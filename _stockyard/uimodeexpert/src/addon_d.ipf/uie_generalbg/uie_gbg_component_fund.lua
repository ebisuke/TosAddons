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
    FLAG_PVPMINECOIN=0x02,
    FLAG_TP=0x04,
    FLAG_POPOCOIN=0x08,
    FLAG_ACCOUNTSILVER=0x10,
    FLAG_MARKETSOLDSILVER=0x20,

    FLAG_ALL=0xFFFFFFFF,
    new=function(parentgbg,name,flags,size)
        local self=inherit(g.gbg.uiegbgComponentFund,g.gbg.uiegbgComponentBase,parentgbg,name)
        self.flags=flags or g.gbg.uiegbgComponentFund.FLAG_SILVER
        self.size=size or 40
        return self
    end,
    initializeImpl=function(self,gbox)
        local y=0
        gbox:EnableScrollBar(0)
        local aObj = GetMyAccountObj()
        
        if (self.flags&g.gbg.uiegbgComponentFund.FLAG_SILVER)~=0 then
            local text=gbox:CreateOrGetControl('richtext','silver',0,y,100,0)
            local silverAmountStr = GET_TOTAL_MONEY_STR();
            text:SetText(string.format('{img icon_item_silver %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..silverAmountStr)
            y=y+text:GetHeight()
            text:SetTextTooltip('{ol}シルバー')
        end
        if (self.flags&g.gbg.uiegbgComponentFund.FLAG_ACCOUNTSILVER)~=0 then
            
            local silver = '?';
            local text=gbox:CreateOrGetControl('richtext','accountsilver',0,y,100,0)
            text:SetText(string.format('{img icon_item_silverbox1 %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..silver)
            local mapClassName = session.GetMapName();
            if mapClassName == "c_Klaipe" or mapClassName == "c_orsha" or mapClassName == "c_fedimian" then
                packet.RequestItemList(IT_ACCOUNT_WAREHOUSE);

            end
            text:SetTextTooltip('{ol}チーム倉庫シルバー(町中でのみ確認可能)')
            y=y+text:GetHeight()
        end
        if (self.flags&g.gbg.uiegbgComponentFund.FLAG_MARKETSOLDSILVER)~=0 then
            
            local silver = '?';
            local text=gbox:CreateOrGetControl('richtext','marketsilver',0,y,100,0)
            text:SetText(string.format('{img icon_item_nxpbox %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..silver)
            local mapClassName = session.GetMapName();
            if mapClassName == "c_Klaipe" or mapClassName == "c_orsha" or mapClassName == "c_fedimian" then
                market.ReqCabinetList();
            end
            text:SetTextTooltip('{ol}マーケット未回収売り上げ(町中でのみ確認可能)')
            y=y+text:GetHeight()
        end
        if (self.flags&g.gbg.uiegbgComponentFund.FLAG_PVPMINECOIN)~=0 then
            
            local count = TryGetProp(aObj,"MISC_PVP_MINE2", '0')
            if count == 'None' then
                count = '0'
            end
            local text=gbox:CreateOrGetControl('richtext','pvpmine',0,y,100,0)
            text:SetText(string.format('{img icon_item_pvpmine_2 %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..count)
            text:SetTextTooltip('{ol}傭兵団コイン')
            y=y+text:GetHeight()
        end
        if (self.flags&g.gbg.uiegbgComponentFund.FLAG_TP)~=0 then
            
           
            local text=gbox:CreateOrGetControl('richtext','tp',0,y,100,0)
            text:SetText(string.format('{img TP_pic %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..(aObj.PremiumMedal+aObj.GiftMedal) ..'+'.. aObj.GiftMedal)
            text:SetTextTooltip('{ol}TP (有料&イベント+無料)')
            y=y+text:GetHeight()
        end
        if (self.flags&g.gbg.uiegbgComponentFund.FLAG_POPOCOIN)~=0 then
            
            local pcBangPoint = session.pcBang.GetPCBangPoint();
            local text=gbox:CreateOrGetControl('richtext','popo',0,y,100,0)
            text:SetText(string.format('{img pcbang_point_icon %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..pcBangPoint)
            text:SetTextTooltip('{ol}POPO Point')
            y=y+text:GetHeight()
        end
 
    end,
    hookmsgImpl=function(self,frame,msg,argStr,argNum)
        if msg=='ACCOUNT_WAREHOUSE_ITEM_LIST' or  msg=='ACCOUNT_WAREHOUSE_VIS' then
            if (self.flags&g.gbg.uiegbgComponentFund.FLAG_ACCOUNTSILVER)~=0 then
                local text=self.gbox:GetChild('accountsilver')
                local silver = '?';
                local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
                local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY( { { Name = 'ClassName', Value = MONEY_NAME } }, false, itemList);
                local visItem = visItemList[1];
                text:SetText(string.format('{img icon_item_silverbox1 %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..visItem:GetAmountStr())
            end
        end
        if msg=='CABINET_ITEM_LIST' then
            if (self.flags&g.gbg.uiegbgComponentFund.FLAG_MARKETSOLDSILVER)~=0 then
                local text=self.gbox:GetChild('marketsilver')
                local silver = '0';
                local cnt = session.market.GetCabinetItemCount();        
                for i = 0 , cnt - 1 do
                    local cabinetItem = session.market.GetCabinetItemByIndex(i);
                    local itemID = cabinetItem:GetItemID();   
                    local itemObj = GetIES(cabinetItem:GetObject()); 
                    local whereFrom = cabinetItem:GetWhereFrom();   
                    if itemObj.ClassName == MONEY_NAME then
                        silver=SumForBigNumberInt64(silver,cabinetItem:GetCount())
                    end
                end
                
                text:SetText(string.format('{img icon_item_nxpbox %d %d} {ol}{s%d}',self.size,self.size,math.ceil(self.size*3/4))..silver)
            end
        end
    end
}

UIMODEEXPERT = g
