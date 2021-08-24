local fusibles, seguridad, boveda, puerta, dinero = false, true, false, false, false
local z
local guardias = {}
ESX = nil

Citizen.CreateThread(function()
	RequestIpl("prologue06_copy_milo_")	
 	local interiorid = GetInteriorAtCoords(277.75480000, 290.00350000, 104.55570000)
	ActivateInteriorEntitySet(interiorid, "dovux_vault_original")
 	RefreshInterior(interiorid)
	
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
	
	ESX.TriggerServerCallback('av_bobcat:zone', function(a)
		z = a
	end)
	if Config.Blip then
		blip = AddBlipForCoord(278.32, 307.86, 105.54)
		SetBlipSprite(blip, Config.BlipIcon)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.7)
		SetBlipColour(blip, Config.BlipColour)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.BlipText)
		EndTextCommandSetBlipName(blip)
	end
	
	exports["bt-polyzone"]:AddBoxZone("BobcatCaja", vector3(272.46569824219, 309.5471496582, 105.5463180542), 3.6, 3.2, {
		name="BobcatCaja",
		heading=160.00,
		debugPoly=false,
		minZ=104.02,
		maxZ=106.72
	})
	exports["bt-polyzone"]:AddBoxZone("BobcatBoveda", vector3(273.55325317383, 282.67510986328, 105.55572509766), 3.6, 3.2, {
		name="BobcatBoveda",
		heading=344.00,
		debugPoly=false,
		minZ=104.02,
		maxZ=106.72
	})
	
	exports["bt-polyzone"]:AddBoxZone("DineroFondo", vector3(276.25430297852, 291.91101074219, 105.79623413086), 2.2, 1.7, {
		name="DineroFondo",
		heading=340.00,
		debugPoly=false,
		minZ=104.02,
		maxZ=106.72
	})
	
	exports["bt-polyzone"]:AddBoxZone("DineroDerecha", vector3(276.77792358398, 286.67990112305, 105.55562591553), 2.2, 1.7, {
		name="DineroDerecha",
		heading=244.00,
		debugPoly=false,
		minZ=104.02,
		maxZ=106.72
	})
	
	exports["bt-polyzone"]:AddBoxZone("DineroIzquierda", vector3(272.6955871582, 286.95715332031, 105.55558013916), 2.2, 1.7, {
		name="DineroIzquierda",
		heading=83.00,
		debugPoly=false,
		minZ=104.02,
		maxZ=106.72
	})
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('bt-polyzone:enter')
AddEventHandler('bt-polyzone:enter', function(name)
	if name == "BobcatCaja" then
		fusibles = true
		paso1()
	elseif name == "BobcatBoveda" then
		if not seguridad then
			boveda = true
			paso2()
		end
	elseif name == "DineroFondo" then
		dinero = true
		Trolley3D()
	elseif name == "DineroDerecha" then
		dinero = true
		Trolley3D()
	elseif name == "DineroIzquierda" then
		dinero = true
		Trolley3D()
	end
end)

RegisterNetEvent('bt-polyzone:exit')
AddEventHandler('bt-polyzone:exit', function(name)
	if name == "BobcatCaja" then
		fusibles = false
	elseif name == "BobcatBoveda" then
		boveda = false
	elseif name == "DineroFondo" then
		dinero = false		
	elseif name == "DineroDerecha" then
		dinero = false		
	elseif name == "DineroIzquierda" then
		dinero = false
	end
end)

