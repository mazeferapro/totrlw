-- ============================================================================
-- cl_ammunition.lua - С секцией боеприпасов
-- ============================================================================

local theme = NextRP.Style.Theme

-- == Получаем флаги из nrp_charflags через GetNVar ==
local function GetPlyFlags(ply)
    if not IsValid(ply) then return {} end
    
    local flags = ply:GetNVar('nrp_charflags')
    if flags and istable(flags) then
        return flags
    end
    
    return {}
end

-- Получаем ранг из nrp_rankid
local function GetPlyRank(ply, jobData)
    if not IsValid(ply) then return "" end
    
    local rank = ply:GetNVar('nrp_rankid')
    if rank and rank ~= "" and rank ~= false then
        return rank
    end
    
    rank = ply:GetNWString("Rank")
    if rank and rank ~= "" then
        return rank
    end
    
    if jobData and jobData.default_rank then
        return jobData.default_rank
    end
    
    return ""
end

-- Функция получения списка классов оружия из профессии
local function GetAvailableWeapons()
    local ply = LocalPlayer()
    if not IsValid(ply) then return {} end
    
    local jobData = ply:getJobTable()
    if not jobData then return {} end
    
    local myRank = GetPlyRank(ply, jobData)
    local myFlags = GetPlyFlags(ply)

    local weaponSet = {}
    local anyFlagReplacesWeapon = false
    
    -- 1. Загружаем оружие РАНГА
    if jobData.ranks and jobData.ranks[myRank] and jobData.ranks[myRank].weapon and jobData.ranks[myRank].weapon.ammunition then
        for _, v in pairs(jobData.ranks[myRank].weapon.ammunition) do 
            weaponSet[v] = true 
        end
    end

    -- 2. Загружаем оружие для ВСЕХ активных флагов
    if jobData.flags and table.Count(myFlags) > 0 then
        for flagKey, flagActive in pairs(myFlags) do
            if not flagActive then continue end
            
            local flagData = nil
            
            if jobData.flags[flagKey] then
                flagData = jobData.flags[flagKey]
            else
                for k, v in pairs(jobData.flags) do
                    if v.id == flagKey then
                        flagData = v
                        break
                    end
                end
            end
            
            if flagData then
                if flagData.replaceWeapon then
                    anyFlagReplacesWeapon = true
                end
                
                if flagData.weapon and flagData.weapon.ammunition then
                    for _, v in pairs(flagData.weapon.ammunition) do 
                        weaponSet[v] = true 
                    end
                end
            end
        end
    end
    
    -- Если хотя бы один флаг заменяет оружие
    if anyFlagReplacesWeapon then
        weaponSet = {}
        
        for flagKey, flagActive in pairs(myFlags) do
            if not flagActive then continue end
            
            local flagData = jobData.flags[flagKey]
            if not flagData then
                for k, v in pairs(jobData.flags) do
                    if v.id == flagKey then flagData = v break end
                end
            end
            
            if flagData and flagData.weapon and flagData.weapon.ammunition then
                for _, v in pairs(flagData.weapon.ammunition) do 
                    weaponSet[v] = true 
                end
            end
        end
    end
    
    local res = {}
    for k, v in pairs(weaponSet) do 
        table.insert(res, k) 
    end
    
    return res
end

-- Функция поиска предмета в инвентаре по классу оружия
local function FindItemByWeaponClass(targetClass)
    if not NextRP.Inventory or not NextRP.Inventory.Items then return nil end
    if not targetClass then return nil end
    
    targetClass = string.Trim(targetClass)
    
    for id, item in pairs(NextRP.Inventory.Items) do
        if item.weaponClass then
            if string.lower(string.Trim(item.weaponClass)) == string.lower(targetClass) then
                return item
            end
        end
    end
    
    return nil
end

