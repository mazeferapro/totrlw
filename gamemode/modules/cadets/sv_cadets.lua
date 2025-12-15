local cfg = NextRP.Cadets.Config.Jobs
netstream.Hook('NextRP::TestComplete', function(pPlayer, tAnswers, nChoose)
    if not cfg[nChoose] then 
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Выбранная специализация не найдена!')
        return 
    end

    -- Проверяем тест
    local st = true
    for i = 1, 10 do
        if tAnswers[i] == true then continue end
        st = false
        break
    end

    if st then
        local jobConfig = cfg[nChoose]
        local jobIDs = jobConfig[2] -- ID профессий
        local targetJobID = jobIDs[1] -- Берем первую профессию из списка
        
        -- Находим профессию по ID
        local targetJob = NextRP.GetJobByID(targetJobID)
        if not targetJob then
            pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Профессия "' .. targetJobID .. '" не найдена!')
            return
        end

        -- Находим индекс профессии
        local teamIndex = targetJob.index
        
        -- Выдаем профессию напрямую
        pPlayer:ChangeTeam(teamIndex, false)
        pPlayer:Spawn()
        
        pPlayer:SendMessage(MESSAGE_TYPE_SUCCESS, 'Тест успешно пройден! Вам выдана профессия: ' .. targetJob.name)
        
    else
        pPlayer:SendMessage(MESSAGE_TYPE_ERROR, 'Тест не сдан! Попробуйте еще раз.')
    end

end)