-- gamemode/modules/money/cl_hud.lua
-- Отдельный модуль для отображения денег в HUD



local function ExchangeMenu(count)
    local exc = 0
    local frame = vgui.Create('PawsUI.Frame')
    frame:SetTitle('Обмен')
    frame:SetSize(400, 200)
    frame:MakePopup()
    frame:ShowSettingsButton(false)
    frame:Center()
    local save = vgui.Create('PawsUI.Button', frame)

    save:Stick(BOTTOM, 4):On('DoClick', function()
        netstream.Start('NextRP::Exchange', exc)
        frame:Remove()
    end)

    save:SetLabel('Обменять')
    local radius = vgui.Create('DNumSlider', frame)
    radius:SetPos(50, 50)
    radius:SetSize(300, 100)
    radius:SetText('Количество')
    radius:SetMin(0)
    radius:SetMax(count or 0)
    radius:SetDecimals(0)
    radius:SetDefaultValue(0)
    radius:SetValue(0)

    function radius:OnValueChanged(nValue)
        exc = math.Round(nValue)
    end
end

netstream.Hook('NextRP::ExchangerMenu', function(count)
    ExchangeMenu(count)
end)




































NextRP = NextRP or {}
NextRP.MoneyHUD = NextRP.MoneyHUD or {}

-- Локальные переменные для кэширования и анимации
local cached_money = 0
local displayed_money = 0
local last_money_update = 0
local money_color = Color(255, 255, 255, 255) -- Золотой цвет по умолчанию

-- Функция для получения текущих денег с кэшированием
local function GetCurrentMoney()
    local player = LocalPlayer()
    if not IsValid(player) then return 0 end
    
    local current_money = player:GetMoney() or 0
    
    -- Если деньги изменились, обновляем кэш и время
    if current_money ~= cached_money then
        cached_money = current_money
        last_money_update = CurTime()
        NextRP.MoneyHUD:OnMoneyChanged(current_money)
    end
    
    return current_money
end

-- Функция для отрисовки теней текста
local function DrawShadowText(text, font, x, y, color, align_x, align_y)
    align_x = align_x or TEXT_ALIGN_LEFT
    align_y = align_y or TEXT_ALIGN_TOP
    
    -- Тень
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 200), align_x, align_y)
    
    -- Основной текст
    draw.SimpleText(text, font, x, y, color, align_x, align_y)
end

-- Основная функция отрисовки денег
function NextRP.MoneyHUD:DrawMoney(info_x, info_y, info_align)
    local player = LocalPlayer()
    if not IsValid(player) or not player:Alive() then return end
    
    -- Получаем актуальные деньги
    local current_money = GetCurrentMoney()
    
    -- Плавная анимация изменения денег
    displayed_money = Lerp(FrameTime() * 5, displayed_money, current_money)
    
    -- Формируем текст с разделителями тысяч
    local moneyText = "CR: " .. string.Comma(math.Round(displayed_money))
    
    -- Обновляем цвет в зависимости от времени с последнего изменения
    self:UpdateMoneyColor()
    
    -- Отображаем деньги
    DrawShadowText(moneyText, "hud_team", info_x, info_y + 50, money_color, info_align)
end

-- Функция обновления цвета денег
function NextRP.MoneyHUD:UpdateMoneyColor()
    local time_since_update = CurTime() - last_money_update
    
    -- Если деньги недавно изменились, делаем эффект
    if time_since_update < 2 then
        local flash_intensity = math.sin(CurTime() * 8) * 0.3 + 0.7
        local old_money = displayed_money - 50 -- Примерная разница для определения направления
        
        if cached_money > old_money then
            -- Зеленый для увеличения денег
            money_color = Color(0, 255, 0, 255 * flash_intensity)
        else
            -- Красный для уменьшения денег  
            money_color = Color(255, 0, 0, 255 * flash_intensity)
        end
    elseif time_since_update < 5 then
        -- Плавный переход обратно к золотому
        local fade = (5 - time_since_update) / 3
        money_color = Color(255, 255, 255, 255)
    else
        -- Обычный золотой цвет
        Color(255, 255, 255, 255)
    end
end

-- Функция вызываемая при изменении денег
function NextRP.MoneyHUD:OnMoneyChanged(newAmount)
    -- Звуковые эффекты при изменении денег
    if cached_money > 0 then -- Не воспроизводим при первой загрузке
        if newAmount > cached_money then
            -- Звук получения денег
            surface.PlaySound("garrysmod/content_downloaded.wav")
        elseif newAmount < cached_money then
            -- Звук траты денег
            surface.PlaySound("buttons/button10.wav")
        end
    end
    
    -- Лог для отладки
    print("[Money HUD] Money changed: " .. (cached_money or 0) .. " -> " .. newAmount)
end

-- Функция для принудительного обновления денег
function NextRP.MoneyHUD:ForceUpdate()
    GetCurrentMoney()
end

-- Функция инициализации
function NextRP.MoneyHUD:Initialize()
    -- Инициализируем начальные деньги
    timer.Simple(1, function()
        GetCurrentMoney()
    end)
    
    print("[Money HUD] Модуль отображения денег инициализирован")
end

timer.Create("NextRP_MoneyHUD_Update", 2, 0, function()
    GetCurrentMoney()
end)

-- Сетевые обработчики для принудительного обновления
if netstream then
    netstream.Hook('NextRP::MoneyUpdated', function(newAmount)
        cached_money = newAmount
        last_money_update = CurTime()
        NextRP.MoneyHUD:OnMoneyChanged(newAmount)
    end)
else
    -- Обработчик стандартного net (если потребуется)
    net.Receive("NextRP_MoneyUpdate", function()
        local newAmount = net.ReadInt(32)
        cached_money = newAmount
        last_money_update = CurTime()
        NextRP.MoneyHUD:OnMoneyChanged(newAmount)
    end)
end

-- Инициализируем модуль
NextRP.MoneyHUD:Initialize()

print("[NextRP.Money] Клиентский HUD модуль загружен!")