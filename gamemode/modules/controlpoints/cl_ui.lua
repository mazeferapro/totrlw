local function AdminMenu(ent)
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Настройка')
    frame:SetSize(400, 300)
    frame:MakePopup()
    frame:ShowSettingsButton(false)
    frame:Center()
    local save = vgui.Create('PawsUI.Button', frame)

    save:Stick(BOTTOM, 4):On('DoClick', function()
        frame:Remove()
    end)

    save:SetLabel('Сохранить')
    local radius = vgui.Create('DNumSlider', frame)
    radius:SetPos(50, 50)
    radius:SetSize(300, 100)
    radius:SetText('Радиус')
    radius:SetMin(50)
    radius:SetMax(400)
    radius:SetDecimals(0)
    radius:SetDefaultValue(100)
    radius:SetValue(ent:GetRadius())
    local name = vgui.Create('PawsUI.Button', frame)
    name:SetPos(50, 150)
    name:SetSize(300, 25)

    function name:DoClick()
        NextRP:QuerryText(QUERY_MAT_QUESTION, c'Accent', 'Введите название точки', ent:GetTitle(), nil, function(sValue)
            name.Data = sValue
        end, nil, nil)
    end

    name:SetLabel('Изменить название')
    local description = vgui.Create('PawsUI.Button', frame)
    description:SetPos(50, 180)
    description:SetSize(300, 25)

    function description:DoClick()
        NextRP:QuerryText(QUERY_MAT_QUESTION, c'Accent', 'Введите название точки', ent:GetDescription(), nil, function(sValue)
            description.Data = sValue
        end, nil, nil)
    end

    description:SetLabel('Изменить описание')

    function radius:OnValueChanged(nValue)
        self.Data = nValue
    end

    function frame:OnRemove()
        hook.Remove('CalcView', 'CP_CalcView')
        hook.Remove('PostDrawTranslucentRenderables', 'CP_Sphere')
        netstream.Start('NextRP::ControlPointSendConfigs', ent, radius.Data or ent:GetRadius(), name.Data or ent:GetTitle(), description.Data or ent:GetDescription())
    end

    hook.Add('CalcView', 'CP_CalcView', function(pPlayer, vPos, aAngles, nFov)
        local ang = (ent:GetPos() - (ent:GetPos() - Vector(150, 150, -500))):Angle()

        local view = {
            origin = ent:GetPos() - Vector(150, 150, -500),
            angles = ang,
            fov = nFov,
            drawviewer = false
        }

        return view
    end)

    hook.Add('PostDrawTranslucentRenderables', 'CP_Sphere', function()
        render.SetColorMaterial()
        local pos = ent:GetPos()
        local radius = radius:GetValue()
        local wideSteps = 10
        local tallSteps = 10
        render.DrawSphere(pos, radius, wideSteps, tallSteps, ColorAlpha(c'Green', 50))
    end)
end

netstream.Hook('NextRP::OpenCPAdmin', function(eCP)
    AdminMenu(eCP)
end)

