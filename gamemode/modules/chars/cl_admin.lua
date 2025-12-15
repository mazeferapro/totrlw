function NextRP.Ranks:OpenAdminUI()
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Управление персонажами')
    frame:SetSize(960, 720)
    frame:MakePopup() 
    frame:Center()
    frame:ShowSettingsButton(false)

    local sidebar = vgui.Create('PawsUI.Sideblock', frame)
    
    local button1 = vgui.Create('PawsUI.Button', sidebar) 
        button1:SetTall(30)
        button1:SetLabel('') 
        button1
            :Stick(TOP, 1)
            --:Background(NextRP.Style.Theme.Background)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Blue)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :On('Paint', function(s, w, h)
                draw.SimpleText('Поиск по steamid', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end)
            :On('DoClick', function()
                NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
                'Введите SteamID для поиска по персонажам.\nSteamID32 / SteamID64\n\nЭто выведит список персонажей игрока\n\nОтвет на запрос информации с БД может занимать до 30 секунд.',
                '',
                'Поиск', function(sValue)
                    netstream.Start('NextRP::FindChar', 'steamid', sValue)
                end,
                'Отмена', nil)
            end)

    local button2 = vgui.Create('PawsUI.Button', sidebar) 
        button2:SetTall(30)
        button2:SetLabel('')
        button2
            :Stick(TOP, 1)
            --:Background(NextRP.Style.Theme.Background) 
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Blue)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :On('Paint', function(s, w, h)
                draw.SimpleText('Поиск по номеру', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end)
            :On('DoClick', function()
                NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
                'Введите номер для поиска по персонажам.\n\nЭто выведит список персонажей с указаным номером.\nОдинаковый номер персонажей условно невозможен, но администрация может устанавливать одинаковые номера для двух разныхт персонажей.\n\nОтвет на запрос информации с БД может занимать до 30 секунд.',
                '',
                'Поиск', function(sValue)
                    netstream.Start('NextRP::FindChar', 'number', sValue)
                end,
                'Отмена', nil)
            end)

    local button3 = vgui.Create('PawsUI.Button', sidebar) 
        button3:SetTall(30)
        button3:SetLabel('')
        button3
            :Stick(TOP, 1)
            --:Background(NextRP.Style.Theme.Background) 
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Blue)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :On('Paint', function(s, w, h)
                draw.SimpleText('Поиск по имени', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end)
            :On('DoClick', function()
                NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
                'Введите имя для поиска по персонажам.\n\nЭто выведит список персонажей с указаным именем.\n\nОтвет может включать несколько персонажей, которые имеют в своём имени запрос.\n\nОтвет на запрос информации с БД может занимать до 30 секунд.',
                '',
                'Поиск', function(sValue)
                    netstream.Start('NextRP::FindChar', 'name', sValue)
                end,
                'Отмена', nil)
            end) 

    self.content = vgui.Create('PawsUI.ScrollPanel', frame)
    self.content:Dock(FILL)

    self.content
        :TDLib()
        :Text('Используйте поиск...', 'font_sans_35')
end

