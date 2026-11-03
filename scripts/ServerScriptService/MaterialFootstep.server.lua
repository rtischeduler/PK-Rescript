-- MaterialFootstep Script (Upgraded)
-- Plays footstep sounds based on foot contact with the ground (animation-synced)
-- Uses StepPart with Ground/Water particle emitters for visual stepping effects
-- Ground particles enabled when foot hits ground; Water particles when in water
-- Particles disable when the foot lifts

local character = script.Parent
local humanoid = character:FindFirstChildOfClass("Humanoid")
local hrp = character:FindFirstChild("HumanoidRootPart")

if not humanoid or not hrp then
	return
end

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Footstep sound folder reference
local footstepsFolder = Lighting:FindFirstChild("Footsteps")
if not footstepsFolder then
	warn("[Footsteps] Footsteps folder not found in Lighting!")
	return
end

-- Clone all footstep sounds as templates (kept in a folder, not played directly)
-- On each footstep we clone from the template, play the clone, and destroy it when done
local soundTemplates = {}
-- Templates are kept in a Folder for organization, but played sounds MUST be
-- parented directly to hrp (a BasePart) so they are treated as 3D positional sounds.
-- If parented to a Folder, Roblox treats them as 2D/global sounds (full volume everywhere).
local soundFolder = Instance.new("Folder")
soundFolder.Name = "FootstepSounds"
soundFolder.Parent = hrp

for _, sound in footstepsFolder:GetChildren() do
	if sound:IsA("Sound") then
		local template = sound:Clone()
		template.Parent = soundFolder
		soundTemplates[sound.Name] = template
	end
end

-- Find the StepPart template in Lighting.Assets.Effects.WaveEffects
local stepPartTemplate = Lighting:FindFirstChild("Assets")
	and Lighting.Assets:FindFirstChild("Effects")
	and Lighting.Assets.Effects:FindFirstChild("WaveEffects")
	and Lighting.Assets.Effects.WaveEffects:FindFirstChild("StepPart")

if not stepPartTemplate then
	warn("[Footsteps] StepPart template not found in Lighting.Assets.Effects.WaveEffects!")
	return
end

-- Find feet (support multiple naming conventions)
local leftFoot = character:FindFirstChild("lfoot") or character:FindFirstChild("LeftFoot") or character:FindFirstChild("leftfoot") or character:FindFirstChild("Left Foot") or character:FindFirstChild("LFoot")
local rightFoot = character:FindFirstChild("Rightfoot") or character:FindFirstChild("RightFoot") or character:FindFirstChild("rightfoot") or character:FindFirstChild("Right Foot") or character:FindFirstChild("RFoot")

if not leftFoot or not rightFoot then
	warn("[Footsteps] Could not find both feet on character!")
	return
end

-- Create a StepPart clone welded to a foot for particle effects
local function createStepPartForFoot(foot)
	local stepPart = stepPartTemplate:Clone()
	stepPart.Anchored = false
	stepPart.CanCollide = false
	stepPart.CanTouch = false
	stepPart.Transparency = 1
	stepPart.Name = foot.Name .. "_StepPart"
	stepPart.Parent = character

	-- Position at the bottom of the foot
	local footBottomOffset = CFrame.new(0, -foot.Size.Y / 2, 0)
	stepPart.CFrame = foot.CFrame * footBottomOffset

	-- Weld to the foot so it follows foot movement
	local weld = Instance.new("Weld")
	weld.Name = "StepWeld"
	weld.Part0 = foot
	weld.Part1 = stepPart
	weld.C0 = footBottomOffset
	weld.Parent = stepPart

	-- Ensure particle emitters are disabled initially
	local groundEmitter = stepPart:FindFirstChild("Ground")
	local waterEmitter = stepPart:FindFirstChild("Water")

	if groundEmitter then groundEmitter.Enabled = false end
	if waterEmitter then waterEmitter.Enabled = false end

	return stepPart, groundEmitter, waterEmitter
end

local leftStepPart, leftGround, leftWater = createStepPartForFoot(leftFoot)
local rightStepPart, rightGround, rightWater = createStepPartForFoot(rightFoot)

