-- Any target system (ox_target, qb-target, ...) and menu through community_bridge
local Target = exports.community_bridge:Target()

-----------
----BIN----
-----------
CreateThread(function()
    local targetOptions = {
        {
            name = 'lb_dumpster_dive',
            label = Lang:t('target.label'),
            icon = 'fas fa-dumpster',
            distance = 1.5,
            onSelect = function(ent)
                CreateThread(function()
                    if GetDumpsterState(ObjToNet(ent)) then
                        return notify(Lang:t('notifies.already_dived'), 'error')
                    end

                    isBusy = true
                    PoliceAlert()

                    if not Config.Minigame or Config.Minigame == 'none' or MiniGame() then
                        ProgressBar(ent)
                    else
                        notify(Lang:t('notifies.failed_minigame'), 'error')
                        isBusy = false
                    end
                end)
            end,
            canInteract = function()
                return not isBusy
            end
        }
    }

    -- Only add the "Open Dumpster" option if Config.Storage is true
    if Config.Storage then
        table.insert(targetOptions, {
            name = 'lb_dumpster_storage',
            icon = "far fa-trash-alt",
            label = "Open Dumpster",
            distance = 1.5,
            onSelect = function() TriggerEvent('lb-dumpster:client:open:Dumpster:storage') end,
        })
    end

    Target.AddModel(Config.Props, targetOptions)
end)


RegisterNetEvent('lb-dumpster:client:ResetEntity', function(netId)
    if NetworkGetEntityIsNetworked(netId) then NetworkUnregisterNetworkedEntity(netId) end
end)

-----------
----BUM----
-----------
CreateThread(function()
    Target.AddModel(Config.pedModels, {
        {
            name = 'lb_dumpster_sell',
            icon = "fa-solid fa-location-dot",
            label = "Sell Trash",
            distance = 2.5,
            onSelect = function() TriggerEvent('lb-dumpster:client:MainMenu') end,
        },
    })
end)

RegisterNetEvent('lb-dumpster:client:MainMenu', function()
    local MainMenu = {
        {
            isMenuHeader = true,
            header = "Sell Trash"
        },
        {
            header = "Sell me all your shit",
            txt = "",
            icon = "fa-solid fa-bars",
            params = {
                isServer = true,
                event = "lb-dumpster:server:sellItems",
            }
        },
    }

    -- community_bridge opens this qb-menu style table with whatever menu the server runs
    exports.community_bridge:Menu().Open(MainMenu, true)
end)

-----------
--STORAGE--
-----------
RegisterNetEvent('lb-dumpster:client:open:Dumpster:storage')
AddEventHandler('lb-dumpster:client:open:Dumpster:storage', function()
    if not Config.Storage then return end

    local DumpsterFound = ClosestContainer()
    if not DumpsterFound then return end
    local Dumpster = 'Container | '..math.floor(DumpsterFound.x).. ' | '..math.floor(DumpsterFound.y)..' |'

    TriggerServerEvent("lb-dumpster:server:openDumpsterInventory", Dumpster)
end)

function ClosestContainer()
    for _, propModel in ipairs(Config.Props) do
        local StartShape = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.1, 0)
        local EndShape = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.8, -0.4)
        local RayCast = StartShapeTestRay(StartShape.x, StartShape.y, StartShape.z, EndShape.x, EndShape.y, EndShape.z, 16, PlayerPedId(), 0)
        local Retval, Hit, Coords, Surface, EntityHit = GetShapeTestResult(RayCast)
        local BinModel = 0

        if EntityHit then
            BinModel = GetEntityModel(EntityHit)
        end

        if GetHashKey(propModel) == BinModel then
            local EntityHitCoords = GetEntityCoords(EntityHit)
            if EntityHitCoords.x < 0 or EntityHitCoords.y < 0 then
                EntityHitCoords = { x = EntityHitCoords.x + 5000, y = EntityHitCoords.y + 5000 }
            end
            return EntityHitCoords
        end
    end
end

------------
--BUM PEDS--
------------

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

function StartJobPed(coords, model, scenario)
    local ped
    if not DoesEntityExist(ped) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        ped = CreatePed(0, model, coords, false, false)

        SetEntityAsMissionEntity(ped)
        SetPedFleeAttributes(ped, 0, 0)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end
    return ped
end

CreateThread(function()
    for key, value in pairs(Config.BumsLocation) do
        StartJobPed(value.coords, value.model, value.scenario)
    end
end)
