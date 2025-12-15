if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName			= 'Руки'
SWEP.Author				= 'Kot'
SWEP.Purpose				= 'Not much.'
SWEP.Spawnable				= true
SWEP.Category				= 'DOTR | Другое'

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Slot			= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.Primary.Automatic = false

SWEP.PointA, SWEP.PointB = nil, nil

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end

	self:SetNextPrimaryFire( CurTime() + 1 )

    local Pos = self.Owner:GetShootPos()
	local Aim = self.Owner:GetAimVector()

    local trace = util.TraceLine({
        start = Pos,
        endpos = Pos + Aim * 500,
        filter = self.Owner
    })

    if not self.PointA then
        self.PointA = trace.HitPos
        print('Point A set!')
        return 
    end
    if not self.PointB then
        self.PointB = trace.HitPos
        print('Point B set!')
        return 
    end

    if CLIENT then
        -- NextRP.Teleports = NextRP.Teleports or {}
        -- NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}
        -- NextRP.Teleports.Brushes[#NextRP.Teleports.Brushes + 1] = {a = self.PointA, b = self.PointB}

        NextRP.Teleports:OpenAdminMenu(self.PointA, self.PointB)
    end
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end

	self:SetNextSecondaryFire( CurTime() + 1 )

    self.PointA, self.PointB = nil, nil   
    
    print('CLEARED')
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end

    if CLIENT then
        NextRP.Teleports:OpenConfigMenu()
    end
end

if CLIENT then
    local mat = Material('models/wireframe')
    function SWEP:DrawHUD()
        if self.PointA then           
            local secondPoint = self.PointB
            if not secondPoint then
                local Pos = self.Owner:GetShootPos()
	            local Aim = self.Owner:GetAimVector()

                local tr = util.TraceLine({
                    start = Pos,
                    endpos = Pos + Aim * 500,
                    filter = self.Owner
                })

                secondPoint = tr.HitPos
            end            
            cam.Start3D()
                -- render.SetColorMaterial()
                render.SetMaterial(mat)
                
                render.DrawBox(Vector(0, 0, 0), Angle(0, 0, 0), self.PointA, secondPoint, Color(150, 50, 50))

                render.DrawSphere(self.PointA, 25, 10, 10, Color(150, 50, 50))
                render.DrawSphere(secondPoint, 25, 10, 10, Color(150, 50, 50))
            cam.End3D()
        end

        NextRP.Teleports = NextRP.Teleports or {}
        NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}

        cam.Start3D()
            for id, ent in ipairs( NextRP.Teleports.Brushes ) do
                render.SetMaterial(mat)
                render.DrawBox(Vector(0, 0, 0), Angle(0, 0, 0), ent.a, ent.b, Color(150, 50, 50))
            end
        cam.End3D()

        local instruction = 'ПКМ что-бы установить первую точку!'

        if self.PointA and not self.PointB then
            instruction = 'ПКМ что-бы установить вторую точку!'
        elseif self.PointA and self.PointB then
            instruction = 'ПКМ что-бы подтвердить!'
        end
        
        draw.SimpleText(instruction, 'font_sans_16', ScrW() * .5, ScrH() * .5 + 60, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText('ЛКМ что-бы очистить выделение!', 'font_sans_16', ScrW() * .5, ScrH() * .5 + 80, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end
end

