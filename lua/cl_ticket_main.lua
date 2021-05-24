STS.settings = {}

local blur = Material('pp/blurscreen')

// Draw outlined blur panel
function STS.settings:drawBlurPanelOutlined(panel, color, layers, density)
    local x, y = panel:LocalToScreen(0, 0)
    local w, h = panel:GetWide(), panel:GetTall()
	local x2, y2 = panel:GetPos()

    surface.SetDrawColor(Color(255,255,255))
    surface.SetMaterial(Material('pp/blurscreen'))

    for i = 1, layers do
        blur:SetFloat('$blur', (i / layers) * density)
		blur:Recompute()

		render.UpdateScreenEffectTexture()

        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end

    surface.SetDrawColor(color)
	surface.DrawRect(x2 - (x - 1), y2 - (y - 1), w - 2, h - 2)

    surface.SetDrawColor(Color(20, 20, 20, 210))
    surface.DrawOutlinedRect(x2 - x, y2 - y, w, h)
end

// Draw outlined blur panel
function STS.settings:drawRectOutlined(xpos, ypos, width, height, color)
	surface.SetDrawColor(color)
	surface.DrawRect(xpos + 1, ypos + 1, width - 2, height - 2)

	surface.SetDrawColor(Color(20, 20, 20, 210))
	surface.DrawOutlinedRect(xpos, ypos, width, height)
end

notifcount = 0

// Notification
function STS.Notify(text, color, length)
	local txtlength = text

	for i=1, #txtlength do
		txtlength = string.SetChar(txtlength, i, 'a')
	end

	txtlength = surface.GetTextSize(txtlength)

	local NPanel = vgui.Create('DFrame')
	NPanel:SetSize(300+txtlength, 50)
	NPanel:SetPos(ScrW()/2-150-(txtlength/2), 10)
	NPanel:ShowCloseButton(false)
	NPanel:SetTitle('')
	NPanel:SetDraggable(false)

	LocalPlayer():EmitSound(Sound('buttons/blip1.wav'), 75, 150, 0.25)

	NPanel:MoveTo( ScrW()/2-150-(txtlength/2), (NPanel:GetTall()+10)*notifcount, 1, 0, -1, function() end)

	NPanel.Paint = function(self,w,h)
		STS.settings:drawRectOutlined(0,0,w,h,Color(0,0,0,150))
		STS.settings:drawBlurPanelOutlined(self,Color(0,0,0,150), 3, 8)
		draw.SimpleText(text, "GModToolHelp", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	timer.Simple(length, function()
		NPanel:MoveTo( ScrW()+1000, 30, 1, 0, -1, function()
			NPanel:Remove()
			notifcount = notifcount - 1
		end)
	end)
	notifcount = notifcount + 1
end

net.Receive('send_notify', function()
	local text = net.ReadString()
	local color = net.ReadColor()
	local length = net.ReadInt(32)

	STS.Notify(text,color,length)
end)

// Currently notice count
local noticeCount = 0
local NAmount = 1

tickets = {}

local y = 10

// Emtpy slots
local slots = {}

// slot creation
for i=0, 50 do
	slots[i] = false
end

// Open notice frame
function CreateNotice(pl,text)
	if !LocalPlayer():inAdminMode() then return end
	if !STS.Config.admincanseeyourself and (LocalPlayer() == pl) then return end
	LocalPlayer():EmitSound(Sound('buttons/blip1.wav'), 75, 150, 0.25)
	
	// Find empty slot
	for k, empty in pairs(slots) do
		if (empty != nil) and (empty == false) then
			noticeCount = k
			break
		end 
	end

	y = 10 + 155*noticeCount

	local curpnl = NAmount

	tickets[NAmount] = vgui.Create('ticket_notice')
	tickets[NAmount]:SetSize(270,150)
	tickets[NAmount]:SetTicketText(text)
	tickets[NAmount]:SetTicketOwner(pl)
	tickets[NAmount]:SetTitle('')
	tickets[NAmount]:SetPos(ScrW()+500, y)
	tickets[NAmount]:SetDraggable(false)

	// frame animation
	tickets[NAmount]:MoveTo(ScrW()-275,y, 1, 0, -1, function()
		timer.Simple(STS.Config.noticetime-1, function()
			if !IsValid(tickets[curpnl]) then return end
			tickets[curpnl]:MoveTo(ScrW()+500, y, 0.2, 0, -1, function()
				local pos = tickets[curpnl].pos

				tickets[curpnl]:Remove()

				slots[pos] = false
			end)
		end)
	end)

	tickets[NAmount].pos = noticeCount
	slots[noticeCount] = true

	local pos = tickets[NAmount].pos

	tickets[NAmount].OnRemove = function()
		slots[pos] = false
		
		timer.Simple(1, function()
			if (LocalPlayer():GetNWEntity('accepted_ticket') == NULL) or !LocalPlayer():GetNWEntity('accepted_ticket'):IsPlayer() then 
				
				net.Start('skip_ticket') net.SendToServer()
			end
		end)

		noticeCount = noticeCount - 1									
	end	


	noticeCount = noticeCount + 1
	NAmount = NAmount + 1
end


net.Receive('create_ticket', function()
	local text = net.ReadString()
	local ply = net.ReadEntity()

	CreateNotice(ply, text)
end)

// Open accepted support ticket
function OpenTicket(ply, target)
	if !ply:inAdminMode() then return end
	if STS.Config.admincanseeyourself and (LocalPlayer() == pl) then return end

	local frame = vgui.Create('accepted_ticket')
	frame:SetSize(650, 140)
	frame:SetPos(ScrW()/2-325, 10)
	frame:SetTitle('')

	frame:SetPly(ply)
	frame:SetTarget(target)

	timer.Simple(STS.Config.tickettime-1, function()
		if !IsValid(frame) then return end

		net.Start('close_ticket')
			net.WriteEntity(target)
		net.SendToServer()

		frame:Remove()
	end)
end

net.Receive('open_ticket', function()
	OpenTicket(LocalPlayer(), net.ReadEntity())
end)

// Open rate panel
function OpenRatePanel(target)
	local frame = vgui.Create('rate_admin')
	frame:SetSize(400,120)
	frame:Center()
	frame:MakePopup()
	frame:SetTarget(target)
end

net.Receive('close_ticket', function()
	local target = net.ReadEntity()

	if !IsValid(target) then return end

	// Open rate panel
	OpenRatePanel(target)
end)

// Include all vgui elemets
include('vgui_elements/ticket_notice.lua')
include('vgui_elements/accepted_ticket.lua')
include('vgui_elements/rate_admin.lua')
include('vgui_elements/rate_list.lua')

net.Receive('update_tdata', function()
	local tbl = net.ReadTable()
	local ply = net.ReadEntity()

	if !istable(tbl) then return end

	for _, v in pairs(player.GetAll()) do
		if v == ply then v.Tdata = tbl break end
	end
end)