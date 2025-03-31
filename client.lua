local TASER_RANGE = 25.0 * 0.3048
local TASER_INCAP_TIME = 5000
local cartridges = 2
local taserWarningActive = false
local batteryLevel = 100
local isShooting = false
local displayHUD = false

local function updateHUD()
    SendNUIMessage({
        type = "updateHUD",
        data = {
            cartridges = cartridges,
            battery = batteryLevel,
            armed = taserWarningActive
        }
    })
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        
        if GetSelectedPedWeapon(ped) == GetHashKey('WEAPON_STUNGUN') then
            if not displayHUD then
                displayHUD = true
                SendNUIMessage({type = "showHUD", show = true})
            end
            updateHUD()
        elseif displayHUD then
            displayHUD = false
            SendNUIMessage({type = "showHUD", show = false})
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        
        if GetSelectedPedWeapon(ped) == GetHashKey('WEAPON_STUNGUN') then
            if cartridges <= 0 then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 257, true)
            elseif IsControlJustPressed(0, 24) and not isShooting then
                isShooting = true
                
                local postalData = GetResourceState('nearest-postal') == 'started' 
                    and exports['nearest-postal']:getPostal() or nil
                
                TriggerServerEvent('taser-x2:logIncident', {
                    officerName = GetPlayerName(PlayerId()),
                    postal = postalData
                })
                TriggerEvent('taser-x2:fire')
                Citizen.Wait(1000)
                isShooting = false
            end
        end
    end
end)

RegisterNetEvent('taser-x2:fire')
AddEventHandler('taser-x2:fire', function()
    local ped = PlayerPedId()
    
    if cartridges <= 0 then
        TriggerEvent('chat:addMessage', {args = {'^1TASER X2', 'No cartridges remaining! Use /reloadtaser to reload.'}})
        return
    end

    local success, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(
        StartShapeTestRay(
            GetEntityCoords(ped),
            GetOffsetFromEntityInWorldCoords(ped, 0.0, TASER_RANGE, 0.0),
            -1, ped, 0
        )
    )

    cartridges = cartridges - 1
    taserWarningActive = true
    batteryLevel = math.max(0, batteryLevel - 5)

    if hit and DoesEntityExist(entityHit) and IsEntityAPed(entityHit) then
        Citizen.SetTimeout(3000, function() taserWarningActive = false end)
        handleTaserHit(ped, entityHit)
    else
        Citizen.SetTimeout(1000, function() taserWarningActive = false end)
    end
end)

RegisterCommand('reloadtaser', function()
    if cartridges < 2 then
        cartridges = 2
        PlaySoundFrontend(-1, "WEAPON_PURCHASE", "HUD_AMMO_SHOP_SOUNDSET", 1)
        TriggerEvent('chat:addMessage', {args = {'TASER X2', 'Reloaded cartridges.'}})
    end
end, false)

RegisterCommand('rt', function() ExecuteCommand('reloadtaser') end, false)

TriggerEvent('chat:addSuggestion', '/reloadtaser', 'Reload your TASER (Alias: /rt)')
TriggerEvent('chat:addSuggestion', '/rt', 'Reload your TASER')
TriggerEvent('chat:addSuggestion', '/chargetaser', 'Charge your TASER')

RegisterNetEvent('taser-x2:chargeBattery')
AddEventHandler('taser-x2:chargeBattery', function()
    batteryLevel = 100
    TriggerEvent('chat:addMessage', {
        color = {0, 150, 255},
        args = {'TASER', '^4Charging Complete.'}
    })
end)

RegisterNetEvent('taser-x2:tased')
AddEventHandler('taser-x2:tased', function()
    SetPedToRagdoll(PlayerPedId(), TASER_INCAP_TIME, TASER_INCAP_TIME, 0, true, true, false)
end)

