-- TitanusGodzilla Attack System (Optimized)
-- Handles ONLY: animation playing, VFX, SFX, movement, and grab/dash mechanics
-- All combat logic (damage, stun, knockback, block, clash, grab, rage) is delegated to the shared CombatSystem module

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
local isTargetBlocking = CombatSystem.isTargetBlocking

local HitEffectEvent = game.ReplicatedStorage:FindFirstChild("HitEffectEvent")
local AttackConfirmEvent = game.ReplicatedStorage:FindFirstChild("AttackConfirmEvent")
local AttackEndEvent = game.ReplicatedStorage:FindFirstChild("AttackEndEvent")

----------------------------------------------------------------
-- HITBOX DATA HELPER (manually creates hitboxes from HitboxDataModule)
----------------------------------------------------------------
local HitboxDataModule = require(game.ReplicatedStorage:WaitForChild("HitboxDataModule"))
local KAIJU_NAME = "TitanusGodzilla"

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
	holder.CanTouch = false
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

----------------------------------------------------------------
-- VFX HELPERS
----------------------------------------------------------------

-- Blood gash effect (red slash on hit)
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

-- Interval damage for buildings (delegates to CombatSystem.dealDamage)
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

local function setArmTrails(character, enabled)
	local leftArm = character:FindFirstChild("Left Arm")
	if leftArm then
		local trail = leftArm:FindFirstChild("LArmTrail")
		if trail and trail:IsA("Trail") then trail.Enabled = enabled end
	end
	local rightArm = character:FindFirstChild("Right Arm")
	if rightArm then
		local trail = rightArm:FindFirstChild("RArmTrail")
		if trail and trail:IsA("Trail") then trail.Enabled = enabled end
	end
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
-- BURNING STATE (HP < 400): activates orange fire visuals
-- Unique to TitanusGodzilla
----------------------------------------------------------------
local BURNING_HP_THRESHOLD = 400
local burningState = {} -- [character] = stored original data

local function activateBurning(character)
	if burningState[character] then return end

	local ect = character:FindFirstChild("ECT")
	local burningColors = ect and ect:FindFirstChild("BurningColors")

	local state = {parts = {}, beamLights = {}, burningLights = {}, particles = {}}

	-- 1. Enable fire particles in BurningColors.Flames
	if burningColors then
		local flames = burningColors:FindFirstChild("Flames")
		if flames then
			for _, desc in ipairs(flames:GetDescendants()) do
				if desc:IsA("ParticleEmitter") then
					state.particles[desc] = desc.Enabled
					desc.Enabled = true
				end
				end
			end

		-- 2. Enable orange lights in BurningColors.Light
		local burningLight = burningColors:FindFirstChild("Light")
		if burningLight then
			for _, desc in ipairs(burningLight:GetDescendants()) do
				if desc:IsA("Light") then
					state.burningLights[desc] = desc.Brightness
					desc.Brightness = 10
				end
				end
			end
	end

	-- 3. Show all burning parts in ECT.BurningColors
	if burningColors then
		for _, part in ipairs(burningColors:GetDescendants()) do
			if part:IsA("BasePart") and (string.find(string.lower(part.Name), "burning") or string.find(string.lower(part.Name), "therm")) then
				state.parts[part] = {transparency = part.Transparency, material = part.Material}
				part.Material = Enum.Material.Neon
				local tween = TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0})
				tween:Play()
			end
			end
		end

	burningState[character] = state
end

local function deactivateBurning(character)
	local state = burningState[character]
	if not state then return end

	for emitter, wasEnabled in pairs(state.particles) do
		if emitter and emitter.Parent then emitter.Enabled = wasEnabled end
	end

	for light, origBrightness in pairs(state.burningLights) do
		if light and light.Parent then light.Brightness = origBrightness end
	end

	for part, data in pairs(state.parts) do
		if part and part.Parent then
			local tween = TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = data.transparency})
			tween:Play()
			local origMaterial = data.material
			tween.Completed:Connect(function()
				if part and part.Parent then part.Material = origMaterial end
			end)
		end
	end

	burningState[character] = nil
end

