local v4 = game.Players.LocalPlayer.Character
local v6 = require(v4:WaitForChild("Settings"))
local v12 = require(game.ReplicatedStorage.Assets.Kaijus.OtherScripts:WaitForChild("CameraShaker"))
local v17 = require(game.ReplicatedStorage.Assets.Kaijus.OtherScripts.CameraShaker:WaitForChild("CameraShakeInstance"))
local v22 = require(script.Parent.Parent:WaitForChild("UIFunctions"))
local v25 = script.Parent.Parent:WaitForChild("Control")
local v26 = game:GetService("TweenService")
local v28 = workspace.CurrentCamera
local function ShakeCam_1(p1, p2, p3, p4, p5, p6, p7, p8)
	local v30 = game
	local v31 = v30.Players
	local v32 = v31.LocalPlayer
	local v33 = v32.Settings
	local v34 = v33.UI
	local v35 = v34.ScreenShake
	local v36 = v35.Value
	if v36 == true then
		v35 = v12
		v36 = v35.new
		v34 = Enum.RenderPriority.Camera
		v35 = v34.Value
		v34 = function(p9)
			v28.CFrame = v28.CFrame * p9
		end
		local v41 = v36(v35, v34)
		if p6 == true then
			v31 = game
			v32 = v31.Lighting
			v33 = v32.DefaultBlur
			v32 = TweenInfo.new
			v31 = 0.25
			local v44 = {}
			v44.Size = p7
			v26:Create(v33, v32(v31), v44):Play()
		end
	
	
		v41:Start()
		v41:Shake(v12.Presets.ShakeSize)
		v30 = p4
		v41:ShakeOnce(p1, p2, p3, v30)
		v41:ShakeSustain(v12.Presets.ShakeSize)
		v41:StopSustained(p4)
		local v86 = v12
		wait(p4)
		v41:ShakeSustain(v86.Presets.ShakeSize):StartFadeOut(p4)
		if p6 == true then
			wait(p8 * 0.5)
			v86 = game.Lighting
			v86 = TweenInfo.new
			local v71 = {}
			v71.Size = 3
			(v26:Create(v86.DefaultBlur, v86(0.35), v71)):Play()
		end
	end
end
v25.Values.Actions.Roaring.Changed:Connect(function()
	local v95 = v25
	local v96 = v95.Values
	local v97 = v96.Actions
	local v98 = v97.Roaring
	local v99 = v98.Value
	if v99 == true then
		v96 = script
		v97 = v96.CooldownsTime
		v98 = v97.ScreenShaking
		v99 = v98.Value
		if v99 == false then
			v99 = wait
			v97 = v6
			v98 = v97.RoarStartTime
			v99(v98)
			v97 = 50
			v96 = 0
			v95 = v6.RoarTime * 0.515
			ShakeCam_1(0.45, v97, v96, v95, 0.25, true, v6.RoarBlur, v6.RoarTime)
		end
	end
end)
v4:WaitForChild("Aspects").Info.Health.Changed:Connect(function()
	ShakeCam_1(0.35, 15, 0, 0.2, 0.25, false, 0, 0)
end)
v4.HumanoidRootPart.Smack.Played:Connect(function()
	local v123 = v4
	local v126 = v123.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
	if not v126 then
		v126 = ShakeCam_1
		v123 = 0.35
		v126(v123, 25, 0, 0.2, 0.25, false, 0, 0)
	end
end)
v4.HumanoidRootPart.Gash.Played:Connect(function()
	local v136 = v4
	local v139 = v136.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
	if not v139 then
		v139 = ShakeCam_1
		v136 = 0.35
		v139(v136, 18, 0, 0.2, 0.25, false, 0, 0)
	end
end)
v4.HumanoidRootPart.Hit.Played:Connect(function()
	local v149 = v4
	local v152 = v149.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
	if not v152 then
		v152 = ShakeCam_1
		v149 = 0.35
		v152(v149, 21, 0, 0.2, 0.25, false, 0, 0)
	end
end)
v4.HumanoidRootPart.Stomp.Played:Connect(function()
	local v162 = v4
	local v165 = v162.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
	if not v165 then
		v165 = ShakeCam_1
		v162 = 0.35
		v165(v162, 50, 0, 0.3, 0.25, false, 0, 0)
	end
end)
v4.StunItems.GrabbedBuildings.ChildAdded:Connect(function()
	local v175 = v4
	local v178 = v175.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
	if not v178 then
		v178 = ShakeCam_1
		v175 = 0.35
		v178(v175, 30, 0, 0.3, 0.25, false, 0, 0)
	end
end)
local v235 = v4.StunItems.GrabbedBuildings
v235.ChildRemoved:Connect(function()
	local v188 = v4
	local v191 = v188.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
	if not v191 then
		v191 = ShakeCam_1
		v188 = 0.4
		v191(v188, 45, 0, 0.3, 0.25, false, 0, 0)
	end
end)
while true do
	wait()
	v235 = v4.Humanoid
	v235 = Enum.Material.Air
	if v235.FloorMaterial == v235 then
		break
	end
end
v200 = ShakeCam_1
v235 = 0.55
v200(v235, 55, 0, 0.2, 0.25, false, 0, 0)