function paso1()
	local robando = false
	while fusibles do
		if not seguridad then return end
		if #(GetEntityCoords(PlayerPedId()) - vector3(272.46081542969, 309.45129394531, 105.54658508301)) < 2 and not robando then
			DrawText3Ds(272.46081542969, 309.45129394531, 105.54658508301, Config.Lang['sabotage'])
			if IsControlJustPressed(0,38) then
				ESX.TriggerServerCallback('av_bobcat:cooldown', function(cooldown)
					if not cooldown then
						robando = true					
						FreezeEntityPosition(PlayerPedId(), true)
						TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_WELDING', -1, true)
						Citizen.Wait(4500)
						ClearPedTasksImmediately(PlayerPedId())
						FreezeEntityPosition(PlayerPedId(), false)
						if Config.SpawnGuards then
							SpawnGuardias()
						end
						seguridad = false
						TriggerServerEvent('av_bobcat:notifypd')
						TriggerEvent('av_bobcat:notify',Config.Lang['install_c4'])
					end
				end)
			end
		end
		Citizen.Wait(4)
	end
end

function paso2()
	local robando = false
	while boveda do
		if puerta then return end
		if #(GetEntityCoords(PlayerPedId()) - vector3(273.43786621094, 282.79684448242, 105.55565643311)) < 2 then
			DrawText3Ds(273.43786621094, 282.79684448242, 105.55565643311, Config.Lang['c4'])
			if IsControlJustPressed(0,38) and not robando then
				ESX.TriggerServerCallback('av_bobcat:c4', function(item)	
					if item then
						robando = true
						puerta = true		
						SetEntityHeading(PlayerPedId(), 340.11)
						carritos()
						anim()
						if Config.SpawnGuards then
							for i = 1, #guardias do
								SetEntityAsNoLongerNeeded(guardias[i])
							end
						end
					end
				end)
			end
		end
		Citizen.Wait(4)
	end
end

