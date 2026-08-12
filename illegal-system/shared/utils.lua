Utils = {}

--- Sorteio simples de 1 a 100 comparado contra uma chance percentual.
--- @param chancePercent number
--- @return boolean
function Utils.RollChance(chancePercent)
    if not chancePercent or chancePercent <= 0 then return false end
    return math.random(1, 100) <= chancePercent
end

--- Número inteiro aleatório entre min e max, inclusive.
function Utils.RandomBetween(min, max)
    if min > max then min, max = max, min end
    return math.random(min, max)
end

--- Timestamp unix atual (segundos).
function Utils.Now()
    return os.time()
end

--- Sorteia uma categoria de loot baseada no tierbar/minigame ou chance
function Utils.GetRandomLootPool()
    local roll = math.random(1, 100)
    if roll <= 10 then
        return 'rare'
    elseif roll <= 40 then
        return 'uncommon'
    else
        return 'common'
    end
end
