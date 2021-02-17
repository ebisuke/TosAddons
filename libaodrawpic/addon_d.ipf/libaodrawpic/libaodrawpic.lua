-- libaodrawpic by ebisuke

local g={
    debug=false,
    images={
        brush_small_s=5,
        brush_small_bs=5,
        brush_large_s=10,
        brush_large_bs=10,
    }
}
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
local function cat(tbla,tblb)
    
    local cpy=deepcopy(tbla)
    for k,v in pairs(tblb) do
        table.insert(cpy,v)
    end
    return cpy
end
function g.inject(pic)
    pic._drewElementCount=pic._drewElementCount or 0
    if pic._OldRemoveAllChild==nil and pic._OldRemoveAllChild~=pic.RemoveAllChild then
        pic._OldRemoveAllChild=pic.RemoveAllChild
        function pic.RemoveAllChild(self)
            
            self:_OldRemoveAllChild()
            pic._drewElementCount=0
        end
    end
    

    function pic.DrawBrushHorz(self,x,y,xx,yy,brush,color)
        if xx<x then
            local swap=xx
            xx=x
            x=swap
        end
        if yy<y then
            local swap=yy
            yy=y
            y=swap
        end
        local sz=math.floor(g.images[brush])
        local szl=g.images[brush]
        if g.images[brush] then
            if g.images[brush]>(xx-x) then
                for i=1,xx-x+1 do
                    local elem=self:CreateOrGetControl("picture","libaodrawpicelem"..self._drewElementCount,x+i-1-szl/2,math.ceil(y-sz/2+1),1,1)
                    AUTO_CAST(elem)
                    elem:SetImage(brush..'_min')
                    elem:SetColorTone(color)
                    elem:Resize(szl,szl)
                    elem:EnableHitTest(0)
                    self._drewElementCount=self._drewElementCount+1
                end
            else
                local elem=self:CreateOrGetControl("groupbox","libaodrawpicelem"..self._drewElementCount,x,y,30,30)
                AUTO_CAST(elem)
                
                elem:SetSkinName('sb_'..brush)
                --elem:SetSkinName('bg2')
                elem:SetColorTone(color)
                
                elem:Resize(xx-x+sz,szl)
                elem:SetOffset(math.ceil(x-szl/2),math.ceil(y-sz/2+1))
                elem:EnableHitTest(0)
                self._drewElementCount=self._drewElementCount+1
            end
        else
                ERROUT('Brush not found:'..brush)
        end
    end
    function pic.DrawBrushIcon(self,x,y,brush,color)
        local elem=self:CreateOrGetControl("picture","libaodrawpicelem"..self._drewElementCount,x,y,1,1)
        AUTO_CAST(elem)
        elem:SetImage(brush)
        elem:SetOffset(elem:GetX()-elem:GetImageWidth()/2,elem:GetY()-elem:GetImageHeight()/2)
        elem:Resize(elem:GetImageWidth(),elem:GetImageHeight())
        elem:SetColorTone(color)
        elem:EnableHitTest(0)
        self._drewElementCount=self._drewElementCount+1
    end


    return pic;
end

function LIBAODRAWPIC_ON_INIT(addon, frame)
end
LIBAODRAWPICV1_0=g

function LIBAODRAWPIC_TEST()


end
