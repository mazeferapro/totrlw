local cfg = GMap.config

local PANEL = {}

function PANEL:Init()
    -- self:SetValue(false)

    self.animProgress = 0
    self.targetProgress = 0
    self.animSpeed = 10
end

function PANEL:OnChange(newValue)
    self.targetProgress = newValue and 1 or 0

    -- surface.PlaySound( 'luna_ui/click3.wav' )
end

function PANEL:Think()
    if self.animProgress ~= self.targetProgress then
        self.animProgress = math.Approach(self.animProgress, self.targetProgress, FrameTime() * self.animSpeed)
        self:InvalidateLayout()
    end
end

function PANEL:Paint(w, h)
    draw.NewRect(0, 0, w, h, cfg.colors.main_back)
    
    local size = math.min(w, h) - scale(10)
    local progress = self.animProgress
    local currentSize = size * progress
    local x = w * 0.5 - currentSize * 0.5
    local y = h * 0.5 - currentSize * 0.5
    
    draw.NewRect(x, y, currentSize, currentSize, cfg.colors.blue)
end

vgui.Register('gmap.checkbox', PANEL, 'DCheckBox')