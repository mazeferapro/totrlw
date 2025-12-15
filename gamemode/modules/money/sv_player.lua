--- @classmod Player

local pMeta = FindMetaTable('Player')

--- Устанавливает деньги игроку
-- @realm server
-- @tparam number nMoneyAmount кол-во денег для установки
function pMeta:SetMoney(nMoneyAmount)
    local oldMoney = self:GetMoney() or 0
    
    -- 1. Сразу обновляем NVar для клиента
    self:SetNVar('nrp_money', nMoneyAmount)
    
    -- 2. Обновляем кэш персонажа
    local char = self:CharacterByID(self:GetNVar('nrp_charid'))
    if char then
        char.money = nMoneyAmount
    end
    
    -- 3. Сохраняем в БД без колбэков
    local charid = self:GetNVar('nrp_charid')
    if charid and charid ~= -1 then
        MySQLite.query(string.format(
            "UPDATE nextrp_characters SET money = %d WHERE character_id = %d",
            nMoneyAmount,
            charid
        ))
        
        -- Обновляем глобальный кэш
        if NextRP.Chars.Cache[charid] then
            NextRP.Chars.Cache[charid].money = nMoneyAmount
        end
    end
    
    -- 4. Уведомляем клиент если есть изменения
    if oldMoney ~= nMoneyAmount then
        if netstream then
            netstream.Start(self, 'NextRP::MoneyUpdated', nMoneyAmount)
        end
        print("[Money] " .. self:Nick() .. " money: " .. oldMoney .. " -> " .. nMoneyAmount)
    end
end
--- Добавляет деньги игроку
-- @realm server
-- @tparam number nMoneyAmount кол-во денег для добавления
-- @treturn number Новый баланс игрока
function pMeta:AddMoney(nMoneyAmount)
    local curMoney = self:GetMoney()
    self:SetMoney(curMoney + nMoneyAmount)

    --return curMoney + nMoneyAmount
end

function pMeta:SendMoney(nMoneyAmount, pTarget)
    if not self:CanAfford(nMoneyAmount) then self:SendNotification('У вас недостаточно денег!', 0, 5, NextRP.Style.Theme.Accent, NextRP.Style.Theme.Text) return end
    if pTarget:IsPlayer() then
        self:AddMoney(-nMoneyAmount)
        self:SendNotification('Вы передали '..nMoneyAmount..' CR игроку '..pTarget:GetNVar('nrp_nickname'), 0, 3, NextRP.Style.Theme.Accent, NextRP.Style.Theme.Text)
        self:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_GIVE)
        pTarget:AddMoney(nMoneyAmount)
        pTarget:SendNotification('Вы получили '..nMoneyAmount..' CR от игрока '..self:GetNVar('nrp_nickname'), 0, 3, NextRP.Style.Theme.Accent, NextRP.Style.Theme.Text)
    end
end

function pMeta:CrystalSpeed()
    local Cryses = self.Cryses
    local job = NextRP.GetJob(self:Team())
    local flags = self:GetNVar('nrp_charflags')
    local wrspeed = false
    local jobspead = false
    local defW = 100
    local defR = 250
    local slow = ((Cryses >= 5 and Cryses < 10) and .9) or ((Cryses >= 10 and Cryses < 15) and .75) or ((Cryses >= 15 and Cryses < 20) and .5) or (Cryses >= 20 and .25) or 1
    if job.walkspead and job.runspead then jobspead = {job.walkspead, job.runspead} end
    for k, v in pairs(flags) do
        local flag = job.flags[k] or NextRP.Config.Pripiskis[k]
        if flag.replaceWalkandRunSpeed and wrspeed == false then wrspeed = {flag.walk, flag.run} end
    end
    if wrspeed ~= false then
        defW = wrspeed[1] >= defW and wrspeed[1] or defW
        defR = wrspeed[2] >= defR and wrspeed[2] or defR
    end

    if jobspead ~= false then
        defW = jobspead[1] >= defW and jobspead[1] or defW
        defR = jobspead[2] >= defR and jobspead[2] or defR
    end
    self:SetWalkSpeed(defW*slow)
    self:SetSlowWalkSpeed((defW-20)*slow)
    self:SetRunSpeed(defR*slow)
end

