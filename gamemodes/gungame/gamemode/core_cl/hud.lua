
--[[-------------------------------------------------------------------------
HUD
---------------------------------------------------------------------------]]
local scrw,scrh = ScrW(),ScrH()
local top_left,top_mid,top_right 			= {0,0},		{scrw/2,0},			{scrw,0}
local middle_left,middle,middle_right 		= {0,scrh/2},	{scrw/2,scrh/2},	{scrw,scrh/2} 
local bottom_left,bottom_mid,bottom_right 	= {0,scrh},		{scrw/2,scrh},		{scrw,scrh}
local function DrawLevelsAndHealth()
	local hp = LocalPlayer():Health()
	local ap = LocalPlayer():Armor()
	draw.SimpleTextOutlined(
		"Level  "..LocalPlayer():GetNWInt("GunGame_Level").." out of "..#GUNGAME.Weapons,
		"gungame_medium",
		bottom_left[1]+8,
		bottom_left[2]-68,
		Color(255,255,255),
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		2,
		Color(0,0,0,55)
	)

	if hp > 0 then
		surface.SetDrawColor(255,115,115,155)
		surface.SetMaterial(Material("vgui/gradient_up"))
		surface.DrawTexturedRect(48,ScrH()-42,math.Clamp(hp*2,1,200),16)
		surface.SetDrawColor(255,115,115,155)
		surface.SetMaterial(Material("vgui/gradient_down"))
		surface.DrawTexturedRect(48,ScrH()-26,math.Clamp(hp*2,1,200),16)
		surface.SetDrawColor(255,255,255,155)
		surface.DrawRect(48,ScrH()-42,1,32)
		surface.SetDrawColor(255,255,255,155)
		surface.DrawRect(48+math.Clamp(hp*2,1,200),ScrH()-42,1,32)
		draw.SimpleTextOutlined(
			hp,
			"gungame_large",
			bottom_left[1]+math.Clamp(hp,28,100)+44,
			bottom_left[2]-28,
			Color(255,255,255,255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1,
			Color(255,155,155,25)
		)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("dgungame/hud_hp.png"))
		surface.DrawTexturedRect(2,ScrH()-50,48,48)
	end
	if ap > 0 then
		surface.SetDrawColor(155,215,255,155)
		surface.SetMaterial(Material("vgui/gradient_up"))
		surface.DrawTexturedRect(308,ScrH()-42,math.Clamp(ap*2,1,200),16)
		surface.SetDrawColor(155,215,255,155)
		surface.SetMaterial(Material("vgui/gradient_down"))
		surface.DrawTexturedRect(308,ScrH()-26,math.Clamp(ap*2,1,200),16)
		surface.SetDrawColor(255,255,255,155)
		surface.DrawRect(308,ScrH()-42,1,32)
		surface.SetDrawColor(255,255,255,155)
		surface.DrawRect(308+math.Clamp(ap*2,1,200),ScrH()-42,1,32)
		draw.SimpleTextOutlined(
			ap,
			"gungame_large",
			bottom_left[1]+math.Clamp(ap,28,100)+308,
			bottom_left[2]-28,
			Color(255,255,255,255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1,
			Color(155,215,255,25)
		)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("dgungame/hud_ap.png"))
		surface.DrawTexturedRect(262,ScrH()-50,48,48)
	end
end

