TEAM_CADET = NextRP.createJob('Кадет', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'cadet', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/player/olive/cadet/cadet.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Cadet',
    ranks = {
        ['Cadet'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/player/olive/cadet/cadet.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Кадеты',
            speed = {500, 500}, -- Значения скорости: {walkSpeed, runSpeed}
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = true,
    walkspead = 100,
    runspead = 250,
    -- Категория
    category = 'Кадеты'
})




--[[----------------------------------------------------------------------------------

    #:ВАР

------------------------------------------------------------------------------------]]

TEAM_501TRP = NextRP.createJob('Боец 501-го', {
    id = '501trp',
    model = {'models/501st/trooper.mdl'},
    color = Color(0,102,204),
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            sortOrder = 1,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Рекрут',
            whitelist = false,
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 4,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 5,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 6,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 7,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 8,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 9,
            model = {
                'models/501st/trooper.mdl',
            },
            hp = 250,
            ar = 50,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Старший Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 10,
            model = {
                'models/501st/officer.mdl',
            },
            hp = 250,
            ar = 55,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 11,
            model = {
                'models/501st/officer.mdl',
            },
            hp = 250,
            ar = 55,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 12,
            model = {
                'models/501st/officer.mdl',
            },
            hp = 250,
            ar = 55,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15a_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 13,
            model = {
                'models/501st/rex.mdl'
            },
            hp = 250,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'arccw_k_dc17ext_akimbo',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Капитан',
            whitelist = false,
        },
    },
    flags = {
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/501st/medic.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_stun',
                },
                ammunition = {
                    'arccw_cgi_k_dp24',
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_med_scanner',
                    'realistic_hook',
                },
            },
            hp = 200,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Тяж боец'] = {
            id = 'HT',
            model = {
                'models/501st/heavy.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_heavy',
                },
                ammunition = {
                    'arccw_cgi_k_z6adv',
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_501shield',
                    'weapon_squadshield_arm',
                    'arccw_k_launcher_rps6',
                    'realistic_hook',
                },
            },
            hp = 400,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Пилот'] = {
            id = 'PIL',
            model = {
                'models/501st/pilot.mdl'
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_stun',
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dp23',
                    'arccw_k_nade_thermal',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'fort_datapad',
                    'realistic_hook',
                },
            },
            hp = 200,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/501st/engineer.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_stun',
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dp23',
                    'arccw_k_nade_thermal',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'fort_datapad',
                    'turret_placer',
                    'arccw_k_nade_sequencecharger',
                    'arccw_k_nade_antitankmine',
                    'defuser_bomb',
                    'turret_placer',
                    'realistic_hook',
                },
            },
            hp = 250,
            ar = 45,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARF'] = {
            id = 'ARF',
            model = {
                'models/501st/arf.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_stun',
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'sv_datapad',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_flashbang',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_decoy',
                    'arccw_k_nade_sonar',
                    'jet_mk2',
                },
            },
            hp = 250,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Десантник'] = {
            id = 'PAR',
            model = {
                'models/501st/officer.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_stun',
                },
                ammunition = {
                    'arccw_cgi_k_dp24',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_nade_impact',
                    'arccw_k_nade_smoke',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_sequencecharger',
                    'realistic_hook',
                },
            },
            hp = 250,
            ar = 45,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARC'] = {
            id = 'ARC',
            model = {
                'models/501st/arc.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_stun',
                },
                ammunition = {
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_k_dc15s_stun',
                    'arccw_k_dc15s_grenadier',
                    'arccw_cgi_k_westarm5',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sequencecharger',
                    'arccw_sops_vibroknife',
                    'arccw_cgi_k_akimbo_dc17_heavy',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_sonar',
                    'weapon_squadshield_arm',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'defuser_bomb',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = '501-й Легион'
})


