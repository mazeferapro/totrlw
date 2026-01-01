--[[--
    Серверная часть системы инвентаря
    Модуль: inventory
]]--

AddCSLuaFile("sh_inventory.lua")
AddCSLuaFile("sh_items_weapons.lua")
include("sh_inventory.lua")
include("sh_items_weapons.lua")

NextRP.Inventory.PlayerInventories = {}
NextRP.Inventory.PlayerStorages = {}
NextRP.Inventory.PlayerEquipment = {}
NextRP.Inventory.UnlockedSlots = {}

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ БД
-- ============================================================================

hook.Add("DatabaseInitialized", "NextRP::Inventory_DB_Init", function()
    -- Таблица основного инвентаря
    MySQLite.query([[
        CREATE TABLE IF NOT EXISTS nextrp_inventory (
            character_id INTEGER NOT NULL PRIMARY KEY,
            grid_data TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Таблица личного хранилища
    MySQLite.query([[
        CREATE TABLE IF NOT EXISTS nextrp_storage (
            character_id INTEGER NOT NULL PRIMARY KEY,
            grid_data TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Таблица слотов снаряжения
    MySQLite.query([[
        CREATE TABLE IF NOT EXISTS nextrp_equipment (
            character_id INTEGER NOT NULL,
            slot_type VARCHAR(50) NOT NULL,
            slot_index INTEGER NOT NULL,
            item_data TEXT,
            PRIMARY KEY (character_id, slot_type, slot_index)
        )
    ]])
    
    -- Таблица разблокированных слотов
    MySQLite.query([[
        CREATE TABLE IF NOT EXISTS nextrp_unlocked_slots (
            character_id INTEGER NOT NULL,
            slot_type VARCHAR(50) NOT NULL,
            unlocked_count INTEGER DEFAULT 0,
            PRIMARY KEY (character_id, slot_type)
        )
    ]])
    
    MsgC(Color(0, 255, 0), "[NextRP] Таблицы инвентаря созданы успешно!\n")
end)

-- ============================================================================
-- ЗАГРУЗКА/СОХРАНЕНИЕ ИНВЕНТАРЯ
-- ============================================================================

function NextRP.Inventory:GetCharacterID(pPlayer)
    if not IsValid(pPlayer) then return nil end
    local charID = pPlayer:GetNVar('nrp_charid')
    if not charID or tonumber(charID) <= 0 then return nil end
    return tonumber(charID)
end

function NextRP.Inventory:LoadCharacterInventory(pPlayer, callback)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then 
        if callback then callback(false) end
        return 
    end
    
    local steamID = pPlayer:SteamID64()
    
    -- Загружаем основной инвентарь
    MySQLite.query(string.format("SELECT * FROM nextrp_inventory WHERE character_id = %d", charID), function(result)
        if not IsValid(pPlayer) then return end
        
        local gridData = {}
        if result and result[1] and result[1].grid_data then
            gridData = self:DeserializeInventory(result[1].grid_data)
        end
        
        self.PlayerInventories[steamID] = self.PlayerInventories[steamID] or {}
        self.PlayerInventories[steamID][charID] = {
            grid = gridData.grid or {},
            items = gridData.items or {}
        }
        
        -- Загружаем хранилище
        MySQLite.query(string.format("SELECT * FROM nextrp_storage WHERE character_id = %d", charID), function(storageResult)
            if not IsValid(pPlayer) then return end
            
            local storageData = {}
            if storageResult and storageResult[1] and storageResult[1].grid_data then
                storageData = self:DeserializeInventory(storageResult[1].grid_data)
            end
            
            self.PlayerStorages[steamID] = self.PlayerStorages[steamID] or {}
            self.PlayerStorages[steamID][charID] = {
                grid = storageData.grid or {},
                items = storageData.items or {}
            }
            
            -- Загружаем снаряжение
            MySQLite.query(string.format("SELECT * FROM nextrp_equipment WHERE character_id = %d", charID), function(equipResult)
                if not IsValid(pPlayer) then return end
                
                self.PlayerEquipment[steamID] = self.PlayerEquipment[steamID] or {}
                self.PlayerEquipment[steamID][charID] = {}
                
                if equipResult then
                    for _, row in ipairs(equipResult) do
                        local slotType = row.slot_type
                        local slotIndex = tonumber(row.slot_index)
                        local itemData = util.JSONToTable(row.item_data)
                        
                        self.PlayerEquipment[steamID][charID][slotType] = self.PlayerEquipment[steamID][charID][slotType] or {}
                        self.PlayerEquipment[steamID][charID][slotType][slotIndex] = itemData

                        -- [FIX] Выдаем оружие если оно есть в слоте при загрузке
                        local regItem = self:GetItemData(itemData.itemID)
                        if regItem and regItem.weaponClass then
                            pPlayer:Give(regItem.weaponClass)
                        end
                    end
                end
                
                -- Загружаем разблокированные слоты
                MySQLite.query(string.format("SELECT * FROM nextrp_unlocked_slots WHERE character_id = %d", charID), function(unlockedResult)
                    if not IsValid(pPlayer) then return end
                    
                    self.UnlockedSlots[steamID] = self.UnlockedSlots[steamID] or {}
                    self.UnlockedSlots[steamID][charID] = {}
                    
                    if unlockedResult then
                        for _, row in ipairs(unlockedResult) do
                            self.UnlockedSlots[steamID][charID][row.slot_type] = tonumber(row.unlocked_count) or 0
                        end
                    end
                    
                    -- Отправляем данные клиенту
                    self:SyncInventoryToClient(pPlayer)
                    
                    MsgC(Color(0, 200, 200), "[NextRP] Инвентарь загружен для CharID: " .. charID .. "\n")
                    
                    if callback then callback(true) end
                end)
            end)
        end)
    end)
end

function NextRP.Inventory:SaveCharacterInventory(pPlayer, charID)
    charID = charID or self:GetCharacterID(pPlayer)
    if not IsValid(pPlayer) or not charID then return end
    
    local steamID = pPlayer:SteamID64()
    
    -- Сохраняем основной инвентарь
    local invData = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
    if invData then
        local jsonData = self:SerializeInventory(invData)
        MySQLite.query(string.format(
            "INSERT INTO nextrp_inventory (character_id, grid_data) VALUES (%d, %s) ON DUPLICATE KEY UPDATE grid_data = %s",
            charID,
            MySQLite.SQLStr(jsonData),
            MySQLite.SQLStr(jsonData)
        ))
    end
    
    -- Сохраняем хранилище
    local storageData = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
    if storageData then
        local jsonData = self:SerializeInventory(storageData)
        MySQLite.query(string.format(
            "INSERT INTO nextrp_storage (character_id, grid_data) VALUES (%d, %s) ON DUPLICATE KEY UPDATE grid_data = %s",
            charID,
            MySQLite.SQLStr(jsonData),
            MySQLite.SQLStr(jsonData)
        ))
    end
    
    -- Сохраняем снаряжение
    local equipData = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
    if equipData then
        for slotType, slots in pairs(equipData) do
            for slotIndex, itemData in pairs(slots) do
                if itemData then
                    MySQLite.query(string.format(
                        "INSERT INTO nextrp_equipment (character_id, slot_type, slot_index, item_data) VALUES (%d, %s, %d, %s) ON DUPLICATE KEY UPDATE item_data = %s",
                        charID,
                        MySQLite.SQLStr(slotType),
                        slotIndex,
                        MySQLite.SQLStr(util.TableToJSON(itemData)),
                        MySQLite.SQLStr(util.TableToJSON(itemData))
                    ))
                else
                    MySQLite.query(string.format(
                        "DELETE FROM nextrp_equipment WHERE character_id = %d AND slot_type = %s AND slot_index = %d",
                        charID,
                        MySQLite.SQLStr(slotType),
                        slotIndex
                    ))
                end
            end
        end
    end
    
    -- Сохраняем разблокированные слоты
    local unlockedData = self.UnlockedSlots[steamID] and self.UnlockedSlots[steamID][charID]
    if unlockedData then
        for slotType, count in pairs(unlockedData) do
            MySQLite.query(string.format(
                "INSERT INTO nextrp_unlocked_slots (character_id, slot_type, unlocked_count) VALUES (%d, %s, %d) ON DUPLICATE KEY UPDATE unlocked_count = %d",
                charID,
                MySQLite.SQLStr(slotType),
                count,
                count
            ))
        end
    end
    
    MsgC(Color(0, 255, 0), "[NextRP] Инвентарь сохранён для CharID: " .. charID .. "\n")
end

-- ============================================================================
-- СИНХРОНИЗАЦИЯ С КЛИЕНТОМ
-- ============================================================================

function NextRP.Inventory:SyncInventoryToClient(pPlayer)
    if not IsValid(pPlayer) then return end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return end
    
    local steamID = pPlayer:SteamID64()
    
    local data = {
        inventory = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID] or {grid = {}, items = {}},
        storage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID] or {grid = {}, items = {}},
        equipment = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID] or {},
        unlockedSlots = self.UnlockedSlots[steamID] and self.UnlockedSlots[steamID][charID] or {}
    }
    
    netstream.Start(pPlayer, "NextRP::InventorySync", data)
end

-- ============================================================================
-- УПРАВЛЕНИЕ ИНВЕНТАРЁМ
-- ============================================================================

function NextRP.Inventory:GetPlayerInventory(pPlayer)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return nil end
    
    local steamID = pPlayer:SteamID64()
    return self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
end

function NextRP.Inventory:GetPlayerStorage(pPlayer)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return nil end
    
    local steamID = pPlayer:SteamID64()
    return self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
end

function NextRP.Inventory:GetPlayerEquipment(pPlayer)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return nil end
    
    local steamID = pPlayer:SteamID64()
    return self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
end

-- Добавить предмет в инвентарь
function NextRP.Inventory:AddItem(pPlayer, itemID, amount, targetStorage)
    if not IsValid(pPlayer) then return false, "Игрок не найден" end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false, "Персонаж не загружен" end
    
    local itemData = self:GetItemData(itemID)
    if not itemData then return false, "Предмет не найден" end
    
    amount = amount or 1
    local steamID = pPlayer:SteamID64()
    
    -- Выбираем целевое хранилище
    local storage, gridWidth, gridHeight
    if targetStorage == "storage" then
        storage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
        gridWidth = self.Config.StorageGridWidth
        gridHeight = self.Config.StorageGridHeight
    else
        storage = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
        gridWidth = self.Config.GridWidth
        gridHeight = self.Config.GridHeight
    end
    
    if not storage then
        storage = {grid = {}, items = {}}
        if targetStorage == "storage" then
            self.PlayerStorages[steamID] = self.PlayerStorages[steamID] or {}
            self.PlayerStorages[steamID][charID] = storage
        else
            self.PlayerInventories[steamID] = self.PlayerInventories[steamID] or {}
            self.PlayerInventories[steamID][charID] = storage
        end
    end
    
    -- Если предмет стакается, пробуем добавить к существующим
    if itemData.stackable and amount > 0 then
        for uniqueID, item in pairs(storage.items) do
            if item.itemID == itemID and item.amount < itemData.maxStack then
                local canAdd = math.min(amount, itemData.maxStack - item.amount)
                item.amount = item.amount + canAdd
                amount = amount - canAdd
                
                if amount <= 0 then
                    self:SyncInventoryToClient(pPlayer)
                    self:SaveCharacterInventory(pPlayer, charID)
                    return true
                end
            end
        end
    end
    
    -- Добавляем новые стаки
    while amount > 0 do
        local posX, posY = self:FindFreeSlot(storage.grid, gridWidth, gridHeight, itemData)
        if not posX then
            self:SyncInventoryToClient(pPlayer)
            self:SaveCharacterInventory(pPlayer, charID)
            return false, "Недостаточно места в инвентаре"
        end
        
        local stackAmount = itemData.stackable and math.min(amount, itemData.maxStack) or 1
        local uniqueID = tostring(os.time()) .. "_" .. math.random(10000, 99999)
        
        -- Занимаем ячейки в сетке
        for x = posX, posX + itemData.width - 1 do
            for y = posY, posY + itemData.height - 1 do
                storage.grid[x .. "_" .. y] = uniqueID
            end
        end
        
        -- Добавляем предмет
        storage.items[uniqueID] = {
            itemID = itemID,
            amount = stackAmount,
            posX = posX,
            posY = posY
        }
        
        amount = amount - stackAmount
    end
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    return true
end

-- Удалить предмет из инвентаря
function NextRP.Inventory:RemoveItem(pPlayer, uniqueID, amount, fromStorage)
    if not IsValid(pPlayer) then return false end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false end
    
    local steamID = pPlayer:SteamID64()
    
    local storage
    if fromStorage then
        storage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
    else
        storage = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
    end
    
    if not storage or not storage.items[uniqueID] then return false end
    
    local item = storage.items[uniqueID]
    local itemData = self:GetItemData(item.itemID)
    if not itemData then return false end
    
    amount = amount or item.amount
    
    if item.amount <= amount then
        -- Удаляем полностью
        for x = item.posX, item.posX + itemData.width - 1 do
            for y = item.posY, item.posY + itemData.height - 1 do
                storage.grid[x .. "_" .. y] = nil
            end
        end
        storage.items[uniqueID] = nil
    else
        -- Уменьшаем количество
        item.amount = item.amount - amount
    end
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    return true
end

-- Переместить предмет
function NextRP.Inventory:MoveItem(pPlayer, uniqueID, newPosX, newPosY, fromStorage, toStorage)
    if not IsValid(pPlayer) then return false end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false end
    
    local steamID = pPlayer:SteamID64()
    
    local sourceStorage = fromStorage 
        and (self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID])
        or (self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID])
    
    local targetStorage = toStorage
        and (self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID])
        or (self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID])
    
    if not sourceStorage or not sourceStorage.items[uniqueID] then return false end
    if not targetStorage then return false end
    
    local item = sourceStorage.items[uniqueID]
    local itemData = self:GetItemData(item.itemID)
    if not itemData then return false end
    
    local gridWidth = toStorage and self.Config.StorageGridWidth or self.Config.GridWidth
    local gridHeight = toStorage and self.Config.StorageGridHeight or self.Config.GridHeight
    
    -- Временно освобождаем старые ячейки
    local oldGrid = {}
    for x = item.posX, item.posX + itemData.width - 1 do
        for y = item.posY, item.posY + itemData.height - 1 do
            local key = x .. "_" .. y
            oldGrid[key] = sourceStorage.grid[key]
            sourceStorage.grid[key] = nil
        end
    end
    
    -- Проверяем возможность размещения
    if not self:CanFitItem(targetStorage.grid, gridWidth, gridHeight, itemData, newPosX, newPosY) then
        -- Восстанавливаем старые ячейки
        for key, val in pairs(oldGrid) do
            sourceStorage.grid[key] = val
        end
        return false
    end
    
    -- Если перемещаем между хранилищами
    if sourceStorage ~= targetStorage then
        sourceStorage.items[uniqueID] = nil
    end
    
    -- Занимаем новые ячейки
    for x = newPosX, newPosX + itemData.width - 1 do
        for y = newPosY, newPosY + itemData.height - 1 do
            targetStorage.grid[x .. "_" .. y] = uniqueID
        end
    end
    
    -- Обновляем позицию
    item.posX = newPosX
    item.posY = newPosY
    targetStorage.items[uniqueID] = item
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    return true
end

-- ============================================================================
-- УПРАВЛЕНИЕ СНАРЯЖЕНИЕМ
-- ============================================================================

function NextRP.Inventory:GetUnlockedSlotCount(pPlayer, slotType)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return 0 end
    
    local steamID = pPlayer:SteamID64()
    local config = self.Config.EquipmentSlots[slotType]
    if not config then return 0 end
    
    local unlocked = self.UnlockedSlots[steamID] and self.UnlockedSlots[steamID][charID] and self.UnlockedSlots[steamID][charID][slotType] or 0
    return config.free + unlocked
end

function NextRP.Inventory:UnlockEquipmentSlot(pPlayer, slotType)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false, "Персонаж не загружен" end
    
    local steamID = pPlayer:SteamID64()
    local config = self.Config.EquipmentSlots[slotType]
    if not config then return false, "Неизвестный тип слота" end
    
    local currentUnlocked = self:GetUnlockedSlotCount(pPlayer, slotType)
    if currentUnlocked >= config.total then
        return false, "Все слоты уже разблокированы"
    end
    
    -- Проверяем деньги персонажа
    local money = pPlayer:GetNVar('nrp_money') or 0
    if money < config.costPerSlot then
        return false, "Недостаточно денег (нужно " .. config.costPerSlot .. " кредитов)"
    end
    
    -- Снимаем деньги
    local char = pPlayer:CharacterByID(charID)
    if char then
        pPlayer:SetCharValue('money', money - config.costPerSlot, function()
            char.money = money - config.costPerSlot
            pPlayer:SetNVar('nrp_money', char.money, NETWORK_PROTOCOL_PUBLIC)
        end)
    end
    
    -- Разблокируем слот
    self.UnlockedSlots[steamID] = self.UnlockedSlots[steamID] or {}
    self.UnlockedSlots[steamID][charID] = self.UnlockedSlots[steamID][charID] or {}
    self.UnlockedSlots[steamID][charID][slotType] = (self.UnlockedSlots[steamID][charID][slotType] or 0) + 1
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    
    return true
end

function NextRP.Inventory:EquipItem(pPlayer, uniqueID, slotType, slotIndex, fromStorage)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false end
    
    local steamID = pPlayer:SteamID64()
    
    local source = fromStorage
        and (self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID])
        or (self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID])
    
    if not source or not source.items[uniqueID] then 
        print("[Inventory] EquipItem: предмет не найден", uniqueID)
        return false 
    end
    
    local item = source.items[uniqueID]
    local itemData = self:GetItemData(item.itemID)
    if not itemData then 
        print("[Inventory] EquipItem: itemData не найден для", item.itemID)
        return false 
    end
    
    -- Проверяем тип слота
    if itemData.slotType ~= slotType then 
        print("[Inventory] EquipItem: неверный тип слота", itemData.slotType, "!=", slotType)
        return false 
    end
    
    -- Проверяем доступность слота
    local unlockedCount = self:GetUnlockedSlotCount(pPlayer, slotType)
    if slotIndex > unlockedCount then 
        print("[Inventory] EquipItem: слот заблокирован", slotIndex, ">", unlockedCount)
        return false 
    end
    
    -- Сохраняем данные предмета ДО удаления
    local savedItemID = item.itemID
    local savedAmount = item.amount or 1
    
    -- Инициализируем снаряжение если нужно
    self.PlayerEquipment[steamID] = self.PlayerEquipment[steamID] or {}
    self.PlayerEquipment[steamID][charID] = self.PlayerEquipment[steamID][charID] or {}
    self.PlayerEquipment[steamID][charID][slotType] = self.PlayerEquipment[steamID][charID][slotType] or {}
    
    -- Если слот занят, возвращаем предмет в инвентарь
    local currentItem = self.PlayerEquipment[steamID][charID][slotType][slotIndex]
    if currentItem then
        local success, err = self:AddItem(pPlayer, currentItem.itemID, currentItem.amount or 1)
        if not success then
            print("[Inventory] EquipItem: не удалось вернуть предмет из слота", err)
            return false
        end
    end
    
    -- Удаляем предмет из инвентаря/хранилища (освобождаем ячейки)
    local itemDataForSize = self:GetItemData(savedItemID)
    if source.items[uniqueID] then
        -- Освобождаем ячейки
        for x = item.posX, item.posX + (itemDataForSize.width or 1) - 1 do
            for y = item.posY, item.posY + (itemDataForSize.height or 1) - 1 do
                source.grid[x .. "_" .. y] = nil
            end
        end
        -- Удаляем из списка предметов
        source.items[uniqueID] = nil
    end
    
    -- Экипируем сохранённые данные
    self.PlayerEquipment[steamID][charID][slotType][slotIndex] = {
        itemID = savedItemID,
        amount = savedAmount
    }
    
    print("[Inventory] EquipItem: успешно экипирован", savedItemID, "в слот", slotType, slotIndex)

    if itemDataForSize.weaponClass then
    pPlayer:Give(itemDataForSize.weaponClass)
    -- Опционально: можно сразу переключиться на него
    -- pPlayer:SelectWeapon(itemDataForSize.weaponClass) 
    end
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    
    return true
