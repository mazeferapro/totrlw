ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'
ENT.PrintName = 'Claimer'
ENT.Author = 'Kot'
ENT.Contact = ''
ENT.Purpose = ''
ENT.Instructions = ''
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = 'ROTR | Утилиты'
ENT.noDrag = true

function ENT:SetupDataTables()

	self:NetworkVar( 'String', 0, 'Title' )
	self:NetworkVar( 'String', 1, 'Claimers' )

    if SERVER then
        self:SetTitle('Местность №1')
        self:SetClaimers('Free')
    end
end