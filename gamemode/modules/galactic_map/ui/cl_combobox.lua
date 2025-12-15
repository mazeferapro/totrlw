local cfg = GMap.config

do
    local PANEL = {}
    function PANEL:Init()
        self.options = {}

        self.scroll = self:Add( 'achievements.scroll' )
        self.scroll:Dock(FILL)
    end

    function PANEL:AddOption(text, callback)
        self.id = #self.options + 1

        self.options[self.id] = self.scroll:Add('DButton')
        self.option = self.options[self.id]
        self.option:SetText('')
        self.option:Dock(TOP)
        self.option:SetTall( scale(30) )

        self.option.color, self.option.targetColor = cfg.colors.gray, cfg.colors.gray
        self.option.Paint = function(s, w, h)
            draw.Blur( s, 3 )
            s.targetColor = s:IsHovered() and cfg.colors.white or cfg.colors.gray
            s.color = LerpColor( FrameTime() * 10, s.color, s.targetColor )

            draw.NewRect( 0, 0, w, h, cfg.colors.main_back )

            draw.SimpleText( text, 'gmap.3', scale(5), h * 0.5, s.color, 0, 1 )
            return true
        end

        if callback then self.option.DoClick = callback end
        return self.option
    end

    function PANEL:PerformLayout(w, h)
        if #self.options < 1 then return end
        self:SetTall(math.min(200, self.option:GetTall() * #self.options))
    end

    function PANEL:Paint(w, h)
    end

    vgui.Register( 'gmap.menu', PANEL, 'EditablePanel' )
end

do
    local PANEL = {}
    function PANEL:Init()
        self.choices = {}
        self.selected = nil
        self.text = ''

        self.open = self:Add('DButton')
        self.open:SetText('')
        self.open:SetTall(scale(50))
        self.open.color, self.open.targetColor = cfg.colors.gray2, cfg.colors.gray2

        self.open.Paint = function(s, w, h)
            s.targetColor = s:IsHovered() and cfg.colors.white or cfg.colors.gray2
            s.color = LerpColor( FrameTime() * 10, s.color, s.targetColor )
            draw.NewRect( 0, 0, w, h, cfg.colors.main_back )

            draw.SimpleText( self.text, 'gmap.3', scale(5), h * 0.5, s.color, 0, 1 )
            return true
        end

        self.open.DoClick = function()
            if self:IsOpen() then
                self:CloseMenu()
                return
            end

            self:Open()
        end
    end

    function PANEL:ChooseOption(value, index)
        if self.m then
            self.m:Remove()
            self.m = nil
        end

        self.selected = index
        self.text = value
        self:OnSelect(index, value)
        surface.PlaySound( 'luna_ui/click2.wav' )

    end

    function PANEL:AddChoice(value, select)
        self.id = #self.choices + 1
        self.choices[self.id] = value
        if select then self:ChooseOption(value) end
        return self.choices[self.id]
    end

    function PANEL:IsOpen()
        return IsValid(self.m) and self.m:IsVisible()
    end

    function PANEL:Open()
        if #self.choices < 1 then return end
        if IsValid(self.m) then
            self.m:Remove()
            self.m = nil
        end

        surface.PlaySound( 'luna_ui/click2.wav' )
        self:SetZPos( 32767 )

        self.m = self:Add('gmap.menu')
        self.m:SetY(self.open:GetTall())
        self.m:SetWide(self:GetWide())
        self.m:SetTall(200)

        for i, v in ipairs(self.choices) do
            self.m:AddOption(v, function() self:ChooseOption(v, i) self:SetZPos( -32767 )  end)
        end
    end

    function PANEL:CloseMenu()
        if not IsValid(self.m) then return end
        self:SetZPos( -32767 )

        surface.PlaySound( 'luna_ui/click2.wav' )
        self.m:Remove()
    end

    function PANEL:OnSelect(index, value)
    end

    function PANEL:PerformLayout(w, h)
        self.open:SetWide(w)
        if not self:IsOpen() then return end
        self.m:SetWide(w)
        self.m:SetTall(200)
        self:SetTall(40 + self.m:GetTall())
    end

    vgui.Register('gmap.combobox', PANEL, 'EditablePanel')
end