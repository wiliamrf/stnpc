BanditIntegration = BanditIntegration or {}
STBNPC_Integration = STBNPC_Integration or {}

-- =====================================================
-- 🧠 BRAIN CORE SAFE LAYER
-- =====================================================
function STBNPC_Integration.GetBrain(npc)
    if not npc then return nil end
    return BanditBrain.Get(npc)
end

function STBNPC_Integration.SaveBrain(npc, brain)
    if not npc or not brain then return end
    BanditBrain.Update(npc, brain)
end

function STBNPC_Integration.EnsureBrain(npc)
    local brain = BanditBrain.Get(npc)
    if not brain then return nil end

    if not brain.tasks then brain.tasks = {} end
    if brain.combatState == nil then brain.combatState = "IDLE" end

    return brain
end

-- =====================================================
-- 🎯 TASK LAYER (UNIFIED COMMAND SYSTEM)
-- =====================================================
function STBNPC_Integration.PushTask(npc, action, data)
    local brain = STBNPC_Integration.EnsureBrain(npc)
    if not brain then return end

    table.insert(brain.tasks, {
        action = action,
        data = data or {},
        source = "STBNPC",
        time = getGameTime():getWorldAgeHours()
    })

    BanditBrain.Update(npc, brain)
end

function STBNPC_Integration.ReplaceTask(npc, action, data)
    local brain = STBNPC_Integration.EnsureBrain(npc)
    if not brain then return end

    brain.tasks = {}

    table.insert(brain.tasks, {
        action = action,
        data = data or {},
        source = "STBNPC_REPLACE",
        time = getGameTime():getWorldAgeHours()
    })

    BanditBrain.Update(npc, brain)
end

function STBNPC_Integration.ClearTasks(npc)
    local brain = STBNPC_Integration.EnsureBrain(npc)
    if not brain then return end

    brain.tasks = {}
    BanditBrain.Update(npc, brain)
end

function STBNPC_Integration.HasTasks(npc)
    local brain = STBNPC_Integration.GetBrain(npc)
    if not brain then return false end
    return BanditBrain.HasTask(brain)
end

-- =====================================================
-- 🔊 SPEECH SYSTEM (TRANSLATION REQUIRED)
-- =====================================================
function STBNPC_Integration.Say(npc, key)
    if not npc then return end

    local text = STBNPC_T(key)
    if not text then return end

    Bandit.Say(npc, text, false)
end

function STBNPC_Integration.SayForce(npc, key)
    if not npc then return end

    local text = STBNPC_T(key)
    if not text then return end

    Bandit.Say(npc, text, true)
end

-- =====================================================
-- ⚔️ COMBAT LAYER (COMBAT 3.0 READY)
-- =====================================================
function STBNPC_Integration.SetCombatState(npc, state)
    local brain = STBNPC_Integration.EnsureBrain(npc)
    if not brain then return end

    brain.combatState = state
    BanditBrain.Update(npc, brain)
end

function STBNPC_Integration.GetCombatState(npc)
    local brain = STBNPC_Integration.GetBrain(npc)
    if not brain then return "IDLE" end
    return brain.combatState or "IDLE"
end

-- =====================================================
-- 👥 SQUAD LAYER (SYNC SYSTEM)
-- =====================================================
function STBNPC_Integration.SyncSquad(squad)
    if not squad then return end

    for _, npc in ipairs(squad) do
        local brain = STBNPC_Integration.GetBrain(npc)
        if brain then
            BanditBrain.Update(npc, brain)
        end
    end
end

function STBNPC_Integration.BroadcastTask(squad, action, data)
    if not squad then return end

    for _, npc in ipairs(squad) do
        STBNPC_Integration.PushTask(npc, action, data)
    end
end

-- =====================================================
-- 📊 AI STATE (DECISION ENGINE INPUT)
-- =====================================================
function STBNPC_Integration.GetState(npc)
    local brain = STBNPC_Integration.GetBrain(npc)
    if not brain then return nil end

    return {
        hasTask = BanditBrain.HasTask(brain),
        hasMoveTask = BanditBrain.HasMoveTask(brain),
        hasActionTask = BanditBrain.HasActionTask(brain),
        isOutOfAmmo = BanditBrain.IsOutOfAmmo(brain),
        isBareHands = BanditBrain.IsBareHands(brain),
        hostile = brain.hostile or false,
        endurance = brain.endurance or 1.0,
        infection = brain.infection or 0,
        combatState = brain.combatState or "IDLE",
        tasksCount = brain.tasks and #brain.tasks or 0
    }
end

-- =====================================================
-- 🧭 HIGH LEVEL COMMANDS (TASKSYSTEM 2.0 READY)
-- =====================================================
function STBNPC_Integration.Command(npc, cmd, data)
    if cmd == "FARM" then
        STBNPC_Integration.PushTask(npc, "FARM", data)

    elseif cmd == "GATHER" then
        STBNPC_Integration.PushTask(npc, "GATHER", data)

    elseif cmd == "CLEAN" then
        STBNPC_Integration.PushTask(npc, "CLEAN", data)

    elseif cmd == "IDLE" then
        STBNPC_Integration.PushTask(npc, "IDLE", data)

    elseif cmd == "ATTACK" then
        STBNPC_Integration.PushTask(npc, "ATTACK", data)

    elseif cmd == "DEFEND" then
        STBNPC_Integration.PushTask(npc, "DEFEND", data)
    end
end