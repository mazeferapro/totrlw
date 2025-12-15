include('shared.lua')

local function InverseLerp( pos, p1, p2 )
    local range = 0
    range = p2-p1
    if range == 0 then return 1 end
    return ((pos - p1)/range)
end

function ENT:Draw()
    self:DrawModel()

    local alpha = 255
    local viewdist = 250

    -- calculate alpha
    local max = viewdist
    local min = viewdist*0.75

    local dist = LocalPlayer():EyePos():Distance( self:GetPos() )

    if dist > min and dist < max then
        local frac = InverseLerp( dist, max, min )
        alpha = alpha * frac
    elseif dist > max then
        alpha = 0
    end

    local oang = self:GetAngles()
    local opos = self:GetPos()

    local ang = self:GetAngles()
    local pos = self:GetPos()

    ang:RotateAroundAxis( oang:Up(), 90 )
    ang:RotateAroundAxis( oang:Right(), -90)
    --ang:RotateAroundAxis( oang:Up(), 90)

    pos = pos + oang:Forward() * 35 + oang:Up() * 90  + oang:Right() * 0

    if alpha > 0 then
        cam.Start3D2D( pos, ang, 0.025 )
            draw.SimpleText( 'Медицинский шкаф', 'font_sans_3d2d_large', 0, 0, Color(225, 177, 44, alpha), TEXT_ALIGN_CENTER )
            draw.SimpleText( 'Получить препараты можно тут.', 'font_sans_3d2d_small', 0, 128, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )          
            draw.SimpleText( 'Нажмите [Е] чтобы воспользоваться.', 'font_sans_3d2d_small', 0, 128 + 72, Color(255,255,255, alpha), TEXT_ALIGN_CENTER )         
        cam.End3D2D()
    end
end



local function MedicsDrug(scrollPanel, vendor, tabla1, tabla2)
    local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
        :Stick(TOP, 2)
        :ClearPaint()
        :On('OnToggle', function(self)

            if self:GetExpanded() then
                self.Header:TDLib()
                    :ClearPaint()
                    :Background(NextRP.Style.Theme.Accent)
            else
                self.Header:TDLib()
                    :ClearPaint()
                    :Background(NextRP.Style.Theme.DarkBlue)
            end

        end)

    DCategory.Header:TDLib()
        :ClearPaint()
        :Text('Препараты', 'font_sans_21')

    if DCategory:GetExpanded() then
        DCategory.Header:TDLib():Background(NextRP.Style.Theme.Accent)
    else
        DCategory.Header:TDLib():Background(NextRP.Style.Theme.DarkBlue)
    end

    DCategory.Header:SetTall(25)

    local contents = vgui.Create('DPanelList', DCategory)

    contents:SetPadding(0)
    contents:SetSpacing(4)
    DCategory:SetContents(contents)

    for k, v in pairs(tabla1) do
        local pnl = vgui.Create('PawsUI.Panel')
            :Stick(TOP, 1)
            :Background(Color(53 + 15, 57 + 15, 68 + 15, 100))

        local reciveButton = TDLib('DButton', pnl)
            :ClearPaint()
            :Stick(FILL, 2)
            :SetRemove(scrollPanel:GetParent())
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Accent)
            :LinedCorners()
            :Text(v, 'font_sans_21')
            :On('DoClick', function()
                netstream.Start('NextRP::GiveMed', vendor, k)
            end)

        pnl:SetTall(64 + 2)
        contents:Add(pnl)
    end

    local DCategory2 = TDLib('DCollapsibleCategory', scrollPanel)
        :Stick(TOP, 2)
        :ClearPaint()
        :On('OnToggle', function(self)

            if self:GetExpanded() then
                self.Header:TDLib()
                    :ClearPaint()
                    :Background(NextRP.Style.Theme.Accent)
            else
                self.Header:TDLib()
                    :ClearPaint()
                    :Background(NextRP.Style.Theme.DarkBlue)
            end

        end)

    DCategory2.Header:TDLib()
        :ClearPaint()
        :Text('Таблетки', 'font_sans_21')

    if DCategory2:GetExpanded() then
        DCategory2.Header:TDLib():Background(NextRP.Style.Theme.Accent)
    else
        DCategory2.Header:TDLib():Background(NextRP.Style.Theme.DarkBlue)
    end

    DCategory2.Header:SetTall(25)

    local contents = vgui.Create('DPanelList', DCategory2)

    contents:SetPadding(0)
    contents:SetSpacing(4)
    DCategory2:SetContents(contents)

    for k, v in pairs(tabla2) do
        local pnl = vgui.Create('PawsUI.Panel')
            :Stick(TOP, 1)
            :Background(Color(53 + 15, 57 + 15, 68 + 15, 100))

        local reciveButton = TDLib('DButton', pnl)
            :ClearPaint()
            :Stick(FILL, 2)
            :SetRemove(scrollPanel:GetParent())
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Accent)
            :LinedCorners()
            :Text(v, 'font_sans_21')
            :On('DoClick', function()
                netstream.Start('NextRP::GiveMed', vendor, k)
            end)

        pnl:SetTall(64 + 2)
        contents:Add(pnl)
    end
