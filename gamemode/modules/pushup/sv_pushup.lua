-- modules/pushup/sv_pushup.lua
-- Серверная часть модуля отжиманий с интеграцией prone

-- Инициализируем структуру модуля
NextRP = NextRP or {}
NextRP.PushupGame = NextRP.PushupGame or {}

-- Создаем основные переменные модуля
NextRP.PushupGame.ActivePlayers = NextRP.PushupGame.ActivePlayers or {}
NextRP.PushupGame.PlayerCooldowns = NextRP.PushupGame.PlayerCooldowns or {}

-- Добавляем сетевые строки
util.AddNetworkString("NextRP_PushupGame_Start")
util.AddNetworkString("NextRP_PushupGame_End")
util.AddNetworkString("NextRP_PushupGame_KeyPress")
util.AddNetworkString("NextRP_PushupGame_UpdateHUD")

-- Функция начала игры для игрока
function NextRP.PushupGame:StartGame(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID()
    
    -- Проверки
    if self.ActivePlayers[steamID] then
        ply:SendMessage(MESSAGE_TYPE_ERROR, self.Messages.alreadyPlaying)
        return false
    end
    
    if (ply:GetNVar('nrp_level') or 1) < self.Config.minLevel then
        ply:SendMessage(MESSAGE_TYPE_ERROR, self.Messages.levelTooLow)
        return false
    end
    
    local cooldown = self.PlayerCooldowns[steamID]
    if cooldown and cooldown > CurTime() then
        local remaining = math.ceil(cooldown - CurTime())
        ply:SendMessage(MESSAGE_TYPE_WARNING, string.format(self.Messages.cooldown, remaining))
        return false
    end
    
    -- Проверяем, может ли игрок лечь (если есть prone система)
    if prone and prone.CanEnter and not prone.CanEnter(ply) then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Вы не можете принять упор лёжа в этом месте!")
        return false
    end
    
    -- Инициализация игрока
    self.ActivePlayers[steamID] = {
        player = ply,
        pushupCount = 0,
        currentSequence = {},
        currentStep = 1,
        startTime = CurTime(),
        stepStartTime = CurTime(),
        lastPos = ply:GetPos(),
        lastKeyTime = 0,
        originalWalkSpeed = ply:GetWalkSpeed(),
        originalRunSpeed = ply:GetRunSpeed(),
        originalDuckSpeed = ply:GetDuckSpeed(),
        originalUnDuckSpeed = ply:GetUnDuckSpeed(),
        wasInProne = ply.IsProne and ply:IsProne() or false -- Сохраняем состояние prone
    }
    
    -- Если есть система prone, заставляем игрока лечь
    if prone and prone.Enter then
        if not self.ActivePlayers[steamID].wasInProne then
            prone.Enter(ply)
        end
    end

    -- Всегда блокируем движение для отжиманий
    self:BlockPlayerMovement(ply, true)
    
    -- Генерируем последовательность
    self:GenerateSequence(steamID)
    
    -- Отправляем клиенту команду начать игру
    net.Start("NextRP_PushupGame_Start")
    net.Send(ply)
    
    ply:SendMessage(MESSAGE_TYPE_SUCCESS, self.Messages.gameStart)
    
    -- Запускаем таймер проверки
    self:StartGameTimer(steamID)
    
    return true
end

-- Блокировка/разблокировка движения игрока (используется только если нет prone)
-- Блокировка/разблокировка движения игрока
function NextRP.PushupGame:BlockPlayerMovement(ply, block)
   if not IsValid(ply) then return end
   
   if block then
       -- Блокируем движение полностью
       ply:SetWalkSpeed(0)
       ply:SetRunSpeed(0)
       ply:SetDuckSpeed(0)
       ply:SetUnDuckSpeed(0)
       
       -- Добавляем хук для полной блокировки движения
       hook.Add("SetupMove", "NextRP_PushupGame_BlockMove_" .. ply:SteamID(), function(target, mv, cmd)
           if target == ply then
               -- Полностью блокируем движение, разрешаем только поворот камеры
               mv:SetForwardSpeed(0)
               mv:SetSideSpeed(0)
               mv:SetUpSpeed(0)
               mv:SetMaxSpeed(0)
               mv:SetMaxClientSpeed(0)
               
               -- Принуждаем к приседанию
               cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))
               
               -- Блокируем прыжки и другие действия
               if cmd:KeyDown(IN_JUMP) then
                   cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
               end
           end
       end)
   else
       -- Разблокируем движение
       local playerData = self.ActivePlayers[ply:SteamID()]
       if playerData then
           ply:SetWalkSpeed(playerData.originalWalkSpeed)
           ply:SetRunSpeed(playerData.originalRunSpeed)
           ply:SetDuckSpeed(playerData.originalDuckSpeed)
           ply:SetUnDuckSpeed(playerData.originalUnDuckSpeed)
       else
           -- Стандартные значения
           ply:SetWalkSpeed(100)
           ply:SetRunSpeed(200)
           ply:SetDuckSpeed(0.3)
           ply:SetUnDuckSpeed(0.3)
       end
       
       -- Убираем хук блокировки движения
       hook.Remove("SetupMove", "NextRP_PushupGame_BlockMove_" .. ply:SteamID())
   end
