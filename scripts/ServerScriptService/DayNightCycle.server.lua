-- Day & Night Cycle System
-- Fixed: ClockTime wrapping through midnight, proper Day start,
--        building lights timing, brightness/ambient transitions

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local TRANSITION_TIME = 300 -- seconds per phase transition
local TWEEN_STEP = 0.1 -- update interval in seconds

-- Sky templates stored in Lighting.cycle
local cycleFolder = Lighting:FindFirstChild("cycle")
local skyTemplates = {
	day   = cycleFolder and cycleFolder:FindFirstChild("Day"),
	mid   = cycleFolder and cycleFolder:FindFirstChild("mid"),
	dusk  = cycleFolder and cycleFolder:FindFirstChild("Dusk"),
	night = cycleFolder and cycleFolder:FindFirstChild("Night"),
}

-- Mark cycle skies with an attribute so we only manage our own skies
for _, sky in pairs(skyTemplates) do
	if sky then
		sky:SetAttribute("CycleSky", true)
	end
end

-- Phase definitions: full day/night cycle
-- Day=10 (morning) -> Midday=14 (afternoon) -> Dusk=18 (sunset) -> Night=0 (midnight) -> Dawn=6 (sunrise)
local phases = {
	{name = "Day",    clockTime = 10, sky = "day",   lightsOn = false, brightness = 3,   ambient = Color3.fromRGB(120, 120, 120)},
	{name = "Midday", clockTime = 14, sky = "mid",   lightsOn = false, brightness = 3,   ambient = Color3.fromRGB(140, 140, 140)},
	{name = "Dusk",   clockTime = 18, sky = "dusk",  lightsOn = true,  brightness = 1.5, ambient = Color3.fromRGB(100, 60, 30)},
	{name = "Night",  clockTime = 0,  sky = "night", lightsOn = true,  brightness = 0.5, ambient = Color3.fromRGB(30, 30, 50)},
	{name = "Dawn",   clockTime = 6,  sky = "day",   lightsOn = false, brightness = 1.5, ambient = Color3.fromRGB(100, 70, 50)},
}

-- Remove cycle skies from Lighting (return to cycleFolder), remove non-cycle skies
local function clearSky()
	for _, child in Lighting:GetChildren() do
		if child:IsA("Sky") then
			if child:GetAttribute("CycleSky") then
				child.Parent = cycleFolder
			else
				child.Parent = nil -- remove non-cycle sky (e.g. from map loading)
			end
		end
	end
end

-- Equip a sky by reparenting it to Lighting
local function setSky(skyName)
	clearSky()
	local template = skyTemplates[skyName]
	if template then
		template.Parent = Lighting
	end
end

-- ===== Building Light System =====
-- 50% of glass parts randomly selected to get dim yellow lights at night

local LIGHT_COLOR = Color3.fromRGB(255, 214, 85)  -- Warm yellow glow
local LIGHT_BRIGHTNESS = 0.3  -- Very dim
local LIGHT_RANGE = 18
local ORIGINAL_COLOR_ATTR = "OriginalGlassColor"
local BUILDING_LIGHT_TAG = "BuildingLight"
local LIGHT_CHANCE = 0.5  -- 50% of glass parts get lit

-- Track which parts currently have lights so we can restore them
local litParts = {}

-- Check if a part is inside Workspace.Buildings
local function isInBuildings(part)
	local parent = part.Parent
	while parent do
		if parent == Workspace:FindFirstChild("Buildings") then
			return true
		end
		parent = parent.Parent
	end
	return false
end

-- Apply light to a single glass part (store original color, turn yellow, add PointLight)
local function applyLight(part)
	if not part:GetAttribute(ORIGINAL_COLOR_ATTR) then
		local c = part.Color
		part:SetAttribute(ORIGINAL_COLOR_ATTR, {R = c.R, G = c.G, B = c.B})
	end
	part.Color = LIGHT_COLOR

	if not part:FindFirstChild(BUILDING_LIGHT_TAG) then
		local light = Instance.new("PointLight")
		light.Name = BUILDING_LIGHT_TAG
		light.Color = LIGHT_COLOR
		light.Brightness = LIGHT_BRIGHTNESS
		light.Range = LIGHT_RANGE
		light.Shadows = false
		light.Parent = part
	end
