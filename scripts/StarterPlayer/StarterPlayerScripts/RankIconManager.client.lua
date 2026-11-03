-- RankIconManager: Updates rank icons in GameGui and Menu based on the local player's rank.
-- Uses RankIcons templates from ReplicatedStorage.Assets.Kaijus.Model.UI.InGame.RankIcons
-- Rank is an IntValue (1=Bronze, 2=Silver, 3=Gold, 4=Diamond, 5=Ruby, 6=Emerald)
-- Ruby and Emerald map to Platinum since those icon templates don't exist.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local XPModule = require(ReplicatedStorage:WaitForChild("XPModule"))
local localPlayer = Players.LocalPlayer
local rankIconsFolder = ReplicatedStorage:WaitForChild("Assets").Kaijus.Model.UI.InGame.RankIcons

-- Rank names that don't have icon templates get mapped to the closest available
local RANK_NAME_TO_FOLDER = {
	Ruby = "Platinum",
	Emerald = "Platinum",
}

-- Get the rank icon template for a given rank number
local function getRankTemplate(rankNumber)
	local rankName = XPModule.getRankName(rankNumber)
	local folderName = RANK_NAME_TO_FOLDER[rankName] or rankName
	local template = rankIconsFolder:FindFirstChild(folderName)
	if not template then
		template = rankIconsFolder:FindFirstChild("Bronze")
	end
	return template, rankName
end

-- Copy gradient properties from source UIGradient to destination
local function copyGradient(srcGradient, destParent)
	local dest = destParent:FindFirstChildOfClass("UIGradient")
	if not dest then
		dest = Instance.new("UIGradient")
		dest.Parent = destParent
	end
	dest.Color = srcGradient.Color
	dest.Transparency = srcGradient.Transparency
	dest.Rotation = srcGradient.Rotation
	dest.Offset = srcGradient.Offset
	dest.Scale = srcGradient.Scale
	dest.Enabled = srcGradient.Enabled
end

-- Update a target PlayerHolder with rank icon properties from the template
local function updatePlayerHolder(targetHolder, templateHolder)
	if not targetHolder or not templateHolder then return end

	-- Update Rank ImageLabel
	local targetRank = targetHolder:FindFirstChild("Rank")
	local templateRank = templateHolder:FindFirstChild("Rank")
	if targetRank and templateRank then
		targetRank.Image = templateRank.Image
		targetRank.ImageColor3 = templateRank.ImageColor3
		targetRank.ImageTransparency = templateRank.ImageTransparency
		targetRank.ZIndex = templateRank.ZIndex
		targetRank.Size = templateRank.Size
		targetRank.Position = templateRank.Position
		targetRank.AnchorPoint = templateRank.AnchorPoint
	end

	-- Update RankTxt ImageLabel
	local targetRankTxt = targetHolder:FindFirstChild("RankTxt")
	local templateRankTxt = templateHolder:FindFirstChild("RankTxt")
	if targetRankTxt and templateRankTxt then
		targetRankTxt.Image = templateRankTxt.Image
		targetRankTxt.ImageColor3 = templateRankTxt.ImageColor3
		targetRankTxt.ImageTransparency = templateRankTxt.ImageTransparency
	end

	-- Update Ring ImageLabel + UIGradient
	local targetRing = targetHolder:FindFirstChild("Ring")
	local templateRing = templateHolder:FindFirstChild("Ring")
	if targetRing and templateRing then
		targetRing.Image = templateRing.Image
		targetRing.ImageColor3 = templateRing.ImageColor3
		targetRing.ImageTransparency = templateRing.ImageTransparency
		targetRing.ZIndex = templateRing.ZIndex

		local templateGradient = templateRing:FindFirstChildOfClass("UIGradient")
		if templateGradient then
			copyGradient(templateGradient, targetRing)
		end
	end
end

