local cfg = GMap.config

local PANEL = {}

AccessorFunc( PANEL, 'm_bHolderText', 'HolderText', FORCE_STRING )

function PANEL:Init()
    self:SetFont( 'gmap.3' )
    self:SetDrawLanguageID( false )

    self.color, self.targetColor = cfg.colors.gray2, cfg.colors.gray2
end

function PANEL:Paint( w, h )
    self.targetColor = self:IsHovered() and cfg.colors.white or (self:GetNumeric() and cfg.colors.yellow or cfg.colors.gray2)
    self.color = LerpColor( FrameTime() * 10, self.color, self.targetColor )

    draw.NewRect( 0, 0, w, h, cfg.colors.main_back )
    if self:GetValue() == '' and not self:IsEditing() then
        draw.SimpleText( self:GetHolderText(), self:GetFont(), scale(5), self:IsMultiline() and scale(5) or h*.5, cfg.colors.gray2, 0, self:IsMultiline() and 3 or 1 )
    end

    self:DrawTextEntryText( self.color, cfg.colors.input_popup, cfg.colors.white )
end

vgui.Register( 'gmap.entry', PANEL, 'DTextEntry' )