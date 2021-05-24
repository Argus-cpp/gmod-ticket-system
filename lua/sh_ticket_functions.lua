local meta = FindMetaTable('Player')

if SERVER then
	local folder = "ticket_system/"

	function meta:sendNotify(txt, color, length)
		net.Start('send_notify')
			net.WriteString(txt)
			net.WriteColor(color)
			net.WriteInt(length, 32)
		net.Send(self)
	end

	// Get admins on work
	function STS:getAdmins()
		local admintbl = {}

		for _, ply in pairs(player.GetAll()) do
			if table.HasValue(STS.root.managers, ply:GetUserGroup()) and (ply:GetNWEntity('accepted_ticket') == NULL) and ply:inAdminMode() then
				table.insert(admintbl, ply)
			end
		end

		return admintbl or {}
	end

	// Get all administrations on server
	function STS:getAllAdmins()
		local admintbl = {}

		for _, ply in pairs(player.GetAll()) do
			if table.HasValue(STS.root.managers, ply:GetUserGroup()) then
				table.insert(admintbl, ply)
			end
		end

		return admintbl or {}
	end


	// Load Ticket Data Function
	function meta:loadTicketData()
		local Tdata = {
			['steamid'] = tostring(self:SteamID64()),
			['accepted_ticket'] = 0,
			['skipped_ticket'] = 0,
			['isadmin'] = 1,
			['rating'] = {}
		}

		if STS.mysql.EnableMySQL then
			// Load Ticket Data From MySQL
			local q = STS.mysql.db.Database:query([[SELECT * FROM sts_admin_list WHERE steamid = ']]..tostring(self:SteamID64())..[[';]])

			q.onData = function( q, data )
				Tdata = data['data']
			end		

			q:start()			
		else
			if file.IsDir(folder.."admin_list", 'DATA') then
				if file.Exists(folder.."admin_list/"..self:SteamID64()..".txt", 'DATA') then
					
					local FData = file.Read(folder.."admin_list/"..self:SteamID64()..".txt", 'DATA')
					
					FData = util.JSONToTable(FData)

					if (FData == nil) or !istable(FData) then return end

					Tdata = FData

				end
			end
		end

		self.Tdata = Tdata or {}

		// Update ticket data
		self:updateTicketData()

		timer.Simple(3, function()
			// Send ticket data to clients
			net.Start('ticket_data')
				net.WriteEntity(self)
				net.WriteTable(self:getTicketData())
			net.Send(STS:getAllAdmins())
		end)
	end

	// Update Ticket Data
	function meta:updateTicketData()
		
		if STS.mysql.EnableMySQL then
			
			local q = STS.mysql.db.Database:query([[REPLACE INTO sts_admin_list VALUES(']]..tostring(self:SteamID64())..[[', ']]..util.TableToJSON(self:getTicketData())..[[')]])
			q:start()

		else
			
			if !file.IsDir(folder.."admin_list/", 'DATA') then file.CreateDir(folder.."admin_list/", 'DATA') end
			file.Write(folder.."admin_list/"..self:SteamID64()..".txt", util.TableToJSON(self:getTicketData()))
		
		end

		if SERVER then
			net.Start('update_tdata')
				net.WriteTable(self:getTicketData())
				net.WriteEntity(self)
			net.Send(STS:getAllAdmins())
		end

	end
end

// Enable or Disable admin-mode
function meta:inAdminMode()
	return self:GetNWBool('adminmode')
end

// Get Ticket Data
function meta:getTicketData()
	return self.Tdata or {}
end

// Get Rating Table of player
function meta:getRateTable()
	return self:getTicketData()['rating'] or {}
end

// Get accepted ticket count
function meta:getAcceptedTicket()
	return self:getTicketData()['accepted_ticket'] or 0
end

// Get skipped ticket count
function meta:getSkippedTicket()
	return self:getTicketData()['skipped_ticket'] or 0
end

// Get Ticket rating
function meta:getTicketRating()
	local TRate = self:getRateTable()
	local TotalScore = 0

	for _, score in pairs(TRate) do
		TotalScore = TotalScore + score
	end

	if #TRate == 0 then table.insert(TRate, 0) end

	return math.Round(TotalScore/#TRate, 2)
end

// Add ticket score
function meta:addTicketScore(score)
	table.insert(self:getRateTable(), score)

	self:updateTicketData()
end

// Add accepted ticket
function meta:addAcceptedTicket(count)
	self.Tdata['accepted_ticket'] = self.Tdata['accepted_ticket'] + count

	self:updateTicketData()
end

// Add skipped ticket
function meta:addSkippedTicket(count)
	self.Tdata['skipped_ticket'] = self.Tdata['skipped_ticket'] + count

	self:updateTicketData()
end

if CLIENT then
	// Update ticket data on clientside
	net.Receive('ticket_data', function()
		local ply = net.ReadEntity()
		local tbl = net.ReadTable()

		for _, v in pairs(player.GetAll()) do
			if v == ply then v.Tdata = tbl break end
		end
	end)
end