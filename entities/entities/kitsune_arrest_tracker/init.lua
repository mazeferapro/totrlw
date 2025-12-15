AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/reizer_props/alysseum_project/console/holo_screen_03/holo_screen_03.mdl")
    self:SetUseType(SIMPLE_USE)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:DrawShadow(false)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end
