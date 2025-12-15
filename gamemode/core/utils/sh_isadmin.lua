function NextRP.Utils:IsAdmin(pPlayer)
    return NextRP.Config.Admins[pPlayer:GetUserGroup()] or false
end