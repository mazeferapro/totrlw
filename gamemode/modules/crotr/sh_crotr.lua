NextRP.CRotR = NextRP.CRotR or {}

NextRP.CRotR.Config = {
	Jobs = {
		{id = 'jedi', price = 200, useNumber = false},
		{id = 'youngjedi', price = 120, useNumber = true, descText = [[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]}, --Пример описания. Можно использовать многострочный текст, но дохуя писать тоже не стоит.
		--{id = '', price = 100, useNumber = true}, --Заготовка под новые профы. id берешь из проф, цену цифрами, useNumber для отображения.
		--{id = '', price = 100, useNumber = true},
	},

	SlotPrice = 500,

	InLine = 7, -- Сколько карточек в одном ряду, больше трех рядов не советую, но и слишком много в ряд пихать не стоит, на квадратных картошках будут слишком узкие.

	Admins = { -- Кто может выдавать бабки.
		['superadmin'] = true, -- Можно по юзеркам.
		['STEAM_0:0:54343242'] = true -- Можно по SteamID.
	}
}

function NextRP.CRotR:IsAdmin(pPlayer)
	if self.Config.Admins[pPlayer:GetUserGroup()] or self.Config.Admins[pPlayer:SteamID()] then return true end
	return false
end