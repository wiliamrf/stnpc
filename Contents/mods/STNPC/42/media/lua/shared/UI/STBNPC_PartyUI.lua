-- =========================================================
-- PARTNER UI 
-- =========================================================


require "ISUI/ISPanel"

STBNPC_PartyUI = ISPanel:derive("STBNPC_PartyUI")

STBNPC_PartyUI.instance = nil

-- =========================================================
-- CRIAR JANELA
-- =========================================================

function STBNPC_PartyUI:initialise()
    ISPanel.initialise(self)

    self:setWidth(250)
    self:setHeight(300)

    self.title = "STBNPC PARTY"

    self.isLocked = false
    self.dragging = false

    self.fixedButton = ISButton:new(10, 10, 80, 20, "FIXAR", self, STBNPC_PartyUI.toggleLock)
    self:addChild(self.fixedButton)
end

-- =========================================================
-- HUD MMORPG STYLE
-- =========================================================
function STBNPC_PartyUI:render()

    self:drawText("PLAYER: " .. getSpecificPlayer(0):getUsername(), 10, 35, 1,1,1,1)

    local party = STBNPC_PartyManager and STBNPC_PartyManager.getParty() or {}

    local y = 60

    for i, npc in ipairs(party) do

        if npc ~= nil then

            local data = npc:getModData().STBNPC or {}

            local name = npc:getDescriptor() and npc:getDescriptor():getSurname() or "NPC"

            self:drawText(
                name .. " [" .. (data.role or "WORKER") .. "]",
                10,
                y,
                0.8, 0.9, 1, 1
            )

            y = y + 20
        end
    end
end

-- =========================================================
-- FIXAR JANELA
-- =========================================================
function STBNPC_PartyUI:toggleLock()

    self.isLocked = not self.isLocked

    if self.isLocked then
        self.fixedButton:setTitle("LOCKED")
    else
        self.fixedButton:setTitle("FIXAR")
    end

    STBNPC_Log("STBNPC_LOG_UI_LOCK_TOGGLED")
end

-- =========================================================
-- MOVER HUD
-- =========================================================

function STBNPC_PartyUI:onMouseDown(x, y)

    if self.isLocked then return end

    self.dragging = true
    self.dragOffsetX = x
    self.dragOffsetY = y
end

function STBNPC_PartyUI:onMouseUp(x, y)

    self.dragging = false
end

function STBNPC_PartyUI:onMouseMove(dx, dy)

    if self.dragging and not self.isLocked then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
end
--========================================================
-- ABRIR UI
--========================================================

function STBNPC_PartyUI_Open()

    if STBNPC_PartyUI.instance then
        STBNPC_PartyUI.instance:removeFromUIManager()
    end

    local ui = STBNPC_PartyUI:new(100, 100, 250, 300)
    ui:initialise()
    ui:addToUIManager()

    STBNPC_PartyUI.instance = ui
end
--========================================================
-- EVENTOS
--========================================================
Events.OnKeyPressed.Add(function(key)

    -- F8 abre UI
    if key == Keyboard.KEY_F8 then
        STBNPC_PartyUI_Open()
    end
end)