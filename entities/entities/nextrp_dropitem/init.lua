AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(5)
    end
    
    -- Автоудаление через 5 минут
    timer.Simple(NextRP.Inventory.Config.DroppedItemLifetime, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

function ENT:SetItemData(itemID, amount)
    self:SetItemID(itemID)
    self:SetItemAmount(amount or 1)
    
    local itemData = NextRP.Inventory:GetItemData(itemID)
    
    -- Модель по умолчанию (коробка), если у предмета нет своей
    local modelToSet = "models/props_junk/cardboard_box001a.mdl"
    local skinToSet = 0
    
    if itemData then
        -- Проверяем, указана ли модель для выброса (dropModel) или обычная модель (model)
        if itemData.dropModel then
            modelToSet = itemData.dropModel
        elseif itemData.model then
            modelToSet = itemData.model
        end
        
        -- Если у предмета есть скин (например, для цветных карточек)
        if itemData.skin then
            skinToSet = itemData.skin
        end
    end
    
    -- Устанавливаем модель
    self:SetModel(modelToSet)
    self:SetSkin(skinToSet)
    
    -- [ВАЖНО] Пересоздаем физику под новую модель
    -- Без этого новая модель будет иметь коллизию от старой коробки
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    -- "Будим" физику, чтобы предмет упал на землю
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        -- Можно немного изменить массу в зависимости от размера предмета, если нужно
        -- phys:SetMass(10) 
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Анти-спам (защита от двойного срабатывания)
    if self.NextUse and self.NextUse > CurTime() then return end
    self.NextUse = CurTime() + 1
    
    local itemID = self:GetItemID()
    local amount = self:GetItemAmount()
    
    -- Напрямую вызываем функцию добавления в инвентарь
    local success, err = NextRP.Inventory:AddItem(activator, itemID, amount)
    
    if success then
        -- Если предмет добавлен, проигрываем звук и удаляем энтити
        activator:EmitSound("items/itempickup.wav")
        self:Remove()
    else
        -- Если ошибка (нет места и т.д.), пишем игроку
        activator:ChatPrint("Не удалось подобрать: " .. (err or "нет места"))
    end
end

function ENT:Think()
    self:NextThink(CurTime() + 1)
    return true
end