while true do
	wait()
	local v2 = game
	local v3 = v2.Players
	local v4 = v3.LocalPlayer
	local v5 = v4.Character
	if not v5 then
		v2 = game
		v3 = v2.Players
		v4 = v3.LocalPlayer
		v5 = v4.Character
		v3 = "Settings"
		if v5:FindFirstChild(v3) then
			break
		end
	end
end
v2 = game
v4 = v2.Players.LocalPlayer
v6 = v4.Character
v2 = "Humanoid"
local v8 = v6:WaitForChild(v2)
local v12 = script.Parent.Parent.Parent:WaitForChild("Control")
local v13 = v6:WaitForChild("Aspects")
local v17
do
	local _success, _result = pcall(function()
		return require(v6:WaitForChild("Settings"))
	end)
	if _success and type(_result) == "table" then
		v17 = _result
	else
		local _p = game.Players.LocalPlayer
		local _inv = _p:FindFirstChild("Inventory")
		local _eq = _inv and _inv:FindFirstChild("EquippedKaiju")
		local _kj = _eq and _eq.Value or "Godzilla2000"
		local _compat = {G2K = "Zilla", Gigan = "ShowaGigan"}
		if _compat[_kj] then _kj = _compat[_kj] end
		local _map = {
			Godzilla2000 = {Kaiju = "Godzilla2000", KaijuName = "Godzilla 2000", KaijuImage = "rbxassetid://9001341666"},
			TitanusGodzilla = {Kaiju = "TitanusGodzilla", KaijuName = "Titanus Godzilla", KaijuImage = "rbxassetid://10767598689"},
			ShowaGigan = {Kaiju = "ShowaGigan", KaijuName = "Showa Gigan", KaijuImage = "rbxassetid://10516719614"},
			Orga = {Kaiju = "Orga", KaijuName = "Orga", KaijuImage = "rbxassetid://9362887059"},
			Zilla = {Kaiju = "Zilla", KaijuName = "Zilla", KaijuImage = "rbxassetid://10245061487"},
			Gamma = {Kaiju = "Gamma", KaijuName = "Gamma", KaijuImage = "rbxassetid://10860355646"},
			MechaGodzilla2021 = {Kaiju = "MechaGodzilla2021", KaijuName = "MechaGodzilla", KaijuImage = "rbxassetid://9001341666"},
		}
		v17 = _map[_kj] or _map.Godzilla2000
		print("[SetupHPandAttacks] Settings require failed, using fallback: " .. _kj)
	end
end
local v20 = game:GetService("TweenService")
local v23 = game:GetService("RunService")
local v27 = script.Parent.Parent.Cooldowns
v6:WaitForChild("TeamBrick")
v6:WaitForChild("Head")
v6:WaitForChild("Torso")
local v32 = v6.TeamBrick.Color
local v863 = v17.Kaiju
if v863 == "Zilla" then
	v863 = script.Parent.Parent.AttacksRage.Attacks
	v863:WaitForChild("Jump")
end
v36 = game
v34 = "UserInputService"
local v37 = v36:GetService(v34)
local v38 = v37.TouchEnabled
if not v38 then
	v33 = script.Parent.Parent
	v37 = v33.Parent.Character.Cooldowns
	v38 = v37.Mobile
	v37 = true
	v38.Visible = v37
end
v41 = "UserInputService"
local v43 = game:GetService(v41)
local v866 = v43.GamepadEnabled
if not v866 then
	v42 = game
	v43 = v42.Players
	v866 = v43.LocalPlayer
	v42 = v12.Values.CamOffset
	v43 = v42.Value
	v866.CameraMinZoomDistance = v43
	v42 = game
	v43 = v42.Players
	v866 = v43.LocalPlayer
	v33 = v12.Values
	v42 = v33.CamOffset.Value
	v43 = v42 * 1.5
	v866.CameraMaxZoomDistance = v43
