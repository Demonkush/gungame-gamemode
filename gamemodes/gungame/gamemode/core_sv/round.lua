GUNGAME.Round = {}
GUNGAME.Round.State 		= 0 -- 0 = waiting, 1 = active, 2 = ended
GUNGAME.Round.TimeElapsed 	= 0 -- Used for timer state 1.
GUNGAME.Round.PrepTime 		= 3 -- For pre/post round delay, how long in seconds between state changes?
GUNGAME.Round.MinPlayers 	= 2 -- How many players are needed to start the game?
GUNGAME.Round.MapSwitch 	= false -- Should the map switch on round end?

function GUNGAME.Functions.RoundState(state)
	GUNGAME.Round.State = state
	net.Start("GGReceiveRoundState")
		net.WriteInt(state,4)
	net.Broadcast()
	if state == 0 or state == 2 then
		GUNGAME.Functions.RemoveRoundTimer()
	end
end

function GUNGAME.Functions.ResetRound()
	GUNGAME.Functions.RoundState(0)
	GUNGAME.Functions.ShuffleWeapons()
	timer.Simple(0.5,function()
		GUNGAME.Functions.ResetPlayers()
		game.CleanUpMap()
	end)
end

concommand.Add("gungame_reset",function(ply,cmd,args)
	if ply:IsSuperAdmin() then
		GUNGAME.Functions.ResetRound()
		GUNGAME.Functions.Notify("The round was reset!",Color(155,155,155),true)
	end
end)

function GUNGAME.Functions.ResetPlayers()
	for a, b in pairs(player.GetAll()) do
		b:SetNWInt("GunGame_Level",1)		
		b:SetFrags(0)
		b:SetDeaths(0)
		b:Spawn()
		b.KillsToLevel = 0
		GUNGAME.Functions.ResetClientside(b)
	end
end

function GUNGAME.Functions.ShuffleWeapons()
	if GUNGAME.Config.ShuffleWeapons then
		local size = #GUNGAME.Weapons
		for i=size,1,-1 do
			local rand = math.random(size)
			GUNGAME.Weapons[i],GUNGAME.Weapons[rand] = GUNGAME.Weapons[rand],GUNGAME.Weapons[i]
		end
	end
end

function GUNGAME.Functions.StartRound()
	GUNGAME.Functions.ShuffleLoadout()
	GUNGAME.Functions.ShuffleWeapons()
	GUNGAME.Functions.ResetPlayers()
	GUNGAME.Functions.RoundState(1)
	GUNGAME.Functions.StartRegenTimer()
	for k, v in pairs(player.GetAll()) do
		v:Freeze(true)
		if !GUNGAME.Config.TeamDeathmatch then
			v:SetTeam(1)
		end
	end
	timer.Simple(GUNGAME.Round.PrepTime,function()
		GUNGAME.Functions.Notify("The round has started!",Color(215,255,155),true)

		GUNGAME.Functions.BroadcastTeamInfo()

		if GUNGAME.Config.TeamDeathmatch then
			GUNGAME.Functions.ShufflePlayers()
		end

		GUNGAME.Functions.StartRoundTimer()
		for k, v in pairs(player.GetAll()) do
			v:Freeze(false)
		end
		SetPlayerTeamColors()
	end)
end

function GUNGAME.Functions.GetTopPlayers()
	local players = player.GetAll()
	table.sort(players,function(a,b) return a:GetNWInt("GunGame_Level") > b:GetNWInt("GunGame_Level") end)
	if istable(players) then
		return players		
	end
end

function GUNGAME.Functions.EndRound(ply)
	GUNGAME.Functions.RoundState(2)
	GUNGAME.Functions.Notify("The round is over!",Color(215,255,155),true)
	if IsValid(ply) then
		GUNGAME.Functions.Notify(ply:Name().." won!",Color(215,255,155),true)
	end
	local leaderboard = GUNGAME.Functions.GetTopPlayers()
	net.Start("GGReceiveLeaderboard") net.WriteTable(leaderboard) net.Broadcast()
	for a, b in pairs(player.GetAll()) do 
		b:StripWeapons()
		b:Freeze(true) 
	end
	net.Start("GGNetworkLastLevel")
		net.WriteTable({})
	net.Broadcast()
	if GUNGAME.Round.MapSwitch then
		GUNGAME.Functions.Notify("Map is changing!",Color(155,155,155),true)
		timer.Simple(GUNGAME.Round.PrepTime,function()
			RunConsoleCommand("changelevel",game.GetMap())
		end)
	else
		timer.Simple(GUNGAME.Round.PrepTime,function()
			GUNGAME.Functions.ResetRound()
		end)
	end
end

function GUNGAME.Functions.CheckRound()
	local plys = #player.GetAll()
	if GUNGAME.Round.State == 0 then
		if plys >= GUNGAME.Round.MinPlayers then
			GUNGAME.Functions.ResetRound()
			GUNGAME.Functions.StartRound()
		end
	end
	if GUNGAME.Round.State == 1 then
		if plys < 2 then
			GUNGAME.Functions.ResetRound()
		end	
	end
end
timer.Create("GGCheckTimer",1,0,function()
	GUNGAME.Functions.CheckRound()
end)
function GUNGAME.Functions.RemoveRoundTimer()
	timer.Remove("GGRoundTimer")
	net.Start("GGReceiveRoundTimer")
		net.WriteString("stop")
	net.Broadcast()
end

function GUNGAME.Functions.StartRoundTimer()
	if timer.Exists("GGRoundTimer") then return end
	local time = GUNGAME.Config.RoundTime or 60
	if GUNGAME.Config.TimerState == 0 then return end
	-- TIME ELAPSED
	if GUNGAME.Config.TimerState == 1 then
		GUNGAME.Round.TimeElapsed = 0
		timer.Create("GGRoundTimer",1,0,function()
			GUNGAME.Round.TimeElapsed = GUNGAME.Round.TimeElapsed + 1
		end)
		net.Start("GGReceiveRoundTimer")
			net.WriteString("elapsed")
		net.Broadcast()
	end
	-- COUNTDOWN
	if GUNGAME.Config.TimerState == 2 then
		timer.Create("GGRoundTimer",time,1,function()
			GUNGAME.Functions.EndRound()
		end)
		net.Start("GGReceiveRoundTimer")
			net.WriteString("countdown")
			net.WriteInt(time,32)
		net.Broadcast()
	end
end