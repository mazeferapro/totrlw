AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( 'models/reizer_props/srsp/sci_fi/console_03/console_03.mdl' )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() 
	end

	self:SetUseType(SIMPLE_USE)
end
 
function ENT:Use( activator, caller )
	if caller:IsPlayer() and table.IsEmpty(caller:GetNVar('nrp_charflags') or {}) then
		netstream.Start(caller, 'NextRP::OpenTest')
	end
end