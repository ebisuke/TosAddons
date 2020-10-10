--uie_gbg_component_market_category_search
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
-- market.lua
local marketCategorySortCriteria = { -- 숫자가 작은 순서로 나오고, 없는 애들은 밑에 감
	Weapon = 1,
	Armor = 2,
	Consume = 3,
	Accessory = 4,
	Recipe = 5,
	Card = 6,
	Misc = 7,
	Gem = 8,
};
local function SORT_CATEGORY(categoryList, sortFunc)
	table.sort(categoryList, sortFunc);
	return categoryList;
end

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT
g.gbg = g.gbg or {}


g.gbg.uiegbgComponentMarketSearch = {
    new = function( parentgbg, name,onselected)
        local self = inherit(g.gbg.uiegbgComponentMarketSearch, g.gbg.uiegbgComponentBase, parentgbg, name)
        self._category={}
        self._activecategory='root'
        self._onselected=onselected
        return self
    end,
    initializeImpl = function(self, gbox)
        g.gbg.uiegbgComponentBase.initializeImpl(self, gbox)
        gbox:SetUserValue('gbg_intrusive',1)
        gbox:SetScrollBar(0)
        gbox:InvalidateScrollBar()
        self._category=self:generateCategory(self._category,'root',0)
      
        self:refreshCategoryButton()
        
    end,
    refreshCategoryButton=function(self)
        local gbox=self.gbox
        local oy=0
        gbox:RemoveAllChild()
        for k,v in ipairs( self._category) do
            local btn=gbox:CreateOrGetControl('button','btn'..v.name..k,v.level*20,oy,gbox:GetWidth()-v.level*20-20,40)
            if v.name==self._activecategory then
                btn:SetText(string.format('{ol}{s%d}{#FF7777}',32-v.level*4)..v.caption)
            else
                btn:SetText(string.format('{ol}{s%d}',28-v.level*4)..v.caption)
            end
           
            btn:SetEventScript(ui.LBUTTONUP,'UIE_GBG_COMPONENT_MARKET_SEARCH_LCLICK')
            btn:SetEventScriptArgNumber(ui.LBUTTONUP,k)
            btn:SetEventScriptArgString(ui.LBUTTONUP,self.name)
            oy=oy+40
        end
    end,
    generateCategory=function(self,tbl,parent,level)
        parent=parent or 'root'
        local categoryList = SORT_CATEGORY(GetMarketCategoryList(parent), function(lhs, rhs)
			local lhsValue = marketCategorySortCriteria[lhs];
			local rhsValue = marketCategorySortCriteria[rhs];
			
			if lhsValue == nil then
				lhsValue = 200000000;				
			end
			if rhsValue == nil then
				rhsValue = 200000000;				
			end

			return lhsValue < rhsValue;
        end);
        if level==0 then
            --local group='IntegrateRetreive'
            --local elem={name=group,caption= ClMsg(group),parent=parent,level=level,isopen=false}
            --table.insert(tbl,elem)
        end
        for i = 1, #categoryList do
            local group
            
             group = categoryList[i];
            if group and not g.util.isNilOrNoneOrWhitespace(group) then
                local elem={name=group,caption= ClMsg(group),parent=parent,level=level,isopen=false}
                table.insert(tbl,elem)
  
                self:generateCategory(tbl,group,level+1)
                
            end
        end
        return tbl

    end,

    defaultHandlerImpl = function(self, key, frame)

        return g.uieHandlergbgComponentTracer.new(key, frame, self)
    end,
    
  
}
function UIE_GBG_COMPONENT_MARKET_SEARCH_LCLICK(frame,ctrl,argstr,argnum)
    EBI_try_catch{
        try = function()
            local self=g.gbg.getComponentInstanceByName(argstr)
            local cat=self._category[argnum]
            self._activecategory=cat.name
            
            if self._onselected then
                self._onselected(self,cat)
            end
            self:refreshCategoryButton()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
UIMODEEXPERT = g