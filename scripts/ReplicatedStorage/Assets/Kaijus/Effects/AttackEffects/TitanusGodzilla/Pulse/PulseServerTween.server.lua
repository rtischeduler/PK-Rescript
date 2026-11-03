--[[
	Server-sided Pulse Attack Effect for TitanusGodzilla
	Reads tween configuration from the model's value objects
	and animates the explosion/pulse using TweenService on the server.
	
	Effect parts: Sphere, Sphere2, Shock, Shockwave
	Each part has config values: Delay, Speed, EasingStyle, TransparencyDelay, TransparencySpeed, Flatten
	Target sizes come from the EndCFrame child of each part.
	Particles are enabled and burst during the effect.
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local model = script.Parent

-- Parse easing style name to enum
local function getEasingStyle(name)
	if name and type(name) == "string" and #name > 0 then
		local ok, result = pcall(function()
			return Enum.EasingStyle[name]
		end)
		if ok then
			return result
		end
	end
	return Enum.EasingStyle.Circular
end

-- Main effect logic
local function runEffect()
	-- Read configuration from the TweenScript folder
	local tweenFolder = model:FindFirstChild("TweenScript")
	local char = nil
	local delayTime = 0
	local particleTime = 0.35
	local targetCFrame = nil

	if tweenFolder then
		local charVal = tweenFolder:FindFirstChild("Char")
		if charVal then
			char = charVal.Value
		end

		local delayVal = tweenFolder:FindFirstChild("DelayTime")
		if delayVal then
			delayTime = delayVal.Value
		end

		local ptVal = tweenFolder:FindFirstChild("ParticleTime")
		if ptVal then
			particleTime = ptVal.Value
		end

		local cfVal = tweenFolder:FindFirstChild("CFrame")
		if cfVal then
			targetCFrame = cfVal.Value
		end
	end

	-- Position the model at the target location
	if targetCFrame then
		model:PivotTo(targetCFrame)
	elseif char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			model:PivotTo(hrp.CFrame)
		end
	end

	-- Apply initial delay
	if delayTime > 0 then
		task.wait(delayTime)
	end

	-- Process each effect part in animation order
	local effectPartNames = {"Sphere", "Sphere2", "Shock", "Shockwave"}
	local maxTotalTime = 0

	for _, partName in effectPartNames do
		local part = model:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			-- Read per-part configuration values
			local delay = 0
			local speed = 1.5
			local easingStyleStr = "Circular"
			local transDelay = 0.8
			local transSpeed = 0.5
			local flatten = false
			local targetSize = part.Size

			local v

			v = part:FindFirstChild("Delay")
			if v then delay = v.Value end

			v = part:FindFirstChild("Speed")
			if v then speed = v.Value end

			v = part:FindFirstChild("EasingStyle")
			if v then easingStyleStr = v.Value end

			v = part:FindFirstChild("TransparencyDelay")
			if v then transDelay = v.Value end

			v = part:FindFirstChild("TransparencySpeed")
			if v then transSpeed = v.Value end

			v = part:FindFirstChild("Flatten")
			if v then flatten = v.Value end

			-- Get target size from the EndCFrame child
			local endCF = part:FindFirstChild("EndCFrame")
			if endCF and endCF:IsA("BasePart") then
				targetSize = endCF.Size
			end

			-- Anchor the part for server-side tweening
			part.Anchored = true
			part.Transparency = 0

			-- Break weld constraints so size tweening works properly
			for _, child in part:GetChildren() do
				if child:IsA("WeldConstraint") then
					child.Enabled = false
				end
			end

			-- Calculate start size (tiny, then scales up to target)
			local startSize
			if flatten then
				-- Flatten: Y stays proportionally small like the target
				local yRatio = targetSize.Y / math.max(targetSize.X, targetSize.Z)
				startSize = Vector3.new(1, math.max(1, targetSize.Y * 0.01), 1)
			else
				startSize = Vector3.new(1, 1, 1)
			end
			part.Size = startSize

			-- Enable ALL particle emitters on this part and its descendants
			for _, desc in part:GetDescendants() do
				if desc:IsA("ParticleEmitter") then
					desc.Enabled = true
					-- Emit a burst proportional to particle time
				desc:Emit(math.clamp(desc.Rate * particleTime, 10, 200))
				end
			end

			-- Track max time for cleanup
			local totalTime = delay + speed + transDelay + transSpeed
			if totalTime > maxTotalTime then
				maxTotalTime = totalTime
			end

			-- Schedule the size scale-up tween
			task.delay(delay, function()
				local easingStyle = getEasingStyle(easingStyleStr)
				local sizeInfo = TweenInfo.new(speed, easingStyle, Enum.EasingDirection.Out)
				local sizeTween = TweenService:Create(part, sizeInfo, {Size = targetSize})
				sizeTween:Play()

				-- Schedule the transparency fade-out after a delay
				task.delay(transDelay, function()
					local transInfo = TweenInfo.new(transSpeed, Enum.EasingStyle.Linear)
					local transTween = TweenService:Create(part, transInfo, {Transparency = 1})
					transTween:Play()
				end)
			end)
		end
	end

	-- Handle the WD (anchor) part
	local wd = model:FindFirstChild("WD")
	if wd and wd:IsA("BasePart") then
		wd.Anchored = true
		wd.Transparency = 1
		wd.CanCollide = false
	end

	-- Make EndCFrame parts invisible and non-interfering
	for _, partName in effectPartNames do
		local part = model:FindFirstChild(partName)
		if part then
			local endCF = part:FindFirstChild("EndCFrame")
			if endCF and endCF:IsA("BasePart") then
				endCF.Anchored = true
				endCF.Transparency = 1
				endCF.CanCollide = false
				for _, child in endCF:GetChildren() do
					if child:IsA("WeldConstraint") then
						child.Enabled = false
					end
				end
			end
		end
	end

	-- Disable particles after the particle time expires
	task.delay(particleTime + 0.5, function()
		for _, partName in effectPartNames do
			local part = model:FindFirstChild(partName)
			if part then
				for _, desc in part:GetDescendants() do
					if desc:IsA("ParticleEmitter") then
						desc.Enabled = false
					end
				end
			end
		end
	end)

	-- After all effects have faded out, destroy the entire model
	task.delay(maxTotalTime + 1, function()
		if model and model.Parent then
			model:Destroy()
		end
	end)
end

-- Wait until the model is parented into the Workspace, then run
local function waitForWorkspace()
	if model:IsDescendantOf(workspace) then
		-- Small yield to let other scripts set up Char/CFrame values
		task.wait(0.05)
		runEffect()
	else
		local conn
		conn = model.AncestryChanged:Connect(function()
			if model:IsDescendantOf(workspace) then
				conn:Disconnect()
				task.wait(0.05)
				runEffect()
			end
		end)
	end
end

waitForWorkspace()