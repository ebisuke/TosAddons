--uie_gbg_component_fund


local acutil = require('acutil')

--ライブラリ読み込み
local debug = false
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
local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (debug == true) then
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
            print(msg)
        end,
        catch = function(error)
        end
    }
end

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT
g.gbg=g.gbg or {}
g.gbg.uiegbgComponentFund={
    FLAG_SILVER=0x01,
    FLAG_MERCINARYCOIN=0x02,
    new=function(parentgbg,name,flags,size)
        local self=inherit(g.gbg.uiegbgComponentFund,g.gbg.uiegbgComponentBase,parentgbg,name)
        self.flags=flags or g.gbg.uiegbgComponentFund.FLAG_SILVER
        self.size=size or 40
        return self
    end,
    initializeImpl=function(self,gbox)
        local y=0
        gbox:EnableScrollBar(0)
        if (self.flags&g.gbg.uiegbgComponentFund.FLAG_SILVER)~=0 then
            local text=gbox:CreateOrGetControl('richtext','silver',0,y,100,0)
            local silverAmountStr = GET_TOTAL_MONEY_STR();
            text:SetText(string.format('{img icon_item_silver %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..silverAmountStr)
        end
        
    end,
    hookmsgImpl=function(self,frame,msg,argStr,argNum)
        
    end
}

UIMODEEXPERT = g
