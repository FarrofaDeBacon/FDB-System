local FDBCore = exports['fdb-core']:GetCoreObject()
local isBusy = false

RegisterNetEvent('fdb-water:client:useTowel', function()
    if isBusy then return end
    
    local isWet = LocalPlayer.state.isWet
    if not isWet then
        lib.notify({ title = 'Toalha', description = 'Você já está seco!', type = 'inform' })
        return
    end

    isBusy = true
    LocalPlayer.state:set('inv_busy', true, true)
    
    if lib.progressBar({
        duration = 5000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disableControl = true,
        disable = { move = true, mouse = true },
        label = 'Secando-se...',
        anim = {
            dict = 'amb_misc@world_human_wash_face_bucket@ground@male_a@idle_a', -- Substituir por animação de toalha se houver
            clip = 'idle_a'
        },
    }) then
        TriggerServerEvent('fdb-water:server:dryPlayer')
        lib.notify({ title = 'Seco', description = 'Você usou a toalha e agora está seco.', type = 'success' })
    else
        lib.notify({ title = 'Cancelado', description = 'Você parou de se secar.', type = 'error' })
    end
    
    ClearPedTasks(cache.ped)
    LocalPlayer.state:set('inv_busy', false, true)
    isBusy = false
end)
