local PANEL = {}

function PANEL:Init()    
    self.VBar:SetWide(12)
    self.VBar:SetHideButtons(true)

    self.VBar.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, ColorAlpha(NextRP.Style.Theme.DarkScroll, 150))
    end
    self.VBar.btnGrip.Paint = function(pnl, w, h)
        draw.RoundedBox(2, 0, 0, w, h, NextRP.Style.Theme.Scroll)
    end
end
 
vgui.Register('PawsUI.ScrollPanel', PANEL, 'DScrollPanel')

