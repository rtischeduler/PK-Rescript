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
18.	local v5 = "FWGiganSkillset"
19.	
21.	v3 = v3:WaitForChild(v5)
22.	v5 = script
24.	v4 = v5.Combat
26.	local v6 = script
28.	v5 = v6.Energy
30.	v6 = game
32.	local v8 = "UserInputService"
33.	
35.	v6 = v6:GetService(v8)
36.	local v7 = require
38.	local v9 = script
40.	v8 = v9.Stats
42.	v7 = v7(v8)
43.	local v10 = "CharacterAssets"
44.	
46.	v8 = v1:WaitForChild(v10)
47.	local v11 = "ScriptManagement"
48.	
50.	v9 = v8:WaitForChild(v11)
51.	v10 = v9.Energy1
53.	v11 = v9.Energy2
55.	local v12 = v9.Energy3
57.	local v13 = {"walk", "idle", "roar", "lcs", "skill1", "skill2", "special"}
58.	local v21 = "CharacterAssets"
59.	
61.	v19 = v1:WaitForChild(v21)
62.	local v18 = v19.Animations
64.	local v17 = v18.Movement
66.	local v16 = v17.Walk
68.	
70.	v14 = v2:LoadAnimation(v16)
71.	v13.walk = v14
73.	v21 = "CharacterAssets"
74.	
76.	v19 = v1:WaitForChild(v21)
77.	v18 = v19.Animations
79.	v17 = v18.Movement
81.	v16 = v17.Idle
83.	
85.	v14 = v2:LoadAnimation(v16)
86.	v13.idle = v14
88.	v21 = "CharacterAssets"
89.	
91.	v19 = v1:WaitForChild(v21)
92.	v18 = v19.Animations
94.	v17 = v18.Actions
96.	v16 = v17.Roar
98.	
100.	v14 = v2:LoadAnimation(v16)
101.	v13.roar = v14
103.	local v14 = {"lc1", "lc2", "lc3"}
104.	local v23 = "CharacterAssets"
105.	
107.	v21 = v1:WaitForChild(v23)
108.	local v20 = v21.Animations
110.	local v19 = v20.Actions
112.	v18 = v19.LCs
114.	v17 = v18.LC1
116.	
118.	v15 = v2:LoadAnimation(v17)
119.	v14.lc1 = v15
121.	v23 = "CharacterAssets"
122.	
124.	v21 = v1:WaitForChild(v23)
125.	v20 = v21.Animations
127.	v19 = v20.Actions
129.	v18 = v19.LCs
131.	v17 = v18.LC2
133.	
135.	v15 = v2:LoadAnimation(v17)
136.	v14.lc2 = v15
138.	v23 = "CharacterAssets"
139.	
141.	v21 = v1:WaitForChild(v23)
142.	v20 = v21.Animations
144.	v19 = v20.Actions
146.	v18 = v19.LCs
148.	v17 = v18.LC3
150.	
152.	v15 = v2:LoadAnimation(v17)
153.	v14.lc3 = v15
155.	v13.lcs = v14
157.	v21 = "CharacterAssets"
158.	
160.	v19 = v1:WaitForChild(v21)
161.	v18 = v19.Animations
163.	v17 = v18.Actions
165.	v16 = v17.Skill1
167.	
169.	v14 = v2:LoadAnimation(v16)
170.	v13.skill1 = v14
172.	v21 = "CharacterAssets"
173.	
175.	v19 = v1:WaitForChild(v21)
176.	v18 = v19.Animations
178.	v17 = v18.Actions
180.	v16 = v17.Skill2
182.	
184.	v14 = v2:LoadAnimation(v16)
185.	v13.skill2 = v14
187.	v21 = "CharacterAssets"
188.	
190.	v19 = v1:WaitForChild(v21)
191.	v18 = v19.Animations
193.	v17 = v18.Actions
195.	v16 = v17.Special
197.	
199.	v14 = v2:LoadAnimation(v16)
200.	v13.special = v14
202.	v14 = v13.walk
204.	local v15 = v13.idle
206.	v16 = v2.Running
208.	-- V nested upvalues[0] = v15
-- V nested upvalues[1] = v14
[DUPCLOSURE] v18 = function(p1) -- [line 28]
	1.	if p1 == 0 then goto #13
	3.	local v1 = v15 -- get upval
	4.	local v3 = 0.5
	5.	
	7.	v1:Play(v3)
	8.	v1 = v14 -- get upval
	9.	v3 = 0.5
	10.	
	12.	v1:Stop(v3)
	13.	return -- referenced by #1
					end
	14.	v1 = v14 -- get upval
	15.	v3 = 0.5
	16.	
	18.	v1:Play(v3)
	19.	v1 = v15 -- get upval
	20.	v3 = 0.5
	21.	
	23.	v1:Stop(v3)
	24.	return
end

209.	CAPTURE VAL R15

210.	CAPTURE VAL R14

211.	
213.	v24:Connect(v26)
214.	local function CooldownTween(p2, p3) -- [line 39]
	1.	local v9 = p2.Visible
	3.	if v9 == false then goto #7
	5.	v9 = true
	6.	p2.Visible = v9
					end
	8.	v9 = UDim2.new
	10.	local v10 = 1
	11.	local v11 = 0
	12.	local v12 = 1
	13.	local v13 = 0
	14.	v9 = v9(v10, v11, v12, v13)
	15.	p2.Size = v9
	17.	v11 = UDim2.new
	19.	v12 = 1
	20.	v13 = 0
	21.	local v14 = 0
	22.	local v15 = 0
	23.	v11 = v11(v12, v13, v14, v15)
	24.	v12 = Enum.EasingDirection.Out
	26.	v13 = Enum.EasingStyle.Sine
	28.	v14 = p3
	29.	v15 = false
	30.	
	32.	p2:TweenSize(v11, v12, v13, v14, v15)
	33.	v9 = task.wait
	35.	v10 = p3
	36.	v9(v10)
	37.	v9 = false
	38.	p2.Visible = v9
	40.	return
