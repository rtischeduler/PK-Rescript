-- CHECK IF USER IS ON MOBILE
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled
local isConsole = UserInputService.GamepadEnabled
local isComputer = UserInputService.KeyboardEnabled
local TweenService = game:GetService("TweenService")
local Emotes = script.Parent.Parent.Parent.Aspects.Emotes
-- IF USER IS ON MOBILE THEN SHOW Script.Parent.Mobile
if isMobile then
script.Parent.Mobile.Visible = true
elseif isConsole then
script.Parent.Mobile.Visible = false
end

-- MAKE script.Parent.Parent.Parent.Aspects.Emotes Function
local v123 = script
local v122 = script
script.Parent.Mobile.Aspects.Emotes.Button.MouseButton1Down:Connect(function()
--CHECK IF EMOTES SIZE IS ALREADY 0.5, 0, 0.65, 0 if so Tween size 0 0 0 0
if Emotes.Size == UDim2.new(0.5, 0, 0.65, 0) then
	Emotes:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
	return
end
-- IF NOT THEN TWEEN EMOTES SIZE TO 0.5, 0, 0.65, 0

v123 = script.Parent.Parent.Parent.Aspects
v122 = v123.Emotes
v122:TweenSize(UDim2.new(0.5, 0, 0.65, 0), "In", "Quad", 0.2)
v123 = script.Parent.Parent.Parent.Aspects
v123.Emotes:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "In", "Quad", 0.2)

end)

-- MAKE IT TO WHERE IF THE USER CLICKS ON EMOTE1, EMOTE2,  EMOTE3, OR EMOTE4  IT tweens size to 0, 0, 0, 0
script.Parent.Parent.Parent.Aspects.Emotes.Emote1.Button.MouseButton1Down:Connect(function()
	Emotes:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
end)
script.Parent.Parent.Parent.Aspects.Emotes.Emote2.Button.MouseButton1Down:Connect(function()
	Emotes:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
end)
script.Parent.Parent.Parent.Aspects.Emotes.Emote3.Button.MouseButton1Down:Connect(function()
	Emotes:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
end)
script.Parent.Parent.Parent.Aspects.Emotes.Emote4.Button.MouseButton1Down:Connect(function()
	Emotes:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.2)
end)

-- SPRINT TOGGLE (mobile)
local sprintButton = script.Parent.Mobile.Aspects.Sprint
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Update sprint button visual based on toggle state
local function updateSprintVisual(isRunning)
	if isRunning then
		--sprintButton.ImageTransparency = 0.2
	--	sprintButton.ImageColor3 = Color3.fromRGB(0, 255, 100)
	--	sprintButton.TXT.Text = "Sprint ON"
	else
		sprintButton.ImageTransparency = 0.75
		sprintButton.ImageColor3 = Color3.fromRGB(243, 255, 0)
		sprintButton.TXT.Text = "Sprint"
	end
end

-- Connect to Running value changes in the character's Animate script
local sprintConnection = nil
local function connectSprintListener(character)
	if sprintConnection then
		sprintConnection:Disconnect()
		sprintConnection = nil
	end
	local animate = character:FindFirstChild("Animate")
	if animate then
		local running = animate:FindFirstChild("Running")
		if running then
			updateSprintVisual(running.Value)
			sprintConnection = running.Changed:Connect(function()
				updateSprintVisual(running.Value)
			end)
		end
	end
end

-- Fire server event on sprint button click (toggle)
sprintButton.Button.MouseButton1Down:Connect(function()
	game.Workspace.Server.Sprint:FireServer()
end)

-- Handle character changes (respawn)
player.CharacterAdded:Connect(function(character)
	task.wait(1) -- Wait for Animate script to be added by spawn system
	connectSprintListener(character)
end)

-- Connect for current character if it exists
if player.Character then
	connectSprintListener(player.Character)
end

-- Fire LMB through the character's Animations.Event (so TitanusGodzilla hitbox logic runs)
local function fireLMB()
	local character = player.Character
	if not character then return end
	local animationsFolder = character:FindFirstChild("Animations")
	local serverEvent = animationsFolder and animationsFolder:FindFirstChild("Event")
	if serverEvent then
		serverEvent:FireServer("LMB")
	else
		warn("ServerEvent not found in Character.Animations for LMB")
	end
end

-- Mobile attack button
script.Parent.Mobile.Aspects.Attack.Button.MouseButton1Down:Connect(fireLMB)

-- PC mouse input for LMB
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fireLMB()
	end
end)