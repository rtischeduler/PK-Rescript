local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local wave = script.Parent
local startSizePart = wave:FindFirstChild("StartSize")
local finalSizePart = wave:FindFirstChild("FinalSize")

if not startSizePart or not finalSizePart then
    warn("RoarWave Tween: StartSize or FinalSize part not found")
    return
end

local startSize = Vector3.new(0.01, 0.01, 0.01)
local finalSize = finalSizePart.Size

-- Hide the template wave so only clones are visible
wave.Transparency = 1
wave.Size = startSize

-- Timing
local minTransparency = 0.9
local maxTransparency = 1

local growTime = 0.3
local flattenTime = 0.15
local fadeOutTime = 0.15
local fadeInTime = 0.3

local flattenHeightRatio = 0.3
local spawnInterval = 0.1

-- Pre-create the tween infos
local growInfo = TweenInfo.new(growTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local flattenInfo = TweenInfo.new(flattenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local fadeOutInfo = TweenInfo.new(fadeOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeInInfo = TweenInfo.new(fadeInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

-- Flattened size: keep X and Z at final, reduce Y
local flattenedSize = Vector3.new(finalSize.X, finalSize.Y * flattenHeightRatio, finalSize.Z)

-- Total max lifetime of one clone (failsafe cleanup via Debris)
local maxLifetime = growTime + fadeOutTime + 0.2

-- Animate one clone: grow from nothing, flatten, fade out, then destroy
-- Uses event-driven callbacks instead of yields so it survives script destruction
local function animateClone(clone)
    clone.Size = startSize
    clone.Transparency = maxTransparency

    -- Failsafe: Debris will destroy this clone no matter what happens to the script
    Debris:AddItem(clone, maxLifetime)

    local growTween = TweenService:Create(clone, growInfo, { Size = finalSize })
    local fadeInTween = TweenService:Create(clone, fadeInInfo, { Transparency = minTransparency })

    growTween.Completed:Connect(function()
        if not clone or not clone.Parent then return end

        local fadeOutTween = TweenService:Create(clone, fadeOutInfo, { Transparency = maxTransparency })
        fadeOutTween.Completed:Connect(function()
            if clone and clone.Parent then
                clone:Destroy()
            end
        end)
        fadeOutTween:Play()
    end)

    growTween:Play()
    fadeInTween:Play()
end

-- Store the wave's CFrame so clones appear in the right spot
local waveCFrame = wave.CFrame

while true do
    local clone = wave:Clone()
    -- Remove children we don't need in the clone (scripts, reference parts, welds, particles)
    for _, child in ipairs(clone:GetChildren()) do
        child:Destroy()
    end
    local randomYaw = math.rad(math.random(0, 1) * 180)
    clone.CFrame = waveCFrame * CFrame.Angles(0, randomYaw, 0)
    clone.Anchored = true
    clone.CanCollide = false
    clone.Massless = true
    clone.CanTouch = false
    clone.Parent = workspace

    task.spawn(animateClone, clone)

    task.wait(spawnInterval)
end