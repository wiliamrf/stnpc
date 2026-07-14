-- =========================================================
-- STBNPC BANDITS AI BRIDGE
-- STATIC WAVE
-- =========================================================
-- Responsável por:
-- 1. Ler estado da IA Bandits
-- 2. Detectar oportunidades de captura
-- 3. Forçar transição para SURRENDER
-- 4. Integrar com RecruitSystem
-- =========================================================

STBNPC_BanditsBridge = STBNPC_BanditsBridge or {}

-- =========================================================
-- UPDATE GLOBAL
-- =========================================================
function STBNPC_BanditsBridge_Update()

    local players = getOnlinePlayers()

    if players == nil then return end

    for i = 0, players:size() - 1 do

        local player = players:get(i)

        if player ~= nil then
            STBNPC_BanditsBridge_CheckNearbyNPC(player)
        end
    end
end


-- =========================================================
-- CHECAR NPCS PRÓXIMOS DO JOGADOR
-- =========================================================
function STBNPC_BanditsBridge_CheckNearbyNPC(player)

    local square = player:getSquare()
    if square == nil then return end

    local range = 10

    for x = -range, range do
        for y = -range, range do

            local sq = getCell():getGridSquare(
                square:getX() + x,
                square:getY() + y,
                square:getZ()
            )

            if sq ~= nil then

                local moving = sq:getMovingObjects()

                if moving ~= nil then

                    for i = 0, moving:size() - 1 do

                        local obj = moving:get(i)

                        if obj ~= player and instanceof(obj, "IsoPlayer") then

                            STBNPC_BanditsBridge_ProcessNPC(player, obj)
                        end
                    end
                end
            end
        end
    end
end



-- =========================================================
-- PROCESSAR DE AI
-- =========================================================
function STBNPC_BanditsBridge_ProcessNPC(player, npc)

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    -- =====================================================
    -- IGNORA NPC JÁ DO STBNPC
    -- =====================================================
    if data.STBNPC.state == "PARTY" then return end

    -- =====================================================
    -- DETECTA SITUAÇÃO DE COMBATE
    -- =====================================================
    local inDanger = npc:getDangerSeenCount() or 0
    local health = npc:getHealth()

    -- =====================================================
    -- CONDIÇÃO DE CAPTURA INTELIGENTE
    -- =====================================================
    local canCapture =
        health < 0.4 or
        (inDanger > 0 and npc:isArmed() == false)

    -- =====================================================
    -- JOGADOR DOMINANDO SITUAÇÃO
    -- =====================================================
    local playerAiming = player:isAiming()

    -- =====================================================
    -- FORÇA PRESSÃO PSICOLÓGICA
    -- =====================================================
    if canCapture and playerAiming then

        local score = STBNPC_BanditsBridge_CalcPressure(player, npc)

        if score > 60 then

            STBNPC_BanditsBridge_ForceSurrender(npc)

            STBNPC_Log("STBNPC_LOG_BRIDGE_SURRENDER_FORCED")
        end
    end
end

-- =========================================================
-- CALCULAR PRESSÃO PSICOLÓGICA(DECISÃO DE RENDIÇÃO)
-- =========================================================

function STBNPC_BanditsBridge_CalcPressure(player, npc)

    local score = 0

    -- vida baixa
    if npc:getHealth() < 0.4 then
        score = score + 40
    end

    -- desarmado
    if not npc:isArmed() then
        score = score + 30
    else
        score = score - 20
    end

    -- jogador mirando
    if player:isAiming() then
        score = score + 50
    end

    -- cercado
    if npc:getDangerSeenCount() > 0 then
        score = score + 20
    end

    return score
end

-- =========================================================
-- FORÇAR RENDIÇÃO  
-- =========================================================
function STBNPC_BanditsBridge_ForceSurrender(npc)

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    data.STBNPC.state = "SURRENDER"

    npc:Say("I give up! Don't shoot!")

    -- integra com RecruitSystem automaticamente
    if STBNPC_RecruitSystem then
        STBNPC_RecruitSystem_Surrender(npc)
    end
end