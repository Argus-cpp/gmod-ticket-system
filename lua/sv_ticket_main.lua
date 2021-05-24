util.AddNetworkString('ticket_data')
util.AddNetworkString('skip_ticket')
util.AddNetworkString('open_ticket')
util.AddNetworkString('create_ticket')
util.AddNetworkString('send_notify')
util.AddNetworkString('close_ticket')
util.AddNetworkString('ticket_button')
util.AddNetworkString('rate_admin')
util.AddNetworkString('update_tdata')


// Skip ticket function
net.Receive('skip_ticket', function(_, ply)
	if !table.HasValue(STS.root.managers, ply:GetUserGroup()) then return end

	ply:addSkippedTicket(1)
end)

// Open support ticket
function OpenSupportTicket(ply, target)

	if target:GetNWEntity('admin_ticket') != NULL then ply:sendNotify(STS.Language[STS.Config.language]['already_accepted'], Color(255,0,0), 3) return end

	ply:SetNWEntity('accepted_ticket', target)
	target:SetNWEntity('admin_ticket', ply)

	target.lastpos = target:GetPos()

	target:sendNotify(STS.Language[STS.Config.language]['accepted_ticket'], Color(0,255,0), 5)

	local id = ply:AccountID()

	timer.Create("check_ticket"..id, 1, 0, function()
		if !IsValid(target) and IsValid(ply) then ply:SetNWEntity('accepted_ticket', NULL) timer.Remove('check_ticket'..id) end
		if !IsValid(ply) and IsValid(target) then target:SetNWEntity('admin_ticket', NULL) timer.Remove('check_ticket'..id) end

		if !IsValid(ply) and !IsValid(target) then timer.Remove('check_ticket'..id) end
	end)

	ply:addAcceptedTicket(1)

	net.Start('open_ticket')
		net.WriteEntity(target)
	net.Send(ply)
end

net.Receive('open_ticket', function(_, ply)
	local target = net.ReadEntity()

	if !IsValid(ply) or !IsValid(target) then return end

	// Open ticket
	OpenSupportTicket(ply, target)
end)

// Close ticket function
function CloseSupportTicket(ply, target)
	ply:SetNWEntity('accepted_ticket', NULL)
	target:SetNWEntity('admin_ticket', NULL)

	// If player is frozen, then unfreeze him
	if target:IsFrozen() then target:Freeze(false) end

	target.lasthelp = ply


	timer.Simple(60, function()
		if !IsValid(target) then return end
		target.lasthelp = nil
	end)

	if timer.Exists("check_ticket"..ply:AccountID()) then timer.Remove('check_ticket'..ply:AccountID()) end

	ply:sendNotify(STS.Language[STS.Config.language]['ticket_closed'], Color(0,255,0), 5)
	target:sendNotify(STS.Language[STS.Config.language]['ticket_closed'], Color(0,255,0), 5)

	// Send rate frame
	net.Start('close_ticket')
		net.WriteEntity(ply)
	net.Send(target)
end

net.Receive('close_ticket', function(_,pl)
	local target = net.ReadEntity()
	if (target == nil) or !target:IsPlayer() then return end

	// Close ticket
	CloseSupportTicket(pl, target)
end)


// Rate admin function
net.Receive('rate_admin', function(_,pl)
	local target = net.ReadEntity()
	local score = net.ReadInt(32)

	if pl.lasthelp != target then return end

	pl.lasthelp = nil

	target:addTicketScore(score)

	pl:sendNotify(STS.Language[STS.Config.language]['thanks_for_rate'], Color(255,255,255), 5)
end)


// Chat commands
hook.Add('PlayerSay', 'open_support_ticket', function(ply, txt)
	local char = string.sub(txt, 1, 1)

	if table.HasValue(STS.Config.chars, char) then
		if ply:GetNWEntity('admin_ticket'):IsPlayer() or (ply:GetNWEntity('admin_ticket') != NULL) or ((ply.lastsupport != nil) and (ply.lastsupport >= CurTime())) then ply:sendNotify(STS.Language[STS.Config.language]['support_cooldown']..math.Round(ply.lastsupport - CurTime()).." sec.", Color(255,255,255), 3) return end

		if !STS.Config.admincancreate and table.HasValue(STS.root.managers, ply:GetUserGroup()) then ply:sendNotify(STS.Language[STS.Config.language]['admin_cant'], Color(255,0,0), 5) return '' end

		local txt = string.Replace(txt, "@", "")

		local canCreate = hook.Run('canCreateTicket', ply, txt)
		if (canCreate != nil) and !canCreate then return end

		net.Start('create_ticket')
			net.WriteString(txt)
			net.WriteEntity(ply)
		net.Send(STS:getAdmins())

		ply.lastsupport = CurTime()+STS.Config.cooldown

		ply:sendNotify(STS.Language[STS.Config.language]['ticket_created'], Color(0,255,0), 5)

		return ''
	end

	local args = string.Explode(' ', txt)

	if table.HasValue(STS.Config.menucommand, args[1]) then
		if !table.HasValue(STS.root.managers, ply:GetUserGroup()) then return '' end

		// Open adminrate frame
		ply:ConCommand('adminrate')

		return ''
	end

	if table.HasValue(STS.Config.adminmode, args[1]) then
		if !table.HasValue(STS.root.managers, ply:GetUserGroup()) then return '' end

		if ply:inAdminMode() == false then

			ply:sendNotify(STS.Language[STS.Config.language]['adminmode_on'], Color(0,255,0), 5)
			ply:SetNWBool('adminmode', true)

		else

			ply:sendNotify(STS.Language[STS.Config.language]['adminmode_off'], Color(0,255,0), 5)
			ply:SetNWBool('adminmode', false)

		end
	end
end)


// Load player data
hook.Add('PlayerInitialSpawn', 'ticket_load_ply_data', function(ply)

	local folder = "ticket_system/"

	if ply:IsPlayer() and table.HasValue(STS.root.managers, ply:GetUserGroup()) then

		timer.Simple(3, function()
			for _, v in pairs(player.GetAll()) do
				if !table.HasValue(STS.root.managers, v:GetUserGroup()) then continue end
				v:updateTicketData()
			end
		end)		

		// Load Ticket Data
		ply:loadTicketData()

		// If player is admin then enable him in ticket system
		if ply:getTicketData()['isadmin'] == 0 then

			ply:getTicketData()['isadmin'] = 1
			ply:updateTicketData()
		end


	elseif ply:IsPlayer() and !table.HasValue(STS.root.managers, ply:GetUserGroup()) and file.Exists(folder.."admin_list/"..ply:SteamID64()..".txt", 'DATA') then

		ply:loadTicketData()


		// If player is not admin then disable him in ticket system
		if ply:getTicketData()['isadmin'] == 1 then

			ply:getTicketData()['isadmin'] = 0
			ply:updateTicketData()
		end

	end

end)	


// Run button functions
net.Receive('ticket_button', function(_, pl)
	local id = net.ReadInt(32)
	local target = net.ReadEntity()

	if !IsValid(target) then return end
	if STS.Config.buttonlist[id] == nil then return end

	// Run function
	STS.Config.buttonlist[id].func(pl, target)
end)