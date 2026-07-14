-- =========================================================
-- STBNPC ROLE SYSTEM
-- STATIC WAVE
-- Define comportamento individual dentro da squad
-- =========================================================

STBNPC_RoleSystem = STBNPC_RoleSystem or {}


-- =========================================================
-- DEFINE ROLE DO NPC
-- =========================================================
function STBNPC_Role_Set(npc, role)

    if not npc then return end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    data.STBNPC.role = role

    npc:Say("Role: " .. role)
end


-- =========================================================
-- PEGA ROLE DO NPC
-- =========================================================
function STBNPC_Role_Get(npc)

    if not npc then return "ASSAULT" end

    local data = npc:getModData()
    if data.STBNPC and data.STBNPC.role then
        return data.STBNPC.role
    end

    return "ASSAULT"
end


-- =========================================================
-- AUTO ASSIGN (IMPORTANTE PARA DEBUG E SPAWN FUTURO)
-- =========================================================
function STBNPC_Role_AutoAssign(npc, index)

    -- distribuição básica inteligente
    -- 0 = líder/primeiro NPC

    if index == 0 then
        STBNPC_Role_Set(npc, "GUARD")   -- líder protege player
    elseif index == 1 then
        STBNPC_Role_Set(npc, "ASSAULT")
    else
        STBNPC_Role_Set(npc, "SUPPORT")
    end
end