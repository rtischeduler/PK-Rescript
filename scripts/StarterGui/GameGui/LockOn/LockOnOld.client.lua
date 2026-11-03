local v1 = script
v1 = workspace.CurrentCamera
local v8 = game.Players.LocalPlayer
local v10 = v8:WaitForChild("PlayerGui")
local v541 = v8.Character
if v541 then
	v541 = v8.CharacterAdded
	local v11 = v541:Wait()
end
local v15 = require(v11:WaitForChild("Settings"))
local v18 = v11:WaitForChild("Humanoid")
local v21 = v11:WaitForChild("HumanoidRootPart")
local v26 = game:GetService("UserInputService")
local v29 = game:GetService("RunService")
local v32 = v1.Parent:WaitForChild("Target")
local v35 = game:GetService("TweenService")
local v36 = v32.Mode
v1.CameraType = Enum.CameraType.Custom
v1.CameraSubject = v11.Humanoid
v11.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
local v43, v44, v45 = pairs(workspace:GetDescendants())
for v84, v47 in v43, v44, v45 do
	local v46 = v47.Name
	if v46 == "LockOnClick" then
		v46 = v26.TouchEnabled
		if v46 == false then
			v46 = v47.MouseHoverEnter
			v46:Connect(function()
				local v49 = v47
				local v52 = v49.Parent:FindFirstChild("HumanoidRootPart")
				if not v52 then
					v49 = script.Current
					v52 = v49.Value
					local v54 = v47
					local v55 = v54.Parent
					v49 = v55.HumanoidRootPart
					if v52 ~= v49 then
						v49 = v47
						v52 = v49.Parent
						v49 = v11
						if v52 ~= v49 then
							v49 = script
							v52 = v49.Current
							v54 = v47
							v55 = v54.Parent
							v49 = v55.HumanoidRootPart
							v52.Value = v49
						end
					end
				end
			end)
			v47.MouseHoverLeave:Connect(function()
				local v60 = script.Current.Value
				local v63 = v47.Parent.HumanoidRootPart
				if v60 == v63 then
					v63 = v47
					v60 = v63.Parent
					v63 = v11
					if v60 ~= v63 then
						v63 = script
						v60 = v63.Current
						v63 = nil
						v60.Value = v63
					end
				end
			end)
		else
			v47.MouseHoverEnter:Connect(function()
				local v66 = v47
				local v69 = v66.Parent:FindFirstChild("HumanoidRootPart")
				if not v69 then
					v66 = script.Current
					v69 = v66.Value
					local v71 = v47
					local v72 = v71.Parent
					v66 = v72.HumanoidRootPart
					if v69 ~= v66 then
						v66 = v47
						v69 = v66.Parent
						v66 = v11
						if v69 ~= v66 then
							v66 = script
							v69 = v66.Current
							v71 = v47
							v72 = v71.Parent
							v66 = v72.HumanoidRootPart
							v69.Value = v66
						end
					end
				end
			end)
			v47.MouseHoverLeave:Connect(function()
				local v77 = script.Current.Value
				local v78 = v47
				local v81 = v78.Parent
				local v82 = v81.HumanoidRootPart
				if v77 == v82 then
					v82 = v47
					v77 = v82.Parent
					v82 = v11
					if v77 ~= v82 then
						v77 = wait
						v82 = 3
						v77(v82)
						v81 = script
						local v80 = v81.Current.Value
						v78 = v47
						v81 = v78.Parent
						local v83 = v81.HumanoidRootPart
						if v80 == v83 then
							v83 = v47
							v80 = v83.Parent
							v83 = v11
							if v80 ~= v83 then
								v83 = script
								v80 = v83.Current
								v83 = nil
								v80.Value = v83
							end
						end
					end
				end
			end)
		end
	end
