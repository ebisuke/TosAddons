
-- This library based on mahjong created by MahjongRepository members.
-- Translated to lua by ebisuke.

-- https://github.com/MahjongRepository/mahjong

-- MIT License

-- Copyright (c) [2017] [Alexey Lisikhin]

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.



--
-- itertools.lua
-- Copyright (C) 2016 Adrian Perez <aperez@igalia.com>
--
-- Distributed under terms of the MIT license.
--

--- Functional iteration utilities using coroutines.
--
-- Iterators
-- ---------
--
-- An **iterator** is a coroutine which yields values of a sequence. Unless
-- specified otherwise, iterators use a constant amount of memory, and
-- yielding the a value takes a constant *O(1)* amount of time.
--
-- Typically iterator implementations use the following pattern:
--
--     function iter (...)
--       -- Do one-time initialization tasks.
--       local finished_iterating = false
--       -- Return a coroutine.
--       return coroutine.wrap(function ()
--         while not finished_iterating do
--           local value = calculate_next_value()
--           coroutine.yield(value)
--         end
--       end)
--     end
--
-- Consuming an iterator is most conveniently done using a `for`-loop:
--
--     for element in iterable do
--       -- Do something with the element.
--     end
--
--
-- Credits
-- -------
--
-- This module is loosely based on [Python's itertools
-- module](https://docs.python.org/3/library/itertools.html), plus some
-- other of Python's built-ins like [map()](https://docs.python.org/3/library/functions.html?highlight=map#map)
-- and [filter()](https://docs.python.org/3/library/functions.html?highlight=filter#filter).
--
-- @module itertools
--

local pairs, ipairs, select = pairs, ipairs, select
local t_sort, t_unpack = table.sort, table.unpack
local co_yield, co_wrap = coroutine.yield, coroutine.wrap
local co_resume = coroutine.resume

local itertools = {}

--- Iterate over the keys of a table.
--
-- Given a `table`, returns an iterator over its keys, as returned by
-- `pairs`.
--
-- @param table A dictionary-like table.
-- @treturn coroutine An iterator over the table keys.
--
function itertools.keys(table)
    return co_wrap(
        function()
            for k, _ in pairs(table) do
                co_yield(k)
            end
        end
    )
end

--- Iterate over the values of a table.
--
-- Given a `table`, returns an iterator over its values, as returned by
-- `pairs`.
--
-- @param table A dictionary-like table.
-- @treturn coroutine An iterator over the table values.
--
function itertools.values(table)
    return co_wrap(
        function()
            for _, v in pairs(table) do
                co_yield(v)
            end
        end
    )
end

--- Iterate over the key and value pairs of a table.
--
-- Given a `table`, returns an iterator over its keys and values, as returned
-- by `pairs`. Each yielded element is a two-element *{ key, value }*
-- array-like table.
--
-- Note that yielded array-like tables are not guaranteed be be unique, and if
-- you need to save a copy of it you must create a new table yourself:
--
--    local tpairs = {}
--    for pair in iterable do
--      table.insert(tpairs, { pair[1], pair[2] })
--    end
--
-- @param table A dictionary-like table.
-- @treturn coroutine An iterator over *{ key, value }* pairs.
--
function itertools.items(table)
    return co_wrap(
        function()
            -- Reuse the same table to avoid table creation (and GC) in the loop.
            local pair = {}
            for k, v in pairs(table) do
                pair[1], pair[2] = k, v
                co_yield(pair)
            end
        end
    )
end

--- Iterate over each value of an array-like table.
--
-- Given an array-like `table`, returns an iterator over its values, as
-- returned by `ipairs`.
--
-- @param table An array-like table.
-- @treturn coroutine An iterator over the table values.
--
function itertools.each(table)
    return co_wrap(
        function()
            for _, v in ipairs(table) do
                co_yield(v)
            end
        end
    )
end

--- Consume an iterable and collect its elements into an array-like table.
--
-- Note that this function runs in *O(n)* time and memory usage because it
-- needs to store all the elements yielded by the iterable.
--
-- @tparam coroutine iterable A non-infinite iterator.
-- @treturn table Array-like table with the collected elements.
-- @treturn integer Number of elements collected.
--
function itertools.collect(iterable)
    local t, n = {}, 0
    if type(iterable)=="table" then
        for _,element in ipairs(iterable) do
            n = n + 1
            t[n] = element
        end
    else
        for element in iterable do
            n = n + 1
            t[n] = element
        end
    end
   
    return t, n
end

--- Iterate over an infinite sequence of consecutive numbers.
--
-- Returns an iterable which produces an infinite sequence of numbers starting
-- at `n`, adding `step` to it in each iteration. Let `i` be the current
-- iteration, starting with `i = 0`, the sequence generated would be:
--
--    n + step * 0, n + step * 1, n + step * 2, ..., n + step * i
--
-- @tparam[opt] number n First value in the sequence.
-- @tparam[opt] number step Increment added in each iteration.
-- @treturn coroutine An iterator over the sequence of numbers.
--
function itertools.count(n, step)
    if n == nil then
        n = 1
    end
    if step == nil then
        step = 1
    end
    return co_wrap(
        function()
            while true do
                co_yield(n)
                n = n + step
            end
        end
    )
end

--- Iterate over a sequence of elements repeatedly.
--
-- Returns an iterable which produces an infinite sequence of elements: first,
-- the elements from `iterable`, then the sequence is repeated indefinitely.
--
-- Note that this may store in memory up to as much elements as provided by
-- `iterable`.
--
-- @tparam coroutine iterable An iterator.
-- @treturn coroutine An infinite iterator repeating elements from `iterable`.
--
function itertools.cycle(iterable)
    local saved = {}
    local nitems = 0
    return co_wrap(
        function()
            for element in iterable do
                co_yield(element)
                nitems = nitems + 1
                saved[nitems] = element
            end
            while nitems > 0 do
                for i = 1, nitems do
                    co_yield(saved[i])
                end
            end
        end
    )
end

--- Iterate over the same value repeatedly.
--
-- Returns an iterator which always produces the same `value`, indefinitely or
-- up to a given number of `times`.
--
-- @param value The value to produce.
-- @tparam[opt] integer times Number of repetitions.
-- @treturn coroutine An iterator which always produces `value`.
--
function itertools.value(value, times)
    if times then
        return co_wrap(
            function()
                while times > 0 do
                    times = times - 1
                    co_yield(value)
                end
            end
        )
    else
        return co_wrap(
            function()
                while true do
                    co_yield(value)
                end
            end
        )
    end
end

--- Iterate over selected values of an iterable.
--
-- If `start` is specified, the returned iterator will skip all preceding
-- elements; otherwise `start` defaults to `1`. The elements with indexes
-- between `start` and `stop` (inclusive) will be yielded. If `stop` is
-- not specified, the default is to yield all elements from `iterable`
-- until it is exhausted.
--
-- For example, using only `stop` can be used to limit the amount of elements
-- yielded by an indefinite iterator. A `range()` iterator similar to Python's
-- could be implemented as follows:
--
--    function range (n)
--       return itertools.islice(itertools.count(), nil, n)
--    end
--
-- @tparam coroutine iterable An iterator.
-- @tparam[opt] integer start Index of the first element, by default `1`.
-- @tparam[opt] integer stop Index of the last element, by default undefined.
-- @treturn coroutine An iterator which selects values.
--
function itertools.islice(iterable, start, stop)
    if start == nil then
        start = 1
    end
    return co_wrap(
        function()
            if stop ~= nil and stop - start < 1 then
                return
            end

            local current = 0
            for element in iterable do
                current = current + 1
                if stop ~= nil and current > stop then
                    return
                end
                if current >= start then
                    co_yield(element)
                end
            end
        end
    )
end

--- Iterate over values while a predicate is true.
--
-- The returned iterator returns successive elements from an `iterable` as
-- long as the `predicate` evaluates to `true` for each element.
--
-- @tparam function predicate Function which checks the predicate.
-- @tparam coroutine iterable An iterator.
-- @treturn coroutine An iterator which yield values while the predicate is true.
--
function itertools.takewhile(predicate, iterable)
    return co_wrap(
        function()
            for element in iterable do
                if predicate(element) then
                    co_yield(element)
                else
                    break
                end
            end
        end
    )
end

--- Iterate over elements applying a function to them
--
-- @tparam function func function Function applied to each element.
-- @tparam coroutine iterable An iterator.
-- @treturn coroutine An iterator which yields the results of applying the
--   function to the elements of `iterable`.
--
function itertools.map(func, iterable)
    return co_wrap(
        function()
            for element in iterable do
                co_yield(func(element))
            end
        end
    )
end

--- Iterate elements, filtering them according to a predicate.
--
-- Returns an iterator over the elements another `iterable` which yields only
-- the elements for which the `predicate` function return `true`.
--
-- For example, the following returns an indefinite iterator over the even
-- natural numbers:
--
--    function even_naturals ()
--       return itertools.filter(function (x) return x % 2 == 1 end,
--                               itertools.count())
--    end
--
-- @tparam function predicate
-- @tparam coroutine iterable An iterator.
-- @treturn coroutine An iterator over the elements which satisfy the predicate.
--
function itertools.filter(predicate, iterable)
    return co_wrap(
        function()
            for element in iterable do
                if predicate(element) then
                    co_yield(element)
                end
            end
        end
    )
end

local function make_comp_func(key)
    if key == nil then
        return nil
    end
    return function(a, b)
        return key(a) < key(b)
    end
end

local _collect = itertools.collect
local function expanditerator(iter)
    local tbl={}
    local i=1
   
    for k,v in iter do
        tbl[i]=v
        i=i+1
    end
    return tbl
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

local function sorted(list, cond)
    local copy = deepcopy(list)
    


    table.sort(copy, cond or 
    function(a,b)
        if type(a)=="table" then
            for k,v in ipairs(a) do
                if v ~= b[k] then
                    return v < b[k]
                end
            end
            --same
            return true
        else
            return a < b
        end
    end)
    return copy
end
function itertools.sorted(iterable, key, reverse)
    local tbl=sorted(iterable,key)
    if reverse then
        local tbl2={}
        for i=1,#tbl do
            tbl2[#tbl-i+1]=tbl[i]
        end
        return tbl2
    end
    return tbl
end



local _value = itertools.value
local function arraygenerator(count, init)
    local list = {}
    for x = 1, count  do
        list[x] = init
    end
    return list
end


local function arrayequal(a,b)
    if type(a)~="table"then
        return a==b
    end
    if #a ~= #b then
        return false
    end
    for k,v in pairs(a) do
        if type(a[k])=="table" and type(b[k])=='table' then
            return arrayequal(a[k],b[k])
        elseif a[k]~=b[k] then
            return false
        end
    end
    return true
end
local function isin(table, elems)
    if type(elems) == 'table' then
        for _, v in ipairs(table) do
            for _, k in ipairs(elems) do
                
                
                if arrayequal(v,k) then
                    return true
                end
                
            end
        end
    else
        for _, v in ipairs(table) do
            if arrayequal(v,elems) then
                return true
            end
        end
    end
    return false
end
local function uniq(a)
    local list={}
    local f=true
    for k,v in ipairs(a) do
        if f then
            list[k]=v
            f=false
        else
            local ok=true
            for kk,vv in ipairs(list) do
                if arrayequal(v,vv) then
                    ok=false
                    break
                end
            end
            if ok then
                list[k]=v
            end
        end
    end
    return list
end
local function tableremove(tbl, tgt, rep)
    for k, v in ipairs(tbl) do

        if type(v)=="table" then
            if arrayequal(v,tgt) then
                table.remove(tbl,k)
                if not rep then
                    break
                end
            end
        else

            if (v == tgt) then
                table.remove(tbl,k)
                if not rep then
                    break
                end
            end
        end
    end
    return tbl
end
local function any(list)
    for _, v in ipairs(list) do
        if v then
            return true
        end
    end
    return false
end
local function indexof(list, data)
    for k, v in ipairs(list) do
        if v == data then
            return k
        end
    end
    return nil
end
local function set(list)
    local s = {}
    for k, v in ipairs(list) do
        s[v] = v
    end
    return s
end
local function compset(a, b)
    for k, v in pairs(a) do
        if (not b[k]) then
            return false
        end
    end
    for k, v in pairs(b) do
        if (not b[a]) then
            return false
        end
    end
    return true
end
local function countof(list, data)
    local count = 0
    for k, v in ipairs(list) do
        if v == data then
            count = count + 1
        end
    end
    return count
end
local permgen
local coroutine = coroutine
local resume = coroutine.resume
permgen = function (a, n, fn)
  if n == 0 then
    fn(a)
  else
    for i=1,n do
      -- put i-th element as the last one
      a[n], a[i] = a[i], a[n]

      -- generate all permutations of the other elements
      permgen(a, n - 1, fn)

      -- restore i-th element
      a[n], a[i] = a[i], a[n]

    end
  end
end

--- an iterator over all permutations of the elements of a list.
-- Please note that the same list is returned each time, so do not keep references!
-- @param a list-like table
-- @return an iterator which provides the next permutation as a list
local function permuteiter (a,n)
    --local n = #a
    local co = coroutine.create(function () permgen(a, n, coroutine.yield) end)
    return function ()   -- iterator
        local code, res = resume(co)
        return res
    end
end
local function noop(...)
    return ...
end

-- convert a nested table to a flat table
local function flatten(t,  res)
    if type(t) ~= 'table' then
        return t
    end

  

    if res == nil then
        res = {}
    end

    for k, v in pairs(t) do
        if type(v) == 'table' then
            local v = flatten(v, {})
            for k2, v2 in pairs(v) do
                res[#res+1] = v2
            end
        else
            res[#res+1] = v
        end
    end
    return res
end

local function permutations(N)
	local level, set, co = -1, {}, nil

	for i = 1, N do set[i] = 0 end

	co = coroutine.create(function () permute(set, level, N, 1) end)

	return function ()
		local _, p = coroutine.resume(co)
		return p
	end
end 

local function permute(set, level, N, k)
	level = level + 1
	set[k] = level
	if level == N then
		coroutine.yield(set)
	else
		for i = 1, N do
			if set[i] == 0 then
				permute(set, level, N, i)
			end
		end
	end

	level = level - 1
	set[k] = 0
end
local function range(a,b,c)
    local l={}
    if b==nil then
        b=a
        a=0
    end
    c=c or 1

    while a~=b do
        l[#l+1]=a
        a=a+c
    end
    return l
end

local function picker(list, cond, add, pick)
    local l = {}
    for _, v in ipairs(list) do
        local pass = true
        if cond then
            pass = cond(v)
        end
        if pick then
            l[#l + 1] = pick(v)
        else
            if pass then
                local val = v
                if add then
                    val = v + (add or 0)
                end
                l[#l + 1] = val
            end
        end
    end
    return l
end

local function slice(l,s,e)
   local list={}
   s=s or 1
   e=e or (#l+1)
   for i=s,e-1 do
    list[#list+1]=l[i]
   end
   return list
end
local function reverse(t)
    local r=deepcopy(t)
  local n = #r
  local i = 1
  while i < n do
    r[i],r[n] = r[n],r[i]
    i = i + 1
    n = n - 1
  end
  return r
end
  
local function pand(a, b)
    if a then
        return b
    else
        return a
    end
end

local g = {}

-- python specific functions

local copy = {}


local function cartesian_product(sets)
    local item_counts = {}
    local indices = {}
    local results = {}
    local set_count = #sets
    local combination_count = 1

    for set_index = set_count, 1, -1 do
        local set = sets[set_index]
        local item_count = #set
        item_counts[set_index] = item_count
        indices[set_index] = 1
        results[set_index] = set[1]
        combination_count = combination_count * item_count
    end

    local combination_index = 0

    return function()
        if combination_index >= combination_count then
            return
        end -- no more output

        if combination_index == 0 then
            goto skip_update
        end -- skip first index update

        indices[set_count] = indices[set_count] + 1

        for set_index = set_count, 1, -1 do -- update index list
            local set = sets[set_index]
            local index = indices[set_index]
            if index <= item_counts[set_index] then
                results[set_index] = set[index]
                break -- no further update needed
            else -- propagate item_counts overflow
                results[set_index] = set[1]
                indices[set_index] = 1
                if set_index > 1 then
                    indices[set_index - 1] = indices[set_index - 1] + 1
                end
            end
        end

        ::skip_update::

        combination_index = combination_index + 1

        return combination_index, results
    end
end

local function sum(list)
    local s = 0
    for _, v in ipairs(list) do
        s = s + v
    end
    return s
end
local function all(list, cond)
    cond=cond or function(v)
        return v
    end
    for _, v in ipairs(list) do
       
        if (not cond(v)) then
            return false
        end
    end
    return true
end

local function find(list, dest)
    --local list = {}
    for k, v in ipairs(list) do
        if (v == dest) then
            return true
        end
    end
    return false
end
local function cat(tbla,tblb)
    
    local cpy=deepcopy(tbla)
    for k,v in pairs(tblb) do
        table.insert(cpy,v)
    end
    return cpy
end
-- Cartesian product of iterables.
--
-- This is equivalent to nested for-loops, with the leftmost iterators
-- being the outermost for-loops, so the yielded results cycle in a
-- manner similar to an odometer, with the rightmost element changing
-- on every iteration.
--
-- @tparam coroutine iterable An iterator.
-- @tparam[opt] coroutine ... Additional iterators.
-- @treturn coroutine An iterator over tuples of product elements.
--
function itertools.product(args,rep)
    -- product('ABCD', 'xy') --> Ax Ay Bx By Cx Cy Dx Dy
    -- product(range(2), repeat=3) --> 000 001 010 011 100 101 110 111
    rep=rep or 1
    local pools = arraygenerator(rep,args)
    local result = {{}}
    for _,pool in ipairs(pools) do
        
        for k,x in ipairs(result)do
            local rs=x
            for _,y in ipairs(pool)do
                rs=cat(rs,{y})
            end
            result[k]=rs
        end
    end
        
    local ret={}
    for _,prod in ipairs(result) do
        table.insert(ret,prod)
    end

    return ret
end
local function combine(tbla,tblb)
    
    local cpy=deepcopy(tbla)
    for k,v in pairs(tblb) do
        cpy[k]=v
    end
    return cpy
end

local function ipermutations(iterable,r)

    -- permutations('ABCD', 2) --> AB AC AD BA BC BD CA CB CD DA DB DC
    -- permutations(range(3)) --> 012 021 102 120 201 210
    local pool = deepcopy(iterable)
    local n = #(pool)
    r = r or n 

    if r > n then
        return {pool}
    end
    local indices = range(n)
    local cycles = range(n, n-r, -1)

    local list={}
    table.insert(list,picker(slice(indices,1,r+1),nil,nil,function(x)return pool[x+1]end))

    --yield tuple(pool[i] for i in indices[:r])
    while n do
        local broken=false
        local p=reverse(range(r))
        for _,i in ipairs(p) do
            cycles[i+1] =  cycles[i+1]-1
            if cycles[i+1] == 0 then
                local sl=slice(indices,i+1+1)
                local sll=slice(indices,i+1,i+1+1)
                local ca=cat(sl,sll)
                for j=i+1,#indices do
                    indices[j]=ca[j-i]
                end
                -- indices[i:] = indices[i+1:] + indices[i:i+1]
                cycles[i+1] = n - i
            else
                local j = cycles[i+1]
                indices[i+1], indices[#indices-j+1] = indices[#indices-j+1], indices[i+1]
                table.insert(list,picker(slice(indices,1,r+1),nil,nil,function(x)return pool[x+1]end))

                broken=true
                break
            end
        end
        if not broken then
            break
        end

    end
    return list
end
--agari
g.Agari = {
    is_agari = function( tiles_34, open_sets_34)
        local tiles = deepcopy(tiles_34)

        if open_sets_34 then
            local isolated_tiles =  g.utils.find_isolated_tile_indices(tiles)
            for _,meld in ipairs(open_sets_34) do
                if not isolated_tiles then
                    break
                end
                local isolated_tile = table.remove(isolated_tiles)

                tiles[meld[0 + 1]] = tiles[meld[0 + 1]] - 1
                tiles[meld[1 + 1]] = tiles[meld[1 + 1]] - 1
                tiles[meld[2 + 1]] = tiles[meld[2 + 1]] - 1
                tiles[isolated_tile+1] = 3
            end
        end
        local j = (1 << tiles[27 + 1]) | (1 << tiles[28 + 1]) | (1 << tiles[29 + 1]) | (1 << tiles[30 + 1]) | (1 << tiles[31 + 1]) | (1 << tiles[32 + 1]) | (1 << tiles[33 + 1])

        if j >= 0x10 then
          
            return false
        end

        if
            ((j & 3) == 2) and
                (tiles[0 + 1] * tiles[8 + 1] * tiles[9 + 1] * tiles[17 + 1] * tiles[18 + 1] * tiles[26 + 1] * tiles[27 + 1] * tiles[28 + 1] * tiles[29 + 1] * tiles[30 + 1] *
                    tiles[31 + 1] *
                    tiles[32 + 1] *
                    tiles[33 + 1] ==
                    2)
         then
            return true
        end
        local sum = 0
        for i=1,34 do
            if (tiles[i] == 2) then
                sum = sum + 1
            end
        end
        if (j & 10)==0 and sum == 7 then
            return true
        end
        if (j & 2)~=0 then
          
            return false
        end
        local n00 = tiles[0 + 1] + tiles[3 + 1] + tiles[6 + 1]
        local n01 = tiles[1 + 1] + tiles[4 + 1] + tiles[7 + 1]
        local n02 = tiles[2 + 1] + tiles[5 + 1] + tiles[8 + 1]

        local n10 = tiles[9 + 1] + tiles[12 + 1] + tiles[15 + 1]
        local n11 = tiles[10 + 1] + tiles[13 + 1] + tiles[16 + 1]
        local n12 = tiles[11 + 1] + tiles[14 + 1] + tiles[17 + 1]

        local n20 = tiles[18 + 1] + tiles[21 + 1] + tiles[24 + 1]
        local n21 = tiles[19 + 1] + tiles[22 + 1] + tiles[25 + 1]
        local n22 = tiles[20 + 1] + tiles[23 + 1] + tiles[26 + 1]

        local n0 = (n00 + n01 + n02) % 3
        if n0 == 1 then
            return false
        end
        local n1 = (n10 + n11 + n12) % 3
        if n1 == 1 then
            return false
        end
        local n2 = (n20 + n21 + n22) % 3
        if n2 == 1 then
            return false
        end
        local function b(x)
            if x then
                return 1
            else
                return 0

            end
        end
        if
            ((b(n0 == 2) + b(n1 == 2) + b(n2 == 2) + b(tiles[27+1] == 2) + b(tiles[28+1] == 2) + b(tiles[29+1] == 2) + b(tiles[30+1] == 2) + b(tiles[31+1] == 2) + b(tiles[32+1] == 2) + b(tiles[33+1] == 2)) ~=
                1)
         then
            
            return false
        end
        local nn0 = (n00 * 1 + n01 * 2) % 3
        local m0 =  g.Agari._to_meld(tiles, 0)
        local nn1 = (n10 * 1 + n11 * 2) % 3
        local m1 =  g.Agari._to_meld(tiles, 9)
        local nn2 = (n20 * 1 + n21 * 2) % 3
        local m2 =  g.Agari._to_meld(tiles, 18)

        if (j & 4)~=0 then
            return (n0 | nn0 | n1 | nn1 | n2 | nn2)==0 and g.Agari._is_mentsu(m0) and g.Agari._is_mentsu(m1) and g.Agari._is_mentsu(m2)
        end
        if n0 == 2 then
            return (n1 | nn1 | n2 | nn2)==0  and g.Agari._is_mentsu(m1) and g.Agari._is_mentsu(m2) and g.Agari._is_atama_mentsu(nn0, m0)
        end
        if n1 == 2 then
            return (n2 | nn2 | n0 | nn0)==0  and g.Agari._is_mentsu(m2) and g.Agari._is_mentsu(m0) and g.Agari._is_atama_mentsu(nn1, m1)
        end
        if n2 == 2 then
            return (n0 | nn0 | n1 | nn1)==0  and g.Agari._is_mentsu(m0) and g.Agari._is_mentsu(m1) and g.Agari._is_atama_mentsu(nn2, m2)
        end
        return false
    end,
    _is_mentsu = function( m)
        local a = m & 7
        local b = 0
        local c = 0
        if a == 1 or a == 4 then
            b = 1
            c = 1
        elseif a == 2 then
            b = 2
            c = 2
        end
        m = m >> 3
        a = (m & 7) - b

        if a < 0 then
            return false
        end
        local is_not_mentsu = false
        for x = 0, 5 do
            b = c
            c = 0
            if a == 1 or a == 4 then
                b = b + 1
                c = c + 1
            elseif a == 2 then
                b = b + 2
                c = c + 2
            end
            m = m >> 3
            a = (m & 7) - b
            if a < 0 then
                is_not_mentsu = true
                break
            end
        end
        if is_not_mentsu then
            return false
        end
        m = m >> 3
        a = (m & 7) - c

        return a == 0 or a == 3
    end,
    _is_atama_mentsu = function( nn, m)
        if nn == 0 then
            if (m & (7 << 6)) >= (2 << 6) and  g.Agari._is_mentsu(m - (2 << 6)) then
                return true
            end
            if (m & (7 << 15)) >= (2 << 15) and  g.Agari._is_mentsu(m - (2 << 15)) then
                return true
            end
            if (m & (7 << 24)) >= (2 << 24) and  g.Agari._is_mentsu(m - (2 << 24)) then
                return true
            end
        elseif nn == 1 then
            if (m & (7 << 3)) >= (2 << 3) and  g.Agari._is_mentsu(m - (2 << 3)) then
                return true
            end
            if (m & (7 << 12)) >= (2 << 12) and  g.Agari._is_mentsu(m - (2 << 12)) then
                return true
            end
            if (m & (7 << 21)) >= (2 << 21) and  g.Agari._is_mentsu(m - (2 << 21)) then
                return true
            end
        elseif nn == 2 then
            if (m & (7 << 0)) >= (2 << 0) and  g.Agari._is_mentsu(m - (2 << 0)) then
                return true
            end
            if (m & (7 << 9)) >= (2 << 9) and  g.Agari._is_mentsu(m - (2 << 9)) then
                return true
            end
            if (m & (7 << 18)) >= (2 << 18) and  g.Agari._is_mentsu(m - (2 << 18)) then
                return true
            end
        end
        return false
    end,
    _to_meld = function(tiles, d)
        local result = 0
        for i = 0, 8 do
            result = result | (tiles[d + i+1] << i * 3)
        end
        return result
    end
}

-- constants

g.TERMINAL_INDICES = {0, 8, 9, 17, 18, 26}

g.EAST = 27
g.SOUTH = 28
g.WEST = 29
g.NORTH = 30
g.HAKU = 31
g.HATSU = 32
g.CHUN = 33

g.WINDS = {g.EAST, g.SOUTH, g.WEST, g.NORTH}

g.HONOR_INDICES = cat(g.WINDS , {g.HAKU, g.HATSU, g.CHUN})

g.FIVE_RED_MAN = 16
g.FIVE_RED_PIN = 52
g.FIVE_RED_SOU = 88

g.AKA_DORA_LIST = {g.FIVE_RED_MAN, g.FIVE_RED_PIN, g.FIVE_RED_SOU}

g.DISPLAY_WINDS = {
    [g.EAST] = 'East',
    [g.SOUTH] = 'South',
    [g.WEST] = 'West',
    [g.NORTH] = 'North'
}

-- for python conventional
local False = false
local True = true
local None = nil
local function len(x)
    return #x
end

--meld
 g.Meld=function( meld_type, tiles, opened, called_tile, who, from_who)
    local r= {
        CHI = 'chi',
        PON = 'pon',
        KAN = 'kan',
        CHANKAN = 'chankan',
        NUKI = 'nuki',
        who = nil,
        tiles = nil,
        type = nil,
        from_who = nil,
        called_tile = nil,
        opened = true,
        __init__ = function(self, meld_type, tiles, opened, called_tile, who, from_who)
            self.type = meld_type
            self.tiles = tiles or {}
            self.opened = opened
            self.called_tile = called_tile
            self.who = who
            self.from_who = from_who
            return self
        end,
        __str__ = function(self)
            return string.format('Type: {%s}, Tiles: {%s} {%s}', self.type, g.TilesConverter.to_one_line_string(self.tiles), self.tiles)
        end,
        __repr__ = function(self)
            return self.__str__()
        end,
        tiles_34 = function(self)
            local list = {}
            for i = 0, #self.tiles - 4 do
                list[i + 1] = math.floor(self.tiles[i] / 4)
            end
        end
    }
    
    return r:__init__(meld_type, tiles, opened, called_tile, who, from_who)
end

--shanten

function g.Shanten()
    return {
        AGARI_STATE = -1,
        tiles = {},
        number_melds = 0,
        number_tatsu = 0,
        number_pairs = 0,
        number_jidahai = 0,
        number_characters = 0,
        number_isolated_tiles = 0,
        min_shanten = 0,
        calculate_shanten = function(self, tiles_34, open_sets_34, chiitoitsu, kokushi)
            tiles_34 = deepcopy(tiles_34)

            self:_init(tiles_34)

            local count_of_tiles = sum(tiles_34)

            if count_of_tiles > 14 then
                return -2
            end

            if open_sets_34 then
                local isolated_tiles = g.utils.find_isolated_tile_indices(tiles_34)
                for _,meld in ipairs(open_sets_34) do
                    if not isolated_tiles then
                        break
                    end
                    local isolated_tile = table.remove(isolated_tiles)

                    tiles_34[meld[0 + 1]+1] = tiles_34[meld[0 + 1]+1] - 1
                    tiles_34[meld[1 + 1]+1] = tiles_34[meld[1 + 1]+1] - 1
                    tiles_34[meld[2 + 1]+1] = tiles_34[meld[2 + 1]+1] - 1
                    tiles_34[isolated_tile+1] = 3
                end
            end
            if not open_sets_34 then
                self.min_shanten = self:_scan_chiitoitsu_and_kokushi(chiitoitsu, kokushi)
            end
            self:_remove_character_tiles(count_of_tiles)

            local init_mentsu = math.floor((14 - count_of_tiles) / 3)
            self:_scan(init_mentsu)

            return self.min_shanten
        end,
        _init = function(self, tiles)
            self.tiles = tiles
            self.number_melds = 0
            self.number_tatsu = 0
            self.number_pairs = 0
            self.number_jidahai = 0
            self.number_characters = 0
            self.number_isolated_tiles = 0
            self.min_shanten = 8
        end,
        _scan = function(self, init_mentsu)
            self.number_characters = 0
            for i = 1, 27 do
                local v=0
                if (self.tiles[i] == 4) then
                    v=1
                else
                    v=0
                end
                self.number_characters = self.number_characters | v << (i-1)
            end
            self.number_melds = self.number_melds + init_mentsu
            self:_run(0)
        end,
        _run = function(self, depth)
            if self.min_shanten == g.AGARI_STATE then
                return
            end
           
            while self.tiles[depth+1]==0 do
                depth = depth + 1

                if depth >= 27 then
                    break
                end
            end
            if depth >= 27 then
                return self:_update_result()
            end
          
            local i = depth
            if i > 8 then
                i = i - 9
            end
            if i > 8 then
                i = i - 9
            end
            if self.tiles[depth+1] == 4 then
                self:_increase_set(depth)
                if i < 7 and self.tiles[depth + 2+1]~=0 then
                    if self.tiles[depth + 1+1]~=0 then
                        self:_increase_syuntsu(depth)
                        self:_run(depth + 1)
                        self:_decrease_syuntsu(depth)
                    end
                    self:_increase_tatsu_second(depth)
                    self:_run(depth + 1)
                    self:_decrease_tatsu_second(depth)
                end
                if i < 8 and self.tiles[depth + 1+1]~=0 then
                    self:_increase_tatsu_first(depth)
                    self:_run(depth + 1)
                    self:_decrease_tatsu_first(depth)
                end
                self:_increase_isolated_tile(depth)
                self:_run(depth + 1)
                self:_decrease_isolated_tile(depth)
                self:_decrease_set(depth)
                self:_increase_pair(depth)

                if i < 7 and self.tiles[depth + 2+1]~=0 then
                    if self.tiles[depth + 1+1] then
                        self:_increase_syuntsu(depth)
                        self:_run(depth)
                        self:_decrease_syuntsu(depth)
                    end
                    self:_increase_tatsu_second(depth)
                    self:_run(depth + 1)
                    self:_decrease_tatsu_second(depth)
                end
                if i < 8 and self.tiles[depth + 1+1]~=0 then
                    self:_increase_tatsu_first(depth)
                    self:_run(depth + 1)
                    self:_decrease_tatsu_first(depth)
                end
                self:_decrease_pair(depth)
            end
            if self.tiles[depth+1] == 3 then
                self:_increase_set(depth)
                self:_run(depth + 1)
                self:_decrease_set(depth)
                self:_increase_pair(depth)

                if i < 7 and self.tiles[depth + 1+1]~=0 and self.tiles[depth + 2+1]~=0 then
                    self:_increase_syuntsu(depth)
                    self:_run(depth + 1)
                    self:_decrease_syuntsu(depth)
                else
                    if i < 7 and self.tiles[depth + 2+1]~=0 then
                        self:_increase_tatsu_second(depth)
                        self:_run(depth + 1)
                        self:_decrease_tatsu_second(depth)
                    end
                    if i < 8 and self.tiles[depth + 1+1]~=0 then
                        self:_increase_tatsu_first(depth)
                        self:_run(depth + 1)
                        self:_decrease_tatsu_first(depth)
                    end
                end
                self:_decrease_pair(depth)

                if i < 7 and self.tiles[depth + 2+1] >= 2 and self.tiles[depth + 1+1] >= 2 then
                    self:_increase_syuntsu(depth)
                    self:_increase_syuntsu(depth)
                    self:_run(depth)
                    self:_decrease_syuntsu(depth)
                    self:_decrease_syuntsu(depth)
                end
            end
            if self.tiles[depth+1] == 2 then
                self:_increase_pair(depth)
                self:_run(depth + 1)
                self:_decrease_pair(depth)
                if i < 7 and self.tiles[depth + 2+1]~=0 and self.tiles[depth + 1+1]~=0 then
                    self:_increase_syuntsu(depth)
                    self:_run(depth)
                    self:_decrease_syuntsu(depth)
                end
            end
            if self.tiles[depth+1] == 1 then
                if i < 6 and self.tiles[depth + 1+1] == 1 and self.tiles[depth + 2+1]~=0 and self.tiles[depth + 3+1] ~= 4 then
                    self:_increase_syuntsu(depth)
                    self:_run(depth + 2)
                    self:_decrease_syuntsu(depth)
                else
                    self:_increase_isolated_tile(depth)
                    self:_run(depth + 1)
                    self:_decrease_isolated_tile(depth)

                    if i < 7 and self.tiles[depth + 2+1]~=0 then
                        if self.tiles[depth + 1+ 1]~=0 then
                            self:_increase_syuntsu(depth)
                            self:_run(depth + 1)
                            self:_decrease_syuntsu(depth)
                        end
                        self:_increase_tatsu_second(depth)
                        self:_run(depth + 1)
                        self:_decrease_tatsu_second(depth)
                    end
                    if i < 8 and self.tiles[depth + 1+1]~=0 then
                        self:_increase_tatsu_first(depth)
                        self:_run(depth + 1)
                        self:_decrease_tatsu_first(depth)
                    end
                end
            end
        end,
        _update_result = function(self)
            local ret_shanten = 8 - self.number_melds * 2 - self.number_tatsu - self.number_pairs
            local n_mentsu_kouho = self.number_melds + self.number_tatsu
            if self.number_pairs then
                n_mentsu_kouho = n_mentsu_kouho + self.number_pairs - 1
            elseif self.number_characters and self.number_isolated_tiles then
                if (self.number_characters | self.number_isolated_tiles) == self.number_characters then
                    ret_shanten = ret_shanten + 1
                end
            end
            if n_mentsu_kouho > 4 then
                ret_shanten = ret_shanten + n_mentsu_kouho - 4
            end
            if ret_shanten ~= g.AGARI_STATE and ret_shanten < self.number_jidahai then
                ret_shanten = self.number_jidahai
            end
            if ret_shanten < self.min_shanten then
                self.min_shanten = ret_shanten
            end
        end,
        _increase_set = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] - 3
            self.number_melds = self.number_melds + 1
        end,
        _decrease_set = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] + 3
            self.number_melds = self.number_melds - 1
        end,
        _increase_pair = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] - 2
            self.number_pairs = self.number_pairs + 1
        end,
        _decrease_pair = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] + 2
            self.number_pairs = self.number_pairs - 1
        end,
        _increase_syuntsu = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] - 1
            self.tiles[k + 1+1] = self.tiles[k + 1+1] - 1
            self.tiles[k + 2+1] = self.tiles[k + 2+1] - 1
            self.number_melds = self.number_melds + 1
        end,
        _decrease_syuntsu = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] + 1
            self.tiles[k + 1+1] = self.tiles[k + 1+1] + 1
            self.tiles[k + 2+1] = self.tiles[k + 2+1] + 1
            self.number_melds = self.number_melds - 1
        end,
        _increase_tatsu_first = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] - 1
            self.tiles[k + 1+1] = self.tiles[k + 1+1] - 1
            self.number_tatsu = self.number_tatsu + 1
        end,
        _decrease_tatsu_first = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] + 1
            self.tiles[k + 1+1] = self.tiles[k + 1+1] + 1
            self.number_tatsu = self.number_tatsu - 1
        end,
        _increase_tatsu_second = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] - 1
            self.tiles[k + 2+1] = self.tiles[k + 2+1] - 1
            self.number_tatsu = self.number_tatsu + 1
        end,
        _decrease_tatsu_second = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] + 1
            self.tiles[k + 2+1] = self.tiles[k + 2+1] + 1
            self.number_tatsu = self.number_tatsu - 1
        end,
        _increase_isolated_tile = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] - 1
            self.number_isolated_tiles = self.number_isolated_tiles | (1 << k)
        end,
        _decrease_isolated_tile = function(self, k)
            self.tiles[k+1] = self.tiles[k+1] + 1
            self.number_isolated_tiles = self.number_isolated_tiles | (1 << k)
        end,
        _scan_chiitoitsu_and_kokushi = function(self, chiitoitsu, kokushi)
            local shanten = self.min_shanten

            local indices = {0, 8, 9, 17, 18, 26, 27, 28, 29, 30, 31, 32, 33}

            local completed_terminals = 0
            for _, i in ipairs(indices) do
                if self.tiles[i+1] >= 2 then
                    completed_terminals = completed_terminals+1
                end
            end
            local terminals = 0
            for _, i in ipairs(indices) do
                if self.tiles[i+1] ~= 0 then
                    terminals = terminals + 1
                end
            end
            indices = {1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16, 19, 20, 21, 22, 23, 24, 25}

            local completed_pairs = completed_terminals
            for _, i in ipairs(indices) do
                if self.tiles[i+1] >= 2 then
                    completed_pairs = completed_pairs + 1
                end
            end
            local pairs = terminals
            for _, i in ipairs(indices) do
                if self.tiles[i+1] ~= 0 then
                    pairs = pairs + 1
                end
            end
            if chiitoitsu then
                local ret_shanten = 6 - completed_pairs + (pand(pairs < 7, 7 - pairs) or 0)
                if ret_shanten < shanten then
                    shanten = ret_shanten
                end
            end
            if kokushi then
                local ret_shanten = 13 - terminals - (pand(completed_terminals, 1) or 0)
                if ret_shanten < shanten then
                    shanten = ret_shanten
                end
            end
            return shanten
        end,
        _remove_character_tiles = function(self, nc)
            local number = 0
            local isolated = 0

            --for i in range(27, 34):
            for i = 27, 33 do
                if self.tiles[i+1] == 4 then
                    self.number_melds = self.number_melds + 1
                    self.number_jidahai = self.number_jidahai + 1
                    number = number | (1 << (i - 27))
                    isolated = isolated | (1 << (i - 27))
                end
                if self.tiles[i+1] == 3 then
                    self.number_melds = self.number_melds + 1
                end
                if self.tiles[i+1] == 2 then
                    self.number_pairs = self.number_pairs + 1
                end
                if self.tiles[i+1] == 1 then
                    isolated = isolated | (1 << (i - 27))
                end
            end
            if self.number_jidahai and (nc % 3) == 2 then
                self.number_jidahai = self.number_jidahai - 1
            end

            if isolated then
                self.number_isolated_tiles = self.number_isolated_tiles | (1 << 27)
                if (number | isolated) == number then
                    self.number_characters = self.number_characters | (1 << 27)
                end
            end
        end
    }
