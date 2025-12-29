--- @classmod Player

local pMeta = FindMetaTable('Player')

pMeta.OldName = pMeta.OldName or pMeta.Name
pMeta.OldNick = pMeta.OldNick or pMeta.Nick

--- Имя персонажа
-- @realm shared
-- @treturn string CharacterFullname 
function pMeta:Name()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_fullname') or self:OldName()
end

--- Имя персонажа
-- @realm shared
-- @treturn string CharacterFullname 
function pMeta:Nick()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_fullname') or self:OldName()
end

function pMeta:Nick1()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_nickname') or self:OldName()
end

--- Имя персонажа
-- @realm shared
-- @treturn string CharacterFullname 
function pMeta:FullName()
    if not IsValid(self) then
        return ''
    end
    return self:GetNVar('nrp_fullname') or self:OldName()
end

--- Фракция персонажа
-- @realm shared
-- @treturn number Faction 
function pMeta:Faction()
    if not IsValid(self) then
        return 1
    end
    return self:GetNVar('nrp_faction') or 1
end

