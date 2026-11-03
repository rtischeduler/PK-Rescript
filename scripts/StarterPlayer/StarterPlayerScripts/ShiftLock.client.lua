local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local shiftLockOn = false

local function updateShiftLock()
	if not player.Character then return end
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if shiftLockOn then
		humanoid.AutoRotate = false
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local lookDir = camera.CFrame.LookVector
			local flatDir = Vector3.new(lookDir.X, 0, lookDir.Z)
			if flatDir.Magnitude > 0 then
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + flatDir)
			end
		end
	else
		humanoid.AutoRotate = true
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		shiftLockOn = not shiftLockOn
	end
end)

RunService.RenderStepped:Connect(function()
	updateShiftLock()
end)

player.CharacterAdded:Connect(function(char)
	shiftLockOn = false
end)