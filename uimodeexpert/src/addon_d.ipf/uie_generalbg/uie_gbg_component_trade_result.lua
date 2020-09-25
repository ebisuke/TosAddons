--uie_gbg_component_trade_result


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

g.gbg.uiegbgComponentTradeResult={

    new=function(tab,parent,name,inventory,shop)
        local self=inherit(g.gbg.uiegbgComponentTradeResult,g.gbg.uiegbgComponentBase,tab,parent,name)
        self.inventory=inventory
        self.shop=shop
        
        return self
    end,
    initializeImpl=function(self,gbox)
        local y=0

        local textdiff=gbox:CreateOrGetControl('richtext','txtdiff',0,150,200,30)
        local textarrow=gbox:CreateOrGetControl('richtext','txtarrow',0,0,200,150)
        local textremain=gbox:CreateOrGetControl('richtext','txtremain',0,210,200,20)

        self:updateDiff('0')
        
    end,
    updateDiff=function(self,diff)
        local gbox=self.gbox
        local txtdiff=gbox:GetChild('txtdiff')
        local textarrow=gbox:GetChild('txtarrow')
        local textremain=gbox:GetChild('txtremain')

        local price="0"
        if IsGreaterThanForBigNumber(diff,"0")==1 then
            --buy
            textarrow:SetText('{img white_left_arrow 150 150}')
            txtdiff:SetText('{s40}'..diff:gsub("%-",""))
            price='-'..diff
        elseif IsGreaterThanForBigNumber("0",diff)==1 then
            --sell
            textarrow:SetText('{img white_right_arrow 150 150}')
            txtdiff:SetText('{s40}'..diff:gsub("%-",""))
            price=diff:gsub('%-','')
        else
            txtdiff:SetText('{s40}0')
        end
        local silverAmountStr = SumForBigNumberInt64(GET_TOTAL_MONEY_STR(),price);

        textremain:SetText('{img icon_item_silver 20 20} {ol}{s18}'..silverAmountStr)
        txtdiff:SetGravity(ui.CENTER_HORZ,ui.TOP)
        textremain:SetGravity(ui.CENTER_HORZ,ui.TOP)
    end,
    hookmsgImpl=function(self,frame,msg,argStr,argNum)
        
    end
}

UIMODEEXPERT = g
