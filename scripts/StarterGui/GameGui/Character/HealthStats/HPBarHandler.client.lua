-- HPBarHandler: Handles the player's health bar display
-- Properly reconnects on every character respawn
-- Reads from Aspects.Info.Health (synced from Humanoid.Health by HealthSync server script)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local HealthStats = script.Parent
local HealthBar = HealthStats:WaitForChild("Health")
local Clipping = HealthBar:WaitForChild("Clipping")
local Top = Clipping:WaitForChild("Top")
local TXT = HealthBar:WaitForChild("TXT")

print("[HPBarHandler] Script loaded, waiting for character...")

-- Resizes the Clipping frame to the health ratio and counter-resizes
-- the Top image to prevent distortion when clipped
local function resizeCustomLoadingBarX(ratio)
	ratio = math.clamp(ratio, 0, 1)
	Clipping.Size = UDim2.new(ratio, Clipping.Size.X.Offset, Clipping.Size.Y.Scale, Clipping.Size.Y.Offset)
	if ratio > 0 then
		local scale = 1 / ratio
		Top.Size = UDim2.new(scale, Top.Size.X.Offset, Top.Size.Y.Scale, Top.Size.Y.Offset)
	else
		Top.Size = UDim2.new(0, Top.Size.X.Offset, Top.Size.Y.Scale, Top.Size.Y.Offset)
	end
end

local function updateHealthBar(healthValue, maxHealthValue)
	local ratio = (maxHealthValue > 0) and (healthValue / maxHealthValue) or 0
	resizeCustomLoadingBarX(ratio)
	TXT.Text = math.floor(healthValue) .. "/" .. math.floor(maxHealthValue)
end

-- Track active connections so we can clean up on respawn
local connections = {}

local function clearConnections()
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}
end

local function hookCharacter(character)
	print("[HPBarHandler] Character added: " .. character.Name)
	clearConnections()

	-- Wait for the Aspects folder (contains health data)
	local aspects = character:WaitForChild("Aspects", 30)
	if not aspects or not character.Parent then
		warn("[HPBarHandler] Aspects not found for character")
		return
	end

	local info = aspects:WaitForChild("Info", 10)
	if not info or not character.Parent then
		warn("[HPBarHandler] Info not found in Aspects")
		return
	end

	local healthValue = info:WaitForChild("Health", 10)
	if not healthValue or not character.Parent then
		warn("[HPBarHandler] Health not found in Info")
		return
	end

	local maxHealthValue = healthValue:WaitForChild("MaxHealth", 10)
	if not maxHealthValue or not character.Parent then
		warn("[HPBarHandler] MaxHealth not found")
		return
	end

	print("[HPBarHandler] Connected! HP: " .. healthValue.Value .. "/" .. maxHealthValue.Value)

	-- Update immediately
	local function refresh()
		updateHealthBar(healthValue.Value, maxHealthValue.Value)
	end

	refresh()

	-- Connect to value changes (event-driven, no polling)
	table.insert(connections, healthValue.Changed:Connect(refresh))
	table.insert(connections, maxHealthValue.Changed:Connect(refresh))
end

-- Re-hook every time the character changes (handles respawns)
Player.CharacterAdded:Connect(hookCharacter)

-- Hook the current character if one already exists
if Player.Character then
	task.spawn(hookCharacter, Player.Character)
end