local timerstate = "stop"
local timerelapsed = 0
local function DrawRoundInfo()
	if timer.Exists(LocalPlayer():EntIndex().."SpawnProtection") then
		local time = timer.TimeLeft(LocalPlayer():EntIndex().."SpawnProtection")
		surface.SetDrawColor(215,255,155,35)
		surface.DrawRect(0,ScrH()-32,ScrW(),32)
		draw.SimpleTextOutlined(
			"Spawn Protection - "..string.NiceTime(time),
			"gungame_medium",
			(ScrW()/2)+math.Clamp(time,28,100),
			ScrH()-18,
			Color(215,255,155,255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1,
			Color(0,0,0,255)
		)
	end


	local gg_txt = "Gun Game"
	local gg_col = Color(255,255,255)
	if GUNGAME.Config.TeamDeathmatch then
		gg_txt = "Team Gun Game"
		gg_col = team.GetColor(LocalPlayer():Team())
	end
	draw.SimpleTextOutlined(
		gg_txt,
		"gungame_medium",
		bottom_left[1]+8,
		bottom_left[2]-100,
		gg_col,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		2,
		Color(0,0,0,55)
	)
	if timerstate == "countdown" then
		if timer.Exists("gg_roundtimer") then
			local time = timer.TimeLeft("gg_roundtimer")
			if time > 1 then
				draw.SimpleTextOutlined(
					"Time Left: "..string.NiceTime(time),
					"gungame_medium",
					top_mid[1],
					top_mid[2]+72,
					Color(255,255,255),
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_CENTER,
					2,
					Color(0,0,0,155)
				)
			end
		end
	end
	if timerstate == "elapsed" then
		if timer.Exists("gg_roundtimer") then
			draw.SimpleTextOutlined(
				"Time Elapsed: "..string.NiceTime(timerelapsed),
				"gungame_medium",
				top_mid[1],
				top_mid[2]+72,
				Color(255,255,255),
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER,
				2,
				Color(0,0,0,155)
			)
		end		
	end
	if timer.Exists("RespawnTimer") then
		local timeleft = timer.TimeLeft("RespawnTimer")
		if timeleft > 1 then
			draw.SimpleTextOutlined(
				"Respawn available in... "..string.NiceTime(timeleft),
				"gungame_medium",
				middle[1],
				middle[2],
				Color(255,255,255),
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER,
				2,
				Color(0,0,0,155)
			)			
		end
	end
end

--[[-------------------------------------------------------------------------
Weapon Info ( Weapon, Ammo, Last Level, Next Level )
---------------------------------------------------------------------------]]
gg_weaponinfo = {}
gg_weaponinfo.primary = ""
gg_weaponinfo.secondary = ""
local function DrawWeaponInfo()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	local weaponname = ""
	local ammo,ammomax = 0,0

	if IsValid(wep) then
		weaponname = wep:GetPrintName()
		ammo = wep:Clip1()
		ammomax = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
		draw.SimpleTextOutlined(
			weaponname,
			"gungame_large",
			bottom_right[1]-32,
			bottom_right[2]-64,
			Color(255,215,155),
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER,
			2,
			Color(0,0,0,155)
		)
		if ammo > 0 then
			draw.SimpleTextOutlined(
				"Ammo: "..ammo.." / "..ammomax,
				"gungame_medium",
				bottom_right[1]-32,
				bottom_right[2]-24,
				Color(255,255,255),
				TEXT_ALIGN_RIGHT,
				TEXT_ALIGN_CENTER,
				2,
				Color(0,0,0,155)
			)
		end
	end
	local weplast = ""
	local wepnext = ""
	local level = LocalPlayer():GetNWInt("GunGame_Level")
	weplast = GUNGAME.Weapons[level-1]
	wepnext = GUNGAME.Weapons[level+1]
	if istable(weapons.Get(weplast)) then
		weplast = weapons.Get(weplast).PrintName
	end
	if istable(weapons.Get(wepnext)) then
		wepnext = weapons.Get(wepnext).PrintName
	end
	if table.HasValue(table.GetKeys(GUNGAME.Config.WeaponNames),weplast) then
		weplast = GUNGAME.Config.WeaponNames[weplast]
	end
	if table.HasValue(table.GetKeys(GUNGAME.Config.WeaponNames),wepnext) then
		wepnext = GUNGAME.Config.WeaponNames[wepnext]
	end
	if weplast && weplast != "" then
		draw.SimpleTextOutlined(
			"< "..tostring(weplast),
			"gungame_medium",
			bottom_right[1]-32,
			bottom_right[2]-136,
			Color(255,155,155,155),
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER,
			2,
			Color(0,0,0,155)
		)
	end
	if wepnext && wepnext != "" then
		draw.SimpleTextOutlined(
			tostring(wepnext).." >",
			"gungame_medium",
			bottom_right[1]-32,
			bottom_right[2]-106,
			Color(215,255,155,155),
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER,
			2,
			Color(0,0,0,155)
		)
	end
end

local lastlevels = {}
local function DrawLastLevel()
	if timer.Exists("gg_roundtimer") then
		for k , v in pairs(lastlevels) do
			if v != LocalPlayer() then
				distance = v:GetPos():Distance(LocalPlayer():GetPos())
				if distance < 500 then
					alpha2 = math.Clamp( distance/4,25,155)
				else
					alpha2 = 155
				end
				local tp = (v:GetPos() + Vector(0,0,80)):ToScreen()
				local tc = team.GetColor(v:Team())
				draw.SimpleTextOutlined("V","gungame_medium",tp.x,tp.y,Color(255,0,0,alpha2),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0,alpha2))
				draw.SimpleTextOutlined("LAST LEVEL!","gungame_medium",tp.x,tp.y-24,Color(255,0,0,alpha2),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0,alpha2))
			end
		end
	end
end

local function DrawTeam()
	if GUNGAME.Config.TeamDeathmatch then
		if timer.Exists("gg_roundtimer") then
			for k , v in pairs(player.GetAll()) do
				distance = v:GetPos():Distance(LocalPlayer():GetPos())
				if distance < 500 then
					alpha2 = math.Clamp( distance/4,25,155)
				else
					alpha2 = 155
				end
				local tp = (v:GetPos() + Vector(0,0,80)):ToScreen()
				local tc = team.GetColor(v:Team())
				if LocalPlayer():Team() == v:Team() && LocalPlayer() != v then
					draw.SimpleTextOutlined("V","gungame_medium",tp.x,tp.y,Color(tc.r,tc.g,tc.b,alpha2),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0,alpha2))
					draw.SimpleTextOutlined(v:Name(),"gungame_medium",tp.x,tp.y-24,Color(tc.r,tc.g,tc.b,alpha2),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0,alpha2))
				end
			end
		end
	end
end

function GM:PostDrawHUD()
	DrawLevelsAndHealth()
	DrawRoundInfo()
	GUNGAME.Functions.DrawWeaponSelection()
	DrawWeaponInfo()
	DrawTeam()
	DrawLastLevel()
end

net.Receive("GGNetworkLastLevel",function(len,pl)
	lastlevels = net.ReadTable()
end)

net.Receive("GGReceiveRoundTimer",function(len,pl)
	local state = net.ReadString()
	if state == "countdown" then
		local time = net.ReadInt(32)
		timerstate = "countdown"
		timer.Create("gg_roundtimer",time,1,function() end)
	end
	if state == "elapsed" then
		timerstate = "elapsed"
		timerelapsed = 0
		timer.Create("gg_roundtimer",1,0,function()
			timerelapsed = timerelapsed + 1
		end)
	end
	if state == "stop" then
		lastlevels = {}
		timerstate = "stop"
		timerelapsed = 0
		if timer.Exists("gg_roundtimer") then
			timer.Remove("gg_roundtimer")
		end
	end
end)

local huds = {["CHudHealth"] = true,["CHudBattery"] = true,["CHudAmmo"] = true,["CHudWeaponSelection"] = true,["CHudSecondaryAmmo"] = true}
hook.Add("HUDShouldDraw","GGHideDefaultHuds",function(a)
	if huds[a] then return false end
end)