--[[--
Физическое представление игрока.

Подробнее об игроках можно найти [тут](https://wiki.garrysmod.com/page/Category:Player).
]]--
-- @classmod Player

local pMeta = FindMetaTable('Player')

--- Сохраняет данные в БД
-- @realm server
-- @tparam string name Поле в БД
-- @tparam string|number value Данный для сохранения
-- @internal
function pMeta:SavePlayerData( name, value )
    local str = isnumber(value) and '%d' or '%s'
    value = isnumber(value) and value or MySQLite.SQLStr(value)

    MySQLite.query( string.format( 'UPDATE nextrp_players SET %s = '..str..' WHERE steam_id = %s;',
        name,
        value,
        MySQLite.SQLStr( self:SteamID() )
    ))
end

--- Получение таблицы профессии
-- **НЕ ВНОСИТЕ ИЗМЕНЕНИЯ В ЭТУ ТАБЛИЦУ**
-- @realm shared
-- @treturn[1] table Таблица профессии
-- @treturn[2] boolean Если таблицы нет - вернёт `false`
function pMeta:getJobTable()
	return NextRP.GetJob(self:Team()) or false
end

--- Проверяет наличие админки и игрока
-- @realm shared
-- @treturn boolean Наличие админки
function pMeta:IsAdmin()
    return NextRP.Utils:IsAdmin(self)
end

--- Группа игрока
-- @realm shared
-- @treturn string Группа
function pMeta:GetUserGroup()
	return self:GetNWString( 'UserGroup', 'user' )
end

function pMeta:CalcWeight()
    local wepTable = self:GetWeapons() or {}
    local weight = 0
    for _, wep in ipairs(wepTable) do
        if wep:GetClass() == 'nextrp_hands' or string.StartsWith(wep:GetClass(), 'medic') then continue end
        weight = weight + (wep.Weight or 5)
    end
    return self:SetNWInt('picked', weight)
end