STBNPC_Lang = STBNPC_Lang or {}

-- idioma padrão (você pode trocar depois via settings)
STBNPC_Lang.current = "EN"

-- tabela de traduções
STBNPC_Lang.data = {

    EN = {
        NPC_HELLO = "Hello",
        NPC_ATTACK = "Attack!",
        NPC_DEFEND = "Defend!",
        NPC_FARM = "Farming",
        NPC_IDLE = "Idle",
    },

    PTBR = {
        NPC_HELLO = "Olá",
        NPC_ATTACK = "Ataque!",
        NPC_DEFEND = "Defender!",
        NPC_FARM = "Fazendo coleta",
        NPC_IDLE = "Ocioso",
    }
}

-- função principal de tradução
function STBNPC_T(key)
    if not key then return nil end

    local lang = STBNPC_Lang.current or "EN"
    local tableLang = STBNPC_Lang.data[lang]

    -- fallback para inglês
    if not tableLang or not tableLang[key] then
        return STBNPC_Lang.data["EN"][key] or key
    end

    return tableLang[key]
end

-- opcional: trocar idioma em runtime
function STBNPC_SetLanguage(lang)
    if STBNPC_Lang.data[lang] then
        STBNPC_Lang.current = lang
    end
end