-- WaterDetection: Detects when camera is underwater and applies swim vision, water sound, and muffle effect

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gameGui = script.Parent
local swimVision = gameGui:FindFirstChild("SwimVision")
local waterSound = gameGui:FindFirstChild("Water")

-- Find the Muffle EqualizerSoundEffect template in ReplicatedStorage
local muffleTemplate = ReplicatedStorage:FindFirstChild("Assets")
if muffleTemplate then
	local kaijus = muffleTemplate:FindFirstChild("Kaijus")
	if kaijus then
		local sounds = kaijus:FindFirstChild("Sounds")
		if sounds then
			muffleTemplate = sounds:FindFirstChild("Muffle")
		else
			muffleTemplate = nil
		end
	else
		muffleTemplate = nil
	end
else
	muffleTemplate = nil
end

local isInWater = false

-- Create a SoundGroup with the Muffle effect to muffle all sounds when underwater
local muffleGroup = Instance.new("SoundGroup")
muffleGroup.Name = "UnderwaterMuffle"
muffleGroup.Parent = SoundService
if muffleTemplate then
	local muffleClone = muffleTemplate:Clone()
	muffleClone.Parent = muffleGroup
end

-- Track sounds we've muffled so we can restore them on exit
local muffledSounds = {}
local descendantConnection = nil

local function setSoundMuffled(sound)
	if sound:IsA("Sound") and not muffledSounds[sound] and sound.SoundGroup == nil then
		sound.SoundGroup = muffleGroup
		muffledSounds[sound] = true
	end
end

-- Cache water-related parts in the workspace for non-terrain water detection
local waterParts = {}
local function refreshWaterParts()
	waterParts = {}
	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("BasePart") then
			local lowerName = string.lower(descendant.Name)
			if lowerName == "waterspot" or descendant.Material == Enum.Material.Water then
				table.insert(waterParts, descendant)
			end
		end
	end
end

refreshWaterParts()

-- Refresh periodically to catch newly loaded map water parts
task.spawn(function()
	while true do
		refreshWaterParts()
		task.wait(5)
	end
end)

-- Also refresh when new parts are added to workspace
Workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BasePart") then
		local lowerName = string.lower(descendant.Name)
		if lowerName == "waterspot" or descendant.Material == Enum.Material.Water then
			table.insert(waterParts, descendant)
		end
	end
end)

local function isCameraInTerrainWater(pos)
	local terrain = Workspace:FindFirstChild("Terrain")
	if not terrain then return false end

	local resolution = 4
	local minX = math.floor(pos.X / resolution) * resolution
	local minY = math.floor(pos.Y / resolution) * resolution
	local minZ = math.floor(pos.Z / resolution) * resolution
	local region = Region3.new(
		Vector3.new(minX, minY, minZ),
		Vector3.new(minX + resolution, minY + resolution, minZ + resolution)
	)

	local ok, materials = pcall(function()
		return terrain:ReadVoxels(region, resolution)
	end)

	if ok and materials and materials[1] and materials[1][1] and materials[1][1][1] then
		return materials[1][1][1] == Enum.Material.Water
	end

	return false
end

local function isCameraInWaterParts(pos)
	for _, part in waterParts do
		if part.Parent then
			local partPos = part.Position
			-- Beneath the waterspot's Y surface = underwater (X/Z bounds ignored)
			if pos.Y <= partPos.Y then
				return true
			end
		end
	end
	return false
end

local function isCameraInWater()
	local camera = Workspace.CurrentCamera
	if not camera then return false end
	local pos = camera.CFrame.Position
	return isCameraInTerrainWater(pos) or isCameraInWaterParts(pos)
end

local function enterWater()
	isInWater = true
	-- Fade in SwimVision overlay
	if swimVision then
		TweenService:Create(swimVision, TweenInfo.new(0.5), {ImageTransparency = 0.55}):Play()
	end
	-- Fade in water ambient sound
	if waterSound then
		waterSound:Play()
		TweenService:Create(waterSound, TweenInfo.new(0.5), {Volume = 0.35}):Play()
	end
	-- Muffle ALL sounds in the game by assigning them to the underwater SoundGroup
	for _, descendant in game:GetDescendants() do
		setSoundMuffled(descendant)
	end
	-- Listen for new sounds added while underwater (roars, songs, footsteps, etc.)
	descendantConnection = game.DescendantAdded:Connect(function(descendant)
		if isInWater then
			setSoundMuffled(descendant)
		end
	end)
end

local function exitWater()
	isInWater = false
	-- Fade out SwimVision overlay
	if swimVision then
		TweenService:Create(swimVision, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
	end
	-- Fade out water ambient sound
	if waterSound then
		TweenService:Create(waterSound, TweenInfo.new(0.5), {Volume = 0}):Play()
	end
	-- Unmuffle all sounds by restoring their SoundGroup to nil
	for sound in pairs(muffledSounds) do
		if sound.Parent then
			sound.SoundGroup = nil
		end
	end
	muffledSounds = {}
	if descendantConnection then
		descendantConnection:Disconnect()
		descendantConnection = nil
	end
end

-- Main detection loop
task.spawn(function()
	while true do
		local inWater = isCameraInWater()
		if inWater and not isInWater then
			enterWater()
		elseif not inWater and isInWater then
			exitWater()
		end
		task.wait(0.1)
	end
end)