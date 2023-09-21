local RSGCore = exports['rsg-core']:GetCoreObject()

-- use campfire command
RSGCore.Commands.Add("campfire", Lang:t('commands.deploy_campfire'), {}, false, function(source)
    local src = source
    TriggerClientEvent('rsg-cooking:client:setupcampfire', src)
end)

-- use campfire
RSGCore.Functions.CreateUseableItem("campfire", function(source, item)
    local src = source
    TriggerClientEvent('rsg-cooking:client:setupcampfire', src, item.name)
end)

-- check player has the ingredients
RSGCore.Functions.CreateCallback('rsg-cooking:server:checkingredients', function(source, cb, ingredients, cookamount)
    local src = source
    local hasItems = false
    local icheck = 0
    local Player = RSGCore.Functions.GetPlayer(src)
    for k, v in pairs(ingredients) do
        if Player.Functions.GetItemByName(v.item) and Player.Functions.GetItemByName(v.item).amount >= v.amount * cookamount then
            icheck = icheck + 1
            if icheck == #ingredients then
                cb(true)
            end
        else
            TriggerClientEvent('RSGCore:Notify', src, Lang:t('error.you_dont_have_the_required_items').. v.item, 'error')
            cb(false)
            return
        end
    end
end)

-- finish cooking
RegisterServerEvent('rsg-cooking:server:finishcooking')
AddEventHandler('rsg-cooking:server:finishcooking', function(ingredients, receive, giveamount, cookamount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    -- remove ingredients
    for k, v in pairs(ingredients) do
        if Config.Debug == true then
            print(v.item)
            print(v.amount)
        end
        local requiredAmount = v.amount * cookamount
        Player.Functions.RemoveItem(v.item, requiredAmount)    
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[v.item], "remove")
    end
    -- add cooked item
    Player.Functions.AddItem(receive, giveamount * cookamount)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[receive], "add")
    local labelReceive = RSGCore.Shared.Items[receive].label
    TriggerClientEvent('RSGCore:Notify', src, Lang:t('success.cooking_successful')..' '..cookamount..' ' .. labelReceive, 'success')
    TriggerClientEvent('RSGCore:Notify', src, Lang:t('success.cooking_finished'), 'success')
end)
