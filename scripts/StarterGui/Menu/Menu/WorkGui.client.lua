wait(0.5)
local v4 = game
local v6 = v4.Players.LocalPlayer
local v8, v9, v6 = pairs(v6.PlayerGui:GetChildren())
for v5, v4 in v8, v9, v6 do
	local v10 = v4.Name
	if v10 == "Menu" then
		local v11 = script
		local v12 = v11.Parent
		v10 = v12.Parent
		if v4 ~= v10 then
			v11 = script
			v12 = v11.Parent
			v10 = v12.Parent
			v10:Destroy()
		end
	end
end
v6 = game.Players
v9 = v6.LocalPlayer
v8 = v9.PlayerGui
v8:WaitForChild("GameGui")
local v15 = game:GetService("RunService")
v9 = game
local v16 = v9:GetService("MarketplaceService")
v4 = "TeleportService"
local v18 = game:GetService(v4)
local v21 = game:GetService("TweenService")
v12 = script
local v23 = v12.Parent.Sounds
v11 = script
v12 = v11.Parent
local v2201 = v12.Events
local v24 = game
v11 = v24.Players.LocalPlayer.PlayerGui
v12 = v11.GameGui
local v27 = v12:FindFirstChild("Control")
v24 = game.Players.LocalPlayer
local v30 = v24.PlayerGui.GameGui
v11 = v30.LockOn
local v31 = v11:FindFirstChild("LockOn")
v30 = false
local v33 = game:GetService("UserInputService")
local v34 = workspace
v24 = v34.CurrentCamera
v34 = script.Parent.Values
local v37 = game.Players.LocalPlayer:WaitForChild("Inventory")
wait(1)
local v42 = game.Players.LocalPlayer:WaitForChild("Settings")
wait(1)
local v46 = game:GetService("TeleportService")
local v47 = false
local v48 = false
local v49 = 0
local v50 = false
local v52 = v37:GetDescendants()
local v55 = script.Parent:GetDescendants()
local v59 = Color3.fromRGB(80, 255, 80)
local v64 = Color3.fromRGB(0, 170, 255)
local v69 = Color3.fromRGB(211, 35, 255)
local v74 = Color3.fromRGB(255, 170, 0)
local v75 = v33.GamepadEnabled
if not v75 then
	v75 = script.Parent.Prompt.PromptImage.XBOXB
	v75.Visible = true
	v75 = script.Parent.Prompt.PromptImage.XBOXY
	v75.Visible = true
end
local function UnlockImages_1(p1, p2)
	local v81 = v50
	if v81 == false then
		if p1 == "GCells" then
			v81 = script.Parent.Inventory.Lootboxes.TXT
			local v242 = v37.Lootboxes
			local v243 = v242.Value
			v81.Text = "Lootboxes : " .. v243
			local v245 = v37
			local v246 = v245.Lootboxes
			v81 = v246.Value
			if v81 == 0 then
				v242 = script
				v243 = v242.Parent
				v245 = v243.Inventory
				v246 = v245.Lootboxes
				v81 = v246.TXT
				v246 = Color3.fromRGB
				v245 = 255
				v243 = 185
				v242 = 0
				v81.TextColor3 = v246(v245, v243, v242)
			else
		
			
			end

	
		
	
		
	
		end
		if p1 == "XP" then

		
		end
	end
	local v267 = v50
	if v267 == false then
		local v102 = script
		local v103 = v102.Parent
		local v104 = v103.Parent
		local v101 = v104.Menu
		v267 = v101.Visible
		if v267 == true then
			if p1 == "Profile" then
				if p1 == "All" then
					v267 = pairs
					v104 = script
					v101 = v104.Parent
					local v105, v106, v104 = v267(v101:GetDescendants())
					for v103, v102 in v105, v106, v104 do
						local v107 = v102.Name
						if v107 == "Favorite" then
					
						end
					end
				end
				if p1 == "All" then
					v103 = script
					v104 = v103.Parent
					
					v104 = "Equipped : "
					
		
					v103 = v102.Value
					
				
					
					
					if v112 == "KaijuValue" then
						if p1 == "Kaiju" then
							v103 = script
							v104 = v103.Parent
							v114 = v104.PlayerInfo
							v113 = v114.KaijuName
							v104 = "Equipped : "
							v116 = v37
							v102 = v116.Skin
							v103 = v102.Value
							v114 = v104 .. v103
							v113.Text = v114
							v113 = pairs
							v104 = script
							v114 = v104.Parent
							local v148, v149, v104 = v113(v114:GetDescendants())
							for v103, v102 in v148, v149, v104 do
								v116 = v102.Name
								if v116 == "InvObj" then
									v116 = v102.Value
									if v116 == p2 then
										v117 = v102.Parent
										v116 = v117.Name
										if v116 == "SkinName" then
											v116 = p2.Value
											if v116 == true then
												v118 = v102.Parent
												v117 = v118.Parent
												v116 = v117.CostTXT
												v117 = false
												v116.Visible = v117
											end
										end
										v117 = v102.Parent
										v116 = v117.Name
										if v116 == "EmoteAnimation" then
											v116 = p2.Value
											if v116 == true then
												v118 = v102.Parent
												v117 = v118.Parent
												v116 = v117.CostTXT
												v117 = false
												v116.Visible = v117
											end
										end
									end
								end
							end
						end
						if v112 == "CostTXT" then
							if p1 == "GCells" then
								if p1 == "All" then
									v102 = script
									v103 = v102.Parent
									v104 = v103.Inventory
									v149 = v104.Lootboxes
									v148 = v149.TXT
									v104 = "Lootboxes : "
									v116 = v37
									v102 = v116.Lootboxes
									v103 = v102.Value
									v149 = v104 .. v103
									v148.Text = v149
									v104 = v37
									v149 = v104.Lootboxes
									v148 = v149.Value
									if v148 == 0 then
										v102 = script
										v103 = v102.Parent
										v104 = v103.Inventory
										v149 = v104.Lootboxes
										v148 = v149.TXT
										v149 = Color3.fromRGB
										v104 = 255
										v103 = 185
										v102 = 0
										v148.TextColor3 = v149(v104, v103, v102)
									else
										v150 = script.Parent.Inventory.Lootboxes
										v148 = v150.TXT
										v150 = Color3.fromRGB
										v148.TextColor3 = v150(255, 255, 255)
									end
									v154 = script.Parent.PlayerInfo
									v148 = v154.GCells
									v116 = v37
									v154 = "GCells : " .. v116.GCells.Value
									v148.Text = v154
									v154 = script.Parent.Lootbox.Open
									v148 = v154.Open
									v116 = v37
									v154 = "Open Lootbox : " .. v116.Lootboxes.Value
									v148.Text = v154
								end
								if p1 == "Settings" then
									if p1 == "All" then
										v148 = pairs
										v155 = script
										v156 = v155.Parent
										v154 = v156.Settings
										local v158, v159, v156 = v148(v154:GetChildren())
										for v155, v157 in v158, v159, v156 do
											v116 = pairs
											v97 = game
											v147 = v97.Players
											v118 = v147.LocalPlayer
											v117 = v118.Settings
											local v160, v161, v118 = v116(v117:GetDescendants())
											for v147, v97 in v160, v161, v118 do
												v146 = v97.Name
												v144 = v157.Name
												if v146 == v144 then
													v146 = v157.Name
													if v146 == "Keybinds" then
														local v163 = v157:FindFirstChild("TXT")
														if not v163 then
															v163 = v157.TXT
															v131 = v157.Name
															v129 = " : "
															v128 = tostring
															v144 = "" .. v131 .. v129 .. v128(v97.Value)
															v163.Text = v144
														end
													end
												end
											end
										end
										v158 = pairs
										v155 = script
										v156 = v155.Parent
										v159 = v156.Keybinds
										local v167, v168, v156 = v158(v159:GetChildren())
										for v155, v157 in v167, v168, v156 do
											v160 = pairs
											v97 = game
											v147 = v97.Players
											v118 = v147.LocalPlayer
											v161 = v118.Settings
											local v169, v170, v118 = v160(v161:GetDescendants())
											for v147, v97 in v169, v170, v118 do
												v163 = v97.Name
												v144 = v157.Name
												if v163 == v144 then
													v164 = "TXT"
													local v171 = v157:FindFirstChild(v164)
													if not v171 then
														v171 = v157.TXT
														v131 = v157.Name
														v129 = " : "
														v166 = tostring
														v144 = "" .. v131 .. v129 .. v166(v97.Value)
														v171.Text = v144
													end
												end
											end
										end
										v155 = game
										v156 = v155.Players
										v168 = v156.LocalPlayer
										v167 = v168.PlayerGui
										v156 = "GameGui"
										local v175 = v167:FindFirstChild(v156)
										if not v175 then
											v168 = game
											v155 = "UserInputService"
											local v176 = v168:GetService(v155)
											v175 = v176.GamepadEnabled
											if v175 == false then
												v175 = pairs
												v170 = game
												v169 = v170.Players
												v157 = v169.LocalPlayer
												local v178 = v157.PlayerGui.GameGui
												v176 = v178.Character
												local v179, v180, v178 = v175(v176:GetDescendants())
												for v177, v157 in v179, v180, v178 do
													v169 = pairs
													v97 = game
													v147 = v97.Players
													v118 = v147.LocalPlayer
													v170 = v118.Settings
													local v181, v182, v118 = v169(v170:GetDescendants())
													for v147, v97 in v181, v182, v118 do
														v171 = v97.Name
														v144 = v157.Name
														if v171 == v144 then
															v172 = "TXT"
															local v183 = v157:FindFirstChild(v172)
															if not v183 then
																local v184 = v157.Parent
																v144 = v184.Parent
																v183 = v144.Name
																if v183 == "Mobile" then
																	v144 = v157.TXT
																	v183 = v144.TXT
																	v184 = ""
																	v131 = tostring
																	v129 = v97.Value
																	v144 = v184 .. v131(v129)
																	v183.Text = v144
																end
															end
														end
													end
												end
											else
												v177 = game
												v178 = v177.Players
												v180 = v178.LocalPlayer
												v179 = v180.PlayerGui
												v178 = "GameGui"
												local v186 = v179:FindFirstChild(v178)
												if not v186 then
													v183 = game
													v97 = v183.Players
													v147 = v97.LocalPlayer
													v118 = v147.PlayerGui
													v182 = v118.GameGui
													v181 = v182.Character
													v157 = v181.HealthStats
													v177 = v157.Attacks
													v180 = v177.Block.TXT
													v186 = v180.TXT
													v180 = "LT"
													v186.Text = v180
													v183 = game
													v97 = v183.Players
													v147 = v97.LocalPlayer
													v118 = v147.PlayerGui
													v182 = v118.GameGui
													v181 = v182.Character
													v157 = v181.HealthStats
													v177 = v157.Attacks
													v180 = v177.Roar.TXT
													v186 = v180.TXT
													v180 = "RB"
													v186.Text = v180
													v183 = game
													v97 = v183.Players
													v147 = v97.LocalPlayer
													v118 = v147.PlayerGui
													v182 = v118.GameGui
													v181 = v182.Character
													v157 = v181.HealthStats
													v177 = v157.Attacks
													v180 = v177.Escape.TXT
													v186 = v180.TXT
													v180 = "A"
													v186.Text = v180
													v183 = game
													v97 = v183.Players
													v147 = v97.LocalPlayer
													v118 = v147.PlayerGui
													v182 = v118.GameGui
													v181 = v182.Character
													v157 = v181.AttacksRage
													v177 = v157.Attacks
													v180 = v177.Grab.TXT
													v186 = v180.TXT
													v180 = "LB"
													v186.Text = v180
													v183 = game
													v97 = v183.Players
													v147 = v97.LocalPlayer
													v118 = v147.PlayerGui
													v182 = v118.GameGui
													v181 = v182.Character
													v157 = v181.AttacksRage
													v177 = v157.Attacks
													v180 = v177.SP1.TXT
													v186 = v180.TXT
													v180 = "A"
													v186.Text = v180
													v183 = game
													v97 = v183.Players
													v147 = v97.LocalPlayer
													v118 = v147.PlayerGui
													v182 = v118.GameGui
													v181 = v182.Character
													v157 = v181.AttacksRage
													v177 = v157.Attacks
													v180 = v177.SP2.TXT
													v186 = v180.TXT
													v180 = "B"
													v186.Text = v180
													v183 = game
													v97 = v183.Players
													v147 = v97.LocalPlayer
													v118 = v147.PlayerGui
													v182 = v118.GameGui
													v181 = v182.Character
													v157 = v181.AttacksRage
													v177 = v157.Attacks
													v180 = v177.SP3.TXT
													v186 = v180.TXT
													v180 = "X"
													v186.Text = v180
													v97 = game
													v147 = v97.Players
													v118 = v147.LocalPlayer
													v182 = v118.PlayerGui
													v181 = v182.GameGui
													v157 = v181.Character
													v177 = v157.AttacksRage
													v180 = v177.Rage.TXT
													v186 = v180.TXT
													v180 = "Y"
													v186.Text = v180
												end
											end
											v186 = workspace
											v187 = "Song"
											local v188 = v186:FindFirstChild(v187)
											if not v188 then
												v180 = workspace
												v188 = v180.Song
												v157 = v42
												v177 = v157.UI
												v180 = v177.MusicVolume.Value
												v188.Volume = v180
												v180 = workspace
												v188 = v180.Song
												local v190 = v188:FindFirstChild("D")
												if v190 == nil then
													v190 = Instance.new
													v180 = "BoolValue"
													v177 = workspace
													v190(v180, v177.Song).Name = "D"
													workspace.Song.TimePosition = 0
												end
											end
											if p1 == "XP" then
												if p1 == "All" then
													v157 = script
													v177 = v157.Parent
													v194 = v177.PlayerInfo
													v193 = v194.XPBar
													v192 = v193.TXT
													v194 = "Level "
													v144 = v37
													v183 = v144.XP
													v97 = v183.Level
													v177 = v97.Value
													v157 = "                    "
													v183 = v37
													v97 = v183.XP
													v181 = v97.Value
													v182 = " / "
													v144 = v37
													v183 = v144.XP
													v97 = v183.XPToEarn
													v118 = v97.Value
													v147 = " XP"
													v193 = v194 .. v177 .. v157 .. v181 .. v182 .. v118 .. v147
													v192.Text = v193
													v157 = script
													v177 = v157.Parent
													v194 = v177.PlayerInfo
													v193 = v194.XPBar
													v192 = v193.Bar
													v193 = UDim2.new
													v181 = v37
													v157 = v181.XP
													v177 = v157.Value
													v118 = v37
													v182 = v118.XP
													v181 = v182.XPToEarn
													v157 = v181.Value
													v194 = v177 / v157
													v177 = 0
													v157 = 1
													v181 = 0
													v192.Size = v193(v194, v177, v157, v181)
												end
												if p1 == "Rewards" then
													if p1 == "All" then
														v192 = 5
														v195 = v16
														v182 = game
														local v196 = v182.Players
														local v199 = v195:UserOwnsGamePassAsync(v196.LocalPlayer.UserId, 54662673)
														if not v199 then
															v192 = 7
															v118 = script
															v182 = v118.Parent
															v196 = v182.Rewards
															v199 = v196.Rewards.Selection.Item3.Lock
															v199.Visible = false
															v118 = script
															v182 = v118.Parent
															v196 = v182.Rewards
															v199 = v196.Rewards.Selection.Item6.Lock
															v199.Visible = false
														end
														v182 = script
														v200 = v182.Parent.Rewards
														v201 = v200.Rewards
														v202 = v201.Selection
														local v203, v204, v201 = pairs(v202:GetDescendants())
														for v200, v196 in v203, v204, v201 do
															v182 = pairs
															v147 = v37
															v118 = v147.Rewards
															local v205, v206, v147 = v182(v118:GetChildren())
															for v97, v183 in v205, v206, v147 do
																v144 = v196.Name
																v184 = v183.Name
																if v144 == v184 then
																	v185 = "NumberValue"
																	local v207 = v183:FindFirstChildOfClass(v185)
																	local v209 = v183:GetAttribute("Max")
																	v174 = v183.ObjectiveName
																	v196.Objective.Text = v174.Text
																	v174 = ""
																	v196.Bar.Type.Text = v174 .. v207.Value .. "/" .. v209
																	v174 = v207.Value / v209
																	v196.Bar.Bar.Size = UDim2.new(v174, 0, 1, 0)
																	local v307 = v183.Value
																	local v308 = v307.Name
																	if v308 == "GCells" then
																		v307 = v183.Value
																		v308 = v307.Name
																		if v308 == "Lootboxes" then
																			v308 = v196.ItemName
																			v307 = v183.Value.Name
																			v308.Text = v307
																			v308 = v196.ItemImage
																			v307 = v183.Value.RarityImage.image
																			v308.Image = v307
																			v307 = v183.Value.Rarity
																			v308 = v307.Text
																			if v308 == "Uncommon" then
																				v308 = v196.ItemName
																				v307 = v59
																				v308.TextColor3 = v307
																				v308 = v196.ItemName
																				v307 = v59
																				v308.TextStrokeColor3 = v307
																			end
																			v307 = v183.Value.Rarity
																			v308 = v307.Text
																			if v308 == "Rare" then
																				v308 = v196.ItemName
																				v307 = v64
																				v308.TextColor3 = v307
																				v308 = v196.ItemName
																				v307 = v64
																				v308.TextStrokeColor3 = v307
																			end
																			v307 = v183.Value.Rarity
																			v308 = v307.Text
																			if v308 == "Epic" then
																				v308 = v196.ItemName
																				v307 = v69
																				v308.TextColor3 = v307
																				v308 = v196.ItemName
																				v307 = v69
																				v308.TextStrokeColor3 = v307
																			end
																			v307 = v183.Value.Rarity
																			v308 = v307.Text
																			if v308 == "Legendary" then
																				v308 = v196.ItemName
																				v307 = v74
																				v308.TextColor3 = v307
																				v308 = v196.ItemName
																				v307 = v74
																				v308.TextStrokeColor3 = v307
																			end
																		end
																	end
																	local v314 = v183.Value
																	local v315 = v314.Name
																	if v315 == "GCells" then
																		v315 = v196.ItemName
																		v216 = ""
																		v217 = v183.GCellValue.Text
																		local v219 = " GCells"
																		v314 = v216 .. v217 .. v219
																		v315.Text = v314
																		v315 = tonumber
																		v216 = v183.GCellValue
																		v314 = v216.Text
																		local v220 = v315(v314)
																		local v221 = 375
																		if v220 >= v221 then
																			v220 = v196.ItemImage
																			v219 = v37
																			v217 = v219.GCells
																			v216 = v217.Legendary
																			v221 = v216.Image
																			v220.Image = v221
																			v220 = v196.ItemName
																			v221 = v74
																			v220.TextColor3 = v221
																			v220 = v196.ItemName
																			v221 = v74
																			v220.TextStrokeColor3 = v221
																		end
																		v216 = v183.GCellValue
																		local v222 = tonumber(v216.Text)
																		local v223 = 250
																		if v222 >= v223 then
																			v222 = tonumber
																			v216 = v183.GCellValue
																			v223 = v216.Text
																			local v224 = v222(v223)
																			local v225 = 375
																			if v225 > v224 then
																				v224 = v196.ItemImage
																				v219 = v37
																				v217 = v219.GCells
																				v216 = v217.Epic
																				v225 = v216.Image
																				v224.Image = v225
																				v224 = v196.ItemName
																				v225 = v69
																				v224.TextColor3 = v225
																				v224 = v196.ItemName
																				v225 = v69
																				v224.TextStrokeColor3 = v225
																			end
																		end
																		v224 = tonumber
																		v216 = v183.GCellValue
																		v225 = v216.Text
																		local v226 = v224(v225)
																		local v227 = 100
																		if v226 >= v227 then
																			v226 = tonumber
																			v216 = v183.GCellValue
																			v227 = v216.Text
																			local v228 = v226(v227)
																			local v229 = 250
																			if v229 > v228 then
																				v228 = v196.ItemImage
																				v219 = v37
																				v217 = v219.GCells
																				v216 = v217.Rare
																				v229 = v216.Image
																				v228.Image = v229
																				v228 = v196.ItemName
																				v229 = v64
																				v228.TextColor3 = v229
																				v228 = v196.ItemName
																				v229 = v64
																				v228.TextStrokeColor3 = v229
																			end
																		end
																		v228 = tonumber
																		v216 = v183.GCellValue
																		v229 = v216.Text
																		local v230 = v228(v229)
																		local v231 = 100
																		if v231 >= v230 then
																			v230 = v196.ItemImage
																			v219 = v37
																			v217 = v219.GCells
																			v216 = v217.Uncommon
																			v231 = v216.Image
																			v230.Image = v231
																			v230 = v196.ItemName
																			v231 = v59
																			v230.TextColor3 = v231
																			v230 = v196.ItemName
																			v231 = v59
																			v230.TextStrokeColor3 = v231
																		end
																	end
																	v231 = v183.Value
																	v230 = v231.Name
																	if v230 == "Lootboxes" then
																		v230 = v196.ItemName
																		v216 = ""
																		v218 = v183.GCellValue
																		v217 = v218.Text
																		v219 = " Lootboxes"
																		v231 = v216 .. v217 .. v219
																		v230.Text = v231
																		v230 = v196.ItemImage
																		v219 = v37
																		v217 = v219.Lootboxes
																		v216 = v217.Image
																		v231 = v216.Image
																		v230.Image = v231
																		v230 = v196.ItemName
																		v231 = v74
																		v230.TextColor3 = v231
																		v230 = v196.ItemName
																		v231 = v74
																		v230.TextStrokeColor3 = v231
																	end
																	v230 = v207.Value
																	if v230 >= v209 then
																		v230 = v196.Check
																		v231 = true
																		v230.Visible = v231
																	end
																	v230 = v196.Name
																	v219 = v37
																	v217 = v219.Rewards
																	v216 = v217.Current
																	v231 = v216.Value
																	if v230 == v231 then
																		v230 = v196.Mark
																		v231 = true
																		v230.Visible = v231
																	else
																		v230 = v196.Mark
																		v231 = false
																		v230.Visible = v231
																	end
																end
															end
														end
														v205 = script
														v200 = v205.Parent.Rewards
														v201 = v200.Rewards
														v204 = v201.Bar
														v203 = v204.Bar
														v204 = UDim2.new
														v206 = v37
														v205 = v206.Rewards
														v200 = v205.Completed.Value
														v201 = v200 / v192
														v200 = 0
														v205 = 0
														v203.Size = v204(v201, v200, 1, v205)
														v203 = script.Parent.Rewards.Rewards.Bar.Type
														v97 = v37
														v147 = v97.Rewards
														v206 = v147.Completed
														local v324 = "/"
														v203.Text = "" .. v206.Value .. v324 .. v192
														local v327 = v37
														local v328 = v327.Rewards
														local v329 = v328.Owned
														v203 = v329.Value
														if v203 == false then
															v324 = script
															v327 = v324.Parent
															v328 = v327.Rewards
															v329 = v328.Rewards
															v203 = v329.Buy
															v329 = true
															v203.Visible = v329
														else
															v324 = script
															v327 = v324.Parent
															v328 = v327.Rewards
															v329 = v328.Rewards
															v203 = v329.Buy
															v329 = false
															v203.Visible = v329
														end
													end
													v235 = game
													v236 = v235.Workspace
													v232 = v236.Server
													v203 = v232.GameMode
													v192 = v203.Value
													if v192 == "Tutorial" then
														v203 = game
														v192 = v203.Lighting
														v235 = v42
														v236 = v235.Graphics
														v232 = v236.Shadows
														v203 = v232.Value
														v192.GlobalShadows = v203
														v232 = game
														v203 = v232.Lighting
														v192 = v203.DepthOfField
														v235 = v42
														v236 = v235.Graphics
														v232 = v236.DepthOfField
														v203 = v232.Value
														v192.Enabled = v203
														v232 = game
														v203 = v232.Lighting
														v192 = v203.DefaultBlur
														v235 = v42
														v236 = v235.Graphics
														v232 = v236.Blur
														v203 = v232.Value
														v192.Enabled = v203
														v236 = v42
														v232 = v236.Graphics
														v203 = v232.Shadows
														v192 = v203.Value
														if v192 == true then
															v203 = game
															v192 = v203.Lighting
															v232 = "Quality"
															local v237 = v192:FindFirstChild(v232)
															if not v237 then
																v203 = game.Lighting
																v237 = v203.Quality
																v203 = workspace.Map
																v237.Parent = v203
															end
														end
														v236 = v42
														v238 = v236.Graphics
														v203 = v238.Shadows
														v237 = v203.Value
														if v237 == false then
															v203 = workspace
															v237 = v203.Map
															v238 = "Quality"
															local v239 = v237:FindFirstChild(v238)
															if not v239 then
																v203 = workspace.Map
																v239 = v203.Quality
																v203 = game.Lighting
																v239.Parent = v203
															end
														end
													end
													v239 = false
													v50 = v239
													return 
												end
											end
										end
									end
								end
							end
							if v112 == "SkinName" then
							end
						end
					end
				end
			end
		end
	end
