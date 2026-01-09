--[[--
    Серверная часть системы инвентаря
    Модуль: inventory
]]--

AddCSLuaFile("sh_inventory.lua")
include("sh_inventory.lua")

NextRP.Inventory.PlayerInventories = {}
NextRP.Inventory.PlayerStorages = {}
NextRP.Inventory.PlayerEquipment = {}
NextRP.Inventory.UnlockedSlots = {}

-- Проверка может ли игрок взаимодействовать с сумкой смерти
local function CanInteractWithDeathBag(pPlayer, ent)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_deadbug" then
        return false, "Недействительная сумка"
    end
    
    -- Проверяем по ID персонажа
    local ownerCharID = ent:GetOwnerCharID()
    if ownerCharID and ownerCharID > 0 then
        local playerCharID = pPlayer:GetNVar('nrp_charid')
        if not playerCharID or playerCharID ~= ownerCharID then
            return false, "Это не сумка вашего персонажа!"
        end
    end
    
    return true
end

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
                        
                        if itemData then
                            self.PlayerEquipment[steamID][charID][slotType] = self.PlayerEquipment[steamID][charID][slotType] or {}
                            self.PlayerEquipment[steamID][charID][slotType][slotIndex] = itemData
                        end
                    end
                end

                -- Загружаем разблокированные слоты
                MySQLite.query(string.format("SELECT * FROM nextrp_unlocked_slots WHERE character_id = %d", charID), function(unlockedResult)
                    if not IsValid(pPlayer) then return end
                    
                    -- [FIX] Проверяем что персонаж не сменился
                    local currentCharID = self:GetCharacterID(pPlayer)
                    if currentCharID ~= charID then
                        MsgC(Color(255, 0, 0), "[NextRP] Inventory Load ABORTED: Character changed! Expected: " .. charID .. ", Got: " .. tostring(currentCharID) .. "\n")
                        if callback then callback(false) end
                        return
                    end
                    
                    self.UnlockedSlots[steamID] = self.UnlockedSlots[steamID] or {}
                    self.UnlockedSlots[steamID][charID] = {}
                    
                    if unlockedResult then
                        for _, row in ipairs(unlockedResult) do
                            self.UnlockedSlots[steamID][charID][row.slot_type] = tonumber(row.unlocked_count) or 0
                        end
                    end
                    
                    -- [FIX] Выдаём оружие ПОСЛЕ полной загрузки
                    local equipData = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
                    if equipData then
                        for slotType, slots in pairs(equipData) do
                            for slotIndex, itemData in pairs(slots) do
                                if itemData and itemData.itemID then
                                    local regItem = self:GetItemData(itemData.itemID)
                                    if regItem and regItem.weaponClass then
                                        if not pPlayer:HasWeapon(regItem.weaponClass) then
                                            pPlayer:Give(regItem.weaponClass)
                                            MsgC(Color(0, 255, 0), "[NextRP] Gave weapon: " .. regItem.weaponClass .. "\n")
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Отправляем данные клиенту
                    self:SyncInventoryToClient(pPlayer)
                    
                    -- [FIX] Снимаем флаг загрузки
                    pPlayer.NextRP_Inventory_IsLoading = false
                    
                    MsgC(Color(0, 200, 200), "[NextRP] Инвентарь загружен для CharID: " .. charID .. "\n")
                    NextRP.Inventory.CachedCharID[steamID] = charID
                    
                    if callback then callback(true) end
                end)
            end)
        end)
    end)
    timer.Simple(0.5, function()
        if IsValid(pPlayer) then
            local weapons = {}
            for _, wep in pairs(pPlayer:GetWeapons()) do
                if IsValid(wep) then
                    weapons[wep:GetClass()] = true
                end
            end
            NextRP.Inventory.TrackedWeapons[steamID] = weapons
            MsgC(Color(0, 255, 0), "[NextRP] Weapon tracking initialized with " .. table.Count(weapons) .. " weapons\n")
        end
    end)
end

