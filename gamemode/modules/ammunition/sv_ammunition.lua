local function calcweight(pPlayer)
    local picked = pPlayer:GetNWInt('picked') or 0
    
    -- Если у игрока есть улучшенные скорости от талантов, используем их
    if pPlayer.TalentEnhancedRunSpeed and pPlayer.TalentEnhancedWalkSpeed then
        local enhancedRunSpeed = pPlayer.TalentEnhancedRunSpeed
        local enhancedWalkSpeed = pPlayer.TalentEnhancedWalkSpeed
        local slowSpeed = enhancedWalkSpeed - 50
        
        if picked >= 100 then
            pPlayer:SetWalkSpeed(enhancedWalkSpeed * 0.65)
            pPlayer:SetRunSpeed(enhancedRunSpeed * 0.65)
            pPlayer:SetSlowWalkSpeed(slowSpeed * 0.65)
        elseif picked >= 50 then
            pPlayer:SetWalkSpeed(enhancedWalkSpeed * 0.85)
            pPlayer:SetRunSpeed(enhancedRunSpeed * 0.85)
            pPlayer:SetSlowWalkSpeed(slowSpeed * 0.85)
        elseif picked >= 25 then
            pPlayer:SetWalkSpeed(enhancedWalkSpeed * 0.95)
            pPlayer:SetRunSpeed(enhancedRunSpeed * 0.95)
            pPlayer:SetSlowWalkSpeed(slowSpeed * 0.95)
        else
            pPlayer:SetWalkSpeed(enhancedWalkSpeed)
            pPlayer:SetRunSpeed(enhancedRunSpeed)
            pPlayer:SetSlowWalkSpeed(slowSpeed)
        end
    else
        -- Стандартная логика без талантов
        local runspeed = pPlayer:getJobTable().runspead or 250
        local walkspeed = pPlayer:getJobTable().walkspead or 100
        local slowspeed = walkspeed - 50
        
        if picked >= 100 then
            pPlayer:SetWalkSpeed(walkspeed * 0.65)
            pPlayer:SetRunSpeed(runspeed * 0.65)
            pPlayer:SetSlowWalkSpeed(slowspeed * 0.65)
        elseif picked >= 50 then
            pPlayer:SetWalkSpeed(walkspeed * 0.85)
            pPlayer:SetRunSpeed(runspeed * 0.85)
            pPlayer:SetSlowWalkSpeed(slowspeed * 0.85)
        elseif picked >= 25 then
            pPlayer:SetWalkSpeed(walkspeed * 0.95)
            pPlayer:SetRunSpeed(runspeed * 0.95)
            pPlayer:SetSlowWalkSpeed(slowspeed * 0.95)
        else
            pPlayer:SetWalkSpeed(walkspeed)
            pPlayer:SetRunSpeed(runspeed)
            pPlayer:SetSlowWalkSpeed(slowspeed)
        end
    end

    if ServerMedicMod and ServerMedicMod.EnableLegsTraum and pPlayer:GetNWInt("MedicineModtraumalegs") != 0 then
        -- Если есть травма ног, применяем дополнительное замедление на 70% (делим на 3)
        local currentWalkSpeed = pPlayer:GetWalkSpeed()
        local currentRunSpeed = pPlayer:GetRunSpeed()
        local currentSlowSpeed = pPlayer:GetSlowWalkSpeed()
        
        pPlayer:SetWalkSpeed(currentWalkSpeed / 3)
        pPlayer:SetRunSpeed(currentRunSpeed / 3)
        pPlayer:SetSlowWalkSpeed(currentSlowSpeed / 3)
    end
end



netstream.Hook('NextRP::AmmunitionWeps', function(pPlayer, sWep)
    local picked = pPlayer:GetNWInt('picked')
    local weight = weapons.Get(sWep).Weight or 5
    if string.StartsWith(sWep, 'medic') then weight = 0 end
    local weps = pPlayer.ammunitionweps

    pPlayer.WeaponTimers = pPlayer.WeaponTimers or {}
    pPlayer.WeaponTimers[sWep] = pPlayer.WeaponTimers[sWep] or CurTime() - 1

    if table.HasValue(weps.ammunition, sWep) or table.HasValue(weps.default, sWep) then
        if pPlayer:HasWeapon(sWep) then
            pPlayer:StripWeapon(sWep)
            pPlayer.WeaponTimers[sWep] = CurTime() + 60
            pPlayer:SetNWInt('picked', picked - weight)
        else
            if picked >= 200 then pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете нести больше!') end
            if pPlayer.WeaponTimers[sWep] < CurTime() then
                pPlayer:Give(sWep)
                pPlayer:SetNWInt('picked', picked + weight)
            else
                pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вам нужно подождать ещё ', Color(71, 141, 255), tostring(math.Round(pPlayer.WeaponTimers[sWep] - CurTime())), color_white, ' секунд, что-бы получить это оружие/экипировку!')
            end
        end
    calcweight(pPlayer)
    pPlayer:CalcWeight()
    end
end)

