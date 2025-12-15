-- Файл: lua/nextrp/modules/progression/sh_commands.lua
-- Дополнительные команды для управления системой прогрессии

-- Серверные команды (только для сервера)
if SERVER then
    
    -- Улучшенная команда добавления опыта с поиском игрока по имени
    concommand.Add("nextrp_addxp_name", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
        
        if #args < 2 then
            pPlayer:ChatPrint("Использование: nextrp_addxp_name <имя игрока> <количество>")
            return
        end
        
        local playerName = args[1]
        local amount = tonumber(args[2])
        
        if not amount or amount <= 0 then
            pPlayer:ChatPrint("Количество опыта должно быть положительным числом")
            return
        end
        
        -- Ищем игрока по частичному совпадению имени
        local targetPlayer = nil
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), string.lower(playerName)) then
                targetPlayer = ply
                break
            end
        end
        
        if not targetPlayer then
            pPlayer:ChatPrint("Игрок с именем '" .. playerName .. "' не найден")
            return
        end
        
        if targetPlayer:GetNVar('nrp_charid') == -1 then
            pPlayer:ChatPrint("Нельзя добавить опыт администратору")
            return
        end
        
        NextRP.Progression:AddXP(targetPlayer, amount)
        pPlayer:ChatPrint("Добавлено " .. amount .. " опыта игроку " .. targetPlayer:Nick())
    end)
    
    -- Команда для установки уровня по имени
    concommand.Add("nextrp_setlevel_name", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then return end
        
        if #args < 2 then
            pPlayer:ChatPrint("Использование: nextrp_setlevel_name <имя игрока> <уровень>")
            return
        end
        
        local playerName = args[1]
        local level = tonumber(args[2])
        
        if not level or level < 1 or level > 50 then
            pPlayer:ChatPrint("Уровень должен быть от 1 до 50")
            return
        end
        
        -- Ищем игрока
        local targetPlayer = nil
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), string.lower(playerName)) then
                targetPlayer = ply
                break
            end
        end
        
        if not targetPlayer then
            pPlayer:ChatPrint("Игрок с именем '" .. playerName .. "' не найден")
            return
        end
        
        local charID = targetPlayer:GetNVar('nrp_charid')
        if charID == -1 then
            pPlayer:ChatPrint("Нельзя изменить уровень администратору")
            return
        end
        
        local char = targetPlayer:CharacterByID(charID)
        if not char then
            pPlayer:ChatPrint("Персонаж не найден")
            return
        end
        
        targetPlayer:SetCharValue('level', level, function()
            char.level = level
            targetPlayer:SetCharValue('exp', 0, function()
                char.exp = 0
                
                netstream.Start(targetPlayer, 'NextRP::ProgressionData', {
                    level = level,
                    xp = 0,
                    xpRequired = NextRP.Progression:GetXPForLevel(level + 1),
                    talentPoints = char.talent_points or 0
                })
                
                pPlayer:ChatPrint("Установлен уровень " .. level .. " игроку " .. targetPlayer:Nick())
                targetPlayer:SendMessage(MESSAGE_TYPE_WARNING, "Ваш уровень был изменен администратором на ", level)
            end)
        end)
    end)
    
    -- Команда для добавления очков талантов по имени
    concommand.Add("nextrp_addtalents_name", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
        
        if #args < 2 then
            pPlayer:ChatPrint("Использование: nextrp_addtalents_name <имя игрока> <количество>")
            return
        end
        
        local playerName = args[1]
        local amount = tonumber(args[2])
        
        if not amount or amount <= 0 then
            pPlayer:ChatPrint("Количество очков должно быть положительным числом")
            return
        end
        
        -- Ищем игрока
        local targetPlayer = nil
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), string.lower(playerName)) then
                targetPlayer = ply
                break
            end
        end
        
        if not targetPlayer then
            pPlayer:ChatPrint("Игрок с именем '" .. playerName .. "' не найден")
            return
        end
        
        local charID = targetPlayer:GetNVar('nrp_charid')
        if charID == -1 then
            pPlayer:ChatPrint("Нельзя добавить очки талантов администратору")
            return
        end
        
        local char = targetPlayer:CharacterByID(charID)
        if not char then
            pPlayer:ChatPrint("Персонаж не найден")
            return
        end
        
        local currentTalentPoints = char.talent_points or 0
        local newTalentPoints = currentTalentPoints + amount
        
        targetPlayer:SetCharValue('talent_points', newTalentPoints, function()
            char.talent_points = newTalentPoints
            
            netstream.Start(targetPlayer, 'NextRP::ProgressionData', {
                level = char.level or 1,
                xp = char.exp or 0,
                xpRequired = NextRP.Progression:GetXPForLevel((char.level or 1) + 1),
                talentPoints = newTalentPoints
            })
            
            pPlayer:ChatPrint("Добавлено " .. amount .. " очков талантов игроку " .. targetPlayer:Nick())
            targetPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Вам добавлено ", amount, " очков талантов администратором")
        end)
    end)
    
    -- Команда для просмотра прогресса игрока
    concommand.Add("nextrp_checkprogress", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
        
        if #args < 1 then
            pPlayer:ChatPrint("Использование: nextrp_checkprogress <имя игрока>")
            return
        end
        
        local playerName = args[1]
        
        -- Ищем игрока
        local targetPlayer = nil
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), string.lower(playerName)) then
                targetPlayer = ply
                break
            end
        end
        
        if not targetPlayer then
            pPlayer:ChatPrint("Игрок с именем '" .. playerName .. "' не найден")
            return
        end
        
        local charID = targetPlayer:GetNVar('nrp_charid')
        if charID == -1 then
            pPlayer:ChatPrint(targetPlayer:Nick() .. " - Администратор (нет прогресса)")
            return
        end
        
        local char = targetPlayer:CharacterByID(charID)
        if not char then
            pPlayer:ChatPrint("Персонаж не найден")
            return
        end
        
        local level = char.level or 1
        local xp = char.exp or 0
        local xpRequired = NextRP.Progression:GetXPForLevel(level + 1)
        local talentPoints = char.talent_points or 0
        
        pPlayer:ChatPrint("=== ПРОГРЕСС ИГРОКА " .. targetPlayer:Nick() .. " ===")
        pPlayer:ChatPrint("Уровень: " .. level)
        pPlayer:ChatPrint("Опыт: " .. xp .. " / " .. (xpRequired > 0 and xpRequired or "MAX"))
        pPlayer:ChatPrint("Очки талантов: " .. talentPoints)
        pPlayer:ChatPrint("Профессия: " .. targetPlayer:getJobTable().name)
        pPlayer:ChatPrint("SteamID: " .. targetPlayer:SteamID())
        
        -- Показываем таланты
        NextRP.Progression:GetCharacterTalents(targetPlayer, function(talents)
            if table.Count(talents) > 0 then
                pPlayer:ChatPrint("=== ИЗУЧЕННЫЕ ТАЛАНТЫ ===")
                for talentID, rank in pairs(talents) do
                    pPlayer:ChatPrint("- " .. talentID .. " (Ранг: " .. rank .. ")")
                end
            else
                pPlayer:ChatPrint("Изученных талантов нет")
            end
        end)
    end)
    
    -- Команда для сброса прогресса игрока
    concommand.Add("nextrp_resetprogress", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then return end
        
        if #args < 1 then
            pPlayer:ChatPrint("Использование: nextrp_resetprogress <имя игрока>")
            return
        end
        
        local playerName = args[1]
        
        -- Ищем игрока
        local targetPlayer = nil
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), string.lower(playerName)) then
                targetPlayer = ply
                break
            end
        end
        
        if not targetPlayer then
            pPlayer:ChatPrint("Игрок с именем '" .. playerName .. "' не найден")
            return
        end
        
        local charID = targetPlayer:GetNVar('nrp_charid')
        if charID == -1 then
            pPlayer:ChatPrint("Нельзя сбросить прогресс администратору")
            return
        end
        
        local char = targetPlayer:CharacterByID(charID)
        if not char then
            pPlayer:ChatPrint("Персонаж не найден")
            return
        end
        
        -- Сбрасываем уровень и опыт
        targetPlayer:SetCharValue('level', 1, function()
            char.level = 1
            targetPlayer:SetCharValue('exp', 0, function()
                char.exp = 0
                targetPlayer:SetCharValue('talent_points', 0, function()
                    char.talent_points = 0
                    
                    -- Удаляем все таланты
                    MySQLite.query(string.format(
                        "DELETE FROM nextrp_character_talents WHERE character_id = %s",
                        MySQLite.SQLStr(charID)
                    ), function()
                        -- Уведомляем игрока
                        netstream.Start(targetPlayer, 'NextRP::ProgressionData', {
                            level = 1,
                            xp = 0,
                            xpRequired = NextRP.Progression:GetXPForLevel(2),
                            talentPoints = 0
                        })
                        
                        netstream.Start(targetPlayer, 'NextRP::CharacterTalents', {})
                        
                        pPlayer:ChatPrint("Прогресс игрока " .. targetPlayer:Nick() .. " полностью сброшен")
                        targetPlayer:SendMessage(MESSAGE_TYPE_WARNING, "Ваш прогресс был сброшен администратором. Смените профессию для применения изменений.")
                        
                        -- Логируем
                        MsgC(Color(255, 0, 0), "[NextRP.Progression] СуперАдмин ", pPlayer:Nick(), " сбросил весь прогресс игрока ", targetPlayer:Nick(), "\n")
                    end)
                end)
            end)
        end)
    end)
    
    -- Команда для массового повышения уровня
    concommand.Add("nextrp_levelup_all", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then return end
        
        local levels = tonumber(args[1]) or 1
        if levels < 1 or levels > 10 then
            pPlayer:ChatPrint("Можно повысить от 1 до 10 уровней за раз")
            return
        end
        
        local count = 0
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
                local char = ply:CharacterByID(ply:GetNVar('nrp_charid'))
                if char then
                    local currentLevel = char.level or 1
                    local newLevel = math.min(currentLevel + levels, 50)
                    
                    if newLevel > currentLevel then
                        ply:SetCharValue('level', newLevel, function()
                            char.level = newLevel
                            ply:SetCharValue('exp', 0, function()
                                char.exp = 0
                                
                                -- Добавляем очки талантов
                                local talentPointsGained = newLevel - currentLevel
                                local currentTalentPoints = char.talent_points or 0
                                
                                ply:SetCharValue('talent_points', currentTalentPoints + talentPointsGained, function()
                                    char.talent_points = currentTalentPoints + talentPointsGained
                                    
                                    netstream.Start(ply, 'NextRP::LevelUp', {
                                        level = newLevel,
                                        xp = 0,
                                        xpRequired = NextRP.Progression:GetXPForLevel(newLevel + 1),
                                        talentPoints = currentTalentPoints + talentPointsGained
                                    })
                                end)
                            end)
                        end)
                        count = count + 1
                    end
                end
            end
        end
        
        pPlayer:ChatPrint("Повышен уровень у " .. count .. " игроков на " .. levels .. " уровней")
        
        -- Уведомляем всех
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
                ply:SendMessage(MESSAGE_TYPE_SUCCESS, "Администратор повысил всем игрокам уровень на ", levels, "!")
            end
        end
    end)
    
    -- Команда для создания события с наградой опыта
    concommand.Add("nextrp_xp_event", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
        
        local amount = tonumber(args[1]) or 100
        local reason = table.concat(args, " ", 2) or "участие в событии"
        
        if amount <= 0 then
            pPlayer:ChatPrint("Количество опыта должно быть положительным")
            return
        end
        
        -- Создаем глобальное уведомление
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                ply:SendMessage(MESSAGE_TYPE_WARNING, "🎉 СОБЫТИЕ! Все получают ", amount, " опыта за ", reason, "!")
            end
        end
        
        -- Добавляем опыт всем
        local count = 0
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
                NextRP.Progression:AddXP(ply, amount)
                count = count + 1
            end
        end
        
        pPlayer:ChatPrint("Событие создано! " .. count .. " игроков получили " .. amount .. " опыта")
        
        -- Логируем
        MsgC(Color(0, 255, 255), "[NextRP.Progression] Админ ", pPlayer:Nick(), " создал событие с наградой ", amount, " опыта: ", reason, "\n")
    end)
    
    -- Команда для просмотра онлайн статистики
    concommand.Add("nextrp_online_stats", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
        
        local players = {}
        local totalLevel = 0
        local maxLevel = 0
        local minLevel = 50
        local totalTalentPoints = 0
        
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
                local char = ply:CharacterByID(ply:GetNVar('nrp_charid'))
                if char then
                    local level = char.level or 1
                    local talentPoints = char.talent_points or 0
                    
                    table.insert(players, {
                        name = ply:Nick(),
                        level = level,
                        xp = char.exp or 0,
                        talentPoints = talentPoints
                    })
                    
                    totalLevel = totalLevel + level
                    maxLevel = math.max(maxLevel, level)
                    minLevel = math.min(minLevel, level)
                    totalTalentPoints = totalTalentPoints + talentPoints
                end
            end
        end
        
        if #players == 0 then
            pPlayer:ChatPrint("Нет игроков с активными персонажами")
            return
        end
        
        local avgLevel = totalLevel / #players
        
        pPlayer:ChatPrint("=== СТАТИСТИКА ОНЛАЙН ИГРОКОВ ===")
        pPlayer:ChatPrint("Всего игроков: " .. #players)
        pPlayer:ChatPrint("Средний уровень: " .. math.Round(avgLevel, 2))
        pPlayer:ChatPrint("Максимальный уровень: " .. maxLevel)
        pPlayer:ChatPrint("Минимальный уровень: " .. minLevel)
        pPlayer:ChatPrint("Всего очков талантов: " .. totalTalentPoints)
        
        -- Сортируем игроков по уровню
        table.sort(players, function(a, b) return a.level > b.level end)
        
        pPlayer:ChatPrint("=== ТОП 5 ИГРОКОВ ОНЛАЙН ===")
        for i = 1, math.min(5, #players) do
            local p = players[i]
            pPlayer:ChatPrint(i .. ". " .. p.name .. " - Уровень: " .. p.level .. " (XP: " .. p.xp .. ", Таланты: " .. p.talentPoints .. ")")
        end
    end)

end

-- Клиентские команды (для клиента и сервера)

-- Команда для быстрого доступа к админ панели
concommand.Add("nextrp_progression_panel", function(ply)
    if CLIENT then
        if not LocalPlayer():IsAdmin() then
            chat.AddText(Color(255, 0, 0), "У вас нет прав для использования этой команды!")
            return
        end
        NextRP.Progression:OpenAdminPanel()
    end
end)

-- Команда для быстрого просмотра собственного прогресса
concommand.Add("nextrp_mystats", function(ply)
    if CLIENT then
        local char = LocalPlayer():CharacterByID(LocalPlayer():GetNVar('nrp_charid'))
        if not char then
            chat.AddText(Color(255, 0, 0), "Персонаж не выбран!")
            return
        end
        
        local level = NextRP.Progression.PlayerData.level
        local xp = NextRP.Progression.PlayerData.xp
        local xpRequired = NextRP.Progression.PlayerData.xpRequired
        local talentPoints = NextRP.Progression.PlayerData.talentPoints
        
        chat.AddText(Color(0, 255, 0), "=== ВАШ ПРОГРЕСС ===")
        chat.AddText(Color(255, 255, 255), "Уровень: ", Color(0, 255, 255), tostring(level))
        chat.AddText(Color(255, 255, 255), "Опыт: ", Color(0, 255, 255), xp .. " / " .. (xpRequired > 0 and xpRequired or "MAX"))
        chat.AddText(Color(255, 255, 255), "Очки талантов: ", Color(0, 255, 255), tostring(talentPoints))
        
        if talentPoints > 0 then
            chat.AddText(Color(255, 255, 0), "У вас есть неиспользованные очки талантов! Используйте /talents")
        end
    elseif SERVER then
        if not IsValid(ply) then return end
        
        local charID = ply:GetNVar('nrp_charid')
        if not charID or charID == -1 then
            ply:ChatPrint("Персонаж не выбран или вы администратор")
            return
        end
        
        local char = ply:CharacterByID(charID)
        if not char then
            ply:ChatPrint("Персонаж не найден")
            return
        end
        
        local level = char.level or 1
        local xp = char.exp or 0
        local xpRequired = NextRP.Progression:GetXPForLevel(level + 1)
        local talentPoints = char.talent_points or 0
        
        ply:ChatPrint("=== ВАШ ПРОГРЕСС ===")
        ply:ChatPrint("Уровень: " .. level)
        ply:ChatPrint("Опыт: " .. xp .. " / " .. (xpRequired > 0 and xpRequired or "MAX"))
        ply:ChatPrint("Очки талантов: " .. talentPoints)
        
        if talentPoints > 0 then
            ply:ChatPrint("У вас есть неиспользованные очки талантов! Используйте /talents")
        end
    end
end)

-- Добавляем автодополнение для консольных команд
if CLIENT then
    -- Автодополнение имен игроков для админских команд
    local function GetPlayerNames()
        local names = {}
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                table.insert(names, "\"" .. ply:Nick() .. "\"")
            end
        end
        return names
    end
    
    -- Регистрируем автодополнение
    concommand.Add("nextrp_addxp_name", nil, GetPlayerNames)
    concommand.Add("nextrp_setlevel_name", nil, GetPlayerNames)
    concommand.Add("nextrp_addtalents_name", nil, GetPlayerNames)
    concommand.Add("nextrp_checkprogress", nil, GetPlayerNames)
    concommand.Add("nextrp_resetprogress", nil, GetPlayerNames)
end

-- Чат команды для удобства
if SERVER then
    hook.Add("PlayerSay", "NextRP::ProgressionChatCommands", function(ply, text)
        local args = string.Explode(" ", text)
        local cmd = string.lower(args[1])
        
        -- Команда для просмотра своего прогресса
        if cmd == "/mystats" or cmd == "!mystats" then
            RunConsoleCommand("nextrp_mystats")
            return ""
        end
        
        -- Админские команды через чат
        if ply:IsAdmin() then
            if cmd == "/addxp" or cmd == "!addxp" then
                if #args >= 3 then
                    local targetName = args[2]
                    local amount = tonumber(args[3])
                    if amount then
                        ply:ConCommand("nextrp_addxp_name \"" .. targetName .. "\" " .. amount)
                    else
                        ply:ChatPrint("Использование: /addxp <имя> <количество>")
                    end
                else
                    ply:ChatPrint("Использование: /addxp <имя> <количество>")
                end
                return ""
            end
            
            if cmd == "/setlevel" or cmd == "!setlevel" then
                if ply:IsSuperAdmin() and #args >= 3 then
                    local targetName = args[2]
                    local level = tonumber(args[3])
                    if level then
                        ply:ConCommand("nextrp_setlevel_name \"" .. targetName .. "\" " .. level)
                    else
                        ply:ChatPrint("Использование: /setlevel <имя> <уровень>")
                    end
                else
                    ply:ChatPrint("Использование: /setlevel <имя> <уровень> (только для суперадминов)")
                end
                return ""
            end
            
            if cmd == "/checkprogress" or cmd == "!checkprogress" then
                if #args >= 2 then
                    local targetName = args[2]
                    ply:ConCommand("nextrp_checkprogress \"" .. targetName .. "\"")
                else
                    ply:ChatPrint("Использование: /checkprogress <имя>")
                end
                return ""
            end
            
            if cmd == "/xpevent" or cmd == "!xpevent" then
                if #args >= 2 then
                    local amount = tonumber(args[2])
                    local reason = table.concat(args, " ", 3)
                    if amount then
                        ply:ConCommand("nextrp_xp_event " .. amount .. " " .. (reason or "событие"))
                    else
                        ply:ChatPrint("Использование: /xpevent <количество> [причина]")
                    end
                else
                    ply:ChatPrint("Использование: /xpevent <количество> [причина]")
                end
                return ""
            end
            
            if cmd == "/progressadmin" or cmd == "!progressadmin" then
                ply:ConCommand("nextrp_progression_admin")
                return ""
            end
        end
    end)
end

-- Регистрируем все команды в справочной системе
if SERVER then
    hook.Add("InitPostEntity", "RegisterProgressionCommands", function()
        -- Регистрируем команды в системе помощи (если есть)
        if NextRP.Help then
            NextRP.Help:RegisterCommand("/talents", "Открыть дерево талантов", "Все игроки")
            NextRP.Help:RegisterCommand("/mystats", "Посмотреть свой прогресс", "Все игроки")
            
            if LocalPlayer and LocalPlayer():IsValid() and LocalPlayer():IsAdmin() then
                NextRP.Help:RegisterCommand("/addxp <имя> <количество>", "Добавить опыт игроку", "Администраторы")
                NextRP.Help:RegisterCommand("/setlevel <имя> <уровень>", "Установить уровень игроку", "Суперадмины")
                NextRP.Help:RegisterCommand("/checkprogress <имя>", "Посмотреть прогресс игрока", "Администраторы")
                NextRP.Help:RegisterCommand("/xpevent <количество> [причина]", "Создать событие с наградой", "Администраторы")
                NextRP.Help:RegisterCommand("/progressadmin", "Открыть админ панель прогрессии", "Администраторы")
            end
        end
    end)
end

print("[NextRP.Progression] Дополнительные команды загружены!")