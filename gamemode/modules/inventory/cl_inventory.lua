--[[--
    Клиентская часть системы инвентаря с UI в стиле DayZ
    Модуль: inventory
]]--

include("sh_inventory.lua")

-- Локальные данные инвентаря
NextRP.Inventory.LocalData = {
    inventory = {grid = {}, items = {}},
    storage = {grid = {}, items = {}},
    equipment = {},
    unlockedSlots = {}
}

-- UI элементы
NextRP.Inventory.UI = NextRP.Inventory.UI or nil
NextRP.Inventory.DraggedItem = nil
NextRP.Inventory.StorageMode = false -- Флаг режима хранилища

-- ============================================================================
-- СЕТЕВЫЕ ОБРАБОТЧИКИ
-- ============================================================================

netstream.Hook("NextRP::InventorySync", function(data)
    NextRP.Inventory.LocalData.inventory = data.inventory or {grid = {}, items = {}}
    NextRP.Inventory.LocalData.storage = data.storage or {grid = {}, items = {}}
    NextRP.Inventory.LocalData.equipment = data.equipment or {}
    NextRP.Inventory.LocalData.unlockedSlots = data.unlockedSlots or {}
    
    -- Обновляем UI если открыт
    if IsValid(NextRP.Inventory.UI) then
        NextRP.Inventory:RefreshUI()
    end
end)

netstream.Hook("NextRP::OpenDeathBag", function(data)
    NextRP.Inventory:OpenDeathBagUI(data.entIndex, data.items)
end)

netstream.Hook("NextRP::UpdateDeathBag", function(data)
    -- [ИЗМЕНЕНИЕ] Если предметов 0 или таблица nil - закрываем окно
    if not data.items or table.Count(data.items) == 0 then
        if IsValid(NextRP.Inventory.DeathBagUI) then
            NextRP.Inventory.DeathBagUI:Remove()
        end
        return
    end

    -- Иначе обновляем интерфейс как обычно
    if IsValid(NextRP.Inventory.DeathBagUI) then
        NextRP.Inventory:RefreshDeathBagUI(data.items)
    end
end)

netstream.Hook("NextRP::OpenStorage", function(withStorage)
    NextRP.Inventory:OpenUI(withStorage or true) -- true = режим хранилища
end)

-- ============================================================================
-- СОЗДАНИЕ UI
-- ============================================================================

