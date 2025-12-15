AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.

include('shared.lua')

function ENT:Initialize()

    self:SetModel( 'models/props_furniture/scifi_medfabricator.mdl' )
    self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
    self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
    self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

    self:SetUseType(SIMPLE_USE)
end

ENT.LastUsed = 0

function ENT:Use( activator, caller )
    if activator:IsPlayer() and self.LastUsed < CurTime() then
        netstream.Start(activator, 'NextRP::MedVendorStart', activator, self)
        self.LastUsed = CurTime() + 3
    end
end


if SERVER then
    netstream.Hook('NextRP::GiveMed', function(pPlayer, vendor, med)
        local ent = ents.Create(med)
        if not ent:IsValid() then return end
        ent:SetPos(vendor:GetPos()+Vector(-20,50,20))
        ent:Spawn()
    end)
end