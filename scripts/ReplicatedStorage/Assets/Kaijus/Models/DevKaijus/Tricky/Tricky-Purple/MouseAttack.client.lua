--By Xontez 
local player = game.Players.LocalPlayer
repeat wait() until player.Character.Humanoid
local humanoid = player.Character.Humanoid
local mouse = player:GetMouse()

local anim = Instance.new("Animation")
anim.AnimationId = "http://www.roblox.com/asset/?id=11031458471" -- ID of Animation

mouse.Button1Down:connect(function(key)
	
		local playAnim = humanoid:LoadAnimation(anim)
	playAnim:Play()

	if anim.AnimationId == "http://www.roblox.com/asset/?id=11031458471" then
		script.Parent.Head.LMB1:Play();
		wait(1.3);
		anim.AnimationId = "http://www.roblox.com/asset/?id=11031426191"
	end
	if anim.AnimationId == "http://www.roblox.com/asset/?id=11031426191" then
		script.Parent.Head.LMB2:Play();
		wait(1.3);
		anim.AnimationId = "http://www.roblox.com/asset/?id=11030953117"
	end
	if anim.AnimationId == "http://www.roblox.com/asset/?id=11030953117" then
		script.Parent.Head.LMB3:Play();
		wait(1);
		anim.AnimationId = "http://www.roblox.com/asset/?id=11031458471"
		script.Parent.Head.Stomp:Play();
	end
end)