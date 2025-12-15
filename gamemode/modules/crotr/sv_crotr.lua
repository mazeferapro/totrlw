NextRP.CRotR = NextRP.CRotR or {}

function NextRP.CRotR:OpenUI(pPlayer)
    MySQLite.query(string.format('SELECT * FROM `nextrp_crotr` WHERE community_id = %s;', MySQLite.SQLStr(pPlayer:SteamID64())),
    function(result)
        if result == nil then
            MySQLite.query(string.format('INSERT INTO `nextrp_crotr`(community_id, table_bought) VALUES(%s, %s);',
                MySQLite.SQLStr(pPlayer:SteamID64()),
                MySQLite.SQLStr('[]')
            ))
            netstream.Start(pPlayer, 'NextRP::OpenCRotRMenu', '[]', 0)
        else
            local sBought = result[1].table_bought or '[]'
            local nCrotrs = result[1].crotrs or 0
            netstream.Start(pPlayer, 'NextRP::OpenCRotRMenu', sBought, nCrotrs)
        end
    end)
end

function NextRP.CRotR:Buy(pPlayer, sBought, nCrotrs, nJob)
    MySQLite.query(string.format('UPDATE `nextrp_crotr` SET table_bought = %s, crotrs = %d WHERE community_id = %s',
        MySQLite.SQLStr(sBought),
        nCrotrs,
        MySQLite.SQLStr(pPlayer:SteamID64())
    ), function()
        pPlayer:ChangeTeam(nJob, false)
        timer.Simple(.2, function() pPlayer:Spawn() end)
    end)
end

function NextRP.CRotR:AddCrotrs(community_id, nCrotrs)
    MySQLite.query(string.format('SELECT crotrs FROM `nextrp_crotr` WHERE community_id = %s;', MySQLite.SQLStr(community_id)),
    function(result)
        if result == nil then
            MySQLite.query(string.format('INSERT INTO `nextrp_crotr`(community_id, table_bought, crotrs) VALUES(%s, %s, %d);',
                MySQLite.SQLStr(community_id),
                MySQLite.SQLStr('[]'),
                nCrotrs
            ))
        else
            nCrotrs = result[1].crotrs + nCrotrs
            MySQLite.query(string.format('UPDATE `nextrp_crotr` SET crotrs = %d WHERE community_id = %s',
                nCrotrs,
                MySQLite.SQLStr(community_id)
            ))
        end
    end)
end

function NextRP.CRotR:SendAdminData(pPlayer)
    -- Запрашиваем всех, у кого есть записи в базе (crotrs > 0 или купленные профы)
    MySQLite.query(string.format('SELECT * FROM `nextrp_crotr`'), 
    function(db_result)
        local tAllPlayersData = {}
        local tDBIDs = {}

        -- 1. Добавляем данные из базы
        if db_result then
            for _, v in ipairs(db_result) do
                -- Используем community_id как ключ
                tAllPlayersData[v.community_id] = {
                    crotrs = v.crotrs or 0, -- Устанавливаем 0, если nil
                    community_id = v.community_id
                }
                tDBIDs[v.community_id] = true
            end
        end

        -- 2. Добавляем всех онлайн-игроков, которых нет в базе
        for _, pOnlinePlayer in pairs(player.GetAll()) do
            local sID = pOnlinePlayer:SteamID64()
            
            -- Если игрока нет в списке из базы, добавляем его с 0 CRotR
            if not tDBIDs[sID] then
                tAllPlayersData[sID] = {
                    crotrs = 0,
                    community_id = sID
                }
            end
        end
        
        -- Поскольку tAllPlayersData - это таблица с ключами SteamID64, 
        -- преобразуем ее обратно в индексированную таблицу для отправки, 
        -- как ожидает клиент.
        local tFinalResult = {}
        for _, v in pairs(tAllPlayersData) do
            table.insert(tFinalResult, v)
        end

        -- 3. Отправляем полный список клиенту
        netstream.Start(pPlayer, 'NextRP::CRotROpenAdmin', tFinalResult)
    end)
end

netstream.Hook('NextRP::SpendCrotrs', function(pPlayer, sBought, nCrotrs, nJob)
    NextRP.CRotR:Buy(pPlayer, sBought, nCrotrs, nJob)
end)

