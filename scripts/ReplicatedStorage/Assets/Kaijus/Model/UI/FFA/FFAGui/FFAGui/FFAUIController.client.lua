-- FFA (Free For All) UI Controller
-- Displays: round timer, first-place player info (name, rank, kills, PFP),
-- and the local player's info (name, rank, kills, PFP, place).
-- Self-contained: clone the FFAGui ScreenGui to a player's PlayerGui to activate.
-- Not wired to any activation system yet.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Safely require XPModule
local XPModule
pcall(function()
	XPModule = require(ReplicatedStorage:FindFirstChild("XPModule"))
end)

local localPlayer = Players.LocalPlayer

-- UI references
local gui = script.Parent
local timerFrame = gui:FindFirstChild("Timer")
local timerLabel = timerFrame and timerFrame:FindFirstChild("TimeTXT")
local firstFrame = gui:FindFirstChild("First")
local youFrame = gui:FindFirstChild("You")

-- First place elements
local firstName = firstFrame and firstFrame:FindFirstChild("Playername")
local firstKills = firstFrame and firstFrame:FindFirstChild("KAmount")
local firstPlace = firstFrame and firstFrame:FindFirstChild("Place")
local firstRank = firstFrame and firstFrame:FindFirstChild("Rank")
local firstPFP = firstFrame and firstFrame:FindFirstChild("PFP")
local firstPlayerImage = firstPFP and firstPFP:FindFirstChild("PlayerImage")

-- You (local player) elements
local youName = youFrame and youFrame:FindFirstChild("Playername")
local youKills = youFrame and youFrame:FindFirstChild("KAmount")
local youPlace = youFrame and youFrame:FindFirstChild("Place")
local youRank = youFrame and youFrame:FindFirstChild("Rank")
local youPFP = youFrame and youFrame:FindFirstChild("PFP")
local youPlayerImage = youPFP and youPFP:FindFirstChild("PlayerImage")

-- State
local roundKills = {} -- [userId] = killCount, synced from server
local firstPlaceUserId = 0 -- from server NumberValue

-- Rank icon templates from ReplicatedStorage.Assets.Kaijus.Model.UI.InGame.RankIcons
local rankIconsFolder = ReplicatedStorage:FindFirstChild("Assets")
	and ReplicatedStorage.Assets:FindFirstChild("Kaijus")
	and ReplicatedStorage.Assets.Kaijus:FindFirstChild("Model")
	and ReplicatedStorage.Assets.Kaijus.Model:FindFirstChild("UI")
	and ReplicatedStorage.Assets.Kaijus.Model.UI:FindFirstChild("InGame")
	and ReplicatedStorage.Assets.Kaijus.Model.UI.InGame:FindFirstChild("RankIcons")

-- Ruby and Emerald map to Platinum (no icon templates exist for those ranks)
local RANK_NAME_TO_FOLDER = {
	Ruby = "Platinum",
	Emerald = "Platinum",
}

-- Get rank icon image and color for a given rank number
local function getRankIcon(rankNumber)
	if not XPModule or not rankIconsFolder then return nil, nil end
	local rankName = XPModule.getRankName(rankNumber)
	local folderName = RANK_NAME_TO_FOLDER[rankName] or rankName
	local template = rankIconsFolder:FindFirstChild(folderName) or rankIconsFolder:FindFirstChild("Bronze")
	if not template then return nil, rankName end
	local holder = template:FindFirstChild("PlayerHolder")
	if not holder then return nil, rankName end
	local rank = holder:FindFirstChild("Rank")
	if not rank then return nil, rankName end
	return {image = rank.Image, color = rank.ImageColor3}, rankName
end

-- Get a player's rank from their Inventory/XP folder
local function getPlayerRank(player)
	if not player then return 1 end
	local inv = player:FindFirstChild("Inventory")
	if not inv then return 1 end
	local xp = inv:FindFirstChild("XP")
	if not xp then return 1 end
	local rank = xp:FindFirstChild("Rank")
	return rank and rank.Value or 1
end

-- Format seconds as M:SS
local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%d:%02d", m, s)
end

-- Set a player's thumbnail on a PFP PlayerImage
local thumbnailCache = {}
local function setPlayerThumbnail(playerImage, userId)
	if not playerImage then return end
	if thumbnailCache[userId] then
		playerImage.Image = thumbnailCache[userId]
		return
	end
	task.spawn(function()
		local ok, thumbUrl = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		end)
		if ok and thumbUrl then
			thumbnailCache[userId] = thumbUrl
			playerImage.Image = thumbUrl
			local imValue = playerImage:FindFirstChild("IMValue")
			if imValue then
				imValue.Value = userId
			end
		end
	end)
end

-- Set rank icon on a Rank ImageLabel
local function setRankIcon(rankLabel, rankNumber)
	if not rankLabel then return end
	local icon = getRankIcon(rankNumber)
	if icon then
		rankLabel.Image = icon.image
		rankLabel.ImageColor3 = icon.color
		rankLabel.ImageTransparency = 0
	else
		rankLabel.ImageTransparency = 1
	end
end

-- Calculate the local player's place based on kill counts
local function calculatePlace(userId)
	local myKills = roundKills[userId] or 0
	local place = 1
	for otherId, kills in pairs(roundKills) do
		if otherId ~= userId and kills > myKills then
			place = place + 1
		end
	end
	return place
end

