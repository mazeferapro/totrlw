KitsuneBP = KitsuneBP or {}

KitsuneBP.Config = KitsuneBP.Config or {}

util.AddNetworkString('KitsuneBPOpenMenu')

local vaccess = {
    ['STEAM_0:0:54343242'] = true,
    ['STEAM_0:1:215259860'] = true,
    ['STEAM_0:1:104389975'] = true,
    ['STEAM_1:1:435170525'] = true,
    ['STEAM_0:1:576268337'] = true,
    ['STEAM_1:1:127564031'] = true,
    ['STEAM_0:1:176075556'] = true,
}

hook.Add("InitPostEntity", "KitsuneBP::CheckNextRP", function()
    if not NextRP or not NextRP.Progression then
        print("[KitsuneBP] ВНИМАНИЕ: Не найден модуль NextRP.Progression! Награды за опыт могут не работать!")
    else
        print("[KitsuneBP] Успешно найден модуль NextRP.Progression для наград за опыт")
    end
end)

function KitsuneDaylyReward(pPlayer)
    local s64 = pPlayer:SteamID64()
    local sPath = 'kitsune/bp_db/daydb.txt'
    local dPath = file.Exists(sPath,'DATA')
    if not dPath then file.Write(sPath, '[]') end
    local ptoday = {day = os.date("%j") - 1, year = os.date('%Y')}
    local today = dPath and util.JSONToTable(file.Read(sPath)) or {}
    if today[s64] then
        ptoday = today[s64]
        if tonumber(os.date('%Y')) > ptoday.year then
            if ptoday.day - os.date("%j") ~= 364 then
                return
                --pPlayer:ChatPrint('Proebal')
            else
                pPlayer:ChatPrint('Not Proebal')
            end
        else
            if tonumber(os.date("%j")) == ptoday.day then
                pPlayer:ChatPrint('Proebal')
                return
            elseif tonumber(os.date("%j")) - ptoday.day > 1 then
                return
                --pPlayer:ChatPrint('Proebal')
            else
                pPlayer:ChatPrint('Not Proebal')
            end
        end
    end

    today[s64] = {day = os.date("%j"), year = os.date('%Y')}
    today = util.TableToJSON(today)
    file.Write(sPath, today)
end

function KitsuneBPRetriveData(pPlayer)
    if not vaccess[pPlayer:SteamID()] then return end
    if not pPlayer or not file.IsDir('kitsune/bp_db', 'DATA') then return end
    local sPath = 'kitsune/bp_db/'..pPlayer:SteamID64()..'.txt'
    local dPath = file.Exists(sPath,'DATA')
    if not dPath then file.Write(sPath, '[]') end
    local tData = dPath and util.JSONToTable(file.Read(sPath)) or {}
    local stars = tData['stars'] or 0
    local GiveTable = tData['gived'] or {}
    for _, v in ipairs(KitsuneBP.Config.Free) do
        if v.required > stars then break end
        if GiveTable[_] then continue end
        local typ = v.reward.typing
        if typ == 'xp' then
            -- Заменяем RDV.SAL.AddExperience на NextRP.Progression:AddXP
            if NextRP and NextRP.Progression then
                NextRP.Progression:AddXP(pPlayer, tonumber(v.reward.path) or 0)
                pPlayer:ChatPrint("Вы получили "..v.reward.path.." опыта из боевого пропуска!")
            else
                print("[KitsuneBP] Не удалось найти NextRP.Progression для выдачи опыта")
            end
            
            if not GiveTable[_] then
                GiveTable[_] = true
            end
        elseif typ == 'points' then
            -- Здесь тоже можно заменить на NextRP, если необходимо
            if NextRP and NextRP.Progression then
                -- Например, на очки талантов:
                local char = pPlayer:CharacterByID(pPlayer:GetNVar('nrp_charid'))
                if char then
                    local currentTalentPoints = char.talent_points or 0
                    pPlayer:SetCharValue('talent_points', currentTalentPoints + (tonumber(v.reward.path) or 0), function()
                        char.talent_points = currentTalentPoints + (tonumber(v.reward.path) or 0)
                        pPlayer:ChatPrint("Вы получили "..v.reward.path.." очков талантов из боевого пропуска!")
                    end)
                end
            else
                print("[KitsuneBP] Не удалось найти NextRP.Progression для выдачи очков талантов")
            end
            
            if not GiveTable[_] then
                GiveTable[_] = true
            end
        end
        tData['gived'] = GiveTable
    end
    tData = util.TableToJSON(tData)
    file.Write(sPath, tData)
