-- TeamBattle Server Script (DISABLED)
-- Team deathmatch: first team to reach ScoreToWin kills wins, or timer ends
-- Loads maps from ReplicatedStorage.Assets.Maps into Workspace as "Map"

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- References to game mode values
local modeFolder = script.Parent.GameModeScripts.TeamBattle
local TimerValue = modeFolder.Timer
local TickValue = modeFolder.Tick
local ScoreToWin = modeFolder.ScoreToWin
local RedTeam = modeFolder.RedTeam
local BlueTeam = modeFolder.BlueTeam

local INTERMISSION_TIME = 5

-- UI template
local uiFolder = ReplicatedStorage.Assets.Kaijus.Model.UI.TeamBattle

-- Reward helpers
local function AwardGCells(player, amount)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local gcells = inventory:FindFirstChild("GCells")
	if gcells then
		gcells.Value = gcells.Value + amount
		print("[Team] Awarded " .. amount .. " GCells to " .. player.Name)
	end
end

local function AwardLootbox(player, amount)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local lootboxes = inventory:FindFirstChild("Lootboxes")
	if lootboxes then
		lootboxes.Value = lootboxes.Value + amount
		print("[Team] Awarded " .. amount .. " lootbox(es) to " .. player.Name)
	end
end

-- Function to assign the TeamBattle GUI to a player's PlayerGui
local function AssignUI(player)
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end
	if playerGui:FindFirstChild("TBGUI") then return end
	if not uiFolder then return end
	local template = uiFolder:FindFirstChild("TBGUI")
	if template and template:IsA("ScreenGui") then
		local gui = template:Clone()
		gui.ResetOnSpawn = false
		gui.Parent = playerGui
		print("[Team] Assigned UI to " .. player.Name)
	end
end

-- Track which team each player is on: [userId] = "Red" or "Blue"
local playerTeams = {}

-- RemoteEvent for round state notifications
local roundStateEvent = ReplicatedStorage:FindFirstChild("RoundState")
if not roundStateEvent then
	roundStateEvent = Instance.new("RemoteEvent")
	roundStateEvent.Name = "RoundState"
	roundStateEvent.Parent = ReplicatedStorage
end

-- RemoteEvent for kill/score updates
local killUpdateEvent = ReplicatedStorage:FindFirstChild("KillUpdate")
if not killUpdateEvent then
	killUpdateEvent = Instance.new("RemoteEvent")
	killUpdateEvent.Name = "KillUpdate"
	killUpdateEvent.Parent = ReplicatedStorage
end

-- Function to assign players to teams (alternating)
local function AssignTeams()
	local players = Players:GetPlayers()
	table.sort(players, function(a, b) return a.UserId < b.UserId end)

	for i, player in ipairs(players) do
		if i % 2 == 1 then
			playerTeams[player.UserId] = "Red"
		else
			playerTeams[player.UserId] = "Blue"
		end
	end
end

-- Function to get a player's team
local function GetPlayerTeam(player)
	return playerTeams[player.UserId]
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
		print("[Team] Moved " .. count .. " buildings from map to Buildings folder")
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
		print("[Team] Cleared " .. count .. " map buildings from Buildings folder")
	end
end

-- Function to load a random map from ReplicatedStorage.Assets.Maps
local function LoadMap()
	print("[Team] Loading new map...")

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
		warn("[Team] No maps found in ReplicatedStorage.Assets.Maps!")
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
	print("[Team] Map loaded successfully")
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

-- Function to reset team scores
local function ResetScores()
	RedTeam.Score.Value = 0
	BlueTeam.Score.Value = 0
	killUpdateEvent:FireAllClients({Red = 0, Blue = 0})
end

-- Function to add a kill to a team's score
local function AddTeamKill(teamName)
	if teamName == "Red" then
		RedTeam.Score.Value = RedTeam.Score.Value + 1
	elseif teamName == "Blue" then
		BlueTeam.Score.Value = BlueTeam.Score.Value + 1
	end
	killUpdateEvent:FireAllClients({Red = RedTeam.Score.Value, Blue = BlueTeam.Score.Value})
