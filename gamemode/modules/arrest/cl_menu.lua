local theme = NextRP.Style.Theme
local LIB = PAW_MODULE('lib')
local Colors = {
        Text = Color(37, 37, 37),
        Base = Color(200, 200, 200),
        BaseDarker = Color(100, 100, 100),
        Button = Color(127, 128, 132),
        ButtonHover = Color(215, 216, 218),
        CloseHover = Color(255, 89, 89),
        AccptHover = Color(85, 243, 133),

        Green = Color(90, 200, 90),
        Red = Color(255, 69, 69)
    }

local function Kitsune_ArrestMenu(pl, Cal)
    if not Cal:IsPlayer() then return end
    local frame = vgui.Create('PawsUI.Frame')
        frame:SetTitle('Арест')
        frame:SetSize(1000, 600)
        frame:MakePopup()
        frame:Center()
        frame:ShowSettingsButton(false)

    local info = vgui.Create('PawsUI.Panel', frame)
        :Stick(FILL)

    local Title = TDLib('DPanel', frame)
        :Stick(TOP, 5)
        :ClearPaint()
        :On('Paint', function(s, w, h)
            draw.DrawText('Свежее мясо\n'..'Давай сюда, я разберусь.', 'font_sans_21', w * 0.5, 0, color_white, TEXT_ALIGN_CENTER)
        end)
    Title:SetTall(45)

    local scrollPanel = TDLib('DScrollPanel', frame)
        :Stick(FILL)

    local scrollPanelBar = scrollPanel:GetVBar()
    scrollPanelBar:TDLib()
        :ClearPaint()
        :Background(theme.DarkScroll)

    scrollPanelBar.btnUp:TDLib()
        :ClearPaint()
        :Background(theme.DarkScroll)
        :CircleClick()

    scrollPanelBar.btnDown:TDLib()
        :ClearPaint()
        :Background(theme.DarkScroll)
        :CircleClick()

    scrollPanelBar.btnGrip:TDLib()
        :ClearPaint()
        :Background(theme.Scroll)
        :CircleClick()

    for _, target in pairs(pl) do
            local pnl = vgui.Create('PawsUI.Panel')
                :Stick(TOP)
                :Background(Color(53 + 15, 57 + 15, 68 + 15, 100))
                pnl:SetHeight(150)
                pnl:SetTall(100)

            local AvatarCircle = vgui.Create('PawsUI.Panel', pnl)
                :Stick(LEFT, 2)
                :SquareFromHeight()
                :ClearPaint()
                --:Circle(team.GetColor(target:Team()))

            local Avatar = TDLib('AvatarImage', AvatarCircle)
                Avatar:SetSize(64, 64)
                Avatar:SetPlayer(target)

            local tname = vgui.Create('PawsUI.Panel', pnl)
                :Stick(TOP, 2)
                :DivTall(3)
                :ClearPaint()
                tname:On('Paint', function(s, w, h)
                    draw.DrawText(target:Nick() or 'None', 'font_sans_21', 1, 5, NextRP.Style.Theme.Text, nil, TEXT_ALIGN_LEFT)
                end)

            local reciveButton = TDLib('DButton', pnl)
                :ClearPaint()
                :Stick(FILL, 3)
                :Background(NextRP.Style.Theme.Background)
                :FadeHover(NextRP.Style.Theme.Accent)
                :LinedCorners()
                :Text('Выбрать', 'font_sans_21')
                :On('DoClick', function()
                    LIB:DoStringRequest('Время', 'Введите время в минутах', '0', function(v)
                        --[[net.Start('KitsuneArest')
                            net.WritePlayer(target)
                            net.WriteString(v)
                        net.SendToServer()]]--
                        netstream.Start('NextRP::ArrestArresting', target, v)
                    end, nil, 'Подтвердить', 'Отмена')
                end)

            pnl:SetTall(64 + 2)
            scrollPanel:Add(pnl)
    end
end

netstream.Hook('NextRP::OpenArrestMenu', function(Cal, pos)
    local pp = player.FindInSphere(pos, 200) or {}
    Kitsune_ArrestMenu(pp, Cal)
end)

Arrestants = {}
ArrestantsTime = {}

net.Receive('KitsuneArest', function()
    local tArest = util.JSONToTable(net.ReadString())
    local tArestTime = util.JSONToTable(net.ReadString())
    if not table.IsEmpty(tArest) and not table.IsEmpty(tArestTime) then
        Arrestants = tArest
        ArrestantsTime = tArestTime
    end
    for k, v in pairs(Arrestants) do
        local schet = ArrestantsTime[k] + Arrestants[k]
        if CurTime() >= schet then ArrestantsTime[k] = nil Arrestants[k] = nil end
    end
end)