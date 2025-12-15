--[[--
Клиентская часть модуля прогрессии персонажей
Содержит интерфейс для отображения прогресса, уровней и талантов
]]--
-- @module NextRP.Progression

NextRP.Progression = NextRP.Progression or {}

-- Локальные переменные для хранения данных о прогрессии игрока
NextRP.Progression.PlayerData = {
    level = 1,
    xp = 0,
    xpRequired = 100,
    talentPoints = 0,
    talents = {}
}

-- Дерево талантов для текущей профессии
NextRP.Progression.TalentTree = nil

-- Константы для интерфейса
local TALENT_ICON_SIZE = 64
local TALENT_PADDING = 20
local TALENT_CONNECTION_WIDTH = 4

-- Сетевые обработчики для получения данных с сервера
netstream.Hook('NextRP::ProgressionData', function(data)
    NextRP.Progression.PlayerData.level = data.level
    NextRP.Progression.PlayerData.xp = data.xp
    NextRP.Progression.PlayerData.xpRequired = data.xpRequired
    NextRP.Progression.PlayerData.talentPoints = data.talentPoints

    -- Обновляем HUD
    hook.Run('NextRP::ProgressionDataUpdated', data)
end)

netstream.Hook('NextRP::XPUpdate', function(data)
    NextRP.Progression.PlayerData.xp = data.xp
    NextRP.Progression.PlayerData.xpRequired = data.xpRequired

    -- Эффект получения опыта на HUD
    hook.Run('NextRP::XPGained', data.xp)
end)

netstream.Hook('NextRP::LevelUp', function(data)
    -- Старые значения для анимации
    local oldLevel = NextRP.Progression.PlayerData.level

    -- Обновляем данные
    NextRP.Progression.PlayerData.level = data.level
    NextRP.Progression.PlayerData.xp = data.xp
    NextRP.Progression.PlayerData.xpRequired = data.xpRequired
    NextRP.Progression.PlayerData.talentPoints = data.talentPoints

    -- Эффект повышения уровня
    hook.Run('NextRP::LevelUpEffect', oldLevel, data.level)

    -- Уведомление о повышении уровня
    surface.PlaySound("garrysmod/content_downloaded.wav")

    -- Если есть очки талантов, уведомляем о возможности их потратить
    if data.talentPoints > 0 then
        NextRP:Location(5, "У вас есть " .. data.talentPoints .. " очков талантов! Используйте команду /talents чтобы открыть дерево талантов.")
    end
end)

netstream.Hook('NextRP::CharacterTalents', function(talents)
    NextRP.Progression.PlayerData.talents = talents

    -- Обновляем интерфейс талантов, если он открыт
    if IsValid(NextRP.Progression.TalentPanel) then
        NextRP.Progression.TalentPanel:UpdateTalents(talents)
    end
end)

netstream.Hook('NextRP::TalentAdded', function(data)
    -- Обновляем локальные данные
    NextRP.Progression.PlayerData.talents[data.talent] = data.rank
    NextRP.Progression.PlayerData.talentPoints = data.talentPoints

    -- Эффект изучения таланта
    hook.Run('NextRP::TalentLearned', data.talent, data.rank)

    -- Уведомление
    surface.PlaySound("garrysmod/save_load1.wav")

    -- Обновляем интерфейс талантов, если он открыт
    if IsValid(NextRP.Progression.TalentPanel) then
        NextRP.Progression.TalentPanel:UpdateTalents(NextRP.Progression.PlayerData.talents)
    end
end)

netstream.Hook('NextRP::TalentTreeData', function(data)
    NextRP.Progression.TalentTree = data.tree

    -- Если интерфейс талантов уже открыт, обновляем его
    if IsValid(NextRP.Progression.TalentPanel) then
        NextRP.Progression.TalentPanel:SetTalentTree(data.tree, data.talents)
    end
end)

netstream.Hook('NextRP::OpenTalentTree', function()
    -- Запрашиваем дерево талантов с сервера
    netstream.Start('NextRP::RequestTalentTree')

    -- Открываем панель талантов
    NextRP.Progression:OpenTalentPanel()
end)

-- Функция для открытия панели дерева талантов
function NextRP.Progression:OpenTalentPanel()
    if IsValid(self.TalentPanel) then
        self.TalentPanel:Remove()
    end

    -- Создаем основную панель
    local panel = vgui.Create('PawsUI.Frame')
    panel:SetTitle('Дерево талантов')
    panel:SetSize(900, 700)
    panel:Center()
    panel:MakePopup()
    panel:ShowSettingsButton(false)

    -- Сохраняем ссылку на панель
    self.TalentPanel = panel

    -- Информационная панель вверху

        local infoPanel = vgui.Create('PawsUI.Panel', panel)
        infoPanel:Dock(TOP)
        infoPanel:SetTall(80)
        infoPanel:DockMargin(5, 5, 5, 5)

        -- Отображаем информацию о персонаже
        infoPanel.Paint = function(s, w, h)
            -- Фон
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)

            -- Уровень
            draw.SimpleText("Уровень: " .. self.PlayerData.level, "font_sans_24", 20, 15, NextRP.Style.Theme.Text)

            -- Опыт
            draw.SimpleText("Опыт: " .. self.PlayerData.xp .. " / " .. self.PlayerData.xpRequired, "font_sans_18", 20, 45, NextRP.Style.Theme.Text)

            -- Прогресс-бар опыта
            local barWidth = w - 40
            local progress = self.PlayerData.xp / self.PlayerData.xpRequired

            draw.RoundedBox(4, 20, 70, barWidth, 5, NextRP.Style.Theme.DarkGray)
            draw.RoundedBox(4, 20, 70, barWidth * progress, 5, NextRP.Style.Theme.Accent)

            -- Очки талантов
            draw.SimpleText("Очки талантов: " .. self.PlayerData.talentPoints, "font_sans_24", w - 250, 15, NextRP.Style.Theme.HightlightText)
        end

    -- Основная панель для отображения дерева талантов
    local talentTreeScroll = vgui.Create('PawsUI.ScrollPanel', panel)
    talentTreeScroll:Dock(FILL)
    talentTreeScroll:DockMargin(5, 5, 5, 5)

    local talentTreeCanvas = vgui.Create('DPanel', talentTreeScroll)
    talentTreeCanvas:SetSize(2000, 1500)  -- Большой размер для размещения всех талантов
    talentTreeCanvas:SetPos(0, 0)

    -- Отрисовка дерева талантов
    talentTreeCanvas.Paint = function(s, w, h)
        -- Фон
        draw.RoundedBox(0, 0, 0, w, h, NextRP.Style.Theme.Background)

        -- Рисуем соединительные линии между талантами
        if self.TalentTree and self.TalentTree.talents then
            surface.SetDrawColor(NextRP.Style.Theme.Accent)

            for talentID, talent in pairs(self.TalentTree.talents) do
                if talent.prerequisites then
                    local talentPos = talent.position or {x = 0, y = 0}

                    for _, prereqID in ipairs(talent.prerequisites) do
                        local prereq = self.TalentTree.talents[prereqID]
                        if prereq then
                            local prereqPos = prereq.position or {x = 0, y = 0}

                            -- Рисуем линию от предпосылки к таланту
                            if self.PlayerData.talents[prereqID] then
                                -- Активная линия
                                surface.SetDrawColor(NextRP.Style.Theme.Green)
                            else
                                -- Неактивная линия
                                surface.SetDrawColor(NextRP.Style.Theme.DarkGray)
                            end

                            surface.DrawLine(
                                talentPos.x * (TALENT_ICON_SIZE + TALENT_PADDING) + TALENT_ICON_SIZE/2,
                                talentPos.y * (TALENT_ICON_SIZE + TALENT_PADDING) + TALENT_ICON_SIZE/2,
                                prereqPos.x * (TALENT_ICON_SIZE + TALENT_PADDING) + TALENT_ICON_SIZE/2,
                                prereqPos.y * (TALENT_ICON_SIZE + TALENT_PADDING) + TALENT_ICON_SIZE/2
                            )
                        end
                    end
                end
            end
        end
    end

    -- Функция для обновления дерева талантов
    function panel:SetTalentTree(tree, talents)
        NextRP.Progression.TalentTree = tree
        NextRP.Progression.PlayerData.talents = talents

        -- Очищаем существующие элементы
        for _, child in pairs(talentTreeCanvas:GetChildren()) do
            child:Remove()
        end

        -- Если дерево не загружено, показываем сообщение
        if not tree or not tree.talents then
            local errorLabel = vgui.Create('DLabel', talentTreeCanvas)
            errorLabel:SetText('Дерево талантов не загружено. Пожалуйста, попробуйте снова позже.')
            errorLabel:SetFont('font_sans_24')
            errorLabel:SetTextColor(NextRP.Style.Theme.Red)
            errorLabel:SizeToContents()
            errorLabel:Center()
            return
        end

        -- Определяем позиции для каждого таланта, если они не заданы
        local usedPositions = {}
        local nextPos = {x = 1, y = 1}

        for talentID, talent in pairs(tree.talents) do
            if not talent.position then
                -- Находим свободную позицию
                while usedPositions[nextPos.x .. "," .. nextPos.y] do
                    nextPos.x = nextPos.x + 1
                    if nextPos.x > 10 then
                        nextPos.x = 1
                        nextPos.y = nextPos.y + 1
                    end
                end

                talent.position = {x = nextPos.x, y = nextPos.y}
                usedPositions[nextPos.x .. "," .. nextPos.y] = true

                -- Перемещаем на следующую позицию
                nextPos.x = nextPos.x + 1
                if nextPos.x > 10 then
                    nextPos.x = 1
                    nextPos.y = nextPos.y + 1
                end
            else
                usedPositions[talent.position.x .. "," .. talent.position.y] = true
            end
        end

        -- Создаем иконки для каждого таланта
        for talentID, talent in pairs(tree.talents) do
            local icon = vgui.Create('DButton', talentTreeCanvas)
            icon:SetSize(TALENT_ICON_SIZE, TALENT_ICON_SIZE)
            icon:SetPos(
                talent.position.x * (TALENT_ICON_SIZE + TALENT_PADDING),
                talent.position.y * (TALENT_ICON_SIZE + TALENT_PADDING)
            )
            icon:SetText("")

            -- Иконка таланта
            local talentIcon = talent.icon or "icon16/star.png"
            local talentMaterial = Material(talentIcon, "smooth")

            -- Уровень таланта
            local talentRank = talents[talentID] or 0
            local maxRank = talent.maxRank or 1

            -- Проверяем, доступен ли талант для изучения
            local canLearn = true
            if talent.prerequisites then
                for _, prereqID in ipairs(talent.prerequisites) do
                    if not talents[prereqID] then
                        canLearn = false
                        break
                    end
                end
            end

            -- Отрисовка кнопки таланта
            icon.Paint = function(s, w, h)
                -- Фон
                local bgColor = NextRP.Style.Theme.Primary

                if talentRank > 0 then
                    -- Изученный талант
                    bgColor = NextRP.Style.Theme.Green
                elseif not canLearn then
                    -- Недоступный талант
                    bgColor = NextRP.Style.Theme.DarkGray
                elseif s:IsHovered() and NextRP.Progression.PlayerData.talentPoints > 0 then
                    -- Доступный для изучения талант при наведении
                    bgColor = NextRP.Style.Theme.Accent
                end

                local fillH = (talentRank > 0 and (talentRank / maxRank) * h or h)
                local yPos = h - fillH

                draw.RoundedBox(4, 0, yPos, w, fillH, bgColor)

                -- Рамка
                surface.SetDrawColor(NextRP.Style.Theme.Text)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                -- Иконка
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(talentMaterial)
                surface.DrawTexturedRect(w/2 - 16, h/2 - 16, 32, 32)

                -- Отображение ранга
                if maxRank > 1 then
                    draw.SimpleText(talentRank .. "/" .. maxRank, "font_sans_12", w - 10, h - 5, NextRP.Style.Theme.Text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                end
            end

            -- Действие при нажатии на талант
            icon.DoClick = function()
                if talentRank < maxRank and canLearn and NextRP.Progression.PlayerData.talentPoints > 0 then
                    -- Запрос на изучение таланта
                    netstream.Start('NextRP::LearnTalent', talentID)
                else
                    -- Отображаем подсказку, почему нельзя изучить талант
                    local reason = ""
                    if NextRP.Progression.PlayerData.talentPoints <= 0 then
                        reason = "У вас нет доступных очков талантов."
                    elseif talentRank >= maxRank then
                        reason = "Вы уже изучили максимальный ранг этого таланта."
                    elseif not canLearn then
                        reason = "Вы должны сначала изучить необходимые предпосылки."
                    end

                    surface.PlaySound("buttons/button10.wav")
                    NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Red, reason)
                end
            end

            -- Подсказка при наведении
            icon:SetTooltip(talent.name .. "\n" .. talent.description ..
                (talent.prerequisites and "\n\nТребуется: " .. table.concat(talent.prerequisites, ", ") or "") ..
                (maxRank > 1 and "\n\nТекущий ранг: " .. talentRank .. "/" .. maxRank or ""))
        end
    end

    -- Функция для обновления изученных талантов
    function panel:UpdateTalents(talents)
        NextRP.Progression.PlayerData.talents = talents
        self:SetTalentTree(NextRP.Progression.TalentTree, talents)
    end

    -- Если дерево талантов уже загружено, отображаем его
    if NextRP.Progression.TalentTree then
        panel:SetTalentTree(NextRP.Progression.TalentTree, NextRP.Progression.PlayerData.talents)
    else
        -- Запрашиваем дерево талантов с сервера
        netstream.Start('NextRP::RequestTalentTree')
    end

    return panel
