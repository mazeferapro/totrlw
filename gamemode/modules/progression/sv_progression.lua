--[[--
Модуль прогрессии персонажей
Управляет уровнями, опытом и талантами персонажей
]]--
-- @module NextRP.Progression

NextRP.Progression = NextRP.Progression or {}


-- Константы для расчета опыта
local XP_BASE = 1000  -- Базовый опыт для первого уровня
local XP_MULTIPLIER = 1.5  -- Множитель для каждого следующего уровня
local MAX_LEVEL = 50  -- Максимальный уровень

-- Загрузка деревьев талантов из базы данных
function NextRP.Progression:LoadTalentTrees()
    self.TalentTrees = self.TalentTrees or {}
    
    MySQLite.query("SELECT * FROM nextrp_talent_trees", function(results)
        if not results or not istable(results) then return end
        
        for _, row in ipairs(results) do
            local jobID = row.job_id
            local talentTree = util.JSONToTable(row.talent_tree)
            
            self.TalentTrees[jobID] = talentTree
        end
        
        MsgC(Color(0, 255, 0), "[NextRP.Progression] Деревья талантов загружены!\n")
    end)
end

-- Расчет необходимого опыта для уровня
function NextRP.Progression:GetXPForLevel(level)
    if level <= 1 then return 0 end
    if level > MAX_LEVEL then return -1 end -- -1 означает максимальный уровень
    
    return math.floor(XP_BASE * (XP_MULTIPLIER ^ (level - 1)))
end

-- Добавление опыта персонажу
function NextRP.Progression:AddXP(pPlayer, amount)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then return end
    
    local charID = pPlayer:GetNVar('nrp_charid')
    if charID == -1 then return end -- Не добавляем опыт администраторам
    
    local char = pPlayer:CharacterByID(charID)
    if not char then return end
    
    -- Получаем текущие значения уровня и опыта
    local currentLevel = char.level or 1
    local currentXP = char.exp or 0
    
    -- Если игрок уже на максимальном уровне, не добавляем опыт
    if currentLevel >= MAX_LEVEL then
        return
    end
    
    -- Добавляем опыт
    local tCP = ents.FindByClass('nextrp_controlpoint')
    local tJob = pPlayer:getJobTable()

    for _, cp in ipairs(tCP) do
        if tJob.control == cp:GetControl() then amount = amount + (amount * .02) end
    end
    local newXP = currentXP + amount
    local xpForNextLevel = self:GetXPForLevel(currentLevel + 1)
    local leveledUp = false
    local newLevel = currentLevel
    local talentPointsGained = 0
    
    -- Проверяем, повысился ли уровень
    while newXP >= xpForNextLevel and xpForNextLevel > 0 do
        newXP = newXP - xpForNextLevel
        newLevel = newLevel + 1
        talentPointsGained = talentPointsGained + 1
        leveledUp = true
        
        -- Если достигнут максимальный уровень, обнуляем опыт
        if newLevel >= MAX_LEVEL then
            newXP = 0
            break
        end
        
        xpForNextLevel = self:GetXPForLevel(newLevel + 1)
    end
    
    -- Обновляем данные в базе данных
    pPlayer:SetCharValue('exp', newXP, function()
        char.exp = newXP
        
        if leveledUp then
            pPlayer:SetCharValue('level', newLevel, function()
                char.level = newLevel
                
                -- Обновляем количество талант-поинтов
                local currentTalentPoints = char.talent_points or 0
                local newTalentPoints = currentTalentPoints + talentPointsGained
                
                pPlayer:SetCharValue('talent_points', newTalentPoints, function()
                    char.talent_points = newTalentPoints
                    
                    -- Уведомляем игрока о повышении уровня
                    netstream.Start(pPlayer, 'NextRP::LevelUp', {
                        level = newLevel,
                        xp = newXP,
                        xpRequired = self:GetXPForLevel(newLevel + 1),
                        talentPoints = newTalentPoints
                    })
                    
                    -- Уведомляем в чат
                    pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Вы достигли уровня ', newLevel, '! Получено ', talentPointsGained, ' очков талантов.')
                    
                    -- Хук для других модулей
                    hook.Run('NextRP::PlayerLevelUp', pPlayer, newLevel, talentPointsGained)
                end)
            end)
        else
            -- Просто уведомляем об изменении опыта
            netstream.Start(pPlayer, 'NextRP::XPUpdate', {
                xp = newXP,
                xpRequired = self:GetXPForLevel(currentLevel + 1)
            })
        end
    end)
    
    return newXP, leveledUp, newLevel
end

-- Получение талантов персонажа
function NextRP.Progression:GetCharacterTalents(pPlayer, callback)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then 
        if callback then callback({}) end
        return
    end
    
    local charID = pPlayer:GetNVar('nrp_charid')
    if charID == -1 then 
        if callback then callback({}) end
        return
    end
    
    MySQLite.query(string.format(
        "SELECT talent_id, `rank` FROM nextrp_character_talents WHERE character_id = %s",
        MySQLite.SQLStr(charID)
    ), function(results)
        local talents = {}
        
        if results and istable(results) then
            for _, row in ipairs(results) do
                talents[row.talent_id] = row.rank
            end
        end
        
        if callback then
            callback(talents)
        end
    end)
end

-- Добавление таланта персонажу
function NextRP.Progression:AddTalent(pPlayer, talentID, callback)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then 
        if callback then callback(false, "Персонаж не выбран") end
        return
    end
    
    local charID = pPlayer:GetNVar('nrp_charid')
    if charID == -1 then 
        if callback then callback(false, "Нельзя добавить талант администратору") end
        return
    end
    
    local char = pPlayer:CharacterByID(charID)
    if not char then 
        if callback then callback(false, "Персонаж не найден") end
        return
    end
    
    -- Проверяем, доступен ли талант для данной профессии
    local jobID = pPlayer:getJobTable().id
    local talentTree = self.TalentTrees[jobID]
    
    if not talentTree or not talentTree.talents or not talentTree.talents[talentID] then
        if callback then callback(false, "Данный талант недоступен для вашей профессии") end
        return
    end
    
    local talent = talentTree.talents[talentID]
    
    -- Проверяем, есть ли у персонажа необходимые очки талантов
    local talentPoints = char.talent_points or 0
    if talentPoints < 1 then
        if callback then callback(false, "Недостаточно очков талантов") end
        return
    end
    
    -- Получаем текущие таланты персонажа для проверки предпосылок
    self:GetCharacterTalents(pPlayer, function(currentTalents)
        -- Проверяем предпосылки для таланта
        if talent.prerequisites then
            for _, prereqID in ipairs(talent.prerequisites) do
                if not currentTalents[prereqID] then
                    if callback then callback(false, "Не выполнены предварительные требования") end
                    return
                end
            end
        end
        
        -- Проверяем, имеет ли персонаж уже этот талант
        local currentRank = currentTalents[talentID] or 0
        
        -- Проверяем, не достигнут ли максимальный ранг
        if currentRank >= (talent.maxRank or 1) then
            if callback then callback(false, "Достигнут максимальный ранг таланта") end
            return
        end
        
        -- Добавляем/обновляем талант
        local newRank = currentRank + 1
        
        MySQLite.query(string.format(
            "INSERT INTO nextrp_character_talents (character_id, talent_id, `rank`) VALUES (%s, %s, %d) ON DUPLICATE KEY UPDATE `rank` = %d",
            MySQLite.SQLStr(charID),
            MySQLite.SQLStr(talentID),
            newRank,
            newRank
        ), function()
            -- Уменьшаем количество очков талантов
            pPlayer:SetCharValue('talent_points', talentPoints - 1, function()
                char.talent_points = talentPoints - 1
                
                -- Применяем эффекты таланта
                self:ApplyTalentEffects(pPlayer, talentID, newRank)
                
                -- Уведомляем игрока
                netstream.Start(pPlayer, 'NextRP::TalentAdded', {
                    talent = talentID,
                    rank = newRank,
                    talentPoints = talentPoints - 1
                })
                
                -- Хук для других модулей
                hook.Run('NextRP::PlayerTalentAdded', pPlayer, talentID, newRank)
                
                if callback then callback(true) end
            end)
        end)
    end)
end

