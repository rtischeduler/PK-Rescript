-- DataLoadedFade: Shows a loading screen until player data finishes loading
-- and has fully replicated to the client, then fades the screen away.
-- Works with PlayerDataManager's DataLoaded attribute.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- The Load frame and its children to fade
local loadFrame = script.Parent
local menuGui = loadFrame.Parent
local bg = loadFrame:FindFirstChild("BG")
local rewardsLabel = loadFrame:FindFirstChild("Rewards")
local blackFade = menuGui and menuGui:FindFirstChild("BlackFade")

-- =========================================================================
-- Helper: wait for a child to exist on the client (replication check)
-- =========================================================================
local function waitForChild(parent, name, timeout)
	local child = parent:FindFirstChild(name)
	if child then return child end
	local elapsed = 0
	while not child and elapsed < (timeout or 10) do
		task.wait(0.1)
		elapsed = elapsed + 0.1
		child = parent:FindFirstChild(name)
	end
	return child
end

-- =========================================================================
-- Step 1: Wait for the DataLoaded attribute from the server.
-- This tells us the server has finished loading from DataStores.
-- =========================================================================
local t = 0
local maxWait = 30
while not player:GetAttribute("DataLoaded") and t < maxWait do
	task.wait(0.1)
	t = t + 0.1
end

-- =========================================================================
-- Step 2: Wait for the actual data folders to replicate to the client.
-- The attribute may arrive before all the instances have replicated,
-- so we verify the folders and key child values actually exist on our side.
-- =========================================================================

-- Wait for the three main folders
local inventory = waitForChild(player, "Inventory", 15)
local settings = waitForChild(player, "Settings", 15)
local stats = waitForChild(player, "Stats", 15)

-- Wait for key values inside Inventory to confirm full replication
if inventory then
	local xp = waitForChild(inventory, "XP", 10)
	if xp then
		waitForChild(xp, "Level", 5)
		waitForChild(xp, "XPToEarn", 5)
		waitForChild(xp, "Rank", 5)
	end
	waitForChild(inventory, "GCells", 5)
	waitForChild(inventory, "Lootboxes", 5)
	waitForChild(inventory, "Skin", 5)
	waitForChild(inventory, "ProfileImage", 5)
	local rewards = waitForChild(inventory, "Rewards", 5)
	if rewards then
		waitForChild(rewards, "Completed", 5)
		waitForChild(rewards, "Current", 5)
		waitForChild(rewards, "Owned", 5)
	end
end

-- Wait for key values inside Settings
if settings then
	local ui = waitForChild(settings, "UI", 5)
	if ui then
		waitForChild(ui, "MusicVolume", 5)
	end
	local graphics = waitForChild(settings, "Graphics", 5)
	if graphics then
		waitForChild(graphics, "Shadows", 5)
		waitForChild(graphics, "DepthOfField", 5)
		waitForChild(graphics, "Blur", 5)
	end
	waitForChild(settings, "ScreenShake", 5)
	waitForChild(settings, "ShowHitboxes", 5)
	waitForChild(settings, "Keybinds", 5)
end

-- Wait for key values inside Stats
if stats then
	waitForChild(stats, "K", 5)
	waitForChild(stats, "D", 5)
	waitForChild(stats, "BestCombo", 5)
	waitForChild(stats, "TotalDamage", 5)
	waitForChild(stats, "MainKaiju", 5)
	waitForChild(stats, "KaijuUsage", 5)
end

-- Small buffer for any final replication packets
task.wait(0.3)

-- Update text to show data is loaded
if rewardsLabel then
	rewardsLabel.Text = "Data Loaded"
end

-- Brief pause so the player can see "Data Loaded"
task.wait(0.5)

-- Fade out the frame over 1 second
local fadeDuration = 1.0
local fadeInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local tweens = {}
if bg then
	table.insert(tweens, TweenService:Create(bg, fadeInfo, {ImageTransparency = 1}))
end
if rewardsLabel then
	table.insert(tweens, TweenService:Create(rewardsLabel, fadeInfo, {TextTransparency = 1}))
end
if blackFade then
	table.insert(tweens, TweenService:Create(blackFade, fadeInfo, {BackgroundTransparency = 1}))
end

-- Play all tweens
for _, tween in ipairs(tweens) do
	tween:Play()
end

-- Wait for fade to complete
task.wait(fadeDuration)

-- Hide the frame entirely
loadFrame.Visible = false
if blackFade then
	blackFade.Visible = false
end

-- Restore transparency values in case the frame is shown again later
if bg then
	bg.ImageTransparency = 0.15
end
if rewardsLabel then
	rewardsLabel.TextTransparency = 0
end
if blackFade then
	blackFade.BackgroundTransparency = 0
end