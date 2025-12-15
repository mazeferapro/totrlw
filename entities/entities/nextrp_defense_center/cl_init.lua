-- gamemode/modules/autoevents/entities/nextrp_defense_center/cl_init.lua

include("shared.lua")

function ENT:Initialize()
    self:SetRenderBounds(Vector(-600, -600, -50), Vector(600, 600, 100))
end

function ENT:Draw()
    self:DrawModel()
    
    -- Отрисовка информации над энтити
    local pos = self:GetPos() + Vector(0, 0, 80)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        local status = self:GetActive() and "АКТИВЕН" or "НЕАКТИВЕН"
        local color = self:GetActive() and Color(0, 255, 0) or Color(255, 0, 0)
        
        draw.RoundedBox(4, -90, -25, 180, 50, Color(0, 0, 0, 200))
        draw.SimpleText("ЦЕНТР ОБОРОНЫ", "DermaDefaultBold", 0, -15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self:GetCenterName(), "DermaDefault", 0, 0, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(status, "DermaDefaultBold", 0, 15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
    
    -- Отрисовка зоны обороны
    if LocalPlayer():IsAdmin() or self:GetActive() then
        render.SetColorMaterial()
        local alpha = LocalPlayer():IsAdmin() and 50 or 20
        local wireAlpha = LocalPlayer():IsAdmin() and 150 or 80
        
        -- Проверяем, находится ли игрок в зоне
        local playerInZone = LocalPlayer():GetPos():Distance(self:GetPos()) <= self:GetDefenseRadius()
        local zoneColor = playerInZone and Color(0, 255, 0, alpha) or Color(255, 100, 100, alpha)
        local wireColor = playerInZone and Color(0, 255, 0, wireAlpha) or Color(255, 100, 100, wireAlpha)
        
        render.DrawSphere(self:GetPos(), self:GetDefenseRadius(), 20, 20, zoneColor)
        render.DrawWireframeSphere(self:GetPos(), self:GetDefenseRadius(), 20, 20, wireColor, true)
    end
end

-- Меню настройки
net.Receive("NextRP_DefenseCenter_OpenMenu", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Настройка центра обороны")
    frame:SetSize(420, 300)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(true)
    frame:SetDraggable(true)
    frame:SetSizable(false)
    
    -- Стилизация фрейма
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 240))
        draw.RoundedBox(4, 0, 0, w, 24, Color(60, 60, 60, 255))
        surface.SetDrawColor(100, 150, 200)
        surface.DrawRect(0, 24, w, 2)
    end
    
    -- Название центра
    local nameLabel = vgui.Create("DLabel", frame)
    nameLabel:SetText("Название центра:")
    nameLabel:SetPos(15, 40)
    nameLabel:SetSize(150, 20)
    nameLabel:SetTextColor(Color(255, 255, 255))
    
    local nameEntry = vgui.Create("DTextEntry", frame)
    nameEntry:SetText(ent:GetCenterName())
    nameEntry:SetPos(15, 65)
    nameEntry:SetSize(390, 25)
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
        draw.RoundedBox(4, 2, 2, w-4, h-4, Color(50, 50, 50, 255))
        self:DrawTextEntryText(Color(255, 255, 255), Color(100, 150, 200), Color(200, 200, 200))
    end
    
    -- Радиус обороны
    local radiusLabel = vgui.Create("DLabel", frame)
    radiusLabel:SetText("Радиус зоны обороны:")
    radiusLabel:SetPos(15, 100)
    radiusLabel:SetSize(200, 20)
    radiusLabel:SetTextColor(Color(255, 255, 255))
    
    local radiusSlider = vgui.Create("DNumSlider", frame)
    radiusSlider:SetPos(15, 120)
    radiusSlider:SetSize(390, 25)
    radiusSlider:SetMin(100)
    radiusSlider:SetMax(25000)
    radiusSlider:SetDecimals(0)
    radiusSlider:SetValue(ent:GetDefenseRadius())
    radiusSlider:SetText("Радиус")
    radiusSlider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 100))
    end
    
    -- Активность центра
    local activeCheck = vgui.Create("DCheckBoxLabel", frame)
    activeCheck:SetText("Активный центр обороны")
    activeCheck:SetPos(15, 155)
    activeCheck:SetSize(250, 20)
    activeCheck:SetTextColor(Color(255, 255, 255))
    activeCheck:SetChecked(ent:GetActive())
    
    -- Информация о расстоянии до игрока
    local distanceLabel = vgui.Create("DLabel", frame)
    local playerDistance = LocalPlayer():GetPos():Distance(ent:GetPos())
    local inZone = playerDistance <= ent:GetDefenseRadius()
    local statusText = inZone and "В ЗОНЕ" or "ВНЕ ЗОНЫ"
    local statusColor = inZone and Color(0, 255, 0) or Color(255, 100, 100)
    distanceLabel:SetText("Расстояние до вас: " .. math.floor(playerDistance) .. " ед. (" .. statusText .. ")")
    distanceLabel:SetPos(15, 185)
    distanceLabel:SetSize(390, 20)
    distanceLabel:SetTextColor(statusColor)
    
    -- Разделитель
    local divider = vgui.Create("DPanel", frame)
    divider:SetPos(15, 215)
    divider:SetSize(390, 1)
    divider.Paint = function(self, w, h)
        surface.SetDrawColor(100, 100, 100)
        surface.DrawRect(0, 0, w, h)
    end
    
    -- Кнопки
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetText("Сохранить")
    saveBtn:SetPos(15, 230)
    saveBtn:SetSize(90, 35)
    saveBtn:SetTextColor(Color(255, 255, 255))
    saveBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 120, 80) or Color(60, 100, 60)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    saveBtn.DoClick = function()
        net.Start("NextRP_DefenseCenter_Configure")
        net.WriteEntity(ent)
        net.WriteTable({
            name = nameEntry:GetText(),
            radius = radiusSlider:GetValue(),
            active = activeCheck:GetChecked(),
        })
        net.SendToServer()
        frame:Close()
        chat.AddText(Color(0, 255, 0), "[AutoEvents] ", Color(255, 255, 255), "Настройки центра обороны сохранены!")
    end
    
    local testBtn = vgui.Create("DButton", frame)
    testBtn:SetText("Тест зоны")
    testBtn:SetPos(115, 230)
    testBtn:SetSize(90, 35)
    testBtn:SetTextColor(Color(255, 255, 255))
    testBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(100, 120, 140) or Color(80, 100, 120)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    testBtn.DoClick = function()
        -- Показать временно зону для тестирования
        chat.AddText(Color(0, 255, 0), "[Центр обороны] ", Color(255, 255, 255), "Зона обороны отображается в течение 10 секунд")
        
        -- Временное отображение зоны для всех игроков
        timer.Simple(10, function()
            chat.AddText(Color(255, 165, 0), "[Центр обороны] ", Color(255, 255, 255), "Тестовый режим завершен")
        end)
    end
    
    local deleteBtn = vgui.Create("DButton", frame)
    deleteBtn:SetText("Удалить")
    deleteBtn:SetPos(215, 230)
    deleteBtn:SetSize(90, 35)
    deleteBtn:SetTextColor(Color(255, 255, 255))
    deleteBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(120, 60, 60) or Color(100, 40, 40)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    deleteBtn.DoClick = function()
        local confirmFrame = vgui.Create("DFrame")
        confirmFrame:SetTitle("Подтверждение")
        confirmFrame:SetSize(300, 150)
        confirmFrame:Center()
        confirmFrame:MakePopup()
        confirmFrame:ShowCloseButton(true)
        
        confirmFrame.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 240))
            draw.RoundedBox(4, 0, 0, w, 24, Color(60, 60, 60, 255))
        end
        
        local confirmLabel = vgui.Create("DLabel", confirmFrame)
        confirmLabel:SetText("Вы уверены что хотите удалить центр обороны?")
        confirmLabel:SetPos(20, 40)
        confirmLabel:SetSize(260, 20)
        confirmLabel:SetTextColor(Color(255, 255, 255))
        
        local yesBtn = vgui.Create("DButton", confirmFrame)
        yesBtn:SetText("Да")
        yesBtn:SetPos(50, 80)
        yesBtn:SetSize(80, 30)
        yesBtn:SetTextColor(Color(255, 255, 255))
        yesBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(120, 60, 60) or Color(100, 40, 40)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        yesBtn.DoClick = function()
            net.Start("NextRP_DefenseCenter_Delete")
            net.WriteEntity(ent)
            net.SendToServer()
            confirmFrame:Close()
            frame:Close()
            chat.AddText(Color(255, 100, 100), "[AutoEvents] ", Color(255, 255, 255), "Центр обороны удален!")
        end
        
        local noBtn = vgui.Create("DButton", confirmFrame)
        noBtn:SetText("Нет")
        noBtn:SetPos(170, 80)
        noBtn:SetSize(80, 30)
        noBtn:SetTextColor(Color(255, 255, 255))
        noBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(80, 80, 80) or Color(60, 60, 60)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        noBtn.DoClick = function()
            confirmFrame:Close()
        end
    end
    
    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetText("Отмена")
    cancelBtn:SetPos(315, 230)
    cancelBtn:SetSize(90, 35)
    cancelBtn:SetTextColor(Color(255, 255, 255))
    cancelBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 80, 80) or Color(60, 60, 60)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    cancelBtn.DoClick = function()
        frame:Close()
    end
end)