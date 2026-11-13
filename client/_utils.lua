-- Qbox / QBCore / ESX through community_bridge
Notify = exports.community_bridge:Notify()
local BridgeProgress = exports.community_bridge:ProgressBar()
isBusy = false

function notify(message, notifyType)
    Notify.SendNotify(message, notifyType or 'info', 5000)
end

if Config.Minigame == 'memorygame' then
    function MiniGame()
        local success = false
        local holdResult = true

        exports["memorygame"]:thermiteminigame(5, 3, 3, 15, function()
            success = true
            holdResult = false
        end, function()
            success = false
            holdResult = false
        end)

        while holdResult do Wait(100) end
        return success
    end
elseif Config.Minigame == 'qb-lock' then
    function MiniGame()
        local success = exports['qb-lock']:StartLockPickCircle(3, 10)
        return success or false
    end
elseif Config.Minigame == 'ps-ui' then
    function MiniGame()
        local success = false
        exports['ps-ui']:Circle(function(result)
            success = result
        end, 3, 10)
        return success
    end
elseif Config.Minigame and Config.Minigame ~= 'none' then
    print('[lb-dumpster] Invalid minigame specified in config.lua')
end

function PoliceAlert()
    if Config.Illegal then
        if math.random(1,100) >= Config.AlertChance then return end
        local coords = GetEntityCoords(PlayerPedId())
        local fn = type(Config.Dispatch) == 'table' and Config.Dispatch.Function
        local ok, err = pcall(fn or function()
            exports.community_bridge:Dispatch().SendAlert({
                coords = coords, message = Lang:t('police.message'), code = Lang:t('police.code'),
                blipData = { sprite = 318, color = 1, scale = 0.5 }, jobs = { 'police' },
            })
        end, coords)
        if not ok then print(('[gldnrmz-dumpsters] Config.Dispatch.Function failed: %s'):format(err)) end
    end
end

function ProgressBar(ent)
    local finished = BridgeProgress.Open({
        duration = Config.ProgressTime * 1000,
        label = Lang:t('progress.diving'),
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 },
    })

    isBusy = false
    ClearPedTasks(PlayerPedId())

    if finished then
        if not NetworkGetEntityIsNetworked(ent) then NetworkRegisterEntityAsNetworked(ent) end
        TriggerServerEvent('lb-dumpster:server:SetEntity', ObjToNet(ent), true)
        if not Config.ResetOnReboot then TriggerServerEvent('lb-dumpster:server:ResetEntity', ObjToNet(ent)) end
    else
        HurtPlayer(true)
    end
end

function HurtPlayer(cancelled)
    local doubled = 0.5
    if cancelled then doubled = 1.5 end

    if Config.Hurting then
        if math.random(1,100) >= Config.HurtChance * doubled then return end

        local health = GetEntityHealth(PlayerPedId())
        local newHealth = health - math.random(Config.HurtDamage.min, Config.HurtDamage.max)
        SetEntityHealth(PlayerPedId(), newHealth)

        if Config.CanBleed then
            if math.random(1,100) >= Config.BleedChance then return end
            TriggerEvent('hospital:client:SetPain')
        end
    end
end

-- Ask the server whether a dumpster was already searched
local pendingState = {}
local stateRequestId = 0

function GetDumpsterState(netId)
    stateRequestId = stateRequestId + 1
    local id = stateRequestId
    local p = promise.new()
    pendingState[id] = p
    TriggerServerEvent('lb-dumpster:server:getEntityState', netId, id)
    SetTimeout(5000, function()
        if pendingState[id] then pendingState[id] = nil; p:resolve(true) end
    end)
    return Citizen.Await(p)
end

RegisterNetEvent('lb-dumpster:client:entityState', function(id, wasDived)
    local p = pendingState[id]
    if not p then return end
    pendingState[id] = nil
    p:resolve(wasDived)
end)
