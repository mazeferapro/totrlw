include("shared.lua")

function ENT:Draw()
  if not IsValid(self) or not IsValid(LocalPlayer()) then return end

  self:DrawModel()

  local pos = self:GetPos()
  local ang = self:GetAngles()
  ang:RotateAroundAxis(ang:Up(), 0)
  ang:RotateAroundAxis(ang:Forward(), 85)

  if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 40000 then
    cam.Start3D2D(pos + ang:Up()*0-Vector(0,0,30), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.025)

      draw.SimpleText('Нажмите [Е] для добычи', "font_sans_3d2d_large", 0, -3085, color_white, TEXT_ALIGN_CENTER)

    cam.End3D2D()
  end
end