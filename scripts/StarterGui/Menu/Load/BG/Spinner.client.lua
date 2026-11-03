local RunService = game:GetService("RunService")
local bg = script.Parent
local rotation = 0

RunService.RenderStepped:Connect(function(dt)
	rotation = (rotation - 180 * dt) % 360
	bg.Rotation = rotation
end)