local DeriveGamemode = DeriveGamemode
local MsgC = MsgC
local hook = hook
local include = include
local AddCSLuaFile = AddCSLuaFile
local ipairs = ipairs
local setmetatable = setmetatable
local table = table
local Color = Color
local pairs = pairs
local file = file
local string = string
local util = util

-- Информация про режим.
GM.Name = 'StarWarsRP'
GM.Version = '2.1.1'
GM.ServerVersion = '1.0.0'
GM.ServerID = 'vision'

-- Информация про автора, не юзайте слитый, напишите мне.
GM.Author = ''
GM.Email = ''
GM.Website = ''

-- Подтягиваем функции с сандбокса
DeriveGamemode('sandbox')

MsgC('\n==============================================\n=\n')
MsgC('= NextRP начал загружаться.\n= Версия: '..GM.Version..'\n= Разработчик: Кот\n=\n')
MsgC('==============================================\n\n')

hook.Run('NextRP::StartLoading')

include('libs/nw.lua')
AddCSLuaFile('libs/nw.lua')
MsgC('NW загружен.\n')

include('libs/pon.lua')
AddCSLuaFile('libs/pon.lua')

MsgC('PON загружен.\n')

include('libs/netstream.lua')
AddCSLuaFile('libs/netstream.lua')
MsgC('NetStream v2 загружен.\n')

include('libs/mysqlite.lua')
AddCSLuaFile('libs/mysqlite.lua')
MsgC('MySQLite загружен.\n')

include('libs/cami.lua')
AddCSLuaFile('libs/cami.lua')
MsgC('CAMI загружен.\n')



local EP = {
    m = GM.FolderName..'/gamemode/libs/paws/paws_lib/modules/',
    l = GM.FolderName..'/gamemode/libs/paws/paws_lib/'
}
local MODULES = MODULES or {}
local meta = {}
function meta.__call( self, var )
	return self
end
local meta1 = {
    uID = 'newmodule', 
    Title = 'New Module',
    Author = 'Newbie', 
    Version = '0.0.1',

    ROOT = 'paw_newmodule',
    CONFIG = 'config.lua',

    FILESYSTEM = {},
    NETS = {},

    OnLoad = function(self)

    end,

    SetTitle = function(self, sString)
        self.Title = sString
        return self
    end,
    SetAuthor = function(self, sString)
        self.Author = sString
        return self
    end,
    SetVersion = function(self, sString)
        self.Version = sString
        return self
    end,

    SetRoot = function(self, sString)
        self.ROOT = sString 
        return self 
    end,
    SetConfig = function(self, sString) 
        self.CONFIG = sString
        return self
    end,

    SetFileSystem = function(self, tTable)
        self.FILESYSTEM = tTable
        return self
    end,

    SetNets = function(self, tTable)
        self.NETS = tTable
        return self
    end,

    SetOnLoadFunction = function(self, fFuntion)
        self.OnLoad = fFuntion(self)
        return self
    end
}
meta.__index = meta1 
function PAW_MODULE(uid)

    for k, v in ipairs(MODULES) do
        if v.uID == uid then return MODULES[k] end
    end

    local ModuleTable = {
        uID = uid 
    }

    setmetatable(ModuleTable, meta)
    local i = table.insert(MODULES, ModuleTable)

    return MODULES[i]
end
local function loadLib()
    local m = include(EP.l .. 'lib.lua')
    NextRP.PawLib = m
    AddCSLuaFile(EP.l .. 'lib.lua') 

    MsgC(Color(0,255,0), '[Aw... Paws!] Загрузка модуля "'..m.Title..'" by '..m.Author..' (v: '..m.Version..')'..'\n')
    hook.Run('Paws.'..m.uID..'.Loading', m)

    include(EP.l..m.CONFIG)
    AddCSLuaFile(EP.l..m.CONFIG)

    for k, dir in pairs(m.FILESYSTEM) do
        if dir == 'modules' then continue end
        local files = file.Find(EP.l..dir..'/*', 'LUA')

        for k, v in pairs(files) do
            if string.StartWith(v, 'sv') then
                if SERVER then
                    local load = include(EP.l..dir..'/'..v)
                    if load then load() end
                end 
            end

            if string.StartWith(v, 'cl') then
                if CLIENT then
                    local load = include(EP.l..dir..'/'..v)
                    if load then load() end 
                end

                AddCSLuaFile(EP.l..dir..'/'..v)
            end

            if string.StartWith(v, 'sh') then
                local load = include(EP.l..dir..'/'..v)
                if load then load() end

                AddCSLuaFile(EP.l..dir..'/'..v)
            end 

            MsgC(Color(190, 252, 3), '[Aw... Paws!]', '[', m.Title, ']', ' Загрузка "'..v..'" прошла успешно\n')
        end 
    end

    for k, v in pairs(m.NETS) do
        if SERVER then
            util.AddNetworkString(v)
            MsgC(Color(0, 255, 0), '[Aw... Paws!]', '[', m.Title, ']', ' Зарегестрировано имя Neta "'..v..'" успешно\n' )
        end
    end

    MsgC(Color(0,255,0), '[Aw... Paws!] Загружен модуль "'..m.Title..'" by '..m.Author..' (v: '..m.Version..')'..'\n')
    m.Loaded = true
    hook.Run('Paws.'..m.uID..'.Loaded', m)
