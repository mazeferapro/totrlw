local PANEL = {}

local Vector = Vector
if VECTOR_OVERRIDE then
    Vector = VECTOR_OVERRIDE
end

function PANEL:Init()
    self.center = Vector(0, 0)
    self.zoom = 1
    self.targetZoom = 1
    self.enableZoom = true
    self.enablePan = true

    self.dragging = false
    self.dragStart = Vector(0, 0)
    self.velocity = Vector(0, 0)

    self.hooks = {}

    self.smoothZoomSpeed = 10
    self.smoothPanSpeed = 60

    self:SetPaintBackgroundEnabled(false)

    self.minZoom = 0.01
    self.maxZoom = 1
    self.zoomStep = 0.1

    self.mapBounds = {
        minX = math.huge,
        minY = math.huge,
        maxX = -math.huge,
        maxY = -math.huge
    }
    self.padding = 300 -- отступ от края карты в пикселях
end

function PANEL:SetZoomStep(zoomStep)
    self.zoomStep = zoomStep
end

function PANEL:SetMinMaxZoom(minZoom, maxZoom)
    self.minZoom = minZoom
    self.maxZoom = maxZoom
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT and self.enablePan then
        self.dragging = true
        self.dragStart = Vector(gui.MouseX(), gui.MouseY())
        self.velocity = Vector(0, 0)
    end
end

function PANEL:OnMouseReleased(mouseCode)
    if mouseCode == MOUSE_LEFT then
        self.dragging = false
    end
end

function PANEL:OnMouseWheeled(delta)
    if self.enableZoom then
        local zoomDelta = self.zoomStep * delta
        self.targetZoom = math.Clamp(self.targetZoom - zoomDelta, self.minZoom, self.maxZoom)
    end
end

function PANEL:GetCenter()
    return self.center.x, self.center.y
end

function PANEL:SetCenter(gbX, gbY)
    self.center = Vector(gbX, gbY)
end

function PANEL:ToScreen(gbX, gbY)
    if not gbX or not gbY then
        return 0, 0
    end
    local x = (gbX - self.center.x) * self.zoom + self:GetWide() / 2
    local y = (gbY - self.center.y) * self.zoom + self:GetTall() / 2
    return x, y
end

function PANEL:ToAbsolute(loX, loY)
    local x = (loX - self:GetWide() / 2) / self.zoom + self.center.x
    local y = (loY - self:GetTall() / 2) / self.zoom + self.center.y
    return x, y
end

function PANEL:SetZoom(zoom)
    self.targetZoom = math.Clamp(zoom, self.minZoom, self.maxZoom)
end

function PANEL:GetZoom()
    return self.zoom
end

function PANEL:EnableZoom(enable)
    self.enableZoom = enable
end

function PANEL:EnablePan(enable)
    self.enablePan = enable
end

function PANEL:GetBounds()
    local w, h = self:GetSize()
    local tlx, tly = self:ToAbsolute(0, 0)
    local brx, bry = self:ToAbsolute(w, h)
    return Vector(tlx, tly), Vector(brx, bry)
end

function PANEL:SetMapBounds(minX, minY, maxX, maxY)
    self.mapBounds.minX = minX
    self.mapBounds.minY = minY
    self.mapBounds.maxX = maxX
    self.mapBounds.maxY = maxY
end

function PANEL:ClampCenter()
    local w, h = self:GetSize()
    local visibleWidth = w / self.zoom
    local visibleHeight = h / self.zoom

    local minX = self.mapBounds.minX + visibleWidth / 2 - self.padding / self.zoom
    local maxX = self.mapBounds.maxX - visibleWidth / 2 + self.padding / self.zoom
    local minY = self.mapBounds.minY + visibleHeight / 2 - self.padding / self.zoom
    local maxY = self.mapBounds.maxY - visibleHeight / 2 + self.padding / self.zoom

    self.center.x = math.Clamp(self.center.x, minX, maxX)
    self.center.y = math.Clamp(self.center.y, minY, maxY)
end

function PANEL:Think()
    local zoomDelta = self.targetZoom - self.zoom
    if math.abs(zoomDelta) > 0.001 then
        self.zoom = self.zoom + zoomDelta * FrameTime() * self.smoothZoomSpeed
    else
        self.zoom = self.targetZoom
    end

    if self.dragging then
        local mousePos = Vector(gui.MouseX(), gui.MouseY())
        local dragDelta = mousePos - self.dragStart
        local panDelta = dragDelta / self.zoom
        self.center = self.center - panDelta
        self.dragStart = mousePos

        self.velocity = self.velocity * 0.8 + dragDelta * FrameTime() * self.smoothPanSpeed
    else
        local panDelta = self.velocity / self.zoom
        self.center = self.center - panDelta

        self.velocity = self.velocity * 0.95
    end

    self:ClampCenter()
end

vgui.Register('gmap.canvas', PANEL, 'EditablePanel')