NextRP = NextRP or {}
NextRP.Chars = NextRP.Chars or {}
NextRP.Chars.Cache = NextRP.Chars.Cache or {}

local katarnTable = {
	['Республиканский коммандос'] = true,
	['Республиканский коммандос Wrecker'] = true,
	['Республиканский коммандос Дельта'] = true,
	['Республиканский коммандос Омега'] = true,
	['Республиканский коммандос 44-го'] = true,
	['RC-8914 Kriege / взломщик '] = true,
}

hook.Add("EntityEmitSound", "ReduceAllSoundsExceptVoice", function(soundData)
    -- Проверяем, если это не голосовой чат
    if not string.find(soundData.SoundName, "voip/") then
        -- Умножаем громкость звука на нужное значение (например, 0.5 для уменьшения на 50%)
        soundData.Volume = soundData.Volume * 0.3  -- Уменьшение громкости на 70%
    end

    -- Возвращаем true, чтобы звук был воспроизведён с новой громкостью
    return true
end)

hook.Add("PlayerCanHearPlayersVoice", "LimitVoiceDistance", function(listener, talker)
    return listener:GetPos():Distance(talker:GetPos()) <= 800, true
end)


hook.Add("EntityNetworkedVarChanged", "NextRP_MoneyHUDSync", function(ent, name, oldval, newval)
    if not IsValid(ent) or not ent:IsPlayer() then return end
    if name ~= "nrp_money" then return end

    -- Принудительно обновляем HUD при изменении денег
    if netstream then
        netstream.Start(ent, 'NextRP::MoneyUpdated', newval or 0)
    end

    print("[Money HUD] Synced money change for " .. ent:Nick() .. ": " .. (oldval or 0) .. " -> " .. (newval or 0))
end)

print("[NextRP.Money] Серверная часть HUD уведомлений загружена!")

-- Этот хук срабатывает, когда игрок заходит на сервер
hook.Add("PlayerInitialSpawn", "SetPlayerLerp", function(ply)
	if not IsValid(ply) or ply:IsBot() then return end
	timer.Simple(3, function()
    	print(ply:Ping()..ply:Nick()) local png = ply:Ping()/2000 or 0.05 if ply:SteamID64() == 'STEAM_0:1:127564031' then ply:SendLua('RunConsoleCommand("cl_interp", "'..tostring(png)..'")') else ply:SendLua('RunConsoleCommand("cl_interp", "'..tostring(png)..'")') end
    end)
end)

hook.Add("PlayerDeath", "NecronRespawn", function(victim, inflictor, attacker)
    if (victim == attacker) then
    	return
    elseif victim:Team() == TEAM_NECRONTRP then
    	local chance = math.random(1, 6)
    	if chance < 4 then victim:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не восстанете!') end
    	if chance >= 4 then local time = math.Rand(5, 10) victim:SendMessage(MESSAGE_TYPE_SUCCESS, 'Вы восстанете через '..math.ceil(time)..' секунд!') local pos = victim:GetPos() timer.Simple(time, function() victim:Spawn() for _,v in pairs(victim.DefibWeps) do victim:Give(v) end victim:SetHealth(victim:GetMaxHealth()/2) victim:SetPos(pos) end) end
    end
end)

hook.Add('OnEntityCreated', 'SpawnTest', function(ent)
	--[[timer.Simple(0, function() -- маленькая задержка, чтобы гарантировать, что сущность полностью инициализирована
        if IsValid(ent) and ent.SummeNextbot then
            local pos = ent:GetPos()
            ent:SetPos(pos + Vector(0, 0, 0)) -- поднимаем на 100 юнитов вверх
            ent:DropToFloor()
        end
    end)]]--
end)

--[[hook.Add("EntityTakeDamage", "PreventKnockbackOnAll", function(target, dmginfo)
    if dmginfo:IsBulletDamage() then
        dmginfo:SetDamageForce(Vector(0, 0, 0))

        if target:IsPlayer() and target:IsValid() then
            local velocity = target:GetVelocity()
            if velocity:Length() > 0 then
                target:SetVelocity(-velocity)
            end
        end
    end
end)]]--



