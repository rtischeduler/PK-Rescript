local v1 = {}
local v4 = game:GetService("TweenService")
local function v5(p1, p2)
	local v9 = require(p1:WaitForChild("Settings"))
	local v12 = tostring(p2)
	local v13 = false
	local v14 = false
	local v17 = p1.TeamBrick.CFrame.Y
	local v18 = workspace
	local v19 = v18.Map
	local v20 = v19.WaterSpot
	local v133 = v20.CFrame
	local v134 = v133.Y
	if v134 > v17 then
		v14 = true
	end
	if v14 == false then
		v17 = string.gsub
		v134 = v12
		v133 = "Enum.Material."
		v20 = ""
		v12 = v17(v134, v133, v20)
		local v22 = script
		local v24, v25, v22 = pairs(v22.Sounds:GetChildren())
		for v28, v19 in v24, v25, v22 do
			v18 = v19.Name
			if v18 == v12 then
				local v26 = v19:Clone()
				v26.Parent = p1.Torso
				v26:Destroy()
			end
		end
	else
		v22 = script
		v25 = v22.Sounds
		v24 = v25.Glass
		local v29 = v24:Clone()
		v25 = p1.Torso
		v29.Parent = v25
		v29:Destroy()
	end
	local function Stomp_1()
		local v31 = v13
		if v31 == false then
			v31 = Instance.new
			local v36 = v31("Part", workspace.CharacterStuff.Hitboxes)
			v36.Anchored = false
			v36.CanCollide = true
			v36.Transparency = 1
			v36.Massless = true
			local v38 = p1
			local v41 = p1
			local v42 = v41.HumanoidRootPart
			v36.Size = Vector3.new(v38.HumanoidRootPart.Size.X * 1.25, 35, v42.Size.Z * 1.25)
			v36.CFrame = p1.HumanoidRootPart.CFrame
			v36.CFrame = CFrame.new(v36.CFrame.X, v36.CFrame.Y - v9.HipHeight * 1.25, v36.CFrame.Z)
			v36.Anchored = true
			v36.CanCollide = false
			local v51, v52, v53 = pairs(v36:GetTouchingParts())
			for v39, v38 in v51, v52, v53 do
				v42 = v13
				if v42 == false then
					v42 = v38.Parent
					v41 = p1
					if v42 ~= v41 then
						v42 = v38.Parent
						local v55 = v42:FindFirstChild("Aspects")
						if not v55 then
							local v56 = v38.Parent
							v41 = v56.Aspects.Info.Weight
							v55 = v41.Value
							local v59 = p1
							local v60 = v59.Aspects
							local v104 = v60.Info
							local v105 = v104.Weight
							local v106 = v105.Value
							v41 = v106 - 1
							if v41 >= v55 then
								v104 = v38.Parent
								v105 = v104.Aspects
								v106 = v105.Info
								v41 = v106.Health
								v55 = v41.Value
								v41 = 0
								if v55 > v41 then
									v106 = v38.Parent
									v41 = v106.HumanoidRootPart
									v55 = v41.Anchored
									if v55 == true then
										v55 = true
										v13 = v55
										v105 = v38.Parent
										v106 = v105.Aspects
										v41 = v106.Info
										v55 = v41.Health
										v59 = v38.Parent
										v60 = v59.Aspects
										v104 = v60.Info
										v105 = v104.Health
										v106 = v105.Value
										v41 = v106 - 50
										v55.Value = v41
										v106 = p1
										v41 = v106.HumanoidRootPart
										v55 = v41.Hit
										v55:Play()
										if not v38 then
											local v61 = v38.Parent
											if not v61 then
												v104 = v38.Parent
												v105 = v104.Aspects
												v106 = v105.Info
												v41 = v106.Health
												v61 = v41.Value
												v41 = 0
												if v41 >= v61 then
													v61 = pairs
													v106 = game
													v41 = v106.Players
													local v62, v63, v58 = v61(v41:GetPlayers())
													for v57, v56 in v62, v63, v106 do
														v60 = v56.PlayerGui
														local v65 = v60:FindFirstChild("GameGui")
														if not v65 then
															v59 = game.ReplicatedStorage.Assets.Kaijus.UI.Feed
															v65 = v59.FeedAsset
															local v71 = v65:Clone()
															v59 = v71.AttackerName
															v59.Text = p1.Name
															v59 = v71.PlayerName
															v59.Text = v38.Parent.Name
															v59 = require
															v71.AttackerImage.KaijuImage.Image = v9.KaijuImage
															v71.PlayerImage.KaijuImage.Image = v59(v38.Parent:WaitForChild("Settings")).KaijuImage
															v71.Parent = v56.PlayerGui.GameGui.Character.Feed
															game.Players:GetPlayerFromCharacter(p1).Stats.K.Value = game.Players:GetPlayerFromCharacter(p1).Stats.K.Value + 1
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
			v36:Destroy()
		end
	end
	Stomp_1()
	v22 = 0.05
	wait(v22)
	Stomp_1()
