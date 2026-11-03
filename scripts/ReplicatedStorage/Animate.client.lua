-- IDLE, WALK AND SPRINT ANIMATION
task.wait(0.2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local camera = workspace.CurrentCamera

-- FOV settings
local NORMAL_FOV = 70
local SPRINT_FOV = 80
local FOV_LERP_SPEED = 5  -- higher = faster transition

-- Load animations from character's Animations folder
local animationsFolder = character:WaitForChild("Animations")
local idleAnimation = animationsFolder:WaitForChild("Idle")
local walkAnimation = animationsFolder:WaitForChild("Walk")
local sprintAnimation = animationsFolder:WaitForChild("Sprint")

-- Get speed values from Animations folder
local sprintSpeedValue = animationsFolder:FindFirstChild("SprintSpeed")
local walkSpeedValue = animationsFolder:FindFirstChild("WalkSpeed")

-- Store base walk speed (humanoid's WalkSpeed at spawn, or WalkSpeed NumberValue if valid)
local baseWalkSpeed = humanoid.WalkSpeed
if walkSpeedValue and walkSpeedValue.Value > 0 then
	baseWalkSpeed = walkSpeedValue.Value
end

-- Sprint speed from NumberValue, fallback to 2.5x base walk speed
local sprintSpeed = (sprintSpeedValue and sprintSpeedValue.Value > 0) and sprintSpeedValue.Value or (baseWalkSpeed * 2.5)

-- Load animation tracks
local idleTrack = animator:LoadAnimation(idleAnimation)
local walkTrack = animator:LoadAnimation(walkAnimation)
local sprintTrack = animator:LoadAnimation(sprintAnimation)

-- Set animation priorities
idleTrack.Priority = Enum.AnimationPriority.Idle
walkTrack.Priority = Enum.AnimationPriority.Movement
sprintTrack.Priority = Enum.AnimationPriority.Movement

-- Enable looping so animations repeat continuously
idleTrack.Looped = true
walkTrack.Looped = true
sprintTrack.Looped = true

-- Sprint state tracking
local isShiftHeld = false
local runningValue = script:FindFirstChild("Running")
local lastSprinting = false

-- Stamina exhaustion lockout: prevents sprint oscillation when stamina hits 0
local staminaExhausted = false
local STAMINA_RECOVER_THRESHOLD = 0.3  -- need 30% stamina to sprint again after exhaustion

-- Stamina check: read from Aspects.Info.Stamina (server-synced)
local function getStaminaRatio()
	local aspects = character:FindFirstChild("Aspects")
	if not aspects then return 1 end
	local info = aspects:FindFirstChild("Info")
	if not info then return 1 end
	local stamina = info:FindFirstChild("Stamina")
	if not stamina then return 1 end
	local maxStamina = stamina:FindFirstChild("MaxStamina")
	if not maxStamina then return 1 end
	local maxVal = maxStamina.Value
	if maxVal <= 0 then return 1 end
	return stamina.Value / maxVal
end

-- Smooth transition times (seconds)
local FADE_IN = 0.2
local FADE_OUT = 0.3

-- Current animation state
local currentAnimState = "idle"
local justExitedSwimming = false  -- true when ground anims should use 0.7s fade-in to match swim fade-out

-- Shift key detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		isShiftHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		isShiftHeld = false
		staminaExhausted = false  -- releasing shift resets exhaustion lockout
	end
end)

-- Determine if sprinting (Shift held OR Running value is true from mobile UI)
-- Also requires stamina > 0 to sprint, and not in exhaustion lockout
local function isSprinting()
	if staminaExhausted then return false end
	return (isShiftHeld or (runningValue and runningValue.Value == true)) and getStaminaRatio() > 0
end

-- Update animations every frame
local function updateAnimations(dt)
	local isMoving = humanoid.MoveDirection.Magnitude > 0
	local forcedWalk = false
	local fwVal = character:FindFirstChild("ForceWalk")
	if fwVal then forcedWalk = fwVal.Value end
	local isSwimmingNow = character:GetAttribute("IsSwimming")
	local sprinting = not forcedWalk and not isSwimmingNow and isSprinting()
	
	-- Stamina exhaustion lockout logic
	local staminaRatio = getStaminaRatio()
	if sprinting and staminaRatio <= 0 then
		-- Ran out of stamina while sprinting: lock out sprinting until recovery
		staminaExhausted = true
		sprinting = false
	elseif staminaExhausted and staminaRatio >= STAMINA_RECOVER_THRESHOLD then
		-- Recovered enough stamina to sprint again
		staminaExhausted = false
	end
	
	-- Update WalkSpeed when sprint state changes (skip if RageActive)
	if sprinting ~= lastSprinting then
		lastSprinting = sprinting
		if not character:GetAttribute("RageActive") then
			if sprinting then
				humanoid.WalkSpeed = sprintSpeed
			else
				humanoid.WalkSpeed = baseWalkSpeed
			end
		end
	end
	
	-- If forced walk is active and currently at sprint speed, reset to walk speed
	if forcedWalk and humanoid.WalkSpeed > baseWalkSpeed then
		humanoid.WalkSpeed = baseWalkSpeed
	end
	
	-- Re-apply correct WalkSpeed if it doesn't match expected smtate
	-- (handles server restoring WalkSpeed after attacks/stuns/knockback
	-- where the server value differs from client's sprint state)
	-- Skip if RageActive — rage controls its own speed
	-- Skip if stunned/knocked down/grabbed — those systems manage WalkSpeed
	local aspects = character:FindFirstChild("Aspects")
	local stunFolder = aspects and aspects:FindFirstChild("Stun")
	local stunnedVal = stunFolder and stunFolder:FindFirstChild("Stunned")
	local knockdownVal = stunFolder and stunFolder:FindFirstChild("Knockdown")
	local grabbedVal = stunFolder and stunFolder:FindFirstChild("Grabbed")
	local isStunned = (stunnedVal and stunnedVal.Value) or (knockdownVal and knockdownVal.Value) or (grabbedVal and grabbedVal.Value)
	if not forcedWalk and not character:GetAttribute("RageActive") and not isStunned and not isSwimmingNow then
		local expectedSpeed = sprinting and sprintSpeed or baseWalkSpeed
		if humanoid.WalkSpeed ~= expectedSpeed then
			humanoid.WalkSpeed = expectedSpeed
		end
	end
	
	-- Smoothly lerp camera FOV: only increase when actually moving AND sprinting
	local isActuallySprinting = sprinting and isMoving
	local targetFOV = isActuallySprinting and SPRINT_FOV or NORMAL_FOV
	camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * math.clamp(FOV_LERP_SPEED * dt, 0, 1)
	
	-- Stop ground animations while stunned (stun animations handled by combat system)
	if isStunned then
		if idleTrack.IsPlaying then idleTrack:Stop(FADE_OUT) end
		if walkTrack.IsPlaying then walkTrack:Stop(FADE_OUT) end
		if sprintTrack.IsPlaying then sprintTrack:Stop(FADE_OUT) end
		currentAnimState = "stunned"
		-- Prevent movement while stunned
		humanoid.WalkSpeed = 0
		return
	end

	-- Reset from stunned state
	if currentAnimState == "stunned" then
		currentAnimState = "idle"
	end

	-- Stop ground animations while swimming (swim animations handled by SwimSystem)
	-- Use 0.6s fade to match SwimSystem's enter/exit fade for smooth crossfade
	if character:GetAttribute("IsSwimming") then
		local swimFade = 0.6
		if idleTrack.IsPlaying then idleTrack:Stop(swimFade) end
		if walkTrack.IsPlaying then walkTrack:Stop(swimFade) end
		if sprintTrack.IsPlaying then sprintTrack:Stop(swimFade) end
		currentAnimState = "swimming"
		return
	end

	-- Reset from swimming state
	-- Use "none" so the transition logic fires and restarts the correct ground animation
	if currentAnimState == "swimming" then
		currentAnimState = "none"
		justExitedSwimming = true  -- next ground anim play should use 0.6s fade
	end

	-- Determine target animation state
	local targetState
	if not isMoving then
		targetState = "idle"
	elseif sprinting then
		targetState = "sprint"
	else
		targetState = "walk"
	end
	
	-- Skip full transition if state hasn't changed (still adjust playback speeds)
	if targetState == currentAnimState then
		if currentAnimState == "walk" then
			walkTrack:AdjustSpeed(humanoid.WalkSpeed / baseWalkSpeed)
		elseif currentAnimState == "sprint" then
			sprintTrack:AdjustSpeed(humanoid.WalkSpeed / sprintSpeed)
		end
		return
	end
	
	currentAnimState = targetState

	-- Use 0.6s fade-in when transitioning back from swimming (matches SwimSystem exit fade)
	-- Otherwise use normal short fades
	local fadeIn = justExitedSwimming and 0.6 or FADE_IN
	justExitedSwimming = false

	-- Transition animations with smooth fades
	if targetState == "idle" then
		walkTrack:Stop(FADE_OUT)
		sprintTrack:Stop(FADE_OUT)
		if not idleTrack.IsPlaying then
			idleTrack:Play(fadeIn)
		end
	elseif targetState == "walk" then
		sprintTrack:Stop(FADE_OUT)
		idleTrack:Stop(FADE_OUT)
		if not walkTrack.IsPlaying then
			walkTrack:Play(fadeIn)
		end
		walkTrack:AdjustSpeed(humanoid.WalkSpeed / baseWalkSpeed)
	elseif targetState == "sprint" then
		walkTrack:Stop(FADE_OUT)
		idleTrack:Stop(FADE_OUT)
		if not sprintTrack.IsPlaying then
			sprintTrack:Play(fadeIn)
		end
		sprintTrack:AdjustSpeed(humanoid.WalkSpeed / sprintSpeed)
	end
end

-- CONSTANTLY UPDATE ANIMS
RunService.RenderStepped:Connect(updateAnimations)