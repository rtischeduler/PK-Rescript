--[[
	SwimSystem — Complete rewrite with custom animation tweening

	- Smooth tween IN when entering water (custom easing curve)
	- Smooth tween OUT when exiting water (custom easing curve)
	- SwimIdle plays when not moving in water
	- Swim plays when moving in water
	- Smooth crossfade between Swim and SwimIdle
	- LinearVelocity for movement + gravity cancellation
	- AlignOrientation keeps character upright
	- Mobile support (SwimUp / SwimDown buttons)
	- Server sync via SwimRemote
	- Terrain climbing + floor checking
	- Morph / respawn safe
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local swimRemote = ReplicatedStorage:FindFirstChild("SwimRemote")
local keybindModule = ReplicatedStorage:FindFirstChild("KeybindConfig")
local KeybindConfig = keybindModule and require(keybindModule) or {
	SwimUp = Enum.KeyCode.One,
	SwimDown = Enum.KeyCode.Three,
}

-- ==================== SETTINGS ====================
local SWIM_SPEED = 28
local SWIM_SPRINT_MULTIPLIER = 1.8
local ACCEL = 8
local ENTER_FADE = 0.6
local EXIT_FADE = 0.6
local CROSSFADE = 0.4

-- ==================== EASING ====================
local function easeInOutCubic(t)
	return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2)^3 / 2
end

-- ==================== SHARED INPUT ====================
local swimUp = false
local swimDown = false

-- ==================== PER-CHARACTER STATE ====================
local isSwimming = false
local currentVel = Vector3.zero
local swimTrack = nil
local swimIdleTrack = nil
local charConn = nil
local currentChar = nil
local animState = "none"

local swimAttachment = nil
local linearVel = nil
local alignOrient = nil
local savedWalkSpeed = nil

-- ==================== ANIMATION TWEEN ENGINE ====================
-- Tweens animation weights frame-by-frame with custom easing curves.
-- This gives full control over enter/exit/crossfade transitions
-- instead of relying on Roblox's built-in fade which only does linear.

local activeTweens = {} -- [track] = { startWeight, targetWeight, duration, elapsed, easingFunc }

local function startAnimTween(track, targetWeight, duration, easingFunc)
	if not track then return end
	if targetWeight > 0 and not track.IsPlaying then
		track:Play(0, 0) -- start playing at weight 0; we tween the weight up
	end
	activeTweens[track] = {
		startWeight = track.WeightCurrent,
		targetWeight = targetWeight,
		duration = duration,
		elapsed = 0,
		easingFunc = easingFunc or easeInOutCubic,
	}
end

local function stopAnimTween(track)
	activeTweens[track] = nil
end

local function updateAnimTweens(dt)
	local completed = {}
	for track, tween in pairs(activeTweens) do
		tween.elapsed += dt
		local t = math.clamp(tween.elapsed / tween.duration, 0, 1)
		local easedT = tween.easingFunc(t)
		local weight = tween.startWeight + (tween.targetWeight - tween.startWeight) * easedT
		track:AdjustWeight(weight)

		if t >= 1 then
			completed[track] = true
			if tween.targetWeight <= 0 and track.IsPlaying then
				track:Stop()
			end
		end
	end
	for track, _ in pairs(completed) do
		activeTweens[track] = nil
	end
end

-- ==================== WATER DETECTION ====================

local function getWaterSpots()
	local spots = {}
	for _, desc in workspace:GetDescendants() do
		if desc:IsA("BasePart") and desc.Name == "WaterSpot" then
			table.insert(spots, desc)
		end
	end
	return spots
end

local function isUnderwater(pos, waterSpots, hrpSize, currentlySwimming)
	for _, spot in ipairs(waterSpots) do
		local surfaceY = spot.Position.Y + spot.Size.Y * 0.5
		local threshold = surfaceY + hrpSize.Y * 0.5
		if currentlySwimming then
			threshold = threshold + 1 -- hysteresis to prevent surface flicker
		end
		if pos.Y <= threshold then
			return true
		end
	end
	return false
end

local function getWaterSurfaceY(waterSpots)
	local highestY = nil
	for _, spot in ipairs(waterSpots) do
		local surfaceY = spot.Position.Y + spot.Size.Y * 0.5
		if highestY == nil or surfaceY > highestY then
			highestY = surfaceY
		end
	end
	return highestY
end

-- ==================== CAMERA-RELATIVE MOVEMENT ====================

local function getCameraMoveDirection()
	local camera = workspace.CurrentCamera
	if not camera then return Vector3.zero end

	local fwd, right = 0, 0
	if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then fwd += 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then fwd -= 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then right += 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then right -= 1 end

	if fwd == 0 and right == 0 then return Vector3.zero end

	local camLook = camera.CFrame.LookVector
	local camRight = camera.CFrame.RightVector
	camLook = Vector3.new(camLook.X, 0, camLook.Z)
	camRight = Vector3.new(camRight.X, 0, camRight.Z)
	if camLook.Magnitude > 0 then camLook = camLook.Unit end
	if camRight.Magnitude > 0 then camRight = camRight.Unit end

	local worldMove = camLook * fwd + camRight * right
	if worldMove.Magnitude > 0 then worldMove = worldMove.Unit end
	return worldMove
end

-- ==================== MOBILE BUTTONS ====================

local function findMobileButton(name)
	local pgui = player:FindFirstChild("PlayerGui")
	if not pgui then return nil end

	local gameGui = pgui:FindFirstChild("GameGui")
	if gameGui then
		local charFrame = gameGui:FindFirstChild("Character")
		if charFrame then
			local cooldowns = charFrame:FindFirstChild("Cooldowns")
			if cooldowns then
				local mobileFrame = cooldowns:FindFirstChild("Mobile")
				if mobileFrame then
					local aspects = mobileFrame:FindFirstChild("Aspects")
					if aspects then
						local btn = aspects:FindFirstChild(name)
						if btn and btn:IsA("ImageButton") then
							return btn
						end
					end
				end
			end
		end
	end

	for _, desc in pgui:GetDescendants() do
		if desc.Name == name and desc:IsA("ImageButton") then
			if not string.find(desc:GetFullName(), "Keybinds") then
				return desc
			end
		end
	end
	return nil
end

local function connectMobileButton(btn, setFlag)
	if not btn then return nil end
	local activeInput = nil
	local conns = {}

	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			activeInput = input
			setFlag(true)
		end
	end

	table.insert(conns, btn.InputBegan:Connect(onInputBegan))
	for _, child in btn:GetDescendants() do
		if child:IsA("GuiButton") then
			table.insert(conns, child.InputBegan:Connect(onInputBegan))
		end
	end

	table.insert(conns, UserInputService.InputEnded:Connect(function(input)
		if input == activeInput then
			activeInput = nil
			setFlag(false)
		end
	end))

	-- Return cleanup function so old connections can be disconnected on respawn
	return function()
		for _, c in ipairs(conns) do
			c:Disconnect()
		end
		if activeInput then
			setFlag(false)
		end
	end
end

-- ==================== CLEANUP ====================

local function cleanupCharacter()
	if charConn then
		charConn:Disconnect()
		charConn = nil
	end
	if swimTrack then
		stopAnimTween(swimTrack)
		if swimTrack.IsPlaying then swimTrack:Stop() end
		swimTrack = nil
	end
	if swimIdleTrack then
		stopAnimTween(swimIdleTrack)
		if swimIdleTrack.IsPlaying then swimIdleTrack:Stop() end
		swimIdleTrack = nil
	end
	activeTweens = {}
	if linearVel then linearVel:Destroy() linearVel = nil end
	if alignOrient then alignOrient:Destroy() alignOrient = nil end
	if swimAttachment then swimAttachment:Destroy() swimAttachment = nil end
	if currentChar then
		currentChar:SetAttribute("IsSwimming", false)
		-- Re-enable default Animate script on cleanup
		local animateScript = currentChar:FindFirstChild("Animate")
		if animateScript then
			animateScript.Disabled = false
		end
		local hum = currentChar:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
		local hrp = currentChar:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end
	end
	isSwimming = false
	currentVel = Vector3.zero
	animState = "none"
end

-- ==================== SETUP CHARACTER ====================

local function setupCharacter(character)
	print("[SwimSystem] setupCharacter called for", character.Name)
	cleanupCharacter()
	currentChar = character

	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid or not humanoid:IsA("Humanoid") then
		print("[SwimSystem] ERROR: Humanoid not found!")
		return
	end

	local animator = humanoid:WaitForChild("Animator", 5)
	if not animator or not animator:IsA("Animator") then
		print("[SwimSystem] ERROR: Animator not found!")
		return
	end

	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp or not hrp:IsA("BasePart") then
		print("[SwimSystem] ERROR: HumanoidRootPart not found!")
		return
	end

	-- Load swim animations from the character's Animations folder
	-- Use WaitForChild with timeout so animations are found even if folder loads late
	local animations = character:FindFirstChild("Animations")
	if not animations then
		print("[SwimSystem] Animations folder not found immediately, waiting...")
		animations = character:WaitForChild("Animations", 5)
	end
	if animations then
		print("[SwimSystem] Animations folder found!")
		local swimAnim = animations:FindFirstChild("Swim")
		if not swimAnim then
			swimAnim = animations:WaitForChild("Swim", 3)
		end
		local swimIdleAnim = animations:FindFirstChild("SwimIdle")
		if not swimIdleAnim then
			swimIdleAnim = animations:WaitForChild("SwimIdle", 3)
		end
		print("[SwimSystem] Swim found:", swimAnim and swimAnim:IsA("Animation"), "id:", swimAnim and swimAnim.AnimationId or "NIL")
		print("[SwimSystem] SwimIdle found:", swimIdleAnim and swimIdleAnim:IsA("Animation"), "id:", swimIdleAnim and swimIdleAnim.AnimationId or "NIL")

		-- Check for valid (non-empty) AnimationId — some kaiju have empty Swim or SwimIdle
		local swimValid = swimAnim and swimAnim:IsA("Animation") and swimAnim.AnimationId ~= ""
		local swimIdleValid = swimIdleAnim and swimIdleAnim:IsA("Animation") and swimIdleAnim.AnimationId ~= ""
		print("[SwimSystem] swimValid:", swimValid, "swimIdleValid:", swimIdleValid)

		-- If only one animation has a valid ID, use it for both states
		if swimValid and not swimIdleValid then
			swimIdleAnim = swimAnim
			swimIdleValid = true
			print("[SwimSystem] Using Swim anim for both states")
		elseif swimIdleValid and not swimValid then
			swimAnim = swimIdleAnim
			swimValid = true
			print("[SwimSystem] Using SwimIdle anim for both states")
		end

		if swimValid then
			swimTrack = animator:LoadAnimation(swimAnim)
			swimTrack.Priority = Enum.AnimationPriority.Action4
			swimTrack.Looped = true
			print("[SwimSystem] swimTrack loaded, AnimationId:", swimAnim.AnimationId)
		else
			print("[SwimSystem] WARNING: swimTrack NOT loaded (no valid Swim animation)")
		end
		if swimIdleValid then
			swimIdleTrack = animator:LoadAnimation(swimIdleAnim)
			swimIdleTrack.Priority = Enum.AnimationPriority.Action4
			swimIdleTrack.Looped = true
			print("[SwimSystem] swimIdleTrack loaded, AnimationId:", swimIdleAnim.AnimationId)
		else
			print("[SwimSystem] WARNING: swimIdleTrack NOT loaded (no valid SwimIdle animation)")
		end
	else
		print("[SwimSystem] ERROR: Animations folder not found after waiting!")
	end

	local waterSpots = getWaterSpots()
	local lastRefresh = 0

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local function updateRayFilter()
		rayParams.FilterDescendantsInstances = {character}
		for _, spot in ipairs(waterSpots) do
			table.insert(rayParams.FilterDescendantsInstances, spot)
		end
	end
	updateRayFilter()

	charConn = RunService.Heartbeat:Connect(function(dt)
		if currentChar ~= character then return end
		if not hrp or not hrp.Parent then return end
		if not humanoid or not humanoid.Parent then return end

		-- Always update animation tweens (handles exit fades even after leaving water)
		updateAnimTweens(dt)

		-- Refresh water spots every 5 seconds
		lastRefresh += dt
		if lastRefresh > 5 then
			lastRefresh = 0
			waterSpots = getWaterSpots()
			updateRayFilter()
		end

		local pos = hrp.Position
		local hrpSize = hrp.Size
		local inWater = isUnderwater(pos, waterSpots, hrpSize, isSwimming)

		-- ===== ENTER WATER =====
		if inWater and not isSwimming then
			isSwimming = true
			currentVel = Vector3.zero
			character:SetAttribute("IsSwimming", true)
			print("[SwimSystem] ENTERING WATER — swimTrack:", swimTrack ~= nil, "swimIdleTrack:", swimIdleTrack ~= nil)

			-- Start both tracks at weight 0, then tween idle in with custom easing
			-- Save and reset WalkSpeed so Animate script re-captures correct base on restart
			local animFolder = character:FindFirstChild("Animations")
			local wsVal = animFolder and animFolder:FindFirstChild("WalkSpeed")
			local baseSpeed = (wsVal and wsVal.Value > 0) and wsVal.Value or 16
			local ssVal = animFolder and animFolder:FindFirstChild("SprintSpeed")
			local sprintSpd = (ssVal and ssVal.Value > 0) and ssVal.Value or (baseSpeed * 2.5)
			-- If currently at sprint speed, reset to base before saving
			if humanoid.WalkSpeed >= sprintSpd * 0.9 then
				savedWalkSpeed = baseSpeed
			else
				savedWalkSpeed = humanoid.WalkSpeed
			end
			humanoid.WalkSpeed = savedWalkSpeed

			-- Disable default Animate script so it doesn't override swim animations
			local animateScript = character:FindFirstChild("Animate")
			if animateScript then
				animateScript.Disabled = true
				print("[SwimSystem] Disabled default Animate script, baseWalkSpeed saved as:", savedWalkSpeed)
			end

			if swimIdleTrack then
				swimIdleTrack:Play(0, 1)
				swimIdleTrack:AdjustWeight(1)
				startAnimTween(swimIdleTrack, 1, ENTER_FADE, easeInOutCubic)
				print("[SwimSystem] Playing swimIdleTrack at full weight")
			else
				print("[SwimSystem] WARNING: swimIdleTrack is nil, no idle animation to play!")
			end
			if swimTrack then
				swimTrack:Play(0, 1)
				swimTrack:AdjustWeight(0)
				-- swim stays at weight 0 until the character moves
				print("[SwimSystem] swimTrack loaded at weight 0 (will tween in on movement)")
			else
				print("[SwimSystem] WARNING: swimTrack is nil, no swim animation to play!")
			end
			animState = "idle"

			-- Stop all default animation tracks to prevent interference
			if swimIdleTrack and swimTrack then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					if track ~= swimTrack and track ~= swimIdleTrack then
						track:Stop(0)
						print("[SwimSystem] Stopped interfering track:", track.Name)
					end
				end
			end

			-- Attachment on HRP for both constraints
			swimAttachment = Instance.new("Attachment")
			swimAttachment.Name = "SwimAttachment"
			swimAttachment.Parent = hrp

			-- LinearVelocity handles ALL movement + gravity cancellation
			linearVel = Instance.new("LinearVelocity")
			linearVel.Attachment0 = swimAttachment
			linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
			linearVel.VectorVelocity = Vector3.zero
			linearVel.MaxForce = math.huge
			linearVel.Parent = hrp

			-- AlignOrientation keeps character upright
			alignOrient = Instance.new("AlignOrientation")
			alignOrient.Mode = Enum.OrientationAlignmentMode.OneAttachment
			alignOrient.Attachment0 = swimAttachment
			alignOrient.MaxTorque = math.huge
			alignOrient.MaxAngularVelocity = math.huge
			alignOrient.Responsiveness = 50
			alignOrient.CFrame = hrp.CFrame - hrp.CFrame.Position
			alignOrient.Parent = hrp

			-- Disable humanoid ground controller
			humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
			humanoid.PlatformStand = true
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)

			if swimRemote then
				swimRemote:FireServer(true)
			end

		-- ===== EXIT WATER =====
		elseif not inWater and isSwimming then
			isSwimming = false
			currentVel = Vector3.zero
			character:SetAttribute("IsSwimming", false)

			-- Tween both animations OUT with custom easing
			if swimTrack then
				startAnimTween(swimTrack, 0, EXIT_FADE, easeInOutCubic)
			end
			if swimIdleTrack then
				startAnimTween(swimIdleTrack, 0, EXIT_FADE, easeInOutCubic)
			end
			animState = "none"

			-- Zero velocity BEFORE destroying constraints to prevent flying
			if hrp and hrp.Parent then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end

			-- Destroy constraints
			if linearVel then linearVel:Destroy() linearVel = nil end
			if alignOrient then alignOrient:Destroy() alignOrient = nil end
			if swimAttachment then swimAttachment:Destroy() swimAttachment = nil end

			-- Restore WalkSpeed to saved base BEFORE re-enabling Animate script
			-- (Animate restarts and captures humanoid.WalkSpeed as baseWalkSpeed)
			if savedWalkSpeed then
				humanoid.WalkSpeed = savedWalkSpeed
			end

			-- Re-enable default Animate script
			local animateScript = character:FindFirstChild("Animate")
			if animateScript then
				animateScript.Disabled = false
			end

			-- Restore humanoid states
			humanoid.PlatformStand = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)

			-- Force humanoid out of Physics state back to ground control
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

			-- Zero velocity again after state change to be safe
			if hrp and hrp.Parent then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end

			if swimRemote then
				swimRemote:FireServer(false)
			end
		end

		-- ===== SWIMMING PHYSICS + ANIMATION =====
		if isSwimming and linearVel and alignOrient then

			-- Sprint check
			local isSprintSwim = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			if not isSprintSwim and currentChar then
				local animate = currentChar:FindFirstChild("Animate")
				local runningVal = animate and animate:FindFirstChild("Running")
				if runningVal and runningVal.Value then
					isSprintSwim = true
				end
			end
			local sprintMult = isSprintSwim and SWIM_SPRINT_MULTIPLIER or 1.0
			local speed = SWIM_SPEED * sprintMult

			-- Horizontal movement (keyboard primary, mobile joystick fallback)
			local moveDir = getCameraMoveDirection()
			if moveDir.Magnitude < 0.1 and UserInputService.TouchEnabled then
				moveDir = humanoid.MoveDirection
			end

			-- Vertical movement
			local targetVelY = 0
			if swimUp then
				local surfaceY = getWaterSurfaceY(waterSpots)
				if surfaceY and pos.Y >= surfaceY + hrpSize.Y * 0.25 then
					targetVelY = 0
					currentVel = Vector3.new(currentVel.X, 0, currentVel.Z)
				else
					targetVelY += speed
				end
			end
			if swimDown then
				targetVelY -= speed
			end

			-- Terrain climbing: auto-rise when swimming into terrain
			if moveDir.Magnitude > 0.1 and not swimDown then
				local rayOrigin = pos - Vector3.new(0, hrpSize.Y * 0.3, 0)
				local rayDir = moveDir.Unit * (hrpSize.X * 0.5 + 5)
				local hit = workspace:Raycast(rayOrigin, rayDir, rayParams)
				if hit and hit.Instance and hit.Instance.Name ~= "WaterSpot" then
					targetVelY = speed
				end
			end

			-- Floor check: prevent going through ground
			local downHit = workspace:Raycast(pos, Vector3.new(0, -(hrpSize.Y * 0.5 + 2), 0), rayParams)
			if downHit and downHit.Instance and downHit.Instance.Name ~= "WaterSpot" then
				local feetY = pos.Y - hrpSize.Y * 0.5
				if feetY <= downHit.Position.Y + 0.5 then
					targetVelY = math.max(targetVelY, 0)
				end
			end

			-- Build target velocity
			local targetVel = Vector3.new(moveDir.X * speed, targetVelY, moveDir.Z * speed)

			-- Smooth exponential lerp
			local alpha = 1 - math.exp(-dt * ACCEL)
			currentVel = currentVel:Lerp(targetVel, alpha)

			-- Apply velocity
			linearVel.VectorVelocity = currentVel

			-- Update orientation: face movement direction, stay upright
			if moveDir.Magnitude > 0.1 then
				alignOrient.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(moveDir.X, 0, moveDir.Z))
			else
				local look = hrp.CFrame.LookVector
				local flatLook = Vector3.new(look.X, 0, look.Z)
				if flatLook.Magnitude > 0.01 then
					alignOrient.CFrame = CFrame.lookAt(Vector3.zero, flatLook.Unit)
				end
			end

			-- ===== ANIMATION CROSSFADE =====
			-- Both tracks are always playing while in water;
			-- we tween their weights for perfectly smooth transitions.
			local isMoving = currentVel.Magnitude > 1.0
			if isMoving and animState ~= "swim" then
				-- Crossfade: swim IN, idle OUT
				if swimTrack then
					swimTrack:Play(0, 1)
					swimTrack:AdjustWeight(1)
					startAnimTween(swimTrack, 1, CROSSFADE, easeInOutCubic)
				end
				if swimIdleTrack then
					startAnimTween(swimIdleTrack, 0, CROSSFADE, easeInOutCubic)
				end
				animState = "swim"
			elseif not isMoving and animState ~= "idle" then
				-- Crossfade: idle IN, swim OUT
				if swimIdleTrack then
					swimIdleTrack:Play(0, 1)
					swimIdleTrack:AdjustWeight(1)
					startAnimTween(swimIdleTrack, 1, CROSSFADE, easeInOutCubic)
				end
				if swimTrack then
					startAnimTween(swimTrack, 0, CROSSFADE, easeInOutCubic)
				end
				animState = "idle"
			end
		end
	end)
