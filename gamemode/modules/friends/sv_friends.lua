local letters = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM'
local chartable = string.Explode('', letters)

function NextRP.Friends:GenerateCode(pPlayer)
    if not IsValid(pPlayer) then return end
    if pPlayer:GetNVar('nrp_referalcode') then return pPlayer:GetNVar('nrp_referalcode') end

    local randomCode = ''
    for i = 1, 5 do
        randomCode = randomCode .. chartable[math.random(1, 52)]
    end

    MySQLite.query(
        string.format(
            'SELECT * FROM `nextrp_players` WHERE referal_code = %s;',
            MySQLite.SQLStr(randomCode)
        ),

        function(tPlayerData)
            if tPlayerData and istable(tPlayerData) then
                NextRP.Friends:GenerateCode(pPlayer)
            else
                pPlayer:SavePlayerData( 'referal_code', randomCode )
                pPlayer:SetNVar( 'nrp_referalcode', randomCode )
                netstream.Start( pPlayer, 'NextRP::SendGeneratedCode', randomCode )
            end
        end
    )
end
function NextRP.Friends:ApplyCode(pPlayer, sCode)
    if pPlayer:GetNVar('nrp_referalcodeapplied') then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы уже активировали другой реферальный код!')
        return
    end

    MySQLite.query(
        string.format(
            'SELECT * FROM `nextrp_players` WHERE referal_code = %s;',
            MySQLite.SQLStr(sCode)
        ),

        function(tPlayerData)
            if tPlayerData and istable(tPlayerData) then
                if tPlayerData[1].community_id == pPlayer:SteamID64() then
                    pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете ввести свой реферальный код!')
                    return
                end

                if tPlayerData[1].referal_code_applied == pPlayer:GetNVar('nrp_referalcode') then
                    pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'У этого человека уже активен ваш код, вы не можете активировать его код!')
                    return
                end

                NextRP.CRotR:AddCrotrs(pPlayer:SteamID64(), 25)
                pPlayer:SavePlayerData( 'referal_code_applied', sCode )
                pPlayer:SetNVar('nrp_referalcodeapplied', sCode)

                pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Вы ввели реферальный код! Начислено 25 CRotRов!')

                local targetPlayer = player.GetBySteamID64(tPlayerData[1].community_id)

                if IsValid(targetPlayer) then
                    NextRP.CRotR:AddCrotrs(tPlayerData[1].community_id, 50)
                    targetPlayer:SendMessage(MESSAGE_TYPE_WARNING, 'Ваш реферальный код ввели! Начислено 50 CRotRов!')
                else
                    NextRP.CRotR:AddCrotrs(tPlayerData[1].community_id, 50)
                end
            else
                pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Такого реферального кода не найдено в БД!')
            end
        end
    )
end

netstream.Hook('NextRP::ApplyReferalCode', function(pPlayer, sCode)
    NextRP.Friends:ApplyCode(pPlayer, sCode)
end)

netstream.Hook('NextRP::GenerateReferalCode', function(pPlayer, sCode)
    NextRP.Friends:GenerateCode(pPlayer)
end)