end

--tile

g.Tile = {
    value = nil,
    is_tsumogiri = nil,
    __init__ = function(self, value, is_tsumogiri)
        self.value = value
        self.is_tsumogiri = is_tsumogiri
    end
}

g.TilesConverter = {
    to_one_line_string = function(tiles, print_aka_dora)
        tiles = sorted(tiles)
        if print_aka_dora==nil then
            print_aka_dora= true
        end
        local man =
            picker(
            tiles,
            function(t)
                return t < 36
            end
        )

        local pin =
            picker(
            tiles,
            function(t)
                return 36 <= t and t < 72
            end
        )
        pin = picker(pin, nil, -36)

        local sou =
            picker(
            tiles,
            function(t)
                return 72 <= t and t < 108
            end
        )
        sou = picker(sou, nil, -72)

        local honors =
            picker(
            tiles,
            function(t)
                return t >= 108
            end
        )
        honors = picker(honors, nil, -108)

        local function words(suits, red_five, suffix)
            local word = ''
            for _, v in ipairs(suits) do
                if v == red_five and print_aka_dora then
                    word = word.."0"
                else
                    word = word..tostring(math.floor(v / 4) + 1)
                end
            end

            return pand(suits , '' .. word .. suffix) or ''
        end
        sou = words(sou, g.FIVE_RED_SOU - 72, 's')
        pin = words(pin, g.FIVE_RED_PIN - 36, 'p')
        man = words(man, g.FIVE_RED_MAN, 'm')
        honors = words(honors, -1 - 108, 'z')

        return man .. pin .. sou .. honors
    end,
    to_34_array = function(tiles)
        local results = arraygenerator(34, 0)
        for _,tile in ipairs(tiles) do
            tile = math.floor(tile / 4)
            results[tile+1] = results[tile+1] + 1
        end
        return results
    end,
    to_136_array = function(tiles)
        local temp = {}
        local results = {}
        --for x in range(0, 34):
        for x = 1, 34 do
            if tiles[x] then
                local temp_value = arraygenerator((x-1) * 4, tiles[x])
                for _, tile in ipairs(temp_value) do
                    if find(results, tile) then
                        local count_of_tiles =
                            #picker(
                            temp,
                            function(t)
                                return t == tile
                            end
                        )
                        local new_tile = tile + count_of_tiles
                        table.insert(results, new_tile)
                        table.insert(temp, tile)
                    else
                        table.insert(results, tile)
                        table.insert(temp, tile)
                    end
                end
            end
        end
        return results
    end,
    string_to_136_array = function(sou, pin, man, honors, has_aka_dora)
        --[[
        Method to convert one line string tiles format to the 136 array.
        You can pass r or 0 instead of 5 for it to become a red five from
        that suit. To prevent old usage without red,
        has_aka_dora has to be True for this to do that.
        We need it to increase readability of our tests
        ]]
        local function _split_string(st, offset, red)
            local data = {}
            local temp = {}
            
            if not st then
               
                return {}
            end

            for idx=1,#st do
                local i=string.sub(st,idx,idx)
                
                if (i == 'r' or i == '0') and has_aka_dora then
                    table.insert(temp, red)
                    table.insert(data, red)
                else
                    local tile = offset + (tonumber(i) - 1) * 4
                    if tile == red and has_aka_dora then
                        -- prevent non reds to become red
                        tile = tile + 1
                    end
                    if find(data, tile) then
                        local count_of_tiles =
                            #picker(
                            temp,
                            function(t)
                                return t == tile
                            end
                        )
                        local new_tile = tile + count_of_tiles

                        table.insert(temp, tile)
                        table.insert(data, new_tile)
                    else
                        table.insert(temp, tile)
                        table.insert(data, tile)
                    end
                end
            end
           
            return data
        end

        local results = _split_string(man, 0, g.FIVE_RED_MAN)
        for k, v in ipairs(_split_string(pin, 36, g.FIVE_RED_PIN)) do
            results[#results + 1] = v
        end
        for k, v in ipairs(_split_string(sou, 72, g.FIVE_RED_SOU)) do
            results[#results + 1] = v
        end
        for k, v in ipairs(_split_string(honors, 108)) do
            results[#results + 1] = v
        end
      
        return results
    end,
    string_to_34_array = function(sou, pin, man, honors)
        local results = g.TilesConverter.string_to_136_array(sou, pin, man, honors)
        results = g.TilesConverter.to_34_array(results)
        return results
    end,
    find_34_tile_in_136_array = function(tile34, tiles)
        if tile34 == nil or tile34 > 33 then
            return nil
        end

        local tile = tile34 * 4

        local possible_tiles = arraygenerator(1, tile)
        for i = 1, 3 do
            possible_tiles[#possible_tiles + 1] = tile + 1
        end
        -- + [tile + i for i in range(1, 4)]

        local found_tile = nil
        for _, possible_tile in ipairs(possible_tiles) do
            if find(tiles, possible_tile) then
                found_tile = possible_tile
                break
            end
        end

        return found_tile
    end,
    one_line_string_to_136_array = function(string, has_aka_dora)
        local sou = ''
        local pin = ''
        local man = ''
        local honors = ''

        local split_start = 0

        for index, i in ipairs(string) do
            if i == 'm' then
                man = man .. string:sub(split_start + 1, index)
                split_start = index + 1
            end
            if i == 'p' then
                pin = pin .. string:sub(split_start + 1, index)
                split_start = index + 1
            end
            if i == 's' then
                sou = sou .. string:sub(split_start + 1, index)
                split_start = index + 1
            end
            if i == 'z' or i == 'h' then
                honors = honors .. string:sub(split_start + 1, index)
                split_start = index + 1
            end
        end
        return g.TilesConverter.string_to_136_array(sou, pin, man, honors, has_aka_dora)
    end,
    one_line_string_to_34_array = function(string, has_aka_dora)
        local results = g.TilesConverter.one_line_string_to_136_array(string, has_aka_dora)
        results = g.TilesConverter.to_34_array(results)
        return results
    end
}

g.utils = {
    is_aka_dora = function(tile, aka_enabled)
        if not aka_enabled then
            return false
        end
        if find({g.FIVE_RED_MAN, g.FIVE_RED_PIN, g.FIVE_RED_SOU}, tile) then
            return true
        end
        return false
    end,
    plus_dora = function(tile, dora_indicators)
        local tile_index = math.floor(tile / 4)
        local dora_count = 0

        for _, dora in ipairs(dora_indicators) do
            dora = math.floor(dora / 4)

            -- sou, pin, man
            if tile_index < g.EAST then
                -- with indicator 9, dora will be 1
                if dora == 8 then
                    dora = -1
                elseif dora == 17 then
                    dora = 8
                elseif dora == 26 then
                    dora = 17
                end
                if tile_index == dora + 1 then
                    dora_count = dora_count + 1
                end
            else
                if dora < g.EAST then
                    --continue
                else
                    dora = dora - 9 * 3
                    local tile_index_temp = tile_index - 9 * 3

                    -- dora indicator is north
                    if dora == 3 then
                        dora = -1
                    end
                    -- dora indicator is hatsu
                    if dora == 6 then
                        dora = 3
                    end
                    if tile_index_temp == dora + 1 then
                        dora_count = dora_count + 1
                    end
                end
            end
        end
        return dora_count
    end,
    is_chi = function(item)
        if #item ~= 3 then
            return false
        end
        return (item[0 + 1] == item[1 + 1] - 1) and (item[1 + 1] - 1 == item[2 + 1] - 2)
    end,
    is_pon = function(item)
        if #item ~= 3 then
            return false
        end
        return (item[0 + 1] == item[1 + 1]) and ( item[1 + 1] == item[2 + 1])
    end,
    is_pair = function(item)
        return #item == 2
    end,
    is_man = function(tile)
        return tile <= 8
    end,
    is_pin = function(tile)
        return (8 < tile) and (tile <= 17)
    end,
    is_sou = function(tile)
        return (17 < tile) and (tile) <= 26
    end,
    is_honor = function(tile)
        return tile >= 27
    end,
    is_terminal = function(tile)
        return find(g.Tile.TERMINAL_INDICES, tile)
    end,
    is_dora_indicator_for_terminal = function(tile)
        return tile == 7 or tile == 8 or tile == 16 or tile == 17 or tile == 25 or tile == 26
    end,
    contains_terminals = function(hand_set)
        for _, v in ipairs(hand_set) do
            if (find(g.TERMINAL_INDICES, v)) then
                return true
            end
        end
        return false
    end,
    simplify = function(tile)
        return tile - 9 * math.floor(tile / 9)
    end,
    find_isolated_tile_indices = function(hand_34)
        local isolated_indices = {}

        for x = 1, g.CHUN + 1 -1 +1 do
            -- for honor tiles we don't need to check nearby tiles
            if g.utils.is_honor(x) and hand_34[x] == 0 then
                table.insert(isolated_indices, x)
            else
                local simplified = g.utils.simplify(x)

                -- 1 suit tile
                if simplified == 0 then
                    if hand_34[x] == 0 and hand_34[x + 1] == 0 then
                        table.insert(isolated_indices, x)
                    end
                elseif -- 9 suit tile
                    simplified == 8 then
                    -- 2-8 tiles tiles
                    if hand_34[x] == 0 and hand_34[x - 1] == 0 then
                        table.insert(isolated_indices, x)
                    end
                else
                    if hand_34[x] == 0 and hand_34[x - 1] == 0 and hand_34[x + 1] == 0 then
                        table.insert(isolated_indices, x)
                    end
                end
            end
        end
        return isolated_indices
    end,
    is_tile_strictly_isolated = function(hand_34, tile_34)
        hand_34 = deepcopy(hand_34)
        -- we don't need to count target tile in the hand
        hand_34[tile_34] = hand_34[tile_34] - 1
        if hand_34[tile_34] < 0 then
            hand_34[tile_34] = 0
        end
        local indices = {}
        if g.utils.is_honor(tile_34) then
            return hand_34[tile_34] == 0
        else
            local simplified = g.utils.simplify(tile_34)

            -- 1 suit tile
            if simplified == 0 then
                -- 2 suit tile
                indices = {tile_34, tile_34 + 1, tile_34 + 2}
            elseif simplified == 1 then
                -- 8 suit tile
                indices = {tile_34 - 1, tile_34, tile_34 + 1, tile_34 + 2}
            elseif simplified == 7 then
                -- 9 suit tile
                indices = {tile_34 - 2, tile_34 - 1, tile_34, tile_34 + 1}
            elseif simplified == 8 then
                -- 3-7 tiles tiles
                indices = {tile_34 - 2, tile_34 - 1, tile_34}
            else
                indices = {tile_34 - 2, tile_34 - 1, tile_34, tile_34 + 1, tile_34 + 2}
            end
        end
        return all(
            indices,
            function(x)
                return hand_34[x] == 0
            end
        )
    end,
    count_tiles_by_suits = function(tiles_34)
        local suits = {
            {['count'] = 0, ['name'] = 'sou', ['function'] = g.utils.is_sou},
            {['count'] = 0, ['name'] = 'man', ['function'] = g.utils.is_man},
            {['count'] = 0, ['name'] = 'pin', ['function'] = g.utils.is_pin},
            {['count'] = 0, ['name'] = 'honor', ['function'] = g.utils.is_honor}
        }

        for x = 0, 33 do
            local tile = tiles_34[x]
            if not tile then
                --continue
            else
                for _, item in ipairs(suits) do
                    if item['function'](x) then
                        item['count'] = item['count'] + tile
                    end
                end
            end
        end
        return suits
    end
}
local function simplifyindices(tbl)
    return picker(
        tbl,
        nil,
        nil,
        function(x)
            g.utils.simplify(x)
        end
    )
end
--
g.HandDivider = {
    divide_hand = function(tiles_34, melds)
        if not melds then
            melds = {}
        end

        local closed_hand_tiles_34 = deepcopy(tiles_34)

        -- small optimization, we can't have a pair in open part of the hand,
        -- so we don't need to try find pairs in open sets
        local sum = 0

        for _, v in ipairs(melds) do
            sum = sum + v.tiles_34
        end
        
        --local open_tile_indices = melds and reduce(lambda x, y: x + y, [x.tiles_34 for x in melds]) or []
        local open_tile_indices = melds or {}
        for _, open_item in ipairs(open_tile_indices) do
            closed_hand_tiles_34[open_item] = closed_hand_tiles_34[open_item] - 1
        end
        local pair_indices = g.HandDivider.find_pairs(closed_hand_tiles_34)

        -- let's try to find all possible hand options
        local hands = {}

        
        for _, pair_index in ipairs(pair_indices) do
            local local_tiles_34 = deepcopy(tiles_34)
            
            -- we don't need to combine already open sets
            for _,open_item in ipairs(open_tile_indices) do
                local_tiles_34[open_item+1] = local_tiles_34[open_item+1] - 1
            end
            local_tiles_34[pair_index+1] = local_tiles_34[pair_index+1] - 2

            -- 0 - 8 man tiles
            local man = g.HandDivider.find_valid_combinations(local_tiles_34, 0, 8)

            -- 9 - 17 pin tiles
            local pin = g.HandDivider.find_valid_combinations(local_tiles_34, 9, 17)

            -- 18 - 26 sou tiles
            local sou = g.HandDivider.find_valid_combinations(local_tiles_34, 18, 26)

            local honor = {}
            for _, x in ipairs(g.HONOR_INDICES) do
                if local_tiles_34[x+1] == 3 then
                    table.insert(honor, arraygenerator(3, x))
                end
            end
            if #honor>0 then
                honor = {honor}
            end
            local arrays = {{arraygenerator(2, pair_index)}}
            if #sou>0  then
                arrays=cat(arrays,sou)
                --table.insert(arrays, sou)
            end
            if #man>0 then
                arrays=cat(arrays,man)
                --table.insert(arrays, man)
            end
            if #pin>0 then
                arrays=cat(arrays,pin)
                --table.insert(arrays, pin)
            end
            if #honor>0 then
                arrays=cat(arrays,honor)
                --table.insert(arrays, honor)
            end
            for _,meld in ipairs(melds) do
                arrays=cat(arrays, {meld.tiles_34})
                --table.insert(arrays, {meld.tiles_34})
            end
           

            -- let's find all possible hand from our valid sets
            for _,s in ipairs(itertools.product(arrays)) do
                local hand = {}
               
                for _, item in ipairs(s) do
                    if type(item[0 + 1]) == 'table' then
                        for _, x in ipairs(item) do
                            table.insert(hand, x)
                        end
                    else
                        table.insert(hand, item)
                    end
                end
                hand =
                    sorted(
                    hand,
                    function(x, y)
                        return x[0 + 1] < y[0 + 1]
                    end
                )
               
                if #hand == 5 then
                    table.insert(hands, hand)
                    
                end
            end
        end
        -- small optimization, let's remove hand duplicates
        local unique_hands = {}
        for _, hand in ipairs(hands) do
           
            hand =
                sorted(
                hand,
                function(x, y)
                    if (x[0 + 1] == y[0 + 1]) then
                        return x[1 + 1] < y[1 + 1]
                    else
                        return x[0 + 1] < y[0 + 1]
                    end
                end
            )

            local notfound = true
            for _, v in ipairs(unique_hands) do
                if (v == hand) then
                    notfound = false
                    break
                end
            end
            if notfound then
                table.insert(unique_hands, hand)
            end
        end
        hands = unique_hands

        if #pair_indices == 7 then
            local hand = {}
            for _, index in pair_indices do
                table.insert(hand, arraygenerator(2, index))
            end
            table.insert(hands, hand)
        end
      
        --return sorted(hands)
        return hands
    end,
    find_pairs = function(tiles_34, first_index, second_index)
        --[[
    Find all possible pairs in the hand and return their indices
    :return: array of pair indices
    ]]
       
        first_index = first_index or 0
        second_index = second_index or 33
        local pair_indices = {}
        for x = first_index, second_index + 1 - 1 do
            -- ignore pon of honor tiles, because it can't be a part of pair
            if isin({x}, g.HONOR_INDICES) and tiles_34[x+1] ~= 2 then
                --continue
            else
                if tiles_34[x+1] >= 2 then
                    table.insert(pair_indices, x)
                end
            end
        end
    
        return pair_indices
    end,
    find_valid_combinations = function(tiles_34, first_index, second_index, hand_not_completed)
        --[[
    Find and return all valid set combinations in given suit
    :param tiles_34:
    :param first_index:
    :param second_index:
    :param hand_not_completed: in that mode we can return just possible shi or pon sets
    :return: list of valid combinations
    ]]
        local indices = {}
        for x = first_index, second_index + 1 - 1 do
            if tiles_34[x+1] > 0 then
               
                indices = cat(indices, arraygenerator(tiles_34[x+1], x))
            end
        end
       
        if  #indices==0 then
            return {}
        end
        local all_possible_combinations = ipermutations(indices,3)
        
        local function is_valid_combination(possible_set)
            
            if g.utils.is_chi(possible_set) then
                return true
            end

            if g.utils.is_pon(possible_set) then
                return true
            end

            return false
        end
        local valid_combinations = {}
        for _, combination in ipairs(all_possible_combinations) do
            if is_valid_combination(combination) then
                table.insert(valid_combinations,combination)
            end
        end
        if #valid_combinations == 0 then
         
            return {}
        end
        local count_of_needed_combinations = math.floor(#indices / 3)

        local z = {}
        for _, v in ipairs(valid_combinations) do
            z = cat(z, v)
        end

        local comp = true
        if #z ~= #indices then
            comp = false
        else
            for i, v in ipairs(valid_combinations) do
                if (indices[i] ~= v) then
                    comp = false
                    break
                end
            end
        end

        -- simple case, we have count of sets == count of tiles
        if count_of_needed_combinations == #valid_combinations and comp then
            return {valid_combinations}
        end
        -- filter and remove not possible pon sets
        for _, item in ipairs(valid_combinations) do
            if g.utils.is_pon(item) then
                local count_of_sets = 1
                local count_of_tiles = 0
                while count_of_sets > count_of_tiles do
                    count_of_tiles =
                        #picker(
                        indices,
                        function(x)
                            return x == item[0 + 1]
                        end
                    ) / 3
                    count_of_sets =
                        #picker(
                        valid_combinations,
                        function(x)
                            if x[0 + 1] == item[0 + 1] and x[1 + 1] == item[1 + 1] and x[2 + 1] == item[2 + 1] then
                                return true
                            else
                                return false
                            end
                        end
                    )

                    if count_of_sets > count_of_tiles then
                        tableremove(valid_combinations, item)
                    --valid_combinations.remove(item)
                    end
                end
            end
        end
        -- filter and remove not possible chi sets
        for _, item in ipairs(valid_combinations) do
            if g.utils.is_chi(item) then
                local count_of_sets = 5
                -- TODO calculate real count of possible sets
                local count_of_possible_sets = 4
                while count_of_sets > count_of_possible_sets do
                    count_of_sets =
                        #picker(
                        valid_combinations,
                        function(x)
                            return x[0 + 1] == item[0 + 1] and x[1 + 1] == item[1 + 1] and x[2 + 1] == item[2 + 1]
                        end
                    )

                    if count_of_sets > count_of_possible_sets then
                        tableremove(valid_combinations,item)
                        
                    end
                end
            end
        end
        -- lit of chi\pon sets for not completed hand
        if hand_not_completed then
            return {valid_combinations}
        end
        -- hard case - we can build a lot of sets from our tiles
        -- for example we have 123456 tiles and we can build sets:
        -- [1, 2, 3] [4, 5, 6] [2, 3, 4] [3, 4, 5]
        -- and only two of them valid in the same time [1, 2, 3] [4, 5, 6]
        local tbl = {}
        for i = 1, #valid_combinations do
            tbl[#tbl + 1] = i
        end
        local possible_combinations = ipermutations(tbl, count_of_needed_combinations)

        local combinations_results = {}

        for _, combination in ipairs(possible_combinations) do
            local result = {}
            
            for _, item in ipairs(combination) do
                result=cat(result, valid_combinations[item])
            end
            
            result = sorted(result)
           
            if  arrayequal(result,indices) then
                local results = {}
                for _, item in ipairs(combination) do
                    table.insert(results, valid_combinations[item])
                end
                results =
                    sorted(
                    results,
                    function(a,z)
                        return  a[0 + 1]< z[0 + 1]
                    end
                )
                if not isin(results, combinations_results) then
                    table.insert(combinations_results, results)
                end
            end
        end
        combinations_results=uniq(combinations_results)
        return combinations_results
    end
}

--fu
g.FuCalculator = {
    BASE = 'base',
    PENCHAN = 'penchan',
    KANCHAN = 'kanchan',
    VALUED_PAIR = 'valued_pair',
    PAIR_WAIT = 'pair_wait',
    TSUMO = 'tsumo',
    HAND_WITHOUT_FU = 'hand_without_fu',
    CLOSED_PON = 'closed_pon',
    OPEN_PON = 'open_pon',
    CLOSED_TERMINAL_PON = 'closed_terminal_pon',
    OPEN_TERMINAL_PON = 'open_terminal_pon',
    CLOSED_KAN = 'closed_kan',
    OPEN_KAN = 'open_kan',
    CLOSED_TERMINAL_KAN = 'closed_terminal_kan',
    OPEN_TERMINAL_KAN = 'open_terminal_kan',
    calculate_fu = function( hand, win_tile, win_group, config, valued_tiles, melds)
        --[[
        Calculate hand fu with explanations
        :param hand:
        :param win_tile: 136 tile format
        :param win_group: one set where win tile exists
        :param is_tsumo:
        :param config: HandConfig object
        :param valued_tiles: dragons, player wind, round wind
        :param melds: opened sets
        :return:
        ]]
        local win_tile_34 = math.floor(win_tile / 4)

        if not valued_tiles then
            valued_tiles = {}
        end

        if not melds then
            melds = {}
        end

        local fu_details = {}

        if #hand == 7 then
            return {['fu'] = 25, ['reason'] = g.FuCalculator.BASE}, 25
        end
        local pair =
            picker(
            hand,
            function(x)
                return g.utils.is_pair(x)
            end
        )[1]
        local pon_sets =
            picker(
            hand,
            function(x)
                return g.utils.is_pon(x)
            end
        )

        local copied_opened_melds =
            picker(
            melds,
            function(x)
                return x.type == g.Meld.CHI
            end
        )
        local closed_chi_sets = {}
        for _, x in ipairs(hand) do
            if not isin(copied_opened_melds, x) then
                --closed_chi_sets.append(x)
                table.insert(closed_chi_sets, x)
            else
                table.insert(copied_opened_melds, x)
                tableremove(copied_opened_melds, x)
            end
        end
        local is_open_hand =
            any(
            picker(
                melds,
                nil,
                nil,
                function(x)
                    return x.opened
                end
            )
        )

        if isin(closed_chi_sets, win_group) then
            local tile_index = g.utils.simplify(win_tile_34)

            -- penchan
            if g.utils.contains_terminals(win_group) then
                -- 1-2-... wait
                if tile_index == 2 and indexof(win_group, win_tile_34) == 2 + 1 then
                    table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.PENCHAN})
                elseif -- 8-9-... wait
                    tile_index == 6 and indexof(win_group, win_tile_34) == 0 + 1 then
                    table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.PENCHAN})
                end
            end
            -- kanchan waiting 5-...-7
            if indexof(win_group,win_tile_34) == 1 then
                table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.KANCHAN})
            end
        end
        -- valued pair
        local count_of_valued_pairs = countof(valued_tiles, pair[1])
        if count_of_valued_pairs == 1 then
            table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.VALUED_PAIR})
        end
        -- east-east pair when you are on east gave double fu
        if count_of_valued_pairs == 2 then
            table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.VALUED_PAIR})
            table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.VALUED_PAIR})
        end
        -- pair wait
        if g.utils.is_pair(win_group) then
            table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.PAIR_WAIT})
        end
        for _, set_item in ipairs(pon_sets) do
            local open_meld =
                picker(
                melds,
                function(x)
                    return set_item == x.tiles_34
                end
            )
            open_meld = open_meld and open_meld[0 + 1] or nil

            local set_was_open = open_meld and open_meld.opened or false
            local is_kan = (open_meld and (open_meld.type == g.Meld.KAN or open_meld.type == g.Meld.CHANKAN)) or false
            local is_honor = isin(g.TERMINAL_INDICES,set_item[1]) or isin( g.HONOR_INDICES,set_item[1])

            -- we win by ron on the third pon tile, our pon will be count as open
            if not config.is_tsumo and arrayequal(set_item,win_group) then
                set_was_open = true
            end
            if is_honor then
                if is_kan then
                    if set_was_open then
                        table.insert(fu_details, {['fu'] = 16, ['reason'] = g.FuCalculator.OPEN_TERMINAL_KAN})
                    else
                        table.insert(fu_details, {['fu'] = 32, ['reason'] = g.FuCalculator.CLOSED_TERMINAL_KAN})
                    end
                else
                    if set_was_open then
                        table.insert(fu_details, {['fu'] = 4, ['reason'] = g.FuCalculator.OPEN_TERMINAL_PON})
                    else
                        table.insert(fu_details, {['fu'] = 8, ['reason'] = g.FuCalculator.CLOSED_TERMINAL_PON})
                    end
                end
            else
                if is_kan then
                    if set_was_open then
                        table.insert(fu_details, {['fu'] = 8, ['reason'] = g.FuCalculator.OPEN_KAN})
                    else
                        table.insert(fu_details, {['fu'] = 16, ['reason'] = g.FuCalculator.OPCLOSED_KANEN_KAN})
                    end
                else
                    if set_was_open then
                        table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.OPEN_PON})
                    else
                        table.insert(fu_details, {['fu'] = 4, ['reason'] = g.FuCalculator.CLOSED_PON})
                    end
                end
            end
        end
        local add_tsumo_fu = #fu_details > 0 or config.options.fu_for_pinfu_tsumo

        if config.is_tsumo and add_tsumo_fu then
            -- 2 additional fu for tsumo (but not for pinfu)
            table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.TSUMO})
        end
        if is_open_hand and #fu_details == 0 and config.options.fu_for_open_pinfu then
            -- there is no 1-20 hands, so we had to add additional fu
            table.insert(fu_details, {['fu'] = 2, ['reason'] = g.FuCalculator.HAND_WITHOUT_FU})
        end
        if is_open_hand or config.is_tsumo then
            table.insert(fu_details, {['fu'] = 20, ['reason'] = g.FuCalculator.BASE})
        else
            table.insert(fu_details, {['fu'] = 20, ['reason'] = g.FuCalculator.BASE})
        end
        return fu_details, g.FuCalculator.round_fu(fu_details)
    end,
    round_fu = function(fu_details)
        -- 22 -> 30 and etc.
        local fu =
            sum(
            picker(
                fu_details,
                nil,
                nil,
                function(x)
                    return x['fu']
                end
            )
        )
        return math.floor((fu + 9) / 10) * 10
    end
}
--handcalculator
g.HandCalculator = {
    config = nil,
    estimate_hand_value = function(tiles, win_tile, melds, dora_indicators, config)
        --[[
        :param tiles: array with 14 tiles in 136-tile format
        :param win_tile: 136 format tile that caused win (ron or tsumo)
        :param melds: array with Meld objects
        :param dora_indicators: array of tiles in 136-tile format
        :param config: HandConfig object
        :return: HandResponse object
        ]]
        local self = g.HandCalculator
        if not melds then
            melds = {}
        end

        if not dora_indicators then
            dora_indicators = {}
        end
        self.config = config or g.HandConfig()

        local agari = g.Agari
        local hand_yaku = {}
        local scores_calculator = g.ScoresCalculator
        local tiles_34 = g.TilesConverter.to_34_array(tiles)
        local divider = g.HandDivider
        local fu_calculator = g.FuCalculator

        local opened_melds =
            picker(
            melds,
            function(x)
                return x.opened
            end,
            nil,
            function(x)
                return x.tiles_34
            end
        )
        local all_melds =
            picker(
            melds,
            nil,
            nil,
            function(x)
                return x.tiles_34
            end
        )
        local is_open_hand = #opened_melds > 0

        -- special situation
        if self.config.is_nagashi_mangan then
            table.insert(hand_yaku, self.config.yaku.nagashi_mangan)

            local fu = 30
            local han = self.config.yaku.nagashi_mangan.han_closed
            local cost = scores_calculator.calculate_scores(han, fu, self.config, false)
            return g.HandResponse(cost, han, fu, hand_yaku)
        end
        if not isin(tiles, win_tile) then
            return g.HandResponse(nil, nil, nil, nil,  'Win tile not in the hand')
        end
        if self.config.is_riichi and is_open_hand then
            return g.HandResponse(nil, nil, nil, nil,  "Riichi can't be declared with open hand")
        end
        if self.config.is_daburu_riichi and is_open_hand then
            return g.HandResponse(nil, nil, nil, nil,  "Daburu Riichi can't be declared with open hand")
        end
        if self.config.is_ippatsu and is_open_hand then
            return g.HandResponse(nil, nil, nil, nil,  "Ippatsu can't be declared with open hand")
        end
        if self.config.is_ippatsu and not self.config.is_riichi and not self.config.is_daburu_riichi then
            return g.HandResponse(nil, nil, nil, nil,  "Ippatsu can't be declared without riichi")
        end
        if not agari.is_agari(tiles_34, all_melds) then
            return g.HandResponse(nil, nil, nil, nil,  'Hand is not winning')
        end
        if not self.config.options.has_double_yakuman then
            self.config.yaku.daburu_kokushi.han_closed = 13
            self.config.yaku.suuankou_tanki.han_closed = 13
            self.config.yaku.daburu_chuuren_poutou.han_closed = 13
            self.config.yaku.daisuushi.han_closed = 13
            self.config.yaku.daisuushi.han_open = 13
        end
        
        local hand_options = g.HandDivider.divide_hand(tiles_34, melds)
       
        local calculated_hands = {}
        for _, hand in ipairs(hand_options) do
            local is_chiitoitsu = self.config.yaku.chiitoitsu:is_condition_met(hand)
            local valued_tiles = {g.HAKU, g.HATSU, g.CHUN, self.config.player_wind, self.config.round_wind}
            
            local win_groups = self._find_win_groups(win_tile, hand, opened_melds)
            for _, win_group in ipairs(win_groups) do
            
                local cost = nil
                local error = nil
                local hand_yaku = {}
                local han = 0

                local fu_details, fu = fu_calculator.calculate_fu(hand, win_tile, win_group, self.config, valued_tiles, melds)

                local is_pinfu = #fu_details == 1 and not is_chiitoitsu and not is_open_hand

                local pon_sets =
                    picker(
                    hand,
                    function(x)
                        return g.utils.is_pon(x)
                    end
                )
                local chi_sets =
                    picker(
                    hand,
                    function(x)
                        return g.utils.is_chi(x)
                    end
                )

                if self.config.is_tsumo then
                    if not is_open_hand then
                        table.insert(hand_yaku, self.config.yaku.tsumo)
                    end
                end
                if is_pinfu then
                    table.insert(hand_yaku, self.config.yaku.pinfu)
                end
                -- let's skip hand that looks like chitoitsu, but it contains open sets
                if is_chiitoitsu and is_open_hand then
                    --continue
                else
                    if is_chiitoitsu then
                        table.insert(hand_yaku, self.config.yaku.chiitoitsu)
                    end
                    local is_daisharin = self.config.yaku.daisharin:is_condition_met(hand, self.config.options.has_daisharin_other_suits)
                    if self.config.options.has_daisharin and is_daisharin then
                        self.config.yaku.daisharin.rename(hand)
                        table.insert(hand_yaku, self.config.yaku.daisharin)
                    end
                    local is_tanyao = self.config.yaku.tanyao:is_condition_met(hand)
                    if is_open_hand and not self.config.options.has_open_tanyao then
                        is_tanyao = false
                    end
                    if is_tanyao then
                        table.insert(hand_yaku, self.config.yaku.tanyao)
                    end
                    if self.config.is_riichi and not self.config.is_daburu_riichi then
                        table.insert(hand_yaku, self.config.yaku.riichi)
                    end
                    if self.config.is_daburu_riichi then
                        table.insert(hand_yaku, self.config.yaku.daburu_riichi)
                    end
                    if self.config.is_ippatsu then
                        table.insert(hand_yaku, self.config.yaku.ippatsu)
                    end
                    if self.config.is_rinshan then
                        table.insert(hand_yaku, self.config.yaku.rinshan)
                    end

                    if self.config.is_chankan then
                        table.insert(hand_yaku, self.config.yaku.chankan)
                    end
                    if self.config.is_haitei then
                        table.insert(hand_yaku, self.config.yaku.haitei)
                    end
                    if self.config.is_houtei then
                        table.insert(hand_yaku, self.config.yaku.houtei)
                    end
                    if self.config.is_renhou then
                        if self.config.options.renhou_as_yakuman then
                            table.insert(hand_yaku, self.config.yaku.renhou_yakuman)
                        else
                            table.insert(hand_yaku, self.config.yaku.renhou)
                        end
                    end
                    if self.config.is_tenhou then
                        table.insert(hand_yaku, self.config.yaku.tenhou)
                    end
                    if self.config.is_chiihou then
                        table.insert(hand_yaku, self.config.yaku.chiihou)
                    end
                    if self.config.yaku.honitsu:is_condition_met(hand) then
                        table.insert(hand_yaku, self.config.yaku.honitsu)
                    end

                    if self.config.yaku.chinitsu:is_condition_met(hand) then
                        table.insert(hand_yaku, self.config.yaku.chinitsu)
                    end
                    if self.config.yaku.tsuisou:is_condition_met(hand) then
                        table.insert(hand_yaku, self.config.yaku.tsuisou)
                    end

                    if self.config.yaku.honroto:is_condition_met(hand) then
                        table.insert(hand_yaku, self.config.yaku.honroto)
                    end

                    if self.config.yaku.chinroto:is_condition_met(hand) then
                        table.insert(hand_yaku, self.config.yaku.chinroto)
                    end
                    if self.config.yaku.ryuisou:is_condition_met(hand) then
                        table.insert(hand_yaku, self.config.yaku.ryuisou)
                    end

                    -- small optimization, try to detect yaku with chi required sets only if we have chi sets in hand
                    if #chi_sets > 0 then
                        if self.config.yaku.chanta:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.chanta)
                        end

                        if self.config.yaku.junchan:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.junchan)
                        end

                        if self.config.yaku.ittsu:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.ittsu)
                        end

                        if not is_open_hand then
                            if self.config.yaku.ryanpeiko:is_condition_met(hand) then
                                table.insert(hand_yaku, self.config.yaku.ryanpeiko)
                            
                            elseif self.config.yaku.iipeiko:is_condition_met(hand) then
                                table.insert(hand_yaku, self.config.yaku.iipeiko)
                            end
                        end
                        if self.config.yaku.sanshoku:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.sanshoku)
                        end
                    end
                    -- small optimization, try to detect yaku with pon required sets only if we have pon sets in hand
                    if #pon_sets > 0 then
                        if self.config.yaku.toitoi:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.toitoi)
                        end

                        if self.config.yaku.sanankou:is_condition_met(hand, win_tile, melds, self.config.is_tsumo) then
                            table.insert(hand_yaku, self.config.yaku.sanankou)
                        end

                        if self.config.yaku.sanshoku_douko:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.sanshoku_douko)
                        end

                        if self.config.yaku.shosangen:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.shosangen)
                        end

                        if self.config.yaku.haku:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.haku)
                        end

                        if self.config.yaku.hatsu:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.hatsu)
                        end

                        if self.config.yaku.chun:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.chun)
                        end

                        if self.config.yaku.east:is_condition_met(hand, self.config.player_wind, self.config.round_wind) then
                            if self.config.player_wind == g.EAST then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_place)
                            end
                            if self.config.round_wind == g.EAST then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_round)
                            end
                        end
                        if self.config.yaku.south:is_condition_met(hand, self.config.player_wind, self.config.round_wind) then
                            if self.config.player_wind == g.SOUTH then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_place)
                            end
                            if self.config.round_wind == g.SOUTH then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_round)
                            end
                        end
                        if self.config.yaku.west:is_condition_met(hand, self.config.player_wind, self.config.round_wind) then
                            if self.config.player_wind == g.WEST then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_place)
                            end
                            if self.config.round_wind == g.WEST then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_round)
                            end
                        end
                        if self.config.yaku.north:is_condition_met(hand, self.config.player_wind, self.config.round_wind) then
                            if self.config.player_wind == g.NORTH then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_place)
                            end
                            if self.config.round_wind == g.NORTH then
                                table.insert(hand_yaku, self.config.yaku.yakuhai_round)
                            end
                        end
                        if self.config.yaku.daisangen:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.daisangen)
                        end

                        if self.config.yaku.shosuushi:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.shosuushi)
                        end

                        if self.config.yaku.daisuushi:is_condition_met(hand) then
                            table.insert(hand_yaku, self.config.yaku.daisuushi)
                        end
                        -- closed kan can't be used in chuuren_poutou
                        if not len(melds) and self.config.yaku.chuuren_poutou:is_condition_met(hand) then
                            if tiles_34[math.floor(win_tile / 4)] == 2 or tiles_34[math.floor(win_tile / 4)] == 4 then
                                table.insert(hand_yaku, self.config.yaku.daburu_chuuren_poutou)
                            else
                                table.insert(hand_yaku, self.config.yaku.chuuren_poutou)
                            end
                        end

                        if not is_open_hand and self.config.yaku.suuankou:is_condition_met(hand, win_tile, self.config.is_tsumo) then
                            if tiles_34[math.floor(win_tile / 4)] == 2 then
                                table.insert(hand_yaku, self.config.yaku.suuankou_tanki)
                            else
                                table.insert(hand_yaku, self.config.yaku.suuankou)
                            end
                        end

                        if self.config.yaku.sankantsu:is_condition_met(hand, melds) then
                            table.insert(hand_yaku, self.config.yaku.sankantsu)
                        end

                        if self.config.yaku.suukantsu:is_condition_met(hand, melds) then
                            table.insert(hand_yaku, self.config.yaku.suukantsu)
                        end
                    end
                    -- yakuman is not connected with other yaku
                    local yakuman_list =
                        picker(
                        hand_yaku,
                        function(x)
                            return x.is_yakuman
                        end
                    )
                    if #yakuman_list > 0 then
                        hand_yaku = yakuman_list
                    end
                    -- calculate han
                    for _, item in ipairs(hand_yaku) do
                        if is_open_hand and item.han_open then
                            han = han + item.han_open
                        else
                            han = han + item.han_closed
                        end
                    end
                    if han == 0 then
                        error = 'There are no yaku in the hand'
                        cost = nil
                    end

                    -- we don't need to add dora to yakuman
                    if #yakuman_list == 0 then
                        local tiles_for_dora = deepcopy(tiles)

                        -- we had to search for dora in kan fourth tiles as well
                        for _, meld in ipairs(melds) do
                            if meld.type == g.Meld.KAN or meld.type == g.Meld.CHANKAN then
                                table.insert(tiles_for_dora, meld.tiles[3 + 1])
                            end
                        end
                        local count_of_dora = 0
                        local count_of_aka_dora = 0

                        for _, tile in ipairs(tiles_for_dora) do
                            count_of_dora = count_of_dora + g.utils.plus_dora(tile, dora_indicators)
                        end
                        for _, tile in ipairs(tiles_for_dora) do
                            if g.utils.is_aka_dora(tile, self.config.options.has_aka_dora) then
                                count_of_aka_dora = count_of_aka_dora + 1
                            end
                        end
                        if count_of_dora > 0 then
                            self.config.yaku.dora.han_open = count_of_dora
                            self.config.yaku.dora.han_closed = count_of_dora

                            table.insert(hand_yaku, self.config.yaku.dora)

                            han = han + count_of_dora
                        end
                        if count_of_aka_dora > 0 then
                            self.config.yaku.aka_dora.han_open = count_of_aka_dora
                            self.config.yaku.aka_dora.han_closed = count_of_aka_dora
                            table.insert(hand_yaku, self.config.yaku.aka_dora)

                            han = han + count_of_aka_dora
                        end
                    end
                    if not error then
                        cost = scores_calculator:calculate_scores(han, fu, self.config, #yakuman_list > 0)
                    end
                    local calculated_hand = {
                        ['cost'] = cost,
                        ['error'] = error,
                        ['hand_yaku'] = hand_yaku,
                        ['han'] = han,
                        ['fu'] = fu,
                        ['fu_details'] = fu_details
                    }
                    table.insert(calculated_hands, calculated_hand)
                end
            end
        end
        -- exception hand
        if not is_open_hand and self.config.yaku.kokushi:is_condition_met(nil, tiles_34) then
            if tiles_34[math.floor(win_tile / 4)] == 2 then
                table.insert(hand_yaku, self.config.yaku.daburu_kokushi)
            else
                table.insert(hand_yaku, self.config.yaku.kokushi)
            end
            if self.config.is_renhou and self.config.options.renhou_as_yakuman then
                table.insert(hand_yaku, self.config.yaku.renhou_yakuman)
            end

            if self.config.is_tenhou then
                table.insert(hand_yaku, self.config.yaku.tenhou)
            end
            if self.config.is_chiihou then
                table.insert(hand_yaku, self.config.yaku.chiihou)
            end
            -- calculate han
            local han = 0
            for _, item in ipairs(hand_yaku) do
                if is_open_hand and item.han_open then
                    han = han + item.han_open
                else
                    han = han + item.han_closed
                end
            end
            local fu = 0
            local cost = scores_calculator:calculate_scores(han, fu, self.config, #hand_yaku > 0)
            table.insert(
                calculated_hands,
                {
                    ['cost'] = cost,
                    ['error'] = nil,
                    ['hand_yaku'] = hand_yaku,
                    ['han'] = han,
                    ['fu'] = fu,
                    ['fu_details'] = {}
                }
            )
        end

        -- let's use cost for most expensive hand
        --calculated_hands = itertools.sorted(calculated_hands, function(x) return x['han'], x['fu'] end, true)
       
        calculated_hands =
            itertools.sorted(
            calculated_hands,
            function(x)
                return x['han'] * 10000 + x['fu']
            end,
            true
        )
      
        local calculated_hand = calculated_hands[0+1]
        
        local cost = calculated_hand['cost']
        local error = calculated_hand['error']
        local hand_yaku = calculated_hand['hand_yaku']
        local han = calculated_hand['han']
        local fu = calculated_hand['fu']
        local fu_details = calculated_hand['fu_details']

        return g.HandResponse(cost, han, fu, hand_yaku, error, fu_details)
    end,
    _find_win_groups = function(win_tile, hand, opened_melds)
        local win_tile_34 = math.floor((win_tile or 0) / 4)

        -- to detect win groups
        -- we had to use only closed sets
        local closed_set_items = {}
        for _, x in ipairs(hand) do
            if not isin(opened_melds, x) then
                --closed_set_items.append(x)
                table.insert(closed_set_items, x)
            else
                tableremove(opened_melds, x)
            end
        end
        -- for forms like 45666 and ron on 6
        -- we can assume that ron was on 456 form and on 66 form
        -- and depends on form we will have different hand cost
        -- so, we had to check all possible win groups
        local win_groups =
            picker(
            closed_set_items,
            function(x)
                return isin(x, win_tile_34)
            end
        )
        local s = set(win_groups)
        local unique_win_groups =
            picker(
            win_groups,
            function(x)
                return compset(s, x)
            end,
            nil,
            function(x)
                return {x}
            end
        )

        return unique_win_groups
    end
}

--HandConfig
g.HandConstants = {
    -- Hands over 26+ han don't count as double yakuman
    KAZOE_LIMITED = 0,
    -- Hands over 13+ is a sanbaiman
    KAZOE_SANBAIMAN = 1,
    -- 26+ han as double yakuman, 39+ han as triple yakuman, etc.
    KAZOE_NO_LIMIT = 2
}

g.OptionalRules = function()
    return {
        --[[
    All the supported optional rules
    ]]
        has_open_tanyao = true,
        has_aka_dora = true,
        has_double_yakuman = true,
        kazoe_limit = g.HandConstants.KAZOE_LIMITED,
        kiriage = false,
        -- if false, 1-20 hand will be possible
        fu_for_open_pinfu = true,
        -- if true, pinfu tsumo will be disabled
        fu_for_pinfu_tsumo = false,
        renhou_as_yakuman = true,
        has_daisharin = true,
        has_daisharin_other_suits = true,
        __init__ = function(
            self,
            has_open_tanyao,
            has_aka_dora,
            has_double_yakuman,
            kazoe_limit,
            kiriage,
            fu_for_open_pinfu,
            fu_for_pinfu_tsumo,
            renhou_as_yakuman,
            has_daisharin,
            has_daisharin_other_suits)
            self.has_open_tanyao = has_open_tanyao
            self.has_aka_dora = has_aka_dora
            self.has_double_yakuman = has_double_yakuman
            self.kazoe_limit = kazoe_limit
            self.kiriage = kiriage
            self.fu_for_open_pinfu = fu_for_open_pinfu
            self.fu_for_pinfu_tsumo = fu_for_pinfu_tsumo
            self.renhou_as_yakuman = renhou_as_yakuman
            self.has_daisharin = has_daisharin or has_daisharin_other_suits
            self.has_daisharin_other_suits = has_daisharin_other_suits
        end
    }
end

g.HandConfig = function()
    local c= combine(
        deepcopy(g.HandConstants),
        {
            --[[
    Special class to pass various settings to the hand calculator object
    ]]
            yaku = nil,
            options = nil,
            is_tsumo = false,
            is_riichi = false,
            is_ippatsu = false,
            is_rinshan = false,
            is_chankan = false,
            is_haitei = false,
            is_houtei = false,
            is_daburu_riichi = false,
            is_nagashi_mangan = false,
            is_tenhou = false,
            is_renhou = false,
            is_chiihou = false,
            is_dealer = false,
            player_wind = nil,
            round_wind = nil,
            __init__ = function(
                self,
                is_tsumo,
                is_riichi,
                is_ippatsu,
                is_rinshan,
                is_chankan,
                is_haitei,
                is_houtei,
                is_daburu_riichi,
                is_nagashi_mangan,
                is_tenhou,
                is_renhou,
                is_chiihou,
                player_wind,
                round_wind,
                options)
                self.yaku = g.YakuConfig()
                self.options = options or g.OptionalRules()

                self.is_tsumo = is_tsumo
                self.is_riichi = is_riichi
                self.is_ippatsu = is_ippatsu
                self.is_rinshan = is_rinshan
                self.is_chankan = is_chankan
                self.is_haitei = is_haitei
                self.is_houtei = is_houtei
                self.is_daburu_riichi = is_daburu_riichi
                self.is_nagashi_mangan = is_nagashi_mangan
                self.is_tenhou = is_tenhou
                self.is_renhou = is_renhou
                self.is_chiihou = is_chiihou

                self.player_wind = player_wind
                self.round_wind = round_wind
                self.is_dealer = player_wind == g.EAST
            end
        }
    )
    c:__init__()
    return c
end
--HandResponse

g.HandResponse = function(cost, han, fu, yaku, error, fu_details)
    local self = {
        cost = nil,
        han = nil,
        fu = nil,
        fu_details = nil,
        yaku = nil,
        error = nil,
        str__ = function(self)
                if self.error then
                    return self.error
                else
                    return string.format('%d han, %d fu', self.han, self.fu)
                end
            end
    }
    self.cost = cost
    self.han = han
    self.fu = fu
    self.error = error

    if fu_details then
        self.fu_details =
            itertools.sorted(
            fu_details,
            function(x,y)
                return x['fu']<x['fu']
            end,
            true
        )
    end

    if yaku then
        self.yaku =
            itertools.sorted(
            yaku,
            function(x,y)
                return x.yaku_id<y.yaku_id
            end
        )
    end
    return self
end

--scores
g.ScoresCalculator = {
    calculate_scores = function(self, han, fu, config, is_yakuman)
        --[[
        Calculate how much scores cost a hand with given han and fu
        :param han: int
        :param fu: int
        :param config: HandConfig object
        :param is_yakuman: boolean
        :return: a dictionary with main and additional cost
        for ron additional cost is always = 0
        for tsumo main cost is cost for dealer and additional is cost for player
        {'main': 1000, 'additional': 0}
        ]]
        -- kazoe hand
        if han >= 13 and not is_yakuman then
            -- Hands over 26+ han don't count as double yakuman
            if config.options.kazoe_limit == g.HandConfig.KAZOE_LIMITED then
                -- Hands over 13+ is a sanbaiman
                han = 13
            elseif config.options.kazoe_limit == g.HandConfig.KAZOE_SANBAIMAN then
                han = 12
            end
        end
        local base_points
        local rounded
        local double_rounded
        local four_rounded
        local six_rounded

        if han >= 5 then
            local rounded
            if han >= 78 then
                rounded = 48000
            elseif han >= 65 then
                rounded = 40000
            elseif han >= 52 then
                rounded = 32000
            elseif han >= 39 then
                -- double yakuman
                rounded = 24000
            elseif han >= 26 then
                -- yakuman
                rounded = 16000
            elseif han >= 13 then
                -- sanbaiman
                rounded = 8000
            elseif han >= 11 then
                -- baiman
                rounded = 6000
            elseif han >= 8 then
                -- haneman
                rounded = 4000
            elseif han >= 6 then
                rounded = 3000
            else
                rounded = 2000
            end
            double_rounded = rounded * 2
            four_rounded = double_rounded * 2
            six_rounded = double_rounded * 3
        else
            base_points = fu * (2^ (2 + han))
            rounded = math.floor((base_points + 99) / 100) * 100
            double_rounded = math.floor((2 * base_points + 99) / 100) * 100
            four_rounded = math.floor((4 * base_points + 99) / 100) * 100
            six_rounded = math.floor((6 * base_points + 99) / 100) * 100

            local is_kiriage = false
            if config.options.kiriage then
                if han == 4 and fu == 30 then
                    is_kiriage = true
                end
                if han == 3 and fu == 60 then
                    is_kiriage = true
                end
            end

            -- mangan
            if rounded > 2000 or is_kiriage then
                rounded = 2000
                double_rounded = rounded * 2
                four_rounded = double_rounded * 2
                six_rounded = double_rounded * 3
            end
        end
        if config.is_tsumo then
            --return {['main']= double_rounded, ['additional']= config.is_dealer and double_rounded or rounded}
            if config.is_dealer then
                return {['main'] = double_rounded, ['additional'] = double_rounded}
            else
                return {['main'] = double_rounded, ['additional'] = rounded}
            end
        else
            if config.is_dealer then
                return {['main'] = six_rounded, ['additional'] = 0}
            else
                return {['main'] = four_rounded, ['additional'] = 0}
            end
        end
    end
}

g.Yaku = function(id)
    local self = {
        yaku_id = nil,
        tenhou_id = nil,
        name = nil,
        han_open = nil,
        han_closed = nil,
        is_yakuman = nil,
        english = nil,
        japanese = nil,
        __str__ = function(self)
            return self.name
        end,
        __repr__ = function(self)
            -- for calls in array
            return self:__str__()
        end,
        __init__ = function(self, yaku_id)
            self.tenhou_id = nil
            self.yaku_id = yaku_id

            self:set_attributes()
        end,
        is_condition_met = function(self, hand, args)
            --[[
            Is this yaku exists in the hand?
            :param: hand
            :param: args: some yaku requires additional attributes
            :return: boolean
            ]]
            error('NotImplementedError')
        end,
        set_attributes = function(self)
            --[[
            Set id, name, han related to the yaku
            ]]
            error('NotImplementedError')
        end
    }
    
    return self
end
g.Count = function(init)
    return {
        v = init,
        next = function(self)
            local c = self.v
            self.v = self.v + 1
            return self.v
        end
    }
end
g.YakuConfig = function()
    local self = {
        __init__ = function(self)
            local id = g.Count(0)

            -- Yaku situations
            self.tsumo = g.Tsumo(id:next())
            self.riichi = g.Riichi(id:next())
            self.ippatsu = g.Ippatsu(id:next())
            self.chankan = g.Chankan(id:next())
            self.rinshan = g.Rinshan(id:next())
            self.haitei = g.Haitei(id:next())
            self.houtei = g.Houtei(id:next())
            self.daburu_riichi = g.DaburuRiichi(id:next())
            self.nagashi_mangan = g.NagashiMangan(id:next())
            self.renhou = g.Renhou(id:next())

            -- Yaku 1 Hands
            self.pinfu = g.Pinfu(id:next())
            self.tanyao = g.Tanyao(id:next())
            self.iipeiko = g.Iipeiko(id:next())
            self.haku = g.Haku(id:next())
            self.hatsu = g.Hatsu(id:next())
            self.chun = g.Chun(id:next())

            self.east = g.YakuhaiEast(id:next())
            self.south = g.YakuhaiSouth(id:next())
            self.west = g.YakuhaiWest(id:next())
            self.north = g.YakuhaiNorth(id:next())
            self.yakuhai_place = g.YakuhaiOfPlace(id:next())
            self.yakuhai_round = g.YakuhaiOfRound(id:next())

            -- Yaku 2 Hands
            self.sanshoku = g.Sanshoku(id:next())
            self.ittsu = g.Ittsu(id:next())
            self.chanta = g.Chanta(id:next())
            self.honroto = g.Honroto(id:next())
            self.toitoi = g.Toitoi(id:next())
            self.sanankou = g.Sanankou(id:next())
            self.sankantsu = g.SanKantsu(id:next())
            self.sanshoku_douko = g.SanshokuDoukou(id:next())
            self.chiitoitsu = g.Chiitoitsu(id:next())
            self.shosangen = g.Shosangen(id:next())

            -- Yaku 3 Hands
            self.honitsu = g.Honitsu(id:next())
            self.junchan = g.Junchan(id:next())
            self.ryanpeiko = g.Ryanpeikou(id:next())

            -- Yaku 6 Hands
            self.chinitsu = g.Chinitsu(id:next())

            -- Yakuman list
            self.kokushi = g.KokushiMusou(id:next())
            self.chuuren_poutou = g.ChuurenPoutou(id:next())
            self.suuankou = g.Suuankou(id:next())
            self.daisangen = g.Daisangen(id:next())
            self.shosuushi = g.Shousuushii(id:next())
            self.ryuisou = g.Ryuuiisou(id:next())
            self.suukantsu = g.Suukantsu(id:next())
            self.tsuisou = g.Tsuuiisou(id:next())
            self.chinroto = g.Chinroutou(id:next())
            self.daisharin = g.Daisharin(id:next())

            --Double yakuman
            self.daisuushi = g.DaiSuushii(id:next())
            self.daburu_kokushi = g.DaburuKokushiMusou(id:next())
            self.suuankou_tanki = g.SuuankouTanki(id:next())
            self.daburu_chuuren_poutou = g.DaburuChuurenPoutou(id:next())

            --Yakuman situations
            self.tenhou = g.Tenhou(id:next())
            self.chiihou = g.Chiihou(id:next())
            self.renhou_yakuman = g.RenhouYakuman(id:next())

            -- Other
            self.dora = g.Dora(id:next())
            self.aka_dora = g.AkaDora(id:next())
            return self
        end
    }

    self:__init__()
    return self
end

--Yaku s
local function yakuinherit(attribstr, condstr, condparams, strstr)
    
    return function(id)

        local c = g.Yaku(id)
        local env = {
            g=g,
            len=len,   
            ipairs=ipairs,
            simplifyindices=simplifyindices,
            flatten=flatten,
            picker=picker,
            any=any,
            cat=cat,
            isin=isin,
            deepcopy=deepcopy,
            all=all,
            table=table,
            math=math,
            arrayequal=arrayequal,
        }
        

        --print(attribstr)
        condparams = condparams or '(self,hand,args)'
        c.set_attributes = assert(load('return function(self) ' .. attribstr .. ' end', nil, nil, env))()
        c.is_condition_met = assert(load('return function' .. condparams:gsub('%*', '') .. ' ' .. condstr .. ' end', nil, nil, env))()
        c.__str__ = assert(load('return function(self) ' .. (strstr or "") .. ' end', nil, nil, env))()
        c:__init__(id)
        return c    
    end
end

g.Chiihou =
    yakuinherit(
    [[

    self.tenhou_id = 38
    self.name = 'Chiihou'
    self.english = 'Earthly Hand'
    self.japanese = '地和'

    self.han_open = None
    self.han_closed = 13

    self.is_yakuman = true]],
    [[return true]]
)
g.Chinroutou =
    yakuinherit(
    [[
    self.tenhou_id = 44

    self.name = 'Chinroutou'
    self.english = 'All Terminals'
    self.japanese = '清老頭'

    self.han_open = 13
    self.han_closed = 13

    self.is_yakuman = true
]],
    [[ 
    indices = flatten(hand)
    return all(picker(indices,nil,nil,function(x) return isin(g.TERMINAL_INDICES,x) end)) ]]
)
g.ChuurenPoutou =
    yakuinherit(
    [[
self.tenhou_id = 45

self.name = 'Chuuren Poutou'
self.english = 'Nine Gates'
self.japanese = '九蓮宝燈'

self.han_open = None
self.han_closed = 13

self.is_yakuman = true]],
    [[
    local sou_sets = 0
    local pin_sets = 0
    local man_sets = 0
    local honor_sets = 0
    for _,item in ipairs(hand) do
        if g.utils.is_sou(item[0+1]) then
            sou_sets = sou_sets+1
        elseif is_pin(item[0+1]) then
            pin_sets = pin_sets+1
        elseif is_man(item[0+1]) then
            man_sets = man_sets+1
        else
            honor_sets = honor_sets+1
        end
    end
    sets = {sou_sets, pin_sets, man_sets}
    only_one_suit = #picker(sets,function(x) return x~=0 end ) == 1
    if not only_one_suit or honor_sets > 0 then
        return false
    end
    local indices = flatten(hand)
    -- cast tile indices to 0..8 representation
    indices = picker(indices,nil,nil,function(x) return g.utils.simplify(x)end)

    -- 1-1-1
    if  #picker(indices,function(x) return x==0 end )  < 3 then
        return alse
    end
    -- 9-9-9
    if #picker(indices,function(x) return x==8 end ) < 3 then
        return False
    end
    -- 1-2-3-4-5-6-7-8-9 and one tile to any of them
    tableremove(indices,0)
    tableremove(indices,0)
    tableremove(indices,8)
    tableremove(indices,8)
    
    for x=0,8 do
        if isin(indices,x) then
             tableremove(indices,x)
        end
    end
    if #indices == 1 then
        return true
    end
    return False]]
)

g.DaburuChuurenPoutou =
    yakuinherit(
    [[self.tenhou_id = 46

self.name = 'Daburu Chuuren Poutou'
self.english = 'Pure Nine Gates'
self.japanese = '純正九蓮宝燈'

self.han_open = None
self.han_closed = 26

self.is_yakuman = true]],
    [[ 
    -- was it here or not is controlling by superior code
return true]]
)

g.DaburuKokushiMusou =
    yakuinherit(
    [[
    self.tenhou_id = 48

    self.name = 'Kokushi Musou Juusanmen Matchi'
    self.english = 'Thirteen Orphans 13-way wait'
    self.japanese = '国士無双十三面待ち'

    self.han_open = None
    self.han_closed = 26

    self.is_yakuman = true
]],
    [[-- was it here or not is controlling by superior code
return true]]
)
g.Daisangen =
    yakuinherit(
    [[
    self.tenhou_id = 39

    self.name = 'Daisangen'
    self.english = 'Big Three Dragons'
    self.japanese = '大三元'

    self.han_open = 13
    self.han_closed = 13

    self.is_yakuman = true

]],
    [[
    local count_of_dragon_pon_sets = 0
    for _,item in ipairs(hand) do
        if g.utils.is_pon(item) and isin( {g.CHUN, g.HAKU, g.HATSU},item[0]) then
            count_of_dragon_pon_sets = count_of_dragon_pon_sets+1
        end
    end
    return count_of_dragon_pon_sets == 3
]]
)

g.Daisharin = function(id)
    local self =
        yakuinherit(
        [[self.name = 'Daisharin'
    self.english = 'Big wheels'
    self.japanese = '大車輪'
    self.han_open = None
    self.han_closed = 13

    self.is_yakuman = true
    ]],
        [[
        local sou_sets = 0
        local pin_sets = 0
        local  man_sets = 0
        local  honor_sets = 0
    for _,item in ipairs(hand) do
        if g.utils.is_sou(item[0+1]) then
            sou_sets = sou_sets+1
        elseif  g.utils.is_pin(item[0+1])then
            pin_sets = pin_sets+1
        elseif  g.utils.is_man(item[0+1])then
            man_sets = man_sets+1
        else
            honor_sets = honor_sets+1
        end
    end
    local sets = {sou_sets, pin_sets, man_sets}
    local only_one_suit = #picker(sets,function(x)return x~=0 end) == 1
    if not only_one_suit or honor_sets > 0 then
        return false
    end

    if not allow_other_sets and pin_sets == 0 then
        -- if we are not allowing other sets than pins
        return false
    end

    local indices = flatten(hand) 
    -- cast tile indices to 0..8 representation
    indices = simplifyindices(indices)

    -- check for pairs
    for x=1,7  do
        if #picker(indices,function(y)return x==y end) ~= 2 then
            return false
        end

    end

    return true]],
        [[(self, hand, allow_other_sets, *args)]]
    )(id)
    self.set_pin = function(me)
        me.name = 'Daisharin'
        me.english = 'Big wheels'
        me.japanese = '大車輪'
    end
    self.set_sou = function(me)
        me.name = 'Daisuurin'
        me.english = 'Bamboo forest'
        me.japanese = '大竹林'
    end
    self.set_man = function(me)
        me.name = 'Daichikurin'
        me.english = 'Numerous numbers'
        me.japanese = '大数隣'
    end
    self.rename = function(me, hand)
        -- rename this yakuman depending on tiles used
        if g.utils.is_sou(hand[0 + 1][0 + 1]) then
            me.set_sou()
        elseif g.utils.is_pin(hand[0 + 1][0 + 1]) then
            me.set_pin()
        else
            me.set_man()
        end
    end

    return self
end


g.DaiSuushii =
    yakuinherit(
    [[
    self.tenhou_id = 49

    self.name = 'Dai Suushii'
    self.english = 'Big Four Winds'
    self.japanese = '大四喜'

    self.han_open = 26
    self.han_closed = 26

    self.is_yakuman = true
]],
    [[
    
    local pon_sets = picker(hand,g.utils.is_pon)
    if #pon_sets ~= 4 then
        return false
    end


    local count_wind_sets = 0
    local winds = {g.EAST, g.SOUTH, g.WEST, g.NORTH}
    for _,item in ipairs(pon_sets) do
        if g.utils.is_pon(item) and isin(winds,item[0+1]) then
            count_wind_sets = count_wind_sets+1
        end
    end
    return count_wind_sets == 4
]]
)

g.KokushiMusou =
    yakuinherit(
    [[self.tenhou_id = 47

    self.name = 'Kokushi Musou'
    self.english = 'Thirteen Orphans'
    self.japanese = '国士無双'

    self.han_open = None
    self.han_closed = 13

    self.is_yakuman = true]],
    [[
        if (tiles_34[0+1] * tiles_34[8+1] * tiles_34[9+1] * tiles_34[17+1] * tiles_34[18+1] *
        tiles_34[26+1] * tiles_34[27+1] * tiles_34[28+1] * tiles_34[29+1] * tiles_34[30+1] *
        tiles_34[31+1] * tiles_34[32+1] * tiles_34[33+1] == 2) then
            return true
        end

        return false

    ]],
    [[(self, hand, tiles_34, *args)]]
)

g.RenhouYakuman =
    yakuinherit(
    [[self.name = 'Renhou'
    self.english = 'Hand Of Man'
    self.japanese = '人和'

    self.han_open = None
    self.han_closed = 13

    self.is_yakuman = true]],
    [[return true]]
)
g.Ryuuiisou =
    yakuinherit(
    [[self.tenhou_id = 43

    self.name = 'Ryuuiisou'
    self.english = 'All Green'
    self.japanese = '緑一色'

    self.han_open = 13
    self.han_closed = 13

    self.is_yakuman = true]],
    [[ local green_indices = {19, 20, 21, 23, 25, g.HATSU}
    local indices = flatten(hand)
    return all(indices,function(x) return isin(green_indices,x) end)]]
)

g.Shousuushii =
    yakuinherit(
    [[ self.tenhou_id = 50

    self.name = 'Shousuushii'
    self.english = 'Small Four Winds'
    self.japanese = '小四喜'

    self.han_open = 13
    self.han_closed = 13

    self.is_yakuman = True]],
    [[
        local pon_sets = picker(hand,g.utils.is_pon)
    if #pon_sets < 3 then
        return false
    end
    local count_of_wind_sets = 0
    local wind_pair = 0
    local winds = {g.EAST, g.SOUTH, g.WEST, g.NORTH}
    for _,item in ipairs(hand) do
        if g.utils.is_pon(item) and isin(winds,item[0+1]) then
            count_of_wind_sets = count_of_wind_sets+1
        end
        if g.utils.is_pair(item) and isin(winds,item[0+1]) then
            wind_pair = wind_pair+1
        end
    end
    return count_of_wind_sets == 3 and wind_pair == 1]]
)
g.Suuankou =
    yakuinherit(
    [[  self.tenhou_id = 41

    self.name = 'Suu ankou'
    self.english = 'Four Concealed Triplets'
    self.japanese = '四暗刻'

    self.han_open = true
    self.han_closed = 13

    self.is_yakuman = True]],
    [[
        win_tile = math.floor(win_tile/4)
        local closed_hand = {}
        for _,item in ipairs(hand) do
            -- if we do the ron on syanpon wait our pon will be consider as open
            if g.utils.is_pon(item) and isin(item,win_tile) and not is_tsumo then
            else
               table.insert(closed_hand,item) 
            
            end
        end
    local count_of_pon = #picker(closed_hand,g.utils.is_pon)
    return count_of_pon == 4]],
    [[(self, hand, win_tile, is_tsumo)]]
)
g.SuuankouTanki =
    yakuinherit(
    [[self.tenhou_id = 40

    self.name = 'Suu ankou tanki'
    self.english = 'Four Concealed Triplets Single Wait'
    self.japanese = '四暗刻単騎待ち'

    self.han_open = None
    self.han_closed = 26

    self.is_yakuman = true]],
    [[return true]]
)
g.Suukantsu =
    yakuinherit(
    [[self.tenhou_id = 51

    self.name = 'Suu kantsu'
    self.english = 'Four Kans'
    self.japanese = '四槓子'

    self.han_open = 13
    self.han_closed = 13

    self.is_yakuman = True]],
    [[ 
        kan_sets = picker(melds,function(x) return x.type == g.Meld.KAN or x.type == g.Meld.CHANKAN end)
    return #kan_sets == 4]],
    [[(self, hand, melds, *args)]]
)

g.Tenhou =
    yakuinherit(
    [[self.tenhou_id = 37

    self.name = 'Tenhou'
    self.english = 'Heavenly Hand'
    self.japanese = '天和'

    self.han_open = None
    self.han_closed = 13

    self.is_yakuman = True]],
    [[return true]]
)

g.Tsuuiisou =
    yakuinherit(
    [[self.tenhou_id = 42

    self.name = 'Tsuu iisou'
    self.english = 'All Honors'
    self.japanese = '字一色'

    self.han_open = 13
    self.han_closed = 13

    self.is_yakuman = True]],
    [[ 
    local indices = flatten(hand)
    local p=picker(indices,nil,nil,function(x) return isin( g.HONOR_INDICES,x) end)
    return all(p)]]
)
g.AkaDora =
    yakuinherit(
    [[ self.tenhou_id = 54

    self.name = 'Aka Dora'
    self.english = 'Red Five'
    self.japanese = '赤ドラ'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False]],
    [[return true]],
    nil,
    [[string.format('Aka Dora %d',(self.han_closed))]]
)
g.Chankan =
    yakuinherit(
    [[self.tenhou_id = 3

    self.name = 'Chankan'
    self.english = 'Robbing A Kan'
    self.japanese = '搶槓'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False]],
    [[return true]]
)

g.Chanta =
    yakuinherit(
    [[self.tenhou_id = 23

    self.name = 'Chanta'
    self.english = 'Terminal Or Honor In Each Group'
    self.japanese = '混全帯么九'

    self.han_open = 1
    self.han_closed = 2

    self.is_yakuman = False]],
    [[ 
        local function tile_in_indices(item_set, indices_array)
            for _,x in ipairs(item_set) do
                if isin(indices_array,x) then
                    return True
                end
            end
            return False
        end

        local honor_sets = 0
        local terminal_sets = 0
        local count_of_chi = 0
        for _,item in ipairs(hand) do
            if g.utils.is_chi(item) then
                count_of_chi = count_of_chi+1
            end
            if tile_in_indices(item, g.TERMINAL_INDICES) then
                terminal_sets = terminal_sets+1
            end
            if tile_in_indices(item, g.HONOR_INDICES) then
                honor_sets = honor_sets+1
            end
            if count_of_chi == 0 then
                return False
            end
        end

        return terminal_sets + honor_sets == 5 and terminal_sets ~= 0 and honor_sets ~= 0

]]
)

g.Chiitoitsu =
    yakuinherit(
    [[
    self.tenhou_id = 22

    self.name = 'Chiitoitsu'
    self.english = 'Seven Pairs'
    self.japanese = '七対子'

    self.han_open = None
    self.han_closed = 2

    self.is_yakuman = False

]],
    [[
    return len(hand) == 7
]]
)

g.Chinitsu =
    yakuinherit(
    [[
    self.tenhou_id = 35

    self.name = 'Chinitsu'
    self.english = 'Flush'
    self.japanese = '清一色'

    self.han_open = 5
    self.han_closed = 6

    self.is_yakuman = False
]],
    [[
    local honor_sets = 0
    local sou_sets = 0
    local pin_sets = 0
    local man_sets = 0
    for _,item in ipairs(hand) do
        if isin(g.HONOR_INDICES,item[0+1] ) then
            honor_sets = honor_sets+1
        end

        if g.utils.is_sou(item[0+1]) then
            sou_sets =sou_sets+ 1
        
        elseif g.utils.is_pin(item[0+1]) then
            pin_sets = pin_sets+1
        
        elseif g.utils.is_man(item[0+1]) then
            man_sets = man_sets+1
        end
    end
    local sets = {sou_sets, pin_sets, man_sets}
    local only_one_suit = len(picker(sets,function(x)return x~=0 end)) == 1

    return only_one_suit and honor_sets == 0
]]
)
g.Chun =
    yakuinherit(
    [[self.tenhou_id = 20

    self.name = 'Yakuhai (chun)'
    self.english = 'Red Dragon'
    self.japanese = '役牌(中)'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False
]],
    [[
    return len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == g.CHUN end)) == 1
]]
)
g.DaburuRiichi =
    yakuinherit(
    [[self.tenhou_id = 21

    self.name = 'Double Riichi'
    self.english = 'Double Riichi'
    self.japanese = 'ダブル立直'

    self.han_open = None
    self.han_closed = 2

    self.is_yakuman = False]],
    [[return true]]
)

g.Dora =
    yakuinherit(
    [[self.tenhou_id = 52

    self.name = 'Dora'
    self.english = 'Dora'
    self.japanese = 'ドラ'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False
]],
    [[
    return true
]],
    nil,
    [[string.format('Dora %d',(self.han_closed))]]
)
g.YakuhaiEast =
    yakuinherit(
    [[
    self.tenhou_id = 10

    self.name = 'Yakuhai (east)'
    self.english = 'East Round/Seat'
    self.japanese = '役牌(東)'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False
]],
    [[
    if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == player_wind end)) == 1 and player_wind == g.EAST then
    return True
    end

if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == round_wind end)) == 1 and round_wind == g.EAST then
    return True
