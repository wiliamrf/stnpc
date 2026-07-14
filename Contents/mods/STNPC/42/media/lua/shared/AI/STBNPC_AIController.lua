-- =========================================================
-- STBNPC AI CONTROLLER
-- STATIC WAVE
-- =========================================================
-- Responsável por:
-- 1. Definir estado do NPC (FOLLOW / DEFEND / WORK / IDLE / COMBAT)
-- 2. Conectar Party + Totem + Bandits AI
-- 3. Evitar IA pesada constante
-- =========================================================

STBNPC_AIController = STBNPC_AIController or {}

-- =========================================================
-- TIPOS DE ESTADO DA IA
-- =========================================================
STBNPC_AIState = {
    FOLLOW = "FOLLOW",
    DEFEND = "DEFEND",
    WORK = "WORK",
    IDLE = "IDLE",
    COMBAT = "COMBAT"
}

-- =========================================================
-- INICIALIZAÇÃO
-- =========================================================
function STBNPC_AIController_Init()
    STBNPC_Log("STBNPC_LOG_INIT_AI")
end

-- =========================================================
-- FUNÇÃO PRINCIPAL DE UPDATE DA IA
-- =========================================================
function STBNPC_AIController_Update(npc)

    if npc == nil then return end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    -- =====================================================
    -- 1. DETECTA SE NPC É PARTY OU TOTEM
    -- =====================================================
    local isParty = data.STBNPC.isPartyMember == true
    local isWorker = data.STBNPC.isWorker == true
    local isGuard  = data.STBNPC.isGuard == true

    -- =====================================================
    -- 2. PRIORIDADE MÁXIMA: COMBATE
    -- =====================================================
    if STBNPC_AIController_HasThreat(npc) then
        STBNPC_AIController_SetState(npc, STBNPC_AIState.COMBAT)
        STBNPC_AIController_Combat(npc)
        return
    end

    -- =====================================================
    -- 3. PARTY (PLAYER MODE)
    -- =====================================================
    if isParty then
        STBNPC_AIController_SetState(npc, STBNPC_AIState.FOLLOW)
        STBNPC_AIController_Follow(npc)
        return
    end

    -- =====================================================
    -- 4. TOTEM - GUARD / WORK
    -- =====================================================
    if isGuard then
        STBNPC_AIController_SetState(npc, STBNPC_AIState.DEFEND)
        STBNPC_AIController_Defend(npc)
        return
    end

    if isWorker then
        STBNPC_AIController_SetState(npc, STBNPC_AIState.WORK)
        STBNPC_AIController_Work(npc)
        return
    end

    -- =====================================================
    -- 5. DEFAULT IDLE
    -- =====================================================
    STBNPC_AIController_SetState(npc, STBNPC_AIState.IDLE)
    STBNPC_AIController_Idle(npc)

end

-- =========================================================
-- DETECÇÃO DE PERIGO (ZOMBIE / BANDIT)
-- =========================================================
function STBNPC_AIController_HasThreat(npc)

    if npc == nil then return false end

    local enemy = npc.LastEnemeySeen

    if enemy ~= nil then
        return true
    end

    return false
end

-- =========================================================
-- COMBATE
-- =========================================================
function STBNPC_AIController_Combat(npc)

    local enemy = npc.LastEnemeySeen
    if enemy == nil then return end

    -- aqui entra integração futura com Bandits AI
    -- por enquanto usamos comportamento base do Zomboid

    if npc.getPathfindManager then
        npc:getPathfindManager():setRunning(true)
    end

    npc:walkTo(enemy:getX(), enemy:getY(), enemy:getZ())

    STBNPC_Log("STBNPC_LOG_STATE_COMBAT")
end

-- =========================================================
-- FOLLOW (PARTY MODE)
-- =========================================================
function STBNPC_AIController_Follow(npc)

    local player = getSpecificPlayer(0)
    if player == nil then return end

    local dist = npc:DistTo(player)

    if dist > 3 then
        npc:walkTo(player:getX(), player:getY(), player:getZ())
    end
end

-- =========================================================
-- DEFESA (TOTEM - GUARD)
-- =========================================================
function STBNPC_AIController_Defend(npc)

    local homeX = npc:getModData().STBNPC.homeX
    local homeY = npc:getModData().STBNPC.homeY

    if homeX == nil or homeY == nil then return end

    local dist = npc:getModData().STBNPC.guardRadius or 25

    -- se sair da área → volta
    if npc:DistToSquare(homeX, homeY) > dist then
        npc:walkTo(homeX, homeY, npc:getZ())
    end
end

-- =========================================================
-- TRABALHO (TOTEM - WORK)
-- =========================================================
function STBNPC_AIController_Work(npc)

    -- aqui depois vamos ligar tarefas reais:
    -- farm, loot, limpar corpo, etc

    STBNPC_Log("STBNPC_LOG_STATE_WORK")

    -- comportamento simples inicial
    if math.random(1, 100) < 5 then
        npc:Say("Working...")
    end
end

-- =========================================================
-- IDLE (DESCANSO)
-- =========================================================
function STBNPC_AIController_Idle(npc)

    -- reduz consumo de CPU e movimentação

    if math.random(1, 200) < 2 then
        npc:Say("...")
    end
end

-- =========================================================
-- SETAR ESTADO
-- =========================================================
function STBNPC_AIController_SetState(npc, state)

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    if data.STBNPC.state ~= state then
        data.STBNPC.state = state
    end
end