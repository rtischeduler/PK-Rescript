-- OverheadHealthBar (Server-Sided): Displays health bars above ALL players' characters
-- All players can see each other's health bars, name, and kaiju name
-- The bar fill color matches the character's UltColor or FireColor from Aspects

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HealthTemplate = ReplicatedStorage:WaitForChild("Health")

-- Kaiju display name mapping (same as KaijuDisplayHandler)
local KAIJU_DISPLAY = {
	["Godzilla2000"]      = "Godzilla 2000",
	["TitanusGodzilla"]   = "Titanus Godzilla",
	["ShowaGigan"]        = "Showa Gigan",
	["Orga"]              = "Orga",
	["Zilla"]             = "Zilla",
	["Gamma"]             = "Gamma",
	["Destoroyah"]        = "Destoroyah",
	["DummyG2k"]          = "Godzilla 2000",
	["MechaGodzilla2021"] = "MechaGodzilla",
	["Tricky"]            = "Tricky",
	["Gilga"]             = "Gilga",
}

local KAIJU_COMPAT = {
	["G2K"]   = "Zilla",
	["Gigan"] = "ShowaGigan",
}

local function getEquippedKaiju(player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return nil end
	local equipped = inventory:FindFirstChild("EquippedKaiju")
	if not equipped then return nil end
	local kaiju = equipped.Value
	if kaiju == "" then return nil end
	if KAIJU_COMPAT[kaiju] then
		kaiju = KAIJU_COMPAT[kaiju]
	end
	return kaiju
end

local function getKaijuDisplayName(character, player)
	-- Method 1: Check Settings module on the character
	local settingsModule = character:FindFirstChild("Settings")
	if settingsModule and settingsModule:IsA("ModuleScript") then
		local success, settings = pcall(require, settingsModule)
		if success and type(settings) == "table" and settings.KaijuName then
			return settings.KaijuName
		end
	end

	-- Method 2: Check Name StringValue on the character
	local nameValue = character:FindFirstChild("Name")
	if nameValue and nameValue:IsA("StringValue") then
		return nameValue.Value
	end

	-- Method 3: Fallback to equipped kaiju mapping
	local kaijuName = getEquippedKaiju(player)
	if kaijuName and KAIJU_DISPLAY[kaijuName] then
		return KAIJU_DISPLAY[kaijuName]
	end

	return nil
end

-- Clipping resize logic (same as HPBar script)
-- Resizes the Clipping frame to the health ratio AND counter-resizes
-- the Top image to 1/ratio so it doesn't distort when clipped.
local function resizeCustomLoadingBarX(ratio, clippingFrame, topFrame)
	clippingFrame.Size = UDim2.new(ratio, clippingFrame.Size.X.Offset, clippingFrame.Size.Y.Scale, clippingFrame.Size.Y.Offset)
	if ratio > 0 then
		local scale = 1 / ratio
		topFrame.Size = UDim2.new(scale, topFrame.Size.X.Offset, topFrame.Size.Y.Scale, topFrame.Size.Y.Offset)
	else
		topFrame.Size = UDim2.new(0, topFrame.Size.X.Offset, topFrame.Size.Y.Scale, topFrame.Size.Y.Offset)
	end
end

-- Get the character's color from Aspects (UltColor first, then FireColor, then BladeColor)
local function getCharacterColor(character)
	local aspects = character:FindFirstChild("Aspects")
	if not aspects then return nil end
	local colors = aspects:FindFirstChild("Colors")
	if not colors then return nil end

	-- Try UltColor first (fall back to FireColor if UltColor is black)
	local ultColorVal = colors:FindFirstChild("UltColor")
	if ultColorVal then
		local c = ultColorVal.Value
		if c ~= Color3.new(0, 0, 0) then
			return c
		end
	end

	-- Fall back to FireColor under NormalColor
	local normalColor = colors:FindFirstChild("NormalColor")
	if normalColor then
		local fireColorVal = normalColor:FindFirstChild("FireColor")
		if fireColorVal then
			return fireColorVal.Value
		end

		-- Fall back to BladeColor
		local bladeColorVal = normalColor:FindFirstChild("BladeColor")
		if bladeColorVal then
			return bladeColorVal.Value
		end
	end

	return nil
end

local function setupOverheadHealth(player, character)
	-- Wait for Aspects (contains health info)
	local aspects = character:WaitForChild("Aspects", 15)
	if not aspects then return end
	local info = aspects:WaitForChild("Info", 15)
	if not info then return end
	local healthInfo = info:WaitForChild("Health", 15)
	if not healthInfo then return end
	local maxHealthObj = healthInfo:WaitForChild("MaxHealth", 15)
	if not maxHealthObj then return end

	-- Wait for HumanoidRootPart
	local hrp = character:WaitForChild("HumanoidRootPart", 15)
	if not hrp then return end

	-- Remove any existing overhead health bar
	local existing = character:FindFirstChild("OverheadHealthBar")
	if existing then
		existing:Destroy()
	end

	-- Create the BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "OverheadHealthBar"
	billboard.Adornee = hrp
	billboard.Size = UDim2.new(0, 240, 0, 48)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 150

	-- Position above the character based on model extents (increased Y offset)
	local function updateOffset()
		local extents = character:GetExtentsSize()
		billboard.StudsOffset = Vector3.new(0, extents.Y / 2 + 6, 0)
	end
	updateOffset()

	-- Create the name label (PlayerName (KaijuName)) above the health bar
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Text = player.Name
	nameLabel.Parent = billboard

	-- Clone health bar from ReplicatedStorage
	local healthBar = HealthTemplate:Clone()
	healthBar.AnchorPoint = Vector2.new(0, 0)
	healthBar.Size = UDim2.new(1, 0, 0, 22)
	healthBar.Position = UDim2.new(0, 0, 0, 18)
	healthBar.Parent = billboard

	-- Remove the HP text label from the bar
	local txt = healthBar:FindFirstChild("TXT")
	if txt then
		txt:Destroy()
	end

	-- Get references to clipping elements
	local clipping = healthBar:FindFirstChild("Clipping")
	local top = clipping and clipping:FindFirstChild("Top")

	-- Apply character color to the Top ImageLabel
	local function updateColor()
		local color = getCharacterColor(character)
		if color and top then
			top.ImageColor3 = color
		end
	end
	updateColor()

	-- Listen for color value changes so the bar updates if colors change mid-game
	local colorsFolder = aspects:FindFirstChild("Colors")
	if colorsFolder then
		local ultColorVal = colorsFolder:FindFirstChild("UltColor")
		if ultColorVal then
			ultColorVal.Changed:Connect(updateColor)
		end
		local normalColor = colorsFolder:FindFirstChild("NormalColor")
		if normalColor then
			local fireColorVal = normalColor:FindFirstChild("FireColor")
			if fireColorVal then
				fireColorVal.Changed:Connect(updateColor)
			end
			local bladeColorVal = normalColor:FindFirstChild("BladeColor")
			if bladeColorVal then
				bladeColorVal.Changed:Connect(updateColor)
			end
		end
	end

	-- Update the health bar display
	local function updateHealthBar()
		local healthValue = healthInfo.Value
		local maxHealthValue = maxHealthObj.Value
		local ratio = (maxHealthValue > 0) and (healthValue / maxHealthValue) or 0
		if clipping and top then
			resizeCustomLoadingBarX(ratio, clipping, top)
		end
	end

	updateHealthBar()
	healthInfo.Changed:Connect(updateHealthBar)
	maxHealthObj.Changed:Connect(updateHealthBar)

	-- Update the name label with kaiju name
	local function updateName()
		local kaijuName = getKaijuDisplayName(character, player)
		if kaijuName and kaijuName ~= "" then
			nameLabel.Text = player.Name .. " (" .. kaijuName .. ")"
		else
			nameLabel.Text = player.Name
		end
	end
	updateName()

	-- Listen for EquippedKaiju changes to update the name
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local equipped = inventory:FindFirstChild("EquippedKaiju")
		if equipped then
			equipped.Changed:Connect(updateName)
		end
		inventory.ChildAdded:Connect(function(child)
			if child.Name == "EquippedKaiju" then
				child.Changed:Connect(updateName)
				updateName()
			end
		end)
	end

	-- Parent the billboard to the character (server-side, replicates to all clients)
	billboard.Parent = character

	-- Recalculate offset after a short delay in case parts are still loading
	task.delay(1, updateOffset)
	task.delay(3, updateOffset)
end

-- Handle character respawns for each player
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(1)
		setupOverheadHealth(player, character)
	end)
	if player.Character then
		task.spawn(function()
			task.wait(1)
			setupOverheadHealth(player, player.Character)
		end)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end