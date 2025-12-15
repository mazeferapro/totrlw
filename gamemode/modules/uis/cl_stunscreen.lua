local alpha = 0
local alpha_lerp = 0

local function RemoveStunScreean()
    hook.Remove('Think', 'StunTimer')
    hook.Remove('HUDPaint', 'StunTimer')
end

function NextRP:StunScreen(bShow, pActor, nTime)
    if bShow then
        local dead = RealTime()
        local sActorName = pActor:Name()

        alpha = 250

        local skull = PawsUI.Materials.Stun

        hook.Add('HUDPaint', 'StunTimer', function()
            local time = math.Round(nTime - RealTime() + dead)
            alpha_lerp = Lerp(FrameTime()*6,alpha_lerp or 0,alpha or 0) or 0

            local w, h = ScrW(), ScrH()
            -- draw.DrawBlur( 0, 0, w, h, alpha_lerp/100 )

            draw.RoundedBox(0,0,0,w,h,Color(40, 40, 40, alpha_lerp))

            draw.SimpleText('О Г Л У Ш Е Н', 'font_sans_35', w * .5, h * .5 - 128, NextRP.Style.Theme.Red, TEXT_ALIGN_CENTER, 0)

            draw.SimpleText('Вас оглушил '..sActorName, 'font_sans_21', w * .5, h * .5 + 35 + 64, color_white, TEXT_ALIGN_CENTER, 0)
            draw.SimpleText('Вас оглушили без причины? Воспользуйтесь F1 что-бы подать жалобу.', 'font_sans_21', w * .5, h * .5 + 35 + 64 + 21, color_white, TEXT_ALIGN_CENTER, 0)
            

            if time > 0 then
                local tw = draw.SimpleText('Подождите '..time..' секунд, до прихода в сознание.', 'font_sans_24', w * .5, h * .5 + 64 , color_white, TEXT_ALIGN_CENTER, 0)
                
                surface.SetDrawColor(225, 177, 44, 255)
                surface.DrawRect(w * .5 - tw * .5, h * .5 + 64 + 22, tw, 2)
            end

            surface.SetMaterial(skull)
            surface.SetDrawColor(251, 197, 49, 255)
            surface.DrawTexturedRect(w * .5 - 64 - math.random(-5, 5), h * .5 - 64 - 16 - math.random(-5, 5), 128, 128)
        end)

        hook.Add('Think', 'StunTimer', function()
            if not LocalPlayer():Alive() then
                RemoveStunScreean()
            end
        end)
    else
        RemoveStunScreean()
    end
end

netstream.Hook('NextRP::StunScreen', function(bBool, pActor, nTime)
    NextRP:StunScreen(bBool, pActor, nTime)
end)