end

-- Генерация новой последовательности клавиш
function NextRP.PushupGame:GenerateSequence(steamID)
    local playerData = self.ActivePlayers[steamID]
    if not playerData then return end
    
    local sequences = self.Config.keySequences
    local sequence = sequences[math.random(1, #sequences)]
    
    playerData.currentSequence = table.Copy(sequence)
    playerData.currentStep = 1
    playerData.stepStartTime = CurTime()
    playerData.lastKeyTime = 0 -- Сбрасываем время последнего нажатия
    
    -- Отправляем последовательность клиенту
    net.Start("NextRP_PushupGame_UpdateHUD")
    net.WriteTable({
        sequence = playerData.currentSequence,
        currentStep = playerData.currentStep,
        pushupCount = playerData.pushupCount,
        timeLeft = self.Config.timePerKey
    })
    net.Send(playerData.player)
end

-- Завершить игру
function NextRP.PushupGame:EndGame(steamID, success)
    local playerData = self.ActivePlayers[steamID]
    if not playerData then return end
    
    local ply = playerData.player
    if IsValid(ply) then
        -- Восстанавливаем состояние prone или разблокируем движение
        if prone and prone.Exit and prone.End then
            if not playerData.wasInProne then
                -- Если игрок не был в prone до начала игры, выводим его из prone
                if ply.IsProne and ply:IsProne() then
                    prone.Exit(ply)
                end
            end
        else
            -- Если нет системы prone, разблокируем движение
            self:BlockPlayerMovement(ply, false)
        end
        
        if success and playerData.pushupCount > 0 then
            -- Выдаем награды
            local money = playerData.pushupCount * self.Config.moneyPerPushup
            local exp = playerData.pushupCount * self.Config.expPerPushup
            
            -- Добавляем опыт (если есть система прогрессии)
            if NextRP and NextRP.Progression then
                NextRP.Progression:AddXP(ply, exp)
            end
            
            ply:SendMessage(MESSAGE_TYPE_SUCCESS, string.format(self.Messages.gameEnd, playerData.pushupCount))
        end
        
        -- Устанавливаем кулдаун
        self.PlayerCooldowns[steamID] = CurTime() + self.Config.cooldownTime
        
        -- Отправляем клиенту команду завершить игру
        net.Start("NextRP_PushupGame_End")
        net.WriteBool(success)
        net.WriteInt(playerData.pushupCount, 8)
        net.Send(ply)
    end
    
    self.ActivePlayers[steamID] = nil

    self:BlockPlayerMovement(ply, false)
end

-- Таймер игры
function NextRP.PushupGame:StartGameTimer(steamID)
    timer.Create("NextRP_PushupGame_" .. steamID, 0.1, 0, function()
        local playerData = NextRP.PushupGame.ActivePlayers[steamID]
        if not playerData then
            timer.Remove("NextRP_PushupGame_" .. steamID)
            return
        end
        
        local ply = playerData.player
        if not IsValid(ply) then
            NextRP.PushupGame:EndGame(steamID, false)
            timer.Remove("NextRP_PushupGame_" .. steamID)
            return
        end
        
        -- Проверяем, не отошел ли игрок далеко (если нет prone или он не в prone)
        if not (ply.IsProne and ply:IsProne()) then
            if playerData.lastPos:Distance(ply:GetPos()) > NextRP.PushupGame.Config.maxMoveDistance then
                ply:SendMessage(MESSAGE_TYPE_ERROR, NextRP.PushupGame.Messages.movedTooFar)
                NextRP.PushupGame:EndGame(steamID, false)
                timer.Remove("NextRP_PushupGame_" .. steamID)
                return
            end
        end
        
        -- Проверяем время на текущий шаг
        local timeLeft = NextRP.PushupGame.Config.timePerKey - (CurTime() - playerData.stepStartTime)
        if timeLeft <= 0 then
            ply:SendMessage(MESSAGE_TYPE_ERROR, NextRP.PushupGame.Messages.timeUp)
            NextRP.PushupGame:EndGame(steamID, false)
            timer.Remove("NextRP_PushupGame_" .. steamID)
            return
        end
        
        -- Обновляем HUD
        net.Start("NextRP_PushupGame_UpdateHUD")
        net.WriteTable({
            sequence = playerData.currentSequence,
            currentStep = playerData.currentStep,
            pushupCount = playerData.pushupCount,
            timeLeft = math.max(0, timeLeft)
        })
        net.Send(ply)
    end)
end

-- Обработка нажатия клавиш
net.Receive("NextRP_PushupGame_KeyPress", function(len, ply)
    local key = net.ReadInt(32)
    local steamID = ply:SteamID()
    local playerData = NextRP.PushupGame.ActivePlayers[steamID]
    
    if not playerData then return end
    
    -- Система предотвращения ложных срабатываний
    local currentTime = CurTime()
    if currentTime - playerData.lastKeyTime < NextRP.PushupGame.Config.keyBlockTime then
        ply:SendMessage(MESSAGE_TYPE_WARNING, NextRP.PushupGame.Messages.keyTooFast)
        return
    end
    
    playerData.lastKeyTime = currentTime
    
    local expectedKey = playerData.currentSequence[playerData.currentStep]
    
    if key == expectedKey then
        -- Правильная клавиша
        playerData.currentStep = playerData.currentStep + 1
        
        if playerData.currentStep > #playerData.currentSequence then
            -- Отжимание завершено
            playerData.pushupCount = playerData.pushupCount + 1
            
            -- Выполняем анимацию салюта при завершении отжимания
            ply:DoAnimationEvent(ACT_GMOD_TAUNT_SALUTE)
            
            ply:Say("/me Отжался " .. playerData.pushupCount, false)
            ply:SendMessage(MESSAGE_TYPE_SUCCESS, string.format(NextRP.PushupGame.Messages.success, playerData.pushupCount))
            
            if playerData.pushupCount >= NextRP.PushupGame.Config.maxPushups then
                -- Достигнут максимум
                NextRP.PushupGame:EndGame(steamID, true)
                timer.Remove("NextRP_PushupGame_" .. steamID)
            else
                -- Генерируем новую последовательность
                NextRP.PushupGame:GenerateSequence(steamID)
            end
        else
            -- Переходим к следующей клавише
            playerData.stepStartTime = CurTime()
        end
    else
        -- Неправильная клавиша
        ply:SendMessage(MESSAGE_TYPE_ERROR, NextRP.PushupGame.Messages.failure)
        NextRP.PushupGame:EndGame(steamID, false)
        timer.Remove("NextRP_PushupGame_" .. steamID)
    end
end)

-- Команда для начала игры
hook.Add("PlayerSay", "NextRP_PushupGame_Command", function(ply, text)
    if string.lower(text) == "/pushup" or string.lower(text) == "/отжимания" then
        NextRP.PushupGame:StartGame(ply)
        return ""
    end
end)

-- Очистка при отключении игрока
hook.Add("PlayerDisconnected", "NextRP_PushupGame_Cleanup", function(ply)
    local steamID = ply:SteamID()
    
    -- Восстанавливаем состояние prone или разблокируем движение
    local playerData = NextRP.PushupGame.ActivePlayers[steamID]
    if playerData then
        if prone and prone.Exit then
            if not playerData.wasInProne and ply.IsProne and ply:IsProne() then
                prone.Exit(ply)
            end
        else
            NextRP.PushupGame:BlockPlayerMovement(ply, false)
        end
    end
    
    -- Очищаем данные
    NextRP.PushupGame.ActivePlayers[steamID] = nil
    timer.Remove("NextRP_PushupGame_" .. steamID)
end)

-- Очистка при смене персонажа или команды
hook.Add("OnPlayerChangedTeam", "NextRP_PushupGame_TeamChange", function(ply, oldTeam, newTeam)
    local steamID = ply:SteamID()
    if NextRP.PushupGame.ActivePlayers[steamID] then
        NextRP.PushupGame:EndGame(steamID, false)
        timer.Remove("NextRP_PushupGame_" .. steamID)
    end
end)

-- Хук для предотвращения выхода из prone во время тренировки
if prone then
    hook.Add("prone.CanExit", "NextRP_PushupGame_PreventProneExit", function(ply)
        local steamID = ply:SteamID()
        if NextRP.PushupGame.ActivePlayers[steamID] then
            -- Не разрешаем выходить из prone во время тренировки
            return false
        end
    end)
end