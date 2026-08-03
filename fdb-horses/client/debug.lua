-- ============================================================
-- FASE D (PROVA PRÁTICA) — Teste de Nativas do Adestrador
-- ============================================================

RegisterNetEvent('fdb-horses:client:debug:TestTrainerNative', function(action)
    local horsePed = GetActiveHorsePed and GetActiveHorsePed() or 0

    if horsePed == 0 or not DoesEntityExist(horsePed) then
        local playerPed = cache.ped
        if IsPedOnMount(playerPed) then
            horsePed = GetMount(playerPed)
        end
    end

    if not horsePed or horsePed == 0 or not DoesEntityExist(horsePed) then
        lib.notify({ title = '[PROVA] Nenhum cavalo ativo encontrado.', type = 'error', duration = 5000 })
        return
    end

    -- --------------------------------------------------------
    -- 1. TASK_HORSE_ACTION (Action 1 = Rear Up / Empinar)
    -- --------------------------------------------------------
    if action == 'empinar' then
        if not IsPedOnMount(cache.ped) then
            lib.notify({ title = '[PROVA] Monte no cavalo para testar empinar!', type = 'warning', duration = 5000 })
            return
        end

        lib.notify({ title = '[PROVA] Disparando TaskHorseAction(horse, 1, 0, 0)', description = 'Executando empinada nativa...', type = 'inform', duration = 4000 })
        
        -- Chamada nativa de empinar
        TaskHorseAction(horsePed, 1, 0, 0)
        Wait(3000)

        lib.notify({ title = '[PROVA] Teste empinar concluído. O cavalo empinou?', type = 'success', duration = 6000 })

    -- --------------------------------------------------------
    -- 2. TASK_HORSE_ACTION (Action 3 = Side-Pass / Passo Lateral)
    -- --------------------------------------------------------
    elseif action == 'passolateral' then
        if not IsPedOnMount(cache.ped) then
            lib.notify({ title = '[PROVA] Monte no cavalo para testar passo lateral!', type = 'warning', duration = 5000 })
            return
        end

        lib.notify({ title = '[PROVA] Disparando TaskHorseAction(horse, 3, 0, 0)', description = 'Executando passo lateral...', type = 'inform', duration = 4000 })
        
        -- Chamada nativa de passo lateral
        TaskHorseAction(horsePed, 3, 0, 0)
        Wait(3000)

        lib.notify({ title = '[PROVA] Teste passo lateral concluído. O cavalo andou de lado?', type = 'success', duration = 6000 })

    -- --------------------------------------------------------
    -- 3. TASK_LEAD_HORSE (Conduzir Rédea a pé)
    -- --------------------------------------------------------
    elseif action == 'conduzir' then
        if IsPedOnMount(cache.ped) then
            lib.notify({ title = '[PROVA] Desmonte do cavalo para testar conduzir!', type = 'warning', duration = 5000 })
            return
        end

        lib.notify({ title = '[PROVA] Disparando TaskLeadHorse(player, horse, true)', description = 'Puxando pela rédea...', type = 'inform', duration = 4000 })
        
        -- Chamada nativa de conduzir rédea
        TaskLeadHorse(cache.ped, horsePed, true)
        Wait(4000)

        lib.notify({ title = '[PROVA] Teste conduzir concluído. O personagem segurou a rédea?', type = 'success', duration = 6000 })
    end
end)
