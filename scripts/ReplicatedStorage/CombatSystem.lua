-- CombatSystem: Unified combat module for stun, knockdown, knockback, recover, blocking, clash, and damage systems.
-- Replaces per-kaiju CombatModule copies. All kaiju attacksystem scripts should require this module.
-- DO NOT modify individual kaiju CombatModule copies — use this shared module instead.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote events (shared across all kaiju)
local CombatTargetEvent = ReplicatedStorage:FindFirstChild("CombatTarget")
local ComboEvent = ReplicatedStorage:FindFirstChild("ComboEvent")
local HitEffectEvent = ReplicatedStorage:FindFirstChild("HitEffectEvent")
local KnockbackEvent = ReplicatedStorage:FindFirstChild("KnockbackEvent")

-- Load damage/stun data from central Damage module
local DamageModule = require(game.Lighting.Assets.Damage)

-- Load BuildingHealth module for NumberValue-based building health
local BuildingHealth = require(ReplicatedStorage:FindFirstChild("BuildingHealth"))

----------------------------------------------------------------
-- SHARED STATE
----------------------------------------------------------------

-- Per-player state (shared with attacksystem scripts)
local playerState = {} -- [userId] = {attackTrack, blockTrack, comboStep, lastLMBTime, isStunned, isBlocking, isRoaring, isRaging, isBusy, isBeaming, isAttackingLMB, cancelAttack, savedWalkSpeed, ...}

-- Per-character stun tracking (generation-based to invalidate old timers)
local stunState = {}       -- [character] = {endTime, stunnedTrack, savedWalkSpeed}
local stunGeneration = {}  -- [character] = generation counter
local recoverySavedSpeed = {}  -- [character] = savedWalkSpeed (preserved across stun→knockdown→grab transitions)

-- Per-attacker combo tracking (server-side, for knockback/damage scaling)
local attackerComboCount = {} -- [attackerChar] = {count = N, lastHitTime = T}

-- Clash cooldown tracking
local clashCooldowns = {} -- [char1][char2] = tick() when clash was resolved

----------------------------------------------------------------
-- COMBAT CONSTANTS
----------------------------------------------------------------

local HITSTOP_LIGHT = 0.06
local HITSTOP_HEAVY = 0.1
local COMBO_RESET_TIME = 3
local DAMAGE_SCALE_PER_HIT = 0.08
local MIN_DAMAGE_SCALE = 0.5
local CLASH_WINDOW = 0.15
local CLASH_COOLDOWN = 1.5
-- After a clash resolves, any hit still in flight between the same two fighters is thrown away for this long.
-- (Hitboxes that already touched keep firing after both attacks are cancelled, which used to stun both fighters.)
local CLASH_LOCK = 0.5

local function recentlyClashed(charA, charB)
	local key1, key2 = charA, charB
	if key1.Name > key2.Name then key1, key2 = key2, key1 end
	local t = clashCooldowns[key1] and clashCooldowns[key1][key2]
	return t ~= nil and (tick() - t) < CLASH_LOCK
end

-- First hit wins: a fighter who is stunned, knocked down, grabbed, dead or whose attack was cancelled
-- cannot land a hit that was already in flight. This stops "both players get stunned" trades.
local function canAttackerHit(attackerChar)
	if not attackerChar or not attackerChar.Parent then return false end
	local hum = attackerChar:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then return false end
	local aspects = attackerChar:FindFirstChild("Aspects")
	local stunFolder = aspects and aspects:FindFirstChild("Stun")
	if stunFolder then
		for _, name in ipairs({ "Stunned", "Knockdown", "Grabbed" }) do
			local v = stunFolder:FindFirstChild(name)
			if v and v:IsA("BoolValue") and v.Value then return false end
		end
	end
	local plr = Players:GetPlayerFromCharacter(attackerChar)
	local st = plr and playerState[plr.UserId]
	if st and (st.isStunned or st.cancelAttack) then return false end
	return true
end

----------------------------------------------------------------
-- RAGE SYSTEM
----------------------------------------------------------------

local function addRage(character, amount)
	if not character or not character.Parent then return end
	if amount <= 0 then return end
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		local state = playerState[player.UserId]
		if state and state.isRaging then return end
	end
	local aspects = character:FindFirstChild("Aspects")
	if not aspects then return end
	local info = aspects:FindFirstChild("Info")
	if not info then return end
	local rage = info:FindFirstChild("Rage")
	if not rage or not rage:IsA("NumberValue") then return end
	local maxRage = rage:FindFirstChild("MaxRage")
	local max = maxRage and maxRage:IsA("NumberValue") and maxRage.Value or 100
	rage.Value = math.min(rage.Value + amount, max)
end

----------------------------------------------------------------
-- DAMAGE / STUN DATA HELPERS
----------------------------------------------------------------

local function getDamage(key)
	local val = DamageModule[key]
	return typeof(val) == "number" and val or 0
end

local function getStun(key)
	local val = DamageModule[key]
	return typeof(val) == "number" and val or 1.2
end

----------------------------------------------------------------
-- ANIMATION HELPERS
----------------------------------------------------------------

local function stopTrack(track, fadeTime)
	if track and track.IsPlaying then
		track:Stop(fadeTime or 0.1)
	end
end

local function playAttackAnimation(animationsFolder, animator, animName)
	if not animationsFolder or not animator then return nil end
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track.Priority == Enum.AnimationPriority.Action then
			track:Stop(0.1)
		end
	end
	local anim = animationsFolder:FindFirstChild(animName)
	if anim and anim:IsA("Animation") and anim.AnimationId ~= "" then
		local track = animator:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		return track
	end
	return nil
end

----------------------------------------------------------------
-- VFX HELPERS
----------------------------------------------------------------

local recoverEffectCooldown = {} -- [character] = tick() of last recover effect

local function playRecoverEffect(character)
	-- Stun-state guard: block recover effects if the character is still in ANY stun state.
	-- This prevents recover effects/sounds from playing during combos or when transitioning
	-- between stun types (e.g., Stunned -> Knockdown). Only play when truly recovered.
	local aspects = character:FindFirstChild("Aspects")
	local stunFolder = aspects and aspects:FindFirstChild("Stun")
	if stunFolder then
		local stunned = stunFolder:FindFirstChild("Stunned")
		local knockdown = stunFolder:FindFirstChild("Knockdown")
		local grabbed = stunFolder:FindFirstChild("Grabbed")
		if (stunned and stunned:IsA("BoolValue") and stunned.Value)
			or (knockdown and knockdown:IsA("BoolValue") and knockdown.Value)
			or (grabbed and grabbed:IsA("BoolValue") and grabbed.Value) then
			return
		end
	end

	-- Debounce: prevent multiple recover effects in quick succession (e.g., during combos)
	-- Uses a shared attribute so both CombatSystem and NPC scripts (DummyG2K) share the same cooldown
	local now = tick()
	local lastRecover = character:GetAttribute("LastRecoverEffect") or 0
	if (now - lastRecover) < 1.5 then
		return
	end
	character:SetAttribute("LastRecoverEffect", now)

	local recoverTemplate = game.Lighting:FindFirstChild("Assets")
		and game.Lighting.Assets:FindFirstChild("Effects")
		and game.Lighting.Assets.Effects:FindFirstChild("HitEffects")
		and game.Lighting.Assets.Effects.HitEffects:FindFirstChild("Recover")
	if not recoverTemplate then return end
	local targetHrp = character:FindFirstChild("HumanoidRootPart")
	if not targetHrp then return end

	local recoverClone = recoverTemplate:Clone()
	recoverClone.CFrame = targetHrp.CFrame
	recoverClone.Anchored = true
	recoverClone.CanCollide = false
	recoverClone.Transparency = 1
	for _, desc in ipairs(recoverClone:GetDescendants()) do
		if desc:IsA("ParticleEmitter") then
			desc.Enabled = true
		end
	end
	recoverClone.Parent = character

	local recoverSound = targetHrp:FindFirstChild("Recover")
	if recoverSound and recoverSound:IsA("Sound") then
		recoverSound:Play()
	end

	-- Keep effect for the original 1 second, then fade particles for 0.7s more before destroying
	task.delay(1, function()
		if not recoverClone or not recoverClone.Parent then return end
		-- Disable particle emitters so existing particles fade out naturally
		for _, desc in ipairs(recoverClone:GetDescendants()) do
			if desc:IsA("ParticleEmitter") then
				desc.Enabled = false
			end
		end
		task.delay(0.7, function()
			if recoverClone and recoverClone.Parent then
				recoverClone:Destroy()
			end
		end)
	end)
