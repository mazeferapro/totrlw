SWEP.PrintName = "Axel"
SWEP.Category = "LOLinc's Epic Weapons"
SWEP.Base = "weapon_base"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/lew/weapons/c_axe.mdl"
SWEP.WorldModel = "models/bluegun/crystalgun.mdl"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false

SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.HoldType = "grenade"
SWEP.FiresUnderwater = true

SWEP.Slot = 0
SWEP.SlotPos = 3
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Weight = 10
SWEP.BobScale = 0.2
SWEP.SwayScale = 1

SWEP.Primary.Sound = Sound( "weapons/iceaxe/iceaxe_swing1.wav" )
--weapons/iceaxe/iceaxe_swing1.wav
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 10
SWEP.Primary.DelayMiss = 0.5
SWEP.Primary.DelayHit = 0.5
SWEP.Primary.Force = 1000

SWEP.Secondary.Sound = Sound( "physics/wood/wood_box_impact_bullet1.wav" )
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
--SWEP.RunSightsPos = Vector(-20, -11.969, -2.832)
--SWEP.RunSightsAng = Vector(10.175, -1.852, -70)

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:SetWeaponHoldType( self.HoldType )
	self.Idle = 0
	self.IdleTimer = CurTime() + 3
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_DEPLOY )
end

function SWEP:PrimaryAttack()
	self.Owner:LagCompensation( true )
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 56,
		filter = self.Owner,
		mask = MASK_SHOT_HULL,
	} )
	if !IsValid( tr.Entity ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 56,
			filter = self.Owner,
			mins = Vector( -16, -16, 0 ),
			maxs = Vector( 16, 16, 0 ),
			mask = MASK_SHOT_HULL,
		} )
	end
	if SERVER and IsValid( tr.Entity ) then
		local dmginfo = DamageInfo()
		local attacker = self.Owner
		if !IsValid( attacker ) then
			attacker = self
		end
		dmginfo:SetAttacker( attacker )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( self.Primary.Damage )
		dmginfo:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
		tr.Entity:TakeDamageInfo( dmginfo )
	end
	if tr.Hit then
		self:EmitSound( self.Secondary.Sound )
		self:SetNextPrimaryFire( CurTime() + self.Primary.DelayHit )
		self:SetNextSecondaryFire( CurTime() + self.Primary.DelayHit )
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	else
		self:EmitSound( self.Primary.Sound )
		self:SetNextPrimaryFire( CurTime() + self.Primary.DelayMiss )
		self:SetNextSecondaryFire( CurTime() + self.Primary.DelayMiss )
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	end
	self.Owner:LagCompensation( false )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:ViewPunchReset()
	self.Owner:ViewPunch( Angle( math.Rand( 1, 2 ), math.Rand( -3.5, -1.5 ), 0 ) )
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:SecondaryAttack()
end

local IRONSIGHT_TIME = 0.25

function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.05
			self.BobScale 	= 0.05
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end

function SWEP:Reload()
end

function SWEP:Think()
end

-- LOLinc. 2023