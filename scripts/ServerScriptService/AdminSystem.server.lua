-- Admin Ban/Unban/Grant System (Server-side)
-- Only l0tzie can use these admin commands. Bans are persisted via DataStore.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local ADMIN_USERNAME = "l0tzie"

-- DataStore for banned players (keyed by UserId, value = username)
local banStore = DataStoreService:GetDataStore("BannedPlayers_v1")

-- In-memory ban cache for quick lookups
local bannedUserIds = {}

-- Load banned players from DataStore on startup
local function loadBans()
	local success, data = pcall(function()
		return banStore:GetAsync("BannedList")
	end)
	if success and type(data) == "table" then
		for userId, username in pairs(data) do
			bannedUserIds[tonumber(userId)] = username
		end
		local count = 0
		for _ in pairs(bannedUserIds) do count = count + 1 end
		print("[AdminSystem] Loaded " .. count .. " banned players")
	else
		if not success then
			warn("[AdminSystem] Failed to load ban list from DataStore")
		end
	end
end

-- Save banned players to DataStore
local function saveBans()
	local data = {}
	for userId, username in pairs(bannedUserIds) do
		data[tostring(userId)] = username
	end
	local success, err = pcall(function()
		banStore:SetAsync("BannedList", data)
	end)
	if not success then
		warn("[AdminSystem] Failed to save ban list: " .. tostring(err))
	end
end

-- Check if a player is an admin (case insensitive)
local function isAdmin(player)
	return string.lower(player.Name) == string.lower(ADMIN_USERNAME)
end

-- Get UserId from username (wraps GetUserIdFromNameAsync with pcall)
local function getUserIdFromName(username)
	local success, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(username)
	end)
	if success then
		return userId
	end
	return nil
end

-- Check on join if player is banned
local function onPlayerAdded(player)
	if bannedUserIds[player.UserId] then
		player:Kick("You have been banned from this game.")
		return
	end
end

-- Load bans BEFORE connecting PlayerAdded so the ban list is ready
loadBans()

-- Connect PlayerAdded
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle already-connected players
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		onPlayerAdded(p)
	end)
end

-- Get RemoteEvents
local adminFolder = ReplicatedStorage:WaitForChild("AdminEvents", 10)
if not adminFolder then
	warn("[AdminSystem] AdminEvents folder not found!")
	return
end

local banEvent = adminFolder:WaitForChild("BanEvent")
local unbanEvent = adminFolder:WaitForChild("UnbanEvent")
local grantEvent = adminFolder:WaitForChild("GrantGCellsEvent")
local dealDamageEvent = adminFolder:WaitForChild("DealDamageEvent")
local addLevelEvent = adminFolder:WaitForChild("AddLevelEvent")

-- Ban Event Handler
banEvent.OnServerEvent:Connect(function(player, username)
	if not isAdmin(player) then return end
	if type(username) ~= "string" or username == "" then
		banEvent:FireClient(player, false, "Invalid username.")
		return
	end

	-- Get the UserId from the username
	local targetUserId = getUserIdFromName(username)
	if not targetUserId then
		banEvent:FireClient(player, false, "Could not find user: " .. username)
		return
	end

	-- Check if already banned
	if bannedUserIds[targetUserId] then
		banEvent:FireClient(player, false, username .. " is already banned.")
		return
	end

	-- Add to ban list
	bannedUserIds[targetUserId] = username
	saveBans()

	-- Kick if currently online
	local targetPlayer = Players:GetPlayerByUserId(targetUserId)
	if targetPlayer then
		targetPlayer:Kick("You have been banned from this game.")
	end

	print("[AdminSystem] " .. player.Name .. " banned " .. username .. " (ID: " .. targetUserId .. ")")
	banEvent:FireClient(player, true, "Successfully banned " .. username)
end)

-- Unban Event Handler
unbanEvent.OnServerEvent:Connect(function(player, username)
	if not isAdmin(player) then return end
	if type(username) ~= "string" or username == "" then
		unbanEvent:FireClient(player, false, "Invalid username.")
		return
	end

	-- Get the UserId from the username
	local targetUserId = getUserIdFromName(username)
	if not targetUserId then
		unbanEvent:FireClient(player, false, "Could not find user: " .. username)
		return
	end

	-- Check if banned
	if not bannedUserIds[targetUserId] then
		unbanEvent:FireClient(player, false, username .. " is not banned.")
		return
	end

	-- Remove from ban list
	bannedUserIds[targetUserId] = nil
	saveBans()

	print("[AdminSystem] " .. player.Name .. " unbanned " .. username)
	unbanEvent:FireClient(player, true, "Successfully unbanned " .. username)
end)

