--[[--
Модуль для работы с API
NextRP предоставляет своим пользователям возможноть взаемодействывать с API Multiverse Team.
]]
-- @module NextRP.Logger

NextRP.Logger = NextRP.Logger or {}

local webhook = {
    params = {},
    endpoint = 'http://185.251.89.135:5001/api/v1/server/discord/send',

    -- URL
    SetURL = function(self, value)
        self()['url'] = value
        return self
    end,
    -- Username
    SetUsername = function(self, value)
        self()['username'] = value
        return self
    end,
    -- Avatar
    SetAvatar = function(self, value)
        self()['avatar'] = value
        return self
    end,

    -- Отправление веб хука на API
    Send = function(self, message, callback)
        if not NextRP.Logger.Ready then 
            Error('Logger not ready yet! Try again later!')
            return 
        end
        local body = {}
        if message.IsEmbed then
            body['embed'] = message()
        else
            body['message'] = tostring(message)
        end
        body['url'] = self()['url']
        body['avatar'] = self()['avatar']
        body['username'] = self()['username']

        HTTP({
            success = function(code, body)
                if callback then
                    callback(false, code, body)
                end
            end,
            failed = function(reason)
                if callback then
                    callback(true, reason)
                end
            end,
            method = 'POST',
            url = self.endpoint,
            headers = {
                ['Authorization'] = NextRPToken 
            },
            body = util.TableToJSON(body),
            type = 'application/json'
        })
    end,
    
    -- Метафункции
    __call = function(self)
        return self.params
    end
}
webhook.__index = webhook

--- Создаёт вебхук.
-- @realm server
-- @tparam string url Ссылка на котоую будет отправлен вебхук
-- @treturn Webhook Созданный объект вебхука
function NewWebhook(url)
    local wh = setmetatable({}, webhook)

    return wh:SetURL(url)
end

local embed = {
    IsEmbed = true,
    Embed = {},
    -- Простые действия
    SetTitle = function(self, value)
        self()['title'] = value
        return self
    end,
    SetDescription = function(self, value)
        self()['description'] = value
        return self
    end,
    SetURL = function(self, value)
        self()['url'] = value
        return self
    end,
    SetColor = function(self, value)
        self()['color'] = value
        return self
    end,
    SetThumbnail = function(self, value)
        self()['thumbnail'] = value
        return self
    end,
    SetImage = function(self, value)
        self()['image'] = value
        return self
    end,

    -- Действия в несколько параметров
    SetAuthor = function(self, name, icon, url)
        self()['author'] = {}

        if name then
            self()['author']['name'] = name
        end
        if icon then
            self()['author']['icon_url'] = icon
        end
        if url then
            self()['author']['url'] = url
        end

        return self
    end,
    SetFooter = function(self, text, icon)
        self()['footer'] = {}
        
        if text then
            self()['footer']['text'] = text
        end
        if icon then
            self()['footer']['icon_url'] = icon
        end

        return self
    end,
    
    -- Добавление полей
    AddField = function(self, name, value, inline)
        self()['fields'] = self()['fields'] or {}
        local field = {}
        
        if name then
            field['name'] = name
        else
            ErrorNoHaltWithStack('name must be specified in AddField method!')
            return self
        end
        if value then
            field['value'] = value
        else
            ErrorNoHaltWithStack('value must be specified in AddField method!')
            return self
        end
        if inline then
            field['inline'] = inline
        end
        
        self()['fields'][#self()['fields'] + 1] = field

        return self
    end,

    -- Вернуть JSON представление ембеда, может кому-то будет полезно.
    JSON = function(self)
        return util.TableToJSON(self())
    end,

    -- Метафункции
    __call = function(self)
        return self.Embed
    end,
    __tostring = function(self)
        return self:JSON()
    end
}
embed.__index = embed

--- Создаёт объект Embed.
-- @realm server
-- @treturn Embed Созданный объект Embed
function NewEmbed()
    return setmetatable({}, embed)
end