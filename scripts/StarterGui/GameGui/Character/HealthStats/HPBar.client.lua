--HEALTH BAR
-- Matches the resize logic from the old SetupHPandAttacks script
local Player = game.Players.LocalPlayer

-- Wait for character with Aspects (same as old SetupHPandAttacks script)
local Char
while true do
	Char = Player.Character
	if Char and Char:FindFirstChild("Aspects") then
		break
	end
	task.wait()
end

local Aspects = Char:WaitForChild("Aspects")
local HealthInfo = Aspects:WaitForChild("Info"):WaitForChild("Health")
local MaxHealthObj = HealthInfo:WaitForChild("MaxHealth")

local HealthBar = script.Parent.Health
local Clipping = HealthBar.Clipping
local Top = Clipping.Top

-- resizeCustomLoadingBarX (ported from old SetupHPandAttacks script)
-- Resizes the Clipping frame to the health ratio AND counter-resizes
-- the Top image to 1/ratio so it doesn't distort when clipped.
local function resizeCustomLoadingBarX(ratio, clippingFrame, topFrame)
	clippingFrame.Size = UDim2.new(ratio, clippingFrame.Size.X.Offset, clippingFrame.Size.Y.Scale, clippingFrame.Size.Y.Offset)
	if ratio > 0 then
		local scale = 1 / ratio
		topFrame.Size = UDim2.new(scale, topFrame.Size.X.Offset, topFrame.Size.Y.Scale, topFrame.Size.Y.Offset)
	else
		topFrame.Size = UDim2.new(0, topFrame.Size.X.Offset, topFrame.Size.Y.Scale, topFrame.Size.Y.Offset)
	end
end

-- DO NOT TWEEN
local function HealthBarUpdate()
	local healthValue = HealthInfo.Value
	local maxHealthValue = MaxHealthObj.Value
	local ratio = (maxHealthValue > 0) and (healthValue / maxHealthValue) or 0
	-- Resize Clipping to the ratio and counter-resize Top to prevent distortion
	resizeCustomLoadingBarX(ratio, Clipping, Top)
	-- SET TEXT
	HealthBar.TXT.Text = math.floor(healthValue) .. "/" .. math.floor(maxHealthValue)
end

HealthBarUpdate()

-- Update when health values change (event-driven, no polling loop)
HealthInfo.Changed:Connect(HealthBarUpdate)
MaxHealthObj.Changed:Connect(HealthBarUpdate)