end
return False
]],
    [[(self, hand, player_wind, round_wind, *args)]]
)

g.Haitei =
    yakuinherit(
    [[
        self.tenhou_id = 5

        self.name = 'Haitei Raoyue'
        self.english = 'Win By Last Draw'
        self.japanese = '海底摸月'

        self.han_open = 1
        self.han_closed = 1

        self.is_yakuman = False
    ]],
    [[return true]]
)
g.Haku =
    yakuinherit(
    [[self.tenhou_id = 18

    self.name = 'Yakuhai (haku)'
    self.english = 'White Dragon'
    self.japanese = '役牌(白)'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False

]],
    [[
    return len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == g.HAKU end)) == 1
]]
)
g.Hatsu =
    yakuinherit(
    [[self.tenhou_id = 19

    self.name = 'Yakuhai (hatsu)'
    self.english = 'Green Dragon'
    self.japanese = '役牌(發)'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False

]],
    [[
    return len(picker(hand,function(x) return g.utils.is_pon(x) and  x[0+1] == g.HATSU end)) == 1
]]
)
g.Honitsu =
    yakuinherit(
    [[
        self.tenhou_id = 34
        self.name = 'Honitsu'
        self.english = 'Half Flush'
        self.japanese = '混一色'

        self.han_open = 2
        self.han_closed = 3

        self.is_yakuman = False
    ]],
    [[
        local honor_sets = 0
        local sou_sets = 0
        local pin_sets = 0
        local man_sets = 0
        for _,item in ipairs(hand) do
            if isin(g.HONOR_INDICES,item[0+1]) then
                honor_sets = honor_sets+1
            end

            if g.utils.is_sou(item[0+1]) then
                sou_sets = sou_sets+1
            elseif g.utils.is_pin(item[0+1]) then
                pin_sets =pin_sets+ 1
            elseif g.utils.is_man(item[0+1]) then
                man_sets = man_sets+1
            end
        end
        local sets = {sou_sets, pin_sets, man_sets}
        local only_one_suit = len( picker(sets,function(x) return x~=0 end)) == 1

        return only_one_suit and honor_sets ~= 0
    ]]
)
g.Honroto =
    yakuinherit(
    [[ self.tenhou_id = 31

    self.name = 'Honroutou'
    self.english = 'Terminals and Honors'
    self.japanese = '混老頭'

    self.han_open = 2
    self.han_closed = 2

    self.is_yakuman = False]],
    [[
        local indices = flatten(hand)
        local tbl=deepcopy(g.HONOR_INDICES)
        tbl=cat(tbl,g.TERMINAL_INDICES)
        local result = tbl
        return all(picker(result,nil,nil,function(x) return isin(indices,x)end))
    ]]
)
g.Houtei =
    yakuinherit(
    [[
        self.tenhou_id = 6

        self.name = 'Houtei Raoyui'
        self.english = 'Win by last discard'
        self.japanese = '河底撈魚'

        self.han_open = 1
        self.han_closed = 1

        self.is_yakuman = False  
    ]],
    [[
        return true
    ]]
)
g.Iipeiko =
    yakuinherit(
    [[
        self.tenhou_id = 9

        self.name = 'Iipeiko'
        self.english = 'Identical Sequences'
        self.japanese = '一盃口'

        self.han_open = None
        self.han_closed = 1

        self.is_yakuman = False
    ]],
    [[
        local chi_sets = picker(hand,function(x) return g.utils.is_chi(x) end)

        local count_of_identical_chi = 0
        for _,x in ipairs(chi_sets) do
            local count = 0
            for _,y in ipairs(chi_sets) do
                if arrayequal(x, y) then
                    count =count+ 1
                end
            end
            if count > count_of_identical_chi then
                count_of_identical_chi = count
            end
        end
        return count_of_identical_chi >= 2
    ]]
)
g.Ippatsu =
    yakuinherit(
    [[
        self.tenhou_id = 2

        self.name = 'Ippatsu'
        self.english = 'One Shot'
        self.japanese = '一発'

        self.han_open = None
        self.han_closed = 1

        self.is_yakuman = False
    ]],
    [[return true]]
)
g.Ittsu =
    yakuinherit(
    [[self.tenhou_id = 24

    self.name = 'Ittsu'
    self.english = 'Straight'
    self.japanese = '一気通貫'

    self.han_open = 1
    self.han_closed = 2

    self.is_yakuman = False]],
    [[
        local chi_sets = picker(hand,function (i) return g.utils.is_chi(i) end)
        if len(chi_sets) < 3 then
            return False
        end

        local sou_chi = {}
        local pin_chi = {}
        local man_chi = {}
        for _,item in ipairs(chi_sets) do
            if g.utils.is_sou(item[0+1])then
                table.insert(sou_chi,item)
                
            elseif g.utils.is_pin(item[0+1]) then
               
                table.insert(pin_chi,item)
                
            elseif g.utils.is_man(item[0+1])then
      
                table.insert(man_chi,item)
            end          
        
        end
        local sets = {sou_chi, pin_chi, man_chi}

        for _,suit_item in ipairs(sets) do
            if len(suit_item) < 3 then
                --continue
            else

                local casted_sets = {}

                for _,set_item in ipairs(suit_item) do
                    -- cast tiles indices to 0..8 representation
                    table.insert(casted_sets,
                    {g.utils.simplify(set_item[0+1]),
                    g.utils.simplify(set_item[1+1]),
                    g.utils.simplify(set_item[2+1])})
      
                end
                if isin(casted_sets,{0, 1, 2}) and isin(casted_sets,{3, 4, 5}) and  isin(casted_sets,{6, 7, 8}) then
                    return True
                end
            end
        end
        return False
    ]]
)

