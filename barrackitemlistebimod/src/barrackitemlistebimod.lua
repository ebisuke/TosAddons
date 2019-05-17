--[[---------------
LuaBit v0.4
-------------------
a bitwise operation lib for lua.
http://luaforge.net/projects/bit/
How to use:
-------------------
 bit.bnot(n) -- bitwise not (~n)
 bit.band(m, n) -- bitwise and (m & n)
 bit.bor(m, n) -- bitwise or (m | n)
 bit.bxor(m, n) -- bitwise xor (m ^ n)
 bit.brshift(n, bits) -- right shift (n >> bits)
 bit.blshift(n, bits) -- left shift (n << bits)
 bit.blogic_rshift(n, bits) -- logic right shift(zero fill >>>)
 
Please note that bit.brshift and bit.blshift only support number within
32 bits.
2 utility functions are provided too:
 bit.tobits(n) -- convert n into a bit table(which is a 1/0 sequence)
               -- high bits first
 bit.tonumb(bit_tbl) -- convert a bit table into a number 
-------------------
Under the MIT license.
copyright(c) 2006~2007 hanzhao (abrash_han@hotmail.com)
--]]---------------



------------------------
-- bit lib implementions

local function check_int(n)
    -- checking not float
    if(n - math.floor(n) > 0) then
     error("trying to use bitwise operation on non-integer!")
    end
   end
   
   local function to_bits(n)
    check_int(n)
    if(n < 0) then
     -- negative
     return to_bits(bit.bnot(math.abs(n)) + 1)
    end
    -- to bits table
    local tbl = {}
    local cnt = 1
    while (n > 0) do
     local last = math.mod(n,2)
     if(last == 1) then
      tbl[cnt] = 1
     else
      tbl[cnt] = 0
     end
     n = (n-last)/2
     cnt = cnt + 1
    end
   
    return tbl
   end
   
   local function tbl_to_number(tbl)
    local n = table.getn(tbl)
   
    local rslt = 0
    local power = 1
    for i = 1, n do
     rslt = rslt + tbl[i]*power
     power = power*2
    end
    
    return rslt
   end
   
   local function expand(tbl_m, tbl_n)
    local big = {}
    local small = {}
    if(table.getn(tbl_m) > table.getn(tbl_n)) then
     big = tbl_m
     small = tbl_n
    else
     big = tbl_n
     small = tbl_m
    end
    -- expand small
    for i = table.getn(small) + 1, table.getn(big) do
     small[i] = 0
    end
   
   end
   
   local function bit_or(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n)
   
    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
     if(tbl_m[i]== 0 and tbl_n[i] == 0) then
      tbl[i] = 0
     else
      tbl[i] = 1
     end
    end
    
    return tbl_to_number(tbl)
   end
   
   local function bit_and(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n) 
   
    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
     if(tbl_m[i]== 0 or tbl_n[i] == 0) then
      tbl[i] = 0
     else
      tbl[i] = 1
     end
    end
   
    return tbl_to_number(tbl)
   end
   
   local function bit_not(n)
    
    local tbl = to_bits(n)
    local size = math.max(table.getn(tbl), 32)
    for i = 1, size do
     if(tbl[i] == 1) then 
      tbl[i] = 0
     else
      tbl[i] = 1
     end
    end
    return tbl_to_number(tbl)
   end
   
   local function bit_xor(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n) 
   
    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
     if(tbl_m[i] ~= tbl_n[i]) then
      tbl[i] = 1
     else
      tbl[i] = 0
     end
    end
    
    --table.foreach(tbl, print)
   
    return tbl_to_number(tbl)
   end
   
   local function bit_rshift(n, bits)
    check_int(n)
    
    local high_bit = 0
    if(n < 0) then
     -- negative
     n = bit_not(math.abs(n)) + 1
     high_bit = 2147483648 -- 0x80000000
    end
   
    for i=1, bits do
     n = n/2
     n = bit_or(math.floor(n), high_bit)
    end
    return math.floor(n)
   end
   
   -- logic rightshift assures zero filling shift
   local function bit_logic_rshift(n, bits)
    check_int(n)
    if(n < 0) then
     -- negative
     n = bit_not(math.abs(n)) + 1
    end
    for i=1, bits do
     n = n/2
    end
    return math.floor(n)
   end
   
   local function bit_lshift(n, bits)
    check_int(n)
    
    if(n < 0) then
     -- negative
     n = bit_not(math.abs(n)) + 1
    end
   
    for i=1, bits do
     n = n*2
    end
    return bit_and(n, 4294967295) -- 0xFFFFFFFF
   end
   
   local function bit_xor2(m, n)
    local rhs = bit_or(bit_not(m), bit_not(n))
    local lhs = bit_or(m, n)
    local rslt = bit_and(lhs, rhs)
    return rslt
   end
   
   --------------------
   -- bit lib interface
   
   local bit = {
    -- bit operations
    bnot = bit_not,
    band = bit_and,
    bor  = bit_or,
    bxor = bit_xor,
    brshift = bit_rshift,
    blshift = bit_lshift,
    bxor2 = bit_xor2,
    blogic_rshift = bit_logic_rshift,
   
    -- utility func
    tobits = to_bits,
    tonumb = tbl_to_number,
   }
   
   
luabit= bit
   
   
   
   --[[
   for i = 1, 100 do
    for j = 1, 100 do
     if(bit.bxor(i, j) ~= bit.bxor2(i, j)) then
      error("bit.xor failed.")
     end
    end
   end
   --]]
   
   
   
   
