-- gamemode/modules/autoevents/entities/nextrp_npc_spawn/init.lua

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
    self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 32))
    
    self:SetActive(true)
    self:SetSpawnName("Зона спавна #" .. self:EntIndex())
    self:SetSpawnRadius(50)
    
    -- Эффект для визуализации
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:SetColor(Color(255, 0, 0, 150))
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() or not activator:IsAdmin() then
        return
    end
    
    self:OpenConfigMenu(activator)
end

function ENT:OpenConfigMenu(ply)
    net.Start("NextRP_NPCSpawn_OpenMenu")
    net.WriteEntity(self)
    net.Send(ply)
end

function ENT:SetSpawnConfig(data)
    self:SetSpawnName(data.name or "Зона спавна")
    self:SetSpawnRadius(data.radius or 50)
    self:SetActive(data.active ~= false)
end

-- Функция для получения позиции спавна в радиусе
function ENT:GetSpawnPosition(radius, attempts)
    radius = radius or self:GetSpawnRadius()
    attempts = attempts or 15
    
    local base_pos = self:GetPos()
    
    for i = 1, attempts do
        -- Равномерное распределение по кольцам вместо центра
        local ring = math.random(1, 4) -- 4 кольца для лучшего распределения
        local min_dist = (ring - 1) * (radius / 4)
        local max_dist = ring * (radius / 4)
        
        local angle = math.random(0, 359)
        local distance = math.random(min_dist, max_dist)
        
        local x = math.cos(math.rad(angle)) * distance
        local y = math.sin(math.rad(angle)) * distance
        
        local test_pos = base_pos + Vector(x, y, 50) -- Начинаем выше
        
        -- Трассировка вниз для нахождения земли
        local trace_down = util.TraceLine({
            start = test_pos,
            endpos = test_pos - Vector(0, 0, 100),
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if trace_down.Hit then
            local ground_pos = trace_down.HitPos + Vector(0, 0, 5)
            
            -- Проверяем, что в этой позиции достаточно места (hull trace)
            local hull_trace = util.TraceHull({
                start = ground_pos,
                endpos = ground_pos + Vector(0, 0, 1),
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 72),
                mask = MASK_SOLID
            })
            
            -- Проверяем расстояние до других NPC (избегаем скучивания)
            local too_close = false
            for _, ent in pairs(ents.FindInSphere(ground_pos, 70)) do
                if ent:IsNPC() and ent:GetPos():Distance(ground_pos) < 60 then
                    too_close = true
                    break
                end
            end
            
            if not hull_trace.Hit and not too_close then
                return ground_pos
            end
        end
    end
    
    -- Если не удалось найти хорошую позицию, возвращаем позицию по краю зоны
    local fallback_angle = math.random(0, 359)
    local fallback_distance = radius * 0.8 -- 80% от радиуса
    local fallback_x = math.cos(math.rad(fallback_angle)) * fallback_distance
    local fallback_y = math.sin(math.rad(fallback_angle)) * fallback_distance
    
    return base_pos + Vector(fallback_x, fallback_y, 10)
end

function ENT:GetMultipleSpawnPositions(count, min_distance)
    min_distance = min_distance or 70
    local positions = {}
    local radius = self:GetSpawnRadius()
    
    for i = 1, count do
        local attempts = 0
        local found_position = false
        
        while attempts < 25 and not found_position do
            local pos = self:GetSpawnPosition(radius, 8)
            local valid = true
            
            -- Проверяем расстояние до уже выбранных позиций
            for _, existing_pos in pairs(positions) do
                if pos:Distance(existing_pos) < min_distance then
                    valid = false
                    break
                end
            end
            
            if valid then
                table.insert(positions, pos)
                found_position = true
            end
            
            attempts = attempts + 1
        end
        
        -- Если не удалось найти позицию, используем радиальное размещение
        if not found_position then
            local angle = (360 / count) * (i - 1) + math.random(-20, 20)
            local distance = radius * (0.6 + math.random() * 0.3) -- 60-90% радиуса
            local x = math.cos(math.rad(angle)) * distance
            local y = math.sin(math.rad(angle)) * distance
            table.insert(positions, self:GetPos() + Vector(x, y, 10))
        end
    end
    
    return positions
end

-- Сетевые сообщения
util.AddNetworkString("NextRP_NPCSpawn_OpenMenu")
util.AddNetworkString("NextRP_NPCSpawn_Configure")
util.AddNetworkString("NextRP_NPCSpawn_Delete")

net.Receive("NextRP_NPCSpawn_Configure", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    local data = net.ReadTable()
    
    if IsValid(ent) and ent:GetClass() == "nextrp_npc_spawn" then
        ent:SetSpawnConfig(data)
    end
end)

net.Receive("NextRP_NPCSpawn_Delete", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local ent = net.ReadEntity()
    if IsValid(ent) and ent:GetClass() == "nextrp_npc_spawn" then
        ent:Remove()
    end
end)