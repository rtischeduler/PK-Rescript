--[[
    BeamClashModule
    Controls beam clashing between two kaiju.
    
    When two active BeamHitbox parts touch:
    1. Starts a clash between the two players
    2. Turns both players to face each other
    3. Loops the middle 0.2 seconds of the beaming animation
    4. Disables head turning (via IsBeamClashing attribute)
    5. Prevents other attacks (via IsBeamClashing attribute)
]]

local BeamClashModule = {}

-- Configuration
BeamClashModule.LOOP_DURATION = 0.2
BeamClashModule.BEAM_HITBOX_NAMES = {"BeamHitbox", "BeamHitBox"}
BeamClashModule.LOOK_AT_RATE = 0.03

-- Clash timing
BeamClashModule.COUNTDOWN_DURATION = 3
BeamClashModule.SPAM_WINDOW_DURATION = 5

-- Clash results
BeamClashModule.LOSER_DAMAGE = 150
BeamClashModule.KNOCKBACK_FORCE = 250

-- Click tracking
BeamClashModule.MAX_CLICKS = 100  -- FillFull reaches 100% at this many clicks

-- Active clashes: { [Player] = { partner = Player, startTime = number } }
local activeClashes = {}

--- Check if a player is currently in a beam clash
function BeamClashModule.IsClashing(player)
	return activeClashes[player] ~= nil
end

--- Get the clash partner for a player
function BeamClashModule.GetClashPartner(player)
	local clash = activeClashes[player]
	return clash and clash.partner
end

--- Start a beam clash between two players
function BeamClashModule.StartClash(player1, player2)
	if activeClashes[player1] or activeClashes[player2] then
		return false
	end
	
	activeClashes[player1] = { partner = player2, startTime = tick() }
	activeClashes[player2] = { partner = player1, startTime = tick() }
	
	-- Set IsBeamClashing attribute to disable head turning and other attacks
	local char1 = player1.Character
	local char2 = player2.Character
	if char1 then char1:SetAttribute("IsBeamClashing", true) end
	if char2 then char2:SetAttribute("IsBeamClashing", true) end
	
	return true
end

--- End a beam clash for a player and their partner
function BeamClashModule.EndClash(player)
	local clash = activeClashes[player]
	if not clash then return nil end
	
	local partner = clash.partner
	activeClashes[player] = nil
	activeClashes[partner] = nil
	
	-- Remove IsBeamClashing attribute
	local char1 = player.Character
	local char2 = partner.Character
	if char1 then char1:SetAttribute("IsBeamClashing", false) end
	if char2 then char2:SetAttribute("IsBeamClashing", false) end
	
	return partner
end

--- Check if a character's beam is currently active
function BeamClashModule.IsBeaming(character)
	for _, name in BeamClashModule.BEAM_HITBOX_NAMES do
		local beamHitbox = character:FindFirstChild(name, true)
		if beamHitbox and beamHitbox:IsA("BasePart") then
			return beamHitbox.Transparency < 1
		end
	end
	return false
end

--- Find the BeamHitbox in a character (recursive search)
function BeamClashModule.FindBeamHitbox(character)
	for _, name in BeamClashModule.BEAM_HITBOX_NAMES do
		local beamHitbox = character:FindFirstChild(name, true)
		if beamHitbox and beamHitbox:IsA("BasePart") then
			return beamHitbox
		end
	end
	return nil
end

--- Calculate the animation loop window (middle LOOP_DURATION seconds)
function BeamClashModule.GetLoopWindow(animationLength)
	if animationLength <= 0 then
		return 0, 0
	end
	
	local midpoint = animationLength / 2
	local halfWindow = BeamClashModule.LOOP_DURATION / 2
	
	local loopStart = math.max(0, midpoint - halfWindow)
	local loopEnd = math.min(animationLength, midpoint + halfWindow)
	
	return loopStart, loopEnd
end

--- Make two characters face each other on the XZ plane
function BeamClashModule.UpdateLookAt(player1, player2)
	local char1 = player1.Character
	local char2 = player2.Character
	
	if not char1 or not char2 then return false end
	
	local hrp1 = char1:FindFirstChild("HumanoidRootPart")
	local hrp2 = char2:FindFirstChild("HumanoidRootPart")
	
	if not hrp1 or not hrp2 then return false end
	
	local pos1 = hrp1.Position
	local pos2 = hrp2.Position
	
	-- Rotate on XZ plane only (keep Y the same)
	hrp1.CFrame = CFrame.new(pos1, Vector3.new(pos2.X, pos1.Y, pos2.Z))
	hrp2.CFrame = CFrame.new(pos2, Vector3.new(pos1.X, pos2.Y, pos1.Z))
	
	-- Zero horizontal velocity to prevent drifting
	hrp1.AssemblyLinearVelocity = Vector3.new(0, hrp1.AssemblyLinearVelocity.Y, 0)
	hrp2.AssemblyLinearVelocity = Vector3.new(0, hrp2.AssemblyLinearVelocity.Y, 0)
	
	return true
end

--- Get all active clashes
function BeamClashModule.GetActiveClashes()
	return activeClashes
end

--- Calculate FillFull size based on click count
function BeamClashModule.GetFillSize(clickCount)
	local ratio = math.clamp(clickCount / BeamClashModule.MAX_CLICKS, 0, 1)
	return ratio
end

return BeamClashModule