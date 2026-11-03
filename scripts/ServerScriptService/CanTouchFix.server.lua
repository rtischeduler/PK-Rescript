-- Ensures CanTouch=true on all character body parts so hitbox .Touched events fire.
-- Without this, kaiju body parts with CanTouch=false block attack hit detection.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function ensureCanTouch(character)
	for _, desc in ipairs(character:GetDescendants()) do
		if desc:IsA("BasePart") and desc.CanTouch == false then
			-- Skip Hitbox parts owned by this character (those are managed by attack scripts)
			-- Skip effect/VFX parts that should not be touchable
			local name = desc.Name
			if name ~= "Hitbox" and name ~= "BeamHitbox" and name ~= "RoarWaveActive" and name ~= "RoarAuraActive" and name ~= "GrabEffectActive" then
				desc.CanTouch = true
			end
		end
	end
end

local function onCharacterAdded(character)
	-- Fix existing parts
	ensureCanTouch(character)
	-- Monitor for parts added later (accessories, effects, etc.)
	local connection
	connection = character.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") then
			local name = desc.Name
			if name ~= "Hitbox" and name ~= "BeamHitbox" and name ~= "RoarWaveActive" and name ~= "RoarAuraActive" and name ~= "GrabEffectActive" then
				task.defer(function()
					if desc and desc.Parent and desc:IsA("BasePart") and desc.CanTouch == false then
					desc.CanTouch = true
				end
				end)
			end
		end
	end)
	character.AncestryChanged:Connect(function()
		if not character.Parent then
			connection:Disconnect()
		end
	end)
end

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)

print("[CanTouchFix] Loaded - ensuring CanTouch=true on all kaiju character parts")