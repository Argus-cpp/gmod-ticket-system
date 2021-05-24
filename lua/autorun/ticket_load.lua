if SERVER then
	AddCSLuaFile('ticket_config.lua')
	AddCSLuaFile('sh_ticket_functions.lua')
	AddCSLuaFile('cl_ticket_main.lua')
	AddCSLuaFile('vgui_elements/ticket_notice.lua')
	AddCSLuaFile('vgui_elements/accepted_ticket.lua')
	AddCSLuaFile('vgui_elements/rate_admin.lua')
	AddCSLuaFile('vgui_elements/rate_list.lua')

	include('ticket_config.lua')
	include('sh_ticket_functions.lua')
	include('mysql_module.lua')
	include('sv_ticket_main.lua')
else
	include('ticket_config.lua')
	include('cl_ticket_main.lua')
	include('sh_ticket_functions.lua')
end

// Add materials file to FastDL
if SERVER then
	local res_files = {
		'materials/sts/stars/0.png',
		'materials/sts/stars/1.png',
		'materials/sts/stars/2.png',
		'materials/sts/stars/3.png',
		'materials/sts/stars/4.png',
		'materials/sts/stars/5.png',
		'materials/sts/stars/6.png',
		'materials/sts/stars/7.png',
		'materials/sts/stars/8.png',
		'materials/sts/stars/9.png',
		'materials/sts/stars/10.png',
		'materials/sts/stars/star.png'
	}

	for _, material in pairs(res_files) do
		resource.AddFile(material)
	end
	MsgC(Color(0,255,0), "[STS] All FastDL files has been added!\n")

	local version = 1.0
	// Check addon verswion
	timer.Simple(1, function()
		http.Fetch( "https://pastebin.com/raw/fzaFywZx",
			function( body, len, headers, code )
				if version != tonumber(body) then 
					MsgC(Color(255,0,0), "[STS] You need update you'r addon!\n[STS] Check last version of addon on gmodstore.com for update!\n")
				else
					MsgC(Color(0,255,0), "[STS] This addon have the latest version "..body.."!\n")
				end
			end
		)
	end)

end