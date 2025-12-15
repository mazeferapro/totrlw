--[[--
Модуль для проверки прав игрока

    if NextRP:HasPrivilege(Player, "manage_chars") then
        -- сделать что-то
    end
]]--
-- @module NextRP.Permissions

NextRP.Permissions = NextRP.Permissions or {}

local PRIVILEGES = {
    -- Модули
    ['manage_chars'] = {
        'admin',
        'Доступ к управлению персонажами.',
    },
    ['manage_ranks'] = {
        'admin',
        'Доступ к управлению званиями.',
    },
    ['manage_slots'] = {
        'superadmin',
        'eventmanager',
        'Доступ к управлению слотами.'
    },
    ['manage_vehs'] = {
        'superadmin',
        'Доступ к управлению транспортом.'
    },
    ['manage_spawns'] = {
        'admin',
        'Доступ к управлению спавнами игроков.'
    },
    ['manage_controlpoints'] = {
        'superadmin',
        'Доступ к управлению точками захвата.'
    },

    -- Спавны
    ['spawn_sweps'] = {
        'admin',
        'moderator',
        'supereventmanager',
        'eventmanager',
        'Доступ к спавну свепов'
    },
    ['spawn_effect'] = {
        'admin',
        'moderator',
        'supereventmanager',
        'eventmanager',
        'Доступ к спавну эффектов'
    },
    ['spawn_npc'] = {
        'admin',
        'moderator',
        'supereventmanager',
        'eventmanager',
        'Доступ к спавну НПС'
    },
    ['spawn_ragdolls'] = {
        'admin',
        'moderator',
        'supereventmanager',
        'eventmanager',
        'Доступ к спавну регдоллов'
    },
    ['spawn_ents'] = {
        'admin',
        'moderator',
        'supereventmanager',
        'eventmanager',
        'Доступ к спавну энтити'
    },
    ['spawn_props'] = {
        'admin',
        'eventmanager',
        'Доступ к спавну пропов'
    },
}

for k, v in pairs(PRIVILEGES) do
    local CAMI_PRIVILEGE = {
        Name = 'nrp_'..k,
        MinAccess = v[1],
        Description = v[2]
    }

    CAMI.RegisterPrivilege(CAMI_PRIVILEGE)
    print('[ NextRP ]', 'Зарегестрирована привелегия "'..k..'"!')
end

--- Проверяет на наличие прав у игрока
-- @realm shared
-- @tparam Player pPlayer Игрок, которого нужно проверить
-- @tparam string sPrivilege Привелегия, на наличие которой проверяем
-- @treturn boolean Имееться ли у игрока данная привелегия
-- @aliases NextRP:HasPrivilege(pPlayer, sPrivilege)
function NextRP.Permissions.HasPrivilege(pPlayer, sPrivilege)
    local hasAccess = CAMI.PlayerHasAccess(pPlayer, 'nrp_'..sPrivilege)
    return hasAccess
end
function NextRP:HasPrivilege(pPlayer, sPrivilege)
    return NextRP.Permissions.HasPrivilege(pPlayer, sPrivilege)
end