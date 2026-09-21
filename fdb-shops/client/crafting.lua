-- ============================================================
-- FDB System | fdb-shops | client/crafting.lua
-- Client UI and Logic for Crafting at Shop Stations
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local fdbLibs = exports['fdb-libs']
local isCrafting = false

--- Abre o menu de craft usando fdb-libs
function OpenCraftMenu(station)
    if isCrafting then return end

    fdbLibs:TriggerServerCallback('fdb-shops:server:getCraftMenu', function(success, recipesOrError)
        if not success then
            fdbLibs:Notify(recipesOrError, 'error', 3000)
            return
        end

        local options = {}
        for _, recipe in ipairs(recipesOrError) do
            local metadata = {}
            for _, ing in ipairs(recipe.ingredients) do
                table.insert(metadata, {label = ing.name, value = tostring(ing.amount) .. 'x'})
            end

            table.insert(options, {
                title = ('Fabricar %s (x%d)'):format(recipe.result, recipe.amount),
                description = ('Tempo estimado: %ds'):format(recipe.time / 1000),
                metadata = metadata,
                onSelect = function()
                    StartCrafting(station, recipe.id)
                end
            })
        end

        fdbLibs:RegisterMenu('shop_craft_menu', {
            title = 'Bancada de Produção',
            options = options
        })

        fdbLibs:ShowMenu('shop_craft_menu')
    end, station.shop_id, station.id)
end

--- Inicia o progresso e animações de fabricação
function StartCrafting(station, recipeId)
    if isCrafting then return end
    isCrafting = true

    fdbLibs:TriggerServerCallback('fdb-shops:server:requestCraft', function(success, recipeOrError, serverStation)
        if not success then
            fdbLibs:Notify(recipeOrError, 'error', 3000)
            isCrafting = false
            return
        end
        
        local recipe = recipeOrError
        local animDict = serverStation.animation_dict
        local animName = serverStation.animation_name
        
        -- Start Progress Bar via fdb-libs
        fdbLibs:ProgressBar('shop_crafting', 'Fabricando ' .. recipe.result .. '...', recipe.time, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = animDict,
            anim = animName,
            flags = 16,
        }, {}, {}, function() 
            -- On Success
            isCrafting = false
            TriggerServerEvent('fdb-shops:server:completeCraft', station.shop_id, recipeId, station.id)
        end, function() 
            -- On Cancel
            isCrafting = false
            fdbLibs:Notify('Fabricação cancelada.', 'error', 3000)
        end)

    end, station.shop_id, recipeId, station.id)
end
