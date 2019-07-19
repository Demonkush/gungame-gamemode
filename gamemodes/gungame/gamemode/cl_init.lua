include("shared.lua")

net.Receive("GGConnectMessage",function(len,pl)
	local str = net.ReadString()
	chat.AddText(Color(155,155,155),str,Color(215,255,115)," connected to the server!")
end)

net.Receive("GGDisconnectMessage",function(len,pl)
	local str = net.ReadString()
	chat.AddText(Color(155,155,155),str,Color(255,115,115)," disconnected from the server!")
end)

net.Receive("GGSendRespawnTime",function(len,pl)
	local time = net.ReadInt(8)
	timer.Create("RespawnTimer",time,1,function() end)
end)

net.Receive("GGBroadcastTeam",function(len,pl)
	local teams = net.ReadBool()
	GUNGAME.Config.TeamDeathmatch = teams
	timer.Simple(1,function() SetPlayerTeamColors() end)
end)

net.Receive("GGWeaponTableSync",function(len,pl)
	local tab = net.ReadTable()
	GUNGAME.Weapons = table.Copy(tab)
end)

net.Receive("GGSpawnProtectionTimer",function(len,pl)
	local ply = net.ReadEntity()
	local time = net.ReadInt(8)
	if IsValid(ply) then
		if time > 0 then
			ply:SetMaterial("models/props_combine/com_shield001a")
			timer.Remove(ply:EntIndex().."SpawnProtection")
			timer.Create(ply:EntIndex().."SpawnProtection",time,1,function()
				ply:SetMaterial()
			end)
		end
	end
end)

function GM:HUDAmmoPickedUp() end
function GM:HUDItemPickedUp() end
function GM:HUDWeaponPickedUp() end