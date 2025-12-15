-- gamemode/modules/autoevents/entities/nextrp_npc_spawn/shared.lua

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Зона спавна NPC"
ENT.Category = "ROTR | Авто-ивенты"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("String", 0, "SpawnName")
    self:NetworkVar("Int", 0, "SpawnRadius")
end