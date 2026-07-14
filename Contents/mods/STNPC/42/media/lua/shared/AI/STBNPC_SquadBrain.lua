-- =========================================================
-- STBNPC SQUAD BRAIN
-- IA COLETIVA DO ESQUADRÃO
-- STATIC WAVE
-- =========================================================

STBNPC_SquadBrain = STBNPC_SquadBrain or {}


-- =========================================================
-- LOOP PRINCIPAL (DECISÃO COLETIVA)
-- =========================================================
Events.OnTick.Add(function()

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    STBNPC_SquadBrain_EvaluateSquad(player, squad)
end)


-- =========================================================
-- AVALIAÇÃO GLOBAL DO ESQUADRÃO
-- =========================================================
function STBNPC_SquadBrain_EvaluateSquad(player, squad)

    local enemyNearby = false
    local closestEnemy = nil
    local closestDist = 999

    -- =====================================================
    -- SCAN GLOBAL (1x por tick leve)
    -- =====================================================
    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            local enemy = npc.LastEnemeySeen

            if enemy ~= nil then

                local dist = npc:DistTo(enemy)

                if dist < closestDist then
                    closestDist = dist
                    closestEnemy = enemy
                    enemyNearby = true
                end
            end
        end
    end

    -- =====================================================
    -- DECISÃO GLOBAL DO ESQUADRÃO
    -- =====================================================
    if enemyNearby then
        STBNPC_SquadBrain_SetState("COMBAT", closestEnemy)
    else
        STBNPC_SquadBrain_SetState("PEACE", nil)
    end
end

function STBNPC_SquadBrain_SetState(state, enemy)

    local squad = STBNPC_SquadSystem.members

    for _, npc in ipairs(squad) do

        if npc and not npc:isDead() then

            local data = npc:getModData()
            data.STBNPC = data.STBNPC or {}

            data.STBNPC.squadState = state
            data.STBNPC.squadEnemy = enemy

            STBNPC_SquadBrain_ExecuteRole(npc, state, enemy)
        end
    end
end

function STBNPC_SquadBrain_ExecuteRole(npc, state, enemy)

    local data = npc:getModData().STBNPC
    local role = data.role or "ASSAULT"

    -- =====================================================
    -- COMBATE
    -- =====================================================
    if state == "COMBAT" then

        -- -----------------------------
        -- ASSAULT (linha de frente)
        -- -----------------------------
        if role == "ASSAULT" then

            if enemy then
                npc:getTaskManager():AddToTop(PursueTask:new(npc, enemy))
            end
        end

        -- -----------------------------
        -- SUPPORT (cobre + distância)
        -- -----------------------------
        if role == "SUPPORT" then

            if enemy then
                local dist = npc:DistTo(enemy)

                if dist < 4 then
                    npc:getTaskManager():AddToTop(FleeTask:new(npc))
                else
                    npc:getTaskManager():AddToTop(AttackTask:new(npc))
                end
            end
        end

        -- -----------------------------
        -- GUARD (defesa fixa)
        -- -----------------------------
        if role == "GUARD" then

            if enemy then
                npc:getTaskManager():AddToTop(AttackTask:new(npc))
            else
                npc:getTaskManager():AddToTop(WanderTask:new(npc))
            end
        end
    end


    -- =====================================================
    -- PAZ / EXPLORAÇÃO
    -- =====================================================
    if state == "PEACE" then

        if role == "ASSAULT" or role == "SUPPORT" then
            npc:getTaskManager():AddToTop(FollowTask:new(npc, getSpecificPlayer(0)))
        end

        if role == "GUARD" then
            npc:getTaskManager():AddToTop(WanderTask:new(npc))
        end
    end
end