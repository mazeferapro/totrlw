--- @classmod Player

local pMeta = FindMetaTable('Player')

--- Поиск персонажа игрока по ID
-- @realm server
-- @tparam number character_id ID персонажа
-- @treturn table|boolean Таблица персонажа, или `false` если персонаж не найден.
function pMeta:CharacterByID(character_id)
    if not istable(self.Characters) then return false end
    for i, char in pairs(self.Characters) do
        if char.character_id == character_id then
            return char
        end
    end

    return false
end

--- Запрос всех персонажей игрока с БД, минуя кэш
-- @realm server
-- @tparam func|charsCallback cb Колбэк функция
-- @internal
-- @see charsCallback
function pMeta:RequestCharacters(cb)
    local playerid = self:GetNVar('nrp_id')

    MySQLite.query( string.format('SELECT * FROM nextrp_characters WHERE player_id = %s;', MySQLite.SQLStr(playerid)), function(characters)
        characters = characters or {}
        for i, char in pairs(characters) do
            characters[i].team_index = NextRP.JobsByID[char.team_id].index
            characters[i].flag = util.JSONToTable(characters[i].flag)
            characters[i].inventory = util.JSONToTable(characters[i].inventory)
            characters[i].model = util.JSONToTable(characters[i].model)
        end
 
        if self:IsAdmin() then
            characters[#characters + 1] = {
                character_id = -1,
                character_name = 'Администратор',
                character_nickname = self:OldName(),
                exp = 0,
                flag = {},
                inventory = {},
                level = 1,
                model = {
                    model = 'models/player/hostage/hostage_04.mdl',
                    skin = 0,
                    bodygroups = {}
                },
                money = 500,
                player_id = pPlayer,
                rankid = 'ADMIN',
                rpid = '####',
                team_id = 'admin',
                team_index = TEAM_ADMIN,
            }
        end

        if cb then cb(characters) end
        return characters
    end, function(err)
        print(err)
        return err
    end)
end

