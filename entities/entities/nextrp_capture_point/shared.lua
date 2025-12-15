-- gamemode/modules/autoevents/entities/nextrp_capture_point/shared.lua

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Точка захвата"
ENT.Category = "ROTR | Авто-ивенты"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Model = "models/reizer_props/srsp/sci_fi/command_table_01/command_table_01.mdl"

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Captured")
    self:NetworkVar("Bool", 1, "Active")
    self:NetworkVar("Float", 0, "CaptureProgress")
    self:NetworkVar("String", 0, "PointName")
    self:NetworkVar("Int", 0, "CaptureRadius")
end