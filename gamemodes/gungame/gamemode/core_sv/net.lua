util.AddNetworkString("GGReceiveRoundState")
util.AddNetworkString("GGReceiveRoundTimer")
util.AddNetworkString("GGResetClientside")
util.AddNetworkString("GGReceiveLeaderboard")
util.AddNetworkString("GGReceiveWeaponSwitch")
util.AddNetworkString("GGSpawnProtectionTimer")
util.AddNetworkString("GUNGAMENotification")
util.AddNetworkString("GGDisconnectMessage")
util.AddNetworkString("GGConnectMessage")
util.AddNetworkString("GGSendRespawnTime")
util.AddNetworkString("GGBroadcastTeam")
util.AddNetworkString("GGSaveConfig")
util.AddNetworkString("GGSaveLoadout")
util.AddNetworkString("GGLoadLoadout")
util.AddNetworkString("GGRemoveLoadout")
util.AddNetworkString("GGUpdateLoadouts")
util.AddNetworkString("GGAdminMenuRequest")
util.AddNetworkString("GGAdminMenuSend")
util.AddNetworkString("GGRequestTeamSwitch")
util.AddNetworkString("GGNetworkLastLevel")
util.AddNetworkString("GGResetRound")
util.AddNetworkString("GGWeaponTableSync")

net.Receive("GGRemoveLoadout",function(len,pl)
	if !pl:IsSuperAdmin() then return end
	local loadout = net.ReadString()
	pl:PrintMessage(HUD_PRINTTALK,"Loadout: "..loadout.." deleted!")
	file.Delete( "dgungame_loadouts/"..loadout )

	local find_loadouts = file.Find("dgungame_loadouts/*.txt","DATA")
	net.Start("GGUpdateLoadouts")
		net.WriteTable(find_loadouts)
	net.Send(pl)
end)

net.Receive("GGResetRound",function(len,pl)
	if !pl:IsSuperAdmin() then return end
	GUNGAME.Functions.ResetRound()
	GUNGAME.Functions.Notify("The round was reset!",Color(155,155,155),true)
end)

net.Receive("GGAdminMenuRequest",function(len,pl)
	if !pl:IsSuperAdmin() then return end
	GUNGAME.Functions.FillShuffleTable()

	local find_loadouts = file.Find("dgungame_loadouts/*.txt","DATA")
	net.Start("GGAdminMenuSend") net.WriteTable(GUNGAME.Config) net.WriteTable(GUNGAME.Weapons) net.WriteTable(find_loadouts) net.Send(pl)
end)

net.Receive("GGReceiveWeaponSwitch",function(len,pl)
	local primary = net.ReadBool()
	if pl:Alive() then
		local wep = "weapon_crowbar"
		if primary then
			wep = pl:GetNWString("GunGame_Primary")
		else
			wep = pl:GetNWString("GunGame_Secondary")
		end
		if !pl:HasWeapon(wep) then pl:Give(wep) end
		pl:SelectWeapon(wep)
	end
end)