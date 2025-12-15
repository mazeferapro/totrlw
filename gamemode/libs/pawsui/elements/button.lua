local PANEL = {}

surface.CreateFont('PawsUI.Button', {
    font = 'Open Sans',
    size = 21,
    weight = 500,
    extended = true
})

function PANEL:Init()
    self:SetFont('PawsUI.Button')
    self:SetText('') 

    self:SetTall(25)

    self.m_Text = 'Label'
    self.m_Color = NextRP.Style.Theme.Text

    self:TDLib()
        :ClearPaint()
        :Background(NextRP.Style.Theme.Background)
        :FadeHover()
        :BarHover(NextRP.Style.Theme.Accent)
        :CircleClick(NextRP.Style.Theme.AlphaWhite)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'PawsUI.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
        :On('OnCursorEntered', function(s) s:LerpColor('m_Color', NextRP.Style.Theme.HoveredText) end)
        :On('OnCursorExited', function(s) s:LerpColor('m_Color', NextRP.Style.Theme.Text) end)
end

function PANEL:Restore()
    self:ClearPaint()
        :Background(NextRP.Style.Theme.Background)
        :FadeHover()
        :BarHover(NextRP.Style.Theme.Accent)
        :CircleClick(NextRP.Style.Theme.AlphaWhite)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'PawsUI.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
    return self
end

function PANEL:SetBackground(bgColor, hoverColor)
    self:ClearPaint()
        :Background(bgColor or NextRP.Style.Theme.DarkBlue)
        :FadeHover(hoverColor or NextRP.Style.Theme.Blue)
        :CircleClick(NextRP.Style.Theme.AlphaWhite)
        :On('Paint', function(s, w, h)
            draw.SimpleText(self.m_Text, 'PawsUI.Button', w * .5, h * .5, s.m_Color , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
    return self
end
 
function PANEL:SetLabel(str)
    self.m_Text = str

    self:InvalidateLayout()

    return self
end

vgui.Register('PawsUI.Button', PANEL, 'DButton')