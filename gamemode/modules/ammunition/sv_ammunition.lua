-- ============================================================================
-- sv_ammunition.lua - Система снабжения с сохранением в БД для каждой карты
-- ============================================================================

local cfg = NextRP.Ammunition.Config

-- Локальная переменная для кэширования текущих очков (избегаем постоянных запросов к БД)
local cachedSupplyPoints = nil
local currentMap = game.GetMap()

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ ТАБЛИЦЫ В БД
-- ============================================================================

hook.Add("DatabaseInitialized", "NextRP::Ammunition_DB_Init", function()
    MySQLite.query([[
        CREATE TABLE IF NOT EXISTS nextrp_supply_points (
            map_name VARCHAR(128) NOT NULL PRIMARY KEY,
            supply_points INT DEFAULT 10000,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]], function()
        MsgC(Color(0, 255, 0), "[NextRP Ammunition] Таблица очков снабжения создана!\n")
        -- После создания таблицы загружаем данные
        NextRP.Ammunition:LoadSupplyPoints()
    end)
end)

-- ============================================================================
-- ФУНКЦИИ РАБОТЫ С ОЧКАМИ СНАБЖЕНИЯ
-- ============================================================================

-- Загрузка очков снабжения из БД
function NextRP.Ammunition:LoadSupplyPoints(callback)
    MySQLite.query(string.format(
        "SELECT supply_points FROM nextrp_supply_points WHERE map_name = %s",
        MySQLite.SQLStr(currentMap)
    ), function(result)
        if result and result[1] then
            cachedSupplyPoints = tonumber(result[1].supply_points) or cfg.MaxSupply
            MsgC(Color(0, 255, 100), "[NextRP Ammunition] Загружено " .. cachedSupplyPoints .. " очков снабжения для карты: " .. currentMap .. "\n")
        else
            -- Карты нет в БД - создаём запись с максимальным значением (используем INSERT IGNORE чтобы избежать ошибки дубликата)
            cachedSupplyPoints = cfg.MaxSupply
            MySQLite.query(string.format(
                "INSERT IGNORE INTO nextrp_supply_points (map_name, supply_points) VALUES (%s, %d)",
                MySQLite.SQLStr(currentMap),
                cfg.MaxSupply
            ), function()
                MsgC(Color(0, 255, 100), "[NextRP Ammunition] Создана запись для карты: " .. currentMap .. " с " .. cfg.MaxSupply .. " очками\n")
            end)
        end
        
        -- Синхронизируем с клиентами
        SetGlobalInt("NextRP_SupplyPoints", cachedSupplyPoints)
        
        if callback then callback(cachedSupplyPoints) end
    end)
end

-- Сохранение очков снабжения в БД
function NextRP.Ammunition:SaveSupplyPoints(points)
    if points == nil then points = cachedSupplyPoints end
    if points == nil then return end
    
    MySQLite.query(string.format(
        "INSERT INTO nextrp_supply_points (map_name, supply_points) VALUES (%s, %d) ON DUPLICATE KEY UPDATE supply_points = %d",
        MySQLite.SQLStr(currentMap),
        points,
        points
    ))
end

-- Получить текущие очки снабжения
function NextRP.Ammunition:GetSupplyPoints()
    return cachedSupplyPoints or GetGlobalInt("NextRP_SupplyPoints", cfg.MaxSupply)
end

-- Установить очки снабжения
function NextRP.Ammunition:SetSupplyPoints(points, save)
    points = math.Clamp(points, 0, cfg.MaxSupply)
    cachedSupplyPoints = points
    SetGlobalInt("NextRP_SupplyPoints", points)
    
    -- По умолчанию сохраняем в БД
    if save ~= false then
        self:SaveSupplyPoints(points)
    end
    
    return points
end

-- Добавить очки снабжения
function NextRP.Ammunition:AddSupplyPoints(amount, save)
    local current = self:GetSupplyPoints()
    return self:SetSupplyPoints(current + amount, save)
end

-- Потратить очки снабжения
function NextRP.Ammunition:SpendSupplyPoints(amount, save)
    local current = self:GetSupplyPoints()
    if current < amount then return false end
    self:SetSupplyPoints(current - amount, save)
    return true
end

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ ПРИ СТАРТЕ СЕРВЕРА
-- ============================================================================

hook.Add("Initialize", "NextRP::SupplyInit", function()
    -- Устанавливаем начальное значение (будет перезаписано после загрузки из БД)
    SetGlobalInt("NextRP_SupplyPoints", cfg.MaxSupply)
end)

-- Загрузка после полной инициализации (на случай если DatabaseInitialized не сработал)
hook.Add("InitPostEntity", "NextRP::SupplyLoadFallback", function()
    timer.Simple(2, function()
        if cachedSupplyPoints == nil then
            MsgC(Color(255, 200, 0), "[NextRP Ammunition] Fallback загрузка очков снабжения...\n")
            NextRP.Ammunition:LoadSupplyPoints()
        end
    end)
end)

-- ============================================================================
-- ТАЙМЕР РЕГЕНЕРАЦИИ
-- ============================================================================

timer.Create("NextRP::SupplyRegen", cfg.RegenInterval, 0, function()
    local current = NextRP.Ammunition:GetSupplyPoints()
    if current < cfg.MaxSupply then
        local newValue = math.min(current + cfg.RegenAmount, cfg.MaxSupply)
        NextRP.Ammunition:SetSupplyPoints(newValue, true)
    end
end)

-- ============================================================================
-- ПЕРИОДИЧЕСКОЕ СОХРАНЕНИЕ (на случай крашей)
-- ============================================================================

timer.Create("NextRP::SupplyAutoSave", 300, 0, function() -- Каждые 5 минут
    if cachedSupplyPoints then
        NextRP.Ammunition:SaveSupplyPoints()
        MsgC(Color(100, 200, 100), "[NextRP Ammunition] Автосохранение: " .. cachedSupplyPoints .. " очков\n")
    end
end)

-- Сохранение при выключении сервера
hook.Add("ShutDown", "NextRP::SupplySaveOnShutdown", function()
    if cachedSupplyPoints then
        -- Используем синхронный запрос при выключении
        MySQLite.query(string.format(
            "UPDATE nextrp_supply_points SET supply_points = %d WHERE map_name = %s",
            cachedSupplyPoints,
            MySQLite.SQLStr(currentMap)
        ))
        MsgC(Color(255, 200, 0), "[NextRP Ammunition] Сохранено при выключении: " .. cachedSupplyPoints .. " очков\n")
    end
end)

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================

-- Получение флагов игрока
local function GetPlyFlags(ply)
    if not IsValid(ply) then return {} end
    
    local flags = ply:GetNVar('nrp_charflags')
    if flags and istable(flags) then
        return flags
    end
    
    return {}
end

-- Получение ранга игрока
local function GetPlyRank(ply, jobData)
    if not IsValid(ply) then return "" end
    
    local rank = ply:GetNVar('nrp_rankid')
    if rank and rank ~= "" and rank ~= false then
        return rank
    end
    
    if jobData and jobData.default_rank then
        return jobData.default_rank
    end
    
    return ""
end

-- ============================================================================
-- ПРОВЕРКА РАЗРЕШЕНИЯ НА ПОЛУЧЕНИЕ ПРЕДМЕТА
-- ============================================================================

local function CanPlayerGetItem(ply, itemID)
    local itemData = NextRP.Inventory:GetItemData(itemID)
    if not itemData or not itemData.weaponClass then return false end
    
    local targetWepClass = itemData.weaponClass
    local jobData = ply:getJobTable()
    if not jobData then return false end
    
    local myRank = GetPlyRank(ply, jobData)
    local myFlags = GetPlyFlags(ply)
    
    local allowed = false
    local anyFlagReplacesWeapon = false
    
    -- Проверяем есть ли флаг с replaceWeapon
    if jobData.flags and table.Count(myFlags) > 0 then
        for flagKey, flagActive in pairs(myFlags) do
            if not flagActive then continue end
            
            local flagData = jobData.flags[flagKey]
            if not flagData then
                for k, v in pairs(jobData.flags) do
                    if v.id == flagKey then flagData = v break end
                end
            end
            
            if flagData and flagData.replaceWeapon then
                anyFlagReplacesWeapon = true
                break
            end
        end
    end
    
    -- 1. Проверка ранга (только если нет флага с replaceWeapon)
    if not anyFlagReplacesWeapon then
        if jobData.ranks and jobData.ranks[myRank] then
            local rankData = jobData.ranks[myRank]
            if rankData.weapon and rankData.weapon.ammunition then
                for _, class in pairs(rankData.weapon.ammunition) do
                    if class == targetWepClass then 
                        allowed = true 
                        break 
                    end
                end
            end
        end
    end
    
    -- 2. Проверка флагов
    if jobData.flags and table.Count(myFlags) > 0 then
        for flagKey, flagActive in pairs(myFlags) do
            if not flagActive then continue end
            
            local flagData = jobData.flags[flagKey]
            if not flagData then
                for k, v in pairs(jobData.flags) do
                    if v.id == flagKey then flagData = v break end
                end
            end
            
            if flagData and flagData.weapon and flagData.weapon.ammunition then
                for _, class in pairs(flagData.weapon.ammunition) do
                    if class == targetWepClass then 
                        allowed = true 
                        break 
                    end
                end
            end
            
            if allowed then break end
        end
    end
    
    return allowed
end

-- ============================================================================
-- ПОКУПКА ПРЕДМЕТА
-- ============================================================================

netstream.Hook("NextRP::Ammunition::Buy", function(ply, data)
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Проверка дистанции до NPC
    if data.entIndex then
        local ent = Entity(data.entIndex)
        if IsValid(ent) and ent:GetClass() == "nextrp_ammunition" then
            if ply:GetPos():DistToSqr(ent:GetPos()) > 300*300 then return end
        end
    end

    local itemID = data.itemID
    
    -- Проверка разрешения
    if not CanPlayerGetItem(ply, itemID) then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Этот предмет недоступен для вашего звания/должности.")
        return
    end
    
    local itemDef = NextRP.Inventory:GetItemData(itemID)
    if not itemDef then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Предмет не найден!")
        return
    end
    
    local price = itemDef.supplyPrice or 0
    local currentSupply = NextRP.Ammunition:GetSupplyPoints()
    
    -- Проверка достаточности очков
    if currentSupply < price then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "На базе недостаточно очков снабжения!")
        return
    end
    
    -- Добавляем предмет в инвентарь
    local success, err = NextRP.Inventory:AddItem(ply, itemID, 1)
    
    if success then
        -- Списываем очки и сохраняем в БД
        NextRP.Ammunition:SetSupplyPoints(currentSupply - price, true)
        ply:SendMessage(MESSAGE_TYPE_SUCCESS, "Вы получили: " .. itemDef.name)
        ply:EmitSound("items/ammo_pickup.wav")
    else
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Ошибка: " .. (err or "Инвентарь полон"))
    end
end)

