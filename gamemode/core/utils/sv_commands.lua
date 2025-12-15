local function WrongArgs(MODULE, pPlayer)
    MODULE:SendNotify(pPlayer, 'Неверные аргументы!', nil, 4, MODULE.Config.Colors.Red)
end

local function LoadCommands(MODULE)

    local MESSAGES_TYPE = MODULE.Config.Chat.MESSAGES_TYPE

    // chat commands

    MODULE:Command('y').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 550, Color(255, 69, 56), '[Крик] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText )

        hook.Run('Paws.Lib.CommandRun.Chat', 'y', pPlayer, sText)
    end

    MODULE:Command('w').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 150, Color(255, 69, 56), '[Шепот] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText )

        hook.Run('Paws.Lib.CommandRun.Chat', 'w', pPlayer, sText)
    end

    // rp commands

    MODULE:Command('me').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[ME] ', Color(252, 186, 255), pPlayer:FullName(), ' ', sText )

        hook.Run('Paws.Lib.CommandRun.RP', 'me', pPlayer, sText)
    end

    MODULE:Command('do').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[DO] ', Color(252, 186, 255), sText, ' ( ', pPlayer:FullName(), ' )' )

        hook.Run('Paws.Lib.CommandRun.RP', 'do', pPlayer, sText)
    end

    MODULE:Command('try').Run = function( pPlayer, sText )
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        local Chance = math.random(0, 100) >= 50
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[TRY] ', Color(252, 186, 255), pPlayer:FullName(), ' ', Chance and Color(83, 199, 0) or Color(255, 69, 56), Chance and 'успешно' or 'безуспешно', Color(252, 186, 255), ' выполнил действие: ', sText )

        hook.Run('Paws.Lib.CommandRun.RP', 'try', pPlayer, sText, Chance)
    end

    MODULE:Command('roll').Run = function( pPlayer, sText )
        // if sText != '' or sText != nil then WrongArgs(MODULE, pPlayer) return end
        local Chance = math.random(0, 100)
        MODULE:SendMessageDist(pPlayer, MESSAGES_TYPE.RP, 250, Color(255, 69, 56), '[ROLL] ', Color(252, 186, 255), 'Шанс выполнения ', Chance, ' ( ', pPlayer:FullName(), ' )' )

        hook.Run('Paws.Lib.CommandRun.RP', 'roll', pPlayer, sText, Chance)
    end

    // animation commands

    MODULE:Command('salute').Run = function( pPlayer, sText )
        pPlayer:Say('/me исполнил воинское приветствие')
        pPlayer:DoAnimationEvent( ACT_GMOD_TAUNT_SALUTE )
    end

    MODULE:Command('bow').Run = function( pPlayer, sText )
        pPlayer:Say('/me поклонился')
        pPlayer:DoAnimationEvent( ACT_GMOD_GESTURE_BOW )
    end

    MODULE:Command('forward').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Вперёд"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_FORWARD )
    end

    MODULE:Command('group').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Сгруппироваться"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_GROUP )
    end

    MODULE:Command('halt').Run = function( pPlayer, sText )
        pPlayer:Say('/me показал сигнал "Стоп"')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_HALT )
    end

    MODULE:Command('point').Run = function( pPlayer, sText )
        pPlayer:Say('/me указал')
        pPlayer:DoAnimationEvent( ACT_SIGNAL_FORWARD )
        pPlayer:ConCommand('mcompass_spot')
    end


    // ooc commands

    local function ooc(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[OOC] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText )

        hook.Run('Paws.Lib.CommandRun.OOC', 'ooc', pPlayer, sText)
    end

    MODULE:Command('ooc').Run = ooc
    MODULE:Command('/').Run = ooc
    MODULE:Command('a').Run = ooc

    local function looc(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 250, Color(255, 129, 56), '[LOOC]', color_white, ' (( ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', color_white, sText, ' ))' )

        hook.Run('Paws.Lib.CommandRun.LOOC', 'looc', pPlayer, sText)
    end

    MODULE:Command('looc').Run = looc
    MODULE:Command('l').Run = looc
    MODULE:Command('lo').Run = looc

    // servermsg

    local function servermsg(pPlayer, sText)
        if !pPlayer:IsAdmin() then return end
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        MODULE:SendMessageDist(pPlayer, -1, 0, Color(255, 129, 56), '[СЕРВЕР] ', Color(255,0,0), sText )
    end

    MODULE:Command('sm').Run = servermsg
    MODULE:Command('servermessage').Run = servermsg
    MODULE:Command('servermsg').Run = servermsg

    local function getmodel(pPlayer, sText)
        local ent = pPlayer:GetEyeTrace().Entity

        if IsValid(ent) then
            MODULE:SendMessage(pPlayer, -1, 'Модель получена: ', ent:GetModel(), ' и скопирована в буфер обмена.')
            pPlayer:SendLua('SetClipboardText("'..ent:GetModel()..'")')
        end
    end

    MODULE:Command('getmodel').Run = getmodel

    local function base(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        for k, v in ipairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[БАЗА] ', team.GetColor(pPlayer:Team()), pPlayer:FullName(), ': ', Color(252, 219, 3), sText )
        end
    end

    MODULE:Command('base').Run = base
    MODULE:Command('advert').Run = base
    MODULE:Command('ad').Run = base

    local function event(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end

        for k, v in ipairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[RP]', color_white, ' > ', Color(252, 219, 3), sText, color_white, ' ', pPlayer:Name() )
        end

        -- Discord.Backend.API:Send(
        --     Discord.OOP:New('Message'):SetChannel('Relay'):SetEmbed({
        --         title = 'СОБЫТИЕ',
        --         color = 14790956,
        --         description = '**На сервере произошло событие**:\n> '..sText,
        --     }):ToAPI()
        -- )
    end

    MODULE:Command('event').Run = event
    MODULE:Command('e').Run = event
    MODULE:Command('rp').Run = event

    local function venator(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end
        for k, v in ipairs(player.GetHumans()) do
            MODULE:SendMessage(v, -1, Color(255, 129, 56), '[ВЕНАТОР]', color_white, ' > ', Color(252, 219, 3), sText )
        end
    end

    MODULE:Command('venator').Run = venator
    MODULE:Command('v').Run = venator

    local function ScreenNotify(pPlayer, sText)
        if not pPlayer:IsSuperAdmin() then return end
        netstream.Start(nil, 'NextRP::ScreenNotify', sText)
    end

    MODULE:Command('sn').Run = ScreenNotify

    local function CrysDpor(pPlayer)
        local tr = pPlayer:GetEyeTrace()
        if pPlayer.Cryses and pPlayer.Cryses <= 0 then MODULE:SendMessage(pPlayer, -1, 'У тебя нет кристаллов!') return end
        pPlayer.Cryses = pPlayer.Cryses - 1
        local ent = ents.Create('money_crys')
        --ent:SetPos(pPlayer:GetPos()+Vector(20, 0, 100))
        local dir = (tr.HitPos-tr.StartPos):GetNormalized()
        local dist = tr.StartPos:Distance(tr.HitPos) > 500 and 500 or tr.StartPos:Distance(tr.HitPos)
        local pos = tr.StartPos + dir * dist*.15
        ent:SetPos(pos)
        ent:Spawn()
        pPlayer:CrystalSpeed()
        MODULE:SendMessage(pPlayer, -1, 'Ты выбросил один кристалл! У тебя осталось '..pPlayer.Cryses..'!')
    end

    MODULE:Command('dropcrys').Run = CrysDpor

    local function tst(pPlayer, sText)
        if not pPlayer:IsSuperAdmin() then return end
        sText = tonumber(sText) or 1
        --local wep = weapons.GetStored('arc9_k_dc15le')
        --sup_inv.ItemMeta:Recreate('arc9_k_dc15x')
        --PrintTable(FindMetaTable('Entity'))
        --local ww = sup_items['arc9_k_dc15le']
        --print(sup_inv.GetByClass('arc9_k_dc15le').isWeapon)
        --print(wep.IsWeapon)
        --print(wep:IsWeapon() and 'tru' or 'fals')
        --pPlayer:Give('arc9_k_dc17ext', true, true)dcompas') then
        --print(pPlayer:GetNWBool('Dhelm'))
        --pPlayer:SetMoney(5000000)
        --PrintTable()
        --[[local current_time = os.date("*t", os.time() + (NextRP.AutoEvents.Config.Settings.timezone_offset * 3600))
        local current_minutes = current_time.hour * 60 + current_time.min
        for _, schedule_item in pairs(NextRP.AutoEvents.Config.Schedule) do
            local schedule_minutes = schedule_item.hour * 60 + schedule_item.minute

            if current_minutes == notification_minutes and not NextRP.AutoEvents.Config.Settings.schedule_countdown_enabled then
                local map_data = NextRP.AutoEvents.Config.Maps[schedule_item.map]
                if map_data then
                    for _, ply in pairs(player.GetAll()) do
                        if IsValid(ply) then
                            ply:ChatPrint("[AutoEvents] Через 5 минут: " .. schedule_item.name .. " (" .. map_data.name .. ")")
                        end
                    end
                    print("[AutoEvents] Уведомление: " .. schedule_item.name)
                end
            end
        end]]--
        --print(Color(204, 57, 20):ToVector())
        --local mi = ents.FindByClass('medic_mri_monitor')
        --pPlayer:ChatPrint(#mi)
        --NextRP.Progression:AddXP(pPlayer, 100000)
        --pPlayer:SetPos(mi[2]:GetPos())
        local tr = pPlayer:GetEyeTrace().Entity
        --CrystalSpeed(pPlayer)
        pPlayer:Freeze(false)
        --NextRP.CRotR:Buy(pPlayer, 'pipiska2')
        --NextRP.CRotR:GetBoughtList(pPlayer)
        --MySQLite.query(string.format('SELECT * FROM `nextrp_crotr`'), function(result) netstream.Start(pPlayer, 'NextRP::CRotROpenAdmin', result) end)
        --NextRP.CRotR:GetBoughtList(pPlayer)
        --NextRP.CRotR:Buy(pPlayer, 'ppska2')
        --NextRP.CRotR:AddCrotrs(pPlayer, 5000)
        --print(isfunction(RDV.LIBRARY.OnCharacterChanged))
            RDV.LIBRARY.OnCharacterChanged(nil, nil)
        --pPlayer.tBought = nil
        --PrintTable(NextRP.AutoEvents.Config.Schedule)
        --[[tr:SetNextInvade(CurTime()+100)
        tr:SetLastCaptured(CurTime())
        print(tr:GetLastCaptured())
        print(tr:GetNextInvade())]]--
        --[[net.Start( "RASKO_NightvisionOn" )
            if sText == 1 then
                net.WriteBool(true)
            else
                net.WriteBool(false)
            end
        net.Send(pPlayer)]]--
        --pPlayer:ChatPrint()
        --PrintTable()

        --MedicineStomach
        --MedicineArm
        --MedicineChest
        --MedicineHead

        --pPlayer:SetNWInt('MedicineStomach', 50)
        --pPlayer:SetPos(Vector(8389.101562, 7413.427246, -13841.510742))
        --if tonumber(sText) == 2 then timer.Pause('tst'..pPlayer:SteamID64()) return end
        --if tonumber(sText) == 1 then timer.UnPause('tst'..pPlayer:SteamID64()) return end
        --if timer.Exists('tst'..pPlayer:SteamID64()) then pPlayer:ChatPrint(timer.TimeLeft('tst'..pPlayer:SteamID64())) else timer.Create('tst'..pPlayer:SteamID64(), 60, 1, function() pPlayer:ChatPrint('END') end) end
    end

    MODULE:Command('tst').Run = tst

    local function test1(pPlayer)
        if !pPlayer:IsSuperAdmin() then MODULE:SendMessage(pPlayer, -1, 'Не для тебя положено.') return end
        NextRP.CRotR:OpenUI(pPlayer)
    end

    MODULE:Command('test1').Run = test1


    local listBots = {}

    local function bottest(pPlayer, sText)
        if !pPlayer:SteamID() == 'STEAM_0:0:54343242' then return end
        if sText == '1' then
            for _, v in ipairs(player.GetBots()) do
                v:Kick()
            end
            return
        elseif sText == '2' then
            local jop = NextRP.GetJobByID('ct')
            local teamIndex = jop.index
            pPlayer:ChangeTeam(teamIndex, false)
        end

        if ( player.GetCount() < game.MaxPlayers() ) then

            --local num = #listBots or 1
            --local k = game.MaxPlayers() - player.GetCount()
            local iter = 1
            local jop = NextRP.GetJobByID('ct')
            local teamIndex = jop.index
            while iter <= 20 do
                local bt = player.CreateNextBot("Kishka_"..iter)
                bt:SetTeam(teamIndex)
                bt:Spawn()
                iter = iter + 1
            end
        end
    end

    MODULE:Command('testbot').Run = bottest

    local function npchp(pPlayer, sText)
        if !pPlayer:IsAdmin() then MODULE:SendMessage(pPlayer, -1, 'Не для тебя положено.') return end
        sText = tonumber(sText)
        local ent = pPlayer:GetEyeTrace().Entity
        if !ent:IsNPC() or sText == nil then MODULE:SendMessage(pPlayer, -1, 'Укажи хп или смотри на NPC.') return end
        ent:SetHealth(sText)
    end

    MODULE:Command('npchp').Run = npchp

    local function eventdelay(pPlayer, sText)
        if not pPlayer:IsAdmin() then return end
        --print(sText)
        if sText and sText ~= nil and sText ~= '' then
            sText = tonumber(sText)
            if sText and sText == nil or sText == '' then
                MODULE:SendMessage(pPlayer, -1, 'Нормально время укажи и мозга не еби, долбоеб мой друг.')
                return
            end
        end
        local next_event = NextRP.AutoEvents.FindNextScheduledEvent()
        for _, v in ipairs(NextRP.AutoEvents.Config.Schedule) do
            if v.hour == next_event.hour then
                if sText and sText ~= nil and sText ~= '' then
                    v.hour = v.hour + sText
                else
                    v.hour = v.hour + 1
                end
                MODULE:SendMessage(pPlayer, -1, 'Ивент "'..v.name..'" отсрочен на '..(sText ~= '' and sText or '1')..' час(а/ов). (до смены карты или рестарта)')
                --PrintTable(NextRP.AutoEvents.Config.Schedule)
                break
            end
        end
        NextRP.AutoEvents.StartScheduleCountdown()
    end

    MODULE:Command('eventdelay').Run = eventdelay

    local function mscale(pPlayer, sText)
        if not pPlayer:IsAdmin() then return end
        sText = string.Replace(sText, ' ', '')
        if sText[1] ~= '@' and sText[1] ~= '^' then WrongArgs(MODULE, pPlayer) return end
        local scale = tonumber(sText[2]..sText[3]) or 1
        if sText[1] == '@' then
            local ent = pPlayer:GetEyeTrace().Entity
            if not ent or not ent:IsPlayer() then MODULE:SendMessage(pPlayer, -1, 'Цель не является игроком. Чтобы применить на себя используйте ^.') return end
            ent:SetModelScale(scale, 1)
        else
            pPlayer:SetModelScale(scale, 1)
        end
        ScaleFixV(sText[1] == '^' and pPlayer or ent, scale)
    end

    MODULE:Command('mscale').Run = mscale


    local function eventpause(pPlayer, sText)
        if not pPlayer:IsAdmin() then return end
        sText = tonumber(sText)
        if sText == '' or sText == nil then MODULE:SendMessage(pPlayer, -1, 'Ошибка! Не указано значение (0/1)') return end
        if sText == 0 then
            if timer.Exists('AutoEvents_HUD_Update') then timer.UnPause('AutoEvents_HUD_Update') end
            if timer.Exists('AutoEvents_Schedule') then timer.UnPause('AutoEvents_Schedule') MODULE:SendMessage(pPlayer, -1, 'Отсчет возобновлен!') end
        elseif sText == 1 then
            if timer.Exists('AutoEvents_HUD_Update') then timer.Pause('AutoEvents_HUD_Update') end
            if timer.Exists('AutoEvents_Schedule') then timer.Pause('AutoEvents_Schedule') MODULE:SendMessage(pPlayer, -1, 'Отсчет остановлен! Не забудьте его возобновить.') end
        else
            MODULE:SendMessage(pPlayer, -1, 'Значение должно быть 0 или 1')
        end
    end

    MODULE:Command('eventpause').Run = eventpause

    local function radio(pPlayer, sText)
        if sText == '' or sText == nil then WrongArgs(MODULE, pPlayer) return end

        for k, v in ipairs(player.GetHumans()) do
            if (v:GetFrequency() == pPlayer:GetFrequency()) and v:GetSpeaker() then
                MODULE:SendMessage(v, -1, Color(255, 129, 56), '[ ', pPlayer:GetFrequency(), ' ] ', team.GetColor(pPlayer:Team()), pPlayer:Name(), color_white, ':', sText )
            end
        end
    end

    MODULE:Command('radio').Run = radio
    MODULE:Command('r').Run = radio
end

hook.Add('Paws.lib.Loaded', 'LoadCommands', LoadCommands)

if PAW_MODULE('lib').Loaded then
    LoadCommands(PAW_MODULE('lib'))
end