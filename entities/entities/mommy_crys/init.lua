AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
--"models/niksacokica/items/red_crystal.mdl"
function ENT:Initialize()
    self:SetModel('models/statua/starwars/crystals/orange.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMaterial(MAT_GLASS)
    self:SetUseType(SIMPLE_USE)

    self:SetMaxHealth(250)
    self:SetHealth(250)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

    phys:EnableMotion( false )
end

function ENT:Use( activator, Caller )
    if IsValid(activator) and activator:IsPlayer() and activator:GetActiveWeapon():GetClass() == 'weapon_pickaxe' then
        activator:Freeze(true)
        net.Start('ProgressBarStart')
            net.WriteString('Добыча')
            net.WriteUInt(10, 8)
        net.Send(activator)

        activator:SetAnimation( PLAYER_ATTACK1 )

        activator:ViewPunch( Angle( 0, 0, 3 ) )

        timer.Create( "Effects."..activator:SteamID(), 1, 9, function()
            if not IsValid( activator ) or not activator:Alive() then
                return
            end

            activator:ViewPunch( Angle( 0, 0, 3 ) )

            activator:SetAnimation( PLAYER_ATTACK1 )
        end )
        timer.Simple(10, function()
            local tr = activator:GetEyeTrace()
            local crys = ents.Create("money_crys")
                local dir = (tr.HitPos-tr.StartPos):GetNormalized()
                local dist = tr.StartPos:Distance(tr.HitPos) > 250 and 250 or tr.StartPos:Distance(tr.HitPos)
                local pos = tr.StartPos + dir * dist*.5
                crys:SetPos(pos)
                --crys:SetPos(self:GetPos() + Vector(math.random(-15, 15), math.random(-15, 15), 0))
            crys:Spawn()
            activator:Freeze(false)
            local dmg, dmgI = math.random(5, 15), DamageInfo()
            dmgI:SetDamage(dmg)
            dmgI:SetAttacker(self)
            self:TakeDamageInfo(dmgI)
            --self:TakeDamage(math.random(5, 15))
        end)
    else
        activator:PrintMessage(4, "Вам нужна кирка для добычи кристаллов!")
    end
end

function ENT:OnTakeDamage(dmginfo)
    if dmginfo:GetAttacker() ~= self then return end
    local CurHealth = self:Health()
    self:TakePhysicsDamage(dmginfo)
    local NewHealth = math.Clamp(CurHealth - dmginfo:GetDamage(), -1, 250)

    self:SetHealth(NewHealth)

    if NewHealth <= 0 then
        self:SetColor(Color (0, 0, 0, 0))
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetCollisionGroup(10)
        self:EmitSound("ambient/materials/footsteps_glass1.wav")

        timer.Simple(1800, function()
            self:SetColor(Color(255, 255, 255, 255))
            self:SetRenderMode(RENDERMODE_TRANSCOLOR)
            self:SetCollisionGroup(0)
            self:SetHealth(250)
        end)
    end
end