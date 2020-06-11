--cubeopener
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

local function startswith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
local acutil = require('acutil')
local g = {}
local whitelist={
    [640475]=true,
}
g.debug = false
g.framename="cubeopener"
g.total=nil
g.openitem=nil

local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
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




-- ライブラリ読み込み
function CUBEOPENER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            local timer = GET_CHILD(ui.GetFrame("cubeopener"), "addontimer", "ui::CAddOnTimer");
            acutil.setupHook(CUBEOPENER_INVENTORY_RBDC_ITEMUSE_JUMPER, "INVENTORY_RBDC_ITEMUSE")
            acutil.setupHook(CUBEOPENER_OPEN_TRADE_SELECT_ITEM_JUMPER, "OPEN_TRADE_SELECT_ITEM")
            acutil.setupHook(CUBEOPENER_REQUEST_TRADE_ITEM_JUMPER, "REQUEST_TRADE_ITEM")
            acutil.setupHook(CUBEOPENER_CANCEL_TRADE_ITEM_JUMPER, "CANCEL_TRADE_ITEM")
    
            frame:ShowWindow(1)
        end,
        catch = function(error)
            DBGOUT(error)
        end
    }
end
function CUBEOPENER_REQUEST_TRADE_ITEM_JUMPER(frame, ctrl, argStr, argNum)
    DBGOUT("REQ")
    if(g.openitem==nil)then
        if(not REQUEST_TRADE_ITEM_OLD(frame, ctrl, argStr, argNum))then
            --fail
            g.total=nil
            g.openitem=nil
        end
    else
        CUBEOPENER_REQUEST_TRADE_ITEM(frame, ctrl, argStr, argNum)
    end
end
function CUBEOPENER_CANCEL_TRADE_ITEM_JUMPER(frame, ctrl, argStr, argNum)
    CANCEL_TRADE_ITEM_OLD(frame, ctrl, argStr, argNum)
    CUBEOPENER_CANCEL_TRADE_ITEM(frame, ctrl, argStr, argNum)
end
function CUBEOPENER_CANCEL_TRADE_ITEM(frame, ctrl, argStr, argNum)
    g.total=nil
    g.openitem=nil
    DBGOUT("CANCEL TRADE")
end
function CUBEOPENER_REQUEST_TRADE_ITEM(frame, ctrl, argStr, argNum)
    local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
    DBGOUT("REQUEST TRADE")
	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s#%d", itemGuid, selected);
		DBGOUT("selectExist")
        for i=1,g.total do
    	    ReserveScript(string.format("pc.ReqExecuteTx('SCR_TX_TRADE_SELECT_ITEM','%s' );",argStr),0.5*i)
        end
        g.total=nil
        g.openitem=nil
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end
function CUBEOPENER_INVENTORY_RBDC_ITEMUSE_JUMPER(frame, object, argStr, argNum)
    if (not CUBEOPENER_INVENTORY_RBDC_ITEMUSE(frame, object, argStr, argNum)) then
        INVENTORY_RBDC_ITEMUSE_OLD(frame, object, argStr, argNum)
    end
end
function CUBEOPENER_OPEN_TRADE_SELECT_ITEM_JUMPER(invItem)
  
    OPEN_TRADE_SELECT_ITEM_OLD(invItem)
    CUBEOPENER_OPEN_TRADE_SELECT_ITEM(invItem)
end
function CUBEOPENER_OPEN_TRADE_SELECT_ITEM(invItem)
    DBGOUT("OPEN TRADE")
end
function CUBEOPENER_INVENTORY_RBDC_ITEMUSE(frame, object, argStr, argNum)
    return EBI_try_catch{
        try = function()
            
            
            local invitem = GET_SLOT_ITEM(object);
            if invitem == nil then
                return;
            end
            
            local itemobj = GetIES(invitem:GetObject());
          
                --ensure
                if nil == invitem then
                    return;
                end
               
                --それはキューブ？
                local groupName = itemobj.GroupName;
                DBGOUT(groupName)
                local itemtype = invitem.type;
                if(groupName=="Cube" or groupName=="Event" or whitelist[itemtype])then
                        
                    if true == invitem.isLockState then
                        ui.SysMsg(ClMsg("MaterialItemIsLock"));
                        return true;
                    end
                
                    --ここでイベントキューブを開く
                    --if true == RUN_CLIENT_SCP(invitem) then
                    --    return true;
                    --end
                    
                    local stat = info.GetStat(session.GetMyHandle());		
                    if stat.HP <= 0 then
                        return true;
                    end
                    
                    
                    local curTime = item.GetCoolDown(itemtype);
                    if curTime ~= 0 then
                        imcSound.PlaySoundEvent("skill_cooltime");
                        return true;
                    end
                    if(whitelist[itemtype])then
                        if keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1 then

                            --再開封可能
                            g.openitem=invitem
                            INPUT_NUMBER_BOX(ui.GetFrame(g.framename), '消費キューブいくつ開きますか？', 'CUBEOPENER_CONSUMEOPEN', invitem.count, 1, invitem.count, nil, nil, 1)
                            return true
                        else
                            return false
                        end

                    elseif(groupName=="Cube")then
                        local rerollPrice =TryGet(itemobj, "NumberArg1")
                        if(rerollPrice==0 or not rerollPrice )then
                            if keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1 then

                                --再開封可能
                                g.openitem=invitem
                                INPUT_NUMBER_BOX(ui.GetFrame(g.framename), 'キューブいくつ開きますか？', 'CUBEOPENER_CUBEOPEN', invitem.count, 1, invitem.count, nil, nil, 1)
                                return true
                            else
                                return false
                            end
                        end
                    elseif(groupName=="Event")then
                        --再開封可能
                        if keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1 then
                            if(itemobj.ClientScp=="None")then
                                --キューブ仕様
                                g.openitem=invitem
                                INPUT_NUMBER_BOX(ui.GetFrame(g.framename), 'イベントキューブいくつ開きますか？', 'CUBEOPENER_CUBEOPEN', invitem.count, 1, invitem.count, nil, nil, 1)
                                return true
                            else

                                g.openitem=invitem
                                INPUT_NUMBER_BOX(ui.GetFrame(g.framename), 'イベントアイテムいくつ開きますか？', 'CUBEOPENER_EVENTOPEN',  invitem.count, 1, invitem.count, nil, nil, 1)
                                return true
                            end
                        --use
                        else
                            g.openitem=nil
                            return false
                        end 
                    end
                end
                
                
                
                
                return false;
         
        end,
        catch = function(error)
            DBGOUT(error)
        end
    }
end
function CUBEOPENER_EVENTOPEN(frame, cnt)

    g.total=cnt
    INV_ICON_USE(g.openitem)
end

function CUBEOPENER_CONSUMEOPEN(frame, cnt)
    g.total=cnt
    INV_ICON_USE(g.openitem)
end
function CUBEOPENER_CUBEOPEN(frame, cnt)
    local delay=0.01
    for i=1,cnt do

        delay=delay+0.5
   
        ReserveScript(string.format("CUBEOPENER_INVICONUSE('%s');",g.openitem:GetIESID()),delay)
        
    end
    g.openitem=nil
end
function CUBEOPENER_INVICONUSE(iesid)
    DBGOUT("CHAIN")
    local invItem=session.GetInvItemByGuid(iesid)
    INV_ICON_USE(invItem)
end