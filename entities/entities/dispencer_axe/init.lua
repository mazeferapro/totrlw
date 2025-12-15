AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()
	self:SetModel("models/props_c17/FurnitureCupboard001a.mdl")
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

function ENT:SpawnFunction(ply, tr, ClassName)
	if(!tr.Hit) then return end

	local SpawnPos = ply:GetShootPos() + ply:GetForward() * 80

	local ent = ents.Create(ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Use(activator, caller)
		if self.UseTimer <= CurTime() and activator:IsPlayer() then

			self:SetSkin(self.LoadingSkin)
			self:EmitSound("buttons/button6.wav")

			--if AASCheckPidrill(activator) then
				if activator:HasWeapon("weapon_pickaxe") then
				activator:StripWeapon( "weapon_pickaxe" )
				elseif activator:CanAfford(300) then
					activator:Give("weapon_pickaxe", false )
					activator:addMoney(-300)
				else
					activator:PrintMessage( 4, "Недостаточно денег, пошел вон!" )
				end
			--end
				self.UseTimer = CurTime() + 1
				self.Status = 0
		else
			self:EmitSound("npc/roller/code2.wav")
			return false
		end
end

function ENT:Think()
	if self.UseTimer <= CurTime() && self.Status == 0 then
		self:EmitSound("buttons/button7.wav")
		self:SetSkin(self.CurSkin)
		self.Status = 1
	end
end