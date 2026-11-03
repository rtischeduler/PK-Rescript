-- ClientCombatHandler: Client-side knockback, hitstop, and look-at-attacker
-- Receives events from server and applies them locally for INSTANT feedback (no network latency)
-- This eliminates the server round-trip delay for physics and animation effects

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Get remote events
local KnockbackEvent = ReplicatedStorage:WaitForChild("KnockbackEvent", 10)
local HitEffectEvent = ReplicatedStorage:FindFirstChild("HitEffectEvent")

----------------------------------------------------------------
-- CLIENT-SIDE KNOCKBACK
-- Applies LinearVelocity on own character for instant knockback (no server round-trip)
-- The client has network ownership of their own character, so physics updates
-- replicate to the server and all other clients automatically.
----------------------------------------------------------------

local KNOCKBACK_DURATION = 0.3
local knockbackSavedWalkSpeed = nil

KnockbackEvent.OnClientEvent:Connect(function(pushDir, horizontalForce, verticalForce)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	-- Zero WalkSpeed so the humanoid controller doesn't fight the knockback
	if humanoid then
		-- Only save and zero WalkSpeed if it's currently non-zero.
		-- If it's already 0 (from an active attack or stun), another system
		-- owns WalkSpeed restoration — don't take ownership here.
		if humanoid.WalkSpeed > 0 then
			knockbackSavedWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0
		else
			knockbackSavedWalkSpeed = nil
		end
	end

	-- Create or reuse Attachment on HRP
	local attachment = hrp:FindFirstChild("KnockbackAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "KnockbackAttachment"
		attachment.Parent = hrp
	end

	-- Remove any existing knockback constraint (handles rapid re-hits)
	local existingVelocity = hrp:FindFirstChild("KnockbackVelocity")
	if existingVelocity then existingVelocity:Destroy() end

	-- LinearVelocity constraint in Vector mode
	-- ForceLimitsEnabled = false -> unlimited force -> always overcomes humanoid controller
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "KnockbackVelocity"
	linearVelocity.Attachment0 = attachment
	-- Force knockback to be strictly horizontal: zero out any vertical component
	pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
	if pushDir.Magnitude > 0 then
		pushDir = pushDir.Unit
	end

	linearVelocity.VectorVelocity = pushDir * horizontalForce
	linearVelocity.ForceLimitsEnabled = false
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Parent = hrp

	-- Clear angular velocity to prevent spinning
	hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

	-- Clean up after knockback duration
	task.delay(KNOCKBACK_DURATION, function()
		if linearVelocity and linearVelocity.Parent then
			linearVelocity:Destroy()
		end
		-- Restore WalkSpeed unless stunned/knocked down/grabbed (those systems manage WalkSpeed)
		if humanoid and humanoid.Parent and knockbackSavedWalkSpeed ~= nil then
			local aspects = character:FindFirstChild("Aspects")
			local stunFolder = aspects and aspects:FindFirstChild("Stun")
			local stunnedVal = stunFolder and stunFolder:FindFirstChild("Stunned")
			local knockdownVal = stunFolder and stunFolder:FindFirstChild("Knockdown")
			local grabbedVal = stunFolder and stunFolder:FindFirstChild("Grabbed")
			local isStillStunned = (stunnedVal and stunnedVal.Value) or (knockdownVal and knockdownVal.Value) or (grabbedVal and grabbedVal.Value)
			if not isStillStunned then
				humanoid.WalkSpeed = knockbackSavedWalkSpeed
			end
		end
		knockbackSavedWalkSpeed = nil
	end)
end)

----------------------------------------------------------------
-- CLIENT-SIDE LOOK-AT-ATTACKER
-- Rotates own character to face the attacker instantly (no server round-trip).
-- Server-side CFrame changes on player characters can be overwritten by
-- the client's own physics simulation, so doing it client-side is more reliable.
----------------------------------------------------------------

local function applyLookAt(attackerPosition)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local lookDirection = attackerPosition - hrp.Position
	lookDirection = Vector3.new(lookDirection.X, 0, lookDirection.Z)
	if lookDirection.Magnitude > 0 then
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDirection.Unit)
	end
end

----------------------------------------------------------------
-- EVENT LISTENERS (HitEffectEvent for Hitstop and LookAt)
-- ScreenShake, BeamShake, and RoarShake are handled by the ComboTracker script
----------------------------------------------------------------

if HitEffectEvent then
	HitEffectEvent.OnClientEvent:Connect(function(effectType, ...)
		if effectType == "LookAt" then
			local position = select(1, ...)
			applyLookAt(position)
		end
	end)
end
