local chars = NextRP.Chars or {} 
chars.Cache = {}

hook.Add( 'DatabaseInitialized', 'RetriveChars', function()
    MySQLite.query('SELECT * FROM `nextrp_characters`',
    function(result)
        if not istable(result) then return end
        for k, v in pairs(result) do
            chars.Cache[v.character_id] = v
        end
    end)
end)

netstream.Hook('NextRP::FindChar', function(pPlayer, sMode, sValue)
    if not NextRP:HasPrivilege(pPlayer, 'manage_chars') then return end
    local tresult = {}

    if sMode == 'steamid' then
        if string.StartWith(sValue, 'STEAM_0') then
            sValue = util.SteamIDTo64(sValue)
        end

        MySQLite.query( string.format( 'SELECT id FROM `nextrp_players` WHERE `community_id` = %s;',
            MySQLite.SQLStr(sValue)
        ), function(result)
            if result and result[1].id then
                
                for k, v in pairs(NextRP.Chars.Cache) do
                    if v.player_id == result[1].id then
                        tresult[#tresult + 1] = v
                    end
                end

                netstream.Start(pPlayer, 'NextRP::CharAdminRespond', 'hit', tresult)
            else
                netstream.Start(pPlayer, 'NextRP::CharAdminRespond', 'fail', 'Не найдено информации о этом SteamID!')
            end
        end)
    elseif sMode == 'number' then
        for k, v in pairs(NextRP.Chars.Cache) do
            if v.rpid == sValue then
                tresult[#tresult + 1] = v
            end
        end

        netstream.Start(pPlayer, 'NextRP::CharAdminRespond', 'hit', tresult)
    elseif sMode == 'name' then
        for k, v in pairs(NextRP.Chars.Cache) do
            if string.find(v.character_nickname, sValue, 1) then
                tresult[#tresult + 1] = v
            end
        end

        netstream.Start(pPlayer, 'NextRP::CharAdminRespond', 'hit', tresult)
    end
end)

netstream.Hook('NextRP::AdminDeleteChar', function(pPlayer, nID)
    if not NextRP:HasPrivilege(pPlayer, 'manage_chars') then return end

    if not chars.Cache[nID] then return end

    local char = chars.Cache[nID]
    local playerID = char.player_id

    MySQLite.query(string.format('DELETE FROM `nextrp_characters` WHERE `character_id` = %s;', MySQLite.SQLStr(nID)), function()
        local pTarget = player.GetByPlayerID(playerID)
        if pTarget then
            pTarget:RequestCharacters(function(characters)
                pTarget.Characters = characters
                
                if pTarget:GetNVar('nrp_charid') == nID then
                    netstream.Start(pTarget, 'NextRP::OpenInitCharsMenu', characters, {
                        col = Color(255, 0, 0),
                        text = 'Ваш активный персонаж удалён администратором, выберите или создайте другого персонажа!'
                    })
                else
                    pTarget:SendMessage(MESSAGE_TYPE_WARNING, 'Ваш персонаж #' ..nID .. ' ' .. char.rankid .. ' ' .. char.rpid .. ' ' .. char.character_nickname .. ' удалён администратором.')
                end

                local shouldRemove = true
                
                for k, v in pairs(pTarget.Characters) do
                    if char.team_id == v.team_id then 
                        shouldRemove = false
                        break
                    end
                end

                if shouldRemove then
                    local job = NextRP.GetJobByID(char.team_id)
                    if job.type == TYPE_JEDI then
                        -- Discord:JobRank(pPlayer:SteamID64(), 'job:jedi', 'job:noadd')
                    else
                        -- Discord:JobRank(pPlayer:SteamID64(), 'job:'..char.team_id, 'job:noadd')
                    end
                end
            end)
        end
        
        chars.Cache[nID] = nil

        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Персонаж #' ..nID .. ' ' .. char.rankid .. ' ' .. char.rpid .. ' ' .. char.character_nickname .. ' удалён.')
    end)
end)

netstream.Hook('NextRP::AdminEditChar', function(pPlayer, nID, sName, sValue)
    if not NextRP:HasPrivilege(pPlayer, 'manage_chars') then return end

    if not chars.Cache[nID] then return end

    print(nID, sName, sValue)

    local char = chars.Cache[nID]
    local playerID = char.player_id
    local pTarget = player.GetByPlayerID(playerID)

    if pTarget and pTarget:GetNVar('nrp_charid') == nID then
        if sName == 'rankid' then
            NextRP.Ranks:SetRank(pPlayer, pTarget, sValue)
        elseif sName == 'number' then
            NextRP.Ranks:SetNumber(pPlayer, pTarget, sValue)
        elseif sName == 'name' then
            NextRP.Ranks:SetNickname(pPlayer, pTarget, sValue)
        elseif sName == 'job' then
            local job = NextRP.GetJob(sValue)
            if not job then return end
            
            pTarget:ChangeTeam( sValue, false )
            pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Персонажу #' .. nID .. ' ' .. char.rankid .. ' ' .. char.rpid .. ' ' .. char.character_nickname .. ' установлена профессия ' .. job.name)
        end

        return
    end

    if sName == 'rankid' then
        chars:SetCharValue( nID, 'rankid', sValue, function()
            pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Персонажу #' .. nID .. ' ' .. char.rpid .. ' ' .. char.character_nickname .. ' установлено звание '.. sValue .. '.')
        end )
    elseif sName == 'number' then
        chars:SetCharValue( nID, 'rpid', sValue )
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Персонажу #' .. nID .. ' ' .. char.rankid .. ' ' .. char.character_nickname .. ' установлен номер '.. sValue .. '.')
    elseif sName == 'name' then
        chars:SetCharValue( nID, 'character_nickname', sValue )
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Персонажу #' .. nID .. ' ' .. char.rankid .. ' ' .. char.rpid .. ' установлен(о) позывной/имя '.. sValue .. '.')
    elseif sName == 'job' then
        local job = NextRP.GetJob(sValue)
        if not job then return end
        chars:SetCharValue( nID, 'team_id', job.id )

        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Персонажу #' .. nID .. ' ' .. char.rankid .. ' ' .. char.rpid .. ' ' .. char.character_nickname .. ' установлена профессия '.. job.name .. '.')
    end
end)
