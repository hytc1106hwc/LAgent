# LAgent
这个模块解决了“在高版本的Lua解释器中调用低版本的Lua模块函数”的问题，当前只支持Windows系统
## 使用说明
- **目录说明**
  1. bin目录:     存放Lua多个版本的解释器
  2. clibs目录:   存放dll的目录
  3. lua目录:      存放lua模块的目录

- **全局使用**

  如果要在全局使用
  1. **首先，配置LUA_HOME** 环境变量,通常位于 "C:\Program Files (x86)\Lua\{LUA_VERSION}"
  2. **将目录 "bin", "clibs", "lua" 放到LUA_HOME 目录下**
  3. 参考下面的例子进行使用

- **相对使用**
  ,
  1. 改变 utils.lua脚本中的"_M.ROOT_PATH" 变量路径， 位于 "lua"目录下
  2. 参考下面的例子进行使用


  ## 例子
  ``` lua
  -- 当在相对环境中使用时，应该先指定 package.path
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

