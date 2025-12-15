local codes = NextRP.Codes

codes.CurCode = codes.CurCode or {}

function codes:GetDefaultCode(CONTROL)
    if NextRP.Config.Codes.States[CONTROL] then
        for k, v in pairs(NextRP.Config.Codes.States[CONTROL]) do
            if v.Default then 
                return k
            end
        end
    end
end

function codes:GetCurCode(CONTROL)
    if codes.CurCode[CONTROL] then
        return codes.CurCode[CONTROL]
    else
        codes:SetCurCodeInternal(CONTROL, codes:GetDefaultCode(CONTROL))
        return codes.CurCode[CONTROL]
    end
end

function codes:GetPerms(CONTROL, pActor)
    if NextRP.Config.Codes.Permissions[CONTROL] then
        local perms = NextRP.Config.Codes.Permissions[CONTROL][pActor:Team()]
        if istable(perms) then
            if perms[pActor:GetNWString('nrp_rankid')] then
                return true
            end
            return false
        end 

        if isbool(perms) and perms then
            return true
        end
    end

    ErrorNoHaltWithStack('ПРАВА ФРАКЦИИ НЕ НАСТРОЕНЫ, ПРОВЕРЬТЕ config/sh_config.lua!')
    return false
end

function codes:SetCurCodeInternal(CONTROL, CODE)
    if NextRP.Config.Codes.States[CONTROL] then
        if not istable(NextRP.Config.Codes.States[CONTROL][CODE]) then
            return false
        end
    end

    codes.CurCode[CONTROL] = CODE
    return true
end

function codes:SetCurCode(CONTROL, CODE, pActor)
    if not codes:GetPerms(CONTROL, pActor) then return end

    local suc = codes:SetCurCodeInternal(CONTROL, CODE)
    if not suc then return end

    netstream.Start(player.FindByControl(CONTROL), 'NextRP::NotifyChangeCode', false, CODE, pActor)
end

netstream.Hook('NextRP::RequestCodeChange', function(pPlayer, CODE)
    if codes:GetCurCode(pPlayer:getJobTable().control) == CODE then
        return false
    end

    codes:SetCurCode(pPlayer:getJobTable().control, CODE, pPlayer)
end)

hook.Add('NextRP::CharacterSelected', 'NextRP::SetupCodes', function(pPlayer)
    -- TODO: Отправить текущий код фракции игроку, если таковой имееться.
    local CONTROL = pPlayer:getJobTable().control
    netstream.Start(pPlayer, 'NextRP::NotifyChangeCode', true, codes:GetCurCode(CONTROL))
end)