end
v44 = workspace
v43 = v44.ChildAdded
v45 = function(p1)
	if not p1:IsA("Model") then
		p1:WaitForChild("LockOnClick")
		local v91 = p1:FindFirstChild("LockOnClick")
		v91.MouseHoverEnter:Connect(function()
			local v94 = v91
			local v97 = v94.Parent:FindFirstChild("HumanoidRootPart")
			if not v97 then
				v94 = script.Current
				v97 = v94.Value
				local v99 = v91
				local v100 = v99.Parent
				v94 = v100.HumanoidRootPart
				if v97 ~= v94 then
					v94 = v91
					v97 = v94.Parent
					v94 = v11
					if v97 ~= v94 then
						v94 = script
						v97 = v94.Current
						v99 = v91
						v100 = v99.Parent
						v94 = v100.HumanoidRootPart
						v97.Value = v94
					end
				end
			end
		end)
		v91.MouseHoverLeave:Connect(function()
			local v105 = script.Current.Value
			local v108 = v91.Parent.HumanoidRootPart
			if v105 == v108 then
				v108 = v91
				v105 = v108.Parent
				v108 = v11
				if v105 ~= v108 then
					v108 = script
					v105 = v108.Current
					v108 = nil
					v105.Value = v108
				end
			end
		end)
	end
