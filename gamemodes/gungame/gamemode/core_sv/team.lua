local function FriendlyFireCheck(ply,att)
	if GUNGAME.Config.TeamDeathmatch then
		if !GUNGAME.Config.FriendlyFire then
			if att:IsPlayer() && ply:IsPlayer() then
				if ply:Team() == att:Team() then return false end
			end
		else
			return true
		end
	end
end
hook.Add("PlayerShouldTakeDamage","gungameff",FriendlyFireCheck)

local function DamageCheck(target,dmginfo)
	local att = dmginfo:GetAttacker()
	if target:IsPlayer() then
		if IsValid(att) then
			if att:IsPlayer() then
				if target.SpawnProtection then
					dmginfo:SetDamage(0)
				end
				if att.SpawnProtection then
					dmginfo:SetDamage(0)
				end
			end
		end
	end

end
hook.Add("EntityTakeDamage","gungametd",DamageCheck)

function GUNGAME.Functions.ShufflePlayers()
	local function ShuffleThem()
		for a, b in pairs(player.GetAll()) do
			local t1,t2 = team.NumPlayers(2),team.NumPlayers(3)
			if t1 > t2 then
				b:SetTeam(3)
			end
			if t1 < t2 then
				b:SetTeam(2)			
			end
			if t1 == t2 then
				local rando = math.random(2,3)
				b:SetTeam(rando)
			end
		end
	end
	ShuffleThem()
	local t1,t2 = team.NumPlayers(2),team.NumPlayers(3)
	if t1 < 1 then
		ShuffleThem()
	end
	if t2 < 1 then
		ShuffleThem()
	end
end

function GUNGAME.Functions.RequestTeamSwitch(ply,t)
	if !GUNGAME.Config.TeamDeathmatch then return end
	local t1,t2 = team.NumPlayers(2),team.NumPlayers(3)
	if ply:Team() == t then ply:PrintMessage(HUD_PRINTTALK,"You are already on this team!") return end
	local joining1 = false
	local joining2 = false
	if t1 == 0 && t2 == 0 then
		local r = math.random(2,3)
		if r == 2 then joining1 = true
		elseif r == 3 then joining2 = true
		end
	else
		if t1 == 0 then joining1 = true end
		if t2 == 0 then joining2 = true end
	end
	if t1 > t2 then if t == 3 then joining2 = true end end
	if t1 < t2 then if t == 2 then joining1 = true end end
	if joining1 or joining2 then
		ply:SetTeam(t)
		local teamnum = t-1
		ply:PrintMessage(HUD_PRINTTALK,"Changed to Team "..teamnum.."!")
		SetPlayerTeamColors()
		ply:Spawn()
		return
	end
	if t1 == t2 then
		ply:PrintMessage(HUD_PRINTTALK,"Sorry, but the teams are currently even! Wait for a shuffle or open spot!")
	end	
end

net.Receive("GGRequestTeamSwitch",function(len,pl)
	local bool = net.ReadBool()
	if bool then
		GUNGAME.Functions.RequestTeamSwitch(pl,2)
	else
		GUNGAME.Functions.RequestTeamSwitch(pl,3)
	end
end)

local function OpenGunGameMenu(ply)
	ply:ConCommand("GunGameMenu")
end
hook.Add("ShowHelp","GGGunGameMenu",OpenGunGameMenu)


function GUNGAME.Functions.BroadcastTeamInfo()
	net.Start("GGBroadcastTeam")
		net.WriteBool(GUNGAME.Config.TeamDeathmatch)
	net.Broadcast()
end