-- Применение эффектов таланта
function NextRP.Progression:ApplyTalentEffects(pPlayer, talentID, rank)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then return end
    
    -- Получаем полное дерево игрока (с флагами)
    local talentTree = self:GetPlayerTalentTree(pPlayer)
    
    if not talentTree or not talentTree.talents or not talentTree.talents[talentID] then
        -- Fallback на старый метод
        local jobID = pPlayer:getJobTable().id
        talentTree = self.TalentTrees[jobID]
        
        if not talentTree or not talentTree.talents or not talentTree.talents[talentID] then
            return
        end
    end
    
    local talent = talentTree.talents[talentID]
    
    -- Обрабатываем эффекты таланта
    if talent.effects then
        for effectType, effectValue in pairs(talent.effects) do
            local value = type(effectValue) == "table" and effectValue[rank] or effectValue
            
            if effectType == "health" then
                local currentRank = pPlayer:GetNVar('nrp_rankid')
                local charFlags = pPlayer:GetNVar('nrp_charflags')
                local jobTable = pPlayer:getJobTable()
                
                if jobTable and jobTable.ranks and jobTable.ranks[currentRank] then
                    local baseHP = jobTable.ranks[currentRank].hp or 100
                    
                    if charFlags and jobTable.flags then
                        for flagID, flagData in pairs(jobTable.flags) do
                            if not flagData.replaceHPandAR then continue end
                            if charFlags[flagID] and flagData.hp then
                                baseHP = flagData.hp
                                break
                            end
                        end
                    end
                    
                    pPlayer:SetMaxHealth(baseHP + value)
                    pPlayer:SetHealth(pPlayer:GetMaxHealth())
                end
                
            elseif effectType == "armor" then
                local currentRank = pPlayer:GetNVar('nrp_rankid')
                local charFlags = pPlayer:GetNVar('nrp_charflags')
                local jobTable = pPlayer:getJobTable()
                
                if jobTable and jobTable.ranks and jobTable.ranks[currentRank] then
                    local baseArmor = jobTable.ranks[currentRank].ar or 0
                    
                    if charFlags and jobTable.flags then
                        for flagID, flagData in pairs(jobTable.flags) do
                            if not flagData.replaceHPandAR then continue end
                            if charFlags[flagID] and flagData.ar then
                                baseArmor = flagData.ar
                                break
                            end
                        end
                    end
                    
                    pPlayer:SetArmor(baseArmor + value)
                end
                
            elseif effectType == "speed" then
                local currentWalk = pPlayer:GetWalkSpeed()
                local currentRun = pPlayer:GetRunSpeed()
                
                pPlayer:SetWalkSpeed(currentWalk + value)
                pPlayer:SetRunSpeed(currentRun + value)
                
            elseif effectType == "healthRegen" then
                pPlayer.HealthRegenAmount = (pPlayer.HealthRegenAmount or 0) + value
                
                local timerID = "TalentRegen_" .. pPlayer:SteamID64()
                if not timer.Exists(timerID) then
                    timer.Create(timerID, 1, 0, function()
                        if not IsValid(pPlayer) then
                            timer.Remove(timerID)
                            return
                        end
                        
                        if pPlayer:Health() >= pPlayer:GetMaxHealth() then return end
                        
                        pPlayer:SetHealth(math.min(
                            pPlayer:Health() + pPlayer.HealthRegenAmount,
                            pPlayer:GetMaxHealth()
                        ))
                        
                        netstream.Start(pPlayer, 'NextRP::HealthRegen', pPlayer.HealthRegenAmount)
                    end)
                end
            end
        end
    end

    -- !!! ВАЖНО: Мгновенный вызов LSCS интеграции !!!
    if self.LSCS and self.LSCS.ApplyTalentEffects then
        self.LSCS:ApplyTalentEffects(pPlayer, talent, rank)
    end
    
    hook.Run('NextRP::ApplyTalentEffect', pPlayer, talentID, rank, talent)
end

-- ============================================================================
-- ОБНОВИТЬ AddTalent чтобы проверять талант в полном дереве:
-- ============================================================================

function NextRP.Progression:AddTalent(pPlayer, talentID, callback)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then
        if callback then callback(false, "Игрок не найден") end
        return
    end
    
    local charID = pPlayer:GetNVar('nrp_charid')
    if charID == -1 then
        if callback then callback(false, "Персонаж не найден") end
        return
    end
    
    local char = pPlayer:CharacterByID(charID)
    if not char then
        if callback then callback(false, "Персонаж не загружен") end
        return
    end
    
    -- Получаем полное дерево игрока (с флагами)
    local talentTree = self:GetPlayerTalentTree(pPlayer)
    
    if not talentTree or not talentTree.talents then
        if callback then callback(false, "Дерево талантов не найдено") end
        return
    end
    
    local talent = talentTree.talents[talentID]
    if not talent then
        if callback then callback(false, "Талант не найден") end
        return
    end
    
    local talentPoints = char.talent_points or 0
    if talentPoints < 1 then
        if callback then callback(false, "Недостаточно очков талантов") end
        return
    end
    
    self:GetCharacterTalents(pPlayer, function(currentTalents)
        -- Проверяем пререквизиты
        if talent.prerequisites then
            for _, prereqID in ipairs(talent.prerequisites) do
                if not currentTalents[prereqID] then
                    if callback then callback(false, "Не выполнены предварительные требования") end
                    return
                end
            end
        end
        
        local currentRank = currentTalents[talentID] or 0
        
        if currentRank >= (talent.maxRank or 1) then
            if callback then callback(false, "Достигнут максимальный ранг таланта") end
            return
        end
        
        local newRank = currentRank + 1
        
        MySQLite.query(string.format(
            "INSERT INTO nextrp_character_talents (character_id, talent_id, `rank`) VALUES (%s, %s, %d) ON DUPLICATE KEY UPDATE `rank` = %d",
            MySQLite.SQLStr(charID),
            MySQLite.SQLStr(talentID),
            newRank,
            newRank
        ), function()
            pPlayer:SetCharValue('talent_points', talentPoints - 1, function()
                char.talent_points = talentPoints - 1
                
                self:ApplyTalentEffects(pPlayer, talentID, newRank)
                
                netstream.Start(pPlayer, 'NextRP::TalentAdded', {
                    talent = talentID,
                    rank = newRank,
                    talentPoints = talentPoints - 1
                })
                
                hook.Run('NextRP::PlayerTalentAdded', pPlayer, talentID, newRank)
                
                if callback then callback(true) end
            end)
        end)
    end)
end



-- Инициализация деревьев талантов для профессий
function NextRP.Progression:InitTalentTrees()
    -- Загружаем существующие деревья из базы данных
    self:LoadTalentTrees()
    
    -- Создаем стандартное дерево талантов для каждой профессии
    for jobID, job in pairs(NextRP.JobsByID) do
        -- Если для данной профессии еще нет дерева талантов, создаем его
        if not self.TalentTrees[jobID] then
            local talentTree = self:CreateDefaultTalentTree(jobID, job)
            
            if talentTree then
                -- Сохраняем в базу данных
                MySQLite.query(string.format(
                    "INSERT INTO nextrp_talent_trees (job_id, talent_tree) VALUES (%s, %s) ON DUPLICATE KEY UPDATE talent_tree = %s",
                    MySQLite.SQLStr(jobID),
                    MySQLite.SQLStr(util.TableToJSON(talentTree)),
                    MySQLite.SQLStr(util.TableToJSON(talentTree))
                ))
                
                self.TalentTrees[jobID] = talentTree
            end
        end
    end
end

-- Создание стандартного дерева талантов для профессии
function NextRP.Progression:CreateDefaultTalentTree(jobID, job)
    -- Используем конфигурацию из sh_talent_trees.lua
    local tree = NextRP.TalentTrees.GetJobTree(jobID)
    
    if tree then
        tree.jobID = jobID
        tree.name = job and job.name or tree.name
        return tree
    end
    
    -- Fallback на базовое дерево если конфигурации нет
    local defaultTree = NextRP.TalentTrees["_default"]
    if defaultTree then
        local result = table.Copy(defaultTree)
        result.jobID = jobID
        result.name = job and job.name or "Таланты"
        return result
    end
    
    return nil
end