function NextRP.Inventory:SaveCharacterInventory(pPlayer, charID)
    charID = charID or self:GetCharacterID(pPlayer)
    if not IsValid(pPlayer) or not charID then return end
    
    local steamID = pPlayer:SteamID64()
    
    -- [FIX] Не сохраняем во время загрузки
    if pPlayer.NextRP_Inventory_IsLoading then
        MsgC(Color(255, 200, 0), "[NextRP] Inventory Save BLOCKED: Loading in progress for CharID: " .. charID .. "\n")
        return
    end
    
    -- [FIX] Проверяем что данные вообще существуют в памяти
    local hasData = (self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]) or
                    (self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID])
    
    if not hasData then
        MsgC(Color(255, 0, 0), "[NextRP] Inventory Save BLOCKED: No data in memory for CharID: " .. charID .. " (preventing data loss)\n")
        return
    end
    
    -- [FIX] Логируем что сохраняем
    MsgC(Color(255, 255, 0), "[NextRP DEBUG] SaveCharacterInventory called for CharID: " .. tostring(charID) .. "\n")
    MsgC(Color(255, 255, 0), "[NextRP DEBUG] IsLoading: " .. tostring(pPlayer.NextRP_Inventory_IsLoading) .. "\n")

    local equipData = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
    if equipData then
        local count = 0
        for slotType, slots in pairs(equipData) do
            for slotIndex, item in pairs(slots) do
                if item then 
                    count = count + 1 
                    MsgC(Color(0, 255, 0), "[NextRP DEBUG] Equipment slot " .. slotType .. "[" .. slotIndex .. "]: " .. tostring(item.itemID) .. "\n")
                end
            end
        end
        MsgC(Color(0, 255, 0), "[NextRP DEBUG] Total equipment items: " .. count .. "\n")
    else
        MsgC(Color(255, 0, 0), "[NextRP DEBUG] NO EQUIPMENT DATA IN MEMORY!\n")
    end
    
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
    
    -- [FIX] Сохраняем снаряжение - ТОЛЬКО реальные предметы, БЕЗ DELETE для nil
    if equipData then
        for slotType, slots in pairs(equipData) do
            for slotIndex, itemData in pairs(slots) do
                -- [FIX] Сохраняем ТОЛЬКО если есть данные, НЕ удаляем nil
                if itemData and itemData.itemID then
                    MySQLite.query(string.format(
                        "INSERT INTO nextrp_equipment (character_id, slot_type, slot_index, item_data) VALUES (%d, %s, %d, %s) ON DUPLICATE KEY UPDATE item_data = %s",
                        charID,
                        MySQLite.SQLStr(slotType),
                        slotIndex,
                        MySQLite.SQLStr(util.TableToJSON(itemData)),
                        MySQLite.SQLStr(util.TableToJSON(itemData))
                    ))
                end
            end
        end
    end
    
    -- Сохраняем разблокированные слоты (без изменений)
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
    
    -- ============================================
    -- ИСПРАВЛЕНИЕ: ПРОВЕРКА НА ДУБЛИКАТЫ
    -- Нельзя экипировать одинаковые предметы в разные слоты
    -- ============================================
    self.PlayerEquipment[steamID] = self.PlayerEquipment[steamID] or {}
    self.PlayerEquipment[steamID][charID] = self.PlayerEquipment[steamID][charID] or {}
    self.PlayerEquipment[steamID][charID][slotType] = self.PlayerEquipment[steamID][charID][slotType] or {}
    
    local equip = self.PlayerEquipment[steamID][charID]
    if equip[slotType] then
        for existingSlotIndex, existingItem in pairs(equip[slotType]) do
            if existingItem and existingItem.itemID == item.itemID then
                -- Проверяем что это не тот же самый слот
                if tonumber(existingSlotIndex) ~= tonumber(slotIndex) then
                    print("[Inventory] EquipItem: предмет уже экипирован в слоте", existingSlotIndex)
                    if pPlayer.SendMessage then
                        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Этот предмет уже экипирован!")
                    else
                        pPlayer:ChatPrint("Этот предмет уже экипирован!")
                    end
                    return false
                end
            end
        end
    end
    -- ============================================
    
    -- Сохраняем данные предмета ДО удаления
    local savedItemID = item.itemID
    local savedAmount = item.amount or 1
    
    -- Если слот занят, возвращаем предмет в инвентарь
    local currentItem = equip[slotType][slotIndex]
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
    equip[slotType][slotIndex] = {
        itemID = savedItemID,
        amount = savedAmount
    }
    
    print("[Inventory] EquipItem: успешно экипирован", savedItemID, "в слот", slotType, slotIndex)

    if itemDataForSize.weaponClass then
        pPlayer:Give(itemDataForSize.weaponClass)
    end
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    
    return true
end

