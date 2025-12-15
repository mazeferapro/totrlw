local cfg = GMap.config

local PANEL = {}

function PANEL:Init()
    self:SetSize( scale(100), scale(130) )
    self:SetText''

    self.rotationAngle = 0
    self.rotationSpeed = 0.1

    self.targetRotationSpeed = 0
    self.lastHoverTime = 0
    self.hoverDuration = 1

    local canvas = self:GetParent()
    self.info = canvas:Add( 'gmap.planetInfo' )
end

function PANEL:Think()
    local canvas = self:GetParent()
    local x, y = canvas:ToScreen(self.xPos, self.yPos)

    self:SetPos(x - self:GetWide() * 0.5, y - self:GetTall() * 0.5)
    self.info:SetPos(x + self:GetWide() * 0.5 + 5, y - self.info:GetTall() * 0.5)

    local currentTime = SysTime()
    local dt = FrameTime()

    if self:IsHovered() then
        self.targetRotationSpeed = 0.1
        self.lastHoverTime = currentTime
    else
        local timeSinceHover = currentTime - self.lastHoverTime
        if timeSinceHover < self.hoverDuration then
            local t = timeSinceHover / self.hoverDuration
            self.targetRotationSpeed = Lerp(t, 0.1, 0)
        else
            self.targetRotationSpeed = 0
        end
    end

    self.rotationSpeed = Lerp(dt * 10, self.rotationSpeed, self.targetRotationSpeed)
    self.rotationAngle = self.rotationAngle + self.rotationSpeed

    if self.rotationAngle >= 360 then
        self.rotationAngle = self.rotationAngle - 360
    end
end

local planetSize = scale(80)
local planetImageSize = planetSize - scale(20)
function PANEL:Paint( w, h )
    if not self.data then return end

    draw.Image( w*.5 - planetSize*.5, h*.5 - planetSize*.5, planetSize, planetSize, cfg.mats.planetBack, cfg.colors.main_back )

    --[[
        if self:IsHovered() then
            self.rotationAngle = self.rotationAngle + self.rotationSpeed
            if self.rotationAngle >= 360 then
                self.rotationAngle = self.rotationAngle - 360
            end
        end
    --]]

    surface.SetDrawColor( cfg.planet_color[self.data.team] or cfg.colors.white )
    surface.SetMaterial( cfg.mats.planetElement )
    surface.DrawTexturedRectRotated( w*.5, h*.5, planetSize, planetSize, self.rotationAngle )

    if self.data.icon and self.data.icon != '' then
        draw.Image( w*.5 - planetImageSize*.5, h*.5 - planetImageSize*.5, planetImageSize, planetImageSize, self.data.icon, cfg.colors.white)
    end

    draw.SimpleText( self.data.name, 'gmap.7', w*.5, h - scale(1), cfg.colors.white, 1, 4 )

    return true
end

vgui.Register( 'gmap.planet', PANEL, 'DButton' )