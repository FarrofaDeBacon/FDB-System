-- ============================================================
-- FDB System | fdb-libs | client/utils/loaders.lua
-- Asynchronous Loaders for resources (Models, Dicts, etc)
-- ============================================================

-- Carrega um modelo (Ped, Objeto, Cavalo)
local function LoadModel(model)
    local hash = type(model) == "string" and joaat(model) or model
    if not IsModelValid(hash) then 
        print(("[fdb-libs] ERROR: Model %s is not valid."):format(tostring(model)))
        return false 
    end
    if HasModelLoaded(hash) then return true end

    RequestModel(hash)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(hash) then
        print(("[fdb-libs] ERROR: Failed to load model %s (timeout)."):format(tostring(model)))
        return false
    end
    return true
end

-- Carrega um dicionario de animacao
local function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasAnimDictLoaded(dict) then
        print(("[fdb-libs] ERROR: Failed to load AnimDict %s (timeout)."):format(tostring(dict)))
        return false
    end
    return true
end

-- Carrega uma partícula (PTFX)
local function LoadParticleFx(ptfx)
    if HasNamedPtfxAssetLoaded(ptfx) then return true end
    
    RequestNamedPtfxAsset(ptfx)
    local timeout = GetGameTimer() + 5000
    while not HasNamedPtfxAssetLoaded(ptfx) and GetGameTimer() < timeout do
        Wait(10)
    end
    
    if not HasNamedPtfxAssetLoaded(ptfx) then
        print(("[fdb-libs] ERROR: Failed to load PTFX %s (timeout)."):format(tostring(ptfx)))
        return false
    end
    return true
end

-- Carrega um Asset de Arma
local function LoadWeaponAsset(weaponHash)
    local hash = type(weaponHash) == "string" and joaat(weaponHash) or weaponHash
    if HasWeaponAssetLoaded(hash) then return true end
    
    RequestWeaponAsset(hash)
    local timeout = GetGameTimer() + 5000
    while not HasWeaponAssetLoaded(hash) and GetGameTimer() < timeout do
        Wait(10)
    end
    
    if not HasWeaponAssetLoaded(hash) then
        print(("[fdb-libs] ERROR: Failed to load WeaponAsset %s (timeout)."):format(tostring(weaponHash)))
        return false
    end
    return true
end

-- Registra os exports
exports('LoadModel', LoadModel)
exports('LoadAnimDict', LoadAnimDict)
exports('LoadParticleFx', LoadParticleFx)
exports('LoadWeaponAsset', LoadWeaponAsset)

-- COMANDO DE TESTE TEMPORARIO
RegisterCommand('testloader', function()
    Citizen.CreateThread(function()
        print('[fdb-libs] Testando LoadModel (p_cigar01x)...')
        local result = exports['fdb-libs']:LoadModel('p_cigar01x')
        print('[fdb-libs] Resultado LoadModel: ' .. tostring(result))
    end)
end, false)
