STBNPC_Test = {}

function STBNPC_Test.ValidateNPC(npc)
    if not npc then
        print("[STBNPC_TEST] ❌ NPC is nil")
        return false
    end

    local brain = BanditBrain.Get(npc)

    if not brain then
        print("[STBNPC_TEST] ❌ Brain missing")
        return false
    end

    if not brain.tasks then
        print("[STBNPC_TEST] ⚠ tasks missing, fixing...")
        brain.tasks = {}
    end

    if #brain.tasks > 20 then
        print("[STBNPC_TEST] ⚠ too many tasks: " .. #brain.tasks)
    end

    if brain.combatState == nil then
        print("[STBNPC_TEST] ⚠ combatState missing, fixing...")
        brain.combatState = "IDLE"
    end

    print("[STBNPC_TEST] ✅ NPC OK")
    return true
end

function STBNPC_Test.ValidateAll(list)
    if not list then return end

    for i = 1, #list do
        STBNPC_Test.ValidateNPC(list[i])
    end
end

function STBNPC_Test.PrintBrain(npc)
    local brain = BanditBrain.Get(npc)

    if not brain then
        print("[STBNPC_TEST] No brain")
        return
    end

    print("==== BRAIN DEBUG ====")
    print("Tasks:", brain.tasks and #brain.tasks or 0)
    print("Combat:", brain.combatState)
    print("Hostile:", brain.hostile)
    print("Endurance:", brain.endurance)
    print("=====================")
end