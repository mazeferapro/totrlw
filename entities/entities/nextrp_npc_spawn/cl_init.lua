-- gamemode/modules/autoevents/entities/nextrp_npc_spawn/cl_init.lua

include("shared.lua")

function ENT:Initialize()
    self:SetRenderBounds(Vector(-100, -100, -50), Vector(100, 100, 50))
end

function ENT:Draw()
    self:DrawModel()
    
    -- Отрисовка информации над энтити
    local pos = self:GetPos() + Vector(0, 0, 40)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        draw.RoundedBox(4, -60, -15, 120, 30, Color(0, 0, 0, 200))
        draw.SimpleText("СПАВН NPC", "DermaDefaultBold", 0, -5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self:GetSpawnName(), "DermaDefault", 0, 10, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
    
    -- Отрисовка зоны спавна для админов
    if LocalPlayer():IsAdmin() then
        render.SetColorMaterial()
        render.DrawSphere(self:GetPos(), self:GetSpawnRadius(), 10, 10, Color(255, 0, 0, 30))
        render.DrawWireframeSphere(self:GetPos(), self:GetSpawnRadius(), 10, 10, Color(255, 0, 0, 100), true)
    end
end

-- Меню настройки
net.Receive("NextRP_NPCSpawn_OpenMenu", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Настройка зоны спавна NPC")
    frame:SetSize(400, 250)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(true)
    frame:SetDraggable(true)
    frame:SetSizable(false)
    
    -- Стилизация фрейма
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 240))
        draw.RoundedBox(4, 0, 0, w, 24, Color(60, 60, 60, 255))
        surface.SetDrawColor(200, 100, 100)
        surface.DrawRect(0, 24, w, 2)
    end
    
    -- Название зоны
    local nameLabel = vgui.Create("DLabel", frame)
    nameLabel:SetText("Название зоны:")
    nameLabel:SetPos(15, 40)
    nameLabel:SetSize(150, 20)
    nameLabel:SetTextColor(Color(255, 255, 255))
    
    local nameEntry = vgui.Create("DTextEntry", frame)
    nameEntry:SetText(ent:GetSpawnName())
    nameEntry:SetPos(15, 65)
    nameEntry:SetSize(370, 25)
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
        draw.RoundedBox(4, 2, 2, w-4, h-4, Color(50, 50, 50, 255))
        self:DrawTextEntryText(Color(255, 255, 255), Color(200, 100, 100), Color(200, 200, 200))
    end
    
    -- Радиус спавна
    local radiusLabel = vgui.Create("DLabel", frame)
    radiusLabel:SetText("Радиус спавна:")
    radiusLabel:SetPos(15, 100)
    radiusLabel:SetSize(150, 20)
    radiusLabel:SetTextColor(Color(255, 255, 255))
    
    local radiusSlider = vgui.Create("DNumSlider", frame)
    radiusSlider:SetPos(15, 120)
    radiusSlider:SetSize(370, 25)
    radiusSlider:SetMin(25)
    radiusSlider:SetMax(500)
    radiusSlider:SetDecimals(0)
    radiusSlider:SetValue(ent:GetSpawnRadius())
    radiusSlider:SetText("Радиус")
    radiusSlider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 100))
    end
    
    -- Активность зоны
    local activeCheck = vgui.Create("DCheckBoxLabel", frame)
    activeCheck:SetText("Активная зона спавна")
    activeCheck:SetPos(15, 155)
    activeCheck:SetSize(200, 20)
    activeCheck:SetTextColor(Color(255, 255, 255))
    activeCheck:SetChecked(ent:GetActive())
    
    -- Разделитель
    local divider = vgui.Create("DPanel", frame)
    divider:SetPos(15, 185)
    divider:SetSize(370, 1)
    divider.Paint = function(self, w, h)
        surface.SetDrawColor(100, 100, 100)
        surface.DrawRect(0, 0, w, h)
    end
    
    -- Кнопки
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetText("Сохранить")
    saveBtn:SetPos(15, 200)
    saveBtn:SetSize(90, 35)
    saveBtn:SetTextColor(Color(255, 255, 255))
    saveBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 120, 80) or Color(60, 100, 60)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    saveBtn.DoClick = function()
        net.Start("NextRP_NPCSpawn_Configure")
        net.WriteEntity(ent)
        net.WriteTable({
            name = nameEntry:GetText(),
            radius = radiusSlider:GetValue(),
            active = activeCheck:GetChecked(),
        })
        net.SendToServer()
        frame:Close()
        chat.AddText(Color(0, 255, 0), "[AutoEvents] ", Color(255, 255, 255), "Настройки зоны спавна NPC сохранены!")
    end
    
    local deleteBtn = vgui.Create("DButton", frame)
    deleteBtn:SetText("Удалить")
    deleteBtn:SetPos(115, 200)
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
        confirmLabel:SetText("Вы уверены что хотите удалить зону спавна?")
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
            net.Start("NextRP_NPCSpawn_Delete")
            net.WriteEntity(ent)
            net.SendToServer()
            confirmFrame:Close()
            frame:Close()
            chat.AddText(Color(255, 100, 100), "[AutoEvents] ", Color(255, 255, 255), "Зона спавна NPC удалена!")
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
    
    local testBtn = vgui.Create("DButton", frame)
    testBtn:SetText("Тест спавна")
    testBtn:SetPos(215, 200)
    testBtn:SetSize(90, 35)
    testBtn:SetTextColor(Color(255, 255, 255))
    testBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(100, 120, 140) or Color(80, 100, 120)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    testBtn.DoClick = function()
        chat.AddText(Color(200, 100, 100), "[Зона спавна] ", Color(255, 255, 255), "Радиус спавна отображается красной сферой")
        chat.AddText(Color(255, 255, 255), "Текущий радиус: ", Color(255, 255, 0), tostring(radiusSlider:GetValue()), Color(255, 255, 255), " единиц")
    end
    
    local cancelBtn = vgui.Create("DButton", frame)
    cancelBtn:SetText("Отмена")
    cancelBtn:SetPos(315, 200)
    cancelBtn:SetSize(70, 35)
    cancelBtn:SetTextColor(Color(255, 255, 255))
    cancelBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 80, 80) or Color(60, 60, 60)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    cancelBtn.DoClick = function()
        frame:Close()
    end
end)