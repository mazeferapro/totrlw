local theme = NextRP.Style.Theme

-- == Вспомогательная функция для надежного получения флага ==
local function GetPlyFlag(ply)
    if not IsValid(ply) then return "" end
    
    -- Список возможных ключей, под которыми может быть спрятан флаг
    local keysToCheck = {
        "Flag", "flag", "JobFlag", "jobFlag", "CharFlag", "charFlag", 
        "RankFlag", "rankFlag", "ActiveFlag", "UserFlag"
    }

    for _, key in ipairs(keysToCheck) do
        -- 1. Проверяем NetVars (наиболее вероятно для NextRP)
        if ply.GetNetVar then
            local val = ply:GetNetVar(key)
            if val and val ~= "" then return val end
        end
        
        -- 2. Проверяем NWString
        local val = ply:GetNWString(key)
        if val and val ~= "" then return val end
    end
    
    return ""
end
-- ==========================================================

-- Функция получения списка классов оружия из профессии
local function GetAvailableWeapons()
    local ply = LocalPlayer()
    if not IsValid(ply) then return {} end
    
    local jobData = ply:getJobTable()
    if not jobData then return {} end
    
    -- Получаем ранг
    local myRank = ply:GetNWString("Rank")
    if (not myRank or myRank == "") and ply.GetNetVar then myRank = ply:GetNetVar("Rank") end
    if (not myRank or myRank == "") and jobData.default_rank then myRank = jobData.default_rank end

    -- Получаем флаг (исправленным методом)
    local myFlag = GetPlyFlag(ply)

    -- Дебаг (чтобы вы видели в консоли, что происходит)
    print("[Ammo Debug] Работа: " .. (jobData.Name or "Unknown"))
    print("[Ammo Debug] Ранг: " .. tostring(myRank))
    print("[Ammo Debug] Флаг: '" .. tostring(myFlag) .. "'")

    local weaponSet = {}
    
    -- 1. Загружаем оружие РАНГА
    if jobData.ranks and jobData.ranks[myRank] and jobData.ranks[myRank].weapon and jobData.ranks[myRank].weapon.ammunition then
         for _, v in pairs(jobData.ranks[myRank].weapon.ammunition) do 
            weaponSet[v] = true 
         end
    end

    -- 2. Загружаем оружие ФЛАГА
    if myFlag ~= "" and jobData.flags then
        local flagData = jobData.flags[myFlag]
        
        -- Если по ключу не нашли, ищем по ID (для случаев, когда ключ 'Медик', а флаг 'MED')
        if not flagData then
            for k, v in pairs(jobData.flags) do
                if v.id == myFlag then 
                    flagData = v 
                    break 
                end
            end
        end
        
        if flagData and flagData.weapon and flagData.weapon.ammunition then
            print("[Ammo Debug] Конфиг флага найден! Добавляем оружие...")
            
            -- ВАЖНО: Если в конфиге работы стоит replaceWeapon = true, то очищаем оружие ранга
            if flagData.replaceWeapon then
                print("[Ammo Debug] Флаг заменяет оружие ранга (replaceWeapon=true).")
                weaponSet = {}
            end
            
            for _, v in pairs(flagData.weapon.ammunition) do 
                weaponSet[v] = true 
            end
        else
             print("[Ammo Debug] Флаг есть, но настройки для него в job.flags не найдены.")
        end
    end
    
    -- Преобразуем таблицу обратно в список
    local res = {}
    for k,v in pairs(weaponSet) do table.insert(res, k) end
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
    print("----------------------------------------------------------------")
    print("[Ammo Debug] Генерация меню (Всего: " .. #weaponList .. ")...")
    
    for _, wepClass in pairs(weaponList) do
        local itemData = FindItemByWeaponClass(wepClass)
        if not itemData then 
            -- print("[Ammo Debug] Предмет не найден в инвентаре для класса: " .. wepClass)
            continue 
        end
        
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

        local reciveButton = TDLib('DButton', pnl)
            :ClearPaint()
            :Stick(FILL, 2)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Accent)
            :LinedCorners()
            :On('Think', function(s) s:Text('Получить', 'font_sans_21') end)
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
    print("----------------------------------------------------------------")
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
    print("[Ammo Debug] Открытие меню...")
    local weaponList = GetAvailableWeapons()
    
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Арсенал снабжения')
    frame:SetSize(1000, 600)
    frame:MakePopup()
    frame:Center()
    frame:ShowSettingsButton(false)

    local leftpanel = vgui.Create('PawsUI.Panel', frame)
        :Stick(RIGHT)
        :Background(Color(53 + 15, 57 + 15, 68 + 15, 100))
        :DivWide(3)

    local supplyTitle = vgui.Create('PawsUI.Panel', leftpanel):Stick(TOP, 2):Text('Снабжение:')
    local supplyPanel = vgui.Create('PawsUI.Panel', leftpanel)
        :ClearPaint():Stick(TOP, 2):Background(NextRP.Style.Theme.Background)
        :On('Paint', function(s, w, h)
            local supply = GetGlobalInt("NextRP_SupplyPoints", 0)
            local maxSupply = NextRP.Ammunition.Config.MaxSupply or 10000
            makeBar(supply, 0, 0, w, h, Color(100, 200, 255), 0, maxSupply)
            draw.SimpleText(supply, "PawsUI.Text.Small", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

    local scrollPanel = TDLib('DScrollPanel', frame):Stick(FILL, 2)
    scrollPanel.EntIndex = entIndex
    
    local scrollPanelBar = scrollPanel:GetVBar()
    scrollPanelBar:TDLib():ClearPaint():Background(theme.DarkScroll)
    scrollPanelBar.btnUp:TDLib():ClearPaint():Background(theme.DarkScroll):CircleClick()
    scrollPanelBar.btnDown:TDLib():ClearPaint():Background(theme.DarkScroll):CircleClick()
    scrollPanelBar.btnGrip:TDLib():ClearPaint():Background(theme.Scroll):CircleClick()

    generateWeapons(scrollPanel, weaponList)
end

netstream.Hook('NextRP::OpenAmmunitionMenu', function(data)
    Ammunition(data and data.entIndex)
end)