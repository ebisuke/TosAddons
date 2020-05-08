--fps
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
g.debug = false
g.needtoopen = false
g.portals = {}
g.delay = 3
g.itemcount = 0
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


g.location = g.location or nil
g.framename = "findportalshop"
g.inspecting = false
g.gid = g.gid or nil
g.tgt = {}
g.inc = 1
g.sz = {}
function FINDPORTALSHOP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            g.frame = ui.GetFrame("findportalshop");
            frame = g.frame
            frame:ShowWindow(0)
            acutil.slashCommand("/fpsf", FINDPORTALSHOP_PROCESS_COMMAND);
            if OLD_MAP_OPEN == nil then
                OLD_MAP_OPEN = MAP_OPEN
                MAP_OPEN = FINDPORTALSHOP_MAP_OPEN_JUMPER
            end
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            
            timer:SetUpdateScript("FINDPORTALSHOP_ON_TIMER");
            timer:EnableHideUpdate(1)
            timer:Start(0.5);
            --frame:ShowWindow(1)
            acutil.setupHook(FINDPORTALSHOP_PORTAL_SELLER_OPEN_UI, "PORTAL_SELLER_OPEN_UI")
            acutil.setupHook(FINDPORTALSHOP_BUFFSELLER_OPEN, "BUFFSELLER_OPEN")
            
            acutil.addSysIcon('findportalshop', 'sysmenu_sys', 'findportalshop', 'FINDPORTALSHOP_TOGGLE')
            FINDPORTALSHOP_VIEWINIT()
            FINDPORTALSHOP_INIT()
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end

function FINDPORTALSHOP_MAP_OPEN_JUMPER(frame)
    if OLD_MAP_OPEN ~= nil then
        OLD_MAP_OPEN(frame)
    end
    FINDPORTALSHOP_MAP_OPEN(frame)
end

