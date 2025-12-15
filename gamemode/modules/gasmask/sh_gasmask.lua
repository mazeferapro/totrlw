-- ================================
-- ФАЙЛ: gamemode/modules/gasmask/sh_gasmask.lua
-- ================================

-- Инициализация модуля (общая часть)
NextRP.GasMask = NextRP.GasMask or {}

-- Профессии без противогазами
NextRP.GasMask.Jobs = {
    ['Боец 212-го'] = false,
    ['Боец 44-й Дивизии'] = false,
    ['Боец SOF'] = false,
    ['Боец Корусантской гвардии'] = false,
    ['Боец 125-го'] = false,
    ['Боец ARC'] = false,
    ['Боец ARC Alpha'] = false,
    ['Боец ARC Null'] = false,
    ['Представитель Республиканской Разведки'] = false,
    ['Ассасин специального назначения'] = false,
    ['Раззведчик специального назначения'] = false,
    ['Боец Штаба'] = false,
    ['Боец ARF Rancor'] = false,
    ['Наёмник Люси'] = false,
    ['Gabriel'] = false,
    ['Наёмник Сибата'] = false,
    ['Наёмник Батон'] = false,
    ['Агент ВАР'] = false,
    ['Наёмник'] = false, -- ЭТИМ МОЖНА (Достаточно удалить из списка или написать false)
    ['Кадет'] = true -- ЭТИМ НЕЗЯ (Пишешь true и профа не может юзать)
}
    -- Профессии с встроенной защитой НЕ нуждаются в противогазах
    
NextRP.GasMask.Default = {
    ['Республиканский коммандос 44-го'] = true,
    ['Республиканский коммандос Дельта'] = true,
    ['Республиканский коммандос'] = true,
    ['Республиканский коммандос Wrecker'] = true,
    ['Юнлинг'] = true,
    ['Джедай'] = true,
    ['Оби-Ван Кеноби'] = true,
    ['Джедай Triff'] = true,
    ['Джедай Patience Kys'] = true,
    ['Джедай'] = true,

}

NextRP.GasMask.Config = {
    key = KEY_F2, -- Клавиша для надевания/снятия
    slowdownMultiplier = 0.95, -- Замедление (70% от обычной скорости)
    sound_on = "items/battery_pickup.wav", -- Звук надевания
    sound_off = "items/flashlight1.wav", -- Звук снятия
    gasDamageTypes = {
        [65536] = true,
        [DMG_POISON] = true
    }, -- Тип урона от газа (константа DMG_NERVEGAS)
    hintInterval = 10, -- Интервал показа подсказки (секунды)
    hintDuration = 9, -- Длительность показа подсказки (секунды)
    overlayAlpha = 80, -- Прозрачность затемнения
    requireHelmet = true, -- Требовать наличие шлема для СЖО
}

-- Локализация
NextRP.GasMask.Lang = {
    mask_on = "СЗД активирована. Вы защищены от газа.",
    mask_off = "СЗД деактивирована. Вы больше не защищены от газа.",
    mask_active = "СЗД АКТИВЕН",
    hint = "",
    no_access = "Ваша профессия не может использовать СЗД!",
    no_helmet = "Для активации СЗД необходимо надеть шлем!",
    helmet_removed = "СЗД автоматически отключена - изменен шлем!",
}

