include('shared.lua')

function ENT:Draw()
	self:DrawModel()

	self:DrawModel()

	local alpha = 255
	local viewdist = 250

	-- calculate alpha
	local max = viewdist
	local min = viewdist*0.75

	local dist = LocalPlayer():EyePos():Distance( self:GetPos() )

	if dist > min and dist < max then
		local frac = InverseLerp( dist, max, min )
		alpha = alpha * frac
	elseif dist > max then
		alpha = 0
	end

	local oang = self:GetAngles()
	local opos = self:GetPos()

	local ang = self:GetAngles()
	local pos = self:GetPos()

	ang:RotateAroundAxis( oang:Up(), 90 )
	ang:RotateAroundAxis( oang:Right(), -90 )
	ang:RotateAroundAxis( oang:Up(), 90)

	pos = pos + oang:Forward() * 13 + oang:Up() * 50  + oang:Right() * -25

	if alpha > 0 then
		cam.Start3D2D( pos, ang, 0.25 )

		surface.SetFont("Trebuchet24")
		local dX,dY = surface.GetTextSize("Аренда кирки")

		surface.SetDrawColor(32,32,32,125)

			draw.SimpleTextOutlined("Аренда кирки","Trebuchet24",50,-150,Color(235,235,235),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,0,Color(25,25,25))
			draw.DrawText("Нажмите [ Е ] чтобы получить", "Trebuchet24", -100, 0, Color(255,255,255))
			draw.DrawText("Стоимость аренды: 300 кредитов", "Trebuchet24", -100, 50, Color(255,255,255))

		cam.End3D2D()
	end
end