g.Junchan =
    yakuinherit(
    [[  self.tenhou_id = 33

    self.name = 'Junchan'
    self.english = 'Terminal In Each Meld'
    self.japanese = '純全帯么九'

    self.han_open = 2
    self.han_closed = 3

    self.is_yakuman = False]],
    [[
        local function tile_in_indices(item_set, indices_array)
            for _,x in ipairs(item_set) do
                if isin(indices_array,x) then
                    return True
                end

            end
            return False
        end

    local terminal_sets = 0
    local count_of_chi = 0
    for _,item in ipairs(hand) do
        if g.utils.is_chi(item) then
            count_of_chi =count_of_chi+ 1
        end
        if tile_in_indices(item, g.TERMINAL_INDICES) then
            terminal_sets = terminal_sets+1
        end
    end
    if count_of_chi == 0 then
        return False
    end
    return terminal_sets == 5]]
)

g.NagashiMangan =
    yakuinherit(
    [[self.name = 'Nagashi Mangan'
    self.english = 'Nagashi Mangan'
    self.japanese = '流し満貫'

    self.han_open = 5
    self.han_closed = 5

    self.is_yakuman = False]],
    [[return true]]
)

g.YakuhaiNorth =
    yakuinherit(
    [[
        self.tenhou_id = 10

        self.name = 'Yakuhai (north)'
        self.english = 'North Round/Seat'
        self.japanese = '役牌(北)'

        self.han_open = 1
        self.han_closed = 1

        self.is_yakuman = False
]],
    [[
    if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == player_wind end)) == 1 and player_wind == g.NORTH then
    return True
    end
    if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == round_wind end)) == 1 and round_wind == g.NORTH then
        return True
    end

    return False
]],
    [[(self, hand, player_wind, round_wind, *args)]]
)

