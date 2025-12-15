ENT.Base = 'base_brush'
ENT.Type = 'brush'

if SERVER then
    ENT.PointA = Vector(0, 0, 0)
    ENT.PointB = Vector(1, 1, 1)
    ENT.id = ''
    
    function ENT:Initialize()
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionBounds(self.PointA, self.PointB)

        NextRP.Teleports[#NextRP.Teleports + 1] = self
    end

    function ENT:StartTouch()
        
    end 
else
    -- function ENT:Draw()
    --     cam.Start3D(self:GetPos())
    --         render.SetMaterial(mat)
    --         render.DrawBox(Vector(0, 0, 0), Angle(0, 0, 0), self.PointA, self.PointB, COLOR_WHITE)

    --         render.DrawSphere(self.PointA, 25, 50, 50, Color(150, 50, 50))
    --         render.DrawSphere(self.PointB, 25, 50, 50, Color(150, 50, 50))
    --     cam.End3D()
    -- end
end