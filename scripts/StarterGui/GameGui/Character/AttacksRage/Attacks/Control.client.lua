local TweenService = game:GetService("TweenService")

-- FOR EACH IMAGEBUTTON IN SCRIPT.PARENT	
for _, v in pairs(script.Parent:GetChildren()) do
	if v:IsA("ImageButton") then
		v.Button.MouseButton1Click:Connect(function()

			--EVENTNAME ADD "Event" at the end of v.Name
			local EventName = v.Name .. "Event"
			local barGrad = v:WaitForChild("BarGrad")
		


			-- Find ServerEvent inside of game.Workspace.Server
			local ServerEvent = game.Workspace.Server:FindFirstChild(EventName)

			if ServerEvent then
				ServerEvent:FireServer()
			else
				warn("ServerEvent not found in Workspace.Server")
			end

			local SP1Duration = 2
			local SP2Duration = 7
			local SP3Duration = 2
			local GrabDuration = 1
			-- Dont let user press again until finished for 5 seconds
			v.Button.Visible = false
			if v.Name == "SP1" then
				wait(SP1Duration)
			elseif v.Name == "SP2" then
				wait(SP2Duration)
			elseif v.Name == "SP3" then
				wait(SP3Duration)
			elseif v.Name == "Grab" then
				wait(GrabDuration)
			end
		
			barGrad.Offset = Vector2.new(0, 0)


			-- COUNTDOWN SYSTEM ANY VALUE MAKE v.CD.Text countdown based off of duration Variables
			v.CD.Visible = true
			local tweenInfo = nil
			-- SET TWEEN DURATION BASED OFF OF NAME
		if v.Name == "SP1" then
				tweenInfo = TweenInfo.new(
					SP1Duration, -- Duration: 3 seconds to fill back
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
			elseif v.Name == "SP2" then
				tweenInfo = TweenInfo.new(
					SP2Duration, -- Duration: 3 seconds to fill back
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
			elseif v.Name == "SP3" then
				tweenInfo = TweenInfo.new(
					SP3Duration, -- Duration: 3 seconds to fill back
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
			elseif v.Name == "Grab" then
				tweenInfo = TweenInfo.new(
					GrabDuration, -- Duration: 3 seconds to fill back
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out
				)
		end
			
			local tween = TweenService:Create(barGrad, tweenInfo, {Offset = Vector2.new(0, 1)})
			tween:Play()
			
			v.TXT.Visible = false
			v.Img.Visible = false
			if v.Name == "SP1" then
				v.CD.Text = SP1Duration
				while SP1Duration > 0 do
					wait(1)
					SP1Duration = SP1Duration - 1
					v.CD.Text = SP1Duration
				end
			elseif v.Name == "SP2" then
				v.CD.Text = SP2Duration
				while SP2Duration > 0 do
					wait(1)
					SP2Duration = SP2Duration - 1
					v.CD.Text = SP2Duration
				end
				elseif v.Name == "SP3" then
				v.CD.Text = SP3Duration
				while SP3Duration > 0 do
					wait(1)
					SP3Duration = SP3Duration - 1
					v.CD.Text = SP3Duration
				end
			elseif v.Name == "Grab" then
				v.CD.Text = GrabDuration
				while GrabDuration > 0 do
					wait(1)
					GrabDuration = GrabDuration - 1
					v.CD.Text = GrabDuration
				end
			end
			
			-- COUNTDOWN SYSTEM ANY VALUE
			local v200 = script.Parent.Parent.Parent.HealthStats.SetupHPandAttacks.Sounds.Shine:Clone()
			v200.Parent = script
			v200:Play()
			v.TXT.Visible = true
			v.Img.Visible = true
			v.CD.Visible = false
			local p8 = 0
			local p7 = v.Flash
			v200.PlayOnRemove = true
			v200:Destroy()
			p7.Image = "0"
			p7.Image = "rbxassetid://9306185645"
			wait(p8)
			p7.Image = "rbxassetid://9306185497"
			wait(p8)
			p7.Image = "rbxassetid://9306185349"
			wait(p8)
			p7.Image = "rbxassetid://9306185183"
			wait(p8)
			p7.Image = "rbxassetid://9306185027"
			wait(p8)
			p7.Image = "rbxassetid://9306184888"
			wait(p8)
			p7.Image = "rbxassetid://9306184747"
			wait(p8)
			p7.Image = "rbxassetid://9306184554"
			wait(p8)
			p7.Image = "rbxassetid://9306184434"
			wait(p8)
			p7.Image = "rbxassetid://9306184265"
			wait(p8)
			p7.Image = "0"
			v200:Destroy()
			v.Button.Visible = true



		end)

	end
end

while true do
	local p10 = 0
	local p9 = script.Parent.Parent.Rage.Ready
	p9.Visible = true
	wait()
	p9.Visible = true
	p9.Image = "rbxassetid://9316238151"
	wait(p10)
	p9.Image = "rbxassetid://9316237977"
	wait(p10)
	p9.Image = "rbxassetid://9316237818"
	wait(p10)
	p9.Image = "rbxassetid://9316237700"
	wait(p10)
	p9.Image = "rbxassetid://9316237609"
	wait(p10)
	p9.Image = "rbxassetid://9316237541"
	wait(p10)
	p9.Image = "rbxassetid://9316237468"
	wait(p10)
	p9.Image = "rbxassetid://9316237387"
	wait(p10)
	p9.Image = "rbxassetid://9316237261"
	wait(p10)
	p9.Image = "rbxassetid://9316237110"
	wait(p10)
	p9.Image = "rbxassetid://9316236916"
	wait(p10)
	p9.Image = "rbxassetid://9316236777"
	wait(p10)
	p9.Image = "rbxassetid://9316236668"
	wait(p10)
	p9.Image = "rbxassetid://9316236541"
	wait(p10)
	p9.Image = "rbxassetid://9316236435"
	wait(p10)
	p9.Image = "rbxassetid://9316236311"
	wait(p10)
	p9.Image = "rbxassetid://9316236130"
	wait(p10)
	p9.Image = "rbxassetid://9316235970"
	wait(p10)
	p9.Image = "rbxassetid://9316235769"
	wait(p10)
	p9.Image = "rbxassetid://9316235596"
	wait(p10)
	p9.Image = "rbxassetid://9316235472"
	wait(p10)
	p9.Image = "rbxassetid://9316235372"
	wait(p10)
	p9.Image = "rbxassetid://9316235228"
	wait(p10)
	p9.Image = "rbxassetid://9316235059"
	
end




-- FOR EACH IMAGEBUTTON IN SCRIPT.PARENT	
