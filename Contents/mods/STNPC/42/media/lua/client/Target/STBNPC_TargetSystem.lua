-- =========================================================
-- STBNPC TARGET SYSTEM
-- STATIC WAVE
-- Sistema de seleção de NPC estilo MMORPG
-- =========================================================

STBNPC_TargetSystem = STBNPC_TargetSystem or {}

-- alvo atual
STBNPC_TargetSystem.currentTarget = nil

-- controle de performance (evita rodar todo tick)
STBNPC_TargetSystem.tickCounter = 0


-- =========================================================
-- ATUALIZAÇÃO DO ALVO
-- =========================================================
function STBNPC_TargetSystem_Update(player)

    if not player then return end

    -- controla frequência de atualização
    STBNPC_TargetSystem.tickCounter = STBNPC_TargetSystem.tickCounter + 1

    if STBNPC_TargetSystem.tickCounter < 10 then
        return
    end

    STBNPC_TargetSystem.tickCounter = 0

    local square = player:getSquare()
    if not square then return end

    local objs = square:getMovingObjects()
    if not objs then return end

    local closest = nil
    local closestDist = 999

    for i = 0, objs:size() - 1 do

        local obj = objs:get(i)

        -- evita selecionar o próprio player
        if instanceof(obj, "IsoPlayer") and obj ~= player then

            local dist = obj:DistTo(player)

            if dist < 3 and dist < closestDist then
                closest = obj
                closestDist = dist
            end
        end
    end

    STBNPC_TargetSystem.currentTarget = closest
end


-- =========================================================
-- UPDATE LOOP GLOBAL
-- =========================================================
Events.OnTick.Add(function()

    local player = getSpecificPlayer(0)
    if player then
        STBNPC_TargetSystem_Update(player)
    end
end)


-- =========================================================
-- RETORNA O NPC SELECIONADO
-- =========================================================
function STBNPC_GetTargetNPC(player)

    return STBNPC_TargetSystem.currentTarget
end


-- =========================================================
-- RENDER VISUAL (HIGHLIGHT SIMPLES)
-- =========================================================
Events.OnRenderTick.Add(function()

    local npc = STBNPC_TargetSystem.currentTarget
    if not npc then return end

    local x = npc:getX()
    local y = npc:getY()
    local z = npc:getZ()

    local sx, sy = IsoUtils.XYToScreen(x, y, z, 0)

    if sx and sy then

        local name = "NPC"

        if npc.getDescriptor then
            local desc = npc:getDescriptor()
            if desc then
                name = desc:getSurname() or "NPC"
            end
        end

        UIManager.DrawText(
            name .. " [TARGET]",
            sx,
            sy - 40,
            1, 0.8, 0.2, 1
        )
    end
end)