-- Map Roblox Material enums to the sound names in the Footsteps folder
local MATERIAL_TO_SOUND = {
	[Enum.Material.Plastic] = "Plastic",
	[Enum.Material.SmoothPlastic] = "Plastic",
	[Enum.Material.Wood] = "Wood",
	[Enum.Material.WoodPlanks] = "WoodPlanks",
	[Enum.Material.Marble] = "Marble",
	[Enum.Material.Basalt] = "Basalt",
	[Enum.Material.Slate] = "Slate",
	[Enum.Material.CrackedLava] = "CrackedLava",
	[Enum.Material.Concrete] = "Concrete",
	[Enum.Material.Limestone] = "LimeStone",
	[Enum.Material.Granite] = "Granite",
	[Enum.Material.Pavement] = "Pavement",
	[Enum.Material.Brick] = "Brick",
	[Enum.Material.Pebble] = "Pebble",
	[Enum.Material.Cobblestone] = "Cobblestone",
	[Enum.Material.Rock] = "Rock",
	[Enum.Material.Sandstone] = "Sandstone",
	[Enum.Material.CorrodedMetal] = "CorrodedMetal",
	[Enum.Material.DiamondPlate] = "DiamondPlate",
	[Enum.Material.Foil] = "Foil",
	[Enum.Material.Metal] = "Metal",
	[Enum.Material.Grass] = "Grass",
	[Enum.Material.LeafyGrass] = "LeafyGrass",
	[Enum.Material.Sand] = "Sand",
	[Enum.Material.Fabric] = "Fabric",
	[Enum.Material.Snow] = "Snow",
	[Enum.Material.Mud] = "Mud",
	[Enum.Material.Ground] = "Ground",
	[Enum.Material.Asphalt] = "Asphalt",
	[Enum.Material.Salt] = "Sand",
	[Enum.Material.Ice] = "Ice",
	[Enum.Material.Glacier] = "Glacier",
	[Enum.Material.Cardboard] = "Fabric",
	[Enum.Material.Carpet] = "Fabric",
	[Enum.Material.CeramicTiles] = "Slate",
	[Enum.Material.ClayRoofTiles] = "Slate",
	[Enum.Material.RoofShingles] = "Slate",
	[Enum.Material.Leather] = "Fabric",
	[Enum.Material.Plaster] = "Concrete",
	[Enum.Material.Rubber] = "Plastic",
	[Enum.Material.Neon] = "Neon",
	[Enum.Material.Glass] = "Glass",
}

-- Function to get the material and distance under a foot via raycast
local function castFootToGround(foot)
	local rayOrigin = foot.Position
	local rayDirection = Vector3.new(0, -150, 0)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {character}

	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	if result then
		return result.Material, (result.Position - rayOrigin).Magnitude
	end

	return Enum.Material.Plastic, math.huge
end

-- Function to play the footstep sound for a given material
-- Clones the sound from a template so it plays fully without being cut off, then auto-destroys
local function playFootstep(material)
	local soundName = MATERIAL_TO_SOUND[material] or "Plastic"

	local template = soundTemplates[soundName] or soundTemplates["Plastic"]
	if not template then return end

	local soundClone = template:Clone()
	-- CRITICAL: Ensure PlayOnRemove is false so the sound does NOT auto-play
	-- when the character is destroyed (which would blast all sounds at once).
	soundClone.PlayOnRemove = false
	-- Parent directly to hrp (BasePart) so the sound is 3D and distance-attenuated.
	-- Parenting to a Folder would make it a 2D global sound (audible everywhere).
	soundClone.Parent = hrp
	soundClone:Play()

	-- Destroy the clone when it finishes playing
	soundClone.Ended:Connect(function()
		soundClone:Destroy()
	end)

	-- Safety cleanup in case Ended doesn't fire (e.g., sound asset fails to load)
	task.delay(soundClone.TimeLength > 0 and soundClone.TimeLength + 0.5 or 5, function()
		if soundClone and soundClone.Parent then
			soundClone:Destroy()
		end
	end)
end

-- State machine for each foot:
--   "air"    → foot is above ground, waiting for landing
--   "grounded" → foot has hit ground, waiting for lift-off
-- This naturally gives exactly one sound per ground contact. No cooldown timers needed.

local footState = {}

local function setupFoot(foot, groundEmitter, waterEmitter)
	footState[foot] = {
		prevY = nil,
		prevDelta = 0,
		phase = "air",           -- "air" or "grounded"
		groundEmitter = groundEmitter,
		waterEmitter = waterEmitter,
		particleEnableTime = 0,  -- time when particles were enabled (for minimum visible duration)
	}