end

-- HUD элементы для отображения прогресса
hook.Add("HUDPaint", "NextRP::ProgressionHUD", function()
    --[[if LocalPlayer():GetNWBool('Dlvl') then return end
    -- Отображаем небольшой индикатор уровня и опыта в левом нижнем углу
    local x = 30
    local y = ScrH() - 200
    local width = 150
    local height = 40


    -- Уровень
    draw.SimpleText("Уровень: " .. NextRP.Progression.PlayerData.level, "font_sans_18", x + 10, y + 5, NextRP.Style.Theme.Text)

    -- Прогресс-бар опыта
    local barWidth = width - 20
    local progress = NextRP.Progression.PlayerData.xp / NextRP.Progression.PlayerData.xpRequired

    draw.RoundedBox(2, x + 10, y + 25, barWidth, 10, NextRP.Style.Theme.DarkGray)
    draw.RoundedBox(2, x + 10, y + 25, barWidth * progress, 10, NextRP.Style.Theme.Accent)

    -- Текст опыта
    local xpText = NextRP.Progression.PlayerData.xp .. "/" .. NextRP.Progression.PlayerData.xpRequired
    local textW, textH = surface.GetTextSize(xpText)
    draw.SimpleText(xpText, "font_sans_12", x + 10 + barWidth/2, y + 25 + 5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)]]--
end)

-- Эффекты при получении опыта и повышении уровня
local xpNotifications = {}

-- Добавление уведомления о получении опыта
hook.Add("NextRP::XPGained", "ShowXPNotification", function(amount)
    -- Создаем новое уведомление об опыте
    table.insert(xpNotifications, {
        amount = amount,
        time = CurTime(),
        alpha = 255
    })

    -- Удаляем старые уведомления
    if #xpNotifications > 5 then
        table.remove(xpNotifications, 1)
    end
end)

