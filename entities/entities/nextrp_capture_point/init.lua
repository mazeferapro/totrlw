-- gamemode/modules/autoevents/entities/nextrp_capture_point/init.lua

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetUseType(SIMPLE_USE)
    
    -- Установка размеров хитбокса
    self:SetCollisionBounds(Vector(-32, -32, 0), Vector(32, 32, 64))
    
    self:SetCaptured(false)
    self:SetActive(false)
    self:SetCaptureProgress(0)
    self:SetPointName("Точка #" .. self:EntIndex())
    self:SetCaptureRadius(100)
    
    -- Эффект для визуализации
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:UpdateColor()
    
    -- НОВЫЕ ПОЛЯ ДЛЯ NPC
    self.spawned_defenders = {}
    self.last_npc_spawn = 0
    self.npc_spawn_interval = 30 -- Спавн NPC каждые 30 секунд если нет защитников
    
    -- Таймер для проверки захвата
    timer.Create("CaptureCheck_" .. self:EntIndex(), 1, 0, function()
        if IsValid(self) then
            self:CheckCapture()
            self:CheckDefenders() -- НОВАЯ ФУНКЦИЯ
        else
            timer.Remove("CaptureCheck_" .. self:EntIndex())
        end
    end)
end

function ENT:OnRemove()
    timer.Remove("CaptureCheck_" .. self:EntIndex())
    
    -- Удаляем всех защитников при удалении точки
    self:ClearDefenders()
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() or not activator:IsAdmin() then
        return
    end
    
    self:OpenConfigMenu(activator)
end

function ENT:UpdateColor()
    if self:GetCaptured() then
        self:SetColor(Color(0, 255, 0, 200)) -- Зеленый - захвачена
    elseif self:GetActive() then
        self:SetColor(Color(255, 165, 0, 200)) -- Оранжевый - активна
    else
        self:SetColor(Color(255, 0, 0, 200)) -- Красный - неактивна
    end
end

-- НОВАЯ ФУНКЦИЯ - Проверка защитников
function ENT:CheckDefenders()
    if not self:GetActive() or self:GetCaptured() then return end
    
    -- Проверяем живых защитников
    local alive_defenders = 0
    for i = #self.spawned_defenders, 1, -1 do
        local npc = self.spawned_defenders[i]
        if IsValid(npc) and npc:Health() > 0 then
            alive_defenders = alive_defenders + 1
        else
            table.remove(self.spawned_defenders, i)
        end
    end
end

