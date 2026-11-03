local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerHolder = script.Parent
local KaijuNameLabel = PlayerHolder:WaitForChild("KaijuName")
local KaijuImageLabel = PlayerHolder:WaitForChild("KaijuImage")

-- Fallback kaiju display data (used when Name/Image values are missing)
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
	-- Read the Name and Image values cloned into the character from ReplicatedStorage.Kaijus.Models
	local nameValue = character:FindFirstChild("Name")
	local imageValue = character:FindFirstChild("Image")

	local nameSet = false
	local imageSet = false

	if nameValue and nameValue:IsA("StringValue") then
		KaijuNameLabel.Text = nameValue.Value
		nameSet = true
	end

	if imageValue and imageValue:IsA("NumberValue") then
		KaijuImageLabel.Image = "rbxassetid://" .. tostring(math.floor(imageValue.Value))
		imageSet = true
	end

	-- Fallback: use equipped kaiju mapping for any missing values
	if not nameSet or not imageSet then
		local kaijuName = getEquippedKaiju()
		if kaijuName and KAIJU_DISPLAY[kaijuName] then
			local data = KAIJU_DISPLAY[kaijuName]
			if not nameSet then
				KaijuNameLabel.Text = data.name
			end
			if not imageSet then
				KaijuImageLabel.Image = data.image
			end
		end
	end
end

-- Update immediately when character loads or respawns
Player.CharacterAdded:Connect(function(character)
	-- Wait briefly for the cloned values to be replicated
	task.wait(0.5)
	updateKaijuDisplay(character)
end)

-- Constant interval check as a safety net to ensure the display always stays in sync
while true do
	local character = Player.Character
	if character then
		updateKaijuDisplay(character)
	end
	task.wait(1)
end