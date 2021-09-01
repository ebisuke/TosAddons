
local function fn()
    --
    -- json.lua
    --
    -- Copyright (c) 2018 rxi
    --
    -- Permission is hereby granted, free of charge, to any person obtaining a copy of
    -- this software and associated documentation files (the "Software"), to deal in
    -- the Software without restriction, including without limitation the rights to
    -- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
    -- of the Software, and to permit persons to whom the Software is furnished to do
    -- so, subject to the following conditions:
    --
    -- The above copyright notice and this permission notice shall be included in all
    -- copies or substantial portions of the Software.
    --
    -- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    -- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    -- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    -- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    -- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    -- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    -- SOFTWARE.
    --
    local json = {_version = "0.1.1"}
    
    -------------------------------------------------------------------------------
    -- Encode
    -------------------------------------------------------------------------------
    local encode
    
    local escape_char_map = {
        ["\\"] = "\\\\",
        ["\""] = "\\\"",
        ["\b"] = "\\b",
        ["\f"] = "\\f",
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
    }
    
    -- Custom sub string function since ToS' seems to have some weird limit
    -- Fixes loading files with sizes > 2048
    local function strsub(str, start, _end)
        start = start and start or 1;
        _end = _end and _end or 1;
        str = tostring(str);
        
        local len = _end - start + 1;
        local str_ = '';
        str = str:gsub(".", '', start - 1);
        str:gsub(".", function(c)str_ = str_ .. c end, len);
        return str_;
    end
    
    local escape_char_map_inv = {["\\/"] = "/"}
    for k, v in pairs(escape_char_map) do
        escape_char_map_inv[v] = k
    end
    
    
    local function escape_char(c)
        return escape_char_map[c] or string.format("\\u%04x", c:byte())
    end
    
    
    local function encode_nil(val)
        return "null"
    end
    
    
    local function encode_table(val, stack)
        local res = {}
        stack = stack or {}
        
        -- Circular reference?
        if stack[val] then error("circular reference") end
        
        stack[val] = true
        
        if val[1] ~= nil or next(val) == nil then
            -- Treat as array -- check keys are valid and it is not sparse
            local n = 0
            for k in pairs(val) do
                if type(k) ~= "number" then
                    error("invalid table: mixed or invalid key types")
                end
                n = n + 1
            end
            if n ~= #val then
                error("invalid table: sparse array")
            end
            -- Encode
            for i, v in ipairs(val) do
                table.insert(res, encode(v, stack))
            end
            stack[val] = nil
            return "[" .. table.concat(res, ",") .. "]"
        
        else
            -- Treat as an object
            for k, v in pairs(val) do
                if type(k) ~= "string" then
                    error("invalid table: mixed or invalid key types")
                end
                table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
            end
            stack[val] = nil
            return "{" .. table.concat(res, ",") .. "}"
        end
    end
    
    
    local function encode_string(val)
        return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
    end
    
    
    local function encode_number(val)
        -- Check for NaN, -inf and inf
        if val ~= val or val <= -math.huge or val >= math.huge then
            error("unexpected number value '" .. tostring(val) .. "'")
        end
        return string.format("%.14g", val)
    end
    
    
    local type_func_map = {
        ["nil"] = encode_nil,
        ["table"] = encode_table,
        ["string"] = encode_string,
        ["number"] = encode_number,
        ["boolean"] = tostring,
    }
    
    
    encode = function(val, stack)
        local t = type(val)
        local f = type_func_map[t]
        if f then
            return f(val, stack)
        end
        error("unexpected type '" .. t .. "'")
    end
    
    
    function json.encode(val)
        return (encode(val))
    end
    
    
    -------------------------------------------------------------------------------
    -- Decode
    -------------------------------------------------------------------------------
    local parse
    
    local function create_set(...)
        local res = {}
        for i = 1, select("#", ...) do
            res[select(i, ...)] = true
        end
        return res
    end
    
    local space_chars = create_set(" ", "\t", "\r", "\n")
    local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
    local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
    local literals = create_set("true", "false", "null")
    
    local literal_map = {
        ["true"] = true,
        ["false"] = false,
        ["null"] = nil,
    }
    
    
    local function next_char(str, idx, set, negate)
        for i = idx, #str do
            if set[strsub(str, i, i)] ~= negate then
                return i
            end
        end
        return #str + 1
    end
    
    
    local function decode_error(str, idx, msg)
        local line_count = 1
        local col_count = 1
        for i = 1, idx - 1 do
            col_count = col_count + 1
            if strsub(str, i, i) == "\n" then
                line_count = line_count + 1
                col_count = 1
            end
        end
        error(string.format("%s at line %d col %d", msg, line_count, col_count))
    end
    
    
    local function codepoint_to_utf8(n)
        -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
        local f = math.floor
        if n <= 0x7f then
            return string.char(n)
        elseif n <= 0x7ff then
            return string.char(f(n / 64) + 192, n % 64 + 128)
        elseif n <= 0xffff then
            return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
        elseif n <= 0x10ffff then
            return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                f(n % 4096 / 64) + 128, n % 64 + 128)
        end
        error(string.format("invalid unicode codepoint '%x'", n))
    end
    
    
    local function parse_unicode_escape(s)
        local n1 = tonumber(strsub(s, 3, 6), 16)
        local n2 = tonumber(strsub(s, 9, 12), 16)
        -- Surrogate pair?
        if n2 then
            return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
        else
            return codepoint_to_utf8(n1)
        end
    end
    
    
    local function parse_string(str, i)
        local has_unicode_escape = false
        local has_surrogate_escape = false
        local has_escape = false
        local last
        for j = i + 1, #str do
            local x = str:byte(j)
            
            if x < 32 then
                decode_error(str, j, "control character in string")
            end
            
            if last == 92 then -- "\\" (escape char)
                if x == 117 then -- "u" (unicode escape sequence)
                    local hex = strsub(str, j + 1, j + 5)
                    if not hex:find("%x%x%x%x") then
                        decode_error(str, j, "invalid unicode escape in string")
                    end
                    if hex:find("^[dD][89aAbB]") then
                        has_surrogate_escape = true
                    else
                        has_unicode_escape = true
                    end
                else
                    local c = string.char(x)
                    if not escape_chars[c] then
                        decode_error(str, j, "invalid escape char '" .. c .. "' in string")
                    end
                    has_escape = true
                end
                last = nil
            
            elseif x == 34 then -- '"' (end of string)
                local s = strsub(str, i + 1, j - 1)
                if has_surrogate_escape then
                    s = s:gsub("\\u[dD][89aAbB]..\\u....", parse_unicode_escape)
                end
                if has_unicode_escape then
                    s = s:gsub("\\u....", parse_unicode_escape)
                end
                if has_escape then
                    s = s:gsub("\\.", escape_char_map_inv)
                end
                return s, j + 1
            
            else
                last = x
            end
        end
        decode_error(str, i, "expected closing quote for string")
    end
    
    
    local function parse_number(str, i)
        local x = next_char(str, i, delim_chars)
        local s = strsub(str, i, x - 1)
        local n = tonumber(s)
        if not n then
            decode_error(str, i, "invalid number '" .. s .. "'")
        end
        return n, x
    end
    
    
    local function parse_literal(str, i)
        local x = next_char(str, i, delim_chars)
        local word = strsub(str, i, x - 1)
        if not literals[word] then
            decode_error(str, i, "invalid literal '" .. word .. "'")
        end
        return literal_map[word], x
    end
    
    
    local function parse_array(str, i)
        local res = {}
        local n = 1
        i = i + 1
        while 1 do
            local x
            i = next_char(str, i, space_chars, true)
            -- Empty / end of array?
            if strsub(str, i, i) == "]" then
                i = i + 1
                break
            end
            -- Read token
            x, i = parse(str, i)
            res[n] = x
            n = n + 1
            -- Next token
            i = next_char(str, i, space_chars, true)
            local chr = strsub(str, i, i)
            i = i + 1
            if chr == "]" then break end
            if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
        end
        return res, i
    end
    
    
    local function parse_object(str, i)
        local res = {}
        i = i + 1
        while 1 do
            local key, val
            i = next_char(str, i, space_chars, true)
            -- Empty / end of object?
            if strsub(str, i, i) == "}" then
                i = i + 1
                break
            end
            -- Read key
            if strsub(str, i, i) ~= '"' then
                decode_error(str, i, "expected string for key")
            end
            key, i = parse(str, i)
            -- Read ':' delimiter
            i = next_char(str, i, space_chars, true)
            if strsub(str, i, i) ~= ":" then
                decode_error(str, i, "expected ':' after key")
            end
            i = next_char(str, i + 1, space_chars, true)
            -- Read value
            val, i = parse(str, i)
            -- Set
            res[key] = val
            -- Next token
            i = next_char(str, i, space_chars, true)
            local chr = strsub(str, i, i)
            i = i + 1
            if chr == "}" then break end
            if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
        end
        return res, i
    end
    
    
    local char_func_map = {
        ['"'] = parse_string,
        ["0"] = parse_number,
        ["1"] = parse_number,
        ["2"] = parse_number,
        ["3"] = parse_number,
        ["4"] = parse_number,
        ["5"] = parse_number,
        ["6"] = parse_number,
        ["7"] = parse_number,
        ["8"] = parse_number,
        ["9"] = parse_number,
        ["-"] = parse_number,
        ["t"] = parse_literal,
        ["f"] = parse_literal,
        ["n"] = parse_literal,
        ["["] = parse_array,
        ["{"] = parse_object,
    }
    
    
    parse = function(str, idx)
        local chr = strsub(str, idx, idx)
        local f = char_func_map[chr]
        if f then
            return f(str, idx)
        end
        decode_error(str, idx, "unexpected character '" .. chr .. "'")
    end
    
    
    function json.decode(str)
        if type(str) ~= "string" then
            error("expected argument of type string, got " .. type(str))
        end
        local res, idx = parse(str, next_char(str, 1, space_chars, true))
        idx = next_char(str, idx, space_chars, true)
        if idx <= #str then
            decode_error(str, idx, "trailing garbage")
        end
        return res
    end
    local acutil = {};
    
    _G['ADDONS'] = _G['ADDONS'] or {};
    _G['ADDONS']['EVENTS'] = _G['ADDONS']['EVENTS'] or {};
    _G['ADDONS']['EVENTS']['ARGS'] = _G['ADDONS']['EVENTS']['ARGS'] or {};
    
    -- ================================================================
    -- Lua 5.3 Migration
    -- ================================================================
    if not _G['loadstring'] and _G['load'] then
        _G['loadstring'] = _G['load']
    end
    
    if not _G['unpack'] then
        _G['unpack'] = table.unpack;
    end
    
    -- ================================================================
    -- Strings
    -- ================================================================
    function acutil.addThousandsSeparator(amount)
        local formatted = amount
        
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k == 0) then
                break
            end
        end
        
        return formatted
    end
    
    function acutil.leftPad(str, len, char)
        if char == nil then
            char = ' '
        end
        
        return string.rep(char, len - #str) .. str
    end
    
    function acutil.rightPad(str, len, char)
        if char == nil then
            char = ' '
        end
        
        return str .. string.rep(char, len - #str)
    end
    
    function acutil.tostring(var)
        if (var == nil) then return 'nil'; end
        local tp = type(var);
        if (tp == 'string' or tp == 'number') then
            return var;
        end
        if (tp == 'boolean') then
            if (var) then
                return 'true';
            else
                return 'false';
            end
        end
        return tp;
    end
    
    -- ================================================================
    -- Player
    -- ================================================================
    function acutil.getStatPropertyFromPC(typeStr, statStr, pc)
        local errorText = "Param was nil";
        
        if typeStr ~= nil and statStr ~= nil and pc ~= nil then
            
            if typeStr == "JOB" then
                if statStr == "STR" then
                    return pc.STR_JOB;
                elseif statStr == "DEX" then
                    return pc.DEX_JOB;
                elseif statStr == "CON" then
                    return pc.CON_JOB;
                elseif statStr == "INT" then
                    return pc.INT_JOB;
                elseif statStr == "MNA" then
                    return pc.MNA_JOB;
                elseif statStr == "LUCK" then
                    return pc.LUCK_JOB;
                else
                    errorText = "Could not find stat " .. statStr .. " for type " .. typeStr;
                end
            
            elseif typeStr == "STAT" then
                if statStr == "STR" then
                    return pc.STR_STAT;
                elseif statStr == "DEX" then
                    return pc.DEX_STAT;
                elseif statStr == "CON" then
                    return pc.CON_STAT;
                elseif statStr == "INT" then
                    return pc.INT_STAT;
                elseif statStr == "MNA" then
                    return pc.MNA_STAT;
                elseif statStr == "LUCK" then
                    return pc.LUCK_STAT;
                else
                    errorText = "Could not find stat " .. statStr .. " for type " .. typeStr;
                end
            
            elseif typeStr == "BONUS" then
                if statStr == "STR" then
                    return pc.STR_Bonus;
                elseif statStr == "DEX" then
                    return pc.DEX_Bonus;
                elseif statStr == "CON" then
                    return pc.CON_Bonus;
                elseif statStr == "INT" then
                    return pc.INT_Bonus;
                elseif statStr == "MNA" then
                    return pc.MNA_Bonus;
                else
                    errorText = "Could not find stat " .. statStr .. " for type " .. typeStr;
                end
            
            elseif typeStr == "ADD" then
                if statStr == "STR" then
                    return pc.STR_ADD;
                elseif statStr == "DEX" then
                    return pc.DEX_ADD;
                elseif statStr == "CON" then
                    return pc.CON_ADD;
                elseif statStr == "INT" then
                    return pc.INT_ADD;
                elseif statStr == "MNA" then
                    return pc.MNA_ADD;
                elseif statStr == "LUCK" then
                    return pc.LUCK_ADD;
                else
                    errorText = "Could not find stat " .. statStr .. " for type " .. typeStr;
                end
            
            elseif typeStr == "BM" then
                if statStr == "STR" then
                    return pc.STR_BM;
                elseif statStr == "DEX" then
                    return pc.DEX_BM;
                elseif statStr == "CON" then
                    return pc.CON_BM;
                elseif statStr == "INT" then
                    return pc.INT_BM;
                elseif statStr == "MNA" then
                    return pc.MNA_BM;
                elseif statStr == "LUCK" then
                    return pc.LUCK_BM;
                else
                    errorText = "Could not find stat " .. statStr .. " for type " .. typeStr;
                end
            
            else
                errorText = "Could not find a property for type " .. typeStr;
            end
        end
        
        ui.SysMsg(errorText);
        return 0;
    end
    
    function acutil.isValidStat(statStr, includeLuck)
        if statStr == "LUCK" then
            return includeLuck;
        elseif statStr == "STR" or
            statStr == "DEX" or
            statStr == "CON" or
            statStr == "INT" or
            statStr == "MNA" then
            return true;
        end
        
        return false;
    end
    
    function acutil.textControlFactory(attributeName, isMainSection)
        local text = "";
        
        if attributeName == "MNA" then
            attributeName = "SPR"
        elseif attributeName == "MountDEF" then
            attributeName = "physical defense"
        elseif attributeName == "MountDR" then
            attributeName = "evasion"
        elseif attributeName == "MountMHP" then
            attributeName = "max HP"
        end
        
        if isMainSection then
            text = "Points invested in " .. attributeName;
        else
            text = "Mounted " .. attributeName .. " bonus";
        end
        return text;
    end
    
    -- ================================================================
    -- Item
    -- ================================================================
    function acutil.getItemRarityColor(itemObj)
        local itemProp = geItemTable.GetProp(itemObj.ClassID);
        local grade = itemObj.ItemGrade;
        
        if (itemObj.ItemType == "Recipe") then
            local recipeGrade = string.match(itemObj.Icon, "misc(%d)");
            if recipeGrade ~= nil then
                grade = tonumber(recipeGrade) - 1
                grade = (grade > 1 and grade) or 1
            end
        end
        
        if (itemProp.setInfo ~= nil) then return "00FF00"; -- set piece
        elseif (grade == 0) then return "FFBA03"; -- premium
        elseif (grade == 1) then return "FFFFFF"; -- common
        elseif (grade == 2) then return "108CFF"; -- rare
        elseif (grade == 3) then return "AA40FF"; -- epic
        elseif (grade == 4) then return "FF4F00"; -- Good old Red-ish Legendary that degraded to unique
        elseif (grade == 5) then return "EFEA00"; -- All new Bright-Yellow legendary. (Solmiki/Lolo/Some event item. might useful in future)
        end
        return "E1E1E1"; -- no grade (non-equipment items)
    end
    
    -- ================================================================
    -- Hooks/Events
    -- ================================================================
    function acutil.setupHook(newFunction, hookedFunctionStr)
        local storeOldFunc = hookedFunctionStr .. "_OLD";
        if _G[storeOldFunc] == nil then
            _G[storeOldFunc] = _G[hookedFunctionStr];
            _G[hookedFunctionStr] = newFunction;
        else
            _G[hookedFunctionStr] = newFunction;
        end
    end
    
    function acutil.setupEvent(myAddon, functionNameAbs, myFunctionName)
        local functionName = string.gsub(functionNameAbs, "%.", "");
        
        if _G['ADDONS']['EVENTS'][functionName .. "_OLD"] == nil then
            _G['ADDONS']['EVENTS'][functionName .. "_OLD"] = loadstring("return " .. functionNameAbs)();
        end
        
        local hookedFuncString = functionNameAbs .. [[ = function(...)
		local function pack2(...) return {n=select('#', ...), ...} end
		local thisFuncName = "]]
            
            .. functionName .. [[";
		local result = pack2(pcall(_G['ADDONS']['EVENTS'][thisFuncName .. '_OLD'], ...));
		_G['ADDONS']['EVENTS']['ARGS'][thisFuncName] = {...};
		imcAddOn.BroadMsg(thisFuncName);
		return unpack(result, 2, result.n);
	end
	]]
        
        
        
        
        
        ;
        pcall(loadstring(hookedFuncString));
        
        myAddon:RegisterMsg(functionName, myFunctionName);
    end
    
    -- usage:
    -- function myFunc(addonFrame, eventMsg)
    --     local arg1, arg2, arg3 = acutils.getEventArgs(eventMsg);
    -- end
    function acutil.getEventArgs(eventMsg)
        return unpack(_G['ADDONS']['EVENTS']['ARGS'][eventMsg]);
    end
    
    -- ================================================================
    -- Json
    -- ================================================================
    function acutil.saveJSON(path, tbl)
        file, err = io.open(path, "w")
        if err then return _, err end
        
        local s = json.encode(tbl);
        file:write(s);
        file:close();
    end
    
    -- tblMerge is optional, use this to merge new pairs from tblMerge while
    -- preserving the pairs set in the pre-existing config file
    function acutil.loadJSON(path, tblMerge, ignoreError)
        -- opening the file
        local file, err = io.open(path, "r");
        local t = nil;
        -- if a error happened
        if (err) then
            -- if the ignoreError is true
            if (ignoreError) then
                -- we simply set it as a empty json
                t = {};
            else
                -- if it's not, the error is returned
                return _, err
            end
        else
            -- if nothing wrong happened, the file is read
            local content = file:read("*all");
            file:close();
            t = json.decode(content);
        end
        -- if there is another table to merge (like default options)
        if tblMerge then
            -- we merge it
            t = acutil.mergeLeft(tblMerge, t)
            -- and save it back to file
            acutil.saveJSON(path, t);
        end
        -- returning the table
        return t;
    end
    
    -- ================================================================
    -- Tables
    -- ================================================================
    -- merge left
    function acutil.mergeLeft(t1, t2)
        for k, v in pairs(t2) do
            if (type(v) == "table") and (type(t1[k] or false) == "table") then
                acutil.mergeLeft(t1[k], t2[k])
            else
                t1[k] = v
            end
        end
        return t1
    end
    
    -- table length (when #table doesn't works)
    function acutil.tableLength(T)
        local count = 0
        for _ in pairs(T) do count = count + 1 end
        return count
    end
    
    -- ================================================================
    -- Logging
    -- ================================================================
    function acutil.log(msg)
        CHAT_SYSTEM(acutil.tostring(msg));
    end
    
    -- ================================================================
    -- Slash Commands
    -- ================================================================
    -- credits to fiote for some code https://github.com/fiote/
    acutil.slashCommands = acutil.slashCommands or {};
    
    function acutil.slashCommand(cmd, fn)
        if cmd:sub(1, 1) ~= "/" then cmd = "/" .. cmd end
        acutil.slashCommands[cmd] = fn;
    end
    
    function acutil.slashSet(set)
        if (not set.base) then return ui.SysMsg('[acutil.slashSet] missing "base" string.'); end
        if (set.title) then set.title = set.title .. '{nl}-----------{nl}'; else set.title = ''; end
        
        local fnError = set.error;
        
        if (not fnError) then
            fnError = function(extraMsg)
                if (extraMsg) then extraMsg = '{nl}-----------{nl}' .. extraMsg .. '{nl}-----------{nl}'; else extraMsg = ''; end
                return 'Command not valid.{nl}' .. extraMsg .. 'Type "' .. set.base .. '" for help.', '', 'Nope';
            end
        end
        
        local executeSetCmd = function(fn, params)
            local p1, p2, p3;
            if (params) then
                p1, p2, p3 = fn(params);
            else
                p1, p2, p3 = fn();
            end
            if (p1) then
                local msg = set.title .. p1;
                if (p2 and p3) then return ui.MsgBox(msg, p2, p3); end
                if (p2) then return ui.MsgBox(msg, p2); end
                return ui.MsgBox(msg);
            end
        end
        
        local mainFn = function(words)
            local word = table.remove(words, 1);
            if (word == 'help') then word = nil; end
            
            if (word) then
                for cmd, data in pairs(set.cmds) do
                    if (cmd == word) then
                        local fn = data.fn;
                        local qtexpected = data.nparams or 0;
                        local qtfound = acutil.tableLength(words);
                        if (qtfound ~= qtexpected) then
                            return executeSetCmd(fnError, set.base .. ' ' .. cmd .. ' expects ' .. qtexpected .. ' params, not ' .. qtfound .. '.');
                        else
                            local params = {};
                            local n = 0;
                            while (acutil.tableLength(words) > 0) do
                                params[n] = table.remove(words, 1);
                                n = n + 1;
                            end
                            return executeSetCmd(fn, params);
                        end
                    end
                end
                return executeSetCmd(fnError, word .. ' is not a valid call.');
            else
                if (set.empty) then
                    return executeSetCmd(set.empty);
                end
                local lines = set.base .. '{nl}Show addon help.{nl}-----------{nl}';
                for cmd, data in pairs(set.cmds) do
                    local params = ' ';
                    local qtparams = data.nparams or 0;
                    for i = 1, qtparams do
                        params = params .. '$param' .. i .. ' ';
                    end
                    lines = lines .. set.base .. ' ' .. cmd .. params .. '{nl}-----------{nl}';
                end
                return ui.MsgBox(set.title .. lines, '', 'Nope');
            end
        end
        
        acutil.slashCommand(set.base, mainFn);
    end
    
    function acutil.onUIChat(msg)
        acutil.uiChat_OLD(msg);
        
        local words = {};
        for word in msg:gmatch('%S+') do
            table.insert(words, word)
        end
        
        local cmd = table.remove(words, 1);
        for i, v in ipairs({"/r", "/w", "/p", "/y", "/s", "/g"}) do
            if (tostring(cmd) == tostring(v)) then
                cmd = table.remove(words, 1);
                break;
            end
        end
        
        local fn = acutil.slashCommands[cmd];
        if (fn ~= nil) then
            acutil.closeChat();
            return fn(words);
        end
    end
    
    function acutil.closeChat()
        local chatFrame = GET_CHATFRAME();
        local edit = chatFrame:GetChild('mainchat');
        
        chatFrame:ShowWindow(0);
        edit:ShowWindow(0);
        
        ui.CloseFrame("chat_option");
        ui.CloseFrame("chat_emoticon");
    end
    
    -- alternate chat hook to avoid conflict with cwapi and lkchat
    if not acutil.uiChat_OLD then
        acutil.uiChat_OLD = ui.Chat;
    end
    
    ui.Chat = acutil.onUIChat;
    
    
    -- ================================================================
    -- Addon Sysmenu
    -- ================================================================
    ACUTIL_sysmenuMargin = 0;
    ACUTIL_sysmenuAddons = {};
    
    function acutil.addSysIcon(name, icon, tooltip, functionString)
        if ACUTIL_sysmenuAddons == nil then ACUTIL_sysmenuAddons = {}; end
        if ACUTIL_sysmenuAddons[name] == nil then ACUTIL_sysmenuAddons[name] = {}; end
        
        ACUTIL_sysmenuAddons[name].icon = icon;
        ACUTIL_sysmenuAddons[name].tooltip = tooltip;
        ACUTIL_sysmenuAddons[name].functionString = functionString;
        
        SYSMENU_CHECK_HIDE_VAR_ICONS_HOOKED(ui.GetFrame("sysmenu"), true);
    end
    
    function ACUTIL_OPEN_ADDON_SYSMENU()
        local frm = ui.GetFrame("ACUTIL_ADDON_SYSMENU");
        if frm ~= nil then
            if frm:IsVisible() == 1 then
                frm:ShowWindow(0);
                return;
            else
                frm:ShowWindow(1);
            end
        end
        
        if frm == nil then
            frm = ui.CreateNewFrame("sysmenu", "ACUTIL_ADDON_SYSMENU");
            frm:RemoveAllChild();
        end
        
        local sysMenuFrame = ui.GetFrame("sysmenu");
        local status = sysMenuFrame:GetChild("status");
        local acutilbutton = sysMenuFrame:GetChild("acutiladdon");
        local margin = status:GetMargin();
        frm:Resize(1920, 100);
        frm:MoveFrame(sysMenuFrame:GetX(), sysMenuFrame:GetY() + 35);
        frm:SetSkinName("systemmenu_vertical 잠정제거");
        
        ACUTIL_sysmenuMargin = acutilbutton:GetMargin().right;
        
        for k, v in pairs(ACUTIL_sysmenuAddons) do
            local btn = frm:CreateOrGetControl("button", "acutilAddon" .. tostring(k), status:GetWidth(), status:GetHeight(), ui.LEFT, ui.BOTTOM, 0, margin.top, margin.right, margin.bottom);
            local btnMargin = btn:GetMargin();
            btn:SetMargin(btnMargin.left, btnMargin.top, ACUTIL_sysmenuMargin, btnMargin.bottom);
            btn:CloneFrom(status);
            AUTO_CAST(btn);
            btn:SetImage(v.icon);
            
            --local byFullString = string.find(v.functionString, ')') ~= nil;
            btn:SetEventScript(ui.LBUTTONUP, v.functionString);
            btn:SetTextTooltip("{@st59}" .. v.tooltip);
            
            ACUTIL_sysmenuMargin = ACUTIL_sysmenuMargin - 39;
        end
    end
    
    function ACUTIL_SYSMENU_ICON(frame)
        if acutil.tableLength(ACUTIL_sysmenuAddons) > 0 then
            local extraBag = frame:GetChild('extraBag');
            local offsetX = 39;
            local rightMargin = 0;
            for idx = 0, frame:GetChildCount() - 1 do
                local t = frame:GetChildByIndex(idx):GetMargin().right;
                if rightMargin < t and frame:GetChildByIndex(idx):GetName() ~= "acutiladdon" then
                    rightMargin = t;
                end
            end
            rightMargin = rightMargin + offsetX;
            local margin = extraBag:GetMargin();
            local btn = frame:CreateOrGetControl("button", "acutiladdon", extraBag:GetWidth(), extraBag:GetHeight(), ui.LEFT, ui.BOTTOM, 0, margin.top, margin.right, margin.bottom);
            local btnMargin = btn:GetMargin();
            btn:SetMargin(btnMargin.left, btnMargin.top, rightMargin, btnMargin.bottom);
            btn:CloneFrom(extraBag);
            AUTO_CAST(btn);
            btn:SetImage("sysmenu_sys");
            btn:SetUserValue("IS_VAR_ICON", "YES");
            
            btn:SetEventScript(ui.LBUTTONUP, 'ACUTIL_OPEN_ADDON_SYSMENU');
            btn:SetTextTooltip("{@st59}Addons");
        end
    end
    
    function SYSMENU_CHECK_HIDE_VAR_ICONS_HOOKED(frame, isAcutil)
        if isAcutil == nil then
            --_G["SYSMENU_CHECK_HIDE_VAR_ICONS_OLD"](frame);
            if _G["SYSMENU_CHECK_HIDE_VAR_ICONS_OLD"] then
                _G["SYSMENU_CHECK_HIDE_VAR_ICONS_OLD"](frame);
            end
        end
        
        ACUTIL_SYSMENU_ICON(frame);
    end
    
    function SYSMENU_CREATE_VARICON_HOOKED(frame, status, ctrlName, frameName, imageName, startX, offsetX, hotkeyName)
        local margin = startX;
        margin = _G["SYSMENU_CREATE_VARICON_OLD"](frame, status, ctrlName, frameName, imageName, startX, offsetX, hotkeyName);
        
        ACUTIL_SYSMENU_ICON(frame);
        return margin;
    end
    
    acutil.setupHook(SYSMENU_CHECK_HIDE_VAR_ICONS_HOOKED, "SYSMENU_CHECK_HIDE_VAR_ICONS");
    acutil.setupHook(SYSMENU_CREATE_VARICON_HOOKED, "SYSMENU_CREATE_VARICON");
    
    local sysmenuFrame = ui.GetFrame("sysmenu");
    SYSMENU_CHECK_HIDE_VAR_ICONS(sysmenuFrame);
    
    ----------------------------------
    PRELOADER_DISGUISED_FUNC = _G["PRELOADER_DISGUISED_FUNC"]
    
    PRELOADER_DISGUISED_REQUIRE_OLD = _G["PRELOADER_DISGUISED_REQUIRE_OLD"]
    PRELOADER_DISGUISED_FUNC_BARRACK = _G["PRELOADER_DISGUISED_FUNC_BARRACK"]
    
    PRELOADER_DISGUISED_LOADED = _G["PRELOADER_DISGUISED_LOADED"] or false
    PRELOADER = _G["PRELOADER"] or {
        Events = {
            EventsOnTitle = "EventsOnTitle",
            EventsOnBarrack = "EventsOnBarrack",
        },
        _EventsOnTitle = {},
        _EventsOnBarrack = {},
        fireEvents = function(event,...)
            for _, v in ipairs(PRELOADER["_" .. event]) do
                local r, e = pcall(v,...)
                if not r then
                    ui.SysMsg(e)
                end
            end
        end
    }
    --prevent crush
    function PRELOADER_SelectObject(...)
        if GetMyActor()~=nil then
            return SelectObject_OLD(...)
        end
        return {},0
    end
    acutil.setupHook(PRELOADER_SelectObject,"SelectObject")
    
    --replace require
    function PRELOADER_DISGUISED_REQUIRE(name)
        local b, e = pcall(PRELOADER_DISGUISED_REQUIRE_OLD, name)
        if not b then
            if name == "acutil" then
                return acutil
            elseif name == 'json' then
                return json
            else
                assert(b, e)
            end
        end
        return e
    end
    if PRELOADER_DISGUISED_REQUIRE ~= _G["require"] then
        PRELOADER_DISGUISED_REQUIRE_OLD = _G["require"]
        _G["require"] = PRELOADER_DISGUISED_REQUIRE
    end
    
    local function disguisefunc()
        
        local r, e = pcall(PRELOADER_PRELOAD_PRE)
        if not r then
            ui.SysMsg(e)
        end
        return PRELOADER_DISGUISED_FUNC()
    end
    local barrack_opened=false
    local function disguisefuncbarrack(addon, frame)
        
        if  ui.GetFrame("barrack_charlist") and ui.GetFrame("barrack_charlist"):IsVisible()==1 and barrack_opened==false then
            local r, e = pcall(PRELOADER_PRELOAD_BARRACK_PRE)
            if not r then
                ui.SysMsg(e)
            end
            barrack_opened=true
        end
        
        return PRELOADER_DISGUISED_FUNC_BARRACK()
    end
  
    local function disguisefuncbarrackend(addon, frame)
        
       
         
        barrack_opened=false
        
        
        return PRELOADER_DISGUISED_FUNC_BARRACK_END()
    end
    if login.LoadServerList ~= disguisefunc then
        PRELOADER_DISGUISED_FUNC = login.LoadServerList
        login.LoadServerList = disguisefunc
    end
    if  session.barrack.GetMyAccount ~= disguisefuncbarrack then
        PRELOADER_DISGUISED_FUNC_BARRACK =  session.barrack.GetMyAccount
        session.barrack.GetMyAccount = disguisefuncbarrack
    end
    if  barrack.IsHideLogin ~= disguisefuncbarrackend then
        PRELOADER_DISGUISED_FUNC_BARRACK_END =  barrack.IsHideLogin
        barrack.IsHideLogin = disguisefuncbarrackend
    end
    function PRELOADER_PRELOAD_PRE()
        ReserveScript("PRELOADER_PRELOAD()", 0.01)
    end
    function PRELOADER_PRELOAD_BARRACK_PRE(addon,frame)
        PRELOADER_PRELOAD_BARRACK(addon,frame)
    end
    function PRELOADER_PRELOAD()
        
        if not PRELOADER_DISGUISED_LOADED then
            debug.ReloadAddOnScp()
            PRELOADER_DISGUISED_LOADED = true
            
           
        end
        if ui.GetFrame("loginui_autojoin"):IsVisible() == 1 then
            local text = ui.GetFrame("loginui_autojoin"):CreateOrGetControl("richtext", "txtpreloaded", 10, 10, 200, 30)
            text:SetText("{s24}{ol}Preloaded Addons.")
            PRELOADER.fireEvents(PRELOADER.Events.EventsOnTitle)
        end
    end
    function PRELOADER_PRELOAD_BARRACK(addon,frame)
        
        PRELOADER.fireEvents(PRELOADER.Events.EventsOnBarrack,addon,frame)
    end
    function PRELOADER_ADDLISTENER(event, func)
        PRELOADER['_' .. event][#PRELOADER['_' .. event] + 1] = func
    end
end
--error trap
local r, e = pcall(fn)
if not r then
    local f = io.open('error_preloader.txt', "w+")
    f:write(e)
    f:flush()
    io.close(f)
    ui.SysMsg(e)
end
