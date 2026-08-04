Utils = {}

--- Retorna o identificador de stash padrão do inventário para um UID de mochila
--- @param uid string
--- @return string
function Utils.GetStashName(uid)
    if not uid then return nil end
    return "bp_" .. uid
end
