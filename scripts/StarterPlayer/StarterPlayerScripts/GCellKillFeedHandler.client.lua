-- GCellKillReward Client Handler
-- Listens for GCellKillReward RemoteEvent and displays a feed notification
-- showing red arrows (>>>>) instead of GCell reward when a player kills someone with a kaiju.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GCellKillReward RemoteEvent (fired from CombatModule on server)
local gcellEvent = ReplicatedStorage:WaitForChild("GCellKillReward")

-- FeedAsset template
local feedAssetTemplate = ReplicatedStorage.Assets.Kaijus.Model.UI.Feed.FeedAsset

-- Kaiju models folder (for image lookup)
local kaijuModelsFolder = ReplicatedStorage.Assets.Kaijus.Models

-- Chime sound properties (matches the existing feed system's Chime)
local CHIME_SOUND_ID = "rbxassetid://9119833560"
local CHIME_VOLUME = 2

-- Returns the image asset ID for a kaiju by name, or nil if not found
local function getKaijuImageId(kaijuName)
	if not kaijuName or kaijuName == "" then return nil end
	local model = kaijuModelsFolder:FindFirstChild(kaijuName)
	if not model then
		-- Check DevKaijus subfolder
		local devFolder = kaijuModelsFolder:FindFirstChild("DevKaijus")
		if devFolder then
			model = devFolder:FindFirstChild(kaijuName)
		end
	end
	if model then
		local imageVal = model:FindFirstChild("Image")
		if imageVal and imageVal:IsA("NumberValue") then
			return imageVal.Value
		end
	end
	return nil
end

gcellEvent.OnClientEvent:Connect(function(attackerNameStr, gcellReward, victimName, attackerKaijuName, victimKaijuName)
	-- Find the menu feed container at runtime
	local menuGui = playerGui:FindFirstChild("Menu")
	if not menuGui then return end

	local feedFrame = menuGui:FindFirstChild("Feed")
	if not feedFrame then return end

	local innerFeed = feedFrame:FindFirstChild("Feed")
	if not innerFeed then return end

	-- Clone the FeedAsset template
	local feedItem = feedAssetTemplate:Clone()

	-- Set text fields
	local attackerName = feedItem:FindFirstChild("AttackerName")
	if attackerName then
		attackerName.Text = attackerNameStr or player.Name
	end

	local playerName = feedItem:FindFirstChild("PlayerName")
	if playerName then
		playerName.Text = victimName or "Unknown"
	end

	-- Set the V label to show red arrows instead of GCell reward amount
	local vLabel = feedItem:FindFirstChild("V")
	if vLabel then
		vLabel.Text = ">>>>"
		vLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
		vLabel.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
	end

	-- Set the attacker's kaiju image
	if attackerKaijuName and attackerKaijuName ~= "" then
		local imageId = getKaijuImageId(attackerKaijuName)
		if imageId then
			local attackerImage = feedItem:FindFirstChild("AttackerImage")
			if attackerImage then
				attackerImage.Image = "rbxassetid://" .. tostring(imageId)
				local kaijuImage = attackerImage:FindFirstChild("KaijuImage")
				if kaijuImage then
					kaijuImage.Image = "rbxassetid://" .. tostring(imageId)
				end
			end
		end
	end

	-- Set the victim's kaiju image
	if victimKaijuName and victimKaijuName ~= "" then
		local imageId = getKaijuImageId(victimKaijuName)
		if imageId then
			local playerImage = feedItem:FindFirstChild("PlayerImage")
			if playerImage then
				playerImage.Image = "rbxassetid://" .. tostring(imageId)
				local kaijuImage = playerImage:FindFirstChild("KaijuImage")
				if kaijuImage then
					kaijuImage.Image = "rbxassetid://" .. tostring(imageId)
				end
			end
		end
	end

	-- Add Chime Sound (required by the existing feed animation system in Deobfuscated script)
	local chime = Instance.new("Sound")
	chime.Name = "Chime"
	chime.SoundId = CHIME_SOUND_ID
	chime.Volume = CHIME_VOLUME
	chime.Parent = feedItem

	-- Parent to the feed container (triggers the Deobfuscated animation system)
	feedItem.Parent = innerFeed
end)