-- Загрузка прогресса персонажа при входе в игру
function NextRP.Progression:LoadCharacterProgression(pPlayer)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') or not NextRP.GetJob(pPlayer:Team()) then return end
    
    local charID = pPlayer:GetNVar('nrp_charid')
    if charID == -1 then return end -- Пропускаем для администраторов
    
    local char = pPlayer:CharacterByID(charID)
    if not char then return end
    
    -- Отправляем данные о прогрессе клиенту
    netstream.Start(pPlayer, 'NextRP::ProgressionData', {
        level = char.level or 1,
        xp = char.exp or 0,
        xpRequired = self:GetXPForLevel((char.level or 1) + 1),
        talentPoints = char.talent_points or 0
    })
    
    -- Загружаем таланты персонажа
    self:GetCharacterTalents(pPlayer, function(talents)
        -- Применяем все таланты
        for talentID, rank in pairs(talents) do
            self:ApplyTalentEffects(pPlayer, talentID, rank)
        end
        
        -- Отправляем таланты клиенту
        netstream.Start(pPlayer, 'NextRP::CharacterTalents', talents)
    end)
end

-- Инициализация модуля
hook.Add("DatabaseInitialized", "NextRP::ProgressionInit", function()
    -- Инициализируем дерево талантов
    NextRP.Progression:InitTalentTrees()
    
    -- Хук на загрузку персонажа
    hook.Add("NextRP::CharacterSelected", "NextRP::LoadProgression", function(pPlayer, charID)
        timer.Simple(1, function() -- Небольшая задержка для уверенности, что персонаж полностью загружен
            NextRP.Progression:LoadCharacterProgression(pPlayer)
        end)
    end)
    
    MsgC(Color(0, 255, 0), "[NextRP.Progression] Модуль прогрессии инициализирован!\n")
end)

-- Добавляем команды для администраторов
concommand.Add("nextrp_addxp", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local target = player.GetByID(tonumber(args[1]) or 0)
    local amount = tonumber(args[2]) or 0
    
    if IsValid(target) and amount > 0 then
        NextRP.Progression:AddXP(target, amount)
        pPlayer:ChatPrint("Добавлено " .. amount .. " опыта игроку " .. target:Nick())
    else
        pPlayer:ChatPrint("Использование: nextrp_addxp <игрок ID> <количество>")
    end
end)

concommand.Add("nextrp_setlevel", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then return end
    
    local target = player.GetByID(tonumber(args[1]) or 0)
    local level = tonumber(args[2]) or 1
    
    if IsValid(target) and level > 0 and level <= MAX_LEVEL then
        local charID = target:GetNVar('nrp_charid')
        if charID == -1 then return end
        
        local char = target:CharacterByID(charID)
        if not char then return end
        
        target:SetCharValue('level', level, function()
            char.level = level
            target:SetCharValue('exp', 0, function()
                char.exp = 0
                
                -- Уведомляем игрока
                netstream.Start(target, 'NextRP::LevelUp', {
                    level = level,
                    xp = 0,
                    xpRequired = NextRP.Progression:GetXPForLevel(level + 1),
                    talentPoints = char.talent_points or 0
                })
                
                pPlayer:ChatPrint("Установлен уровень " .. level .. " игроку " .. target:Nick())
            end)
        end)
    else
        pPlayer:ChatPrint("Использование: nextrp_setlevel <игрок ID> <уровень>")
    end
end)

-- Примеры событий, дающих опыт (можно расширить)
hook.Add("PlayerDeath", "NextRP::KillXP", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end
    
    -- Давать опыт за убийство только если они враги
    local victimControl = victim:getJobTable().control
    local attackerControl = attacker:getJobTable().control
    
    if victimControl != attackerControl and victimControl != CONTROL_NONE and attackerControl != CONTROL_NONE then
        NextRP.Progression:AddXP(attacker, 50) -- 50 опыта за убийство врага
    end
end)

-- Функция для добавления опыта при выполнении заданий/событий
function NextRP.Progression:RewardXPForObjective(pPlayer, objectiveType, objectiveID)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then return end
    
    -- Различные награды за разные типы целей
    local xpRewards = {
        controlpoint_capture = 100,
        quest_complete = 200,
        event_participation = 150
    }
    
    local xpAmount = xpRewards[objectiveType] or 50
    
    -- Добавляем опыт
    self:AddXP(pPlayer, xpAmount)
    
    -- Уведомляем игрока
    pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Вы получили ', xpAmount, ' опыта за выполнение задания!')
end



-- Добавляем сетевые обработчики
netstream.Hook('NextRP::RequestTalentTree', function(pPlayer)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then return end
    
    local job = pPlayer:getJobTable()
    if not job then return end
    
    local jobID = job.id
    local flags = pPlayer:GetNVar('nrp_charflags') or {}
    
    -- Получаем дерево с учётом флагов игрока
    local talentTree = NextRP.TalentTrees.GetPlayerTree(jobID, flags)
    
    if not talentTree then
        talentTree = NextRP.Progression:CreateDefaultTalentTree(jobID, job)
    end
    
    if talentTree then
        NextRP.Progression:GetCharacterTalents(pPlayer, function(talents)
            netstream.Start(pPlayer, 'NextRP::TalentTreeData', {
                tree = talentTree,
                talents = talents
            })
        end)
    else
        netstream.Start(pPlayer, 'NextRP::TalentTreeData', {
            tree = {jobID = jobID, name = job.name, talents = {}},
            talents = {}
        })
    end
end)

function NextRP.Progression:GetPlayerTalentTree(pPlayer)
    if not IsValid(pPlayer) then return nil end
    
    local job = pPlayer:getJobTable()
    if not job then return nil end
    
    local jobID = job.id
    local flags = pPlayer:GetNVar('nrp_charflags') or {}
    
    return NextRP.TalentTrees.GetPlayerTree(jobID, flags)
end


-- Обработчик запроса на изучение таланта
netstream.Hook('NextRP::LearnTalent', function(pPlayer, talentID)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then return end
    
    NextRP.Progression:AddTalent(pPlayer, talentID, function(success, message)
        if not success then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, message)
        end
    end)
end)

-- Инициализация хуков для добавления опыта за различные действия
hook.Add("NextRP::ModulesLoaded", "NextRP::SetupXPHooks", function()
    -- Опыт за захват контрольных точек
    hook.Add("NextRP::ControlPointCaptured", "XP_ControlPointCapture", function(point, team)
        -- Даем опыт всем игрокам команды, находящимся рядом с точкой
        for _, ply in ipairs(team) do
            if IsValid(ply) and ply:GetPos():Distance(point:GetPos()) < 1000 then
                NextRP.Progression:AddXP(ply, 100)
            end
        end
    end)
    
    -- Опыт за время игры (каждые 10 минут)
    timer.Create("NextRP::PlaytimeXP", 600, 0, function()
        for _, ply in player.Iterator() do
            if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 and ply:Alive() then
                NextRP.Progression:AddXP(ply, 25) -- 25 опыта каждые 10 минут активной игры
            end
        end
    end)
    
    -- Опыт за лечение союзников
    hook.Add("NextRP::PlayerHealed", "XP_Healing", function(healer, target, amount)
        if IsValid(healer) and IsValid(target) and healer != target then
            NextRP.Progression:AddXP(healer, math.floor(amount / 10)) -- 1 опыт за каждые 10 единиц лечения
        end
    end)
    
    -- Опыт за помощь союзникам (ассисты)
    hook.Add("NextRP::PlayerAssisted", "XP_Assist", function(assistant, killer, victim)
        if IsValid(assistant) and assistant != killer and assistant != victim then
            NextRP.Progression:AddXP(assistant, 25) -- 25 опыта за ассист
        end
    end)
    
    -- Опыт за выполнение роли (для администраторов)
    hook.Add("NextRP::AdminRoleplayReward", "XP_RoleplayReward", function(admin, target, amount)
        if IsValid(admin) and admin:IsAdmin() and IsValid(target) then
            NextRP.Progression:AddXP(target, amount)
            admin:ChatPrint("Выдано " .. amount .. " опыта игроку " .. target:Nick() .. " за отыгрыш роли")
        end
    end)
end)

-- Обновление данных о прогрессии при повышении уровня
hook.Add("NextRP::PlayerLevelUp", "UpdateProgressionUI", function(pPlayer, newLevel, talentPointsGained)
    -- Дополнительные эффекты при повышении уровня
    local effects = {
        [5] = function(p) -- На 5 уровне
            p:SendMessage(MESSAGE_TYPE_WARNING, "Вы достигли 5 уровня! Вам доступны новые таланты.")
        end,
        [10] = function(p) -- На 10 уровне
            p:SendMessage(MESSAGE_TYPE_WARNING, "Вы достигли 10 уровня! Вам доступны продвинутые таланты.")
        end,
        [25] = function(p) -- На 25 уровне
            p:SendMessage(MESSAGE_TYPE_WARNING, "Вы достигли 25 уровня! Вы стали элитным воином.")
        end,
        [50] = function(p) -- На максимальном уровне
            p:SendMessage(MESSAGE_TYPE_WARNING, "Вы достигли максимального 50 уровня! Вы стали легендой.")
        end
    }
    
    -- Применяем эффекты, если они есть для данного уровня
    if effects[newLevel] then
        effects[newLevel](pPlayer)
    end
end)