end
v1.Step = v5
v5 = function(p3)
	local v139 = game.Players:GetPlayerFromCharacter(p3)
	local v142 = require(p3:WaitForChild("Settings"))
	local v143 = p3.Head
	local v144 = v143.Roar
	local v239 = false
	local v145
	local v200 = p3.Aspects
	local v202, v203, v200 = pairs(v200.Stun:GetChildren())
	for v217, v206 in v202, v203, v200 do
		local v207 = v206:IsA("BoolValue")
		if not v207 then
			v207 = v206.Changed
			v207:Connect(function()
				local v209 = v206
				local v210 = v209.Value
				if v210 == true then
					v210 = v143
					if v210 == false then
						v209 = v139.PlayerGui.GameGui.Control.Values.Actions.Roaring
						v210 = v209.Value
						if v210 == true then
							v210 = function()
								local v148 = v143
								if v148 == false then
									v148 = true
									v143 = v148
									v148 = v144
									v148:Stop()
									local v149 = v139
									v149.Character.Aspects.Defense.Armor.Value = false
									p3.Aspects.Defense.Roaring.Value = false
									v139.PlayerGui.GameGui.Control.Values.Actions.Roaring.Value = false
									v139.PlayerGui.GameGui.Control.Values.Actions.DoingSomething.Value = false
									local v185 = p3.RoarFXPart
									local v156, v157, v151 = pairs(v185.ROARFX:GetDescendants())
									for v150, v149 in v156, v157, v185 do
										local v159 = v149:IsA("ParticleEmitter")
										if not v159 then
											v159 = false
											v149.Enabled = v159
										end
									end
									v156 = wait
									v157 = 5
									v156(v157)
									v159 = v139.PlayerGui.GameGui
									v185 = v159.Control.Values.Actions
									v185.Roaring.Delay.Value = false
									v159 = v139.PlayerGui.GameGui
									v159.Control.Values.Cooldowns.Roar.Delay.Value = false
								end
							end
							v210()
						end
					end
				end
			end)
		end
	end
	local v218 = v139.PlayerGui
	local v219 = v218.GameGui
	v206 = v219.Control
	v217 = v206.Values
	v200 = v217.Actions
	v203 = v200.Roaring
	v202 = v203.Value
	if v202 == false then
		if v239 == false then
			v217 = v139.Character
			v200 = v217.Aspects
			v203 = v200.Defense
			v202 = v203.Armor
			v203 = true
			v202.Value = v203
			v218 = v139.PlayerGui
			v219 = v218.GameGui
			v206 = v219.Control
			v217 = v206.Values
			v200 = v217.Actions
			v203 = v200.Roaring
			v202 = v203.Delay
			v203 = true
			v202.Value = v203
			v219 = v139.PlayerGui
			v206 = v219.GameGui
			v217 = v206.Control
			v200 = v217.Values
			v203 = v200.Actions
			v202 = v203.Roaring
			v203 = true
			v202.Value = v203
			v218 = v139.PlayerGui
			v219 = v218.GameGui
			v206 = v219.Control
			v217 = v206.Values
			v200 = v217.Cooldowns
			v203 = v200.Roar
			v202 = v203.Delay
			v203 = true
			v202.Value = v203
			v219 = v139.PlayerGui
			v206 = v219.GameGui
			v217 = v206.Control
			v200 = v217.Values
			v203 = v200.Actions
			v202 = v203.DoingSomething
			v203 = true
			v202.Value = v203
			v200 = p3.Aspects
			v203 = v200.Defense
			v202 = v203.Roaring
			v203 = true
			v202.Value = v203
			v202 = wait
			v203 = v142.RoarAudioDelay
			v202(v203)
			v217 = p3.Aspects
			v200 = v217.Stun
			if v200.Stunned.Value == false then
				v144:Play()
			end
			wait(v142.RoarStartTime)
			v217 = p3.Aspects
			v200 = v217.Stun
			local v223 = v200.Stunned
			local v224 = v223.Value
			if v224 == false then
				v224 = pairs
				v200 = p3.RoarFXPart
				v223 = v200.ROARFX
				local v225, v226, v200 = v224(v223:GetDescendants())
				for v217, v206 in v225, v226, v200 do
					local v228 = v206:IsA("ParticleEmitter")
					if not v228 then
						v228 = true
						v206.Enabled = v228
					end
				end
			end
			v225 = wait
			v226 = v142.RoarTime
			v225(v226)
			v200 = p3.RoarFXPart
			local v231, v232, v200 = pairs(v200.ROARFX:GetDescendants())
			for v217, v206 in v231, v232, v200 do
				local v234 = v206:IsA("ParticleEmitter")
				if not v234 then
					v234 = false
					v206.Enabled = v234
				end
			end
			if v239 == false then
				v217 = v139.Character
				v200 = v217.Aspects
				v232 = v200.Defense
				v231 = v232.Armor
				v232 = false
				v231.Value = v232
				v200 = p3.Aspects
				v232 = v200.Defense
				v231 = v232.Roaring
				v232 = false
				v231.Value = v232
				v234 = v139.PlayerGui
				v206 = v234.GameGui
				v217 = v206.Control
				v200 = v217.Values
				v232 = v200.Actions
				v231 = v232.Roaring
				v232 = false
				v231.Value = v232
				v234 = v139.PlayerGui
				v206 = v234.GameGui
				v217 = v206.Control
				v200 = v217.Values
				v232 = v200.Actions
				v231 = v232.DoingSomething
				v232 = false
				v231.Value = v232
				v231 = wait
				v232 = 5
				v231(v232)
				if v145 == nil then
					v145:Destroy()
					v145 = nil
				end
				v218 = v139.PlayerGui
				v234 = v218.GameGui
				v206 = v234.Control
				v217 = v206.Values
				v200 = v217.Cooldowns
				v200.Roar.Delay.Value = false
				v218 = v139.PlayerGui
				v234 = v218.GameGui
				v206 = v234.Control
				v217 = v206.Values
				v200 = v217.Actions
				v200.Roaring.Delay.Value = false
				return 
			end
		end
	end
