local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local XPModule = require(ReplicatedStorage:WaitForChild("XPModule"))

local EnemyStats = script.Parent
local PlayerHolder = EnemyStats:WaitForChild("PlayerHolder")
local HealthFrame = EnemyStats:WaitForChild("Health")
local StaminaFrame = EnemyStats:WaitForChild("Stamina")
local PlayerNameLabel = PlayerHolder:WaitForChild("PlayerName")
local KaijuNameLabel = PlayerHolder:WaitForChild("KaijuName")
local KaijuImageLabel = PlayerHolder:WaitForChild("KaijuImage")

-- Health bar elements
local HealthClipping = HealthFrame:WaitForChild("Clipping")
local HealthTop = HealthClipping:WaitForChild("Top")
local HealthTxt = HealthFrame:WaitForChild("TXT")

-- Stamina bar elements
local StaminaClipping = StaminaFrame:WaitForChild("Clipping")
local StaminaTop = StaminaClipping:WaitForChild("Top")
local StaminaTxt = StaminaFrame:WaitForChild("TXT")

-- Rank elements
local RankTxtLabel = PlayerHolder:WaitForChild("RankTxt")
local RankTxtTx = RankTxtLabel:WaitForChild("TX")

-- Rank icon folder (same as RankIconManager)
local rankIconsFolder = ReplicatedStorage:WaitForChild("Assets").Kaijus.Model.UI.InGame.RankIcons

local RANK_NAME_TO_FOLDER = {
	Ruby = "Platinum",
	Emerald = "Platinum",
}

-- Hide by default
EnemyStats.Visible = false

local currentTarget = nil
local targetHumanoid = nil
local targetPlayer = nil
local targetHealthValue = nil   -- NumberValue for building health
local targetMaxHealthValue = nil -- NumberValue for building max health
local staminaValue = nil
local maxStaminaValue = nil
local connections = {}

-- Building detection helper
local function isBuilding(character)
	if not character then return false end
	local buildingsFolder = workspace:FindFirstChild("Buildings")
	if not buildingsFolder then return false end
	return character:IsDescendantOf(buildingsFolder)
end

local function clearConnections()
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}
end

