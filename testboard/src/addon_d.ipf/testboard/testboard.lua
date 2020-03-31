--アドオン名（大文字）
local addonName = "testboard"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "testboard"
g.debug = true
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x = nil
g.y = nil
g.buffs={}
--ライブラリ読み込み
CHAT_SYSTEM("[TESTBOARD]loaded")
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
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
function TESTBOARD_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function TESTBOARD_LOAD_SETTINGS()
    TESTBOARD_DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        TESTBOARD_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    TESTBOARD_UPGRADE_SETTINGS()
    TESTBOARD_SAVE_SETTINGS()

end


function TESTBOARD_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=TESTBOARD_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function TESTBOARD_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('testboard', 'sysmenu_sys', 'testboard', 'TESTBOARD_TOGGLE_FRAME')
            --addon:RegisterMsg('GAME_START_3SEC', 'TESTBOARD_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --addon:RegisterMsg('BUFF_ADD', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_REMOVE', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_UPDATE', 'TESTBOARD_BUFF_ON_MSG');
            
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("TESTBOARD_ON_TIMER");
            timer:Start(0.1);
            --TESTBOARD_SHOW(g.frame)
            TESTBOARD_INIT()
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TESTBOARD_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function TESTBOARD_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function TESTBOARD_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end
function TESTBOARD_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local button = frame:CreateOrGetControl("button", "btn", 0, 80, 200, 100)
            AUTO_CAST(button)
            button:SetEventScript(ui.LBUTTONUP, "TESTBOARD_TEST")
            button:SetText("INJECT LOVE!")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TESTBOARD_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
        -- local frame = ui.GetFrame(g.framename)
        -- local pic = frame:GetChild("pic")
        -- tolua.cast(pic, "ui::CPicture")
        -- local x, y = GET_LOCAL_MOUSE_POS(pic);
        -- if mouse.IsLBtnPressed() ~= 0 then
        --     if(g.x==nil or g.y==nil )then
        --         g.x=x
        --         g.y=y
        --     end
        --     --print(string.format("draw %d,%d",x,y))
        --     local pics=pic:GetPixelColor(x, y);
        --     --print("pics "..tostring(pics))
        --     pic:DrawBrush(g.x,g.y,x,y, "spray_8", "FFFF0000");
        --     pic:Invalidate()
        --     g.x=x
        --     g.y=y
        -- else
        --     g.x=nil
        --     g.y=nil
        -- end
        -- local fndList, fndCount = SelectObject(GetMyActor(), 400, 'ALL');
        -- local flag = 0
        -- for index = 1, fndCount do
        --     local enemyHandle = GetHandle(fndList[index]);
        --     if(enemyHandle~=nil)then
        --         local enemy = world.GetActor(enemyHandle);
        --         if enemy ~= nil then
        --             local apc=enemy:GetPCApc()
        --             local aid=enemy:GetPCApc():GetAID();
        --             local opc=session.otherPC.GetByStrAID(aid)
        --             if(opc~=nil)then
        --                --print(tostring(opc:GetPartyInfo()))
        --             end
        --         end
        --     end
        -- end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function TESTBOARD_TEST()
    
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:RemoveChild("testweb")
            local p=frame:CreateOrGetControl("webpicture","testweb",0,0,100,100)
            AUTO_CAST(p)
            p:SetUrlInfo("https://hldc.co.jp/blog/wp-content/uploads/2017/08/img_graphs.png")
        end,
        catch = function(error)
            ERROUT("FAIL:" .. tostring(error))
        end
    }
end
