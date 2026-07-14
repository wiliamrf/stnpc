-- =========================================================
-- STBNPC PARTY SYSTEM
-- STATIC WAVE
-- =========================================================
-- Responsável por:
-- 1. Gerenciar party do jogador (máx 3 NPCs)
-- 2. Controlar follow
-- 3. Evitar conflito de IA pesada
-- 4. Preparar NPCs para combate em grupo
-- =========================================================

STBNPC_PartyManager = STBNPC_PartyManager or {}

-- =========================================================
-- CONFIGURAÇÃO DA PARTY
-- =========================================================
STBNPC_PartyManager.config = {
    maxMembers = 3,
    followDistance = 3,      -- distância ideal do player
    updateInterval = 5       -- ticks leves (performance)
}

-- lista de membros da party
STBNPC_PartyManager.members = {}

-- controle de update leve
STBNPC_PartyManager.lastUpdate = 0

-- =========================================================
-- INICIALIZAÇÃO
-- =========================================================
function STBNPC_PartyManager_Init()
    print("[STBNPC] Party System Initialized")
end

-- =========================================================
-- ADICIONAR NPC NA PARTY
-- =========================================================
function STBNPC_PartyManager_Add(npc)

    if npc == nil then return end

    -- evita duplicação
    if STBNPC_PartyManager_IsMember(npc) then return end

    -- limite da party
    if #STBNPC_PartyManager.members >= STBNPC_PartyManager.config.maxMembers then
        print("[STBNPC] Party full!")
        return
    end

    -- marca NPC como membro da party
    npc:getModData().STBNPC = npc:getModData().STBNPC or {}
    npc:getModData().STBNPC.isPartyMember = true

    table.insert(STBNPC_PartyManager.members, npc)

    print("[STBNPC] NPC added to party")
end

-- =========================================================
-- REMOVER NPC DA PARTY
-- =========================================================
function STBNPC_PartyManager_Remove(npc)

    for i, member in ipairs(STBNPC_PartyManager.members) do
        if member == npc then

            -- remove flag
            npc:getModData().STBNPC.isPartyMember = false

            table.remove(STBNPC_PartyManager.members, i)

            print("[STBNPC] NPC removed from party")
            return
        end
    end
end

-- =========================================================
-- VERIFICAR SE NPC É DA PARTY
-- =========================================================
function STBNPC_PartyManager_IsMember(npc)

    for _, member in ipairs(STBNPC_PartyManager.members) do
        if member == npc then
            return true
        end
    end

    return false
end

-- =========================================================
-- VERIFICA SE NPC ESTÁ MORTO
-- =========================================================
function STBNPC_PartyManager_IsDead(npc)

    if npc == nil then return true end

    -- Zomboid: check padrão de morte
    if npc:isDead() then
        return true
    end

    return false
end

-- =========================================================
-- FUNÇÃO PRINCIPAL DE UPDATE (FOLLOW LOGIC)
-- =========================================================
function STBNPC_PartyManager_Update()

    local player = getSpecificPlayer(0)
    if player == nil then return end

    local gameTime = getGameTime():getWorldAgeHours()

    -- controle de performance
    if (gameTime - STBNPC_PartyManager.lastUpdate) < STBNPC_PartyManager.config.updateInterval then
        return
    end

    STBNPC_PartyManager.lastUpdate = gameTime

     for i = #STBNPC_PartyManager.members, 1, -1 do

        local npc = STBNPC_PartyManager.members[i]

        -- =========================================
        -- REMOVE NPC SE MORREU
        -- =========================================
        if STBNPC_PartyManager_IsDead(npc) then

            if npc and npc.getModData then
                npc:getModData().STBNPC.isPartyMember = false
            end

            table.remove(STBNPC_PartyManager.members, i)

            STBNPC_Log("STBNPC_LOG_PARTY_ADDED")

        else
            -- comportamento normal
            STBNPC_PartyManager_FollowPlayer(npc, player)
        end
    end
end

-- =========================================================
-- LÓGICA DE FOLLOW
-- =========================================================
function STBNPC_PartyManager_FollowPlayer(npc, player)

    -- segurança
    if npc == nil or player == nil then return end

    -- calcula distância simples
    local dist = npc:DistTo(player)

    -- se estiver longe demais → seguir
    if dist > STBNPC_PartyManager.config.followDistance then

        -- manda NPC seguir o player
        -- aqui é onde conectamos com IA do Bandits depois
        if npc.getPathfindManager then
            npc:getPathfindManager():setRunning(true)
        end

        npc:walkTo(player:getX(), player:getY(), player:getZ())

        -- debug leve
        -- print("[STBNPC] NPC following player")

    else
        -- idle leve quando perto
        if npc.setRunning then
            npc:setRunning(false)
        end
    end
end

-- =========================================================
-- CLEAR PARTY
-- =========================================================
function STBNPC_PartyManager_Clear()

    for _, npc in ipairs(STBNPC_PartyManager.members) do
        if npc then
            npc:getModData().STBNPC.isPartyMember = false
        end
    end

    STBNPC_PartyManager.members = {}

    print("[STBNPC] Party cleared")
end


-- =========================================================
-- DEBUG STATUS
-- =========================================================
function STBNPC_PartyManager_Debug()

    print("[STBNPC] Party size: " .. tostring(#STBNPC_PartyManager.members))

    for i, npc in ipairs(STBNPC_PartyManager.members) do
        print("[STBNPC] Member " .. i .. " -> " .. tostring(npc))
    end
end