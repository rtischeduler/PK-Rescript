-- Hides the overhead health bar BillboardGui on the local player's own character

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local function hideOwnHealthBar(character)
	local billboard = character:WaitForChild("OverheadHealthBar", 10)
	if billboard then
		billboard.Enabled = false
	end
end

local function onCharacterAdded(character)
	task.spawn(hideOwnHealthBar, character)
end

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)