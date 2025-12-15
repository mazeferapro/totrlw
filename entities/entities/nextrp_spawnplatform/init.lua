AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
	self:SetModel( 'models/hunter/blocks/cube025x025x025.mdl' )
	self:SetSolid( SOLID_BBOX )
	self:DropToFloor()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self:SetUseType( SIMPLE_USE )

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	self:SetMaterial( 'models/debug/debugwhite' )
	self:SetColor(Color(68, 189, 50))
end

function ENT:Use(pPlayer)
	if not NextRP:HasPrivilege(pPlayer, 'manage_spawns') then return end

	netstream.Start(pPlayer, 'NextRP::SelectSpawnJob', self)
end

netstream.Hook('NextRP::SelectSpawnJob', function(pPlayer, eEnt, sJobID)
	if not NextRP:HasPrivilege(pPlayer, 'manage_spawns') then return end

	eEnt:SetJobID(sJobID)
end)