function NextRP.Inventory:UnequipItem(pPlayer, slotType, slotIndex)
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false end
    
    local steamID = pPlayer:SteamID64()
    
    local equip = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
    if not equip or not equip[slotType] or not equip[slotType][slotIndex] then return false end
    
    local item = equip[slotType][slotIndex]
    local itemData = self:GetItemData(item.itemID)
    
    -- Пробуем добавить в инвентарь
    local success, err = self:AddItem(pPlayer, item.itemID, item.amount)
    if not success then 
        pPlayer:ChatPrint("Не удалось снять предмет: " .. (err or "нет места"))
        return false, err 
    end
    
    -- Забираем оружие из рук
    if itemData and itemData.weaponClass then
        pPlayer:StripWeapon(itemData.weaponClass)
    end

    -- [FIX] Убираем из памяти
    equip[slotType][slotIndex] = nil
    
    -- [FIX] Явно удаляем из БД сразу
    MySQLite.query(string.format(
        "DELETE FROM nextrp_equipment WHERE character_id = %d AND slot_type = %s AND slot_index = %d",
        charID,
        MySQLite.SQLStr(slotType),
        slotIndex
    ))
    
    self:SyncInventoryToClient(pPlayer)
    -- [FIX] НЕ вызываем SaveCharacterInventory здесь - мы уже удалили из БД напрямую
    
    return true
end

function NextRP.Inventory:MergeStacks(pPlayer, sourceUniqueID, targetUniqueID, fromStorage, toStorage)
    if not IsValid(pPlayer) then return false, "Игрок не найден" end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false, "Персонаж не загружен" end
    
    local steamID = pPlayer:SteamID64()
    
    -- Получаем источник
    local sourceStorage
    if fromStorage then
        sourceStorage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
    else
        sourceStorage = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
    end
    
    -- Получаем цель
    local targetStorage
    if toStorage then
        targetStorage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
    else
        targetStorage = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
    end
    
    if not sourceStorage or not sourceStorage.items[sourceUniqueID] then
        return false, "Исходный предмет не найден"
    end
    
    if not targetStorage or not targetStorage.items[targetUniqueID] then
        return false, "Целевой предмет не найден"
    end
    
    local sourceItem = sourceStorage.items[sourceUniqueID]
    local targetItem = targetStorage.items[targetUniqueID]
    
    -- Проверяем что это одинаковые предметы
    if sourceItem.itemID ~= targetItem.itemID then
        return false, "Разные типы предметов"
    end
    
    local itemData = self:GetItemData(sourceItem.itemID)
    if not itemData then return false, "Данные предмета не найдены" end
    
    -- Проверяем стакаемость
    if not itemData.stackable then
        return false, "Этот предмет нельзя складывать"
    end
    
    local maxStack = itemData.maxStack or 99
    
    -- Проверяем есть ли место в целевом стаке
    if targetItem.amount >= maxStack then
        return false, "Целевой стак полон"
    end
    
    -- Рассчитываем сколько можем добавить
    local canAdd = math.min(sourceItem.amount, maxStack - targetItem.amount)
    
    -- Добавляем к целевому стаку
    targetItem.amount = targetItem.amount + canAdd
    
    -- Убираем из исходного
    sourceItem.amount = sourceItem.amount - canAdd
    
    -- Если исходный стак опустел, удаляем его
    if sourceItem.amount <= 0 then
        -- Освобождаем ячейки
        for x = sourceItem.posX, sourceItem.posX + itemData.width - 1 do
            for y = sourceItem.posY, sourceItem.posY + itemData.height - 1 do
                sourceStorage.grid[x .. "_" .. y] = nil
            end
        end
        sourceStorage.items[sourceUniqueID] = nil
    end
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    
    return true
end

netstream.Hook("NextRP::InventoryMergeStacks", function(pPlayer, data)
    local success, err = NextRP.Inventory:MergeStacks(
        pPlayer, 
        data.sourceUniqueID, 
        data.targetUniqueID, 
        data.fromStorage, 
        data.toStorage
    )
    
    if not success then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, err or "Не удалось объединить стаки")
    end
