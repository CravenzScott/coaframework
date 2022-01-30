CashoutCore = {}
CashoutCore.PlayerData = {}
CashoutCore.Config = CashoutConfig
CashoutCore.Shared = CashoutShared
CashoutCore.ServerCallbacks = {}

isLoggedIn = false

function GetCoreObject()
	return CashoutCore
end

RegisterNetEvent('CashoutCore:GetObject')
AddEventHandler('CashoutCore:GetObject', function(cb)
	cb(GetCoreObject())
end)

RegisterNetEvent('CashoutCore:Client:OnPlayerLoaded')
AddEventHandler('CashoutCore:Client:OnPlayerLoaded', function()
	ShutdownLoadingScreenNui()
	isLoggedIn = true
end)

RegisterNetEvent('CashoutCore:Client:OnPlayerUnload')
AddEventHandler('CashoutCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)
