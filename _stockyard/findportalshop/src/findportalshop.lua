function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local acutil = require('acutil')
function FINDPORTALSHOP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame("findportalshop");
            frame:ShowWindow(0)
            if OLD_MAP_OPEN == nil then
                OLD_MAP_OPEN = MAP_OPEN
                MAP_OPEN = FINDPORTALSHOP_MAP_OPEN_JUMPER
            end
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
 
            local btnopen = frame:CreateOrGetControl("button", "btnfindportal", 0, 0, 120, 40)
            btnopen:SetMargin(0, 18, 80 + 120 + 20, 0)
            btnopen:SetGravity(ui.RIGHT, ui.TOP)
            btnopen:SetSkinName("test_pvp_btn")
            btnopen:SetText("{@st66b}ポタ屋一覧")
            btnopen:SetEventScript(ui.LBUTTONDOWN, "FINDPORTALSHOP_TOGGLE");
            FINDPORTALSHOP_LISTING();
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
    local frame = ui.GetFrame("findportalshop");
    --比較的遠くまでのポータルショップを探す
    local objList, objCount = SelectObject(GetMyActor(), 1000, 'ALL')
    local portals = {}
    portals = {name = "", title = "", pchandle = 0, mapname = nil, position = nil}
    portals = {}
    --ポタ屋を検索
    for i = 1, objCount do
        local itm = objList[i];
        local hnd = GetHandle(itm);
        local tgt = info.GetTargetInfo(hnd);
        if (itm.ClassName == "PC") and (tgt.IsDummyPC == 1) then
            --ダミーPC
            --グループ名取得
            --local actr = world.GetActor(hnd);
            
            local groupname = info.GetFamilyName(hnd);
            print(tostring(groupname))
            if (groupname ~= nil) then
                --ショップの情報を仕入れる
                local shop = session.autoSeller.GetShopBaseInfo(AUTO_SELL_PORTAL)
                if (shop ~= nil) then
                    print("here")
                    --ポタ屋
                    for j = 0, session.autoSeller.GetCount(groupname) - 1 do
                        
                        local itemInfo = session.autoSeller.GetByIndex(groupName, i);
                        local propValue = itemInfo:GetArgStr();
                        local portalInfoList = StringSplit(propValue, "@"); -- portalPos@openedTime
                        local portalPosList = StringSplit(portalInfoList[1], "#"); -- zoneName#x#y#z
                        
                        -- name
                        local mapName = portalPosList[1];
                        local x, y, z = portalPosList[2], portalPosList[3], portalPosList[4];
                        local mapCls = GetClass('Map', mapName);
                        local registerCheck = GET_CHILD_RECURSIVELY(ctrlSet, 'registerCheck');
                        --registerCheck:SetTextByKey('map', mapCls.Name);
                        portals[#portals] = {name = groupname, title = shop.Title, mapname = mapCls.Name, position = {x = x, y = y, z = z}}
                    end
                end
            end
        end
    end
end
function FINDPORTALSHOP_FIND(name)

end
