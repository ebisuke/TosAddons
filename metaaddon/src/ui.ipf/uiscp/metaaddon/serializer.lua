--metaaddon_addonlet
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.fn=g.fn or {}

g.fn.SerializeObject=function(obj)

    local tbl={}
    local pool={}
    local sobj=g.fn._SerializeObject(obj,pool)


    return {
        pool=pool,
        body=sobj
    }
end
g.fn._SerializeObject=function(obj,pool)
    if type(obj)=="table" then
        local sobj={}
     
        if obj._className then
            g.fn.dbgout("SerializeObject className:"..obj._className)
            -- MAObject
            
            if not pool[obj._id] then
                

                local blacklistFields={
                    ["_hierarchy"]=true,
                    ["_released"]=true,
                    ["_supers"]=true,
                }
                local poolobj={}
                pool[obj._id]=poolobj
                for key,value in pairs(obj) do
                    if not blacklistFields[key] then
                        
                        poolobj[key]=g.fn._SerializeObject(value,pool)
                    end
                end
            
               
                sobj={
                    _link=obj._id,
                }
            else
                sobj={
                    _link=obj._id,
                }
            end
        else
            -- Non MAObject
            for key,value in pairs(obj) do
                sobj[key]=g.fn._SerializeObject(value,pool)
            end
        end
        return sobj
    elseif type(obj)=="function" then
        -- ignore
    else
        return obj
    end
end




g.fn.DeserializeObject=function(obj)
    if not obj.body or not obj.pool then
        g.fn.errout("DeserializeObject: invalid obj")
    end
    --reconstruct pool
    local pool={}

    --create skeleton
    for key,value in pairs(obj.pool) do
        local instance=g.fn.CreateInstance(value._className)
        pool[key]=instance
    end
    --create body
    for key,_ in pairs(pool) do
        pool[key]=g.fn._DeserializeObject(obj.pool[key],pool[key],pool)
    end
    return g.fn._DeserializeObject(obj.body,{},pool)
end

g.fn._DeserializeObject=function(sobj,obj,pool)
    if type(sobj)=="table" then
        if sobj._link then
            return pool[sobj._link]
        else
 
            for key,value in pairs(sobj) do
                obj[key]=g.fn._DeserializeObject(value,{},pool)
            end
            return obj
        end
    elseif type(sobj)=="function" then
        -- ignore
    else
        return sobj
    end

end