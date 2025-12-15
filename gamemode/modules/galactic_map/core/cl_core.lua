local cfg = GMap.config
net.Receive('GMap:SyncAllPlayers', function(_)
    local tbl = net.ReadTable()
    GMap.Planets = tbl
end)

local margin = scale(15)
local lineMargin = scale(50)
local headerHeight = scale(50)
local lineHeight = scale(1)
local progressBarHeight = scale(20)
local barHeight = progressBarHeight
local barY = scale(45)
local fr
function GMap:Menu()
    local warInfo = GMap.Planets
    local republicPlanets, cisPlanets = CountCapturedPlanets()
    local totalPlanets = republicPlanets + cisPlanets
    local tickets = string.Comma(GetTickets()) .. 'Т'
    fr = vgui.Create('gmap.frame')
    local frW, frH = fr:GetSize()
    local panel_left = fr:Add('Panel')
    panel_left:SetSize(scale(300), frH - scale(260))
    panel_left:CenterVertical()
    panel_left:SetX(scale(30))
    local panel_right = fr:Add('Panel')
    panel_right:SetSize(scale(300), frH - scale(430))
    panel_right:CenterVertical()
    panel_right:SetX(frW - panel_right:GetWide() - scale(30))
    local pW = panel_left:GetWide()
    local cloneWar = panel_left:Add('Panel')
    cloneWar:SetSize(pW, scale(200))
    cloneWar.Paint = function(_, w, h)
        draw.Blur(_, 3)
        draw.NewRect(0, 0, w, h, cfg.colors.main_back)
        draw.SimpleText('ВОЙНА КЛОНОВ', 'gmap.1', scale(10), scale(5), cfg.colors.white, 0, 3)
        local barWidth = w - scale(20)
        draw.NewRect(scale(10), barY, barWidth, barHeight, cfg.colors.main_back)
        if totalPlanets > 0 then
            local cisWidth = math.floor(cisPlanets / totalPlanets * barWidth)
            draw.NewRect(scale(10), barY, cisWidth, barHeight, cfg.colors.red)
            local republicWidth = barWidth - cisWidth
            draw.NewRect(scale(10) + cisWidth, barY, republicWidth - margin, barHeight, cfg.colors.blue)
            draw.NewRect(scale(10) + cisWidth, barY, scale(2), barHeight, cfg.colors.white)
        end

        draw.SimpleText('Планет сектора: ' .. table.Count(GALACTIC_MAP), 'gmap.2', scale(10), scale(75), cfg.colors.white, 0, 3)
        draw.markupText({
            text = {
                {
                    text = 'Сепаратисты: ',
                    font = 'gmap.2',
                    color = {
                        r = 255,
                        g = 255,
                        b = 255
                    }
                },
                {
                    text = cisPlanets,
                    font = 'gmap.2',
                    color = {
                        r = 255,
                        g = 0,
                        b = 0
                    }
                }
            },
            x = scale(10),
            y = scale(105),
            alignX = 0,
            alignY = 3
        })

        draw.markupText({
            text = {
                {
                    text = 'Республика: ',
                    font = 'gmap.2',
                    color = {
                        r = 255,
                        g = 255,
                        b = 255
                    }
                },
                {
                    text = republicPlanets,
                    font = 'gmap.2',
                    color = {
                        r = 30,
                        g = 97,
                        b = 220
                    }
                }
            },
            x = scale(10),
            y = scale(135),
            alignX = 0,
            alignY = 3
        })

        draw.markupText({
            text = {
                {
                    text = 'Тикетов: ',
                    font = 'gmap.2',
                    color = {
                        r = 255,
                        g = 255,
                        b = 255
                    }
                },
                {
                    text = tickets,
                    font = 'gmap.2',
                    color = {
                        r = 255,
                        g = 215,
                        b = 0
                    }
                }
            },
            x = scale(10),
            y = scale(165),
            alignX = 0,
            alignY = 3
        })
    end

    local infoPanel = panel_left:Add('Panel')
    infoPanel:SetSize(pW, panel_left:GetTall() - cloneWar:GetTall() - margin)
    infoPanel:SetY(cloneWar:GetTall() + margin)
    infoPanel.Paint = function(_, w, h)
        draw.Blur(_, 3)
        draw.NewRect(0, 0, w, h, cfg.colors.main_back)
        draw.SimpleText('ИНФОРМАЦИЯ', 'gmap.1', w * 0.5, scale(10), cfg.colors.white, 1, 3)
        local lineY = headerHeight
        draw.NewRect(lineMargin, lineY, w - lineMargin * 2, lineHeight, cfg.colors.white)
        local planetName = GALACTIC_MAP[fr.currentPlanet].name
        local nameY = lineY + margin
        draw.SimpleText('«ПЛАНЕТА ' .. utf8.upper(planetName) .. '»', 'gmap.3', w * 0.5, nameY, cfg.colors.blue, 1, 3)
        lineY = fr.descInfo:GetY() + fr.descInfo:GetTall() + margin
        draw.NewRect(lineMargin, lineY, w - lineMargin * 2, lineHeight, cfg.colors.white)
        local warInfoY = lineY + margin
        draw.SimpleText('«ВОЕННАЯ ИНФОРМАЦИЯ»', 'gmap.3', w * 0.5, warInfoY, cfg.colors.blue, 1, 3)
        lineY = fr.orderPanel:GetY() + fr.orderPanel:GetTall() + margin * 2
        draw.NewRect(lineMargin, lineY, w - lineMargin * 2, lineHeight, cfg.colors.white)
        local progressY = lineY + margin
        draw.SimpleText('«ТЕКУЩИЙ ПРОГРЕСС»', 'gmap.3', w * 0.5, progressY, cfg.colors.blue, 1, 3)
        local progressBarY = progressY + margin * 2
        local progressBarWidth = w - lineMargin * 2
        local fillWidth = math.Clamp(progressBarWidth * _.firstProgress / _.secondProgress, 0, progressBarWidth)
        draw.NewRect(lineMargin, progressBarY, w - lineMargin * 2, progressBarHeight, cfg.colors.main_back)
        draw.NewRect(lineMargin, progressBarY, fillWidth, progressBarHeight, cfg.colors.red)
        draw.SimpleText(_.firstProgress .. ' / ' .. _.secondProgress, 'gmap.5', w * 0.5, progressBarY + progressBarHeight * 3.5, cfg.colors.white, 1, 1)
    end

    fr.descInfo = infoPanel:Add('gmap.wrap-text')
    fr.descInfo:SetSize(infoPanel:GetWide() - scale(60), scale(60))
    local warnInfo = infoPanel:Add('gmap.wrap-text')
    warnInfo:SetSize(infoPanel:GetWide() - scale(60), scale(60))
    fr.orderPanel = infoPanel:Add('Panel')
    fr.orderPanel:SetSize(infoPanel:GetWide() - scale(60), scale(120))
    local prW = panel_right:GetWide()
    local orderWar = panel_right:Add('Panel')
    orderWar:SetSize(pW, scale(310))
    orderWar.Paint = function(_, w, h)
        draw.Blur(_, 3)
        draw.NewRect(0, 0, w, h, cfg.colors.main_back)
        draw.SimpleText('ПРИКАЗ ШТАБА', 'gmap.1', w * 0.5, scale(10), cfg.colors.white, 1, 3)
        local lineY = headerHeight
        draw.NewRect(lineMargin, lineY, w - lineMargin * 2, lineHeight, cfg.colors.white)
        local nameY = lineY + margin
        local headerDesc = warInfo and warInfo.HeaderDescription and '«' .. warInfo.HeaderDescription .. '»' or ''
        draw.SimpleText(headerDesc, 'gmap.3', w * 0.5, nameY, cfg.colors.blue, 1, 3)
        draw.Image(w * .5 - scale(100) * .5, nameY + fr.warDesc:GetTall() + scale(40), scale(100), scale(100), cfg.mats.war1, cfg.colors.red)
    end

    fr.warDesc = orderWar:Add('gmap.wrap-text')
    fr.warDesc:SetSize(orderWar:GetWide() - scale(60), scale(90))
    local companyInfo = panel_right:Add('Panel')
    companyInfo:SetSize(prW, panel_right:GetTall() - orderWar:GetTall() - margin)
    companyInfo:SetY(orderWar:GetTall() + margin)
    companyInfo.Paint = function(_, w, h)
        draw.Blur(_, 3)
        draw.NewRect(0, 0, w, h, cfg.colors.main_back)
        draw.SimpleText('ТЕКУЩАЯ КОМПАНИЯ', 'gmap.1', w * 0.5, scale(10), cfg.colors.white, 1, 3)
        local lineY = headerHeight
        draw.NewRect(lineMargin, lineY, w - lineMargin * 2, lineHeight, cfg.colors.white)
        local nameY = lineY + margin
        local warInfo = GMap.Planets
        local headerWarCompany = warInfo and warInfo.HeaderWarCompany and '«' .. utf8.upper(warInfo.HeaderWarCompany) .. '»' or ''
        draw.SimpleText(headerWarCompany, 'gmap.3', w * 0.5, nameY, cfg.colors.blue, 1, 3)
        draw.Image(w * .5 - scale(100) * .5, nameY + fr.companyDesc:GetTall() + scale(40), scale(100), scale(100), cfg.mats.war2, cfg.colors.red)
    end

    fr.companyDesc = companyInfo:Add('gmap.wrap-text')
    fr.companyDesc:SetSize(companyInfo:GetWide() - scale(60), scale(90))
    local function UpdateElementPositions()
        local margin = scale(20)
        local currentX, currentY = scale(30), scale(100)
        fr.descInfo:SetPos(currentX, currentY)
        fr.warDesc:SetPos(currentX, currentY)
        fr.companyDesc:SetPos(currentX, currentY)
        currentY = currentY + fr.descInfo:GetTall() + margin
        warnInfo:SetPos(currentX, currentY + scale(40))
        currentY = currentY + warnInfo:GetTall() + margin
        fr.orderPanel:SetPos(currentX, currentY)
    end

    local function UpdatePlanetInfo(planetIndex)
        local planetInfo = GALACTIC_MAP[planetIndex]
        fr.descInfo:SetText(planetInfo.desc.info)
        warnInfo:SetText('Для того, чтобы взять под контроль планету «' .. planetInfo.name .. '», нужно:')
        if warInfo and warInfo.OrderDescription then
            fr.warDesc:SetText(warInfo.OrderDescription)
            fr.companyDesc:SetText(warInfo.WarCompanyDesc)
        end

        fr.orderPanel:Clear()
        local tableInfo = GMap.Planets[planetIndex]
        local orderInfo = tableInfo and tableInfo.WarInfo or {}
        local completeInfo = tableInfo and tableInfo.Completed or {}
        local firstProgress, secondProgress = tableInfo and tableInfo.firstProgress or 0, tableInfo and tableInfo.secondProgress or 0
        infoPanel.firstProgress, infoPanel.secondProgress = firstProgress, secondProgress
        for i, order in ipairs(orderInfo) do
            local item = fr.orderPanel:Add('Panel')
            item:Dock(TOP)
            item:SetTall(scale(30))
            item.Paint = function(self, w, h) draw.SimpleText(order, completeInfo[i] and 'gmap.2_underline' or 'gmap.2', w * 0.5, h * 0.5, cfg.colors.white, 1, 1) end
        end

        fr.orderPanel:SetTall(#orderInfo * scale(30))
        UpdateElementPositions()
        infoPanel:InvalidateLayout(true)
    end

    UpdatePlanetInfo(1)
    hook.Add('GMap:PlanetSelected', 'UpdatePlanetInfo', function(planetIndex) UpdatePlanetInfo(planetIndex) end)
end

net.Receive('GMap:Menu', function()
    if IsValid(fr) then return end
    GMap:Menu()
end)