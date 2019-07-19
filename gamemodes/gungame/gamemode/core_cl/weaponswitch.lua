--[[-------------------------------------------------------------------------
Weapon Swap
---------------------------------------------------------------------------]]
local nextswap = 0
local scrw,scrh = ScrW(),ScrH()
local top_left,top_mid,top_right 			= {0,0},		{scrw/2,0},			{scrw,0}
local middle_left,middle,middle_right 		= {0,scrh/2},	{scrw/2,scrh/2},	{scrw,scrh/2} 
local bottom_left,bottom_mid,bottom_right 	= {0,scrh},		{scrw/2,scrh},		{scrw,scrh}
hook.Add("PlayerBindPress","gungameScrollWheel",function(ply,bind,pressed)
	if nextswap < CurTime() then
		if bind == "invprev" or bind == "invnext" then
			gungame_SwapWeapons("swap")
			nextswap = CurTime() + 0.2
		end
		if bind == "slot1" then gungame_SwapWeapons("primary") end
		if bind == "slot2" then gungame_SwapWeapons("secondary") end
	end
end)

--[[-------------------------------------------------------------------------
Weapon Selection
---------------------------------------------------------------------------]]
if !gg_weaponselect then gg_weaponselect = {} end
gg_weaponselect.primaryselected = true
local primarysize,primarypos,primaryoffsets = 80,{96,106},{16,16}
local secondarysize,secondarypos,secondaryoffsets = 64,{-64,96},{16,16}
local glowfx,glowfxswitch = 0,false
local function CreatePrimaryWeaponSlot()
	if IsValid(gg_weaponselect.primarypanel) then  gg_weaponselect.primarypanel:Remove() end
	gg_weaponselect.primarypanel = vgui.Create("DFrame")
	gg_weaponselect.primarypanel:SetPos(bottom_mid[1]-primarypos[1]-primaryoffsets[1],bottom_mid[2]-primarypos[2]-primaryoffsets[2])
	gg_weaponselect.primarypanel:SetSize(primarysize,primarysize)
	gg_weaponselect.primarypanel:SetTitle("1")
	gg_weaponselect.primarypanel:SetDraggable(false)
	gg_weaponselect.primarypanel:ShowCloseButton(false)
	gg_weaponselect.primarypanel.Paint = function(self)
		draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(25,25,25,215))
		if gg_weaponselect.primaryselected then
			if glowfxswitch then glowfx = glowfx + (FrameTime()*32) if glowfx >= 45 then glowfxswitch = false end end
			if !glowfxswitch then glowfx = glowfx - (FrameTime()*32) if glowfx <= 0 then glowfxswitch = true end end
			draw.RoundedBox(4,4,4,self:GetWide()-8,self:GetTall()-8,Color(155,155,155,glowfx))
		end
	end
	local item = vgui.Create("DLabel",gg_weaponselect.primarypanel)
	item:SetText("Main")
	item:SetFont("gungame_small")
	item:SetColor(Color(215,215,215,155))
	item:SizeToContents()
	item:SetPos(primarysize/2-(item:GetWide()/2),primarysize/2)
	gg_weaponselect.primarypanel.item = item
end
local function CreateSecondaryWeaponSlot()
	if IsValid(gg_weaponselect.secondarypanel) then  gg_weaponselect.secondarypanel:Remove() end
	gg_weaponselect.secondarypanel = vgui.Create("DFrame")
	gg_weaponselect.secondarypanel:SetPos(bottom_mid[1]-secondarypos[1]-secondaryoffsets[1],bottom_mid[2]-secondarypos[2]-secondaryoffsets[2])
	gg_weaponselect.secondarypanel:SetSize(secondarysize,secondarysize)
	gg_weaponselect.secondarypanel:SetTitle("2")
	gg_weaponselect.secondarypanel:SetDraggable(false)
	gg_weaponselect.secondarypanel:ShowCloseButton(false)
	gg_weaponselect.secondarypanel:SetAlpha(115)
	gg_weaponselect.secondarypanel.Paint = function(self)
		draw.RoundedBox(4,0,0,self:GetWide(),self:GetTall(),Color(25,25,25,215))
		if !gg_weaponselect.primaryselected then
			if glowfxswitch then glowfx = glowfx + (FrameTime()*32) if glowfx >= 45 then glowfxswitch = false end end
			if !glowfxswitch then glowfx = glowfx - (FrameTime()*32) if glowfx <= 0 then glowfxswitch = true end end
			draw.RoundedBox(4,4,4,self:GetWide()-8,self:GetTall()-8,Color(155,155,155,glowfx))
		end
	end	
	local item = vgui.Create("DLabel",gg_weaponselect.secondarypanel)
	item:SetText("Melee")
	item:SetFont("gungame_small")
	item:SetColor(Color(215,215,215,155))
	item:SizeToContents()
	item:SetPos(secondarysize/2-(item:GetWide()/2),secondarysize/2)
	gg_weaponselect.secondarypanel.item = item
