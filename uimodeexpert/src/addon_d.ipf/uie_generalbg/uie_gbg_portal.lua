--uie_gbg_portal


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

g.gbg.uiegbgPortal={
    new=function(frame,name,caption)
        local self=inherit(g.gbg.uiegbgPortal,g.gbg.uiegbgBase,frame,name,caption or g.tr('portalshop') )
        return self
    end,
    initializeImpl=function(self,gbox)

     
        local zeny=g.gbg.uiegbgComponentFund.new(self,'fund')
        zeny:initialize(gbox:GetWidth()-260,20,200,40)
        self:addComponent(zeny)

        local pframe = ui.GetFrame('portal_seller');
        local groupName = pframe:GetUserValue('GroupName');
        local itemCount = session.autoSeller.GetCount(groupName);
        for i = 0, itemCount - 1 do
            local itemInfo = session.autoSeller.GetByIndex(groupName, i);
            local propValue = itemInfo:GetArgStr();
            local portalInfoList = StringSplit(propValue, "@"); -- portalPos@openedTime
            local portalPosList = StringSplit(portalInfoList[1], "#"); -- zoneName#x#y#z
    
            -- name
            local pc = GetMyPCObject();
            local mapName = portalPosList[1];
            local mapCls = GetClass('Map', mapName);
            local x, y, z = portalPosList[2], portalPosList[3], portalPosList[4];
            local isValid = ui.IsImageExist(mapName);
            if isValid == false then
                world.PreloadMinimap(mapName);
            end
            local w=(gbox:GetWidth()-100)/itemCount
            local ww=350
            local h=600
            local ingbox=gbox:CreateOrGetControl('groupbox','gboxportal'..i,w*(i-1)+gbox:GetWidth()/2-ww/2,50,ww,h);
            AUTO_CAST(ingbox)
            local title=ingbox:CreateOrGetControl('richtext','title',10,10,ww-20,60)
            title:SetText('{ol}{s32}'..mapCls.Name)
            local map=ingbox:CreateOrGetControl('picture','map',10,10+60,300,300)
            AUTO_CAST(map)
            map:SetImage(mapName)
            map:SetEnableStretch(1)

            local mark=ingbox:CreateOrGetControl('picture','mark',10,10+60,40,40)
            AUTO_CAST(mark)
            mark:SetImage('trasuremapmark')
            mark:SetEnableStretch(1)
            local mapprop = geMapTable.GetMapProp(mapName);
            local mapPos = mapprop:WorldPosToMinimapPos(x, z, map:GetWidth(), map:GetHeight());
            mark:SetOffset(10-mark:GetWidth()/2+mapPos.x,10+60-mark:GetHeight()/2+mapPos.y)
            local price=ingbox:CreateOrGetControl('button','price',10,10+60+300,ww-20,60)
            local itemName, cnt = ITEMBUFF_NEEDITEM_Sage_PortalShop(pc, mapName);
            local cost = cnt * itemInfo.price;     
            price:SetText(g.util.generateSilverString(cost,40))
            price:SetEventScript(ui.LBUTTONUP,'UIE_GBG_PORTAL_LCLICK')
            price:SetEventScriptArgNumber(ui.LBUTTONUP,i)
            
        end
    end,
    defaultHandlerImpl = function(self, key, frame)
     
        return g.uieHandlergbgComponentTracer.new(key, frame, self)
    end,
}
function UIE_GBG_PORTAL_LCLICK(frame,ctrl,argstr,argnum)
    local pframe = ui.GetFrame('portal_seller');
    local groupName = pframe:GetUserValue('GroupName');
    local handle = pframe:GetUserIValue('HANDLE');
    local sellType = pframe:GetUserIValue('SELL_TYPE');
    local index = argnum
    session.autoSeller.Buy(handle, index, 1, sellType)
end
-- g.gbg.uiegbgComponentPortal = {
--     new = function(parentgbg, name, selectcallback)
--         local self = inherit(g.gbg.uiegbgComponentPortal, g.gbg.uiegbgComponentBase, parentgbg, name)
--         self.selectcallback = selectcallback
--         return self
--     end,
--     initializeImpl=function(self,gbox)

        

--     end,
-- }
UIMODEEXPERT = g
