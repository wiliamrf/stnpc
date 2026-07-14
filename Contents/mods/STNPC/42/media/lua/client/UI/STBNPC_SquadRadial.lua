-- =========================================================
-- STBNPC SQUAD RADIAL MENU
-- Integração com Q (ISRadialMenu)
-- STATIC WAVE
-- =========================================================

require "ISUI/ISRadialMenu"

STBNPC_SquadRadial = STBNPC_SquadRadial or {}


-- =========================================================
-- INJETA OPÇÕES NO RADIAL DO JOGO
-- =========================================================
local oldDisplay = ISRadialMenu.display

function ISRadialMenu:display(player, x, y)

    oldDisplay(self, player, x, y)

    STBNPC_SquadRadial_AddOptions(self, player)
end


-- =========================================================
-- ADICIONA OPÇÕES DA PARTY NO Q
-- =========================================================
function STBNPC_SquadRadial_AddOptions(menu, player)

    local squad = STBNPC_SquadSystem and STBNPC_SquadSystem.members
    if not squad then return end

    -- =========================
    -- FOLLOW
    -- =========================
    menu:addSlice("Squad: Follow", getTexture("media/ui/icon_follow.png"), function()
        STBNPC_SquadSystem_SetMode("FOLLOW")
    end)

    -- =========================
    -- FLEE
    -- =========================
    menu:addSlice("Squad: Flee", getTexture("media/ui/icon_flee.png"), function()
        STBNPC_SquadSystem_SetMode("FLEE")
    end)

    -- =========================
    -- PATROL
    -- =========================
    menu:addSlice("Squad: Patrol", getTexture("media/ui/icon_patrol.png"), function()
        STBNPC_SquadSystem_SetMode("PATROL")
    end)

    -- =========================
    -- HOLD POSITION
    -- =========================
    menu:addSlice("Squad: Hold", getTexture("media/ui/icon_hold.png"), function()
        STBNPC_SquadSystem_SetMode("HOLD")
    end)

    -- =========================
    -- STEALTH MODE (NOVO)
    -- =========================
    menu:addSlice("Squad: Stealth", getTexture("media/ui/icon_stealth.png"), function()
        STBNPC_SquadSystem_SetMode("STEALTH")
    end)
end