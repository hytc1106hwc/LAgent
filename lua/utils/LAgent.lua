---------------------------------------------------------------------------------
-- Function	: Agent for executing function in specified lua interpreter
--		  and returning desired results
-- Author	: ArisHu(50362)
---------------------------------------------------------------------------------
local base = _G
--require("libutils")
local string = require("string")
local table = require("table")
local print = print
local debug = require("debug")
local utils = require("utils")
local lfile = require("utils.LFile")
local lasync = require("utils.LAsyncTask")

utils.LAgent = {}
local _M = utils.LAgent

--------------------------------------------------------------------------------
-- Program constants
--------------------------------------------------------------------------------
local ROOT_PATH = utils.ROOT_PATH
local INTERPRETER_LUA_51_PATH = "\""..ROOT_PATH.."bin\\lua51\\lua51.exe".."\""
local INTERPRETER_LUA_52_PATH = "\""..ROOT_PATH.."bin\\lua52\\lua52.exe".."\""
local INTERPRETER_LUA_53_PATH = "\""..ROOT_PATH.."bin\\lua53\\lua53.exe".."\""

local LUA_EXE_TYPE = {
	INTERPRETER_LUA_51_PATH,
	INTERPRETER_LUA_52_PATH,
	INTERPRETER_LUA_53_PATH
}
local FILE_NEW_LINE = lfile.FILE_NEW_LINE

local __DEBUG = utils.__DEBUG

-- default use lua53.exe
_M.INTERPRETER_TYPE = 3

--------------------------------------------------------------------------------
-- Internal methods
--------------------------------------------------------------------------------

-- global lock object
local lck = {}

-- try get lock
function lck.tryLock()
	if (base.fileLock == nil or base.fileLock == false) then
		base.fileLock = true
		return true, nil
	end
	return false, "Wait! we are operating for you"
end

-- release lock
function lck.release()
	base.fileLock = false
	return true, nil
end

-- use interpreter to execute the temporary result
-- must use /WAIT option for waiting new process terminated, 
-- otherwise will throw error
local function executeCmd(prog)
    --local pipe
    local command
    if __DEBUG then
	command = "start /WAIT cmd /c "..prog
	--pipe = utils.try(io.popen, command)
	--pipe:close()
	local handle = io.open(lfile.getBatFilePath(), "w+")
	handle:write(command)
	handle:close()
	os.execute(command)
    else
	command = "start /MIN /WAIT cmd /Q /c "..prog
	--pipe = utils.try(io.popen, command)
	--pipe:close()
	os.execute(command)
    end
    
    return true
end

--------------------------------------------------------------------------------
-- Public LAgent API
--------------------------------------------------------------------------------
--@deprecated
local function extractResultFromFile()
	local ret, errMsg = utils.extractResultFromFile(lfile.getResultFilePath())
	return ret, errMsg
end
_M.extractResultFromFile = extractResultFromFile


-- get function call in string format
function _M.getStrFuncCall(...)
	local argsArr = {...}
	local funcName = argsArr[1]
	table.remove(argsArr, 1)
	-- if utils.LUA_51 then
	local strArgs = ""
	for i, v in ipairs(argsArr) do
		strArgs = strArgs..utils.serialize(v)
	end
	return funcName..""..strArgs..""
end


-- get execution results
function _M.getResults()
	-- print("LAgent: LUA VERSION = ", base._VERSION)
	if utils.LUA_51 then
		return base.unpack(lfile.getResults())
	else
		return table.unpack(lfile.getResults())
	end
end

-- use interpreter to execute command
-- @interpreterType	iterpreter type, default using lua53.exe
-- @header		modules required for executing function 'funcCall'
-- @funcCall		the function to be executed
-- resultCount		result count
function _M.execute(interpreterType, header, funcCall, resultCount)
	if base.type(interpreterType) ~= "number" then
		return nil, "first parameter should be a integer"
	end

	local tp = base.tonumber(interpreterType)
	if  tp < 1 or tp > 3 then
		return nil, "first parameter should between 1 or 2 or 3"
	end

	local ret, errMsg
	
	-- delete temp files
	lfile.delete()

	-- result count of function call
	local retCount = 2
	if resultCount == nil then
		retCount = 2
	else
		retCount = base.tonumber(resultCount)
	end

	local INTERPRETER_PATH = utils.normalize_in_windows(LUA_EXE_TYPE[interpreterType])
	--print("INTERPRETER_PATH = ", INTERPRETER_PATH)
	ret, errMsg = utils.try(lck.tryLock)
	if ret then
		ret, errMsg = utils.try(lfile.create)
		ret, errMsg = utils.try(lfile.appendHeader, header)
		
		if __DEBUG then
			print("LAgent.execute: funcCall = ", funcCall)
		end

		ret, errMsg = utils.try(lfile.appendFuncCall, funcCall, retCount)
		
		if __DEBUG then
			ret, errMsg = utils.try(executeCmd, INTERPRETER_PATH.." -i "..lfile.getTmpFilePath())
		else
			ret, errMsg = utils.try(executeCmd, INTERPRETER_PATH.." "..lfile.getTmpFilePath())
		end	
	end
	utils.try(lck.release)
	return ret,errMsg
end

return _M