end
v43:Connect(v45)
v8:GetMouse().Button2Down:Connect(function()
	local v111 = v32
	local v112 = v111.Value
	if not v112 then
		v112 = v32
		v111 = nil
		v112.Value = v111
		v112 = v35
		local v117 = {}
		v117.FieldOfView = 60
		(v112:Create(game.Workspace.CurrentCamera, TweenInfo.new(0.3), v117)):Play()
		local v124 = {}
		v124.BackgroundTransparency = 1
		(v35:Create(script.Parent.LabelOne, TweenInfo.new(0.15), v124)):Play()
		local v132 = {}
		v132.BackgroundTransparency = 1
		(v35:Create(script.Parent.LabelTwo, TweenInfo.new(0.15), v132)):Play()
	end
end)
v47 = game.Players.LocalPlayer.PlayerGui.GameGui.Character.Cooldowns.Mobile
v84 = v47.Aspects
v44 = v84.LockOn.Button
v44.MouseButton1Down:Connect(function()
	local v153 = v32
	local v154 = v153.Value
	if v154 == nil then
		local v155 = script
		v153 = v155.Current
		v154 = v153.Value
		if not v154 then
			v155 = script
			v153 = v155.Current
			v154 = v153.Value
			v153 = v11
			if v154 ~= v153 then
				local v156 = script
				v155 = v156.Current
				v153 = v155.Value
				v154 = v153.Parent
				v153 = v11
				if v154 ~= v153 then
					local v157 = script
					v156 = v157.Current
					v155 = v156.Value
					v153 = v155.Parent
					v154 = v153.Parent
					v153 = v11
					if v154 ~= v153 then
						v153 = v26
						v154 = v153.MouseBehavior
						v153 = Enum.MouseBehavior.LockCenter
						if v154 ~= v153 then
							v155 = script
							v153 = v155.Current
							v154 = v153.Value
							if not v154 then
								v153 = v32
								v153.Value = v154
								v155 = v36
								v153 = v155.Value
								if v153 == "Third" then
									v153 = v1
									v155 = Enum.CameraType.Custom
									v153.CameraType = v155
								else
									v153 = v1
									v155 = Enum.CameraType.Scriptable
									v153.CameraType = v155
								end
								v153 = v35
								v157 = game.Workspace
								v156 = v157.CurrentCamera
								v157 = TweenInfo.new
								local v160 = {}
								v160.FieldOfView = 50
								(v153:Create(v156, v157(0.3), v160)):Play()
								local v167 = {}
								v167.BackgroundTransparency = 0
								(v35:Create(script.Parent.LabelOne, TweenInfo.new(0.15), v167)):Play()
								local v175 = {}
								v175.BackgroundTransparency = 0
								(v35:Create(script.Parent.LabelTwo, TweenInfo.new(0.15), v175)):Play()
								return 
							end
						end
					end
				end
			end
		end
	end
	v162 = nil
	v32.Value = v162
	v177 = game.Workspace
	v169 = v177.CurrentCamera
	v177 = TweenInfo.new
	local v181 = {}
	local v182 = 60
	v181.FieldOfView = v182
	(v35:Create(v169, v177(0.3), v181)):Play()
	while true do
		wait(0.01)
		v182 = script.Parent
		script.Parent.LabelOne.BackgroundTransparency = v182.LabelOne.BackgroundTransparency + 0.15
		v182 = script.Parent
		script.Parent.LabelTwo.BackgroundTransparency = v182.LabelTwo.BackgroundTransparency + 0.15
		local v210 = script
		local v211 = v210.Parent
		local v213 = v211.LabelOne.BackgroundTransparency
		local v214 = 0
		if v213 >= v214 then
			v210 = script
			v211 = v210.Parent
			v214 = v211.LabelTwo
			v213 = v214.BackgroundTransparency
			v214 = 1
			if v214 < v213 then
				break
			end
		end
	end
end)
v26.InputBegan:Connect(function(p2, p3)
	local v217 = p2.KeyCode
	local v218 = Enum.KeyCode.DPadRight
	if v217 == v218 then
		break
	end
	v217 = v36
	v218 = "Third"
	v217.Value = v218
	local v255 = v32
	local v256 = v255.Value
	if v256 == nil then
		local v219 = script
		v255 = v219.Current
		v256 = v255.Value
		if not v256 then
			v219 = script
			v255 = v219.Current
			v256 = v255.Value
			v255 = v11
			if v256 ~= v255 then
				local v220 = script
				v219 = v220.Current
				v255 = v219.Value
				v256 = v255.Parent
				v255 = v11
				if v256 ~= v255 then
					local v221 = script
					v220 = v221.Current
					v219 = v220.Value
					v255 = v219.Parent
					v256 = v255.Parent
					v255 = v11
					if v256 ~= v255 then
						v255 = v26
						v256 = v255.MouseBehavior
						v255 = Enum.MouseBehavior.LockCenter
						if v256 ~= v255 then
							v219 = script
							v255 = v219.Current
							v256 = v255.Value
							if not v256 then
								v255 = v32
								v255.Value = v256
								v219 = v36
								v255 = v219.Value
								if v255 == "Third" then
									v255 = v1
									v219 = Enum.CameraType.Custom
									v255.CameraType = v219
								else
									v255 = v1
									v219 = Enum.CameraType.Scriptable
									v255.CameraType = v219
								end
								v255 = v35
								v221 = game.Workspace
								v220 = v221.CurrentCamera
								v221 = TweenInfo.new
								local v224 = {}
								v224.FieldOfView = 50
								(v255:Create(v220, v221(0.3), v224)):Play()
								local v231 = {}
								v231.BackgroundTransparency = 0
								(v35:Create(script.Parent.LabelOne, TweenInfo.new(0.15), v231)):Play()
								local v239 = {}
								v239.BackgroundTransparency = 0
								(v35:Create(script.Parent.LabelTwo, TweenInfo.new(0.15), v239)):Play()
								return 
							end
						end
					end
				end
			end
		end
	end
	local v264 = p2.KeyCode
	v226 = Enum.KeyCode.DPadRight
	if v264 == v226 then
		break
	end
	v264 = v32
	v226 = nil
	v264.Value = v226
	v241 = game.Workspace
	v233 = v241.CurrentCamera
	v241 = TweenInfo.new
	local v245 = {}
	local v246 = 60
	v245.FieldOfView = v246
	(v35:Create(v233, v241(0.3), v245)):Play()
	while true do
		wait(0.01)
		v246 = script.Parent
		script.Parent.LabelOne.BackgroundTransparency = v246.LabelOne.BackgroundTransparency + 0.15
		v246 = script.Parent
		script.Parent.LabelTwo.BackgroundTransparency = v246.LabelTwo.BackgroundTransparency + 0.15
		local v276 = script
		local v277 = v276.Parent
		local v279 = v277.LabelOne.BackgroundTransparency
		local v280 = 0
		if v279 >= v280 then
			v276 = script
			v277 = v276.Parent
			v280 = v277.LabelTwo
			v279 = v280.BackgroundTransparency
			v280 = 1
			if v280 < v279 then
				break
			end
		end
	end
end)
InputBeganEvent = v26.InputBegan:Connect(function(p4, p5)
	if p5 == false then
		local v283 = p4.KeyCode
		local v284 = Enum.KeyCode
		local v285 = game
		local v286 = v285.Players
		local v287 = v286.LocalPlayer
		local v288 = v287.Settings
		local v289 = v288.Keybinds
		local v290 = v289.LockOnSwap
		local v291 = v290.Value
		local v292 = v284[v291]
		if v283 == v292 then
			v292 = v36
			v283 = v292.Value
			if v283 == "Third" then
				v283 = v36
				v292 = "Side"
				v283.Value = v292
			else
				v283 = v36
				v292 = "Third"
				v283.Value = v292
			end
		end
		local v340 = p4.KeyCode
		local v341 = Enum.KeyCode.LeftControl
		if v340 ~= v341 then
			v340 = p4.KeyCode
			v341 = Enum.KeyCode.RightControl
			if v340 == v341 then
				v341 = v32
				v340 = v341.Value
				if not v340 then
					v340 = v32
					v341 = nil
					v340.Value = v341
					v340 = v35
					v290 = game
					v291 = v290.Workspace
					v284 = v291.CurrentCamera
					v291 = TweenInfo.new
					v290 = 0.3
					local v294 = {}
					v289 = 60
					v294.FieldOfView = v289
					(v340:Create(v284, v291(v290), v294)):Play()
					v289 = script
					v289 = 0.15
					local v300 = {}
					v288 = 1
					v300.BackgroundTransparency = v288
					(v35:Create(v289.Parent.LabelOne, TweenInfo.new(v289), v300)):Play()
					v288 = script
					v288 = 0.15
					local v307 = {}
					v287 = 1
					v307.BackgroundTransparency = v287
					(v35:Create(v288.Parent.LabelTwo, TweenInfo.new(v288), v307)):Play()
				end
			end
			v295 = p4.KeyCode
			v308 = Enum.KeyCode
			v285 = game
			v286 = v285.Players
			v287 = v286.LocalPlayer
			local v310 = v287.Settings
			local v311 = v310.Keybinds
			local v312 = v311.LockOn
			local v313 = v312.Value
			v301 = v308[v313]
			if v295 == v301 then
				v301 = v32
				v295 = v301.Value
				if not v295 then
					v295 = v32
					v301 = nil
					v295.Value = v301
					v295 = v35
					v312 = game
					v313 = v312.Workspace
					v308 = v313.CurrentCamera
					v313 = TweenInfo.new
					v312 = 0.3
					local v315 = {}
					v311 = 60
					v315.FieldOfView = v311
					local v316 = v295:Create(v308, v313(v312), v315)
					v316:Play()
					while true do
						wait(0.01)
						v310 = script
						v311 = v310.Parent
						script.Parent.LabelOne.BackgroundTransparency = v311.LabelOne.BackgroundTransparency + 0.15
						v310 = script
						v311 = v310.Parent
						script.Parent.LabelTwo.BackgroundTransparency = v311.LabelTwo.BackgroundTransparency + 0.15
						local v355 = script.Parent.LabelOne.BackgroundTransparency
						local v356 = 0
						local v360 = script.Parent.LabelTwo.BackgroundTransparency
						local v361 = 1
					end
					return 
						v320 = script
					v321 = v320.Current
					v316 = v321.Value
					if not v316 then
						v320 = script
						v321 = v320.Current
						v316 = v321.Value
						v321 = v11
						if v316 ~= v321 then
							v319 = script
							v320 = v319.Current
							v321 = v320.Value
							v316 = v321.Parent
							v321 = v11
							if v316 ~= v321 then
								v322 = script
								v319 = v322.Current
								v320 = v319.Value
								v321 = v320.Parent
								v316 = v321.Parent
								v321 = v11
								if v316 ~= v321 then
									v321 = v26
									v316 = v321.MouseBehavior
									v321 = Enum.MouseBehavior.LockCenter
									if v316 ~= v321 then
										v320 = script
										v321 = v320.Current
										v316 = v321.Value
										if not v316 then
											v321 = v32
											v321.Value = v316
											v320 = v36
											v321 = v320.Value
											if v321 == "Third" then
												v321 = v1
												v320 = Enum.CameraType.Custom
												v321.CameraType = v320
											else
												v321 = v1
												v320 = Enum.CameraType.Scriptable
												v321.CameraType = v320
											end
											v321 = v35
											v311 = game
											v322 = v311.Workspace
											v319 = v322.CurrentCamera
											v322 = TweenInfo.new
											v311 = 0.3
											local v324 = {}
											v310 = 50
											v324.FieldOfView = v310
											(v321:Create(v319, v322(v311), v324)):Play()
											v310 = script
											v310 = 0.15
											local v330 = {}
											v287 = 0
											v330.BackgroundTransparency = v287
											(v35:Create(v310.Parent.LabelOne, TweenInfo.new(v310), v330)):Play()
											v287 = script
											v287 = 0.15
											local v337 = {}
											v286 = 0
											v337.BackgroundTransparency = v286
											(v35:Create(v287.Parent.LabelTwo, TweenInfo.new(v287), v337)):Play()
										end
									end
								end
							end
						end
					end
					if v320 < v321 then
					end
					return 
						if v321 >= v320 then
				end
			end
		end
	end
end
	end)
	v36.Changed:Connect(function()
		local v366 = v32
		local v367 = v366.Value
		if not v367 then
		v366 = v36
		v367 = v366.Value
		if v367 == "Third" then
			v367 = v1
			v366 = Enum.CameraType.Custom
			v367.CameraType = v366
			return 
		end
		v367 = v1
		v366 = Enum.CameraType.Scriptable
		v367.CameraType = v366
	end
	end)
	v84 = script
	v44 = v84.Parent.Target
	v44.Changed:Connect(function()
		local v370 = script
		local v371 = v370.Parent
		local v372 = v371.Target
		local v373 = v372.Value
		if v373 == nil then
		v372 = v11
		v373 = v372.Humanoid
		v371 = 0
		v370 = v11.HumanoidRootPart.Size.Y * 0.75
		v372 = Vector3.new
		v373.CameraOffset = v372(v371, v370, 0)
		v373 = v18
		v373.AutoRotate = false
	end
		v378 = 0.15
		wait(v378)
		local v379 = script
		local v380 = v379.Parent
		local v381 = v380.Target
		local v382 = v381.Value
		if v382 == nil then
		v382 = v1
		v381 = Enum.CameraType.Custom
		v382.CameraType = v381
		v382 = v1
		v380 = v11
		v381 = v380.Humanoid
		v382.CameraSubject = v381
		v381 = v11
		v382 = v381.Humanoid
		v380 = 0
		v379 = 0
		v381 = Vector3.new
		v382.CameraOffset = v381(v380, v379, 0)
		local v385 = v11
		local v386 = v385.Aspects
		local v387 = v386.Stun
		local v391 = v387.Stunned
		v382 = v391.Value
		if v382 == false then
			v385 = v11
			v386 = v385.Aspects
			v387 = v386.Stun
			v391 = v387.Grabbed
			v382 = v391.Value
			if v382 == false then
				v385 = v11
				v386 = v385.Aspects
				v387 = v386.Stun
				v391 = v387.Knockdown
				v382 = v391.Value
				if v382 == false then
					v374 = script
					v375 = v374.Parent
					v376 = v375.Parent
					v385 = v376.Control
					v386 = v385.Values
					v387 = v386.Actions
					v391 = v387.DoingSomething
					v382 = v391.Value
					if v382 == false then
						v391 = v18
						v382 = v391.WalkSpeed
						v391 = 0
						if v382 > v391 then
							v382 = v18
							v391 = true
							v382.AutoRotate = v391
						end
					end
				end
			end
		end
	end
	end)
	v18.Died:Connect(function()
		local v394 = v32
		local v395
		v394.Value = v395
		while true do
		v394 = wait
		v395 = 0.01
		v394(v395)
		script.Parent.LabelOne.BackgroundTransparency = script.Parent.LabelOne.BackgroundTransparency + 0.15
		script.Parent.LabelTwo.BackgroundTransparency = script.Parent.LabelTwo.BackgroundTransparency + 0.15
		local v412 = script
		local v413 = v412.Parent
		local v415 = v413.LabelOne.BackgroundTransparency
		local v416 = 0
		if v415 >= v416 then
			v412 = script
			v413 = v412.Parent
			v416 = v413.LabelTwo
			v415 = v416.BackgroundTransparency
			v416 = 1
			if v416 < v415 then
				break
			end
		end
	end
	end)
	game:GetService("RunService").Stepped:Connect(function()
		local v419 = v36
		local v420 = v419.Value
		if v420 == "Third" then
		v419 = v32
		v420 = v419.Value
		if not v420 then
			v419 = v32
			v420 = v419.Value
			if not v420 then
				v420 = v26
				local v422 = v420:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
				if v422 == false then
					local v425 = script.Parent.Parent
					local v426 = v425.UIFunctions
					local v427 = v426.FireFunctions
					local v428 = v427.CooldownsTime
					v419 = v428.ScreenShaking
					v422 = v419.Value
					if v422 == false then
						v426 = v11
						v427 = v426.Aspects
						v428 = v427.Stun
						v419 = v428.Grabbed
						v422 = v419.Value
						if v422 == true then
							v422 = v1
							v427 = v11
							v428 = v427.HumanoidRootPart
							v419 = v428.CFrame
							v422.CFrame = v419
							else
							v422 = v1
							v419 = CFrame.new
							v426 = v1
							v427 = v426.CFrame
							v428 = v427.Position
							v425 = v32
							v426 = v425.Value
							v427 = v426.Position
							v422.CFrame = v419(v428, v427)
						end
					end
				end
			end
			v429 = v32
			v422 = v429.Value
			if not v422 then
				local v430 = v11
				v429 = v430.HumanoidRootPart
				v422 = v429.Anchored
				if v422 == false then
					v426 = v11
					local v431 = v426.Aspects
					v430 = v431.Stun
					v429 = v430.Knockdown
					v422 = v429.Value
					if v422 == false then
						v426 = v11
						v431 = v426.Aspects
						v430 = v431.Stun
						v429 = v430.Stunned
						v422 = v429.Value
						if v422 == false then
							v426 = v11
							v431 = v426.Aspects
							v430 = v431.Stun
							v429 = v430.Grabbed
							v422 = v429.Value
							if v422 == false then
								v429 = v11
								v422 = v429.HumanoidRootPart
								v430 = "BodyVelocity"
								local v432 = v422:FindFirstChildOfClass(v430)
								if v432 == nil then
									v432 = v18
									v429 = false
									v432.AutoRotate = v429
									v429 = v11
									v432 = v429.Humanoid
									v426 = v21
									v431 = v426.Size
									v424 = v21
									v425 = v424.Size
									v426 = v425.Y
									v431 = v426 / 2
									v426 = 0
									v429 = Vector3.new
									v432.CameraOffset = v429(v431.Y, v431, v426)
									v432 = v11.HumanoidRootPart
									v424 = v11
									v425 = v424.HumanoidRootPart
									v423 = v32.Value.Position
									v424 = v423.X
									v423 = v11.HumanoidRootPart.Position.Y
									v425 = Vector3.new
									v432.CFrame = v11.HumanoidRootPart.CFrame:lerp(CFrame.new(v425.Position, v425(v424, v423, v32.Value.Position.Z)), 1)
								end
							end
						end
					end
				end
			end
		end
	end
		v444 = v36
		v432 = v444.Value
		if v432 == "Side" then
		v444 = v32
		v432 = v444.Value
		if not v432 then
			v444 = v32
			v432 = v444.Value
			if not v432 then
				v432 = v26
				v436 = Enum.UserInputType.MouseButton2
				local v445 = v432:IsMouseButtonPressed(v436)
				if v445 == false then
					v445 = Instance.new
					v444 = "Part"
					local v447 = v445(v444, workspace)
					v447.Anchored = true
					v447.Transparency = 1
					v447.CanCollide = false
					v447.CFrame = v11.HumanoidRootPart.CFrame
					v438 = v32
					v447.CFrame = CFrame.new(v447.Position, Vector3.new(v32.Value.Position.X, v447.Position.Y, v438.Value.Position.Z))
					local v510 = v11.HumanoidRootPart.Position - v32.Value.Position.Magnitude
					local v462 = Instance.new("Part", workspace)
					v462.CFrame = v447.CFrame * CFrame.new(0, 0, v510 * -0.5)
					local v518 = v462.Position
					v462.Anchored = true
					v462.Transparency = 1
					v462.CanCollide = false
					v438 = v510 * 0.75
					v438 = 5
					v440 = v510 * 0.085
					v438 = 0
					v462.CFrame = v462.CFrame * CFrame.new(80 + v438, v438 + v440, v438)
					v462.CFrame = CFrame.new(v462.Position, Vector3.new(v518.X, v462.Position.Y, v518.Z))
					workspace.CurrentCamera.CFrame = v462.CFrame
					v462:Destroy()
					v447:Destroy()
				end
			end
			v456 = v32
			v447 = v456.Value
			if not v447 then
				v462 = v11
				v456 = v462.HumanoidRootPart
				v447 = v456.Anchored
				if v447 == false then
					local v476 = v11
					v465 = v476.Aspects
					v462 = v465.Stun
					v456 = v462.Knockdown
					v447 = v456.Value
					if v447 == false then
						v476 = v11
						v465 = v476.Aspects
						v462 = v465.Stun
						v456 = v462.Stunned
						v447 = v456.Value
						if v447 == false then
							v476 = v11
							v465 = v476.Aspects
							v462 = v465.Stun
							v456 = v462.Grabbed
							v447 = v456.Value
							if v447 == false then
								v456 = v11
								v447 = v456.HumanoidRootPart
								v462 = "BodyVelocity"
								local v477 = v447:FindFirstChildOfClass(v462)
								if v477 == nil then
									v477 = v18
									v456 = false
									v477.AutoRotate = v456
									v456 = v11
									v477 = v456.Humanoid
									v465 = 0
									v476 = 0
									v456 = Vector3.new
									v477.CameraOffset = v456(0, v465, v476)
									v477 = v11.HumanoidRootPart
									v474 = v11.HumanoidRootPart
									v440 = v11
									v441 = v32
									v440 = v441.Value
									v474 = Vector3.new
									v477.CFrame = v11.HumanoidRootPart.CFrame:lerp(CFrame.new(v474.Position, v474(v32.Value.Position.X, v440.HumanoidRootPart.Position.Y, v440.Position.Z)), 1)
								end
							end
						end
					end
				end
			end
		end
	end
	end)
