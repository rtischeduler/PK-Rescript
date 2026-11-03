-- PlayerDataManager: Server-side player data initialization and persistence
-- Creates Inventory and Settings folders on each player with all required Values.
-- Loads/saves data via DataStores. Handles UpdateValue RemoteEvent for settings changes.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[PlayerDataManager] Script started, requiring XPModule...")

local XPModule = require(ReplicatedStorage:WaitForChild("XPModule"))

print("[PlayerDataManager] XPModule loaded successfully")

-- addXP: Adds XP to a player's inventory, processes level-ups and rank updates.
-- This is the single server-authoritative function for granting XP.
local function addXP(player, amount)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local xpFolder = inventory:FindFirstChild("XP")
	if not xpFolder then return end

	local newLevel, newXP, newXPToEarn, newRank = XPModule.processLevelUp(
		xpFolder.Value + amount,
		xpFolder.Level.Value,
		xpFolder.XPToEarn.Value,
		xpFolder.Rank.Value
	)

	xpFolder.Value = newXP
	xpFolder.Level.Value = newLevel
	xpFolder.XPToEarn.Value = newXPToEarn

	local rankVal = xpFolder:FindFirstChild("Rank")
	if rankVal then
		rankVal.Value = newRank
	end

	print("[PlayerDataManager] " .. player.Name .. " is now Level " .. newLevel .. " (Rank " .. newRank .. ") XP: " .. newXP .. "/" .. newXPToEarn)
end

-- Expose addXP globally so CombatModule scripts can award XP on hit
_G.AddXP = addXP

-- Forward declaration so ProcessReceipt can reference saveAll before its full definition
local saveAll

-- =========================================================================
-- RETRY HELPER for DataStore GetAsync calls
-- =========================================================================

-- retryGetAsync: Calls store:GetAsync(key) with exponential backoff retries.
-- Returns (success: boolean, data: any) where data is either the loaded data
-- or the error message on failure.
local function retryGetAsync(store, key, maxRetries)
	maxRetries = maxRetries or 3
	local lastErr
	for attempt = 1, maxRetries + 1 do
		local success, data = pcall(function()
			return store:GetAsync(key)
		end)
		if success then
			return true, data
		end
		lastErr = data
		if attempt <= maxRetries then
			warn(string.format("[PlayerDataManager] GetAsync attempt %d/%d failed for key '%s': %s",
				attempt, maxRetries + 1, key, tostring(data)))
			task.wait(math.min(2 ^ (attempt - 1), 3))  -- 1, 2, 3 seconds
		end
	end
	warn(string.format("[PlayerDataManager] GetAsync FAILED after %d attempts for key '%s': %s",
		maxRetries + 1, key, tostring(lastErr)))
	return false, lastErr
end

-- =========================================================================
-- DEVELOPER PRODUCT PURCHASE HANDLING (GCells purchases with Robux)
-- =========================================================================

-- Map of Developer Product IDs to GCell amounts
local GCELL_PRODUCTS = {
	[1265365074] = 125,   -- +125 GCells
	[1265365191] = 250,   -- +250 GCells
	[1265365294] = 500,   -- +500 GCells
	[1265365363] = 1000,  -- +1000 GCells
}

-- ProcessReceipt: Called by Roblox when a developer product purchase is completed
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Player left: return NotProcessedYet so Roblox retries later
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local gcellAmount = GCELL_PRODUCTS[receiptInfo.ProductId]
	if not gcellAmount then
		-- Unknown product: grant purchase to avoid locking the player out
		warn("[PlayerDataManager] Unknown product ID purchased: " .. tostring(receiptInfo.ProductId))
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		warn("[PlayerDataManager] No inventory found for player " .. player.Name .. " during receipt processing")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Add GCells to the player's inventory
	inventory.GCells.Value = inventory.GCells.Value + gcellAmount

	-- Save immediately to ensure GCells persist
	if saveAll then
		saveAll(player)
	else
		warn("[PlayerDataManager] saveAll not available during receipt processing")
	end

	print("[PlayerDataManager] Granted " .. gcellAmount .. " GCells to " .. player.Name .. " (Product: " .. receiptInfo.ProductId .. ")")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- DataStores - wrapped in pcall in case API services are disabled in Studio
local dataStoresAvailable = true
local inventoryStore
local settingsStore
local statsStore

local dsSuccess, dsErr = pcall(function()
	inventoryStore = DataStoreService:GetDataStore("PlayerInventory_v1")
	settingsStore = DataStoreService:GetDataStore("PlayerSettings_v2")
	statsStore = DataStoreService:GetDataStore("PlayerStats_v1")
end)

if not dsSuccess then
	warn("[PlayerDataManager] GetDataStore FAILED: " .. tostring(dsErr) .. " - DataStores unavailable, will use defaults only")
	dataStoresAvailable = false
else
	print("[PlayerDataManager] DataStores initialized successfully")
end

-- =========================================================================
-- DEFAULT VALUES
-- =========================================================================

local DEFAULT_KEYBINDS = {
	SP1 = "Z",
	SP2 = "X",
	SP3 = "C",
	Roar = "R",
	Grab = "G",
	Escape = "E",
	Rage = "V",
	Block = "F",
	LockOn = "T",
	LockOnSwap = "Y",
	SwimUp = "One",
	SwimDown = "Three",
}

local DEFAULT_SETTINGS = {
	MusicVolume = 0.75,
	Shadows = true,
	DepthOfField = true,
	Blur = true,
	ScreenShake = true,
	ShowHitboxes = false,
	Keybinds = true, -- toggle for custom keybinds
}

local DEFAULT_INVENTORY = {
	XP = 0,
	Level = 1,
	XPToEarn = 300,
	Rank = 1,
	GCells = 0,
	Lootboxes = 0,
	Skin = "",
	ProfileImage = "",
	RewardsCompleted = 0,
	RewardsCurrent = "",
	RewardsOwned = false,
}

local DEFAULT_STATS = {
	K = 0,
	D = 0,
	BestCombo = 0,
	TotalDamage = 0,
	MainKaiju = "",
	KaijuUsage = "",
}

-- =========================================================================
-- FOLDER CREATION
-- =========================================================================