end)

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
    
    -- [FIX] Не дропаем во время загрузки
    if pPlayer.NextRP_Inventory_IsLoading then
        MsgC(Color(255, 200, 0), "[NextRP] DropAllItems BLOCKED: Loading in progress\n")
        return
    end
    
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
    ent:SetOwnerCharID(charID)  -- Для проверки владельца по персонажу
    ent:SetOwnerName(pPlayer:GetNVar('nrp_fullname') or pPlayer:Nick())  -- Имя персонажа для отображения
    ent:SetItemCount(table.Count(itemsCopy))
    
    print("[Inventory] DropAllItems: сумка создана на позиции", deathPos)
    
    -- ============================================
    -- ОЧИСТКА ПАМЯТИ
    -- ============================================
    
    -- Очищаем инвентарь игрока
    if inventory then
        inventory.grid = {}
        inventory.items = {}
    end
    
    -- Очищаем экипировку
    if self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID] then
        self.PlayerEquipment[steamID][charID] = {}
    end
    
    -- ============================================
    -- ОЧИСТКА БД (НОВОЕ!)
    -- ============================================
    
    -- Удаляем инвентарь из БД
    MySQLite.query(string.format(
        "UPDATE nextrp_inventory SET grid_data = %s WHERE character_id = %d",
        MySQLite.SQLStr(util.TableToJSON({grid = {}, items = {}})),
        charID
    ))
    
    -- Удаляем экипировку из БД
    MySQLite.query(string.format(
        "DELETE FROM nextrp_equipment WHERE character_id = %d",
        charID
    ))
    
    print("[Inventory] DropAllItems: БД очищена для CharID:", charID)
    
    -- ============================================
    
    self:SyncInventoryToClient(pPlayer)
    -- НЕ вызываем SaveCharacterInventory - мы уже всё сохранили напрямую
end




-- ============================================================================
-- ХУКИ
-- ============================================================================

hook.Add("NextRP::CharacterSelected", "NextRP::Inventory_OnCharSelected", function(pPlayer, newCharID, oldCharID)
    if not IsValid(pPlayer) then return end
    
    local steamID = pPlayer:SteamID64()
    
    -- [FIX] Устанавливаем флаг СРАЗУ
    pPlayer.NextRP_Inventory_IsLoading = true
    
    -- Сохраняем инвентарь старого персонажа ТОЛЬКО если он был загружен
    if oldCharID and tonumber(oldCharID) > 0 then
        local oldID = tonumber(oldCharID)
        
        -- Проверяем что данные старого персонажа существуют
        local hasOldData = NextRP.Inventory.PlayerEquipment[steamID] and NextRP.Inventory.PlayerEquipment[steamID][oldID]
        
        if hasOldData then
            pPlayer.NextRP_Inventory_IsLoading = false
            NextRP.Inventory:SaveCharacterInventory(pPlayer, oldID)
            pPlayer.NextRP_Inventory_IsLoading = true
        end
        
        -- Очищаем данные старого персонажа из памяти
        if NextRP.Inventory.PlayerInventories[steamID] then
            NextRP.Inventory.PlayerInventories[steamID][oldID] = nil
        end
        if NextRP.Inventory.PlayerStorages[steamID] then
            NextRP.Inventory.PlayerStorages[steamID][oldID] = nil
        end
        if NextRP.Inventory.PlayerEquipment[steamID] then
            NextRP.Inventory.PlayerEquipment[steamID][oldID] = nil
        end
        if NextRP.Inventory.UnlockedSlots[steamID] then
            NextRP.Inventory.UnlockedSlots[steamID][oldID] = nil
        end
    end
    
    -- Обновляем кэш charID
    NextRP.Inventory.CachedCharID[steamID] = tonumber(newCharID)
end)

hook.Add("PlayerSpawn", "NextRP::Inventory_LoadAfterSpawn", function(pPlayer)
    if not IsValid(pPlayer) then return end
    if not pPlayer.NextRP_Inventory_IsLoading then return end
    
    local charID = NextRP.Inventory:GetCharacterID(pPlayer)
    if not charID then return end
    
    -- Загружаем с небольшой задержкой после спавна
    timer.Simple(0.5, function()
        if not IsValid(pPlayer) then return end
        
        local currentCharID = NextRP.Inventory:GetCharacterID(pPlayer)
        if currentCharID ~= charID then return end
        
        NextRP.Inventory:LoadCharacterInventory(pPlayer, function(success)
            if IsValid(pPlayer) then
                pPlayer.NextRP_Inventory_IsLoading = false
            end
        end)
    end)
end)


NextRP.Inventory.CachedCharID = NextRP.Inventory.CachedCharID or {}

