-- FFA Server Script (DISABLED)
-- Free-for-all: round ends when timer reaches 0
-- Loads maps from ReplicatedStorage.Assets.Maps into Workspace as "Map"
-- Tracks kills and first place player

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- References to game mode values
local modeFolder = script.Parent.GameModeScripts.FFA
local TimeValue = modeFolder.Time
local RoundTimeValue = modeFolder.RoundTime
local FirstValue = modeFolder.First

local INTERMISSION_TIME = 5

-- UI template
local uiFolder = ReplicatedStorage.Assets.Kaijus.Model.UI.FFA

-- Reward helpers
local function AwardGCells(player, amount)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local gcells = inventory:FindFirstChild("GCells")
	if gcells then
		gcells.Value = gcells.Value + amount
		print("[FFA] Awarded " .. amount .. " GCells to " .. player.Name)
	end
end

local function AwardLootbox(player, amount)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local lootboxes = inventory:FindFirstChild("Lootboxes")
	if lootboxes then
		lootboxes.Value = lootboxes.Value + amount
		print("[FFA] Awarded " .. amount .. " lootbox(es) to " .. player.Name)
	end
end

-- Function to assign the FFA GUI to a player's PlayerGui
local function AssignUI(player)
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end
	if playerGui:FindFirstChild("FFAGui") then return end
	if not uiFolder then return end
	local template = uiFolder:FindFirstChild("FFAGui")
	if template and template:IsA("ScreenGui") then
		local gui = template:Clone()
		gui.ResetOnSpawn = false
		gui.Parent = playerGui
		print("[FFA] Assigned UI to " .. player.Name)
	end
end

-- Kill tracking per round: [userId] = killCount
local roundKills = {}

-- RemoteEvent for round state notifications
local roundStateEvent = ReplicatedStorage:FindFirstChild("RoundState")
if not roundStateEvent then
	roundStateEvent = Instance.new("RemoteEvent")
	roundStateEvent.Name = "RoundState"
	roundStateEvent.Parent = ReplicatedStorage
end

-- RemoteEvent for kill/leaderboard updates
local killUpdateEvent = ReplicatedStorage:FindFirstChild("KillUpdate")
if not killUpdateEvent then
	killUpdateEvent = Instance.new("RemoteEvent")
	killUpdateEvent.Name = "KillUpdate"
	killUpdateEvent.Parent = ReplicatedStorage
end

-- Function to get a player's kill count this round
local function getKills(userId)
	return roundKills[userId] or 0
end

-- Function to find and update the First place player
local function updateFirstPlace()
	local bestUserId = 0
	local bestKills = 0

	for userId, kills in pairs(roundKills) do
		if kills > bestKills then
			bestKills = kills
			bestUserId = userId
		end
	end

	FirstValue.Value = bestUserId
end

-- Function to add a kill for a player
local function addKill(userId)
	roundKills[userId] = (roundKills[userId] or 0) + 1
	updateFirstPlace()
	killUpdateEvent:FireAllClients(roundKills)
end

-- Expose kill tracking functions globally so Event.Script can call them
_G.FFAKillTracking = {
	addKill = addKill,
	getKills = getKills,
	roundKills = roundKills,
}

-- Function to reset all kill counts for a new round
local function resetRoundKills()
	for userId in pairs(roundKills) do
		roundKills[userId] = nil
	end
	FirstValue.Value = 0
	killUpdateEvent:FireAllClients(roundKills)
end

-- Function to move building models from a loaded map into Workspace.Buildings
local function MoveMapBuildings(map)
	local buildingsFolder = workspace:FindFirstChild("Buildings")
	if not buildingsFolder then
		buildingsFolder = Instance.new("Folder")
		buildingsFolder.Name = "Buildings"
		buildingsFolder.Parent = workspace
	end
	local count = 0
	for _, child in ipairs(map:GetChildren()) do
		if child:IsA("Model") and child.Name == "Building" then
			child:SetAttribute("FromMap", true)
			child.Parent = buildingsFolder
			count = count + 1
		end
	end
	if count > 0 then
		print("[FFA] Moved " .. count .. " buildings from map to Buildings folder")
	end
end

-- Function to clear map-sourced buildings from Workspace.Buildings
local function ClearMapBuildings()
	local buildingsFolder = workspace:FindFirstChild("Buildings")
	if not buildingsFolder then return end
	local count = 0
	for _, building in ipairs(buildingsFolder:GetChildren()) do
		if building:GetAttribute("FromMap") then
			building:Destroy()
			count = count + 1
		end
	end
	if count > 0 then
		print("[FFA] Cleared " .. count .. " map buildings from Buildings folder")
	end
