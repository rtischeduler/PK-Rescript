-- KaijuDisplayHandler: Updates the kaiju name, image, and player name in the HUD
-- Tries multiple sources in order: Settings module -> cloned Name/Image values -> fallback mapping
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerHolder = script.Parent
local KaijuNameLabel = PlayerHolder:WaitForChild("KaijuName")
local KaijuImageLabel = PlayerHolder:WaitForChild("KaijuImage")
local PlayerNameLabel = PlayerHolder:WaitForChild("PlayerName")

-- Fallback kaiju display data (used when Settings module fails to load)
local KAIJU_DISPLAY = {
	["Godzilla2000"]     = {name = "Godzilla 2000",   image = "rbxassetid://9001341666"},
	["TitanusGodzilla"]  = {name = "Titanus Godzilla", image = "rbxassetid://10767598689"},
	["ShowaGigan"]       = {name = "Showa Gigan",     image = "rbxassetid://10516719614"},
	["Orga"]             = {name = "Orga",            image = "rbxassetid://9362887059"},
	["Zilla"]            = {name = "Zilla",           image = "rbxassetid://10245061487"},
	["Gamma"]            = {name = "Gamma",           image = "rbxassetid://10860355646"},
	["Destoroyah"]       = {name = "Destoroyah",      image = "rbxassetid://9001341666"},
	["DummyG2k"]         = {name = "Godzilla 2000",   image = "rbxassetid://9001341666"},
	["MechaGodzilla2021"] = {name = "MechaGodzilla",  image = "rbxassetid://9001341666"},
	["Tricky"]           = {name = "Tricky",          image = "rbxassetid://9001341666"},
	["Gilga"]            = {name = "Gilga",           image = "rbxassetid://9001341666"},
}

-- Backward compat mapping (same as spawn script)
local KAIJU_COMPAT = {
	["G2K"] = "Zilla",
	["Gigan"] = "ShowaGigan",
}

local function getEquippedKaiju()
	local inventory = Player:FindFirstChild("Inventory")
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

local function updateKaijuDisplay(character)
	-- Set player name
	PlayerNameLabel.Text = Player.Name

	local displayName = nil
	local displayImage = nil

	-- Method 1: Try Settings module
	local settingsModule = character:FindFirstChild("Settings")
	if settingsModule and settingsModule:IsA("ModuleScript") then
		local success, settings = pcall(require, settingsModule)
		if success and type(settings) == "table" then
			displayName = settings.KaijuName
			displayImage = settings.KaijuImage
		end
	end

	-- Method 2: Try cloned Name/Image values (from spawn script)
	if not displayName or not displayImage then
		local nameValue = character:FindFirstChild("Name")
		local imageValue = character:FindFirstChild("Image")
		if nameValue and nameValue:IsA("StringValue") then
			displayName = nameValue.Value
		end
		if imageValue and imageValue:IsA("NumberValue") then
			displayImage = "rbxassetid://" .. tostring(math.floor(imageValue.Value))
		end
	end

	-- Method 3: Use fallback mapping based on equipped kaiju
	if not displayName or not displayImage then
		local kaijuName = getEquippedKaiju()
		if kaijuName and KAIJU_DISPLAY[kaijuName] then
			local data = KAIJU_DISPLAY[kaijuName]
			if not displayName then displayName = data.name end
			if not displayImage then displayImage = data.image end
		end
	end

	-- Apply the display values
	if displayName then
		KaijuNameLabel.Text = tostring(displayName)
	end
	if displayImage then
		KaijuImageLabel.Image = tostring(displayImage)
	end
end

-- Update every time a new character loads (handles respawns)
Player.CharacterAdded:Connect(function(character)
	task.wait(0.5)
	updateKaijuDisplay(character)
end)

-- Handle the current character if one already exists
if Player.Character then
	task.spawn(function()
		task.wait(0.5)
		updateKaijuDisplay(Player.Character)
	end)
end
