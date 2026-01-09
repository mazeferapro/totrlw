NextRP.Ammunition = NextRP.Ammunition or {}

NextRP.Ammunition.Config = {
    MaxSupply = 100000,       -- Максимум очков снабжения на сервере
    RegenAmount = 50,        -- Сколько восстанавливается
    RegenInterval = 300,      -- Раз в сколько секунд (1 минута)
}

-- Вспомогательная функция для получения таблицы профессии игрока
function NextRP.Ammunition:GetJobData(ply)
    if not IsValid(ply) then return {} end
    
    local teamID = ply:Team()
    
    -- Пытаемся получить данные профессии из NextRP.Jobs
    if NextRP.Jobs and NextRP.Jobs[teamID] then
        return NextRP.Jobs[teamID]
    end
    
    -- На всякий случай, если структура другая, проверяем стандартный getJobTable
    if ply.getJobTable then
        return ply:getJobTable()
    end

    return {}
end