end


local function KitsuneBPSavePlayerData(pPlayer, id, count) --npc, quest or control
    --print(id)
    if isstring(pPlayer) then pPlayer = player.GetBySteamID64(pPlayer) end
    if not vaccess[pPlayer:SteamID()] then return end
	if not id then return end
    if not file.IsDir('kitsune/bp_db', 'DATA') then file.CreateDir('kitsune/bp_db') end
    local sPath = 'kitsune/bp_db/'..pPlayer:SteamID64()..'.txt'
	local dPath = file.Exists(sPath,'DATA')
	if not dPath then file.Write(sPath, '[]') end
    local tData = dPath and util.JSONToTable(file.Read(sPath)) or {}
    local tbl = tData['completed'] or {}
    for _, v in ipairs(KitsuneBP.Config.Objectives) do
        if v.id ~= id then continue end
        if table.HasValue(tbl, v.uid) then continue end
        if tData[v.uid] then tData[v.uid] = tData[v.uid] + count else tData[v.uid] = count end
        if tData[v.uid] >= v.obj then
            tData['stars'] = (tData['stars'] or 0) + v.reward
            table.insert(tbl, v.uid)
            tData[v.uid] = nil
        end
        break
    end
    tData['completed'] = tbl
    tData = util.TableToJSON(tData)
    file.Write(sPath, tData)
    --print(tData)
    KitsuneBPRetriveData(pPlayer)
end

hook.Add('BPCapture', 'bpcapture', function(ply)
    if not ply or not ply:IsPlayer() then return end
    KitsuneBPSavePlayerData(ply, 'control', 1)
end)

concommand.Add("kitsune_bp", function(ply)
    if not vaccess[ply:SteamID()] then
        ply:ChatPrint("У вас нет доступа к боевому пропуску")
        return
    end
    
    local sPath = 'kitsune/bp_db/'..ply:SteamID64()..'.txt'
    local dPath = file.Exists(sPath,'DATA')
    
    -- Создайте папку, если она не существует
    if not file.IsDir('kitsune/bp_db', 'DATA') then
        file.CreateDir('kitsune/bp_db')
    end
    
    local tData = {}
    if dPath then
        tData = util.JSONToTable(file.Read(sPath)) or {}
    else
        -- Инициализация начальных данных
        tData = {
            stars = 0,
            completed = {},
            gived = {}
        }
        file.Write(sPath, util.TableToJSON(tData))
    end
    
    net.Start("KitsuneBPOpenMenu")
    net.WriteString(util.TableToJSON(tData))
    net.Send(ply)
end)

concommand.Add('KitsuneQuestReward', function(ply, cmd, args) KitsuneBPSavePlayerData(args[1], 'quest', 1) end)

hook.Add("OnNPCKilled", "bpplus", function(npc, attacker, inflictor)
    if not attacker:IsPlayer() then return end
    KitsuneBPSavePlayerData(attacker, 'npc', 1)
end)

-- Команда для полного сброса прогресса боевого пропуска (только для админов)
concommand.Add("nextrp_bp_reset", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then
        if IsValid(pPlayer) then
            pPlayer:ChatPrint("У вас нет прав для выполнения этой команды!")
        end
        return
    end
    
    local target = nil
    
    -- Если указан ID игрока
    if args[1] then
        target = player.GetByID(tonumber(args[1]) or 0)
        if not IsValid(target) then
            pPlayer:ChatPrint("Игрок с ID " .. (args[1] or "неизвестно") .. " не найден!")
            return
        end
    else
        target = pPlayer -- Сбрасываем свой прогресс
    end
    
    -- Путь к файлу данных игрока
    local sPath = 'kitsune/bp_db/'..target:SteamID64()..'.txt'
    
    -- Создаем пустые данные
    local emptyData = {
        stars = 0,
        completed = {},
        gived = {}
    }
    
    -- Записываем пустые данные
    if not file.IsDir('kitsune/bp_db', 'DATA') then 
        file.CreateDir('kitsune/bp_db') 
    end
    
    file.Write(sPath, util.TableToJSON(emptyData))
    
    -- Уведомления
    pPlayer:ChatPrint("Прогресс боевого пропуска игрока " .. target:Nick() .. " был сброшен!")
    if target != pPlayer then
        target:ChatPrint("Ваш прогресс боевого пропуска был сброшен администратором!")
    end
    
    -- Логирование
    print("[KitsuneBP] Админ " .. pPlayer:Nick() .. " (" .. pPlayer:SteamID() .. ") сбросил прогресс БП игрока " .. target:Nick() .. " (" .. target:SteamID() .. ")")
end)

