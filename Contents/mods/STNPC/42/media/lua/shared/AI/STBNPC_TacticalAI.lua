-- =========================================================
-- STBNPC TACTICAL AI
-- STATIC WAVE
-- Controle de comportamento de esquadrão em combate
-- =========================================================

STBNPC_TacticalAI = STBNPC_TacticalAI or {}

-- update global leve
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    for _, npc in ipairs(squad) do
        if npc then
            STBNPC_TacticalAI_Process(npc)
        end
    end
end)

function STBNPC_TacticalAI_Process(npc)

    if npc:isDead() then return end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    local mode = data.STBNPC.commandMode or "FOLLOW"

    local enemy = npc.LastEnemeySeen
    local danger = npc:getDangerSeenCount() or 0
    local health = npc:getHealth()

    -- =====================================================
    -- PRIORIDADE MÁXIMA: SOBREVIVÊNCIA
    -- =====================================================
    if health < 0.3 then
        STBNPC_TacticalAI_Retreat(npc)
        return
    end

    -- =====================================================
    -- SE TEM INIMIGO
    -- =====================================================
    if enemy ~= nil and danger > 0 then

        STBNPC_TacticalAI_Combat(npc, enemy, mode)
        return
    end

    -- =====================================================
    -- FORA DE COMBATE
    -- =====================================================
    STBNPC_TacticalAI_NonCombat(npc, mode)
end

function STBNPC_TacticalAI_Combat(npc, enemy, mode)

    local player = getSpecificPlayer(0)
    local distToEnemy = npc:DistTo(enemy)
    local distToPlayer = npc:DistTo(player)

    -- =====================================================
    -- FOLLOW MODE
    -- =====================================================
    if mode == "FOLLOW" then

        if distToEnemy < 3 then
            npc:getTaskManager():AddToTop(FleeTask:new(npc))
        else
            npc:getTaskManager():AddToTop(PursueTask:new(npc, enemy))
        end
    end

    -- =====================================================
    -- GUARD MODE (DEFESA INTELIGENTE)
    -- =====================================================
    if mode == "GUARD" then

        if distToEnemy < 5 then
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        else
            npc:getTaskManager():AddToTop(PursueTask:new(npc, enemy))
        end
    end

    -- =====================================================
    -- HOLD POSITION (DEFESA ESTÁTICA)
    -- =====================================================
    if mode == "HOLD" then

        if distToEnemy < 2 then
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        else
            -- não persegue
            npc:getTaskManager():AddToTop(WanderTask:new(npc))
        end
    end

    -- =====================================================
    -- PATROL MODE
    -- =====================================================
    if mode == "PATROL" then

        if distToEnemy < 6 then
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        else
            npc:getTaskManager():AddToTop(WanderTask:new(npc))
        end
    end
end


function STBNPC_TacticalAI_Retreat(npc)

    npc:Say("I'm falling back!")

    npc:getTaskManager():AddToTop(FleeTask:new(npc))
end


function STBNPC_TacticalAI_NonCombat(npc, mode)

    local player = getSpecificPlayer(0)

    if mode == "FOLLOW" then
        npc:getTaskManager():AddToTop(FollowTask:new(npc, player))
    end

    if mode == "GUARD" then
        npc:getTaskManager():AddToTop(WanderTask:new(npc))
    end

    if mode == "PATROL" then
        npc:getTaskManager():AddToTop(FindBuildingTask:new(npc))
    end

    if mode == "HOLD" then
        -- fica parado / idle
    end

    if mode == "STEALTH" then

    -- andar lento + evitar combate
    if enemy ~= nil then
        npc:getTaskManager():AddToTop(FleeTask:new(npc))
    else
        npc:getTaskManager():AddToTop(WanderTask:new(npc))
    end
    end
end