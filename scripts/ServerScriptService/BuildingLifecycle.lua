--[[
	BuildingLifecycle Module
	Manages the death/sink/revive cycle for a single building.
	Required by per-building runner scripts cloned by BuildingSystemInstaller.

	Updated: Progressive visual damage system:
		- 75% health: parts become Slate material, slightly darker (90% brightness per part)
		- 50% health: parts become Slate material, moderately darker (80% brightness per part)
		- 25% health: fire particle emitters activate
		-  0% health: collapse + smoke
	Uses the Rubble mesh and ParticleEmitters already built into each
	building model instead of creating new parts/effects at runtime.
]]

local BuildingHealth = require(game.ReplicatedStorage:FindFirstChild("BuildingHealth"))

local SINK_SPEED = 50
local RISE_SPEED = 50
local SINK_DISTANCE = 300
local REVIVE_DELAY = 120

local BuildingLifecycle = {}

-- Collect every ParticleEmitter descendant of an instance (for enable/disable)
local function collectParticles(root)
	local emitters = {}
	for _, desc in root:GetDescendants() do
		if desc:IsA("ParticleEmitter") then
			table.insert(emitters, desc)
		end
	end
	return emitters
end
-- Find all parts named "Rubble" that are direct children of the building
local function findRubbleParts(building)
	local parts = {}
	for _, child in building:GetChildren() do
		if child.Name == "Rubble" and child:IsA("BasePart") then
			table.insert(parts, child)
		end
	end
	return parts
end

-- Get all visible (non-transparent, non-Rubble) BaseParts in a building
local function getVisibleParts(building)
	local parts = {}
	for _, desc in building:GetDescendants() do
		if desc:IsA("BasePart") and desc.Name ~= "Rubble" and desc.Transparency < 1 then
			table.insert(parts, desc)
		end
	end
	return parts
end

-- Get the building's base color from its first visible part
-- (Aspects.Colors.BaseColor is always 0,0,0 in these buildings so we use actual part color)
local function getBaseColor(building)
	local parts = getVisibleParts(building)
	if #parts > 0 then
		return parts[1].Color
	end
	return Color3.fromRGB(100, 100, 100)
end

-- Enable or disable all Fire particle emitters on the building's HumanoidRootPart
local function setFireEnabled(building, enabled)
	local hrp = building:FindFirstChild("HumanoidRootPart")
	if hrp then
		for _, child in hrp:GetChildren() do
			if child.Name == "Fire" and child:IsA("ParticleEmitter") then
				child.Enabled = enabled
			end
		end
	end
end

-- Enable or disable all Smoke particle emitters on the building's HumanoidRootPart
local function setSmokeEnabled(building, enabled)
	local hrp = building:FindFirstChild("HumanoidRootPart")
	if hrp then
		for _, child in hrp:GetChildren() do
			if (child.Name == "Smoke" or child.Name == "LastSmoke") and child:IsA("ParticleEmitter") then
				child.Enabled = enabled
			end
		end
	end
end

-- Raycast downward from a position to find the ground level Y coordinate
local function findGroundY(x, y, z, exclude)
	local rayOrigin = Vector3.new(x, y, z)
	local rayDir = Vector3.new(0, -500, 0)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = exclude or {}

	local result = workspace:Raycast(rayOrigin, rayDir, params)
	if result then
		return result.Position.Y
	end
	return nil -- ray missed; caller should fall back
end

