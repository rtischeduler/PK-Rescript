-- Freecam Script
-- Toggle with Shift+P | Move with WASD | Up/Down with Q/E | Speed boost with Shift

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local freecamEnabled = false
local savedCameraType = nil

-- Movement state
local moveDirection = Vector3.new(0, 0, 0)
local currentVelocity = Vector3.new(0, 0, 0)
local baseSpeed = 50
local speedMultiplier = 1
local boostMultiplier = 3

-- Smoothing settings
local acceleration = 8
local damping = 6

-- Key tracking
local keysDown = {}

local function getMoveVector()
	local forward = (keysDown["w"] and 1 or 0) - (keysDown["s"] and 1 or 0)
	local right = (keysDown["d"] and 1 or 0) - (keysDown["a"] and 1 or 0)
	local up = (keysDown["e"] and 1 or 0) - (keysDown["q"] and 1 or 0)
	return Vector3.new(right, up, -forward)
end

local function enableFreecam()
	freecamEnabled = true
	savedCameraType = camera.CameraType
	camera.CameraType = Enum.CameraType.Scriptable

	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Freecam Enabled",
			Text = "WASD to move, Q/E for up/down, Shift to boost. Shift+P to disable.",
			Duration = 4,
		})
	end)
end

local function disableFreecam()
	freecamEnabled = false
	moveDirection = Vector3.new(0, 0, 0)
	currentVelocity = Vector3.new(0, 0, 0)
	keysDown = {}

	if savedCameraType then
		camera.CameraType = savedCameraType
		savedCameraType = nil
	else
		camera.CameraType = Enum.CameraType.Custom
	end

	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Freecam Disabled",
			Text = "Returned to normal camera.",
			Duration = 3,
		})
	end)
end

-- Toggle on Shift+P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		if freecamEnabled then
			disableFreecam()
		else
			enableFreecam()
		end
		return
	end

	if not freecamEnabled then return end

	-- Track movement keys
	local key = string.lower(input.KeyCode.Name)
	if key == "w" or key == "a" or key == "s" or key == "d" or key == "q" or key == "e" then
		keysDown[key] = true
	end

	-- Track boost
	if input.KeyCode == Enum.KeyCode.LeftShift then
		speedMultiplier = boostMultiplier
	end
end)

UserInputService.InputEnded:Connect(function(input)
	local key = string.lower(input.KeyCode.Name)
	if key == "w" or key == "a" or key == "s" or key == "d" or key == "q" or key == "e" then
		keysDown[key] = false
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		speedMultiplier = 1
	end
end)

-- Smooth camera movement using render step
local RENDER_PRIORITY = Enum.RenderPriority.Camera.Value

RunService:BindToRenderStep("FreecamUpdate", RENDER_PRIORITY, function(dt)
	if not freecamEnabled then return end

	-- Mouse look (right-click drag to rotate, or always allow mouse delta)
	local mouseDelta = UserInputService:GetMouseDelta()
	if mouseDelta.Magnitude > 0 then
		local currentRotation = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + camera.CFrame.LookVector)
		local rx, ry, rz = currentRotation:ToEulerAnglesYXZ()
		ry = ry - mouseDelta.X * 0.005
		rx = math.clamp(rx - mouseDelta.Y * 0.005, -math.rad(89), math.rad(89))
		local newCFrame = CFrame.fromEulerAnglesYXZ(rx, ry, rz) + camera.CFrame.Position
		camera.CFrame = newCFrame
	end

	-- Calculate desired movement direction in camera space
	local moveVec = getMoveVector()
	if moveVec.Magnitude > 0 then
		moveVec = moveVec.Unit
	end

	-- Transform movement by camera orientation
	local cameraCFrame = camera.CFrame
	local desiredVelocity = (cameraCFrame:VectorToWorldSpace(moveVec)) * baseSpeed * speedMultiplier

	-- Smooth acceleration/damping
	currentVelocity = currentVelocity:Lerp(desiredVelocity, math.clamp(dt * acceleration, 0, 1))

	-- Apply damping when no input
	if moveVec.Magnitude == 0 then
		currentVelocity = currentVelocity:Lerp(Vector3.new(0, 0, 0), math.clamp(dt * damping, 0, 1))
	end

	-- Move the camera
	camera.CFrame = camera.CFrame + currentVelocity * dt
end)

-- Clean up if the script is destroyed
script.Destroying:Connect(function()
	if freecamEnabled then
		disableFreecam()
	end
end)
