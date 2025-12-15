-- modules/pushup/cl_pushup.lua  
-- Клиентская часть модуля отжиманий с поддержкой prone

NextRP = NextRP or {}
NextRP.PushupGame = NextRP.PushupGame or {}
NextRP.PushupGame.IsPlaying = false
NextRP.PushupGame.GameData = {}
NextRP.PushupGame.LastKeyPress = 0
NextRP.PushupGame.WasInProne = false

-- Получение начала игры
net.Receive("NextRP_PushupGame_Start", function()
    NextRP.PushupGame.IsPlaying = true
    NextRP.PushupGame.GameData = {}
    NextRP.PushupGame.LastKeyPress = 0
    
    -- Сохраняем, был ли игрок в prone до начала игры
    if LocalPlayer().IsProne then
        NextRP.PushupGame.WasInProne = LocalPlayer():IsProne()
    end
    
    -- Включаем захват клавиш
    hook.Add("Think", "NextRP_PushupGame_KeyCapture", function()
        if not NextRP.PushupGame.IsPlaying then return end
        
        local currentTime = CurTime()
        local keys = {KEY_W, KEY_A, KEY_S, KEY_D}
        
        -- Система предотвращения ложных срабатываний
        for _, key in pairs(keys) do
            if input.IsKeyDown(key) and (currentTime - NextRP.PushupGame.LastKeyPress) > NextRP.PushupGame.Config.keyBlockTime then
                NextRP.PushupGame.LastKeyPress = currentTime
                
                net.Start("NextRP_PushupGame_KeyPress")
                net.WriteInt(key, 32)
                net.SendToServer()
                
                break
            end
        end
    end)
    
    -- Блокируем некоторые клавиши движения (если не используется prone)
    hook.Add("PlayerBindPress", "NextRP_PushupGame_BlockKeys", function(ply, bind, pressed)
        if not NextRP.PushupGame.IsPlaying then return end
        if ply ~= LocalPlayer() then return end
        
        -- Блокируем прыжки и другие действия во время отжиманий
        if bind == "+jump" or bind == "+reload" or bind == "+use" then
            return true
        end
        
        -- Если используется prone система, блокируем команду prone во время тренировки
        if prone and bind == "prone" then
            return true
        end
    end)
end)

-- Получение завершения игры
net.Receive("NextRP_PushupGame_End", function()
    local success = net.ReadBool()
    local pushupCount = net.ReadInt(8)
    
    NextRP.PushupGame.IsPlaying = false
    NextRP.PushupGame.GameData = {}
    NextRP.PushupGame.LastKeyPress = 0
    NextRP.PushupGame.WasInProne = false
    
    hook.Remove("Think", "NextRP_PushupGame_KeyCapture")
    hook.Remove("PlayerBindPress", "NextRP_PushupGame_BlockKeys")
    
    if success then
        surface.PlaySound("buttons/button14.wav")
    else
        surface.PlaySound("buttons/button10.wav")
    end
end)

-- Обновление данных для HUD
net.Receive("NextRP_PushupGame_UpdateHUD", function()
    NextRP.PushupGame.GameData = net.ReadTable()
end)

