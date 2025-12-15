--[[local IsValid = IsValid
local LocalPlayer = LocalPlayer
local Vector = Vector
local math = math
local pairs = pairs
local istable = istable
local table = table
local cam = cam
local Angle = Angle
local surface = surface
local draw = draw
local ColorAlpha = ColorAlpha
local Color = Color
local hook = hook
local player = player

local dist = 30000
local function DrawPlayerOverhead(ply)
	if(!IsValid(ply)) then return end
	if(ply == LocalPlayer()) then return end
	if(!ply:Alive()) then return end
	if(ply:GetNoDraw()) then return end
    if ply:GetNVar('nrp_charid') == false then return end
    if ply:getJobTable() == false then return end

	local distance = LocalPlayer():GetPos():DistToSqr(ply:GetPos())
	if(distance > dist) then return end

	local ang = LocalPlayer():EyeAngles()
	local pos = ply:EyePos() + ang:Up() + Vector(0, 0, 15)

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local alpha = math.Clamp(math.Remap(distance, dist/4, dist, 255, 0), 0, 255)

	local name = ply:FullName()
	local rank = ply:GetFullRank() .. ' / ' .. ply:GetRank()

	local spec = ply:GetNVar('nrp_charflags')
	local jt = ply:getJobTable()

	local final = 'Без специализации'
	if spec then
		for k, v in pairs(spec) do
			if not istable(final) then final = {} end
			if jt.flags[k] then final[#final + 1] = jt.flags[k].id elseif NextRP.Config.Pripiskis[k] then final[#final + 1] = NextRP.Config.Pripiskis[k].id end
		end
	end

	if istable(final) then
		final = table.concat(final, ', ')
	end

	local jobname = ply:getJobTable().category
	if ply:getJobTable().type == TYPE_ADMIN then return end
	cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.06)

		if ply:IsSpeaking() then
			surface.SetDrawColor(NextRP.Style.Theme.Text)
			surface.SetMaterial(PawsUI.Materials.TalkIcon)
			surface.DrawTexturedRect(-32, -92, 64, 64)
		end

		draw.SimpleText(name, 'font_sans_56', 0, 0, ColorAlpha(color_white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, ColorAlpha(Color(255,255,255), alpha) )
        draw.SimpleText(rank, 'font_sans_35', 0, 40, ColorAlpha( color_white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(final, 'font_sans_35', 0, 70, ColorAlpha( color_white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(jobname, 'font_sans_56', 0, 105, ColorAlpha( color_white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

hook.Add('PostDrawTranslucentRenderables', 'NextRP::OverheadHUD', function()
	if(!hook.Run('HUDShouldDraw', 'NextRP::DrawOverheadHUD')) then return end
	for k, v in player.Iterator() do
		local isCloak = v:GetNWBool("advaced_cloak_started")
		if isCloak or v:GetMoveType() == MOVETYPE_NOCLIP then continue end
		DrawPlayerOverhead(v)
	end
end)

hook.Add('PostDrawTranslucentRenderables', 'NextRP::ItemsHUD', function()
	if(!hook.Run('HUDShouldDraw', 'NextRP::DrawOverheadHUD')) then return end
end)

hook.Remove('PostDrawTranslucentRenderables', 'NextRP::ItemsHUD')]]--