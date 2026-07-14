-- =========================================================
-- STBNPC RECRUIT SYSTEM
-- STATIC WAVE
-- =========================================================
-- Responsável por:
-- 1. Detectar NPC do mundo (Bandits / Survivors)
-- 2. Calcular chance de rendição
-- 3. Converter NPC WILD -> SURRENDER -> PARTY
-- =========================================================

STBNPC_RecruitSystem = STBNPC_RecruitSystem or {}

STBNPC_RecruitSystem.debug = true
-- STBNPC_RecruitSystem.debug = false

-- cooldown anti-exploit
STBNPC_RecruitSystem.cooldowns = {}

-- =========================================================
-- INICIALIZAÇÃO
-- =========================================================
function STBNPC_RecruitSystem_Init()
    STBNPC_Log("STBNPC_LOG_RECRUIT_INIT")
end

-- =========================================================
-- FUNÇÃO PRINCIPAL: TENTAR RECRUTAR NPC
-- =========================================================
function STBNPC_RecruitSystem_TryRecruit(player, npc)

    if player == nil or npc == nil then return end

    local id = npc:getOnlineID() or tostring(npc)

    -- =====================================================
    -- COOLDOWN (evita spam)
    -- =====================================================
    if STBNPC_RecruitSystem.cooldowns[id] ~= nil then
        STBNPC_Log("STBNPC_LOG_RECRUIT_COOLDOWN")
        return
    end

    -- =====================================================
    -- ESTADO BASE
    -- =====================================================
    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    if data.STBNPC.state == "PARTY" then
        STBNPC_Log("STBNPC_LOG_ALREADY_RECRUITED")
        return
    end

    -- =====================================================
    -- 1. CALCULAR SCORE DE RENDIÇÃO
    -- =====================================================
    local score = STBNPC_RecruitSystem_CalcSurrenderScore(player, npc)

    -- =====================================================
    -- 2. DECISÃO
    -- =====================================================
    if score >= 70 then

        STBNPC_RecruitSystem_Surrender(npc)

    elseif score >= 40 then

        STBNPC_Log("STBNPC_LOG_RECRUIT_NOT_SURE")
        npc:Say("...")

    else

        STBNPC_Log("STBNPC_LOG_RECRUIT_FAIL")
        npc:Say("No way!")

    end

    -- cooldown curto
    STBNPC_RecruitSystem.cooldowns[id] = true

    -- remove cooldown depois (simples)
    luaThread.create(function()
        os.sleep(10)
        STBNPC_RecruitSystem.cooldowns[id] = nil
    end)
end

-- =========================================================
-- CALCULAR SCORE DE RENDIÇÃO
-- =========================================================
function STBNPC_RecruitSystem_CalcSurrenderScore(player, npc)

    local score = 0

    -- VIDA BAIXA
    local health = npc:getHealth()
    if health < 0.4 then
        score = score + 40
    end

    -- NPC DESARMADO
    if npc:isArmed() == false then
        score = score + 30
    else
        score = score - 30
    end

    -- JOGADOR APONTANDO ARMA (SIMULADO)
    if player:isAiming() then
        score = score + 50
    end

    -- ENCONTRADO ISOLADO
    local enemiesNearby = npc:getDangerSeenCount()
    if enemiesNearby == 0 then
        score = score + 20
    end

    -- PERSONALIDADE (Bandits bravery)
    if npc.getBravePoints then
        local bravery = npc:getBravePoints()
        score = score - (bravery * 5)
    end

    return score
end

-- =========================================================
-- FORÇAR RENDIÇÃO
-- =========================================================
function STBNPC_RecruitSystem_Surrender(npc)

    local data = npc:getModData().STBNPC
    if not data then return end

    data.state = "SURRENDER"

    npc:Say("...I give up")

    STBNPC_Log("STBNPC_LOG_NPC_SURRENDERED")
end

