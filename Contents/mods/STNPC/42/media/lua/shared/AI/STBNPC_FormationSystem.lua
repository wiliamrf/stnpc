-- =========================================================
-- STBNPC FORMATION SYSTEM
-- STATIC WAVE
-- Organização tática do esquadrão ao redor do player
-- =========================================================

STBNPC_FormationSystem = STBNPC_FormationSystem or {}

-- tipo de formação atual
STBNPC_FormationSystem.mode = "CIRCLE"

-- distância base entre NPCs
STBNPC_FormationSystem.spacing = 2.5


-- =========================================================
-- LOOP PRINCIPAL
-- =========================================================
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    STBNPC_FormationSystem_Update(player, squad)
end)


-- =========================================================
-- UPDATE DA FORMAÇÃO
-- =========================================================
function STBNPC_FormationSystem_Update(player, squad)

    local x = player:getX()
    local y = player:getY()

    local index = 0
    local total = #squad

    for i, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            local data = npc:getModData()
            data.STBNPC = data.STBNPC or {}

            local role = data.STBNPC.role or "ASSAULT"

            -- calcula posição desejada
            local tx, ty = STBNPC_FormationSystem_CalcPosition(player, role, index, total)

            -- move NPC para posição
            STBNPC_FormationSystem_MoveTo(npc, tx, ty)

            index = index + 1
        end
    end
end

function STBNPC_FormationSystem_CalcPosition(player, role, index, total)

    local px = player:getX()
    local py = player:getY()

    local spacing = STBNPC_FormationSystem.spacing

    -- =====================================================
    -- FORMAÇÃO CÍRCULO (default)
    -- =====================================================
    if STBNPC_FormationSystem.mode == "CIRCLE" then

        local angle = (index / math.max(total, 1)) * 360
        local rad = math.rad(angle)

        local x = px + math.cos(rad) * spacing * 2
        local y = py + math.sin(rad) * spacing * 2

        return x, y
    end

    -- =====================================================
    -- FORMAÇÃO LINHA (FRONTAL)
    -- =====================================================
    if STBNPC_FormationSystem.mode == "LINE" then

        local offset = (index - (total / 2)) * spacing

        local x = px + offset
        local y = py + 2

        return x, y
    end

    return px, py
end

function STBNPC_FormationSystem_MoveTo(npc, x, y)

    if not npc then return end

    local dist = npc:DistToSquare(x, y)

    -- evita spam de movimentação
    if dist < 1 then return end

    npc:getTaskManager():AddToTop(GoToLocationTask:new(npc, x, y, 0))
end