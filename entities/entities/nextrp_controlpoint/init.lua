AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.

include('shared.lua')

sound.Add( {
	name = 'POINT_CAPTURED',
	channel = CHAN_STATIC,
	volume = .8,
	level = 80,
	pitch = {95, 110},
	sound = 'point_capture.wav'
})

function ENT:Initialize()

	self:SetModel( 'models/jellyton/bf2/misc/props/command_post.mdl' )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetUseType(SIMPLE_USE)

	self.NextPoint = CurTime()
	self.OldControl = -1
	self:SetBodygroup(1, 2)
end

local npcTable = {
	'b1_battledroid_f',
	'b1_battledroid_heavy_f',
	'b1_battledroid_specialist_f',
}

local function EntRemove(eTable)
	for _, ent in ipairs(eTable) do
		if ent:IsValid() then ent:Remove() end
	end
end

function ENT:Think()
	local res = player.FindInSphere(self:GetPos(), self:GetRadius())
	self.Players = {}

	for k, v in pairs(res) do
		if v:IsPlayer() and v:Alive() then
			local jt = v:getJobTable()
			local control = jt.control

			if control == CONTROL_NONE then continue end

			self.Players[control] = self.Players[control] or 0
			self.Players[control] = self.Players[control] + 1

			netstream.Start(v, 'NextRP::FindInPoint', self)
		end
	end

	local winner = {con = false, members = 0}
	for k, v in pairs(self.Players) do
		if v > winner.members then
			winner = {con = k, members = v}
		end
	end
	if (CurTime() - self:GetLastCaptured()) >= self:GetNextInvade() and next(self.Players) == nil then
		--if self:GetControl() == CONTROL_GAR then
		local pos = self:GetPos()
		local entTable = {}
			if self:GetControl() ~= CONTROL_NONE then
				for i = 0, 5, 1 do
					local ent = ents.Create(npcTable[math.random(#npcTable)])
					ent:SetPos(Vector(pos.x + math.random(-self:GetRadius(), self:GetRadius()), pos.y + math.random(-self:GetRadius(), self:GetRadius()), pos.z + 500))
--				    ent:SetCollisionGroup(COLLISION_GROUP_NONE)
				    timer.Simple(0+i*0.4, function() ent:Spawn() end)
				    --ent:DropToFloor()
--				    timer.Simple(0+i*3, function() ent:SetCollisionGroup(COLLISION_GROUP_PLAYER) end)
				    table.insert(entTable, ent)
				end
			    self:SetControl(CONTROL_CIS)
			    self:SetNextInvade(math.random(300, 600))
			end
			timer.Simple(1800, function()
				for k, ent in ipairs(entTable) do
					if ent:IsValid() then ent:Remove() end
					entTable[k] = nil
				end
				--entTable = {}
			end)
		return
		--end
	end

	if not winner.con then
		self:SetInvader(-1)
		self:ProvidePoint()
		return
	end

	if winner.con ~= self:GetControl() then
		self:SetInvader(winner.con)
		self:ProvidePoint()
	end
end

function ENT:ProvidePoint()
	if CurTime() < self.NextPoint then
		return
	end
	self.NextPoint = CurTime() + .5

	-- Обычная ситуация, нет захватчиков, добавляем поинт (или не добавляем)
	if self:GetInvader() == -1 and self:GetControl() ~= -1 then
		self:SetPoints(math.Clamp(self:GetPoints() + 1, 0, 8))
		return
	end

	-- Обычная ситуация, нет захватчиков, нет владельцев, скидываем пойнты до нуля
	if self:GetInvader() == -1 and self:GetControl() == -1 then
		self:SetPoints(math.Clamp(self:GetPoints() - 1, 0, 8))
		return
	end

	-- Захватываем нейтральную точку
	if self:GetControl() == -1 and self:GetInvader() ~= -1 then
		self:SetPoints(math.Clamp(self:GetPoints() + 1, 0, 8))

		if self:GetPoints() == 8 then
			self:SetControl(self:GetInvader())
			self:SetInvader(-1)
		end
		return
	end

	-- Захват точки
	if self:GetControl() ~= self:GetInvader() then
		if self:GetPoints() > 0 then -- Убираем очко за очком, что бы сбросить захват.
			self:SetPoints(math.Clamp(self:GetPoints() - 1, 0, 8))
			return
		end
		if self:GetPoints() == 0 then -- Как только очков будет ноль, сбросить контрол (захват)
			self:SetControl(-1)
			return
		end
	end

end

function ENT:ClearPoints()
	if self:GetPoints() > 0 then self:SetPoints(0) end
end

function ENT:OnCaptured(sName, nOld, nNew)
	if nNew == CONTROL_GAR then
        self:SetBodygroup(1, 0)
        self:SetLastCaptured(CurTime())
    elseif nNew == CONTROL_CIS or nNew == CONTROL_NATO then
        self:SetBodygroup(1, 1)
        self:SetLastCaptured(CurTime())
	else
		self:SetBodygroup(1, 2)
		self:SetLastCaptured(CurTime())
	end
	--self:SetBodygroup(1, 2)
	--self:SetLastCaptured(CurTime())

	if nNew ~= -1 then
		self:EmitSound('POINT_CAPTURED')

		netstream.Start(player.FindByControl(nOld), 'NextRP::ScreenNotify', string.format('Ваша фракция %s потеряла точку "%s".', CONTROL_LOCALIZATIONS[nOld], self:GetTitle()))
		netstream.Start(player.FindByControl(nNew), 'NextRP::ScreenNotify', string.format('Ваша фракция %s захватила точку "%s".\nТак держать, боец!', CONTROL_LOCALIZATIONS[nNew], self:GetTitle()))
		local plytbl = player.FindInSphere(self:GetPos(), self:GetRadius() + 100) or {}
		for _, v in ipairs(plytbl) do
			local jt = v:getJobTable() or {}
			local control = jt.control or CONTROL_NONE
			if control == nNew then hook.Run('BPCapture', v) end
		end
		self:SetNextInvade(math.random(300, 1800))
	end
end

function ENT:Use( activator, caller )
	if caller:IsPlayer() then
		if not NextRP:HasPrivilege(caller, 'manage_controlpoints') then return end
		netstream.Start(caller, 'NextRP::OpenCPAdmin', self)
	end
end