function SpawnGuardias()
	local p = PlayerPedId()
	ClearAreaOfEverything(268.23, 300.27, 105.55, 50.0, true, true, true, true)
	SetPedRelationshipGroupHash(p, GetHashKey("PLAYER"))
	AddRelationshipGroup('Guardias')
	for i=1, #Config.Guards do
		local guardia = Config.Guards[i]
		RequestModel(GetHashKey(guardia.ped))
		while not HasModelLoaded(GetHashKey(guardia.ped)) do
			Wait(1)
		end
		guardias[i] = CreatePed(4, GetHashKey(guardia.ped), guardia.pos[1], guardia.pos[2], guardia.pos[3], guardia.pos[4], false, true)
		NetworkRegisterEntityAsNetworked(guardias[i])
		SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(guardias[i]), true)
		SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(guardias[i]), true)
		SetPedCanSwitchWeapon(guardias[i], true)
		SetPedArmour(guardias[i], guardia.armour)
		SetPedAccuracy(guardias[i], math.random(70,90))
		SetEntityInvincible(guardias[i], false)
		SetEntityVisible(guardias[i], true)
		SetEntityAsMissionEntity(guardias[i])
		GiveWeaponToPed(guardias[i], GetHashKey(guardia.weapon), 255, false, false)
		SetPedDropsWeaponsWhenDead(guardias[i], false)
		SetPedFleeAttributes(guardias[i], 0, false)	
		SetPedRelationshipGroupHash(guardias[i], GetHashKey("Guardias"))	
		TaskGuardCurrentPosition(guardias[i], 5.0, 5.0, 1)
	end
	Citizen.Wait(1000)
	SetRelationshipBetweenGroups(0, GetHashKey("Guardias"), GetHashKey("Guardias"))
	SetRelationshipBetweenGroups(5, GetHashKey("Guardias"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("Guardias"))	

end

function carritos()
	RequestModel("hei_prop_hei_cash_trolly_01")
	Citizen.Wait(100)	
	Money1 = CreateObject(269934519, 276.92, 286.64, 104.55, 1, 0, 0) -- 1st Derecha
	Money2 = CreateObject(269934519, 276.27, 291.96, 104.55, 1, 0, 0) -- 1nd Izquierda	
	Money3 = CreateObject(269934519, 272.67, 286.92, 104.55, 1, 0, 0) -- 2do Derecha
end

function Trolley3D()
	local coords = GetEntityCoords(PlayerPedId())
	Trolley = GetClosestObjectOfType(coords, 2.0, 269934519, false, false, false) -- 1st Right
	local TrolleyCoords = GetEntityCoords(Trolley)
	Citizen.CreateThread(function()
		while dinero do	
			Citizen.Wait(5)						
			DrawText3Ds(TrolleyCoords.x, TrolleyCoords.y, TrolleyCoords.z + 1.0,Config.Lang['loot'])
			if IsControlJustPressed(0, 38) then	
				Lootear(Trolley)			
			end
		end
	end)
end

function Lootear(MoneyTrolley)
    Grab2clear = false
    Grab3clear = false
    Money = MoneyTrolley
    local ped = PlayerPedId()
    local model = "hei_prop_heist_cash_pile"

	local function AnimDinero()
	    local pedCoords = GetEntityCoords(ped)
        local grabmodel = GetHashKey(model)

        RequestModel(grabmodel)
        while not HasModelLoaded(grabmodel) do
            Citizen.Wait(100)
        end
	    local grabobj = CreateObject(grabmodel, pedCoords, true)
	    FreezeEntityPosition(grabobj, true)
	    SetEntityInvincible(grabobj, true)
	    SetEntityNoCollisionEntity(grabobj, ped)
	    SetEntityVisible(grabobj, false, false)
	    AttachEntityToEntity(grabobj, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
	    local startedGrabbing = GetGameTimer()
	    Citizen.CreateThread(function()
		    while GetGameTimer() - startedGrabbing < 37000 do
			    Citizen.Wait(1)
			    DisableControlAction(0, 73, true)
			    if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
				    if not IsEntityVisible(grabobj) then
					    SetEntityVisible(grabobj, true, false)
				    end
			    end
			    if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
				    if IsEntityVisible(grabobj) then
                        SetEntityVisible(grabobj, false, false)                   
				    end
			    end
		    end
		    DeleteObject(grabobj)
			TriggerServerEvent("av_bobcat:MakeItRain",z)
			dinero = false
	    end)
    end
    local emptyobj = 769923921
	
	if IsEntityPlayingAnim(Money, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 3) then
		return
    end
    local baghash = GetHashKey("hei_p_m_bag_var22_arm_s")

    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    RequestModel(baghash)
    RequestModel(emptyobj)
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(emptyobj) and not HasModelLoaded(baghash) do
        Citizen.Wait(100)
    end
    while not NetworkHasControlOfEntity(Money) do
		Citizen.Wait(1)
		NetworkRequestControlOfEntity(Money)
	end
	GrabBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), GetEntityCoords(PlayerPedId()), true, false, false)
    Grab1 = NetworkCreateSynchronisedScene(GetEntityCoords(Money), GetEntityRotation(Money), 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(ped, Grab1, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(GrabBag, Grab1, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
	NetworkStartSynchronisedScene(Grab1)
	Citizen.Wait(1500)
	AnimDinero()
    if not Grab2clear then
        Grab2 = NetworkCreateSynchronisedScene(GetEntityCoords(Money), GetEntityRotation(Money), 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, Grab2, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(GrabBag, Grab2, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
        NetworkAddEntityToSynchronisedScene(Money, Grab2, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(Grab2)
        Citizen.Wait(37000)
    end
    if not Grab3clear then
        Grab3 = NetworkCreateSynchronisedScene(GetEntityCoords(Money), GetEntityRotation(Money), 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, Grab3, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(GrabBag, Grab3, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(Grab3)
        NewTrolley = CreateObject(emptyobj, GetEntityCoords(Money) + vector3(0.0, 0.0, - 0.985), true, false, false)
        SetEntityRotation(NewTrolley, GetEntityRotation(Money))
        while not NetworkHasControlOfEntity(Money) do
            Citizen.Wait(1)
            NetworkRequestControlOfEntity(Money)
        end
        DeleteObject(Money)
        while DoesEntityExist(Money) do
            Citizen.Wait(1)
            DeleteObject(Money)
        end
        PlaceObjectOnGroundProperly(NewTrolley)
    end
	Citizen.Wait(1800)
	if DoesEntityExist(GrabBag) then
        DeleteEntity(GrabBag)
    end
    SetPedComponentVariation(ped, 5, 45, 0, 0)
	RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
	SetModelAsNoLongerNeeded(emptyobj)
	SetModelAsNoLongerNeeded(GetHashKey("hei_p_m_bag_var22_arm_s"))
end

function anim()
	local c4prop = nil
	local c4prop2 = nil
	local ped = PlayerPedId()
	RequestModel("ch_prop_ch_explosive_01a")
	while not HasModelLoaded("ch_prop_ch_explosive_01a") do
		RequestModel("ch_prop_ch_explosive_01a")
		Citizen.Wait(0)
	end
	LoadAnim("anim_heist@hs3f@ig8_vault_explosives@right@male@")
	local plyPos = GetEntityCoords(ped)
	local fwd, _, _, pos = GetEntityMatrix(ped)
	local newPos = (fwd * 0.35) + pos 
	SetEntityCoords(ped, newPos.xy, newPos.z)
	
	SetPedComponentVariation(ped, 5, -1, 0, 0)
	c4prop = CreateObject(GetHashKey("ch_prop_ch_explosive_01a"), plyPos.x, plyPos.y, plyPos.z-0.04,  true,  true, false)
	bolso = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), plyPos.x, plyPos.y, plyPos.z-0.04,  true,  true, false)
	SetEntityCollision(c4prop, 0, 1)
	SetEntityCollision(bolso, 0, 1)
	
	local rot = vec3(180.0, 180.0, -110.0)
	
	local entrada = NetworkCreateSynchronisedScene(newPos.xy, plyPos.z+0.5, rot, 2, 0, 0, 1065353216, 0, 1.3)	
	NetworkAddPedToSynchronisedScene(ped, entrada, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "player_ig8_vault_explosive_enter", 4.0, -4.0, 1033, 0, 1000.0, 0)
	NetworkAddEntityToSynchronisedScene(bolso, entrada, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "bag_ig8_vault_explosive_enter", 1.0, -1.0, 0, 0)
	NetworkAddEntityToSynchronisedScene(c4prop, entrada, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "semtex_a_ig8_vault_explosive_enter", 1.0, -1.0, 0, 0)
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local c4uno = NetworkCreateSynchronisedScene(newPos.xy, plyPos.z+0.5, rot, 2, 0, 0, 1065353216, 0, 1.3)	
	NetworkAddPedToSynchronisedScene(ped, c4uno, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "player_ig8_vault_explosive_plant_a", 4.0, -4.0, 1033, 0, 1000.0, 0)
	NetworkAddEntityToSynchronisedScene(bolso, c4uno, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "bag_ig8_vault_explosive_plant_a", 1.0, -1.0, 0, 0)
	NetworkAddEntityToSynchronisedScene(c4prop, c4uno, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "semtex_a_ig8_vault_explosive_plant_a", 1.0, -1.0, 0, 0)
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local c4dos = NetworkCreateSynchronisedScene(newPos.xy, plyPos.z+0.5, rot, 2, 0, 0, 1065353216, 0, 1.3)	
	NetworkAddPedToSynchronisedScene(ped, c4dos, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "player_ig8_vault_explosive_plant_b", 4.0, -4.0, 1033, 0, 1000.0, 0)
	NetworkAddEntityToSynchronisedScene(bolso, c4dos, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "bag_ig8_vault_explosive_plant_b", 1.0, -1.0, 0, 0)
		
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	ForceEntityAiAndAnimationUpdate(bolso)
	ForceEntityAiAndAnimationUpdate(c4prop)
	NetworkStartSynchronisedScene(entrada)
	Citizen.Wait(1200)
	
	ForceEntityAiAndAnimationUpdate(bolso)
	ForceEntityAiAndAnimationUpdate(c4prop)
	NetworkStartSynchronisedScene(c4uno)
	Citizen.Wait(2000)
	
	FreezeEntityPosition(c4prop, 1)
	SetEntityCollision(c4prop, 0, 1)
	
	c4prop2 = CreateObject(GetHashKey("ch_prop_ch_explosive_01a"), plyPos.x, plyPos.y, plyPos.z-0.04,  true,  true, false)
	SetEntityCollision(c4prop2, 0, 1)
	NetworkAddEntityToSynchronisedScene(c4prop2, c4dos, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "semtex_b_ig8_vault_explosive_plant_b", 1.0, -1.0, 0, 0)
	ForceEntityAiAndAnimationUpdate(c4prop2)
	ForceEntityAiAndAnimationUpdate(bolso)
	NetworkStartSynchronisedScene(c4dos)
	Citizen.Wait(2000)
	FreezeEntityPosition(c4prop2, 1)
	SetEntityCollision(c4prop2, 0, 1)
	
	Citizen.Wait(100)

	DeleteObject(bolso)
	SetPedComponentVariation(ped, 5, 45, 0, 0)
	Citizen.Wait(5000)
	TriggerServerEvent('av_bobcat:efecto')
	Citizen.Wait(50)
	DeleteObject(c4prop)
	DeleteObject(c4prop2)
end

RegisterNetEvent('av_bobcat:explosion')
AddEventHandler('av_bobcat:explosion', function()
	local interiorid = GetInteriorAtCoords(277.75480000, 290.00350000, 104.55570000)
	if #(GetEntityCoords(PlayerPedId()) - vector3(273.57418823242, 282.86407470703, 105.55570220947)) < 100 then	
		RequestNamedPtfxAsset('scr_josh3')
		while not HasNamedPtfxAssetLoaded('scr_josh3') do
			Citizen.Wait(1)
		end	
		UseParticleFxAssetNextCall('scr_josh3')
		explo1 = StartParticleFxLoopedAtCoord("scr_josh3_explosion", 273.57418823242, 282.86407470703, 105.55570220947, 0.0, 0.0, 0.0, 3.0, false, false, false, 0)		
		SetStateOfRayfireMapObject(handle, 6) 
		SetStateOfRayfireMapObject(handle2, 6)
		PlaySoundFromCoord(-1, "MAIN_EXPLOSION_CHEAP", 273.57418823242, 282.86407470703, 105.55570220947, 0, 0, 100, 0)
		DeactivateInteriorEntitySet(interiorid, "dovux_vault_original")
		ActivateInteriorEntitySet(interiorid, "dovux_vault_broken")
		RefreshInterior(interiorid)
	end
end)

RegisterNetEvent('av_bobcat:reset')
AddEventHandler('av_bobcat:reset', function()
	local interiorid = GetInteriorAtCoords(277.75480000, 290.00350000, 104.55570000)
	DeactivateInteriorEntitySet(interiorid, "dovux_vault_broken")
	ActivateInteriorEntitySet(interiorid, "dovux_vault_original") 
	RefreshInterior(interiorid)
end)

RegisterNetEvent('av_bobcat:policeblip')
AddEventHandler('av_bobcat:policeblip', function()
	if Config.PoliceJobName == ESX.PlayerData.job.name then
		TriggerEvent('av_bobcat:notify',Config.Lang['cops_notification'])
		blipRobbery = AddBlipForCoord(272.67, 307.96, 105.07)
		SetBlipSprite(blipRobbery, 161)
		SetBlipScale(blipRobbery, 3.0)
		SetBlipColour(blipRobbery, 3)
		PulseBlip(blipRobbery)
		Wait(60000)
		RemoveBlip(blipRobbery)
	end
end)

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function LoadAnim(animDict)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        local interiorid = GetInteriorAtCoords(277.75480000, 290.00350000, 104.55570000)
		DeactivateInteriorEntitySet(interiorid, "dovux_vault_broken")
		ActivateInteriorEntitySet(interiorid, "dovux_vault_original") 
		RefreshInterior(interiorid)
    end
end)