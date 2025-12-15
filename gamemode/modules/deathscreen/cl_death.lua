local Material = Material
local hook = hook
local netstream = netstream
local LocalPlayer = LocalPlayer
local RealTime = RealTime
local pairs = pairs
local tostring = tostring
local math = math
local markup = markup
local Lerp = Lerp
local FrameTime = FrameTime
local ScrW = ScrW
local ScrH = ScrH
local draw = draw
local Color = Color
local surface = surface
local system = system
local timer = timer

local alpha_lerp, alpha = 0, 0

local skull = Material('hud/skull.png', 'mips smooth')
hook.Add('NextRP::IconLoaded', 'NextRP::LoadDeathScreenIcons', function()
    skull = NextRP.Style.Materials.SkullIcon
end)

netstream.Hook('NextRP::Death', function(bool, dmginfo)
    local RESPAWN_TIME = NextRP:GetDeathTime(LocalPlayer())
    if bool then
        local dead = RealTime()

        alpha = 250
        local markup_string = ''
        local dmginfo_state = false

        if dmginfo then
            for i, case in pairs(dmginfo) do
                dmginfo_state = true
                markup_string = markup_string..'<font=font_sans_21>'..case.att_color..tostring(case.attacker)..'</colour> нанёс вам <colour=214, 45, 32, 255>'..tostring( math.Round(case.damage) )..'</colour> урона </font>\n'
            end
        end

        local parsed = markup.Parse( markup_string )
        

        hook.Add('HUDPaint', 'RespawnTimer', function()
            local time = math.Round(RESPAWN_TIME - RealTime() + dead)
            alpha_lerp = Lerp(FrameTime()*6,alpha_lerp or 0,alpha or 0) or 0

            local w, h = ScrW(), ScrH()
            -- draw.DrawBlur( 0, 0, w, h, alpha_lerp/100 )

            draw.RoundedBox(0,0,0,w,h,Color(40, 40, 40, alpha_lerp))

            if dmginfo_state then draw.SimpleText('Список полученого урона:', 'font_sans_21', 20, 60, color_white, TEXT_ALIGN_LEFT, 0) end
            parsed:Draw( 30, 80, 0, 0 )

            draw.SimpleText('Вас убили без причины? Воспользуйтесь F1 что-бы подать жалобу.', 'font_sans_21', w * .5, h * .5 + 35 + 64, color_white, TEXT_ALIGN_CENTER, 0)

            if time > 0 then
                local tw = draw.SimpleText('Подождите '..time..' секунд, что-бы возродиться.', 'font_sans_24', w * .5, h * .5 + 64 , color_white, TEXT_ALIGN_CENTER, 0)
                
                surface.SetDrawColor(225, 177, 44, 255)
                surface.DrawRect(w * .5 - tw * .5, h * .5 + 64 + 22, tw, 2)
            else
                local tw = draw.SimpleText('Нажмите любую кнопку для возрождения.', 'font_sans_24', w * .5, h * .5 + 64, color_white, TEXT_ALIGN_CENTER, 0)

                surface.SetDrawColor(225, 177, 44, 255)
                surface.DrawRect(w * .5 - tw * .5, h * .5 + 64 + 22, tw, 2)
            end

            surface.SetMaterial(skull)
            surface.SetDrawColor(251, 197, 49, 255)
            surface.DrawTexturedRect(w * .5 - 64, h * .5 - 64 - 16, 128, 128)
        end)



        hook.Add('Think', 'RespawnTimerMusic', function()
            if (RealTime() - dead) < 1 then return end

            hook.Remove('Think', 'RespawnTimerMusic')

            if LocalPlayer():Alive() then return end
            if not system.HasFocus() then return end
        end)
        system.FlashWindow()
    else
        hook.Remove('HUDPaint', 'RespawnTimer')
    end

end)

hook.Add( 'CreateClientsideRagdoll', 'fade_out_corpses', function( entity, ragdoll )
	if entity:IsNPC() then
        timer.Simple(3, function() ragdoll:SetSaveValue( 'm_bFadingOut', true ) end)
    end
end )