TEAM_CTRP = NextRP.createJob('Боец 104-го', {
    id = 'ctrp',
    model = {'models/finch/jaj/104th/wp/trooper.mdl'},
    color = Color(127,143,166),
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            sortOrder = 1,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Рекрут',
            whitelist = false,
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 4,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 5,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 6,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 7,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 8,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 9,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Старший Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 10,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 11,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 12,
            model = {
                'models/finch/jaj/104th/wp/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15a',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 13,
            model = {
                'models/finch/jaj/104th/wp/comet.mdl',
                'models/finch/vrp/evo/104ce/barbatos.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'arccw_k_dc17ext_akimbo',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 14,
            model = {
                'models/finch/jaj/104th/wp/comet.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 15,
            model = {
                'models/finch/jaj/104th/wp/comet.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['СС'] = {
            sortOrder = 16,
            model = {
                'models/finch/jaj/104th/wp/comet.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = true,
        },
        ['SCC'] = {
            sortOrder = 17,
            model = {
                'models/finch/jaj/104th/wp/comet.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Старший Клон-Коммандер',
            whitelist = true,
        },
        ['MC'] = {
            sortOrder = 18,
            model = {
                'models/finch/jaj/104th/wp/comet.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            fullRank = 'Маршал коммандер',
            whitelist = true,
        },
    },
    flags = {
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/finch/jaj/104th/wp/medic.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_k_dc15s',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_med_scanner',
                    'realistic_hook',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Тяж боец'] = {
            id = 'HT',
            model = {
                'models/finch/jaj/104th/base/trooper3.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_dc17_heavy',
                },
                ammunition = {
                    'arccw_cgi_k_z6adv',
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_republicshield',
                    'weapon_squadshield_arm',
                    'realistic_hook',
                },
            },
            hp = 400,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Дроид OOM'] = {
            id = 'OOM',
            model = {
                'models/player/roger/rb1_battledroid/assault/b1_battledroid_assault.mdl',
            },
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_e5bx',
                    'arccw_k_e5s',
                    'arccw_k_dc17_stun',
                    'arccw_k_rg4d',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'realistic_hook',
                },
            },
            hp = 250,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Ракетомётчик 104-го'] = {
            id = 'JAV',
            model = {
                'models/finch/jaj/104th/wp/sinker.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_launcher_rps6',
                    'arccw_k_launcher_plx1',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_launcher_plx1',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_impact',
                    'arccw_k_nade_flashbang',
                    'realistic_hook',
                },
            },
            hp = 270,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир основного взвода 104-го'] = {
            id = 'OFCREG',
            model = {
                'models/finch/jaj/104th/base/officer.mdl',
            },
            weapon = {
                default = {
                    'arccw_cgi_k_akimbo_dc17_heavy',
                },
                ammunition = {
                    'aarccw_k_dc15le',
                    'arccw_k_nade_thermal',
                    'arccw_k_launcher_rps6',
                    'arccw_cgi_k_z6adv',
                    'arccw_k_dc15le',
                    'weapon_officerboost_normal',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 400,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир медиков 104-го'] = {
            id = 'OFCMED',
            model = {
                'models/finch/jaj/104th/wp/fourfour.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_k_dc15s',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_med_scanner',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Пилот'] = {
            id = 'PIL',
            model = {
                'models/finch/jaj/104th/base/pilot.mdl',
                'models/navy/gnavyengineer2.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dp24c',
                    'arccw_k_nade_thermal',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'fort_datapad',
                    'realistic_hook',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/finch/jaj/104th/base/eng.mdl',
                'models/navy/gnavyengineer2.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dp24c',
                    'arccw_k_nade_thermal',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'fort_datapad',
                    'turret_placer',
                    'arccw_k_nade_sequencecharger',
                    'arccw_k_nade_antitankmine',
                    'defuser_bomb',
                    'realistic_hook',
                },
            },
            hp = 250,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Миномётчик-артиллерист 104-го'] = {
            id = 'MOR',
            model = {
                'models/finch/jaj/104th/wp/boost.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'mortar_constructor',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 250,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Офицер ИПВ 104-го'] = {
            id = 'IPV',
            model = {
                'models/finch/jaj/104th/wp/tracer.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dp24c',
                    'arccw_k_nade_thermal',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'fort_datapad',
                    'weapon_officerboost_normal',
                    'arccw_eq_designator',
                    'waypoint_designator',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARF'] = {
            id = 'ARF',
            model = {
                'models/finch/jaj/104th/wp/arf.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'sv_datapad',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_flashbang',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_decoy',
                    'arccw_k_nade_sonar',
                    'jet_mk2',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Офицер развед. взвода 104-го'] = {
            id = 'OFCREC',
            model = {
                'models/finch/jaj/104th/wp/mortar.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'sv_datapad',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_flashbang',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_decoy',
                    'arccw_k_nade_sonar',
                    'jet_mk2',
                    'arccw_k_dc17ext_akimbo',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Пехотный снайпер 104-го'] = {
            id = 'SNP',
            model = {
                'models/finch/jaj/104th/base/barc.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_valken38',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'jet_mk2',
                    'arccw_k_nade_smoke',
                    'arccw_sops_vibroknife',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Десантник 104-го'] = {
            id = 'PAR',
            model = {
                'models/finch/jaj/104th/base/ab.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_nade_impact',
                    'arccw_k_nade_smoke',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_sequencecharger',
                    'realistic_hook',
                },
            },
            hp = 270,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Ударный десантник 104-го'] = {
            id = 'DPAR',
            model = {
                'models/finch/jaj/104th/base/ab.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_nade_impact',
                    'arccw_k_nade_smoke',
                    'weapon_squadshield_arm',
                    'arccw_sops_vibroknife',
                    'arccw_cgi_k_dlt16',
                    'realistic_hook',
                },
            },
            hp = 330,
            ar = 55,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARC'] = {
            id = 'ARC',
            model = {
                'models/finch/jaj/104th/wp/arc.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sequencecharger',
                    'arccw_sops_vibroknife',
                    'arccw_k_dc17ext_akimbo',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_sonar',
                    'weapon_squadshield_arm',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'defuser_bomb',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир взвода особых задач 104-го'] = {
            id = 'COMRST',
            model = {
                'models/finch/jaj/104th/wp/nines.mdl',
                'models/finch/vrp/evo/104ce/hellwolf.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sequencecharger',
                    'arccw_sops_vibroknife',
                    'weapon_squadshield_arm',
                    'weapon_officerboost_normal',
                    'arccw_cgi_k_dc15x',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'defuser_bomb',
                    'realistic_hook',
                    'arccw_k_launcher_plx1',
                    'mortar_range_finder',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['EVO боец 104-го'] = {
            id = 'EVO',
            model = {
                'models/finch/vrp/evo/104ce/finch.mdl',
                'models/finch/jaj/104th/wp/jet.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_thermite',
                    'arccw_k_nade_smoke',
                    'cw_flamethrower',
                    'arccw_k_nade_sequencecharger',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_dioxis',
                    'arccw_k_nade_bacta',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 270,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир EVO 104-го'] = {
            id = 'COMEVO',
            model = {
                'models/finch/vrp/evo/104ce/warwick.mdl',
                'models/finch/jaj/104th/wp/jet.mdl',
            },
           weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_thermite',
                    'arccw_k_nade_smoke',
                    'cw_flamethrower',
                    'arccw_k_nade_sequencecharger',
                    'arccw_sops_vibroknife',
                    'weapon_squadshield_arm',
                    'arccw_k_nade_dioxis',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 270,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир 104-го батальона'] = {
            id = 'COMBAT',
            model = {
                'models/finch/jaj/104th/wp/comet.mdl',
                'models/finch/vrp/evo/104ce/barbatos.mdl',
            },
           weapon = {
                default = {
                    'arccw_cgi_k_dc17_revolver',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_westarm5',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_cgi_k_z6adv',
                    'arccw_cgi_k_akimbo_dc17_ext',
                    'weapon_officerboost_laststand',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                    'realistic_hook',
                    'mortar_range_finder',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Медик ARF 104-го батальона'] = {
            id = 'ARFM',
            model = {
                'models/finch/jaj/104th/wp/arf.mdl',
            },
           weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_cgi_k_dc15x',
                    'jet_mk2',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_sonar',
                    'weapon_defibrillator',
                    'arccw_k_nade_bacta',
                    'weapon_bactainjector',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Медик Десантник 104-го батальона'] = {
            id = 'PARM',
            model = {
                'models/finch/jaj/104th/base/ab.mdl',
            },
           weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_sops_vibroknife',
                    'arccw_k_nade_smoke',
                    'jet_mk5',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'realistic_hook',
                },
            },
            hp = 270,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = '104-й Батальон'
})

TEAM_CTRP = NextRP.createJob('Боец КГ', {
    id = 'cg',
    model = {'models/sg/trooper.mdl'},
    color = Color(255,0,0),
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            sortOrder = 1,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Клон Рекрут',
            whitelist = false,
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 3,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 3,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 7,
            model = {
                'models/sg/trooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_nade_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Старший Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 13,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 15,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['СС'] = {
            sortOrder = 16,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = true,
        },
        ['SCC'] = {
            sortOrder = 17,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Старший Клон-Коммандер',
            whitelist = true,
        },
        ['MC'] = {
            sortOrder = 17,
            model = {
                'models/sg/officer.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            fullRank = 'Маршал коммандер',
            whitelist = true,
        },
    },
    flags = {
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/sg/medic.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dp23',
                    'arccw_k_dc15s',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_med_scanner',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Дроид OOM'] = {
            id = 'OOM',
            model = {
                'models/player/roger/rb1_battledroid/assault/b1_battledroid_assault.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_coruscantguardshield',
                    'fort_datapad',
                },
            },
            hp = 250,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Пилот'] = {
            id = 'PIL',
            model = {
                'models/sg/pilot.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dp23',
                    'arccw_k_nade_thermal',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Клон-следователь'] = {
            id = 'SLED',
            model = {
                'models/sg/arfk9.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15x',
                    'arccw_k_dc17ext_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'realistic_hook',
                    'weapon_lvsrepair',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                    'weapon_bactainjector',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ГБР'] = {
            id = 'GBR',
            model = {
                'models/sg/heavy.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_dc17ext_akimbo',
                    'arccw_k_nade_thermal',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'jet_mk5',
                    'realistic_hook',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                    'arccw_cgi_k_z6adv',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Агент Гвардии'] = {
            id = 'AGNT',
            model = {
                'models/sg/riot.mdl',
                'models/navy/gnavyengineer.mdl',
                'models/knyajepack/197th_pack/197th_trooper.mdl',
                'models/55th/ph2/trooper/55th_trp.mdl',
                'models/finch/jaj/104th/wp/trooper.mdl',
                'models/51stcompany/trooper.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_nt242',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_launcher_rps6',
                    'weapon_lvsrepair',
                    'defuser_bomb',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_med_scanner',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            hp = 250,
            ar = 50,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARC'] = {
            id = 'ARC',
            model = {
                'models/sg/arc.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                    'weapon_bactainjector',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир КГ'] = {
            id = 'COMBAT',
            model = {
                'models/sg/fox.mdl',
            },
           weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'jet_mk5',
                    'arccw_k_dc15s',
                    'arccw_k_dc15a',
                    'arccw_k_launcher_rps6',
                    'arccw_k_dc17_akimbo',
                    'arccw_k_coruscantguardshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'weapon_lvsrepair',
                    'fort_datapad',
                    'realistic_hook',
                    'jet_mk5',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_stun',
                },
            },
            hp = 400,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = 'Корусантская Гвардия'
})

TEAM_197TH = NextRP.createJob('Боец 197-го', {
    id = '197th',
    model = {'models/knyajepack/197th_pack/197th_trooper.mdl'},
    color = Color(127,143,166),
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            sortOrder = 1,
            model = {
                'models/knyajepack/197th_pack/197th_trooper.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                },
            },
            fullRank = 'Клон Рекрут',
            whitelist = false,
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/knyajepack/197th_pack/197th_trooper.mdl',
                'models/knyajepack/197th_pack/197th_piltrooper.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 3,
            model = {
                'models/knyajepack/197th_pack/197th_trooper.mdl',
                'models/knyajepack/197th_pack/197th_piltrooper.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/knyajepack/197th_pack/197th_trooper.mdl',
                'models/knyajepack/197th_pack/197th_piltrooper.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 3,
            model = {
                'models/knyajepack/197th_pack/197th_trooper.mdl',
                'models/knyajepack/197th_pack/197th_piltrooper.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/knyajepack/197th_pack/197th_sergeant.mdl',
                'models/knyajepack/197th_pack/197th_pilsergeant.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/knyajepack/197th_pack/197th_sergeant.mdl',
                'models/knyajepack/197th_pack/197th_pilsergeant.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/knyajepack/197th_pack/197th_sergeant.mdl',
                'models/knyajepack/197th_pack/197th_pilsergeant.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Сержант',
            whitelist = false,
        },
        ['MSG'] = {
            sortOrder = 7,
            model = {
                'models/knyajepack/197th_pack/197th_sergeant.mdl',
                'models/knyajepack/197th_pack/197th_pilsergeant.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Мастер Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 8,
            model = {
                'models/knyajepack/197th_pack/197th_sergeant.mdl',
                'models/knyajepack/197th_pack/197th_pilleit.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Штаб Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/knyajepack/197th_pack/197th_saper.mdl',
                'models/knyajepack/197th_pack/197th_pilleit.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/knyajepack/197th_pack/197th_leit.mdl',
                'models/knyajepack/197th_pack/197th_pilleit.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/knyajepack/197th_pack/197th_leit.mdl',
                'models/knyajepack/197th_pack/197th_pilleit.mdl',
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/knyajepack/197th_pack/197th_captain.mdl',
                'models/knyajepack/197th_pack/197th_pilcmd.mdl',
                'models/knyajepack/197th_pack/197th_pilcpt.mdl'
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 13,
            model = {
                'models/knyajepack/197th_pack/197th_captain.mdl',
                'models/knyajepack/197th_pack/197th_pilcmd.mdl',
                'models/knyajepack/197th_pack/197th_pilcpt.mdl'
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 15,
            model = {
                'models/knyajepack/197th_pack/197th_captain.mdl',
                'models/knyajepack/197th_pack/197th_pilcmd.mdl',
                'models/knyajepack/197th_pack/197th_pilcpt.mdl'
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Полковник',
            whitelist = false,
        },
        ['CC'] = {
            sortOrder = 16,
            model = {
                'models/knyajepack/197th_pack/197th_captain.mdl',
                'models/knyajepack/197th_pack/197th_pilcmd.mdl',
                'models/knyajepack/197th_pack/197th_pilcpt.mdl'
            },
            hp = 250,
            ar = 30,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'fort_datapad',
                    'sv_datapad',
                    'keypad_cracker',
                    'weapon_lvsrepair',
                    'jet_mk2'
                },
            },
            fullRank = 'Клон Коммандер',
            whitelist = false,
        },
     },
     flags = {
        ['PIL X'] = {
            id = 'PIL X',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL REC'] = {
            id = 'PIL REC',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['D SCT'] = {
            id = 'D SCT',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL SCT'] = {
            id = 'PIL SCT',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['D MG'] = {
            id = 'D MG',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL MA'] = {
            id = 'PIL MA',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['D MV'] = {
            id = 'D MV',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL MV'] = {
            id = 'PIL MV',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL AKA'] = {
            id = 'PIL AKA',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL INS'] = {
            id = 'PIL INS',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL INSS'] = {
            id = 'PIL INSS',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL V'] = {
            id = 'PIL V',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL CCO'] = {
            id = 'PIL CCO',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['PIL CO'] = {
            id = 'PIL CO',
            model = {
                'models/knyajepack/197th_pack/197th_piltrooper.mdl'
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 100,
            ar = 0,
            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
    },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = '197-й Инженерно Пилотный Корпус'
})

TEAM_26TH = NextRP.createJob('Боец 26-й роты', {
    id = '26th',
    model = {'models/55th/ph2/trooper/55th_trp.mdl'},
    color = Color(127,143,166),
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            sortOrder = 1,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                },
            },
            fullRank = 'Клон Рекрут',
            whitelist = false,
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                },
            },
            fullRank = 'Клон Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 3,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                },
            },
            fullRank = 'Клон Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                },
            },
            fullRank = 'Клон Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 3,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                },
            },
            fullRank = 'Клон Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                },
            },
            fullRank = 'Клон Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Сержант',
            whitelist = false,
        },
        ['MSG'] = {
            sortOrder = 7,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Мастер Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 8,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Штаб Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 45,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15le',
                    'arccw_k_sb2',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                    'weapon_officerboost_normal',
                },
            },
            fullRank = 'Клон Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 13,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'realistic_hook',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 14,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15le',
                    'arccw_k_sb2',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                    'weapon_officerboost_normal',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['СС'] = {
            sortOrder = 15,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15le',
                    'arccw_k_sb2',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                    'weapon_officerboost_normal',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = true,
        },
        ['SCC'] = {
            sortOrder = 16,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15le',
                    'arccw_k_sb2',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                    'weapon_officerboost_normal',
                },
            },
            fullRank = 'Старший Клон-Коммандер',
            whitelist = true,
        },
        ['MC'] = {
            sortOrder = 17,
            model = {
                'models/reizer_models/clones/88th_p2/88th_trp/88th_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_aa_trp/88th_aa_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_fortem/88th_fortem.mdl',
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc15le',
                    'arccw_k_sb2',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                    'weapon_officerboost_normal',
                },
            },
            fullRank = 'Маршал коммандер',
            whitelist = true,
        },
     },
     flags = {
        ['PIL'] = {
            id = 'PIL',
            model = {
                'models/reizer_models/clones/88th_p2/88th_pilots/88th_pilot_01b.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_sb2',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'sv_datapad',
                    'weapon_lvsrepair',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 200,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['SPEC'] = {
            id = 'SPEC',
            model = {
                'models/reizer_models/clones/88th_p2/88th_specops/88th_specops3.mdl',
                'models/reizer_models/clones/88th_p2/88th_arc_specops1/88th_arc_specops1.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc19',
                    'arccw_k_dc15x',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'waypoint_designator',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'weapon_cuff_elastic',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 200,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['MED'] = {
            id = 'MED',
            model = {
                'models/reizer_models/clones/88th_p2/88th_medic/88th_medic.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dp24c',
                    'weapon_med_scanner',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_bactanade',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_flashbang',
                    'arccw_k_nade_smoke',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 200,
            ar = 45,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ENG'] = {
            id = 'ENG',
            model = {
                'models/reizer_models/clones/88th_p2/88th_custom_08/88th_c_08.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_nade_shock',
                    'arccw_k_dc15s',
                    'arccw_k_sb2',
                    'fort_datapad',
                    'sv_datapad',
                    'turret_placer',
                    'defuser_bomb',
                    'weapon_lvsrepair',
                    'weapon_squadshield_arm',
                    'arccw_k_nade_antitankmine',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                    'arccw_k_nade_detonite',
                },
                default = {
                    'arccw_k_dc17ext',
                },
            },
            hp = 250,
            ar = 55,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['HT'] = {
            id = 'HT',
            model = {
                'models/reizer_models/clones/88th_p2/88th_heavy/88th_heavy.mdl',
                'models/reizer_models/clones/88th_p2/88th_eod_custom_01/88th_eod_custom_01.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_cgi_k_z6adv',
                    'arccw_k_sb2',
                    'arccw_k_republicshield',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_impact',
                    'arccw_k_nade_c14',
                    'arccw_cgi_k_212shield',
                },
                default = {
                    'arccw_cgi_k_akimbo_dc17_heavy',
                },
            },
            hp = 450,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['DES'] = {
            id = 'DES',
            model = {
                'models/reizer_models/clones/88th_p2/88th_para_trp/88th_para_trp.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_dp24c',
                    'realistic_hook',
                    'jet_mk1',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 235,
            ar = 55,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['SEALS'] = {
            id = 'SEALS',
            model = {
                'models/reizer_models/clones/88th_p2/88th_aqua_trp/88th_aqua_trp.mdl',
                'models/reizer_models/clones/88th_p2/88th_arc_aqua/88th_arc_aqua.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_sops_vibroknife',
                    'arccw_k_dc17ext_akimbo',
                    'arccw_cgi_k_e9d',
                    'arccw_k_sb2',
                    'weapon_bactainjector',
                    'waypoint_designator',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c25',
                    'realistic_hook',
                },
                default = {
                    'arccw_cgi_k_akimbo_dc17_heavy',
                },
            },
            hp = 245,
            ar = 55,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['JET'] = {
            id = 'JET',
            model = {
                'models/reizer_models/clones/88th_p2/88th_jet_cpt/88th_jet_cpt.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_launcher_smartlauncher',
                    'jet_mk2',
                    'realistic_hook',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_stun',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 200,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['CMD'] = {
            id = 'CMD',
            model = {
                'models/reizer_models/clones/88th_p2/88th_cpt2/88th_cpt2.mdl',
                'models/reizer_models/clones/88th_p2/88th_odi/88th_odi.mdl',
                'models/reizer_models/clones/88th_p2/88th_veteran/88th_veteran.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15le',
                    'arccw_k_sb2',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'weapon_cuff_elastic',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 400,
            ar = 55,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARF'] = {
            id = 'ARF',
            model = {
                'models/reizer_models/clones/88th_p2/88th_arf/88th_arf.mdl',
                'models/reizer_models/clones/88th_p2/88th_arf/88th_arf_camo1.mdl',
                'models/reizer_models/clones/88th_p2/88th_arf/88th_arf_camo2.mdl',
                'models/reizer_models/clones/88th_p2/88th_arf/88th_arf_camo3.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_sops_republic_t702',
                    'waypoint_designator',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_flashbang',
                    'arccw_k_nade_smoke',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 200,
            ar = 45,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARC'] = {
            id = 'ARC',
            model = {
                'models/reizer_models/clones/88th_p2/88th_arc/88th_arc.mdl',
                'models/reizer_models/clones/88th_p2/88th_arc_arf/88th_arc_arf.mdl',
                'models/reizer_models/clones/88th_p2/88th_arc_freedom/88th_arc_freedom.mdl',
                'models/reizer_models/clones/88th_p2/88th_arc_specops1/88th_arc_specops1.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dp24c',
                    'arccw_k_dc15x',
                    'waypoint_designator',
                    'jet_mk5',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                    'arccw_k_sb2',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['MERC'] = {
            id = 'MERC',
            model = {
                'models/cgi_roge_pm/shanni.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_sops_republic_773firepuncher',
                    'weapon_vibrosword',
                    'jet_mk5',
                    'waypoint_designator',
                    'weapon_officerboost_laststand',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_med_scanner',
                    'defuser_bomb',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_flashbang',
                    'arccw_k_nade_sonar',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 250,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ADMERC'] = {
            id = 'ADMERC',
            model = {
                'models/cgi_roge_pm/shanni_yellow.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_cgi_k_dc15a',
                    'arccw_k_dp24c',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_flashbang',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
                default = {
                    'arccw_cgi_k_dc17_stun',
                },
            },
            hp = 250,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Agent Himera'] = {
            id = 'Agent Himera',
            model = {
                'models/rusya/wiz/wiz_commando.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_sops_galactic_galaar15',
                    'arccw_k_dp24c',
                    'arccw_iqa11',
                    'waypoint_designator',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 250,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Salam'] = {
            id = 'SLM',
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 500,
            ar = 70,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Alpha 45'] = {
            id = 'Alpha 45',
            model = {
                'models/pinky/clone/arc_omen.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dp24c',
                    'arccw_k_dc15x',
                    'arccw_k_launcher_rps6',
                    'arccw_sops_republic_t702',
                    'arccw_sops_republic_z6x',
                    'waypoint_designator',
                    'jet_mk5',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        
    },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = '26-я рота «Ангелы»'
})

TEAM_26THRAZ = NextRP.createJob('ARF Raz', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = '26thraz', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/212th_arfcmd/212th_arfcmd.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'PVT',
    ranks = {
        ['PVT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                        'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {'arccw_k_dc17s_dual'}, -- При спавне
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                } -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Рядовой',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['PV2'] = {
            sortOrder = 2,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 4,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 5,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 6,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 7,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Сержант',
            whitelist = false,
        },
        ['MSG'] = {
            sortOrder = 7,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Мастер Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 8,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Штаб Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 13,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 14,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['СС'] = {
            sortOrder = 15,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = true,
        },
        ['SCC'] = {
            sortOrder = 16,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Старший Клон-Коммандер',
            whitelist = true,
        },
        ['MC'] = {
            sortOrder = 17,
            model = {
                'models/212th_arfcmd/212th_arfcmd.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s_dual',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_sops_republic_t702',
                    'arccw_cgi_k_dc19',
                    'arccw_k_nade_thermal',
                    'arccw_cgi_k_rps6',
                    'jet_mk5',
                    'realistic_hook',
                },
            },
            fullRank = 'Маршал коммандер',
            whitelist = true,
        },
     },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Сводная рота'
})

TEAM_MCENI = NextRP.createJob('ENG Enigma', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'mceni', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/sl_juggernaut/sl_juggernaut.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'PVT',
    ranks = {
        ['PVT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                        'models/cxtrooper/models/cxtrooper.mdl',
                        'models/51stcompany/engineertrooper.mdl',
                        'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {'arccw_k_dc17s'}, -- При спавне
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                } -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Рядовой',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['PV2'] = {
            sortOrder = 2,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 4,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 5,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 6,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 7,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Сержант',
            whitelist = false,
        },
        ['MSG'] = {
            sortOrder = 7,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Мастер Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 8,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Штаб Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 13,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 14,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['СС'] = {
            sortOrder = 15,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = true,
        },
        ['SCC'] = {
            sortOrder = 16,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Старший Клон-Коммандер',
            whitelist = true,
        },
        ['MC'] = {
            sortOrder = 17,
            model = {
                'models/cxtrooper/models/cxtrooper.mdl',
                'models/51stcompany/engineertrooper.mdl',
                'models/sl_juggernaut/sl_juggernaut.mdl',
            },
            hp = 200,
            ar = 60,
            weapon = {
                default = {
                    'arccw_k_dc17s',
                },
                ammunition = {
                    'arccw_k_dp24c',
                    'arccw_cgi_k_dc15x',
                    'arccw_k_nade_detonite',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'sv_datapad',
                },
            },
            fullRank = 'Маршал коммандер',
            whitelist = true,
        },
     },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Сводная рота'
})

TEAM_SALAM = NextRP.createJob('HT Salam', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'salam', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/aussiwozzi/cgi/md/212_re_imp.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'PVT',
    ranks = {
        ['PVT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                        'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500, -- ХП
            ar = 70, -- Армор
            weapon = { -- Оружие
                default = {'arccw_k_dc17ext_akimbo'}, -- При спавне
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                } -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Рядовой',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['PV2'] = {
            sortOrder = 2,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 4,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 5,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 6,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 7,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Сержант',
            whitelist = false,
        },
        ['MSG'] = {
            sortOrder = 7,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Мастер Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 8,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Штаб Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 13,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 14,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['СС'] = {
            sortOrder = 15,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = true,
        },
        ['SCC'] = {
            sortOrder = 16,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Старший Клон-Коммандер',
            whitelist = true,
        },
        ['MC'] = {
            sortOrder = 17,
            model = {
                'models/aussiwozzi/cgi/md/212_re_imp.mdl',
            },
            hp = 500,
            ar = 70,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_sb2',
                    'arccw_sops_empire_tl50',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_iqa11',
                    'jet_mk6',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
            },
            fullRank = 'Маршал коммандер',
            whitelist = true,
        },
     },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Сводная рота'
})

TEAM_SHDW = NextRP.createJob('Корпус Теней', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'shdw', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/aussiwozzi/cgi/base/shadow_trooper.mdl'},
    color = Color(0, 0, 0),
    -- Звания
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/aussiwozzi/cgi/base/shadow_trooper.mdl'
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = { -- Оружие
                default = {
                    'arccw_k_dc17_stun',
                }, -- При спавне
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
               }, -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Рекрут',
            speed = {500, 500}, -- Значения скорости: {walkSpeed, runSpeed}
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/aussiwozzi/cgi/base/shadow_trooper.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 3,
            model = {
                'models/aussiwozzi/cgi/base/shadow_trooper.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/aussiwozzi/cgi/base/shadow_trooper.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 3,
            model = {
                'models/aussiwozzi/cgi/base/shadow_trooper.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/aussiwozzi/cgi/base/shadow_trooper.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/aussiwozzi/cgi/base/shadow_officer.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/aussiwozzi/cgi/base/shadow_officer.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_cgi_k_dc19',
                    'arccw_sops_republic_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Сержант',
            whitelist = false,
        },
        ['MSG'] = {
            sortOrder = 7,
            model = {
                'models/aussiwozzi/cgi/base/shadow_officer.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_cgi_k_dc19',
                    'arccw_sops_republic_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Мастер Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 8,
            model = {
                'models/aussiwozzi/cgi/base/shadow_officer.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_cgi_k_dc19',
                    'arccw_sops_republic_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Штаб Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/aussiwozzi/cgi/base/shadow_officer.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_cgi_k_dc19',
                    'arccw_sops_republic_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/aussiwozzi/cgi/base/shadow_officer.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_cgi_k_dc19',
                    'arccw_sops_republic_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/aussiwozzi/cgi/base/shadow_officer.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_cgi_k_dc19',
                    'arccw_sops_republic_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                    'realistic_hook',
                },
            },
            fullRank = 'Клон Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/aussiwozzi/cgi/base/shadow_commander.mdl',
            },
            hp = 280, -- ХП
            ar = 40, -- Армор
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'arccw_k_sb2',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'weapon_defibrillator',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_officerboost_normal',
                },
            },
            fullRank = 'Клон Капитан',
            whitelist = false,
        },
    },
    flags = {
        ['ARF'] = {
            id = 'ARF',
            model = {
                'models/aussiwozzi/cgi/base/shadow_arf.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_dc17ext',
                    'arccw_k_dc15x',
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17_stun',
                    'realistic_hook',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                },
            },
            hp = 250,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ENG'] = {
            id = 'ENG',
            model = {
                'models/aussiwozzi/cgi/base/shadow_barc.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_k_dc17ext',
                    'realistic_hook',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17ext',
                },
            },
            hp = 270,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['MED'] = {
            id = 'MED',
            model = {
                'models/aussiwozzi/cgi/base/shadow_medic.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17ext',
                    'realistic_hook',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['PIL'] = {
            id = 'PIL',
            model = {
                'models/aussiwozzi/cgi/base/shadow_pilot.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'sv_datapad',
                    'realistic_hook',
                },
            },
            hp = 230,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARC'] = {
            id = 'ARC',
            model = {
                'models/aussiwozzi/cgi/base/shadow_arc.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_dc17ext_akimbo',
                    'arccw_k_launcher_plx1',
                    'arccw_k_westarm5',
                    'arccw_k_nade_bacta',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'sv_datapad',
                    'realistic_hook',
                    'jet_mk5',
                },
            },
            hp = 550,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['HT'] = {
            id = 'HT',
            model = {
                'models/aussiwozzi/cgi/base/shadow_trooper.mdl',
            },
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                },
                ammunition = {
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'arccw_sops_republic_dc19',
                    'arccw_cgi_k_dc19',
                    'arccw_k_z6',
                    'arccw_k_launcher_rps6',
                    'realistic_hook',
                },
            },
            hp = 400,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        }
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 100,
    runspead = 250,
    -- Категория
    category = 'Корпус Теней'
})

TEAM_BLADE = NextRP.createJob('BladeWolf', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'blade', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/mgrr/flaymi/bladewolff.mdl'},
    color = Color(0, 0, 0),
    -- Звания
    default_rank = 'Blade',
    ranks = {
        ['Blade'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/mgrr/flaymi/bladewolff.mdl'
            },
            hp = 250, -- ХП
            ar = 75, -- Армор
            weapon = { -- Оружие
                default = {
                    'weapon_standardswordart',
                    'weapon_fists',
                    'arccw_sops_vibroknife',}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Blade Wolfs',
            speed = {500, 500}, -- Значения скорости: {walkSpeed, runSpeed}
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = true,
    walkspead = 100,
    runspead = 250,
    -- Категория
    category = 'Корпус Теней'
})

TEAM_51TH = NextRP.createJob('Боец 51-й роты', {
    id = '51th',
    model = {'models/55th/ph2/trooper/55th_trp.mdl'},
    color = Color(127,143,166),
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            sortOrder = 1,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                },
            },
            fullRank = 'Клон Рекрут',
            whitelist = false,
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                },
            },
            fullRank = 'Клон Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 3,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                },
            },
            fullRank = 'Клон Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                },
            },
            fullRank = 'Клон Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 3,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                },
            },
            fullRank = 'Клон Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                },
            },
            fullRank = 'Клон Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/sergeanttrooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                    'arccw_k_republicshield',
                },
            },
            fullRank = 'Клон Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/sergeanttrooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15s_grenadier',
                    'arccw_k_nade_impact',
                    'arccw_k_republicshield',
                },
            },
            fullRank = 'Клон Сержант',
            whitelist = false,
        },
        ['MSG'] = {
            sortOrder = 7,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/sergeanttrooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Мастер Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 8,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/sergeanttrooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Штаб Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/officertrooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/officertrooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/51stcompany/trooper.mdl',
                'models/51stcompany/officertrooper.mdl',
                'models/51stcompany/snowtrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_akimbo',
                },
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dc17_stun',
                    'arccw_k_dc15a_grenadier',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_officerboost_normal',
                    'waypoint_designator',
                },
            },
            fullRank = 'Клон Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/51stcompany/commandertrooper.mdl',
            },
            hp = 250,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dp24c',
                    'arccw_k_dc15x',
                    'weapon_officerboost_laststand',
                    'waypoint_designator',
                    'jet_mk5',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_sonar',
                    'arccw_k_nade_c14',
                    'realistic_hook',
                    'weapon_officerboost_normal',
                },
            },
            fullRank = 'Клон Капитан',
            whitelist = false,
        },
     },
     flags = {
        ['Пилот'] = {
            id = 'PIL',
            model = {
                'models/51stcompany/pilottrooper.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_shock',
                    'arccw_k_nade_flashbang',
                    'sv_datapad',
                    'weapon_lvsrepair',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
    },
    ['Медик'] = {
            id = 'MED',
            model = {
                'models/51stcompany/medictrooper.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_dp24c',
                    'weapon_med_scanner',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_bactanade',
                    'arccw_k_nade_bacta',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/51stcompany/engineertrooper.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_nade_shock',
                    'arccw_k_dc15s',
                    'arccw_k_dp24c',
                    'fort_datapad',
                    'sv_datapad',
                    'turret_placer',
                    'defuser_bomb',
                    'weapon_lvsrepair',
                    'weapon_squadshield_arm',
                    'arccw_k_nade_antitankmine',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_thermal',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17ext',
                },
            },
            hp = 250,
            ar = 40,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Тяж боец'] = {
            id = 'HT',
            model = {
                'models/51stcompany/heavygunnertrooper.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_z6adv',
                    'arccw_k_republicshield',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_c14',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 400,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Огнеметчик'] = {
            id = 'FT',
            model = {
                'models/51stcompany/heavygunnertrooper.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_dp24',
                    'cw_flamethrower',
                    'arccw_k_republicshield',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_c14',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 280,
            ar = 50,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },    
        ['Скаут'] = {
            id = 'SCT',
            model = {
                'models/51stcompany/arf(scout)troopermontero.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_dp24',
                    'arccw_k_dc15x',
                    'waypoint_designator',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_flashbang',
                    'arccw_k_nade_smoke',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 200,
            ar = 30,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARF'] = {
            id = 'ARF',
            model = {
                'models/51stcompany/arf(scout)trooper.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15s',
                    'arccw_k_valken38',
                    'waypoint_designator',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_flashbang',
                    'arccw_k_nade_smoke',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc17',
                },
            },
            hp = 200,
            ar = 35,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ARC'] = {
            id = 'ARC',
            model = {
                'models/51stcompany/arctrooper.mdl'
            },
            weapon = {
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dp24c',
                    'arccw_k_dc15x',
                    'waypoint_designator',
                    'jet_mk5',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'arccw_k_nade_c14',
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
            },
            hp = 500,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        }
    },

    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = '51-я рота'
})