-- Create the Inventory folder on a player with all required Values
local function createInventory(player)
	-- If already exists (e.g. script re-run), remove old one
	local existing = player:FindFirstChild("Inventory")
	if existing then
		existing:Destroy()
	end

	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	-- XP (IntValue) with Level and XPToEarn children
	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = DEFAULT_INVENTORY.XP
	xp.Parent = inventory

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = DEFAULT_INVENTORY.Level
	level.Parent = xp

	local xpToEarn = Instance.new("IntValue")
	xpToEarn.Name = "XPToEarn"
	xpToEarn.Value = DEFAULT_INVENTORY.XPToEarn
	xpToEarn.Parent = xp

	-- Rank (IntValue) - prestige rank, increments every 205 levels
	local rank = Instance.new("IntValue")
	rank.Name = "Rank"
	rank.Value = DEFAULT_INVENTORY.Rank
	rank.Parent = xp

	-- GCells (IntValue) - currency
	local gcells = Instance.new("IntValue")
	gcells.Name = "GCells"
	gcells.Value = DEFAULT_INVENTORY.GCells
	gcells.Parent = inventory

	-- Lootboxes (IntValue) - lootbox count
	local lootboxes = Instance.new("IntValue")
	lootboxes.Name = "Lootboxes"
	lootboxes.Value = DEFAULT_INVENTORY.Lootboxes
	lootboxes.Parent = inventory

	-- Skin (StringValue) - currently equipped skin name
	local skin = Instance.new("StringValue")
	skin.Name = "Skin"
	skin.Value = DEFAULT_INVENTORY.Skin
	skin.Parent = inventory

	-- ProfileImage (StringValue) - user's profile image asset ID
	local profileImage = Instance.new("StringValue")
	profileImage.Name = "ProfileImage"
	profileImage.Value = DEFAULT_INVENTORY.ProfileImage
	profileImage.Parent = inventory

	-- Rewards (Folder)
	local rewards = Instance.new("Folder")
	rewards.Name = "Rewards"
	rewards.Parent = inventory

	local completed = Instance.new("IntValue")
	completed.Name = "Completed"
	completed.Value = DEFAULT_INVENTORY.RewardsCompleted
	completed.Parent = rewards

	local current = Instance.new("StringValue")
	current.Name = "Current"
	current.Value = DEFAULT_INVENTORY.RewardsCurrent
	current.Parent = rewards

	local owned = Instance.new("BoolValue")
	owned.Name = "Owned"
	owned.Value = DEFAULT_INVENTORY.RewardsOwned
	owned.Parent = rewards

	return inventory
end

-- Create the Settings folder on a player with all required Values
local function createSettings(player)
	local existing = player:FindFirstChild("Settings")
	if existing then
		existing:Destroy()
	end

	local settings = Instance.new("Folder")
	settings.Name = "Settings"
	settings.Parent = player

	-- UI subfolder
	local ui = Instance.new("Folder")
	ui.Name = "UI"
	ui.Parent = settings

	local musicVolume = Instance.new("NumberValue")
	musicVolume.Name = "MusicVolume"
	musicVolume.Value = DEFAULT_SETTINGS.MusicVolume
	musicVolume.Parent = ui

	-- Graphics subfolder
	local graphics = Instance.new("Folder")
	graphics.Name = "Graphics"
	graphics.Parent = settings

	local shadows = Instance.new("BoolValue")
	shadows.Name = "Shadows"
	shadows.Value = DEFAULT_SETTINGS.Shadows
	shadows.Parent = graphics

	local depthOfField = Instance.new("BoolValue")
	depthOfField.Name = "DepthOfField"
	depthOfField.Value = DEFAULT_SETTINGS.DepthOfField
	depthOfField.Parent = graphics

	local blur = Instance.new("BoolValue")
	blur.Name = "Blur"
	blur.Value = DEFAULT_SETTINGS.Blur
	blur.Parent = graphics

	-- Other settings directly under Settings
	local screenShake = Instance.new("BoolValue")
	screenShake.Name = "ScreenShake"
	screenShake.Value = DEFAULT_SETTINGS.ScreenShake
	screenShake.Parent = settings

	local showHitboxes = Instance.new("BoolValue")
	showHitboxes.Name = "ShowHitboxes"
	showHitboxes.Value = DEFAULT_SETTINGS.ShowHitboxes
	showHitboxes.Parent = settings

	local keybindsToggle = Instance.new("BoolValue")
	keybindsToggle.Name = "Keybinds"
	keybindsToggle.Value = DEFAULT_SETTINGS.Keybinds
	keybindsToggle.Parent = settings

	-- Keybind StringValues
	for name, key in pairs(DEFAULT_KEYBINDS) do
		local keybind = Instance.new("StringValue")
		keybind.Name = name
		keybind.Value = key
		keybind.Parent = settings
	end

	return settings
end

-- Create the Stats folder on a player with K and D Values
local function createStats(player)
	local existing = player:FindFirstChild("Stats")
	if existing then
		existing:Destroy()
	end

	local stats = Instance.new("Folder")
	stats.Name = "Stats"
	stats.Parent = player

	local kills = Instance.new("IntValue")
	kills.Name = "K"
	kills.Value = DEFAULT_STATS.K
	kills.Parent = stats

	local deaths = Instance.new("IntValue")
	deaths.Name = "D"
	deaths.Value = DEFAULT_STATS.D
	deaths.Parent = stats

	local bestCombo = Instance.new("IntValue")
	bestCombo.Name = "BestCombo"
	bestCombo.Value = DEFAULT_STATS.BestCombo
	bestCombo.Parent = stats

	local totalDamage = Instance.new("IntValue")
	totalDamage.Name = "TotalDamage"
	totalDamage.Value = DEFAULT_STATS.TotalDamage
	totalDamage.Parent = stats

	local mainKaiju = Instance.new("StringValue")
	mainKaiju.Name = "MainKaiju"
	mainKaiju.Value = DEFAULT_STATS.MainKaiju
	mainKaiju.Parent = stats

	local kaijuUsage = Instance.new("StringValue")
	kaijuUsage.Name = "KaijuUsage"
	kaijuUsage.Value = DEFAULT_STATS.KaijuUsage
	kaijuUsage.Parent = stats

	return stats
end

-- =========================================================================
-- DATA SERIALIZATION
-- =========================================================================

