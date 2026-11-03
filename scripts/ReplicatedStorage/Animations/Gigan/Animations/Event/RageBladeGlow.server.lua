-- ShowaGigan Rage Blade Glow
-- When rage is full, LKnife and RSword turn to BladeColor with Neon material.
-- When rage drops below max, they revert to NormalColor and Metal material.

-- The script is cloned into the character at runtime:
--   character.Animations.Event.RageBladeGlow
local character = script.Parent and script.Parent.Parent and script.Parent.Parent.Parent
if not character then
	warn("[RageBladeGlow] Could not find character ancestor")
	return
end

-- Wait for Aspects to be available (character may still be initializing)
local aspects = character:FindFirstChild("Aspects")
if not aspects then
	-- Aspects should already be part of the cloned model, but retry just in case
	local t = 0
	while not aspects and t < 5 do
		task.wait(0.1)
		t = t + 0.1
		aspects = character:FindFirstChild("Aspects")
	end
end
if not aspects then
	warn("[RageBladeGlow] No Aspects folder found on character")
	return
end

-- Resolve color values
local colors = aspects:FindFirstChild("Colors")
local normalColorVal = colors and colors:FindFirstChild("NormalColor")
local bladeColorVal = normalColorVal and normalColorVal:FindFirstChild("BladeColor")

if not normalColorVal or not bladeColorVal then
	warn("[RageBladeGlow] Missing NormalColor or BladeColor")
	return
end

-- Resolve rage values
local info = aspects:FindFirstChild("Info")
local rageVal = info and info:FindFirstChild("Rage")
local maxRageVal = rageVal and rageVal:FindFirstChild("MaxRage")

if not rageVal then
	warn("[RageBladeGlow] Missing Rage value")
	return
end

local maxRage = (maxRageVal and maxRageVal.Value) or 100

-- Find the knife parts
local lKnife = character:FindFirstChild("LKnife")
local rSword = character:FindFirstChild("RSword")

if not lKnife and not rSword then
	warn("[RageBladeGlow] No LKnife or RSword found on character")
	return
end

-- Store original material so we can revert correctly
local ORIGINAL_MATERIAL = Enum.Material.Metal

local function applyRageState(isRageFull)
	-- During rage ultimate, always force neon blade color regardless of rage value
	if character:GetAttribute("RageActive") then
		isRageFull = true
	end
	local color = isRageFull and bladeColorVal.Value or normalColorVal.Value
	local material = isRageFull and Enum.Material.Neon or ORIGINAL_MATERIAL

	if lKnife then
		lKnife.Color = color
		lKnife.Material = material
	end
	if rSword then
		rSword.Color = color
		rSword.Material = material
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
	local shouldBeFull = newRage >= maxRage or character:GetAttribute("RageActive") == true
	if shouldBeFull ~= rageFull then
		rageFull = shouldBeFull
		applyRageState(rageFull)
	end
end)

-- Listen for RageActive attribute changes (set by attacksystem during rage ultimate)
character:GetAttributeChangedSignal("RageActive"):Connect(function()
	local isRageActive = character:GetAttribute("RageActive") == true
	local shouldBeFull = rageVal.Value >= maxRage or isRageActive
	if shouldBeFull ~= rageFull then
		rageFull = shouldBeFull
		applyRageState(rageFull)
	end
end)

-- Also listen for MaxRage changes in case it adjusts
if maxRageVal then
	maxRageVal.Changed:Connect(function(newMax)
		maxRage = newMax
		local shouldBeFull = rageVal.Value >= maxRage or character:GetAttribute("RageActive") == true
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