end
[DUPCLOSURE] v24 = CooldownTween
215.	v44 = false
216.	v45 = false
217.	-- V nested upvalues[0] = v13
-- V nested upvalues[1] = v17
-- V nested upvalues[2] = v18
-- V nested upvalues[3] = v14
-- V nested upvalues[4] = v1
-- V nested upvalues[5] = v4
-- V nested upvalues[6] = v16
-- V nested upvalues[7] = v3
-- V nested upvalues[8] = v7
local function Roar() -- [line 52]
	1.	local v29 = v13 -- get upval
	2.	local v28 = v29.roar
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v29 = v17 -- get upval
	5.	if v29 == false then goto #50
	7.	v29 = v18 -- get upval
	8.	if v29 == false then goto #50
	10.	local v30 = v14 -- get upval
	11.	v29 = v30.IsPlaying
	13.	if v29 then goto #18
	14.	v29 = v14 -- get upval
	15.	local v31 = 0.6
	16.	
	18.	v29:Stop(v31) -- referenced by #13
					end
	19.	v29 = v1 -- get upval
	20.	v31 = "HumanoidRootPart"
	21.	
	23.	v29 = v29:WaitForChild(v31)
	24.	v30 = true
	25.	v29.Anchored = v30
	27.	v31 = 0.3
	28.	
	30.	v28:Play(v31)
	31.	v29 = true
	32.	v17 = v29 -- set upval
	33.	v29 = v4 -- get upval
	34.	v31 = "Roar"
	35.	local v32 = "Sound"
	36.	
	38.	v29:FireServer(v31, v32)
	39.	v29 = v28.Stopped
	41.		-- V nested upvalues[0] = upvalues[4]
	-- V nested upvalues[1] = upvalues[1]
	-- V nested upvalues[2] = upvalues[2]
	-- V nested upvalues[3] = upvalues[6]
	-- V nested upvalues[4] = upvalues[7]
	-- V nested upvalues[5] = upvalues[8]
	[NEWCLOSURE] v31 = function() -- [line 63]
		1.	local v29 = upvalues[4] -- get upval
		2.	local v31 = "HumanoidRootPart"
		3.	
		5.	v29 = v29:WaitForChild(v31)
		6.	local v30 = false
		7.	v29.Anchored = v30
		9.	v29 = false
		10.	upvalues[1] = v29 -- set upval
		11.	v29 = true
		12.	upvalues[2] = v29 -- set upval
		13.	v29 = upvalues[6] -- get upval
		14.	v31 = upvalues[7] -- get upval
		15.	local v33 = "Roar"
		16.	
		18.	v31 = v31:WaitForChild(v33)
		19.	v30 = v31.CDframe
		21.	v33 = upvalues[8] -- get upval
		22.	local v32 = v33.Cooldowns
		24.	v31 = v32.Roar
		26.	v29(v30, v31)
		27.	v29 = false
		28.	upvalues[2] = v29 -- set upval
		29.	return
	end

	42.	CAPTURE UPVAL U4

	43.	CAPTURE UPVAL U1

	44.	CAPTURE UPVAL U2

	45.	CAPTURE UPVAL U6

	46.	CAPTURE UPVAL U7

	47.	CAPTURE UPVAL U8

	48.	
	50.	v42:Connect(v44) -- referenced by #5, #8
					end
					end
	51.	return
end
[NEWCLOSURE] v59 = Roar
218.	CAPTURE VAL R13

219.	CAPTURE REF R17

220.	CAPTURE REF R18

221.	CAPTURE VAL R14

222.	CAPTURE VAL R1

223.	CAPTURE VAL R4

224.	CAPTURE VAL R16

225.	CAPTURE VAL R3

226.	CAPTURE VAL R7

227.	v77 = v70.roar
229.	local v79 = "Roar"
230.	
232.	v77 = v77:GetMarkerReachedSignal(v79)
233.	-- V nested upvalues[0] = v61
[DUPCLOSURE] v79 = function() -- [line 72]
	1.	local v58 = v61 -- get upval
	2.	local v60 = "Roar"
	3.	local v61 = "Particle"
	4.	
	6.	v58:FireServer(v60, v61)
	7.	return
end

234.	CAPTURE VAL R4

235.	
237.	v80:Connect(v82)
238.	v80 = v73.roar
240.	v82 = "Armor"
241.	
243.	v80 = v80:GetMarkerReachedSignal(v82)
244.	-- V nested upvalues[0] = v64
-- V nested upvalues[1] = v73
[DUPCLOSURE] v82 = function() -- [line 75]
	1.	local v61 = v64 -- get upval
	2.	local v63 = "Armor"
	3.	local v66 = v73 -- get upval
	4.	local v65 = v66.roar
	6.	local v64 = v65.Length
	8.	
	10.	v61:FireServer(v63, v64)
	11.	return
end

245.	CAPTURE VAL R4

246.	CAPTURE VAL R13

247.	
249.	v85:Connect(v87)
250.	v85 = 0
251.	-- V nested upvalues[0] = v17
-- V nested upvalues[1] = v20
local function SetLC() -- [line 83]
	1.	local v66 = v17 -- get upval
	2.	if not v66 then goto #3
	3.	goto #4 -- referenced by #2
					else
	4.	return -- referenced by #3
					end
	5.	v66 = v20 -- get upval
	6.	local v67 = 3
	7.	if v67 > v66 then goto #12
	9.	v66 = v20 -- get upval
	10.	v66 = v66 + 1
	11.	v20 = v66 -- set upval
	12.	return -- referenced by #7
					end
	13.	v66 = 0
	14.	v20 = v66 -- set upval
	15.	return
end
[NEWCLOSURE] v86 = SetLC
252.	CAPTURE REF R17

253.	CAPTURE REF R20