-- Заменить хук PlayerDisconnected:
hook.Add("PlayerDisconnected", "NextRP::Inventory_OnDisconnect", function(pPlayer)
    if not IsValid(pPlayer) then return end
    
    local steamID = pPlayer:SteamID64()
    
    -- Используем кэшированный charID если NVar уже недоступен
    local charID = pPlayer:GetNVar('nrp_charid')
    if not charID or tonumber(charID) <= 0 then
        charID = NextRP.Inventory.CachedCharID[steamID]
    end
    
    if charID and tonumber(charID) > 0 then
        -- Принудительно снимаем флаг загрузки для сохранения
        pPlayer.NextRP_Inventory_IsLoading = false
        NextRP.Inventory:SaveCharacterInventory(pPlayer, tonumber(charID))
    end
    
    -- Очищаем кэш
    NextRP.Inventory.CachedCharID[steamID] = nil
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
        -- Проверка владельца по ID персонажа
        local canInteract, errMsg = CanInteractWithDeathBag(pPlayer, ent)
        if not canInteract then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, errMsg)
            return
        end
        
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
    
    -- Проверка владельца по ID персонажа
    local canInteract, errMsg = CanInteractWithDeathBag(pPlayer, ent)
    if not canInteract then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, errMsg)
        return
    end
    
    local items = ent:GetItems()
    local item = items[data.uniqueID]
    if not item then return end
    
    local success, err = NextRP.Inventory:AddItem(pPlayer, item.itemID, item.amount)
    if success then
        items[data.uniqueID] = nil
        
        if IsValid(ent) and ent.SetItems then
            ent:SetItems(items)
        end
        
        if table.Count(items) == 0 then
            if IsValid(ent) then ent:Remove() end
            
            netstream.Start(pPlayer, "NextRP::UpdateDeathBag", {
                entIndex = data.entIndex,
                items = {} 
            })
        else
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


-- ============================================================================
-- ФИКС ГРАНАТ v2 - добавить в конец sv_inventory.lua
-- Более агрессивная проверка слотов
-- ============================================================================

-- Таблица для отслеживания оружия игроков
NextRP.Inventory.TrackedWeapons = NextRP.Inventory.TrackedWeapons or {}

-- Функция очистки слота по классу оружия
function NextRP.Inventory:ClearEquipmentSlotByWeapon(pPlayer, weaponClass)
    if not IsValid(pPlayer) then return false end
    
    -- [FIX] Не очищаем во время загрузки!
    if pPlayer.NextRP_Inventory_IsLoading then 
        MsgC(Color(255, 200, 0), "[NextRP Inventory] ClearEquipmentSlot BLOCKED - loading in progress\n")
        return false 
    end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false end
    
    local steamID = pPlayer:SteamID64()
    local equip = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
    if not equip then return false end
    
    local cleared = false
    
    -- Проверяем все слоты снаряжения
    for slotType, slots in pairs(equip) do
        for slotIndex, item in pairs(slots) do
            if item and item.itemID then
                local itemData = self:GetItemData(item.itemID)
                if itemData and itemData.weaponClass and itemData.weaponClass == weaponClass then
                    -- Освобождаем слот
                    equip[slotType][slotIndex] = nil
                    cleared = true
                    
                    -- Удаляем из БД
                    MySQLite.query(string.format(
                        "DELETE FROM nextrp_equipment WHERE character_id = %d AND slot_type = %s AND slot_index = %d",
                        charID,
                        MySQLite.SQLStr(slotType),
                        slotIndex
                    ))
                    
                    MsgC(Color(255, 200, 0), "[NextRP Inventory] Слот " .. slotType .. "[" .. slotIndex .. "] освобождён (оружие " .. weaponClass .. ")\n")
                end
            end
        end
    end
    
    if cleared then
        self:SyncInventoryToClient(pPlayer)
    end
    
    return cleared
end

-- Функция проверки всех слотов игрока
function NextRP.Inventory:ValidateEquipmentSlots(pPlayer)
    if not IsValid(pPlayer) then return end
    
    -- [FIX] Не валидируем во время загрузки!
    if pPlayer.NextRP_Inventory_IsLoading then return end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return end
    
    local steamID = pPlayer:SteamID64()
    local equip = self.PlayerEquipment[steamID] and self.PlayerEquipment[steamID][charID]
    if not equip then return end
    
    local needSync = false
    
    for slotType, slots in pairs(equip) do
        for slotIndex, item in pairs(slots) do
            if item and item.itemID then
                local itemData = self:GetItemData(item.itemID)
                if itemData and itemData.weaponClass then
                    -- Проверяем есть ли оружие у игрока
                    if not pPlayer:HasWeapon(itemData.weaponClass) then
                        -- Очищаем слот
                        equip[slotType][slotIndex] = nil
                        needSync = true
                        
                        MySQLite.query(string.format(
                            "DELETE FROM nextrp_equipment WHERE character_id = %d AND slot_type = %s AND slot_index = %d",
                            charID,
                            MySQLite.SQLStr(slotType),
                            slotIndex
                        ))
                        
                        MsgC(Color(255, 150, 0), "[NextRP Inventory] Очищен слот " .. slotType .. "[" .. slotIndex .. "] - оружие " .. itemData.weaponClass .. " отсутствует\n")
                    end
                end
            end
        end
    end
    
    if needSync then
        self:SyncInventoryToClient(pPlayer)
    end