g.Pinfu =
    yakuinherit(
    [[self.tenhou_id = 7

    self.name = 'Pinfu'
    self.english = 'All Sequences'
    self.japanese = '平和'

    self.han_open = None
    self.han_closed = 1

    self.is_yakuman = False]],
    [[return true]]
)
g.Renhou =
    yakuinherit(
    [[
        self.tenhou_id = 36

        self.name = 'Renhou'
        self.english = 'Hand Of Man'
        self.japanese = '人和'

        self.han_open = None
        self.han_closed = 5

        self.is_yakuman = False
    ]],
    [[return true]]
)
g.Riichi =
    yakuinherit(
    [[self.tenhou_id = 1

    self.name = 'Riichi'
    self.english = 'Riichi'
    self.japanese = '立直'

    self.han_open = None
    self.han_closed = 1

    self.is_yakuman = False]],
    [[return true]]
)
g.Rinshan =
    yakuinherit(
    [[
        self.tenhou_id = 4

        self.name = 'Rinshan Kaihou'
        self.english = 'Dead Wall Draw'
        self.japanese = '嶺上開花'

        self.han_open = 1
        self.han_closed = 1

        self.is_yakuman = False
    ]],
    [[return true]]
)

g.Ryanpeikou =
    yakuinherit(
    [[self.tenhou_id = 32

    self.name = 'Ryanpeikou'
    self.english = 'Two Sets Of Identical Sequences'
    self.japanese = '二盃口'

    self.han_open = None
    self.han_closed = 3

    self.is_yakuman = False]],
    [[
        local chi_sets = picker(hand,function(i) return g.utils.is_chi(i)end)
        local count_of_identical_chi = {}
        for _,x in ipairs(chi_sets) do
            local count = 0
            for _,y in ipairs(chi_sets) do
                if arrayequal(x ,y) then
                    count = count+1
                end
            end
            table.insert(count_of_identical_chi,count)
           
        end
        return len(
            picker(count_of_identical_chi,function(x) return x>=2 end)    
        ) == 4
    ]]
)
g.Sanankou =
    yakuinherit(
    [[self.tenhou_id = 29

    self.name = 'San Ankou'
    self.english = 'Tripple Concealed Triplets'
    self.japanese = '三暗刻'

    self.han_open = 2
    self.han_closed = 2

    self.is_yakuman = False]],
    [[ 
        win_tile = math.floor(win_tile / 4)

    local  open_sets = picker(melds,function(x) return x.opened end,nil,function(x) return x.tiles_34 end) 

    local chi_sets = picker(hand,function(x) return (g.utils.is_chi(x) and isin(x,win_tile) and not isin(open_sets,x)) end)
    local pon_sets = picker(hand,g.utils.is_pon)

    local closed_pon_sets = {}
    for _,item in ipairs(pon_sets) do
        if isin(open_sets,item) then
            -- continue
        else
            -- if we do the ron on syanpon wait our pon will be consider as open
            -- and it is not 789999 set
            if isin(item,win_tile) and not is_tsumo and len(chi_sets)>0 then
                -- continue
            else
                table.insert(closed_pon_sets,item)

            end
        end
    end
    return len(closed_pon_sets) == 3]],
    [[(self, hand, win_tile, melds, is_tsumo)]]
)
g.SanKantsu =
    yakuinherit(
    [[ self.tenhou_id = 27

    self.name = 'San Kantsu'
    self.english = 'Three Kans'
    self.japanese = '三槓子'

    self.han_open = 2
    self.han_closed = 2

    self.is_yakuman = False]],
    [[ 
        kan_sets = picker(melds,function(x)return x.type == g.Meld.KAN or x.type == g.Meld.CHANKAN end)
        return len(kan_sets) == 3
    ]],
    [[(self, hand, melds, *args)]]
)

