--------------------------------------------------------------------------------
-- Function	: Class for creating temporary file
-- Author	: ArisHu(50362)
--------------------------------------------------------------------------------
local base = _G
local utils = require("utils")
local math = require("math")
local string = require("string")
local os = require("os")
local io = require("io")
local TEMP_PATH = utils.TEMP_PATH
local __DEBUG = utils.__DEBUG

utils.ltf = {}

local _M = utils.ltf

_M.fileName = nil
_M.filePath = nil
_M.fileExt = nil
_M.fileHandle = nil

--------------------------------------------------------------------------------
-- Internal Methods
--------------------------------------------------------------------------------
-- get random temporary file with specified file extension
local function getRandomFileName(fileExt)
	math.randomseed(os.time())
	local randomVal = math.random(1, 10000)
	local fileName = "temp"..(base.tostring(randomVal))..fileExt
	return fileName
end


--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
-- create a temp file
function _M:create(fileExt)
	if base.type(fileExt) ~= "string" then
		error("Invalid parameter: should be a valid file extension")
	end
	
	if not string.find(fileExt, "%.") then
		fileExt = "."..fileExt
	end

	_M.fileName = getRandomFileName(fileExt)
	_M.filePath = TEMP_PATH..(_M.fileName)
	_M.fileExt = fileExt
	_M.fileHandle, errMsg = io.open(_M.filePath, "w+")
	if errMsg ~= nil then
		base.error("open temp file failed: "..errMsg)
	end
	return _M
end

-- get temp file's name
function _M:getName()
	return _M.fileName
end

-- get temp file's absolute path
function _M:getPath()
	return utils.normalize_in_windows(_M.filePath)
end

-- write content to temp file
function _M:write(...)
	if _M.fileHandle ~= nil then
		_M.fileHandle:write(...)
	else
		base.error("Cannot write to file: attempt to write to a closed file")
	end
end

-- close file handle
-- optionally delete the file
function _M:close(delete)
	-- if file handle not equals to nil, 
	-- then close it
	if _M.fileHandle then
		_M.fileHandle:close()
		_M.fileHandle = nil
		
		if delete ~= nil then
			if base.type(delete) == "boolean" then
				if delete then
					os.remove(_M.filePath)
					_M.filePath = nil
				end
			else
				base.error("parameter should be a boolean value")
			end
		end
		return true
	else
		base.error("attempt to close a closed file")
	end
end

return _M