254.	-- V nested upvalues[0] = v13
-- V nested upvalues[1] = v20
local function LCreset(p4, p5) -- [line 92]
	1.	local v72 = task.delay
	3.	local v73 = 0.5
	4.		-- V nested upvalues[0] = upvalues[0]
	-- V nested upvalues[1] = p5
	-- V nested upvalues[2] = upvalues[1]
	[NEWCLOSURE] v74 = function() -- [line 93]
		1.	local v74 = upvalues[0] -- get upval
		2.	local v73 = v74.lcs
		-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v74 = p5 -- get upval
		5.	local v75 = upvalues[1] -- get upval
		6.	if v75 > v74 then goto #25
		8.	v75 = v73.lc1
		10.	v74 = v75.IsPlaying
		12.	if v74 then goto #13
		13.	return -- referenced by #12
						end
		14.	v75 = v73.lc2
		16.	v74 = v75.IsPlaying
		18.	if v74 then goto #19
		19.	return -- referenced by #18
						end
		20.	v75 = v73.lc3
		22.	v74 = v75.IsPlaying
		24.	if v74 then goto #25
		25.	return -- referenced by #6, #24
						end
						end
		26.	v74 = 0
		27.	upvalues[1] = v74 -- set upval
		28.	return
	end

	5.	CAPTURE UPVAL U0

	6.	CAPTURE VAL R1

	7.	CAPTURE UPVAL U1

	8.	v83(v84, v85)
	9.	return
end
[NEWCLOSURE] v104 = LCreset
255.	CAPTURE VAL R13

256.	CAPTURE REF R20

257.	-- V nested upvalues[0] = v13
-- V nested upvalues[1] = v17
-- V nested upvalues[2] = v20
-- V nested upvalues[3] = v15
-- V nested upvalues[4] = v14
-- V nested upvalues[5] = v2
local function Combo() -- [line 122]
	1.	local v86 = v13 -- get upval
	2.	local v85 = v86.lcs
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v86 = v17 -- get upval
	5.	if not v86 then goto #17
	6.	goto #7
	7.	goto #17 -- referenced by #6
					else
	8.	v86 = v20 -- get upval
	9.	local v87 = 3
	10.	if v87 > v86 then goto #15
	12.	v86 = v20 -- get upval
	13.	v86 = v86 + 1
	14.	v20 = v86 -- set upval
	15.	goto #17 -- referenced by #10
					else
	16.	v86 = 0
	17.	v20 = v86 -- set upval -- referenced by #5, #7, #15
					end
					end
					end
	18.	v86 = v20 -- get upval
	19.	if v86 == 1 then goto #49
	21.	v86 = v17 -- get upval
	22.	if v86 == false then goto #134
	24.	v87 = v15 -- get upval
	25.	v86 = v87.IsPlaying
	27.	if not v86 then goto #31
	28.	v87 = v14 -- get upval
	29.	v86 = v87.IsPlaying
	31.	if v86 then goto #35 -- referenced by #27
					end
	32.	v86 = v14 -- get upval
	33.	
	35.	v86:Stop() -- referenced by #31
					end
	36.	v86 = v85.lc1
	38.	local v88 = 0.3
	39.	local v89 = 1
	40.	
	42.	v86:Play(v88, v89)
	43.	v86 = v2 -- get upval
	44.	v87 = 0
	45.	v86.WalkSpeed = v87
	47.	v86 = true
	48.	v17 = v86 -- set upval
	49.	return -- referenced by #19
					end
	50.	v86 = v20 -- get upval
	51.	if v86 == 2 then goto #92
	53.	v86 = v17 -- get upval
	54.	if v86 == false then goto #134
	56.	v87 = v15 -- get upval
	57.	v86 = v87.IsPlaying
	59.	if not v86 then goto #68
	60.	v87 = v14 -- get upval
	61.	v86 = v87.IsPlaying
	63.	if not v86 then goto #68
	64.	v87 = v85.lc1
	66.	v86 = v87.IsPlaying
	68.	if v86 then goto #78 -- referenced by #59, #63
					end
					end
	69.	v86 = v14 -- get upval
	70.	
	72.	v86:Stop()
	73.	v86 = v85.lc1
	75.	v88 = 0.2
	76.	
	78.	v86:Stop(v88) -- referenced by #68
					end
	79.	v86 = v85.lc2
	81.	v88 = 0.3
	82.	v89 = 1
	83.	
	85.	v86:Play(v88, v89)
	86.	v86 = v2 -- get upval
	87.	v87 = 0
	88.	v86.WalkSpeed = v87
	90.	v86 = true
	91.	v17 = v86 -- set upval
	92.	return -- referenced by #51
					end
	93.	v86 = v20 -- get upval
	94.	if v86 == 3 then goto #134
	96.	v86 = v17 -- get upval
	97.	if v86 == false then goto #134
	99.	v87 = v15 -- get upval
	100.	v86 = v87.IsPlaying
	102.	if not v86 then goto #111
	103.	v87 = v14 -- get upval
	104.	v86 = v87.IsPlaying
	106.	if not v86 then goto #111
	107.	v87 = v85.lc2
	109.	v86 = v87.IsPlaying
	111.	if v86 then goto #121 -- referenced by #102, #106
					end
					end
	112.	v86 = v14 -- get upval
	113.	
	115.	v86:Stop()
	116.	v86 = v85.lc2
	118.	v88 = 0.2
	119.	
	121.	v86:Stop(v88) -- referenced by #111
					end
	122.	v86 = v85.lc3
	124.	v88 = 0.3
	125.	v89 = 1
	126.	
	128.	v86:Play(v88, v89)
	129.	v86 = v2 -- get upval
	130.	v87 = 0
	131.	v86.WalkSpeed = v87
	133.	v86 = true
	134.	v17 = v86 -- set upval -- referenced by #22, #54, #94, #97
					end
					end
					end
					end
	135.	return
end
[NEWCLOSURE] v107 = Combo
258.	CAPTURE VAL R13

259.	CAPTURE REF R17

260.	CAPTURE REF R20

261.	CAPTURE VAL R15

262.	CAPTURE VAL R14

263.	CAPTURE VAL R2

