-- ============================================================================
-- entities/entities/nextrp_temp_crate/shared.lua
-- Временный ящик для хранения предметов (не сохраняется в БД)
-- ============================================================================

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Временный ящик"
ENT.Author = "NextRP"
ENT.Category = "NextRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true

-- Сетевые переменные
function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "CrateName")
    self:NetworkVar("Int", 0, "ItemCount")
    self:NetworkVar("Int", 1, "GridWidth")
    self:NetworkVar("Int", 2, "GridHeight")
end