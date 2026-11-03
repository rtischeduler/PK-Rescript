-- AspectsGUI: Emote wheel and visual effects handler
-- Handles per-kaiju emote loading, emote wheel display, and emote activation

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Wait for GameGui
local playerGui = player:WaitForChild("PlayerGui")
local gameGui = playerGui:WaitForChild("GameGui", 30)
if not gameGui then
	warn("[AspectsGUI] GameGui not found, aborting")
	return
end

local control = gameGui:FindFirstChild("Control")

-- References to UI
local aspects = script.Parent
local emotesFrame = aspects:WaitForChild("Emotes", 10)
local emotesValues = emotesFrame and emotesFrame:WaitForChild("Values", 10)

-- Emote scripts root
local emoteScriptsRoot = ReplicatedStorage:FindFirstChild("Assets")
emoteScriptsRoot = emoteScriptsRoot and emoteScriptsRoot:FindFirstChild("Kaijus")
emoteScriptsRoot = emoteScriptsRoot and emoteScriptsRoot:FindFirstChild("EmoteScripts")

-- Slot scripts (references to emote scripts for slots 1-4)
local slotScripts = {nil, nil, nil, nil}

-- Emote click debounce (prevents rapid double-cloning)
local emoteDebounce = false

-- Helper: Strip kaiju prefix from emote display names
-- E.g. "Godzilla2000-Rest" -> "Rest"
local function stripKaijuPrefix(emoteName)
	local dashPos = string.find(emoteName, "-")
	if dashPos then
		return string.sub(emoteName, dashPos + 1)
	end
	return emoteName
end

-- Get the current kaiju name
local function getKaijuName()
	-- Try SelectedKaiju value in Menu
	local menuGui = playerGui:FindFirstChild("Menu")
	if menuGui then
		local menuFrame = menuGui:FindFirstChild("Menu")
		if menuFrame then
			local values = menuFrame:FindFirstChild("Values")
			if values then
				local selKaiju = values:FindFirstChild("SelectedKaiju")
				if selKaiju and selKaiju.Value ~= "" then
					return selKaiju.Value
				end
			end
		end
	end
	-- Fallback: check EquippedKaiju in inventory
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local equipped = inventory:FindFirstChild("EquippedKaiju")
		if equipped and equipped.Value ~= "" then
			return equipped.Value
		end
	end
	-- Final fallback
	return "Godzilla2000"
end

-- Load emotes for a specific kaiju into the UI slots
local function loadEmotesForKaiju(kaijuName)
	if not emoteScriptsRoot then
		warn("[AspectsGUI] EmoteScripts root not found")
		return
	end

	local kaijuEmoteFolder = emoteScriptsRoot:FindFirstChild(kaijuName)
	if not kaijuEmoteFolder then
		warn("[AspectsGUI] No emote scripts folder for kaiju: " .. tostring(kaijuName))
		return
	end

	-- Get inventory emotes for this kaiju
	local inventory = player:FindFirstChild("Inventory")
	local emotesFolder = inventory and inventory:FindFirstChild("Emotes")
	local kaijuEmotesInv = emotesFolder and emotesFolder:FindFirstChild(kaijuName)

	-- For each slot (1-4)
	for slotNum = 1, 4 do
		local slotName = "Emote" .. slotNum
		local uiSlot = emotesFrame:FindFirstChild(slotName)
		local uiValuesSlot = emotesValues and emotesValues:FindFirstChild(slotName)
		local txtLabel = uiSlot and uiSlot:FindFirstChild("TXT")

		-- Determine emote name: check inventory first
		local emoteName = ""
		if kaijuEmotesInv then
			local invSlot = kaijuEmotesInv:FindFirstChild(slotName)
			if invSlot then
				emoteName = invSlot.Value
			end
		end

		-- Find the emote script by name (only show equipped emotes)
		local emoteScript = nil
		if emoteName ~= "" then
			emoteScript = kaijuEmoteFolder:FindFirstChild(emoteName)
		end

		-- Store the script reference
		slotScripts[slotNum] = emoteScript

		-- Update UI ObjectValue
		if uiValuesSlot then
			uiValuesSlot.Value = emoteScript
		end

		-- Update TXT label and slot visibility
		if txtLabel then
			if emoteScript then
				txtLabel.Text = stripKaijuPrefix(emoteScript.Name)
				local emoteNameVal = emoteScript:FindFirstChild("EmoteName")
				if emoteNameVal then
					txtLabel.Text = stripKaijuPrefix(emoteNameVal.Value)
				end
			else
				txtLabel.Text = ""
			end
		end

		-- Hide the slot visually if no emote is equipped
		if uiSlot then
			uiSlot.Visible = emoteScript ~= nil
		end
	end
