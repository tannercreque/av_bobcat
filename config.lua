Config = {}


Config.Blip = true 
Config.BlipIcon = 108
Config.BlipColour = 5
Config.BlipText = 'Bobcat Security'

Config.MinPolice = 0
Config.PoliceJobName = 'police' 
Config.CooldownTime = 60

Config.NeedsBlowtorch = false
Config.BlowtorchName = 'blowtorch'
Config.RemoveBlowtorch = false 

Config.NeedsC4 = false 
Config.C4amount = 2 
Config.C4Name = 'c4' 
Config.RemoveC4 = true 

Config.SpawnGuards = true 
Config.Guards = {
	[1] = {
		pos = {266.00, 298.79, 105.55, 275.35},
		ped = 'mp_s_m_armoured_01',
		weapon = 'WEAPON_PISTOL',
		armour = 100
	},
	[2] = {
		pos = {269.62, 292.94, 105.55, 344.74},
		ped = 's_m_m_armoured_02',
		weapon = 'WEAPON_PISTOL',
		armour = 100
	},
	[3] = {
		pos = {272.99, 300.26, 105.55, 74.10},
		ped = 'mp_s_m_armoured_01',
		weapon = 'WEAPON_PISTOL',
		armour = 100
	},
	[4] = {
		pos = {272.92, 306.76, 105.55, 144.07},
		ped = 's_m_m_armoured_02',
		weapon = 'WEAPON_PISTOL',
		armour = 100
	},
}

Config.Money = math.random(20000,32000) 
Config.Account = 'black_money' 

Config.Lang = {
	['sabotage'] = 'Press ~r~[E]~w~ to sabotage',
	['missing_blowtorch'] = 'You need a blowtorch',
	['install_c4'] = 'Install C4 on vault to open',
	['c4'] = 'Press ~r~[E]~w~ to install C4',
	['missing_c4'] = 'You need C4',
	['stole'] = 'You stole $',
	['loot'] = 'Press ~r~[E]~w~ to loot',
	['cooldown_active'] = 'Cooldown active',
	['not_enough'] = 'Not enough cops online',
	['cops_notification'] = 'Robbery started at Bobcat Security'
}

RegisterNetEvent('av_bobcat:notify')
AddEventHandler('av_bobcat:notify', function(msg)
	exports['mythic_notify']:SendAlert('inform',msg)
end)