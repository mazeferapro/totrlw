local cfg = GMap.config

local PANEL = {}

function PANEL:Init()
    self:SetFont('gmap.4')
    self:SetTextColor(cfg.colors.white)
    self:SetWrap(true)
    self:SetContentAlignment(7)
    self:SetText''
end

vgui.Register( 'gmap.wrap-text', PANEL, 'DLabel' )