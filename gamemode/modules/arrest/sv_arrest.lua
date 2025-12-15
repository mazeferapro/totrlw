local LIB = PAW_MODULE('lib')

Kitsune_Arrest = Kitsune_Arrest or {}
Arrestants = Arrestants or {}
ArrestantsTime = ArrestantsTime or {}
ArrestedWeapon = ArrestedWeapon or {}

Kitsune_Arrest.Rooms = {
    Vector(7618.870605, 7479.129883, -13855.591797),
    Vector(8363.343750, 7516.069336, -13840.071289),
    Vector(7581.661133, 7079.341309, -13840.364258),
    Vector(8315.307617, 7130.208496, -13838.390625),
    Vector(7600.699219, 6687.895508, -13841.392578),
    Vector(8353.845703, 6730.801270, -13860.508789)
}

local function Kitsune_Arest_Aresting(pSender, pTarget, tText)

    if !pSender:IsValid() || !pTarget:IsValid() then
        return
    end
    local Arrested = false
    if tText == nil or tText == '' then
        LIB:SendMessage(pSender, -1, 'Введите корректное время.')
    elseif not pTarget:HasWeapon('weapon_handcuffed') then
        LIB:SendMessage(pSender, -1, 'Игрок не в наручниках.')
    elseif not Kitsune_Arrest.Rooms then
        LIB:SendMessage(pSender, -1, 'Проблема с конфигом, напиши Ворону!')
    else
        tText = tonumber(tText)
        for _, v in ipairs(Kitsune_Arrest.Rooms) do
            if #ents.FindInSphere(v, 10) < 2 then
                pTarget:SetPos(v)
                Arrested = true
                break
            end
        end
        LIB:SendMessage(pSender, -1, Arrested and pTarget:Nick()..' посажен на '..tText..' минут.' or 'Все камеры чем-то заняты!')
        if Arrested then
            local WepTable = {}
            for _, wep in ipairs(pTarget:GetWeapons()) do
                if wep:GetClass() == 'nextrp_hands' then continue end
                pTarget:StripWeapon(wep:GetClass())
                if wep:GetClass() == 'weapon_handcuffed' then continue end
                table.insert(WepTable, wep:GetClass())
            end
            ArrestedWeapon[pTarget:SteamID()] = WepTable
            LIB:SendMessage(pTarget, -1, 'Вы посажены на '..tText..' минут. Ваше оружие изъято на время ареста.')
        else
            return
        end
        tText = tText * 60
        Arrestants[pTarget:SteamID()] = tText
        ArrestantsTime[pTarget:SteamID()] = CurTime()
        timer.Create('ArrestTimeFor'..pTarget:SteamID64(), tText, 1, function() RespawnArrest(pTarget) end)
    end
end

function RespawnArrest(pTarget)
    if pTarget:IsValid() then
        Arrestants[pTarget:SteamID()] = nil
        ArrestantsTime[pTarget:SteamID()] = nil
        if not pTarget:Kitsune_Arrest_Escape() then return end
        if ArrestedWeapon and ArrestedWeapon[pTarget:SteamID()] then
            for _, wep in pairs(ArrestedWeapon[pTarget:SteamID()]) do
                pTarget:Give(wep)
            end
            ArrestedWeapon[pTarget:SteamID()] = nil
        end
        pTarget:SetPos(Vector(8260.703125, 9796.092773, -14007.968750))
        hook.Run('KitsuneArrestTrack')
    end
end


netstream.Hook('NextRP::ArrestArresting', function(pSender, pTarget, tText)
    Kitsune_Arest_Aresting(pSender, pTarget, tText)
end)

hook.Add('PlayerDisconnected', 'ArrestDCcheck', function(ply)
    if timer.Exists('ArrestTimeFor'..ply:SteamID64()) then timer.Pause('ArrestTimeFor'..ply:SteamID64()) end
end)

--[[local function Kitsune_Arrest_Noty(pPlayer)
    for _, ply in player.Iterator() do
        if ply:Team() == 'Боец Бюро Безопастности' then LIB:SendMessage(pPlayer, -1, Color(255, 129, 56), '[БАЗА] ', Color(255,0,0), pPlayer:Nick()..' Испарился из КПЗ!') end
    end
end

hook.Add('PlayerDisconnected', 'Kitsune_Arrest_Leave', function(pPlayer) if Arrestants and Arrestants[pPlayer:SteamID()] then Kitsune_Arrest_Noty(pPlayer) end end)]]

local timing = 0

hook.Add("Think", "KitsuneArrestTrack", function()
    if CurTime() > timing then
        net.Start("KitsuneArest")

        if istable(Arrestants) and istable(ArrestantsTime) then
            local sArest = util.TableToJSON(Arrestants)
            local sArestTime = util.TableToJSON(ArrestantsTime)
            net.WriteString(sArest)
            net.WriteString(sArestTime)
        else
            net.WriteString('[]')
            net.WriteString('[]')
        end

        net.Broadcast()
        timing = CurTime() + 15
    end
end)