--[[
    ПАТЧ: Трата очков снабжения при вызове техники
    
    При вызове транспорта через nextrp_carspawner будет тратиться
    определённое количество supply points.
    
    ЗАМЕНИ содержимое gamemode/modules/cardealler/sv_carspawns.lua на этот код.
]]--

-- ============================================================================
-- КОНФИГУРАЦИЯ СТОИМОСТИ ТЕХНИКИ
-- ============================================================================





-- ============================================================================
-- ФУНКЦИЯ ПОЛУЧЕНИЯ СТОИМОСТИ ТЕХНИКИ
-- ============================================================================


-- ============================================================================
-- ОБНОВЛЁННЫЙ NETSTREAM HOOK ДЛЯ СПАВНА ТЕХНИКИ
-- ============================================================================

netstream.Hook('NextRP::SpawnCar', function(pPlayer, eSpawner, sClass, iSkin, tBodygroups)
    -- Проверка: уже есть вызванная техника
    if IsValid(pPlayer.SpawnedVeh) then 
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете вызвать более одной единицы техники!') 
        return 
    end

    -- Проверка доступа к технике
    local avaibleVehs = NextRP:GetAvaibleCars(pPlayer)
    local can = false

    for k, v in pairs(avaibleVehs) do
        if v.class == sClass then 
            can = true 
            break 
        end
    end

    if not can then 
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'У вас нет доступа к этому транспорту!') 
        return 
    end

    -- ============================================
    -- ПРОВЕРКА И ТРАТА ОЧКОВ СНАБЖЕНИЯ (НОВОЕ!)
    -- ============================================
    
    local vehicleCost = NextRP.CarDealer:GetVehicleCost(sClass)
    local currentSupply = NextRP.Ammunition:GetSupplyPoints()
    
    if currentSupply < vehicleCost then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 
            string.format('На базе недостаточно очков снабжения! Нужно: %d, доступно: %d', 
                vehicleCost, currentSupply))
        return
    end
    
    -- ============================================

    -- Поиск свободной платформы
    local findedPlatform = nil

    for k, platform in pairs(eSpawner.Platforms) do
        local pPos = platform:GetPos()
        local pFinalPos = pPos + Vector(0, 0, 1000)

        local tr = util.TraceLine({
            start = pPos,
            endpos = pFinalPos,
            filter = platform,
            ignoreworld = true
        })

        if not tr.Hit then
            if not IsValid(tr.Entity) then 
                findedPlatform = platform 
                break 
            end
        end
    end

    if IsValid(findedPlatform) then        
        local Veh = ents.Create(sClass)
        if not IsValid(Veh) then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Что-то не так с транспортом! Обратитесь к тех. администратору!')
            return 
        end

        -- ============================================
        -- СПИСЫВАЕМ ОЧКИ СНАБЖЕНИЯ (НОВОЕ!)
        -- ============================================
        
        NextRP.Ammunition:SetSupplyPoints(currentSupply - vehicleCost, true)
        
        MsgC(Color(255, 200, 100), 
            string.format("[CarDealer] %s вызвал технику %s (-%d очков снабжения)\n", 
                pPlayer:Nick(), sClass, vehicleCost))
        
        -- ============================================

        Veh:SetPos(findedPlatform:GetPos() + Vector(0, 0, 100))
        Veh:SetAngles(findedPlatform:GetAngles())

        Veh:SetSkin(iSkin)

        for k, v in pairs(tBodygroups) do
            Veh:SetBodygroup(k, v)
        end

        Veh:Spawn()

        pPlayer.SpawnedVeh = Veh
        
        -- Уведомление игроку
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 
            string.format('Техника вызвана! Потрачено %d очков снабжения.', vehicleCost))
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Невозможно найти свободное место! Попробуйте позже.')
    end
end)

-- ============================================================================
-- ВОЗВРАТ ТЕХНИКИ (БЕЗ ИЗМЕНЕНИЙ, НО ДЛЯ ПОЛНОТЫ ФАЙЛА)
-- ============================================================================

netstream.Hook('NextRP::ReturnCar', function(pPlayer)
    if not IsValid(pPlayer.SpawnedVeh) then 
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не вызывали технику!') 
        return 
    end

    local sClass = pPlayer.SpawnedVeh

    local vehicleCost = NextRP.CarDealer:GetVehicleCost(sClass)

    local refundAmount = vehicleCost
    NextRP.Ammunition:AddSupplyPoints(refundAmount, true)
    

    pPlayer.SpawnedVeh:Remove()
    pPlayer.SpawnedVeh = nil
    pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Вы вернули технику! Возвращено ' .. refundAmount .. ' очков снабжения.')
end)

-- ============================================================================
-- КОНСОЛЬНАЯ КОМАНДА ДЛЯ НАСТРОЙКИ СТОИМОСТИ ТЕХНИКИ
-- ============================================================================

concommand.Add("nextrp_vehicle_cost", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[CarDealer] У вас нет прав!")
        return
    end
    
    if #args < 1 then
        -- Показать все настроенные стоимости
        local msg = "\n[CarDealer] Стоимость техники:\n" .. string.rep("-", 50) .. "\n"
        msg = msg .. "По умолчанию: " .. NextRP.CarDealer.DefaultVehicleCost .. " очков\n\n"
        
        if table.Count(NextRP.CarDealer.VehicleCosts) > 0 then
            msg = msg .. "Настроенные классы:\n"
            for class, cost in pairs(NextRP.CarDealer.VehicleCosts) do
                msg = msg .. string.format("  %s: %d очков\n", class, cost)
            end
        else
            msg = msg .. "Нет настроенных классов (используется стоимость по умолчанию)\n"
        end
        
        msg = msg .. string.rep("-", 50)
        
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    if #args == 1 then
        -- Показать стоимость конкретного класса
        local class = args[1]
        local cost = NextRP.CarDealer:GetVehicleCost(class)
        local msg = string.format("[CarDealer] Стоимость %s: %d очков", class, cost)
        
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    if #args >= 2 then
        -- Установить стоимость
        local class = args[1]
        local cost = tonumber(args[2])
        
        if not cost then
            local msg = "[CarDealer] Неверная стоимость!"
            if IsValid(ply) then
                ply:PrintMessage(HUD_PRINTCONSOLE, msg)
            else
                print(msg)
            end
            return
        end
        
        NextRP.CarDealer.VehicleCosts[class] = cost
        
        local msg = string.format("[CarDealer] Установлена стоимость %s: %d очков", class, cost)
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
    end
end)

MsgC(Color(0, 255, 100), "[NextRP CarDealer] Система стоимости техники загружена!\n")