-- Format a place number as ordinal string (1st, 2nd, 3rd, etc.)
local function formatPlace(n)
	local suffix = "th"
	local lastDigit = n % 10
	local lastTwo = n % 100
	if lastTwo < 11 or lastTwo > 13 then
		if lastDigit == 1 then suffix = "st"
		elseif lastDigit == 2 then suffix = "nd"
		elseif lastDigit == 3 then suffix = "rd" end
	end
	return tostring(n) .. suffix
end

-- Update the First place display
local function updateFirstPlace()
	if not firstFrame then return end

	if firstPlaceUserId == 0 then
		if firstName then firstName.Text = "" end
		if firstKills then firstKills.Text = "0 K" end
		if firstPlace then firstPlace.Text = "1st" end
		if firstRank then firstRank.ImageTransparency = 1 end
		if firstPlayerImage then firstPlayerImage.Image = "" end
		return
	end

	local player = Players:GetPlayerByUserId(firstPlaceUserId)
	if player then
		if firstName then firstName.Text = player.DisplayName end
		setPlayerThumbnail(firstPlayerImage, player.UserId)
		setRankIcon(firstRank, getPlayerRank(player))
	else
		-- Player left but still has first place; keep last known info
		if firstName and firstName.Text == "" then
			firstName.Text = "Unknown"
		end
	end

	local kills = roundKills[firstPlaceUserId] or 0
	if firstKills then firstKills.Text = tostring(kills) .. " K" end
	if firstPlace then firstPlace.Text = "1st" end
end

-- Update the You (local player) display
local function updateYouDisplay()
	if not youFrame or not localPlayer then return end

	if youName then youName.Text = localPlayer.DisplayName end

	local kills = roundKills[localPlayer.UserId] or 0
	if youKills then youKills.Text = tostring(kills) .. " K" end

	local place = calculatePlace(localPlayer.UserId)
	if youPlace then youPlace.Text = formatPlace(place) end

	setRankIcon(youRank, getPlayerRank(localPlayer))
	setPlayerThumbnail(youPlayerImage, localPlayer.UserId)
end

-- Update timer
local function updateTimer(value)
	if timerLabel then
		timerLabel.Text = formatTime(value)
	end
end

-- Connect to server-side FFA values
local function findFFAFolder()
	local server = workspace:FindFirstChild("Server")
	if not server then return nil end
	local gms = server:FindFirstChild("GameModeScripts")
	if not gms then return nil end
	return gms:FindFirstChild("FFA")
end

local function connectServerValues()
	local ffa = findFFAFolder()
	if not ffa then return false end

	local timer = ffa:FindFirstChild("Time")
	if timer then
		updateTimer(timer.Value)
		timer.Changed:Connect(updateTimer)
	end

	local first = ffa:FindFirstChild("First")
	if first then
		firstPlaceUserId = first.Value
		first.Changed:Connect(function(value)
			firstPlaceUserId = value
			updateFirstPlace()
		end)
		updateFirstPlace()
	end

	return timer ~= nil
end

-- Handle kill update data from server
local function handleKillUpdate(killsData)
	if type(killsData) == "table" then
		roundKills = killsData
	end
	updateFirstPlace()
	updateYouDisplay()
end

-- Connect to RemoteEvents (created dynamically by the FFA server script)
local function connectRemoteEvents()
	local killUpdate = ReplicatedStorage:FindFirstChild("KillUpdate")
	if killUpdate and killUpdate:IsA("RemoteEvent") then
		killUpdate.OnClientEvent:Connect(handleKillUpdate)
	end

	local roundState = ReplicatedStorage:FindFirstChild("RoundState")
	if roundState and roundState:IsA("RemoteEvent") then
		roundState.OnClientEvent:Connect(function(state)
			if state == "RoundEnd" then
				roundKills = {}
				firstPlaceUserId = 0
				updateFirstPlace()
				updateYouDisplay()
				if timerLabel then timerLabel.Text = "0:00" end
			elseif state == "RoundStart" then
				roundKills = {}
				updateFirstPlace()
				updateYouDisplay()
			end
		end)
	end
end

-- Initialize
local function init()
	-- Set defaults
	if timerLabel then timerLabel.Text = "0:00" end
	if youName and localPlayer then youName.Text = localPlayer.DisplayName end
	if youKills then youKills.Text = "0 K" end
	if youPlace then youPlace.Text = "--" end

	-- Connect server values
	if not connectServerValues() then
		-- Watch for server folder creation
		workspace.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "FFA" and descendant:IsA("Folder") then
				task.wait(0.1)
				connectServerValues()
			end
		end)
	end

	-- Connect remote events (retry since they're created dynamically)
	connectRemoteEvents()
	ReplicatedStorage.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("RemoteEvent") and (descendant.Name == "KillUpdate" or descendant.Name == "RoundState") then
			connectRemoteEvents()
		end
	end)

	-- Initial you display
	updateYouDisplay()

	-- Update local player info when their inventory/XP loads or changes
	if localPlayer then
		local function watchInventory()
			local inv = localPlayer:FindFirstChild("Inventory")
			if inv then
				local xp = inv:FindFirstChild("XP")
				if xp then
					local rank = xp:FindFirstChild("Rank")
					if rank then
						rank.Changed:Connect(function()
							updateYouDisplay()
						end)
						updateYouDisplay()
					end
				end
			end
		end

		-- Try immediately
		watchInventory()

		-- Watch for inventory creation
		localPlayer.ChildAdded:Connect(function(child)
			if child.Name == "Inventory" then
				task.wait(0.5)
				watchInventory()
			end
		end)
	end
end

init()