function FINDPORTALSHOP_MAP_OPEN(frame)
    EBI_try_catch{
        try = function()
        
        
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function FINDPORTALSHOP_TOGGLE()
    EBI_try_catch{
        try = function()
            ui.ToggleFrame("findportalshop")
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
            print(error)
        end
    }
end
function FINDPORTALSHOP_LISTING()
    EBI_try_catch{
        try = function()
            if (not g.inspecting) then
                g.inspecting = true

                g.tgt={}
                g.inc=1
                DBGOUT("go")
                --比較的遠くまでのポータルショップを探す
                local objList, objCount = SelectObject(GetMyPCObject(), 400, 'ALL', 1)
                local portals = {}
                portals = {name = "", title = "", pchandle = 0, mapname = nil, position = nil}
                portals = {}
                local delay = 0
                g.sz.w = ui.GetFrame("portal_seller"):GetWidth()
                g.sz.h = ui.GetFrame("portal_seller"):GetHeight()
                g.sz.x = ui.GetFrame("portal_seller"):GetX()
                g.sz.y = ui.GetFrame("portal_seller"):GetY()
                
                --ui.GetFrame("portal_seller"):Resize(1, 1)
                ui.GetFrame("portal_seller"):SetOffset(-2000, 0)
                
                --ポタ屋を検索
                for i = 1, objCount do
                    local itm = objList[i];
                    local hnd = GetHandle(itm);
                    if (hnd) then
                        local tgt = info.GetTargetInfo(hnd);
                        local actor = world.GetActor(hnd)
                        if (itm.ClassName == "PC") and (tgt.IsDummyPC == 1) then
                            --ダミーPC
                            --グループ名取得
                            --local actr = world.GetActor(hnd);
                            local groupname = info.GetFamilyName(hnd);
                            
                            if (groupname ~= nil) then
                                --DBGOUT(tostring(groupname))
                                --ショップの情報を仕入れる
                                --ポタ屋
                             
                                local sellBalloon = ui.GetFrame("SELL_BALLOON_" .. actor:GetHandleVal());
                                local text = sellBalloon:GetTextByKey("Text")
                                local tt = sellBalloon:GetChild("text");
                                local val=tt:GetTextByKey("value");
                                local sellType
                                if sellBalloon ~= nil then
                                    sellType = sellBalloon:GetUserIValue("SELL_TYPE");
                                --session.autoSeller.RequestOpenShop(actor:GetHandleVal(), sellType);
                                end
                                if (sellType == AUTO_SELL_PORTAL) then
                                    
                                    g.tgt[#g.tgt + 1] = {
                                        handle = actor:GetHandleVal(),
                                        teamname =  info.GetFamilyName(actor:GetHandleVal()),
                                        title = val
                                    }
                                    DBGOUT("portal")
                                
                                -- ReserveScript(string.format("session.autoSeller.RequestOpenShop(%d,AUTO_SELL_PORTAL)", actor:GetHandleVal()), delay)
                                -- ReserveScript(string.format("FINDPORTALSHOP_INSPECT_RESULT('%s')", "Portal"), delay + 4)
                                -- delay = delay + 6
                                end
                            
                            end
                        end
                    end
                end
            
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function FINDPORTALSHOP_PORTAL_SELLER_OPEN_UI(groupName, sellType, handle)
    EBI_try_catch{
        try = function()
            if (g.inspecting) then
                ui.GetFrame("portal_seller"):SetOffset(-2000, 0)
            --PORTAL_SELLER_OPEN_UI_OLD(groupName, sellType, handle)
            else
                DBGOUT("ended")
                FINDPORTALSHOP_FIX()
                
                PORTAL_SELLER_OPEN_UI_OLD(groupName, sellType, handle)
                
                
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_CLOSE()
    ui.GetFrame("findportalshop"):ShowWindow(0);
end
function FINDPORTALSHOP_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local adv = frame:GetChildRecursively("adv")
            AUTO_CAST(adv)
            frame:Resize(1200,800)
            frame:SetColorTone("77777777")
            frame:SetLayerLevel(50)
            frame:SetSkinName("chat_window_2")
            adv:Resize(frame:GetWidth(),frame:GetHeight()-adv:GetY())
            adv:EnableAutoResize(false, true)
            
            adv:SetGravity(ui.LEFT, ui.TOP)
            adv:SetOffset(0, 100)
            adv:SetStartRow(1);	
            adv:SetColWidth(0,200)
            adv:SetColWidth(1,300)
            adv:SetColWidth(2,200)
            adv:SetColWidth(3,200)
            adv:SetColWidth(4,200)
            adv:SetColWidth(5,200)
            adv:SetColWidth(6,100)

            adv:Resize(frame:GetWidth() - 10, frame:GetHeight() - 200)
            adv:SetSkinName("bg2")
            adv:SetEventScript(ui.LBUTTONUP, "FINDPORTALSHOP_LBTN")
            adv:SetEventScript(ui.RBUTTONUP, "FINDPORTALSHOP_RBTN")
            
            local btn = frame:CreateOrGetControl("button", "btnrefresh", 20, 70, 100, 30)
            btn:SetText("{ol}Refresh")
            btn:SetEventScript(ui.LBUTTONUP, "FINDPORTALSHOP_REFRESH")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_LBTN()
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame(g.framename)
            
            local adv = frame:GetChildRecursively("adv")
            local key = adv:GetObjectXY(tonumber(adv:GetSelectedKey())+1, 5):GetText()
            local handle = tonumber(adv:GetObjectXY(tonumber(adv:GetSelectedKey())+1, 6):GetText())
            local actor=world.GetActor(handle)
            if(actor)then
                local fndList, fndCount = SelectObject(GetMyActor(), 400, 'ALL');
                for i = 1, fndCount do
                    local actor = world.GetActor(GetHandle(fndList[i]));
                    local hnd =GetHandle(fndList[i])
                    local targetInfo= info.GetTargetInfo(hnd);
                
                    if(targetInfo.IsDummyPC==1)then
                        if(hnd~=handle)then
                            actor:SetAuraInfo("None");
                        else
                            actor:SetAuraInfo("EliteBuff");
                            DBGOUT("aura")
                        end
                    end
                    
                end
                local self=GetMyActor()
                local pos=actor:GetPos()
                --self:ActorJump(10, 0);
                --geMCC.MoveTo(actor, enemy:GetPos());
                local dist=info.GetDestPosDistance(pos.x, pos.y, pos.z, session.GetMyHandle());
                direct.MoveToTarget(self:GetHandleVal(), handle, 10, 33);
                --self:MoveMathPoint(pos.x, pos.y, pos.z, 0.1*dist, 1.0);
                --self:RotateToTarget(actor, 0.0);
                --actor:GetAnimation():PlayFixAnim('WALK', 0.1*dist,0)
            end
            DBGOUT(key)
            --SLM(key)
            local frame = ui.GetFrame(g.framename)
            
            --frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_RBTN()
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame(g.framename)
            
            local adv = frame:GetChildRecursively("adv")
            local key = adv:GetObjectXY(tonumber(adv:GetSelectedKey())+1, 5):GetText()
            local handle = tonumber(adv:GetObjectXY(tonumber(adv:GetSelectedKey())+1, 6):GetText())
            local actor=world.GetActor(handle)
            
            DBGOUT(key)
            SLM(key)
            local frame = ui.GetFrame(g.framename)
            
            --frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_INSPECT_RESULT(groupname, kanban, teamname, handle)
    EBI_try_catch{
        try = function()
            
            
            
            local itemCount = session.autoSeller.GetCount(groupname);
            DBGOUT("cnt" .. tostring(itemCount))
            local portals = {}
            for i = 0, itemCount - 1 do
                local itemInfo = session.autoSeller.GetByIndex(groupname, i);
                local propValue = itemInfo:GetArgStr();
                local portalInfoList = StringSplit(propValue, "@"); -- portalPos@openedTime
                local portalPosList = StringSplit(portalInfoList[1], "#"); -- zoneName#x#y#z
                local mapName = portalPosList[1];
                local mapCls = GetClass('Map', mapName);
                
                local x, y, z = portalPosList[2], portalPosList[3], portalPosList[4];
                
                local isValid = ui.IsImageExist(mapName);
                if isValid == false then
                    world.PreloadMinimap(mapName);
                end
                local mapprop = geMapTable.GetMapProp(mapName);
                --local mapPos = mapprop:WorldPosToMinimapPos(x, z, pic:GetWidth(), pic:GetHeight());
                local mapCls = GetClass('Map', mapName)
                portals[#portals + 1] = {
                    Name = mapCls.Name
                }
            end
            local actor = world.GetActor(handle)
            FINDPORTALSHOP_ADD(teamname, kanban, portals,
                {
                    Handle=actor:GetHandleVal(),
                    Name = session.GetMapName(),
                    x = actor:GetPos().x,
                    z = actor:GetPos().z
                })
            g.inc = g.inc + 1
            session.autoSeller.Close("Portal");

            ui.GetFrame("portal_seller"):ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_REFRESH()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            FINDPORTALSHOP_FIX()
            FINDPORTALSHOP_CLEAR()
            FINDPORTALSHOP_LISTING()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = "usage{nl}/fpsf 地点の名前"
        return ui.MsgBox(msg, "", "Nope")
    end
    
    g.finding = cmd
    DBGOUT("COMMAND SUCCESS")
end

function FINDPORTALSHOP_ON_TIMER()
    EBI_try_catch{
        try = function()
            
            if (g.inspecting) then
                DBGOUT("do")
                if (#g.tgt >= g.inc) then
                    local v = g.tgt[g.inc]
                    if(v)then
                      
                        if(v.handle)then
                            session.SetMyPageOwnerHandle(v.handle)
                            session.autoSeller.RequestOpenShop(v.handle, AUTO_SELL_PORTAL)
                            ReserveScript(string.format("FINDPORTALSHOP_INSPECT_RESULT('%s','%s','%s',%d)", "Portal",  v.title,v.teamname, v.handle), 0.25)
                        end
                        
                    end
                else
                    DBGOUT("end" .. tostring(#g.tgt) .. "/" .. tostring(g.inc))
                    g.inspecting = false
                    g.inc = 1
                    FINDPORTALSHOP_FIX()
                    
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_BUFFSELLER_OPEN(parent, ctrl)
    
    BUFFSELLER_OPEN_OLD(parent, ctrl)
end
function FINDPORTALSHOP_FIX()
    EBI_try_catch{
        try = function()
            
            ui.GetFrame("portal_seller"):Resize(450, 1200)
            ui.GetFrame("portal_seller"):SetOffset(0, 0)
            DBGOUT("fix")
            --g.inc = 1
            --g.inspecting = false
            --g.tgt = {}
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function FINDPORTALSHOP_VIEWINIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("findportalshop")
            local adv = frame:GetChildRecursively("adv")
            AUTO_CAST(adv)
            adv:SetSkinName("bg2")
            adv:EnableAutoResize(false, true)
            adv:ClearUserItems()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FINDPORTALSHOP_CLEAR()
    local frame = ui.GetFrame("findportalshop")
    local adv = frame:GetChildRecursively("adv")
    AUTO_CAST(adv)
    --adv:RemoveAllChild()    
    adv:ClearUserItems()
    g.itemcount = 0
end
function FINDPORTALSHOP_ADD(groupname, kanban, portals, map)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local adv = frame:GetChildRecursively("adv")
            AUTO_CAST(adv)
            local o = g.itemcount * 20 + 20
            local x = 0
            local item = adv:SetItem(g.itemcount, 0, groupname, "white_16_ol")
            item:Resize(adv:GetColWidth(0), item:GetHeight())
            item:SetOffset(x, o)
            x = x + adv:GetColWidth(0)
            local item = adv:SetItem(g.itemcount, 1, kanban, "white_16_ol")
            item:Resize(adv:GetColWidth(1), item:GetHeight())
            item:SetOffset(x, o)
            x = x + adv:GetColWidth(1)
            for i = 1, 3 do
                if (portals[i] ~= nil) then
                    item = adv:SetItem(g.itemcount, i + 1, portals[i].Name, "white_16_ol")
                    item:Resize(adv:GetColWidth(i + 1), item:GetHeight())
                    item:SetOffset(x, o)
                
                end
                x = x + adv:GetColWidth(i + 1)
            end
            local mapprop = geMapTable.GetMapProp(map.Name);
            local str=string.format("%d#%d#%d", mapprop.type,map.x, map.z);	
            local item = adv:SetItem(g.itemcount, 5,str)
            item:Resize(adv:GetColWidth(5), item:GetHeight())
            item:SetOffset(x, o)
            x = x + adv:GetColWidth(5)
            local item = adv:SetItem(g.itemcount, 6,tostring(map.Handle))
            item:Resize(adv:GetColWidth(6), item:GetHeight())
            item:SetOffset(x, o)
            x = x + adv:GetColWidth(6)
            g.itemcount = g.itemcount + 1
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
