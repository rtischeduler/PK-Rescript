-- Maple_Nine || Deleted User#0696 || Plays an animation whenever the player moves (REQUIRES A FOLDER NAMED "Animations" AND 2 ANIMATIONS NAMED "Walk" AND "Idle"

local char = script.Parent
local currentAnim = "Idle"
local humanoid = char:WaitForChild("Humanoid")
local animations = char:WaitForChild("Animations")

--=== ANIMATIONS

Idle = humanoid:LoadAnimation(animations.Idle)
Walk = humanoid:LoadAnimation(animations.Walk)

--===


--=== Stops all playing animations.
local function stopAnimations()
	for i,v in pairs(humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end
--===


function charMoving(speed)
	--//The Humanoid.Running event returns the current Speed that the player is moving at, which makes it easy to determine which animation to play.
	if speed > 1 and currentAnim ~= "Walk" then
		currentAnim = "Walk"
		stopAnimations()
		Walk:Play()

	elseif speed < 2 and currentAnim ~= "Idle" then
		currentAnim = "Idle"
		stopAnimations()
		Idle:Play()
	end
end

Idle:Play()
humanoid.Running:Connect(charMoving)
local UIS = game:GetService('UserInputService')
local Player = game.Players.LocalPlayer
local Character = Player.Character


UIS.InputBegan:connect(function(input)--When a player has pressed LeftShift it will play the animation and it will set the normal walking speed (16) to 35.
	if input.KeyCode == Enum.KeyCode.LeftShift then
		Character.Humanoid.WalkSpeed = 55
		local Anim = Instance.new('Animation')
		Anim.AnimationId = 'rbxassetid://11021715721'
		PlayAnim = Character.Humanoid:LoadAnimation(Anim)
		PlayAnim:Play()
		Idle:Stop()
		Walk:Stop()
	end
end)


UIS.InputEnded:connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		Character.Humanoid.WalkSpeed = 33
		PlayAnim:Stop()
		Idle:Stop()
		Walk:Play()
	end
end)
	
