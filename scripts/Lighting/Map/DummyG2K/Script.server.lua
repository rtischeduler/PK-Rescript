-- TRAINING DUMMY SCRIPT FOR DummyG2K
-- Based on TitanusGodzilla Event.Script structure, stripped of attack functions and player input
-- Retains: stun, knockdown, knockback, grabbed handling + idle animation + death/faint

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Reference to the dummy model (script.Parent)
local dummy = script.Parent
local humanoid = dummy:FindFirstChildOfClass("Humanoid")
local animator = humanoid and humanoid:FindFirstChild("Animator")
local animationsFolder = dummy:FindFirstChild("Animations")

-- Animation track references
local idleTrack = nil
local currentStunTrack = nil

-- Helper: play an animation from the Animations folder with given priority
local function playAnimation(animationsFolder, animator, animName, priority)
	if not animationsFolder or not animator then return nil end
	local anim = animationsFolder:FindFirstChild(animName)
	if anim and anim:IsA("Animation") then
		local track = animator:LoadAnimation(anim)
		track.Priority = priority or Enum.AnimationPriority.Action
		track:Play()
		return track
	end
	return nil
end

-- Helper: stop a track safely
local function stopTrack(track)
	if track and track.IsPlaying then
		track:Stop()
	end
end

-- Helper: stop all playing animation tracks
local function stopAllTracks()
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end
end

-- Helper: play recover VFX and sound when stun ends
local function playRecoverEffect(character)
	-- Stun-state guard: block recover effects if the character is still in ANY stun state.
	-- Only play when truly recovered from all stun types.
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

	-- Shared debounce with CombatSystem via attribute to prevent duplicate recover effects
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
	if recoverTemplate then
		local targetHrp = character:FindFirstChild("HumanoidRootPart")
		if targetHrp then
			local recoverClone = recoverTemplate:Clone()
			recoverClone.CFrame = targetHrp.CFrame
			recoverClone.Anchored = true
			recoverClone.CanCollide = false
			recoverClone.Transparency = 1
			-- Enable all particle emitters
			for _, desc in ipairs(recoverClone:GetDescendants()) do
				if desc:IsA("ParticleEmitter") then
					desc.Enabled = true
				end
			end
			recoverClone.Parent = character
			-- Play Recover sound from HumanoidRootPart
			local recoverSound = targetHrp:FindFirstChild("Recover")
			if recoverSound and recoverSound:IsA("Sound") then
				recoverSound:Play()
			end
			task.delay(1, function()
				if recoverClone and recoverClone.Parent then
					recoverClone:Destroy()
				end
			end)
		end
	end
end

-- Helper: enable or disable block VFX (BlockCircle & BlockFX inside HumanoidRootPart.Attachment)
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
			-- Also handle any nested emitters/beams inside the effect
			for _, desc in ipairs(effect:GetDescendants()) do
				if desc:IsA("ParticleEmitter") or desc:IsA("Beam") then
					desc.Enabled = enabled
				end
			end
		end
	end
end

-- Helper: find the nearest player character near the dummy
local function findNearestPlayerCharacter()
	local dummyHrp = dummy:FindFirstChild("HumanoidRootPart")
	if not dummyHrp then return nil end
	local dummyPos = dummyHrp.Position
	local nearestChar = nil
	local nearestDist = math.huge
	for _, player in Players:GetPlayers() do
		local char = player.Character
		if char then
			local charHrp = char:FindFirstChild("HumanoidRootPart")
			if charHrp then
				local dist = (charHrp.Position - dummyPos).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearestChar = char
				end
			end
		end
	end
	return nearestChar
end

-- Helper: make the dummy face a target character
local function lookAtCharacter(targetChar)
	local dummyHrp = dummy:FindFirstChild("HumanoidRootPart")
	local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	if dummyHrp and targetHrp and dummyHrp.Parent and targetHrp.Parent then
		local lookDirection = (targetHrp.Position - dummyHrp.Position)
		if lookDirection.Magnitude > 0 then
			dummyHrp.CFrame = CFrame.new(dummyHrp.Position, targetHrp.Position)
		end
	end
end

