-- LockOn System - Clean Rewrite
-- Handles lock-on targeting with Third and Side camera modes

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local lockOnFolder = script.Parent
local target = lockOnFolder.Target              -- ObjectValue: locked-on target HRP
local mode = target.Mode                      -- StringValue: "Third" or "Side"
local labelOne = lockOnFolder.LabelOne        -- ImageLabel
local labelTwo = lockOnFolder.LabelTwo        -- ImageLabel
local lockOnUI = script:FindFirstChild("LockOnUI") -- BillboardGui

-- Keybinds from central config
local keybindConfig = require(game.ReplicatedStorage.KeybindConfig)
local LOCKON_KEY = keybindConfig.LockOn
local LOCKON_SWAP_KEY = keybindConfig.LockOnSwap

-- Internal state
local currentHover = nil -- HumanoidRootPart currently hovered over

-- Character references (updated on respawn)
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================
-- Helper Functions
-- ============================================

local function isStunned()
    local aspects = character:FindFirstChild("Aspects")
    if not aspects then return false end
    local stun = aspects:FindFirstChild("Stun")
    if not stun then return false end
    local s = stun:FindFirstChild("Stunned")
    local g = stun:FindFirstChild("Grabbed")
    local k = stun:FindFirstChild("Knockdown")
    return (s and s.Value) or (g and g.Value) or (k and k.Value)
end

local function isDoingSomething()
    local control = character:FindFirstChild("Control")
    if not control then return false end
    local values = control:FindFirstChild("Values")
    if not values then return false end
    local actions = values:FindFirstChild("Actions")
    if not actions then return false end
    local d = actions:FindFirstChild("DoingSomething")
    return d and d.Value
end

local function isScreenShaking()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    local gg = pg:FindFirstChild("GameGui")
    if not gg then return false end
    local uiFunc = gg:FindFirstChild("UIFunctions")
    if not uiFunc then return false end
    local fireFunc = uiFunc:FindFirstChild("FireFunctions")
    if not fireFunc then return false end
    local cdTime = fireFunc:FindFirstChild("CooldownsTime")
    if not cdTime then return false end
    local shake = cdTime:FindFirstChild("ScreenShaking")
    return shake and shake.Value
end

local function isGrabbed()
    local aspects = character:FindFirstChild("Aspects")
    if not aspects then return false end
    local stun = aspects:FindFirstChild("Stun")
    if not stun then return false end
    local g = stun:FindFirstChild("Grabbed")
    return g and g.Value
end

local function fadeOutLabels()
    TweenService:Create(labelOne, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService:Create(labelTwo, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
end

local function showLabels()
    TweenService:Create(labelOne, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    TweenService:Create(labelTwo, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end

-- Update mobile LockOn button visual state
local function updateMobileButtonVisual(isLocked)
    if not mobileButton then return end
    local lockOnBtn = mobileButton.Parent -- ImageButton
    if not lockOnBtn then return end
    if isLocked then
        lockOnBtn.ImageTransparency = 0.2
        lockOnBtn.ImageColor3 = Color3.fromRGB(0, 255, 100)
    else
        lockOnBtn.ImageTransparency = 0.75
        lockOnBtn.ImageColor3 = Color3.fromRGB(255, 0, 132)
    end
end

local function unlock()
    target.Value = nil
    TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = 60}):Play()
    fadeOutLabels()
    if lockOnUI then lockOnUI.Adornee = nil end
    updateMobileButtonVisual(false)
end

local function tryLockOn()
    if not currentHover then return false end
    -- Don't lock onto self
    if currentHover.Parent == character or currentHover.Parent.Parent == character then
        return false
    end
    -- Note: Old script has a MouseBehavior check but its obfuscated logic makes the
    -- exact condition unclear. Removing this gate to restore basic functionality.
    target.Value = currentHover
    -- Set camera based on mode
    if mode.Value == "Third" then
        camera.CameraType = Enum.CameraType.Custom
    else
        camera.CameraType = Enum.CameraType.Scriptable
    end
    TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = 50}):Play()
    showLabels()
    if lockOnUI then lockOnUI.Adornee = currentHover end
    updateMobileButtonVisual(true)
    return true
