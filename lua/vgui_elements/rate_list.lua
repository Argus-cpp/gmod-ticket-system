local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle('')

	self.uppnl = vgui.Create('DPanel', self)
	self.uppnl:Dock(TOP)
	self.uppnl:SetTall(30)
	self.uppnl:DockMargin(1,5,1,5)

	self.uppnl.Paint = function(self,w,h)

		STS.settings:drawRectOutlined(0,h-2,w,2,Color(10,10,10,150))

		draw.SimpleText('Nick', 'GModToolHelp', 25, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	
		draw.SimpleText('Accepted ticket', 'GModToolHelp', w*0.35, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
		draw.SimpleText('Skipped ticket', 'GModToolHelp', w*0.65, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
		draw.SimpleText('Rating', 'GModToolHelp', w-10, h/2, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)	
	end

	self.scrlpnl = vgui.Create('DScrollPanel', self)
	self.scrlpnl:Dock(FILL)

	for k, ply in pairs(player.GetAll()) do
		if !table.HasValue(STS.root.managers, ply:GetUserGroup()) then continue end
		local PStat = self.scrlpnl:Add('DPanel')
		PStat:Dock(TOP)
		PStat:DockMargin(1, 1, 1, 2)

		PStat.OnMousePressed = function()
			SetClipboardText(ply:SteamID())
			STS.Notify(STS.Language[STS.Config.language]['steamid_copied'], Color(255,255,255), 3)
		end

		PStat.Paint = function(self,w,h)
			if self:IsHovered() then
				self:SetCursor('hand')
			end

			STS.settings:drawRectOutlined(0,0,w,30,Color(10,10,10,150))

			draw.SimpleText(ply:Nick(), 'ChatFont', 25, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	
			draw.SimpleText(ply:getAcceptedTicket(), 'ChatFont', w*0.35, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
			draw.SimpleText(ply:getSkippedTicket(), 'ChatFont', w*0.65, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	

			local total_score = ply:getTicketRating()

			if (total_score <= 0.3) then
				surface.SetMaterial(Material('sts/stars/0.png'))
			elseif (total_score > 0.3) and (total_score <= 0.5) then
				surface.SetMaterial(Material('sts/stars/1.png'))
			elseif (total_score > 0.5) and (total_score <= 1.3) then
				surface.SetMaterial(Material('sts/stars/2.png'))
			elseif (total_score > 1.3) and (total_score <= 1.5) then
				surface.SetMaterial(Material('sts/stars/3.png'))
			elseif (total_score > 1.5) and (total_score <= 2.3) then
				surface.SetMaterial(Material('sts/stars/4.png'))
			elseif (total_score > 2.3) and (total_score <= 2.7) then
				surface.SetMaterial(Material('sts/stars/5.png'))
			elseif (total_score > 2.7) and (total_score <= 3.3) then
				surface.SetMaterial(Material('sts/stars/6.png'))
			elseif (total_score > 3.3) and (total_score <= 3.7) then
				surface.SetMaterial(Material('sts/stars/7.png'))
			elseif  (total_score > 3.7) and (total_score <= 4.3) then
				surface.SetMaterial(Material('sts/stars/8.png'))
			elseif (total_score > 4.3) and (total_score <= 4.7) then
				surface.SetMaterial(Material('sts/stars/9.png'))
			elseif (total_score > 4.7) then
				surface.SetMaterial(Material('sts/stars/10.png'))
			end
		
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(w-105,h/2-10,100,20)

			draw.SimpleText(total_score.."/5", 'ChatFont', w-110, h/2, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)	
		end

		local image = vgui.Create('AvatarImage', PStat)
		image:SetPlayer(ply,128)
		image:SetSize(16,16)
		image:SetPos(5,5)
	end

	local scrollBar = self.scrlpnl:GetVBar()
	scrollBar:DockMargin(-5, 0, 0, 0)

	scrollBar.Paint = function() return end

	function scrollBar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 160))
	end

	function scrollBar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 160))
	end

	function scrollBar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 160))
	end

	local BClose = vgui.Create('DButton', self)
	BClose:SetText("")
	BClose:SetSize(24,24)
	
	timer.Simple(0, function()
		BClose:SetPos(self:GetWide()-BClose:GetWide()-5, 3)
	end)
	
	BClose.Paint = function(self,w,h)
		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawOutlinedRect(0, 0, w, h)

		if self:IsHovered() then
			surface.SetDrawColor(Color(110, 10, 10, 180))
		else
			surface.SetDrawColor(Color(70, 10, 10, 180))
		end

		surface.DrawRect(0, 0, w, h)

		draw.SimpleText('x', 'GModToolHelp', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	BClose.DoClick = function() self:Remove() end
end

function PANEL:Paint(w,h)
	STS.settings:drawBlurPanelOutlined(self, Color(10,10,10, 100), 2, 5)
	STS.settings:drawRectOutlined(0,0,w,30,Color(10,10,10,150))

	draw.SimpleText(STS.Language[STS.Config.language]['menu_title'], 'GModToolSubtitle', w/2, 15, Color(2, 185, 217), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("rate_list", PANEL, "DFrame")

concommand.Add('adminrate', function()
	if !table.HasValue(STS.root.managers, LocalPlayer():GetUserGroup()) then return end

	local frame = vgui.Create('rate_list')
	frame:SetSize(700,500)
	frame:Center()
	frame:MakePopup()
end)