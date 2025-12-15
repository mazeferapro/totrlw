--[[local LIB = PAW_MODULE('lib')
local Colors = MODULE.Config.Colors

local function ClaimMenu(LandName, ent)
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Занятие территории')
    frame:SetSize(400, 300)
    frame:MakePopup()
    frame:ShowSettingsButton(false)
    frame:Center()

    local panel = TDLib('DPanel', frame)
        :Stick(TOP)
        :ClearPaint()
        :Title('Вы действительно хотите занять '..LandName..'?')

    local button = TDLib('DButton', frame)
        :Stick(BOTTOM)
        :DivTall(2)
        :ClearPaint()
        :FadeHover(Colors.ButtonHover or Color(255, 192, 15))
        :On('DoClick', function(ent)
            netstream.Start('NextRP::ClaimerClaim', LocalPlayer(), ent)
        end
end

netstream.Hook('NextRP::ClaimerMenu', function(Title, ent)
    ClaimMenu(Title, ent)
end]]--