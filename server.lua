local webhook = '' -- Your Discord webhook
local carritos = 0
local cooldown = 0
local esperar = false
local wait = 10000
local num

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		num = math.random(1111,9999)	
	end
end)

ESX.RegisterServerCallback('av_bobcat:zone', function(source,cb)
	cb(num)
end)

ESX.RegisterServerCallback('av_bobcat:c4', function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
		
	if xPlayer.getInventoryItem(Config.C4Name).count >= Config.C4amount then
		xPlayer.removeInventoryItem(Config.C4Name,Config.C4amount)
		cb(true)
	else
		TriggerClientEvent('av_bobcat:notify',source,Config.Lang['missing_c4'])
		cb(false)
	end	
end)

ESX.RegisterServerCallback('av_bobcat:cooldown', function(source,cb)
	local xPlayers = ESX.GetPlayers()
	local cops = 0
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == Config.PoliceJobName then
			cops = cops + 1
		end		
	end
		
	if cops >= Config.MinPolice and not esperar then
		if Config.NeedsBlowtorch then
			if xPlayer.getInventoryItem(Config.BlowtorchName).count >= 1 then	
				if Config.RemoveBlowtorch then
					xPlayer.removeInventoryItem(Config.BlowtorchName,1)
				end
				cb(false)			
			else
				cb(true)
			end
		else
			cb(false)
		end
	else
		TriggerClientEvent('av_bobcat:notify',source,Config.Lang['not_enough'])
		cb(true)
	end
end)

RegisterServerEvent('av_bobcat:notifypd')
AddEventHandler('av_bobcat:notifypd', function()
	TriggerClientEvent('av_bobcat:policeblip',-1)
end)

RegisterServerEvent('av_bobcat:efecto')
AddEventHandler('av_bobcat:efecto', function()
	TriggerClientEvent('av_bobcat:explosion',-1)
	local usuario = GetPlayerName(source)
	local content = {
        {
        	["color"] = '5015295',
            ["title"] = "**BOBCAT**",
            ["description"] = "**".. usuario .."** started the Bobcat Security Heist",
            ["footer"] = {
                ["text"] = "AV Scripts",
            },
        }
    }
  	PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = content}), { ['Content-Type'] = 'application/json' })	
	esperar = true
	print('^3[Bobcat Security]: ^2Cooldown started^0')
	cooldown = os.time()
end)

RegisterServerEvent('av_bobcat:MakeItRain')
AddEventHandler('av_bobcat:MakeItRain', function(z)
	if z ~= num then
		local usuario = GetPlayerName(source)
		local content = {
			{
				["color"] = '5015295',
				["title"] = "**Bobcat Heist**",
				["description"] = "**".. usuario .."** Using LUA Injector",
				["footer"] = {
					["text"] = "AV Scripts",
				},
			}
		}
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = content}), { ['Content-Type'] = 'application/json' })
		DropPlayer(source,'Using LUA Injector :(')
		return
	end
	local xPlayer = ESX.GetPlayerFromId(source)
	local dinero = Config.Money
	carritos = carritos + carritos
	if carritos <= 3 then
		xPlayer.addAccountMoney(Config.Account,dinero)
		TriggerClientEvent('av_bobcat:notify',source,Config.Lang['stole']..dinero)
	end
end)

Citizen.CreateThread(function()
	local t = Config.CooldownTime * 60
	local w = 10000
	while true do		
		Citizen.Wait(wait)
		if esperar then
			wait = 1000
			if (os.time() - cooldown) > t and cooldown ~= 0 then
				print('^3[Bobcat Security]: ^2Cooldown finished^0')
				TriggerClientEvent('av_bobcat:reset',-1)
				carritos = 0
				esperar = false
			end
		else
			wait = 10000
		end		
	end
end)