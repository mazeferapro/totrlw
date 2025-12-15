AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel('models/ace/sw/rh/cgi_holotable_bottom.mdl')

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
    self.ProtalVector = false

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion( false )
		phys:Wake()
	end
end

function ENT:Use( activator, caller )
	if IsValid( activator ) and activator:IsPlayer() then
		net.Start( 'GMap:Menu' )
		net.Send(activator)
	end
end