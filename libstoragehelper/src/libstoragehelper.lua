local g={
    debug=false
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


function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end


local p={
    debug=false,
    target=IT_ACCOUNT_WAREHOUSE,
}
function p.init()
    packet.RequestItemList(p.target);
end
function p.get_exist_item_index(itemObj)
    local ret1 = false
    local ret2 = -1
    
    if geItemTable.IsStack(itemObj.ClassID) == 1 then
        local itemList = session.GetEtcItemList(p.target);    
        local sortedGuidList = itemList:GetGuidList();    
        local sortedCnt = sortedGuidList:Count();
        
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid)
            local invItem_obj = GetIES(invItem:GetObject());
            if itemObj.ClassID == invItem_obj.ClassID then
                ret1 = true
                ret2 = invItem.invIndex 
                break
            end
        end
        return ret1, ret2
    else
        return false, -1
    end
end
function p.get_valid_index()
    local itemList = session.GetEtcItemList(p.target);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetGuidList();
    local sortedCnt = sortedGuidList:Count();
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local start_index = 0
    local last_index = p.storagesize() - 1
    local itemCnt = 0;
    local guidList = itemList:GetGuidList();
    local cnt = guidList:Count();
    local offset=0
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = itemList:GetItemByGuid(guid);
        local obj = GetIES(invItem:GetObject());
        if obj.ClassName ~= MONEY_NAME and invItem.invIndex < p.getcountpertab() then
            itemCnt = itemCnt + 1;
        end
    end
    local __set = {}
    local inc = 0
    local money_offset = 0
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        
        if obj.ClassName ~= MONEY_NAME then
            if(  __set[invItem.invIndex])then
                DBGOUT("duplicate "..tostring(invItem.invIndex))
            end
            __set[invItem.invIndex] = {item = invItem, obj = obj, mode = 1}

        
        else
            
            DBGOUT("money "..tostring(invItem.invIndex))
            
            --__set[invItem.invIndex] = {item = invItem, obj = obj, mode = 2}
            money_offset=1
        end
    end
    local first=0
    for i=0,slotCount do
        if(__set[i]~=nil)then
            first=first+1
        end
    end
    if(p.target==IT_ACCOUNT_WAREHOUSE)then
        -- -1 is preventaion tos bug
        DBGOUT(string.format("prevent %d/%d",first,slotCount-1))
        if(first>=(slotCount-1))then
            
            for i=0,p.getcountpertab()-1 do
                __set[i] ={mode=1}
            end
        end
        --prevent tos bug
        for i=1,p.gettabcount() do
            local count=0
            for j=p.getcountpertab()*i,p.getcountpertab()*(i+1)-1 do
                if(__set[j]~=nil)then
                    count=count+1
        
                end
            end
            DBGOUT(string.format("tab %d items %d/%d",i,count,(p.getcountpertab()-1)))
            if(count>=(p.getcountpertab()-1))then
                for j=p.getcountpertab()*i,p.getcountpertab()*(i+1)-1 do
                    __set[j] ={mode=1}
                end
            end
        end
    end

    local index = start_index
    
    for k=start_index,last_index+1 do
        index = k
        if __set[k] == nil then
            offset=offset-1
            if(offset<=0)then
                break
            end
        end
    end
    
    DBGOUT("idx" .. index)
    return index
end

function p.gettabcount()
    if (true == session.loginInfo.IsPremiumState(ITEM_TOKEN)) then
        return 5
       
    else
        return 1
       
    end
end

function p.getcountpertab()
    return 70
end
function p.getitemiter()
    local itemList=session.GetEtcItemList(p.target)
    local guidList = itemList:GetGuidList();
    local cnt = guidList:Count();
    local pos=0
    return  function()
            if(pos>=cnt)then
                return nil
            end
            local guid = guidList:Get(pos);
            pos=pos+1
            local invItem = itemList:GetItemByGuid(guid);
            local obj = GetIES(invItem:GetObject());
            return guid,invItem,obj
    end
end
function p.getinvitem(iesid)
  
    return  session.GetEtcItemByGuid(p.target, iesid)
 
end

--- gets storage size.
--- reduced one for each tab from the actual for preventation tos bug.
function p.storagesize()
    if(p.target==IT_ACCOUNT_WAREHOUSE)then
        local account = session.barrack.GetMyAccount();
        local slotCount = account:GetAccountWarehouseSlotCount();
        
        return (slotCount-1) + (p.gettabcount() - 1) * (p.getcountpertab()-1)
    elseif(p.target==IT_WAREHOUSE)then
        local etc = GetMyEtcObject();
        return etc.MaxWarehouseCount;
    end
end
--- gets storage size.
--- reduced one for each tab from the actual for preventation tos bug.
function p.storageremain() 
    return p.storagesize()-p.count()
end
function p.checkvalid(iesid,silent)
    local invItem=session.GetInvItemByGuid(iesid)
    local itemList = session.GetEtcItemList(p.target);  
    local obj = GetIES(invItem:GetObject())
    if p.storagesize() <= p.count() then
        if(not silent)then
            ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        end
        return;

    end
    if true == invItem.isLockState then
        if(not silent)then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
        end
        return;
    end
    
    local itemCls = GetClassByType("Item", obj.ClassID);
    if itemCls.ItemType == 'Quest' then
        if(not silent)then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        end
        return;
    end
    if(p.target==IT_ACCOUNT_WAREHOUSE)then
        local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
        if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
            if(not silent)then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
            end
            return;
        end
    end
    return true
