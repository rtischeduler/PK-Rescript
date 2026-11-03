-- WaterTextureAnimation: Scrolls the OffsetStudsU/V on all waterspot Texture instances for a flowing water effect

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Animation speed (studs per second)
local SPEED_U = 1.5
local SPEED_V = 1.0

local offsetU = 0
local offsetV = 0

-- Collect all Texture instances parented to waterspot parts
local textures = {}
local function refreshTextures()
	textures = {}
	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("Texture") then
			local parent = descendant.Parent
			if parent and string.lower(parent.Name) == "waterspot" then
				table.insert(textures, descendant)
			end
		end
	end
end

refreshTextures()

-- Also refresh periodically to catch newly loaded map parts
local function isWaterspotTexture(descendant)
	if descendant:IsA("Texture") then
		local parent = descendant.Parent
		return parent and string.lower(parent.Name) == "waterspot"
	end
	return false
end

Workspace.DescendantAdded:Connect(function(descendant)
	if isWaterspotTexture(descendant) then
		table.insert(textures, descendant)
	end
end)

RunService.RenderStepped:Connect(function(dt)
	offsetU = offsetU + SPEED_U * dt
	offsetV = offsetV + SPEED_V * dt
	for _, texture in textures do
		if texture.Parent then
			texture.OffsetStudsU = offsetU
			texture.OffsetStudsV = offsetV
		end
	end
end)