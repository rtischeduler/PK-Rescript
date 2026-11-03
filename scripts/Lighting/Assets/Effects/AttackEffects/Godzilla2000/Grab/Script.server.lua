-- Enable all Fire particles 1 second after the Grab effect is cloned into the game
local model = script.Parent

-- Wait until the model is actually in the game (not still in Lighting)
if model.Parent == game.Lighting then
	model.AncestryChanged:Connect(function()
		if model.Parent ~= game.Lighting then
			task.delay(1, function()
				for _, desc in ipairs(model:GetDescendants()) do
					if desc:IsA("ParticleEmitter") and desc.Name == "Fire" then
						desc.Enabled = true
					end
				end
			end)
		end
	end)
else
	-- Already in the game, just wait 1 second
	task.delay(1, function()
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("ParticleEmitter") and desc.Name == "Fire" then
				desc.Enabled = true
			end
		end
	end)
end