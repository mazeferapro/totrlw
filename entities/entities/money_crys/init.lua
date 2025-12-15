AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local ColTable = {
	Color(255,125,0),
	Color(0,50,255),
	Color(255,51,255),
	Color(160,160,160),
	Color(255,255,51)
}

function ENT:Initialize()
	self:SetModel("models/venator/venator_kybercrystal_wos_white.mdl")

	self:SetColor(ColTable[math.random(1, #ColTable)])

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use( ply, caller )
    ply.Cryses = ply.Cryses and ply.Cryses + 1 or 1
    self:Remove()
    if SERVER then ply:CrystalSpeed() end
end
