local function CRotRAdminUI(tPlayers)
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('CTotR Админ-панель')
    frame:SetSize(960, 720)
    frame:MakePopup()
    frame:Center()
    frame:ShowSettingsButton(false)

    local content = vgui.Create('PawsUI.ScrollPanel', frame)
    content:Dock(FILL)
    content
        :TDLib()

    for sID, pData in pairs(tPlayers) do
	    local nam = vgui.Create('PawsUI.Panel')
	    nam:SetTall(64)
	    nam
	    	:Stick(TOP,5)
	    	:On('Think', function(s)
	    		s:ClearPaint()
	    		s:Text(tPlayers[sID].sName..' CTotRы: '..tPlayers[sID].crotrs, 'font_sans_32')
	    	end)

	    local ava = TDLib('AvatarImage', nam)
	    ava:SetSteamID(sID,64)
	    ava:SetSize(64,64)

	    local adm = vgui.Create('PawsUI.Button', nam)
	    adm:SetTall(32)
	    adm:SetLabel('')
	    adm
	    	:Stick(RIGHT, 5)
	    	:DivWide(20)
	    	:FadeHover(NextRP.Style.Theme.Blue)
	    	:CircleClick(NextRP.Style.Theme.AlphaWhite)
	    	:On('Paint', function(s, w, h)
	    		draw.SimpleText('Выдать', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	    	end)
	    	:On('DoClick', function()
	    		NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
                'Установите количество CTotRов для выдачи.\n\n!ВНИМАНИЕ!\n\nЭто количество прибавится к уже имеющимся! Чтобы забрать CTotRы используйте отрицательные значения.',
                '',
                'Установить', function(sValue)
                	local nCrotrs = tonumber(sValue)
                	if nCrotrs == nil then chat.AddText('Введите число!') return end
                    netstream.Start('NextRP::AddCRotRs', sID, nCrotrs)
                    tPlayers[sID].crotrs = tPlayers[sID].crotrs + nCrotrs
                end,
                'Отмена', nil)
	    	end)
	    content:Add(nam)
	end
end

netstream.Hook('NextRP::CRotROpenAdmin', function(tCRotR)
	local tPlayers = {}
	if tCRotR[1] == nil then return end
	for _, v in ipairs(tCRotR) do
		steamworks.RequestPlayerInfo(v.community_id, function(sName)
			tPlayers[v.community_id] = {['crotrs'] = v.crotrs,['sName'] = sName}
		end)
	end
    CRotRAdminUI(tPlayers)
end)