end

-- Обновляем список оружия игрока
local function UpdateTrackedWeapons(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    local weapons = {}
    
    for _, wep in pairs(ply:GetWeapons()) do
        if IsValid(wep) then
            weapons[wep:GetClass()] = true
        end
    end
    
    NextRP.Inventory.TrackedWeapons[steamID] = weapons
end

-- Проверяем какое оружие пропало
local function CheckMissingWeapons(ply)
    if not IsValid(ply) then return end
    
    -- [FIX] Не проверяем во время загрузки инвентаря!
    if ply.NextRP_Inventory_IsLoading then return end
    
    -- [FIX] Не проверяем если персонаж не загружен
    local charID = NextRP.Inventory:GetCharacterID(ply)
    if not charID then return end
    
    local steamID = ply:SteamID64()
    local oldWeapons = NextRP.Inventory.TrackedWeapons[steamID] or {}
    local currentWeapons = {}
    
    for _, wep in pairs(ply:GetWeapons()) do
        if IsValid(wep) then
            currentWeapons[wep:GetClass()] = true
        end
    end
    
    -- Ищем пропавшее оружие
    for wepClass, _ in pairs(oldWeapons) do
        if not currentWeapons[wepClass] then
            -- Оружие пропало - очищаем слот
            NextRP.Inventory:ClearEquipmentSlotByWeapon(ply, wepClass)
        end
    end
    
    -- Обновляем список
    NextRP.Inventory.TrackedWeapons[steamID] = currentWeapons
end



-- Инициализация при загрузке персонажа
hook.Add("NextRP::CharacterLoaded", "NextRP::Inventory::InitTracking", function(ply)
    if IsValid(ply) then
        timer.Simple(1, function()
            if IsValid(ply) then
                UpdateTrackedWeapons(ply)
            end
        end)
    end
end)

-- При спавне игрока
hook.Add("PlayerSpawn", "NextRP::Inventory::SpawnTracking", function(ply)
    timer.Simple(0.5, function()
        if IsValid(ply) then
            UpdateTrackedWeapons(ply)
        end
    end)
end)

-- При получении оружия
hook.Add("PlayerCanPickupWeapon", "NextRP::Inventory::PickupTracking", function(ply, wep)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            UpdateTrackedWeapons(ply)
        end
    end)
end)

-- Хук на выдачу оружия
hook.Add("WeaponEquip", "NextRP::Inventory::EquipTracking", function(wep, ply)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            UpdateTrackedWeapons(ply)
        end
    end)
end)

-- Команда для ручной проверки
concommand.Add("nextrp_validate_slots", function(ply, cmd, args)
    if IsValid(ply) then
        NextRP.Inventory:ValidateEquipmentSlots(ply)
        ply:ChatPrint("[Inventory] Слоты проверены и синхронизированы")
    end
end)

-- Админ команда для проверки всех игроков
concommand.Add("nextrp_validate_all_slots", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    for _, p in ipairs(player.GetAll()) do
        NextRP.Inventory:ValidateEquipmentSlots(p)
    end
    
    local msg = "[Inventory] Слоты всех игроков проверены"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

MsgC(Color(0, 255, 100), "[NextRP Inventory] Фикс гранат v2 загружен!\n")

netstream.Hook("NextRP::InventoryTakeAllFromBag", function(pPlayer, data)
    local ent = Entity(data.entIndex)
    if not IsValid(ent) or ent:GetClass() ~= "nextrp_deadbug" then return end
    if ent:GetPos():Distance(pPlayer:GetPos()) > NextRP.Inventory.Config.PickupRadius then return end
    
    -- Проверка владельца по ID персонажа
    local canInteract, errMsg = CanInteractWithDeathBag(pPlayer, ent)
    if not canInteract then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, errMsg)
        return
    end
    
    local items = ent:GetItems()
    if not items or table.Count(items) == 0 then return end
    
    local takenItems = {}
    local failedItems = {}
    
    for uniqueID, item in pairs(items) do
        local success, err = NextRP.Inventory:AddItem(pPlayer, item.itemID, item.amount)
        if success then
            table.insert(takenItems, uniqueID)
        else
            failedItems[uniqueID] = item
        end
    end
    
    for _, uniqueID in ipairs(takenItems) do
        items[uniqueID] = nil
    end
    
    if IsValid(ent) and ent.SetItems then
        ent:SetItems(failedItems)
    end
    
    if table.Count(failedItems) == 0 then
        if IsValid(ent) then ent:Remove() end
        
        netstream.Start(pPlayer, "NextRP::UpdateDeathBag", {
            entIndex = data.entIndex,
            items = {}
        })
        
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, "Все предметы забраны!")
    else
        netstream.Start(pPlayer, "NextRP::UpdateDeathBag", {
            entIndex = data.entIndex,
            items = failedItems
        })
        
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Не хватило места для всех предметов!")
    end
