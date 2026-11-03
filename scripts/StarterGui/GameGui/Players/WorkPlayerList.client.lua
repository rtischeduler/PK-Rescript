local v3 = game:GetService("UserInputService")
local v4 = false
local v121 = game.Players.MaxPlayers
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
v3.InputBegan:Connect(function(p1, p2)
	local v16 = p1.KeyCode
	local v17 = Enum.KeyCode.Tab
	if v16 == v17 then
		if p2 == false then
			v16 = v4
			if v16 == false then
				v17 = script.Parent
				v16 = v17.TT
				local v19 = workspace
				local v20 = v19.Server
				v17 = v20.GameMode.Value
				v16.Text = v17
				local v40 = script
				v17 = v40.Parent
				v16 = v17.Visible
				if v16 == false then
					v16 = true
					v4 = v16
					v17 = script
					v16 = v17.Parent
					v17 = true
					v16.Visible = v17
					v17 = script
					v16 = v17.Parent
					local v21 = script
					v19 = v21.Parent.Colors
					v20 = v19.FullSize
					v40 = v20.Size
					v20 = "InOut"
					v19 = "Linear"
					v16:TweenSize(v40, v20, v19, 0.05)
					v17 = 0.05
					wait(v17)
					local v26 = v3:IsKeyDown(Enum.KeyCode.Tab)
					if v26 == false then
						local v27 = script
						local v28 = v27.Parent
						v26 = v28.Visible
						if v26 == true then
							v28 = script
							v26 = v28.Parent
							v28 = true
							v26.Visible = v28
							v28 = script
							v26 = v28.Parent
							v27 = UDim2.new
							v21 = 0
							v26:TweenSize(v27(0, 0, 0, v21), "InOut", "Linear", 0.05)
							v28 = 0.05
							wait(v28)
							script.Parent.Visible = false
						end
					end
					v38 = false
					v4 = v38
				end
			end
		end
	end
end)
v3.InputEnded:Connect(function(p3, p4)
	local v45 = p3.KeyCode
	local v46 = Enum.KeyCode.Tab
	if v45 == v46 then
		if p4 == false then
			v45 = v4
			if v45 == false then
				local v47 = script
				v46 = v47.Parent
				v45 = v46.Visible
				if v45 == true then
					v45 = true
					v4 = v45
					v46 = script
					v45 = v46.Parent
					v47 = UDim2.new
					v45:TweenSize(v47(0, 0, 0, 0), "InOut", "Linear", 0.05)
					v46 = 0.05
					wait(v46)
					script.Parent.Visible = false
					v4 = false
				end
			end
		end
	end
end)
game:GetService("RunService").Stepped:Connect(function()
	local v63 = script
	local v64 = v63.Parent
	local v65 = v64.Visible
	if v65 == true then
		v65 = 0
		v64 = pairs
		local v66 = game
		v63 = v66.Players
		local v67, v68, v66 = v64(v63:GetPlayers())
		for v80, v71 in v67, v68, v66 do
			if not v71:FindFirstChild("Stats") then
				local v74 = v71:FindFirstChild("Number")
				if not v74 then
					v74 = v71.Number
					v74:Destroy()
				end
				local v78 = Instance.new("NumberValue", v71)
				v78.Name = "Number"
				v65 = v65 + 1
				v78.Value = v65
			end
		end
		v67 = pairs
		v66 = script
		v68 = v66.Parent
		local v81, v82, v66 = v67(v68:GetChildren())
		for v80, v71 in v81, v82, v66 do
			local v84 = v71:IsA("Frame")
			if not v84 then
				v84 = false
				v71.Visible = v84
				v84 = pairs
				local v85 = game
				v79 = v85.Players
				local v86, v87, v85 = v84(v79:GetPlayers())
				for v109, v90 in v86, v87, v85 do
					local v91 = v90:FindFirstChild("Number")
					if not v91 then
						v91 = v90.Number.Value
						local v93 = v71.Number
						local v110 = v93.Value
						if v91 == v110 then
							v91 = v90.Character
							if not v91 then
								v91 = require
								v110 = v90.Character
								local v96 = game
								v93 = v96.Players
								local v97 = v93.LocalPlayer
								if v90 == v97 then
									v96 = script.Parent.Colors
									v93 = v96.YourColor
									v97 = v93.BackgroundColor3
									v71.BackgroundColor3 = v97
								else
									v98 = script
									v99 = v98.Parent
									v96 = v99.Colors
									v93 = v96.OtherColor
									v97 = v93.BackgroundColor3
									v71.BackgroundColor3 = v97
								end
								local v100 = v90:FindFirstChild("PlayerTeam")
								if not v100 then
									v93 = v90.Character.TeamBrick
									v100 = v93.Color
									v71.BackgroundColor3 = v100
								end
								v71.Visible = true
								v93 = v90.Name
								v71.PlayerName.Text = v93
								v93 = v71.KaijuImage
								v93 = v91(v110:WaitForChild("Settings")).KaijuImage
								v93.KaijuImage.Image = v93
								v93 = v71.Rank
								v101 = "Level "
								local v102 = v90.Inventory
								local v103 = v102.XP
								v98 = v103.Level
								v99 = v98.Value
								v93 = v101 .. v99
								v93.TX.Text = v93
								local v116 = v71.Stats
								v101 = ""
								local v104 = v90.Stats
								local v105 = v104.K
								v99 = v105.Value
								v98 = "K / "
								local v118 = v90.Stats.D
								local v119 = v118.Value
								local v120 = "D"
								v93 = v101 .. v99 .. v98 .. v119 .. v120
								v116.Text = v93
								if not v90 then
									v116 = pairs
									v118 = game
									v120 = v118.ReplicatedStorage
									v119 = v120.Assets
									v98 = v119.Kaijus
									v99 = v98.UI
									v101 = v99.InGame
									v93 = v101.RankIcons
									local v106, v107, v101 = v116(v93:GetChildren())
									for v99, v98 in v106, v107, v101 do
										v103 = v98.Name
										v104 = v90.Inventory.XP
										v105 = v104.Rank
										v102 = v105.Value
										if v103 == v102 then
											v103 = v71.Rank
											v104 = v98.PlayerHolder
											v105 = v104.RankTxt
											v102 = v105.ImageColor3
											v103.ImageColor3 = v102
											v103 = v71.RankIcon
											v104 = v98.PlayerHolder
											v105 = v104.Rank
											v102 = v105.Image
											v103.Image = v102
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
end)