end
---acquires invItem and invObj
function p.itemandobj(iesid)
    local invItem = session.GetInvItemByGuid(iesid)
    local invItem_obj = GetIES(invItem:GetObject());
    return invItem,invItem_obj
end
function p.aw()
    return ui.GetFrame("accountwarehouse")
end
function p.w()
    if(ui.GetFrame("warehouse"):IsVisible()==1)then
        return ui.GetFrame("warehouse")
    elseif (ui.GetFrame("camp_ui"):IsVisible()==1)then
        return  ui.GetFrame("camp_ui")
    end
    return nil
end
function p.frame()
    if(p.target==IT_ACCOUNT_WAREHOUSE)then

        return p.aw()
    elseif(p.target==IT_WAREHOUSE)then
        return p.w()
    end
end

-- put item
-- if count is nil,will use totalcount
-- return if succeeded true ,else false 
function p.putitem(iesid,count,slient)

    return EBI_try_catch{
        try=function()
            if(not p.checkvalid(iesid,slient))then

                return false
            end
        
            local invItem,invObj=p.itemandobj(iesid)
            if(p.target==IT_ACCOUNT_WAREHOUSE)then
            
        
                local ret, idx = p.get_exist_item_index(invObj)
            
                if (ret == false) then
        
                    idx = p.get_valid_index()
                end
                if(idx)then
                    item.PutItemToWarehouse(p.target, iesid, tostring(math.min(count or invItem.count,invItem.count)), p.frame():GetUserIValue("HANDLE"), idx)
                    return true
                end
            elseif(p.target==IT_WAREHOUSE)then
        
                item.PutItemToWarehouse(p.target, iesid, tostring(math.min(count or invItem.count,invItem.count)), p.frame():GetUserIValue("HANDLE"))
                return true
            end
        
        
            return false
        end,
        catch=function(e)
            ERROUT(e)
        end
    }
 
end
-- current item count
function p.count()
    local itemList = session.GetEtcItemList(p.target);
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();
    local rcnt=0
    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        if(invItem~=nil)then
            local invItem_obj = GetIES(invItem:GetObject());
            if invItem_obj.ClassName ~= MONEY_NAME then
                rcnt=rcnt+1
            end
        end
    end
    return rcnt
end
-- return bool,
-- get items
-- itemlist is list of item and count
-- such as 
-- {
--  {iesid="1514816461831",count=2},
--  {iesid="2488814315343",count=2}
-- }
-- if count is nil,will use totalcount
-- return if succeeded true ,else false 
-- if you will task from personal warehouse ,list length must be 1 and make sure sufficient silver.
function p.takeitems(itemlist)
    session.ResetItemList();
    local frame = p.frame();
    for _,v in ipairs(itemlist) do
        local invItem = session.GetEtcItemByGuid(p.target, v.iesid);
        local cnt = math.min(v.count or invItem.count,invItem.count)
    
    
        DBGOUT("TAKE")
        session.AddItemID( v.iesid, cnt);
    end
    item.TakeItemFromWarehouse_List(p.target, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
end
-- return bool,
-- get item for personal warehouse
-- if count is nil,will use totalcount
-- return if succeeded true ,else false 
function p.takeitem(iesid,count)

    local frame = p.frame();

    local invItem = session.GetEtcItemByGuid(p.target, iesid);
    local cnt = math.min(count or invItem.count,invItem.count)

    DBGOUT("TAKE")
    
    if(p.target==IT_ACCOUNT_WAREHOUSE)then
        session.ResetItemList();
        session.AddItemID(iesid, cnt);
        item.TakeItemFromWarehouse_List(p.target,session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
    else
        item.TakeItemFromWarehouse(p.target, iesid, cnt, frame:GetUserIValue("HANDLE"));
    end
end
--gets account money
--return amount of silver as string
function p.accountmoney()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY( { { Name = 'ClassName', Value = MONEY_NAME } }, false, itemList);
    local visItem = visItemList[1];
    if visItem == nil then
        return "0";
    end

    return visItem:GetAmountStr()
end
-- itemslist iterator
-- returns iesid,invItem,invObj
function p.items()
    local itemList = session.GetEtcItemList(p.target);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();    
    local sortedCnt = sortedGuidList:Count();    
    local i=0
    return function()
        while i<sortedCnt do
            local guid = sortedGuidList:Get(i)
            i=i+1
            local invItem = itemList:GetItemByGuid(guid)

            if invItem ~= nil then
                local obj = GetIES(invItem:GetObject());
                if obj.ClassName ~= MONEY_NAME  then
                    return guid,invItem,obj
                end
            end
          
        end
        return nil
    end
end

LIBSTORAGEHELPERV1_3=p

-- LIBSTORAGEHELPER=
--     LIBSTORAGEHELPER or 
--     LIBSTORAGEHELPERV1_0 or 
--     LIBSTORAGEHELPERV1_1 or
--     LIBSTORAGEHELPERV1_2
    