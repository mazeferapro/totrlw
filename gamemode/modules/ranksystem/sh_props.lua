local ranks = NextRP.Ranks
properties.Add( "openrank", {
	MenuLabel = "Управление персонажем", -- Name to display on the context menu
	Order = 1, -- The order to display this property relative to other properties
	MenuIcon = "icon16/database_edit.png", -- The icon to display next to the property

	Filter = function( self, ent ) -- A function that determines whether an entity is valid for this property
		if ( !ent:IsPlayer() ) then return false end
		local isARC = LocalPlayer():GetNVar('nrp_charflags')['arc'] or false

        if ranks:Can(LocalPlayer(), ent) or isARC then
            return true
        end

		return false 
	end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		ranks:OpenUI(ent)
	end,
	Receive = function( self, length, player ) -- The action to perform upon using the property ( Serverside )
        
	end 
} )

properties.Add( "slots", {
	MenuLabel = "Управление слотами", -- Name to display on the context menu
	Order = 1, -- The order to display this property relative to other properties
	MenuIcon = "icon16/database_edit.png", -- The icon to display next to the property

	Filter = function( self, ent ) -- A function that determines whether an entity is valid for this property
		if ( !ent:IsPlayer() ) then return false end
		
        if NextRP:HasPrivilege(LocalPlayer(), 'manage_slots') then
            return true
        end

		return false 
	end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		PAW_MODULE('lib'):DoStringRequest('Введите кол-во слотов', 'Введите кол-во слотов (Уже установлено текущее кол-во слотов): ', ent:GetNVar('nrp_slots'), function(sValue)
			self:MsgStart()
				net.WriteEntity(ent)
				net.WriteString(sValue)
			self:MsgEnd()
		end, nil, 'Применить', 'Отмена')
	end,
	Receive = function( self, length, player ) -- The action to perform upon using the property ( Serverside )
        
        local ent = net.ReadEntity()
		local slots = net.ReadString()

		slots = tonumber(slots)
		if not slots then return end

		if NextRP:HasPrivilege(player, 'manage_slots') then
			ent:SetNVar('nrp_slots', slots, NETWORK_PROTOCOL_PUBLIC)
			ent:SavePlayerData( 'char_slots', slots)
		end
	end 
} )