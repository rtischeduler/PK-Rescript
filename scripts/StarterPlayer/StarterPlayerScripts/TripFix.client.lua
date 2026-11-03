-- TripFix: Prevents swimming, falling down, and ragdolling for kaiju characters
-- Located in StarterPlayerScripts so it persists across morphs/character changes

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local DISABLED_STATES = {
	[Enum.HumanoidStateType.Swimming] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
	[Enum.HumanoidStateType.Ragdoll] = true,
	[Enum.HumanoidStateType.PlatformStanding] = true,
}

local activeConnections = {}

local function setupCharacter(character)
	-- Clean up old connections from previous character
	for _, conn in ipairs(activeConnections) do
		conn:Disconnect()
	end
	activeConnections = {}

	local function applyFix(humanoid)
		-- Disable unwanted states so the engine never enters them
		for state in pairs(DISABLED_STATES) do
			humanoid:SetStateEnabled(state, false)
		end

		-- Safety net: if any disabled state is somehow entered, force back to running
		-- But DON'T interfere when swimming — SwimSystem needs PlatformStanding
		local stateConn
		stateConn = humanoid.StateChanged:Connect(function(_, newState)
			if DISABLED_STATES[newState] then
				if character:GetAttribute("IsSwimming") then return end
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
		table.insert(activeConnections, stateConn)
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		applyFix(humanoid)
	else
		-- Humanoid might not exist yet, wait for it
		local waitConn
		waitConn = character.ChildAdded:Connect(function(child)
			if child:IsA("Humanoid") then
				waitConn:Disconnect()
				applyFix(child)
			end
		end)
		table.insert(activeConnections, waitConn)
	end
end

-- Watch for character changes (morphs, respawns, etc.)
player.CharacterAdded:Connect(setupCharacter)

-- Handle current character if already loaded
if player.Character then
	task.spawn(setupCharacter, player.Character)
end

-- Fallback poll: catch character changes that CharacterAdded might miss
local lastChar = nil
task.spawn(function()
	while true do
		task.wait(0.5)
		local char = player.Character
		if char and char ~= lastChar then
			lastChar = char
			setupCharacter(char)
		end
	end
end)