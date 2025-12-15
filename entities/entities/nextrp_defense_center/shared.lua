-- gamemode/modules/autoevents/entities/nextrp_defense_center/shared.lua

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Центр обороны"
ENT.Category = "ROTR | Авто-ивенты"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Model = "models/reizer_props/srsp/sci_fi/command_table_02/command_table_02.mdl"

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("String", 0, "CenterName")
    self:NetworkVar("Int", 0, "DefenseRadius")
end