--- Запрос определенного персонажа с БД, минуя кэш
-- @realm server
-- @tparam func|charCallback cb Колбэк функция
-- @tparam number character_id
-- @see charCallback
function pMeta:LoadCharacter(cb, character_id)
    local char = self:CharacterByID(character_id)
        
    RDV.LIBRARY.OnCharacterLoaded()

    if char then
        local jt = NextRP.GetJob(char.team_index)
        self:SetNVar( 'is_load_char', true, NETWORK_PROTOCOL_PUBLIC )
        self:SetNVar( 'nrp_rpname', char.character_nickname, NETWORK_PROTOCOL_PUBLIC )

        local formatedName = {}
        formatedName[#formatedName + 1] = char.rankid
        if jt.type ~= TYPE_JEDI and jt.type ~= TYPE_ADMIN and jt.nonumber ~= true then
            formatedName[#formatedName + 1] = char.rpid 
        end
        formatedName[#formatedName + 1] = char.character_nickname


        self:SetNVar( 'nrp_fullname', table.concat(formatedName, ' '), NETWORK_PROTOCOL_PUBLIC )

        self:SetNVar( 'nrp_name', char.character_nickname, NETWORK_PROTOCOL_PUBLIC )
        self:SetNVar( 'nrp_nickname', char.character_nickname, NETWORK_PROTOCOL_PUBLIC )
        
        self:SetNVar( 'nrp_faction', NextRP.JobsByID[char.team_id].type, NETWORK_PROTOCOL_PUBLIC )

        self:SetNVar('nrp_charid', character_id, NETWORK_PROTOCOL_PUBLIC)
        self:SetNVar('nrp_rankid', char.rankid, NETWORK_PROTOCOL_PUBLIC)

        self:SetNVar('nrp_rpid', char.rpid, NETWORK_PROTOCOL_PUBLIC)
        self:SetNVar('nrp_charflags', char.flag or {}, NETWORK_PROTOCOL_PUBLIC)

        self:SetNVar('nrp_money', char.money or false, NETWORK_PROTOCOL_PUBLIC)

        self:SetTeam(char.team_index)

        for k, v in pairs(char.flag) do
            if istable(jt.flags[k]) or istable(NextRP.Config.Pripiskis[k]) then continue end
            char.flag[k] = nil
            self:SetCharValue('flag', util.TableToJSON(char.flag), function()
                self:SetNVar('nrp_charflags', char.flag or {}, NETWORK_PROTOCOL_PUBLIC)
            end)
        end

        -- self:UpdateInventory()
        if cb then cb(char) end

        if IsValid(self.SpawnedVeh) then
            self.SpawnedVeh:Remove()
            self.SpawnedVeh = nil

            self:SendMessage(MESSAGE_TYPE_WARNING, 'Ваша техника была возвращена из-за смены персонажа.')
        end
    else
        self:ConCommand('retry')
    end
end

--- Установка игроку профессии
-- @realm server
-- @tparam number team_index **Индекс** профессии
-- @tparam[opt=false] boolean temp Устанавливает временную профессию
-- @see charCallback
function pMeta:ChangeTeam( team_index, temp )
    team_index = team_index and team_index or error('NoValue')

    local oldJob = self:getJobTable()
    local job = NextRP.GetJob(team_index)
    if not job then return end

    local rankid = job.ranks[self:GetRank()]
    if not istable(rankid) then rankid = job.default_rank else rankid = self:GetRank() end

    if not temp then
        self:SetNVar('nrp_tempjob', false)
        self:SetCharValue('team_id', job.id, function()
            local c = self:CharacterByID(self:GetNVar('nrp_charid'))
            c.team_id = job.id

            self:SetCharValue('rankid', rankid, function()
                c.rankid = rankid
                c.team_index = team_index
                c.flag = {}
                c.model = {}
                
                self:LoadCharacter(function()
                    self:SendMessage(MESSAGE_TYPE_WARNING, 'Вам выдали профессию ', job.name, ' на постоянной основе.')
                    hook.Call( 'PlayerLoadout', GAMEMODE, self )
                    hook.Call( 'PlayerChangeJob', GAMEMODE, self, oldJob, job)
                end, self:GetNVar('nrp_charid'))
            end)

            self:SetCharValue('model', '[]')
            self:SetCharValue('flag', '[]')
        end)
    else
        local c = self:CharacterByID(self:GetNVar('nrp_charid'))
        c.team_id = job.id
        c.team_index = team_index
        c.rankid = rankid
        c.flag = {}
        c.model = {}
        
        self:SetNVar('nrp_tempjob', true)

        self:LoadCharacter(function()
            self:SendMessage(MESSAGE_TYPE_WARNING, 'Вам выдали профессию ', job.name, ' на время (до перезахода/смены персонажа).')
            hook.Call( 'PlayerLoadout', GAMEMODE, self )
        end, self:GetNVar('nrp_charid'))
    end
end
netstream.Hook('NextRP::GiveTeam', function(pPlayer, pTarget, iTeam, bTemp)
    if pPlayer:IsAdmin() then pTarget:ChangeTeam(iTeam, bTemp) end
    local pJob = pPlayer:getJobTable()
    local tJob = pTarget:getJobTable()

    local isPHasWL = pJob.ranks[pPlayer:GetRank()].whitelist
    local isARC = pPlayer:GetNVar('nrp_charflags')['arc'] or false

    if (iTeam ~= pTarget:Team()) and (isPHasWL or isARC) then
        pTarget:ChangeTeam(iTeam, bTemp)
    end
end)

--- Изменяет значения полей в БД (для персонажа)
-- @realm server
-- @tparam string name Имя поля в БД
-- @tparam string|number value Значение для поля
-- @tparam func cb Колбэк функция, без аргументов
-- @tparam[opt=ID текущего персонажа] number charid ID персонажа
-- @internal
function pMeta:SetCharValue( name, value, cb, charid )
    value = value and value or error('NoValue')

    charid = charid and MySQLite.SQLStr(charid) or MySQLite.SQLStr(self:GetNVar('nrp_charid'))
    local numCharid = tonumber(string.Replace(charid, '"', ''))
    
    -- Ensure the character cache exists before trying to access it
    if not NextRP.Chars.Cache[numCharid] then
        NextRP.Chars.Cache[numCharid] = {}
    end
    
    NextRP.Chars.Cache[numCharid][name] = value

    local str = isnumber(value) and '%d' or '%s'
    value = isnumber(value) and value or MySQLite.SQLStr(value)

    MySQLite.query( string.format( 'UPDATE nextrp_characters SET %s = '..str..' WHERE character_id = %s;',
        name,
        value,
        charid
    ), function()
        if cb then cb() end
    end)
end

function pMeta:AddSlot(nSlots)
    local curSlots = self:GetNVar('nrp_slots')
    nSlots = curSlots + nSlots

    self:SetNVar('nrp_slots', nSlots, NETWORK_PROTOCOL_PUBLIC)
    self:SavePlayerData( 'char_slots', nSlots)
end

hook.Add('NextRP::PlayerIDRetrived', 'OpenCharsMenu', function(pPlayer)
    pPlayer:RequestCharacters(function(characters)
        pPlayer.Characters = characters

        for k, v in pairs(characters) do
            local job = NextRP.GetJob(v.team_index)
            if job.type == TYPE_JEDI then
                -- Discord:JobRank(pPlayer:SteamID64(), 'job:noremove', 'job:jedi')
                continue
            else
                -- Discord:JobRank(pPlayer:SteamID64(), 'job:noremove', 'job:'..job.id)
                continue 
            end
        end

        -- Discord:JobRank(pPlayer:SteamID64(), 'misc:noav', 'misc:noadd')
        netstream.Start(pPlayer, 'NextRP::OpenInitCharsMenu', characters)
    end)
end)

--- Колбэк для персонажей
-- @realm server
-- @function charsCallback
-- @tparam table chars Персонажи игрока
-- @callback

--- Колбэк для персонажа
-- @realm server
-- @function charCallback
-- @tparam table char Персонаж игрока
-- @callback