--metaaddon_common

---------------------------------------------------------------------------------------
-- Copyright 2012 Rackspace (original), 2013-2021 Thijs Schreijer (modifications)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS-IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- see http://www.ietf.org/rfc/rfc4122.txt
--
-- Note that this is not a true version 4 (random) UUID.  Since `os.time()` precision is only 1 second, it would be hard
-- to guarantee spacial uniqueness when two hosts generate a uuid after being seeded during the same second.  This
-- is solved by using the node field from a version 1 UUID.  It represents the mac address.
--
-- 28-apr-2013 modified by Thijs Schreijer from the original [Rackspace code](https://github.com/kans/zirgo/blob/807250b1af6725bad4776c931c89a784c1e34db2/util/uuid.lua) as a generic Lua module.
-- Regarding the above mention on `os.time()`; the modifications use the `socket.gettime()` function from LuaSocket
-- if available and hence reduce that problem (provided LuaSocket has been loaded before uuid).
--
-- **Important:** the random seed is a global piece of data. Hence setting it is
-- an application level responsibility, libraries should never set it!
--
-- See this issue; [https://github.com/Kong/kong/issues/478](https://github.com/Kong/kong/issues/478)
-- It demonstrates the problem of using time as a random seed. Specifically when used from multiple processes.
-- So make sure to seed only once, application wide. And to not have multiple processes do that
-- simultaneously.

local M = {}
local math = require("math")
local os = require("os")
local string = require("string")

local bitsize = 32 -- bitsize assumed for Lua VM. See randomseed function below.
local lua_version = tonumber(_VERSION:match("%d%.*%d*")) -- grab Lua version used

local MATRIX_AND = {{0, 0}, {0, 1}}
local MATRIX_OR = {{0, 1}, {1, 1}}
local HEXES = "0123456789abcdef"

local math_floor = math.floor
local math_random = math.random
local math_abs = math.abs
local string_sub = string.sub
local to_number = tonumber
local assert = assert
local type = type

-- performs the bitwise operation specified by truth matrix on two numbers.
local function BITWISE(x, y, matrix)
	local z = 0
	local pow = 1
	while x > 0 or y > 0 do
		z = z + (matrix[x % 2 + 1][y % 2 + 1] * pow)
		pow = pow * 2
		x = math_floor(x / 2)
		y = math_floor(y / 2)
	end
	return z
end

local function INT2HEX(x)
	local s, base = "", 16
	local d
	while x > 0 do
		d = x % base + 1
		x = math_floor(x / base)
		s = string_sub(HEXES, d, d) .. s
	end
	while #s < 2 do
		s = "0" .. s
	end
	return s
end

----------------------------------------------------------------------------
-- Creates a new uuid. Either provide a unique hex string, or make sure the
-- random seed is properly set. The module table itself is a shortcut to this
-- function, so `my_uuid = uuid.new()` equals `my_uuid = uuid()`.
--
-- For proper use there are 3 options;
--
-- 1. first require `luasocket`, then call `uuid.seed()`, and request a uuid using no
-- parameter, eg. `my_uuid = uuid()`
-- 2. use `uuid` without `luasocket`, set a random seed using `uuid.randomseed(some_good_seed)`,
-- and request a uuid using no parameter, eg. `my_uuid = uuid()`
-- 3. use `uuid` without `luasocket`, and request a uuid using an unique hex string,
-- eg. `my_uuid = uuid(my_networkcard_macaddress)`
--
-- @return a properly formatted uuid string
-- @param hwaddr (optional) string containing a unique hex value (e.g.: `00:0c:29:69:41:c6`), to be used to compensate for the lesser `math_random()` function. Use a mac address for solid results. If omitted, a fully randomized uuid will be generated, but then you must ensure that the random seed is set properly!
-- @usage
-- local uuid = require("uuid")
-- print("here's a new uuid: ",uuid())
function M.new(hwaddr)
	-- bytes are treated as 8bit unsigned bytes.
	local bytes = {
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255),
		math_random(0, 255)
	}

	if hwaddr then
		assert(type(hwaddr) == "string", "Expected hex string, got " .. type(hwaddr))
		-- Cleanup provided string, assume mac address, so start from back and cleanup until we've got 12 characters
		local i, str = #hwaddr, hwaddr
		hwaddr = ""
		while i > 0 and #hwaddr < 12 do
			local c = str:sub(i, i):lower()
			if HEXES:find(c, 1, true) then
				-- valid HEX character, so append it
				hwaddr = c .. hwaddr
			end
			i = i - 1
		end
		assert(
			#hwaddr == 12,
			"Provided string did not contain at least 12 hex characters, retrieved '" .. hwaddr .. "' from '" .. str .. "'"
		)

		-- no split() in lua. :(
		bytes[11] = to_number(hwaddr:sub(1, 2), 16)
		bytes[12] = to_number(hwaddr:sub(3, 4), 16)
		bytes[13] = to_number(hwaddr:sub(5, 6), 16)
		bytes[14] = to_number(hwaddr:sub(7, 8), 16)
		bytes[15] = to_number(hwaddr:sub(9, 10), 16)
		bytes[16] = to_number(hwaddr:sub(11, 12), 16)
	end

	-- set the version
	bytes[7] = BITWISE(bytes[7], 0x0f, MATRIX_AND)
	bytes[7] = BITWISE(bytes[7], 0x40, MATRIX_OR)
	-- set the variant
	bytes[9] = BITWISE(bytes[9], 0x3f, MATRIX_AND)
	bytes[9] = BITWISE(bytes[9], 0x80, MATRIX_OR)
	return INT2HEX(bytes[1]) ..
		INT2HEX(bytes[2]) ..
			INT2HEX(bytes[3]) ..
				INT2HEX(bytes[4]) ..
					"-" ..
						INT2HEX(bytes[5]) ..
							INT2HEX(bytes[6]) ..
								"-" ..
									INT2HEX(bytes[7]) ..
										INT2HEX(bytes[8]) ..
											"-" ..
												INT2HEX(bytes[9]) ..
													INT2HEX(bytes[10]) ..
														"-" ..
															INT2HEX(bytes[11]) ..
																INT2HEX(bytes[12]) ..
																	INT2HEX(bytes[13]) .. INT2HEX(bytes[14]) .. INT2HEX(bytes[15]) .. INT2HEX(bytes[16])
end

----------------------------------------------------------------------------
-- Improved randomseed function.
-- Lua 5.1 and 5.2 both truncate the seed given if it exceeds the integer
-- range. If this happens, the seed will be 0 or 1 and all randomness will
-- be gone (each application run will generate the same sequence of random
-- numbers in that case). This improved version drops the most significant
-- bits in those cases to get the seed within the proper range again.
-- @param seed the random seed to set (integer from 0 - 2^32, negative values will be made positive)
-- @return the (potentially modified) seed used
-- @usage
-- local socket = require("socket")  -- gettime() has higher precision than os.time()
-- local uuid = require("uuid")
-- -- see also example at uuid.seed()
-- uuid.randomseed(socket.gettime()*10000)
-- print("here's a new uuid: ",uuid())
function M.randomseed(seed)
	seed = math_floor(math_abs(seed))
	if seed >= (2 ^ bitsize) then
		-- integer overflow, so reduce to prevent a bad seed
		seed = seed - math_floor(seed / 2 ^ bitsize) * (2 ^ bitsize)
	end
	if lua_version < 5.2 then
		-- 5.1 uses (incorrect) signed int
		math.randomseed(seed - 2 ^ (bitsize - 1))
	else
		-- 5.2 uses (correct) unsigned int
		math.randomseed(seed)
	end
	return seed
end

----------------------------------------------------------------------------
-- Seeds the random generator.
-- It does so in 3 possible ways;
--
-- 1. if in ngx_lua, use `ngx.time() + ngx.worker.pid()` to ensure a unique seed
-- for each worker. It should ideally be called from the `init_worker` context.
-- 2. use luasocket `gettime()` function, but it only does so when LuaSocket
-- has been required already.
-- 3. use `os.time()`: this only offers resolution to one second (used when
-- LuaSocket hasn't been loaded)
--
-- **Important:** the random seed is a global piece of data. Hence setting it is
-- an application level responsibility, libraries should never set it!
-- @usage
-- local socket = require("socket")  -- gettime() has higher precision than os.time()
-- -- LuaSocket loaded, so below line does the same as the example from randomseed()
-- uuid.seed()
-- print("here's a new uuid: ",uuid())
function M.seed()
	if _G.ngx ~= nil then
		return M.randomseed(ngx.time() + ngx.worker.pid())
	elseif package.loaded["socket"] and package.loaded["socket"].gettime then
		return M.randomseed(package.loaded["socket"].gettime() * 10000)
	else
		return M.randomseed(os.time())
	end
end
--- Iterate over the sorted elements from an iterable.
--
-- A custom `key` function can be supplied, and it will be applied to each
-- element being compared to obtain a sorting key, which will be the values
-- used for comparisons when sorting. The `reverse` flag can be set to sort
-- the elements in descending order.
--
-- Note that `iterable` must be consumed before sorting, so the returned
-- iterator runs in *O(n)* memory space. Sorting is done internally using
-- `table.sort`.
--
-- @tparam coroutine iterable An iterator.
-- @tparam[opt] function key Function used to retrieve the sorting key used
--   to compare elements.
-- @tparam[opt] boolean reverse Whether to yield the elements in reverse
--   (descending) order. If not supplied, defaults to `false`.
-- @treturn coroutine An iterator over the sorted elements.
--
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
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.cls = g.cls or {}
g.debug = true
g.fn = g.fn or {}
g.lib = g.lib or {}
g.fn.trycatch = function(what)
	local status, result = pcall(what.try)
	if not status then
		what.catch(result)
	end
	return result
end

g.fn.dbgout = function(msg)
	g.fn.trycatch {
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
g.fn.errout = function(msg)
	g.fn.trycatch {
		try = function()
			CHAT_SYSTEM(msg)
			print(msg)
		end,
		catch = function(error)
		end
	}
end
g.fn.tableFirst=function(t)
	for k,v in pairs(t) do
		return v
	end
end


g.fn._uuidgen = M.seed()
g.fn.getUUID = function()
	return g.fn._uuidgen()
end
g.fn.lazy = function(fn)
	g.fn._lazyFuncs = g.fn._lazyFuncs or {}
	g.fn._lazyFuncs[#g.fn._lazyFuncs + 1] = fn
end
g.fn.lazyLoad = function(fn)
	for _, v in ipairs(g.fn._lazyFuncs) do
		v()
	end
end
g.fn.lazy(
	function()
		g.lib.aodrawpic = LIBAODRAWPICV1_3
	end
)
local function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end
g.fn.CombineTable=function(t1,t2)
    local t = t1
    for key, value in pairs(t2) do
        if(t[key] == nil and value)then
            t[key] = value
        end
    end
    return t
end 


g.fn.len=function (T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
g.fn.inherit=function(obj,...)
    local chain={...}
    local object=obj
   
    local combinedmeta={}
    local hierarchy={}
    local behindclasses={}



    for _,super in pairs(chain) do
        if(not  behindclasses[super._className])then
            behindclasses[super._className]=super
        end
        
            combinedmeta=g.fn.CombineTable(combinedmeta,super)
            hierarchy[#hierarchy+1]={super=super}
            if(super._hierarchy) then
                for _,v in ipairs(super._hierarchy) do
                    if(not  behindclasses[v.super._className])then
                        behindclasses[v.super._className]=v.super
                    end
                    
                    combinedmeta=g.fn.CombineTable(combinedmeta,v.super)
                    hierarchy[#hierarchy+1]={
                        super=v.super
                    }
                   
                end
            end
        
    end

    --remove duplication
    local hash = {}
    local res = {}
    
  
    for _,v in ipairs(hierarchy) do
        if (not hash[v.super._className]) then
            res[#res+1] = v -- you could print here instead of saving to result table if you wanted
            hash[v.super._className] = true
        end
    end
    
    hierarchy=ReverseTable(res)
    table.insert(hierarchy,{super=object})
    object=g.fn.CombineTable(object,combinedmeta)

    behindclasses[object._className]=object
    object._hierarchy=hierarchy
    object._supers=behindclasses

    return object
end
g.fn.CreateInstance=function (typename,...)
	local obj=g.cls[typename](...):init()
	return obj
end

--referenced from http://d.hatena.ne.jp/Ko-Ta/20100830/p1
-- lua
-- テーブルシリアライズ
function g.fn.luavalue2str(v)
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

function g.fn.luafield2str(v)
	local vt = type(v);
	
	if (vt=="number")then
		return string.format("[%d]",v);
	end;
	if (vt=="string")then
		return string.format("%s",v);
	end;
	return 'UnknownField';
end;

function g.fn.luaserialize(t)
	local f,v,buf;
	
	-- テーブルじゃない場合
	if not(type(t)=="table")then
		return g.fn.value2str(t);
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
			buf = buf .. g.fn.luafield2str(f) .. "=" .. g.fn.luaserialize(v);
		else
			buf = buf .. g.fn.luafield2str(f) .. "=" .. g.fn.luavalue2str(v);
		end;
		-- 次の要素
		f,v = next(t,f);
	end
	
	buf = "{" .. buf .. "}";
	return buf;
end;
function g.fn.lualoadfromfile_internal(env,path,dummy)
	local _ENV = env
    local result,data=pcall(dofile,path)
    if(result)then
        return data
    else
        --print("FAIL"..data)
        return dummy
    end
end
function g.fn.lualoadfromfile(path,dummy)
    local env = {dofile=dofile,pcall=pcall}
    local lff=g.fn.loadfromfile_internal
   
    local result,data=pcall(lff,env,path,dummy)
    if(result)then
        return data
    else
        return dummy
    end
end;
function g.fn.luasavetofile(path,data)
    local s="return "..g.fn.luaserialize(data)
    --CHAT_SYSTEM(tostring(#s))
    local fn=io.open(path,"w+")
    fn:write(s)
    fn:flush()
    fn:close()
end;
g.cls.MAObject = function()
	local self={

		_className="MAObject",
		_id=nil,
		_hierarchy={},
		_released=false,
		_supers={},
		init=function(self)
			--don't be confused with the initialize function of the class
			--don't call in the constructor
			--don't inherit this function
			self._id=""..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999)
		
			local fail=false
			local breaking=false
			for i,v in ipairs(self._hierarchy) do
				g.fn.trycatch({
					try = function()
					--DBGOUT("init>"..v.super._className)
					if(v.super.preInitImpl(self)~=nil)then
						fail=true
						return nil
					end
				end,
				catch = function(error)
					g.fn.errout("MAObject.preInit()"..error)
					fail=true
				end
			})
			end
			if(breaking)then
				self._fail=true
				return self
			end
			
			for i,v in ipairs(self._hierarchy) do
				g.fn.trycatch({
					try = function()
					--DBGOUT("init>"..v.super._className)
					if(v.super.initImpl(self)~=nil)then
						return nil
					end
				end,
				catch = function(error)
					g.fn.errout("MAObject.init()"..error)
					fail=true
				end
			})
			end
			if(breaking)then
				self._fail=true
				return self
			end

			for i,v in ipairs(self._hierarchy) do
				--DBGOUT("lazyinit>"..v.super._className)
				g.fn.trycatch({
					try = function()
						v.super.lazyInitImpl(self)
					end,
					catch = function(error)
						g.fn.errout("MAObject.lazyInit()"..error)
						fail=true
					end
				})
			end 
			if(breaking)then
				self._fail=true
				return self
			end

			if fail then
				self._fail=true
			end
			return self
		end,
		isFailed=function(self)
			return self._fail
		end,
		isReleased=function(self)
			return self._released
		end,
		-- hook method
		-- pre hook function's return is indicated to be ignored.true is ignored, false is not ignored.
		-- post hook function's return is modified to be the return of the original hook function.
		hook=function(self,name,prefunc,postfunc)

			if(not self[name])then
				error("no such method:"..name)
			end
			if(self["_originalFunc_"..name])then
				print("_common.lua:"..self._className.. "> hook method:"..name.." is already hooked.")
			end
			--replace the original method
			self["_originalFunc_"..name]=self[name]
			self[name]=function(self,...)
		
				if(prefunc)then
					local tbl={prefunc(self,...)}
					if tbl and tbl[1] then
						table.remove(tbl,1)
						return table.unpack(tbl)
					end
				end
				local result={self["_originalFunc_"..name](self,...)}
				if(postfunc)then
					local tbl={postfunc(self,result,...)}
					if tbl then
						return table.unpack(tbl)
					end
				end
				return table.unpack(result)
			end
		
		end,
		release=function(self)

			--don't call in the constructor
			--don't inherit this function
			local called={}
			local reversed=ReverseTable(self._hierarchy)
			
			for i,v in ipairs(reversed) do
				v.super.releaseImpl(self)
			end
			self._released=true
			return self
		end,
		preInitImpl=function(self)
			--override me
		
			
		end,
		initImpl=function(self)
			--override me
		
			
		end,
		lazyInitImpl=function(self)
			--override me
		
			
		end,
		releaseImpl=function(self)
			--override me
		end,
		
		getID=function(self)
			return self._id
		end,
		
		instanceOf=function (self,super)
			if(type(super)=="function")then
				error "instanceOf must be needed object.not constructor."
			end
			if(self._className==super._className)then
				return true
			end
			if(self._supers[super._className])then
				return true
			end
			return false
			
		end,
		assign=function(self,obj)
			 self:assignImpl(obj)
			 return self
		end, 
		assignImpl=function(self,obj)
			
		end, 
		clone=function (self)
			return g.fn.CreateInstance(self._className):assign(self)
		end,
		super=function(self)
			return self._hierarchy[#self._hierarchy].super		
		end
	}
	self._hierarchy[#self._hierarchy+1]={super=self}
	return self
end

g.cls.MASerializable = function()
	local self={
		_className="MASerializable",
		serialize=function(self)
			--override me
			return {}
		end,
		deserialize=function(self,obj)
			--override me
		end,
		assignImpl=function(self,obj)
			--override me
			self._supers["MAObject"].assignImpl(self,obj)
		end,
	}
	local obj= g.fn.inherit(self,g.cls.MAObject())

    return obj
end