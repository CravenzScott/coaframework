CashoutCore.Functions = {}

CashoutCore.Functions.ExecuteSql = function(wait, query, cb)
	local rtndata = {}
	local waiting = true
	exports['ghmattimysql']:execute(query, {}, function(data)
		if cb ~= nil and wait == false then
			cb(data)
		end
		rtndata = data
		waiting = false
	end)
	if wait then
		while waiting do
			Citizen.Wait(5)
		end
		if cb ~= nil and wait == true then
			cb(rtndata)
		end
	end
	return rtndata
end

CashoutCore.Functions.GetIdentifier = function(source, idtype)
	local idtype = idtype ~=nil and idtype or CashoutConfig.IdentifierType
	for _, identifier in pairs(GetPlayerIdentifiers(source)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

CashoutCore.Functions.GetSource = function(identifier)
	for src, player in pairs(CashoutCore.Players) do
		local idens = GetPlayerIdentifiers(src)
		for _, id in pairs(idens) do
			if identifier == id then
				return src
			end
		end
	end
	return 0
end

CashoutCore.Functions.GetPlayer = function(source)
	if type(source) == "number" then
		return CashoutCore.Players[source]
	else
		return CashoutCore.Players[CashoutCore.Functions.GetSource(source)]
	end
end

CashoutCore.Functions.GetPlayerByCitizenId = function(citizenid)
	for src, player in pairs(CashoutCore.Players) do
		local cid = citizenid
		if CashoutCore.Players[src].PlayerData.citizenid == cid then
			return CashoutCore.Players[src]
		end
	end
	return nil
end

CashoutCore.Functions.GetPlayerByPhone = function(number)
	for src, player in pairs(CashoutCore.Players) do
		local cid = citizenid
		if CashoutCore.Players[src].PlayerData.charinfo.phone == number then
			return CashoutCore.Players[src]
		end
	end
	return nil
end

CashoutCore.Functions.GetPlayers = function()
	local sources = {}
	for k, v in pairs(CashoutCore.Players) do
		table.insert(sources, k)
	end
	return sources
end

CashoutCore.Functions.CreateCallback = function(name, cb)
	CashoutCore.ServerCallbacks[name] = cb
end

CashoutCore.Functions.TriggerCallback = function(name, source, cb, ...)
	if CashoutCore.ServerCallbacks[name] ~= nil then
		CashoutCore.ServerCallbacks[name](source, cb, ...)
	end
end

CashoutCore.Functions.CreateUseableItem = function(item, cb)
	CashoutCore.UseableItems[item] = cb
end

CashoutCore.Functions.CanUseItem = function(item)
	return CashoutCore.UseableItems[item] ~= nil
end

CashoutCore.Functions.UseItem = function(source, item)
	CashoutCore.UseableItems[item.name](source, item)
end

CashoutCore.Functions.Kick = function(source, reason, setKickReason, deferrals)
	local src = source
	reason = "\n"..reason.."\n🔸 Check out our discord for more information: "..CashoutCore.Config.Server.discord
	if(setKickReason ~=nil) then
		setKickReason(reason)
	end
	Citizen.CreateThread(function()
		if(deferrals ~= nil)then
			deferrals.update(reason)
			Citizen.Wait(2500)
		end
		if src ~= nil then
			DropPlayer(src, reason)
		end
		local i = 0
		while (i <= 4) do
			i = i + 1
			while true do
				if src ~= nil then
					if(GetPlayerPing(src) >= 0) then
						break
					end
					Citizen.Wait(100)
					Citizen.CreateThread(function() 
						DropPlayer(src, reason)
					end)
				end
			end
			Citizen.Wait(5000)
		end
	end)
end

CashoutCore.Functions.IsWhitelisted = function(source)
	local identifiers = GetPlayerIdentifiers(source)
	local rtn = false
	if (CashoutCore.Config.Server.whitelist) then
		CashoutCore.Functions.ExecuteSql(true, "SELECT * FROM `whitelist` WHERE `"..CashoutCore.Config.IdentifierType.."` = '".. CashoutCore.Functions.GetIdentifier(source).."'", function(result)
			local data = result[1]
			if data ~= nil then
				for _, id in pairs(identifiers) do
					if data.steam == id or data.license == id then
						rtn = true
					end
				end
			end
		end)
	else
		rtn = true
	end
	return rtn
end

CashoutCore.Functions.AddPermission = function(source, permission)
	local Player = CashoutCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		CashoutCore.Config.Server.PermissionList[GetPlayerIdentifiers(source)[1]] = {
			steam = GetPlayerIdentifiers(source)[1],
			license = GetPlayerIdentifiers(source)[2],
			permission = permission:lower(),
		}
		CashoutCore.Functions.ExecuteSql(true, "DELETE FROM `permissions` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
		CashoutCore.Functions.ExecuteSql(true, "INSERT INTO `permissions` (`name`, `steam`, `license`, `permission`) VALUES ('"..GetPlayerName(source).."', '"..GetPlayerIdentifiers(source)[1].."', '"..GetPlayerIdentifiers(source)[2].."', '"..permission:lower().."')")
		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('CashoutCore:Client:OnPermissionUpdate', source, permission)
	end
end

CashoutCore.Functions.RemovePermission = function(source)
	local Player = CashoutCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		CashoutCore.Config.Server.PermissionList[GetPlayerIdentifiers(source)[1]] = nil	
		CashoutCore.Functions.ExecuteSql(true, "DELETE FROM `permissions` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
		Player.Functions.UpdatePlayerData()
	end
end

CashoutCore.Functions.HasPermission = function(source, permission)
	local retval = false
	local steamid = GetPlayerIdentifiers(source)[1]
	local licenseid = GetPlayerIdentifiers(source)[2]
	local permission = tostring(permission:lower())
	if permission == "user" then
		retval = true
	else
		if CashoutCore.Config.Server.PermissionList[steamid] ~= nil then 
			if CashoutCore.Config.Server.PermissionList[steamid].steam == steamid and CashoutCore.Config.Server.PermissionList[steamid].license == licenseid then
				if CashoutCore.Config.Server.PermissionList[steamid].permission == permission or CashoutCore.Config.Server.PermissionList[steamid].permission == "god" then
					retval = true
				end
			end
		end
	end
	return retval
end

CashoutCore.Functions.GetPermission = function(source)
	local retval = "user"
	Player = CashoutCore.Functions.GetPlayer(source)
	local steamid = GetPlayerIdentifiers(source)[1]
	local licenseid = GetPlayerIdentifiers(source)[2]
	if Player ~= nil then
		if CashoutCore.Config.Server.PermissionList[Player.PlayerData.steam] ~= nil then 
			if CashoutCore.Config.Server.PermissionList[Player.PlayerData.steam].steam == steamid and CashoutCore.Config.Server.PermissionList[Player.PlayerData.steam].license == licenseid then
				retval = CashoutCore.Config.Server.PermissionList[Player.PlayerData.steam].permission
			end
		end
	end
	return retval
end

CashoutCore.Functions.IsOptin = function(source)
	local retval = false
	local steamid = GetPlayerIdentifiers(source)[1]
	if CashoutCore.Functions.HasPermission(source, "admin") then
		retval = CashoutCore.Config.Server.PermissionList[steamid].optin
	end
	return retval
end

CashoutCore.Functions.ToggleOptin = function(source)
	local steamid = GetPlayerIdentifiers(source)[1]
	if CashoutCore.Functions.HasPermission(source, "admin") then
		CashoutCore.Config.Server.PermissionList[steamid].optin = not CashoutCore.Config.Server.PermissionList[steamid].optin
	end
end

CashoutCore.Functions.IsPlayerBanned = function (source)
	local retval = false
	local message = ""
	CashoutCore.Functions.ExecuteSql(true, "SELECT * FROM `bans` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."' OR `license` = '"..GetPlayerIdentifiers(source)[2].."' OR `ip` = '"..GetPlayerIdentifiers(source)[3].."'", function(result)
		if result[1] ~= nil then 
			if os.time() < result[1].expire then
				retval = true
				local timeTable = os.date("*t", tonumber(result[1].expire))
				message = "You have been banned from the server lol:\n"..result[1].reason.."\nBan expires "..timeTable.day.. "/" .. timeTable.month .. "/" .. timeTable.year .. " " .. timeTable.hour.. ":" .. timeTable.min .. "\n"
			else
				CashoutCore.Functions.ExecuteSql(true, "DELETE FROM `bans` WHERE `id` = "..result[1].id)
			end
		end
	end)
	return retval, message
end

