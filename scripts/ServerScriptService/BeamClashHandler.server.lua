--[[
    BeamClashHandler (Server)
    Full beam clash flow:
    1. Detect BeamHitbox touch → start clash
    2. 3-second countdown
    3. 5-second spam window (players mash to win)
    4. Winner determined by click count
    5. Loser knocked back + 150 HP damage
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BeamClashModule = require(ReplicatedStorage:FindFirstChild("BeamClashModule"))
local BeamClashRemote = ReplicatedStorage:FindFirstChild("BeamClashRemote")

local playerConnections = {}
local clickCounts = {}  -- { [Player] = number }

-- Traverse up from a part to find the player that owns it
local function getPlayerFromPart(part)
	local current = part
	while current do
		local player = Players:GetPlayerFromCharacter(current)
		if player then return player, current end
		current = current.Parent
	end
	return nil, nil
end

-- Apply knockback to the loser
local function applyKnockback(loser, winner)
	local loserChar = loser.Character
	local winnerChar = winner.Character
	if not loserChar or not winnerChar then return end
	
	local loserHrp = loserChar:FindFirstChild("HumanoidRootPart")
	local winnerHrp = winnerChar:FindFirstChild("HumanoidRootPart")
	if not loserHrp or not winnerHrp then return end
	
	-- Direction: away from winner
	local direction = (loserHrp.Position - winnerHrp.Position).Unit
	loserHrp.AssemblyLinearVelocity = direction * BeamClashModule.KNOCKBACK_FORCE + Vector3.new(0, 80, 0)
	
	-- Damage
	local humanoid = loserChar:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid:TakeDamage(BeamClashModule.LOSER_DAMAGE)
	end
end

-- Run the full clash sequence for a pair
local function runClashSequence(player1, player2)
	-- Phase 1: Countdown (3 seconds)
	for i = BeamClashModule.COUNTDOWN_DURATION, 1, -1 do
		BeamClashRemote:FireClient(player1, "ClashCountdown", i)
		BeamClashRemote:FireClient(player2, "ClashCountdown", i)
		task.wait(1)
	end
	
	-- Check if both still valid before spam phase
	local char1 = player1.Character
	local char2 = player2.Character
	if not char1 or not char2 then
		endClash(player1)
		return
	end
	
	-- Phase 2: Spam window (5 seconds)
	clickCounts[player1] = 0
	clickCounts[player2] = 0
	
	BeamClashRemote:FireClient(player1, "ClashSpamStart")
	BeamClashRemote:FireClient(player2, "ClashSpamStart")
	
	local spamStart = tick()
	while tick() - spamStart < BeamClashModule.SPAM_WINDOW_DURATION do
		task.wait(0.1)
		-- Keep players facing each other during spam
		BeamClashModule.UpdateLookAt(player1, player2)
	end
	
	-- Phase 3: Determine winner
	local clicks1 = clickCounts[player1] or 0
	local clicks2 = clickCounts[player2] or 0
	
	local winner, loser
	if clicks1 > clicks2 then
		winner = player1
		loser = player2
	elseif clicks2 > clicks1 then
		winner = player2
		loser = player1
	end
	
	-- Send results
	BeamClashRemote:FireClient(player1, "ClashResult", {
		winner = (winner == player1),
		yourClicks = clicks1,
		opponentClicks = clicks2,
	})
	BeamClashRemote:FireClient(player2, "ClashResult", {
		winner = (winner == player2),
		yourClicks = clicks2,
		opponentClicks = clicks1,
	})
	
	-- Apply knockback and damage to loser
	if loser then
		applyKnockback(loser, winner)
	end
	
	-- Small delay before ending clash
	task.wait(1)
	endClash(player1)
end

-- Handle BeamHitbox touch
local function onBeamHitboxTouched(hitbox, otherPart)
	local isBeamHitbox = false
	for _, name in BeamClashModule.BEAM_HITBOX_NAMES do
		if otherPart.Name == name and otherPart:IsA("BasePart") then
			isBeamHitbox = true
			break
		end
	end
	if not isBeamHitbox then return end
	
	local player1, char1 = getPlayerFromPart(hitbox)
	local player2, char2 = getPlayerFromPart(otherPart)
	
	if not player1 or not player2 then return end
	if player1 == player2 then return end
	if not BeamClashModule.IsBeaming(char1) or not BeamClashModule.IsBeaming(char2) then return end
	if BeamClashModule.IsClashing(player1) or BeamClashModule.IsClashing(player2) then return end
	
	if BeamClashModule.StartClash(player1, player2) then
		BeamClashRemote:FireClient(player1, "ClashStart", player2)
		BeamClashRemote:FireClient(player2, "ClashStart", player1)
		
		-- Run the full sequence in a separate thread
		task.spawn(runClashSequence, player1, player2)
	end
end

-- Connect Touched event on a BeamHitbox
local function connectHitbox(player, hitbox)
	if not hitbox or not hitbox:IsA("BasePart") then return end
	
	local conn = hitbox.Touched:Connect(function(other)
		onBeamHitboxTouched(hitbox, other)
	end)
	
	if playerConnections[player] then
		if playerConnections[player].hitboxTouched then
			playerConnections[player].hitboxTouched:Disconnect()
		end
		playerConnections[player].hitboxTouched = conn
	end
end

-- Set up beam detection for a character
local function setupCharacter(player, character)
	local hitbox = BeamClashModule.FindBeamHitbox(character)
	if hitbox then
		connectHitbox(player, hitbox)
	end
	
	local descConn = character.DescendantAdded:Connect(function(desc)
		for _, name in BeamClashModule.BEAM_HITBOX_NAMES do
			if desc.Name == name and desc:IsA("BasePart") then
				connectHitbox(player, desc)
				break
			end
		end
	end)
	
	if playerConnections[player] then
		playerConnections[player].descendantAdded = descConn
	end
end

-- End a clash and notify both clients
local function endClash(player)
	local partner = BeamClashModule.EndClash(player)
	clickCounts[player] = nil
	if partner then
		clickCounts[partner] = nil
	end
	BeamClashRemote:FireClient(player, "ClashEnd")
	if partner then
		BeamClashRemote:FireClient(partner, "ClashEnd")
	end
end

-- Handle click events from clients
BeamClashRemote.OnServerEvent:Connect(function(player, action)
	if action == "ClashClick" then
		if BeamClashModule.IsClashing(player) then
			clickCounts[player] = (clickCounts[player] or 0) + 1
			-- Send updated click count back to this player
			BeamClashRemote:FireClient(player, "ClashClickUpdate", clickCounts[player])
		end
	end
end)

-- Handle player added
local function onPlayerAdded(player)
	playerConnections[player] = {}
	
	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)
	
	player.CharacterRemoving:Connect(function()
		if BeamClashModule.IsClashing(player) then
			endClash(player)
		end
	end)
end

-- Handle player removing
local function onPlayerRemoving(player)
	if BeamClashModule.IsClashing(player) then
		endClash(player)
	end
	
	if playerConnections[player] then
		for key, conn in pairs(playerConnections[player]) do
			if typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
		end
		playerConnections[player] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end