end

function NextRP.Inventory:UnequipItem(pPlayer, slotType, slotIndex)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false end
    
    local steamID = pPlayer:SteamID64()
    
    -- Получаем текущую экипировку
    local equip = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
    if not equip or not equip[slotType] or not equip[slotType][slotIndex] then return false end
    
    local item = equip[slotType][slotIndex]
    local itemData = self:GetItemData(item.itemID)
    
    -- 1. Пробуем добавить предмет обратно в инвентарь
    -- (AddItem сам сохранит изменения в инвентаре)
    local success, err = self:AddItem(pPlayer, item.itemID, item.amount)
    
    if success then
        -- 2. Если предмет успешно добавлен в инвентарь, ЗАБИРАЕМ оружие из рук
        if itemData and itemData.weaponClass then
            pPlayer:StripWeapon(itemData.weaponClass)
        end
        
        -- 3. [ВАЖНО] Прямое удаление из базы данных
        -- Мы делаем это вручную, так как SaveCharacterInventory игнорирует удаленные ключи (nil)
        MySQLite.query(string.format(
            "DELETE FROM nextrp_equipment WHERE character_id = %d AND slot_type = %s AND slot_index = %d",
            charID,
            MySQLite.SQLStr(slotType),
            slotIndex
        ))

        -- 4. Удаляем предмет из памяти сервера
        equip[slotType][slotIndex] = nil
        
        -- 5. Синхронизируем изменения с клиентом (чтобы слот визуально освободился)
        self:SyncInventoryToClient(pPlayer)
        
        print("[Inventory] Предмет снят, удален из БД и перемещен в инвентарь:", slotType, slotIndex)
        return true
    else
        -- Если места в инвентаре нет
        pPlayer:ChatPrint("Не удалось снять предмет: " .. (err or "нет места"))
        return false
    end
