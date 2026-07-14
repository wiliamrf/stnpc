-- =========================================================
-- STBNPC TOTEM SYSTEM
-- STATIC WAVE
-- Simulação de vida + gerenciamento de base
-- =========================================================

STBNPC_TotemSystem = STBNPC_TotemSystem or {}

-- =========================================================
-- CONFIGURAÇÕES
-- =========================================================
STBNPC_TotemSystem.range = 25

STBNPC_TotemSystem.workCycle = {
    guardMorning = {start = 6, finish = 12},
    guardAfternoon = {start = 12, finish = 18},
    restNight = {start = 18, finish = 6}
}

-- controle de NPCs ligados ao totem
STBNPC_TotemSystem.members = STBNPC_TotemSystem.members or {}


function STBNPC_Totem_AddNPC(npc)

    if not npc then return end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    data.STBNPC.inTotem = true
    data.STBNPC.fatigue = data.STBNPC.fatigue or 0
    data.STBNPC.hunger = data.STBNPC.hunger or 0

    table.insert(STBNPC_TotemSystem.members, npc)

    npc:Say("Assigned to Totem Base")
end

function STBNPC_Totem_Update()

    local hour = getGameTime():getHour()

    for _, npc in ipairs(STBNPC_TotemSystem.members) do

        if npc and not npc:isDead() then

            local data = npc:getModData().STBNPC

            -- =================================================
            -- FATIGA AUMENTA COM O TEMPO
            -- =================================================
            data.fatigue = (data.fatigue or 0) + 0.01

            -- =================================================
            -- FOME AUMENTA
            -- =================================================
            data.hunger = (data.hunger or 0) + 0.005

            -- =================================================
            -- DECISÃO DE ROTINA
            -- =================================================
            STBNPC_Totem_ExecuteRoutine(npc, hour, data)
        end
    end
end

function STBNPC_Totem_ExecuteRoutine(npc, hour, data)

    -- =====================================================
    -- 🛌 DESCANSO FORÇADO
    -- =====================================================
    if data.fatigue > 80 then
        npc:getTaskManager():AddToTop(SleepTask:new(npc))
        return
    end

    -- =====================================================
    -- 🍗 FOME CRÍTICA
    -- =====================================================
    if data.hunger > 70 then
        npc:getTaskManager():AddToTop(EatTask:new(npc))
        return
    end

    -- =====================================================
    -- 🛡️ TURNOS DE GUARDA
    -- =====================================================

    if hour >= 6 and hour < 12 then
        STBNPC_Totem_AssignTask(npc, "GUARD_MORNING")
    elseif hour >= 12 and hour < 18 then
        STBNPC_Totem_AssignTask(npc, "GUARD_AFTERNOON")
    else
        STBNPC_Totem_AssignTask(npc, "REST")
    end
end

function STBNPC_Totem_AssignTask(npc, task)

    local data = npc:getModData().STBNPC

    -- =====================================================
    -- GUARDA
    -- =====================================================
    if task == "GUARD_MORNING" or task == "GUARD_AFTERNOON" then

        npc:getTaskManager():AddToTop(WanderTask:new(npc))

        -- patrulha leve
        data.state = "GUARDING"
    end

    -- =====================================================
    -- DESCANSO
    -- =====================================================
    if task == "REST" then

        npc:getTaskManager():AddToTop(SleepTask:new(npc))
        data.state = "RESTING"
    end
end

Events.OnTick.Add(function()

    STBNPC_Totem_Update()
end)