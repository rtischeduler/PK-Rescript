local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- List of usernames allowed to see kaiju buttons (case-insensitive)
local allowedUsernames = {
	"l0tzie",
	"xqt_zilla03",
	"JustaProGamer8",
	"owe_cel"
}

-- Kaiju entries that must stay visible for allowed users even if something else hides them
local alwaysVisible = {
	"MechaGodzilla2021"
}

local menu = script.Parent

-- Navigate to Characters.LeftBar.Selection
local function findSelection()
	local frame = menu:FindFirstChild("Menu")
	if not frame then return nil end
	local characters = frame:FindFirstChild("Characters")
	if not characters then return nil end
	local leftBar = characters:FindFirstChild("LeftBar")
	if not leftBar then return nil end
	return leftBar:FindFirstChild("Selection")
end

local function isAllowed(username)
	for _, name in ipairs(allowedUsernames) do
		if string.lower(name) == string.lower(username) then
			return true
		end
	end
	return false
end

local function isAlwaysVisible(item)
	for _, name in ipairs(alwaysVisible) do
		if string.lower(item.Name) == string.lower(name) then
			return true
		end
	end
	return false
end

local function showItem(kaijuItem)
	if not kaijuItem:IsA("GuiObject") then return end
	if not kaijuItem.Visible then kaijuItem.Visible = true end
	local button = kaijuItem:FindFirstChild("Button")
	if button and button:IsA("GuiObject") and not button.Visible then
		button.Visible = true
	end
end

local watched = {}

-- Keep always-visible entries visible if another script hides them later
local function watchItem(kaijuItem)
	if watched[kaijuItem] or not kaijuItem:IsA("GuiObject") or not isAlwaysVisible(kaijuItem) then return end
	watched[kaijuItem] = true
	kaijuItem:GetPropertyChangedSignal("Visible"):Connect(function()
		if not kaijuItem.Visible and isAllowed(localPlayer.Name) then
			kaijuItem.Visible = true
		end
	end)
end

local selectionFrame = nil

local function updateButtons()
	if not selectionFrame then return end
	-- Only make buttons visible for allowed users; never hide already-visible buttons
	if not isAllowed(localPlayer.Name) then return end

	for _, kaijuItem in ipairs(selectionFrame:GetChildren()) do
		showItem(kaijuItem)
		watchItem(kaijuItem)
	end
end

-- Selection may not be loaded yet, keep trying
task.spawn(function()
	local attempts = 0
	while not selectionFrame and attempts < 60 do
		selectionFrame = findSelection()
		if selectionFrame then break end
		attempts += 1
		task.wait(0.5)
	end
	if not selectionFrame then
		warn("[KaijuButtonVisibility] Characters.LeftBar.Selection not found")
		return
	end

	updateButtons()

	-- Entries added after startup (e.g. unlocked or created later)
	selectionFrame.ChildAdded:Connect(function(child)
		if isAllowed(localPlayer.Name) then
			showItem(child)
			watchItem(child)
		end
	end)

	-- Periodic refresh in case an entry was shown/hidden by other scripts
	while true do
		task.wait(2)
		updateButtons()
	end
end)

-- Re-check if player changes name
localPlayer:GetPropertyChangedSignal("Name"):Connect(function()
	updateButtons()
end)
