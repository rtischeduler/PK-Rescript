--[[
	BuildingSystemInstaller
	Directly sets up the death/sink/revive lifecycle for every building
	in the Buildings folder. No runtime-created scripts needed —
	all logic runs from this single script context.
]]

local BuildingLifecycle = require(script.Parent.BuildingLifecycle)

local buildingsFolder = workspace:FindFirstChild("Buildings")
if not buildingsFolder then
	warn("BuildingSystemInstaller: Buildings folder not found in Workspace")
	return
end

local function installIntoBuilding(building)
	if not building:IsA("Model") then return end
	-- Skip if already set up (prevents double-connecting Died events)
	if building:GetAttribute("LifecycleInstalled") then return end
	building:SetAttribute("LifecycleInstalled", true)
	BuildingLifecycle.setup(building)
end

-- Install into all existing buildings
for _, building in buildingsFolder:GetChildren() do
	installIntoBuilding(building)
end

-- Handle buildings added later during gameplay
buildingsFolder.ChildAdded:Connect(function(child)
	task.wait(0.5)
	installIntoBuilding(child)
end)