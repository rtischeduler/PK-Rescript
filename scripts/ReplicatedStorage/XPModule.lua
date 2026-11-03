-- XPModule: Defines XP requirements per level and the prestige/rank system.
-- Every 205 levels = next rank, resets to level 1.
-- Both client and server can require this module.

local XPModule = {}

-- Rank names in order. After the last name, ranks continue numerically (e.g. "Rank 7").
XPModule.RANK_NAMES = {
	[1] = "Bronze",
	[2] = "Silver",
	[3] = "Gold",
	[4] = "Diamond",
	[5] = "Ruby",
	[6] = "Emerald",
}

XPModule.LEVELS_PER_RANK = 205

-- XP required to advance from one level to the next.
-- Formula: base + (level * growth). This gives a gentle curve.
XPModule.BASE_XP = 300
XPModule.XP_GROWTH = 50

-- Get the XP needed to go from `level` to `level + 1`
function XPModule.getXPForLevel(level)
	return XPModule.BASE_XP + ((level - 1) * XPModule.XP_GROWTH)
end

-- Get the rank number for a given level (1-based)
function XPModule.getRankFromLevel(level)
	return math.floor((level - 1) / XPModule.LEVELS_PER_RANK) + 1
end

-- Get the level within the current rank (1 to LEVELS_PER_RANK)
function XPModule.getLevelInRank(level)
	return ((level - 1) % XPModule.LEVELS_PER_RANK) + 1
end

-- Get the display name for a rank number
function XPModule.getRankName(rank)
	return XPModule.RANK_NAMES[rank] or ("Rank " .. rank)
end

-- Given current XP, Level (within current rank 1..LEVELS_PER_RANK), Rank, and XPToEarn,
-- process a level-up. When level exceeds LEVELS_PER_RANK, it resets to 1 and rank
-- increments (prestige).
-- Returns: newLevel, newXP, newXPToEarn, newRank
-- This is a pure calculation function; the caller is responsible for setting values.
function XPModule.processLevelUp(currentXP, currentLevel, currentXPToEarn, currentRank)
	local level = currentLevel
	local xp = currentXP
	local xpToEarn = currentXPToEarn
	local rank = currentRank or 1

	-- Level up as long as XP meets the requirement
	while xp >= xpToEarn do
		xp = xp - xpToEarn
		level = level + 1
		-- Prestige: reset level to 1 and increment rank
		if level > XPModule.LEVELS_PER_RANK then
			level = 1
			rank = rank + 1
		end
		xpToEarn = XPModule.getXPForLevel(level)
	end

	return level, xp, xpToEarn, rank
end

return XPModule