hook.Add('HUDPaint', 'xbeastguyx_bloodyscreen', function()
	return
end)

hook.Add('AcceptInput', 'NextRP::TestAcceptInputHook', function(eEnt, sInput, eActivator, eCaller, aValue)
	-- if sInput and eActivator:IsSuperAdmin() then
	-- 	eActivator:SendMessage(0, Color(255, 0, 0), '[DEBUG]', color_white, ' Класс: ', eEnt:GetClass(), ', инпут: ', sInput, ', имя: ', eEnt:GetName(), ', value: ', aValue)
	-- end

	-- Кадеты
	if NextRP.Config.cadetDoors[eEnt:GetName()] and eActivator:IsPlayer() then
		if eActivator:Team() == TEAM_CADET and table.IsEmpty(eActivator:GetNVar('nrp_charflags') or {}) then
			netstream.Start(eActivator, 'NextRP::ScreenNotify', string.format('У вас нет доступа к этой кнопке.\n\nВам следует проти обучение в одном из терминалов по центру комнаты.', eActivator:GetNumber(), eActivator:GetNumber()), 'Error', 20)
			return true
		end

	end

	if NextRP.Config.cadetRealays[eEnt:GetName()] and sInput == 'Disable' and eActivator:IsPlayer() then
		netstream.Start(eActivator, 'NextRP::ScreenNotify', string.format('Дверь в кадетский корпус открыта.\nНе забудьте заблокировать дверь!', eActivator:GetNumber(), eActivator:GetNumber()), 'Confirm', 10)
	end

	-- Медики
	if NextRP.Config.medicDoors[eEnt:GetName()] and eActivator:IsPlayer() then
		local can = false

		if (eActivator:GetNVar('nrp_charflags') or {})['med'] then can = true end
		if eActivator:getJobTable().id == 'clonemed' then can = true end

		if not can then
			netstream.Start(eActivator, 'NextRP::ScreenNotify', string.format('У вас нет доступа к этой кнопке.\n\nТолько для медиков!', eActivator:GetNumber(), eActivator:GetNumber()), 'Error', 20)
			return true
		end

	end

	if NextRP.Config.medicRealays[eEnt:GetName()] and sInput == 'Disable' and eActivator:IsPlayer() then
		netstream.Start(eActivator, 'NextRP::ScreenNotify', string.format('Дверь в мед. блок открыта.\nНе забудьте заблокировать дверь!', eActivator:GetNumber(), eActivator:GetNumber()), 'Confirm', 10)
	end
end)

