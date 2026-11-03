local v1 = {}
v1.run_service = game:GetService("RunService")
local v31 = script.Parent
local v7 = v31:WaitForChild("fps_label")
local v10 = v31:WaitForChild("update_rate")
local v11 = v10.Value
local v12 = 0.25
if v11 > 0 then
	v12 = 2
	if v11 > v12 then
		v10 = 1
	else
		v10 = v11
	end
	v11 = v10
	v10 = 0
	local v14 = tick()
	v12 = v14 - v11
	v14 = 1 / v11
	v1.run_service.RenderStepped:Connect(function()
		v10 = v10 + 1
		local v20 = v12
		local v21 = tick() - v20
		local v30 = v11
		if v21 >= v30 then
			v21 = v7
			v20 = tostring(math.round(v10 * v14))
			v30 = v20 .. " FPS"
			v21.Text = v30
			v10 = 0
			v12 = tick()
			return 
		end
	end)
	return 
end
