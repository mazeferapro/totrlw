--[[NextRP.Teleports = NextRP.Teleports or {}

function NextRP.Teleports:OpenAdminMenu(a, b)
    if not LocalPlayer():IsSuperAdmin() then return end
    print(b)
    if not isvector(a) or not isvector(b) then
        chat.AddText('Что-то пошло не так. Свяжитесь с разработчиком. Ошибка: ', Color(255, 142, 50), 'No Vectors Set')
        return 
    end

    local frame = vgui.Create('DFrame')
        frame:SetSize(350, 205)
        frame:MakePopup()
        frame:Center()
        frame:SetTitle('Настройка телепорта')

    local id = vgui.Create('DTextEntry', frame)
        id:SetPlaceholderText('ID планеты *')
        id:TDLib()
            :Stick(TOP, 3)

    local name = vgui.Create('DTextEntry', frame)
        name:SetPlaceholderText('Название планеты *')
        name:TDLib()
            :Stick(TOP, 3)

    local iconOrModel = vgui.Create('DTextEntry', frame)
        iconOrModel:SetPlaceholderText('Путь к модели или иконке')
        iconOrModel:TDLib()
            :Stick(TOP, 3)

    local global = vgui.Create('DCheckBoxLabel', frame)
        global:SetText('Глобально? (будет создано на всех картах, зачем?)')
        global:TDLib()
            :Stick(TOP, 3)

    local temp = vgui.Create('DCheckBoxLabel', frame)
        temp:SetText('Временно? (будет удалено после рестарта сервера)')
        temp:TDLib()
            :Stick(TOP, 3)

    local helpText = vgui.Create('DLabel', frame)
        helpText:SetText('Пункты отмеченные "*" обязательны к заполнению!')
        helpText:TDLib()
            :Stick(TOP, 3)

    local submit = vgui.Create('DButton', frame)
        submit:SetText('Подтвердить')
        submit:TDLib()
            :Stick(TOP, 3)

    function submit:DoClick()
        if id:GetValue() == '' or not id:GetValue() then
            chat.AddText(Color(255, 88, 77), 'Введите ID планеты! ', color_white, 'Да-да, это обязательно!')
            return 
        end

        if name:GetValue() == '' or not name:GetValue() then
            chat.AddText(Color(255, 88, 77), 'Введите название планеты! ', color_white, 'Да-да, это обязательно!')
            return 
        end

        local isGlobal = global:GetChecked()
        local isTemp = temp:GetChecked()
        local idValue = id:GetValue()
        local nameValue = name:GetValue()

        if isGlobal then
            NextRP.Teleports = NextRP.Teleports or {}
            NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}
            NextRP.Teleports.Brushes.Global = NextRP.Teleports.Brushes.Global or {}

            NextRP.Teleports.Brushes.Global[idValue] = {
                name = nameValue,
                id = idValue,
                boundA = a,
                boundB = b
            }
        else
            local map = game.GetMap()

            NextRP.Teleports = NextRP.Teleports or {}
            NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}
            NextRP.Teleports.Brushes[map] = NextRP.Teleports.Brushes[map] or {}
            
            NextRP.Teleports.Brushes[map][idValue] = {
                name = nameValue,
                id = idValue,
                boundA = a,
                boundB = b
            }
        end

        netstream.Start('NextRP.Teleports.Create', isGlobal, isTemp, idValue, nameValue, a, b)
        chat.AddText(Color(0, 255, 98), 'Готово! ', color_white, 'Планета добавлена в конфиг!')
    end
end

function NextRP.Teleports:OpenConfigMenu()
    if IsValid(self.ConfigPanel) then return end

    self.ConfigPanel = vgui.Create('DFrame')
    self.ConfigPanel:SetSize(800, 600)
    self.ConfigPanel:MakePopup()
    self.ConfigPanel:Center()

    self.ConfigPanel:SetTitle('Настройка всех телепортов')

    local scrollpanel = vgui.Create('DScrollPanel', self.ConfigPanel)

    scrollpanel:TDLib():Stick(FILL, 3)

    for k, v in pairs(NextRP.Teleports.Brushes[game.GetMap()]) do
        local teleportPanel = vgui.Create('DPanel')

        local deleteButton = vgui.Create('DButton', teleportPanel)
        deleteButton:TDLib()
            :Stick(RIGHT, 2)

        deleteButton:SetWide(150)
        deleteButton:SetLabel('Удалить')

        function deleteButton:DoClick()
            netstream.Start('NextRP.Teleports.Remove', k, false)
        end

        scrollpanel:Add(teleportPanel)
    end

    for k, v in pairs(NextRP.Teleports.Brushes.Global) do
        local teleportPanel = vgui.Create('DPanel')

        local deleteButton = vgui.Create('DButton', teleportPanel)
        deleteButton:TDLib()
            :Stick(RIGHT, 2)

        deleteButton:SetWide(150)
        deleteButton:SetLabel('Удалить')

        function deleteButton:DoClick()
            netstream.Start('NextRP.Teleports.Remove', k, true)
        end

        scrollpanel:Add(teleportPanel)
    end


end

netstream.Hook('NextRP.Teleports.Sync', function(teleports)
    NextRP.Teleports = NextRP.Teleports or {}
    NextRP.Teleports.Brushes = NextRP.Teleports.Brushes or {}

    NextRP.Teleports.Brushes = teleports
end)]]