end
function gungame_ClearWeaponSlots()
	if IsValid(gg_weaponselect.primarypanel) then gg_weaponselect.primarypanel:Remove() end
	if IsValid(gg_weaponselect.secondarypanel) then gg_weaponselect.secondarypanel:Remove() end
end
local function FocusPrimary()
	primarysize = 80
	primaryoffsets = {16,16}
	secondarysize = 64
	secondaryoffsets = {16,16}
	gg_weaponselect.primaryselected = true
	if IsValid(gg_weaponselect.primarypanel) then
		gg_weaponselect.primarypanel:SizeTo(primarysize,primarysize,0.5,0,-1)
		gg_weaponselect.primarypanel:AlphaTo(255,0.5,0)
		local item = gg_weaponselect.primarypanel.item
		item:MoveTo(primarysize/2-(item:GetWide()/2),primarysize/2,0.5,0,-1)
	else return end
	
	if IsValid(gg_weaponselect.secondarypanel) then
		gg_weaponselect.secondarypanel:SizeTo(secondarysize,secondarysize,0.5,0,-1)
		gg_weaponselect.secondarypanel:AlphaTo(115,0.5,0)
		local item = gg_weaponselect.secondarypanel.item
		item:MoveTo(secondarysize/2-(item:GetWide()/2),secondarysize/2,0.5,0,-1)
	end

	net.Start("GGReceiveWeaponSwitch")
		net.WriteBool(true)
	net.SendToServer()
end
local function FocusSecondary()
	primarysize = 64
	primaryoffsets = {8,8}
	secondarysize = 80
	secondaryoffsets = {24,24}
	gg_weaponselect.primaryselected = false
	gg_weaponselect.primarypanel:SizeTo(primarysize,primarysize,0.5,0,-1)
	gg_weaponselect.primarypanel:AlphaTo(115,0.5,0)
	local item = gg_weaponselect.primarypanel.item
	item:MoveTo(primarysize/2-(item:GetWide()/2),primarysize/2,0.5,0,-1)
	
	gg_weaponselect.secondarypanel:SizeTo(secondarysize,secondarysize,0.5,0,-1)
	gg_weaponselect.secondarypanel:AlphaTo(255,0.5,0)
	local item = gg_weaponselect.secondarypanel.item
	item:MoveTo(secondarysize/2-(item:GetWide()/2),secondarysize/2,0.5,0,-1)

	net.Start("GGReceiveWeaponSwitch")
		net.WriteBool(false)
	net.SendToServer()
end
function gungame_SwapWeapons(mode)
	if !IsValid(gg_weaponselect.primarypanel) then return end
	if !IsValid(gg_weaponselect.secondarypanel) then return end
	if mode != "swap" then
		if gg_weaponselect.primaryselected && mode == "secondary" then FocusSecondary() end
		if !gg_weaponselect.primaryselected && mode == "primary" then FocusPrimary() end
	else
		if gg_weaponselect.primaryselected then
			FocusSecondary()
		else
			FocusPrimary()
		end
	end
	gg_weaponselect.primarypanel:MoveTo(bottom_mid[1]-primarypos[1]-primaryoffsets[1],bottom_mid[2]-primarypos[2]-primaryoffsets[2],0.5,0,-1)
	gg_weaponselect.secondarypanel:MoveTo(bottom_mid[1]-secondarypos[1]-secondaryoffsets[1],bottom_mid[2]-secondarypos[2]-secondaryoffsets[2],0.5,0,-1)
end
function GUNGAME.Functions.DrawWeaponSelection()
	if !IsValid(gg_weaponselect.primarypanel) then CreatePrimaryWeaponSlot() end
	if !IsValid(gg_weaponselect.secondarypanel) then CreateSecondaryWeaponSlot() end
end
net.Receive("GGResetClientside",function(len,pl) FocusPrimary() end)