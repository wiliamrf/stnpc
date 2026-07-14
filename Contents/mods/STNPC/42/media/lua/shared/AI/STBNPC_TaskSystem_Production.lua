-- =========================================================
-- STBNPC TASK SYSTEM PRODUCTION 2.0
-- STATIC WAVE
-- Sistema de produção de base estilo RimWorld
-- =========================================================

STBNPC_BaseState = STBNPC_BaseState or {}

STBNPC_BaseState.foodStock = STBNPC_BaseState.foodStock or 0
STBNPC_BaseState.materialStock = STBNPC_BaseState.materialStock or 0
STBNPC_BaseState.cleanliness = STBNPC_BaseState.cleanliness or 50


-- =========================================================
-- CONTROLE DE PERFORMANCE (RATE LIMIT)
-- =========================================================
STBNPC_TaskSystem_Production = STBNPC_TaskSystem_Production or {}
STBNPC_TaskSystem_Production.tick = 0
STBNPC_TaskSystem_Production.rate = 20


-- =========================================================
-- LOOP GLOBAL
-- =========================================================
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    STBNPC_TaskSystem_Production.tick = STBNPC_TaskSystem_Production.tick + 1

    if STBNPC_TaskSystem_Production.tick < STBNPC_TaskSystem_Production.rate then
        return
    end

    STBNPC_TaskSystem_Production.tick = 0

    STBNPC_TaskSystem_Production_Update(squad)
end)


-- =========================================================
-- UPDATE PRINCIPAL
-- =========================================================
function STBNPC_TaskSystem_Production_Update(squad)

    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            STBNPC_TaskSystem_Production_Evaluate(npc)
        end
    end
end


-- =========================================================
-- AVALIAÇÃO DE NECESSIDADES DA BASE
-- =========================================================
function STBNPC_TaskSystem_Production_Evaluate(npc)

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}
    data = data.STBNPC

    -- evita spam de reatribuição
    if data.isWorking then return end


    -- =====================================================
    -- 🍗 COMIDA EM BAIXA
    -- =====================================================
    if STBNPC_BaseState.foodStock < 20 then
        return STBNPC_TaskSystem_Production_Assign(npc, "FARM")
    end


    -- =====================================================
    -- 🪵 MATERIAL EM BAIXA
    -- =====================================================
    if STBNPC_BaseState.materialStock < 15 then
        return STBNPC_TaskSystem_Production_Assign(npc, "GATHER")
    end


    -- =====================================================
    -- 🧹 BASE SUJA
    -- =====================================================
    if STBNPC_BaseState.cleanliness < 40 then
        return STBNPC_TaskSystem_Production_Assign(npc, "CLEAN")
    end


    -- =====================================================
    -- 🧍 IDLE
    -- =====================================================
    return STBNPC_TaskSystem_Production_Assign(npc, "IDLE")
end


-- =========================================================
-- ATRIBUIÇÃO DE TAREFA
-- =========================================================
function STBNPC_TaskSystem_Production_Assign(npc, task)

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}
    data = data.STBNPC

    -- evita repetir mesma tarefa
    if data.lastTask == task then return end

    data.lastTask = task
    data.isWorking = true

    STBNPC_TaskSystem_Production_Execute(npc, task)
end


-- =========================================================
-- EXECUÇÃO DAS TAREFAS
-- =========================================================
function STBNPC_TaskSystem_Production_Execute(npc, task)

    local tm = npc:getTaskManager()
    local data = npc:getModData().STBNPC

    -- =====================================================
    -- 🌾 FARM
    -- =====================================================
    if task == "FARM" then

        npc:Say(STBNPC_T("STBNPC_FARMING"))

        tm:AddToTop(WanderTask:new(npc))

        STBNPC_BaseState.foodStock = STBNPC_BaseState.foodStock + 1
        STBNPC_BaseState.foodStock = STBNPC_BaseState.foodStock - 0.2
    end


    -- =====================================================
    -- 🪵 GATHER
    -- =====================================================
    if task == "GATHER" then

        npc:Say(STBNPC_T("STBNPC_GATHERING"))

        tm:AddToTop(WanderTask:new(npc))

        STBNPC_BaseState.materialStock = STBNPC_BaseState.materialStock + 1
        STBNPC_BaseState.materialStock = STBNPC_BaseState.materialStock - 0.15
    end


    -- =====================================================
    -- 🧹 CLEAN
    -- =====================================================
    if task == "CLEAN" then

        npc:Say(STBNPC_T("STBNPC_CLEANING"))

        tm:AddToTop(WanderTask:new(npc))

        STBNPC_BaseState.cleanliness = STBNPC_BaseState.cleanliness + 2
        STBNPC_BaseState.cleanliness = STBNPC_BaseState.cleanliness - 0.1
    end


    -- =====================================================
    -- 🧍 IDLE
    -- =====================================================
    if task == "IDLE" then

        if math.random(1, 100) < 10 then
            npc:Say(STBNPC_T("STBNPC_IDLE"))
        end

        tm:AddToTop(IdleTask:new(npc))
    end


    -- libera o NPC para nova decisão depois de um tempo
    data.isWorking = false
end