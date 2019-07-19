function GUNGAME.Functions.EntityTakeDamage(target,dmginfo)
	if target:IsPlayer() then
		if dmginfo:GetAttacker():IsPlayer() then
			if GUNGAME.Config.TeamDeathmatch then
				if dmginfo:GetAttacker():Team() == target:Team() then return end
			end
		end
		target.LastHitTime = CurTime() + GUNGAME.Config.RegenLastHitTime
	end
end
hook.Add("EntityTakeDamage","GGENTDMGHOOK",GUNGAME.Functions.EntityTakeDamage)

hook.Add("KeyPress","GUNGAMEAMMO",function(ply,key)
	if key == IN_RELOAD then
		if GUNGAME.Config.AllowFreeAmmo then
			if ply.AmmoDelay < CurTime() then
				ply.AmmoDelay = CurTime() + 3
				local wep = ply:GetActiveWeapon()
				if IsValid(wep) then
					ply:GiveAmmo(50,wep:GetPrimaryAmmoType(),true)
				end
			end
		end
	end
	if ply.CanSpawn && !ply:Alive() then
		ply:Spawn()
	end
end)