end
v77 = "XP"
v37:WaitForChild(v77)
local v333 = game
local v334 = v333.Players
v76 = v334.LocalPlayer
local v335 = v76.PlayerGui
v78 = v335.Menu
local v336, v337, v335 = pairs(v78:GetDescendants())
for v76, v334 in v336, v337, v335 do
	v333 = v334.Name
	if v333 == "EmoteName" then
		v333 = v334.Parent
		local v339 = v333:FindFirstChild("EmoteAnimation")
		if not v339 then
			v339 = pairs
			local v340 = game
			local v342, v343, v340 = v339(v340.ReplicatedStorage:GetDescendants())
			for v349, v346 in v342, v343, v340 do
				local v345 = v346.Name
				if v334.Value == v345 then
					local v348 = v346:IsA("LocalScript")
					if not v348 then
						v345 = v334.Parent
						v348 = v345.EmoteAnimation
						v348.Value = v346
					end
				end
			end
		end
	end
end
v336 = pairs
v342 = game
v76 = v342.Players.LocalPlayer
v335 = v76.PlayerGui
v337 = v335.Menu
local v350, v351, v335 = v336(v337:GetDescendants())
for v76, v334 in v350, v351, v335 do
	v342 = v334.Name
	if v342 == "SkinName" then
		v342 = v334.Parent
		v340 = "SkinModel"
		local v352 = v342:FindFirstChild(v340)
		if not v352 then
			v352 = pairs
			local v353 = game
			v343 = v353.ReplicatedStorage
			local v354, v355, v353 = v352(v343:GetDescendants())
			for v349, v346 in v354, v355, v353 do
				v348 = v334.Value
				v345 = v346.Name
				if v348 == v345 then
					local v357 = v346:IsA("Model")
					if not v357 then
						v345 = v334.Parent
						v357 = v345.SkinModel
						v357.Value = v346
					end
				end
			end
		end
	end
end
v76 = script
v335 = v76.Parent
v351 = v335.Parent
v350 = v351.Menu
v351 = true
v350.Visible = v351
v350 = UnlockImages_1
v351 = "All"
v350(v351)
v76 = script
v76.Parent.Parent.Menu.Visible = false
v76 = game
v76.Players.LocalPlayer.CharacterRemoving:Connect(function()
	while true do
		wait()
		local v361 = game
		local v362 = v361.Players
		local v363 = v362.LocalPlayer
		local v364 = v363.Character
		if not v364 then
			v361 = game
			v362 = v361.Players
			v363 = v362.LocalPlayer
			v364 = v363.Character
			v362 = "Humanoid"
			local v365 = v364:FindFirstChild(v362)
			if not v365 then
				v361 = script.Parent
				v363 = v361.Parent.Menu
				v365 = v363.Visible
				if v365 == false then
					break
				end
			end
		end
	end
	v361 = script
	v367 = v361.Parent
	v363 = v367.Parent
	v365 = v363.Menu
	v363 = true
	v365.Visible = v363
	v365 = UnlockImages_1
	v363 = "Settings"
	v365(v363)
	v361 = script
	v367 = v361.Parent
	v367.Parent.Menu.Visible = false
end)
local v373 = workspace:FindFirstChild("Song")
if not v373 then
	break
end
v373 = workspace.Song
v373.TimePosition = 0
local v374, v375, v376 = pairs(v37:GetDescendants())
for v76, v334 in v374, v375, v376 do
	v354 = v334.Changed
	v353 = function()
		local v377 = v334
		local v378 = v377.Parent
		local v379 = v378.Name
		if v379 == "Profile" then
			v379 = UnlockImages_1
			v378 = "Profile"
			v379(v378)
			return 
		end
		local v380 = v334
		local v383 = v37:FindFirstChild("XP")
		if v380 ~= v383 then
			v377 = v334
			v383 = v377.Parent
			v380 = v383.Name
			if v380 == "XP" then
				v380 = UnlockImages_1
				v383 = "XP"
				v380(v383)
				return 
			end
			local v384 = v334
			local v385 = v384.Name
			if v385 == "Rewards" then
				v377 = v334
				v384 = v377.Parent
				v385 = v384.Name
				if v385 == "Rewards" then
					local v386 = v334
					v377 = v386.Parent
					v384 = v377.Parent
					v385 = v384.Name
					if v385 == "Rewards" then
						v386 = v334.Parent
						v377 = v386.Parent
						v384 = v377.Parent
						v385 = v384.Name
						if v385 == "Rewards" then
							while true do
								v385 = wait
								v385()
								v386 = script
								v377 = v386.Parent
								v384 = v377.Rewards
								if v384.Visible == true then
									break
								end
							end
							v388 = UnlockImages_1
							v384 = "Rewards"
							v388(v384)
							return 
						end
						local v389 = v334
						local v390 = v389.Name
						if v390 == "GCells" then
							v389 = v334
							v390 = v389.Name
							if v390 == "Lootboxes" then
								v377 = v334
								v389 = v377.Parent
								v390 = v389.Name
								if v390 == "GCells" then
									v377 = v334
									v389 = v377.Parent
									v390 = v389.Name
									if v390 == "Lootboxes" then
										v390 = UnlockImages_1
										v389 = "GCells"
										v390(v389)
										return 
									end
									local v391 = v334
									v377 = "Emotes"
									local v393 = v391.Parent:FindFirstChild(v377)
									if v393 then
										v391 = v334.Parent
										v393 = v391.Parent
										local v395 = v393:FindFirstChild("Emotes")
										if v395 then
											local v396 = v334
											v391 = v396.Parent
											v395 = v391.Name
											if v395 == "Emotes" then
												v391 = v334
												v395 = v391.Name
												if v395 == "Emotes" then
													v391 = v334
													v395 = v391.Name
													if v395 == "Skin" then
														v391 = v334
														v395 = v391.Name
														if v395 == "Kaiju" then
															v395 = UnlockImages_1
															v391 = "Kaiju"
															v396 = v334
															v395(v391, v396)
															return 
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
	v354:Connect(v353)
end
v374 = pairs
v76 = game.Players
v376 = v76.LocalPlayer
v375 = v376.Settings
local v398, v399, v376 = v374(v375:GetDescendants())
for v76, v334 in v398, v399, v376 do
	v334.Changed:Connect(function()
		UnlockImages_1("Settings")
	end)
end
v76 = game.Players
v376 = v76.LocalPlayer
v399 = v376.PlayerGui
v398 = v399.ChildAdded
v376 = function()
	UnlockImages_1()
end
v398:Connect(v376)
v76 = game
v399 = v76.Players.LocalPlayer
v399.CharacterAdded:Connect(function()
	UnlockImages_1()
end)
v76 = game
v399 = v76.Players.LocalPlayer
v399.CharacterRemoving:Connect(function()
	UnlockImages_1()
end)
v76 = script
v399 = v76.Parent.Events
v76 = game.Players.LocalPlayer
v76 = true
v399.CheckProfile:FireServer(v76.Name, v76)
local v416 = script.Parent
v399 = v416.GCells
local v417, v418, v416 = pairs(v399:GetChildren())
for v415, v334 in v417, v418, v416 do
	local v420 = v334:FindFirstChild("Button")
	if not v420 then
		v420 = v334.Name
		if v420 == "Back" then
			v355 = v334.Button
			v420 = v355.MouseButton1Down
			v420:Connect(function()
				v16:PromptProductPurchase(game.Players.LocalPlayer, tonumber(v334.Name))
			end)
		end
	end
