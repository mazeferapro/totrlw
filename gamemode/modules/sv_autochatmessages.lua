local MESSAGES = NextRP.Config.AutoChatMessages

if timer.Exists('NextRP::AutoChatMessages') then timer.Remove('NextRP::AutoChatMessages') end

local i = 0
timer.Create('NextRP::AutoChatMessages', 120, 0, function()
    i = i + 1
    if i > #MESSAGES then i = 1 end
    
    NextRP:SendGlobalMessage(NextRP.Style.Theme.Accent, NextRP.Config.ShortCode, NextRP.Style.Theme.Text, ' | ', NextRP.Style.Theme.Accent, 'Подсказка', NextRP.Style.Theme.Text, ' | ', unpack(MESSAGES[i]))
end)

-- lua/autorun/server/sv_gift_spawner.lua

local SpawnerConfig = {
    EntityClass = "nextrp_gift", 
    MaxGifts = 20,
    SpawnInterval = 120,  
    Debug = true,
    MinDist = 1000,  -- Минимальная дистанция от игрока (чтобы не спавнить в лице)
    MaxDist = 2000, -- Максимальная дистанция (чтобы не спавнить на другом конце карты)
}

local function Log(msg)
    if SpawnerConfig.Debug then print("[Gift Spawner] " .. msg) end
end

local function GetPositionNearPlayer()
    -- 1. Получаем список всех игроков
    local plys = player.GetAll()
    if #plys == 0 then return nil end

    -- 2. Перемешиваем таблицу игроков, чтобы выбирать случайного
    local randomPly = plys[math.random(#plys)]
    
    -- Если игрок мертв или в машине - пропускаем (для надежности)
    if not IsValid(randomPly) or not randomPly:Alive() then return nil end

    -- 3. Строим вектор поиска ОТ ИГРОКА
    -- Берем позицию глаз игрока
    local startPos = randomPly:EyePos() 
    
    -- Выбираем случайное направление на земле (угол)
    local randomAngle = Angle(0, math.random(0, 360), 0)
    local randomDist = math.random(SpawnerConfig.MinDist, SpawnerConfig.MaxDist)
    
    -- Вычисляем конечную точку (куда мы хотим поставить подарок)
    local forwardVec = randomAngle:Forward() * randomDist
    local targetPos = startPos + forwardVec

    -- 4. Пускаем луч ОТ ИГРОКА к этой точке
    -- Это гарантирует, что мы не спавним за стеной или под полом, 
    -- потому что луч идет из валидной точки.
    local tr = util.TraceLine({
        start = startPos,
        endpos = targetPos,
        filter = randomPly, -- Игнорируем самого игрока
        mask = MASK_SOLID_BRUSHONLY -- Ищем только стены/пол
    })

    -- Теперь нам нужно найти пол под этой точкой.
    -- Если мы уперлись в стену (tr.Hit), то ищем пол под местом удара.
    -- Если не уперлись, ищем пол под конечной точкой.
    local searchPos = tr.HitPos
    
    -- Отступаем немного назад от стены, если попали в стену
    if tr.Hit then
        searchPos = tr.HitPos + (tr.HitNormal * 30)
    end

    -- 5. Финальный луч ВНИЗ, чтобы найти пол (но неглубоко!)
    -- Мы ищем пол только в пределах 200 юнитов вниз от уровня глаз игрока.
    -- Это не даст лучу уйти "под карту".
    local downTr = util.TraceLine({
        start = searchPos,
        endpos = searchPos - Vector(0, 0, 500), -- Ищем пол вниз
        mask = MASK_SOLID_BRUSHONLY
    })

    if downTr.Hit and not downTr.StartSolid then
        -- Проверка на небо
        if downTr.HitSky then return nil end
        -- Проверка на воду
        if bit.band(util.PointContents(downTr.HitPos), CONTENTS_WATER) == CONTENTS_WATER then return nil end
        
        -- Проверка нормали (чтобы не спавнить на крутых склонах > 45 градусов)
        if downTr.HitNormal.z < 0.7 then return nil end

        return downTr.HitPos
    end

    return nil
end

local function SpawnGift()
    if #ents.FindByClass(SpawnerConfig.EntityClass) >= SpawnerConfig.MaxGifts then return end

    -- Пытаемся найти точку (несколько попыток за цикл)
    local pos = nil
    for i=1, 5 do
        pos = GetPositionNearPlayer()
        if pos then break end
    end

    if pos then
        local ent = ents.Create(SpawnerConfig.EntityClass)
        if IsValid(ent) then
            -- Спавним чуть выше пола (+20 юнитов)
            ent:SetPos(pos + Vector(0,0,20))
            ent:SetAngles(Angle(0, math.random(0, 360), 0))
            ent:Spawn()
            
            -- ВАЖНО: Добавляем проверку "Анти-провал" прямо в энтити
            -- Если подарок всё-таки упадет под карту (Z < -15000), он удалится
            ent:CallOnRemove("AntiVoid", function(e) end) 
            
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then phys:Wake() end

            Log("Спавн рядом с игроком: " .. tostring(pos))
            local x, y, z = math.Round(pos.x), math.Round(pos.y), math.Round(pos.z)
            print("TP: tp_pos " .. x .. " " .. y .. " " .. z)
        end
    else
        Log("Не нашли валидную точку рядом с игроками.")
    end
end

timer.Create("RandomGiftSpawner", SpawnerConfig.SpawnInterval, 0, SpawnGift)

concommand.Add("force_spawn_gift", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    SpawnGift()
end)

concommand.Add("tp_pos", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    if #args < 3 then return end
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:SetPos(Vector(tonumber(args[1]), tonumber(args[2]), tonumber(args[3])))
end)