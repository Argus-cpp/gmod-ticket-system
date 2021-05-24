STS = STS or {}
STS.Config = {}
STS.root = {}
STS.Language = {}

// MySQL Module
STS.mysql = STS.mysql or {}
STS.mysql.db = {}

// Current language of addon
STS.Config.language = "en"

--[[-------------------------------------------------------------------------
							MySQL config
---------------------------------------------------------------------------]]

STS.mysql.EnableMySQL = false -- Set true to enable MySQL module
STS.mysql.Host = "localhost"
STS.mysql.Username = "root"
STS.mysql.Password = ""
STS.mysql.Database_name = "database_name"
STS.mysql.Database_port = 3306

STS.mysql.reconnect = true -- Enable auto-connect when an error occurs while connecting to the database?

--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]

// Administration/moderation or helper usergroup list
STS.root.managers = {'admin', 'superadmin', 'moderator'}

// Ticket notice time (in sec)
STS.Config.noticetime = 30 

// Accepted ticket time (in sec)
STS.Config.tickettime = 600

// Cooldown for create a new ticket
STS.Config.cooldown = 10 

// Chars for open ticket menu
STS.Config.chars = {"@", "#", "%"}

// Command for open admin rating list (Only for Administration)
STS.Config.menucommand = {"!adminrate", "/adminrate"}

// Enable admin-mode commands
STS.Config.adminmode = {"!adminmode", "/adminmode"}

// Admin can create support ticket?
STS.Config.admincancreate = true

// The administrator can see yourself ticket. (DEBUG FUNCTION, recommended to disable this)
STS.Config.admincanseeyourself = false

// Command list
STS.Config.buttonlist = {
	[1] = {
		icon = "icon16/script_edit.png",
		text = "Copy SteamID",
		func = function(ply, target)
			if CLIENT then
				SetClipboardText(target:SteamID())
			end
			if SERVER then
				ply:sendNotify("SteamID has been copied in clipboard!", Color(0,255,0), 3)
			end
		end
	},
	[2] = {
		icon = "icon16/arrow_redo.png",
		text = "Bring",
		func = function(ply, target)
			if SERVER then
				target:SetPos(ply:GetPos())
				ply:sendNotify(target:Nick().." has been teleported to you.", Color(0,255,0), 3)
			end
		end
	},
	[3] = {
		icon = "icon16/arrow_up.png",
		text = "Goto",
		func = function(ply, target)
			if SERVER then
				ply:SetPos(target:GetPos())
				ply:sendNotify("You teleported to "..target:Nick(), Color(0,255,0), 3)
			end
		end
	},
	[4] = {
		icon = "icon16/arrow_down.png",
		text = "Teleport",
		func = function(ply, target)
			if SERVER then
				target:SetPos(ply:EyePos())
				ply:sendNotify(target:Nick().." teleported on you'r eye trace.", Color(0,255,0), 3)
			end
		end
	},
	[5] = {
		icon = "icon16/bug.png",
		text = "Freeze",
		func = function(ply, target)
			if SERVER then
				target:Freeze(true)
				ply:sendNotify(target:Nick().." will be freezed!", Color(0,255,0), 3)
			end
		end
	},
	[6] = {
		icon = "icon16/bug_delete.png",
		text = "UnFreeze",
		func = function(ply, target)
			if SERVER then
				target:Freeze(false)
				ply:sendNotify(target:Nick().." will be unfreezed!", Color(0,255,0), 3)
			end
		end
	},
	[7] = {
		icon = "icon16/arrow_rotate_clockwise.png",
		text = "Return",
		func = function(ply, target)
			if SERVER then
				target:SetPos(target.lastpos)
				ply:sendNotify(target:Nick().." returned to origian position!", Color(0,255,0), 3)
			end
		end
	},
}

// Language
STS.Language['en'] = {
	['ticket_title'] = "Ticket from: ",
	['skit_ticket'] = "Skip",
	['accept_ticket'] = "Accept",
	['support_cooldown'] = "Wait ",
	['close_ticket'] = "Close support ticket",
	['ticket_closed'] = "Support ticket has been closed!",
	['ticket_by'] = "Ticket by ",
	['rate_button'] = "Rate Administration",
	['rate_administration_title'] = "Please, rate work of administartion",
	['thanks_for_rate'] = "Thanks for your rating!",
	['steamid_copied'] = "SteamID has been copied in clipboard!",
	['already_accepted'] = "This ticket already accepted!",
	['menu_title'] = "Rating of Administration",
	['ticket_created'] = "You'r ticked has been created! Please wait!",
	['accepted_ticket'] = "You'r ticket has been accepted!",
	['adminmode_on'] = "Admin-mode enabled!",
	['adminmode_off'] = "Admin-mode disabled!",
	['admin_cant'] = "Administration can't create support tickets!",
}