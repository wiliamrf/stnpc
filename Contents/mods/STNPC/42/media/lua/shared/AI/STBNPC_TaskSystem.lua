-- =========================================================
-- STBNPC TASK SYSTEM
-- STATIC WAVE
-- Sistema de vida e tarefas estilo RimWorld (base)
-- =========================================================

STBNPC_TaskSystem = STBNPC_TaskSystem or {}

-- cache leve (evita spam de decisão)
STBNPC_TaskSystem.tick = 0
STBNPC_TaskSystem.rate = 15


-- =========================================================
-- LOOP GLOBAL
-- =========================================================
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    STBNPC_TaskSystem.tick = STBNPC_TaskSystem.tick + 1

    if STBNPC_TaskSystem.tick < STBNPC_TaskSystem.rate then
        return
    end

    STBNPC_TaskSystem.tick = 0

    STBNPC_TaskSystem_Update(squad)
end)


-- =========================================================
-- UPDATE PRINCIPAL
-- =========================================================
function STBNPC_TaskSystem_Update(squad)

    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            STBNPC_TaskSystem_Evaluate(npc)
        end
    end
end

function STBNPC_TaskSystem_Evaluate(npc)

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    local hunger = data.STBNPC.hunger or 0
    local fatigue = data.STBNPC.fatigue or 0

    -- =====================================================
    -- 🍗 FOME (PRIORIDADE ALTA)
    -- =====================================================
    if hunger >= 60 then
        return STBNPC_TaskSystem_Assign(npc, "EAT", 100)
    end

    -- =====================================================
    -- 😴 CANSADO (PRIORIDADE ALTA)
    -- =====================================================
    if fatigue >= 70 then
        return STBNPC_TaskSystem_Assign(npc, "REST", 90)
    end

    -- =====================================================
    -- 🧹 LIMPEZA (PRIORIDADE BAIXA / ALEATÓRIA)
    -- =====================================================
    if math.random(1, 100) <= 20 then
        return STBNPC_TaskSystem_Assign(npc, "CLEAN", 30)
    end

    -- =====================================================
    -- 🧍 IDLE (PADRÃO)
    -- =====================================================
    return STBNPC_TaskSystem_Assign(npc, "IDLE", 10)
end

function STBNPC_TaskSystem_Assign(npc, task, priority)

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    -- evita sobrescrever tarefas mais importantes
    if data.STBNPC.priority and data.STBNPC.priority > priority then
        return
    end

    data.STBNPC.task = task
    data.STBNPC.priority = priority

    STBNPC_TaskSystem_Execute(npc, task)
end


function STBNPC_TaskSystem_Execute(npc, task)

    local tm = npc:getTaskManager()
    local data = npc:getModData().STBNPC

    -- =====================================================
    -- 🍗 EAT
    -- =====================================================
    if task == "EAT" then

        npc:Say(STBNPC_T("STBNPC_NEED_FOOD"))

        tm:AddToTop(EatTask:new(npc))
    end

    -- =====================================================
    -- 😴 REST
    -- =====================================================
    if task == "REST" then

        npc:Say(STBNPC_T("STBNPC_NEED_REST"))

        tm:AddToTop(SleepTask:new(npc))
    end

    -- =====================================================
    -- 🧹 CLEAN
    -- =====================================================
    if task == "CLEAN" then

        npc:Say(STBNPC_T("STBNPC_CLEANING"))

        tm:AddToTop(WanderTask:new(npc))
    end

    -- =====================================================
    -- 🧍 IDLE (SEM AÇÃO)
    -- =====================================================
    if task == "IDLE" then

        -- sem spam de fala
        if math.random(1, 100) < 5 then
            npc:Say(STBNPC_T("STBNPC_IDLE"))
        end

        tm:AddToTop(IdleTask:new(npc))
    end
end

function STBNPC_T(key)
    return getText(key) or key
end