# LAgent
This module solves the problem "Calling module function of low Lua version in High version lua interpreter", currently only support windows

## Usage
 - **directory description**
  1. bin:     This is the directory holding lua interpreters
  2. clibs:   This is the directory holding libs
  3. lua:	    This is the directory holding lua modules

- **global usage**

  when using in global path,
  1. **first of all, config LUA_HOME** environment,usually located on "C:\Program Files (x86)\Lua\{LUA_VERSION}"
  2. **put directories "bin", "clibs", "lua" into LUA_HOME directory**
  3. using it like examples below

- **relative usage**
  when using in relative path,
  1. change "_M.ROOT_PATH" in utils.lua localted in path "lua\"
  2. using it like examples below


  ## Examples
  ``` lua
  -- when using in relative path, should specify package.path first, otherwise not
  -- package.path = "D:/demo/lua/?.lua;;"

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
			password = '123456',
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
			password = '123456',
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

  ```

