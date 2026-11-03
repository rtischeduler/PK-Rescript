-- Godzilla2000 Attack System (Optimized)
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

local HitEffectEvent = game.ReplicatedStorage:FindFirstChild("HitEffectEvent")
local AttackConfirmEvent = game.ReplicatedStorage:FindFirstChild("AttackConfirmEvent")
local AttackEndEvent = game.ReplicatedStorage:FindFirstChild("AttackEndEvent")
local HitboxDataModule = require(game.ReplicatedStorage:WaitForChild("HitboxDataModule"))

----------------------------------------------------------------
-- HITBOX DATA HELPER (manually creates hitboxes from HitboxDataModule)
----------------------------------------------------------------
local KAIJU_NAME = "Godzilla2000"

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

-- Connect Touched handler to BOTH the hitbox child AND its holder parent
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
	LMB1 = 0.45, LMB2 = 0.45, LMB3 = 1.14,
	Roar = 0.5, Grab = 0.4, SP1 = 0.3, SP2 = 0.4, SP3 = 2,
}

-- Initialize the shared combat system (sets up death handling, player tracking, etc.)
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

	-- Check stun/knockdown/grab aspects — can't attack while in those states
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
			setArmTrails(character, false)
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
					dealDamage(targetChar, getDamage("G2000Grab_Damage"), character, getStun("G2000Grab_Stun"), true, false, true)
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
						and game.Lighting.Assets.Effects.AttackEffects:FindFirstChild("Godzilla2000")
						and game.Lighting.Assets.Effects.AttackEffects.Godzilla2000:FindFirstChild("Grab")
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

							-- Weld effect parts to grabbed character
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
							-- Particles off initially; enabled 0.5s before throw
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
				end
			end)
		end

		-- If no target grabbed within 0.4s, cancel
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

		-- Grab end: throw the target
		local function onGrabEnd()
			if state.grabCancelled then return end
			state.grabCancelled = true
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			state.attackTrack = nil
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
				dealDamage(grabbedCharacter, getDamage("G2000GrabThrow_Damage"), character, getStun("G2000GrabThrow_Stun"), true, false, true)
				if targetHrp and targetHrp.Parent and hrp and hrp.Parent then
					applyKnockback(grabbedCharacter, hrp, 50, 10)
				end

				local throwStunDuration = getStun("G2000GrabThrow_Stun")
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
					-- Restore beam colors
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
	-- SP1 (Special Attack 1)
	----------------------------------------------------------------
	elseif Type == "SP1" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP1")

		-- SFX
		script.Parent.Parent.Parent.Head.SP1:Play()

		saveAndSetWalkSpeed(state, humanoid, 0)

		-- Movement: forward dash (horizontal only to prevent ground clipping)
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			task.spawn(function()
				for i = 1, 3 do
					if hrp and hrp.Parent then
						local look = hrp.CFrame.LookVector
						local flatLook = Vector3.new(look.X, 0, look.Z)
						if flatLook.Magnitude > 0.001 then
							flatLook = flatLook.Unit
						end
						hrp.CFrame = CFrame.new(hrp.Position + flatLook * 1.5) * (hrp.CFrame - hrp.Position)
					end
					task.wait(0.05)
				end
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
							dealBuildingIntervalDamage(targetChar, getDamage("G2000Special1_Damage"), character, getStun("G2000Special1_Stun"), true, sp1Hitbox)
							return
						end
						dealDamage(targetChar, getDamage("G2000Special1_Damage"), character, getStun("G2000Special1_Stun"), false, true, true)
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
	-- SP2 (Special Attack 2 - Tail Whip)
	----------------------------------------------------------------
	elseif Type == "SP2" then
		state.isBusy = true
		state.isBlocking = false
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "SP2")

		-- SFX
		script.Parent.Parent.Parent.Head.SP2:Play()

		-- VFX: enable tail trails
		setTailTrails(character, true)

		saveAndSetWalkSpeed(state, humanoid, 0)

		-- Movement: forward dash
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			task.spawn(function()
				for i = 1, 6 do
					if hrp and hrp.Parent then
						hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -1.5)
					end
					task.wait(0.06)
				end
			end)
		end

		-- Hitbox on tail part
		local tailParts = findTailParts(character)
		local sp2BodyPart = hrp
		if #tailParts >= 4 then
			sp2BodyPart = tailParts[#tailParts - 2].part
		elseif #tailParts >= 2 then
			sp2BodyPart = tailParts[#tailParts - 1].part
		elseif #tailParts >= 1 then
			sp2BodyPart = tailParts[1].part
		end

		destroyExistingHitboxes(character)
		local sp2Hitbox = nil
		if sp2BodyPart then
			sp2Hitbox = cloneHitbox("SP2", sp2BodyPart, character)
			local sp2Debounce = {}
			connectHitboxTouched(sp2Hitbox, function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not sp2Debounce[targetChar] then
					sp2Debounce[targetChar] = true
					if isBuilding(targetChar) then
						dealBuildingIntervalDamage(targetChar, getDamage("G2000Special2_Damage"), character, getStun("G2000Special2_Stun"), true, sp2Hitbox)
						return
					end
					-- Combat delegated to CombatSystem
					dealDamage(targetChar, getDamage("G2000Special2_Damage"), character, getStun("G2000Special2_Stun"), false, true, true)
					applyKnockback(targetChar, character:FindFirstChild("HumanoidRootPart"), 120, 50)
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
			restoreWalkSpeed(state, character)
		end

		if state.attackTrack then
			state.attackTrack.Ended:Connect(onSP2End)
		else
			task.delay(3, onSP2End)
		end

	----------------------------------------------------------------
	-- SP3 (Special Attack 3 - Beam)
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
		local Charge = character.AttachStart.BeamCharge
		local BeamFire = character.AttachStart.BeamFire
		Charge:Play()
		task.wait(0.7)
		BeamFire:Play()

		-- VFX: beam camera shake
		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "BeamShakeStart")
		end

		-- VFX: enable beams and trail
		local AttachStart = character:FindFirstChild("AttachStart")
		if AttachStart then
			for _, beam in ipairs(AttachStart:GetDescendants()) do
				if beam:IsA("Beam") then beam.Enabled = true end
			end
		end
		AttachStart.Trail.Enabled = true

		-- VFX: beam colors to fire color
		local beamColorsFolder = character:FindFirstChild("BeamColors")
		local aspectsColors, fireColorVal = getBeamColorValues(character)
		local normalColorVal = aspectsColors
		local beamOriginalData = {}
		if beamColorsFolder and fireColorVal then
			beamOriginalData = tweenBeamColorsToFire(beamColorsFolder, fireColorVal.Value)
		end

		-- Hitbox + combat (delegated to CombatSystem for damage/knockback)
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
									dealDamage(targetChar, getDamage("G2000Special3_Damage"), character, getStun("G2000Special3_Stun"), _isBldg, not _isBldg, true)
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
										and game.Lighting.Assets.Effects.HitEffects:FindFirstChild("G2KBeam")
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

		-- VFX: disable beams and trail
		if AttachStart then
			for _, beam in ipairs(AttachStart:GetDescendants()) do
				if beam:IsA("Beam") then beam.Enabled = false end
			end
		end
		AttachStart.Trail.Enabled = false

		-- VFX: restore beam colors
		if beamColorsFolder and normalColorVal then
			restoreBeamColors(beamColorsFolder, normalColorVal.Value, beamOriginalData)
		end

		if beamHitbox then
			beamHitbox.CanTouch = false
			beamHitbox.Transparency = 1
		end

		state.isBusy = false
		if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
		state.isBeaming = false
		restoreWalkSpeed(state, character)

		local forceWalk = character:FindFirstChild("ForceWalk")
		if forceWalk then forceWalk.Value = false end

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
			-- Clear shared Defense.Blocking BoolValue
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
			-- Set shared Defense.Blocking BoolValue
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
		-- Clear shared Defense.Blocking BoolValue
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
		stopTrack(state.attackTrack)
		stopTrack(state.blockTrack)
		state.blockTrack = nil

		-- Set rage to 0
		rageValue.Value = 0

		-- Animation: rage charge
		state.attackTrack = playAttackAnimation(animationsFolder, animator, "Rage")

		saveAndSetWalkSpeed(state, humanoid, 0)

		task.wait(1.5)
		if not character or not character.Parent or not state.isRaging then
			state.isRaging = false
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			return
		end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- VFX: clone Ult effect model
		local ultEffectTemplate = game.ReplicatedStorage:FindFirstChild("Assets")
			and game.ReplicatedStorage.Assets:FindFirstChild("Kaijus")
			and game.ReplicatedStorage.Assets.Kaijus:FindFirstChild("Effects")
			and game.ReplicatedStorage.Assets.Kaijus.Effects:FindFirstChild("UltEffects")
			and game.ReplicatedStorage.Assets.Kaijus.Effects.UltEffects:FindFirstChild("Godzilla2000")
			and game.ReplicatedStorage.Assets.Kaijus.Effects.UltEffects.Godzilla2000:FindFirstChild("Ult")

		if ultEffectTemplate then
			local ultClone = ultEffectTemplate:Clone()
			ultClone.Name = "RageExplosion"
			ultClone:PivotTo(CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z))
			for _, desc in ipairs(ultClone:GetDescendants()) do
				if desc:IsA("BasePart") then
					desc.Anchored = true
					desc.CanCollide = false
					desc.Massless = true
					desc.CanTouch = false
				end
			end
			local tweenScript = ultClone:FindFirstChild("Tween")
			if tweenScript and tweenScript:IsA("Script") then tweenScript.Disabled = true end
			local rageAnimScript = ultClone:FindFirstChild("RageEffectAnimation")
			if rageAnimScript and rageAnimScript:IsA("Script") then rageAnimScript.Disabled = false end
			ultClone.Parent = workspace
		end

		-- VFX: screen shake
		if HitEffectEvent then
			HitEffectEvent:FireClient(player, "RoarShakeStart")
		end

		-- Hitbox + combat (delegated to CombatSystem)
		destroyExistingHitboxes(character)
		local rageHitbox = cloneHitbox("Rage", hrp, character)

		if rageHitbox then
			local rageDebounce = {}
			connectHitboxTouched(rageHitbox, function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not rageDebounce[targetChar] then
					rageDebounce[targetChar] = true
					if isBuilding(targetChar) then
						dealBuildingIntervalDamage(targetChar, getDamage("G2000Rage_Damage"), character, getStun("G2000Rage_Stun"), true, rageHitbox)
						return
					end
					-- Combat delegated to CombatSystem
					dealDamage(targetChar, getDamage("G2000Rage_Damage"), character, getStun("G2000Rage_Stun"), false, true, true)
					applyKnockback(targetChar, hrp, 100, 40)
					setKnockdown(targetChar, true)
					task.delay(2, function() setKnockdown(targetChar, false) end)
				end
			end)
		end

		-- Cleanup after explosion
		task.delay(1.5, function()
			state.isRaging = false
			state.isBusy = false
			if AttackEndEvent then AttackEndEvent:FireClient(player, Type) end
			if rageHitbox and rageHitbox.Parent then rageHitbox.Parent:Destroy() end
			if not character or not character.Parent then return end
			if HitEffectEvent then
				HitEffectEvent:FireClient(player, "RoarShakeEnd")
			end
			restoreWalkSpeed(state, character)
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
			setArmTrails(character, true)
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
				-- LMB3: attach hitbox to HRP for consistent frontal coverage
				lmbHitbox = cloneHitbox("Light3", hrp, character, CFrame.new(0, 0, -8))
			else
				lmbHitbox = cloneHitbox("Light" .. state.comboStep, hrp, character, CFrame.new(0, 0, -8))
			end
			local lmbDebounce = {}
			connectHitboxTouched(lmbHitbox, function(otherPart)
				local targetChar = getCharacterFromPart(otherPart)
				if targetChar and targetChar ~= character and not lmbDebounce[targetChar] then
					lmbDebounce[targetChar] = true
					local dmgKey = "G2000Light" .. state.comboStep .. "_Damage"
					local stunKey = "G2000Light" .. state.comboStep .. "_Stun"
					local isHeavy = (animName == "LMB3")
					if isBuilding(targetChar) then
						dealBuildingIntervalDamage(targetChar, getDamage(dmgKey), character, getStun(stunKey), isHeavy, lmbHitbox)
						return
					end
					-- Combat delegated to CombatSystem
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

					-- VFX: blood gash for LMB1/LMB2
					if animName == "LMB1" or animName == "LMB2" then
						spawnBloodGash(targetHrp)
					end

					-- LMB3: knockdown + heavy sound
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