end
v417 = pairs
v416 = script.Parent
v418 = v416.Gamepass
local v429, v430, v416 = v417(v418:GetChildren())
for v415, v334 in v429, v430, v416 do
	local v433 = v334:FindFirstChild("Button")
	if not v433 then
		v433 = v334.Name
		if v433 == "Back" then
			v355 = v334.Button
			v433 = v355.MouseButton1Down
			v433:Connect(function()
				v16:PromptGamePassPurchase(game.Players.LocalPlayer, tonumber(v334.Name))
			end)
		end
	end
end
v429 = pairs
v416 = script.Parent
v430 = v416.Settings
local v442, v443, v416 = v429(v430:GetChildren())
for v415, v334 in v442, v443, v416 do
	v346 = game
	v349 = v346.Players
	local v445 = v349.LocalPlayer
	v355 = v445.Settings
	local v446, v447, v445 = pairs(v355:GetDescendants())
	for v349, v346 in v446, v447, v445 do
		v357 = v346.Name
		v345 = v334.Name
		if v357 == v345 then
			local v449 = v334:FindFirstChild("Button")
			if not v449 then
				v449 = v334.Name
				if v449 == "Keybinds" then
					v345 = v334.Button
					v449 = v345.MouseButton1Down
					v449:Connect(function()
						script.Parent.Events.UpdateValue:FireServer(v346, not v346.Value)
					end)
				end
			end
		end
	end
end
v446 = script
v416 = v446.Parent.Settings.MusicVolume
v443 = v416.TXT
v442 = v443.InputEnded
v442:Connect(function()
	local v461 = script
	local v462 = v461.Parent
	local v463 = v462.Settings
	local v464 = v463.MusicVolume
	local v465 = v464.TXT
	local v467 = tonumber(v465.Text)
	if not v467 then
		v467 = tonumber
		v461 = script
		v462 = v461.Parent
		v463 = v462.Settings
		v464 = v463.MusicVolume
		v465 = v464.TXT
		local v469 = v467(v465.Text)
		v461 = script.Parent
		v462 = v461.Settings
		v463 = v462.MusicVolume
		v464 = v463.TXT
		v465 = v464.Text
		local v472 = tonumber(v465)
		local v473 = 10
		if v472 > v473 then
			v469 = 10
		end
		v463 = script
		v464 = v463.Parent
		v473 = v464.Events
		v472 = v473.UpdateValue
		local v479 = game.Players
		v461 = v479.LocalPlayer
		v462 = v461.Settings
		v463 = v462.UI
		v464 = v463.MusicVolume
		v463 = v469
		v472:FireServer(v464, v463)
		while true do
			wait()
			v479 = game
			v461 = v479.Players
			v462 = v461.LocalPlayer
			v473 = v462.Settings.UI.MusicVolume
			if v473.Value ~= v469 then
				break
			end
		end
		v462 = script
		v476 = v462.Parent
		v477 = v476.Settings
		v478 = v477.MusicVolume.TXT
		v477 = "MusicVolume : "
		v476 = v469
		v478.Text = v477 .. v476
	end
end)
local v483 = script.Parent
v443 = v483.Keybinds
local v484, v485, v483 = pairs(v443:GetChildren())
for v415, v334 in v484, v485, v483 do
	v446 = pairs
	v346 = game
	v349 = v346.Players
	v445 = v349.LocalPlayer
	v447 = v445.Settings
	local v486, v487, v445 = v446(v447:GetDescendants())
	for v349, v346 in v486, v487, v445 do
		v345 = v334.Name
		if v346.Name == v345 then
			local v490 = v334:FindFirstChild("TXT")
			if not v490 then
				v345 = v334.Button
				v490 = v345.MouseButton1Down
				v490:Connect(function()
					local v492 = true
					v334.TXT.Text = "Press key to bind it."
					v33.InputBegan:Connect(function(p3, p4)
						local v496 = p3.KeyCode
						local v497 = Enum.KeyCode.Unknown
						if v496 ~= v497 then
							if p4 == false then
								v496 = v492
								if v496 == true then
									v496 = tostring
									v497 = p3.KeyCode
									script.Parent.Events.UpdateValue:FireServer(v346, string.gsub("" .. v496(v497), "Enum.KeyCode.", ""))
									v492 = false
									return 
								end
							end
						end
					end)
				end)
			end
		end
	end