-- Автоматическое сохранение изменений при выходе игрока
hook.Add("PlayerDisconnected", "SaveProgression", function(pPlayer)
    -- Ничего не делаем, так как изменения сохраняются сразу в базу данных
end)

-- Добавление интерфейса команд для персонажей
hook.Add("NextRP::InitializeCommands", "AddProgressionCommands", function()
    -- Команда для просмотра прогресса
    NextRP:AddCommand("level", function(pPlayer, sText)
        local char = pPlayer:CharacterByID(pPlayer:GetNVar('nrp_charid'))
        if not char then return end
        
        local level = char.level or 1
        local xp = char.exp or 0
        local xpRequired = NextRP.Progression:GetXPForLevel(level + 1)
        local talentPoints = char.talent_points or 0
        
        -- Уведомляем в чат
        pPlayer:SendMessage(MESSAGE_TYPE_NONE, "Уровень: ", level, " | Опыт: ", xp, "/", xpRequired, " | Очки талантов: ", talentPoints)
    end)
    
    -- Команда для открытия дерева талантов
    NextRP:AddCommand("talents", function(pPlayer, sText)
        netstream.Start(pPlayer, 'NextRP::OpenTalentTree')
    end)
end)

hook.Add("OnNPCKilled", "NextRP::NPCKillXP", function(npc, attacker, inflictor)
    -- Проверяем, что убийца - игрок
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
    -- Получаем максимальное здоровье NPC
    local npcMaxHealth = npc:GetMaxHealth()
    
    -- Базовый коэффициент для расчёта опыта
    local baseXPMultiplier = 0.2
    
    -- Рассчитываем награду за опыт на основе максимального здоровья
    local xpReward = math.floor(npcMaxHealth * baseXPMultiplier)
    
    -- Ограничиваем минимальное и максимальное значение
    xpReward = math.Clamp(xpReward, 5, 500)
    
    -- Добавляем опыт игроку
    NextRP.Progression:AddXP(attacker, xpReward)
    
    -- Уведомляем игрока об убийстве
    attacker:SendMessage(MESSAGE_TYPE_SUCCESS, 'Вы получили ', xpReward, ' опыта за убийство NPC!')
    
    -- Запускаем хук для других модулей
    hook.Run("NextRP::NPCKilled", attacker, npc, xpReward)
end)

hook.Add("EntityTakeDamage", "NextRP::TrackRegenDamage", function(target, dmgInfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    
    -- Если у игрока есть таймер регенерации, обновляем время последнего урона
    if target.HealthRegenTimer then
        target.LastDamageTime = CurTime()
    end
end)

hook.Add("PlayerDisconnected", "NextRP::CleanupRegenTimers", function(player)
    if player.HealthRegenTimer then
        timer.Remove(player.HealthRegenTimer)
        player.HealthRegenTimer = nil
        player.HasHealthRegen = nil
    end
end)

hook.Add("PlayerSpawn", "NextRP::ProgressionRespawn", function(pPlayer)
    if not IsValid(pPlayer) then return end
    
    -- Небольшая задержка для уверенности, что игрок полностью загружен
    timer.Simple(0.5, function()
        if not IsValid(pPlayer) then return end
        
        local charID = pPlayer:GetNVar('nrp_charid')
        if not charID or charID == -1 then return end -- Пропускаем администраторов
        
        -- Сбрасываем старые эффекты регенерации
        if pPlayer.HealthRegenTimer then
            timer.Remove(pPlayer.HealthRegenTimer)
            pPlayer.HealthRegenTimer = nil
        end
        
        pPlayer.HasHealthRegen = false
        pPlayer.HealthRegenAmount = 0
        pPlayer.LastDamageTime = CurTime()
        
        -- Перезагружаем прогресс персонажа
        NextRP.Progression:LoadCharacterProgression(pPlayer)
        
        -- Логируем для отладки
        MsgC(Color(0, 255, 255), "[NextRP.Progression] Прогресс перезагружен для игрока: ", pPlayer:Nick(), " (Респавн)\n")
    end)
end)

hook.Add("PlayerDeath", "NextRP::ProgressionDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end
    
    -- Останавливаем регенерацию здоровья
    if victim.HealthRegenTimer then
        timer.Remove(victim.HealthRegenTimer)
        victim.HealthRegenTimer = nil
    end
    
    victim.HasHealthRegen = false
    victim.HealthRegenAmount = 0
    
    -- Логируем
    MsgC(Color(255, 100, 100), "[NextRP.Progression] Временные эффекты сброшены для игрока: ", victim:Nick(), " (Смерть)\n")
end)

-- Инициализация игроков при входе в игру
hook.Add("PlayerInitialSpawn", "NextRP::InitHealthRegenSystem", function(player)
    player.HasHealthRegen = false
    player.HealthRegenAmount = 0
    player.LastDamageTime = CurTime()
end)

-- Сброс параметров регенерации при смене класса/профессии
hook.Add("NextRP::PlayerChangeTeam", "NextRP::ResetHealthRegen", function(player, oldTeam, newTeam)
    -- Сбрасываем параметры регенерации
    player.HasHealthRegen = false
    
    -- Удаляем таймер, если он существует
    if player.HealthRegenTimer then
        timer.Remove(player.HealthRegenTimer)
        player.HealthRegenTimer = nil
    end
    
    -- Таланты будут применены заново через загрузку прогресса персонажа
end)

hook.Add("NextRP::CharacterSelected", "NextRP::ResetHealthRegenOnCharSelect", function(pPlayer, charID)
    -- Немедленно сбросить предыдущие параметры регенерации
    if pPlayer.HealthRegenTimer then
        timer.Remove(pPlayer.HealthRegenTimer)
        pPlayer.HealthRegenTimer = nil
    end
    
    pPlayer.HasHealthRegen = false
    pPlayer.HealthRegenAmount = 0
    pPlayer.LastDamageTime = CurTime()
    
    -- Сбросить здоровье и броню до стандартных значений
    local currentRank = pPlayer:GetNVar('nrp_rankid')
    local jobTable = pPlayer:getJobTable()
    
    if jobTable and jobTable.ranks and jobTable.ranks[currentRank] then
        local baseHP = jobTable.ranks[currentRank].hp or 100
        local baseArmor = jobTable.ranks[currentRank].ar or 0
        
        pPlayer:SetMaxHealth(baseHP)
        pPlayer:SetHealth(baseHP)
        pPlayer:SetArmor(baseArmor)
    else
        pPlayer:SetMaxHealth(100)
        pPlayer:SetHealth(100)
        pPlayer:SetArmor(0)
    end

    pPlayer.TalentEnhancedRunSpeed = nil
    pPlayer.TalentEnhancedWalkSpeed = nil
    
    -- Ждем немного, чтобы убедиться, что все старые таймеры удалены
    timer.Simple(0.1, function()
        if IsValid(pPlayer) then
            -- Двойная проверка на удаление таймера регенерации
            if pPlayer.HealthRegenTimer then
                timer.Remove(pPlayer.HealthRegenTimer)
                pPlayer.HealthRegenTimer = nil
            end
            pPlayer.HasHealthRegen = false
            pPlayer.HealthRegenAmount = 0
        end
    end)
    
    -- Выполняем логирование для отладки
    print("[NextRP.Progression] Сброс регенерации для игрока: " .. pPlayer:Nick() .. " (SteamID: " .. pPlayer:SteamID() .. ")")
end)

-- Дополнительный хук для надежного мониторинга изменений персонажа
hook.Add("NextRP::PlayerChangeCharacter", "NextRP::StopRegenOnCharChange", function(pPlayer, oldCharID, newCharID)
    if pPlayer.HealthRegenTimer then
        timer.Remove(pPlayer.HealthRegenTimer)
        pPlayer.HealthRegenTimer = nil
    end
    
    pPlayer.HasHealthRegen = false
    pPlayer.HealthRegenAmount = 0
    
    print("[NextRP.Progression] Смена персонажа, регенерация остановлена: " .. pPlayer:Nick())
end)

-- Обновление существующего хука для восстановления здоровья
-- Заменить или модифицировать блок кода в функции NextRP.Progression:ApplyTalentEffects
-- где происходит добавление эффекта health_regen
if effectType == "health_regen" then
    -- Добавляем или обновляем параметр восстановления здоровья
    pPlayer.HealthRegenAmount = value
    pPlayer.HasHealthRegen = true
    pPlayer.LastDamageTime = CurTime()
    
    -- Удаляем существующий таймер, если он есть
    if pPlayer.HealthRegenTimer then
        timer.Remove(pPlayer.HealthRegenTimer)
        pPlayer.HealthRegenTimer = nil
    end
    
    -- Создаем новый таймер для регенерации здоровья с уникальным именем для игрока
    local timerName = "NextRP_HealthRegen_" .. pPlayer:SteamID64() .. "_" .. pPlayer:GetNVar('nrp_charid')
    pPlayer.HealthRegenTimer = timerName
    
    print("[NextRP.Progression] Создан таймер регенерации: " .. timerName .. " для " .. pPlayer:Nick())
    
    timer.Create(timerName, 1, 0, function()
        if not IsValid(pPlayer) or not pPlayer:Alive() or not pPlayer.HasHealthRegen or pPlayer:GetNVar('nrp_charid') ~= charID then
            timer.Remove(timerName)
            if IsValid(pPlayer) then
                pPlayer.HealthRegenTimer = nil
                pPlayer.HasHealthRegen = false
            end
            print("[NextRP.Progression] Таймер регенерации остановлен: " .. timerName)
            return
        end
        
        -- Остальной код регенерации без изменений...
    end)
end


-- API для других модулей
-- Добавление опыта за выполнение различных действий
function NextRP.Progression:RewardXPForAction(pPlayer, actionType, amount)
    if not IsValid(pPlayer) or not pPlayer:GetNVar('nrp_charid') then return end
    
    -- Базовые множители опыта для разных действий
    local multipliers = {
        combat = 1.0,      -- Боевые действия
        roleplay = 1.5,    -- Отыгрыш роли
        objective = 1.2,   -- Выполнение целей
        craft = 0.8,       -- Крафт предметов
        exploration = 0.7  -- Исследование
    }
    
    local multiplier = multipliers[actionType] or 1.0
    local finalAmount = math.floor(amount * multiplier)
    
    -- Добавляем опыт с множителем
    return self:AddXP(pPlayer, finalAmount)
end


concommand.Add("check_stats", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local target = ply
    
    -- Если указан аргумент и игрок админ, найти целевого игрока
    if args[1] and ply:IsAdmin() then
        for _, v in pairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()), string.lower(args[1])) then
                target = v
                break
            end
        end
    end
    
    if not IsValid(target) then
        ply:ChatPrint("Игрок не найден!")
        return
    end
    
    local health = target:Health()
    local maxHealth = target:GetMaxHealth()
    local armor = target:Armor()
    local maxArmor = target:GetMaxArmor()
    
    local message = target:Nick() .. " - HP: " .. health .. "/" .. maxHealth .. " | Armor: " .. armor .. "/" .. maxArmor
    
    print(message)
    ply:ChatPrint(message)
