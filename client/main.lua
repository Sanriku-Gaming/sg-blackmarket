local QBCore = exports['qb-core']:GetCoreObject()

------------------------
--     Variables      --
------------------------
local PlayerJob
local marketPed
local target

------------------------
--     Functions      --
------------------------
local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function formatNumber(num)
    return string.format('%d', num):reverse():gsub('%d%d%d', '%1,'):reverse():gsub('^,', '')
end

local function isPolice()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    for job, grade in pairs(Config.Police.jobs) do
        if PlayerJob.name == job then
            return true
        end
    end
    return false
end

local function canArrest()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    for job, grade in pairs(Config.Police.jobs) do
        if PlayerJob.name == job and PlayerJob.grade.level >= grade then
            return true
        end
    end
    return false
end

local function spawnPed(loc, model, scenario)
    if Config.Debug then print('Spawning Blackmarket Ped:', loc, model, scenario) end
    local coords = loc
    local pedModel = model
    local pedScenario = scenario

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end
    marketPed = CreatePed(4, pedModel, coords.x, coords.y, coords.z - 1, coords.w, false, false)
    SetEntityAsMissionEntity(marketPed, true, true)
    SetBlockingOfNonTemporaryEvents(marketPed, true)
    TaskStartScenarioInPlace(marketPed, pedScenario, 0, true)
    FreezeEntityPosition(marketPed, true)
    return marketPed
end

local function arrestPed(entity)
    NetworkHasControlOfEntity(entity)
    if DoesEntityExist(entity) then
        local ped = PlayerPedId()
        local tCoords = GetEntityCoords(entity)
        local heading = GetEntityHeading(ped)
        TriggerServerEvent('sg-blackmarket:server:arrestPed')
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Cuff', 0.2)
        loadAnimDict('mp_arrest_paired')
        loadAnimDict("mp_arresting")
        ClearPedTasksImmediately(entity)
        SetEntityCoords(entity, GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.25, -1.0))

        Wait(100)
        SetEntityHeading(entity, heading)
        TaskPlayAnim(entity, 'mp_arrest_paired', 'crook_p2_back_right', 3.0, 3.0, -1, 32, 0, 0, 0, 0 ,true, true, true)
        TaskPlayAnim(ped, 'mp_arrest_paired', 'cop_p2_back_right', 3.0, 3.0, -1, 48, 0, 0, 0, 0)

        Wait(3500)
        TaskPlayAnim(ped, 'mp_arrest_paired', 'exit', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
        TaskPlayAnim(entity, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
        ClearPedTasks(ped)
        Wait(3500)
        SetPedAsNoLongerNeeded(entity)
    end
end

function purchaseItem(data)
    if not canShop then return end

    local dialog = exports['qb-input']:ShowInput({
        header = "Purchase " .. data.item.label,
        submitText = "Buy",
        inputs = {
            {
                text = "Amount",
                name = "amount",
                type = "number",
                isRequired = true,
                default = 1
            }
        }
    })

    if dialog then
        local amount = tonumber(dialog.amount)
        if amount and amount > 0 and canShop then
            QBCore.Functions.TriggerCallback('sg-blackmarket:server:purchaseItem', function(success, reason)
                if Config.Debug then print(success, reason) end
                if success then
                    QBCore.Functions.Notify('Purchased ' .. amount .. 'x ' .. data.item.label, 'success')
                    openBlackmarketMenu()
                else
                    QBCore.Functions.Notify(reason or 'Purchase failed', 'error')
                    purchaseItem(data)
                end
            end, {
                category = data.category,
                uid = data.uid,
                item = data.item,
                amount = amount
            })
        end
    end
end

function openCategoryMenu(data)
    local items = data.items
    local menuItems = {
        {
            header = "← Go Back",
            params = {
                isAction = true,
                event = openBlackmarketMenu
            }
        }
    }

    local sortedItems = {}
    for uid, item in pairs(items) do
        table.insert(sortedItems, {uid = uid, item = item})
    end

    table.sort(sortedItems, function(a, b)
        return a.item.label < b.item.label
    end)

    for _, itemData in ipairs(sortedItems) do
        local item = itemData.item
        table.insert(menuItems, {
            header = item.label,
            icon = item.name,
            txt = string.format("Price: $%s | Stock: %s <br>%s", formatNumber(item.price), formatNumber(item.stock), item.desc),
            disabled = item.stock <= 0,
            params = {
                isAction = true,
                event = purchaseItem,
                args = {
                    category = data.category,
                    uid = itemData.uid,
                    item = item
                }
            }
        })
    end

    if not canShop then return end
    exports['qb-menu']:openMenu(menuItems)
end

function openBlackmarketMenu()
    QBCore.Functions.TriggerCallback('sg-blackmarket:server:getShopItems', function(shopItems)
        local categories = {}
        local sortedCategories = {}

        for category in pairs(Config.Items) do
            if shopItems[category] and next(shopItems[category]) then
                table.insert(sortedCategories, category)
            end
        end

        table.sort(sortedCategories, function(a, b)
            return Config.Items[a].label < Config.Items[b].label
        end)

        for _, category in ipairs(sortedCategories) do
            table.insert(categories, {
                header = Config.Items[category].label,
                icon = Config.Items[category].icon,
                txt = "Browse " .. Config.Items[category].label,
                params = {
                    isAction = true,
                    event = openCategoryMenu,
                    args = {
                        category = category,
                        items = shopItems[category]
                    }
                }
            })
        end

        if not canShop then return end
        exports['qb-menu']:openMenu(categories)
    end)
end

------------------------
--       Events       --
------------------------
RegisterNetEvent('sg-blackmarket:client:spawnPed', function(data)
    canShop = true
    if Config.Debug then QBCore.Debug(data) end
    if marketPed then
        if DoesEntityExist(marketPed) then 
            DeleteEntity(marketPed)
            marketPed = nil
        end
    end

    if target then
        exports['qb-target']:RemoveTargetEntity(target)
        target = nil
    end

    local ped = spawnPed(data.loc, data.model, data.scenario)
    target = exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                targeticon = 'fa-solid fa-comment-dots',
                label = 'Browse the shop!',
                canInteract = function()
                    return not isPolice()
                end,
                action = function()
                    openBlackmarketMenu()
                end,
            },
            {
                targeticon = 'fa-solid fa-handcuffs',
                label = 'Arrest this snitch!',
                canInteract = function()
                    return Config.Police.enableArrest and canArrest() or false
                end,
                action = function(entity)
                    arrestPed(entity)
                end,
            }
        },
        distance = 2.5,
    })
