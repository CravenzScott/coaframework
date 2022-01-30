-- CashoutCore Command Events
RegisterNetEvent('CashoutCore:Command:TeleportToPlayer')
AddEventHandler('CashoutCore:Command:TeleportToPlayer', function(othersource)
	local coords = CashoutCore.Functions.GetCoords(GetPlayerPed(GetPlayerFromServerId(othersource)))
	local entity = GetPlayerPed(-1)
	if IsPedInAnyVehicle(Entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, coords.x, coords.y, coords.z)
	SetEntityHeading(entity, coords.a)
end)

RegisterNetEvent('CashoutCore:Command:TeleportToCoords')
AddEventHandler('CashoutCore:Command:TeleportToCoords', function(x, y, z)
	local entity = GetPlayerPed(-1)
	if IsPedInAnyVehicle(Entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, x, y, z)
end)

RegisterNetEvent('CashoutCore:Command:SpawnVehicle')
AddEventHandler('CashoutCore:Command:SpawnVehicle', function(model)
	CashoutCore.Functions.SpawnVehicle(model, function(vehicle)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
	end)
end)

RegisterNetEvent('CashoutCore:Command:DeleteVehicle')
AddEventHandler('CashoutCore:Command:DeleteVehicle', function()
	local vehicle = CashoutCore.Functions.GetClosestVehicle()
	if IsPedInAnyVehicle(GetPlayerPed(-1)) then vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false) else vehicle = CashoutCore.Functions.GetClosestVehicle() end
	-- TriggerServerEvent('CashoutCore:Command:CheckOwnedVehicle', GetVehicleNumberPlateText(vehicle))
	CashoutCore.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent('CashoutCore:Command:Revive')
AddEventHandler('CashoutCore:Command:Revive', function()
	local coords = CashoutCore.Functions.GetCoords(GetPlayerPed(-1))
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.a, true, false)
	SetPlayerInvincible(GetPlayerPed(-1), false)
	ClearPedBloodDamage(GetPlayerPed(-1))
end)

RegisterNetEvent('CashoutCore:Command:GoToMarker')
AddEventHandler('CashoutCore:Command:GoToMarker', function()
	Citizen.CreateThread(function()
		local entity = PlayerPedId()
		if IsPedInAnyVehicle(entity, false) then
			entity = GetVehiclePedIsUsing(entity)
		end
		local success = false
		local blipFound = false
		local blipIterator = GetBlipInfoIdIterator()
		local blip = GetFirstBlipInfoId(8)

		while DoesBlipExist(blip) do
			if GetBlipInfoIdType(blip) == 4 then
				cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
				blipFound = true
				break
			end
			blip = GetNextBlipInfoId(blipIterator)
		end

		if blipFound then
			DoScreenFadeOut(250)
			while IsScreenFadedOut() do
				Citizen.Wait(250)
			end
			local groundFound = false
			local yaw = GetEntityHeading(entity)
			
			for i = 0, 1000, 1 do
				SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
				SetEntityRotation(entity, 0, 0, 0, 0 ,0)
				SetEntityHeading(entity, yaw)
				SetGameplayCamRelativeHeading(0)
				Citizen.Wait(0)
				--groundFound = true
				if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
					cz = ToFloat(i)
					groundFound = true
					break
				end
			end
			if not groundFound then
				cz = -300.0
			end
			success = true
		end

		if success then
			SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
			SetGameplayCamRelativeHeading(0)
			if IsPedSittingInAnyVehicle(PlayerPedId()) then
				if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
					SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
				end
			end
			--HideLoadingPromt()
			DoScreenFadeIn(250)
		end
	end)
end)

-- Other stuff
RegisterNetEvent('CashoutCore:Player:SetPlayerData')
AddEventHandler('CashoutCore:Player:SetPlayerData', function(val)
	CashoutCore.PlayerData = val
end)

RegisterNetEvent('CashoutCore:Player:UpdatePlayerData')
AddEventHandler('CashoutCore:Player:UpdatePlayerData', function()
	local data = {}
	data.position = CashoutCore.Functions.GetCoords(GetPlayerPed(-1))
	TriggerServerEvent('CashoutCore:UpdatePlayer', data)
end)

RegisterNetEvent('CashoutCore:Player:UpdatePlayerPosition')
AddEventHandler('CashoutCore:Player:UpdatePlayerPosition', function()
	local position = CashoutCore.Functions.GetCoords(GetPlayerPed(-1))
	TriggerServerEvent('CashoutCore:UpdatePlayerPosition', position)
end)

RegisterNetEvent('CashoutCore:Client:LocalOutOfCharacter')
AddEventHandler('CashoutCore:Client:LocalOutOfCharacter', function(playerId, playerName, message)
	local sourcePos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerId)), false)
    local pos = GetEntityCoords(GetPlayerPed(-1), false)
    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z, true) < 20.0) then
		TriggerEvent("chatMessage", "OOC | " .. playerName, "normal", message)
    end
end)

RegisterNetEvent('CashoutCore:Notify')
AddEventHandler('CashoutCore:Notify', function(text, type, length)
	CashoutCore.Functions.Notify(text, type, length)
end)

RegisterNetEvent('CashoutCore:Client:TriggerCallback')
AddEventHandler('CashoutCore:Client:TriggerCallback', function(name, ...)
	if CashoutCore.ServerCallbacks[name] ~= nil then
		CashoutCore.ServerCallbacks[name](...)
		CashoutCore.ServerCallbacks[name] = nil
	end
end)

RegisterNetEvent("CashoutCore:Client:UseItem")
AddEventHandler('CashoutCore:Client:UseItem', function(item)
	TriggerServerEvent("CashoutCore:Server:UseItem", item)
end)