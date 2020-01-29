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

local acutil = require('acutil')
local g = g or {}

g.location = g.location or nil
g.debug = true
g.finding = true
function FINDPORTALSHOP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame("findportalshop");
            frame:ShowWindow(0)
            acutil.slashCommand("/fpsf", FINDPORTALSHOP_PROCESS_COMMAND);
            if OLD_MAP_OPEN == nil then
                OLD_MAP_OPEN = MAP_OPEN
                MAP_OPEN = FINDPORTALSHOP_MAP_OPEN_JUMPER
            end
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            
            timer:SetUpdateScript("FINDPORTALSHOP_ON_TIMER");
            timer:Start(3);
            frame:ShowWindow(1)
        --acutil.addSysIcon('findportalshop', 'sysmenu_sys', 'findportalshop', 'FINDPORTALSHOP_TOGGLE')
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
            ui.GetFrame("map"):ShowWindow(0)
            local frame = ui.GetFrame("findportalshop");
            frame:ShowWindow(1)
            FINDPORTALSHOP_LISTING()
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
            if (g.finding) then
                --比較的遠くまでのポータルショップを探す
                local objList, objCount = SelectObject(GetMyPCObject(), 400, 'ALL', 1)
                local portals = {}
                portals = {name = "", title = "", pchandle = 0, mapname = nil, position = nil}
                portals = {}
                --ポタ屋を検索
                for i = 1, objCount do
                    local itm = objList[i];
                    local hnd = GetHandle(itm);
                    if (hnd) then
                        local tgt = info.GetTargetInfo(hnd);
                        local actor=world.GetActor(hnd)
                        if (itm.ClassName == "PC") and (tgt.IsDummyPC == 1) then
                            --ダミーPC
                            --グループ名取得
                            --local actr = world.GetActor(hnd);
                            local groupname = info.GetFamilyName(hnd);
                            DBGOUT(tostring(groupname))
                            if (groupname ~= nil) then
                                --ショップの情報を仕入れる
                                --ポタ屋
                                session.SetMyPageOwnerHandle(hnd)
                                local sellBalloon = ui.GetFrame("SELL_BALLOON_" .. actor:GetHandleVal());
                                if sellBalloon ~= nil then
                                    local sellType = sellBalloon:GetUserIValue("SELL_TYPE");
                                    session.autoSeller.RequestOpenShop(actor:GetHandleVal(), sellType);
                                end
                                local groupInfo = session.autoSeller.GetByIndex("Portal", 0);
                                DBGOUT(tostring(session.autoSeller.GetCount("Portal")))
                                for j = 0, session.autoSeller.GetCount("Portal") - 1 do
                                    DBGOUT(tostring(j))
                                    local titleName = session.autoSeller.GetTitle("Portal");
                                    local itemInfo = session.autoSeller.GetByIndex("Portal", j);
                                    local propValue = itemInfo:GetArgStr();
                                    local portalInfoList = StringSplit(propValue, "@"); -- portalPos@openedTime
                                    local portalPosList = StringSplit(portalInfoList[1], "#"); -- zoneName#x#y#z
                                    
                                    -- name
                                    local mapName = portalPosList[1];
                                    local x, y, z = portalPosList[2], portalPosList[3], portalPosList[4];
                                    local mapCls = GetClass('Map', mapName);
                                    --絞り込み開始
                                    DBGOUT(string.format("%s %s %s", groupname, titleName, mapName))
                                    -- if (g.finding:match(mapName)) then
                                    --     DBGOUT("MATCH")
                                    --     session.minimap.AddIconInfo("GuildIndun", "trasuremapmark", MakeVec3(x, y, z), titleName, true, "None", 0.75);
                                    -- end
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
function FINDPORTALSHOP_FIND(name)

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
    FINDPORTALSHOP_LISTING()
end
