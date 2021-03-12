--ebiremovedialog
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

local addonName = "ebiremovedialog"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings = g.settings or {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "アドオン名（大文字）"
g.debug = false
g.bkfade = {}
g.watchingdialog = false
g.usearts = false
g.latesttext = ""
--ライブラリ読み込み
CHAT_SYSTEM("[ERD]loaded")
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


local function DBGOUT(msg)
    
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
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end

function EBIREMOVEDIALOG_DIALOG_TEXTVIEW(frame, text, titleName, voiceName)
    EBIREMOVEDIALOG_DIALOG_TEXTVIEW_OLD(frame, text, titleName, voiceName)
    g.latesttext = text
    DBGOUT("latest" .. g.latesttext)
    if ui.GetFrame("challenge_mode"):IsVisible() == 1 or g.watchingdialog == true then
        DBGOUT("TEXTVIEW" .. tostring(ui.GetFrame("challenge_mode"):IsVisible()))
        ReserveScript("EBIREMOVEDIALOG_SETENABLE_SELECTDIALOG_SINGLE(true,'" .. text .. "')", 0.01)
        g.watchingdialog = true
    end

end
function EBIREMOVEDIALOG_INV_ICON_USE(invItem)
    EBI_try_catch{
        try = function()
            local itemCls = GetClassByType('Item', invItem.type)
            if itemCls and itemCls.GroupName == 'HiddenAbility' and g.settings.artsbook then
                DBGOUT('hidden')
                if nil == invItem then
                    return;
                end
                
                if true == invItem.isLockState then
                    ui.SysMsg(ClMsg("MaterialItemIsLock"));
                    return;
                end
                
                if true == RUN_CLIENT_SCP(invItem) then
                    return;
                end
                
                local stat = info.GetStat(session.GetMyHandle());
                if stat.HP <= 0 then
                    return;
                end
                
                local itemtype = invItem.type;
                local curTime = item.GetCoolDown(itemtype);
                if curTime ~= 0 then
                    imcSound.PlaySoundEvent("skill_cooltime");
                    return;
                end
                g.usearts = true
                g.watchingdialog = true
                
                ReserveScript("EBIREMOVEDIALOG_DIALOG_DO_SINGLE(true)", 0.02)
                item.UseByGUID(invItem:GetIESID());
            
            else
                EBIREMOVEDIALOG_INV_ICON_USE_OLD(invItem)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EBIREMOVEDIALOG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            addon:RegisterMsg('GAME_START', 'EBIREMOVEDIALOG_GAME_START');
            addon:RegisterMsg('DIALOG_CLOSE', 'EBIREMOVEDIALOG_DIALOG_RESTOREENABLE');
            --addon:RegisterMsg('DIALOG_CHANGE_OK', 'EBIREMOVEDIALOG_DIALOG_CHANGE_OK_NEXT');
            --addon:RegisterMsg('DIALOG_CHANGE_NEXT', 'EBIREMOVEDIALOG_DIALOG_CHANGE_OK_NEXT');
            --addon:RegisterMsg('DIALOG_SKIP', 'EBIREMOVEDIALOG_DIALOG_CHANGE_OK_NEXT');
            addon:RegisterMsg('DIALOG_ADD_SELECT', 'EBIREMOVEDIALOG_DIALOG_DO_MULTIPLE');
            g.latesttest = ""
            g.watchingdialog = false
            g.artsbook = false;
            if EBIREMOVEDIALOG_INV_ICON_USE_OLD == nil and INV_ICON_USE ~= EBIREMOVEDIALOG_INV_ICON_USE then
                EBIREMOVEDIALOG_INV_ICON_USE_OLD = INV_ICON_USE
                INV_ICON_USE = EBIREMOVEDIALOG_INV_ICON_USE
            end
            if EBIREMOVEDIALOG_DIALOG_TEXTVIEW_OLD ~= nil then
                DIALOG_SHOW_DIALOG_TEXT = EBIREMOVEDIALOG_DIALOG_TEXTVIEW_OLD
                EBIREMOVEDIALOG_DIALOG_TEXTVIEW_OLD = nil
            end
            if EBIREMOVEDIALOG_DIALOG_TEXTVIEW_OLD == nil and DIALOG_SHOW_DIALOG_TEXT ~= EBIREMOVEDIALOG_DIALOG_TEXTVIEW then
                EBIREMOVEDIALOG_DIALOG_TEXTVIEW_OLD = DIALOG_SHOW_DIALOG_TEXT
                DIALOG_SHOW_DIALOG_TEXT = EBIREMOVEDIALOG_DIALOG_TEXTVIEW
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EBIREMOVEDIALOG_GAME_START()
    
    EBIREMOVEDIALOG_LOAD_SETTINGS()
    EBIREMOVEDIALOGCONFIG_INIT()
    EBIREMOVEDIALOG_APPLY()
end
-- function EBIREMOVEDIALOG_DIALOG_CHANGE_OK_NEXT(frame, msg, argstr, argnum)
--     if g.watchingdialog == false then
--         local go = false
--         local uiframe = ui.GetFrame('dialog')
--         local text = uiframe:GetChildRecursively('textlist')
--         local rawtext = g.latesttest
--         local prefix = "{s20}{b}{#1f100b}"
--         DBGOUT(rawtext)
--         DBGOUT(ClMsg('AcceptNextLevelChallengeMode'))
--         if g.settings.challengemodenextstep then
--             if rawtext==ClMsg('AcceptNextLevelChallengeMode') then
--                 go = true
--             end
--         end
--         if g.settings.challengemodecomplete then
--             if rawtext==ClMsg('CompleteChallengeMode') then
--                 go = true
--             end
--         end
--         if g.settings.challengemodeabort then
--             if rawtext==ClMsg('AcceptStopLevelChallengeMode')then
--                 go = true
--             end
--         end
--         if go then
--             DBGOUT("OKNEXT")
--             --frame:ShowWindow(0)
--             g.watchingdialog = true
--             ReserveScript('EBIREMOVEDIALOG_DIALOG_DO_SINGLE(true)', 0.01)
--         else
--             DBGOUT("FAIL")
--         end
--     end
-- end
function EBIREMOVEDIALOG_DIALOG_DO_SINGLE(ok)
    if g.watchingdialog == true then
        
        ReserveScript("EBIREMOVEDIALOG_SETENABLE_SELECTDIALOG_SINGLE(" .. tostring(ok) .. ")", 0.01)
    end
end
function EBIREMOVEDIALOG_DIALOG_DO_MULTIPLE(frame, ctrl, argstr, argnum)
    
    if (ui.GetFrame("challenge_mode"):IsVisible() == 1 and g.watchingdialog == true) or g.usearts then
        DBGOUT("multiple")
        ReserveScript("EBIREMOVEDIALOG_SETENABLE_SELECTDIALOG_MULTIPLE(" .. tostring(0) .. ")", 0.01)
    end
end


function EBIREMOVEDIALOG_SETENABLE_SELECTDIALOG_MULTIPLE(select)
    if g.watchingdialog and (ui.GetFrame("challenge_mode"):IsVisible() == 1 or g.usearts) then
        
        local go = false
        if ui.GetFrame("challenge_mode"):IsVisible() == 1 then
            local uiframe = ui.GetFrame('dialog')
            local text = uiframe:GetChildRecursively('textlist')
            local rawtext = g.latesttext
            local prefix = "{s20}{b}{#1f100b}"
            DBGOUT(rawtext)
            DBGOUT(ClMsg('AcceptNextLevelChallengeMode'))
            if g.settings.challengemodenextstep then
                if rawtext == ClMsg('AcceptNextLevelChallengeMode') then
                    go = true
                end
            end
            if g.settings.challengemodecomplete then
                if rawtext == ClMsg('CompleteChallengeMode') then
                    go = true
                end
            end
            if g.settings.challengemodeabort then
                if rawtext == ClMsg('AcceptStopLevelChallengeMode') then
                    go = true
                end
            end
        else
            go = true
        end
        if go then
            DBGOUT("Multiplut")
            session.SetSelectDlgList();
            ui.OpenFrame('dialogselect');
            ReserveScript([[
                local x=mouse.GetX();
                local y=mouse.GetY();
                ReserveScript('control.DialogSelect(]]
                .. (select + 1) .. [[)',0.01);
                ReserveScript(string.format('mouse.SetPos(%d,%d)',x,y),0.02)
                ]]              
                , 0.03);
        else
            DBGOUT("failed")
        end
        g.watchingdialog = false
        g.usearts = false
    end
end
function EBIREMOVEDIALOG_SETENABLE_SELECTDIALOG_SINGLE(ok)
    if g.watchingdialog then
        
        if ui.GetFrame("challenge_mode"):IsVisible() == 1 or g.usearts then
            local go = false
            if ui.GetFrame("challenge_mode"):IsVisible() == 1 then
                local uiframe = ui.GetFrame('dialog')
                local text = uiframe:GetChildRecursively('textlist')
                local rawtext = g.latesttext
                DBGOUT(rawtext)
                DBGOUT(ClMsg('AcceptNextLevelChallengeMode'))
                if g.settings.challengemodenextstep then
                    if rawtext == ClMsg('AcceptNextLevelChallengeMode') then
                        go = true
                    end
                end
                if g.settings.challengemodecomplete then
                    if rawtext == ClMsg('CompleteChallengeMode') then
                        go = true
                    end
                end
                if g.settings.challengemodeabort then
                    if rawtext == ClMsg('AcceptStopLevelChallengeMode') then
                        go = true
                    end
                end
            else
                go = true
            end
            if ok then
                if go then
                    EBIREMOVEDIALOG_SETENABLE_SELECTDIALOG_MULTIPLE(0)
                end
            
            else
                DBGOUT("Cancel")
                control.DialogCancel();
            end
        
        else
            if ok then
                DBGOUT("OK")
                control.DialogOk();
            
            else
                DBGOUT("Cancel")
                control.DialogCancel();
            end
        end
    
    
    end
end
function EBIREMOVEDIALOG_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function EBIREMOVEDIALOG_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    EBIREMOVEDIALOGCONFIG_GENERATEDEFAULT(g.settings)
    EBIREMOVEDIALOG_UPGRADE_SETTINGS()
    EBIREMOVEDIALOG_SAVE_SETTINGS()

end

function EBIREMOVEDIALOG_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function EBIREMOVEDIALOG_APPLY()
    EBI_try_catch{
        try = function()
            -- if g.settings.challengemodeenter then
            --     assert(pcall(function()
            --         function DIALOG_ACCEPT_CHALLENGE_MODE(handle)
            --             ACCEPT_CHALLENGE_MODE(handle,1)
            --         end
            --     end))
            -- end
            -- if g.settings.challengehardmodeenter then
            --     assert(pcall(function()
            --         function DIALOG_ACCEPT_CHALLENGE_MODE_HARD_MODE(handle)
            --             ACCEPT_CHALLENGE_MODE(handle,1)
            --         end
            --     end))
            -- end
            -- if g.settings.challengemodenextstep then
            --     assert(pcall(function()
            --         function DIALOG_ACCEPT_NEXT_LEVEL_CHALLENGE_MODE(handle)
            --             ACCEPT_NEXT_LEVEL_CHALLENGE_MODE(handle)
            --         end
            --     end))
            -- end
            -- if g.settings.challengemodeabort then
            --     assert(pcall(function()
            --         function DIALOG_ACCEPT_STOP_LEVEL_CHALLENGE_MODE(handle)
            --             ACCEPT_STOP_LEVEL_CHALLENGE_MODE(handle)
            --         end
            --     end))
            -- end
            -- if g.settings.challengemodecomplete then
            --     assert(pcall(function()
            --         function DIALOG_COMPLETE_CHALLENGE_MODE(handle)
            --             ACCEPT_STOP_LEVEL_CHALLENGE_MODE(handle)
            --         end
            --     end))
            -- end
            if g.settings.cardremove then
                assert(pcall(function()
                        -- 카드 슬롯 정보창 열기
                        function EQUIP_CARDSLOT_INFO_OPEN(slotIndex)
                            
                            
                            local frame = ui.GetFrame('equip_cardslot_info');
                            
                            if frame:IsVisible() == 1 then
                                frame:ShowWindow(0);
                            end
                            
                            local cardID, cardLv, cardExp = GETMYCARD_INFO(slotIndex);
                            if cardID == 0 then
                                return;
                            end
                            
                            local prop = geItemTable.GetProp(cardID);
                            if prop ~= nil then
                                cardLv = prop:GetLevel(cardExp);
                            end
                            
                            -- 카드 슬롯 제거하기 위함
                            frame:SetUserValue("REMOVE_CARD_SLOTINDEX", slotIndex);
                            EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT(frame,nil)
                        end
                end
                ))
            end
            if g.settings.cardequip then
                assert(pcall(function()
                    function CARD_SLOT_EQUIP(slot, item, groupNameStr)
                        local obj = GetIES(item:GetObject());
                        if obj.GroupName == "Card" then			
                            local slotIndex = slot:GetSlotIndex();
                            if groupNameStr == 'ATK' then
                                slotIndex = slotIndex + (0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
                            elseif groupNameStr == 'DEF' then
                                slotIndex = slotIndex + (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
                            elseif groupNameStr == 'UTIL' then
                                slotIndex = slotIndex + (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
                            elseif groupNameStr == 'STAT' then
                                slotIndex = slotIndex + (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
                            elseif groupNameStr == 'LEG' then
                                slotIndex = 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE
                                -- leg 카드는 slotindex = 12, 13번째 슬롯
                            end
                    
                            local cardInfo = equipcard.GetCardInfo(slotIndex + 1);
                            if cardInfo ~= nil then
                                ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"));
                                return;
                            end
                    
                            if groupNameStr == 'LEG' then
                                local pcEtc = GetMyEtcObject();
                                if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 then
                                    ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
                                    return
                                end
                            end
                    
                            if item.isLockState == true then
                                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                                return
                            end
                                    
                            local itemGuid = item:GetIESID();
                            local invFrame = ui.GetFrame("inventory");	
                            invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid);
                            invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", slotIndex);	
                            local textmsg = string.format("[ %s ]{nl}%s", obj.Name, ScpArgMsg("AreYouSureEquipCard"));	
                            REQUEST_EQUIP_CARD_TX()		
                            return 1;
                        end;
                        return 0;
                    end
                end
                ))
            end
            if g.settings.bookreading then
                assert(pcall(function()
                    function BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN(invItem)
                        if invItem == nil then
                            return;
                        end
                        
                        local invFrame = ui.GetFrame("inventory");
                        local itemobj = GetIES(invItem:GetObject());
                        if itemobj == nil then
                            return;
                        end
                        
                        if SYSMENU_INVENTORY_WEIGHT_NOTICE == nil then
                            --older one
                            invFrame:SetUserValue("INVITEM_GUID", invItem:GetIESID());
                        else
                            --newer
                            invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
                        end
                        
                        if itemobj.Script == 'SCR_SUMMON_MONSTER_FROM_CARDBOOK' then
                            REQUEST_SUMMON_BOSS_TX()
                            return;
                        elseif itemobj.Script == 'SCR_QUEST_CLEAR_LEGEND_CARD_LIFT' then
                            local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("Use_Item_LegendCard_Slot_Open2"));
                            ui.MsgBox_NonNested(textmsg, itemobj.Name, "REQUEST_SUMMON_BOSS_TX", "None");
                            return;
                        end
                    end
                end))
            end
            if g.settings.timelimited then
                assert(pcall(function()
                        -- RWFTLI
                        local json = require "json_imc"
                        
                        local max_slot_per_tab = account_warehouse.get_max_slot_per_tab()
                        local current_tab_index = 0
                        local custom_title_name = {}
                        local new_add_item = {}
                        local new_stack_add_item = {}
                        local ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD = ON_ACCOUNT_WAREHOUSE_ITEM_LIST
                        
                        function EBI_try_catch(what)
                            local status, result = pcall(what.try)
                            if not status then
                                what.catch(result)
                            end
                            return result
                        end
                        local function get_valid_index()
                            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
                            local guidList = itemList:GetGuidList();
                            local sortedGuidList = itemList:GetSortedGuidList();
                            local sortedCnt = sortedGuidList:Count();
                            
                            local start_index = (current_tab_index * max_slot_per_tab)
                            local last_index = (start_index + max_slot_per_tab) - 1
                            
                            local __set = {}
                            for i = 0, sortedCnt - 1 do
                                local guid = sortedGuidList:Get(i)
                                local invItem = itemList:GetItemByGuid(guid)
                                local obj = GetIES(invItem:GetObject());
                                if obj.ClassName ~= MONEY_NAME then
                                    if start_index <= invItem.invIndex and invItem.invIndex <= last_index and __set[invItem.invIndex] == nil then
                                        __set[invItem.invIndex] = 1
                                    end
                                end
                            end
                            
                            local index = start_index
                            for k, v in pairs(__set) do
                                if __set[index] ~= 1 then
                                    break
                                else
                                    index = index + 1
                                end
                            end
                            
                            return index
                        end
                        
                        
                        local function get_tab_index(item_inv_index)
                            if item_inv_index < 0 then
                                item_inv_index = 0
                            end
                            local index = math.floor(item_inv_index / max_slot_per_tab)
                            return index
                        end
                        
                        local function is_new_item(id)
                            for k, v in pairs(new_add_item) do
                                if v == id then
                                    return true
                                end
                            end
                            return false
                        end
                        
                        local function is_stack_new_item(class_id)
                            for k, v in pairs(new_stack_add_item) do
                                if v == class_id then
                                    return true
                                end
                            end
                            return false
                        end
                        function ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame, msg, argStr, argNum, tab_index)
                            ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD(frame, msg, argStr, argNum, tab_index)
                            if tab_index == nil then
                                tab_index = current_tab_index
                            end
                            
                            current_tab_index = tab_index
                        end
                        local function _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem)
                            local index = get_valid_index()
                            local account = session.barrack.GetMyAccount();
                            local slotCount = account:GetAccountWarehouseSlotCount();
                            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
                            local itemCnt = 0;
                            local guidList = itemList:GetGuidList();
                            local cnt = guidList:Count();
                            for i = 0, cnt - 1 do
                                local guid = guidList:Get(i);
                                local invItem = itemList:GetItemByGuid(guid);
                                local obj = GetIES(invItem:GetObject());
                                if obj.ClassName ~= MONEY_NAME and invItem.invIndex < max_slot_per_tab then
                                    itemCnt = itemCnt + 1;
                                end
                            end
                            
                            if slotCount <= itemCnt and index < max_slot_per_tab then
                                ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
                                return false;
                            end
                            
                            if slotCount <= index and index < max_slot_per_tab then
                                ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
                                return false;
                            end
                            return true;
                        end
                        
                        
                        function PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM(frame, invItem, slot, fromFrame)
                            local obj = GetIES(invItem:GetObject())
                            if _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(obj) == false then
                                return;
                            end
                            
                            if CHECK_EMPTYSLOT(frame, obj) == 1 then
                                return
                            end
                            
                            if true == invItem.isLockState then
                                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                                return;
                            end
                            
                            local itemCls = GetClassByType("Item", invItem.type);
                            if itemCls.ItemType == 'Quest' then
                                ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
                                return;
                            end
                            
                            local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
                            if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
                                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                                return;
                            end
                            
                            if fromFrame:GetName() == "inventory" then
                                local maxCnt = invItem.count;
                                if TryGetProp(obj, "BelongingCount") ~= nil then
                                    maxCnt = invItem.count - obj.BelongingCount;
                                    if maxCnt <= 0 then
                                        maxCnt = 0;
                                    end
                                end
                                
                                if invItem.count > 1 then
                                    INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt, nil, tostring(invItem:GetIESID()));
                                else
                                    if maxCnt <= 0 then
                                        ui.SysMsg(ClMsg("ItemIsNotTradable"));
                                        return;
                                    end
                                    
                                    local slotset = GET_CHILD_RECURSIVELY(frame, 'slotset');
                                    local goal_index = get_valid_index()
                                    if invItem.hasLifeTime == true then
                                        local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", "%s", %d, %d)', IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue('HANDLE'), goal_index);
                                        --ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                                        ReserveScript(yesscp, 0.00)
                                        return;
                                    end
                                    
                                    -- 여기서 아이템 입고 요청
                                    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"), goal_index)
                                    new_add_item[#new_add_item + 1] = invItem:GetIESID()
                                
                                --if geItemTable.IsStack(obj.ClassID) == 1 then
                                --    new_stack_add_item[#new_stack_add_item + 1] = obj.ClassID
                                --end
                                end
                            else
                                if slot ~= nil then
                                    AUTO_CAST(slot);
                                    local iconSlot = liftIcon:GetParent();
                                    AUTO_CAST(iconSlot);
                                    item.SwapSlotIndex(IT_ACCOUNT_WAREHOUSE, slot:GetSlotIndex(), iconSlot:GetSlotIndex());
                                    ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame);
                                end
                            end
                        end
                        
                        function WAREHOUSE_INV_RBTN(itemObj, slot)
                            
                            local frame = ui.GetFrame("warehouse");
                            local icon = slot:GetIcon();
                            local iconInfo = icon:GetInfo();
                            local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
                            
                            local obj = GetIES(invItem:GetObject());
                            if CHECK_EMPTYSLOT(frame, obj) == 1 then
                                return
                            end
                            
                            if true == invItem.isLockState then
                                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                                return;
                            end
                            
                            local itemCls = GetClassByType("Item", invItem.type);
                            if itemCls.ItemType == 'Quest' then
                                ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
                                return;
                            end
                            
                            if tonumber(itemCls.LifeTime) > 0 and obj.ItemLifeTimeOver > 0 then
                                ui.MsgBox(ScpArgMsg("WrongDropItem"));
                                return;
                            end
                            
                            if itemCls.MarketCategory == 'Housing_Furniture' or
                                itemCls.MarketCategory == 'Housing_Laboratory' or
                                itemCls.MarketCategory == 'Housing_Contract' then
                                ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
                                return;
                            end
                            
                            AUTO_CAST(slot);
                            local fromFrame = slot:GetTopParentFrame();
                            
                            if fromFrame:GetName() == "inventory" then
                                if invItem.count > 1 then
                                    INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_WAREHOUSE", invItem.count, 1, invItem.count, nil, tostring(invItem:GetIESID()));
                                else
                                    if invItem.hasLifeTime == true then
                                        local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", %d, %d)', IT_WAREHOUSE, invItem:GetIESID(), invItem.count, frame:GetUserIValue("HANDLE"));
                                        --ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                                        ReserveScript(yesscp, 0.00)
                                        return;
                                    end
                                    
                                    item.PutItemToWarehouse(IT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"));
                                end
                            end
                        end
                
                end))
            end
            
            if g.settings.dimension then
                assert(pcall(function()
                        
                        function BEFORE_APPLIED_YESSCP_OPEN(invItem)
                            if invItem == nil then
                                return;
                            end
                            
                            local invFrame = ui.GetFrame("inventory");
                            local itemobj = GetIES(invItem:GetObject());
                            if itemobj == nil then
                                return;
                            end
                            invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
                            if invItem.type == 494233 then
                                REQUEST_SUMMON_BOSS_TX()
                            else
                                local strLang = TryGetProp(itemobj, 'StringArg')
                                if strLang ~= 'None' then
                                    local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg(strLang));
                                    ui.MsgBox_NonNested(textmsg, itemobj.Name, 'REQUEST_SUMMON_BOSS_TX', "None");
                                end
                            end
                            
                            return;
                        end
                
                end))
            
            end
            if g.settings.idticket then
                assert(pcall(function()
                    function BEFORE_APPLIED_INDUNRESET_OPEN(invItem)
                        local frame = ui.GetFrame("token");
                        if invItem.isLockState then
                            frame:ShowWindow(0)
                            return;
                        end
                        
                        local obj = GetIES(invItem:GetObject());
                        
                        if obj.ItemLifeTimeOver > 0 then
                            ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
                            return;
                        end
                        
                        if 0 == frame:IsVisible() then
                            frame:ShowWindow(1)
                        end
                        
                        local token_middle = GET_CHILD(frame, "token_middle", "ui::CPicture");
                        token_middle:SetImage("indunFreeEnter_middle");
                        
                        local gBox = frame:GetChild("gBox");
                        gBox:RemoveAllChild();
                        
                        local ctrlSet = gBox:CreateControlSet("tokenDetail", "CTRLSET_INDUNFREE", ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
                        local prop = ctrlSet:GetChild("prop");
                        
                        if obj.ClassName == 'Premium_indunReset_1add' or obj.ClassName == 'Premium_indunReset_1add_14d' or obj.ClassName == 'indunReset_1add_14d_NoStack' or obj.ClassName == 'Event_1704_Premium_indunReset_1add' or obj.ClassName == 'indunReset_1add_14d_NoStack_Team' then
                            prop:SetTextByKey("value", ClMsg('Indun1AddText'));
                        else
                            prop:SetTextByKey("value", ClMsg('IndunRestText'));
                        end
                        
                        local value = GET_CHILD_RECURSIVELY(ctrlSet, "value");
                        value:ShowWindow(0);
                        
                        
                        GBOX_AUTO_ALIGN(gBox, 0, 2, 0, true, false);
                        local itemobj = GetIES(invItem:GetObject());
                        local endTxt = frame:GetChild("endTime");
                        endTxt:ShowWindow(0);
                        
                        local strTxt = frame:GetChild("richtext_1");
                        strTxt:SetTextByKey("value", GetClassString('Item', itemobj.ClassName, 'Name'));
                        
                        local bg2 = frame:GetChild("bg2");
                        local indunStr = bg2:GetChild("indunStr");
                        indunStr:SetTextByKey("value", GetClassString('Item', itemobj.ClassName, 'Name') .. ScpArgMsg("Premium_itemEun"));
                        indunStr:SetTextByKey("value2", ScpArgMsg("Premium_character"));
                        indunStr:ShowWindow(1);
                        
                        local endTime2 = bg2:GetChild("endTime2");
                        endTime2:ShowWindow(0);
                        
                        local strTxt = bg2:GetChild("str");
                        strTxt:SetTextByKey("value", GetClassString('Item', itemobj.ClassName, 'Name'));
                        
                        local forToken = bg2:GetChild("forToken");
                        forToken:ShowWindow(1);
                        
                        frame:SetUserValue("itemIES", invItem:GetIESID());
                        frame:SetUserValue("ClassName", itemobj.ClassName);
                        bg2:Resize(bg2:GetWidth(), 440);
                        frame:Resize(frame:GetWidth(), 500);
                        REQ_TOKEN_ITEM(frame)
                    end
                end))
            
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
