-- ShowaGigan Attack System (Optimized)
-- Handles ONLY: animation playing, VFX, SFX, movement, and grab mechanics
-- All combat logic (damage, stun, knockback, block, clash) is delegated to the shared CombatSystem module

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Require the shared CombatSystem module instead of a per-kaiju CombatModule copy
local CombatSystem = require(game.ReplicatedStorage.CombatSystem)

-- Pull in the shared API (identical to old CombatModule API)
local playerState = CombatSystem.playerState
local getDamage = CombatSystem.getDamage
local getStun = CombatSystem.getStun
local stopTrack = CombatSystem.stopTrack
local playAttackAnimation = CombatSystem.playAttackAnimation
local setBlockEffects = CombatSystem.setBlockEffects
local getCharacterFromPart = CombatSystem.getCharacterFromPart
local closestPointOnPart = CombatSystem.closestPointOnPart
local dealDamage = CombatSystem.dealDamage
local setGrabbed = CombatSystem.setGrabbed
local setKnockdown = CombatSystem.setKnockdown
local applyKnockback = CombatSystem.applyKnockback
local isBuilding = CombatSystem.isBuilding
local BuildingHealth = CombatSystem.BuildingHealth
local breakBlock = CombatSystem.breakBlock
local resetComboCount = CombatSystem.resetComboCount

local HitEffectEvent = game.ReplicatedStorage:FindFirstChild("HitEffectEvent")
local AttackConfirmEvent = game.ReplicatedStorage:FindFirstChild("AttackConfirmEvent")
local AttackEndEvent = game.ReplicatedStorage:FindFirstChild("AttackEndEvent")
local HitboxDataModule = require(game.ReplicatedStorage:WaitForChild("HitboxDataModule"))

----------------------------------------------------------------
-- HITBOX DATA HELPER (manually creates hitboxes from HitboxDataModule)
----------------------------------------------------------------
local KAIJU_NAME = "ShowaGigan"

local function destroyExistingHitboxes(character)
	for _, child in ipairs(character:GetChildren()) do
		if child.Name == "HitboxHolder" then
			child:Destroy()
		end
	end
end

local function cloneHitbox(hitboxName, bodyPart, parent, c0Offset)
	local data = HitboxDataModule[KAIJU_NAME] and HitboxDataModule[KAIJU_NAME][hitboxName]
	if not data then return nil end

	local c0 = c0Offset or CFrame.new()

	-- Create holder
	local holder = Instance.new("Part")
	holder.Name = "HitboxHolder"
	holder.Size = data.holderSize
	holder.CFrame = bodyPart.CFrame * c0
	holder.Anchored = false
	holder.CanCollide = false
	holder.CanTouch = true
	holder.CanQuery = false
	holder.Massless = true
	holder.CastShadow = false
	holder.Color = Color3.new(0, 1, 0)
	holder.Transparency = 1

	-- Create hitbox child
	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = data.hitboxSize
	hitbox.CFrame = bodyPart.CFrame * c0 * data.offset
	hitbox.Anchored = false
	hitbox.CanCollide = false
	hitbox.CanTouch = true
	hitbox.CanQuery = true
	hitbox.Massless = true
	hitbox.CastShadow = false
	hitbox.Color = Color3.new(0, 1, 0)
	hitbox.Transparency = 1
	hitbox.Parent = holder

	-- Weld holder to bodyPart
	local weld = Instance.new("Weld")
	weld.Name = "HitboxWeld"
	weld.Part0 = bodyPart
	weld.Part1 = holder
	weld.C0 = c0
	weld.C1 = CFrame.new()
	weld.Parent = holder

	-- Weld hitbox to holder
	local innerWeld = Instance.new("Weld")
	innerWeld.Name = "InnerHitboxWeld"
	innerWeld.Part0 = holder
	innerWeld.Part1 = hitbox
	innerWeld.C0 = CFrame.new()
	innerWeld.C1 = data.offset:Inverse()
	innerWeld.Parent = hitbox

	holder.Parent = parent
	return hitbox
end

local function connectHitboxTouched(hitbox, handler)
	hitbox.Touched:Connect(handler)
	local holder = hitbox and hitbox.Parent
	if holder and holder:IsA("BasePart") then
		holder.Touched:Connect(handler)
	end
end

----------------------------------------------------------------
-- VFX HELPERS
----------------------------------------------------------------

local function spawnBloodGash(targetHrp)
	local gashTemplate = game.Lighting:FindFirstChild("Assets")
		and game.Lighting.Assets:FindFirstChild("Effects")
		and game.Lighting.Assets.Effects:FindFirstChild("HitEffects")
		and game.Lighting.Assets.Effects.HitEffects:FindFirstChild("Gash")
	if not gashTemplate or not targetHrp then return end
	task.spawn(function()
		local gashClone = gashTemplate:Clone()
		gashClone.CFrame = targetHrp.CFrame
		gashClone.Anchored = true
		gashClone.CanCollide = false
		gashClone.Transparency = 1
		gashClone.Parent = workspace
		if gashClone:IsA("BasePart") then
			gashClone.Color = Color3.new(0.8, 0, 0)
			gashClone.Material = Enum.Material.Neon
		end
		for _, desc in ipairs(gashClone:GetDescendants()) do
			if desc:IsA("BasePart") then
				desc.Color = Color3.new(0.8, 0, 0)
				desc.Material = Enum.Material.Neon
				desc.Transparency = 1
			elseif desc:IsA("ParticleEmitter") then
				desc.Color = ColorSequence.new(Color3.new(0.8, 0, 0))
				desc.Enabled = true
			end
		end
		local gashSound = gashClone:FindFirstChild("Gash")
		if gashSound and gashSound:IsA("Sound") then gashSound:Play() end
		task.wait(0.8)
		if gashClone and gashClone.Parent then gashClone:Destroy() end
	end)
end

local function dealBuildingIntervalDamage(targetChar, damageAmount, attackerChar, stunDuration, isHeavy, hitbox)
	if not targetChar or not isBuilding(targetChar) then return end
	task.spawn(function()
		while hitbox and hitbox.Parent and targetChar and targetChar.Parent do
			if BuildingHealth.isDead(targetChar) or BuildingHealth.isInvulnerable(targetChar) then break end
			dealDamage(targetChar, damageAmount, attackerChar, stunDuration, true, false, isHeavy)
			task.wait(0.35)
		end
	end)
end

----------------------------------------------------------------
-- HIT SOUND HELPER
----------------------------------------------------------------

local HIT_SOUND_ID = "rbxassetid://4697383191"