end
local function load()
    local modules = file.Find(EP.m..'/*', 'LUA')

    MsgC(Color(0,255,0), '[Aw... Paws!] Найдено доп. модулей: ', table.Count(modules), '\n')

    for k, v in pairs(modules) do
        local m = include(EP.m..'/'..v)

        // if not istable(m) then continue end

        AddCSLuaFile(EP.m..'/'..EP.m..'/'..v) 

        MsgC(Color(0,255,0), '[Aw... Paws!] Loading module "'..m.Title..'" by '..m.Author..' (v: '..m.Version..')'..'\n')
        hook.Run('Paws.'..m.uID..'.Loading', m)

        include(EP.m..'/'..m.ROOT..'/'..m.CONFIG)
        AddCSLuaFile(EP.m..'/'..m.ROOT..'/'..m.CONFIG)

        for k, dir in pairs(m.FILESYSTEM) do
            local files = file.Find(EP.m..'/'..m.ROOT..'/'..dir..'/*', 'LUA')

            for k, v in pairs(files) do
                if string.StartWith(v, 'sv') then
                    if SERVER then
                        local load = include(EP.m..'/'..m.ROOT..'/'..dir..'/'..v)
                        if load then load() end
                    end 
                end

                if string.StartWith(v, 'cl') then
                    if CLIENT then
                        local load = include(EP.m..'/'..m.ROOT..'/'..dir..'/'..v)
                        if load then load() end 
                    end

                    AddCSLuaFile(EP.m..'/'..m.ROOT..'/'..dir..'/'..v)
                end

                if string.StartWith(v, 'sh') then
                    local load = include(EP.m..'/'..m.ROOT..'/'..dir..'/'..v)
                    if load then load() end

                    AddCSLuaFile(EP.m..'/'..m.ROOT..'/'..dir..'/'..v)
                end 

                MsgC(Color(190, 252, 3), '[Aw... Paws!]', '[', m.Title, ']', ' Loaded "'..v..'" successfully\n')
            end 
        end

        for k, v in pairs(m.NETS) do
            if SERVER then
                util.AddNetworkString(v)
                MsgC(Color(0, 255, 0), '[Aw... Paws!]', '[', m.Title, ']', ' Registered Network string "'..v..'" successfully\n' )
            end
        end

        MsgC(Color(0,255,0), '[Aw... Paws!] Loaded module "'..m.Title..'" by '..m.Author..' (v: '..m.Version..')'..'\n')
        m.Loaded = true
        hook.Run('Paws.'..m.uID..'.Loaded', m)
    end
end

local fn = GM.FolderName
local function IncludeClient(path)
	if CLIENT then
		include(fn..'/gamemode/libs/pawsui/' .. path)
	end

	if SERVER then
		AddCSLuaFile(fn..'/gamemode/libs/pawsui/' .. path)
	end
end 
local function loadPawsUI()
    IncludeClient('settings.lua')
	for k, v in pairs(file.Find(fn..'/gamemode/libs/pawsui/elements/*.lua', 'LUA')) do 
		IncludeClient('elements/'..v)
	end

	for k, v in pairs(file.Find(fn..'/gamemode/libs/pawsui/libs/*.lua', 'LUA')) do 
		IncludeClient('libs/'..v)
	end
end 

-- Глобальная таблица
NextRP = {
    Config = {},
    Style = {},
    -- Main systems
    Jobs = {},
    JobsByID = {},
    Whitelist = {},
    -- Components
    Utils = {},
    Database = {},
    -- Sub-system
    Chars = {},
    Ranks = {},
    Scoreboard = {},
    NPC = {},
    Friends = {},
    Cadets = {},
    ControlPoints = {},
    Codes = {},
    Logger = {},
    -- Cars
    Cars = {},
    Version = GM.Version,
    ServerVersion = GM.ServerVersion,
    ServerID = string.Replace(GM.ServerID..'_'..GM.Version..'_'..GM.ServerVersion, '.', '_'), -- Используеться для сохранения файлов
    APIServerID = GM.ServerID, -- Используеться для аунтификации на api-сервере
    CRotR = {}
}

loadLib()
loadPawsUI()

