NextRP.DeathsInfo = NextRP.DeathsInfo or {}
hook.Add('PlayerDeath', 'NextRP::DeathScreen', function(pPlayer)
    pPlayer.DeadTime = RealTime()

    NextRP.DeathsInfo = NextRP.DeathsInfo or {}

    if NextRP.DeathsInfo[pPlayer:SteamID()] then 
        netstream.Start(pPlayer, 'NextRP::Death', true, NextRP.DeathsInfo[pPlayer:SteamID()])
    else
        netstream.Start(pPlayer, 'NextRP::Death', true, {})
    end

    NextRP.DeathsInfo[pPlayer:SteamID()] = nil
end)

hook.Add('PlayerDeathThink', 'NextRP::DeathScreenThink', function(pPlayer)
    local RESPAWN_TIME = NextRP:GetDeathTime(pPlayer)
    if pPlayer.DeadTime and RealTime() - pPlayer.DeadTime < RESPAWN_TIME then
        return false
    end
end)

hook.Add('PlayerSpawn', 'NextRP::HideDeathTimer', function(pPlayer)
    netstream.Start(pPlayer, 'NextRP::Death', false)
    netstream.Start(target, 'NextRP::StunScreen', false)
end)

hook.Add('EntityTakeDamage', 'NextRP::AppendDMGInfo', function( target, dmginfo )
    if target:IsPlayer() and not target:IsBot() then
        local ent = target:GetNWEntity('CShield')
        if IsValid(ent) and ent:GetActive() then ent:TakeDamageInfo(dmginfo) end
        NextRP.DeathsInfo[target:SteamID()] = NextRP.DeathsInfo[target:SteamID()] or {}

        local att = dmginfo:GetAttacker()

        local attacker = att:IsWorld() and 'worldspawn' or ( att.Name and att:Name() or ( att.Nick and att:Nick() or 'worldspawn' ) )

        if not att:IsWorld() and att.Team and att:Team() then
            tm_c = team.GetColor(att:Team())
        end
        
        table.insert(NextRP.DeathsInfo[target:SteamID()], {
            attacker = attacker,
            att_color = '<colour=255, 165, 0, 255>',
            damage = dmginfo:GetDamage()
        })
    end
end)