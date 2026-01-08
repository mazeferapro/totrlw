-- ============================================================================
-- entities/entities/nextrp_temp_crate/init.lua
-- Серверная часть временного ящика
-- ============================================================================

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ============================================================================

function ENT:Initialize()
    self:SetModel("models/reizer_props/srsp/sci_fi/crate_02/crate_02.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(50)
    end
    
    -- Хранилище предметов (не сохраняется в БД!)
    self.Items = {}
    self.Grid = {}
    
    -- Размер сетки по умолчанию
    self:SetGridWidth(8)
    self:SetGridHeight(5)
    self:SetCrateName("Временный ящик")
    self:SetItemCount(0)
    
    -- Время жизни (опционально) - по умолчанию не ограничено
    self.LifeTime = 0 -- 0 = бесконечно, иначе секунды
    self.SpawnTime = CurTime()
end

-- ============================================================================
-- ИСПОЛЬЗОВАНИЕ
-- ============================================================================

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Отправляем данные клиенту
    netstream.Start(activator, "NextRP::OpenTempCrate", {
        entIndex = self:EntIndex(),
        items = self.Items,
        gridWidth = self:GetGridWidth(),
        gridHeight = self:GetGridHeight(),
        crateName = self:GetCrateName()
    })
end

-- ============================================================================
-- УПРАВЛЕНИЕ ПРЕДМЕТАМИ
-- ============================================================================

function ENT:GetItems()
    return self.Items or {}
end

function ENT:SetItems(items)
    self.Items = items or {}
    self:SetItemCount(table.Count(self.Items))
    
    -- Обновляем сетку
    self.Grid = {}
    for uniqueID, item in pairs(self.Items) do
        local itemData = NextRP.Inventory:GetItemData(item.itemID)
        if itemData then
            for x = item.posX, item.posX + (itemData.width or 1) - 1 do
                for y = item.posY, item.posY + (itemData.height or 1) - 1 do
                    self.Grid[x .. "_" .. y] = uniqueID
                end
            end
        end
    end
end

function ENT:AddItem(itemID, amount, posX, posY)
    local itemData = NextRP.Inventory:GetItemData(itemID)
    if not itemData then return false, "Предмет не найден" end
    
    amount = amount or 1
    
    -- Если позиция не указана - ищем свободное место
    if not posX or not posY then
        posX, posY = self:FindFreeSlot(itemData)
        if not posX then
            return false, "Недостаточно места"
        end
    end
    
    -- Проверяем можно ли разместить
    if not self:CanFitItem(itemData, posX, posY) then
        return false, "Позиция занята"
    end
    
    local uniqueID = tostring(os.time()) .. "_" .. math.random(10000, 99999)
    
    -- Занимаем ячейки
    for x = posX, posX + itemData.width - 1 do
        for y = posY, posY + itemData.height - 1 do
            self.Grid[x .. "_" .. y] = uniqueID
        end
    end
    
    -- Добавляем предмет
    self.Items[uniqueID] = {
        itemID = itemID,
        amount = amount,
        posX = posX,
        posY = posY
    }
    
    self:SetItemCount(table.Count(self.Items))
    
    return true, uniqueID
end

function ENT:RemoveItem(uniqueID, amount)
    local item = self.Items[uniqueID]
    if not item then return false end
    
    local itemData = NextRP.Inventory:GetItemData(item.itemID)
    if not itemData then return false end
    
    amount = amount or item.amount
    
    if item.amount <= amount then
        -- Удаляем полностью
        for x = item.posX, item.posX + itemData.width - 1 do
            for y = item.posY, item.posY + itemData.height - 1 do
                self.Grid[x .. "_" .. y] = nil
            end
        end
        self.Items[uniqueID] = nil
    else
        item.amount = item.amount - amount
    end
    
    self:SetItemCount(table.Count(self.Items))
    return true
end

function ENT:FindFreeSlot(itemData)
    local gridWidth = self:GetGridWidth()
    local gridHeight = self:GetGridHeight()
    
    for y = 1, gridHeight - itemData.height + 1 do
        for x = 1, gridWidth - itemData.width + 1 do
            if self:CanFitItem(itemData, x, y) then
                return x, y
            end
        end
    end
    
    return nil, nil
end

function ENT:CanFitItem(itemData, posX, posY, ignoreUniqueID)
    local gridWidth = self:GetGridWidth()
    local gridHeight = self:GetGridHeight()
    
    -- Проверяем границы
    if posX < 1 or posY < 1 then return false end
    if posX + itemData.width - 1 > gridWidth then return false end
    if posY + itemData.height - 1 > gridHeight then return false end
    
    -- Проверяем занятость
    for x = posX, posX + itemData.width - 1 do
        for y = posY, posY + itemData.height - 1 do
            local occupiedBy = self.Grid[x .. "_" .. y]
            if occupiedBy and occupiedBy ~= ignoreUniqueID then
                return false
            end
        end
    end
    
    return true
end

function ENT:MoveItem(uniqueID, newPosX, newPosY)
    local item = self.Items[uniqueID]
    if not item then return false end
    
    local itemData = NextRP.Inventory:GetItemData(item.itemID)
    if not itemData then return false end
    
    -- Проверяем можно ли разместить (игнорируя текущую позицию предмета)
    if not self:CanFitItem(itemData, newPosX, newPosY, uniqueID) then
        return false
    end
    
    -- Освобождаем старые ячейки
    for x = item.posX, item.posX + itemData.width - 1 do
        for y = item.posY, item.posY + itemData.height - 1 do
            self.Grid[x .. "_" .. y] = nil
        end
    end
    
    -- Занимаем новые ячейки
    for x = newPosX, newPosX + itemData.width - 1 do
        for y = newPosY, newPosY + itemData.height - 1 do
            self.Grid[x .. "_" .. y] = uniqueID
        end
    end
    
    -- Обновляем позицию
    item.posX = newPosX
    item.posY = newPosY
    
    return true
end

function ENT:MergeStacks(sourceUniqueID, targetUniqueID)
    local sourceItem = self.Items[sourceUniqueID]
    local targetItem = self.Items[targetUniqueID]
    
    if not sourceItem or not targetItem then return false end
    if sourceItem.itemID ~= targetItem.itemID then return false end
    
    local itemData = NextRP.Inventory:GetItemData(sourceItem.itemID)
    if not itemData or not itemData.stackable then return false end
    
    local maxStack = itemData.maxStack or 99
    
    if targetItem.amount >= maxStack then return false end
    
    local canAdd = math.min(sourceItem.amount, maxStack - targetItem.amount)
    
    targetItem.amount = targetItem.amount + canAdd
    sourceItem.amount = sourceItem.amount - canAdd
    
    if sourceItem.amount <= 0 then
        -- Освобождаем ячейки
        for x = sourceItem.posX, sourceItem.posX + itemData.width - 1 do
            for y = sourceItem.posY, sourceItem.posY + itemData.height - 1 do
                self.Grid[x .. "_" .. y] = nil
            end
        end
        self.Items[sourceUniqueID] = nil
        self:SetItemCount(table.Count(self.Items))
    end
    
    return true
end

-- ============================================================================
-- THINK (для времени жизни)
-- ============================================================================

function ENT:Think()
    if self.LifeTime > 0 then
        if CurTime() > self.SpawnTime + self.LifeTime then
            -- Время истекло - удаляем ящик
            self:Remove()
        end
    end
    
    self:NextThink(CurTime() + 5)
    return true
end

-- ============================================================================
-- СЕТЕВЫЕ ОБРАБОТЧИКИ
-- ============================================================================

-- Взять предмет из ящика
netstream.Hook("NextRP::TakeTempCrateItem", function(pPlayer, data)
    local ent = Entity(data.entIndex)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_temp_crate" then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > 200 then return end
    
    local items = ent:GetItems()
    local item = items[data.uniqueID]
    if not item then return end
    
    local success, err = NextRP.Inventory:AddItem(pPlayer, item.itemID, item.amount)
    if success then
        ent:RemoveItem(data.uniqueID, item.amount)
        
        -- Обновляем UI
        netstream.Start(pPlayer, "NextRP::UpdateTempCrate", {
            entIndex = data.entIndex,
            items = ent:GetItems()
        })
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, err or "Не удалось взять предмет")
    end
end)

