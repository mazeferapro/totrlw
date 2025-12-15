AddCSLuaFile()

SWEP.PrintName			= "Рукиы"
SWEP.Author				= "pack" -- The Maw
SWEP.Purpose    		= "Удерживайте левую кнопку мыши, чтобы перетащить элементы."
SWEP.Category = "SUP • Разное"

SWEP.ViewModel			= "models/weapons/c_medkit.mdl"
SWEP.WorldModel			= ""

-- SWEP.Category = "Supreme"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.PropMasses = {
    ['models/props_c17/gravestone004a.mdl'] = 300,
}

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self.animationsEnabled = false  -- Изначально анимации выключены
	
	self.Time = 0
	self.Range = 150
end

function SWEP:Think()
	if (self.Drag and (not self.Owner:KeyDown(IN_ATTACK) or not IsValid(self.Drag.Entity))) then
		self.Drag = nil
	end
end

function SWEP:PrimaryAttack()
	local Pos = self.Owner:GetShootPos()
	local Aim = self.Owner:GetAimVector()
	
	local Tr = util.TraceLine({
		start = Pos,
		endpos = Pos+Aim*self.Range,
		filter = player.GetAll(),
	})
	
	local HitEnt = Tr.Entity

	
	if (self.Drag) then 
		HitEnt = self.Drag.Entity
	else
		if (!IsValid(HitEnt) or HitEnt:GetMoveType() ~= MOVETYPE_VPHYSICS or HitEnt:IsVehicle()) then return end
			
		if (!self.Drag) then
			self.Drag = {
				OffPos = HitEnt:WorldToLocal(Tr.HitPos),
				Entity = HitEnt,
				Fraction = Tr.Fraction,
			}
		end
	end
	
	if (CLIENT or !IsValid(HitEnt)) then return end

	if not IsValid(HitEnt:GetNWEntity('Player')) then return end
	
	local Phys = HitEnt:GetPhysicsObject()
		
	if (IsValid(Phys)) then
		if !(HitEnt:GetPos():Distance(self.Owner:GetPos()) >= 10) then  return end
		local Pos2 		= Pos + Aim*self.Range*self.Drag.Fraction
		local OffPos 		= HitEnt:LocalToWorld(self.Drag.OffPos)
		local Dif 		= Pos2-OffPos
		local Nom 		= (Dif:GetNormal()*math.min(1,Dif:Length()/100)*500-Phys:GetVelocity())*Phys:GetMass()*2
		
		Phys:ApplyForceOffset(Nom,OffPos)
		Phys:AddAngleVelocity(-Phys:GetAngleVelocity()/4)
	end
end

function SWEP:Tick() -- Who was shit here?
	if not (SERVER and self.HitEnt) then return end
	self.DeBuff = false
	self.DeBuff_s = false
	if (self.Drag) then
		self.DeBuff = true
		self.DeBuff_s = true
	else
		self.DeBuff = false
	end

	if not self.HitEnt or not IsValid(self.HitEnt) then return end

	if not IsValid(self.HitEnt:GetNWEntity('Player')) then return end

	local Phys = self.HitEnt:GetPhysicsObject()

	if not Phys then return end
	local Mass = self.PropMasses[self.HitEnt:GetModel()] and self.PropMasses[self.HitEnt:GetModel()] or Phys:GetMass()

    local max_walkspeed = GAMEMODE.Config and GAMEMODE.Config.walkspeed or 200
    local max_runspeed = GAMEMODE.Config and GAMEMODE.Config.runspeed or 400

	if !(self.HitEnt:GetPos():Distance(self.Owner:GetPos()) >= 10) then  return end


    if self.DeBuff and Mass < 2000 then
		local run = math.min( max_runspeed, math.max( 60, 300-Mass ) )
        local walk = math.min( max_walkspeed, math.max( 60, 300-Mass ) )

        self.Owner:SetRunSpeed(run)
        self.Owner:SetWalkSpeed(walk)

		self.DeBuff_s = false
	else
        self.Owner:SetRunSpeed(max_runspeed)
        self.Owner:SetWalkSpeed(max_walkspeed)
	end
