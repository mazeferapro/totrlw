local PANEL = {}

surface.CreateFont('PawsUI.Frame', {
    font = 'Open Sans',
    size = 36,
    weight = 500,
    extended = true
})

function PANEL:Init()
    self:DockPadding(0, 5, 0, 5)
    
    self.top = vgui.Create('Panel', self) 
    self.top:Dock(TOP) 
    self.top:DockPadding(0, 0, 0, 2)
    self.top.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, NextRP.Style.Theme.Primary, true, true, false, false)

        surface.SetDrawColor(NextRP.Style.Theme.Accent)
        surface.DrawRect(0, h-2, w, 2)
    end

    self.title = vgui.Create('DLabel', self.top)
    self.title:Dock(LEFT)
    self.title:DockMargin( 10, 0, 0, 0 )
    self.title:SetFont('PawsUI.Frame')
    self.title:SetTextColor(color_white)

    self.closeBtn = vgui.Create('DButton', self.top)
    self.closeBtn:Dock(RIGHT)
    self.closeBtn:SetText('')
    self.closeBtn.CloseButton = Color(195, 195, 195)
    self.closeBtn.Alpha = 0
    self.closeBtn.DoClick = function(pnl)
        self:Remove()
    end
    self.closeBtn.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(NextRP.Style.Theme.Red, pnl.Alpha), false, true, false, false)

        surface.SetDrawColor(pnl.CloseButton)
        surface.SetMaterial(PawsUI.Materials.CloseButton)
        surface.DrawTexturedRect(12, 12, w - 24, h - 24)
    end
    self.closeBtn.OnCursorEntered = function(pnl)
        pnl:Lerp('Alpha', 255)
        pnl:LerpColor('CloseButton', Color(255, 255, 255))
    end
    self.closeBtn.OnCursorExited = function(pnl)
        pnl:Lerp('Alpha', 0)
        pnl:LerpColor('CloseButton', Color(195, 195, 195))
    end

    self.settingsBtn = vgui.Create('DButton', self.top)
    self.settingsBtn:Dock(RIGHT)
    self.settingsBtn:SetText('')
    self.settingsBtn.CloseButton = Color(195, 195, 195)
    self.settingsBtn.Alpha = 0
    self.settingsBtn.DoClick = function(pnl)
        
    end
    self.settingsBtn.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(NextRP.Style.Theme.Accent, pnl.Alpha), false, false, false, false)

        surface.SetDrawColor(pnl.CloseButton)
        surface.SetMaterial(PawsUI.Materials.SettingsButton)
        surface.DrawTexturedRect(12, 12, w - 24, h - 24)
    end
    self.settingsBtn.OnCursorEntered = function(pnl)
        pnl:Lerp('Alpha', 255)
        pnl:LerpColor('CloseButton', Color(255, 255, 255))
    end
    self.settingsBtn.OnCursorExited = function(pnl)
        pnl:Lerp('Alpha', 0)
        pnl:LerpColor('CloseButton', Color(195, 195, 195))
    end
end

function PANEL:SetTitle(str)
    self.title:SetText(str)
    self.title:SizeToContents()
end

function PANEL:PerformLayout(w, h)
    self.top:SetTall(42)

    self.closeBtn:SetWide(40)
    self.settingsBtn:SetWide(40)
end

function PANEL:Paint(w, h)
    
    draw.RoundedBox(0, 0, 0, w, h, NextRP.Style.Theme.Background)

    surface.SetDrawColor(NextRP.Style.Theme.Accent)
    surface.DrawRect(0, 0, w, 5)
    surface.DrawRect(0, h-5, w, 5)
end

function PANEL:ShowCloseButton(show)
    self.closeBtn:SetVisible(show)
end

function PANEL:SetSettingsFunc(func)
    self.settingsBtn.DoClick = func
end

function PANEL:ShowSettingsButton(show)
    self.settingsBtn:SetVisible(show)
end

vgui.Register('PawsUI.Frame', PANEL, 'EditablePanel')