netstream.Hook('NextRP::Exchange', function(pPlayer, exc)
    if !exc then exc = 0 end
    pPlayer.Cryses = (pPlayer.Cryses - exc) > 0 and (pPlayer.Cryses - exc) or 0
    if exc <= 0 then pPlayer:SendNotification('0 CR за 0 кристаллов. Все верно.', 0, 3, NextRP.Style.Theme.Accent, NextRP.Style.Theme.Text) return end
    pPlayer:AddMoney(exc*250)
    --NextRP.Progression:AddXP(pPlayer, exc*100)
    pPlayer:SendNotification('Вы получили '..(exc*250)..' CR. Сдано кристаллов: '..exc, 0, 5, NextRP.Style.Theme.Accent, NextRP.Style.Theme.Text)
    pPlayer:CrystalSpeed()
end)

if not netstream then
    util.AddNetworkString("NextRP_MoneyUpdate")
end

concommand.Add("nextrp_givemoney", function(pPlayer, cmd, args)
        if not IsValid(pPlayer) or not pPlayer:IsAdmin() then 
            if IsValid(pPlayer) then
                pPlayer:ChatPrint("У вас нет прав для использования этой команды!")
            end
            return 
        end
        
        if #args < 2 then
            pPlayer:ChatPrint("Использование: nextrp_givemoney <имя игрока> <количество>")
            return
        end
        
        local playerName = args[1]
        local amount = tonumber(args[2])
        
        if not amount or amount <= 0 then
            pPlayer:ChatPrint("Количество денег должно быть положительным числом")
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
            pPlayer:ChatPrint("Нельзя выдать деньги администратору")
            return
        end
        
        -- Выдаем деньги
        targetPlayer:AddMoney(amount)
        
        -- Уведомления
        pPlayer:ChatPrint("Выдано " .. amount .. " CR игроку " .. targetPlayer:Nick())
        targetPlayer:SendNotification('Администратор выдал вам ' .. amount .. ' CR!', 0, 5, NextRP.Style.Theme.Accent, NextRP.Style.Theme.Text)
        
        -- Лог
        print("[Money] Админ " .. pPlayer:Nick() .. " выдал " .. amount .. " CR игроку " .. targetPlayer:Nick())
    end)

hook.Add("NextRP::InitializeCommands", "AddMoneyTransferCommand", function()
    NextRP:AddCommand("givemoney", function(pPlayer, sText)
        local args = string.Explode(" ", sText)
        
        if #args < 2 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Использование: /givemoney <имя игрока> <количество>")
            return
        end
        
        local playerName = args[1]
        local amount = tonumber(args[2])
        
        if not amount or amount <= 0 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Количество денег должно быть положительным числом")
            return
        end
        
        -- Проверяем, хватает ли денег
        if not pPlayer:CanAfford(amount) then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "У вас недостаточно денег! У вас: " .. (pPlayer:GetMoney() or 0) .. " CR")
            return
        end
        
        -- Ищем игрока по частичному совпадению имени
        local targetPlayer = nil
        local foundPlayers = {}
        
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), string.lower(playerName)) then
                table.insert(foundPlayers, ply)
            end
        end
        
        if #foundPlayers == 0 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Игрок с именем '" .. playerName .. "' не найден")
            return
        elseif #foundPlayers > 1 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Найдено несколько игроков. Будьте более точными:")
            for _, ply in ipairs(foundPlayers) do
                pPlayer:SendMessage(MESSAGE_TYPE_NONE, "- " .. ply:Nick())
            end
            return
        end
        
        targetPlayer = foundPlayers[1]
        
        -- Проверяем, что целевой игрок имеет персонажа
        if targetPlayer:GetNVar('nrp_charid') == -1 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя передать деньги администратору")
            return
        end
        
        -- Проверяем, что игрок не передает деньги самому себе
        if targetPlayer == pPlayer then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Вы не можете передать деньги самому себе!")
            return
        end
        
        -- Проверяем расстояние между игроками
        local distance = pPlayer:GetPos():Distance(targetPlayer:GetPos())
        if distance > 200 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Игрок слишком далеко! Подойдите ближе.")
            return
        end
        
        -- Используем существующую функцию SendMoney
        pPlayer:SendMoney(amount, targetPlayer)
        
        -- Лог операции
        print("[Money Transfer] " .. pPlayer:Nick() .. " передал " .. amount .. " CR игроку " .. targetPlayer:Nick())
    end)
    
    -- Команда для проверки баланса
    NextRP:AddCommand("money", function(pPlayer, sText)
        local money = pPlayer:GetMoney() or 0
        pPlayer:SendMessage(MESSAGE_TYPE_NONE, "Ваш баланс: " .. string.Comma(money) .. " CR")
    end)
end)