TEAM_SOSO = NextRP.createJob('Боец ARC Blue Flame', {
    id = 'soso',
    model = {'models/angel/angel.mdl'},
    color = Color(127,143,166),
    default_rank = 'PVT',
    ranks = {
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                },
            },
            fullRank = 'Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 3,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 3,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 7,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Старший Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 12,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 12,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['CC'] = {
            sortOrder = 12,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = false,
        },
        ['MC'] = {
            sortOrder = 12,
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Маршал-Коммандер',
            whitelist = false,
        },
    },
    flags = {
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
                'models/navy/gnavymedic.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                },
            },
            hp = 530,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир'] = {
            id = 'COM',
            model = {
                'models/enot/enot.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'arccw_k_nade_thermal',
                    'arccw_k_launcher_smartlauncher',
                    'arccw_k_nade_sequencecharger',
                },
            },
            hp = 550,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'weapon_squadshield_arm',
                    'weapon_lvsrepair',
                    'arccw_k_nade_bacta',
                    'arccw_k_dp23',
                    'turret_placer',
                    'fort_datapad',
                    'sv_datapad',
                },
            },
            hp = 530,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Взломщик'] = {
            id = 'HAC',
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_nade_thermal',
                    'arccw_k_launcher_smartlauncher',
                    'keypad_cracker',
                    'sv_datapad',
                },
            },
            hp = 530,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Подрывник'] = {
            id = 'DEM',
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'arccw_k_nade_thermal',
                    'arccw_k_launcher_smartlauncher',
                    'arccw_k_nade_sequencecharger',
                    'arccw_eq_mortar',
                    'arccw_eq_designator',
                    'fort_datapad',
                },
            },
            hp = 550,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Разведчик'] = {
            id = 'SCT',
            model = {
                'models/angel/angel.mdl',
                'models/border/border.mdl',
                'models/enarc/enarc.mdl',
                'models/shadow/shadow.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'realistic_hook',
                    'arccw_k_nade_thermal',
                    'arccw_k_dc15x',
                    'fort_datapad',
                },
            },
            hp = 530,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = 'ARC | Blue Flame'
})