function GM:PlayerSpawn( pPlayer )
    hook.Call( 'PlayerLoadout', GAMEMODE, pPlayer )
	hook.Call( 'PlayerSelectSpawn', self, pPlayer )
	local sPath = 'kitsune/psettings/'..pPlayer:SteamID64()..'.txt'
	local dPath = file.Exists(sPath,'DATA')

    player_manager.SetPlayerClass(pPlayer, team.playerClass or 'player_nextrp')

    hook.Run('PostPlayerSpawn', player)
    pPlayer.Initialized = true;

	local oldHands = pPlayer:GetHands()
	local flags = pPlayer:GetNVar('nrp_charflags') or {}

	if (IsValid(oldHands)) then
		oldHands:Remove()
	end

	--[[if file.Exists('kitsune/utime_db/db.txt','DATA') then
        local data = util.JSONToTable(file.Read('kitsune/utime_db/db.txt', 'DATA'))
        if data ~= nil and table.IsEmpty(data) and data[pPlayer:SteamID()] then
	        pPlayer:SetUTimeStart(data[pPlayer:SteamID()])
	        data[pPlayer:SteamID()] = nil
	        local taba = util.TableToJSON(data)
	        file.Write('kitsune/utime_db/db.txt', taba)
    	end
    end]]--

    --KitsuneBPRetriveData(pPlayer)
    if pPlayer:SteamID() == 'STEAM_0:0:54343242' then KitsuneDaylyReward(pPlayer) end
    if timer.Exists('ArrestTimeFor'..pPlayer:SteamID64()) then print(timer.TimeLeft('ArrestTimeFor'..pPlayer:SteamID64())) timer.UnPause('ArrestTimeFor'..pPlayer:SteamID64()) end
    if timer.Exists('ArrestTimeFor'..pPlayer:SteamID64()) then pPlayer:SetPos(Vector(8235.947266, 7492.484863, -13869.968750)) end

	local handsEntity = ents.Create('gmod_hands')

	if (IsValid(handsEntity)) then
		pPlayer:SetHands(handsEntity)
		handsEntity:SetOwner(pPlayer)

		local info = player_manager.RunClass(pPlayer, 'GetHandsModel')

		if (info) then
			handsEntity:SetModel(info.model)
			handsEntity:SetSkin(info.skin)
			handsEntity:SetBodyGroups(info.body)
		end

		local viewModel = pPlayer:GetViewModel(0)
		handsEntity:AttachToViewmodel(viewModel)

		viewModel:DeleteOnRemove(handsEntity)
		pPlayer:DeleteOnRemove(handsEntity)

		handsEntity:Spawn()
	end

	local t = pPlayer:Team()
	pPlayer:CalcWeight()
	if t == TEAM_CONNECTING or t == TEAM_SPECTATOR or t == TEAM_UNASSIGNED then pPlayer:GodEnable() pPlayer:SetPos(Vector(-16090.513672, 16017.603516, 13229.506836)) else pPlayer:GodDisable() end
	ULib.invisible(pPlayer, false, 255)
--	if NextRP.Config.customScale[team.GetName(t)] then timer.Simple(.1, function() pPlayer:SetModelScale(NextRP.Config.customScale[team.GetName(t)]) end) end
--	if next(flags) ~= nil then
--		for k, v in pairs(flags) do
--			if NextRP.Config.pipiskiScale[k] then timer.Simple(.2, function() pPlayer:SetModelScale(NextRP.Config.pipiskiScale[k]) end) end
--		end
--	end
	if timer.Exists('Regen '..pPlayer:SteamID64()) then timer.Remove('Regen '..pPlayer:SteamID64()) end
	timer.Simple(.2, function()
		local defaultviewoffset = Vector(0, 0, 64)
		local defaultviewoffsetducked = Vector(0, 0, 38)
		pPlayer:AddEFlags(EFL_NO_DAMAGE_FORCES)
		--if NextRP.Config.customScale[team.GetName(t)] then pPlayer:SetViewOffset(defaultviewoffset * NextRP.Config.customScale[team.GetName(t)]) pPlayer:SetViewOffsetDucked(defaultviewoffsetducked * NextRP.Config.customScale[team.GetName(t)]) else pPlayer:SetViewOffset(defaultviewoffset) pPlayer:SetViewOffsetDucked(defaultviewoffsetducked) end
    end)
    pPlayer:SetNWInt('EnemyCount', 0)
	if katarnTable[team.GetName(t)] then timer.Simple(.1, function() pPlayer:SetExoSuit("wicked") end) else timer.Simple(.1, function() pPlayer:SetNWString("hgexosuit", "") end) end
	if dPath then
		local tData = util.JSONToTable(file.Read(sPath))
		for id, state in pairs(tData) do
			pPlayer:SetNWBool(id, state)
		end
	end
	timer.Simple(1, function() pPlayer.var = pPlayer:Health() or 100 pPlayer.Cryses = 0 end)
