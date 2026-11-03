
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NeckTurnEvent = ReplicatedStorage:WaitForChild("NeckTurn")

local player = Players.LocalPlayer

-- Configuration
local MAX_PITCH_ANGLE = math.rad(30)  -- Up/down limit
local MAX_YAW_ANGLE = math.rad(40)    -- Left/right limit
local SMOOTH_SPEED = 5                -- Higher = faster response
local NECK_SCALE = 0.35               -- How much necks rotate relative to head (0-1)
local REMOTE_SMOOTH_SPEED = 7         -- Smoothing for remote players

-- Find the turn Motor6D for a neck part (looks for "TurnMotor" child)
local function findNeckTurnMotor(part)
	local motor = part:FindFirstChild("TurnMotor")
	if motor and motor:IsA("Motor6D") then
		return motor
	end
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("Motor6D") and child.Part1 then
			local part1Name = child.Part1.Name:lower()
			if not part1Name:match("jaw") and not part1Name:match("eye")
				and not part1Name:match("lid") and not part1Name:match("dewlap")
				and not part1Name:match("dorsal") and not part1Name:match("attach") then
				return child
			end
		end
	end
	return nil
end

-- Find the Motor6D that controls a given part by searching the entire model
local function findMotorForPart(model, targetPart)
	for _, desc in model:GetDescendants() do
		if desc:IsA("Motor6D") and desc.Part1 == targetPart then
			return desc
		end
	end
	return nil
end

-- Build a motor cache for any kaiju model (reusable for local and remote)
local function buildMotorCache(model)
	local cache = {
		neckMotors = {},
		fakeHeadMotor = nil,
		headPart = nil,
		currentPitch = 0,
		currentYaw = 0,
		targetPitch = 0,
		targetYaw = 0,
		maxPitch = math.rad(45),
		maxYaw = math.rad(50)
	}
	
	-- Neck motors: Neck 1/2/3, n1/n2, or single Neck
	for i = 1, 3 do
		local neck = model:FindFirstChild("Neck " .. i) or model:FindFirstChild("Neck" .. i)
		if neck then
			local motor = findNeckTurnMotor(neck)
			if motor then
				table.insert(cache.neckMotors, { motor = motor, originalC0 = motor.C0, scale = NECK_SCALE ^ i })
			end
		end
	end
	
	if #cache.neckMotors == 0 then
		for i = 1, 2 do
			local neck = model:FindFirstChild("n" .. i)
			if neck then
				local motor = findNeckTurnMotor(neck)
				if motor then
					table.insert(cache.neckMotors, { motor = motor, originalC0 = motor.C0, scale = NECK_SCALE ^ i })
				end
			end
		end
	end
	
	if #cache.neckMotors == 0 then
		local neck = model:FindFirstChild("Neck")
		if neck then
			local motor = findNeckTurnMotor(neck)
			if motor then
				table.insert(cache.neckMotors, { motor = motor, originalC0 = motor.C0, scale = NECK_SCALE })
			end
		end
	end
	
	-- FakeHead motor
	local fakeHead = model:FindFirstChild("FakeHead")
	if fakeHead then
		cache.headPart = fakeHead
		local motor = findMotorForPart(model, fakeHead)
		if motor then
			for i = #cache.neckMotors, 1, -1 do
				if cache.neckMotors[i].motor == motor then
					table.remove(cache.neckMotors, i)
				end
			end
			cache.fakeHeadMotor = { motor = motor, originalC0 = motor.C0, scale = 1 }
		end
	end
	
	if not cache.headPart then
		cache.headPart = model:FindFirstChild("Head") or model.PrimaryPart
	end
	
	return cache
end

-- Find kaiju model in a character
local function findKaijuModelInCharacter(character)
	if not character then return nil end
	if character:FindFirstChild("Neck 1") or character:FindFirstChild("n1") or character:FindFirstChild("FakeHead") then
		return character
	end
	for _, child in character:GetChildren() do
		if child:IsA("Model") then
			if child:FindFirstChild("Neck 1") or child:FindFirstChild("n1") or child:FindFirstChild("FakeHead") then
				return child
			end
		end
	end
	return nil
