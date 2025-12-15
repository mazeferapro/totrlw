ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'
ENT.PrintName = 'Точка захвата'
ENT.Author = 'Kot'
ENT.Contact = ''
ENT.Purpose = ''
ENT.Instructions = ''
ENT.Category = 'ROTR | DEV'
ENT.Carry = false
ENT.Spawnable = true
ENT.noDrag = true

function ENT:SetupDataTables()

	self:NetworkVar( 'Int', 0, 'Control' )
	self:NetworkVar( 'Int', 1, 'Radius' )
	self:NetworkVar( 'Int', 2, 'Invader' )
	self:NetworkVar( 'Int', 3, 'Points' )
    self:NetworkVar( 'Int', 4, 'LastCaptured' )
    self:NetworkVar( 'Int', 5, 'NextInvade' )

	self:NetworkVar( 'String', 0, 'Title' )
	self:NetworkVar( 'String', 1, 'Description' )

    if SERVER then
        self:SetControl(-1)
        self:SetRadius(100)
        self:SetInvader(-1)
        self:SetPoints(0)
        self:SetLastCaptured(100000)
        self:SetNextInvade(120)

        self:SetTitle('Точка захвата')
        self:SetDescription('Эта местность нужна Нам!')

        self:NetworkVarNotify( 'Control', self.OnCaptured )
    end

end