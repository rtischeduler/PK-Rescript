-- Godzilla2000 Rage Explosion Animation
-- This script lives inside the cloned Ult model and animates the explosion
-- when enabled by the attacksystem after cloning to workspace.

local TweenService = game:GetService("TweenService")
local model = script.Parent

-- Wait a frame to ensure the model is properly parented
task.wait()

-- Only run if we're in workspace (not in ReplicatedStorage template)
if not model:IsDescendantOf(workspace) then return end

local parts = {}
local decals = {}
local particles = {}
local tweens = {}

-- Collect all visual parts, decals, and particle emitters
for _, child in ipairs(model:GetChildren()) do
	if child:IsA("BasePart") and child.Name == "Base" then
		-- Base part: keep transparent, just collect particles/decals
		for _, desc in ipairs(child:GetDescendants()) do
			if desc:IsA("ParticleEmitter") then
				table.insert(particles, desc)
			end
			if desc:IsA("Decal") then
				table.insert(decals, desc)
			end
		end
	elseif child:IsA("BasePart") and child.Name == "ball mesh" then
		-- Ball mesh parts: keep transparent (they are particle emitter holders)
		-- Only collect their particle emitters, do NOT make them visible
		for _, desc in ipairs(child:GetDescendants()) do
			if desc:IsA("ParticleEmitter") then
				table.insert(particles, desc)
			end
		end
	elseif child:IsA("BasePart") then
		-- Ring mesh parts: these are the visible animated rings
		local speedVal = child:FindFirstChild("Speed")
		local endSizeVal = child:FindFirstChild("EndSize")
		local speed = speedVal and speedVal.Value or 0.5
		local endSize = endSizeVal and endSizeVal.Value or child.Size

		-- Store for animation
		table.insert(parts, {
			part = child,
			speed = speed,
			endSize = endSize,
			startSize = Vector3.new(1, 1, 1),
		})

		-- Collect decals on this part
		for _, desc in ipairs(child:GetDescendants()) do
			if desc:IsA("Decal") then
				table.insert(decals, desc)
			end
			if desc:IsA("ParticleEmitter") then
				table.insert(particles, desc)
			end
		end
	end
end

-- PHASE 1: Initialize - shrink all meshes to tiny, make visible
for _, partInfo in ipairs(parts) do
	local p = partInfo.part
	p.Size = partInfo.startSize
	p.Transparency = 0
end

-- Make all decals visible
for _, decal in ipairs(decals) do
	decal.Transparency = 0
end

-- Enable all particle emitters
for _, emitter in ipairs(particles) do
	emitter.Enabled = true
end

-- Play the Explode sound on the Base part
local basePart = model:FindFirstChild("Base")
if basePart then
	local explodeSound = basePart:FindFirstChild("Explode")
	if explodeSound and explodeSound:IsA("Sound") then
		explodeSound:Play()
	end
end

-- PHASE 2: Expand - tween all meshes from tiny to their EndSize
local maxDuration = 0
for _, partInfo in ipairs(parts) do
	local tweenInfo = TweenInfo.new(
		partInfo.speed,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(partInfo.part, tweenInfo, {
		Size = partInfo.endSize,
	})
	tween:Play()
	table.insert(tweens, tween)
	if partInfo.speed > maxDuration then
		maxDuration = partInfo.speed
	end
end

-- Wait for the expansion to complete
task.wait(maxDuration + 0.3)

-- PHASE 3: Cleanup - tween ring parts transparent slowly, then destroy
local fadeDuration = 2.5
local fadeTweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

-- Disable particle emitters (let existing particles fade out)
for _, emitter in ipairs(particles) do
	emitter.Enabled = false
end

-- Tween ring parts transparent
for _, partInfo in ipairs(parts) do
	local fadeTween = TweenService:Create(partInfo.part, fadeTweenInfo, {
		Transparency = 1,
	})
	fadeTween:Play()
end

-- Tween all decals transparent
for _, decal in ipairs(decals) do
	local fadeTween = TweenService:Create(decal, fadeTweenInfo, {
		Transparency = 1,
	})
	fadeTween:Play()
end

-- After fade completes, destroy the model
task.delay(fadeDuration + 0.5, function()
	if model and model.Parent then
		model:Destroy()
	end
end)