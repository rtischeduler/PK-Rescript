local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Get BeamColors parts with "blue" in the name (these are the ones that pulse via transparency)
local function getBeamColorParts(character)
	local folder = character:FindFirstChild("BeamColors")
	if not folder then return {} end
	local parts = {}
	for _, desc in ipairs(folder:GetDescendants()) do
		if desc:IsA("BasePart") and string.find(string.lower(desc.Name), "blue") then
			table.insert(parts, desc)
		end
	end
	return parts
end

-- Get all Light objects inside BeamColors.Light model
local function getBeamColorLights(character)
	local folder = character:FindFirstChild("BeamColors")
	if not folder then return {} end
	local lightModel = folder:FindFirstChild("Light")
	if not lightModel then return {} end
	local lights = {}
	for _, desc in ipairs(lightModel:GetDescendants()) do
		if desc:IsA("Light") then
			table.insert(lights, desc)
		end
	end
	return lights
end

local function setupPulsate(character)
	local aspects = character:FindFirstChild("Aspects")
	if not aspects then return end
	local info = aspects:FindFirstChild("Info")
	if not info then return end
	local rageVal = info:FindFirstChild("Rage")
	if not rageVal or not rageVal:IsA("NumberValue") then return end
	local maxRageVal = rageVal:FindFirstChild("MaxRage")
	if not maxRageVal or not maxRageVal:IsA("NumberValue") then return end

	local pulsating = false
	local stopFlag = false
	local originalData = {}

	local function saveOriginals()
		for _, part in ipairs(getBeamColorParts(character)) do
			if not originalData[part] then
				originalData[part] = {material = part.Material, transparency = part.Transparency}
			end
		end
		for _, light in ipairs(getBeamColorLights(character)) do
			if not originalData[light] then
				originalData[light] = {enabled = light.Enabled, brightness = light.Brightness}
			end
		end
	end

	local function restoreOriginals()
		for part, data in pairs(originalData) do
			if part and part.Parent then
				if part:IsA("Light") then
					local tween = TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Brightness = data.brightness
					})
					tween:Play()
					tween.Completed:Connect(function()
						if part and part.Parent then
							part.Enabled = data.enabled
						end
					end)
				elseif part:IsA("BasePart") then
					local tween = TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = data.transparency
					})
					tween:Play()
					tween.Completed:Connect(function()
						if part and part.Parent then
							part.Material = data.material
						end
					end)
				end
			end
		end
	end

	local function pulsateLoop()
		-- Slow breathing: 2s fade in, 2s fade out, repeating
		local breatheInInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local breatheOutInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

		while not stopFlag do
			-- Breathe IN: slowly tween all parts to visible + Neon, lights brighten
			for _, part in ipairs(getBeamColorParts(character)) do
				if part and part.Parent then
					part.Material = Enum.Material.Neon
					local tween = TweenService:Create(part, breatheInInfo, {Transparency = 0.6})
					tween:Play()
				end
			end
			for _, light in ipairs(getBeamColorLights(character)) do
				if light and light.Parent then
					light.Enabled = true
					local tween = TweenService:Create(light, breatheInInfo, {Brightness = 3})
					tween:Play()
				end
			end

			task.wait(2)
			if stopFlag then break end

			-- Breathe OUT: slowly tween all parts back to original transparency, lights dim
			for _, part in ipairs(getBeamColorParts(character)) do
				if part and part.Parent then
					local orig = originalData[part]
					local targetTrans = orig and orig.transparency or 1
					local tween = TweenService:Create(part, breatheOutInfo, {Transparency = targetTrans})
					tween:Play()
					tween.Completed:Connect(function()
						if part and part.Parent and orig then
							part.Material = orig.material
						end
					end)
				end
			end
			for _, light in ipairs(getBeamColorLights(character)) do
				if light and light.Parent then
					local tween = TweenService:Create(light, breatheOutInfo, {Brightness = 0})
					tween:Play()
				end
			end

			task.wait(2)
			if stopFlag then break end
		end
	end

	local function startPulsate()
		if pulsating then return end
		pulsating = true
		stopFlag = false
		saveOriginals()
		task.spawn(pulsateLoop)
	end

	local function stopPulsate()
		pulsating = false
		stopFlag = true
		restoreOriginals()
	end

	local function checkRage()
		if rageVal.Value >= maxRageVal.Value then
			startPulsate()
		else
			stopPulsate()
		end
	end

	rageVal.Changed:Connect(checkRage)
	maxRageVal.Changed:Connect(checkRage)
	checkRage()

	task.spawn(function()
		while character and character.Parent do
			task.wait(1)
			if rageVal.Value >= maxRageVal.Value and not pulsating then
				startPulsate()
			elseif rageVal.Value < maxRageVal.Value and pulsating then
				stopPulsate()
			end
		end
		stopPulsate()
	end)
end

local function onCharacterAdded(character)
	task.wait(0.5)
	if not character or not character.Parent then return end
	local aspects = character:FindFirstChild("Aspects")
	if not aspects then return end
	local info = aspects:FindFirstChild("Info")
	if not info then return end
	local rageVal = info:FindFirstChild("Rage")
	if not rageVal then return end
	setupPulsate(character)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end