-- Resizes a clipping bar and counter-resizes the Top image to prevent distortion
-- (same pattern used by the player's HPBarHandler and StaminaBarHandler)
local function resizeCustomLoadingBarX(clipping, top, ratio)
	ratio = math.clamp(ratio, 0, 1)
	clipping.Size = UDim2.new(ratio, clipping.Size.X.Offset, clipping.Size.Y.Scale, clipping.Size.Y.Offset)
	if ratio > 0 then
		local scale = 1 / ratio
		top.Size = UDim2.new(scale, top.Size.X.Offset, top.Size.Y.Scale, top.Size.Y.Offset)
	else
		top.Size = UDim2.new(0, top.Size.X.Offset, top.Size.Y.Scale, top.Size.Y.Offset)
	end
end

local function getRankTemplate(rankNumber)
	local rankName = XPModule.getRankName(rankNumber)
	local folderName = RANK_NAME_TO_FOLDER[rankName] or rankName
	local template = rankIconsFolder:FindFirstChild(folderName)
	if not template then
		template = rankIconsFolder:FindFirstChild("Bronze")
	end
	return template, rankName
end

local function copyGradient(srcGradient, destParent)
	local dest = destParent:FindFirstChildOfClass("UIGradient")
	if not dest then
		dest = Instance.new("UIGradient")
		dest.Parent = destParent
	end
	dest.Color = srcGradient.Color
	dest.Transparency = srcGradient.Transparency
	dest.Rotation = srcGradient.Rotation
	dest.Offset = srcGradient.Offset
	dest.Scale = srcGradient.Scale
	dest.Enabled = srcGradient.Enabled
end

-- Update a PlayerHolder with rank icon properties from a template (same logic as RankIconManager)
local function updatePlayerHolder(targetHolder, templateHolder)
	if not targetHolder or not templateHolder then return end

	local targetRank = targetHolder:FindFirstChild("Rank")
	local templateRank = templateHolder:FindFirstChild("Rank")
	if targetRank and templateRank then
		targetRank.Image = templateRank.Image
		targetRank.ImageColor3 = templateRank.ImageColor3
		targetRank.ImageTransparency = templateRank.ImageTransparency
		targetRank.ZIndex = templateRank.ZIndex
		targetRank.Size = templateRank.Size
		targetRank.Position = templateRank.Position
		targetRank.AnchorPoint = templateRank.AnchorPoint
	end

	local targetRankTxt = targetHolder:FindFirstChild("RankTxt")
	local templateRankTxt = templateHolder:FindFirstChild("RankTxt")
	if targetRankTxt and templateRankTxt then
		targetRankTxt.Image = templateRankTxt.Image
		targetRankTxt.ImageColor3 = templateRankTxt.ImageColor3
		targetRankTxt.ImageTransparency = templateRankTxt.ImageTransparency
	end

	local targetRing = targetHolder:FindFirstChild("Ring")
	local templateRing = templateHolder:FindFirstChild("Ring")
	if targetRing and templateRing then
		targetRing.Image = templateRing.Image
		targetRing.ImageColor3 = templateRing.ImageColor3
		targetRing.ImageTransparency = templateRing.ImageTransparency
		targetRing.ZIndex = templateRing.ZIndex

		local templateGradient = templateRing:FindFirstChildOfClass("UIGradient")
		if templateGradient then
			copyGradient(templateGradient, targetRing)
		end
	end
end

-- Update rank icon and level text for the target player
local function updateEnemyRankAndLevel(player)
	if not player then return end

	local inventory = player:FindFirstChild("Inventory")
	if not inventory then return end
	local xpFolder = inventory:FindFirstChild("XP")
	if not xpFolder then return end
	local rankValue = xpFolder:FindFirstChild("Rank")
	local levelValue = xpFolder:FindFirstChild("Level")

	local rankNumber = rankValue and rankValue.Value or 1
	local level = levelValue and levelValue.Value or 1

	local template = getRankTemplate(rankNumber)
	if template then
		local templateHolder = template:FindFirstChild("PlayerHolder")
		if templateHolder then
			updatePlayerHolder(PlayerHolder, templateHolder)
		end
	end

	-- Update the level text in RankTxt
	RankTxtTx.Text = "Level " .. level
end

local function updateEnemyDisplay(character)
	if not character or not character.Parent then
		return
	end

	local targetIsBuilding = isBuilding(character)

	-- PlayerName: use the character's Name (which includes the player name or dummy name)
	local playerName = character.Name
	-- If the character has a player, use the player's display name instead
	targetPlayer = Players:GetPlayerFromCharacter(character)
	if targetPlayer then
		playerName = targetPlayer.DisplayName
	end
	PlayerNameLabel.Text = playerName

	if targetIsBuilding then
		-- Buildings: show building name, hide kaiju-specific elements
		local nameValue = character:FindFirstChild("Name")
		if nameValue and nameValue:IsA("StringValue") then
			KaijuNameLabel.Text = nameValue.Value
		else
			KaijuNameLabel.Text = "Building"
		end
		KaijuImageLabel.Image = ""
		RankTxtLabel.Visible = false
		StaminaFrame.Visible = false
	else
		-- KaijuName and KaijuImage: read from Name and Image values cloned into the character
		local nameValue = character:FindFirstChild("Name")
		if nameValue and nameValue:IsA("StringValue") then
			KaijuNameLabel.Text = nameValue.Value
		else
			KaijuNameLabel.Text = character.Name
		end

		local imageValue = character:FindFirstChild("Image")
		if imageValue and imageValue:IsA("NumberValue") then
			KaijuImageLabel.Image = "rbxassetid://" .. tostring(math.floor(imageValue.Value))
		else
			KaijuImageLabel.Image = ""
		end

		-- Update rank and level only if it's a real player
		if targetPlayer then
			updateEnemyRankAndLevel(targetPlayer)
			RankTxtLabel.Visible = true
		else
			RankTxtLabel.Visible = false
		end

		-- Show stamina for players only
		StaminaFrame.Visible = (targetPlayer ~= nil)
	end
end

local function updateHealthBar()
	if targetHealthValue and targetHealthValue.Parent and targetMaxHealthValue and targetMaxHealthValue.Parent then
		-- Building: read from NumberValues
		local health = targetHealthValue.Value
		local maxHealth = targetMaxHealthValue.Value
		local ratio = (maxHealth > 0) and (health / maxHealth) or 0
		resizeCustomLoadingBarX(HealthClipping, HealthTop, ratio)
		HealthTxt.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
		return
	end

	if not targetHumanoid or not targetHumanoid.Parent then
		return
	end

	local health = targetHumanoid.Health
	local maxHealth = targetHumanoid.MaxHealth

	local ratio = (maxHealth > 0) and (health / maxHealth) or 0
	resizeCustomLoadingBarX(HealthClipping, HealthTop, ratio)

	HealthTxt.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
end

local function updateStaminaBar()
	if not staminaValue or not staminaValue.Parent then
		return
	end
	if not maxStaminaValue or not maxStaminaValue.Parent then
		return
	end

	local stamina = staminaValue.Value
	local maxStamina = maxStaminaValue.Value

	local ratio = (maxStamina > 0) and (stamina / maxStamina) or 0
	resizeCustomLoadingBarX(StaminaClipping, StaminaTop, ratio)

	StaminaTxt.Text = math.floor(stamina) .. "/" .. math.floor(maxStamina)
end

-- Hook stamina value changes for player targets only
local function hookStamina(character)
	clearConnections()
	staminaValue = nil
	maxStaminaValue = nil

	if not targetPlayer then
		return -- Not a player, don't hook stamina
	end

	local aspects = character:FindFirstChild("Aspects")
	if not aspects then return end
	local info = aspects:FindFirstChild("Info")
	if not info then return end
	local stamina = info:FindFirstChild("Stamina")
	if not stamina then return end
	local maxStamina = stamina:FindFirstChild("MaxStamina")
	if not maxStamina then return end

	staminaValue = stamina
	maxStaminaValue = maxStamina

	-- Update immediately
	updateStaminaBar()

	-- Connect to value changes (event-driven, no polling)
	table.insert(connections, stamina.Changed:Connect(updateStaminaBar))
	table.insert(connections, maxStamina.Changed:Connect(updateStaminaBar))
end

local function setTarget(character)
	if currentTarget == character then
		-- Same target, just make sure we're visible and updating
		updateEnemyDisplay(character)
		return
	end

	currentTarget = character
	targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
	targetPlayer = character and Players:GetPlayerFromCharacter(character)
	targetHealthValue = nil
	targetMaxHealthValue = nil

	-- For buildings, get health from Aspects.Info NumberValues instead of Humanoid
	if character and isBuilding(character) then
		local aspects = character:FindFirstChild("Aspects")
		if aspects then
			local info = aspects:FindFirstChild("Info")
			if info then
				targetHealthValue = info:FindFirstChild("Health")
				-- MaxHealth is a child of the Health NumberValue, not a sibling in Info
				targetMaxHealthValue = targetHealthValue and targetHealthValue:FindFirstChild("MaxHealth")
			end
		end
	end

	if not character then
		EnemyStats.Visible = false
		return
	end

	-- For buildings, we don't need a Humanoid to show the panel
	if not isBuilding(character) and not targetHumanoid then
		EnemyStats.Visible = false
		return
	end

	-- Show the EnemyStats and populate data
	EnemyStats.Visible = true
	updateEnemyDisplay(character)
	updateHealthBar()

	-- Hook stamina only for players (non-players: only show health, don't change anything else)
	hookStamina(character)
end

local function clearTarget()
	currentTarget = nil
	targetHumanoid = nil
	targetPlayer = nil
	targetHealthValue = nil
	targetMaxHealthValue = nil
	staminaValue = nil
	maxStaminaValue = nil
	clearConnections()
	EnemyStats.Visible = false
end

-- Listen for combat target signals from the server
local CombatTargetEvent = game.ReplicatedStorage:WaitForChild("CombatTarget")
CombatTargetEvent.OnClientEvent:Connect(function(targetCharacter)
	if not targetCharacter or not targetCharacter.Parent then
		return
	end

	-- Don't target ourselves
	if targetCharacter == Player.Character then
		return
	end

	setTarget(targetCharacter)
end)

-- Constantly update health bar and check if target is still alive
RunService.Heartbeat:Connect(function()
	if not currentTarget then return end

	-- Check if target still exists
	if not currentTarget or not currentTarget.Parent then
		clearTarget()
		return
	end

	-- For buildings, re-acquire health NumberValues if lost
	if isBuilding(currentTarget) then
		if not targetHealthValue or not targetHealthValue.Parent then
			local aspects = currentTarget:FindFirstChild("Aspects")
			if aspects then
				local info = aspects:FindFirstChild("Info")
				if info then
					targetHealthValue = info:FindFirstChild("Health")
					-- MaxHealth is a child of the Health NumberValue, not a sibling in Info
					targetMaxHealthValue = targetHealthValue and targetHealthValue:FindFirstChild("MaxHealth")
				end
			end
		end
		if not targetHealthValue then
			clearTarget()
			return
		end
	else
		-- Re-acquire humanoid if lost (kaijus)
		if not targetHumanoid or not targetHumanoid.Parent then
			targetHumanoid = currentTarget:FindFirstChildOfClass("Humanoid")
			if not targetHumanoid then
				clearTarget()
				return
			end
		end
	end

	-- Update health bar every frame
	updateHealthBar()

	-- If target is dead, hide after a short delay so the player sees the 0 HP
	local isDead = false
	if targetHealthValue and targetHealthValue.Parent then
		isDead = targetHealthValue.Value <= 0
	elseif targetHumanoid and targetHumanoid.Parent then
		isDead = targetHumanoid.Health <= 0
	end

	if isDead then
		task.delay(1.5, function()
			-- Only clear if this is still the same target and they're still dead
			local stillDead = false
			if targetHealthValue and targetHealthValue.Parent then
				stillDead = targetHealthValue.Value <= 0
			elseif targetHumanoid and targetHumanoid.Parent then
				stillDead = targetHumanoid.Health <= 0
			end
			if currentTarget and stillDead then
				clearTarget()
			end
		end)
	end
end)

-- Also clear target when our own character dies (we can't be fighting if we're dead)
Player.CharacterAdded:Connect(function(character)
	-- When we respawn, clear any old target reference
	clearTarget()
end)