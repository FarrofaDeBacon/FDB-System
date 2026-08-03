print('[rsg-inventory] Carregando modulo client/hotbar_keys.lua (Modo Loop)...')

local HotbarKeys = {
    [1] = 0xE6F612E4, -- 1
    [2] = 0x1CE6D9EB, -- 2
    [3] = 0x4F49CC4C, -- 3
    [4] = 0x8F9F9E58, -- 4
    [5] = 0xAB62E997, -- 5
    [6] = 0xA1FDE2A6, -- 6
    [7] = 0xB03A913B, -- 7
    [8] = 0x42385422, -- 8
}

local function UseHotbarSlot(slot)
    if Inventory.CanPlayerUseInventory() then
        print(('[rsg-inventory] Comando hotbar slot %d executado via Loop! (Fase H6)'):format(slot))
        TriggerServerEvent('rsg-inventory:server:UseHotbarSlot', slot)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        for slot, controlHash in pairs(HotbarKeys) do
            if IsControlJustReleased(0, controlHash) then
                UseHotbarSlot(slot)
            end
        end
    end
end)
