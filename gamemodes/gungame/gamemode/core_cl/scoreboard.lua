GUNGAME.Scoreboard = {}
GUNGAME.Scoreboard.Panel = nil

function GUNGAME.Functions.OpenScoreboard()
	if IsValid(GUNGAME.Scoreboard.Panel) then
		GUNGAME.Scoreboard.Panel:Remove()
	end

	GUNGAME.Scoreboard.Panel = vgui.Create("DFrame")
	local w = ScrW()*0.6
	if ScrW() < 1200 then
		w = ScrW()
	end
	local frame = GUNGAME.Scoreboard.Panel
	frame:SetSize(w,2)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	frame:SetPos(ScrW()/2-(w/2),ScrH()/2)
	frame:MakePopup()
	frame.Paint = function(self)
		--surface.SetDrawColor(Color(0,25,35,215))
		--surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	frame:SizeTo(
		w,
		480,
		.5
	)
	frame:MoveTo(
		ScrW()/2-(w/2),
		ScrH()/2-240,
		.5
	)
	local txt = "Gun Game v"..GUNGAME.Config.Version
	if GUNGAME.Config.TeamDeathmatch then
		txt = "Team Gun Game v"..GUNGAME.Config.Version
	end
	local title = vgui.Create("DLabel",frame)
	title:SetText(txt)
	title:SetFont("DermaLarge")
	title:SetColor(Color(0,0,0,255))
	title:SizeToContents()
	title:SetPos(0,40)
	title:CenterHorizontal()
	local x,y = title:GetPos()
	title:SetPos(x+2,y)
	local title = vgui.Create("DLabel",frame)
	title:SetText(txt)
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:SetPos(0,38)
	title:CenterHorizontal()
	local server = vgui.Create("DLabel",frame)
	server:SetText(GetHostName())
	server:SetFont("DermaLarge")
	server:SetColor(Color(0,0,0,255))
	server:SizeToContents()
	server:SetPos(0,5)
	server:CenterHorizontal()
	local x,y = server:GetPos()
	server:SetPos(x+2,y)
	local server = vgui.Create("DLabel",frame)
	server:SetText(GetHostName())
	server:SetFont("DermaLarge")
	server:SizeToContents()
	server:SetPos(0,5)
	server:CenterHorizontal()

	local plist = vgui.Create("DScrollPanel",frame)
	plist:SetSize(frame:GetWide()-10,383)
	plist:SetPos(5,128)
	plist.Paint = function(self) end
	local sbar = plist:GetVBar()
	function sbar:Paint(w,h) draw.RoundedBox(0,0,0,w,h,Color(45,45,45,215)) end
	function sbar.btnUp:Paint(w,h) draw.RoundedBox(0,0,0,w,h,Color(155,155,155)) end
	function sbar.btnDown:Paint(w,h) draw.RoundedBox(0,0,0,w,h,Color(155,155,155)) end
	function sbar.btnGrip:Paint(w,h) draw.RoundedBox(0,0,0,w,h,Color(115,115,115)) end

	local labels = {"Ping","K/D","Deaths","Kills","Level"}
	local am = frame:GetWide()/8
	local lm = frame:GetWide()-110
	for a, b in pairs(labels) do
		local text = vgui.Create("DLabel",frame)
		text:SetText(b)
		text:SetPos(lm,100)
		text:SetFont("gungame_small")
		text:SetColor(Color(0,0,0,255))
		text:SizeToContents()
		local x,y = text:GetPos()
		text:SetPos(x+1,y+1)
		local text = vgui.Create("DLabel",frame)
		text:SetText(b)
		text:SetPos(lm,100)
		text:SetFont("gungame_small")
		text:SizeToContents()

		local txtsize = string.len(b)
		lm = lm - (am + txtsize)
	end

	local marginy = 0
	local function CreatePlayerList(plys)
		for a, b in pairs(plys) do
			local playercard = vgui.Create("DPanel",plist)
			playercard:SetPos(5,marginy)
			playercard:SetSize(frame:GetWide()-35,36)
			playercard.Paint = function(self)
				if IsValid(b) then
					local col = team.GetColor(b:Team())
					surface.SetDrawColor(Color(col.r,col.g,col.b,115))
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
				end
			end
			local marginx = playercard:GetWide()-64
			local avatar = vgui.Create("AvatarImage",playercard)
			avatar:SetPos(2,2)
			avatar:SetSize(32,32)
			avatar:SetPlayer(b,32)
			local avatar_button = vgui.Create("DButton",playercard)
			avatar_button:SetPos(2,2)
			avatar_button:SetSize(32,32)
			avatar_button:SetText("")
			avatar_button.DoClick = function() b:ShowProfile() end
			avatar_button.Paint = function() end

			local label = vgui.Create("DLabel",playercard)
			label:SetFont("gungame_medium")
			label:SetText(b:Name())
			label:SizeToContents()
			label:SetPos(70,2)
			label:SetColor(Color(0,0,0,255))

			local ping = vgui.Create("DLabel",playercard)
			ping:SetPos(marginx,4)
			ping:SetText(b:Ping())
			ping:SetFont("gungame_medium")
			ping:SetColor(Color(0,0,0,255))
			ping:SizeToContents()
			marginx = marginx - (w/7)

			local kdr = math.Round(b:Frags()/b:Deaths())
			local kd = vgui.Create("DLabel",playercard)
			kd:SetPos(marginx,4)
			kd:SetText(kdr)
			kd:SetFont("gungame_medium")
			kd:SetColor(Color(0,0,0,255))
			kd:SizeToContents()
			marginx = marginx - (w/10)

			local deaths = vgui.Create("DLabel",playercard)
			deaths:SetPos(marginx,4)
			deaths:SetText(b:Deaths())
			deaths:SetFont("gungame_medium")
			deaths:SetColor(Color(0,0,0,255))
			deaths:SizeToContents()
			marginx = marginx - (w/7)

			local kills = vgui.Create("DLabel",playercard)
			kills:SetPos(marginx,4)
			kills:SetText(b:Frags())
			kills:SetFont("gungame_medium")
			kills:SetColor(Color(0,0,0,255))
			kills:SizeToContents()
			marginx = marginx - (w/8.5)

			local level = vgui.Create("DLabel",playercard)
			level:SetPos(marginx,4)
			level:SetText(b:GetNWInt("GunGame_Level"))
			level:SetFont("gungame_medium")
			level:SetColor(Color(0,0,0,255))
			level:SizeToContents()

			local mute = vgui.Create("DImageButton",playercard)
			mute:SetPos(36,2)
			mute:SetSize(32,32)
			mute:SetColor(Color(255,255,255,255))
			if b:IsMuted() then
				mute:SetImage("icon32/muted.png")
			else
				mute:SetImage("icon32/unmuted.png")
			end
			mute.DoClick = function()
				if b:IsMuted() then
					mute:SetImage("icon32/unmuted.png")
					b:SetMuted(false)
				else
					mute:SetImage("icon32/muted.png")
					b:SetMuted(true)
				end
			end

			playercard.Think = function()
				if IsValid(b) then
					local kdr = math.Round(b:Frags()/b:Deaths(),2)
					if b:Frags() == 0 then kdr = 0 end
					if b:Deaths() <= 0 then kdr = b:Frags() end
					kd:SetText(kdr)
					kd:SizeToContents()
					ping:SetText(b:Ping())
					ping:SizeToContents()
				end
			end

			marginy = marginy + 42
		end
	end
	if !GUNGAME.Config.TeamDeathmatch then
		CreatePlayerList(player.GetAll())
	else
		if timer.Exists("gg_roundtimer") then
			CreatePlayerList(team.GetPlayers(2))
			marginy = marginy + 32
			CreatePlayerList(team.GetPlayers(3))
		else
			CreatePlayerList(player.GetAll())
		end
	end
	gui.EnableScreenClicker(true)
end

function GUNGAME.Functions.CloseScoreboard()
	if IsValid(GUNGAME.Scoreboard.Panel) then
		GUNGAME.Scoreboard.Panel:AlphaTo(0,0.25,0,function() GUNGAME.Scoreboard.Panel:Remove() end)
	end
	gui.EnableScreenClicker(false)
end
function GM:ScoreboardShow() GUNGAME.Functions.OpenScoreboard() end
function GM:ScoreboardHide() GUNGAME.Functions.CloseScoreboard() end