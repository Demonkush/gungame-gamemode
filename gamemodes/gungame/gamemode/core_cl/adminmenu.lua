--[[-------------------------------------------------------------------------
Q Menu
---------------------------------------------------------------------------]]
local loadouttable = {}
local badstr = {"weapon_","demon_hl2_","m9k_","cw_ber_", "blast_", "bb_", "khr_", "cw_", "nz_", "deika_", "r_base_", "tfa_", "weapon_vj_"}
local gungame_menu = nil
local lastselectedwep = nil
local lastmenu = nil
local function CloseGunGameMenu() if IsValid(gungame_menu) then gungame_menu:Remove() end end
local function RebuildMenuArea()
	if IsValid(gungame_menu.menu) then gungame_menu.menu:Remove() end
	local menu_area = vgui.Create("DPanel",gungame_menu)
	menu_area:SetSize(gungame_menu:GetWide(),660)
	menu_area:SetPos(0,96)
	menu_area.Paint = function(self)
		surface.SetDrawColor(Color(155,155,155,55))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	gungame_menu.menu = menu_area
end

local tempweapontab = table.Copy(GUNGAME.Weapons)
local tempconfigtab = table.Copy(GUNGAME.Config)
local function Loadout()
	if !IsValid(gungame_menu) then return end
	RebuildMenuArea()
	local weaponselected = nil
	local core = gungame_menu.menu
	local title = vgui.Create("DLabel",core)
	title:SetPos(5,0)
	title:SetText("Loadout Menu")
	title:SetFont("gungame_medium")
	title:SizeToContents()

	local weaponlist = vgui.Create("DScrollPanel",core)
	weaponlist:SetSize(980,500)
	weaponlist:SetPos(25,50)
	weaponlist.weps = {}
	weaponlist.Paint = function(self)
		surface.SetDrawColor(Color(155,155,155,55))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end

	local addweapon = vgui.Create("DButton",core)
	addweapon:SetText("Add Weapon")
	addweapon:SetSize(180,40)
	addweapon:SetPos(25,560)
	addweapon:SetFont("gungame_medium")
	addweapon:SetColor(Color(215,255,215,255))
	addweapon.Paint = function(self)
		surface.SetDrawColor(0,25,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(215,255,215,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	addweapon.DoClick = function() GUNGAME.Functions.OpenWeaponBrowser(core) end

	local removeweapon = vgui.Create("DButton",core)
	removeweapon:SetText("Remove Weapon")
	removeweapon:SetSize(215,40)
	removeweapon:SetPos(215,560)
	removeweapon:SetFont("gungame_medium")
	removeweapon:SetColor(Color(255,215,215,255))
	removeweapon.Paint = function(self)
		surface.SetDrawColor(25,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,215,215,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	removeweapon.DoClick = function()
		if IsValid(weaponselected) then
			table.RemoveByValue(tempweapontab,weaponselected.Class)
			weaponselected:Remove() weaponselected = nil
			GUNGAME.Functions.RefreshWeaponList()
		end
	end

	local function OpenLoadWindow()
		local core = vgui.Create("DFrame")
		core:SetTitle("Load Loadout - ( Right Click = Remove )")
		core:SetSize(450,450)
		core:Center()
		core:MakePopup()
		core.Paint = function(self)
			surface.SetDrawColor(0,0,0,235)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end

		local container = vgui.Create("DScrollPanel",core)
		container:SetSize(core:GetWide(),core:GetTall()-24)
		container:SetPos(0,24)

		local function RemovePromptWindow(loadout)
			local remove_prompt = vgui.Create("DPanel",core)
			remove_prompt:SetSize(400,100)
			remove_prompt:SetPos(core:GetWide()/2-remove_prompt:GetWide()/2,core:GetTall()/2-remove_prompt:GetTall()/2)
			remove_prompt.Paint = function(self)
				surface.SetDrawColor(Color(0,0,0,245))
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
			local loadout_txt = string.TrimRight(loadout,".txt")
			local title = vgui.Create("DLabel",remove_prompt)
			title:SetText("Are you sure you want to delete this loadout:\n'"..loadout_txt.."'?")
			title:SetFont("DermaDefaultBold")
			title:SizeToContents()
			title:SetPos(remove_prompt:GetWide()/2-title:GetWide()/2,16)

			local button_no = vgui.Create("DButton",remove_prompt)
			button_no:SetText("No")
			button_no:SetFont("DermaDefaultBold")
			button_no:SetSize(80,25)
			button_no:SetPos(remove_prompt:GetWide()-100,64)
			button_no:SetColor(Color(255,255,255,255))
			button_no.DoClick = function()
				remove_prompt:Remove()
			end
			button_no.Paint = function(self)
				surface.SetDrawColor(0,0,0,235)
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
				surface.SetDrawColor(255,255,255,235)
				surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
				if self:IsHovered() then
					surface.SetDrawColor(255,255,255,55)
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
				end
			end

			local button_yes = vgui.Create("DButton",remove_prompt)
			button_yes:SetText("Yes")
			button_yes:SetFont("DermaDefaultBold")
			button_yes:SetSize(80,25)
			button_yes:SetPos(20,64)
			button_yes:SetColor(Color(255,255,255,255))
			button_yes.DoClick = function()
				net.Start("GGRemoveLoadout")
					net.WriteString(loadout)
				net.SendToServer()
				core:Remove()
				timer.Simple(0.1,function()
					OpenLoadWindow()
				end)
			end
			button_yes.Paint = function(self)
				surface.SetDrawColor(0,0,0,235)
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
				surface.SetDrawColor(255,255,255,235)
				surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
				if self:IsHovered() then
					surface.SetDrawColor(255,255,255,55)
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
				end
			end
		end

		local margin = 0
		for a, b in pairs(loadouttable) do
			local name = string.TrimRight(b,".txt")
			local button = vgui.Create("DButton",container)
			button:SetSize(container:GetWide()-40,20)
			button:SetPos(20,margin)
			button:SetFont("DermaDefaultBold")
			button:SetColor(Color(0,0,0,255))
			button:SetText(name)
			button.File = b
			button.DoRightClick = function()
				RemovePromptWindow(button.File)
			end
			button.DoClick = function()
				net.Start("GGLoadLoadout") net.WriteString(button.File) net.SendToServer()
				core:Remove()
				gungame_menu:Remove()
				GUNGAME.Functions.RequestAdminMenu()
			end

			margin = margin + 24
		end
	end
	local loadloadout = vgui.Create("DButton",core)
	loadloadout:SetText("Load Loadout")
	loadloadout:SetSize(180,40)
	loadloadout:SetPos(25,610)
	loadloadout:SetFont("gungame_medium")
	loadloadout:SetColor(Color(255,255,255,255))
	loadloadout.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	loadloadout.DoClick = function() OpenLoadWindow() end

	local function OpenSaveWindow()
		local core = vgui.Create("DFrame")
		core:SetTitle("Save Loadout")
		core:SetSize(450,100)
		core:Center()
		core:MakePopup()
		core.Paint = function(self)
			surface.SetDrawColor(0,0,0,235)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		local savename = GUNGAME.Config.LastSavedLoadout
		if savename == nil then savename = "--name of save--" end
		local text = vgui.Create("DTextEntry",core)
		text:SetPos(25,45)
		text:SetSize(200,35)
		text:SetText(savename)
		text.OnEnter = function( self ) savename = self:GetValue() end
		text.OnChange = function( self ) savename = self:GetValue() end
		local button = vgui.Create("DButton",core)
		button:SetSize(100,35)
		button:SetPos(240,45)
		button:SetText("Save")
		button:SetFont("gungame_medium")
		button:SetColor(Color(255,255,255,255))
		button.Paint = function(self)
			surface.SetDrawColor(0,0,0,235)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			surface.SetDrawColor(255,255,255,235)
			surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
			if self:IsHovered() then
				surface.SetDrawColor(255,255,255,55)
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
		end
		button.DoClick = function()
			if savename == "--name of save--" then return end
			GUNGAME.Config.LastSavedLoadout = savename
			chat.AddText( "Saving file: "..savename.."..." )
			net.Start("GGSaveLoadout") net.WriteString(savename) net.WriteTable(tempweapontab) net.WriteString(tempconfigtab.SecondaryWeapon) net.SendToServer()
			core:Remove()
			gungame_menu:Remove()
			GUNGAME.Functions.RequestAdminMenu()
		end
	end
	local saveloadout = vgui.Create("DButton",core)
	saveloadout:SetText("Save Loadout")
	saveloadout:SetSize(180,40)
	saveloadout:SetPos(215,610)
	saveloadout:SetFont("gungame_medium")
	saveloadout:SetColor(Color(255,255,255,255))
	saveloadout.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	saveloadout.DoClick = function() OpenSaveWindow() end

	local movedown = vgui.Create("DButton",core)
	movedown:SetText("Move Down")
	movedown:SetSize(150,40)
	movedown:SetPos(675,560)
	movedown:SetFont("gungame_medium")
	movedown:SetColor(Color(255,255,255,255))
	movedown.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	movedown.DoClick = function()
		if IsValid(weaponselected) then
			for a, b in pairs(tempweapontab) do
				if a == weaponselected.Key then
					local reptab = table.Copy(tempweapontab)
					if a>1 then tempweapontab[a] = reptab[a-1] tempweapontab[a-1] = reptab[a] end
					lastselectedwep = math.Clamp(a-1,1,#tempweapontab)
					GUNGAME.Functions.RefreshWeaponList()
				end
			end
		end
	end

	local moveup = vgui.Create("DButton",core)
	moveup:SetText("Move Top")
	moveup:SetSize(150,40)
	moveup:SetPos(840,560)
	moveup:SetFont("gungame_medium")
	moveup:SetColor(Color(255,255,255,255))
	moveup.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	moveup.DoClick = function()
		if IsValid(weaponselected) then
			for a, b in pairs(tempweapontab) do
				if a == weaponselected.Key then
					local reptab = table.Copy(tempweapontab)
					if a<#tempweapontab then 
						tempweapontab[a] = reptab[a+1] 
						tempweapontab[a+1] = reptab[a] 
					end
					lastselectedwep = math.Clamp(a+1,1,#tempweapontab)
					GUNGAME.Functions.RefreshWeaponList()
				end
			end
		end
	end

	local function OpenClipboardWindow()
		local core = vgui.Create("DFrame")
		core:SetTitle("Add from Clipboard")
		core:SetSize(450,100)
		core:Center()
		core:MakePopup()
		core.Paint = function(self)
			surface.SetDrawColor(0,0,0,235)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		if clipboard == nil then clipboard = "--paste here--" end
		local text = vgui.Create("DTextEntry",core)
		text:SetPos(25,45)
		text:SetSize(200,35)
		text:SetText(clipboard)
		text.OnEnter = function( self ) clipboard = self:GetValue() end
		text.OnChange = function( self ) clipboard = self:GetValue() end
		local button = vgui.Create("DButton",core)
		button:SetSize(100,35)
		button:SetPos(240,45)
		button:SetText("Apply")
		button:SetFont("gungame_medium")
		button:SetColor(Color(255,255,255,255))
		button.Paint = function(self)
			surface.SetDrawColor(0,0,0,235)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			surface.SetDrawColor(255,255,255,235)
			surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
			if self:IsHovered() then
				surface.SetDrawColor(255,255,255,55)
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
		end
		button.DoClick = function()
			if clipboard == "--paste here--" then return end
			chat.AddText( "Adding from Clipboard..." )
			local result = string.Explode(",",clipboard)
			if istable(result) then
				for a, b in pairs(result) do
					table.insert(tempweapontab,b)
				end
			end
			GUNGAME.Functions.RefreshWeaponList()
		end
	end
	local addfromcb = vgui.Create("DButton",core)
	addfromcb:SetText("Add from Clipboard")
	addfromcb:SetSize(250,40)
	addfromcb:SetPos(700,610)
	addfromcb:SetFont("gungame_medium")
	addfromcb:SetColor(Color(255,255,255,255))
	addfromcb.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	addfromcb.DoClick = function()
		OpenClipboardWindow()
	end

	local function CreateSecondary()
		if IsValid(core.secondaryselect) then core.secondaryselect:Remove() end
		local secondaryselect = vgui.Create("DButton",core)
		core.secondaryselect = secondaryselect
		secondaryselect:SetSize(64,64)
		secondaryselect:SetPos(520,570)
		secondaryselect:SetText("")
		secondaryselect.Image = Material("entities/"..tempconfigtab.SecondaryWeapon..".png")
		if secondaryselect.Image:IsError() then secondaryselect.Image = Material("vgui/entities/"..tempconfigtab.SecondaryWeapon..".png") end
		if secondaryselect.Image:IsError() then secondaryselect.Image = Material("weapons/swep") end
		secondaryselect.Paint = function(self)
			surface.SetMaterial(self.Image)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
			if self:IsHovered() then
				surface.SetDrawColor( Color( 255, 255, 255, 55 ) )
				surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
			end
		end
		secondaryselect.DoClick = function() GUNGAME.Functions.OpenWeaponBrowser(core,true) end
		local x,y = secondaryselect:GetPos()
		local title = vgui.Create("DLabel",core)
		title:SetText("Secondary Weapon")
		title:SetFont("gungame_small")
		title:SizeToContents()
		title:SetPos(x-(title:GetWide()/2-32),y-18)
		local footer = vgui.Create("DPanel",core)
		footer:SetSize(128,18)
		footer:SetPos(x-32,y+64)
		footer.Paint = function(self)
			surface.SetDrawColor(Color(0,0,0,255))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		secondaryselect.footer = footer
		secondaryselect.OnRemove = function() if IsValid(secondaryselect.footer) then secondaryselect.footer:Remove() end end
		local strtxt = tempconfigtab.SecondaryWeapon
		for z, v in pairs(badstr) do if string.match(tempconfigtab.SecondaryWeapon,v) then strtxt = string.TrimLeft(tempconfigtab.SecondaryWeapon,v) end end
		local txt = vgui.Create("DLabel",secondaryselect.footer)
		txt:SetPos(2,0)
		txt:SetFont("gungame_small")
		txt:SetColor(Color(255,255,255,255))
		txt:SetText(strtxt)
		txt:SetSize(100,18)
	end
	CreateSecondary()

	function GUNGAME.Functions.UnselectAll() for a, b in pairs(weaponlist.weps) do if IsValid(b) then b.Selected = false end end end
	function GUNGAME.Functions.RefreshWeaponList(wep)
		for a, b in pairs(weaponlist.weps) do if IsValid(b) then b:Remove() end end
		GUNGAME.Functions.CreateWeaponList(wep)
	end

	function GUNGAME.Functions.CreateWeaponList(lastwep)
		local marginx,marginy,row = 45,25,0
		for a, b in pairs(tempweapontab) do
			if isstring(b) then
				local wep = vgui.Create("DButton",weaponlist)
				wep:SetSize(96,96)
				wep:SetPos(marginx,marginy)
				wep.Image = Material("entities/"..b..".png")
				if wep.Image:IsError() then wep.Image = Material("vgui/entities/"..b..".png") end
				if wep.Image:IsError() then wep.Image = Material("weapons/swep") end
				wep:SetText("")
				local p = vgui.Create("Panel")
				p:SetVisible(false)
				p:SetSize(100+(string.len(b)*15),25)
				p.Paint = function(self)
					surface.SetDrawColor(Color(0,0,0,255))
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
					draw.SimpleTextOutlined(b,"gungame_medium",self:GetWide()/2,-2,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,Color(55,55,55,155))
				end
				wep:SetTooltipPanel(p)
				wep.Class = b
				wep.Key = a
				wep.Selected = false
				if wep.Class == lastwep then wep.Selected = true end
				table.insert(weaponlist.weps,wep)
				wep.Paint = function(self) 
					surface.SetMaterial(self.Image)
					surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
					surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )
					if self.Selected then
						surface.SetDrawColor( Color( 255, 0, 0, 155 ) )
						for i=1,3 do
							surface.DrawOutlinedRect(i,i,self:GetWide()-(i*2),self:GetTall()-(i*2))
						end
					end
					if self:IsHovered() then
						surface.SetDrawColor( Color( 255, 255, 255, 55 ) )
						surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
					end
					draw.SimpleTextOutlined(a,"gungame_medium",2,-4,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,Color(0,0,0,255))
				end
				wep.DoClick = function()
					if !wep.Selected then
						GUNGAME.Functions.UnselectAll()
						wep.Selected = true
						weaponselected = wep
						lastselectedwep = a
					else
						GUNGAME.Functions.UnselectAll()
						wep.Selected = false
						weaponselected = nil
						lastselectedwep = nil
					end
				end
				if lastselectedwep != nil then
					if lastselectedwep == a then
						wep.Selected = true
						weaponselected = wep
					end
				end
				local x,y = wep:GetPos()
				local footer = vgui.Create("DPanel",weaponlist)
				footer:SetSize(96,18)
				footer:SetPos(x,y+96)
				footer.Paint = function(self)
					surface.SetDrawColor(Color(0,0,0,255))
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
				end
				wep.footer = footer
				wep.OnRemove = function() if IsValid(wep.footer) then wep.footer:Remove() end end
				local strtxt = b
				for z, v in pairs(badstr) do if string.match(b,v) then strtxt = string.TrimLeft(b,v) end end
				local txt = vgui.Create("DLabel",wep.footer)
				txt:SetPos(2,0)
				txt:SetFont("gungame_small")
				txt:SetColor(Color(255,255,255,255))
				txt:SetText(strtxt)
				txt:SetSize(100,18)
				marginx = marginx + 128
				row = row + 1
				if row > 6 then
					row = 0
					marginx=45
					marginy=marginy+128
				end
			end
		end
	end
	GUNGAME.Functions.CreateWeaponList()

	local hl2 = {"weapon_crowbar","weapon_pistol","weapon_smg1","weapon_357","weapon_ar2","weapon_shotgun","weapon_crossbow","weapon_frag","weapon_rpg","weapon_stunstick"}
	function GUNGAME.Functions.OpenWeaponBrowser(core,secondary)
		if !IsValid(core) then return end
		local browser = vgui.Create("DFrame")
		browser:SetSize(640,480)
		browser:SetTitle("Weapon Browser")
		browser:Center()
		browser:MakePopup()
		browser.Paint = function(self)
			surface.SetDrawColor(Color(0,0,0,235))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		local tree = vgui.Create("DTree",browser)
		tree:Dock(FILL)
		local categories = {}
		local weponslist = {}
		local tolistweps = table.Copy(weapons.GetList())
		table.Add(tolistweps,hl2)
		for a, b in pairs(tolistweps) do
			local info = {}
			local cls = "weapon_crowbar"
			if !istable(b) then
				cls = b
				info.PrintName = "NO NAME"
				for c, d in pairs(GUNGAME.Config.WeaponNames) do if c == b then info.PrintName = d end end
				info.Category = "HALF-LIFE 2"
			else
				cls = b.ClassName
				info = weapons.GetStored(b.ClassName)
			end
			if info then
				table.insert(weponslist,{name=info.PrintName,category=info.Category,class=cls})
				if info.Category == nil then info.Category = "No Category" end
				if !table.HasValue(categories,info.Category) then table.insert(categories,info.Category) end
			end
		end
		for a, b in pairs(categories) do
			if b == nil then b = "No Category" end
			local node = tree:AddNode(b)
			for c, d in pairs(weponslist) do
				if d.category == b then
					if d.name == nil then d.name = d.class end
					local wep = node:AddNode(d.name)
					wep.class = d.class
					wep.DoClick = function()
						surface.PlaySound("buttons/button4.wav")
						if secondary then
							tempconfigtab.SecondaryWeapon = wep.class
							CreateSecondary()
						else
							table.insert(tempweapontab,wep.class)
							GUNGAME.Functions.RefreshWeaponList()
						end
					end
				end
			end
		end
	end
end

local function Shuffle()
	if !IsValid(gungame_menu) then return end
	RebuildMenuArea()

	local core = gungame_menu.menu

	local title = vgui.Create("DLabel",core)
	title:SetPos(5,0)
	title:SetText("Shuffle Menu")
	title:SetFont("gungame_medium")
	title:SizeToContents()

	local arrows = vgui.Create("DLabel",core)
	arrows:SetText("<\n\n\n>")
	arrows:SetFont("DermaLarge")
	arrows:SetPos(0,256)
	arrows:SizeToContents()
	arrows:CenterHorizontal()
	local arrows = vgui.Create("DLabel",core)
	arrows:SetText("Enable\n\n\n\n\nDisable")
	arrows:SetFont("DermaLarge")
	arrows:SetPos(0,225)
	arrows:SizeToContents()
	arrows:CenterHorizontal()

	local shuffles = vgui.Create("DScrollPanel",core)
	shuffles:SetSize(300,450)
	shuffles:SetPos(150,100)
	shuffles.Paint = function(self)
		surface.SetDrawColor(Color(155,215,155,55))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end

	local notshuffles = vgui.Create("DScrollPanel",core)
	notshuffles:SetSize(300,450)
	notshuffles:SetPos(570,100)
	notshuffles.Paint = function(self)
		surface.SetDrawColor(Color(215,155,155,55))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end

	local margin = 0
	for a, b in pairs(tempconfigtab.ShuffleTableLoaded) do
		local shuffbutton = vgui.Create("DButton",notshuffles)
		shuffbutton:SetPos(15,5+margin)
		shuffbutton:SetText(string.TrimRight(b,".txt"))
		shuffbutton:SetFont("gungame_medium")
		shuffbutton:SetSize(notshuffles:GetWide()-30,32)
		shuffbutton:SetColor(Color(255,215,215,255))
		shuffbutton.Paint = function(self)
			surface.SetDrawColor(55,0,0,235)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			surface.SetDrawColor(255,215,215,235)
			surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
			if self:IsHovered() then
				surface.SetDrawColor(255,255,255,55)
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
		end
		shuffbutton.DoClick = function()
			table.insert(tempconfigtab.ShuffleTable,b)
			table.RemoveByValue(tempconfigtab.ShuffleTableLoaded,b)
			Shuffle()
		end
		margin = margin + 40
	end

	local margin = 0
	for c, d in pairs(tempconfigtab.ShuffleTable) do
		local shuffbutton = vgui.Create("DButton",shuffles)
		shuffbutton:SetPos(15,5+margin)
		shuffbutton:SetText(string.TrimRight(d,".txt"))
		shuffbutton:SetFont("gungame_medium")
		shuffbutton:SetSize(shuffles:GetWide()-30,32)
		shuffbutton:SetColor(Color(215,255,215,255))
		shuffbutton.Paint = function(self)
			surface.SetDrawColor(0,55,0,235)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			surface.SetDrawColor(215,255,215,235)
			surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
			if self:IsHovered() then
				surface.SetDrawColor(255,255,255,55)
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
		end
		shuffbutton.DoClick = function()
			table.insert(tempconfigtab.ShuffleTableLoaded,d)
			table.RemoveByValue(tempconfigtab.ShuffleTable,d)
			Shuffle()
		end
		margin = margin + 40		
	end

	local title = vgui.Create("DLabel",core)
	title:SetPos(0,35)
	title:SetText("Click on a loadout to switch sides!")
	title:SetFont("gungame_medium")
	title:SizeToContents()
	title:CenterHorizontal()

	local check = vgui.Create("DCheckBoxLabel",core)
	check:SetPos(0,70)
	check:SetFont("DermaDefaultBold")
	check:SetText("Enable Loadout Shuffle?")
	check:SetValue(tempconfigtab.ShuffleLoadouts)
	check:SizeToContents()
	check:CenterHorizontal()
	check.OnChange = function()
		tempconfigtab.ShuffleLoadouts = check:GetChecked()
	end

	local save = vgui.Create("DButton",core)
	save:SetSize(175,35)
	save:SetFont("gungame_medium")
	save:SetText("Save")
	save:SetPos(0,core:GetTall()-75)
	save:CenterHorizontal()
	save:SetColor(Color(255,255,255,255))
	save.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	save.DoClick = function()
		chat.AddText( "Saving new shuffle settings to config..." )
		net.Start("GGSaveConfig") net.WriteTable(tempconfigtab) net.SendToServer()
	end
end

local function Settings()
	if !IsValid(gungame_menu) then return end
	RebuildMenuArea()

	local core = gungame_menu.menu

	local title = vgui.Create("DLabel",core)
	title:SetPos(5,0)
	title:SetText("Settings Menu")
	title:SetFont("gungame_medium")
	title:SizeToContents()

	local settingspanel = vgui.Create("DScrollPanel",core)
	settingspanel:SetSize(core:GetWide()-500,core:GetTall()-125)
	settingspanel:SetPos(250,50)
	settingspanel.Paint = function(self)
		surface.SetDrawColor(Color(25,25,25,245))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end

	local marginy = 15
	local marginx = 15
	-- Team Deathmatch
		if !tempconfigtab.TeamDeathmatch then tempconfigtab.TeamDeathmatch = GUNGAME.ConfigDefaults.TeamDeathmatch end
		local check = vgui.Create("DCheckBoxLabel",settingspanel)
		check:SetPos(marginx,marginy)
		check:SetText("Team Deathmatch")
		check:SetFont("DermaDefaultBold")
		check:SetTextColor(Color(255,255,255))
		check:SetValue(tempconfigtab.TeamDeathmatch)
		check:SizeToContents()
		check.OnChange = function(self)
			tempconfigtab.TeamDeathmatch = self:GetChecked()
		end
		marginy = marginy + 25
	-- Friendly Fire
		if !tempconfigtab.FriendlyFire then tempconfigtab.FriendlyFire = GUNGAME.ConfigDefaults.FriendlyFire end
		local check = vgui.Create("DCheckBoxLabel",settingspanel)
		check:SetPos(marginx,marginy)
		check:SetText("Friendly Fire")
		check:SetFont("DermaDefaultBold")
		check:SetTextColor(Color(255,255,255))
		check:SetValue(tempconfigtab.FriendlyFire)
		check:SizeToContents()
		check.OnChange = function(self)
			tempconfigtab.FriendlyFire = self:GetChecked()
		end
		marginy = marginy + 25
	-- Shuffle Weapons
		if !tempconfigtab.ShuffleWeapons then tempconfigtab.ShuffleWeapons = GUNGAME.ConfigDefaults.ShuffleWeapons end
		local check = vgui.Create("DCheckBoxLabel",settingspanel)
		check:SetPos(marginx,marginy)
		check:SetText("Shuffle Weapons")
		check:SetFont("DermaDefaultBold")
		check:SetTextColor(Color(255,255,255))
		check:SetValue(tempconfigtab.ShuffleWeapons)
		check:SizeToContents()
		check.OnChange = function(self)
			tempconfigtab.ShuffleWeapons = self:GetChecked()
		end
		marginy = marginy + 25
	-- Round Time
		if !tempconfigtab.RoundTime then tempconfigtab.RoundTime = GUNGAME.ConfigDefaults.RoundTime end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.RoundTime)
		txt.OnChange = function(self)
			tempconfigtab.RoundTime = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Round Time in Seconds")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Spawn Protection Time
		if !tempconfigtab.SpawnProtection then tempconfigtab.SpawnProtection = GUNGAME.ConfigDefaults.SpawnProtection end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.SpawnProtection)
		txt.OnChange = function(self)
			tempconfigtab.SpawnProtection = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Spawn Protection Time (0=disable)")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Timer State
		if !tempconfigtab.TimerState then tempconfigtab.TimerState = GUNGAME.ConfigDefaults.TimerState end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.TimerState)
		txt.OnChange = function(self)
			tempconfigtab.TimerState = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Timer Mode (0 = none, 1 = time elapsed, 2 = countdown)")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Kills to Level
		if !tempconfigtab.KillsToLevel then tempconfigtab.KillsToLevel = GUNGAME.ConfigDefaults.KillsToLevel end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.KillsToLevel)
		txt.OnChange = function(self)
			tempconfigtab.KillsToLevel = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Kills to Level")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Secondary Kill Levels Lost
		if !tempconfigtab.SecondaryKillLevelsLost then tempconfigtab.SecondaryKillLevelsLost = GUNGAME.ConfigDefaults.SecondaryKillLevelsLost end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.SecondaryKillLevelsLost)
		txt.OnChange = function(self)
			tempconfigtab.SecondaryKillLevelsLost = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Humiliation Loss")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Secondary Kill Levels Gain
		if !tempconfigtab.SecondaryKillLevelsGain then tempconfigtab.SecondaryKillLevelsGain = GUNGAME.ConfigDefaults.SecondaryKillLevelsGain end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.SecondaryKillLevelsGain)
		txt.OnChange = function(self)
			tempconfigtab.SecondaryKillLevelsGain = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Humiliation Gain")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Allow Free Ammo
		if !tempconfigtab.AllowFreeAmmo then tempconfigtab.AllowFreeAmmo = GUNGAME.ConfigDefaults.AllowFreeAmmo end
		local check = vgui.Create("DCheckBoxLabel",settingspanel)
		check:SetPos(marginx,marginy)
		check:SetText("Allow Free Ammo")
		check:SetFont("DermaDefaultBold")
		check:SetTextColor(Color(255,255,255))
		check:SetValue(tempconfigtab.AllowFreeAmmo)
		check:SizeToContents()
		check.OnChange = function(self)
			tempconfigtab.AllowFreeAmmo = self:GetChecked()
		end
		marginy = marginy + 25
	-- Allow Auto Bhop
		if !tempconfigtab.AllowAutoBhop then tempconfigtab.AllowAutoBhop = GUNGAME.ConfigDefaults.AllowAutoBhop end
		local check = vgui.Create("DCheckBoxLabel",settingspanel)
		check:SetPos(marginx,marginy)
		check:SetText("Allow Auto Bhop")
		check:SetFont("DermaDefaultBold")
		check:SetTextColor(Color(255,255,255))
		check:SetValue(tempconfigtab.AllowAutoBhop)
		check:SizeToContents()
		check.OnChange = function(self)
			tempconfigtab.AllowAutoBhop = self:GetChecked()
		end
		marginy = marginy + 25
	-- Delay Between Next Weapon
		if !tempconfigtab.DelayBetweenNextWeapon then tempconfigtab.DelayBetweenNextWeapon = GUNGAME.ConfigDefaults.DelayBetweenNextWeapon end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.DelayBetweenNextWeapon)
		txt.OnChange = function(self)
			tempconfigtab.DelayBetweenNextWeapon = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Delay Between Next Weapon")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Spawn Delay
		if !tempconfigtab.SpawnDelay then tempconfigtab.SpawnDelay = GUNGAME.ConfigDefaults.SpawnDelay end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.SpawnDelay)
		txt.OnChange = function(self)
			tempconfigtab.SpawnDelay = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Spawn Delay")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Spawn Auto Delay
		if !tempconfigtab.SpawnAutoDelay then tempconfigtab.SpawnAutoDelay = GUNGAME.ConfigDefaults.SpawnAutoDelay end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.SpawnAutoDelay)
		txt.OnChange = function(self)
			tempconfigtab.SpawnAutoDelay = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Auto-Spawn Delay")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Death Penalty
		if !tempconfigtab.DeathPenalty then tempconfigtab.DeathPenalty = GUNGAME.ConfigDefaults.DeathPenalty end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.DeathPenalty)
		txt.OnChange = function(self)
			tempconfigtab.DeathPenalty = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Death Penalty ( extra time on death )")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Regen Mode
		if !tempconfigtab.RegenMode then tempconfigtab.RegenMode = GUNGAME.ConfigDefaults.RegenMode end
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.RegenMode)
		txt.OnChange = function(self)
			tempconfigtab.RegenMode = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Regen Mode (1 = off, 2 = regen over time, 3 = regen on kill)")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Regen Amount
		if !tempconfigtab.RegenAmount then tempconfigtab.RegenAmount = GUNGAME.ConfigDefaults.RegenAmount end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.RegenAmount)
		txt.OnChange = function(self)
			tempconfigtab.RegenAmount = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Regen Amount")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Regen Interval
		if !tempconfigtab.RegenInterval then tempconfigtab.RegenInterval = GUNGAME.ConfigDefaults.RegenInterval end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.RegenInterval)
		txt.OnChange = function(self)
			tempconfigtab.RegenInterval = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Regen Interval ( time in between regen )")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Regen Last Hit Time
		if !tempconfigtab.RegenLastHitTime then tempconfigtab.RegenLastHitTime = GUNGAME.ConfigDefaults.RegenLastHitTime end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.RegenLastHitTime)
		txt.OnChange = function(self)
			tempconfigtab.RegenLastHitTime = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Regen Last Hit Time ( regen delay after taking damage )")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Regen Kill Amount
		if !tempconfigtab.RegenKillAmount then tempconfigtab.RegenKillAmount = GUNGAME.ConfigDefaults.RegenKillAmount end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.RegenKillAmount)
		txt.OnChange = function(self)
			tempconfigtab.RegenKillAmount = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Regen Kill Amount")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Overheal Amount
		if !tempconfigtab.OverhealAmount then tempconfigtab.OverhealAmount = GUNGAME.ConfigDefaults.OverhealAmount end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.OverhealAmount)
		txt.OnChange = function(self)
			tempconfigtab.OverhealAmount = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Overheal Amount")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Overheal Divider
		if !tempconfigtab.OverhealDivider then tempconfigtab.OverhealDivider = GUNGAME.ConfigDefaults.OverhealDivider end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.OverhealDivider)
		txt.OnChange = function(self)
			tempconfigtab.OverhealDivider = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Overheal Divider")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Walk Speed
		if !tempconfigtab.WalkSpeed then tempconfigtab.WalkSpeed = GUNGAME.ConfigDefaults.WalkSpeed end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.WalkSpeed)
		txt.OnChange = function(self)
			tempconfigtab.WalkSpeed = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Walk Speed")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Crouched Speed
		if !tempconfigtab.CrouchedSpeed then tempconfigtab.CrouchedSpeed = GUNGAME.ConfigDefaults.CrouchedSpeed end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.CrouchedSpeed)
		txt.OnChange = function(self)
			tempconfigtab.CrouchedSpeed = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Crouched Walk Speed (0 to 1)")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Run Speed
		if !tempconfigtab.RunSpeed then tempconfigtab.RunSpeed = GUNGAME.ConfigDefaults.RunSpeed end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.RunSpeed)
		txt.OnChange = function(self)
			tempconfigtab.RunSpeed = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Run Speed (0 = disable)")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Jump Height
		if !tempconfigtab.JumpHeight then tempconfigtab.JumpHeight = GUNGAME.ConfigDefaults.JumpHeight end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.JumpHeight)
		txt.OnChange = function(self)
			tempconfigtab.JumpHeight = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Jump Height (0 = disable)")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	-- Gravity
		if !tempconfigtab.Gravity then tempconfigtab.Gravity = GUNGAME.ConfigDefaults.Gravity end	
		local txt = vgui.Create("DTextEntry",settingspanel)
		txt:SetPos(marginx,marginy)
		txt:SetSize(100,15)
		txt:SetText(tempconfigtab.Gravity)
		txt.OnChange = function(self)
			tempconfigtab.Gravity = tonumber(self:GetValue())
		end
		local txtlbl = vgui.Create("DLabel",settingspanel)
		txtlbl:SetText("Gravity (Affects ALL players)")
		txtlbl:SetFont("DermaDefaultBold")
		txtlbl:SetPos(marginx+txt:GetWide()+10,marginy)
		txtlbl:SetColor(Color(255,255,255))
		txtlbl:SizeToContents()
		marginy = marginy + 25
	local divider = vgui.Create("DPanel",settingspanel)
	divider:SetPos(12,marginy)
	divider:SetSize(settingspanel:GetWide()-24,2)

	local save = vgui.Create("DButton",core)
	save:SetSize(175,35)
	save:SetFont("gungame_medium")
	save:SetText("Save")
	save:SetPos(core:GetWide()/2-256,core:GetTall()-55)
	save:SetColor(Color(255,255,255,255))
	save.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	save.DoClick = function()
		chat.AddText( "Saving new shuffle settings to config..." )
		net.Start("GGSaveConfig") net.WriteTable(tempconfigtab) net.SendToServer()
	end
	local reset = vgui.Create("DButton",core)
	reset:SetSize(100,35)
	reset:SetFont("gungame_medium")
	reset:SetText("Reset")
	reset:SetPos(core:GetWide()/2-52,core:GetTall()-55)
	reset:SetColor(Color(255,255,255,255))
	reset.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	reset.DoClick = function()
		net.Start("GGResetRound") net.SendToServer()
	end
	local defaults = vgui.Create("DButton",core)
	defaults:SetSize(175,35)
	defaults:SetFont("gungame_medium")
	defaults:SetText("Defaults")
	defaults:SetPos(core:GetWide()/2+75,core:GetTall()-55)
	defaults:SetColor(Color(255,255,255,255))
	defaults.Paint = function(self)
		surface.SetDrawColor(0,0,0,235)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,235)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
		if self:IsHovered() then
			surface.SetDrawColor(255,255,255,55)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	defaults.DoClick = function()
		tempconfigtab = table.Copy(GUNGAME.Config)
		gungame_menu:Remove()
		GUNGAME.Functions.RequestAdminMenu()
	end