netstream.Hook('NextRP::CharAdminRespond', function(sStatus, Data)
    if not IsValid(NextRP.Ranks.content) then return end
    
    if sStatus == 'fail' then
        NextRP.Ranks.content:Clear()
        NextRP.Ranks.content:ClearPaint():Text('Ошибка: '..Data, 'font_sans_35')
    elseif sStatus == 'hit' then
        NextRP.Ranks.content:ClearPaint()
        NextRP.Ranks.content:Clear()

        for k, v in pairs(Data) do 
            local spec = istable(v.flag) and v.flag or util.JSONToTable(v.flag)

            local jt = NextRP.GetJobByID(v.team_id)
            if jt == nil then return end

            local final = 'Без специализации'
            for kk, vv in pairs(spec) do
                if not istable(final) then final = {} end
                final[#final + 1] = jt.flags[kk].id
            end

            if istable(final) then
                final = table.concat(final, ', ')
            end

            local pnl = NextRP.Ranks.content:Add('PawsUI.Panel')
            pnl:Stick(TOP)
                :Background(NextRP.Style.Theme.Background)
                :On('Paint', function(s, w, h) 
                    draw.SimpleText(v.rank .. ' ' .. v.rpid .. ' ' .. v.character_nickname, 'font_sans_26', 5, 2)
                    draw.SimpleText(jt.name, 'font_sans_21', 5, h * .5, nil, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(final, 'font_sans_21', 5, 40)
                end)
 
            pnl:DockMargin(0, 2, 5, 0)
            pnl:SetTall(65)

            -- Удаления
            local button1 = vgui.Create('PawsUI.Button', pnl) 
                button1:SetLabel('')
                button1
                    :Background(NextRP.Style.Theme.Background)
                    :FadeHover(NextRP.Style.Theme.Red)
                    :CircleClick(NextRP.Style.Theme.AlphaWhite)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText('Удалить', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end):On('DoClick', function()
                        NextRP:Querry(QUERY_MAT_WARNING,
                            NextRP.Style.Theme.Red,
                            'Вы собираетесь удалить этого персонажа!\nПродолжить?',
                            { 
                                {
                                    Text = 'Да',
                                    Click = function(frame)
                                        netstream.Start('NextRP::AdminDeleteChar', v.character_id)
                                        pnl:Remove()
                                    end
                                },
                                {
                                    Text = 'Нет',
                                    Click = function(frame)
                                        
                                    end
                                }
                            }
                        )
                    end)
            button1:SetPos(pnl:GetWide() - 85, 5)
            button1:SetSize(80, 55)

            -- Номер
            local button2 = vgui.Create('PawsUI.Button', pnl) 
                button2:SetLabel('')
                button2
                    :Background(NextRP.Style.Theme.Background)
                    :FadeHover(NextRP.Style.Theme.Blue)
                    :CircleClick(NextRP.Style.Theme.AlphaWhite)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText('Номер', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end)
                    :On('DoClick', function()
                        NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
                        'Введите номер для этого персонажа.',
                        '',
                        'Установить', function(sValue)
                            netstream.Start('NextRP::AdminEditChar', v.character_id, 'number', sValue )
                            v.rpid = sValue
                        end,
                        'Отмена', nil)
                    end)

            button2:SetPos(pnl:GetWide() - 85 * 4, 5)
            button2:SetSize(80, 25) 

            -- Имя
            local button3 = vgui.Create('PawsUI.Button', pnl) 
                button3:SetLabel('')
                button3
                    :Background(NextRP.Style.Theme.Background)
                    :FadeHover(NextRP.Style.Theme.Blue)
                    :CircleClick(NextRP.Style.Theme.AlphaWhite)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText('Имя', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end)
                    :On('DoClick', function()
                        NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
                        'Введите имя для этого персонажа.',
                        '',
                        'Установить', function(sValue)
                            netstream.Start('NextRP::AdminEditChar', v.character_id, 'name', sValue )
                            v.character_nickname = sValue
                        end,
                        'Отмена', nil)
                    end)

            button3:SetPos(pnl:GetWide() - 85 * 4, 35)
            button3:SetSize(80, 25)

            -- Звание
            local button4 = vgui.Create('PawsUI.Button', pnl) 
                button4:SetLabel('')
                button4 
                    :Background(NextRP.Style.Theme.Background)
                    :FadeHover(NextRP.Style.Theme.Blue)
                    :CircleClick(NextRP.Style.Theme.AlphaWhite)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText('Звание', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end)
                    :On('DoClick', function()
                        local m = vgui.Create('Paws.Menu')
                        for kk, vv in SortedPairsByMemberValue(jt.ranks, 'sortOrder') do
                            m:AddOption(kk .. ' / ' .. vv.fullRank, function()
                                netstream.Start('NextRP::AdminEditChar', v.character_id, 'rank', kk )
                                v.rank = kk
                            end)
                        end
                        m:SetPos(gui.MousePos())
                        m:Open()
                    end)

            button4:SetPos(pnl:GetWide() - 85 * 3, 5)
            button4:SetSize(80, 25)

            -- Приписки
            local button5 = vgui.Create('PawsUI.Button', pnl) 
                button5:SetLabel('')
                button5
                    :Background(NextRP.Style.Theme.Background)
                    :FadeHover(NextRP.Style.Theme.Blue)
                    :CircleClick(NextRP.Style.Theme.AlphaWhite)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText('Приписки', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end)
                    :On('DoClick', function()
                        local m = vgui.Create('Paws.Menu')

                        local pM = m:AddSubMenu('Добавить')
                        local tM = m:AddSubMenu('Убрать')

                        local allFlags = jt.flags
                        local activeFlags = spec

                        local addFlags = {}

                        for k, v in pairs(allFlags) do
                            if activeFlags[k] then continue end
                            addFlags[k] = true
                        end
                        
                        for k, v in pairs(addFlags) do
                            pM:AddOption(allFlags[k].id, function()
                                
                            end)
                        end

                        for k, v in pairs(activeFlags) do
                            tM:AddOption(allFlags[k].id, function()
                                
                            end)
                        end

                        m:SetPos(gui.MousePos())
                        m:Open()
                    end)

            button5:SetPos(pnl:GetWide() - 85 * 3, 35)
            button5:SetSize(80, 25)

            -- Профа
            local button6 = vgui.Create('PawsUI.Button', pnl) 
                button6:SetLabel('')
                button6
                    :Background(NextRP.Style.Theme.Background)
                    :FadeHover(NextRP.Style.Theme.Blue)
                    :CircleClick(NextRP.Style.Theme.AlphaWhite)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText('Профа', 'font_sans_26', w * .5, h * .5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end)
                    :On('DoClick', function()
                        local m = vgui.Create('Paws.Menu')

                        for kk, vv in NextRP.GetSortedCategories() do
                            local categpM = m:AddSubMenu(vv.name)

                            for kkk, job in ipairs(vv.members) do
                                categpM:AddOption(job.name, function()
                                    netstream.Start('NextRP::AdminEditChar', v.character_id, 'job', job.index )
                                    jt = job
                                end)
                            end
                        end

                        m:SetPos(gui.MousePos())
                        m:Open()
                    end)

            button6:SetPos(pnl:GetWide() - 85 * 2, pnl:GetTall() * .5 - 25 * .5)
            button6:SetSize(80, 25) 
        end
    end
end)