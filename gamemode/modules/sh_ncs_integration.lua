-- Добавить в начало lua/rdv_companions/sh_init.lua
-- или создать новый файл lua/rdv_companions/sh_nextrp_integration.lua

-- Интеграция с NextRP Money System
if SERVER then
    -- Проверяем наличие NextRP системы денег
    hook.Add("InitPostEntity", "RDV_COMPANIONS_NextRP_Integration", function()
        timer.Simple(2, function() -- Даём время на загрузку всех модулей
            if not NextRP or not NextRP.Chars then
                print("[RDV COMPANIONS] ВНИМАНИЕ: NextRP не найден, аддон компаньонов может работать некорректно!")
                return
            end
            
            -- Проверяем наличие функций денег
            local pMeta = FindMetaTable('Player')
            if not pMeta.GetMoney or not pMeta.AddMoney or not pMeta.CanAfford then
                print("[RDV COMPANIONS] ОШИБКА: NextRP Money система не найдена!")
                return
            end
            
            print("[RDV COMPANIONS] Успешная интеграция с NextRP Money System!")
            
            -- Отключаем NCS_SHARED если он используется для денег
            if NCS_SHARED and NCS_SHARED.AddMoney then
                -- Переопределяем функции NCS_SHARED для использования NextRP
                local oldAddMoney = NCS_SHARED.AddMoney
                local oldCanAfford = NCS_SHARED.CanAfford
                
                NCS_SHARED.AddMoney = function(P, currency, amount)
                    if currency == nil and IsValid(P) and P:IsPlayer() then
                        -- Используем NextRP систему
                        return P:AddMoney(amount)
                    else
                        -- Используем старую систему для других валют
                        return oldAddMoney(P, currency, amount)
                    end
                end
                
                NCS_SHARED.CanAfford = function(P, currency, amount)
                    if currency == nil and IsValid(P) and P:IsPlayer() then
                        -- Используем NextRP систему
                        return P:CanAfford(amount)
                    else
                        -- Используем старую систему для других валют
                        return oldCanAfford(P, currency, amount)
                    end
                end
                
                print("[RDV COMPANIONS] NCS_SHARED переопределён для использования NextRP Money!")
            end
        end)
    end)
end

-- Клиентская часть интеграции
if CLIENT then
    hook.Add("InitPostEntity", "RDV_COMPANIONS_NextRP_Integration_Client", function()
        timer.Simple(3, function()
            -- Проверяем наличие NextRP HUD системы
            if NextRP and NextRP.MoneyHUD then
                print("[RDV COMPANIONS] Клиентская интеграция с NextRP Money HUD активна!")
            end
        end)
    end)
    
    -- Хук для обновления отображения денег после покупок
    hook.Add("RDV_COMPANIONS_MoneyChanged", "UpdateNextRPMoneyHUD", function()
        if NextRP and NextRP.MoneyHUD and NextRP.MoneyHUD.ForceUpdate then
            NextRP.MoneyHUD:ForceUpdate()
        end
    end)
end

-- Функция для логирования покупок (серверная)
if SERVER then
    hook.Add("RDV_COMPANIONS_CompanionPurchased", "LogCompanionPurchase", function(player, companionID, price)
        if not IsValid(player) then return end
        
        local logMessage = string.format("[COMPANIONS PURCHASE] %s (%s) купил компаньона '%s' за %d CR", 
            player:Nick(), 
            player:SteamID(), 
            companionID, 
            price or 0
        )
        
        print(logMessage)
        
        -- Можно добавить запись в файл логов или базу данных
        -- file.Append("companions_purchases.log", logMessage .. "\n")
    end)
end
