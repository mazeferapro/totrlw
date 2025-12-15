AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.

include('shared.lua')

function ENT:Initialize()
    self:SetModel('models/ace/sw/r5.mdl')
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
    PrintTable(self:GetSequenceList())

    timer.Simple(0, function()
        if IsValid(self) then
            self:ResetSequence('idle_all_02')
            self:ResetSequence('idle_all_angry')
            self:ResetSequence('idle_all_scared')
            self:ResetSequence('idle_all_scared')
        end
    end)
end

function ENT:Use( activator, Caller )
	netstream.Start(activator, 'NextRP::ExchangerMenu', activator.Cryses or 0)
end

function ENT:Think()
    -- We don't need to think, we are just a prop after all!
end