--[[
	BuildingHealth Module
	NumberValue-based health system for buildings.
	Replaces Humanoid-based health management to prevent respawn damage issues.

	Health is stored in: building.Aspects.Info.Health (NumberValue)
	MaxHealth is stored in: building.Aspects.Info.Health.MaxHealth (NumberValue)
	Invulnerability is stored via attribute: building:GetAttribute("BuildingInvulnerable")
]]

local BuildingHealth = {}

-- Get the Health NumberValue from a building
local function getHealthValue(building)
	if not building then return nil end
	local aspects = building:FindFirstChild("Aspects")
	if not aspects then return nil end
	local info = aspects:FindFirstChild("Info")
	if not info then return nil end
	local health = info:FindFirstChild("Health")
	if not health or not health:IsA("NumberValue") then return nil end
	return health
end

-- Get the MaxHealth NumberValue (child of Health)
local function getMaxHealthValue(building)
	local health = getHealthValue(building)
	if not health then return nil end
	local maxHealth = health:FindFirstChild("MaxHealth")
	if not maxHealth or not maxHealth:IsA("NumberValue") then return nil end
	return maxHealth
end

function BuildingHealth.getHealth(building)
	local health = getHealthValue(building)
	return health and health.Value or 0
end

function BuildingHealth.getMaxHealth(building)
	local maxHealth = getMaxHealthValue(building)
	if maxHealth then return maxHealth.Value end
	-- Fallback: try Humanoid
	local humanoid = building and building:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.MaxHealth or 100
end

function BuildingHealth.isDead(building)
	return BuildingHealth.getHealth(building) <= 0
end

function BuildingHealth.isInvulnerable(building)
	if not building then return false end
	return building:GetAttribute("BuildingInvulnerable") == true
end

function BuildingHealth.setInvulnerable(building, value)
	if not building then return end
	building:SetAttribute("BuildingInvulnerable", value)
end

-- Apply damage to a building via NumberValue. Returns actual damage dealt.
function BuildingHealth.dealDamage(building, amount)
	if not building or not building.Parent then return 0 end
	if BuildingHealth.isInvulnerable(building) then return 0 end
	if BuildingHealth.isDead(building) then return 0 end

	local health = getHealthValue(building)
	if not health then return 0 end

	local healthBefore = health.Value
	health.Value = math.max(0, healthBefore - amount)
	return healthBefore - health.Value
end

-- Reset building health to MaxHealth
function BuildingHealth.resetHealth(building)
	if not building then return end
	local health = getHealthValue(building)
	local maxHealth = getMaxHealthValue(building)
	if health and maxHealth then
		health.Value = maxHealth.Value
	elseif health then
		local humanoid = building:FindFirstChildOfClass("Humanoid")
		if humanoid then
			health.Value = humanoid.MaxHealth
		end
	end
end

-- Connect a callback to health changes. Returns the connection.
function BuildingHealth.onHealthChanged(building, callback)
	local health = getHealthValue(building)
	if not health then return nil end
	return health.Changed:Connect(callback)
end

return BuildingHealth