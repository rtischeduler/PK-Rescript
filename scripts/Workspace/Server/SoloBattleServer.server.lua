-- SoloBattle Server Script (DISABLED)
-- Last man standing: round ends when one player remains or timer hits 0
-- Loads maps from ReplicatedStorage.Assets.Maps into Workspace as "Map"

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- References to game mode values
local modeFolder = script.Parent.GameModeScripts.SoloBattle
local TimerValue = modeFolder.Timer
local TickValue = modeFolder.Tick

local INTERMISSION_TIME = 5

-- UI template
local uiFolder = ReplicatedStorage.Assets.Kaijus.Model.UI.SoloBattle

-- Reward helpers
local function AwardGCells(player, amount)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local gcells = inventory:FindFirstChild("GCells")
	if gcells then
		gcells.Value = gcells.Value + amount
		print("[Solo] Awarded " .. amount .. " GCells to " .. player.Name)
	end
end

local function AwardLootbox(player, amount)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local lootboxes = inventory:FindFirstChild("Lootboxes")
	if lootboxes then
		lootboxes.Value = lootboxes.Value + amount
		print("[Solo] Awarded " .. amount .. " lootbox(es) to " .. player.Name)
	end
end

-- Function to assign the SoloBattle GUI to a player's PlayerGui
local function AssignUI(player)
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end
	if playerGui:FindFirstChild("SoloGUI") then return end
	if not uiFolder then return end
	local template = uiFolder:FindFirstChild("SoloGUI")
	if template and template:IsA("ScreenGui") then
		local gui = template:Clone()
		gui.ResetOnSpawn = false
		gui.Parent = playerGui
		print("[Solo] Assigned UI to " .. player.Name)
	end
end

-- RemoteEvent for round state notifications
local roundStateEvent = ReplicatedStorage:FindFirstChild("RoundState")
if not roundStateEvent then
	roundStateEvent = Instance.new("RemoteEvent")
	roundStateEvent.Name = "RoundState"
	roundStateEvent.Parent = ReplicatedStorage
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
		print("[Solo] Moved " .. count .. " buildings from map to Buildings folder")
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
		print("[Solo] Cleared " .. count .. " map buildings from Buildings folder")
	end
end

-- Function to load a random map from ReplicatedStorage.Assets.Maps
local function LoadMap()
	print("[Solo] Loading new map...")

	-- Remove existing map if any
	local existingMap = workspace:FindFirstChild("Map")
	if existingMap then
		existingMap:Destroy()
	end

	-- Clear old sky from Lighting
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("Sky") then
			child:Destroy()
		end
	end

	-- Load random map from ReplicatedStorage.Assets.Maps
	local mapsFolder = ReplicatedStorage.Assets.Maps
	local maps = mapsFolder:GetChildren()
	if #maps == 0 then
		warn("[Solo] No maps found in ReplicatedStorage.Assets.Maps!")
		return false
	end

	local map = maps[math.random(1, #maps)]:Clone()
	map.Name = "Map"

	-- Fix collision fidelity for better physics
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

	-- Apply sky
	local sky = map:FindFirstChild("Sky")
	if sky then
		sky:Clone().Parent = Lighting
	end

	-- Play music
	local song = map:FindFirstChild("Song")
	if song and song:IsA("Sound") then
		song:Play()
	end

	-- Play ambience
	local ambience = map:FindFirstChild("Ambience")
	if ambience and ambience:IsA("Sound") then
		ambience:Play()
	end

	-- Apply lighting settings
	local brightness = map:FindFirstChild("Brightness")
	if brightness then
		Lighting.Brightness = brightness.Value
	end

	local ambient = map:FindFirstChild("Ambient")
	if ambient then
		Lighting.Ambient = ambient.Value
	end

	task.wait(1)
	print("[Solo] Map loaded successfully")
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

-- Function to count alive players
local function CountAlivePlayers()
	local count = 0
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				count = count + 1
			end
		end
	end
	return count
end

-- Function to get the last alive player
local function GetLastAlivePlayer()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				return player
			end
		end
	end
	return nil
end

-- Function to end the current round
local function EndRound(winner)
	print("[Solo] Round ending...")

	local spawnModule = _G.KaijuSpawnModule
	if spawnModule and spawnModule.SetSpawningAllowed then
		spawnModule.SetSpawningAllowed(false)
	end

	if winner then
		print("[Solo] Winner: " .. winner.Name)
	else
		print("[Solo] Round ended by timer (no winner)")
	end

	roundStateEvent:FireAllClients("RoundEnd")

	KillAllPlayers()

	task.wait(0.5)

	local map = workspace:FindFirstChild("Map")
	if map then
		map:Destroy()
		print("[Solo] Map destroyed")
	end

	-- Clear map-sourced buildings from the Buildings folder
	ClearMapBuildings()

	print("[Solo] Intermission: " .. INTERMISSION_TIME .. " seconds")
	task.wait(INTERMISSION_TIME)

	LoadMap()

	if spawnModule and spawnModule.SetSpawningAllowed then
		spawnModule.SetSpawningAllowed(true)
	end

	roundStateEvent:FireAllClients("RoundStart")
	RespawnAllPlayers()

	print("[Solo] New round started!")

	-- Award rewards to the winner
	if winner then
		AwardGCells(winner, 20)
		AwardLootbox(winner, 1)
	end
end

-- Track player deaths to detect last man standing
local function OnCharacterDied(player)
	task.wait(0.1) -- small delay to let health settle
	if #Players:GetPlayers() < 2 then return end -- need at least 2 players

	local alive = CountAlivePlayers()
	if alive <= 1 then
		local winner = GetLastAlivePlayer()
		EndRound(winner)
	end
end

local function SetupPlayer(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				task.spawn(OnCharacterDied, player)
			end)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	SetupPlayer(player)
	AssignUI(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	SetupPlayer(player)
	AssignUI(player)
end

-- Initial reset to ensure clean state
TimerValue.Value = 500
TickValue.Value = 0

-- Initial map load
LoadMap()

-- Main game loop
while true do
	local currentTime = TimerValue.Value

	while currentTime > 0 do
		task.wait(1)
		currentTime = currentTime - 1
		TimerValue.Value = currentTime
		TickValue.Value = TickValue.Value + 1

		-- Check if only one player is alive (win condition)
		if #Players:GetPlayers() >= 2 and CountAlivePlayers() <= 1 then
			local winner = GetLastAlivePlayer()
			EndRound(winner)
			break
		end
	end

	-- If timer ran out without a break (no winner found via loop check)
	if currentTime <= 0 then
		EndRound(GetLastAlivePlayer())
	end

	-- Reset timer for next round
	TimerValue.Value = 500
	TickValue.Value = 0
end