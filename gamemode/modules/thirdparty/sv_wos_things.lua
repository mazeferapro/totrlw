-- hook.Add('wOS.ALCS.GetCharacterID', 'NextRP::SetWOSCharID', function(pPlayer)
--     if not IsValid(pPlayer) then return 0 end

--     return tonumber(pPlayer:GetNVar('nrp_charid')) or 0
-- end)

hook.Remove('wOS.ALCS.GetCharacterID', 'NextRP::SetWOSCharID')