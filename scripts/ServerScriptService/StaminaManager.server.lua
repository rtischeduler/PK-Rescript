-- StaminaManager: Server-side stamina drain and regeneration
-- Drains stamina when sprinting or blocking, regenerates when idle
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configuration
local SPRINT_DRAIN_RATE = 7       -- Stamina drained per second while sprinting
local BLOCK_DRAIN_RATE = 12      -- Stamina drained per second while blocking
local REGEN_RATE = 6             -- Stamina regenerated per second when not draining
local REGEN_DELAY = 1.5         -- Seconds after last drain before regen starts
local BASE_WALK_SPEED = 16      -- Base walk speed threshold for sprint detection

local playerData = {}

local function setupCharacter(player, character)
	-- Wait for Aspects to exist
	local aspects = character:WaitForChild("Aspects", 30)
	if not aspects or not character.Parent then return end

	local info = aspects:WaitForChild("Info", 10)
	if not info or not character.Parent then return end

	local stamina = info:WaitForChild("Stamina", 10)
	if not stamina or not character.Parent then return end

	local maxStamina = stamina:WaitForChild("MaxStamina", 10)
	if not maxStamina or not character.Parent then return end

	local defense = aspects:FindFirstChild("Defense")
	if not defense then return end

	local blocking = defense:FindFirstChild("Blocking")

	-- Track this player's stamina state
	playerData[player.UserId] = {
		stamina = stamina,
		maxStamina = maxStamina,
		blocking = blocking,
		character = character,
		lastDrainTime = 0,
	}

	print("[StaminaManager] Setup complete for " .. player.Name)
end

local function cleanupPlayer(player)
	playerData[player.UserId] = nil
end

-- Main update loop
RunService.Heartbeat:Connect(function(dt)
	for userId, data in pairs(playerData) do
		local stamina = data.stamina
		local maxStamina = data.maxStamina
		local character = data.character

		-- Validate character still exists
		if not character or not character.Parent then
			playerData[userId] = nil
			continue
		end

		local currentStamina = stamina.Value
		local maxStam = maxStamina.Value

		-- Check if blocking
		local isBlocking = false
		if data.blocking and data.blocking.Value then
			isBlocking = true
		end

		-- Check if sprinting via horizontal velocity
		-- WalkSpeed is set on the client and does NOT replicate to the server,
		-- so we detect sprinting by checking if the character is moving faster
		-- than the base walk speed threshold.
		-- Swimming is exempt from stamina drain entirely.
		local isSprinting = false
		local isSwimming = (_G.IsPlayerSwimming and _G.IsPlayerSwimming(Players:GetPlayerByUserId(userId)) or false)
			or (character:GetAttribute("IsSwimming") == true)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if humanoid and hrp and not isSwimming then
			local velocity = hrp.AssemblyLinearVelocity
			local horizontalSpeed = math.sqrt(velocity.X ^ 2 + velocity.Z ^ 2)
			if horizontalSpeed > BASE_WALK_SPEED + 1 then
				isSprinting = true
			end
		end

		-- Drain or regenerate stamina
		if isBlocking then
			-- Block drains stamina
			local drain = BLOCK_DRAIN_RATE * dt
			stamina.Value = math.max(0, currentStamina - drain)
			data.lastDrainTime = tick()
		elseif isSprinting then
			-- Sprint drains stamina
			local drain = SPRINT_DRAIN_RATE * dt
			stamina.Value = math.max(0, currentStamina - drain)
			data.lastDrainTime = tick()
		else
			-- Regenerate after delay
			if tick() - data.lastDrainTime >= REGEN_DELAY then
				local regen = REGEN_RATE * dt
				stamina.Value = math.min(maxStam, currentStamina + regen)
			end
		end

		-- If stamina hits 0 while sprinting, force stop sprint on server
		-- by setting WalkSpeed to base (server-authoritative)
		if stamina.Value <= 0 and isSprinting then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = BASE_WALK_SPEED
			end
		end
	end
end)

-- Handle players joining
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(setupCharacter, player, character)
	end)

	-- If character already exists
	if player.Character then
		task.spawn(setupCharacter, player, player.Character)
	end

	player.CharacterRemoving:Connect(function()
		cleanupPlayer(player)
	end)
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(cleanupPlayer)

-- Setup for any players already in the game
for _, player in Players:GetPlayers() do
	player.CharacterAdded:Connect(function(character)
		task.spawn(setupCharacter, player, character)
	end)
	if player.Character then
		task.spawn(setupCharacter, player, player.Character)
	end
	player.CharacterRemoving:Connect(function()
		cleanupPlayer(player)
	end)
end

print("[StaminaManager] Loaded")