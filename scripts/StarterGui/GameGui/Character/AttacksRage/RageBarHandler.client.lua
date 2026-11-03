-- RageBarHandler: Handles the player's rage bar display
-- Reads from character's Aspects.Info.Rage (synced from server)
-- Plays fire gif when rage reaches max, flash gif on max transition
-- Follows the same pattern as HPBarHandler and StaminaBarHandler

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local KeybindConfig = require(game.ReplicatedStorage.KeybindConfig)

local AttacksRage = script.Parent
local RageBar = AttacksRage:WaitForChild("Rage")
local Clipping = RageBar:WaitForChild("Clipping")
local InnerClipping = Clipping:WaitForChild("Clipping")
local Top = InnerClipping:WaitForChild("Top")
local TEXT = RageBar:WaitForChild("TEXT")
local Flash = RageBar:WaitForChild("Flash")
local Ready = RageBar:WaitForChild("Ready")
local RageButton = RageBar:WaitForChild("Button")
local RageTXT = RageBar:WaitForChild("TXT")

-- Debounce: prevents rage ultimate from being spammed
local rageFiring = false

-- Fire gif frames (from original SetupHPandAttacks script)
local FIRE_FRAMES = {
	"rbxassetid://9316238151", "rbxassetid://9316237977", "rbxassetid://9316237818",
	"rbxassetid://9316237700", "rbxassetid://9316237609", "rbxassetid://9316237541",
	"rbxassetid://9316237468", "rbxassetid://9316237387", "rbxassetid://9316237261",
	"rbxassetid://9316237110", "rbxassetid://9316236916", "rbxassetid://9316236777",
	"rbxassetid://9316236668", "rbxassetid://9316236541", "rbxassetid://9316236435",
	"rbxassetid://9316236311", "rbxassetid://9316236130", "rbxassetid://9316235970",
	"rbxassetid://9316235769", "rbxassetid://9316235596", "rbxassetid://9316235472",
	"rbxassetid://9316235372", "rbxassetid://9316235228", "rbxassetid://9316235059",
}

-- Flash gif frames (from original SetupHPandAttacks script)
local FLASH_FRAMES = {
	"rbxassetid://9306185645", "rbxassetid://9306185497", "rbxassetid://9306185349",
	"rbxassetid://9306185183", "rbxassetid://9306185027", "rbxassetid://9306184888",
	"rbxassetid://9306184747", "rbxassetid://9306184554", "rbxassetid://9306184434",
	"rbxassetid://9306184265",
}

-- Shine sound from the original script's Sounds folder
local shineSound = game.StarterGui.GameGui.Character.HealthStats.SetupHPandAttacks.Sounds:FindFirstChild("Shine")

print("[RageBarHandler] Script loaded, waiting for character...")

-- Resize the bar vertically (Y-axis) and counter-resize Top to prevent distortion
local function resizeCustomLoadingBarY(ratio)
	ratio = math.clamp(ratio, 0, 1)
	InnerClipping.Size = UDim2.new(1, InnerClipping.Size.X.Offset, ratio, InnerClipping.Size.Y.Offset)
	if ratio > 0 then
		Top.Size = UDim2.new(1, Top.Size.X.Offset, 1 / ratio, Top.Size.Y.Offset)
	else
		Top.Size = UDim2.new(1, Top.Size.X.Offset, 0, Top.Size.Y.Offset)
	end
end

-- Play flash gif on the Flash element (one-shot cycle)
local function playFlashGif(frameDelay)
	-- Play shine sound
	if shineSound then
		local sound = shineSound:Clone()
		sound.Parent = script
		sound.PlayOnRemove = true
		sound:Destroy()
	end
	Flash.Image = ""
	for _, frameId in ipairs(FLASH_FRAMES) do
		Flash.Image = frameId
		task.wait(frameDelay)
	end
	Flash.Image = ""
end

-- Play fire gif on the Ready element
-- Loops while Rage > MaxRage, otherwise plays one cycle then hides
local fireGifRunning = false

local function playFireGif(rageValue, maxRageValue, frameDelay)
	if fireGifRunning then return end
	fireGifRunning = true
	Ready.Visible = true
	while true do
		for _, frameId in ipairs(FIRE_FRAMES) do
			Ready.Image = frameId
			task.wait(frameDelay)
		end
		if rageValue.Value < maxRageValue.Value then
			break
		end
	end
	Ready.Visible = false
	fireGifRunning = false
end

-- Track active connections so we can clean up on respawn
local connections = {}

local function clearConnections()
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}
end