TEAM_THETA = NextRP.createJob('Боец ARC Theta', {
    id = 'theta',
    model = {'models/angel/angel.mdl'},
    color = Color(127,143,166),
    default_rank = 'PVT',
    ranks = {
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                },
            },
            fullRank = 'Рядовой',
            whitelist = false,
        },
        ['PV2'] = {
            sortOrder = 3,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Рядовой Второго Класса',
            whitelist = false,
        },
        ['PV1'] = {
            sortOrder = 3,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Рядовой Первого Класса',
            whitelist = false,
        },
        ['SPC'] = {
            sortOrder = 3,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Специалист',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 7,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Старший Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 12,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 12,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['CC'] = {
            sortOrder = 12,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = false,
        },
        ['MC'] = {
            sortOrder = 12,
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            hp = 530,
            ar = 60,
            weapon = {
                default = {
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'weapon_cuff_elastic',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                },
            },
            fullRank = 'Маршал-Коммандер',
            whitelist = false,
        },
    },
    flags = {
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
                'models/navy/gnavymedic.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                },
            },
            hp = 530,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_dc15s',
                    'arccw_k_nade_thermal',
                    'weapon_squadshield_arm',
                    'weapon_lvsrepair',
                    'arccw_k_nade_bacta',
                    'arccw_k_dp23',
                    'turret_placer',
                    'fort_datapad',
                    'sv_datapad',
                },
            },
            hp = 530,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Взломщик'] = {
            id = 'HAC',
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_nade_thermal',
                    'arccw_k_launcher_smartlauncher',
                    'keypad_cracker',
                    'sv_datapad',
                },
            },
            hp = 530,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Подрывник'] = {
            id = 'DEM',
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'arccw_k_z6adv',
                    'arccw_k_nade_thermal',
                    'arccw_k_launcher_smartlauncher',
                    'arccw_k_nade_sequencecharger',
                    'arccw_eq_mortar',
                    'arccw_eq_designator',
                    'fort_datapad',
                },
            },
            hp = 550,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Разведчик'] = {
            id = 'SCT',
            model = {
                'models/arcspers/arcane.mdl',
                'models/marauder/keen_arc.mdl',
                'models/satoru/cgi/arcsquad/jaw.mdl',
                'models/satoru/cgi/arcsquad/juck.mdl',
                'models/satoru/cgi/arcsquad/vexer.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_k_westarm5',
                    'arccw_k_dc17ext_akimbo',
                    'jet_mk5',
                    'realistic_hook',
                    'arccw_k_nade_thermal',
                    'arccw_k_dc15x',
                    'fort_datapad',
                },
            },
            hp = 530,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Vairo'] = {
            id = 'Vairo',
            model = {
                'models/chet/custom/arc_lu/arc_lu.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                    'arccw_sops_republic_t702',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'jet_mk5',
                    'arccw_k_westarm5',
                    'arccw_sw_rocket_rps6',
                    'arccw_impact_grenade',
                    'arccw_sops_vibroknife',
                    'weapon_cuff_elastic',
                    'arccw_k_nade_c14',
                    'fort_datapad',
                    'weapon_squadshield_arm',
                    'arccw_k_dc17_stun',
                    'fort_datapad',
                },
            },
            hp = 550,
            ar = 65,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = 'ARC | Theta'
})

