NextRP.Ammunition = NextRP.Ammunition or {}

-- Настройка глобального снабжения
NextRP.Ammunition.Config = {
    MaxSupply = 10000,      -- Максимум очков снабжения
    RegenAmount = 5,        -- Сколько очков восстанавливается
    RegenInterval = 60,     -- Интервал восстановления (секунды)
    
    -- Список предметов в ящике
    -- itemID: ID предмета из sh_inventory.lua
    -- price: Стоимость в очках снабжения
    Items = {
        { itemID = "weapon_dc15a", price = 100 },
        { itemID = "weapon_dc15s", price = 80 },
        { itemID = "weapon_dc17",  price = 50 },
        { itemID = "medkit",       price = 25 },
        { itemID = "ammo_rifle",   price = 10 },
        { itemID = "grenade_frag", price = 150 },
    }
}