end
-- ============================================================================
-- ВЫБРОС ПРЕДМЕТОВ
-- ============================================================================

function NextRP.Inventory:DropItem(pPlayer, uniqueID, fromStorage)
    if not IsValid(pPlayer) then return false end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false end
    
    local steamID = pPlayer:SteamID64()
    
    local storage = fromStorage
        and (self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID])
        or (self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID])
    
    if not storage or not storage.items[uniqueID] then return false end
    
    local item = storage.items[uniqueID]
    local itemData = self:GetItemData(item.itemID)
    if not itemData or not itemData.canDrop then return false end
    
    -- Создаём entity выброшенного предмета
    local ent = ents.Create("nextrp_dropitem")
    if not IsValid(ent) then return false end
    
    local tr = pPlayer:GetEyeTrace()
    local pos = tr.HitPos + tr.HitNormal * 10
    
    ent:SetPos(pos)
    ent:SetAngles(Angle(0, math.random(0, 360), 0))
    ent:Spawn()
    ent:Activate()
    
    ent:SetItemData(item.itemID, item.amount)
    ent:SetDroppedBy(pPlayer:SteamID64())
    
    -- Удаляем из инвентаря
    self:RemoveItem(pPlayer, uniqueID, item.amount, fromStorage)
    
    return true