end

local function setBlockEffects(character, enabled)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local attachment = hrp:FindFirstChild("Attachment")
	if not attachment then return end
	for _, name in ipairs({"BlockCircle", "BlockFX"}) do
		local effect = attachment:FindFirstChild(name)
		if effect then
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("PointLight") or effect:IsA("SpotLight") or effect:IsA("SurfaceLight") then
				effect.Enabled = enabled
			elseif effect:IsA("BasePart") then
				effect.Transparency = enabled and 0 or 1
			end
			for _, desc in ipairs(effect:GetDescendants()) do
				if desc:IsA("ParticleEmitter") or desc:IsA("Beam") then
					desc.Enabled = enabled
				end
			end
		end
	end
end

----------------------------------------------------------------
-- HITSTOP / HIT FLASH
----------------------------------------------------------------

local function applyHitstop(attackerChar, targetChar, duration)
	-- Animation pausing has been removed per request
end

----------------------------------------------------------------
-- BUILDING HIT EFFECT
----------------------------------------------------------------

local function applyBuildingHitEffect(building, attackerHrp, isHeavy)
	local hrp = building:FindFirstChild("HumanoidRootPart")

	for _, desc in building:GetDescendants() do
		if desc.Name == "Hit" and desc:IsA("Sound") then
			desc:Play()
			break
		end
	end

	-- Blood gash effect
	local gashTemplate = game.Lighting:FindFirstChild("Assets")
		and game.Lighting.Assets:FindFirstChild("Effects")
		and game.Lighting.Assets.Effects:FindFirstChild("HitEffects")
		and game.Lighting.Assets.Effects.HitEffects:FindFirstChild("Gash")
	if gashTemplate and hrp then
		task.spawn(function()
			local gashClone = gashTemplate:Clone()
			gashClone.CFrame = hrp.CFrame
			gashClone.Anchored = true
			gashClone.CanCollide = false
			gashClone.Transparency = 1
			gashClone.Parent = workspace
			if gashClone:IsA("BasePart") then
				gashClone.Color = Color3.new(0.8, 0, 0)
				gashClone.Material = Enum.Material.Neon
			end
			for _, gashDesc in ipairs(gashClone:GetDescendants()) do
				if gashDesc:IsA("BasePart") then
					gashDesc.Color = Color3.new(0.8, 0, 0)
					gashDesc.Material = Enum.Material.Neon
					gashDesc.Transparency = 1
				elseif gashDesc:IsA("ParticleEmitter") then
					gashDesc.Color = ColorSequence.new(Color3.new(0.8, 0, 0))
					gashDesc.Enabled = true
				end
			end
			local gashSound = gashClone:FindFirstChild("Gash")
			if gashSound and gashSound:IsA("Sound") then gashSound:Play() end
			task.wait(0.8)
			if gashClone and gashClone.Parent then gashClone:Destroy() end
		end)
	end

	local impactPos = nil
	if attackerHrp then
		impactPos = hrp and hrp.Position or building:GetPivot().Position
		local closestDist = math.huge
		for _, desc in building:GetDescendants() do
			if desc:IsA("BasePart") and desc.Transparency < 1 then
				local localPoint = desc.CFrame:ToObjectSpace(CFrame.new(attackerHrp.Position)).Position
				local halfSize = desc.Size / 2
				local clamped = Vector3.new(
					math.clamp(localPoint.X, -halfSize.X, halfSize.X),
					math.clamp(localPoint.Y, -halfSize.Y, halfSize.Y),
					math.clamp(localPoint.Z, -halfSize.Z, halfSize.Z)
				)
				local cp = desc.CFrame:PointToWorldSpace(clamped)
				local dist = (cp - attackerHrp.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					impactPos = cp
				end
			end
		end
	end
	if not impactPos or not attackerHrp then return end

	local tempPart = Instance.new("Part")
	tempPart.Name = "BuildingHitFX"
	tempPart.Size = Vector3.new(1, 1, 1)
	tempPart.Transparency = 1
	tempPart.CanCollide = false
	tempPart.CanQuery = false
	tempPart.Anchored = true
	tempPart.CFrame = CFrame.new(impactPos)
	tempPart.Parent = workspace

	local debris = Instance.new("ParticleEmitter")
	debris.Name = "Debris"
	debris.Texture = "rbxassetid://243660364"
	debris.Color = ColorSequence.new(Color3.fromRGB(120, 110, 100), Color3.fromRGB(80, 70, 60))
	debris.Size = NumberSequence.new(isHeavy and 6 or 3, isHeavy and 12 or 8)
	debris.Transparency = NumberSequence.new(0.2, 1)
	debris.Lifetime = NumberRange.new(0.4, 0.8)
	debris.Rate = 0
	debris.Speed = NumberRange.new(isHeavy and 20 or 12, isHeavy and 35 or 22)
	debris.SpreadAngle = Vector2.new(45, 45)
	debris.Rotation = NumberRange.new(0, 360)
	debris.Acceleration = Vector3.new(0, -15, 0)
	debris.Enabled = false
	debris.Parent = tempPart

	debris.Enabled = true
	debris:Emit(isHeavy and 30 or 15)
	debris.Enabled = false

	task.delay(2, function()
		if tempPart and tempPart.Parent then
			tempPart.Parent = nil
		end
	end)
end

----------------------------------------------------------------
-- HITBOX HELPERS
----------------------------------------------------------------

local function createHitbox(size, cframe, parent)
	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = size
	hitbox.CFrame = cframe
	hitbox.Color = Color3.new(1, 0, 0)
	hitbox.Transparency = 1
	hitbox.Anchored = false
	hitbox.CanCollide = false
	hitbox.Massless = true
	hitbox.CanTouch = true
	hitbox.CanQuery = true
	hitbox.CastShadow = false
	hitbox.Parent = parent
	return hitbox
end

local function weldHitbox(hitbox, part, offset)
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = hitbox
	weld.C0 = offset or CFrame.new()
	weld.C1 = CFrame.new()
	weld.Parent = hitbox
end

----------------------------------------------------------------
-- CHARACTER DETECTION HELPERS
----------------------------------------------------------------

local function getCharacterFromPart(part)
	-- Only detect characters through visible parts (Transparency == 0).
	-- This prevents combat detection via invisible helper parts like grabbers, beam hitboxes, hitboxes, HumanoidRootPart, etc.
	if part:IsA("BasePart") and part.Transparency > 0 then
		return nil
	end
	local current = part
	while current and current ~= workspace do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			return current
		end
		current = current.Parent
	end
	return nil
end

local function closestPointOnPart(part, point)
	local localPoint = part.CFrame:ToObjectSpace(CFrame.new(point)).Position
	local halfSize = part.Size / 2
	local clamped = Vector3.new(
		math.clamp(localPoint.X, -halfSize.X, halfSize.X),
		math.clamp(localPoint.Y, -halfSize.Y, halfSize.Y),
		math.clamp(localPoint.Z, -halfSize.Z, halfSize.Z)
	)
	return part.CFrame:PointToWorldSpace(clamped)
end

local function isBuilding(character)
	if not character then return false end
	local buildingsFolder = workspace:FindFirstChild("Buildings")
	if not buildingsFolder then return false end
	return character:IsDescendantOf(buildingsFolder)
end

----------------------------------------------------------------
-- BLOCK DETECTION
----------------------------------------------------------------

local isTargetBlocking -- forward declaration

isTargetBlocking = function(character)
	local aspects = character:FindFirstChild("Aspects")
	local defense = aspects and aspects:FindFirstChild("Defense")
	local blockingVal = defense and defense:FindFirstChild("Blocking")
	if blockingVal and blockingVal:IsA("BoolValue") and blockingVal.Value then
		return true
	end
	local targetPlayer = Players:GetPlayerFromCharacter(character)
	if targetPlayer then
		local targetState = playerState[targetPlayer.UserId]
		if targetState and targetState.isBlocking then
			return true
		end
	end
	return false
end

local function isTargetRaging(character)
	local targetPlayer = Players:GetPlayerFromCharacter(character)
	if targetPlayer then
		local targetState = playerState[targetPlayer.UserId]
		if targetState and targetState.isRaging then
			return true
		end
	end
	return false
end

----------------------------------------------------------------
-- KNOCKBACK SYSTEM
----------------------------------------------------------------

local function applyKnockback(targetChar, attackerHrp, horizontalForce, verticalForce)
	if isBuilding(targetChar) then
		return
	end

	if isTargetBlocking(targetChar) then
		return
	end

	local kbTargetPlayer = Players:GetPlayerFromCharacter(targetChar)
	if kbTargetPlayer then
		local kbTargetState = playerState[kbTargetPlayer.UserId]
		if kbTargetState and kbTargetState.isRoaring then
			return
		end
		if kbTargetState and kbTargetState.isRaging then
			return
		end
	end

	local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHrp or not attackerHrp or not attackerHrp.Parent then return end

	local pushDir = attackerHrp.CFrame.LookVector
	pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
	if pushDir.Magnitude > 0 then
		pushDir = pushDir.Unit
	end

	local attackerChar = attackerHrp.Parent
	local comboData = attackerComboCount[attackerChar]
	local comboCount = comboData and comboData.count or 0
	local comboMult = math.min(1 + 0.12 * math.max(0, comboCount - 1), 2.0)

	local scaledH = horizontalForce * comboMult

	if kbTargetPlayer and KnockbackEvent then
		KnockbackEvent:FireClient(kbTargetPlayer, pushDir, scaledH, 0)
		return
	end

	local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

	local savedWalkSpeed = nil
	local shouldRestoreWalkSpeed = false
	if targetHum then
		local stunCheckPlayer = Players:GetPlayerFromCharacter(targetChar)
		local stunCheckState = stunCheckPlayer and playerState[stunCheckPlayer.UserId]
		if not (stunCheckState and stunCheckState.isStunned) and not (stunCheckState and stunCheckState.savedWalkSpeed ~= nil) then
			savedWalkSpeed = targetHum.WalkSpeed
			if savedWalkSpeed <= 0 then savedWalkSpeed = 16 end
			targetHum.WalkSpeed = 0
			shouldRestoreWalkSpeed = true
		end
	end

	local attachment = targetHrp:FindFirstChild("KnockbackAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "KnockbackAttachment"
		attachment.Parent = targetHrp
	end

	local existingVelocity = targetHrp:FindFirstChild("KnockbackVelocity")
	if existingVelocity then existingVelocity:Destroy() end

	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "KnockbackVelocity"
	linearVelocity.Attachment0 = attachment
	linearVelocity.VectorVelocity = pushDir * scaledH
	linearVelocity.ForceLimitsEnabled = false
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Parent = targetHrp

	targetHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

	local knockbackDuration = 0.3
	task.delay(knockbackDuration, function()
		if linearVelocity and linearVelocity.Parent then
			linearVelocity:Destroy()
		end
		if shouldRestoreWalkSpeed and targetHum and targetHum.Parent then
			if savedWalkSpeed ~= nil then
				local speed = savedWalkSpeed
				if speed <= 0 then speed = 16 end
				targetHum.WalkSpeed = speed
			end
		end
	end)
end

----------------------------------------------------------------
-- ATTACK CANCELLATION
----------------------------------------------------------------

local function cancelCurrentAttack(character)
	if not character or not character.Parent then return end
	local targetPlayer = Players:GetPlayerFromCharacter(character)
	if not targetPlayer then return end
	local targetState = playerState[targetPlayer.UserId]
	if not targetState then return end

	if targetState.isRoaring then
		return
	end

	if targetState.isRaging then
		return
	end

	targetState.cancelAttack = true

	if targetState.attackTrack and targetState.attackTrack.IsPlaying then
		targetState.attackTrack:Stop(0.1)
	end
	targetState.attackTrack = nil

	if targetState.blockTrack and targetState.blockTrack.IsPlaying then
		targetState.blockTrack:Stop(0.1)
	end
	targetState.blockTrack = nil
	targetState.isBlocking = false

	local aspects = character:FindFirstChild("Aspects")
	local defense = aspects and aspects:FindFirstChild("Defense")
	local blockingVal = defense and defense:FindFirstChild("Blocking")
	if blockingVal and blockingVal:IsA("BoolValue") then
		blockingVal.Value = false
	end

	targetState.isBusy = false
	targetState.isAttackingLMB = false
	targetState.isBeaming = false

	for _, child in ipairs(character:GetChildren()) do
		if child.Name == "HitboxHolder" then
			child:Destroy()
		end
	end

	local beamHitbox = character:FindFirstChild("BeamHitbox")
	if beamHitbox then
		beamHitbox.CanTouch = false
		beamHitbox.Transparency = 1
	end

	if HitEffectEvent and targetPlayer then
		HitEffectEvent:FireClient(targetPlayer, "BeamShakeEnd")
	end

	local attachStart = character:FindFirstChild("AttachStart")
	if attachStart then
		for _, beam in ipairs(attachStart:GetDescendants()) do
			if beam:IsA("Beam") then beam.Enabled = false end
		end
		local trail = attachStart:FindFirstChild("Trail")
		if trail and trail:IsA("Trail") then trail.Enabled = false end
	end

	local beamColors = character:FindFirstChild("BeamColors")
	if beamColors then
		for _, desc in ipairs(beamColors:GetDescendants()) do
			if desc:IsA("Light") then
				desc.Enabled = false
			end
		end
		local aspectsColors = aspects and aspects:FindFirstChild("Colors")
		local normalColorVal = aspectsColors and aspectsColors:FindFirstChild("NormalColor")
		local normalColor = normalColorVal and normalColorVal.Value
		for _, desc in ipairs(beamColors:GetDescendants()) do
			if desc:IsA("BasePart") then
				desc.Material = Enum.Material.SmoothPlastic
				if string.find(string.lower(desc.Name), "blue") then
					desc.Transparency = 1
				elseif normalColor then
					desc.Color = normalColor
				end
				local beamCharge = desc:FindFirstChild("BeamCharge")
				if beamCharge and beamCharge:IsA("ParticleEmitter") then
					beamCharge.Enabled = false
				end
			end
		end
	end

	local fakeHead = character:FindFirstChild("FakeHead")
	if fakeHead then
		local blood = fakeHead:FindFirstChild("Blood")
		if blood and blood:IsA("ParticleEmitter") then
			blood.Enabled = false
		end
	end

	local hollowEarth = character:FindFirstChild("HollowEarth")
	if hollowEarth then
		for _, desc in ipairs(hollowEarth:GetDescendants()) do
			if desc:IsA("ParticleEmitter") then desc.Enabled = false end
			if desc:IsA("Light") then desc.Enabled = false end
		end
		for _, part in ipairs(hollowEarth:GetChildren()) do
			if part:IsA("BasePart") then part.Transparency = 1 end
		end
	end

	for _, desc in ipairs(character:GetDescendants()) do
		if desc:IsA("Trail") and (desc.Name == "TailTrail" or (desc.Parent and (string.match(desc.Parent.Name, "^t%d+$") or string.match(desc.Parent.Name, "^Tail %d+$")))) then
			desc.Enabled = false
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and targetState.savedWalkSpeed and not targetState.isStunned then
		local speed = targetState.savedWalkSpeed
		if speed <= 0 then speed = 16 end
		humanoid.WalkSpeed = speed
	end
	targetState.savedWalkSpeed = nil

	setBlockEffects(character, false)

	local forceWalk = character:FindFirstChild("ForceWalk")
	if forceWalk then forceWalk.Value = false end
end

----------------------------------------------------------------
-- STUN SYSTEM (generation-based, refreshes on repeated hits — does NOT accumulate)
-- During a combo, each hit refreshes the stun timer to stunDuration from now.
-- The stun only ends stunDuration after the LAST hit. Stun time never stacks.
----------------------------------------------------------------

local function applyStun(character, attackerChar, stunDuration)
	local now = tick()
	local stunTime = stunDuration or 1.2

	local aspects = character:FindFirstChild("Aspects")
	local stunFolder = aspects and aspects:FindFirstChild("Stun")
	local knockdownVal = stunFolder and stunFolder:FindFirstChild("Knockdown")
	local grabbedVal = stunFolder and stunFolder:FindFirstChild("Grabbed")
	if (knockdownVal and knockdownVal.Value) or (grabbedVal and grabbedVal.Value) then
		return
	end

	if isTargetRaging(character) then
		return
	end

	local existing = stunState[character]
	local newEndTime = now + stunTime

	-- If already stunned (combo continuation): refresh the timer instead of stacking.
	-- The stun will end stunTime after the LAST hit — durations do NOT add up.
	if existing and existing.endTime > now then
		existing.endTime = newEndTime
	else
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChild("Animator")
		local stunnedTrack = nil
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
			local animFolder = character:FindFirstChild("Animations")
			if animFolder then
				local stunAnim = animFolder:FindFirstChild("Stunned")
				if stunAnim and stunAnim:IsA("Animation") and stunAnim.AnimationId ~= "" then
					stunnedTrack = animator:LoadAnimation(stunAnim)
					stunnedTrack.Priority = Enum.AnimationPriority.Action
					stunnedTrack:Play()
				end
			end
		end

		local savedStunWalkSpeed = nil
		if humanoid then
			local targetPlayer = Players:GetPlayerFromCharacter(character)
			local targetState = targetPlayer and playerState[targetPlayer.UserId]
			if targetState and targetState.savedWalkSpeed ~= nil then
				savedStunWalkSpeed = targetState.savedWalkSpeed
				targetState.savedWalkSpeed = nil
			else
				savedStunWalkSpeed = humanoid.WalkSpeed
				if savedStunWalkSpeed <= 0 then savedStunWalkSpeed = 16 end
			end
			humanoid.WalkSpeed = 0
		end

		if stunFolder then
			local stunnedValue = stunFolder:FindFirstChild("Stunned")
			if stunnedValue and stunnedValue:IsA("BoolValue") then
				stunnedValue.Value = true
			end
		end

		local targetPlayer = Players:GetPlayerFromCharacter(character)
		if targetPlayer then
			local targetState = playerState[targetPlayer.UserId]
			if targetState then
				targetState.isStunned = true
			end
		end

		stunState[character] = {
			endTime = newEndTime,
			stunnedTrack = stunnedTrack,
			savedWalkSpeed = savedStunWalkSpeed,
		}
	end

	stunGeneration[character] = (stunGeneration[character] or 0) + 1
	local currentGen = stunGeneration[character]

	task.delay(stunTime, function()
		-- Only the latest generation's timer may end the stun.
		-- This ensures combo hits cancel the pending recovery and only the
		-- final hit's timer actually ends the stun.
		if stunGeneration[character] ~= currentGen then return end
		if not stunState[character] then return end

		local entry = stunState[character]
		stunState[character] = nil

		local aspectsCheck = character:FindFirstChild("Aspects")
		local stunFolderCheck = aspectsCheck and aspectsCheck:FindFirstChild("Stun")
		local knockdown = stunFolderCheck and stunFolderCheck:FindFirstChild("Knockdown")
		local grabbed = stunFolderCheck and stunFolderCheck:FindFirstChild("Grabbed")
		local isStillStunned = (knockdown and knockdown.Value) or (grabbed and grabbed.Value)

		if not isStillStunned then
			if entry and entry.stunnedTrack and entry.stunnedTrack.IsPlaying then
				entry.stunnedTrack:Stop()
			end
			if stunFolderCheck then
				local stunnedVal = stunFolderCheck:FindFirstChild("Stunned")
				if stunnedVal and stunnedVal:IsA("BoolValue") then
					stunnedVal.Value = false
				end
			end
			local targetHumanoid = character:FindFirstChildOfClass("Humanoid")
			if targetHumanoid and entry and entry.savedWalkSpeed ~= nil then
				local speed = entry.savedWalkSpeed
				if speed <= 0 then speed = 16 end
				targetHumanoid.WalkSpeed = speed
			end
			local targetPlayer = Players:GetPlayerFromCharacter(character)
			if targetPlayer then
				local targetState = playerState[targetPlayer.UserId]
				if targetState then
					targetState.isStunned = false
				end
			end
			playRecoverEffect(character)
			-- Clear any stale recovery saved speed (knockdown/grab may have set it)
			recoverySavedSpeed[character] = nil
		end
	end)
end

----------------------------------------------------------------
-- BLOCK BREAK SYSTEM
----------------------------------------------------------------

local function breakBlock(character)
	local targetPlayer = Players:GetPlayerFromCharacter(character)
	if targetPlayer then
		local targetState = playerState[targetPlayer.UserId]
		if targetState and targetState.isBlocking then
			targetState.isBlocking = false
			stopTrack(targetState.blockTrack)
			targetState.blockTrack = nil
		end
	end
	local aspects = character:FindFirstChild("Aspects")
	local defense = aspects and aspects:FindFirstChild("Defense")
	local blockingVal = defense and defense:FindFirstChild("Blocking")
	if blockingVal and blockingVal:IsA("BoolValue") then
		blockingVal.Value = false
	end
	setBlockEffects(character, false)
	local forceWalk = character:FindFirstChild("ForceWalk")
	if forceWalk then forceWalk.Value = false end
end

----------------------------------------------------------------
-- CLASH SYSTEM
----------------------------------------------------------------

local setKnockdown -- forward declaration (needed by resolveClash)

local function resolveClash(attackerChar, targetChar, damage, stunDuration, isHeavy)
	if isTargetRaging(attackerChar) or isTargetRaging(targetChar) then
		return false
	end

	local key1, key2 = attackerChar, targetChar
	if key1.Name > key2.Name then key1, key2 = key2, key1 end

	local now = tick()
	if clashCooldowns[key1] and clashCooldowns[key1][key2] and (now - clashCooldowns[key1][key2]) < CLASH_COOLDOWN then
		return false
	end

	local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
	local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
	if not attackerPlayer or not targetPlayer then return false end

	local attackerState = playerState[attackerPlayer.UserId]
	local targetState = playerState[targetPlayer.UserId]
	if not attackerState or not targetState then return false end

	if not attackerState.isAttackingLMB or not targetState.isAttackingLMB then
		return false
	end

	clashCooldowns[key1] = clashCooldowns[key1] or {}
	clashCooldowns[key1][key2] = now

	local attackerTime = attackerState.attackStartTime or 0
	local targetTime = targetState.attackStartTime or 0
	local timeDiff = attackerTime - targetTime

	local winnerChar, loserChar

	if math.abs(timeDiff) <= CLASH_WINDOW then
		if (targetState.comboStep or 1) > (attackerState.comboStep or 1) then
			winnerChar = targetChar
			loserChar = attackerChar
		else
			winnerChar = attackerChar
			loserChar = targetChar
		end
	elseif attackerTime < targetTime then
		winnerChar = attackerChar
		loserChar = targetChar
	else
		winnerChar = targetChar
		loserChar = attackerChar
	end

	for _, char in ipairs({winnerChar, loserChar}) do
		local hum = char:FindFirstChildOfClass("Humanoid")
		local anim = hum and hum:FindFirstChild("Animator")
		if anim then
			for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
				if track.Priority == Enum.AnimationPriority.Action then
					track:Stop(0.05)
				end
			end
			local animFolder = char:FindFirstChild("Animations")
			if animFolder then
				local clashAnim = animFolder:FindFirstChild("MeleeClash")
				if clashAnim and clashAnim:IsA("Animation") and clashAnim.AnimationId ~= "" then
					local track = anim:LoadAnimation(clashAnim)
					track.Priority = Enum.AnimationPriority.Action
					track:Play()
				end
			end
		end
	end

	cancelCurrentAttack(winnerChar)
	cancelCurrentAttack(loserChar)

	local winnerHrp = winnerChar:FindFirstChild("HumanoidRootPart")
	if winnerHrp then
		local winSound = winnerHrp:FindFirstChild("WinClash")
		if winSound and winSound:IsA("Sound") then winSound:Play() end
	end

	local loserHrp = loserChar:FindFirstChild("HumanoidRootPart")
	local loserHum = loserChar:FindFirstChildOfClass("Humanoid")
	local clashActualDamage = 0
	if loserHum and loserHum.Health > 0 then
		local healthBefore = loserHum.Health
		loserHum:TakeDamage(damage * 0.75)
		clashActualDamage = healthBefore - loserHum.Health
		if clashActualDamage > 0 then
			addRage(winnerChar, clashActualDamage * 0.25)
			addRage(loserChar, clashActualDamage * 0.15)
		end
	end

	applyHitstop(winnerChar, loserChar, HITSTOP_HEAVY * 2)

	if winnerHrp and loserHrp then
		applyKnockback(loserChar, winnerHrp, 70, 30)
	end
	setKnockdown(loserChar, true)
	task.delay(1.2, function()
		if loserChar and loserChar.Parent then
			setKnockdown(loserChar, false)
		end
	end)

	local winnerPlayer = Players:GetPlayerFromCharacter(winnerChar)
	if winnerPlayer and HitEffectEvent then
		HitEffectEvent:FireClient(winnerPlayer, "ScreenShake", 2.0, 0.3)
	end
	local loserPlayer = Players:GetPlayerFromCharacter(loserChar)
	if loserPlayer and HitEffectEvent then
		HitEffectEvent:FireClient(loserPlayer, "ScreenShake", 3.0, 0.4)
	end

	if winnerPlayer and ComboEvent then
		ComboEvent:FireClient(winnerPlayer, damage * 0.75)
	end

	if clashActualDamage > 0 and winnerPlayer then
		local winnerStats = winnerPlayer:FindFirstChild("Stats")
		if winnerStats then
			local td = winnerStats:FindFirstChild("TotalDamage")
			if td then
				td.Value = td.Value + math.floor(clashActualDamage)
			end
			local mk = winnerStats:FindFirstChild("MainKaiju")
			local ku = winnerStats:FindFirstChild("KaijuUsage")
			local inv = winnerPlayer:FindFirstChild("Inventory")
			local skin = inv and inv:FindFirstChild("Skin")
			if mk and ku and skin and skin.Value ~= "" then
				local kaijuName = skin.Value
				local usage = {}
				if ku.Value ~= "" then
					for kaiju, countStr in string.gmatch(ku.Value, "([^,:]+):(%d+)") do
						usage[kaiju] = tonumber(countStr) or 0
					end
				end
				usage[kaijuName] = (usage[kaijuName] or 0) + 1
				local maxCount = 0
				local maxKaiju = kaijuName
				for kaiju, count in pairs(usage) do
					if count > maxCount then
						maxCount = count
						maxKaiju = kaiju
					end
				end
				mk.Value = maxKaiju
				local parts = {}
				for kaiju, count in pairs(usage) do
					table.insert(parts, kaiju .. ":" .. count)
				end
				ku.Value = table.concat(parts, ",")
			end
		end
	end

	if winnerPlayer and CombatTargetEvent then
		CombatTargetEvent:FireClient(winnerPlayer, loserChar)
	end

	if loserHum and loserHum.Health <= 0 and winnerPlayer and not isBuilding(loserChar) then
		local killTracking = _G.FFAKillTracking
		if killTracking and killTracking.addKill then
			killTracking.addKill(winnerPlayer.UserId)
		end

		local teamTracking = _G.TeamKillTracking
		if teamTracking and teamTracking.AddKill and teamTracking.GetTeam then
			local killerTeam = teamTracking.GetTeam(winnerPlayer)
			if killerTeam then
				teamTracking.AddKill(killerTeam)
			end
		end

		local wStats = winnerPlayer:FindFirstChild("Stats")
		if wStats then
			local kv = wStats:FindFirstChild("K")
			if kv then kv.Value = kv.Value + 1 end
		end
		local lPlayer = Players:GetPlayerFromCharacter(loserChar)
		if lPlayer then
			local lStats = lPlayer:FindFirstChild("Stats")
			if lStats then
				local dv = lStats:FindFirstChild("D")
				if dv then dv.Value = dv.Value + 1 end
			end
		end

		if _G.AddXP then
			_G.AddXP(winnerPlayer, math.random(40, 60))
		end

		local gcellReward = math.random(6, 15)
		local winnerInventory = winnerPlayer:FindFirstChild("Inventory")
		if winnerInventory then
			local gcells = winnerInventory:FindFirstChild("GCells")
			if gcells and gcells:IsA("IntValue") then
				gcells.Value = gcells.Value + gcellReward
			end
		end

		local gcellEvent = ReplicatedStorage:FindFirstChild("GCellKillReward")
		if gcellEvent then
			local loserP = Players:GetPlayerFromCharacter(loserChar)
			local victimName = loserP and loserP.Name or loserChar.Name
			local winnerInv = winnerPlayer:FindFirstChild("Inventory")
			local winnerSkin = winnerInv and winnerInv:FindFirstChild("Skin")
			local attackerKaijuName = winnerSkin and winnerSkin.Value or ""
			local loserInv = loserP and loserP:FindFirstChild("Inventory")
			local loserSkin = loserInv and loserInv:FindFirstChild("Skin")
			local victimKaijuName = loserSkin and loserSkin.Value or ""
			gcellEvent:FireAllClients(winnerPlayer.Name, gcellReward, victimName, attackerKaijuName, victimKaijuName)
		end
	end

	return true
end

----------------------------------------------------------------
-- DAMAGE SYSTEM
----------------------------------------------------------------

local function dealDamage(character, amount, attackerChar, stunDuration, bypassBlock, lookAtAttacker, isHeavyHit)
	if isTargetRaging(character) then
		return
	end

	-- First hit wins: ignore hits from an attacker who can no longer attack (stunned/knocked down/dead/cancelled),
	-- and hits between two fighters that just clashed. Without this, queued hitboxes stun both sides.
	if attackerChar and attackerChar ~= character then
		if not canAttackerHit(attackerChar) then
			return
		end
		if recentlyClashed(attackerChar, character) then
			return
		end
	end

	if not bypassBlock then
		local targetPlayer = Players:GetPlayerFromCharacter(character)
		if targetPlayer then
			local targetState = playerState[targetPlayer.UserId]
			if targetState and targetState.isAttackingLMB then
				local clashResult = resolveClash(attackerChar, character, amount, stunDuration, isHeavyHit)
				if clashResult then
					return
				end
			end
		end
	end

	if not bypassBlock and isTargetBlocking(character) then
		local blockBroken = false
		local aspects = character:FindFirstChild("Aspects")
		if aspects then
			local info = aspects:FindFirstChild("Info")
			if info then
				local stamina = info:FindFirstChild("Stamina")
				if stamina then
					local staminaDrain = amount * 0.5
					stamina.Value = math.max(0, stamina.Value - staminaDrain)

					if stamina.Value <= 0 then
						blockBroken = true
						breakBlock(character)
						local targetHrp = character:FindFirstChild("HumanoidRootPart")
						if targetHrp then
							local breakSound = targetHrp:FindFirstChild("BlockBreak")
							if breakSound and breakSound:IsA("Sound") then
								breakSound:Play()
							end
						end
					end
				end
			end
		end

		if not blockBroken then
			local targetHrp = character:FindFirstChild("HumanoidRootPart")
			if targetHrp then
				local blockedSound = targetHrp:FindFirstChild("Blocked")
				if blockedSound and blockedSound:IsA("Sound") then
					blockedSound:Play()
				end
			end
			return
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local targetIsBldg = isBuilding(character)

	-- For buildings, use NumberValue health; for characters, use Humanoid health
	local currentHealth
	if targetIsBldg then
		currentHealth = BuildingHealth.getHealth(character)
	else
		currentHealth = humanoid and humanoid.Health or 0
	end

	if currentHealth > 0 then
		local comboCount = 1
		if attackerChar then
			local now = tick()
			local comboData = attackerComboCount[attackerChar]
			if comboData and (now - comboData.lastHitTime) < COMBO_RESET_TIME then
				comboData.count = comboData.count + 1
				comboData.lastHitTime = now
			else
				attackerComboCount[attackerChar] = {count = 1, lastHitTime = now}
			end
			comboCount = attackerComboCount[attackerChar].count
		end

		attackerComboCount[character] = nil

		local damageScale = math.max(MIN_DAMAGE_SCALE, 1 - DAMAGE_SCALE_PER_HIT * (comboCount - 1))
		local scaledAmount = amount * damageScale

		local healthBefore
		local actualDamage
		if targetIsBldg then
			healthBefore = BuildingHealth.getHealth(character)
			actualDamage = BuildingHealth.dealDamage(character, scaledAmount)
		else
			healthBefore = humanoid.Health
			humanoid:TakeDamage(scaledAmount)
			actualDamage = healthBefore - humanoid.Health
		end

		if actualDamage > 0 then
			local attackerIsRaging = false
			if attackerChar then
				local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
				if attackerPlayer then
					local attackerState = playerState[attackerPlayer.UserId]
					if attackerState and attackerState.isRaging then
						attackerIsRaging = true
					end
				end
			end
			if not targetIsBldg and not attackerIsRaging then
				if attackerChar then
					addRage(attackerChar, actualDamage * 0.25)
				end
				addRage(character, actualDamage * 0.15)
			end
		end

		local targetIsBuilding = targetIsBldg

		if attackerChar and not targetIsBuilding then
			local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
			local attackerState = attackerPlayer and playerState[attackerPlayer.UserId]
			if not (attackerState and attackerState.isBeaming) then
				local hitstopDuration = isHeavyHit and HITSTOP_HEAVY or HITSTOP_LIGHT
				applyHitstop(attackerChar, character, hitstopDuration)
			end
		end

		if targetIsBuilding and attackerChar then
			local attackerHrp = attackerChar:FindFirstChild("HumanoidRootPart")
			applyBuildingHitEffect(character, attackerHrp, isHeavyHit)
		end

		if attackerChar and HitEffectEvent then
			local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
			if attackerPlayer then
				local shakeIntensity = isHeavyHit and 1.5 or 0.7
				local shakeDuration = isHeavyHit and 0.25 or 0.12
				HitEffectEvent:FireClient(attackerPlayer, "ScreenShake", shakeIntensity, shakeDuration)
			end
		end

		local dmgTargetPlayer = Players:GetPlayerFromCharacter(character)
		local targetIsRoaring = dmgTargetPlayer and playerState[dmgTargetPlayer.UserId] and playerState[dmgTargetPlayer.UserId].isRoaring

		if not targetIsRoaring then
			if not targetIsBuilding then
				cancelCurrentAttack(character)
			end
			applyStun(character, attackerChar, stunDuration)
		end

		if actualDamage > 0 and attackerChar then
			local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
			if attackerPlayer and ComboEvent then
				ComboEvent:FireClient(attackerPlayer, actualDamage)
			end

			local attackerStats = attackerPlayer and attackerPlayer:FindFirstChild("Stats")
			if attackerStats then
				local td = attackerStats:FindFirstChild("TotalDamage")
				if td then
					td.Value = td.Value + math.floor(actualDamage)
				end

				local bc = attackerStats:FindFirstChild("BestCombo")
				if bc and comboCount > bc.Value then
					bc.Value = comboCount
				end

				local mk = attackerStats:FindFirstChild("MainKaiju")
				local ku = attackerStats:FindFirstChild("KaijuUsage")
				local inv = attackerPlayer and attackerPlayer:FindFirstChild("Inventory")
				local skin = inv and inv:FindFirstChild("Skin")
				if mk and ku and skin and skin.Value ~= "" then
					local kaijuName = skin.Value
					local usage = {}
					if ku.Value ~= "" then
						for kaiju, countStr in string.gmatch(ku.Value, "([^,:]+):(%d+)") do
							usage[kaiju] = tonumber(countStr) or 0
						end
					end
					usage[kaijuName] = (usage[kaijuName] or 0) + 1
					local maxCount = 0
					local maxKaiju = kaijuName
					for kaiju, count in pairs(usage) do
						if count > maxCount then
							maxCount = count
							maxKaiju = kaiju
						end
					end
					mk.Value = maxKaiju
					local parts = {}
					for kaiju, count in pairs(usage) do
						table.insert(parts, kaiju .. ":" .. count)
					end
					ku.Value = table.concat(parts, ",")
				end
			end
		end

		if lookAtAttacker ~= false and attackerChar and not targetIsRoaring and not isBuilding(character) then
			local attackerHrp = attackerChar:FindFirstChild("HumanoidRootPart")
			if attackerHrp and attackerHrp.Parent then
				if HitEffectEvent and dmgTargetPlayer then
					HitEffectEvent:FireClient(dmgTargetPlayer, "LookAt", attackerHrp.Position)
				else
					local targetHrp = character:FindFirstChild("HumanoidRootPart")
					if targetHrp and targetHrp.Parent then
						task.defer(function()
							if targetHrp and targetHrp.Parent and attackerHrp and attackerHrp.Parent then
								local lookDirection = (attackerHrp.Position - targetHrp.Position)
								lookDirection = Vector3.new(lookDirection.X, 0, lookDirection.Z)
								if lookDirection.Magnitude > 0 then
									targetHrp.CFrame = CFrame.new(targetHrp.Position, targetHrp.Position + lookDirection.Unit)
								end
							end
						end)
					end
				end
			end
		end

		if attackerChar and CombatTargetEvent then
			local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
			if attackerPlayer then
				CombatTargetEvent:FireClient(attackerPlayer, character)
			end
		end

		if humanoid.Health <= 0 and healthBefore > 0 and attackerChar and not isBuilding(character) then
			local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
			if attackerPlayer then
				local killTracking = _G.FFAKillTracking
				if killTracking and killTracking.addKill then
					killTracking.addKill(attackerPlayer.UserId)
				end

				local teamTracking = _G.TeamKillTracking
				if teamTracking and teamTracking.AddKill and teamTracking.GetTeam then
					local killerTeam = teamTracking.GetTeam(attackerPlayer)
					if killerTeam then
						teamTracking.AddKill(killerTeam)
					end
				end

				local aStats = attackerPlayer:FindFirstChild("Stats")
				if aStats then
					local kv = aStats:FindFirstChild("K")
					if kv then kv.Value = kv.Value + 1 end
				end
				local vPlayer = Players:GetPlayerFromCharacter(character)
				if vPlayer then
					local vStats = vPlayer:FindFirstChild("Stats")
					if vStats then
						local dv = vStats:FindFirstChild("D")
						if dv then dv.Value = dv.Value + 1 end
					end
				end

				if _G.AddXP then
					_G.AddXP(attackerPlayer, math.random(40, 60))
				end

				local gcellReward = 6
				local attackerInventory = attackerPlayer:FindFirstChild("Inventory")
				if attackerInventory then
					local gcells = attackerInventory:FindFirstChild("GCells")
					if gcells and gcells:IsA("IntValue") then
						gcells.Value = gcells.Value + gcellReward
					end
				end

				local gcellEvent = ReplicatedStorage:FindFirstChild("GCellKillReward")
				if gcellEvent then
					local victimPlayer = Players:GetPlayerFromCharacter(character)
					local victimName = victimPlayer and victimPlayer.Name or character.Name
					local attackerInv = attackerPlayer:FindFirstChild("Inventory")
					local attackerSkin = attackerInv and attackerInv:FindFirstChild("Skin")
					local attackerKaijuName = attackerSkin and attackerSkin.Value or ""
					local victimInv = victimPlayer and victimPlayer:FindFirstChild("Inventory")
					local victimSkin = victimInv and victimInv:FindFirstChild("Skin")
					local victimKaijuName = victimSkin and victimSkin.Value or ""
					gcellEvent:FireAllClients(attackerPlayer.Name, gcellReward, victimName, attackerKaijuName, victimKaijuName)
				end
			end
		end

		if targetIsBuilding and healthBefore > 0 and BuildingHealth.isDead(character) and attackerChar then
			local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
			if attackerPlayer then
				if _G.AddXP then
					_G.AddXP(attackerPlayer, math.random(40, 60))
				end
			end
		end
	end
end

----------------------------------------------------------------
-- GRAB SYSTEM
----------------------------------------------------------------

local function setGrabbed(targetChar, value)
	if value and isTargetRaging(targetChar) then
		return
	end

	local aspects = targetChar:FindFirstChild("Aspects")
	local stun = aspects and aspects:FindFirstChild("Stun")
	local grabbed = stun and stun:FindFirstChild("Grabbed")
	if grabbed and grabbed:IsA("BoolValue") then
		grabbed.Value = value
	end

	if value then
		local existingStun = stunState[targetChar]
		if existingStun then
			if existingStun.stunnedTrack and existingStun.stunnedTrack.IsPlaying then
				existingStun.stunnedTrack:Stop()
			end
			-- Preserve saved walk speed before clearing stun state
			if existingStun.savedWalkSpeed ~= nil and not recoverySavedSpeed[targetChar] then
				recoverySavedSpeed[targetChar] = existingStun.savedWalkSpeed
			end
			stunState[targetChar] = nil
		end

		-- If no saved speed yet (no existing stun to inherit from), save from humanoid
		if not recoverySavedSpeed[targetChar] then
			local hum = targetChar:FindFirstChildOfClass("Humanoid")
			if hum then
				local speed = hum.WalkSpeed
				if speed <= 0 then speed = 16 end
				recoverySavedSpeed[targetChar] = speed
			end
		end

		local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
		local animator = targetHumanoid and targetHumanoid:FindFirstChild("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
			local animFolder = targetChar:FindFirstChild("Animations")
			if animFolder then
				local grabAnim = animFolder:FindFirstChild("Grabbed")
				if grabAnim and grabAnim:IsA("Animation") and grabAnim.AnimationId ~= "" then
					local track = animator:LoadAnimation(grabAnim)
					track.Priority = Enum.AnimationPriority.Action
					track:Play()
				end
			end
		end

		local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
		if targetPlayer then
			local targetState = playerState[targetPlayer.UserId]
			if targetState then
				targetState.isStunned = true
			end
		end
	else
		local knockdownVal = stun and stun:FindFirstChild("Knockdown")
		local isKnockedDown = knockdownVal and knockdownVal.Value

		if not isKnockedDown then
			local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
			if targetPlayer then
				local targetState = playerState[targetPlayer.UserId]
				if targetState then
					targetState.isStunned = false
				end
			end

			local stunnedVal = stun and stun:FindFirstChild("Stunned")
			if stunnedVal and stunnedVal:IsA("BoolValue") then
				stunnedVal.Value = false
			end

			local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
			local animator = targetHumanoid and targetHumanoid:FindFirstChild("Animator")
			if animator then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					track:Stop()
				end
			end

			-- Restore WalkSpeed from saved value (stun/knockdown/grab recovery)
			if targetHumanoid and recoverySavedSpeed[targetChar] ~= nil then
				local speed = recoverySavedSpeed[targetChar]
				if speed <= 0 then speed = 16 end
				targetHumanoid.WalkSpeed = speed
			end
			recoverySavedSpeed[targetChar] = nil

			playRecoverEffect(targetChar)
		end
	end
end

----------------------------------------------------------------
-- KNOCKDOWN SYSTEM
----------------------------------------------------------------

setKnockdown = function(targetChar, value)
	if value and isTargetBlocking(targetChar) then
		return
	end

	if value then
		local kdTargetPlayer = Players:GetPlayerFromCharacter(targetChar)
		if kdTargetPlayer then
			local kdTargetState = playerState[kdTargetPlayer.UserId]
			if kdTargetState and kdTargetState.isRoaring then
				return
			end
			if kdTargetState and kdTargetState.isRaging then
				return
			end
		end
	end

	local aspects = targetChar:FindFirstChild("Aspects")
	local stun = aspects and aspects:FindFirstChild("Stun")
	local knockdown = stun and stun:FindFirstChild("Knockdown")
	if knockdown and knockdown:IsA("BoolValue") then
		knockdown.Value = value
	end

	if value then
		local existingStun = stunState[targetChar]
		if existingStun then
			if existingStun.stunnedTrack and existingStun.stunnedTrack.IsPlaying then
				existingStun.stunnedTrack:Stop()
			end
			-- Preserve saved walk speed before clearing stun state
			if existingStun.savedWalkSpeed ~= nil and not recoverySavedSpeed[targetChar] then
				recoverySavedSpeed[targetChar] = existingStun.savedWalkSpeed
			end
			stunState[targetChar] = nil
		end

		-- If no saved speed yet (no existing stun to inherit from), save from humanoid
		if not recoverySavedSpeed[targetChar] then
			local hum = targetChar:FindFirstChildOfClass("Humanoid")
			if hum then
				local speed = hum.WalkSpeed
				if speed <= 0 then speed = 16 end
				recoverySavedSpeed[targetChar] = speed
			end
		end

		local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
		local animator = targetHumanoid and targetHumanoid:FindFirstChild("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
			local animFolder = targetChar:FindFirstChild("Animations")
			if animFolder then
				local kdAnim = animFolder:FindFirstChild("KnockDown")
				if kdAnim and kdAnim:IsA("Animation") and kdAnim.AnimationId ~= "" then
					local track = animator:LoadAnimation(kdAnim)
					track.Priority = Enum.AnimationPriority.Action
					track:Play()
				end
			end
		end

		local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
		if targetPlayer then
			local targetState = playerState[targetPlayer.UserId]
			if targetState then
				targetState.isStunned = true
			end
		end
	else
		-- If the target is currently grabbed, skip full recovery — the grab system controls the target's state.
		-- This prevents delayed setKnockdown(false) calls (e.g., from LMB3) from interfering with an active grab.
		local grabbedVal = stun and stun:FindFirstChild("Grabbed")
		if grabbedVal and grabbedVal:IsA("BoolValue") and grabbedVal.Value then
			return
		end

		local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
		if targetPlayer then
			local targetState = playerState[targetPlayer.UserId]
			if targetState then
				targetState.isStunned = false
			end
		end

		local stunnedVal = stun and stun:FindFirstChild("Stunned")
		if stunnedVal and stunnedVal:IsA("BoolValue") then
			stunnedVal.Value = false
		end

		local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
		local animator = targetHumanoid and targetHumanoid:FindFirstChild("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end
		end

		-- Restore WalkSpeed from saved value (stun/knockdown/grab recovery)
		if targetHumanoid and recoverySavedSpeed[targetChar] ~= nil then
			local speed = recoverySavedSpeed[targetChar]
			if speed <= 0 then speed = 16 end
			targetHumanoid.WalkSpeed = speed
		end
		recoverySavedSpeed[targetChar] = nil

		playRecoverEffect(targetChar)
	end
end


----------------------------------------------------------------
-- DEATH / FAINT SYSTEM
----------------------------------------------------------------

local function getFaintKeyframeSequence()
	local kaijus = ReplicatedStorage:FindFirstChild("Kaijus")
	local models = kaijus and kaijus:FindFirstChild("Models")
	local titan = models and models:FindFirstChild("TitanusGodzilla")
	local default = titan and titan:FindFirstChild("TitanusGodzilla-Default")
	local animSaves = default and default:FindFirstChild("AnimSaves")
	return animSaves and animSaves:FindFirstChild("Faint")
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then return end

	local resetPlayer = Players:GetPlayerFromCharacter(character)
	if resetPlayer then
		local resetState = playerState[resetPlayer.UserId]
		if resetState then
			resetState.isRaging = false
			resetState.isRoaring = false
			resetState.isBusy = false
			resetState.isStunned = false
			resetState.isBlocking = false
			resetState.isBeaming = false
			resetState.isAttackingLMB = false
			resetState.cancelAttack = false
			resetState.attackTrack = nil
			resetState.blockTrack = nil
			resetState.savedWalkSpeed = nil
		end
		recoverySavedSpeed[character] = nil
	end

	humanoid.BreakJointsOnDeath = false

	local forceWalk = character:FindFirstChild("ForceWalk")
	if not forceWalk then
		forceWalk = Instance.new("BoolValue")
		forceWalk.Name = "ForceWalk"
		forceWalk.Value = false
		forceWalk.Parent = character
	end

	humanoid.Died:Connect(function()
		local animator = humanoid:FindFirstChild("Animator")

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Anchored = true
		end

		local deathWaveTemplate = game.Lighting:FindFirstChild("Assets")
			and game.Lighting.Assets:FindFirstChild("Effects")
			and game.Lighting.Assets.Effects:FindFirstChild("WaveEffects")
			and game.Lighting.Assets.Effects.WaveEffects:FindFirstChild("DeathWave")

		if not animator then return end

		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end

		local animationsFolder = character:FindFirstChild("Animations")
		local faintAnim = animationsFolder and animationsFolder:FindFirstChild("Faint")
		local track

		if faintAnim and faintAnim:IsA("Animation") and faintAnim.AnimationId ~= "" then
			track = animator:LoadAnimation(faintAnim)
		else
			local faintKfs = getFaintKeyframeSequence()
			if faintKfs and faintKfs:IsA("KeyframeSequence") then
				track = animator:LoadAnimation(faintKfs)
			end
		end

		if track then
			track.Priority = Enum.AnimationPriority.Action
			track.Looped = true
			track:Play()
			task.spawn(function()
				local length = track.Length
				local attempts = 0
				while length <= 0 and attempts < 60 do
					task.wait()
					length = track.Length
					attempts += 1
				end

				if length > 0 then
					local deathWaveSpawned = false
					while track.IsPlaying do
						if not deathWaveSpawned and track.TimePosition >= length - 0.5 and deathWaveTemplate and hrp then
							deathWaveSpawned = true
							local deathWaveClone = deathWaveTemplate:Clone()
							deathWaveClone.Name = "DeathWaveActive"

							for _, desc in ipairs(deathWaveClone:GetDescendants()) do
								if desc:IsA("BasePart") then
									desc.Anchored = false
									desc.CanCollide = false
									desc.Massless = true
								end
							end
							deathWaveClone.Anchored = false
							deathWaveClone.CanCollide = false
							deathWaveClone.Massless = true

							local hrpPos = hrp.Position
							deathWaveClone.CFrame = hrp.CFrame * CFrame.new(0, -28, 15)

							local weld = Instance.new("Weld")
							weld.Name = "DeathWaveWeld"
							weld.Part0 = hrp
							weld.Part1 = deathWaveClone
							weld.C0 = CFrame.new(0, -28, 15)
							weld.C1 = CFrame.new()
							weld.Parent = deathWaveClone

							deathWaveClone.Parent = character
						end
						if track.TimePosition >= length - 0.1 then
							track.Looped = false
							break
						end
						task.wait()
					end
				else
					task.wait(2)
					if deathWaveTemplate and hrp then
						local deathWaveClone = deathWaveTemplate:Clone()
						deathWaveClone.Name = "DeathWaveActive"

						for _, desc in ipairs(deathWaveClone:GetDescendants()) do
							if desc:IsA("BasePart") then
								desc.Anchored = false
								desc.CanCollide = false
								desc.Massless = true
							end
						end
						deathWaveClone.Anchored = false
						deathWaveClone.CanCollide = false
						deathWaveClone.Massless = true

						local hrpPos = hrp.Position
						deathWaveClone.CFrame = hrp.CFrame * CFrame.new(0, -28, 15)

						local weld = Instance.new("Weld")
						weld.Name = "DeathWaveWeld"
						weld.Part0 = hrp
						weld.Part1 = deathWaveClone
						weld.C0 = CFrame.new(0, -28, 15)
						weld.C1 = CFrame.new()
						weld.Parent = deathWaveClone

						deathWaveClone.Parent = character
					end
					task.wait(1)
					track.Looped = false
				end
			end)
		end
	end)
end

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------

local function init()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(onCharacterAdded)
	end)

	for _, player in Players:GetPlayers() do
		if player.Character then
			onCharacterAdded(player.Character)
		end
		player.CharacterAdded:Connect(onCharacterAdded)
	end

	Players.PlayerRemoving:Connect(function(player)
		playerState[player.UserId] = nil
		if player.Character then
			attackerComboCount[player.Character] = nil
			clashCooldowns[player.Character] = nil
			recoverySavedSpeed[player.Character] = nil
			for k, v in pairs(clashCooldowns) do
				v[player.Character] = nil
			end
		end
	end)
end

----------------------------------------------------------------
-- MODULE EXPORTS
----------------------------------------------------------------

return {
	-- Shared state
	playerState = playerState,

	-- Constants
	HITSTOP_LIGHT = HITSTOP_LIGHT,
	HITSTOP_HEAVY = HITSTOP_HEAVY,
	COMBO_RESET_TIME = COMBO_RESET_TIME,
	DAMAGE_SCALE_PER_HIT = DAMAGE_SCALE_PER_HIT,
	MIN_DAMAGE_SCALE = MIN_DAMAGE_SCALE,
	CLASH_WINDOW = CLASH_WINDOW,
	CLASH_COOLDOWN = CLASH_COOLDOWN,

	-- Data helpers
	getDamage = getDamage,
	getStun = getStun,

	-- Animation helpers
	stopTrack = stopTrack,
	playAttackAnimation = playAttackAnimation,

	-- VFX helpers
	playRecoverEffect = playRecoverEffect,
	setBlockEffects = setBlockEffects,
	applyHitstop = applyHitstop,
	applyBuildingHitEffect = applyBuildingHitEffect,

	-- Hitbox helpers
	createHitbox = createHitbox,
	weldHitbox = weldHitbox,

	-- Character detection
	getCharacterFromPart = getCharacterFromPart,
	closestPointOnPart = closestPointOnPart,
	isBuilding = isBuilding,
	isTargetBlocking = isTargetBlocking,
	isTargetRaging = isTargetRaging,

	-- Building health system (NumberValue-based)
	BuildingHealth = BuildingHealth,

	-- Core combat systems
	applyStun = applyStun,
	dealDamage = dealDamage,
	breakBlock = breakBlock,
	resolveClash = resolveClash,
	getComboCount = function(attackerChar)
		local data = attackerComboCount[attackerChar]
		return data and data.count or 0
	end,
	resetComboCount = function(attackerChar)
		attackerComboCount[attackerChar] = nil
	end,
	setGrabbed = setGrabbed,
	setKnockdown = setKnockdown,
	applyKnockback = applyKnockback,
	cancelCurrentAttack = cancelCurrentAttack,

	-- Rage system
	addRage = addRage,

	-- Initialization
	init = init,
}