264.	local v164 = v152.lcs
266.	local v163 = v164.lc1
268.	local v165 = "CanCombo"
269.	
271.	v163 = v163:GetMarkerReachedSignal(v165)
272.	-- V nested upvalues[0] = v17
-- V nested upvalues[1] = v1
-- V nested upvalues[2] = v20
-- V nested upvalues[3] = v13
-- V nested upvalues[4] = v2
[NEWCLOSURE] v165 = function() -- [line 157]
	1.	local v140 = false
	2.	v17 = v140 -- set upval
	3.	v140 = v1 -- get upval
	4.	local v141 = v20 -- get upval
	-- DECOMPILER REMARK: Function "LCreset" was inlined here (LINE IS NOT VALID)
	5.	local v142 = task.delay
	7.	local v143 = 0.5
	8.		-- V nested upvalues[0] = upvalues[3]
	-- V nested upvalues[1] = v2
	-- V nested upvalues[2] = upvalues[2]
	[NEWCLOSURE] v144 = function() -- [line 93]
		1.	local v142 = upvalues[3] -- get upval
		2.	local v141 = v142.lcs
		-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v142 = v2 -- get upval
		5.	local v143 = upvalues[2] -- get upval
		6.	if v143 > v142 then goto #25
		8.	v143 = v141.lc1
		10.	v142 = v143.IsPlaying
		12.	if v142 then goto #13
		13.	return -- referenced by #12
						end
		14.	v143 = v141.lc2
		16.	v142 = v143.IsPlaying
		18.	if v142 then goto #19
		19.	return -- referenced by #18
						end
		20.	v143 = v141.lc3
		22.	v142 = v143.IsPlaying
		24.	if v142 then goto #25
		25.	return -- referenced by #6, #24
						end
						end
		26.	v142 = 0
		27.	upvalues[2] = v142 -- set upval
		28.	return
	end

	9.	CAPTURE UPVAL U3

	10.	CAPTURE VAL R1

	11.	CAPTURE UPVAL U2

	12.	v153(v154, v155)
	13.	v151 = v2 -- get upval
	14.	v152 = 12
	15.	v151.WalkSpeed = v152
	17.	return
end

273.	CAPTURE REF R17

274.	CAPTURE VAL R1

275.	CAPTURE REF R20

276.	CAPTURE VAL R13

277.	CAPTURE VAL R2

278.	
280.	v181:Connect(v183)
281.	v182 = v170.lcs
283.	v181 = v182.lc2
285.	v183 = "CanCombo"
286.	
288.	v181 = v181:GetMarkerReachedSignal(v183)
289.	-- V nested upvalues[0] = v17
-- V nested upvalues[1] = v1
-- V nested upvalues[2] = v20
-- V nested upvalues[3] = v13
-- V nested upvalues[4] = v2
[NEWCLOSURE] v183 = function() -- [line 162]
	1.	local v158 = false
	2.	v17 = v158 -- set upval
	3.	v158 = v1 -- get upval
	4.	local v159 = v20 -- get upval
	-- DECOMPILER REMARK: Function "LCreset" was inlined here (LINE IS NOT VALID)
	5.	local v160 = task.delay
	7.	local v161 = 0.5
	8.		-- V nested upvalues[0] = upvalues[3]
	-- V nested upvalues[1] = v2
	-- V nested upvalues[2] = upvalues[2]
	[NEWCLOSURE] v162 = function() -- [line 93]
		1.	local v160 = upvalues[3] -- get upval
		2.	local v159 = v160.lcs
		-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v160 = v2 -- get upval
		5.	local v161 = upvalues[2] -- get upval
		6.	if v161 > v160 then goto #25
		8.	v161 = v159.lc1
		10.	v160 = v161.IsPlaying
		12.	if v160 then goto #13
		13.	return -- referenced by #12
						end
		14.	v161 = v159.lc2
		16.	v160 = v161.IsPlaying
		18.	if v160 then goto #19
		19.	return -- referenced by #18
						end
		20.	v161 = v159.lc3
		22.	v160 = v161.IsPlaying
		24.	if v160 then goto #25
		25.	return -- referenced by #6, #24
						end
						end
		26.	v160 = 0
		27.	upvalues[2] = v160 -- set upval
		28.	return
	end

	9.	CAPTURE UPVAL U3

	10.	CAPTURE VAL R1

	11.	CAPTURE UPVAL U2

	12.	v171(v172, v173)
	13.	v169 = v2 -- get upval
	14.	v170 = 12
	15.	v169.WalkSpeed = v170
	17.	return
end

290.	CAPTURE REF R17

291.	CAPTURE VAL R1

292.	CAPTURE REF R20

293.	CAPTURE VAL R13

294.	CAPTURE VAL R2

295.	
297.	v199:Connect(v201)
298.	v199 = 12
299.	v177.WalkSpeed = v199
301.	v201 = v188.lcs
303.	v200 = v201.lc3
305.	v199 = v200.Stopped
307.	-- V nested upvalues[0] = v17
-- V nested upvalues[1] = v1
-- V nested upvalues[2] = v20
-- V nested upvalues[3] = v13
-- V nested upvalues[4] = v2
[NEWCLOSURE] v201 = function() -- [line 168]
	1.	local v176 = false
	2.	v17 = v176 -- set upval
	3.	v176 = v1 -- get upval
	4.	local v177 = v20 -- get upval
	-- DECOMPILER REMARK: Function "LCreset" was inlined here (LINE IS NOT VALID)
	5.	local v178 = task.delay
	7.	local v179 = 0.5
	8.		-- V nested upvalues[0] = upvalues[3]
	-- V nested upvalues[1] = v2
	-- V nested upvalues[2] = upvalues[2]
	[NEWCLOSURE] v180 = function() -- [line 93]
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
	14.	v188 = 12
	15.	v187.WalkSpeed = v188
	17.	return
end

308.	CAPTURE REF R17

309.	CAPTURE VAL R1

310.	CAPTURE REF R20

311.	CAPTURE VAL R13

312.	CAPTURE VAL R2

