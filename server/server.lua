local cblib = exports.cb_lib:Core()

RegisterNetEvent('cb-shop:makePayment', function(type, price, basket)
    local src = source

    if cblib.Framework.Money.Remove(src, tonumber(price), type) then
        for k, v in pairs(basket) do
            cblib.Inventory.AddItem(src, v.name, v.amount)
        end
        TriggerClientEvent("cb_lib:notify", src, "Purchase successful", nil, "success")
    else
        TriggerClientEvent("cb_lib:notify", src, "Not enough money", nil, "success")
    end
end)


-- name = "Market",
-- label = "7/24 Market",
-- type = "normal",
-- blip = true,
-- blipSprite = 59,
-- blipColor = 2,
-- blipScale = 0.5,
-- categories = {
--     [1] = {
--         name = "General",
--         description = "Needs",
--         items = {
--             {name = "water_bottle", label = "Water", perPrice = 150, description = "Drinks"},
--             {name = "sandwich", label = "Sandwich", perPrice = 150, description = "Food"},
--             {name = "snikkel_candy", label = "Snikkel Candy", perPrice = 150, description = "General"},
--             {name = "tosti", label = "Tosti", perPrice = 150, description = "General"},
--             {name = "beer", label = "Beer", perPrice = 150, description = "General"},
--             {name = "cola", label = "Cola", perPrice = 150, description = "General"},
--             {name = "twerks_candy", label = "Twerks Candy", perPrice = 150, description = "General"},
--             {name = "whiskey", label = "Whiskey", perPrice = 150, description = "General"},
--         }
--     },
-- },

RegisterCommand('openstore', function (source, args, raw)
    TriggerClientEvent('cb-shop:openShop', source, {
        name = "Market",
        label = "7/24 Market",
        type = "normal",
        blip = true,
        blipSprite = 59,
        blipColor = 2,
        blipScale = 0.5,
        categories = {
            [1] = {
                name = "General",
                description = "Needs",
                items = {
                    {name = "water_bottle", label = "Water", perPrice = 150, description = "Drinks"},
                }
            },
        },
    })
end)