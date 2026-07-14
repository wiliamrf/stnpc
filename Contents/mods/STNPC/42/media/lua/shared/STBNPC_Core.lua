-- =========================================================
-- STBNPC - STATIC WAVE
-- Core System (Base da Engine)
-- =========================================================
-- Responsável por:
-- 1. Inicializar sistemas (Party / Totem / AI)
-- 2. Registrar eventos do jogo
-- 3. Criar loop leve de atualização
-- 4. Evitar execução pesada por frame
-- =========================================================

STBNPC = STBNPC or {}

-- =========================================================
-- CONFIGURAÇÃO GLOBAL DO SISTEMA
-- =========================================================
STBNPC.Config = {
    updateInterval = 10,   -- ticks entre atualizações leves (performance)
    lastUpdateTick = 0
}

-- =========================================================
-- LISTA GLOBAL DE NPCs GERENCIADOS
-- =========================================================
STBNPC.NPCs = {}

-- =========================================================
-- INICIALIZA O SISTEMA STBNPC
-- =========================================================
function STBNPC_Init()

    print("[STBNPC] Static Wave System Initializing...")

    -- Inicializa sub-sistemas (serão criados depois)
    if STBNPC_PartyManager_Init then
        STBNPC_PartyManager_Init()
    end

    if STBNPC_TotemManager_Init then
        STBNPC_TotemManager_Init()
    end

    if STBNPC_AIController_Init then
        STBNPC_AIController_Init()
    end

    print("[STBNPC] System Ready.")
end

-- =========================================================
-- REGISTRAR NPC NO SISTEMA
-- =========================================================
-- Cada NPC controlado pelo mod deve ser registrado aqui
function STBNPC_RegisterNPC(npc)

    if npc == nil then return end

    -- evita duplicação
    if STBNPC.NPCs[npc] then return end

    STBNPC.NPCs[npc] = {
        entity = npc,
        lastUpdate = 0,
        state = "IDLE"
    }

    print("[STBNPC] NPC registered.")
end

-- =========================================================
-- ATUALIZAÇÃO PRINCIPAL (LOOP LEVE)
-- =========================================================
-- Esse loop roda com intervalo para evitar lag
function STBNPC_Update()

    local gameTime = getGameTime():getWorldAgeHours()

    -- controla frequência de execução
    if (gameTime - STBNPC.Config.lastUpdateTick) < STBNPC.Config.updateInterval then
        return
    end

    STBNPC.Config.lastUpdateTick = gameTime

    -- percorre NPCs registrados
    for _, data in pairs(STBNPC.NPCs) do

        local npc = data.entity

        if npc ~= nil then

            -- chama IA principal (será expandida depois)
            if STBNPC_AIController_Update then
                STBNPC_AIController_Update(npc)
            end

            -- chama lógica de totem (base)
            if STBNPC_TotemManager_Update then
                STBNPC_TotemManager_Update(npc)
            end

        end
    end
end

-- =========================================================
-- HOOK NO JOGO (EVENTO PRINCIPAL)
-- =========================================================
-- Esse evento roda automaticamente no Zomboid
Events.OnTick.Add(function()

    -- garante que sistema foi inicializado
    if not STBNPC._initialized then
        STBNPC_Init()
        STBNPC._initialized = true
    end

    -- loop leve principal
    STBNPC_Update()

end)

-- =========================================================
-- UTILIDADE: DEBUG
-- =========================================================
function STBNPC_DebugPrint(msg)
    print("[STBNPC DEBUG] " .. tostring(msg))
end

-- =========================================================
-- FIM DO CORE
-- =========================================================