-------------------------------------------------------------------------------------
-- function: asynchronously execute function with a callback function
-- Author: 50362
-------------------------------------------------------------------------------------
local base = _G
local coroutine = require("coroutine")
local table = require("table")
local print = print
local utils = require("utils")

utils.LAsyncTask = {}
local _M = utils.LAsyncTask

-------------------------------------------------------------------------------------
-- Properties
-------------------------------------------------------------------------------------
local __DEBUG = utils.__DEBUG

_M.funcsPool = {}
_M.funcArgsPool = {}
_M.callbacksPool = {}

-------------------------------------------------------------------------------------
-- Private Methods
-------------------------------------------------------------------------------------
-- 
local function executor()
	return coroutine.create(function(func, funcArgs)
		if __DEBUG then
			print("executor: func = "..tostring(func))
			print("executor: funcArgs = "..tostring(funcArgs))
			print("executor: funcArgs[1] = "..tostring(funcArgs[1]))
			print("executor: funcArgs[2] = "..tostring(funcArgs[2]))
			if utils.LUA_51 then
				print("executor: funcArgs Count = "..tostring(base.select('#', base.unpack(funcArgs))))
			else
				print("executor: funcArgs Count = "..tostring(base.select('#', table.unpack(funcArgs))))
			end
		end

		if __DEBUG then
			local co = coroutine.running()
			print("executor Status: "..coroutine.status(co))
		end
		
		local results
		if utils.LUA_51 then
			results = {base.pcall(func, base.unpack(funcArgs))}
			
		else
			results = {base.pcall(func, table.unpack(funcArgs))}
		end

		
		if func then
			if results then
				local status = results[1]
				table.remove(results, 1)
				if __DEBUG then
					print("executor: function executed result = "..table.concat(results, ";"))
				end
				if utils.LUA_51 then
					coroutine.yield(base.unpack(results))
				else
					coroutine.yield(table.unpack(results))
				end
			else
				coroutine.yield(nil, "function executed failed.")
			end
		else
			if __DEBUG then
				print("executor: end")
			end
			coroutine.yield(nil, "function is a nil value")
		end
	end)
end

local function consumer(co, callbackFunc, func, funcArgs)
	if __DEBUG then
		print("consumer: entering")
		print("consumer: func = "..tostring(func))
		print("consumer: funcArgs = "..table.concat(funcArgs, ";"))
	end

	local retVals = {coroutine.resume(co, func, funcArgs)}
	if retVals[1] == true then -- first argument is execution status
		table.remove(retVals, 1)
		if __DEBUG then
			print("val-consumer: "..table.concat(retVals, ","))
		end
		if callbackFunc then -- has callback function
			local ret, errMsg
			if utils.LUA_51 then
				ret, errMsg = base.pcall(callbackFunc, base.unpack(retVals))
				
			else
				ret, errMsg = base.pcall(callbackFunc, table.unpack(retVals))
			end

			if ret then
				return table.unpack(retVals)
			else
				return nil, errMsg
			end
		else -- do not have callback function
			if utils.LUA_51 then
				return base.unpack(retVals)
			else
				return table.unpack(retVals)
			end
		end
	else -- function executed failed
		table.remove(retVals, 1)

		if callbackFunc then -- has callback function
			if utils.LUA_51 then
				ret, errMsg = base.pcall(callbackFunc, base.unpack(retVals))
				
			else
				ret, errMsg = base.pcall(callbackFunc, table.unpack(retVals))
			end
			if ret then
				if utils.LUA_51 then
					return base.unpack(retVals)
				else
					return table.unpack(retVals)
				end
			else
				return nil, errMsg
			end
		else -- do not have callback function
			if utils.LUA_51 then
				return base.unpack(retVals)
			else
				return table.unpack(retVals)
			end
		end
	end
end

local function doExecution()
	while true do
		local func = table.remove(_M.funcsPool, 1)
		local funcArgs = table.remove(_M.funcArgsPool, 1)
		local callbackFunc = table.remove(_M.callbacksPool, 1)

		if __DEBUG then
			print("func: "..tostring(func))
			print("funcArgs: "..tostring(funcArgs))
			print("callbackFunc: "..tostring(callbackFunc))
		end

		if not func then
			if __DEBUG then
				print("terminated")
			end
			break
		else
			local co = executor() -- 每次从池子中捞出一个函数,都需要创建一个新协程对象，这是为了便于将函数和函数参数传到executor中去
			if __DEBUG then
				print("co: "..tostring(co))
			end
			if callbackFunc then
				if __DEBUG then
					print("entering consumer with callbackFunc: "..tostring(co))
				end
				
				return consumer(co, callbackFunc, func, funcArgs)	
			else
				if __DEBUG then
					print("entering consumer without callbackFunc: "..tostring(co))
				end
				return consumer(co, nil, func, funcArgs)	
			end
		end
	end
end


-------------------------------------------------------------------------------------
-- Public Methods
-------------------------------------------------------------------------------------
function _M.create(func, ...)
	local argsTb = {...}
	base.assert(type(func) == "function") -- main function
	
	if (type(base.select(#argsTb, ...)) == "function") then
		local callbackFunc = table.remove(argsTb, #argsTb)
		table.insert(_M.callbacksPool, callbackFunc)
	else
		--table.insert(_M.callbacksPool, nil)
	end

	table.insert(_M.funcsPool, func)
	local funcArgs = argsTb
	table.insert(_M.funcArgsPool, funcArgs)
	if __DEBUG then
		print("@func(create)")
	end
end

-- @deprecated
function _M.addCallback(callbackFunc)
	table.insert(_M.callbacksPool, callbackFunc)
	if __DEBUG then
		print("@func(addCallback)")
	end
end

function _M.execute()
	return doExecution()
end

return _M
