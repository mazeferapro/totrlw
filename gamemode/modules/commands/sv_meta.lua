local MODULE = NextRP

local meta = {}
function meta.__call( self, var )
	return self
end 

if CLIENT then return end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end

local function WrongArgs(MODULE, pPlayer)
    MODULE:SendNotify(pPlayer, 'Неверные аргументы!', nil, 4, MODULE.Config.Colors.Red)
end

local m = {
    command = 'newcommand',
    Title = 'New Command',
    Description = 'New Command Description',

    Run = function(self, pPlayer, sText)
        -- To edit
    end,

    OnRun = function(self, pPlayer, sText)
        self.Run(pPlayer, sText)
        hook.Run('Paws.Lib.CommandRun', self.command, pPlayer, sText)
    end,

    SetCommand = function(self, sString)
        self.command = sString
        return self
    end,
    SetTitle = function(self, sString)
        self.Title = sString
        return self
    end,
    SetDescription = function(self, sString)
        self.Description = sString
        return self
    end,

    SetOnRunFunction = function(self, fFuntion)
        self.Run = fFuntion
        return self
    end
}

meta.__index = m

function MODULE:Command(command, get)

    get = get or false

    self.Commands = self.Commands or {} // MODULE.Commands = MODULE.Comands or {}
    
    for k, v in ipairs(self.Commands) do
        if v.command == command then return self.Commands[k] end
    end

    if get then
        return nil
    end

    local CommandTable = {
        command = command or nil
    }

    setmetatable(CommandTable, meta)

    local i = table.insert(self.Commands, CommandTable)

    return self.Commands[i]
end

function NextRP:AddCommand(sCommand, fCallback)
    local cmd = MODULE:Command(sCommand, false)
    cmd:SetOnRunFunction(fCallback)
end

NextRP:AddCommand('helmet', function(pPlayer)
    local helmetbodys = { 'Helmet', 'Head', 'helmet', 'head' }
    local bbody = true
    for k, data in pairs(pPlayer:GetBodyGroups()) do
        if table.HasValue(helmetbodys, data.name) then
            bbody = pPlayer:GetBodygroup(data.id)
            pPlayer:SetBodygroup(data.id, pPlayer:GetBodygroup(data.id) == 0 and 1 or 0 )
            pPlayer:Say(bbody == 0 and '/me снял шлем' or '/me надел шлем')
        end
    end
end)

NextRP:AddCommand('visor', function(pPlayer)
    local helmetbodys = { 'visor', 'Visor', 'binos', 'Binos' }
    local bbody = true
    for k, data in pairs(pPlayer:GetBodyGroups()) do
        if table.HasValue(helmetbodys, data.name) then
            bbody = pPlayer:GetBodygroup(data.id)
            if bbody == 0 then
                MODULE:SendNotify(pPlayer, 'Вы не можете взаимодействовать с визором!', nil, 4, MODULE.Config.Colors.Red)
                return
            end
            pPlayer:SetBodygroup(data.id, pPlayer:GetBodygroup(data.id) == 1 and 2 or 1 )
            pPlayer:Say(bbody == 2 and '/me снял визор' or '/me надел визор')
        end
    end
end)


NextRP:AddCommand('visori', function(pPlayer)
    print('stat')
    --local tbl = Comlink.Channels
    --for k, v in pairs(tbl) do
        --pPlayer:ChatPrint(k..' '..v)
       hook.Call("Comlink.CreateChannels")
   -- end
end)

NextRP:AddCommand('visori2', function(pPlayer)
    print(tprint(pPlayer:getJobTable()))
    --local tbl = Comlink.Channels
    --for k, v in pairs(tbl) do
        --pPlayer:ChatPrint(k..' '..v)
   -- end
end)

NextRP:AddCommand('test', function(pPlayer, sText)
end)

NextRP:AddCommand('setclaimertitle', function(pPlayer, sText)
    if not pPlayer:IsAdmin() then return end
    if sText == '' then return end
    local tr = pPlayer:GetEyeTrace().Entity
    tr:SetTitle(sText)
end)

NextRP:AddCommand('docs', function(pPlayer)
    local tDocsInfo = {}

    local tJob = pPlayer:getJobTable()
    --local tFactionConfig = MODULE.Config.Factions[tJob.faction] or MODULE.Config.Factions.Default

    table.insert(tDocsInfo, '['..tJob.category..']')

    table.insert(tDocsInfo, '['..pPlayer:GetRank()..']')

    table.insert(tDocsInfo, '['..pPlayer:GetNumber()..']')

    table.insert(tDocsInfo, '['..pPlayer:GetNickname()..']')

    PAW_MODULE('lib'):SendMessageDist(pPlayer, 4, 250, Color(90, 200, 90), '[Docs] ', color_white, unpack(tDocsInfo) )
end)

NextRP:AddCommand("givemoney", function(pPlayer, sText)
        local args = string.Explode(" ", sText)
        
        if #args < 2 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Использование: /givemoney <имя игрока> <количество>")
            return
        end
        
        local playerName = args[1]
        local amount = tonumber(args[2])
        
        if not amount or amount <= 0 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Количество денег должно быть положительным числом")
            return
        end
        
        -- Проверяем, хватает ли денег
        if not pPlayer:CanAfford(amount) then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "У вас недостаточно денег! У вас: " .. (pPlayer:GetMoney() or 0) .. " CR")
            return
        end
        
        -- Ищем игрока по частичному совпадению имени
        local targetPlayer = nil
        local foundPlayers = {}
        
        for _, ply in ipairs(player.GetAll()) do
            if string.find(string.lower(ply:Nick()), string.lower(playerName)) then
                table.insert(foundPlayers, ply)
            end
        end
        
        if #foundPlayers == 0 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Игрок с именем '" .. playerName .. "' не найден")
            return
        elseif #foundPlayers > 1 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Найдено несколько игроков. Будьте более точными:")
            for _, ply in ipairs(foundPlayers) do
                pPlayer:SendMessage(MESSAGE_TYPE_NONE, "- " .. ply:Nick())
            end
            return
        end
        
        targetPlayer = foundPlayers[1]
        
        -- Проверяем, что целевой игрок имеет персонажа
        if targetPlayer:GetNVar('nrp_charid') == -1 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Нельзя передать деньги администратору")
            return
        end
        
        -- Проверяем, что игрок не передает деньги самому себе
        if targetPlayer == pPlayer then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Вы не можете передать деньги самому себе!")
            return
        end
        
        -- Проверяем расстояние между игроками
        local distance = pPlayer:GetPos():Distance(targetPlayer:GetPos())
        if distance > 200 then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, "Игрок слишком далеко! Подойдите ближе.")
            return
        end
        
        -- Используем существующую функцию SendMoney
        pPlayer:SendMoney(amount, targetPlayer)
        
        -- Лог операции
        print("[Money Transfer] " .. pPlayer:Nick() .. " передал " .. amount .. " CR игроку " .. targetPlayer:Nick())
    end)
    
    -- Команда для проверки баланса
    NextRP:AddCommand("money", function(pPlayer, sText)
        local money = pPlayer:GetMoney() or 0
        pPlayer:SendMessage(MESSAGE_TYPE_NONE, "Ваш баланс: " .. string.Comma(money) .. " CR")
    end)