-- Update a single player list frame with the correct rank icon for a player
local function updatePlayerListRank(frame, rankNumber)
	local template, rankName = getRankTemplate(rankNumber)
	if not template then return end
	local templateHolder = template:FindFirstChild("PlayerHolder")
	if not templateHolder then return end

	-- RankIcon - the main rank icon image
	local rankIcon = frame:FindFirstChild("RankIcon")
	local templateRank = templateHolder:FindFirstChild("Rank")
	if rankIcon and templateRank then
		rankIcon.Image = templateRank.Image
		rankIcon.ImageColor3 = templateRank.ImageColor3
		rankIcon.Visible = true
	end

	-- Rank - the text badge with rank name color
	local rankLabel = frame:FindFirstChild("Rank")
	local templateRankTxt = templateHolder:FindFirstChild("RankTxt")
	if rankLabel and templateRankTxt then
		rankLabel.ImageColor3 = templateRankTxt.ImageColor3
		rankLabel.Visible = true
		local tx = rankLabel:FindFirstChild("TX")
		if tx then
			tx.Text = rankName
		end
	end
end

-- Update profile UI element colors (Border, PlayerName, stat labels) based on
-- the viewed player's rank. Checks the Profile's "ViewedRank" attribute first;
-- falls back to the local player's rank template if not set.
local function updateProfileGradients(templateHolder)
	if not templateHolder then return end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end

	local menu = playerGui:FindFirstChild("Menu")
	if not menu then return end
	local menuFrame = menu:FindFirstChild("Menu")
	if not menuFrame then return end

	local profile = menuFrame:FindFirstChild("Profile")
	if not profile then return end

	-- Check if we're viewing someone else's profile; use their rank if so
	local viewedRank = profile:GetAttribute("ViewedRank")
	local effectiveHolder = templateHolder
	if viewedRank then
		local viewedTemplate = getRankTemplate(viewedRank)
		if viewedTemplate then
			local vh = viewedTemplate:FindFirstChild("PlayerHolder")
			if vh then
				effectiveHolder = vh
			end
		end
	end

	local templateRing = effectiveHolder:FindFirstChild("Ring")
	if not templateRing then return end
	local rankColor = templateRing.ImageColor3

	-- PlayerHolder: Border (image) + PlayerName (text)
	local profileHolder = profile:FindFirstChild("PlayerHolder")
	if profileHolder then
		local border = profileHolder:FindFirstChild("Border")
		if border then
			border.ImageColor3 = rankColor
		end

		local playerName = profileHolder:FindFirstChild("PlayerName")
		if playerName then
			playerName.TextColor3 = rankColor
		end
	end

	-- Stat labels: apply rank color to the image and its TX text label
	local statNames = {"TimePlayed", "MainKaiju", "DMGDone", "KD", "BestCombo"}
	for _, statName in ipairs(statNames) do
		local statImage = profile:FindFirstChild(statName)
		if statImage then
			statImage.ImageColor3 = rankColor
			local tx = statImage:FindFirstChild("TX")
			if tx then
				tx.TextColor3 = rankColor
			end
		end
	end

	-- Buttons inside the profile panel
	local buttonNames = {"Back", "EnterName", "EnterPicture"}
	for _, btnName in ipairs(buttonNames) do
		local btn = profile:FindFirstChild(btnName)
		if btn then
			btn.ImageColor3 = rankColor
		end
	end
end