313.	
315.	v217:Connect(v219)
316.	v218 = v206.lcs
318.	v217 = v218.lc1
320.	v219 = "Lunge"
321.	
323.	v217 = v217:GetMarkerReachedSignal(v219)
324.	-- V nested upvalues[0] = v197
[DUPCLOSURE] v219 = function() -- [line 175]
	1.	local v194 = v197 -- get upval
	2.	local v196 = "Combo1"
	3.	local v197 = "Lunge"
	4.	
	6.	v194:FireServer(v196, v197)
	7.	return
end

325.	CAPTURE VAL R4

326.	
328.	v220:Connect(v222)
329.	v221 = v209.lcs
331.	v220 = v221.lc1
333.	v222 = "DMG"
334.	
336.	v220 = v220:GetMarkerReachedSignal(v222)
337.	-- V nested upvalues[0] = v200
[DUPCLOSURE] v222 = function() -- [line 178]
	1.	local v197 = v200 -- get upval
	2.	local v199 = "Combo1"
	3.	local v200 = "DMG"
	4.	
	6.	v197:FireServer(v199, v200)
	7.	return
end

338.	CAPTURE VAL R4

339.	
341.	v223:Connect(v225)
342.	v224 = v212.lcs
344.	v223 = v224.lc2
346.	v225 = "DMG"
347.	
349.	v223 = v223:GetMarkerReachedSignal(v225)
350.	-- V nested upvalues[0] = v203
[DUPCLOSURE] v225 = function() -- [line 181]
	1.	local v200 = v203 -- get upval
	2.	local v202 = "Combo2"
	3.	local v203 = "DMG"
	4.	
	6.	v200:FireServer(v202, v203)
	7.	return
end

351.	CAPTURE VAL R4

352.	
354.	v226:Connect(v228)
355.	v227 = v215.lcs
357.	v226 = v227.lc2
359.	v228 = "Lunge"
360.	
362.	v226 = v226:GetMarkerReachedSignal(v228)
363.	-- V nested upvalues[0] = v206
[DUPCLOSURE] v228 = function() -- [line 184]
	1.	local v203 = v206 -- get upval
	2.	local v205 = "Combo2"
	3.	local v206 = "Lunge"
	4.	
	6.	v203:FireServer(v205, v206)
	7.	return
end

364.	CAPTURE VAL R4

365.	
367.	v229:Connect(v231)
368.	v230 = v218.lcs
370.	v229 = v230.lc3
372.	v231 = "DMG"
373.	
375.	v229 = v229:GetMarkerReachedSignal(v231)
376.	-- V nested upvalues[0] = v209
[DUPCLOSURE] v231 = function() -- [line 187]
	1.	local v206 = v209 -- get upval
	2.	local v208 = "Combo3"
	3.	local v209 = "DMG"
	4.	
	6.	v206:FireServer(v208, v209)
	7.	return
end

377.	CAPTURE VAL R4

378.	
380.	v232:Connect(v234)
381.	v233 = v221.lcs
383.	v232 = v233.lc3
385.	v234 = "Lunge"
386.	
388.	v232 = v232:GetMarkerReachedSignal(v234)
389.	-- V nested upvalues[0] = v212
[DUPCLOSURE] v234 = function() -- [line 190]
	1.	local v209 = v212 -- get upval
	2.	local v211 = "Combo3"
	3.	local v212 = "Lunge"
	4.	
	6.	v209:FireServer(v211, v212)
	7.	return
end

390.	CAPTURE VAL R4

391.	
393.	v235:Connect(v237)
394.	v235 = false
395.	-- V nested upvalues[0] = v13
-- V nested upvalues[1] = v17
-- V nested upvalues[2] = v24
-- V nested upvalues[3] = v4
-- V nested upvalues[4] = v16
-- V nested upvalues[5] = v3
-- V nested upvalues[6] = v7
local function Skill1() -- [line 196]
	1.	local v213 = v13 -- get upval
	2.	local v212 = v213.skill1
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v213 = v17 -- get upval
	5.	if v213 == false then goto #46
	7.	v213 = v24 -- get upval
	8.	if v213 == false then goto #46
	10.	local v215 = 0.3
	11.	
	13.	v212:Play(v215)
	14.	v213 = true
	15.	v17 = v213 -- set upval
	16.	v213 = v4 -- get upval
	17.	v215 = "Skill1"
	18.	
	20.	v213:FireServer(v215)
	21.	v213 = task.wait
	23.	v215 = v212.Length
	25.	local v214 = v215 - 0.4
	26.	v213(v214)
	27.	v213 = false
	28.	v17 = v213 -- set upval
	29.	v213 = true
	30.	v24 = v213 -- set upval
	31.	v213 = v16 -- get upval
	32.	v215 = v3 -- get upval
	33.	local v217 = "Skill1"
	34.	
	36.	v215 = v215:WaitForChild(v217)
	37.	v214 = v215.CDframe
	39.	v217 = v7 -- get upval
	40.	local v216 = v217.Cooldowns
	42.	v215 = v216.Skill1
	44.	v213(v214, v215)
	45.	v213 = false
	46.	v24 = v213 -- set upval -- referenced by #5, #8
					end
					end
	47.	return
end
[NEWCLOSURE] v236 = Skill1
396.	CAPTURE VAL R13

397.	CAPTURE REF R17

398.	CAPTURE REF R24

399.	CAPTURE VAL R4

400.	CAPTURE VAL R16

401.	CAPTURE VAL R3

402.	CAPTURE VAL R7

403.	v258 = v245.skill1
405.	local v260 = "DMG"
406.	
408.	v258 = v258:GetMarkerReachedSignal(v260)
409.	-- V nested upvalues[0] = v236
[DUPCLOSURE] v260 = function() -- [line 211]
	1.	local v233 = v236 -- get upval
	2.	local v235 = "Skill1"
	3.	local v236 = "DMG"
	4.	
	6.	v233:FireServer(v235, v236)
	7.	return
end

410.	CAPTURE VAL R4

