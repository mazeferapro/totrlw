local ranks = NextRP.Ranks or {}

function ranks:SetRank(pPlayer, pTarget, sRank)
    if pTarget:GetNVar('nrp_rankid') == sRank then
        return
    end

    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_WARNING, 'Отправляем запрос на смену звания.')

    local c = pTarget:CharacterByID(charid)
    c.rankid  = sRank

    if not pPlayer:GetNVar('nrp_tempjob') then
        pTarget:SetCharValue('rankid', sRank, function()
            pTarget:LoadCharacter(function()
                pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Звание успешно изменено.')
                hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
            end, charid)
        end)
        return 
    end

    pTarget:LoadCharacter(function()
        hook.Call( 'PlayerLoadout', GAMEMODE, pTarget )
    end, charid)
end

netstream.Hook('NextRP::SetCharRank', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:SetRank(pPlayer, pTarget, sRank)
end)

function ranks:SetNumber(pPlayer, pTarget, sRank)
    if pTarget:GetNVar('nrp_rpid') == sRank then
        return
    end

    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_WARNING, 'Отправляем запрос на смену номера.')

    local c = pTarget:CharacterByID(charid)
    c.rpid = sRank

    if not pPlayer:GetNVar('nrp_tempjob') then
        pTarget:SetCharValue('rpid', sRank, function()
            pTarget:LoadCharacter(function()
                pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Номер успешно изменён.')
                hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
            end, charid)
        end)
        return 
    end

    pTarget:LoadCharacter(function()
        hook.Call( 'PlayerLoadout', GAMEMODE, pTarget )
    end, charid)
end

netstream.Hook('NextRP::SetCharNumber', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:SetNumber(pPlayer, pTarget, sRank)
end)

function ranks:SetNickname(pPlayer, pTarget, sName)
    if pTarget:GetNVar('nrp_nickname') == sName then return end

    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_WARNING, 'Отправляем запрос на смену позывного.')
    
    local c = pTarget:CharacterByID(charid)
    c.character_nickname = sName

    if not pPlayer:GetNVar('nrp_tempjob') then
        pTarget:SetCharValue('character_nickname', sName, function()
            pTarget:LoadCharacter(function()
                pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Позывной успешно измененён.')
                hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
            end, charid)
        end)
        return 
    end
    pTarget:LoadCharacter(function()
        hook.Call( 'PlayerLoadout', GAMEMODE, pTarget )
    end, charid)
end

netstream.Hook('NextRP::SetCharNickname', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:SetNickname(pPlayer, pTarget, sRank)
end)

function ranks:AddFlag(pPlayer, pTarget, sFlag)
    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_WARNING, 'Отправляем запрос на добавление приписки.')

    local curFlag = pTarget:GetNVar('nrp_charflags') or {}
    if curFlag[sFlag] then return end
    curFlag[sFlag] = true

    local c = pTarget:CharacterByID(charid)
    c.flag = curFlag

    if not pPlayer:GetNVar('nrp_tempjob') then
        pTarget:SetCharValue('flag', util.TableToJSON(curFlag), function()
            pTarget:LoadCharacter(function()
                pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Приписка успешно добавлена.')
                hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
            end, charid)
        end)
        return 
    end

    pTarget:LoadCharacter(function()
        hook.Call( 'PlayerLoadout', GAMEMODE, pTarget )
    end, charid)
end

netstream.Hook('NextRP::AddCharFlag', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:AddFlag(pPlayer, pTarget, sRank)
end)

function ranks:RemoveFlag(pPlayer, pTarget, sFlag)
    if not ranks:Can(pPlayer, pTarget) then return end

    local charid = pTarget:GetNVar('nrp_charid')

    pPlayer:SendMessage(MESSAGE_TYPE_WARNING, 'Отправляем запрос на удаление приписки.')

    local curFlag = pTarget:GetNVar('nrp_charflags') or {}
    if not curFlag[sFlag] then return end
    curFlag[sFlag] = nil

    local c = pTarget:CharacterByID(charid)
    c.flag = curFlag

    if not pPlayer:GetNVar('nrp_tempjob') then
        pTarget:SetCharValue('flag', util.TableToJSON(curFlag), function()
            pTarget:LoadCharacter(function()
                pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Приписка успешно удалена.')
                hook.Call( 'PlayerLoadout', GAMEMODE, pTarget );
            end, charid)
        end)
        return 
    end

    pTarget:LoadCharacter(function()
        hook.Call( 'PlayerLoadout', GAMEMODE, pTarget )
    end, charid)
end

netstream.Hook('NextRP::RemoveCharFlag', function(pPlayer, pTarget, sRank)
    if not IsValid(pPlayer) then return end
    if not IsValid(pTarget) then return end
    if not isstring(sRank) then return end

    ranks:RemoveFlag(pPlayer, pTarget, sRank)
end)

NextRP:AddCommand('ranks', function(pPlayer)
    netstream.Start(pPlayer, 'NextRP::OpenSelfRankMenu')
end)