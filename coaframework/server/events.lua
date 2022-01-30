-- Player joined
RegisterServerEvent("CashoutCore:PlayerJoined")
AddEventHandler('CashoutCore:PlayerJoined', function()
	local src = source
end)

AddEventHandler('playerDropped', function(reason) 
	local src = source
	print("Dropped: "..GetPlayerName(src))
	TriggerEvent("cash-log:server:CreateLog", "joinleave", "Dropped", "red", "**".. GetPlayerName(src) .. "** ("..GetPlayerIdentifiers(src)[1]..") left..")
	TriggerEvent("cash-log:server:sendLog", GetPlayerIdentifiers(src)[1], "joined", {})
	if reason ~= "Reconnecting" and src > 60000 then return false end
	if(src==nil or (CashoutCore.Players[src] == nil)) then return false end
	CashoutCore.Players[src].Functions.Save()
	CashoutCore.Players[src] = nil
end)

-- Checking everything before joining
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
	deferrals.defer()
	local src = source
	deferrals.update("\nChecking name...")
	local name = GetPlayerName(src)
	if name == nil then 
		CashoutCore.Functions.Kick(src, 'Please do not use an empty steam name.', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	if(string.match(name, "[*%%'=`\"]")) then
        CashoutCore.Functions.Kick(src, 'You have in your name a sign('..string.match(name, "[*%%'=`\"]")..') whats not allowed.\nPlease take this out of your steam name..', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	if (string.match(name, "drop") or string.match(name, "table") or string.match(name, "database")) then
        CashoutCore.Functions.Kick(src, 'You have a word in your name (drop/table/database) which is not allowed..', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	deferrals.update("\nChecking identifiers...")
    local identifiers = GetPlayerIdentifiers(src)
	local steamid = identifiers[1]
	local license = identifiers[2]
    if (CashoutConfig.IdentifierType == "steam" and (steamid:sub(1,6) == "steam:") == false) then
        CashoutCore.Functions.Kick(src, 'You have to have steam on to play.', setKickReason, deferrals)
        CancelEvent()
		return false
	elseif (CashoutConfig.IdentifierType == "license" and (steamid:sub(1,6) == "license:") == false) then
		CashoutCore.Functions.Kick(src, 'No social club license found.', setKickReason, deferrals)
        CancelEvent()
		return false
    end
	deferrals.update("\nChecking ban status...")
    local isBanned, Reason = CashoutCore.Functions.IsPlayerBanned(src)
    if(isBanned) then
        CashoutCore.Functions.Kick(src, Reason, setKickReason, deferrals)
        CancelEvent()
        return false
    end
	deferrals.update("\nChecking whitelist status...")
    if(not CashoutCore.Functions.IsWhitelisted(src)) then
        CashoutCore.Functions.Kick(src, 'Unfortunately, you are not whitelisted.', setKickReason, deferrals)
        CancelEvent()
        return false
    end
	deferrals.update("\nChecking server status...")
    if(CashoutCore.Config.Server.closed and not IsPlayerAceAllowed(src, "cashadmin.join")) then
		CashoutCore.Functions.Kick(_source, 'The server is closed:\n'..CashoutCore.Config.Server.closedReason, setKickReason, deferrals)
        CancelEvent()
        return false
	end
	TriggerEvent("cash-log:server:CreateLog", "joinleave", "Queue", "orange", "**"..name .. "** ("..json.encode(GetPlayerIdentifiers(src))..") in queue..")
	TriggerEvent("cash-log:server:sendLog", GetPlayerIdentifiers(src)[1], "left", {})
	TriggerEvent("connectqueue:playerConnect", src, setKickReason, deferrals)
end)

RegisterServerEvent("CashoutCore:server:CloseServer")
AddEventHandler('CashoutCore:server:CloseServer', function(reason)
    local src = source
    local Player = CashoutCore.Functions.GetPlayer(src)

    if CashoutCore.Functions.HasPermission(source, "admin") or CashoutCore.Functions.HasPermission(source, "god") then 
        local reason = reason ~= nil and reason or "No reason given..."
        CashoutCore.Config.Server.closed = true
        CashoutCore.Config.Server.closedReason = reason
        TriggerClientEvent("cashadmin:client:SetServerStatus", -1, true)
	else
		CashoutCore.Functions.Kick(src, "You don't have permission...", nil, nil)
    end
end)

RegisterServerEvent("CashoutCore:server:OpenServer")
AddEventHandler('CashoutCore:server:OpenServer', function()
    local src = source
    local Player = CashoutCore.Functions.GetPlayer(src)
    if CashoutCore.Functions.HasPermission(source, "admin") or CashoutCore.Functions.HasPermission(source, "god") then
        CashoutCore.Config.Server.closed = false
        TriggerClientEvent("cashadmin:client:SetServerStatus", -1, false)
    else
        CashoutCore.Functions.Kick(src, "You don't have permission...", nil, nil)
    end
end)

RegisterServerEvent("CashoutCore:UpdatePlayer")
AddEventHandler('CashoutCore:UpdatePlayer', function(data)
	local src = source
	local Player = CashoutCore.Functions.GetPlayer(src)
	
	if Player ~= nil then
		Player.PlayerData.position = data.position

		local newHunger = Player.PlayerData.metadata["hunger"] - 4.2
		local newThirst = Player.PlayerData.metadata["thirst"] - 3.8
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData("thirst", newThirst)
		Player.Functions.SetMetaData("hunger", newHunger)

		Player.Functions.AddMoney("bank", Player.PlayerData.job.payment)
		TriggerClientEvent('CashoutCore:Notify', src, "You received your payslip of $" ..Player.PlayerData.job.payment .." from the government")
		TriggerClientEvent("hud:client:UpdateNeeds", src, newHunger, newThirst)

		Player.Functions.Save()
	end
end)

RegisterServerEvent("CashoutCore:UpdatePlayerPosition")
AddEventHandler("CashoutCore:UpdatePlayerPosition", function(position)
	local src = source
	local Player = CashoutCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.PlayerData.position = position
	end
end)

RegisterServerEvent("CashoutCore:Server:TriggerCallback")
AddEventHandler('CashoutCore:Server:TriggerCallback', function(name, ...)
	local src = source
	CashoutCore.Functions.TriggerCallback(name, src, function(...)
		TriggerClientEvent("CashoutCore:Client:TriggerCallback", src, name, ...)
	end, ...)
end)

RegisterServerEvent("CashoutCore:Server:UseItem")
AddEventHandler('CashoutCore:Server:UseItem', function(item)
	local src = source
	local Player = CashoutCore.Functions.GetPlayer(src)
	if item ~= nil and item.amount > 0 then
		if CashoutCore.Functions.CanUseItem(item.name) then
			CashoutCore.Functions.UseItem(src, item)
		end
	end
end)

RegisterServerEvent("CashoutCore:Server:RemoveItem")
AddEventHandler('CashoutCore:Server:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = CashoutCore.Functions.GetPlayer(src)
	Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterServerEvent("CashoutCore:Server:AddItem")
AddEventHandler('CashoutCore:Server:AddItem', function(itemName, amount, slot, info)
	local src = source
	local Player = CashoutCore.Functions.GetPlayer(src)
	Player.Functions.AddItem(itemName, amount, slot, info)
end)

RegisterServerEvent('CashoutCore:Server:SetMetaData')
AddEventHandler('CashoutCore:Server:SetMetaData', function(meta, data)
    local src = source
	local Player = CashoutCore.Functions.GetPlayer(src)
	if meta == "hunger" or meta == "thirst" then
		if data > 100 then
			data = 100
		end
	end
	if Player ~= nil then 
		Player.Functions.SetMetaData(meta, data)
	end
	TriggerClientEvent("hud:client:UpdateNeeds", src, Player.PlayerData.metadata["hunger"], Player.PlayerData.metadata["thirst"])
end)

AddEventHandler('chatMessage', function(source, n, message)
	if string.sub(message, 1, 1) == "/" then
		local args = CashoutCore.Shared.SplitStr(message, " ")
		local command = string.gsub(args[1]:lower(), "/", "")
		CancelEvent()
		if CashoutCore.Commands.List[command] ~= nil then
			local Player = CashoutCore.Functions.GetPlayer(tonumber(source))
			if Player ~= nil then
				table.remove(args, 1)
				if (CashoutCore.Functions.HasPermission(source, "god") or CashoutCore.Functions.HasPermission(source, CashoutCore.Commands.List[command].permission)) then
					if (CashoutCore.Commands.List[command].argsrequired and #CashoutCore.Commands.List[command].arguments ~= 0 and args[#CashoutCore.Commands.List[command].arguments] == nil) then
					    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be completed!")
					    local agus = ""
					    for name, help in pairs(CashoutCore.Commands.List[command].arguments) do
					    	agus = agus .. " ["..help.name.."]"
					    end
				        TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
					else
						CashoutCore.Commands.List[command].callback(source, args)
					end
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command!")
				end
			end
		end
	end
end)

RegisterServerEvent('CashoutCore:CallCommand')
AddEventHandler('CashoutCore:CallCommand', function(command, args)
	if CashoutCore.Commands.List[command] ~= nil then
		local Player = CashoutCore.Functions.GetPlayer(tonumber(source))
		if Player ~= nil then
			if (CashoutCore.Functions.HasPermission(source, "god")) or (CashoutCore.Functions.HasPermission(source, CashoutCore.Commands.List[command].permission)) or (CashoutCore.Commands.List[command].permission == Player.PlayerData.job.name) then
				if (CashoutCore.Commands.List[command].argsrequired and #CashoutCore.Commands.List[command].arguments ~= 0 and args[#CashoutCore.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be completed!")
					local agus = ""
					for name, help in pairs(CashoutCore.Commands.List[command].arguments) do
						agus = agus .. " ["..help.name.."]"
					end
					TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
				else
					CashoutCore.Commands.List[command].callback(source, args)
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command!")
			end
		end
	end
end)

RegisterServerEvent("CashoutCore:AddCommand")
AddEventHandler('CashoutCore:AddCommand', function(name, help, arguments, argsrequired, callback, persmission)
	CashoutCore.Commands.Add(name, help, arguments, argsrequired, callback, persmission)
end)

RegisterServerEvent("CashoutCore:ToggleDuty")
AddEventHandler('CashoutCore:ToggleDuty', function()
	local src = source
	local Player = CashoutCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('CashoutCore:Notify', src, "You're off duty now!")
	else
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('CashoutCore:Notify', src, "You're now on duty!")
	end
	TriggerClientEvent("CashoutCore:Client:SetDuty", src, Player.PlayerData.job.onduty)
end)

Citizen.CreateThread(function()
	CashoutCore.Functions.ExecuteSql(true, "SELECT * FROM `permissions`", function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				CashoutCore.Config.Server.PermissionList[v.steam] = {
					steam = v.steam,
					license = v.license,
					permission = v.permission,
					optin = true,
				}
			end
		end
	end)
end)

CashoutCore.Functions.CreateCallback('CashoutCore:HasItem', function(source, cb, itemName)
	local retval = false
	local Player = CashoutCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		if Player.Functions.GetItemByName(itemName) ~= nil then
			retval = true
		end
	end
	
	cb(retval)
end)	

RegisterServerEvent('CashoutCore:Command:CheckOwnedVehicle')
AddEventHandler('CashoutCore:Command:CheckOwnedVehicle', function(VehiclePlate)
	if VehiclePlate ~= nil then
		CashoutCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..VehiclePlate.."'", function(result)
			if result[1] ~= nil then
				CashoutCore.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `state` = '1' WHERE `citizenid` = '"..result[1].citizenid.."'")
				TriggerEvent('cash-garagesystem:server:RemoveVehicle', result[1].citizenid, VehiclePlate)
			end
		end)
	end
end)