function BuildingLifecycle.setup(building)
	-- Get NumberValue health (primary health system for buildings)
	local aspects = building:FindFirstChild("Aspects")
	local info = aspects and aspects:FindFirstChild("Info")
	local healthValue = info and info:FindFirstChild("Health")
	if not healthValue then return end

	local maxHealthValue = healthValue:FindFirstChild("MaxHealth")

	-- Keep Humanoid for character detection but don't use it for health management
	local humanoid = building:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.BreakJointsOnDeath = false
	end

	local isProcessing = false
	local originalPosition = nil -- Persistent original position across death/revive cycles

	-- === PROGRESSIVE DAMAGE VISUAL SYSTEM ===
	-- damageStage: 0=normal, 1=slate-light (75% HP), 2=slate-dark (50% HP), 3=fire (25% HP)
	local damageStage = 0
	local originalData = {} -- { [part] = {material=Enum.Material, color=Color3} }

	-- Store original material and color for each visible part
	for _, part in getVisibleParts(building) do
		originalData[part] = { material = part.Material, color = part.Color }
	end

	-- Store original CanCollide for all parts so we can restore properly on revive
	local originalCanCollide = {}
	for _, desc in building:GetDescendants() do
		if desc:IsA("BasePart") then
			originalCanCollide[desc] = desc.CanCollide
		end
	end

	-- Apply or restore visual damage at a given stage
	local function applyDamageVisuals(stage)
		local parts = getVisibleParts(building)

		if stage <= 0 then
			-- Restore original materials and colors
			for _, part in parts do
				local data = originalData[part]
				if data then
					part.Material = data.material
					part.Color = data.color
				end
			end
			setFireEnabled(building, false)
		elseif stage == 1 then
			-- 75% health: Slate, slightly darker from each part's own color
			for _, part in parts do
				local data = originalData[part]
				if data then
					part.Material = Enum.Material.Slate
					part.Color = Color3.new(
						data.color.R * 0.9,
						data.color.G * 0.9,
						data.color.B * 0.9
					)
				end
			end
		elseif stage == 2 then
			-- 50% health: Slate, moderately darker from each part's own color
			for _, part in parts do
				local data = originalData[part]
				if data then
					part.Material = Enum.Material.Slate
					part.Color = Color3.new(
						data.color.R * 0.8,
						data.color.G * 0.8,
						data.color.B * 0.8
					)
				end
			end
		end
	end

	-- Forward declaration for death handler (referenced by onHealthChanged)
	local onBuildingDied

	-- Health threshold handler — fires whenever the NumberValue health changes
	local function onHealthChanged(health)
		if isProcessing then return end

		local maxHealth = maxHealthValue and maxHealthValue.Value or 100
		if maxHealth <= 0 then return end
		local ratio = health / maxHealth

		if ratio <= 0.25 and damageStage < 3 then
			damageStage = 3
			-- Enable fire particle emitters
			setFireEnabled(building, true)
		elseif ratio <= 0.50 and damageStage < 2 then
			damageStage = 2
			applyDamageVisuals(2)
		elseif ratio <= 0.75 and damageStage < 1 then
			damageStage = 1
			applyDamageVisuals(1)
		end

		-- Death detection via NumberValue health
		if health <= 0 then
			onBuildingDied()
		end
	end

	healthValue.Changed:Connect(onHealthChanged)

	-- Check current health in case the building starts below a threshold
	onHealthChanged(healthValue.Value)

	onBuildingDied = function()
		if isProcessing then return end
		isProcessing = true

		-- Set invulnerability to prevent damage during death/respawn cycle
		BuildingHealth.setInvulnerable(building, true)

		if not originalPosition then
			originalPosition = building:GetPivot()
		end
		local originalPivot = originalPosition
		local targetY = originalPivot.Position.Y - SINK_DISTANCE
		local _, bSize = building:GetBoundingBox()
		local pivot = building:GetPivot()

		-- === RUMBLE PHASE: shake the building and play rumble sound before collapse ===
		do
			local rumbleHrp = building:FindFirstChild("HumanoidRootPart")
			if rumbleHrp then
				local rumbleSound = rumbleHrp:FindFirstChild("Rumble")
				if rumbleSound and rumbleSound:IsA("Sound") then
					rumbleSound:Play()
				end
			end

			local rumbleDuration = 1.0
			local rumbleElapsed = 0
			local rumbleStep = 0.03
			local shakeBase = 0.3
			-- Shake intensifies over time, peaks right before collapse
			while rumbleElapsed < rumbleDuration and building and building.Parent do
				local progress = rumbleElapsed / rumbleDuration
				local intensity = shakeBase + progress * 1.5 -- grows from 0.3 to 1.8
				local jitter = CFrame.new(
					(math.random() - 0.5) * intensity,
					(math.random() - 0.5) * intensity * 0.5,
					(math.random() - 0.5) * intensity
				) * CFrame.Angles(
					(math.random() - 0.5) * 0.02 * progress,
					(math.random() - 0.5) * 0.02 * progress,
					(math.random() - 0.5) * 0.02 * progress
				)
				building:PivotTo(originalPivot * jitter)
				rumbleElapsed = rumbleElapsed + rumbleStep
				task.wait(rumbleStep)
			end
			-- Snap back to original position before collapse
			building:PivotTo(originalPivot)
		end

		-- === COLLAPSE: play explosion sound ===
		do
			local collapseHrp = building:FindFirstChild("HumanoidRootPart")
			if collapseHrp then
				local explodeSound = collapseHrp:FindFirstChild("Explode")
				if explodeSound and explodeSound:IsA("Sound") then
					explodeSound:Play()
				end
			end
		end

		-- === DISABLE COLLISION on all building parts (collapsed state) ===
		for _, desc in building:GetDescendants() do
			if desc:IsA("BasePart") then
				desc.CanCollide = false
			end
		end

		-- === Use existing Rubble parts from the building model ===
		local rubbleParts = findRubbleParts(building)
		local usingExistingRubble = #rubbleParts > 0

		-- Collect particle emitters BEFORE reparenting rubble so we capture all of them
		local allParticles = collectParticles(building)

		-- Track fire emitters we clone onto rubble (so we can clean them up on revive)
		local rubbleFireEmitters = {}

		-- Find ground level via raycast (exclude the building itself)
		local buildingY = pivot.Position.Y
		local groundY = findGroundY(pivot.Position.X, buildingY, pivot.Position.Z, {building})
		-- Fallback: bottom of the building's bounding box
		if not groundY then
			groundY = pivot.Position.Y - bSize.Y / 2
		end

		if usingExistingRubble then
			-- Reparent rubble parts to workspace so they don't sink with the building
			-- Position them at ground level, make visible and collidable
			for _, rubble in rubbleParts do
				local rubbleSize = rubble.Size
				local rubbleY = groundY + rubbleSize.Y / 2
				rubble.CFrame = CFrame.new(pivot.Position.X, rubbleY, pivot.Position.Z)
				rubble.Transparency = 0
				rubble.CanCollide = false
				rubble.Anchored = true
				rubble.Parent = workspace
			end
		else
			-- Fallback: create a simple rubble part (for buildings without pre-made rubble)
			local rubble = Instance.new("Part")
			rubble.Name = "BuildingRubble"
			rubble.Size = Vector3.new(
				math.max(bSize.X * 0.8, 12),
				math.max(bSize.Y * 0.1, 3),
				math.max(bSize.Z * 0.8, 12)
			)
			rubble.Material = Enum.Material.Slate
			rubble.Color = Color3.fromRGB(80, 80, 90)
			rubble.Anchored = true
			rubble.CanCollide = false
			rubble.CFrame = CFrame.new(pivot.Position.X, groundY + rubble.Size.Y / 2, pivot.Position.Z)
			rubble.Parent = workspace
			table.insert(rubbleParts, rubble)
		end

		-- === Enable all existing particle emitters (fire + smoke) in the building ===
		for _, emitter in allParticles do
			emitter.Enabled = true
		end

		-- === Clone Fire emitters from HRP onto rubble parts (fire on the rubble!) ===
		if usingExistingRubble then
			local hrp = building:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, rubble in rubbleParts do
					for _, child in hrp:GetChildren() do
						if child.Name == "Fire" and child:IsA("ParticleEmitter") then
							local fireClone = child:Clone()
							fireClone.Enabled = true
							fireClone.Parent = rubble
							table.insert(rubbleFireEmitters, fireClone)
						end
					end
				end
			end
		end

		-- === SINKING PHASE ===
		while building and building.Parent do
			local current = building:GetPivot()
			if current.Position.Y <= targetY then break end
			local newY = math.max(targetY, current.Position.Y - SINK_SPEED * 0.1)
			building:PivotTo(CFrame.new(current.Position.X, newY, current.Position.Z) * current.Rotation)
			task.wait(0.1)
		end

		-- === WAIT PHASE ===
		local sinkDuration = SINK_DISTANCE / SINK_SPEED
		task.wait(math.max(0, REVIVE_DELAY - sinkDuration))

		-- Check building still exists
		if not building or not building.Parent then
			for _, rubble in rubbleParts do
				if rubble and rubble.Parent then rubble.Parent = nil end
			end
			isProcessing = false
			return
		end

		-- === REVIVE: Reset NumberValue health ===
		BuildingHealth.resetHealth(building)

		-- === RESET PROGRESSIVE DAMAGE VISUALS ===
		damageStage = 0
		applyDamageVisuals(0) -- Restore original materials and colors
		setFireEnabled(building, false)
		setSmokeEnabled(building, false)

		-- Disable all particle emitters
		for _, emitter in allParticles do
			if emitter and emitter.Parent then
				emitter.Enabled = false
			end
		end

		-- Remove cloned fire emitters from rubble
		for _, fireEmitter in rubbleFireEmitters do
			if fireEmitter and fireEmitter.Parent then
				fireEmitter.Parent = nil
			end
		end

		-- Hide and reset rubble parts
		for _, rubble in rubbleParts do
			if rubble and rubble.Parent then
				rubble.Transparency = 1
				rubble.CanCollide = false

				if usingExistingRubble then
					-- Reparent back to the building and restore original position
					rubble.Parent = building
				else
					-- Created rubble: remove it
				rubble.Parent = nil
				end
			end
		end

		-- === RE-ENABLE COLLISION AND TOUCH on all building parts BEFORE rising ===
		-- This ensures players can attack and interact with the building
		-- as soon as it starts coming back up, not just after it finishes.
		for _, desc in building:GetDescendants() do
			if desc:IsA("BasePart") then
				-- Restore original CanCollide instead of blindly setting true
				-- HumanoidRootPart, Rubble, and "Under" parts should stay false
				desc.CanCollide = originalCanCollide[desc] == true
				desc.CanTouch = true
			end
		end

		-- Clear invulnerability and allow the building to be damaged/killed again.
		BuildingHealth.setInvulnerable(building, false)
		-- originalPosition is stored persistently so the building will always
		-- rise back to the correct position even if killed during rising.
		isProcessing = false

		task.wait(0.5)

		-- === RISING PHASE ===
		while building and building.Parent do
			local current = building:GetPivot()
			if current.Position.Y >= originalPivot.Position.Y then
				building:PivotTo(originalPivot)
				break
			end
			local newY = math.min(originalPivot.Position.Y, current.Position.Y + RISE_SPEED * 0.1)
			building:PivotTo(CFrame.new(current.Position.X, newY, current.Position.Z) * current.Rotation)
			task.wait(0.1)
		end
	end
end

return BuildingLifecycle