-- Main update function for the local player's rank icons in GameGui and Menu
local function updateRankIcons()
	local inventory = localPlayer:FindFirstChild("Inventory")
	if not inventory then return end
	local xpFolder = inventory:FindFirstChild("XP")
	if not xpFolder then return end
	local rankValue = xpFolder:FindFirstChild("Rank")
	if not rankValue then return end

	local rankNumber = rankValue.Value
	local template, rankName = getRankTemplate(rankNumber)
	if not template then return end
	local templateHolder = template:FindFirstChild("PlayerHolder")
	if not templateHolder then return end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end

	-- Update GameGui HealthStats PlayerHolder
	local gameGui = playerGui:FindFirstChild("GameGui")
	if gameGui then
		local character = gameGui:FindFirstChild("Character")
		if character then
			local healthStats = character:FindFirstChild("HealthStats")
			if healthStats then
				local holder = healthStats:FindFirstChild("PlayerHolder")
				if holder then
					updatePlayerHolder(holder, templateHolder)
					-- Update the level text in RankTxt
					local rankTxt = holder:FindFirstChild("RankTxt")
					if rankTxt then
						local tx = rankTxt:FindFirstChild("TX")
						if tx then
							local level = xpFolder:FindFirstChild("Level")
							tx.Text = "Level " .. (level and level.Value or 1)
						end
					end
				end
			end
		end
	end

	-- Update Menu Profile PlayerHolder
	local menu = playerGui:FindFirstChild("Menu")
	if menu then
		local menuFrame = menu:FindFirstChild("Menu")
		if menuFrame then
			local profile = menuFrame:FindFirstChild("Profile")
			if profile then
				-- Use the viewed player's rank for profile rank icons if available
				local viewedRank = profile:GetAttribute("ViewedRank")
				local profileTemplateHolder = templateHolder
				if viewedRank then
					local viewedTemplate = getRankTemplate(viewedRank)
					if viewedTemplate then
						local vh = viewedTemplate:FindFirstChild("PlayerHolder")
						if vh then
							profileTemplateHolder = vh
						end
					end
				end

				local profileHolder = profile:FindFirstChild("PlayerHolder")
				if profileHolder then
					local rankIcons = profileHolder:FindFirstChild("RankIcons")
					if rankIcons then
						local rankIconsHolder = rankIcons:FindFirstChild("PlayerHolder")
						if rankIconsHolder then
							updatePlayerHolder(rankIconsHolder, profileTemplateHolder)
						end
					end
				end
			end
		end
	end

	-- Update profile gradients (Border, PlayerName, stat labels) based on rank
	updateProfileGradients(templateHolder)
end

-- Wait for the player's Inventory to exist
local function waitForInventory()
	for i = 1, 120 do
		local inv = localPlayer:FindFirstChild("Inventory")
		if inv then return inv end
		task.wait(0.5)
	end
	return nil
end

local inventory = waitForInventory()
if not inventory then
	warn("[RankIconManager] Player Inventory not found after waiting")
	return
end

local xpFolder = inventory:FindFirstChild("XP")
if xpFolder then
	local rankValue = xpFolder:FindFirstChild("Rank")
	local levelValue = xpFolder:FindFirstChild("Level")
	local xpValue = xpFolder:FindFirstChild("XP")

	-- Initial update
	updateRankIcons()

	-- Connect to value changes
	if rankValue then
		rankValue.Changed:Connect(updateRankIcons)
	end
	if levelValue then
		levelValue.Changed:Connect(updateRankIcons)
	end
	if xpValue then
		xpValue.Changed:Connect(updateRankIcons)
	end
end

-- Update when player respawns
localPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	updateRankIcons()
end)

-- Periodic update for player list rank icons (when the player list is visible)
RunService.Stepped:Connect(function()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end
	local gameGui = playerGui:FindFirstChild("GameGui")
	if not gameGui then return end
	local playersFrame = gameGui:FindFirstChild("Players")
	if not playersFrame or not playersFrame.Visible then return end

	for _, frame in playersFrame:GetChildren() do
		if frame:IsA("Frame") and frame.Name ~= "Colors" and frame.Visible then
			local frameNumber = frame:FindFirstChild("Number")
			if frameNumber then
				for _, player in Players:GetPlayers() do
					local playerNumber = player:FindFirstChild("Number")
					if playerNumber and playerNumber.Value == frameNumber.Value then
						local inv = player:FindFirstChild("Inventory")
						if inv then
							local xp = inv:FindFirstChild("XP")
							if xp then
								local rank = xp:FindFirstChild("Rank")
								if rank then
									updatePlayerListRank(frame, rank.Value)
								end
							end
						end
						break
					end
				end
			end
		end
	end
end)

-- Periodic update for Menu rank icons (when the menu is visible)
task.spawn(function()
	while true do
		task.wait(0.5)
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if not playerGui then continue end
		local menu = playerGui:FindFirstChild("Menu")
		if menu then
			local menuFrame = menu:FindFirstChild("Menu")
			if menuFrame and menuFrame.Visible then
				updateRankIcons()
			end
		end
	end
end)