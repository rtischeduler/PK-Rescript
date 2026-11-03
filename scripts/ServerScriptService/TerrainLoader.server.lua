local TerrainLoader = {}

-- Services
local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain

-- Configuration
local TERRAIN_DATA_FOLDER = "TerrainData"
local PASTE_EMPTY_CELLS = false -- CRITICAL: false = combine/merge, true = overwrite (deletes existing terrain)

-- Applies water properties from a TerrainRegion's WaterProperties folder to the terrain.
-- Skips regions where WaterTransparency is 1 (fully invisible), since those regions
-- have no visible water and should not override water settings from regions that do.
local function applyWaterProperties(terrainRegion)
	local waterProps = terrainRegion:FindFirstChild("WaterProperties")
	if not waterProps then return end

	local waterTransparency = waterProps:FindFirstChild("WaterTransparency")
	if waterTransparency and waterTransparency:IsA("NumberValue") then
		-- Skip this region if water is fully transparent (no visible water)
		if waterTransparency.Value >= 1 then
			print("[TerrainLoader] Skipping water properties for " .. terrainRegion.Name .. " (WaterTransparency = 1, no visible water)")
			return
		end
		Terrain.WaterTransparency = 1 -- Force all water fully transparent
	end

	local waterColor = waterProps:FindFirstChild("WaterColor")
	if waterColor and waterColor:IsA("Color3Value") then
		Terrain.WaterColor = waterColor.Value
	end

	local waterReflectance = waterProps:FindFirstChild("WaterReflectance")
	if waterReflectance and waterReflectance:IsA("NumberValue") then
		Terrain.WaterReflectance = waterReflectance.Value
	end

	local waterWaveSize = waterProps:FindFirstChild("WaterWaveSize")
	if waterWaveSize and waterWaveSize:IsA("NumberValue") then
		Terrain.WaterWaveSize = waterWaveSize.Value
	end

	local waterWaveSpeed = waterProps:FindFirstChild("WaterWaveSpeed")
	if waterWaveSpeed and waterWaveSpeed:IsA("NumberValue") then
		Terrain.WaterWaveSpeed = waterWaveSpeed.Value
	end
end

-- Applies material colors from a TerrainRegion's MaterialColors folder to the terrain
local function applyMaterialColors(terrainRegion)
	local matColors = terrainRegion:FindFirstChild("MaterialColors")
	if not matColors then return end

	for _, child in matColors:GetChildren() do
		if child:IsA("Color3Value") then
			local materialName = child.Name
			local success, materialEnum = pcall(function()
				return Enum.Material[materialName]
			end)
			if success and materialEnum then
				Terrain:SetMaterialColor(materialEnum, child.Value)
			end
		end
	end
end

-- Main loading function: combines all TerrainRegion chunks from TerrainData without overwriting existing terrain
function TerrainLoader.LoadAll()
	local terrainData = Lighting:FindFirstChild(TERRAIN_DATA_FOLDER)
	if not terrainData then
		warn("[TerrainLoader] No '" .. TERRAIN_DATA_FOLDER .. "' folder found in Lighting.")
		return
	end

	local regions = {}
	for _, child in terrainData:GetChildren() do
		if child:IsA("TerrainRegion") then
			table.insert(regions, child)
		end
	end

	if #regions == 0 then
		warn("[TerrainLoader] No TerrainRegion instances found in " .. TERRAIN_DATA_FOLDER)
		return
	end

	-- Sort by name for consistent loading order
	table.sort(regions, function(a, b)
		return a.Name < b.Name
	end)

	local corner = Terrain.MaxExtents.Min -- Paste at the terrain origin corner

	for i, region in regions do
		print("[TerrainLoader] Loading terrain chunk: " .. region.Name .. " (" .. tostring(region.SizeInCells) .. ")")

		-- Paste with pasteEmptyCells = false so empty cells don't delete existing terrain
		Terrain:PasteRegion(region, corner, PASTE_EMPTY_CELLS)

		-- Apply water properties and material colors (later maps override earlier ones)
		applyWaterProperties(region)
		applyMaterialColors(region)

		print("[TerrainLoader] Loaded " .. region.Name .. " (" .. i .. "/" .. #regions .. ")")
	end

	-- Remove all water voxels by replacing Water material with Air in chunks
	local chunkSize = 512
	for x = -2048, 2048 - chunkSize, chunkSize do
		for y = -256, 256 - chunkSize, chunkSize do
			for z = -2048, 2048 - chunkSize, chunkSize do
				pcall(function()
					local region = Region3.new(
						Vector3.new(x, y, z),
						Vector3.new(x + chunkSize, y + chunkSize, z + chunkSize)
					):ExpandToGrid(4)
					Terrain:ReplaceMaterial(region, 4, Enum.Material.Water, Enum.Material.Air)
				end)
			end
		end
	end

	-- Also set water transparency to 1 as a backup
	Terrain.WaterTransparency = 1

	print("[TerrainLoader] All " .. #regions .. " terrain chunks combined successfully! Water removed.")
end

-- Run on server start
TerrainLoader.LoadAll()

return TerrainLoader