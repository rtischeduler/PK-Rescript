-- Decompiled with the Synapse X Luau decompiler.

local l__LocalPlayer__1 = game.Players.LocalPlayer;
debounce = false;
l__LocalPlayer__1:GetMouse().KeyDown:connect(function(p1)
	if not debounce then
		debounce = true;
		if p1 == "r" then
			print("RClick");
			script.Parent.Humanoid.WalkSpeed = 0
			local v2 = Instance.new("Animation");
			local v3 = Instance.new("Sound");
			v3.Parent = l__LocalPlayer__1.Character.Head;
			v3.Volume = 1000;
			v3.SoundId = "http://www.roblox.com/asset/?id=6947488201";
			v3:Play();
			v2.AnimationId = "http://www.roblox.com/asset/?id=11030225339";
			v2.Name = "HelloEmo";
			local v4 = l__LocalPlayer__1.Character.Humanoid:LoadAnimation(v2);
			print("LoadAnimate");
			v4:Play();
	
			script.Parent.FakeHead.RoarFX.Enabled = true
			script.Parent.FakeHead.RoarFX2.Enabled = true
			script.Parent.FakeHead.RoarFX3.Enabled = true
			
			
			wait(2);
			script.Parent.FakeHead.RoarFX.Enabled = false
			script.Parent.FakeHead.RoarFX2.Enabled = false
			script.Parent.FakeHead.RoarFX3.Enabled = false
			script.Parent.Humanoid.WalkSpeed = 33
			wait(6);
			
		end;
		debounce = false;
	end;
end);

