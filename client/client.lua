ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local IsHandcuffed = false
local handcuffTimer = {}

local HandcuffTime = 10 * 60000 -- 10 mins

--Check Nearby Player To Handcuff
RegisterNetEvent("cy_handcuff:handcuff")
AddEventHandler("cy_handcuff:handcuff", function()
    local target, distance = ESX.Game.GetClosestPlayer()
    local ped = PlayerPedId()
    local playerheading = GetEntityHeading(ped)
    local playerlocation = GetEntityForwardVector(ped)
    local playerCoords = GetEntityCoords(ped)
    local target_id = GetPlayerServerId(target)

    if distance <= 2.0 then
        TriggerServerEvent('cy_handcuff:arrestnearby', target_id, playerheading, playerCoords, playerlocation)
    else
        exports['mythic_notify']:SendAlert('error','你需靠近目標才能解銬')
    end
end)

--Uncuff Nearby Player That Are Cuffed
RegisterNetEvent("cy_handcuff:uncuff")
AddEventHandler("cy_handcuff:uncuff", function()
    local target, distance = ESX.Game.GetClosestPlayer()
    local ped = PlayerPedId()
    local playerheading = GetEntityHeading(ped)
    local playerlocation = GetEntityForwardVector(ped)
    local playerCoords = GetEntityCoords(ped)
    local target_id = GetPlayerServerId(target)

    if distance <= 2.0 then
        TriggerServerEvent('cy_handcuff:releasenearby', target_id, playerheading, playerCoords, playerlocation)
    else
        exports['mythic_notify']:SendAlert('error','你需靠近目標才能上銬')
    end
end)

--Arrest Nearby Player
RegisterNetEvent('cy_handcuff:arrestTarget')
AddEventHandler('cy_handcuff:arrestTarget', function(playerheading, playercoords, playerlocation)
	local ped = PlayerPedId()
	SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(ped, x, y, z)
	SetEntityHeading(ped, playerheading)
	Citizen.Wait(250)
	loadanimdict('mp_arrest_paired')
	TaskPlayAnim(ped, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750 , 2, 0, 0, 0, 0)
	Citizen.Wait(3760)
	IsHandcuffed = true
	TriggerEvent('cy_handcuff:cuffPlayer')
	loadanimdict('mp_arresting')
	TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
end)

--Count Time
RegisterNetEvent('cy_handcuff:cuffPlayer')
AddEventHandler('cy_handcuff:cuffPlayer', function()
	local playerPed = PlayerPedId()

	Citizen.CreateThread(function()
		if IsHandcuffed then
            if handcuffTimer.active then
                ESX.ClearTimeout(handcuffTimer.task)
            end

			StartHandcuffTimer()
		else
			if handcuffTimer.active then
				ESX.ClearTimeout(handcuffTimer.task)
			end

		end
	end)
end)

--Source itself do the arresting animation
RegisterNetEvent('cy_handcuff:doarrestinganim')
AddEventHandler('cy_handcuff:doarrestinganim', function()
	Citizen.Wait(250)
	loadanimdict('mp_arrest_paired')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
		TriggerEvent("mythic_progbar:client:progress", {
        name = "doarrestinganim",
        duration = 3750,
        label = "上銬中",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "",
            anim = "",
        },
        prop = {
            model = "",
        }
    }, function(status)
    end)
	Citizen.Wait(3000)
end) 

--Handcuff Timer (Will uncuff the player after a certain amount of time)
function StartHandcuffTimer()
	if handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(HandcuffTime, function()
		TriggerEvent("cy_handcuff:uncuffPlayer")
		handcuffTimer.active = false
	end)
end

--Uncuff Player
RegisterNetEvent('cy_handcuff:uncuffPlayer')
AddEventHandler('cy_handcuff:uncuffPlayer', function()
	if IsHandcuffed then
		local playerPed = PlayerPedId()
		IsHandcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

--Nearby Target get uncuffed
RegisterNetEvent('cy_handcuff:uncuffTarget')
AddEventHandler('cy_handcuff:uncuffTarget', function(playerheading, playercoords, playerlocation)
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
    local ped = PlayerPedId()
	SetEntityCoords(ped, x, y, z)
	SetEntityHeading(ped, playerheading)
	Citizen.Wait(250)
	loadanimdict('mp_arresting')
	TaskPlayAnim(ped, 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Citizen.Wait(5500)
	IsHandcuffed = false
	TriggerEvent('cy_handcuff:cuffPlayer')
	ClearPedTasks(ped)
end)

--Uncuff Animation for source
RegisterNetEvent('cy_handcuff:uncuffanim')
AddEventHandler('cy_handcuff:uncuffanim', function()
	Citizen.Wait(250)
	loadanimdict('mp_arresting')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
    TriggerEvent("mythic_progbar:client:progress", {
        name = "uncuffanim",
        duration = 5500,
        label = "解銬中",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "",
            anim = "",
        },
        prop = {
            model = "",
        }
    }, function(status)
        if not status then
            ClearPedTasksImmediately(PlayerPedId())
        end
    end)
end)

--Load anim function
function loadanimdict(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname) 
		while not HasAnimDictLoaded(dictname) do 
			Citizen.Wait(1)
		end
	end
end

--Disable Player Control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if IsHandcuffed then
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, false) -- Attack
			DisableControlAction(0, 257, false) -- Attack 2
			DisableControlAction(0, 25, false) -- Aim
			DisableControlAction(0, 263, false) -- Melee Attack 1

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, false) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(500)
		end
	end
end)
