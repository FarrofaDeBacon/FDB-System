-- ============================================================
-- FDB System | fdb-shops | server/employee_manager.lua
-- Employee and permissions management
-- ============================================================

local resourceName = GetCurrentResourceName()

EmployeeManager = {}

--- Hires an employee for a shop
--- @param shopId string
--- @param citizenid string
--- @param perms table
function EmployeeManager.Hire(shopId, citizenid, perms)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return false, "Shop not found" end
    
    perms = perms or {}
    
    -- Insert or update
    MySQL.insert([[
        INSERT INTO shop_employees (shop_id, player_id, perm_atender, perm_repor_estoque, perm_craftar, perm_financeiro, perm_editar_precos, perm_gerenciar_funcionarios)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            perm_atender = VALUES(perm_atender),
            perm_repor_estoque = VALUES(perm_repor_estoque),
            perm_craftar = VALUES(perm_craftar),
            perm_financeiro = VALUES(perm_financeiro),
            perm_editar_precos = VALUES(perm_editar_precos),
            perm_gerenciar_funcionarios = VALUES(perm_gerenciar_funcionarios)
    ]], {
        shopId, 
        citizenid, 
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
    return true
end

--- Updates employee permissions
--- @param shopId string
--- @param citizenid string
--- @param newPerms table
function EmployeeManager.UpdatePermissions(shopId, citizenid, newPerms)
    return EmployeeManager.Hire(shopId, citizenid, newPerms)
end

--- Gets all permissions for a specific employee
--- @param shopId string
--- @param citizenid string
--- @return table|nil
function EmployeeManager.GetPermissions(shopId, citizenid)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return nil end

    if shop.ownerId == citizenid then
        -- Owner has all permissions implicitly
        return {
            atender = true,
            repor_estoque = true,
            craftar = true,
            financeiro = true,
            editar_precos = true,
            gerenciar_funcionarios = true,
            isOwner = true
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
        isOwner = false
    }
end

--- Quick check if an employee has a specific permission
--- @param shopId string
--- @param citizenid string
--- @param permName string
--- @return boolean
function EmployeeManager.HasPermission(shopId, citizenid, permName)
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)
    if not perms then return false end
    if perms.isOwner then return true end
    return perms[permName] == true
end

--- Fetch all employees of a shop
--- @param shopId string
--- @return table
function EmployeeManager.GetEmployees(shopId)
    local employees = {}
    local result = MySQL.query.await('SELECT * FROM shop_employees WHERE shop_id = ?', {shopId})
    if result then
        for _, row in ipairs(result) do
            table.insert(employees, {
                citizenid = row.player_id,
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
