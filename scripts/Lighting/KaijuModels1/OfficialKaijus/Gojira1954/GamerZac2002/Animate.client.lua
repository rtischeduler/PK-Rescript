-- Saved by UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw

--SynapseX Decompiler
-- USED GLOBALS: script.
1.	
2.	local v1 = script
4.	local v0 = v1.Parent
6.	local v2 = script
8.	v1 = v2.Parent
10.	local v3 = "Humanoid"
11.	
13.	v1 = v1:WaitForChild(v3)
14.	local v4 = "Animations"
15.	
17.	v2 = v0:WaitForChild(v4)
18.	local v5 = "Running"
19.	local v6 = false
20.	
22.	v0:SetAttribute(v5, v6)
23.	v5 = "Swimming"
24.	v6 = false
25.	
27.	v0:SetAttribute(v5, v6)
28.	local v7 = "Idle"
29.	
31.	v4 = v2:WaitForChild(v7)
32.	
34.	v3 = v1:LoadAnimation()
35.	v4 = Enum.AnimationPriority.Core
37.	v3.Priority = v4
39.	v6 = 0
40.	
42.	v3:Play(v6)
43.	local v8 = "Walk"
44.	
46.	v5 = v2:WaitForChild(v8)
47.	
49.	v4 = v1:LoadAnimation()
50.	v5 = Enum.AnimationPriority.Movement
52.	v4.Priority = v5
54.	v5 = v1.Changed
56.	-- V nested upvalues[0] = v1
-- V nested upvalues[1] = v4
-- V nested upvalues[2] = v0
[DUPCLOSURE] v7 = function() -- [line 8]
	1.	local v2 = v1 -- get upval
	2.	local v1 = v2.MoveDirection
	4.	v2 = Vector3.new(0, 0, 0)
	5.	if v1 == v2 then goto #23
	7.	v2 = v4 -- get upval
	8.	v1 = v2.IsPlaying
	10.	if v1 == true then goto #23
	12.	v1 = v0 -- get upval
	13.	local v3 = "Swimming"
	14.	
	16.	v1 = v1:GetAttribute(v3)
	17.	if v1 == false then goto #23
	19.	v1 = v4 -- get upval
	20.	v3 = 0.3
	21.	
	23.	v1:Stop(v3) -- referenced by #5, #10, #17
					end
					end
					end
	24.	v2 = v1 -- get upval
	25.	v1 = v2.MoveDirection
	27.	v2 = Vector3.new(0, 0, 0)
	28.	if v1 ~= v2 then goto #56
	30.	v2 = v4 -- get upval
	31.	v1 = v2.IsPlaying
	33.	if v1 == false then goto #56
	35.	v1 = v0 -- get upval
	36.	v3 = "Swimming"
	37.	
	39.	v1 = v1:GetAttribute(v3)
	40.	if v1 == false then goto #56
	42.	v1 = v0 -- get upval
	43.	v3 = "Running"
	44.	
	46.	v1 = v1:GetAttribute(v3)
	47.	if v1 == false then goto #56
	49.	v1 = v4 -- get upval
	50.	v3 = 0.3
	51.	local v4 = 1
	52.	local v5 = 0.7
	53.	
	55.	v1:Play(v3, v4, v5)
	56.	return -- referenced by #28, #33, #40, #47
					end
					end
					end
					end
	57.	v2 = v1 -- get upval
	58.	v1 = v2.MoveDirection
	60.	v2 = Vector3.new(0, 0, 0)
	61.	if v1 ~= v2 then goto #86
	63.	v2 = v4 -- get upval
	64.	v1 = v2.IsPlaying
	66.	if v1 == true then goto #86
	68.	v1 = v0 -- get upval
	69.	v3 = "Swimming"
	70.	
	72.	v1 = v1:GetAttribute(v3)
	73.	if v1 == false then goto #86
	75.	v1 = v0 -- get upval
	76.	v3 = "Running"
	77.	
	79.	v1 = v1:GetAttribute(v3)
	80.	if v1 == true then goto #86
	82.	v1 = v4 -- get upval
	83.	v3 = 0.3
	84.	
	86.	v1:Stop(v3) -- referenced by #61, #66, #73, #80
					end
					end
					end
					end
	87.	return
end

57.	CAPTURE VAL R1

58.	CAPTURE VAL R4

59.	CAPTURE VAL R0

60.	
62.	v38:Connect(v40)
63.	return