-- Отрисовка HUD
hook.Add("HUDPaint", "NextRP_PushupGame_HUD", function()
    if not NextRP.PushupGame.IsPlaying or not NextRP.PushupGame.GameData.sequence then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local data = NextRP.PushupGame.GameData
    local config = NextRP.PushupGame.Config
    
    -- Основной фон
    draw.RoundedBox(8, scrW/2 - 250, 50, 500, 230, Color(0, 0, 0, 200))
    
    -- Заголовок
    draw.SimpleText("ТРЕНИРОВКА ОТЖИМАНИЙ", "DermaLarge", scrW/2, 80, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    
    -- Счетчик отжиманий
    draw.SimpleText("Выполнено: " .. data.pushupCount .. " / " .. config.maxPushups, "DermaDefault", scrW/2, 110, Color(100, 255, 100), TEXT_ALIGN_CENTER)
    
    -- Статус prone (если система доступна)
    if LocalPlayer().IsProne then
        local proneStatus = LocalPlayer():IsProne() and "В УПОРЕ ЛЁЖА" or "НЕ В УПОРЕ ЛЁЖА"
        local proneColor = LocalPlayer():IsProne() and Color(100, 255, 100) or Color(255, 100, 100)
        draw.SimpleText(proneStatus, "DermaDefault", scrW/2, 130, proneColor, TEXT_ALIGN_CENTER)
    end
    
    -- Текущая последовательность клавиш
    local keySize = 45
    local keySpacing = 55
    local startX = scrW/2 - (#data.sequence * keySpacing / 2) + (keySpacing / 2)
    local keysY = (LocalPlayer().IsProne and LocalPlayer():IsProne()) and 160 or 140
    
    for i, key in ipairs(data.sequence) do
        local keyName = config.keyNames[key] or "?"
        local color = Color(60, 60, 60, 200)
        local textColor = Color(200, 200, 200)
        
        if i == data.currentStep then
            -- Текущая клавиша (мигает)
            local alpha = math.sin(CurTime() * 8) * 127 + 128
            color = Color(255, 255, 100, alpha)
            textColor = Color(0, 0, 0)
        elseif i < data.currentStep then
            -- Выполненные клавиши
            color = Color(100, 255, 100, 200)
            textColor = Color(0, 0, 0)
        end
        
        local keyX = startX + (i-1) * keySpacing
        local keyY = keysY
        
        -- Рисуем клавишу
        draw.RoundedBox(6, keyX - keySize/2, keyY, keySize, keySize, color)
        draw.RoundedBox(6, keyX - keySize/2 + 2, keyY + 2, keySize - 4, keySize - 4, Color(255, 255, 255, 50))
        
        -- Текст клавиши
        draw.SimpleText(keyName, "DermaLarge", keyX, keyY + keySize/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Прогресс-бар времени
    local timeLeft = math.max(0, data.timeLeft or 0)
    local timeProgress = timeLeft / config.timePerKey
    local barWidth = 400
    local barHeight = 8
    local barX = scrW/2 - barWidth/2
    local barY = keysY + 60
    
    -- Фон прогресс-бара
    draw.RoundedBox(4, barX, barY, barWidth, barHeight, Color(100, 100, 100, 200))
    
    -- Заполнение прогресс-бара
    local fillColor = timeProgress > 0.3 and Color(100, 255, 100) or Color(255, 100, 100)
    draw.RoundedBox(4, barX, barY, barWidth * timeProgress, barHeight, fillColor)
    
    -- Таймер
    local timeColor = timeLeft > 1 and Color(255, 255, 255) or Color(255, 100, 100)
    draw.SimpleText("Время: " .. string.format("%.1f", timeLeft), "DermaDefault", scrW/2, barY + 20, timeColor, TEXT_ALIGN_CENTER)
    
    -- Подсказка текущей клавиши (большая)
    if data.currentStep <= #data.sequence then
        local currentKey = config.keyNames[data.sequence[data.currentStep]] or "?"
        local alpha = math.sin(CurTime() * 6) * 100 + 155
        draw.SimpleText("НАЖМИТЕ: " .. currentKey, "DermaLarge", scrW/2, scrH - 140, Color(255, 255, 100, alpha), TEXT_ALIGN_CENTER)
    end
    
    -- Инструкции
    local instructY = scrH - 100
    draw.SimpleText("Нажимайте клавиши в правильной последовательности", "DermaDefault", scrW/2, instructY, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    
    if LocalPlayer().IsProne and LocalPlayer():IsProne() then
        draw.SimpleText("Вы в упоре лёжа - выполняйте отжимания!", "DermaDefault", scrW/2, instructY + 20, Color(100, 255, 100), TEXT_ALIGN_CENTER)
    else
        draw.SimpleText("Не отходите далеко от места тренировки!", "DermaDefault", scrW/2, instructY + 20, Color(255, 200, 100), TEXT_ALIGN_CENTER)
    end
end)

-- Эффект вибрации экрана при правильном нажатии и салюте
hook.Add("NextRP_PushupGame_Success", "NextRP_PushupGame_ScreenShake", function()
    util.ScreenShake(LocalPlayer():GetPos(), 2, 5, 0.3, 100)
end)

-- Визуальные эффекты при успешном отжимании
hook.Add("DoAnimationEvent", "NextRP_PushupGame_SaluteEffect", function(ply, event, data)
    if event == PLAYERANIMEVENT_CUSTOM_GESTURE and ply == LocalPlayer() then
        -- Эффект при выполнении салюта
        local effectdata = EffectData()
        effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
        effectdata:SetMagnitude(1)
        effectdata:SetScale(1)
        util.Effect("confetti", effectdata)
    end
end)

-- Дополнительные звуковые эффекты
local function PlaySuccessSound()
    surface.PlaySound("garrysmod/save_load" .. math.random(1, 4) .. ".wav")
end

-- Хук для воспроизведения звука при успешном отжимании
hook.Add("NextRP_PushupGame_PushupComplete", "NextRP_PushupGame_PlaySound", function()
    PlaySuccessSound()
end)