end

function NextRP.Inventory:DropAllItems(pPlayer, deathPos)
    if not IsValid(pPlayer) then return end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then 
        print("[Inventory] DropAllItems: нет персонажа")
        return 
    end
    
    local steamID = pPlayer:SteamID64()
    local inventory = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
    
    if not inventory then 
        print("[Inventory] DropAllItems: инвентарь не найден")
        return 
    end
    
    -- Собираем все предметы
    local itemsCopy = {}
    local hasItems = false
    
    -- Копируем предметы из инвентаря
    if inventory.items then
        for uniqueID, item in pairs(inventory.items) do
            itemsCopy[uniqueID] = table.Copy(item)
            hasItems = true
        end
    end
    
    -- Копируем экипировку
    local equip = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
    if equip then
        for slotType, slots in pairs(equip) do
            for slotIndex, item in pairs(slots) do
                if item and item.itemID then
                    local equipUniqueID = "equip_" .. slotType .. "_" .. slotIndex
                    itemsCopy[equipUniqueID] = table.Copy(item)
                    hasItems = true
                end
            end
        end
    end
    
    -- Если нет предметов - не создаём сумку
    if not hasItems then
        print("[Inventory] DropAllItems: нет предметов для выброса")
        return
    end
    
    print("[Inventory] DropAllItems: выбрасываем", table.Count(itemsCopy), "предметов")
    
    -- Создаём контейнер с предметами
    local ent = ents.Create("nextrp_deadbug")
    if not IsValid(ent) then 
        print("[Inventory] DropAllItems: не удалось создать entity")
        return 
    end
    
    ent:SetPos(deathPos + Vector(0, 0, 20))
    ent:Spawn()
    ent:Activate()
    
    ent:SetItems(itemsCopy)
    ent:SetOwnerSteamID(steamID)
    ent:SetItemCount(table.Count(itemsCopy))
    
    print("[Inventory] DropAllItems: сумка создана на позиции", deathPos)
    
    -- Очищаем инвентарь игрока
    if inventory then
        inventory.grid = {}
        inventory.items = {}
    end
    
    -- Очищаем экипировку
    if self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID] then
        self.PlayerEquipment[steamID][charID] = {}
    end
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
end

