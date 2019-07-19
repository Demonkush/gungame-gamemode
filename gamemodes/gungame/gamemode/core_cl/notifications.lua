GUNGAME.Notifications = {}
GUNGAME.Notifications.Enabled 	= true -- If disabled, notifications will print to chat instead.
GUNGAME.Notifications.Delay 	= 5 -- How long before they fade out?
GUNGAME.Notifications.Waiting = false
GUNGAME.Notifications.ContainerQueue = {}
GUNGAME.Notifications.Container = {}
GUNGAME.Notifications.KillFeed = {}


local function InitializeNotifications()
	if IsValid(GUNGAME.Notifications.Core) then GUNGAME.Notifications.Core:Remove() end

	GUNGAME.Notifications.Core = vgui.Create("DFrame")
	local core = GUNGAME.Notifications.Core
	core:SetPos(0,0)
	core:SetSize(ScrW(),ScrH())
	core:SetTitle("")
	core:ShowCloseButton(false)
	core:SetDraggable(false)
	core.Paint = function() end
	core.Think = function()
		if !GUNGAME.Notifications.Waiting then
			GUNGAME.Functions.NextNotification()
		else
			if #GUNGAME.Notifications.Container <= 0 then
				GUNGAME.Notifications.Waiting = false
			end
		end
	end
end
InitializeNotifications()

local function RemoveNotification(panel)
	if IsValid(panel) then table.RemoveByValue(GUNGAME.Notifications.Container,panel) panel:Remove() end
end

local function FadeIn(panel)
	if IsValid(panel) then panel:SetAlpha(0) panel:AlphaTo(255,1,0) end
end
local function FadeOut(panel)
	if IsValid(panel) then panel:AlphaTo(0,1,0,function() RemoveNotification(panel) end) end
end

local margin = 40
local function MoveUp(panel)
	if !IsValid(panel) then return end
	local x,y = panel:GetPos()
	panel:MoveTo(x,y-margin,1,0,-1,function()
		if panel.id == 1 then
			GUNGAME.Notifications.Waiting = false
			GUNGAME.Functions.NextNotification()
		end
	end)
end

local function MoveAllUp(tab)
	if !istable(tab) then return end
	for a, b in pairs(tab) do
		if IsValid(b) then
			MoveUp(b)
		end
	end
end

function GUNGAME.Functions.NextNotification()
	local queue = #GUNGAME.Notifications.ContainerQueue
	if queue >= 1 then
		local data = GUNGAME.Notifications.ContainerQueue[1]
		GUNGAME.Functions.SendNotification(data.txt,data.col)
		table.remove(GUNGAME.Notifications.ContainerQueue,1)
	end
end

function GUNGAME.Functions.SendNotification(txt,color)
	if !GUNGAME.Notifications.Enabled then return end
	if GUNGAME.Notifications.Waiting then return end
	if IsValid(GUNGAME.Notifications.Core) then
		GUNGAME.Notifications.Waiting = true
		local notif = vgui.Create("DPanel",GUNGAME.Notifications.Core)
		local text = vgui.Create("DLabel",notif)
		text:SetText(txt)
		text:SetFont("gungame_medium")
		text:SetColor(color)
		text:SizeToContents()

		notif:SetSize(text:GetWide()+16,32)
		notif:SetPos(0,ScrH()-164)
		text:Center()
		notif:CenterHorizontal()
		notif.Paint = function(self)
			draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(25,25,25,215))
		end
		FadeIn(notif)
		timer.Simple(GUNGAME.Notifications.Delay,function()
			FadeOut(notif)
		end)
		table.insert(GUNGAME.Notifications.Container,notif)
		notif.id = #GUNGAME.Notifications.Container
		MoveAllUp(GUNGAME.Notifications.Container)
	end
end

function GUNGAME.Functions.RequestNotification(txt,col)
	local function RequestQueue() table.insert(GUNGAME.Notifications.ContainerQueue,{txt=txt,col=col}) end
	if GUNGAME.Notifications.Waiting then RequestQueue() return end
	if #GUNGAME.Notifications.Container <= 0 then
		GUNGAME.Functions.SendNotification(txt,color)
	else
		RequestQueue()
	end
end

net.Receive("GUNGAMENotification",function(len,pl)
	local txt = net.ReadString()
	local col = net.ReadVector()
	col = Color(col.x,col.y,col.z)
	GUNGAME.Functions.RequestNotification(txt,col)
end)

function GUNGAME.Functions.SendKillFeed(victim,killer) end
net.Receive("GUNGAMEKillFeed",function(len,pl)
	local vic = net.ReadString()
	local kil = net.ReadString()
	GUNGAME.Functions.SendKillFeed(vic,kil)
end)