-- Serialize inventory data to a table for DataStore
local function serializeInventory(inventory)
	local data = {
		XP = inventory.XP.Value,
		Level = inventory.XP.Level.Value,
		XPToEarn = inventory.XP.XPToEarn.Value,
		Rank = inventory.XP.Rank.Value,
		GCells = inventory.GCells.Value,
		Lootboxes = inventory.Lootboxes.Value,
		Skin = inventory.Skin.Value,
		ProfileImage = inventory.ProfileImage.Value,
		RewardsCompleted = inventory.Rewards.Completed.Value,
		RewardsCurrent = inventory.Rewards.Current.Value,
		RewardsOwned = inventory.Rewards.Owned.Value,
	}

	-- Save any extra BoolValues (owned items like skins, emotes, kaijus)
	local ownedItems = {}
	for _, child in ipairs(inventory:GetChildren()) do
		if child:IsA("BoolValue") then
			ownedItems[child.Name] = child.Value
		elseif child:IsA("IntValue") and child.Name ~= "XP" and child.Name ~= "GCells" and child.Name ~= "Lootboxes" then
			-- Extra IntValues (e.g. reward progress)
			ownedItems[child.Name] = child.Value
		elseif child:IsA("StringValue") and child.Name ~= "Skin" then
			ownedItems[child.Name] = child.Value
		end
	end
	data.OwnedItems = ownedItems

	-- Save Skins folder (per-kaiju skin preferences)
	local skinsFolder = inventory:FindFirstChild("Skins")
	if skinsFolder then
		local skinData = {}
		for _, kaijuSkinVal in ipairs(skinsFolder:GetChildren()) do
			if kaijuSkinVal:IsA("StringValue") then
				skinData[kaijuSkinVal.Name] = kaijuSkinVal.Value
			end
		end
		data.Skins = skinData
	end

	-- Save Emotes folder (per-kaiju equipped emote slots)
	local emotesFolder = inventory:FindFirstChild("Emotes")
	if emotesFolder then
		local emoteData = {}
		for _, kaijuFolder in ipairs(emotesFolder:GetChildren()) do
			if kaijuFolder:IsA("Folder") then
				local kaijuEmotes = {}
				for _, slotValue in ipairs(kaijuFolder:GetChildren()) do
					if slotValue:IsA("StringValue") then
						kaijuEmotes[slotValue.Name] = slotValue.Value
					end
				end
				emoteData[kaijuFolder.Name] = kaijuEmotes
			end
		end
		data.Emotes = emoteData
	end

	-- Save reward children (individual reward objects)
	local rewardData = {}
	for _, reward in ipairs(inventory.Rewards:GetChildren()) do
		if reward:IsA("IntValue") or reward:IsA("StringValue") or reward:IsA("BoolValue") then
			-- Skip the core values (Completed, Current, Owned) - already saved above
			if reward.Name ~= "Completed" and reward.Name ~= "Current" and reward.Name ~= "Owned" then
				rewardData[reward.Name] = {
					ClassName = reward.ClassName,
					Value = reward.Value,
				}
			end
		end
	end
	data.RewardData = rewardData

	return data
end

-- Serialize settings data to a table for DataStore
local function serializeSettings(settings)
	local data = {
		MusicVolume = settings.UI.MusicVolume.Value,
		Shadows = settings.Graphics.Shadows.Value,
		DepthOfField = settings.Graphics.DepthOfField.Value,
		Blur = settings.Graphics.Blur.Value,
		ScreenShake = settings.ScreenShake.Value,
		ShowHitboxes = settings.ShowHitboxes.Value,
		Keybinds = settings.Keybinds.Value,
	}

	-- Save keybind values
	for name, _ in pairs(DEFAULT_KEYBINDS) do
		local keybind = settings:FindFirstChild(name)
		if keybind then
			data["Keybind_" .. name] = keybind.Value
		end
	end

	return data
end

-- Serialize stats data to a table for DataStore
local function serializeStats(stats)
	return {
		K = stats.K.Value,
		D = stats.D.Value,
		BestCombo = stats.BestCombo.Value,
		TotalDamage = stats.TotalDamage.Value,
		MainKaiju = stats.MainKaiju.Value,
		KaijuUsage = stats.KaijuUsage.Value,
	}
end
-- =========================================================================

