AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.
util.AddNetworkString('KitsuneArest')

include('shared.lua')

local LIB = PAW_MODULE('lib')

function ENT:Initialize()
    self:SetModel('models/alpha_dotr/alpha_dotr.mdl')
    self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
    self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:CapabilitiesAdd(CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)
    self:PhysicsInit(SOLID_BBOX)
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
        phys:EnableMotion(false)
    end
    --PrintTable(self:GetSequenceList())

    timer.Simple(0, function()
        if IsValid(self) then
            self:ResetSequence('idle_all_02')
            self:ResetSequence('idle_all_angry')
            self:ResetSequence('idle_all_scared')
            self:ResetSequence('idle_all_scared')
            --self:ResetSequence('menu_gman')
            --sit_zen gesture_item_give
            --ahqdi = self:GetSequenceList()
        end
    end)
end

Kitsune_Arrest = Kitsune_Arrest or {}
Arrestants = Arrestants or {}
ArrestantsTime = ArrestantsTime or {}

--[[Kitsune_Arrest.Rooms = {
    Vector(-11245.974609, -788.475159, 427.114258),
    Vector(-11257.120117, -1109.841919, 419.846527),
    Vector(-11253.497070, -1438.104858, 414.472778),
    Vector(-11271.666016, -1754.963867, 417.928131),
    Vector(-12087.544922, -1749.114380, 438.443695),
    Vector(-12093.066406, -1414.430542, 413.320953),
    Vector(-12096.926758, -1088.687622, 417.928131),
    Vector(-12082.882813, -780.936401, 421.763184),
}]]--

function ENT:Use( activator, Caller )
    if activator:IsPlayer() and ( Kitsune_Arrest.Access[team.GetName(activator:Team())] or activator:IsAdmin() ) then
        --local pl = player.GetAll()
        netstream.Start(activator, 'NextRP::OpenArrestMenu', activator, self:GetPos())
    else
        LIB:SendMessage(activator, -1, Color(255, 255, 255), 'Неа')
    end
end

--[[local function Kitsune_Arest_Aresting(pSender, pTarget, tText)

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
        timer.Create('ArrestTimeFor'..pTarget:Nick(), tText, 1, function() Arrestants[pTarget:SteamID()] = nil ArrestantsTime[pTarget:SteamID()] = nil if pTarget:IsValid() then pTarget:SetPos(Vector(-11263.972656, -1362.540161, -159.968750)) end end)
    end
end]]--

--hook.Add('PlayerDisconnected', 'Kitsune_Arrest_Leave', function(pPlayer) if Arrestants[pPlayer:SteamID()] then LIB:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[БАЗА] ', Color(255,0,0), pPlayer:Nick()..' Испарился из КПЗ!') end end)

--[[net.Receive('KitsuneArest', function(pPlayer)
    local pTarget = net.ReadPlayer()
    local tText = net.ReadString()
    Kitsune_Arest_Aresting(pPlayer, pTarget, tText)
end)]]

function ENT:Think()
    -- We don't need to think, we are just a prop after all!
end