end
v483 = script.Parent.Values
v485 = v483.SelectedObject
v484 = v485.Changed
v484:Connect(function()
	local v518 = script
	local v519 = v518.Parent
	local v520 = v519.Values
	local v521 = v520.SelectedObject
	local v522 = v521.Value
	if not v522 then
		v519 = script
		v520 = v519.Parent
		v521 = v520.PlayerInfo
		v522 = v521.Selected
		v520 = "Selected Item : "
		v518 = script.Parent.Values.SelectedObject.Value
		v519 = v518.Name
		v521 = v520 .. v519
		v522.Text = v521
		return 
	end
	script.Parent.PlayerInfo.Selected.Text = "Selected Item : None"
end)
v486 = script
v485 = v486.Parent.Emotes.Emote1.Button
v485.MouseButton1Down:Connect(function()
	local v534 = script
	local v535 = v534.Parent
	local v536 = v535.Values
	local v537 = v536.SelectedObject
	local v538 = v537.Value
	if not v538 then
		local v539 = script
		local v540 = v539.Parent
		v534 = v540.Values
		v535 = v534.SelectedObject
		v536 = v535.Value
		v537 = v536.Parent
		v538 = v537.Name
		if v538 == "Emotes" then
			v535 = script
			v536 = v535.Parent
			v537 = v536.Sounds
			v538 = v537.Click
			v538:Play()
			v539 = script
			v540 = v539.Parent
			v534 = v540.Values
			v535 = v534.SelectedObject
			v536 = v535.Value
			v537 = v536.Parent
			local v541 = v537.Parent
			v540 = script
			v534 = v540.Parent
			v535 = v534.Values
			v536 = v535.SelectedEmote
			v537 = v536.Value
			v540 = ""
			v539 = v541.Name
			v534 = v540 .. v539 .. "-Emotes"
			v540 = ""
			v539 = v541.Name
			v539 = script
			v540 = v539.Parent
			v535 = v540.Events.EquipEmote
			v540 = v537
			v539 = (v541:FindFirstChild(v534)):FindFirstChild(v540 .. v539 .. "-Emote1")
			v535:FireServer(v540, v539)
			script.Parent.Emotes.Emote1.TXT.Text = "Equipped"
			wait(0.15)
			script.Parent.Emotes.Visible = false
		end
	end
end)
v486 = script
v485 = v486.Parent.Emotes.Emote2.Button
v485.MouseButton1Down:Connect(function()
	local v562 = script
	local v563 = v562.Parent
	local v564 = v563.Values
	local v565 = v564.SelectedObject
	local v566 = v565.Value
	if not v566 then
		local v567 = script
		local v568 = v567.Parent
		v562 = v568.Values
		v563 = v562.SelectedObject
		v564 = v563.Value
		v565 = v564.Parent
		v566 = v565.Name
		if v566 == "Emotes" then
			v563 = script
			v564 = v563.Parent
			v565 = v564.Sounds
			v566 = v565.Click
			v566:Play()
			v567 = script
			v568 = v567.Parent
			v562 = v568.Values
			v563 = v562.SelectedObject
			v564 = v563.Value
			v565 = v564.Parent
			local v569 = v565.Parent
			v568 = script
			v562 = v568.Parent
			v563 = v562.Values
			v564 = v563.SelectedEmote
			v565 = v564.Value
			v568 = ""
			v567 = v569.Name
			v562 = v568 .. v567 .. "-Emotes"
			v568 = ""
			v567 = v569.Name
			v567 = script
			v568 = v567.Parent
			v563 = v568.Events.EquipEmote
			v568 = v565
			v567 = (v569:FindFirstChild(v562)):FindFirstChild(v568 .. v567 .. "-Emote2")
			v563:FireServer(v568, v567)
			script.Parent.Emotes.Emote2.TXT.Text = "Equipped"
			wait(0.15)
			script.Parent.Emotes.Visible = false
		end
	end
end)
v486 = script
v485 = v486.Parent.Emotes.Emote3.Button
v485.MouseButton1Down:Connect(function()
	local v590 = script
	local v591 = v590.Parent
	local v592 = v591.Values
	local v593 = v592.SelectedObject
	local v594 = v593.Value
	if not v594 then
		local v595 = script
		local v596 = v595.Parent
		v590 = v596.Values
		v591 = v590.SelectedObject
		v592 = v591.Value
		v593 = v592.Parent
		v594 = v593.Name
		if v594 == "Emotes" then
			v591 = script
			v592 = v591.Parent
			v593 = v592.Sounds
			v594 = v593.Click
			v594:Play()
			v595 = script
			v596 = v595.Parent
			v590 = v596.Values
			v591 = v590.SelectedObject
			v592 = v591.Value
			v593 = v592.Parent
			local v597 = v593.Parent
			v596 = script
			v590 = v596.Parent
			v591 = v590.Values
			v592 = v591.SelectedEmote
			v593 = v592.Value
			v596 = ""
			v595 = v597.Name
			v590 = v596 .. v595 .. "-Emotes"
			v596 = ""
			v595 = v597.Name
			v595 = script
			v596 = v595.Parent
			v591 = v596.Events.EquipEmote
			v596 = v593
			v595 = (v597:FindFirstChild(v590)):FindFirstChild(v596 .. v595 .. "-Emote3")
			v591:FireServer(v596, v595)
			script.Parent.Emotes.Emote3.TXT.Text = "Equipped"
			wait(0.15)
			script.Parent.Emotes.Visible = false
		end
	end
end)
v486 = script
v485 = v486.Parent.Emotes.Emote4.Button
v485.MouseButton1Down:Connect(function()
	local v618 = script
	local v619 = v618.Parent
	local v620 = v619.Values
	local v621 = v620.SelectedObject
	local v622 = v621.Value
	if not v622 then
		local v623 = script
		local v624 = v623.Parent
		v618 = v624.Values
		v619 = v618.SelectedObject
		v620 = v619.Value
		v621 = v620.Parent
		v622 = v621.Name
		if v622 == "Emotes" then
			v619 = script
			v620 = v619.Parent
			v621 = v620.Sounds
			v622 = v621.Click
			v622:Play()
			v623 = script
			v624 = v623.Parent
			v618 = v624.Values
			v619 = v618.SelectedObject
			v620 = v619.Value
			v621 = v620.Parent
			local v625 = v621.Parent
			v624 = script
			v618 = v624.Parent
			v619 = v618.Values
			v620 = v619.SelectedEmote
			v621 = v620.Value
			v624 = ""
			v623 = v625.Name
			v618 = v624 .. v623 .. "-Emotes"
			v624 = ""
			v623 = v625.Name
			v623 = script
			v624 = v623.Parent
			v619 = v624.Events.EquipEmote
			v624 = v621
			v623 = (v625:FindFirstChild(v618)):FindFirstChild(v624 .. v623 .. "-Emote4")
			v619:FireServer(v624, v623)
			script.Parent.Emotes.Emote4.TXT.Text = "Equipped"
			wait(0.15)
			script.Parent.Emotes.Visible = false
		end
	end
end)
v486 = script
v485 = v486.Parent.Prompt.PromptImage.Close
v485.MouseButton1Down:Connect(function()
	script.Parent.Sounds.Click:Play()
	script.Parent.Prompt.Visible = false
end)
v33.InputBegan:Connect(function(p5)
	local v656 = p5.KeyCode
	local v657 = Enum.KeyCode.ButtonB
	if v656 == v657 then
		local v659 = script.Parent
		local v660 = v659.Prompt
		v657 = v660.PromptImage
		v656 = v657.Visible
		if v656 == true then
			v659 = script
			v660 = v659.Parent
			v657 = v660.Sounds
			v656 = v657.Click
			v656:Play()
			v660 = script
			v657 = v660.Parent
			v657 = false
			v657.Prompt.Visible = v657
		end
	end
	v661 = p5.KeyCode
	local v708 = Enum.KeyCode.ButtonY
	if v661 == v708 then
		v658 = script
		v659 = v658.Parent
		v660 = v659.Prompt
		v708 = v660.PromptImage
		v661 = v708.Visible
		if v661 == true then
			v661 = v30
			if v661 == false then
				v661 = true
				v30 = v661
				v659 = script
				v660 = v659.Parent
				v708 = v660.Sounds
				v661 = v708.Click
				v661:Play()
				v658 = script
				v659 = v658.Parent
				v660 = v659.Values
				v708 = v660.SelectedObject
				local v662 = v708.Value
				if not v662 then
					local v663 = script
					v658 = v663.Parent
					v659 = v658.Values
					v660 = v659.SelectedObject
					v708 = v660.Value
					v662 = v708.Value
					if v662 == false then
						v660 = v37
						v708 = v660.GCells
						v662 = v708.Value
						v659 = v34
						v660 = v659.Cost
						v708 = v660.Value
						if v662 >= v708 then
							v658 = script
							v659 = v658.Parent
							v660 = v659.Values
							v708 = v660.SelectedObject
							v662 = v708.Value
							v660 = "Onsale"
							local v664 = v662:GetAttribute(v660)
							if v664 == true then
								v658 = script
								v659 = v658.Parent
								v708 = v659.Prompt.PromptImage
								v664 = v708.PromptInfo
								v708 = "Bought Item!"
								v664.Text = v708
								v659 = script
								v708 = v659.Parent.Events
								v664 = v708.BuyItem
								v663 = script.Parent
								v658 = v663.Values
								v659 = v658.SelectedObject
								v663 = v34
								v658 = v663.Cost
								v659 = v658.Value
								v664:FireServer(v659.Value, v659)
								v708 = 0.35
								wait(v708)
								script.Parent.Prompt.Visible = false
								v30 = false
								return 
							end
						end
						v668 = v37
						v669 = v668.GCells
						v670 = v669.Value
						local v671 = v34
						v668 = v671.Cost
						v669 = v668.Value
						if v669 > v670 then
							v658 = script
							v671 = v658.Parent
							v668 = v671.Values
							v669 = v668.SelectedObject
							v670 = v669.Value
							v668 = "Onsale"
							local v672 = v670:GetAttribute(v668)
							if v672 == true then
								v663 = script
								v658 = v663.Parent
								v671 = v658.Prompt
								v669 = v671.PromptImage.PromptInfo
								v672 = v669.Text
								v663 = script
								v658 = v663.Parent
								v671 = v658.Prompt
								v669 = v671.PromptImage.PromptInfo
								v669.Text = "Not enough GCells!"
								v669 = wait
								v669(0.5)
								v663 = script
								v658 = v663.Parent
								v671 = v658.Prompt
								v671.PromptImage.PromptInfo.Text = v672
								v30 = false
								return 
							end
						end
					end
				end
				v658 = script
				v671 = v658.Parent
				v674 = v671.Values
				v675 = v674.SelectedObject
				v672 = v675.Value
				if not v672 then
					v663 = script
					v658 = v663.Parent
					v671 = v658.Values
					v674 = v671.SelectedObject
					v675 = v674.Value
					v672 = v675.Value
					if v672 == true then
						v666 = script
						v663 = v666.Parent
						v658 = v663.Values
						v671 = v658.SelectedObject
						v674 = v671.Value
						v675 = v674.Parent
						v672 = v675.Name
						if v672 == "Skins" then
							v658 = script
							v671 = v658.Parent
							v674 = v671.Prompt
							v675 = v674.PromptImage
							v672 = v675.PromptInfo
							v675 = "Equipped Item!"
							v672.Text = v675
							v671 = script
							v674 = v671.Parent
							v675 = v674.Events
							v672 = v675.EquipSkin
							v666 = script
							v663 = v666.Parent
							v658 = v663.Values
							v671 = v658.SelectedObject
							v674 = v671.Value
							v672:FireServer(v674)
							v675 = 0.35
							wait(v675)
							script.Parent.Prompt.Visible = false
							v30 = false
							return 
						end
					end
				end
				v658 = script
				v671 = v658.Parent
				v677 = v671.Values
				v678 = v677.SelectedObject
				v679 = v678.Value
				if not v679 then
					v663 = script
					v658 = v663.Parent
					v671 = v658.Values
					v677 = v671.SelectedObject
					v678 = v677.Value
					v679 = v678.Value
					if v679 == true then
						v666 = script
						v663 = v666.Parent
						v658 = v663.Values
						v671 = v658.SelectedObject
						v677 = v671.Value
						v678 = v677.Parent
						v679 = v678.Name
						if v679 == "Emotes" then
							v666 = script
							v663 = v666.Parent
							v658 = v663.Values
							v671 = v658.SelectedObject
							v677 = v671.Value
							v678 = v677.Parent
							v679 = v678.Parent
							v678 = pairs
							v666 = game
							v663 = v666.ReplicatedStorage
							v658 = v663.Assets
							v671 = v658.Kaijus
							v677 = v671.EmoteScripts
							local v680, v681, v671 = v678(v677:GetDescendants())
							for v658, v663 in v680, v681, v671 do
								local v683 = v663:IsA("LocalScript")
								if not v683 then
									v683 = v663.Name
									local v691 = (v679:FindFirstChild("" .. v679.Name .. "-Emotes")):FindFirstChild("" .. v679.Name .. "-Emote1")
									local v692 = v691.Value
									if v683 == v692 then
										v691 = script.Parent.Emotes
										v692 = v691.Emote1
										v683 = v692.TXT
										v691 = v663.EmoteName
										v692 = v691.Value
										v683.Text = v692
									end
									v683 = v663.Name
									v693 = "" .. v679.Name .. "-Emotes"
									local v697 = (v679:FindFirstChild(v693)):FindFirstChild("" .. v679.Name .. "-Emote2")
									local v728 = v697.Value
									if v683 == v728 then
										v694 = script.Parent
										v697 = v694.Emotes
										v728 = v697.Emote2
										v683 = v728.TXT
										v697 = v663.EmoteName
										v728 = v697.Value
										v683.Text = v728
									end
									v683 = v663.Name
									v698 = "" .. v679.Name .. "-Emotes"
									local v701 = (v679:FindFirstChild(v698)):FindFirstChild("" .. v679.Name .. "-Emote3")
									local v735 = v701.Value
									if v683 == v735 then
										v694 = script.Parent
										v701 = v694.Emotes
										v735 = v701.Emote3
										v683 = v735.TXT
										v701 = v663.EmoteName
										v735 = v701.Value
										v683.Text = v735
									end
									v683 = v663.Name
									v702 = "" .. v679.Name .. "-Emotes"
									local v705 = (v679:FindFirstChild(v702)):FindFirstChild("" .. v679.Name .. "-Emote4")
									local v742 = v705.Value
									if v683 == v742 then
										v694 = script.Parent
										v705 = v694.Emotes
										v742 = v705.Emote4
										v683 = v742.TXT
										v705 = v663.EmoteName
										v742 = v705.Value
										v683.Text = v742
									end
								end
							end
							v671 = script
							v681 = v671.Parent
							v680 = v681.Prompt
							v681 = false
							v680.Visible = v681
							v671 = script
							v681 = v671.Parent
							v680 = v681.Emotes
							v681 = true
							v680.Visible = v681
							v680 = false
							v30 = v680
							return 
						end
					end
				end
				v679 = wait
				v680 = 0.15
				v679(v680)
				v30 = false
			end
		end
	end
end)
v486 = script
v485 = v486.Parent.Prompt.PromptImage.Select
v485.MouseButton1Down:Connect(function()
	local v745 = v30
	if v745 == false then
		v745 = true
		v30 = v745
		v745 = script.Parent.Sounds.Click
		v745:Play()
		local v749 = script
		local v796 = v749.Parent
		local v797 = v796.Values
		local v798 = v797.SelectedObject
		local v750 = v798.Value
		if not v750 then
			local v751 = script
			v749 = v751.Parent
			v796 = v749.Values
			v797 = v796.SelectedObject
			v798 = v797.Value
			v750 = v798.Value
			if v750 == false then
				v797 = v37
				v798 = v797.GCells
				v750 = v798.Value
				v796 = v34
				v797 = v796.Cost
				v798 = v797.Value
				if v750 >= v798 then
					v749 = script
					v796 = v749.Parent
					v797 = v796.Values
					v798 = v797.SelectedObject
					v750 = v798.Value
					v797 = "Onsale"
					local v752 = v750:GetAttribute(v797)
					if v752 == true then
						v749 = script
						v796 = v749.Parent
						v798 = v796.Prompt.PromptImage
						v752 = v798.PromptInfo
						v798 = "Bought Item!"
						v752.Text = v798
						v796 = script
						v798 = v796.Parent.Events
						v752 = v798.BuyItem
						v751 = script.Parent
						v749 = v751.Values
						v796 = v749.SelectedObject
						v751 = v34
						v749 = v751.Cost
						v796 = v749.Value
						v752:FireServer(v796.Value, v796)
						v798 = 0.35
						wait(v798)
						script.Parent.Prompt.Visible = false
						v30 = false
						return 
					end
				end
				v756 = v37
				v757 = v756.GCells
				v758 = v757.Value
				local v759 = v34
				v756 = v759.Cost
				v757 = v756.Value
				if v757 > v758 then
					v749 = script
					v759 = v749.Parent
					v756 = v759.Values
					v757 = v756.SelectedObject
					v758 = v757.Value
					v756 = "Onsale"
					local v760 = v758:GetAttribute(v756)
					if v760 == true then
						v751 = script
						v749 = v751.Parent
						v759 = v749.Prompt
						v757 = v759.PromptImage.PromptInfo
						v760 = v757.Text
						v751 = script
						v749 = v751.Parent
						v759 = v749.Prompt
						v757 = v759.PromptImage.PromptInfo
						v757.Text = "Not enough GCells!"
						v757 = wait
						v757(0.5)
						v751 = script
						v749 = v751.Parent
						v759 = v749.Prompt
						v759.PromptImage.PromptInfo.Text = v760
						v30 = false
						return 
					end
				end
			end
		end
		local v807 = script
		v759 = v807.Parent
		v762 = v759.Values
		v763 = v762.SelectedObject
		v760 = v763.Value
		if not v760 then
			v751 = script
			v807 = v751.Parent
			v759 = v807.Values
			v762 = v759.SelectedObject
			v763 = v762.Value
			v760 = v763.Value
			if v760 == true then
				v754 = script
				v751 = v754.Parent
				v807 = v751.Values
				v759 = v807.SelectedObject
				v762 = v759.Value
				v763 = v762.Parent
				v760 = v763.Name
				if v760 == "Skins" then
					v807 = script
					v759 = v807.Parent
					v762 = v759.Prompt
					v763 = v762.PromptImage
					v760 = v763.PromptInfo
					v763 = "Equipped Item!"
					v760.Text = v763
					v759 = script
					v762 = v759.Parent
					v763 = v762.Events
					v760 = v763.EquipSkin
					v754 = script
					v751 = v754.Parent
					v807 = v751.Values
					v759 = v807.SelectedObject
					v762 = v759.Value
					v760:FireServer(v762)
					v763 = 0.35
					wait(v763)
					script.Parent.Prompt.Visible = false
					v30 = false
					return 
				end
			end
		end
		local v810 = script
		v759 = v810.Parent
		v765 = v759.Values
		v766 = v765.SelectedObject
		v767 = v766.Value
		if not v767 then
			v751 = script
			v810 = v751.Parent
			v759 = v810.Values
			v765 = v759.SelectedObject
			v766 = v765.Value
			v767 = v766.Value
			if v767 == true then
				v754 = script
				v751 = v754.Parent
				v810 = v751.Values
				v759 = v810.SelectedObject
				v765 = v759.Value
				v766 = v765.Parent
				v767 = v766.Name
				if v767 == "Emotes" then
					v754 = script
					v751 = v754.Parent
					v810 = v751.Values
					v759 = v810.SelectedObject
					v765 = v759.Value
					v766 = v765.Parent
					v767 = v766.Parent
					v766 = pairs
					v754 = game
					v751 = v754.ReplicatedStorage
					v810 = v751.Assets
					v759 = v810.Kaijus
					v765 = v759.EmoteScripts
					local v768, v769, v759 = v766(v765:GetDescendants())
					for v749, v751 in v768, v769, v759 do
						local v771 = v751:IsA("LocalScript")
						if not v771 then
							v771 = v751.Name
							local v779 = (v767:FindFirstChild("" .. v767.Name .. "-Emotes")):FindFirstChild("" .. v767.Name .. "-Emote1")
							local v780 = v779.Value
							if v771 == v780 then
								v779 = script.Parent.Emotes
								v780 = v779.Emote1
								v771 = v780.TXT
								v779 = v751.EmoteName
								v780 = v779.Value
								v771.Text = v780
							end
							v771 = v751.Name
							v781 = "" .. v767.Name .. "-Emotes"
							local v785 = (v767:FindFirstChild(v781)):FindFirstChild("" .. v767.Name .. "-Emote2")
							local v820 = v785.Value
							if v771 == v820 then
								v782 = script.Parent
								v785 = v782.Emotes
								v820 = v785.Emote2
								v771 = v820.TXT
								v785 = v751.EmoteName
								v820 = v785.Value
								v771.Text = v820
							end
							v771 = v751.Name
							v786 = "" .. v767.Name .. "-Emotes"
							local v789 = (v767:FindFirstChild(v786)):FindFirstChild("" .. v767.Name .. "-Emote3")
							local v827 = v789.Value
							if v771 == v827 then
								v782 = script.Parent
								v789 = v782.Emotes
								v827 = v789.Emote3
								v771 = v827.TXT
								v789 = v751.EmoteName
								v827 = v789.Value
								v771.Text = v827
							end
							v771 = v751.Name
							v790 = "" .. v767.Name .. "-Emotes"
							local v793 = (v767:FindFirstChild(v790)):FindFirstChild("" .. v767.Name .. "-Emote4")
							local v834 = v793.Value
							if v771 == v834 then
								v782 = script.Parent
								v793 = v782.Emotes
								v834 = v793.Emote4
								v771 = v834.TXT
								v793 = v751.EmoteName
								v834 = v793.Value
								v771.Text = v834
							end
						end
					end
					v759 = script
					v769 = v759.Parent
					v768 = v769.Prompt
					v769 = false
					v768.Visible = v769
					v759 = script
					v769 = v759.Parent
					v768 = v769.Emotes
					v769 = true
					v768.Visible = v769
					v768 = false
					v30 = v768
					return 
				end
			end
		end
		v767 = wait
		v768 = 0.15
		v767(v768)
		v30 = false
	end
end)
v486 = script
v485 = v486.Parent.Parent.MenuButton.Button
v485.MouseButton1Down:Connect(function()
	local v837 = v30
	if v837 == false then
		v837 = true
		v30 = v837
		v837 = script.Parent.MainMenu
		local v840 = script
		local v922 = v840.Parent
		local v923 = v922.Visible
		if v923 == false then
			v840 = script.Parent
			v922 = v840.MainMenu
			v923 = v922.Position
			local v842 = script
			local v843 = v842.Parent
			local v844 = v843.MainMenu
			local v924 = v844.Positions
			v840 = v924.StartPos
			v922 = v840.Position
			if v923 == v922 then
				v923 = true
				v837.Visible = v923
				v922 = script
				v923 = v922.Parent
				v922 = true
				v923.Visible = v922
				v840 = script
				v922 = v840.Parent
				v923 = v922.PlayerInfo
				v840 = UDim2.new
				v924 = 0
				v844 = 0
				v843 = 0
				v842 = 0
				v923:TweenPosition(v840(v924, v844, v843, v842), "InOut", "Linear", 0.45)
				v922 = script.Parent
				v922 = true
				v922.PlayerInfo.Visible = v922
				local v926 = script.Parent
				v922 = v926.MainMenu
				local v852, v853, v849 = pairs(v922:GetChildren())
				for v851, v856 in v852, v853, v926 do
					local v857 = v856:IsA("ImageButton")
					if not v857 then
						v857 = v856.Name
						if v857 == "MenuToggle" then
							v857 = true
							v856.Visible = v857
						end
					end
				end
				local v927 = game
				v926 = v927.Players
				v853 = v926.LocalPlayer
				v852 = v853.PlayerGui
				local v858 = v852:FindFirstChild("GameGui")
				if not v858 then
					v857 = script
					v856 = v857.Parent
					v927 = v856.Parent
					v853 = v927.Parent.GameGui
					v858 = v853.Character
					v853 = false
					v858.Visible = v853
				end
				v859 = script.Parent
				v853 = v859.Sounds
				v853.Slide:Play()
				v853 = true
				v31.Disabled = v853
				v859 = v837
				v857 = v837.TweenSpeed
				v856 = v857.Value
				local v862 = {}
				v857 = v837.Positions.EndPos.Position
				v862.Position = v857
				local v865 = v21:Create(v859, TweenInfo.new(v856), v862)
				v865:Play()
				v865.Completed:Connect(function()
					v30 = false
				end)
				v30 = false
				return 
			end
		end
		v869 = script.Parent.MainMenu
		v865 = v869.Position
		v864 = script
		v857 = v864.Parent
		local v872 = v857.MainMenu
		local v933 = v872.Positions
		local v934 = v933.EndPos
		v869 = v934.Position
		if v865 == v869 then
			v933 = script
			v934 = v933.Parent
			v869 = v934.Sounds
			v865 = v869.Slide
			v865:Play()
			v933 = game
			v934 = v933.Players
			v869 = v934.LocalPlayer
			v934 = "GameGui"
			local v874 = v869.PlayerGui:FindFirstChild(v934)
			if not v874 then
				v872 = script
				v933 = v872.Parent
				v869 = v933.Parent.Parent
				v874 = v869.GameGui
				v869 = true
				v874.Enabled = v869
				v857 = script
				v872 = v857.Parent
				v933 = v872.Parent
				v869 = v933.Parent.GameGui
				v874 = v869.Character
				v869 = true
				v874.Visible = v869
			end
			v869 = false
			v31.Disabled = v869
			v875 = v837
			v933 = TweenInfo.new
			v857 = v837.TweenSpeed
			v872 = v857.Value
			local v877 = {}
			v863 = v837.Positions
			v864 = v863.StartPos
			v857 = v864.Position
			v877.Position = v857
			(v21:Create(v875, v933(v872), v877)):Play()
			local v880 = script
			local v882, v883, v880 = pairs(v880.Parent:GetDescendants())
			for v905, v857 in v882, v883, v880 do
				local v885 = v857:FindFirstChild("Object")
				if not v885 then
					v885 = v857.Name
					if v885 == "MenuToggle" then
						v863 = v857.Object
						v885 = v863.Value
						if not v885 then
							v863 = v857.Object
							v885 = v863.Value
							local v887 = v885:FindFirstChild("TweenSpeed")
							if not v887 then
								v887 = v21
								local v895 = {}
								v895.Position = v857.Object.Value.Positions.StartPos.Position
								local v898 = v887:Create(v857.Object.Value, TweenInfo.new(v857.Object.Value.TweenSpeed.Value), v895)
								v898:Play()
								v898.Completed:Connect(function()
									v857.Object.Value.Visible = false
								end)
							end
						end
					end
				end
			end
			v880 = script
			v883 = v880.Parent
			v882 = v883.PlayerInfo
			v905 = -0.75
			v857 = 0
			v898 = 0
			v882:TweenPosition(UDim2.new(v905, v857, v898, 0), "InOut", "Linear", 0.35)
			v883 = 0.35
			wait(v883)
			script.Parent.Visible = false
			v837.Visible = false
			script.Parent.PlayerInfo.Visible = false
			local v949 = script.Parent
			local v916, v917, v914 = pairs(v949.MainMenu:GetChildren())
			for v915, v920 in v916, v917, v949 do
				local v921 = v920:IsA("ImageButton")
				if not v921 then
					v921 = v920.Name
					if v921 == "MenuToggle" then
						v921 = false
						v920.Visible = v921
					end
				end
			end
			v916 = false
			v30 = v916
		end
		v878 = false
		v30 = v878
	end
end)
v33.InputBegan:Connect(function(p6, p7)
	local v953 = p6.KeyCode
	local v954 = Enum.KeyCode.M
	if v953 == v954 then
		if p7 == false then
			v953 = v30
			if v953 == false then
				v953 = true
				v30 = v953
				v954 = script.Parent
				v953 = v954.MainMenu
				local v956 = script
				local v1038 = v956.Parent
				v954 = v1038.Visible
				if v954 == false then
					v956 = script.Parent
					v1038 = v956.MainMenu
					v954 = v1038.Position
					local v958 = script
					local v959 = v958.Parent
					local v960 = v959.MainMenu
					local v1039 = v960.Positions
					v956 = v1039.StartPos
					v1038 = v956.Position
					if v954 == v1038 then
						v954 = true
						v953.Visible = v954
						v1038 = script
						v954 = v1038.Parent
						v1038 = true
						v954.Visible = v1038
						v956 = script
						v1038 = v956.Parent
						v954 = v1038.PlayerInfo
						v956 = UDim2.new
						v1039 = 0
						v960 = 0
						v959 = 0
						v958 = 0
						v954:TweenPosition(v956(v1039, v960, v959, v958), "InOut", "Linear", 0.45)
						v1038 = script.Parent
						v1038 = true
						v1038.PlayerInfo.Visible = v1038
						local v1041 = script.Parent
						v1038 = v1041.MainMenu
						local v968, v969, v965 = pairs(v1038:GetChildren())
						for v967, v972 in v968, v969, v1041 do
							local v973 = v972:IsA("ImageButton")
							if not v973 then
								v973 = v972.Name
								if v973 == "MenuToggle" then
									v973 = true
									v972.Visible = v973
								end
							end
						end
						local v1042 = game
						v1041 = v1042.Players
						v969 = v1041.LocalPlayer
						v968 = v969.PlayerGui
						local v974 = v968:FindFirstChild("GameGui")
						if not v974 then
							v973 = script
							v972 = v973.Parent
							v1042 = v972.Parent
							v969 = v1042.Parent.GameGui
							v974 = v969.Character
							v969 = false
							v974.Visible = v969
						end
						v975 = script.Parent
						v969 = v975.Sounds
						v969.Slide:Play()
						v969 = true
						v31.Disabled = v969
						v975 = v953
						v973 = v953.TweenSpeed
						v972 = v973.Value
						local v978 = {}
						v973 = v953.Positions.EndPos.Position
						v978.Position = v973
						local v981 = v21:Create(v975, TweenInfo.new(v972), v978)
						v981:Play()
						v981.Completed:Connect(function()
							v30 = false
						end)
						v30 = false
						return 
					end
				end
				v985 = script.Parent.MainMenu
				v981 = v985.Position
				v980 = script
				v973 = v980.Parent
				local v988 = v973.MainMenu
				local v1048 = v988.Positions
				local v1049 = v1048.EndPos
				v985 = v1049.Position
				if v981 == v985 then
					v1048 = script
					v1049 = v1048.Parent
					v985 = v1049.Sounds
					v981 = v985.Slide
					v981:Play()
					v1048 = game
					v1049 = v1048.Players
					v985 = v1049.LocalPlayer
					v1049 = "GameGui"
					local v990 = v985.PlayerGui:FindFirstChild(v1049)
					if not v990 then
						v988 = script
						v1048 = v988.Parent
						v985 = v1048.Parent.Parent
						v990 = v985.GameGui
						v985 = true
						v990.Enabled = v985
						v973 = script
						v988 = v973.Parent
						v1048 = v988.Parent
						v985 = v1048.Parent.GameGui
						v990 = v985.Character
						v985 = true
						v990.Visible = v985
					end
					v985 = false
					v31.Disabled = v985
					v991 = v953
					v1048 = TweenInfo.new
					v973 = v953.TweenSpeed
					v988 = v973.Value
					local v993 = {}
					v979 = v953.Positions
					v980 = v979.StartPos
					v973 = v980.Position
					v993.Position = v973
					(v21:Create(v991, v1048(v988), v993)):Play()
					local v996 = script
					local v998, v999, v996 = pairs(v996.Parent:GetDescendants())
					for v1021, v973 in v998, v999, v996 do
						local v1001 = v973:FindFirstChild("Object")
						if not v1001 then
							v1001 = v973.Name
							if v1001 == "MenuToggle" then
								v979 = v973.Object
								v1001 = v979.Value
								if not v1001 then
									v979 = v973.Object
									v1001 = v979.Value
									local v1003 = v1001:FindFirstChild("TweenSpeed")
									if not v1003 then
										v1003 = v21
										local v1011 = {}
										v1011.Position = v973.Object.Value.Positions.StartPos.Position
										local v1014 = v1003:Create(v973.Object.Value, TweenInfo.new(v973.Object.Value.TweenSpeed.Value), v1011)
										v1014:Play()
										v1014.Completed:Connect(function()
											v973.Object.Value.Visible = false
										end)
									end
								end
							end
						end
					end
					v996 = script
					v999 = v996.Parent
					v998 = v999.PlayerInfo
					v1021 = -0.75
					v973 = 0
					v1014 = 0
					v998:TweenPosition(UDim2.new(v1021, v973, v1014, 0), "InOut", "Linear", 0.35)
					v999 = 0.35
					wait(v999)
					script.Parent.Visible = false
					v953.Visible = false
					script.Parent.PlayerInfo.Visible = false
					local v1064 = script.Parent
					local v1032, v1033, v1030 = pairs(v1064.MainMenu:GetChildren())
					for v1031, v1036 in v1032, v1033, v1064 do
						local v1037 = v1036:IsA("ImageButton")
						if not v1037 then
							v1037 = v1036.Name
							if v1037 == "MenuToggle" then
								v1037 = false
								v1036.Visible = v1037
							end
						end
					end
					v1032 = false
					v30 = v1032
				end
				v994 = false
				v30 = v994
			end
		end
	end
end)
v485 = v34.KaijuMenu
v485.Changed:Connect(function()
	local v1068 = v34
	local v1069 = v1068.KaijuMenu
	local v1070 = v1069.Value
	if not v1070 then
		v1069 = v49
		v1070 = v1069 + 1
		v49 = v1070
		v1070 = v49
		v1068 = v34.KaijuMenu.Value.SelectStores.Select.Button
		v1069 = v1068.MouseButton1Down
		v1069:Connect(function()
			local v1076 = v34
			local v1077 = v1076.SelectedKaiju
			local v1078 = v1077.Value
			if not v1078 then
				v1076 = script.Parent
				v1077 = v1076.Sounds
				v1078 = v1077.Click
				v1078:Play()
				v1076 = script.Parent
				v1077 = v1076.Events
				v1076 = v34.SelectedKaiju.Value
				v1077.EquipKaiju:FireServer(v1076)
			end
		end)
		v1068 = v34.KaijuMenu.Value.Left
		v1068.MouseButton1Down:Connect(function()
			local v1086 = v49
			local v1087 = v1070
			if v1086 == v1087 then
				break
			end
			v1086 = true
			v47 = v1086
			while true do
				v1086 = wait
				v1087 = 0.025
				v1086(v1087)
				v34.KaijuModel.Value.HumanoidRootPart.CFrame = v34.KaijuModel.Value.HumanoidRootPart.CFrame * CFrame.Angles(0, -0.085, 0)
				if v47 == false then
					break
				end
			end
		end)
		v1068 = v34.KaijuMenu.Value.Left
		v1068.MouseButton1Up:Connect(function()
			v47 = false
		end)
		v1068 = v34.KaijuMenu.Value.Left
		v1068.MouseLeave:Connect(function()
			v47 = false
		end)
		v1068 = v34.KaijuMenu.Value.Right
		v1068.MouseButton1Down:Connect(function()
			local v1112 = v49
			local v1113 = v1070
			if v1112 == v1113 then
				break
			end
			v1112 = true
			v48 = v1112
			while true do
				v1112 = wait
				v1113 = 0.025
				v1112(v1113)
				v34.KaijuModel.Value.HumanoidRootPart.CFrame = v34.KaijuModel.Value.HumanoidRootPart.CFrame * CFrame.Angles(0, 0.085, 0)
				if v48 == false then
					break
				end
			end
		end)
		v1068 = v34.KaijuMenu.Value.Right
		v1068.MouseButton1Up:Connect(function()
			v48 = false
		end)
		v1068 = v34.KaijuMenu.Value.Right
		v1068.MouseLeave:Connect(function()
			v48 = false
		end)
		return 
	end
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	v1073 = game
	v1074 = v1073.Players
	v24.CameraSubject = v1074.LocalPlayer.Character.Humanoid
end)
local v1162 = false
local function UnlockItems_1(p8)
	while true do
		wait()
		if v1162 == false then
			break
		end
	end
	v1165 = true
	v1162 = v1165
	v1165 = nil
	local v1166
	local v1167
	local v1168
	local v1170 = v37.GCells
	local v1171 = v1170.Value
	v1170 = 0
	local function RollItem_1()
		local v1176 = math.random(0, 950)
		local v1177 = p8
		local v1178 = v1177.Name
		if v1178 == "Item1" then
			v1178 = math.random
			v1177 = 1
			local v1180 = v1178(v1177, 11)
			if v1180 == 1 then
				if v1180 == 2 then
					if v1180 == 3 then
						v1165 = "GCells"
					end
					if v1180 == 4 then
						if v1180 == 5 then
							if v1180 == 6 then
								v1181 = "XP"
								v1165 = v1181
							end
							if v1180 == 7 then
								if v1180 == 8 then
									v1181 = "Skins"
									v1165 = v1181
								end
								if v1180 == 9 then
									if v1180 == 10 then
										if v1180 == 11 then
											v1181 = "Emotes"
											v1165 = v1181
										end
										v1181 = p8
										v1180 = v1181.Name
										if v1180 == "Item2" then
											v1180 = math.random
											v1181 = 1
											local v1183 = v1180(v1181, 10)
											if v1183 == 1 then
												if v1183 == 2 then
													if v1183 == 3 then
														v1165 = "Skins"
													end
													if v1183 == 4 then
														if v1183 == 5 then
															if v1183 == 6 then
																v1184 = "Emotes"
																v1165 = v1184
															end
															if v1183 == 7 then
																if v1183 == 8 then
																	v1184 = "GCells"
																	v1165 = v1184
																end
																if v1183 == 9 then
																	if v1183 == 10 then
																		v1184 = "XP"
																		v1165 = v1184
																	end
																	v1184 = p8
																	v1183 = v1184.Name
																	if v1183 == "Item3" then
																		v1183 = math.random
																		v1184 = 1
																		local v1186 = v1183(v1184, 11)
																		if v1186 == 1 then
																			if v1186 == 2 then
																				if v1186 == 3 then
																					v1165 = "GCells"
																				end
																				if v1186 == 4 then
																					if v1186 == 5 then
																						if v1186 == 6 then
																							v1187 = "XP"
																							v1165 = v1187
																						end
																						if v1186 == 7 then
																							if v1186 == 8 then
																								v1187 = "Emotes"
																								v1165 = v1187
																							end
																							if v1186 == 9 then
																								if v1186 == 10 then
																									if v1186 == 11 then
																										v1187 = "Skins"
																										v1165 = v1187
																									end
																									v1187 = p8
																									v1186 = v1187.ItemType
																									v1187 = v1165
																									v1186.Value = v1187
																									v1186 = 90
																									if v1186 >= v1176 then
																										v1186 = "Legendary"
																										v1166 = v1186
																									end
																									v1186 = 90
																									if v1176 > v1186 then
																										v1186 = 225
																										if v1186 >= v1176 then
																											v1186 = "Epic"
																											v1166 = v1186
																										end
																									end
																									v1186 = 225
																									if v1176 > v1186 then
																										v1186 = 465
																										if v1186 >= v1176 then
																											v1186 = "Rare"
																											v1166 = v1186
																										end
																									end
																									v1186 = 465
																									if v1176 > v1186 then
																										v1186 = 950
																										if v1186 >= v1176 then
																											v1186 = "Uncommon"
																											v1166 = v1186
																										end
																									end
																									v1186 = v1165
																									if v1186 == "Emotes" then
																										v1186 = "Rare"
																										v1166 = v1186
																									end
																									v1186 = pairs
																									v1187 = v37
																									local v1188, v1189, v1190 = v1186(v1187:GetDescendants())
																									for v1212, v1193 in v1188, v1189, v1190 do
																										local v1191 = v1165
																										if v1191 == "GCells" then
																											v1191 = v1165
																											if v1191 == "XP" then
																												local v1194 = v1193:IsA("BoolValue")
																												if not v1194 then
																													v1194 = v1193.Value
																													if v1194 == false then
																														if not v1193:FindFirstChild("RarityImage") then
																															local v1198 = v1193:FindFirstChild("Rarity")
																															if not v1198 then
																																v1198 = v1193.Rarity.Text
																																local v1230 = v1166
																																if v1198 == v1230 then
																																	local v1201 = v1193:FindFirstChild("Locked")
																																	if v1201 == nil then
																																		v1230 = v1170
																																		v1201 = v1230 + 1
																																		v1170 = v1201
																																		v1201 = Instance.new
																																		v1230 = "NumberValue"
																																		local v1203 = v1201(v1230, v1193)
																																		v1203.Name = "NUMBERO"
																																		v1203.Value = v1170
																																	end
																																end
																															end
																														end
																													end
																												end
																											end
																										end
																										v1203 = v1165
																										if v1203 == "XP" then
																											v1203 = v37
																											v1193 = v1203.XP
																											v1167 = v1193
																											v1204 = p8
																											v1203 = v1204.ItemImage
																											v1204 = "http://www.roblox.com/asset/?id=293541673"
																											v1203.Image = v1204
																											v1203 = v1166
																											if v1203 == "Uncommon" then
																												v1203 = 150
																												v1168 = v1203
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v59
																												v1203.TextColor3 = v1204
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v59
																												v1203.TextStrokeColor3 = v1204
																											end
																											v1203 = v1166
																											if v1203 == "Rare" then
																												v1203 = 275
																												v1168 = v1203
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v64
																												v1203.TextColor3 = v1204
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v64
																												v1203.TextStrokeColor3 = v1204
																											end
																											v1203 = v1166
																											if v1203 == "Epic" then
																												v1203 = 425
																												v1168 = v1203
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v69
																												v1203.TextColor3 = v1204
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v69
																												v1203.TextStrokeColor3 = v1204
																											end
																											v1203 = v1166
																											if v1203 == "Legendary" then
																												v1203 = 585
																												v1168 = v1203
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v74
																												v1203.TextColor3 = v1204
																												v1204 = p8
																												v1203 = v1204.ItemName
																												v1204 = v74
																												v1203.TextStrokeColor3 = v1204
																											end
																											v1204 = p8
																											v1203 = v1204.ItemName
																											v1204 = "" .. v1168 .. " XP"
																											v1203.Text = v1204
																											return 
																										end
																										v1203 = v1165
																										if v1203 == "GCells" then
																											v1203 = v37
																											v1193 = v1203.GCells
																											v1167 = v1193
																											v1203 = pairs
																											v1205 = v37
																											v1204 = v1205.GCells
																											local v1208, v1209, v1205 = v1203(v1204:GetChildren())
																											for v1206, v1207 in v1208, v1209, v1205 do
																												local v1210 = v1207.Name
																												local v1211 = v1166
																												if v1210 == v1211 then
																													v1211 = p8
																													v1210 = v1211.ItemImage
																													v1211 = v1207.Image
																													v1210.Image = v1211
																												end
																											end
																											v1208 = v1166
																											if v1208 == "Uncommon" then
																												v1208 = 10
																												v1168 = v1208
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v59
																												v1208.TextColor3 = v1209
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v59
																												v1208.TextStrokeColor3 = v1209
																											end
																											v1208 = v1166
																											if v1208 == "Rare" then
																												v1208 = 25
																												v1168 = v1208
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v64
																												v1208.TextColor3 = v1209
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v64
																												v1208.TextStrokeColor3 = v1209
																											end
																											v1208 = v1166
																											if v1208 == "Epic" then
																												v1208 = 55
																												v1168 = v1208
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v69
																												v1208.TextColor3 = v1209
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v69
																												v1208.TextStrokeColor3 = v1209
																											end
																											v1208 = v1166
																											if v1208 == "Legendary" then
																												v1208 = 125
																												v1168 = v1208
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v74
																												v1208.TextColor3 = v1209
																												v1209 = p8
																												v1208 = v1209.ItemName
																												v1209 = v74
																												v1208.TextStrokeColor3 = v1209
																											end
																											v1209 = p8
																											v1208 = v1209.ItemName
																											v1205 = ""
																											v1206 = v1168
																											v1207 = " GCells"
																											v1209 = v1205 .. v1206 .. v1207
																											v1208.Text = v1209
																											return 
																										end
																									end
																									v1188 = pairs
																									v1189 = v37
																									local v1213, v1214, v1190 = v1188(v1189:GetDescendants())
																									for v1212, v1193 in v1213, v1214, v1190 do
																										v1208 = v1165
																										if v1208 == "GCells" then
																											v1208 = v1165
																											if v1208 == "XP" then
																												v1208 = math.random
																												v1209 = 0
																												v1205 = v1170
																												v1206 = "NUMBERO"
																												local v1217 = v1193:FindFirstChild(v1206)
																												if not v1217 then
																													local v1218 = v1193.NUMBERO
																													v1217 = v1218.Value
																													if v1217 == v1208(v1209, v1205) then
																														local v1220 = v1193:IsA("BoolValue")
																														if not v1220 then
																															v1220 = v1193.Value
																															if v1220 == false then
																																if not v1193:FindFirstChild("RarityImage") then
																																	local v1224 = v1193:FindFirstChild("Rarity")
																																	if not v1224 then
																																		v1218 = v1193.Rarity
																																		v1224 = v1218.Text
																																		v1218 = v1166
																																		if v1224 == v1218 then
																																			local v1226 = v1193:FindFirstChild("Locked")
																																			if v1226 == nil then
																																				v1218 = p8
																																				v1226 = v1218.ItemImage
																																				v1218 = v1193.RarityImage.Image
																																				v1226.Image = v1218
																																				v1218 = p8
																																				v1226 = v1218.ItemName
																																				v1218 = v1193.Name
																																				v1226.Text = v1218
																																				v1226 = v1166
																																				if v1226 == "Uncommon" then
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v59
																																					v1226.TextColor3 = v1218
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v59
																																					v1226.TextStrokeColor3 = v1218
																																				end
																																				v1226 = v1166
																																				if v1226 == "Rare" then
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v64
																																					v1226.TextColor3 = v1218
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v64
																																					v1226.TextStrokeColor3 = v1218
																																				end
																																				v1226 = v1166
																																				if v1226 == "Epic" then
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v69
																																					v1226.TextColor3 = v1218
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v69
																																					v1226.TextStrokeColor3 = v1218
																																				end
																																				v1226 = v1166
																																				if v1226 == "Legendary" then
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v74
																																					v1226.TextColor3 = v1218
																																					v1218 = p8
																																					v1226 = v1218.ItemName
																																					v1218 = v74
																																					v1226.TextStrokeColor3 = v1218
																																				end
																																				v1167 = v1193
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
																									v1213 = pairs
																									v1214 = v37
																									local v1228, v1229, v1190 = v1213(v1214:GetDescendants())
																									for v1212, v1193 in v1228, v1229, v1190 do
																										v1215 = v1193.Name
																										if v1215 == "NUMBERO" then
																											v1193:Destroy()
																										end
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
	RollItem_1()
	if v1167 == nil then
		break
	end
	while true do
		wait()
		RollItem_1()
		if v1167 then
			break
		end
	end
	v30 = true
	script.Parent.Drops.Visible = true
	script.Parent.Events.LootboxUnlock:FireServer(v1167, v1168)
	while true do
		wait()
		local v1240 = v1167.Value
		if v1240 == true then
			break
		end
		v1240 = v1167.Name
		if v1240 == "GCells" then
			break
		end
		v1240 = v1167.Name
		if v1240 == "XP" then
			break
		end
	end
	v1240 = false
	v1162 = v1240
