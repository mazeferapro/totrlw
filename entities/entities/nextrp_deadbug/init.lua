AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box004a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(20)
    end
    
    self.Items = {}
    
    -- Автоудаление через 10 минут
    timer.Simple(600, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

function ENT:SetItems(items)
    self.Items = items or {}
    self:SetItemCount(table.Count(self.Items))
end

function ENT:GetItems()
    return self.Items or {}
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    netstream.Start(activator, "NextRP::OpenDeathBag", {
        entIndex = self:EntIndex(),
        items = self.Items
    })
end

function ENT:Think()
    -- Проверяем, есть ли ещё предметы
    if table.Count(self.Items) == 0 then
        self:Remove()
    end
    
    self:NextThink(CurTime() + 1)
    return true
end