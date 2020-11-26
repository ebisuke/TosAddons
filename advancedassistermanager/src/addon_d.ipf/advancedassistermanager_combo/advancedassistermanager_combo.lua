-- advancedassistermanager_combo

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
local function fact (n)
    if n <= 0 then
      return 1
    else
      return n * fact(n-1)
    end
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
local function card_combination4(list,limit)
    local comb={}
    for k,v in ipairs(list) do
        for kk,vv in ipairs(list) do
            if kk~=k then
                for kkk=kk+1,#list do
                    local vvv=list[kkk]
                    if kkk~=k and kkk~=kk then
                        for kkkk=kkk+1,#list do
                            local vvvv=list[kkkk]
                            if kkkk~=k and kkkk~=kk and kkkk~=kkk  then
                                comb[#comb+1] = {
                                    v,vv,vvv,vvvv
                                }
                                if limit and #comb>limit then
                                    return comb,false
                                end
                            end
                        end
                    end
                    
                end
            end
        end
        
    end
    return comb,true
end
--アドオン名（大文字）
local addonName = 'advancedassistermanager'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.framename_cmb = 'advancedassistermanager_combo'
g.aamc={
    condition={
        main=nil,
        sub={}
    },
    search={
        work=false,
        combination={},
        progress=0,
        count=0,
        matched={}
    },

    searchresult={},
    getPassiveListByCards=function(cards)
        local passives={}
        for _,v in ipairs(cards) do
            local mainCard=v
            local infoCls = GetClass("Ancient_Info",mainCard.classname)
            if infoCls ~= nil then
                local buffName = TryGetProp(infoCls, "StringArg1", "None")
                local buffCls = GetClass("Buff",buffName)
                if not g.aamc.condition.main or g.aamc.condition.main.buffName==buffName then
                    passives[buffCls.ClassID]= passives[buffCls.ClassID] or {}
                    passives[buffCls.ClassID][#passives[buffCls.ClassID]+1]={
                        name=buffCls.Name,
                        buffName=buffName,
                        
                        card=mainCard,
                        tooltip=buffCls.ToolTip
                    }
                end
            end
        end
        return passives
    end,
    getFilteredCard=function(cards)
        --絞り込み処理
        local supcards={}
        local clsList,clsCount = GetClassList("ancient_combo")
        
        for _,v in ipairs(cards)do
            local pass=true

            local cls = GetClass("Monster",v.classname)
            for _,vv in ipairs(g.aamc.condition.sub) do
                
                for i = 0,clsCount-1 do
                    local comboCls = GetClassByIndexFromList(clsList, i);
                    local typename=comboCls.TypeName_1
                    local classname=comboCls.ClassName
                    if classname==vv.buffName then
                        if vv.type==1 then
                            if typename~=cls.Attribute then
                                pass=false
                            end
                        elseif vv.type==2 then
                            if typename~=cls.RaceType then
                                pass=false
                            end
                        elseif vv.type==3 then
                            if tonumber(typename)~=v.rarity then
                                pass=false
                            end
                        end
                    end
                end        
                
            end
            if pass then
                supcards[#supcards+1] = v
            end
        end
        return supcards
    end,
    calcScore=function(aamcards)
        local infoCls = GetClass("Ancient_Info",aamcards[1].classname)
    
        local caption, parsed = TRY_PARSE_ANCIENT_PROPERTY(infoCls, infoCls.Tooltop, aamcards[1].card);
        local comboList=AAM_GET_ANCIENT_COMBO_LIST({
            aamcards[1].card,
            aamcards[2].card,
            aamcards[3].card,
            aamcards[4].card,
        })

        for i = 1,#comboList do
            local comboCls = comboList[i][1]
            local comboCardList = comboList[i][2]
            local caption, parsed = TRY_PARSE_ANCIENT_PROPERTY(comboCls, comboCls.Tooltop,{
                aamcards[1].card,
                aamcards[2].card,
                aamcards[3].card,
                aamcards[4].card,
            });

        end
    end,
    getCombinationPassiveListByCards=function(cards,musthavemonstername)
        
        local byracetype={}
        local byrarity={}
        local byattribute={}

        local supcards={}
        local clsList,clsCount = GetClassList("ancient_combo")
        supcards=cards

        for _,v in ipairs(supcards)do
            local cls = GetClass("Monster",v.classname)
            byracetype[cls.RaceType]= byracetype[cls.RaceType] or {}
            byracetype[cls.RaceType][#byracetype[cls.RaceType]+1]=v
            byrarity[v.rarity]= byrarity[v.rarity] or {}
            byrarity[v.rarity][#byrarity[v.rarity]+1]=v
            byattribute[cls.Attribute]= byattribute[cls.Attribute] or {}
            byattribute[cls.Attribute][#byattribute[cls.Attribute]+1]=v
        end
        if musthavemonstername then
            local acls = GetClass("Ancient_Info",musthavemonstername)
            local cls = GetClass("Monster",musthavemonstername)
            local bk
            bk=byracetype[cls.RaceType]
            byracetype={}
            byracetype[cls.RaceType]=bk
            bk=byrarity[acls.Rarity]
            byrarity={}
            byrarity[acls.Rarity]=bk
            bk=byattribute[cls.Attribute]
            byattribute={}
            byattribute[cls.Attribute]=bk
        end


        local list={}
        for i = 0,clsCount-1 do
            local comboCls = GetClassByIndexFromList(clsList, i);
            local typename=comboCls.TypeName_1
            local classname=comboCls.ClassName
            local comb_min=tonumber(comboCls.TypeNum_1)

            if  comboCls.PreScript=='SCR_ANCIENT_COMBO_ATTRIBUTE_PRECHECK' then
                if byattribute[typename] and #byattribute[typename] >= comb_min  then
                    list[#list+1]={
                        name=comboCls.Name,
                        buffName=classname,
                        candidate=byattribute[typename],
                        tooltip=comboCls.Tooltop,
                        type=1,
                        count=#byattribute[typename]
                    }
                end
            elseif comboCls.PreScript=='SCR_ANCIENT_COMBO_RACETYPE_PRECHECK' then
                
                if byracetype[typename] and #byracetype[typename] >= comb_min then
                    list[#list+1]={
                        name=comboCls.Name,
                        buffName=classname,
                        candidate=byracetype[typename],
                        tooltip=comboCls.Tooltop,
                        type=2,
                        count=#byracetype[typename]
                    }
                end
            elseif  comboCls.PreScript=='SCR_ANCIENT_COMBO_RANK_PRECHECK' then
                
                if byrarity[tonumber(typename)] and #byrarity[tonumber(typename)] >= comb_min then
                    list[#list+1]={
                        name=comboCls.Name,
                        buffName=classname,
                        candidate=byrarity[typename],
                        tooltip=comboCls.Tooltop,
                        type=3,
                        count=#byrarity[tonumber(typename)] 
                    }
                end
            end
        
            
        end
        return list
    end,
    GET_ANCIENT_COMBO_LIST=function(cardlist)
        local comboList = {}
        local clsList,clsCount = GetClassList("ancient_combo")
        for i = 0,clsCount-1 do
            local comboCls = GetClassByIndexFromList(clsList, i);
            if comboCls.PreScript ~= nil and comboCls.PreScript ~= "None" then
                local preScript = _G[comboCls.PreScript]
                print(comboCls.PreScript)
                local slotList = preScript(comboCls,cardlist)
                if slotList ~= "None" then
                    slotList = StringSplit(slotList,'/')
                    local cardList = {}
                    
                    table.insert(comboList,comboCls)
                end
            end
        end
        return comboList
    end,
    generateCombination=function(cards)
        
    end


}


local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
                fd:flush()
                fd:close()
            end
        end,
        catch = function(error)
        end
    }
end
local function ERROUT(msg)
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end

--マップ読み込み時処理（1度だけ）
function ADVANCEDASSISTERMANAGER_COMBO_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(ADVANCEDASSISTERMANAGER_GETCID()))
            frame:ShowWindow(0)

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
                
            local timer = frame:CreateOrGetControl("timer", "addontimer");
            AUTO_CAST(timer)
            timer:SetUpdateScript("ADVANCEDASSISTERMANAGER_SEARCH_TICK");
            timer:Stop();
            timer:Start(0.01, 0);

            frame:ShowWindow(0)
            ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSITERMANAGER_COMBO_LIST_OPEN()
    ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()
end
function  ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()
    EBI_try_catch {
        try = function()
        local frame= ui.GetFrame(g.framename_cmb)
        local gboxmain=frame:CreateOrGetControl('groupbox','gboxmain',10,90,frame:GetWidth()/2-15,300)
        local gboxsub=frame:CreateOrGetControl('groupbox','gboxsub',frame:GetWidth()/2+5,90,frame:GetWidth()/2-15,300)
        local gboxcomb=frame:CreateOrGetControl('groupbox','gboxcomb',10,430,frame:GetWidth()-20,frame:GetHeight()-450)
        gboxmain:SetSkinName("bg2")
        gboxsub:SetSkinName("bg2")
        gboxcomb:SetSkinName("bg2")
        local btnclear=frame:CreateOrGetControl('button','buttonclear',10,60,100,30)
        btnclear:SetSkinName('test_pvp_btn')
        btnclear:SetText('{ol}Reset')
        btnclear:SetEventScript(ui.LBUTTONUP,'ADVANCEDASSISTERMANAGER_COMBO_ON_CLEAR_BUFF')

        local cards=g.aam.getAllCards(true)

        gboxmain:RemoveAllChild()
        gboxsub:RemoveAllChild()
        local mainpassives=g.aamc.getPassiveListByCards(cards)
        local combinationpassives
        if g.aamc.condition.main then
            local monsterCls=GetClassByType('Monster',g.aamc.condition.main.monsterid)
            combinationpassives=g.aamc.getCombinationPassiveListByCards(cards)
        else
            combinationpassives=g.aamc.getCombinationPassiveListByCards(cards)
        end
        local y=0
        y=0
        
        for k,v in pairs(mainpassives) do
          
            local red='{#FFFFFF}'
            local filtered=false
            if g.aamc.condition.main and v[1].buffName== g.aamc.condition.main.buffName then
                red='{#FF0000}'
                filtered=true
                
            end
    
            local btn=gboxmain:CreateOrGetControl('button','btnmain'..k,10,y,200,30)
            AUTO_CAST(btn)
            btn:SetSkinName('test_pvp_btn')
            btn:SetText('{ol}'..red..v[1].name)
            btn:SetTextTooltip('{ol}'..v[1].tooltip)
            btn:SetEventScript(ui.LBUTTONUP,'ADVANCEDASSISTERMANAGER_COMBO_ON_ADD_MAINBUFF')
            btn:SetEventScriptArgString(ui.LBUTTONUP,v[1].buffName)
            local cls=GetClass('Monster',v[1].card.classname)

            btn:SetEventScriptArgNumber(ui.LBUTTONUP,cls.ClassID)
            y=y+35
            
        end
        y=0
        local clsList,clsCount = GetClassList("ancient_combo")

        for k,v in pairs(combinationpassives) do
            local btn=gboxsub:CreateOrGetControl('button','btncomb'..k,10,y,200,30)
            AUTO_CAST(btn)

            local red='{#FFFFFF}'
            for _,vv in ipairs(g.aamc.condition.sub) do
                if v.buffName== vv.buffName then
                    red='{#FF0000}'
                end
            end
            btn:SetSkinName('test_pvp_btn')
            btn:SetText('{ol}'..red..v.name..'('..v.count..')')
            btn:SetTextTooltip('{ol}'..string.gsub( dictionary.ReplaceDicIDInCompStr(v.tooltip),"#{CaptionRatio}#",""))
            btn:SetEventScript(ui.LBUTTONUP,'ADVANCEDASSISTERMANAGER_COMBO_ON_ADD_SUBBUFF')
            btn:SetEventScriptArgString(ui.LBUTTONUP,v.buffName)
            btn:SetEventScriptArgNumber(ui.LBUTTONUP,v.type)
            y=y+35
        end
       
        local btnsearch=frame:CreateOrGetControl('button','btnsearch',0,400,150,30)
        btnsearch:SetGravity(ui.CENTER_HORZ,ui.TOP)
        btnsearch:SetMargin(0,400,150,0)
        btnsearch:SetSkinName('test_pvp_btn')
        btnsearch:SetText('{ol}Search')
        btnsearch:SetEventScript(ui.LBUTTONUP,'ADVANCEDASSISTERMANAGER_COMBO_ON_SEARCH')
        local btnstop=frame:CreateOrGetControl('button','btnstop',0,400,150,30)
        btnstop:SetGravity(ui.CENTER_HORZ,ui.TOP)
        btnstop:SetMargin(150,400,0,0)
        btnstop:SetSkinName('test_pvp_btn')
        btnstop:SetText('{ol}Stop')
        btnstop:SetEventScript(ui.LBUTTONUP,'ADVANCEDASSISTERMANAGER_COMBO_SEARCH_STOP')

    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function ADVANCEDASSISTERMANAGER_COMBO_ON_ADD_MAINBUFF(frame,ctrl,argstr,argnum)
    local buffCls = GetClass("Buff",argstr)
    if g.aamc.condition.main then
        if g.aamc.condition.main.buffName==argstr then
            g.aamc.condition.main=nil
            ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()
            return
        end
    end

    g.aamc.condition.main={
        buffName=argstr,
        monsterid=argnum
    }
    ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()
end
function ADVANCEDASSISTERMANAGER_COMBO_ON_ADD_SUBBUFF(frame,ctrl,argstr,argnum)
    local buffCls = GetClass("Buff",argstr)

    for k,v in ipairs(g.aamc.condition.sub) do
        if v.buffName==argstr then
            table.remove(g.aamc.condition.sub,k)
            ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()
            return
        end
    end
    g.aamc.condition.sub[#g.aamc.condition.sub+1]={
        buffName=argstr,
        type=argnum
    }

    ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()
end
function ADVANCEDASSISTERMANAGER_COMBO_ON_CLEAR_BUFF(frame,ctrl,argstr,argnum)
    g.aamc.condition.main=nil
    g.aamc.condition.sub={}
    ADVANCEDASSISTERMANAGER_COMBO_INIT_FRAME()
end
function ADVANCEDASSISTERMANAGER_SEARCH_TICK()
    EBI_try_catch {
        try = function()
            local frame= ui.GetFrame(g.framename_cmb)
            local gboxcomb=frame:GetChildRecursively('gboxcomb')
            if not g.aamc.search.work then

                return
            end
            AUTO_CAST(gboxcomb)
      
            for kk=g.aamc.search.progress,math.min(g.aamc.search.progress+5000,#g.aamc.search.combination)  do
                local vv=g.aamc.search.combination[kk]
                local pass=true
                for k,v in ipairs(g.aamc.condition.sub) do
                    local cls=GetClass('ancient_combo',v.buffName)
                    
                    local cardlist={vv[1].card,vv[2].card,vv[3].card,vv[4].card}
                
                    if _G[cls.PreScript](cls,cardlist)~='None' then
                        
                    else

                        pass=false
                    end
                    
                end
                if g.aamc.search.count>=100 then
                    pass=false

                end
        
                if pass then
                    
                    g.aamc.matched[#g.aamc.matched+1]=vv
                
                    g.aamc.search.count=g.aamc.search.count+1
                    

                    
                end
                g.aamc.search.progress=kk
                local gauge=frame:CreateOrGetControl('gauge','gauge',20,frame:GetHeight()-10,frame:GetWidth()-40,10)
                AUTO_CAST(gauge)
                gauge:SetMaxPoint(#g.aamc.search.combination)
                gauge:SetCurPoint(kk)
                
                if kk==#g.aamc.search.combination then
                    g.aamc.search.work=false
                    frame:RemoveChild('gauge')
                    ui.SysMsg('[AAM]Search Completed')
                    ADVANCEDASSISTERMANAGER_COMBO_SEARCH_COMPLETE()
                    return
                end
                
            end
            if g.aamc.search.progress==#g.aamc.search.combination then
                g.aamc.search.work=false
                frame:RemoveChild('gauge')
                ui.SysMsg('[AAM]Search Completed')
                ADVANCEDASSISTERMANAGER_COMBO_SEARCH_COMPLETE()
                
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
        
       
end
function ADVANCEDASSISTERMANAGER_COMBO_SEARCH_STOP()
    local frame= ui.GetFrame(g.framename_cmb)
    g.aamc.search.work=false
    frame:RemoveChild('gauge')
end
function ADVANCEDASSISTERMANAGER_COMBO_SEARCH_COMPLETE()
    local frame= ui.GetFrame(g.framename_cmb)
    local gboxcomb=frame:GetChildRecursively('gboxcomb')
    gboxcomb:RemoveAllChild()
    for k,v in ipairs(g.aamc.matched) do
        ADVANCEDASSISTERMANAGER_COMBO_ADD(k,v)
        
    end
end

function ADVANCEDASSISTERMANAGER_COMBO_ADD(kk,vv)
    local frame= ui.GetFrame(g.framename_cmb)
    local gboxcomb=frame:GetChildRecursively('gboxcomb')
    local minigbox=gboxcomb:CreateOrGetControl('groupbox','gboxmini'..kk,0,(kk-1)*120,gboxcomb:GetWidth()-20,130)
    AUTO_CAST(minigbox)
    minigbox:SetSkinName('none')
    minigbox:EnableHittestGroupBox(0)
    local slotset=minigbox:CreateOrGetControl('slotset','slots',0,10,minigbox:GetWidth()-300,minigbox:GetHeight())
    
    AUTO_CAST(slotset)
    slotset:SetSkinName('accountwarehouse_slot')
    slotset:EnableDrag(0)
    slotset:EnableDrop(0)
    slotset:EnableSelection(0)
    slotset:SetColRow(4,1)
    slotset:SetSpc(3, 3)
    slotset:SetSlotSize(90, 110)
    slotset:CreateSlots()
    
    for i, vvv in ipairs(vv) do
        
        local slot = slotset:GetSlotByIndex(i - 1)
        AUTO_CAST(slot)
        ADVANCEDASSISTERMANAGER_SET_SLOT(slot,vvv)
        
    end
    local tooltip=minigbox:CreateOrGetControl('richtext','tooltip',minigbox:GetWidth()-290,10,100,90)
    tooltip:EnableHitTest(0)
    local button=minigbox:CreateOrGetControl('button','btnequip',minigbox:GetWidth()-100,100,100,30)
    button:SetText('{ol}Equip')
    button:SetSkinName('test_pvp_btn')
    button:SetEventScript(ui.LBUTTONUP,'ADVANCEDASSISTERMANAGER_COMBO_ON_EQUIP')
    button:SetEventScriptArgNumber(ui.LBUTTONUP,kk)
    
    local yellow_font = "{s14}{#f9e38d}"
    local green_font = "{s14}{#2dcd37}-"
    local txt='{ol}'
    local infoCls = GetClass("Ancient_Info",vv[1].classname)
    
    local caption, parsed = TRY_PARSE_ANCIENT_PROPERTY(infoCls, infoCls.Tooltop, vv[1].card);
    local comboList=AAM_GET_ANCIENT_COMBO_LIST({
        vv[1].card,
        vv[2].card,
        vv[3].card,
        vv[4].card,
    })
    txt=txt..green_font..caption..'{nl}'
    for i = 1,#comboList do
        local comboCls = comboList[i][1]
        local comboCardList = comboList[i][2]
        local caption, parsed = TRY_PARSE_ANCIENT_PROPERTY(comboCls, comboCls.Tooltop,{
            vv[1].card,
            vv[2].card,
            vv[3].card,
            vv[4].card,
        });
        txt=txt..green_font..caption..'{nl}'
    end
    button:SetTextTooltip(txt)
    tooltip:SetText(txt)
end
function ADVANCEDASSISTERMANAGER_COMBO_ON_SEARCH(frame,ctrl,argstr,argnum)
    EBI_try_catch {
        try = function()
        
        local cards=g.aam.getAllCards(true)
        local suppedcards=cards
        local nest=4
        local another={}
        --計算コストを調べる
        local n=#suppedcards
        local calccost=fact(n)/(fact(nest)*fact(n-nest))

       
        --コンビネーションを生成

        local comb,completed=card_combination4(suppedcards)
 
        DBGOUT('cost:'..calccost..' comb:'..#comb)
        if g.aamc.condition.main then

            local moncls=GetClassByType('Monster',g.aamc.condition.main.monsterid)
            print('mon'..moncls.ClassName)
            local clon={}
            for k,v in ipairs(comb) do
                if v[1].classname~=moncls.ClassName then
                    
                else
                    clon[#clon+1]=v
                end
            end
            comb=clon
         
        end
        print(tostring(#comb))
        g.aamc.search.combination=comb;
        g.aamc.search.progress=1;
        g.aamc.matched={}
        g.aamc.search.work=true;
        g.aamc.search.count=0;
        local frame= ui.GetFrame(g.framename_cmb)
        local gboxcomb=frame:GetChildRecursively('gboxcomb')

        AUTO_CAST(gboxcomb)
        gboxcomb:RemoveAllChild()
    
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_COMBO_ON_EQUIP(frame,ctrl,argstr,argnum)
    local v=g.aamc.search.combination[argnum]
    local delay=ADVANCEDASSISTERMANAGER_DO_ENSURECARDS(v)
    delay=delay+0.3
    ReserveScript(string.format('REQUEST_SWAP_ANCIENT_CARD(nil,"%s",%d)',v[1].guid,0),delay)
    delay=delay+0.3
    ReserveScript(string.format('REQUEST_SWAP_ANCIENT_CARD(nil,"%s",%d)',v[2].guid,1),delay)
    delay=delay+0.3
    ReserveScript(string.format('REQUEST_SWAP_ANCIENT_CARD(nil,"%s",%d)',v[3].guid,2),delay)
    delay=delay+0.3
    ReserveScript(string.format('REQUEST_SWAP_ANCIENT_CARD(nil,"%s",%d)',v[4].guid,3),delay)

end
function AAM_GET_ANCIENT_COMBO_LIST(cardList)
	local comboList = {}
	local clsList,clsCount = GetClassList("ancient_combo")
	for i = 0,clsCount-1 do
		local comboCls = GetClassByIndexFromList(clsList, i);
		if comboCls.PreScript ~= nil and comboCls.PreScript ~= "None" then
			local preScript = _G[comboCls.PreScript]
			local slotList = preScript(comboCls,cardList)
			if slotList ~= "None" then
				slotList = StringSplit(slotList,'/')
				--local cardList = {}
				
				table.insert(comboList,{comboCls,cardList})
			end
		end
	end
	return comboList
end
_G['ADDONS'][author][addonName]=g