end
v487 = script
v486 = v487.Parent
v486.Drops.Close.MouseButton1Down:Connect(function()
	script.Parent.Drops.Visible = false
	v30 = false
end)
v445 = script
v487 = v445.Parent
v486 = v487.Inventory
v486.Lootboxes.Button.MouseButton1Down:Connect(function()
	v24.CameraType = Enum.CameraType.Scriptable
	local v1262 = {}
	v1262.CFrame = workspace["Lootbox Room"].Cam.CFrame
	(v21:Create(v24, TweenInfo.new(0.3), v1262)):Play()
end)
v445 = script
v487 = v445.Parent
v486 = v487.Lootbox
v486.Back.Button.MouseButton1Down:Connect(function()
	local v1271 = script
	local v1272 = v1271.Parent
	local v1273 = v1272.Drops
	local v1274 = v1273.Visible
	if v1274 == false then
		v1274 = v24
		v1273 = Enum.CameraType.Custom
		v1274.CameraType = v1273
		v1274 = v24
		v1271 = game.Players.LocalPlayer
		v1272 = v1271.Character
		v1273 = v1272.Humanoid
		v1274.CameraSubject = v1273
	end
end)
v445 = script
v487 = v445.Parent
v486 = v487.Lootbox
v486.Open.Button.MouseButton1Down:Connect(function()
	local v1279 = v30
	if v1279 == true then
		local v1280 = script
		local v1281 = v1280.Parent
		local v1282 = v1281.Drops
		v1279 = v1282.Visible
		if v1279 == true then
			local v1284 = script.Parent
			v1280 = v1284.Lootbox
			v1281 = v1280.ECT
			v1282 = v1281.WhiteFlash
			v1279 = v1282.Visible
			if v1279 == false then
				v1282 = v24
				v1279 = v1282.CFrame
				v1284 = workspace
				v1280 = v1284["Lootbox Room"]
				v1281 = v1280.Cam
				v1282 = v1281.CFrame
				if v1279 == v1282 then
					v1281 = script
					v1282 = v1281.Parent
					v1279 = v1282.Drops
					v1282 = false
					v1279.Visible = v1282
					v1279 = false
					v30 = v1279
				end
			end
		end
	end
	v1283 = game
	v1284 = v1283.Players
	v1280 = v1284.LocalPlayer
	v1281 = v1280.Inventory
	v1282 = v1281.Lootboxes
	local v1347 = v1282.Value
	v1282 = 0
	if v1347 > v1282 then
		v1347 = v30
		if v1347 == false then
			v1283 = script
			v1284 = v1283.Parent
			v1280 = v1284.Lootbox
			v1281 = v1280.ECT
			v1282 = v1281.WhiteFlash
			v1347 = v1282.Visible
			if v1347 == false then
				v1280 = script
				v1281 = v1280.Parent
				v1282 = v1281.Drops
				v1347 = v1282.Visible
				if v1347 == false then
					v1347 = true
					v30 = v1347
					v1280 = script
					v1281 = v1280.Parent
					v1282 = v1281.Sounds
					v1347 = v1282.ChestShake
					v1347:Play()
					v1282 = 0.45
					wait(v1282)
					local v1288 = Instance.new("Animation")
					v1288.AnimationId = "http://www.roblox.com/asset/?id=9631104532"
					v1284 = workspace
					v1280 = v1284["Lootbox Room"]
					v1281 = v1280.LootBox
					v1280 = v1288
					local v1290 = v1281.Humanoid:LoadAnimation(v1280)
					v1290:Play()
					wait(0.3)
					v1283 = script
					v1284 = v1283.Parent
					v1284.Sounds.Chestopen:Play()
					wait(0.2)
					v1283 = script
					v1284 = v1283.Parent
					v1284.Sounds.ChestShine:Play()
					v1283 = script.Parent
					v1284 = v1283.Lootbox
					v1284.ECT.WhiteFlash.Visible = true
					v1283 = script.Parent.Lootbox.ECT
					v1284 = v1283.WhiteFlash
					v1283 = TweenInfo.new
					local v1303 = {}
					v1303.BackgroundTransparency = 0
					(v21:Create(v1284, v1283(0.2), v1303)):Play()
					wait(0.2)
					UnlockItems_1(script.Parent.Drops.Item1)
					while true do
						wait(0.01)
						if v1162 == false then
							break
						end
					end
					v1313 = UnlockItems_1
					v1313(script.Parent.Drops.Item2)
					while true do
						wait(0.01)
						if v1162 == false then
							break
						end
					end
					v1317 = UnlockItems_1
					v1317(script.Parent.Drops.Item3)
					wait(0.3)
					script.Parent.Events.LootboxDeduct:FireServer()
					v1290:Stop(0.1)
					local v1327 = {}
					v1327.CFrame = workspace["Lootbox Room"].Cam.CFrame
					(v21:Create(v24, TweenInfo.new(0.2), v1327)):Play()
					wait(0.2)
					local v1338 = {}
					v1338.BackgroundTransparency = 1
					(v21:Create(script.Parent.Lootbox.ECT.WhiteFlash, TweenInfo.new(0.3), v1338)):Play()
					wait(0.3)
					script.Parent.Lootbox.ECT.WhiteFlash.Visible = false
				end
			end
		end
	end
end)
v445 = script
v487 = v445.Parent
v486 = v487.Inventory
v486.Kaijus.Button.MouseButton1Down:Connect(function()
	wait(0.1)
	local v1381 = script
	local v1382 = v1381.Parent
	local v1383 = v1382.Characters
	local v1384 = v1383.LeftBar
	local v1385 = v1384.Visible
	if v1385 == true then
		v1385 = pairs
		v1383 = workspace
		v1384 = v1383.ViewPortModel
		local v1386, v1387, v1383 = v1385(v1384:GetChildren())
		for v1382, v1381 in v1386, v1387, v1383 do
			if v1381.Name == "Char" then
				v1381:Destroy()
			end
		end
		v1383 = v34
		v1387 = v1383.KaijuModel
		v1386 = v1387.Value
		if not v1386 then
			v1387 = workspace
			v1386 = v1387.CurrentCamera
			v1387 = Enum.CameraType.Custom
			v1386.CameraType = v1387
			v1386 = v24
			v1381 = game.Players
			v1382 = v1381.LocalPlayer
			v1383 = v1382.Character
			v1387 = v1383.Humanoid
			v1386.CameraSubject = v1387
			v1383 = v34
			v1387 = v1383.KaijuModel
			v1386 = v1387.Value
			v1386:Destroy()
			v1387 = v34
			v1387 = nil
			v1387.KaijuModel.Value = v1387
			v1387 = v34
			v1387 = ""
			v1387.SelectedKaiju.Value = v1387
			v1387 = v34
			v1387 = nil
			v1387.KaijuMenu.Value = v1387
		end
	end
end)
v445 = script
v487 = v445.Parent
v486 = v487.Inventory
v486.GCells.Button.MouseButton1Down:Connect(function()
	script.Parent.Characters.LeftBar:TweenPosition(script.Parent.Characters.LeftBar.Positions.StartPos.Position)
	wait(0.25)
	script.Parent.Characters.LeftBar.Visible = false
end)
v445 = script
v487 = v445.Parent
v486 = v487.Inventory
v486.Gamepasses.Button.MouseButton1Down:Connect(function()
	script.Parent.Characters.LeftBar:TweenPosition(script.Parent.Characters.LeftBar.Positions.StartPos.Position)
	wait(0.25)
	script.Parent.Characters.LeftBar.Visible = false
end)
v445 = script
v487 = v445.Parent
v486 = v487.Inventory
v486.Lootboxes.Button.MouseButton1Down:Connect(function()
	script.Parent.Characters.LeftBar:TweenPosition(script.Parent.Characters.LeftBar.Positions.StartPos.Position)
	wait(0.25)
	script.Parent.Characters.LeftBar.Visible = false
end)
v486 = script
local v1454 = v486.Parent
local v1455, v1456, v1454 = pairs(v1454.Parent:GetDescendants())
for v486, v487 in v1455, v1456, v1454 do
	v346 = "TextButton"
	local v1457 = v487:IsA(v346)
	if not v1457 then
		v1457 = v487.Name
		if v1457 == "Button" then
			v349 = v487.Parent
			v1457 = v349.ImageTransparency
			v349 = v487.MouseEnter
			v349:Connect(function()
				local v1463 = script.Parent.Sounds.Scroll:Clone()
				v1463.PlayOnRemove = true
				v1463.Parent = script
				v1463:Destroy()
				v487.Parent.ImageTransparency = 0
			end)
			v487.MouseLeave:Connect(function()
				v487.Parent.ImageTransparency = v1457
			end)
			v487.MouseButton1Down:Connect(function()
				local v1476 = v30
				if v1476 == false then
					local v1477 = v487
					local v1478 = v1477.Parent
					local v1479 = v1478.Parent
					local v1480 = v1479.Parent
					v1476 = v1480.Name
					if v1476 == "EmoteStore" then
						v1479 = v487
						v1480 = v1479.Parent
						v1476 = v1480.Name
						if v1476 == "Select" then
							v1480 = v487
							v1476 = v1480.Parent
							v1479 = "Onsale"
							local v1481 = v1476:FindFirstChild(v1479)
							if not v1481 then
								v1481 = true
								v30 = v1481
								v1480 = v34
								v1481 = v1480.Onsale
								v1477 = v487
								v1478 = v1477.Parent
								v1480 = v1478.Onsale.Value
								v1481.Value = v1480
								v1480 = script.Parent
								v1481 = v1480.Prompt
								v1480 = false
								v1481.Visible = v1480
								v1478 = script
								v1480 = v1478.Parent.Sounds
								v1481 = v1480.Click
								v1481:Play()
								v1480 = v34
								local v1484 = v487
								v1477 = v1484.Parent
								v1478 = v1477.EmoteAnimation
								local v1494 = v1478.Value
								v1480 = v1494.Name
								v1480.SelectedEmote.Value = v1480
								v1480 = v37
								local v1485, v1486, v1482 = pairs(v1480:GetDescendants())
								for v1478, v1477 in v1485, v1486, v1494 do
									v1484 = v1477.Name
									local v1489 = v34.SelectedEmote.Value
									if v1484 == v1489 then
										v1489 = v34
										v1484 = v1489.SelectedObject
										v1484.Value = v1477
									end
								end
								v1486 = v34
								v1485 = v1486.Cost
								v1477 = v487
								v1478 = v1477.Parent
								v1494 = v1478.Cost
								v1486 = v1494.Value
								v1485.Value = v1486
								v1478 = v487
								v1486 = v1478.Parent.EmoteAnimation
								v1485 = v1486.Value
								local v1490 = v1485:Clone()
								v1486 = v1490.Char
								v1477 = workspace
								v1478 = v1477.ViewPortModel
								v1486.Value = v1478.Char
								v1488 = game
								v1489 = v1488.Players
								v1477 = v1489.LocalPlayer.PlayerGui
								v1478 = v1477.Menu
								v1486 = v1478.Menu.EmoteScripts
								v1490.Parent = v1486
								v1486 = wait
								v1486(0.15)
								v30 = false
								return 
							end
						end
					end
				end
			end)
			v487.MouseButton1Down:Connect(function()
				local v1503 = v30
				if v1503 == false then
					local v1504 = v487
					local v1505 = v1504.Parent
					local v1506 = v1505.Parent
					v1503 = v1506.Name
					if v1503 == "SkinStore" then
						v1505 = v487
						v1506 = v1505.Parent
						v1503 = v1506.Name
						if v1503 == "Select" then
							v1503 = true
							v30 = v1503
							v1504 = script
							v1505 = v1504.Parent
							v1506 = v1505.Sounds
							v1503 = v1506.Click
							v1503:Play()
							v1505 = v34
							v1506 = v1505.SelectedObject
							local v1507 = v1506.Value
							if not v1507 then
								v1504 = v34
								v1505 = v1504.SelectedObject
								v1506 = v1505.Value
								v1507 = v1506.Value
								if v1507 == false then
									v1505 = v34
									v1506 = v1505.Onsale
									v1507 = v1506.Value
									if v1507 == true then
										v1505 = script
										v1506 = v1505.Parent
										v1507 = v1506.Prompt
										v1506 = true
										v1507.Visible = v1506
										v1504 = script.Parent
										v1505 = v1504.Prompt
										v1506 = v1505.PromptImage
										v1507 = v1506.PromptInfo
										v1505 = "Purchase "
										v1504 = v34.SelectedObject.Value.Name
										v1506 = v1505 .. v1504 .. " for " .. v34.Cost.Value .. " GCells?"
										v1507.Text = v1506
									end
								end
								v1504 = v34
								v1505 = v1504.SelectedObject
								v1506 = v1505.Value
								v1507 = v1506.Value
								if v1507 == true then
									v1505 = script
									v1506 = v1505.Parent
									v1507 = v1506.Prompt
									v1506 = true
									v1507.Visible = v1506
									v1508 = script
									v1504 = v1508.Parent
									v1505 = v1504.Prompt
									v1506 = v1505.PromptImage
									v1507 = v1506.PromptInfo
									v1505 = "Select "
									v1511 = v34
									v1513 = v1511.SelectedObject
									v1512 = v1513.Value
									v1504 = v1512.Name
									v1508 = "?"
									v1506 = v1505 .. v1504 .. v1508
									v1507.Text = v1506
								end
							end
							v1506 = 0.15
							wait(v1506)
							v30 = false
							return 
						end
					end
				end
			end)
			v487.MouseButton1Down:Connect(function()
				local v1521 = v30
				if v1521 == false then
					local v1522 = v487
					local v1523 = v1522.Parent
					local v1524 = v1523.Parent
					v1521 = v1524.Name
					if v1521 == "EmoteStore" then
						v1523 = v487
						v1524 = v1523.Parent
						v1521 = v1524.Name
						if v1521 == "Select" then
							v1521 = true
							v30 = v1521
							v1522 = script
							v1523 = v1522.Parent
							v1524 = v1523.Sounds
							v1521 = v1524.Click
							v1521:Play()
							v1523 = v34
							v1524 = v1523.SelectedObject
							local v1525 = v1524.Value
							if not v1525 then
								v1522 = v34
								v1523 = v1522.SelectedObject
								v1524 = v1523.Value
								v1525 = v1524.Value
								if v1525 == false then
									v1523 = v34
									v1524 = v1523.Onsale
									v1525 = v1524.Value
									if v1525 == true then
										v1523 = script
										v1524 = v1523.Parent
										v1525 = v1524.Prompt
										v1524 = true
										v1525.Visible = v1524
										v1522 = script.Parent
										v1523 = v1522.Prompt
										v1524 = v1523.PromptImage
										v1525 = v1524.PromptInfo
										v1523 = "Purchase "
										v1522 = v34.SelectedObject.Value.Name
										v1524 = v1523 .. v1522 .. " for " .. v34.Cost.Value .. " GCells?"
										v1525.Text = v1524
									end
								end
								v1522 = v34
								v1523 = v1522.SelectedObject
								v1524 = v1523.Value
								v1525 = v1524.Value
								if v1525 == true then
									v1523 = script
									v1524 = v1523.Parent
									v1525 = v1524.Prompt
									v1524 = true
									v1525.Visible = v1524
									v1526 = script
									v1522 = v1526.Parent
									v1523 = v1522.Prompt
									v1524 = v1523.PromptImage
									v1525 = v1524.PromptInfo
									v1523 = "Select "
									v1529 = v34
									v1531 = v1529.SelectedObject
									v1530 = v1531.Value
									v1522 = v1530.Name
									v1526 = "?"
									v1524 = v1523 .. v1522 .. v1526
									v1525.Text = v1524
								end
							end
							v1524 = 0.15
							wait(v1524)
							v30 = false
							return 
						end
					end
				end
			end)
			v487.MouseButton1Down:Connect(function()
				local v1539 = v30
				if v1539 == false then
					local v1540 = v487
					local v1541 = v1540.Parent
					local v1542 = v1541.Parent
					local v1543 = v1542.Parent
					v1539 = v1543.Name
					if v1539 == "SkinStore" then
						v1541 = v487
						v1542 = v1541.Parent
						v1543 = v1542.Parent
						v1539 = v1543.Name
						if v1539 == "SelectionFrame" then
							v1543 = v487
							v1539 = v1543.Parent
							v1542 = "Onsale"
							local v1544 = v1539:FindFirstChild(v1542)
							if not v1544 then
								v1544 = true
								v30 = v1544
								v1543 = script.Parent
								v1544 = v1543.Prompt
								v1543 = false
								v1544.Visible = v1543
								v1541 = script
								v1543 = v1541.Parent.Sounds
								v1544 = v1543.Click
								v1544:Play()
								v1543 = v34
								v1540 = v487
								v1541 = v1540.Parent
								v1543 = v1541.Onsale.Value
								v1543.Onsale.Value = v1543
								v1543 = workspace
								local v1547 = v1543.ViewPortModel:FindFirstChild("Char")
								if not v1547 then
									v1543 = workspace.ViewPortModel
									v1547 = v1543.Char
									v1547:Destroy()
								end
								v1543 = v34
								v1540 = v487
								v1541 = v1540.Parent
								v1548 = v1541.SkinModel
								v1543 = v1548.Value
								v1543.KaijuModel.Value = v1543
								v1543 = v34
								v1548 = ""
								local v1550 = v487
								v1540 = v1550.Parent.SkinName
								v1541 = v1540.Value
								v1543 = v1548 .. v1541
								v1543.SelectedSkin.Value = v1543
								v1543 = v34
								v1540 = v487
								v1541 = v1540.Parent
								v1548 = v1541.Cost
								v1543 = v1548.Value
								v1543.Cost.Value = v1543
								v1543 = v37
								local v1552, v1553, v1548 = pairs(v1543:GetDescendants())
								for v1541, v1540 in v1552, v1553, v1548 do
									local v1555 = v1540:IsA("BoolValue")
									if not v1555 then
										v1555 = v1540.Name
										v1550 = v34.SelectedSkin.Value
										if v1555 == v1550 then
											v1550 = v34
											v1555 = v1550.SelectedObject
											v1555.Value = v1540
										end
									end
								end
								v1552 = wait
								v1553 = 0.15
								v1552(v1553)
								v1548 = v34
								local v1560 = v1548.KaijuModel.Value:Clone()
								v1548 = true
								v1560.HumanoidRootPart.Anchored = v1548
								v1548 = v34
								v1548.KaijuModel.Value = v1560
								v1540 = "Settings"
								v1560.Name = "Char"
								v1541 = workspace
								v1560.Parent = v1541.ViewPortModel
								v1541 = false
								v1560.HumanoidRootPart.Anchored = v1541
								v1541 = CFrame.new
								v1556 = workspace
								v1557 = v1556.ViewPortModel
								v1555 = v1557.CharSpot.CFrame
								v1556 = workspace.ViewPortModel.CharSpot
								v1557 = v1556.CFrame
								v1556 = v1560.Humanoid.HipHeight
								v1557 = v1556 * 8
								v1555 = v1557.Y + v1557
								v1556 = workspace.ViewPortModel.CharSpot
								v1557 = v1556.CFrame
								v1560.HumanoidRootPart.CFrame = v1541(v1555.X, v1555, v1557.Z)
								v1556 = workspace
								v1557 = v1556.ViewPortModel
								v1556 = workspace.ViewPortModel
								v1557 = v1556.CharSpot
								v1556 = v1560.HumanoidRootPart.CFrame
								v1557 = v1556.Y
								v1556 = workspace.ViewPortModel.CharSpot.CFrame
								v1557 = v1556.Z
								v1560.HumanoidRootPart.CFrame = CFrame.new(v1557.CFrame.X, v1557 - v1560.TeamBrick.Position - v1557.CharSpot.Position.Magnitude, v1557)
								local v1572 = Instance.new("Animation")
								v1572.AnimationId = "http://www.roblox.com/asset/?id=" .. require(v1560:WaitForChild(v1540)).Idle
								do local t = v1560.Humanoid:LoadAnimation(v1572); t.Looped = true; t:Play() end
								local v1579 = v1560:FindFirstChild("Orga")
								if not v1579 then
									v1579 = Instance.new
									local v1581 = v1579("Animation")
									v1581.AnimationId = "http://www.roblox.com/asset/?id=9127268479"
									v1556 = v1581
									do local t = v1560.Humanoid:LoadAnimation(v1556); t.Looped = true; t:Play() end
								end
								v1581 = workspace.ViewPortModel.Cam
								v1581.CFrame = CFrame.new(workspace.ViewPortModel.Cam.CFrame.X, v1560.HumanoidRootPart.CFrame.Y, workspace.ViewPortModel.Cam.CFrame.Z)
								v1581 = workspace.ViewPortModel.Cam
								v1581.Orientation = Vector3.new(-0.76, 178.03, 0)
								v1581 = v24
								v1581.CameraType = Enum.CameraType.Scriptable
								v1581 = workspace.CurrentCamera
								v1581.CFrame = workspace.ViewPortModel.Cam.CFrame
								v1581 = wait
								v1581(0.15)
								v30 = false
								return 
							end
						end
					end
				end
			end)
			v487.MouseButton1Down:Connect(function()
				local v1655 = v30
				if v1655 == false then
					local v1656 = v487
					local v1657 = v1656.Parent
					local v1658 = v1657.Parent
					v1655 = v1658.Name
					if v1655 == "Selection" then
						v1657 = v487
						v1658 = v1657.Object
						v1655 = v1658.Value
						local v1659 = script
						local v1660 = v1659.Parent
						v1656 = v1660.Values
						v1657 = v1656.KaijuMenu
						v1658 = v1657.Value
						if v1655 ~= v1658 then
							v1655 = true
							v30 = v1655
							v1657 = script
							v1658 = v1657.Parent
							v1655 = v1658.Prompt
							v1658 = false
							v1655.Visible = v1658
							v1658 = workspace
							v1655 = v1658.ViewPortModel
							v1657 = "Char"
							local v1661 = v1655:FindFirstChild(v1657)
							if not v1661 then
								v1658 = workspace.ViewPortModel
								v1661 = v1658.Char
								v1661:Destroy()
							end
							v1662 = v487
							v1658 = v1662.Object
							local v1663 = v1658.Value
							if not v1663 then
								v1662 = v487
								v1658 = v1662.Object
								v1663 = v1658.Value
								v1662 = "Sound"
								local v1664 = v1663:FindFirstChild(v1662)
								if not v1664 then
									v1660 = v487
									v1656 = v1660.Object
									v1658 = v1656.Value.Sound
									v1664 = v1658.Value
									v1664:Play()
								end
							end
							v1656 = script
							v1665 = v1656.Parent
							v1658 = v1665.Inventory
							local v1666 = v1658.Visible
							if v1666 == true then
								v1666 = v21
								v1660 = script
								v1656 = v1660.Parent
								v1665 = v1656.Inventory
								v1656 = TweenInfo.new
								v1659 = script.Parent.Inventory.TweenSpeed
								v1660 = v1659.Value
								local v1671 = {}
								v1659 = script.Parent.Inventory.Positions.StartPos.Position
								v1671.Position = v1659
								local v1674 = v1666:Create(v1665, v1656(v1660), v1671)
								v1674:Play()
								v1674.Completed:Connect(function()
									script.Parent.Inventory.Visible = false
								end)
							end
							v1674 = v34.SelectedKaiju
							v1674.Value = v487.Parent.Name
							v1674 = script.Parent.Values.KaijuMenu
							v1674.Value = v487.Object.Value
							v1674 = pairs
							v1659 = game
							local v1684 = v1659.ReplicatedStorage
							local v1764 = v1684.Assets.Kaijus
							local v1685, v1686, v1683 = v1674(v1764.Models:GetDescendants())
							for v1682, v1684 in v1685, v1686, v1764 do
								v1659 = pairs
								v1669 = v37
								local v1687, v1688, v1668 = v1659(v1669:GetChildren())
								for v1667, v1673 in v1687, v1688, v1668 do
									v1672 = v1673.Name
									local v1691 = v487.Parent.Name
									if v1672 == v1691 then
										v1672 = v1684.Name
										v1691 = v1673:FindFirstChild("" .. v1673.Name .. "-Skin").Value
										if v1672 == v1691 then
											v1691 = v34
											v1672 = v1691.KaijuModel
											v1672.Value = v1684
										end
									end
								end
							end
							v1764 = script.Parent.Values
							v1686 = v1764.KaijuMenu
							v1685 = v1686.Value
							v1686 = true
							v1685.Visible = v1686
							v1687 = script
							v1686 = v1687.Parent.Values.KaijuMenu.Value
							v1685 = v1686.SelectStores
							v1686 = true
							v1685.Visible = v1686
							v1687 = script
							v1686 = v1687.Parent.Values.KaijuMenu.Value
							v1685 = v1686.SelectStores
							v1673 = script
							v1667 = v1673.Parent
							v1668 = v1667.Values
							v1688 = v1668.KaijuMenu
							v1687 = v1688.Value
							v1686 = v1687.SelectStores.Positions.EndPos.Position
							v1685.Position = v1686
							v1687 = script
							v1686 = v1687.Parent.Values.KaijuMenu.Value
							v1685 = v1686.SkinStore
							v1686 = false
							v1685.Visible = v1686
							v1687 = script
							v1686 = v1687.Parent.Values.KaijuMenu.Value
							v1685 = v1686.SkinStore
							v1673 = script
							v1667 = v1673.Parent
							v1668 = v1667.Values
							v1688 = v1668.KaijuMenu
							v1687 = v1688.Value
							v1686 = v1687.SkinStore.Positions.StartPos.Position
							v1685.Position = v1686
							v1687 = script
							v1686 = v1687.Parent.Values.KaijuMenu.Value
							v1685 = v1686.EmoteStore
							v1686 = false
							v1685.Visible = v1686
							v1687 = script
							v1686 = v1687.Parent.Values.KaijuMenu.Value
							v1685 = v1686.EmoteStore
							v1673 = script
							v1667 = v1673.Parent
							v1668 = v1667.Values
							v1688 = v1668.KaijuMenu
							v1687 = v1688.Value
							v1686 = v1687.EmoteStore.Positions.StartPos.Position
							v1685.Position = v1686
							v1685 = v21
							v1688 = script
							v1687 = v1688.Parent
							v1672 = script
							v1673 = v1672.Parent
							v1667 = v1673.Values
							v1668 = v1667.KaijuMenu
							v1688 = v1668.Value
							v1687 = v1688.TweenSpeed
							local v1698 = {}
							v1696 = script
							v1691 = v1696.Parent
							v1672 = v1691.Values
							v1673 = v1672.KaijuMenu
							v1667 = v1673.Value
							v1668 = v1667.Positions
							v1688 = v1668.EndPos
							v1687 = v1688.Position
							v1698.Position = v1687
							(v1685:Create(v1687.Values.KaijuMenu.Value, TweenInfo.new(v1687.Value), v1698)):Play()
							local v1702 = script.Parent
							local v1704, v1705, v1702 = pairs(v1702.KaijuMenus:GetChildren())
							for v1701, v1687 in v1704, v1705, v1702 do
								v1672 = script
								v1673 = v1672.Parent
								v1667 = v1673.Values
								v1668 = v1667.KaijuMenu
								v1688 = v1668.Value
								if v1687 ~= v1688 then
									v1688 = v21
									v1667 = v1687
									v1673 = TweenInfo.new
									v1691 = v1687.TweenSpeed
									v1672 = v1691.Value
									local v1707 = {}
									v1689 = v1687.Positions
									v1696 = v1689.StartPos
									v1691 = v1696.Position
									v1707.Position = v1691
									local v1708 = v1688:Create(v1667, v1673(v1672), v1707)
									v1708:Play()
									v1708.Completed:Connect(function()
										v1687.Visible = false
									end)
								end
							end
							v1704 = wait
							v1705 = 0.15
							v1704(v1705)
							v1702 = v34
							local v1715 = v1702.KaijuModel.Value:Clone()
							v1715.HumanoidRootPart.Anchored = true
							v34.KaijuModel.Value = v1715
							v1687 = "Settings"
							v1715.Name = "Char"
							v1715.Parent = workspace.ViewPortModel
							v1715.HumanoidRootPart.Anchored = false
							v1708 = workspace.ViewPortModel.CharSpot.CFrame
							v1691 = workspace
							v1708 = v1691.ViewPortModel.CharSpot.CFrame.Y + v1715.Humanoid.HipHeight * 8
							v1691 = workspace
							v1715.HumanoidRootPart.CFrame = CFrame.new(v1708.X, v1708, v1691.ViewPortModel.CharSpot.CFrame.Z)
							v1696 = workspace
							v1691 = v1696.ViewPortModel
							local v1838 = v1691.CharSpot.CFrame
							v1715.HumanoidRootPart.CFrame = CFrame.new(workspace.ViewPortModel.CharSpot.CFrame.X, v1715.HumanoidRootPart.CFrame.Y - v1715.TeamBrick.Position - workspace.ViewPortModel.CharSpot.Position.Magnitude, v1838.Z)
							local v1728 = Instance.new("Animation")
							v1728.AnimationId = "http://www.roblox.com/asset/?id=" .. require(v1715:WaitForChild(v1687)).Idle
							do local t = v1715.Humanoid:LoadAnimation(v1728); t.Looped = true; t:Play() end
							local v1735 = v1715:FindFirstChild("Orga")
							if not v1735 then
								v1735 = Instance.new
								local v1737 = v1735("Animation")
								v1737.AnimationId = "http://www.roblox.com/asset/?id=9127268479"
								v1838 = v1737
								do local t = v1715.Humanoid:LoadAnimation(v1838); t.Looped = true; t:Play() end
							end
							v1737 = workspace.ViewPortModel.Cam
							v1696 = workspace
							v1691 = v1696.ViewPortModel
							v1691 = v1715.HumanoidRootPart
							v1689 = workspace.ViewPortModel
							v1696 = v1689.Cam
							v1691 = v1696.CFrame
							v1737.CFrame = CFrame.new(v1691.Cam.CFrame.X, v1691.CFrame.Y, v1691.Z)
							v1737 = workspace.ViewPortModel.Cam
							v1737.Orientation = Vector3.new(-0.76, 178.03, 0)
							v1737 = v24
							v1737.CameraType = Enum.CameraType.Scriptable
							v1737 = workspace.CurrentCamera
							v1737.CFrame = workspace.ViewPortModel.Cam.CFrame
							v1737 = wait
							v1737(0.15)
							v30 = false
							return 
						end
					end
				end
			end)
		end
	end