-- ============================================================================
-- ХУКИ
-- ============================================================================

hook.Add("NextRP::CharacterSelected", "NextRP::Inventory_OnCharSelected", function(pPlayer, newCharID, oldCharID)
    if not IsValid(pPlayer) then return end
    
    -- Сохраняем инвентарь старого персонажа
    if oldCharID and tonumber(oldCharID) > 0 then
        NextRP.Inventory:SaveCharacterInventory(pPlayer, tonumber(oldCharID))
    end
    
    -- Загружаем инвентарь нового персонажа
    timer.Simple(0.5, function()
        if IsValid(pPlayer) then
            NextRP.Inventory:LoadCharacterInventory(pPlayer)
        end
    end)
end)

hook.Add("PlayerDisconnected", "NextRP::Inventory_OnDisconnect", function(pPlayer)
    if not IsValid(pPlayer) then return end
    NextRP.Inventory:SaveCharacterInventory(pPlayer)
end)

hook.Add("PlayerDeath", "NextRP::Inventory_OnDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end
    
    -- Проверяем есть ли у игрока персонаж
    local charID = NextRP.Inventory:GetCharacterID(victim)
    if not charID then return end
    
    print("[Inventory] Игрок погиб:", victim:Nick(), "CharID:", charID)
    
    -- Небольшая задержка чтобы избежать конфликтов
    timer.Simple(0.1, function()
        if IsValid(victim) then
            NextRP.Inventory:DropAllItems(victim, victim:GetPos())
        end
    end)
end)

