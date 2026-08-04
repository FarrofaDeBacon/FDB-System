local consumeAnimations = {
	eat = {
		dict = 'mech_inventory@eating@multi_bite@sphere_d8-2_sandwich',
		clip = 'quick_right_hand',
		duration = 2000,
		attach = { x = 0.1, y = -0.01, z = -0.07, rx = -90.0, ry = 100.0, rz = 0.0 }
	},
	drink = {
		dict = 'amb_rest_drunk@world_human_drinking@male_a@idle_a',
		clip = 'idle_a',
		duration = 4000,
		attach = { x = 0.05, y = -0.07, z = -0.05, rx = -75.0, ry = 60.0, rz = 0.0 }
	},
	canned = {
		dict = 'mech_inventory@eating@canned_food@cylinder@d8-2_h10-5',
		clip = 'left_hand',
		duration = 2000,
		attach = { x = 0.10, y = -0.03, z = 0.02, rx = 20.0, ry = -70.0, rz = -20.0 }
	},
	medical = {
		dict = 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5',
		clip = 'chug_a',
		duration = 2000,
		attach = { x = 0.0, y = 0.0, z = 0.04, rx = 0.0, ry = 0.0, rz = 0.0 }
	},
	drug = {
		dict = 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5',
		clip = 'chug_a',
		duration = 2000,
		attach = { x = 0.0, y = 0.0, z = 0.04, rx = 0.0, ry = 0.0, rz = 0.0 }
	}
}

function eatstew()
    local ped = PlayerPedId()
    RequestModel(`p_bowl04x_stew`)
    RequestModel(`p_spoon01x`)
    while not HasModelLoaded(`p_bowl04x_stew`) or not HasModelLoaded(`p_spoon01x`) do Wait(10) end
    
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(`p_bowl04x_stew`, coords.x, coords.y, coords.z, true, true, false)
    local prop2 = CreateObject(`p_spoon01x`, coords.x, coords.y, coords.z, true, true, false)
    
    Citizen.InvokeNative(0x669655FFB29EF1A9, prop, 0, "Stew_Fill", 1.0)
    Citizen.InvokeNative(0xCAAF2BCCFEF37F77, prop, 20)
    Citizen.InvokeNative(0xCAAF2BCCFEF37F77, prop2, 82)
    TaskItemInteraction_2(ped, 599184882, prop, `p_bowl04x_stew_ph_l_hand`, -583731576, 1, 0, 0.0)
    TaskItemInteraction_2(ped, 599184882, prop2, `p_spoon01x_ph_r_hand`, -583731576, 1, 0, 0.0)
    Citizen.InvokeNative(0xB35370D5353995CB, ped, -583731576, 1.0)
end

local activeConsumeProp = nil

local function cleanupConsumeProp()
	if activeConsumeProp then
		if DoesEntityExist(activeConsumeProp) then
			DetachEntity(activeConsumeProp, true, true)
			DeleteObject(activeConsumeProp)
		end
		activeConsumeProp = nil
	end
end

function playConsumeAnimation(spec)
	local ped = PlayerPedId()
	if ped == 0 or not DoesEntityExist(ped) then
		return
	end

	local animType = 'eat'
	local propName = nil
	local duration = nil

	if type(spec) == 'table' then
		if type(spec.animation) == 'string' and spec.animation ~= '' then
			animType = spec.animation:lower()
		elseif type(spec.anim) == 'string' and spec.anim ~= '' then
			animType = spec.anim:lower()
		end
		if type(spec.prop) == 'string' and spec.prop ~= '' then
			propName = spec.prop
		end
		if spec.duration ~= nil then
			duration = tonumber(spec.duration)
		end
	elseif type(spec) == 'string' and spec ~= '' then
		propName = spec
	end

    print("DEBUG: playConsumeAnimation animType: " .. tostring(animType) .. " propName: " .. tostring(propName))

	if animType == 'stew' then
        print("DEBUG: Entrando no eatstew")
        eatstew()
        return
    end

	local animDef = consumeAnimations[animType] or consumeAnimations.eat
	local dict = animDef.dict
	local clip = animDef.clip
	local defaultDuration = animDef.duration or 2000
	local attach = animDef.attach

	local modelName = propName or animDef.defaultProp or 'P_BREAD05X'
	local modelHash = GetHashKey(modelName)

    print("DEBUG: dict: " .. tostring(dict) .. " clip: " .. tostring(clip) .. " model: " .. tostring(modelName))

	RequestAnimDict(dict)
	local attempts = 0
	while not HasAnimDictLoaded(dict) and attempts < 50 do
		attempts = attempts + 1
		Wait(50)
	end
	if not HasAnimDictLoaded(dict) then
        print("DEBUG: Falhou ao carregar o dict: " .. tostring(dict))
		return
	end

	RequestModel(modelHash)
	attempts = 0
	while not HasModelLoaded(modelHash) and attempts < 50 do
		attempts = attempts + 1
		Wait(50)
	end
	if not HasModelLoaded(modelHash) then
        print("DEBUG: Falhou ao carregar o model: " .. tostring(modelName))
		RemoveAnimDict(dict)
		return
	end

    print("DEBUG: Tudo carregado. Verificando fumo...")
	do
		local t = animType
		if t == 'cigarette' or t == 'cigaret' then
			TriggerEvent('fdb-consume:prop:cigaret')
			return
		elseif t == 'cigar' or t == 'smoke' then
            print("DEBUG: Executando scenario nativo de charuto (WORLD_HUMAN_SMOKE_CIGAR)")
			ClearPedTasks(PlayerPedId())
			TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_SMOKE_CIGAR'), -1, true, false, false, false)
			return
		elseif t == 'pipe' or t == 'pipe_smoker' then
			TriggerEvent('fdb-consume:prop:pipe_smoker')
			return
		elseif t == 'chew' or t == 'chewing' or t == 'chewingtobacco' then
			TriggerEvent('fdb-consume:prop:chewingtobacco')
			return
		end
	end

    print("DEBUG: Tocando animacao generica e segurando prop")
	cleanupConsumeProp()

    -- Dispara o evento que vai segurar o prop e criar os Prompts Interativos (Dar Gole/Dar Mordida)
    TriggerEvent('fdb-consume:client:StartInteractiveConsumable', animType, modelHash, attach)

	RemoveAnimDict(dict)
	SetModelAsNoLongerNeeded(modelHash)
    print("DEBUG: playConsumeAnimation finalizado")
end

RegisterNetEvent('fdb-consume:playConsumeAnim', function(propName)
	playConsumeAnimation(propName)
end)

exports('PlayConsumeAnimation', playConsumeAnimation)
