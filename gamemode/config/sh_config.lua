NextRP.Config.Title = 'Tales Of The Republic'
NextRP.Config.FancyTitle = 'TOTR'
NextRP.Config.ShortCode = 'TOTR'

NextRP.Config.RespawnTime = 30
NextRP.Config.DeathTimes = {
    ['user'] = 30,
    ['superadmin'] = 5
}

NextRP.Config.Pripiskis = {
}

NextRP.Config.cadetDoors = {
    ['main_trainingroom_forcefield_1_BUTTON'] = true,
    ['main_trainingroom_forcefield_1_BUTTON1'] = true,
}

NextRP.Config.cadetRealays = {
    ['main_trainingroom_forcefield_1'] = true,
}

NextRP.Config.medicDoors = {
    ['medbay_forcefielb'] = true,
}

NextRP.Config.medicRealays = {
    ['medbay_forcefield_1'] = true,
}

--NextRP.Config.customScale = {
--    ['Кадет'] = 1.0,
--}

--NextRP.Config.pipiskiScale = {
--}

NextRP.Config.regenTable = {
}

NextRP.Config.gasNoDamageTable = {
}


NextRP.Config.Link = {
    -- Правила
    Rule = 'https://docs.google.com/document/d/1ePuzNyuJq19eYoEqhtBDsU486c-DJPevU1e9r6-ueg8/edit?tab=t.0#heading=h.fgx3k797cb7t',
    -- Сайт
    WebSite = 'https://sites.google.com/view/chronicleofhopev2', -- ссылка на сайт
    -- Соцсети
    VK = '', -- ссылка на ВК
    Discord = 'https://discord.gg/buaJZ2SJm3', -- ссылка на Discord
    -- Стимовское говно
    SteamCollection = 'https://steamcommunity.com/sharedfiles/filedetails/?id=3021279832', -- ссылка на коллекцию Steam
    -- Донат
    --Donate = 'https://vk.com/dawnrepublicswrp' -- ссылка на донат. [...но зачем?]
}

NextRP.Config.FootstepSounds = {
    
    -- Пример для админов (беззвучные шаги)
    ['Администратор'] = {
        sounds = {},  -- пустая таблица = беззвучные шаги
        volume = 0.0,
        pitch = {100, 100}
    }
}

NextRP.Config.FootstepSoundsByFlag = {
}

hook.Add('NextRP::ConfigLoaded', 'NextRP::LoadConfigRlatedStuff', function()
NextRP.Config.Codes = {
    Permissions = {
        [CONTROL_GAR] = {
          [TEAM_CTRP] = true,
        }
    },
    States = {
        [CONTROL_GAR] = {
            [1] = {
                Title = '[Зелённый код]',
                Description = 'Уровень 3 - Штатный режим',
                Color = Color(0, 172, 29),
                Sound = Sound('defcons/defcon543.wav'),

                Default = true
            },
            [2] = {
                Title = '[Жёлтый Код]',
                Description = 'Уровень 2 - Повышенная готовность',
                Color = Color(238, 231, 30),
                Sound = Sound('defcons/defcon412.wav')
            },
            [3] = {
                Title = ' [Красный код]',
                Description = 'Уровень 1 - К оружию',
                Color = Color(183, 31, 31),
                Sound = Sound('defcons/defcon331.wav')
            },
            [4] = {
                Title = '[Черный код]',
                Description = 'Уровень 0 - Эвакуация с военного объекта',
                Color = Color(36, 36, 36),
                Sound = Sound('defcons/defcon331.wav')
            },
        }
    }
}
end)

hook.Add('NextRP::ThemeLoaded', 'NextRP::LoadeThemeRalatedStuff', function() -- эту строку не трогать

-- Для простоты написания сообщений.
local text = NextRP.Style.Theme.Text
local accent = NextRP.Style.Theme.Accent
local yellow = NextRP.Style.Theme.Yello
local orange = NextRP.Style.Theme.LightRed

NextRP.Config.AutoChatMessages = {
    {text, 'Надоело играть за этого персонажа? Используйте ', accent, 'F4', text, ' что-бы сменить его!'},
    {text, 'Кто-то нарушил? НонРП? Используйте: ', accent, 'F6', text, ' что-бы подать жалобу.'},
    {text, 'Для переключения вида от третьего лица, используйте: ', accent, 'F3', text, '.'},
    {text, 'За нарушение ', accent, 'правил сообщества вы ', text, 'получите ', orange, 'блокировку (бан)', text, ' на срок от 2-х дней.'},
    {text, 'Нажмите: ', accent, 'F2', text, ' для активации/деактивации СЗД.'},
    -- {text, 'Что-бы поддержать сервер вы можете ', accent, 'задонатить ', text, 'для этого используйте: ', accent, NextRP.Config.Link.VK, text, ' или ', accent, NextRP.Config.Link.Discord, text, '.'},
}

end) -- и эту строку тоже не трогать

NextRP.Config.UniqueIDs = {
    ['STEAM_0:1:127564031'] = {'Raven'},
    ['STEAM_0:1:176075556'] = {'Mazefera'},
    ['STEAM_0:0:54343242'] = {'Kudere', true},
    ['STEAM_0:1:576060442'] = {'КвестМейкер'},
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        function IsUnique(pPlayer) if IsValid(pPlayer) then return NextRP.Config.UniqueIDs[pPlayer:SteamID()] else return false end end
hook.Add('NextRP::IconLoaded', 'NextRP::LoadIconsRelatedStuff', function()

NextRP.Config.ControlsColors = {
    [CONTROL_CIS] = Color(204, 57, 20),
    [CONTROL_GAR] = Color(77, 184, 255),
    [CONTROL_HEADHUNTERS] = Color(225, 255, 55),
    [CONTROL_NONE] = Color(255, 118, 248),
    [CONTROL_NATO] = Color(64, 64, 64)
}

NextRP.Config.ControlsMaterials = {
    [CONTROL_CIS] = NextRP.Style.Materials.DroidIcon,
    [CONTROL_GAR] = NextRP.Style.Materials.CloneIcon,
    [CONTROL_HEADHUNTERS] = NextRP.Style.Materials.RPRoleIcon,
    [CONTROL_NONE] = NextRP.Style.Materials.ServerStuffIcon,
    [CONTROL_NATO] = NextRP.Style.Materials.DroidIcon
}

end)