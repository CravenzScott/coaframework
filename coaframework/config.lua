-- very old way of doing a framework config, this derives from 2018 style, haha, not very good to use but fuck it
--vinny
-----------------------------------------------------
CashoutConfig = {}

CashoutConfig.MaxPlayers = GetConvarInt('sv_maxclients', 64)

CashoutConfig.IdentifierType = "steam" 

CashoutConfig.DefaultSpawn = {x=-1035.71,y=-2731.87,z=12.86,a=0.0}

CashoutConfig.Money = {}

CashoutConfig.Money.MoneyTypes = {['cash'] = 650, ['bank'] = 500, ['crypto'] = 0 } -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
CashoutConfig.Money.DontAllowMinus = {'cash', 'bank', 'crypto'}

CashoutConfig.Player = {}

CashoutConfig.Player.MaxWeight = 120000

CashoutConfig.Player.MaxInvSlots = 41 

CashoutConfig.Player.Bloodtypes = {"A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", }

CashoutConfig.Server = {} 

CashoutConfig.Server.closed = false 

CashoutConfig.Server.closedReason = "Doing tests - Vincent" 

CashoutConfig.Server.uptime = 0 

CashoutConfig.Server.whitelist = false

CashoutConfig.Server.discord = "https://discord.gg/6vxgUTg" 

CashoutConfig.Server.PermissionList = {} 
