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

-- Process Crater: make visible, break welds, launch chunks
local crater = wave:FindFirstChild("Crater")
if crater then
    -- Break all joints inside the crater so chunks are free
    for _, desc in ipairs(crater:GetDescendants()) do
        if desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("Motor6D") then
            desc:Destroy()
        end
    end

    -- Make all crater parts visible and launch them
    local wavePos = wave.Position
    for _, desc in ipairs(crater:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Transparency = 0
            desc.Massless = false
            desc.CanCollide = false

            -- Direction from wave center to the chunk (outward)
            local dir = desc.Position - wavePos
            local horizontal = Vector3.new(dir.X, 0, dir.Z)
            if horizontal.Magnitude > 0.1 then
                horizontal = horizontal.Unit
            else
                horizontal = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                if horizontal.Magnitude > 0 then
                    horizontal = horizontal.Unit
                end
            end

            local upward = math.random(20, 50)
            local outward = math.random(15, 40)

            desc.AssemblyLinearVelocity = Vector3.new(
                horizontal.X * outward + math.random(-5, 5),
                upward,
                horizontal.Z * outward + math.random(-5, 5)
            )
            desc.AssemblyAngularVelocity = Vector3.new(
                math.random(-10, 10),
                math.random(-10, 10),
                math.random(-10, 10)
            )
        end
    end

    -- Fade out crater parts after they've flown
    task.delay(craterFadeDelay, function()
        if not crater or not crater.Parent then return end
        for _, desc in ipairs(crater:GetDescendants()) do
            if desc:IsA("BasePart") then
                local tween = TweenService:Create(desc,
                    TweenInfo.new(craterFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { Transparency = 1 }
                )
                tween:Play()
            end
        end
    end)
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