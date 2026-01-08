include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos() + self:GetUp() * 75
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    if dist > 300 then return end
    
    local alpha = math.Clamp(255 - (dist - 100) * 2, 50, 255)
    
    cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.08)
        local w, h = 400, 80
        
        -- Фон
        draw.RoundedBox(8, -w/2, -h/2, w, h, Color(30, 40, 50, alpha * 0.9))
        
        -- Рамка
        surface.SetDrawColor(ColorAlpha(NextRP.Style.Theme.Accent, alpha))
        surface.DrawOutlinedRect(-w/2, -h/2, w, h, 2)
        
        -- Заголовок
        draw.SimpleText("Личное хранилище", "PawsUI.Text.Normal", 0, -15, ColorAlpha(NextRP.Style.Theme.Accent, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Подсказка
        draw.SimpleText("[E] Открыть", "PawsUI.Text.Small", 0, 15, ColorAlpha(Color(200, 200, 200), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

netstream.Hook("NextRP::OpenStorage", function()
    NextRP.Inventory:OpenUI(true)
end)