-- Генерация секции оружия
local function generateWeapons(scrollPanel, weaponList)
    local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
        :Stick(TOP, 2)
        :ClearPaint()
        :On('OnToggle', function(self)
            if self:GetExpanded() then
                self.Header:TDLib():ClearPaint():Background(theme.Accent)
            else
                self.Header:TDLib():ClearPaint():Background(theme.DarkBlue)
            end
        end)

    DCategory.Header:TDLib():ClearPaint():Text('Доступное снаряжение', 'font_sans_21')

    if DCategory:GetExpanded() then DCategory.Header:TDLib():Background(theme.Accent)
    else DCategory.Header:TDLib():Background(theme.DarkBlue) end

    DCategory.Header:SetTall(25)

    local contents = vgui.Create('DPanelList', DCategory)
    contents:SetPadding(0)
    contents:SetSpacing(4)
    contents:EnableVerticalScrollbar(true)
    DCategory:SetContents(contents)

    local foundCount = 0
    
    for _, wepClass in pairs(weaponList) do
        local itemData = FindItemByWeaponClass(wepClass)
        if not itemData then continue end
        
        foundCount = foundCount + 1
        local pnl = vgui.Create('PawsUI.Panel')
        pnl:Background(Color(53 + 15, 57 + 15, 68 + 15, 100))
        pnl:SetTall(64 + 2)

        local icon = vgui.Create('PawsUI.Panel', pnl)
        icon:Stick(LEFT, 2)
        if itemData.icon then
            if string.EndsWith(itemData.icon, ".mdl") then
                local modelIcon = vgui.Create("SpawnIcon", icon)
                modelIcon:SetModel(itemData.icon)
                modelIcon:Dock(FILL)
            else
                local wepMat = Material(itemData.icon, 'smooth')
                PAW_MODULE('lib'):Download('nw/noicon.png', 'https://i.imgur.com/yaqb1ND.png', function(dPath)
                    local mat = Material(dPath, 'smooth')
                    if wepMat:IsError() then icon:Material(mat) else icon:Material(wepMat) end
                end)
            end
        end
        icon:SetWide(64)

        local title = vgui.Create('PawsUI.Panel', pnl)
        title:Stick(TOP, 2)
        title:On('Paint', function(s, w, h)
            draw.DrawText(itemData.name, 'font_sans_21', 1, 5, NextRP.Style.Theme.Text, nil, TEXT_ALIGN_LEFT)
            local price = itemData.supplyPrice or 0
            draw.DrawText(price .. " ОС", 'font_sans_18', 1, 25, Color(255, 200, 50), nil, TEXT_ALIGN_LEFT)
        end)

		local price = itemData.supplyPrice or 0

        local reciveButton = TDLib('DButton', pnl)
            :ClearPaint()
            :Stick(FILL, 2)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Accent)
            :LinedCorners()
            :On('Think', function(s) s:Text('Получить ' .. '( - ' .. price .. ' cнабжения )', 'font_sans_21') end)
            :On('DoClick', function()
                netstream.Start('NextRP::Ammunition::Buy', {
                    itemID = itemData.id,
                    entIndex = scrollPanel.EntIndex 
                })
            end)
        contents:AddItem(pnl)
    end
    
    if foundCount == 0 then
        local lbl = vgui.Create("DLabel")
        lbl:SetText( #weaponList == 0 and "Список оружия пуст." or "Нет предметов в инвентаре для этого оружия.")
        lbl:SetTextColor(Color(255, 100, 100))
        lbl:SetFont("font_sans_21")
        lbl:SizeToContents()
        lbl:SetContentAlignment(5)
        contents:AddItem(lbl)
    end
end

-- ============================================================================
-- ГЕНЕРАЦИЯ СЕКЦИИ БОЕПРИПАСОВ
-- ============================================================================
local function generateAmmoSection(scrollPanel)
    local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
        :Stick(TOP, 2)
        :ClearPaint()
        :On('OnToggle', function(self)
            if self:GetExpanded() then
                self.Header:TDLib():ClearPaint():Background(Color(200, 150, 50))
            else
                self.Header:TDLib():ClearPaint():Background(Color(100, 80, 30))
            end
        end)

    DCategory.Header:TDLib():ClearPaint():Text('Расходники', 'font_sans_21')
    
    if DCategory:GetExpanded() then 
        DCategory.Header:TDLib():Background(Color(200, 150, 50))
    else 
        DCategory.Header:TDLib():Background(Color(100, 80, 30)) 
    end

    DCategory.Header:SetTall(25)

    local contents = vgui.Create('DPanelList', DCategory)
    contents:SetPadding(0)
    contents:SetSpacing(4)
    contents:EnableVerticalScrollbar(true)
    DCategory:SetContents(contents)

    -- Список боеприпасов для отображения
    local ammoItems = {
        "ammo_tibanna",   -- Тибан (основные патроны)
        "ammo_rockets",   -- Ракеты
        "bacta_inj",       -- SMG патроны
        "ammo_ar2",       -- Тяжёлые патроны
        "ammo_grenades",  -- Гранаты
    }
    
    local foundCount = 0
    
    for _, itemID in pairs(ammoItems) do
        local itemData = NextRP.Inventory:GetItemData(itemID)
        if not itemData then continue end
        
        foundCount = foundCount + 1
        
        local pnl = vgui.Create('PawsUI.Panel')
        pnl:Background(Color(60, 50, 40, 150))
        pnl:SetTall(64 + 2)

        -- Иконка
        local icon = vgui.Create('PawsUI.Panel', pnl)
        icon:Stick(LEFT, 2)
        if itemData.icon then
            local wepMat = Material(itemData.icon, 'smooth')
            if not wepMat:IsError() then
                icon:Material(wepMat)
            end
        end
        icon:SetWide(64)

        -- Название и цена
        local title = vgui.Create('PawsUI.Panel', pnl)
        title:Stick(TOP, 2)
        title:On('Paint', function(s, w, h)
            draw.DrawText(itemData.name, 'font_sans_21', 1, 5, NextRP.Style.Theme.Text, nil, TEXT_ALIGN_LEFT)
            local price = itemData.supplyPrice or 0
            
            -- Показываем количество патронов
            if itemData.ammoAmount then
                draw.DrawText("+" .. itemData.ammoAmount .. " шт", 'font_sans_16', w - 10, 15, Color(150, 255, 150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end)

		local price = itemData.supplyPrice or 0
		


        -- Кнопка получить
        local reciveButton = TDLib('DButton', pnl)
            :ClearPaint()
            :Stick(FILL, 2)
            :Background(Color(80, 60, 40))
            :FadeHover(Color(150, 120, 50))
            :LinedCorners()
            :On('Think', function(s) s:Text('Получить ' .. '( - ' .. price .. ' cнабжения )' , 'font_sans_21') end)
            :On('DoClick', function()
                netstream.Start('NextRP::Ammunition::BuyAmmo', {
                    itemID = itemData.id,
                    entIndex = scrollPanel.EntIndex 
                })
            end)
        contents:AddItem(pnl)
    end
    
    if foundCount == 0 then
        local lbl = vgui.Create("DLabel")
        lbl:SetText("Боеприпасы не настроены")
        lbl:SetTextColor(Color(255, 150, 100))
        lbl:SetFont("font_sans_21")
        lbl:SizeToContents()
        lbl:SetContentAlignment(5)
        contents:AddItem(lbl)
    end
end

local function makeBar(val, x, y, w, h, col, angle, max)
    local function polyRect(x,y,w,h,angle,rotate,color)
        local rect = { { x = x, y = y + h }, { x = x + rotate, y = y }, { x = x + w + angle, y = y }, { x = x + w, y = y + h } }
        surface.SetDrawColor( color )
        draw.NoTexture()
        surface.DrawPoly( rect )
    end
    polyRect(x, y, w, h, angle, angle, Color(72,72,72,135))
    polyRect(x, y, math.Clamp(val, 0, max or 100)/(max or 100) * w, h, angle, angle, col)
end

local function Ammunition(entIndex)
    local weaponList = GetAvailableWeapons()
    
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Арсенал снабжения')
    frame:SetSize(1000, 650)
    frame:MakePopup()
    frame:Center()
    frame:ShowSettingsButton(false)

    -- Правая панель со статистикой
    local leftpanel = vgui.Create('PawsUI.Panel', frame)
        :Stick(RIGHT)
        :Background(Color(53 + 15, 57 + 15, 68 + 15, 100))
        :DivWide(3)

    local supplyTitle = vgui.Create('PawsUI.Panel', leftpanel):Stick(TOP, 2):Text('Снабжение:')
    local supplyPanel = vgui.Create('PawsUI.Panel', leftpanel)
        :ClearPaint():Stick(TOP, 2):Background(NextRP.Style.Theme.Background)
        :On('Paint', function(s, w, h)
            local supply = GetGlobalInt("NextRP_SupplyPoints", 0)
            local maxSupply = NextRP.Ammunition.Config.MaxSupply or 100000
            makeBar(supply, 0, 0, w, h, Color(100, 200, 255), 0, maxSupply)
            draw.SimpleText(supply .. " / " .. maxSupply, "PawsUI.Text.Small", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)
    supplyPanel:SetTall(30)

    local title = vgui.Create('PawsUI.Panel', leftpanel):Stick(TOP, 2):Text('Нагрузка:')
    local weightpanel = vgui.Create('PawsUI.Panel', leftpanel)
        :ClearPaint():Stick(TOP, 2):Background(NextRP.Style.Theme.Background)
            :On('Paint', function(s, w, h)
                local weight = LocalPlayer():GetNWInt('picked', 0)
                makeBar(weight, 0, 0, w, h, color_white, 0)
                if weight >= 50 then makeBar(weight-50, 0, 0, w, h, Color(255,0,0), 0) end
            end)
    weightpanel:SetTall(30)
    
    -- Информация о патронах игрока
    local ammoTitle = vgui.Create('PawsUI.Panel', leftpanel):Stick(TOP, 2):Text('Ваши патроны:')
    local ammoInfoPanel = vgui.Create('PawsUI.Panel', leftpanel)
        :ClearPaint():Stick(TOP, 2):Background(Color(40, 40, 40, 150))
        :On('Paint', function(s, w, h)
            local ply = LocalPlayer()
            local y = 5
            
            -- Показываем патроны разных типов
            local ammoTypes = {
                {name = "Pulse", type = "pulse_ammo"},
                {name = "SMG", type = "smg1"},
                {name = "AR2", type = "ar2"},
                {name = "Rockets", type = "RPG_Round"},
            }
            
            for _, ammo in ipairs(ammoTypes) do
                local count = ply:GetAmmoCount(ammo.type)
                local col = count > 0 and Color(150, 255, 150) or Color(150, 150, 150)
                draw.SimpleText(ammo.name .. ": " .. count, "font_sans_16", 10, y, col, TEXT_ALIGN_LEFT)
                y = y + 18
            end
        end)
    ammoInfoPanel:SetTall(80)

    -- Основной скролл-панель
    local scrollPanel = TDLib('DScrollPanel', frame):Stick(FILL, 2)
    scrollPanel.EntIndex = entIndex
    
    local scrollPanelBar = scrollPanel:GetVBar()
    scrollPanelBar:TDLib():ClearPaint():Background(theme.DarkScroll)
    scrollPanelBar.btnUp:TDLib():ClearPaint():Background(theme.DarkScroll):CircleClick()
    scrollPanelBar.btnDown:TDLib():ClearPaint():Background(theme.DarkScroll):CircleClick()
    scrollPanelBar.btnGrip:TDLib():ClearPaint():Background(theme.Scroll):CircleClick()

    -- Генерируем секции
    generateWeapons(scrollPanel, weaponList)
    generateAmmoSection(scrollPanel)
end

netstream.Hook('NextRP::OpenAmmunitionMenu', function(data)
    Ammunition(data and data.entIndex)
end)

-- Debug команда
concommand.Add("ammo_debug_flag", function()
    local ply = LocalPlayer()
    print("=== AMMUNITION DEBUG ===")
    
    local flags = ply:GetNVar('nrp_charflags')
    if flags and istable(flags) then
        if table.Count(flags) > 0 then
            for k, v in pairs(flags) do
                print("  ['" .. tostring(k) .. "'] = " .. tostring(v))
            end
        else
            print("  (пустая таблица)")
        end
    else
        print("  = " .. tostring(flags))
    end
    
    print("GetNVar('nrp_rankid'): '" .. tostring(ply:GetNVar('nrp_rankid')) .. "'")
    print("========================")
end)