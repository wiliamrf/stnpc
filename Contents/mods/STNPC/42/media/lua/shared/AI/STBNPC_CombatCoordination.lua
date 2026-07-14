-- =========================================================
-- STBNPC COMBAT COORDINATION SYSTEM
-- STATIC WAVE
-- IA tática de combate em grupo (nível AAA)
-- =========================================================

STBNPC_Combat = STBNPC_Combat or {}

-- alvo global do esquadrão
STBNPC_Combat.currentTarget = nil

-- cooldown leve pra evitar spam de recalculo
STBNPC_Combat.lastUpdate = 0
STBNPC_Combat.updateRate = 10 -- ticks


-- =========================================================
-- LOOP PRINCIPAL
-- =========================================================
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    STBNPC_Combat_Update(player, squad)
end)


-- =========================================================
-- ATUALIZAÇÃO GLOBAL DO COMBATE
-- =========================================================
function STBNPC_Combat_Update(player, squad)

    STBNPC_Combat.lastUpdate = STBNPC_Combat.lastUpdate + 1

    if STBNPC_Combat.lastUpdate < STBNPC_Combat.updateRate then
        return
    end

    STBNPC_Combat.lastUpdate = 0

    local closestEnemy = nil
    local closestDist = 999

    -- =====================================================
    -- 1. ENCONTRA INIMIGO MAIS PRÓXIMO DO ESQUADRÃO
    -- =====================================================
    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            local enemy = npc.LastEnemeySeen

            if enemy then
                local dist = npc:DistTo(enemy)

                if dist < closestDist then
                    closestDist = dist
                    closestEnemy = enemy
                end
            end
        end
    end

    -- =====================================================
    -- 2. DEFINE ALVO GLOBAL
    -- =====================================================
    STBNPC_Combat.currentTarget = closestEnemy

    -- =====================================================
    -- 3. EXECUTA COMPORTAMENTO POR NPC
    -- =====================================================
    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then
            STBNPC_Combat_Execute(npc, closestEnemy)
        end
    end
end

function STBNPC_Combat_Execute(npc, enemy)

    if not enemy then return end

    local role = STBNPC_Squad_GetRole(npc)

    local dist = npc:DistTo(enemy)

    -- =====================================================
    -- 🪖 ASSAULT (linha de frente)
    -- =====================================================
    if role == "ASSAULT" then

        if dist > 1.5 then
            npc:getTaskManager():AddToTop(PursueTask:new(npc, enemy))
        else
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        end
    end

    -- =====================================================
    -- 🛡️ GUARD (protege player, reage)
    -- =====================================================
    if role == "GUARD" then

        local player = getSpecificPlayer(0)
        local pDist = npc:DistTo(player)

        if pDist > 2 then
            npc:getTaskManager():AddToTop(FollowTask:new(npc, player))
        end

        -- só entra em combate se inimigo chegar perto
        if dist < 6 then
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        end
    end

    -- =====================================================
    -- 🧑‍⚕️ SUPPORT (backline / seguro)
    -- =====================================================
    if role == "SUPPORT" then

        if dist < 3 then
            -- recua pra não atrapalhar
            npc:getTaskManager():AddToTop(WanderTask:new(npc))
        else
            -- atira / apoio
            if npc:usingGun() then
                npc:getTaskManager():AddToTop(AttackTask:new(npc))
            else
                npc:getTaskManager():AddToTop(FollowTask:new(npc, getSpecificPlayer(0)))
            end
        end
    end
end
