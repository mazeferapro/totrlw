local cfg = GMap.config

local PANEL = {}

local x = scale(10)
function PANEL:Init()
    self.currentPlanet = 0
    self.WarTask = {}
    self.WarTaskCompleted = {}

    local parent = self:GetParent()
    local pW, pH = parent:GetSize()
    self:SetSize( pW, pH )

    self.horizScroll = self:Add( 'gmap.horizontal-scroll' )
    self.horizScroll:Dock(FILL)

    self.planetSettings = self.horizScroll:Add( 'Panel' )
    self.planetSettings:SetSize( scale(500), pH )

    self.planetSettings.Paint = function( _, w, h )
        draw.Blur( _, 2 )
        draw.NewRect( 0, 0, w, h, cfg.colors.back5 )
        draw.SimpleText( 'НАСТРОЙКА ПЛАНЕТЫ', 'gmap.1', x, scale(5), cfg.colors.white, 0, 3 )

        draw.SimpleText( 'ВНИМАНИЕ!', 'gmap.8', x, self.settingsDesc:GetTall() + self.warInfoBack:GetTall() + self.entryPrice:GetTall() + scale(120), cfg.colors.red, 0, 3 )
    end

    self:addContent1()

    self.orderSettings = self.horizScroll:Add( 'Panel' )
    self.orderSettings:SetSize( scale(500), pH )
    self.orderSettings:SetX( self.planetSettings:GetWide() + scale(20) )

    self:addContent2()
    self:addContent3()
end

function PANEL:addContent3()
    local oW, oH = self.orderSettings:GetSize()

    self.companyPanel = self.orderSettings:Add( 'Panel' )
    self.companyPanel:SetSize( oW, oH - self.orderPanel:GetTall() - self.companyPanel:GetTall() )
    self.companyPanel:SetY( self.orderPanel:GetTall() + scale(20) )

    self.companyPanel.Paint = function( _, w, h )
        draw.Blur( _, 2 )
        draw.NewRect( 0, 0, w, h, cfg.colors.back5 )
        draw.SimpleText( 'ВОЕННАЯ КАМПАНИЯ', 'gmap.1', x, scale(5), cfg.colors.white, 0, 3 )

        draw.SimpleText( 'ВНИМАНИЕ!', 'gmap.8', x, self.companyDesc:GetTall() + self.companyHeader:GetTall() + self.companyMain:GetTall() + scale(80), cfg.colors.red, 0, 3 )
    end

    local w = oW - scale(20)

    self.companyDesc = self.companyPanel:Add( 'gmap.wrap-text' )
    self.companyDesc:SetSize( w, scale(60) )
    self.companyDesc:SetPos( x, scale(50) )
    self.companyDesc:SetTextColor( cfg.colors.gray )
    self.companyDesc:SetFont( 'gmap.3' )
    self.companyDesc:SetText( 'Локальная задача, исходящая от командования 13-ой Секторальной Армии' )

    self.companyHeader = self.companyPanel:Add( 'gmap.entry' )
    self.companyHeader:SetSize( w, scale(50) )
    self.companyHeader:SetPos( x, self.companyDesc:GetTall() + scale(50) )
    self.companyHeader:SetText( GMap.Planets and GMap.Planets.HeaderWarCompany or '' )
    self.companyHeader:SetHolderText( 'ЗАГОЛОВОК ПРИКАЗА' )

    self.companyMain = self.companyPanel:Add( 'gmap.entry' )
    self.companyMain:SetSize( w, scale(100) )
    self.companyMain:SetPos( x, self.companyDesc:GetTall() + scale(50) + self.companyHeader:GetTall() + x )
    self.companyMain:SetText( GMap.Planets and GMap.Planets.WarCompanyDesc or '' )
    self.companyMain:SetHolderText( 'ПРИКАЗ' )
    self.companyMain:SetMultiline( true )

    self.apply3 = self.companyPanel:Add( 'gmap.btn' )
    self.apply3:SetSize( scale(150), scale(50) )
    self.apply3:SetPos( self.companyPanel:GetWide() - self.apply3:GetWide() - x, self.companyDesc:GetTall() + self.companyHeader:GetTall() + self.companyMain:GetTall() + scale(70) )
    self.apply3:SetText( 'ПРИМЕНИТЬ' )

    self.apply3.DoClick = function()
        surface.PlaySound( 'luna_ui/click2.wav' )

        local body = self:GetParent()
        local fr = body:GetParent()

        local headerText, descText = self.companyHeader:GetValue(), self.companyMain:GetValue()

        net.Start('GMap:GetInfoConfigWarCompany')
            net.WriteString( headerText )
            net.WriteString( descText )
        net.SendToServer()

        fr:Notify( 'Изменения военной кампании вступили в силу.' )
    end

    self.companyWarn = self.companyPanel:Add( 'gmap.wrap-text' )
    self.companyWarn:SetSize( w, scale(60) )
    self.companyWarn:SetPos( x, self.companyPanel:GetTall() - self.companyWarn:GetTall() - scale(230) )
    self.companyWarn:SetTextColor( cfg.colors.gray )
    self.companyWarn:SetFont( 'gmap.3' )
    self.companyWarn:SetText('Не меняйте приказ без причины! Это приведёт к плачевным для Вас последствиям')
