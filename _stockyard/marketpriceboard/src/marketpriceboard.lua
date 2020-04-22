--文字処理用
-- $Id: utf8.lua 179 2009-04-03 18:10:03Z pasta $
--
-- Provides UTF-8 aware string functions implemented in pure lua:
-- * utf8len(s)
-- * utf8sub(s, i, j)
-- * utf8reverse(s)
-- * utf8char(unicode)
-- * utf8unicode(s, i, j)
-- * utf8gensub(s, sub_len)
-- * utf8find(str, regex, init, plain)
-- * utf8match(str, regex, init)
-- * utf8gmatch(str, regex, all)
-- * utf8gsub(str, regex, repl, limit)
--
-- If utf8data.lua (containing the lower<->upper case mappings) is loaded, these
-- additional functions are available:
-- * utf8upper(s)
-- * utf8lower(s)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.
--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.

Contributors:
Alimov Stepan

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the author nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-- ABNF from RFC 3629
--
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF
--
local byte = string.byte
local char = string.char
local dump = string.dump
local find = string.find
local format = string.format
local gmatch = string.gmatch
local gsub = string.gsub
local len = string.len
local lower = string.lower
local match = string.match
local rep = string.rep
local reverse = string.reverse
local sub = string.sub
local upper = string.upper

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes(s, i)
    -- argument defaults
    i = i or 1
    
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8charbytes' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8charbytes' (number expected, got " .. type(i) .. ")")
    end
    
    local c = byte(s, i)
    
    -- determine bytes needed for character, based on RFC 3629
    -- validate byte 1
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1
    
    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = byte(s, i + 1)
        
        if not c2 then
            error("UTF-8 string terminated early")
        end
        
        -- validate byte 2
        if c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end
        
        return 2
    
    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = byte(s, i + 1)
        local c3 = byte(s, i + 2)
        
        if not c2 or not c3 then
            error("UTF-8 string terminated early")
        end
        
        -- validate byte 2
        if c == 224 and (c2 < 160 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 237 and (c2 < 128 or c2 > 159) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end
        
        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end
        
        return 3
    
    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = byte(s, i + 1)
        local c3 = byte(s, i + 2)
        local c4 = byte(s, i + 3)
        
        if not c2 or not c3 or not c4 then
            error("UTF-8 string terminated early")
        end
        
        -- validate byte 2
        if c == 240 and (c2 < 144 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 244 and (c2 < 128 or c2 > 143) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end
        
        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end
        
        -- validate byte 4
        if c4 < 128 or c4 > 191 then
            error("Invalid UTF-8 character")
        end
        
        return 4
    
    else
        error("Invalid UTF-8 character")
    end
end

-- returns the number of characters in a UTF-8 string
local function utf8len(s)
    -- argument checking
    if type(s) ~= "string" then
        for k, v in pairs(s) do print('"', tostring(k), '"', tostring(v), '"') end
        error("bad argument #1 to 'utf8len' (string expected, got " .. type(s) .. ")")
    end
    
    local pos = 1
    local bytes = len(s)
    local len = 0
    
    while pos <= bytes do
        len = len + 1
        pos = pos + utf8charbytes(s, pos)
    end
    
    return len
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub(s, i, j)
    -- argument defaults
    j = j or -1
    
    local pos = 1
    local bytes = len(s)
    local len = 0
    
    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or utf8len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1
    
    -- can't have start before end!
    if startChar > endChar then
        return ""
    end
    
    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes
    
    while pos <= bytes do
        len = len + 1
        
        if len == startChar then
            startByte = pos
        end
        
        pos = pos + utf8charbytes(s, pos)
        
        if len == endChar then
            endByte = pos - 1
            break
        end
    end
    
    if startChar > len then startByte = bytes + 1 end
    if endChar < 1 then endByte = 0 end
    
    return sub(s, startByte, endByte)
end


-- replace UTF-8 characters based on a mapping table
local function utf8replace(s, mapping)
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8replace' (string expected, got " .. type(s) .. ")")
    end
    if type(mapping) ~= "table" then
        error("bad argument #2 to 'utf8replace' (table expected, got " .. type(mapping) .. ")")
    end
    
    local pos = 1
    local bytes = len(s)
    local charbytes
    local newstr = ""
    
    while pos <= bytes do
        charbytes = utf8charbytes(s, pos)
        local c = sub(s, pos, pos + charbytes - 1)
        
        newstr = newstr .. (mapping[c] or c)
        
        pos = pos + charbytes
    end
    
    return newstr
end


-- identical to string.upper except it knows about unicode simple case conversions
local function utf8upper(s)
    return utf8replace(s, utf8_lc_uc)
end

-- identical to string.lower except it knows about unicode simple case conversions
local function utf8lower(s)
    return utf8replace(s, utf8_uc_lc)
end

-- identical to string.reverse except that it supports UTF-8
local function utf8reverse(s)
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8reverse' (string expected, got " .. type(s) .. ")")
    end
    
    local bytes = len(s)
    local pos = bytes
    local charbytes
    local newstr = ""
    
    while pos > 0 do
        c = byte(s, pos)
        while c >= 128 and c <= 191 do
            pos = pos - 1
            c = byte(s, pos)
        end
        
        charbytes = utf8charbytes(s, pos)
        
        newstr = newstr .. sub(s, pos, pos + charbytes - 1)
        
        pos = pos - 1
    end
    
    return newstr
end

-- http://en.wikipedia.org/wiki/Utf8
-- http://developer.coronalabs.com/code/utf-8-conversion-utility
local function utf8char(unicode)
    if unicode <= 0x7F then return char(unicode) end
    
    if (unicode <= 0x7FF) then
        local Byte0 = 0xC0 + math.floor(unicode / 0x40);
        local Byte1 = 0x80 + (unicode % 0x40);
        return char(Byte0, Byte1);
    end;
    
    if (unicode <= 0xFFFF) then
        local Byte0 = 0xE0 + math.floor(unicode / 0x1000);
        local Byte1 = 0x80 + (math.floor(unicode / 0x40) % 0x40);
        local Byte2 = 0x80 + (unicode % 0x40);
        return char(Byte0, Byte1, Byte2);
    end;
    
    if (unicode <= 0x10FFFF) then
        local code = unicode
        local Byte3 = 0x80 + (code % 0x40);
        code = math.floor(code / 0x40)
        local Byte2 = 0x80 + (code % 0x40);
        code = math.floor(code / 0x40)
        local Byte1 = 0x80 + (code % 0x40);
        code = math.floor(code / 0x40)
        local Byte0 = 0xF0 + code;
        
        return char(Byte0, Byte1, Byte2, Byte3);
    end;
    
    error 'Unicode cannot be greater than U+10FFFF!'
end

local shift_6 = 2 ^ 6
local shift_12 = 2 ^ 12
local shift_18 = 2 ^ 18

local utf8unicode
utf8unicode = function(str, i, j, byte_pos)
    i = i or 1
    j = j or i
    
    if i > j then return end
    
    local char, bytes
    
    if byte_pos then
        bytes = utf8charbytes(str, byte_pos)
        char = sub(str, byte_pos, byte_pos - 1 + bytes)
    else
        char, byte_pos = utf8sub(str, i, i), 0
        bytes = #char
    end
    
    local unicode
    
    if bytes == 1 then unicode = byte(char) end
    if bytes == 2 then
        local byte0, byte1 = byte(char, 1, 2)
        local code0, code1 = byte0 - 0xC0, byte1 - 0x80
        unicode = code0 * shift_6 + code1
    end
    if bytes == 3 then
        local byte0, byte1, byte2 = byte(char, 1, 3)
        local code0, code1, code2 = byte0 - 0xE0, byte1 - 0x80, byte2 - 0x80
        unicode = code0 * shift_12 + code1 * shift_6 + code2
    end
    if bytes == 4 then
        local byte0, byte1, byte2, byte3 = byte(char, 1, 4)
        local code0, code1, code2, code3 = byte0 - 0xF0, byte1 - 0x80, byte2 - 0x80, byte3 - 0x80
        unicode = code0 * shift_18 + code1 * shift_12 + code2 * shift_6 + code3
    end
    
    return unicode, utf8unicode(str, i + 1, j, byte_pos + bytes)
end

-- Returns an iterator which returns the next substring and its byte interval
local function utf8gensub(str, sub_len)
    sub_len = sub_len or 1
    local byte_pos = 1
    local len = #str
    return function(skip)
        if skip then byte_pos = byte_pos + skip end
        local char_count = 0
        local start = byte_pos
        repeat
            if byte_pos > len then return end
            char_count = char_count + 1
            local bytes = utf8charbytes(str, byte_pos)
            byte_pos = byte_pos + bytes
        
        until char_count == sub_len
        
        local last = byte_pos - 1
        local sub = sub(str, start, last)
        return sub, start, last
    end
end

local function binsearch(sortedTable, item, comp)
    local head, tail = 1, #sortedTable
    local mid = math.floor((head + tail) / 2)
    if not comp then
        while (tail - head) > 1 do
            if sortedTable[tonumber(mid)] > item then
                tail = mid
            else
                head = mid
            end
            mid = math.floor((head + tail) / 2)
        end
    else
        end
    if sortedTable[tonumber(head)] == item then
        return true, tonumber(head)
    elseif sortedTable[tonumber(tail)] == item then
        return true, tonumber(tail)
    else
        return false
    end
end
local function classMatchGenerator(class, plain)
    local codes = {}
    local ranges = {}
    local ignore = false
    local range = false
    local firstletter = true
    local unmatch = false
    
    local it = utf8gensub(class)
    
    local skip
    for c, bs, be in it do
        skip = be
        if not ignore and not plain then
            if c == "%" then
                ignore = true
            elseif c == "-" then
                table.insert(codes, utf8unicode(c))
                range = true
            elseif c == "^" then
                if not firstletter then
                    error('!!!')
                else
                    unmatch = true
                end
            elseif c == ']' then
                break
            else
                if not range then
                    table.insert(codes, utf8unicode(c))
                else
                    table.remove(codes)-- removing '-'
                    table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                    range = false
                end
            end
        elseif ignore and not plain then
            if c == 'a' then -- %a: represents all letters. (ONLY ASCII)
                table.insert(ranges, {65, 90})-- A - Z
                table.insert(ranges, {97, 122})-- a - z
            elseif c == 'c' then -- %c: represents all control characters.
                table.insert(ranges, {0, 31})
                table.insert(codes, 127)
            elseif c == 'd' then -- %d: represents all digits.
                table.insert(ranges, {48, 57})-- 0 - 9
            elseif c == 'g' then -- %g: represents all printable characters except space.
                table.insert(ranges, {1, 8})
                table.insert(ranges, {14, 31})
                table.insert(ranges, {33, 132})
                table.insert(ranges, {134, 159})
                table.insert(ranges, {161, 5759})
                table.insert(ranges, {5761, 8191})
                table.insert(ranges, {8203, 8231})
                table.insert(ranges, {8234, 8238})
                table.insert(ranges, {8240, 8286})
                table.insert(ranges, {8288, 12287})
            elseif c == 'l' then -- %l: represents all lowercase letters. (ONLY ASCII)
                table.insert(ranges, {97, 122})-- a - z
            elseif c == 'p' then -- %p: represents all punctuation characters. (ONLY ASCII)
                table.insert(ranges, {33, 47})
                table.insert(ranges, {58, 64})
                table.insert(ranges, {91, 96})
                table.insert(ranges, {123, 126})
            elseif c == 's' then -- %s: represents all space characters.
                table.insert(ranges, {9, 13})
                table.insert(codes, 32)
                table.insert(codes, 133)
                table.insert(codes, 160)
                table.insert(codes, 5760)
                table.insert(ranges, {8192, 8202})
                table.insert(codes, 8232)
                table.insert(codes, 8233)
                table.insert(codes, 8239)
                table.insert(codes, 8287)
                table.insert(codes, 12288)
            elseif c == 'u' then -- %u: represents all uppercase letters. (ONLY ASCII)
                table.insert(ranges, {65, 90})-- A - Z
            elseif c == 'w' then -- %w: represents all alphanumeric characters. (ONLY ASCII)
                table.insert(ranges, {48, 57})-- 0 - 9
                table.insert(ranges, {65, 90})-- A - Z
                table.insert(ranges, {97, 122})-- a - z
            elseif c == 'x' then -- %x: represents all hexadecimal digits.
                table.insert(ranges, {48, 57})-- 0 - 9
                table.insert(ranges, {65, 70})-- A - F
                table.insert(ranges, {97, 102})-- a - f
            else
                if not range then
                    table.insert(codes, utf8unicode(c))
                else
                    table.remove(codes)-- removing '-'
                    table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                    range = false
                end
            end
            ignore = false
        else
            if not range then
                table.insert(codes, utf8unicode(c))
            else
                table.remove(codes)-- removing '-'
                table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                range = false
            end
            ignore = false
        end
        
        firstletter = false
    end
    
    table.sort(codes)
    
    local function inRanges(charCode)
        for _, r in ipairs(ranges) do
            if r[1] <= charCode and charCode <= r[2] then
                return true
            end
        end
        return false
    end
    if not unmatch then
        return function(charCode)
            return binsearch(codes, charCode) or inRanges(charCode)
        end, skip
    else
        return function(charCode)
            return charCode ~= -1 and not (binsearch(codes, charCode) or inRanges(charCode))
        end, skip
    end
end

-- utf8sub with extra argument, and extra result value
local function utf8subWithBytes(s, i, j, sb)
    -- argument defaults
    j = j or -1
    
    local pos = sb or 1
    local bytes = len(s)
    local len = 0
    
    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or utf8len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1
    
    -- can't have start before end!
    if startChar > endChar then
        return ""
    end
    
    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes
    
    while pos <= bytes do
        len = len + 1
        
        if len == startChar then
            startByte = pos
        end
        
        pos = pos + utf8charbytes(s, pos)
        
        if len == endChar then
            endByte = pos - 1
            break
        end
    end
    
    if startChar > len then startByte = bytes + 1 end
    if endChar < 1 then endByte = 0 end
    
    return sub(s, startByte, endByte), endByte + 1
end

local cache = setmetatable({}, {
    __mode = 'kv'
})
local cachePlain = setmetatable({}, {
    __mode = 'kv'
})
local function matcherGenerator(regex, plain)
    local matcher = {
        functions = {},
        captures = {}
    }
    if not plain then
        cache[regex] = matcher
    else
        cachePlain[regex] = matcher
    end
    local function simple(func)
        return function(cC)
            if func(cC) then
                matcher:nextFunc()
                matcher:nextStr()
            else
                matcher:reset()
            end
        end
    end
    local function star(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextFunc()
                matcher:nextStr()
            else
                matcher:nextFunc()
            end
        end
    end
    local function minus(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextStr()
            end
            matcher:nextFunc()
        end
    end
    local function question(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextFunc()
                matcher:nextStr()
            end
            matcher:nextFunc()
        end
    end
    
    local function capture(id)
        return function(cC)
            local l = matcher.captures[id][2] - matcher.captures[id][1]
            local captured = utf8sub(matcher.string, matcher.captures[id][1], matcher.captures[id][2])
            local check = utf8sub(matcher.string, matcher.str, matcher.str + l)
            if captured == check then
                for i = 0, l do
                    matcher:nextStr()
                end
                matcher:nextFunc()
            else
                matcher:reset()
            end
        end
    end
    local function captureStart(id)
        return function(cC)
            matcher.captures[id][1] = matcher.str
            matcher:nextFunc()
        end
    end
    local function captureStop(id)
        return function(cC)
            matcher.captures[id][2] = matcher.str - 1
            matcher:nextFunc()
        end
    end
    
    local function balancer(str)
        local sum = 0
        local bc, ec = utf8sub(str, 1, 1), utf8sub(str, 2, 2)
        local skip = len(bc) + len(ec)
        bc, ec = utf8unicode(bc), utf8unicode(ec)
        return function(cC)
            if cC == ec and sum > 0 then
                sum = sum - 1
                if sum == 0 then
                    matcher:nextFunc()
                end
                matcher:nextStr()
            elseif cC == bc then
                sum = sum + 1
                matcher:nextStr()
            else
                if sum == 0 or cC == -1 then
                    sum = 0
                    matcher:reset()
                else
                    matcher:nextStr()
                end
            end
        end, skip
    end
    
    matcher.functions[1] = function(cC)
        matcher:fullResetOnNextStr()
        matcher.seqStart = matcher.str
        matcher:nextFunc()
        if (matcher.str > matcher.startStr and matcher.fromStart) or matcher.str >= matcher.stringLen then
            matcher.stop = true
            matcher.seqStart = nil
        end
    end
    
    local lastFunc
    local ignore = false
    local skip = nil
    local it = (function()
        local gen = utf8gensub(regex)
        return function()
            return gen(skip)
        end
    end)()
    local cs = {}
    for c, bs, be in it do
        skip = nil
        if plain then
            table.insert(matcher.functions, simple(classMatchGenerator(c, plain)))
        else
            if ignore then
                if find('123456789', c, 1, true) then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    table.insert(matcher.functions, capture(tonumber(c)))
                elseif c == 'b' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    local b
                    b, skip = balancer(sub(regex, be + 1, be + 9))
                    table.insert(matcher.functions, b)
                else
                    lastFunc = classMatchGenerator('%' .. c)
                end
                ignore = false
            else
                if c == '*' then
                    if lastFunc then
                        table.insert(matcher.functions, star(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '+' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        table.insert(matcher.functions, star(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '-' then
                    if lastFunc then
                        table.insert(matcher.functions, minus(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '?' then
                    if lastFunc then
                        table.insert(matcher.functions, question(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '^' then
                    if bs == 1 then
                        matcher.fromStart = true
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '$' then
                    if be == len(regex) then
                        matcher.toEnd = true
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '[' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc, skip = classMatchGenerator(sub(regex, be + 1))
                elseif c == '(' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    table.insert(matcher.captures, {})
                    table.insert(cs, #matcher.captures)
                    table.insert(matcher.functions, captureStart(cs[#cs]))
                    if sub(regex, be + 1, be + 1) == ')' then matcher.captures[#matcher.captures].empty = true end
                elseif c == ')' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    local cap = table.remove(cs)
                    if not cap then
                        error('invalid capture: "(" missing')
                    end
                    table.insert(matcher.functions, captureStop(cap))
                elseif c == '.' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc = function(cC) return cC ~= -1 end
                elseif c == '%' then
                    ignore = true
                else
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc = classMatchGenerator(c)
                end
            end
        end
    end
    if #cs > 0 then
        error('invalid capture: ")" missing')
    end
    if lastFunc then
        table.insert(matcher.functions, simple(lastFunc))
    end
    lastFunc = nil
    ignore = nil
    
    table.insert(matcher.functions, function()
        if matcher.toEnd and matcher.str ~= matcher.stringLen then
            matcher:reset()
        else
            matcher.stop = true
        end
    end)
    
    matcher.nextFunc = function(self)
        self.func = self.func + 1
    end
    matcher.nextStr = function(self)
        self.str = self.str + 1
    end
    matcher.strReset = function(self)
        local oldReset = self.reset
        local str = self.str
        self.reset = function(s)
            s.str = str
            s.reset = oldReset
        end
    end
    matcher.fullResetOnNextFunc = function(self)
        local oldReset = self.reset
        local func = self.func + 1
        local str = self.str
        self.reset = function(s)
            s.func = func
            s.str = str
            s.reset = oldReset
        end
    end
    matcher.fullResetOnNextStr = function(self)
        local oldReset = self.reset
        local str = self.str + 1
        local func = self.func
        self.reset = function(s)
            s.func = func
            s.str = str
            s.reset = oldReset
        end
    end
    
    matcher.process = function(self, str, start)
            
            self.func = 1
            start = start or 1
            self.startStr = (start >= 0) and start or utf8len(str) + start + 1
            self.seqStart = self.startStr
            self.str = self.startStr
            self.stringLen = utf8len(str) + 1
            self.string = str
            self.stop = false
            
            self.reset = function(s)
                s.func = 1
            end
            
            local lastPos = self.str
            local lastByte
            local char
            while not self.stop do
                if self.str < self.stringLen then
                    --[[ if lastPos < self.str then
                    print('last byte', lastByte)
                    char, lastByte = utf8subWithBytes(str, 1, self.str - lastPos - 1, lastByte)
                    char, lastByte = utf8subWithBytes(str, 1, 1, lastByte)
                    lastByte = lastByte - 1
                    else
                    char, lastByte = utf8subWithBytes(str, self.str, self.str)
                    end
                    lastPos = self.str ]]
                    char = utf8sub(str, self.str, self.str)
                    --print('char', char, utf8unicode(char))
                    self.functions[self.func](utf8unicode(char))
                else
                    self.functions[self.func](-1)
                end
            end
            
            if self.seqStart then
                local captures = {}
                for _, pair in pairs(self.captures) do
                    if pair.empty then
                        table.insert(captures, pair[1])
                    else
                        table.insert(captures, utf8sub(str, pair[1], pair[2]))
                    end
                end
                return self.seqStart, self.str - 1, unpack(captures)
            end
    end
    
    return matcher
end

-- string.find
local function utf8find(str, regex, init, plain)
    local matcher = cache[regex] or matcherGenerator(regex, plain)
    return matcher:process(str, init)
end

-- string.match
local function utf8match(str, regex, init)
    init = init or 1
    local found = {utf8find(str, regex, init)}
    if found[1] then
        if found[3] then
            return unpack(found, 3)
        end
        return utf8sub(str, found[1], found[2])
    end
end

-- string.gmatch
local function utf8gmatch(str, regex, all)
    regex = (utf8sub(regex, 1, 1) ~= '^') and regex or '%' .. regex
    local lastChar = 1
    return function()
        local found = {utf8find(str, regex, lastChar)}
        if found[1] then
            lastChar = found[2] + 1
            if found[all and 1 or 3] then
                return unpack(found, all and 1 or 3)
            end
            return utf8sub(str, found[1], found[2])
        end
    end
end

local function replace(repl, args)
    local ret = ''
    if type(repl) == 'string' then
        local ignore = false
        local num = 0
        for c in utf8gensub(repl) do
            if not ignore then
                if c == '%' then
                    ignore = true
                else
                    ret = ret .. c
                end
            else
                num = tonumber(c)
                if num then
                    ret = ret .. args[num]
                else
                    ret = ret .. c
                end
                ignore = false
            end
        end
    elseif type(repl) == 'table' then
        ret = repl[args[1] or args[0]] or ''
    elseif type(repl) == 'function' then
        if #args > 0 then
            ret = repl(unpack(args, 1)) or ''
        else
            ret = repl(args[0]) or ''
        end
    end
    return ret
end
-- string.gsub
local function utf8gsub(str, regex, repl, limit)
    limit = limit or -1
    local ret = ''
    local prevEnd = 1
    local it = utf8gmatch(str, regex, true)
    local found = {it()}
    local n = 0
    while #found > 0 and limit ~= n do
        local args = {[0] = utf8sub(str, found[1], found[2]), unpack(found, 3)}
        ret = ret .. utf8sub(str, prevEnd, found[1] - 1)
            .. replace(repl, args)
        prevEnd = found[2] + 1
        n = n + 1
        found = {it()}
    end
    return ret .. utf8sub(str, prevEnd), n
end

---------
--referenced from http://d.hatena.ne.jp/Ko-Ta/20100830/p1
-- lua
-- setfenv is gone since Lua 5.2
-- copied from https://leafo.net/guides/setfenv-in-lua52-and-above.html
local setfenv = _G['setfenv']
if not setfenv then
    setfenv = function(fn, env)
        local i = 1
        while true do
          local name = debug.getupvalue(fn, i)
          if name == "_ENV" then
            debug.upvaluejoin(fn, i, (function()
              return env
            end), 1)
            break
          elseif not name then
            break
          end
      
          i = i + 1
        end
        return fn
      end
end

-- テーブルシリアライズ
local function value2str(v)
	local vt = type(v);
	
	if (vt=="nil")then
		return "nil";
	end;
	if (vt=="number")then
		return string.format("%d",v);
	end;
	if (vt=="string")then
		return string.format('"%s"',v);
	end;
	if (vt=="boolean")then
		if (v==true)then
			return "true";
		else
			return "false";
		end;
	end;
	if (vt=="function")then
		return '"*function"';
	end;
	if (vt=="thread")then
		return '"*thread"';
	end;
	if (vt=="userdata")then
		return '"*userdata"';
	end;
	return '"UnsupportFormat"';
end;

local function field2str(v)
	local vt = type(v);
	
	if (vt=="number")then
		return string.format("[%d]",v);
	end;
	if (vt=="string")then
		return string.format("%s",v);
	end;
	return 'UnknownField';
end;

local function serialize(t)
	local f,v,buf;
	
	-- テーブルじゃない場合
	if not(type(t)=="table")then
		return value2str(t);
	end
	
	buf = "";
	f,v = next(t,nil);
	while f do
		-- ,を付加する
		if (buf~="")then
			buf = buf .. ",";
		end;
		-- 値
		if (type(v)=="table")then
			buf = buf .. field2str(f) .. "=" .. serialize(v);
		else
			buf = buf .. field2str(f) .. "=" .. value2str(v);
		end;
		-- 次の要素
		f,v = next(t,f);
	end
	
	buf = "{" .. buf .. "}";
	return buf;
end;
local function loadfromfile_internal(path,dummy)
    local result,data=pcall(dofile,path)
    if(result)then
        return data
    else
        --print("FAIL"..data)
        return dummy
    end
end
local function loadfromfile(path,dummy)
    local env = {dofile=dofile,pcall=pcall}
    local lff=loadfromfile_internal
    setfenv(lff, env)
    local result,data=pcall(lff,path,dummy)
    if(result)then
        return data
    else

        return dummy
    end
end;
local function savetofile(path,data)
    local s="return "..serialize(data)
    --CHAT_SYSTEM(tostring(#s))
    local fn=io.open(path,"w+")
    fn:write(s)
    fn:flush()
    fn:close()
end;
local function treat(key)
    if(tonumber(key)~=nil)then
        return "c"..tostring(key)
    else
        return key
    end
end
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
----------------------
--アドオン名（大文字）
local addonName = "marketpriceboard"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

--設定ファイル保存先
--nil=ALPHA1
--1=ALPHA1-2
--2=ALPHA3,0.0.1,ALPHA4,0.0.2
--3=ALPHA5,0.0.3,0.0.4,0.0.5
g.version = 3
g.basePath = string.format('../addons/%s/', addonNameLower)
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
-- g.prices = {
--     _sample_ = {
--         currentState = {
--             priceHigh = "0",
--             priceLow = "0",
--             priceClose = "0",
--             priceOpen = "0",
--         },
--         latestDate=nil,
--         dirty = false,
--         indication_bid = {
--             P0 = {
--                 count = 0,
--                 price = "0"
--             }
--         },
--         history = {
        
--         }
--     }
-- }
g.framename = "marketpriceboard"
g.debug = false
g.slotsize = {48, 48}
g.rows=35
g.columns=5
g.slots = g.rows*g.columns
g.ignore = true
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)
g.clsidlist=nil
g.compfuncstr=nil
g.requestcount=7
g.isminutemode=false
g.dateformat="%Y-%m-%dT%H:00:00+09:00"
g.minutedateformat="%Y-%m-%dT%H:%M:00+09:00"
g.dateformatdaily="%Y-%m-%dT00:00:00+09:00"
g.known={}
g.chartlimit=360
g.max="99999999999"
g.maxint=9999999999

--ライブラリ読み込み
CHAT_SYSTEM("[MPB]loaded")
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
local function IsLesserThanForBigNumber(a, b)
    if a == b or (IsGreaterThanForBigNumber(a, b) == 1) then
        return 0
    end
    return 1
end


local translationtable = {
    
    }

local function L_(str)
    if (translationtable[str] == nil) then
        return str
    end
    if (option.GetCurrentCountry() == "Japanese") then
        return translationtable[str].jp
    end
    if (translationtable[str].eng ~= nil) then
        return translationtable[str].eng
    end
    return str

end

--デフォルト設定
if (not g.loaded) then
    --シンタックス用に残す
    g.settings = {
        version = nil,
        --フレーム表示場所
        position = {
            x = 0,
            y = 0
        },
        items = {},
        ebi=true,
    }


end

local function MARKETPRICEBOARD_DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
            end
        end,
        catch = function(error)
        end
    }

end
local function MARKETPRICEBOARD_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function MARKETPRICEBOARD_SAVE_SETTINGS()
    MARKETPRICEBOARD_DBGOUT("SAVE_SETTINGS")
    MARKETPRICEBOARD_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)

end

function MARKETPRICEBOARD_LOAD_SETTINGS()
    
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        MARKETPRICEBOARD_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {items = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    
    local upc = MARKETPRICEBOARD_UPGRADE_SETTINGS()
    
    -- ショートサーキット評価を回避するため、いったん変数に入れる
    if upc then
        MARKETPRICEBOARD_SAVE_SETTINGS()
    end
   
end
function MARKETPRICEBOARD_UPGRADE_SETTINGS()
    local upgraded = false
    --1->2
    if (g.settings.version == nil or g.settings.version == 1) then
        CHAT_SYSTEM(L_("Tsettingsupdt12"))
        
        g.settings.version = 2
        upgraded = true
    end
    --1->2
    if (g.settings.version == 2) then
        CHAT_SYSTEM(L_("Tsettingsupdt23"))
        g.settings.itemmanagetempdisabled = false
        g.settings.version = 3
        upgraded = true
    end
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function MARKETPRICEBOARD_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            frame:ShowWindow(0)
            acutil.slashCommand("/mpb", MARKETPRICEBOARD_PROCESS_COMMAND);
            addon:RegisterMsg("OPEN_DLG_MARKET", "MARKETPRICEBOARD_ON_OPEN_MARKET");
            addon:RegisterMsg("MARKET_ITEM_LIST", "MARKETPRICEBOARD_ON_MARKET_ITEM_LIST");
            addon:RegisterMsg("MARKET_MINMAX_INFO", "MARKETPRICEBOARD_ON_MARKET_MINMAX_INFO");
            addon:RegisterMsg("MARKET_MINMAX_INFO", "MARKETPRICEBOARD_ON_MARKET_MINMAX_INFO");
            addon:RegisterMsg('GAME_START_3SEC', 'MARKETPRICEBOARD_3SEC')
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            g.ignore=true
            MARKETPRICEBOARD_INIT_FRAME(frame)
            MARKETPRICEBOARD_LOADALLPRICE()
            
           
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end


function MARKETPRICEBOARD_3SEC()
    
    --ReserveScript("MARKETPRICEBOARD_EBI_TRACKER()",20)
    
end
function MARKETPRICEBOARD_TOGGLE_FRAME()
    ui.ToggleFrame(g.framename)
--MARKETPRICEBOARD_SAVE_SETTINGS()
end

function MARKETPRICEBOARD_CLOSE(frame)
    frame:ShowWindow(0)
--MARKETPRICEBOARD_SAVE_SETTINGS()
end
local function GET_SEARCH_PRICE_ORDER(frame)
	local priceOrderCheck_0 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_0');
	local priceOrderCheck_1 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_1');
	if priceOrderCheck_0 == nil or priceOrderCheck_1 == nil then
		return -1;
	end

	if priceOrderCheck_0:IsChecked() == 1 then
		return 0;
	end
	if priceOrderCheck_1:IsChecked() == 1 then
		return 1;
	end
	return 0; -- default
end
local function GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit)
	local queryValue = '';
	local minValue = -1000000;
	local maxValue = 1000000;
	local valid = false;
	if minEdit:GetText() ~= nil and minEdit:GetText() ~= '' then
		minValue = tonumber(minEdit:GetText());
		valid = true;
	end
	if maxEdit:GetText() ~= nil and maxEdit:GetText() ~= '' then
		maxValue = tonumber(maxEdit:GetText());
		valid = true;
	end
	
	if valid == false then
		return queryValue;
	end

	queryValue = minValue..';'..maxValue;	
	return queryValue;
end

local function GET_SEARCH_OPTION(frame)
	local optionName, optionValue = {}, {};
	local optionSet = {}; -- for checking duplicate option
	local category = frame:GetUserValue('SELECTED_CATEGORY');

	-- level range
	local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet');
	if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
		local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit');
		local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit');
		local opValue = GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit);
		if opValue ~= '' then
			local opName = 'CT_UseLv';
			if category == 'OPTMisc' then
				opName = 'Level';
			end
			optionName[#optionName + 1] = opName;
			optionValue[#optionValue + 1] = opValue;
			optionSet[opName] = true;
		end
	end

	-- grade
	local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet');
	if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
		local checkStr = '';
		local matchCnt, lastMatch = 0, nil;
		local childCnt = gradeCheckSet:GetChildCount();
		for i = 0, childCnt - 1 do
			local child = gradeCheckSet:GetChildByIndex(i);
			if string.find(child:GetName(), 'gradeCheck_') ~= nil then
				AUTO_CAST(child);
				if child:IsChecked() == 1 then
					local grade = string.sub(child:GetName(), string.find(child:GetName(), '_') + 1);
					checkStr = checkStr..grade..';';
					matchCnt = matchCnt + 1;
					lastMatch = grade;
				end
			end
		end
		if checkStr ~= '' then
			if matchCnt == 1 then
				checkStr = checkStr..lastMatch;
			end
			local opName = 'CT_ItemGrade';
			optionName[#optionName + 1] = opName;
			optionValue[#optionValue + 1] = checkStr;
			optionSet[opName] = true;
		end
	end

	-- random option flag
	local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet');
	if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
		local ranOpName, ranOpValue;
		local appCheck_0 = GET_CHILD(appCheckSet, 'appCheck_0');
		if appCheck_0:IsChecked() == 1 then
			ranOpName = 'Random_Item';
			ranOpValue = '2'
		end

		local appCheck_1 = GET_CHILD(appCheckSet, 'appCheck_1');
		if appCheck_1:IsChecked() == 1 then
			ranOpName = 'Random_Item';
			ranOpValue = '1'
		end

		if ranOpName ~= nil then
			optionName[#optionName + 1] = ranOpName;
			optionValue[#optionValue + 1] = ranOpValue;
			optionSet[ranOpName] = true;
		end
	end

	-- detail setting
	local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet');
	if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
		local curCnt = detailOptionSet:GetUserIValue('ADD_SELECT_COUNT');
		for i = 0, curCnt do
			local selectSet = GET_CHILD_RECURSIVELY(detailOptionSet, 'SELECT_'..i);
			if selectSet ~= nil and selectSet:IsVisible() == 1 then
				local nameList = GET_CHILD(selectSet, 'groupList');
				local opName = nameList:GetSelItemKey();
				if opName ~= '' then
					local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'), GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));				
					if opValue ~= '' and optionSet[opName] == nil then
						optionName[#optionName + 1] = opName;
						optionValue[#optionValue + 1] = opValue;
						optionSet[opName] = true;
					end
				end
			end
		end
	end

	-- option group
	local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet');
	if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
		local curCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT');		
		for i = 0, curCnt do
			local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_'..i);
			if selectSet ~= nil then
				local nameList = GET_CHILD(selectSet, 'nameList');
				local opName = nameList:GetSelItemKey();
				if opName ~= '' then
					local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'), GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'));
					if opValue ~= '' and optionSet[opName] == nil then
						optionName[#optionName + 1] = opName;
						optionValue[#optionValue + 1] = opValue;
						optionSet[opName] = true;
					end
				end
			end
		end
	end

	-- gem option
	local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet');
	if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
		local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit');
		local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit');
		local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit');
		local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit');
		if category == 'Gem' then
			local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
			if opValue ~= '' then
				optionName[#optionName + 1] = 'GemLevel';
				optionValue[#optionValue + 1] = opValue;
				optionSet['GemLevel'] = true;
			end

			local roastOpValue = GET_MINMAX_QUERY_VALUE_STRING(roastingMinEdit, roastingMaxEdit);			
			if roastOpValue ~= '' then
				optionName[#optionName + 1] = 'GemRoastingLv';
				optionValue[#optionValue + 1] = roastOpValue;
				optionSet['GemRoastingLv'] = true;
			end
		elseif category == 'Card' then
			local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit);
			if opValue ~= '' then
				optionName[#optionName + 1] = 'CardLevel';
				optionValue[#optionValue + 1] = opValue;
				optionSet['CardLevel'] = true;
			end
		end
	end

	return optionName, optionValue;
end

function MARKETPRICEBOARD_CAN_INTERCEPT_MARKET()
    local frame=ui.GetFrame("market")
    local key,value=GET_SEARCH_OPTION(frame)
    if(g.ignore==false)then
        return true
    end
    if frame==nil then
        return  session.market.GetCurPage()==0 
    else
        return  session.market.GetCurPage()==0 and #key == 0

    end
end
function MARKETPRICEBOARD_ON_MARKET_ITEM_LIST(frame)
    EBI_try_catch{
        try = function()
            MARKETPRICEBOARD_DBGOUT("COME")

            local count = session.market.GetItemCount();
            g.known=g.known or {}
            for i = 0, count - 1 do
                local marketItem = session.market.GetItemByIndex(i);
                local itemObj = GetIES(marketItem:GetObject());
                if(g.known[itemObj.ClassName]==nil and MARKETPRICEBOARD_CAN_INTERCEPT_MARKET())then
                    g.prices[itemObj.ClassName]= g.prices[itemObj.ClassName]or {}
                    g.prices[itemObj.ClassName].dirty=true
                    g.known[itemObj.ClassName]=true
                end
                if(g.ignore==false or MARKETPRICEBOARD_CAN_INTERCEPT_MARKET())then
                    MARKETPRICEBOARD_DBGOUT("insert")
                    MARKETPRICEBOARD_NEWDATA(marketItem, itemObj)
                end
            end
            
            --次のページへ

            if( g.ignore==false and session.market.GetCurPage()<
                math.floor(session.market.GetTotalCount() / g.requestcount))then
                MARKETPRICEBOARD_DBGOUT("NEXT PAGE")
                ReserveScript(string.format("MARKETPRICEBOARD_REFRESHMARKET_SIMPLE(%d)",session.market.GetCurPage()+1),0.75)

            else
                local now=os.date(g.minutedateformat)

                if(g.ignore==false or (g.clsidlist~= nil and #g.clsidlist > 0 and g.prices[GetClassByType("Item",g.clsidlist[1]).ClassName].latestDate~=now))then
                    MARKETPRICEBOARD_UPDATEHILO(GetClassByType("Item",g.clsidlist[1]).ClassName)
                    table.remove(g.clsidlist, 1)

                    if(#g.clsidlist>0)then
                        ReserveScript(string.format("MARKETPRICEBOARD_REFRESHMARKET_SIMPLE(%d)",0),0.75)
                    else
                        ReserveScript(g.compfuncstr,0.1)
                    end
                    MARKETPRICEBOARD_UPDATEBOARD()
                else
                    if(MARKETPRICEBOARD_CAN_INTERCEPT_MARKET()) then
                        for k,_ in pairs(g.known) do
                            MARKETPRICEBOARD_UPDATEHILO(k)
                        end
                       
                    end
                end
           
            end
        
           
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end
function MARKETPRICEBOARD_NEWDATA(marketItem, itemObj)
    local name = itemObj.ClassName
    local data = deepcopy(g.prices[name]) 
    if(data==nil)then
        MARKETPRICEBOARD_LOADPRICE(name) 
        data= g.prices[name]  or {indication_bid = {}}
        MARKETPRICEBOARD_DBGOUT("DATA NIL")
    end
    local sellprice = marketItem:GetSellPrice();
    local sellcount = marketItem.count
    if (data.dirty == true or data.indication_bid==nil) then
        data.indication_bid = {}
       
        MARKETPRICEBOARD_DBGOUT("gene")
    end
    if (data.indication_bid["P" .. sellprice] == nil) then
        data.indication_bid["P" .. sellprice] = {price = sellprice, count = sellcount}
    else
        data.indication_bid["P" .. sellprice].count =
            data.indication_bid["P" .. sellprice].count + sellcount
    end
    local now=os.date(g.minutedateformat)
    local currentState = deepcopy(data.currentState) or {priceHigh="0",priceLow=g.max}
    if(data.dirty == true and currentState.priceClose==nil)then
        currentState={priceHigh="0",priceLow=g.max}
        currentState.priceClose = sellprice
        --g.prices.latestDate=now
        MARKETPRICEBOARD_DBGOUT("CLOSE NIL")
    end
  
   
    if (data.dirty == true) then
        currentState.priceClose = sellprice
        data.dirty = false
        
    end
    data.currentState = deepcopy(currentState)

    g.prices[name] = data
    MARKETPRICEBOARD_SAVEPRICE(name)
end
function MARKETPRICEBOARD_UPDATEHILO(name)
    local data = deepcopy(g.prices[name] )
    if(data==nil)then
        MARKETPRICEBOARD_LOADPRICE(name) 
        data= g.prices[name]  or {indication_bid = {}}
    end

    local now=os.date(g.minutedateformat)
    local currentState = deepcopy(data.currentState) or {priceHigh="0",priceLow=g.max}

    local sellprice=currentState.priceClose
    

    if g.prices[name].latestDate==nil or g.prices[name].latestDate~=now or currentState.priceClose==nil then
        currentState={priceHigh="0",priceLow=g.max,priceOpen=  currentState.priceClose,priceClose=  currentState.priceClose}
        currentState.priceClose = sellprice

        g.prices[name].latestDate=now
        MARKETPRICEBOARD_DBGOUT("UPPER")

    end
    if(currentState.priceOpen==nil)then
        currentState.priceOpen=sellprice
        MARKETPRICEBOARD_DBGOUT("UNDER")

    end
    
    --現在値の更新
    if IsGreaterThanForBigNumber(sellprice, currentState.priceHigh) == 1 then
        MARKETPRICEBOARD_DBGOUT("GREATER")
        currentState.priceHigh = sellprice
    end
    if IsLesserThanForBigNumber(sellprice, currentState.priceLow) == 1 and  currentState.priceLow~="0" then
        MARKETPRICEBOARD_DBGOUT("LESSER")
        currentState.priceLow = sellprice
    end

    local date=g.prices[name].latestDate
    local added=false
    local noadd=false
    local forhistory=deepcopy(currentState)
    --値段つかずの処理
    if(forhistory.priceClose=="0" or forhistory.priceClose== nil)then
        if(forhistory.priceOpen~="0" and forhistory.priceOpen~=nil)then
            forhistory.priceClose=forhistory.priceOpen
        else
            noadd=true
        end
    end
    if(noadd==false)then

        data.history=data.history or {}
        for k,v in pairs(data.history) do
            if(v.date==date)then
                data.history[k].date=date
                data.history[k].data=forhistory
                
                added=true
                MARKETPRICEBOARD_DBGOUT("added")
                break;
            end
        end
    end

    if(added==false)then
        MARKETPRICEBOARD_DBGOUT("created")
        dar=forhistory
        data.history[#data.history+1]={date=date,data=forhistory}
    end
    data.currentState = deepcopy(currentState)

    g.prices[name] = data
    MARKETPRICEBOARD_SAVEPRICE(name)
end
function MARKETPRICEBOARD_makeTimeStamp(dateString)
    --local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
    local xyear, xmonth, xday, xhour, xminute, 
        xseconds, xoffset, xoffsethour, xoffsetmin = dateString:match(pattern)
    local convertedTimestamp = os.time({year = xyear, month = xmonth, 
        day = xday, hour = xhour, min = xminute, sec = xseconds})
    local offset = xoffsethour * 60 + xoffsetmin
    if xoffset == "-" then offset = offset * -1 end
    return math.floor(convertedTimestamp + offset)
end
function MARKETPRICEBOARD_MARKET_INIT_CATEGORY(frame)	
	local marketCategory = GET_CHILD_RECURSIVELY(frame, 'marketCategory');
	local bgBox = GET_CHILD(marketCategory, 'bgBox');



	-- 첨 키면 통합 검색 키게 해달라고 하셨다
    local integrateRetreiveCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_IntegrateRetreive');
    if(integrateRetreiveCtrlset~=nil)then
    MARKETPRICEBOARD_MARKET_CATEGORY_CLICK_QUIET(integrateRetreiveCtrlset);
    end
end
function MARKETPRICEBOARD_MARKET_CATEGORY_CLICK_QUIET(ctrlset, ctrl, reqList, forceOpen)	
	local frame = ctrlset:GetTopParentFrame();
	frame:SetUserValue('SELECTED_SUB_CATEGORY', 'None');
	MARKET_OPTION_BOX_CLOSE_CLICK(frame);

	local prevSelectCategory = frame:GetUserValue('SELECTED_CATEGORY');
	local category = ctrlset:GetUserValue('CATEGORY');
	local foldimg = GET_CHILD(ctrlset, 'foldimg');
	local cateListBox = GET_CHILD_RECURSIVELY(frame, 'cateListBox');
	DESTROY_CHILD_BYNAME(cateListBox, 'detailBox');

	if forceOpen ~= true and (prevSelectCategory == 'None' or prevSelectCategory == category) then
		if foldimg:GetUserValue('IS_PLUS_IMAGE') == 'YES' then
			foldimg:SetImage('viewunfold');
			foldimg:SetUserValue('IS_PLUS_IMAGE', 'NO');
			ALIGN_CATEGORY_BOX(ctrlset:GetParent(), ctrlset);
			return;
		end
	end
	frame:SetUserValue('isRecipeSearching', 0);

	-- color change
	local prevSelectCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_'..prevSelectCategory);
	if prevSelectCtrlset ~= nil then
		local bgBox = GET_CHILD(prevSelectCtrlset, 'bgBox');
		bgBox:SetSkinName('base_btn');

		local foldimg = GET_CHILD(prevSelectCtrlset, 'foldimg');		
		foldimg:SetImage('viewunfold');
		foldimg:SetUserValue('IS_PLUS_IMAGE', 'NO');
	
	end
	local bgBox = GET_CHILD(ctrlset, 'bgBox');
	bgBox:SetSkinName('baseyellow_btn');
	frame:SetUserValue('SELECTED_CATEGORY', category);

	-- fold img
	foldimg:SetImage('spreadclose');
	foldimg:SetUserValue('IS_PLUS_IMAGE', 'YES');
	
	local subCategoryList = GetMarketCategoryList(category);

	local detailBox = DRAW_DETAIL_CATEGORY(frame, ctrlset, subCategoryList, forceOpen);
	ALIGN_CATEGORY_BOX(ctrlset:GetParent(), ctrlset, detailBox);


end

function MARKETPRICEBOARD_REFRESHMARKET()
    EBI_try_catch{
        try = function()

            local frame = ui.GetFrame('marketpriceboard')
            if (frame == nil or not MARKETPRICEBOARD_ISINCITY()) then
                return
            end
            if(g.ignore==false)then
                ui.MsgBox("今はダメ")
                return
            end
            CHAT_SYSTEM("[MPB]価格情報取り込みを開始します。ESCを押し続けるとキャンセルします。")
            local gauge=frame:GetChild('gauge')
            tolua.cast(gauge,"ui::CGauge")


            MARKETPRICEBOARD_DBGOUT("GO")
            local obj = GET_CHILD_RECURSIVELY(frame,('slt'))
            local slotset = tolua.cast(obj, 'ui::CSlotSet')
            g.ignore = false
           
            session.market.ClearItems();
            session.market.ClearRecipeSearchList();
            MARKET_CLEAR_RECIPE_SEARCHLIST(ui.GetFrame("market"));
            MARKETPRICEBOARD_MARKET_INIT_CATEGORY(ui.GetFrame("market"))
            local clsidlist={}
            for i = 0, g.slots - 1 do
                local slot = slotset:GetSlotByIndex(i)
                if (slot ~= nil) then
                    local val = slot:GetUserValue('clsid')
                    local class = GetClassByType("Item", val)
                    
                    if(class~=nil)then
                        clsidlist[#clsidlist+1]=val
                    end 
                   

                end
            end
            gauge:SetMaxPoint(#clsidlist)
            MARKETPRICEBOARD_REFRESHMARKETITEM(clsidlist,"MARKETPRICEBOARD_REFRESHMARKET_END()")
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end
function MARKETPRICEBOARD_REFRESHMARKETSINGLE(clsid)
    EBI_try_catch{
        try = function()
            if(g.ignore==false or not MARKETPRICEBOARD_ISINCITY())then
                return
            end
            local class = GetClassByType("Item", clsid)
            if(class==nil)then
                return
            end 
            g.ignore = false
            g.clsidlist={clsid}
            g.known={}
            MARKET_CLEAR_RECIPE_SEARCHLIST(ui.GetFrame("market"));
            MARKETPRICEBOARD_MARKET_INIT_CATEGORY(ui.GetFrame("market"))
            MARKETPRICEBOARD_REFRESHMARKETITEM({clsid},"MARKETPRICEBOARD_REFRESHMARKET_END()")
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end
function MARKETPRICEBOARD_REFRESHMARKET_SIMPLE(page)

    MARKETPRICEBOARD_REFRESHMARKETITEM(g.clsidlist,g.compfuncstr,page)
end
function MARKETPRICEBOARD_REFRESHMARKETITEM(clsidlist,compfuncstr,page)
    EBI_try_catch{
        try = function()
            local class = GetClassByType("Item", clsidlist[1])
            if 1 == keyboard.IsKeyPressed("ESCAPE") then
                CHAT_SYSTEM("[MPB]キャンセルしました")
                g.ignore=true
                g.compfuncstr=nil
                g.clsidlist=nil
                return;
                
            end
            
            if(class~=nil)then
                local frame = ui.GetFrame('marketpriceboard')
                if (frame == nil) then
                    return
                end
                local gauge=frame:GetChild('gauge')
                tolua.cast(gauge,"ui::CGauge")
                gauge:SetCurPoint(gauge:GetMaxPoint()-#clsidlist)
                page=page or 0
                g.compfuncstr=compfuncstr
                g.clsidlist=clsidlist
                MARKETPRICEBOARD_DBGOUT(class.Name)
                local realname = dictionary.ReplaceDicIDInCompStr(class.Name)
                realname = utf8sub(realname, 1, math.min(#realname, 16))
                MarketSearch(page+1, 0, realname, "", {}, {}, g.requestcount);
            end
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end
function MARKETPRICEBOARD_REFRESHMARKET_END()
    g.ignore = true
    local frame = ui.GetFrame('marketpriceboard')
    if (frame == nil) then
        return
    end
    local gauge=frame:GetChild('gauge')
    tolua.cast(gauge,"ui::CGauge")
    gauge:SetCurPoint(0)
    MARKETPRICEBOARD_UPDATEBOARD()
    MARKETPRICEBOARD_UPDATEDETAIL()
end
function MARKETPRICEBOARD_INIT_FRAME(frame)
    EBI_try_catch{
        try = function()
            if (frame == nil) then
                frame = ui.GetFrame(g.framename)
            end
            MARKETPRICEBOARD_DBGOUT("INIT FRAME")
            
            frame:SetEventScript(ui.LBUTTONUP, 'MARKETPRICEBOARD_END_DRAG')
            frame:Resize(380, 610)
            local obj = frame:CreateOrGetControl('button', 'refresh', 20, 60, 70, 40)
            obj:SetText("refresh")
            obj:SetEventScript(ui.LBUTTONDOWN, "MARKETPRICEBOARD_REFRESHMARKET")
            local obj = frame:CreateOrGetControl('button', 'clear', 90, 60, 70, 40)
            obj:SetText("clear")
            obj:SetEventScript(ui.LBUTTONDOWN, "MARKETPRICEBOARD_CLEAR")
            
            local gbox=frame:CreateOrGetControl('groupbox', 'gbox', 30, 120, 64*5+20, 64*7)
            tolua.cast(gbox,"ui::CGroupBox")
            gbox:EnableScrollBar(1)
            local obj = gbox:CreateOrGetControl('slotset', 'slt', 0, 0, 0, 0)
            if (obj == nil) then
                CHAT_SYSTEM('nil')
            end
            local gauge=frame:CreateOrGetControl('gauge', 'gauge', 170, 80, 200, 20)
            tolua.cast(gauge,"ui::CGauge")

            local slotset = tolua.cast(obj, 'ui::CSlotSet')
            local slotCount = g.slots
            slotset:SetColRow(g.columns, g.rows)
            slotset:SetSlotSize(64, 64)
            slotset:EnableDrag(0)
            slotset:EnableDrop(1)
            slotset:EnablePop(1)
            slotset:SetSpc(0, 0)
            slotset:SetSkinName('invenslot2')
            slotset:SetEventScript(ui.DROP, 'MARKETPRICEBOARD_ON_DROP')
            slotset:CreateSlots()
            for i = 0, slotCount - 1 do
                local slot = slotset:GetSlotByIndex(i)
                
                slot:SetEventScript(ui.RBUTTONUP, 'MARKETPRICEBOARD_ON_RCLICK')
                slot:SetEventScriptArgNumber(ui.RBUTTONUP, i)
            
            end
            MARKETPRICEBOARD_LOAD_SETTINGS()
            MARKETPRICEBOARD_LOADFROMSTRUCTURE(frame)
           
            MARKETPRICEBOARD_DBGOUT("END INIT FRAME")
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end
function MARKETPRICEBOARD_CLEAR()
    g.prices={}
    MARKETPRICEBOARD_UPDATEBOARD()
end
function MARKETPRICEBOARD_GET_UPDOWN(className)
    local data=MARKETPRICEBOARD_AGGREGATE_DAILY(className)
    if(data==nil or #data<=1)then
        return 0
    end
    if(IsGreaterThanForBigNumber(data[#data].data.priceClose,data[#data-1].data.priceClose)==1 )then
        return 1
    end
    if(IsLesserThanForBigNumber(data[#data].data.priceClose,data[#data-1].data.priceClose)==1 )then
        return -1
    end
    return 0
end
function MARKETPRICEBOARD_GET_CHANGE(className)
    local data=MARKETPRICEBOARD_AGGREGATE_DAILY(className)
    if(data==nil or #data<=1 or data[#data].data.priceClose==nil or data[#data-1].data.priceClose==nil)then
        return "0"
    end
    return SumForBigNumberInt64(data[#data].data.priceClose,"-"..data[#data-1].data.priceClose or "0")
end
function MARKETPRICEBOARD_UPDATEBOARD()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local obj = GET_CHILD_RECURSIVELY(frame,'slt')
            local slotset = tolua.cast(obj, 'ui::CSlotSet')
            for i = 0, g.slots - 1 do
                local slot = slotset:GetSlotByIndex(i)
                if (slot ~= nil) then
                    local val = slot:GetUserValue('clsid')
                    local class = GetClassByType("Item", val)
                    if (class ~= nil) then
                        local className = GetClassByType("Item", val).ClassName
                        if (g.prices[className] ~= nil) then
                            local data = g.prices[className]
                            local bidrate = MARKETPRICEBOARD_GET_BIDRATE(className)
                            slot:RemoveAllChild()
                            local txt = slot:CreateOrGetControl("richtext", "count", 0, 0, slot:GetWidth(), 16)
                            local col="#FFFFFF"
                            local updown=MARKETPRICEBOARD_GET_UPDOWN(className)
                            if(updown==-1)then
                                col="#FF0000"
                            elseif updown == 1 then
                                col="#00FF77"
                            end
                            txt:SetGravity(ui.RIGHT, ui.TOP)
                            txt:EnableHitTest(0)
                            txt:SetText("{ol}{"..col.."}{s16}" .. bidrate.count)
                            txt:ShowWindow(1)

                            local txtchange = slot:CreateOrGetControl("richtext", "change", 0, 0, slot:GetWidth(), 16)
                            
                            local change=MARKETPRICEBOARD_GET_CHANGE(className)
                            local str="{ol}{"..col.."}{s16}"..MARKETPRICEBOARD_SHORTPRICE(change)
                            if(IsGreaterThanForBigNumber(change,"0")==1)then
                                str="{img green_up_arrow 14 14}{ol}{"..col.."}{s16}"..MARKETPRICEBOARD_SHORTPRICE(change):gsub("-","")
                            elseif IsLesserThanForBigNumber(change,"0") == 1 then
                            
                                str="{img red_down_arrow 14 14}{ol}{"..col.."}{s16}"..MARKETPRICEBOARD_SHORTPRICE(change):gsub("-","")
                            end
                            txtchange:SetGravity(ui.RIGHT, ui.CENTER_VERT)
                            txtchange:EnableHitTest(0)

                            txtchange:SetText(str)
                            txtchange:ShowWindow(1)
                            local txtprice = slot:CreateOrGetControl("richtext", "price", 0, 0, slot:GetWidth(), 16)
                            txtprice:SetGravity(ui.RIGHT, ui.BOTTOM)
                            txtprice:EnableHitTest(0)
                            txtprice:SetText("{ol}{"..col.."}{s20}" .. MARKETPRICEBOARD_SHORTPRICE(bidrate.price))
                            txtprice:ShowWindow(1)
                        end
                    end
                end
            end
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end
function MARKETPRICEBOARD_SAVEPRICE(classname)
    savetofile(g.basePath.."/price_"..tostring(GetServerGroupID()).."_"..classname..".lua",g.prices[classname])
end
function MARKETPRICEBOARD_LOADPRICE(classname)
    g.prices=g.prices or {}
    g.prices[classname]=
    loadfromfile(g.basePath.."/price_"..tostring(GetServerGroupID()).."_"..classname..".lua")
    
    --修正処置
    g.prices[classname]=g.prices[classname]or {indication_bid={}}
    g.prices[classname].history=g.prices[classname].history or {}
    local fixed=false
    local i=1
    local lim=#g.prices[classname].history
    while i <= #g.prices[classname].history do
        local v=g.prices[classname].history[i]
        if(v.data.priceClose==nil)then
            
            table.remove(g.prices[classname].history,i)
            fixed=true
        else
            
            if(v.data==nil or v.data.priceHigh==nil or v.data.priceLow==nil)then
                g.prices[classname].history[i].data=g.prices[classname].history[i].data or 
                {priceOpen=v.data.priceClose or "0",
                priceClose=v.data.priceClose or "0"}
                g.prices[classname].history[i].data.priceLow=v.data.priceClose or "0"
                g.prices[classname].history[i].data.priceHigh=v.data.priceClose or "0"
                
                fixed=true
            end
            if(v.data.priceOpen==nil)then
                g.prices[classname].history[i].data.priceOpen=v.data.priceClose
                fixed=true
            end
        end
        i=i+1
    end
    if fixed then
       
        MARKETPRICEBOARD_SAVEPRICE(classname)
    end
end
function MARKETPRICEBOARD_LOADALLPRICE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local obj = GET_CHILD_RECURSIVELY(frame,'slt')
            local slotset = tolua.cast(obj, 'ui::CSlotSet')
            for i = 0, g.slots - 1 do
                local slot = slotset:GetSlotByIndex(i)
                if (slot ~= nil) then
                    local val = slot:GetUserValue('clsid')
                    local class = GetClassByType("Item", val)
                    if (class ~= nil) then
                        local className = GetClassByType("Item", val).ClassName
                        MARKETPRICEBOARD_LOADPRICE(className)
                    end
                end
            end
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }
end

function MARKETPRICEBOARD_SHORTPRICE(price)
    local suffix = ""
    if(price==nil)then
        return "0"
    end
    if (#price > 4) then
        suffix = "k"
        price = string.sub(price, 1, -4)
    end
    if (#price > 4) then
        suffix = "M"
        price = string.sub(price, 1, -4)
    end
    if (#price > 4) then
        suffix = "G"
        price = string.sub(price, 1, -4)
    end
    return price .. suffix
end

function MARKETPRICEBOARD_GET_BIDRATE(className)
    local bidindication
    for k, v in pairs(g.prices[className].indication_bid) do
        if (bidindication == nil or IsLesserThanForBigNumber(v.price, bidindication.price) == 1) then
            bidindication = v

        end
    end
    return bidindication or {price = "0", count = 0}
end
function MARKETPRICEBOARD_GET_BIDRATE_ASARRAY(className)
    local bidindication = {}
    local idx = 1
    for k, v in pairs(g.prices[className].indication_bid) do
        bidindication[idx] = v
        idx = idx + 1
    end
    table.sort(bidindication,
        function(a, b)
            return IsLesserThanForBigNumber(a.price, b.price) == 1
        end)
    return bidindication
end
function MARKETPRICEBOARD_ON_OPEN_MARKET()
    local frame = ui.GetFrame('market')
    local obj = frame:CreateOrGetControl('button', 'openbtn_priceboard', 340, 30, 70, 40)
    obj:SetText("PriceBoard")
    obj:SetEventScript(ui.LBUTTONUP, "MARKETPRICEBOARD_TOGGLE_FRAME")
end
function MARKETPRICEBOARD_ON_DROP(frame, ctrl)
    EBI_try_catch{
        try = function()
            local liftIcon = ui.GetLiftIcon()
            local liftParent = liftIcon:GetParent()
            local slot = tolua.cast(ctrl, 'ui::CSlot')
            local iconInfo = liftIcon:GetInfo()
            
            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID())
            if(g.ignore==false)then
                ui.MsgBox("今はダメ")
                return
            end
            
            
            if iconInfo == nil or slot == nil or invitem == nil then
                
                return
            end
            local itemobj = GetIES(invitem:GetObject())
            if (iconInfo:GetIESID() == '0') then
                if (liftParent:GetName() == 'pic') then
                    local parent = liftParent:GetParent()
                    while (string.starts(parent:GetName(), 'ITEM') == false) do
                        parent = parent:GetParent()
                        if (parent == nil) then
                            CHAT_SYSTEM('失敗')
                            return
                        end
                    end
                    
                    local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
                    local mySession = session.GetMySession()
                    local cid = mySession:GetCID()
                    local count = session.market.GetItemCount()
                    local marketItem = session.market.GetItemByIndex(row)
                    local obj = GetIES(marketItem:GetObject())
                    
                    
                    -- アイコンを生成
                    local invitems = GetClassByType("Item", obj.ClassID)
                    -- IESを生成
                    if (invitems == nil) then
                        
                        else
                        slot:SetUserValue('clsid', tostring(obj.ClassID))
                        
                        SET_SLOT_ITEM_CLS(slot, invitems)
                        SET_SLOT_STYLESET(slot, invitems)
                    end
                else
                    
                    return
                end
            else
                
                
                local invitems = GetClassByType("Item", itemobj.ClassID)
                if (invitems ~= nil) then
                    
                    slot:SetUserValue('clsid', tostring(itemobj.ClassID))
                    --slot:SetUserValue("iesid",iconInfo:GetIESID())
                    SET_SLOT_ITEM_CLS(slot, invitems)
                    SET_SLOT_STYLESET(slot, invitems)
                end
            end
            MARKETPRICEBOARD_SAVETOSTRUCTURE()
            MARKETPRICEBOARD_SAVE_SETTINGS()
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end

function MARKETPRICEBOARD_ON_RCLICK(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            if keyboard.IsKeyPressed('LSHIFT') == 1 then
                if(g.ignore==false)then
                    ui.MsgBox("今はダメ")
                    return
                end
                --削除モード
                slot:SetUserValue('clsid', nil)
                MARKETPRICEBOARD_SAVE_SETTINGS()
                MARKETPRICEBOARD_LOADFROMSTRUCTURE()
                
            else
                local clsid = slot:GetUserValue('clsid')
                MARKETPRICEBOARD_SHOWDETAIL(clsid)
                MARKETPRICEBOARD_REFRESHMARKETSINGLE(clsid)
 
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
            print(error)
        end
    }
end

function MARKETPRICEBOARD_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('marketpriceboard')
    if (frame == nil) then
        return
    end
    local slotset = GET_CHILD_RECURSIVELY(frame,'slt')
    if (slotset == nil) then
        return
    end
    slotset = tolua.cast(slotset, 'ui::CSlotSet')
    
    for i = 0, g.slots - 1 do
        local slot = slotset:GetSlotByIndex(i)
        if (slot ~= nil) then
            local val = slot:GetUserValue('clsid')
            g.settings.items[i + 1] = {clsid = tonumber(val)}
        
        else
            
            g.settings.items[i + 1] = nil
        end
    end
end
function MARKETPRICEBOARD_LOADFROMSTRUCTURE(frame)
    local frame = ui.GetFrame('marketpriceboard')
    if (frame == nil or g.settings.items == nil) then
        return
    end
    
    local obj = GET_CHILD_RECURSIVELY(frame,'slt')
    local slotset = tolua.cast(obj, 'ui::CSlotSet')
    if (slotset == nil) then
        return
    end
    slotset:ClearIconAll()
    
    for i = 0, g.slots - 1 do
        -- statements
        local slot = slotset:GetSlotByIndex(i)
        if (slot ~= nil) then
            slot:SetText("")
            slot:RemoveAllChild();
        end
    end
    for i = 1, #g.settings.items do
        EBI_try_catch{
            try = function()
                
                local item = g.settings.items[i]
                local slot = slotset:GetSlotByIndex(i - 1)
                if (item ~= nil) then
                    
                   
                    if (item['clsid'] ~= nil) then
                        slot:SetUserValue('clsid', tostring(item['clsid']))
                        -- アイコンを生成
                        local invitem = GetClassByType("Item", item['clsid'])
                        
                        SET_SLOT_ITEM_CLS(slot, invitem)
                        SET_SLOT_STYLESET(slot, invitem)
                    end                    
                end
            end,
            catch = function(error)
                CHAT_SYSTEM(error)
            end
        }
    end
    MARKETPRICEBOARD_UPDATEBOARD()
end

--フレーム場所保存処理
function MARKETPRICEBOARD_END_DRAG()
    g.settings.position.x = g.frame:GetX()
    g.settings.position.y = g.frame:GetY()
    MARKETPRICEBOARD_SAVE_SETTINGS()
end
--チャットコマンド処理（acutil使用時）
function MARKETPRICEBOARD_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = L_("Usagemsg")
        return ui.MsgBox(msg, "", "Nope")
    end
    -- if cmd == "on" then
    --     g.settings.ebi=true
    --     MARKETPRICEBOARD_SAVE_SETTINGS()
    --     CHAT_SYSTEM("[MPB]EBI ENABLED")
    --     return
	-- end
    -- if cmd == "off" then
    --     g.settings.ebi=false
    --     MARKETPRICEBOARD_SAVE_SETTINGS()
    --     CHAT_SYSTEM("[MPB]EBI DISABLED")
    --     return
    -- end
    if cmd == "track" then
        MARKETPRICEBOARD_EBI_TRACKER()
        return
    end
    CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
end
function MARKETPRICEBOARD_EBI_TRACKER()
    if MARKETPRICEBOARD_ISINCITY() then

    MARKETPRICEBOARD_REFRESHMARKET()
    end
end
function MARKETPRICEBOARD_ISINCITY()
    local mapClsName = session.GetMapName();

    if(mapClsName ==  "c_Klaipe" or mapClsName ==  "c_fedimian" or mapClsName ==  "c_orsha")then
        return true
    end
    return false;
end

function MARKETPRICEBOARD_SHOWDETAIL(clsid)
    EBI_try_catch{
        try = function()
            local detailframe = ui.GetFrame("marketpriceboarddetail")
            if (defailframe ~= nil) then
                ui.DestroyFrame("marketpriceboarddetail")
            
            end
            

            detailframe = ui.CreateNewFrame("marketpriceboard", "marketpriceboarddetail")
            detailframe:ShowWindow(1)
            detailframe:Resize(500,600)
            local slot = detailframe:CreateOrGetControl("slot", "itemslot", 30, 70, 64, 64)
			tolua.cast(slot, "ui::CSlot")
			slot:ClearIcon()
            local class = GetClassByType("Item", clsid)
            if(class~=nil)then
                local data = g.prices[class.ClassName]
    
                local txtitem = detailframe:CreateOrGetControl("richtext", "itemname", 100, 70, 200, 64)
                local gbox=detailframe:CreateOrGetControl("groupbox","gbox",20,170,200,18*12)
                tolua.cast(gbox,"ui::CGroupBox")
                txtitem:SetText("{ol}{#FFFFFF}{s20}"..class.Name)
                SET_SLOT_ITEM_CLS(slot, class)
                SET_SLOT_STYLESET(slot, class)
                detailframe:SetUserValue("clsid",clsid)
                if (data == nil) then
                    MARKETPRICEBOARD_DBGOUT("null")
                    gbox:RemoveAllChild()
                    return
                end


                MARKETPRICEBOARD_UPDATE_CHART_OPTION(detailframe)
                MARKETPRICEBOARD_UPDATEDETAIL()
            end
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }

end
function MARKETPRICEBOARD_UPDATEDETAIL()

    local detailframe = ui.GetFrame("marketpriceboarddetail")
    local gbox=detailframe:CreateOrGetControl("groupbox","gbox",20,170,200,18*12)
    local clsid=detailframe:GetUserIValue("clsid")
    local class = GetClassByType("Item", clsid)
    local data = g.prices[class.ClassName]
    tolua.cast(gbox,"ui::CGroupBox")
    gbox:RemoveAllChild()
    gbox:SetSkinName("test_gray_button")
    local txtindicate = gbox:CreateOrGetControl("richtext", "labelindicate", 0, 10, 240, 64)
    txtindicate:SetText("{ol}{#FFFFFF}{s20}売気配")
    txtindicate:SetGravity(ui.CENTER_HORZ,ui.TOP)
    local bidrate = MARKETPRICEBOARD_GET_BIDRATE_ASARRAY(class.ClassName)
    --8本板
    for i = 1, 8 do
        local txtcount = gbox:CreateOrGetControl("richtext", "count_bid_" .. tostring(i), 20, (i-1) * 20+40, 150, 18)
        local txtprice = gbox:CreateOrGetControl("richtext", "price_bid_" .. tostring(i), 90, (i-1) * 20+40, 150, 18)
        
        txtcount:SetText("")
        txtprice:SetText("")
        
    end
    for i = 1,8 do
        local ri=8-i+1
        local txtcount = gbox:GetChild("count_bid_" .. tostring(ri))
        local txtprice = gbox:GetChild("price_bid_" .. tostring(ri))
        if (bidrate[i] ~= nil) then
            txtcount:SetText("{ol}{#FFFFFF}{s18}" .. bidrate[i].count)
            txtprice:SetText("{ol}{#FFFFFF}{s18}" .. MARKETPRICEBOARD_SHORTPRICE(bidrate[i].price))
        end
    end
    -- info
    local txtupperlimit=detailframe:CreateOrGetControl("richtext","upperlimit",20,400,200,18)
    txtupperlimit:SetText("{ol}{#FFFFFF}{s16}値幅制限上限:")
    local txtunderlimit=detailframe:CreateOrGetControl("richtext","underlimit",20,420,200,18)
    txtunderlimit:SetText("{ol}{#FFFFFF}{s16}値幅制限下限:")
    local txtavg=detailframe:CreateOrGetControl("richtext","avg",20,440,200,18)
    txtavg:SetText("{ol}{#FFFFFF}{s16}平均取引値　 :")

    local price=MARKETPRICEBOARD_AGGREGATE_DAILY(class.ClassName)
    if(price[#price]~=nil and #price >= 2 and price[#price].data~=nil)then
        local txthigh=detailframe:CreateOrGetControl("richtext","high",20,460,200,18)
        txthigh:SetText("{ol}{#FFFFFF}{s16}日中高値　 　 :"..MARKETPRICEBOARD_SHORTPRICE(price[#price].data.priceHigh or "0"))
        local txtlow=detailframe:CreateOrGetControl("richtext","low",20,480,200,18)
        txtlow:SetText("{ol}{#FFFFFF}{s16}日中安値　　  :"..MARKETPRICEBOARD_SHORTPRICE(price[#price].data.priceLow or "0"))
        local txtopen=detailframe:CreateOrGetControl("richtext","open",20,500,200,18)
        txtopen:SetText("{ol}{#FFFFFF}{s16}日中始値　 　 :"..MARKETPRICEBOARD_SHORTPRICE(price[#price].data.priceOpen or "0"))
        local txtclose=detailframe:CreateOrGetControl("richtext","close",20,520,200,18)
        txtclose:SetText("{ol}{#FFFFFF}{s16}日中終値　　  :"..MARKETPRICEBOARD_SHORTPRICE(price[#price].data.priceClose or "0"))
        local txtprevclose=detailframe:CreateOrGetControl("richtext","prevclose",20,540,200,18)
        txtprevclose:SetText("{ol}{#FFFFFF}{s16}前日終値　　  :"..MARKETPRICEBOARD_SHORTPRICE(price[#price-1].data.priceClose or "0"))
    end
    local itemProp = geItemTable.GetPropByName(class.ClassName);
    local price=0
    if itemProp ~= nil then
		price = geItemTable.GetSellPrice(itemProp);
    
    end
    local txtsell=detailframe:CreateOrGetControl("richtext","sell",20,560,200,18)
    txtsell:SetText("{ol}{#FFFFFF}{s16}店頭売値　　  :"..tostring(price))
    local invItem=session.GetInvItemByName(class.ClassName)
    --インベントリ内にアイテムがあるなら値幅制限情報が取得できる
    if invItem ~= nil then
        MARKETPRICEBOARD_DBGOUT("request")
        market.ReqSellMinMaxInfo(invItem:GetIESID());

    end
    -- chart
    local chart = detailframe:CreateOrGetControl("groupbox", "chart", 250, 240, 240, 200)
    tolua.cast(gbox,"ui::CGroupBox")
    chart:RemoveAllChild()

    MARKETPRICEBOARD_RENDER_CHART()
end
function MARKETPRICEBOARDDETAIL_CLOSE(frame)
    frame:ShowWindow(0)
end
function MARKETPRICEBOARD_ON_MARKET_MINMAX_INFO(frame, msg, argStr, argNum)
    local detailframe=ui.GetFrame("marketpriceboarddetail")
    if(detailframe==nil)then
        return
    end
    local tokenList = TokenizeByChar(argStr, ";");
    local minStr = tokenList[1];
    local minAllow = tokenList[2];
    local maxStr = tokenList[3];
    local maxAllow = tokenList[4];
    local avg = tokenList[5];
    local txtupperlimit=detailframe:GetChild("upperlimit")
    txtupperlimit:SetText("{ol}{#FFFFFF}{s16}値幅制限上限:"..MARKETPRICEBOARD_SHORTPRICE(maxAllow))
    local txtunderlimit=detailframe:GetChild("underlimit")
    txtunderlimit:SetText("{ol}{#FFFFFF}{s16}値幅制限下限:"..MARKETPRICEBOARD_SHORTPRICE(minAllow))
    local txtavg=detailframe:GetChild("avg")
    txtavg:SetText("{ol}{#FFFFFF}{s16}平均取引値　 :"..MARKETPRICEBOARD_SHORTPRICE(avg))
end
function MARKETPRICEBOARD_RENDER_CHART(detailframe)
    EBI_try_catch{
        try = function()
            if(detailframe==nil)then
                 detailframe = ui.GetFrame("marketpriceboarddetail")
            end
            local chart = detailframe:GetChild("chart")

            tolua.cast(chart,"ui::CGroupBox")
            
            chart:SetUserValue("clsid",detailframe:GetUserIValue("clsid"))
            chart:EnableScrollBar(0)
            MARKETPRICEBOARD_RENDER_CHART_IMPL(chart,detailframe:GetUserIValue("clsid"))
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }

end
local function GET_LOCAL_MOUSE_POS(ctrl)
    if(ctrl==nil)then
        return 0,0
    end
	local topFrame = ctrl:GetTopParentFrame();
	local pt = topFrame:ScreenPosToFramePos(mouse.GetX(), mouse.GetY());
	local x = pt.x - ctrl:GetGlobalX();
	local y = pt.y - ctrl:GetGlobalY();
	return x, y;

end
function MARKETPRICEBOARD_RENDER_CHART_IMPL(chart,clsid)
    EBI_try_catch{
        try = function()
            MARKETPRICEBOARD_DBGOUT("RENDER")
            if(chart==nil)then
                return
            end
            --tolua.cast(chart,"ui::CGroupBox")

            local yoffset=8
            local offset=50

            local innerchart=chart:CreateOrGetControl("picture", "innerchart", offset, yoffset, chart:GetWidth()-offset-8, chart:GetHeight()-yoffset*2)
            tolua.cast(innerchart,"ui::CPicture")
   
            innerchart:CreateInstTexture()
            innerchart:FillClonePicture("FF000000");
            innerchart:EnableHitTest(1)

            innerchart:SetUserValue("clsid",clsid)
  
            chart:EnableHitTest(1)
 
            
            chart:SetSkinName("test_gray_button")
            if(innerchart:GetTopParentFrame():GetName()~="marketpriceboardlargechart")then
            innerchart:SetEventScript(ui.RBUTTONUP,"MARKETPRICEBOARD_CHART_ON_RCLICK")
            end
            innerchart:SetEventScript(ui.LBUTTONDOWN,"MARKETPRICEBOARD_INNER_ON_LBUTTONDOWN")
            innerchart:SetEventScript(ui.LBUTTONUP,"MARKETPRICEBOARD_INNER_ON_LBUTTONUP")
            innerchart:SetEventScript(ui.MOUSEWHEEL,"MARKETPRICEBOARD_INNER_ON_WHEEL")
            chart:SetOverSound('button_over');
            chart:SetClickSound('button_over');

            local class = GetClassByType("Item", clsid)

            local data = deepcopy(g.prices[class.ClassName])
            if(g.settings.charttimemode==1)then
                if g.isminutemode==false then
                    data.history=MARKETPRICEBOARD_AGGREGATE_HOURLY(class.ClassName)
                end
               
            elseif(g.settings.charttimemode==4)then
                data.history=MARKETPRICEBOARD_AGGREGATE_4HOURLY(class.ClassName)
            elseif (g.settings.charttimemode==10)then
                data.history=MARKETPRICEBOARD_AGGREGATE_DAILY(class.ClassName)
            end
                
            if(g.settings.concat==false)then
                data.history=MARKETPRICEBOARD_HISTORY_MAKESPACE(data.history)
            end

            
            MARKETPRICEBOARD_DBGOUT(tostring(#data.history))
            local w=6

            local minimum=g.maxint
            local maximum=0
            for i=#data.history,math.max(1,#data.history-g.chartlimit),-1 do
                local hist=data.history[i]
                local high,low,open,close
                if(hist==nil) then
                    MARKETPRICEBOARD_DBGOUT("FAIL"..tostring(i))
                    return
                end
                --MARKETPRICEBOARD_DBGOUT("da"..tostring(hist.data.priceHigh))
                high=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceHigh)
                low=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceLow)
                open=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceOpen)
                close=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceClose)
                minimum=math.min(minimum,low)
                maximum=math.max(maximum,high)
                
            end
            if(maximum-minimum<2)then
                minimum=maximum-1
                maximum=minimum+2
            end
            local minmaxheight=maximum-minimum
            
            local h=innerchart:GetHeight()-4

            MARKETPRICEBOARD_DBGOUT(tostring(#data.history))
            --upper under
            local upper = chart:CreateOrGetControl("richtext","textupper",0,0,0,16)
            local under = chart:CreateOrGetControl("richtext","textunder",0,0,0,16)
            upper:SetGravity(ui.LEFT,ui.TOP)
            under:SetGravity(ui.LEFT,ui.BOTTOM)
            upper:SetText("{ol}{#FFFFFF}{s18}" ..MARKETPRICEBOARD_SHORTPRICE(tostring(maximum).."0"))
            under:SetText("{ol}{#FFFFFF}{s18}" ..MARKETPRICEBOARD_SHORTPRICE(tostring(minimum).."0"))
            local prevclose=nil
            for i=#data.history,math.max(1,#data.history-g.chartlimit),-1 do
    
                --MARKETPRICEBOARD_DBGOUT("de")
                local hist=data.history[i]

                --candlestick
                local color
                local high,low,open,close
                high=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceHigh)
                low=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceLow)
                open=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceOpen)
                close=MARKETPRICEBOARD_SIMPLIFIEDINT(hist.data.priceClose)
                if g.settings.linemode~=true and open>close then
                    local swap=close
                    close=open
                    open=swap
                end

                if(IsGreaterThanForBigNumber(hist.data.priceOpen,hist.data.priceClose)==1)then
                    --up
                    color=0
                else
                    color=1
                end
                local height=((close-minimum)-(open-minimum))*h/minmaxheight
                local fixh=math.max(0,height)
                if(g.settings.linemode==true)then
                    if(prevclose~=nil)then
                        MARKETPRICEBOARD_DRAWLINE(
                            hist,
                            innerchart,
                            color,
                            (i-1)*(w+1)+w/2,
                            (h-(close-minimum)*h/minmaxheight),
                            i*(w+1)+w/2,
                            (h-(prevclose-minimum)*h/minmaxheight)
                        )
                    end
                else
                    MARKETPRICEBOARD_DRAWRECT(
                        hist,
                        innerchart,
                        color,
                        i*(w+1),
                        (h-(close-minimum)*h/minmaxheight),w,
                        fixh)
                    MARKETPRICEBOARD_DRAWRECT(
                        hist,
                        innerchart,
                        color,
                        i*(w+1)+w/2,h-(high-minimum)*h/minmaxheight,1,
                        ((high-minimum)-(low-minimum))*h/minmaxheight)
                end
                
                prevclose=close
            end
            innerchart:Invalidate()
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }

end
function MARKETPRICEBOARD_INNER_ON_LBUTTONDOWN(parent,ctrl, s, n)
   
    local x, y = GET_MOUSE_POS();
	ctrl:SetUserValue("MOUSE_X", x);
	ctrl:SetUserValue("MOUSE_Y", y);
    mouse.ChangeCursorImg("MOVE_MAP", 1);
    ctrl:RunUpdateScript("MARKETPRICEBOARD_INNERCHART_ON_MOUSEMOVE");	
    MARKETPRICEBOARD_RENDER_CHART_IMPL(ctrl:GetParent(),ctrl:GetUserIValue("clsid"))
end

function MARKETPRICEBOARD_INNER_ON_LBUTTONUP(parent,ctrl, s, n)
    MARKETPRICEBOARD_RENDER_CHART_IMPL(ctrl:GetParent(),ctrl:GetUserIValue("clsid"))
end

function MARKETPRICEBOARD_INNER_ON_WHEEL(parent,ctrl, s, n)

    local mx, my = GET_MOUSE_POS();

    local scrx= ctrl:GetUserIValue("SCROLL_X") or 0;
	local dx = 0;
    
    if(n>0)then
        dx=-10
    else
        dx=10
    end

	dx = dx * 2;
    scrx=math.max(0,scrx+dx)
    ctrl:SetUserValue("SCROLL_X", scrx);
	MARKETPRICEBOARD_RENDER_CHART_IMPL(ctrl:GetParent(),ctrl:GetUserIValue("clsid"))

end

function MARKETPRICEBOARD_CHART_ON_RCLICK(parent,ctrl, s, n)
    MARKETPRICEBOARD_CREATE_LARGE_CHART(ctrl:GetUserIValue("clsid"))
end
function MARKETPRICEBOARD_CREATE_LARGE_CHART(clsid)
    EBI_try_catch{
        try = function()
            local largeframe = ui.GetFrame("marketpriceboardlargechart")
            if (largeframe == nil) then
                largeframe = ui.CreateNewFrame("marketpriceboard", "marketpriceboardlargechart")
            end
            

            
            largeframe:SetUserValue("clsid",clsid)
            largeframe:ShowWindow(1)
            largeframe:Resize(800,600)
            local slot = largeframe:CreateOrGetControl("slot", "itemslot", 30, 70, 64, 64)
			tolua.cast(slot, "ui::CSlot")
			slot:ClearIcon()
            local class = GetClassByType("Item", clsid)
            if(class~=nil)then
                local data = g.prices[class.ClassName]
    
                local txtitem = largeframe:CreateOrGetControl("richtext", "itemname", 100, 70, 200, 64)
                local gbox=largeframe:CreateOrGetControl("groupbox","gbox",20,170,200,18*12)
                tolua.cast(gbox,"ui::CGroupBox")
                txtitem:SetText("{ol}{#FFFFFF}{s20}"..class.Name)
                SET_SLOT_ITEM_CLS(slot, class)
                SET_SLOT_STYLESET(slot, class)

                -- chart
                local chart = largeframe:CreateOrGetControl("groupbox", "chart", 20, 150, largeframe:GetWidth()-40,  largeframe:GetHeight()-180)
                tolua.cast(gbox,"ui::CGroupBox")
                chart:RemoveAllChild()

                MARKETPRICEBOARD_RENDER_CHART(largeframe)
                MARKETPRICEBOARD_UPDATE_CHART_OPTION(largeframe)
      
            end
        end,
        catch = function(error)
            MARKETPRICEBOARD_ERROUT(error)
        end
    }

end
function MARKETPRICEBOARD_INNERCHART_ON_MOUSEMOVE(ctrl)
    if mouse.IsLBtnPressed() == 0 then
		mouse.ChangeCursorImg("BASIC", 0);
		return 0;
    end
    local mx, my = GET_MOUSE_POS();
	local x = ctrl:GetUserIValue("MOUSE_X");
    local y = ctrl:GetUserIValue("MOUSE_Y");
    local scrx= ctrl:GetUserIValue("SCROLL_X") or 0;
	local dx = mx - x;
	local dy = my - y;
	dx = dx;
    dy = dy;
    scrx=math.max(0,scrx-dx)
    ctrl:SetUserValue("SCROLL_X", scrx);
    ctrl:SetUserValue("MOUSE_X", mx);
    ctrl:SetUserValue("MOUSE_Y", my);	
   
    MARKETPRICEBOARD_RENDER_CHART_IMPL(ctrl:GetParent(),ctrl:GetUserIValue("clsid"))
	return 1;
end

function MARKETPRICEBOARD_AGGREGATE_DAILY(classname)
    local data = g.prices[classname]
    local aggregate={}
    local idx=1
    local date=nil
    if(data==nil or data.history==nil)then
        return {history={}}
    end
    for k,v in ipairs(data.history) do
        local createnew=false
        if date == nil then
            createnew=true
        else
            local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
            local xyear, xmonth, xday, xhour, xminute, 
                xseconds, xoffset, xoffsethour, xoffsetmin = v.date:match(pattern)
            local xxyear, xxmonth, xxday, xxhour, xxminute, 
                xxseconds, xxoffset, xxoffsethour, xxoffsetmin = date:match(pattern)
            local datetime=MARKETPRICEBOARD_makeTimeStamp(v.date)
            if(xyear==xxyear and xmonth == xxmonth and xday==xxday)then
                createnew=false
            else
                createnew=true
            end
        end 
        if(createnew==true)then
            --MARKETPRICEBOARD_DBGOUT("NEW "..v.data.priceHigh.."/"..v.data.priceLow)
            date=v.date
            aggregate[idx]=deepcopy(v)
            MARKETPRICEBOARD_DBGOUT("NEW")
            idx=idx+1
            
        else
            MARKETPRICEBOARD_DBGOUT("OLD")
            local newdata=deepcopy(aggregate[idx-1])
            newdata.data.priceClose=v.data.priceClose
            --newdata.data.priceOpen=v.data.priceOpen
          --現在値の更新
            if newdata.data.priceHigh==nil or IsGreaterThanForBigNumber(v.data.priceHigh,newdata.data.priceHigh) == 1 then
                newdata.data.priceHigh = v.data.priceHigh
            end
            if newdata.data.priceLow ==nil or IsLesserThanForBigNumber(v.data.priceLow, newdata.data.priceLow) == 1 then
                newdata.data.priceLow = v.data.priceLow
            end
            aggregate[idx-1]=newdata
        end
    end
    return aggregate
end
function MARKETPRICEBOARD_AGGREGATE_HOURLY(classname)
    local data = g.prices[classname]
    local aggregate={}
    local idx=1
    local date=nil
    if(data==nil or data.history==nil)then
        return {history={}}
    end
    for k,v in ipairs(data.history) do
        local createnew=false
        if date == nil then
            createnew=true
        else
            local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
            local xyear, xmonth, xday, xhour, xminute, 
                xseconds, xoffset, xoffsethour, xoffsetmin = v.date:match(pattern)
            local xxyear, xxmonth, xxday, xxhour, xxminute, 
                xxseconds, xxoffset, xxoffsethour, xxoffsetmin = date:match(pattern)
            local datetime=MARKETPRICEBOARD_makeTimeStamp(v.date)
            if(xyear==xxyear and xmonth == xxmonth and xday==xxday and xhour==xxhour)then
                createnew=false
            else
                createnew=true
            end
        end 
        if(createnew==true)then
            --MARKETPRICEBOARD_DBGOUT("NEW "..v.data.priceHigh.."/"..v.data.priceLow)
            date=v.date
            aggregate[idx]=deepcopy(v)
            MARKETPRICEBOARD_DBGOUT("NEW")
            idx=idx+1
            
        else
            MARKETPRICEBOARD_DBGOUT("OLD")
            local newdata=deepcopy(aggregate[idx-1])
            newdata.data.priceClose=v.data.priceClose
            --newdata.data.priceOpen=v.data.priceOpen
          --現在値の更新
            if newdata.data.priceHigh==nil or IsGreaterThanForBigNumber(v.data.priceHigh,newdata.data.priceHigh) == 1 then
                newdata.data.priceHigh = v.data.priceHigh
            end
            if newdata.data.priceLow ==nil or IsLesserThanForBigNumber(v.data.priceLow, newdata.data.priceLow) == 1 then
                newdata.data.priceLow = v.data.priceLow
            end
            aggregate[idx-1]=newdata
        end
    end
    return aggregate
end
function MARKETPRICEBOARD_AGGREGATE_4HOURLY(classname)
    local data = g.prices[classname]
    local aggregate={}
    local idx=1
    local date=nil
    if(data==nil or data.history==nil)then
        return {history={}}
    end
    for k,v in ipairs(data.history) do
        local createnew=false
        if date == nil then
            createnew=true
        else
            local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
            local xyear, xmonth, xday, xhour, xminute, 
                xseconds, xoffset, xoffsethour, xoffsetmin = v.date:match(pattern)
            local xxyear, xxmonth, xxday, xxhour, xxminute, 
                xxseconds, xxoffset, xxoffsethour, xxoffsetmin = date:match(pattern)
            local datetime=MARKETPRICEBOARD_makeTimeStamp(v.date)
            if(xyear==xxyear and xmonth == xxmonth and xday==xxday and math.floor(xhour/4)==math.floor(xxhour/4))then
                createnew=false
            else
                createnew=true
            end
        end 
        if(createnew==true)then
            --MARKETPRICEBOARD_DBGOUT("NEW "..v.data.priceHigh.."/"..v.data.priceLow)
            date=v.date
            aggregate[idx]=deepcopy(v)
            MARKETPRICEBOARD_DBGOUT("NEW")
            idx=idx+1
            
        else
            MARKETPRICEBOARD_DBGOUT("OLD")
            local newdata=deepcopy(aggregate[idx-1])
            newdata.data.priceClose=v.data.priceClose
            --newdata.data.priceOpen=v.data.priceOpen
          --現在値の更新
            if newdata.data.priceHigh==nil or IsGreaterThanForBigNumber(v.data.priceHigh,newdata.data.priceHigh) == 1 then
                newdata.data.priceHigh = v.data.priceHigh
            end
            if newdata.data.priceLow ==nil or IsLesserThanForBigNumber(v.data.priceLow, newdata.data.priceLow) == 1 then
                newdata.data.priceLow = v.data.priceLow
            end
            aggregate[idx-1]=newdata
        end
    end
    return aggregate
end

function MARKETPRICEBOARD_HISTORY_MAKESPACE(history)
    local newhist={}
    local idx=1
    local date=nil
    
    local cur=history[1]
    local curdate=tostring(MARKETPRICEBOARD_makeTimeStamp(cur.date))
    local last=  history[#history]
    local lastdate=tostring(MARKETPRICEBOARD_makeTimeStamp(last.date))
    local useformat
    if(g.settings.charttimemode==10)then
        useformat=g.dateformatdaily
    elseif(g.settings.charttimemode==4)then
        useformat=g.dateformat
    else
        if(g.isminutemode==true)then
            useformat=g.minutedateformat
        else
            useformat=g.dateformat
        
        end
    end

    if(curdate==lastdate)then
        return {cur}
    end
    for k,v in ipairs(history) do

        
        local giveup=0
        local copy=false
        while giveup<100 do
            if(g.settings.charttimemode==10)then
                curdate=SumForBigNumberInt64(curdate,"86400")
            elseif(g.settings.charttimemode==4)then
                curdate=SumForBigNumberInt64(curdate,"14400")
            else
                if(g.isminutemode==true)then
                    curdate=SumForBigNumberInt64(curdate,"60")
                else
                    curdate=SumForBigNumberInt64(curdate,"3600")
                end
            end
            --少しずつインクリしていく
            giveup=giveup+1
            MARKETPRICEBOARD_DBGOUT(string.format("%d,%s",MARKETPRICEBOARD_makeTimeStamp(v.date),curdate))
            if(IsLesserThanForBigNumber(tostring(MARKETPRICEBOARD_makeTimeStamp(v.date)),curdate)==1)then
                -- pass
                --if(copy==false)then
                    MARKETPRICEBOARD_DBGOUT("create")
                    newhist[idx]={
                        date= os.date(useformat,tonumber(curdate)),
                        data={
                            priceLow=v.data.priceLow,
                            priceHigh=v.data.priceHigh,
                            priceClose=v.data.priceClose,
                            priceOpen=v.data.priceOpen,
                        }
                    }
                -- else
                --     MARKETPRICEBOARD_DBGOUT("copy")
                --     newhist[idx]={
                --         date= os.date(useformat,tonumber(curdate)),
                --         data={
                --             priceLow=v.data.priceClose,
                --             priceHigh=v.data.priceClose,
                --             priceClose=v.data.priceClose,
                --             priceOpen=v.data.priceClose,
                --         }
                --     }
                -- end
                MARKETPRICEBOARD_DBGOUT("endo")
                idx=idx+1
                break
            else
                -- 作成
                
                
                MARKETPRICEBOARD_DBGOUT("copy")
                newhist[idx]={
                    date= os.date(useformat,tonumber(curdate)),
                    data={
                        priceLow=cur.data.priceClose,
                        priceHigh=cur.data.priceClose,
                        priceClose=cur.data.priceClose,
                        priceOpen=cur.data.priceClose,
                    }
                }
                
                MARKETPRICEBOARD_DBGOUT("bb "..tostring(curdate))
                
                copy=true
                idx=idx+1
                
            end
        end
        
        cur=v
    end
    --newhist[#newhist+1]=last
    return newhist
end
function MARKETPRICEBOARD_SIMPLIFIEDINT(bignumber)
    if(bignumber==nil)then
        return 0
    end
    if(#bignumber < 3) then
        return 0
    end
    return tonumber(string.sub(bignumber,1,-2))
end
function MARKETPRICEBOARD_DRAWRECT(data,ctrl,col,x,y,w,h)

    local name=ctrl:GetUserIValue("next")
    --local brush="brush_"..ctrl:GetUserIValue("next")
    --ctrl:SetUserValue("next",name+1)
    local offsetx=ctrl:GetUserIValue("SCROLL_X") or 0
    --local nx=ctrl:CreateOrGetControl("slot",brush,x,y,w,h)
    --tolua.cast(nx,"ui::CGroupBox")
    --MARKETPRICEBOARD_DBGOUT(string.format("%d,%d,%d,%d",x,y,w,h))
    local color
    if(col==0)then
        color="FFFF0000"
        --nx:SetSkinName("invenslot_unique")
    else
        color="FF00FF77"
        --nx:SetSkinName("invenslot_rare")
    end

    if(x-offsetx-w<0 or (x-offsetx)>=ctrl:GetWidth())then
        return
    end
    for xx=x-offsetx,x+w-1-offsetx do
        ctrl:DrawBrush(xx,y,xx,y+h,"spray_1",color)
    end
    
end
function MARKETPRICEBOARD_DRAWLINE(data,ctrl,col,x,y,xx,yy)

    local name=ctrl:GetUserIValue("next")
    --local brush="brush_"..ctrl:GetUserIValue("next")
    --ctrl:SetUserValue("next",name+1)
    local offsetx=ctrl:GetUserIValue("SCROLL_X") or 0
    --local nx=ctrl:CreateOrGetControl("slot",brush,x,y,w,h)
    --tolua.cast(nx,"ui::CGroupBox")
    --MARKETPRICEBOARD_DBGOUT(string.format("%d,%d,%d,%d",x,y,w,h))
    local color

    color="FFFFFFFF"


    
    ctrl:DrawBrush(x-offsetx,y,xx-offsetx,yy,"spray_1",color)

    
end
function MARKETPRICEBOARD_CHANGED_CHART_OPTION(frame,msg,argstr,argnum)
    EBI_try_catch{
        try = function()
    local detailframe=frame
    MARKETPRICEBOARD_RENDER_CHART()

    local btnhourly=GET_CHILD(detailframe,"hourly","ui::CCheckBox")
    local btndaily=GET_CHILD(detailframe,"daily","ui::CCheckBox")
    local btnfourhourly=GET_CHILD(detailframe,"fourhourly","ui::CCheckBox")
    local btntick=GET_CHILD(detailframe,"tick","ui::CCheckBox")
    local btnline=GET_CHILD(detailframe,"line","ui::CCheckBox")
    if(argnum==0)then
        g.settings.charttimemode=1

    elseif argnum==1 then
        g.settings.charttimemode=10
        
    elseif argnum==2 then
        g.settings.charttimemode=4
        
    elseif argnum==200 then
        g.settings.concat=btntick:IsChecked()==1
    elseif argnum==300 then
        g.settings.linemode=btnline:IsChecked()==1
    end
    
    MARKETPRICEBOARD_RENDER_CHART(detailframe)
    MARKETPRICEBOARD_UPDATE_CHART_OPTION(detailframe)
    MARKETPRICEBOARD_SAVE_SETTINGS()
end,
catch = function(error)
    MARKETPRICEBOARD_ERROUT(error)
end
}
end

function MARKETPRICEBOARD_UPDATE_CHART_OPTION(detailframe)
    MARKETPRICEBOARD_DBGOUT("changed")
    local offset=170
    if(detailframe:GetName()=="marketpriceboardlargechart")then
        offset=100
    end
    local btnhourly = detailframe:CreateOrGetControl("checkbox", "hourly", 240, offset, 60, 20)
    if(g.isminutemode)then
        btnhourly:SetText("{ol}{#FFFFFF}{s18}分足")
    else
        btnhourly:SetText("{ol}{#FFFFFF}{s18}時足")
    end
    local btnfourhourly = detailframe:CreateOrGetControl("checkbox", "fourhourly", 320, offset, 60, 20)
    btnfourhourly:SetText("{ol}{#FFFFFF}{s18}4h足")
    local btndaily = detailframe:CreateOrGetControl("checkbox", "daily", 240, offset+20, 60, 20)
    btndaily:SetText("{ol}{#FFFFFF}{s18}日足")
    local btntick = detailframe:CreateOrGetControl("checkbox", "tick", 390, offset, 60, 20)
    btntick:SetText("{ol}{#FFFFFF}{s18}TICK詰め")
    local btnline = detailframe:CreateOrGetControl("checkbox", "line", 320,offset+20, 60, 20)
    btnline:SetText("{ol}{#FFFFFF}{s18}LINE表示")

    tolua.cast(btnhourly,"ui::CCheckBox")
    tolua.cast(btnfourhourly,"ui::CCheckBox")
    tolua.cast(btndaily,"ui::CCheckBox")
    tolua.cast(btntick,"ui::CCheckBox")
    tolua.cast(btnline,"ui::CCheckBox")
    
    btnhourly:SetEventScript(ui.LBUTTONDOWN, "MARKETPRICEBOARD_CHANGED_CHART_OPTION")
    btnhourly:SetEventScriptArgNumber(ui.LBUTTONDOWN,0)
    btnfourhourly:SetEventScript(ui.LBUTTONDOWN, "MARKETPRICEBOARD_CHANGED_CHART_OPTION")
    btnfourhourly:SetEventScriptArgNumber(ui.LBUTTONDOWN,2)

    btndaily:SetEventScript(ui.LBUTTONDOWN, "MARKETPRICEBOARD_CHANGED_CHART_OPTION")
    btndaily:SetEventScriptArgNumber(ui.LBUTTONDOWN,1)
    
    btntick:SetEventScript(ui.LBUTTONDOWN, "MARKETPRICEBOARD_CHANGED_CHART_OPTION")
    btntick:SetEventScriptArgNumber(ui.LBUTTONDOWN,200)
    btnline:SetEventScript(ui.LBUTTONDOWN, "MARKETPRICEBOARD_CHANGED_CHART_OPTION")
    btnline:SetEventScriptArgNumber(ui.LBUTTONDOWN,300)
    if(g.settings.charttimemode==1)then
        btnhourly:SetCheck(1)
        btndaily:SetCheck(0)
        btnfourhourly:SetCheck(0)
        
    elseif(g.settings.charttimemode==4)then
        btnhourly:SetCheck(0)
        btndaily:SetCheck(0)
        btnfourhourly:SetCheck(1)
    elseif(g.settings.charttimemode==10)then
        btnhourly:SetCheck(0)
        btndaily:SetCheck(1)
        btnfourhourly:SetCheck(0)
    end
    if(g.settings.concat==true)then
        btntick:SetCheck(1)
     
    else
        btntick:SetCheck(0)
    end
    if(g.settings.linemode==true)then
        btnline:SetCheck(1)
     
    else
        btnline:SetCheck(0)
    end
end

