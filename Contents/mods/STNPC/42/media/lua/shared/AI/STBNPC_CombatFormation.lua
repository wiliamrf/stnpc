-- =========================================================
-- STBNPC COMBAT FORMATION SYSTEM 2.0
-- STATIC WAVE
-- Formação dinâmica durante combate
-- =========================================================

STBNPC_CombatFormation = STBNPC_CombatFormation or {}

-- distância base entre NPCs
STBNPC_CombatFormation.spacing = 2.2

-- cooldown leve
STBNPC_CombatFormation.tick = 0
STBNPC_CombatFormation.rate = 8


-- =========================================================
-- LOOP PRINCIPAL
-- =========================================================
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    local enemy = STBNPC_Combat and STBNPC_Combat.currentTarget
    if not enemy then return end

    STBNPC_CombatFormation.tick = STBNPC_CombatFormation.tick + 1

    if STBNPC_CombatFormation.tick < STBNPC_CombatFormation.rate then
        return
    end

    STBNPC_CombatFormation.tick = 0

    STBNPC_CombatFormation_Update(squad, enemy)
end)


-- =========================================================
-- UPDATE DA FORMAÇÃO DE COMBATE
-- =========================================================
function STBNPC_CombatFormation_Update(squad, enemy)

    local ex = enemy:getX()
    local ey = enemy:getY()

    local index = 0
    local total = #squad

    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            local role = STBNPC_Squad_GetRole(npc)

            local tx, ty = STBNPC_CombatFormation_GetPosition(
                npc,
                role,
                index,
                total,
                ex,
                ey
            )

            STBNPC_CombatFormation_Move(npc, tx, ty)

            index = index + 1
        end
    end
end

function STBNPC_CombatFormation_GetPosition(npc, role, index, total, ex, ey)

    local spacing = STBNPC_CombatFormation.spacing

    -- =====================================================
    -- 🪖 ASSAULT (linha frontal do inimigo)
    -- =====================================================
    if role == "ASSAULT" then

        local x = ex + (index * 0.5)
        local y = ey - spacing

        return x, y
    end

    -- =====================================================
    -- 🧑‍⚕️ SUPPORT (linha traseira)
    -- =====================================================
    if role == "SUPPORT" then

        local x = ex - (index * 0.5)
        local y = ey + spacing * 2

        return x, y
    end

    -- =====================================================
    -- 🛡️ GUARD (protege jogador, não inimigo)
    -- =====================================================
    if role == "GUARD" then

        local player = getSpecificPlayer(0)

        local px = player:getX()
        local py = player:getY()

        return px + math.cos(index) * 2, py + math.sin(index) * 2
    end

    return ex, ey
end

function STBNPC_CombatFormation_Move(npc, x, y)

    if not npc then return end

    local dist = npc:DistToSquare(x, y)

    -- evita micro-spam de movimento
    if dist < 1.2 then return end

    npc:getTaskManager():AddToTop(GoToLocationTask:new(npc, x, y, 0))
end