end

-- ==================== GLOBAL INPUT ====================

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == KeybindConfig.SwimUp then
		swimUp = true
	elseif input.KeyCode == KeybindConfig.SwimDown then
		swimDown = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == KeybindConfig.SwimUp then
		swimUp = false
	elseif input.KeyCode == KeybindConfig.SwimDown then
		swimDown = false
	end
end)

-- ==================== MOBILE BUTTONS ====================

local mobileCleanups = {}
local lastUpBtn = nil
local lastDownBtn = nil

task.spawn(function()
	while true do
		local swimUpBtn = findMobileButton("SwimUp")
		local swimDownBtn = findMobileButton("SwimDown")
		if swimUpBtn and swimDownBtn then
			-- Detect new button instances (respawn recreates GameGui with ResetOnSpawn)
			if swimUpBtn ~= lastUpBtn then
				if mobileCleanups.up then
					mobileCleanups.up()
				end
				mobileCleanups.up = connectMobileButton(swimUpBtn, function(v) swimUp = v end)
				lastUpBtn = swimUpBtn
			end
			if swimDownBtn ~= lastDownBtn then
				if mobileCleanups.down then
					mobileCleanups.down()
				end
				mobileCleanups.down = connectMobileButton(swimDownBtn, function(v) swimDown = v end)
				lastDownBtn = swimDownBtn
			end
		end
		task.wait(1)
	end
end)

-- ==================== CHARACTER DETECTION ====================

task.spawn(function()
	local lastChar = nil
	while true do
		local char = player.Character
		if char and char ~= lastChar then
			lastChar = char
			task.wait(0.2)
			setupCharacter(char)
		end
		task.wait(0.1)
	end
end)

player.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	setupCharacter(char)
end)