include("shared.lua")

function ENT:Draw()
  self:DrawModel()

  self:DrawModel()

  local pos = self:GetPos()
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 0)
    ang:RotateAroundAxis(ang:Forward(), 85)
    local tF, tS = 'R-5', 'Нажмите [Е] чтобы сдать кристаллы'

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 40000 then
    cam.Start3D2D( pos + ang:Up()*0-Vector(0,0,30), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.025 )
      surface.SetFont("font_sans_3d2d_large")
      local xF, xS = select(1, surface.GetTextSize(tF)), select(1, surface.GetTextSize(tS))/2

      draw.SimpleText(tF,"font_sans_3d2d_large",xF,-4500,color_white,TEXT_ALIGN_CENTER)
      draw.SimpleText(tS, "font_sans_3d2d_large", xS-xS+150, -4000, color_white, TEXT_ALIGN_CENTER)

    cam.End3D2D()
  end
end