end

local function OpenGunGameMenu(tab1,tab2)
	tempconfigtab = table.Copy(tab1)
	tempweapontab = table.Copy(tab2)
	if LocalPlayer():IsSuperAdmin() then
		CloseGunGameMenu()
		gungame_menu = vgui.Create("DFrame")
		gungame_menu:SetTitle("Gun Game - Admin Menu")
		gungame_menu:SetIcon("icon16/gun.png")
		gungame_menu:SetSize(1024,768)
		gungame_menu:ShowCloseButton(true)
		gungame_menu:SetDraggable(true)
		gungame_menu:Center()
		gungame_menu:MakePopup()
		gungame_menu.Paint = function(self)
			surface.SetDrawColor(Color(25,25,25,245))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		RebuildMenuArea()
		local tabs_bar = vgui.Create("DPanel",gungame_menu)
		tabs_bar:SetSize(gungame_menu:GetWide(),64)
		tabs_bar:SetPos(0,24)
		tabs_bar.Paint = function(self)
			surface.SetDrawColor(Color(155,155,155,55))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		local tabs = {}
		tabs[1] = {icon="icon16/gun.png",text="Loadout",func="loadout"}
		tabs[2] = {icon="icon16/arrow_switch.png",text="Shuffle",func="shuffle"}
		tabs[3] = {icon="icon16/script_edit.png",text="Settings",func="settings"}
		local margin_next,margin_start = 0,0
		margin_start = margin_start+#tabs*32
		for a, b in pairs(tabs) do
			local tab_icon = vgui.Create("DImage",tabs_bar)
			tab_icon:SetSize(16,16)
			tab_icon:SetPos(margin_start+margin_next+40,tabs_bar:GetTall()/2-24)
			tab_icon:SetImage(b.icon)
			local tab_label = vgui.Create("DLabel",tabs_bar)
			tab_label:SetText(b.text)
			tab_label:SetFont("DermaLarge")
			tab_label:SetPos(margin_start+margin_next,tabs_bar:GetTall()/2-8)
			tab_label:SizeToContents()
			local tab_button = vgui.Create("DButton",tabs_bar)
			tab_button:SetSize(tab_label:GetWide()+64,tab_label:GetTall()+32)
			tab_button:SetPos(margin_start+margin_next-32,tabs_bar:GetTall()/2-40)
			tab_button:SetText("")
			tab_button.DoClick = function()
				if b.func == "loadout" then Loadout() lastmenu = "loadout" end
				if b.func == "shuffle" then Shuffle() lastmenu = "shuffle" end
				if b.func == "settings" then Settings() lastmenu = "settings" end
				surface.PlaySound("buttons/button1.wav")
			end
			tab_button.Paint = function(self) 
				if self:IsHovered() then
					surface.SetDrawColor(155,155,155,15)
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
				end
			end
			margin_next = margin_next + 175
		end
		Loadout()
	end
end
net.Receive("GGUpdateLoadouts",function(len,pl)
	local loadouts = net.ReadTable()
	loadouttable = table.Copy(loadouts)
end)
net.Receive("GGAdminMenuSend",function(len,pl) 
	local tab = net.ReadTable() 
	local tab2 = net.ReadTable() 
	local tab3 = net.ReadTable()
	loadouttable = table.Copy(tab3)
	OpenGunGameMenu(tab,tab2) 
	if lastmenu != nil then
		if IsValid(gungame_menu) then
			if lastmenu == "loadout" then
				Loadout()
			end
			if lastmenu == "shuffle" then
				Shuffle()
			end
			if lastmenu == "settings" then
				Settings()
			end
		end
	end
end)
function GUNGAME.Functions.RequestAdminMenu() net.Start("GGAdminMenuRequest") net.SendToServer() end
function GM:OnSpawnMenuOpen() GUNGAME.Functions.RequestAdminMenu() end