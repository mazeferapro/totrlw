include("shared.lua")
AddCSLuaFile()

include("Shared.lua")

surface.CreateFont( "EPS_SimulationTracker", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 45,
})

surface.CreateFont( "EPS_SimulationTrackerBig", {
	font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 100,
})

function ENT:Draw()
	local simulationcount = nil

    self:DrawModel()

	if istable(Arrestants) then
		simulationcount = table.Count(Arrestants)
   	end

    local pos = self:LocalToWorld(Vector(-1, -85, 77))
    local ang = self:LocalToWorldAngles(Angle(0, -270, 90))

    cam.Start3D2D(pos, ang, 0.1)
    	local placement = 200

	    draw.RoundedBox(0, 158, 186, 1384, 576, Color(49, 112, 112, 155))
	    draw.SimpleText("Арестанты", "EPS_SimulationTrackerBig", 800, 130, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	    if istable(Arrestants) then
	    	local ply
	    	local time
	    	local inzone
	    	for k, v in pairs(Arrestants) do
	    		ply = player.GetBySteamID(k)
	    		time = CurTime() - (ArrestantsTime[k] + v)
	    		if ply then inzone = ply:Kitsune_Arrest_Escape() else inzone = nil end
	    		if placement < 875 then
		    		draw.RoundedBox(0, 158, placement, 1384, 100, Color(49, 112, 112, 255))

		    		draw.SimpleText(EPS_ShortenString((ply and ply:Nick() or k).." / Посажен: "..(string.NiceTime(CurTime() - ArrestantsTime[k])).. " назад".. (inzone and ' / Сидеть:'..(string.NiceTime((ArrestantsTime[k] + v) - CurTime())) or ' / Сбежал!'), 120), "EPS_SimulationTracker", 855, placement + 50, inzone and Color(255,255,255) or Color(255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		    		placement = placement + 125
		    	end
	    	end

	    	if simulationcount > 7 then
		    	draw.SimpleText(". . . . .", "EPS_SimulationTrackerBig", 885, 950, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	    	end
	    end

    cam.End3D2D()
end