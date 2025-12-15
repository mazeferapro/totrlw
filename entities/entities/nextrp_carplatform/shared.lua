ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'
ENT.PrintName = 'Спавн платформа'
ENT.Author = 'Kot'
ENT.Contact = ''
ENT.Purpose = ''
ENT.Instructions = ''
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = 'ROTR | Техника'
ENT.Editable = false
ENT.Carry = false

function ENT:SetupDataTables()

	self:NetworkVar( 'Int', 0, 'Number' )

    if SERVER then
        self:SetNumber(0)
    end

end