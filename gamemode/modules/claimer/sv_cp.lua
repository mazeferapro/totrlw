--[[netstream.Hook('NextRP::ClaimerClaim', function(pPlayer, ent)
    local cat = pPlayer:getJobTable().category
    ent:SetClaimers(cat)
    PAW_MODULE('lib'):SendMessageDist(pPlayer, 0, 0, Color(220, 221, 225), '[БАЗА] ', Color(251, 197, 49), cat..' заняли '..ent:GetTitle())
end)]]--