local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetDraggable(true)

	self.time = CurTime() + STS.Config.tickettime

	local BClose = vgui.Create('DButton', self)
	BClose:SetText("")
	BClose:SetSize(24+surface.GetTextSize(STS.Language[STS.Config.language]['close_ticket']),24)
	timer.Simple(0, function()
		BClose:SetPos(self:GetWide()-BClose:GetWide()-5, 2)
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

		draw.SimpleText(STS.Language[STS.Config.language]['close_ticket'], 'GModToolHelp', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	BClose.DoClick = function() surface.PlaySound('ui/buttonclick.wav') net.Start('close_ticket') net.WriteEntity(self.target) net.SendToServer() self:Remove() end

	self.avatar = vgui.Create("AvatarImage", self)
	timer.Simple(0, function()
		self.avatar:SetPlayer(self.target, 128)
	end)
	self.avatar:SetPos(0, 35)
	self.avatar:SetSize(105,105)
	self.avatar:Dock(LEFT)
	self.avatar:DockMargin(4, 4, 4, 4)

	self.BPanel = vgui.Create('DPanel', self)
	self.BPanel:Dock(FILL)
	self.BPanel.Paint = function() end

	local x, y = 5, 7
	local count = 0

	for k,v in pairs(STS.Config.buttonlist)do
		if (count != 0) and (count % 3 == 0) then x = x + 145 y = 7 count = 0 end
		local button = vgui.Create('DButton', self.BPanel)
		button:SetPos(x, y+count*32)
		button:SetSize(140,30)
		button:SetText("")

		button.Paint = function(self,w,h)
			STS.settings:drawRectOutlined(0,0,w,30,Color(10,10,10,150))

			if self:IsHovered() then
				draw.SimpleText(v.text, "GModToolHelp", w/2-40, h/2, Color(2, 185, 217), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(v.text, "GModToolHelp", w/2-40, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			surface.SetMaterial(Material(v.icon))
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(6,5,20,20)
		end

		button.DoClick = function() v.func(self.ply, self.target) net.Start('ticket_button') net.WriteInt(k, 32) net.WriteEntity(self.target) net.SendToServer() surface.PlaySound('ui/buttonclick.wav') end
		
		count = count + 1
	end
end

// Set admin
function PANEL:SetPly(ply)
	self.ply = ply
end

// Set target
function PANEL:SetTarget(ply)
	self.target = ply
end

function PANEL:Think()
	if !IsValid(self.target) then self:Remove() end
end

function PANEL:Paint(w,h)
	STS.settings:drawBlurPanelOutlined(self, Color(10,10,10, 100), 2, 5)
	STS.settings:drawRectOutlined(0,0,w,30,Color(10,10,10,150))

	draw.RoundedBox(0, 0, h-5, w,5,Color(2, 185, 217,50))
	draw.RoundedBox(0, 0, h-5, w*((self.time-CurTime())/STS.Config.tickettime),5,Color(2, 185, 217))

	draw.SimpleText(STS.Language[STS.Config.language]['ticket_by']..self.target:Nick(), 'GModToolHelp', 5, 7, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register('accepted_ticket', PANEL, 'DFrame')