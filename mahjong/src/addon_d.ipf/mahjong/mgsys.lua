local g={}
-- https://github.com/MahjongRepository/mahjong
-- python specific functions

local copy={}
function copy.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[copy.deepcopy(orig_key)] = copy.deepcopy(orig_value)
        end
        setmetatable(copy, copy.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function copy.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[copy.deepcopy(orig_key)] = copy.deepcopy(orig_value)
        end
        setmetatable(copy,copy.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
local function sorted(list)
    local copy=copy.deepcopy(list)
    table.sort(copy)
    return copy
end
local function sum(list)
    local s=0
    for _,v in ipairs(list) do
        s=s+v
    end
    return s
end
local function all(list,cond)
    
    for _,v in ipairs(list) do
        if(not cond(v)) then
            return false
        end
    end
    return true
end
local function picker(list,cond,add)
    local l={}
    for _,v in ipairs(list) do
        
        local pass=true
        if cond then
            pass=cond(v)
        
        end
        if pass then
            local val=v+(add or 0)
            l[#l+1] = val
        end
    end
    return l
end
local function arraygenerator(count,init)
    local list={}
    for x=0,count-1 do
        list[#list+1] = init
    end
    return list
end
local function find(list,dest)
    local list={}
    for k,v in ipairs(list) do
        if(v==dest)then
            return true
        end
    end
    return false
end
--agari
g.Agari={

    is_agari=function(self, tiles_34, open_sets_34)
        

        local tiles = copy.deepcopy(tiles_34)


        if open_sets_34 then
            local isolated_tiles = find_isolated_tile_indices(tiles)
            for meld in ipairs(open_sets_34) do
                if not isolated_tiles then
                    break
                 end
                 local isolated_tile = isolated_tiles.pop()

                tiles[meld[0]] =tiles[meld[0]]- 1
                tiles[meld[1]] =tiles[meld[1]]- 1
                tiles[meld[2]] =tiles[meld[2]]- 1
                tiles[isolated_tile] = 3
            end
        end
        j = (1 << tiles[27]) | (1 << tiles[28]) | (1 << tiles[29]) | (1 << tiles[30]) |  (1 << tiles[31]) | (1 << tiles[32]) | (1 << tiles[33])

        if j >= 0x10 then
            return false
        end

        if ((j & 3) == 2) and (tiles[0] * tiles[8] * tiles[9] * tiles[17] * tiles[18] *
                               tiles[26] * tiles[27] * tiles[28] * tiles[29] * tiles[30] *
                               tiles[31] * tiles[32] * tiles[33] == 2) then
            return true

        end
        local sum =0
        for k,v in range(0,34) do
            if(tiles[i]==2)then
                sum=sum+1
            end
        end
        if not (j & 10) and sum == 7 then
            return true
        end
        if j & 2 then
            return false
        end
        local n00 = tiles[0] + tiles[3] + tiles[6]
        local n01 = tiles[1] + tiles[4] + tiles[7]
        local n02 = tiles[2] + tiles[5] + tiles[8]

        local n10 = tiles[9] + tiles[12] + tiles[15]
        local n11 = tiles[10] + tiles[13] + tiles[16]
        local n12 = tiles[11] + tiles[14] + tiles[17]

        local n20 = tiles[18] + tiles[21] + tiles[24]
        local n21 = tiles[19] + tiles[22] + tiles[25]
        local n22 = tiles[20] + tiles[23] + tiles[26]

        local  n0 = (n00 + n01 + n02) % 3
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
        if ((n0 == 2) + (n1 == 2) + (n2 == 2) + (tiles[27] == 2) + (tiles[28] == 2) +
                (tiles[29] == 2) + (tiles[30] == 2) + (tiles[31] == 2) + (tiles[32] == 2) +
                (tiles[33] == 2) ~= 1)then
            return false
    end
        local nn0 = (n00 * 1 + n01 * 2) % 3
        local m0 = self._to_meld(tiles, 0)
        local nn1 = (n10 * 1 + n11 * 2) % 3
        local m1 = self._to_meld(tiles, 9)
        local nn2 = (n20 * 1 + n21 * 2) % 3
        local m2 = self._to_meld(tiles, 18)

        if j & 4 then
            return not (n0 | nn0 | n1 | nn1 | n2 | nn2) and self._is_mentsu(m0) 
                and self._is_mentsu(m1) and self._is_mentsu(m2)
        end
        if n0 == 2 then
            return not (n1 | nn1 | n2 | nn2) and self._is_mentsu(m1) and self._is_mentsu(m2) 
                and self._is_atama_mentsu(nn0, m0)
        end
        if n1 == 2 then
            return not (n2 | nn2 | n0 | nn0) and self._is_mentsu(m2) and self._is_mentsu(m0) 
                and self._is_atama_mentsu(nn1, m1)
        end
        if n2 == 2 then
            return not (n0 | nn0 | n1 | nn1) and self._is_mentsu(m0) and self._is_mentsu(m1) 
                and self._is_atama_mentsu(nn2, m2)
        end
        return false
    end,
    _is_mentsu=function(self, m)
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
        for x=0,5 do
            b = c
            c = 0
            if a == 1 or a == 4 then
                b = b+ 1
                c = c+ 1
            elseif a == 2 then
                b = b+ 2
                c = c+ 2
            end
            m =m>> 3
            a = (m & 7) - b
            if a < 0 then
                is_not_mentsu = true
                break
            end
        end
        if is_not_mentsu then
            return false
        end
        m =  m>>3
        a = (m & 7) - c

        return a == 0 or a == 3
    end,
    _is_atama_mentsu=function(self, nn, m)
        if nn == 0 then
            if (m & (7 << 6)) >= (2 << 6) and self._is_mentsu(m - (2 << 6)) then
                return true
            end
            if (m & (7 << 15)) >= (2 << 15) and self._is_mentsu(m - (2 << 15))then
                return true
            end
            if (m & (7 << 24)) >= (2 << 24) and self._is_mentsu(m - (2 << 24))then
                return true
            end
        elseif nn == 1 then
            if (m & (7 << 3)) >= (2 << 3) and self._is_mentsu(m - (2 << 3))then
                return true
            end
            if (m & (7 << 12)) >= (2 << 12) and self._is_mentsu(m - (2 << 12))then
                return true
            end
            if (m & (7 << 21)) >= (2 << 21) and self._is_mentsu(m - (2 << 21))then
                return true
            end
        elseif nn == 2 then
            if (m & (7 << 0)) >= (2 << 0) and self._is_mentsu(m - (2 << 0))then
                return true
            end
            if (m & (7 << 9)) >= (2 << 9) and self._is_mentsu(m - (2 << 9))then
                return true
            end
            if (m & (7 << 18)) >= (2 << 18) and self._is_mentsu(m - (2 << 18))then
                return true
            end
        end
        return false
    end,
    _to_meld=function(self, tiles, d)
        local result = 0
        for i=0,8 do
            result =result| (tiles[d + i] << i * 3)
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
g.HONOR_INDICES = g.WINDS + {g.HAKU, g.HATSU, g.CHUN}

g.FIVE_RED_MAN = 16
g.FIVE_RED_PIN = 52
g.FIVE_RED_SOU = 88

g.AKA_DORA_LIST = {g.FIVE_RED_MAN, g.FIVE_RED_PIN, g.FIVE_RED_SOU}

g.DISPLAY_WINDS = {
    [g.EAST]= 'East',
    [g.SOUTH]= 'South',
    [g.WEST]= 'West',
    [g.NORTH]= 'North'
}
--meld
function g.Meld()
    return {
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

        init=function(self, meld_type, tiles, opened, called_tile, who, from_who)
            self.type = meld_type
            self.tiles = tiles or {}
            self.opened = opened
            self.called_tile = called_tile
            self.who = who
            self.from_who = from_who
        end,
        __str__=function(self)
            return string.format('Type: {%s}, Tiles: {%s} {%s}',self.type, g.TilesConverter.to_one_line_string(self.tiles), self.tiles)
        end,

        __repr__=function(self)
            return self.__str__()
        end,

        tiles_34=function(self)
            local list={}
            for i=0,#self.tiles-4 do
                list[i+1]=math.floor(self.tiles[i]/4)
            end
            
        end
    }
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

        calculate_shanten=function (self, tiles_34, open_sets_34, chiitoitsu, kokushi)

            tiles_34 = copy.deepcopy(tiles_34)

            self._init(tiles_34)

            local count_of_tiles = sum(tiles_34)

            if count_of_tiles > 14 then
                return -2
            end

            if open_sets_34 then
                local isolated_tiles = find_isolated_tile_indices(tiles_34)
                for meld in open_sets_34 do
                    if not isolated_tiles then
                        break
                    end
                    local isolated_tile = isolated_tiles.pop()

                    tiles_34[meld[0]] =  tiles_34[meld[0]]-1
                    tiles_34[meld[1]] =  tiles_34[meld[1]]-1
                    tiles_34[meld[2]] =  tiles_34[meld[2]]-1
                    tiles_34[isolated_tile] = 3
                end
            end
            if not open_sets_34 then
                self.min_shanten = self._scan_chiitoitsu_and_kokushi(chiitoitsu, kokushi)
            end
            self._remove_character_tiles(count_of_tiles)

            local init_mentsu = math.floor((14 - count_of_tiles) / 3)
            self._scan(init_mentsu)

            return self.min_shanten
        end,
        _init=function(self, tiles)
            self.tiles = tiles
            self.number_melds = 0
            self.number_tatsu = 0
            self.number_pairs = 0
            self.number_jidahai = 0
            self.number_characters = 0
            self.number_isolated_tiles = 0
            self.min_shanten = 8
        end,
        _scan=function(self, init_mentsu)
            self.number_characters = 0
            for i=0,26 do
                self.number_characters = self.number_characters|(self.tiles[i] == 4) << i
            end
            self.number_melds = self.number_melds+init_mentsu
            self._run(0)
        end,

        _run=function(self, depth)
            if self.min_shanten == AGARI_STATE then
                return
            end

            while not self.tiles[depth] do
                depth = depth+ 1

                if depth >= 27 then
                    break
                end
            end
            if depth >= 27 then
                return self._update_result()
            end
            local i = depth
            if i > 8 then
                i = i- 9
            end
            if i > 8 then
                i = i- 9
            end
            if self.tiles[depth] == 4 then
                self._increase_set(depth)
                if i < 7 and self.tiles[depth + 2] then
                    if self.tiles[depth + 1] then
                        self._increase_syuntsu(depth)
                        self._run(depth + 1)
                        self._decrease_syuntsu(depth)
                    end
                    self._increase_tatsu_second(depth)
                    self._run(depth + 1)
                    self._decrease_tatsu_second(depth)
                end
                if i < 8 and self.tiles[depth + 1] then
                    self._increase_tatsu_first(depth)
                    self._run(depth + 1)
                    self._decrease_tatsu_first(depth)
                end
                self._increase_isolated_tile(depth)
                self._run(depth + 1)
                self._decrease_isolated_tile(depth)
                self._decrease_set(depth)
                self._increase_pair(depth)

                if i < 7 and self.tiles[depth + 2] then
                    if self.tiles[depth + 1] then
                        self._increase_syuntsu(depth)
                        self._run(depth)
                        self._decrease_syuntsu(depth)
                    end
                    self._increase_tatsu_second(depth)
                    self._run(depth + 1)
                    self._decrease_tatsu_second(depth)
                end
                if i < 8 and self.tiles[depth + 1] then
                    self._increase_tatsu_first(depth)
                    self._run(depth + 1)
                    self._decrease_tatsu_first(depth)
                end
                self._decrease_pair(depth)
            end
            if self.tiles[depth] == 3 then
                self._increase_set(depth)
                self._run(depth + 1)
                self._decrease_set(depth)
                self._increase_pair(depth)

                if i < 7 and self.tiles[depth + 1] and self.tiles[depth + 2] then
                    self._increase_syuntsu(depth)
                    self._run(depth + 1)
                    self._decrease_syuntsu(depth)
                else
                    if i < 7 and self.tiles[depth + 2] then
                        self._increase_tatsu_second(depth)
                        self._run(depth + 1)
                        self._decrease_tatsu_second(depth)
                    end
                    if i < 8 and self.tiles[depth + 1] then
                        self._increase_tatsu_first(depth)
                        self._run(depth + 1)
                        self._decrease_tatsu_first(depth)
                    end
                end
                self._decrease_pair(depth)

                if i < 7 and self.tiles[depth + 2] >= 2 and self.tiles[depth + 1] >= 2 then
                    self._increase_syuntsu(depth)
                    self._increase_syuntsu(depth)
                    self._run(depth)
                    self._decrease_syuntsu(depth)
                    self._decrease_syuntsu(depth)
                end
            end
            if self.tiles[depth] == 2 then
                self._increase_pair(depth)
                self._run(depth + 1)
                self._decrease_pair(depth)
                if i < 7 and self.tiles[depth + 2] and self.tiles[depth + 1] then
                    self._increase_syuntsu(depth)
                    self._run(depth)
                    self._decrease_syuntsu(depth)
                end
            end
            if self.tiles[depth] == 1 then
                if i < 6 and self.tiles[depth + 1] == 1 and self.tiles[depth + 2] and self.tiles[depth + 3] ~= 4 then
                    self._increase_syuntsu(depth)
                    self._run(depth + 2)
                    self._decrease_syuntsu(depth)
                else
                    self._increase_isolated_tile(depth)
                    self._run(depth + 1)
                    self._decrease_isolated_tile(depth)

                    if i < 7 and self.tiles[depth + 2] then
                        if self.tiles[depth + 1] then
                            self._increase_syuntsu(depth)
                            self._run(depth + 1)
                            self._decrease_syuntsu(depth)
                        end
                        self._increase_tatsu_second(depth)
                        self._run(depth + 1)
                        self._decrease_tatsu_second(depth)
                    end
                    if i < 8 and self.tiles[depth + 1] then
                        self._increase_tatsu_first(depth)
                        self._run(depth + 1)
                        self._decrease_tatsu_first(depth)
                    end
                end
            end
        end,
        _update_result=function(self)
            local ret_shanten = 8 - self.number_melds * 2 - self.number_tatsu - self.number_pairs
            local n_mentsu_kouho = self.number_melds + self.number_tatsu
            if self.number_pairs then
                n_mentsu_kouho = n_mentsu_kouho+self.number_pairs - 1
            elseif self.number_characters and self.number_isolated_tiles then
                if (self.number_characters | self.number_isolated_tiles) == self.number_characters then
                    ret_shanten = ret_shanten+1
                end
            end
            if n_mentsu_kouho > 4 then
                ret_shanten = ret_shanten+n_mentsu_kouho - 4
            end
            if ret_shanten ~= Shanten.AGARI_STATE and ret_shanten < self.number_jidahai then
                ret_shanten = self.number_jidahai
            end
            if ret_shanten < self.min_shanten then
                self.min_shanten = ret_shanten
            end
        end,
        _increase_set=function(self, k)
            self.tiles[k] = self.tiles[k]-3
            self.number_melds =  self.number_melds+1
        end,
        _decrease_set=function(self, k)
            self.tiles[k] =  self.tiles[k]+3
            self.number_melds = self.number_melds -1
        end,
        _increase_pair=function(self, k)
            self.tiles[k] = self.tiles[k]-2
            self.number_pairs = self.number_pairs+1
        end,
        _decrease_pair=function(self, k)
            self.tiles[k] = self.tiles[k] +2
            self.number_pairs = self.number_pairs-1
        end,
        _increase_syuntsu=function(self, k)
            self.tiles[k] = self.tiles[k]-1
            self.tiles[k + 1] = self.tiles[k + 1]-1
            self.tiles[k + 2] = self.tiles[k + 2]-1
            self.number_melds = self.number_melds+1
        end,
        _decrease_syuntsu=function(self, k)
            self.tiles[k] = self.tiles[k]+1
            self.tiles[k + 1] = self.tiles[k + 1]+1
            self.tiles[k + 2] = self.tiles[k + 2]+1
            self.number_melds = self.number_melds-1
        end,
        _increase_tatsu_first=function(self, k)
            self.tiles[k] = self.tiles[k]-1
            self.tiles[k + 1] = self.tiles[k + 1]-1
            self.number_tatsu = self.number_tatsu+1
        end,

        _decrease_tatsu_first=function(self, k)
            self.tiles[k] = self.tiles[k]+1
            self.tiles[k + 1] = self.tiles[k + 1]+1
            self.number_tatsu = self.number_tatsu-1
        end,
        _increase_tatsu_second=function(self, k)
            self.tiles[k] = self.tiles[k]-1
            self.tiles[k + 2] = self.tiles[k + 2]-1
            self.number_tatsu =  self.number_tatsu+1
        end,
        _decrease_tatsu_second=function(self, k)
            self.tiles[k] = self.tiles[k]+1
            self.tiles[k + 2] =  self.tiles[k + 2]+1
            self.number_tatsu =self.number_tatsu- 1
        end,
        _increase_isolated_tile=function(self, k)
            self.tiles[k] = self.tiles[k]-1
            self.number_isolated_tiles =  self.number_isolated_tiles|(1 << k)
        end,
        _decrease_isolated_tile=function(self, k)
            self.tiles[k] = self.tiles[k]+1
            self.number_isolated_tiles = self.number_isolated_tiles|(1 << k)
        end,
        _scan_chiitoitsu_and_kokushi=function(self, chiitoitsu, kokushi)
            local shanten = self.min_shanten

            local indices = {0, 8, 9, 17, 18, 26, 27, 28, 29, 30, 31, 32, 33}

            local completed_terminals = 0
            for _,i in ipairs(indices) do
                if self.tiles[i] >= 2 then
                    completed_terminals =completed_terminals
                end
            end
            local terminals = 0
            for _,i in ipairs(indices) do
                if self.tiles[i] ~=0 then
                    terminals =terminals+1
                end
            end
            indices = {1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16, 19, 20, 21, 22, 23, 24, 25}

            local completed_pairs = completed_terminals
            for _,i in ipairs(indices) do
                if self.tiles[i] >=2 then
                completed_pairs = completed_pairs+1
                end
            end
            local pairs = terminals
            for _,i in ipairs(indices) do
                if self.tiles[i] ~=0 then
                    pairs =pairs+1
                end
            end
            if chiitoitsu then
                local ret_shanten = 6 - completed_pairs + (pairs < 7 and 7 - pairs or 0)
                if ret_shanten < shanten then
                    shanten = ret_shanten
                end
            end
            if kokushi then
                local ret_shanten = 13 - terminals - (completed_terminals and 1 or 0)
                if ret_shanten < shanten then
                    shanten = ret_shanten
                end
            end
            return shanten
        end,
        _remove_character_tiles=function(self, nc)
            local number = 0
            local isolated = 0

            --for i in range(27, 34):
            for i=27,33 do
                if self.tiles[i] == 4 then
                    self.number_melds =  self.number_melds +1
                    self.number_jidahai = self.number_jidahai+1
                    number = number|(1 << (i - 27))
                    isolated = isolated|(1 << (i - 27))
                end
                if self.tiles[i] == 3 then
                    self.number_melds =  self.number_melds+1
                end
                if self.tiles[i] == 2 then
                    self.number_pairs =  self.number_pairs+1
                end
                if self.tiles[i] == 1 then
                    isolated =isolated| (1 << (i - 27))
                end
            end
            if self.number_jidahai and (nc % 3) == 2 then
                self.number_jidahai =  self.number_jidahai-1
            end

            if isolated then
                self.number_isolated_tiles =  self.number_isolated_tiles|(1 << 27)
                if (number | isolated) == number then
                    self.number_characters = self.number_characters|(1 << 27)
                end
            end
        end

    }
end

--tile


g.Tile={
    value = nil,
    is_tsumogiri = nil,

    __init__=function(self, value, is_tsumogiri)
        self.value = value
        self.is_tsumogiri = is_tsumogiri
    end
}

g.TilesConverter={

    to_one_line_string=function(tiles, print_aka_dora)

        tiles = sorted(tiles)

        local man = picker(tiles,function(t)return t<36 end)

        local pin =  picker(tiles,function(t)return 36 <= t and t < 72 end)
        pin =  picker(pin,nil,-36)

        local sou = picker(tiles,function(t)return 72 <= t and t < 108 end)
        sou =picker(sou,nil,-72)

        local  honors = picker(tiles,function(t)return t>=108 end)
        honors = picker(honors,nil,-108)

        function words(suits, red_five, suffix)
            local word=""
            for _,v in ipairs(suits) do
                if v== red_five and print_aka_dora then
                    word=0
                else
                    word=tostring(math.floor(i/4)+1)
                end

            end

            return suits and ''.. word .. suffix or ''
        end
        sou = words(sou, g.FIVE_RED_SOU - 72, 's')
        pin = words(pin, g.FIVE_RED_PIN - 36, 'p')
        man = words(man, g.FIVE_RED_MAN, 'm')
        honors = words(honors, -1 - 108, 'z')

        return man + pin + sou + honors
    end,

    to_34_array=function(tiles) 
     
        local results = arraygenerator(34,0)
        for tile in tiles do
            tile = math.floor(tile/4)
            results[tile] =results[tile]+ 1
        end
        return results
    end,

     to_136_array=function (tiles)
 
        local temp = {}
        local results = {}
        --for x in range(0, 34):
        for x=0,33 do
            if tiles[x] then
                
                local temp_value = arraygenerator(x*4, tiles[x])
                for _,tile in ipairs(temp_value)do
                    
                    if find(results,tile) then
                        local count_of_tiles = #picker(temp,function(t)return t==tile end)
                        local new_tile = tile + count_of_tiles
                        results.append(new_tile)

                        temp.append(tile)
                    else
                        results.append(tile)
                        temp.append(tile)
                    end
                end
            end
        end
        return results
    end,
    
    string_to_136_array=function(sou, pin, man, honors, has_aka_dora)
        
        function _split_string(string, offset, red)
            local data = {}
            local temp = {}

            if not string then
                return {}
            end

            for k,i in ipairs(string) do
                if (i == 'r' or i == '0') and has_aka_dora then
                    temp.append(red)
                    data.append(red)
                else
                    local tile = offset + (tonumber(i) - 1) * 4
                    if tile == red and has_aka_dora then
                     
                        tile =tile+ 1
                    end
                    if find(data,tile) then
                        local count_of_tiles = #picker(temp,function(t)return t==tile end)
                        local new_tile = tile + count_of_tiles
                        data.append(new_tile)

                        temp.append(tile)
                    else
                        data.append(tile)
                        temp.append(tile)
                    end
                end
            end
            return data
        end

        local results = _split_string(man, 0, g.FIVE_RED_MAN)
        for k,v in pairs(_split_string(pin, 36, g.FIVE_RED_PIN)) do results[#results+1] = v end
        for k,v in pairs(_split_string(sou, 72, g.FIVE_RED_SOU)) do results[#results+1] = v end
        for k,v in pairs( _split_string(honors, 108)) do results[#results+1] = v end
       


        return results

    end,
    string_to_34_array=function(sou, pin, man, honors)
   
        local results = g.TilesConverter.string_to_136_array(sou, pin, man, honors)
        results = g.TilesConverter.to_34_array(results)
        return results
    end
    ,
    find_34_tile_in_136_array=function(tile34, tiles)

        if tile34 == nil or tile34 > 33 then
                return nil
        end

        local tile = tile34 * 4

        local possible_tiles = arraygenerator(1,tile)
        for i=1,3 do
            possible_tiles[#possible_tiles+1] = tile+1
        end
        -- + [tile + i for i in range(1, 4)]

        local found_tile = nil
        for _,possible_tile in ipairs(possible_tiles) do
            if find(tiles,possible_tile)then
                found_tile = possible_tile
                break
            end
        end

        return found_tile

    end,
    one_line_string_to_136_array=function(string, has_aka_dora)

        local sou = ''
        local pin = ''
        local man = ''
        local honors = ''

        local split_start = 0

        for index, i in ipairs(string) do
            if i == 'm' then
                man =man.. string:sub(split_start+1,index)
                split_start = index + 1
 
        end
            if i == 'p' then
                pin = pin.. string:sub(split_start+1,index)
                split_start = index + 1
        end
                if i == 's'then
                sou =  sou..string:sub(split_start+1,index)
                split_start = index + 1
        end
                if i == 'z' or i == 'h'then
                honors = honors..string:sub(split_start+1,index)
                split_start = index + 1
        end
    end
        return g.TilesConverter.string_to_136_array(sou, pin, man, honors, has_aka_dora)
    end,

    one_line_string_to_34_array=function(string, has_aka_dora)
       
        local results = g.TilesConverter.one_line_string_to_136_array(string, has_aka_dora)
        results = g.TilesConverter.to_34_array(results)
        return results
    end
}

g.utils={
    
is_aka_dora=function(tile, aka_enabled)

    if not aka_enabled then
        return false
end
    if find({g.Tile.FIVE_RED_MAN, g.Tile.FIVE_RED_PIN, g.Tile.FIVE_RED_SOU},tile) then
        return true
    end
    return false
end,

plus_dora=function(tile, dora_indicators)
    
    local tile_index = tile // 4
    local dora_count = 0

    for _,dora in ipairs(dora_indicators) do
        dora = math.floor(dora/4)

        -- sou, pin, man
        if tile_index < g.Tile.EAST then

            -- with indicator 9, dora will be 1
            if dora == 8 then
                dora = -1
            elseif dora == 17 then
                dora = 8
            elseif dora == 26 then 
                dora = 17
            end
            if tile_index == dora + 1 then
                dora_count = dora_count+1
            end
        else
            if dora < g.Tile.EAST then
                --continue
            else

                dora = dora-9 * 3
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
                    dora_count =dora_count+ 1
                end
            end
        end
    end
    return dora_count
    end,

is_chi=function(item)

    if #item ~= 3 then
        return false
    end
    return item[0] == item[1] - 1 == item[2] - 2
end,

is_pon=function(item)

if #item ~= 3 then
    return false
end
return item[0] == item[1] == item[2]
end,

is_pair=function(item)

return #item == 2
end,

is_man=function(tile)

return tile <= 8
end,

is_pin=function(tile)

return 8 < tile <= 17
end,

is_sou=function(tile)

return 17 < tile <= 26
end,

is_honor=function(tile)

return tile >= 27
end,

is_terminal=function(tile)

return find(g.Tile.TERMINAL_INDICES,tile)
end,

is_dora_indicator_for_terminal=function(tile)

return tile == 7 or tile == 8 or tile == 16 or tile == 17 or tile == 25 or tile == 26
end,

contains_terminals=function(hand_set)
    for _,v in ipairs(hand_set) do
        if(find(g.Tile.TERMINAL_INDICES,v))then
            return true
        end
    end
    return false

end,
simplify=function(tile)

    return tile - 9 * (tile // 9)
end,

find_isolated_tile_indices=function(hand_34)

    local isolated_indices = {}

    for x=0, g.Tile.CHUN + 1-1 do
         -- for honor tiles we don't need to check nearby tiles
        if g.utils.is_honor(x) and hand_34[x] == 0 then
            isolated_indices.append(x)
        else
            local simplified = g.utils.simplify(x)

            -- 1 suit tile
            if simplified == 0 then
                if hand_34[x] == 0 and hand_34[x + 1] == 0 then
                    isolated_indices.append(x)
                end
            elseif
                -- 9 suit tile
                simplified == 8 then
                    if hand_34[x] == 0 and hand_34[x - 1] == 0 then
                        isolated_indices.append(x)
                    end
                -- 2-8 tiles tiles
            else
                if hand_34[x] == 0 and hand_34[x - 1] == 0 and hand_34[x + 1] == 0 then
                    isolated_indices.append(x)
                end
            end
        end
    end
    return isolated_indices
end,

is_tile_strictly_isolated=function(hand_34, tile_34)

hand_34 = copy.copy(hand_34)
-- we don't need to count target tile in the hand
hand_34[tile_34] =hand_34[tile_34]- 1
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
        indices = {tile_34, tile_34 + 1, tile_34 + 2}
    -- 2 suit tile
    elseif simplified == 1 then
        indices = {tile_34 - 1, tile_34, tile_34 + 1, tile_34 + 2}
    -- 8 suit tile
    elseif simplified == 7 then
        indices = {tile_34 - 2, tile_34 - 1, tile_34, tile_34 + 1}
    -- 9 suit tile
    elseif simplified == 8 then
        indices = {tile_34 - 2, tile_34 - 1, tile_34}
    -- 3-7 tiles tiles
    else
        indices = {tile_34 - 2, tile_34 - 1, tile_34, tile_34 + 1, tile_34 + 2}
    end
end
return all(indices,function(x) return hand_34[x] == 0 end)
    end,

count_tiles_by_suits=function(tiles_34)

local suits = {
    {['count']= 0, ['name']= 'sou',   ['function']= g.utils.is_sou},
    {['count']= 0, ['name']= 'man',   ['function']= g.utils.is_man},
    {['count']= 0, ['name']= 'pin',   ['function']= g.utils.is_pin},
    {['count']= 0, ['name']= 'honor', ['function']= g.utils.is_honor}
    }

    for x=0,33 do
        local tile = tiles_34[x]
        if not tile then
            --continue
        else
            for _,item in ipairs(suits) do
                if item['function'](x) then
                    item['count'] = item['count'] + tile
                end

            end
        end
    end
return suits
end
}
