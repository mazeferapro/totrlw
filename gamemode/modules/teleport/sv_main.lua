// TODO:
// Точки выхода для телепорта

--[[NextRP.Teleports = NextRP.Teleports or {}

netstream.Hook('NextRP.Teleports.Create', function(ply, isGlobal, isTemp, idValue, nameValue, boundA, boundB)
    if not ply:IsSuperAdmin() then
        ply:Kick('Двигай отсюда. Тебе нельзя это использовать. #TeleportsAlertCreate')
        return 
    end

    if idValue:lower() == 'global' then
        
        return 
    end

    if isGlobal then
        NextRP.Teleports = NextRP.Teleports or {}
        NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}
        NextRP.Teleports.Brushes.Global = NextRP.Teleports.Brushes.Global or {}

        NextRP.Teleports.Brushes.Global[idValue] = {
            name = nameValue,
            id = idValue,
            boundA = boundA,
            boundB = boundB
        }
    else
        local map = game.GetMap()

        NextRP.Teleports = NextRP.Teleports or {}
        NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}
        NextRP.Teleports.Brushes[map] = NextRP.Teleports.Brushes[map] or {}
        
        NextRP.Teleports.Brushes[map][idValue] = {
            name = nameValue,
            id = idValue,
            boundA = boundA,
            boundB = boundB
        }
    end

    local newEnt = ents.Create('nextrp_teleport_brush')
        newEnt.PointA, newEnt.PointB, newEnt.id = boundA, boundB, idValue
        newEnt:Spawn()
        newEnt:Activate()

    if not isTemp then
        file.CreateDir('nextrp')
        file.Write('nextrp/teleports.txt', util.TableToJSON(NextRP.Teleports.Brushes))
    end
end)

netstream.Hook('NextRP.Teleports.Remove', function(id, isGlobal)
    if not ply:IsSuperAdmin() then
        ply:Kick('Двигай отсюда. Тебе нельзя это использовать. #TeleportsAlertRemove')
        return 
    end

    if idValue:lower() == 'global' then
        
        return 
    end

    if isGlobal then
        NextRP.Teleports = NextRP.Teleports or {}
        NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}
        NextRP.Teleports.Brushes.Global = NextRP.Teleports.Brushes.Global or {}

        NextRP.Teleports.Brushes.Global[id] = nil
        
        file.CreateDir('nextrp')
        file.Write('nextrp/teleports.txt', util.TableToJSON(NextRP.Teleports.Brushes))
    else
        NextRP.Teleports = NextRP.Teleports or {}
        NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}
        NextRP.Teleports.Brushes[game.GetMap()] = NextRP.Teleports.Brushes[game.GetMap()] or {}

        NextRP.Teleports.Brushes[game.GetMap()][id] = nil

        file.CreateDir('nextrp')
        file.Write('nextrp/teleports.txt', util.TableToJSON(NextRP.Teleports.Brushes))
    end
end)

function NextRP.Teleports:Teleport(TargetPlanet, CurPlanet)
    if TargetPlanet == CurPlanet then
        l:SendNotify(pPlayer, 'Вы пытаетесь отправиться на эту же планету!', 1, 5, l.Config.Colors.Red)
        return 
    end
    
    if pPlayer.CurPlanet != CurPlanet then
        pPlayer:Kick('[EXPLOITER] Transport System Alert')
        return 
    end

    if ExitPoints[TargetPlanet] then
        local Pos = table.Random(ExitPoints[TargetPlanet])

        local ship = pPlayer:lfsGetPlane()

        if ship:GetDriver() != pPlayer then
            return 
        end
        
        local BlockedSpot = false

        local Finded = ents.FindInSphere( Pos, 128 )
        for k, v in ipairs(Finded) do
            if v.LFS then
                BlockedSpot = true
            end
        end

        if BlockedSpot then
            l:SendNotify(pPlayer, 'Точка выхода заблокирована, попробуйте ещё раз!', 1, 5, l.Config.Colors.Red)
            return
        end

        local phys = ship:GetPhysicsObject()
        phys:SetPos(Pos + Vector(math.random(-50, 50), math.random(-50, 50), 0), true)
    else
        l:SendNotify(pPlayer, 'Точка выхода не найдена, обратитесь к администрации!', 1, 5, l.Config.Colors.Red)
    end
end

hook.Add('NextRP::PlayerFullLoad', 'NextRP.SendTeleports', function(ply)
    local tmp = {}
    tmp[game.GetMap()] = NextRP.Teleports.Brushes[game.GetMap()] or {}
    tmp['Global'] = NextRP.Teleports.Brushes.Global or {}
    
    netstream.Start(ply, 'NextRP.Teleports.Sync', tmp)
end)

hook.Add('InitPostEntity', 'NextRP.Teleports.Load', function()
    if file.Exists('nextrp/teleports.txt', 'DATA') then
        local status, result = pcall(util.JSONToTable, file.Read('nextrp/teleports.txt', 'DATA'))

        if status then
            NextRP.Teleports.Brushes = result
            print('Телепорты загружены')
        else
            NextRP.Teleports.Brushes = {}
            print('Ошибка в чтении файла телепортов.')
        end
    else
        NextRP.Teleports.Brushes = {}
        file.Write('nextrp/teleports.txt', '[]')
        print('Файл телепортов создан.')
    end

    for k, v in pairs(NextRP.Teleports.Brushes[game.GetMap()] or {}) do
        local newEnt = ents.Create('nextrp_teleport_brush')
            newEnt.PointA, newEnt.PointB, newEnt.id = v.boundA, v.boundB, v.id
            newEnt:Spawn()
            newEnt:Activate()
    end

    MsgC(color_white, 'Загружено ', Color(100, 200, 100), #(NextRP.Teleports.Brushes[game.GetMap()] or {}), color_white, ' телепортов для карты ', Color(100, 200, 100), game.GetMap(), color_white, '!\n')
end)

hook.Add('PostCleanupMap', 'NextRP.Teleports.Restore', function()
    for k, v in pairs(NextRP.Teleports.Brushes[game.GetMap()] or {}) do
        local newEnt = ents.Create('nextrp_teleport_brush')
            newEnt.PointA, newEnt.PointB = v.boundA, v.boundB
            newEnt:Spawn()
            newEnt:Activate()
    end
end)]]