local table = require("table")
local string = require("string")

local tostr = string.char

local double_decode_count = 0
local double_encode_count = 0

-- cache bitops
local bor,band,bxor,rshift = luabit.bor,luabit.band,luabit.bxor,luabit.brshift
if not rshift then -- luajit differ from luabit
  rshift = luabit.rshift
end 

local function byte_mod(x,v)
  if x < 0 then
    x = x + 256
  end
  return (x%v)
end


-- buffer
local strbuf="" -- for unpacking
local strary={} -- for packing


local function strary_append_int16(n,h)
  if n < 0 then
     n = n + 65536
  end
  table.insert( strary, tostr(h, math.floor(n / 256), n % 256 ) )
end
local function strary_append_int32(n,h)
  if n < 0 then
     n = n  + 4294967296
  end
  table.insert( strary, tostr(h,
      math.floor(n/16777216),
      math.floor(n/65536) %256,
      math.floor(n/256) % 256,
      n % 256 ) )
end   

local doubleto8bytes
local strary_append_double = function(n)
  -- assume double
  double_encode_count = double_encode_count + 1
  local b = doubleto8bytes(n)
  --                             print( string.format( "doubleto8bytes: %x %x %x %x %x %x %x %x", b:byte(1), b:byte(2), b:byte(3), b:byte(4), b:byte(5), b:byte(6), b:byte(7), b:byte(8)))
  table.insert( strary, tostr(0xcb))
  table.insert( strary, string.reverse(b) )   -- reverse: make big endian double precision
end


--- IEEE 754

-- out little endian
doubleto8bytes = function(x)
  local function grab_byte(v)
    return math.floor(v / 256), tostr(math.fmod(math.floor(v), 256))
  end
  local sign = 0
  if x < 0 then sign = 1; x = -x end
  local mantissa, exponent = math.frexp(x)
  if x == 0 then -- zero
    mantissa, exponent = 0, 0
  elseif x == 1/0 then
    mantissa, exponent = 0, 2047
  else
    mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, 53)
    exponent = exponent + 1022
  end
  --   print("doubleto8bytes: exp:", exponent, "mantissa:", mantissa , "sign:", sign )
  
  local v, byte = "" -- convert to bytes
  x = mantissa
  for i = 1,6 do
    x, byte = grab_byte(x); v = v..byte -- 47:0
  end
  x, byte = grab_byte(exponent * 16 + x);  v = v..byte -- 55:48
  x, byte = grab_byte(sign * 128 + x); v = v..byte -- 63:56
  return v
end

local function bitstofrac(ary)
  local x = 0
  local cur = 0.5
  for i,v in ipairs(ary) do
     x = x + cur * v
     cur = cur / 2
  end
  return x   
end

local function bytestobits(ary)
  local out={}
  for i,v in ipairs(ary) do
    for j=0,7,1 do
      table.insert(out, band( rshift(v,7-j), 1 ) )
    end
  end
  return out
end

local function dumpbits(ary)
  local s=""
  for i,v in ipairs(ary) do
    s = s .. v .. " "
    if (i%8)==0 then s = s .. " " end
  end
  print(s)
end

-- get little endian
local function bytestodouble(v)
  -- sign:1bit
  -- exp: 11bit (2048, bias=1023)
  local sign = math.floor(v:byte(8) / 128)
  local exp = band( v:byte(8), 127 ) * 16 + rshift( v:byte(7), 4 ) - 1023 -- bias
  -- frac: 52 bit
  local fracbytes = {
    band( v:byte(7), 15 ), v:byte(6), v:byte(5), v:byte(4), v:byte(3), v:byte(2), v:byte(1) -- big endian
  }
  local bits = bytestobits(fracbytes)
   
  for i=1,4 do table.remove(bits,1) end

--   dumpbits(bits)

  if sign == 1 then sign = -1 else sign = 1 end
   
  local frac = bitstofrac(bits)
  if exp == -1023 and frac==0 then return 0 end
  if exp == 1024 and frac==0 then return 1/0 *sign end
  local real = math.ldexp(1+frac,exp)

--   print( "sign:", sign, "exp:", exp,  "frac:", frac, "real:", real, "v:", v:byte(1),v:byte(2),v:byte(3),v:byte(4),v:byte(5),v:byte(6),v:byte(7),v:byte(8) )
  return real * sign
end

--- packers

local packers = {}

packers.dynamic = function(data)
  local t = type(data)
  return packers[t](data)
end

packers["nil"] = function(data)
  table.insert( strary, tostr(0xc0))
end

packers.boolean = function(data)
  if data then -- pack true
    table.insert( strary, tostr(0xc3))
  else -- pack false
    table.insert( strary, tostr(0xc2))
  end
end

packers.number = function(n)
  if math.floor(n) == n then -- integer
    if n >= 0 then -- positive integer
      if n < 128 then -- positive fixnum
         table.insert( strary, tostr(n))
      elseif n < 256 then -- uint8
         table.insert(strary, tostr(0xcc,n))
      elseif n < 65536 then -- uint16
        strary_append_int16(n,0xcd)
      elseif n < 4294967296 then -- uint32
        strary_append_int32(n,0xce)
      else -- lua cannot handle uint64, so double
         strary_append_double(n)
      end
    else -- negative integer
      if n >= -32 then -- negative fixnum
         table.insert( strary, tostr( 0xe0 + ((n+256)%32)) )
      elseif n >= -128 then -- int8
         table.insert( strary, tostr(0xd0,byte_mod(n,0x100)))
      elseif n >= -32768 then -- int16
        strary_append_int16(n,0xd1)
      elseif n >= -2147483648 then -- int32
        strary_append_int32(n,0xd2)
      else -- lua cannot handle int64, so double
         strary_append_double(n)
      end
    end
  else -- floating point
     strary_append_double(n)
  end
