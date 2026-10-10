-- ============================================================
-- FDB System | fdb-shops | server/employee_manager.lua
-- Employee and permissions management with grades & duty
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local resourceName = GetCurrentResourceName()

EmployeeManager = {
    Duty = {}, -- [shopId .. ':' .. citizenid] = true/false
    Cache = {} -- [shopId .. ':' .. citizenid] = { perms = table, expires = timestamp }
}

local DEFAULT_GRADES = {
    [1] = { name = "Aprendiz / Fabricante", perms = { craftar = true, atender = false, repor_estoque = false, financeiro = false, editar_precos = false, gerenciar_funcionarios = false } },
    [2] = { name = "Estoquista", perms = { craftar = true, repor_estoque = true, atender = false, financeiro = false, editar_precos = false, gerenciar_funcionarios = false } },
    [3] = { name = "Vendedor / Caixa", perms = { craftar = true, repor_estoque = true, atender = true, financeiro = true, editar_precos = false, gerenciar_funcionarios = false } },
    [4] = { name = "Gerente", perms = { craftar = true, repor_estoque = true, atender = true, financeiro = true, editar_precos = true, gerenciar_funcionarios = true } }
}

--- Resolves default permissions for a grade level merged with explicit flags
local function resolveGradePerms(gradeLevel, perms)
    local grade = DEFAULT_GRADES[tonumber(gradeLevel)] or DEFAULT_GRADES[1]
    local finalPerms = {}
    for k, v in pairs(grade.perms) do
        finalPerms[k] = v
    end
    if type(perms) == 'table' then
        for k, v in pairs(perms) do
            if type(v) == 'boolean' then
                finalPerms[k] = v
            end
        end
    end
    return finalPerms
end

--- Validates if a caller can manage a target with specific finalPerms
function EmployeeManager.CanManage(shopId, callerCitizenId, targetCitizenId, targetGradeLevel, finalPerms)
    if callerCitizenId == targetCitizenId then return false, "Você não pode editar a si mesmo." end
    
    local callerPerms = EmployeeManager.GetPermissions(shopId, callerCitizenId)
    if not callerPerms or not callerPerms.gerenciar_funcionarios then
        return false, "Você não tem permissão para gerenciar funcionários."
    end
    
    if callerPerms.isOwner or callerPerms.isAdmin then
        return true, ""
    end

    -- Regular manager restrictions
    if finalPerms.gerenciar_funcionarios then
        return false, "Apenas o proprietário pode conceder permissão de gerência."
    end

    local targetExistingPerms = EmployeeManager.GetPermissions(shopId, targetCitizenId)
    if targetExistingPerms and targetExistingPerms.isOwner then
        return false, "Você não pode editar o proprietário."
    end

    if targetExistingPerms and targetExistingPerms.gradeLevel and targetExistingPerms.gradeLevel >= callerPerms.gradeLevel then
        return false, "Você não pode editar alguém com cargo igual ou superior."
    end

    if targetGradeLevel >= callerPerms.gradeLevel then
        return false, "Você não pode promover alguém a um cargo igual ou superior ao seu."
    end
    
    -- "só concede o que possui"
    for k, v in pairs(finalPerms) do
        if v and not callerPerms[k] then
            return false, "Você não pode conceder permissões que não possui (" .. k .. ")."
        end
    end

    return true, ""
end

function EmployeeManager.InvalidateCache(shopId, citizenid)
    EmployeeManager.Cache[shopId .. ':' .. citizenid] = nil
end

