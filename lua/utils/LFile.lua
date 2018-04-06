---------------------------------------------------------------------------------
-- Function	: Module for creating temporary script file
--                and setting or getting results to or from result file
-- Author	: Aris Hu(50362)
---------------------------------------------------------------------------------
local base = _G
local string = require("string")
local table = require("table")
local os = require("os")
local io = require("io")
local utils = require("utils")
local print = print

utils.LFile = {}
local _M = utils.LFile

---------------------------------------------------------------------------
-- Program constants
---------------------------------------------------------------------------
local ROOT_PATH = utils.ROOT_PATH
local C_PATH = utils.C_PATH
local LUA_PATH = utils.LUA_PATH
local TEMP_PATH = utils.TEMP_PATH
local TEMP_FILE_PATH = TEMP_PATH.."temp.lua"
local TEMP_BAT_FILE_PATH = TEMP_PATH.."executeCommand.bat"
local TEMP_RESULT_FILE_PATH = TEMP_PATH.."result.lua"
local FILE_NEW_LINE = "\n"
local __DEBUG = utils.__DEBUG
---------------------------------------------------------------------------
-- Methods for Local Use
---------------------------------------------------------------------------
-- whether or not param is a string
local function isParameterValid(param)
	if (base.type(param) == "string") then
		return true
	end
	return false
end

---------------------------------------------------------------------------
-- Public LFile API
---------------------------------------------------------------------------
-- @deprecated
local function createBatFile(content)
	local handle = io.open(TEMP_BAT_FILE_PATH, "w+")
	handle:write(FILE_NEW_LINE..content)
	handle:close()
	return true
end
_M.cteateBatFile = createBatFile

local function getBatFilePath()
	return TEMP_BAT_FILE_PATH
end
_M.getBatFilePath = getBatFilePath


-- get result file Path
local function getResultFilePath()
	return TEMP_RESULT_FILE_PATH
end
_M.getResultFilePath = getResultFilePath


-- create temporary lua script
local function createTmpScript()
	local dOut = io.output()
	local handle = utils.try(io.open, TEMP_FILE_PATH, "w+")
	io.output(handle)
	utils.try(io.write, FILE_NEW_LINE.."package.cpath = \""..utils.single_slash_to_backslash(C_PATH).."?.dll\"")
	utils.try(io.write, FILE_NEW_LINE.."package.path = \""..utils.single_slash_to_backslash(LUA_PATH).."?.lua;;\"")
	utils.try(io.write, FILE_NEW_LINE)
	utils.try(io.flush)
	utils.try(io.close, handle)
	io.output(dOut)
	return true, nil
end

_M.create = createTmpScript


-- get temporary script file path
local function getTempScriptFilePath()
	return utils.normalize_in_windows(TEMP_FILE_PATH)
end
_M.getTmpFilePath = getTempScriptFilePath

-- append required modules to temporary lua script file
local function appendHeader(header)
	if isParameterValid(header) == false then
		return false, "must be a string in appendStringToTempScript method"
	end
	local dOut = io.output()
	local handle = utils.try(io.open, TEMP_FILE_PATH, "a+")
	io.output(handle)
	utils.try(io.write, FILE_NEW_LINE.."local lfile = require('utils.LFile')")
	utils.try(io.write, FILE_NEW_LINE..header)
	utils.try(io.write, FILE_NEW_LINE)
	utils.try(io.flush)
	utils.try(io.close, handle)
	io.output(dOut)
	return true, nil
end
_M.appendHeader = appendHeader

-- get result holder string
local function getStrResultHolder(resultCount)
	if base.type(resultCount) ~= "number" then
		return nil, "First parameter should be the result count of function call."
	end
	if base.tonumber(resultCount) < 1 then
		return nil, "result count should be greater than or equal to 1."
	end

	local strResultHolder = ""

	if resultCount == 2 then
		strResultHolder = strResultHolder.."res1, res2 "
	else
		for i = 1, (resultCount-1) do
			strResultHolder = strResultHolder..("res"..i)..","
		end
		strResultHolder = strResultHolder..("res"..resultCount)
	end

	if __DEBUG then
		print("LFile.getStrResultHolder: strResultHolder = ", strResultHolder)
	end
	return strResultHolder
end

-- append content to the temp script file
local function appendFuncCall(funcCall, resultCount)
	if isParameterValid(funcCall) == false then
		return false, "must be a string in appendFuncCall method"
	end
	local dOut = io.output()
	local handle = utils.try(io.open, TEMP_FILE_PATH, "a+")
	io.output(handle)

	local strResultHolder = getStrResultHolder(resultCount)

	utils.try(io.write, FILE_NEW_LINE.."local "..strResultHolder.." = "..funcCall)

	local resultFilePath = utils.single_slash_to_double(getResultFilePath())
	utils.try(io.write, FILE_NEW_LINE.."local resultFilePath = \""..resultFilePath.."\"")
	utils.try(io.write, FILE_NEW_LINE.."lfile.setResults(resultFilePath, "..strResultHolder..")")
	utils.try(io.flush)
	utils.try(io.close, handle)
	io.output(dOut)
	return true, nil
end
_M.appendFuncCall = appendFuncCall

-- delete the temp files
local function deleteTempFiles()
	os.remove(TEMP_FILE_PATH)
	os.remove(TEMP_RESULT_FILE_PATH)
	os.remove(TEMP_BAT_FILE_PATH)
end
_M.delete = deleteTempFiles


-- serialize results to result file
-- each result has name prefix 'res', plus the result's index
function _M.setResults(...)
	local resultsTable = {...}
	local resultFilePath = resultsTable[1]
	table.remove(resultsTable, 1)
	print("setResults: result file path: ", resultFilePath)
	local handle = io.open(resultFilePath, "w+")
	for i, v in ipairs(resultsTable) do
		print("serilize: res"..i)
		local str_serialize = utils.serialize(v)
		handle:write("res"..i.." = "..str_serialize.."\n")
	end
	handle:close()
end

-- get result from result file
-- and put them into table
function _M.getResults()
	local resultsTable = {}
	
	if __DEBUG then
		print("getResults: result file path: ", getResultFilePath())
	end

	base.dofile(getResultFilePath())
	table.insert(resultsTable, base.res1)
	table.insert(resultsTable, base.res2)
	table.insert(resultsTable, base.res3)
	table.insert(resultsTable, base.res4)
	table.insert(resultsTable, base.res5)
	table.insert(resultsTable, base.res6)
	table.insert(resultsTable, base.res7)
	table.insert(resultsTable, base.res8)
	
	if not __DEBUG then
		deleteTempFiles()
	end

	return resultsTable
end

return _M