end
v1455 = pairs
v1454 = script
v1456 = v1454.Parent
local v1859, v1860, v1454 = v1455(v1456:GetDescendants())
for v486, v487 in v1859, v1860, v1454 do
	local v1862 = v487:FindFirstChild("Place")
	if not v1862 then
		v1862 = v487.MouseButton1Down
		v1862:Connect(function()
			local v1865 = script
			local v1867, v1868, v1865 = pairs(v1865.Parent:GetDescendants())
			for v1883, v1871 in v1867, v1868, v1865 do
				local v1872 = v1871:FindFirstChild("Positions")
				if not v1872 then
					v1872 = v21
					local v1877 = {}
					v1877.Position = v1871.Positions.StartPos.Position
					(v1872:Create(v1871, TweenInfo.new(0.5), v1877)):Play()
				end
			end
			v1883 = script
			v1865 = v1883.Parent
			v1868 = v1865.Parent
			v1867 = v1868.Load
			v1868 = true
			v1867.Visible = v1868
			v1881 = script
			v1871 = v1881.Parent
			v1883 = v1871.Parent
			v1868 = v1883.Load.BG
			v1867 = v1868.Rotate
			v1868 = false
			v1867.Disabled = v1868
			v1867 = v21
			v1881 = script.Parent
			v1871 = v1881.Parent
			v1883 = v1871.Load
			v1883 = TweenInfo.new
			v1871 = 0.3
			local v1886 = {}
			v1881 = 0.65
			v1886.TextStrokeTransparency = v1881
			(v1867:Create(v1883.Rewards, v1883(v1871), v1886)):Play()
			v1881 = script.Parent.Parent
			v1881 = 0.3
			local v1893 = {}
			v1893.TextTransparency = 0
			(v21:Create(v1881.Load.Rewards, TweenInfo.new(v1881), v1893)):Play()
			local v1901 = {}
			v1901.BackgroundTransparency = 0
			(v21:Create(script.Parent.Parent.Load.Frame, TweenInfo.new(0.25), v1901)):Play()
			script.Parent.Parent.Load.Rewards.Text = "Teleporting to server..."
			v46:Teleport(v487.Place.Value, game.Players.LocalPlayer)
		end)
	end