end)

function NextRP.Inventory:SplitStack(pPlayer, uniqueID, splitAmount, fromStorage)
    if not IsValid(pPlayer) then return false, "Игрок не найден" end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false, "Персонаж не загружен" end
    
    local steamID = pPlayer:SteamID64()
    
    -- Получаем хранилище
    local storage
    local gridWidth, gridHeight
    
    if fromStorage then
        storage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
        gridWidth = self.Config.StorageGridWidth
        gridHeight = self.Config.StorageGridHeight
    else
        storage = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
        gridWidth = self.Config.GridWidth
        gridHeight = self.Config.GridHeight
    end
    
    if not storage or not storage.items[uniqueID] then 
        return false, "Предмет не найден" 
    end
    
    local item = storage.items[uniqueID]
    local itemData = self:GetItemData(item.itemID)
    
    if not itemData then return false, "Данные предмета не найдены" end
    if not itemData.stackable then return false, "Этот предмет нельзя разделить" end
    if not item.amount or item.amount <= 1 then return false, "Недостаточно предметов для разделения" end
    if splitAmount <= 0 or splitAmount >= item.amount then return false, "Неверное количество" end
    
    -- Ищем свободное место для нового стака
    local posX, posY = self:FindFreeSlot(storage.grid, gridWidth, gridHeight, itemData)
    if not posX then
        return false, "Недостаточно места для нового стака"
    end
    
    -- Уменьшаем количество в оригинальном стаке
    item.amount = item.amount - splitAmount
    
    -- Создаём новый стак
    local newUniqueID = tostring(os.time()) .. "_" .. math.random(10000, 99999)
    
    -- Занимаем ячейки для нового стака
    for x = posX, posX + itemData.width - 1 do
        for y = posY, posY + itemData.height - 1 do
            storage.grid[x .. "_" .. y] = newUniqueID
        end
    end
    
    -- Добавляем новый стак
    storage.items[newUniqueID] = {
        itemID = item.itemID,
        amount = splitAmount,
        posX = posX,
        posY = posY
    }
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    
    return true
end

netstream.Hook("NextRP::InventorySplitStack", function(pPlayer, data)
    local success, err = NextRP.Inventory:SplitStack(pPlayer, data.uniqueID, data.amount, data.fromStorage)
    
    if not success then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, err or "Не удалось разделить стак")
    end
end)