local function hookCharacter(character)
	print("[RageBarHandler] Character added: " .. character.Name)
	clearConnections()

	-- Wait for the Aspects folder (contains rage data)
	local aspects = character:WaitForChild("Aspects", 30)
	if not aspects or not character.Parent then
		warn("[RageBarHandler] Aspects not found for character")
		return
	end

	local info = aspects:WaitForChild("Info", 10)
	if not info or not character.Parent then
		warn("[RageBarHandler] Info not found in Aspects")
		return
	end

	local rageValue = info:WaitForChild("Rage", 10)
	if not rageValue or not character.Parent then
		warn("[RageBarHandler] Rage not found in Info")
		return
	end

	local maxRageValue = rageValue:WaitForChild("MaxRage", 10)
	if not maxRageValue or not character.Parent then
		warn("[RageBarHandler] MaxRage not found")
		return
	end

	-- Wait for TeamBrick (used for rage bar color when full)
	local teamBrick = character:FindFirstChild("TeamBrick")
	if not teamBrick then
		teamBrick = character:WaitForChild("TeamBrick", 10)
	end

	print("[RageBarHandler] Connected! Rage: " .. rageValue.Value .. "/" .. maxRageValue.Value)

	-- Initialize: rage starts at 0
	resizeCustomLoadingBarY(0)
	TEXT.Text = "0"
	Ready.Visible = false
	Top.ImageColor3 = Color3.fromRGB(255, 255, 255)

	-- Play fire gif once at init (like the original script did)
	task.spawn(function()
		playFireGif(rageValue, maxRageValue, 0.01)
	end)

	-- Update the bar and text
	local function updateRageBar()
		local rage = rageValue.Value
		local maxRage = maxRageValue.Value
		local ratio = (maxRage > 0) and (rage / maxRage) or 0
		resizeCustomLoadingBarY(ratio)
		TEXT.Text = tostring(math.floor(rage))
	end

	-- Handle rage value changes
	local wasMaxed = false

	local function onRageChanged()
		updateRageBar()

		local rage = rageValue.Value
		local maxRage = maxRageValue.Value
		local teamColor = teamBrick and teamBrick.Color or Color3.fromRGB(255, 255, 255)

		if rage < maxRage then
			-- Not at max: set bar to white if it isn't already
			if Top.ImageColor3 ~= Color3.fromRGB(255, 255, 255) then
				TweenService:Create(Top, TweenInfo.new(0.05), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end
			wasMaxed = false
		elseif rage >= maxRage then
			-- At max: set bar to team color if it was white, play flash and fire gifs
			if Top.ImageColor3 == Color3.fromRGB(255, 255, 255) then
				TweenService:Create(Top, TweenInfo.new(0.2), {ImageColor3 = teamColor}):Play()

				-- Play flash gif
				task.spawn(function()
					playFlashGif(0.065)
				end)

				-- Play fire gif (loops while rage stays above max)
				task.spawn(function()
					playFireGif(rageValue, maxRageValue, 0.03)
				end)
			end
			wasMaxed = true
		end
	end

	-- Initial update
	updateRageBar()

	-- Connect to value changes (event-driven, no polling)
	table.insert(connections, rageValue.Changed:Connect(onRageChanged))
	table.insert(connections, maxRageValue.Changed:Connect(onRageChanged))

	-- Re-color bar when team brick color changes (if currently maxed)
	if teamBrick then
		table.insert(connections, teamBrick.Changed:Connect(function(prop)
			if prop == "Color" and wasMaxed then
				TweenService:Create(Top, TweenInfo.new(0.2), {ImageColor3 = teamBrick.Color}):Play()
			end
		end))
	end

	-- Fire rage ultimate when rage is full
	-- Uses the same event as the other attacks: character.Animations.Event:FireServer("Rage")
	local RAGE_BUSY_DURATION = 5

	local function tryFireRage()
		-- Only fire when rage is full
		if rageValue.Value < maxRageValue.Value then return end
		-- Prevent spamming
		if rageFiring then return end

		local character = Player.Character
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		-- Find the same ServerEvent that the other attacks fire to
		local animationsFolder = character:FindFirstChild("Animations")
		local ServerEvent = animationsFolder and animationsFolder:FindFirstChild("Event")
		if not ServerEvent then
			warn("[RageBarHandler] ServerEvent not found in Character.Animations")
			return
		end

		-- Check if player is busy doing something else
		local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
		local control = gameGui and gameGui:FindFirstChild("Control")
		local doingSomething = control and control:FindFirstChild("Values")
		doingSomething = doingSomething and doingSomething:FindFirstChild("Actions")
		doingSomething = doingSomething and doingSomething:FindFirstChild("DoingSomething")
		if doingSomething and doingSomething.Value then return end

		rageFiring = true

		-- Fire the server event with "Rage" as the attack name
		ServerEvent:FireServer("Rage")

		-- Busy lockout duration
		task.delay(RAGE_BUSY_DURATION, function()
			rageFiring = false
		end)
	end

	-- Click handlers on all interactive rage UI elements
	table.insert(connections, RageButton.MouseButton1Click:Connect(tryFireRage))
	table.insert(connections, RageTXT.MouseButton1Click:Connect(tryFireRage))
	table.insert(connections, Ready.MouseButton1Click:Connect(tryFireRage))

	-- Keyboard handler for Rage keybind (V key)
	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == KeybindConfig.Rage then
			tryFireRage()
		end
	end))
end

-- Re-hook every time the character changes (handles respawns)
Player.CharacterAdded:Connect(hookCharacter)

-- Hook the current character if one already exists
if Player.Character then
	task.spawn(hookCharacter, Player.Character)
end