netstream.Hook('NextRP::AmmunitionGiveAll', function(pPlayer)
    local weps = pPlayer.ammunitionweps
    pPlayer.WeaponGiveAll = pPlayer.WeaponGiveAll or CurTime() - 1
    local kolvo = 0

    if pPlayer.WeaponGiveAll < CurTime() then
        -- Выдаем оружие из ammunition
        for r, u in pairs(weps.ammunition) do
            if !pPlayer:HasWeapon(u) then
                pPlayer:Give(u)
                kolvo = kolvo + 1
                
                -- Добавляем вес каждого оружия
                local weight = weapons.Get(u).Weight or 5
                if string.StartsWith(u, 'medic') then weight = 0 end
                local currentWeight = pPlayer:GetNWInt('picked') or 0
                pPlayer:SetNWInt('picked', currentWeight + weight)
            end
        end

        -- Выдаем оружие из default
        for r, u in pairs(weps.default) do
            if !pPlayer:HasWeapon(u) then
                pPlayer:Give(u)
                kolvo = kolvo + 1
                
                -- Добавляем вес каждого оружия
                local weight = weapons.Get(u).Weight or 5
                if string.StartsWith(u, 'medic') then weight = 0 end
                local currentWeight = pPlayer:GetNWInt('picked') or 0
                pPlayer:SetNWInt('picked', currentWeight + weight)
            end
        end

        if kolvo > 0 then
            pPlayer.WeaponGiveAll = CurTime() + 60
        else
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'У вас уже всё есть!')
        end
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вам нужно подождать ещё ', Color(71, 141, 255), tostring(math.Round(pPlayer.WeaponGiveAll - CurTime())), color_white, ' секунд, что-бы получить всё вооружение!')
    end
    
    -- Пересчитываем скорость после изменения веса
    calcweight(pPlayer)
    pPlayer:CalcWeight()
end)

netstream.Hook('NextRP::AmmunitionRemoveAll', function(pPlayer)
    local weps = pPlayer.ammunitionweps
    local kolvo = 0
    
    pPlayer.WeaponTimers = pPlayer.WeaponTimers or {}

    -- Убираем оружие из ammunition
    for r, u in pairs(weps.ammunition) do
        if pPlayer:HasWeapon(u) then
            pPlayer:StripWeapon(u)
            pPlayer.WeaponTimers[u] = CurTime() + 60
            kolvo = kolvo + 1
            
            -- Убираем вес каждого оружия
            local weight = weapons.Get(u).Weight or 5
            if string.StartsWith(u, 'medic') then weight = 0 end
            local currentWeight = pPlayer:GetNWInt('picked') or 0
            pPlayer:SetNWInt('picked', math.max(0, currentWeight - weight))
        end
    end

    -- Убираем оружие из default
    for r, u in pairs(weps.default) do
        if pPlayer:HasWeapon(u) then
            pPlayer:StripWeapon(u)
            pPlayer.WeaponTimers[u] = CurTime() + 60
            kolvo = kolvo + 1
            
            -- Убираем вес каждого оружия
            local weight = weapons.Get(u).Weight or 5
            if string.StartsWith(u, 'medic') then weight = 0 end
            local currentWeight = pPlayer:GetNWInt('picked') or 0
            pPlayer:SetNWInt('picked', math.max(0, currentWeight - weight))
        end
    end
    
    -- Пересчитываем скорость после изменения веса
    calcweight(pPlayer)
    pPlayer:CalcWeight()
end)
netstream.Hook('NextRP::Dispenser', function(pPlayer, type)
    local tbl = {1,2,3,4,5}
    local greandetypes = {'grenade', 'arccw_bacta_grenade', 'arccw_flash_grenade', 'arccw_impact_grenade', 'arccw_k_nade_smoke', 'arccw_k_nade_flashbang', 'arccw_k_nade_thermal'}

    if !tbl[type] then return end
    pPlayer.Dispenser = pPlayer.Dispenser or {}
    pPlayer.Dispenser[type] = pPlayer.Dispenser[type] or CurTime() - 1

    if type == tbl[1] and pPlayer.Dispenser[type] < CurTime() then
        pPlayer:GiveAmmo(2000, "ar2", false)
        pPlayer.Dispenser[type] = CurTime() + 5
    elseif type == tbl[2] and pPlayer.Dispenser[type] < CurTime() then
        pPlayer:GiveAmmo(50, "rpg_round", false)
        pPlayer.Dispenser[type] = CurTime() + 5
    elseif type == tbl[3] and pPlayer.Dispenser[type] < CurTime() then
        for _, v in ipairs(greandetypes) do
            pPlayer:GiveAmmo(5, v, false)
        end
        pPlayer.Dispenser[type] = CurTime() + 5
    elseif type == tbl[4] and pPlayer.Dispenser[type] < CurTime() then
        if pPlayer:Armor() == pPlayer:GetMaxArmor() then return pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'У вас и так уже максимум брони!') end
        pPlayer:SetArmor( pPlayer:Armor() + 50 )
        if pPlayer:Armor() > pPlayer:GetMaxArmor() then
            pPlayer:SetArmor( pPlayer:GetMaxArmor() )
        end
        pPlayer:EmitSound("npc/roller/code2.wav")
        pPlayer.Dispenser[type] = CurTime() + 5
    elseif type == tbl[5] and pPlayer.Dispenser[type] < CurTime() then
        pPlayer:GiveAmmo(20, "SMG1_Grenade", false)
        pPlayer.Dispenser[type] = CurTime() + 5
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Вам нужно подождать ещё ', Color(71, 141, 255), tostring(math.Round(pPlayer.Dispenser[type] - CurTime())), color_white, ' секунд, прежде чем взять это!')
    end
