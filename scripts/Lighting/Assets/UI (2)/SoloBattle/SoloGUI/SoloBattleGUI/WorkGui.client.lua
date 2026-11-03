local v7 = ((workspace:WaitForChild("Server")):WaitForChild("GameModeScripts")):WaitForChild("SoloBattle")
local v8 = false
local v11 = game:GetService("TweenService")
local v12 = false
local function TXTSCROLL_1(p1)
	while true do
		wait()
		local v16 = v8
		if v16 == false then
			v16 = script.Parent.TextBox.Size
			if v16 ~= UDim2.new(0, 0, 0, 0) then
				break
			end
		end
	end
	v16 = true
	v8 = v16
	v22 = script.Parent.TextBox
	v16 = v22.TXT
	v22 = 0
	v16.MaxVisibleGraphemes = v22
	v22 = script.Parent
	v16 = v22.TextBox
	v16:TweenSize(UDim2.new(0.3, 0, 0.2, 0), "InOut", "Quad", 0.1)
	v22 = script.Parent.TextBox
	v22.TXT.Text = p1
	local v35 = script
	local v36 = v35.Parent
	local v59 = v36.TextBox
	v22 = v59.TXT.Text
	wait(0.1)
	while true do
		wait(0.005)
		local v41 = v8
		if v41 == true then
			v59 = script
			v41 = v59.Parent.TextBox
			v59 = 0.3
			v36 = 0
			v35 = 0.2
			v41.Size = UDim2.new(v59, v36, v35, 0)
			v41 = script.TEXT
			local v45 = v41:Clone()
			v45.PlayOnRemove = true
			v45.Parent = script
			v45:Destroy()
			script.Parent.TextBox.TXT.MaxVisibleGraphemes = script.Parent.TextBox.TXT.MaxVisibleGraphemes + 1
		end
		v46 = script
		v47 = v46.Parent
		v48 = v47.TextBox
		v49 = v48.TXT
		v45 = v49.MaxVisibleGraphemes
		if string.len(v22) < v45 then
			break
		end
	end
	v45 = false
	v8 = v45
end
TXTSCROLL_1("Waiting for another player to battle..")
v7.Timer.Changed:Connect(function()
	local v189 = v7
	local v190 = v189.Timer
	local v191 = v190.Value
	if v191 == 0 then
		v191 = v12
		if v191 == false then
			v191 = 0
			v190 = true
			v12 = v190
			v190 = pairs
			local v192 = game
			v189 = v192.Players
			local v193, v194, v192 = v190(v189:GetPlayers())
			for v203, v196 in v193, v194, v192 do
				local v195 = v196.Character
				if not v195 then
					v195 = (v196.Character:FindFirstChild("Aspects")):FindFirstChild("Info").Health.Value
					if v195 > 0 then
						v191 = v191 + 1
					end
				end
			end
			if v191 == 1 then
				v193 = pairs
				v192 = game
				v194 = v192.Players
				local v204, v205, v192 = v193(v194:GetPlayers())
				for v203, v196 in v204, v205, v192 do
					v195 = v196.Character
					if not v195 then
						v195 = v196.Character
						v201 = "Aspects"
						local v206 = v195:FindFirstChild(v201)
						if not v206 then
							v202 = v196.Character
							v206 = v202.Aspects
							local v208 = v206:FindFirstChild("Info")
							if not v208 then
								local v209 = v196.Character
								local v210 = v209.Aspects
								local v211 = v210.Info
								v202 = v211.Health
								v208 = v202.Value
								v202 = 0
								if v208 > v202 then
									v211 = script
									v202 = v211.Parent
									v208 = v202.TextBox
									v211 = UDim2.new
									v210 = 0
									v209 = 0
									v208:TweenSize(v211(v210, v209, 0, 0), "InOut", "Quad", 0.1)
									v202 = 0.1
									wait(v202)
									TXTSCROLL_1("" .. v196.Name .. " has won the match!")
								end
							end
						end
					end
				end
			end
			if v191 == 1 then
				v192 = script
				v205 = v192.Parent
				v204 = v205.TextBox
				v192 = UDim2.new
				v203 = 0
				v196 = 0
				v204:TweenSize(v192(v203, v196, 0, 0), "InOut", "Quad", 0.1)
				v205 = 0.1
				wait(v205)
				TXTSCROLL_1("The game resulted in a DRAW!")
			end
			wait(2)
			script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
			while true do
				wait()
				if workspace:FindFirstChild("Map") == nil then
					break
				end
			end
			v249 = false
			v12 = v249
			v249 = script.Parent.TextBox
			v249:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
			wait(0.1)
			TXTSCROLL_1("Waiting for another player to battle..")
			while true do
				wait(0.5)
				if workspace:FindFirstChild("Map") then
					break
				end
			end
			v266 = script.Parent.TextBox
			v266:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
			wait(0.1)
			TXTSCROLL_1("You will be fighting on the map " .. workspace.Map.MapName.Value)
			wait(2)
			script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
			wait(0.1)
			TXTSCROLL_1("3.")
			wait(1)
			script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
			wait(0.1)
			TXTSCROLL_1("2.")
			wait(1)
			script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
			wait(0.1)
			TXTSCROLL_1("1.")
			wait(1)
			script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
			workspace.Server.Spawn:FireServer()
		end
	end
end)
v7.Timer.Changed:Connect(function()
	script.Parent.Timer.TimeTXT.Text = "" .. v7.Timer.Value
	script.Parent:TweenSize(UDim2.new(1.03, 0, 1, 0), "Out", "Quad", 0.15)
	local v386 = {}
	v386.Rotation = script.Parent.Timer.Img.Rotation + 5
	(v11:Create(script.Parent.Timer.Img, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0), v386)):Play()
	wait(0.155)
	script.Parent:TweenSize(UDim2.new(1, 0, 1, 0), "In", "Quad", 0.15)
end)
(function()
	script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
	wait(0.1)
	TXTSCROLL_1("Waiting for another player to battle..")
	while true do
		wait(0.5)
		if workspace:FindFirstChild("Map") then
			break
		end
	end
	v92 = script.Parent.TextBox
	v92:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
	wait(0.1)
	TXTSCROLL_1("You will be fighting on the map " .. workspace.Map.MapName.Value)
	wait(2)
	script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
	wait(0.1)
	TXTSCROLL_1("3.")
	wait(1)
	script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
	wait(0.1)
	TXTSCROLL_1("2.")
	wait(1)
	script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
	wait(0.1)
	TXTSCROLL_1("1.")
	wait(1)
	script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
	workspace.Server.Spawn:FireServer()
end)()
