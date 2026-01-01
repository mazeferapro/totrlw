include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    local itemID = self:GetItemID()
    if not itemID or itemID == "" then return end
    
    local itemData = NextRP.Inventory:GetItemData(itemID)
    if not itemData then return end
    
    local pos = self:GetPos() + Vector(0, 0, 20)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    if dist > 300 then return end
    
    local alpha = math.Clamp(255 - (dist - 100) * 2, 50, 255)
    
    cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.1)
        local w, h = 300, 80
        
        -- Фон
        draw.RoundedBox(8, -w/2, -h/2, w, h, Color(30, 30, 30, alpha * 0.9))
        
        -- Рамка редкости
        local rarityColor = NextRP.Inventory:GetRarityColor(itemData.rarity)
        surface.SetDrawColor(ColorAlpha(rarityColor, alpha))
        surface.DrawOutlinedRect(-w/2, -h/2, w, h, 2)
        
        -- Название
        draw.SimpleText(itemData.name, "PawsUI.Text.Normal", 0, -15, ColorAlpha(rarityColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Количество
        local amount = self:GetItemAmount()
        if amount > 1 then
            draw.SimpleText("x" .. amount, "PawsUI.Text.Small", 0, 15, ColorAlpha(color_white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Подсказка
        draw.SimpleText("[E] Подобрать", "PawsUI.Text.Small", 0, 25, ColorAlpha(Color(200, 200, 200), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:Think()
end