local function playHitSoundOnTarget(targetChar)
	if not targetChar or not targetChar.Parent then return end
	local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHrp then return end
	local sound = Instance.new("Sound")
	sound.SoundId = HIT_SOUND_ID
	sound.Volume = 6
	sound.PlaybackSpeed = 1
	sound.Looped = false
	sound.Name = "IntervalHitSound"
	sound.Parent = targetHrp
	sound:Play()
	sound.Ended:Connect(function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
	-- Safety cleanup in case Ended doesn't fire
	task.delay(1.5, function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
end

----------------------------------------------------------------
-- TRAIL HELPERS
----------------------------------------------------------------

local function isTailTrail(desc)
	if not desc:IsA("Trail") then return false end
	if desc.Name == "TailTrail" then return true end
	local parent = desc.Parent
	if parent and (string.match(parent.Name, "^t%d+$") or string.match(parent.Name, "^Tail %d+$")) then
		return true
	end
	return false
end

local function setTailTrails(character, enabled)
	for _, desc in ipairs(character:GetDescendants()) do
		if isTailTrail(desc) then
			desc.Enabled = enabled
		end
	end
end

local function setKnifeTrails(character, enabled)
	local lknife = character:FindFirstChild("LKnife")
	if lknife then
		local trail = lknife:FindFirstChild("LArmTrail")
		if trail and trail:IsA("Trail") then trail.Enabled = enabled end
	end
	local rsword = character:FindFirstChild("RSword")
	if rsword then
		local trail = rsword:FindFirstChild("RArmTrail")
		if trail and trail:IsA("Trail") then trail.Enabled = enabled end
	end
end

----------------------------------------------------------------
-- BEAM COLOR HELPERS
----------------------------------------------------------------

local function getBeamColorValues(character)
	local aspectsColors = character:FindFirstChild("Aspects")
		and character.Aspects:FindFirstChild("Colors")
		and character.Aspects.Colors:FindFirstChild("NormalColor")
	local fireColorVal = aspectsColors and aspectsColors:FindFirstChild("FireColor")
	return aspectsColors, fireColorVal
end

local function tweenBeamColorsToFire(beamColorsFolder, fireColor)
	local originalData = {}
	for _, part in ipairs(beamColorsFolder:GetChildren()) do
		if part:IsA("BasePart") then
			originalData[part] = {material = part.Material, color = part.Color}
			part.Material = Enum.Material.Neon
			local tween = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = fireColor})
			tween:Play()
			local beamCharge = part:FindFirstChild("BeamCharge")
			if beamCharge then beamCharge.Enabled = true end
		end
	end
	return originalData
end

local function restoreBeamColors(beamColorsFolder, normalColor, originalData)
	for _, part in ipairs(beamColorsFolder:GetChildren()) do
		if part:IsA("BasePart") and originalData[part] then
			local tween = TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = normalColor})
			tween:Play()
			local beamCharge = part:FindFirstChild("BeamCharge")
			if beamCharge then beamCharge.Enabled = false end
			local origMaterial = originalData[part].material
			tween.Completed:Connect(function()
				if part and part.Parent then part.Material = origMaterial end
			end)
		end
	end
end

----------------------------------------------------------------
-- TAIL PART FINDER
----------------------------------------------------------------

local function findTailParts(character)
	local tailParts = {}
	for _, desc in ipairs(character:GetDescendants()) do
		if desc:IsA("BasePart") then
			local num = string.match(desc.Name, "Tail (%d+)") or string.match(desc.Name, "^t(%d+)$")
			if num then
				table.insert(tailParts, {part = desc, num = tonumber(num)})
			end
		end
	end
	table.sort(tailParts, function(a, b) return a.num < b.num end)
	return tailParts
end

----------------------------------------------------------------
-- WALK SPEED HELPER
----------------------------------------------------------------

local function saveAndSetWalkSpeed(state, humanoid, newSpeed)
	-- Guard: only save if we don't already have a saved value
	-- This prevents overwriting the real walkspeed with 0 from a previous attack
	if state.savedWalkSpeed == nil then
		local currentSpeed = humanoid.WalkSpeed
		state.savedWalkSpeed = (currentSpeed > 0) and currentSpeed or 16
	end
	humanoid.WalkSpeed = newSpeed
end

local function restoreWalkSpeed(state, character)
	if state.savedWalkSpeed ~= nil then
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then
			if not state.isStunned then
				hum.WalkSpeed = state.savedWalkSpeed
				state.savedWalkSpeed = nil
			end
			-- If stunned, keep savedWalkSpeed for later restoration
		else
			state.savedWalkSpeed = nil
		end
	end
end

----------------------------------------------------------------
-- COMBAT CONSTANTS
----------------------------------------------------------------

local LMB_COOLDOWN = 0.4
local COMBO_WINDOW = 6

local HITBOX_DURATION = {
	LMB1 = 0.45, LMB2 = 0.45, LMB3 = 0.64,
	Roar = 0.5, Grab = 0.4, SP1 = 0.3, SP2 = 0.4, SP3 = 2,
}

-- Initialize the shared combat system
CombatSystem.init()

----------------------------------------------------------------
-- MAIN ATTACK HANDLER
----------------------------------------------------------------