end)

netstream.Hook('NextRP::AdminRequestPlayerData', function(pPlayer, playerIndex)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(playerIndex)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then 
        netstream.Start(pPlayer, 'NextRP::AdminPlayerData', {
            level = 1,
            xp = 0,
            xpRequired = 100,
            talentPoints = 0,
            playerName = targetPlayer:Nick(),
            steamID = targetPlayer:SteamID()
        })
        return
    end
    
    local char = targetPlayer:CharacterByID(charID)
    if not char then return end
    
    local level = char.level or 1
    local xp = char.exp or 0
    local xpRequired = NextRP.Progression:GetXPForLevel(level + 1)
    local talentPoints = char.talent_points or 0
    
    netstream.Start(pPlayer, 'NextRP::AdminPlayerData', {
        level = level,
        xp = xp,
        xpRequired = xpRequired,
        talentPoints = talentPoints,
        playerName = targetPlayer:Nick(),
        steamID = targetPlayer:SteamID()
    })
end)

-- Установка уровня игрока
netstream.Hook('NextRP::AdminSetLevel', function(pPlayer, data)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(data.player)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local newLevel = data.level
    if not newLevel or newLevel < 1 or newLevel > 50 then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя изменить уровень администратору!")
        return
    end
    
    local char = targetPlayer:CharacterByID(charID)
    if not char then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Персонаж не найден!")
        return
    end
    
    -- Устанавливаем новый уровень
    targetPlayer:SetCharValue('level', newLevel, function()
        char.level = newLevel
        
        -- Сбрасываем опыт при изменении уровня
        targetPlayer:SetCharValue('exp', 0, function()
            char.exp = 0
            
            -- Уведомляем целевого игрока
            netstream.Start(targetPlayer, 'NextRP::ProgressionData', {
                level = newLevel,
                xp = 0,
                xpRequired = NextRP.Progression:GetXPForLevel(newLevel + 1),
                talentPoints = char.talent_points or 0
            })
            
            -- Уведомляем админа
            pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Уровень игрока ", targetPlayer:Nick(), " установлен на ", newLevel)
            
            -- Логируем действие
            MsgC(Color(255, 255, 0), "[NextRP.Progression] Админ ", pPlayer:Nick(), " установил уровень ", newLevel, " игроку ", targetPlayer:Nick(), "\n")
            
            -- Хук для других модулей
            hook.Run('NextRP::AdminLevelSet', pPlayer, targetPlayer, newLevel)
        end)
    end)
end)

-- Добавление опыта игроку
netstream.Hook('NextRP::AdminAddXP', function(pPlayer, data)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(data.player)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local xpAmount = data.amount
    if not xpAmount or xpAmount <= 0 then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя добавить опыт администратору!")
        return
    end
    
    -- Добавляем опыт через существующую функцию
    NextRP.Progression:AddXP(targetPlayer, xpAmount)
    
    -- Уведомляем админа
    pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Добавлено ", xpAmount, " опыта игроку ", targetPlayer:Nick())
    
    -- Логируем действие
    MsgC(Color(255, 255, 0), "[NextRP.Progression] Админ ", pPlayer:Nick(), " добавил ", xpAmount, " опыта игроку ", targetPlayer:Nick(), "\n")
    
    -- Хук для других модулей
    hook.Run('NextRP::AdminXPAdded', pPlayer, targetPlayer, xpAmount)
end)

-- Установка опыта игрока
netstream.Hook('NextRP::AdminSetXP', function(pPlayer, data)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(data.player)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local xpAmount = data.amount
    if not xpAmount or xpAmount < 0 then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя изменить опыт администратору!")
        return
    end
    
    local char = targetPlayer:CharacterByID(charID)
    if not char then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Персонаж не найден!")
        return
    end
    
    -- Устанавливаем опыт
    targetPlayer:SetCharValue('exp', xpAmount, function()
        char.exp = xpAmount
        
        -- Уведомляем целевого игрока
        netstream.Start(targetPlayer, 'NextRP::XPUpdate', {
            xp = xpAmount,
            xpRequired = NextRP.Progression:GetXPForLevel((char.level or 1) + 1)
        })
        
        -- Уведомляем админа
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Опыт игрока ", targetPlayer:Nick(), " установлен на ", xpAmount)
        
        -- Логируем действие
        MsgC(Color(255, 255, 0), "[NextRP.Progression] Админ ", pPlayer:Nick(), " установил опыт ", xpAmount, " игроку ", targetPlayer:Nick(), "\n")
        
        -- Хук для других модулей
        hook.Run('NextRP::AdminXPSet', pPlayer, targetPlayer, xpAmount)
    end)
end)