TEAM_RCRP = NextRP.createJob('Республиканский коммандос', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'rcrp', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/aussiwozzi/cgi/commando/rc_blue_squad.mdl'
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'RC',
    ranks = {
        ['RC'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/aussiwozzi/cgi/commando/rc_blue_squad.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_demo.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_leader.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_sniper.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_tech.mdl',
                'models/aussiwozzi/cgi/commando/rc_junglestriker.mdl',
                'models/aussiwozzi/cgi/commando/rc_nightops.mdl',
                'models/aussiwozzi/cgi/commando/rc_plain.mdl',
                'models/aussiwozzi/cgi/commando/rc_urbanfighter.mdl',
                'models/aussiwozzi/cgi/commando/rc_ranger.mdl',
                'models/aussiwozzi/cgi/commando/rc_recon.mdl',
                'models/aussiwozzi/cgi/commando/rc_sarge.mdl',
            },
            hp = 500, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                }, -- При спавне
                ammunition = {
                } -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Республиканский коммандос',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        }
    },
    flags = {
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/aussiwozzi/cgi/commando/rc_blue_squad.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_demo.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_leader.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_sniper.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_tech.mdl',
                'models/aussiwozzi/cgi/commando/rc_junglestriker.mdl',
                'models/aussiwozzi/cgi/commando/rc_nightops.mdl',
                'models/aussiwozzi/cgi/commando/rc_plain.mdl',
                'models/aussiwozzi/cgi/commando/rc_urbanfighter.mdl',
                'models/aussiwozzi/cgi/commando/rc_ranger.mdl',
                'models/aussiwozzi/cgi/commando/rc_recon.mdl',
                'models/aussiwozzi/cgi/commando/rc_sarge.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/aussiwozzi/cgi/commando/rc_blue_squad.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_demo.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_leader.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_sniper.mdl',
                'models/aussiwozzi/cgi/commando/rc_hope_tech.mdl',
                'models/aussiwozzi/cgi/commando/rc_junglestriker.mdl',
                'models/aussiwozzi/cgi/commando/rc_nightops.mdl',
                'models/aussiwozzi/cgi/commando/rc_plain.mdl',
                'models/aussiwozzi/cgi/commando/rc_urbanfighter.mdl',
                'models/aussiwozzi/cgi/commando/rc_ranger.mdl',
                'models/aussiwozzi/cgi/commando/rc_recon.mdl',
                'models/aussiwozzi/cgi/commando/rc_sarge.mdl',
            },
            weapon = {
                ammunition = {
                },
                default = {
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 150,
    runspead = 300,
    Salary = 100,
    -- Категория
    category = 'Республиканский коммандос'
})

TEAM_RCWF = NextRP.createJob('Werewolf', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'rcww', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/zekora/zekora.mdl',
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'RC',
    ranks = {
        ['RC'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/zekora/zekora.mdl',
            },
            hp = 500, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                    'arccw_k_dc15sa',
                }, -- При спавне
                ammunition = {
                    'arccw_k_dc17m_rifle_republic',
                    'arccw_k_dc17m_shotgun_republic',
                    'arccw_k_dc17m_sniper_republic',
                    'realistic_hook',
                } -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Республиканский коммандос отряда Werewolf',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        }
    },
    flags = {
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/manik/manik.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc17m_rifle_republic',
                    'arccw_k_dc17m_shotgun_republic',
                    'arccw_k_dc17m_sniper_republic',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'arccw_k_nade_bacta',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc15sa',
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Подрывник'] = {
            id = 'DEM',
            model = {
                'models/earnaut/earnaut.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc17m_rifle_republic',
                    'arccw_k_dc17m_shotgun_republic',
                    'arccw_k_dc17m_sniper_republic',
                    'arccw_k_launcher_plx1',
                    'arccw_k_launcher_hh12',
                    'arccw_k_nade_impact',
                    'arccw_k_nade_c14',
                    'arccw_k_nade_antitankmine',
                    'defuser_bomb',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc15sa',
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Командир'] = {
            id = 'CMD',
            model = {
                'models/krei/krei.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc17m_rifle_republic',
                    'arccw_k_dc17m_shotgun_republic',
                    'arccw_k_dc17m_sniper_republic',
                    'realistic_hook',
                    'weapon_marker',
                    'weapon_officerboost_normal',
                },
                default = {
                    'arccw_k_dc15sa',
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Снайпер'] = {
            id = 'SNP',
            model = {
                'models/zekora/zekora.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc17m_rifle_republic',
                    'arccw_k_dc17m_shotgun_republic',
                    'arccw_k_dc17m_sniper_republic',
                    'realistic_hook',
                },
                default = {
                    'arccw_k_dc15sa',
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/soundway/soundway.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc17m_rifle_republic',
                    'arccw_k_dc17m_shotgun_republic',
                    'arccw_k_dc17m_sniper_republic',
                    'weapon_lvsrepair',
                    'sv_datapad',
                    'realistic_hook',
                    'comlink_fixingtool',
                    'fort_datapad',
                },
                default = {
                    'arccw_k_dc15sa',
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = true,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 150,
    runspead = 300,
    Salary = 100,
    -- Категория
    category = 'Республиканский коммандос'
})

TEAM_ARCALPHARP = NextRP.createJob('Боец ARC Alpha', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'arcalpharp', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/arcalphasquad/alphatroopersgt.mdl'
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'CPL',
    ranks = {
        ['CPL'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/arcalphasquad/alphatroopersgt.mdl'
            },
            hp = 300, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {
                },
                ammunition = {
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Капрал',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['SGT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/arcalphasquad/alphatroopersgt.mdl'
            },
            hp = 350, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                    'arc9_k_dc17_stun',
                },
                ammunition = {
                    'arc9_k_westarm5',
                    'arc9_k_valken38',
                    'arc9_k_dp23c',
                    'arc9_k_launcher_rps6_republic',
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_sonar',
                    'arc9_k_z6',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arc9_k_nade_bacta',
                    'fort_datapad',
                    'sv_datapad',
                    'defuser_bomb',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'medic_medkit',
                    'weapon_med_scanner',
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Сержант',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['LT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/arcalphasquad/alphatrooperlt.mdl'
            },
            hp = 400, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                    'arc9_k_dc17_stun',
                },
                ammunition = {
                    'arc9_k_westarm5',
                    'arc9_k_valken38',
                    'arc9_k_dp23c',
                    'arc9_k_launcher_rps6_republic',
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_sonar',
                    'arc9_k_z6',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arc9_k_nade_bacta',
                    'fort_datapad',
                    'sv_datapad',
                    'defuser_bomb',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'medic_medkit',
                    'weapon_med_scanner',
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Лейтенант',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['CPT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/arcalphasquad/alphatroopercpt.mdl'
            },
            hp = 500, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                    'arc9_k_dc17_stun',
                },
                ammunition = {
                    'arc9_k_westarm5',
                    'arc9_k_valken38',
                    'arc9_k_dp23c',
                    'arc9_k_launcher_rps6_republic',
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_sonar',
                    'arc9_k_z6',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arc9_k_nade_bacta',
                    'fort_datapad',
                    'sv_datapad',
                    'defuser_bomb',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'medic_medkit',
                    'weapon_med_scanner',
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Капитан',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
            ['Медик'] = {
            id = 'MED',
            model = {
                'models/clone125_baton.mdl',
                'models/navy/gnavymedic.mdl',
            },
            weapon = {
                ammunition = {
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_bactanade',
                    'arc9_k_nade_smoke',
                    'arc9_k_dc17ext_akimbo',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arc9_k_nade_stun',
                    'medic_medkit',
                    'medic_blood',
                    'medic_dosimetr',
                    'medic_ecg_temp',
                    'medic_exam',
                    'medic_nerv_maleol',
                    'medic_ophtalmoscope',
                    'medic_otoscope',
                    'medic_pulseoxymetr',
                    'medic_expresstest_flu',
                    'medic_scapula',
                    'medic_shethoscope',
                    'medic_therm',
                    'medic_tonometr'
                },
                default = {
                    'arc9_k_dc17_stun'
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 150,
    runspead = 300,
    Salary = 100,
    -- Категория
    category = 'ARC | Alpha'
})

TEAM_ARCALPHARPFORDO = NextRP.createJob('Боец ARC Alpha Fordo', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'arcalpharfordo', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/frost/chsv/ordo.mdl'
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'CPL',
    ranks = {
        ['CPL'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/frost/chsv/ordo.mdl'
            },
            hp = 300, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'jet_mk1',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'weapon_bactanade',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'defuser_bomb',
                    'realistic_hook',
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Капрал',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['SGT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/frost/chsv/ordo.mdl'
            },
            hp = 350, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'jet_mk1',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'weapon_bactanade',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'defuser_bomb',
                    'realistic_hook',
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Сержант',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['LT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/frost/chsv/ordo.mdl'
            },
            hp = 400, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'jet_mk1',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'weapon_bactanade',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'defuser_bomb',
                    'realistic_hook',
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Лейтенант',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['CPT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/frost/chsv/ordo.mdl'
            },
            hp = 500, -- ХП
            ar = 60, -- Армор
            weapon = { -- Оружие
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'jet_mk1',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'weapon_bactanade',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'defuser_bomb',
                    'realistic_hook',
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Капитан',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
            ['Медик'] = {
            id = 'MED',
            model = {
                'models/frost/chsv/ordo.mdl',
            },
            weapon = { -- Оружие
                default = {
                    'arccw_k_dc17ext_akimbo',
                },
                ammunition = {
                    'arccw_k_westarm5',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_smoke',
                    'jet_mk1',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'weapon_bactanade',
                    'fort_datapad',
                    'weapon_lvsrepair',
                    'defuser_bomb',
                    'realistic_hook',
                },
            },
            hp = 500,
            ar = 60,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = false,
        },
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 150,
    runspead = 300,
    Salary = 100,
    -- Категория
    category = 'ARC | Alpha'
})

TEAM_ARCNULLRP = NextRP.createJob('Боец ARC Null', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'arcnullrp', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/wf/nulled/aden.mdl'
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'SGT',
    ranks = {
        ['SGT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/wf/nulled/aden.mdl',
            },
            hp = 500, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {
                },
                ammunition = {
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Сержант',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['LT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/wf/nulled/aden.mdl',
            },
            hp = 500, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {
                },
                ammunition = {
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Лейтенант',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['CPT'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/wf/nulled/aden.mdl',
            },
            hp = 500, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {
                },
                ammunition = {
                },
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Капитан',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
        ['Прудии'] = {
            id = 'Prudii',
            model = {
                'models/wf/nulled/prudii.mdl',
                'models/kylejwest/synergyroleplay/sr3dnullprudiimando/sr3dnullprudiimando.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_cgi_k_westarm5',
                    'arccw_k_cgi_westarm5_sniper',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_sonar',
                    'arccw_cgi_k_z6adv',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arccw_k_nade_bacta',
                    'fort_datapad',
                    'defuser_bomb',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
                default = {
                    'arc9_k_dc17_stun',
                },
            },
            hp = 500,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Джайнг'] = {
            id = 'Jaing',
            model = {
                'models/wf/nulled/jaing.mdl',
                'models/kylejwest/synergyroleplay/sr3dnulljaingmando/sr3dnulljaingmando.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_cgi_k_westarm5',
                    'arccw_k_cgi_westarm5_sniper',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_sonar',
                    'arccw_cgi_k_z6adv',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arccw_k_nade_bacta',
                    'fort_datapad',
                    'defuser_bomb',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
                default = {
                    'arc9_k_dc17_stun',
                },
            },
            hp = 500,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Комрк'] = {
            id = 'Komrk',
            model = {
                'models/wf/nulled/komrk.mdl',
                'models/kylejwest/synergyroleplay/sr3dnullkomrkmando/sr3dnullkomrkmando.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_cgi_k_westarm5',
                    'arccw_k_cgi_westarm5_sniper',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_sonar',
                    'arccw_cgi_k_z6adv',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arccw_k_nade_bacta',
                    'fort_datapad',
                    'defuser_bomb',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
                default = {
                    'arc9_k_dc17_stun',
                },
            },
            hp = 500,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Мерил'] = {
            id = 'Mereel',
            model = {
                'models/wf/nulled/mereel.mdl',
                'models/kylejwest/synergyroleplay/sr3dnullmereelmando/sr3dnullmereelmando.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_cgi_k_westarm5',
                    'arccw_k_cgi_westarm5_sniper',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_sonar',
                    'arccw_cgi_k_z6adv',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arccw_k_nade_bacta',
                    'fort_datapad',
                    'defuser_bomb',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
                default = {
                    'arc9_k_dc17_stun',
                },
            },
            hp = 500,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Аден'] = {
            id = 'Aden',
            model = {
                'models/wf/nulled/aden.mdl',
                'models/kylejwest/synergyroleplay/sr3dnulladenmando/sr3dnulladenmando.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_cgi_k_westarm5',
                    'arccw_k_cgi_westarm5_sniper',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_sonar',
                    'arccw_cgi_k_z6adv',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arccw_k_nade_bacta',
                    'fort_datapad',
                    'defuser_bomb',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
                default = {
                    'arc9_k_dc17_stun', 
                },
            },
            hp = 500,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Ордо'] = {
            id = 'Ordo',
            model = {
                'models/wf/nulled/ordo.mdl',
                'models/kylejwest/synergyroleplay/sr3dnullordomando/sr3dnullordomando.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_cgi_k_westarm5',
                    'arccw_k_cgi_westarm5_sniper',
                    'arccw_k_launcher_rps6',
                    'arccw_k_nade_thermal',
                    'arccw_k_nade_sonar',
                    'arccw_cgi_k_z6adv',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_defibrillator',
                    'arccw_k_nade_bacta',
                    'fort_datapad',
                    'defuser_bomb',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
                default = {
                    'arc9_k_dc17_stun', 
                },
            },
            hp = 600,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 150,
    runspead = 300,
    Salary = 100,
    -- Категория
    category = 'ARC | Null'
})

TEAM_MAZENRP = NextRP.createJob('Представитель Республиканской Разведки', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'mazenrp', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/player/gary/commission/starwars/omen_srt.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Classified',
    ranks = {
        ['Classified'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/gonzo/republicintelligence/director/director.mdl',
                'models/player/gary/commission/starwars/omen_srt.mdl'
            },
            hp = 600, -- ХП
            ar = 65, -- Армор
            weapon = { -- Оружие
                default = {
                    'arc9_k_dc17ext',
                    'sw_datapad'
                }, -- При спавне
                ammunition = {
                    'arc9_galactic_vssmaze',
                    'arc9_galactic_nt242ri',
                    'realistic_hook',
                    'weapon_bactainjector',
                    'arc9_k_nade_thermal',
                    'jet_mk5',
                    'arc9_k_nade_c14'
                } -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Засекреченно',
            speed = {500, 500}, -- Значения скорости: {walkSpeed, runSpeed}
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    -- Категория
    category = 'Штаб'
})

TEAM_HQNRP = NextRP.createJob('Боец Штаба', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'hqnrp', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/navy/gnavyengineer.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'JLT',
    ranks = {
        ['JLT'] = {
            sortOrder = 1,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
            },
            hp = 150,
            ar = 30,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 2,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
            },
            hp = 200,
            ar = 35,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 3,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
            },
            hp = 250,
            ar = 35,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 4,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
            },
            hp = 350,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 2,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
            },
            hp = 350,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
        ['LCL'] = {
            sortOrder = 2,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
            },
            hp = 350,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Подполковник',
            whitelist = false,
        },
        ['COL'] = {
            sortOrder = 1,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
            },
            hp = 350,
            ar = 40,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Полковник',
            whitelist = false,
        },
        ['CC'] = {
            sortOrder = 2,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_appo/general.mdl',
                'models/aldmor/tc13_general_c/general_cards.mdl',
            },
            hp = 400,
            ar = 50,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Клон-Коммандер',
            whitelist = false,
        },
        ['GEN'] = {
            sortOrder = 3,
            model = {
                'models/navy/gnavyengineer.mdl',
                'models/aldmor/tc13_marshall/marshall.mdl'
            },
            hp = 600,
            ar = 65,
            weapon = {
                default = {
                    'arccw_k_dc17_stun',
                    'sw_datapad',
                    'arccw_sops_vibroknife',
                },
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                },
            },
            fullRank = 'Генерал',
            whitelist = false,
        },
    },
    flags = {
        ['СКШ'] = {
            id = 'SKB',
            model = {
                'models/aldmor/tc13_colonel/colonel.mdl',
                'models/aldmor/tc13_adiutant/adiutant.mdl',
            },
            weapon = {
                ammunition = {
                    'arccw_k_dc15s_stun',
                    'arccw_k_dc17_stun',
                    'arccw_k_republicshield',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'weapon_squadshield_arm',
                },
                default = {
                },
            },
            hp = 250,
            ar = 40,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = true,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    -- Категория
    category = 'Штаб'
})

