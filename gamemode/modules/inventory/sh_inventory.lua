
NextRP.Inventory = NextRP.Inventory or {}

-- ============================================================================
-- КОНФИГУРАЦИЯ
-- ============================================================================

NextRP.Inventory.Config = {
    -- Размер сетки инвентаря персонажа (ширина x высота)
    GridWidth = 10,
    GridHeight = 6,
    
    -- Размер сетки личного хранилища
    StorageGridWidth = 15,
    StorageGridHeight = 10,
    
    -- Размер ячейки в пикселях (для UI)
    CellSize = 50,
    
    -- Типы слотов снаряжения
    SlotTypes = {
        PRIMARY = "primary",           -- Основное оружие
        SECONDARY = "secondary",       -- Второстепенное снаряжение
        HEAVY = "heavy",              -- Тяжёлое снаряжение
        SPECIAL = "special",          -- Специальное снаряжение
        MEDICAL = "medical"           -- Медицинское снаряжение
    },
    
    -- Конфигурация слотов снаряжения
    EquipmentSlots = {
        primary = {
            total = 2,
            free = 1,
            costPerSlot = 500, -- CRotR за дополнительный слот
            icon = "icon16/gun.png"
        },
        secondary = {
            total = 2,
            free = 1,
            costPerSlot = 300,
            icon = "icon16/shield.png"
        },
        heavy = {
            total = 2,
            free = 1,
            costPerSlot = 750,
            icon = "icon16/bomb.png"
        },
        special = {
            total = 3,
            free = 1,
            costPerSlot = 400,
            icon = "icon16/lightning.png"
        },
        medical = {
            total = 3,
            free = 1,
            costPerSlot = 250,
            icon = "icon16/heart.png"
        }
    },
    
    -- Время жизни выброшенных предметов (в секундах)
    DroppedItemLifetime = 300, -- 5 минут
    
    -- Радиус подбора предметов
    PickupRadius = 100,
    
    -- Цвета UI
    Colors = {
        Empty = Color(40, 40, 40, 200),
        Occupied = Color(60, 80, 60, 200),
        Selected = Color(80, 120, 80, 255),
        Invalid = Color(120, 40, 40, 200),
        Locked = Color(80, 80, 80, 200),
        Hover = Color(100, 100, 100, 200)
    }
}

-- ============================================================================
-- БАЗА ПРЕДМЕТОВ
-- ============================================================================

-- Формат предмета:
-- {
--     id = "unique_id",
--     name = "Название",
--     description = "Описание",
--     icon = "path/to/icon.png",
--     width = 1,  -- Ширина в ячейках
--     height = 1, -- Высота в ячейках
--     stackable = false, -- Можно ли стакать
--     maxStack = 1,
--     weight = 0.5, -- Вес в кг
--     slotType = nil, -- Тип слота (если это снаряжение)
--     weaponClass = nil, -- Класс оружия (если это оружие)
--     onUse = nil, -- Функция при использовании
--     canDrop = true, -- Можно ли выбросить
--     rarity = "common" -- common, uncommon, rare, epic, legendary
-- }

NextRP.Inventory.Items = {}

-- Функция регистрации предмета
function NextRP.Inventory:RegisterItem(itemData)
    if not itemData.id then
        MsgC(Color(255, 0, 0), "[NextRP Inventory] Ошибка: предмет без ID!\n")
        return false
    end
    
    -- Значения по умолчанию
    itemData.width = itemData.width or 1
    itemData.height = itemData.height or 1
    itemData.stackable = itemData.stackable or false
    itemData.maxStack = itemData.maxStack or 1
    itemData.weight = itemData.weight or 0.1
    itemData.canDrop = itemData.canDrop ~= false
    itemData.rarity = itemData.rarity or "common"
    
    self.Items[itemData.id] = itemData
    return true
end

-- Получить данные предмета по ID
function NextRP.Inventory:GetItemData(itemID)
    return self.Items[itemID]
end

-- ============================================================================
-- СТАНДАРТНЫЕ ПРЕДМЕТЫ
-- ============================================================================

-- Медикаменты
NextRP.Inventory:RegisterItem({
    id = "medkit",
    name = "Аптечка",
    description = "Восстанавливает 50 HP",
    icon = "icon16/heart.png",
    width = 2,
    height = 1,
    slotType = "medical",
    rarity = "common",
    onUse = function(ply)
        if SERVER then
            local newHealth = math.min(ply:Health() + 50, ply:GetMaxHealth())
            ply:SetHealth(newHealth)
            return true
        end
    end
})

