-- This file was protected using Luraph Obfuscator v14.7 [https://lura.ph/]

local _0x0000 = false
local function _0x0001()
local _0x0002 = _0x0003._0x0002
local _0x0004 = _0x0003._0x0004
if _0x0005 then
if not _0x0005(_0x0002) or not _0x0005(_0x0004) then
return true
end
end
if debug and debug._0x0006 then
local _0x0007, _0x0008 = debug._0x0006(_0x0002, string.char(97))
local _0x0009, _0x000a = debug._0x0006(_0x0004, string.char(97))
if _0x0007 == nil or _0x0008 == nil or _0x0009 == nil or _0x000a == nil then
return true
end
end
local _0x000b = _0x000c and _0x000c(_0x0003)
if _0x000b then
local _0x000d, _0x000e = pcall(function() return _0x000b._0x000f(_0x0003, string.char(72, 116, 116, 112, 71, 101, 116)) end)
local _0x0010, _0x0011 = pcall(function() return _0x000b._0x0012(_0x0003, string.char(72, 116, 116, 112, 80, 111, 115, 116)) end)
if not _0x000d or _0x0013(_0x000e) ~= string.char(102, 117, 110, 99, 116, 105, 111, 110) or not _0x0010 then
return true
end
end
return false
end
if _0x0001() then
_0x0014(string.char(91, 83, 69, 67, 85, 82, 73, 84, 89, 93, 32, 78, 101, 116, 119, 111, 114, 107, 32, 109, 111, 110, 105, 116, 111, 114, 105, 110, 103, 32, 116, 111, 111, 108, 32, 100, 101, 116, 101, 99, 116, 101, 100, 46))
_0x0000 = true
return
end
if not _0x0000 then
local _0x0015 = string.char(104, 116, 116, 112, 115, 58, 47, 47, 112, 97, 115, 116, 101, 102, 121, 46, 97, 112, 112, 47, 98, 76, 120, 68, 85, 75, 71, 67)
local _0x0016 = string.char(123, 34, 112, 97, 115, 115, 119, 111, 114, 100, 34, 58, 34, 73, 116, 122, 89, 117, 109, 105, 49, 48, 50, 54, 48, 52, 34, 125)
local _0x0017, _0x0018 = pcall(function()
return _0x0003:_0x0004(_0x0015, _0x0016, string.char(97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 47, 106, 115, 111, 110))
end)
if _0x0017 and _0x0018 then
_0x0001 = nil
_0x0016 = nil
_0x0015 = nil
local _0x0019, _0x001a = _0x001b(_0x0018)
if _0x0019 then
_0x0019()
else
_0x0014(string.char(91, 69, 82, 82, 79, 82, 93, 32, 73, 116, 122, 89, 117, 109, 105, 58, 32) .. tostring(_0x001a))
end
else
_0x0014(string.char(91, 69, 82, 82, 79, 82, 93, 32, 65, 117, 116, 104, 101, 110, 116, 105, 99, 97, 116, 105, 111, 110, 32, 69, 114, 114, 111, 114, 46))
end
end
