GM.Name = "Gun Game"
GM.Author = "Demonkush"
GM.Website = "http://www.tachyongaming.net"
--[[-------------------------------------------------------------------------
Gun Game by Demonkush for FumingStone

Features
- Gun Game 						( Level up on kill and get new weapons! )
- Configurable Game Variables 	( Almost everything is controllable! )
- Built-In Auto Bunny Hop 		( Type !bhop or /bhop in chat or type bhop in console )
- Custom Weapon Selection 		( Primary <-> Secondary weapon swap with clean UI! )
- Infinite Ammo Reload 			( If enabled, pressing Reload will give free ammo! )
- Pretty Notifications 			( Custom notification system and join / leave messages! )
- Round System 					( Game waits for players to start, and handles map change! )
- Custom Scoreboard 			( K/D, Level, Ping, Steam Avatar, Mute, and Teams )
- Team System 					( Team Indicators, Team Shuffling and Friendly Fire )
- Robust Admin Config Menu 		( Edit the loadout, shuffle and configurations in-game with ease! )

Commands
- gungame_reset ( as a superadmin, you can use this to reset the round! )


Credits
- Demonkush: Gamemode creator and some icons.
- FumingStone: Commissioner and ideas.
- Carl Enlund: Helmet Font- https://github.com/carlenlund/helmet
---------------------------------------------------------------------------]]
-- SHARED
GUNGAME = {}
GUNGAME.Config = {}
GUNGAME.Functions = {}
GUNGAME.Panels = {}
GUNGAME.Weapons = {} -- Fill this in-game!
GUNGAME.ConfigDefaults = {}
GUNGAME.Config.Version = "1.4"
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- These are the default configurations, they should all be modified in-game! --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
GUNGAME.Config.RoundTime 				= 600 -- How many seconds in a round?
GUNGAME.Config.TimerState 				= 2 -- 0 = none, 1 = time elapsed, 2 = countdown
GUNGAME.Config.KillsToLevel 			= 1 -- How many kills are needed to level up?
GUNGAME.Config.SecondaryKillLevelsLost 	= 1 -- How many levels are lost on a secondary kill? ( Victim )
GUNGAME.Config.SecondaryKillLevelsGain 	= 1 -- How many levels are gained on a secondary kill? ( Killer )
GUNGAME.Config.AllowFreeAmmo 			= true -- If you can hit reload to get free ammo.
GUNGAME.Config.AllowAutoBhop 			= false -- If the Auto Bhop system is enabled.
GUNGAME.Config.DelayBetweenNextWeapon 	= 1 -- Delay between giving you the next weapon.
GUNGAME.Config.SpawnDelay 				= 2 -- How long does it take to respawn?
GUNGAME.Config.SpawnAutoDelay 			= 1 -- How long does it take to auto-respawn a player? (nil = disabled)
GUNGAME.Config.DeathPenalty				= 2 -- Stack on extra time for suicides? ( 0 = disable )
GUNGAME.Config.RegenMode 				= 2 -- 1 = off, 2 = regen over time, 3 = regen on kill
GUNGAME.Config.RegenAmount 				= 1 -- How much to heal on interval, if RegenMode is 2.
GUNGAME.Config.RegenInterval 			= 1 -- Time between intervals to heal if RegenMode is 2.
GUNGAME.Config.RegenLastHitTime 		= 3 -- Time after being hit to being regeneration, if RegenMode is 2.
GUNGAME.Config.RegenKillAmount 			= 10 -- How much to heal on kill, if RegenMode is 3.
GUNGAME.Config.SpawnProtection 			= 3 -- How long will spawn protection last? 0 = disable.

GUNGAME.Config.OverhealAmount 			= 50 -- How much can be overhealed? 0 = disabled.
GUNGAME.Config.OverhealDivider 			= 2 -- How much should the health be divided up?

GUNGAME.Config.TeamDeathmatch 			= false -- Is this a team round?
GUNGAME.Config.FriendlyFire 			= false -- Can you hurt team mates in TDM?
GUNGAME.Config.SecondaryWeapon 			= "weapon_crowbar" -- What is the secondary weapon?
GUNGAME.Config.LevelUpSound 			= "buttons/button5.wav" -- This is played whenever a player levels up!

GUNGAME.Config.WalkSpeed 		= 200
GUNGAME.Config.CrouchedSpeed 	= 0.5
GUNGAME.Config.RunSpeed 		= 500
GUNGAME.Config.JumpHeight 		= 200
GUNGAME.Config.Gravity 			= 600