function NextRP.Inventory:OpenUI(withStorage)
    if IsValid(self.UI) then
        self.UI:Remove()
        return
    end
    
    self.StorageMode = withStorage or false
    
    -- Запрашиваем актуальные данные
    netstream.Start("NextRP::RequestInventoryOpen")
    
    local config = self.Config
    local theme = NextRP.Style.Theme
    
    -- Рассчитываем размер окна
    local windowWidth = config.GridWidth * config.CellSize + 300 + 40
    if self.StorageMode then
        windowWidth = windowWidth + config.StorageGridWidth * config.CellSize + 30
    end
    
    -- Главный фрейм
    self.UI = vgui.Create("PawsUI.Frame")
    self.UI:SetTitle(self.StorageMode and "Инвентарь и Хранилище" or "Инвентарь")
    self.UI:SetSize(math.min(windowWidth, ScrW() - 100), 700)
    self.UI:Center()
    self.UI:MakePopup()
    self.UI:ShowSettingsButton(false)
    
    -- Левая панель - инвентарь персонажа
    local leftPanel = vgui.Create("PawsUI.Panel", self.UI)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(config.GridWidth * config.CellSize + 20)
    leftPanel:DockMargin(5, 5, 5, 5)
    
    local invTitle = vgui.Create("DLabel", leftPanel)
    invTitle:Dock(TOP)
    invTitle:SetTall(30)
    invTitle:SetFont("PawsUI.Text.Normal")
    invTitle:SetText("Инвентарь персонажа")
    invTitle:SetTextColor(theme.Text)
    invTitle:SetContentAlignment(5)
    
    -- Сетка инвентаря
    self.InventoryGrid = self:CreateGrid(leftPanel, config.GridWidth, config.GridHeight, "inventory")
    self.InventoryGrid:Dock(TOP)
    self.InventoryGrid:DockMargin(5, 5, 5, 5)
    
    -- Центральная панель - слоты снаряжения
    local centerPanel = vgui.Create("PawsUI.Panel", self.UI)
    centerPanel:Dock(LEFT)
    centerPanel:SetWide(280)
    centerPanel:DockMargin(5, 5, 5, 5)
    
    local equipTitle = vgui.Create("DLabel", centerPanel)
    equipTitle:Dock(TOP)
    equipTitle:SetTall(30)
    equipTitle:SetFont("PawsUI.Text.Normal")
    equipTitle:SetText("Снаряжение")
    equipTitle:SetTextColor(theme.Text)
    equipTitle:SetContentAlignment(5)
    
    local equipScroll = vgui.Create("PawsUI.ScrollPanel", centerPanel)
    equipScroll:Dock(FILL)
    equipScroll:DockMargin(5, 5, 5, 5)
    
    -- Создаём секции для каждого типа снаряжения
    self.EquipmentPanels = {}
    for slotType, slotConfig in pairs(config.EquipmentSlots) do
        self:CreateEquipmentSection(equipScroll, slotType, slotConfig)
    end
    
    -- Правая панель - личное хранилище (только если StorageMode)
    if self.StorageMode then
        local rightPanel = vgui.Create("PawsUI.Panel", self.UI)
        rightPanel:Dock(FILL)
        rightPanel:DockMargin(5, 5, 5, 5)
        
        local storageTitle = vgui.Create("DLabel", rightPanel)
        storageTitle:Dock(TOP)
        storageTitle:SetTall(30)
        storageTitle:SetFont("PawsUI.Text.Normal")
        storageTitle:SetText("Личное хранилище")
        storageTitle:SetTextColor(theme.Text)
        storageTitle:SetContentAlignment(5)
        
        local storageScroll = vgui.Create("PawsUI.ScrollPanel", rightPanel)
        storageScroll:Dock(FILL)
        storageScroll:DockMargin(5, 5, 5, 5)
        
        self.StorageGrid = self:CreateGrid(storageScroll, config.StorageGridWidth, config.StorageGridHeight, "storage")
    else
        self.StorageGrid = nil
    end
    
    -- Заполняем данными
    self:RefreshUI()
end