end

-- Restore a single glass part to its original color and remove PointLight
local function removeLight(part)
	if not part or not part.Parent then return end

	local savedColor = part:GetAttribute(ORIGINAL_COLOR_ATTR)
	if savedColor then
		part.Color = Color3.new(savedColor.R, savedColor.G, savedColor.B)
		part:SetAttribute(ORIGINAL_COLOR_ATTR, nil)
	end

	local light = part:FindFirstChild(BUILDING_LIGHT_TAG)
	if light then
		light.Parent = nil
	end
end

-- Turn on building lights: find ALL glass parts, randomly light 50%
local function turnOnBuildingLights()
	local buildings = Workspace:FindFirstChild("Buildings")
	if not buildings then return end

	litParts = {}  -- clear previous tracking

	for _, building in buildings:GetChildren() do
		if building:IsA("Model") then
			for _, descendant in building:GetDescendants() do
				if descendant:IsA("BasePart") and descendant.Material == Enum.Material.Glass then
					-- 50% chance to light this part
					if math.random() <= LIGHT_CHANCE then
						applyLight(descendant)
						table.insert(litParts, descendant)
					end
				end
			end
		end
	end
end

-- Turn off building lights: restore all lit parts to normal glass
local function turnOffBuildingLights()
	for _, part in ipairs(litParts) do
		removeLight(part)
	end
	litParts = {}
end

-- Track current light state to avoid redundant toggling
local lightsCurrentlyOn = false

-- Handle buildings/parts added during gameplay (e.g. revived buildings)
local function onDescendantAdded(descendant)
	if not lightsCurrentlyOn then return end
	if not descendant:IsA("BasePart") then return end
	if descendant.Material ~= Enum.Material.Glass then return end
	if not isInBuildings(descendant) then return end

	-- 50% chance to light newly added glass parts
	if math.random() <= LIGHT_CHANCE then
		applyLight(descendant)
		table.insert(litParts, descendant)
	end
end

Workspace.DescendantAdded:Connect(onDescendantAdded)

-- ===== Main Cycle =====

-- Manual tween that wraps ClockTime forward through midnight correctly
local function tweenPhase(fromPhase, toPhase)
	local fromTime = fromPhase.clockTime
	local toTime = toPhase.clockTime

	-- If target is earlier than start, wrap forward through midnight
	local targetTime = toTime
	if toTime < fromTime then
		targetTime = toTime + 24
	end

	local elapsed = 0
	while elapsed < TRANSITION_TIME do
		local dt = task.wait(TWEEN_STEP)
		if dt == nil then dt = TWEEN_STEP end
		elapsed = elapsed + dt
		if elapsed >= TRANSITION_TIME then break end

		local progress = elapsed / TRANSITION_TIME
		Lighting.ClockTime = (fromTime + (targetTime - fromTime) * progress) % 24
		Lighting.Brightness = fromPhase.brightness + (toPhase.brightness - fromPhase.brightness) * progress
		Lighting.Ambient = fromPhase.ambient:Lerp(toPhase.ambient, progress)
	end

	-- Snap to final values
	Lighting.ClockTime = toTime
	Lighting.Brightness = toPhase.brightness
	Lighting.Ambient = toPhase.ambient
end

-- Initialize: start on Day phase
local phaseIndex = 1
local currentPhase = phases[1]
setSky(currentPhase.sky)
Lighting.ClockTime = currentPhase.clockTime
Lighting.Brightness = currentPhase.brightness
Lighting.Ambient = currentPhase.ambient

-- Main cycle loop
while true do
	local nextIndex = (phaseIndex % #phases) + 1
	local nextPhase = phases[nextIndex]

	-- Smoothly transition ClockTime, Brightness, Ambient
	tweenPhase(currentPhase, nextPhase)

	-- AFTER reaching the new phase: swap sky and toggle lights
	setSky(nextPhase.sky)

	if nextPhase.lightsOn and not lightsCurrentlyOn then
		turnOnBuildingLights()
		lightsCurrentlyOn = true
	elseif not nextPhase.lightsOn and lightsCurrentlyOn then
		turnOffBuildingLights()
		lightsCurrentlyOn = false
	end

	currentPhase = nextPhase
	phaseIndex = nextIndex
end