KitsuneBP = KitsuneBP or {}

KitsuneBP.Config = KitsuneBP.Config or {}

local LIB = PAW_MODULE('lib')
local plydata = plydata or {}

local function bpcontent(pnl)

		local content = TDLib('DPanel', pnl)
	        :ClearPaint()

	    content:SetPos(0, 0)
	    content:SetSize(pnl:GetWide(), pnl:GetTall())

	    local header = TDLib('DPanel', content)
        	:ClearPaint()
        	:Stick(TOP, 5)
        	:DivTall(22)

	    local close = TDLib('DButton', header)
		    :Text('', 'font_sans_16')
		    :Stick(RIGHT)
		    :SetRemove(pnl)
		    :ClearPaint()
		    :Background(Color(40,40,40, 200))
		    :FadeHover()
		    :On('Paint', function(s, w, h)
		        surface.SetDrawColor(color_white)
		        surface.SetMaterial(PawsUI.Materials.CloseButton)
		        surface.DrawTexturedRect(12, 12, w - 24, h - 24)
		    end)

	    close:SetSize(32,32)

	    local leftpanel = TDLib('DPanel', pnl)
	    	:ClearPaint()

	    leftpanel:SetSize(content:GetWide()/2, content:GetTall()/2)
	    leftpanel:SetPos(50, 100)


	    local icon = TDLib('DModelPanel', leftpanel)
	        :Stick(FILL)
	        :Text('', 'font_sans_56')

	    icon:SetLookAt( Vector(0,0,0) )
		icon:SetCamPos( Vector(150,200,72))
		icon:SetFOV(20)

	    local kostpnl = TDLib('DPanel', pnl)
	    	:ClearPaint()
	    	:On('Paint', function(s, w, h)
		        surface.SetDrawColor(color_white)
	    		surface.DrawOutlinedRect(0, 0, w, h)
	      	end)

	    kostpnl:SetSize(leftpanel:GetSize())
	    kostpnl:SetPos(leftpanel:GetPos())

	    pnl.modelPanel = icon

	    local rightpanel = TDLib('DPanel', pnl)
	    	:ClearPaint()
	    	:On('Paint', function(s, w, h)
		        surface.SetDrawColor(color_white)
	    		surface.DrawOutlinedRect(0, 0, w, h)
	      	end)

	    	rightpanel:SetSize(content:GetWide()/3, content:GetTall()/2)
	      	rightpanel:SetPos(content:GetWide()-rightpanel:GetWide()-10, 100)

	    local objectives = TDLib('DPanel', rightpanel)
	    	:ClearPaint()
	    	:Stick(FILL)

	    local scroller = TDLib('DScrollPanel', objectives)
	    	:ClearPaint()
	    	:Stick(FILL, 5)
	    	:HideVBar()



	    for _, v in ipairs(KitsuneBP.Config.Objectives) do

	    	local ids = v.uid and plydata[v.uid] or '0'
	    	local check = table.HasValue(plydata.completed, v.uid)
	    	if check then ids = v.obj end

	    	local obj = TDLib('DPanel')
	    		:ClearPaint()
	    		:Stick(TOP, 5)
	    		:DivTall(20)

	    	local objtext = TDLib('DPanel', obj)
	    		:ClearPaint()
	    		:Stick(TOP)
	    		:DivTall(2)
	    		:DualText(
	    			v.title or 'nottitle',
	    			ScrH() >= 1440 and 'font_sans_21' or 'font_sans_16',
	    			color_white,
	    			'Вы получите очков: '..v.reward,
	    			ScrH() >= 1440 and 'font_sans_21' or 'font_sans_16',
	    			color_white
	    		)

	    	local objbar = TDLib('DPanel', obj)
	    		:ClearPaint()
	    		:Stick(BOTTOM)
	    		:DivTall(3)
	    		:On('Paint', function(s, w, h)
	    			polyRect(5, 5, math.Clamp(ids, 0, v.obj)/v.obj * (w-10), h-5, 0, 0, NextRP.Style.Theme.Accent)
	    			surface.SetDrawColor(color_white)
	    			surface.DrawOutlinedRect(5, 5, w-10, h-5)
	    		end)
	    		:Text(check and 'ЗАВЕРШЕНО!' or ids..' / '..v.obj, 'font_sans_21')

	    	scroller:Add(obj)
	    end

	    local check = 999
	    local level = 0
	    if not plydata.stars then plydata['stars'] = 0 end

	    for _, v in ipairs(KitsuneBP.Config.Free) do
	    	if plydata.stars and plydata.stars >= v.required then level = level + 1 continue else check = v.required break end
	    end

	    local progresspanel = TDLib('DPanel', content)
	    	:ClearPaint()
	    	:On('Paint', function(s, w, h)
	    		polyRect(5, 5, math.Clamp(plydata.stars or 0, 0, check)/check * (w-10), h-5, 0, 0, NextRP.Style.Theme.Accent)
	    		surface.SetDrawColor(color_white)
	    		surface.DrawOutlinedRect(5, 5, w-10, h-5)
	    	end)
	    	:DualText(
	    		'До следующего уровня',
	    		'font_sans_21',
	    		color_white,
	    		plydata.stars..' / '..check,
	    		'font_sans_21'
	    	)

	    progresspanel:SetSize(rightpanel:GetWide(), rightpanel:GetTall()/5)
	    progresspanel:SetPos(content:GetWide() - rightpanel:GetWide() - 10, rightpanel:GetTall() + 110)

	    local basement = TDLib('DPanel', content)
	    	:ClearPaint()
	    	:Stick(BOTTOM, 15)
	    	:DivTall(5)

	    local footer = TDLib('DPanel', basement)
        	:ClearPaint()
        	:Stick(BOTTOM) -- Заменить на TOP при добавлении према
        	:DivTall(2.2)

	    local butonscroller = TDLib('DHorizontalScroller', footer)
	        :Stick(FILL)
	        :ClearPaint()

    	butonscroller:SetOverlap(-10)
    	butonscroller.btnLeft.Paint = function() end
		butonscroller.btnLeft:SetCursor('arrow')
		butonscroller.btnLeft:SetEnabled(false)
		butonscroller.btnRight:SetCursor('arrow')
		butonscroller.btnRight.Paint = function() end
		butonscroller.btnRight:SetEnabled(false)

    	local count = ((butonscroller:GetWide()-50)/5)

    	for k, v in pairs(KitsuneBP.Config.Free) do
    		local name
    		if v.text ~= '' then
    			name = v.text
    		else
    			if v.reward.typing == 'xp' then name = 'Опыт' elseif v.reward.typing == 'weaponskin' then name = 'Скин на оружие \n' elseif v.reward.typing == 'points' then name = 'Очки прокачки' elseif v.reward.typing == 'discount' then name = 'Скидка' else name = 'vip' end
    		end

	        local lvlpnl = TDLib('DPanel')
	            :ClearPaint()
	            :Background(Color(47, 54, 64, 25))

	        lvlpnl:SetWide(count)

	        butonscroller:AddPanel(lvlpnl)

	        local chooseButton = TDLib('DButton', lvlpnl)
	            :ClearPaint()
	            :Background(level >= k and NextRP.Style.Theme.Accent or Color(47, 54, 64, 70))
	            :Text(level < k and name or 'Награда получена', 'font_sans_21')
	            :On('Think', function(s)
	            end)
	            :On('DoClick', function()
	        	   	if v.reward.typing == 'xp' and v.reward.path then --[[pnl.modelPanel:SetModel(v.reward.path)]] pnl.modelPanel:SetText(v.reward.path..' ОПЫТА') print(pnl.modelPanel.Text) elseif v.reward.typing == 'points' and v.reward.path then pnl.modelPanel:SetText('ОЧКИ ПРОКАЧКИ: '..v.reward.path) end
	        	   	--if v.reward.typing == 'playerskin' then pnl.modelPanel:SetFOV(40) pnl.modelPanel:SetLookAt( Vector(0,0,40) ) else pnl.modelPanel:SetFOV(20) pnl.modelPanel:SetLookAt( Vector(0,0,0) ) end
	            end)

	        chooseButton:SetSize(lvlpnl:GetSize())
	    end

    	--[[local premfooter = TDLib('DPanel', basement)
        	:ClearPaint()
        	:Stick(BOTTOM)
        	:DivTall(2.2)

	    local prembutonscroller = TDLib('DHorizontalScroller', premfooter)
	        :Stick(FILL)
	        :ClearPaint()

    	prembutonscroller:SetOverlap(-10)
    	prembutonscroller.btnLeft.Paint = function() end
		prembutonscroller.btnLeft:SetCursor('arrow')
		prembutonscroller.btnLeft:SetEnabled(false)
		prembutonscroller.btnRight:SetCursor('arrow')
		prembutonscroller.btnRight.Paint = function() end
		prembutonscroller.btnRight:SetEnabled(false)


	    for k, v in pairs(KitsuneBP.Config.Premium) do

	        local premlvlpnl = TDLib('DPanel')
	            :ClearPaint()
	            :Background(Color(47, 54, 64, 70))

	        premlvlpnl:SetWide(count)

	        prembutonscroller:AddPanel(premlvlpnl)

	        local premicon = TDLib('DPanel', premlvlpnl)
                :ClearPaint()

            premicon.s = 64
            premicon.col = color_white
            premicon:SetSize(premlvlpnl:GetWide(), 240)
            premicon:SetPos(premlvlpnl:GetWide() * 0.5 - premicon:GetWide() * 0.5, premlvlpnl:GetTall() * 0.5 - 180 * 0.5)

            LIB:Download('nw/crown.png', 'https://i.imgur.com/1eWUdlj.png', function(dPath)
                local mat = Material(dPath, 'smooth noclamp')

                premicon:On('Paint', function(s)
                    surface.SetMaterial(mat)
                    surface.SetDrawColor(premicon.col)
                    surface.DrawTexturedRect(premicon:GetWide() * 0.5 - premicon.s * 0.5, 180 * 0.5 - premicon.s * 0.5, premicon.s, premicon.s)
                end)
            end)

	        local premchooseButton = TDLib('DButton', premlvlpnl)
	            :ClearPaint()
	            :Background(level >= k and NextRP.Style.Theme.Accent or Color(47, 54, 64, 70))
	            :Text(level < k and (v.text or k) or 'Награда получена', 'font_sans_21')
	            :On('Think', function(s)
	        	   	premicon.col = TDLibUtil.LerpColor(FrameTime() * 12, premicon.col, s:IsHovered() and NextRP.Style.Theme.Accent or color_white)
	            	premicon.s = Lerp(FrameTime() * 12, premicon.s, s:IsHovered() and 128 or 64)
	            end)
	            :On('DoClick', function()
	        	   	if v.reward.typing == 'weaponskin' and v.reward.path then pnl.modelPanel:SetModel(v.reward.path) end
	        	   	--if v.reward.typing == 'playerskin' then pnl.modelPanel:SetFOV(40) pnl.modelPanel:SetLookAt( Vector(0,0,40) ) else pnl.modelPanel:SetFOV(20) pnl.modelPanel:SetLookAt( Vector(0,0,0) ) end
	            end)

	        premchooseButton:SetSize(premlvlpnl:GetSize())
	    end]]--
    return content
end


local function bpopenui()
	local main = TDLib('DFrame')
        :ClearPaint()
        :On('Paint', function(s, w, h)
            surface.SetMaterial(NextRP.Style.Materials.CharacterSystemBackground)
            surface.SetDrawColor(150, 150, 150, 255)
            surface.DrawTexturedRect(0, 0, w, h)
            surface.SetDrawColor(NextRP.Style.Theme.Accent)
            surface.DrawRect(0, 0, w, 5)
            surface.DrawRect(0, h - 5, w, 5)
        end)
    main:SetSize(ScrW()/2, ScrH()/2)
    main:Center()
    main:MakePopup()
    main:SetTitle('')
    main:ShowCloseButton(false)
    main:SetDraggable(false)

	local pnl = bpcontent(main)
end


net.Receive('KitsuneBPOpenMenu', function()
	local sData = net.ReadString()
	plydata = sData and util.JSONToTable(sData) or {}

	bpopenui()
end)
