-- Qbox / QBCore / ESX through community_bridge
local Framework = exports.community_bridge:Framework()
local Inventory = exports.community_bridge:Inventory()
local Notify = exports.community_bridge:Notify()

local entities = {}

local function notify(src, message, notifyType)
    Notify.SendNotify(src, message, notifyType or 'info', 5000)
end

local function itemLabel(name)
    local ok, info = pcall(Inventory.GetItemInfo, name)
    return ok and type(info) == 'table' and info.label or name
end

-----------
----BIN----
-----------
RegisterNetEvent('lb-dumpster:server:ResetEntity', function(entity)
    entities[entity] = 0
end)

function EntityRespawn()
    for key, t in pairs(entities) do
        entities[key] = t + 1
        if t >= 0 and t >= Config.ResetTime then
            entities[key] = -1
        end
    end
    SetTimeout(60000, EntityRespawn)
end

if not Config.ResetOnReboot then
    EntityRespawn()
end

local function wasDived(netId)
    return not (entities[netId] == -1 or entities[netId] == nil)
end

local function pGive(playerId, item, amount)
    if type(item) == 'string' then
        Inventory.AddItem(playerId, item, amount)
        notify(playerId, Lang:t('notifies.you_got', { items = amount .. 'x ' .. itemLabel(item) }))
    elseif type(item) == 'table' then
        if #item <= 0 then return notify(playerId, Lang:t('notifies.got_nothing')) end

        local itemString = ''
        for _, i in pairs(item) do
            Inventory.AddItem(playerId, i.item, i.amount)
            itemString = i.amount .. 'x ' .. itemLabel(i.item) .. ', ' .. itemString
        end

        if itemString ~= '' then
            notify(playerId, Lang:t('notifies.you_got', { items = itemString }))
        else
            notify(playerId, Lang:t('notifies.got_nothing'))
        end
    end
end

function DropItem(finished, netId, playerId)
    if not netId or not finished then return end

    local totalChances = 0
    for _, tierData in pairs(Config.LootTiers) do
        totalChances = totalChances + tierData.chances
    end

    local tierRoll = math.random(1, totalChances)
    local selectedTier = nil
    for _, tierData in pairs(Config.LootTiers) do
        if tierRoll <= tierData.chances then
            selectedTier = tierData
            break
        else
            tierRoll = tierRoll - tierData.chances
        end
    end

    if not selectedTier then return end

    if Config.CanLootMultiple then
        local itemTable = {}
        local itemAmount = math.random(1, Config.MaxLootItem)

        for _ = 1, itemAmount do
            local item = selectedTier.loottable[math.random(1, #selectedTier.loottable)]
            itemTable[#itemTable+1] = { item = item.item, amount = math.floor(math.random(item.min, item.max)) }
        end

        return pGive(playerId, itemTable)
    else
        local item = selectedTier.loottable[math.random(1, #selectedTier.loottable)]
        return pGive(playerId, item.item, math.random(item.min, item.max))
    end
end

RegisterNetEvent('lb-dumpster:server:SetEntity', function(netId, isFinished)
    local src = source
    -- Loot each dumpster once until it resets
    if wasDived(netId) then return end
    entities[netId] = 0
    DropItem(isFinished, netId, src)
end)

RegisterNetEvent('lb-dumpster:server:getEntityState', function(netId, requestId)
    TriggerClientEvent('lb-dumpster:client:entityState', source, requestId, wasDived(netId))
end)

AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    for key, v in pairs(entities) do
        if v == -1 then
            TriggerClientEvent('lb-dumpster:client:ResetEntity', -1, key)
        end
    end
end)

-----------
----BUM----
-----------
local function playerItems(src)
    local ok, items = pcall(Inventory.GetPlayerInventory, src)
    return ok and type(items) == 'table' and items or {}
end

--stealing (server-only: never callable from a client)
local function pedStealItems(src)
    local itemsStolen = false
    local removedItems = {}

    for k, v in pairs(playerItems(src)) do
        local itemName = v.name
        local amount = tonumber(v.count or v.amount) or 0

        if Config.ItemsSteal[itemName] and amount > 0 and math.random(1, 100) <= Config.StealChance then
            local amountToSteal = math.random(1, amount)
            local slot = (v.slot and v.slot > 0) and v.slot or nil
            if Inventory.RemoveItem(src, itemName, amountToSteal, slot) then
                removedItems[k] = { name = itemName, amount = amountToSteal }
                itemsStolen = true
                if Config.BumSteal then
                    notify(src, "GIVE ME YO SHIT, BITCH!", 'error')
                end
            end
        end
    end

    if next(removedItems) then
        TriggerEvent('lb-dumpster:server:onPedStealItems', src, removedItems)
    end

    if not itemsStolen then
        notify(src, "You ain't got shit I want")
    end
end

--selling
RegisterNetEvent('lb-dumpster:server:sellItems', function()
    local src = source
    local totalPrice = 0

    for _, v in pairs(playerItems(src)) do
        local itemName = v.name
        local amount = tonumber(v.count or v.amount) or 0

        if Config.ItemsSell[itemName] and amount > 0 then
            local slot = (v.slot and v.slot > 0) and v.slot or nil
            if Inventory.RemoveItem(src, itemName, amount, slot) then
                totalPrice = totalPrice + Config.ItemsSell[itemName].price * amount
            end
        end
    end

    if totalPrice > 0 then
        Framework.AddAccountBalance(src, 'money', totalPrice)
        notify(src, "Here's $"..totalPrice..", piss off.", 'success')
    else
        pedStealItems(src)
    end
end)

-----------
--STORAGE--
-----------
local registered = {}

RegisterNetEvent('lb-dumpster:server:openDumpsterInventory', function(dumpsterName)
    local src = source
    if not Config.Storage or type(dumpsterName) ~= 'string' or not dumpsterName:match('^Container | %-?%d+ | %-?%d+ |$') then return end

    if not registered[dumpsterName] then
        pcall(Inventory.RegisterStash, dumpsterName, 'Dumpster', Config.StorageSize, Config.StorageWeight)
        registered[dumpsterName] = true
    end
    Inventory.OpenStash(src, 'stash', dumpsterName)
end)
