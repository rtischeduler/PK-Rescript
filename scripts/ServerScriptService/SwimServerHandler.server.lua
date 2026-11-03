local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local swimRemote = ReplicatedStorage:WaitForChild("SwimRemote")

-- Track which players are currently swimming
local swimmingPlayers = {}

swimRemote.OnServerEvent:Connect(function(player, isSwimming)
	swimmingPlayers[player] = isSwimming or false
	-- Also set attribute on character for server-side checks
	local character = player.Character
	if character then
		character:SetAttribute("IsSwimming", isSwimming == true)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	swimmingPlayers[player] = nil
end)

-- Expose swimming state so other server scripts can query it
_G.GetSwimmingPlayers = function()
	return swimmingPlayers
end

_G.IsPlayerSwimming = function(player)
	return swimmingPlayers[player] == true
end
