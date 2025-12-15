-- pushup_game/sh_config.lua
-- Конфигурация модуля отжиманий с поддержкой prone

NextRP = NextRP or {}
NextRP.PushupGame = NextRP.PushupGame or {}

-- Константы типов сообщений (если не определены)
MESSAGE_TYPE_ERROR = MESSAGE_TYPE_ERROR or 0
MESSAGE_TYPE_WARNING = MESSAGE_TYPE_WARNING or 1  
MESSAGE_TYPE_SUCCESS = MESSAGE_TYPE_SUCCESS or 2

-- Конфигурация игры
NextRP.PushupGame.Config = {
    -- Время на нажатие каждой клавиши (секунды)
    timePerKey = 2.5,
    
    -- Максимальное количество отжиманий за сессию
    maxPushups = 5,
    
    -- Награда за каждое отжимание
    moneyPerPushup = 50,
    
    -- Опыт за каждое отжимание
    expPerPushup = 200,
    
    -- Минимальный уровень для игры
    minLevel = 1,
    
    -- Кулдаун между сессиями (секунды)
    cooldownTime = 0,
    
    -- Время блокировки между нажатиями клавиш (секунды)
    keyBlockTime = 0.3,
    
    -- Максимальное расстояние отхода от стартовой позиции (используется только если нет prone)
    maxMoveDistance = 50,
    
    -- Использовать систему prone для лежания (если доступна)
    useProneSystem = true,
    
    -- Выполнять анимацию салюта при успешном отжимании
    saluteOnSuccess = true,
    
    -- Возможные последовательности клавиш
    keySequences = {
        {KEY_W, KEY_A, KEY_S, KEY_D},
        {KEY_A, KEY_D, KEY_W, KEY_S}, 
        {KEY_S, KEY_W, KEY_D, KEY_A},
        {KEY_D, KEY_S, KEY_A, KEY_W},
        {KEY_W, KEY_S, KEY_A, KEY_D},
        {KEY_A, KEY_W, KEY_D, KEY_S}
    },
    
    -- Названия клавиш для отображения
    keyNames = {
        [KEY_W] = "W",
        [KEY_A] = "A",
        [KEY_S] = "S", 
        [KEY_D] = "D"
    }
}

-- Сообщения
NextRP.PushupGame.Messages = {
    gameStart = "Принимайте упор лёжа! Начинаем тренировку!",
    gameEnd = "Тренировка завершена! Отжиманий выполнено: %d",
    keyPrompt = "Нажмите клавишу: %s",
    timeUp = "Время вышло! Игра окончена.",
    success = "Отлично! Отжимание %d выполнено!",
    failure = "Неправильная клавиша! Игра окончена.",
    cooldown = "Отдохните немного! Осталось: %d сек.",
    levelTooLow = "Ваш уровень слишком низкий для этой тренировки!",
    alreadyPlaying = "Вы уже тренируетесь!",
    keyTooFast = "Не торопитесь! Подождите немного между нажатиями.",
    movedTooFar = "Вы отошли слишком далеко от места тренировки!",
    proneRequired = "Для тренировки необходимо принять упор лёжа!",
    cantEnterProne = "Вы не можете принять упор лёжа в этом месте!"
}

-- pushup_game/sh_prone_integration.lua
-- Интеграция модуля отжиманий с системой prone

-- Проверяем, доступна ли система prone
if not prone then
    print("[PushupGame] Система prone не найдена. Используется базовая блокировка движения.")
    return
end

-- Серверная часть интеграции
if SERVER then
    
    -- Предотвращаем выход из prone во время тренировки отжиманий
    hook.Add("prone.CanExit", "NextRP_PushupGame_PreventProneExit", function(ply)
        local steamID = ply:SteamID()
        if NextRP and NextRP.PushupGame and NextRP.PushupGame.ActivePlayers and NextRP.PushupGame.ActivePlayers[steamID] then
            -- Не разрешаем выходить из prone во время тренировки
            if CLIENT then
                chat.AddText(Color(255, 100, 100), "[Тренировка] Нельзя встать во время выполнения отжиманий!")
            end
            return false
        end
    end)
    
    -- Автоматически завершаем тренировку если игрок каким-то образом вышел из prone
    hook.Add("prone.OnPlayerExitted", "NextRP_PushupGame_CheckProneExit", function(ply)
        local steamID = ply:SteamID()
        if NextRP and NextRP.PushupGame and NextRP.PushupGame.ActivePlayers and NextRP.PushupGame.ActivePlayers[steamID] then
            local playerData = NextRP.PushupGame.ActivePlayers[steamID]
            if playerData and not playerData.wasInProne then
                -- Если игрок не был в prone изначально, но сейчас вышел из него - завершаем тренировку
                ply:SendMessage(MESSAGE_TYPE_WARNING, "Тренировка прервана - вы встали!")
                NextRP.PushupGame:EndGame(steamID, false)
                timer.Remove("NextRP_PushupGame_" .. steamID)
            end
        end
    end)
    
    -- Проверяем, может ли игрок начать тренировку в prone
    hook.Add("NextRP_PushupGame_CanStart", "NextRP_PushupGame_CheckProne", function(ply)
        -- Если игрок не в prone и не может лечь - не разрешаем начать тренировку
        if not ply:IsProne() and not prone.CanEnter(ply) then
            return false, "Вы не можете принять упор лёжа в этом месте!"
        end
        return true
    end)

else -- CLIENT
    
    -- Клиентские уведомления и эффекты
    hook.Add("prone.OnPlayerEntered", "NextRP_PushupGame_ProneEntered", function(ply)
        if ply == LocalPlayer() and NextRP.PushupGame.IsPlaying then
            -- Уведомление о том, что игрок принял упор лёжа для тренировки
            notification.AddLegacy("Упор лёжа принят! Готовьтесь к тренировке!", NOTIFY_HINT, 3)
        end
    end)
    
    -- Предупреждение при попытке встать во время тренировки
    hook.Add("KeyPress", "NextRP_PushupGame_PreventProneToggle", function(ply, key)
        if ply == LocalPlayer() and NextRP.PushupGame.IsPlaying then
            -- Если нажата клавиша для prone во время тренировки
            local proneKey = GetConVar("prone_bindkey_key")
            if proneKey and key == proneKey:GetInt() then
                chat.AddText(Color(255, 200, 100), "[Тренировка] Нельзя менять позицию во время выполнения отжиманий!")
                return true
            end
        end
    end)
    
end

-- Общие функции для обеих сторон
function NextRP.PushupGame:IsProneAvailable()
    return prone ~= nil and prone.Enter ~= nil and prone.Exit ~= nil
end

function NextRP.PushupGame:GetProneStatus(ply)
    if not self:IsProneAvailable() then
        return "unavailable"
    end
    
    if ply:IsProne() then
        return "prone"
    elseif prone.CanEnter(ply) then
        return "can_enter"
    else
        return "cannot_enter"
    end
end