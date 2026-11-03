local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackConfirmEvent = ReplicatedStorage:FindFirstChild("AttackConfirmEvent")
local AttackEndEvent = ReplicatedStorage:FindFirstChild("AttackEndEvent")

-- Global lockout: prevents ANY attack from firing while one is in progress
-- Matches the server script's state.isBusy logic
local isBusy = false

-- Pending attack: stores the button reference while waiting for server confirmation
local pendingAttack = nil

-- Cooldown durations for UI (how long the cooldown bar fills after attack ends)
local COOLDOWN_DURATIONS = {
	SP1 = 12,
	SP2 = 15,
	SP3 = 20,
	Grab = 9,
}

-- Tracks the currently active attack so AttackEndEvent knows which button to advance
local activeAttack = nil

local function startCooldownPhase(v, EventName)
	local barGrad = v:FindFirstChild("BarGrad")
	local cooldownDuration = COOLDOWN_DURATIONS[EventName] or 2

	-- Release global busy lock - other attacks can now fire
	isBusy = false
	activeAttack = nil

	-- Cooldown phase: show cooldown UI
	v.TXT.Visible = false
	v.CD.Visible = true
	v.Img.Visible = false
	barGrad.Offset = Vector2.new(0, 0)
	task.wait(0.1)

	local tweenInfo = TweenInfo.new(
		cooldownDuration,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(barGrad, tweenInfo, {Offset = Vector2.new(0, 1)})
	tween:Play()

	local remaining = cooldownDuration
	v.CD.Text = remaining
	while remaining > 0 do
		task.wait(1)
		remaining = remaining - 1
		v.CD.Text = remaining
	end

	-- Flash animation when cooldown finishes
	local v200 = script.Parent.Parent.Parent.HealthStats.SetupHPandAttacks.Sounds.Shine:Clone()
	v200.Parent = script
	v200:Play()
	v.TXT.Visible = true
	v.Img.Visible = true
	v.CD.Visible = false
	local p8 = 0
	local p7 = v.Flash
	v200.PlayOnRemove = true
	v200:Destroy()
	p7.Image = "0"
	p7.Image = "rbxassetid://9306185645"
	task.wait(p8)
	p7.Image = "rbxassetid://9306185497"
	task.wait(p8)
	p7.Image = "rbxassetid://9306185349"
	task.wait(p8)
	p7.Image = "rbxassetid://9306185183"
	task.wait(p8)
	p7.Image = "rbxassetid://9306185027"
	task.wait(p8)
	p7.Image = "rbxassetid://9306184888"
	task.wait(p8)
	p7.Image = "rbxassetid://9306184747"
	task.wait(p8)
	p7.Image = "rbxassetid://9306184554"
	task.wait(p8)
	p7.Image = "rbxassetid://9306184434"
	task.wait(p8)
	p7.Image = "rbxassetid://9306184265"
	task.wait(p8)
	p7.Image = "0"
	v200:Destroy()
	v.Button.Visible = true
end

local function performAttack(v)
	-- Reject if any attack is already in progress (matches server isBusy check)
	if isBusy then return end
	-- Reject if this specific button is still on its own cooldown
	if not v.Button.Visible then return end
	-- Reject if already waiting for a server confirmation
	if pendingAttack then return end

	local EventName = v.Name
	local character = game.Players.LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Find ServerEvent inside Character.Animations
	local animationsFolder = character:FindFirstChild("Animations")
	local ServerEvent = animationsFolder and animationsFolder:FindFirstChild("Event")
	if not ServerEvent then
		warn("ServerEvent not found in Character.Animations")
		return
	end

	-- Set pending state and fire the server event
	-- The server will confirm via AttackConfirmEvent if the attack was actually accepted
	pendingAttack = v
	ServerEvent:FireServer(EventName)

	-- Timeout: if no server confirmation within 1 second, clear pending state
	task.delay(1, function()
		if pendingAttack == v then
			pendingAttack = nil
		end
	end)
end

-- Listen for server confirmation that an attack was actually fired
-- Only apply cooldown if the server confirms the attack was accepted
-- Start the attack phase: lock out and show attack visuals
local function startAttackPhase(v, EventName)
	isBusy = true
	activeAttack = {button = v, attackType = EventName}

	-- Attack phase: hide button, show attack visuals
	v.Button.Visible = false
	v.TXT.Visible = true
	v.CD.Visible = false
	v.Img.Visible = true

	-- Safety fallback: if no AttackEndEvent arrives within 10s, force cooldown
	task.delay(10, function()
		if activeAttack and activeAttack.attackType == EventName then
			startCooldownPhase(v, EventName)
		end
	end)
end

if AttackConfirmEvent then
	AttackConfirmEvent.OnClientEvent:Connect(function(attackType)
		if pendingAttack and pendingAttack.Name == attackType then
			local v = pendingAttack
			pendingAttack = nil
			task.spawn(function()
				startAttackPhase(v, attackType)
			end)
		end
	end)
end

-- Listen for server signal that the attack's busy phase has ended -> begin cooldown
if AttackEndEvent then
	AttackEndEvent.OnClientEvent:Connect(function(attackType)
		if activeAttack and activeAttack.attackType == attackType then
			local v = activeAttack.button
			task.spawn(function()
				startCooldownPhase(v, attackType)
			end)
		end
	end)
end

-- Button click handlers
for _, v in pairs(script.Parent:GetChildren()) do
	if v:IsA("ImageButton") then
		v.Button.MouseButton1Click:Connect(function()
			performAttack(v)
		end)
	end
end

-- Keyboard input handlers
local UserInputService = game:GetService("UserInputService")
local KeybindConfig = require(game.ReplicatedStorage.KeybindConfig)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == KeybindConfig.SP1 then
		local btn = script.Parent:FindFirstChild("SP1")
		if btn then performAttack(btn) end
	elseif input.KeyCode == KeybindConfig.SP2 then
		local btn = script.Parent:FindFirstChild("SP2")
		if btn then performAttack(btn) end
	elseif input.KeyCode == KeybindConfig.SP3 then
		local btn = script.Parent:FindFirstChild("SP3")
		if btn then performAttack(btn) end
	elseif input.KeyCode == KeybindConfig.Grab then
		local btn = script.Parent:FindFirstChild("Grab")
		if btn then performAttack(btn) end

	end
end)