-- =========================================================
-- STBNPC SQUAD SYSTEM
-- STATIC WAVE
-- Core do sistema de esquadrão (Party AI Controller)
-- =========================================================

STBNPC_SquadSystem = STBNPC_SquadSystem or {}

-- =========================================================
-- CONFIGURAÇÕES
-- =========================================================
STBNPC_SquadSystem.maxSquadSize = 3

-- lista principal da squad
STBNPC_SquadSystem.members = STBNPC_SquadSystem.members or {}

-- cache interno de roles (opcional futuro)
STBNPC_SquadSystem.roles = STBNPC_SquadSystem.roles or {}


-- =========================================================
-- ADICIONAR NPC NA SQUAD
-- =========================================================
function STBNPC_SquadSystem_Add(npc)

    if not npc then return end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    -- já está na squad
    if data.STBNPC.inSquad then return end

    -- limite de membros
    if #STBNPC_SquadSystem.members >= STBNPC_SquadSystem.maxSquadSize then
        return
    end

    data.STBNPC.inSquad = true
    data.STBNPC.commandMode = data.STBNPC.commandMode or "FOLLOW"

    -- =====================================================
    -- AUTO ROLE ASSIGN
    -- =====================================================
    local index = #STBNPC_SquadSystem.members

    if index == 0 then
        data.STBNPC.role = "GUARD"
    elseif index == 1 then
        data.STBNPC.role = "ASSAULT"
    else
        data.STBNPC.role = "SUPPORT"
    end

    table.insert(STBNPC_SquadSystem.members, npc)

    npc:Say("Joined Squad [" .. data.STBNPC.role .. "]")

    STBNPC_Log("STBNPC_LOG_SQUAD_ADD")
end


-- =========================================================
-- REMOVER NPC DA SQUAD
-- =========================================================
function STBNPC_SquadSystem_Remove(npc)

    if not npc then return end

    local data = npc:getModData()

    if data.STBNPC then
        data.STBNPC.inSquad = false
        data.STBNPC.role = nil
        data.STBNPC.commandMode = nil
    end

    for i = #STBNPC_SquadSystem.members, 1, -1 do
        if STBNPC_SquadSystem.members[i] == npc then
            table.remove(STBNPC_SquadSystem.members, i)
        end
    end

    STBNPC_Log("STBNPC_LOG_SQUAD_REMOVE")
end


-- =========================================================
-- LIMPEZA AUTOMÁTICA
-- =========================================================
function STBNPC_SquadSystem_Clean()

    for i = #STBNPC_SquadSystem.members, 1, -1 do

        local npc = STBNPC_SquadSystem.members[i]

        if npc == nil or npc:isDead() then
            table.remove(STBNPC_SquadSystem.members, i)
        end
    end
end


-- =========================================================
-- SETAR MODO GLOBAL DO ESQUADRÃO
-- =========================================================
function STBNPC_SquadSystem_SetMode(mode)

    for _, npc in ipairs(STBNPC_SquadSystem.members) do

        local data = npc:getModData()
        data.STBNPC = data.STBNPC or {}

        data.STBNPC.commandMode = mode

        npc:Say("Mode: " .. tostring(mode))
    end

    STBNPC_Log("STBNPC_LOG_SQUAD_MODE_" .. tostring(mode))
end


-- =========================================================
-- COMANDOS GLOBAIS
-- =========================================================

function STBNPC_Squad_Follow()
    STBNPC_SquadSystem_SetMode("FOLLOW")
end

function STBNPC_Squad_Hold()
    STBNPC_SquadSystem_SetMode("HOLD")
end

function STBNPC_Squad_Patrol()
    STBNPC_SquadSystem_SetMode("PATROL")
end

function STBNPC_Squad_Guard()
    STBNPC_SquadSystem_SetMode("GUARD")
end


-- =========================================================
-- ADICIONAR NPC SELECIONADO (TARGET SYSTEM)
-- =========================================================
function STBNPC_Squad_AddTargetedNPC(player)

    local npc = STBNPC_GetTargetNPC(player)

    if not npc then
        STBNPC_Log("STBNPC_LOG_SQUAD_NO_TARGET")
        return
    end

    STBNPC_SquadSystem_Add(npc)
end


-- =========================================================
-- HELPERS (ROLE GET)
-- =========================================================
function STBNPC_Squad_GetRole(npc)

    if not npc then return "ASSAULT" end

    local data = npc:getModData()

    if data.STBNPC and data.STBNPC.role then
        return data.STBNPC.role
    end

    return "ASSAULT"
end


-- =========================================================
-- HELPERS (COMMAND MODE GET)
-- =========================================================
function STBNPC_Squad_GetMode(npc)

    if not npc then return "FOLLOW" end

    local data = npc:getModData()

    if data.STBNPC and data.STBNPC.commandMode then
        return data.STBNPC.commandMode
    end

    return "FOLLOW"
end


-- =========================================================
-- LIMPEZA PERIÓDICA
-- =========================================================
Events.OnTick.Add(function()

    STBNPC_SquadSystem_Clean()
end)