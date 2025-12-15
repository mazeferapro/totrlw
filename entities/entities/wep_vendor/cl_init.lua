include('shared.lua')

function ENT:Draw()
    self:DrawModel()
end

local cTable = {
    ['Гранаты'] = {
        ['arc9_k_nade_bacta'] = 18000,
        ['arc9_k_nade_thermal'] = 19000,
        ['arc9_k_nade_flash'] = 15000,
        ['arc9_k_nade_impact'] = 12000,
    },
    ['Тяжелое вооружение'] = {
        ['arc9_k_launcher_smartlauncher'] = 50000,
        ['arc9_galactic_rt97h'] = 25000,
        ['arc9_galactic_m45x'] = 26000,
        ['arc9_k_launcher_e60r'] = 40000,
        ['arc9_k_launcher_plx1_republic'] = 42000,
    },
    ['Бластерные пистолеты'] = {
        ['arc9_galactic_defender_sporting'] = 2500,
        ['arc9_galactic_glie44'] = 2000,
        ['arc9_galactic_dl18d'] = 2700,
        ['arc9_galactic_bryar'] = 2500,
        ['arc9_galactic_westar35'] = 5500,
    },
    ['Двойное вооружение'] = {
        ['arc9_galactic_bryar'] = 5008,
        ['arc9_k_dc17sa_akimbo'] = 5700,
        ['arc9_k_dc17ext_akimbo'] = 6000,
    },
    ['Бластерные винтовки'] = {
        ['arc9_galactic_a280s'] = 10000,
        ['arc9_galactic_a287'] = 11080,
        ['arc9_galactic_bowcaster'] = 12000,
        ['arc9_galactic_el16'] = 10000,
        ['arc9_k_westarm5'] = 25000,
    },
    ['Снайперские винтовки'] = {
        ['arc9_galactic_iqa11c'] = 15000,
        ['arc9_k_valken38'] = 19000,
        ['arc9_galactic_e9x'] = 20000,
    },
    ['Дробовики'] = {
        ['arc9_galactic_md12'] = 10000,
        ['arc9_k_sb2'] = 15000,
    },
    ['Прочее'] = {
        ['realistic_hook'] = 15000,
        ['jet_mk5'] = 25000,
        ['weapon_bactainjector'] = 16000,
        ['fort_datapad'] = 15500,
    }
}


local function generateWeapons(scrollPanel, tWeapons, sWeapons, cat)
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
        :Text(cat or 'Error!', 'font_sans_21')

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

    for wep, price in pairs(sWeapons) do
        local tWep = weapons.Get(wep)
        if tWep == nil then continue end

        local pnl = vgui.Create('PawsUI.Panel')
            :Stick(TOP, 1)
            :Background(Color(53 + 15, 57 + 15, 68 + 15, 100))

        local wepMat = Material('entities/'..wep..'.png', 'smooth')

        local icon = vgui.Create('PawsUI.Panel', pnl)
            :Stick(LEFT, 2)

        PAW_MODULE('lib'):Download('nw/noicon.png', 'https://i.imgur.com/yaqb1ND.png', function(dPath)
            local mat = Material(dPath, 'smooth')
            if wepMat:IsError() then
                icon:Material(mat)
            else
                icon:Material(wepMat)
            end
        end)

        icon:SetWide(64)

        local title = vgui.Create('PawsUI.Panel', pnl)
            :Stick(TOP, 2)

        title:On('Paint', function(s, w, h)
            draw.DrawText(tWep.PrintName or wep, 'font_sans_21', 1, 5, NextRP.Style.Theme.Text, nil, TEXT_ALIGN_LEFT)
        end)

        local reciveButton = TDLib('DButton', pnl)
            :ClearPaint()
            :SetRemove(scrollPanel:GetParent())
            :Stick(FILL, 2)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Accent)
            :LinedCorners()
            :On('Think', function(s)
                local hasValidAccess = false
                local timeText = ""
                
                if tWeapons[wep] and istable(tWeapons[wep]) and tWeapons[wep].expiry then
                    hasValidAccess = os.time() < tWeapons[wep].expiry
                    
                    if hasValidAccess then
                        local timeLeft = tWeapons[wep].expiry - os.time()
                        local hours = math.floor(timeLeft / 3600)
                        local minutes = math.floor((timeLeft % 3600) / 60)
                        local seconds = timeLeft % 60
                        timeText = string.format(" (%02d:%02d:%02d)", hours, minutes, seconds)
                    end
                end
                
                if LocalPlayer():HasWeapon(wep) and hasValidAccess then
                    s:Text('У вас уже есть это оружие', 'font_sans_21')
                    s:SetEnabled(false)
                elseif hasValidAccess then
                    s:Text('Получить' .. timeText, 'font_sans_21')
                    s:SetEnabled(true)
                else
                    s:Text('Купить за '..price..' CR (30 дней)', 'font_sans_21')
                    s:SetEnabled(true)
                end
            end)
            :On('DoClick', function()
                local hasValidAccess = false
                if tWeapons[wep] and istable(tWeapons[wep]) and tWeapons[wep].expiry then
                    hasValidAccess = os.time() < tWeapons[wep].expiry
                end
                
                if LocalPlayer():HasWeapon(wep) and hasValidAccess then
                    return -- Ничего не делаем, если оружие уже есть
                elseif hasValidAccess then
                    price = 'give'
                end
                
                netstream.Start('NextRP::BuyOrGiveWeapon', wep, price, nil)
            end)

        pnl:SetTall(64 + 2)
        contents:Add(pnl)
    end
end

local function VendorMenu(tWeapons)
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Галактический аукцион')
    frame:SetSize(700, 700)
    frame:MakePopup()
    frame:Center()
    frame:ShowSettingsButton(false)

    local info = vgui.Create('PawsUI.Panel', frame)
        :Stick(FILL)

    local scrollPanel = TDLib('DScrollPanel', frame)
        :Stick(FILL, 2)

    local reciveAllButton = TDLib('DButton', scrollPanel)
        :ClearPaint()
        :SetRemove(scrollPanel:GetParent())
        :Stick(TOP, 3)
        :Background(NextRP.Style.Theme.Background)
        :FadeHover(NextRP.Style.Theme.Accent)
        :Text('Взять все купленное вооружение', 'font_sans_21')
        :On('DoClick', function()
            PrintTable(tWeapons)
            netstream.Start('NextRP::BuyOrGiveWeapon', util.TableToJSON(tWeapons), 'giveall')
        end)

    reciveAllButton:SetTall(64 + 2)

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

    for k, v in pairs(cTable) do
        generateWeapons(scrollPanel, tWeapons, v, k)
    end
end

netstream.Hook('NextRP::WepVendorStart', function(pPlayer, tWeapons)
    if tWeapons == 'empty' then 
        tWeapons = {} 
    else 
        tWeapons = util.JSONToTable(tWeapons) 
    end
    VendorMenu(tWeapons)
end)