411.	
413.	v261:Connect(v263)
414.	v261 = false
415.	-- V nested upvalues[0] = v13
-- V nested upvalues[1] = v17
-- V nested upvalues[2] = v26
-- V nested upvalues[3] = v12
-- V nested upvalues[4] = v11
-- V nested upvalues[5] = v10
-- V nested upvalues[6] = v14
-- V nested upvalues[7] = v1
-- V nested upvalues[8] = v4
-- V nested upvalues[9] = v16
-- V nested upvalues[10] = v3
-- V nested upvalues[11] = v7
local function Skill2() -- [line 216]
	1.	local v237 = v13 -- get upval
	2.	local v236 = v237.skill2
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v237 = v17 -- get upval
	5.	if v237 == false then goto #89
	7.	v237 = v26 -- get upval
	8.	if v237 == false then goto #89
	10.	local v238 = v12 -- get upval
	11.	v237 = v238.Value
	13.	v238 = 0
	14.	if v238 >= v237 then goto #26
	16.	v238 = v11 -- get upval
	17.	v237 = v238.Value
	19.	v238 = 0
	20.	if v238 >= v237 then goto #26
	22.	v238 = v10 -- get upval
	23.	v237 = v238.Value
	25.	if v237 == 50 then goto #89
					end
					end
	27.	v238 = v14 -- get upval
	28.	v237 = v238.IsPlaying
	30.	if v237 then goto #35
	31.	v237 = v14 -- get upval
	32.	local v239 = 0.6
	33.	
	35.	v237:Stop(v239) -- referenced by #30
					end
	36.	v237 = v1 -- get upval
	37.	v239 = "HumanoidRootPart"
	38.	
	40.	v237 = v237:WaitForChild(v239)
	41.	v238 = true
	42.	v237.Anchored = v238
	44.	v239 = 0.4
	45.	
	47.	v236:Play(v239)
	48.	v237 = true
	49.	v17 = v237 -- set upval
	50.	v237 = v4 -- get upval
	51.	v239 = "Skill2"
	52.	local v240 = "Sound"
	53.	
	55.	v237:FireServer(v239, v240)
	56.	v237 = task.wait
	58.	v239 = v236.Length
	60.	v238 = v239 - 0.3
	61.	v237(v238)
	62.	v237 = v1 -- get upval
	63.	v239 = "HumanoidRootPart"
	64.	
	66.	v237 = v237:WaitForChild(v239)
	67.	v238 = false
	68.	v237.Anchored = v238
	70.	v237 = false
	71.	v17 = v237 -- set upval
	72.	v237 = true
	73.	v26 = v237 -- set upval
	74.	v237 = v16 -- get upval
	75.	v239 = v3 -- get upval
	76.	local v241 = "Skill2"
	77.	
	79.	v239 = v239:WaitForChild(v241)
	80.	v238 = v239.CDframe
	82.	v241 = v7 -- get upval
	83.	v240 = v241.Cooldowns
	85.	v239 = v240.Skill2
	87.	v237(v238, v239)
	88.	v237 = false
	89.	v26 = v237 -- set upval -- referenced by #5, #8, #25
					end
					end
					end
	90.	return
end
[NEWCLOSURE] v262 = Skill2
416.	CAPTURE VAL R13

417.	CAPTURE REF R17

418.	CAPTURE REF R26

419.	CAPTURE VAL R12

420.	CAPTURE VAL R11

421.	CAPTURE VAL R10

422.	CAPTURE VAL R14

423.	CAPTURE VAL R1

424.	CAPTURE VAL R4

425.	CAPTURE VAL R16

426.	CAPTURE VAL R3

427.	CAPTURE VAL R7

428.	v303 = v288.skill2
430.	local v305 = "Fly"
431.	
433.	v303 = v303:GetMarkerReachedSignal(v305)
434.	-- V nested upvalues[0] = v279
-- V nested upvalues[1] = v280
[DUPCLOSURE] v305 = function() -- [line 237]
	1.	local v276 = v279 -- get upval
	2.	local v278 = "Skill2"
	3.	local v279 = "Fly"
	4.	
	6.	v276:FireServer(v278, v279)
	7.	v276 = v280 -- get upval
	8.	v278 = 50
	9.	
	11.	v276:FireServer(v278)
	12.	return
end

435.	CAPTURE VAL R4

436.	CAPTURE VAL R5

437.	
439.	v308:Connect(v310)
440.	v308 = v293.skill2
442.	v310 = "DMG"
443.	
445.	v308 = v308:GetMarkerReachedSignal(v310)
446.	-- V nested upvalues[0] = v284
[DUPCLOSURE] v310 = function() -- [line 241]
	1.	local v281 = v284 -- get upval
	2.	local v283 = "Skill2"
	3.	local v284 = "DMG"
	4.	
	6.	v281:FireServer(v283, v284)
	7.	return
end

447.	CAPTURE VAL R4

448.	
450.	v311:Connect(v313)
451.	v311 = v296.skill2
453.	v313 = "GroundSlam"
454.	
456.	v311 = v311:GetMarkerReachedSignal(v313)
457.	-- V nested upvalues[0] = v287
[DUPCLOSURE] v313 = function() -- [line 244]
	1.	local v284 = v287 -- get upval
	2.	local v286 = "Skill2"
	3.	local v287 = "Slam"
	4.	
	6.	v284:FireServer(v286, v287)
	7.	return
end

458.	CAPTURE VAL R4

