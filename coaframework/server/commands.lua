CashoutCore.Commands = {}
CashoutCore.Commands.List = {}

CashoutCore.Commands.Add = function(name, help, arguments, argsrequired, callback, permission) -- [name] = command name (ex. /givemoney), [help] = help text, [arguments] = arguments that need to be passed (ex. {{name="id", help="ID of a player"}, {name="amount", help="amount of money"}}), [argsrequired] = set arguments required (true or false), [callback] = function(source, args) callback, [permission] = rank or job of a player
	CashoutCore.Commands.List[name:lower()] = {
		name = name:lower(),
		permission = permission ~= nil and permission:lower() or "user",
		help = help,
		arguments = arguments,
		argsrequired = argsrequired,
		callback = callback,
	}
end

CashoutCore.Commands.Refresh = function(source)
	local Player = CashoutCore.Functions.GetPlayer(tonumber(source))
	if Player ~= nil then
		for command, info in pairs(CashoutCore.Commands.List) do
			if CashoutCore.Functions.HasPermission(source, "god") or CashoutCore.Functions.HasPermission(source, CashoutCore.Commands.List[command].permission) then
				TriggerClientEvent('chat:addSuggestion', source, "/"..command, info.help, info.arguments)
			end
		end
	end
end

CashoutCore.Commands.Add("tp", "Teleport to a player or location", {{name="id/x", help="ID of a player or X position"}, {name="y", help="Y position"}, {name="z", help="Z position"}}, false, function(source, args)
	if (args[1] ~= nil and (args[2] == nil and args[3] == nil)) then
		-- tp to player
		local Player = CashoutCore.Functions.GetPlayer(tonumber(args[1]))
		if Player ~= nil then
			TriggerClientEvent('CashoutCore:Command:TeleportToPlayer', source, Player.PlayerData.source)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
		end
	else
		-- tp to location
		if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
			local x = tonumber(args[1])
			local y = tonumber(args[2])
			local z = tonumber(args[3])
			TriggerClientEvent('CashoutCore:Command:TeleportToCoords', source, x, y, z)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Not every argument is filled in (x, y, z)")
		end
	end
end, "admin")

CashoutCore.Commands.Add("addpermission", "Give permission to someone (god/admin)", {{name="id", help="Player ID"}, {name="permission", help="Permission level"}}, true, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(tonumber(args[1]))
	local permission = tostring(args[2]):lower()
	if Player ~= nil then
		CashoutCore.Functions.AddPermission(Player.PlayerData.source, permission)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")	
	end
end, "god")

CashoutCore.Commands.Add("removepermission", "Take permission away from somebody", {{name="id", help="Player ID"}}, true, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		CashoutCore.Functions.RemovePermission(Player.PlayerData.source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")	
	end
end, "god")

CashoutCore.Commands.Add("sv", "Spawn a Vehicle", {{name="model", help="Model name of the vehicle"}}, true, function(source, args)
	TriggerClientEvent('CashoutCore:Command:SpawnVehicle', source, args[1])
end, "admin")

CashoutCore.Commands.Add("debug", "Turn debug mode on/off", {}, false, function(source, args)
	TriggerClientEvent('koil-debug:toggle', source)
end, "admin")

CashoutCore.Commands.Add("dv", "Delete spawned vehicle", {}, false, function(source, args)
	TriggerClientEvent('CashoutCore:Command:DeleteVehicle', source)
end, "admin")

CashoutCore.Commands.Add("tpm", "Teleport to marker", {}, false, function(source, args)
	TriggerClientEvent('CashoutCore:Command:GoToMarker', source)
end, "admin")

CashoutCore.Commands.Add("givemoney", "Give money to player", {{name="id", help="Player ID"},{name="moneytype", help="Type money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

CashoutCore.Commands.Add("setmoney", "Set money for a player", {{name="id", help="Player ID"},{name="moneytype", help="Type money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

CashoutCore.Commands.Add("setjob", "Give a job to a player", {{name="id", help="Player ID"}, {name="job", help="Name of a job"}}, true, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetJob(tostring(args[2]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

CashoutCore.Commands.Add("job", "Look what your job is", {}, false, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(source)
	TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Job: "..Player.PlayerData.job.label)
end)

CashoutCore.Commands.Add("setgang", "Make a player a gang member.", {{name="id", help="Player ID"}, {name="job", help="Name of a job"}}, true, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetGang(tostring(args[2]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

CashoutCore.Commands.Add("gang", "Look what your job is", {}, false, function(source, args)
	local Player = CashoutCore.Functions.GetPlayer(source)

	if Player.PlayerData.gang.name ~= "none" then
		TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Gang: "..Player.PlayerData.gang.label)
	else
		TriggerClientEvent('CashoutCore:Notify', source, "You\'re not in a gang!", "error")
	end
end)

CashoutCore.Commands.Add("testnotify", "test notify", {{name="text", help="Just a test"}}, true, function(source, args)
	TriggerClientEvent('CashoutCore:Notify', source, table.concat(args, " "), "success")
end, "god")

CashoutCore.Commands.Add("clearinv", "Clear players inventory.", {{name="id", help="Player ID"}}, false, function(source, args)
	local playerId = args[1] ~= nil and args[1] or source 
	local Player = CashoutCore.Functions.GetPlayer(tonumber(playerId))
	if Player ~= nil then
		Player.Functions.ClearInventory()
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

CashoutCore.Commands.Add("ooc", "type /ooc to speak out of character.", {}, false, function(source, args)
	local message = table.concat(args, " ")
	TriggerClientEvent("CashoutCore:Client:LocalOutOfCharacter", -1, source, GetPlayerName(source), message)
	local Players = CashoutCore.Functions.GetPlayers()
	local Player = CashoutCore.Functions.GetPlayer(source)

	for k, v in pairs(CashoutCore.Functions.GetPlayers()) do
		if CashoutCore.Functions.HasPermission(v, "admin") then
			if CashoutCore.Functions.IsOptin(v) then
				TriggerClientEvent('chatMessage', v, "OOC " .. GetPlayerName(source), "normal", message)
				TriggerEvent("cash-log:server:CreateLog", "ooc", "OOC", "white", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Message:** " ..message, false)
			end
		end
	end
end)