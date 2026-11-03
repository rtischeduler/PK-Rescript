local v5 = require(script.Parent.CameraShakeInstance)
local v6 = {}
v6.Bump = function()
	local v13 = v5.new(2.5, 4, 0.1, 0.75)
	v13.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
	v13.RotationInfluence = Vector3.new(1, 1, 1)
	return v13
end
v6.ShakeSize = function()
	local v40 = v5.new(game.Players.LocalPlayer.PlayerGui.GameGui.UIFunctions.FireFunctions.Values.Size.Value, game.Players.LocalPlayer.PlayerGui.GameGui.UIFunctions.FireFunctions.Values.Intensity.Value, game.Players.LocalPlayer.PlayerGui.GameGui.UIFunctions.FireFunctions.Values.StartSpeed.Value, game.Players.LocalPlayer.PlayerGui.GameGui.UIFunctions.FireFunctions.Values.StopSpeed.Value)
	v40.PositionInfluence = Vector3.new(game.Players.LocalPlayer.PlayerGui.GameGui.UIFunctions.FireFunctions.Values.InfSize1.Value, game.Players.LocalPlayer.PlayerGui.GameGui.UIFunctions.FireFunctions.Values.InfSize1.Value, game.Players.LocalPlayer.PlayerGui.GameGui.UIFunctions.FireFunctions.Values.InfSize1.Value)
	v40.RotationInfluence = Vector3.new(4, 1, 1)
	return v40
end
v6.Explosion = function()
	local v112 = v5.new(5, 10, 0, 1.5)
	v112.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
	v112.RotationInfluence = Vector3.new(4, 1, 1)
	return v112
end
v6.Earthquake = function()
	local v130 = v5.new(0.6, 3.5, 2, 10)
	v130.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
	v130.RotationInfluence = Vector3.new(1, 1, 4)
	return v130
end
v6.BadTrip = function()
	local v148 = v5.new(10, 0.15, 5, 10)
	v148.PositionInfluence = Vector3.new(0, 0, 0.15)
	v148.RotationInfluence = Vector3.new(2, 1, 4)
	return v148
end
v6.HandheldCamera = function()
	local v166 = v5.new(1, 0.25, 5, 10)
	v166.PositionInfluence = Vector3.new(0, 0, 0)
	v166.RotationInfluence = Vector3.new(1, 0.5, 0.5)
	return v166
end
v6.Vibration = function()
	local v184 = v5.new(0.4, 20, 2, 2)
	v184.PositionInfluence = Vector3.new(0, 0.15, 0)
	v184.RotationInfluence = Vector3.new(1.25, 0, 4)
	return v184
end
local function RoughDriving_1()
	local v202 = v5.new(1, 2, 1, 1)
	v202.PositionInfluence = Vector3.new(0, 0, 0)
	v202.RotationInfluence = Vector3.new(1, 1, 1)
	return v202
end
v6.RoughDriving = RoughDriving_1
RoughDriving_1 = setmetatable
local v214 = {}
v214.__index = function(p1, p2)
	local v218 = v6[p2]
	local v220 = type(v218)
	if v220 == "function" then
		v220 = v218
		return v220()
	end
	error('No preset found with index "' .. p2 .. '"')
end
return RoughDriving_1({}, v214)