end

-- Helper: Clear focus from any focused TextBox in the emote wheel
local function clearEmoteFocus()
	for slotNum = 1, 4 do
		local slotName = "Emote" .. slotNum
		local uiSlot = emotesFrame:FindFirstChild(slotName)
		if uiSlot then
			local txt = uiSlot:FindFirstChild("TXT")
			if txt and txt:IsA("TextBox") then
				txt:ReleaseFocus(true)
			end
		end
	end
end

-- Setup emote button click handlers
local buttonConnections = {}
local function setupEmoteButtons()
	-- Disconnect old connections
	for _, conn in ipairs(buttonConnections) do
		conn:Disconnect()
	end
	buttonConnections = {}

	for slotNum = 1, 4 do
		local slotName = "Emote" .. slotNum
		local uiSlot = emotesFrame:FindFirstChild(slotName)
		if uiSlot then
			local button = uiSlot:FindFirstChild("Button")
			if button then
				local conn = button.MouseButton1Down:Connect(function()
					-- Check if player is busy
					if control then
						local actions = control:FindFirstChild("Values")
						actions = actions and actions:FindFirstChild("Actions")
						actions = actions and actions:FindFirstChild("DoingSomething")
						if actions and actions.Value then return end
					end

					-- Get current character and humanoid
					local currentChar = player.Character
					if not currentChar then return end
					local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
					if not humanoid then return end

					-- Check walk speed
					if humanoid.WalkSpeed <= 0 then return end

					-- Check stun
					local aspectsFolder = currentChar:FindFirstChild("Aspects")
					if aspectsFolder then
						local stun = aspectsFolder:FindFirstChild("Stun")
						if stun then
							local stunned = stun:FindFirstChild("Stunned")
							if stunned and stunned.Value then return end
						end
					end

					-- Clone and activate the emote script
					local emoteScript = slotScripts[slotNum]
					if emoteScript and not emoteDebounce then
						emoteDebounce = true

						-- Clean up old emote clones in the character
						for _, child in ipairs(currentChar:GetChildren()) do
							if child:IsA("LocalScript") and child:FindFirstChild("Char") and child:FindFirstChild("EmoteName") then
								child.Parent = nil
						end
						end

						local ok, err = pcall(function()
							local clone = emoteScript:Clone()
							local charVal = clone:FindFirstChild("Char")
							if charVal then
								charVal.Value = currentChar
							end
							clone.Parent = currentChar
						end)

						if not ok then
							warn("[AspectsGUI] Failed to clone emote: " .. tostring(err))
							emoteDebounce = false
							return
						end

						-- Close the emote wheel
						clearEmoteFocus()
						emotesFrame:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
						task.delay(1, function()
							emoteDebounce = false
						end)
					end
				end)
				table.insert(buttonConnections, conn)
			end
		end
	end
end

-- Emote wheel open via keyboard (hold B)
local bHeld = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.B and not bHeld then
		bHeld = true
		-- Refresh emotes when wheel opens
		loadEmotesForKaiju(getKaijuName())
		emotesFrame:TweenSize(UDim2.new(0.5, 0, 0.65, 0), "In", "Quad", 0.2)
		emotesFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "In", "Quad", 0.2)
	end
end)

-- Emote wheel close via keyboard (release B)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.B then
		bHeld = false
		clearEmoteFocus()
		emotesFrame:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
	end
end)

-- Mobile emote button toggle (open/close wheel)
local mobileBtn = gameGui:FindFirstChild("Character")
mobileBtn = mobileBtn and mobileBtn:FindFirstChild("Cooldowns")
mobileBtn = mobileBtn and mobileBtn:FindFirstChild("Mobile")
mobileBtn = mobileBtn and mobileBtn:FindFirstChild("Aspects")
mobileBtn = mobileBtn and mobileBtn:FindFirstChild("Emotes")
mobileBtn = mobileBtn and mobileBtn:FindFirstChild("Button")

