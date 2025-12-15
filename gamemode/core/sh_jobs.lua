--[[--
Модуль для создания и обработки профессий
]]
-- @module NextRP.Jobs

NextRP.Jobs = {}
NextRP.Categories = {} 
NextRP.CategoriesByName = {} 
NextRP.JobsByID = {}
-- Типы
-- Новые
TYPE_NONE = 0
-- Фракции
TYPE_GAR = 1 -- Для ВАР
TYPE_JEDI = 2 -- Для Джедаев
TYPE_UNDEF = 3 -- Заготовка
TYPE_OTHER = 4 -- Для других отрядов

TYPE_ORC = 20 -- Для орков
-- Администрация
TYPE_ADMIN = 10
-- РП Роль
TYPE_RPROLE = 11

-- Контролы
-- Союзники
CONTROL_GAR = 1 -- Империум
-- Некроны
CONTROL_CIS = 2 -- Некроны
-- Эльдары
CONTROL_NATO = 5 -- Эльдары

-- Наёмники
CONTROL_HEADHUNTERS = 3 -- Наёмники
-- Ничего
CONTROL_NONE = 4 -- Ничего, не даёт эффекта на контролы

FACTION_LOCALIZATIONS = {
    [TYPE_NONE] = 'Без фракции',
    [TYPE_GAR] = 'ВАР',
    [TYPE_JEDI] = 'Джедаи',
    [TYPE_OTHER] = 'Другое',
    [TYPE_ADMIN] = 'Администратор',
    [TYPE_RPROLE] = 'РП Роль',
}

CONTROL_LOCALIZATIONS = {
    [CONTROL_GAR] = 'ВАР',
    [CONTROL_CIS] = 'КНС',
    [CONTROL_NATO] = 'Тато',
    [CONTROL_HEADHUNTERS] = 'Наёмники',
    [CONTROL_NONE] = 'Нейтральная (но захвачено)',
	 -- Это должно игнорироваться, но на всякий случай пусть будет тут
}

MONEY_FORMATS = { -- Не используеться сейчас
	[TYPE_NONE] = '%iCR',
    [TYPE_GAR] = '%iCR',
    [TYPE_JEDI] = '%iCR',
	[TYPE_ADMIN] = '%i админ баксов',
	[TYPE_OTHER] = '%iCR',
}

local indexnum = 0 -- счётчик для проф

--- Создаёт профессию
-- @realm shared
-- @param sName string Название профессии
-- @param tTeam table Таблица профессии
-- @treturn number Индекс профессии
function NextRP.createJob(sName, tTeam)
    indexnum = indexnum + 1

    team.SetUp( indexnum, sName, tTeam.color )

	tTeam.index = indexnum
	tTeam.name = sName or ''

	NextRP.Jobs[indexnum] = tTeam
	NextRP.JobsByID[tTeam.id] = tTeam

	local models = tTeam.model
	local rmodels = tTeam.ranks
	local fmodels = tTeam.flags

	if SERVER and models then
		if istable(models) then
			for k,v in pairs(models) do
				util.PrecacheModel(v)
			end
		else
			util.PrecacheModel(models)
		end

		if istable(rmodels) then
			for k, rank in pairs(rmodels) do
				if istable(rank.model) then
					for k, v in pairs(rank.model) do
						util.PrecacheModel(v)
					end
				else
					util.PrecacheModel(rank.model)
				end
			end
		end

		if istable(fmodels) then
			for k, flag in pairs(rmodels) do
				if istable(flag.model) then
					for k, v in pairs(flag.model) do
						util.PrecacheModel(v)
					end
				else
					util.PrecacheModel(flag.model)
				end 
			end
		end
	end

    hook.Run('NextRP::NewJob', indexnum, tTeam)
	MsgC('Зарегестрирована новая профессия ', '№', indexnum, ' "', sName, '", ', 'фракция: ', FACTION_LOCALIZATIONS[tTeam.type], '\n')

	if NextRP.CategoriesByName[tTeam.category] then
		local categId = NextRP.CategoriesByName[tTeam.category]

		NextRP.addJobToCateg(categId.index, tTeam)
	else		
		local categ, id = NextRP.createCategory(tTeam.category, {type = tTeam.type})
		NextRP.addJobToCateg(id, tTeam)

		MsgC('Зарегестрирована новая категория ', ' "', tTeam.category, '"\n')
	end

	return indexnum
end 

local indexnumcat = 0
function NextRP.createCategory(sName, tCateg)
	indexnumcat = indexnumcat + 1

	local c = NextRP.CategoriesByName[sName]
	local members = {}
	local sortOrder = 999

	if c then indexnumcat = NextRP.CategoriesByName[sName].index end
	if c then members = NextRP.CategoriesByName[sName].members end
	if c then sortOrder = NextRP.CategoriesByName[sName].sortOrder end

	local tReturn = {
		index = indexnumcat,
		name = sName,
		members = members,
		sortOrder = sortOrder
	}

	table.Merge(tReturn, tCateg)

	NextRP.Categories[indexnumcat] = tReturn
	NextRP.CategoriesByName[sName] = tReturn

	return tReturn, indexnumcat
end

function NextRP.addJobToCateg(nId, tJob)
	local categ = NextRP.Categories[nId]
	local categ2 = NextRP.CategoriesByName[categ.name]

	local jobID = #categ.members

	categ.members[jobID + 1] = tJob
	categ2.members[jobID + 1] = tJob
end

function NextRP.GetSortedCategories()
	return SortedPairsByMemberValue( NextRP.Categories, 'sortOrder' )
end

function NextRP.GetJob(index)
    return NextRP.Jobs[index] or false
end

function NextRP.GetJobByName(name)
    for _, tblJob in pairs(NextRP.Jobs) do
		if tblJob.name == name then
			return tblJob
		end
	end
end

function NextRP.GetJobByID(name)
    for _, tblJob in pairs(NextRP.Jobs) do
		if tostring(tblJob.id) == tostring(name) then
			return tblJob
		end
	end
end

function NextRP.formatMoney(factionType, amount)
	return string.format(MONEY_FORMATS[factionType], amount)
end