end
v1.Roar = v5
v5 = function(p4)
	local v248 = game.Players:GetPlayerFromCharacter(p4)
	local v251 = require(p4:WaitForChild("Settings"))
	p4.Aspects.Info.Stamina.Changed:Connect(function()
		local v256 = p4
		local v257 = v256.Aspects
		local v258 = v257.Info
		local v260 = v258.Stamina.Value
		local v264 = 0
		if v264 >= v260 then
			local v262 = v248.PlayerGui
			local v263 = v262.GameGui
			v256 = v263.Control
			v257 = v256.Values
			v258 = v257.Actions
			v264 = v258.Blocking
			v260 = v264.Value
			if v260 == true then
				v262 = v248
				v263 = v262.PlayerGui
				v256 = v263.GameGui
				v257 = v256.Control
				v258 = v257.Values
				v264 = v258.Actions
				v260 = v264.Blocking
				v264 = false
				v260.Value = v264
				v262 = v248
				v263 = v262.PlayerGui
				v256 = v263.GameGui
				v257 = v256.Control
				v258 = v257.Values
				v264 = v258.Actions
				v260 = v264.DoingSomething
				v264 = false
				v260.Value = v264
				v256 = v248
				v257 = v256.Character
				v258 = v257.Aspects
				v264 = v258.Defense
				v260 = v264.Blocking
				v264 = false
				v260.Value = v264
				v257 = p4
				v258 = v257.HumanoidRootPart
				v264 = v258.Attachment
				v260 = v264.BlockFX
				v264 = false
				v260.Enabled = v264
				v257 = p4
				v258 = v257.HumanoidRootPart
				v264 = v258.Attachment
				v260 = v264.BlockCircle
				v264 = false
				v260.Enabled = v264
				v257 = p4
				v258 = v257.Aspects
				v264 = v258.Info
				v260 = v264.Stamina
				v264 = 0
				v260.Value = v264
			end
		end
	end)
	local v266 = p4.Aspects
	local v267, v268, v266 = pairs(v266.Stun:GetChildren())
	for v252, v270 in v267, v268, v266 do
		v270.Changed:Connect(function()
			local v272 = v270
			local v273 = v272.Value
			if v273 == true then
				local v275 = v248.PlayerGui
				local v276 = v275.GameGui
				local v277 = v276.Control
				local v278 = v277.Values
				local v279 = v278.Actions
				v272 = v279.Blocking
				v273 = v272.Value
				if v273 == true then
					v275 = v248
					v276 = v275.PlayerGui
					v277 = v276.GameGui
					v278 = v277.Control
					v279 = v278.Values
					v272 = v279.Actions
					v273 = v272.Blocking
					v272 = false
					v273.Value = v272
					v275 = v248
					v276 = v275.PlayerGui
					v277 = v276.GameGui
					v278 = v277.Control
					v279 = v278.Values
					v272 = v279.Actions
					v273 = v272.DoingSomething
					v272 = false
					v273.Value = v272
					v277 = v248
					v278 = v277.Character
					v279 = v278.Aspects
					v272 = v279.Defense
					v273 = v272.Blocking
					v272 = false
					v273.Value = v272
					v278 = p4
					v279 = v278.HumanoidRootPart
					v272 = v279.Attachment
					v273 = v272.BlockFX
					v272 = false
					v273.Enabled = v272
					v278 = p4
					v279 = v278.HumanoidRootPart
					v272 = v279.Attachment
					v273 = v272.BlockCircle
					v272 = false
					v273.Enabled = v272
				end
			end
		end)
	end
	local v281 = v248.PlayerGui.GameGui
	v270 = v281.Control
	local v287 = v270.Values
	v266 = v287.Actions
	v268 = v266.Blocking
	v267 = v268.Value
	if v267 == false then
		v270 = v248.Character
		v287 = v270.Aspects
		v266 = v287.Stun
		v268 = v266.Stunned
		v267 = v268.Value
		if v267 == false then
			v270 = v248.Character
			v287 = v270.Aspects
			v266 = v287.Stun
			v268 = v266.Grabbed
			v267 = v268.Value
			if v267 == false then
				v270 = v248.Character
				v287 = v270.Aspects
				v266 = v287.Stun
				v268 = v266.Knockdown
				v267 = v268.Value
				if v267 == false then
					v281 = v248.PlayerGui
					v270 = v281.GameGui
					v287 = v270.Control
					v266 = v287.Values
					v268 = v266.Actions
					v267 = v268.Blocking
					v268 = true
					v267.Value = v268
					v281 = v248.PlayerGui
					v270 = v281.GameGui
					v287 = v270.Control
					v266 = v287.Values
					v268 = v266.Actions
					v267 = v268.DoingSomething
					v268 = true
					v267.Value = v268
					v270 = v248.Character
					v287 = v270.Aspects
					v266 = v287.Stun
					v268 = v266.Stunned
					v267 = v268.Value
					if v267 == false then
						v270 = v248.Character
						v287 = v270.Aspects
						v266 = v287.Stun
						v268 = v266.Grabbed
						v267 = v268.Value
						if v267 == false then
							v270 = v248.Character
							v287 = v270.Aspects
							v266 = v287.Stun
							v268 = v266.Knockdown
							v267 = v268.Value
							if v267 == false then
								v266 = p4.Aspects
								v268 = v266.Defense
								v267 = v268.Blocking
								v268 = true
								v267.Value = v268
								v266 = p4.HumanoidRootPart
								v268 = v266.Attachment
								v267 = v268.BlockFX
								v268 = true
								v267.Enabled = v268
								v266 = p4.HumanoidRootPart
								v268 = v266.Attachment
								v267 = v268.BlockCircle
								v268 = true
								v267.Enabled = v268
							end
						end
					end
					return 
				end
			end
		end
	end
	local v289 = v248.PlayerGui.GameGui
	v270 = v289.Control
	local v290 = v270.Values
	local v291 = v290.Actions
	v268 = v291.Blocking
	v267 = v268.Value
	if v267 == true then
		v270 = v248.Character
		v290 = v270.Aspects
		v291 = v290.Stun
		v268 = v291.Stunned
		v267 = v268.Value
		if v267 == false then
			v270 = v248.Character
			v290 = v270.Aspects
			v291 = v290.Stun
			v268 = v291.Grabbed
			v267 = v268.Value
			if v267 == false then
				v270 = v248.Character
				v290 = v270.Aspects
				v291 = v290.Stun
				v268 = v291.Knockdown
				v267 = v268.Value
				if v267 == false then
					v267 = wait
					v268 = 0.45
					v267(v268)
					v291 = p4.Aspects
					v291.Defense.Blocking.Value = false
					v291 = p4.HumanoidRootPart
					v291.Attachment.BlockFX.Enabled = false
					v291 = p4.HumanoidRootPart
					v291.Attachment.BlockCircle.Enabled = false
					v289 = v248.PlayerGui
					v270 = v289.GameGui
					v290 = v270.Control
					v291 = v290.Values
					v291.Actions.Blocking.Value = false
					v289 = v248.PlayerGui
					v270 = v289.GameGui
					v290 = v270.Control
					v291 = v290.Values
					v291.Actions.DoingSomething.Value = false
					return 
				end
			end
		end
	end
