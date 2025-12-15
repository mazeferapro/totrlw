hook.Add('NextRP::ModulesLoaded', 'NextRP::ThemeParser', function()
	for k, v in pairs(NextRP.Style.Materials) do
		local path = 'nextrp/theme/'..NextRP.ServerID..'_'..NextRP.Style.ID..'/'..string.lower(k)..'.png'
		local dPath = 'data/'..path
	
		if(file.Exists(path, 'DATA')) then NextRP.Style.Materials[k] = Material(dPath, 'mips smooth') end
		if(!file.IsDir(string.GetPathFromFilename(path), 'DATA')) then file.CreateDir(string.GetPathFromFilename(path)) end
	
		http.Fetch(v, function(body, size, headers, code)
			if(code != 200) then return errorCallback(code) end
			file.Write(path, body)
			NextRP.Style.Materials[k] = Material(dPath, 'mips smooth')
		end)
	end

	hook.Call('NextRP::IconLoaded', GM)
end)


