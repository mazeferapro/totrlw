local cfg = GMap.config

local PANEL = {}

function PANEL:Init()
    self:SetSize( scale(150), scale(35) )
    
    self.alpha = 0
    self.currentID = 1
    self.price = 0
end

local statusText = {
    [1] = 'Захват. компания';
    [2] = 'Оборон. компания';
}

function PANEL:Paint(w, h)
    local status = tonumber( self.status )
    if status then
        draw.SimpleText(statusText[ status ] or '', 'gmap.6', 0, 0, ColorAlpha( cfg.colors.white, self.alpha * 255), 0, 3 )
    end
    if self.price then
        local price = string.Comma( self.price )
        draw.SimpleText('Значимость: '.. price ..'Т', 'gmap.6', 0, h - 1, ColorAlpha( cfg.colors.yellow, self.alpha * 255), 0, 4 )
    end
end

function PANEL:Think()
    local parent = self.planet
    if IsValid( parent ) then
        if parent:IsHovered() then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 10, self.alpha, 0)
        end
    end
    local infoTable = GMap.Planets[ self.currentID ]
    if infoTable then
        self.price = infoTable.PlanetPrice
    end
end

vgui.Register( 'gmap.planetInfo', PANEL, 'EditablePanel' )