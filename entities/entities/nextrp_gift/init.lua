AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include('shared.lua')
 
-- === КОНФИГУРАЦИЯ ПОДАРКА ===
local GiftConfig = {
    -- Модели подарков
    Models = {
        'models/gift/christmas_gift.mdl',
        'models/gift/christmas_gift_2.mdl',
    },
    
    -- Настройки Денег
    Money = {
        Min = 1,  -- Минимальная сумма
        Max = 1000, -- Максимальная сумма
        Chance = 50 -- Шанс выпадения денег (в процентах, от 0 до 100). Оставшиеся % - это опыт.
    },

    -- Настройки Опыта
    XP = {
        Min = 1,  -- Минимальный опыт
        Max = 1000, -- Максимальный опыт
    }
}
-- ============================

function ENT:Initialize()
	self:SetModel( GiftConfig.Models[math.random(1, #GiftConfig.Models)] )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() 
	end

	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(pPlayer)
    if not IsValid(pPlayer) or not pPlayer:IsPlayer() then return end

    -- Определяем тип награды (Деньги или Опыт)
    local isMoney = math.random(1, 100) <= GiftConfig.Money.Chance
    
    if isMoney then
        -- Выдаем Деньги
        local amount = math.random(GiftConfig.Money.Min, GiftConfig.Money.Max)
        pPlayer:AddMoney(amount)
        
        -- Уведомление (используем стандартный чат, чтобы избежать ошибок, если NextRP:SendGlobalMessage нет)
        pPlayer:ChatPrint("[Подарок] Вы нашли " .. string.Comma(amount) .. " кредитов!")
    else
        -- Выдаем Опыт
        local amount = math.random(GiftConfig.XP.Min, GiftConfig.XP.Max)
        
        -- Проверка на наличие функции (защита от ошибок)
        if NextRP and NextRP.Progression and NextRP.Progression.AddXP then
            NextRP.Progression:AddXP(pPlayer, amount)
            pPlayer:ChatPrint("[Подарок] Вы получили " .. amount .. " опыта!")
        else
            -- Если NextRP не найден, выдаем деньги как резерв
            pPlayer:AddMoney(amount * 10)
            pPlayer:ChatPrint("[Подарок] Ошибка системы опыта. Выдана компенсация деньгами: " .. (amount * 10))
            print("[ERROR] NextRP.Progression:AddXP not found!")
        end
    end

    -- Удаляем подарок после использования
    self:Remove()
end