-- Добавление очков талантов
netstream.Hook('NextRP::AdminAddTalentPoints', function(pPlayer, data)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(data.player)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local talentAmount = data.amount
    if not talentAmount or talentAmount <= 0 then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя добавить очки талантов администратору!")
        return
    end
    
    local char = targetPlayer:CharacterByID(charID)
    if not char then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Персонаж не найден!")
        return
    end
    
    local currentTalentPoints = char.talent_points or 0
    local newTalentPoints = currentTalentPoints + talentAmount
    
    -- Обновляем очки талантов
    targetPlayer:SetCharValue('talent_points', newTalentPoints, function()
        char.talent_points = newTalentPoints
        
        -- Уведомляем целевого игрока
        netstream.Start(targetPlayer, 'NextRP::ProgressionData', {
            level = char.level or 1,
            xp = char.exp or 0,
            xpRequired = NextRP.Progression:GetXPForLevel((char.level or 1) + 1),
            talentPoints = newTalentPoints
        })
        
        -- Уведомляем админа
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Добавлено ", talentAmount, " очков талантов игроку ", targetPlayer:Nick())
        
        -- Логируем действие
        MsgC(Color(255, 255, 0), "[NextRP.Progression] Админ ", pPlayer:Nick(), " добавил ", talentAmount, " очков талантов игроку ", targetPlayer:Nick(), "\n")
        
        -- Хук для других модулей
        hook.Run('NextRP::AdminTalentPointsAdded', pPlayer, targetPlayer, talentAmount)
    end)
end)

-- Установка очков талантов
netstream.Hook('NextRP::AdminSetTalentPoints', function(pPlayer, data)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(data.player)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local talentAmount = data.amount
    if not talentAmount or talentAmount < 0 then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя изменить очки талантов администратору!")
        return
    end
    
    local char = targetPlayer:CharacterByID(charID)
    if not char then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Персонаж не найден!")
        return
    end
    
    -- Устанавливаем очки талантов
    targetPlayer:SetCharValue('talent_points', talentAmount, function()
        char.talent_points = talentAmount
        
        -- Уведомляем целевого игрока
        netstream.Start(targetPlayer, 'NextRP::ProgressionData', {
            level = char.level or 1,
            xp = char.exp or 0,
            xpRequired = NextRP.Progression:GetXPForLevel((char.level or 1) + 1),
            talentPoints = talentAmount
        })
        
        -- Уведомляем админа
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Очки талантов игрока ", targetPlayer:Nick(), " установлены на ", talentAmount)
        
        -- Логируем действие
        MsgC(Color(255, 255, 0), "[NextRP.Progression] Админ ", pPlayer:Nick(), " установил очки талантов ", talentAmount, " игроку ", targetPlayer:Nick(), "\n")
        
        -- Хук для других модулей
        hook.Run('NextRP::AdminTalentPointsSet', pPlayer, targetPlayer, talentAmount)
    end)
end)

-- Сброс всех талантов игрока
netstream.Hook('NextRP::AdminResetTalents', function(pPlayer, playerIndex)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(playerIndex)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя сбросить таланты администратору!")
        return
    end
    
    local char = targetPlayer:CharacterByID(charID)
    if not char then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Персонаж не найден!")
        return
    end
    
    -- Удаляем все таланты из базы данных
    MySQLite.query(string.format(
        "DELETE FROM nextrp_character_talents WHERE character_id = %s",
        MySQLite.SQLStr(charID)
    ), function()
        -- Сбрасываем эффекты талантов - требуется перезаход или смена профессии
        targetPlayer:SendMessage(MESSAGE_TYPE_WARNING, "Ваши таланты были сброшены администратором. Смените профессию или перезайдите для применения изменений.")
        
        -- Уведомляем целевого игрока об обновлении талантов
        netstream.Start(targetPlayer, 'NextRP::CharacterTalents', {})
        
        -- Уведомляем админа
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Все таланты игрока ", targetPlayer:Nick(), " были сброшены")
        
        -- Логируем действие
        MsgC(Color(255, 255, 0), "[NextRP.Progression] Админ ", pPlayer:Nick(), " сбросил все таланты игрока ", targetPlayer:Nick(), "\n")
        
        -- Хук для других модулей
        hook.Run('NextRP::AdminTalentsReset', pPlayer, targetPlayer)
    end)
end)

-- Запрос талантов игрока для просмотра
netstream.Hook('NextRP::AdminRequestTalents', function(pPlayer, playerIndex)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    local targetPlayer = Entity(playerIndex)
    if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
    
    local charID = targetPlayer:GetNVar('nrp_charid')
    if not charID or charID == -1 then
        netstream.Start(pPlayer, 'NextRP::AdminPlayerTalents', {
            talents = {},
            playerName = targetPlayer:Nick()
        })
        return
    end
    
    -- Получаем таланты игрока
    NextRP.Progression:GetCharacterTalents(targetPlayer, function(talents)
        netstream.Start(pPlayer, 'NextRP::AdminPlayerTalents', {
            talents = talents,
            playerName = targetPlayer:Nick()
        })
    end)
end)

-- Дополнительные админские команды через консоль

-- Команда для массового добавления опыта всем игрокам
concommand.Add("nextrp_addxp_all", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then return end
    
    local amount = tonumber(args[1]) or 0
    if amount <= 0 then
        pPlayer:ChatPrint("Использование: nextrp_addxp_all <количество>")
        return
    end
    
    local count = 0
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
            NextRP.Progression:AddXP(ply, amount)
            count = count + 1
        end
    end
    
    pPlayer:ChatPrint("Добавлено " .. amount .. " опыта " .. count .. " игрокам")
    
    -- Уведомляем всех игроков
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNVar('nrp_charid') and ply:GetNVar('nrp_charid') != -1 then
            ply:SendMessage(MESSAGE_TYPE_SUCCESS, "Администратор выдал всем игрокам ", amount, " опыта!")
        end
    end
    
    -- Логируем
    MsgC(Color(255, 0, 0), "[NextRP.Progression] СуперАдмин ", pPlayer:Nick(), " добавил ", amount, " опыта всем игрокам\n")
end)

-- Команда для просмотра топ игроков по уровню
concommand.Add("nextrp_top_levels", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsAdmin() then return end
    
    -- Получаем топ игроков из базы данных
    MySQLite.query(
        "SELECT name, level, exp FROM nextrp_characters WHERE level > 1 ORDER BY level DESC, exp DESC LIMIT 10",
        function(results)
            if not results or not istable(results) then
                pPlayer:ChatPrint("Нет данных о персонажах")
                return
            end
            
            pPlayer:ChatPrint("=== ТОП 10 ИГРОКОВ ПО УРОВНЮ ===")
            for i, row in ipairs(results) do
                pPlayer:ChatPrint(i .. ". " .. row.name .. " - Уровень: " .. row.level .. " (Опыт: " .. row.exp .. ")")
            end
        end
    )
end)

-- Команда для просмотра статистики прогрессии сервера
concommand.Add("nextrp_progression_stats", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then return end
    
    MySQLite.query(
        "SELECT AVG(level) as avg_level, MAX(level) as max_level, COUNT(*) as total_chars FROM nextrp_characters WHERE level > 0",
        function(results)
            if not results or not results[1] then
                pPlayer:ChatPrint("Нет данных для статистики")
                return
            end
            
            local data = results[1]
            pPlayer:ChatPrint("=== СТАТИСТИКА ПРОГРЕССИИ СЕРВЕРА ===")
            pPlayer:ChatPrint("Всего персонажей: " .. (data.total_chars or 0))
            pPlayer:ChatPrint("Средний уровень: " .. math.Round(data.avg_level or 0, 2))
            pPlayer:ChatPrint("Максимальный уровень: " .. (data.max_level or 0))
        end
    )
    
    -- Дополнительная статистика по талантам
    MySQLite.query(
        "SELECT COUNT(DISTINCT character_id) as chars_with_talents, COUNT(*) as total_talents FROM nextrp_character_talents",
        function(results)
            if results and results[1] then
                local data = results[1]
                pPlayer:ChatPrint("Персонажей с талантами: " .. (data.chars_with_talents or 0))
                pPlayer:ChatPrint("Всего изученных талантов: " .. (data.total_talents or 0))
            end
        end
    )
end)

-- Команда для резервного копирования данных прогрессии
concommand.Add("nextrp_backup_progression", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then return end
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupFile = "nextrp_progression_backup_" .. timestamp .. ".txt"
    
    -- Создаем резервную копию данных прогрессии
    MySQLite.query(
        "SELECT c.steamid, c.name, c.level, c.exp, c.talent_points FROM nextrp_characters c WHERE c.level > 0",
        function(results)
            if not results then
                pPlayer:ChatPrint("Ошибка при создании резервной копии")
                return
            end
            
            local backupData = {
                timestamp = os.time(),
                characters = results
            }
            
            -- Добавляем данные о талантах
            MySQLite.query(
                "SELECT ct.character_id, ct.talent_id, ct.'rank', c.steamid FROM nextrp_character_talents ct JOIN nextrp_characters c ON ct.character_id = c.id",
                function(talentResults)
                    if talentResults then
                        backupData.talents = talentResults
                    end
                    
                    local jsonData = util.TableToJSON(backupData, true)
                    file.Write(backupFile, jsonData)
                    
                    pPlayer:ChatPrint("Резервная копия прогрессии создана: " .. backupFile)
                    MsgC(Color(0, 255, 0), "[NextRP.Progression] Создана резервная копия: ", backupFile, "\n")
                end
            )
        end
    )
end)