NextRP.Inventory:RegisterItem({
    id = "medkit_large",
    name = "Большая аптечка",
    description = "Полностью восстанавливает HP",
    icon = "icon16/heart_add.png",
    width = 2,
    height = 2,
    slotType = "medical",
    rarity = "uncommon",
    onUse = function(ply)
        if SERVER then
            ply:SetHealth(ply:GetMaxHealth())
            return true
        end
    end
})

NextRP.Inventory:RegisterItem({
    id = "bandage",
    name = "Бинт",
    description = "Восстанавливает 25 HP",
    icon = "icon16/pill.png",
    width = 1,
    height = 1,
    stackable = true,
    maxStack = 5,
    slotType = "medical",
    rarity = "common",
    onUse = function(ply)
        if SERVER then
            local newHealth = math.min(ply:Health() + 25, ply:GetMaxHealth())
            ply:SetHealth(newHealth)
            return true
        end
    end
})

NextRP.Inventory:RegisterItem({
    id = "stimpack",
    name = "Стимулятор",
    description = "Временно увеличивает скорость",
    icon = "icon16/lightning.png",
    width = 1,
    height = 2,
    slotType = "special",
    rarity = "rare",
    onUse = function(ply)
        if SERVER then
            local oldSpeed = ply:GetRunSpeed()
            ply:SetRunSpeed(oldSpeed * 1.5)
            timer.Simple(30, function()
                if IsValid(ply) then
                    ply:SetRunSpeed(oldSpeed)
                end
            end)
            return true
        end
    end
})

-- Боеприпасы
NextRP.Inventory:RegisterItem({
    id = "ammo_rifle",
    name = "Патроны для винтовки",
    description = "30 патронов калибра 5.56",
    icon = "icon16/bullet_yellow.png",
    width = 1,
    height = 1,
    stackable = true,
    maxStack = 10,
    rarity = "common"
})

NextRP.Inventory:RegisterItem({
    id = "ammo_pistol",
    name = "Пистолетные патроны",
    description = "15 патронов калибра 9мм",
    icon = "icon16/bullet_black.png",
    width = 1,
    height = 1,
    stackable = true,
    maxStack = 15,
    rarity = "common"
})

NextRP.Inventory:RegisterItem({
    id = "ammo_heavy",
    name = "Тяжёлые патроны",
    description = "10 патронов калибра .50",
    icon = "icon16/bullet_red.png",
    width = 2,
    height = 1,
    stackable = true,
    maxStack = 5,
    rarity = "uncommon"
})

-- Гранаты
NextRP.Inventory:RegisterItem({
    id = "grenade_frag",
    name = "Осколочная граната",
    description = "Взрывчатка",
    icon = "icon16/bomb.png",
    width = 1,
    height = 1,
    slotType = "special",
    rarity = "uncommon"
})

NextRP.Inventory:RegisterItem({
    id = "grenade_smoke",
    name = "Дымовая граната",
    description = "Создаёт дымовую завесу",
    icon = "icon16/weather_clouds.png",
    width = 1,
    height = 1,
    slotType = "special",
    rarity = "common"
})

