ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Сумка"
ENT.Author = "NextRP"
ENT.Category = "NextRP"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "OwnerSteamID")
    self:NetworkVar("String", 1, "OwnerName")      -- Имя персонажа для отображения
    self:NetworkVar("Int", 0, "ItemCount")
    self:NetworkVar("Int", 1, "OwnerCharID")       -- ID персонажа-владельца
end