end
v1859 = pairs
v1454 = script
v1860 = v1454.Parent
local v1927, v1928, v1454 = v1859(v1860:GetDescendants())
for v486, v487 in v1927, v1928, v1454 do
	local v1931 = v487:FindFirstChild("Object")
	if not v1931 then
		v1931 = v487.MouseButton1Down
		v1931:Connect(function()
			local v1933 = v30
			if v1933 == false then
				local v1934 = v487
				v1933 = v1934.Parent
				local v1936 = v1933:FindFirstChild("Cost")
				if v1936 == nil then
					v1934 = v487
					v1936 = v1934.Name
					if v1936 == "MenuToggle" then
						local v1937 = v487
						local v1938 = v1937.Parent
						v1934 = v1938.Parent
						v1936 = v1934.Name
						if v1936 == "Selection" then
							v1938 = v487
							v1934 = v1938.Parent
							v1936 = v1934.Name
							if v1936 == "Open" then
								v1936 = true
								v30 = v1936
								v1938 = script
								v1934 = v1938.Parent
								v1936 = v1934.Prompt
								v1934 = false
								v1936.Visible = v1934
								v1937 = script
								v1938 = v1937.Parent
								v1934 = v1938.Sounds
								v1936 = v1934.Click
								v1936:Play()
								v1934 = v487
								local v1940, v1941, v1938 = pairs(v1934:GetChildren())
								for v1937, v1943 in v1940, v1941, v1938 do
									local v1942 = v1943.Name
									if v1942 == "Object" then
										v1942 = v1943.Value.Position
										local v1945 = v1943.Value
										local v1946 = v1945.Positions
										local v1947 = v1946.StartPos
										local v1994 = v1947.Position
										if v1942 == v1994 then
											v1942 = v1943.Value
											v1994 = true
											v1942.Visible = v1994
											v1947 = v1943.Parent
											v1994 = v1947.Parent
											v1942 = v1994.Name
											if v1942 == "Back" then
												v1946 = script
												v1947 = v1946.Parent
												v1994 = v1947.Values
												v1942 = v1994.SelectedObject
												v1994 = nil
												v1942.Value = v1994
											end
											v1947 = v1943.Parent
											v1994 = v1947.Parent
											v1942 = v1994.Name
											if v1942 == "Back" then
												v1946 = v1943.Parent
												v1947 = v1946.Parent
												v1994 = v1947.Parent
												v1942 = v1994.Name
												if v1942 == "Inventory" then
													v1945 = script
													v1946 = v1945.Parent
													v1947 = v1946.Characters
													v1994 = v1947.LeftBar
													v1942 = v1994.Visible
													if v1942 == true then
														v1947 = v34
														v1994 = v1947.KaijuModel
														v1942 = v1994.Value
														if not v1942 then
															v1947 = v34
															v1994 = v1947.KaijuModel
															v1942 = v1994.Value
															v1942:Destroy()
															v1994 = v34
															v1994 = nil
															v1994.KaijuModel.Value = v1994
															v1994 = v34
															v1994 = ""
															v1994.SelectedKaiju.Value = v1994
															v1994 = v34
															v1994 = nil
															v1994.KaijuMenu.Value = v1994
														end
														v1948 = v21
														v1945 = script.Parent
														v1946 = v1945.Characters
														v1947 = v1946.LeftBar
														v1946 = TweenInfo.new
														v1945 = script.Parent.Characters.LeftBar.TweenSpeed.Value
														local v1955 = {}
														v1955.Position = script.Parent.Characters.LeftBar.Positions.StartPos.Position
														local v1958 = v1948:Create(v1947, v1946(v1945), v1955)
														v1958:Play()
														v1958.Completed:Connect(function()
															script.Parent.Characters.LeftBar.Visible = false
														end)
													end
												end
											end
											v1958 = v1943.Value.Sound.Value
											v1958:Play()
											v1953 = v1943.Value
											v1949 = v1953.TweenSpeed
											local v1972 = {}
											v1951 = v1943.Value
											v1952 = v1951.Positions
											v1953 = v1952.EndPos
											v1949 = v1953.Position
											v1972.Position = v1949
											local v1973 = v21:Create(v1943.Value, TweenInfo.new(v1949.Value), v1972)
											v1973:Play()
											v1973.Completed:Connect(function()
												v30 = false
											end)
										else
											v1973 = v1943.Value.Sound.Value
											v1973:Play()
											v1953 = v1943.Value
											v1949 = v1953.TweenSpeed
											local v1983 = {}
											v1951 = v1943.Value
											v1952 = v1951.Positions
											v1953 = v1952.StartPos
											v1949 = v1953.Position
											v1983.Position = v1949
											local v1984 = v21:Create(v1943.Value, TweenInfo.new(v1949.Value), v1983)
											v1984:Play()
											v1984.Completed:Connect(function()
												v1943.Value.Visible = false
												wait(0.15)
												v30 = false
											end)
										end
									end
								end
								v1940 = wait
								v1941 = 0.3
								v1940(v1941)
								v30 = false
								return 
							end
						end
					end
				end
			end
		end)
	end