--- Hires or updates an employee
function EmployeeManager.Hire(shopId, callerCitizenId, targetCitizenId, perms, gradeLevel, roleName)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return false, "Loja não encontrada" end
    if not targetCitizenId or targetCitizenId == "" then return false, "Cidadão inválido" end
    
    local grade = tonumber(gradeLevel)
    if not grade or grade < 1 or grade > 4 then grade = 1 end

    local role = (roleName and roleName ~= '') and roleName or DEFAULT_GRADES[grade].name
    local finalPerms = resolveGradePerms(grade, perms)

    -- If callerCitizenId is provided, do security checks
    if callerCitizenId then
        local canManage, reason = EmployeeManager.CanManage(shopId, callerCitizenId, targetCitizenId, grade, finalPerms)
        if not canManage then return false, reason end
    end
    
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
        shopId, targetCitizenId, grade, role,
        finalPerms.atender and 1 or 0,
        finalPerms.repor_estoque and 1 or 0,
        finalPerms.craftar and 1 or 0,
        finalPerms.financeiro and 1 or 0,
        finalPerms.editar_precos and 1 or 0,
        finalPerms.gerenciar_funcionarios and 1 or 0
    })

    EmployeeManager.InvalidateCache(shopId, targetCitizenId)

    if callerCitizenId then
        -- Audit Log
        MySQL.insert('INSERT INTO shop_transactions (shop_id, buyer_name, transaction_type, item_name, quantity, total_price, metadata, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())', {
            shopId, callerCitizenId, 'employee_update', targetCitizenId, 1, 0, json.encode({ grade = grade, role = role, perms = finalPerms })
        })
    end

    return true, "Sucesso"
end

function EmployeeManager.Fire(shopId, callerCitizenId, targetCitizenId)
    local targetExistingPerms = EmployeeManager.GetPermissions(shopId, targetCitizenId)
    if not targetExistingPerms then return false, "Funcionário não encontrado." end
    
    if callerCitizenId then
        -- We reuse CanManage logic but without new perms checking
        local callerPerms = EmployeeManager.GetPermissions(shopId, callerCitizenId)
        if not callerPerms or not callerPerms.gerenciar_funcionarios then
            return false, "Sem permissão."
        end
        if targetCitizenId == callerCitizenId then
            return false, "Não pode demitir a si mesmo."
        end
        if targetExistingPerms.isOwner then
            return false, "Não pode demitir o proprietário."
        end
        if not callerPerms.isOwner and not callerPerms.isAdmin and targetExistingPerms.gradeLevel >= callerPerms.gradeLevel then
            return false, "Não pode demitir cargo igual ou superior."
        end
    end

    MySQL.update('DELETE FROM shop_employees WHERE shop_id = ? AND player_id = ?', {shopId, targetCitizenId})
    EmployeeManager.Duty[shopId .. ':' .. targetCitizenId] = nil
    EmployeeManager.InvalidateCache(shopId, targetCitizenId)

    if callerCitizenId then
        MySQL.insert('INSERT INTO shop_transactions (shop_id, buyer_name, transaction_type, item_name, quantity, total_price, metadata, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())', {
            shopId, callerCitizenId, 'employee_fire', targetCitizenId, 1, 0, "{}"
        })
    end

    return true, "Sucesso"
end

function EmployeeManager.SetDuty(shopId, citizenid, isDuty)
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)
    -- Must be an employee or owner
    if not perms or perms.isPublic or (not perms.isOwner and not perms.isAdmin and not perms.atender and not perms.craftar and not perms.repor_estoque and not perms.financeiro and not perms.editar_precos and not perms.gerenciar_funcionarios) then
        return false
    end

    local key = shopId .. ':' .. citizenid
    EmployeeManager.Duty[key] = (isDuty == true)
    
    pcall(function()
        MySQL.update('UPDATE shop_employees SET is_duty = ? WHERE shop_id = ? AND player_id = ?', {isDuty and 1 or 0, shopId, citizenid})
    end)
    return EmployeeManager.Duty[key]
end

function EmployeeManager.IsOnDuty(shopId, citizenid)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return false end
    
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)
    if not perms or perms.isPublic or (not perms.isOwner and not perms.isAdmin and not perms.atender and not perms.craftar and not perms.repor_estoque and not perms.financeiro and not perms.editar_precos and not perms.gerenciar_funcionarios) then
        return false
    end

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

