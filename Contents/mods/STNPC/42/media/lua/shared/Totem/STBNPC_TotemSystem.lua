-- =========================================================
-- STBNPC TOTEM SYSTEM
-- STATIC WAVE
-- =========================================================
-- Responsável por:
-- 1. Criar base (Totem)
-- 2. Gerenciar até 5 NPCs por base
-- 3. Definir roles (GUARD / WORKER)
-- 4. Vincular cama e área da base
-- 5. Integrar com AIController
-- =========================================================

STBNPC_TotemSystem = STBNPC_TotemSystem or {}

-- =========================================================
-- CONFIGURAÇÃO
-- =========================================================
STBNPC_TotemSystem.config = {
    maxNPC = 5,
    radius = 25
}

-- lista de todos os totems ativos
STBNPC_TotemSystem.totems = {}

-- =========================================================
-- CRIAR TOTEM
-- =========================================================
function STBNPC_TotemSystem_Create(x, y, z, owner)

    local totem = {
        id = tostring(x .. "_" .. y .. "_" .. z),

        x = x,
        y = y,
        z = z,

        owner = owner,

        npcs = {},

        radius = STBNPC_TotemSystem.config.radius
    }

    table.insert(STBNPC_TotemSystem.totems, totem)

    STBNPC_Log("STBNPC_LOG_TOTEM_CREATED")

    return totem
end

-- =========================================================
-- ADICIONAR NPC NO TOTEM
-- =========================================================
function STBNPC_TotemSystem_AddNPC(totem, npc, role)

    if totem == nil or npc == nil then return end

    if #totem.npcs >= STBNPC_TotemSystem.config.maxNPC then
        STBNPC_Log("STBNPC_LOG_TOTEM_FULL")
        return
    end

    npc:getModData().STBNPC = npc:getModData().STBNPC or {}

    npc:getModData().STBNPC.totemID = totem.id
    npc:getModData().STBNPC.role = role or "WORKER"

    -- posição base
    npc:getModData().STBNPC.homeX = totem.x
    npc:getModData().STBNPC.homeY = totem.y
    npc:getModData().STBNPC.homeZ = totem.z

    -- raio de defesa
    npc:getModData().STBNPC.guardRadius = totem.radius

    table.insert(totem.npcs, npc)

    STBNPC_Log("STBNPC_LOG_NPC_ASSIGNED_TOTEM")
end

-- =========================================================
-- REMOVER NPC DO TOTEM
-- =========================================================
function STBNPC_TotemSystem_RemoveNPC(totem, npc)

    if totem == nil or npc == nil then return end

    for i, v in ipairs(totem.npcs) do
        if v == npc then
            table.remove(totem.npcs, i)

            if npc:getModData().STBNPC then
                npc:getModData().STBNPC.totemID = nil
                npc:getModData().STBNPC.role = nil
            end

            STBNPC_Log("STBNPC_LOG_NPC_REMOVED_TOTEM")
            return
        end
    end
end

-- =========================================================
-- PEGAR TOTEM DO NPC
-- =========================================================
function STBNPC_TotemSystem_GetNPCToTem(npc)

    if npc == nil then return nil end

    local id = npc:getModData().STBNPC and npc:getModData().STBNPC.totemID

    if id == nil then return nil end

    for _, totem in ipairs(STBNPC_TotemSystem.totems) do
        if totem.id == id then
            return totem
        end
    end

    return nil
end

-- =========================================================
-- UPDATE GLOBAL (RODAR NO GAME LOOP)
-- =========================================================
function STBNPC_TotemSystem_Update()

    for _, totem in ipairs(STBNPC_TotemSystem.totems) do

        if totem ~= nil then
            STBNPC_TotemSystem_UpdateNPCs(totem)
        end
    end
end

-- =========================================================
-- UPDATE NPCs DO TOTEM
-- =========================================================
function STBNPC_TotemSystem_UpdateNPCs(totem)

    for i = #totem.npcs, 1, -1 do

        local npc = totem.npcs[i]

        -- REMOVE NPC MORTO
        if npc == nil or npc:isDead() then
            table.remove(totem.npcs, i)
            STBNPC_Log("STBNPC_LOG_NPC_DEAD_REMOVED")
        else

            -- chama AI central
            if STBNPC_AIController_Update then
                STBNPC_AIController_Update(npc)
            end
        end
    end
end