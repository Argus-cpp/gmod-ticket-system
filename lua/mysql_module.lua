if( STS.mysql and STS.mysql.EnableMySQL == true )then
	require( 'mysqloo' )
else
	MsgC(Color(255,255,0), "[STS] Database is disabled! You can enalbe this in config file ;)\n")
	return
end

function STS.mysql.db:connect (server, port, username, password, databaseName, callback)

	if( !STS.mysql or !STS.mysql.EnableMySQL )then return end

	if( STS.mysql.db:IsConnected() )then
		STS.mysql.db.Database = nil
		STS.mysql.db:connect()
	end
	
	STS.mysql.db.Database = mysqloo.connect (server, username, password, databaseName, port)
	
	function STS.mysql.db.Database:onConnected()
		MsgC(Color(0,255,0), "[STS] Connecting to DATABASE is successfully! "..STS.mysql.Host.."@"..STS.mysql.Database_name.."\n")
	end
	
	function STS.mysql.db.Database:onConnectionFailed (error)
		MsgC(Color(255,0,0), error)
	end

	STS.mysql.db.Database:setAutoReconnect( STS.mysql.reconnect )

	STS.mysql.db.Database:connect()
end

function STS.mysql.db:IsConnected ()
	return STS.mysql.db.Database ~= nil
end

STS.mysql.db:connect( STS.mysql.Host, STS.mysql.Database_port, STS.mysql.Username, STS.mysql.Password, STS.mysql.Database_name )

if !STS.mysql.EnableMySQL then return end


-- Create admin list table
local q = STS.mysql.db.Database:query([[
    CREATE TABLE IF NOT EXISTS sts_admin_list(
        steamid VARCHAR(80) PRIMARY KEY,
        data JSON
    );
]])

q:start()