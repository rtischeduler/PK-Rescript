-- KeybindDataStore: Delegates to PlayerDataManager's player.Settings folder
-- KeybindLoad returns keybind values from the player's Settings (already loaded by PlayerDataManager)
-- KeybindSave writes keybind values to the player's Settings (triggers PlayerDataManager auto-save)

local Players = game:GetService("Players")
local KeybindSave = game.ReplicatedStorage:WaitForChild("KeybindSave")
local KeybindLoad = game.ReplicatedStorage:WaitForChild("KeybindLoad")

local KEYBIND_NAMES = {"SP1", "SP2", "SP3", "Roar", "Grab", "Escape", "Rage", "Block", "LockOn", "LockOnSwap", "SwimUp", "SwimDown"}

-- Client requests saved keybinds: read from player's Settings folder
KeybindLoad.OnServerInvoke = function(player)
	local settings = player:WaitForChild("Settings", 10)
	if not settings then return nil end

	local data = {}
	for _, name in ipairs(KEYBIND_NAMES) do
		local kv = settings:FindFirstChild(name)
		if kv then
			data[name] = kv.Value
		end
	end
	return data
end

-- Client sends updated keybinds to save: write to player's Settings values
KeybindSave.OnServerEvent:Connect(function(player, keybindData)
	if type(keybindData) ~= "table" then return end

	local settings = player:FindFirstChild("Settings")
	if not settings then return end

	for _, name in ipairs(KEYBIND_NAMES) do
		if keybindData[name] ~= nil then
			local kv = settings:FindFirstChild(name)
			if kv then
				kv.Value = keybindData[name]
			end
		end
	end
end)