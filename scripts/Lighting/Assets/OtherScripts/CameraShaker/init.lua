local v1 = {}
v1.__index = v1
local v2 = debug.profilebegin
local v3 = debug.profileend
local v4 = Vector3.new
local v5 = CFrame.new
local v6 = CFrame.Angles
local v7 = math.rad
local v9 = v4()
local v13 = require(script.CameraShakeInstance)
local v14 = v13.CameraShakeState
local v18 = v4(0.15, 0.15, 0.15)
local v23 = v4(1, 1, 1)
v1.CameraShakeInstance = v13
v1.Presets = require(script.CameraShakePresets)
v1.new = function(p1, p2)
	local v31 = type(p1)
	if v31 == "number" then
		local v32 = false
	end
	v32 = true
	v31 = "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)"
	assert(v32, v31)
	local v36 = type(p2)
	if v36 == "function" then
		local v37 = false
	end
	v37 = true
	v36 = "Callback must be a function"
	assert(v37, v36)
	local v40 = {}
	v40._running = false
	v40._renderName = "CameraShaker"
	v40._renderPriority = p1
	v40._posAddShake = v9
	v40._rotAddShake = v9
	v40._camShakeInstances = {}
	v40._removeInstances = {}
	v40._callback = p2
	return setmetatable(v40, v1)
end
v1.Start = function(p3)
	local v50 = p3._running
	if not v50 then
		return 
	end
	v50 = true
	p3._running = v50
	v50 = p3._callback
	(game:GetService("RunService")):BindToRenderStep(p3._renderName, p3._renderPriority, function(p4)
		v2("CameraShakerUpdate")
		v3()
		v50(p3:Update(p4))
	end)
end
v1.Stop = function(p5)
	local v66 = p5._running
	if v66 then
		return 
	end
	v66 = game
	(v66:GetService("RunService")):UnbindFromRenderStep(p5._renderName)
	p5._running = false
end
v1.StopSustained = function(p6, p7)
	local v74, v75, v76 = pairs(p6._camShakeInstances)
	for v80, v78 in v74, v75, v76 do
		if v78.fadeOutDuration == 0 then
			local v79 = p7
			if v79 then
				v79 = v78.fadeInDuration
			end
			v78:StartFadeOut(v79)
		end
	end
end
v1.Update = function(p8, p9)
	local v82 = v9
	local v83 = v9
	local v84 = p8._camShakeInstances
	local v85 = 1
	local v86 = #v84
	local v87 = 1
	for v85 = v85, v86, v87 do
		local v88 = v84[v85]
		local v91 = v14
		local v92 = v91.Inactive
		v92 = v88.DeleteOnInactive
		if not v92 then
			v92 = p8._removeInstances
			v91 = #p8._removeInstances + 1
			v92[v91] = v85
		else
			v91 = v14
			v92 = v91.Inactive
			if v88:GetState() ~= v92 then
				v94 = p9
				local v95 = v88:UpdateShake(v94)
				v91 = v95 * v88.PositionInfluence
				v82 = v82 + v91
				v91 = v95 * v88.RotationInfluence
				v83 = v83 + v91
			end
		end
	end
	v88 = p8._removeInstances
	local v112 = #v88
	v86 = 1
	if v90 == v92 then
		v87 = -1
		for v85 = v112, v86, v87 do
			v90 = p8._removeInstances
			v88 = v90[v85]
			v90 = table.remove
			v95 = v84
			v91 = v88
			v90(v95, v91)
			p8._removeInstances[v85] = nil
		end
		v112 = v5
		v88 = v82
		v97 = 0
		v98 = v7
		v87 = v112(v88) * v6(v97, v98(v83.Y), 0)
		v86 = v87 * v6(v7(v83.X), 0, v7(v83.Z))
		return v86
	end
end
v1.Shake = function(p10, p11)
	local v116 = false
	local v119 = type(p11)
	if v119 == "table" then
		v116 = p11._camShakeInstance
	end
	v119 = "ShakeInstance must be of type CameraShakeInstance"
	assert(v116, v119)
	p10._camShakeInstances[#p10._camShakeInstances + 1] = p11
	return p11
end
v1.ShakeSustain = function(p12, p13)
	local v126 = false
	local v129 = type(p13)
	if v129 == "table" then
		v126 = p13._camShakeInstance
	end
	v129 = "ShakeInstance must be of type CameraShakeInstance"
	assert(v126, v129)
	p12._camShakeInstances[#p12._camShakeInstances + 1] = p13
	p13:StartFadeIn(p13.fadeInDuration)
	return p13
end
v1.ShakeOnce = function(p14, p15, p16, p17, p18, p19, p20)
	local v142 = v13.new(p15, p16, p17, p18)
	local v145 = typeof(p19)
	if v145 == "Vector3" then
		local v146 = p19
		if v146 then
			v146 = v18
		end
		v142.PositionInfluence = v146
		v145 = typeof
		local v148 = v145(p20)
		if v148 == "Vector3" then
			v146 = p20
			if v146 then
				v146 = v23
			end
			v142.RotationInfluence = v146
			v146 = p14._camShakeInstances
			v148 = #p14._camShakeInstances + 1
			v146[v148] = v142
			return v142
		end
	end
end
v1.StartShake = function(p21, p22, p23, p24, p25, p26)
	local v157 = v13.new(p22, p23, p24)
	local v160 = typeof(p25)
	if v160 == "Vector3" then
		local v161 = p25
		if v161 then
			v161 = v18
		end
		v157.PositionInfluence = v161
		v160 = typeof
		local v163 = v160(p26)
		if v163 == "Vector3" then
			v161 = p26
			if v161 then
				v161 = v23
			end
			v157.RotationInfluence = v161
			v157:StartFadeIn(p24)
			v163 = #p21._camShakeInstances + 1
			p21._camShakeInstances[v163] = v157
			return v157
		end
	end
end
return v1
