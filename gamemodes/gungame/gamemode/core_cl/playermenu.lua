local model_select = 1
local model_list = {}
local mat_grad = Material("vgui/gradient_up")
local function OpenPlayerModelMenu()
	model_list = {}
	for a, b in pairs(player_manager.AllValidModels()) do
		table.insert(model_list,{id=a,model=b})
	end

	local core = vgui.Create("DFrame")
	core:SetSize(640,480)
	core:Center()
	core:SetTitle("")
	core:SetDraggable(true)
	core:ShowCloseButton(true)
	core:MakePopup()
	core.Paint = function(self)
		surface.SetDrawColor(Color(55,55,55,255))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end

	local title = vgui.Create("DLabel",core)
	title:SetFont("DermaLarge")
	title:SetText("Playermodel Menu")
	title:SizeToContents()
	title:SetPos(0,32)
	title:CenterHorizontal()

	local total = #model_list
	local num = vgui.Create("DLabel",core)
	num:SetFont("DermaLarge")
	num:SetText(model_select.." / "..total)
	num:SizeToContents()
	num:SetPos(0,core:GetTall()-64)
	num:CenterHorizontal()

	-- Previous Model
	if model_list[model_select-1] then
		local prev_model_panel = vgui.Create("DPanel",core)
		prev_model_panel:SetSize(100,200)
		prev_model_panel:SetPos(75,0)
		prev_model_panel:CenterVertical()
		prev_model_panel.Paint = function(self)
			surface.SetDrawColor(Color(0,0,0,155))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())

			surface.SetMaterial(mat_grad)
			surface.SetDrawColor(Color(155,155,155,15))
			surface.DrawTexturedRect(8,8,self:GetWide()-16,self:GetTall()-16)
		end

		local prev_model = vgui.Create("DModelPanel",prev_model_panel)
		prev_model:SetModel(model_list[model_select-1].model)
		prev_model:SetSize(prev_model_panel:GetWide(),prev_model_panel:GetTall())
		prev_model:SetCamPos(Vector(0,35,35))
		prev_model:SetLookAt(Vector(0,0,35))

		local prev_model_button = vgui.Create("DButton",prev_model_panel)
		prev_model_button:SetSize(prev_model_panel:GetWide(),prev_model_panel:GetTall())
		prev_model_button:SetText("")
		prev_model_button.Paint = function(self)
			if self:IsHovered() then
				surface.SetDrawColor(Color(255,255,255,55))
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
		end
		prev_model_button.DoClick = function()
			model_select = model_select - 1
			core:Close()
			OpenPlayerModelMenu()
			surface.PlaySound("buttons/button3.wav")
		end

		local prev_model_label = vgui.Create("DLabel",prev_model_panel)
		prev_model_label:SetText(model_list[model_select-1].id)
		prev_model_label:SizeToContents()
		prev_model_label:SetPos(prev_model_panel:GetWide()/2-prev_model_label:GetWide()/2,prev_model_panel:GetTall()-16)
	end

	-- Current Model
		local current_model_panel = vgui.Create("DPanel",core)
		current_model_panel:SetSize(150,300)
		current_model_panel:Center()
		current_model_panel.Paint = function(self)
			surface.SetDrawColor(Color(0,0,0,155))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())

			surface.SetMaterial(mat_grad)
			surface.SetDrawColor(Color(155,155,155,15))
			surface.DrawTexturedRect(8,8,self:GetWide()-16,self:GetTall()-16)
		end

		local current_model = vgui.Create("DModelPanel",current_model_panel)
		current_model:SetModel(model_list[model_select].model)
		current_model:SetSize(current_model_panel:GetWide(),current_model_panel:GetTall())
		current_model:SetCamPos(Vector(0,35,35))
		current_model:SetLookAt(Vector(0,0,35))

		local current_model_button = vgui.Create("DButton",current_model_panel)
		current_model_button:SetSize(current_model_panel:GetWide(),current_model_panel:GetTall())
		current_model_button:SetText("")
		current_model_button.Paint = function(self)
			if self:IsHovered() then
				surface.SetDrawColor(Color(255,255,255,55))
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
		end
		current_model_button.DoClick = function()
			RunConsoleCommand("cl_playermodel",model_list[model_select].id)
			chat.AddText("You will spawn as "..model_list[model_select].id)
			core:Close()
			surface.PlaySound("buttons/button2.wav")
		end

		local current_model_label = vgui.Create("DLabel",current_model_panel)
		current_model_label:SetText(model_list[model_select].id)
		current_model_label:SizeToContents()
		current_model_label:SetPos(current_model_panel:GetWide()/2-current_model_label:GetWide()/2,current_model_panel:GetTall()-16)

	if model_list[model_select+1] then
		local next_model_panel = vgui.Create("DPanel",core)
		next_model_panel:SetSize(100,200)
		next_model_panel:SetPos(core:GetWide()-175,0)
		next_model_panel:CenterVertical()
		next_model_panel.Paint = function(self)
			surface.SetDrawColor(Color(0,0,0,155))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())

			surface.SetMaterial(mat_grad)
			surface.SetDrawColor(Color(155,155,155,15))
			surface.DrawTexturedRect(8,8,self:GetWide()-16,self:GetTall()-16)
		end

		local next_model = vgui.Create("DModelPanel",next_model_panel)
		next_model:SetModel(model_list[model_select+1].model)
		next_model:SetSize(next_model_panel:GetWide(),next_model_panel:GetTall())
		next_model:SetCamPos(Vector(0,35,35))
		next_model:SetLookAt(Vector(0,0,35))

		local next_model_button = vgui.Create("DButton",next_model_panel)
		next_model_button:SetSize(next_model_panel:GetWide(),next_model_panel:GetTall())
		next_model_button:SetText("")
		next_model_button.Paint = function(self)
			if self:IsHovered() then
				surface.SetDrawColor(Color(255,255,255,55))
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
		end
		next_model_button.DoClick = function()
			model_select = model_select + 1
			core:Close()
			OpenPlayerModelMenu()
			surface.PlaySound("buttons/button3.wav")
		end

		local next_model_label = vgui.Create("DLabel",next_model_panel)
		next_model_label:SetText(model_list[model_select+1].id)
		next_model_label:SizeToContents()
		next_model_label:SetPos(next_model_panel:GetWide()/2-next_model_label:GetWide()/2,next_model_panel:GetTall()-16)
	end
