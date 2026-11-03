-- MechaGodzilla2021 Attack System
-- Handles: LMB attacks (LMB1, LMB2, LMB3 grab), SP1 (Tail Stab), SP3 (Proton Scream Beam), Roar
-- All combat logic (damage, stun, knockback, grab) is delegated to the shared CombatSystem module

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Require shared CombatSystem
local CombatSystem = require(game.ReplicatedStorage.CombatSystem)

-- Pull shared API
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

local HitEffectEvent = game.ReplicatedStorage:FindFirstChild("HitEffectEvent")
local AttackConfirmEvent = game.ReplicatedStorage:FindFirstChild("AttackConfirmEvent")
local AttackEndEvent = game.ReplicatedStorage:FindFirstChild("AttackEndEvent")
local HitboxDataModule = require(game.ReplicatedStorage:WaitForChild("HitboxDataModule"))

----------------------------------------------------------------
-- HITBOX DATA HELPER (manually creates hitboxes from HitboxDataModule)
----------------------------------------------------------------
local KAIJU_NAME = "MechaGodzilla2021"

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

-- Interval damage for buildings
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

-- LMB3 Grab constants
local GRAB_DURATION = 3       -- seconds the target is held
local GRAB_INTERVAL_DAMAGE = 0.5 -- damage per tick
local GRAB_INTERVAL_TIME = 0.5   -- seconds between damage ticks
local GRAB_HITBOX_WINDOW = 0.64  -- time to wait for grab hitbox to connect

