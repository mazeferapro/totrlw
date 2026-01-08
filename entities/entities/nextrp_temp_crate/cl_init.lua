-- ============================================================================
-- entities/entities/nextrp_temp_crate/cl_init.lua
-- Клиентская часть временного ящика С ИНВЕНТАРЁМ ИГРОКА
-- ИСПРАВЛЕНО: отображение предметов инвентаря, правильная компоновка
-- ============================================================================

include("shared.lua")

-- ============================================================================
-- ОТРИСОВКА
-- ============================================================================

function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos() + self:GetUp() * 45
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
        draw.SimpleText((self.crateName or "Временный ящик"), "PawsUI.Text.Normal", 0, -15, ColorAlpha(NextRP.Style.Theme.Accent, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Подсказка
        draw.SimpleText("[E] Открыть", "PawsUI.Text.Small", 0, 15, ColorAlpha(Color(200, 200, 200), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:DrawTranslucent()
    self:Draw()
end

-- ============================================================================
-- UI ЯЩИКА + ИНВЕНТАРЬ ИГРОКА
-- ============================================================================

NextRP.Inventory.TempCrateUI = nil

netstream.Hook("NextRP::OpenTempCrate", function(data)
    NextRP.Inventory:OpenTempCrateUI(data)
end)

netstream.Hook("NextRP::UpdateTempCrate", function(data)
    if IsValid(NextRP.Inventory.TempCrateUI) and NextRP.Inventory.TempCrateUI.EntIndex == data.entIndex then
        NextRP.Inventory:RefreshTempCrateGrid(data.items)
    end
end)

function NextRP.Inventory:OpenTempCrateUI(data)
    if IsValid(self.TempCrateUI) then
        self.TempCrateUI:Remove()
    end
    
    -- Закрываем обычный инвентарь если открыт
    if IsValid(self.UI) then
        self.UI:Remove()
    end
    
    local theme = NextRP.Style.Theme
    local config = self.Config
    
    -- Запрашиваем актуальные данные инвентаря
    netstream.Start("NextRP::RequestInventoryOpen")
    
    -- Размеры сеток
    local crateGridWidth = data.gridWidth or 8
    local crateGridHeight = data.gridHeight or 5
    local invGridWidth = config.GridWidth
    local invGridHeight = config.GridHeight
    
    -- Рассчитываем размер окна
    local invPanelWidth = invGridWidth * config.CellSize + 20
    local cratePanelWidth = crateGridWidth * config.CellSize + 20
    local windowWidth = invPanelWidth + cratePanelWidth + 40
    local windowHeight = math.max(invGridHeight, crateGridHeight) * config.CellSize + 140
    
    self.TempCrateUI = vgui.Create("PawsUI.Frame")
    self.TempCrateUI:SetTitle("Инвентарь | " .. (data.crateName or "Временный ящик"))
    self.TempCrateUI:SetSize(windowWidth, windowHeight)
    self.TempCrateUI:Center()
    self.TempCrateUI:MakePopup()
    self.TempCrateUI:ShowSettingsButton(false)
    self.TempCrateUI.EntIndex = data.entIndex
    self.TempCrateUI.Items = data.items or {}
    self.TempCrateUI.CrateGridWidth = crateGridWidth
    self.TempCrateUI.CrateGridHeight = crateGridHeight
    
    -- ============================================
    -- ЛЕВАЯ ПАНЕЛЬ - ИНВЕНТАРЬ ИГРОКА
    -- ============================================
    local leftPanel = vgui.Create("DPanel", self.TempCrateUI)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(invPanelWidth)
    leftPanel:DockMargin(5, 5, 5, 5)
    leftPanel.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
    end
    
    local invTitle = vgui.Create("DLabel", leftPanel)
    invTitle:Dock(TOP)
    invTitle:SetTall(30)
    invTitle:SetFont("PawsUI.Text.Normal")
    invTitle:SetText("Инвентарь")
    invTitle:SetTextColor(theme.Text)
    invTitle:SetContentAlignment(5)
    
    -- Контейнер для сетки инвентаря
    local invContainer = vgui.Create("DPanel", leftPanel)
    invContainer:Dock(FILL)
    invContainer:DockMargin(5, 5, 5, 5)
    invContainer.Paint = function() end
    
    -- Сетка инвентаря
    self.TempCrateUI.InventoryGrid = self:CreateGrid(invContainer, invGridWidth, invGridHeight, "inventory")
    self.TempCrateUI.InventoryGrid:SetPos(5, 5)
    
    -- Сохраняем ссылку для работы drag & drop и RefreshUI
    self.InventoryGrid = self.TempCrateUI.InventoryGrid
    self.StorageMode = false
    self.StorageGrid = nil
    self.UI = self.TempCrateUI -- Важно для EndDrag
    
    -- ============================================
    -- ПРАВАЯ ПАНЕЛЬ - ВРЕМЕННЫЙ ЯЩИК
    -- ============================================
    local rightPanel = vgui.Create("DPanel", self.TempCrateUI)
    rightPanel:Dock(FILL)
    rightPanel:DockMargin(5, 5, 5, 5)
    rightPanel.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
    end
    
    local crateTitle = vgui.Create("DLabel", rightPanel)
    crateTitle:Dock(TOP)
    crateTitle:SetTall(30)
    crateTitle:SetFont("PawsUI.Text.Normal")
    crateTitle:SetText(data.crateName or "Временный ящик")
    crateTitle:SetTextColor(theme.Text)
    crateTitle:SetContentAlignment(5)
    
    -- Кнопка "Взять всё"
    local takeAllBtn = vgui.Create("PawsUI.Button", rightPanel)
    takeAllBtn:SetLabel("Взять всё")
    takeAllBtn:Dock(BOTTOM)
    takeAllBtn:SetTall(35)
    takeAllBtn:DockMargin(5, 5, 5, 5)
    
    takeAllBtn.DoClick = function()
        netstream.Start("NextRP::TakeAllTempCrate", {
            entIndex = self.TempCrateUI.EntIndex
        })
    end
    
    -- Контейнер для сетки ящика
    local crateContainer = vgui.Create("DPanel", rightPanel)
    crateContainer:Dock(FILL)
    crateContainer:DockMargin(5, 5, 5, 5)
    crateContainer.Paint = function() end
    
    -- Сетка ящика
    self.TempCrateUI.CrateGrid = self:CreateCrateGrid(crateContainer, crateGridWidth, crateGridHeight)
    self.TempCrateUI.CrateGrid:SetPos(5, 5)
    
    -- Заполняем данными ящика
    self:RefreshTempCrateGrid(data.items)
    
    -- Заполняем данными инвентаря игрока
    self:DrawItems(self.TempCrateUI.InventoryGrid, self.LocalData.inventory, "inventory")
    
    -- При закрытии очищаем ссылки
    self.TempCrateUI.OnClose = function()
        self.UI = nil
        self.InventoryGrid = nil
        self.TempCrateUI = nil
    end
end

-- Создание сетки для ящика
function NextRP.Inventory:CreateCrateGrid(parent, gridWidth, gridHeight)
    local config = self.Config
    
    local grid = vgui.Create("DPanel", parent)
    grid:SetSize(gridWidth * config.CellSize, gridHeight * config.CellSize)
    grid.GridType = "crate"
    grid.GridWidth = gridWidth
    grid.GridHeight = gridHeight
    grid.Cells = {}
    
    grid.Paint = function() end
    
    -- Создаём ячейки
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local cell = vgui.Create("DPanel", grid)
            cell:SetPos((x - 1) * config.CellSize, (y - 1) * config.CellSize)
            cell:SetSize(config.CellSize, config.CellSize)
            cell.GridX = x
            cell.GridY = y
            cell.GridType = "crate"
            
            cell.Paint = function(pnl, w, h)
                local bgColor = config.Colors.Empty
                
                if pnl.IsOccupied then
                    bgColor = config.Colors.Occupied
                end
                
                if pnl:IsHovered() then
                    bgColor = config.Colors.Hover
                end
                
                draw.RoundedBox(2, 1, 1, w - 2, h - 2, bgColor)
                surface.SetDrawColor(60, 60, 60, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            
            grid.Cells[x .. "_" .. y] = cell
        end
    end
    
    return grid
end

-- Обновление сетки ящика
function NextRP.Inventory:RefreshTempCrateGrid(items)
    if not IsValid(self.TempCrateUI) or not IsValid(self.TempCrateUI.CrateGrid) then return end
    
    local grid = self.TempCrateUI.CrateGrid
    local config = self.Config
    
    -- Удаляем старые предметы
    for _, child in pairs(grid:GetChildren()) do
        if child.IsItemPanel then
            child:Remove()
        end
    end
    
    -- Сбрасываем занятость
    for key, cell in pairs(grid.Cells) do
        cell.IsOccupied = false
    end
    
    self.TempCrateUI.Items = items or {}
    
    -- Обновляем занятость и рисуем предметы
    for uniqueID, item in pairs(items or {}) do
        local itemData = self:GetItemData(item.itemID)
        if not itemData then continue end
        
        -- Помечаем ячейки как занятые
        for x = item.posX, item.posX + itemData.width - 1 do
            for y = item.posY, item.posY + itemData.height - 1 do
                local cell = grid.Cells[x .. "_" .. y]
                if cell then
                    cell.IsOccupied = true
                end
            end
        end
        
        -- Создаём панель предмета
        local itemPanel = vgui.Create("DButton", grid)
        itemPanel.IsItemPanel = true
        itemPanel.UniqueID = uniqueID
        itemPanel.ItemData = itemData
        itemPanel.Item = item
        itemPanel.GridType = "crate"
        itemPanel:SetText("")
        
        itemPanel:SetPos((item.posX - 1) * config.CellSize, (item.posY - 1) * config.CellSize)
        itemPanel:SetSize(itemData.width * config.CellSize, itemData.height * config.CellSize)
        
        itemPanel.Paint = function(pnl, w, h)
            local bgColor = self:GetRarityColor(itemData.rarity)
            bgColor = ColorAlpha(bgColor, pnl:IsHovered() and 180 or 100)
            
            -- Подсветка для объединения стаков
            if self.DraggedItem and self.DraggedItem.itemID == item.itemID and itemData.stackable then
                if self.DraggedItem.uniqueID ~= uniqueID then
                    bgColor = Color(100, 255, 100, 150)
                end
            end
            
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, bgColor)
            
            -- Иконка
            if itemData.icon then
                local iconSize = math.min(w, h) - 10
                local mat = Material(itemData.icon)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
            end
            
            -- Количество
            if item.amount and item.amount > 1 then
                draw.SimpleText("x" .. item.amount, "PawsUI.Text.Small", w - 3, h - 3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end
            
            -- Рамка редкости
            surface.SetDrawColor(self:GetRarityColor(itemData.rarity))
            surface.DrawOutlinedRect(2, 2, w - 4, h - 4, 2)
        end
        
        -- ОБНОВЛЕНО: Поддержка перетаскивания
        itemPanel.OnMousePressed = function(pnl, mouseCode)
            if mouseCode == MOUSE_LEFT then
                self:StartCrateDrag(pnl)
            elseif mouseCode == MOUSE_RIGHT then
                -- Правый клик - меню
                local menu = DermaMenu()
                
                menu:AddOption("Взять", function()
                    netstream.Start("NextRP::TakeTempCrateItem", {
                        entIndex = self.TempCrateUI.EntIndex,
                        uniqueID = uniqueID
                    })
                end):SetIcon("icon16/accept.png")
                
                menu:AddOption("Информация", function()
                    self:ShowItemInfo(itemData)
                end):SetIcon("icon16/information.png")
                
                menu:Open()
            end
        end
        
        itemPanel.OnCursorEntered = function(pnl)
            pnl.ItemData = itemData
            pnl.Item = item
            self:ShowItemTooltip(pnl)
        end
        
        itemPanel.OnCursorExited = function(pnl)
            self:HideItemTooltip()
        end
    end
end

-- Начало перетаскивания из ящика
function NextRP.Inventory:StartCrateDrag(itemPanel)
    if not itemPanel or not itemPanel.Item then return end
    
    self.DraggedItem = {
        itemID = itemPanel.Item.itemID,
        uniqueID = itemPanel.UniqueID,
        amount = itemPanel.Item.amount,
        fromStorage = false,
        fromCrate = true,
        originalPanel = itemPanel
    }
    
    -- Создаём визуальный элемент перетаскивания
    if IsValid(self.DragVisual) then
        self.DragVisual:Remove()
    end
    
    self.DragVisual = vgui.Create("DPanel")
    self.DragVisual:SetSize(itemPanel:GetSize())
    self.DragVisual:SetMouseInputEnabled(false)
    self.DragVisual:MakePopup()
    self.DragVisual:SetKeyboardInputEnabled(false)
    
    local itemData = self:GetItemData(self.DraggedItem.itemID)
    
    self.DragVisual.Paint = function(pnl, w, h)
        if not itemData then return end
        local bgColor = ColorAlpha(self:GetRarityColor(itemData.rarity), 200)
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        
        if itemData.icon then
            local iconSize = math.min(w, h) - 10
            local mat = Material(itemData.icon)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
        end
    end
    
    -- Обновляем позицию
    hook.Add("Think", "NextRP::CrateDrag", function()
        if not IsValid(self.DragVisual) then
            hook.Remove("Think", "NextRP::CrateDrag")
            return
        end
        
        local x, y = gui.MousePos()
        self.DragVisual:SetPos(x - self.DragVisual:GetWide()/2, y - self.DragVisual:GetTall()/2)
        
        if not input.IsMouseDown(MOUSE_LEFT) then
            self:EndCrateDrag()
        end
    end)
end

-- Окончание перетаскивания из ящика
function NextRP.Inventory:EndCrateDrag()
    if not self.DraggedItem or not self.DraggedItem.fromCrate then 
        self.DraggedItem = nil
        return 
    end
    
    if IsValid(self.DragVisual) then
        self.DragVisual:Remove()
    end
    
    local x, y = gui.MousePos()
    local dropped = false
    
    -- Проверяем сетку ящика (перемещение внутри ящика)
    if IsValid(self.TempCrateUI) and IsValid(self.TempCrateUI.CrateGrid) then
        local crateGrid = self.TempCrateUI.CrateGrid
        local gx, gy = crateGrid:LocalToScreen(0, 0)
        local gw, gh = crateGrid:GetSize()
        
        if x >= gx and x <= gx + gw and y >= gy and y <= gy + gh then
            -- Проверяем бросили ли на другой предмет для объединения
            local targetPanel = self:FindItemPanelUnderCursor(crateGrid, x, y)
            
            if targetPanel and targetPanel.UniqueID ~= self.DraggedItem.uniqueID then
                local sourceItemData = self:GetItemData(self.DraggedItem.itemID)
                
                -- Проверяем можно ли объединить
                if targetPanel.Item.itemID == self.DraggedItem.itemID and sourceItemData and sourceItemData.stackable then
                    netstream.Start("NextRP::MergeTempCrateStacks", {
                        entIndex = self.TempCrateUI.EntIndex,
                        sourceUniqueID = self.DraggedItem.uniqueID,
                        targetUniqueID = targetPanel.UniqueID
                    })
                    dropped = true
                end
            end
            
            -- Обычное перемещение внутри ящика
            if not dropped then
                local cellX = math.floor((x - gx) / self.Config.CellSize) + 1
                local cellY = math.floor((y - gy) / self.Config.CellSize) + 1
                
                netstream.Start("NextRP::MoveTempCrateItem", {
                    entIndex = self.TempCrateUI.EntIndex,
                    uniqueID = self.DraggedItem.uniqueID,
                    newX = cellX,
                    newY = cellY
                })
                dropped = true
            end
        end
    end
    
    -- Проверяем сетку инвентаря игрока (забрать из ящика в инвентарь)
    if not dropped and IsValid(self.InventoryGrid) then
        local invGrid = self.InventoryGrid
        local gx, gy = invGrid:LocalToScreen(0, 0)
        local gw, gh = invGrid:GetSize()
        
        if x >= gx and x <= gx + gw and y >= gy and y <= gy + gh then
            -- Забираем предмет из ящика в инвентарь
            netstream.Start("NextRP::TakeTempCrateItem", {
                entIndex = self.TempCrateUI.EntIndex,
                uniqueID = self.DraggedItem.uniqueID
            })
            dropped = true
        end
    end
    
    self.DraggedItem = nil
    hook.Remove("Think", "NextRP::CrateDrag")
end

-- Переопределяем RefreshUI для работы с TempCrateUI
local originalRefreshUI = NextRP.Inventory.RefreshUI
NextRP.Inventory.RefreshUI = function(self)
    -- Если открыт интерфейс ящика, обновляем его
    if IsValid(self.TempCrateUI) and IsValid(self.TempCrateUI.InventoryGrid) then
        self:ClearItems(self.TempCrateUI.InventoryGrid)
        self:DrawItems(self.TempCrateUI.InventoryGrid, self.LocalData.inventory, "inventory")
        return
    end
    
    -- Иначе вызываем оригинальный RefreshUI
    if originalRefreshUI then
        originalRefreshUI(self)
    end
end

-- Вспомогательная функция для поиска панели предмета под курсором (если не определена)
if not NextRP.Inventory.FindItemPanelUnderCursor then
    function NextRP.Inventory:FindItemPanelUnderCursor(grid, mouseX, mouseY)
        if not IsValid(grid) then return nil end
        
        for _, child in pairs(grid:GetChildren()) do
            if child.IsItemPanel and IsValid(child) then
                local px, py = child:LocalToScreen(0, 0)
                local pw, ph = child:GetSize()
                
                if mouseX >= px and mouseX <= px + pw and mouseY >= py and mouseY <= py + ph then
                    return child
                end
            end
        end
        
        return nil
    end
end

print("[NextRP] Entity nextrp_temp_crate (client) загружен!")