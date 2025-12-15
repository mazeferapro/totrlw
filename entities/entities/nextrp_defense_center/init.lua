AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetUseType(SIMPLE_USE)
    
    -- Установка размеров хитбокса
    self:SetCollisionBounds(Vector(-32, -32, 0), Vector(32, 32, 64))
    
    self:SetActive(false)
    self:SetCenterName("Центр обороны #" .. self:EntIndex())
    self:SetDefenseRadius(500)
    
    -- Эффект для визуализации
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:SetColor(Color(0, 150, 255, 200))
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() or not activator:IsAdmin() then
        return
    end
    
    self:OpenConfigMenu(activator)
end

function ENT:OpenConfigMenu(ply)
    net.Start("NextRP_DefenseCenter_OpenMenu")
    net.WriteEntity(self)
    net.Send(ply)
end

function ENT:SetCenterConfig(data)
    self:SetCenterName(data.name or "Центр обороны")
    self:SetDefenseRadius(data.radius or 500)
    self:SetActive(data.active ~= false)
end

-- Функция проверки, находится ли игрок в зоне безопасности
function ENT:IsPlayerInSafeZone(ply)
    if not IsValid(ply) then return false end
    local distance = self:GetPos():Distance(ply:GetPos())
    return distance <= self:GetDefenseRadius()
end

-- Получить всех игроков в зоне
function ENT:GetPlayersInZone()
    local players = {}
    for _, ply in pairs(player.GetAll()) do
        if self:IsPlayerInSafeZone(ply) then
            table.insert(players, ply)
        end
    end
    return players
end

--

-- Получить всех игроков вне зоны
function ENT:GetPlayersOutsideZone()
    local players = {}
    for _, ply in pairs(player.GetAll()) do
        if not self:IsPlayerInSafeZone(ply) and ply:Alive() then
            table.insert(players, ply)
        end
    end
    return players
end

-- Сетевые сообщения
util.AddNetworkString("NextRP_DefenseCenter_OpenMenu")
util.AddNetworkString("NextRP_DefenseCenter_Configure")
util.AddNetworkString("NextRP_DefenseCenter_Delete")

net.Receive("NextRP_DefenseCenter_Configure", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    local data = net.ReadTable()
    
    if IsValid(ent) and ent:GetClass() == "nextrp_defense_center" then
        ent:SetCenterConfig(data)
    end
end)

net.Receive("NextRP_DefenseCenter_Delete", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    if IsValid(ent) and ent:GetClass() == "nextrp_defense_center" then
        ent:Remove()
    end
end)