end

local function checkValue( panel, value, min, max, errorMessage)
    if value == nil or value == '' or not value or value < min or value > max then
        panel:Notify(errorMessage)
        return false
    end
    return true
end

function PANEL:addContent2()
    local oW = self.orderSettings:GetWide()

    self.orderPanel = self.orderSettings:Add( 'Panel' )
    self.orderPanel:SetSize( oW, scale(420) )

    self.orderPanel.Paint = function( _, w, h )
        draw.Blur( _, 2 )
        draw.NewRect( 0, 0, w, h, cfg.colors.back5 )
        draw.SimpleText( 'ПРИКАЗ ШТАБА', 'gmap.1', x, scale(5), cfg.colors.white, 0, 3 )

        draw.SimpleText( 'ВНИМАНИЕ!', 'gmap.8', x, self.orderDesc:GetTall() + self.orderHeader:GetTall() + self.orderMain:GetTall() + scale(80), cfg.colors.red, 0, 3 )
    end

    local w = oW - scale(20)

    self.orderDesc = self.orderPanel:Add( 'gmap.wrap-text' )
    self.orderDesc:SetSize( w, scale(60) )
    self.orderDesc:SetPos( x, scale(50) )
    self.orderDesc:SetTextColor( cfg.colors.gray )
    self.orderDesc:SetFont( 'gmap.3' )
    self.orderDesc:SetText( 'Глобальная задача, транслируемая со стороны генерального штаба Великой Армии Республики.' )

    self.orderHeader = self.orderPanel:Add( 'gmap.entry' )
    self.orderHeader:SetSize( w, scale(50) )
    self.orderHeader:SetPos( x, self.orderDesc:GetTall() + scale(50) )
    self.orderHeader:SetText( GMap.Planets and GMap.Planets.HeaderDescription or '' )
    self.orderHeader:SetHolderText( 'ЗАГОЛОВОК ПРИКАЗА' )

    self.orderMain = self.orderPanel:Add( 'gmap.entry' )
    self.orderMain:SetSize( w, scale(100) )
    self.orderMain:SetPos( x, self.orderDesc:GetTall() + scale(50) + self.orderHeader:GetTall() + x )
    self.orderMain:SetText( GMap.Planets and GMap.Planets.OrderDescription or '' )
    self.orderMain:SetHolderText( 'ПРИКАЗ' )
    self.orderMain:SetMultiline( true )

    self.apply2 = self.orderPanel:Add( 'gmap.btn' )
    self.apply2:SetSize( scale(150), scale(50) )
    self.apply2:SetPos( self.orderPanel:GetWide() - self.apply2:GetWide() - x, self.orderDesc:GetTall() + self.orderHeader:GetTall() + self.orderMain:GetTall() + scale(70) )
    self.apply2:SetText( 'ПРИМЕНИТЬ' )

    self.apply2.DoClick = function()
        surface.PlaySound( 'luna_ui/click2.wav' )

        local body = self:GetParent()
        local fr = body:GetParent()

        local headerText, descText = self.orderHeader:GetValue(), self.orderMain:GetValue()

        net.Start('GMap:GetInfoConfigOrderFrom')
            net.WriteString( headerText )
            net.WriteString( descText )
        net.SendToServer()

        fr:Notify( 'Изменения приказов штаба вступили в силу.' )
    end

    self.orderWarn = self.orderPanel:Add( 'gmap.wrap-text' )
    self.orderWarn:SetSize( w, scale(60) )
    self.orderWarn:SetPos( x, self.orderPanel:GetTall() - self.orderWarn:GetTall() - x )
    self.orderWarn:SetTextColor( cfg.colors.gray )
    self.orderWarn:SetFont( 'gmap.3' )
    self.orderWarn:SetText('Не меняйте приказ без причины! Это приведёт к плачевным для Вас последствиям')

