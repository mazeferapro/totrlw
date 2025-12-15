local cfg = GMap.config
local aspectRatio = 16 / 9
local originalWidth, originalHeight = 1920, 1080
local scrw, scrh = ScrW(), ScrH()

local PANEL = {}

function PANEL:Init()
    self.currentPlanet = 1
    self.connections = {}

    self:SetSize(scrw, scrh)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.4)

    self.canvas = vgui.Create( 'gmap.canvas', self )
    self.canvas:Dock(FILL)
    self.canvas:SetMinMaxZoom(0.7, 2)
    self.canvas:SetZoomStep(0.1)
    self.canvas:EnableZoom(true)
    self.canvas:EnablePan(true)

    self:SetupPlanets()
    self:SetupConnections()
    self:CenterMap()

    self.logo = self:Add( 'gm.logo' )
    self.logo2 = self:Add( 'gm.logo2' )
    self.close = self:Add( 'gm.close' )

    surface.PlaySound( 'luna_ui/blip1.wav' )
end

function PANEL:SafetyRemove()
    if IsValid(self) then
        self:AlphaTo(0, 0.3, 0, function()
            self:Remove()
        end)
    end
end

function PANEL:OnKeyCodeReleased(key)
    if key == KEY_ESCAPE then
        if esc then
            esc.openMenu()
        end
        self:SafetyRemove()
        gui.HideGameUI()
    end
end

function PANEL:CenterMap()
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge

    for _, planet in ipairs(GALACTIC_MAP) do
        minX = math.min(minX, planet.xPos)
        minY = math.min(minY, planet.yPos)
        maxX = math.max(maxX, planet.xPos)
        maxY = math.max(maxY, planet.yPos)
    end

    local centerX = (minX + maxX) * 0.5
    local centerY = (minY + maxY) * 0.5

    self.canvas:SetCenter(centerX, centerY)

    local mapWidth = (maxX - minX) * 3
    local mapHeight = (maxY - minY) * 3
    local canvasWidth, canvasHeight = self.canvas:GetSize()
    local zoomX = canvasWidth / mapWidth
    local zoomY = canvasHeight / mapHeight
    local initialZoom = math.min(zoomX, zoomY) * 0.9

    self.canvas:SetZoom(initialZoom)
    
    self.canvas:SetMapBounds(minX - mapWidth / 6, minY - mapHeight / 6, maxX + mapWidth / 6, maxY + mapHeight / 6)
end

function PANEL:SetupPlanets()
    for index, planet in ipairs(GALACTIC_MAP) do
        local planetButton = self.canvas:Add('gmap.planet')
        planetButton.data = planet
        planetButton.xPos = planet.xPos
        planetButton.yPos = planet.yPos

        local statusInfo = GMap.Planets[index] and GMap.Planets[index].Status or nil

        planetButton.info.planet = planetButton
        planetButton.info.price = planet.price
        planetButton.info.status = statusInfo or planet.status
        planetButton.info.currentID = index

        planetButton.DoClick = function(s)
            self.currentPlanet = index
            hook.Run('GMap:PlanetSelected', index)

            -- surface.PlaySound('luna_galactic_warfare/ui_planetzoom.wav')
        end

        re.map[index] = planetButton
    end
end

local iconSize, margin = scale(32), scale(2.5)
local function drawMouseText( mat, text, x, y )
    local w, h = draw.SimpleText( text, 'gmap.2', x, y, cfg.colors.white, 2, 4 )
    draw.Image( x - w - iconSize, y - h - margin, iconSize, iconSize, mat, cfg.colors.white )
end

function PANEL:Paint(w, h)
    draw.NewRect(0, 0, w, h, cfg.colors.back)

    local scaledWidth, scaledHeight

    if w / h > aspectRatio then
        scaledHeight = h
        scaledWidth = h * aspectRatio
    else
        scaledWidth = w
        scaledHeight = w / aspectRatio
    end

    local x = (w - scaledWidth) * .5
    local y = (h - scaledHeight) * .5

    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)

    draw.Image(x, y, scaledWidth, scaledHeight, cfg.mats.back1, cfg.colors.white)
    draw.Image(x, y, scaledWidth, scaledHeight, cfg.mats.back2, cfg.colors.back4)

    -- for i = 1, 9 do
    --     draw.Image(x, y, scaledWidth, scaledHeight, cfg.mats['sector'.. i], i <= 3 and cfg.colors.back2 or (i <= 6 and cfg.colors.back3 or cfg.colors.back2))
    -- end

    draw.Image(x, y, scaledWidth, scaledHeight, cfg.mats.stripes, cfg.colors.white)
    draw.Image( x, y, scaledWidth, scaledHeight, cfg.mats.vignette, cfg.colors.vignette )

    render.PopFilterMag()
    render.PopFilterMin()

    self:DrawConnections()
    self.canvas:PaintManual()

    draw.SimpleText('Игровой сервер от SUP • developing team. STAR WARS™ является собственностью компании LucasFilm Ltd.', 'gm.1', w*.5, h - scale(40), cfg.colors.white_copyright, 1, 4)

    drawMouseText( cfg.mats.mouse1, 'Выбрать', w - scale(30), h - scale(30) )
    drawMouseText( cfg.mats.mouse2, 'Приблизить', w - scale(160), h - scale(30) )
end

function PANEL:OnMouseWheeled(delta)
    self.canvas:OnMouseWheeled(delta)
end

local function CalculateDistance(planet1, planet2)
    local dx = planet1.xPos - planet2.xPos
    local dy = planet1.yPos - planet2.yPos
    return math.sqrt(dx*dx + dy*dy)
end

local function FindNearestNeighbors(planet, allPlanets, numNeighbors)
    local distances = {}
    for i, otherPlanet in pairs(allPlanets) do
        if planet ~= otherPlanet then
            local distance = CalculateDistance(planet, otherPlanet)
            table.insert(distances, {index = i, distance = distance})
        end
    end
    table.sort(distances, function(a, b) return a.distance < b.distance end)
    local neighbors = {}
    for i = 1, math.min(numNeighbors, #distances) do
        table.insert(neighbors, distances[i].index)
    end
    return neighbors
end

local numNeighbors = 3
function PANEL:SetupConnections()
    for i, planet in pairs(GALACTIC_MAP) do
        local neighbors = FindNearestNeighbors(planet, GALACTIC_MAP, numNeighbors)
        for _, neighborIndex in ipairs(neighbors) do
            local neighbor = GALACTIC_MAP[neighborIndex]
            table.insert(self.connections, {
                start = { x = planet.xPos, y = planet.yPos },
                finish = { x = neighbor.xPos, y = neighbor.yPos }
            })
        end
    end
end

local color_lines = Color( 255, 255, 255, 30 )
function PANEL:DrawConnections()
    surface.SetDrawColor( color_lines )
    for _, connection in ipairs(self.connections) do
        local startX, startY = self.canvas:ToScreen(connection.start.x, connection.start.y)
        local finishX, finishY = self.canvas:ToScreen(connection.finish.x, connection.finish.y)
        surface.DrawLine(startX, startY, finishX, finishY)
    end
end

vgui.Register('gmap.frame', PANEL, 'EditablePanel')