netstream.Hook('NextRP::AddCRotRs', function(pPlayer, community_id, nCrotrs)
    -- !!! ДОБАВЬТЕ ПРОВЕРКУ АДМИНА ЗДЕСЬ !!!
    if not NextRP.CRotR:IsAdmin(pPlayer) then return end 

    if community_id == nil then 
        -- Вызываем новую функцию для отправки полных данных
        NextRP.CRotR:SendAdminData(pPlayer)
        return 
    end
    
    -- Логика выдачи CRotR остается прежней
    NextRP.CRotR:AddCrotrs(community_id, nCrotrs)
end)

netstream.Hook('NextRP::BuyCRotRSlot', function(pPlayer, nPrice)
    -- Проверка, что цена корректна
    if nPrice == nil or not isnumber(nPrice) or nPrice <= 0 then 
        return 
    end

    local sSteamID64 = pPlayer:SteamID64()
    
    -- Шаг 1: Получаем текущий баланс CRotR
    MySQLite.query(string.format('SELECT crotrs FROM `nextrp_crotr` WHERE community_id = %s;', MySQLite.SQLStr(sSteamID64)),
    function(crotrs_result)
        if crotrs_result == nil or crotrs_result[1] == nil then
            LIB:Notify(pPlayer, 'Ошибка: Нет записи в системе CRotR.', 1, 5, LIB.Config.Colors.Red)
            return
        end

        local nCrotrs = crotrs_result[1].crotrs or 0

        -- 1.1. Проверка баланса
        if nCrotrs < nPrice then
            LIB:Notify(pPlayer, 'У Вас недостаточно CRotRов!', 1, 5, LIB.Config.Colors.Red)
            return
        end
        
        local nNewCrotrs = nCrotrs - nPrice

        -- Шаг 2: Списываем средства в таблице nextrp_crotr
        MySQLite.query(string.format('UPDATE `nextrp_crotr` SET crotrs = %d WHERE community_id = %s',
            nNewCrotrs,
            MySQLite.SQLStr(sSteamID64)
        ), function()
            
            -- Шаг 3: Обновляем количество слотов в таблице nextrp_players
            
            -- Сначала пытаемся получить текущее количество слотов и ID игрока
            MySQLite.query(string.format('SELECT char_slots, id FROM `nextrp_players` WHERE community_id = %s;', MySQLite.SQLStr(sSteamID64)),
            function(slots_result)
                
                if slots_result == nil or slots_result[1] == nil then
                    -- Если игрока нет в nextrp_players (что странно, но возможно при ошибке), отменяем.
                    LIB:Notify(pPlayer, 'Критическая ошибка: Не найдена запись игрока для обновления слотов.', 1, 5, LIB.Config.Colors.Red)
                    return
                end
                
                local nSlotsBought = slots_result[1].char_slots or 0
                local nNewSlots = nSlotsBought + 1
                
                -- Обновление существующей записи о слотах
                local sQuery = string.format('UPDATE `nextrp_players` SET char_slots = %d WHERE community_id = %s',
                    nNewSlots,
                    MySQLite.SQLStr(sSteamID64)
                )
                
                MySQLite.query(sQuery, function()
                    -- 4. Уведомление игрока
                    LIB:Notify(pPlayer, 'Вы успешно приобрели дополнительный слот! Ваш новый баланс: '..nNewCrotrs..' CRotRов. Текущее количество слотов: '..nNewSlots, 0, 7, LIB.Config.Colors.Green)
                    
                    -- Опционально: Отправить netstream игроку для обновления его локального UI
                    -- netstream.Start(pPlayer, 'NextRP::UpdateSlots', nNewSlots) 
                end)
            end)
        end)
    end)
end)

-- Создаем консольную команду, которая может быть вызвана игроками.
concommand.Add("open_crotr_menu", function(pPlayer, cmd, args)
    -- Проверяем, что команду вызывает именно игрок, а не консоль сервера.
    if not IsValid(pPlayer) or not pPlayer:IsPlayer() then
        return
    end

    -- Вызываем функцию открытия UI, которая есть в sv_crotr.lua
    -- и запускает netstream на клиент.
    NextRP.CRotR:OpenUI(pPlayer)
end)