end

-- Expose kill tracking for external scripts
_G.TeamKillTracking = {
	AddKill = AddTeamKill,
	GetTeam = GetPlayerTeam,
	AssignTeams = AssignTeams,
}

-- Function to check if a team has won
local function CheckWinCondition()
	if RedTeam.Score.Value >= ScoreToWin.Value then
		return "Red"
	elseif BlueTeam.Score.Value >= ScoreToWin.Value then
		return "Blue"
	end
	return nil
end

-- Function to end the current round
local function EndRound(winningTeam)
	print("[Team] Round ending...")

	local spawnModule = _G.KaijuSpawnModule
	if spawnModule and spawnModule.SetSpawningAllowed then
		spawnModule.SetSpawningAllowed(false)
	end

	if winningTeam then
		print("[Team] Winning team: " .. winningTeam)
	else
		print("[Team] Round ended by timer")
	end

	roundStateEvent:FireAllClients("RoundEnd")

	KillAllPlayers()

	task.wait(0.5)

	local map = workspace:FindFirstChild("Map")
	if map then
		map:Destroy()
		print("[Team] Map destroyed")
	end

	-- Clear map-sourced buildings from the Buildings folder
	ClearMapBuildings()

	print("[Team] Intermission: " .. INTERMISSION_TIME .. " seconds")
	task.wait(INTERMISSION_TIME)

	-- Reset scores for new round
	ResetScores()

	-- Reassign teams
	AssignTeams()

	LoadMap()

	if spawnModule and spawnModule.SetSpawningAllowed then
		spawnModule.SetSpawningAllowed(true)
	end

	roundStateEvent:FireAllClients("RoundStart")
	RespawnAllPlayers()

	print("[Team] New round started!")

	-- Award rewards to all players on the winning team
	if winningTeam then
		for _, player in ipairs(Players:GetPlayers()) do
			if GetPlayerTeam(player) == winningTeam then
				AwardGCells(player, 30)
				AwardLootbox(player, 1)
			end
		end
	end
end

-- Track player deaths to award kills to the killer's team
-- This uses a simple approach: when a player dies, we try to find the last attacker
local function OnCharacterDied(player)
	-- Kill credit is handled by the external damage system
-- which should call _G.TeamKillTracking.AddKill(teamName)
-- Here we just check win condition after a death
	task.wait(0.2)
	local winner = CheckWinCondition()
	if winner then
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
	-- Assign team if not already assigned
	if not playerTeams[player.UserId] then
		-- Count players on each team and assign to the smaller one
		local redCount, blueCount = 0, 0
		for _, team in pairs(playerTeams) do
			if team == "Red" then redCount = redCount + 1
			elseif team == "Blue" then blueCount = blueCount + 1 end
		end
		playerTeams[player.UserId] = redCount <= blueCount and "Red" or "Blue"
	end
end)

Players.PlayerRemoving:Connect(function(player)
	playerTeams[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	SetupPlayer(player)
	AssignUI(player)
end

-- Initial setup
AssignTeams()
ResetScores()
TimerValue.Value = 500
TickValue.Value = 0
LoadMap()

-- Main game loop
while true do
	local currentTime = TimerValue.Value

	while currentTime > 0 do
		task.wait(1)
		currentTime = currentTime - 1
		TimerValue.Value = currentTime
		TickValue.Value = TickValue.Value + 1

		-- Check if a team reached the score to win
		local winner = CheckWinCondition()
		if winner then
			EndRound(winner)
			break
		end
	end

	-- If timer ran out
	if currentTime <= 0 then
		-- Determine winner by highest score, or nil if tied
		if RedTeam.Score.Value > BlueTeam.Score.Value then
			EndRound("Red")
		elseif BlueTeam.Score.Value > RedTeam.Score.Value then
			EndRound("Blue")
		else
			EndRound(nil) -- Tie
		end
	end

	-- Reset timer for next round
	TimerValue.Value = 500
	TickValue.Value = 0
end