end

function PANEL:addContent1()
    local w = self.planetSettings:GetWide() - scale(20)

    self.settingsDesc = self.planetSettings:Add( 'gmap.wrap-text' )
    self.settingsDesc:SetSize( w, scale(120) )
    self.settingsDesc:SetPos( x, scale(50) )
    self.settingsDesc:SetTextColor( cfg.colors.gray )
    self.settingsDesc:SetFont( 'gmap.3' )
    self.settingsDesc:SetText([[Настройка информации о планете, её статус.
Задачи и прогресс захвата.

Если вы уже заполнили все данные, то можете указать уже выполненые задачи.]])

    self.selectPlanet = self.planetSettings:Add( 'gmap.combobox' )
    self.selectPlanet:SetSize( w - scale( 110 ), scale(50)  )
    self.selectPlanet:SetPos( x, self.settingsDesc:GetTall() + self.selectPlanet:GetTall() + x )
    self.selectPlanet.text = 'ВЫБРАТЬ ПЛАНЕТУ'

    for id, planet in ipairs( GALACTIC_MAP ) do
        self.selectPlanet:AddChoice( planet.name )
    end

    self.selectPlanet.OnSelect = function(_, index, __)
        self.currentPlanet = index

        local tableInfo = GMap.Planets[index]
        self.status:SetText(tableInfo and tableInfo.Status or '')
    
        for i = 1, 5 do
            local warInfo = tableInfo and tableInfo.WarInfo and tableInfo.WarInfo[i] or ''
            self.WarTask[i]:SetText(warInfo)
    
            local completed = tableInfo and tableInfo.Completed and tableInfo.Completed[i] or false
            self.WarTaskCompleted[i]:SetValue(completed)
        end

        local price = tableInfo and tableInfo.PlanetPrice or ''
        self.entryPrice:SetText( price )

        local fProg, sProg = tableInfo and tableInfo.firstProgress or '', tableInfo and tableInfo.secondProgress or ''
        self.firstProgress:SetText( fProg )
        self.secondProgress:SetText( sProg )
    end

    self.status = self.planetSettings:Add( 'gmap.entry' )
    self.status:SetSize( scale(100), scale(50) )
    self.status:SetPos( w - self.status:GetWide() + scale(10), self.settingsDesc:GetTall() + self.selectPlanet:GetTall() + x )
    self.status:SetHolderText( 'СТАТУС' )
    self.status:SetNumeric( true )

    self.warInfoBack = self.planetSettings:Add( 'Panel' )
    self.warInfoBack:SetSize( w, scale(400) )
    self.warInfoBack:SetPos( x, self.settingsDesc:GetTall() + self.selectPlanet:GetTall() + scale(70) )

    for i = 1, 5 do
        self.order = self.warInfoBack:Add( 'Panel' )
        self.order:Dock(TOP)
        self.order:SetTall( scale(50) )
        self.order:DockMargin( 0, 0, 0, scale(10) )

        self.WarTask[i] = self.order:Add( 'gmap.entry' )
        self.WarTask[i]:Dock(FILL)
        self.WarTask[i]:DockMargin( 0, 0, scale(10), 0 )
        self.WarTask[i]:SetHolderText( i.. ' ВОЕННАЯ ЗАДАЧА' )

        self.WarTaskCompleted[i] = self.order:Add( 'gmap.checkbox' )
        self.WarTaskCompleted[i]:Dock(RIGHT)
        self.WarTaskCompleted[i]:SetWide( scale(50) )
    end

    self.entryPrice = self.planetSettings:Add( 'gmap.entry' )
    self.entryPrice:SetSize( w, scale(50) )
    self.entryPrice:SetPos( x, self.settingsDesc:GetTall() + self.warInfoBack:GetTall() + scale(20) )
    self.entryPrice:SetHolderText( 'ЦЕННОСТЬ ПЛАНЕТЫ' )
    self.entryPrice:SetNumeric(true)

    self.settingsWarn = self.planetSettings:Add( 'gmap.wrap-text' )
    self.settingsWarn:SetSize( w, scale(120) )
    self.settingsWarn:SetPos( x, self.planetSettings:GetTall() - self.settingsWarn:GetTall() - scale(200) )
    self.settingsWarn:SetTextColor( cfg.colors.gray )
    self.settingsWarn:SetFont( 'gmap.3' )
    self.settingsWarn:SetText('Сохраняйте целостность текста, не допускайте грамматических ошибок и старайтесь кратко, но доступно изложить всю информацию через доступные Вам функции!')

    self.firstProgress = self.planetSettings:Add( 'gmap.entry' )
    self.firstProgress:SetSize( w * .5 - scale(5), scale(50) )
    self.firstProgress:SetPos( x, self.settingsDesc:GetTall() + self.warInfoBack:GetTall() + self.entryPrice:GetTall() + scale(30) )
    self.firstProgress:SetHolderText( 'ПРОГРЕСС 1' )
    self.firstProgress:SetNumeric(true)

    self.secondProgress = self.planetSettings:Add( 'gmap.entry' )
    self.secondProgress:SetSize( w * .5 - scale(5), scale(50) )
    self.secondProgress:SetPos( self.firstProgress:GetWide() + x + x, self.settingsDesc:GetTall() + self.warInfoBack:GetTall() + self.entryPrice:GetTall() + scale(30) )
    self.secondProgress:SetHolderText( 'ПРОГРЕСС 2' )
    self.secondProgress:SetNumeric(true)

    self.apply = self.planetSettings:Add( 'gmap.btn' )
    self.apply:SetSize( scale(150), scale(50) )
    self.apply:SetPos( self.planetSettings:GetWide() - self.apply:GetWide() - x, self.settingsDesc:GetTall() + self.warInfoBack:GetTall() + self.entryPrice:GetTall() + scale(110) )
    self.apply:SetText( 'ПРИМЕНИТЬ' )

    self.apply.DoClick = function()
        surface.PlaySound( 'luna_ui/click2.wav' )

        local body = self:GetParent()
        local fr = body:GetParent()

        local status, planetPrice, fProgress, sProgess = tonumber(self.status:GetValue()), tonumber(self.entryPrice:GetValue()), tonumber(self.firstProgress:GetValue()), tonumber(self.secondProgress:GetValue())

        if not checkValue( fr, status, 1, 2, 'Некорректно указан статус (1 или 2)') then return end
        if not checkValue( fr, fProgress, 1, 3, 'Некорректно указан прогресс 1 (от 1 до 3)') then return end
        if not checkValue( fr, sProgess, 1, 3, 'Некорректно указан прогресс 2 (от 1 до 3)') then return end
        if not checkValue( fr, planetPrice, 0, math.huge, 'Некорректно указана ценность планеты.') then return end

        if self.currentPlanet == 0 then
            fr:Notify('Не указана планета.')
            return
        end
        
        local WarInfo, WarCompleted = {}, {}
        for i = 1, 5 do
            WarInfo[i] = self.WarTask[i]:GetValue()
            WarCompleted[i] = self.WarTaskCompleted[i]:GetChecked()
        end

        net.Start('GMap:GetInfoConfig')
            net.WriteInt( self.currentPlanet, 10 )
            net.WriteTable( WarInfo )
            net.WriteString( planetPrice )
            net.WriteTable( WarCompleted )
            net.WriteString( status )
            net.WriteString( fProgress )
            net.WriteString( sProgess )
        net.SendToServer()

        fr:Notify( 'Изменения планет вступили в силу.' )
    end
end

vgui.Register( 'gm.tab.galacticmap', PANEL, 'EditablePanel' )