-- ============================================================
-- FDB System | fdb-shops | server/employee_manager.lua
-- Employee and permissions management with grades & duty
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local resourceName = GetCurrentResourceName()

EmployeeManager = {
    Duty = {} -- [shopId .. ':' .. citizenid] = true/false
}

local DEFAULT_GRADES = {
    [1] = {
        name = "Aprendiz / Fabricante",
        perms = { craftar = true, atender = false, repor_estoque = false, financeiro = false, editar_precos = false, gerenciar_funcionarios = false }
    },
    [2] = {
        name = "Estoquista",
        perms = { craftar = true, repor_estoque = true, atender = false, financeiro = false, editar_precos = false, gerenciar_funcionarios = false }
    },
    [3] = {
        name = "Vendedor / Caixa",
        perms = { craftar = true, repor_estoque = true, atender = true, financeiro = true, editar_precos = false, gerenciar_funcionarios = false }
    },
    [4] = {
        name = "Gerente",
        perms = { craftar = true, repor_estoque = true, atender = true, financeiro = true, editar_precos = true, gerenciar_funcionarios = true }
    }
}

--- Resolves default permissions for a grade level if perms table is empty
local function resolveGradePerms(gradeLevel, perms)
    local grade = DEFAULT_GRADES[tonumber(gradeLevel) or 1] or DEFAULT_GRADES[1]
    if perms and next(perms) ~= nil then
        return perms
    end
    return grade.perms
end

--- Hires an employee for a shop
--- @param shopId string
--- @param citizenid string
--- @param perms table
--- @param gradeLevel number
--- @param roleName string
function EmployeeManager.Hire(shopId, citizenid, perms, gradeLevel, roleName)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return false, "Shop not found" end
    
    local grade = tonumber(gradeLevel) or 1
    local role = (roleName and roleName ~= '') and roleName or (DEFAULT_GRADES[grade] and DEFAULT_GRADES[grade].name or "Auxiliar")
    perms = resolveGradePerms(grade, perms)
    
    MySQL.insert([[
        INSERT INTO shop_employees (shop_id, player_id, grade_level, role_name, perm_atender, perm_repor_estoque, perm_craftar, perm_financeiro, perm_editar_precos, perm_gerenciar_funcionarios)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            grade_level = VALUES(grade_level),
            role_name = VALUES(role_name),
            perm_atender = VALUES(perm_atender),
            perm_repor_estoque = VALUES(perm_repor_estoque),
            perm_craftar = VALUES(perm_craftar),
            perm_financeiro = VALUES(perm_financeiro),
            perm_editar_precos = VALUES(perm_editar_precos),
            perm_gerenciar_funcionarios = VALUES(perm_gerenciar_funcionarios)
    ]], {
        shopId, 
        citizenid, 
        grade,
        role,
        perms.atender and 1 or 0,
        perms.repor_estoque and 1 or 0,
        perms.craftar and 1 or 0,
        perms.financeiro and 1 or 0,
        perms.editar_precos and 1 or 0,
        perms.gerenciar_funcionarios and 1 or 0
    })

    return true
end

--- Fires an employee from a shop
--- @param shopId string
--- @param citizenid string
function EmployeeManager.Fire(shopId, citizenid)
    MySQL.update('DELETE FROM shop_employees WHERE shop_id = ? AND player_id = ?', {shopId, citizenid})
    EmployeeManager.Duty[shopId .. ':' .. citizenid] = nil
    return true
end

--- Updates employee permissions and role
function EmployeeManager.UpdatePermissions(shopId, citizenid, newPerms, gradeLevel, roleName)
    return EmployeeManager.Hire(shopId, citizenid, newPerms, gradeLevel, roleName)
end

--- Toggles or sets duty status
function EmployeeManager.SetDuty(shopId, citizenid, isDuty)
    local key = shopId .. ':' .. citizenid
    EmployeeManager.Duty[key] = (isDuty == true)
    
    pcall(function()
        MySQL.update('UPDATE shop_employees SET is_duty = ? WHERE shop_id = ? AND player_id = ?', {isDuty and 1 or 0, shopId, citizenid})
    end)
    return EmployeeManager.Duty[key]
end

--- Checks if an employee is on duty
function EmployeeManager.IsOnDuty(shopId, citizenid)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return false end
    
    -- Owner and Admins have duty override if not explicitly toggled
    local player = FDBCore.Functions.GetPlayerByCitizenId(citizenid)
    if player and player.PlayerData and player.PlayerData.source then
        if FDBCore.Functions.HasPermission(player.PlayerData.source, 'admin') then return true end
    end
    if shop.ownerId and shop.ownerId == citizenid then
        local key = shopId .. ':' .. citizenid
        if EmployeeManager.Duty[key] ~= nil then
            return EmployeeManager.Duty[key]
        end
        return true -- Owners are on-duty by default
    end
    
    local key = shopId .. ':' .. citizenid
    if EmployeeManager.Duty[key] ~= nil then
        return EmployeeManager.Duty[key]
    end
    
    local row = MySQL.single.await('SELECT is_duty FROM shop_employees WHERE shop_id = ? AND player_id = ?', {shopId, citizenid})
    if row and row.is_duty == 1 then
        EmployeeManager.Duty[key] = true
        return true
    end
    
    return false
end