end
v1.Block = v5
v5 = function(p5, p6, p7, p8)
	local v308 = game.Players:GetPlayerFromCharacter(p5)
	local v311 = require(p5:WaitForChild("Settings"))
	local v313 = p6:Clone()
	local v316 = v313:FindFirstChild("Char")
	if not v316 then
		v316 = v313.Char
		v316.Value = p5
	end
	local v318 = v313:FindFirstChild("Owner")
	if not v318 then
		v318 = v313.Owner
		v318.Value = p5
	end
	local v319 = workspace
	v313.Parent = v319.CharacterStuff.Effects
	local v328 = v313.Name
	if v328 == p7 then
		v313.CFrame = p8
	end
	v328 = pairs
	local v321, v322, v319 = v328(v313:GetDescendants())
	for v325, v324 in v321, v322, v319 do
		if v324.Name == p7 then
			v324.CFrame = p8
		end
	end
	v322 = p5.HumanoidRootPart
	v321 = v322.Stomp
	v321:Play()
end
v1.CreateEffect = v5
v5 = function(p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31)
	local v332 = game.Players:GetPlayerFromCharacter(p9)
	local v335 = require(p9:WaitForChild("Settings"))
	local v336 = false
	local v337 = false
	local v338 = false
	local v341 = game:GetService("RunService")
	local v342 = false
	if p16 == "Beam" then
		local v343 = false
		local v349 = Instance.new("Part", workspace.CharacterStuff.Hitboxes)
		v349.Name = "" .. v332.Name
		v349.Anchored = false
		v349.CanCollide = false
		v349.Color = Color3.fromRGB(0, 255, 0)
		v349.Massless = true
		local v730 = v332.Settings.UI.ShowHitboxes.Value
		if v730 == true then
			v730 = 0
			v349.Transparency = v730
		else
			v730 = 1
			v349.Transparency = v730
		end
		v349.Size = p10
		v349.CFrame = p11
		v349.CFrame = v349.CFrame * p12
		local v356 = Instance.new("WeldConstraint", v349)
		v356.Part0 = p14
		v356.Part1 = v349
		local function HitEnemy_1(p32, p33, p34, p35, p36, p37, p38, p39, p40, p41, p42, p43, p44, p45, p46, p47)
			local v359 = p9
			local v360 = v359.Aspects
			local v361 = v360.Stun
			local v362 = v361.Stunned
			local v363 = v362.Value
			if v363 == false then
				v363 = p32.Parent
				v359 = game.ReplicatedStorage.Assets
				v360 = v359.Kaijus
				v361 = v360.RemoteEvents
				v362 = v361.AddStun
				v360 = v363
				v359 = p33
				v362:FireServer(v360, v359, p34, p35, p36, p37, p38, p39, p40, p41, p42, p32, p44, p45, p46, p47)
			end
		end
		local v385 = {}
		v385.Transparency = 1
		local v387 = v4:Create(v349, TweenInfo.new(p13), v385)
		v387:Play()
		v336 = true
		local v394, v395, v396 = pairs(workspace:GetPartBoundsInBox(v349.CFrame, v349.Size, OverlapParams.new()))
		for v428, v398 in v394, v395, v396 do
			if v343 == false then
				local v397 = v398.Name
				if v397 == "Terrain" then
					if v336 == true then
						v397 = v398.Parent
						local v399 = v332.Character
						if v397 ~= v399 then
							local v400 = v332.Character
							local v401 = v400.Aspects
							local v402 = v401.Stun
							v399 = v402.Stunned
							v397 = v399.Value
							if v397 == false then
								v397 = v398.Transparency
								v399 = 1
								if v399 > v397 then
									v397 = v398.Parent
									v402 = "Humanoid"
									local v403 = v397:FindFirstChild(v402)
									if not v403 then
										v403 = v398.Parent
										local v405 = v403:FindFirstChild("Aspects")
										if not v405 then
											v399 = v398.Parent
											v405 = v399.Aspects
											local v407 = v405:FindFirstChild("Info")
											if not v407 then
												v399 = v398.Parent.Aspects
												v407 = v399.Info
												local v409 = v407:FindFirstChild("Health")
												if not v409 then
													v400 = v398.Parent
													v401 = v400.Aspects
													local v410 = v401.Info
													v399 = v410.Health
													v409 = v399.Value
													v399 = 0
													if v409 > v399 then
														v409 = v398.CanTouch
														if v409 == true then
															if not v349 then
																v410 = v398.Parent
																v399 = v410.StunItems
																v409 = v399.StunValues
																v410 = p15
																local v411 = v409:FindFirstChild(v410)
																if v411 == nil then
																	if p30 == nil then
																		v411 = Instance.new
																		v399 = "BoolValue"
																		local v412 = v411(v399)
																		v412.Name = p15
																		v401 = v398.Parent
																		v412.Parent = v401.StunItems.StunValues
																		v401 = p19
																		v400 = p20
																		HitEnemy_1(v398, v401, v400, p17, p16, p22, p21, p23, p24, p25, p18, p26, p27, p28, p29, p31)
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
				end
			end
		end
		v336 = false
		v394 = v341.RenderStepped
		v396 = function()
			local v429 = false
			print("ran1")
			local v432 = v343
			if v432 == false then
				local v433 = p9
				local v434 = v433.Aspects
				local v435 = v434.Stun
				local v436 = v435.Stunned
				v432 = v436.Value
				if v432 == false then
					v432 = v336
					if v432 == false then
						v432 = v349
						if not v432 then
							v432 = workspace
							v434 = v349
							v435 = v434.CFrame
							v433 = v349
							v434 = v433.Size
							v433 = OverlapParams.new
							v436 = true
							v336 = v436
							v436 = pairs
							local v439, v440, v441 = v436(v432:GetPartBoundsInBox(v435, v434, v433()))
							for v489, v443 in v439, v440, v441 do
								local v442 = v343
								if v442 == false then
									v442 = v443.Name
									if v442 == "Terrain" then
										v442 = v336
										if v442 == true then
											v442 = v443.Parent
											local v444 = v332
											local v445 = v444.Character
											if v442 ~= v445 then
												local v446 = v332
												local v447 = v446.Character
												local v448 = v447.Aspects
												v444 = v448.Stun
												v445 = v444.Stunned
												v442 = v445.Value
												if v442 == false then
													v442 = v443.Transparency
													v445 = 1
													if v445 > v442 then
														v442 = v443.Parent
														v444 = "Humanoid"
														local v449 = v442:FindFirstChild(v444)
														if not v449 then
															v449 = v443.Parent
															local v451 = v449:FindFirstChild("Aspects")
															if not v451 then
																v445 = v443.Parent
																v451 = v445.Aspects
																local v453 = v451:FindFirstChild("Info")
																if not v453 then
																	v445 = v443.Parent.Aspects
																	v453 = v445.Info
																	local v455 = v453:FindFirstChild("Health")
																	if not v455 then
																		v447 = v443.Parent
																		v448 = v447.Aspects
																		local v456 = v448.Info
																		v445 = v456.Health
																		v455 = v445.Value
																		v445 = 0
																		if v455 > v445 then
																			v455 = v443.CanTouch
																			if v455 == true then
																				v455 = v349
																				if not v455 then
																					v456 = v443.Parent
																					v445 = v456.StunItems
																					v455 = v445.StunValues
																					v456 = p15
																					local v457 = v455:FindFirstChild(v456)
																					if v457 == nil then
																						v457 = p30
																						if v457 == nil then
																							if v429 == false then
																								v457 = Instance.new
																								v445 = "BoolValue"
																								local v458 = v457(v445)
																								v458.Name = p15
																								v448 = v443.Parent
																								v458.Parent = v448.StunItems.StunValues
																								v429 = true
																								v448 = p19
																								v447 = p20
																								v446 = p17
																								HitEnemy_1(v443, v448, v447, v446, p16, p22, p21, p23, p24, p25, p18, p26, p27, p28, p29, p31)
																							end
																						end
																					end
																				end
																				v458 = v349
																				if not v458 then
																					v458 = p30
																					if not v458 then
																						v458 = v342
																						if v458 == false then
																							v458 = true
																							v342 = v458
																							v458 = HitEnemy_1
																							v458(v443, p19, p20, p17, p16, p22, p21, p23, p24, p25, p18, p26, p27, p28, p29, p31)
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
									end
								end
							end
							v439 = v343
							if v439 == false then
								v439 = p30
								if not v439 then
									v439 = wait
									v441 = p30
									v440 = v441 * 0.9
									v439(v440)
									v336 = false
									v342 = false
								end
							end
							v490 = v343
							if v490 == false then
								v490 = p30
								if v490 == nil then
									v490 = false
									v336 = v490
								end
							end
						end
					end
				end
			end
			v437 = v349
			if v437 == nil then
				return 
			end
		end
		local v496 = v394:Connect(v396)
		v395 = v341.Stepped
		v428 = function()
			local v497 = false
			print("ran2")
			local v500 = v343
			if v500 == false then
				local v501 = p9
				local v502 = v501.Aspects
				local v503 = v502.Stun
				local v504 = v503.Stunned
				v500 = v504.Value
				if v500 == false then
					v500 = v337
					if v500 == false then
						v500 = v349
						if not v500 then
							v500 = workspace
							v502 = v349
							v503 = v502.CFrame
							v501 = v349
							v502 = v501.Size
							v501 = OverlapParams.new
							v504 = true
							v337 = v504
							v504 = pairs
							local v507, v508, v509 = v504(v500:GetPartBoundsInBox(v503, v502, v501()))
							for v541, v511 in v507, v508, v509 do
								local v510 = v343
								if v510 == false then
									v510 = v511.Name
									if v510 == "Terrain" then
										v510 = v337
										if v510 == true then
											v510 = v511.Parent
											local v512 = v332
											local v513 = v512.Character
											if v510 ~= v513 then
												local v514 = v332
												local v515 = v514.Character
												local v516 = v515.Aspects
												v512 = v516.Stun
												v513 = v512.Stunned
												v510 = v513.Value
												if v510 == false then
													v510 = v511.Transparency
													v513 = 1
													if v513 > v510 then
														v510 = v511.Parent
														v512 = "Humanoid"
														local v517 = v510:FindFirstChild(v512)
														if not v517 then
															v517 = v511.Parent
															local v519 = v517:FindFirstChild("Aspects")
															if not v519 then
																v513 = v511.Parent
																v519 = v513.Aspects
																local v521 = v519:FindFirstChild("Info")
																if not v521 then
																	v513 = v511.Parent.Aspects
																	v521 = v513.Info
																	local v523 = v521:FindFirstChild("Health")
																	if not v523 then
																		v515 = v511.Parent
																		v516 = v515.Aspects
																		local v524 = v516.Info
																		v513 = v524.Health
																		v523 = v513.Value
																		v513 = 0
																		if v523 > v513 then
																			v523 = v511.CanTouch
																			if v523 == true then
																				v523 = v349
																				if not v523 then
																					v524 = v511.Parent
																					v513 = v524.StunItems
																					v523 = v513.StunValues
																					v524 = p15
																					local v525 = v523:FindFirstChild(v524)
																					if v525 == nil then
																						v525 = p30
																						if v525 == nil then
																							if v497 == false then
																								v525 = Instance.new
																								v513 = "BoolValue"
																								local v526 = v525(v513)
																								v526.Name = p15
																								v516 = v511.Parent
																								v526.Parent = v516.StunItems.StunValues
																								v497 = true
																								v516 = p19
																								v515 = p20
																								v514 = p17
																								HitEnemy_1(v511, v516, v515, v514, p16, p22, p21, p23, p24, p25, p18, p26, p27, p28, p29, p31)
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
										end
									end
								end
							end
							v507 = v343
							if v507 == false then
								v507 = p30
								if v507 == nil then
									v507 = false
									v337 = v507
								end
							end
						end
					end
				end
			end
			v505 = v349
			if v505 == nil then
				return 
			end
		end
		local v546 = v395:Connect(v428)
		v398 = function()
			local v548 = false
			print("ran3")
			local v551 = v343
			if v551 == false then
				local v552 = p9
				local v553 = v552.Aspects
				local v554 = v553.Stun
				local v555 = v554.Stunned
				v551 = v555.Value
				if v551 == false then
					v551 = v338
					if v551 == false then
						v551 = v349
						if not v551 then
							v551 = workspace
							v553 = v349
							v554 = v553.CFrame
							v552 = v349
							v553 = v552.Size
							v552 = OverlapParams.new
							v555 = true
							v338 = v555
							v555 = pairs
							local v558, v559, v560 = v555(v551:GetPartBoundsInBox(v554, v553, v552()))
							for v592, v562 in v558, v559, v560 do
								local v561 = v343
								if v561 == false then
									v561 = v562.Name
									if v561 == "Terrain" then
										v561 = v338
										if v561 == true then
											v561 = v562.Parent
											local v563 = v332
											local v564 = v563.Character
											if v561 ~= v564 then
												local v565 = v332
												local v566 = v565.Character
												local v567 = v566.Aspects
												v563 = v567.Stun
												v564 = v563.Stunned
												v561 = v564.Value
												if v561 == false then
													v561 = v562.Transparency
													v564 = 1
													if v564 > v561 then
														v561 = v562.Parent
														v563 = "Humanoid"
														local v568 = v561:FindFirstChild(v563)
														if not v568 then
															v568 = v562.Parent
															local v570 = v568:FindFirstChild("Aspects")
															if not v570 then
																v564 = v562.Parent
																v570 = v564.Aspects
																local v572 = v570:FindFirstChild("Info")
																if not v572 then
																	v564 = v562.Parent.Aspects
																	v572 = v564.Info
																	local v574 = v572:FindFirstChild("Health")
																	if not v574 then
																		v566 = v562.Parent
																		v567 = v566.Aspects
																		local v575 = v567.Info
																		v564 = v575.Health
																		v574 = v564.Value
																		v564 = 0
																		if v574 > v564 then
																			v574 = v562.CanTouch
																			if v574 == true then
																				v574 = v349
																				if not v574 then
																					v575 = v562.Parent
																					v564 = v575.StunItems
																					v574 = v564.StunValues
																					v575 = p15
																					local v576 = v574:FindFirstChild(v575)
																					if v576 == nil then
																						v576 = p30
																						if v576 == nil then
																							if v548 == false then
																								v576 = Instance.new
																								v564 = "BoolValue"
																								local v577 = v576(v564)
																								v577.Name = p15
																								v567 = v562.Parent
																								v577.Parent = v567.StunItems.StunValues
																								v548 = true
																								v567 = p19
																								v566 = p20
																								v565 = p17
																								HitEnemy_1(v562, v567, v566, v565, p16, p22, p21, p23, p24, p25, p18, p26, p27, p28, p29, p31)
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
										end
									end
								end
							end
							v558 = v343
							if v558 == false then
								v558 = p30
								if v558 == nil then
									v558 = false
									v338 = v558
								end
							end
						end
					end
				end
			end
			v556 = v349
			if v556 == nil then
				return 
			end
		end
		local v597 = v341.RenderStepped:Connect(v398)
		v412 = function()
			local v599 = v349
			if not v599 then
				v599 = v349
				v599:Destroy()
				v496:Disconnect()
				v546:Disconnect()
				v597:Disconnect()
				v343 = true
				v336 = false
				local v605, v606, v607 = pairs(workspace:GetDescendants())
				for v613, v609 in v605, v606, v607 do
					if v609.Name == "" .. p15 then
						v609:Destroy()
					end
				end
				return 
			end
		end
		v387.Completed:Connect(v412)
	end
	if p16 == "Beam" then
		v356 = "BeamHitbox"
		local v616 = p9:FindFirstChild(v356)
		v349 = false
		local v617 = false
		v387 = v4
		v546 = workspace
		v496 = v546.Terrain
		v546 = TweenInfo.new
		v597 = p13
		local v639 = {}
		local v640 = workspace
		local v642 = v640.Terrain.WaterTransparency
		v639.WaterTransparency = v642
		local v643 = v387:Create(v496, v546(v597), v639)
		v643:Play()
		v643.Completed:Connect(function()
			local v646 = v616
			if not v646 then
				v646 = true
				v349 = v646
				v646 = pairs
				local v648, v649, v650 = v646(workspace:GetDescendants())
				for v656, v652 in v648, v649, v650 do
					if v652.Name == "" .. p15 then
						v652:Destroy()
					end
				end
				return 
			end
		end)
		v341.RenderStepped:Connect(function()
			local v659 = v349
			if v659 == false then
				local v660 = p9
				local v661 = v660.Aspects
				local v662 = v661.Stun
				local v663 = v662.Stunned
				v659 = v663.Value
				if v659 == false then
					v659 = v336
					if v659 == false then
						v659 = true
						v336 = v659
						v659 = false
						v663 = workspace
						v660 = v616
						v661 = v660.CFrame
						v660 = v616.Size
						v662 = pairs
						local v667, v668, v669 = v662(v663:GetPartBoundsInBox(v661, v660, OverlapParams.new()))
						for v705, v671 in v667, v668, v669 do
							local v670 = v349
							if v670 == false then
								v670 = v617
								if v670 == false then
									v670 = v671.Parent
									local v672 = v332
									local v673 = v672.Character
									if v670 ~= v673 then
										local v674 = v332
										local v675 = v674.Character
										local v676 = v675.Aspects
										v672 = v676.Stun
										v673 = v672.Stunned
										v670 = v673.Value
										if v670 == false then
											v670 = v671.Parent
											v672 = "Humanoid"
											local v677 = v670:FindFirstChild(v672)
											if not v677 then
												v677 = v671.Parent
												local v679 = v677:FindFirstChild("Aspects")
												if not v679 then
													v673 = v671.Parent
													v679 = v673.Aspects
													local v681 = v679:FindFirstChild("Info")
													if not v681 then
														v673 = v671.Parent.Aspects
														v681 = v673.Info
														local v683 = v681:FindFirstChild("Health")
														if not v683 then
															v675 = v671.Parent
															v676 = v675.Aspects
															local v684 = v676.Defense
															v673 = v684.IFrame
															v683 = v673.Value
															if v683 == false then
																v675 = v671.Parent
																v676 = v675.Aspects
																v684 = v676.Info
																v673 = v684.Health
																v683 = v673.Value
																v673 = 0
																if v683 > v673 then
																	v683 = v671.CanTouch
																	if v683 == true then
																		v683 = v616
																		if not v683 then
																			v676 = p9
																			v684 = v676.AttachStart
																			v673 = v684.Beam
																			v683 = v673.Enabled
																			if v683 == true then
																				if v659 == false then
																					v683 = v671.Name
																					if v683 == "BeamHitbox" then
																						v659 = true
																						v683 = p28
																						v673 = function(p48, p49, p50, p51, p52, p53, p54, p55, p56, p57, p58, p59, p60, p61)
																							local v619 = p48.Parent
																							local v620 = p9
																							if v619 ~= v620 then
																								local v621 = p9
																								local v622 = v621.Aspects
																								local v623 = v622.Stun
																								v620 = v623.Stunned
																								v619 = v620.Value
																								if v619 == false then
																									v622 = p9
																									v623 = v622.AttachStart
																									v620 = v623.Beam
																									v619 = v620.Enabled
																									if v619 == true then
																										v619 = p48.Parent
																										v621 = game.ReplicatedStorage.Assets
																										v622 = v621.Kaijus
																										v623 = v622.RemoteEvents
																										v620 = v623.AddStun
																										v622 = v619
																										v621 = p49
																										v620:FireServer(v622, v621, p50, p51, p52, p53, p54, p55, p56, p57, p58, p48, p60, p61)
																									end
																								end
																							end
																						end
																						v684 = v671
																						v676 = p19
																						v675 = p20
																						v674 = p17
																						v673(v684, v676, v675, v674, p16, p22, p21, p23, p24, p25, p18, p26, p27, v683)
																					end
																					v683 = v671.Name
																					if v683 == "BeamHitbox" then
																						local v695 = v671.Parent
																						local v696 = v695.AttachStart
																						local v697 = v696.Beam
																						v683 = v697.Enabled
																						if v683 == true then
																							local v698 = v671.Parent
																							v695 = v698.Aspects
																							v696 = v695.Stun
																							v697 = v696.Stunned
																							v683 = v697.Value
																							if v683 == false then
																								v698 = v671.Parent
																								v695 = v698.Aspects
																								v696 = v695.Stun
																								v697 = v696.Knockdown
																								v683 = v697.Value
																								if v683 == false then
																									v698 = game
																									v695 = v698.Players
																									v696 = v695.LocalPlayer
																									v697 = v696.PlayerGui
																									v683 = v697.GameGui
																									v696 = "BeamClash"
																									local v699 = v683:FindFirstChild(v696)
																									if v699 == nil then
																										v697 = game
																										v699 = v697.Players
																										v697 = true
																										v617 = v697
																										v698 = game.ReplicatedStorage.Assets
																										v695 = v698.Kaijus
																										v697 = v695.RemoteEvents.BeamClash
																										v695 = v699:GetPlayerFromCharacter(v671.Parent)
																										v697:FireServer(v695)
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
												end
											end
										end
									end
								end
							end
						end
						v667 = wait
						v669 = p30
						v668 = v669 * 0.9
						v667(v668)
						v336 = false
					end
				end
			end
		end)
		local v711, v712, v713 = pairs(workspace:GetDescendants())
		for v720, v642 in v711, v712, v713 do
			local v715 = v642:IsA("BasePart")
			if not v715 then
				v715 = v642.Parent
				if not v715:FindFirstChild("Aspects") then
					local v719 = v642:FindFirstChild("Bool")
					if not v719 then
						v640 = v642.Bool
						v719 = v640.Value
						v642.CanCollide = v719
						v719 = v642.Bool
						v719:Destroy()
					end
				end
			end
		end
		v711 = false
		v616.CanCollide = v711
	end
end
v1.CreateHitbox = v5
v5 = function(p62, p63)
	local v743 = game.Players:GetPlayerFromCharacter(p62)
	local v745 = game:GetService("RunService")
	game.ReplicatedStorage.Assets.Kaijus.RemoteEvents.GrabBuilding:FireServer(p63)
end
v1.GrabBuilding = v5
return v1