-- Положить предмет в ящик
netstream.Hook("NextRP::PutTempCrateItem", function(pPlayer, data)
    local ent = Entity(data.entIndex)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_temp_crate" then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > 200 then return end
    
    local charID = NextRP.Inventory:GetCharacterID(pPlayer)
    if not charID then return end
    
    local steamID = pPlayer:SteamID64()
    local storage = data.fromStorage
        and (NextRP.Inventory.PlayerStorages[steamID] and NextRP.Inventory.PlayerStorages[steamID][charID])
        or (NextRP.Inventory.PlayerInventories[steamID] and NextRP.Inventory.PlayerInventories[steamID][charID])
    
    if not storage or not storage.items[data.uniqueID] then return end
    
    local item = storage.items[data.uniqueID]
    
    -- Добавляем в ящик
    local success, result = ent:AddItem(item.itemID, item.amount)
    if success then
        -- Удаляем из инвентаря игрока
        NextRP.Inventory:RemoveItem(pPlayer, data.uniqueID, item.amount, data.fromStorage)
        
        -- Обновляем UI ящика
        netstream.Start(pPlayer, "NextRP::UpdateTempCrate", {
            entIndex = data.entIndex,
            items = ent:GetItems()
        })
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, result or "Не удалось положить предмет")
    end