-- Серверная часть
if SERVER then
    print("[NextRP] Загружается серверная часть модуля СЗД...")
    
    -- Сетевые строки
    util.AddNetworkString("NextRP_GasMask_Toggle")
    util.AddNetworkString("NextRP_GasMask_State")
    util.AddNetworkString("NextRP_GasMask_Sync")

    -- Серверные функции
    NextRP.GasMask.Server = {}

    -- Проверка наличия шлема у игрока через bodygroups
    function NextRP.GasMask.Server:HasHelmet(ply)
        if not IsValid(ply) then return false end
        
        -- Если проверка шлемов отключена
        if not NextRP.GasMask.Config.requireHelmet then
            return true
        end
        
        -- Проверяем через bodygroups
        local helmetBodyGroups = { 'Helmet', 'Head', 'helmet', 'head' }
        
        for k, data in pairs(ply:GetBodyGroups()) do
            if table.HasValue(helmetBodyGroups, data.name) then
                local bodyGroupValue = ply:GetBodygroup(data.id)
                -- Если bodygroup = 0, значит шлем надет (0 = надет, 1 = снят)
                if bodyGroupValue == 0 then
                    return true
                end
            end
        end
        
        return false
    end

    -- Проверка доступности противогаза для игрока
    function NextRP.GasMask.Server:CanUseGasMask(ply)
        if not IsValid(ply) or not ply:Alive() then return false end
        
        local job = ply:getJobTable()
        if not job then return false end
        
        local canUse = (not NextRP.GasMask.Jobs[job.name] or NextRP.GasMask.Default[job.name])
        return canUse
    end

    -- Проверка возможности активации СЖО (с учетом шлема)
    function NextRP.GasMask.Server:CanActivateGasMask(ply)
        if not self:CanUseGasMask(ply) then return false end
        
        -- Если требуется шлем, проверяем его наличие
        if NextRP.GasMask.Config.requireHelmet then
            return self:HasHelmet(ply)
        end
        
        return true
    end

    -- Получение текущего состояния противогаза
    function NextRP.GasMask.Server:GetMaskState(ply)
        return ply:GetNVar('gasmask_active') or false
    end

    -- Установка состояния противогаза
    function NextRP.GasMask.Server:SetMaskState(ply, state)
        ply:SetNVar('gasmask_active', state, NETWORK_PROTOCOL_PUBLIC)
        
        -- Синхронизируем с клиентом
        net.Start("NextRP_GasMask_State")
        net.WriteBool(state)
        net.Send(ply)
        
        print(string.format("[GasMask] %s %s СЗД", ply:Name(), state and "надел"))
    end

    -- Применение эффектов противогаза
    function NextRP.GasMask.Server:ApplyMaskEffects(ply, enable)
        if not IsValid(ply) then return end
        
        if enable then
            -- Надеваем противогаз
            ply:EmitSound(NextRP.GasMask.Config.sound_on, 75, 100, 1, CHAN_ITEM)
            
            if ply.SendMessage then
                ply:SendMessage(MESSAGE_TYPE_SUCCESS, NextRP.GasMask.Lang.mask_on)
            end
            
            -- Сохраняем оригинальную скорость и применяем замедление
            local walkSpeed = ply:GetWalkSpeed()
            local runSpeed = ply:GetRunSpeed()
            
            ply:SetNVar('gasmask_original_walk', walkSpeed, NETWORK_PROTOCOL_PRIVATE)
            ply:SetNVar('gasmask_original_run', runSpeed, NETWORK_PROTOCOL_PRIVATE)
            
            local newWalk = walkSpeed * NextRP.GasMask.Config.slowdownMultiplier
            local newRun = runSpeed * NextRP.GasMask.Config.slowdownMultiplier
            
            ply:SetWalkSpeed(newWalk)
            ply:SetRunSpeed(newRun)
            
        else
            -- Снимаем противогаз
            ply:EmitSound(NextRP.GasMask.Config.sound_off, 75, 100, 1, CHAN_ITEM)
            
            if ply.SendMessage then
                ply:SendMessage(MESSAGE_TYPE_WARNING, NextRP.GasMask.Lang.mask_off)
            end
            
            -- Восстанавливаем оригинальную скорость
            local originalWalk = ply:GetNVar('gasmask_original_walk') or ply:GetWalkSpeed()
            local originalRun = ply:GetNVar('gasmask_original_run') or ply:GetRunSpeed()
            
            ply:SetWalkSpeed(originalWalk)
            ply:SetRunSpeed(originalRun)
            
            -- Очищаем сохраненные значения
            ply:SetNVar('gasmask_original_walk', nil)
            ply:SetNVar('gasmask_original_run', nil)
        end
    end

    -- Принудительное отключение СЖО (когда снят шлем)
    function NextRP.GasMask.Server:ForceDisableMask(ply, reason)
        if not IsValid(ply) then return end
        if not self:GetMaskState(ply) then return end -- Уже выключен
        
        self:SetMaskState(ply, false)
        self:ApplyMaskEffects(ply, false)
        
        -- Уведомляем игрока о причине
        if reason and ply.SendMessage then
            ply:SendMessage(MESSAGE_TYPE_ERROR, reason)
        end
        
        -- Вызываем хук
        hook.Run("NextRP_GasMask_StateChanged", ply, false)
    end

    -- Переключение состояния противогаза
    function NextRP.GasMask.Server:ToggleMask(ply)
        if not IsValid(ply) then return end
        
        if not self:CanUseGasMask(ply) then
            if ply.SendMessage then
                ply:SendMessage(MESSAGE_TYPE_ERROR, NextRP.GasMask.Lang.no_access)
            end
            return
        end
        
        local currentState = self:GetMaskState(ply)
        local newState = not currentState
        
        -- Если пытаемся включить СЖО, проверяем наличие шлема
        if newState and not self:CanActivateGasMask(ply) then
            if ply.SendMessage then
                ply:SendMessage(MESSAGE_TYPE_ERROR, NextRP.GasMask.Lang.no_helmet)
            end
            return
        end
        
        self:SetMaskState(ply, newState)
        self:ApplyMaskEffects(ply, newState)
        
        -- Вызываем хук для других модулей
        hook.Run("NextRP_GasMask_StateChanged", ply, newState)
    end

    -- Проверка шлема у игроков с активной СЖО
    function NextRP.GasMask.Server:CheckHelmetStatus()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and self:GetMaskState(ply) then
                -- При требовании шлема проверяем его наличие
                if NextRP.GasMask.Config.requireHelmet and not self:HasHelmet(ply) then
                    self:ForceDisableMask(ply, NextRP.GasMask.Lang.helmet_removed)
                end
            end
        end
    end

    -- Сброс состояния при спавне
    function NextRP.GasMask.Server:ResetMaskState(ply)
        if not IsValid(ply) then return end
        
        ply:SetNVar('gasmask_active', false)
        ply:SetNVar('gasmask_original_walk', nil)
        ply:SetNVar('gasmask_original_run', nil)
        
        -- Уведомляем клиент
        net.Start("NextRP_GasMask_State")
        net.WriteBool(false)
        net.Send(ply)
    end

    -- Проверка защиты от газа (основная функция)
    function NextRP.GasMask.Server:HasGasProtection(ply)
        if not IsValid(ply) then return false end
        
        local teamName = team.GetName(ply:Team())
        
        -- Встроенная защита (существующая система из NextRP.Config)
        if NextRP.Config and NextRP.Config.gasNoDamageTable and NextRP.Config.gasNoDamageTable[teamName] then
            return true
        end
        
        -- Защита через противогаз
        if self:GetMaskState(ply) then
            return true
        end
        
        return false
    end

    -- ================================
    -- СЕТЕВЫЕ ОБРАБОТЧИКИ
    -- ================================

    net.Receive("NextRP_GasMask_Toggle", function(len, ply)
        NextRP.GasMask.Server:ToggleMask(ply)
    end)

    -- Синхронизация состояния при подключении
    net.Receive("NextRP_GasMask_Sync", function(len, ply)
        local state = NextRP.GasMask.Server:GetMaskState(ply)
        net.Start("NextRP_GasMask_State")
        net.WriteBool(state)
        net.Send(ply)
    end)

    -- ================================
    -- ХУКИ
    -- ================================

    -- Заменяем старый хук защиты от газа
    hook.Remove('EntityTakeDamage', 'KrigNoChem') -- Удаляем старый
    
    hook.Add('EntityTakeDamage', 'NextRP_GasMask_Protection', function(target, dmginfo)
        if not target or not target:IsPlayer() or not target:Alive() then return end
        
        -- Проверяем тип урона (газ)
        if NextRP.GasMask.Config.gasDamageTypes[dmginfo:GetDamageType()] then
            if NextRP.GasMask.Server:HasGasProtection(target) then
                return true -- Блокируем урон от газа
            end
        end
    end)

    -- Сброс состояния при спавне
    hook.Add("PlayerSpawn", "NextRP_GasMask_Reset", function(ply)
        NextRP.GasMask.Server:ResetMaskState(ply)
    end)

    -- Восстановление скорости при загрузке персонажа
    hook.Add("PlayerLoadout", "NextRP_GasMask_Loadout", function(ply)
        timer.Simple(0.1, function()
            if IsValid(ply) and NextRP.GasMask.Server:GetMaskState(ply) then
                NextRP.GasMask.Server:ApplyMaskEffects(ply, true)
            end
        end)
    end)

    -- Периодическая проверка шлемов (каждые 2 секунды)
    timer.Create("NextRP_GasMask_HelmetCheck", 2, 0, function()
        NextRP.GasMask.Server:CheckHelmetStatus()
    end)

    -- Хук на изменение bodygroups для отслеживания снятия шлема
    hook.Add("PlayerSetBodygroup", "NextRP_GasMask_BodygroupCheck", function(ply, id, value)
        if not IsValid(ply) or not NextRP.GasMask.Server:GetMaskState(ply) then return end
        
        -- Получаем название bodygroup
        local bodyGroups = ply:GetBodyGroups()
        if not bodyGroups[id + 1] then return end -- +1 потому что индексы с 1
        
        local bodyGroupName = bodyGroups[id + 1].name
        local helmetBodyGroups = { 'Helmet', 'Head', 'helmet', 'head' }
        
        -- Если изменили bodygroup шлема - всегда отключаем СЖО (при любом изменении)
        if table.HasValue(helmetBodyGroups, bodyGroupName) then
            NextRP.GasMask.Server:ForceDisableMask(ply, NextRP.GasMask.Lang.helmet_removed)
        end
    end)

    -- API функции для других модулей
    function NextRP:IsPlayerGasProtected(ply)
        return NextRP.GasMask.Server:HasGasProtection(ply)
    end
    
    function NextRP:SetPlayerGasMask(ply, state)
        if state and not NextRP.GasMask.Server:CanActivateGasMask(ply) then
            return false
        end
        
        if NextRP.GasMask.Server:CanUseGasMask(ply) then
            NextRP.GasMask.Server:SetMaskState(ply, state)
            NextRP.GasMask.Server:ApplyMaskEffects(ply, state)
            return true
        end
        return false
    end
    
    function NextRP:TogglePlayerGasMask(ply)
        NextRP.GasMask.Server:ToggleMask(ply)
    end

    -- Новая API функция для проверки шлема
    function NextRP:PlayerHasHelmet(ply)
        return NextRP.GasMask.Server:HasHelmet(ply)
    end

    print("[NextRP] Серверная часть модуля противогазов загружена")
