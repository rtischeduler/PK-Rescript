local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local wave = script.Parent

-- Find reference size parts
local startSizePart = wave:FindFirstChild("StartSize")
local finalSizePart = wave:FindFirstChild("FinalSize")

if not startSizePart or not finalSizePart then
    warn("DeathWave Tween: StartSize or FinalSize part not found")
    return
end

local startSize = startSizePart.Size
local finalSize = finalSizePart.Size

-- Destroy reference parts (not needed at runtime)
startSizePart:Destroy()
finalSizePart:Destroy()

-- Break existing WeldConstraints on the wave
-- (the DeathWaveWeld added by the spawn code is a regular Weld, not a WeldConstraint, so it survives)
for _, child in ipairs(wave:GetChildren()) do
    if child:IsA("WeldConstraint") then
        child:Destroy()
    end
end

-- Start invisible at small size
wave.Transparency = 1
wave.Size = startSize

-- Timing
local growTime = 0.5
local fadeInTime = 0.1
local fadeOutTime = 0.5
local particleDuration = 0.3
local craterFadeDelay = 1.0
local craterFadeTime = 0.5
local maxLifetime = 3

-- Failsafe cleanup
Debris:AddItem(wave, maxLifetime)

-- Enable Stomp particle emitters
for _, child in ipairs(wave:GetChildren()) do
    if child:IsA("ParticleEmitter") then
        child.Enabled = true
    end
end

-- Disable particles after a short burst
task.delay(particleDuration, function()
    for _, child in ipairs(wave:GetChildren()) do
        if child:IsA("ParticleEmitter") then
            child.Enabled = false
        end
    end
end)

-- Process Crater: anchor in workspace, keep for 10 seconds
local crater = wave:FindFirstChild("Crater")
if crater then
    -- Detach crater from the wave so it persists independently in workspace
    crater.Parent = workspace

    -- Anchor crater parts (no explosion, no launching)
    -- Keep crater parts invisible (Transparency stays at 1 from template)
    for _, desc in ipairs(crater:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = true
            desc.CanCollide = false
            desc.AssemblyLinearVelocity = Vector3.zero
            desc.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- Clean up crater after 10 seconds
    Debris:AddItem(crater, 10)
end

-- Grow the wave mesh and fade in
local growTween = TweenService:Create(wave,
    TweenInfo.new(growTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    { Size = finalSize }
)
local fadeInTween = TweenService:Create(wave,
    TweenInfo.new(fadeInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    { Transparency = 0.3 }
)

growTween.Completed:Connect(function()
    if not wave or not wave.Parent then return end
    local fadeOutTween = TweenService:Create(wave,
        TweenInfo.new(fadeOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Transparency = 1 }
    )
    fadeOutTween:Play()
end)

growTween:Play()
fadeInTween:Play()