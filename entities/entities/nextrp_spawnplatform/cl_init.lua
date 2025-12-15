include('shared.lua')

local SHOULD_DRAW = CreateConVar( 'nrp_showspawn', 0, FCVAR_ARCHIVE, 'Показывает или скрывает сообщения' )

function ENT:Initialize()
	self:SetNoDraw(true)
end

function ENT:Think()
	local shouldDraw = SHOULD_DRAW:GetBool()

	self:SetNoDraw(!shouldDraw)
end

local function InverseLerp( pos, p1, p2 )
	local range = 0
	range = p2-p1
	if range == 0 then return 1 end
	return ((pos - p1)/range)
end

function ENT:Draw()
	if( self:GetNoDraw() ) then return end
    self:DrawModel()

    local distance = LocalPlayer():GetPos():DistToSqr(self:GetPos())
	if(distance > 30000 * 2) then return end

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + ang:Up() + Vector(0, 0, 15)

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local alpha = math.Clamp(math.Remap(distance, 30000 * 0.25, 30000, 255, 0), 0, 255)

    local name = NextRP.JobsByID[self:GetJobID()] and NextRP.JobsByID[self:GetJobID()].name or 'NoName'
    local color = NextRP.JobsByID[self:GetJobID()] and NextRP.JobsByID[self:GetJobID()].color or color_white

    cam.Start3D2D( pos, ang, 0.025 )
		draw.SimpleText( 'Точка спавна', 'font_sans_3d2d_small', 0, 0, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER )
		draw.SimpleText( name, 'font_sans_3d2d_large', 0, 72, Color(color.r or 0, color.g or 0, color.b or 0, alpha), TEXT_ALIGN_CENTER )
	cam.End3D2D()
end

netstream.Hook('NextRP::SelectSpawnJob', function(eEnt)
    local m = vgui.Create('Paws.Menu')

    for k, v in NextRP.GetSortedCategories() do
        local categpM = m:AddSubMenu(v.name)

        for k, job in ipairs(v.members) do
            categpM:AddOption(job.name, function()
                netstream.Start('NextRP::SelectSpawnJob', eEnt, job.id)
            end)
        end
    end

    m:Open()
    m:Center()
end)