-- Grant GCells Event Handler
grantEvent.OnServerEvent:Connect(function(player, targetUsername, amount)
	if not isAdmin(player) then return end
	if type(targetUsername) ~= "string" or targetUsername == "" then
		grantEvent:FireClient(player, false, "Invalid username.")
		return
	end

	local amt = tonumber(amount)
	if not amt or amt <= 0 then
		grantEvent:FireClient(player, false, "Invalid GCells amount.")
		return
	end

	-- Find the target player (must be online to grant GCells)
	local targetPlayer = nil
	for _, p in ipairs(Players:GetPlayers()) do
		if string.lower(p.Name) == string.lower(targetUsername) then
			targetPlayer = p
			break
		end
	end

	if not targetPlayer then
		grantEvent:FireClient(player, false, targetUsername .. " is not currently in the game.")
		return
	end

	-- Find the player's Inventory and GCells value
	local inventory = targetPlayer:FindFirstChild("Inventory")
	if not inventory then
		grantEvent:FireClient(player, false, "Target player has no inventory.")
		return
	end

	local gcells = inventory:FindFirstChild("GCells")
	if not gcells or not gcells:IsA("IntValue") then
		grantEvent:FireClient(player, false, "Target player has no GCells value.")
		return
	end

	-- Grant the GCells
	gcells.Value = gcells.Value + amt

	print("[AdminSystem] " .. player.Name .. " granted " .. amt .. " GCells to " .. targetUsername)
	grantEvent:FireClient(player, true, "Granted " .. amt .. " GCells to " .. targetUsername)
end)

-- Deal 100 Damage Event Handler (damages the admin's own character for testing)
dealDamageEvent.OnServerEvent:Connect(function(player)
	if not isAdmin(player) then return end

	local character = player.Character
	if not character then
		dealDamageEvent:FireClient(player, false, "No character found (are you spawned?)")
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		dealDamageEvent:FireClient(player, false, "No Humanoid found on your character.")
		return
	end

	if humanoid.Health <= 0 then
		dealDamageEvent:FireClient(player, false, "Your character is already dead.")
		return
	end

	humanoid:TakeDamage(100)
	print("[AdminSystem] " .. player.Name .. " dealt 100 damage to their own character (testing)")
	dealDamageEvent:FireClient(player, true, "Dealt 100 damage to your character!")
end)

-- Add Level Event Handler (adds levels to the admin's own player only)
local XPModule = ReplicatedStorage:FindFirstChild("XPModule")
if XPModule then
	XPModule = require(XPModule)
end

addLevelEvent.OnServerEvent:Connect(function(player, amount)
	if not isAdmin(player) then return end

	local amt = tonumber(amount)
	if not amt or amt <= 0 then
		addLevelEvent:FireClient(player, false, "Invalid level amount.")
		return
	end

	-- Find the admin's own XP folder
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		addLevelEvent:FireClient(player, false, "You have no inventory.")
		return
	end

	local xpFolder = inventory:FindFirstChild("XP")
	if not xpFolder then
		addLevelEvent:FireClient(player, false, "You have no XP data.")
		return
	end

	local levelVal = xpFolder:FindFirstChild("Level")
	local rankVal = xpFolder:FindFirstChild("Rank")
	local xpToEarnVal = xpFolder:FindFirstChild("XPToEarn")

	if not levelVal or not rankVal or not xpToEarnVal then
		addLevelEvent:FireClient(player, false, "XP data is incomplete.")
		return
	end

	local oldLevel = levelVal.Value
	local newLevel = oldLevel + amt

	levelVal.Value = newLevel

	-- Recalculate rank and XPToEarn for the new level
	if XPModule then
		rankVal.Value = XPModule.getRankFromLevel(newLevel)
		xpToEarnVal.Value = XPModule.getXPForLevel(newLevel)
	else
		-- Fallback if XPModule is not available
		rankVal.Value = math.floor((newLevel - 1) / 205) + 1
		xpToEarnVal.Value = 300 + ((newLevel - 1) * 50)
	end

	print("[AdminSystem] " .. player.Name .. " added " .. amt .. " levels (" .. oldLevel .. " -> " .. newLevel .. ")")
	addLevelEvent:FireClient(player, true, "Added " .. amt .. " levels! You are now Level " .. newLevel .. ".")
end)

print("[AdminSystem] Admin ban/unban/grant/damage/level system initialized")