-- =========================================================
-- RECRUTAR PARA PARTY
-- =========================================================
function STBNPC_RecruitSystem_ConfirmRecruit(npc)

    local data = npc:getModData().STBNPC
    if not data then return end

    if data.state ~= "SURRENDER" then
        STBNPC_Log("STBNPC_LOG_RECRUIT_NOT_SURRENDERED")
        return
    end

    -- muda estado
    data.state = "PARTY"

    -- adiciona na party
    STBNPC_PartyManager_Add(npc)

    STBNPC_Log("STBNPC_LOG_RECRUIT_SUCCESS")
end

-- =========================================================
-- DEBUG SYSTEM (STATIC WAVE DEV ONLY)
-- =========================================================

--- =========================================================
-- DEBUG - Procura NPC próximo ao jogador
-- =========================================================
function STBNPC_RecruitSystem_Debug_GetNPC(player)

    if not player then
        return nil
    end

    local px = player:getX()
    local py = player:getY()
    local pz = player:getZ()

    local cell = getCell()

    if not cell then
        return nil
    end

    local closestNPC = nil
    local closestDistance = 999

    for x = px - 5, px + 5 do
        for y = py - 5, py + 5 do

            local square = cell:getGridSquare(x, y, pz)

            if square then

                local objects = square:getMovingObjects()

                if objects then

                    for i = 0, objects:size() - 1 do

                        local obj = objects:get(i)

                        if obj
                        and instanceof(obj, "IsoPlayer")
                        and obj ~= player
                        then

                            local distance = obj:DistTo(player)

                            if distance < closestDistance then

                                closestDistance = distance
                                closestNPC = obj
                            end
                        end
                    end
                end
            end
        end
    end

    return closestNPC
end
-- =========================================================
-- DEBUG: RECRUTAR DIRETO (SEM SCORE)
-- =========================================================
function STBNPC_RecruitSystem_Debug_Recruit(player)

    if not STBNPC_RecruitSystem.debug then return end

    local npc = STBNPC_RecruitSystem_Debug_GetNPC(player)

    if npc == nil then
        STBNPC_Log("STBNPC_LOG_DEBUG_NO_NPC")
        return
    end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    data.STBNPC.state = "PARTY"

    STBNPC_PartyManager_Add(npc)

    STBNPC_Log("STBNPC_LOG_DEBUG_FORCE_RECRUIT")

    npc:Say("DEBUG JOINED PARTY")
end
-- =========================================================
-- DEBUG: FORÇAR RENDIÇÃO
-- =========================================================
function STBNPC_RecruitSystem_Debug_Surrender(player)

    if not STBNPC_RecruitSystem.debug then return end

    local npc = STBNPC_RecruitSystem_Debug_GetNPC(player)

    if npc == nil then
        STBNPC_Log("STBNPC_LOG_DEBUG_NO_NPC")
        return
    end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    data.STBNPC.state = "SURRENDER"

    npc:Say("DEBUG SURRENDER")

    STBNPC_Log("STBNPC_LOG_DEBUG_SURRENDER")
end

-- =========================================================
-- DEBUG: ENVIAR PARA TOTEM
-- =========================================================
function STBNPC_RecruitSystem_Debug_ToTotem(player, totem)

    if not STBNPC_RecruitSystem.debug then return end

    local npc = STBNPC_RecruitSystem_Debug_GetNPC(player)

    if npc == nil then return end

    local data = npc:getModData()
    data.STBNPC = data.STBNPC or {}

    data.STBNPC.state = "COLONY"

    STBNPC_TotemSystem_AddNPC(totem, npc, "WORKER")

    npc:Say("DEBUG ASSIGNED TO TOTEM")

    STBNPC_Log("STBNPC_LOG_DEBUG_TOTEM_ASSIGN")
end
-- =========================================================
-- tecla rápida (exemplo simples)
-- =========================================================
Events.OnKeyPressed.Add(function(key)

    if key == Keyboard.KEY_F9 then
        STBNPC_RecruitSystem_Debug_Recruit(getSpecificPlayer(0))
    end

    if key == Keyboard.KEY_F10 then
        STBNPC_RecruitSystem_Debug_Surrender(getSpecificPlayer(0))
    end
end)