-- ONE-TIME WIPE: Clears equipmentSlots from ALL players in the database
-- Run from server console: wipe_equipment
RegisterCommand('wipe_equipment', function(source, args, rawCommand)
    if source ~= 0 then return end -- console only
    print('[rsg-inventory] Wiping equipmentSlots from all players...')
    exports.oxmysql:execute(
        "UPDATE players SET metadata = JSON_REMOVE(metadata, '$.equipmentSlots')",
        {},
        function(rowsAffected)
            print('[rsg-inventory] DONE. equipmentSlots wiped from ' .. tostring(rowsAffected) .. ' players.')
            print('[rsg-inventory] Players will get a clean empty slot structure on next login.')
        end
    )
end, true)
