local v3 = script.Char.Value
local v5 = require(v3:WaitForChild("Settings"))
local v14 = game.Players.LocalPlayer.PlayerGui.GameGui.Control.Values.Actions.DoingSomething
local v15 = v3:WaitForChild("Humanoid")
local v16 = v3:WaitForChild("Aspects")
local v19 = game.Players.LocalPlayer:GetMouse()
local v21 = game:GetService("TweenService")
local v24 = Instance.new("Animation")
v24.AnimationId = "http://www.roblox.com/asset/?id=9647450237"
v24 = v3.Humanoid:LoadAnimation(v24)
v24:Play()
v24:Stop()
v24:Play(0.35)
v15.WalkSpeed = 0
v15.AutoRotate = false
v14.Value = true
local v92 = v3.Name
local v32 = game
local v33 = v32.Players
local v34 = v33.LocalPlayer
local v93 = v34.Name
if v92 ~= v93 then
	v32 = game.Players.LocalPlayer.PlayerGui.Menu
	v33 = v32.Menu
	v34 = v33.Values
	v93 = v34.KaijuModel
	v92 = v93.Changed
	v34 = function()
		v24:Stop(0)
		v15.WalkSpeed = 0
		v15.AutoRotate = false
		v14.Value = false
		script:Destroy()
	end
	v92:Connect(v34)
	v32 = game.Players.LocalPlayer.PlayerGui
	v33 = v32.Menu
	v93 = v33.Menu.EmoteScripts
	v93.ChildAdded:Connect(function()
		v24:Stop(0)
		v15.WalkSpeed = 0
		v15.AutoRotate = false
		v14.Value = false
		script:Destroy()
	end)
end
local v59 = v3.Name
local v60 = game.Players.LocalPlayer
local v100 = v60.Name
if v59 == v100 then
	v59 = game:GetService("UserInputService").InputBegan
	v60 = function(p1, p2)
		if p2 == false then
			local v62 = v16.Stun
			local v63 = v62.Stunned
			local v64 = v63.Value
			if v64 == false then
				v63 = v14
				v64 = v63.Value
				if v64 == true then
					v63 = v24
					v64 = v63.IsPlaying
					if not v64 then
						v64 = p1.KeyCode
						v63 = Enum.KeyCode.Z
						if v64 ~= v63 then
							v64 = p1.KeyCode
							v63 = Enum.KeyCode.X
							if v64 ~= v63 then
								v64 = p1.KeyCode
								v63 = Enum.KeyCode.C
								if v64 ~= v63 then
									v64 = p1.KeyCode
									v63 = Enum.KeyCode.G
									if v64 ~= v63 then
										v64 = p1.KeyCode
										v63 = Enum.KeyCode.R
										if v64 ~= v63 then
											v64 = p1.KeyCode
											v63 = Enum.KeyCode.W
											if v64 ~= v63 then
												v64 = p1.KeyCode
												v63 = Enum.KeyCode.A
												if v64 ~= v63 then
													v64 = p1.KeyCode
													v63 = Enum.KeyCode.S
													if v64 ~= v63 then
														v64 = p1.KeyCode
														v63 = Enum.KeyCode.D
														if v64 == v63 then
															v64 = v24
															v62 = 0.35
															v64:Stop(v62)
															v63 = v5.WalkSpeed
															v15.WalkSpeed = v63
															v63 = true
															v15.AutoRotate = v63
															v63 = false
															v14.Value = v63
															v63 = 0.35
															wait(v63)
															script:Destroy()
														end
														return 
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	v59:Connect(v60)
	v100 = v16.Stun.Stunned
	v100.Changed:Connect(function()
		local v74 = v16.Stun
		local v75 = v74.Stunned
		local v76 = v75.Value
		if v76 == true then
			v75 = v24
			v76 = v75.IsPlaying
			if not v76 then
				v76 = v24
				v74 = 0
				v76:Stop(v74)
				v75 = 0
				v15.WalkSpeed = v75
				v75 = false
				v15.AutoRotate = v75
				v75 = false
				v14.Value = v75
				script:Destroy()
			end
		end
	end)
end