end

-- Apply rotation to a cache's motors
local function applyRotationToCache(cache)
	local clampedPitch = math.clamp(cache.currentPitch, -cache.maxPitch, cache.maxPitch)
	local clampedYaw = math.clamp(cache.currentYaw, -cache.maxYaw, cache.maxYaw)
	
	for _, neckData in cache.neckMotors do
		local motor = neckData.motor
		if motor and motor.Parent then
			local scale = neckData.scale
			local rotation = CFrame.Angles(-clampedPitch * scale, -clampedYaw * scale, 0)
			motor.C0 = neckData.originalC0 * rotation
		end
	end
	
	if cache.fakeHeadMotor then
		local motor = cache.fakeHeadMotor.motor
		if motor and motor.Parent then
			local rotation = CFrame.Angles(-clampedPitch, -clampedYaw, 0)
			local pos = cache.fakeHeadMotor.originalC0.Position
			motor.C0 = (rotation * (cache.fakeHeadMotor.originalC0 - pos)) + pos
		end
	end
end

-- ===== LOCAL PLAYER =====
local localCache = nil

local function onCharacterAdded()
	task.wait(0.5)
	local model = findKaijuModelInCharacter(player.Character)
	if model then
		localCache = buildMotorCache(model)
	end
end

if player.Character then
	task.spawn(onCharacterAdded)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- ===== REMOTE PLAYERS =====
local remoteCaches = {}  -- [userId] = cache

-- Setup a remote player's cache when their character loads
local function setupRemotePlayer(remotePlayer)
	if remotePlayer.UserId == player.UserId then return end
	task.wait(0.5)
	local model = findKaijuModelInCharacter(remotePlayer.Character)
	if model then
		remoteCaches[remotePlayer.UserId] = buildMotorCache(model)
	end
end

-- Listen for angle updates from server (for other players)
NeckTurnEvent.OnClientEvent:Connect(function(userId, pitch, yaw, maxPitch, maxYaw)
	if userId == player.UserId then return end  -- ignore our own data
	
	local cache = remoteCaches[userId]
	if not cache then
		-- Try to find and cache this player's motors
		local remotePlayer = Players:GetPlayerByUserId(userId)
		if remotePlayer then
			local model = findKaijuModelInCharacter(remotePlayer.Character)
			if model then
				cache = buildMotorCache(model)
				remoteCaches[userId] = cache
			end
		end
	end
	
	if cache then
		cache.targetPitch = pitch or 0
		cache.targetYaw = yaw or 0
		if type(maxPitch) == "number" then cache.maxPitch = maxPitch end
		if type(maxYaw) == "number" then cache.maxYaw = maxYaw end
	end
end)

-- Watch for new players joining
Players.PlayerAdded:Connect(function(remotePlayer)
	remotePlayer.CharacterAdded:Connect(function()
		task.spawn(setupRemotePlayer, remotePlayer)
	end)
	if remotePlayer.Character then
		task.spawn(setupRemotePlayer, remotePlayer)
	end
end)

-- Setup existing players
for _, remotePlayer in Players:GetPlayers() do
	if remotePlayer ~= player then
		remotePlayer.CharacterAdded:Connect(function()
			task.spawn(setupRemotePlayer, remotePlayer)
		end)
		if remotePlayer.Character then
			task.spawn(setupRemotePlayer, remotePlayer)
		end
	end
end

