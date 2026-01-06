local theme = NextRP.Style.Theme

local function generateWeapons(scrollPanel, tWeapons)
    local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
		:Stick(TOP, 2)
		:ClearPaint()
		:On('OnToggle', function(self)

			if self:GetExpanded() then
				self.Header:TDLib()
					:ClearPaint()
					:Background(theme.Accent)
			else
				self.Header:TDLib()
					:ClearPaint()
					:Background(theme.DarkBlue)
			end

		end)

	DCategory.Header:TDLib()
		:ClearPaint()
		:Text('Получаемое', 'font_sans_21')

	if DCategory:GetExpanded() then
		DCategory.Header:TDLib():Background(theme.Accent)
	else
		DCategory.Header:TDLib():Background(theme.DarkBlue)
	end

	DCategory.Header:SetTall(25)

	local contents = vgui.Create('DPanelList', DCategory)

	contents:SetPadding(0)
	contents:SetSpacing(4)
	DCategory:SetContents(contents)

	for k, wep in pairs(tWeapons) do
		local tWep = weapons.Get(wep)
		if tWep == nil then continue end

		local pnl = vgui.Create('PawsUI.Panel')
			:Stick(TOP, 1)
			:Background(Color(53 + 15, 57 + 15, 68 + 15, 100))

		local wepMat = Material('entities/'..wep..'.png', 'smooth')

		local icon = vgui.Create('PawsUI.Panel', pnl)
			:Stick(LEFT, 2)


		PAW_MODULE('lib'):Download('nw/noicon.png', 'https://i.imgur.com/yaqb1ND.png', function(dPath)
			local mat = Material(dPath, 'smooth')
			if wepMat:IsError() then
				icon:Material(mat)
			else
				icon:Material(wepMat)
			end
		end)

		icon:SetWide(64)

		local title = vgui.Create('PawsUI.Panel', pnl)
			:Stick(TOP, 2)

		title:On('Paint', function(s, w, h)
			draw.DrawText(tWep.PrintName or wep, 'font_sans_21', 1, 5, NextRP.Style.Theme.Text, nil, TEXT_ALIGN_LEFT)
		end)

		local reciveButton = TDLib('DButton', pnl)
			:ClearPaint()
			:Stick(FILL, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:On('Think', function(s)
				if string.StartsWith(wep, 'medic') then
					if LocalPlayer():HasWeapon(wep) then
						s:Text('Сдать', 'font_sans_21')
					else
						s:Text('Получить', 'font_sans_21')
					end
				elseif LocalPlayer():HasWeapon(wep) then
					s:Text(tWep.Weight and ('Сдать ('..'-'..tWep.Weight..' нагрузки)') or 'Сдать (-5 нагрузки)', 'font_sans_21')
				else
					s:Text(tWep.Weight and ('Получить ('..'+'..tWep.Weight..' нагрузки)') or 'Получить (+5 нагрузки)', 'font_sans_21')
				end
			end)
			:On('DoClick', function()
				netstream.Start('NextRP::AmmunitionWeps', wep)
			end)

		pnl:SetTall(64 + 2)
		contents:Add(pnl)
	end
end
local function generateDWeapons(scrollPanel, tDWeapons)
    local DCategory = TDLib('DCollapsibleCategory', scrollPanel)
		:Stick(TOP, 2)
		:ClearPaint()
		:On('OnToggle', function(self)

			if self:GetExpanded() then
				self.Header:TDLib()
					:ClearPaint()
					:Background(theme.Accent)
			else
				self.Header:TDLib()
					:ClearPaint()
					:Background(theme.DarkBlue)
			end

		end)

	DCategory.Header:TDLib()
		:ClearPaint()
		:Text('Стандартное', 'font_sans_21')

	if DCategory:GetExpanded() then
		DCategory.Header:TDLib():Background(theme.Accent)
	else
		DCategory.Header:TDLib():Background(theme.DarkBlue)
	end

	DCategory.Header:SetTall(25)

	local contents = vgui.Create('DPanelList', DCategory)

	contents:SetPadding(0)
	contents:SetSpacing(4)
	DCategory:SetContents(contents)

	for k, wep in pairs(tDWeapons) do
		local tWep = weapons.Get(wep)
		if tWep == nil then continue end

		local pnl = vgui.Create('PawsUI.Panel')
			:Stick(TOP, 1)
			:Background(Color(53 + 15, 57 + 15, 68 + 15, 100))

		local wepMat = Material('entities/'..wep..'.png', 'smooth')

		local icon = vgui.Create('PawsUI.Panel', pnl)
			:Stick(LEFT, 2)


		PAW_MODULE('lib'):Download('nw/noicon.png', 'https://i.imgur.com/yaqb1ND.png', function(dPath)
			local mat = Material(dPath, 'smooth')
			if wepMat:IsError() then
				icon:Material(mat)
			else
				icon:Material(wepMat)
			end
		end)

		icon:SetWide(64)

		local title = vgui.Create('PawsUI.Panel', pnl)
			:Stick(TOP, 2)

		title:On('Paint', function(s, w, h)
			draw.DrawText(tWep.PrintName or wep, 'font_sans_21', 1, 5, NextRP.Style.Theme.Text, nil, TEXT_ALIGN_LEFT)
		end)

		local reciveButton = TDLib('DButton', pnl)
			:ClearPaint()
			:Stick(FILL, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:On('Think', function(s)
				if LocalPlayer():HasWeapon(wep) then
					s:Text(tWep.Weight and ('Сдать ('..'-'..tWep.Weight..' нагрузки)') or 'Сдать (-5 нагрузки)', 'font_sans_21')
				else
					s:Text(tWep.Weight and ('Получить ('..'+'..tWep.Weight..' нагрузки)') or 'Получить (+5 нагрузки)', 'font_sans_21')
				end
			end)
			:On('DoClick', function()
				netstream.Start('NextRP::AmmunitionWeps', wep)
			end)

		pnl:SetTall(64 + 2)
		contents:Add(pnl)
	end
end

local function Ammunition(tWeapons, tDWeapons)
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Оружейный ящик')
    frame:SetSize(1000, 600)
    frame:MakePopup()
    frame:Center()
    frame:ShowSettingsButton(false)

    local leftpanel = vgui.Create('PawsUI.Panel', frame)
        :Stick(RIGHT)
		:Background(Color(53 + 15, 57 + 15, 68 + 15, 100))
        :DivWide(3)

    local giveweapons = TDLib('DButton', leftpanel)
			:ClearPaint()
			:Stick(TOP, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:Text('Взять всё вооружение', 'font_sans_21')
			:On('DoClick', function()
				netstream.Start('NextRP::AmmunitionGiveAll')
			end)

	giveweapons:SetTall(64 + 2)

	local removeweapons = TDLib('DButton', leftpanel)
			:ClearPaint()
			:Stick(TOP, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:Text('Положить всё вооружение', 'font_sans_21')
			:On('DoClick', function()
				netstream.Start('NextRP::AmmunitionRemoveAll')
			end)

	removeweapons:SetTall(64 + 2)

	local giveammo = TDLib('DButton', leftpanel)
			:ClearPaint()
			:Stick(TOP, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:Text('Взять патроны', 'font_sans_21')
			:On('DoClick', function()
				netstream.Start('NextRP::Dispenser', 1)
			end)

	giveammo:SetTall(64 + 2)

	local giverocket = TDLib('DButton', leftpanel)
			:ClearPaint()
			:Stick(TOP, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:Text('Взять ракеты', 'font_sans_21')
			:On('DoClick', function()
				netstream.Start('NextRP::Dispenser', 2)
			end)

	giverocket:SetTall(64 + 2)

	local givegrenade = TDLib('DButton', leftpanel)
			:ClearPaint()
			:Stick(TOP, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:Text('Взять гранаты', 'font_sans_21')
			:On('DoClick', function()
				netstream.Start('NextRP::Dispenser', 3)
			end)

	givegrenade:SetTall(64 + 2)

	local givegrenade = TDLib('DButton', leftpanel)
			:ClearPaint()
			:Stick(TOP, 2)
			:Background(NextRP.Style.Theme.Background)
			:FadeHover(NextRP.Style.Theme.Accent)
			:LinedCorners()
			:Text('Взять ГП', 'font_sans_21')
			:On('DoClick', function()
				netstream.Start('NextRP::Dispenser', 5)
			end)

	givegrenade:SetTall(64 + 2)

	local title = vgui.Create('PawsUI.Panel', leftpanel)
		:Stick(TOP, 2)
		:Text('Нагрузка:')

	local weightpanel = vgui.Create('PawsUI.Panel', leftpanel)
			:ClearPaint()
			:Stick(TOP, 2)
			:Background(NextRP.Style.Theme.Background)
			:On('Paint', function(s, w, h)
				local weight = LocalPlayer():GetNWInt('picked')
			    makeBar(weight, 0, 0, w, h, color_white, 0)
			    if weight >= 50 then makeBar(weight-50, 0, 0, w, h, Color(255,0,0), 0) end
			end)

	weightpanel:SetTall(30)
-- ar

    local info = vgui.Create('PawsUI.Panel', frame)
        :Stick(FILL)

	local scrollPanel = TDLib('DScrollPanel', frame)
        :Stick(FILL, 2)

	local scrollPanelBar = scrollPanel:GetVBar()
	scrollPanelBar:TDLib()
		:ClearPaint()
		:Background(theme.DarkScroll)

	scrollPanelBar.btnUp:TDLib()
		:ClearPaint()
		:Background(theme.DarkScroll)
		:CircleClick()

	scrollPanelBar.btnDown:TDLib()
		:ClearPaint()
		:Background(theme.DarkScroll)
		:CircleClick()

	scrollPanelBar.btnGrip:TDLib()
		:ClearPaint()
		:Background(theme.Scroll)
		:CircleClick()

	if table.Count(tWeapons) > 0 then
        generateWeapons(scrollPanel, tWeapons)
    end
    if table.Count(tDWeapons) > 0 then
        generateDWeapons(scrollPanel, tDWeapons)
    end
end


local function removeAllDuplicates(tbl)
    local seen = {}
    local result = {}

    for _, v in ipairs(tbl) do
        if not seen[v] then
            seen[v] = true
            table.insert(result, v)
        end
    end

    return result
end


netstream.Hook('NextRP::OpenAmmunitionMenu', function(tWeapons, tDWeapons)
	local uniqWep = removeAllDuplicates(tWeapons)
	local uniqDWep = removeAllDuplicates(tDWeapons)
	Ammunition(uniqWep, uniqDWep)
end)

function makeBar(val, x, y, w, h, col, angle, max)
        polyRect(x, y, w, h, angle, angle, Color(72,72,72,135))
        polyRect(x, y, math.Clamp(val, 0, max or 100)/(max or 100) * w, h, angle, angle, col)
    end

function polyRect(x,y,w,h,angle,rotate,color)
        local rect = {
          { x = x, y = y + h },
          { x = x + rotate, y = y },
          { x = x + w + angle, y = y },
          { x = x + w, y = y + h }
        }
        surface.SetDrawColor( color )
        draw.NoTexture()
        surface.DrawPoly( rect )
end