end

-- function SWEP:SecondaryAttack()
-- end

animstionsTable = {
	{
		name = 'Комлинк';
		bones = {
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(32.9448, -103.5211, 2.2273),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(-90.3271, -31.3616, -41.8804),
	        ["ValveBiped.Bip01_R_Hand"] = Angle(0,0,-24),
	    };
	};

	{
		name = 'Скрестить Руки';
		bones = {
            ["ValveBiped.Bip01_R_Forearm"] = Angle(-43.779933929443,-107.18412780762,15.918969154358),
            ["ValveBiped.Bip01_R_UpperArm"] = Angle(20.256689071655, -57.223915100098, -6.1269416809082),
            ["ValveBiped.Bip01_L_UpperArm"] = Angle(-28.913911819458, -59.408206939697, 1.0253102779388),
            ["ValveBiped.Bip01_R_Thigh"] = Angle(4.7250719070435, -6.0294013023376, -0.46876749396324),
            ["ValveBiped.Bip01_L_Thigh"] = Angle(-7.6583762168884, -0.21996378898621, 0.4060270190239),
            ["ValveBiped.Bip01_L_Forearm"] = Angle(51.038677215576, -120.44165039063, -18.86986541748),
            ["ValveBiped.Bip01_R_Hand"] = Angle(14.424224853516, -33.406204223633, -7.2624106407166),
            ["ValveBiped.Bip01_L_Hand"] = Angle(25.959447860718, 31.564517974854, -14.979378700256),
	    };
	};

	{
		name = 'Убрать Руки';
		bones = {
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(3.809, 15.382, 2.654),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(-63.658, 1.8 , -84.928),
	        ["ValveBiped.Bip01_L_UpperArm"] = Angle(3.809, 15.382, 2.654),
	        ["ValveBiped.Bip01_L_Forearm"] = Angle(53.658, -29.718, 31.455),

	        ["ValveBiped.Bip01_R_Thigh"] = Angle(4.829, 0, 0),
	        ["ValveBiped.Bip01_L_Thigh"] = Angle(-8.89, 0, 0),
	    };
	};

	{
		name = 'Дай пять!';
		bones = {
	        ["ValveBiped.Bip01_L_Forearm"] = Angle(25,-65,25),
	        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-70,-180,70),
	    };
	};

	{
		name = 'Гололинк';
		bones = {
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(10,-20),
	        ["ValveBiped.Bip01_R_Hand"] = Angle(0,1,50),
	        ["ValveBiped.Bip01_Head1"] = Angle(0,-30,-20),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-65,39.8863),
	    };
	};

	{
		name = 'Средний Палец';
		bones = {
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(15,-55,-0),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-55,-0),
	        ["ValveBiped.Bip01_R_Hand"] = Angle(20,20,90),
	        ["ValveBiped.Bip01_R_Finger1"] = Angle(20,-40,-0),
	        ["ValveBiped.Bip01_R_Finger3"] = Angle(0,-30,0),
	        ["ValveBiped.Bip01_R_Finger4"] = Angle(-10,-40,0),
	        ["ValveBiped.Bip01_R_Finger11"] = Angle(-0,-70,-0),
	        ["ValveBiped.Bip01_R_Finger31"] = Angle(0,-70,0),
	        ["ValveBiped.Bip01_R_Finger41"] = Angle(0,-70,0),
	        ["ValveBiped.Bip01_R_Finger12"] = Angle(-0,-70,-0),
	        ["ValveBiped.Bip01_R_Finger32"] = Angle(0,-70,0),
	        ["ValveBiped.Bip01_R_Finger42"] = Angle(0,-70,-0),
	    };
	};

	{
		name = 'Указать';
		bones = {
	        ["ValveBiped.Bip01_R_Finger2"] = Angle(4.151602268219, -52.963024139404, 0.42117667198181),
	        ["ValveBiped.Bip01_R_Finger21"] = Angle(0.00057629722869024, -58.618747711182, 0.001297949347645),
	        ["ValveBiped.Bip01_R_Finger3"] = Angle(4.151602268219, -52.963024139404, 0.42117667198181),
	        ["ValveBiped.Bip01_R_Finger31"] = Angle(0.00057629722869024, -58.618747711182, 0.001297949347645),
	        ["ValveBiped.Bip01_R_Finger4"] = Angle(4.151602268219, -52.963024139404, 0.42117667198181),
	        ["ValveBiped.Bip01_R_Finger41"] = Angle(0.00057629722869024, -58.618747711182, 0.001297949347645),
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(25.019514083862, -87.288040161133, -0.0012286090059206),
	    };
	};

	{
		name = 'Воинское Приветствие';
		bones = {
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(80, -95, -77.5),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(35, -125, -5),
	    };
	};

	{
		name = 'Сдаюсь!';
		bones = {
	        ["ValveBiped.Bip01_L_Forearm"] = Angle(25,-65,25),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(-25,-65,-25),
	        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-70,-180,70),
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(70,-180,-70),
	    };
	};
}