-- Загружаем Ядро
function NextRP.LoadCore(self)
    local sPath = GM.FolderName..'/gamemode/core/'

    local files, folders = file.Find(sPath..'/*', 'LUA')
    local loaded = false

    for k, v in pairs(files) do
        if string.StartWith(v, 'sv') then
            if SERVER then
                local load = include(sPath..v)
                if load then load() end
            end 

            loaded = true
        end

        if string.StartWith(v, 'cl') then
            if CLIENT then
                local load = include(sPath..v)
                if load then load() end 
            end

            AddCSLuaFile(sPath..v)
            loaded = true
        end

        if string.StartWith(v, 'sh') then
            local load = include(sPath..v)
            if load then load() end

            AddCSLuaFile(sPath..v)
            loaded = true
        end 

        if loaded then MsgC(Color(190, 252, 3), '[ NextRP ]', '[ Ядро ]', ' Файл "'..v..'" загружен успешно!\n', sPath..v, '\n') end
    end

    for k, v in pairs(folders) do
        local files = file.Find(sPath..v..'/*.lua', 'LUA')

        for kf, vf in pairs(files) do
            if string.StartWith(vf, 'sv') then
                if SERVER then
                    local load = include(sPath..v..'/'..vf)
                    if load then load() end
                    
                end 
            end

            if string.StartWith(vf, 'cl') then
                if CLIENT then
                    local load = include(sPath..v..'/'..vf)
                    
                    if load then load() end 
                end

                AddCSLuaFile(sPath..v..'/'..vf)
            end

            if string.StartWith(vf, 'sh') then
                local load = include(sPath..v..'/'..vf)
                if load then load() end

                AddCSLuaFile(sPath..v..'/'..vf)
            end 

            MsgC(Color(190, 252, 3), '[ NextRP ]', '[ Ядро | ', v, ' ]', ' Файл "'..vf..'" загружен успешно!\n', sPath..v..'/'..vf, '\n')
        end
    end
end

-- Загружаем конфиги
function NextRP.LoadConfigs(self)
    local sPath = GM.FolderName..'/gamemode/config/'

    include(sPath..'sh_themes.lua')
    AddCSLuaFile(sPath..'sh_themes.lua')

    local files, folders = file.Find(sPath..'/*.lua', 'LUA')

    for k, v in pairs(files) do
        if string.StartWith(v, 'sv') then
            if SERVER then
                local load = include(sPath..v)
                if load then load() end
            end 
        end

        if string.StartWith(v, 'cl') then
            if CLIENT then
                local load = include(sPath..v)
                if load then load() end 
            end

            AddCSLuaFile(sPath..v)
        end

        if string.StartWith(v, 'sh') then
            local load = include(sPath..v)
            if load then load() end

            AddCSLuaFile(sPath..v)
        end 

        MsgC(Color(190, 252, 3), '[ NextRP ]', '[ Конфиг ]', ' Файл "'..v..'" загружен успешно!\n')
    end
end
-- Загружаем модули
function NextRP.LoadModules(self)
    local sPath = GM.FolderName..'/gamemode/modules/'

    local files, folders = file.Find(sPath..'/*', 'LUA')
    local loaded = false

    for k, v in pairs(files) do
        if string.StartWith(v, 'sv') then
            if SERVER then
                local load = include(sPath..v)
                if load then load() end
            end 

            loaded = true
        end

        if string.StartWith(v, 'cl') then
            if CLIENT then
                local load = include(sPath..v)
                if load then load() end 
            end

            AddCSLuaFile(sPath..v)
            loaded = true
        end

        if string.StartWith(v, 'sh') then
            local load = include(sPath..v)
            if load then load() end

            AddCSLuaFile(sPath..v)
            loaded = true
        end 

        if loaded then MsgC(Color(190, 252, 3), '[ NextRP ]', '[ Модули ]', ' Файл "'..v..'" загружен успешно!\n', sPath..v, '\n') end
    end

    for k, v in pairs(folders) do
        local files = file.Find(sPath..v..'/*.lua', 'LUA')

        for kf, vf in pairs(files) do
            if string.StartWith(vf, 'sv') then
                if SERVER then
                    local load = include(sPath..v..'/'..vf)
                    if load then load() end
                    
                end 
            end

            if string.StartWith(vf, 'cl') then
                if CLIENT then
                    local load = include(sPath..v..'/'..vf)
                    
                    if load then load() end 
                end

                AddCSLuaFile(sPath..v..'/'..vf)
            end

            if string.StartWith(vf, 'sh') then
                local load = include(sPath..v..'/'..vf)
                if load then load() end

                AddCSLuaFile(sPath..v..'/'..vf)
            end 

            MsgC(Color(190, 252, 3), '[ NextRP ]', '[ Модули | ', v, ' ]', ' Файл "'..vf..'" загружен успешно!\n', sPath..v..'/'..vf, '\n')
        end
    end
end


hook.Run('NextRP::PreCoreLoad')
NextRP:LoadCore()
hook.Run('NextRP::CoreLoaded')

hook.Run('NextRP::PreConfigLoad')
NextRP:LoadConfigs()
hook.Run('NextRP::ConfigLoaded')

hook.Run('NextRP::PreModulesLoad')
NextRP:LoadModules()
hook.Run('NextRP::ModulesLoaded')

hook.Run('NextRP::EndLoading')

MsgC('\n==============================================\n=\n')
MsgC('= NextRP завершил загружаться.\n= '..GM.Version..'\n= Разработчик: Кот\n=\n')
MsgC('==============================================\n')