-- ============================================================================
-- СЕТЕВЫЕ ОБРАБОТЧИКИ
-- ============================================================================

netstream.Hook("NextRP::InventoryMoveItem", function(pPlayer, data)
    NextRP.Inventory:MoveItem(pPlayer, data.uniqueID, data.newX, data.newY, data.fromStorage, data.toStorage)
end)

netstream.Hook("NextRP::InventoryDropItem", function(pPlayer, data)
    NextRP.Inventory:DropItem(pPlayer, data.uniqueID, data.fromStorage)
end)

netstream.Hook("NextRP::InventoryEquipItem", function(pPlayer, data)
    NextRP.Inventory:EquipItem(pPlayer, data.uniqueID, data.slotType, data.slotIndex, data.fromStorage)
end)

netstream.Hook("NextRP::InventoryUnequipItem", function(pPlayer, data)
    NextRP.Inventory:UnequipItem(pPlayer, data.slotType, data.slotIndex)
end)

netstream.Hook("NextRP::InventoryUseItem", function(pPlayer, data)
    local charID = NextRP.Inventory:GetCharacterID(pPlayer)
    if not charID then return end
    
    local steamID = pPlayer:SteamID64()
    local storage = data.fromStorage
        and (NextRP.Inventory.PlayerStorages[steamID] and NextRP.Inventory.PlayerStorages[steamID][charID])
        or (NextRP.Inventory.PlayerInventories[steamID] and NextRP.Inventory.PlayerInventories[steamID][charID])
    
    if not storage or not storage.items[data.uniqueID] then return end
    
    local item = storage.items[data.uniqueID]
    local itemData = NextRP.Inventory:GetItemData(item.itemID)
    
    if itemData and itemData.onUse then
        local success = itemData.onUse(pPlayer, item)
        if success then
            NextRP.Inventory:RemoveItem(pPlayer, data.uniqueID, 1, data.fromStorage)
        end
    end
end)

netstream.Hook("NextRP::InventoryUnlockSlot", function(pPlayer, slotType)
    local success, err = NextRP.Inventory:UnlockEquipmentSlot(pPlayer, slotType)
    if not success then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, err)
    else
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Слот разблокирован!")
    end
end)

netstream.Hook("NextRP::InventoryPickupItem", function(pPlayer, entIndex)
    local ent = Entity(entIndex)
    if not IsValid(ent) then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > NextRP.Inventory.Config.PickupRadius then return end
    
    if ent:GetClass() == "nextrp_dropped_item" then
        local itemID = ent:GetItemID()
        local amount = ent:GetItemAmount()
        
        local success, err = NextRP.Inventory:AddItem(pPlayer, itemID, amount)
        if success then
            ent:Remove()
        else
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, err or "Не удалось подобрать предмет")
        end
    elseif ent:GetClass() == "nextrp_deadbug" then
        -- Открываем интерфейс сумки смерти
        netstream.Start(pPlayer, "NextRP::OpenDeathBag", {
            entIndex = entIndex,
            items = ent:GetItems()
        })
    end
