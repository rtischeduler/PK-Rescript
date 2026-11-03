-- Godzilla2000 Rage Dorsal Glow
-- When rage is full, all BeamColors (dorsal fins) turn to FireColor with Neon material.
-- When rage drops below max, they revert to NormalColor and Concrete material.

-- The script is cloned into the character at runtime:
--   character.Animations.Event.RageDorsalGlow
local character = script.Parent and script.Parent.Parent and script.Parent.Parent.Parent
if not character then
	warn("[RageDorsalGlow] Could not find character ancestor")
	return
end

-- Wait for Aspects to be available (character may still be initializing)
local aspects = character:FindFirstChild("Aspects")
if not aspects then
	local t = 0
	while not aspects and t < 5 do
		task.wait(0.1)
		t = t + 0.1
		aspects = character:FindFirstChild("Aspects")
	end
end
if not aspects then
	warn("[RageDorsalGlow] No Aspects folder found on character")
	return
end

-- Resolve color values
local colors = aspects:FindFirstChild("Colors")
local normalColorVal = colors and colors:FindFirstChild("NormalColor")
local fireColorVal = normalColorVal and normalColorVal:FindFirstChild("FireColor")

if not normalColorVal or not fireColorVal then
	warn("[RageDorsalGlow] Missing NormalColor or FireColor")
	return
end

-- Resolve rage values
local info = aspects:FindFirstChild("Info")
local rageVal = info and info:FindFirstChild("Rage")
local maxRageVal = rageVal and rageVal:FindFirstChild("MaxRage")

if not rageVal then
	warn("[RageDorsalGlow] Missing Rage value")
	return
end

local maxRage = (maxRageVal and maxRageVal.Value) or 100

-- Find the BeamColors model (dorsal fins)
local beamColorsModel = character:FindFirstChild("BeamColors")
if not beamColorsModel then
	warn("[RageDorsalGlow] No BeamColors model found on character")
	return
end

-- Collect all dorsal parts
local dorsalParts = {}
for _, child in ipairs(beamColorsModel:GetChildren()) do
	if child:IsA("BasePart") then
		table.insert(dorsalParts, child)
	end
end

if #dorsalParts == 0 then
	warn("[RageDorsalGlow] No parts found inside BeamColors")
	return
end

-- Store original material so we can revert correctly
local ORIGINAL_MATERIAL = Enum.Material.Concrete

local function applyRageState(isRageFull)
	local color = isRageFull and fireColorVal.Value or normalColorVal.Value
	local material = isRageFull and Enum.Material.Neon or ORIGINAL_MATERIAL

	for _, part in ipairs(dorsalParts) do
		if part and part.Parent then
			part.Color = color
			part.Material = material
		end
	end
end

-- Track rage state to avoid redundant updates
local rageFull = false

-- Apply initial state
if rageVal.Value >= maxRage then
	rageFull = true
end
applyRageState(rageFull)

-- Listen for rage changes
rageVal.Changed:Connect(function(newRage)
	local shouldBeFull = newRage >= maxRage
	if shouldBeFull ~= rageFull then
		rageFull = shouldBeFull
		applyRageState(rageFull)
	end
end)

-- Also listen for MaxRage changes in case it adjusts
if maxRageVal then
	maxRageVal.Changed:Connect(function(newMax)
		maxRage = newMax
		local shouldBeFull = rageVal.Value >= maxRage
		if shouldBeFull ~= rageFull then
			rageFull = shouldBeFull
			applyRageState(rageFull)
		end
	end)
end

-- Poll as a safety net in case Changed events are missed (e.g. value reset during morph)
task.spawn(function()
	while character.Parent do
		task.wait(0.5)
		local shouldBeFull = rageVal.Value >= maxRage
		if shouldBeFull ~= rageFull then
			rageFull = shouldBeFull
			applyRageState(rageFull)
		end
	end
end)