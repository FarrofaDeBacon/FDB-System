-- ============================================================
-- fdb-medical-core | server/database.lua
-- Integração de Banco de Dados Oficial e Persistência
-- ============================================================

local RSGCore = exports['fdb-core']:GetCoreObject()

-- ============================================================
-- INICIALIZAÇÃO E MIGRAÇÃO DO SCHEMA
-- ============================================================
CreateThread(function()
    Wait(1000) -- Aguarda conexão ao banco

    -- Inicializa tabela de feridas purificada com a escala 0-100 do motor
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS player_wounds_core (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            body_part VARCHAR(50) NOT NULL,
            severity FLOAT NOT NULL DEFAULT 0.0,
            bleeding FLOAT NOT NULL DEFAULT 0.0,
            pain FLOAT NOT NULL DEFAULT 0.0,
            weapon_hash VARCHAR(50),
            weapon_name VARCHAR(100),
            damage_type VARCHAR(50),
            wound_description TEXT,
            is_scar TINYINT(1) DEFAULT 0,
            scar_time TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY `citizen_body_part_scar` (citizenid, body_part, is_scar)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    -- Tabela de histórico de eventos médicos
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS medical_history_core (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            event_type VARCHAR(50) NOT NULL,
            body_part VARCHAR(50),
            details JSON,
            performed_by VARCHAR(50),
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX(citizenid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    print("^2[fdb-medical-core] Database schema initialized.^7")
end)

-- ============================================================
-- FUNÇÕES DE PERSISTÊNCIA
-- ============================================================

--- Loga um evento no histórico médico do jogador
function LogMedicalEvent(citizenid, eventType, bodyPart, details, performedBy)
    if not citizenid or not eventType then return false end
    
    local detailsJson = json.encode(details or {})
    
    MySQL.Async.execute([[
        INSERT INTO medical_history_core 
        (citizenid, event_type, body_part, details, performed_by)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        citizenid,
        eventType,
        bodyPart,
        detailsJson,
        performedBy
    })
    
    return true
end

--- Salva as feridas ativas do jogador (Statebag) pro MySQL
function SaveWoundData(citizenid, woundsData)
    if not citizenid or type(woundsData) ~= 'table' then return false end
    
    MySQL.Async.execute('DELETE FROM player_wounds_core WHERE citizenid = ? AND is_scar = 0', { citizenid }, function()
        for bodyPart, wound in pairs(woundsData) do
            MySQL.Async.execute([[
                INSERT INTO player_wounds_core 
                (citizenid, body_part, severity, bleeding, pain, weapon_hash, weapon_name, damage_type, wound_description)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                citizenid,
                bodyPart,
                wound.severity or 0.0,
                wound.bleeding or 0.0,
                wound.pain or 0.0,
                wound.weaponHash,
                wound.weaponName,
                wound.damageType,
                wound.description
            })
        end
    end)
    
    return true
end

--- Carrega as feridas ativas do MySQL
function LoadWoundData(citizenid)
    if not citizenid then return {} end
    
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_wounds_core WHERE citizenid = ? AND is_scar = 0', {citizenid})
    local wounds = {}
    
    for _, row in ipairs(result) do
        wounds[row.body_part] = {
            severity = tonumber(row.severity) or 0.0,
            bleeding = tonumber(row.bleeding) or 0.0,
            pain = tonumber(row.pain) or 0.0,
            weaponHash = row.weapon_hash,
            weaponName = row.weapon_name,
            damageType = row.damage_type,
            description = row.wound_description,
            timestamp = row.created_at
        }
    end
    
    return wounds
end

--- Cria uma cicatriz
function CreateScar(citizenid, bodyPart, woundData)
    if not citizenid or not bodyPart or not woundData then return false end
    
    if (woundData.severity or 0) >= 30 then
        MySQL.Async.execute([[
            INSERT INTO player_wounds_core 
            (citizenid, body_part, severity, weapon_hash, weapon_name, damage_type, wound_description, is_scar, scar_time)
            VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW())
            ON DUPLICATE KEY UPDATE scar_time = NOW()
        ]], {
            citizenid,
            bodyPart,
            woundData.severity,
            woundData.weaponHash,
            woundData.weaponName,
            woundData.damageType,
            woundData.description or 'Old injury'
        })
        
        LogMedicalEvent(citizenid, 'wound_healed_scar', bodyPart, {
            weaponType = woundData.weaponName,
            severity = woundData.severity
        })
    end
    
    return true
end

--- Retorna as cicatrizes
function GetPlayerScars(citizenid)
    if not citizenid then return {} end
    
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_wounds_core WHERE citizenid = ? AND is_scar = 1 ORDER BY scar_time DESC', {citizenid})
    local scars = {}
    
    for _, row in ipairs(result) do
        table.insert(scars, {
            bodyPart = row.body_part,
            scarType = row.damage_type or 'unknown',
            description = row.wound_description or 'Old injury',
            severity = tonumber(row.severity),
            weaponType = row.weapon_name or 'unknown',
            healedDate = row.scar_time
        })
    end
    
    return scars
end
