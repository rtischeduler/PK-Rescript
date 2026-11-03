local Player = game.Players.LocalPlayer
if Player.Name == "L0tzie" or Player.Name == "DenisTheCheeseKing" then
	script.Parent.Visible = true
else
	script.Parent:Destroy()
end