end

local medtable = {
    ['medic_pills_aciclovirin']         = 'Ацикловирин',
    ['medic_pills_allopyrinol']         = 'Аллопиринол',
    ['medic_pills_amantadin']           = 'Амантадин',
    ['medic_pills_angiopriomillin']     = 'Ангиоприомиллин',
    ['medic_pills_calciftorin']         = 'Кальцифторин',
    ['medic_pills_cardiologin']         = 'Кардиологин',
    ['medic_pills_corticosteron']       = 'Кортикостерон',
    ['medic_pills_erythropinol']        = 'Еритропинол',
    ['medic_pills_ferroarginil']        = 'Ферроаргинил',
    ['medic_pills_phtoropancreatin']    = 'Фторопанкреатин',
    ['medic_pills_ganfumaril']          = 'Ганфумарил',
    ['medic_pills_grippferron']         = 'Гриппферон',
    ['medic_pills_haemoprotolin']       = 'Гемопротолин',
    ['medic_pills_hepatovirin']         = 'Гепатовирин',
    ['medic_pills_hydrocardin']         = 'Гидрокардин',
    ['medic_pills_hydrocortizon']       = 'Гидрокортизон',
    ['medic_pills_hydroferrin']         = 'Гидроферрин',
    ['medic_pills_kolhicin']            = 'Колхицин',
    ['medic_pills_levomycetin']         = 'Левомицетин',
    ['medic_pills_micomycin']           = 'Микомицин',
    ['medic_pills_nasocapril']          = 'Назокаприл',
    ['medic_pills_octinomycillin']      = 'Оциномициллин',
    ['medic_pills_oseltamivir']         = 'Осельтамивир',
    ['medic_pills_oxacillin']           = 'Оксациллин',
    ['medic_pills_penicillin']          = 'Пенициллин',
    ['medic_pills_protoftordin']        = 'Протофтордин',
    ['medic_pills_ribaverin']           = 'Рибаверин',
    ['medic_pills_rimamantadin']        = 'Римамантадин',
    ['medic_pills_serotrombin']         = 'Серотромбин',
    ['medic_pills_trombocyclon']        = 'Тромбоциклон',
    ['medic_pills_zinamivir']           = 'Зинамивир',
    ['medic_pills_cadelin']             = 'Каделин',
    ['medic_pills_cystamine']           = 'Цистамин',
    ['medic_heal_vaselin']              = 'Вазелин',
    ['medic_pills_propital']            = 'Пропитал',
}

local tableTable = {
    ['medic_heal_bandage']              = 'Бинт',
    ['medic_heal_blood_plasma']         = 'Плазма крови',
    ['medic_heal_bandage_kit']          = 'Набор бинтов',
    ['medic_urina']                     = 'Банка для мочи',
    ['medic_heal_alasplint']            = 'Металлическая шина',
    ['medic_heal_surgerykit']           = 'Хирургический набор'
}

local function MedVendor(vendor)
    local MedFrame = TDLib('DFrame')
        :ClearPaint()
        :Background(color_black)
        :FadeIn()
        :On('Paint', function(s, w, h)
            surface.SetDrawColor(NextRP.Style.Theme.Accent)
            surface.DrawRect(0, 0, w, 5)
            surface.DrawRect(0, h-5, w, 5)
        end)
    MedFrame:SetSize(ScrW()/2, ScrH()/2)
    MedFrame:Center()
    MedFrame:SetTitle('')
    MedFrame:MakePopup()
    MedFrame:ShowCloseButton(true)
    MedFrame:SetDraggable(true)

    local scrollPanel = TDLib('DScrollPanel', MedFrame)
        :Stick(FILL, 2)

    local scrollPanelBar = scrollPanel:GetVBar()
    scrollPanelBar:TDLib()
        :ClearPaint()
        :Background(NextRP.Style.Theme.DarkScroll)

    scrollPanelBar.btnUp:TDLib()
        :ClearPaint()
        :Background(NextRP.Style.Theme.DarkScroll)
        :CircleClick()

    scrollPanelBar.btnDown:TDLib()
        :ClearPaint()
        :Background(NextRP.Style.Theme.DarkScroll)
        :CircleClick()

    scrollPanelBar.btnGrip:TDLib()
        :ClearPaint()
        :Background(NextRP.Style.Theme.Scroll)
        :CircleClick()

    MedicsDrug(scrollPanel, vendor, medtable, tableTable)
end


netstream.Hook('NextRP::MedVendorStart', function(pPlayer, vendor)
    MedVendor(vendor)
end)