-- НОВАЯ ФУНКЦИЯ - Спавн защитников
function ENT:SpawnDefenders(count)
    count = count or 3
    
    -- Получаем настройки NPC из конфига автоивентов
    local map_data = NextRP and NextRP.AutoEvents and NextRP.AutoEvents.Config and 
                    NextRP.AutoEvents.Config.Maps and NextRP.AutoEvents.Config.Maps[game.GetMap()]
    
    local npc_types = {}
    if map_data and map_data.defenders and map_data.defenders.npc_types then
        npc_types = map_data.defenders.npc_types
    else
        -- Резервные типы NPC если нет конфига
        npc_types = {
        }
    end
    
    for i = 1, count do
        local npc_data = npc_types[math.random(1, #npc_types)]
        local npc = self:CreateDefender(npc_data)
        
        if IsValid(npc) then
            table.insert(self.spawned_defenders, npc)
        end
    end
    
    print("[CapturePoint] Создано " .. count .. " защитников для точки " .. self:GetPointName())
end

-- НОВАЯ ФУНКЦИЯ - Создание защитника
function ENT:CreateDefender(npc_data)
    local npc = ents.Create(npc_data.class)
    if not IsValid(npc) then return nil end
    
    -- Позиционирование вокруг точки
    local angle = math.random(0, 360)
    local radius = self:GetCaptureRadius() * 0.7 -- Спавним на 70% радиуса от центра
    local x = math.cos(math.rad(angle)) * radius
    local y = math.sin(math.rad(angle)) * radius
    
    local spawn_pos = self:GetPos() + Vector(x, y, 10)
    
    -- Проверяем, что позиция валидна
    local trace = util.TraceLine({
        start = spawn_pos + Vector(0, 0, 50),
        endpos = spawn_pos - Vector(0, 0, 100),
        filter = function(ent) return ent ~= npc end
    })
    
    if trace.Hit then
        spawn_pos = trace.HitPos + Vector(0, 0, 5)
    end
    
    npc:SetPos(spawn_pos)
    npc:SetAngles(Angle(0, math.random(0, 360), 0))
    npc:Spawn()
    npc:Activate()
    
    -- Настройка NPC
    npc:SetHealth(npc_data.health or 100)
    npc:SetMaxHealth(npc_data.health or 100)
    
    if npc_data.weapon then
        timer.Simple(0.1, function()
            if IsValid(npc) then
                npc:Give(npc_data.weapon)
            end
        end)
    end
    
    -- Настраиваем поведение защитника
    timer.Simple(1, function()
        if IsValid(npc) then
            -- NPC будет патрулировать вокруг точки
            npc:SetSchedule(SCHED_IDLE_WANDER)
            
            -- Устанавливаем ключевые значения для лучшего AI
            npc:SetKeyValue("spawnflags", "256") -- Fall to ground
            npc:SetKeyValue("squadname", "defenders_" .. self:EntIndex())
        end
    end)
    
    -- Автоудаление через 10 минут (защита от накопления)
    timer.Simple(600, function()
        if IsValid(npc) then
            npc:Remove()
        end
    end)
    
    return npc
end

-- НОВАЯ ФУНКЦИЯ - Очистка защитников
function ENT:ClearDefenders()
    for _, npc in pairs(self.spawned_defenders) do
        if IsValid(npc) then
            npc:Remove()
        end
    end
    self.spawned_defenders = {}
end

function ENT:CheckCapture()
    if not self:GetActive() or self:GetCaptured() then return end
    
    local players_in_range = {}
    local npcs_in_range = {}
    
    -- Поиск игроков и NPC в радиусе
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), self:GetCaptureRadius())) do
        if ent:IsPlayer() and ent:Alive() then
            table.insert(players_in_range, ent)
        elseif ent:IsNPC() and ent:Health() > 0 then
            -- Проверяем, является ли NPC защитником этой точки
            local is_defender = false
            for _, defender in pairs(self.spawned_defenders) do
                if defender == ent then
                    is_defender = true
                    break
                end
            end
            
            if is_defender then
                table.insert(npcs_in_range, ent)
            end
        end
    end
    
    local player_count = #players_in_range
    local npc_count = #npcs_in_range
    
    -- Логика захвата
    if player_count > 0 and npc_count == 0 then
        -- Игроки захватывают точку (нет защитников)
        local progress = self:GetCaptureProgress() + (player_count * 2)
        self:SetCaptureProgress(math.min(progress, 100))
        
        if self:GetCaptureProgress() >= 100 then
            self:SetCaptured(true)
            self:UpdateColor()
            self:OnPointCaptured()
        end
    elseif npc_count > 0 and player_count == 0 then
        -- NPC отбивают прогресс
        local progress = self:GetCaptureProgress() - (npc_count * 1)
        self:SetCaptureProgress(math.max(progress, 0))
    elseif player_count > 0 and npc_count > 0 then
        -- Битва между игроками и NPC - прогресс зависит от превосходства
        if player_count > npc_count then
            local progress = self:GetCaptureProgress() + ((player_count - npc_count) * 0.5)
            self:SetCaptureProgress(math.min(progress, 100))
        elseif npc_count > player_count then
            local progress = self:GetCaptureProgress() - ((npc_count - player_count) * 0.5)
            self:SetCaptureProgress(math.max(progress, 0))
        end
        -- Если равенство - прогресс не меняется
    end