-- Reference to Faint KeyframeSequence (fallback for death animation)
local function getFaintKeyframeSequence()
	local kaijus = game.ReplicatedStorage:FindFirstChild("Kaijus")
	local models = kaijus and kaijus:FindFirstChild("Models")
	local g2k = models and models:FindFirstChild("DummyG2K")
	local default = g2k and g2k:FindFirstChild("Godzilla2000-Default")
	local animSaves = default and default:FindFirstChild("AnimSaves")
	return animSaves and animSaves:FindFirstChild("Faint")
end

-- Play Faint animation on death
local function setupDeathHandling()
	if not humanoid then return end

	-- Prevent default ragdoll so death animation can play
	humanoid.BreakJointsOnDeath = false

	humanoid.Died:Connect(function()
		local anim = humanoid:FindFirstChild("Animator")

		-- Anchor HumanoidRootPart so the body stays in place
		local hrp = dummy:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Anchored = true
		end

		-- Clone DeathWave effect and place it below the dummy
		local deathWaveTemplate = game.Lighting:FindFirstChild("Assets")
			and game.Lighting.Assets:FindFirstChild("Effects")
			and game.Lighting.Assets.Effects:FindFirstChild("WaveEffects")
			and game.Lighting.Assets.Effects.WaveEffects:FindFirstChild("DeathWave")

		if deathWaveTemplate and hrp then
			local deathWaveClone = deathWaveTemplate:Clone()
			deathWaveClone.Name = "DeathWaveActive"

			-- Unanchor the cloned DeathWave so it doesn't float in the air
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

			-- Position below the dummy's feet
			local hrpPos = hrp.Position
			deathWaveClone.CFrame = CFrame.new(hrpPos.X, hrpPos.Y - 3, hrpPos.Z)

			-- Weld the DeathWave to the HumanoidRootPart so it stays with the body
			local weld = Instance.new("Weld")
			weld.Name = "DeathWaveWeld"
			weld.Part0 = hrp
			weld.Part1 = deathWaveClone
			weld.C0 = CFrame.new(0, -3, 0)
			weld.C1 = CFrame.new()
			weld.Parent = deathWaveClone

			deathWaveClone.Parent = dummy
		end

		if not anim then return end

		-- Stop any currently playing animations
		for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
			track:Stop()
		end

		-- Try Faint from character's Animations folder first
		local faintAnim = animationsFolder and animationsFolder:FindFirstChild("Faint")
		local track

		if faintAnim and faintAnim:IsA("Animation") and faintAnim.AnimationId ~= "" then
			track = anim:LoadAnimation(faintAnim)
		else
			-- Fall back to KeyframeSequence
			local faintKfs = getFaintKeyframeSequence()
			if faintKfs and faintKfs:IsA("KeyframeSequence") then
				track = anim:LoadAnimation(faintKfs)
			end
		end

		if track then
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
			-- Freeze at the last frame so the death pose stays visible
			task.spawn(function()
				local length = track.Length
				if length > 0 then
					while track.IsPlaying and track.TimePosition < length - 0.1 do
						task.wait()
					end
				end
			end)
		end
	end)
end

-- Check if any stun state is currently active
function isAnyStunActive()
	local aspects = dummy:FindFirstChild("Aspects")
	local stun = aspects and aspects:FindFirstChild("Stun")
	if not stun then return false end
	local stunned = stun:FindFirstChild("Stunned")
	local knockdown = stun:FindFirstChild("Knockdown")
	local grabbed = stun:FindFirstChild("Grabbed")
	return (stunned and stunned.Value) or (knockdown and knockdown.Value) or (grabbed and grabbed.Value)
end

-- Play idle animation
function playIdle()
	if not animator or not animationsFolder then return end
	-- Stop any current stun track
	stopTrack(currentStunTrack)
	currentStunTrack = nil
	-- Stop existing idle track if playing
	stopTrack(idleTrack)
	-- Play idle with Idle priority so action animations can override it
	idleTrack = playAnimation(animationsFolder, animator, "Idle", Enum.AnimationPriority.Idle)
end

