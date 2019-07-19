GUNGAME.Leaderboard = {}
GUNGAME.Leaderboard.Players = {}

function GUNGAME.Functions.CreateLeaderboard()
end

net.Receive("GGReceiveLeaderboard",function(len,pl)
	GUNGAME.Functions.CreateLeaderboard()
end)