NextRP.Inventory:RegisterItem({
    id = "grenade_flash",
    name = "Светошумовая граната",
    description = "Ослепляет противников",
    icon = "icon16/lightbulb.png",
    width = 1,
    height = 1,
    slotType = "special",
    rarity = "common"
})

        NextRP.Inventory:RegisterItem({
            id = "weapon_dc15a",
            name = "DC-15A Бластерная винтовка",
            description = "Стандартная бластерная винтовка клонов",
            icon = "entities/arccw/kraken/republic-arsenal/dc15a.png",
            width = 4,
            height = 2,
            dropModel = "models/arccw/kraken-new/republic/w_dc15a.mdl",
            slotType = "primary",
            weaponClass = "arccw_k_dc15a",
            rarity = "legendary"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "weapon_dc15s",
            name = "DC-15S Бластерный карабин",
            description = "Компактный бластерный карабин",
            icon = "icon16/gun.png",
            width = 3,
            height = 2,
            slotType = "primary",
            weaponClass = "arccw_k_dc15s",
            rarity = "common"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "weapon_dc17",
            name = "DC-17 Бластерный пистолет",
            description = "Стандартный бластерный пистолет клонов",
            icon = "icon16/gun.png",
            width = 2,
            height = 1,
            slotType = "secondary",
            weaponClass = "arc9_sw_dc17",
            rarity = "common"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "weapon_dc17ext",
            name = "DC-17 (Расширенный магазин)",
            description = "DC-17 с увеличенным магазином",
            icon = "icon16/gun.png",
            width = 2,
            height = 1,
            slotType = "secondary",
            weaponClass = "arc9_sw_dc17ext",
            rarity = "uncommon"
        })
        
        -- Тяжёлое вооружение
        NextRP.Inventory:RegisterItem({
            id = "weapon_z6",
            name = "Z-6 Роторная пушка",
            description = "Тяжёлая роторная бластерная пушка",
            icon = "icon16/bomb.png",
            width = 4,
            height = 3,
            slotType = "heavy",
            weaponClass = "arc9_sw_z6",
            rarity = "rare"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "weapon_rps6",
            name = "RPS-6 Ракетная установка",
            description = "Противотанковая ракетная установка",
            icon = "icon16/bomb.png",
            width = 5,
            height = 2,
            slotType = "heavy",
            weaponClass = "arc9_sw_rps6",
            rarity = "rare"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "weapon_dc15x",
            name = "DC-15x Снайперская винтовка",
            description = "Снайперская бластерная винтовка",
            icon = "icon16/gun.png",
            width = 5,
            height = 2,
            slotType = "primary",
            weaponClass = "arc9_sw_dc15x",
            rarity = "rare"
        })
        
        -- Специальное снаряжение
        NextRP.Inventory:RegisterItem({
            id = "jetpack",
            name = "Джетпак",
            description = "Реактивный ранец для полётов",
            icon = "icon16/lightning.png",
            width = 3,
            height = 3,
            slotType = "special",
            rarity = "epic"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "grapple_hook",
            name = "Крюк-кошка",
            description = "Устройство для быстрого перемещения",
            icon = "icon16/anchor.png",
            width = 2,
            height = 2,
            slotType = "special",
            weaponClass = "weapon_grapplehook",
            rarity = "uncommon"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "shield_personal",
            name = "Персональный щит",
            description = "Переносной энергетический щит",
            icon = "icon16/shield.png",
            width = 2,
            height = 3,
            slotType = "special",
            rarity = "rare"
        })
        
        -- Световые мечи (для джедаев)
        NextRP.Inventory:RegisterItem({
            id = "lightsaber_single",
            name = "Световой меч",
            description = "Оружие рыцаря-джедая",
            icon = "icon16/wand.png",
            width = 1,
            height = 3,
            slotType = "primary",
            rarity = "epic"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "lightsaber_double",
            name = "Двухклинковый световой меч",
            description = "Редкое оружие с двумя клинками",
            icon = "icon16/wand.png",
            width = 1,
            height = 4,
            slotType = "primary",
            rarity = "legendary"
        })
        
        -- Дополнительные расходники
        NextRP.Inventory:RegisterItem({
            id = "thermal_detonator",
            name = "Термальный детонатор",
            description = "Мощная граната",
            icon = "icon16/bomb.png",
            width = 1,
            height = 1,
            stackable = true,
            maxStack = 3,
            slotType = "special",
            rarity = "rare"
        })
        
        NextRP.Inventory:RegisterItem({
            id = "droid_popper",
            name = "EMP-граната",
            description = "Электромагнитная граната против дроидов",
            icon = "icon16/plugin_disabled.png",
            width = 1,
            height = 1,
            stackable = true,
            maxStack = 5,
            slotType = "special",
            rarity = "uncommon"
        })
        
        -- Бакта и медицина
        NextRP.Inventory:RegisterItem({
            id = "bacta_injector",
            name = "Бакта-инъектор",
            description = "Мгновенное лечение 75 HP",
            icon = "icon16/heart_add.png",
            width = 1,
            height = 2,
            slotType = "medical",
            rarity = "uncommon",
            onUse = function(ply)
                if SERVER then
                    local newHealth = math.min(ply:Health() + 75, ply:GetMaxHealth())
                    ply:SetHealth(newHealth)
                    ply:EmitSound("items/medshot4.wav")
                    return true
                end
            end
        })
        
        NextRP.Inventory:RegisterItem({
            id = "bacta_canister",
            name = "Канистра бакты",
            description = "Полное восстановление здоровья",
            icon = "icon16/pill.png",
            width = 2,
            height = 3,
            slotType = "medical",
            rarity = "rare",
            onUse = function(ply)
                if SERVER then
                    ply:SetHealth(ply:GetMaxHealth())
                    ply:EmitSound("items/medcharge4.wav")
                    return true
                end
            end
        })
        
        NextRP.Inventory:RegisterItem({
            id = "stim_combat",
            name = "Боевой стимулятор",
            description = "Увеличивает урон на 30 секунд",
            icon = "icon16/lightning.png",
            width = 1,
            height = 1,
            stackable = true,
            maxStack = 3,
            slotType = "medical",
            rarity = "rare",
            onUse = function(ply)
                if SERVER then
                    ply:SetNWBool("CombatStim", true)
                    timer.Simple(30, function()
                        if IsValid(ply) then
                            ply:SetNWBool("CombatStim", false)
                        end
                    end)
                    return true
                end
            end
        })
        
        NextRP.Inventory:RegisterItem({
            id = "stim_speed",
            name = "Стимулятор скорости",
            description = "Увеличивает скорость на 20 секунд",
            icon = "icon16/arrow_refresh.png",
            width = 1,
            height = 1,
            stackable = true,
            maxStack = 3,
            slotType = "medical",
            rarity = "uncommon",
            onUse = function(ply)
                if SERVER then
                    local oldWalk = ply:GetWalkSpeed()
                    local oldRun = ply:GetRunSpeed()
                    ply:SetWalkSpeed(oldWalk * 1.3)
                    ply:SetRunSpeed(oldRun * 1.3)
                    timer.Simple(20, function()
                        if IsValid(ply) then
                            ply:SetWalkSpeed(oldWalk)
                            ply:SetRunSpeed(oldRun)
                        end
                    end)
                    return true
                end
            end
        })