if SERVER then
    local function applyAnimation(ply, animation)
        if not IsValid(ply) then return end

        for boneName, angle in pairs(animation.bones) do
            local bone = ply:LookupBone(boneName)
            if bone then
                ply:ManipulateBoneAngles(bone, angle)
            end
        end
    end

	local angle_default = Angle(0, 0, 0)
	local function resetAnimation(ply)
        if not IsValid(ply) then return end

        for _, anim in ipairs(animstionsTable) do
            for boneName, _ in pairs(anim.bones) do
                local bone = ply:LookupBone(boneName)
                if bone then
                    ply:ManipulateBoneAngles(bone, angle_default)
                end
            end
        end
    end

    util.AddNetworkString('Animations:Select')
    util.AddNetworkString('Animations:Apply')
    util.AddNetworkString('Animations:Reset')

	net.Receive('Animations:Select', function(_, ply)
		if CurTime() < (ply.delay_anim or 0) then return end

        local ID = net.ReadUInt( 8 )
        if not ID then return end
        if not ply:Alive() then return end

        ply.selectedAnimation = ID

		ply.delay_anim = CurTime() + 1
    end)

    net.Receive('Animations:Apply', function(_, ply)
		if CurTime() < (ply.delay_anim or 0) then return end

        if not ply:Alive() then return end
        if not ply.selectedAnimation then return end

        local animation = animstionsTable[ply.selectedAnimation]
        if not animation then return end

        applyAnimation(ply, animation)
		ply.delay_anim = CurTime() + 1
    end)

    net.Receive('Animations:Reset', function(_, ply)
		if CurTime() < (ply.delay_anim or 0) then return end

        if not ply:Alive() then return end

        resetAnimation(ply)
		ply.delay_anim = CurTime() + 1
    end)
end

