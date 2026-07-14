-- =========================================================
-- STBNPC COMBAT INTELLIGENCE 3.0
-- STATIC WAVE
-- IA de combate inteligente (nível AAA)
-- =========================================================

STBNPC_CombatIntelligence = STBNPC_CombatIntelligence or {}

-- alvo global inteligente
STBNPC_CombatIntelligence.target = nil

-- cache leve
STBNPC_CombatIntelligence.tick = 0
STBNPC_CombatIntelligence.rate = 10


-- =========================================================
-- LOOP PRINCIPAL
-- =========================================================
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    STBNPC_CombatIntelligence.tick = STBNPC_CombatIntelligence.tick + 1

    if STBNPC_CombatIntelligence.tick < STBNPC_CombatIntelligence.rate then
        return
    end

    STBNPC_CombatIntelligence.tick = 0

    STBNPC_CombatIntelligence_Update(squad)
end)


function STBNPC_CombatIntelligence_SelectTarget(squad)

    local bestTarget = nil
    local bestScore = -999

    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            local enemy = npc.LastEnemeySeen

            if enemy then

                local dist = npc:DistTo(enemy)

                local danger = npc:getDangerSeenCount()

                -- =================================================
                -- SCORE DE AMEAÇA (IA REAL)
                -- =================================================
                local score = 0

                -- mais perto = mais prioridade
                score = score + (10 - dist)

                -- mais perigo percebido = mais prioridade
                score = score + danger * 2

                -- suporte sob ameaça vira prioridade
                if npc:getModData().STBNPC.role == "SUPPORT" and dist < 4 then
                    score = score + 5
                end

                if score > bestScore then
                    bestScore = score
                    bestTarget = enemy
                end
            end
        end
    end

    return bestTarget
end


function STBNPC_CombatIntelligence_Execute(npc, enemy, squad)

    if not npc or not enemy then return end

    local role = STBNPC_Squad_GetRole(npc)
    local dist = npc:DistTo(enemy)

    -- =====================================================
    -- 🪖 ASSAULT (pressão constante)
    -- =====================================================
    if role == "ASSAULT" then

        if dist > 1.5 then
            npc:getTaskManager():AddToTop(PursueTask:new(npc, enemy))
        else
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        end
    end

    -- =====================================================
    -- 🧑‍⚕️ SUPPORT (IA DE SOBREVIVÊNCIA)
    -- =====================================================
    if role == "SUPPORT" then

        -- se inimigo perto demais → recua
        if dist < 3 then
            npc:getTaskManager():AddToTop(FleeTask:new(npc))
        else
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        end

        -- ajuda aliados feridos
        for _, ally in ipairs(squad) do

            if ally ~= npc and ally:getHealth() < 0.5 then

                npc:getTaskManager():AddToTop(FollowTask:new(npc, ally))
                break
            end
        end
    end

    -- =====================================================
    -- 🛡️ GUARD (proteção ativa do player)
    -- =====================================================
    if role == "GUARD" then

        local player = getSpecificPlayer(0)
        local pDist = npc:DistTo(player)

        -- mantém proximidade com player
        if pDist > 2.5 then
            npc:getTaskManager():AddToTop(FollowTask:new(npc, player))
        end

        -- intercepta ameaças próximas
        if dist < 6 then
            npc:getTaskManager():AddToTop(AttackTask:new(npc))
        end
    end
end


function STBNPC_CombatIntelligence_Update(squad)

    -- =====================================================
    -- 1. escolhe alvo inteligente
    -- =====================================================
    local target = STBNPC_CombatIntelligence_SelectTarget(squad)

    STBNPC_CombatIntelligence.target = target

    -- =====================================================
    -- 2. executa IA por NPC
    -- =====================================================
    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then
            STBNPC_CombatIntelligence_Execute(npc, target, squad)
        end
    end
end