end

function ENT:OnPointCaptured()
    -- Уведомление всех игроков
    for _, ply in player.Iterator() do
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTTALK, "Точка '" .. self:GetPointName() .. "' захвачена!")
        end
    end
    
    -- Удаляем всех защитников при захвате
    self:ClearDefenders()
    
    -- Вызов функции в основном модуле
    if NextRP and NextRP.AutoEvents and NextRP.AutoEvents.OnPointCaptured then
        NextRP.AutoEvents.OnPointCaptured()
    end
    
    -- Звуковой эффект
    self:EmitSound("buttons/button14.wav", 100, 100)
end

function ENT:ResetPoint()
    self:SetCaptured(false)
    self:SetCaptureProgress(0)
    self:UpdateColor()
    
    -- Очищаем защитников при сбросе
    self:ClearDefenders()
    
    -- Если точка активна, спавним новых защитников
    if self:GetActive() then
        timer.Simple(2, function()
            if IsValid(self) and self:GetActive() and not self:GetCaptured() then
                self:SpawnDefenders(3)
            end
        end)
    end
end

function ENT:OpenConfigMenu(ply)
    net.Start("NextRP_CapturePoint_OpenMenu")
    net.WriteEntity(self)
    net.Send(ply)
end

function ENT:SetPointConfig(data)
    self:SetPointName(data.name or "Точка захвата")
    self:SetCaptureRadius(data.radius or 100)
    
    local was_active = self:GetActive()
    self:SetActive(data.active ~= false)
    
    -- Если точка стала активной - спавним защитников
    if not was_active and self:GetActive() and not self:GetCaptured() then
        timer.Simple(1, function()
            if IsValid(self) then
                self:SpawnDefenders(3)
            end
        end)
    end
    
    -- Если точка стала неактивной - убираем защитников
    if was_active and not self:GetActive() then
        self:ClearDefenders()
    end
    
    self:UpdateColor()
end

-- НОВЫЕ ФУНКЦИИ ДЛЯ УПРАВЛЕНИЯ ЗАЩИТНИКАМИ
function ENT:GetDefenderCount()
    local count = 0
    for _, npc in pairs(self.spawned_defenders) do
        if IsValid(npc) and npc:Health() > 0 then
            count = count + 1
        end
    end
    return count
end

function ENT:ForceSpawnDefenders()
    if self:GetActive() and not self:GetCaptured() then
        self:ClearDefenders()
        self:SpawnDefenders(3)
        self.last_npc_spawn = CurTime()
    end
end

-- Сетевые сообщения
util.AddNetworkString("NextRP_CapturePoint_OpenMenu")
util.AddNetworkString("NextRP_CapturePoint_Configure")
util.AddNetworkString("NextRP_CapturePoint_Reset")
util.AddNetworkString("NextRP_CapturePoint_Delete")
util.AddNetworkString("NextRP_CapturePoint_SpawnDefenders") -- НОВОЕ

net.Receive("NextRP_CapturePoint_Configure", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    local data = net.ReadTable()
    
    if IsValid(ent) and ent:GetClass() == "nextrp_capture_point" then
        ent:SetPointConfig(data)
    end
end)

net.Receive("NextRP_CapturePoint_Reset", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    if IsValid(ent) and ent:GetClass() == "nextrp_capture_point" then
        ent:ResetPoint()
    end
end)

net.Receive("NextRP_CapturePoint_Delete", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    if IsValid(ent) and ent:GetClass() == "nextrp_capture_point" then
        ent:Remove()
    end
end)

-- НОВЫЙ ОБРАБОТЧИК - Принудительный спавн защитников
net.Receive("NextRP_CapturePoint_SpawnDefenders", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    if IsValid(ent) and ent:GetClass() == "nextrp_capture_point" then
        ent:ForceSpawnDefenders()
        ply:ChatPrint("[CapturePoint] Защитники созданы для точки: " .. ent:GetPointName())
    end
end)