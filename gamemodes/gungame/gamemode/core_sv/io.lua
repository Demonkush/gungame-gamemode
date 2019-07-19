function GUNGAME.Functions.LoadSettings()
	local path = "dgungame/settings.txt"
	if file.Exists(path,"DATA") then
		local load = file.Read(path,"DATA")
		GUNGAME.Config = util.JSONToTable( load )
		GUNGAME.Functions.FillShuffleTable()
		RunConsoleCommand("sv_gravity",GUNGAME.Config.Gravity)
		GUNGAME.Functions.UpdatePlayerSpeeds()
		GUNGAME.Functions.BroadcastTeamInfo()
	end
end

function GUNGAME.Functions.SaveSettings()
	local path = "dgungame/settings.txt"
	local save = util.TableToJSON(GUNGAME.Config)
	if !file.Exists("dgungame","DATA") then
		file.CreateDir("dgungame")
	end
	file.Write(path,save)
	GUNGAME.Functions.LoadSettings()
	GUNGAME.Functions.ResetRound()
end


function GUNGAME.Functions.LoadLoadout(name,ply)
	name = string.TrimRight(name,".txt")
	local path = "dgungame_loadouts/"..name..".txt"
	if file.Exists(path,"DATA") then
		local load = file.Read(path,"DATA")
		GUNGAME.Weapons = util.JSONToTable( load )
		if IsValid(ply) then
			ply:PrintMessage(HUD_PRINTTALK,"Loaded loadout: "..name.."!")
		end
	end
end

function GUNGAME.Functions.SaveLoadout(name,ply,tab,sec)
	local path = "dgungame_loadouts/"..name..".txt"
	local save = util.TableToJSON(tab)
	if !file.Exists("dgungame_loadouts","DATA") then
		file.CreateDir("dgungame_loadouts")
	end
	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTTALK,"Saved loadout: "..name.."!")
	end
	GUNGAME.Config.LastSavedLoadout = name
	GUNGAME.Config.SecondaryWeapon = sec
	GUNGAME.Functions.SaveSettings()
	file.Write(path,save)
	if GUNGAME.Config.LastSavedLoadout != nil then
		GUNGAME.Functions.LoadLoadout(GUNGAME.Config.LastSavedLoadout)
	end
end

function GUNGAME.Functions.FillShuffleTable()
	GUNGAME.Config.ShuffleTableLoaded = {}
	for a, b in pairs(file.Find("dgungame_loadouts/*","DATA")) do
		if !table.HasValue(GUNGAME.Config.ShuffleTable,b) then
			table.insert(GUNGAME.Config.ShuffleTableLoaded,b)
		end
	end
end

net.Receive("GGSaveConfig",function(len,pl)
	if !pl:IsSuperAdmin() then return end
	pl:PrintMessage(HUD_PRINTTALK,"Saved Gun Game configuration!")
	local config = net.ReadTable()
	GUNGAME.Config = config
	GUNGAME.Functions.SaveSettings()
end)

net.Receive("GGSaveLoadout",function(len,pl)
	if !pl:IsSuperAdmin() then return end
	local filename = net.ReadString()
	local tab = net.ReadTable()
	local secondary = net.ReadString()
	GUNGAME.Functions.SaveLoadout(filename,pl,tab,secondary)
end)

net.Receive("GGLoadLoadout",function(len,pl)
	if !pl:IsSuperAdmin() then return end
	local filename = net.ReadString()
	GUNGAME.Functions.LoadLoadout(filename,pl)
end)