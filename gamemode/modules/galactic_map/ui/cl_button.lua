local cfg = GMap.config

local PANEL = {}

function PANEL:Init()
    self:SetFont( 'gmap.3' )
    self:SetTextColor( color_transparent )
    self:SetText''

    self.color, self.targetColor = cfg.colors.blue, cfg.colors.blue
end

function PANEL:Paint( w, h )
    self.targetColor = self:IsHovered() and cfg.colors.blue_hover or cfg.colors.blue
    self.color = LerpColor( FrameTime() * 10, self.color, self.targetColor )

    draw.RoundedBox( scale(6), 0, 0, w, h, self.color )
    draw.SimpleText( self:GetText(), self:GetFont(), w*.5, h*.5, cfg.colors.white, 1, 1 )
    return true
end

vgui.Register( 'gmap.btn', PANEL, 'DButton')