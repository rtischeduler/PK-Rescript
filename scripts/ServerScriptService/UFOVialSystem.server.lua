-- UFO Vial Drop System
-- UFO flies in from outside the map, stops above ground (not water), drops a vial, then flies away.
-- Vials have all effects enabled when dropped and stand upright on landing.
-- Health vials: restore 100-200 HP on touch, then destroy.
-- GCell vials: grant 60-85 GCells on touch, then destroy.
-- Rage vials: fill rage to max on touch, then destroy.
-- Stamina vials: restore stamina to full on touch, then destroy.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Navigate to the UFOS folder
local function findUFOSFolder()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	if not assets then return nil end
	local kaijus = assets:FindFirstChild("Kaijus")
	if not kaijus then return nil end
	local items = kaijus:FindFirstChild("Items")
	if not items then return nil end
	return items:FindFirstChild("UFOS")
end

local UFOS_PATH = findUFOSFolder()
if not UFOS_PATH then
	warn("[UFO System] Could not find ReplicatedStorage.Assets.Kaijus.Items.UFOS")
	return
end

local UFO_TEMPLATE = UFOS_PATH:FindFirstChild("UFO")
local VIAL_NAMES = { "Stamina", "Health", "Rage", "GCells" }

-- Vial collection configuration
local VIAL_CONFIG = {
	Health = {
		minAmount = 100,
		maxAmount = 200,
	},
	GCells = {
		minAmount = 60,
		maxAmount = 85,
	},
	Stamina = {
		fullRestore = true,
	},
	Rage = {
		fullRestore = true,
	},
}

-- Set up touch collection for a landed vial
local function setupVialCollection(vial, vialName)
	local config = VIAL_CONFIG[vialName]
	if not config then return end -- No collection behavior for this vial type

	local debounce = false

	local function onTouch(otherPart)
		if debounce then return end

		-- Find the player character that touched the vial
		local character = otherPart.Parent
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		-- Get the player from the character
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		debounce = true

		if vialName == "Health" then
			-- Add 100-200 health to the character's humanoid
			local healAmount = math.random(config.minAmount, config.maxAmount)
			humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)
			print("[UFOVialSystem] " .. player.Name .. " collected Health vial: +" .. healAmount .. " HP")
		elseif vialName == "Stamina" then
			-- Restore stamina to full (100)
			local aspects = character:FindFirstChild("Aspects")
			if aspects then
				local info = aspects:FindFirstChild("Info")
				if info then
					local stamina = info:FindFirstChild("Stamina")
					if stamina then
						local maxStamina = stamina:FindFirstChild("MaxStamina")
						if maxStamina then
							stamina.Value = maxStamina.Value
							print("[UFOVialSystem] " .. player.Name .. " collected Stamina vial: full restore")
						end
					end
				end
			end
		elseif vialName == "Rage" then
			-- Fill rage to max
			local aspects = character:FindFirstChild("Aspects")
			if aspects then
				local info = aspects:FindFirstChild("Info")
				if info then
					local rage = info:FindFirstChild("Rage")
					if rage then
						local maxRage = rage:FindFirstChild("MaxRage")
						if maxRage then
							rage.Value = maxRage.Value
							print("[UFOVialSystem] " .. player.Name .. " collected Rage vial: rage filled to max (" .. maxRage.Value .. ")")
						end
					end
				end
			end
		elseif vialName == "GCells" then
			-- Add 60-85 GCells to the player's inventory
			local gcellAmount = math.random(config.minAmount, config.maxAmount)
			local inventory = player:FindFirstChild("Inventory")
			if inventory then
				local gcells = inventory:FindFirstChild("GCells")
				if gcells and gcells:IsA("IntValue") then
					gcells.Value = gcells.Value + gcellAmount
					print("[UFOVialSystem] " .. player.Name .. " collected GCell vial: +" .. gcellAmount .. " GCells")
				end
			end
		end

		-- Destroy the vial after collection
		vial:Destroy()
	end

	-- Connect Touched to all BaseParts in the vial model
	for _, desc in vial:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Touched:Connect(onTouch)
		end
	end