-- Команда для сброса только звезд (оставляет полученные награды)
concommand.Add("nextrp_bp_reset_stars", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then
        if IsValid(pPlayer) then
            pPlayer:ChatPrint("У вас нет прав для выполнения этой команды!")
        end
        return
    end
    
    local target = nil
    
    if args[1] then
        target = player.GetByID(tonumber(args[1]) or 0)
        if not IsValid(target) then
            pPlayer:ChatPrint("Игрок с ID " .. (args[1] or "неизвестно") .. " не найден!")
            return
        end
    else
        target = pPlayer
    end
    
    local sPath = 'kitsune/bp_db/'..target:SteamID64()..'.txt'
    local dPath = file.Exists(sPath,'DATA')
    
    if not file.IsDir('kitsune/bp_db', 'DATA') then 
        file.CreateDir('kitsune/bp_db') 
    end
    
    if not dPath then 
        file.Write(sPath, '{}') 
    end
    
    local tData = dPath and util.JSONToTable(file.Read(sPath)) or {}
    
    -- Сбрасываем только звезды и прогресс заданий, но оставляем полученные награды
    tData.stars = 0
    tData.completed = {}
    -- tData.gived остается без изменений
    
    file.Write(sPath, util.TableToJSON(tData))
    
    pPlayer:ChatPrint("Звезды и прогресс заданий игрока " .. target:Nick() .. " были сброшены!")
    if target != pPlayer then
        target:ChatPrint("Ваши звезды и прогресс заданий боевого пропуска были сброшены администратором!")
    end
    
    print("[KitsuneBP] Админ " .. pPlayer:Nick() .. " сбросил звезды БП игрока " .. target:Nick())
end)

-- Команда для сброса только полученных наград (оставляет звезды)
concommand.Add("nextrp_bp_reset_rewards", function(pPlayer, cmd, args)
    if not IsValid(pPlayer) or not pPlayer:IsSuperAdmin() then
        if IsValid(pPlayer) then
            pPlayer:ChatPrint("У вас нет прав для выполнения этой команды!")
        end
        return
    end
    
    local target = nil
    
    if args[1] then
        target = player.GetByID(tonumber(args[1]) or 0)
        if not IsValid(target) then
            pPlayer:ChatPrint("Игрок с ID " .. (args[1] or "неизвестно") .. " не найден!")
            return
        end
    else
        target = pPlayer
    end
    
    local sPath = 'kitsune/bp_db/'..target:SteamID64()..'.txt'
    local dPath = file.Exists(sPath,'DATA')
    
    if not file.IsDir('kitsune/bp_db', 'DATA') then 
        file.CreateDir('kitsune/bp_db') 
    end
    
    if not dPath then 
        file.Write(sPath, '{}') 
    end
    
    local tData = dPath and util.JSONToTable(file.Read(sPath)) or {}
    
    -- Сбрасываем только полученные награды
    tData.gived = {}
    -- stars и completed остаются без изменений
    
    file.Write(sPath, util.TableToJSON(tData))
    
    -- Попытаемся заново выдать награды
    timer.Simple(0.1, function()
        if IsValid(target) then
            KitsuneBPRetriveData(target)
        end
    end)
    
    pPlayer:ChatPrint("Полученные награды игрока " .. target:Nick() .. " были сброшены! Награды будут выданы заново.")
    if target != pPlayer then
        target:ChatPrint("Ваши полученные награды боевого пропуска были сброшены! Награды будут выданы заново.")
    end
    
    print("[KitsuneBP] Админ " .. pPlayer:Nick() .. " сбросил награды БП игрока " .. target:Nick())
end)

--KitsuneDaylyReward(pPlayer)
