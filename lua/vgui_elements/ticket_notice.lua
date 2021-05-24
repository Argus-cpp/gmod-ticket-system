local PANEL = {}

function PANEL:Init()

	self.time = CurTime() + STS.Config.noticetime
	self.title = ""

	self:ShowCloseButton(false)

	self.txtpanel = vgui.Create("DTextEntry", self)
	self.txtpanel:SetMultiline(true)
	self.txtpanel:Dock(FILL)
	self.txtpanel:DockMargin(1, 5, 1, 5)
	self.txtpanel:SetVerticalScrollbarEnabled(true)
	self.txtpanel:SetFont('ChatFont')
	
	self.txtpanel.Paint = function(self,w,h)
	    surface.SetDrawColor(Color(10,10,10,150))
	    surface.DrawOutlinedRect(0, 0, w, h)

	    surface.SetDrawColor(Color(70,70,70,150))
		surface.DrawRect(1, 1, w - 2, h - 2)

		self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
	end


	self.bpnl = vgui.Create('DPanel', self)
	self.bpnl:Dock(BOTTOM)
	self.bpnl.Paint = function(self,w,h)
		STS.settings:drawRectOutlined(0,0,w,h,Color(10,10,10,150))
	end

	self.ABtn = vgui.Create('DButton', self.bpnl)
	self.ABtn:SetPos(1,self:GetTall()-1)
	self.ABtn:Dock(LEFT)
	self.ABtn:SetText("")

	timer.Simple(0, function()
		self.ABtn:SetWide(self:GetWide()/2-7)
		self.ABtn:DockMargin(1,1,1,1)
	end)

	self.ABtn.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0, 255, 0,150))
		draw.SimpleText(STS.Language[STS.Config.language]['accept_ticket'], "GModToolHelp", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end	

	self.ABtn.DoClick = function() surface.PlaySound('ui/buttonclick.wav') net.Start('open_ticket') net.WriteEntity(self.owner) net.SendToServer() for _,v in pairs(tickets) do v:Remove() end self:Close() end


	self.SBtn = vgui.Create('DButton', self.bpnl)
	self.SBtn:SetPos(1,self:GetTall()-1)
	self.SBtn:Dock(RIGHT)
	self.SBtn:SetText("")

	self.SBtn.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(255, 0, 0,150))
		draw.SimpleText(STS.Language[STS.Config.language]['skit_ticket'], "GModToolHelp", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	timer.Simple(0, function()
		self.SBtn:SetWide(self:GetWide()/2-7)
		self.SBtn:DockMargin(1,1,1,1)
	end)

	self.SBtn.DoClick = function() surface.PlaySound('ui/buttonrollover.wav') self:Close() end
 
end

// Set Ticket description
function PANEL:SetTicketText(txt)
	self.txtpanel:SetText(txt)
end

// Set Ticket title
function PANEL:SetTicketOwner(ply)
	self.owner = ply
end

function PANEL:Think()
	if !IsValid(self.owner) then 
		self:Remove()
	end
	if self.owner:GetNWEntity('admin_ticket') != NULL then self:Remove() end
end

function PANEL:Paint(w,h)
	STS.settings:drawBlurPanelOutlined(self, Color(10,10,10, 100), 2, 5)
	STS.settings:drawRectOutlined(0,0,w,30,Color(10,10,10,150))

	draw.RoundedBox(0, 0, 0, w,5,Color(2, 185, 217,50))
	draw.RoundedBox(0, 0, 0, w*((self.time-CurTime())/STS.Config.noticetime),5,Color(2, 185, 217))

	draw.SimpleText(STS.Language[STS.Config.language]['ticket_title']..self.owner:Nick(), 'GModToolHelp', 1, 7, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register('ticket_notice', PANEL, 'DFrame')