459.	
461.	v314:Connect(v316)
462.	-- V nested upvalues[0] = v13
-- V nested upvalues[1] = v17
-- V nested upvalues[2] = v26
-- V nested upvalues[3] = v12
-- V nested upvalues[4] = v11
-- V nested upvalues[5] = v10
-- V nested upvalues[6] = v14
-- V nested upvalues[7] = v1
-- V nested upvalues[8] = v4
local function Special() -- [line 248]
	1.	local v288 = v13 -- get upval
	2.	local v287 = v288.special
	-- DECOMPILER REMARK: Function "SetLC" was inlined here (LINE IS NOT VALID)
	4.	v288 = v17 -- get upval
	5.	if v288 == false then goto #70
	7.	v288 = v26 -- get upval
	8.	if v288 == false then goto #70
	10.	local v289 = v12 -- get upval
	11.	v288 = v289.Value
	13.	v289 = 0
	14.	if v289 >= v288 then goto #26
	16.	v289 = v11 -- get upval
	17.	v288 = v289.Value
	19.	v289 = 0
	20.	if v289 >= v288 then goto #26
	22.	v289 = v10 -- get upval
	23.	v288 = v289.Value
	25.	if v288 == 100 then goto #70
					end
					end
	27.	v289 = v14 -- get upval
	28.	v288 = v289.IsPlaying
	30.	if v288 then goto #35
	31.	v288 = v14 -- get upval
	32.	local v290 = 0.6
	33.	
	35.	v288:Stop(v290) -- referenced by #30
					end
	36.	v288 = v1 -- get upval
	37.	v290 = "HumanoidRootPart"
	38.	
	40.	v288 = v288:WaitForChild(v290)
	41.	v289 = true
	42.	v288.Anchored = v289
	44.	v290 = 0.4
	45.	
	47.	v287:Play(v290)
	48.	v288 = true
	49.	v17 = v288 -- set upval
	50.	v288 = v4 -- get upval
	51.	v290 = "Special"
	52.	
	54.	v288:FireServer(v290)
	55.	v288 = task.wait
	57.	v290 = v287.Length
	59.	v289 = v290 - 0.3
	60.	v288(v289)
	61.	v288 = v1 -- get upval
	62.	v290 = "HumanoidRootPart"
	63.	
	65.	v288 = v288:WaitForChild(v290)
	66.	v289 = false
	67.	v288.Anchored = v289
	69.	v288 = false
	70.	v17 = v288 -- set upval -- referenced by #5, #8, #25
					end
					end
					end
	71.	return
end
[NEWCLOSURE] v314 = Special
463.	CAPTURE VAL R13

464.	CAPTURE REF R17

465.	CAPTURE REF R26

466.	CAPTURE VAL R12

467.	CAPTURE VAL R11

468.	CAPTURE VAL R10

469.	CAPTURE VAL R14

470.	CAPTURE VAL R1

471.	CAPTURE VAL R4

472.	local v345 = v329.special
474.	local v347 = "Armor"
475.	
477.	v345 = v345:GetMarkerReachedSignal(v347)
478.	-- V nested upvalues[0] = v320
[DUPCLOSURE] v347 = function() -- [line 266]
	1.	local v317 = v320 -- get upval
	2.	local v319 = "Armor"
	3.	
	5.	v317:FireServer(v319)
	6.	return
end

479.	CAPTURE VAL R4

480.	
482.	v347:Connect(v349)
483.	v347 = v331.special
485.	v349 = "Fly"
486.	
488.	v347 = v347:GetMarkerReachedSignal(v349)
489.	-- V nested upvalues[0] = v322
-- V nested upvalues[1] = v323
[DUPCLOSURE] v349 = function() -- [line 269]
	1.	local v319 = v322 -- get upval
	2.	local v321 = "Special"
	3.	local v322 = "Fly"
	4.	
	6.	v319:FireServer(v321, v322)
	7.	v319 = v323 -- get upval
	8.	v321 = 100
	9.	
	11.	v319:FireServer(v321)
	12.	return
end

490.	CAPTURE VAL R4

491.	CAPTURE VAL R5

492.	
494.	v352:Connect(v354)
495.	v352 = v336.special
497.	v354 = "DMG"
498.	
500.	v352 = v352:GetMarkerReachedSignal(v354)
501.	-- V nested upvalues[0] = v327
[DUPCLOSURE] v354 = function() -- [line 273]
	1.	local v324 = v327 -- get upval
	2.	local v326 = "Special"
	3.	local v327 = "DMG"
	4.	
	6.	v324:FireServer(v326, v327)
	7.	return
end

502.	CAPTURE VAL R4

503.	
505.	v355:Connect(v357)
506.	v357 = "UpperTorso"
507.	
509.	v355 = v327:WaitForChild(v357)
510.	local v358 = game
512.	v357 = v358.Workspace
514.	v356 = v357.CurrentCamera
516.	v356.CameraSubject = v355
518.	-- V nested upvalues[0] = v329
local function EnergyChange(p6, p7) -- [line 283]
	1.	local v327 = v329 -- get upval
	2.	local v329 = p6
	3.	
	5.	v327 = v327:FindFirstChild(v329)
	6.	if not v327 then goto #11
	7.	v327 = v329 -- get upval
	8.	v329 = p6
	9.	
	11.	v327 = v327:WaitForChild(v329) -- referenced by #6
					end
	12.	local v328 = p7 / 100
	13.	local v330 = v327.Energy
	15.	v329 = v330.Energy
	17.	v330 = UDim2.new
	19.	local v331 = v328
	20.	local v332 = 0
	21.	local v333 = 1
	22.	local v334 = 0
	23.	v330 = v330(v331, v332, v333, v334)
	24.	v329.Size = v330
	26.	return
end
[DUPCLOSURE] v356 = EnergyChange
519.	CAPTURE VAL R3

520.	local v371 = "Value"
521.	
523.	v369 = v348:GetPropertyChangedSignal(v371)
524.	-- V nested upvalues[0] = v348
-- V nested upvalues[1] = v341
[DUPCLOSURE] v371 = function() -- [line 290]
	1.	local v340 = v348 -- get upval
	2.	local v339 = v340.Name
	4.	local v341 = v348 -- get upval
	5.	v340 = v341.Value
	-- DECOMPILER REMARK: Function "EnergyChange" was inlined here (LINE IS NOT VALID)
	7.	v341 = v341 -- get upval
	8.	local v343 = v339
	9.	
	11.	v341 = v341:FindFirstChild(v343)
	12.	if not v341 then goto #17
	13.	v341 = v341 -- get upval
	14.	v343 = v339
	15.	
	17.	v341 = v341:WaitForChild(v343) -- referenced by #12
					end
	18.	local v342 = v340 / 100
	19.	local v344 = v341.Energy
	21.	v343 = v344.Energy
	23.	v344 = UDim2.new
	25.	local v345 = v342
	26.	local v346 = 0
	27.	local v347 = 1
	28.	local v348 = 0
	29.	v344 = v344(v345, v346, v347, v348)
	30.	v343.Size = v344
	32.	return
