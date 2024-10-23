local cblib = exports.cb_lib:Core()
local pedSpawned = false

function createPeds()
    if pedSpawned then return end
    for k, v in pairs(Config.Shops) do
        local pedHash2 = type(v.pedHash) == "number" and v.pedHash or joaat(v.pedHash)
        RequestModel(pedHash2)
        while not HasModelLoaded(pedHash2) do
            Citizen.Wait(0)
        end
        for a, b in pairs(v.coords) do
            b.ped = CreatePed(0, pedHash2, b.coords.x, b.coords.y, b.coords.z - 1, b.coords.w, false, true)
            TaskStartScenarioInPlace(b.ped, v.scenario, 0, true)
            FreezeEntityPosition(b.ped, true)
            SetEntityInvincible(b.ped, true)
            SetBlockingOfNonTemporaryEvents(b.ped, true)
            SetModelAsNoLongerNeeded(pedHash2)

            cblib.Target.AddEntity(b.ped, {
                {
                    icon = 'fas fa-boxes-packing',
                    label = v.name .. ' | ' .. v.label,
                    job = v.jobName,
                    onSelect = function()
                        openShop(v.name, v.label, v.categories, v.type)
                    end,
                }
            }, 3)
        end
        pedSpawned = true
    end
end

function deletePeds()
    if not pedSpawned then return end
    for k, v in pairs(Config.Shops) do
        for a, b in pairs(v.coords) do
            DeletePed(b.ped)
            pedSpawned = false
        end
    end
end

