-- StaminaBarHandler: Handles the player's stamina bar display
-- Properly reconnects on every character respawn
-- Reads from Aspects.Info.Stamina (synced from server)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local HealthStats = script.Parent
local StaminaBar = HealthStats:WaitForChild("Stamina")
local Clipping = StaminaBar:WaitForChild("Clipping")
local Top = Clipping:WaitForChild("Top")
local TXT = StaminaBar:WaitForChild("TXT")

print("[StaminaBarHandler] Script loaded, waiting for character...")

-- Resizes the Clipping frame to the stamina ratio and counter-resizes
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

local function updateStaminaBar(staminaValue, maxStaminaValue)
	local ratio = (maxStaminaValue > 0) and (staminaValue / maxStaminaValue) or 0
	resizeCustomLoadingBarX(ratio)
	TXT.Text = math.floor(staminaValue) .. "/" .. math.floor(maxStaminaValue)
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
	print("[StaminaBarHandler] Character added: " .. character.Name)
	clearConnections()

	-- Wait for the Aspects folder (contains stamina data)
	local aspects = character:WaitForChild("Aspects", 30)
	if not aspects or not character.Parent then
		warn("[StaminaBarHandler] Aspects not found for character")
		return
	end

	local info = aspects:WaitForChild("Info", 10)
	if not info or not character.Parent then
		warn("[StaminaBarHandler] Info not found in Aspects")
		return
	end

	local staminaValue = info:WaitForChild("Stamina", 10)
	if not staminaValue or not character.Parent then
		warn("[StaminaBarHandler] Stamina not found in Info")
		return
	end

	local maxStaminaValue = staminaValue:WaitForChild("MaxStamina", 10)
	if not maxStaminaValue or not character.Parent then
		warn("[StaminaBarHandler] MaxStamina not found")
		return
	end

	print("[StaminaBarHandler] Connected! Stamina: " .. staminaValue.Value .. "/" .. maxStaminaValue.Value)

	-- Update immediately
	local function refresh()
		updateStaminaBar(staminaValue.Value, maxStaminaValue.Value)
	end

	refresh()

	-- Connect to value changes (event-driven, no polling)
	table.insert(connections, staminaValue.Changed:Connect(refresh))
	table.insert(connections, maxStaminaValue.Changed:Connect(refresh))
end

-- Re-hook every time the character changes (handles respawns)
Player.CharacterAdded:Connect(hookCharacter)

-- Hook the current character if one already exists
if Player.Character then
	task.spawn(hookCharacter, Player.Character)
end