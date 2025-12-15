local pMeta = FindMetaTable('Player')

--[[function pMeta:Arrest(target, time)
	netstream.Start('NextRP::ArrestArresting', target, time)
	return true
end]]--

function pMeta:Kitsune_Arrest_Escape()
    local Checked = nil
    local tPlayers = {}
    local iPlayers = 0
    for _, v in ipairs(Kitsune_Arrest.Rooms) do
        local tEntities = ents.FindInSphere(v, 200)
        for i = 1, #tEntities do
            if tEntities[i]:IsPlayer() then
                iPlayers = iPlayers + 1
                tPlayers[iPlayers] = tEntities[i]
            end
        end
        if #tPlayers > 0 and table.HasValue(tPlayers, self) then Checked = true else Checked = false end
    end
    return Checked
end