-- Хук для автоматического логирования важных действий
hook.Add('NextRP::AdminLevelSet', 'LogAdminActions', function(admin, target, level)
    -- Записываем в лог файл (если есть система логирования)
    if NextRP.Logging then
        NextRP.Logging:AddLog('admin_progression', {
            admin = admin:SteamID(),
            target = target:SteamID(),
            action = 'set_level',
            value = level,
            timestamp = os.time()
        })
    end
end)

hook.Add('NextRP::AdminXPAdded', 'LogAdminActions', function(admin, target, amount)
    if NextRP.Logging then
        NextRP.Logging:AddLog('admin_progression', {
            admin = admin:SteamID(),
            target = target:SteamID(),
            action = 'add_xp',
            value = amount,
            timestamp = os.time()
        })
    end
end)

hook.Add('NextRP::AdminTalentsReset', 'LogAdminActions', function(admin, target)
    if NextRP.Logging then
        NextRP.Logging:AddLog('admin_progression', {
            admin = admin:SteamID(),
            target = target:SteamID(),
            action = 'reset_talents',
            timestamp = os.time()
        })
    end
end)

-- Функция для валидации админских действий
local function ValidateAdminAction(admin, target, actionType)
    if not IsValid(admin) or not admin:IsAdmin() then
        return false, "Нет прав администратора"
    end
    
    if not IsValid(target) or not target:IsPlayer() then
        return false, "Целевой игрок не найден"
    end
    
    if target:GetNVar('nrp_charid') == -1 then
        return false, "Нельзя изменять данные администратора"
    end
    
    -- Дополнительные проверки для разных типов действий
    if actionType == "set_level" and not admin:IsSuperAdmin() then
        return false, "Только суперадминистраторы могут устанавливать уровни"
    end
    
    return true
end

-- Улучшенная функция для отката изменений (если потребуется)
function NextRP.Progression:RevertAdminAction(actionID)
    -- Здесь можно реализовать систему отката действий администраторов
    -- Пока что заглушка для будущего развития
end

hook.Add("NextRP::FlagChanged", "NextRP::ProgressionFlagUpdate", function(pPlayer)
    if IsValid(pPlayer) then
        timer.Simple(0.5, function()
            if IsValid(pPlayer) then
                -- Отправляем обновлённое дерево клиенту
                local tree = NextRP.Progression:GetPlayerTalentTree(pPlayer)
                if tree then
                    NextRP.Progression:GetCharacterTalents(pPlayer, function(talents)
                        netstream.Start(pPlayer, 'NextRP::TalentTreeData', {
                            tree = tree,
                            talents = talents
                        })
                    end)
                end
            end
        end)
    end
end)

-- ============================================================================
-- ИНТЕГРАЦИЯ С LSCS: PROTECTION FIX (NO SAVE LOOP)
-- ============================================================================

NextRP.Progression.LSCS = NextRP.Progression.LSCS or {}

-- Инициализация БД
hook.Add("DatabaseInitialized", "NextRP::LSCS_DB_Init", function()
    MySQLite.query([[
        CREATE TABLE IF NOT EXISTS nextrp_lscs_inventory (
            character_id INTEGER NOT NULL,
            slot INTEGER NOT NULL,
            item_class TEXT NOT NULL,
            is_equipped INTEGER DEFAULT -1,
            PRIMARY KEY (character_id, slot)
        )
    ]])
    MsgC(Color(0, 255, 0), "[NextRP] LSCS Database Initialized.\n")
end)

function NextRP.Progression.LSCS:IsInstalled()
    local meta = FindMetaTable("Player")
    return meta and meta.lscsAddInventory ~= nil
end

-- Вспомогательные функции
function NextRP.Progression.LSCS:HasItem(pPlayer, itemClass)
    if not IsValid(pPlayer) then return false end
    local inventory = pPlayer:lscsGetInventory() or {}
    for _, item in pairs(inventory) do
        if item == itemClass then return true end
    end
    return false
end

function NextRP.Progression.LSCS:ClearInventory(pPlayer)
    if not IsValid(pPlayer) then return end
    if pPlayer.lscsWipeInventory then
        pPlayer:lscsWipeInventory(false)
    end
end

-- Получить безопасный ID
function NextRP.Progression.LSCS:GetSecureCharID(pPlayer)
    if not IsValid(pPlayer) then return nil end
    local charID = pPlayer:GetNVar('nrp_charid')
    if not charID or tonumber(charID) <= 0 then return nil end
    return tonumber(charID)
end

-- Выдача предмета (В обход сохранения, если это нужно)
function NextRP.Progression.LSCS:GiveLSCSItem(pPlayer, itemClass, autoEquip)
    if not IsValid(pPlayer) or not self:IsInstalled() then return false end
    
    if self:HasItem(pPlayer, itemClass) then return true end

    -- ВАЖНО: Если мы выдаем предмет через систему, мы временно блокируем сохранение,
    -- чтобы хук PostPlayerInventory не сработал и не перезаписал БД.
    pPlayer.NextRP_LSCS_IgnoreSave = true

    pPlayer:lscsAddInventory(itemClass, autoEquip)
    
    if pPlayer.lscsBuildPlayerInfo then 
        pPlayer:lscsBuildPlayerInfo() 
    end

    -- Снимаем блокировку сохранения через кадр
    timer.Simple(0.1, function()
        if IsValid(pPlayer) then pPlayer.NextRP_LSCS_IgnoreSave = false end
    end)
    
    -- Если это не загрузка персонажа, то сохраняем вручную безопасно
    if not pPlayer.NextRP_LSCS_IsLoading then
        local charID = self:GetSecureCharID(pPlayer)
        if charID then
            self:SaveCharacterInventory(pPlayer, charID)
        end
    end
    
    return true
end

function NextRP.Progression.LSCS:GiveForcePower(pPlayer, forcePowerID)
    return self:GiveLSCSItem(pPlayer, forcePowerID, false)
end

function NextRP.Progression.LSCS:GiveItem(pPlayer, itemType, itemID)
    local shouldEquip = (itemType == "stance")
    return self:GiveLSCSItem(pPlayer, itemID, shouldEquip)
end

function NextRP.Progression.LSCS:ApplyTalentEffects(pPlayer, talent, rank)
    if not talent or not talent.effects then return end
    
    local function ParseEffect(effectTable)
        local data = effectTable
        if data[rank] and type(data[rank]) == "table" then data = data[rank] end
        if istable(data) then
            for _, id in ipairs(data) do
                if type(id) == "string" then
                    if effectTable == talent.effects.lscsStances then
                        self:GiveItem(pPlayer, "stance", id)
                    else
                        self:GiveLSCSItem(pPlayer, id, false)
                    end
                end
            end
        end
    end

    if talent.effects.lscsForcePowers then ParseEffect(talent.effects.lscsForcePowers) end
    if talent.effects.lscsStances then ParseEffect(talent.effects.lscsStances) end
    if talent.effects.lscsHilts then ParseEffect(talent.effects.lscsHilts) end
    if talent.effects.lscsCrystals then ParseEffect(talent.effects.lscsCrystals) end
end

-- ============================================================================
-- СОХРАНЕНИЕ И ЗАГРУЗКА (CRITICAL FIX)
-- ============================================================================

