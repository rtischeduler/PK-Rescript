local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- List of usernames allowed to see kaiju buttons
local allowedUsernames = {
	"l0tzie",
	"xqt_zilla03",
	"JustaProGamer8",
	"owe_cel"
}

-- Find the Selection scrolling frame
local menu = script.Parent
local selection = menu:FindFirstChild("Menu", true)

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

local selectionFrame = findSelection()

local function isAllowed(username)
	for _, name in ipairs(allowedUsernames) do
		if string.lower(name) == string.lower(username) then
			return true
		end
	end
	return false
end

local function updateButtons()
	if not selectionFrame then return end
	local shouldShow = isAllowed(localPlayer.Name)

	-- Only make buttons visible for allowed users; never hide already-visible buttons
	if not shouldShow then return end

	for _, kaijuItem in ipairs(selectionFrame:GetChildren()) do
		if kaijuItem:IsA("GuiObject") then
			kaijuItem.Visible = true
			local button = kaijuItem:FindFirstChild("Button")
			if button and button:IsA("TextButton") then
				button.Visible = true
			end
		end
	end
end

if selectionFrame then
	updateButtons()
else
	-- Selection might not be loaded yet, retry
	task.spawn(function()
		local attempts = 0
		while not selectionFrame and attempts < 20 do
			attempts += 1
			task.wait(0.5)
			selectionFrame = findSelection()
		end
		if selectionFrame then
			updateButtons()
		end
	end)
end

-- Re-check if player changes (e.g., character respawn doesn't change name, but just in case)
localPlayer:GetPropertyChangedSignal("Name"):Connect(function()
	updateButtons()
end)