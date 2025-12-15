--[[--
Расширение стандартной библиотеки

Этот модуль являеться расширением стандартной библиотеки [player](https://wiki.facepunch.com/gmod/player%28library%29)
]]--
-- @elib player

--- Поиск игроков в сфере
-- @realm shared
-- @tparam vector pos Позиция центра сферы
-- @tparam number dist Дистанция, в которой нужно искать. aka радиус
-- @treturn table Таблица найденых игроков
-- @author Star#6136 from SWRP Developers
function player.FindInSphere(pos, dist)
    dist = dist * dist
    local t = {}
    for index, ply in player.Iterator() do
        if ply:GetPos():DistToSqr(pos) < dist then
            t[#t + 1] = ply
        end
    end
    return t
end

--- Поиск игроков контролу (фракции)
-- @realm shared
-- @tparam number control Фракция, по которой проводить выборку
-- @treturn table Таблица найденых игроков 
function player.FindByControl(control)
    local t = {}
    for index, ply in player.Iterator() do
        if isbool(ply:getJobTable()) then continue end
        if ply:getJobTable().control == control then
            t[#t + 1] = ply
        end
    end
    return t
end

--- Поиск игрока по ID
-- @realm shared
-- @tparam number nID ID игрока, по которому будет проведём поиск
-- @treturn Player Найденый игрок
function player.GetByPlayerID(nID)
    for k, v in ipairs(player.GetHumans()) do
        if v:GetNVar('nrp_id') == nID then
            return v
        end
    end

    return false
end

function NextRP:GetAvaibleCars(pPlayer)
    -- Базовая реализация - возвращает все доступные машины
    local availableCars = {}
    
    -- Проверяем права игрока и его фракцию
    local playerFaction = pPlayer:GetNVar('nrp_faction') or TYPE_NONE
    
    for class, data in pairs(NextRPCarList or {}) do
        -- Проверяем, может ли игрок использовать эту машину
        if self:CanPlayerUseCar(pPlayer, class, data) then
            availableCars[class] = data
        end
    end
    
    return availableCars
end

function NextRP:CanPlayerUseCar(pPlayer, class, data)
    -- Базовая логика проверки прав
    -- Здесь можно добавить проверки по фракции, рангу и т.д.
    return true -- Пока что разрешаем все
end

hook.Add('HUDPaint', 'xbeastguyx_bloodyscreen', function()
    return
end)

hook.Add("PlayerFootstep", "NextRP_CustomFootsteps", function(ply, pos, foot, sound, volume, filter)
    if not IsValid(ply) then return end
    
    local teamName = team.GetName(ply:Team())
    local charFlags = ply:GetNVar('nrp_charflags') or {}
    
    -- Проверяем админов отдельно
    if teamName == 'Администратор' or teamName == 'Сервочереп' then 
        return true -- Беззвучные шаги для админов
    end
    
    -- Сначала проверяем флаги (приоритет у флагов)
    local footstepConfig = nil
    for flagName, _ in pairs(charFlags) do
        if NextRP.Config.FootstepSoundsByFlag[flagName] then
            footstepConfig = NextRP.Config.FootstepSoundsByFlag[flagName]
            break
        end
    end
    
    -- Если нет кастомных звуков у флагов, проверяем команду
    if not footstepConfig and NextRP.Config.FootstepSounds[teamName] then
        footstepConfig = NextRP.Config.FootstepSounds[teamName]
    end
    
    -- Если нет кастомной конфигурации, используем стандартные звуки
    if not footstepConfig then
        return false -- Позволяем стандартные звуки
    end
    
    -- Если звуки пустые, делаем беззвучные шаги
    if not footstepConfig.sounds or #footstepConfig.sounds == 0 then
        return true
    end
    
    -- Воспроизводим кастомный звук
    local soundToPlay = footstepConfig.sounds[math.random(1, #footstepConfig.sounds)]
    local pitch = math.random(footstepConfig.pitch[1], footstepConfig.pitch[2])
    
    -- Используем EmitSound для воспроизведения звука на сервере
    local soundLevel = 75 -- Уровень звука (дистанция слышимости)
    local soundVolume = footstepConfig.volume or 1.0
    
    -- Проверяем, что звук существует (базовая проверка)
    if soundToPlay and soundToPlay ~= "" then
        ply:EmitSound(soundToPlay, soundLevel, pitch, soundVolume, CHAN_AUTO)
    end
    
    return true -- Блокируем стандартные звуки
end)


--local pipiskiScale = {
--    ['DDT'] = 1.8,
--    ['Терминатор'] = 1.1,
--    ['Огрин'] = 1.7
--}

--hook.Add("PlayerSpawn", "ViewJfs", function(ply)
--    local t = ply:Team()
--    local flags = ply:GetNVar('nrp_charflags') or {}
--    local defaultviewoffset = Vector(0, 0, 64)
--    local defaultviewoffsetducked = Vector(0, 0, 38)
    --[[timer.Simple(0.2, function()
        if NextRP.Config.customScale[team.GetName(t)] then ply:SetViewOffset(defaultviewoffset * NextRP.Config.customScale[team.GetName(t)]) ply:SetViewOffsetDucked(defaultviewoffsetducked * NextRP.Config.customScale[team.GetName(t)]) else ply:SetViewOffset(defaultviewoffset) ply:SetViewOffsetDucked(defaultviewoffsetducked) end
    end)]]--
   -- if next(flags) ~= nil then
 --       for k, v in pairs(flags) do
  --          if pipiskiScale[k] then timer.Simple(.2, function() ply:SetViewOffset(defaultviewoffset * pipiskiScale[k]) ply:SetViewOffsetDucked(defaultviewoffsetducked * pipiskiScale[k]) end) end
 --       end
 --   end
-- end)

function ShowPlayerSpeed(pPlayer)
    local walkSpeed = pPlayer:GetWalkSpeed()
    local runSpeed = pPlayer:GetRunSpeed()
    local slowSpeed = pPlayer:GetSlowWalkSpeed()
    
    pPlayer:ChatPrint("Скорость персонажа:")
    pPlayer:ChatPrint("Ходьба: " .. walkSpeed)
    pPlayer:ChatPrint("Бег: " .. runSpeed) 
    pPlayer:ChatPrint("Медленная ходьба: " .. slowSpeed)
end


function ScaleFixV(pPlayer, scale)
    local defaultviewoffset = Vector(0, 0, 64)
    local defaultviewoffsetducked = Vector(0, 0, 38)
    pPlayer:SetViewOffset(defaultviewoffset * scale)
    pPlayer:SetViewOffsetDucked(defaultviewoffsetducked * scale)
end


concommand.Add("nrp_showspeed", function(pPlayer, cmd, args)
    if not pPlayer:IsAdmin() then return end
    
    local target = pPlayer
    if args[1] then
        target = Player(tonumber(args[1]))
    end
    
    if IsValid(target) then
        ShowPlayerSpeed(target)
    end
end)
