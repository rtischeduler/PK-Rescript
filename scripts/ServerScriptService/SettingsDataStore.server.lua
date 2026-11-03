-- SettingsDataStore: Delegates to PlayerDataManager's player.Settings folder
-- SettingsLoad returns a table built from the player's Settings values (already loaded by PlayerDataManager)
-- SettingsSave writes directly to the player's Settings values (triggers PlayerDataManager auto-save)

local Players = game:GetService("Players")
local SettingsSave = game.ReplicatedStorage:WaitForChild("SettingsSave")
local SettingsLoad = game.ReplicatedStorage:WaitForChild("SettingsLoad")

-- Build a settings table from the player's Settings folder
local function buildSettingsTable(player)
	local settings = player:FindFirstChild("Settings")
	if not settings then return nil end

	local data = {}

	-- UI subfolder
	local ui = settings:FindFirstChild("UI")
	if ui then
		local mv = ui:FindFirstChild("MusicVolume")
		if mv then data.MusicVolume = mv.Value end
	end

	-- Graphics subfolder
	local graphics = settings:FindFirstChild("Graphics")
	if graphics then
		local shadows = graphics:FindFirstChild("Shadows")
		if shadows then data.Shadows = shadows.Value end

		local dof = graphics:FindFirstChild("DepthOfField")
		if dof then data.DepthOfField = dof.Value end

		local blur = graphics:FindFirstChild("Blur")
		if blur then data.Blur = blur.Value end
	end

	-- Direct settings
	local screenShake = settings:FindFirstChild("ScreenShake")
	if screenShake then data.ScreenShake = screenShake.Value end

	local showHitboxes = settings:FindFirstChild("ShowHitboxes")
	if showHitboxes then data.ShowHitboxes = showHitboxes.Value end

	local keybindsToggle = settings:FindFirstChild("Keybinds")
	if keybindsToggle then data.Keybinds = keybindsToggle.Value end

	-- Keybind StringValues
	local keybindNames = {"SP1", "SP2", "SP3", "Roar", "Grab", "Escape", "Rage", "Block", "LockOn", "LockOnSwap", "SwimUp", "SwimDown"}
	for _, name in ipairs(keybindNames) do
		local kv = settings:FindFirstChild(name)
		if kv then
			data[name] = kv.Value
		end
	end

	return data
end

-- Apply a settings table to the player's Settings folder values
local function applySettingsTable(player, settingsData)
	local settings = player:FindFirstChild("Settings")
	if not settings then return end

	if type(settingsData) ~= "table" then return end

	local ui = settings:FindFirstChild("UI")
	if ui and settingsData.MusicVolume ~= nil then
		local mv = ui:FindFirstChild("MusicVolume")
		if mv then mv.Value = settingsData.MusicVolume end
	end

	local graphics = settings:FindFirstChild("Graphics")
	if graphics then
		if settingsData.Shadows ~= nil then
			local v = graphics:FindFirstChild("Shadows")
			if v then v.Value = settingsData.Shadows end
		end
		if settingsData.DepthOfField ~= nil then
			local v = graphics:FindFirstChild("DepthOfField")
			if v then v.Value = settingsData.DepthOfField end
		end
		if settingsData.Blur ~= nil then
			local v = graphics:FindFirstChild("Blur")
			if v then v.Value = settingsData.Blur end
		end
	end

	if settingsData.ScreenShake ~= nil then
		local v = settings:FindFirstChild("ScreenShake")
		if v then v.Value = settingsData.ScreenShake end
	end

	if settingsData.ShowHitboxes ~= nil then
		local v = settings:FindFirstChild("ShowHitboxes")
		if v then v.Value = settingsData.ShowHitboxes end
	end

	if settingsData.Keybinds ~= nil then
		local v = settings:FindFirstChild("Keybinds")
		if v then v.Value = settingsData.Keybinds end
	end

	-- Keybind values
	local keybindNames = {"SP1", "SP2", "SP3", "Roar", "Grab", "Escape", "Rage", "Block", "LockOn", "LockOnSwap", "SwimUp", "SwimDown"}
	for _, name in ipairs(keybindNames) do
		if settingsData[name] ~= nil then
			local v = settings:FindFirstChild(name)
			if v then v.Value = settingsData[name] end
		end
	end
end

-- Client requests saved settings: return from player's Settings folder
SettingsLoad.OnServerInvoke = function(player)
	-- Wait briefly for PlayerDataManager to create the Settings folder
	local settings = player:WaitForChild("Settings", 10)
	if not settings then return nil end
	return buildSettingsTable(player)
end

-- Client sends updated settings to save: write to player's Settings values
SettingsSave.OnServerEvent:Connect(function(player, settingsData)
	applySettingsTable(player, settingsData)
end)