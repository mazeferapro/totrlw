--- @classmod Player

local pMeta = FindMetaTable('Player')

pMeta.OldName = pMeta.OldName or pMeta.Name
pMeta.OldNick = pMeta.OldNick or pMeta.Nick

--- Имя персонажа
-- @realm shared
-- @treturn string CharacterFullname 
function pMeta:Name()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_fullname') or self:OldName()
end

--- Имя персонажа
-- @realm shared
-- @treturn string CharacterFullname 
function pMeta:Nick()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_fullname') or self:OldName()
end

function pMeta:Nick1()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_nickname') or self:OldName()
end

--- Имя персонажа
-- @realm shared
-- @treturn string CharacterFullname 
function pMeta:FullName()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_fullname') or self:OldName()
end

--- Фракция персонажа
-- @realm shared
-- @treturn number Faction 
function pMeta:Faction()
    if not IsValid(self) then
        return 1
    end
    return self:GetNVar('nrp_faction') or 1
end

if SERVER then return end

print("[CL SPY] Принудительный перехват всех сетевых сообщений...")

-- Таблица для хранения оригинальных функций, чтобы не оборачивать их дважды
if not _G.OriginalNetReceivers then
    _G.OriginalNetReceivers = {}
end

local min_size_kb = 2 -- Минимальный размер (в КБ) для тревоги

-- Функция-шпион
local function CreateSpy(name, original_func)
    return function(len, ply)
        -- len = длина в битах
        local bytes = len / 8
        local kb = bytes / 1024
        
        -- Ловим только жирные пакеты
        if kb > min_size_kb then
            MsgC(Color(255, 0, 0), string.format("\n[!!! HEAVY PACKET] Имя: %s | Вес: %.2f KB (%d bits)\n", name, kb, len))
        elseif kb > 0.5 then
            MsgC(Color(255, 200, 0), string.format("[NET] %s: %.2f KB\n", name, kb))
        end
        
        -- Вызываем оригинал
        if original_func then
            local b, err = pcall(original_func, len, ply)
            if not b then
                ErrorNoHalt("[SPY ERROR in " .. name .. "]: " .. tostring(err) .. "\n")
            end
        end
    end
end

-- 1. Перехватываем УЖЕ зарегистрированные сообщения (самое важное)
local count = 0
local net_table = net.Receivers -- Внутренняя таблица GMod

for name, func in pairs(net_table) do
    -- Проверяем, не перехватили ли мы это уже
    if not _G.OriginalNetReceivers[name] then
        _G.OriginalNetReceivers[name] = func -- Сохраняем оригинал
        net_table[name] = CreateSpy(name, func) -- Подменяем на шпиона
        count = count + 1
    end
end

print("[CL SPY] Успешно перехвачено " .. count .. " активных сетевых каналов.")

-- 2. Перехватываем БУДУЩИЕ регистрации (на всякий случай)
local old_receive = net.Receive
function net.Receive(name, func, ...)
    _G.OriginalNetReceivers[name] = func
    -- Регистрируем сразу нашего шпиона
    old_receive(name, CreateSpy(name, func), ...)
end

-- lua/autorun/server/sv_filescanner.lua

if CLIENT then return end

print("[SCANNER] Начинаю полное сканирование файлов на наличие 'urpc'...")
print("[SCANNER] Это может занять несколько секунд...")

-- Что ищем (в нижнем регистре)
local SEARCH_TERM = "urpc"
local SEARCH_PATTERN = "\"[uU][rR][pP][cC]\"" -- Ищет "urpc" в кавычках

local files_found = 0

-- Рекурсивная функция для обхода папок
local function ScanDirectory(path)
    -- Получаем файлы и папки
    local files, folders = file.Find(path .. "*", "GAME")

    if not files then return end

    -- 1. Проверяем файлы
    for _, filename in ipairs(files) do
        if string.EndsWith(filename, ".lua") then
            -- Читаем файл
            local full_path = path .. filename
            local content = file.Read(full_path, "GAME")

            if content then
                -- Переводим в нижний регистр для поиска
                local content_lower = string.lower(content)
                
                -- Ищем вхождение "urpc"
                -- Мы ищем именно добавление сетевой строки или старт
                if string.find(content_lower, "\"urpc\"", 1, true) or string.find(content_lower, "\'urpc\'", 1, true) then
                    print("\n[НАЙДЕНО!] >>> " .. full_path)
                    files_found = files_found + 1
                    
                    -- Пытаемся показать строку (бонус)
                    local lines = string.Explode("\n", content)
                    for i, line in ipairs(lines) do
                        if string.find(string.lower(line), "urpc") then
                            print("   Строка " .. i .. ": " .. string.Trim(line))
                            break -- Показываем только первое совпадение в файле
                        end
                    end
                end
            end
        end
    end

    -- 2. Рекурсивно идем в папки
    for _, folder in ipairs(folders) do
        -- Пропускаем папки карт и материалов, там нет Lua
        if folder ~= "maps" and folder ~= "materials" and folder ~= "models" and folder ~= "sound" then
            ScanDirectory(path .. folder .. "/")
        end
    end
end

-- Запускаем сканирование по главным папкам
-- Обычно аддоны лежат тут:
ScanDirectory("addons/")
ScanDirectory("lua/")
ScanDirectory("gamemodes/")

print("[SCANNER] Сканирование завершено. Найдено файлов: " .. files_found)