end

-- Клиентская часть
if CLIENT then
    print("[NextRP] Загружается клиентская часть модуля противогазов...")
    
    -- Локальные переменные
    local gasMaskActive = false
    local lastHintTime = 0
    local keyPressed = false

    -- Клиентские функции
    NextRP.GasMask.Client = {}

    -- Получение состояния противогаза
    function NextRP.GasMask.Client:GetMaskState()
        return gasMaskActive
    end

    -- Проверка наличия шлема (клиентская версия) через bodygroups
    function NextRP.GasMask.Client:HasHelmet()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        
        -- Если проверка шлемов отключена
        if not NextRP.GasMask.Config.requireHelmet then
            return true
        end
        
        -- Проверяем через bodygroups
        local helmetBodyGroups = { 'Helmet', 'Head', 'helmet', 'head' }
        
        for k, data in pairs(ply:GetBodyGroups()) do
            if table.HasValue(helmetBodyGroups, data.name) then
                local bodyGroupValue = ply:GetBodygroup(data.id)
                -- Если bodygroup = 0, значит шлем надет (0 = надет, 1 = снят)
                if bodyGroupValue == 0 then
                    return true
                end
            end
        end
        
        return false
    end

    -- Проверка доступности противогаза
    function NextRP.GasMask.Client:CanUseMask()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return false end
        
        local job = ply:getJobTable()
        if not job then return false end
        
        local canUse = (not NextRP.GasMask.Jobs[job.name] or NextRP.GasMask.Default[job.name])
        return canUse
    end

    -- Проверка возможности активации (с учетом шлема)
    function NextRP.GasMask.Client:CanActivateMask()
        if not self:CanUseMask() then return false end
        
        if NextRP.GasMask.Config.requireHelmet then
            return self:HasHelmet()
        end
        
        return true
    end

    -- Отправка запроса на переключение
    function NextRP.GasMask.Client:ToggleMask()
        if not self:CanUseMask() then 
            chat.AddText(Color(255, 100, 100), NextRP.GasMask.Lang.no_access)
            return 
        end

        -- Если пытаемся включить, проверяем шлем
        if not gasMaskActive and not self:CanActivateMask() then
            chat.AddText(Color(255, 100, 100), NextRP.GasMask.Lang.no_helmet)
            return
        end
        
        net.Start("NextRP_GasMask_Toggle")
        net.SendToServer()
    end

    -- Отрисовка подсказки
    function NextRP.GasMask.Client:DrawHint()
        if not self:CanUseMask() then return end
        if gasMaskActive then return end -- Не показывать если противогаз уже надет
        
        local currentTime = CurTime()
        
        -- Показываем подсказку периодически
        local cycle = currentTime % NextRP.GasMask.Config.hintInterval
       if cycle < NextRP.GasMask.Config.hintDuration then
           local keyName = input.GetKeyName(NextRP.GasMask.Config.key) or "G"
           local hintText = string.format(NextRP.GasMask.Lang.hint, keyName) 
            
            -- Если нет шлема, показываем предупреждение
            if NextRP.GasMask.Config.requireHelmet and not self:HasHelmet() then
                hintText = hintText .. ""
            end
            
            -- Плавное появление/исчезновение
            local fadeTime = 1
            local alpha = 255
            if cycle < fadeTime then
                alpha = (cycle / fadeTime) * 255
            elseif cycle > (NextRP.GasMask.Config.hintDuration - fadeTime) then
                alpha = ((NextRP.GasMask.Config.hintDuration - cycle) / fadeTime) * 255
            end
            
            -- Цвет зависит от доступности
            local color = Color(255, 255, 100, alpha)
            if NextRP.GasMask.Config.requireHelmet and not self:HasHelmet() then
                color = Color(255, 150, 100, alpha) -- Оранжевый если нет шлема
            end
            
            draw.SimpleText(hintText, "DermaDefault", 
                ScrW() * 0.5, ScrH() * 0.8, 
                color, 
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- ================================
    -- СЕТЕВЫЕ ОБРАБОТЧИКИ
    -- ================================

    net.Receive("NextRP_GasMask_State", function()
        gasMaskActive = net.ReadBool()
        print("[GasMask Client] Состояние изменено на:", gasMaskActive)
    end)

    -- ================================
    -- ХУКИ
    -- ================================

    -- Обработка нажатий клавиш
    hook.Add("Think", "NextRP_GasMask_KeyHandler", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Проверяем нажатие клавиши
        if input.IsKeyDown(NextRP.GasMask.Config.key) then
            if not keyPressed then
                keyPressed = true
                NextRP.GasMask.Client:ToggleMask()
            end
        else
            keyPressed = false
        end
    end)

    -- Отрисовка подсказок
    hook.Add("HUDPaint", "NextRP_GasMask_Hint", function()
        NextRP.GasMask.Client:DrawHint()
    end)

    -- Синхронизация при инициализации
    hook.Add("InitPostEntity", "NextRP_GasMask_Init", function()
        timer.Simple(2, function()
            net.Start("NextRP_GasMask_Sync")
            net.SendToServer()
        end)
    end)

    -- API для других модулей
    function NextRP:GetLocalPlayerGasMask()
        return NextRP.GasMask.Client:GetMaskState()
    end

    -- Новая API функция для проверки шлема на клиенте
    function NextRP:LocalPlayerHasHelmet()
        return NextRP.GasMask.Client:HasHelmet()
    end

    print("[NextRP] Клиентская часть модуля противогазов загружена")
end

print("[NextRP] Модуль противогазов успешно загружен!")