g.Sanshoku =
    yakuinherit(
    [[
        self.tenhou_id = 25

        self.name = 'Sanshoku Doujun'
        self.english = 'Three Colored Triplets'
        self.japanese = '三色同順'

        self.han_open = 1
        self.han_closed = 2

        self.is_yakuman = False
    ]],
    [[
        local chi_sets = picker(hand,function(i) return g.utils.is_chi(i) end)
        if len(chi_sets) < 3 then
            return False
        end
        local sou_chi = {}
        local pin_chi = {}
        local man_chi = {}
        for _,item in ipairs(chi_sets) do
            if g.utils.is_sou(item[0+1]) then
                table.insert(sou_chi,item)

             elseif g.utils.is_pin(item[0+1]) then
                table.insert(pin_chi,item)
             
            elseif g.utils.is_man(item[0+1]) then
                table.insert(man_chi,item)
             
            end
        end
        for _,sou_item in ipairs(sou_chi) do
            for _,pin_item in  ipairs(pin_chi) do
                for _,man_item in  ipairs(man_chi) do
                    -- cast tile indices to 0..8 representation
                    sou_item =  picker(sou_item,nil,nil,function(x) return g.utils.simplify(x) end)
                    pin_item =  picker(pin_item,nil,nil,function(x) return g.utils.simplify(x) end)
                    man_item =  picker(man_item,nil,nil,function(x) return g.utils.simplify(x) end)
                    if sou_item == pin_item and pin_item == man_item then
                        return True
                    end
                end

            end
        end
        return False
    ]]
)
g.SanshokuDoukou =
    yakuinherit(
    [[self.tenhou_id = 26

    self.name = 'Sanshoku Doukou'
    self.english = 'Three Colored Triplets'
    self.japanese = '三色同刻'

    self.han_open = 2
    self.han_closed = 2

    self.is_yakuman = False]],
    [[
        local pon_sets = picker(hand,function(i) return g.utils.is_pon(i) end)
        if len(pon_sets) < 3 then
            return False
        end
        local sou_pon = {}
        local pin_pon = {}
        local man_pon = {}
        for _,item in ipairs(pon_sets) do
            if g.utils.is_sou(item[0+1]) then
                table.insert(sou_pon,item)

             elseif g.utils.is_pin(item[0+1]) then
                table.insert(pin_pon,item)
             
            elseif g.utils.is_man(item[0+1]) then
                table.insert(man_pon,item)
             
            end
        end
        for _,sou_item in ipairs(sou_pon) do
            for _,pin_item in  ipairs(pin_pon) do
                for _,man_item in  ipairs(man_pon) do
                    -- cast tile indices to 0..8 representation
                    sou_item =  picker(sou_item,nil,nil,function(x) return g.utils.simplify(x) end)
                    pin_item =  picker(pin_item,nil,nil,function(x) return g.utils.simplify(x) end)
                    man_item =  picker(man_item,nil,nil,function(x) return g.utils.simplify(x) end)
                    if sou_item == pin_item and pin_item == man_item then
                        return True
                    end
                end

            end
        end
        return False

    ]]
)

