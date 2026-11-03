local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")

-- DataStore for tutorial completion
local tutorialDataStore = DataStoreService:GetDataStore("TutorialData")

local function onPlayerAdded(player)
	-- Wait for the player's character to load
	player.CharacterAdded:Wait()
	
	-- Check if the player has completed the tutorial
	local success, tutorialComplete = pcall(function()
		return tutorialDataStore:GetAsync("Tutorial_" .. player.UserId)
	end)
	
	if not success then
		warn("Failed to load tutorial data for " .. player.Name)
		return
	end
	
	-- If no data exists, create the entry with false
	if tutorialComplete == nil then
		print("Creating new tutorial data for " .. player.Name)
		local setSuccess, setError = pcall(function()
			tutorialDataStore:SetAsync("Tutorial_" .. player.UserId, false)
		end)
		if not setSuccess then
			warn("Failed to create tutorial data: " .. setError)
			return
		end
		tutorialComplete = false
	end
	
	-- If tutorialComplete is false, teleport to Training
	-- If it's true, they've already completed it
	if tutorialComplete == false then
		print(player.Name .. " has not completed the tutorial. Teleporting to Training...")
		TeleportService:TeleportToPlaceByName("Training", player)
	else
		print(player.Name .. " has already completed the tutorial.")
	end
end

-- Handle players who join
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle players who are already in the game (in case of script reload)
for _, player in Players:GetPlayers() do
	task.spawn(function()
		onPlayerAdded(player)
	end)
end