end)

hook.Add('PlayerDeath', 'NextRP::ResetWepsTimers', function(pPlayer)
    pPlayer.WeaponTimers = {}
    pPlayer.Dispenser = {}
    pPlayer.WeaponGiveAll = CurTime() - 1
end)

--[[
    Серверная часть модуля Ammunition
    Адаптировано под Inventory System и Supply Points
]]

AddCSLuaFile("cl_ammunition.lua")
AddCSLuaFile("sh_config.lua")
include("sh_config.lua")

-- Инициализация снабжения
hook.Add("Initialize", "NextRP::InitSupplyPoints", function()
    SetGlobalInt("NextRP_SupplyPoints", NextRP.Ammunition.Config.MaxSupply)
end)

-- Регенерация снабжения
timer.Create("NextRP::RegenSupply", NextRP.Ammunition.Config.RegenInterval, 0, function()
    local current = GetGlobalInt("NextRP_SupplyPoints", 0)
    local max = NextRP.Ammunition.Config.MaxSupply
    
    if current < max then
        SetGlobalInt("NextRP_SupplyPoints", math.min(current + NextRP.Ammunition.Config.RegenAmount, max))
    end
end)

-- Функция изменения очков снабжения (для админов или событий)
function NextRP.Ammunition:AddSupply(amount)
    local current = GetGlobalInt("NextRP_SupplyPoints", 0)
    local max = NextRP.Ammunition.Config.MaxSupply
    SetGlobalInt("NextRP_SupplyPoints", math.Clamp(current + amount, 0, max))
end

-- Обработчик запроса на получение предмета
netstream.Hook("NextRP::AmmunitionBuy", function(ply, index)
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Проверка дистанции до ближайшего ящика
    local nearby = false
    for _, ent in pairs(ents.FindByClass("nextrp_ammunition")) do
        if ent:GetPos():DistToSqr(ply:GetPos()) < 200 * 200 then
            nearby = true
            break
        end
    end
    
    if not nearby then return end
    
    -- Получаем данные о предмете
    local itemConfig = NextRP.Ammunition.Config.Items[index]
    if not itemConfig then return end
    
    -- Проверяем наличие глобальных очков снабжения
    local currentSupply = GetGlobalInt("NextRP_SupplyPoints", 0)
    if currentSupply < itemConfig.price then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Недостаточно очков снабжения в системе!")
        return
    end
    
    -- Проверяем валидность предмета в инвентаре
    local itemData = NextRP.Inventory:GetItemData(itemConfig.itemID)
    if not itemData then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Ошибка конфигурации: Предмет не существует")
        return
    end
    
    -- Пытаемся выдать предмет в инвентарь
    local success, err = NextRP.Inventory:AddItem(ply, itemConfig.itemID, 1)
    
    if success then
        -- Снимаем очки снабжения только при успехе
        NextRP.Ammunition:AddSupply(-itemConfig.price)
        
        ply:SendMessage(MESSAGE_TYPE_SUCCESS, "Вы получили: " .. itemData.name)
        ply:EmitSound("items/ammo_pickup.wav")
    else
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Ошибка: " .. (err or "Нет места в инвентаре"))
    end
end)

-- Админ-команда для управления снабжением
concommand.Add("nextrp_setsupply", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    local amount = tonumber(args[1])
    if amount then
        SetGlobalInt("NextRP_SupplyPoints", amount)
        print("Supply points set to " .. amount)
    end
end)