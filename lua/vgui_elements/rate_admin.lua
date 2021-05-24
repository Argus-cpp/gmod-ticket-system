local PANEL = {}

function PANEL:Init()
	self:SetTitle('')
	self:ShowCloseButton(false)

	local currat = 1

	self.panel = vgui.Create('DPanel', self)
	self.panel:Dock(FILL)
	self.panel:DockMargin(20,10,20,5)
	self.panel.Paint = function(self,w,h)  end

	local strs = {}

	for i=1, 5 do
		strs[i] = vgui.Create('DPanel', self.panel)
		strs[i]:Dock(LEFT)
		strs[i]:DockMargin(8, 1, 0, 1)
		strs[i]:SetWide(60)
		strs[i]:SetTall(60)
		strs[i].Paint = function(self,w,h)
			surface.SetMaterial(Material('sts/stars/star.png'))
			if self:IsHovered() then self:SetCursor('hand') end
			if currat >= i then
				surface.SetDrawColor(255,255,255,255)
			else
				surface.SetDrawColor(100,100,100,255)
			end
			surface.DrawTexturedRect(0,0,w,h)
		end
		strs[i].OnMousePressed = function()
			currat = i
			surface.PlaySound('ui/buttonrollover.wav')
		end
	end

	local BClose = vgui.Create('DButton', self)
	BClose:SetText("")
	BClose:SetSize(24,24)
	
	timer.Simple(0, function()
		BClose:SetPos(self:GetWide()-BClose:GetWide()-10, 2)
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

	local BRate = vgui.Create('DButton', self)
	BRate:Dock(BOTTOM)
	BRate:SetText('')

	BRate.DoClick = function()
		if (currat > 5) or (currat < 1) then return end

		net.Start('rate_admin')
			net.WriteEntity(self.target)
			net.WriteInt(currat,32)
		net.SendToServer()

		surface.PlaySound('ui/buttonclick.wav')

		self:Remove()
	end

	BRate.Paint = function(self,w,h)
		STS.settings:drawRectOutlined(0,0,w,30,Color(10,10,10,150))		

		if self:IsHovered() then
			draw.SimpleText(STS.Language[STS.Config.language]['rate_button'], 'GModToolHelp', w/2, h/2, Color(2, 185, 217), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(STS.Language[STS.Config.language]['rate_button'], 'GModToolHelp', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

function PANEL:SetTarget(ply)
	self.target = ply
end

function PANEL:Paint(w,h)
	STS.settings:drawBlurPanelOutlined(self, Color(10,10,10, 100), 2, 5)
	STS.settings:drawRectOutlined(0,0,w,30,Color(10,10,10,150))

	draw.SimpleText(STS.Language[STS.Config.language]['rate_administration_title'], 'GModToolHelp', 5, 5, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register('rate_admin', PANEL, "DFrame")