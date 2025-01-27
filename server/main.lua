local QBCore = exports['qb-core']:GetCoreObject()

------------------------
--     Variables      --
------------------------
local uids = {}
local shopItems = {}
local marketPed = {}
local pedArrested = false

------------------------
--     Functions      --
------------------------
-- Initializes the blackmarket_ped table in the database if it does not exist
local function initBlackmarketTable()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS blackmarket_ped (
            id INT AUTO_INCREMENT PRIMARY KEY,
            pedModel VARCHAR(100),
            pedScenario VARCHAR(100),
            pedCoords JSON,
            spawnDate DATETIME,
            resetDays INT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
end

local function createUID()
    local uid = math.random(1000000, 9999999)
    local attempts = 0
    local maxAttempts = 100
    
    while uids[uid] and attempts < maxAttempts do
        uid = math.random(1000000, 9999999)
        attempts = attempts + 1
    end
    
    if attempts >= maxAttempts then
        print('^1Failed to generate unique item UID after ' .. maxAttempts .. ' attempts^7')
        return nil
    end
    
    uids[uid] = true
    return uid
end

local function generateSerialNumber()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    local serial_number = ""
    for i = 1, Config.WeaponSerialNumbers.length do
        local random_index = math.random(1, #charset)
        serial_number = serial_number .. string.sub(charset, random_index, random_index)
    end

    if Config.WeaponSerialNumbers.scratch.enable then
        local num_scratches = math.random(Config.WeaponSerialNumbers.scratch.min, Config.WeaponSerialNumbers.scratch.max)
        for i = 1, num_scratches do
            local scratch_index = math.random(1, Config.WeaponSerialNumbers.length)
            serial_number = string.sub(serial_number, 1, scratch_index - 1) .. Config.WeaponSerialNumbers.scratch.character .. string.sub(serial_number, scratch_index + 1)
        end
    end

    return Config.WeaponSerialNumbers.prefix .. serial_number
end

local function setupShopItems()
    if Config.Debug then print('Setting up shop items...') end
    shopItems = {}
    
    for category, data in pairs(Config.Items) do
        if Config.Debug then print('Processing category:', category) end
        shopItems[category] = {}
        
        for i = 1, #data.items do
            local item = data.items[i]
            if QBCore.Shared.Items[item.item] then
                local uid = createUID()
                if uid then
                    shopItems[category][uid] = {
                        name = item.item,
                        label = QBCore.Shared.Items[item.item].label,
                        desc = QBCore.Shared.Items[item.item].description,
                        price = math.random(item.price.min, item.price.max),
                        stock = math.random(item.stock.min, item.stock.max),
                        category = category,
                        configIndex = i
                    }
                    if Config.Debug then print('Added item:', item.item, 'to category:', category) end
                end
            else
                if Config.Debug then print('Invalid item:', item.item, 'in category:', category) end
            end
        end
    end
    if Config.Debug then print('Shop items setup complete') end
end

local function updateStock(category, uid, amount)
    if not shopItems[category] then
        return
    end
    if not shopItems[category][uid] then
        return
    end
    shopItems[category][uid].stock = shopItems[category][uid].stock - amount
end

local function validateItem(category, uid)
    if not shopItems[category] then
        return false
    end
    if not shopItems[category][uid] then
        return false
    end
    return true
end

local function getOrCreatePedData()
    local result = MySQL.Sync.fetchAll('SELECT *, UNIX_TIMESTAMP(spawnDate) as spawn_timestamp FROM blackmarket_ped LIMIT 1')

    if #result == 0 then
        local randomLocation = Config.Locations[math.random(#Config.Locations)]
        local randomModel = Config.Ped.models[math.random(#Config.Ped.models)]
        local randomScenario = Config.Ped.scenarios[math.random(#Config.Ped.scenarios)]
        local resetDays = math.random(Config.ResetDays.min, Config.ResetDays.max)
        local coordsJson = json.encode({
            x = randomLocation[1].x, 
            y = randomLocation[1].y, 
            z = randomLocation[1].z, 
            w = randomLocation[1].w
        })

        MySQL.Sync.execute([[
            INSERT INTO blackmarket_ped 
            (pedModel, pedScenario, pedCoords, spawnDate, resetDays) 
            VALUES (?, ?, ?, NOW(), ?)
        ]], {
            randomModel, 
            randomScenario, 
            coordsJson, 
            resetDays
        })

        marketPed = {
            pedModel = randomModel,
            pedScenario = randomScenario,
            coords = randomLocation[1],
            resetDays = resetDays
        }
        return marketPed
    else
        local data = result[1]
        local coords = json.decode(data.pedCoords)
        local spawnTime = data.spawn_timestamp
        local currentTime = os.time()
        local daysSinceSpawn = math.floor((currentTime - spawnTime) / (24 * 60 * 60))

        if daysSinceSpawn >= data.resetDays then
            local randomLocation = Config.Locations[math.random(#Config.Locations)]
            local randomModel = Config.Ped.models[math.random(#Config.Ped.models)]
            local randomScenario = Config.Ped.scenarios[math.random(#Config.Ped.scenarios)]
            local newResetDays = math.random(Config.ResetDays.min, Config.ResetDays.max)

            MySQL.Sync.execute([[
                UPDATE blackmarket_ped 
                SET pedModel = ?, 
                    pedScenario = ?, 
                    pedCoords = ?, 
                    spawnDate = NOW(), 
                    resetDays = ?
            ]], {
                randomModel, 
                randomScenario, 
                json.encode({
                    x = randomLocation[1].x, 
                    y = randomLocation[1].y, 
                    z = randomLocation[1].z, 
                    w = randomLocation[1].w
                }), 
                newResetDays
            })

            marketPed = {
                pedModel = randomModel,
                pedScenario = randomScenario,
                coords = randomLocation[1],
                resetDays = newResetDays
            }
            return marketPed
        end

        marketPed = {
            pedModel = data.pedModel,
            pedScenario = data.pedScenario,
            coords = vector4(coords.x, coords.y, coords.z, coords.w),
            resetDays = data.resetDays
        }
        return marketPed
    end
end

------------------------
--     Callbacks      --
------------------------
QBCore.Functions.CreateCallback('sg-blackmarket:server:getShopItems', function(source, cb)
    cb(shopItems)
end)

QBCore.Functions.CreateCallback('sg-blackmarket:server:purchaseItem', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = shopItems[data.category][data.uid]

    if Config.Debug then
        print('sg-blackmarket:server:purchaseItem')
        QBCore.Debug(data)
    end

    if not item then
        return cb(false, 'Invalid item')
    end

    if item.stock < data.amount then
        return cb(false, 'Not enough stock')
    end

    local totalPrice = item.price * data.amount
    if not Player.Functions.RemoveMoney(Config.Account, totalPrice) then
        return cb(false, 'Not enough money')
    end

    local configItem = Config.Items[data.category].items[item.configIndex]
    configItem.info = configItem.info or {}

    -- Check if item is unique
    if QBCore.Shared.Items[item.name].unique then
        local addedItems = 0
        for i = 1, data.amount do
            if QBCore.Shared.Items[item.name].type == 'weapon' then
                configItem.info.serie = generateSerialNumber()
            end
            if Player.Functions.AddItem(item.name, 1, false, configItem.info) then
                addedItems = addedItems + 1
            else
                -- Refund remaining money and update stock only for successful adds
                local refundAmount = (data.amount - addedItems) * item.price
                Player.Functions.AddMoney(Config.Account, refundAmount)
                updateStock(data.category, data.uid, addedItems)

                if addedItems > 0 then
                    return cb(true, string.format('Added %d items. Inventory full for remaining %d', addedItems, data.amount - addedItems))
                else
                    return cb(false, 'Inventory full')
                end
            end
        end
        updateStock(data.category, data.uid, addedItems)
        return cb(true)
    else
        -- Non-unique item logic
        if Player.Functions.AddItem(item.name, data.amount, false, configItem.info) then
            updateStock(data.category, data.uid, data.amount)
            return cb(true)
        else
            Player.Functions.AddMoney(Config.Account, totalPrice)
            return cb(false, 'Inventory full')
        end
    end
end)

------------------------
--   Server Events    --
------------------------
RegisterNetEvent('sg-blackmarket:server:arrestPed', function()
    marketPed = nil
    pedArrested = true
    TriggerClientEvent('sg-blackmarket:client:removePed', -1, source)
    MySQL.Sync.execute('DELETE FROM blackmarket_ped')
    SetTimeout(Config.Debug and (1 * 60000) or (Config.Police.timeout * 60000), function()
        local reset = getOrCreatePedData()
        pedArrested = false
        if reset then
            local info = {loc = marketPed.coords, model = marketPed.pedModel, scenario = marketPed.pedScenario}
            TriggerClientEvent('sg-blackmarket:client:spawnPed', -1, info)
        end
    end)
end)

------------------------
--    Core Events     --
------------------------
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    if pedArrested then return end
    if Config.Debug then print('OnPlayerLoaded', src, marketPed.coords, marketPed.pedModel, marketPed.pedScenario) end

    local info = {loc = marketPed.coords, model = marketPed.pedModel, scenario = marketPed.pedScenario}
    Wait(100)
    TriggerClientEvent('sg-blackmarket:client:spawnPed', src, info)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if Config.SqlAutoInstall then
        initBlackmarketTable()
    end
    Wait(1000)
    setupShopItems()
    getOrCreatePedData()

    Wait(1000)
    if Config.Debug then
        print('^5[INFO]^7 - Blackmarket ped data:')
        print('^5[INFO]^7 - Ped Model: ^3' .. marketPed.pedModel)
        print('^5[INFO]^7 - Ped Scenario: ^3' .. marketPed.pedScenario)
        print('^5[INFO]^7 - Ped Location: ^3' .. marketPed.coords.x .. ', ' .. marketPed.coords.y .. ', ' .. marketPed.coords.z .. ', ' .. marketPed.coords.w)
        print('^5[INFO]^7 - Reset Days: ^3' .. marketPed.resetDays)
        local info = {loc = marketPed.coords, model = marketPed.pedModel, scenario = marketPed.pedScenario}
        TriggerClientEvent('sg-blackmarket:client:spawnPed', -1, info)
    end
end)