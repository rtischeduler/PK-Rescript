-- AdminGUI Client Script
-- Only l0tzie can see and use this panel. Destroys the GUI and toggle button for everyone else.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = script.Parent
local playerGui = player:WaitForChild("PlayerGui")

-- Security: destroy the GUI and admin toggle button if the player is not l0tzie (case insensitive)
if string.lower(player.Name) ~= "l0tzie" then
	gui:Destroy()
	-- Also destroy the admin toggle button from the Menu ScreenGui
	local menuGui = playerGui:FindFirstChild("Menu")
	if menuGui then
		local adminToggle = menuGui:FindFirstChild("AdminButton")
		if adminToggle then
			adminToggle:Destroy()
		end
	end
	return
end

-- Show the admin toggle button for l0tzie
local menuGui = playerGui:WaitForChild("Menu", 10)
local adminToggleButton = nil
if menuGui then
	adminToggleButton = menuGui:FindFirstChild("AdminButton")
	if adminToggleButton then
		adminToggleButton.Visible = true
	end
end

local adminFolder = ReplicatedStorage:WaitForChild("AdminEvents", 10)
if not adminFolder then
	warn("[AdminGUI] Could not find AdminEvents folder!")
	return
end

local banEvent = adminFolder:WaitForChild("BanEvent")
local unbanEvent = adminFolder:WaitForChild("UnbanEvent")
local grantEvent = adminFolder:WaitForChild("GrantGCellsEvent")
local dealDamageEvent = adminFolder:WaitForChild("DealDamageEvent")
local addLevelEvent = adminFolder:WaitForChild("AddLevelEvent")

local frame = gui:WaitForChild("MainFrame")
local usernameBox = frame:WaitForChild("UsernameBox")
local banButton = frame:WaitForChild("BanButton")
local unbanButton = frame:WaitForChild("UnbanButton")
local gcellUserBox = frame:WaitForChild("GCellUserBox")
local gcellAmountBox = frame:WaitForChild("GCellAmountBox")
local grantButton = frame:WaitForChild("GrantButton")
local statusLabel = frame:WaitForChild("StatusLabel")
local damageButton = frame:WaitForChild("DamageButton")
local levelSection = frame:WaitForChild("LevelSection")
local levelRow = levelSection:WaitForChild("LevelRow")
local levelAmountBox = levelRow:WaitForChild("LevelAmountBox")
local addLevelButton = levelRow:WaitForChild("AddLevelButton")
local lootboxSection = frame:WaitForChild("LootboxSection")
local lootboxRow = lootboxSection:WaitForChild("LootboxRow")
local lootboxAmountBox = lootboxRow:WaitForChild("LootboxAmountBox")
local giveLootboxButton = lootboxRow:WaitForChild("GiveLootboxButton")
local title = frame:WaitForChild("Title")
local closeButton = title:WaitForChild("CloseButton")

-- Ensure title can receive input for dragging
title.Active = true

-- Make the panel draggable by the Title bar
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart = nil
local startPos = nil

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

title.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local function setStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

-- Re-center the panel when toggled open
local function centerFrame()
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
end

-- Ban button
banButton.MouseButton1Click:Connect(function()
	local username = usernameBox.Text
	if username == "" then
		setStatus("Enter a username first!", Color3.fromRGB(255, 100, 100))
		return
	end
	setStatus("Banning " .. username .. "...", Color3.fromRGB(255, 200, 100))
	banEvent:FireServer(username)
end)

-- Unban button
unbanButton.MouseButton1Click:Connect(function()
	local username = usernameBox.Text
	if username == "" then
		setStatus("Enter a username first!", Color3.fromRGB(255, 100, 100))
		return
	end
	setStatus("Unbanning " .. username .. "...", Color3.fromRGB(255, 200, 100))
	unbanEvent:FireServer(username)
end)

-- Grant GCells button
grantButton.MouseButton1Click:Connect(function()
	local targetUser = gcellUserBox.Text
	local amount = tonumber(gcellAmountBox.Text)
	if targetUser == "" then
		setStatus("Enter a target username!", Color3.fromRGB(255, 100, 100))
		return
	end
	if not amount or amount <= 0 then
		setStatus("Enter a valid amount!", Color3.fromRGB(255, 100, 100))
		return
	end
	setStatus("Granting " .. amount .. " GCells to " .. targetUser .. "...", Color3.fromRGB(255, 200, 100))
	grantEvent:FireServer(targetUser, amount)
end)

