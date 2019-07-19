AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

resource.AddWorkshop("1524544510") -- Gamemode on Workshop
function GUNGAME.Functions.StartRegenTimer()
	local function Regen()
		if GUNGAME.Config.RegenMode != 2 then return end
		for a, b in pairs(player.GetAll()) do
			if b:Alive() then
				if b.LastHitTime < CurTime() && b.NextRegen < CurTime() then
					local hp = b:Health()
					b:SetHealth(math.Clamp(hp+GUNGAME.Config.RegenAmount,1,100))
					b.NextRegen = CurTime() + GUNGAME.Config.RegenInterval
				end
			end
		end
	end
	timer.Remove("GGRegen")
	if GUNGAME.Config.RegenMode == 2 then
		timer.Create("GGRegen",1,0,Regen)
	end
end

function GUNGAME.Functions.UpdatePlayerSpeeds()
	local walkspeed 		= tonumber(GUNGAME.Config.WalkSpeed)
	local crouchedspeed 	= tonumber(GUNGAME.Config.CrouchedSpeed)
	local runspeed 			= tonumber(GUNGAME.Config.RunSpeed)
	local jumpheight 		= tonumber(GUNGAME.Config.JumpHeight)
	if walkspeed 		<= 0 then walkspeed 	= 1 end
	if crouchedspeed 	<= 0 then crouchedspeed = 1 end
	if runspeed 		< walkspeed then runspeed 		= walkspeed end
	if jumpheight 		<= 0 then jumpheight 	= 1 end
	for a, b in pairs(player.GetAll()) do
		if b:Alive() then
			b:SetWalkSpeed(walkspeed)
			b:SetCrouchedWalkSpeed(crouchedspeed)
			b:SetRunSpeed(runspeed)
			b:SetJumpPower(jumpheight)
		end
	end
end

function GM:Initialize()
	GUNGAME.Functions.StartRegenTimer()
	GUNGAME.Functions.LoadSettings()
	if GUNGAME.Config.LastSavedLoadout != nil then
		GUNGAME.Functions.LoadLoadout(GUNGAME.Config.LastSavedLoadout)
	end
end

function GUNGAME.Functions.SetSpawnProtection(ply)
	local time = GUNGAME.Config.SpawnProtection
	if time == nil then time = 3 end
	net.Start("GGSpawnProtectionTimer")
		net.WriteEntity(ply)
		net.WriteInt(time,8)
	net.Broadcast()
	ply.SpawnProtection = true
	timer.Create(ply:EntIndex().."SpawnProtection",time,1,function()
		if IsValid(ply) then ply.SpawnProtection = false end
	end)
end

function GM:PlayerInitialSpawn(ply) 
	ply:SetTeam(1)
	net.Start("GGConnectMessage") net.WriteString(tostring(ply:Name())) net.Broadcast()
	ply.LastHitTime = 0
	ply.NextRegen = 0
	ply.AmmoDelay = 0
	ply.NextSpawn = 0
	ply.KillsToLevel = 0
	ply.SpawnProtection = false
	ply.GG_BunnyHopping = false
	ply:SetNWInt("GunGame_Level",1)
	ply:SetNWString("GunGame_Primary",GUNGAME.Config.DefaultWeapons[1])
	ply:SetNWString("GunGame_Secondary",GUNGAME.Config.SecondaryWeapon)	
	if GUNGAME.Config.TeamDeathmatch then
		GUNGAME.Functions.BroadcastTeamInfo()
	end
end

function GM:PlayerSetModel(ply)
	local model = ply:GetInfo("cl_playermodel")
	local model_path = player_manager.TranslatePlayerModel(model)
	if model_path then
		ply:SetModel(model_path)
	else
		ply:SetModel("models/player/kleiner.mdl")
	end
	SetPlayerTeamColors()
end

function GM:PlayerDeathThink(ply) 
	if !ply.NextSpawn then ply.NextSpawn = 1 end
    if CurTime()>=ply.NextSpawn then
        ply.CanSpawn = true
		if GUNGAME.Config.SpawnAutoDelay != nil then
			if CurTime()>=(ply.NextSpawn+GUNGAME.Config.SpawnAutoDelay) then
				ply:Spawn()
			end
		end
    end
end

function GM:PlayerSpawn(ply)
	ply:SetNWString("GunGame_Secondary",GUNGAME.Config.SecondaryWeapon)	
	ply.NextSpawn = math.huge
	hook.Call("PlayerSetModel",GAMEMODE,ply)
	ply:SetupHands()
	hook.Call("PlayerLoadout",GAMEMODE,ply)
	SetPlayerTeamColors()

	timer.Simple(0.5,function()
		GUNGAME.Functions.UpdatePlayerSpeeds()
		GUNGAME.Functions.SetSpawnProtection(ply)
		net.Start("GGWeaponTableSync") net.WriteTable(GUNGAME.Weapons) net.Send(ply)
	end)
end

function GM:PlayerLoadout(ply)
	GUNGAME.Functions.GiveAppropriateWeapons(ply)
end

function GM:PlayerDisconnected(ply)
	net.Start("GGDisconnectMessage") net.WriteString(tostring(ply:Name())) net.Broadcast()
end

function GM:DoPlayerDeath(ply,att,dmg)
	ply.CanSpawn = false
	local delay = GUNGAME.Config.SpawnDelay
	ply:AddDeaths(1)
	ply:CreateRagdoll()
	ply.NextSpawn = CurTime() + delay
	net.Start("GGSendRespawnTime") net.WriteInt(delay,8) net.Send(ply)
	if ply == att then
		delay = delay + GUNGAME.Config.DeathPenalty
	else
		local secondarykill = false
		if att:IsPlayer() then
			if GUNGAME.Config.RegenMode == 3 then
				local hp = att:Health()
				local max = 100+GUNGAME.Config.OverhealAmount
				local amount = GUNGAME.Config.RegenKillAmount

				if hp+amount > 100 then
					amount = amount / GUNGAME.Config.OverhealDivider
				end

				local newhp = math.Clamp(hp+amount,1,max)
				att:SetHealth(newhp)
			end
			local function DoLevelUp(ply,att)
				att.KillsToLevel = 0
				if IsValid(att:GetActiveWeapon()) then
					if att:GetActiveWeapon():GetClass() == att:GetNWString("GunGame_Secondary") then
						secondarykill = true
					end
				end
				if secondarykill then
					GUNGAME.Functions.SecondaryKill(ply,att)				
				else
					GUNGAME.Functions.LevelUp(att)
				end
			end

			if GUNGAME.Config.KillsToLevel > 1 then
				att.KillsToLevel = att.KillsToLevel + 1
				if att.KillsToLevel >= GUNGAME.Config.KillsToLevel then
					DoLevelUp(ply,att)
				end
			else
				DoLevelUp(ply,att)
			end

			if GUNGAME.Config.TeamDeathmatch then
				if att:Team() == ply:Team() then
					att:AddFrags(-1)
					att:PrintMessage(HUD_PRINTTALK,"Do not kill your team members! (-1 Kill and Level)")
					GUNGAME.Functions.LevelDown(att)
					return
				end
			end
			att:AddFrags(1)
		end
	end
	GUNGAME.Functions.UpdateLastLevels()
end

function GUNGAME.Functions.Notify(txt,col,global,ply)
	net.Start("GUNGAMENotification")
		net.WriteString(txt)
		net.WriteVector(Vector(col.r,col.g,col.b))
	if global then net.Broadcast() else
		if IsValid(ply) then net.Send(ply) end
	end
end