local function saveInventory(player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	if not dataStoresAvailable then return end

	local data = serializeInventory(inventory)
	local success, err = pcall(function()
		inventoryStore:SetAsync("Inv_" .. player.UserId, data)
	end)
	if not success then
		warn("[PlayerDataManager] Failed to save inventory for " .. player.Name .. ": " .. tostring(err))
	end
end

local function saveSettings(player)
	local settings = player:FindFirstChild("Settings")
	if not settings then return end
	if not dataStoresAvailable then return end

	local data = serializeSettings(settings)
	local success, err = pcall(function()
		settingsStore:SetAsync("Settings_" .. player.UserId, data)
	end)
	if not success then
		warn("[PlayerDataManager] Failed to save settings for " .. player.Name .. ": " .. tostring(err))
	end
end

local function saveStats(player)
	local stats = player:FindFirstChild("Stats")
	if not stats then return end
	if not dataStoresAvailable then return end

	local data = serializeStats(stats)
	local success, err = pcall(function()
		statsStore:SetAsync("Stats_" .. player.UserId, data)
	end)
	if not success then
		warn("[PlayerDataManager] Failed to save stats for " .. player.Name .. ": " .. tostring(err))
	end
end

saveAll = function(player)
	saveInventory(player)
	saveSettings(player)
	saveStats(player)
end

local function loadInventory(player, inventory)
	if not dataStoresAvailable then
		print("[PlayerDataManager] DataStores unavailable - skipping inventory load for " .. player.Name .. " (using defaults)")
		return
	end
	local success, data = retryGetAsync(inventoryStore, "Inv_" .. player.UserId)
	if not success then
		warn("[PlayerDataManager] Failed to load inventory for " .. player.Name .. " - using defaults")
		return
	end
	if not data then
		print("[PlayerDataManager] No saved inventory for " .. player.Name .. " - using defaults (new player)")
		return
	end

	-- Apply core values
	if data.XP then inventory.XP.Value = data.XP end
	if data.Level then inventory.XP.Level.Value = data.Level end
	if data.XPToEarn then inventory.XP.XPToEarn.Value = data.XPToEarn end
	if data.Rank then inventory.XP.Rank.Value = data.Rank end

	-- Auto-fix: process pending level-ups for players who accumulated XP
	-- before the rank/level system was live (e.g. from lootbox XP rewards)
	if inventory.XP.Value >= inventory.XP.XPToEarn.Value then
		local newLevel, newXP, newXPToEarn, newRank = XPModule.processLevelUp(
			inventory.XP.Value,
			inventory.XP.Level.Value,
			inventory.XP.XPToEarn.Value,
			inventory.XP.Rank.Value
		)
		local oldLevel = inventory.XP.Level.Value
		inventory.XP.Value = newXP
		inventory.XP.Level.Value = newLevel
		inventory.XP.XPToEarn.Value = newXPToEarn
		inventory.XP.Rank.Value = newRank
		print("[PlayerDataManager] Auto-fixed " .. player.Name .. ": Level " .. oldLevel .. " -> " .. newLevel .. " (Rank " .. newRank .. ") XP: " .. newXP .. "/" .. newXPToEarn)
	end

	if data.GCells then inventory.GCells.Value = data.GCells end
	if data.Lootboxes then inventory.Lootboxes.Value = data.Lootboxes end
	if data.Skin then inventory.Skin.Value = data.Skin end
	if data.ProfileImage then inventory.ProfileImage.Value = data.ProfileImage end
	if data.RewardsCompleted then inventory.Rewards.Completed.Value = data.RewardsCompleted end
	if data.RewardsCurrent then inventory.Rewards.Current.Value = data.RewardsCurrent end
	if data.RewardsOwned ~= nil then inventory.Rewards.Owned.Value = data.RewardsOwned end

	-- Restore owned items (extra BoolValues, IntValues, StringValues)
	if data.OwnedItems then
		for name, value in pairs(data.OwnedItems) do
			-- Only create if it doesn't already exist
			if not inventory:FindFirstChild(name) then
				if type(value) == "boolean" then
					local item = Instance.new("BoolValue")
					item.Name = name
					item.Value = value
					item.Parent = inventory
				elseif type(value) == "number" then
					local item = Instance.new("IntValue")
					item.Name = name
					item.Value = value
					item.Parent = inventory
				elseif type(value) == "string" then
					local item = Instance.new("StringValue")
					item.Name = name
					item.Value = value
					item.Parent = inventory
				end
			end
		end
	end

	-- Restore Emotes folder (per-kaiju)
	if data.Emotes then
		local emotesFolder = inventory:FindFirstChild("Emotes")
		if not emotesFolder then
			emotesFolder = Instance.new("Folder")
			emotesFolder.Name = "Emotes"
			emotesFolder.Parent = inventory
		end
		for kaijuName, slots in pairs(data.Emotes) do
			if type(slots) == "table" then
				local kaijuFolder = emotesFolder:FindFirstChild(kaijuName)
				if not kaijuFolder then
					kaijuFolder = Instance.new("Folder")
					kaijuFolder.Name = kaijuName
					kaijuFolder.Parent = emotesFolder
				end
				for slotName, emoteName in pairs(slots) do
					local slotValue = kaijuFolder:FindFirstChild(slotName)
					if not slotValue then
						slotValue = Instance.new("StringValue")
						slotValue.Name = slotName
						slotValue.Parent = kaijuFolder
					end
					slotValue.Value = emoteName
				end
			end
		end
	end

	-- Restore Skins folder (per-kaiju skin preferences)
	if data.Skins then
		local skinsFolder = inventory:FindFirstChild("Skins")
		if not skinsFolder then
			skinsFolder = Instance.new("Folder")
			skinsFolder.Name = "Skins"
			skinsFolder.Parent = inventory
		end
		for kaijuName, skinName in pairs(data.Skins) do
			local skinVal = skinsFolder:FindFirstChild(kaijuName)
			if not skinVal then
				skinVal = Instance.new("StringValue")
				skinVal.Name = kaijuName
				skinVal.Parent = skinsFolder
			end
			skinVal.Value = skinName
		end
	end

	-- Restore reward data
	if data.RewardData then
		for name, info in pairs(data.RewardData) do
			if not inventory.Rewards:FindFirstChild(name) then
				local item
				if info.ClassName == "IntValue" then
					item = Instance.new("IntValue")
				elseif info.ClassName == "StringValue" then
					item = Instance.new("StringValue")
				elseif info.ClassName == "BoolValue" then
					item = Instance.new("BoolValue")
				else
					item = Instance.new("IntValue")
				end
				item.Name = name
				item.Value = info.Value
				item.Parent = inventory.Rewards
			end
		end
	end
end

local function loadSettings(player, settings)
	if not dataStoresAvailable then
		print("[PlayerDataManager] DataStores unavailable - skipping settings load for " .. player.Name .. " (using defaults)")
		return
	end
	local success, data = retryGetAsync(settingsStore, "Settings_" .. player.UserId)
	if not success then
		warn("[PlayerDataManager] Failed to load settings for " .. player.Name .. " - using defaults")
		return
	end
	if not data then
		print("[PlayerDataManager] No saved settings for " .. player.Name .. " - using defaults (new player)")
		return
	end

	if data.MusicVolume then settings.UI.MusicVolume.Value = data.MusicVolume end
	if data.Shadows ~= nil then settings.Graphics.Shadows.Value = data.Shadows end
	if data.DepthOfField ~= nil then settings.Graphics.DepthOfField.Value = data.DepthOfField end
	if data.Blur ~= nil then settings.Graphics.Blur.Value = data.Blur end
	if data.ScreenShake ~= nil then settings.ScreenShake.Value = data.ScreenShake end
	if data.ShowHitboxes ~= nil then settings.ShowHitboxes.Value = data.ShowHitboxes end
	if data.Keybinds ~= nil then settings.Keybinds.Value = data.Keybinds end

	-- Load keybind values
	for name, _ in pairs(DEFAULT_KEYBINDS) do
		local keybind = settings:FindFirstChild(name)
		if keybind and data["Keybind_" .. name] then
			keybind.Value = data["Keybind_" .. name]
		end
	end
end

local function loadStats(player, stats)
	if not dataStoresAvailable then
		print("[PlayerDataManager] DataStores unavailable - skipping stats load for " .. player.Name .. " (using defaults)")
		return
	end
	local success, data = retryGetAsync(statsStore, "Stats_" .. player.UserId)
	if not success then
		warn("[PlayerDataManager] Failed to load stats for " .. player.Name .. " - using defaults")
		return
	end
	if not data then
		print("[PlayerDataManager] No saved stats for " .. player.Name .. " - using defaults (new player)")
		return
	end

	if data.K then stats.K.Value = data.K end
	if data.D then stats.D.Value = data.D end
	if data.BestCombo then stats.BestCombo.Value = data.BestCombo end
	if data.TotalDamage then stats.TotalDamage.Value = data.TotalDamage end
	if data.MainKaiju then stats.MainKaiju.Value = data.MainKaiju end
	if data.KaijuUsage then stats.KaijuUsage.Value = data.KaijuUsage end
end

-- =========================================================================
-- AUTO-SAVE (debounced)
-- =========================================================================

local saveDebounces = {}

local function scheduleSave(player)
	if saveDebounces[player] then return end
	saveDebounces[player] = true
	task.delay(3, function()
		saveDebounces[player] = nil
		if player and player.Parent then
			saveAll(player)
		end
	end)
end

local function setupAutoSave(player)
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		-- Save when any existing value changes
		for _, value in ipairs(inventory:GetDescendants()) do
			if value:IsA("ValueBase") then
				value.Changed:Connect(function()
					scheduleSave(player)
				end)
			end
		end
		-- Save when new items are added to inventory
		inventory.ChildAdded:Connect(function(child)
			scheduleSave(player)
			if child:IsA("ValueBase") then
				child.Changed:Connect(function()
					scheduleSave(player)
				end)
			end
			-- Also monitor children of added objects
			child.DescendantAdded:Connect(function(desc)
				if desc:IsA("ValueBase") then
					desc.Changed:Connect(function()
						scheduleSave(player)
					end)
				end
			end)
		end)
		-- Monitor rewards folder for new reward children
		local rewards = inventory:FindFirstChild("Rewards")
		if rewards then
			rewards.ChildAdded:Connect(function(child)
				scheduleSave(player)
				if child:IsA("ValueBase") then
					child.Changed:Connect(function()
						scheduleSave(player)
					end)
				end
			end)
		end
	end

	local settings = player:FindFirstChild("Settings")
	if settings then
		for _, value in ipairs(settings:GetDescendants()) do
			if value:IsA("ValueBase") then
				value.Changed:Connect(function()
					scheduleSave(player)
				end)
			end
		end
		-- Save when new settings are added
		settings.DescendantAdded:Connect(function(desc)
			scheduleSave(player)
			if desc:IsA("ValueBase") then
			desc.Changed:Connect(function()
				scheduleSave(player)
			end)
			end
		end)
	end

	-- Auto-save Stats folder
	local stats = player:FindFirstChild("Stats")
	if stats then
		for _, value in ipairs(stats:GetChildren()) do
			if value:IsA("ValueBase") then
				value.Changed:Connect(function()
					scheduleSave(player)
				end)
			end
		end
		stats.ChildAdded:Connect(function(child)
			scheduleSave(player)
			if child:IsA("ValueBase") then
				child.Changed:Connect(function()
					scheduleSave(player)
				end)
			end
		end)
	end
end

-- =========================================================================
-- REMOTE EVENT HANDLERS
-- =========================================================================

-- Connect to RemoteEvents that live in the player's PlayerGui (cloned from StarterGui)
local function connectEvents(player)
	local playerGui = player:WaitForChild("PlayerGui", 30)
	if not playerGui then return end

	local menuGui = playerGui:WaitForChild("Menu", 30)
	if not menuGui then return end

	local menuFrame = menuGui:FindFirstChild("Menu")
	if not menuFrame then
		menuFrame = menuGui:WaitForChild("Menu", 30)
		if not menuFrame then return end
	end

	local events = menuFrame:FindFirstChild("Events")
	if not events then return end

	-- UpdateValue: Client sends (ValueInstance, newValue) to update a setting
	local updateValue = events:FindFirstChild("UpdateValue")
	if updateValue and updateValue:IsA("RemoteEvent") then
		updateValue.OnServerEvent:Connect(function(p, valueObj, newValue)
			if p ~= player then return end
			if typeof(valueObj) == "Instance" and valueObj:IsA("ValueBase") then
				-- Security: verify the value belongs to this player
				local current = valueObj
				local isUnderPlayer = false
				while current do
					if current == player then
						isUnderPlayer = true
						break
					end
					current = current.Parent
				end
				if isUnderPlayer then
					valueObj.Value = newValue
				end
			end
		end)
	end

	-- CheckProfile: Client requests profile verification
	local checkProfile = events:FindFirstChild("CheckProfile")
	if checkProfile and checkProfile:IsA("RemoteEvent") then
		checkProfile.OnServerEvent:Connect(function(p, ...)
			if p ~= player then return end
			-- Profile check: ensure inventory exists and is loaded
			local inventory = player:FindFirstChild("Inventory")
			if inventory then
				-- Fire back to client to confirm profile is ready
				-- The client-side code uses this to know data is loaded
				checkProfile:FireClient(player)
			end
		end)
	end

	-- BuyItem: Client requests to buy an item with GCells
	local buyItem = events:FindFirstChild("BuyItem")
	if buyItem and buyItem:IsA("RemoteEvent") then
		buyItem.OnServerEvent:Connect(function(p, itemCost, itemName)
			if p ~= player then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end

			local cost = tonumber(itemCost)
			if not cost or cost < 0 then return end

			-- Check if player has enough GCells
			if inventory.GCells.Value >= cost then
				-- Deduct GCells
				inventory.GCells.Value = inventory.GCells.Value - cost

				-- Mark item as owned (create a BoolValue on the inventory)
				if itemName and type(itemName) == "string" and itemName ~= "" then
					local ownedItem = inventory:FindFirstChild(itemName)
					if not ownedItem then
						ownedItem = Instance.new("BoolValue")
						ownedItem.Name = itemName
						ownedItem.Value = true
						ownedItem.Parent = inventory
					else
						ownedItem.Value = true
					end
				end

				-- Confirm purchase to client
				buyItem:FireClient(player, true, itemName)
			else
				-- Not enough GCells
				buyItem:FireClient(player, false, itemName)
			end
		end)
	end

	-- LootboxDeduct: Client requests to deduct a lootbox
	local lootboxDeduct = events:FindFirstChild("LootboxDeduct")
	if lootboxDeduct and lootboxDeduct:IsA("RemoteEvent") then
		lootboxDeduct.OnServerEvent:Connect(function(p)
			if p ~= player then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end

			if inventory.Lootboxes.Value > 0 then
				inventory.Lootboxes.Value = inventory.Lootboxes.Value - 1
			end
		end)
	end

	-- LootboxAdd: Client requests to add lootboxes (e.g., from rewards, gameplay)
	local lootboxAdd = events:FindFirstChild("LootboxAdd")
	if lootboxAdd and lootboxAdd:IsA("RemoteEvent") then
		lootboxAdd.OnServerEvent:Connect(function(p, amount)
			if p ~= player then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end

			local addAmount = tonumber(amount)
			if not addAmount or addAmount <= 0 then return end

			-- Cap at reasonable max to prevent abuse
			addAmount = math.clamp(addAmount, 1, 100)
			inventory.Lootboxes.Value = inventory.Lootboxes.Value + addAmount
		end)
	end

	-- EquipSkin: Client requests to equip a skin (with ownership check)
	local equipSkin = events:FindFirstChild("EquipSkin")
	if equipSkin and equipSkin:IsA("RemoteEvent") then
		equipSkin.OnServerEvent:Connect(function(p, skinName)
			if p ~= player then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end
			if type(skinName) ~= "string" or skinName == "" then return end

			-- Check ownership: Default skins are always owned
			-- Matches "Default", "default", "Godzilla2000-Default", "Zilla-default", etc.
			local lowerSkin = string.lower(skinName)
			local isOwned = (lowerSkin == "default") or (string.sub(lowerSkin, -8) == "-default")
			if not isOwned then
				local owned = inventory:FindFirstChild(skinName)
				isOwned = owned and owned:IsA("BoolValue") and owned.Value
			end

			if isOwned then
				inventory.Skin.Value = skinName
			else
				warn("[PlayerDataManager] Player " .. player.Name .. " does not own skin: " .. skinName)
			end
		end)
	end

	-- SetMain: Client requests to set main kaiju/skin (with ownership check)
	local setMain = events:FindFirstChild("SetMain")
	if setMain and setMain:IsA("RemoteEvent") then
		setMain.OnServerEvent:Connect(function(p, ...)
			if p ~= player then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end
			local args = {...}
			if #args > 0 and type(args[1]) == "string" then
				local skinName = args[1]
				-- Check skin ownership before setting
				-- Matches "Default", "", and any skin ending in "-Default" (case-insensitive)
				local lowerSkin = string.lower(skinName)
				local isOwned = (skinName == "Default") or (skinName == "") or (string.sub(lowerSkin, -8) == "-default")
				if not isOwned then
					local owned = inventory:FindFirstChild(skinName)
					isOwned = owned and owned:IsA("BoolValue") and owned.Value
				end
				if isOwned then
					inventory.Skin.Value = skinName
				else
					warn("[PlayerDataManager] Player " .. player.Name .. " does not own skin via SetMain: " .. skinName)
				end
			end
		end)
	end

	-- EquipKaiju: Client requests to equip a kaiju
	local equipKaiju = events:FindFirstChild("EquipKaiju")
	if equipKaiju and equipKaiju:IsA("RemoteEvent") then
		equipKaiju.OnServerEvent:Connect(function(p, kaijuName)
			if p ~= player then return end
			if type(kaijuName) ~= "string" or kaijuName == "" then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end

			-- Check if player owns this kaiju
			local ownedKaiju = inventory:FindFirstChild(kaijuName)
			if ownedKaiju and ownedKaiju:IsA("BoolValue") and ownedKaiju.Value then
				-- Set as equipped kaiju
				local equipped = inventory:FindFirstChild("EquippedKaiju")
				if not equipped then
					equipped = Instance.new("StringValue")
					equipped.Name = "EquippedKaiju"
					equipped.Parent = inventory
				end
				equipped.Value = kaijuName
				equipKaiju:FireClient(player, true, kaijuName)
			else
				equipKaiju:FireClient(player, false, kaijuName)
			end
		end)
	end

	-- EquipEmote: Client requests to equip an emote (per-kaiju)
	local equipEmote = events:FindFirstChild("EquipEmote")
	if equipEmote and equipEmote:IsA("RemoteEvent") then
		equipEmote.OnServerEvent:Connect(function(p, emoteName, slot, kaijuName)
			if p ~= player then return end
			if type(emoteName) ~= "string" then return end
			if type(kaijuName) ~= "string" or kaijuName == "" then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end

			-- Check if player owns this emote
			-- Free/default emotes may not have a BoolValue in the inventory yet;
			-- auto-create it so they can be equipped without issues.
			local ownedEmote = inventory:FindFirstChild(emoteName)
			local isEmoteOwned = false
			if ownedEmote and ownedEmote:IsA("BoolValue") then
				isEmoteOwned = ownedEmote.Value
			elseif not ownedEmote then
				-- BoolValue doesn't exist: auto-own (handles free/default emotes)
				isEmoteOwned = true
				ownedEmote = Instance.new("BoolValue")
				ownedEmote.Name = emoteName
				ownedEmote.Value = true
				ownedEmote.Parent = inventory
			end
			if isEmoteOwned then
				-- Get or create the Emotes folder
				local emotesFolder = inventory:FindFirstChild("Emotes")
				if not emotesFolder then
					emotesFolder = Instance.new("Folder")
					emotesFolder.Name = "Emotes"
					emotesFolder.Parent = inventory
				end

				-- Get or create the per-kaiju folder
				local kaijuFolder = emotesFolder:FindFirstChild(kaijuName)
				if not kaijuFolder then
					kaijuFolder = Instance.new("Folder")
					kaijuFolder.Name = kaijuName
					kaijuFolder.Parent = emotesFolder
				end

				-- Store equipped emote in the correct slot
				local slotNum = tonumber(slot) or 1
				local slotValue = kaijuFolder:FindFirstChild("Emote" .. slotNum)
				if not slotValue then
					slotValue = Instance.new("StringValue")
					slotValue.Name = "Emote" .. slotNum
					slotValue.Parent = kaijuFolder
				end
				slotValue.Value = emoteName
				equipEmote:FireClient(player, true, emoteName)
			else
				equipEmote:FireClient(player, false, emoteName)
			end
		
		end)
	end

	-- LootboxUnlock: Client requests to unlock a lootbox item
	-- Parameters: (player, rewardType, rewardName, amount, rarity)
	--   rewardType: "XP", "GCells", "Lootboxes", "Skin", "Emote", "Kaiju"
	--   rewardName: item name (for skins/emotes) or same as rewardType (for currency)
	--   amount: numeric amount (for XP/GCells/Lootboxes)
	--   rarity: rarity string ("Uncommon", "Rare", "Epic", "Legendary")
	local lootboxUnlock = events:FindFirstChild("LootboxUnlock")
	if lootboxUnlock and lootboxUnlock:IsA("RemoteEvent") then
		lootboxUnlock.OnServerEvent:Connect(function(p, rewardType, rewardName, amount, rarity)
			if p ~= player then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end

			-- Validate rewardType
			if type(rewardType) ~= "string" or rewardType == "" then return end

			-- Handle currency rewards (XP, GCells, Lootboxes)
			if rewardType == "XP" then
				local addAmount = tonumber(amount) or 0
				if addAmount > 0 then
					addXP(player, addAmount)
				end
				return
			end

			if rewardType == "GCells" then
				local addAmount = tonumber(amount) or 0
				if addAmount > 0 then
					-- Cap to prevent abuse
					addAmount = math.clamp(addAmount, 0, 10000)
					inventory.GCells.Value = inventory.GCells.Value + addAmount
				end
				return
			end

			if rewardType == "Lootboxes" then
				local addAmount = tonumber(amount) or 0
				if addAmount > 0 then
					addAmount = math.clamp(addAmount, 0, 100)
					inventory.Lootboxes.Value = inventory.Lootboxes.Value + addAmount
				end
				return
			end

			-- Handle item rewards (Skins, Emotes, Kaijus)
			if rewardType == "Skin" or rewardType == "Emote" or rewardType == "Kaiju" then
				if type(rewardName) == "string" and rewardName ~= "" then
					-- Mark item as owned
					local ownedItem = inventory:FindFirstChild(rewardName)
					if not ownedItem then
						ownedItem = Instance.new("BoolValue")
						ownedItem.Name = rewardName
						ownedItem.Value = true
						ownedItem.Parent = inventory
					else
						ownedItem.Value = true
					end

					-- If rarity info provided, store it
					if type(rarity) == "string" and rarity ~= "" then
						local rarityValue = inventory:FindFirstChild(rewardName .. "_Rarity")
						if not rarityValue then
							rarityValue = Instance.new("StringValue")
							rarityValue.Name = rewardName .. "_Rarity"
							rarityValue.Parent = inventory
						end
						rarityValue.Value = rarity
					end
				end
			end
		end)
	end

	-- ChangeIMAGE: Client requests to change an image for a kaiju/skin
	local changeImage = events:FindFirstChild("ChangeIMAGE")
	if changeImage and changeImage:IsA("RemoteEvent") then
		changeImage.OnServerEvent:Connect(function(p, targetName, imageId)
			if p ~= player then return end
			local inventory = player:FindFirstChild("Inventory")
			if not inventory then return end

			if type(targetName) == "string" and type(imageId) == "string" then
				-- Special case: setting profile image directly
				if targetName == "ProfileImage" then
					local profileImg = inventory:FindFirstChild("ProfileImage")
					if profileImg then
						profileImg.Value = imageId
					end
				else
					local imageValue = inventory:FindFirstChild(targetName .. "_Image")
					if not imageValue then
						imageValue = Instance.new("StringValue")
						imageValue.Name = targetName .. "_Image"
						imageValue.Parent = inventory
					end
					imageValue.Value = imageId
				end
			end
		end)
	end

	-- LoadProfile: Client requests another player's profile data
	-- Supports both online players (live Inventory/Stats objects) and offline
	-- players (loaded from DataStore via GetUserIdFromNameAsync).
	local loadProfile = events:FindFirstChild("LoadProfile")
	if loadProfile and loadProfile:IsA("RemoteEvent") then
		loadProfile.OnServerEvent:Connect(function(p, targetPlayerName)
			if p ~= player then return end
			if type(targetPlayerName) ~= "string" or targetPlayerName == "" then return end

			-- Helper: gather profile data from an online player's live objects
			local function gatherOnline(targetPlayer)
				local targetInventory = targetPlayer:FindFirstChild("Inventory")
				if not targetInventory then return nil end

				local profileData = {
					Name = targetPlayer.Name,
					DisplayName = targetPlayer.DisplayName,
					UserId = targetPlayer.UserId,
					ProfileImage = "",
					Level = 1,
					Rank = 1,
					Skin = "",
					EquippedKaiju = "",
					Kills = 0,
					Deaths = 0,
					BestCombo = 0,
					TotalDamage = 0,
					MainKaiju = "",
					Online = true,
				}

				local profileImg = targetInventory:FindFirstChild("ProfileImage")
				if profileImg and profileImg:IsA("StringValue") then
					profileData.ProfileImage = profileImg.Value
				end

				local xpFolder = targetInventory:FindFirstChild("XP")
				if xpFolder then
					local lvl = xpFolder:FindFirstChild("Level")
					if lvl then profileData.Level = lvl.Value end
					local rank = xpFolder:FindFirstChild("Rank")
					if rank then profileData.Rank = rank.Value end
				end

				local skin = targetInventory:FindFirstChild("Skin")
				if skin and skin:IsA("StringValue") then
					profileData.Skin = skin.Value
				end

				local equippedKaiju = targetInventory:FindFirstChild("EquippedKaiju")
				if equippedKaiju and equippedKaiju:IsA("StringValue") then
					profileData.EquippedKaiju = equippedKaiju.Value
				end

				local targetStats = targetPlayer:FindFirstChild("Stats")
				if targetStats then
					local k = targetStats:FindFirstChild("K")
					if k then profileData.Kills = k.Value end
					local d = targetStats:FindFirstChild("D")
					if d then profileData.Deaths = d.Value end
					local bc = targetStats:FindFirstChild("BestCombo")
					if bc then profileData.BestCombo = bc.Value end
					local td = targetStats:FindFirstChild("TotalDamage")
					if td then profileData.TotalDamage = td.Value end
					local mk = targetStats:FindFirstChild("MainKaiju")
					if mk then profileData.MainKaiju = mk.Value end
				end

				return profileData
			end

			-- Helper: gather profile data from DataStore for an offline player
			local function gatherOffline(userId)
				local profileData = {
					Name = "",
					DisplayName = "",
					UserId = userId,
					ProfileImage = "",
					Level = 1,
					Rank = 1,
					Skin = "",
					EquippedKaiju = "",
					Kills = 0,
					Deaths = 0,
					BestCombo = 0,
					TotalDamage = 0,
					MainKaiju = "",
					Online = false,
				}

				-- Load inventory data
				local invSuccess, invData = pcall(function()
					return inventoryStore:GetAsync("Inv_" .. userId)
				end)
				if invSuccess and invData then
					profileData.ProfileImage = invData.ProfileImage or ""
					profileData.Level = invData.Level or 1
					profileData.Rank = invData.Rank or 1
					profileData.Skin = invData.Skin or ""
					if invData.OwnedItems and invData.OwnedItems.EquippedKaiju then
						profileData.EquippedKaiju = invData.OwnedItems.EquippedKaiju
					end
				end

				-- Load stats data
				local statsSuccess, statsData = pcall(function()
					return statsStore:GetAsync("Stats_" .. userId)
				end)
				if statsSuccess and statsData then
					profileData.Kills = statsData.K or 0
					profileData.Deaths = statsData.D or 0
					profileData.BestCombo = statsData.BestCombo or 0
					profileData.TotalDamage = statsData.TotalDamage or 0
					profileData.MainKaiju = statsData.MainKaiju or ""
				end

				return profileData
			end

			-- 1) Try to find the target player online (case-insensitive)
			local targetPlayer = nil
			for _, plr in ipairs(Players:GetPlayers()) do
				if string.lower(plr.Name) == string.lower(targetPlayerName)
					or string.lower(plr.DisplayName) == string.lower(targetPlayerName) then
					targetPlayer = plr
					break
				end
			end

			if targetPlayer then
				local profileData = gatherOnline(targetPlayer)
				if profileData then
					loadProfile:FireClient(player, true, profileData)
				else
					loadProfile:FireClient(player, false, "No inventory")
				end
				return
			end

			-- 2) Player not online — try offline lookup via GetUserIdFromNameAsync
			local userId
			local nameSuccess, nameResult = pcall(function()
				return Players:GetUserIdFromNameAsync(targetPlayerName)
			end)
			if nameSuccess and nameResult then
				userId = nameResult
			end

			if not userId then
				loadProfile:FireClient(player, false, "Player not found")
				return
			end

			-- Gather offline data from DataStore
			local profileData = gatherOffline(userId)
			if not profileData then
				loadProfile:FireClient(player, false, "No data found")
				return
			end

			-- Try to get the player's username and display name for the profile
			local infoSuccess, infoResult = pcall(function()
				return Players:GetPlayerByUserId(userId)
			end)
			if infoSuccess and infoResult then
				-- Player came online while we were looking
				profileData = gatherOnline(infoResult) or profileData
			else
				-- Use the username from the lookup (GetUserIdFromNameAsync validates the name)
				profileData.Name = targetPlayerName
				profileData.DisplayName = targetPlayerName
			end

			loadProfile:FireClient(player, true, profileData)
		end)
	end