end

packers.string = function(data)
  local n = #data
  if n < 32 then
     table.insert( strary, tostr( 0xa0+n ) )
  elseif n < 65536 then
    strary_append_int16(n,0xda)
  elseif n < 4294967296 then
    strary_append_int32(n,0xdb)
  else
    error("overflow")
  end
  table.insert( strary, data)
end

packers["function"] = function(data)
  error("unimplemented:function")
end

packers.userdata = function(data)
  error("unimplemented:userdata")
end

packers.thread = function(data)
  error("unimplemented:thread")
end

packers.table = function(data)
  local is_map,ndata,nmax = false,0,0
  for k,_ in pairs(data) do
    if type(k) == "number" then
      if k > nmax then nmax = k end
    else is_map = true end
    ndata = ndata+1
  end
  if is_map then -- pack as map
    if ndata < 16 then
       table.insert( strary, tostr(0x80+ndata))
    elseif ndata < 65536 then
      strary_append_int16(ndata,0xde)
    elseif ndata < 4294967296 then
      strary_append_int32(ndata,0xdf)
    else
      error("overflow")
    end
    for k,v in pairs(data) do
      packers[type(k)](k)
      packers[type(v)](v)
    end
  else -- pack as array
    if nmax < 16 then
       table.insert( strary, tostr( 0x90+nmax ) )
    elseif nmax < 65536 then
      strary_append_int16(nmax,0xdc)
    elseif nmax < 4294967296 then
      strary_append_int32(nmax,0xdd)
    else
      error("overflow")
    end
    for i=1,nmax do packers[type(data[i])](data[i]) end
  end
end

-- types decoding

local types_map = {
    [0xc0] = "nil",
    [0xc2] = "false",
    [0xc3] = "true",
    [0xca] = "float",
    [0xcb] = "double",
    [0xcc] = "uint8",
    [0xcd] = "uint16",
    [0xce] = "uint32",
    [0xcf] = "uint64",
    [0xd0] = "int8",
    [0xd1] = "int16",
    [0xd2] = "int32",
    [0xd3] = "int64",
    [0xda] = "raw16",
    [0xdb] = "raw32",
    [0xdc] = "array16",
    [0xdd] = "array32",
    [0xde] = "map16",
    [0xdf] = "map32",
  }

local type_for = function(n)
                    
  if types_map[n] then return types_map[n]
  elseif n < 0xc0 then
    if n < 0x80 then return "fixnum_posi"
    elseif n < 0x90 then return "fixmap"
    elseif n < 0xa0 then return "fixarray"
    else return "fixraw" end
  elseif n > 0xdf then return "fixnum_neg"
  else return "undefined" end
end

local types_len_map = {
  uint16 = 2, uint32 = 4, uint64 = 8,
  int16 = 2, int32 = 4, int64 = 8,
  float = 4, double = 8,
}




--- unpackers

local unpackers = {}