-- ===== MAIN LOOP =====
local connection
connection = RunService.RenderStepped:Connect(function(deltaTime)
	-- === LOCAL PLAYER ===
	if not localCache or not localCache.neckMotors or #localCache.neckMotors == 0 and not localCache.fakeHeadMotor then
		local model = findKaijuModelInCharacter(player.Character)
		if model then
			localCache = buildMotorCache(model)
		end
	else
		-- Verify model still exists
		local model = findKaijuModelInCharacter(player.Character)
		if not model then
			localCache = nil
		end
	end
	
	if localCache then
		-- Check if beam clashing - disable head turning
		local character = player.Character
		if character and character:GetAttribute("IsBeamClashing") then
			-- Reset neck motors to original positions during beam clash
			for _, neckData in localCache.neckMotors do
				if neckData.motor and neckData.motor.Parent then
					neckData.motor.C0 = neckData.originalC0
				end
			end
			if localCache.fakeHeadMotor and localCache.fakeHeadMotor.motor and localCache.fakeHeadMotor.motor.Parent then
				localCache.fakeHeadMotor.motor.C0 = localCache.fakeHeadMotor.originalC0
			end
		else
			local mouse = player:GetMouse()
			local camera = workspace.CurrentCamera
			
			if camera then
				local viewportSize = camera.ViewportSize
				local centerX = viewportSize.X / 2
				local centerY = viewportSize.Y / 2
				
				local dx = math.clamp((mouse.X - centerX) / centerX, -1, 1)
				local dy = math.clamp((mouse.Y - centerY) / centerY, -1, 1)
				
				local yaw = dx * MAX_YAW_ANGLE
				local pitch = dy * MAX_PITCH_ANGLE
				
				-- Send to server for relay to other clients
				NeckTurnEvent:FireServer(pitch, yaw, MAX_PITCH_ANGLE, MAX_YAW_ANGLE)
				
				-- Smooth interpolation
				local alpha = math.min(1, SMOOTH_SPEED * deltaTime)
				localCache.currentPitch = localCache.currentPitch + (pitch - localCache.currentPitch) * alpha
				localCache.currentYaw = localCache.currentYaw + (yaw - localCache.currentYaw) * alpha
				
				applyRotationToCache(localCache)
			end
		end
	end
	
	-- === REMOTE PLAYERS ===
	local remoteAlpha = math.min(1, REMOTE_SMOOTH_SPEED * deltaTime)
	for userId, cache in pairs(remoteCaches) do
		-- Check if player still exists
		local remotePlayer = Players:GetPlayerByUserId(userId)
		if not remotePlayer or not remotePlayer.Parent then
			remoteCaches[userId] = nil
			continue
		end
		
		-- Verify model still exists, re-cache if needed
		if not cache.fakeHeadMotor and #cache.neckMotors == 0 then
			local model = findKaijuModelInCharacter(remotePlayer.Character)
			if model then
				local newCache = buildMotorCache(model)
				newCache.targetPitch = cache.targetPitch
				newCache.targetYaw = cache.targetYaw
				newCache.maxPitch = cache.maxPitch
				newCache.maxYaw = cache.maxYaw
				remoteCaches[userId] = newCache
				cache = newCache
			else
				continue
			end
		end
		
		-- Check if remote player is beam clashing - reset neck to original
		if remotePlayer.Character and remotePlayer.Character:GetAttribute("IsBeamClashing") then
			for _, neckData in cache.neckMotors do
				if neckData.motor and neckData.motor.Parent then
					neckData.motor.C0 = neckData.originalC0
				end
			end
			if cache.fakeHeadMotor and cache.fakeHeadMotor.motor and cache.fakeHeadMotor.motor.Parent then
				cache.fakeHeadMotor.motor.C0 = cache.fakeHeadMotor.originalC0
			end
			continue
		end
		
		-- Smooth interpolation
		cache.currentPitch = cache.currentPitch + (cache.targetPitch - cache.currentPitch) * remoteAlpha
		cache.currentYaw = cache.currentYaw + (cache.targetYaw - cache.currentYaw) * remoteAlpha
		
		applyRotationToCache(cache)
	end
end)

-- Cleanup on script destruction
script.Destroying:Connect(function()
	if connection then
		connection:Disconnect()
	end
end)