end

-- =========================================================================
-- PLAYER LIFECYCLE
-- =========================================================================

local function onPlayerAdded(player)
	print("[PlayerDataManager] onPlayerAdded called for " .. player.Name)

	-- Clear any stale DataLoaded attribute from a previous run (e.g. script reload in Studio).
	-- This ensures the Spawn Script waits for the fresh DataStore load to complete before
	-- reading EquippedKaiju / Skin, preventing a race condition where stale attribute = true
	-- lets the spawn proceed with default/empty values before loadInventory finishes.
	player:SetAttribute("DataLoaded", nil)

	-- Create data structures first (before anything else)
	local inventory = createInventory(player)
	print("[PlayerDataManager] Inventory folder created for " .. player.Name .. " with " .. #inventory:GetChildren() .. " children")
	local settings = createSettings(player)
	print("[PlayerDataManager] Settings folder created for " .. player.Name)
	local stats = createStats(player)
	print("[PlayerDataManager] Stats folder created for " .. player.Name)

	-- Load saved data from DataStores IN PARALLEL to minimize wait time.
	-- Sequential loading can take 3x longer if DataStores are slow/failing.
	local invDone, setDone, statsDone = false, false, false

	task.spawn(function()
		loadInventory(player, inventory)
		invDone = true
	end)

	task.spawn(function()
		loadSettings(player, settings)
		setDone = true
	end)

	task.spawn(function()
		loadStats(player, stats)
		statsDone = true
	end)

	-- Wait for all three to finish, with a hard cap of 12 seconds so we never
	-- block longer than the Spawn script's 15s DataLoaded timeout.
	local waitTime = 0
	while not (invDone and setDone and statsDone) and waitTime < 12 do
		task.wait(0.1)
		waitTime = waitTime + 0.1
	end

	if not (invDone and setDone and statsDone) then
		warn(string.format("[PlayerDataManager] Data loading timed out after 12s for %s (inv:%s set:%s stats:%s) - proceeding with defaults",
			player.Name, tostring(invDone), tostring(setDone), tostring(statsDone)))
	end

	print("[PlayerDataManager] Data loading complete for " .. player.Name .. ", signaling DataLoaded")

	-- Signal that player data has finished loading so other scripts (e.g. Spawn)
	-- know it is safe to read EquippedKaiju / Skin without getting defaults.
	player:SetAttribute("DataLoaded",  true)

	-- Set up auto-save on value changes
	setupAutoSave(player)

	-- Connect to RemoteEvents (in separate thread since it waits for PlayerGui)
	task.spawn(function()
		connectEvents(player)
	end)
end

local function onPlayerRemoving(player)
	-- Clear debounce
	saveDebounces[player] = nil
	-- Final save
	saveAll(player)
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in the game (e.g. when this script is added at runtime)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		onPlayerAdded(player)
	end)
end 