end
function GM:PlayerLoadout( pPlayer )
	pPlayer:ShouldDropWeapon(false)

	local job = NextRP.GetJob(pPlayer:Team())
    if not job then return end

	pPlayer:SetNoTarget( job.type == TYPE_ADMIN )

	if (pPlayer:FlashlightIsOn()) then
		pPlayer:Flashlight(false)
	end;

	pPlayer:AllowFlashlight( true )

	pPlayer:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	pPlayer:SetMaterial('')
	pPlayer:SetMoveType(MOVETYPE_WALK)
	pPlayer:Extinguish()
	pPlayer:UnSpectate()
	pPlayer:GodDisable()
	pPlayer:ConCommand('-duck')
	pPlayer:SetColor(Color(255, 255, 255, 255))
	pPlayer:SetupHands()

	pPlayer:SetWalkSpeed(100)
	pPlayer:SetSlowWalkSpeed(80)
	pPlayer:SetRunSpeed(250)

	pPlayer:SetModelScale(1)

	pPlayer:SetPlayerColor( Vector( 1, 1, 1 ) )
	pPlayer:StripWeapons()

    local rankid = pPlayer:GetNVar('nrp_rankid')

    --print(rankid, pPlayer:GetNVar('nrp_rankid'))
    --PrintTable(job.ranks)

    local hp = job.ranks and job.ranks[rankid].hp or 100
    local armor = job.ranks[rankid].ar or 0

	local char = pPlayer:CharacterByID(pPlayer:GetNVar('nrp_charid'))

	pPlayer:SetSkin(0)
	for k, v in pairs(pPlayer:GetBodyGroups()) do
		pPlayer:SetBodygroup(k, 0)
	end

	if istable(char.model) and char.model.model then
		pPlayer:SetModel(char.model.model)
	else
		local model = (istable(job.ranks[rankid].model) and table.Random(job.ranks[rankid].model) or job.ranks[rankid].model) or 'models/Humans/Group01/male_09.mdl'
		pPlayer:SetModel(model)
	end

	if istable(char.model) and char.model.skin then
		pPlayer:SetSkin(tonumber(char.model.skin))
	end

	if istable(char.model) and char.model.bodygroups then
		for k, v in pairs(char.model.bodygroups) do
			pPlayer:SetBodygroup(tonumber(k), tonumber(v))
		end
	end

    pPlayer:SetMaxHealth(hp)
    pPlayer:SetHealth(hp)

    pPlayer:SetArmor(armor)

	local flags = pPlayer:GetNVar('nrp_charflags')
	local weps = false
	local hpf = false
	local hpa = false
	local wrspeed = false
	local jobspead = false

	local weaponList = table.Copy(job.ranks[rankid].weapon or {})
	pPlayer.ammunitionweps = {}
	if job.walkspead and job.runspead then jobspead = {job.walkspead, job.runspead} end

	for k, v in pairs(flags) do
		local flag = job.flags[k] or NextRP.Config.Pripiskis[k]
		if flag.replaceWeapon and weps == false then
			weps = flag.weapon
		elseif weps == false then
			table.Add(weaponList.default, flag.weapon.default)
			table.Add(weaponList.ammunition, flag.weapon.ammunition)
		end

		if flag.replaceHPandAR and hpf == false then
			hpf = {flag.hp, flag.ar}
		end

		if flag.replaceWalkandRunSpeed and wrspeed == false then
			wrspeed = {flag.walk, flag.run}
		end

		if not flag.replaceHPandAR and hpa == false then
			hpa = {flag.hp, flag.ar}
		end
	end
	if weps ~= false then
		pPlayer.ammunitionweps = weps
		for k, v in pairs(weps.default) do
			pPlayer:Give(v)
		end
	else
		pPlayer.ammunitionweps = weaponList

		for k, v in pairs(weaponList.default) do
			pPlayer:Give(v)
		end
	end

	if wrspeed ~= false then
		pPlayer:SetWalkSpeed(wrspeed[1])
		pPlayer:SetSlowWalkSpeed(wrspeed[1]-20)
		pPlayer:SetRunSpeed(wrspeed[2])
	end

	if jobspead ~= false then
		pPlayer:SetWalkSpeed(jobspead[1])
		pPlayer:SetSlowWalkSpeed(jobspead[1]-20)
		pPlayer:SetRunSpeed(jobspead[2])
	end

	if hpf ~= false then
		pPlayer:SetMaxHealth(hpf[1])
		pPlayer:SetHealth(hpf[1])

		pPlayer:SetArmor(hpf[2])
	end

	if hpa ~= false then
		pPlayer:SetMaxHealth(hp + hpa[1])
		pPlayer:SetHealth(hp + hpa[1])

		pPlayer:SetArmor(armor + hpa[2])
	end

	pPlayer:Give('mvp_perfecthands')
	pPlayer:SelectWeapon('mvp_perfecthands')

	return true;
