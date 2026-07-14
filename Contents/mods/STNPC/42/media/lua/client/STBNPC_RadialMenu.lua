--=========================================================
-- RADIAL MENU
--=========================================================

require "TimedActions/ISRadialMenu"

local oldRadial = ISRadialMenu.display

function ISRadialMenu:display(player, x, y)

    oldRadial(self, player, x, y)

    STBNPC_RadialMenu_AddOptions(self, player)
end
--=========================================================
-- ADICIONAR OPÇÕES AO RADIAL MENU
--=========================================================

function STBNPC_RadialMenu_AddOptions(menu, player)

    local target = STBNPC_GetTargetNPC(player)

    if target == nil then return end

    -- =====================================================
    -- RECRUIT
    -- =====================================================
    menu:addSlice("Recruit NPC", getTexture("media/ui/icon_recruit.png"), function()

        STBNPC_RecruitSystem_TryRecruit(player, target)

    end)

    -- =====================================================
    -- FORCE SURRENDER
    -- =====================================================
    menu:addSlice("Force Surrender", getTexture("media/ui/icon_hand.png"), function()

        STBNPC_BanditsBridge_ForceSurrender(target)

    end)

    -- =====================================================
    -- ADD TO PARTY
    -- =====================================================
    menu:addSlice("Add to Party", getTexture("media/ui/icon_group.png"), function()

        STBNPC_RecruitSystem_ConfirmRecruit(target)

    end)

    -- =====================================================
    -- SEND TO TOTEM
    -- =====================================================
    menu:addSlice("Assign to Base", getTexture("media/ui/icon_home.png"), function()

        local totem = STBNPC_TotemSystem_GetClosest(player)

        if totem then
            STBNPC_TotemSystem_AddNPC(totem, target, "WORKER")
        end

    end)
end
--=========================================================
-- OBTER NPC ALVO
--========================================================= 
function STBNPC_GetTargetNPC(player)

    local square = player:getSquare()
    if not square then return nil end

    local zombies = square:getMovingObjects()

    for i = 0, zombies:size() - 1 do

        local obj = zombies:get(i)

        if instanceof(obj, "IsoPlayer") then
            return obj
        end
    end

    return nil
end