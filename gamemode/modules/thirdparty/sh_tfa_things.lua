-- hook.Add('TFA_Initialize', 'NextRP::ApplyWeaponSkin', function(weapon)
--     weapon.VElements['dc15a'].material = '1camo_test/dc15a/l115/orange'
--     weapon.WElements['dc15a'].material = '1camo_test/dc15a/l115/orange'

--     weapon.TracerName = 'rw_sw_laser_purple'
--     weapon.ImpactEffect = 'rw_sw_impact_purple'

--     weapon:ClearMaterialCache()
-- end)

local patchTbl = {
    ['rw_sw_dc15s'] = {
        [1] = {'nrp_stun'},
    },
	['rw_sw_dc17'] = {
		[1] = {'nrp_hook'}
	}
}

hook.Add('TFA_PreInitAttachments', 'NextRP::AddAtachments', function(wep)
    if not IsValid(wep) then return end
	local tbl = patchTbl[wep:GetClass()]
	
	if not IsValid(wep.Owner) or not wep.Owner:getJobTable() then
		return
	end

	if wep:GetClass() == 'rw_sw_dc17' and wep.Owner:getJobTable().id ~= '41trooper' then return end
	if not tbl then return end

	wep.Attachments = wep.Attachments or {}

	for k,v in pairs(tbl) do
		if not wep.Attachments[k] then
			wep.Attachments[k] = {}
		end
	end

	for k, v in pairs(wep.Attachments) do
		local selname
		if v.sel then
			if isnumber(v.sel) and v.sel >= 0 then
				selname = v.atts[v.sel]
			elseif isstring(v.sel) then
				selname = v.sel
			end
		end

		v.atts = v.atts or {}
		for _, att in ipairs(tbl[k] or {}) do
			table.insert(v.atts, att)
		end

		if selname then
			for n,m in pairs(v.atts) do
				if m == selname then
					v.sel = n
				end
			end
		end
	end
end)

local function createHook(self)
	if IsValid(self.Hook) then
		self.Hook:Remove()
	end
	
	if IsValid(self.Owner.rhook) then
		self.Owner.rhook:Remove()
	end
	
	local ang = self.Owner:EyeAngles()
	ang:RotateAroundAxis(self.Owner:GetAimVector(),120)
	ang:RotateAroundAxis(self.Owner:GetRight(),0)
	ang:RotateAroundAxis(self.Owner:GetUp(),-90)
	
	local ent = ents.Create("ent_grapplehook")
	ent:SetOwner(self.Owner)
	-- ent:SetUser(self.Owner)
	ent:SetPos(self.Owner:GetShootPos()-self.Owner:GetAimVector()*10+self.Owner:GetRight()*6)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector()*(rhook.ShootPower or 2000))
	ent:GetPhysicsObject():AddAngleVelocity( Vector(-100,0,0) )
	self.Owner.rhook = ent
	self.Owner:DeleteOnRemove(ent)
end

hook.Add('TFA_PrimaryAttack', 'NextRP::HookProccesing', function(wep)
	if wep.HOOK_Active then
		if SERVER then
			wep.Hook = createHook(wep)
			if IsValid( wep.Hook ) then
				wep.Owner:EmitSound( "bobble/grapple_hook/grappling_hook_shoot.mp3", 75,100,1,CHAN_WEAPON )
				wep:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			end
		end

		return true
	end
end)

-- Это заготовка для будущего обновления
