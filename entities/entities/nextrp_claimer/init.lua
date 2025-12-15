AddCSLuaFile( 'cl_init.lua' ) -- Make sure clientside
AddCSLuaFile( 'shared.lua' )  -- and shared scripts are sent.

include('shared.lua')

function ENT:Initialize()

	self:SetModel( 'models/reizer_props/srsp/sci_fi/console_01/console_01.mdl' )
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
	CooldownsClaim = CooldownsClaim or {}
    NUM_MINUTES_CLAIM = 180
    local cool = NUM_MINUTES_CLAIM - os.difftime(os.time(), CooldownsClaim[caller:GetName()])
	if caller:IsPlayer() then
		if CooldownsClaim and not CooldownsClaim[caller:GetName()] then CooldownsClaim[caller:GetName()] = 0 end
		if CooldownsClaim[caller:GetName()] and ( os.time() - CooldownsClaim[caller:GetName()] ) > NUM_MINUTES_CLAIM then
			local cat = caller:getJobTable().category

			if self:GetClaimers() == 'Free' then
				self:SetClaimers(cat)
				PAW_MODULE('lib'):SendMessageDist(caller, 0, 0, Color(220, 221, 225), '[БАЗА] ', Color(251, 197, 49), cat..' заняли '..self:GetTitle())
				CooldownsClaim[caller:GetName()] = os.time()
			elseif self:GetClaimers() == cat then
				self:SetClaimers('Free')
				PAW_MODULE('lib'):SendMessageDist(caller, 0, 0, Color(220, 221, 225), '[БАЗА] ', Color(251, 197, 49), cat..' освободили '..self:GetTitle())
			else
				PAW_MODULE('lib'):SendNotify(caller, 'Местность занята!', 2, 5, PAW_MODULE('lib').Config.Colors.Red)
			end
		else
			PAW_MODULE('lib'):SendNotify(caller, 'Вы не можете использовать это в течение '..cool..' секунд.', 2, 5, PAW_MODULE('lib').Config.Colors.Red)
		end
	end
end