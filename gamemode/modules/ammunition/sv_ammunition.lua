local cfg = NextRP.Ammunition.Config

hook.Add("Initialize", "NextRP::SupplyInit", function()
    if GetGlobalInt("NextRP_SupplyPoints", -1) == -1 then
        SetGlobalInt("NextRP_SupplyPoints", cfg.MaxSupply)
    end
end)

timer.Create("NextRP::SupplyRegen", cfg.RegenInterval, 0, function()
    local current = GetGlobalInt("NextRP_SupplyPoints", 0)
    if current < cfg.MaxSupply then
        SetGlobalInt("NextRP_SupplyPoints", math.min(current + cfg.RegenAmount, cfg.MaxSupply))
    end
end)

-- == Вспомогательная функция для сервера ==
local function GetPlyFlag(ply)
    if not IsValid(ply) then return "" end
    
    local f = ply:GetNWString("Flag")
    if f and f ~= "" then return f end
    
    f = ply:GetNWString("flag")
    if f and f ~= "" then return f end

    if ply.GetNetVar then
        f = ply:GetNetVar("Flag")
        if f and f ~= "" then return f end
        
        f = ply:GetNetVar("flag")
        if f and f ~= "" then return f end
    end
    
    return ""
end
-- =========================================

-- Проверка разрешения на получение предмета
local function CanPlayerGetItem(ply, itemID)
    local itemData = NextRP.Inventory:GetItemData(itemID)
    if not itemData or not itemData.weaponClass then return false end
    
    local targetWepClass = itemData.weaponClass
    local jobData = ply:getJobTable()
    if not jobData then return false end
    
    -- Получаем ранг
    local myRank = ply:GetNWString("Rank", jobData.default_rank or "")
    if (not myRank or myRank == "") and ply.GetNetVar then myRank = ply:GetNetVar("Rank") or "" end
    if myRank == "" and jobData.default_rank then myRank = jobData.default_rank end

    -- Получаем флаг
    local myFlag = GetPlyFlag(ply)
    
    local allowed = false
    
    -- 1. Проверка ранга
    if jobData.ranks and jobData.ranks[myRank] then
        local rankData = jobData.ranks[myRank]
        if rankData.weapon and rankData.weapon.ammunition then
            for _, class in pairs(rankData.weapon.ammunition) do
                if class == targetWepClass then allowed = true break end
            end
        end
    end
    
    -- 2. Проверка флага
    if myFlag ~= "" and jobData.flags then
        local flagData = jobData.flags[myFlag]
        
        if not flagData then
            for k, v in pairs(jobData.flags) do
                if v.id == myFlag then flagData = v break end
            end
        end

        if flagData and flagData.weapon and flagData.weapon.ammunition then
             if flagData.replaceWeapon then allowed = false end
             
             for _, class in pairs(flagData.weapon.ammunition) do
                if class == targetWepClass then allowed = true break end
             end
        end
    end
    
    return allowed
end

netstream.Hook("NextRP::Ammunition::Buy", function(ply, data)
    if not IsValid(ply) or not ply:Alive() then return end
    
    if data.entIndex then
        local ent = Entity(data.entIndex)
        if IsValid(ent) and ent:GetClass() == "nextrp_ammunition" then
            if ply:GetPos():DistToSqr(ent:GetPos()) > 300*300 then return end
        end
    end

    local itemID = data.itemID
    
    if not CanPlayerGetItem(ply, itemID) then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Этот предмет недоступен для вашего звания/должности.")
        return
    end
    
    local itemDef = NextRP.Inventory:GetItemData(itemID)
    local price = itemDef.supplyPrice or 0
    local currentSupply = GetGlobalInt("NextRP_SupplyPoints", 0)
    
    if currentSupply < price then
        ply:SendMessage(MESSAGE_TYPE_ERROR, "На базе недостаточно очков снабжения!")
        return
    end
    
    local success, err = NextRP.Inventory:AddItem(ply, itemID, 1)
    
    if success then
        SetGlobalInt("NextRP_SupplyPoints", currentSupply - price)
        ply:SendMessage(MESSAGE_TYPE_SUCCESS, "Вы получили: " .. itemDef.name)
        ply:EmitSound("items/ammo_pickup.wav")
    else
        ply:SendMessage(MESSAGE_TYPE_ERROR, "Ошибка: " .. (err or "Инвентарь полон"))
    end
end)

concommand.Add("nextrp_setsupply", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    local val = tonumber(args[1])
    if val then SetGlobalInt("NextRP_SupplyPoints", val) end
end)