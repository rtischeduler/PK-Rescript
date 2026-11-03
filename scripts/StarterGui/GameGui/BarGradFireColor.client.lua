-- Constantly updates every attack button's BarGrad to the player's fire color.
-- Falls back to BladeColor if no FireColor is present.
-- Re-checks the player character every interval because the player morphs.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gameGui = script.Parent

-- Collect all BarGrad UIGradient instances from both attack button folders
-- Also collect the Rage bar fill gradient so it is affected by fire color too
local function collectBarGrads()
	local grads = {}

	local function scanAttacksFolder(attacksFolder)
		if not attacksFolder then return end
		for _, btn in ipairs(attacksFolder:GetChildren()) do
			local barGrad = btn:FindFirstChild("BarGrad")
			if barGrad and barGrad:IsA("UIGradient") then
				table.insert(grads, barGrad)
			end
		end
	end

	local characterFrame = gameGui:FindFirstChild("Character")
	if characterFrame then
		local healthStats = characterFrame:FindFirstChild("HealthStats")
		if healthStats then
			scanAttacksFolder(healthStats:FindFirstChild("Attacks"))
		end
		local attacksRage = characterFrame:FindFirstChild("AttacksRage")
		if attacksRage then
			scanAttacksFolder(attacksRage:FindFirstChild("Attacks"))

			-- Collect the Rage bar fill gradient (named "UIGradient" on the Top element)
			local rageBar = attacksRage:FindFirstChild("Rage")
			if rageBar then
				local clipping = rageBar:FindFirstChild("Clipping")
				local innerClipping = clipping and clipping:FindFirstChild("Clipping")
				local top = innerClipping and innerClipping:FindFirstChild("Top")
				local rageGrad = top and top:FindFirstChildWhichIsA("UIGradient")
				if rageGrad then
					table.insert(grads, rageGrad)
				end
			end
		end
	end

	return grads
end

local barGrads = collectBarGrads()

-- Re-collect if new attack buttons are added later
for _, folder in ipairs({
	gameGui:FindFirstChild("Character") and gameGui.Character:FindFirstChild("HealthStats") and gameGui.Character.HealthStats:FindFirstChild("Attacks"),
	gameGui:FindFirstChild("Character") and gameGui.Character:FindFirstChild("AttacksRage") and gameGui.Character.AttacksRage:FindFirstChild("Attacks"),
}) do
	if folder then
		folder.ChildAdded:Connect(function()
			barGrads = collectBarGrads()
		end)
	end
end

-- Also re-collect if the Rage bar or its children are added/reparented
local attacksRageFolder = gameGui:FindFirstChild("Character") and gameGui.Character:FindFirstChild("AttacksRage")
if attacksRageFolder then
	attacksRageFolder.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("UIGradient") then
			barGrads = collectBarGrads()
		end
	end)
end

local currentFireColor = nil

local function updateBarGrads(color)
	for _, barGrad in ipairs(barGrads) do
		if barGrad and barGrad.Parent then
			barGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.001, color),
				ColorSequenceKeypoint.new(1, color),
			})
		end
	end
end

-- Constantly check for the player character (it morphs) and update fire color
while true do
	local character = player.Character
	if character then
		local aspects = character:FindFirstChild("Aspects")
		local colors = aspects and aspects:FindFirstChild("Colors")
		local normalColor = colors and colors:FindFirstChild("NormalColor")
		local fireColorVal = normalColor and normalColor:FindFirstChild("FireColor")
		if not fireColorVal then
			fireColorVal = normalColor and normalColor:FindFirstChild("BladeColor")
		end
		if fireColorVal then
			local fireColor = fireColorVal.Value
			if fireColor ~= currentFireColor then
				currentFireColor = fireColor
				updateBarGrads(fireColor)
			end
		end
	end
	task.wait(0.5)
end