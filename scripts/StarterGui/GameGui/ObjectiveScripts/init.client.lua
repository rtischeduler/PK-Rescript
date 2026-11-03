local v4 = game.Players.LocalPlayer.Character
local v6 = game.Players.LocalPlayer.PlayerGui:WaitForChild("GameGui")
v4:WaitForChild("Aspects")
script:WaitForChild("EventObjective")
local v11 = game.Players
local v13 = v11.LocalPlayer.Inventory
local v15, v16, v13 = pairs(v13.Rewards:GetChildren())
for v12, v11 in v15, v16, v13 do
	local v18 = v11:GetAttribute("OneLife")
	if v18 == true then
		v18 = v11:FindFirstChildOfClass("NumberValue").Value
		local v23 = v11:GetAttribute("Max")
		if v18 ~= v23 then
			v23 = script
			v18 = v23.EventObjective
			v18:FireServer(v11, v11:FindFirstChildOfClass("NumberValue"), 0)
		end
	end
end
v15 = v4.ChildAdded
v13 = function(p1)
	local v31 = p1:FindFirstChild("EmoteName")
	if not v31 then
		v31 = pairs
		local v33 = game.Players
		local v35 = v33.LocalPlayer.Inventory
		local v37, v38, v35 = v31(v35.Rewards:GetChildren())
		for v34, v33 in v37, v38, v35 do
			local v40 = v33:FindFirstChild("ObjectiveName")
			if not v40 then
				v40 = v33.BasicObjective.Text
				local v42 = p1.EmoteName
				local v51 = v42.Value
				if v40 == v51 then
					v51 = script
					v40 = v51.EventObjective
					v42 = v33
					v40:FireServer(v42, v33:FindFirstChildOfClass("NumberValue"), v33:FindFirstChildOfClass("NumberValue").Value + 1)
				end
			end
		end
	end
end
v15:Connect(v13)
local function HitCounter_1(p2)
	local v54 = game
	local v55 = v54.Players
	local v56 = v55.LocalPlayer
	local v57 = v56.Inventory
	local v58 = v57.Rewards
	local v59 = v58.Owned
	local v60 = v59.Value
	if v60 == true then
		v60 = pairs
		v55 = game
		v56 = v55.Players
		v57 = v56.LocalPlayer
		v58 = v57.Inventory
		v59 = v58.Rewards
		local v61, v62, v58 = v60(v59:GetChildren())
		for v57, v56 in v61, v62, v58 do
			local v64 = v56:FindFirstChild("ObjectiveName")
			if not v64 then
				v54 = v56.BasicObjective
				v64 = v54.Text
				if v64 == p2 then
					v54 = script
					v64 = v54.EventObjective
					v64:FireServer(v56, v56:FindFirstChildOfClass("NumberValue"), v56:FindFirstChildOfClass("NumberValue").Value + 1)
				end
			end
		end
	end
end
v16 = v6.ChildAdded
v16:Connect(function(p3)
	local v74 = p3.Name
	if v74 == "MeleeClash" then
		v74 = HitCounter_1
		v74("Melee Clash")
	end
	local v76 = p3.Name
	if v76 == "BeamClash" then
		v76 = HitCounter_1
		v76("Beam Clash")
	end
end)
v4.Aspects.Info.Stamina.Changed:Connect(function()
	local v84 = v4.Aspects.Defense.Blocking
	local v85 = v84.Value
	if v85 == true then
		v85 = HitCounter_1
		v84 = "Block"
		v85(v84)
	end
end)
v4.Aspects.Info.Health.Changed:Connect(function()
	local v90 = v4.Head.Roar
	local v91 = v90.IsPlaying
	if v91 == true then
		v91 = HitCounter_1
		v90 = "RoarStun"
		v91(v90)
	end
end)
v6.Character.ComboHolder.ComboAmount.Changed:Connect(function()
	local v98 = v6.Character.ComboHolder.ComboAmount.Value
	local v99 = 0
	if v98 > v99 then
		v98 = HitCounter_1
		v99 = "Hits"
		v98(v99)
	end
end)
v4.Aspects.Info.Health.Changed:Connect(function()
	local v105 = v4.Aspects.Defense.Roaring
	local v106 = v105.Value
	if v106 == true then
		v106 = HitCounter_1
		v105 = "RoarStun"
		v106(v105)
	end
end)
v4.Aspects.Info.GrabbedSomething.Changed:Connect(function()
	local v112 = v4.Aspects.Info.GrabbedSomething
	local v113 = v112.Value
	if v113 == true then
		v113 = HitCounter_1
		v112 = "Grab"
		v113(v112)
	end
end)