end

-- Function to load a random map from ReplicatedStorage.Assets.Maps
local function LoadMap()
	print("[FFA] Loading new map...")

	local existingMap = workspace:FindFirstChild("Map")
	if existingMap then
		existingMap:Destroy()
	end

	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("Sky") then
			child:Destroy()
		end
	end

	local mapsFolder = ReplicatedStorage.Assets.Maps
	local maps = mapsFolder:GetChildren()
	if #maps == 0 then
		warn("[FFA] No maps found in ReplicatedStorage.Assets.Maps!")
		return false
	end

	local map = maps[math.random(1, #maps)]:Clone()
	map.Name = "Map"

	for _, descendant in ipairs(map:GetDescendants()) do
		if descendant:IsA("UnionOperation") then
			pcall(function()
				descendant.CollisionFidelity = Enum.CollisionFidelity.Precise
			end)
		elseif descendant:IsA("MeshPart") then
			pcall(function()
				descendant.CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition
			end)
		end
	end

	map.Parent = workspace

	-- Move building models from the map into Workspace.Buildings
	MoveMapBuildings(map)

	local sky = map:FindFirstChild("Sky")
	if sky then
		sky:Clone().Parent = Lighting
	end

	local song = map:FindFirstChild("Song")
	if song and song:IsA("Sound") then
		song:Play()
	end

	local ambience = map:FindFirstChild("Ambience")
	if ambience and ambience:IsA("Sound") then
		ambience:Play()
	end

	local brightness = map:FindFirstChild("Brightness")
	if brightness then
		Lighting.Brightness = brightness.Value
	end

	local ambient = map:FindFirstChild("Ambient")
	if ambient then
		Lighting.Ambient = ambient.Value
	end

	task.wait(1)
	print("[FFA] Map loaded successfully")
	return true
end

-- Function to kill all players
local function KillAllPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end
	end
end

-- Function to respawn all players
local function RespawnAllPlayers()
	local spawnModule = _G.KaijuSpawnModule
	for _, player in ipairs(Players:GetPlayers()) do
		if spawnModule and spawnModule.SpawnPlayer then
			spawnModule.SpawnPlayer(player)
		else
			player:LoadCharacter()
		end
	end
end

-- Function to end the current round
local function EndRound()
	print("[FFA] Round ending...")

	local spawnModule = _G.KaijuSpawnModule
	if spawnModule and spawnModule.SetSpawningAllowed then
		spawnModule.SetSpawningAllowed(false)
	end

	roundStateEvent:FireAllClients("RoundEnd")

	-- Capture first place player BEFORE resetting kills
	local firstUserId = FirstValue.Value
	local firstPlayer = nil
	if firstUserId > 0 then
		firstPlayer = Players:GetPlayerByUserId(firstUserId)
	end

	KillAllPlayers()
	resetRoundKills()

	task.wait(0.5)

	local map = workspace:FindFirstChild("Map")
	if map then
		map:Destroy()
		print("[FFA] Map destroyed")
	end

	-- Clear map-sourced buildings from the Buildings folder
	ClearMapBuildings()

	print("[FFA] Intermission: " .. INTERMISSION_TIME .. " seconds")
	task.wait(INTERMISSION_TIME)

	LoadMap()

	if spawnModule and spawnModule.SetSpawningAllowed then
		spawnModule.SetSpawningAllowed(true)
	end

	roundStateEvent:FireAllClients("RoundStart")
	RespawnAllPlayers()

	print("[FFA] New round started!")

	-- Award 30 GCells and 1 Lootbox to the first place player
	if firstPlayer then
		AwardGCells(firstPlayer, 10)
		AwardLootbox(firstPlayer, 1)
	end
end

-- Assign UI to players when they join
Players.PlayerAdded:Connect(function(player)
	AssignUI(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	AssignUI(player)
end

-- Clean up kill tracking when a player leaves
Players.PlayerRemoving:Connect(function(player)
	roundKills[player.UserId] = nil
	updateFirstPlace()
end)

-- Initial reset to ensure clean state
resetRoundKills()
TimeValue.Value = RoundTimeValue.Value

-- Initial map load
LoadMap()

-- Main game loop
while true do
	local currentTime = RoundTimeValue.Value
	TimeValue.Value = currentTime

	while currentTime > 0 do
		task.wait(1)
		currentTime = currentTime - 1
		TimeValue.Value = currentTime
	end

	-- Timer ended
	EndRound()
end