-- Отображение уведомлений о получении опыта
hook.Add("HUDPaint", "DrawXPNotifications", function()
    local x = 10
    local y = ScrH() - 60

    for i, notification in ipairs(xpNotifications) do
        -- Анимация исчезновения
        local alpha = 255
        local lifetime = CurTime() - notification.time

        if lifetime > 2 then
            alpha = math.max(0, 255 - (lifetime - 2) * 255)
            notification.alpha = alpha
        end

        -- Если уведомление полностью исчезло, удаляем его
        if alpha <= 0 then
            table.remove(xpNotifications, i)
            continue
        end

        -- Отображаем уведомление
        draw.SimpleText("+" .. notification.amount .. " XP", "font_sans_18", x, y - i * 20, ColorAlpha(NextRP.Style.Theme.Accent, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end)

-- Анимация повышения уровня
hook.Add("NextRP::LevelUpEffect", "ShowLevelUpAnimation", function(oldLevel, newLevel)
    -- Создаем эффект повышения уровня
    local levelEffect = {
        startTime = CurTime(),
        oldLevel = oldLevel,
        newLevel = newLevel,
        duration = 3, -- Длительность анимации в секундах
        active = true
    }

    -- Отрисовка эффекта
    hook.Add("HUDPaint", "LevelUpAnimation", function()
        if not levelEffect.active then return end

        local elapsed = CurTime() - levelEffect.startTime
        if elapsed > levelEffect.duration then
            levelEffect.active = false
            hook.Remove("HUDPaint", "LevelUpAnimation")
            return
        end

        local progress = elapsed / levelEffect.duration
        local alpha = 255

        if progress > 0.7 then
            alpha = math.max(0, 255 * (1 - ((progress - 0.7) / 0.3)))
        end

        -- Центр экрана
        local centerX = ScrW() / 2
        local centerY = ScrH() / 2

        -- Размер и положение текста
        local scale = 1 + math.sin(progress * math.pi) * 0.5
        local yOffset = -50 * progress

    end)
end)

-- Эффект изучения нового таланта
hook.Add("NextRP::TalentLearned", "ShowTalentLearnedEffect", function(talentID, rank)
    -- Получаем информацию о таланте
    local talent = NextRP.Progression.TalentTree and NextRP.Progression.TalentTree.talents[talentID]
    if not talent then return end

    -- Создаем эффект изучения таланта
    local talentEffect = {
        startTime = CurTime(),
        name = talent.name,
        rank = rank,
        maxRank = talent.maxRank or 1,
        icon = talent.icon or "icon16/star.png",
        duration = 2.5, -- Длительность анимации в секундах
        active = true
    }

    -- Отрисовка эффекта
    hook.Add("HUDPaint", "TalentLearnedAnimation", function()
        if not talentEffect.active then return end

        local elapsed = CurTime() - talentEffect.startTime
        if elapsed > talentEffect.duration then
            talentEffect.active = false
            hook.Remove("HUDPaint", "TalentLearnedAnimation")
            return
        end

        local progress = elapsed / talentEffect.duration
        local alpha = 255

        if progress > 0.7 then
            alpha = math.max(0, 255 * (1 - ((progress - 0.7) / 0.3)))
        end

        -- Правый верхний угол экрана
        local x = ScrW() - 300
        local y = 100

        -- Фон уведомления
        draw.RoundedBox(8, x, y, 280, 80, ColorAlpha(NextRP.Style.Theme.Primary, alpha * 0.8))
        draw.RoundedBox(8, x, y, 280, 30, ColorAlpha(NextRP.Style.Theme.Accent, alpha * 0.8))

        -- Заголовок
        draw.SimpleText("Изучен новый талант!", "font_sans_18", x + 140, y + 15, ColorAlpha(NextRP.Style.Theme.Text, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Иконка таланта
        local talentMaterial = Material(talentEffect.icon, "smooth")
        surface.SetDrawColor(ColorAlpha(color_white, alpha))
        surface.SetMaterial(talentMaterial)
        surface.DrawTexturedRect(x + 20, y + 40, 32, 32)

        -- Название таланта
        draw.SimpleText(talentEffect.name, "font_sans_18", x + 60, y + 45, ColorAlpha(NextRP.Style.Theme.Text, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Ранг таланта (если применимо)
        if talentEffect.maxRank > 1 then
            draw.SimpleText("Ранг " .. talentEffect.rank .. "/" .. talentEffect.maxRank, "font_sans_16", x + 260, y + 45, ColorAlpha(NextRP.Style.Theme.HightlightText, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end)
end)

-- Команда для открытия дерева талантов
concommand.Add("nextrp_talents", function()
    netstream.Start('NextRP::RequestTalentTree')
    NextRP.Progression:OpenTalentPanel()
end)

-- Добавляем команду чата
hook.Add("OnPlayerChat", "NextRP::TalentsCommand", function(player, text)
    if string.lower(text) == "/talents" or string.lower(text) == "!talents" then
        if player == LocalPlayer() then
            netstream.Start('NextRP::RequestTalentTree')
            NextRP.Progression:OpenTalentPanel()
        end
        return true
    end
end)



-- Добавляем предмет в контекстное меню
hook.Add("PopulateToolMenu", "NextRP::AddProgressionMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "NextRP", "ProgressionMenu", "Таланты", "", "", function(panel)
        panel:ClearControls()

        -- Информация об уровне
        panel:AddControl("Label", {
            Text = "Уровень: " .. NextRP.Progression.PlayerData.level
        })

        panel:AddControl("Label", {
            Text = "Опыт: " .. NextRP.Progression.PlayerData.xp .. " / " .. NextRP.Progression.PlayerData.xpRequired
        })

        panel:AddControl("Label", {
            Text = "Очки талантов: " .. NextRP.Progression.PlayerData.talentPoints
        })

        -- Кнопка для открытия дерева талантов
        panel:AddControl("Button", {
            Label = "Открыть дерево талантов",
            Command = "nextrp_talents"
        })
    end)
end)

-- Инициализация модуля
hook.Add("InitPostEntity", "NextRP::InitProgressionModule", function()
    -- Запрашиваем данные о прогрессе с сервера
    netstream.Start('NextRP::RequestProgressionData')

    -- Добавляем в справк
end)

local regenNotifications = {}

-- Добавляем сетевой хук для получения уведомлений о восстановлении здоровья
netstream.Hook('NextRP::HealthRegen', function(amount)
    -- Создаем новое уведомление о регенерации
    table.insert(regenNotifications, {
        amount = amount,
        time = CurTime(),
        alpha = 255
    })

    -- Удаляем старые уведомления
    if #regenNotifications > 3 then
        table.remove(regenNotifications, 1)
    end
end)

-- Отображаем уведомления о восстановлении здоровья
hook.Add("HUDPaint", "DrawHealthRegenNotifications", function()
    local x = 10
    local y = ScrH() - 100

    for i, notification in ipairs(regenNotifications) do
        -- Анимация исчезновения
        local alpha = 255
        local lifetime = CurTime() - notification.time

        if lifetime > 1.5 then
            alpha = math.max(0, 255 - (lifetime - 1.5) * 255)
            notification.alpha = alpha
        end

        -- Если уведомление полностью исчезло, удаляем его
        if alpha <= 0 then
            table.remove(regenNotifications, i)
            continue
        end

        -- Отображаем уведомление
        draw.SimpleText("+" .. notification.amount .. " HP", "font_sans_16", x, y - i * 20, ColorAlpha(NextRP.Style.Theme.Green, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end)

-- Добавить в конец файла cl_progression.lua

-- Админ меню для управления прогрессией
NextRP.Progression.AdminPanel = nil

-- Функция для открытия админ панели прогрессии
function NextRP.Progression:OpenAdminPanel()
    if IsValid(self.AdminPanel) then
        self.AdminPanel:Remove()
    end

    -- Создаем основную панель
    local panel = vgui.Create('PawsUI.Frame')
    panel:SetTitle('Админ панель - Управление прогрессией')
    panel:SetSize(1200, 800)
    panel:Center()
    panel:MakePopup()
    panel:ShowSettingsButton(false)

    self.AdminPanel = panel

    -- Левая панель со списком игроков
    local playerListPanel = vgui.Create('PawsUI.Panel', panel)
    playerListPanel:Dock(LEFT)
    playerListPanel:SetWide(350)
    playerListPanel:DockMargin(5, 5, 5, 5)

    -- Панель поиска
    local searchPanel = vgui.Create('DPanel', playerListPanel)
    searchPanel:Dock(TOP)
    searchPanel:SetTall(40)
    searchPanel:DockMargin(5, 5, 5, 5)
    searchPanel.Paint = nil

    local searchEntry = vgui.Create('DTextEntry', searchPanel)
    searchEntry:Dock(FILL)
    searchEntry:SetPlaceholderText("Поиск игрока...")
    searchEntry:DockMargin(0, 8, 0, 8)

    -- Заголовок списка игроков
    local playerListLabel = vgui.Create('DLabel', playerListPanel)
    playerListLabel:SetText('Список игроков онлайн:')
    playerListLabel:SetFont('font_sans_18')
    playerListLabel:SetTextColor(NextRP.Style.Theme.Text)
    playerListLabel:Dock(TOP)
    playerListLabel:SetTall(30)
    playerListLabel:DockMargin(5, 5, 5, 5)

    -- Список игроков
    local playerList = vgui.Create('PawsUI.ScrollPanel', playerListPanel)
    playerList:Dock(FILL)
    playerList:DockMargin(5, 5, 5, 5)

    -- Правая панель с информацией о выбранном игроке
    local infoPanel = vgui.Create('PawsUI.Panel', panel)
    infoPanel:Dock(FILL)
    infoPanel:DockMargin(5, 5, 5, 5)

    -- Переменная для хранения выбранного игрока
    local selectedPlayer = nil
    local playerButtons = {}

    -- Функция для фильтрации игроков
    local function FilterPlayers(searchText)
        searchText = string.lower(searchText or "")

        for _, btn in pairs(playerButtons) do
            if IsValid(btn) and IsValid(btn.Player) then
                local playerName = string.lower(btn.Player:Nick())
                local steamID = string.lower(btn.Player:SteamID())
                local jobName = string.lower(btn.Player:getJobTable().name or "")

                local shouldShow = searchText == "" or
                                 string.find(playerName, searchText) or
                                 string.find(steamID, searchText) or
                                 string.find(jobName, searchText)

                btn:SetVisible(shouldShow)
            end
        end
    end

    -- Обработчик поиска
    searchEntry.OnTextChanged = function(self)
        FilterPlayers(self:GetValue())
    end

    -- Функция для обновления списка игроков
    local function UpdatePlayerList()
        playerList:Clear()
        playerButtons = {}

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                local playerButton = vgui.Create('DButton', playerList)
                playerButton:SetText('')
                playerButton:SetTall(70)
                playerButton:Dock(TOP)
                playerButton:DockMargin(0, 2, 0, 2)
                playerButton.Player = ply

                table.insert(playerButtons, playerButton)

                -- Получаем информацию о персонаже
                local charID = ply:GetNVar('nrp_charid')
                local isAdmin = (charID == -1)
                local char = not isAdmin and ply:CharacterByID(charID) or nil
                local level = char and char.level or (isAdmin and "∞" or 1)
                local jobName = ply:getJobTable().name or "Неизвестно"

                -- Отрисовка кнопки игрока
                playerButton.Paint = function(s, w, h)
                    local bgColor = NextRP.Style.Theme.Primary
                    if s:IsHovered() then
                        bgColor = NextRP.Style.Theme.Accent
                    elseif selectedPlayer == ply then
                        bgColor = NextRP.Style.Theme.Green
                    end

                    -- Особый цвет для администраторов
                    if isAdmin then
                        bgColor = Color(100, 50, 150, 200)
                        if selectedPlayer == ply then
                            bgColor = Color(120, 70, 170, 200)
                        end
                    end

                    draw.RoundedBox(4, 0, 0, w, h, bgColor)

                    -- Статус онлайн (зеленая точка)
                    draw.RoundedBox(10, w - 20, 10, 10, 10, Color(0, 255, 0, 255))

                    -- Имя игрока
                    draw.SimpleText(ply:Nick(), "font_sans_16", 10, 8, NextRP.Style.Theme.Text)

                    -- Профессия
                    draw.SimpleText(jobName, "font_sans_12", 10, 28, NextRP.Style.Theme.HightlightText)

                    -- Уровень или статус админа
                    local levelText = isAdmin and "АДМИН" or ("Уровень: " .. level)
                    draw.SimpleText(levelText, "font_sans_12", 10, 48, isAdmin and Color(255, 255, 0) or NextRP.Style.Theme.Text)

                    -- SteamID
                    draw.SimpleText(ply:SteamID(), "font_sans_10", w - 10, 50, NextRP.Style.Theme.Text, TEXT_ALIGN_RIGHT)

                    -- Пинг
                    local ping = ply:Ping()
                    local pingColor = Color(0, 255, 0)
                    if ping > 100 then pingColor = Color(255, 255, 0) end
                    if ping > 200 then pingColor = Color(255, 0, 0) end
                    draw.SimpleText(ping .. "ms", "font_sans_10", w - 10, 8, pingColor, TEXT_ALIGN_RIGHT)
                end

                -- Действие при нажатии
                playerButton.DoClick = function()
                    selectedPlayer = ply
                    UpdateInfoPanel(ply)
                end
            end
        end

        -- Применяем текущий фильтр
        FilterPlayers(searchEntry:GetValue())
    end

    -- Функция для обновления информационной панели
    function UpdateInfoPanel(ply)
        infoPanel:Clear()

        if not IsValid(ply) then return end

        -- Запрашиваем данные о прогрессе игрока
        netstream.Start('NextRP::AdminRequestPlayerData', ply:EntIndex())
    end

    -- Функция для создания интерфейса редактирования
    function panel:CreateEditInterface(playerData)
        infoPanel:Clear()

        if not selectedPlayer or not IsValid(selectedPlayer) then return end

        -- Заголовок с аватаром
        local headerPanel = vgui.Create('PawsUI.Panel', infoPanel)
        headerPanel:Dock(TOP)
        headerPanel:SetTall(80)
        headerPanel:DockMargin(5, 5, 5, 5)

        local avatar = vgui.Create('AvatarImage', headerPanel)
        avatar:SetPos(10, 10)
        avatar:SetSize(60, 60)
        avatar:SetPlayer(selectedPlayer, 64)

        headerPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)

            -- Название заголовка
            draw.SimpleText("Управление прогрессией", "font_sans_24", 80, 10, NextRP.Style.Theme.Text)
            draw.SimpleText(selectedPlayer:Nick(), "font_sans_20", 80, 35, NextRP.Style.Theme.HightlightText)
            draw.SimpleText("SteamID: " .. selectedPlayer:SteamID(), "font_sans_16", 80, 55, NextRP.Style.Theme.Text)

            -- Индикатор онлайн статуса
            draw.RoundedBox(10, w - 30, 15, 20, 20, Color(0, 255, 0, 255))
            draw.SimpleText("ONLINE", "font_sans_12", w - 20, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Информационная панель с текущими характеристиками
        local statsPanel = vgui.Create('PawsUI.Panel', infoPanel)
        statsPanel:Dock(TOP)
        statsPanel:SetTall(150)
        statsPanel:DockMargin(5, 5, 5, 5)

        statsPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)

            -- Заголовок статистики
            draw.SimpleText("Текущая статистика персонажа", "font_sans_18", 20, 15, NextRP.Style.Theme.Text)

            -- Текущие характеристики в две колонки
            local leftCol = 20
            local rightCol = w / 2 + 20

            -- Левая колонка
            draw.SimpleText("Уровень: " .. (playerData.level or 1), "font_sans_16", leftCol, 45, NextRP.Style.Theme.Text)
            draw.SimpleText("Опыт: " .. (playerData.xp or 0), "font_sans_16", leftCol, 70, NextRP.Style.Theme.Text)
            draw.SimpleText("Требуется опыта: " .. (playerData.xpRequired or 100), "font_sans_16", leftCol, 95, NextRP.Style.Theme.Text)

            -- Правая колонка
            draw.SimpleText("Очки талантов: " .. (playerData.talentPoints or 0), "font_sans_16", rightCol, 45, NextRP.Style.Theme.Text)
            draw.SimpleText("Профессия: " .. selectedPlayer:getJobTable().name, "font_sans_16", rightCol, 70, NextRP.Style.Theme.Text)
            draw.SimpleText("Последний вход: " .. os.date("%H:%M", os.time()), "font_sans_16", rightCol, 95, NextRP.Style.Theme.Text)

            -- Прогресс-бар опыта
            if playerData.xpRequired and playerData.xpRequired > 0 then
                local barWidth = w - 40
                local barHeight = 12
                local progress = (playerData.xp or 0) / playerData.xpRequired

                draw.SimpleText("Прогресс до следующего уровня:", "font_sans_16", leftCol, 115, NextRP.Style.Theme.HightlightText)
                draw.RoundedBox(2, leftCol, 135, barWidth, barHeight, NextRP.Style.Theme.DarkGray)
                draw.RoundedBox(2, leftCol, 135, barWidth * progress, barHeight, NextRP.Style.Theme.Accent)

                local progressText = math.Round(progress * 100, 1) .. "%"
                draw.SimpleText(progressText, "font_sans_12", leftCol + barWidth/2, 141, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        -- Создаем табы для разных категорий управления
        local tabPanel = vgui.Create('PawsUI.Panel', infoPanel)
        tabPanel:Dock(FILL)
        tabPanel:DockMargin(5, 5, 5, 5)

        local tabs = {}
        local activeTab = 1
        local tabHeight = 40

        -- Создаем кнопки табов
        local tabButtons = {}
        local tabNames = {"Уровень", "Опыт", "Таланты", "Действия"}

        for i, name in ipairs(tabNames) do
            local tabBtn = vgui.Create('DButton', tabPanel)
            tabBtn:SetPos((i-1) * 150, 0)
            tabBtn:SetSize(150, tabHeight)
            tabBtn:SetText('')

            tabBtn.Paint = function(s, w, h)
                local bgColor = activeTab == i and NextRP.Style.Theme.Accent or NextRP.Style.Theme.Primary
                if s:IsHovered() and activeTab != i then
                    bgColor = NextRP.Style.Theme.Secondary
                end

                draw.RoundedBoxEx(4, 0, 0, w, h, bgColor, true, true, false, false)
                draw.SimpleText(name, "font_sans_16", w/2, h/2, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            tabBtn.DoClick = function()
                activeTab = i
                panel:CreateTabContent(i, playerData)
            end

            tabButtons[i] = tabBtn
        end

        -- Контейнер для содержимого табов
        local tabContent = vgui.Create('PawsUI.Panel', tabPanel)
        tabContent:SetPos(0, tabHeight + 5)
        tabContent:SetSize(tabPanel:GetWide(), tabPanel:GetTall() - tabHeight - 5)

        -- Функция для создания содержимого табов
        function panel:CreateTabContent(tabIndex, data)
            tabContent:Clear()

            if tabIndex == 1 then -- Уровень
                self:CreateLevelTab(tabContent, data)
            elseif tabIndex == 2 then -- Опыт
                self:CreateXPTab(tabContent, data)
            elseif tabIndex == 3 then -- Таланты
                self:CreateTalentsTab(tabContent, data)
            elseif tabIndex == 4 then -- Действия
                self:CreateActionsTab(tabContent, data)
            end
        end

        -- Создаем начальный таб
        panel:CreateTabContent(1, playerData)
    end

    -- Таб управления уровнем
    function panel:CreateLevelTab(parent, data)
        local scrollPanel = vgui.Create('PawsUI.ScrollPanel', parent)
        scrollPanel:Dock(FILL)

        -- Текущий уровень
        local currentLevelPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        currentLevelPanel:Dock(TOP)
        currentLevelPanel:SetTall(60)
        currentLevelPanel:DockMargin(5, 5, 5, 5)

        currentLevelPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Secondary)
            draw.SimpleText("Текущий уровень: " .. (data.level or 1), "font_sans_20", 20, 20, NextRP.Style.Theme.Text)
        end

        -- Быстрые действия
        local quickPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        quickPanel:Dock(TOP)
        quickPanel:SetTall(80)
        quickPanel:DockMargin(5, 5, 5, 5)

        local quickLabel = vgui.Create('DLabel', quickPanel)
        quickLabel:SetText('Быстрые действия:')
        quickLabel:SetFont('font_sans_16')
        quickLabel:SetTextColor(NextRP.Style.Theme.Text)
        quickLabel:SetPos(10, 10)
        quickLabel:SizeToContents()

        -- Кнопки быстрых действий
        local btnWidth = 100
        local btnHeight = 30
        local btnY = 40

        local levelDownBtn = vgui.Create('DButton', quickPanel)
        levelDownBtn:SetPos(10, btnY)
        levelDownBtn:SetSize(btnWidth, btnHeight)
        levelDownBtn:SetText('-1 Уровень')
        levelDownBtn.DoClick = function()
            local currentLevel = data.level or 1
            if currentLevel > 1 then
                netstream.Start('NextRP::AdminSetLevel', {
                    player = selectedPlayer:EntIndex(),
                    level = currentLevel - 1
                })
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end
        end

        local levelUpBtn = vgui.Create('DButton', quickPanel)
        levelUpBtn:SetPos(120, btnY)
        levelUpBtn:SetSize(btnWidth, btnHeight)
        levelUpBtn:SetText('+1 Уровень')
        levelUpBtn.DoClick = function()
            local currentLevel = data.level or 1
            if currentLevel < 50 then
                netstream.Start('NextRP::AdminSetLevel', {
                    player = selectedPlayer:EntIndex(),
                    level = currentLevel + 1
                })
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end
        end

        local level5UpBtn = vgui.Create('DButton', quickPanel)
        level5UpBtn:SetPos(230, btnY)
        level5UpBtn:SetSize(btnWidth, btnHeight)
        level5UpBtn:SetText('+5 Уровней')
        level5UpBtn.DoClick = function()
            local currentLevel = data.level or 1
            local newLevel = math.min(currentLevel + 5, 50)
            netstream.Start('NextRP::AdminSetLevel', {
                player = selectedPlayer:EntIndex(),
                level = newLevel
            })
            timer.Simple(1, function()
                if IsValid(selectedPlayer) then
                    netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                end
            end)
        end

        local maxLevelBtn = vgui.Create('DButton', quickPanel)
        maxLevelBtn:SetPos(340, btnY)
        maxLevelBtn:SetSize(btnWidth, btnHeight)
        maxLevelBtn:SetText('Макс уровень')
        maxLevelBtn.DoClick = function()
            netstream.Start('NextRP::AdminSetLevel', {
                player = selectedPlayer:EntIndex(),
                level = 50
            })
            timer.Simple(1, function()
                if IsValid(selectedPlayer) then
                    netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                end
            end)
        end

        -- Точная установка уровня
        local precisePanel = vgui.Create('PawsUI.Panel', scrollPanel)
        precisePanel:Dock(TOP)
        precisePanel:SetTall(100)
        precisePanel:DockMargin(5, 5, 5, 5)

        local preciseLabel = vgui.Create('DLabel', precisePanel)
        preciseLabel:SetText('Точная установка уровня:')
        preciseLabel:SetFont('font_sans_16')
        preciseLabel:SetTextColor(NextRP.Style.Theme.Text)
        preciseLabel:SetPos(10, 10)
        preciseLabel:SizeToContents()

        local levelSlider = vgui.Create('DNumSlider', precisePanel)
        levelSlider:SetPos(10, 40)
        levelSlider:SetSize(400, 25)
        levelSlider:SetText('Уровень: ')
        levelSlider:SetMin(1)
        levelSlider:SetMax(50)
        levelSlider:SetDecimals(0)
        levelSlider:SetValue(data.level or 1)

        local setLevelBtn = vgui.Create('DButton', precisePanel)
        setLevelBtn:SetPos(10, 70)
        setLevelBtn:SetSize(150, 25)
        setLevelBtn:SetText('Установить уровень')
        setLevelBtn.DoClick = function()
            local newLevel = math.floor(levelSlider:GetValue())
            netstream.Start('NextRP::AdminSetLevel', {
                player = selectedPlayer:EntIndex(),
                level = newLevel
            })
            timer.Simple(1, function()
                if IsValid(selectedPlayer) then
                    netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                end
            end)
        end
    end

    -- Таб управления опытом
    function panel:CreateXPTab(parent, data)
        local scrollPanel = vgui.Create('PawsUI.ScrollPanel', parent)
        scrollPanel:Dock(FILL)

        -- Текущий опыт
        local currentXPPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        currentXPPanel:Dock(TOP)
        currentXPPanel:SetTall(80)
        currentXPPanel:DockMargin(5, 5, 5, 5)

        currentXPPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Secondary)
            draw.SimpleText("Текущий опыт: " .. (data.xp or 0), "font_sans_18", 20, 15, NextRP.Style.Theme.Text)
            draw.SimpleText("Требуется для следующего уровня: " .. (data.xpRequired or 100), "font_sans_16", 20, 40, NextRP.Style.Theme.Text)

            if data.xpRequired and data.xpRequired > 0 then
                local progress = (data.xp or 0) / data.xpRequired
                local barWidth = w - 40
                draw.RoundedBox(2, 20, 60, barWidth, 8, NextRP.Style.Theme.DarkGray)
                draw.RoundedBox(2, 20, 60, barWidth * progress, 8, NextRP.Style.Theme.Accent)
            end
        end

        -- Добавление опыта
        local addXPPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        addXPPanel:Dock(TOP)
        addXPPanel:SetTall(120)
        addXPPanel:DockMargin(5, 5, 5, 5)

        local addXPLabel = vgui.Create('DLabel', addXPPanel)
        addXPLabel:SetText('Добавить опыт:')
        addXPLabel:SetFont('font_sans_16')
        addXPLabel:SetTextColor(NextRP.Style.Theme.Text)
        addXPLabel:SetPos(10, 10)
        addXPLabel:SizeToContents()

        -- Быстрые кнопки добавления опыта
        local xpButtons = {
            {text = "+10 XP", amount = 10},
            {text = "+50 XP", amount = 50},
            {text = "+100 XP", amount = 100},
            {text = "+500 XP", amount = 500},
            {text = "+1000 XP", amount = 1000}
        }

        for i, btn in ipairs(xpButtons) do
            local xpBtn = vgui.Create('DButton', addXPPanel)
            xpBtn:SetPos(10 + (i-1) * 90, 35)
            xpBtn:SetSize(85, 25)
            xpBtn:SetText(btn.text)
            xpBtn.DoClick = function()
                netstream.Start('NextRP::AdminAddXP', {
                    player = selectedPlayer:EntIndex(),
                    amount = btn.amount
                })
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end
        end

        -- Пользовательская сумма
        local customXPEntry = vgui.Create('DTextEntry', addXPPanel)
        customXPEntry:SetPos(10, 70)
        customXPEntry:SetSize(100, 25)
        customXPEntry:SetPlaceholderText("Сумма XP")
        customXPEntry:SetNumeric(true)

        local addCustomXPBtn = vgui.Create('DButton', addXPPanel)
        addCustomXPBtn:SetPos(120, 70)
        addCustomXPBtn:SetSize(100, 25)
        addCustomXPBtn:SetText('Добавить XP')
        addCustomXPBtn.DoClick = function()
            local amount = tonumber(customXPEntry:GetValue())
            if amount and amount > 0 then
                netstream.Start('NextRP::AdminAddXP', {
                    player = selectedPlayer:EntIndex(),
                    amount = amount
                })
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end
        end

        local resetXPBtn = vgui.Create('DButton', addXPPanel)
        resetXPBtn:SetPos(230, 70)
        resetXPBtn:SetSize(100, 25)
        resetXPBtn:SetText('Сбросить XP')
        resetXPBtn.DoClick = function()
            netstream.Start('NextRP::AdminSetXP', {
                player = selectedPlayer:EntIndex(),
                amount = 0
            })
            timer.Simple(1, function()
                if IsValid(selectedPlayer) then
                    netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                end
            end)
        end
    end

    -- Таб управления талантами
    function panel:CreateTalentsTab(parent, data)
        local scrollPanel = vgui.Create('PawsUI.ScrollPanel', parent)
        scrollPanel:Dock(FILL)

        -- Текущие очки талантов
        local talentPointsPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        talentPointsPanel:Dock(TOP)
        talentPointsPanel:SetTall(60)
        talentPointsPanel:DockMargin(5, 5, 5, 5)

        talentPointsPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Secondary)
            draw.SimpleText("Очки талантов: " .. (data.talentPoints or 0), "font_sans_18", 20, 20, NextRP.Style.Theme.Text)
        end

        -- Управление очками талантов
        local talentControlPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        talentControlPanel:Dock(TOP)
        talentControlPanel:SetTall(100)
        talentControlPanel:DockMargin(5, 5, 5, 5)

        local talentLabel = vgui.Create('DLabel', talentControlPanel)
        talentLabel:SetText('Управление очками талантов:')
        talentLabel:SetFont('font_sans_16')
        talentLabel:SetTextColor(NextRP.Style.Theme.Text)
        talentLabel:SetPos(10, 10)
        talentLabel:SizeToContents()

        -- Быстрые кнопки
        local talentButtons = {"+1", "+5", "+10", "+25"}
        for i, text in ipairs(talentButtons) do
            local btn = vgui.Create('DButton', talentControlPanel)
            btn:SetPos(10 + (i-1) * 70, 35)
            btn:SetSize(65, 25)
            btn:SetText(text)
            btn.DoClick = function()
                local amount = tonumber(string.sub(text, 2))
                netstream.Start('NextRP::AdminAddTalentPoints', {
                    player = selectedPlayer:EntIndex(),
                    amount = amount
                })
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end
        end

        -- Точная установка
        local talentEntry = vgui.Create('DTextEntry', talentControlPanel)
        talentEntry:SetPos(10, 70)
        talentEntry:SetSize(100, 25)
        talentEntry:SetPlaceholderText("Количество")
        talentEntry:SetNumeric(true)

        local setTalentBtn = vgui.Create('DButton', talentControlPanel)
        setTalentBtn:SetPos(120, 70)
        setTalentBtn:SetSize(120, 25)
        setTalentBtn:SetText('Установить очки')
        setTalentBtn.DoClick = function()
            local amount = tonumber(talentEntry:GetValue())
            if amount and amount >= 0 then
                netstream.Start('NextRP::AdminSetTalentPoints', {
                    player = selectedPlayer:EntIndex(),
                    amount = amount
                })
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end
        end

        -- Просмотр и сброс талантов
        local talentActionsPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        talentActionsPanel:Dock(TOP)
        talentActionsPanel:SetTall(80)
        talentActionsPanel:DockMargin(5, 5, 5, 5)

        local actionsLabel = vgui.Create('DLabel', talentActionsPanel)
        actionsLabel:SetText('Действия с талантами:')
        actionsLabel:SetFont('font_sans_16')
        actionsLabel:SetTextColor(NextRP.Style.Theme.Text)
        actionsLabel:SetPos(10, 10)
        actionsLabel:SizeToContents()

        local viewTalentsBtn = vgui.Create('DButton', talentActionsPanel)
        viewTalentsBtn:SetPos(10, 40)
        viewTalentsBtn:SetSize(150, 30)
        viewTalentsBtn:SetText('Просмотр талантов')
        viewTalentsBtn.DoClick = function()
            netstream.Start('NextRP::AdminRequestTalents', selectedPlayer:EntIndex())
        end

        local resetTalentsBtn = vgui.Create('DButton', talentActionsPanel)
        resetTalentsBtn:SetPos(170, 40)
        resetTalentsBtn:SetSize(150, 30)
        resetTalentsBtn:SetText('Сбросить все таланты')
        resetTalentsBtn.DoClick = function()
            -- Подтверждение
            local confirmFrame = vgui.Create('PawsUI.Frame')
            confirmFrame:SetTitle('Подтверждение')
            confirmFrame:SetSize(350, 150)
            confirmFrame:Center()
            confirmFrame:MakePopup()
            confirmFrame:ShowSettingsButton(false)

            local confirmLabel = vgui.Create('DLabel', confirmFrame)
            confirmLabel:SetText('Вы уверены, что хотите сбросить\nвсе таланты игрока ' .. selectedPlayer:Nick() .. '?')
            confirmLabel:SetFont('font_sans_16')
            confirmLabel:SetTextColor(NextRP.Style.Theme.Text)
            confirmLabel:SetContentAlignment(5)
            confirmLabel:Dock(FILL)
            confirmLabel:DockMargin(10, 10, 10, 50)

            local buttonPanel = vgui.Create('DPanel', confirmFrame)
            buttonPanel:Dock(BOTTOM)
            buttonPanel:SetTall(40)
            buttonPanel:DockMargin(10, 0, 10, 10)
            buttonPanel.Paint = nil

            local yesBtn = vgui.Create('DButton', buttonPanel)
            yesBtn:SetPos(10, 5)
            yesBtn:SetSize(100, 30)
            yesBtn:SetText('Да')
            yesBtn.DoClick = function()
                netstream.Start('NextRP::AdminResetTalents', selectedPlayer:EntIndex())
                confirmFrame:Remove()
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end

            local noBtn = vgui.Create('DButton', buttonPanel)
            noBtn:SetPos(230, 5)
            noBtn:SetSize(100, 30)
            noBtn:SetText('Нет')
            noBtn.DoClick = function()
                confirmFrame:Remove()
            end
        end
    end

    -- Таб дополнительных действий
    function panel:CreateActionsTab(parent, data)
        local scrollPanel = vgui.Create('PawsUI.ScrollPanel', parent)
        scrollPanel:Dock(FILL)

        -- Панель массовых действий
        local massActionsPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        massActionsPanel:Dock(TOP)
        massActionsPanel:SetTall(120)
        massActionsPanel:DockMargin(5, 5, 5, 5)

        massActionsPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Secondary)
            draw.SimpleText("Быстрые действия", "font_sans_18", 15, 15, NextRP.Style.Theme.Text)
        end

        local copyProgressBtn = vgui.Create('DButton', massActionsPanel)
        copyProgressBtn:SetPos(15, 45)
        copyProgressBtn:SetSize(160, 30)
        copyProgressBtn:SetText('Скопировать прогресс')
        copyProgressBtn:SetTooltip('Копирует текущий прогресс в буфер обмена')
        copyProgressBtn.DoClick = function()
            local progressData = string.format(
                "Игрок: %s\nУровень: %d\nОпыт: %d/%d\nОчки талантов: %d\nSteamID: %s",
                selectedPlayer:Nick(),
                data.level or 1,
                data.xp or 0,
                data.xpRequired or 100,
                data.talentPoints or 0,
                selectedPlayer:SteamID()
            )
            SetClipboardText(progressData)
            surface.PlaySound("garrysmod/save_load1.wav")
            NextRP:ScreenNotify(2, nil, NextRP.Style.Theme.Green, "Прогресс скопирован в буфер обмена!")
        end

        local refreshBtn = vgui.Create('DButton', massActionsPanel)
        refreshBtn:SetPos(185, 45)
        refreshBtn:SetSize(130, 30)
        refreshBtn:SetText('Обновить данные')
        refreshBtn.DoClick = function()
            netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
        end

        local kickBtn = vgui.Create('DButton', massActionsPanel)
        kickBtn:SetPos(325, 45)
        kickBtn:SetSize(100, 30)
        kickBtn:SetText('Кикнуть')
        kickBtn.DoClick = function()
            selectedPlayer:Kick("Кикнут администратором")
        end

        -- Панель логирования
        local logPanel = vgui.Create('PawsUI.Panel', scrollPanel)
        logPanel:Dock(TOP)
        logPanel:SetTall(200)
        logPanel:DockMargin(5, 5, 5, 5)

        logPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)
            draw.SimpleText("История действий (локальная)", "font_sans_16", 15, 15, NextRP.Style.Theme.Text)
        end

        local logList = vgui.Create('DListView', logPanel)
        logList:SetPos(15, 40)
        logList:SetSize(logPanel:GetWide() - 30, logPanel:GetTall() - 55)
        logList:AddColumn("Время")
        logList:AddColumn("Действие")
        logList:AddColumn("Значение")

        -- Добавляем пример записей (в реальности это должно приходить с сервера)
        logList:AddLine(os.date("%H:%M:%S"), "Подключение к админ панели", selectedPlayer:Nick())
        logList:AddLine(os.date("%H:%M:%S"), "Запрос данных игрока", "Успешно")
    end

    -- Изначально обновляем список игроков
    UpdatePlayerList()

    -- Показываем инструкцию, если никто не выбран
    if not selectedPlayer then
        infoPanel:Clear()

        local instructionPanel = vgui.Create('PawsUI.Panel', infoPanel)
        instructionPanel:Dock(FILL)
        instructionPanel:DockMargin(5, 5, 5, 5)

        instructionPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)

            -- Заголовок
            draw.SimpleText("Админ панель управления прогрессией", "font_sans_24", w/2, 50, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER)

            -- Инструкции
            local instructions = {
                "1. Выберите игрока из списка слева",
                "2. Используйте табы для навигации между функциями",
                "3. Все изменения применяются мгновенно",
                "4. Используйте поиск для быстрого нахождения игроков",
                "",
                "Доступные функции:",
                "• Управление уровнем персонажа",
                "• Добавление и установка опыта",
                "• Управление очками талантов",
                "• Просмотр и сброс талантов",
                "• Дополнительные административные действия"
            }

            for i, text in ipairs(instructions) do
                local y = 120 + i * 25
                local color = text == "" and NextRP.Style.Theme.Background or
                             string.find(text, "•") and NextRP.Style.Theme.HightlightText or
                             string.find(text, ":") and NextRP.Style.Theme.Accent or
                             NextRP.Style.Theme.Text

                draw.SimpleText(text, "font_sans_16", w/2, y, color, TEXT_ALIGN_CENTER)
            end

            -- Статистика внизу
            local playerCount = #player.GetAll()
            local activeChars = 0
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
                    activeChars = activeChars + 1
                end
            end

            draw.SimpleText("Игроков онлайн: " .. playerCount .. " | Активных персонажей: " .. activeChars,
                           "font_sans_16", w/2, h - 30, NextRP.Style.Theme.HightlightText, TEXT_ALIGN_CENTER)
        end
    end

    -- Таймер для автообновления списка игроков каждые 10 секунд
    timer.Create("NextRP_AdminPanel_Update", 10, 0, function()
        if IsValid(panel) then
            UpdatePlayerList()

            -- Обновляем данные выбранного игрока каждые 30 секунд
            if selectedPlayer and IsValid(selectedPlayer) then
                netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
            end
        else
            timer.Remove("NextRP_AdminPanel_Update")
        end
    end)

    -- Удаляем таймер при закрытии панели
    panel.OnRemove = function()
        timer.Remove("NextRP_AdminPanel_Update")
    end

    return panel
end

-- Сетевые обработчики для админ панели
netstream.Hook('NextRP::AdminPlayerData', function(data)
    if IsValid(NextRP.Progression.AdminPanel) then
        NextRP.Progression.AdminPanel:CreateEditInterface(data)
    end
end)

netstream.Hook('NextRP::AdminPlayerTalents', function(data)
    -- Создаем улучшенное окно просмотра талантов
    local talentViewFrame = vgui.Create('PawsUI.Frame')
    talentViewFrame:SetTitle('Таланты игрока: ' .. data.playerName)
    talentViewFrame:SetSize(700, 600)
    talentViewFrame:Center()
    talentViewFrame:MakePopup()
    talentViewFrame:ShowSettingsButton(false)

    if table.Count(data.talents) == 0 then
        local noTalentsPanel = vgui.Create('PawsUI.Panel', talentViewFrame)
        noTalentsPanel:Dock(FILL)
        noTalentsPanel:DockMargin(10, 10, 10, 10)

        noTalentsPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)
            draw.SimpleText('У игрока нет изученных талантов', "font_sans_20", w/2, h/2, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText('Добавьте очки талантов и дайте игроку изучить способности', "font_sans_16", w/2, h/2 + 30, NextRP.Style.Theme.HightlightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else
        local talentList = vgui.Create('PawsUI.ScrollPanel', talentViewFrame)
        talentList:Dock(FILL)
        talentList:DockMargin(10, 10, 10, 10)

        -- Заголовок
        local headerPanel = vgui.Create('PawsUI.Panel', talentList)
        headerPanel:Dock(TOP)
        headerPanel:SetTall(40)
        headerPanel:DockMargin(0, 0, 0, 5)

        headerPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Accent)
            draw.SimpleText('Изученные таланты (' .. table.Count(data.talents) .. ')', "font_sans_18", w/2, h/2, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Сортируем таланты по ID для консистентности
        local sortedTalents = {}
        for talentID, rank in pairs(data.talents) do
            table.insert(sortedTalents, {id = talentID, rank = rank})
        end
        table.sort(sortedTalents, function(a, b) return a.id < b.id end)

        for _, talent in ipairs(sortedTalents) do
            local talentPanel = vgui.Create('PawsUI.Panel', talentList)
            talentPanel:Dock(TOP)
            talentPanel:SetTall(80)
            talentPanel:DockMargin(0, 2, 0, 2)

            talentPanel.Paint = function(s, w, h)
                local bgColor = NextRP.Style.Theme.Primary
                if s:IsHovered() then
                    bgColor = NextRP.Style.Theme.Secondary
                end

                draw.RoundedBox(4, 0, 0, w, h, bgColor)

                -- Иконка таланта (если есть)
                draw.RoundedBox(4, 10, 10, 60, 60, NextRP.Style.Theme.DarkGray)
                draw.SimpleText("★", "font_sans_24", 40, 40, NextRP.Style.Theme.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Название таланта
                draw.SimpleText(talent.id, "font_sans_18", 80, 15, NextRP.Style.Theme.Text)

                -- Ранг таланта
                draw.SimpleText("Ранг: " .. talent.rank, "font_sans_16", 80, 40, NextRP.Style.Theme.HightlightText)

                -- ID таланта (для технических целей)
                draw.SimpleText("ID: " .. talent.id, "font_sans_12", 80, 60, NextRP.Style.Theme.Text)

                -- Кнопка действий справа
                local actionText = "Изучен"
                draw.SimpleText(actionText, "font_sans_16", w - 80, 40, NextRP.Style.Theme.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        -- Кнопки действий внизу
        local actionPanel = vgui.Create('DPanel', talentViewFrame)
        actionPanel:Dock(BOTTOM)
        actionPanel:SetTall(50)
        actionPanel:DockMargin(10, 5, 10, 10)
        actionPanel.Paint = nil

        local copyBtn = vgui.Create('DButton', actionPanel)
        copyBtn:SetPos(10, 10)
        copyBtn:SetSize(150, 30)
        copyBtn:SetText('Копировать список')
        copyBtn.DoClick = function()
            local talentText = "Таланты игрока " .. data.playerName .. ":\n"
            for _, talent in ipairs(sortedTalents) do
                talentText = talentText .. "- " .. talent.id .. " (Ранг: " .. talent.rank .. ")\n"
            end
            SetClipboardText(talentText)
            surface.PlaySound("garrysmod/save_load1.wav")
        end

        local refreshBtn = vgui.Create('DButton', actionPanel)
        refreshBtn:SetPos(170, 10)
        refreshBtn:SetSize(100, 30)
        refreshBtn:SetText('Обновить')
        refreshBtn.DoClick = function()
            talentViewFrame:Remove()
            if IsValid(NextRP.Progression.AdminPanel) and selectedPlayer then
                netstream.Start('NextRP::AdminRequestTalents', selectedPlayer:EntIndex())
            end
        end

        local closeBtn = vgui.Create('DButton', actionPanel)
        closeBtn:SetPos(actionPanel:GetWide() - 110, 10)
        closeBtn:SetSize(100, 30)
        closeBtn:SetText('Закрыть')
        closeBtn.DoClick = function()
            talentViewFrame:Remove()
        end
    end
end)

-- Команда для открытия админ панели
concommand.Add("nextrp_progression_admin", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("У вас нет прав для использования этой команды!")
        end
        return
    end

    NextRP.Progression:OpenAdminPanel()
end)

-- Дополнительные сетевые обработчики для уведомлений
netstream.Hook('NextRP::AdminActionSuccess', function(message)
    surface.PlaySound("garrysmod/save_load1.wav")
    NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Green, message)
end)

netstream.Hook('NextRP::AdminActionError', function(message)
    surface.PlaySound("buttons/button10.wav")
    NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Red, message)
end)

-- Горячие клавиши для админ панели
hook.Add("PlayerButtonDown", "NextRP::AdminPanelHotkeys", function(ply, button)
    if not IsValid(NextRP.Progression.AdminPanel) then return end
    if ply != LocalPlayer() or not LocalPlayer():IsAdmin() then return end

    -- F5 - обновить список игроков
    if button == KEY_F5 then
        if IsValid(NextRP.Progression.AdminPanel) then
            -- Обновляем данные
            timer.Simple(0.1, function()
                if IsValid(NextRP.Progression.AdminPanel) then
                    NextRP.Progression.AdminPanel:UpdatePlayerList()
                end
            end)

            surface.PlaySound("garrysmod/ui_click.wav")
            NextRP:ScreenNotify(1, nil, NextRP.Style.Theme.Green, "Список игроков обновлен")
        end
    end
end)

-- Добавляем в контекстное меню для админов
hook.Add("PopulateToolMenu", "NextRP::AddProgressionAdminMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "NextRP Admin", "ProgressionAdmin", "Управление прогрессией", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Label", {
            Text = "Админ панель для управления уровнями, опытом и талантами игроков"
        })

        panel:AddControl("Button", {
            Label = "Открыть панель управления (F6)",
            Command = "nextrp_progression_admin"
        })

        panel:AddControl("Label", {
            Text = " "
        })

        panel:AddControl("Label", {
            Text = "Быстрые команды:"
        })

        panel:AddControl("Label", {
            Text = "• F5 - Обновить список игроков"
        })

        panel:AddControl("Label", {
            Text = "• /addxp <имя> <кол-во> - Добавить опыт"
        })

        panel:AddControl("Label", {
            Text = "• /setlevel <имя> <уровень> - Установить уровень"
        })

        panel:AddControl("Label", {
            Text = " "
        })

        panel:AddControl("Label", {
            Text = "Доступно только администраторам"
        })

        -- Статистика сервера
        if LocalPlayer():IsSuperAdmin() then
            panel:AddControl("Label", {
                Text = " "
            })

            panel:AddControl("Label", {
                Text = "Статистика сервера:"
            })

            panel:AddControl("Button", {
                Label = "Просмотр топ игроков",
                Command = "nextrp_top_levels"
            })

            panel:AddControl("Button", {
                Label = "Статистика прогрессии",
                Command = "nextrp_progression_stats"
            })

            panel:AddControl("Button", {
                Label = "Создать резервную копию",
                Command = "nextrp_backup_progression"
            })
        end
    end)
end)

-- Автодополнение для поиска
hook.Add("OnTextEntryGetFocus", "NextRP::AdminPanelAutocomplete", function(textEntry)
    if not IsValid(NextRP.Progression.AdminPanel) or not textEntry.GetPlaceholderText then return end

    if textEntry:GetPlaceholderText() == "Поиск игрока..." then
        -- Добавляем автодополнение для поиска игроков
        textEntry.OnTextChanged = function(self)
            local text = self:GetValue()
            if string.len(text) >= 2 then
                -- Здесь можно добавить логику автодополнения
                -- Например, подсвечивать совпадающих игроков
            end
        end
    end
end)

-- Система уведомлений об изменениях
hook.Add("NextRP::PlayerLevelUp", "AdminPanelNotifications", function(player, newLevel)
    if IsValid(NextRP.Progression.AdminPanel) then
        -- Если админ панель открыта, показываем уведомление
        NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Green,
            player:Nick() .. " достиг " .. newLevel .. " уровня!")
    end
end)

print("[NextRP.Progression] Админ панель загружена!")-- Добавить в конец файла cl_progression.lua

-- Админ меню для управления прогрессией
NextRP.Progression.AdminPanel = nil

-- Функция для открытия админ панели прогрессии
function NextRP.Progression:OpenAdminPanel()
    if IsValid(self.AdminPanel) then
        self.AdminPanel:Remove()
    end

    -- Создаем основную панель
    local panel = vgui.Create('PawsUI.Frame')
    panel:SetTitle('Админ панель - Управление прогрессией')
    panel:SetSize(1000, 700)
    panel:Center()
    panel:MakePopup()
    panel:ShowSettingsButton(false)

    self.AdminPanel = panel

    -- Левая панель со списком игроков
    local playerListPanel = vgui.Create('PawsUI.Panel', panel)
    playerListPanel:Dock(LEFT)
    playerListPanel:SetWide(300)
    playerListPanel:DockMargin(5, 5, 5, 5)

    -- Заголовок списка игроков
    local playerListLabel = vgui.Create('DLabel', playerListPanel)
    playerListLabel:SetText('Список игроков онлайн:')
    playerListLabel:SetFont('font_sans_18')
    playerListLabel:SetTextColor(NextRP.Style.Theme.Text)
    playerListLabel:Dock(TOP)
    playerListLabel:SetTall(30)
    playerListLabel:DockMargin(5, 5, 5, 5)

    -- Список игроков
    local playerList = vgui.Create('PawsUI.ScrollPanel', playerListPanel)
    playerList:Dock(FILL)
    playerList:DockMargin(5, 5, 5, 5)

    -- Правая панель с информацией о выбранном игроке
    local infoPanel = vgui.Create('PawsUI.Panel', panel)
    infoPanel:Dock(FILL)
    infoPanel:DockMargin(5, 5, 5, 5)

    -- Переменная для хранения выбранного игрока
    local selectedPlayer = nil

    -- Функция для обновления списка игроков
    local function UpdatePlayerList()
        playerList:Clear()

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
                local playerButton = vgui.Create('DButton', playerList)
                playerButton:SetText('')
                playerButton:SetTall(50)
                playerButton:Dock(TOP)
                playerButton:DockMargin(0, 2, 0, 2)

                -- Отрисовка кнопки игрока
                playerButton.Paint = function(s, w, h)
                    local bgColor = NextRP.Style.Theme.Primary
                    if s:IsHovered() then
                        bgColor = NextRP.Style.Theme.Accent
                    elseif selectedPlayer == ply then
                        bgColor = NextRP.Style.Theme.Green
                    end

                    draw.RoundedBox(4, 0, 0, w, h, bgColor)

                    -- Имя игрока
                    draw.SimpleText(ply:Nick(), "font_sans_16", 10, 10, NextRP.Style.Theme.Text)

                    -- Профессия
                    local jobName = ply:getJobTable().name or "Неизвестно"
                    draw.SimpleText(jobName, "font_sans_12", 10, 30, NextRP.Style.Theme.HightlightText)

                    -- SteamID
                    draw.SimpleText(ply:SteamID(), "font_sans_12", w - 10, 10, NextRP.Style.Theme.Text, TEXT_ALIGN_RIGHT)
                end

                -- Действие при нажатии
                playerButton.DoClick = function()
                    selectedPlayer = ply
                    UpdateInfoPanel(ply)
                end
            end
        end
    end

    -- Функция для обновления информационной панели
    function UpdateInfoPanel(ply)
        infoPanel:Clear()

        if not IsValid(ply) then return end

        -- Запрашиваем данные о прогрессе игрока
        netstream.Start('NextRP::AdminRequestPlayerData', ply:EntIndex())
    end

    -- Функция для создания интерфейса редактирования
    function panel:CreateEditInterface(playerData)
        infoPanel:Clear()

        if not selectedPlayer or not IsValid(selectedPlayer) then return end

        -- Заголовок
        local titleLabel = vgui.Create('DLabel', infoPanel)
        titleLabel:SetText('Управление прогрессией: ' .. selectedPlayer:Nick())
        titleLabel:SetFont('font_sans_24')
        titleLabel:SetTextColor(NextRP.Style.Theme.Text)
        titleLabel:Dock(TOP)
        titleLabel:SetTall(40)
        titleLabel:DockMargin(5, 5, 5, 5)

        -- Информационная панель
        local statsPanel = vgui.Create('PawsUI.Panel', infoPanel)
        statsPanel:Dock(TOP)
        statsPanel:SetTall(120)
        statsPanel:DockMargin(5, 5, 5, 5)

        statsPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)

            -- Текущие характеристики
            draw.SimpleText("Текущий уровень: " .. (playerData.level or 1), "font_sans_18", 20, 15, NextRP.Style.Theme.Text)
            draw.SimpleText("Опыт: " .. (playerData.xp or 0) .. " / " .. (playerData.xpRequired or 100), "font_sans_16", 20, 40, NextRP.Style.Theme.Text)
            draw.SimpleText("Очки талантов: " .. (playerData.talentPoints or 0), "font_sans_16", 20, 65, NextRP.Style.Theme.Text)
            draw.SimpleText("SteamID: " .. selectedPlayer:SteamID(), "font_sans_16", 20, 90, NextRP.Style.Theme.HightlightText)

            -- Прогресс-бар опыта
            if playerData.xpRequired and playerData.xpRequired > 0 then
                local barWidth = w - 300
                local progress = (playerData.xp or 0) / playerData.xpRequired

                draw.RoundedBox(2, w - barWidth - 20, 40, barWidth, 10, NextRP.Style.Theme.DarkGray)
                draw.RoundedBox(2, w - barWidth - 20, 40, barWidth * progress, 10, NextRP.Style.Theme.Accent)
            end
        end

        -- Панель управления уровнем
        local levelPanel = vgui.Create('PawsUI.Panel', infoPanel)
        levelPanel:Dock(TOP)
        levelPanel:SetTall(80)
        levelPanel:DockMargin(5, 5, 5, 5)

        local levelLabel = vgui.Create('DLabel', levelPanel)
        levelLabel:SetText('Управление уровнем:')
        levelLabel:SetFont('font_sans_18')
        levelLabel:SetTextColor(NextRP.Style.Theme.Text)
        levelLabel:Dock(TOP)
        levelLabel:SetTall(25)
        levelLabel:DockMargin(5, 5, 5, 5)

        local levelControls = vgui.Create('DPanel', levelPanel)
        levelControls:Dock(FILL)
        levelControls:DockMargin(5, 0, 5, 5)
        levelControls.Paint = nil

        -- Поле ввода уровня
        local levelEntry = vgui.Create('DTextEntry', levelControls)
        levelEntry:SetPos(10, 10)
        levelEntry:SetSize(100, 25)
        levelEntry:SetPlaceholderText("Уровень")
        levelEntry:SetNumeric(true)
        levelEntry:SetValue(tostring(playerData.level or 1))

        -- Кнопка установить уровень
        local setLevelBtn = vgui.Create('DButton', levelControls)
        setLevelBtn:SetPos(120, 10)
        setLevelBtn:SetSize(120, 25)
        setLevelBtn:SetText('Установить уровень')
        setLevelBtn.DoClick = function()
            local newLevel = tonumber(levelEntry:GetValue())
            if newLevel and newLevel > 0 and newLevel <= 50 then
                netstream.Start('NextRP::AdminSetLevel', {
                    player = selectedPlayer:EntIndex(),
                    level = newLevel
                })

                -- Обновляем данные через секунду
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            else
                surface.PlaySound("buttons/button10.wav")
                NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Red, "Неверный уровень! (1-50)")
            end
        end

        -- Кнопки быстрого изменения уровня
        local levelDownBtn = vgui.Create('DButton', levelControls)
        levelDownBtn:SetPos(250, 10)
        levelDownBtn:SetSize(30, 25)
        levelDownBtn:SetText('-1')
        levelDownBtn.DoClick = function()
            local currentLevel = tonumber(levelEntry:GetValue()) or 1
            if currentLevel > 1 then
                levelEntry:SetValue(tostring(currentLevel - 1))
            end
        end

        local levelUpBtn = vgui.Create('DButton', levelControls)
        levelUpBtn:SetPos(285, 10)
        levelUpBtn:SetSize(30, 25)
        levelUpBtn:SetText('+1')
        levelUpBtn.DoClick = function()
            local currentLevel = tonumber(levelEntry:GetValue()) or 1
            if currentLevel < 50 then
                levelEntry:SetValue(tostring(currentLevel + 1))
            end
        end

        -- Панель управления опытом
        local xpPanel = vgui.Create('PawsUI.Panel', infoPanel)
        xpPanel:Dock(TOP)
        xpPanel:SetTall(80)
        xpPanel:DockMargin(5, 5, 5, 5)

        local xpLabel = vgui.Create('DLabel', xpPanel)
        xpLabel:SetText('Управление опытом:')
        xpLabel:SetFont('font_sans_18')
        xpLabel:SetTextColor(NextRP.Style.Theme.Text)
        xpLabel:Dock(TOP)
        xpLabel:SetTall(25)
        xpLabel:DockMargin(5, 5, 5, 5)

        local xpControls = vgui.Create('DPanel', xpPanel)
        xpControls:Dock(FILL)
        xpControls:DockMargin(5, 0, 5, 5)
        xpControls.Paint = nil

        -- Поле ввода опыта
        local xpEntry = vgui.Create('DTextEntry', xpControls)
        xpEntry:SetPos(10, 10)
        xpEntry:SetSize(100, 25)
        xpEntry:SetPlaceholderText("Количество")
        xpEntry:SetNumeric(true)
        xpEntry:SetValue("100")

        -- Кнопка добавить опыт
        local addXPBtn = vgui.Create('DButton', xpControls)
        addXPBtn:SetPos(120, 10)
        addXPBtn:SetSize(100, 25)
        addXPBtn:SetText('Добавить XP')
        addXPBtn.DoClick = function()
            local xpAmount = tonumber(xpEntry:GetValue())
            if xpAmount and xpAmount > 0 then
                netstream.Start('NextRP::AdminAddXP', {
                    player = selectedPlayer:EntIndex(),
                    amount = xpAmount
                })

                -- Обновляем данные через секунду
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            else
                surface.PlaySound("buttons/button10.wav")
                NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Red, "Неверное количество опыта!")
            end
        end

        -- Кнопка сбросить опыт
        local resetXPBtn = vgui.Create('DButton', xpControls)
        resetXPBtn:SetPos(230, 10)
        resetXPBtn:SetSize(100, 25)
        resetXPBtn:SetText('Сбросить XP')
        resetXPBtn.DoClick = function()
            netstream.Start('NextRP::AdminSetXP', {
                player = selectedPlayer:EntIndex(),
                amount = 0
            })

            -- Обновляем данные через секунду
            timer.Simple(1, function()
                if IsValid(selectedPlayer) then
                    netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                end
            end)
        end

        -- Панель управления очками талантов
        local talentPanel = vgui.Create('PawsUI.Panel', infoPanel)
        talentPanel:Dock(TOP)
        talentPanel:SetTall(80)
        talentPanel:DockMargin(5, 5, 5, 5)

        local talentLabel = vgui.Create('DLabel', talentPanel)
        talentLabel:SetText('Управление очками талантов:')
        talentLabel:SetFont('font_sans_18')
        talentLabel:SetTextColor(NextRP.Style.Theme.Text)
        talentLabel:Dock(TOP)
        talentLabel:SetTall(25)
        talentLabel:DockMargin(5, 5, 5, 5)

        local talentControls = vgui.Create('DPanel', talentPanel)
        talentControls:Dock(FILL)
        talentControls:DockMargin(5, 0, 5, 5)
        talentControls.Paint = nil

        -- Поле ввода очков талантов
        local talentEntry = vgui.Create('DTextEntry', talentControls)
        talentEntry:SetPos(10, 10)
        talentEntry:SetSize(100, 25)
        talentEntry:SetPlaceholderText("Количество")
        talentEntry:SetNumeric(true)
        talentEntry:SetValue("1")

        -- Кнопка добавить очки талантов
        local addTalentBtn = vgui.Create('DButton', talentControls)
        addTalentBtn:SetPos(120, 10)
        addTalentBtn:SetSize(120, 25)
        addTalentBtn:SetText('Добавить очки')
        addTalentBtn.DoClick = function()
            local talentAmount = tonumber(talentEntry:GetValue())
            if talentAmount and talentAmount > 0 then
                netstream.Start('NextRP::AdminAddTalentPoints', {
                    player = selectedPlayer:EntIndex(),
                    amount = talentAmount
                })

                -- Обновляем данные через секунду
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            else
                surface.PlaySound("buttons/button10.wav")
                NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Red, "Неверное количество очков!")
            end
        end

        -- Кнопка установить очки талантов
        local setTalentBtn = vgui.Create('DButton', talentControls)
        setTalentBtn:SetPos(250, 10)
        setTalentBtn:SetSize(120, 25)
        setTalentBtn:SetText('Установить очки')
        setTalentBtn.DoClick = function()
            local talentAmount = tonumber(talentEntry:GetValue())
            if talentAmount and talentAmount >= 0 then
                netstream.Start('NextRP::AdminSetTalentPoints', {
                    player = selectedPlayer:EntIndex(),
                    amount = talentAmount
                })

                -- Обновляем данные через секунду
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            else
                surface.PlaySound("buttons/button10.wav")
                NextRP:ScreenNotify(3, nil, NextRP.Style.Theme.Red, "Неверное количество очков!")
            end
        end

        -- Панель дополнительных действий
        local actionsPanel = vgui.Create('PawsUI.Panel', infoPanel)
        actionsPanel:Dock(TOP)
        actionsPanel:SetTall(80)
        actionsPanel:DockMargin(5, 5, 5, 5)

        local actionsLabel = vgui.Create('DLabel', actionsPanel)
        actionsLabel:SetText('Дополнительные действия:')
        actionsLabel:SetFont('font_sans_18')
        actionsLabel:SetTextColor(NextRP.Style.Theme.Text)
        actionsLabel:Dock(TOP)
        actionsLabel:SetTall(25)
        actionsLabel:DockMargin(5, 5, 5, 5)

        local actionsControls = vgui.Create('DPanel', actionsPanel)
        actionsControls:Dock(FILL)
        actionsControls:DockMargin(5, 0, 5, 5)
        actionsControls.Paint = nil

        -- Кнопка сброса всех талантов
        local resetTalentsBtn = vgui.Create('DButton', actionsControls)
        resetTalentsBtn:SetPos(10, 10)
        resetTalentsBtn:SetSize(150, 25)
        resetTalentsBtn:SetText('Сбросить все таланты')
        resetTalentsBtn.DoClick = function()
            -- Подтверждение действия
            local confirmFrame = vgui.Create('PawsUI.Frame')
            confirmFrame:SetTitle('Подтверждение')
            confirmFrame:SetSize(300, 150)
            confirmFrame:Center()
            confirmFrame:MakePopup()
            confirmFrame:ShowSettingsButton(false)

            local confirmLabel = vgui.Create('DLabel', confirmFrame)
            confirmLabel:SetText('Вы уверены, что хотите сбросить\nвсе таланты игрока ' .. selectedPlayer:Nick() .. '?')
            confirmLabel:SetFont('font_sans_16')
            confirmLabel:SetTextColor(NextRP.Style.Theme.Text)
            confirmLabel:SetContentAlignment(5)
            confirmLabel:Dock(FILL)
            confirmLabel:DockMargin(10, 10, 10, 50)

            local buttonPanel = vgui.Create('DPanel', confirmFrame)
            buttonPanel:Dock(BOTTOM)
            buttonPanel:SetTall(40)
            buttonPanel:DockMargin(10, 0, 10, 10)
            buttonPanel.Paint = nil

            local yesBtn = vgui.Create('DButton', buttonPanel)
            yesBtn:SetPos(10, 5)
            yesBtn:SetSize(100, 30)
            yesBtn:SetText('Да')
            yesBtn.DoClick = function()
                netstream.Start('NextRP::AdminResetTalents', selectedPlayer:EntIndex())
                confirmFrame:Remove()

                -- Обновляем данные
                timer.Simple(1, function()
                    if IsValid(selectedPlayer) then
                        netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
                    end
                end)
            end

            local noBtn = vgui.Create('DButton', buttonPanel)
            noBtn:SetPos(180, 5)
            noBtn:SetSize(100, 30)
            noBtn:SetText('Нет')
            noBtn.DoClick = function()
                confirmFrame:Remove()
            end
        end

        -- Кнопка просмотра талантов
        local viewTalentsBtn = vgui.Create('DButton', actionsControls)
        viewTalentsBtn:SetPos(170, 10)
        viewTalentsBtn:SetSize(150, 25)
        viewTalentsBtn:SetText('Просмотр талантов')
        viewTalentsBtn.DoClick = function()
            netstream.Start('NextRP::AdminRequestTalents', selectedPlayer:EntIndex())
        end

        -- Кнопка обновления данных
        local refreshBtn = vgui.Create('DButton', actionsControls)
        refreshBtn:SetPos(330, 10)
        refreshBtn:SetSize(100, 25)
        refreshBtn:SetText('Обновить')
        refreshBtn.DoClick = function()
            netstream.Start('NextRP::AdminRequestPlayerData', selectedPlayer:EntIndex())
        end
    end

    -- Изначально обновляем список игроков
    UpdatePlayerList()

    -- Таймер для автообновления списка игроков каждые 5 секунд
    timer.Create("NextRP_AdminPanel_Update", 5, 0, function()
        if IsValid(panel) then
            UpdatePlayerList()
        else
            timer.Remove("NextRP_AdminPanel_Update")
        end
    end)

    -- Удаляем таймер при закрытии панели
    panel.OnRemove = function()
        timer.Remove("NextRP_AdminPanel_Update")
    end

    return panel