function createBlips()
    for k, v in pairs(Config.Shops) do
        if v.blip == true then
            for a, b in pairs(v.coords) do
                local StoreBlip = AddBlipForCoord(b.coords.x, b.coords.y, b.coords.z)
                SetBlipSprite(StoreBlip, v.blipSprite)
                SetBlipScale(StoreBlip, v.blipScale)
                SetBlipDisplay(StoreBlip, 4)
                SetBlipColour(StoreBlip, v.blipColor)
                SetBlipAsShortRange(StoreBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(v.name)
                EndTextCommandSetBlipName(StoreBlip)
            end
        end
    end
end

Citizen.CreateThread(function()
    createBlips()
    createPeds()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    deletePeds()
end)

RegisterNUICallback("close",function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback("pay",function(data)
    TriggerServerEvent("cb-shop:pay", data)
end)

basket = {}
basketJob = {}
function openShop(name, label, category, type)
    basket = {}
    basketJob = {}
    local categories = {}
    for k, v in pairs(category) do
        table.insert(categories, {
            id = k,
            name = v.name,
            items = v.items,
            description = v.description
        })
    end
    SetNuiFocus(true, true)
    SendNUIMessage({action = "openShop", name = name, label = label, categories = categories, type = type, resourceName = GetCurrentResourceName(),folder= Config.InventoryFolder})
end

RegisterNetEvent('cb-shop:openShop')
AddEventHandler('cb-shop:openShop', function(data)
    openShop(data.name, data.label, data.categories, data.type)
end)

RegisterNUICallback('addToBasket', function(data)
    if json.encode(basket) == "{}" or json.encode(basket) == "[]" then
        table.insert(basket, {
            name = data.name,
            perPrice = tonumber(data.price),
            totalPrice = tonumber(data.price),
            amount = 1,
            label = data.label
        })
        SendNUIMessage({action = "updateBasket", basket = basket})
    else
        local napacaz = napacaz(data.name)
        if napacaz == "insert" then
            table.insert(basket, {
                name = data.name,
                perPrice = tonumber(data.price),
                totalPrice = tonumber(data.price),
                amount = 1,
                label = data.label
            })
            SendNUIMessage({action = "updateBasket", basket = basket})
        end
    end
end)

RegisterNUICallback('addBasketJob', function(data)
    if json.encode(basketJob) == "{}" or json.encode(basketJob) == "[]" then
        table.insert(basketJob, {
            name = data.name,
            perPrice = tonumber(data.price),
            totalPrice = tonumber(data.price),
            amount = 1,
            label = data.label
        })
        SendNUIMessage({action = "updateBasketJob", basket = basketJob})
    else
        local napacazJob = napacazJob(data.name)
        if napacazJob == "insert" then
            table.insert(basketJob, {
                name = data.name,
                perPrice = tonumber(data.price),
                totalPrice = tonumber(data.price),
                amount = 1,
                label = data.label
            })
            SendNUIMessage({action = "updateBasketJob", basket = basketJob})
        end
    end
end)

function napacaz(name)
    for k, v in pairs(basket) do
        if v.name == name then
            basket[k].amount = basket[k].amount + 1
            basket[k].totalPrice = basket[k].perPrice * basket[k].amount
            SendNUIMessage({action = "updateBasket", basket = basket})
            return "update"
        end
    end
    return "insert"
end

function napacazJob(name)
    for k, v in pairs(basketJob) do
        if v.name == name then
            basketJob[k].amount = basketJob[k].amount + 1
            basketJob[k].totalPrice = basketJob[k].perPrice * basketJob[k].amount
            SendNUIMessage({action = "updateBasketJob", basket = basketJob})
            return "update"
        end
    end
    return "insert"
end

RegisterNUICallback('addBasketMore', function(data)
    for k, v in pairs(basket) do
        if v.name == data.name then
            basket[k].amount = basket[k].amount + 1
            basket[k].totalPrice = basket[k].perPrice * basket[k].amount
            SendNUIMessage({action = "updateBasket", basket = basket})
        end
    end
end)

RegisterNUICallback('addBasketMoreJob', function(data)
    for k, v in pairs(basketJob) do
        if v.name == data.name then
            basketJob[k].amount = basketJob[k].amount + 1
            basketJob[k].totalPrice = basketJob[k].perPrice * basketJob[k].amount
            SendNUIMessage({action = "updateBasketJob", basket = basketJob})
        end
    end
end)

RegisterNUICallback('removeOneBasket', function(data)
    for k, v in pairs(basket) do
        if v.name == data.name then
            if basket[k].amount > 1 then
                basket[k].amount = basket[k].amount - 1
                basket[k].totalPrice = basket[k].perPrice * basket[k].amount
                SendNUIMessage({action = "updateBasket", basket = basket})
            else
                basket[k] = nil
                SendNUIMessage({action = "updateBasket", basket = basket})
            end
        end
    end
end)

RegisterNUICallback('removeOneBasketJob', function(data)
    for k, v in pairs(basketJob) do
        if v.name == data.name then
            if basketJob[k].amount > 1 then
                basketJob[k].amount = basketJob[k].amount - 1
                basketJob[k].totalPrice = basketJob[k].perPrice * basketJob[k].amount
                SendNUIMessage({action = "updateBasketJob", basket = basketJob})
            else
                basketJob[k] = nil
                SendNUIMessage({action = "updateBasketJob", basket = basketJob})
            end
        end
    end
end)

RegisterNUICallback('deleteItemFromBasket', function(data)
    for k, v in pairs(basket) do
        if v.name == data.name then
            basket[k] = nil
            SendNUIMessage({action = "updateBasket", basket = basket})
        end
    end
end)

RegisterNUICallback('deleteItemFromBasketJob', function(data)
    for k, v in pairs(basketJob) do
        if v.name == data.name then
            basketJob[k] = nil
            SendNUIMessage({action = "updateBasketJob", basket = basketJob})
        end
    end
end)

RegisterNUICallback('makePayment', function(data)
    TriggerServerEvent('cb-shop:makePayment', data.type, data.price, basket)
end)

RegisterNUICallback('makePaymentJob', function(data)
    TriggerServerEvent('cb-shop:makePayment', data.type, data.price, basketJob)
end)

function hasLicense(licenses, playerLicenses)
    for _, license in ipairs(licenses) do
        if playerLicenses[license] then return true end
    end
    return false
end