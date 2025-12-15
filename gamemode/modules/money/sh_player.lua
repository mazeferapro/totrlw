--- @classmod Player

local pMeta = FindMetaTable('Player')

--- Получает количество денег
-- @realm shared
-- @tretrun number Количество денег на счету
function pMeta:GetMoney()
    return self:GetNVar('nrp_money')
end

--- Проверяет может ли игрок позволить себе что-то на сумму
-- @realm shared
-- @tparam number nSum Сумма для проверки
-- @tretrun boolean Может или нет
function pMeta:CanAfford(nSum)
    if tonumber(nSum) <= 0 then return false end
    local curMoney = self:GetMoney()

    return (curMoney - nSum) >= 0
end

function pMeta:GetLevel()
    local id = self:GetNVar('nrp_charid')
    if not id then return end
    local chr = self:CharacterByID(id)
    return chr.level or 1
end