function NextRP.Inventory:CreateGrid(parent, gridWidth, gridHeight, gridType)
    local config = self.Config
    local theme = NextRP.Style.Theme
    
    local grid = vgui.Create("DPanel", parent)
    grid:SetSize(gridWidth * config.CellSize, gridHeight * config.CellSize)
    grid.GridType = gridType
    grid.GridWidth = gridWidth
    grid.GridHeight = gridHeight
    grid.Cells = {}
    
    grid.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, config.Colors.Empty)
    end
    
    -- Создаём ячейки
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local cell = vgui.Create("DPanel", grid)
            cell:SetPos((x - 1) * config.CellSize, (y - 1) * config.CellSize)
            cell:SetSize(config.CellSize, config.CellSize)
            cell.GridX = x
            cell.GridY = y
            cell.GridType = gridType
            
            cell.Paint = function(pnl, w, h)
                local bgColor = config.Colors.Empty
                
                if pnl.IsOccupied then
                    bgColor = config.Colors.Occupied
                end
                
                if pnl:IsHovered() then
                    bgColor = config.Colors.Hover
                end
                
                if self.DraggedItem and pnl:IsHovered() then
                    local itemData = self:GetItemData(self.DraggedItem.itemID)
                    if itemData then
                        local storage = gridType == "storage" and self.LocalData.storage or self.LocalData.inventory
                        
                        -- Временно убираем предмет из сетки для проверки
                        local tempGrid = table.Copy(storage.grid or {})
                        if self.DraggedItem.uniqueID then
                            for key, val in pairs(tempGrid) do
                                if val == self.DraggedItem.uniqueID then
                                    tempGrid[key] = nil
                                end
                            end
                        end
                        
                        if self:CanFitItem(tempGrid, gridWidth, gridHeight, itemData, x, y) then
                            bgColor = config.Colors.Selected
                        else
                            bgColor = config.Colors.Invalid
                        end
                    end
                end
                
                draw.RoundedBox(2, 1, 1, w - 2, h - 2, bgColor)
                
                -- Границы ячейки
                surface.SetDrawColor(60, 60, 60, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            
            -- Ячейки не обрабатывают клики - клики только на предметах
            
            grid.Cells[x .. "_" .. y] = cell
        end
    end
    
    return grid
end

function NextRP.Inventory:CreateEquipmentSection(parent, slotType, slotConfig)
    local theme = NextRP.Style.Theme
    local config = self.Config
    
    local section = vgui.Create("PawsUI.Panel", parent)
    section:Dock(TOP)
    section:SetTall(100)
    section:DockMargin(0, 5, 0, 5)
    section.SlotType = slotType
    
    local slotNames = {
        primary = "Основное оружие",
        secondary = "Второстепенное",
        heavy = "Тяжёлое снаряжение",
        special = "Специальное",
        medical = "Медицинское"
    }
    
    section.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, theme.Background)
        draw.SimpleText(slotNames[slotType] or slotType, "PawsUI.Text.Small", 5, 5, theme.Text)
    end
    
    -- Слоты
    local slotsPanel = vgui.Create("DPanel", section)
    slotsPanel:Dock(FILL)
    slotsPanel:DockMargin(5, 25, 5, 5)
    slotsPanel.Slots = {}
    
    slotsPanel.Paint = function() end
    
    for i = 1, slotConfig.total do
        local slot = vgui.Create("DButton", slotsPanel)
        slot:SetSize(60, 60)
        slot:SetPos((i - 1) * 65, 0)
        slot:SetText("")
        slot.SlotIndex = i
        slot.SlotType = slotType
        
        slot.Paint = function(pnl, w, h)
            local unlocked = self:GetUnlockedSlotCount(slotType)
            local isLocked = i > unlocked
            
            local bgColor = isLocked and config.Colors.Locked or config.Colors.Empty
            
            if pnl:IsHovered() and not isLocked then
                bgColor = config.Colors.Hover
            end
            
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            if isLocked then
                -- Иконка замка и цена
                draw.SimpleText("🔒", "PawsUI.Text.Normal", w/2, h/2 - 10, theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(slotConfig.costPerSlot .. " кр.", "PawsUI.Text.Small", w/2, h/2 + 10, theme.Gold or Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                -- Проверяем есть ли предмет
                local equip = self.LocalData.equipment[slotType]
                local item = equip and (equip[i] or equip[tostring(i)])
                
                if item then
                    local itemData = self:GetItemData(item.itemID)
                    if itemData then
                        -- Рисуем иконку предмета
                        if itemData.icon then
                            local mat = Material(itemData.icon)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(mat)
                            surface.DrawTexturedRect(10, 10, w - 20, h - 20)
                        end
                        
                        if item.amount and item.amount > 1 then
                            draw.SimpleText("x" .. item.amount, "PawsUI.Text.Small", w - 5, h - 5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                        end
                    end
                else
                    -- Пустой слот
                    draw.SimpleText(tostring(i), "PawsUI.Text.Normal", w/2, h/2, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            
            surface.SetDrawColor(60, 60, 60, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        
        slot.DoClick = function(pnl)
            local unlocked = self:GetUnlockedSlotCount(slotType)
            
            if i > unlocked then
                -- Разблокировка слота за деньги
                local money = LocalPlayer():GetNVar('nrp_money') or 0
                Derma_Query(
                    "Разблокировать слот за " .. slotConfig.costPerSlot .. " кредитов?\n\nУ вас: " .. money .. " кредитов",
                    "Разблокировка слота",
                    "Да", function()
                        netstream.Start("NextRP::InventoryUnlockSlot", slotType)
                    end,
                    "Нет", function() end
                )
            end
            -- Если слот разблокирован и пустой - ничего не делаем
        end
        
        slot.DoRightClick = function(pnl)
            local unlocked = self:GetUnlockedSlotCount(slotType)
            if i > unlocked then return end
            
            local equip = self.LocalData.equipment[slotType]
            -- Проверяем по числу (i), а если нет - по строке
            local item = equip and (equip[i] or equip[tostring(i)]) 
            
            if item then
                self:OnEquipmentSlotRightClick(pnl)
            end
        end
        
        slotsPanel.Slots[i] = slot
    end
    
    self.EquipmentPanels[slotType] = slotsPanel
end

function NextRP.Inventory:GetUnlockedSlotCount(slotType)
    local config = self.Config.EquipmentSlots[slotType]
    if not config then return 0 end
    
    local unlocked = self.LocalData.unlockedSlots[slotType] or 0
    return config.free + unlocked
end

-- ============================================================================
-- ОТРИСОВКА ПРЕДМЕТОВ
-- ============================================================================

function NextRP.Inventory:RefreshUI()
    if not IsValid(self.UI) then return end
    
    -- Очищаем предметы
    self:ClearItems(self.InventoryGrid)
    if IsValid(self.StorageGrid) then
        self:ClearItems(self.StorageGrid)
    end
    
    -- Рисуем предметы инвентаря
    self:DrawItems(self.InventoryGrid, self.LocalData.inventory, "inventory")
    
    -- Рисуем предметы хранилища (только если есть)
    if IsValid(self.StorageGrid) and self.StorageMode then
        self:DrawItems(self.StorageGrid, self.LocalData.storage, "storage")
    end
end

function NextRP.Inventory:ClearItems(grid)
    if not IsValid(grid) then return end
    
    for _, child in pairs(grid:GetChildren()) do
        if child.IsItemPanel then
            child:Remove()
        end
    end
end

function NextRP.Inventory:DrawItems(grid, storageData, gridType)
    if not IsValid(grid) or not storageData then return end
    
    local config = self.Config
    local theme = NextRP.Style.Theme
    
    -- Обновляем занятость ячеек
    for key, cell in pairs(grid.Cells) do
        cell.IsOccupied = storageData.grid and storageData.grid[key] ~= nil
    end
    
    -- Рисуем предметы
    for uniqueID, item in pairs(storageData.items or {}) do
        local itemData = self:GetItemData(item.itemID)
        if not itemData then continue end
        
        local itemPanel = vgui.Create("DButton", grid)
        itemPanel.IsItemPanel = true
        itemPanel.UniqueID = uniqueID
        itemPanel.ItemData = itemData
        itemPanel.Item = item
        itemPanel.GridType = gridType
        itemPanel:SetText("")
        
        itemPanel:SetPos((item.posX - 1) * config.CellSize, (item.posY - 1) * config.CellSize)
        itemPanel:SetSize(itemData.width * config.CellSize, itemData.height * config.CellSize)
        
        itemPanel.Paint = function(pnl, w, h)
            local bgColor = self:GetRarityColor(itemData.rarity)
            bgColor = ColorAlpha(bgColor, 100)
            
            if pnl:IsHovered() then
                bgColor = ColorAlpha(self:GetRarityColor(itemData.rarity), 180)
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
        
        itemPanel.OnMousePressed = function(pnl, mouseCode)
            if mouseCode == MOUSE_LEFT then
                self:StartDrag(pnl)
            elseif mouseCode == MOUSE_RIGHT then
                self:ShowItemMenu(pnl)
            end
        end
        
        itemPanel.OnCursorEntered = function(pnl)
            self:ShowItemTooltip(pnl)
        end
        
        itemPanel.OnCursorExited = function(pnl)
            self:HideItemTooltip()
        end
    end
end

-- ============================================================================
-- DRAG & DROP
-- ============================================================================

function NextRP.Inventory:StartDrag(itemPanel)
    if not itemPanel or not itemPanel.Item then return end
    
    self.DraggedItem = {
        itemID = itemPanel.Item.itemID,
        uniqueID = itemPanel.UniqueID,
        amount = itemPanel.Item.amount,
        fromStorage = itemPanel.GridType == "storage",
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
    hook.Add("Think", "NextRP::InventoryDrag", function()
        if not IsValid(self.DragVisual) then
            hook.Remove("Think", "NextRP::InventoryDrag")
            return
        end
        
        local x, y = gui.MousePos()
        self.DragVisual:SetPos(x - self.DragVisual:GetWide()/2, y - self.DragVisual:GetTall()/2)
        
        if not input.IsMouseDown(MOUSE_LEFT) then
            self:EndDrag()
        end
    end)
end

function NextRP.Inventory:EndDrag()
    if not self.DraggedItem then return end
    
    if IsValid(self.DragVisual) then
        self.DragVisual:Remove()
    end
    
    -- Определяем куда бросаем
    local x, y = gui.MousePos()
    local dropped = false
    
    -- Проверяем сетки
    local gridsToCheck = {self.InventoryGrid}
    if IsValid(self.StorageGrid) then
        table.insert(gridsToCheck, self.StorageGrid)
    end
    
    for _, grid in pairs(gridsToCheck) do
        if IsValid(grid) then
            local gx, gy = grid:LocalToScreen(0, 0)
            local gw, gh = grid:GetSize()
            
            if x >= gx and x <= gx + gw and y >= gy and y <= gy + gh then
                -- Определяем ячейку
                local cellX = math.floor((x - gx) / self.Config.CellSize) + 1
                local cellY = math.floor((y - gy) / self.Config.CellSize) + 1
                
                netstream.Start("NextRP::InventoryMoveItem", {
                    uniqueID = self.DraggedItem.uniqueID,
                    newX = cellX,
                    newY = cellY,
                    fromStorage = self.DraggedItem.fromStorage,
                    toStorage = grid.GridType == "storage"
                })
                
                dropped = true
                break
            end
        end
    end
    
    -- Проверяем слоты снаряжения
    if not dropped then
        for slotType, panel in pairs(self.EquipmentPanels or {}) do
            for i, slot in pairs(panel.Slots or {}) do
                if IsValid(slot) then
                    local sx, sy = slot:LocalToScreen(0, 0)
                    local sw, sh = slot:GetSize()
                    
                    if x >= sx and x <= sx + sw and y >= sy and y <= sy + sh then
                        local itemData = self:GetItemData(self.DraggedItem.itemID)
                        if itemData and itemData.slotType == slotType then
                            local unlocked = self:GetUnlockedSlotCount(slotType)
                            if i <= unlocked then
                                netstream.Start("NextRP::InventoryEquipItem", {
                                    uniqueID = self.DraggedItem.uniqueID,
                                    slotType = slotType,
                                    slotIndex = i,
                                    fromStorage = self.DraggedItem.fromStorage
                                })
                                dropped = true
                            end
                        end
                        break
                    end
                end
            end
            if dropped then break end
        end
    end
    
    -- Если бросили за пределы окна - выбрасываем
    if not dropped and IsValid(self.UI) then
        local ux, uy = self.UI:LocalToScreen(0, 0)
        local uw, uh = self.UI:GetSize()
        
        if x < ux or x > ux + uw or y < uy or y > uy + uh then
            netstream.Start("NextRP::InventoryDropItem", {
                uniqueID = self.DraggedItem.uniqueID,
                fromStorage = self.DraggedItem.fromStorage
            })
        end
    end
    
    self.DraggedItem = nil
    hook.Remove("Think", "NextRP::InventoryDrag")
end

-- ============================================================================
-- КОНТЕКСТНОЕ МЕНЮ
-- ============================================================================

function NextRP.Inventory:ShowItemMenu(itemPanel)
    if not itemPanel or not itemPanel.ItemData then return end
    
    local menu = DermaMenu()
    local itemData = itemPanel.ItemData
    local item = itemPanel.Item
    
    if itemData.onUse then
        menu:AddOption("Использовать", function()
            netstream.Start("NextRP::InventoryUseItem", {
                uniqueID = itemPanel.UniqueID,
                fromStorage = itemPanel.GridType == "storage"
            })
        end):SetIcon("icon16/accept.png")
    end
    
    if itemData.slotType then
        menu:AddOption("Экипировать", function()
            -- Находим свободный слот
            local unlocked = self:GetUnlockedSlotCount(itemData.slotType)
            for i = 1, unlocked do
                local equip = self.LocalData.equipment[itemData.slotType]
                if not equip or not equip[tostring(i)] then
                    netstream.Start("NextRP::InventoryEquipItem", {
                        uniqueID = itemPanel.UniqueID,
                        slotType = itemData.slotType,
                        slotIndex = i,
                        fromStorage = itemPanel.GridType == "storage"
                    })
                    break
                end
            end
        end):SetIcon("icon16/shield.png")
    end
    
    if itemData.canDrop then
        menu:AddOption("Выбросить", function()
            netstream.Start("NextRP::InventoryDropItem", {
                uniqueID = itemPanel.UniqueID,
                fromStorage = itemPanel.GridType == "storage"
            })
        end):SetIcon("icon16/bin.png")
    end
    
    menu:AddOption("Информация", function()
        self:ShowItemInfo(itemData)
    end):SetIcon("icon16/information.png")
    
    menu:Open()
end

function NextRP.Inventory:OnEquipmentSlotRightClick(slot)
    if not slot then return end
    
    local equip = self.LocalData.equipment[slot.SlotType]
    -- [ИСПРАВЛЕНИЕ] Добавлена проверка числового индекса
    local item = equip and (equip[slot.SlotIndex] or equip[tostring(slot.SlotIndex)])
    
    if not item then return end
    
    local menu = DermaMenu()
    
    menu:AddOption("Снять", function()
        netstream.Start("NextRP::InventoryUnequipItem", {
            slotType = slot.SlotType,
            slotIndex = slot.SlotIndex
        })
    end):SetIcon("icon16/arrow_down.png")
    
    menu:Open()
end

-- ============================================================================
-- ТУЛТИПЫ
-- ============================================================================

function NextRP.Inventory:ShowItemTooltip(itemPanel)
    if IsValid(self.Tooltip) then
        self.Tooltip:Remove()
    end
    
    if not itemPanel or not itemPanel.ItemData then return end
    
    local itemData = itemPanel.ItemData
    local item = itemPanel.Item
    local theme = NextRP.Style.Theme
    
    self.Tooltip = vgui.Create("DPanel")
    self.Tooltip:SetSize(250, 120)
    self.Tooltip:MakePopup()
    self.Tooltip:SetKeyboardInputEnabled(false)
    self.Tooltip:SetMouseInputEnabled(false)
    
    self.Tooltip.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 240))
        
        -- Название
        draw.SimpleText(itemData.name or "Неизвестно", "PawsUI.Text.Normal", 10, 10, self:GetRarityColor(itemData.rarity))
        
        -- Редкость
        draw.SimpleText(self:GetRarityName(itemData.rarity), "PawsUI.Text.Small", 10, 35, theme.Text)
        
        -- Описание
        draw.SimpleText(itemData.description or "", "PawsUI.Text.Small", 10, 55, Color(180, 180, 180))
        
        -- Размер
        draw.SimpleText("Размер: " .. (itemData.width or 1) .. "x" .. (itemData.height or 1), "PawsUI.Text.Small", 10, 75, theme.Text)
        
        -- Вес
        draw.SimpleText("Вес: " .. (itemData.weight or 0) .. " кг", "PawsUI.Text.Small", 10, 95, theme.Text)
        
        surface.SetDrawColor(self:GetRarityColor(itemData.rarity))
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    local mx, my = gui.MousePos()
    self.Tooltip:SetPos(mx + 15, my + 15)
end

function NextRP.Inventory:HideItemTooltip()
    if IsValid(self.Tooltip) then
        self.Tooltip:Remove()
    end
end

function NextRP.Inventory:ShowItemInfo(itemData)
    if not itemData then return end
    
    local frame = vgui.Create("PawsUI.Frame")
    frame:SetTitle(itemData.name or "Предмет")
    frame:SetSize(300, 250)
    frame:Center()
    frame:MakePopup()
    frame:ShowSettingsButton(false)
    
    local theme = NextRP.Style.Theme
    
    local content = vgui.Create("PawsUI.Panel", frame)
    content:Dock(FILL)
    content:DockMargin(10, 10, 10, 10)
    
    content.Paint = function(pnl, w, h)
        local y = 10
        
        -- Иконка
        if itemData.icon then
            local mat = Material(itemData.icon)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(w/2 - 32, y, 64, 64)
            y = y + 80
        end
        
        -- Редкость
        draw.SimpleText(self:GetRarityName(itemData.rarity), "PawsUI.Text.Normal", w/2, y, self:GetRarityColor(itemData.rarity), TEXT_ALIGN_CENTER)
        y = y + 25
        
        -- Описание
        draw.SimpleText(itemData.description or "Нет описания", "PawsUI.Text.Small", w/2, y, theme.Text, TEXT_ALIGN_CENTER)
        y = y + 25
        
        -- Характеристики
        draw.SimpleText("Размер: " .. (itemData.width or 1) .. "x" .. (itemData.height or 1), "PawsUI.Text.Small", 10, y, theme.Text)
        y = y + 20
        
        draw.SimpleText("Вес: " .. (itemData.weight or 0) .. " кг", "PawsUI.Text.Small", 10, y, theme.Text)
        y = y + 20
        
        if itemData.stackable then
            draw.SimpleText("Макс. стак: " .. (itemData.maxStack or 1), "PawsUI.Text.Small", 10, y, theme.Text)
        end
    end
end

-- ============================================================================
-- UI СУМКИ СМЕРТИ
-- ============================================================================

function NextRP.Inventory:OpenDeathBagUI(entIndex, items)
    if IsValid(self.DeathBagUI) then
        self.DeathBagUI:Remove()
    end
    
    local theme = NextRP.Style.Theme
    
    self.DeathBagUI = vgui.Create("PawsUI.Frame")
    self.DeathBagUI:SetTitle("Сумка")
    self.DeathBagUI:SetSize(400, 500)
    self.DeathBagUI:Center()
    self.DeathBagUI:MakePopup()
    self.DeathBagUI:ShowSettingsButton(false)
    self.DeathBagUI.EntIndex = entIndex
    self.DeathBagUI.Items = items
    
    local scroll = vgui.Create("PawsUI.ScrollPanel", self.DeathBagUI)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)
    self.DeathBagScroll = scroll
    
    self:RefreshDeathBagUI(items)
end

function NextRP.Inventory:RefreshDeathBagUI(items)
    if not IsValid(self.DeathBagScroll) then return end
    
    self.DeathBagScroll:Clear()
    
    local theme = NextRP.Style.Theme
    
    for uniqueID, item in pairs(items or {}) do
        local itemData = self:GetItemData(item.itemID)
        if not itemData then continue end
        
        local itemPanel = vgui.Create("DPanel", self.DeathBagScroll)
        itemPanel:Dock(TOP)
        itemPanel:SetTall(60)
        itemPanel:DockMargin(0, 2, 0, 2)
        
        itemPanel.Paint = function(pnl, w, h)
            local bgColor = ColorAlpha(self:GetRarityColor(itemData.rarity), pnl:IsHovered() and 150 or 80)
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            -- Иконка
            if itemData.icon then
                local mat = Material(itemData.icon)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(10, 10, 40, 40)
            end
            
            -- Название
            draw.SimpleText(itemData.name or "Неизвестно", "PawsUI.Text.Normal", 60, 15, self:GetRarityColor(itemData.rarity))
            
            -- Количество
            if item.amount and item.amount > 1 then
                draw.SimpleText("x" .. item.amount, "PawsUI.Text.Small", 60, 35, theme.Text)
            end
            
            surface.SetDrawColor(self:GetRarityColor(itemData.rarity))
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        
        local takeBtn = vgui.Create("PawsUI.Button", itemPanel)
        takeBtn:SetLabel("Взять")
        takeBtn:Dock(RIGHT)
        takeBtn:SetWide(80)
        takeBtn:DockMargin(5, 10, 5, 10)
        
        takeBtn.DoClick = function()
            netstream.Start("NextRP::InventoryTakeFromBag", {
                entIndex = self.DeathBagUI.EntIndex,
                uniqueID = uniqueID
            })
        end
    end
    
    if table.Count(items or {}) == 0 then
        local emptyLabel = vgui.Create("DLabel", self.DeathBagScroll)
        emptyLabel:Dock(TOP)
        emptyLabel:SetTall(100)
        emptyLabel:SetFont("PawsUI.Text.Normal")
        emptyLabel:SetText("Сумка пуста")
        emptyLabel:SetTextColor(theme.Text)
        emptyLabel:SetContentAlignment(5)
    end
end

-- ============================================================================
-- КОМАНДЫ
-- ============================================================================

concommand.Add("nextrp_inventory", function()
    NextRP.Inventory:OpenUI(false)
end)

concommand.Add("nextrp_storage", function()
    NextRP.Inventory:OpenUI(true)
end)

hook.Add("OnPlayerChat", "NextRP::InventoryCommand", function(ply, text)
    text = string.lower(text)
    if text == "/inv" or text == "/inventory" or text == "!inv" then
        if ply == LocalPlayer() then
            NextRP.Inventory:OpenUI(false)
        end
        return true
    end
end)

-- Горячая клавиша
hook.Add("PlayerButtonDown", "NextRP::InventoryHotkey", function(ply, button)
    if button == KEY_I and ply == LocalPlayer() then
        if not vgui.CursorVisible() then
            NextRP.Inventory:OpenUI(false)
        end
    end
end)

print("[NextRP] Модуль инвентаря (client) загружен!")