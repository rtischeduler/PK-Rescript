local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Reference to Kaijus folder
local KaijusFolder = ReplicatedStorage.Assets.Kaijus.Models

-- Reference to Animations folder
local AnimationsFolder = ReplicatedStorage.Animations

-- Reference to Lighting.Maps folder for spawn locations
local Lighting = game:GetService("Lighting")

-- Default values
local DEFAULT_KAIJU = "Godzilla2000"
local DEFAULT_SKIN = "Default"

-- Prevent Roblox from auto-loading default characters
-- This must be set on the Players service, NOT on individual Player objects
Players.CharacterAutoLoads = false

-- Track players currently being spawned to prevent infinite loops
local spawningPlayers = {}

-- Track players who need respawning when the map loads
local playersWaitingForMap = {}

-- Mapping for kaiju names to animation folder names (for mismatches)
local KAIJU_TO_ANIMATION_MAP = {
	["ShowaGigan"] = "Gigan",
	["DummyG2K"] = "Zilla",
	["DummyG2k"] = "Zilla",
}

-- Backward compatibility: maps old kaiju names to new folder names in Assets.Kaijus.Models
-- This ensures players with old datastore entries (e.g. "G2K") still spawn correctly
-- after the migration to ReplicatedStorage.Assets.Kaijus.Models
local KAIJU_NAME_COMPAT = {
	["G2K"] = "Zilla",
	["Gigan"] = "ShowaGigan",
}

-- HP values for each kaiju
local KAIJU_HP = {
	["Godzilla2000"] = 1000,
	["G2K"] = 1000,
	["Zilla"] = 1000,
	["ShowaGigan"] = 1000,
	["Gigan"] = 1000,
	["DummyG2K"] = 1000,
	["DummyG2k"] = 1000,
	["Tricky"] = 1250,
	["Orga"] = 1000,
	["TitanusGodzilla"] = 1000,
	["MechaGodzilla2021"] = 1000,
}

-- Track if spawning is allowed (can be disabled during map transitions)
local spawningAllowed = true

-- Function to check if spawning is allowed
local function isSpawningAllowed()
	return spawningAllowed
end

-- Function to set spawning allowed state
local function setSpawningAllowed(allowed)
	spawningAllowed = allowed
	print("[Spawn] Spawning allowed: " .. tostring(allowed))
end

-- Function to check if a string is numeric
local function isNumeric(str)
    return tonumber(str) ~= nil
end

