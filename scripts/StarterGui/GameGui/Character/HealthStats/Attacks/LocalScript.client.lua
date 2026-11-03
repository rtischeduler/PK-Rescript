local isBlocking = false

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackConfirmEvent = ReplicatedStorage:FindFirstChild("AttackConfirmEvent")
local AttackEndEvent = ReplicatedStorage:FindFirstChild("AttackEndEvent")

-- Roar attack state (uses server-confirmed start/end signals instead of hardcoded duration)
local roarPending = nil  -- button ref while waiting for server confirmation
local roarActive = nil   -- button ref during attack phase
local ROAR_COOLDOWN = 5

-- Roar cooldown phase: shown after server signals AttackEndEvent
local function startRoarCooldownPhase(v)
	local barGrad = v:FindFirstChild("BarGrad")
	roarActive = nil

	-- Cooldown phase: show cooldown UI
	v.TXT.Visible = false
	v.CD.Visible = true
	v.Img.Visible = false
	barGrad.Offset = Vector2.new(0, 0)
	task.wait(0.1)

	local roarTweenInfo = TweenInfo.new(
		ROAR_COOLDOWN,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(barGrad, roarTweenInfo, {Offset = Vector2.new(0, 1)})
	tween:Play()

	local remaining = ROAR_COOLDOWN
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

-- Roar attack phase: shown after server confirms via AttackConfirmEvent
local function startRoarAttackPhase(v)
	roarActive = v

	-- Attack phase: hide button, show attack visuals
	v.Button.Visible = false
	v.TXT.Visible = true
	v.CD.Visible = false
	v.Img.Visible = true

	-- Safety fallback: if no AttackEndEvent arrives within 10s, force cooldown
	task.delay(10, function()
		if roarActive == v then
			startRoarCooldownPhase(v)
		end
	end)
end

-- Roar attack request: fires server event and waits for confirmation
local function performRoarAttack(v)
	-- Reject if button not visible (already on cooldown or attacking)
	if not v.Button.Visible then return end
	-- Reject if already waiting for server confirmation
	if roarPending then return end
	-- Reject while blocking
	if isBlocking then return end

	local character = game.Players.LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local animationsFolder = character:FindFirstChild("Animations")
	local ServerEvent = animationsFolder and animationsFolder:FindFirstChild("Event")
	if not ServerEvent then
		warn("ServerEvent not found in Character.Animations")
		return
	end

	-- Set pending state and fire the server event
	-- The server will confirm via AttackConfirmEvent if the attack was actually accepted
	roarPending = v
	ServerEvent:FireServer("Roar")

	-- Timeout: if no server confirmation within 1 second, clear pending state (no cooldown applied)
	task.delay(1, function()
		if roarPending == v then
			roarPending = nil
		end
	end)
end

-- Listen for server confirmation that roar was accepted -> start attack phase
if AttackConfirmEvent then
	AttackConfirmEvent.OnClientEvent:Connect(function(attackType)
		if attackType == "Roar" and roarPending then
			local v = roarPending
			roarPending = nil
			task.spawn(function()
				startRoarAttackPhase(v)
			end)
		end
	end)
end

-- Listen for server signal that roar's busy phase has ended -> begin cooldown
if AttackEndEvent then
	AttackEndEvent.OnClientEvent:Connect(function(attackType)
		if attackType == "Roar" and roarActive then
			local v = roarActive
			task.spawn(function()
				startRoarCooldownPhase(v)
			end)
		end
	end)
end

-- Tween for non-roar attack cooldowns (legacy)
local tweenInfo = TweenInfo.new(
	5, -- Duration: 3 seconds to fill back
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out
)

for _, v in pairs(script.Parent:GetChildren()) do
	if v:IsA("ImageButton") then
		v.Button.MouseButton1Click:Connect(function()

			--EVENTNAME ADD "Event" at the end of v.Name
			local EventName = v.Name
			-- Route Roar through the server-confirmed start/end signal system
			if EventName == "Roar" then
				performRoarAttack(v)
				return
			end
			local barGrad = v:WaitForChild("BarGrad")
			local character = game.Players.LocalPlayer.Character
			local humanoid = character:WaitForChild("Humanoid")
			-- Find ServerEvent inside of Character.Animations looks like : script.Parent.OnServerEvent:Connect(function(player, Type)
		    local ServerEvent = character:WaitForChild("Animations"):WaitForChild("Event")
			

			-- Reject attacks while blocking (Block itself is allowed)
			if isBlocking and EventName ~= "Block" then return end

			if ServerEvent then
				ServerEvent:FireServer(EventName)
			else
				warn("ServerEvent not found in Workspace.Server")
			end
			-- Block has no cooldown — it's togglable
			if EventName == "Block" then
				isBlocking = not isBlocking
				return
			end
			-- Dont let user press again until finished for 5 seconds
			v.Button.Visible = false
			v.TXT.Visible = true
			v.CD.Visible = false
			v.Img.Visible = true
			wait(5)
			v.TXT.Visible = false
			v.CD.Visible = true
			v.Img.Visible = false
			barGrad.Offset = Vector2.new(0, 0)
			wait(0.1)
			local tween = TweenService:Create(barGrad, tweenInfo, {Offset = Vector2.new(0, 1)})
			tween:Play()
			
			local SP1Duration = 5
			v.CD.Text = SP1Duration
			while SP1Duration > 0 do
				wait(1)
				SP1Duration = SP1Duration - 1
				v.CD.Text = SP1Duration
			end


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
			wait(p8)
			p7.Image = "rbxassetid://9306185497"
			wait(p8)
			p7.Image = "rbxassetid://9306185349"
			wait(p8)
			p7.Image = "rbxassetid://9306185183"
			wait(p8)
			p7.Image = "rbxassetid://9306185027"
			wait(p8)
			p7.Image = "rbxassetid://9306184888"
			wait(p8)
			p7.Image = "rbxassetid://9306184747"
			wait(p8)
			p7.Image = "rbxassetid://9306184554"
			wait(p8)
			p7.Image = "rbxassetid://9306184434"
			wait(p8)
			p7.Image = "rbxassetid://9306184265"
			wait(p8)
			p7.Image = "0"
			v200:Destroy()
			v.Button.Visible = true




		end)

	end
end

function ButtonEffect(button)
	-- FIND BUTTON IMAGE BUTTON BY NAME IN SCRIPT PARENT
              	local v = button
				--EVENTNAME ADD "Event" at the end of v.Name
				local EventName = v.Name
				-- Route Roar through the server-confirmed start/end signal system
				if EventName == "Roar" then
					performRoarAttack(v)
					return
				end
				local barGrad = v:WaitForChild("BarGrad")
				local character = game.Players.LocalPlayer.Character
				local humanoid = character:WaitForChild("Humanoid")
				-- Find ServerEvent inside of Character.Animations looks like : script.Parent.OnServerEvent:Connect(function(player, Type)
				local ServerEvent = character:WaitForChild("Animations"):WaitForChild("Event")


				-- Reject attacks while blocking (Block itself is allowed)
				if isBlocking and EventName ~= "Block" then return end

				if ServerEvent then
					ServerEvent:FireServer(EventName)
				else
					warn("ServerEvent not found in Workspace.Server")
				end
				-- Block has no cooldown — it's togglable
				if EventName == "Block" then
					isBlocking = not isBlocking
					return
				end
				-- Dont let user press again until finished for 5 seconds
				v.Button.Visible = false
				v.TXT.Visible = true
				v.CD.Visible = false
				v.Img.Visible = true
				wait(5)
				v.TXT.Visible = false
				v.CD.Visible = true
				v.Img.Visible = false
				barGrad.Offset = Vector2.new(0, 0)
				wait(0.1)
				local tween = TweenService:Create(barGrad, tweenInfo, {Offset = Vector2.new(0, 1)})
				tween:Play()

				local SP1Duration = 5
				v.CD.Text = SP1Duration
				while SP1Duration > 0 do
					wait(1)
					SP1Duration = SP1Duration - 1
					v.CD.Text = SP1Duration
				end


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
				wait(p8)
				p7.Image = "rbxassetid://9306185497"
				wait(p8)
				p7.Image = "rbxassetid://9306185349"
				wait(p8)
				p7.Image = "rbxassetid://9306185183"
				wait(p8)
				p7.Image = "rbxassetid://9306185027"
				wait(p8)
				p7.Image = "rbxassetid://9306184888"
				wait(p8)
				p7.Image = "rbxassetid://9306184747"
				wait(p8)
				p7.Image = "rbxassetid://9306184554"
				wait(p8)
				p7.Image = "rbxassetid://9306184434"
				wait(p8)
				p7.Image = "rbxassetid://9306184265"
				wait(p8)
				p7.Image = "0"
				v.Button.Visible = true

		
end



local UserInputService = game:GetService("UserInputService")
local KeybindConfig = require(game.ReplicatedStorage.KeybindConfig)

-- ON KEY PRESS - uses dynamic keybinds from KeybindConfig
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == KeybindConfig.Roar then
		performRoarAttack(script.Parent.Roar)
	elseif input.KeyCode == KeybindConfig.Escape then
		ButtonEffect(script.Parent.Escape)
	elseif input.KeyCode == KeybindConfig.Block then
		ButtonEffect(script.Parent.Block)
	end
end)