end
v44 = game
v42 = v44.Players
local v868 = v42.LocalPlayer
v42 = "GameGui"
local v45 = v868.PlayerGui:FindFirstChild(v42)
if not v45 then
	v868 = game
	v44 = "UserInputService"
	local v46 = v868:GetService(v44)
	v45 = v46.GamepadEnabled
	if v45 == false then
		v45 = pairs
		v39 = game
		v40 = v39.Players
		v33 = v40.LocalPlayer
		local v48 = v33.PlayerGui.GameGui
		v46 = v48.Character
		local v49, v50, v48 = v45(v46:GetDescendants())
		for v47, v33 in v49, v50, v48 do
			v40 = pairs
			local v51 = game
			local v53 = v51.Players.LocalPlayer
			v39 = v53.Settings
			local v54, v55, v53 = v40(v39:GetDescendants())
			for v52, v51 in v54, v55, v53 do
				local v57 = v33.Name
				if v51.Name == v57 then
					local v59 = v33:FindFirstChild("TXT")
					if not v59 then
						local v60 = v33.Parent
						v57 = v60.Parent
						v59 = v57.Name
						if v59 == "Mobile" then
							v57 = v33.TXT
							v59 = v57.TXT
							v60 = ""
							v57 = v60 .. tostring(v51.Value)
							v59.Text = v57
						end
					end
				end
			end
		end
	else
		v59 = game
		v51 = v59.Players
		v52 = v51.LocalPlayer
		v53 = v52.PlayerGui
		v55 = v53.GameGui
		v54 = v55.Character
		v33 = v54.HealthStats
		v47 = v33.Attacks
		v48 = v47.Block
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "LT"
		v49.Text = v50
		v59 = game
		v51 = v59.Players
		v52 = v51.LocalPlayer
		v53 = v52.PlayerGui
		v55 = v53.GameGui
		v54 = v55.Character
		v33 = v54.HealthStats
		v47 = v33.Attacks
		v48 = v47.Roar
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "RB"
		v49.Text = v50
		v59 = game
		v51 = v59.Players
		v52 = v51.LocalPlayer
		v53 = v52.PlayerGui
		v55 = v53.GameGui
		v54 = v55.Character
		v33 = v54.HealthStats
		v47 = v33.Attacks
		v48 = v47.Escape
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "A"
		v49.Text = v50
		v59 = game
		v51 = v59.Players
		v52 = v51.LocalPlayer
		v53 = v52.PlayerGui
		v55 = v53.GameGui
		v54 = v55.Character
		v33 = v54.AttacksRage
		v47 = v33.Attacks
		v48 = v47.Grab
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "LB"
		v49.Text = v50
		v59 = game
		v51 = v59.Players
		v52 = v51.LocalPlayer
		v53 = v52.PlayerGui
		v55 = v53.GameGui
		v54 = v55.Character
		v33 = v54.AttacksRage
		v47 = v33.Attacks
		v48 = v47.SP1
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "A"
		v49.Text = v50
		v59 = game
		v51 = v59.Players
		v52 = v51.LocalPlayer
		v53 = v52.PlayerGui
		v55 = v53.GameGui
		v54 = v55.Character
		v33 = v54.AttacksRage
		v47 = v33.Attacks
		v48 = v47.SP2
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "B"
		v49.Text = v50
		v59 = game
		v51 = v59.Players
		v52 = v51.LocalPlayer
		v53 = v52.PlayerGui
		v55 = v53.GameGui
		v54 = v55.Character
		v33 = v54.AttacksRage
		v47 = v33.Attacks
		v48 = v47.SP3
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "X"
		v49.Text = v50
		v51 = game
		v52 = v51.Players
		v53 = v52.LocalPlayer
		v55 = v53.PlayerGui
		v54 = v55.GameGui
		v33 = v54.Character
		v47 = v33.AttacksRage
		v48 = v47.Rage
		v50 = v48.TXT
		v49 = v50.TXT
		v50 = "Y"
		v49.Text = v50
	end
	local function updatelvl_1()
		local v67 = game:GetService("UserInputService")
		local v68 = v67.GamepadEnabled
		if not v68 then
			v67 = game.Players
			v68 = v67.LocalPlayer
			v67 = v12.Values.CamOffset.Value
			v68.CameraMinZoomDistance = v67
			v67 = game.Players
			v68 = v67.LocalPlayer
			v67 = v12.Values.CamOffset.Value * 1.5
			v68.CameraMaxZoomDistance = v67
		end
		v71 = game
		v69 = v71.Players
		local v94 = v69.LocalPlayer
		v69 = "Menu"
		local v73 = v94.PlayerGui:FindFirstChild(v69)
		if v73 then
			v72 = game.Players
			v70 = v72.LocalPlayer
			v71 = v70.PlayerGui
			v94 = v71.Menu.XPBar
			v73 = v94.Bar
			v94 = UDim2.new
			v72 = game.Players.LocalPlayer.Inventory
			v70 = v72.XP
			v71 = v70.Value
			v72 = game.Players.LocalPlayer.Inventory.XP.XPToEarn
			v70 = v72.Value
			v72 = 0
			v73.Size = v94(v71 / v70, v71, v70, v72)
			v73 = game.Players.LocalPlayer.PlayerGui.Menu.XPBar.TextLabel
			v73.Text = "" .. game.Players.LocalPlayer.Inventory.XP.Value .. "/" .. game.Players.LocalPlayer.Inventory.XP.XPToEarn.Value .. " XP"
		end
		v79 = game
		v76 = v79.Players
		v77 = v76.LocalPlayer
		v74 = v77.PlayerGui
		v81 = v74.GameGui
		v82 = v81.Character
		v83 = v82.HealthStats
		v84 = v83.PlayerHolder
		v80 = v84.RankTxt
		v84 = "Level "
		v79 = game
		v76 = v79.Players
		v77 = v76.LocalPlayer
		v74 = v77.Inventory
		v81 = v74.XP
		v82 = v81.Level
		v83 = v82.Value
		v80 = v84 .. v83
		v80.TX.Text = v80
		v77 = game
		v74 = v77.ReplicatedStorage
		v81 = v74.Assets
		v82 = v81.Kaijus
		v83 = v82.UI
		v84 = v83.InGame
		v80 = v84.RankIcons
		local v87, v88, v84 = pairs(v80:GetChildren())
		for v83, v82 in v87, v88, v84 do
			v81 = v82.Name
			v86 = game
			v85 = v86.Players
			v78 = v85.LocalPlayer
			v79 = v78.Inventory
			v76 = v79.XP
			v77 = v76.Rank
			v74 = v77.Value
			if v81 == v74 then
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.RankTxt
				v76 = v82.PlayerHolder
				v77 = v76.RankTxt
				v74 = v77.ImageColor3
				v81.ImageColor3 = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Rank
				v76 = v82.PlayerHolder
				v77 = v76.Rank
				v74 = v77.Image
				v81.Image = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Rank
				v76 = v82.PlayerHolder
				v77 = v76.Rank
				v74 = v77.ZIndex
				v81.ZIndex = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Rank
				v76 = v82.PlayerHolder
				v77 = v76.Rank
				v74 = v77.ImageTransparency
				v81.ImageTransparency = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Ring
				v76 = v82.PlayerHolder
				v77 = v76.Ring
				v74 = v77.ZIndex
				v81.ZIndex = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Rank
				v76 = v82.PlayerHolder
				v77 = v76.Rank
				v74 = v77.ImageColor3
				v81.ImageColor3 = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Ring
				v76 = v82.PlayerHolder
				v77 = v76.Ring
				v74 = v77.ImageColor3
				v81.ImageColor3 = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Ring
				v76 = v82.PlayerHolder
				v77 = v76.Ring
				v74 = v77.ZIndex
				v81.ZIndex = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Ring
				v76 = v82.PlayerHolder
				v77 = v76.Ring
				v74 = v77.ImageTransparency
				v81.ImageTransparency = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Rank
				v76 = v82.PlayerHolder
				v77 = v76.Rank
				v74 = v77.Size
				v81.Size = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Rank
				v76 = v82.PlayerHolder
				v77 = v76.Rank
				v74 = v77.Position
				v81.Position = v74
				v76 = script
				v77 = v76.Parent
				v74 = v77.PlayerHolder
				v81 = v74.Rank
				v76 = v82.PlayerHolder
				v77 = v76.Rank
				v74 = v77.AnchorPoint
				v81.AnchorPoint = v74
			end
		end
	end
	v50 = updatelvl_1
	v50()
	v53 = game
	v55 = v53.Players
	v54 = v55.LocalPlayer
	v33 = v54.Inventory
	v47 = v33.XP
	v48 = v47.Level
	v47 = function()
		updatelvl_1()
	end
	v48.Changed:Connect(v47)
	v55 = game
	v54 = v55.Players
	v33 = v54.LocalPlayer
	v48 = v33.Inventory.XP
	v48.Changed:Connect(function()
		updatelvl_1()
	end)
	v53 = game
	v55 = v53.Players
	v54 = v55.LocalPlayer
	v33 = v54.Inventory
	v48 = v33.XP.Rank
	v48.Changed:Connect(function()
		updatelvl_1()
	end)
	v33 = script
	local v129 = v33.Parent
	v48 = v129.Parent
	local v130, v131, v129 = pairs(v48:GetDescendants())
	for v33, v54 in v130, v131, v129 do
		v55 = v54.Name
		if v55 == "BarGrad" then
			v55 = ColorSequence.new
			v53 = {}
			v52 = ColorSequenceKeypoint.new
			v51 = 0
			v59 = Color3.fromRGB
			v57 = 255
			v60 = 255
			v63 = 255
			v53[1] = v52(v51, v59(v57, v60, v63))
			v53[2] = ColorSequenceKeypoint.new(0.001, v32)
			v53[3] = ColorSequenceKeypoint.new(1, v32)
			v54.Color = v55(v53)
		end
	end
	resizeCustomLoadingBarX = function(p1, p2, p3)
		p2.Size = UDim2.new(p1, p2.Size.X.Offset, p2.Size.Y.Scale, p2.Size.Y.Offset)
		if p1 > 0 then
			p3.Size = UDim2.new(1 / p1, p3.Size.X.Offset, p3.Size.Y.Scale, p3.Size.Y.Offset)
		else
			p3.Size = UDim2.new(0, p3.Size.X.Offset, p3.Size.Y.Scale, p3.Size.Y.Offset)
		end
	end
	resizeCustomLoadingBarY = function(p4, p5, p6)
		p5.Size = UDim2.new(1, p5.Size.X.Offset, p4, p5.Size.Y.Offset)
		if p4 > 0 then
			p6.Size = UDim2.new(1, p6.Size.X.Offset, 1 / p4, p6.Size.Y.Offset)
		else
			p6.Size = UDim2.new(1, p6.Size.X.Offset, 0, p6.Size.Y.Offset)
		end
	end
	local function FlashGif_1(p7, p8)
		local v200 = script.Sounds.Shine:Clone()
		v200.Parent = script
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
	end
	local function FireGif_1(p9, p10)
		while true do
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
			if v13.Info.Rage.Value <= v13.Info.Rage.MaxRage.Value then
				break
			end
		end
		v283 = false
		p9.Visible = v283
	end
	v129 = FlashGif_1
	v140 = script
	v136 = v140.Parent
	v132 = v136.Parent
	v155 = v132.AttacksRage.Attacks
	v54 = v155.Grab
	v33 = v54.Flash
	v54 = 0.035
	v129(v33, v54)
	v136 = script
	v132 = v136.Parent
	v155 = v132.Parent.AttacksRage
	FireGif_1(v155.Rage.Ready, 0.01)
	TweenSP = function(p11, p12)
		p11.ImageColor3 = Color3.fromRGB(255, 255, 255)
		local v329 = tonumber(p12)
		p11.BarGrad.Offset = Vector2.new(0, 1)
		p11.Img.Visible = false
		p11.CD.Text = "" .. v329
		p11.CD.Visible = true
		local v340 = {}
		v340.Offset = Vector2.new(0, 0)
		(v20:Create(p11.BarGrad, TweenInfo.new(p12 + p12 * 0.1), v340)):Play()
		while true do
			wait(0.988)
			v329 = v329 - 1
			p11.CD.Text = "" .. v329
			if v329 < 0 then
				break
			end
		end
		v347 = p11.CD
		v350 = false
		v347.Visible = v350
		v347 = FlashGif_1
		v350 = p11.Flash
		v348 = 0.035
		v347(v350, v348)
		p11.Img.Visible = true
		local v389 = {}
		v349 = 0
		v389[1] = ColorSequenceKeypoint.new(v349, Color3.fromRGB(255, 255, 255))
		v389[2] = ColorSequenceKeypoint.new(0.001, v32)
		v389[3] = ColorSequenceKeypoint.new(1, v32)
		p11.BarGrad.Color = ColorSequence.new(v389)
		v365 = TweenInfo.new
		v366 = 0.05
		local v372 = {}
		v367 = Vector2.new
		v368 = 0
		v372.Offset = v367(v368, 1)
		(v20:Create(p11.BarGrad, v365(v366), v372)):Play()
	end
	TweenBar = function(p13, p14, p15, p16)
		local v394 = p14.Parent
		if v394.Parent.Name == "Rage" then
			v394 = UDim2.new
			p14:TweenSize(v394(1, 0, 1, 0), "InOut", "Linear", p16)
		end
		local v406 = tonumber(p16)
		local v407 = p14.Parent
		local v409 = v407.Parent.Name
		if v409 == "Rage" then
			v409 = v20
			v407 = p14.Top
			local v413 = {}
			v413.ImageColor3 = v6.TeamBrick.Color
			(v409:Create(v407, TweenInfo.new(0.2), v413)):Play()
			local v422 = {}
			v422.ImageColor3 = v6.TeamBrick.Color
			(v20:Create(p14.Parent.Parent.Outline, TweenInfo.new(0.2), v422)):Play()
		end
		v424 = p14.Parent.Parent
		v417 = v424.CD
		v424 = true
		v417.Visible = v424
		v424 = p14.Parent.Parent
		v417 = v424.CD
		local v459 = ""
		local v427 = p16
		v424 = v459 .. v427
		v417.Text = v424
		while true do
			v417 = wait
			v424 = 0.988
			v417(v424)
			v406 = v406 - 1
			v459 = p14.Parent
			v459 = ""
			v427 = v406
			v459.Parent.CD.Text = v459 .. v427
			if v406 < 0 then
				break
			end
		end
		v429 = FlashGif_1
		local v462 = p14.Parent
		v428 = v462.Parent.Flash
		v429(v428, 0.035)
		local v430 = p14.Parent
		local v432 = v430.Parent.Name
		if v432 == "Rage" then
			v432 = v20
			v430 = p14.Top
			v462 = TweenInfo.new
			local v435 = {}
			v415 = 255
			v414 = 255
			v423 = 255
			v435.ImageColor3 = Color3.fromRGB(v415, v414, v423)
			(v432:Create(v430, v462(0.2), v435)):Play()
			local v443 = {}
			v443.ImageColor3 = Color3.fromRGB(255, 255, 255)
			(v20:Create(p14.Parent.Parent.Outline, TweenInfo.new(0.2), v443)):Play()
		end
		v449 = p14.Parent.Parent
		v438 = v449.CD
		v449 = false
		v438.Visible = v449
	end
	local function UpdateStats_1()
		wait(0.065)
		local v473 = v6:FindFirstChild("TeamBrick")
		if not v473 then
			v473 = pairs
			local v475 = script.Parent
			local v477, v478, v475 = v473(v475.Parent:GetDescendants())
			for v474, v480 in v477, v478, v475 do
				local v479 = v480.Name
				if v479 == "Glow" then
					local v481 = v480.Parent
					local v482 = v481.Parent
					v479 = v482.Name
					if v479 == "EnemyStats" then
						v481 = "ImageLabel"
						local v483 = v480:IsA(v481)
						if not v483 then
							v482 = v6.TeamBrick
							v483 = v482.Color
							v480.ImageColor3 = v483
						end
					end
				end
			end
		end
		v474 = script
		v475 = v474.Parent
		v478 = v475.PlayerHolder
		v477 = v478.PlayerName
		v475 = v6
		v478 = v475.Name
		v477.Text = v478
		v474 = script
		v475 = v474.Parent
		v478 = v475.PlayerHolder
		v477 = v478.KaijuName
		v475 = v17
		v478 = v475.KaijuName
		v477.Text = v478
		v474 = script
		v475 = v474.Parent
		v478 = v475.PlayerHolder
		v477 = v478.KaijuImage
		v475 = v17
		v478 = v475.KaijuImage
		v477.Image = v478
		v474 = script
		v475 = v474.Parent
		v478 = v475.Health
		v477 = v478.TXT
		v475 = ""
		v484 = v13.Info
		v482 = v484.Health
		v474 = v482.Value
		v480 = "/"
		v484 = v13.Info.Health
		v482 = v484.MaxHealth
		v483 = v482.Value
		v478 = v475 .. v474 .. v480 .. v483
		v477.Text = v478
		v474 = script
		v475 = v474.Parent
		v478 = v475.Stamina
		v477 = v478.TXT
		v475 = ""
		v484 = v13.Info
		v482 = v484.Stamina
		v474 = v482.Value
		v480 = "/"
		v484 = v13.Info.Stamina
		v482 = v484.MaxStamina
		v483 = v482.Value
		v478 = v475 .. v474 .. v480 .. v483
		v477.Text = v478
		v483 = script
		v480 = v483.Parent
		v474 = v480.Parent
		v475 = v474.AttacksRage
		v478 = v475.Rage
		v477 = v478.TEXT
		v475 = ""
		v482 = v13
		v483 = v482.Info
		v480 = v483.Rage
		v474 = v480.Value
		v478 = v475 .. v474
		v477.Text = v478
		v477 = resizeCustomLoadingBarY
		v483 = v13
		v480 = v483.Info
		v474 = v480.Rage
		v475 = v474.Value
		v484 = v13
		v482 = v484.Info
		v483 = v482.Rage
		v480 = v483.MaxRage
		v474 = v480.Value
		v478 = v475 / v474
		v484 = script.Parent
		v482 = v484.Parent
		v483 = v482.AttacksRage
		v480 = v483.Rage
		v474 = v480.Clipping
		v475 = v474.Clipping
		v484 = script.Parent.Parent.AttacksRage
		v482 = v484.Rage
		v483 = v482.Clipping
		v480 = v483.Clipping
		v474 = v480.Top
		v477(v478, v475, v474)
		v483 = v13
		v480 = v483.Info
		v484 = v13
		v482 = v484.Info
		v483 = v482.Health
		v480 = v483.MaxHealth
		v483 = script
		v480 = v483.Parent
		v484 = script
		v482 = v484.Parent
		v483 = v482.Health
		v480 = v483.Clipping
		resizeCustomLoadingBarX(v480.Health.Value / v480.Value, v480.Health.Clipping, v480.Top)
		v483 = v13
		v480 = v483.Info
		v484 = v13
		v482 = v484.Info
		v483 = v482.Stamina
		v480 = v483.MaxStamina
		v483 = script
		v480 = v483.Parent
		v484 = script
		v482 = v484.Parent
		v483 = v482.Stamina
		v480 = v483.Clipping
		resizeCustomLoadingBarX(v480.Stamina.Value / v480.Value, v480.Stamina.Clipping, v480.Top)
	end
	UpdateStats_1()
	local v514, v515, v155 = pairs(v13:GetDescendants())
	for v317, v132 in v514, v515, v155 do
		v136 = v132.Changed
		v141 = UpdateStats_1
		v136:Connect(v141)
	end
	v514 = pairs
	v515 = workspace
	local v516, v517, v155 = v514(v515:GetDescendants())
	for v317, v132 in v516, v517, v155 do
		local v520 = v132:IsA("ProximityPrompt")
		if not v520 then
			v143 = v6.HumanoidRootPart
			v142 = v143.Position
			v144 = v6.Grabber
			v143 = v144.Position
			v140 = v142 - v143.magnitude
			v520 = v140 * 1.5
			v132.MaxActivationDistance = v520
		end
	end
	v516 = pairs
	v155 = script.Parent
	v517 = v155.Parent
	local v522, v523, v155 = v516(v517:GetDescendants())
	for v317, v132 in v522, v523, v155 do
		v521 = "CD"
		local v524 = v132:FindFirstChild(v521)
		if not v524 then
			v140 = v132.Parent
			v524 = v140.Name
			if v524 == "Clipping" then
				v524 = pairs
				v145 = game
				v144 = v145.Players
				v143 = v144.LocalPlayer
				v142 = v143.PlayerGui
				local v525 = v142.GameGui
				v140 = v525.Control
				local v526, v527, v525 = v524(v140:GetDescendants())
				for v142, v143 in v526, v527, v525 do
					v145 = v143.Parent
					v144 = v145.Name
					if v144 == "Cooldowns" then
						v146 = "Delay"
						local v528 = v143:FindFirstChild(v146)
						if not v528 then
							v528 = v143.Name
							v145 = v132.Name
							if v528 == v145 then
								v528 = v143.Name
								if v528 == "Rage" then
									v145 = v143.Delay
									v528 = v145.Changed
									v528:Connect(function()
										local v530 = v143
										local v532 = v530.Delay.Value
										if v532 == true then
											v532 = false
											local function F_1()
												local v535 = {}
												v535[1] = ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 55, 55))
												v535[2] = ColorSequenceKeypoint.new(0.001, v32)
												v535[3] = ColorSequenceKeypoint.new(1, v32)
												v132.BarGrad.Color = ColorSequence.new(v535)
											end
											v530 = v143
											local v554 = v530:FindFirstChild("Owner")
											while v554 == nil do
												while true do
													v554 = wait
													v554()
													F_1()
													if game.Players.LocalPlayer.PlayerGui.GameGui.Control.Values.Actions.DoingSomething.Value == false then
														break
													end
												end
												v565 = wait
												v565()
												F_1()
												v562 = v143
												v563 = v562.Owner
												v564 = v563.Value
												if v564.Value == false then
													break
												end
											end
											if v532 == false then
												v532 = true
												v567 = TweenSP
												v564 = v132
												v562 = v143
												v563 = v562.Value
												v567(v564, v563)
											end
										end
									end)
								end
							end
						end
					end
				end
			end
		end
	end
	v522 = pairs
	v155 = script.Parent
	v523 = v155.Parent
	local v568, v569, v155 = v522(v523:GetDescendants())
	for v317, v132 in v568, v569, v155 do
		v525 = "Clipping"
		local v570 = v132:FindFirstChild(v525)
		if not v570 then
			v527 = v132.Parent
			v570 = v527.Name
			if v570 == "Clipping" then
				v570 = pairs
				v145 = game
				local v571 = v145.Players
				v143 = v571.LocalPlayer
				v142 = v143.PlayerGui
				local v572 = v142.GameGui
				v527 = v572.Control
				local v573, v574, v572 = v570(v527:GetDescendants())
				for v142, v143 in v573, v574, v572 do
					v145 = v143.Parent
					v571 = v145.Name
					if v571 == "Cooldowns" then
						local v576 = v143:FindFirstChild("Delay")
						if not v576 then
							v576 = v143.Name
							v145 = v132.Name
							if v576 == v145 then
								v145 = v143.Delay
								v576 = v145.Changed
								v576:Connect(function()
									local v578 = v143
									local v579 = v578.Delay
									local v580 = v579.Value
									if v580 == true then
										v580 = false
										v578 = v132
										v579 = v578.Name
										if v579 == "Rage" then
											v578 = v132.Clipping
											v579 = v578.Clipping
											v578 = UDim2.new
											v579.Size = v578(1, 0, -0.01, 0)
											v579 = v132.Clipping.Clipping
											v579.Size = UDim2.new(1, 0, 0, 0)
										end
										v579 = v143
										local v592 = v579:FindFirstChild("Owner")
										while v592 == nil do
											while true do
												v592 = wait
												v592()
												v590 = game.Players.LocalPlayer.PlayerGui.GameGui.Control.Values.Actions.DoingSomething
												if v590.Value == false then
													break
												end
											end
											v601 = wait
											v601()
											v599 = v143
											v600 = v599.Owner
											v590 = v600.Value
											if v590.Value == false then
												break
											end
										end
										if v580 == false then
											v580 = true
											v602 = TweenBar
											v590 = 1
											v598 = v132
											v599 = v598.Clipping
											v600 = v599.Clipping
											v596 = v132
											v597 = v596.Clipping
											v598 = v597.Clipping
											v599 = v598.Top
											v597 = v143
											v598 = v597.Value
											v596 = v143
											v597 = v596.Value
											v602(v590, v600, v599, v598, v597)
										end
									end
								end)
							end
						end
					end
				end
			end
		end
	end
	v155 = v13.Info
	v569 = v155.Rage
	v568 = v569.Changed
	v155 = function()
		local v610 = v13.Info.Rage.Value
		local v611 = v13
		local v612 = v611.Info
		local v646 = v612.Rage
		local v647 = v646.MaxRage
		local v648 = v647.Value
		if v648 > v610 then
			local v613 = script
			local v614 = v613.Parent
			local v615 = v614.Parent
			v611 = v615.AttacksRage
			v612 = v611.Rage
			v646 = v612.Clipping
			v647 = v646.Clipping
			v648 = v647.Top
			v610 = v648.ImageColor3
			v648 = Color3.fromRGB
			v647 = 255
			v646 = 255
			v612 = 255
			if v610 ~= v648(v647, v646, v612) then
				v610 = v20
				v613 = script.Parent
				v614 = v613.Parent
				v615 = v614.AttacksRage
				v611 = v615.Rage
				local v622 = {}
				v611 = Color3.fromRGB
				v615 = 255
				v614 = 255
				v613 = 255
				v622.ImageColor3 = v611(v615, v614, v613)
				(v610:Create(v611.Clipping.Clipping.Top, TweenInfo.new(0.05), v622)):Play()
			end
		end
		v624 = v13.Info.Rage.Value
		v623 = v13
		local v628 = v623.Info
		local v651 = v628.Rage
		local v652 = v651.MaxRage
		local v653 = v652.Value
		if v624 >= v653 then
			local v629 = script
			local v630 = v629.Parent
			local v631 = v630.Parent
			v623 = v631.AttacksRage
			v628 = v623.Rage
			v651 = v628.Clipping
			v652 = v651.Clipping
			v653 = v652.Top
			v624 = v653.ImageColor3
			v653 = Color3.fromRGB
			v652 = 255
			v651 = 255
			v628 = 255
			if v624 == v653(v652, v651, v628) then
				v624 = v20
				v617 = script
				v629 = v617.Parent
				v630 = v629.Parent
				v631 = v630.AttacksRage
				v623 = v631.Rage
				local v637 = {}
				v630 = v6
				v631 = v630.TeamBrick
				v623 = v631.Color
				v637.ImageColor3 = v623
				(v624:Create(v623.Clipping.Clipping.Top, TweenInfo.new(0.2), v637)):Play()
				v630 = script
				v631 = v630.Parent
				v623 = v631.Parent
				FlashGif_1(v623.AttacksRage.Rage.Flash, 0.065)
				v630 = script
				v631 = v630.Parent
				v623 = v631.Parent
				FireGif_1(v623.AttacksRage.Rage.Ready, 0.03)
			end
		end
	end
	v568:Connect(v155)
	-- Combo system moved to ComboTracker LocalScript in StarterPlayerScripts
	v132 = script
	v569 = v132.Parent.Parent.Feed
	v569.ChildAdded:Connect(function(p17)
		local v756 = p17.PlayerName.Text
		local v757 = game
		local v758 = v757.Players
		local v759 = v758.LocalPlayer
		local v852 = v759.Name
		if v756 == v852 then
			v756 = p17.PlayerName
			v852 = Color3.fromRGB
			v759 = 0
			v758 = 255
			v757 = 0
			v756.TextColor3 = v852(v759, v758, v757)
		end
		v760 = p17.AttackerName
		local v853 = v760.Text
		local v761 = game
		local v762 = v761.Players
		local v763 = v762.LocalPlayer
		v760 = v763.Name
		if v853 == v760 then
			v853 = p17.AttackerName
			v760 = Color3.fromRGB
			v763 = 0
			v762 = 255
			v761 = 0
			v853.TextColor3 = v760(v763, v762, v761)
		end
		local v765 = game
		v764 = v765.Players
		local v766, v767, v765 = pairs(v764:GetPlayers())
		for v777, v769 in v766, v767, v765 do
			local v770 = p17.AttackerName
			local v771 = v770.Text
			if v769.Name == v771 then
				v770 = "PlayerTeam"
				local v772 = v769:FindFirstChild(v770)
				if not v772 then
					v772 = p17.AttackerName
					v771 = v769.Character.TeamBrick.Color
					v772.TextColor3 = v771
				end
			end
			v772 = v769.Name
			v774 = p17.PlayerName
			local v855 = v774.Text
			if v772 == v855 then
				v774 = "PlayerTeam"
				local v775 = v769:FindFirstChild(v774)
				if not v775 then
					v775 = p17.PlayerName
					v773 = v769.Character
					v855 = v773.TeamBrick.Color
					v775.TextColor3 = v855
				end
			end
		end
		v766 = wait
		v767 = 0.08
		v766(v767)
		if not p17 then
			v771 = script
			v775 = v771.Parent
			v769 = v775.Parent
			v777 = v769.Feed
			v765 = v777.Spots
			p17.Position = v765.Feed1.Position
			v769 = script
			v777 = v769.Parent
			v765 = v777.Parent
			local v780, v781, v765 = pairs(v765.Feed:GetChildren())
			for v777, v769 in v780, v781, v765 do
				if v769 ~= p17 then
					v776 = "Frame"
					local v782 = v769:IsA(v776)
					if not v782 then
						v782 = v769.Changed
						v782:Connect(function()
							wait(0.095)
							local v786 = p17
							if not v786 then
								v786 = v769
								if not v786 then
									v786 = v769.Position
									local v788 = p17
									local v798 = v788.Position
									if v786 == v798 then
										v786 = p17
										v798 = UDim2.new
										v788 = 0.856
										v786.Position = v798(v788, 0, p17.Position.Y.Scale + 0.066, 0)
									end
								end
							end
							local v800 = p17
							if not v800 then
								v800 = v769
								if not v800 then
									v795 = p17.Position.Y
									v800 = v795.Scale
									v795 = 0.335
									if v800 > v795 then
										v800 = p17
										v800:Destroy()
									end
								end
							end
						end)
					end
				end
			end
			v769 = script
			v777 = v769.Parent
			v765 = v777.Parent
			v781 = v765.Feed
			v780 = v781.ChildAdded
			v765 = function()
				wait(0.095)
				local v804 = script
				local v806 = v804.Parent.Parent
				local v808, v809, v806 = pairs(v806.Feed:GetChildren())
				for v805, v804 in v808, v809, v806 do
					if v804 ~= p17 then
						local v812 = v804:IsA("Frame")
						if not v812 then
							v812 = p17
							if not v812 then
								if not v804 then
									v812 = v804.Position
									local v813 = p17
									local v814 = v813.Position
									if v812 == v814 then
										v812 = p17
										v814 = UDim2.new
										v813 = 0.856
										v812.Position = v814(v813, 0, p17.Position.Y.Scale + 0.066, 0)
									end
								end
							end
							v812 = p17
							if not v812 then
								if not v804 then
									v821 = p17.Position.Y
									v812 = v821.Scale
									v821 = 0.335
									if v812 > v821 then
										v812 = p17
										v812:Destroy()
									end
								end
							end
						end
					end
				end
			end
			v780:Connect(v765)
			v781 = 3
			wait(v781)
			if not p17 then
				local v828, v829, v830 = pairs(p17:GetDescendants())
				for v777, v769 in v828, v829, v830 do
					local v833 = v769:IsA("TextLabel")
					if not v833 then
						v833 = v20
						v773 = TweenInfo.new
						local v837 = {}
						v837.TextTransparency = 1
						(v833:Create(v769, v773(1.22), v837)):Play()
					end
					local v841 = v769:IsA("ImageLabel")
					if not v841 then
						v841 = v20
						local v846 = {}
						v838 = 1
						v846.ImageTransparency = v838
						local v847 = v841:Create(v769, TweenInfo.new(1.25), v846)
						v847:Play()
						v847.Completed:Connect(function()
							local v851 = p17
							if not v851 then
								v851 = p17
								v851:Destroy()
							end
						end)
					end
				end
			end
		end
	end)
	return 
end