end

525.	CAPTURE VAL R10

526.	CAPTURE VAL R3

527.	
529.	v385:Connect(v387)
530.	v387 = "Value"
531.	
533.	v385 = v365:GetPropertyChangedSignal(v387)
534.	-- V nested upvalues[0] = v365
-- V nested upvalues[1] = v357
[DUPCLOSURE] v387 = function() -- [line 293]
	1.	local v356 = v365 -- get upval
	2.	local v355 = v356.Name
	4.	local v357 = v365 -- get upval
	5.	v356 = v357.Value
	-- DECOMPILER REMARK: Function "EnergyChange" was inlined here (LINE IS NOT VALID)
	7.	v357 = v357 -- get upval
	8.	local v359 = v355
	9.	
	11.	v357 = v357:FindFirstChild(v359)
	12.	if not v357 then goto #17
	13.	v357 = v357 -- get upval
	14.	v359 = v355
	15.	
	17.	v357 = v357:WaitForChild(v359) -- referenced by #12
					end
	18.	local v358 = v356 / 100
	19.	local v360 = v357.Energy
	21.	v359 = v360.Energy
	23.	v360 = UDim2.new
	25.	local v361 = v358
	26.	local v362 = 0
	27.	local v363 = 1
	28.	local v364 = 0
	29.	v360 = v360(v361, v362, v363, v364)
	30.	v359.Size = v360
	32.	return
end

535.	CAPTURE VAL R11

536.	CAPTURE VAL R3

537.	
539.	v401:Connect(v403)
540.	v403 = "Value"
541.	
543.	v401 = v382:GetPropertyChangedSignal(v403)
544.	-- V nested upvalues[0] = v382
-- V nested upvalues[1] = v373
[DUPCLOSURE] v403 = function() -- [line 296]
	1.	local v372 = v382 -- get upval
	2.	local v371 = v372.Name
	4.	local v373 = v382 -- get upval
	5.	v372 = v373.Value
	-- DECOMPILER REMARK: Function "EnergyChange" was inlined here (LINE IS NOT VALID)
	7.	v373 = v373 -- get upval
	8.	local v375 = v371
	9.	
	11.	v373 = v373:FindFirstChild(v375)
	12.	if not v373 then goto #17
	13.	v373 = v373 -- get upval
	14.	v375 = v371
	15.	
	17.	v373 = v373:WaitForChild(v375) -- referenced by #12
					end
	18.	local v374 = v372 / 100
	19.	local v376 = v373.Energy
	21.	v375 = v376.Energy
	23.	v376 = UDim2.new
	25.	local v377 = v374
	26.	local v378 = 0
	27.	local v379 = 1
	28.	local v380 = 0
	29.	v376 = v376(v377, v378, v379, v380)
	30.	v375.Size = v376
	32.	return
end

545.	CAPTURE VAL R12

546.	CAPTURE VAL R3

547.	
549.	v417:Connect(v419)
550.	v417 = v392.InputBegan
552.	-- V nested upvalues[0] = v409
-- V nested upvalues[1] = v405
-- V nested upvalues[2] = v411
-- V nested upvalues[3] = v413
-- V nested upvalues[4] = v414
[DUPCLOSURE] v419 = function(p8, p9) -- [line 300]
	1.	if p9 then goto #2
	2.	return -- referenced by #1
					end
	3.	local v387 = p8.UserInputType
	5.	local v388 = Enum.UserInputType.MouseButton1
	7.	if v387 == v388 then goto #10
	9.	v387 = v409 -- get upval
	10.	v387(v388) -- referenced by #7
					end
	11.	v387 = p8.KeyCode
	13.	v388 = Enum.KeyCode.R
	15.	if v387 == v388 then goto #18
	17.	v387 = v405 -- get upval
	18.	v387(v388) -- referenced by #15
					end
	19.	v387 = p8.KeyCode
	21.	v388 = Enum.KeyCode.One
	23.	if v387 == v388 then goto #26
	25.	v387 = v411 -- get upval
	26.	v387(v388) -- referenced by #23
					end
	27.	v387 = p8.KeyCode
	29.	v388 = Enum.KeyCode.Two
	31.	if v387 == v388 then goto #34
	33.	v387 = v413 -- get upval
	34.	v387(v388) -- referenced by #31
					end
	35.	v387 = p8.KeyCode
	37.	v388 = Enum.KeyCode.X
	39.	if v387 == v388 then goto #42
	41.	v387 = v414 -- get upval
	42.	v387(v388) -- referenced by #39
					end
	43.	return
end

553.	CAPTURE VAL R23

554.	CAPTURE VAL R19

555.	CAPTURE VAL R25

556.	CAPTURE VAL R27

557.	CAPTURE VAL R28

558.	
560.	v432:Connect(v434)
561.	local v435 = "Roar"
562.	
564.	v433 = v404:WaitForChild(v435)
565.	v432 = v433.MouseButton1Click
567.	v434 = v420
568.	
570.	v432:Connect(v434)
571.	v435 = "Skill1"
572.	
574.	v433 = v404:WaitForChild(v435)
575.	v432 = v433.MouseButton1Click
577.	v434 = v426
578.	
580.	v432:Connect(v434)
581.	v435 = "Skill2"
582.	
584.	v433 = v404:WaitForChild(v435)
585.	v432 = v433.MouseButton1Click
587.	v434 = v428
588.	
590.	v432:Connect(v434)
591.	v435 = "Special"
592.	
594.	v433 = v404:WaitForChild(v435)
595.	v432 = v433.MouseButton1Click
597.	v434 = v429
598.	
600.	v432:Connect(v434)
601.	[CLOSEUPVALS]: clear captures from back until: 17
602.	return
