local Players = game:GetService("Players")
local Server = script.Parent

-- Track combo state for each player
local playerCombos = {}

-- Attack cooldown and combo timing
local LMB_COOLDOWN = 1.3 -- seconds between each LMB attack
local COMBO_TIMEOUT = 4.0 -- seconds before combo resets

-- Function to get the current combo state for a player
local function getComboState(player)
	if not playerCombos[player.UserId] then
		playerCombos[player.UserId] = {
			currentCombo = 0,
			lastClickTime = 0,
			isAttacking = false,
			attackTrack = nil
		}
	end
	return playerCombos[player.UserId]
end

-- Function to move player forward smoothly
local function movePlayerForward(character, distance, duration)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local startCFrame = hrp.CFrame
	local forwardDirection = startCFrame.LookVector
	local endPosition = startCFrame.Position + (forwardDirection * distance)
	
	local startTime = tick()
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local progress = math.min(elapsed / duration, 1)
		
		-- Smooth easing
		local easedProgress = progress * progress * (3 - 2 * progress)
		
		if hrp and hrp.Parent then
			local newPosition = startCFrame.Position:Lerp(endPosition, easedProgress)
			hrp.CFrame = CFrame.new(newPosition, newPosition + forwardDirection)
		end
		
		if progress >= 1 then
			connection:Disconnect()
		end
	end)
end

-- Function to play attack animation and effects
local function playAttack(player, comboNumber)
	local character = player.Character
	if not character then return end

	local comboState = getComboState(player)

	-- Find Animations folder in character
	local animationsFolder = character:FindFirstChild("Animations")
	if not animationsFolder then
		-- Try to find it in HumanoidRootPart
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			animationsFolder = hrp:FindFirstChild("Animations")
		end
	end

	-- Find the animation for this combo number
	local animName = "LMB" .. comboNumber
	local animation = animationsFolder and animationsFolder:FindFirstChild(animName)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	
	if animation and animator then
		local animTrack = animator:LoadAnimation(animation)
		animTrack.Priority = Enum.AnimationPriority.Action
		animTrack:Play()

		-- Track attack state so we can block new attacks during animation
		comboState.attackTrack = animTrack
		comboState.isAttacking = true

		animTrack.Ended:Connect(function()
			comboState.isAttacking = false
			comboState.attackTrack = nil
		end)

		-- Move player forward during attack
		movePlayerForward(character, 8, 0.5)
	end
	
	-- Play attack sound from Head
	local head = character:FindFirstChild("Head")
	if head then
		local attackSound = head:FindFirstChild("AttackSound")
		if attackSound and attackSound:IsA("Sound") then
			attackSound:Play()
		end
	end
	
	print("[LMB] Player " .. player.Name .. " attacked with combo " .. comboNumber)
end

-- Handle LMB event from client
Server.LMB.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	local comboState = getComboState(player)
	local currentTime = tick()

	-- Enforce cooldown between attacks
	if (currentTime - comboState.lastClickTime) < LMB_COOLDOWN then
		return
	end

	-- Check if enough time has passed since last click
	local timeSinceLastClick = currentTime - comboState.lastClickTime

	-- If within combo timeout, advance combo, otherwise reset
	if timeSinceLastClick <= COMBO_TIMEOUT and comboState.currentCombo > 0 then
		comboState.currentCombo = comboState.currentCombo + 1
		if comboState.currentCombo > 3 then
			comboState.currentCombo = 1 -- Reset to first combo if past 3
		end
	else
		comboState.currentCombo = 1 -- Start new combo
	end

	comboState.lastClickTime = currentTime

	-- Play the attack for current combo
	playAttack(player, comboState.currentCombo)
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
	playerCombos[player.UserId] = nil
end)

print("[LMB] Attack system loaded!")