local function setupHealthMonitoring(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local isBurning = false

	local function checkHealth()
		if not humanoid or not humanoid.Parent then return end
		if humanoid.Health < BURNING_HP_THRESHOLD and humanoid.Health > 0 and not isBurning then
			isBurning = true
			activateBurning(character)
		elseif humanoid.Health >= BURNING_HP_THRESHOLD and isBurning then
			isBurning = false
			deactivateBurning(character)
		end
	end

	checkHealth()
	humanoid.HealthChanged:Connect(checkHealth)

	humanoid.Died:Connect(function()
		activateBurning(character)
	end)
end

local function onPlayerAddedForBurning(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		setupHealthMonitoring(character)
	end)
	player.CharacterRemoving:Connect(function(character)
		burningState[character] = nil
	end)
	if player.Character then
		task.spawn(function()
			task.wait(0.5)
			setupHealthMonitoring(player.Character)
		end)
	end
end

Players.PlayerAdded:Connect(onPlayerAddedForBurning)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAddedForBurning(player)
end

----------------------------------------------------------------
-- COMBAT CONSTANTS
----------------------------------------------------------------

local LMB_COOLDOWN = 0.4
local COMBO_WINDOW = 6

local HITBOX_DURATION = {
	LMB1 = 0.5, LMB2 = 0.5, LMB3 = 0.6,
	Roar = 0.5, Grab = 0.4, SP1 = 0.3, SP2 = 0.4, SP3 = 2, Ultimate = 4,
}

-- Initialize the shared combat system
CombatSystem.init()

----------------------------------------------------------------
-- MAIN ATTACK HANDLER (OnServerEvent)
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
		state = {attackTrack = nil, blockTrack = nil, comboStep = 1, lastLMBTime = 0, isBusy = false, isBlocking = false, isStunned = false, isRoaring = false, savedWalkSpeed = nil, comboCooldownEnd = 0, grabCancelled = false, cancelAttack = false, isAttackingLMB = false, attackStartTime = 0, isBeaming = false, lmbAttackId = 0}
		playerState[userId] = state
	end
	state.cancelAttack = false

	local aspects = character:FindFirstChild("Aspects")
	local stunFolder = aspects and aspects:FindFirstChild("Stun")
	local knockdownVal = stunFolder and stunFolder:FindFirstChild("Knockdown")
	local grabbedVal = stunFolder and stunFolder:FindFirstChild("Grabbed")
	local stunnedVal = stunFolder and stunFolder:FindFirstChild("Stunned")
	local aspectStunned = (knockdownVal and knockdownVal.Value) or (grabbedVal and grabbedVal.Value) or (stunnedVal and stunnedVal.Value)
	if state.isStunned or aspectStunned then return end
	if tick() < state.comboCooldownEnd and Type ~= "Block" and Type ~= "BlockOver" then return end
	if state.isBusy then
		-- Allow special attacks (SP1/SP2/SP3) to cancel ongoing LMB attacks
		if (Type == "SP1" or Type == "SP2" or Type == "SP3" or Type == "Ultimate" or Type == "Rage") and state.isAttackingLMB then
			state.isAttackingLMB = false
			state.isBusy = false
			destroyExistingHitboxes(character)
			stopTrack(state.attackTrack)
			state.attackTrack = nil
			restoreWalkSpeed(state, character)
			setArmTrails(character, false)
			setTailTrails(character, false)
		else
			return
		end
	end
	if state.isBlocking and Type ~= "Block" and Type ~= "BlockOver" then return end

	-- Confirm to client that the attack was accepted (for client-side cooldown validation)
	if AttackConfirmEvent and (Type == "SP1" or Type == "SP2" or Type == "SP3" or Type == "Grab" or Type == "Roar") then
		AttackConfirmEvent:FireClient(player, Type)
	end

	if Type == "Roar" then
		state.isBusy = true
		state.isBlocking = false
		state.isRoaring = true
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.attackTrack = nil
		state.blockTrack = nil

		saveAndSetWalkSpeed(state, humanoid, 0)
		local head = character:FindFirstChild("Head")
		local roarSound = head and head:FindFirstChild("Roar")
		if roarSound then roarSound:Play() end

		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "RoarShakeStart")
		end

		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Roar")
		task.wait(0.9)

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

		local roarAura = character:FindFirstChild("RoarFXPart")
		if roarAura then
			for _, part in ipairs(roarAura:GetDescendants()) do
				if part:IsA("ParticleEmitter") and part.Name == "RoarFX" then
					part.Enabled = true
				end
			end
		end

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

		task.delay(3.8, function()
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
			if character and character:FindFirstChildOfClass("Humanoid") and not state.isStunned then
				restoreWalkSpeed(state, character)
			end
			task.wait(2)
			if roarSound then
				roarSound:Stop()
				roarSound.TimePosition = 0
			end
		end)

	elseif Type == "Grab" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.grabCancelled = false
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Grab")

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local fakeHead = character:FindFirstChild("FakeHead")
		local grabbedCharacter = nil
		local grabFollowConnection = nil
		local grabHitbox = nil
		local targetSavedWalkSpeed = 16

		if hrp then
			grabHitbox = cloneHitbox("Grab", hrp, character)
			local grabDebounce = {}
			grabHitbox.Touched:Connect(function(otherPart)
				if grabbedCharacter then return end
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not grabDebounce[targetChar] and not isBuilding(targetChar) then
					grabDebounce[targetChar] = true
					grabbedCharacter = targetChar
					breakBlock(targetChar)
					dealDamage(targetChar, getDamage("TitanusGrab_Damage"), character, getStun("TitanusGrab_Stun"), true, false, true)
					setGrabbed(targetChar, true)

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
				end
			end)
		end

		task.delay(0.4, function()
			if not grabbedCharacter and not state.grabCancelled then
				state.grabCancelled = true
				state.isBusy = false
				if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
				stopTrack(state.attackTrack)
				state.attackTrack = nil
				if grabHitbox and grabHitbox.Parent then grabHitbox.Parent:Destroy() end
			end
		end)

		local function onGrabEnd()
			if state.grabCancelled then return end
			state.grabCancelled = true
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			state.attackTrack = nil
			if grabFollowConnection then grabFollowConnection:Disconnect(); grabFollowConnection = nil end
			if grabHitbox and grabHitbox.Parent then grabHitbox.Parent:Destroy() end
			if grabbedCharacter and grabbedCharacter.Parent then
				local targetHrp = grabbedCharacter:FindFirstChild("HumanoidRootPart")
				setKnockdown(grabbedCharacter, true)
				setGrabbed(grabbedCharacter, false)
				if targetHrp then targetHrp.Anchored = false end
				local targetHum = grabbedCharacter:FindFirstChildOfClass("Humanoid")
				if targetHum then targetHum.WalkSpeed = targetSavedWalkSpeed end
				dealDamage(grabbedCharacter, getDamage("TitanusGrabThrow_Damage"), character, getStun("TitanusGrabThrow_Stun"), true, false, true)
				if targetHrp and targetHrp.Parent and hrp and hrp.Parent then
					applyKnockback(grabbedCharacter, hrp, 50, 10)
				end

				local throwStunDuration = getStun("TitanusGrabThrow_Stun")
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

	elseif Type == "SP1" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP1")
		if state.attackTrack then state.attackTrack:AdjustSpeed(1.6) end
		script.Parent.Parent.Parent.Head.SP1:Play()

		local SP1_SPEED = 85
		local SP1_START_DELAY = 0.5
		local SP1_DURATION = 2.0

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local sp1GrabbedChar = nil
		local sp1FollowConnection = nil
		local sp1Hitbox = nil
		local sp1GrabbedCollisions = {}
		if hrp then
			sp1Hitbox = cloneHitbox("SP1", hrp, character)
			local sp1Debounce = {}
			sp1Hitbox.Touched:Connect(function(otherPart)
				if sp1GrabbedChar then return end
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not sp1Debounce[targetChar] then
					if isBuilding(targetChar) then
						sp1Debounce[targetChar] = true
						dealBuildingIntervalDamage(targetChar, getDamage("TitanusSpecial1_Damage"), character, getStun("TitanusSpecial1_Stun"), false, sp1Hitbox)
						return
					end
					if isTargetBlocking(targetChar) then
						sp1Debounce[targetChar] = true
						local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
						if targetHrp then
							local blockedSound = targetHrp:FindFirstChild("Blocked")
							if blockedSound and blockedSound:IsA("Sound") then
								blockedSound:Play()
							end
						end
						return
					end
					sp1Debounce[targetChar] = true
					sp1GrabbedChar = targetChar
					dealDamage(targetChar, getDamage("TitanusSpecial1_Damage"), character, getStun("TitanusSpecial1_Stun"), false, false, true)
					setGrabbed(targetChar, true)
					local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
					if targetHrp then
						local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
						if targetHum then targetHum.WalkSpeed = 0 end
						targetHrp.Anchored = true
						for _, part in ipairs(sp1GrabbedChar:GetDescendants()) do
							if part:IsA("BasePart") then
								sp1GrabbedCollisions[part] = part.CanCollide
								part.CanCollide = false
							end
						end
						targetHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						targetHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
						local lookDir = hrp.CFrame.LookVector
						local flatLook = Vector3.new(lookDir.X, 0, lookDir.Z)
						if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
						local flatHrp = CFrame.new(hrp.Position, hrp.Position + flatLook)
						targetHrp.CFrame = flatHrp * CFrame.new(0, 0, -10) * CFrame.Angles(0, math.rad(180), 0)
						sp1FollowConnection = RunService.Heartbeat:Connect(function()
							if sp1GrabbedChar and sp1GrabbedChar.Parent and hrp and hrp.Parent then
								local tHrp = sp1GrabbedChar:FindFirstChild("HumanoidRootPart")
									if tHrp then
										local hbLookDir = hrp.CFrame.LookVector
										local hbFlatLook = Vector3.new(hbLookDir.X, 0, hbLookDir.Z)
										if hbFlatLook.Magnitude > 0 then hbFlatLook = hbFlatLook.Unit end
										local hbFlatHrp = CFrame.new(hrp.Position, hrp.Position + hbFlatLook)
										tHrp.CFrame = hbFlatHrp * CFrame.new(0, 0, -10) * CFrame.Angles(0, math.rad(180), 0)
									end
							else
								if sp1FollowConnection then sp1FollowConnection:Disconnect() end
							end
						end)
					end
					task.spawn(function()
						while sp1GrabbedChar and sp1GrabbedChar.Parent
							and sp1Hitbox and sp1Hitbox.Parent do
							task.wait(1.4)
							if not sp1GrabbedChar or not sp1GrabbedChar.Parent then break end
							if not sp1Hitbox or not sp1Hitbox.Parent then break end
							local grabbedHum = sp1GrabbedChar:FindFirstChildOfClass("Humanoid")
							if grabbedHum and grabbedHum.Health > 0 then
								dealDamage(sp1GrabbedChar, getDamage("TitanusSpecial1_Damage"), character, getStun("TitanusSpecial1_Stun"), false, false, true)
							end
							sp1Hitbox.Transparency = 1
						end
					end)
				end
			end)
		end

		if hrp and humanoid then
			local originalWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0

			task.delay(SP1_START_DELAY, function()
				if not character or not hrp or not hrp.Parent then return end

				local dashDirection = hrp.CFrame.LookVector
				dashDirection = Vector3.new(dashDirection.X, 0, dashDirection.Z)
				if dashDirection.Magnitude > 0 then
					dashDirection = dashDirection.Unit
				end

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {character}
				if sp1GrabbedChar and sp1GrabbedChar.Parent then
					table.insert(rayParams.FilterDescendantsInstances, sp1GrabbedChar)
				end
				rayParams.FilterType = Enum.RaycastFilterType.Exclude

				local function raycastGroundIgnoreTransparent(origin, downwardDistance, params)
					local currentOrigin = origin
					local remaining = downwardDistance
					for _ = 1, 10 do
						local hit = workspace:Raycast(currentOrigin, Vector3.new(0, -remaining, 0), params)
						if not hit then return nil end
						if hit.Instance.Transparency == 0 then return hit end
						local traveled = (hit.Position - currentOrigin).Magnitude
						remaining = remaining - traveled - 0.5
						if remaining <= 0 then return nil end
						currentOrigin = hit.Position - Vector3.new(0, 0.5, 0)
					end
					return nil
				end

				local groundOffset = 3.5
				local startGround = raycastGroundIgnoreTransparent(hrp.Position, 100, rayParams)
				if startGround then
					groundOffset = hrp.Position.Y - startGround.Position.Y
				end

				hrp.Anchored = true

				local function endDash()
					if sp1Hitbox and sp1Hitbox.Parent then sp1Hitbox.Parent:Destroy() end
					if sp1FollowConnection then sp1FollowConnection:Disconnect(); sp1FollowConnection = nil end
					if sp1GrabbedChar and sp1GrabbedChar.Parent then
						local targetHrp = sp1GrabbedChar:FindFirstChild("HumanoidRootPart")
						setKnockdown(sp1GrabbedChar, true)
						setGrabbed(sp1GrabbedChar, false)
						for part, wasCollidable in pairs(sp1GrabbedCollisions) do
							if part and part.Parent then
								part.CanCollide = wasCollidable
							end
						end
						sp1GrabbedCollisions = {}
						if targetHrp then targetHrp.Anchored = false end
						local targetHum = sp1GrabbedChar:FindFirstChildOfClass("Humanoid")
						if targetHum then targetHum.WalkSpeed = 16 end
						if targetHrp and targetHrp.Parent and hrp and hrp.Parent then
							applyKnockback(sp1GrabbedChar, hrp, 50, 50)
						end
						task.delay(2, function()
							if sp1GrabbedChar and sp1GrabbedChar.Parent then
								setKnockdown(sp1GrabbedChar, false)
							end
						end)
					end
					if hrp and hrp.Parent then
						-- Final ground check: snap to ground BEFORE unanchoring to prevent clipping
						local finalRayParams = RaycastParams.new()
						finalRayParams.FilterDescendantsInstances = {character}
						if sp1GrabbedChar and sp1GrabbedChar.Parent then
							table.insert(finalRayParams.FilterDescendantsInstances, sp1GrabbedChar)
						end
						finalRayParams.FilterType = Enum.RaycastFilterType.Exclude
						local finalGroundHit = raycastGroundIgnoreTransparent(Vector3.new(hrp.Position.X, hrp.Position.Y + 50, hrp.Position.Z), 200, finalRayParams)
						if finalGroundHit then
							local safeY = finalGroundHit.Position.Y + groundOffset
							if safeY > hrp.Position.Y then
								hrp.CFrame = CFrame.new(hrp.Position.X, safeY, hrp.Position.Z) * (hrp.CFrame - hrp.Position)
							end
						end
						hrp.Anchored = false
						hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
					state.isBusy = false
					if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
					if character and character:FindFirstChildOfClass("Humanoid") then
						character:FindFirstChildOfClass("Humanoid").WalkSpeed = originalWalkSpeed
					end
				end

				local elapsed = 0
				local MAX_Y_DELTA_PER_FRAME = 10
				local connection
				connection = RunService.Heartbeat:Connect(function(dt)
					elapsed += dt
					if elapsed >= SP1_DURATION then
						connection:Disconnect()
						endDash()
						return
					end
					if hrp and hrp.Parent then
						local frameFilter = {character}
						if sp1GrabbedChar and sp1GrabbedChar.Parent then
							table.insert(frameFilter, sp1GrabbedChar)
						end
						rayParams.FilterDescendantsInstances = frameFilter
						local moveStep = dashDirection * SP1_SPEED * dt
						local currentPos = hrp.Position
						local newX = currentPos.X + moveStep.X
						local newZ = currentPos.Z + moveStep.Z
						local groundHit = raycastGroundIgnoreTransparent(Vector3.new(newX, currentPos.Y + 50, newZ), 100, rayParams)
						local newY = currentPos.Y
						if groundHit then
							local targetY = groundHit.Position.Y + groundOffset
							local yDelta = targetY - currentPos.Y
							if yDelta < -MAX_Y_DELTA_PER_FRAME then
								targetY = currentPos.Y - MAX_Y_DELTA_PER_FRAME
							end
							newY = targetY
						end
					hrp.CFrame = CFrame.new(newX, newY, newZ) * (hrp.CFrame - currentPos)
					end
				end)
			end)
		end

	elseif Type == "SP2" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP2")
		script.Parent.Parent.Parent.Head.SP2:Play()

		local head = character:FindFirstChild("Head")
		if head then
			local heavySound = head:FindFirstChild("Heavy")
			if heavySound and heavySound:IsA("Sound") then heavySound:Play() end
		end

		saveAndSetWalkSpeed(state, humanoid, 0)

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			task.spawn(function()
				local startCFrame = hrp.CFrame
				local targetCFrame = startCFrame * CFrame.Angles(0, math.rad(-85), 0)
				local duration = 0.5
				local elapsed = 0
				local connection
				connection = RunService.Heartbeat:Connect(function(dt)
					elapsed += dt
					if elapsed >= duration or not hrp or not hrp.Parent then
						connection:Disconnect()
						if hrp and hrp.Parent then hrp.CFrame = targetCFrame end
						return
					end
					local alpha = elapsed / duration
					local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
					hrp.CFrame = startCFrame:Lerp(targetCFrame, smoothAlpha)
				end)
			end)
		end

		setTailTrails(character, true)

		destroyExistingHitboxes(character)
		local sp2Hitbox = nil
		if hrp then
			sp2Hitbox = cloneHitbox("SP2", hrp, character)
			local sp2Debounce = {}
			sp2Hitbox.Touched:Connect(function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not sp2Debounce[targetChar] then
					sp2Debounce[targetChar] = true
					if isBuilding(targetChar) then
						dealBuildingIntervalDamage(targetChar, getDamage("TitanusSpecial2_Damage"), character, getStun("TitanusSpecial2_Stun"), true, sp2Hitbox)
						return
					end
					dealDamage(targetChar, getDamage("TitanusSpecial2_Damage"), character, getStun("TitanusSpecial2_Stun"), false, true, true)
					applyKnockback(targetChar, character:FindFirstChild("HumanoidRootPart"), 150, 60)
					setKnockdown(targetChar, true)
					task.delay(1.5, function() setKnockdown(targetChar, false) end)
					task.delay(1, function() sp2Debounce[targetChar] = nil end)
				end
			end)
		end

		local function onSP2End()
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			if sp2Hitbox and sp2Hitbox.Parent then sp2Hitbox.Parent:Destroy() end
			setTailTrails(character, false)
			if character and character:FindFirstChildOfClass("Humanoid") and not state.isStunned then
				restoreWalkSpeed(state, character)
			end
		end

		task.delay(1.2, function()
			if state.attackTrack then
				stopTrack(state.attackTrack)
			end
		end)

		if state.attackTrack then
			state.attackTrack.Ended:Connect(onSP2End)
		else
			task.delay(1.9, onSP2End)
		end

	elseif Type == "SP3" then
		local isBurning = humanoid.Health < BURNING_HP_THRESHOLD

		if isBurning then
			-- PULSE ATTACK (when burning is enabled)
			state.isBusy = true
			state.isBlocking = false
			stopTrack(state.attackTrack)
			stopTrack(state.blockTrack)
			state.attackTrack = nil
			state.blockTrack = nil

			saveAndSetWalkSpeed(state, humanoid, 0)

			local ect = character:FindFirstChild("ECT")
			local dorsalFins = {}
			local dorsalOriginalData = {}
			local chargeParticles = {}

			if ect then
				for _, desc in ipairs(ect:GetDescendants()) do
					if desc:IsA("BasePart") and string.find(string.lower(desc.Name), "dorsal") then
						table.insert(dorsalFins, desc)
						dorsalOriginalData[desc] = {material = desc.Material, transparency = desc.Transparency, color = desc.Color}
					end
				end
			end

			local beamColors = character:FindFirstChild("BeamColors")
			if beamColors then
				for _, desc in ipairs(beamColors:GetDescendants()) do
					if desc:IsA("BasePart") and string.find(string.lower(desc.Name), "dorsal") then
						table.insert(dorsalFins, desc)
						dorsalOriginalData[desc] = {material = desc.Material, transparency = desc.Transparency, color = desc.Color}
					end
				end
			end

			for _, fin in ipairs(dorsalFins) do
				fin.Material = Enum.Material.Neon
				local glowTween = TweenService:Create(fin, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0, Color = Color3.new(0, 1, 1)})
				glowTween:Play()
				local particle = Instance.new("ParticleEmitter")
				particle.Name = "PulseChargeParticle"
				particle.Color = ColorSequence.new(Color3.new(0, 1, 1), Color3.new(0, 0.5, 1))
				particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 2), NumberSequenceKeypoint.new(1, 0)})
				particle.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1)})
				particle.Lifetime = NumberRange.new(0.3, 0.8)
				particle.Rate = 40
				particle.Speed = NumberRange.new(2, 5)
				particle.SpreadAngle = Vector2.new(30, 30)
				particle.EmissionDirection = Enum.NormalId.Top
				particle.LightEmission = 1
				particle.LightInfluence = 0
				particle.Parent = fin
				table.insert(chargeParticles, particle)
				local finLight = Instance.new("PointLight")
				finLight.Name = "PulseChargeLight"
				finLight.Color = Color3.new(0, 1, 1)
				finLight.Brightness = 0
				finLight.Range = 8
				finLight.Parent = fin
				local lightTween = TweenService:Create(finLight, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 5})
				lightTween:Play()
			end

			if HitEffectEvent then
				HitEffectEvent:FireClient(player, "RoarShakeStart")
			end

			task.wait(3)

			for _, particle in ipairs(chargeParticles) do
				if particle and particle.Parent then particle:Destroy() end
			end
			for _, fin in ipairs(dorsalFins) do
				if fin and fin.Parent then
					local chargeLight = fin:FindFirstChild("PulseChargeLight")
					if chargeLight then chargeLight:Destroy() end
				end
			end
			for _, fin in ipairs(dorsalFins) do
				if fin and fin.Parent then
					fin.Color = Color3.new(1, 1, 1)
					fin.Transparency = 0
				end
			end

			local head = character:FindFirstChild("Head")
			if head then
				local heavySound = head:FindFirstChild("Heavy")
				if heavySound and heavySound:IsA("Sound") then heavySound:Play() end
			end

			local pulseTemplate = game.ReplicatedStorage:FindFirstChild("Assets")
				and game.ReplicatedStorage.Assets:FindFirstChild("Kaijus")
				and game.ReplicatedStorage.Assets.Kaijus:FindFirstChild("Effects")
				and game.ReplicatedStorage.Assets.Kaijus.Effects:FindFirstChild("AttackEffects")
				and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects:FindFirstChild("TitanusGodzilla")
				and game.ReplicatedStorage.Assets.Kaijus.Effects.AttackEffects.TitanusGodzilla:FindFirstChild("Pulse")
			local pulseClone = nil
			local hrp = character:FindFirstChild("HumanoidRootPart")

			if pulseTemplate and hrp then
				pulseClone = pulseTemplate:Clone()
				pulseClone.Name = "PulseActive"
				local tweenFolder = pulseClone:FindFirstChild("TweenScript")
				if tweenFolder then
					local charVal = tweenFolder:FindFirstChild("Char")
					if charVal and charVal:IsA("ObjectValue") then charVal.Value = character end
					local cfVal = tweenFolder:FindFirstChild("CFrame")
					if cfVal and cfVal:IsA("CFrameValue") then cfVal.Value = hrp.CFrame end
				end
				pulseClone:PivotTo(CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z))
				for _, desc in ipairs(pulseClone:GetDescendants()) do
					if desc:IsA("BasePart") then
						desc.Anchored = true
						desc.CanCollide = false
						desc.Massless = true
						desc.CanTouch = false
					end
				end
				pulseClone.Parent = workspace
			end

			local PULSE_RADIUS = 150
			local PULSE_DAMAGE = 200
			local pulseDebounce = {}

			if hrp then
				local pulseHitbox = Instance.new("Part")
				pulseHitbox.Name = "PulseHitbox"
				pulseHitbox.Shape = Enum.PartType.Ball
				pulseHitbox.Size = Vector3.new(10, 10, 10)
				pulseHitbox.CFrame = hrp.CFrame
				pulseHitbox.Anchored = true
				pulseHitbox.CanCollide = false
				pulseHitbox.Massless = true
				pulseHitbox.CastShadow = false
				pulseHitbox.Material = Enum.Material.Neon
				pulseHitbox.Color = Color3.new(0, 1, 1)
				pulseHitbox.Transparency = 0.5
				pulseHitbox.Parent = workspace

				local expandTween = TweenService:Create(pulseHitbox, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(PULSE_RADIUS * 2, PULSE_RADIUS * 2, PULSE_RADIUS * 2), Transparency = 1})
				expandTween:Play()
				expandTween.Completed:Connect(function()
					if pulseHitbox and pulseHitbox.Parent then pulseHitbox:Destroy() end
				end)

				for _, targetChar in ipairs(workspace:GetChildren()) do
					if targetChar ~= character then
						local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
						local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
						if targetHrp and targetHum and targetHum.Health > 0 and not pulseDebounce[targetChar] then
							local dist = (targetHrp.Position - hrp.Position).Magnitude
							if dist <= PULSE_RADIUS then
								pulseDebounce[targetChar] = true
								if isBuilding(targetChar) then
									dealDamage(targetChar, PULSE_DAMAGE * 2, character, 3, true, false, true)
								else
									dealDamage(targetChar, PULSE_DAMAGE, character, 3, false, true, true)
									applyKnockback(targetChar, hrp, 200, 80)
									setKnockdown(targetChar, true)
									task.delay(3, function() setKnockdown(targetChar, false) end)
								end
							end
						end
					end
				end
			end

			task.delay(1.5, function()
				state.isBusy = false
				if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
				if HitEffectEvent then
					HitEffectEvent:FireClient(player, "RoarShakeEnd")
				end
				for fin, data in pairs(dorsalOriginalData) do
					if fin and fin.Parent then
						local tween = TweenService:Create(fin, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = data.transparency, Color = data.color})
						tween:Play()
						tween.Completed:Connect(function()
							if fin and fin.Parent then fin.Material = data.material end
						end)
					end
				end
				if character and character:FindFirstChildOfClass("Humanoid") and not state.isStunned then
					restoreWalkSpeed(state, character)
				end
			end)
		else
			-- BEAM ATTACK (when burning is NOT enabled)
			state.isBusy = true
			state.isBlocking = false
			state.isBeaming = true
			stopTrack(state.attackTrack)
			stopTrack(state.blockTrack)
			state.blockTrack = nil

			local forceWalk = character:FindFirstChild("ForceWalk")
			if forceWalk then forceWalk.Value = true end

			saveAndSetWalkSpeed(state, humanoid, 15)

			state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP3")

			local AttachStart = character:FindFirstChild("AttachStart")
			local Charge = AttachStart and AttachStart:FindFirstChild("BeamCharge")
			local BeamFire = AttachStart and AttachStart:FindFirstChild("BeamFire")
			if Charge and Charge:IsA("Sound") then Charge:Play() end

			local fakeHead = character:FindFirstChild("FakeHead")
			local bloodEmitter = fakeHead and fakeHead:FindFirstChild("Blood")
			if bloodEmitter and bloodEmitter:IsA("ParticleEmitter") then bloodEmitter.Enabled = true end

			local beamColorsFolder = character:FindFirstChild("BeamColors")
			local beamOriginalData = {}

			if beamColorsFolder then
				for _, part in ipairs(beamColorsFolder:GetDescendants()) do
					if part:IsA("BasePart") and string.find(string.lower(part.Name), "blue") then
						beamOriginalData[part] = {material = part.Material, transparency = part.Transparency}
						part.Material = Enum.Material.Neon
						local transTween = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0})
						transTween:Play()
					end
				end
				local lightModel = beamColorsFolder:FindFirstChild("Light")
				if lightModel then
					for _, desc in ipairs(lightModel:GetDescendants()) do
						if desc:IsA("Light") then
							beamOriginalData[desc] = {enabled = desc.Enabled, brightness = desc.Brightness}
							desc.Brightness = 10
							desc.Enabled = true
						end
					end
				end
			end

			task.wait(1.4)
			if BeamFire and BeamFire:IsA("Sound") then BeamFire:Play() end

			if HitEffectEvent then
				HitEffectEvent:FireClient(player, "BeamShakeStart")
			end

			if AttachStart then
				for _, beam in ipairs(AttachStart:GetDescendants()) do
					if beam:IsA("Beam") then beam.Enabled = true end
				end
				local trail = AttachStart:FindFirstChild("Trail")
				if trail and trail:IsA("Trail") then trail.Enabled = false end
			end

			local beamHitbox = character:FindFirstChild("BeamHitbox")
			local sp3Targets = {}
			local sp3Active = true

			if beamHitbox then
				beamHitbox.CanTouch = true
				beamHitbox.Transparency = 1
				beamHitbox.Color = Color3.new(0, 1, 0)
				beamHitbox.Touched:Connect(function(otherPart)
					if not sp3Active then return end
					local targetChar = getCharacterFromPart(otherPart)
					if targetChar and targetChar ~= character and not sp3Targets[targetChar] then
						sp3Targets[targetChar] = {effectClone = nil}
					end
				end)
			end

			task.spawn(function()
				while sp3Active and not state.cancelAttack do
					if beamHitbox and beamHitbox.Parent then
						local overlapParams = OverlapParams.new()
						overlapParams.FilterDescendantsInstances = {character}
						overlapParams.FilterType = Enum.RaycastFilterType.Exclude
						local parts = workspace:GetPartBoundsInBox(beamHitbox.CFrame, beamHitbox.Size, overlapParams)
						for _, part in ipairs(parts) do
							local targetChar = getCharacterFromPart(part)
							if targetChar and targetChar ~= character and isBuilding(targetChar) and not sp3Targets[targetChar] then
								sp3Targets[targetChar] = {effectClone = nil}
							end
						end
					end
					for targetChar, data in pairs(sp3Targets) do
						if targetChar and targetChar.Parent then
							local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
							if targetHumanoid and targetHumanoid.Health > 0 and beamHitbox and beamHitbox.Parent then
								local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
								local targetPos = targetHrp and targetHrp.Position or targetChar:GetPivot().Position
								if targetPos then
									local intersectPoint = closestPointOnPart(beamHitbox, targetPos)
									local dist = (intersectPoint - targetPos).Magnitude
									local distThreshold = isBuilding(targetChar) and 80 or 30
									if dist <= distThreshold then
										local _isBldg = isBuilding(targetChar)
										dealDamage(targetChar, getDamage("TitanusSpecial3_Damage"), character, getStun("TitanusSpecial3_Stun"), _isBldg, not _isBldg, true)
										if not _isBldg then
											local _attackerHrp = character:FindFirstChild("HumanoidRootPart")
											if _attackerHrp then
												applyKnockback(targetChar, _attackerHrp, 40, 15)
											end
										end
										local beamTemplate = game.Lighting:FindFirstChild("Assets")
											and game.Lighting.Assets:FindFirstChild("Effects")
											and game.Lighting.Assets.Effects:FindFirstChild("HitEffects")
											and game.Lighting.Assets.Effects.HitEffects:FindFirstChild("TitanusBeam")
										if beamTemplate then
											if data.effectClone and data.effectClone.Parent then data.effectClone:Destroy() end
											local effectClone = beamTemplate:Clone()
											effectClone.Anchored = true
											effectClone.CanCollide = false
											effectClone.Transparency = 0
											effectClone.CFrame = CFrame.new(intersectPoint)
											effectClone.Parent = workspace
											data.effectClone = effectClone
											task.delay(0.7, function()
												if effectClone and effectClone.Parent then effectClone:Destroy() end
											end)
										end
									else
										if data.effectClone and data.effectClone.Parent then data.effectClone:Destroy() end
										sp3Targets[targetChar] = nil
									end
								else
									if data.effectClone and data.effectClone.Parent then data.effectClone:Destroy() end
									sp3Targets[targetChar] = nil
								end
							else
								if data.effectClone and data.effectClone.Parent then data.effectClone:Destroy() end
								sp3Targets[targetChar] = nil
							end
						else
							if data.effectClone and data.effectClone.Parent then data.effectClone:Destroy() end
							sp3Targets[targetChar] = nil
						end
					end
					task.wait(0.35)
				end
				for targetChar, data in pairs(sp3Targets) do
					if data.effectClone and data.effectClone.Parent then data.effectClone:Destroy() end
				end
			end)

			local sp3StartTime = tick()
			while sp3Active and not state.cancelAttack and (tick() - sp3StartTime) < 3 do
				task.wait()
			end
			sp3Active = false

			if HitEffectEvent then
				HitEffectEvent:FireClient(player, "BeamShakeEnd")
			end

			if bloodEmitter and bloodEmitter.Parent then bloodEmitter.Enabled = false end

			if AttachStart then
				for _, beam in ipairs(AttachStart:GetDescendants()) do
					if beam:IsA("Beam") then beam.Enabled = false end
				end
				local trail = AttachStart:FindFirstChild("Trail")
				if trail and trail:IsA("Trail") then trail.Enabled = false end
			end

			if beamColorsFolder then
				local lightModel = beamColorsFolder:FindFirstChild("Light")
				if lightModel then
					for _, desc in ipairs(lightModel:GetDescendants()) do
						if desc:IsA("Light") then
							if beamOriginalData[desc] then desc.Brightness = beamOriginalData[desc].brightness end
							desc.Enabled = false
						end
					end
				end
				for _, part in ipairs(beamColorsFolder:GetDescendants()) do
					if part:IsA("BasePart") and beamOriginalData[part] then
						local origTransparency = beamOriginalData[part].transparency
						local tween = TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = origTransparency})
						tween:Play()
						local origMaterial = beamOriginalData[part].material
						tween.Completed:Connect(function()
							if part and part.Parent then part.Material = origMaterial end
						end)
					end
				end
			end

			if beamHitbox then
				beamHitbox.CanTouch = false
				beamHitbox.Transparency = 1
			end

			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			state.isBeaming = false
			if character and character:FindFirstChildOfClass("Humanoid") and not state.isStunned then
				restoreWalkSpeed(state, character)
			end

			local forceWalk = character:FindFirstChild("ForceWalk")
			if forceWalk then forceWalk.Value = false end
		end -- end of else (not burning) branch

	elseif Type == "Rage" then
		local aspectsFolder = character:FindFirstChild("Aspects")
		local infoFolder = aspectsFolder and aspectsFolder:FindFirstChild("Info")
		local rageVal = infoFolder and infoFolder:FindFirstChild("Rage")
		local maxRageVal = rageVal and rageVal:FindFirstChild("MaxRage")
		if not rageVal or not maxRageVal or rageVal.Value < maxRageVal.Value then return end

		rageVal.Value = 0
		character:SetAttribute("RageActive", true)

		state.isBusy = true
		state.isBlocking = false
		state.isBeaming = true
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil

		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Rage")

		saveAndSetWalkSpeed(state, humanoid, 0)

		local colorsFolder = aspectsFolder and aspectsFolder:FindFirstChild("Colors")
		local ultColorVal = colorsFolder and colorsFolder:FindFirstChild("UltColor")
		local ultColor = ultColorVal and ultColorVal.Value or Color3.new(0, 1, 1)

		local AttachStart = character:FindFirstChild("AttachStart")
		local Charge = AttachStart and AttachStart:FindFirstChild("BeamCharge")
		if Charge and Charge:IsA("Sound") then Charge:Play() end

		local fakeHead = character:FindFirstChild("FakeHead")
		local bloodEmitter = fakeHead and fakeHead:FindFirstChild("Blood")
		if bloodEmitter and bloodEmitter:IsA("ParticleEmitter") then bloodEmitter.Enabled = true end

		local beamColorsFolder = character:FindFirstChild("BeamColors")
		local beamOriginalData = {}

		if beamColorsFolder then
			for _, part in ipairs(beamColorsFolder:GetDescendants()) do
				if part:IsA("BasePart") and string.find(string.lower(part.Name), "blue") then
					beamOriginalData[part] = {material = part.Material, transparency = part.Transparency, color = part.Color}
					part.Material = Enum.Material.Neon
					part.Color = ultColor
					local transTween = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0})
					transTween:Play()
				end
			end
			local lightModel = beamColorsFolder:FindFirstChild("Light")
			if lightModel then
				for _, desc in ipairs(lightModel:GetDescendants()) do
					if desc:IsA("Light") then
						beamOriginalData[desc] = {enabled = desc.Enabled, brightness = desc.Brightness}
						desc.Brightness = 10
						desc.Enabled = true
					end
				end
			end
		end

		local rageActive = true
		local rageTargets = {}
		local rageHitbox = nil

		task.delay(3.7, function()
			if not rageActive or not state.isBeaming then return end

			local hollowEarth = character:FindFirstChild("HollowEarth")
			if hollowEarth then
				for _, desc in ipairs(hollowEarth:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then desc.Enabled = true end
					if desc:IsA("Light") then desc.Enabled = true end
				end
			end

			if AttachStart then
				for _, beam in ipairs(AttachStart:GetDescendants()) do
					if beam:IsA("Beam") then beam.Enabled = true end
				end
				local BeamFire = AttachStart:FindFirstChild("BeamFire")
				if BeamFire and BeamFire:IsA("Sound") then BeamFire:Play() end
			end

			if HitEffectEvent then
				HitEffectEvent:FireClient(player, "BeamShakeStart")
			end

			task.spawn(function()
				while rageActive and not state.cancelAttack do
					for targetChar, _ in pairs(rageTargets) do
						if targetChar and targetChar.Parent then
							local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
							if targetHumanoid and targetHumanoid.Health > 0 then
								if isBuilding(targetChar) then
									dealDamage(targetChar, getDamage("TitanusRage_Damage"), character, getStun("TitanusRage_Stun"), true, false, true)
								else
									dealDamage(targetChar, getDamage("TitanusRage_Damage"), character, getStun("TitanusRage_Stun"), false, true, true)
									local attackerHrp = character:FindFirstChild("HumanoidRootPart")
									if attackerHrp then
										applyKnockback(targetChar, attackerHrp, 60, 25)
									end
								end
							else
								rageTargets[targetChar] = nil
							end
						else
							rageTargets[targetChar] = nil
						end
					end
					task.wait(0.7)
				end
			end)
		end)

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local hitboxHolder = Instance.new("Part")
			hitboxHolder.Name = "HitboxHolder"
			hitboxHolder.Size = Vector3.new(1, 1, 1)
			hitboxHolder.Transparency = 1
			hitboxHolder.CanCollide = false
			hitboxHolder.CanTouch = false
			hitboxHolder.CanQuery = false
			hitboxHolder.Massless = true
			hitboxHolder.CastShadow = false
			hitboxHolder.Anchored = false
			hitboxHolder.CFrame = hrp.CFrame

			local holderWeld = Instance.new("Weld")
			holderWeld.Part0 = hrp
			holderWeld.Part1 = hitboxHolder
			holderWeld.C0 = CFrame.new()
			holderWeld.C1 = CFrame.new()
			holderWeld.Parent = hitboxHolder

			hitboxHolder.Parent = character

			rageHitbox = Instance.new("Part")
			rageHitbox.Size = Vector3.new(200, 29, 233)
			rageHitbox.Transparency = 1
			rageHitbox.CanCollide = false
			rageHitbox.CanTouch = true
			rageHitbox.CanQuery = true
			rageHitbox.Massless = true
			rageHitbox.CastShadow = false
			rageHitbox.Anchored = false
			rageHitbox.CFrame = hrp.CFrame

			local hitboxWeld = Instance.new("Weld")
			hitboxWeld.Part0 = hitboxHolder
			hitboxWeld.Part1 = rageHitbox
			hitboxWeld.C0 = CFrame.new()
			hitboxWeld.C1 = CFrame.new()
			hitboxWeld.Parent = rageHitbox

			rageHitbox.Parent = hitboxHolder

			rageHitbox.Touched:Connect(function(otherPart)
				if not rageActive then return end
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not rageTargets[targetChar] then
					rageTargets[targetChar] = true
				end
			end)
		end

		local rageStartTime = tick()
		while rageActive and not state.cancelAttack and (tick() - rageStartTime) < 6.7 do
			task.wait()
		end
		rageActive = false
		character:SetAttribute("RageActive", false)

		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "BeamShakeEnd")
		end

		if bloodEmitter and bloodEmitter.Parent then bloodEmitter.Enabled = false end

		local hollowEarth = character:FindFirstChild("HollowEarth")
		if hollowEarth then
			for _, desc in ipairs(hollowEarth:GetDescendants()) do
				if desc:IsA("ParticleEmitter") then desc.Enabled = false end
				if desc:IsA("Light") then desc.Enabled = false end
			end
		end

		if AttachStart then
			for _, beam in ipairs(AttachStart:GetDescendants()) do
				if beam:IsA("Beam") then beam.Enabled = false end
			end
			local trail = AttachStart:FindFirstChild("Trail")
			if trail and trail:IsA("Trail") then trail.Enabled = false end
		end

		destroyExistingHitboxes(character)

		state.isBusy = false
		if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
		state.isBeaming = false
		if character and character:FindFirstChildOfClass("Humanoid") and not state.isStunned then
			restoreWalkSpeed(state, character)
		end

		task.delay(3, function()
			if not character or not character.Parent then return end
			if beamColorsFolder then
				local lightModel = beamColorsFolder:FindFirstChild("Light")
				if lightModel then
					for _, desc in ipairs(lightModel:GetDescendants()) do
						if desc:IsA("Light") then
							local origData = beamOriginalData[desc]
							local lightTween = TweenService:Create(desc, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = (origData and origData.brightness) or 0})
							lightTween:Play()
							lightTween.Completed:Connect(function()
								if desc and desc.Parent then
									desc.Enabled = (origData and origData.enabled) or false
								end
							end)
						end
					end
				end
				for _, part in ipairs(beamColorsFolder:GetDescendants()) do
					if part:IsA("BasePart") and string.find(string.lower(part.Name), "blue") then
						local origData = beamOriginalData[part]
						local targetColor = (origData and origData.color) or part.Color
						local tween = TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1, Color = targetColor})
						tween:Play()
						tween.Completed:Connect(function()
								if part and part.Parent then
									part.Material = (origData and origData.material ~= Enum.Material.Neon and origData.material) or Enum.Material.Plastic
								end
							end)
						end
					end
				end
			end)

	elseif Type == "Ultimate" then
		state.isBusy = true
		state.isBlocking = false
		state.isBeaming = true
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil

		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Rage")

		saveAndSetWalkSpeed(state, humanoid, 0)

		local aspectsFolder = character:FindFirstChild("Aspects")
		local colorsFolder = aspectsFolder and aspectsFolder:FindFirstChild("Colors")
		local ultColorVal = colorsFolder and colorsFolder:FindFirstChild("UltColor")
		local ultColor = ultColorVal and ultColorVal.Value or Color3.new(0, 1, 1)

		local beamColorsFolder = character:FindFirstChild("BeamColors")
		local beamOriginalData = {}

		if beamColorsFolder then
			for _, part in ipairs(beamColorsFolder:GetDescendants()) do
				if part:IsA("BasePart") and string.find(string.lower(part.Name), "blue") then
					beamOriginalData[part] = {material = part.Material, transparency = part.Transparency, color = part.Color}
					part.Material = Enum.Material.Neon
					local transTween = TweenService:Create(part, TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0, Color = ultColor})
					transTween:Play()
				end
			end
			local lightModel = beamColorsFolder:FindFirstChild("Light")
			if lightModel then
				for _, desc in ipairs(lightModel:GetDescendants()) do
					if desc:IsA("Light") then
						beamOriginalData[desc] = {enabled = desc.Enabled, brightness = desc.Brightness}
						desc.Enabled = true
						local lightTween = TweenService:Create(desc, TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 10})
						lightTween:Play()
					end
				end
			end
		end

		local AttachStart = character:FindFirstChild("AttachStart")
		local Charge = AttachStart and AttachStart:FindFirstChild("BeamCharge")
		if Charge and Charge:IsA("Sound") then Charge:Play() end

		local ultActive = true
		local ultTargets = {}
		local ultHitbox = nil

		task.delay(4, function()
			if not ultActive or not state.isBeaming then return end

			local hollowEarth = character:FindFirstChild("HollowEarth")
			if hollowEarth then
				for _, desc in ipairs(hollowEarth:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then desc.Enabled = true end
					if desc:IsA("Light") then desc.Enabled = true end
				end
				for _, part in ipairs(hollowEarth:GetChildren()) do
					if part:IsA("BasePart") then
						local tween = TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0})
						tween:Play()
					end
				end
			end

			if AttachStart then
				for _, beam in ipairs(AttachStart:GetDescendants()) do
					if beam:IsA("Beam") then beam.Enabled = true end
				end
				local BeamFire = AttachStart:FindFirstChild("BeamFire")
				if BeamFire and BeamFire:IsA("Sound") then BeamFire:Play() end
			end

			if HitEffectEvent then
				HitEffectEvent:FireClient(player, "BeamShakeStart")
			end

			task.spawn(function()
				while ultActive and not state.cancelAttack do
					for targetChar, _ in pairs(ultTargets) do
						if targetChar and targetChar.Parent then
							local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
							if targetHumanoid and targetHumanoid.Health > 0 then
								if isBuilding(targetChar) then
									dealDamage(targetChar, getDamage("TitanusUltimate_Damage"), character, getStun("TitanusUltimate_Stun"), true, false, true)
								else
									dealDamage(targetChar, getDamage("TitanusUltimate_Damage"), character, getStun("TitanusUltimate_Stun"), false, true, true)
									local attackerHrp = character:FindFirstChild("HumanoidRootPart")
									if attackerHrp then
										applyKnockback(targetChar, attackerHrp, 60, 25)
									end
								end
							else
								ultTargets[targetChar] = nil
							end
						else
							ultTargets[targetChar] = nil
						end
					end
					task.wait(0.3)
				end
			end)
		end)

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			ultHitbox = cloneHitbox("Ult", hrp, character)
			if ultHitbox then
				ultHitbox.Touched:Connect(function(otherPart)
					if not ultActive then return end
					local targetChar = getCharacterFromPart(otherPart)
					if targetChar and targetChar ~= character and not ultTargets[targetChar] then
						ultTargets[targetChar] = true
					end
				end)
			end
		end

		local ultStartTime = tick()
		while ultActive and not state.cancelAttack and (tick() - ultStartTime) < 8 do
			task.wait()
		end
		ultActive = false

		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "BeamShakeEnd")
		end

		local hollowEarth = character:FindFirstChild("HollowEarth")
		if hollowEarth then
			for _, desc in ipairs(hollowEarth:GetDescendants()) do
				if desc:IsA("ParticleEmitter") then desc.Enabled = false end
				if desc:IsA("Light") then desc.Enabled = false end
			end
			for _, part in ipairs(hollowEarth:GetChildren()) do
				if part:IsA("BasePart") then
					local tween = TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1})
					tween:Play()
				end
			end
		end

		if AttachStart then
			for _, beam in ipairs(AttachStart:GetDescendants()) do
				if beam:IsA("Beam") then beam.Enabled = false end
			end
		end

		if beamColorsFolder then
			local lightModel = beamColorsFolder:FindFirstChild("Light")
			if lightModel then
				for _, desc in ipairs(lightModel:GetDescendants()) do
					if desc:IsA("Light") then
						local origData = beamOriginalData[desc]
						local lightTween = TweenService:Create(desc, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = (origData and origData.brightness) or 0})
						lightTween:Play()
						lightTween.Completed:Connect(function()
							if desc and desc.Parent then
								desc.Enabled = (origData and origData.enabled) or false
							end
						end)
					end
				end
			end
			for _, part in ipairs(beamColorsFolder:GetDescendants()) do
				if part:IsA("BasePart") and string.find(string.lower(part.Name), "blue") then
					local origData = beamOriginalData[part]
					local targetColor = (origData and origData.color) or part.Color
					local tween = TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1, Color = targetColor})
					tween:Play()
					tween.Completed:Connect(function()
							if part and part.Parent then
								part.Material = (origData and origData.material ~= Enum.Material.Neon and origData.material) or Enum.Material.Plastic
							end
						end)
					end
				end
			end

		destroyExistingHitboxes(character)

		state.isBusy = false
		if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
		state.isBeaming = false
		if character and character:FindFirstChildOfClass("Humanoid") and not state.isStunned then
			restoreWalkSpeed(state, character)
		end

	elseif Type == "Escape" then
		stopTrack(state.attackTrack)
		state.attackTrack = nil
		script.Parent.Parent.Parent.HumanoidRootPart.Escape:Play()

	elseif Type == "Block" then
		if state.isBlocking then
			stopTrack(state.blockTrack)
			state.blockTrack = nil
			state.isBlocking = false
			setBlockEffects(character, false)
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

	elseif Type == "BlockOver" then
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.isBlocking = false
		setBlockEffects(character, false)
		script.Parent.Parent.Parent.HumanoidRootPart.Block:Play()
		local forceWalk = character:FindFirstChild("ForceWalk")
		if forceWalk then forceWalk.Value = false end
		local aspects = character:FindFirstChild("Aspects")
		local defense = aspects and aspects:FindFirstChild("Defense")
		local blockingVal = defense and defense:FindFirstChild("Blocking")
		if blockingVal and blockingVal:IsA("BoolValue") then
			blockingVal.Value = false
		end

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
		if state.attackTrack then state.attackTrack:AdjustSpeed(1.15) end

		state.isAttackingLMB = true
		state.attackStartTime = tick()

		-- Trails: enable both arm trails for LMB1/LMB2, tail trail for LMB3
		if state.comboStep == 1 or state.comboStep == 2 then
			setArmTrails(character, true)
		end
		if state.comboStep == 3 then
			setTailTrails(character, true)
			task.delay(1.2, function()
				setTailTrails(character, false)
			end)
		end

		-- Forward teleport
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

		-- LMB hitbox (moved forward a bit)
		destroyExistingHitboxes(character)
		state.lmbAttackId += 1
		local myAttackId = state.lmbAttackId
		local lmbHitbox = nil
		if hrp then
			lmbHitbox = cloneHitbox("Light" .. state.comboStep, hrp, character, CFrame.new(0, 0, -8))
			local lmbDebounce = {}
			lmbHitbox.Touched:Connect(function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not lmbDebounce[targetChar] then
					lmbDebounce[targetChar] = true
					local dmgKey = "TitanusLight" .. state.comboStep .. "_Damage"
					local stunKey = "TitanusLight" .. state.comboStep .. "_Stun"
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
						if animName == "LMB1" then
							applyKnockback(targetChar, hrp, 45, 15)
						elseif animName == "LMB2" then
							applyKnockback(targetChar, hrp, 50, 15)
						elseif animName == "LMB3" then
							applyKnockback(targetChar, hrp, 80, 35)
						else
							applyKnockback(targetChar, hrp, 30, 5)
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

		local hitboxDuration = HITBOX_DURATION[animName] or 0.3
		task.delay(hitboxDuration, function()
			if state.lmbAttackId ~= myAttackId then return end
			if not state.isAttackingLMB then return end
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			state.isAttackingLMB = false
			if lmbHitbox and lmbHitbox.Parent then lmbHitbox.Parent:Destroy() end
			if character and character:FindFirstChildOfClass("Humanoid") and not state.isStunned then
				restoreWalkSpeed(state, character)
			end
		end)

		-- Attack sound + trail cleanup
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
						setArmTrails(character, false)
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