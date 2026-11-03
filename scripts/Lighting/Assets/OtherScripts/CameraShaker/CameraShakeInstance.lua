local v1 = {}
v1.__index = v1
local v2 = Vector3.new
local v3 = math.noise
local v4 = {}
v4.FadingIn = 0
v4.FadingOut = 1
v4.Sustained = 2
v4.Inactive = 3
v1.CameraShakeState = v4
v1.new = function(p1, p2, p3, p4)
	if p3 == nil then
		p3 = 0
	end
	if p4 == nil then
		p4 = 0
	end
	local v9 = type(p1)
	if v9 == "number" then
		local v10 = false
	end
	v10 = true
	v9 = "Magnitude must be a number"
	assert(v10, v9)
	local v14 = type(p2)
	if v14 == "number" then
		local v15 = false
	end
	v15 = true
	v14 = "Roughness must be a number"
	assert(v15, v14)
	local v19 = type(p3)
	if v19 == "number" then
		local v20 = false
	end
	v20 = true
	v19 = "FadeInTime must be a number"
	assert(v20, v19)
	local v24 = type(p4)
	if v24 == "number" then
		local v25 = false
	end
	v25 = true
	v24 = "FadeOutTime must be a number"
	assert(v25, v24)
	local v28 = {}
	v28.Magnitude = p1
	v28.Roughness = p2
	v28.PositionInfluence = v2()
	v28.RotationInfluence = v2()
	v28.DeleteOnInactive = true
	v28.roughMod = 1
	local v41 = 1
	v28.magnMod = v41
	v28.fadeOutDuration = p4
	v28.fadeInDuration = p3
	local v32 = 0
	if v32 <= p3 then
		v41 = false
	end
	local v42 = true
	v28.sustain = v42
	v32 = 0
	if p3 > v32 then
		v42 = 0
	else
		v42 = 1
	end
	v28.currentFadeTime = v42
	v28.tick = (Random.new()):NextNumber(-100, 100)
	v28._camShakeInstance = true
	return setmetatable(v28, v1)
end
v1.UpdateShake = function(p5, p6)
	local v47 = p5.tick
	local v48 = p5.currentFadeTime
	local v61 = v3(v47, v47)
	local v64 = p5.fadeInDuration
	local v65 = 0
	if v64 > v65 then
		v64 = p5.sustain
		if not v64 then
			v64 = 1
			if v64 > v48 then
				v65 = p5.fadeInDuration
				v64 = p6 / v65
				v48 = v48 + v64
			else
				v64 = p5.fadeOutDuration
				v65 = 0
				if v64 > v65 then
					v64 = false
					p5.sustain = v64
				end
			end
		end
	end
	local v70 = p5.sustain
	if v70 then
		v65 = p5.fadeOutDuration
		v70 = p6 / v65
		v48 = v48 - v70
	end
	local v71 = p5.sustain
	if not v71 then
		v61 = p5.Roughness
		v61 = p5.roughMod
		v65 = p6 * v61 * v61
		v71 = v47 + v65
		p5.tick = v71
	else
		v61 = p6 * p5.Roughness
		v66 = v61 * p5.roughMod
		v65 = v66 * v48
		v71 = v47 + v65
		p5.tick = v71
	end
	p5.currentFadeTime = v48
	v66 = v2(v3(v47, 0) * 0.5, v3(0, v47) * 0.5, v61 * 0.5) * p5.Magnitude
	return v66 * p5.magnMod * v48
end
v1.StartFadeOut = function(p7, p8)
	if p8 == 0 then
		p7.currentFadeTime = 0
	end
	p7.fadeOutDuration = p8
	v78 = 0
	p7.fadeInDuration = v78
	v78 = false
	p7.sustain = v78
end
v1.StartFadeIn = function(p9, p10)
	if p10 == 0 then
		p9.currentFadeTime = 1
	end
	v80 = p10
	if v80 then
		v80 = p9.fadeInDuration
	end
	p9.fadeInDuration = v80
	v80 = 0
	p9.fadeOutDuration = v80
	v80 = true
	p9.sustain = v80
end
v1.GetScaleRoughness = function(p11)
	return p11.roughMod
end
v1.SetScaleRoughness = function(p12, p13)
	p12.roughMod = p13
end
v1.GetScaleMagnitude = function(p14)
	return p14.magnMod
end
v1.SetScaleMagnitude = function(p15, p16)
	p15.magnMod = p16
end
v1.GetNormalizedFadeTime = function(p17)
	return p17.currentFadeTime
end
v1.IsShaking = function(p18)
	local v90 = true
	if 0 <= p18.currentFadeTime then
		v90 = p18.sustain
	end
	return v90
end
v1.IsFadingOut = function(p19)
	local v94 = p19.sustain
	local v95 = not v94
	if not v95 then
		v94 = p19.currentFadeTime
		if 0 <= v94 then
			v95 = false
		end
		v95 = true
	end
	return v95
end
v1.IsFadingIn = function(p20)
	local v98 = false
	local v99 = p20.currentFadeTime
	local v100 = 1
	if v100 > v99 then
		v98 = p20.sustain
		if not v98 then
			v99 = p20.fadeInDuration
			v100 = 0
			if v100 <= v99 then
				v98 = false
			end
			v98 = true
		end
	end
	return v98
end
v1.GetState = function(p21)
	local v103 = p21:IsFadingIn()
	if not v103 then
		v103 = v1.CameraShakeState.FadingIn
		return v103
	end
	local v107 = p21:IsFadingOut()
	if not v107 then
		v104 = v1
		v105 = v104.CameraShakeState
		v107 = v105.FadingOut
		return v107
	end
	local v109 = p21:IsShaking()
	if not v109 then
		v104 = v1
		v105 = v104.CameraShakeState
		v109 = v105.Sustained
		return v109
	end
	v104 = v1
	v105 = v104.CameraShakeState
	return v105.Inactive
end
return v1