function NextRP.ControlPoints:OpenCPList()
    local points = ents.FindByClass('nextrp_controlpoint')
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Точки интереса')
    frame:SetSize(400, 116 + math.Clamp((64 * #points - 64), 0, 320))
    frame:MakePopup()
    frame:ShowSettingsButton(false)
    frame:Center()

    local function putPoint(ent)
        local curCol = NextRP.Config.ControlsColors[ent:GetControl()] or c'Accent'

        local panel = vgui.Create('PawsUI.Panel')
        panel:SetTall(60)

        panel:Stick(TOP, 2):On('Paint', function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, c'Background')
            local control = ent:GetControl()
            local col = NextRP.Config.ControlsColors[control] or c'Accent'

            if curCol ~= col then
                curCol = PawsUI:LerpColor(FrameTime() * 3, curCol, col)
            end

            draw.NoTexture()

            for i = 1, 8 do
                draw.Arc(50, 30, 20, 17, i * 45, i * 45 + 45, 8, c'AlphaWhite')
            end

            for i = 1, 8 do
                if i > ent:GetPoints() then break end
                draw.Arc(50, 30, 20, 17, i * 45 + 45, i * 45 + 90, 8, curCol)
            end

            if control ~= -1 then
                surface.SetMaterial(NextRP.Config.ControlsMaterials[control])
                surface.SetDrawColor(color_white) 
                surface.DrawTexturedRect(34, 14, 32, 32)
            end

            draw.SimpleText(ent:GetTitle(), 'font_sans_21', 80, 20, ColorAlpha(curCol, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3, ColorAlpha(Color(255, 255, 255), alpha))
            draw.SimpleText(ent:GetDescription(), 'font_sans_16', 80, 40, ColorAlpha(color_white, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3, ColorAlpha(Color(255, 255, 255), alpha))
        end)

        return panel
    end

    local scrollbar = vgui.Create('PawsUI.ScrollPanel', frame)
    scrollbar:Dock(FILL)

    for k, v in pairs(points) do
        scrollbar:Add(putPoint(v))
    end
end

NextRPControlPanels = NextRPControlPanels or {}

netstream.Hook('NextRP::FindInPoint', function(ent)
    if IsValid(NextRPControlPanels[ent]) then return end
    if not IsValid(ent) then return end
    local curCol = NextRP.Config.ControlsColors[ent:GetControl()] or c'Accent'

    if IsValid(NextRPControlPanels[ent]) then
        NextRPControlPanels[ent]:Remove()
    end

    NextRPControlPanels[ent] = vgui.Create('DPanel')
    NextRPControlPanels[ent].number = table.Count(NextRPControlPanels) - 1
    NextRPControlPanels[ent]:SetPos(-307, 150 + (103 * NextRPControlPanels[ent].number))
    NextRPControlPanels[ent]:SetSize(307, 100)
    local panel = NextRPControlPanels[ent]

    function panel:Gone()
        if not IsValid(NextRPControlPanels[ent]) then return end        
        if self.iamhere then return end

        self.iamhere = true

        self:MoveTo(-307, 150 + (103 * NextRPControlPanels[ent].number), .5, nil, nil, function()
            NextRPControlPanels[ent]:Remove()
            NextRPControlPanels[ent] = nil

            self.iamhere = false
        end)
    end

    function panel:Think()
        if not IsValid(ent) then self:Remove() return end
        if LocalPlayer():GetPos():Distance(ent:GetPos()) > ent:GetRadius() then self:Gone() end
    end

    function panel:Paint(w, h)
        if not IsValid(ent) then self:Remove() return end

        local control = ent:GetControl()
        local col = NextRP.Config.ControlsColors[control] or c'Accent'

        if curCol ~= col then
            curCol = PawsUI:LerpColor(FrameTime() * 3, curCol, col)
        end

        draw.RoundedBox(0, 0, 0, 300, 100, c'Background')
        draw.RoundedBoxEx(5, 300, 0, 7, 100, curCol, false, true, false, true)
        draw.NoTexture()

        for i = 1, 8 do
            draw.Arc(30, 50, 20, 17, i * 45, i * 45 + 45, 8, c'Background')
        end

        for i = 1, 8 do
            if i > ent:GetPoints() then break end
            draw.Arc(30, 50, 20, 17, i * 45 + 45, i * 45 + 90, 8, curCol)
        end

        if control ~= -1 then
            surface.SetMaterial(NextRP.Config.ControlsMaterials[control])
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(14, 34, 32, 32)
        end

        draw.SimpleText(ent:GetTitle(), 'font_sans_21', 60, 40, ColorAlpha(curCol, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3, ColorAlpha(Color(255, 255, 255), alpha))
        draw.SimpleText(ent:GetDescription(), 'font_sans_16', 60, 60, ColorAlpha(color_white, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 3, ColorAlpha(Color(255, 255, 255), alpha))
    end

    panel:MoveTo(0, 150 + (103 * NextRPControlPanels[ent].number), .5)
end)

netstream.Hook('NextRP::RemoveAllControlPoints', function()
    for k, v in pairs(NextRPControlPanels) do
        if not IsValid(v) or not ispanel(v) then
            NextRPControlPanels[k] = nil
            continue
        end

        v:MoveTo(-307, 150 + (103 * v.number), .1, nil, nil, function()
            v:Remove()
            NextRPControlPanels[k] = v
        end)
    end
end)