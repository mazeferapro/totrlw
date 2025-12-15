hook.Add( "Initialize", "WorkshopLoad_Initialize", function()
	for k, v in pairs( engine.GetAddons() ) do
		local _file = v.wsid and v.wsid or string.gsub( tostring( v.file ), "%D", "" )
		resource.AddWorkshop( _file )
	end
end )