end)

RegisterNetEvent('sg-blackmarket:client:removePed', function(playerId)
    canShop = false
    local ped = PlayerPedId()
    local mCoords = GetEntityCoords(marketPed)
    local pCoords = GetEntityCoords(ped)
    if #(mCoords - pCoords) <= 50.0 then
        local cuffer = GetPlayerPed(GetPlayerFromServerId(playerId))
        local heading = GetEntityHeading(cuffer)
        NetworkHasControlOfEntity(marketPed)
        ClearPedTasks(marketPed)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "Cuff", 0.2)
        loadAnimDict("mp_arrest_paired")
        loadAnimDict("mp_arresting")
        SetEntityCoords(marketPed, GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.25, -1.0))
        Wait(100)
        SetEntityHeading(marketPed, heading)
        TaskPlayAnim(marketPed, "mp_arrest_paired", "crook_p2_back_right", 3.0, 3.0, -1, 32, 0, 0, 0, 0 ,true, true, true)
        Wait(3500)
        TaskPlayAnim(marketPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
        Wait(1500)
        SetPedAsNoLongerNeeded(marketPed)
        Wait(3500)
    end
    exports['qb-target']:RemoveTargetEntity(target)
    if DoesEntityExist(marketPed) then DeleteEntity(marketPed) end
    marketPed = nil
    target = nil
end)

------------------------
--    Core Events     --
------------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(1500)
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    exports['qb-target']:RemoveTargetEntity(target)
    if DoesEntityExist(marketPed) then DeleteEntity(marketPed) end
    marketPed = nil
    target = nil
    canShop = true
end)