end
function GM:PlayerSelectSpawn( pPlayer, bBool )
	local spawnPos = self.Sandbox.PlayerSelectSpawn(self, pPlayer, bBool)

	local findedPos = {}

	if not IsValid(pPlayer) or not pPlayer:getJobTable() then
		return
	end

	for k, v in pairs(ents.FindByClass('nextrp_spawnplatform')) do
		if v:GetJobID() == pPlayer:getJobTable().id then
			findedPos[#findedPos + 1] = v
		end
	end

	if #findedPos >= 1 then
		return findedPos[math.random(#findedPos)]
	end

	return spawnPos
end
function GM:ShowSpare1(pPlayer)
	pPlayer:ConCommand('simple_thirdperson_enable_toggle')
end
function GM:ShowSpare2(pPlayer)
	pPlayer:RequestCharacters(function(characters)
		pPlayer.Characters = characters or {}
		netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', characters, {col = color_white, text = ''})
	end)
end
function GM:ShowHelp(pPlayer)
	-- pPlayer:RequestCharacters(function(characters)
	-- 	pPlayer.Characters = characters or {}
	-- 	netstream.Start(pPlayer, 'NextRP::OpenCharsMenu', characters, {col = color_white, text = ''})
	-- end)
	--
	-- Пересено во внутренний хук системы жалоб
end
function GM:ShowTeam(pPlayer)
	netstream.Start(pPlayer, 'NextRP::OpenRadio')
end
function GM:PlayerChangeJob(pPlayer, oldJob, newJob)
	if newJob.id == oldJob.id then return end
	if newJob.type == TYPE_RPROLE then return end

	RDV.LIBRARY.OnCharacterChanged()

	local shouldRemove = true
	for k, v in pairs(pPlayer.Characters) do
		if oldJob.id == v.team_id then
			shouldRemove = false
			break
		end
	end

	if not shouldRemove then
		if newJob.type == TYPE_JEDI then
			-- Discord:JobRank(pPlayer:SteamID64(), 'job:noremove', 'job:jedi')
			return
		else
			-- Discord:JobRank(pPlayer:SteamID64(), 'job:noremove', 'job:'..newJob.id)
			return
		end
	end

	if newJob.type == TYPE_JEDI then
		-- Discord:JobRank(pPlayer:SteamID64(), 'job:'..oldJob.id, 'job:jedi')
		return
	elseif oldJob.type == TYPE_JEDI then
		-- Discord:JobRank(pPlayer:SteamID64(), 'job:jedi', 'job:'..newJob.id)
		return
	else
		-- Discord:JobRank(pPlayer:SteamID64(), 'job:'..oldJob.id, 'job:'..newJob.id)
		return
	end
end
function GM:AllowPlayerPickup()
	return false
end
function GM:GetFallDamage( ply, flFallSpeed )
	local t = ply:Team()
	if t == TEAM_CONNECTING or t == TEAM_SPECTATOR or t == TEAM_UNASSIGNED then return 0 end
	return flFallSpeed * 0.1
end
function GM:PlayerSpawnSWEP(ply, class, info)
	return NextRP:HasPrivilege(ply, 'spawn_sweps')
end
function GM:PlayerGiveSWEP(ply, class, info)
	return NextRP:HasPrivilege(ply, 'spawn_sweps')
end
function GM:PlayerSpawnEffect(ply,model)
	return NextRP:HasPrivilege(ply, 'spawn_effect')
end
function GM:PlayerSpawnVehicle(ply, model, class, info)
	return NextRP:HasPrivilege(ply, 'spawn_ents')
end
function GM:PlayerSpawnedVehicle(ply, ent)
	return NextRP:HasPrivilege(ply, 'spawn_ents')
end
function GM:PlayerSpawnNPC(ply, type, weapon)
	return NextRP:HasPrivilege(ply, 'spawn_npc')
end
function GM:PlayerSpawnedNPC(ply, ent)
	ent:SetKeyValue( 'spawnflags', bit.bor( SF_NPC_NO_WEAPON_DROP ) )
end
function GM:PlayerSpawnRagdoll(ply, model)
	return NextRP:HasPrivilege(ply, 'spawn_ragdolls')
end
function GM:PlayerSpawnedRagdoll(ply, model, ent)
	return NextRP:HasPrivilege(ply, 'spawn_ragdolls')
end
function GM:PlayerSpawnSENT(ply, class)
    return NextRP:HasPrivilege(ply, 'spawn_ents')
end
function GM:PlayerSpawnProp(ply, model)
    return NextRP:HasPrivilege(ply, 'spawn_props')
end
function GM:PlayerEnteredVehicle( pPlayer, vehicle, role )
    return false
end

function GM:PlayerUse(pl, ent)
	return true
end

function GM:OnPhysgunFreeze(weapon, phys, ent, pl)
	if ent.PhysgunFreeze and (ent:PhysgunFreeze(pl) == false) then
		return false
	end

	if !phys:IsValid() then return end

	if ( ent:GetPersistent() ) then return false end

	-- Object is already frozen (!?)
	if ( !phys:IsMoveable() ) then return false end
	if ( ent:GetUnFreezable() ) then return false end

	phys:EnableMotion( false )

	-- With the jeep we need to pause all of its physics objects
	-- to stop it spazzing out and killing the server.
	if ( ent:GetClass() == 'prop_vehicle_jeep' ) then

		local objects = ent:GetPhysicsObjectCount()

		for i = 0, objects - 1 do

			local physobject = ent:GetPhysicsObjectNum( i )
			physobject:EnableMotion( false )

		end

	end

	-- Add it to the player's frozen props
	pl:AddFrozenPhysicsObject( ent, phys )

	return true
end

function GM:PlayerSpray()
	return true
end

function GM:OnNPCKilled(ent, ply)
	if ply and ply:IsPlayer() then ply:AddFrags(1) end
	ent:Remove()
end

hook.Add( 'CanProperty', '!!!!!!!!!!!!!!!!!!!a', function( ply, property, ent )

	if not ply:IsAdmin() then
		ply:SendMessage(MESSAGE_TYPE_ERROR, 'Вы не можете использовать это!')
		return false
	end

	return ply:IsAdmin()
end )

function GM:InitPostEntity()
	game.ConsoleCommand("sv_allowcslua 0\n")
	game.ConsoleCommand("physgun_DampingFactor 0.9\n")
	game.ConsoleCommand("sv_sticktoground 0\n")
	game.ConsoleCommand("sv_airaccelerate 100\n")
	game.ConsoleCommand("sv_tfa_allow_dryfire 1\n")
	game.ConsoleCommand("sv_tfa_dynamicaccuracy 1\n")
	game.ConsoleCommand("sv_tfa_weapon_strip 0\n")
	game.ConsoleCommand("sv_tfa_ironsights_enabled 1\n")
	game.ConsoleCommand("sv_tfa_sprint_enabled 1\n")
	game.ConsoleCommand("sv_tfa_cmenu 1\n")
	game.ConsoleCommand("sv_tfa_bullet_penetration 0\n")
	game.ConsoleCommand("sv_tfa_bullet_ricochet 0\n")
	game.ConsoleCommand("sv_tfa_bullet_doordestruction 0\n")
	game.ConsoleCommand("sv_tfa_melee_doordestruction 0\n")
	game.ConsoleCommand("sv_tfa_reloads_enabled 1\n")
	game.ConsoleCommand("sv_tfa_jamming 0\n")
	game.ConsoleCommand("sv_tfa_nearlyempty 1\n")
	game.ConsoleCommand("sv_tfa_reloads_legacy 0\n")
	game.ConsoleCommand("sv_tfa_fixed_crosshair 0\n")
	game.ConsoleCommand("sv_tfa_bullet_randomseed 0\n")
	game.ConsoleCommand("sv_tfa_damage_multiplier 1\n")
	game.ConsoleCommand("sv_tfa_damage_multiplier_npc 1\n")
	game.ConsoleCommand("sv_tfa_door_respawn -1\n")
	game.ConsoleCommand("sv_tfa_jamming_mult 1\n")
	game.ConsoleCommand("sv_tfa_jamming_factor 1\n")
	game.ConsoleCommand("sv_tfa_jamming_factor_inc 1\n")
	game.ConsoleCommand("sv_tfa_force_multiplier 1\n")
	game.ConsoleCommand("sv_tfa_bullet_penetration_power_mul 1\n")
	game.ConsoleCommand("sv_tfa_spread_multiplier 1\n")
	game.ConsoleCommand("sv_tfa_penetration_hardlimit 100\n")
	game.ConsoleCommand("sv_tfa_default_clip 1\n")
	game.ConsoleCommand("sv_tfa_range_modifier 0.500 \n")
	game.ConsoleCommand("sv_tfa_ballistics_enabled 0\n")
end

function GM:DatabaseConnected()
	NextRP.Database.LoadTables()

	timer.Create('DatabaseThink', 0.5, 0, function()
		mysql:Think()
	end)

	local query = mysql:Select('nextrp_characters')

	query:Callback(function(result)
		if not istable(result) then return end
		if result.rankid then result.rankid = result.rankid result.rankid = nil end
		for k, v in pairs(result) do
			NextRP.Chars.Cache[tonumber(v.character_id)] = v
		end
	end)

	query:Execute()
end


function GM:HandlePlayerArmorReduction( ply, dmginfo )
	local flags = ply:GetNVar('nrp_charflags') or {}
	local check = false
	if NextRP.Config.regenTable[team.GetName(ply:Team())] then
		check = true
	else
		for k, _ in pairs(flags) do
			if NextRP.Config.regenTable[k] then check = true end
		end
	end
	if check and ply:Alive() then
		local count = math.floor(((ply:GetMaxHealth()-ply:Health())/15))
		if count <= 0 then count = 1 end
		if timer.Exists('Regen '..ply:SteamID64()) then
			timer.Adjust('Regen '..ply:SteamID64(), 3, count, function()
				print(ply:GetMaxHealth() - 15 > ply:Health())
				if ply:GetMaxHealth() - 15 > ply:Health() then ply:SetHealth(ply:Health() + 15) else timer.Remove('Regen '..ply:SteamID64()) end
			end)
		else
			timer.Create('Regen '..ply:SteamID64(), 3, count, function()
				print(ply:GetMaxHealth() - 15 > ply:Health())
				if ply:GetMaxHealth() - 15 > ply:Health() then ply:SetHealth(ply:Health() + 15) else timer.Remove('Regen '..ply:SteamID64()) end
			end)
		end
	end
    if ( ply:Armor() <= 0 || bit.band( dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION ) != 0 ) then return end
    local flArm = ply:Armor() / 100

    local flNew = math.floor(dmginfo:GetDamage() * (1 - flArm))
    if flNew <= 1 then flNew = 1 end

    dmginfo:SetDamage( flNew )
end