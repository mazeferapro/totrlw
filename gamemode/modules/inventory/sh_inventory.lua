
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

-- ============================================================
-- АВТО-ГЕНЕРАЦИЯ (Из файлов + Из профессий)
-- ============================================================

local function AddItem(id, name, class, type, w, h, price, model, icon)
    if NextRP.Inventory.Items[id] then return end
    NextRP.Inventory:RegisterItem({
        id = id, name = name, description = 'Снаряжение: '..name,
        model = model, icon = icon, width = w, height = h,
        slotType = type, weaponClass = class,
        supplyPrice = price, rarity = 'common'
    })
end

AddItem("aarccw_k_dc15le", "Ak Dc15Le (No File)", "aarccw_k_dc15le", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_galactic_nt242ri", "Arc9 Galactic Nt242Ri (No File)", "arc9_galactic_nt242ri", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_galactic_vssmaze", "Arc9 Galactic Vssmaze (No File)", "arc9_galactic_vssmaze", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc15a", "Arc9 K Dc15A (No File)", "arc9_k_dc15a", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc15a_stun", "Arc9 K Dc15A Stun (No File)", "arc9_k_dc15a_stun", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc15le", "Arc9 K Dc15Le (No File)", "arc9_k_dc15le", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc15s", "Arc9 K Dc15S (No File)", "arc9_k_dc15s", "primary", 3, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc15s_stun", "Arc9 K Dc15S Stun (No File)", "arc9_k_dc15s_stun", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc15x", "Arc9 K Dc15X (No File)", "arc9_k_dc15x", "primary", 5, 2, 150, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc17", "Arc9 K Dc17 (No File)", "arc9_k_dc17", "secondary", 2, 1, 60, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dc17ext_akimbo", "Arc9 K Dc17Ext Akimbo (No File)", "arc9_k_dc17ext_akimbo", "secondary", 2, 1, 60, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dp23", "Arc9 K Dp23 (No File)", "arc9_k_dp23", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dp23c", "Arc9 K Dp23C (No File)", "arc9_k_dp23c", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dp24", "Arc9 K Dp24 (No File)", "arc9_k_dp24", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_dp24c", "Arc9 K Dp24C (No File)", "arc9_k_dp24c", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_launcher_rps6_republic", "Arc9 K Launcher Rps6 Republic (No File)", "arc9_k_launcher_rps6_republic", "primary", 5, 2, 250, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_bacta", "Arc9 K Nade Bacta (No File)", "arc9_k_nade_bacta", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_c14", "Arc9 K Nade C14 (No File)", "arc9_k_nade_c14", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_flash", "Arc9 K Nade Flash (No File)", "arc9_k_nade_flash", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_impact", "Arc9 K Nade Impact (No File)", "arc9_k_nade_impact", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_smoke", "Arc9 K Nade Smoke (No File)", "arc9_k_nade_smoke", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_sonar", "Arc9 K Nade Sonar (No File)", "arc9_k_nade_sonar", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_stun", "Arc9 K Nade Stun (No File)", "arc9_k_nade_stun", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_nade_thermal", "Arc9 K Nade Thermal (No File)", "arc9_k_nade_thermal", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_republicshield", "Arc9 K Republicshield (No File)", "arc9_k_republicshield", "special", 2, 2, 150, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_valken38", "Arc9 K Valken38 (No File)", "arc9_k_valken38", "primary", 5, 2, 150, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_westarm5", "Arc9 K Westarm5 (No File)", "arc9_k_westarm5", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_z6", "Arc9 K Z6 (No File)", "arc9_k_z6", "primary", 5, 2, 250, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arc9_k_z6adv", "Arc9 K Z6Adv (No File)", "arc9_k_z6adv", "primary", 5, 2, 250, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arccw_bowcaster", "Bowcaster", "arccw_bowcaster", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_bowcaster.png")
AddItem("arccw_cgi_k_212shield", "212th Batallion Shield", "arccw_cgi_k_212shield", "special", 2, 2, 150, "models/kraken/cgi/v_cgi_212shield.mdl", "entities/arccw/kraken/cgi/212th_shield.png")
AddItem("arccw_cgi_k_41shield", "41st Legion Shield", "arccw_cgi_k_41shield", "special", 2, 2, 150, "models/kraken/cgi/v_cgi_41shield.mdl", "entities/arccw/kraken/cgi/41st_shield.png")
AddItem("arccw_cgi_k_501shield", "501st Legion Shield", "arccw_cgi_k_501shield", "special", 2, 2, 150, "models/kraken/cgi/v_cgi_501shield.mdl", "entities/arccw/kraken/cgi/501st_shield.png")
AddItem("arccw_cgi_k_akimbo_dc17", "Akimbo DC-17", "arccw_cgi_k_akimbo_dc17", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17.mdl", "entities/arccw/kraken/cgi/17_dual.png")
AddItem("arccw_cgi_k_akimbo_dc17_commando", "Akimbo DC-17s", "arccw_cgi_k_akimbo_dc17_commando", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17s.mdl", "entities/arccw/kraken/cgi/17_commando_akimbo.png")
AddItem("arccw_cgi_k_akimbo_dc17_ext", "Akimbo DC-17 Extended", "arccw_cgi_k_akimbo_dc17_ext", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17ext.mdl", "entities/arccw/kraken/cgi/17_ext_dual.png")
AddItem("arccw_cgi_k_akimbo_dc17_heavy", "Akimbo DC-17 Heavy", "arccw_cgi_k_akimbo_dc17_heavy", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17h.mdl", "entities/arccw/kraken/cgi/17_heavy_dual.png")
AddItem("arccw_cgi_k_cgshield", "Shock Batallion Shield", "arccw_cgi_k_cgshield", "special", 2, 2, 150, "models/kraken/cgi/v_cgi_cgshield.mdl", "entities/arccw/kraken/cgi/cg_shield.png")
AddItem("arccw_cgi_k_dc15a", "DC-15a", "arccw_cgi_k_dc15a", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dc15a.mdl", "entities/arccw/kraken/cgi/15a.png")
AddItem("arccw_cgi_k_dc15a_stun", "DC-15a Stun", "arccw_cgi_k_dc15a_stun", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dc15a.mdl", "entities/arccw/kraken/cgi/15a_stun.png")
AddItem("arccw_cgi_k_dc15a_training", "DC-15a Training", "arccw_cgi_k_dc15a_training", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dc15a.mdl", "entities/arccw/kraken/cgi/15a_training.png")
AddItem("arccw_cgi_k_dc15c", "DC-15c", "arccw_cgi_k_dc15c", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dc15a_shotgun.mdl", "entities/arccw/kraken/cgi/15c.png")
AddItem("arccw_cgi_k_dc15s", "DC-15s", "arccw_cgi_k_dc15s", "primary", 3, 2, 100, "models/kraken/cgi/world/w_cgi_dc15s.mdl", "entities/arccw/kraken/cgi/15s.png")
AddItem("arccw_cgi_k_dc15s_stun", "DC-15s Stun", "arccw_cgi_k_dc15s_stun", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dc15s.mdl", "entities/arccw/kraken/cgi/15s_stun.png")
AddItem("arccw_cgi_k_dc15s_training", "DC-15s Training", "arccw_cgi_k_dc15s_training", "primary", 3, 2, 100, "models/kraken/cgi/world/w_cgi_dc15s.mdl", "entities/arccw/kraken/cgi/15s_training.png")
AddItem("arccw_cgi_k_dc15sa", "DC-15sa", "arccw_cgi_k_dc15sa", "primary", 3, 2, 100, "models/kraken/cgi/world/w_cgi_dc15sa.mdl", "entities/arccw/kraken/cgi/15sa.png")
AddItem("arccw_cgi_k_dc15x", "DC-15x", "arccw_cgi_k_dc15x", "primary", 5, 2, 150, "models/kraken/cgi/world/w_cgi_dc15x.mdl", "entities/arccw/kraken/cgi/15x.png")
AddItem("arccw_cgi_k_dc17", "DC-17", "arccw_cgi_k_dc17", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17.mdl", "entities/arccw/kraken/cgi/17.png")
AddItem("arccw_cgi_k_dc17_commando", "DC-17s", "arccw_cgi_k_dc17_commando", "secondary", 2, 1, 60, "models/arccw/kraken/w_e11.mdl", "entities/arccw/kraken/cgi/17_commando.png")
AddItem("arccw_cgi_k_dc17_ext", "DC-17 Extended", "arccw_cgi_k_dc17_ext", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17ext.mdl", "entities/arccw/kraken/cgi/17_ext.png")
AddItem("arccw_cgi_k_dc17_heavy", "DC-17 Heavy", "arccw_cgi_k_dc17_heavy", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17h.mdl", "entities/arccw/kraken/cgi/17_heavy.png")
AddItem("arccw_cgi_k_dc17_revolver", "DC-17 Revolver", "arccw_cgi_k_dc17_revolver", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17revolver.mdl", "entities/arccw/kraken/cgi/17_revolver.png")
AddItem("arccw_cgi_k_dc17_stun", "DC-17 Stun", "arccw_cgi_k_dc17_stun", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17.mdl", "entities/arccw/kraken/cgi/17_stun.png")
AddItem("arccw_cgi_k_dc17_training", "DC-17 Training", "arccw_cgi_k_dc17_training", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17.mdl", "entities/arccw/kraken/cgi/17_train.png")
AddItem("arccw_cgi_k_dc17m_rifle", "DC-17m Rifle", "arccw_cgi_k_dc17m_rifle", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17m_rifle.mdl", "entities/arccw/kraken/cgi/17m_rifle.png")
AddItem("arccw_cgi_k_dc17m_shotgun", "DC-17m Shotgun", "arccw_cgi_k_dc17m_shotgun", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17m_shotgun.mdl", "entities/arccw/kraken/cgi/17m_shotgun.png")
AddItem("arccw_cgi_k_dc17m_sniper", "DC-17m Sniper", "arccw_cgi_k_dc17m_sniper", "secondary", 2, 1, 60, "models/kraken/cgi/world/w_cgi_dc17m_sniper.mdl", "entities/arccw/kraken/cgi/17m_sniper.png")
AddItem("arccw_cgi_k_dc19", "DC-19", "arccw_cgi_k_dc19", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dc19.mdl", "entities/arccw/kraken/cgi/dc19.png")
AddItem("arccw_cgi_k_dlt16", "DLT-16", "arccw_cgi_k_dlt16", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dlt16.mdl", "entities/arccw/kraken/cgi/dlt16.png")
AddItem("arccw_cgi_k_dlt16s", "DLT-16s", "arccw_cgi_k_dlt16s", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dlt16s.mdl", "entities/arccw/kraken/cgi/dlt16s.png")
AddItem("arccw_cgi_k_dp23", "DP-23", "arccw_cgi_k_dp23", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dp23.mdl", "entities/arccw/kraken/cgi/dp23.png")
AddItem("arccw_cgi_k_dp24", "DP-24", "arccw_cgi_k_dp24", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dp24.mdl", "entities/arccw/kraken/cgi/dp24.png")
AddItem("arccw_cgi_k_dr18", "DR-18", "arccw_cgi_k_dr18", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dr18.mdl", "entities/arccw/kraken/cgi/dr18.png")
AddItem("arccw_cgi_k_dr20", "DR-20", "arccw_cgi_k_dr20", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_dr20.mdl", "entities/arccw/kraken/cgi/dr20.png")
AddItem("arccw_cgi_k_e5", "E-5", "arccw_cgi_k_e5", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_e5.mdl", "entities/arccw/kraken/cgi/e5.png")
AddItem("arccw_cgi_k_e5bx", "E-5-BX", "arccw_cgi_k_e5bx", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_e5.mdl", "entities/arccw/kraken/cgi/e5bx.png")
AddItem("arccw_cgi_k_e5c", "E-5c", "arccw_cgi_k_e5c", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_e5c.mdl", "entities/arccw/kraken/cgi/e5c.png")
AddItem("arccw_cgi_k_e9d", "E-9d", "arccw_cgi_k_e9d", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_e9d.mdl", "entities/arccw/kraken/cgi/e9d.png")
AddItem("arccw_cgi_k_republicshield", "Republic Shield", "arccw_cgi_k_republicshield", "special", 2, 2, 150, "models/kraken/cgi/v_cgi_republicshield.mdl", "entities/arccw/kraken/cgi/republic_shield.png")
AddItem("arccw_cgi_k_rps6", "RPS-6", "arccw_cgi_k_rps6", "primary", 5, 2, 250, "models/kraken/cgi/world/w_cgi_rps6.mdl", "entities/arccw/kraken/cgi/rps6.png")
AddItem("arccw_cgi_k_westarm5", "Westar M5", "arccw_cgi_k_westarm5", "primary", 4, 2, 100, "models/kraken/cgi/world/w_cgi_westarm5.mdl", "entities/arccw/kraken/cgi/westarm5.png")
AddItem("arccw_cgi_k_z6", "Z-6", "arccw_cgi_k_z6", "primary", 5, 2, 250, "models/kraken/cgi/world/w_cgi_z6.mdl", "entities/arccw/kraken/cgi/z6.png")
AddItem("arccw_cgi_k_z6adv", "Z-6 Advanced", "arccw_cgi_k_z6adv", "primary", 5, 2, 250, "models/kraken/cgi/world/w_cgi_z6adv.mdl", "entities/arccw/kraken/cgi/z6adv.png")
AddItem("arccw_cgi_k_z6chain", "Z-6 Chaingun", "arccw_cgi_k_z6chain", "primary", 5, 2, 250, "models/kraken/cgi/world/w_cgi_z6chain.mdl", "entities/arccw/kraken/cgi/z6chain.png")
AddItem("arccw_cj9", "CJ-9", "arccw_cj9", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_cj9.png")
AddItem("arccw_cr2", "CR-2", "arccw_cr2", "primary", 4, 2, 100, "models/arccw/bf2017/w_e11.mdl", "materials/entities/rw_sw_cr2.png")
AddItem("arccw_cr2c", "CR-2C", "arccw_cr2c", "primary", 4, 2, 100, "models/arccw/bf2017/w_e11.mdl", "materials/entities/rw_sw_cr2c.png")
AddItem("arccw_defender", "Defender", "arccw_defender", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_d.png")
AddItem("arccw_defender_sporting", "Defender Sporting", "arccw_defender_sporting", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_defender.png")
AddItem("arccw_dl18", "DL-18", "arccw_dl18", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_dl18.png")
AddItem("arccw_dl44", "DL-44", "arccw_dl44", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_dl44.png")
AddItem("arccw_dt12", "DT-12", "arccw_dt12", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_dt12.png")
AddItem("arccw_dual_defender", "Dual ", "arccw_dual_defender", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_d.png")
AddItem("arccw_dual_defender_sporting", "Dual ", "arccw_dual_defender_sporting", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_defender.png")
AddItem("arccw_dual_dl44", "Dual DL-44", "arccw_dual_dl44", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_dl44.png")
AddItem("arccw_dual_dt12", "Dual DT-12", "arccw_dual_dt12", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_dt12.png")
AddItem("arccw_dual_ib94", "Dual IB-94", "arccw_dual_ib94", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_ib94.png")
AddItem("arccw_dual_ll30", "Dual LL-94", "arccw_dual_ll30", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_ll30.png")
AddItem("arccw_dual_westar34", "Dual Westar 34", "arccw_dual_westar34", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_westar34.png")
AddItem("arccw_dual_westar35", "Dual Westar 35", "arccw_dual_westar35", "primary", 4, 2, 100, "models/arccw/weapons/synbf3/w_scoutblaster.mdl", "materials/entities/rw_sw_dual_westar35.png")
AddItem("arccw_ee3", "EE-3", "arccw_ee3", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_ee3a.png")
AddItem("arccw_eq_designator", "Eq Designator (No File)", "arccw_eq_designator", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arccw_hunter_shotgun", "Hunter Shotgun", "arccw_hunter_shotgun", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_huntershotgun.png")
AddItem("arccw_ib94", "IB-94", "arccw_ib94", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_ib94.png")
AddItem("arccw_iqa11", "IQA-11", "arccw_iqa11", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_iqa11.png")
AddItem("arccw_k16", "K-16 ", "arccw_k16", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_k16.png")
AddItem("arccw_k23", "K-23 ", "arccw_k23", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_relbyk23.png")
AddItem("arccw_k_b2hand", "B2 Handblaster", "arccw_k_b2hand", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_b2hand.mdl", "entities/arccw/kraken/republic-arsenal/b2blaster.png")
AddItem("arccw_k_cgi_an14", "AN-14", "arccw_k_cgi_an14", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/an14.png")
AddItem("arccw_k_cgi_btx12", "BTX-12", "arccw_k_cgi_btx12", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/btx12.png")
AddItem("arccw_k_cgi_btx32", "BTX-32", "arccw_k_cgi_btx32", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/btx32.png")
AddItem("arccw_k_cgi_btx42pistol", "BTX-42 Pistol", "arccw_k_cgi_btx42pistol", "secondary", 2, 1, 60, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/btx42pistol.png")
AddItem("arccw_k_cgi_dc10", "DC-10", "arccw_k_cgi_dc10", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/dc10.png")
AddItem("arccw_k_cgi_dc17sa", "DC-17SA", "arccw_k_cgi_dc17sa", "secondary", 2, 1, 60, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/dc17sa.png")
AddItem("arccw_k_cgi_dc21", "DC-21", "arccw_k_cgi_dc21", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/dc21.png")
AddItem("arccw_k_cgi_e7", "E-7", "arccw_k_cgi_e7", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/e7.png")
AddItem("arccw_k_cgi_iqa11", "IQA-11", "arccw_k_cgi_iqa11", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/iqa11.png")
AddItem("arccw_k_cgi_nt220", "NT-220", "arccw_k_cgi_nt220", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/nt220.png")
AddItem("arccw_k_cgi_nt240x", "NT-240x", "arccw_k_cgi_nt240x", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/nt240x.png")
AddItem("arccw_k_cgi_rps4", "RPS-4", "arccw_k_cgi_rps4", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/rps4.png")
AddItem("arccw_k_cgi_sc16", "SC-16", "arccw_k_cgi_sc16", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/sc16.png")
AddItem("arccw_k_cgi_t20", "T-20", "arccw_k_cgi_t20", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/t20.png")
AddItem("arccw_k_cgi_t22", "T-22", "arccw_k_cgi_t22", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/t22.png")
AddItem("arccw_k_cgi_vibrokatana", "Vibrokatana", "arccw_k_cgi_vibrokatana", "primary", 4, 2, 100, "models/arccw/kraken/cgi_galactic/v_vibrokatana.mdl", "entities/kraken/cgigalactic/vibrokatana.png")
AddItem("arccw_k_cgi_westar35_gau", "WESTAR GAU-35", "arccw_k_cgi_westar35_gau", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/gau35.png")
AddItem("arccw_k_cgi_westar35c", "WESTAR-35c", "arccw_k_cgi_westar35c", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/westar35c.png")
AddItem("arccw_k_cgi_westar35p", "WESTAR-35p", "arccw_k_cgi_westar35p", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/westar35p.png")
AddItem("arccw_k_cgi_westar35r", "WESTAR-35r", "arccw_k_cgi_westar35r", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/westar35r.png")
AddItem("arccw_k_cgi_westar35s", "WESTAR-35s", "arccw_k_cgi_westar35s", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/westar35s.png")
AddItem("arccw_k_cgi_westar35sc", "WESTAR-35sc", "arccw_k_cgi_westar35sc", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/westar35sc.png")
AddItem("arccw_k_cgi_westar35sg", "WESTAR-35sg", "arccw_k_cgi_westar35sg", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/westar35sg.png")
AddItem("arccw_k_cgi_westar35smg", "WESTAR-35smg", "arccw_k_cgi_westar35smg", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/cgigalactic/westar35smg.png")
AddItem("arccw_k_cgi_westarm5_heavy", "WESTAR M5 Heavy", "arccw_k_cgi_westarm5_heavy", "primary", 5, 2, 250, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/westarm5h.png")
AddItem("arccw_k_cgi_westarm5_sniper", "WESTAR M5 Sniper", "arccw_k_cgi_westarm5_sniper", "primary", 5, 2, 150, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/westarm5s.png")
AddItem("arccw_k_cgi_z6x_ion", "Z-6 Mortar", "arccw_k_cgi_z6x_ion", "primary", 5, 2, 250, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/cgigalactic/z6mortar.png")
AddItem("arccw_k_coruscantguardshield", "Coruscant Guard Shield", "arccw_k_coruscantguardshield", "special", 2, 2, 150, "models/arccw/kraken-new/republic/v_cgshield.mdl", "entities/arccw/kraken/republic-arsenal/atts/cg_shield.png")
AddItem("arccw_k_dc15a", "DC-15a", "arccw_k_dc15a", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dc15a.mdl", "entities/arccw/kraken/republic-arsenal/dc15a.png")
AddItem("arccw_k_dc15a_grenadier", "DC-15a Grenadier", "arccw_k_dc15a_grenadier", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dc15a.mdl", "entities/arccw/kraken/republic-arsenal/dc15a_grenadier.png")
AddItem("arccw_k_dc15a_stun", "DC-15a Stun", "arccw_k_dc15a_stun", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dc15a.mdl", "entities/arccw/kraken/republic-arsenal/dc15a_stun.png")
AddItem("arccw_k_dc15a_train", "DC-15a Training", "arccw_k_dc15a_train", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dc15a.mdl", "entities/arccw/kraken/republic-arsenal/dc15a_training.png")
AddItem("arccw_k_dc15le", "DC-15le", "arccw_k_dc15le", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dc15a.mdl", "entities/arccw/kraken/republic-arsenal/dc15le.png")
AddItem("arccw_k_dc15s", "DC-15s", "arccw_k_dc15s", "primary", 3, 2, 100, "models/arccw/kraken-new/republic/w_dc15s.mdl", "entities/arccw/kraken/republic-arsenal/dc15s.png")
AddItem("arccw_k_dc15s_grenadier", "DC-15s Grenadier", "arccw_k_dc15s_grenadier", "primary", 3, 2, 100, "models/arccw/kraken-new/republic/w_dc15s.mdl", "entities/arccw/kraken/republic-arsenal/dc15s_grenadier.png")
AddItem("arccw_k_dc15s_stun", "DC-15s Stun", "arccw_k_dc15s_stun", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dc15s.mdl", "entities/arccw/kraken/republic-arsenal/dc15s_stun.png")
AddItem("arccw_k_dc15s_train", "DC-15s Training", "arccw_k_dc15s_train", "primary", 3, 2, 100, "models/arccw/kraken-new/republic/w_dc15s.mdl", "entities/arccw/kraken/republic-arsenal/dc15s_training.png")
AddItem("arccw_k_dc15sa", "DC-15sa", "arccw_k_dc15sa", "primary", 3, 2, 100, "models/arccw/kraken-new/republic/w_dc15sa.mdl", "entities/arccw/kraken/republic-arsenal/dc15sa.png")
AddItem("arccw_k_dc15x", "DC-15x", "arccw_k_dc15x", "primary", 5, 2, 150, "models/arccw/kraken-new/republic/w_dc15x.mdl", "entities/arccw/kraken/republic-arsenal/dc15x.png")
AddItem("arccw_k_dc17", "DC-17", "arccw_k_dc17", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17.mdl", "entities/arccw/kraken/republic-arsenal/dc17.png")
AddItem("arccw_k_dc17_akimbo", "Dual DC-17", "arccw_k_dc17_akimbo", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17.mdl", "entities/arccw/kraken/republic-arsenal/dc17_dual.png")
AddItem("arccw_k_dc17_stun", "DC-17 Stun", "arccw_k_dc17_stun", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17.mdl", "entities/arccw/kraken/republic-arsenal/dc17_stun.png")
AddItem("arccw_k_dc17_training", "DC-17 Training", "arccw_k_dc17_training", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17.mdl", "entities/arccw/kraken/republic-arsenal/dc17_training.png")
AddItem("arccw_k_dc17ext", "DC-17 Extended", "arccw_k_dc17ext", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17ext.mdl", "entities/arccw/kraken/republic-arsenal/dc17_ext.png")
AddItem("arccw_k_dc17ext_akimbo", "Dual DC-17 Extended", "arccw_k_dc17ext_akimbo", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17ext.mdl", "entities/arccw/kraken/republic-arsenal/dc17_ext_dual.png")
AddItem("arccw_k_dc17m_rifle_republic", "DC-17m Rifle", "arccw_k_dc17m_rifle_republic", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17m.mdl", "entities/arccw/kraken/republic-arsenal/dc17m.png")
AddItem("arccw_k_dc17m_shotgun_republic", "DC-17m Shotgun", "arccw_k_dc17m_shotgun_republic", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17m.mdl", "entities/arccw/kraken/republic-arsenal/dc17m_shotgun.png")
AddItem("arccw_k_dc17m_sniper_republic", "DC-17m Sniper", "arccw_k_dc17m_sniper_republic", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17m.mdl", "entities/arccw/kraken/republic-arsenal/dc17m_sniper.png")
AddItem("arccw_k_dc17s", "DC-17s", "arccw_k_dc17s", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17s.mdl", "entities/arccw/kraken/republic-arsenal/dc17s.png")
AddItem("arccw_k_dc17s_dual", "Dual DC-17s", "arccw_k_dc17s_dual", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17s.mdl", "entities/arccw/kraken/republic-arsenal/dc17s_dual.png")
AddItem("arccw_k_dc17sa", "DC-17sa", "arccw_k_dc17sa", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17s.mdl", "entities/arccw/kraken/republic-arsenal/dc17sa.png")
AddItem("arccw_k_dc17sa_dual", "Dual DC-17sa", "arccw_k_dc17sa_dual", "secondary", 2, 1, 60, "models/arccw/kraken-new/republic/w_dc17s.mdl", "entities/arccw/kraken/republic-arsenal/dc17sa_dual.png")
AddItem("arccw_k_dc19", "DC-19", "arccw_k_dc19", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dc15s.mdl", "entities/arccw/kraken/republic-arsenal/dc19.png")
AddItem("arccw_k_dp23", "DP-23", "arccw_k_dp23", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dp23.mdl", "entities/arccw/kraken/republic-arsenal/dp23.png")
AddItem("arccw_k_dp23c", "DP-23c", "arccw_k_dp23c", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dp23c.mdl", "entities/arccw/kraken/republic-arsenal/dp23c.png")
AddItem("arccw_k_dp24", "DP-24", "arccw_k_dp24", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dp24.mdl", "entities/arccw/kraken/republic-arsenal/dp24.png")
AddItem("arccw_k_dp24c", "DP-24c", "arccw_k_dp24c", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_dp24c.mdl", "entities/arccw/kraken/republic-arsenal/dp24c.png")
AddItem("arccw_k_e5", "E-5", "arccw_k_e5", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_e5.mdl", "entities/arccw/kraken/republic-arsenal/e5.png")
AddItem("arccw_k_e5bx", "E-5bx", "arccw_k_e5bx", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_e5.mdl", "entities/arccw/kraken/republic-arsenal/e5_bx.png")
AddItem("arccw_k_e5c", "E-5c", "arccw_k_e5c", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_e5c.mdl", "entities/arccw/kraken/republic-arsenal/e5c.png")
AddItem("arccw_k_e5s", "E-5s", "arccw_k_e5s", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_e5s.mdl", "entities/arccw/kraken/republic-arsenal/e5s.png")
AddItem("arccw_k_launcher_e60r", "E-60r", "arccw_k_launcher_e60r", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/e60r.png")
AddItem("arccw_k_launcher_hh12", "Republic HH-12", "arccw_k_launcher_hh12", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/hh12.png")
AddItem("arccw_k_launcher_hh12_empire", "Empire HH-12", "arccw_k_launcher_hh12_empire", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/hh12_imperio.png")
AddItem("arccw_k_launcher_plx1", "Republic PLX-1", "arccw_k_launcher_plx1", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/plx1.png")
AddItem("arccw_k_launcher_plx1_empire", "Empire PLX-1", "arccw_k_launcher_plx1_empire", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/plx1_imperio.png")
AddItem("arccw_k_launcher_rps6", "Republic RPS-6", "arccw_k_launcher_rps6", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/rps6.png")
AddItem("arccw_k_launcher_rps6_empire", "Empire RPS-6", "arccw_k_launcher_rps6_empire", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/rps6_imperio.png")
AddItem("arccw_k_launcher_smartlauncher", "Smart Launcher", "arccw_k_launcher_smartlauncher", "primary", 5, 2, 250, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/smartlauncher.png")
AddItem("arccw_k_nade_antitankmine", "Anti-Tank Mine", "arccw_k_nade_antitankmine", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/at_mine.png")
AddItem("arccw_k_nade_bacta", "Bacta Grenade", "arccw_k_nade_bacta", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/bacta.png")
AddItem("arccw_k_nade_base", "Kraken Kabum", "arccw_k_nade_base", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("arccw_k_nade_blaststick", "Blast Stick", "arccw_k_nade_blaststick", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/blaststick.png")
AddItem("arccw_k_nade_c14", "C-14 Anti-Vehicle Grenade", "arccw_k_nade_c14", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/c14.png")
AddItem("arccw_k_nade_c25", "C-25 Fragmentation Grenade", "arccw_k_nade_c25", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/c25.png")
AddItem("arccw_k_nade_decoy", "Decoy Grenade", "arccw_k_nade_decoy", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/decoy.png")
AddItem("arccw_k_nade_detonite", "Detonite Charge", "arccw_k_nade_detonite", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/detonite.png")
AddItem("arccw_k_nade_dioxis", "Dioxis Grenade", "arccw_k_nade_dioxis", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/dioxis.png")
AddItem("arccw_k_nade_flashbang", "Flash Grenade", "arccw_k_nade_flashbang", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/flash.png")
AddItem("arccw_k_nade_impact", "Impact Grenade", "arccw_k_nade_impact", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/impact.png")
AddItem("arccw_k_nade_plasmagrenade", "Plasma Grenade", "arccw_k_nade_plasmagrenade", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/plasmagrenade.png")
AddItem("arccw_k_nade_sequencecharger", "Sequencer Charge", "arccw_k_nade_sequencecharger", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/sequence_charger.png")
AddItem("arccw_k_nade_shock", "Shock Grenade", "arccw_k_nade_shock", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/shock.png")
AddItem("arccw_k_nade_smoke", "Smoke Grenade", "arccw_k_nade_smoke", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/smoke.png")
AddItem("arccw_k_nade_sonar", "Sonar Grenade", "arccw_k_nade_sonar", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/sonar.png")
AddItem("arccw_k_nade_stun", "Stun Grenade", "arccw_k_nade_stun", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/base.png")
AddItem("arccw_k_nade_thermal", "Class-A Thermal Detonator", "arccw_k_nade_thermal", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/thermal.png")
AddItem("arccw_k_nade_thermalimploder", "Thermal Imploder", "arccw_k_nade_thermalimploder", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/thermalimploder.png")
AddItem("arccw_k_nade_thermite", "Thermite Grenade", "arccw_k_nade_thermite", "special", 1, 1, 30, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/incendiary.png")
AddItem("arccw_k_republic_e9", "E-9", "arccw_k_republic_e9", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_e9.mdl", "entities/arccw/kraken/republic-arsenal/e9.png")
AddItem("arccw_k_republicshield", "Galactic Republic Shield", "arccw_k_republicshield", "special", 2, 2, 150, "models/arccw/kraken-new/republic/v_republicshield.mdl", "entities/arccw/kraken/republic-arsenal/atts/republic_shield.png")
AddItem("arccw_k_rg4d", "RG-4D", "arccw_k_rg4d", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_rg4d.mdl", "entities/arccw/kraken/republic-arsenal/rg4d.png")
AddItem("arccw_k_sb2", "SB-2", "arccw_k_sb2", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_sb2.mdl", "entities/arccw/kraken/republic-arsenal/sb2.png")
AddItem("arccw_k_sg6", "SG-6", "arccw_k_sg6", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_cis_shotgun.mdl", "entities/arccw/kraken/republic-arsenal/cis_shotgun.png")
AddItem("arccw_k_valken38", "Valken 38x", "arccw_k_valken38", "primary", 5, 2, 150, "models/arccw/kraken-new/republic/w_valken38.mdl", "entities/arccw/kraken/republic-arsenal/valken38.png")
AddItem("arccw_k_weapon_antimaterial", "K-43", "arccw_k_weapon_antimaterial", "primary", 4, 2, 100, "models/arccw/kraken/w_e11.mdl", "entities/kraken/explosives/antimaterial_rifle.png")
AddItem("arccw_k_weapon_g125", "G-125", "arccw_k_weapon_g125", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/explosives/g125.png")
AddItem("arccw_k_westarm5", "WESTAR M5", "arccw_k_westarm5", "primary", 4, 2, 100, "models/arccw/kraken-new/republic/w_westar.mdl", "entities/arccw/kraken/republic-arsenal/westarm5.png")
AddItem("arccw_k_z4", "Z-4", "arccw_k_z4", "primary", 4, 2, 100, "models/arccw/kraken-new/cis/w_z4.mdl", "entities/arccw/kraken/republic-arsenal/z4.png")
AddItem("arccw_k_z6", "Z-6", "arccw_k_z6", "primary", 5, 2, 250, "models/arccw/kraken-new/republic/w_z6.mdl", "entities/arccw/kraken/republic-arsenal/z6.png")
AddItem("arccw_k_z6adv", "Z-6 Advanced", "arccw_k_z6adv", "primary", 5, 2, 250, "models/arccw/kraken-new/republic/w_z6.mdl", "entities/arccw/kraken/republic-arsenal/z6_adv.png")
AddItem("arccw_ll30", "LL-30", "arccw_ll30", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_ll30.png")
AddItem("arccw_m57", "M-57", "arccw_m57", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_m57.png")
AddItem("arccw_nn14", "NN-14", "arccw_nn14", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_nn14.png")
AddItem("arccw_nt242", "NT-242", "arccw_nt242", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_nt242.png")
AddItem("arccw_relbyv10", "Relby-v10", "arccw_relbyv10", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_relbyv10.png")
AddItem("arccw_scattershotgun", "Scattershotgun", "arccw_scattershotgun", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_huntershotgun.png")
AddItem("arccw_sops_empire_dlt19d", "DLT-19d", "arccw_sops_empire_dlt19d", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dlt19d.mdl", "entities/kraken/sops/dlt19d.png")
AddItem("arccw_sops_empire_dlt23v", "DLT-23V", "arccw_sops_empire_dlt23v", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dlt23v_imperio.mdl", "entities/kraken/sops/dlt23v.png")
AddItem("arccw_sops_empire_dlt34", "DLT-34", "arccw_sops_empire_dlt34", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dlt34.mdl", "entities/kraken/sops/dlt34.png")
AddItem("arccw_sops_empire_e11x", "E-11x", "arccw_sops_empire_e11x", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_e11x.mdl", "entities/kraken/sops/e11x.png")
AddItem("arccw_sops_empire_ee4", "EE-4", "arccw_sops_empire_ee4", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_ee4.mdl", "entities/kraken/sops/ee4.png")
AddItem("arccw_sops_empire_firepuncher", "Empire ", "arccw_sops_empire_firepuncher", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_firepuncher_empire.mdl", "entities/kraken/sops/firepuncher_imperio.png")
AddItem("arccw_sops_empire_heavyrepeater", "Imperial Repeater", "arccw_sops_empire_heavyrepeater", "primary", 5, 2, 250, "models/arccw/kraken/sops/world/w_imperial_repeater.mdl", "entities/kraken/sops/heavyrepeater.png")
AddItem("arccw_sops_empire_shortfirepuncher", "Empire ", "arccw_sops_empire_shortfirepuncher", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_firepuncher_empire.mdl", "entities/kraken/sops/shortypuncher_imperio.png")
AddItem("arccw_sops_empire_stw48", "STW-48", "arccw_sops_empire_stw48", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_stw48.mdl", "entities/kraken/sops/stw48.png")
AddItem("arccw_sops_empire_tl40", "TL-40", "arccw_sops_empire_tl40", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_tl50.mdl", "entities/kraken/sops/tl40.png")
AddItem("arccw_sops_empire_tl50", "TL-50", "arccw_sops_empire_tl50", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_tl50.mdl", "entities/kraken/sops/tl50.png")
AddItem("arccw_sops_galactic_a180", "A-180", "arccw_sops_galactic_a180", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_a180.mdl", "entities/kraken/sops/a180.png")
AddItem("arccw_sops_galactic_a280cfe", "A-280CFE", "arccw_sops_galactic_a280cfe", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_a280cfe.mdl", "entities/kraken/sops/a280cfe.png")
AddItem("arccw_sops_galactic_b0l3", "B0-L3", "arccw_sops_galactic_b0l3", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_boiler_rifle.mdl", "entities/kraken/sops/b0l3.png")
AddItem("arccw_sops_galactic_b1na", "B1-NA", "arccw_sops_galactic_b1na", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_b1na.mdl", "entities/kraken/sops/b1na.png")
AddItem("arccw_sops_galactic_dca4", "DC-A4", "arccw_sops_galactic_dca4", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dca4.mdl", "entities/kraken/sops/dca4.png")
AddItem("arccw_sops_galactic_de10", "DE-10", "arccw_sops_galactic_de10", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_de10.mdl", "entities/kraken/sops/de10.png")
AddItem("arccw_sops_galactic_deadmansrevenge", "Sops Galactic Deadmansrevenge", "arccw_sops_galactic_deadmansrevenge", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dead_mans_revenge.mdl", "entities/kraken/sops/deadmansrevenge.png")
AddItem("arccw_sops_galactic_deadmanstale", "Dead Man", "arccw_sops_galactic_deadmanstale", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dead_mans_tale.mdl", "entities/kraken/sops/deadmanstale.png")
AddItem("arccw_sops_galactic_deathwatchblaster", "Deathwatch Blaster", "arccw_sops_galactic_deathwatchblaster", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_deathwatch_blaster.mdl", "entities/kraken/sops/deathwatchblaster.png")
AddItem("arccw_sops_galactic_dg29", "DG-29", "arccw_sops_galactic_dg29", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dg29.mdl", "entities/kraken/sops/dg29.png")
AddItem("arccw_sops_galactic_dh16", "DH-16", "arccw_sops_galactic_dh16", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dh16.mdl", "entities/kraken/sops/dh16.png")
AddItem("arccw_sops_galactic_dt40", "DT-40", "arccw_sops_galactic_dt40", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dt40.mdl", "entities/kraken/sops/dt40.png")
AddItem("arccw_sops_galactic_emprifle", "EMP Rifle", "arccw_sops_galactic_emprifle", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_emp_rifle.mdl", "entities/kraken/sops/emprifle.png")
AddItem("arccw_sops_galactic_fc1", "FC-1 Flechette Launcher", "arccw_sops_galactic_fc1", "primary", 5, 2, 250, "models/arccw/kraken/sops/world/w_fc1.mdl", "entities/kraken/sops/fc1.png")
AddItem("arccw_sops_galactic_galaar15", "GALAAR-15", "arccw_sops_galactic_galaar15", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_galaar15.mdl", "entities/kraken/sops/galaar15.png")
AddItem("arccw_sops_galactic_galaar15c", "GALAAR-15c", "arccw_sops_galactic_galaar15c", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_galaar15.mdl", "entities/kraken/sops/galaar15c.png")
AddItem("arccw_sops_galactic_iondisruptor", "T-7 Ion Disruptor", "arccw_sops_galactic_iondisruptor", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_ion_disruptor.mdl", "entities/kraken/sops/iondisruptor.png")
AddItem("arccw_sops_galactic_jawapistol", "Jawa Pistol", "arccw_sops_galactic_jawapistol", "secondary", 2, 1, 60, "models/arccw/kraken/sops/world/w_jawapistol.mdl", "entities/kraken/sops/jawapistol.png")
AddItem("arccw_sops_galactic_k0bu", "K-0Bu", "arccw_sops_galactic_k0bu", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_k0bu.mdl", "entities/kraken/sops/k0bu.png")
AddItem("arccw_sops_galactic_k3bu", "K3b-u", "arccw_sops_galactic_k3bu", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_k3bu.mdl", "entities/kraken/sops/k3bu.png")
AddItem("arccw_sops_galactic_m5d", "M5-D", "arccw_sops_galactic_m5d", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_m5d.mdl", "entities/kraken/sops/m5d.png")
AddItem("arccw_sops_galactic_mandorifle", "Amban Pulse Rifle", "arccw_sops_galactic_mandorifle", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_mandalorianrifle.mdl", "entities/kraken/sops/mandorifle.png")
AddItem("arccw_sops_galactic_mw20", "MW-20", "arccw_sops_galactic_mw20", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_mw20.mdl", "entities/kraken/sops/mw20.png")
AddItem("arccw_sops_galactic_prototypeblaster", "Prototype Blaster", "arccw_sops_galactic_prototypeblaster", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_prototype_blaster.mdl", "entities/kraken/sops/prototypeblaster.png")
AddItem("arccw_sops_galactic_r1ca", "R1-CA", "arccw_sops_galactic_r1ca", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_renegade_carbine.mdl", "entities/kraken/sops/r1ca.png")
AddItem("arccw_sops_galactic_scatterpistol", "Scatter Pistol", "arccw_sops_galactic_scatterpistol", "secondary", 2, 1, 60, "models/arccw/kraken/sops/world/w_scatterpistol.mdl", "entities/kraken/sops/scatterpistol.png")
AddItem("arccw_sops_galactic_tl30", "TL-30", "arccw_sops_galactic_tl30", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_tl30.mdl", "entities/kraken/sops/tl30.png")
AddItem("arccw_sops_galactic_wookieslug", "Wookiee Slug", "arccw_sops_galactic_wookieslug", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_wookie_slug.mdl", "entities/kraken/sops/wookieslug.png")
AddItem("arccw_sops_galactic_z5", "Z5 Red Hydra", "arccw_sops_galactic_z5", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_z5.mdl", "entities/kraken/sops/z5.png")
AddItem("arccw_sops_quadblaster_empire", "Quad-Blaster (Empire)", "arccw_sops_quadblaster_empire", "primary", 4, 2, 100, "models/arccw/kraken/sops/new/w_quadblaster_empire.mdl", "entities/kraken/sops/quad_empire.png")
AddItem("arccw_sops_quadblaster_republic", "Quad Blaster (Republic)", "arccw_sops_quadblaster_republic", "primary", 4, 2, 100, "models/arccw/kraken/sops/new/w_quadblaster_republic.mdl", "entities/kraken/sops/quad_republic.png")
AddItem("arccw_sops_republic_773firepuncher", "Republic ", "arccw_sops_republic_773firepuncher", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/sops/firepuncher_republica.png")
AddItem("arccw_sops_republic_773firepuncher_short", "Republic ", "arccw_sops_republic_773firepuncher_short", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/sops/shortypuncher_republica.png")
AddItem("arccw_sops_republic_dc19", "DC-19", "arccw_sops_republic_dc19", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_dc19.mdl", "entities/kraken/sops/dc19.png")
AddItem("arccw_sops_republic_dlt23v", "DLT-23V", "arccw_sops_republic_dlt23v", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/sops/dlt23v.png")
AddItem("arccw_sops_republic_md12x", "MD-12x", "arccw_sops_republic_md12x", "primary", 4, 2, 100, "models/arccw/kraken/w_dlt19.mdl", "entities/kraken/sops/md12x.png")
AddItem("arccw_sops_republic_rx21", "RX-21 ", "arccw_sops_republic_rx21", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_rx21.mdl", "entities/kraken/sops/rx21.png")
AddItem("arccw_sops_republic_t702", "T-702", "arccw_sops_republic_t702", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_t702.mdl", "entities/kraken/sops/t702.png")
AddItem("arccw_sops_republic_x11", "X-11", "arccw_sops_republic_x11", "primary", 4, 2, 100, "models/arccw/kraken/sops/world/w_x11.mdl", "entities/kraken/sops/x11.png")
AddItem("arccw_sops_republic_z6chaingun", "Z-6 Chaingun", "arccw_sops_republic_z6chaingun", "primary", 5, 2, 250, "models/arccw/kraken/sops/world/w_z6chaingun.mdl", "entities/kraken/sops/z6chaingun.png")
AddItem("arccw_sops_republic_z6x", "ZX-6", "arccw_sops_republic_z6x", "primary", 5, 2, 250, "models/arccw/kraken/sops/world/w_zx6.mdl", "entities/kraken/sops/z6x.png")
AddItem("arccw_sops_vibroknife", "Vibroknife", "arccw_sops_vibroknife", "special", 1, 1, 30, "models/arccw/kraken/sops/world/w_vibroknife.mdl", "entities/kraken/sops/vibroknife.png")
AddItem("arccw_tusken_cycler", "Cycler Rifle", "arccw_tusken_cycler", "primary", 4, 2, 100, "models/arccw/bf2017/w_dlt19.mdl", "materials/entities/rw_sw_tusken_cycler.png")
AddItem("arccw_umb1", "UMB-1", "arccw_umb1", "primary", 4, 2, 100, "models/arccw/bf2017/w_e11.mdl", "materials/entities/rw_sw_umb1.png")
AddItem("arccw_westar11", "Westar-11", "arccw_westar11", "primary", 4, 2, 100, "models/arccw/bf2017/w_e11.mdl", "materials/entities/rw_sw_westar11.png")
AddItem("arccw_westar34", "Westar-34", "arccw_westar34", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_westar34.png")
AddItem("arccw_westar35", "Westar-35", "arccw_westar35", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_westar35.png")
AddItem("arccw_x8", "X-8", "arccw_x8", "primary", 4, 2, 100, "models/arccw/bf2017/w_scoutblaster.mdl", "materials/entities/rw_sw_x8.png")
AddItem("arccw_z2", "Z-2", "arccw_z2", "primary", 4, 2, 100, "models/arccw/bf2017/w_t21.mdl", "materials/entities/rw_sw_z2.png")
AddItem("comlink_fixingtool", "Comlink Fixingtool (No File)", "comlink_fixingtool", "special", 2, 1, 50, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("cw_flamethrower", "Cw Flamethrower (No File)", "cw_flamethrower", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("defuser_bomb", "Defuser Bomb (No File)", "defuser_bomb", "special", 2, 1, 50, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("fort_datapad", "Fort Datapad (No File)", "fort_datapad", "special", 2, 1, 50, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("jet_mk1", "Jet Mk1 (No File)", "jet_mk1", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("jet_mk2", "Jet Mk2 (No File)", "jet_mk2", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("jet_mk5", "Jet Mk5 (No File)", "jet_mk5", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("jet_mk6", "Jet Mk6 (No File)", "jet_mk6", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("keypad_cracker", "Keypad Cracker (No File)", "keypad_cracker", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_blood", "Medic Blood (No File)", "medic_blood", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_dosimetr", "Medic Dosimetr (No File)", "medic_dosimetr", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_ecg_temp", "Medic Ecg Temp (No File)", "medic_ecg_temp", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_exam", "Medic Exam (No File)", "medic_exam", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_expresstest_flu", "Medic Expresstest Flu (No File)", "medic_expresstest_flu", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_medkit", "Medic Medkit (No File)", "medic_medkit", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_nerv_maleol", "Medic Nerv Maleol (No File)", "medic_nerv_maleol", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_ophtalmoscope", "Medic Ophtalmoscope (No File)", "medic_ophtalmoscope", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_otoscope", "Medic Otoscope (No File)", "medic_otoscope", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_pulseoxymetr", "Medic Pulseoxymetr (No File)", "medic_pulseoxymetr", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_scapula", "Medic Scapula (No File)", "medic_scapula", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_shethoscope", "Medic Shethoscope (No File)", "medic_shethoscope", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_therm", "Medic Therm (No File)", "medic_therm", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("medic_tonometr", "Medic Tonometr (No File)", "medic_tonometr", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("mortar_constructor", "Mortar Constructor (No File)", "mortar_constructor", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("mortar_range_finder", "Mortar Range Finder (No File)", "mortar_range_finder", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("realistic_hook", "Realistic Hook (No File)", "realistic_hook", "special", 2, 1, 50, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("sv_datapad", "Sv Datapad (No File)", "sv_datapad", "special", 2, 1, 50, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("turret_placer", "Turret Placer (No File)", "turret_placer", "special", 2, 2, 150, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("waypoint_designator", "Waypoint Designator (No File)", "waypoint_designator", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_bactainjector", "Bactainjector (No File)", "weapon_bactainjector", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_bactanade", "Bactanade (No File)", "weapon_bactanade", "special", 1, 1, 30, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_cuff_elastic", "Cuff Elastic (No File)", "weapon_cuff_elastic", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_defibrillator", "Defibrillator (No File)", "weapon_defibrillator", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_lvsrepair", "Lvsrepair (No File)", "weapon_lvsrepair", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_marker", "Marker (No File)", "weapon_marker", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_med_scanner", "Med Scanner (No File)", "weapon_med_scanner", "special", 2, 1, 50, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_officerboost_laststand", "Officerboost Laststand (No File)", "weapon_officerboost_laststand", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_officerboost_normal", "Officerboost Normal (No File)", "weapon_officerboost_normal", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_squadshield_arm", "Squadshield Arm (No File)", "weapon_squadshield_arm", "special", 2, 2, 150, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_stunstick", "Stunstick (No File)", "weapon_stunstick", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")
AddItem("weapon_vibrosword", "Vibrosword (No File)", "weapon_vibrosword", "primary", 4, 2, 100, "models/weapons/w_rif_ak47.mdl", "icon16/gun.png")

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
            name = "DC-15A 1Бластерная винтовка",
            description = "Стандартная бластерная винтовка клонов",
            icon = "entities/arccw/kraken/republic-arsenal/dc15a.png",
            width = 4,
            height = 2,
            dropModel = "models/arccw/kraken-new/republic/w_dc15a.mdl",
            slotType = "primary",
            weaponClass = "arccw_k_dc15a",
            rarity = "legendary",
            supplyPrice = 50
        })

        NextRP.Inventory:RegisterItem({
            id = "dc15a_stun_correct",
            name = "DC-15A (Stun)",
            description = "Винтовка с оглушением",
            icon = "entities/arccw/kraken/republic-arsenal/dc15a.png",
            width = 4,
            height = 2,
            slotType = "primary",
            
            -- ВАЖНО: Класс из лога ошибки
            weaponClass = "arccw_cgi_k_dc15a_stun", 
            
            supplyPrice = 50,
            rarity = "common"
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