end

-- Configuration
local SPAWN_INTERVAL = 60     -- Seconds between UFO spawns (every minute)
local UFO_HEIGHT = 65    -- How high above the ground the UFO stops (not too far up)
local UFO_SPEED = 120        -- UFO zoom speed in studs/second (fast)
local VIAL_HANG_DISTANCE = 7 -- How far below the UFO holds the vial
local MAX_ATTEMPTS = 30      -- Max attempts to find a non-water position

-- Map bounds (based on map center ~112, 300, -95 with size ~2936 x 3877)
local MAP_MIN_X = -1200
local MAP_MAX_X = 1400
local MAP_MIN_Z = -1900
local MAP_MAX_Z = 1800
local MAP_CENTER = Vector3.new(112, 300, -95)

-- Easing function (ease-out for fast zoom-in that slows as it arrives)
local function easeOutCubic(t)
	return 1 - (1 - t) ^ 3
end

-- Pick a random vial name from the available templates
local function getRandomVialName()
	local available = {}
	for _, name in ipairs(VIAL_NAMES) do
		if UFOS_PATH:FindFirstChild(name) then
			table.insert(available, name)
		end
	end
	if #available == 0 then return nil end
	return available[math.random(#available)]
end

-- Enable all ParticleEmitters in a model
local function enableAllEffects(model)
	for _, desc in model:GetDescendants() do
		if desc:IsA("ParticleEmitter") then
			desc.Enabled = true
		end
	end
end

-- Disable LinearVelocity and AngularVelocity constraints so the vial falls naturally
local function disableMovers(model)
	for _, desc in model:GetDescendants() do
		if desc:IsA("LinearVelocity") or desc:IsA("AngularVelocity") then
			desc.Enabled = false
		end
	end
end

-- Set the Anchored state of all BaseParts in a model
local function setAnchored(model, anchored)
	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = anchored
		end
	end
end

-- Find a valid ground position that is NOT water by raycasting downward
local function findGroundPosition()
	for _ = 1, MAX_ATTEMPTS do
		local x = math.random(MAP_MIN_X, MAP_MAX_X)
		local z = math.random(MAP_MIN_Z, MAP_MAX_Z)
		local rayOrigin = Vector3.new(x, 1000, z)
		local rayDir = Vector3.new(0, -2000, 0)

		local params = RaycastParams.new()
		params.IgnoreWater = false -- We WANT to detect water so we can skip it

		local result = Workspace:Raycast(rayOrigin, rayDir, params)
		if result and result.Material ~= Enum.Material.Water then
			return result.Position
		end
	end
	-- Fallback: use map center ground level
	return MAP_CENTER
end

-- Main spawn function
local function spawnUFO()
	if not UFO_TEMPLATE then return end

	-- Find a valid drop position above ground (not water)
	local groundPos = findGroundPosition()
	local targetPos = groundPos + Vector3.new(0, UFO_HEIGHT, 0)

	-- Clone the UFO
	local ufo = UFO_TEMPLATE:Clone()
	local ufoMain = ufo:FindFirstChild("Main")
	if not ufoMain then
		ufo:Destroy()
		return
	end
	ufoMain.Anchored = true
	ufoMain.CanCollide = false

	-- Pick a random vial
	local vialName = getRandomVialName()
	if not vialName then
		ufo:Destroy()
		return
	end
	local vial = UFOS_PATH:FindFirstChild(vialName):Clone()
	local vialHRP = vial:FindFirstChild("HumanoidRootPart")
	if not vialHRP then
		ufo:Destroy()
		vial:Destroy()
		return
	end

	-- Disable movers so they don't interfere with falling
	disableMovers(vial)

	-- Anchor all vial parts while being carried
	setAnchored(vial, true)

	-- Enable all particle effects on the vial
	enableAllEffects(vial)

	-- Set up the vial's Humanoid (so it tries to stay upright when dropped)
	local humanoid = vial:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = false
		humanoid.WalkSpeed = 0
	end

	-- Start position: outside the map, coming from a random direction
	local angle = math.random() * math.pi * 2
	local startOffset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 800
	local startPos = targetPos + startOffset
	startPos = Vector3.new(startPos.X, targetPos.Y, startPos.Z)

	-- Vial offset relative to UFO (beneath it, upright with 90-degree Y rotation matching original)
	local vialOffset = CFrame.new(0, -VIAL_HANG_DISTANCE, 0) * CFrame.Angles(0, math.rad(90), 0)

	-- Position the UFO at the start and the vial beneath it
	ufo:PivotTo(CFrame.new(startPos))
	ufo.Parent = Workspace

	vial:PivotTo(CFrame.new(startPos) * vialOffset)
	vial.Parent = Workspace

	-- Play UFO looping sound
	local ufoSound = ufoMain:FindFirstChild("Sound")
	if ufoSound and ufoSound:IsA("Sound") then
		ufoSound.Looped = true
		ufoSound:Play()
	end

	-- Zoom the UFO (and vial beneath it) to the target position
	local distance = (targetPos - startPos).Magnitude
	local travelTime = math.max(distance / UFO_SPEED, 0.5)
	local startTime = os.clock()

	while os.clock() - startTime < travelTime do
		local alpha = (os.clock() - startTime) / travelTime
		local easedAlpha = easeOutCubic(alpha)
		local currentPos = startPos:Lerp(targetPos, easedAlpha)

		ufo:PivotTo(CFrame.new(currentPos))
		vial:PivotTo(CFrame.new(currentPos) * vialOffset)

		task.wait()
	end

	-- Snap to final position
	ufo:PivotTo(CFrame.new(targetPos))
	vial:PivotTo(CFrame.new(targetPos) * vialOffset)

	-- Stop for a second before dropping
	task.wait(1)

	-- Play drop sound
	local dropSound = ufoMain:FindFirstChild("Drop")
	if dropSound and dropSound:IsA("Sound") then
		dropSound:Play()
	end

	-- Drop the vial: unanchor all parts so it falls
	setAnchored(vial, false)

	-- Make sure the vial is upright when released
	vialHRP.CFrame = CFrame.new(vialHRP.Position) * CFrame.Angles(0, math.rad(90), 0)

	-- Play vial sound
	local vialSound = vialHRP:FindFirstChild("Sound")
	if vialSound and vialSound:IsA("Sound") then
		vialSound:Play()
	end

	-- Wait for the vial to land, then stand it up and anchor it
	task.spawn(function()
		local stableTime = 0
		local maxWait = 15
		local waitStart = os.clock()

		while os.clock() - waitStart < maxWait do
			task.wait(0.1)
			if not vialHRP or not vialHRP.Parent then return end

			local velocity = vialHRP.AssemblyLinearVelocity
			if velocity.Magnitude < 2 then
				stableTime += 0.1
				if stableTime >= 0.4 then
					break
				end
			else
				stableTime = 0
			end
		end

		-- Stand up the vial and anchor it in place
		if vialHRP and vialHRP.Parent then
			local pos = vialHRP.Position
			vialHRP.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(90), 0)
			setAnchored(vial, true)
			enableAllEffects(vial)

			-- Set up touch collection for all vial types
			setupVialCollection(vial, vialName)
		end
	end)

	-- Fly the UFO away immediately after dropping the vial
	local flyAwayPos = startPos + (startPos - targetPos).Unit * 200
	local flyAwayDist = (flyAwayPos - targetPos).Magnitude
	local flyAwayTime = flyAwayDist / UFO_SPEED
	local flyStart = os.clock()

	while os.clock() - flyStart < flyAwayTime do
		local alpha = (os.clock() - flyStart) / flyAwayTime
		local easedAlpha = easeOutCubic(alpha)
		local currentPos = targetPos:Lerp(flyAwayPos, easedAlpha)
		ufo:PivotTo(CFrame.new(currentPos))
		task.wait()
	end

	-- Clean up the UFO, leaving the vial behind
	if ufoSound then ufoSound:Stop() end
	ufo:Destroy()
end

-- Main loop: spawn a UFO every minute
while true do
	spawnUFO()
	task.wait(SPAWN_INTERVAL)
end