function NextRP.Progression.LSCS:SaveCharacterInventory(pPlayer, charID)
    charID = charID or self:GetSecureCharID(pPlayer)
    
    if not IsValid(pPlayer) or not charID then return end
    if not self:IsInstalled() then return end
    
    -- !!! ГЛАВНАЯ ЗАЩИТА !!!
    -- Если персонаж сейчас ЗАГРУЖАЕТСЯ или ему выдается предмет скриптом,
    -- МЫ НЕ СОХРАНЯЕМ. Иначе мы сохраним неполный инвентарь поверх старого.
    if pPlayer.NextRP_LSCS_IsLoading or pPlayer.NextRP_LSCS_IgnoreSave then 
        return 
    end

    local inventory = pPlayer:lscsGetInventory() or {}
    local equipped = pPlayer:lscsGetEquipped() or {}

    MySQLite.begin()
    -- Удаляем только записи конкретного CharID
    MySQLite.query(string.format("DELETE FROM nextrp_lscs_inventory WHERE character_id = %d", charID))

    for slot, itemClass in pairs(inventory) do
        if not itemClass then continue end
        local equipStatus = -1
        local eqVal = equipped[slot]
        if eqVal == true then equipStatus = 1
        elseif eqVal == false then equipStatus = 0
        end
        
        MySQLite.query(string.format(
            "INSERT INTO nextrp_lscs_inventory (character_id, slot, item_class, is_equipped) VALUES (%d, %d, %s, %d)",
            charID, slot, MySQLite.SQLStr(itemClass), equipStatus
        ))
    end
    MySQLite.commit()
    -- Debug для проверки (можно убрать потом)
    -- MsgC(Color(0,255,0), "[NextRP] Saved LSCS for CharID: "..charID.."\n")
end

function NextRP.Progression.LSCS:LoadCharacterInventory(pPlayer, charID)
    charID = charID or self:GetSecureCharID(pPlayer)
    
    if not IsValid(pPlayer) or not charID then return end
    if not self:IsInstalled() then return end

    -- ВКЛЮЧАЕМ РЕЖИМ ЗАГРУЗКИ (Блокирует любые сохранения)
    pPlayer.NextRP_LSCS_IsLoading = true
    pPlayer.NextRP_LSCS_IgnoreSave = true

    -- Очищаем инвентарь
    self:ClearInventory(pPlayer)
    
    MySQLite.query(string.format("SELECT * FROM nextrp_lscs_inventory WHERE character_id = %d", charID), function(results)
        if not IsValid(pPlayer) then return end
        
        -- Проверяем, не сменился ли персонаж пока шел запрос
        local currentID = self:GetSecureCharID(pPlayer)
        if currentID ~= charID then
            MsgC(Color(255, 0, 0), "[NextRP] LSCS Load Aborted: Character Changed mid-load!\n")
            pPlayer.NextRP_LSCS_IsLoading = false
            pPlayer.NextRP_LSCS_IgnoreSave = false
            return 
        end

        if results then
            for _, row in ipairs(results) do
                local slot = tonumber(row.slot)
                local itemClass = row.item_class
                local equipStatus = tonumber(row.is_equipped)
                
                local equipArg = nil
                if equipStatus == 1 then equipArg = true
                elseif equipStatus == 0 then equipArg = false
                end
                
                -- Выдаем предмет (Хук сохранения сработает, но он будет заблокирован флагом IsLoading)
                pPlayer:lscsAddInventory(itemClass, equipArg, slot)
            end
        end
        
        if pPlayer.lscsBuildPlayerInfo then pPlayer:lscsBuildPlayerInfo() end
        
        MsgC(Color(0, 255, 0), "[NextRP] LSCS Loaded for CharID: " .. charID .. "\n")
        
        -- Снимаем режим загрузки с небольшой задержкой, чтобы все хуки успокоились
        timer.Simple(1.0, function()
            if IsValid(pPlayer) then 
                pPlayer.NextRP_LSCS_IsLoading = false 
                pPlayer.NextRP_LSCS_IgnoreSave = false
            end
        end)
    end)
end

-- ============================================================================
-- FIX PICKUP (C-MENU)
-- ============================================================================
hook.Add("InitPostEntity", "NextRP::FixLSCSPickup", function()
    local classes = {"lscs_pickupable", "lscs_hilt_base", "lscs_crystal_base", "lscs_stance_base", "lscs_force_base"}
    for _, class in ipairs(classes) do
        local ENT = scripted_ents.Get(class)
        if ENT then
            ENT.Use = function(self, activator, caller, type, value)
                if not IsValid(activator) or not activator:IsPlayer() then return end
                if self:GetPos():DistToSqr(activator:GetPos()) > 25000 then return end
                
                if activator.lscsAddInventory then
                    activator:lscsAddInventory(self:GetClass(), false)
                    self:Remove()
                    hook.Run("LSCS:PostPlayerInventory", activator, self:GetClass())
                end
            end
            scripted_ents.Register(ENT, class)
        end
    end
end)

-- ============================================================================
-- ХУКИ
-- ============================================================================

hook.Remove("NextRP::CharacterSelected", "NextRP::WipeLSCSOnCharSelect")

-- 1. Смена персонажа -> Сохраняем старого
hook.Add("NextRP::PlayerChangeCharacter", "NextRP::LSCS_SaveOnSwitch", function(pPlayer, oldCharID, newCharID)
    -- Сохраняем ТОЛЬКО если мы не в режиме загрузки
    if oldCharID and tonumber(oldCharID) > 0 and not pPlayer.NextRP_LSCS_IsLoading then
        NextRP.Progression.LSCS:SaveCharacterInventory(pPlayer, tonumber(oldCharID))
    end
end)

-- 2. Выход -> Сохраняем
hook.Add("PlayerDisconnected", "NextRP::LSCS_SaveOnDisconnect", function(pPlayer)
    local charID = NextRP.Progression.LSCS:GetSecureCharID(pPlayer)
    if charID and not pPlayer.NextRP_LSCS_IsLoading then
        NextRP.Progression.LSCS:SaveCharacterInventory(pPlayer, charID)
    end
end)

-- 3. Подбор предмета -> Сохраняем (ЕСЛИ НЕ ЗАГРУЗКА)
hook.Add("LSCS:PostPlayerInventory", "NextRP::LSCS_SaveOnPickup", function(pPlayer, item, index)
    -- Если флаг IsLoading или IgnoreSave стоит, то это добавление из базы или от скрипта
    -- МЫ НЕ ДОЛЖНЫ СОХРАНЯТЬ В ЭТОТ МОМЕНТ
    if pPlayer.NextRP_LSCS_IsLoading or pPlayer.NextRP_LSCS_IgnoreSave then 
        return 
    end
    
    local charID = NextRP.Progression.LSCS:GetSecureCharID(pPlayer)
    if charID then
        NextRP.Progression.LSCS:SaveCharacterInventory(pPlayer, charID)
    end
end)

-- 4. Выброс предмета -> Сохраняем
hook.Add("LSCS:OnPlayerDroppedItem", "NextRP::LSCS_SaveOnDrop", function(pPlayer, ent, id, item)
    if pPlayer.NextRP_LSCS_IsLoading or pPlayer.NextRP_LSCS_IgnoreSave then return end
    
    local charID = NextRP.Progression.LSCS:GetSecureCharID(pPlayer)
    if charID then
        NextRP.Progression.LSCS:SaveCharacterInventory(pPlayer, charID)
    end
end)

-- 5. Выбор персонажа -> Загружаем
hook.Add("NextRP::CharacterSelected", "NextRP::LSCS_LoadOnSelect", function(pPlayer, charID)
    -- Очищаем
    NextRP.Progression.LSCS:ClearInventory(pPlayer)
    
    if not charID or tonumber(charID) <= 0 then return end
    
    -- Задержка 0.5 сек для стабилизации
    timer.Simple(0.5, function()
        if IsValid(pPlayer) then
            NextRP.Progression.LSCS:LoadCharacterInventory(pPlayer, tonumber(charID))
        end
    end)
end)

-- 6. Догрузка талантов
hook.Add("NextRP::CharacterSelected", "NextRP::LoadLSCSFromTalents", function(pPlayer, charID)
    -- Ждем 1.5 сек (после завершения загрузки из базы)
    timer.Simple(1.5, function()
        if not IsValid(pPlayer) then return end
        local secureID = NextRP.Progression.LSCS:GetSecureCharID(pPlayer)
        if not secureID then return end

        local tree = NextRP.Progression:GetPlayerTalentTree(pPlayer)
        if not tree or not tree.talents then return end
        
        NextRP.Progression:GetCharacterTalents(pPlayer, function(talents)
            if not talents then return end
            for talentID, rank in pairs(talents) do
                local talent = tree.talents[talentID]
                if talent and rank > 0 then
                    NextRP.Progression.LSCS:ApplyTalentEffects(pPlayer, talent, rank)
                end
            end
        end)
    end)
end)