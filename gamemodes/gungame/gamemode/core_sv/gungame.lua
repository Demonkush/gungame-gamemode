GUNGAME.LastLevels = {}
function GUNGAME.Functions.LevelUp(ply)
	ply:SetNWInt("GunGame_Level",ply:GetNWInt("GunGame_Level")+1)
	GUNGAME.Functions.GiveAppropriateWeapons(ply)
	if ply:GetNWInt("GunGame_Level") > #GUNGAME.Weapons then
		return
	end
	if ply:GetNWInt("GunGame_Level") == #GUNGAME.Weapons then
		GUNGAME.Functions.Notify(ply:Name().." is on the last level! ( Level: "..ply:GetNWInt("GunGame_Level").." )",Color(215,215,255),true)
	else
		GUNGAME.Functions.Notify(ply:Name().." leveled up! ( Level: "..ply:GetNWInt("GunGame_Level").." )",Color(215,215,255),true)
	end
	ply:EmitSound(GUNGAME.Config.LevelUpSound)
end

function GUNGAME.Functions.ShuffleLoadout()
	if GUNGAME.Config.ShuffleLoadouts then
		local r = math.random(1,#GUNGAME.Config.ShuffleTable)
		GUNGAME.Functions.LoadLoadout(string.TrimRight(GUNGAME.Config.ShuffleTable[r],".txt"))
	end
end

function GUNGAME.Functions.UpdateLastLevels()
	for a, b in pairs(player.GetAll()) do
		if b:GetNWInt("GunGame_Level") == #GUNGAME.Weapons then
			table.insert(GUNGAME.LastLevels,b)
		else
			table.RemoveByValue(GUNGAME.LastLevels,b)
		end
 	end
	net.Start("GGNetworkLastLevel")
		net.WriteTable(GUNGAME.LastLevels)
	net.Broadcast()
end

function GUNGAME.Functions.LevelDown(ply)
	local loss = GUNGAME.Config.SecondaryKillLevelsLost
	ply:PrintMessage(HUD_PRINTTALK,"You lost a level!")
	ply:SetNWInt("GunGame_Level",math.Clamp(ply:GetNWInt("GunGame_Level")-loss,1,#GUNGAME.Weapons))
	GUNGAME.Functions.GiveAppropriateWeapons(ply)
end

function GUNGAME.Functions.SecondaryKill(victim,attacker)
	 local gain = GUNGAME.Config.SecondaryKillLevelsGain

	 if IsValid(victim) then
	 	GUNGAME.Functions.LevelDown(victim)
	 else return end
	 if IsValid(attacker) then
	 	attacker:SetNWInt("GunGame_Level",attacker:GetNWInt("GunGame_Level")+gain)
	 	GUNGAME.Functions.GiveAppropriateWeapons(attacker)
	 	GUNGAME.Functions.Notify(attacker:Name().." humiliated "..victim:Name().."!",Color(255,215,215),true)
	 	attacker:EmitSound(GUNGAME.Config.LevelUpSound)
	 end
end

function GUNGAME.Functions.GiveAppropriateWeapons(ply)
	if !ply:Alive() then return end
	local level = ply:GetNWInt("GunGame_Level")
	if level <= 0 then level = 1 end
	local wep = GUNGAME.Weapons[level]
	if level > #GUNGAME.Weapons then
		GUNGAME.Functions.EndRound(ply)
		return
	end
	for a, b in pairs(GUNGAME.Weapons) do
		if wep == b then
			ply:StripWeapons()
			ply:SetNWString("GunGame_Primary",wep)
			timer.Simple(GUNGAME.Config.DelayBetweenNextWeapon,function()
				if IsValid(ply) then
					if ply:Alive() then
						wep = GUNGAME.Weapons[level]
						ply:Give(GUNGAME.Config.SecondaryWeapon)
						ply:Give(wep)
						if ply:GetActiveWeapon():GetClass() != GUNGAME.Config.SecondaryWeapon then
							timer.Simple(0.01,function()
								wep = GUNGAME.Weapons[level]
								ply:SelectWeapon(wep)
							end)
						end
						GUNGAME.Functions.ResetClientside(ply)
					end
				end
			end)
		end
	end
end

function GUNGAME.Functions.ResetClientside(ply)
	net.Start("GGResetClientside") net.Send(ply)
end

function GUNGAME.Functions.BroadcastClientsideReset()
	net.Start("GGBroadcastClientReset")
	net.Broadcast()
end