g.Shosangen =
    yakuinherit(
    [[self.tenhou_id = 30

    self.name = 'Shou Sangen'
    self.english = 'Small Three Dragons'
    self.japanese = '小三元'

    self.han_open = 2
    self.han_closed = 2

    self.is_yakuman = False]],
    [[
        local dragons = {g.CHUN, g.HAKU, g.HATSU}
    local count_of_conditions = 0
    for _,item in ipairs(hand) do
        -- dragon pon or pair
        if (g.utils.is_pair(item) or g.utils.is_pon(item)) and isin(dragons,item[0+1]) then
            count_of_conditions = count_of_conditions+1
        end
    end
    return count_of_conditions == 3]]
)

g.YakuhaiSouth =
    yakuinherit(
    [[self.tenhou_id = 10

    self.name = 'Yakuhai (south)'
    self.english = 'South Round/Seat'
    self.japanese = '役牌(南)'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False]],
    [[
    if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == player_wind end)) == 1 and player_wind == g.SOUTH then
    return True
    end
    if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == round_wind end)) == 1 and round_wind == g.SOUTH then
        return True
    end
    return False
    ]],
    [[(self, hand, player_wind, round_wind, *args)]]
)

g.Tanyao=yakuinherit(
    [[
        self.tenhou_id = 8

        self.name = 'Tanyao'
        self.english = 'All Simples'
        self.japanese = '断么九'

        self.han_open = 1
        self.han_closed = 1

        self.is_yakuman = False
    ]],
    [[
        local indices = flatten(hand)
        local result={}
        result=cat(result,g.TERMINAL_INDICES)
        result=cat(result,g.HONOR_INDICES)
        
        return not any(picker(indices,nil,nil,function(x) return isin(result,x) end))
    ]]
)
g.Toitoi=yakuinherit(
    [[self.tenhou_id = 28
    self.name = 'Toitoi'
    self.english = 'All Triplets'
    self.japanese = '対々和'

    self.han_open = 2
    self.han_closed = 2

    self.is_yakuman = False]],
    [[
        local count_of_pon = len(picker(hand,g.utils.is_pon))
        return count_of_pon==4
    ]]
)
g.Tsumo=yakuinherit(
    [[self.tenhou_id = 0
    self.name = 'Menzen Tsumo'
    self.english = 'Self Draw'
    self.japanese = '門前清自摸和'

    self.han_open = None
    self.han_closed = 1

    self.is_yakuman = False
]],[[return true]]
)