--- Gets all permissions for a specific employee
--- @param shopId string
--- @param citizenid string
--- @return table|nil
function EmployeeManager.GetPermissions(shopId, citizenid)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return nil end

    local player = FDBCore.Functions.GetPlayerByCitizenId(citizenid)
    local isAdmin = false
    if player and player.PlayerData and player.PlayerData.source then
        isAdmin = FDBCore.Functions.HasPermission(player.PlayerData.source, 'admin')
    end

    if isAdmin or (shop.ownerId and shop.ownerId == citizenid) then
        return {
            atender = true,
            repor_estoque = true,
            craftar = true,
            financeiro = true,
            editar_precos = true,
            gerenciar_funcionarios = true,
            isOwner = (shop.ownerId and shop.ownerId == citizenid),
            isAdmin = isAdmin,
            gradeLevel = 5,
            roleName = (shop.ownerId and shop.ownerId == citizenid) and "Proprietário" or "Administrador"
        }
    end

    -- Public shop (no player owner): allow general public crafting and attending
    if not shop.ownerId or shop.ownerId == "" then
        return {
            atender = true,
            repor_estoque = false,
            craftar = true,
            financeiro = false,
            editar_precos = false,
            gerenciar_funcionarios = false,
            isOwner = false,
            isPublic = true,
            gradeLevel = 0,
            roleName = "Público"
        }
    end

    local row = MySQL.single.await('SELECT * FROM shop_employees WHERE shop_id = ? AND player_id = ?', {shopId, citizenid})
    if not row then return nil end

    return {
        atender = row.perm_atender == 1,
        repor_estoque = row.perm_repor_estoque == 1,
        craftar = row.perm_craftar == 1,
        financeiro = row.perm_financeiro == 1,
        editar_precos = row.perm_editar_precos == 1,
        gerenciar_funcionarios = row.perm_gerenciar_funcionarios == 1,
        isOwner = false,
        gradeLevel = tonumber(row.grade_level) or 1,
        roleName = row.role_name or "Auxiliar"
    }
end

--- Quick check if an employee has a specific permission
function EmployeeManager.HasPermission(shopId, citizenid, permName)
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)
    if not perms then return false end
    if perms.isOwner or perms.isAdmin then return true end
    return perms[permName] == true
end

--- Fetch all employees of a shop with names and online status
function EmployeeManager.GetEmployees(shopId)
    local employees = {}
    local result = MySQL.query.await('SELECT * FROM shop_employees WHERE shop_id = ? ORDER BY grade_level DESC, hired_at ASC', {shopId})
    if result then
        for _, row in ipairs(result) do
            local charName = "Desconhecido"
            local isOnline = false
            local onlinePlayer = FDBCore.Functions.GetPlayerByCitizenId(row.player_id)
            
            if onlinePlayer and onlinePlayer.PlayerData and onlinePlayer.PlayerData.charinfo then
                charName = (onlinePlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (onlinePlayer.PlayerData.charinfo.lastname or '')
                isOnline = true
            else
                local pRow = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', {row.player_id})
                if pRow and pRow.charinfo then
                    local c = json.decode(pRow.charinfo) or {}
                    charName = (c.firstname or '') .. ' ' .. (c.lastname or '')
                end
            end
            
            if charName:gsub('%s+', '') == '' then
                charName = "Cidadão (" .. tostring(row.player_id) .. ")"
            end

            local onDuty = EmployeeManager.Duty[shopId .. ':' .. row.player_id]
            if onDuty == nil then
                onDuty = (row.is_duty == 1)
            end

            table.insert(employees, {
                citizenid = row.player_id,
                name = charName,
                gradeLevel = tonumber(row.grade_level) or 1,
                roleName = row.role_name or (DEFAULT_GRADES[tonumber(row.grade_level) or 1] and DEFAULT_GRADES[tonumber(row.grade_level) or 1].name or "Auxiliar"),
                isOnline = isOnline,
                isDuty = onDuty,
                perms = {
                    atender = row.perm_atender == 1,
                    repor_estoque = row.perm_repor_estoque == 1,
                    craftar = row.perm_craftar == 1,
                    financeiro = row.perm_financeiro == 1,
                    editar_precos = row.perm_editar_precos == 1,
                    gerenciar_funcionarios = row.perm_gerenciar_funcionarios == 1,
                },
                hiredAt = row.hired_at
            })
        end
    end
    return employees
end

--- Gets players in proximity of the caller to hire
function EmployeeManager.GetNearbyPlayers(source, maxDistance)
    maxDistance = maxDistance or 10.0
    local nearby = {}
    local callerPed = GetPlayerPed(source)
    if not callerPed or callerPed == 0 then return nearby end
    local callerCoords = GetEntityCoords(callerPed)

    local players = FDBCore.Functions.GetPlayers()
    for _, targetSrc in ipairs(players) do
        if targetSrc ~= source then
            local targetPed = GetPlayerPed(targetSrc)
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local dist = #(callerCoords - targetCoords)
                if dist <= maxDistance then
                    local targetPlayer = FDBCore.Functions.GetPlayer(targetSrc)
                    if targetPlayer and targetPlayer.PlayerData and targetPlayer.PlayerData.charinfo then
                        local charName = (targetPlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (targetPlayer.PlayerData.charinfo.lastname or '')
                        table.insert(nearby, {
                            source = targetSrc,
                            citizenid = targetPlayer.PlayerData.citizenid,
                            name = charName,
                            distance = math.floor(dist * 10) / 10
                        })
                    end
                end
            end
        end
    end
    return nearby
end
