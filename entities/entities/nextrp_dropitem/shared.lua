ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Выброшенный предмет"
ENT.Author = "NextRP"
ENT.Category = "NextRP"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "ItemID")
    self:NetworkVar("Int", 0, "ItemAmount")
    self:NetworkVar("String", 1, "DroppedBy")
end