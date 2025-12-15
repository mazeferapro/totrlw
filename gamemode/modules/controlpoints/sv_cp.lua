netstream.Hook('NextRP::ControlPointSendConfigs', function(pPlayer, eCP, nRadius, sTitle, sDescription)
    if not NextRP:HasPrivilege(pPlayer, 'manage_controlpoints') then return end
    eCP:SetRadius(nRadius)
    eCP:SetTitle(sTitle)
    eCP:SetDescription(sDescription)
end) 