end

-- ============================================
-- LockOnClick Hover Detection
-- ============================================

local function setupLockOnClick(clickDetector)
    if clickDetector.Name ~= "LockOnClick" then return end

    clickDetector.MouseHoverEnter:Connect(function()
        local targetModel = clickDetector.Parent
        local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
        if targetHRP and targetModel ~= character then
            currentHover = targetHRP
        end
    end)

    clickDetector.MouseHoverLeave:Connect(function()
        if currentHover and currentHover.Parent == clickDetector.Parent then
            if clickDetector.Parent ~= character then
                if UserInputService.TouchEnabled then
                    -- Mobile: clear after 3 seconds if still hovering same target
                    task.delay(3, function()
                        if currentHover and currentHover.Parent == clickDetector.Parent then
                            currentHover = nil
                        end
                    end)
                else
                    -- Desktop: clear immediately
                    currentHover = nil
                end
            end
        end
    end)
end

-- Set up existing LockOnClicks in workspace
for _, descendant in workspace:GetDescendants() do
    if descendant.Name == "LockOnClick" then
        setupLockOnClick(descendant)
    end
end

-- Handle new LockOnClicks added during gameplay
workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "LockOnClick" then
        setupLockOnClick(descendant)
    end
end)

-- ============================================
-- Input Handling
-- ============================================

-- Right-click to unlock
player:GetMouse().Button2Down:Connect(function()
    if target.Value then
        unlock()
    end
end)

-- Keyboard input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- LockOn key (T) - toggle lock-on
    if input.KeyCode == LOCKON_KEY then
        if target.Value then
            unlock()
        else
            mode.Value = "Third" -- Reset to Third mode before locking on (matches old script)
            tryLockOn()
        end
    end

    -- LockOnSwap key (Y) - toggle camera mode
    if input.KeyCode == LOCKON_SWAP_KEY then
        if mode.Value == "Third" then
            mode.Value = "Side"
        else
            mode.Value = "Third"
        end
    end

    -- Left/Right Control - unlock
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        if target.Value then
            unlock()
        end
    end
end)

-- Mobile lock-on button
-- Since this script is inside GameGui, we can access the button directly
-- via script.Parent.Parent (GameGui) instead of going through PlayerGui
local gameGui = script.Parent.Parent
local mobileButton = nil
local mobileDebounce = false

local function findMobileButton()
    local charFrame = gameGui:FindFirstChild("Character")
    if not charFrame then return nil end
    local cooldowns = charFrame:FindFirstChild("Cooldowns")
    if not cooldowns then return nil end
    local mobile = cooldowns:FindFirstChild("Mobile")
    if not mobile then return nil end
    local aspects = mobile:FindFirstChild("Aspects")
    if not aspects then return nil end
    local lockOn = aspects:FindFirstChild("LockOn")
    if not lockOn then return nil end
    return lockOn:FindFirstChild("Button")
end

local function connectMobileButton()
    local btn = findMobileButton()
    if not btn then return false end

    btn.MouseButton1Down:Connect(function()
        if mobileDebounce then return end
        mobileDebounce = true

        if target.Value then
            unlock()
        else
            mode.Value = "Third" -- Reset to Third mode before locking on (matches old script)
            tryLockOn()
        end

        task.delay(0.3, function()
            mobileDebounce = false
        end)
    end)
    mobileButton = btn
    return true
end

-- Set up mobile button (GameGui children are available since this script is inside GameGui)
connectMobileButton()

-- ============================================
-- Mode Changed - update camera type when not locked on
-- ============================================

mode.Changed:Connect(function()
    if not target.Value then
        if mode.Value == "Third" then
            camera.CameraType = Enum.CameraType.Custom
        else
            camera.CameraType = Enum.CameraType.Scriptable
        end
    end
end)

-- ============================================
-- Target Changed - handle unlock transition
-- ============================================