TEAM_SENGRD = NextRP.createJob('Гвардеец Талмирона', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'sengrd', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/nb/wizard/sw_gondor_pm.mdl'
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'GUARD',
    ranks = {
        ['GUARD'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/nb/wizard/sw_gondor_pm.mdl'
            },
            hp = 500, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {
                    'weapon_lscs_mandostaff',
                }, -- При спавне
                ammunition = {
                    'arccw_k_cgi_westar35p',
                    'arccw_cgi_k_dc17_stun',
                    'arccw_cgi_k_dc15s_stun',
                    'arccw_k_cgi_westar35c',
                    'arccw_k_cgi_westar35s',
                    'arccw_k_cgi_westar35sc',
                    'arccw_k_cgi_westar35smg',
                    'arccw_k_cgi_westar35_gau',
                    'jet_mk5',
                    'weapon_bactainjector',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                } -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Гвардеец',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        }
    },
    flags = {
        
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_RPROLE, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 110,
    runspead = 260,
    Salary = 500,
    -- Категория
    category = 'Штаб'
})

TEAM_CT = NextRP.createJob('Боец CT', {
    id = 'ct',
    model = {'models/player/olive/cr_heavy/cr_heavy.mdl'},
    color = Color(127,143,166),
    default_rank = 'TRP',
    ranks = {
        ['TRP'] = {
            sortOrder = 1,
            model = {
                'models/player/olive/cr_heavy/cr_heavy.mdl',
            },
            hp = 150,
            ar = 50,
            weapon = {
                default = {
                    'arc9_k_dc17',
                },
                ammunition = {
                    'arc9_k_dc15s',
                    'arc9_k_dc15a',
                    'arc9_k_nade_thermal',
                },
            },
            fullRank = 'Клон Рекрут',
            whitelist = false,
        },
        ['PVT'] = {
            sortOrder = 2,
            model = {
                'models/ct_pvt/ct_pvt.mdl',
            },
            hp = 150,
            ar = 50,
            weapon = {
                default = {
                    'arc9_k_dc17',
                },
                ammunition = {
                    'arc9_k_dc15s',
                    'arc9_k_dc15a',
                    'arc9_k_nade_thermal',
                },
            },
            fullRank = 'Рядовой',
            whitelist = false,
        },
        ['PFC'] = {
            sortOrder = 3,
            model = {
                'models/ct_pvt/ct_pvt.mdl',
            },
            hp = 150,
            ar = 50,
            weapon = {
                default = {
                    'arc9_k_dc17',
                },
                ammunition = {
                    'arc9_k_dc15s',
                    'arc9_k_dc15a',
                    'arc9_k_nade_thermal',
                },
            },
            fullRank = 'Рядовой Первого Класса',
            whitelist = false,
        },
        ['CPL'] = {
            sortOrder = 4,
            model = {
                'models/ct_pvt/ct_pvt.mdl',
            },
            hp = 150,
            ar = 50,
            weapon = {
                default = {
                    'arc9_k_dc17_stun',
                },
                ammunition = {
                    'arc9_k_dc15s',
                    'arc9_k_dc15a',
                    'arc9_k_nade_thermal',
                },
            },
            fullRank = 'Капрал',
            whitelist = false,
        },
        ['JSG'] = {
            sortOrder = 5,
            model = {
                'models/ct_sgt/ct_sgt.mdl',
            },
            hp = 200,
            ar = 50,
            weapon = {
                default = {
                    'arc9_k_dc17_stun',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Младший Сержант',
            whitelist = false,
        },
        ['SGT'] = {
            sortOrder = 6,
            model = {
                'models/ct_sgt/ct_sgt.mdl',
            },
            hp = 200,
            ar = 50,
            weapon = {
                default = {
                    'arc9_k_dc17_stun',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Сержант',
            whitelist = false,
        },
        ['SSG'] = {
            sortOrder = 7,
            model = {
                'models/ct_sgt/ct_sgt.mdl',
            },
            hp = 200,
            ar = 50,
            weapon = {
                default = {
                    'arc9_k_dc17_stun',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Старший Сержант',
            whitelist = false,
        },
        ['JLT'] = {
            sortOrder = 9,
            model = {
                'models/ct_lt/ct_lt.mdl',
            },
            hp = 250,
            ar = 60,
            weapon = {
                default = {
                    'arc9_k_dc17_akimbo',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Младший Лейтенант',
            whitelist = false,
        },
        ['LT'] = {
            sortOrder = 10,
            model = {
                'models/ct_lt/ct_lt.mdl',
            },
            hp = 250,
            ar = 60,
            weapon = {
                default = {
                    'arc9_k_dc17_akimbo',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Лейтенант',
            whitelist = false,
        },
        ['SLT'] = {
            sortOrder = 11,
            model = {
                'models/ct_lt/ct_lt.mdl',
            },
            hp = 250,
            ar = 60,
            weapon = {
                default = {
                    'arc9_k_dc17_akimbo',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Старший Лейтенант',
            whitelist = false,
        },
        ['CPT'] = {
            sortOrder = 12,
            model = {
                'models/ct_cpt/ct_cpt.mdl',
            },
            hp = 300,
            ar = 60,
            weapon = {
                default = {
                    'arc9_k_dc17_akimbo',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Капитан',
            whitelist = false,
        },
        ['MAJ'] = {
            sortOrder = 13,
            model = {
                'models/ct_cpt/ct_cpt.mdl',
            },
            hp = 300,
            ar = 60,
            weapon = {
                default = {
                    'arc9_k_dc17ext',
                },
                ammunition = {
                    'arc9_k_dc15a_stun',
                    'arc9_k_nade_thermal',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic'
                },
            },
            fullRank = 'Майор',
            whitelist = false,
        },
           ['COL'] = {
           sortOrder = 14,
           model = {
              'models/ct_cpt/ct_cpt.mdl',
           },
           hp = 300,
           ar = 60,
           weapon = {
               default = {
                   'arc9_k_dc17ext',
               },
               ammunition = {
                   'arc9_k_dc15a_stun',
                   'arc9_k_nade_thermal',
                   'arc9_k_dc15s_stun',
                   'weapon_stunstick',
                   'weapon_cuff_elastic'
               },
           },
           fullRank = 'Полковник',
           whitelist = false,
       },
       ['CC'] = {
           sortOrder = 15,
           model = {
              'models/ct_sld/ct_sld.mdl',
           },
           hp = 300,
           ar = 60,
           weapon = {
               default = {
                   'arc9_k_dc17ext',
               },
               ammunition = {
                   'arc9_k_dc15a_stun',
                   'arc9_k_nade_thermal',
                   'arc9_k_dc15s_stun',
                   'weapon_stunstick',
                   'weapon_cuff_elastic'
               },
           },
           fullRank = 'Клон-Командер',
           whitelist = false,
       },
       ['SCC'] = {
           sortOrder = 16,
           model = {
              'models/ct_sld/ct_sld.mdl',
           },
           hp = 300,
           ar = 60,
           weapon = {
               default = {
                   'arc9_k_dc17ext',
               },
               ammunition = {
                   'arc9_k_dc15a_stun',
                   'arc9_k_nade_thermal',
                   'arc9_k_dc15s_stun',
                   'weapon_stunstick',
                   'weapon_cuff_elastic'
               },
           },
           fullRank = 'Старший Клон-Командер',
           whitelist = false,
       },
       ['MC'] = {
           sortOrder = 17,
           model = {
              'models/ct_sld/ct_sld.mdl',
           },
           hp = 300,
           ar = 60,
           weapon = {
               default = {
                   'arc9_k_dc17ext',
               },
               ammunition = {
                   'arc9_k_dc15a_stun',
                   'arc9_k_nade_thermal',
                   'arc9_k_dc15s_stun',
                   'weapon_stunstick',
                   'weapon_cuff_elastic'
               },
           },
           fullRank = ' Маршел Командер',
           whitelist = false,
       },
   },
    flags = {
        ['SN|АРФ'] = {
            id = 'SN|ARF',
            model = {
                'models/ct_arf/ct_arf.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_flash',
                    'arc9_k_nade_smoke',
                    'weapon_cuff_elastic',
                    'weapon_stunstick',
                    'arc9_k_nade_sonar',
                    'arc9_k_dc15le',
                    'arc9_k_dc15x'
                },
                default = {
                'arc9_k_dc17_akimbo',
                'realistic_hook'
                },
            },
            hp = 250,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['ЭРК'] = {
            id = 'ARC',
            model = {
                'models/ct_arc/ct_arc.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_z6adv',
                    'arc9_k_westarm5',
                    'arc9_k_republicshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arc9_k_nade_smoke',
                    'arc9_k_nade_flash',
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_stun',
                    'medic_medkit',
                    'medic_blood',
                    'medic_dosimetr',
                    'medic_ecg_temp',
                    'medic_exam',
                    'jet_mk5',
                    'medic_nerv_maleol',
                    'medic_ophtalmoscope',
                    'medic_otoscope',
                    'medic_pulseoxymetr',
                    'medic_expresstest_flu',
                    'medic_scapula',
                    'medic_shethoscope',
                    'medic_therm',
                    'weapon_med_scanner',
                    'medic_tonometr'
                },
                default = {
                },
            },
            hp = 550,
            ar = 70,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Медик'] = {
            id = 'MED',
            model = {
                'models/ct_med/ct_med.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_dp23c',
                    'weapon_defibrillator',
                    'weapon_bactainjector',
                    'weapon_bactanade',
                    'arc9_k_nade_bacta',
                    'arc9_k_dc17',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arccw_k_nade_stun',
                    'medic_medkit',
                    'medic_blood',
                    'medic_dosimetr',
                    'medic_ecg_temp',
                    'medic_exam',
                    'medic_nerv_maleol',
                    'medic_ophtalmoscope',
                    'medic_otoscope',
                    'medic_pulseoxymetr',
                    'medic_expresstest_flu',
                    'medic_scapula',
                    'medic_shethoscope',
                    'medic_therm',
                    'weapon_med_scanner',
                    'medic_tonometr'
                },
                default = {
                },
            },
            hp = 250,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Пилот'] = {
            id = 'PIL',
            model = {
                'models/ct_pilot/ct_pilot.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_dp23',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arc9_k_nade_stun',
                    'fort_datapad',
                    'sv_datapad',
                    'defuser_bomb',
                    'weapon_squadshield_arm',
                    'arc9_k_nade_thermal',
                    'turret_placer'
                },
                default = {
                },
            },
            hp = 250,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Тяж боец'] = {
            id = 'HT',
            model = {
                'models/ct_heavy/ct_heavy.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_z6adv',
                    'arc9_k_republicshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arc9_k_nade_smoke',
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_impact',
                    'arc9_k_launcher_rps6_republic'
                },
                default = {
                },
            },
            hp = 250,
            ar = 75,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Десантник'] = {
            id = 'DIS',
            model = {
                'models/ct_jet/ct_jet.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_dc15le',
                    'arc9_k_dc17',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arc9_k_nade_smoke',
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_impact',
                    'jet_mk5'
                },
                default = {
                },
            },
            hp = 250,
            ar = 65,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
    },
        ['Инженер'] = {
            id = 'ENG',
            model = {
                'models/ct_eng/ct_eng.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_dp24',
                    'arc9_k_dc15s_stun',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arc9_k_nade_stun',
                    'fort_datapad',
                    'sv_datapad',
                    'defuser_bomb',
                    'weapon_squadshield_arm',
                    'arc9_k_nade_thermal',
                    'turret_placer'
                },
                default = {
                },
            },
            hp = 250,
            ar = 50,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
        ['Гренадер'] = {
            id = 'GER',
            model = {
                'models/ct_barc/ct_barc.mdl',
            },
            weapon = {
                ammunition = {
                    'arc9_k_dc15s',
                    'arc9_k_republicshield',
                    'weapon_stunstick',
                    'weapon_cuff_elastic',
                    'arc9_k_nade_smoke',
                    'arc9_k_nade_thermal',
                    'arc9_k_nade_impact',
                    'arc9_k_launcher_rps6_republic'
                },
                default = {
                },
            },
            hp = 250,
            ar = 55,
            replaceWeapon = false,
            replaceHPandAR = true,
            replaceModel = true,
        },
    type = TYPE_GAR,
    control = CONTROL_GAR,
    start = false,
    walkspead = 100,
    runspead = 250,
    Salary = 100,
    category = 'CT Батальон'
})

--[[----------------------------------------------------------------------------------

    #:Остальное
------------------------------------------------------------------------------------]]

TEAM_YOUNGJEDI = NextRP.createJob('Юнлинг', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'youngjedi', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/player/jedi/human.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Youngling',
    ranks = {
        ['Youngling'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                        'models/jazzmcfly/jka/younglings/jka_young_anikan.mdl',
                        'models/jazzmcfly/jka/younglings/jka_young_female.mdl',
                        'models/jazzmcfly/jka/younglings/jka_young_male.mdl',
                        'models/jazzmcfly/jka/younglings/jka_young_shak.mdl',
            },
            hp = 600, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Юнлинг',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDI = NextRP.createJob('Джедай', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jedi', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/player/jedi/human.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Padawan',
    ranks = {
        ['Padawan'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 2,
            -- Основные настройки
            model = { -- Модели
                        'models/player/jedi/sun_quix.mdl',
                        'models/player/jedi/knight/yang_torm.mdl',
                        'models/player/jedi/nyssa_delacor.mdl',
                        'models/fire/ravinder/fox_jedi2.mdl',
                        'models/swcw/player/swcw/jedi_human_male.mdl',
                        'models/swcw/player/swcw/jedi_twilek_male.mdl',
                        'models/swcw/player/swcw/jedi_zabrak_male.mdl',
                        'models/c10h14n2/jedi/mactavishjedi.mdl',
                        'models/cgi/jedi/2003_armoured_kronyk.mdl',
                        'models/player/gg/jedi/consular_jedi_amerilia.mdl',
                        'models/player/jedi/commission_borris.mdl',
                        'models/player/jedi/etain.mdl',
                        'models/player/jedi/jedi_knigt_azreiath.mdl',
                        'models/player/jedi/jedi_knigt_threnx.mdl',
                        'models/player/jedi/knoot.mdl',
                        'models/player/jedi/nuru_kungurama.mdl',
                        'models/player/jedi/gateway/brandon_commssion.mdl',
                        'models/player/jedi/knight/andy_usca.mdl',
                        'models/player/jedi/knight/knight_ragnar.mdl',
                        'models/player/jedi/knight/zazz_estree.mdl',
                        'models/player/plo/gg/jedi/mu_kai_sinn.mdl',
            },
            hp = 800, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Падаван',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['Knight'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 3,
            -- Основные настройки
            model = { -- Модели
                        'models/player/jedi/sun_quix.mdl',
                        'models/player/jedi/knight/yang_torm.mdl',
                        'models/player/jedi/nyssa_delacor.mdl',
                        'models/fire/ravinder/fox_jedi2.mdl',
                        'models/swcw/player/swcw/jedi_human_male.mdl',
                        'models/swcw/player/swcw/jedi_twilek_male.mdl',
                        'models/swcw/player/swcw/jedi_zabrak_male.mdl',
                        'models/c10h14n2/jedi/mactavishjedi.mdl',
                        'models/cgi/jedi/2003_armoured_kronyk.mdl',
                        'models/player/gg/jedi/consular_jedi_amerilia.mdl',
                        'models/player/jedi/commission_borris.mdl',
                        'models/player/jedi/etain.mdl',
                        'models/player/jedi/jedi_knigt_azreiath.mdl',
                        'models/player/jedi/jedi_knigt_threnx.mdl',
                        'models/player/jedi/knoot.mdl',
                        'models/player/jedi/nuru_kungurama.mdl',
                        'models/player/jedi/gateway/brandon_commssion.mdl',
                        'models/player/jedi/knight/andy_usca.mdl',
                        'models/player/jedi/knight/knight_ragnar.mdl',
                        'models/player/jedi/knight/zazz_estree.mdl',
                        'models/player/plo/gg/jedi/mu_kai_sinn.mdl',
            },
            hp = 1000, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Рыцарь',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['Master'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 4,
            -- Основные настройки
            model = { -- Модели
                        'models/player/jedi/sun_quix.mdl',
                        'models/player/jedi/knight/yang_torm.mdl',
                        'models/player/jedi/nyssa_delacor.mdl',
                        'models/fire/ravinder/fox_jedi2.mdl',
                        'models/swcw/player/swcw/jedi_human_male.mdl',
                        'models/swcw/player/swcw/jedi_twilek_male.mdl',
                        'models/swcw/player/swcw/jedi_zabrak_male.mdl',
                        'models/c10h14n2/jedi/mactavishjedi.mdl',
                        'models/cgi/jedi/2003_armoured_kronyk.mdl',
                        'models/player/gg/jedi/consular_jedi_amerilia.mdl',
                        'models/player/jedi/commission_borris.mdl',
                        'models/player/jedi/etain.mdl',
                        'models/player/jedi/jedi_knigt_azreiath.mdl',
                        'models/player/jedi/jedi_knigt_threnx.mdl',
                        'models/player/jedi/knoot.mdl',
                        'models/player/jedi/nuru_kungurama.mdl',
                        'models/player/jedi/gateway/brandon_commssion.mdl',
                        'models/player/jedi/knight/andy_usca.mdl',
                        'models/player/jedi/knight/knight_ragnar.mdl',
                        'models/player/jedi/knight/zazz_estree.mdl',
                        'models/player/plo/gg/jedi/mu_kai_sinn.mdl',
            },
            hp = 1200, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Мастер',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['Magister'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                        'models/player/jedi/sun_quix.mdl',
                        'models/player/jedi/knight/yang_torm.mdl',
                        'models/player/jedi/nyssa_delacor.mdl',
                        'models/fire/ravinder/fox_jedi2.mdl',
                        'models/swcw/player/swcw/jedi_human_male.mdl',
                        'models/swcw/player/swcw/jedi_twilek_male.mdl',
                        'models/swcw/player/swcw/jedi_zabrak_male.mdl',
                        'models/c10h14n2/jedi/mactavishjedi.mdl',
                        'models/cgi/jedi/2003_armoured_kronyk.mdl',
                        'models/player/gg/jedi/consular_jedi_amerilia.mdl',
                        'models/player/jedi/commission_borris.mdl',
                        'models/player/jedi/etain.mdl',
                        'models/player/jedi/jedi_knigt_azreiath.mdl',
                        'models/player/jedi/jedi_knigt_threnx.mdl',
                        'models/player/jedi/knoot.mdl',
                        'models/player/jedi/nuru_kungurama.mdl',
                        'models/player/jedi/gateway/brandon_commssion.mdl',
                        'models/player/jedi/knight/andy_usca.mdl',
                        'models/player/jedi/knight/knight_ragnar.mdl',
                        'models/player/jedi/knight/zazz_estree.mdl',
                        'models/player/plo/gg/jedi/mu_kai_sinn.mdl',
            },
            hp = 1400, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Магистер',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['Grand Master'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                        'models/player/jedi/knight/yang_torm.mdl'
            },
            hp = 1600, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Гранд-Мастер',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
        ['Temple Watcher'] = {
            id = 'Смотрящий за храмом',

            model = {
                'models/player/jedi/knight/yang_torm.mdl'
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['guard'] = {
            id = 'Страж',

            model = {
                'models/gonzo/greyjediguard/greyjediguard.mdl'
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['defender'] = {
            id = 'Защитник',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['consul'] = {
            id = 'Консул',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['cj'] = {
            id = 'Коммандер',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['gj'] = {
            id = 'Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['sgj'] = {
            id = 'Старший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['hgj'] = {
            id = 'Высший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        }
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDITRIFF = NextRP.createJob('Джедай Triff', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jeditriff', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/swcw/player/swcw/jedi_daron.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Magister',
    ranks = {
        ['Magister'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                        'models/swcw/player/swcw/jedi_daron.mdl',
            },
            hp = 1400, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Магистр',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
        ['guard'] = {
            id = 'Страж',

            model = {
                'models/swcw/player/swcw/jedi_daron.mdl'
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['defender'] = {
            id = 'Защитник',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['consul'] = {
            id = 'Консул',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['cj'] = {
            id = 'Коммандер',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['gj'] = {
            id = 'Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['sgj'] = {
            id = 'Старший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['hgj'] = {
            id = 'Высший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        }
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDIRAVEN = NextRP.createJob('Джедай Raven', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jediraven', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/jedi/jediraven.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Magister',
    ranks = {
        ['Magister'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                        'models/jedi/jediraven.mdl',
                        'models/sith/sithraven.mdl',
            },
            hp = 1400, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Магистр',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
        ['guard'] = {
            id = 'Страж',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['defender'] = {
            id = 'Защитник',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['consul'] = {
            id = 'Консул',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['cj'] = {
            id = 'Коммандер',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['gj'] = {
            id = 'Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['sgj'] = {
            id = 'Старший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['hgj'] = {
            id = 'Высший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        }
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDIENI = NextRP.createJob('Джедай Мейс Винду', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jedieni', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/seven/jedi_macewinduv.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Magister',
    ranks = {
        ['Magister'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                        'models/seven/jedi_macewinduv.mdl',
            },
            hp = 1400, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Магистр',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
        ['guard'] = {
            id = 'Страж',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['defender'] = {
            id = 'Защитник',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['consul'] = {
            id = 'Консул',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['cj'] = {
            id = 'Коммандер',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['gj'] = {
            id = 'Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['sgj'] = {
            id = 'Старший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['hgj'] = {
            id = 'Высший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDIHARLEY = NextRP.createJob('Джедай Harley Stark', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jediharley', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/artel/kotw/kotw.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Knight',
    ranks = {
        ['Knight'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                        'models/artel/kotw/kotw.mdl',
            },
            hp = 1000, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {
                    'weapon_lscs',
                    'weapon_shaman',
                }, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Рыцарь',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
        ['guard'] = {
            id = 'Страж',

            model = {
                'models/artel/kotw/kotw.mdl'
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['defender'] = {
            id = 'Защитник',

            model = {
                'models/artel/kotw/kotw.mdl'
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['consul'] = {
            id = 'Консул',

            model = {
                'models/artel/kotw/kotw.mdl'
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['cj'] = {
            id = 'Коммандер',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['gj'] = {
            id = 'Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['sgj'] = {
            id = 'Старший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['hgj'] = {
            id = 'Высший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        }
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDIPEN = NextRP.createJob('Джедай Patience Kys', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jedipen', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/oxyl/Mando_FEMALE.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Padawan',
    ranks = {
        ['Padawan'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 2,
            -- Основные настройки
            model = { -- Модели
                        'models/oxyl/Mando_FEMALE.mdl',
            },
            hp = 800, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Падаван',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['Knight'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 3,
            -- Основные настройки
            model = { -- Модели
                        'models/oxyl/Mando_FEMALE.mdl',
            },
            hp = 1000, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Рыцарь',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['Master'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 4,
            -- Основные настройки
            model = { -- Модели
                        'models/oxyl/Mando_FEMALE.mdl',
            },
            hp = 1200, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Мастер',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
        ['Magister'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 5,
            -- Основные настройки
            model = { -- Модели
                        'models/oxyl/Mando_FEMALE.mdl',
            },
            hp = 1400, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Магистер',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
        ['guard'] = {
            id = 'Страж',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['defender'] = {
            id = 'Защитник',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['consul'] = {
            id = 'Консул',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['cj'] = {
            id = 'Коммандер',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['gj'] = {
            id = 'Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['sgj'] = {
            id = 'Старший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        },
        ['hgj'] = {
            id = 'Высший Генерал-Джедай',

            model = {
            },
            weapon = {
                ammunition = {},
                default = {}
            },

            hp = 5,
            ar = 5,

            replaceWeapon = false,
            replaceHPandAR = false,
            replaceModel = false,
        }
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_JEDI, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    Salary = 100,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDIASO = NextRP.createJob('Джедай Асока Тано', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jediaso', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/player/jedi/padawan/ahsoka_tano_s7.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Padawan',
    ranks = {
        ['Padawan'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/player/jedi/padawan/ahsoka_tano_s7.mdl'
            },
            hp = 1000, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Асока Тано',
            speed = {500, 500}, -- Значения скорости: {walkSpeed, runSpeed}
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = true,
    walkspead = 100,
    runspead = 250,
    -- Категория
    category = 'Джедаи'
})

TEAM_JEDIKANDO = NextRP.createJob('Джедай Vol Kando', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'jedikando', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/swcw/player/swcw/jedi_human_male.mdl'},
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Knight',
    ranks = {
        ['Knight'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/swcw/player/swcw/jedi_human_male.mdl',
            },
            hp = 1200, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {'weapon_lscs'}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Vol Kando',
            speed = {500, 500}, -- Значения скорости: {walkSpeed, runSpeed}
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_GAR, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_GAR, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = true,
    walkspead = 100,
    runspead = 250,
    -- Категория
    category = 'Джедаи'
})

--[[----------------------------------------------------------------------------------

    #:Остальное
------------------------------------------------------------------------------------]]

TEAM_TPROLL = NextRP.createJob('РП Роль', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'tproll', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/player/combine_super_soldier.mdl'
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'rp',
    ranks = {
        ['rp'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/player/combine_super_soldier.mdl'
            },
            hp = 100, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'рп',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        }
    },
    flags = {

    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_RPROLE, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 100,
    runspead = 250,
    -- Категория
    category = 'RP'
})

TEAM_CITYNRP = NextRP.createJob('Неизвестный', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'citynrp', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = { -- Модели
                'models/player/combine_super_soldier.mdl'
            },
    color = Color(127, 143, 166),
    -- Звания
    default_rank = 'Unknown',
    ranks = {
        ['Unknown'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/assassin/pm_civ_assassin_human_female.mdl',
                'models/bride/pm_civ_bride_costume_female.mdl',
                'models/cyborg/pm_civ_cyborg_costume_male.mdl',
                'models/dweller/pm_civ_dweller_human_female.mdl',
                'models/dweller/pm_civ_dweller_human_male.mdl',
                'models/engineer/pm_civ_engineer_human_female.mdl',
                'models/engineer/pm_civ_engineer_human_male.mdl',
                'models/formal/pm_civ_formal_human_female.mdl',
                'models/formal/pm_civ_formal_human_male.mdl',
                'models/merc/pm_civ_merc_human_female.mdl',
                'models/merc/pm_civ_merc_human_male.mdl',
                'models/noble/pm_civ_noble_human_female.mdl',
                'models/noble/pm_civ_noble_human_male.mdl',
                'models/ranger/pm_civ_ranger_costume_female.mdl',
                'models/rebel/pm_civ_rebel_costume_male.mdl',
                'models/renegade/pm_civ_renegade_human_female.mdl',
                'models/renegade/pm_civ_renegade_human_male.mdl',
                'models/resident/pm_civ_resident_human_female.mdl',
                'models/resident/pm_civ_resident_human_male.mdl',
                'models/scientist/pm_civ_scientist_human_female.mdl',
            },
            hp = 100, -- ХП
            ar = 50, -- Армор
            weapon = { -- Оружие
                default = {}, -- При спавне
                ammunition = {} -- В оружейке
            },
            -- Форматирование
            -- natoCode = 'OR-1',
            fullRank = 'Неизвестный',
            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу
        }
    },
    flags = {

    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_RPROLE, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    -- Стартовая
    start = false,
    walkspead = 100,
    runspead = 250,
    -- Категория
    category = 'RP'
})

TEAM_ADMIN = NextRP.createJob('Администратор', {
    -- НЕОБХОДИМЫЕ НАСТРОЙКИ
    id = 'admin', -- УНИКАЛЬНЫЙ ID ПРОФЫ, без него вся система персонажей идёт нахуй
    -- Модель(и)
    model = {'models/dizcordum/wk/jackswan/wk_servoskull.mdl'},
    color = Color(220, 221, 225),
    -- Звания
    default_rank = 'ADMIN',
    ranks = {
        ['ADMIN'] = {
            -- Порядок сортировки, снизу вверх
            sortOrder = 1,
            -- Основные настройки
            model = { -- Модели
                'models/dizcordum/wk/jackswan/wk_servoskull.mdl'
            },
            hp = 100, -- ХП
            ar = 0, -- Армор
            weapon = { -- Оружие
                default = {'weapon_physgun', 'gmod_tool'}, -- При спавне
                ammunition = {} -- В оружейке
            },

            -- Форматирование
            natoCode = '',
            fullRank = 'Администратор',

            -- Вайтлист
            whitelist = false -- Может ли выдавать эту профу и менять звания
        },
    },
    flags = {
    },

    -- ТИПы и КОНТРОЛы
    type = TYPE_ADMIN, -- ТИП, могут быть TYPE_USA, TYPE_RUSSIA, TYPE_TERROR, TYPE_OTHER, TYPE_ADMIN, TYPE_RPROLE   control = CONTROL_NATO
    control = CONTROL_NONE, -- КОНТРОЛ, можеть быть CONTROL_NATO, CONTROL_TERRORISTS, CONTROL_HEADHUNTERS, CONTROL_NONE
    flag = 'ua',
    -- Стартовая
    start = true,
    walkspead = 250,
    runspead = 300,
    -- Категория
    category = 'Администратор'
})

START_TEAMS = {
	[TYPE_GAR] = TEAM_CADET,
}

--[[----------------------------------------------------------------------------------
By Raven
Date: 08.11.2025
Version: 15
------------------------------------------------------------------------------------]]