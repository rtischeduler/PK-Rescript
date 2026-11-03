-- Saved by UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw

-- 𝓓𝓮𝓬𝓸𝓶𝓹𝓲𝓵𝓮𝓭 𝓫𝔂 𝓯𝓻𝓮𝓪𝓴𝔂 𝓭𝓮𝓬𝓸𝓶𝓹𝓲𝓵𝓮𝓻
-- USED GLOBALS: script.
1.	
2.	local v2 = game
4.	local v1 = v2.Players
6.	local v0 = v1.LocalPlayer
8.	v2 = script
10.	v1 = v2.Parent
12.	local v4 = "Humanoid"
13.	
15.	v2 = v1:WaitForChild(v4)
16.	local v3 = v0.PlayerGui
18.	local v5 = "Skillset"
19.	
21.	v3 = v3:WaitForChild(v5)
22.	v5 = script
24.	v4 = v5.Combat
26.	local v6 = script
28.	v5 = v6.Energy
30.	local v7 = script
32.	v6 = v7.Misc
34.	v7 = game
36.	local v9 = "UserInputService"
37.	
39.	v7 = v7:GetService(v9)
40.	local v8 = game
42.	local v10 = "TweenService"
43.	
45.	v8 = v8:GetService(v10)
46.	v9 = require
48.	local v11 = script
50.	v10 = v11.Stats
52.	v9 = v9(v10)
53.	local v12 = "CharacterAssets"
54.	
56.	v10 = v1:WaitForChild(v12)
57.	local v13 = "ScriptManagement"
58.	
60.	v11 = v10:WaitForChild(v13)
61.	local v14 = game
63.	v13 = v14.Workspace
65.	v12 = v13.CurrentCamera
67.	v13 = 80
68.	v12.FieldOfView = v13
70.	v13 = v11.Energy1
72.	v14 = v11.Energy2
74.	local v15 = v11.Energy3
76.	local v16 = {"walk", "idle", "roar", "lcs", "skill1", "special"}
77.	local v24 = "CharacterAssets"
78.	
80.	v22 = v1:WaitForChild(v24)
81.	local v21 = v22.Animations
83.	local v20 = v21.Movement
85.	local v19 = v20.Walk
87.	
89.	v17 = v2:LoadAnimation(v19)
90.	v16.walk = v17
92.	v24 = "CharacterAssets"
93.	
95.	v22 = v1:WaitForChild(v24)
96.	v21 = v22.Animations
98.	v20 = v21.Movement
100.	v19 = v20.Idle
102.	
104.	v17 = v2:LoadAnimation(v19)
105.	v16.idle = v17
107.	v24 = "CharacterAssets"
108.	
110.	v22 = v1:WaitForChild(v24)
111.	v21 = v22.Animations
113.	v20 = v21.Actions
115.	v19 = v20.Roar
117.	
119.	v17 = v2:LoadAnimation(v19)
120.	v16.roar = v17
122.	local v17 = {"lc1", "lc2", "lc3"}
123.	local v26 = "CharacterAssets"
124.	
126.	v24 = v1:WaitForChild(v26)
127.	local v23 = v24.Animations
129.	local v22 = v23.Actions
131.	v21 = v22.LCs
133.	v20 = v21.LC1
135.	
137.	v18 = v2:LoadAnimation(v20)
138.	v17.lc1 = v18
140.	v26 = "CharacterAssets"
141.	
143.	v24 = v1:WaitForChild(v26)
144.	v23 = v24.Animations
146.	v22 = v23.Actions
148.	v21 = v22.LCs
150.	v20 = v21.LC2
152.	
154.	v18 = v2:LoadAnimation(v20)
155.	v17.lc2 = v18
157.	v26 = "CharacterAssets"
158.	
160.	v24 = v1:WaitForChild(v26)
161.	v23 = v24.Animations
163.	v22 = v23.Actions
165.	v21 = v22.LCs
167.	v20 = v21.LC3
169.	
171.	v18 = v2:LoadAnimation(v20)
172.	v17.lc3 = v18
174.	v16.lcs = v17
176.	v24 = "CharacterAssets"
177.	
179.	v22 = v1:WaitForChild(v24)
180.	v21 = v22.Animations
182.	v20 = v21.Actions
184.	v19 = v20.Skill1
186.	
188.	v17 = v2:LoadAnimation(v19)
189.	v16.skill1 = v17
191.	v24 = "CharacterAssets"
192.	
194.	v22 = v1:WaitForChild(v24)
195.	v21 = v22.Animations
197.	v20 = v21.Actions
199.	v19 = v20.Special
201.	
203.	v17 = v2:LoadAnimation(v19)
204.	v16.special = v17
206.	v17 = v16.walk
208.	local v18 = v16.idle
210.	v19 = v1.HumanoidRootPart
212.	
214.	v19 = v19:GetDescendants()
215.	v20 = pairs
217.	v21 = v19
218.	v20, v21, v22 = v20(v21)
219.	for v23, v24 in v20(v21) do -- [escape at #228] (pairs/next)
220.	local v27 = "Sound"
221.	
223.	v25 = v24:IsA(v27)
224.	if v25 then goto #227
225.	
227.	v24:Destroy() -- referenced by #224
				end
228.	end -- FORGLOOP - iterate + goto #219
230.	v20 = v2.Running
232.	-- V nested upvalues[0] = v18
-- V nested upvalues[1] = v17
[DUPCLOSURE] v22 = function(p1) -- [line 38]
	1.	if p1 == 0 then goto #13
	3.	local v1 = v18 -- get upval
	4.	local v3 = 0.5
	5.	
	7.	v1:Play(v3)
	8.	v1 = v17 -- get upval
	9.	v3 = 0.5
	10.	
	12.	v1:Stop(v3)
	13.	return -- referenced by #1
					end
	14.	local v2 = v17 -- get upval
	15.	v1 = v2.IsPlaying
	17.	if v1 == false then goto #23
	19.	v1 = v17 -- get upval
	20.	v3 = 0.5
	21.	
	23.	v1:Play(v3) -- referenced by #17
					end
	24.	v1 = v17 -- get upval
	25.	v3 = 0.5
	26.	
	28.	v1:Play(v3)
	29.	v1 = v18 -- get upval
	30.	v3 = 0.5
	31.	
	33.	v1:Stop(v3)
	34.	return
end

233.	CAPTURE VAL R18

234.	CAPTURE VAL R17

235.	
237.	v32:Connect(v34)
238.	v34 = "RightFoot"
239.	
241.	v32 = v29:GetMarkerReachedSignal(v34)
242.	-- V nested upvalues[0] = v18
[DUPCLOSURE] v34 = function() -- [line 50]
	1.	local v13 = v18 -- get upval
	2.	local v15 = "RightFoot"
	3.	
	5.	v13:FireServer(v15)
	6.	return
end

243.	CAPTURE VAL R6

244.	
246.	v34:Connect(v36)
247.	v36 = "LeftFoot"
248.	
250.	v34 = v31:GetMarkerReachedSignal(v36)
251.	-- V nested upvalues[0] = v20
[DUPCLOSURE] v36 = function() -- [line 53]
	1.	local v15 = v20 -- get upval
	2.	local v17 = "LeftFoot"
	3.	
	5.	v15:FireServer(v17)
	6.	return
end

252.	CAPTURE VAL R6

253.	
255.	v36:Connect(v38)
256.	local function CooldownTween(p2, p3) -- [line 57]
	1.	local v17 = p2.Visible
	3.	if v17 == false then goto #7
	5.	v17 = true
	6.	p2.Visible = v17
					end
	8.	v17 = UDim2.new
	10.	local v18 = 1
	11.	local v19 = 0
	12.	local v20 = 1
	13.	local v21 = 0
	14.	v17 = v17(v18, v19, v20, v21)
	15.	p2.Size = v17
	17.	v19 = UDim2.new
	19.	v20 = 1
	20.	v21 = 0
	21.	local v22 = 0
	22.	local v23 = 0
	23.	v19 = v19(v20, v21, v22, v23)
	24.	v20 = Enum.EasingDirection.Out
	26.	v21 = Enum.EasingStyle.Sine
	28.	v22 = p3
	29.	v23 = false
	30.	
	32.	p2:TweenSize(v19, v20, v21, v22, v23)
	33.	v17 = task.wait
	35.	v18 = p3
	36.	v17(v18)
	37.	v17 = false
	38.	p2.Visible = v17
	40.	return
end
[DUPCLOSURE] v36 = CooldownTween
257.	-- V nested upvalues[0] = v43
-- V nested upvalues[1] = v47
local function FovTween(p4, p5, p6, p7) -- [line 67]
	1.	local v36 = v43 -- get upval
	2.	local v38 = v47 -- get upval
	3.	local v39 = TweenInfo.new
	5.	local v40 = p5
	6.	local v41 = Enum.EasingStyle.Sine
	8.	local v42 = Enum.EasingDirection.Out
	10.	local v43 = 0
	11.	local v44 = false
	12.	local v45 = 0
	13.	v39 = v39(v40, v41, v42, v43, v44, v45)
	14.	v40 = {"FieldOfView"}
	15.	v40.FieldOfView = p4
	17.	
	19.	v36 = v36:Create(v38, v39, v40)
	20.	
	22.	v36:Play()
	23.	v36 = task.wait
	25.	local v37 = p6
	26.	v36(v37)
	27.	v36 = v43 -- get upval
	28.	v38 = v47 -- get upval
	29.	v39 = TweenInfo.new
	31.	v40 = p7
	32.	v41 = Enum.EasingStyle.Sine
	34.	v42 = Enum.EasingDirection.Out
	36.	v43 = 0
	37.	v44 = false
	38.	v45 = 0
	39.	v39 = v39(v40, v41, v42, v43, v44, v45)
	40.	v40 = {"FieldOfView"}
	41.	v41 = 80
	42.	v40.FieldOfView = v41
	44.	
	46.	v36 = v36:Create(v38, v39, v40)
	47.	
	49.	v36:Play()
	50.	return
end
[DUPCLOSURE] v56 = FovTween
258.	CAPTURE VAL R8

259.	CAPTURE VAL R12

260.	v80 = false
261.	v81 = false
262.	-- V nested upvalues[0] = v16
-- V nested upvalues[1] = v22
-- V nested upvalues[2] = v23
-- V nested upvalues[3] = v17
-- V nested upvalues[4] = v2
-- V nested upvalues[5] = v4
-- V nested upvalues[6] = v20
-- V nested upvalues[7] = v3
-- V nested upvalues[8] = v9
local function Roar() -- [line 77]
	1.	local v60 = v16 -- get upval
	2.	local v59 = v60.roar
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v60 = v22 -- get upval
	5.	if v60 == false then goto #46
	7.	v60 = v23 -- get upval
	8.	if v60 == false then goto #46
	10.	local v61 = v17 -- get upval
	11.	v60 = v61.IsPlaying
	13.	if v60 then goto #18
	14.	v60 = v17 -- get upval
	15.	local v62 = 0.6
	16.	
	18.	v60:Stop(v62) -- referenced by #13
					end
	19.	v60 = v2 -- get upval
	20.	v61 = 0
	21.	v60.WalkSpeed = v61
	23.	v62 = 0.3
	24.	
	26.	v59:Play(v62)
	27.	v60 = true
	28.	v22 = v60 -- set upval
	29.	v60 = v4 -- get upval
	30.	v62 = "Roar"
	31.	local v63 = "Sound"
	32.	
	34.	v60:FireServer(v62, v63)
	35.	v60 = v59.Stopped
	37.		-- V nested upvalues[0] = upvalues[4]
	-- V nested upvalues[1] = upvalues[1]
	-- V nested upvalues[2] = upvalues[2]
	-- V nested upvalues[3] = upvalues[6]
	-- V nested upvalues[4] = upvalues[7]
	-- V nested upvalues[5] = upvalues[8]
	[NEWCLOSURE] v62 = function() -- [line 88]
		1.	local v60 = upvalues[4] -- get upval
		2.	local v61 = 6
		3.	v60.WalkSpeed = v61
		5.	v60 = false
		6.	upvalues[1] = v60 -- set upval
		7.	v60 = true
		8.	upvalues[2] = v60 -- set upval
		9.	v60 = upvalues[6] -- get upval
		10.	local v62 = upvalues[7] -- get upval
		11.	local v64 = "Roar"
		12.	
		14.	v62 = v62:WaitForChild(v64)
		15.	v61 = v62.CDframe
		17.	v64 = upvalues[8] -- get upval
		18.	local v63 = v64.Cooldowns
		20.	v62 = v63.Roar
		22.	v60(v61, v62)
		23.	v60 = false
		24.	upvalues[2] = v60 -- set upval
		25.	return
	end

	38.	CAPTURE UPVAL U4

	39.	CAPTURE UPVAL U1

	40.	CAPTURE UPVAL U2

	41.	CAPTURE UPVAL U6

	42.	CAPTURE UPVAL U7

	43.	CAPTURE UPVAL U8

	44.	
	46.	v72:Connect(v74) -- referenced by #5, #8
					end
					end
	47.	return
end
[NEWCLOSURE] v94 = Roar
263.	CAPTURE VAL R16

264.	CAPTURE REF R22

265.	CAPTURE REF R23

266.	CAPTURE VAL R17

267.	CAPTURE VAL R2

268.	CAPTURE VAL R4

269.	CAPTURE VAL R20

270.	CAPTURE VAL R3

271.	CAPTURE VAL R9

272.	local v111 = v102.roar
274.	v113 = "Roar"
275.	
277.	v111 = v111:GetMarkerReachedSignal(v113)
278.	-- V nested upvalues[0] = v90
[DUPCLOSURE] v113 = function() -- [line 97]
	1.	local v87 = v90 -- get upval
	2.	local v89 = "Roar"
	3.	local v90 = "Particle"
	4.	
	6.	v87:FireServer(v89, v90)
	7.	return
end

279.	CAPTURE VAL R4

280.	
282.	v114:Connect(v116)
283.	v114 = v105.roar
285.	v116 = "Armor"
286.	
288.	v114 = v114:GetMarkerReachedSignal(v116)
289.	-- V nested upvalues[0] = v93
-- V nested upvalues[1] = v105
-- V nested upvalues[2] = v110
[DUPCLOSURE] v116 = function() -- [line 100]
	1.	local v90 = v93 -- get upval
	2.	local v92 = "Armor"
	3.	local v95 = v105 -- get upval
	4.	local v94 = v95.roar
	6.	local v93 = v94.Length
	8.	
	10.	v90:FireServer(v92, v93)
	11.	v90 = v110 -- get upval
	12.	local v91 = 45
	13.	v92 = 0.25
	14.	v93 = 0.24
	15.	v94 = 3.8
	16.	v90(v91, v92, v93, v94)
	17.	return
end

290.	CAPTURE VAL R4

291.	CAPTURE VAL R16

292.	CAPTURE VAL R21

293.	
295.	v124:Connect(v126)
296.	v124 = v115.roar
298.	v126 = "LeftFoot"
299.	
301.	v124 = v124:GetMarkerReachedSignal(v126)
302.	-- V nested upvalues[0] = v105
[DUPCLOSURE] v126 = function() -- [line 104]
	1.	local v100 = v105 -- get upval
	2.	local v102 = "LeftFoot"
	3.	
	5.	v100:FireServer(v102)
	6.	return
end

303.	CAPTURE VAL R6

304.	
306.	v126:Connect(v128)
307.	v126 = 0
308.	-- V nested upvalues[0] = v22
-- V nested upvalues[1] = v25
local function SetLC() -- [line 112]
	1.	local v102 = v22 -- get upval
	2.	if not v102 then goto #3
	3.	goto #4 -- referenced by #2
					else
	4.	return -- referenced by #3
					end
	5.	v102 = v25 -- get upval
	6.	local v103 = 3
	7.	if v103 > v102 then goto #12
	9.	v102 = v25 -- get upval
	10.	v102 = v102 + 1
	11.	v25 = v102 -- set upval
	12.	return -- referenced by #7
					end
	13.	v102 = 0
	14.	v25 = v102 -- set upval
	15.	return
end
[NEWCLOSURE] v127 = SetLC
309.	CAPTURE REF R22

310.	CAPTURE REF R25

311.	-- V nested upvalues[0] = v16
-- V nested upvalues[1] = v25
local function LCreset(p8, p9) -- [line 121]
	1.	local v108 = task.delay
	3.	local v109 = 0.5
	4.		-- V nested upvalues[0] = upvalues[0]
	-- V nested upvalues[1] = p9
	-- V nested upvalues[2] = upvalues[1]
	[NEWCLOSURE] v110 = function() -- [line 122]
		1.	local v110 = upvalues[0] -- get upval
		2.	local v109 = v110.lcs
		-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v110 = p9 -- get upval
		5.	local v111 = upvalues[1] -- get upval
		6.	if v111 > v110 then goto #25
		8.	v111 = v109.lc1
		10.	v110 = v111.IsPlaying
		12.	if v110 then goto #13
		13.	return -- referenced by #12
						end
		14.	v111 = v109.lc2
		16.	v110 = v111.IsPlaying
		18.	if v110 then goto #19
		19.	return -- referenced by #18
						end
		20.	v111 = v109.lc3
		22.	v110 = v111.IsPlaying
		24.	if v110 then goto #25
		25.	return -- referenced by #6, #24
						end
						end
		26.	v110 = 0
		27.	upvalues[1] = v110 -- set upval
		28.	return
	end

	5.	CAPTURE UPVAL U0

	6.	CAPTURE VAL R1

	7.	CAPTURE UPVAL U1

	8.	v119(v120, v121)
	9.	return
end
[NEWCLOSURE] v145 = LCreset
312.	CAPTURE VAL R16

313.	CAPTURE REF R25

314.	-- V nested upvalues[0] = v16
-- V nested upvalues[1] = v22
-- V nested upvalues[2] = v25
-- V nested upvalues[3] = v18
-- V nested upvalues[4] = v17
-- V nested upvalues[5] = v2
local function Combo() -- [line 151]
	1.	local v122 = v16 -- get upval
	2.	local v121 = v122.lcs
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v122 = v22 -- get upval
	5.	if not v122 then goto #17
	6.	goto #7
	7.	goto #17 -- referenced by #6
					else
	8.	v122 = v25 -- get upval
	9.	local v123 = 3
	10.	if v123 > v122 then goto #15
	12.	v122 = v25 -- get upval
	13.	v122 = v122 + 1
	14.	v25 = v122 -- set upval
	15.	goto #17 -- referenced by #10
					else
	16.	v122 = 0
	17.	v25 = v122 -- set upval -- referenced by #5, #7, #15
					end
					end
					end
	18.	v122 = v25 -- get upval
	19.	if v122 == 1 then goto #49
	21.	v122 = v22 -- get upval
	22.	if v122 == false then goto #134
	24.	v123 = v18 -- get upval
	25.	v122 = v123.IsPlaying
	27.	if not v122 then goto #31
	28.	v123 = v17 -- get upval
	29.	v122 = v123.IsPlaying
	31.	if v122 then goto #35 -- referenced by #27
					end
	32.	v122 = v17 -- get upval
	33.	
	35.	v122:Stop() -- referenced by #31
					end
	36.	v122 = v121.lc1
	38.	local v124 = 0.3
	39.	local v125 = 1
	40.	
	42.	v122:Play(v124, v125)
	43.	v122 = v2 -- get upval
	44.	v123 = 0
	45.	v122.WalkSpeed = v123
	47.	v122 = true
	48.	v22 = v122 -- set upval
	49.	return -- referenced by #19
					end
	50.	v122 = v25 -- get upval
	51.	if v122 == 2 then goto #92
	53.	v122 = v22 -- get upval
	54.	if v122 == false then goto #134
	56.	v123 = v18 -- get upval
	57.	v122 = v123.IsPlaying
	59.	if not v122 then goto #68
	60.	v123 = v17 -- get upval
	61.	v122 = v123.IsPlaying
	63.	if not v122 then goto #68
	64.	v123 = v121.lc1
	66.	v122 = v123.IsPlaying
	68.	if v122 then goto #78 -- referenced by #59, #63
					end
					end
	69.	v122 = v17 -- get upval
	70.	
	72.	v122:Stop()
	73.	v122 = v121.lc1
	75.	v124 = 0.2
	76.	
	78.	v122:Stop(v124) -- referenced by #68
					end
	79.	v122 = v121.lc2
	81.	v124 = 0.3
	82.	v125 = 1
	83.	
	85.	v122:Play(v124, v125)
	86.	v122 = v2 -- get upval
	87.	v123 = 0
	88.	v122.WalkSpeed = v123
	90.	v122 = true
	91.	v22 = v122 -- set upval
	92.	return -- referenced by #51
					end
	93.	v122 = v25 -- get upval
	94.	if v122 == 3 then goto #134
	96.	v122 = v22 -- get upval
	97.	if v122 == false then goto #134
	99.	v123 = v18 -- get upval
	100.	v122 = v123.IsPlaying
	102.	if not v122 then goto #111
	103.	v123 = v17 -- get upval
	104.	v122 = v123.IsPlaying
	106.	if not v122 then goto #111
	107.	v123 = v121.lc2
	109.	v122 = v123.IsPlaying
	111.	if v122 then goto #121 -- referenced by #102, #106
					end
					end
	112.	v122 = v17 -- get upval
	113.	
	115.	v122:Stop()
	116.	v122 = v121.lc2
	118.	v124 = 0.2
	119.	
	121.	v122:Stop(v124) -- referenced by #111
					end
	122.	v122 = v121.lc3
	124.	v124 = 0.3
	125.	v125 = 1
	126.	
	128.	v122:Play(v124, v125)
	129.	v122 = v2 -- get upval
	130.	v123 = 0
	131.	v122.WalkSpeed = v123
	133.	v122 = true
	134.	v22 = v122 -- set upval -- referenced by #22, #54, #94, #97
					end
					end
					end
					end
	135.	return
end
[NEWCLOSURE] v148 = Combo
315.	CAPTURE VAL R16

316.	CAPTURE REF R22

317.	CAPTURE REF R25

318.	CAPTURE VAL R18

319.	CAPTURE VAL R17

320.	CAPTURE VAL R2

321.	local v205 = v191.lcs
323.	local v204 = v205.lc1
325.	local v206 = "CanCombo"
326.	
328.	v204 = v204:GetMarkerReachedSignal(v206)
329.	-- V nested upvalues[0] = v22
-- V nested upvalues[1] = v1
-- V nested upvalues[2] = v25
-- V nested upvalues[3] = v16
-- V nested upvalues[4] = v2
[NEWCLOSURE] v206 = function() -- [line 186]
	1.	local v176 = false
	2.	v22 = v176 -- set upval
	3.	v176 = v1 -- get upval
	4.	local v177 = v25 -- get upval
	-- DECOMPILER REMARK: Function "LCreset" was inlined here (LINE IS NOT VALID)
	5.	local v178 = task.delay
	7.	local v179 = 0.5
	8.		-- V nested upvalues[0] = upvalues[3]
	-- V nested upvalues[1] = v2
	-- V nested upvalues[2] = upvalues[2]
	[NEWCLOSURE] v180 = function() -- [line 122]
		1.	local v178 = upvalues[3] -- get upval
		2.	local v177 = v178.lcs
		-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v178 = v2 -- get upval
		5.	local v179 = upvalues[2] -- get upval
		6.	if v179 > v178 then goto #25
		8.	v179 = v177.lc1
		10.	v178 = v179.IsPlaying
		12.	if v178 then goto #13
		13.	return -- referenced by #12
						end
		14.	v179 = v177.lc2
		16.	v178 = v179.IsPlaying
		18.	if v178 then goto #19
		19.	return -- referenced by #18
						end
		20.	v179 = v177.lc3
		22.	v178 = v179.IsPlaying
		24.	if v178 then goto #25
		25.	return -- referenced by #6, #24
						end
						end
		26.	v178 = 0
		27.	upvalues[2] = v178 -- set upval
		28.	return
	end

	9.	CAPTURE UPVAL U3

	10.	CAPTURE VAL R1

	11.	CAPTURE UPVAL U2

	12.	v189(v190, v191)
	13.	v187 = v2 -- get upval
	14.	v188 = 6
	15.	v187.WalkSpeed = v188
	17.	return
end

330.	CAPTURE REF R22

331.	CAPTURE VAL R1

332.	CAPTURE REF R25

333.	CAPTURE VAL R16

334.	CAPTURE VAL R2

335.	
337.	v222:Connect(v224)
338.	v223 = v209.lcs
340.	v222 = v223.lc2
342.	v224 = "CanCombo"
343.	
345.	v222 = v222:GetMarkerReachedSignal(v224)
346.	-- V nested upvalues[0] = v22
-- V nested upvalues[1] = v1
-- V nested upvalues[2] = v25
-- V nested upvalues[3] = v16
-- V nested upvalues[4] = v2
[NEWCLOSURE] v224 = function() -- [line 191]
	1.	local v194 = false
	2.	v22 = v194 -- set upval
	3.	v194 = v1 -- get upval
	4.	local v195 = v25 -- get upval
	-- DECOMPILER REMARK: Function "LCreset" was inlined here (LINE IS NOT VALID)
	5.	local v196 = task.delay
	7.	local v197 = 0.5
	8.		-- V nested upvalues[0] = upvalues[3]
	-- V nested upvalues[1] = v2
	-- V nested upvalues[2] = upvalues[2]
	[NEWCLOSURE] v198 = function() -- [line 122]
		1.	local v196 = upvalues[3] -- get upval
		2.	local v195 = v196.lcs
		-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v196 = v2 -- get upval
		5.	local v197 = upvalues[2] -- get upval
		6.	if v197 > v196 then goto #25
		8.	v197 = v195.lc1
		10.	v196 = v197.IsPlaying
		12.	if v196 then goto #13
		13.	return -- referenced by #12
						end
		14.	v197 = v195.lc2
		16.	v196 = v197.IsPlaying
		18.	if v196 then goto #19
		19.	return -- referenced by #18
						end
		20.	v197 = v195.lc3
		22.	v196 = v197.IsPlaying
		24.	if v196 then goto #25
		25.	return -- referenced by #6, #24
						end
						end
		26.	v196 = 0
		27.	upvalues[2] = v196 -- set upval
		28.	return
	end

	9.	CAPTURE UPVAL U3

	10.	CAPTURE VAL R1

	11.	CAPTURE UPVAL U2

	12.	v207(v208, v209)
	13.	v205 = v2 -- get upval
	14.	v206 = 6
	15.	v205.WalkSpeed = v206
	17.	return
end

347.	CAPTURE REF R22

348.	CAPTURE VAL R1

349.	CAPTURE REF R25

350.	CAPTURE VAL R16

351.	CAPTURE VAL R2

352.	
354.	v240:Connect(v242)
355.	v242 = v227.lcs
357.	v241 = v242.lc3
359.	v240 = v241.Stopped
361.	-- V nested upvalues[0] = v22
-- V nested upvalues[1] = v1
-- V nested upvalues[2] = v25
-- V nested upvalues[3] = v16
-- V nested upvalues[4] = v2
[NEWCLOSURE] v242 = function() -- [line 196]
	1.	local v212 = false
	2.	v22 = v212 -- set upval
	3.	v212 = v1 -- get upval
	4.	local v213 = v25 -- get upval
	-- DECOMPILER REMARK: Function "LCreset" was inlined here (LINE IS NOT VALID)
	5.	local v214 = task.delay
	7.	local v215 = 0.5
	8.		-- V nested upvalues[0] = upvalues[3]
	-- V nested upvalues[1] = v2
	-- V nested upvalues[2] = upvalues[2]
	[NEWCLOSURE] v216 = function() -- [line 122]
		1.	local v214 = upvalues[3] -- get upval
		2.	local v213 = v214.lcs
		-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v214 = v2 -- get upval
		5.	local v215 = upvalues[2] -- get upval
		6.	if v215 > v214 then goto #25
		8.	v215 = v213.lc1
		10.	v214 = v215.IsPlaying
		12.	if v214 then goto #13
		13.	return -- referenced by #12
						end
		14.	v215 = v213.lc2
		16.	v214 = v215.IsPlaying
		18.	if v214 then goto #19
		19.	return -- referenced by #18
						end
		20.	v215 = v213.lc3
		22.	v214 = v215.IsPlaying
		24.	if v214 then goto #25
		25.	return -- referenced by #6, #24
						end
						end
		26.	v214 = 0
		27.	upvalues[2] = v214 -- set upval
		28.	return
	end

	9.	CAPTURE UPVAL U3

	10.	CAPTURE VAL R1

	11.	CAPTURE UPVAL U2

	12.	v225(v226, v227)
	13.	v223 = v2 -- get upval
	14.	v224 = 6
	15.	v223.WalkSpeed = v224
	17.	return
end

362.	CAPTURE REF R22

363.	CAPTURE VAL R1

364.	CAPTURE REF R25

365.	CAPTURE VAL R16

366.	CAPTURE VAL R2

367.	
369.	v258:Connect(v260)
370.	v259 = v245.lcs
372.	v258 = v259.lc1
374.	v260 = "Lunge"
375.	
377.	v258 = v258:GetMarkerReachedSignal(v260)
378.	-- V nested upvalues[0] = v233
[DUPCLOSURE] v260 = function() -- [line 203]
	1.	local v230 = v233 -- get upval
	2.	local v232 = "Combo1"
	3.	local v233 = "Lunge"
	4.	
	6.	v230:FireServer(v232, v233)
	7.	return
end

379.	CAPTURE VAL R4

380.	
382.	v261:Connect(v263)
383.	v262 = v248.lcs
385.	v261 = v262.lc1
387.	v263 = "DMG"
388.	
390.	v261 = v261:GetMarkerReachedSignal(v263)
391.	-- V nested upvalues[0] = v236
[DUPCLOSURE] v263 = function() -- [line 206]
	1.	local v233 = v236 -- get upval
	2.	local v235 = "Combo1"
	3.	local v236 = "DMG"
	4.	
	6.	v233:FireServer(v235, v236)
	7.	return
end

392.	CAPTURE VAL R4

393.	
395.	v264:Connect(v266)
396.	v265 = v251.lcs
398.	v264 = v265.lc1
400.	v266 = "LeftFoot"
401.	
403.	v264 = v264:GetMarkerReachedSignal(v266)
404.	-- V nested upvalues[0] = v241
[DUPCLOSURE] v266 = function() -- [line 209]
	1.	local v236 = v241 -- get upval
	2.	local v238 = "LeftFoot"
	3.	
	5.	v236:FireServer(v238)
	6.	return
end

405.	CAPTURE VAL R6

406.	
408.	v266:Connect(v268)
409.	v267 = v253.lcs
411.	v266 = v267.lc2
413.	v268 = "DMG"
414.	
416.	v266 = v266:GetMarkerReachedSignal(v268)
417.	-- V nested upvalues[0] = v241
[DUPCLOSURE] v268 = function() -- [line 212]
	1.	local v238 = v241 -- get upval
	2.	local v240 = "Combo2"
	3.	local v241 = "DMG"
	4.	
	6.	v238:FireServer(v240, v241)
	7.	return
end

418.	CAPTURE VAL R4

419.	
421.	v269:Connect(v271)
422.	v270 = v256.lcs
424.	v269 = v270.lc2
426.	v271 = "Lunge"
427.	
429.	v269 = v269:GetMarkerReachedSignal(v271)
430.	-- V nested upvalues[0] = v244
[DUPCLOSURE] v271 = function() -- [line 215]
	1.	local v241 = v244 -- get upval
	2.	local v243 = "Combo2"
	3.	local v244 = "Lunge"
	4.	
	6.	v241:FireServer(v243, v244)
	7.	return
end

431.	CAPTURE VAL R4

432.	
434.	v272:Connect(v274)
435.	v273 = v259.lcs
437.	v272 = v273.lc2
439.	v274 = "LeftFoot"
440.	
442.	v272 = v272:GetMarkerReachedSignal(v274)
443.	-- V nested upvalues[0] = v249
[DUPCLOSURE] v274 = function() -- [line 218]
	1.	local v244 = v249 -- get upval
	2.	local v246 = "LeftFoot"
	3.	
	5.	v244:FireServer(v246)
	6.	return
end

444.	CAPTURE VAL R6

445.	
447.	v274:Connect(v276)
448.	v275 = v261.lcs
450.	v274 = v275.lc3
452.	v276 = "DMG1"
453.	
455.	v274 = v274:GetMarkerReachedSignal(v276)
456.	-- V nested upvalues[0] = v249
[DUPCLOSURE] v276 = function() -- [line 221]
	1.	local v246 = v249 -- get upval
	2.	local v248 = "Combo3"
	3.	local v249 = "DMG1"
	4.	
	6.	v246:FireServer(v248, v249)
	7.	return
end

457.	CAPTURE VAL R4

458.	
460.	v277:Connect(v279)
461.	v278 = v264.lcs
463.	v277 = v278.lc3
465.	v279 = "DMG2"
466.	
468.	v277 = v277:GetMarkerReachedSignal(v279)
469.	-- V nested upvalues[0] = v252
[DUPCLOSURE] v279 = function() -- [line 224]
	1.	local v249 = v252 -- get upval
	2.	local v251 = "Combo3"
	3.	local v252 = "DMG2"
	4.	
	6.	v249:FireServer(v251, v252)
	7.	return
end

470.	CAPTURE VAL R4

471.	
473.	v280:Connect(v282)
474.	v281 = v267.lcs
476.	v280 = v281.lc3
478.	v282 = "DMG3"
479.	
481.	v280 = v280:GetMarkerReachedSignal(v282)
482.	-- V nested upvalues[0] = v255
[DUPCLOSURE] v282 = function() -- [line 227]
	1.	local v252 = v255 -- get upval
	2.	local v254 = "Combo3"
	3.	local v255 = "DMG3"
	4.	
	6.	v252:FireServer(v254, v255)
	7.	return
end

483.	CAPTURE VAL R4

484.	
486.	v283:Connect(v285)
487.	v284 = v270.lcs
489.	v283 = v284.lc3
491.	v285 = "DMG4"
492.	
494.	v283 = v283:GetMarkerReachedSignal(v285)
495.	-- V nested upvalues[0] = v258
[DUPCLOSURE] v285 = function() -- [line 230]
	1.	local v255 = v258 -- get upval
	2.	local v257 = "Combo3"
	3.	local v258 = "DMG4"
	4.	
	6.	v255:FireServer(v257, v258)
	7.	return
end

496.	CAPTURE VAL R4

497.	
499.	v286:Connect(v288)
500.	v287 = v273.lcs
502.	v286 = v287.lc3
504.	v288 = "Lunge"
505.	
507.	v286 = v286:GetMarkerReachedSignal(v288)
508.	-- V nested upvalues[0] = v261
[DUPCLOSURE] v288 = function() -- [line 233]
	1.	local v258 = v261 -- get upval
	2.	local v260 = "Combo3"
	3.	local v261 = "Lunge"
	4.	
	6.	v258:FireServer(v260, v261)
	7.	return
end

509.	CAPTURE VAL R4

510.	
512.	v289:Connect(v291)
513.	v290 = v276.lcs
515.	v289 = v290.lc3
517.	v291 = "LeftFoot"
518.	
520.	v289 = v289:GetMarkerReachedSignal(v291)
521.	-- V nested upvalues[0] = v266
[DUPCLOSURE] v291 = function() -- [line 236]
	1.	local v261 = v266 -- get upval
	2.	local v263 = "LeftFoot"
	3.	
	5.	v261:FireServer(v263)
	6.	return
end

522.	CAPTURE VAL R6

523.	
525.	v291:Connect(v293)
526.	v292 = v278.lcs
528.	v291 = v292.lc3
530.	v293 = "RightFoot"
531.	
533.	v291 = v291:GetMarkerReachedSignal(v293)
534.	-- V nested upvalues[0] = v268
[DUPCLOSURE] v293 = function() -- [line 239]
	1.	local v263 = v268 -- get upval
	2.	local v265 = "RightFoot"
	3.	
	5.	v263:FireServer(v265)
	6.	return
end

535.	CAPTURE VAL R6

536.	
538.	v293:Connect(v295)
539.	v293 = false
540.	-- V nested upvalues[0] = v16
-- V nested upvalues[1] = v22
-- V nested upvalues[2] = v29
-- V nested upvalues[3] = v17
-- V nested upvalues[4] = v2
-- V nested upvalues[5] = v4
-- V nested upvalues[6] = v20
-- V nested upvalues[7] = v3
-- V nested upvalues[8] = v9
local function Skill1() -- [line 245]
	1.	local v266 = v16 -- get upval
	2.	local v265 = v266.skill1
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v266 = v22 -- get upval
	5.	if v266 == false then goto #64
	7.	v266 = v29 -- get upval
	8.	if v266 == false then goto #64
	10.	local v267 = v17 -- get upval
	11.	v266 = v267.IsPlaying
	13.	if v266 then goto #18
	14.	v266 = v17 -- get upval
	15.	local v268 = 0.6
	16.	
	18.	v266:Stop(v268) -- referenced by #13
					end
	19.	v266 = v2 -- get upval
	20.	v267 = 0
	21.	v266.WalkSpeed = v267
	23.	v268 = 0.3
	24.	
	26.	v265:Play(v268)
	27.	v266 = true
	28.	v22 = v266 -- set upval
	29.	v266 = v4 -- get upval
	30.	v268 = "Skill1"
	31.	local v269 = "Sound"
	32.	
	34.	v266:FireServer(v268, v269)
	35.	v266 = wait
	37.	v268 = v265.Length
	39.	v267 = v268 - 0.3
	40.	v266(v267)
	41.	v266 = v2 -- get upval
	42.	v267 = 6
	43.	v266.WalkSpeed = v267
	45.	v266 = false
	46.	v22 = v266 -- set upval
	47.	v266 = true
	48.	v29 = v266 -- set upval
	49.	v266 = v20 -- get upval
	50.	v268 = v3 -- get upval
	51.	local v270 = "Skill1"
	52.	
	54.	v268 = v268:WaitForChild(v270)
	55.	v267 = v268.CDframe
	57.	v270 = v9 -- get upval
	58.	v269 = v270.Cooldowns
	60.	v268 = v269.Skill1
	62.	v266(v267, v268)
	63.	v266 = false
	64.	v29 = v266 -- set upval -- referenced by #5, #8
					end
					end
	65.	return
end
[NEWCLOSURE] v294 = Skill1
541.	CAPTURE VAL R16

542.	CAPTURE REF R22

543.	CAPTURE REF R29

544.	CAPTURE VAL R17

545.	CAPTURE VAL R2

546.	CAPTURE VAL R4

547.	CAPTURE VAL R20

548.	CAPTURE VAL R3

549.	CAPTURE VAL R9

550.	v325 = v310.skill1
552.	local v327 = "Lunge"
553.	
555.	v325 = v325:GetMarkerReachedSignal(v327)
556.	-- V nested upvalues[0] = v298
[DUPCLOSURE] v327 = function() -- [line 263]
	1.	local v295 = v298 -- get upval
	2.	local v297 = "Skill1"
	3.	local v298 = "Lunge"
	4.	
	6.	v295:FireServer(v297, v298)
	7.	return
end

557.	CAPTURE VAL R4

558.	
560.	v328:Connect(v330)
561.	v328 = v313.skill1
563.	v330 = "Stomp"
564.	
566.	v328 = v328:GetMarkerReachedSignal(v330)
567.	-- V nested upvalues[0] = v301
-- V nested upvalues[1] = v318
[DUPCLOSURE] v330 = function() -- [line 266]
	1.	local v298 = v301 -- get upval
	2.	local v300 = "Skill1"
	3.	local v301 = "Stomp"
	4.	
	6.	v298:FireServer(v300, v301)
	7.	v298 = v318 -- get upval
	8.	local v299 = 70
	9.	v300 = 0.1
	10.	v301 = 0.2
	11.	local v302 = 0.4
	12.	v298(v299, v300, v301, v302)
	13.	return
end

568.	CAPTURE VAL R4

569.	CAPTURE VAL R21

570.	
572.	v336:Connect(v338)
573.	v336 = v321.skill1
575.	v338 = "Stomp2"
576.	
578.	v336 = v336:GetMarkerReachedSignal(v338)
579.	-- V nested upvalues[0] = v309
-- V nested upvalues[1] = v326
[DUPCLOSURE] v338 = function() -- [line 270]
	1.	local v306 = v309 -- get upval
	2.	local v308 = "Skill1"
	3.	local v309 = "Stomp1"
	4.	
	6.	v306:FireServer(v308, v309)
	7.	v306 = v326 -- get upval
	8.	local v307 = 70
	9.	v308 = 0.1
	10.	v309 = 0.2
	11.	local v310 = 0.4
	12.	v306(v307, v308, v309, v310)
	13.	return
end

580.	CAPTURE VAL R4

581.	CAPTURE VAL R21

582.	
584.	v344:Connect(v346)
585.	v344 = v329.skill1
587.	v346 = "KickDMG"
588.	
590.	v344 = v344:GetMarkerReachedSignal(v346)
591.	-- V nested upvalues[0] = v317
[DUPCLOSURE] v346 = function() -- [line 274]
	1.	local v314 = v317 -- get upval
	2.	local v316 = "Skill1"
	3.	local v317 = "KickDMG"
	4.	
	6.	v314:FireServer(v316, v317)
	7.	return
end

592.	CAPTURE VAL R4

593.	
595.	v347:Connect(v349)
596.	-- V nested upvalues[0] = v16
-- V nested upvalues[1] = v22
-- V nested upvalues[2] = v15
-- V nested upvalues[3] = v14
-- V nested upvalues[4] = v13
-- V nested upvalues[5] = v17
-- V nested upvalues[6] = v2
-- V nested upvalues[7] = v4
local function Special() -- [line 279]
	1.	local v318 = v16 -- get upval
	2.	local v317 = v318.special
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v318 = v22 -- get upval
	5.	if v318 == false then goto #60
	7.	local v319 = v15 -- get upval
	8.	v318 = v319.Value
	10.	v319 = 0
	11.	if v319 >= v318 then goto #23
	13.	v319 = v14 -- get upval
	14.	v318 = v319.Value
	16.	v319 = 0
	17.	if v319 >= v318 then goto #23
	19.	v319 = v13 -- get upval
	20.	v318 = v319.Value
	22.	if v318 == 100 then goto #60
					end
					end
	24.	v319 = v17 -- get upval
	25.	v318 = v319.IsPlaying
	27.	if v318 then goto #32
	28.	v318 = v17 -- get upval
	29.	local v320 = 0.6
	30.	
	32.	v318:Stop(v320) -- referenced by #27
					end
	33.	v318 = v2 -- get upval
	34.	v319 = 0
	35.	v318.WalkSpeed = v319
	37.	v320 = 0.3
	38.	
	40.	v317:Play(v320)
	41.	v318 = true
	42.	v22 = v318 -- set upval
	43.	v318 = v4 -- get upval
	44.	v320 = "Special"
	45.	local v321 = "Sound"
	46.	
	48.	v318:FireServer(v320, v321)
	49.	v318 = wait
	51.	v320 = v317.Length
	53.	v319 = v320 - 0.3
	54.	v318(v319)
	55.	v318 = v2 -- get upval
	56.	v319 = 6
	57.	v318.WalkSpeed = v319
	59.	v318 = false
	60.	v22 = v318 -- set upval -- referenced by #5, #22
					end
					end
	61.	return
end
[NEWCLOSURE] v347 = Special
597.	CAPTURE VAL R16

598.	CAPTURE REF R22

599.	CAPTURE VAL R15

600.	CAPTURE VAL R14

601.	CAPTURE VAL R13

602.	CAPTURE VAL R17

603.	CAPTURE VAL R2

604.	CAPTURE VAL R4

605.	local v376 = v360.special
607.	local v378 = "Armor"
608.	
610.	v376 = v376:GetMarkerReachedSignal(v378)
611.	-- V nested upvalues[0] = v348
-- V nested upvalues[1] = v349
-- V nested upvalues[2] = v365
[DUPCLOSURE] v378 = function() -- [line 296]
	1.	local v345 = v348 -- get upval
	2.	local v347 = "Armor"
	3.	
	5.	v345:FireServer(v347)
	6.	v345 = v348 -- get upval
	7.	v347 = "Special"
	8.	local v348 = "Chestvfx"
	9.	
	11.	v345:FireServer(v347, v348)
	12.	v345 = v349 -- get upval
	13.	v347 = 100
	14.	
	16.	v345:FireServer(v347)
	17.	v345 = v365 -- get upval
	18.	local v346 = 76
	19.	v347 = 0.1
	20.	v348 = 0.12
	21.	local v349 = 0.2
	22.	v345(v346, v347, v348, v349)
	23.	return
end

612.	CAPTURE VAL R4

613.	CAPTURE VAL R5

614.	CAPTURE VAL R21

615.	
617.	v388:Connect(v390)
618.	v388 = v372.special
620.	v390 = "RedPulse"
621.	
623.	v388 = v388:GetMarkerReachedSignal(v390)
624.	-- V nested upvalues[0] = v360
-- V nested upvalues[1] = v377
[DUPCLOSURE] v390 = function() -- [line 302]
	1.	local v357 = v360 -- get upval
	2.	local v359 = "Special"
	3.	local v360 = "RedPulse"
	4.	
	6.	v357:FireServer(v359, v360)
	7.	v357 = v377 -- get upval
	8.	local v358 = 50
	9.	v359 = 0.2
	10.	v360 = 0.23
	11.	local v361 = 4
	12.	v357(v358, v359, v360, v361)
	13.	return
end

625.	CAPTURE VAL R4

626.	CAPTURE VAL R21

627.	
629.	v396:Connect(v398)
630.	v396 = v380.special
632.	v398 = "ChestVFXend"
633.	
635.	v396 = v396:GetMarkerReachedSignal(v398)
636.	-- V nested upvalues[0] = v368
[DUPCLOSURE] v398 = function() -- [line 306]
	1.	local v365 = v368 -- get upval
	2.	local v367 = "Special"
	3.	local v368 = "vfxend"
	4.	
	6.	v365:FireServer(v367, v368)
	7.	return
end

637.	CAPTURE VAL R4

638.	
640.	v399:Connect(v401)
641.	v399 = v383.special
643.	v401 = "Pulse"
644.	
646.	v399 = v399:GetMarkerReachedSignal(v401)
647.	-- V nested upvalues[0] = v371
[DUPCLOSURE] v401 = function() -- [line 309]
	1.	local v368 = v371 -- get upval
	2.	local v370 = "Special"
	3.	local v371 = "Pulse"
	4.	
	6.	v368:FireServer(v370, v371)
	7.	return
end

648.	CAPTURE VAL R4

649.	
651.	v402:Connect(v404)
652.	v404 = "UpperTorso"
653.	
655.	v402 = v371:WaitForChild(v404)
656.	local v405 = game
658.	v404 = v405.Workspace
660.	v403 = v404.CurrentCamera
662.	v403.CameraSubject = v402
664.	-- V nested upvalues[0] = v373
local function EnergyChange(p10, p11) -- [line 317]
	1.	local v371 = v373 -- get upval
	2.	local v373 = p10
	3.	
	5.	v371 = v371:FindFirstChild(v373)
	6.	if not v371 then goto #11
	7.	v371 = v373 -- get upval
	8.	v373 = p10
	9.	
	11.	v371 = v371:WaitForChild(v373) -- referenced by #6
					end
	12.	local v372 = p11 / 100
	13.	local v374 = v371.Energy
	15.	v373 = v374.Energy
	17.	v374 = UDim2.new
	19.	local v375 = v372
	20.	local v376 = 0
	21.	local v377 = 1
	22.	local v378 = 0
	23.	v374 = v374(v375, v376, v377, v378)
	24.	v373.Size = v374
	26.	return
end
[DUPCLOSURE] v403 = EnergyChange
665.	CAPTURE VAL R3

666.	local v418 = "Value"
667.	
669.	v416 = v395:GetPropertyChangedSignal(v418)
670.	-- V nested upvalues[0] = v395
-- V nested upvalues[1] = v385
[DUPCLOSURE] v418 = function() -- [line 324]
	1.	local v384 = v395 -- get upval
	2.	local v383 = v384.Name
	4.	local v385 = v395 -- get upval
	5.	v384 = v385.Value
	-- DECOMPILER REMARK: Function "EnergyChange" was inlined here (LINE IS NOT VALID)
	7.	v385 = v385 -- get upval
	8.	local v387 = v383
	9.	
	11.	v385 = v385:FindFirstChild(v387)
	12.	if not v385 then goto #17
	13.	v385 = v385 -- get upval
	14.	v387 = v383
	15.	
	17.	v385 = v385:WaitForChild(v387) -- referenced by #12
					end
	18.	local v386 = v384 / 100
	19.	local v388 = v385.Energy
	21.	v387 = v388.Energy
	23.	v388 = UDim2.new
	25.	local v389 = v386
	26.	local v390 = 0
	27.	local v391 = 1
	28.	local v392 = 0
	29.	v388 = v388(v389, v390, v391, v392)
	30.	v387.Size = v388
	32.	return
end

671.	CAPTURE VAL R13

672.	CAPTURE VAL R3

673.	
675.	v432:Connect(v434)
676.	v434 = "Value"
677.	
679.	v432 = v412:GetPropertyChangedSignal(v434)
680.	-- V nested upvalues[0] = v412
-- V nested upvalues[1] = v401
[DUPCLOSURE] v434 = function() -- [line 327]
	1.	local v400 = v412 -- get upval
	2.	local v399 = v400.Name
	4.	local v401 = v412 -- get upval
	5.	v400 = v401.Value
	-- DECOMPILER REMARK: Function "EnergyChange" was inlined here (LINE IS NOT VALID)
	7.	v401 = v401 -- get upval
	8.	local v403 = v399
	9.	
	11.	v401 = v401:FindFirstChild(v403)
	12.	if not v401 then goto #17
	13.	v401 = v401 -- get upval
	14.	v403 = v399
	15.	
	17.	v401 = v401:WaitForChild(v403) -- referenced by #12
					end
	18.	local v402 = v400 / 100
	19.	local v404 = v401.Energy
	21.	v403 = v404.Energy
	23.	v404 = UDim2.new
	25.	local v405 = v402
	26.	local v406 = 0
	27.	local v407 = 1
	28.	local v408 = 0
	29.	v404 = v404(v405, v406, v407, v408)
	30.	v403.Size = v404
	32.	return
end

681.	CAPTURE VAL R14

682.	CAPTURE VAL R3

683.	
685.	v448:Connect(v450)
686.	v450 = "Value"
687.	
689.	v448 = v429:GetPropertyChangedSignal(v450)
690.	-- V nested upvalues[0] = v429
-- V nested upvalues[1] = v417
[DUPCLOSURE] v450 = function() -- [line 330]
	1.	local v416 = v429 -- get upval
	2.	local v415 = v416.Name
	4.	local v417 = v429 -- get upval
	5.	v416 = v417.Value
	-- DECOMPILER REMARK: Function "EnergyChange" was inlined here (LINE IS NOT VALID)
	7.	v417 = v417 -- get upval
	8.	local v419 = v415
	9.	
	11.	v417 = v417:FindFirstChild(v419)
	12.	if not v417 then goto #17
	13.	v417 = v417 -- get upval
	14.	v419 = v415
	15.	
	17.	v417 = v417:WaitForChild(v419) -- referenced by #12
					end
	18.	local v418 = v416 / 100
	19.	local v420 = v417.Energy
	21.	v419 = v420.Energy
	23.	v420 = UDim2.new
	25.	local v421 = v418
	26.	local v422 = 0
	27.	local v423 = 1
	28.	local v424 = 0
	29.	v420 = v420(v421, v422, v423, v424)
	30.	v419.Size = v420
	32.	return
end

691.	CAPTURE VAL R15

692.	CAPTURE VAL R3

693.	
695.	v464:Connect(v466)
696.	v464 = v437.InputBegan
698.	-- V nested upvalues[0] = v454
-- V nested upvalues[1] = v460
-- V nested upvalues[2] = v461
-- V nested upvalues[3] = v458
[DUPCLOSURE] v466 = function(p12, p13) -- [line 335]
	1.	if p13 then goto #2
	2.	return -- referenced by #1
					end
	3.	local v431 = p12.KeyCode
	5.	local v432 = Enum.KeyCode.R
	7.	if v431 == v432 then goto #10
	9.	v431 = v454 -- get upval
	10.	v431(v432) -- referenced by #7
					end
	11.	v431 = p12.KeyCode
	13.	v432 = Enum.KeyCode.One
	15.	if v431 == v432 then goto #18
	17.	v431 = v460 -- get upval
	18.	v431(v432) -- referenced by #15
					end
	19.	v431 = p12.KeyCode
	21.	v432 = Enum.KeyCode.X
	23.	if v431 == v432 then goto #26
	25.	v431 = v461 -- get upval
	26.	v431(v432) -- referenced by #23
					end
	27.	v431 = p12.UserInputType
	29.	v432 = Enum.UserInputType.MouseButton1
	31.	if v431 == v432 then goto #34
	33.	v431 = v458 -- get upval
	34.	v431(v432) -- referenced by #31
					end
	35.	return
end

699.	CAPTURE VAL R24

700.	CAPTURE VAL R30

701.	CAPTURE VAL R31

702.	CAPTURE VAL R28

703.	
705.	v476:Connect(v478)
706.	local v479 = "Roar"
707.	
709.	v477 = v445:WaitForChild(v479)
710.	v476 = v477.MouseButton1Click
712.	v478 = v466
713.	
715.	v476:Connect(v478)
716.	v479 = "Skill1"
717.	
719.	v477 = v445:WaitForChild(v479)
720.	v476 = v477.MouseButton1Click
722.	v478 = v472
723.	
725.	v476:Connect(v478)
726.	v479 = "Special"
727.	
729.	v477 = v445:WaitForChild(v479)
730.	v476 = v477.MouseButton1Click
732.	v478 = v473
733.	
735.	v476:Connect(v478)
736.	[CLOSEUPVALS]: clear captures from back until: 22
737.	return