-- Handle Stunned value change
local function onStunnedChanged(value)
	if value then
		-- Stunned: stop all and play Stunned animation
		stopAllTracks()
		currentStunTrack = playAnimation(animationsFolder, animator, "Stunned", Enum.AnimationPriority.Action)
		-- Look at the nearest player (attacker)
		local nearestChar = findNearestPlayerCharacter()
		if nearestChar then
			lookAtCharacter(nearestChar)
		end
		-- Auto-recover after 1.3 seconds (mirrors attacker's dealDamage timer for player targets)
		task.delay(1.3, function()
			local aspects = dummy:FindFirstChild("Aspects")
			local stun = aspects and aspects:FindFirstChild("Stun")
			local stunned = stun and stun:FindFirstChild("Stunned")
			if stunned and stunned:IsA("BoolValue") and stunned.Value then
				-- Only recover if not knocked down or grabbed
				local knockdown = stun:FindFirstChild("Knockdown")
				local grabbed = stun:FindFirstChild("Grabbed")
				local isStillStunned = (knockdown and knockdown.Value) or (grabbed and grabbed.Value)
				if not isStillStunned then
					stunned.Value = false
				end
			end
		end)
	else
		-- Recovered: stop stun animation, resume idle
		-- Recover effect is handled by CombatSystem, not here
		stopTrack(currentStunTrack)
		currentStunTrack = nil
		playIdle()
	end
end

-- Handle Knockdown value change
local function onKnockdownChanged(value)
	if value then
		-- Knocked down: stop all and play KnockDown animation
		stopAllTracks()
		currentStunTrack = playAnimation(animationsFolder, animator, "KnockDown", Enum.AnimationPriority.Action)
		-- Look at the nearest player (attacker)
		local nearestChar = findNearestPlayerCharacter()
		if nearestChar then
			lookAtCharacter(nearestChar)
		end
		-- Auto-recover after 1.5 seconds (mirrors attacker's knockdown timer for player targets)
		task.delay(1.5, function()
			local aspects = dummy:FindFirstChild("Aspects")
			local stun = aspects and aspects:FindFirstChild("Stun")
			local knockdown = stun and stun:FindFirstChild("Knockdown")
			if knockdown and knockdown:IsA("BoolValue") and knockdown.Value then
				-- Only recover if not grabbed
				local grabbed = stun and stun:FindFirstChild("Grabbed")
				if not (grabbed and grabbed.Value) then
					knockdown.Value = false
				end
			end
		end)
	else
		-- Recovered: stop knockdown animation, resume idle
		-- Recover effect is handled by CombatSystem, not here
		stopTrack(currentStunTrack)
		currentStunTrack = nil
		playIdle()
	end
end

-- Handle Grabbed value change
local function onGrabbedChanged(value)
	if value then
		-- Grabbed: stop all and play Grabbed animation
		stopAllTracks()
		currentStunTrack = playAnimation(animationsFolder, animator, "Grabbed", Enum.AnimationPriority.Action)
		-- Disable AutoRotate and zero WalkSpeed so the Humanoid doesn't fight the attacker's CFrame updates
		if humanoid then
			humanoid.AutoRotate = false
			humanoid.WalkSpeed = 0
		end
	else
		-- Released: stop grabbed animation, resume idle
		-- Recover effect is handled by CombatSystem, not here
		stopTrack(currentStunTrack)
		currentStunTrack = nil
		-- Restore AutoRotate and WalkSpeed
		if humanoid then
			humanoid.AutoRotate = true
			humanoid.WalkSpeed = 16
		end
		playIdle()
	end
end

-- Connect to Aspects.Stun value changes
local function connectStunListeners()
	local aspects = dummy:FindFirstChild("Aspects")
	local stun = aspects and aspects:FindFirstChild("Stun")
	if not stun then return end

	local stunned = stun:FindFirstChild("Stunned")
	local knockdown = stun:FindFirstChild("Knockdown")
	local grabbed = stun:FindFirstChild("Grabbed")

	if stunned and stunned:IsA("BoolValue") then
		stunned.Changed:Connect(onStunnedChanged)
	end
	if knockdown and knockdown:IsA("BoolValue") then
		knockdown.Changed:Connect(onKnockdownChanged)
	end
	if grabbed and grabbed:IsA("BoolValue") then
		grabbed.Changed:Connect(onGrabbedChanged)
	end
end

-- Initialize
local function init()
	if not humanoid or not animator then return end
	-- Setup death handling
	setupDeathHandling()
	-- Connect stun listeners
	connectStunListeners()
	-- Play idle animation on start
	playIdle()
end

init()