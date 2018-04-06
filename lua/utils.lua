--------------------------------------------------------------------------------
-- Function	: Utils help module
-- Author	: ArisHu(50362)
-- Note		: Before using this module, you have to 
--                specifiy correct ROOT_PATH below
--------------------------------------------------------------------------------
local base = _G
local table = require("table")
local io = require("io")
local string = require("string")
local debug = require("debug")
local print = print

_M = {}

--------------------------------------------------------------------------------
-- Program constants
--------------------------------------------------------------------------------
_M.__DEBUG = false

--------------------------------------------------------------------------------
-- Internal methods
--------------------------------------------------------------------------------
local function single_slash_to_double(str)
	return string.gsub(str, "[\\]", "%1%1")
end
_M.single_slash_to_double = single_slash_to_double

local function normalize_in_windows(str)
	return string.gsub(str, "[\\\\]", "\\")
end
_M.normalize_in_windows = normalize_in_windows

local function single_slash_to_backslash(str)
	return string.gsub(str, "[\\\\]", "/")
end
_M.single_slash_to_backslash = single_slash_to_backslash

-- whether or not file or directory is exist
function isFileExsist(filePath)
	local pipe = io.popen(" if exist "..filePath.." (echo 1) else (echo 0) ", "r")
	local res = tonumber(pipe:read("*a"), 10)
	pipe:close()
	return res == 1
end
_M.isFileExsist = isFileExsist

-- create dir
local function mkdir(dirPath)
	os.execute("MKDIR "..dirPath)
end
_M.mkdir = mkdir

-- report error
local function reportError(msg)
	error(msg)
end
_M.reportError = reportError

local function errHander()
	print(debug.traceback)
end

local func = nil
local funcArgs = {}
local function wrapperFunc()
	if _M.LUA_51 then
		return func(base.unpack(funcArgs))
	else
		return func(table.unpack(funcArgs))
	end
end
local function clearFunc()
	func = nil
	funcArgs = {}
end

--------------------------------------------------------------------------------
-- properties
--------------------------------------------------------------------------------
-- root path, must be configed before using
local LUAHOME = os.getenv("LUA_HOME") or os.getenv("LUAHOME")

do
	if _M.__DEBUG then
		print("utils LUAHOME: ", LUAHOME)
	end

	if not LUAHOME then
		reportError("should config 'LUA_HOME' or 'LUAHOME' first")
	end
end

_M.ROOT_PATH = LUAHOME.."\\"

_M.C_PATH = _M.ROOT_PATH.."clibs\\"
_M.LUA_PATH = _M.ROOT_PATH.."lua\\"

_M.TEMP_PATH = os.getenv("WINDIR").."\\temp\\utils\\"
do
	if not isFileExsist(_M.TEMP_PATH) then
		mkdir(_M.TEMP_PATH)
	end
end
_M.LUA_51 = string.find(base._VERSION, "5.1") and true or false
_M.LUA_52 = string.find(base._VERSION, "5.2") and true or false
_M.LUA_53 = string.find(base._VERSION, "5.3") and true or false

local _VERSION = "1.0.0"
local _AUTHOR = "50362"
local _CREATED_TIME = "2018/03/25"
local FILE_NEW_LINE = "\n"

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------
function _M.version()
	local v = _VERSION.."\n".._AUTHOR.."\n".._CREATED_TIME
	return v
end

local function try(f, ...)
	if base.type(f) ~= "function" then
		base.error("not a function", 2)
	end
	func = f
	funcArgs = {...}
	local results = {base.xpcall(wrapperFunc, errHander)}
	if results[1] == false then -- error
		clearFunc()
		return reportError(errMsg)
	end
	table.remove(results, 1) -- result status code
	if _M.LUA_51 then
		return base.unpack(results)
	else
		return table.unpack(results)
	end
end

_M.try = try

-- 去除字符串中的所有空格
local function trim(str)
    local s = nil
	if (str == nil or str == "") then
		s = ""
	else
		s = string.gsub(str, "^%s*(.-)%s*$","%1")
	end
	return s
end

_M.trim = trim

-- 使用delimiter, 将字符串进行分割
-- 返回被分割的字符串Table
-- eg. split("Hello World", " ")将会得到一个table，为{"Hello", "World"}
local function split(str, delimiter)
	local ret = {}
	delimiter = delimiter or " "
	if str == nil then
		return {}
	end
	local lastIndex = 1
	local j = 1
	for i=1, #str do
		if string.char(string.byte(str,i)) == delimiter then
			ret[j] = string.sub(str, lastIndex, i-1)
			j = j + 1
			lastIndex = i + 1
		end
	end

	if lastIndex < #str then
		ret[j] = string.sub(str, lastIndex, #str)
	end
	return ret
end

_M.split = split

function _M.extractResultFromFile(resultFilePath)
    local resultFile = try(io.open, resultFilePath, "r")
    local ret = {}
    for line in resultFile:lines() do
	ret = split(trim(line), ";")
	break
    end
    resultFile:close()
    if #ret > 0 then
	if _M.LUA_51 then
		return base.unpack(ret)
	else
		return table.unpack(ret)
	end
    end
    return nil, nil
end

-- serialize lua data
-- only apply to nil, string, number and table
local function serialize(o)
    local str_serialize = ""
    if o == nil then  
        str_serialize = str_serialize.."nil"
        return str_serialize
    end  
    if type(o) == "number" then   
        str_serialize = str_serialize..o  
    elseif type(o) == "string" then  
        str_serialize = str_serialize..string.format("%q", o)  
    elseif type(o) == "table" then  
        str_serialize = str_serialize.."{"..FILE_NEW_LINE  
        for k,v in pairs(o) do  
            str_serialize = str_serialize.." ["  
            str_serialize = str_serialize..serialize(k)
            str_serialize = str_serialize.."] = "  
            str_serialize = str_serialize..serialize(v)
            str_serialize = str_serialize..","..FILE_NEW_LINE  
        end
        str_serialize = str_serialize.."}"  
    elseif type(o) == "boolean" then  
        str_serialize = str_serialize..(o and "true" or "false")  
    elseif type(o) == "function" then  
        str_serialize = str_serialize.."function"  
    else  
        error("cannot serialize a "..type(o))  
    end
    return str_serialize
end

_M.serialize = serialize

return _M