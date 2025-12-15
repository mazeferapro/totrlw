ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'
ENT.PrintName = 'Точка спавна'
ENT.Author = 'Kot'
ENT.Contact = ''
ENT.Purpose = ''
ENT.Instructions = ''
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = 'ROTR | Утилиты'
ENT.Editable = false
ENT.Carry = false
ENT.noDrag = true

function ENT:SetupDataTables()
    self:NetworkVar('String', 0, 'JobID')

    if SERVER then
        self:SetJobID('ct1')
    end
end