-- Function to get a random spawn location from the CURRENTLY LOADED map in workspace
local function getRandomSpawnLocation()
    -- Only look in the map that is actually loaded into workspace right now.
    -- Previously this searched Lighting.Maps which contains ALL maps, so it could
    -- pick a spawn point from a completely different map with different coordinates,
    -- teleporting the player into the void or below the floor.
    local currentMap = workspace:FindFirstChild("Map")
    if not currentMap then
        warn("[Spawn] No map currently loaded in Workspace!")
        return nil
    end
    
    -- Collect all SpawnLocation class instances in the loaded map
    local spawnLocations = {}
    for _, descendant in ipairs(currentMap:GetDescendants()) do
        if descendant:IsA("SpawnLocation") then
            table.insert(spawnLocations, descendant)
        end
    end
    
    -- If SpawnLocations found, pick a random one
    if #spawnLocations > 0 then
        local randomSpawn = spawnLocations[math.random(1, #spawnLocations)]
        return randomSpawn.CFrame
    end
    
    -- No SpawnLocations found in the loaded map
    warn("[Spawn] No SpawnLocation instances found in the loaded map")
    return nil
end

-- RemoteEvent reference
local SpawnEvent = script.Parent

-- Function to wait for the player's Inventory folder (created by PlayerDataManager)
local function waitForInventory(player, timeout)
	local inventory = player:FindFirstChild("Inventory")
	if inventory then return inventory end
	
	local t = 0
	while not inventory and t < (timeout or 10) do
		task.wait(0.1)
		t = t + 0.1
		inventory = player:FindFirstChild("Inventory")
	end
	
	return inventory
end

-- Function to get player's equipped Kaiju and skin from PlayerDataManager's Inventory folder
local function getPlayerData(player)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		return nil
	end
	
	local equippedKaiju = inventory:FindFirstChild("EquippedKaiju")
	local skin = inventory:FindFirstChild("Skin")
	
	local kaijuName = equippedKaiju and equippedKaiju.Value or ""
	local skinName = skin and skin.Value or ""
	
	-- If skin value contains a dash (e.g. "Godzilla2000-Charcoal"), extract just the skin part
	if skinName and skinName ~= "" then
		local dashPos = string.find(skinName, "-", 1, true)
		if dashPos then
			skinName = string.sub(skinName, dashPos + 1)
		end
	end
	
	return {
		SelectedKaiju = kaijuName ~= "" and kaijuName or nil,
		SelectedSkin = skinName ~= "" and skinName or nil,
	}
end

-- Function to set the player's equipped Kaiju on the Inventory folder
local function setPlayerKaiju(player, kaijuName)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return false end
	
	local equipped = inventory:FindFirstChild("EquippedKaiju")
	if not equipped then
		equipped = Instance.new("StringValue")
		equipped.Name = "EquippedKaiju"
		equipped.Parent = inventory
	end
	equipped.Value = kaijuName
	return true
end

-- Function to set the player's skin on the Inventory folder
local function setPlayerSkin(player, skinName)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return false end
	
	local skin = inventory:FindFirstChild("Skin")
	if skin then
		skin.Value = skinName
	end
	return true
end

-- Function to set skin for a specific kaiju (sets both kaiju and skin on the Inventory folder)
-- Also saves the skin per-kaiju in the Skins folder for independent skin tracking
local function saveSkinForKaiju(player, kaijuName, skinName)
	setPlayerKaiju(player, kaijuName)
	setPlayerSkin(player, skinName)
	
	-- Save per-kaiju skin in the Skins folder
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local skinsFolder = inventory:FindFirstChild("Skins")
		if not skinsFolder then
			skinsFolder = Instance.new("Folder")
			skinsFolder.Name = "Skins"
			skinsFolder.Parent = inventory
		end
		local kaijuSkin = skinsFolder:FindFirstChild(kaijuName)
		if not kaijuSkin then
			kaijuSkin = Instance.new("StringValue")
			kaijuSkin.Name = kaijuName
			kaijuSkin.Parent = skinsFolder
		end
		kaijuSkin.Value = skinName
	end
	
	return true
end

-- Function to get equipped skin for a specific kaiju (reads from per-kaiju Skins folder)
local function getEquippedSkinForKaiju(player, kaijuName)
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local skinsFolder = inventory:FindFirstChild("Skins")
		if skinsFolder then
			local kaijuSkin = skinsFolder:FindFirstChild(kaijuName)
			if kaijuSkin and kaijuSkin.Value ~= "" then
				return kaijuSkin.Value
			end
		end
	end
	return DEFAULT_SKIN
end

-- Function to spawn player with their selected Kaiju and skin
local function spawnPlayer(player)
	-- Check if spawning is allowed
	if not spawningAllowed then
		print("[Spawn] Spawning not allowed for " .. player.Name .. " (map transition)")
		return false
	end
	
	-- Prevent infinite respawn loop
	if spawningPlayers[player.UserId] then
		print("[DEBUG] Already spawning player " .. player.Name .. ", skipping")
		return false
	end
	spawningPlayers[player.UserId] = true
	
	-- Wait for PlayerDataManager to create the Inventory folder
	local inventory = waitForInventory(player, 10)
	if not inventory then
		print("[Spawn] No Inventory folder found for " .. player.Name .. ", using defaults")
	end

	-- Wait for PlayerDataManager to finish loading saved data from DataStore.
	-- Without this, EquippedKaiju and Skin may still be at their default/empty
	-- values because GetAsync hasn't returned yet, causing the player to spawn
	-- as default Godzilla2000 instead of their saved kaiju.
	local t = 0
	while not player:GetAttribute("DataLoaded") and t < 15 do
		task.wait(0.1)
		t = t + 0.1
	end
	if not player:GetAttribute("DataLoaded") then
		print("[Spawn] DataLoaded attribute not set after 15s for " .. player.Name .. ", proceeding with available data")
	end
	
	-- Get player data from the Inventory folder
	local playerData = getPlayerData(player)
	
	local selectedKaiju = DEFAULT_KAIJU
	local selectedSkin = DEFAULT_SKIN
	
	-- If player has data, use their selections
	if playerData then
		if playerData.SelectedKaiju then
			selectedKaiju = playerData.SelectedKaiju
		end
		if playerData.SelectedSkin then
			selectedSkin = playerData.SelectedSkin
		end
	else
		-- No inventory data - use defaults
		print("No player data found for " .. player.Name .. ", using defaults")
	end

	-- Override with per-kaiju skin if one is saved (new per-kaiju system takes priority)
	-- This ensures each kaiju spawns with its own previously equipped skin
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local skinsFolder = inventory:FindFirstChild("Skins")
		if skinsFolder then
			local perKaijuSkin = skinsFolder:FindFirstChild(selectedKaiju)
			if perKaijuSkin and perKaijuSkin.Value ~= "" then
				selectedSkin = perKaijuSkin.Value
				-- Sync the global Skin value for backward compatibility
				local skinVal = inventory:FindFirstChild("Skin")
				if skinVal then skinVal.Value = selectedSkin end
			end
		end
	end
	
	-- Apply backward compatibility mapping for old kaiju names
	-- This migrates old datastore entries (e.g. "G2K") to new names in Assets.Kaijus.Models
	if KAIJU_NAME_COMPAT[selectedKaiju] then
		print("[Spawn] Migrating old kaiju name '" .. selectedKaiju .. "' to '" .. KAIJU_NAME_COMPAT[selectedKaiju] .. "' for " .. player.Name)
		selectedKaiju = KAIJU_NAME_COMPAT[selectedKaiju]
	end
	
	-- Find the Kaiju folder
	local kaijuFolder = KaijusFolder:FindFirstChild(selectedKaiju)
	if not kaijuFolder then
		warn("Kaiju folder not found: " .. selectedKaiju .. ", falling back to default")
		kaijuFolder = KaijusFolder:FindFirstChild(DEFAULT_KAIJU)
		selectedKaiju = DEFAULT_KAIJU
		selectedSkin = DEFAULT_SKIN
	end
	
	-- Find the skin model
	-- The stored skin name could be either:
	-- 1. Full model name like "Godzilla2000-Charcoal"
	-- 2. Just the skin part like "Charcoal"
	local skinModel = kaijuFolder and kaijuFolder:FindFirstChild(selectedSkin)
	local skinModelName = selectedSkin
	
	-- If not found, try prepending kaiju name
	if not skinModel then
		skinModelName = selectedKaiju .. "-" .. selectedSkin
		skinModel = kaijuFolder and kaijuFolder:FindFirstChild(skinModelName)
	end
	
	-- If skin not found, try default skin
	if not skinModel then
		warn("Skin model not found: " .. selectedSkin .. " or " .. skinModelName .. ", falling back to default skin")
		skinModelName = selectedKaiju .. "-" .. DEFAULT_SKIN
		skinModel = kaijuFolder and kaijuFolder:FindFirstChild(skinModelName)
		selectedSkin = DEFAULT_SKIN
	end
	
	-- Final fallback
	if not skinModel then
		warn("Default skin not found for " .. selectedKaiju .. ", trying Godzilla2000-Default")
		kaijuFolder = KaijusFolder:FindFirstChild(DEFAULT_KAIJU)
		skinModel = kaijuFolder and kaijuFolder:FindFirstChild(DEFAULT_KAIJU .. "-" .. DEFAULT_SKIN)
		selectedKaiju = DEFAULT_KAIJU
		selectedSkin = DEFAULT_SKIN
	end
	
	if not skinModel then
		warn("CRITICAL: Could not find any valid Kaiju model!")
		return false
	end
	
	-- Clone the skin model
	local character = skinModel:Clone()
	character.Name = player.Name
	character:SetAttribute("IsKaiju", true)
	
	-- Unanchor all parts in the character — some skin models have anchored parts
	-- left over from editing, which prevents the Humanoid from moving them.
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
		end
	end
	
	-- Set kaiju HP
	local kaijuHP = KAIJU_HP[selectedKaiju] or 1000
	local charHumanoid = character:FindFirstChildOfClass("Humanoid")
	if charHumanoid then
		charHumanoid.MaxHealth = kaijuHP
		charHumanoid.Health = kaijuHP
		print("[Spawn] Set " .. selectedKaiju .. " HP to " .. kaijuHP .. " for " .. player.Name)
	end
	
	-- Clone the kaiju's Name and Image values into the character so the client UI can read them
	local kaijuNameValue = kaijuFolder:FindFirstChild("Name")
	if kaijuNameValue then
		kaijuNameValue:Clone().Parent = character
	end
	local kaijuImageValue = kaijuFolder:FindFirstChild("Image")
	if kaijuImageValue then
		kaijuImageValue:Clone().Parent = character
	end
	
	-- Clone animations for this kaiju
	-- Use mapped animation name if available
	local animationFolderName = KAIJU_TO_ANIMATION_MAP[selectedKaiju] or selectedKaiju
	local kaijuAnimationsFolder = AnimationsFolder:FindFirstChild(animationFolderName)
	if kaijuAnimationsFolder then
		local innerAnimationsFolder = kaijuAnimationsFolder:FindFirstChild("Animations")
		if innerAnimationsFolder then
			local clonedAnimations = innerAnimationsFolder:Clone()
			clonedAnimations.Parent = character
			print("Cloned animations for " .. selectedKaiju .. " (using " .. animationFolderName .. ") to " .. player.Name)
		else
			warn("No inner Animations folder found for " .. animationFolderName)
		end
	else
			warn("No animations folder found for " .. animationFolderName .. " (kaiju: " .. selectedKaiju .. ")")
	end
	
	-- Get random spawn location from Map
	local spawnCFrame = getRandomSpawnLocation()
	
	-- If no map is loaded yet, queue this player for respawn when map loads
	if not spawnCFrame then
		warn("[Spawn] No map loaded yet for " .. player.Name .. ", queuing for respawn")
		playersWaitingForMap[player.UserId] = player
		
		-- Clear spawning flag so they can be respawned later
		spawningPlayers[player.UserId] = nil
		return false
	end
	
	-- Player is no longer waiting for map
	playersWaitingForMap[player.UserId] = nil

	-- Raycast straight down from the spawn point to find the actual floor.
	-- Some maps have SpawnLocations floating high above the ground, and large
	-- kaiju can clip through the floor when falling long distances. Placing
	-- them directly on the floor via raycast avoids the fall entirely.
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local halfHeight = hrp and (hrp.Size.Y / 2) or 16

	local rayOrigin = spawnCFrame.Position + Vector3.new(0, 5, 0)
	local rayDirection = Vector3.new(0, -1000, 0)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {character}
	rayParams.RespectCanCollide = true

	local rayResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	if rayResult then
		-- Place the HRP center so its bottom sits on the floor surface
		local floorY = rayResult.Position.Y
		local newPos = Vector3.new(spawnCFrame.Position.X, floorY + halfHeight, spawnCFrame.Position.Z)
		spawnCFrame = CFrame.new(newPos) * (spawnCFrame - spawnCFrame.Position)
		print("[Spawn] Raycast found floor at Y=" .. math.floor(floorY) .. ", adjusted spawn Y=" .. math.floor(newPos.Y))
	else
		-- No floor found — add a Y offset so the kaiju spawns above the map
	-- and can fall onto it instead of below it
		local offsetPos = spawnCFrame.Position + Vector3.new(0, 300, 0)
		spawnCFrame = CFrame.new(offsetPos) * (spawnCFrame - spawnCFrame.Position)
		warn("[Spawn] No floor found below spawn, applying +300 Y offset")
	end

	-- Remove old character (set Parent nil, do NOT Destroy)
	local oldCharacter = player.Character
	if oldCharacter then
		oldCharacter:Destroy()
	end

	-- Clone Animate script into the character (before parenting so it's ready)
	local Control = game.ReplicatedStorage.Animate:Clone()
	Control.Parent = character
	Control.Enabled = true

	-- Clone MaterialFootstep script into the character for footstep sounds
	local materialFootstep = game.ServerScriptService:FindFirstChild("MaterialFootstep")
	if materialFootstep then
		local footstepClone = materialFootstep:Clone()
		footstepClone.Parent = character
		footstepClone.Enabled = true
		print("[Spawn] Cloned MaterialFootstep into " .. player.Name)
	else
		warn("[Spawn] MaterialFootstep script not found in ServerScriptService!")
	end

	-- Parent the character into workspace first. PivotTo only actually moves parts
	-- when the model is in the game tree — calling it before parenting only updates
	-- WorldPivot metadata and leaves parts at their old positions.
	character.Parent = workspace

	-- Teleport the entire model to the spawn location. PivotTo on an in-tree model
	-- moves every part so the PrimaryPart (HumanoidRootPart) lands exactly on
	-- spawnCFrame. This handles kaiju whose WorldPivot is far from their HRP.
	character:PivotTo(spawnCFrame)

	-- Belt-and-suspenders: also set HRP CFrame directly to guarantee the physics
	-- assembly root is exactly on the spawn point.
	if hrp then
		hrp.CFrame = spawnCFrame
	else
		warn("Cloned character missing HumanoidRootPart")
	end

	-- Set player.Character ONLY ONCE, AFTER the model is in workspace at the
	-- correct position. Setting it before parenting or setting it twice can cause
	-- Roblox to re-evaluate the character and shift its position.
	player.Character = character
	
	print("Spawned " .. player.Name .. " as " .. selectedKaiju .. " with skin " .. selectedSkin)

	-- Connect to Humanoid.Died to respawn the player when they die
	local charHumanoid = character:FindFirstChildOfClass("Humanoid")
	if charHumanoid then
		charHumanoid.Died:Connect(function()
			print("[Spawn] " .. player.Name .. " died, respawning in 3 seconds...")
			task.delay(3, function()
				if player.Parent == Players then
					spawnPlayer(player)
				end
			end)
		end)
	end

	-- Clear spawning flag after a short delay
	task.delay(1, function()
		spawningPlayers[player.UserId] = nil
	end)
	
	return true, selectedKaiju, selectedSkin
end

-- Handle spawn requests from clients
SpawnEvent.OnServerEvent:Connect(function(player)
	spawnPlayer(player)
end)

-- When the Maps folder is added to Lighting, respawn all players who were waiting
Lighting.ChildAdded:Connect(function(child)
	if child.Name == "Maps" then
		print("[Spawn] Maps folder added to Lighting, respawning queued players...")
		-- Small delay to let the folder fully load
		task.wait(1)
		
		for userId, player in pairs(playersWaitingForMap) do
			if player.Parent == Players then
				print("[Spawn] Respawning " .. player.Name .. " (was waiting for map)")
				task.spawn(spawnPlayer, player)
			end
		end
		
		-- Also check all current players — if any are not kaiju, respawn them
		for _, player in Players:GetPlayers() do
			local character = player.Character
			if character then
				local isKaiju = character:GetAttribute("IsKaiju") == true
				if not isKaiju then
					print("[Spawn] Found non-kaiju character for " .. player.Name .. " after Maps loaded, respawning...")
					task.spawn(spawnPlayer, player)
				end
			end
		end
	end
end)

-- Handle players joining - spawn them with their saved Kaiju
Players.PlayerAdded:Connect(function(player)
	-- Connect to CharacterAdded to handle any future respawns
	player.CharacterAdded:Connect(function(character)
		-- Check if this is a kaiju character using the IsKaiju attribute
		-- This is more reliable than checking for Animations folder
		local isKaiju = character:GetAttribute("IsKaiju") == true
		
		-- If it's not a kaiju character, immediately respawn as kaiju
		if not isKaiju then
			print("[Spawn] Non-kaiju character detected for " .. player.Name .. ", respawning as kaiju...")
			task.spawn(spawnPlayer, player)
		end
	end)
	
	-- Initial spawn as Kaiju - spawn immediately
	spawnPlayer(player)
end)

-- Handle players already in game (for script reload)
for _, player in Players:GetPlayers() do
	task.spawn(function()
		task.wait(0.5)
		spawnPlayer(player)
	end)
end

-- Export functions for external use (like saving selections)
local module = {}

function module.SetPlayerKaiju(player, kaijuName)
	return setPlayerKaiju(player, kaijuName)
end

function module.SetPlayerSkin(player, skinName)
	return setPlayerSkin(player, skinName)
end

function module.SetPlayerKaijuAndSkin(player, kaijuName, skinName)
	setPlayerKaiju(player, kaijuName)
	return setPlayerSkin(player, skinName)
end

function module.SetSkinForKaiju(player, kaijuName, skinName)
	return saveSkinForKaiju(player, kaijuName, skinName)
end

function module.GetEquippedSkinForKaiju(player, kaijuName)
	return getEquippedSkinForKaiju(player, kaijuName)
end

function module.GetPlayerData(player)
	return getPlayerData(player)
end

function module.GetMappedKaijuName(kaijuName)
	return KAIJU_NAME_COMPAT[kaijuName] or kaijuName
end

function module.SpawnPlayer(player)
	return spawnPlayer(player)
end

function module.SetSpawningAllowed(allowed)
	setSpawningAllowed(allowed)
end

function module.IsSpawningAllowed()
	return isSpawningAllowed()
end

-- Make module accessible
_G.KaijuSpawnModule = module

-- Handle KaijuSelection RemoteEvent from client
local KaijuSelectionEvent = ReplicatedStorage:FindFirstChild("KaijuSelection")
if KaijuSelectionEvent then
	KaijuSelectionEvent.OnServerEvent:Connect(function(player, action, kaijuName, skinName)
		local inventory = player:FindFirstChild("Inventory")
		if not inventory then return end

		-- Helper: check if player owns a kaiju
		local function ownsKaiju(name)
			local owned = inventory:FindFirstChild(name)
			return owned and owned:IsA("BoolValue") and owned.Value
		end

		-- Helper: check if player owns a skin (or it's Default)
		-- Matches "Default", "", and any skin ending in "-Default" (case-insensitive)
		-- e.g. "Godzilla2000-Default", "Zilla-Default", etc.
		local function ownsSkin(name)
			if name == "Default" or name == "" then return true end
			local lowerName = string.lower(name)
			if string.sub(lowerName, -8) == "-default" then return true end
			local owned = inventory:FindFirstChild(name)
			return owned and owned:IsA("BoolValue") and owned.Value
		end

		if action == "SetKaiju" then
			-- Set only the Kaiju on the Inventory folder (DO NOT RESPAWN)
			if kaijuName and ownsKaiju(kaijuName) then
				setPlayerKaiju(player, kaijuName)
				-- Load the per-kaiju skin
				local perKaijuSkin = getEquippedSkinForKaiju(player, kaijuName)
				setPlayerSkin(player, perKaijuSkin)
				print("Saved Kaiju selection for " .. player.Name .. ": " .. kaijuName .. " (skin: " .. perKaijuSkin .. ")")
			else
				print("[Spawn] Player does not own kaiju: " .. tostring(kaijuName))
			end
		elseif action == "SetSkin" then
			-- Set only the Skin on the Inventory folder
			if skinName and ownsSkin(skinName) then
				setPlayerSkin(player, skinName)
				print("Saved Skin selection for " .. player.Name .. ": " .. skinName)
			else
				print("[Spawn] Player does not own skin: " .. tostring(skinName))
			end
		elseif action == "SetSkinForKaiju" then
			-- Set skin for a specific kaiju (DO NOT RESPAWN)
			if kaijuName and skinName and ownsKaiju(kaijuName) and ownsSkin(skinName) then
				saveSkinForKaiju(player, kaijuName, skinName)
				print("Saved skin " .. skinName .. " for Kaiju " .. kaijuName .. " for " .. player.Name)
			else
				print("[Spawn] Ownership check failed for SetSkinForKaiju: kaiju=" .. tostring(kaijuName) .. " skin=" .. tostring(skinName))
			end
		elseif action == "SetKaijuAndSkin" then
			-- Set both Kaiju and Skin on the Inventory folder
			if kaijuName and skinName and ownsKaiju(kaijuName) and ownsSkin(skinName) then
				setPlayerKaiju(player, kaijuName)
				setPlayerSkin(player, skinName)
				-- Save per-kaiju skin
				saveSkinForKaiju(player, kaijuName, skinName)
				print("Saved Kaiju and Skin for " .. player.Name .. ": " .. kaijuName .. " - " .. skinName)
				
				-- Respawn the player with the new selection
				spawnPlayer(player)
			else
				print("[Spawn] Ownership check failed for SetKaijuAndSkin: kaiju=" .. tostring(kaijuName) .. " skin=" .. tostring(skinName))
			end
		end
	end)
else
	warn("KaijuSelection RemoteEvent not found in ReplicatedStorage!")
end

print("Kaiju Spawn System loaded successfully!")