local unpack_number = function(offset,ntype,nlen)
  --                         print("unpack_number: ntype:", ntype, " nlen:", nlen, "ofs:",offset, "nstrbuf:",#strbuf )
  local b1,b2,b3,b4,b5,b6,b7,b8
  if nlen>=2 then
    b1,b2 = string.byte( strbuf, offset+1, offset+2 )
  end
  if nlen>=4 then
    b3,b4 = string.byte( strbuf, offset+3, offset+4 )
  end
  if nlen>=8 then
    b5,b6,b7,b8 = string.byte( strbuf, offset+5, offset+8 )
  end
  
  if ntype == "uint16_t" then
    --                            print( string.format("u16 bytes: %x %x", b1, b2 ))
    return b1 * 256 + b2
  elseif ntype == "uint32_t" then
    --                            print( string.format("u32 bytes: %x %x %x %x ", b1, b2, b3, b4 ))
    return b1*65536*256 + b2*65536 + b3 * 256 + b4
  elseif ntype == "int16_t" then
    local n = b1 * 256 + b2
    local nn = (65536 - n)*-1
    if nn == -65536 then nn = 0 end
    --                            print( string.format("i16 bytes: %x %x", b1, b2 ),n,nn)
    return nn
  elseif ntype == "int32_t" then
    local n = b1*65536*256 + b2*65536 + b3 * 256 + b4
    local nn = ( 4294967296 - n ) * -1
    if nn == -4294967296 then nn = 0 end
    --                            print( string.format("i32 bytes: %x %x %x %x ", b1, b2, b3, b4 ), n, nn )
    return nn
  elseif ntype == "double_t" then
    --                            print( string.format("doublebytes networked: %x %x %x %x %x %x %x %x", b1, b2, b3, b4,b5,b6,b7,b8 ) )
    local s = tostr(b8,b7,b6,b5,b4,b3,b2,b1)                            
    --                            print(" unpack_double: slen:", string.len(s), b1, b2, b3, b4, b5, b6, b7, b8 )
    double_decode_count = double_decode_count + 1
    local n = bytestodouble( s )
    return n
  else
    error("unpack_number: not impl:" .. ntype )
  end
end



local function unpacker_number(offset)
local obj_type = type_for( string.byte( strbuf, offset+1, offset+1 ) )
local nlen = types_len_map[obj_type]
local ntype
if (obj_type == "float") then
  error("float is not implemented")
else
  ntype = obj_type .. "_t"
end
--  print("unpacker_number:  ntype:", ntype , " nlen:", nlen )
return offset+nlen+1,unpack_number(offset+1,ntype,nlen)
end

local function unpack_map(offset,n)
  local r = {}
  local k,v
  for i=1,n do
    offset,k = unpackers.dynamic(offset)
    assert(offset)
    offset,v = unpackers.dynamic(offset)
    assert(offset)
    r[k] = v
  end
  return offset,r
end

local function unpack_array(offset,n)
  local r = {}
  for i=1,n do
    offset,r[i] = unpackers.dynamic(offset)
    assert(offset)
  end
  return offset,r
end

function unpackers.dynamic(offset)
  --  print("unpackers.dynamic: strbuf:", #strbuf, " ofs:", offset )
  if offset >= #strbuf then error("need more data") end
  local obj_type = type_for( string.byte( strbuf, offset+1, offset+1 ) )
  --   print("unpackers.dynamic: type:", obj_type, string.format(" typebyte:%x", buf[offset+1]))
  return unpackers[obj_type](offset)
end

function unpackers.undefined(offset)
   error("unimplemented:undefined")
end

unpackers["nil"] = function(offset)
  return offset+1,nil
end

unpackers["false"] = function(offset)
  return offset+1,false
end

unpackers["true"] = function(offset)
  return offset+1,true
end

unpackers.fixnum_posi = function(offset)
  return offset+1, string.byte( strbuf, offset+1, offset+1) 
end

unpackers.uint8 = function(offset)
  return offset+2, string.byte( strbuf, offset+2, offset+2 )
end

unpackers.uint16 = unpacker_number
unpackers.uint32 = unpacker_number
unpackers.uint64 = unpacker_number

unpackers.fixnum_neg = function(offset)
  -- alternative to cast below:
  local n = string.byte( strbuf, offset+1, offset+1)
  local nn = ( 256 - n ) * -1
  return offset+1,  nn
end

unpackers.int8 = function(offset)
  local i = string.byte( strbuf, offset+2, offset+2 )
  if i > 127 then
    i = (256 - i ) * -1
  end
  return offset+2, i
end

unpackers.int16 = unpacker_number
unpackers.int32 = unpacker_number
unpackers.int64 = unpacker_number

unpackers.float = unpacker_number
unpackers.double = unpacker_number

unpackers.fixraw = function(offset)
  local n = byte_mod( string.byte( strbuf, offset+1, offset+1) ,0x1f+1)
  --  print("unpackers.fixraw: offset:", offset, "#buf:", #buf, "n:",n  )
  local b
  if ( #strbuf - 1 - offset ) < n then
    error("require more data")
  end  
  
  if n > 0 then
    b = string.sub( strbuf, offset + 1 + 1, offset + 1 + 1 + n - 1 )
  else
    b = ""
  end  
  return offset+n+1,b
end

unpackers.raw16 = function(offset)
  local n = unpack_number(offset+1,"uint16_t",2)
  if ( #strbuf - 1 - 2 - offset ) < n then
     error("require more data")
  end
  local b = string.sub( strbuf, offset+1+1+2, offset+1 + 1+2 + n - 1 )
  return offset+n+3,b 
end

unpackers.raw32 = function(offset)
  local n = unpack_number(offset+1,"uint32_t",4)
  if ( #strbuf  - 1 - 4 - offset ) < n then
    error( "require more data (possibly bug)")
  end  
  --  print("unpackers.raw32: n:", n, string.format("%x %x %x %x %x", buf[offset+1], buf[offset+2], buf[offset+3], buf[offset+4], buf[offset+5]) )
  local b = string.sub( strbuf, offset+1+ 1+4, offset+1 + 1+4 +n -1 )
  return offset+n+5,b
end

unpackers.fixarray = function(offset)
  return unpack_array( offset+1,byte_mod( string.byte( strbuf, offset+1,offset+1),0x0f+1))
end

unpackers.array16 = function(offset)
  return unpack_array(offset+3,unpack_number(offset+1,"uint16_t",2)) 
end

unpackers.array32 = function(offset)
  return unpack_array(offset+5,unpack_number(offset+1,"uint32_t",4))
end

unpackers.fixmap = function(offset)
  return unpack_map(offset+1,byte_mod( string.byte( strbuf, offset+1,offset+1),0x0f+1))
end

unpackers.map16 = function(offset)
  return unpack_map(offset+3,unpack_number(offset+1,"uint16_t",2))
end

unpackers.map32 = function(offset)
  return unpack_map(offset+5,unpack_number(offset+1,"uint32_t",4))
end

-- Main functions

local ljp_pack = function(data)
  strary={}
  packers.dynamic(data)
  local s = table.concat(strary,"")
  --                    print("strary len:", #strary, strary[1], s,  string.sub(s,1) )                    
  return s
end

local ljp_unpack = function(s,offset)
  if offset == nil then offset = 0 end
  if type(s) ~= "string" then return false,"invalid argument" end
  local data
  strbuf = s
  offset,data = unpackers.dynamic(offset)
  return offset,data
end

local function ljp_stat()
  return {
    double_decode_count = double_decode_count,
    double_encode_count = double_encode_count
  }
end

local msgpack = {
  pack = ljp_pack,
  unpack = ljp_unpack,
  stat = ljp_stat
}

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end


function EBI_LOAD(filepath)

    EBI_try_catch{
        try=function()

            local fd=io.open(filepath,"rb")
            if fd~=nil then
                local alldata=fd:read("*a");
                fd:close()
                local count,message=msgpack.unpack(alldata)
                return message
            else
                return nil;
            end
        end,
        catch=function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function EBI_SAVE(filepath,table)

    EBI_try_catch{
        try=function()
            local alldata=msgpack.pack(table)

            local fd=io.open(filepath,"wb+")
            fd:write(alldata)
            fd:flush()
            fd:close()
        end,
        catch=function(error)
            CHAT_SYSTEM(error)
        end
}

end
_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['BARRACKITEMLISTEBIMOD'] = _G['ADDONS']['BARRACKITEMLISTEBIMOD'] or {};
local acutil = require('acutil')
local g = _G['ADDONS']['BARRACKITEMLISTEBIMOD']

g.settingPath = '../addons/BARRACKITEMLISTEBIMOD/'
g.userlist  = acutil.loadJSON(g.settingPath..'userlist.json',nil) or {}
g.warehouseList = EBI_LOAD(g.settingPath..'warehouse.bin',nil) or {}
g.nodeList = {
        {"Unused" , "シルバー"}
        ,{"Weapon" , "武器"}
        ,{"SubWeapon" , "サブ武器"}
        ,{"Armor" , "アーマー"}
        ,{"Drug" , "消費アイテム"}
        ,{"Recipe" ,"レシピ"}
        ,{"Material","素材"}
        ,{"Gem","ジェム"}
        ,{"Card","カード"}
        ,{"Collection","コレクション"}
        ,{"Quest" ,"クエスト"}
        ,{"Event" ,"イベント"}
        ,{"Cube" , "キューブ"}
        ,{"Premium" ,"プレミアム"}
        ,{"warehouse","倉庫"}
    }
g.setting = acutil.loadJSON(g.settingPath..'setting.json',nil)
if not g.setting then
    g.setting = {}
    g.setting.col = 14
    g.setting.hideNode = {}
    g.setting.OpenNodeAll = false
    acutil.saveJSON(g.settingPath..'setting.json',g.setting)
end

g.itemlist = g.itemlist or {}
for k,v in pairs(g.userlist) do
    ---if not g.itemlist[k] then
        g.itemlist[k] = EBI_LOAD(g.settingPath..k..'.bin',nil)

    --end
end

function OPEN_BARRACKITEMLISTEBIMOD()
	ui.ToggleFrame('barrackitemlistebimod')
end




function BARRACKITEMLISTEBIMOD_ON_INIT(addon,frame)
    local cid = info.GetCID(session.GetMyHandle())
    g.userlist[cid] = info.GetPCName(session.GetMyHandle())
    acutil.saveJSON(g.settingPath..'userlist.json',g.userlist)
    acutil.slashCommand('/itemlist', BARRACKITEMLISTEBIMOD_COMMAND)
    acutil.slashCommand('/il',BARRACKITEMLISTEBIMOD_COMMAND)
    
    acutil.setupEvent(addon,'GAME_TO_BARRACK','BARRACKITEMLISTEBIMOD_SAVE_LIST')
    acutil.setupEvent(addon,'GAME_TO_LOGIN','BARRACKITEMLISTEBIMOD_SAVE_LIST')
    acutil.setupEvent(addon,'DO_QUIT_GAME','BARRACKITEMLISTEBIMOD_SAVE_LIST')
    acutil.setupEvent(addon,'WAREHOUSE_CLOSE','BARRACKITEMLISTEBIMOD_SAVE_WAREHOUSE')
    -- acutil.setupEvent(addon, 'SELECT_CHARBTN_LBTNUP', 'SELECT_CHARBTN_LBTNUP_EVENT')

    -- addon:RegisterMsg('GAME_START_3SEC','BARRACKITEMLISTEBIMOD_CREATE_VAR_ICONS')
    acutil.addSysIcon("barrackitemlistebimod", "sysmenu_inv", "Barrack Item List", "OPEN_BARRACKITEMLISTEBIMOD")    
    local droplist = tolua.cast(frame:GetChild("droplist"), "ui::CDropList");
    droplist:ClearItems()
    droplist:AddItem(1,'None')
    for k,v in pairs(g.userlist) do
        droplist:AddItem(k,"{s20}"..v.."{/}",0,'BARRACKITEMLISTEBIMOD_SHOW_LIST()');
    end
    tolua.cast(frame:GetChild('tab'), "ui::CTabControl"):SelectTab(0)
    frame:GetChild('saveBtn'):SetTextTooltip('現在のキャラのインベントリを保存する')
    BARRACKITEMLISTEBIMOD_CREATE_SETTINGMENU()
    BARRACKITEMLISTEBIMOD_TAB_CHANGE(frame)
    frame:ShowWindow(0)
    BARRACKITEMLISTEBIMOD_SAVE_LIST()
end

-- function SELECT_CHARBTN_LBTNUP_EVENT(addonFrame, eventMsg)
--     local parent, ctrl, cid, argNum = acutil.getEventArgs(eventMsg);
--     BARRACKITEMLISTEBIMOD_SHOW_LIST(cid)
-- end

function BARRACKITEMLISTEBIMOD_TAB_CHANGE(frame, obj, argStr, argNum)
    local treeGbox = frame:GetChild('treeGbox')
    local droplist = frame:GetChild("droplist")
    local searchGbox = frame:GetChild('searchGbox')
    local settingGbox = frame:GetChild('settingGbox')
    local tabObj = tolua.cast(frame:GetChild('tab'), "ui::CTabControl");
	local tabIndex = tabObj:GetSelectItemIndex();

	if (tabIndex == 0) then
		treeGbox:ShowWindow(1)
        droplist:ShowWindow(1)
		searchGbox:ShowWindow(0)
        settingGbox:ShowWindow(0)
        BARRACKITEMLISTEBIMOD_SHOW_LIST()
        BARRACKITEMLISTEBIMOD_SAVE_SETTINGMENU()
	elseif (tabIndex == 1) then
		treeGbox:ShowWindow(0)
        droplist:ShowWindow(0)
		searchGbox:ShowWindow(1)
        settingGbox:ShowWindow(0)
        BARRACKITEMLISTEBIMOD_SAVE_SETTINGMENU()
        BARRACKITEMLISTEBIMOD_SHOW_SEARCH_ITEMS()
    else
        treeGbox:ShowWindow(0)
        droplist:ShowWindow(0)
		searchGbox:ShowWindow(0)
        settingGbox:ShowWindow(1)
	end
end

function BARRACKITEMLISTEBIMOD_COMMAND(command)
    BARRACKITEMLISTEBIMOD_CREATE_SETTINGMENU()
    ui.ToggleFrame('barrackitemlistebimod')
end 

function BARRACKITEMLISTEBIMOD_SAVE_LIST()
    local list = {}
    session.BuildInvItemSortedList()
	local invItemList = session.GetInvItemSortedList();

    for i = 1, invItemList:size() - 1 do
        local invItem = invItemList:at(i);
        if invItem ~= nil then
    		local obj = GetIES(invItem:GetObject());
            list[obj.GroupName] = list[obj.GroupName] or {}
            table.insert(list[obj.GroupName],GetItemData(obj,invItem))
        end
	end
    local cid = info.GetCID(session.GetMyHandle())
    EBI_SAVE(g.settingPath..cid..'.bin',list)
    g.itemlist[cid] = list  
end

function BARRACKITEMLISTEBIMOD_SHOW_LIST(cid)
    local frame = ui.GetFrame('barrackitemlistebimod')
    frame:ShowWindow(1)
    local gbox = GET_CHILD(frame,'treeGbox','ui::CGroupBox');
    local droplist = GET_CHILD(frame,'droplist', "ui::CDropList")
    if not cid then cid= droplist:GetSelItemKey() end
    for k,v in pairs(g.userlist) do
        local child = gbox:GetChild("tree"..k) 
        if child then
            child:ShowWindow(0)
        end
    end
    local list = g.itemlist[cid]
    if not list then
        list ,e = EBI_LOAD(g.settingPath..cid..'.bin')
        if(e==nil) then 
          CHAT_SYSTEM("BBBB")
          return
         end
    end
    CHAT_SYSTEM("AAAA")
    g.warehouseList[tostring(cid)] = g.warehouseList[tostring(cid)] or {}
    list.warehouse =  g.warehouseList[tostring(cid)].warehouse or {};
    local tree = gbox:CreateOrGetControl('tree','tree'..cid,25,50,545,0)
    -- if tree:GetUserValue('exist_data') ~= '1' then
        -- tree:SetUserValue('exist_data',1) 
        tolua.cast(tree,'ui::CTreeControl')
        tree:ResizeByResolutionRecursively(1)
        tree:Clear()
        tree:EnableDrawFrame(true);
        tree:SetFitToChild(true,60); 
        tree:SetFontName("white_20_ol");
        local nodeName,parentCategory
        local slot,slotset,icon
        local nodeList = g.nodeList
        for i,value in ipairs(nodeList) do
            local nodeItemList = list[value[1]]
            if nodeItemList and not g.setting.hideNode[i] then
                if value[1] == "Unused" then
                    tree:Add("シルバー : " .. acutil.addThousandsSeparator(nodeItemList[1][2]));
                else
                    tree:Add(value[2]);
                    parentCategory = tree:FindByCaption(value[2]);
                    slotset = BARRACKITEMLISTEBIMOD_MAKE_SLOTSET(tree,value[1])
                    tree:Add(parentCategory,slotset, 'slotset_'..value[1]);
                    for i ,v in ipairs(nodeItemList) do
                        slot = slotset:GetSlotByIndex(i - 1)


                        slot:SetText(string.format(v[2]))
                        slot:SetTextMaxWidth(1000)
                        icon = CreateIcon(slot)
                        icon:SetImage(v[3])
                        icon:SetTextTooltip(string.format("%s : %s",BARRACKITEMLISTEBIMOD_GETNAMEBYCLASSID(v[1]),v[2]))
                        if (i % g.setting.col) == 0 then
                            slotset:ExpandRow()
                        end
                    end
                end
            end
        -- end
    end
    if g.setting.OpenNodeAll then
        tree:OpenNodeAll()
    end
    tree:ShowWindow(1)
    frame:ShowWindow(1)
end
function BARRACKITEMLISTEBIMOD_MAKE_SLOTSET(tree, name)
    local col = g.setting.col
    local slotsize = math.floor(tree:GetWidth() / (col + 1))
    local slotsetTitle = 'slotset_titile_'..name
	local newslotset = tree:CreateOrGetControl('slotset','slotset_'..name,0,0,0,0) 
	tolua.cast(newslotset, "ui::CSlotSet");
	
	newslotset:EnablePop(0)
	newslotset:EnableDrag(0)
	newslotset:EnableDrop(0)
	newslotset:SetMaxSelectionCount(999)
	newslotset:SetSlotSize(slotsize,slotsize);
	newslotset:SetColRow(col,1)
	newslotset:SetSpc(0,0)
	newslotset:SetSkinName('invenslot2')
	newslotset:EnableSelection(0)
    newslotset:ResizeByResolutionRecursively(1)
	newslotset:CreateSlots()
	return newslotset;
end

function BARRACKITEMLISTEBIMOD_SEARCH_ITEMS(itemlist,itemName,iswarehouse)
    local items = {}
    for cid,name in pairs(g.userlist) do
        if itemlist[cid] then
            for group,list in pairs(itemlist[cid]) do
                if group ~= 'warehouse' or iswarehouse then
                    for i ,v in ipairs(list) do

                        local name=BARRACKITEMLISTEBIMOD_GETNAMEBYCLASSID(v[1])
                        if string.find(name,itemName) then
                            items[cid] = items[cid] or {}
                            table.insert(items[cid],v)
                        end
                    end
                end
            end
        end
    end
    return items
end
function BARRACKITEMLISTEBIMOD_GETNAMEBYCLASSID(clsid)
  local itemCls=GetClassByType("Item",clsid)
  return dictionary.ReplaceDicIDInCompStr(itemCls.Name)
end
function BARRACKITEMLISTEBIMOD_SHOW_SEARCH_ITEMS(frame, obj, argStr, argNum)
    local frame = ui.GetFrame('barrackitemlistebimod')
    local searchGbox = frame:GetChild('searchGbox')
    local editbox = tolua.cast(searchGbox:GetChild('searchEdit'), "ui::CEditControl");
    local tree = searchGbox:CreateOrGetControl('tree','saerchTree',25,50,545,0)
    tolua.cast(tree,'ui::CTreeControl')
    tree:ResizeByResolutionRecursively(1)
    tree:Clear()
    tree:EnableDrawFrame(true);
    tree:SetFitToChild(true,60); 
    tree:SetFontName("white_20_ol");
    if editbox:GetText() == '' or not editbox:GetText() then return end
    local invItems = BARRACKITEMLISTEBIMOD_SEARCH_ITEMS(g.itemlist,editbox:GetText(),false)
    local warehouseItems = BARRACKITEMLISTEBIMOD_SEARCH_ITEMS(g.warehouseList,editbox:GetText(),true)
    tree:Add('インベントリ')
    _BARRACKITEMLISTEBIMOD_SEARCH_ITEMS(tree,invItems,'_i')
    tree:Add('倉庫')
    _BARRACKITEMLISTEBIMOD_SEARCH_ITEMS(tree,warehouseItems,'_w')
    tree:OpenNodeAll()
    tree:ShowWindow(1)
end

function _BARRACKITEMLISTEBIMOD_SEARCH_ITEMS(tree,items,type)
    local nodeName,parentCategory
    local slot,slotset,icon
    for k,value in pairs(items) do
        tree:Add(g.userlist[k]..type);
        parentCategory = tree:FindByCaption(g.userlist[k]..type);
        slotset = BARRACKITEMLISTEBIMOD_MAKE_SLOTSET(tree,k..type)
        tree:Add(parentCategory,slotset, 'slotset_'..k..type);
        for i ,v in ipairs(value) do
            slot = slotset:GetSlotByIndex(i - 1)
            slot:SetText(string.format('{s20}%s',v[2]))
            slot:SetTextAlign(30,30)
            -- slot:SetTextMaxWidth(1000)
            icon = CreateIcon(slot)
            icon:SetImage(v[3])
            icon:SetTextTooltip(string.format("%s : %s",v[1],v[2]))
            if (i % g.setting.col) == 0 then
                slotset:ExpandRow()
            end
        end
    end

end

function BARRACKITEMLISTEBIMOD_SAVE_WAREHOUSE()
    local frame = ui.GetFrame('warehouse')
    local slotset = frame:GetChild("gbox"):GetChild('slotset')
    tolua.cast(slotset,'ui::CSlotSet')
    local items = {}
    local slot , item
    
	for i = 0 , slotset:GetSlotCount() -1 do
         slot = slotset:GetSlotByIndex(i)
         item = GetItemData(GetObjBySlot(slot))
         if item then
             table.insert(items,item)
         end
    end
    local cid = tostring(info.GetCID(session.GetMyHandle()))
    g.warehouseList[cid] = {}
    g.warehouseList[cid].warehouse = items
    EBI_SAVE(g.settingPath..'warehouse.bin',g.warehouseList)
end

 function GetItemData(obj,item)
    if not obj then return end
    local itemName = dictionary.ReplaceDicIDInCompStr(obj.Name)
    local itemCount = item.count
    local iconImg = obj.Icon
    if obj.GroupName ==  'Gem' or obj.GroupName ==  'Card' then
        itemCount = 'Lv' .. GET_ITEM_LEVEL(obj)
    end
    if obj.ItemType == 'Equip' and obj.ClassType == 'Outer' then
        local tempiconname = string.sub(obj.Icon, string.len(obj.Icon) - 1 );
        if tempiconname ~= "_m" and tempiconname ~= "_f" then
            if gender == nil then
                gender = GetMyPCObject().Gender;
            end
            if gender == 1 then
                iconImg =iconImg.."_m"
            else
                iconImg = iconImg.."_f"
            end
        end
    end
    return {obj.ClassID,itemCount,iconImg}
end

 function GetObjBySlot(slot)
    local icon = slot:GetIcon()
    if not icon then return end
    local info = icon:GetInfo()
    local IESID = info:GetIESID()
    return GetObjectByGuid(IESID) ,info ,IESID
end

function BARRACKITEMLISTEBIMOD_CREATE_SETTINGMENU()
    local frame = ui.GetFrame('barrackitemlistebimod')
    local settingGbox = frame:GetChild('settingGbox')
    local hideNodeGbox = settingGbox:GetChild('hideNodeGbox')

    -- create slotsize droplist
    local droplist = tolua.cast(settingGbox:GetChild("slotColDList"), "ui::CDropList");
    droplist:ClearItems()
    for i = 7, 14  do
        droplist:AddItem(i,"{s20}"..i.."{/}");
    end
    droplist:SelectItemByKey(g.setting.col)
    
    --create hide node list
    local checkbox
    for i = 1 ,#g.nodeList do
        checkbox = hideNodeGbox:CreateOrGetControl('checkbox','checkbox'..i,30,i*30,200,30)
        tolua.cast(checkbox,'ui::CCheckBox')
        checkbox:SetText('{s30}{#000000}'..g.nodeList[i][2])
        if not g.setting.hideNode[i] then 
            checkbox:SetCheck(1)
        end
    end
    checkbox = tolua.cast(settingGbox:GetChild('openNodeChbox'),'ui::CCheckBox')
    if g.setting.OpenNodeAllthen then
        checkbox:SetCheck(1)
    end
end

function BARRACKITEMLISTEBIMOD_SAVE_SETTINGMENU() 
    local frame = ui.GetFrame('barrackitemlistebimod')
    local settingGbox = frame:GetChild('settingGbox')
    local hideNodeGbox = settingGbox:GetChild('hideNodeGbox')
    -- save slotsize droplist
    local droplist = tolua.cast(settingGbox:GetChild("slotColDList"), "ui::CDropList");
    g.setting.col = droplist:GetSelItemKey()
    --save hide node list
    local checkbox
    for i = 1 ,#g.nodeList do
        checkbox = tolua.cast(hideNodeGbox:GetChild('checkbox'..i),'ui::CCheckBox')
        if checkbox:IsChecked() ~= 1 then 
            g.setting.hideNode[i] = true
        else
            g.setting.hideNode[i] = false
        end
    end
    
    checkbox = tolua.cast(settingGbox:GetChild('openNodeChbox'),'ui::CCheckBox')
    if checkbox:IsChecked() == 1 then 
        g.setting.OpenNodeAll = true
    else
        g.setting.OpenNodeAll = false
    end
    acutil.saveJSON(g.settingPath..'setting.json',g.setting)
end

function BARRACKITEMLISTEBIMOD_CREATE_VAR_ICONS()
    local frame = ui.GetFrame("sysmenu");
	if false == VARICON_VISIBLE_STATE_CHANTED(frame, "necronomicon", "necronomicon")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "grimoire", "grimoire")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "guild", "guild")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "poisonpot", "poisonpot")
	then
		return;
	end

	DESTROY_CHILD_BY_USERVALUE(frame, "IS_VAR_ICON", "YES");

    local extraBag = frame:GetChild('extraBag');
	local status = frame:GetChild("status");
	local offsetX = status:GetX() - extraBag:GetX();
	local rightMargin = extraBag:GetMargin().right + offsetX;

	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "guild", "guild", "sysmenu_guild", rightMargin, offsetX, "Guild");
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "necronomicon", "necronomicon", "sysmenu_card", rightMargin, offsetX);
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "grimoire", "grimoire", "sysmenu_neacro", rightMargin, offsetX);
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "poisonpot", "poisonpot", "sysmenu_wugushi", rightMargin, offsetX);	
    if _G["EXPCARDCALCULATOR"] then
    	rightMargin = SYSMENU_CREATE_VARICON(frame, status, "expcardcalculator", "expcardcalculator", "addonmenu_expcard", rightMargin, offsetX, "Experience Card Calculator") or rightMargin
	end
    rightMargin = SYSMENU_CREATE_VARICON(frame, status, "barrackitemlistebimod", "barrackitemlistebimod", "sysmenu_inv", rightMargin, offsetX, "barrack item list");
    local expcardcalculatorButton = GET_CHILD(frame, "expcardcalculator", "ui::CButton");
	if expcardcalculatorButton ~= nil then
		expcardcalculatorButton:SetTextTooltip("{@st59}expcardcalculator");
	end

	local BARRACKITEMLISTEBIMODButton = GET_CHILD(frame, "barrackitemlistebimod", "ui::CButton");
	if BARRACKITEMLISTEBIMODButton ~= nil then
		BARRACKITEMLISTEBIMODButton:SetTextTooltip("{@st59}barrackitemlistebimod");
	end
end