if CLIENT then
	-- function SWEP:Initialize()
	-- 	self.animationsEnabled = false  -- Изначально анимации выключены
	-- end
	
	function SWEP:SecondaryAttack()
		if CurTime() < self:GetNextPrimaryFire() then return end
	
		self.animationsEnabled = not self.animationsEnabled -- Переключаем состояние анимаций
	
		if self.animationsEnabled then
			net.Start('Animations:Apply')
		else
			net.Start('Animations:Reset')
		end
	
		net.SendToServer()
	
		self:SetNextPrimaryFire(CurTime() + 0.1)
	end
	-- function SWEP:SecondaryAttack()
	-- 	if CurTime() < self:GetNextPrimaryFire() then return end

    --     net.Start('Animations:Apply')
    --     net.SendToServer()

	-- 	self:SetNextPrimaryFire(CurTime() + 2)

	-- 	if CurTime() < self:GetNextSecondaryFire() then return end

    --     net.Start('Animations:Reset')
    --     net.SendToServer()

	-- 	self:SetNextSecondaryFire(CurTime() + 2)
    -- end

    -- function SWEP:SecondaryAttack()
	-- 	if CurTime() < self:GetNextSecondaryFire() then return end

    --     net.Start('Animations:Reset')
    --     net.SendToServer()

	-- 	self:SetNextSecondaryFire(CurTime() + 1)
    -- end

	local scrw, scrh = ScrW(), ScrH()

	local col = {
		back = Color(22, 23, 28, 150);
		white = Color( 255, 255, 255 );
		close = Color(180, 49, 28, 255);
	}

	local mats = {
		logo = Material( 'luna_icons/body-balance.png', 'smooth mips');
	}

	local function scale(nNum)
		return nNum
	end

	local draw = draw

	function draw.ShadowSimpleText(text, font, x, y, color, alignment_x, alignment_y, shadow_distance)
		shadow_distance = shadow_distance or 1
		draw.SimpleText(text, font, x, y + shadow_distance, color_shadow, alignment_x, alignment_y)

		return draw.SimpleText(text, font, x, y, color, alignment_x, alignment_y)
	end

	local headerSizeH = scale(50)

	local fr
	function SWEP:Reload()
		if CurTime() < (self.delay or 0) then return end

		if IsValid( fr ) then return end
		local ply = LocalPlayer()

		fr = vgui.Create( 'Panel' )
		fr:SetSize( scrw, scrh )
		fr:MakePopup()
		fr:SetAlpha(0)
		fr:AlphaTo( 255, 0.3 )
		fr.startTime = SysTime()

		fr.Paint = function(self, w, h)
			Derma_DrawBackgroundBlur(self, self.startTime)
		end

		local frW, frH = fr:GetSize()

		local panel = fr:Add( 'Panel' )
		panel:SetSize( scale(450), scale(400) )
		panel:Center()
		panel:DockPadding( scale(10), headerSizeH + scale(10), scale(10), scale(10) )

		panel.Paint = function( _, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, col.back )
			draw.RoundedBox( 0, 0, 0, w, headerSizeH, col.back )

			surface.SetMaterial( mats.logo )
			surface.SetDrawColor(col.white )
			surface.DrawTexturedRect( scale(10), scale(10), scale(32), scale(32) )

			draw.ShadowSimpleText( "АНИМАЦИИ", luna.MontBase30, scale(50), scale(12), col.white, 0, 3 )
		end

		local close = panel:Add( 'DButton' )
		close:SetSize( headerSizeH, headerSizeH )
		close:SetX( panel:GetWide() - close:GetWide() )
		
		close.Paint = function(self, w, h)
			draw.RoundedBox( 4, 0, 0, w, h, col.close )
			draw.ShadowSimpleText( "X", luna.MontBaseTitle, w *.5, h *.5, color_white, 1, 1)

			return true
		end

		close.DoClick = function()
			fr:Remove()
			surface.PlaySound( "luna_ui/pop.wav" )
		end

		local scroll = panel:Add( TDLib('DScrollPanel') )
		scroll:Dock(FILL)
		scroll.pnl = nil

		for id, anim in ipairs( animstionsTable ) do
			local item = scroll:Add( 'DButton' )
			item:Dock(TOP)
			item:SetTall( scale(32) )
			item:DockMargin( 0, 0, 0, scale(5) )

			item.DoClick = function( s )
				if CurTime() < (ply.delaySelect or 0) then return end
				ply.selectAnim = id

				net.Start('Animations:Select')
					net.WriteUInt( id, 8 )
                net.SendToServer()

				surface.PlaySound( "luna_ui/pop.wav" )
				ply.delaySelect = CurTime() + 1
			end

			item.Paint = function(self, w, h)
				if ply.selectAnim == id then
					surface.SetDrawColor( col.white )
					surface.DrawOutlinedRect( 0, 0, w, h )
				end
                draw.RoundedBox(0, 0, 0, w, h, col.back)
                draw.ShadowSimpleText(anim.name, luna.MontBase24, w * .5, h * .5, col.white, 1, 1)

				return true
            end

		end

		self.delay = CurTime() + 1
	end


	local x, y = ScrW() * .5, ScrH() * .5

	function SWEP:DrawHUD()
		if (IsValid(self.Owner:GetVehicle())) then return end
		local Pos = self.Owner:GetShootPos()
		local Aim = self.Owner:GetAimVector()
		
		local Tr = util.TraceLine({
			start = Pos,
			endpos = Pos+Aim*self.Range,
			filter = player.GetAll(),
		})
		
		local HitEnt = Tr.Entity

		
		if (IsValid(HitEnt) and HitEnt:GetMoveType() == MOVETYPE_VPHYSICS and not self.Drag and not HitEnt:IsVehicle()) then
			self.Time = math.min(1,self.Time+2*FrameTime())
		else
			self.Time = math.max(0,self.Time-2*FrameTime())
		end
		
		-- print(1)
		-- print(HitEnt:GetNWEntity('Player'))
		-- if not IsValid(HitEnt:GetNWEntity('Player')) then return end
		
		local Pos2 = Pos + Aim*150*Tr.Fraction
		local B = Pos2:ToScreen()

		-- if not (not IsValid(HitEnt) or HitEnt:GetMoveType() ~= MOVETYPE_VPHYSICS or HitEnt:IsVehicle()) and not (self.Drag) then
			draw.RoundedBox(4,B.x-3,B.y-3,6,6,Color(255,255,255,140))
		-- end

		if (self.Drag and IsValid(self.Drag.Entity)) then
			local Pos2 = Pos + Aim*100*self.Drag.Fraction
			local OffPos = self.Drag.Entity:LocalToWorld(self.Drag.OffPos)
			local Dif = Pos2-OffPos
			
			local A = OffPos:ToScreen()
			local B = Pos2:ToScreen()

			draw.RoundedBox(6,A.x-5,A.y-5,10,10,Color(255,255,255,140))
			
		end
	end
