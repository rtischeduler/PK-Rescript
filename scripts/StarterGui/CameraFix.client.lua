local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function fixCamera()
	-- Do NOT interfere when the menu script has set the camera to Scriptable
	-- (this happens during kaiju viewport display and lootbox room viewing)
	if camera.CameraType == Enum.CameraType.Scriptable then return end

	local Menu = script.Parent.Menu.Menu.Characters.LeftBar
	local startPos = Menu.Positions.StartPos.Position
	if Menu.Position.X.Scale <= startPos.X.Scale + 0.01 then
    local character = player.Character
    -- Only fix if character exists, is in the game tree, and is alive
    if not character then return end
    if not character.Parent or character.Parent == nil then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp and humanoid.Health > 0 then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = humanoid
    end
	else
		return
	end
end

-- Use BindToRenderStep with priority just after camera so we override everything
RunService:BindToRenderStep("CameraFix", Enum.RenderPriority.Camera.Value + 1, fixCamera)

player.CharacterAdded:Connect(function(character)
    -- Wait for humanoid then immediately fix
    local hum = character:WaitForChild("Humanoid", 5)
    if hum and camera.CameraType ~= Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = hum
    end

    -- Also clear LockOn target so it doesn't reference old character
    local gui = player:FindFirstChild("PlayerGui")
    if gui then
        local gameGui = gui:FindFirstChild("GameGui")
        if gameGui then
            local lockOn = gameGui:FindFirstChild("LockOn")
            if lockOn then
                local target = lockOn:FindFirstChild("Target")
                if target then
                    local val = target:FindFirstChild("Value")
                    if val then
                        val.Value = nil
                    end
                end
            end
        end
    end
end)

-- Fix immediately
task.wait(0.5)
fixCamera()