-- Deal 100 Damage button (damages your own character for testing)
damageButton.MouseButton1Click:Connect(function()
	setStatus("Dealing 100 damage to your character...", Color3.fromRGB(255, 200, 100))
	dealDamageEvent:FireServer()
end)

-- Give Lootboxes button (self-only, uses LootboxAdd from Menu events)
giveLootboxButton.MouseButton1Click:Connect(function()
	local amount = tonumber(lootboxAmountBox.Text)
	if not amount or amount <= 0 then
		setStatus("Enter a valid amount!", Color3.fromRGB(255, 100, 100))
		return
	end

	-- Find the LootboxAdd RemoteEvent from the player's PlayerGui Menu
	local menuGui = playerGui:FindFirstChild("Menu")
	if not menuGui then
		setStatus("Menu not found! Open the menu first.", Color3.fromRGB(255, 100, 100))
		return
	end

	local menuFrame = menuGui:FindFirstChild("Menu")
	if not menuFrame then
		setStatus("Menu frame not found!", Color3.fromRGB(255, 100, 100))
		return
	end

	local events = menuFrame:FindFirstChild("Events")
	if not events then
		setStatus("Events folder not found!", Color3.fromRGB(255, 100, 100))
		return
	end

	local lootboxAddEvent = events:FindFirstChild("LootboxAdd")
	if not lootboxAddEvent or not lootboxAddEvent:IsA("RemoteEvent") then
		setStatus("LootboxAdd event not found!", Color3.fromRGB(255, 100, 100))
		return
	end

	setStatus("Giving " .. amount .. " lootboxes to yourself...", Color3.fromRGB(255, 200, 100))
	lootboxAddEvent:FireServer(amount)
	task.wait(0.3)
	setStatus("Granted " .. amount .. " lootboxes!", Color3.fromRGB(100, 255, 100))
end)

-- Add Levels button (self-only)
addLevelButton.MouseButton1Click:Connect(function()
	local amount = tonumber(levelAmountBox.Text)
	if not amount or amount <= 0 then
		setStatus("Enter a valid level amount!", Color3.fromRGB(255, 100, 100))
		return
	end
	setStatus("Adding " .. amount .. " levels to yourself...", Color3.fromRGB(255, 200, 100))
	addLevelEvent:FireServer(amount)
end)

-- Listen for responses from server
banEvent.OnClientEvent:Connect(function(success, message)
	if success then
		setStatus(message, Color3.fromRGB(100, 255, 100))
	else
		setStatus(message, Color3.fromRGB(255, 100, 100))
	end
end)

unbanEvent.OnClientEvent:Connect(function(success, message)
	if success then
		setStatus(message, Color3.fromRGB(100, 255, 100))
	else
		setStatus(message, Color3.fromRGB(255, 100, 100))
	end
end)

grantEvent.OnClientEvent:Connect(function(success, message)
	if success then
		setStatus(message, Color3.fromRGB(100, 255, 100))
	else
		setStatus(message, Color3.fromRGB(255, 100, 100))
	end
end)

dealDamageEvent.OnClientEvent:Connect(function(success, message)
	if success then
		setStatus(message, Color3.fromRGB(100, 255, 100))
	else
		setStatus(message, Color3.fromRGB(255, 100, 100))
	end
end)

addLevelEvent.OnClientEvent:Connect(function(success, message)
	if success then
		setStatus(message, Color3.fromRGB(100, 255, 100))
	else
		setStatus(message, Color3.fromRGB(255, 100, 100))
	end
end)

setStatus("Admin Panel Ready", Color3.fromRGB(100, 255, 100))

-- Close button: hide the admin panel
closeButton.MouseButton1Click:Connect(function()
	dragging = false
	frame.Visible = false
end)

-- Admin toggle button: show/hide the admin panel
if adminToggleButton then
	local toggleButton = adminToggleButton:FindFirstChild("Button")
	if toggleButton then
		toggleButton.MouseButton1Click:Connect(function()
			frame.Visible = not frame.Visible
			if frame.Visible then
				centerFrame()
				setStatus("Admin Panel Ready", Color3.fromRGB(100, 255, 100))
			end
		end)
	end
end