end)

-- Взять всё из ящика
netstream.Hook("NextRP::TakeAllTempCrate", function(pPlayer, data)
    local ent = Entity(data.entIndex)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_temp_crate" then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > 200 then return end
    
    local items = ent:GetItems()
    if not items or table.Count(items) == 0 then return end
    
    local takenItems = {}
    
    for uniqueID, item in pairs(items) do
        local success, err = NextRP.Inventory:AddItem(pPlayer, item.itemID, item.amount)
        if success then
            table.insert(takenItems, uniqueID)
        end
    end
    
    -- Удаляем взятые предметы
    for _, uniqueID in ipairs(takenItems) do
        ent:RemoveItem(uniqueID)
    end
    
    -- Обновляем UI
    netstream.Start(pPlayer, "NextRP::UpdateTempCrate", {
        entIndex = data.entIndex,
        items = ent:GetItems()
    })
    
    if #takenItems > 0 then
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Забрано предметов: " .. #takenItems)
    end
end)

-- Переместить предмет внутри ящика
netstream.Hook("NextRP::MoveTempCrateItem", function(pPlayer, data)
    local ent = Entity(data.entIndex)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_temp_crate" then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > 200 then return end
    
    local success = ent:MoveItem(data.uniqueID, data.newX, data.newY)
    
    if success then
        -- Обновляем UI
        netstream.Start(pPlayer, "NextRP::UpdateTempCrate", {
            entIndex = data.entIndex,
            items = ent:GetItems()
        })
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Не удалось переместить предмет")
    end
end)

-- Объединить стаки в ящике
netstream.Hook("NextRP::MergeTempCrateStacks", function(pPlayer, data)
    local ent = Entity(data.entIndex)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_temp_crate" then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > 200 then return end
    
    local success = ent:MergeStacks(data.sourceUniqueID, data.targetUniqueID)
    
    if success then
        netstream.Start(pPlayer, "NextRP::UpdateTempCrate", {
            entIndex = data.entIndex,
            items = ent:GetItems()
        })
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Не удалось объединить предметы")
    end
end)

-- ============================================================================
-- АДМИН КОМАНДЫ
-- ============================================================================

concommand.Add("nextrp_spawn_crate", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "У вас нет прав!")
        return
    end
    
    local tr = ply:GetEyeTrace()
    local ent = ents.Create("nextrp_temp_crate")
    
    if not IsValid(ent) then return end
    
    ent:SetPos(tr.HitPos + Vector(0, 0, 20))
    ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
    ent:Spawn()
    ent:Activate()
    
    -- Опциональные параметры
    if args[1] then
        ent:SetCrateName(args[1])
    end
    
    if tonumber(args[2]) and tonumber(args[3]) then
        ent:SetGridWidth(tonumber(args[2]))
        ent:SetGridHeight(tonumber(args[3]))
    end
    
    if tonumber(args[4]) then
        ent.LifeTime = tonumber(args[4])
    end
    
    local msg = "[Crate] Создан временный ящик"
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, msg)
    end
    print(msg)
end)

print("[NextRP] Entity nextrp_temp_crate загружен!")