function NextRP.GetDeathTime(self, pPlayer)
    local c = NextRP.Config.DeathTimes or {}
    
    -- if c[pPlayer:GetUserGroup()] then
    --     return c[pPlayer:GetUserGroup()]
    -- end

    return NextRP.Config.RespawnTime or 30
end  