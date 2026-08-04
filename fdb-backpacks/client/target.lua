local FDBCore = exports['fdb-core']:GetCoreObject()
registeredEntities = {}

--- Configura as interações de mira para uma mochila física no chão
--- @param entity number
--- @param stashId string
--- @param itemName string
function SetupTarget(entity, stashId, itemName)
    print(("[Backpack Debug] SetupTarget called. Entity: %s, StashId: %s, ItemName: %s"):format(entity, stashId, itemName))
    if registeredEntities[stashId] then
        print("[Backpack Debug] StashId already registered in target list. Skipping.")
        return
    end
    registeredEntities[stashId] = true
    print("[Backpack Debug] Registering ox_target options for Entity.")

    local bpConfig = Config.Backpacks[itemName]
    local isSatchel = bpConfig and (bpConfig.isClothing or itemName == "doctor_bag" or itemName:sub(1, 8) == "satchel_")
    local typeLabel = isSatchel and "Bolsa" or "Mochila"

    exports.ox_target:addLocalEntity(entity, {
        {
            name     = 'open_backpack_' .. stashId,
            icon     = 'fas fa-basket-shopping',
            label    = 'Vasculhar ' .. typeLabel,
            distance = 2.0,
            onSelect = function()
                -- Solicita abertura e lock ao servidor
                local model = 'p_ambpack02x'
                if bpConfig then model = bpConfig.model end
                TriggerEvent("fdb-inventory:client:openBackpackDrawer", stashId, model)
            end,
        },
        {
            name     = 'wear_backpack_' .. stashId,
            icon     = 'fas fa-shirt',
            label    = 'Vestir ' .. typeLabel,
            distance = 2.0,
            canInteract = function(entity, distance, data)
                local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId
                local bp = groundBackpacks[uid]
                return bp and bp.state ~= 'open'
            end,
            onSelect = function()
                PlayWearFromGroundAnimation(function()
                    TriggerServerEvent("fdb-backpacks:server:wearBackpack", stashId)
                end)
            end,
        },
        {
            name     = 'pickup_backpack_' .. stashId,
            icon     = 'fas fa-hand-holding',
            label    = 'Recolher ' .. typeLabel,
            distance = 2.0,
            canInteract = function(entity, distance, data)
                local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId
                local bp = groundBackpacks[uid]
                return bp and bp.state ~= 'open'
            end,
            onSelect = function()
                PlayDoffAndPlaceAnimation(function()
                    TriggerServerEvent("fdb-backpacks:server:pickupBackpack", stashId)
                end)
            end,
        }
    })
end