-- ============================================================================
-- КОНСОЛЬНЫЕ КОМАНДЫ (АДМИН)
-- ============================================================================

-- Установить очки снабжения
concommand.Add("nextrp_setsupply", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Supply] У вас нет прав!")
        return 
    end
    
    local val = tonumber(args[1])
    if not val then
        local msg = "[Supply] Использование: nextrp_setsupply <количество>"
        if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, msg) else print(msg) end
        return
    end
    
    NextRP.Ammunition:SetSupplyPoints(val, true)
    
    local msg = "[Supply] Установлено " .. val .. " очков снабжения для карты " .. currentMap
    if IsValid(ply) then 
        ply:PrintMessage(HUD_PRINTCONSOLE, msg) 
    end
    MsgC(Color(0, 255, 0), msg .. "\n")
end)

-- Добавить очки снабжения
concommand.Add("nextrp_addsupply", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Supply] У вас нет прав!")
        return 
    end
    
    local val = tonumber(args[1])
    if not val then
        local msg = "[Supply] Использование: nextrp_addsupply <количество>"
        if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, msg) else print(msg) end
        return
    end
    
    local newVal = NextRP.Ammunition:AddSupplyPoints(val, true)
    
    local msg = "[Supply] Добавлено " .. val .. " очков. Текущее значение: " .. newVal
    if IsValid(ply) then 
        ply:PrintMessage(HUD_PRINTCONSOLE, msg) 
    end
    MsgC(Color(0, 255, 0), msg .. "\n")
