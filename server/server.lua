ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('handcuff', function(source)
    TriggerClientEvent("cy_handcuff:handcuff", source)
end)

ESX.RegisterUsableItem('handcuff_key', function(source)
    TriggerClientEvent("cy_handcuff:uncuff", source)
end)

RegisterServerEvent("cy_handcuff:arrestnearby")
AddEventHandler("cy_handcuff:arrestnearby", function(targetid, playerheading, playerCoords,  playerlocation)
    local _source = source
    TriggerClientEvent("cy_handcuff:arrestTarget", targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent("cy_handcuff:doarrestinganim", _source)
end)

RegisterServerEvent('cy_handcuff:releasenearby')
AddEventHandler('cy_handcuff:releasenearby', function(targetid, playerheading, playerCoords,  playerlocation)
    local _source = source
    TriggerClientEvent('cy_handcuff:uncuffTarget', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('cy_handcuff:uncuffanim', _source)
end)
