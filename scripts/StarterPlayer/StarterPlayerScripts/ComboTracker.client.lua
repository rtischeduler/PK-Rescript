-- ComboTracker: Client-side combo counter UI system
-- Listens for ComboEvent from server, tracks hits/damage, tweens UI, resets after 2s inactivity

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local comboEvent = ReplicatedStorage:WaitForChild("ComboEvent", 10)
local hitEffectEvent = ReplicatedStorage:WaitForChild("HitEffectEvent", 10)

-- Combo state
local comboCount = 0
local comboDamage = 0
local comboTimerThread = nil
local comboActive = false

-- UI size constants
local HIDE_SIZE = UDim2.new(0, 0, 0, 0)
local SHOW_SIZE = UDim2.new(0.117, 0, 0.195, 0)
local POP_SIZE = UDim2.new(0.145, 0, 0.24, 0) -- Bigger for pop effect

-- Tween info constants
local POP_TWEEN = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SETTLE_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HIDE_TWEEN = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local COMBO_TIMEOUT = 2 -- seconds of inactivity before combo resets

-- Get the ComboHolder UI element from the player's GameGui
local function getComboHolder()
	local gameGui = player.PlayerGui:FindFirstChild("GameGui")
	if not gameGui then return nil end
	local characterFrame = gameGui:FindFirstChild("Character")
	if not characterFrame then return nil end
	return characterFrame:FindFirstChild("ComboHolder")
end

-- Hide the combo UI with a smooth tween
local function hideCombo()
	local comboHolder = getComboHolder()
	if not comboHolder then return end

	comboCount = 0
	comboDamage = 0
	comboActive = false

	-- Update NumberValues for objective system
	comboHolder.ComboAmount.Value = 0
	comboHolder.ComboDamage.Value = 0

	comboHolder.ComboText.Text = ""
	comboHolder.DamageText.Text = ""

	local tween = TweenService:Create(comboHolder, HIDE_TWEEN, {
		Size = HIDE_SIZE
	})
	tween:Play()
end

-- Show the combo UI with a pop-up scale effect
local function showCombo(count, damage)
	local comboHolder = getComboHolder()
	if not comboHolder then return end

	-- Update text labels
	comboHolder.ComboText.Text = count .. " Hits"
	comboHolder.DamageText.Text = math.floor(damage) .. " DMG"

	-- Update NumberValues for objective system
	comboHolder.ComboAmount.Value = count
	comboHolder.ComboDamage.Value = damage

	-- Pop-up effect: scale to bigger size first, then settle to normal
	local popTween = TweenService:Create(comboHolder, POP_TWEEN, {
		Size = POP_SIZE
	})
	popTween:Play()

	popTween.Completed:Connect(function()
		if comboActive and comboCount == count then
			local settleTween = TweenService:Create(comboHolder, SETTLE_TWEEN, {
				Size = SHOW_SIZE
			})
			settleTween:Play()
		end
	end)
end

-- Handle a combo hit from the server
local function onComboHit(damageAmount)
	comboCount = comboCount + 1
	comboDamage = comboDamage + damageAmount
	comboActive = true

	showCombo(comboCount, comboDamage)

	-- Cancel any existing inactivity timer
	if comboTimerThread then
		task.cancel(comboTimerThread)
	end

	-- Start a new inactivity timer
	comboTimerThread = task.delay(COMBO_TIMEOUT, function()
		comboTimerThread = nil
		hideCombo()
	end)
end

-- Listen for combo events from the server
if comboEvent then
	comboEvent.OnClientEvent:Connect(onComboHit)
end

----------------------------------------------------------------
-- SCREEN SHAKE (Project Kaiju 4.0 style impact feedback)
-- Uses BindToRenderStep at Camera+1 priority so shake runs
-- AFTER the camera controller updates CFrame each frame.
----------------------------------------------------------------

local camera = workspace.CurrentCamera
local shakeState = {
	active = false,
	startTime = 0,
	duration = 0,
	intensity = 0,
}
local beamShakeActive = false
local BEAM_SHAKE_INTENSITY = 0.3
local roarShakeActive = false
local ROAR_SHAKE_INTENSITY = 0.5

local function applyScreenShake(intensity, duration)
	-- New shake overrides any active shake (no blocking)
	shakeState.active = true
	shakeState.startTime = tick()
	shakeState.duration = duration
	shakeState.intensity = intensity
end