local HITBOX_DURATION = {
	LMB1 = 0.45, LMB2 = 0.45,
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
		state = {
			attackTrack = nil, blockTrack = nil, comboStep = 1, lastLMBTime = 0,
			isBusy = false, isBlocking = false, isStunned = false, isRoaring = false,
			isRaging = false, savedWalkSpeed = nil, comboCooldownEnd = 0,
			grabCancelled = false, cancelAttack = false, isAttackingLMB = false,
			attackStartTime = 0, isBeaming = false, lmbAttackId = 0,
		}
		playerState[userId] = state
	end
	state.cancelAttack = false

	-- Check stun/knockdown/grab aspects
	local aspects = character:FindFirstChild("Aspects")
	local stunFolder = aspects and aspects:FindFirstChild("Stun")
	local knockdownVal = stunFolder and stunFolder:FindFirstChild("Knockdown")
	local grabbedVal = stunFolder and stunFolder:FindFirstChild("Grabbed")
	local stunnedVal = stunFolder and stunFolder:FindFirstChild("Stunned")
	local aspectStunned = (knockdownVal and knockdownVal.Value)
		or (grabbedVal and grabbedVal.Value)
		or (stunnedVal and stunnedVal.Value)
	if state.isStunned or aspectStunned then return end

	if tick() < state.comboCooldownEnd then return end

	-- Busy check
	if state.isBusy then
		if (Type == "SP1" or Type == "SP3" or Type == "Grab") and state.isAttackingLMB then
			state.isAttackingLMB = false
			state.isBusy = false
			destroyExistingHitboxes(character)
			stopTrack(state.attackTrack)
			state.attackTrack = nil
			restoreWalkSpeed(state, character)
		else
			return
		end
	end
	if state.isBlocking then return end

	-- Confirm to client that the attack was accepted
	if AttackConfirmEvent and (Type == "SP1" or Type == "SP3" or Type == "Grab" or Type == "Roar") then
		AttackConfirmEvent:FireClient(player, Type)
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

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
		local roarFXPart = character:FindFirstChild("RoarFXPart")
		if roarFXPart then
			for _, desc in ipairs(roarFXPart:GetDescendants()) do
				if desc:IsA("ParticleEmitter") then
					desc.Enabled = true
				end
			end
		end

		-- VFX: RoarWave (expanding wave at feet)
		local roarWaveTemplate = game.Lighting:FindFirstChild("Assets")
			and game.Lighting.Assets:FindFirstChild("Effects")
			and game.Lighting.Assets.Effects:FindFirstChild("WaveEffects")
			and game.Lighting.Assets.Effects.WaveEffects:FindFirstChild("RoarWave")
		local roarWaveClone = nil
		if roarWaveTemplate and hrp then
			roarWaveClone = roarWaveTemplate:Clone()
			roarWaveClone.Name = "RoarWaveActive"

			local charVal = roarWaveClone:FindFirstChild("Char")
			if charVal and charVal:IsA("ObjectValue") then
				charVal.Value = character
			end

			roarWaveClone:PivotTo(CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z))

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
			if roarFXPart then
				for _, desc in ipairs(roarFXPart:GetDescendants()) do
					if desc:IsA("ParticleEmitter") then desc.Enabled = false end
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
	-- LMB (Light Attack Combo: LMB1, LMB2, LMB3=Grab)
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

		if state.comboStep == 3 then
			------------------------------------------------------------
			-- LMB3: GRAB MECHANIC
			-- Grabs the other player with the Grabber for 3 seconds,
			-- deals 0.5 interval damage, then knocks them back
			------------------------------------------------------------

			-- SFX: grab deploy sound
			if head then
				local lmb31 = head:FindFirstChild("LMB31")
				if lmb31 and lmb31:IsA("Sound") then lmb31:Play() end
				local grabSound = head:FindFirstChild("Grab")
				if grabSound and grabSound:IsA("Sound") then grabSound:Play() end
			end

			-- Set Grabbing aspect
			local grabbingVal = aspects and aspects:FindFirstChild("Grabbing")
			if grabbingVal and grabbingVal:IsA("BoolValue") then
				grabbingVal.Value = true
			end

			-- Spawn grab hitbox on the Grabber part
			destroyExistingHitboxes(character)
			state.lmbAttackId += 1
			local myAttackId = state.lmbAttackId

			local grabberPart = character:FindFirstChild("Grabber")
			local grabBodyPart = grabberPart or hrp

			local grabHitbox = nil
			local grabbedCharacter = nil
			local grabFollowConnection = nil
			local targetSavedWalkSpeed = 16
			local grabEnded = false
			local collisionParts = {}

			if grabBodyPart then
				grabHitbox = cloneHitbox("Grab", grabBodyPart, character, CFrame.new(0, 0, -10))
				local grabDebounce = {}

				connectHitboxTouched(grabHitbox, function(otherPart)
					if grabbedCharacter then return end
					local targetChar = getCharacterFromPart(otherPart)
					if targetChar and targetChar ~= character
						and not grabDebounce[targetChar]
						and not isBuilding(targetChar) then

						grabDebounce[targetChar] = true
						grabbedCharacter = targetChar

						-- Combat: break block, set grabbed
						breakBlock(targetChar)
						setGrabbed(targetChar, true)

					-- Disable collision on grabbed target to prevent flinging
					for _, part in ipairs(targetChar:GetDescendants()) do
						if part:IsA("BasePart") and part.CanCollide then
							part.CanCollide = false
							table.insert(collisionParts, part)
						end
					end

						-- SFX: grab hit sound
						if head then
							local lmb32 = head:FindFirstChild("LMB32")
							if lmb32 and lmb32:IsA("Sound") then lmb32:Play() end
						end

						-- Stop target movement
						local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
						local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
						local followTarget = grabberPart or hrp

						if targetHum then
							targetSavedWalkSpeed = targetHum.WalkSpeed
							targetHum.WalkSpeed = 0
							targetHum.AutoRotate = false
						end

						-- Anchor target and follow grabber
						if targetHrp then
							targetHrp.Anchored = true
							targetHrp.CFrame = followTarget.CFrame
								* CFrame.new(0, 0, -15)
								* CFrame.Angles(0, math.rad(180), 0)

							grabFollowConnection = RunService.Heartbeat:Connect(function()
								if grabbedCharacter and grabbedCharacter.Parent
									and followTarget and followTarget.Parent then
									local tHrp = grabbedCharacter:FindFirstChild("HumanoidRootPart")
									if tHrp then
										tHrp.CFrame = followTarget.CFrame
											* CFrame.new(0, 0, -15)
											* CFrame.Angles(0, math.rad(180), 0)
										end
								else
									if grabFollowConnection then
										grabFollowConnection:Disconnect()
										grabFollowConnection = nil
									end
								end
							end)
						end

						-- Destroy grab hitbox once we have a target
						if grabHitbox and grabHitbox.Parent then
							grabHitbox.Parent:Destroy()
						end

						-- Interval damage loop: 0.5 damage every 0.5 seconds for 3 seconds
						task.spawn(function()
							local grabStartTime = tick()
							while grabbedCharacter and grabbedCharacter.Parent
								and (tick() - grabStartTime) < GRAB_DURATION do
								local targetHum2 = grabbedCharacter:FindFirstChildOfClass("Humanoid")
								if not targetHum2 or targetHum2.Health <= 0 then break end
								dealDamage(grabbedCharacter, GRAB_INTERVAL_DAMAGE, character, 0, true, false, false)
								task.wait(GRAB_INTERVAL_TIME)
							end
						end)
					end
				end)
			end

			-- Grab end function: release target with knockback
			local function onGrabEnd()
				if grabEnded then return end
				grabEnded = true
				state.isBusy = false
				if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
				state.isAttackingLMB = false
				state.attackTrack = nil

				-- Reset Grabbing aspect
				local grabbingVal2 = aspects and aspects:FindFirstChild("Grabbing")
				if grabbingVal2 and grabbingVal2:IsA("BoolValue") then
					grabbingVal2.Value = false
				end

				if grabFollowConnection then
					grabFollowConnection:Disconnect()
					grabFollowConnection = nil
				end
				if grabHitbox and grabHitbox.Parent then
					grabHitbox.Parent:Destroy()
				end

				-- Release grabbed target with knockback
				if grabbedCharacter and grabbedCharacter.Parent then
					local targetHrp = grabbedCharacter:FindFirstChild("HumanoidRootPart")
					setGrabbed(grabbedCharacter, false)

					if targetHrp then
						targetHrp.Anchored = false
					end

					local targetHum = grabbedCharacter:FindFirstChildOfClass("Humanoid")
					if targetHum then
						targetHum.WalkSpeed = targetSavedWalkSpeed
						targetHum.AutoRotate = true
					end

					-- Knockback
					if targetHrp and targetHrp.Parent and hrp and hrp.Parent then
						applyKnockback(grabbedCharacter, hrp, 80, 35)

					-- Re-enable collision on grabbed target after knockback separates them
					task.delay(0.5, function()
						for _, part in ipairs(collisionParts) do
							if part and part.Parent then
								part.CanCollide = true
							end
						end
						collisionParts = {}
					end)
					end

					-- Knockdown
					setKnockdown(grabbedCharacter, true)
					task.delay(1.5, function()
						if grabbedCharacter and grabbedCharacter.Parent then
							setKnockdown(grabbedCharacter, false)
						end
					end)
				end

				restoreWalkSpeed(state, character)
			end

			-- End grab when animation ends, or after grab duration + buffer
			if state.attackTrack then
				state.attackTrack.Ended:Connect(onGrabEnd)
			end

			-- Safety timeout: end grab after GRAB_DURATION + buffer
			task.delay(GRAB_DURATION + 0.5, onGrabEnd)

			-- If no target grabbed within hitbox window, cancel
			task.delay(GRAB_HITBOX_WINDOW, function()
				if not grabbedCharacter and not grabEnded then
					onGrabEnd()
				end
			end)

		else
			------------------------------------------------------------
			-- LMB1 / LMB2: Regular melee attack
			------------------------------------------------------------

			-- SFX: attack sound
			if head then
				local attackSound = head:FindFirstChild(animName)
				if attackSound and attackSound:IsA("Sound") then
					local clone = attackSound:Clone()
					clone.Parent = head
					clone:Play()
					clone.Ended:Connect(function()
						clone:Destroy()
					end)
				end
			end

			-- Movement: forward dash
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
				lmbHitbox = cloneHitbox("Light" .. state.comboStep, hrp, character, CFrame.new(0, 0, -8))
				local lmbDebounce = {}

				connectHitboxTouched(lmbHitbox, function(otherPart)
					local targetChar = getCharacterFromPart(otherPart)
					if targetChar and targetChar ~= character and not lmbDebounce[targetChar] then
						lmbDebounce[targetChar] = true
						local dmgKey = "MechaGodzillaLight" .. state.comboStep .. "_Damage"
						local stunKey = "MechaGodzillaLight" .. state.comboStep .. "_Stun"
						local isHeavy = false

						if isBuilding(targetChar) then
							dealBuildingIntervalDamage(targetChar, getDamage(dmgKey), character, getStun(stunKey), isHeavy, lmbHitbox)
							return
						end

						-- Combat delegated to CombatSystem
						dealDamage(targetChar, getDamage(dmgKey), character, getStun(stunKey), false, true, isHeavy)

						local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
						if targetHrp and hrp and hrp.Parent then
							applyKnockback(targetChar, hrp, 35, 12)
						end

						-- VFX: blood gash
						if targetHrp then
							spawnBloodGash(targetHrp)
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
		end

		-- Advance combo
		state.comboStep = (state.comboStep % 3) + 1
		state.lastLMBTime = now

		if animName == "LMB3" then
			state.comboCooldownEnd = now + 3
		end

	----------------------------------------------------------------
	-- SP1: TAIL STAB (3 damage intervals at 0.4s)
	----------------------------------------------------------------
	elseif Type == "SP1" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil

		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP1")

		-- SFX
		if head then
			local sp1Sound = head:FindFirstChild("SP1")
			if sp1Sound and sp1Sound:IsA("Sound") then sp1Sound:Play() end
		end

		saveAndSetWalkSpeed(state, humanoid, 0)

		destroyExistingHitboxes(character)
		local sp1Hitbox = nil
		local sp1Targets = {}

		if hrp then
			sp1Hitbox = cloneHitbox("SP1", hrp, character, CFrame.new(0, 0, -10))
			if sp1Hitbox then
				connectHitboxTouched(sp1Hitbox, function(otherPart)
					local targetChar = getCharacterFromPart(otherPart)
					if targetChar and targetChar ~= character and not sp1Targets[targetChar] then
						if isBuilding(targetChar) then
							sp1Targets[targetChar] = true
							dealBuildingIntervalDamage(targetChar, getDamage("MechaGodzillaSpecial1_Damage"), character, getStun("MechaGodzillaSpecial1_Stun"), true, sp1Hitbox)
							return
						end
						sp1Targets[targetChar] = true
					end
				end)
			end
		end

		-- 3 damage intervals at 0.4s each
		task.spawn(function()
			for i = 1, 3 do
				task.wait(0.4)
				for targetChar, _ in pairs(sp1Targets) do
					if targetChar and targetChar.Parent and not isBuilding(targetChar) then
						local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
						if targetHum and targetHum.Health > 0 then
							dealDamage(targetChar, getDamage("MechaGodzillaSpecial1_Damage"), character, getStun("MechaGodzillaSpecial1_Stun"), false, true, true)
							local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
							if targetHrp then
								spawnBloodGash(targetHrp)
							end
							-- Knockback on the final hit
							if i == 3 and targetHrp and hrp and hrp.Parent then
								applyKnockback(targetChar, hrp, 60, 25)
							end
						end
					end
				end
			end

			-- Cleanup
			destroyExistingHitboxes(character)
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			restoreWalkSpeed(state, character)
		end)

	----------------------------------------------------------------
	-- SP3: PROTON SCREAM (Beam Attack)
	----------------------------------------------------------------
	elseif Type == "SP3" then
		state.isBusy = true
		state.isBlocking = false
		state.isBeaming = true
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil

		-- Movement: force walk mode
		local forceWalk = character:FindFirstChild("ForceWalk")
		if forceWalk then forceWalk.Value = true end

		saveAndSetWalkSpeed(state, humanoid, 15)

		-- Animation
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP3")

		-- SFX: beam charge + fire sounds
		local attachStart = character:FindFirstChild("AttachStart")
		local chargeSound = attachStart and attachStart:FindFirstChild("BeamCharge")
		local fireSound = attachStart and attachStart:FindFirstChild("BeamFire")
		if chargeSound then chargeSound:Play() end
		task.wait(0.7)
		if fireSound then fireSound:Play() end

		-- VFX: beam camera shake
		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "BeamShakeStart")
		end

		-- VFX: enable beams on AttachStart
		if attachStart then
			for _, beam in ipairs(attachStart:GetDescendants()) do
				if beam:IsA("Beam") then beam.Enabled = true end
			end
			-- Enable trail if present
			local trail = attachStart:FindFirstChildOfClass("Trail")
			if trail then trail.Enabled = true end
		end

		-- Hitbox + combat
		local beamHitbox = character:FindFirstChild("BeamHitbox")
		local sp3Targets = {}
		local sp3Active = true

		if beamHitbox then
			beamHitbox.CanTouch = true
			beamHitbox.Transparency = 1

			beamHitbox.Touched:Connect(function(otherPart)
				if not sp3Active then return end
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not sp3Targets[targetChar] then
					sp3Targets[targetChar] = {effectClone = nil}
				end
			end)
		end

		-- Continuous beam damage loop
		task.spawn(function()
			while sp3Active and not state.cancelAttack do
				-- Spatial query to detect buildings
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
									-- Combat delegated to CombatSystem
									dealDamage(targetChar, getDamage("MechaGodzillaSpecial3_Damage"), character, getStun("MechaGodzillaSpecial3_Stun"), _isBldg, not _isBldg, true)
									if not _isBldg then
										local _attackerHrp = character:FindFirstChild("HumanoidRootPart")
										if _attackerHrp then
											applyKnockback(targetChar, _attackerHrp, 40, 15)
										end
									end

									-- VFX: beam hit effect
									local beamTemplate = game.Lighting:FindFirstChild("Assets")
										and game.Lighting.Assets:FindFirstChild("Effects")
										and game.Lighting.Assets.Effects:FindFirstChild("HitEffects")
										and game.Lighting.Assets.Effects.HitEffects:FindFirstChild("MechaBeam")
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

		-- Beam duration (3 seconds max)
		local sp3StartTime = tick()
		while sp3Active and not state.cancelAttack and (tick() - sp3StartTime) < 3 do
			task.wait()
		end
		sp3Active = false

		-- VFX: stop beam camera shake
		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "BeamShakeEnd")
		end

		-- VFX: disable beams
		if attachStart then
			for _, beam in ipairs(attachStart:GetDescendants()) do
				if beam:IsA("Beam") then beam.Enabled = false end
			end
			local trail = attachStart:FindFirstChildOfClass("Trail")
			if trail then trail.Enabled = false end
		end

		-- SFX: beam end sound
		if head then
			local beamEnd = head:FindFirstChild("BeamEnd")
			if beamEnd and beamEnd:IsA("Sound") then beamEnd:Play() end
		end

		if beamHitbox then
			beamHitbox.CanTouch = false
			beamHitbox.Transparency = 1
		end

		state.isBusy = false
		if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
		state.isBeaming = false
		restoreWalkSpeed(state, character)

		local forceWalk2 = character:FindFirstChild("ForceWalk")
		if forceWalk2 then forceWalk2.Value = false end
	end
end)