end

function SWEP:PreDrawViewModel( vm,pl,wep)
	return true
end


--[[AddCSLuaFile()
SWEP.Base				= "weapon_base"
SWEP.PrintName			= "Коробка с кристаллами"
SWEP.ViewModel			= "models/weapons/c_nsuitcase.mdl"
SWEP.WorldModel			= "models/weapons/w_nsuitcase.mdl"
SWEP.ViewModelFOV 		= 54
SWEP.HoldType			= "none"
SWEP.UseHands			= "true"
SWEP.Purpose			= ""
SWEP.Weight				= 2
SWEP.AutoSwitchTo		= true
SWEP.Spawnable			= false

SWEP.Primary.Sound			= ""
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Recoil			= 0
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 0
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Tracer			= 0
SWEP.Primary.Force			= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "normal"
SWEP.Category 				= "Other"

SWEP.Secondary.Sound		= ""
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 0
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Cone			= 0
SWEP.Secondary.Delay		= 0
SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Tracer		= 0
SWEP.Secondary.Force		= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "normal"

function SWEP:Initialize()

	self:SetWeaponHoldType("normal")]]--
	--[[local ply=self:GetOwner()
	if CLIENT then return end
	if ply:IsPlayer() then
		if CrysCollectTable[ply:SteamID()] then
			local collect = CrysCollectTable[ply:SteamID()]
			local ws = ply:GetWalkSpeed()
			local rs = ply:GetRunSpeed()
			local wsn = ws - 0.1 * collect
			local rsn = rs - 0.1 * collect
			if wsn <= 0 then wsn = ws - 10 end
			if rsn <= 0 then rsn = rs - 10 end
			ply:SetWalkSpeed(wsn)
			ply:SetRunSpeed(rsn)
		end
	end]]--
--end
--function SWEP:PrimaryAttack(ply)
--[[	local ply=self.Owner
	if CLIENT then return end
	if not IsFirstTimePredicted() then return end
	if ply:IsPlayer() then
		local ent = ents.Create(self:GetClass())
            if ply:GetPos():Distance(ply:GetEyeTrace().HitPos) > 200 then
               ent:SetPos(ply:GetShootPos() + (ply:GetAimVector()*100))
            else
                ent:SetPos(ply:GetEyeTrace().HitPos)
            end
            ent:SetAngles(ply:GetAngles())
            ent:DropToFloor()
            ent:Spawn()
		self:GetOwner():StripWeapon(self:GetClass())
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)]]
--end
--function SWEP:SecondaryAttack() end
--function SWEP:Think() end