GUNGAME.Config.ShuffleWeapons = false -- Weapons "in the loadout".
GUNGAME.Config.ShuffleLoadouts = false -- Shuffling a list of loadouts.
GUNGAME.Config.ShuffleTable = {}
GUNGAME.Config.ShuffleTableLoaded = {}
GUNGAME.ConfigDefaults = GUNGAME.Config -- For repairing old configs!

-- Default Loadout ( will be replaced with your custom loadout! )
GUNGAME.Config.DefaultWeapons = {"weapon_pistol","weapon_357","weapon_smg1","weapon_ar2","weapon_shotgun","weapon_crossbow"}
function GUNGAME.Functions.SetupDefaultWeapons()
	GUNGAME.Weapons = GUNGAME.Config.DefaultWeapons
end
GUNGAME.Functions.SetupDefaultWeapons() -- Use if a loadout is corrupted or missing!

GUNGAME.Config.LastSavedLoadout 		= nil -- If this is not nil, it will try to load a filename by string!

-- Strings to fix weapon names of non-sweps
GUNGAME.Config.WeaponNames = {}
GUNGAME.Config.WeaponNames["weapon_crowbar"] = "CROWBAR"
GUNGAME.Config.WeaponNames["weapon_stunstick"] = "STUNSTICK"
GUNGAME.Config.WeaponNames["weapon_pistol"] = "PISTOL"
GUNGAME.Config.WeaponNames["weapon_smg1"] = "SMG1"
GUNGAME.Config.WeaponNames["weapon_357"] = "357"
GUNGAME.Config.WeaponNames["weapon_ar2"] = "AR2"
GUNGAME.Config.WeaponNames["weapon_shotgun"] = "SHOTGUN"
GUNGAME.Config.WeaponNames["weapon_crossbow"] = "CROSSBOW"
GUNGAME.Config.WeaponNames["weapon_rpg"] = "RPG"
GUNGAME.Config.WeaponNames["weapon_frag"] = "GRENADE"
GUNGAME.Config.WeaponNames["weapon_bugbait"] = "BUGBAIT"

local color_yellow 	= Color(255,255,55)
local color_red	 	= Color(255,115,115)
local color_blue 	= Color(115,215,255)
team.SetUp(1,"Mercenaries",color_yellow)
team.SetUp(2,"The Renegades",color_red)
team.SetUp(3,"The Company",color_blue)
function SetPlayerTeamColors()
	team.SetColor(1,color_yellow)
	team.SetColor(2,color_red)
	team.SetColor(3,color_blue)
	for a, b in pairs(player.GetAll()) do
		if b:Alive() then
			local col = team.GetColor(b)
			b:SetPlayerColor(Vector(col.r/255,col.g/255,col.b/255))
		end
	end
end

local gmname = "gungame"
if SERVER then
	local cl_add = file.Find(gmname.."/gamemode/core_cl/*","LUA")
	for cla,clb in pairs(cl_add) do
		AddCSLuaFile(gmname.."/gamemode/core_cl/"..clb)
	end
	local sv_load = file.Find(gmname.."/gamemode/core_sv/*","LUA")
	for sva,svb in pairs(sv_load) do
		include(gmname.."/gamemode/core_sv/"..svb)
	end
end
if CLIENT then
	local cl_load = file.Find(gmname.."/gamemode/core_cl/*","LUA")
	for cla,clb in pairs(cl_load) do
		include(gmname.."/gamemode/core_cl/"..clb)
	end
end

local function GG_BHop(ply,data)
	if CLIENT and ply != LocalPlayer() then return end

	if GUNGAME.Config.AllowAutoBhop then
		local btn = data:GetButtons()
		if bit.band(btn,IN_JUMP) > 0 then
			if ply.GG_BunnyHopping then
				if ply:WaterLevel() < 2 and ply:GetMoveType() ~= MOVETYPE_LADDER and !ply:IsOnGround() then
					data:SetButtons(bit.band(btn,bit.bnot(IN_JUMP)))
				end
			end
		end
	end
end
hook.Add("SetupMove","GGBHOPHOOK",GG_BHop)

local function BHopToggle(ply)
	if ply.GG_BunnyHopping then
		ply:PrintMessage(HUD_PRINTTALK,"BHop disabled!")
		ply.GG_BunnyHopping = false
	else
		ply:PrintMessage(HUD_PRINTTALK,"BHop enabled!")
		ply.GG_BunnyHopping = true
	end
end

concommand.Add("bhop",function(ply,cmd,args)
	BHopToggle(ply)
end)

local function GG_BHopSay(ply,txt)
	if string.lower(txt) == "/bhop" or string.lower(txt) == "!bhop" then
		BHopToggle(ply)
		return ""
	end
end
hook.Add("PlayerSay","GG_BHopSay",GG_BHopSay)