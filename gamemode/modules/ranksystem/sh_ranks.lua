local pMeta = FindMetaTable('Player')

function pMeta:GetRank()
    return self:GetNVar('nrp_rankid')
end

function pMeta:isArrested()
    return Arrestants[self:SteamID()]
end

function pMeta:GetNumber()
    return self:GetNVar('nrp_rpid')
end

-- function pMeta:GetNATORank()
--     local rank = self:GetNVar('nrp_rankid')
--     local jt = self:getJobTable()

--     if rank == false then return '' end
--     if jt == false then return '' end
--     if not istable(jt.ranks[rank]) then return '' end
--     return jt.ranks[rank].natoCode
-- end

function pMeta:GetFullRank()
    local rankid = self:GetNVar('nrp_rankid')
    local jt = self:getJobTable()

    if rankid == false then return '' end
    if jt == false then return '' end
    if not istable(jt.ranks[rank]) then return '' end
    return jt.ranks[rank].fullRank
end

function pMeta:GetName()
    return self:GetNVar('nrp_name')
end

function pMeta:IsCommander()
    local jt = self:getJobTable()
    if jt.ranks[self:GetRank()].whitelist then return true else return false end
end

--[[function pMeta:GetSurname()
    return self:GetNVar('nrp_surname')
end]]--

function pMeta:GetNickname()
    return self:GetNVar('nrp_nickname')
end

function NextRP.Ranks:Can(pPlayer, pTarget)
    local playerRank = pPlayer:GetRank()
    local targetRank = pTarget:GetRank()

    if NextRP:HasPrivilege(pPlayer, 'manage_ranks') then return true end

    local isCommander = pPlayer:getJobTable().ranks[playerRank].whitelist
    local isExsists = pTarget:getJobTable().ranks[targetRank] and true or false

    if isCommander and isExsists then
        return true
    end

    if SERVER then pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете изменять этого персонажа!') end
    return false 
end