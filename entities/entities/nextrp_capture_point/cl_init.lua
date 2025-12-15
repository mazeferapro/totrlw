-- gamemode/modules/autoevents/entities/nextrp_capture_point/cl_init.lua

include("shared.lua")

function ENT:Initialize()
    self:SetRenderBounds(Vector(-150, -150, -50), Vector(150, 150, 100))
end

function ENT:Draw()
    self:DrawModel()
    
    -- Отрисовка информации над энтити
    local pos = self:GetPos() + Vector(0, 0, 80)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        local status = "НЕАКТИВНА"
        local color = Color(255, 0, 0)
        
        if self:GetCaptured() then
            status = "ЗАХВАЧЕНА"
            color = Color(0, 255, 0)
        elseif self:GetActive() then
            status = "АКТИВНА"
            color = Color(255, 165, 0)
        end
        
        draw.RoundedBox(4, -80, -25, 160, 50, Color(0, 0, 0, 200))
        draw.SimpleText("ТОЧКА ЗАХВАТА", "DermaDefaultBold", 0, -15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self:GetPointName(), "DermaDefault", 0, 0, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(status, "DermaDefaultBold", 0, 15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Прогресс захвата
        if self:GetActive() and not self:GetCaptured() then
            local progress = self:GetCaptureProgress()
            if progress > 0 then
                draw.RoundedBox(2, -60, 25, 120, 8, Color(100, 100, 100))
                draw.RoundedBox(2, -60, 25, 120 * (progress / 100), 8, Color(0, 255, 0))
                draw.SimpleText(math.floor(progress) .. "%", "DermaDefault", 0, 29, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    cam.End3D2D()
    
    -- Отрисовка зоны захвата для админов
    if LocalPlayer():IsAdmin() and self:GetActive() then
        render.SetColorMaterial()
        local color = self:GetCaptured() and Color(0, 255, 0, 30) or Color(255, 165, 0, 30)
        render.DrawSphere(self:GetPos(), self:GetCaptureRadius(), 15, 15, color)
        render.DrawWireframeSphere(self:GetPos(), self:GetCaptureRadius(), 15, 15, Color(color.r, color.g, color.b, 100), true)
    end
end

-- Меню настройки
net.Receive("NextRP_CapturePoint_OpenMenu", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Настройка точки захвата")
    frame:SetSize(400, 320)
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
    
    -- Название точки
    local nameLabel = vgui.Create("DLabel", frame)
    nameLabel:SetText("Название точки:")
    nameLabel:SetPos(15, 40)
    nameLabel:SetSize(150, 20)
    nameLabel:SetTextColor(Color(255, 255, 255))
    
    local nameEntry = vgui.Create("DTextEntry", frame)
    nameEntry:SetText(ent:GetPointName())
    nameEntry:SetPos(15, 65)
    nameEntry:SetSize(370, 25)
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
        draw.RoundedBox(4, 2, 2, w-4, h-4, Color(50, 50, 50, 255))
        self:DrawTextEntryText(Color(255, 255, 255), Color(100, 150, 200), Color(200, 200, 200))
    end
    
    -- Радиус захвата
    local radiusLabel = vgui.Create("DLabel", frame)
    radiusLabel:SetText("Радиус захвата:")
    radiusLabel:SetPos(15, 100)
    radiusLabel:SetSize(150, 20)
    radiusLabel:SetTextColor(Color(255, 255, 255))
    
    local radiusSlider = vgui.Create("DNumSlider", frame)
    radiusSlider:SetPos(15, 120)
    radiusSlider:SetSize(370, 25)
    radiusSlider:SetMin(50)
    radiusSlider:SetMax(300)
    radiusSlider:SetDecimals(0)
    radiusSlider:SetValue(ent:GetCaptureRadius())
    radiusSlider:SetText("Радиус")
    radiusSlider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 100))
    end
    
    -- Активность точки
    local activeCheck = vgui.Create("DCheckBoxLabel", frame)
    activeCheck:SetText("Активная точка")
    activeCheck:SetPos(15, 155)
    activeCheck:SetSize(200, 20)
    activeCheck:SetTextColor(Color(255, 255, 255))
    activeCheck:SetChecked(ent:GetActive())
    
    -- Информация о прогрессе
    local infoLabel = vgui.Create("DLabel", frame)
    local progress = math.floor(ent:GetCaptureProgress())
    local status = ent:GetCaptured() and "Захвачена" or "Не захвачена"
    infoLabel:SetText("Прогресс: " .. progress .. "% | Статус: " .. status)
    infoLabel:SetPos(15, 185)
    infoLabel:SetSize(370, 20)
    infoLabel:SetTextColor(Color(200, 200, 200))
    
    -- Разделитель
    local divider = vgui.Create("DPanel", frame)
    divider:SetPos(15, 215)
    divider:SetSize(370, 1)
    divider.Paint = function(self, w, h)
        surface.SetDrawColor(100, 100, 100)
        surface.DrawRect(0, 0, w, h)
    end
    
    -- Кнопки
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetText("Сохранить")
    saveBtn:SetPos(15, 230)
    saveBtn:SetSize(85, 35)
    saveBtn:SetTextColor(Color(255, 255, 255))
    saveBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 120, 80) or Color(60, 100, 60)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    saveBtn.DoClick = function()
        net.Start("NextRP_CapturePoint_Configure")
        net.WriteEntity(ent)
        net.WriteTable({
            name = nameEntry:GetText(),
            radius = radiusSlider:GetValue(),
            active = activeCheck:GetChecked(),
        })
        net.SendToServer()
        frame:Close()
        chat.AddText(Color(0, 255, 0), "[AutoEvents] ", Color(255, 255, 255), "Настройки точки захвата сохранены!")
    end
    
    local resetBtn = vgui.Create("DButton", frame)
    resetBtn:SetText("Сбросить")
    resetBtn:SetPos(110, 230)
    resetBtn:SetSize(85, 35)
    resetBtn:SetTextColor(Color(255, 255, 255))
    resetBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(120, 100, 60) or Color(100, 80, 40)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    resetBtn.DoClick = function()
        net.Start("NextRP_CapturePoint_Reset")
        net.WriteEntity(ent)
        net.SendToServer()
        chat.AddText(Color(255, 165, 0), "[AutoEvents] ", Color(255, 255, 255), "Прогресс точки захвата сброшен!")
    end
    
    local deleteBtn = vgui.Create("DButton", frame)
    deleteBtn:SetText("Удалить")
    deleteBtn:SetPos(205, 230)
    deleteBtn:SetSize(85, 35)
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
        
        local confirmLabel = vgui.Create("DLabel", confirmFrame)
        confirmLabel:SetText("Вы уверены что хотите удалить эту точку?")
        confirmLabel:SetPos(20, 40)
        confirmLabel:SetSize(260, 20)
        confirmLabel:SetTextColor(Color(255, 255, 255))
        
        local yesBtn = vgui.Create("DButton", confirmFrame)
        yesBtn:SetText("Да")
        yesBtn:SetPos(50, 80)
        yesBtn:SetSize(80, 30)
        yesBtn.DoClick = function()
            net.Start("NextRP_CapturePoint_Delete")
            net.WriteEntity(ent)
            net.SendToServer()
            confirmFrame:Close()
            frame:Close()
        end
        
        local noBtn = vgui.Create("DButton", confirmFrame)
        noBtn:SetText("Нет")
        noBtn:SetPos(170, 80)
        noBtn:SetSize(80, 30)
        noBtn.DoClick = function()
            confirmFrame:Close()
        end
    end
    
    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetText("Отмена")
    cancelBtn:SetPos(300, 230)
    cancelBtn:SetSize(85, 35)
    cancelBtn:SetTextColor(Color(255, 255, 255))
    cancelBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 80, 80) or Color(60, 60, 60)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    cancelBtn.DoClick = function()
        frame:Close()
    end
end)