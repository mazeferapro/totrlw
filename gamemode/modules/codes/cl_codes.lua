NextRPActiveCode = NextRPActiveCode or nil
local function DrawFlexText(colors, font, x, y)
    surface.SetFont(font)
    surface.SetTextPos(x, y)

    for k, v in ipairs(colors) do
        local col = v[2]
        surface.SetTextColor(col.r, col.g, col.b, col.a or 255)
        surface.DrawText(tostring(v[1]) .. (v[3] and '' or ' '))
    end
end

hook.Add('HUDPaint', 'NextRP::DrawCode', function()
    if LocalPlayer():GetNWBool('Dcd') then return end
    local jt = LocalPlayer():getJobTable()
    if not jt then return end

    local control = jt.control
    if NextRPActiveCode == nil then return end

    if not NextRP.Config.Codes.States[control] then return end

    local CODE = NextRP.Config.Codes.States[control][NextRPActiveCode]
    if not CODE then return end

    DrawFlexText({
        {
            'Текущий код:',
            Color(255, 255, 255, 255),
            false
        },
        {
            CODE.Title,
            CODE.Color,
            true
        },
        {
            '.',
            Color(255, 255, 255, 255),
            false
        }
    }, 'font_sans_24', 9, 50)

    draw.SimpleText(CODE.Description, 'font_sans_16', 9, 70, Color(255, 255, 255, 255))
end)

netstream.Hook('NextRP::NotifyChangeCode', function(suppres, code, pActor)
    NextRPActiveCode = code

    if not suppres then
        local CODE = NextRP.Config.Codes.States[LocalPlayer():getJobTable().control][NextRPActiveCode]

        NextRP:ScreenNotify(nil, nil, nil, string.format('На базе установлен "%s" код.\n%s\n\nУстановил: %s', CODE.Title, CODE.Description, pActor:Nick()))

        if CODE.Sound then
            surface.PlaySound( CODE.Sound )
        end
    end
end) 

local function GetPerms(CONTROL)
    if NextRP.Config.Codes.Permissions[CONTROL] then
        local perms = NextRP.Config.Codes.Permissions[CONTROL][LocalPlayer():Team()]
        if istable(perms) then
            if perms[LocalPlayer():GetNWString('nrp_rankid')] then
                return true
            end
            return false
        end 

        if isbool(perms) and perms then
            return true
        end
    end

    return false
end

function NextRP.Codes:OpenUI()
    local control = LocalPlayer():getJobTable().control
    if not GetPerms(control) then return end

    local CODES = NextRP.Config.Codes.States[control]

    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Управление кодами')
    frame:SetSize(400, 116 + math.Clamp((64 * #CODES - 64), 0, 320))
    frame:MakePopup()
    frame:ShowSettingsButton(false)
    frame:Center()

    local function putCode(CODE, INDEX)
        local panel = vgui.Create('PawsUI.Panel')
        panel:SetTall(60)

        panel:Stick(TOP, 2):On('Paint', function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, c'Background')

            draw.SimpleText(CODE.Title, 'font_sans_21', 15, 20, CODE.Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3, ColorAlpha(Color(255, 255, 255), alpha))
            draw.SimpleText(CODE.Description, 'font_sans_16', 15, 40, c'Text', TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3, ColorAlpha(Color(255, 255, 255), alpha))
        end)

        local selectBtn = vgui.Create('PawsUI.Button', panel)
        selectBtn:SetLabel(NextRPActiveCode == INDEX and 'Установлен' or 'Установить')
        selectBtn:SetSize(125, 35)
        selectBtn:SetPos(260, 60 * .5 - 35 * .5)

        function selectBtn:DoClick()
            netstream.Start('NextRP::RequestCodeChange', INDEX)

            frame:Remove()
        end

        return panel
    end

    local scrollbar = vgui.Create('PawsUI.ScrollPanel', frame)
    scrollbar:Dock(FILL)

    for k, v in pairs(CODES) do
        scrollbar:Add(putCode(v, k))
    end
end