end

setupFoot(leftFoot, leftGround, leftWater)
setupFoot(rightFoot, rightGround, rightWater)

-- Disable all particles on a foot state
local function disableParticles(state)
	if state.groundEmitter then state.groundEmitter.Enabled = false end
	if state.waterEmitter then state.waterEmitter.Enabled = false end
end

local MIN_PARTICLE_DURATION = 0.4  -- particles stay visible for at least this long after landing
local GROUND_PROXIMITY_MARGIN = 3.0 -- extra studs beyond foot half-height to count as "touching ground"
local DESCEND_THRESHOLD = -0.03     -- how fast (studs/frame) the foot must be falling to register a landing
local LIFT_THRESHOLD = 0.05         -- how fast (studs/frame) the foot must be rising to register a lift

-- Main loop - tracks each foot's Y position to detect contact/lift via state machine
local connection
connection = RunService.Heartbeat:Connect(function()
	-- Clean up if character is dead
	if humanoid.Health <= 0 then
		for _, state in pairs(footState) do
			disableParticles(state)
		end
		connection:Disconnect()
		return
	end

	local isMoving = humanoid.MoveDirection.Magnitude > 0
	local now = tick()

	for foot, state in pairs(footState) do
		-- Skip if foot no longer exists
		if not foot or not foot.Parent then
			continue
		end

		local currentY = foot.Position.Y

		-- When not moving, disable all particles and reset to air state
		if not isMoving then
			if state.phase == "grounded" then
				disableParticles(state)
				state.phase = "air"
			end
			state.prevY = currentY
			state.prevDelta = 0
			continue
		end

		if state.prevY then
			local delta = currentY - state.prevY

			-- LANDING: foot was descending, now flat/ascending, and we're in "air" phase
			if state.phase == "air" and state.prevDelta < DESCEND_THRESHOLD and delta >= -0.01 then
				-- Check if the foot is actually close to the ground
				local material, groundDistance = castFootToGround(foot)
				local footReach = foot.Size.Y / 2 + GROUND_PROXIMITY_MARGIN

				if groundDistance <= footReach then
					state.phase = "grounded"
					state.particleEnableTime = now

					-- Play footstep sound
					playFootstep(material)

					-- Enable appropriate particles based on surface type
					if material == Enum.Material.Water then
						if state.groundEmitter then state.groundEmitter.Enabled = false end
						if state.waterEmitter then state.waterEmitter.Enabled = true end
					else
						if state.waterEmitter then state.waterEmitter.Enabled = false end
						if state.groundEmitter then state.groundEmitter.Enabled = true end
					end
				end
			end

			-- LIFT: foot is clearly rising and we're in "grounded" phase
			if state.phase == "grounded" and delta > LIFT_THRESHOLD and (now - state.particleEnableTime) >= MIN_PARTICLE_DURATION then
				state.phase = "air"
				disableParticles(state)
			end

			state.prevDelta = delta
		end

		state.prevY = currentY
	end
end)

-- Stop all footstep sounds (templates + active clones) to prevent them
-- from blasting at full volume when the character is destroyed
local function stopAllFootstepSounds()
	if hrp and hrp.Parent then
		for _, child in ipairs(hrp:GetChildren()) do
			if child:IsA("Sound") then
				child:Stop()
				child:Destroy()
			end
		end
		local folder = hrp:FindFirstChild("FootstepSounds")
		if folder then
			for _, child in ipairs(folder:GetChildren()) do
				if child:IsA("Sound") then
					child:Stop()
				end
			end
		end
	end
end

-- Clean up on death
humanoid.Died:Connect(function()
	for _, state in pairs(footState) do
		disableParticles(state)
	end
	stopAllFootstepSounds()
	if connection then
		connection:Disconnect()
	end
end)

-- Also stop all sounds when the character is removed from the workspace
-- (e.g. Destroy() called by the spawn script on respawn)
character.AncestryChanged:Connect(function(_, parent)
	if not parent then
		stopAllFootstepSounds()
		if connection then
			connection:Disconnect()
		end
	end
end)

print("[Footsteps] Upgraded footstep system loaded for " .. character.Name)