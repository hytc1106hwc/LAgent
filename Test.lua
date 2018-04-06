
local lagent = require("utils.LAgent")

local testType = 2

if testType == 1 then

	lagent.execute(1,[[
		local http = require("socket.http")
		local mime = require("mime")
	]],
	[[
		http.request("http://www.baidu.com")
	]], 4)

	local b, c, h, s = lagent.getResults()
	print("res1=", b)
	print("res2=", c)
	print("res3=", h)
	print("res4=", s)
elseif testType == 2 then
	lagent.execute(1,[[
		local http = require("socket.http")
		local mime = require("mime")
	]],
	[[
		http.request {
		  method = "HEAD",
		  url = "http://www.baidu.com"
		}
	]], 4)

	local b, c, h, s = lagent.getResults()
	print("res1=", b)
	print("res2=", c)
	print("res3=", h)
	print("res4=", s)
elseif testType == 3 then -- testing ftp upload
	lagent.execute(1, [[
		local ftp = require('socket.ftp')
		local ltn12 = require('ltn12')
	]],[[
		ftp.put{
			host = '192.168.3.24', 
			user = 'hwc',
			password = 'hwc123456',
			-- command = 'appe',
			argument = '/smarthome.rar',
			type = 'i',
			source = ltn12.source.file(io.open('D:\\demo\\smarthome.rar', 'rb'))
		}
	]])

	local res, errMsg = lagent.getResults()
	print("IsSuccess: ", res)
	print("errMsg: ", errMsg)
elseif testType == 4 then -- testing ftp download
	lagent.execute(1, [[
		local ftp = require('socket.ftp')
		local ltn12 = require('ltn12')
	]],[[
		ftp.get{
			host = '192.168.3.24', 
			user = 'hwc',
			password = 'hwc123456',
			-- command = 'appe',
			argument = '/smarthome.rar',
			type = 'i',
			sink = ltn12.sink.file(io.open('D:\\demo\\smarthome2.rar', 'wb'))
		}
	]])

	local res, errMsg = lagent.getResults()
	print("IsSuccess: ", res)
	print("errMsg: ", errMsg)

else
	local myStr = "Hello World"
	local funcStr = "base64.encode("..myStr..")"
	lagent.execute(1,[[
		local base64 = require("base64")
	]], funcStr)

	local encodedStr = lagent.getResults()

	print(encodedStr)
end



