local v3 = script.Char.Value
local v5 = require(v3:WaitForChild("Settings"))
local v14 = game.Players.LocalPlayer.PlayerGui.GameGui.Control.Values.Actions.DoingSomething
local v15 = v3:WaitForChild("Humanoid")
local v16 = v3:WaitForChild("Aspects")
local v19 = game.Players.LocalPlayer:GetMouse()
local v20 = game:GetService("UserInputService")
local v21 = game:GetService("TweenService")
local v24 = Instance.new("Animation")
v24.AnimationId = "http://www.roblox.com/asset/?id=9432946315"
v24 = v3.Humanoid:LoadAnimation(v24)
v24:Play()
v24:Stop()
local v29 = v3.Name
local v30 = game
local v31 = v30.Players
local v32 = v31.LocalPlayer
local v86 = v32.Name
if v29 ~= v86 then
	v30 = game.Players.LocalPlayer.PlayerGui.Menu
	v31 = v30.Menu
	v32 = v31.Values
	v86 = v32.KaijuModel
	v29 = v86.Changed
	v32 = function()
		v24:Stop(0)
		v15.WalkSpeed = v5.WalkSpeed
		v15.AutoRotate = true
		v14.Value = false
		script:Destroy()
	end
	v29:Connect(v32)
	v30 = game.Players.LocalPlayer.PlayerGui
	v31 = v30.Menu
	v86 = v31.Menu.EmoteScripts
	v86.ChildAdded:Connect(function()
		v24:Stop(0)
		v15.WalkSpeed = v5.WalkSpeed
		v15.AutoRotate = true
		v14.Value = false
		script:Destroy()
	end)
end
v24:Play()
v15.WalkSpeed = 0
v15.AutoRotate = false
v14.Value = true
wait(2)
v24:Stop(0.75)
v15.WalkSpeed = v5.WalkSpeed
v15.AutoRotate = true
v14.Value = false
wait(0.5)
script:Destroy()
local v66 = v3.Name
local v67 = game.Players.LocalPlayer
local v68 = v67.Name
if v66 == v68 then
	v67 = v16.Stun
	v68 = v67.Stunned
	v66 = v68.Changed
	v67 = function()
		local v70 = v16.Stun
		local v71 = v70.Stunned
		local v72 = v71.Value
		if v72 == true then
			v71 = v24
			v72 = v71.IsPlaying
			if not v72 then
				v72 = v24
				v70 = 0
				v72:Stop(v70)
				v71 = 0
				v15.WalkSpeed = v71
				v71 = false
				v15.AutoRotate = v71
				v71 = false
				v14.Value = v71
				script:Destroy()
			end
		end
	end
	v66:Connect(v67)
end
