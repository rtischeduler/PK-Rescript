local Whitelist = true -- Is the whitelist on or off?

local IDs = { -- The people who are whitelisted (player IDs)
	3882403525 -- When adding more IDs to the list add a , after any ID added so IDs = { ID, ID, ID } Last one in list does not need the ,
}

game:GetService("Players").PlayerAdded:Connect(function(plr) -- When player added do check
	if not Whitelist then return end -- makes script do nothing when whitelist is off
	if table.find(IDs,plr.UserId) then return end -- makes script do nothing if whitelisted
	if not table.find(IDs,plr.UserId) then plr:Kick("Not Public Testing") end -- Kicks player if person isn't whitelisted
end)

--