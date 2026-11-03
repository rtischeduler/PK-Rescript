-- HealthSync (Server Script): Syncs Humanoid.Health to Aspects.Info.Health.Value
-- The combat system uses Humanoid:TakeDamage() which modifies Humanoid.Health,
-- but the HP bar UI and other scripts read from Aspects.Info.Health (a NumberValue).
-- This script bridges that gap by syncing the two on every character spawn.

local Players = game:GetService("Players")

local function hookCharacter(character)
	-- Skip buildings — they use NumberValue health as source of truth (not Humanoid)
	local buildingsFolder = workspace:FindFirstChild("Buildings")
	if buildingsFolder and character:IsDescendantOf(buildingsFolder) then
		return
	end

	-- Wait for Humanoid
	local humanoid = character:WaitForChild("Humanoid", 15)
	if not humanoid or not character.Parent then return end

	-- Wait for Aspects.Info.Health
	local aspects = character:WaitForChild("Aspects", 15)
	if not aspects or not character.Parent then return end

	local info = aspects:WaitForChild("Info", 10)
	if not info or not character.Parent then return end

	local healthValue = info:WaitForChild("Health", 10)
	if not healthValue or not character.Parent then return end

	local maxHealthValue = healthValue:WaitForChild("MaxHealth", 10)
	if not maxHealthValue or not character.Parent then return end

	-- Sync MaxHealth
	maxHealthValue.Value = humanoid.MaxHealth

	-- Sync current Health
	healthValue.Value = humanoid.Health

	-- Keep them in sync going forward
	humanoid.HealthChanged:Connect(function(newHealth)
		if character.Parent then
			healthValue.Value = newHealth
		end
	end)

	-- If MaxHealth changes, sync that too
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		if character.Parent then
			maxHealthValue.Value = humanoid.MaxHealth
		end
	end)

	print("[HealthSync] Hooked " .. character.Name .. " - HP: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(hookCharacter)
	if player.Character then
		task.spawn(hookCharacter, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end

print("[HealthSync] Server health sync script loaded")