script.Parent.OnServerEvent:Connect(function(player, Type)
	local character = player.Character
	if not character then return end

	local animationsFolder = character:FindFirstChild("Animations")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")

	local userId = player.UserId
	local state = playerState[userId]
	if not state then
		state = {attackTrack = nil, blockTrack = nil, comboStep = 1, lastLMBTime = 0, isBusy = false, isBlocking = false, isStunned = false, isRoaring = false, isRaging = false, savedWalkSpeed = nil, comboCooldownEnd = 0, grabCancelled = false, cancelAttack = false, isAttackingLMB = false, attackStartTime = 0, isBeaming = false, lmbAttackId = 0}
		playerState[userId] = state
	end
	state.cancelAttack = false

	-- Check stun/knockdown/grab aspects
	local aspects = character:FindFirstChild("Aspects")
	local stunFolder = aspects and aspects:FindFirstChild("Stun")
	local knockdownVal = stunFolder and stunFolder:FindFirstChild("Knockdown")
	local grabbedVal = stunFolder and stunFolder:FindFirstChild("Grabbed")
	local stunnedVal = stunFolder and stunFolder:FindFirstChild("Stunned")
	local aspectStunned = (knockdownVal and knockdownVal.Value) or (grabbedVal and grabbedVal.Value) or (stunnedVal and stunnedVal.Value)
	if state.isStunned or aspectStunned then return end

	if tick() < state.comboCooldownEnd and Type ~= "Block" and Type ~= "BlockOver" then return end

	-- Busy check: allow SP1/SP2/SP3 to cancel ongoing LMB attacks
	if state.isBusy then
		if (Type == "SP1" or Type == "SP2" or Type == "SP3") and state.isAttackingLMB then
			state.isAttackingLMB = false
			state.isBusy = false
			destroyExistingHitboxes(character)
			stopTrack(state.attackTrack)
			state.attackTrack = nil
			restoreWalkSpeed(state, character)
			setKnifeTrails(character, false)
		else
			return
		end
	end
	if state.isBlocking and Type ~= "Block" and Type ~= "BlockOver" then return end

	-- Confirm to client that the attack was accepted (for client-side cooldown validation)
	if AttackConfirmEvent and (Type == "SP1" or Type == "SP2" or Type == "SP3" or Type == "Grab" or Type == "Roar") then
		AttackConfirmEvent:FireClient(player, Type)
	end

	----------------------------------------------------------------
	-- ROAR
	----------------------------------------------------------------
	if Type == "Roar" then
		state.isBusy = true
		state.isBlocking = false
		state.isRoaring = true
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.attackTrack = nil
		state.blockTrack = nil

		saveAndSetWalkSpeed(state, humanoid, 0)

		-- SFX: roar sound
		local head = character:FindFirstChild("Head")
		local roarSound = head and head:FindFirstChild("Roar")
		if roarSound then roarSound:Play() end

		-- VFX: screen shake for attacker
		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "RoarShakeStart")
		end

		-- Animation
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Roar")
		task.wait(0.9)

		-- VFX: RoarAura (welded to FakeHead)
		local roarAuraTemplate = game.Lighting:FindFirstChild("Assets")
			and game.Lighting.Assets:FindFirstChild("Effects")
			and game.Lighting.Assets.Effects:FindFirstChild("WaveEffects")
			and game.Lighting.Assets.Effects.WaveEffects:FindFirstChild("RoarAura")
		local roarAuraClone = nil
		local fakeHead = character:FindFirstChild("FakeHead")

		if roarAuraTemplate and fakeHead then
			roarAuraClone = roarAuraTemplate:Clone()
			roarAuraClone.Name = "RoarAuraActive"
			for _, desc in ipairs(roarAuraClone:GetDescendants()) do
				if desc:IsA("BasePart") then
					desc.Anchored = false
					desc.CanCollide = false
					desc.Massless = true
					desc.CanTouch = false
				end
			end
			local mainPart = roarAuraClone:FindFirstChild("MainPart")
			if mainPart then
				local offset = mainPart.CFrame:ToObjectSpace(roarAuraClone:GetPivot())
				roarAuraClone:PivotTo(fakeHead.CFrame * offset)
				local weld = Instance.new("Weld")
				weld.Name = "RoarAuraWeld"
				weld.Part0 = fakeHead
				weld.Part1 = mainPart
				weld.C0 = fakeHead.CFrame:ToObjectSpace(mainPart.CFrame)
				weld.C1 = CFrame.new()
				weld.Parent = mainPart
			end
			roarAuraClone.Parent = character
			for _, desc in ipairs(roarAuraClone:GetDescendants()) do
				if desc:IsA("ParticleEmitter") then desc.Enabled = true end
			end
		end

		-- VFX: RoarFXPart particles
		local roarAura = character:FindFirstChild("RoarFXPart")
		if roarAura then
			for _, part in ipairs(roarAura:GetDescendants()) do
				if part:IsA("ParticleEmitter") and part.Name == "RoarFX" then
					part.Enabled = true
				end
			end
		end

		-- VFX: RoarWave (expanding wave at feet)
		local roarWaveTemplate = game.Lighting:FindFirstChild("Assets")
			and game.Lighting.Assets:FindFirstChild("Effects")
			and game.Lighting.Assets.Effects:FindFirstChild("WaveEffects")
			and game.Lighting.Assets.Effects.WaveEffects:FindFirstChild("RoarWave")
		local roarWaveClone = nil
		local roarHrp = character:FindFirstChild("HumanoidRootPart")
		if roarWaveTemplate and roarHrp then
			roarWaveClone = roarWaveTemplate:Clone()
			roarWaveClone.Name = "RoarWaveActive"

			local charVal = roarWaveClone:FindFirstChild("Char")
			if charVal and charVal:IsA("ObjectValue") then
				charVal.Value = character
			end

			roarWaveClone:PivotTo(CFrame.new(roarHrp.Position.X, roarHrp.Position.Y - 3, roarHrp.Position.Z))

			for _, desc in ipairs(roarWaveClone:GetDescendants()) do
				if desc:IsA("BasePart") then
					desc.Anchored = true
					desc.CanCollide = false
					desc.Massless = true
					desc.CanTouch = false
				end
			end
			roarWaveClone.Parent = workspace
		end

		-- Cleanup roar after duration
		task.delay(2.8, function()
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			state.isRoaring = false

			if HitEffectEvent then
				HitEffectEvent:FireClient(player, "RoarShakeEnd")
			end

			if roarAuraClone and roarAuraClone.Parent then
				for _, desc in ipairs(roarAuraClone:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then desc.Enabled = false end
				end
				roarAuraClone:Destroy()
			end
			if roarAura then
				for _, part in ipairs(roarAura:GetDescendants()) do
					if part:IsA("ParticleEmitter") then part.Enabled = false end
				end
			end
			if roarWaveClone and roarWaveClone.Parent then
				roarWaveClone:Destroy()
			end
			restoreWalkSpeed(state, character)
			task.wait(2)
			if roarSound then
				roarSound:Stop()
				roarSound.TimePosition = 0
			end
		end)

	----------------------------------------------------------------
	-- GRAB
	----------------------------------------------------------------
	elseif Type == "Grab" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.grabCancelled = false
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Grab")
		state.isBeaming = true -- Prevent hitstop from pausing animation during Grab interval damage
		if state.attackTrack then state.attackTrack.Looped = true end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local fakeHead = character:FindFirstChild("FakeHead")
		local grabbedCharacter = nil
		local grabFollowConnection = nil
		local grabHitbox = nil
		local grabEffectActive = nil
		local grabVfxStarted = false
		local beamColorsFolder = character:FindFirstChild("BeamColors")
		local aspectsColors, fireColorVal = getBeamColorValues(character)
		local normalColorVal = aspectsColors
		local beamOriginalData = {}
		local targetSavedWalkSpeed = 16

		if hrp then
			grabHitbox = cloneHitbox("Grab", hrp, character, CFrame.new(0, 0, -15))
			local grabDebounce = {}
			connectHitboxTouched(grabHitbox, function(otherPart)
				if grabbedCharacter then return end
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not grabDebounce[targetChar] and not isBuilding(targetChar) then
					grabDebounce[targetChar] = true
					grabbedCharacter = targetChar

					-- Combat: break block, deal damage, set grabbed (all delegated to CombatSystem)
					breakBlock(targetChar)
					dealDamage(targetChar, getDamage("GiganGrab_Damage"), character, getStun("GiganGrab_Stun"), true, false, true)
					setGrabbed(targetChar, true)
					task.wait(0.5)

					-- VFX: beam colors glow during grab
					if beamColorsFolder and fireColorVal then
						beamOriginalData = tweenBeamColorsToFire(beamColorsFolder, fireColorVal.Value)
					end

					-- VFX: grab effect particles on target
					local grabEffectTemplate = game.Lighting:FindFirstChild("Assets")
						and game.Lighting.Assets:FindFirstChild("Effects")
						and game.Lighting.Assets.Effects:FindFirstChild("AttackEffects")
						and game.Lighting.Assets.Effects.AttackEffects:FindFirstChild("ShowaGigan")
						and game.Lighting.Assets.Effects.AttackEffects.ShowaGigan:FindFirstChild("Grab")
					if grabEffectTemplate then
						task.spawn(function()
							local grabbedHrp = grabbedCharacter and grabbedCharacter:FindFirstChild("HumanoidRootPart")
							if not grabbedHrp then return end

							local effect = grabEffectTemplate:Clone()
							effect.Name = "GrabEffectActive"
							local particleHolder = effect:FindFirstChild("ParticleHolder")
							local basePart = effect:FindFirstChild("Base")

							for _, part in ipairs({particleHolder, basePart}) do
								if part and part:IsA("BasePart") then
									part.CFrame = grabbedHrp.CFrame
								end
							end

							for _, desc in ipairs(effect:GetDescendants()) do
								if desc:IsA("BasePart") then
									desc.Anchored = false
									desc.CanCollide = false
									desc.Massless = true
									desc.CanTouch = false
								end
							end

							for _, part in ipairs({particleHolder, basePart}) do
								if part and part:IsA("BasePart") then
									local weld = Instance.new("Weld")
									weld.Part0 = grabbedHrp
									weld.Part1 = part
									weld.C0 = grabbedHrp.CFrame:ToObjectSpace(part.CFrame)
									weld.C1 = CFrame.new()
									weld.Parent = part
								end
							end

							effect.Parent = workspace
							for _, desc in ipairs(effect:GetDescendants()) do
								if desc:IsA("ParticleEmitter") then desc.Enabled = false end
							end
							grabEffectActive = effect

							task.delay(2.0, function()
								if grabEffectActive and grabEffectActive.Parent and not grabVfxStarted then
									grabVfxStarted = true
									for _, desc in ipairs(grabEffectActive:GetDescendants()) do
										if desc:IsA("ParticleEmitter") then desc.Enabled = true end
									end
								end
							end)
						end)
					end

					-- Movement: make grabbed target follow FakeHead
					local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
					local followTarget = fakeHead or hrp
					if targetHrp then
						local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
						if targetHum then
							targetSavedWalkSpeed = targetHum.WalkSpeed
							targetHum.WalkSpeed = 0
						end
						targetHrp.Anchored = true
						targetHrp.CFrame = followTarget.CFrame * CFrame.new(0, 0, -15) * CFrame.Angles(0, math.rad(180), 0)
						grabFollowConnection = RunService.Heartbeat:Connect(function()
							if grabbedCharacter and grabbedCharacter.Parent and followTarget and followTarget.Parent then
								local tHrp = grabbedCharacter:FindFirstChild("HumanoidRootPart")
								if tHrp then tHrp.CFrame = followTarget.CFrame * CFrame.new(0, 0, -15) * CFrame.Angles(0, math.rad(180), 0) end
							else
								if grabFollowConnection then grabFollowConnection:Disconnect() end
							end
						end)
					end
					if grabHitbox and grabHitbox.Parent then grabHitbox.Parent:Destroy() end

					-- Interval damage during hold: starts 0.2s after grab, deals damage every 0.1s for 1 second
					task.delay(0.2, function()
						if not grabbedCharacter or not grabbedCharacter.Parent then return end
						if state.grabCancelled then return end
						task.spawn(function()
							local elapsed = 0
							while elapsed < 1.0 and grabbedCharacter and grabbedCharacter.Parent and not state.grabCancelled do
								local targetHum = grabbedCharacter:FindFirstChildOfClass("Humanoid")
								if not targetHum or targetHum.Health <= 0 then break end
								dealDamage(grabbedCharacter, getDamage("GiganGrab_Damage"), character, getStun("GiganGrab_Stun"), true, false, false)
								playHitSoundOnTarget(grabbedCharacter)
								local head = character:FindFirstChild("Head")
								if head then
									local attackSound = head:FindFirstChild("AttackSound")
									if attackSound and attackSound:IsA("Sound") then
										attackSound.TimePosition = 0
										attackSound:Play()
									end
								end
								task.wait(0.1)
								elapsed += 0.1
							end
						end)
					end)
				end
			end)
		end

		-- If no target grabbed within 0.4s, cancel
		task.delay(0.4, function()
			if not grabbedCharacter and not state.grabCancelled then
				state.grabCancelled = true
				state.isBusy = false
				if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
				state.isBeaming = false
				stopTrack(state.attackTrack)
				state.attackTrack = nil
				if grabHitbox and grabHitbox.Parent then grabHitbox.Parent:Destroy() end
			end
		end)

		-- Grab end: throw the target
		local function onGrabEnd()
			if state.grabCancelled then return end
			state.grabCancelled = true
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			stopTrack(state.attackTrack)
			state.attackTrack = nil
			state.isBeaming = false
			resetComboCount(character)
			if grabFollowConnection then grabFollowConnection:Disconnect(); grabFollowConnection = nil end
			if grabHitbox and grabHitbox.Parent then grabHitbox.Parent:Destroy() end

			-- Combat: knockdown, ungrab, throw damage, knockback (all delegated to CombatSystem)
			if grabbedCharacter and grabbedCharacter.Parent then
				local targetHrp = grabbedCharacter:FindFirstChild("HumanoidRootPart")
				setKnockdown(grabbedCharacter, true)
				setGrabbed(grabbedCharacter, false)
				if targetHrp then targetHrp.Anchored = false end
				local targetHum = grabbedCharacter:FindFirstChildOfClass("Humanoid")
				if targetHum then targetHum.WalkSpeed = targetSavedWalkSpeed end
				dealDamage(grabbedCharacter, getDamage("GiganGrabThrow_Damage"), character, getStun("GiganGrabThrow_Stun"), true, false, true)
				if targetHrp and targetHrp.Parent and hrp and hrp.Parent then
					applyKnockback(grabbedCharacter, hrp, 50, 10)
				end
				local throwStunDuration = getStun("GiganGrabThrow_Stun")
				task.delay(4, function()
					if grabbedCharacter and grabbedCharacter.Parent then
						local kdAspects = grabbedCharacter:FindFirstChild("Aspects")
						local kdStunFolder = kdAspects and kdAspects:FindFirstChild("Stun")
						if kdStunFolder then
							local kdVal = kdStunFolder:FindFirstChild("Knockdown")
							-- If knockdown was already cleared by another attack (e.g., LMB3),
							-- the target has already recovered - skip throw stun to prevent double stun
							if kdVal and kdVal:IsA("BoolValue") and not kdVal.Value then
								return
							end
							if kdVal and kdVal:IsA("BoolValue") then
								kdVal.Value = false
							end
						end
						CombatSystem.applyStun(grabbedCharacter, character, throwStunDuration)
					end
				end)
			end

			-- VFX: grab effect cleanup
			if grabEffectActive and grabEffectActive.Parent then
				if not grabVfxStarted then
					grabVfxStarted = true
					for _, desc in ipairs(grabEffectActive:GetDescendants()) do
						if desc:IsA("ParticleEmitter") then desc.Enabled = true end
					end
				end
				task.delay(0.6, function()
					if grabEffectActive and grabEffectActive.Parent then
						for _, desc in ipairs(grabEffectActive:GetDescendants()) do
							if desc:IsA("ParticleEmitter") then desc.Enabled = false end
						end
						task.delay(0.5, function()
							if grabEffectActive and grabEffectActive.Parent then
								grabEffectActive:Destroy()
							end
						end)
					end
					if beamColorsFolder and normalColorVal then
						restoreBeamColors(beamColorsFolder, normalColorVal.Value, beamOriginalData)
					end
				end)
			end
		end

		local grabEnded = false
		local function safeOnGrabEnd()
			if grabEnded then return end
			grabEnded = true
			onGrabEnd()
		end
		if state.attackTrack then
			state.attackTrack.Ended:Connect(safeOnGrabEnd)
		end
		task.delay(2.5, safeOnGrabEnd)

	----------------------------------------------------------------
	-- SP1 (Special Attack 1 - Eye Beam)
	----------------------------------------------------------------
	elseif Type == "SP1" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP1")

		-- SFX (delayed to match animation timing)
		task.delay(0.8, function()
			if script.Parent and script.Parent.Parent and script.Parent.Parent.Parent then
				local sp1Head = script.Parent.Parent.Parent:FindFirstChild("Head")
				if sp1Head and sp1Head.Parent then
					local sp1Sound = sp1Head:FindFirstChild("SP1")
					if sp1Sound and sp1Sound:IsA("Sound") then
						sp1Sound:Play()
					end
				end
			end
		end)

		saveAndSetWalkSpeed(state, humanoid, 0)

		local hrp = character:FindFirstChild("HumanoidRootPart")

		-- VFX: Spawn Beam effect in front of Gigan's eye
		local beamTemplate = game.ReplicatedStorage:FindFirstChild("Assets")
			and game.ReplicatedStorage.Assets:FindFirstChild("Kaijus")
			and game.ReplicatedStorage.Assets.Kaijus:FindFirstChild("Effects")
			and game.ReplicatedStorage.Assets.Kaijus.Effects:FindFirstChild("AttackEffects")
			and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects:FindFirstChild("Gigan")
			and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects.Gigan:FindFirstChild("Beam")
		local beamClone = nil
		if beamTemplate then
			task.spawn(function()
				task.wait(0.8)
				beamClone = beamTemplate:Clone()
				beamClone.Name = "BeamActive"

				local tweenScript = beamClone:FindFirstChild("TweenScript")
				if tweenScript then
					local charVal = tweenScript:FindFirstChild("Char")
					if charVal and charVal:IsA("ObjectValue") then
						charVal.Value = character
					end
					local cfVal = tweenScript:FindFirstChild("CFrame")
					if cfVal and cfVal:IsA("ObjectValue") then
						cfVal.Value = hrp
					end
				end

				local eye = character:FindFirstChild("Eye")
				if eye and eye.Parent and hrp and hrp.Parent then
					local beamPos = eye.Position + hrp.CFrame.LookVector * 5
					beamClone.CFrame = CFrame.lookAt(beamPos, eye.Position)
				elseif hrp and hrp.Parent then
					beamClone.CFrame = hrp.CFrame * CFrame.new(0, 5, -10)
				end

				for _, desc in ipairs(beamClone:GetDescendants()) do
					if desc:IsA("BasePart") then
						desc.Anchored = true
						desc.CanCollide = false
						desc.Massless = true
						desc.CanTouch = false
					end
				end
				beamClone.Anchored = true
				beamClone.CanCollide = false
				beamClone.Massless = true
				beamClone.CanTouch = false

				beamClone.Parent = workspace

				for _, desc in ipairs(beamClone:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then
						desc.Enabled = true
					end
				end

				task.delay(0.5, function()
					if beamClone and beamClone.Parent then
						for _, desc in ipairs(beamClone:GetDescendants()) do
							if desc:IsA("ParticleEmitter") then
								desc.Enabled = false
							end
						end
						task.delay(0.3, function()
							if beamClone and beamClone.Parent then
								beamClone:Destroy()
							end
						end)
					end
				end)
			end)
		end

		-- Hitbox + combat (delegated to CombatSystem)
		task.delay(0.2, function()
			if not character or not character.Parent then return end
			local sp1Hitbox = nil
			if hrp and hrp.Parent then
				sp1Hitbox = cloneHitbox("SP1", hrp, character, CFrame.new(0, 0, -8))
				local sp1Debounce = {}
				connectHitboxTouched(sp1Hitbox, function(otherPart)
					local targetChar = getCharacterFromPart(otherPart)
					if targetChar and targetChar ~= character and not sp1Debounce[targetChar] then
						sp1Debounce[targetChar] = true
						if isBuilding(targetChar) then
							dealBuildingIntervalDamage(targetChar, getDamage("GiganSpecial1_Damage"), character, getStun("GiganSpecial1_Stun"), true, sp1Hitbox)
							return
						end
						dealDamage(targetChar, getDamage("GiganSpecial1_Damage"), character, getStun("GiganSpecial1_Stun"), false, true, true)
						spawnBloodGash(targetChar:FindFirstChild("HumanoidRootPart"))
					end
				end)
			end
			task.delay(0.25, function()
				state.isBusy = false
				if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
				if sp1Hitbox and sp1Hitbox.Parent then sp1Hitbox.Parent:Destroy() end
				restoreWalkSpeed(state, character)
			end)
		end)

	----------------------------------------------------------------
	-- SP2 (Special Attack 2 - Buzzsaw)
	----------------------------------------------------------------
	elseif Type == "SP2" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP2")
		state.isBeaming = true -- Prevent hitstop from pausing animation during SP2 interval damage
		if state.attackTrack then state.attackTrack.Looped = true end

		-- SFX
		script.Parent.Parent.Parent.Head.SP2:Play()

		-- VFX: enable tail trails
		setTailTrails(character, true)

		saveAndSetWalkSpeed(state, humanoid, 0)

		local hrp = character:FindFirstChild("HumanoidRootPart")

		-- VFX: Spawn Saw effect on Gigan's body
		local sawTemplate = game.ReplicatedStorage:FindFirstChild("Assets")
			and game.ReplicatedStorage.Assets:FindFirstChild("Kaijus")
			and game.ReplicatedStorage.Assets.Kaijus:FindFirstChild("Effects")
			and game.ReplicatedStorage.Assets.Kaijus.Effects:FindFirstChild("AttackEffects")
			and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects:FindFirstChild("Gigan")
			and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects.Gigan:FindFirstChild("Saw")
		local sawClone = nil
		if sawTemplate then
			task.spawn(function()
				task.wait(0.4)
				sawClone = sawTemplate:Clone()
				sawClone.Name = "SawActive"

				local tweenScript = sawClone:FindFirstChild("TweenScript")
				if tweenScript then
					local charVal = tweenScript:FindFirstChild("Char")
					if charVal and charVal:IsA("ObjectValue") then
						charVal.Value = character
					end
					local cfVal = tweenScript:FindFirstChild("CFrame")
					if cfVal and cfVal:IsA("ObjectValue") then
						cfVal.Value = hrp
					end
				end

				local sawSpot = character:FindFirstChild("SawSpot")
				if sawSpot and sawSpot.Parent and hrp and hrp.Parent then
					sawClone:PivotTo(sawSpot.CFrame * CFrame.new(0, -2, 2))
				elseif sawSpot and sawSpot.Parent then
					sawClone:PivotTo(sawSpot.CFrame * CFrame.new(0, -2, 2))
				elseif hrp and hrp.Parent then
					sawClone:PivotTo(hrp.CFrame * CFrame.new(0, 0, 2))
				end

				for _, desc in ipairs(sawClone:GetDescendants()) do
					if desc:IsA("BasePart") then
						desc.Anchored = true
						desc.CanCollide = false
						desc.Massless = true
						desc.CanTouch = false
					end
				end

				sawClone.Parent = workspace

				for _, desc in ipairs(sawClone:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then
						desc.Enabled = true
					end
				end
			end)
		end

		-- Movement: forward teleport
		if hrp then
			task.spawn(function()
				for i = 1, 6 do
					if hrp and hrp.Parent then
						hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -1.5)
					end
					task.wait(0.06)
				end
				if hrp and hrp.Parent then
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end
			end)
		end

		-- Hitbox: constant interval damage for 3.9 seconds
		destroyExistingHitboxes(character)
		local sp2Hitbox = nil
		local sp2Targets = {}
		if hrp then
			sp2Hitbox = cloneHitbox("SP2", hrp, character, CFrame.new(0, 0, -8))
			connectHitboxTouched(sp2Hitbox, function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character then
					sp2Targets[targetChar] = true
				end
			end)
		end

		-- Interval damage loop: deals damage every 0.1s for 3.9 seconds
		task.spawn(function()
			local elapsed = 0
			while elapsed < 3.9 and character and character.Parent do
				for targetChar in pairs(sp2Targets) do
					if targetChar and targetChar.Parent then
						local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
						if targetHum and targetHum.Health > 0 then
							if isBuilding(targetChar) then
								dealDamage(targetChar, getDamage("GiganSpecial2_Damage"), character, getStun("GiganSpecial2_Stun"), true, false, false)
							else
								dealDamage(targetChar, getDamage("GiganSpecial2_Damage"), character, getStun("GiganSpecial2_Stun"), false, false, false)
								-- Teleport target in front of Gigan constantly
								local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
								if targetHrp and targetHrp.Parent and hrp and hrp.Parent then
									local frontPos = hrp.CFrame * CFrame.new(0, 0, -20)
									targetHrp.CFrame = CFrame.lookAt(frontPos.Position, hrp.Position)
									targetHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
									targetHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
								end
							end
								playHitSoundOnTarget(targetChar)
						else
							sp2Targets[targetChar] = nil
						end
					else
						sp2Targets[targetChar] = nil
					end
				end
				local head = character:FindFirstChild("Head")
				if head then
					local attackSound = head:FindFirstChild("AttackSound")
					if attackSound and attackSound:IsA("Sound") then
						attackSound.TimePosition = 0
						attackSound:Play()
					end
				end
				task.wait(0.1)
				elapsed += 0.1
			end
		end)

		local sp2Ended = false
		local function onSP2End()
			if sp2Ended then return end
			sp2Ended = true
			stopTrack(state.attackTrack)
			state.attackTrack = nil
			state.isBeaming = false
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			if hrp and hrp.Parent then
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
			if sp2Hitbox and sp2Hitbox.Parent then sp2Hitbox.Parent:Destroy() end
			if sawClone and sawClone.Parent then
				for _, desc in ipairs(sawClone:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then
						desc.Enabled = false
					end
				end
				task.delay(0.5, function()
					if sawClone and sawClone.Parent then
						sawClone:Destroy()
					end
				end)
			end
			setTailTrails(character, false)
			restoreWalkSpeed(state, character)
			resetComboCount(character)
		end

		task.delay(3.9, onSP2End)

	----------------------------------------------------------------
	-- SP3 (Special Attack 3 - Swords Slam)
	----------------------------------------------------------------
	elseif Type == "SP3" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP3")

		-- SFX
		script.Parent.Parent.Parent.Head.SP3:Play()

		saveAndSetWalkSpeed(state, humanoid, 0)

		local hrp = character:FindFirstChild("HumanoidRootPart")

		-- Movement: forward dash
		if hrp then
			task.spawn(function()
				for i = 1, 3 do
					if hrp and hrp.Parent then
						hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -1.5)
					end
					task.wait(0.05)
				end
			end)
		end

		-- Hitbox + VFX + combat (delegated to CombatSystem)
		task.delay(0.2, function()
			if not character or not character.Parent then return end
			local sp3Hitbox = nil
			if hrp and hrp.Parent then
				sp3Hitbox = cloneHitbox("SP3", hrp, character, CFrame.new(0, 0, -8))

				-- VFX: Spawn SwordsSlam crater effect
				local slamTemplate = game.ReplicatedStorage:FindFirstChild("Assets")
					and game.ReplicatedStorage.Assets:FindFirstChild("Kaijus")
					and game.ReplicatedStorage.Assets.Kaijus:FindFirstChild("Effects")
					and game.ReplicatedStorage.Assets.Kaijus.Effects:FindFirstChild("AttackEffects")
					and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects:FindFirstChild("Gigan")
					and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects.Gigan:FindFirstChild("SwordsSlam")
				if slamTemplate then
					local slamClone = slamTemplate:Clone()
					slamClone.Name = "SwordsSlamActive"

					local tweenScript = slamClone:FindFirstChild("TweenScript")
					if tweenScript then
						local charVal = tweenScript:FindFirstChild("Char")
						if charVal and charVal:IsA("ObjectValue") then
							charVal.Value = character
						end
						local cfVal = tweenScript:FindFirstChild("CFrame")
						if cfVal and cfVal:IsA("ObjectValue") then
							cfVal.Value = hrp
						end
					end

					slamClone:PivotTo(hrp.CFrame * CFrame.new(0, -22, -40))

					for _, desc in ipairs(slamClone:GetDescendants()) do
						if desc:IsA("BasePart") then
							desc.Anchored = true
							desc.CanCollide = false
							desc.Massless = true
							desc.CanTouch = false
						end
					end

					slamClone.Parent = workspace

					task.delay(0.15, function()
						if slamClone and slamClone.Parent then
							for _, desc in ipairs(slamClone:GetDescendants()) do
								if desc:IsA("ParticleEmitter") then
									desc.Enabled = false
								end
							end
						end
					end)

					task.delay(10, function()
						if slamClone and slamClone.Parent then
							slamClone:Destroy()
						end
					end)
				end

				local sp3Debounce = {}
				connectHitboxTouched(sp3Hitbox, function(otherPart)
					local targetChar = getCharacterFromPart(otherPart)
					if targetChar and targetChar ~= character and not sp3Debounce[targetChar] then
						sp3Debounce[targetChar] = true
						task.delay(0.3, function()
							if not targetChar or not targetChar.Parent then return end
							if isBuilding(targetChar) then
								dealDamage(targetChar, getDamage("GiganSpecial3_Damage"), character, getStun("GiganSpecial3_Stun"), true, false, true)
								return
							end
							dealDamage(targetChar, getDamage("GiganSpecial3_Damage"), character, getStun("GiganSpecial3_Stun"), false, true, true)
							spawnBloodGash(targetChar:FindFirstChild("HumanoidRootPart"))
							setKnockdown(targetChar, true)
							task.delay(2, function() setKnockdown(targetChar, false) end)
							local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
							if targetHrp and hrp and hrp.Parent then
								applyKnockback(targetChar, hrp, 80, 35)
							end
						end)
					end
				end)
			end
			task.delay(0.25, function()
				state.isBusy = false
				if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
				if sp3Hitbox and sp3Hitbox.Parent then sp3Hitbox.Parent:Destroy() end
				restoreWalkSpeed(state, character)
			end)
		end)

	----------------------------------------------------------------
	-- ESCAPE
	----------------------------------------------------------------
	elseif Type == "Escape" then
		stopTrack(state.attackTrack)
		state.attackTrack = nil
		-- SFX
		script.Parent.Parent.Parent.HumanoidRootPart.Escape:Play()

	----------------------------------------------------------------
	-- BLOCK
	----------------------------------------------------------------
	elseif Type == "Block" then
		if state.isBlocking then
			stopTrack(state.blockTrack)
			state.blockTrack = nil
			state.isBlocking = false
			setBlockEffects(character, false)
			-- SFX
			script.Parent.Parent.Parent.HumanoidRootPart.Block:Play()
			local forceWalk = character:FindFirstChild("ForceWalk")
			if forceWalk then forceWalk.Value = false end
			local aspects = character:FindFirstChild("Aspects")
			local defense = aspects and aspects:FindFirstChild("Defense")
			local blockingVal = defense and defense:FindFirstChild("Blocking")
			if blockingVal and blockingVal:IsA("BoolValue") then
				blockingVal.Value = false
			end
		else
			stopTrack(state.attackTrack)
			state.attackTrack = nil
			state.isBlocking = true
			state.blockTrack = playAttackAnimation(animationsFolder, animator, "Block")
			setBlockEffects(character, true)
			-- SFX
			script.Parent.Parent.Parent.HumanoidRootPart.Block:Play()
			local forceWalk = character:FindFirstChild("ForceWalk")
			if forceWalk then forceWalk.Value = true end
			local aspects = character:FindFirstChild("Aspects")
			local defense = aspects and aspects:FindFirstChild("Defense")
			local blockingVal = defense and defense:FindFirstChild("Blocking")
			if blockingVal and blockingVal:IsA("BoolValue") then
				blockingVal.Value = true
			end
		end

	----------------------------------------------------------------
	-- BLOCK OVER (release block)
	----------------------------------------------------------------
	elseif Type == "BlockOver" then
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.isBlocking = false
		setBlockEffects(character, false)
		-- SFX
		script.Parent.Parent.Parent.HumanoidRootPart.Block:Play()
		local forceWalk = character:FindFirstChild("ForceWalk")
		if forceWalk then forceWalk.Value = false end
		local aspects = character:FindFirstChild("Aspects")
		local defense = aspects and aspects:FindFirstChild("Defense")
		local blockingVal = defense and defense:FindFirstChild("Blocking")
		if blockingVal and blockingVal:IsA("BoolValue") then
			blockingVal.Value = false
		end

	----------------------------------------------------------------
	-- RAGE (Ultimate)
	----------------------------------------------------------------
	elseif Type == "Rage" then
		-- Server-side validation: only allow when rage is full
		local rageAspects = character:FindFirstChild("Aspects")
		local rageInfo = rageAspects and rageAspects:FindFirstChild("Info")
		local rageValue = rageInfo and rageInfo:FindFirstChild("Rage")
		local maxRageValue = rageValue and rageValue:FindFirstChild("MaxRage")
		if not rageValue or not maxRageValue then return end
		if rageValue.Value < maxRageValue.Value then return end

		state.isBusy = true
		state.isBlocking = false
		state.isRaging = true
		character:SetAttribute("RageActive", true)
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil

		rageValue.Value = 0

		-- VFX: Disable CanTouch on body parts (invulnerability)
		local function disableCanTouchExceptHitboxes(char)
			for _, desc in ipairs(char:GetDescendants()) do
				if desc:IsA("BasePart") then
					local name = desc.Name
					if name ~= "Hitbox" and name ~= "HitboxHolder" and name ~= "BeamHitbox" then
						desc.CanTouch = false
					end
				end
			end
		end

		local function restoreCanTouch(char)
			for _, desc in ipairs(char:GetDescendants()) do
				if desc:IsA("BasePart") then
					local name = desc.Name
					if name ~= "Hitbox" and name ~= "HitboxHolder" and name ~= "BeamHitbox" and name ~= "RoarWaveActive" and name ~= "RoarAuraActive" and name ~= "GrabEffectActive" then
						desc.CanTouch = true
					end
				end
			end
		end

		disableCanTouchExceptHitboxes(character)

		-- Animation: rage charge (looping, sped up)
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Rage")
		if state.attackTrack then
			state.attackTrack.Looped = true
			state.attackTrack:AdjustSpeed(1.5)
		end

		task.wait(0.4)
		if not character or not character.Parent or not state.isRaging then return end

		-- Movement: high walk speed for free movement
		saveAndSetWalkSpeed(state, humanoid, 90)
		local hrp = character:FindFirstChild("HumanoidRootPart")

		-- === RAGE VISUAL EFFECTS ===
		local rageEffects = {}

		-- VFX: Enable weapon trails
		setKnifeTrails(character, true)

		-- VFX: Force neon blade color during rage
		local rageBladeAspects = character:FindFirstChild("Aspects")
		local rageBladeColors = rageBladeAspects and rageBladeAspects:FindFirstChild("Colors")
		local rageBladeNormalColor = rageBladeColors and rageBladeColors:FindFirstChild("NormalColor")
		local rageBladeColorVal = rageBladeNormalColor and rageBladeNormalColor:FindFirstChild("BladeColor")
		local lKnife = character:FindFirstChild("LKnife")
		local rSword = character:FindFirstChild("RSword")
		if rageBladeColorVal then
			local bladeColor = rageBladeColorVal.Value
			if lKnife then
				lKnife.Color = bladeColor
				lKnife.Material = Enum.Material.Neon
			end
			if rSword then
				rSword.Color = bladeColor
				rSword.Material = Enum.Material.Neon
			end
		end

		-- VFX: Clone UltSwords visual effects and weld to weapons
		local ultSwordsTemplate = game.Lighting.Assets.Effects.AttackEffects.ShowaGigan:FindFirstChild("UltSwords")
		if ultSwordsTemplate then
			local function setupSwordClone(template, targetPart)
				if not template or not targetPart then return nil end
				local clone = template:Clone()
				for _, desc in ipairs(clone:GetDescendants()) do
					if desc:IsA("WeldConstraint") then
						desc.Parent = nil
					end
				end
				for _, desc in ipairs(clone:GetDescendants()) do
					if desc:IsA("BasePart") then
						desc.CanCollide = false
						desc.CanTouch = false
						desc.Anchored = false
						desc.Massless = true
					elseif desc:IsA("Trail") then
						local parentPart = desc.Parent
						if parentPart then
							local att0, att1
							for _, child in ipairs(parentPart:GetChildren()) do
								if child:IsA("Attachment") then
									if not att0 then
										att0 = child
									else
											att1 = child
									end
								end
							end
							if att0 then desc.Attachment0 = att0 end
							if att1 then desc.Attachment1 = att1 end
							desc.Enabled = true
						end
					end
				end
				clone:PivotTo(targetPart.CFrame)
				for _, desc in ipairs(clone:GetDescendants()) do
					if desc:IsA("BasePart") then
						local weld = Instance.new("WeldConstraint")
						weld.Part0 = desc
						weld.Part1 = targetPart
						weld.Parent = desc
					end
				end
				clone.Parent = character
				return clone
			end

			local leftClone = setupSwordClone(ultSwordsTemplate:FindFirstChild("Left"), lKnife)
			if leftClone then table.insert(rageEffects, leftClone) end
			local rightClone = setupSwordClone(ultSwordsTemplate:FindFirstChild("Right"), rSword)
			if rightClone then table.insert(rageEffects, rightClone) end
		end

		-- VFX: Animate expanding ULT waves around character
		local ultTemplate = game.Lighting.Assets.Effects.AttackEffects.ShowaGigan:FindFirstChild("ULT")
		if ultTemplate then
			task.spawn(function()
				while state.isRaging and character and character.Parent do
					if hrp and hrp.Parent then
						for _, child in ipairs(ultTemplate:GetChildren()) do
							if child:IsA("BasePart") and (child.Name == "Circle" or child.Name == "Red") then
								local wave = child:Clone()
								for _, v in ipairs(wave:GetChildren()) do
									v.Parent = nil
								end
								wave.Anchored = true
								wave.CanCollide = false
								wave.CanTouch = false
								wave.CanQuery = false
								wave.CastShadow = false
								wave.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
								wave.Transparency = 0.6
								wave.Parent = character

								local speedVal = child:FindFirstChild("Speed")
								local delayVal = child:FindFirstChild("Delay")
								local speed = (speedVal and speedVal.Value > 0) and speedVal.Value or 0.5
								local delayTime = delayVal and delayVal.Value or 0

								task.delay(delayTime, function()
									local endSize = wave.Size * 2.5
									local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
									local tween = TweenService:Create(wave, tweenInfo, {
										Size = endSize,
										Transparency = 1,
									})
									tween:Play()
									tween.Completed:Connect(function()
										if wave.Parent then wave.Parent = nil end
									end)
								end)
							end
						end
					end
					task.wait(1.2)
				end
			end)
		end

		-- Hitbox: character-sized rage hitbox
		local rageHitbox = nil
		local rageTargets = {}
		if hrp then
			local bbCFrame, bbSize = character:GetBoundingBox()
			rageHitbox = Instance.new("Part")
			rageHitbox.Name = "Hitbox"
			rageHitbox.Size = bbSize
			rageHitbox.CFrame = hrp.CFrame
			rageHitbox.Color = Color3.new(1, 0, 0)
			rageHitbox.Transparency = 1
			rageHitbox.Anchored = false
			rageHitbox.CanCollide = false
			rageHitbox.Massless = true
			rageHitbox.CanTouch = true
			rageHitbox.CanQuery = false
			rageHitbox.CastShadow = false
			rageHitbox.Parent = character

			local offset = hrp.CFrame:ToObjectSpace(bbCFrame)
			local weld = Instance.new("Weld")
			weld.Name = "RageHitboxWeld"
			weld.Part0 = hrp
			weld.Part1 = rageHitbox
			weld.C0 = offset
			weld.C1 = CFrame.new()
			weld.Parent = rageHitbox

			rageHitbox.Touched:Connect(function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character then
					rageTargets[targetChar] = true
				end
			end)
		end

		-- Interval damage loop: deals damage every 0.3s for 5 seconds, scaled by target size
		task.spawn(function()
			local elapsed = 0
			while elapsed < 5 and character and character.Parent and state.isRaging do
				for targetChar in pairs(rageTargets) do
					if targetChar and targetChar.Parent then
						local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
						if targetHum and targetHum.Health > 0 then
							local _, targetSize = targetChar:GetBoundingBox()
							local sizeScale = math.clamp(targetSize.Y / 5, 0.5, 3)
							local baseDmg = getDamage("GiganRage_Damage")
							local scaledDmg = baseDmg * sizeScale
							if isBuilding(targetChar) then
								dealDamage(targetChar, scaledDmg, character, getStun("GiganRage_Stun"), true, false, false)
							else
								dealDamage(targetChar, scaledDmg, character, getStun("GiganRage_Stun"), false, false, false)
							end
								playHitSoundOnTarget(targetChar)
						else
							rageTargets[targetChar] = nil
						end
					else
						rageTargets[targetChar] = nil
					end
				end
				local head = character:FindFirstChild("Head")
				if head then
					local attackSound = head:FindFirstChild("AttackSound")
					if attackSound and attackSound:IsA("Sound") then
						attackSound.TimePosition = 0
						attackSound:Play()
					end
				end
				task.wait(0.3)
				elapsed += 0.3
			end
		end)

		-- Cleanup after 5 seconds
		task.delay(5, function()
			if not character or not character.Parent then return end
			if state.isRaging then
				state.isRaging = false
				character:SetAttribute("RageActive", false)
				stopTrack(state.attackTrack)
				state.attackTrack = nil
				state.isBusy = false
				if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
				resetComboCount(character)
				if rageHitbox and rageHitbox.Parent then rageHitbox:Destroy() end
				restoreCanTouch(character)
				setKnifeTrails(character, false)

				-- Restore knife/sword colors and material
				local restoreAspects = character:FindFirstChild("Aspects")
				local restoreColors = restoreAspects and restoreAspects:FindFirstChild("Colors")
				local restoreNormalColor = restoreColors and restoreColors:FindFirstChild("NormalColor")
				if restoreNormalColor then
					if lKnife then
						lKnife.Color = restoreNormalColor.Value
						lKnife.Material = Enum.Material.Metal
					end
					if rSword then
						rSword.Color = restoreNormalColor.Value
						rSword.Material = Enum.Material.Metal
					end
				end

				-- Destroy rage visual effects
				for _, effect in ipairs(rageEffects) do
					if effect and effect.Parent then
						effect.Parent = nil
					end
				end
				restoreWalkSpeed(state, character)
			end
		end)

	----------------------------------------------------------------
	-- LMB (Light Attack Combo)
	----------------------------------------------------------------
	elseif Type == "LMB" then
		local now = tick()

		if (now - state.lastLMBTime) < LMB_COOLDOWN then return end
		if now < state.comboCooldownEnd then return end

		if (now - state.lastLMBTime) > COMBO_WINDOW then
			state.comboStep = 1
		end

		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.blockTrack)
		state.blockTrack = nil

		saveAndSetWalkSpeed(state, humanoid, 0)

		local animName = "LMB" .. state.comboStep
		state.attackTrack = playAttackAnimation(animationsFolder, animator, animName)

		-- Track LMB attack timing for clash resolution
		state.isAttackingLMB = true
		state.attackStartTime = tick()

		-- VFX: trails
		if state.comboStep == 1 or state.comboStep == 2 then
			setKnifeTrails(character, true)
		end
		if state.comboStep == 3 then
			setTailTrails(character, true)
			task.delay(1.2, function() setTailTrails(character, false) end)
		end

		-- Movement: forward teleport
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			task.spawn(function()
				for i = 1, 5 do
					if hrp and hrp.Parent then
						hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -2.0)
					end
					task.wait(0.05)
				end
			end)
		end

		-- Hitbox
		destroyExistingHitboxes(character)
		state.lmbAttackId += 1
		local myAttackId = state.lmbAttackId
		local lmbHitbox = nil
		if hrp then
			if state.comboStep == 3 then
				local tailParts = findTailParts(character)
				local lmb3BodyPart = hrp
				if #tailParts >= 2 then
					lmb3BodyPart = tailParts[2].part
				elseif #tailParts >= 1 then
					lmb3BodyPart = tailParts[1].part
				end
				lmbHitbox = cloneHitbox("Light3", lmb3BodyPart, character)
			else
				lmbHitbox = cloneHitbox("Light" .. state.comboStep, hrp, character, CFrame.new(0, 0, -8))
			end
			local lmbDebounce = {}
			connectHitboxTouched(lmbHitbox, function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not lmbDebounce[targetChar] then
					lmbDebounce[targetChar] = true
					local dmgKey = "GiganLight" .. state.comboStep .. "_Damage"
					local stunKey = "GiganLight" .. state.comboStep .. "_Stun"
					local isHeavy = (animName == "LMB3")
					if isBuilding(targetChar) then
						dealBuildingIntervalDamage(targetChar, getDamage(dmgKey), character, getStun(stunKey), isHeavy, lmbHitbox)
						return
					end
					local shouldLookAt = (animName == "LMB3")
					if animName == "LMB3" then
						breakBlock(targetChar)
					end
					dealDamage(targetChar, getDamage(dmgKey), character, getStun(stunKey), false, shouldLookAt, isHeavy)

					local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
					if targetHrp and hrp and hrp.Parent then
						if animName == "LMB3" then
							applyKnockback(targetChar, hrp, 80, 35)
						else
							applyKnockback(targetChar, hrp, 35, 12)
						end
					end

					if animName == "LMB1" or animName == "LMB2" then
						spawnBloodGash(targetHrp)
					end

					if animName == "LMB3" then
						setKnockdown(targetChar, true)
						task.delay(1, function() setKnockdown(targetChar, false) end)
						local head = character:FindFirstChild("Head")
						if head then
							local heavySound = head:FindFirstChild("Heavy")
							if heavySound and heavySound:IsA("Sound") then heavySound:Play() end
						end
					end
				end
			end)
		end

		-- Hitbox duration timer
		local hitboxDuration = HITBOX_DURATION[animName] or 0.3
		task.delay(hitboxDuration, function()
			if state.lmbAttackId ~= myAttackId then return end
			if not state.isAttackingLMB then return end
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			state.isAttackingLMB = false
			if lmbHitbox and lmbHitbox.Parent then lmbHitbox.Parent:Destroy() end
			restoreWalkSpeed(state, character)
		end)

		-- SFX: attack sound + trail cleanup
		local head = character:FindFirstChild("Head")
		if head then
			local attackSound = head:FindFirstChild("AttackSound")
			if attackSound and attackSound:IsA("Sound") then
				local clone = attackSound:Clone()
				clone.Parent = head
				clone:Play()
				clone.Ended:Connect(function()
					clone:Destroy()
					if animName == "LMB1" or animName == "LMB2" then
						setKnifeTrails(character, false)
					end
				end)
			end
		end

		state.comboStep = (state.comboStep % 3) + 1
		state.lastLMBTime = now

		if animName == "LMB3" then
			state.comboCooldownEnd = now + 3
		end
	end
end)