-- ============================================================================
-- УТИЛИТЫ
-- ============================================================================

-- Проверка, поместится ли предмет в указанную позицию
function NextRP.Inventory:CanFitItem(grid, gridWidth, gridHeight, itemData, posX, posY)
    if not itemData then return false end
    
    local itemWidth = itemData.width or 1
    local itemHeight = itemData.height or 1
    
    -- Проверяем границы сетки
    if posX < 1 or posY < 1 then return false end
    if posX + itemWidth - 1 > gridWidth then return false end
    if posY + itemHeight - 1 > gridHeight then return false end
    
    -- Проверяем занятость ячеек
    for x = posX, posX + itemWidth - 1 do
        for y = posY, posY + itemHeight - 1 do
            local key = x .. "_" .. y
            if grid[key] then return false end
        end
    end
    
    return true
end

-- Поиск свободного места для предмета
function NextRP.Inventory:FindFreeSlot(grid, gridWidth, gridHeight, itemData)
    if not itemData then return nil, nil end
    
    local itemWidth = itemData.width or 1
    local itemHeight = itemData.height or 1
    
    for y = 1, gridHeight - itemHeight + 1 do
        for x = 1, gridWidth - itemWidth + 1 do
            if self:CanFitItem(grid, gridWidth, gridHeight, itemData, x, y) then
                return x, y
            end
        end
    end
    
    return nil, nil
end

-- Сериализация инвентаря для сохранения в БД
function NextRP.Inventory:SerializeInventory(inventoryData)
    return util.TableToJSON(inventoryData)
end

-- Десериализация инвентаря из БД
function NextRP.Inventory:DeserializeInventory(jsonString)
    if not jsonString or jsonString == "" then
        return {}
    end
    return util.JSONToTable(jsonString) or {}
end

-- Получить цвет редкости
function NextRP.Inventory:GetRarityColor(rarity)
    local colors = {
        common = Color(255, 255, 255),
        uncommon = Color(30, 255, 30),
        rare = Color(30, 144, 255),
        epic = Color(163, 53, 238),
        legendary = Color(255, 165, 0)
    }
    return colors[rarity] or colors.common
end

-- Получить название редкости
function NextRP.Inventory:GetRarityName(rarity)
    local names = {
        common = "Обычный",
        uncommon = "Необычный",
        rare = "Редкий",
        epic = "Эпический",
        legendary = "Легендарный"
    }
    return names[rarity] or names.common
end

print("[NextRP] Модуль инвентаря (shared) загружен!")