end)

-- Показать текущие очки
concommand.Add("nextrp_getsupply", function(ply, cmd, args)
    local current = NextRP.Ammunition:GetSupplyPoints()
    local msg = "[Supply] Карта: " .. currentMap .. " | Очки: " .. current .. "/" .. cfg.MaxSupply
    
    if IsValid(ply) then 
        ply:PrintMessage(HUD_PRINTCONSOLE, msg) 
    else 
        print(msg) 
    end
end)

-- Показать очки всех карт
concommand.Add("nextrp_allsupply", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Supply] У вас нет прав!")
        return 
    end
    
    MySQLite.query("SELECT * FROM nextrp_supply_points ORDER BY map_name", function(result)
        local msg = "\n[Supply] Очки снабжения по картам:\n" .. string.rep("-", 50) .. "\n"
        
        if result then
            for _, row in ipairs(result) do
                local marker = (row.map_name == currentMap) and " <-- ТЕКУЩАЯ" or ""
                msg = msg .. string.format("%-30s %d/%d%s\n", row.map_name, row.supply_points, cfg.MaxSupply, marker)
            end
        else
            msg = msg .. "Нет данных\n"
        end
        
        msg = msg .. string.rep("-", 50)
        
        if IsValid(ply) then 
            ply:PrintMessage(HUD_PRINTCONSOLE, msg) 
        else 
            print(msg) 
        end
    end)
