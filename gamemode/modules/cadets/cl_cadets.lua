local textWrap = NextRP.Utils.textWrap

function NextRP.Cadets:OpenUI()
    self.frame = vgui.Create('PawsUI.Frame')
    local frame = self.frame
    frame:SetTitle('Прохождение теста')
    frame:SetSize(960, 720)
    frame:MakePopup() 
    frame:Center()
    frame:ShowSettingsButton(false)

    self.content = vgui.Create('PawsUI.Panel', frame)
    self.content:Dock(FILL)

    self.content
        :TDLib()

    local info = vgui.Create('PawsUI.Panel', self.content)
        :Stick(TOP, 1)

    info:SetTall(175)

    local text = 'Мы генномодифицированые клоны, выращенные на планете Камино. Созданые по образу наемника Джанго Фетта. Его ген был взят за основу нашего генома. Аббревиатура "ВАР" означает: Великая Армия Республики. Мы находимся на одной из баз планеты Каминар. Мы служим Великой Армии Республики. Лидером Республики является - Верховный Канцлер Шив Палпатин. Нашей целью является защита базы и помощь ближайшим силам союзников. Мы воюем против САД - Сепаратистской Армии Дроидов,под руководством КНС - Конфедерации Независимых Систем. Лидером КНС, является Граф Дуку, а САД - Генерал Гривус.'
    info:On('Paint', function(s, w, h)
        draw.DrawText(textWrap(text, 'PawsUI.Text.Normal', w - 20), 'font_sans_21', s:GetWide() * 0.5, 5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.DrawText('Полезные ссылки:', 'font_sans_26', s:GetWide() * 0.5, h - 27, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)

    local ustav = vgui.Create('DButton', self.content)
        ustav:SetTall(35)
        ustav:TDLib()
            :Stick(TOP, 1)
            :ClearPaint()
            --:Background(NextRP.Style.Theme.Background)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Blue)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :Text('Устав', 'PawsUI.Text.Normal', NextRP.Style.Theme.Text)
            :On('DoClick', function()
                gui.OpenURL('https://sites.google.com/view/chronicleofhopev2/основная-информация')
            end)
    
    local discord = vgui.Create('DButton', self.content)
        discord:SetTall(35)
        discord:TDLib()
            :Stick(TOP, 1)
            :ClearPaint()
            --:Background(NextRP.Style.Theme.Background)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Blue)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :Text('Дискорд', 'PawsUI.Text.Normal', NextRP.Style.Theme.Text)
            :On('DoClick', function()
                gui.OpenURL('https://discord.gg/H7MGtTNEUH')
            end)

    local rules = vgui.Create('DButton', self.content)
        rules:SetTall(35)
        rules:TDLib()
            :Stick(TOP, 1)
            :ClearPaint()
            --:Background(NextRP.Style.Theme.Background)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Blue)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :Text('Правила сервера', 'PawsUI.Text.Normal', NextRP.Style.Theme.Text)
            :On('DoClick', function()
                --gui.OpenURL('https://docs.google.com/document/d/1ePuzNyuJq19eYoEqhtBDsU486c-DJPevU1e9r6-ueg8/edit#heading=h.fgx3k797cb7t')
                gui.OpenURL('https://docs.google.com/document/d/1gNJwDOeJ7dJ-jMiTjHcO-Ea8JFRTpDjOIQMXi7riDmo/edit?tab=t.0')
            end)

    local startTest = vgui.Create('DButton', self.content)
        startTest:SetTall(35)
        startTest:TDLib()
            :Stick(TOP, 1)
            :ClearPaint()
            --:Background(NextRP.Style.Theme.Background)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Accent)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :Text('Начать тест', 'PawsUI.Text.Normal', NextRP.Style.Theme.Text)
            :On('DoClick', function()
                self.content:Clear()
                -- frame:ShowCloseButton(false)

                NextRP.Cadets:StartTest()
            end)

        startTest:DockMargin(1, 15, 1, 0)
end


function NextRP.Cadets:StartTest()
    local curQuestion = 1
    self:Question(curQuestion)
    self.Answers = {}
end