function NextRP.Inventory:QuickTransfer(pPlayer, uniqueID, fromStorage, toStorage)
    if not IsValid(pPlayer) then return false, "Игрок не найден" end
    
    local charID = self:GetCharacterID(pPlayer)
    if not charID then return false, "Персонаж не загружен" end
    
    local steamID = pPlayer:SteamID64()
    
    -- Получаем источник
    local sourceStorage
    if fromStorage then
        sourceStorage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
    else
        sourceStorage = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
    end
    
    if not sourceStorage or not sourceStorage.items[uniqueID] then
        return false, "Предмет не найден"
    end
    
    local item = sourceStorage.items[uniqueID]
    local itemData = self:GetItemData(item.itemID)
    
    if not itemData then return false, "Данные предмета не найдены" end
    
    -- Получаем целевое хранилище
    local targetStorage, targetGridWidth, targetGridHeight
    if toStorage then
        targetStorage = self.PlayerStorages[steamID] and self.PlayerStorages[steamID][charID]
        targetGridWidth = self.Config.StorageGridWidth
        targetGridHeight = self.Config.StorageGridHeight
    else
        targetStorage = self.PlayerInventories[steamID] and self.PlayerInventories[steamID][charID]
        targetGridWidth = self.Config.GridWidth
        targetGridHeight = self.Config.GridHeight
    end
    
    if not targetStorage then
        -- Создаём хранилище если его нет
        if toStorage then
            self.PlayerStorages[steamID] = self.PlayerStorages[steamID] or {}
            self.PlayerStorages[steamID][charID] = {grid = {}, items = {}}
            targetStorage = self.PlayerStorages[steamID][charID]
        else
            return false, "Хранилище не найдено"
        end
    end
    
    -- Если предмет стакается, пробуем добавить к существующим
    if itemData.stackable then
        for targetUniqueID, targetItem in pairs(targetStorage.items) do
            if targetItem.itemID == item.itemID and targetItem.amount < itemData.maxStack then
                local canAdd = math.min(item.amount, itemData.maxStack - targetItem.amount)
                targetItem.amount = targetItem.amount + canAdd
                item.amount = item.amount - canAdd
                
                if item.amount <= 0 then
                    -- Освобождаем ячейки
                    for x = item.posX, item.posX + itemData.width - 1 do
                        for y = item.posY, item.posY + itemData.height - 1 do
                            sourceStorage.grid[x .. "_" .. y] = nil
                        end
                    end
                    sourceStorage.items[uniqueID] = nil
                    
                    self:SyncInventoryToClient(pPlayer)
                    self:SaveCharacterInventory(pPlayer, charID)
                    return true
                end
            end
        end
    end
    
    -- Ищем свободное место
    local posX, posY = self:FindFreeSlot(targetStorage.grid, targetGridWidth, targetGridHeight, itemData)
    if not posX then
        return false, "Недостаточно места"
    end
    
    -- Освобождаем старые ячейки
    for x = item.posX, item.posX + itemData.width - 1 do
        for y = item.posY, item.posY + itemData.height - 1 do
            sourceStorage.grid[x .. "_" .. y] = nil
        end
    end
    
    -- Удаляем из источника
    sourceStorage.items[uniqueID] = nil
    
    -- Занимаем новые ячейки
    for x = posX, posX + itemData.width - 1 do
        for y = posY, posY + itemData.height - 1 do
            targetStorage.grid[x .. "_" .. y] = uniqueID
        end
    end
    
    -- Добавляем в цель
    targetStorage.items[uniqueID] = {
        itemID = item.itemID,
        amount = item.amount,
        posX = posX,
        posY = posY
    }
    
    self:SyncInventoryToClient(pPlayer)
    self:SaveCharacterInventory(pPlayer, charID)
    
    return true
end

netstream.Hook("NextRP::InventoryQuickTransfer", function(pPlayer, data)
    local success, err = NextRP.Inventory:QuickTransfer(pPlayer, data.uniqueID, data.fromStorage, data.toStorage)
    
    if not success then
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, err or "Не удалось перенести предмет")
    end
end)

concommand.Add("nextrp_debug_equip", function(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    local charID = NextRP.Inventory:GetCharacterID(ply)
    
    print("========== DEBUG EQUIPMENT ==========")
    print("SteamID:", steamID)
    print("CharID:", charID)
    print("IsLoading:", ply.NextRP_Inventory_IsLoading)
    print("")
    
    -- Данные в памяти
    print("=== MEMORY DATA ===")
    local equipData = NextRP.Inventory.PlayerEquipment[steamID]
    if equipData then
        print("PlayerEquipment[steamID] exists")
        if equipData[charID] then
            print("PlayerEquipment[steamID][charID] exists")
            for slotType, slots in pairs(equipData[charID]) do
                for slotIndex, item in pairs(slots) do
                    print("  Slot:", slotType, "[" .. slotIndex .. "]", "Item:", item and item.itemID or "NIL")
                end
            end
        else
            print("PlayerEquipment[steamID][charID] = NIL!")
        end
    else
        print("PlayerEquipment[steamID] = NIL!")
    end
    
    print("")
    
    -- Данные в БД
    print("=== DATABASE DATA ===")
    MySQLite.query("SELECT * FROM nextrp_equipment WHERE character_id = " .. (charID or 0), function(result)
        if result then
            for _, row in ipairs(result) do
                print("  DB Row:", row.slot_type, "[" .. row.slot_index .. "]", "Data:", row.item_data)
            end
            print("  Total rows:", #result)
        else
            print("  NO DATA IN DATABASE!")
        end
        print("======================================")
    end)
end)