end

-- Сетевые обработчики для админ панели
netstream.Hook('NextRP::AdminPlayerData', function(data)
    if IsValid(NextRP.Progression.AdminPanel) then
        NextRP.Progression.AdminPanel:CreateEditInterface(data)
    end
end)

netstream.Hook('NextRP::AdminPlayerTalents', function(data)
    -- Создаем окно просмотра талантов
    local talentViewFrame = vgui.Create('PawsUI.Frame')
    talentViewFrame:SetTitle('Таланты игрока: ' .. data.playerName)
    talentViewFrame:SetSize(600, 500)
    talentViewFrame:Center()
    talentViewFrame:MakePopup()
    talentViewFrame:ShowSettingsButton(false)

    local talentList = vgui.Create('PawsUI.ScrollPanel', talentViewFrame)
    talentList:Dock(FILL)
    talentList:DockMargin(10, 10, 10, 10)

    if table.Count(data.talents) == 0 then
        local noTalentsLabel = vgui.Create('DLabel', talentList)
        noTalentsLabel:SetText('У игрока нет изученных талантов')
        noTalentsLabel:SetFont('font_sans_18')
        noTalentsLabel:SetTextColor(NextRP.Style.Theme.Text)
        noTalentsLabel:SetContentAlignment(5)
        noTalentsLabel:Dock(TOP)
        noTalentsLabel:SetTall(50)
    else
        for talentID, rank in pairs(data.talents) do
            local talentPanel = vgui.Create('DPanel', talentList)
            talentPanel:Dock(TOP)
            talentPanel:SetTall(60)
            talentPanel:DockMargin(0, 2, 0, 2)

            talentPanel.Paint = function(s, w, h)
                draw.RoundedBox(4, 0, 0, w, h, NextRP.Style.Theme.Primary)

                -- Название таланта
                draw.SimpleText(talentID, "font_sans_16", 10, 15, NextRP.Style.Theme.Text)

                -- Ранг таланта
                draw.SimpleText("Ранг: " .. rank, "font_sans_16", 10, 35, NextRP.Style.Theme.HightlightText)
            end
        end
    end
end)

-- Команда для открытия админ панели
concommand.Add("nextrp_progression_admin", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("У вас нет прав для использования этой команды!")
        end
        return
    end

    NextRP.Progression:OpenAdminPanel()
end)

-- Добавляем в контекстное меню для админов
hook.Add("PopulateToolMenu", "NextRP::AddProgressionAdminMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "NextRP Admin", "ProgressionAdmin", "Управление прогрессией", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Label", {
            Text = "Админ панель для управления уровнями, опытом и талантами игроков"
        })

        panel:AddControl("Button", {
            Label = "Открыть панель управления",
            Command = "nextrp_progression_admin"
        })

        panel:AddControl("Label", {
            Text = "Доступно только администраторам"
        })
    end)
end)