g.YakuhaiWest=yakuinherit(
[[self.tenhou_id = 10

self.name = 'Yakuhai (west)'
self.english = 'West Round/Seat'
self.japanese = '役牌(西)'

self.han_open = 1
self.han_closed = 1

self.is_yakuman = False
]],[[
    if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == player_wind end)) == 1 and player_wind == g.WEST then
    return True
    end
    if len(picker(hand,function(x) return g.utils.is_pon(x) and x[0+1] == round_wind end)) == 1 and round_wind == g.WEST then
        return True
    end
    return False
    ]],
    [[(self, hand, player_wind, round_wind, *args)]]
)
g.YakuhaiOfPlace=yakuinherit(
    [[ self.tenhou_id = 10

    self.name = 'Yakuhai (wind of place)'
    self.english = 'Value Tiles (Seat)'
    self.japanese = '自風'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False
]],
[[return true]]
)

g.YakuhaiOfRound=yakuinherit(
    [[ self.tenhou_id = 11

    self.name = 'Yakuhai (wind of round)'
    self.english = 'Value Tiles (Round)'
    self.japanese = '場風'

    self.han_open = 1
    self.han_closed = 1

    self.is_yakuman = False]],
    [[return true]]
)
g.Version=1
g.Hand=function()
    return {
        close={},
        tsumo=nil,
        open_melds={},
        discards={},    --鳴きを考慮した河
        discards_raw={},--鳴きを無視した河（捨て牌の一覧）
        last_discard_index=nil,
        getAllTiles=function(self)
            local tiles=deepcopy(self.close)
            tiles=cat(tiles,self:getOpenMeldsToSets())
            return tiles
        end,
        getAllTilesAs34=function(self)
            return g.TilesConverter.to_34_array(self:getAllTiles())
        end,
        getOpenMeldsToSets=function(self)
            local open_sets={}
            for _,v in ipairs(self.open_melds) do
                open_sets=cat(open_sets,v.tiles)
            end
            return open_sets
        end,
        __str__ = function(self)
            return 
            "close:"..g.TilesConverter.to_one_line_string(self.close).."\n"..
            "open:"..g.TilesConverter.to_one_line_string(flatten(picker(self.open_melds,nil,nil,function(x)return x.tiles end))).."\n"

        end
    }
end

g.Member=function(board,idx,name,initial_score,config)
    return {
        board=board,
        hand=g.Hand(),
        index=idx,
        name=name,
        score=initial_score,
        wind=g.EAST,        --暫定
        config=deepcopy(config),
        riichi_total_index=nil,

        calculateShanten=function(self)
            local sn=g.Shanten()
      
                return sn:calculate_shanten(g.TilesConverter.to_34_array(self.hand.close),self.hand.open_melds)
            
        end,
        
        isFuriten=function(self,tile)
            --振り聴条件
            --自分の河に当たり牌のいずれかがある場合
            --他家の捨て配を見逃して自ターンになるまで
            --リーチ後の見逃し
            
            --自分の河チェック
            for _,v in ipairs(self.hand.discards_raw) do
                if self:checkAgariFormation(v) then
                    --自分の河に当たり牌のいずれかがある場合
                    return true
                end
            end

            --他家の捨て牌を見逃して自ターンになるまで
            local idx=self.wind
            if idx==g.NORTH then
                idx=g.EAST
            else
                idx=idx+1
            end
            while idx~=self.board.current_active do
                if self.discards_raw[#self.discards_raw]~= nil then
                    if self:checkAgariFormation(self.discards_raw[#self.discards_raw]) then
                        return true
                    end
                end

                if idx==g.NORTH then
                    idx=g.EAST
                else
                    idx=idx+1
                end
            end

            
            --リーチ後の見逃し
            if config.is_riichi or config.is_daburu_riichi then
                for _,player in ipairs(self.board.members) do
                    for i=player.riichi_index,#player.hand.discards_raw do
                        if self:checkAgariFormation(self.discards_raw[i]) then
                            return true
                        end
                    end
                end
            end 
            return false
        end,
        --形式上がりの判定
        checkAgariFormation=function(self,win_tile)
       
            local agari= g.Agari.is_agari(
                cat(self.hand:getAllTilesAs34(),{math.floor(win_tile / 4)}),self.hand.open_melds)
            return agari
          
        end,
        --上がり判定
        checkAgari=function(self,win_tile)
            
            local agari=g.HandCalculator.estimate_hand_value(
                self.hand:getAllTiles(),win_tile,self.hand.open_melds,self.board:getDoraIndicators(),config)
            return agari
          
        end,
        --牌を切る
        doDiscard=function(self,index,riichi)
            --TODO 食い替え無効入れる
            self.hand.last_discard_index=index
            local tile=self.hand.close[index]
            table.remove(self.hand.close,index)
            --河に追加
            table.insert(self.hand.discards,tile)
            table.insert(self.hand.discards_raw,tile)
            table.insert(self.board.total_discards,tile)
            --切ったらソート
            table.sort(self.hand.close)
            --ツモ牌を消す
            self.hand.tsumo=nil
            --自ターン移行を試みる
            self.board:attemptToNext()
        end,
        
    }
end
local function shuffle(t)
    local tbl = {}
    for i = 1, #t do
        tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
        --local j = math.random(i)
        local j
        if IMCRandom then
             j=IMCRandom(1, i)
        else
            j = math.random(i)
        end
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

g.Board=function()
    return {
        members={},
        rules={},
        yama={},
        wanpai={
            dora={},
            rinshan={}
        },
        total_discards={},
        current_active=g.EAST,
        round=g.EAST,
        kyoku=1,
        getDoraIndicators=function(self)
            local opened_dora_count=1+(4-#self.wanpai.rinshan)
            local dora_indicator={}
            for i=1,opened_dora_count do
                dora_indicator[i]=self.wanpai.doras[1+(i-1)*2]
            end
            return dora_indicator
        end,
        isDora=function(self,tile)
            local dora_indicators=self:getDoraIndicator()
            return g.utils.plus_dora(tile,dora_indicators)>=0
        end,
        startGame=function(self)
      
            
            for player = 1, 4 do
                self.members[player] =g.Member(self,player, 'ほげほげ', 25000)
            end
            self:initializeRound()
        end,
        initializeRound = function(self)
           self:doShipai()
        end,
        doShipai = function(self)
            --山生成
            local yama = {}
            for i = 0, 135 do
                --数字
                table.insert(yama, i)
            end
            --シャッフル
            yama = shuffle(yama)
            local dora = {}
            local rinshan = {}
            --王牌確保

            --どら
            for i = 1, 5 * 2 do
                local hai = table.remove(yama)
                table.insert(dora, hai)
            end
            --りんしゃん
            for i = 1, 2 * 2 do
                local hai = table.remove(yama)
                table.insert(rinshan, hai)
            end

            --くばる
            --雑な配り方だけど許して
            for player = 1, #self.members do
                local hand = g.Hand()
                for i = 1, 13 do
                    local hai = table.remove(yama)
                    table.insert(hand.close, hai)
                end
                --ソート
                table.sort(hand.close)
                self.members[player].hand = hand
               
            end
            self.total_discards={}
            self.wanpai.dora = dora
            self.wanpai.rinshan = rinshan
            self.yama = yama

            self:tsumoFromYama()
        end,
        attemptToNext=function(self)
            --TODO 差し込みを入れる
            self:changeToNextPlayer()
        end,
        changeToNextPlayer=function(self)
            self.current_active=self.current_active+1
            if self.current_active>g.NORTH then
                self.current_active=g.EAST
            end
            self:tsumoFromYama()
        end,

        tsumoFromYama=function(self)
            local player=self.members[self.current_active-g.EAST+1]

            --ツモる
            local tile=table.remove(self.yama)
            player.hand.tsumo=tile
            table.insert(player.hand.close,tile)

            
            --
        end,
    }
end
g.picker=picker
MAHJONG_LIBRARY_V1=g

return g