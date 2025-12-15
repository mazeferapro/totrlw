--[[local LIB = PAW_MODULE('lib')

Kitsune_Arrest = Kitsune_Arrest or {}
Arrestants = Arrestants or {}
ArrestantsTime = ArrestantsTime or {}

Kitsune_Arrest.Rooms = {
    {
        Pos = Vector(-5103.522461, 13919.947266, -7563.968750)
        Ang = Angle(13.740241, 89.731544, 0.000000)
    },
    {
        Pos = Vector(-5105.576172, 14208.735352, -7563.968750)
        Ang = Angle(21.880243, 88.851440, 0.000000)
    },
    {
        Pos = Vector(-4991.048828, 13911.557617, -7563.968750)
        Ang = Angle(27.600252, -89.348679, 0.000000)
    },
    {
        Pos = Vector(-4992.000977, 14205.804688, -7563.968750)
        Ang = Angle(8.460256, 90.171349, 0.000000)
    },
    {
        Pos = Vector(-4881.613281, 13908.836914, -7563.968750)
        Ang = Angle(5.820245, 90.831284, 0.000000)
    },
    {
        Pos = Vector(-4880.612305, 14197.344727, -7563.968750)
        Ang = Angle(26.060247, -89.348724, 0.000000)
    },
    {
        Pos = Vector(-4764.392090, 14190.998047, -7563.968750)
        Ang = Angle(12.860249, 89.951363, 0.000000)
    },
    {
        Pos = Vector(-4767.126953, 13913.769531, -7563.968750)
        Ang = Angle(5.160252, -92.208672, 0.000000)
    },
}

local function Kitsune_Arest_Aresting(pSender, pTarget, tText)

    if !pSender:IsValid() || !pTarget:IsValid() then
        return
    end
    if tText == nil or tText == '' then
        LIB:SendMessage(pSender, -1, 'Введите корректное время.')
    elseif not pTarget:HasWeapon('weapon_handcuffed') then
        LIB:SendMessage(pSender, -1, 'Игрок не в наручниках.')
    elseif not Kitsune_Arrest.Rooms then
        LIB:SendMessage(pSender, -1, 'Проблема с конфигом, напиши Ворону!')
    else
        tText = tonumber(tText) * 60
        for _, v in pairs(Kitsune_Arrest.Rooms) do
            if #ents.FindInSphere(v.Pos, 10) < 1 then pTarget:SetPos(v.Pos) pTarget(SetAngles(v.Ang)) break end
            LIB:SendMessage(pSender, -1, 'Все камеры чем-то заняты!')
        end
        Arrestants[pTarget:SteamID()] = tText
        ArrestantsTime[pTarget:SteamID()] = CurTime()
        timer.Create('ArrestTimeFor'..pTarget:Nick(), tText, 1, function() Arrestants[pTarget:SteamID()] = nil ArrestantsTime[pTarget:SteamID()] = nil if pTarget:IsValid() then pTarget:SetPos(-7594.575684, 13668.291016, -6133.968750) end end)
    end
end


netstream.Hook('NextRP::ArrestArresting', function(pSender, pTarget, tText)
    print('Start')
    Kitsune_Arest_Aresting(pSender, pTarget, tText)
end)

hook.Add('PlayerDisconnected', 'Kitsune_Arrest_Leave', function(pPlayer) if Arrestants[pPlayer:SteamID()] then LIB:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[БАЗА] ', Color(255,0,0), pPlayer:Nick()..' Испарился из КПЗ!') end end)]]--