if mobileBtn then
	mobileBtn.MouseButton1Down:Connect(function()
		if emotesFrame.Size == UDim2.new(0, 0, 0, 0) then
			-- Refresh emotes when wheel opens
			loadEmotesForKaiju(getKaijuName())
			emotesFrame:TweenSize(UDim2.new(0.5, 0, 0.65, 0), "In", "Quad", 0.2)
			emotesFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "In", "Quad", 0.2)
		else
			clearEmoteFocus()
			emotesFrame:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
		end
	end)
end

-- Health/faint handling
local faintPlayed = false
local function setupHealthHandler(character)
	local aspectsFolder = character:FindFirstChild("Aspects")
	if not aspectsFolder then return end
	local info = aspectsFolder:FindFirstChild("Info")
	if not info then return end
	local health = info:FindFirstChild("Health")
	if not health then return end

	health.Changed:Connect(function()
		if health.Value <= 0 and not faintPlayed then
			faintPlayed = true
			-- Play faint sound
			local faintSound = script:FindFirstChild("Faint")
			if faintSound then faintSound:Play() end

			-- Visual effects
			TweenService:Create(game.Lighting.ColorCorrection, TweenInfo.new(0.4), {Saturation = -1}):Play()
			task.wait(0.25)
			TweenService:Create(script.Parent.Parent.DarkVision, TweenInfo.new(0.35), {ImageTransparency = 0}):Play()
			task.wait(0.55)
			TweenService:Create(script.Parent.Parent.Faint, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
		end
	end)
end

-- Initialize for a character
local function initForCharacter(character)
	-- Wait for character to be fully loaded
	character:WaitForChild("Aspects", 10)
	local humanoid = character:WaitForChild("Humanoid", 10)

	task.wait(0.35)

	-- Reset visual effects
	TweenService:Create(game.Lighting.ColorCorrection, TweenInfo.new(0.4), {Saturation = 0}):Play()
	TweenService:Create(script.Parent.Parent.DarkVision, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
	TweenService:Create(script.Parent.Parent.Faint, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()

	-- Reset faint state
	faintPlayed = false

	-- Load emotes for current kaiju
	local kaijuName = getKaijuName()
	loadEmotesForKaiju(kaijuName)

	-- Setup emote buttons
	setupEmoteButtons()

	-- Setup health handler
	setupHealthHandler(character)
end

-- Handle character respawns
player.CharacterAdded:Connect(function(character)
	task.spawn(function()
		initForCharacter(character)
	end)
end)

-- Handle current character if it already exists
if player.Character then
	task.spawn(function()
		initForCharacter(player.Character)
	end)
end

-- Patch 7: Listen for EquipEmote confirmation from server
local equipEmoteEvent = ReplicatedStorage:FindFirstChild("Menu")
	equipEmoteEvent = equipEmoteEvent and equipEmoteEvent:FindFirstChild("Menu")
	equipEmoteEvent = equipEmoteEvent and equipEmoteEvent:FindFirstChild("Events")
	equipEmoteEvent = equipEmoteEvent and equipEmoteEvent:FindFirstChild("EquipEmote")
if equipEmoteEvent then
	equipEmoteEvent.OnClientEvent:Connect(function(success, emoteName)
		if success then
			local kaijuName = getKaijuName()
			loadEmotesForKaiju(kaijuName)
			setupEmoteButtons()
			print("[AspectsGUI] Emote equipped: " .. tostring(emoteName))
		else
			warn("[AspectsGUI] Emote equip failed for: " .. tostring(emoteName))
		end
	end)
end

-- Listen for kaiju changes (when player switches kaiju without respawning)
task.spawn(function()
	local menuGui = playerGui:FindFirstChild("Menu")
	if not menuGui then return end
	local menuFrame = menuGui:FindFirstChild("Menu")
	if not menuFrame then return end
	local values = menuFrame:FindFirstChild("Values")
	if not values then return end
	local selKaiju = values:FindFirstChild("SelectedKaiju")
	if not selKaiju then return end

	selKaiju.Changed:Connect(function()
		local character = player.Character
		if character then
			local kaijuName = getKaijuName()
			loadEmotesForKaiju(kaijuName)
		end
	end)
end)

print("[AspectsGUI] Loaded successfully")
