local Server = script.Parent
local LifeValue = Server.Life
-- Constantly count/update Server.Life Value
task.spawn(function()
	while task.wait(1) do
		LifeValue.Value = LifeValue.Value + 1
	end
end)

function LoadMap()
	local Maps = game.Lighting.Maps:GetChildren()
	local Map = Maps[math.random(1, #Maps)]
	Map.Parent = game.Workspace
	Map.Sky:Clone().Parent = game.Lighting
	Map.Song:Play()
	Map.Name = "Map"
	if Map.Ambience then
		Map.Ambience:Play()
	end
	if Map.Brightness then
		game.Lighting.Brightness = Map.Brightness.Value
	end
	if Map.Ambient then
		game.Lighting.Ambient = Map.Ambient.Value
	end
end

local Gamemode = Server.GameMode.Value
if Gamemode == "FFA" then
--LoadMap()	
elseif Gamemode == "Team Battles" then
LoadMap()	
end

script.Parent.Sprint.OnServerEvent:Connect(function(player)
	local character = player.Character
	if character then
		local animate = character:FindFirstChild("Animate")
		if animate then
			local running = animate:FindFirstChild("Running")
			if running then
				running.Value = not running.Value
			end
		end
	end
end)

script.Map.OnServerEvent:Connect(function()
	LoadMap()
end)