end)

-- Принудительно сохранить
concommand.Add("nextrp_savesupply", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Supply] У вас нет прав!")
        return 
    end
    
    NextRP.Ammunition:SaveSupplyPoints()
    
    local msg = "[Supply] Сохранено: " .. NextRP.Ammunition:GetSupplyPoints() .. " очков для " .. currentMap
    if IsValid(ply) then 
        ply:PrintMessage(HUD_PRINTCONSOLE, msg) 
    end
    MsgC(Color(0, 255, 0), msg .. "\n")
end)

-- Перезагрузить из БД
concommand.Add("nextrp_reloadsupply", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Supply] У вас нет прав!")
        return 
    end
    
    NextRP.Ammunition:LoadSupplyPoints(function(points)
        local msg = "[Supply] Перезагружено: " .. points .. " очков для " .. currentMap
        if IsValid(ply) then 
            ply:PrintMessage(HUD_PRINTCONSOLE, msg) 
        end
        MsgC(Color(0, 255, 0), msg .. "\n")
    end)
end)

-- ============================================================================
-- ПОКУПКА БОЕПРИПАСОВ (напрямую выдаёт патроны игроку, добавляет в инвентарь)
-- ============================================================================

netstream.Hook("NextRP::Ammunition::BuyAmmo", function(ply, data)
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Проверка дистанции до NPC
    if data.entIndex then
        local ent = Entity(data.entIndex)
        if IsValid(ent) and ent:GetClass() == "nextrp_ammunition" then
            if ply:GetPos():DistToSqr(ent:GetPos()) > 300*300 then return end
        end
    end

    local itemID = data.itemID
    
    local itemDef = NextRP.Inventory:GetItemData(itemID)
    if not itemDef then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Предмет не найден!")
        return
    end
    
    
    local price = itemDef.supplyPrice or 0
    local currentSupply = NextRP.Ammunition:GetSupplyPoints()
    
    -- Проверка достаточности очков
    if currentSupply < price then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "На базе недостаточно очков снабжения!")
        return
    end
    
    -- Добавляем предмет в инвентарь (как stackable)
    local success, err = NextRP.Inventory:AddItem(ply, itemID, 1)
    
    if success then
        -- Списываем очки и сохраняем в БД
        NextRP.Ammunition:SetSupplyPoints(currentSupply - price, true)
        ply:SendMessage(MESSAGE_TYPE_SUCCESS, "Вы получили: " .. itemDef.name)
        ply:EmitSound("items/ammo_pickup.wav")
    else
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Ошибка: " .. (err or "Инвентарь полон"))
    end
end)

-- ============================================================================
-- ИСПОЛЬЗОВАНИЕ БОЕПРИПАСОВ ИЗ ИНВЕНТАРЯ
-- ============================================================================

-- Хук для использования предмета боеприпасов
hook.Add("NextRP::Inventory::UseItem", "NextRP::UseAmmoItem", function(ply, itemID, itemData)
    if not itemData.isAmmoItem then return end
    
    local ammoType = itemData.ammoType
    local ammoAmount = itemData.ammoAmount or 30
    
    if ammoType and ammoAmount then
        ply:GiveAmmo(ammoAmount, ammoType, true)
        ply:EmitSound("items/ammo_pickup.wav")
        ply:SendMessage(MESSAGE_TYPE_SUCCESS, "Вы использовали " .. itemData.name .. " (+" .. ammoAmount .. " патронов)")
        return true -- Предмет израсходован
    end
end)

MsgC(Color(0, 255, 100), "[NextRP] Модуль снабжения (sv) загружен! Карта: " .. currentMap .. "\n")