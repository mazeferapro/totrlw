local LIB = PAW_MODULE('lib')

local W = ScrW
local H = ScrH

local scoreboard = NextRP.Scoreboard

scoreboard.Base = scoreboardBase
scoreboard.Blur = scoreboardBlur

--local ping = NextRP.Style.Materials.Ping
--Material('ping/ping_normal1.png', 'mips')

local function pingColor(pPlayer)
    local p = 1
    if IsValid(pPlayer) and pPlayer ~= NULL then
        p = pPlayer:Ping()
    end

    if p <= 50 then
        return NextRP.Style.Theme.Green
    elseif p <= 100 then
        return NextRP.Style.Theme.Yellow
    else
        return NextRP.Style.Theme.Red
    end
end

function scoreboard:Player(pPlayer)
    if pPlayer == nil or pPlayer == NULL or !IsValid(pPlayer) then return end

    local spec = pPlayer:GetNVar('nrp_charflags') or {}
	local jt = pPlayer:getJobTable()
    local rank = pPlayer:GetRank()

	local final = 'Без специализации'
    if spec then
        for k, v in pairs(spec) do
            if not istable(final) then final = {} end
            if jt.flags[k] then final[#final + 1] = jt.flags[k].id elseif NextRP.Config.Pripiskis[k] then final[#final + 1] = NextRP.Config.Pripiskis[k].id end
        end
    else
        final = 'СЛОМАН'
    end

	if istable(final) then
		final = table.concat(final, ', ')
	end

    local PlayerPanel = TDLib('DPanel')
        :Stick(TOP)
        :ClearPaint()
        :On('Paint', function(s, w, h)

            surface.SetDrawColor(40, 40, 40, 150)
            surface.DrawRect(0, 0, w, h)

            draw.SimpleText(rank, 'font_sans_21', 64 + 16 + 4 + 20, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetFont('font_sans_21')
            local nx = surface.GetTextSize('####')

            surface.SetDrawColor(40, 40, 40, 150)
            surface.DrawRect(64 + 16 + 4 + 56 + 70 - nx, 0, nx  * 2, h)

            draw.SimpleText(IsValid(pPlayer) and pPlayer:GetNumber() or '----', 'font_sans_21', 64 + 16 + 4 + 56 + 70, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.SimpleText(IsValid(pPlayer) and pPlayer:Nick1() or 'Имя', 'font_sans_21', 64 + 16 + 4 + 56 + 120 + 49 + 50, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.SimpleText(final, 'font_sans_21', w*.5, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(pingColor(pPlayer))
            if isstring(NextRP.Style.Materials.Ping) then draw.SimpleText(pPlayer:Ping()) else surface.SetMaterial(NextRP.Style.Materials.Ping) end

            surface.DrawTexturedRect(w - 64 - 16 - 9 - 23, h*.5 - 8, 16, 16)
            --print(IsUnique(pPlayer))

            if !istable(IsUnique(pPlayer)) then
                draw.SimpleText(IsValid(pPlayer) and pPlayer:GetUserGroup() or 'Игрок', 'font_sans_21', w - 16 - 4 - 38 - 300,  h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                 draw.SimpleText(IsUnique(pPlayer)[1], 'font_sans_21', w - 16 - 4 - 38 - 300, h * .5 - 1, IsUnique(pPlayer)[2] and HSVToColor(  ( CurTime() * 100 ) % 360, 1, 1 ) or NextRP.Style.Theme.HightlightText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            local frags = (IsValid(pPlayer) and pPlayer:Frags() >= 0 and pPlayer:Frags() or '0') or '0'
            draw.SimpleText(frags..' / '..(IsValid(pPlayer) and pPlayer:Deaths() or '0'), 'font_sans_21', w - 16 - 4 - 38 - 170,  h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end)

    PlayerPanel:SetHeight(32)
    PlayerPanel:DockMargin(0, 3, 0, 0)

    local Avatar = TDLib('AvatarImage', PlayerPanel)
    Avatar:SetPos(84 * .5 - 32 + 12, 0)
    Avatar:SetSize(32, 32)

    Avatar:SetPlayer(pPlayer)

    local ActionButton = TDLib('DButton', PlayerPanel)
        :ClearPaint()
        :Text('')
        :FadeHover(Color(230, 230, 230, 15))
        :On('DoClick', function(s, w, h)
            local Menu = vgui.Create('Paws.Menu')
                Menu:AddOption('Скопировать SteamID', function() SetClipboardText( pPlayer:SteamID() ) surface.PlaySound('gmodadminsuite/success.ogg') end):SetIcon('icon16/add.png')
                Menu:AddOption('Steam профиль', function() gui.OpenURL( "http://steamcommunity.com/profiles/"..pPlayer:SteamID64() ) surface.PlaySound('gmodadminsuite/success.ogg') end):SetIcon('icon16/world_go.png')

                if LocalPlayer():IsAdmin() then
                    local AdminActions, Parent = Menu:AddSubMenu( 'Админ меню', function() RunConsoleCommand('sam', 'menu') scoreboard:ScoreboardToggle(false) end)
                    Parent:SetIcon('icon16/database.png')

                    local InfoActions, Parent = AdminActions:AddSubMenu( 'Информация о '..pPlayer:Nick(), function() RunConsoleCommand('sam', 'menu') scoreboard:ScoreboardToggle(false) end)
                    --print('Error: ---------- '..(pPlayer:GetRank() and pPlayer:GetRank() or 'NULLI'))
                    InfoActions:AddOption('Звание: '..pPlayer:GetRank(), function() SetClipboardText( pPlayer:GetRank() ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                    InfoActions:AddOption('Номер: '..pPlayer:GetNumber(), function() SetClipboardText( pPlayer:GetNumber() ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                    InfoActions:AddOption('Позывной: '..pPlayer:Nick1(), function() SetClipboardText( pPlayer:Nick1() ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                    InfoActions:AddOption('Рация включена: '..(pPlayer:GetNVar('radio_speaker') and 'Включена' or 'Выключена'), function() SetClipboardText( (pPlayer:GetNVar('radio_speaker') and 'Включена' or 'Выключена') ) surface.PlaySound('gmodadminsuite/success.ogg') end)
                    InfoActions:AddOption('Частота рации: '.. (pPlayer:GetNVar('radio_frequency') or 'Неизвестно'), function() SetClipboardText( pPlayer:GetNVar('radio_frequency') or 'Неизвестно' ) surface.PlaySound('gmodadminsuite/success.ogg') end)

                    Parent:SetIcon('icon16/disk_multiple.png')

                    AdminActions:AddOption('ТП к '..pPlayer:Nick(), function() RunConsoleCommand('ulx', 'goto', '$'..pPlayer:UserID()) end):SetIcon('icon16/world_go.png')
                    AdminActions:AddOption('ТП '..pPlayer:Nick()..' к себе', function() RunConsoleCommand('ulx', 'bring', '$'..pPlayer:UserID()) end):SetIcon('icon16/world_go.png')
                    AdminActions:AddOption('Кикнуть '..pPlayer:Nick(), function() LIB:DoStringRequest('Кик', 'Введите причину для кика игрока '..pPlayer:Nick1(), '', function(str) RunConsoleCommand('ulx', 'kickr', '$'..pPlayer:UserID(), str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Кикнуть!', 'Отмена') end):SetIcon('icon16/disconnect.png')

                    local BanActions, Parent = AdminActions:AddSubMenu( 'Забанить '..pPlayer:FullName(), function() RunConsoleCommand('sam', 'menu') scoreboard:ScoreboardToggle(false) end)
                    Parent:SetIcon('icon16/disconnect.png')

                    BanActions:AddOption('На 10 минут', function() LIB:DoStringRequest('Бан', 'Введите причину для бана игрока '..pPlayer:Nick1()..' на 10 минут.', '', function(str) RunConsoleCommand('ulx', 'banid', pPlayer:SteamID(), '10', str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Забанить!', 'Отмена') end):SetIcon('icon16/accept.png')
                    BanActions:AddOption('На 30 минут', function() LIB:DoStringRequest('Бан', 'Введите причину для бана игрока '..pPlayer:Nick1()..' на 30 минут.', '', function(str) RunConsoleCommand('ulx', 'banid', pPlayer:SteamID(), '30', str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Забанить!', 'Отмена') end):SetIcon('icon16/accept.png')
                    BanActions:AddOption('На 60 минут', function() LIB:DoStringRequest('Бан', 'Введите причину для бана игрока '..pPlayer:Nick1()..' на 60 минут.', '', function(str) RunConsoleCommand('ulx', 'banid', pPlayer:SteamID(), '60', str) surface.PlaySound('gmodadminsuite/success.ogg') end, nil, 'Забанить!', 'Отмена') end):SetIcon('icon16/accept.png')
                    BanActions:AddOption('Указать время', function()
                        NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent, 'Введите время бана для '..pPlayer:Nick()..' в минутах.', '', 'Далее!', function(BanL)
                            NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent, 'Введите причину для бана игрока '..pPlayer:Nick()..' на '..BanL..' минут(ы).', '', 'Забанить!',
                            function(BanR)
                                RunConsoleCommand('sam', 'banid', pPlayer:SteamID(), BanL, BanR)
                                surface.PlaySound('gmodadminsuite/success.ogg')
                            end, 'Отмена', nil)
                        end, 'Отмена', nil)
                    end)
                end

                local PropertiesOpen = Menu:AddOption('CMenu', function()
                    timer.Simple(.1, function() properties.OpenEntityMenu( pPlayer, LocalPlayer():GetEyeTrace() ) end)
                end):SetIcon('icon16/cog_go.png')
            Menu:Open()
        end)
    ActionButton:SetPos(0, 0)
    ActionButton:SetSize(PlayerPanel:GetWide(), PlayerPanel:GetTall())

    return PlayerPanel
end

function scoreboard:Line(nHeight, tColor)
    local line = TDLib('DPanel')
        :Stick(TOP)
        :ClearPaint()
        :Background(tColor or NextRP.Style.Theme.Accent)

    line:SetHeight(nHeight)

    return line
end

function scoreboard:AddCategory(icon, name, color)
    if not color then color = NextRP.Style.Theme.Accent end
    local Category = TDLib('DCollapsibleCategory', self.ScrollBase)
            :Stick(TOP)
            :ClearPaint()

    icon = icon or NextRP.Style.Materials.RPRoleIcon

    Category.Header:TDLib()
        :ClearPaint()
        :On('Paint', function(s, w, h)
            surface.SetDrawColor(40, 40, 40, 150)
            surface.DrawRect(0, 0, w, h)

            surface.SetMaterial(icon)
            surface.SetDrawColor(Category:GetExpanded() and Color(225, 225, 225) or Color(220, 221, 225, 150))

            surface.DrawTexturedRect(5, h *.5 - 16, 32, 32)

            local tx = draw.SimpleText(name or 'Категория без названия', 'font_sans_24', 32 + 10, h * .5 - 1, Category:GetExpanded() and NextRP.Style.Theme.HoveredText or NextRP.Style.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(Category:GetExpanded() and color or Color(225, 177, 44, 150))
            surface.DrawRect(32 + 10, h * .5 + 10, tx, 2)
        end)
        :Text('')

    Category.Header:SetTall(38)

    Category:DockMargin(0, 3, 0, 3)

    local contents = TDLib('DPanelList')
    contents:SetPadding(0)
    contents:SetSpacing(3)

    Category:SetContents(contents)

    return contents, Category
end

function scoreboard:ScoreboardToggle(bToggle)
    if bToggle then
        local scoreboardBlur = TDLib('DPanel')
            :Stick(FILL)
            :ClearPaint()
            :Blur()
            :FadeIn()

        local scoreboardBase = TDLib('DPanel')
            :ClearPaint()
            :Background(Color(40, 40, 40, 200))
            :FadeIn()

        local base = scoreboardBase
        scoreboard.Base = base
        scoreboard.Blur = scoreboardBlur

        base:MakePopup()
        base:SetSize(W()*.7, H()*.85)
        base:SetPos(W() - W()*.7 - 60)
        base:CenterVertical()

        base:Add(scoreboard:Line(5))

        local Line = base:Add(scoreboard:Line(5))
        Line:Stick(BOTTOM)

        local Info = TDLib('DPanel', base)
            :ClearPaint()
            :Stick(TOP)
            :On('Paint', function(s, w, h)
                surface.SetDrawColor(40, 40, 40, 150)
                surface.DrawRect(0, 0, w, h)

                draw.SimpleText('Звание', 'font_sans_21', 64 + 16 + 4 + 20, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                draw.SimpleText('Номер', 'font_sans_21', 64 + 16 + 4 + 56 + 70, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText('Имя', 'font_sans_21', 64 + 16 + 4 + 56 + 120 + 49 + 50, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                draw.SimpleText('Приписки', 'font_sans_21', w*.5, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                draw.SimpleText('Ранг', 'font_sans_21', w - 16 - 4 - 38 - 300,  h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText('Пинг', 'font_sans_21', w - 64 - 16 - 4 - 20, h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText('Убийств / Смертей', 'font_sans_21', w - 16 - 4 - 38 - 170,  h * .5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end)

        Info:DockMargin(0, 3, 0, 3)

        local close = TDLib('DButton', Info)
            :Text('', 'font_sans_16')
            :ClearPaint()
            :Stick(RIGHT)
            :Background(Color(40,40,40, 200))
            :FadeHover()
            :On('DoClick', function()
                scoreboard.Base:Remove()
                scoreboard.Blur:Remove()
                scoreboard.StuffBlock:Remove()
            end)

            close:SetSize(32,32)

        base:Add(scoreboard:Line(1))

        local scrollPanel = TDLib('DScrollPanel', base)
            :Stick(FILL, 5)

        scrollPanel:GetVBar():SetWide(0)
	    scrollPanel:GetVBar():Hide()

        self.ScrollBase = scrollPanel

        for k, v in NextRP.GetSortedCategories() do
            local shouldDelete = true

            local IMATERIALS = {
				[TYPE_GAR] = NextRP.Style.Materials.CloneIcon,
				[TYPE_JEDI] = NextRP.Style.Materials.JediIcon,
				[TYPE_ADMIN] = NextRP.Style.Materials.ServerStuffIcon,
				[TYPE_RPROLE] = NextRP.Style.Materials.RPRoleIcon,
			}

            local categ, realCateg = self:AddCategory(v.icon or IMATERIALS[v.type] or NextRP.Style.Materials.CloneIcon, v.name, v.color)

            for k, member in pairs(v.members) do
                if team.NumPlayers(member.index) <= 0 then continue end
                shouldDelete = false

                for kc, pl in ipairs(team.GetPlayers(member.index)) do
                    if pl and pl:GetNVar('is_load_char') then
                        if pl == nil or pl == NULL or !IsValid(pl) then continue end
                        categ:Add(scoreboard:Player(pl))
                    end
                end
            end

            if shouldDelete then realCateg:Remove() end
        end

        local stuffBlock = TDLib('DPanel')
            :ClearPaint()
            :Background(Color(40, 40, 40, 200))
            :FadeIn()

        scoreboard.StuffBlock = stuffBlock

        stuffBlock:SetSize(W()*.2, H()*.85)
        stuffBlock:SetPos(60)
        stuffBlock:CenterVertical()

        stuffBlock:Add(scoreboard:Line(5))

        local Line = stuffBlock:Add(scoreboard:Line(5))
        Line:Stick(BOTTOM)

        local logo = NextRP.Style.Materials.LogoWatermark

        local Header = TDLib('DPanel', stuffBlock)
            :Stick(TOP)
            :ClearPaint()
            :On('Paint', function(s, w, h)
                draw.SimpleText(NextRP.Config.FancyTitle, 'font_sans_26', 64 + 15, h * .5 - 9, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("Онлайн: "..#player.GetAll()..'/'..game.MaxPlayers(), 'font_sans_16', 64 + 15, h * .5 + 13, NextRP.Style.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                surface.SetMaterial(logo)
                surface.SetDrawColor(255, 255, 255, 255)

                surface.DrawTexturedRect(5, h*.5 - 32, 64, 64)
            end)

        Header:SetHeight(60)

        stuffBlock:Add(scoreboard:Line(3))

        local hh = vgui.Create('PawsUI.Panel', stuffBlock)
        hh:Stick(TOP)
            :On('Paint', function(s, w, h)
                draw.SimpleText('Администрация онлайн', 'font_sans_24', w * .5, h*.5, NextRP.Style.Theme.HoveredText, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end)

        hh:SetTall(32)

        local stuffScroller = TDLib('DScrollPanel', stuffBlock)
            :Stick(FILL, 5)
        --stuffScroller:Dock(FILL)
        stuffScroller:GetVBar():SetWide(0)
	    stuffScroller:GetVBar():Hide()


        for k, v in player.Iterator() do
            if v == nil or v == NULL or !IsValid(v) then continue end
            if v:IsAdmin() then

                local panel = stuffScroller:Add('PawsUI.Panel')
                panel:Stick(TOP)
                    :Background(NextRP.Style.Theme.Background)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText(v:Name(), 'font_sans_22', 55, h * .5 + 3, NextRP.Style.Theme.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                        if !istable(IsUnique(v)) then
                            draw.SimpleText(IsValid(v) and v:GetUserGroup() or 'None', 'font_sans_21', 55, h * .5 - 2, NextRP.Style.Theme.HightlightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        else
                            draw.SimpleText(IsUnique(v)[1], 'font_sans_21', 55, h * .5 - 2, IsUnique(v)[2] and HSVToColor(  ( CurTime() * 100 ) % 360, 1, 1 ) or NextRP.Style.Theme.HightlightText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        end
                    end)

                panel:DockMargin(2, 2, 2, 0)
                panel:SetTall(52)

                local avatar = vgui.Create('AvatarImage', panel)
                avatar:SetSize(48, 48)
                avatar:SetPlayer(v, 48)
                avatar:SetPos(2, 2)
            end
        end
        --[[timer.Simple(10, function()
            scoreboard.Base:Remove()
            scoreboard.Blur:Remove()
            scoreboard.StuffBlock:Remove()
        end)]]--
    else
        if IsValid(scoreboard.Base) then
            scoreboard.Base:TDLib():FadeOut()
            scoreboard.Blur:TDLib():FadeOut()
            scoreboard.StuffBlock:TDLib():FadeOut()

            timer.Simple(.1, function()
                scoreboard.Base:Remove()
                scoreboard.Blur:Remove()
                scoreboard.StuffBlock:Remove()
            end)
        end
    end
end

hook.Add('ScoreboardShow', 'Paws.Scoreboard.Show', function()
    scoreboard:ScoreboardToggle(true)
    --[[timer.Create('fade'..LocalPlayer():SteamID64(), 15, 1, function()
            scoreboard.Base:Remove()
            scoreboard.Blur:Remove()
            scoreboard.StuffBlock:Remove()
        end)]]--[[-------------------------------------------------------------------------
        Title
        ---------------------------------------------------------------------------]]               
    return false
end)

hook.Add('ScoreboardHide', 'Paws.Scoreboard.Show', function()
    scoreboard:ScoreboardToggle(false)
    --if timer.Exists('fade'..LocalPlayer():SteamID64()) then timer.Remove('fade'..LocalPlayer():SteamID64()) end
end)