target.Changed:Connect(function()
    if target.Value == nil then
        -- Transition: offset camera up, disable auto-rotate
        humanoid.CameraOffset = Vector3.new(0, humanoidRootPart.Size.Y * 0.75, 0)
        humanoid.AutoRotate = false
        updateMobileButtonVisual(false)

        -- After short delay, fully reset camera
        task.delay(0.15, function()
            if target.Value == nil then
                camera.CameraType = Enum.CameraType.Custom
                camera.CameraSubject = humanoid
                humanoid.CameraOffset = Vector3.new(0, 0, 0)
                -- Restore auto-rotate if not in a stun state
                if not isStunned() and not isDoingSomething() then
                    if humanoid.WalkSpeed > 0 then
                        humanoid.AutoRotate = true
                    end
                end
            end
        end)
    end
end)

-- ============================================
-- Character Died - clear lock-on
-- ============================================

humanoid.Died:Connect(function()
    target.Value = nil
    fadeOutLabels()
    updateMobileButtonVisual(false)
end)

-- ============================================
-- Per-Frame Update (camera + character facing)
-- ============================================

RunService.Stepped:Connect(function()
    local targetValue = target.Value
    if not targetValue then return end

    -- Validate target still exists
    if not targetValue.Parent then
        unlock()
        return
    end

    if mode.Value == "Third" then
        -- Camera: look at target when not right-clicking
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if not isScreenShaking() then
                if isGrabbed() then
                    camera.CFrame = humanoidRootPart.CFrame
                else
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetValue.Position)
                end
            end
        end

        -- Character facing: face the target when not anchored/stunned
        if not humanoidRootPart.Anchored and not isStunned() then
            if not humanoidRootPart:FindFirstChildOfClass("BodyVelocity") then
                humanoid.AutoRotate = false
                humanoid.CameraOffset = Vector3.new(0, humanoidRootPart.Size.Y / 2, 0)

                local targetPos = targetValue.Position
                local lookPos = Vector3.new(targetPos.X, humanoidRootPart.Position.Y, targetPos.Z)
                humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(
                    CFrame.new(humanoidRootPart.Position, lookPos), 1
                )
            end
        end

    elseif mode.Value == "Side" then
        -- Camera: side view when not right-clicking
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local charPos = humanoidRootPart.Position
            local targetPos = targetValue.Position

            -- Anchor CFrame: character facing target on XZ plane
            local anchorCF = CFrame.new(charPos, Vector3.new(targetPos.X, charPos.Y, targetPos.Z))

            -- Distance between character and target
            local distance = (charPos - targetPos).Magnitude

            -- Camera: behind midpoint, offset to the side
            local midCF = anchorCF * CFrame.new(0, 0, distance * -0.5)
            local midPos = midCF.Position
            local cameraCF = midCF * CFrame.new(distance * 0.75 + 5, distance * 0.085, 0)

            -- Make camera look toward midpoint (center between character and target)
            cameraCF = CFrame.new(
                cameraCF.Position,
                Vector3.new(midPos.X, cameraCF.Position.Y, midPos.Z)
            )

            camera.CFrame = cameraCF
        end

        -- Character facing: face the target (zero camera offset in Side mode)
        if not humanoidRootPart.Anchored and not isStunned() then
            if not humanoidRootPart:FindFirstChildOfClass("BodyVelocity") then
                humanoid.AutoRotate = false
                humanoid.CameraOffset = Vector3.new(0, 0, 0)

                local targetPos = targetValue.Position
                local lookPos = Vector3.new(targetPos.X, humanoidRootPart.Position.Y, targetPos.Z)
                humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(
                    CFrame.new(humanoidRootPart.Position, lookPos), 1
                )
            end
        end
    end
end)

-- ============================================
-- Character Respawn Handling
-- Note: GameGui has ResetOnSpawn = true, so this script
-- restarts on every respawn. CharacterAdded handles the
-- case where the character changes while the script persists.
-- ============================================

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")

    -- Reset camera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    humanoid.CameraOffset = Vector3.new(0, 0, 0)

    -- Clear lock-on state
    target.Value = nil
    currentHover = nil

    -- Reconnect died event
    humanoid.Died:Connect(function()
        target.Value = nil
        fadeOutLabels()
    end)
end)

-- Initialize camera on startup
camera.CameraType = Enum.CameraType.Custom
camera.CameraSubject = humanoid
humanoid.CameraOffset = Vector3.new(0, 0, 0)
