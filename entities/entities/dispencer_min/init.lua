AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()
	self:SetModel("models/prop_crates/misc_x64_b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DropToFloor()

	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if(IsValid(phys)) then
		phys:Wake()
	end
end

function ENT:Use(activator, caller)
	if self.UseTimer <= CurTime() and activator:IsPlayer() then
		local status = 'сдали'
		if activator:HasWeapon("weapon_pickaxe") then
			activator:StripWeapon( "weapon_pickaxe" )
			status = 'получили'
		else
			activator:Give("weapon_pickaxe", false )
		end
		self.UseTimer = CurTime() + 1
		activator:SendNotification('Вы '..status..' кирку.', 0, 3, NextRP.Style.Theme.Accent, NextRP.Style.Theme.Text)
	end
end

function ENT:Think()
end