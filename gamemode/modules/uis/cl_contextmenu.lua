ContextMenuPanel = ContextMenuPanel or nil
ContextMenuPanelScreenPanel = ContextMenuPanelScreenPanel or nil

local function Line(nHeight, tColor)
    local line = TDLib('DPanel')
        :Stick(TOP)
        :ClearPaint()
        :Background(tColor or NextRP.Style.Theme.Accent)

    line:SetHeight(nHeight)

    return line
end

local function ContextMenu(bToggle)
    local CONFIG = {
        LEFTSide = {
            [1] = {
                '3-е лицо',
                function()
                    return true
                end,
                {
                    [1] = {
                        'Настройки',
                        function(pPlayer) RunConsoleCommand('simple_thirdperson_menu') end
                    },
                    [2] = {
                        'Вкл/Выкл',
                        function(pPlayer) RunConsoleCommand('simple_thirdperson_enable_toggle') end
                    }
                }
            },
            [2] = {
                'Система',
                function()
                    return true
                end,
                {
                    [1] = {
                        'Точки интереса',
                        function()
                            NextRP.ControlPoints:OpenCPList()
                        end
                    },
                    [2] = {
                        'Ссылки',
                        function()
                            chat.AddText(NextRP.Config.Link.VK..'\n'..NextRP.Config.Link.Discord..'\n'..NextRP.Config.Link.SteamCollection)
                        end
                    },
                    [3] = {
                        'Настройки интерфейса',
                        function()
                            NextRPSetOpenUI()
                        end
                    },
                    [4] = {
                        'Таланты',
                        function()
                            RunConsoleCommand('say', '/talents')
                        end
                    }
                }
            },
            [3] = {
                'Управление',
                function(pPlayer)
                    local CONTROL
                    if isbool(pPlayer:getJobTable().control) then CONTROL = 'CONTROL_GAR' else CONTROL = pPlayer:getJobTable().control end
                    if NextRP.Config.Codes.Permissions[CONTROL] then
                        local perms = NextRP.Config.Codes.Permissions[CONTROL][pPlayer:Team()]
                        if istable(perms) then
                            if perms[pPlayer:GetNWString('nrp_rank')] then
                                return true
                            end
                            return false
                        end

                        if isbool(perms) and perms then
                            return true
                        end
                    end

                    return false
                end,
                {
                    [1] = {
                        'Система кодов',
                        function()
                            NextRP.Codes:OpenUI()
                        end
                    }
                }
            },
            [4] = {
                'LVS',
                function()
                    return true
                end,
                {
                    [1] = {
                        'Настройки',
                        function(pPlayer) RunConsoleCommand('lvs_openmenu') end
                    }
                }
            },
            [5] = {
                'Администратор',
                function(pPlayer)
                    return pPlayer:IsAdmin()
                end,
                {
                    [1] = {
                        'Управление персонажами',
                        function()
                            NextRP.Ranks:OpenAdminUI()
                        end
                    },
                    [2] = {
                        'GTS',
                        function(pPlayer) RunConsoleCommand('say', '!gts')
                        end
                    },
                    [3] = {
                        'Noclip',
                        function(pPlayer) RunConsoleCommand('say', '!noclip')
                        end
                    },
                    [4] = {
                        'Меню',
                        function(pPlayer) RunConsoleCommand('say', '!menu')
                        end
                    },
                    [5] = {
                        'Система предупреждений',
                        function(pPlayer) RunConsoleCommand('say', '!warn')
                        end
                    },
                    [6] = {
                        'God',
                        function(pPlayer) RunConsoleCommand('say', '!god')
                        end
                    },
                    [7] = {
                        'Spectate',
                        function(pPlayer) RunConsoleCommand('say', '!spectate')
                        end
                    }
                }
            }
        },
        RIGHTSide = {
            [1] = {
                'Действия',
                function()
                    return true
                end,
                {
                    [1] = {
                        'Воинское приветствие',
                        function(pPlayer) RunConsoleCommand('say', '/salute') end
                    },
                    [2] = {
                        'Сигнал "Стоп"',
                        function(pPlayer) RunConsoleCommand('say', '/halt') end
                    },
                    [3] = {
                        'Сигнал "Вперед"',
                        function(pPlayer) RunConsoleCommand('say', '/forward') end
                    },
                    [4] = {
                        'Сигнал "Сгруппироваться"',
                        function(pPlayer) RunConsoleCommand('say', '/group') end
                    },
                    [5] = {
                        'Указать',
                        function(pPlayer) RunConsoleCommand('say', '/point') end
                    },
                    [6] = {
                        'Снять шлем',
                        function(pPlayer) RunConsoleCommand('say', '/helmet') end
                    },
                    [7] = {
                        'Поднять руки',
                        function(pPlayer) RunConsoleCommand('anim', 'surrunder') end
                    },
                    [8] = {
                        'Руки перед собой',
                        function(pPlayer) RunConsoleCommand('anim', 'arms_infront') end
                    },
                    [9] = {
                        'Руки за спину',
                        function(pPlayer) RunConsoleCommand('anim', 'arms_back') end
                    },
                    [10] = {
                        'Поклониться',
                        function(pPlayer) RunConsoleCommand('say', '/bow') end
                    },
                    [11] = { 'Документы',
                        function(pPlayer)
                            RunConsoleCommand('say', '/docs')
                        end
                    },
                }
            },
            --[[[2] = {
                'Таймер',
                    function(pPlayer)
                    end,
                {
                    [1] = {
                        UtimePanel and UtimePanel:IsSelected() and 'Закрыть меню' or 'Открыть меню',
                        function(pPlayer)
                            if UtimePanel and UtimePanel:IsSelected() then
                                UtimePanel:SetSelected(false)
                                UtimePanel:Remove()
                            else
                                UtimePanel = TDLib('DPanel')
                                    :Stick(TOP)
                                    :ClearPaint()

                                UtimePanel:SetSize(1, 150)
                                UtimePanel:DockPadding(9, 100, 0, 0)


                                local UTimeInfo = TDLib('DPanel', UtimePanel)
                                    :Stick(FILL)
                                    :ClearPaint()
                                    :On('Think', function(s)
                                        s:ClearPaint()
                                        s:DualText('Сессия: '..Utime.timeToStr(pPlayer:GetUTimeSessionTime()), 'font_sans_21', PawsUI.Theme.Gray or NextRP.Style.Theme.Accent, 'Всего: '..Utime.timeToStr(pPlayer:GetUTimeTotalTime()), 'font_sans_21', PawsUI.Theme.Gray, TEXT_ALIGN_LEFT)
                                    end)

                                    UtimePanel:SetSelectable(true)
                                    UtimePanel:SetSelected(true)
                                return UtimePanel
                            end
                        end
                    },
                }
            },]]--
            [2] = {
                'WIP',
                    function(pPlayer)
                        return pPlayer:IsAdmin()
                    end,
                {
                    [1] = {
                        'Дропнуть кристалл(ЕЩЕ В РАБОТЕ)',
                        function(pPlayer)
                            RunConsoleCommand('say', '/dropcrys')
                        end
                    },
                    --[[[2] = {
                        'TEST1',
                        function(pPlayer)
                            NextRP.Friends:MainFrame()
                        end
                    },
                    [3] = {
                        'TEST2',
                        function(pPlayer)
                            RunConsoleCommand('say', '/test1')
                        end
                    },]]--
                }
            }
        }
    }
    if !bToggle and IsValid(ContextMenuPanel) then
        ContextMenuPanel:Remove()
        gui.EnableScreenClicker(false)
        return
    end

    local wep = LocalPlayer():GetActiveWeapon()
    if wep.InspectPos then
        if IsValid(ContextMenuPanel) then ContextMenuPanel:Remove() end
        return
    end

    gui.EnableScreenClicker(true)
    ContextMenuPanelOld = ContextMenuPanel
    ContextMenuPanel = TDLib('DPanel')
        :Stick(RIGHT)
        :ClearPaint()
        :Background(Color(40, 40, 40, 200))
        :Blur(.1)
        :On('Paint', function(s, w, h)
            surface.SetDrawColor(NextRP.Style.Theme.Accent)

            surface.DrawRect(0, 0, w, 5)
            surface.DrawRect(0, h-5, w, 5)
        end)


    ContextMenuPanel:DockMargin(0, 10, 5, 10)

    ContextMenuPanel:SetWide(400)
    ContextMenuPanel:SetWorldClicker(true)

    ContextMenuPanelScreenPanel = ContextMenuPanelScreenPanel or TDLib('DPanel')
        :ClearPaint()
        :Stick(FILL)
        :On('OnMousePressed', function( p, code )
            hook.Run( 'GUIMousePressed', code, gui.ScreenToVector( gui.MousePos() ) )
        end)
        :On('OnMouseReleased', function( p, code )
            hook.Run( 'GUIMouseReleased', code, gui.ScreenToVector( gui.MousePos() ) )
        end)

    ContextMenuPanelScreenPanel:SetVisible(true)
    ContextMenuPanelScreenPanel:SetWorldClicker(true)

    function ContextMenuPanelScreenPanel:Close()
        self:SetVisible(false)
    end

    g_ContextMenu = ContextMenuPanelScreenPanel

    if IsValid(ContextMenuPanelOld) then ContextMenuPanelOld:Remove() end

    local headerBase = TDLib('DPanel', ContextMenuPanel)
        :ClearPaint()
        :Stick(TOP)
        :On('Paint', function(s, w, h)
            surface.SetDrawColor(NextRP.Style.Theme.Accent)
            surface.DrawRect(0, h-1, w, 1)
        end)

    headerBase:SetTall(72)
    headerBase:DockMargin(0, 5, 0, 0)
    local headerAvatar = TDLib('DPanel', headerBase)
        :ClearPaint()
        :CircleAvatar()
        :Stick(RIGHT, 4)
    headerAvatar:SetPlayer(LocalPlayer(), 64)

    local headerText = TDLib('DPanel', headerBase)
        :ClearPaint()
        :Stick(FILL, 3)
        :DualText(
            LocalPlayer():Name(),
            'font_sans_26',
            color_white,
            LocalPlayer():GetRank(),
            'font_sans_21',
            color_white,
            TEXT_ALIGN_RIGHT
        )
    local leftSide = TDLib('DPanel', ContextMenuPanel)
        :Stick(LEFT)
        :DivWide(2)
        :ClearPaint()

    for k, v in ipairs(CONFIG.LEFTSide) do
        if isfunction(v[2]) and (v[2](LocalPlayer()) == false) then
            continue
        end

        surface.SetFont('font_sans_21')
        local tw = surface.GetTextSize(v[1])

        local leftSideHeader = TDLib('DPanel', leftSide)
            :Stick(TOP)
            :ClearPaint()
            :Text(v[1], 'font_sans_21')
            :On('Paint', function(s, w, h)
                    surface.SetDrawColor(NextRP.Style.Theme.Accent)
                    surface.DrawRect(w*.5-tw*.5, h-5, tw, 2)
                end)

        leftSideHeader:SetTall(25)

        for k, v in pairs(v[3]) do
            if v[3] and v[3](LocalPlayer()) == false then
                continue
            end

            local leftButton = TDLib('DButton', leftSide)
                :Stick(TOP, 1)
                :ClearPaint()
                :Text(v[1], 'font_sans_16')
                :Background(Color(40, 40, 40, 150))
                :FadeHover()
                :CircleClick()
                :BarHover(NextRP.Style.Theme.Accent)
                :On('DoClick', function() v[2](LocalPlayer()) end)

            leftButton:SetTall(25)
        end
    end

    local rightSide = TDLib('DPanel', ContextMenuPanel)
        :Stick(RIGHT)
        :DivWide(2)
        :ClearPaint()

    for k, v in ipairs(CONFIG.RIGHTSide) do
        if isfunction(v[2]) and (v[2](LocalPlayer()) == false) then
            continue
        end

        surface.SetFont('font_sans_21')
        local tw = surface.GetTextSize(v[1])

        local rightSideHeader = TDLib('DPanel', rightSide)
            :Stick(TOP)
            :ClearPaint()
            :Text(v[1], 'font_sans_21')
            :On('Paint', function(s, w, h)
                    surface.SetDrawColor(NextRP.Style.Theme.Accent)
                    surface.DrawRect(w*.5-tw*.5, h-5, tw, 2)
                end)

        rightSideHeader:SetTall(25)

        for k, v in pairs(v[3]) do
            if v[3] and v[3](LocalPlayer()) == false then
                continue
            end

            local rightButton = TDLib('DButton', rightSide)
                :Stick(TOP, 1)
                :ClearPaint()
                :Text(v[1], 'font_sans_16')
                :Background(Color(40, 40, 40, 150))
                :FadeHover()
                :CircleClick()
                :BarHover(NextRP.Style.Theme.Accent)
                :On('DoClick', function() v[2](LocalPlayer()) end)

            rightButton:SetTall(25)
        end
    end

    local tbut = TDLib('DButton', ContextMenuPanel)
            :Stick(BOTTOM, 1)
            :ClearPaint()
            :Text('TEST1', 'font_sans_16')
            :Background(Color(40, 40, 40, 150))
            :FadeHover()
            :CircleClick()
            :BarHover(NextRP.Style.Theme.Accent)
            :On('DoClick', function() LocalPlayer():RunConsoleCommand('say', '/test1') end)

        tbut:SetTall(25)

    local tbut2 = TDLib('DButton', ContextMenuPanel)
            :Stick(BOTTOM, 1)
            :ClearPaint()
            :Text('TEST2', 'font_sans_16')
            :Background(Color(40, 40, 40, 150))
            :FadeHover()
            :CircleClick()
            :BarHover(NextRP.Style.Theme.Accent)
            :On('DoClick', function() NextRP.Friends:MainFrame() end)

        tbut2:SetTall(25)
end

hook.Add('OnContextMenuOpen', 'CustomContextMenu', function()
    ContextMenu(true)
    return true
end)

hook.Add('OnContextMenuClose', 'CustomContextMenu', function()
    ContextMenu(false)
end)