end
v1927 = pairs
v1454 = script
v1928 = v1454.Parent
local v2005, v2006, v1454 = v1927(v1928:GetDescendants())
for v486, v487 in v2005, v2006, v1454 do
	local v2007 = v487.Name
	if v2007 == "Favorite" then
		v2007 = v487.MouseButton1Down
		v2007:Connect(function()
			script.Parent.Sounds.Click:Play()
			script.Parent.Events.SetMain:FireServer(v487.Parent.Name)
			v487.ImageColor3 = Color3.fromRGB(0, 255, 0)
		end)
	end
end
v487 = script.Parent
v486 = v487.MainMenu
v1454 = v486.Profile
v2006 = v1454.Button
v2005 = v2006.MouseButton1Down
v2005:Connect(function()
	script.Parent.Events.CheckProfile:FireServer(game.Players.LocalPlayer.Name, true)
	script.Parent.Profile.EnterName.TXT.Text = ""
	script.Parent.Profile.EnterPicture.TXT.Text = ""
end)
v487 = script.Parent
v486 = v487.Profile
v2006 = v486.EnterPicture.TXT
v2006.FocusLost:Connect(function()
	local v2050 = script
	local v2051 = v2050.Parent
	local v2052 = v2051.Profile
	local v2053 = v2052.EnterPicture
	local v2054 = v2053.TXT
	local v2055 = v2054.Text
	if v2055 == "" then
		v2050 = script
		v2051 = v2050.Parent
		v2052 = v2051.Profile
		v2053 = v2052.PlayerHolder
		v2054 = v2053.PlayerName
		v2055 = v2054.Text
		v2051 = game
		v2052 = v2051.Players
		v2053 = v2052.LocalPlayer
		v2054 = v2053.Name
		if v2055 == v2054 then
			v2055 = tonumber
			v2050 = script.Parent
			v2051 = v2050.Profile
			v2052 = v2051.EnterPicture
			v2053 = v2052.TXT
			v2054 = v2053.Text
			v2051 = script
			v2052 = v2051.Parent
			v2053 = v2052.Events
			v2052 = v2055(v2054)
			v2053.ChangeIMAGE:FireServer(v2052)
			v2053 = 0.15
			wait(v2053)
			v2051 = script
			v2050 = game.Players
			v2051 = v2050.LocalPlayer
			v2051 = true
			v2051.Parent.Events.CheckProfile:FireServer(v2051.Name, v2051)
		end
	end
end)
v487 = script.Parent
v486 = v487.Profile
v2006 = v486.EnterName.TXT
v2006.FocusLost:Connect(function()
	local v2067 = script
	local v2068 = v2067.Parent
	local v2069 = v2068.Profile
	local v2070 = v2069.EnterName
	local v2071 = v2070.TXT
	local v2072 = v2071.Text
	if v2072 == "" then
		v2067 = script
		v2068 = v2067.Parent
		v2069 = v2068.Profile
		v2070 = v2069.EnterName
		v2071 = v2070.TXT
		v2072 = v2071.Text
		v2071 = false
		v2069 = game
		v2070 = v2069.Players
		v2068 = v2072
		local v2073 = v2070:FindFirstChild(v2068)
		if not v2073 then
			v2071 = true
		end
		v2067 = script
		v2069 = v2067.Parent.Events
		v2073 = v2069.CheckProfile
		v2067 = v2071
		v2073:FireServer(v2072, v2067)
		local v2080 = {}
		v2080.Position = script.Parent.Profile.Positions.StartPos.Position
		(v21:Create(script.Parent.Profile, TweenInfo.new(0.25), v2080)):Play()
		wait(2.5)
		local v2094 = {}
		v2094.Position = script.Parent.Profile.Positions.EndPos.Position
		(v21:Create(script.Parent.Profile, TweenInfo.new(0.25), v2094)):Play()
	end
end)
v487 = script.Parent.Rewards.Rewards.Buy
v486 = v487.BuySeason
v2006 = v486.Button.Button
v2006.MouseButton1Down:Connect(function()
	local v2114 = v37
	local v2116 = v2114.GCells.Value
	local v2128 = 1000
	if v2116 >= v2128 then
		local v2117 = v37
		v2114 = v2117.Rewards
		v2128 = v2114.Owned
		v2116 = v2128.Value
		if v2116 == false then
			v2117 = script
			v2114 = v2117.Parent
			v2128 = v2114.Events
			v2116 = v2128.BuyItem
			v2117 = v37.Rewards
			v2114 = v2117.Owned
			v2117 = 1000
			v2116:FireServer(v2114, v2117)
			v2128 = script.Parent.Sounds
			v2128.Click:Play()
		end
	end
	v2120 = v37
	local v2122 = v2120.GCells.Value
	local v2130 = 1000
	if v2130 > v2122 then
		v2119 = v37
		v2120 = v2119.Rewards
		v2130 = v2120.Owned
		v2122 = v2130.Value
		if v2122 == false then
			v2118 = script.Parent.Rewards.Rewards
			v2119 = v2118.Buy
			v2120 = v2119.BuySeason
			v2130 = v2120.Button
			v2122 = v2130.TXT
			v2130 = "Not enough GCells"
			v2122.Text = v2130
			v2122 = wait
			v2130 = 0.75
			v2122(v2130)
			v2118 = script.Parent.Rewards.Rewards
			v2119 = v2118.Buy
			v2120 = v2119.BuySeason
			v2120.Button.TXT.Text = "Buy : 1000G"
		end
	end
end)
local v2135 = false
v487 = script.Parent.Parent
v486 = v487.Feed
v2006 = v486.Feed.ChildAdded
v486 = function(p9)
	p9:WaitForChild("Chime")
	while true do
		wait(0.08)
		if v2135 == false then
			break
		end
	end
	if not p9 then
		v2141 = true
		v2135 = v2141
		v2141 = script.Parent.Parent.Feed.Feed.Spots.Feed1.Position
		p9.Position = v2141
		v2141 = p9.Chime
		v2141:Play()
		local v2151 = {}
		local v2152 = p9.Position
		local v2155 = UDim2.new(0.75, 0, v2152.Y.Scale, 0)
		v2151.Position = v2155
		(v21:Create(p9, TweenInfo.new(0.075), v2151)):Play()
		wait(0.08)
		local v2194 = script.Parent
		local v2161 = v2194.Parent
		local v2162 = v2161.Feed
		local v2164, v2165, v2162 = pairs(v2162.Feed:GetChildren())
		for v2161, v2155 in v2164, v2165, v2162 do
			if v2155 ~= p9 then
				local v2167 = v2155:IsA("Frame")
				if not v2167 then
					if not p9 then
						if not v2155 then
							v2167 = v2155.Position.Y.Scale
							local v2170 = p9.Position
							local v2195 = v2170.Y
							local v2196 = v2195.Scale
							if v2167 == v2196 then
								v2167 = UDim2.new
								v2196 = 0.75
								v2195 = 0
								v2152 = p9.Position.Y.Scale
								v2170 = v2152 - 0.062
								v2152 = 0
								p9.Position = v2167(v2196, v2195, v2170, v2152)
							end
						end
					end
				end
			end
		end
		v2164 = false
		v2135 = v2164
		v2164 = wait
		v2165 = 5
		v2164(v2165)
		if not p9 then
			v2162 = p9
			v2161 = TweenInfo.new
			v2194 = 0.075
			local v2176 = {}
			v2173 = UDim2.new
			v2172 = p9.Position
			v2176.Position = v2173(1.15, 0, v2172.Y.Scale, 0)
			(v21:Create(v2162, v2161(v2194), v2176)):Play()
			wait(0.08)
			p9:Destroy()
		end
	end
end
v2006:Connect(v486)