end)

netstream.Hook("NextRP::InventoryTakeFromBag", function(pPlayer, data)
    local ent = Entity(data.entIndex)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_deadbug" then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > NextRP.Inventory.Config.PickupRadius then return end
    
    local items = ent:GetItems()
    local item = items[data.uniqueID]
    if not item then return end
    
    local success, err = NextRP.Inventory:AddItem(pPlayer, item.itemID, item.amount)
    if success then
        items[data.uniqueID] = nil
        
        -- Если энтити существует, обновляем в ней данные
        if IsValid(ent) and ent.SetItems then
            ent:SetItems(items)
        end
        
        -- Проверяем, остался ли что-то в сумке
        if table.Count(items) == 0 then
            -- [ВАЖНО] Удаляем сумку
            if IsValid(ent) then ent:Remove() end
            
            -- [ВАЖНО] Отправляем клиенту пустую таблицу, чтобы он закрыл окно (см. код клиента выше)
            netstream.Start(pPlayer, "NextRP::UpdateDeathBag", {
                entIndex = data.entIndex,
                items = {} 
            })
        else
            -- Если предметы еще есть, просто обновляем UI
            netstream.Start(pPlayer, "NextRP::UpdateDeathBag", {
                entIndex = data.entIndex,
                items = items
            })
        end
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, err or "Не удалось подобрать предмет")
    end
end)

netstream.Hook("NextRP::RequestInventoryOpen", function(pPlayer)
    NextRP.Inventory:SyncInventoryToClient(pPlayer)
end)

print("[NextRP] Модуль инвентаря (server) загружен!")

-- ============================================================================
-- КОНСОЛЬНЫЕ КОМАНДЫ АДМИНИСТРАТОРА
-- ============================================================================

-- Выдать предмет игроку: nextrp_giveitem <steamid/name> <item_id> [amount]
concommand.Add("nextrp_giveitem", function(ply, cmd, args)
    -- Проверка прав (только консоль или суперадмин)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Inventory] У вас нет прав для этой команды!")
        return
    end
    
    if #args < 2 then
        local msg = [[
[NextRP Inventory] Использование команд:
  nextrp_giveitem <steamid/name> <item_id> [amount] - выдать предмет игроку
  nextrp_removeitem <steamid/name> <unique_id> [amount] - удалить предмет у игрока
  nextrp_clearinv <steamid/name> - очистить инвентарь игрока
  nextrp_listinv <steamid/name> - показать инвентарь игрока
  nextrp_listitems - показать все зарегистрированные предметы
        ]]
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local target = args[1]
    local itemID = args[2]
    local amount = tonumber(args[3]) or 1
    
    -- Находим игрока
    local targetPly = nil
    for _, p in ipairs(player.GetAll()) do
        if p:SteamID() == target or p:SteamID64() == target or string.find(string.lower(p:Nick()), string.lower(target), 1, true) then
            targetPly = p
            break
        end
    end
    
    if not IsValid(targetPly) then
        local msg = "[Inventory] Игрок не найден: " .. target
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    -- Проверяем существует ли предмет
    local itemData = NextRP.Inventory:GetItemData(itemID)
    if not itemData then
        local msg = "[Inventory] Предмет не найден: " .. itemID
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    -- Выдаём предмет
    local success, err = NextRP.Inventory:AddItem(targetPly, itemID, amount)
    
    local msg
    if success then
        msg = string.format("[Inventory] Выдано %s x%d игроку %s", itemData.name, amount, targetPly:Nick())
        targetPly:ChatPrint("Вы получили: " .. itemData.name .. " x" .. amount)
    else
        msg = "[Inventory] Ошибка выдачи: " .. (err or "неизвестная ошибка")
    end
    
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, msg)
    else
        print(msg)
    end
end)

-- Показать все зарегистрированные предметы
concommand.Add("nextrp_listitems", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Inventory] У вас нет прав для этой команды!")
        return
    end
    
    local msg = "\n[NextRP Inventory] Зарегистрированные предметы:\n"
    msg = msg .. string.rep("-", 60) .. "\n"
    msg = msg .. string.format("%-25s %-15s %-10s %s\n", "ID", "Тип слота", "Размер", "Название")
    msg = msg .. string.rep("-", 60) .. "\n"
    
    for id, item in pairs(NextRP.Inventory.Items) do
        local slotType = item.slotType or "-"
        local size = item.width .. "x" .. item.height
        msg = msg .. string.format("%-25s %-15s %-10s %s\n", id, slotType, size, item.name)
    end
    
    msg = msg .. string.rep("-", 60) .. "\n"
    msg = msg .. "Всего предметов: " .. table.Count(NextRP.Inventory.Items) .. "\n"
    
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, msg)
    else
        print(msg)
    end
end)

