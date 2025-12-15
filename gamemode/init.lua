AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

-- Все наши настройки
include('shared.lua')

DEFINE_BASECLASS('gamemode_sandbox')
GM.Sandbox = BaseClass