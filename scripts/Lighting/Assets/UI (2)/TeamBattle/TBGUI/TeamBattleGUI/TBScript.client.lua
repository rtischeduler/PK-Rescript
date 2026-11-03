local v7 = ((workspace:WaitForChild("Server")):WaitForChild("GameModeScripts")):WaitForChild("TeamBattle")
local v8 = false
local v11 = game:GetService("TweenService")
while true do
	wait()
	local v14 = game.Players
	local v16 = v14.LocalPlayer:FindFirstChild("INVLOADED")
	if not v16 then
		v14 = game.Players.LocalPlayer.INVLOADED
		v16 = v14.Value
		if v16 == true then
			break
		end
	end
end
local function TXTSCROLL_1(p1)
	while true do
		wait()
		local v22 = v8
		if v22 == false then
			v22 = script.Parent.TextBox.Size
			if v22 ~= UDim2.new(0, 0, 0, 0) then
				break
			end
		end
	end
	v22 = true
	v8 = v22
	v28 = script.Parent.TextBox
	v22 = v28.TXT
	v28 = 0
	v22.MaxVisibleGraphemes = v28
	v28 = script.Parent
	v22 = v28.TextBox
	v22:TweenSize(UDim2.new(0.3, 0, 0.2, 0), "InOut", "Quad", 0.1)
	v28 = script.Parent.TextBox
	v28.TXT.Text = p1
	local v41 = script
	local v42 = v41.Parent
	local v65 = v42.TextBox
	v28 = v65.TXT.Text
	wait(0.1)
	while true do
		wait(0.005)
		local v47 = v8
		if v47 == true then
			v65 = script
			v47 = v65.Parent.TextBox
			v65 = 0.3
			v42 = 0
			v41 = 0.2
			v47.Size = UDim2.new(v65, v42, v41, 0)
			v47 = script.TEXT
			local v51 = v47:Clone()
			v51.PlayOnRemove = true
			v51.Parent = script
			v51:Destroy()
			script.Parent.TextBox.TXT.MaxVisibleGraphemes = script.Parent.TextBox.TXT.MaxVisibleGraphemes + 1
		end
		v52 = script
		v53 = v52.Parent
		v54 = v53.TextBox
		v55 = v54.TXT
		v51 = v55.MaxVisibleGraphemes
		if string.len(v28) < v51 then
			break
		end
	end
	v51 = false
	v8 = v51
end
v14 = TXTSCROLL_1
v19 = "Waiting for map."
v14(v19)
while true do
	wait()
	v18 = "Map"
	if workspace:FindFirstChild(v18) then
		break
	end
end
v78 = wait
v78(0.05)
v17 = 0
script.Parent.TextBox:TweenSize(UDim2.new(v17, 0, 0, 0), "InOut", "Quad", 0.1)
wait(0.1)
TXTSCROLL_1("Next round starting now.")
wait(1.5)
script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
wait(0.1)
TXTSCROLL_1("You will fight on " .. workspace.Map.MapName.Value)
wait(2)
workspace.Server.Spawn:FireServer()
wait(1.5)
script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
v7.BlueTeam.Score.Changed:Connect(function()
	script.Parent.BlueLabel.TimeTXT.Text = "" .. v7.BlueTeam.Score.Value
end)
v7.RedTeam.Score.Changed:Connect(function()
	script.Parent.RedLabel.TimeTXT.Text = "" .. v7.RedTeam.Score.Value
end)
v7.Timer.Changed:Connect(function()
	script.Parent.Timer.TimeTXT.Text = "" .. v7.Timer.Value
	script.Parent:TweenSize(UDim2.new(1.03, 0, 1, 0), "Out", "Quad", 0.15)
	local v172 = {}
	v172.Rotation = script.Parent.Timer.Img.Rotation + 5
	(v11:Create(script.Parent.Timer.Img, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0), v172)):Play()
	wait(0.155)
	script.Parent:TweenSize(UDim2.new(1, 0, 1, 0), "In", "Quad", 0.15)
	local v190 = v7
	local v191 = v190.Timer.Value
	local v263 = 0
	if v263 >= v191 then
		v190 = v7.RedTeam
		v263 = v190.Score
		v191 = v263.Value
		local v264 = v7
		v190 = v264.ScoreToWin
		v263 = v190.Value
		if v263 < v191 then
			v264 = v7
			v190 = v264.RedTeam
			v263 = v190.Score
			v191 = v263.Value
			local v193 = v7
			v264 = v193.BlueTeam
			v190 = v264.Score
			v263 = v190.Value
			if v191 > v263 then
				v191 = TXTSCROLL_1
				v263 = "Red team has won the round."
				v191(v263)
			end
			v264 = v7
			v190 = v264.BlueTeam
			local v195 = v190.Score.Value
			v264 = v7
			v190 = v264.ScoreToWin
			local v265 = v190.Value
			if v265 < v195 then
				v264 = v7
				v190 = v264.RedTeam
				v265 = v190.Score
				v195 = v265.Value
				v193 = v7
				v264 = v193.BlueTeam
				v190 = v264.Score
				v265 = v190.Value
				if v265 > v195 then
					v195 = TXTSCROLL_1
					v265 = "Blue team has won the round."
					v195(v265)
				end
				wait(4)
				while true do
					wait()
					v190 = "Map"
					if workspace:FindFirstChild(v190) then
						break
					end
				end
				v200 = wait
				v200(0.05)
				v264 = 0
				v193 = 0
				script.Parent.TextBox:TweenSize(UDim2.new(v264, v193, 0, 0), "InOut", "Quad", 0.1)
				wait(0.1)
				local v212 = game
				local v213 = v212.Players
				local v214 = v213.LocalPlayer
				local v215 = v214.Character
				if not v215 then
					v212 = game
					v213 = v212.Players
					v214 = v213.LocalPlayer
					v215 = v214.Character
					v215:Destroy()
				end
				TXTSCROLL_1("Next round starting now.")
				wait(1.5)
				script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
				wait(0.1)
				TXTSCROLL_1("You will fight on " .. workspace.Map.MapName.Value)
				wait(2)
				workspace.Server.Spawn:FireServer()
				wait(1.5)
				script.Parent.TextBox:TweenSize(UDim2.new(0, 0, 0, 0), "InOut", "Quad", 0.1)
				return 
			end
		end
	end
end)