function NextRP.Cadets:Question(number)
    if number > 10 then
        local st = true
        for i = 1, 10 do
            if self.Answers[i] == true then continue end
            st = false
        end
        self.content:Clear()       
        if st then
            local title = vgui.Create('PawsUI.Panel', self.content)
                :Stick(TOP, 1)
                :Text('Тест сдан! Перейдите в дискорд 212-го!', 'PawsUI.Text.Large', NextRP.Style.Theme.Green)

            title:SetTall(150)

            local ctdisc = vgui.Create('DButton', self.content)
            ctdisc:SetTall(35)
            ctdisc:TDLib()
                :Stick(TOP, 1)
                :ClearPaint()
                --:Background(NextRP.Style.Theme.Background)
                :Background(NextRP.Style.Theme.Background)
                :FadeHover(NextRP.Style.Theme.Blue)
                :CircleClick(NextRP.Style.Theme.AlphaWhite)
                :Text('Дискорд 104-го', 'PawsUI.Text.Normal', NextRP.Style.Theme.Text)
                :On('DoClick', function()
                    gui.OpenURL('https://discord.gg/arkVfWajf')
                end)

            local cfg = NextRP.Cadets.Config.Jobs

            for k, v in pairs(cfg) do
                local jobs = ''
                for kk, vv in pairs(v[2]) do
                    jobs = jobs .. NextRP.GetJobByID(vv).category .. ' '
                end
                local job = vgui.Create('DButton', self.content)
                job:SetTall(55)
                job:TDLib()
                    :Stick(TOP, 1)
                    :ClearPaint()
                    --:Background(NextRP.Style.Theme.Background)
                    :Background(NextRP.Style.Theme.Background)
                    :FadeHover(NextRP.Style.Theme.Accent)
                    :CircleClick(NextRP.Style.Theme.AlphaWhite)
                    :Text('', 'PawsUI.Text.Normal', NextRP.Style.Theme.Text)
                    :On('DoClick', function()
                        self.frame:Remove()

                        netstream.Start('NextRP::TestComplete', self.Answers, k)
                    end)
                    :On('Paint', function(s, w, h)
                        draw.SimpleText(v[1], 'PawsUI.Text.Normal', w * .5 , 10, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER)
                        draw.SimpleText(jobs, 'PawsUI.Text.Small', w * .5 , h - 25, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER)
                    end)
            end
        else
            local title = vgui.Create('PawsUI.Panel', self.content)
                :Stick(TOP, 1)
                :Text('Тест не сдан! Попробуйте ещё раз!', 'PawsUI.Text.Large', NextRP.Style.Theme.LightRed)
            
            title:SetTall(150)

            local startTest = vgui.Create('DButton', self.content)
            startTest:SetTall(35)
            startTest:TDLib()
                :Stick(TOP, 1)
                :ClearPaint()
                --:Background(NextRP.Style.Theme.Background)
                :Background(NextRP.Style.Theme.Background)
                :FadeHover(NextRP.Style.Theme.Accent)
                :CircleClick(NextRP.Style.Theme.AlphaWhite)
                :Text('Попробывать ещё раз', 'PawsUI.Text.Normal', NextRP.Style.Theme.Text)
                :On('DoClick', function()
                    self.content:Clear()
                    NextRP.Cadets:StartTest()
                end)

            startTest:DockMargin(1, 15, 1, 0)

        end

        return     
    end

    local cfg = NextRP.Cadets.Config.Questions
    local title = vgui.Create('PawsUI.Panel', self.content)
        -- :Text(textWrap(cfg[number][1], 'PawsUI.Text.Large', 900), 'PawsUI.Text.Large')
        :Stick(TOP, 1)
        :On('Paint', function(s, w, h)
            -- draw.SimpleText('Вопрос '..number..'/10', 'PawsUI.Text.Small', 5, 5, NextRP.Style.Theme.Text)
            draw.DrawText(textWrap(cfg[number][1], 'PawsUI.Text.Large', 900), 'PawsUI.Text.Large', w*.5, h*.5, NextRP.Style.Theme.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.DrawText('Вопрос '..number..'/10', 'PawsUI.Text.Small', 5, 5, NextRP.Style.Theme.Text)
        end)

    title:SetTall(150)

    for k, v in pairs(cfg[number][2]) do
        local answer = vgui.Create('DButton', self.content)
        answer:SetTall(35)
        answer:TDLib()
            :Stick(TOP, 1)
            :ClearPaint()
            --:Background(NextRP.Style.Theme.Background)
            :Background(NextRP.Style.Theme.Background)
            :FadeHover(NextRP.Style.Theme.Blue)
            :CircleClick(NextRP.Style.Theme.AlphaWhite)
            :Text(v[1] .. (v[2] and '  ' or ''), 'PawsUI.Text.Small', NextRP.Style.Theme.Text)
            :On('DoClick', function()
                self.content:Clear()
                self.Answers[number] = v[2]
                NextRP.Cadets:Question(number + 1)
            end)
    end
end

netstream.Hook('NextRP::OpenTest', function()
    NextRP.Cadets:OpenUI()
end)