function EmployeeManager.GetPermissions(shopId, citizenid)
    local cacheKey = shopId .. ':' .. citizenid
    if EmployeeManager.Cache[cacheKey] and EmployeeManager.Cache[cacheKey].expires > os.time() then
        return EmployeeManager.Cache[cacheKey].perms
    end

    local shop = ShopManager.GetShop(shopId)
    if not shop then return nil end

    local player = FDBCore.Functions.GetPlayerByCitizenId(citizenid)
    local isAdmin = false
    if player and player.PlayerData and player.PlayerData.source then
        isAdmin = FDBCore.Functions.HasPermission(player.PlayerData.source, 'admin')
    end

    local resultPerms = nil

    if isAdmin or (shop.ownerId and shop.ownerId == citizenid) then
        resultPerms = {
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
    elseif not shop.ownerId or shop.ownerId == "" then
        resultPerms = {
            atender = false,
            repor_estoque = false,
            craftar = false,
            financeiro = false,
            editar_precos = false,
            gerenciar_funcionarios = false,
            isOwner = false,
            isPublic = true,
            gradeLevel = 0,
            roleName = "Público"
        }
    else
        local row = MySQL.single.await('SELECT * FROM shop_employees WHERE shop_id = ? AND player_id = ?', {shopId, citizenid})
        if row then
            resultPerms = {
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
    end

    if resultPerms then
        EmployeeManager.Cache[cacheKey] = {
            perms = resultPerms,
            expires = os.time() + 300 -- 5 minutes cache
        }
    end

    return resultPerms
end

function EmployeeManager.HasPermission(shopId, citizenid, permName)
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)
    if not perms then return false end
    if perms.isOwner or perms.isAdmin then return true end
    return perms[permName] == true
end

function EmployeeManager.GetEmployees(shopId)
    local employees = {}
    local result = MySQL.query.await('SELECT * FROM shop_employees WHERE shop_id = ? ORDER BY grade_level DESC, hired_at ASC', {shopId})
    if result and #result > 0 then
        local cids = {}
        for _, r in ipairs(result) do table.insert(cids, r.player_id) end
        
        -- Resolve names in bulk
        local cidStr = "'" .. table.concat(cids, "','") .. "'"
        local pRows = MySQL.query.await('SELECT citizenid, charinfo FROM players WHERE citizenid IN ('..cidStr..')')
        local pMap = {}
        if pRows then
            for _, pr in ipairs(pRows) do pMap[pr.citizenid] = pr.charinfo end
        end

        for _, row in ipairs(result) do
            local charName = "Desconhecido"
            local isOnline = false
            local onlinePlayer = FDBCore.Functions.GetPlayerByCitizenId(row.player_id)
            
            if onlinePlayer and onlinePlayer.PlayerData and onlinePlayer.PlayerData.charinfo then
                charName = (onlinePlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (onlinePlayer.PlayerData.charinfo.lastname or '')
                isOnline = true
            else
                if pMap[row.player_id] then
                    local c = json.decode(pMap[row.player_id]) or {}
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

-- Reset duty on login/drop
RegisterNetEvent('fdb-core:server:PlayerDropped', function(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        local cid = Player.PlayerData.citizenid
        for k, v in pairs(EmployeeManager.Duty) do
            if k:match(':' .. cid .. '$') then
                EmployeeManager.Duty[k] = nil
                local shopId = k:gsub(':' .. cid .. '$', '')
                MySQL.update('UPDATE shop_employees SET is_duty = 0 WHERE shop_id = ? AND player_id = ?', {shopId, cid})
            end
        end
    end
end)

RegisterNetEvent('fdb-core:server:OnPlayerLoaded', function(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        local cid = Player.PlayerData.citizenid
        MySQL.update('UPDATE shop_employees SET is_duty = 0 WHERE player_id = ?', {cid})
        for k, v in pairs(EmployeeManager.Duty) do
            if k:match(':' .. cid .. '$') then
                EmployeeManager.Duty[k] = nil
            end
        end
    end
end)