-- Bind to render step AFTER camera controller (priority Camera+1)
RunService:BindToRenderStep("ScreenShake", Enum.RenderPriority.Camera.Value + 1, function()
	local totalOffset = Vector3.new(0, 0, 0)

	-- Impact shake (with exponential decay)
	if shakeState.active then
		local elapsed = tick() - shakeState.startTime
		if elapsed >= shakeState.duration then
			shakeState.active = false
		else
			local progress = elapsed / shakeState.duration
			local decay = (1 - progress) ^ 2
			totalOffset = totalOffset + Vector3.new(
				(math.random() * 2 - 1) * shakeState.intensity * decay,
				(math.random() * 2 - 1) * shakeState.intensity * decay,
				(math.random() * 2 - 1) * shakeState.intensity * decay * 0.3
			)
		end
	end

	-- Beam shake (constant soft rumble, no decay)
	if beamShakeActive then
		totalOffset = totalOffset + Vector3.new(
			(math.random() * 2 - 1) * BEAM_SHAKE_INTENSITY,
			(math.random() * 2 - 1) * BEAM_SHAKE_INTENSITY,
			(math.random() * 2 - 1) * BEAM_SHAKE_INTENSITY * 0.3
		)
	end

	-- Roar shake (constant heavy rumble, no decay - lasts entire roar duration)
	if roarShakeActive then
		totalOffset = totalOffset + Vector3.new(
			(math.random() * 2 - 1) * ROAR_SHAKE_INTENSITY,
			(math.random() * 2 - 1) * ROAR_SHAKE_INTENSITY,
			(math.random() * 2 - 1) * ROAR_SHAKE_INTENSITY * 0.3
		)
	end

	if totalOffset.Magnitude > 0 then
		camera.CFrame = camera.CFrame * CFrame.new(totalOffset)
	end
end)

-- Listen for hit effect events from the server
if hitEffectEvent then
	hitEffectEvent.OnClientEvent:Connect(function(effectType, ...)
		if effectType == "ScreenShake" then
			local intensity = select(1, ...)
			local duration = select(2, ...)
			applyScreenShake(intensity, duration)
		elseif effectType == "BeamShakeStart" then
			beamShakeActive = true
		elseif effectType == "BeamShakeEnd" then
			beamShakeActive = false
		elseif effectType == "RoarShakeStart" then
			roarShakeActive = true
		elseif effectType == "RoarShakeEnd" then
			roarShakeActive = false
		end
	end)
end

-- Reset combo when the player gets stunned
local function setupStunListener(character)
	if not character then return end

	local aspects = character:FindFirstChild("Aspects")
	if not aspects then return end
	local stunFolder = aspects:FindFirstChild("Stun")
	if not stunFolder then return end
	local stunned = stunFolder:FindFirstChild("Stunned")
	if not stunned then return end

	stunned.Changed:Connect(function()
		if stunned.Value == true then
			-- Cancel inactivity timer
			if comboTimerThread then
				task.cancel(comboTimerThread)
				comboTimerThread = nil
			end
			hideCombo()
		end
	end)

	-- Also reset on knockdown
	local knockdown = stunFolder:FindFirstChild("Knockdown")
	if knockdown then
		knockdown.Changed:Connect(function()
			if knockdown.Value == true and comboActive then
				-- Cancel inactivity timer
				if comboTimerThread then
					task.cancel(comboTimerThread)
					comboTimerThread = nil
				end
				hideCombo()
			end
		end)
	end
end

-- Reset combo when the player dies
local function setupDeathListener(character)
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.Died:Connect(function()
		if comboTimerThread then
			task.cancel(comboTimerThread)
			comboTimerThread = nil
		end
		hideCombo()
	end)
end

-- Setup on character added
player.CharacterAdded:Connect(function(character)
	task.wait(1) -- Wait for Aspects to be created
	setupStunListener(character)
	setupDeathListener(character)
end)

-- Setup for current character if it exists
if player.Character then
	task.wait(1)
	setupStunListener(player.Character)
	setupDeathListener(player.Character)
end

-- Initialize ComboHolder to hidden state
local function initComboHolder()
	local comboHolder = getComboHolder()
	if comboHolder then
		comboHolder.Size = HIDE_SIZE
		comboHolder.ComboText.Text = ""
		comboHolder.DamageText.Text = ""
		comboHolder.ComboAmount.Value = 0
		comboHolder.ComboDamage.Value = 0
	end
end

-- Wait for UI to be ready
task.delay(2, initComboHolder)