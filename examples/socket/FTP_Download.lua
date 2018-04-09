--------------------------------------------------------------------------------
-- Function	: FTP download demo
-- Author	: ArisHu(50362)
-- Note		: This demo use luasocket ftp, this module can only be run
--		  with Lua interpreter 5.1, so first parameter of lagent.execute
--		  should be 1
--------------------------------------------------------------------------------

local lagent = require("utils.LAgent")

lagent.execute(1, [[
	local ftp = require('socket.ftp')
	local ltn12 = require('ltn12')
]],[[
	ftp.get{
		host = '192.168.3.3', 
		user = 'hwc',
		password = 'hwc123456',
		-- command = 'appe',
		argument = '/smarthome.rar',
		type = 'i',
		sink = ltn12.sink.file(io.open('D:\\demo\\smarthome2.rar', 'wb'))
	}
]])

local res, errMsg = lagent.getResults()
if errMsg then
	print("Download failed: ", tostring(errMsg))
end
print("Download Successfully")