end

local function OpenGunGameMenu()
	local core = vgui.Create("DFrame")
	core:SetSize(640,480)
	core:Center()
	core:SetTitle("")
	core:SetDraggable(true)
	core:ShowCloseButton(true)
	core:MakePopup()
	core.Paint = function(self)
		surface.SetDrawColor(Color(55,55,55,245))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end

	local title = vgui.Create("DLabel",core)
	title:SetText("Gun Game "..GUNGAME.Config.Version)
	title:SetFont("gungame_medium")
	title:SetPos(0,35)
	title:SetColor(Color(255,255,255,255))
	title:SizeToContents()
	title:CenterHorizontal()	

	local author = vgui.Create("DLabel",core)
	author:SetText("by Demonkush, made for FumingStone~")
	author:SetFont("gungame_small")
	author:SetPos(0,65)
	author:SetColor(Color(155,215,255,255))
	author:SizeToContents()
	author:CenterHorizontal()

	local author = vgui.Create("DLabel",core)
	author:SetText("Font Used: Helmet by Carl Enlund")
	author:SetFont("gungame_small")
	author:SetPos(0,80)
	author:SetColor(Color(255,215,155,255))
	author:SizeToContents()
	author:CenterHorizontal()
	
	local divider = vgui.Create("DPanel",core)
	divider:SetPos(0,100)
	divider:SetSize(300,2)
	divider:CenterHorizontal()

	local button_setmodel = vgui.Create("DButton",core)
	button_setmodel:SetPos(0,120)
	button_setmodel:SetSize(200,40)
	button_setmodel:SetColor(Color(255,255,255,255))
	button_setmodel:SetFont("DermaDefaultBold")
	button_setmodel:SetText("Change Playermodel")
	button_setmodel:CenterHorizontal()
	button_setmodel.Paint = function(self)
		surface.SetDrawColor(Color(0,0,0,215))
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(Color(255,255,255,215))
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())		
		if self:IsHovered() then
			surface.SetDrawColor(Color(255,255,255,155))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
	end
	button_setmodel.DoClick = function()
		OpenPlayerModelMenu()
		core:Close()
	end

	if GUNGAME.Config.TeamDeathmatch then
		local teamtitle = vgui.Create("DLabel",core)
		teamtitle:SetText("Change Team?")
		teamtitle:SetPos(0,155)
		teamtitle:SetFont("gungame_medium")
		teamtitle:SizeToContents()
		teamtitle:CenterHorizontal()

		local team1 = vgui.Create("DButton",core)
		team1:SetSize(200,200)
		team1:SetPos(100,200)
		team1:SetText("Team 1")
		team1:SetFont("gungame_large")
		team1:SetTextColor(Color(255,255,255,255))
		team1.Paint = function(self)
			surface.SetDrawColor(Color(155,55,55,245))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())		
		end
		team1.DoClick = function()
			net.Start("GGRequestTeamSwitch")
				net.WriteBool(true)
			net.SendToServer()
			core:Remove()
		end

		local team2 = vgui.Create("DButton",core)
		team2:SetSize(200,200)
		team2:SetPos(350,200)
		team2:SetText("Team 2")
		team2:SetFont("gungame_large")
		team2:SetTextColor(Color(255,255,255,255))
		team2.Paint = function(self)
			surface.SetDrawColor(Color(55,100,155,245))
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())		
		end
		team2.DoClick = function()
			net.Start("GGRequestTeamSwitch")
				net.WriteBool(false)
			net.SendToServer()
			core:Remove()
		end
	end
end
concommand.Add("GunGameMenu",OpenGunGameMenu)