-- Показать инвентарь игрока
concommand.Add("nextrp_listinv", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Inventory] У вас нет прав для этой команды!")
        return
    end
    
    if #args < 1 then
        local msg = "[Inventory] Использование: nextrp_listinv <steamid/name>"
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local target = args[1]
    local targetPly = nil
    
    for _, p in ipairs(player.GetAll()) do
        if p:SteamID() == target or p:SteamID64() == target or string.find(string.lower(p:Nick()), string.lower(target), 1, true) then
            targetPly = p
            break
        end
    end
    
    if not IsValid(targetPly) then
        local msg = "[Inventory] Игрок не найден: " .. target
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local steamID = targetPly:SteamID64()
    local charID = NextRP.Inventory:GetCharacterID(targetPly)
    
    if not charID then
        local msg = "[Inventory] У игрока нет активного персонажа"
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local inventory = NextRP.Inventory.PlayerInventories[steamID] and NextRP.Inventory.PlayerInventories[steamID][charID]
    
    local msg = string.format("\n[NextRP Inventory] Инвентарь игрока %s (CharID: %d):\n", targetPly:Nick(), charID)
    msg = msg .. string.rep("-", 70) .. "\n"
    msg = msg .. string.format("%-15s %-25s %-10s %-10s\n", "UniqueID", "Предмет", "Кол-во", "Позиция")
    msg = msg .. string.rep("-", 70) .. "\n"
    
    local count = 0
    if inventory and inventory.items then
        for uniqueID, item in pairs(inventory.items) do
            local itemData = NextRP.Inventory:GetItemData(item.itemID)
            local name = itemData and itemData.name or item.itemID
            msg = msg .. string.format("%-15s %-25s %-10d (%d,%d)\n", uniqueID, name, item.amount or 1, item.posX or 0, item.posY or 0)
            count = count + 1
        end
    end
    
    if count == 0 then
        msg = msg .. "Инвентарь пуст\n"
    end
    
    msg = msg .. string.rep("-", 70) .. "\n"
    msg = msg .. "Всего предметов: " .. count .. "\n"
    
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, msg)
    else
        print(msg)
    end
end)

-- Удалить предмет у игрока
concommand.Add("nextrp_removeitem", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Inventory] У вас нет прав для этой команды!")
        return
    end
    
    if #args < 2 then
        local msg = "[Inventory] Использование: nextrp_removeitem <steamid/name> <unique_id> [amount]"
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local target = args[1]
    local uniqueID = args[2]
    local amount = tonumber(args[3])
    
    local targetPly = nil
    for _, p in ipairs(player.GetAll()) do
        if p:SteamID() == target or p:SteamID64() == target or string.find(string.lower(p:Nick()), string.lower(target), 1, true) then
            targetPly = p
            break
        end
    end
    
    if not IsValid(targetPly) then
        local msg = "[Inventory] Игрок не найден: " .. target
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local success = NextRP.Inventory:RemoveItem(targetPly, uniqueID, amount)
    
    local msg
    if success then
        msg = string.format("[Inventory] Предмет %s удалён у игрока %s", uniqueID, targetPly:Nick())
    else
        msg = "[Inventory] Не удалось удалить предмет"
    end
    
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, msg)
    else
        print(msg)
    end
end)

-- Очистить инвентарь игрока
concommand.Add("nextrp_clearinv", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Inventory] У вас нет прав для этой команды!")
        return
    end
    
    if #args < 1 then
        local msg = "[Inventory] Использование: nextrp_clearinv <steamid/name>"
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local target = args[1]
    local targetPly = nil
    
    for _, p in ipairs(player.GetAll()) do
        if p:SteamID() == target or p:SteamID64() == target or string.find(string.lower(p:Nick()), string.lower(target), 1, true) then
            targetPly = p
            break
        end
    end
    
    if not IsValid(targetPly) then
        local msg = "[Inventory] Игрок не найден: " .. target
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    local steamID = targetPly:SteamID64()
    local charID = NextRP.Inventory:GetCharacterID(targetPly)
    
    if not charID then
        local msg = "[Inventory] У игрока нет активного персонажа"
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    -- Очищаем инвентарь
    NextRP.Inventory.PlayerInventories[steamID] = NextRP.Inventory.PlayerInventories[steamID] or {}
    NextRP.Inventory.PlayerInventories[steamID][charID] = {grid = {}, items = {}}
    
    NextRP.Inventory:SyncInventoryToClient(targetPly)
    NextRP.Inventory:SaveCharacterInventory(targetPly, charID)
    
    local msg = string.format("[Inventory] Инвентарь игрока %s очищен", targetPly:Nick())
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, msg)
    else
        print(msg)
    end
    
    targetPly:ChatPrint("Ваш инвентарь был очищен администратором")
end)

-- Выдать предмет по itemID (альтернативная команда с более коротким синтаксисом)
concommand.Add("inv_give", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Inventory] У вас нет прав для этой команды!")
        return
    end
    
    if #args < 2 then
        local msg = "[Inventory] Использование: inv_give <steamid/name> <item_id> [amount]"
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, msg)
        else
            print(msg)
        end
        return
    end
    
    -- Перенаправляем на основную команду
    RunConsoleCommand("nextrp_giveitem", unpack(args))
end)