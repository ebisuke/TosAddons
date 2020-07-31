--アドオン名（大文字）
local addonName = "enemycd"
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
g.settings = {x = 300, y = 300}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "enemycd"
g.debug = true
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x = nil
g.y = nil
g.buffs={}
--ライブラリ読み込み
CHAT_SYSTEM("[ECD]loaded")
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
function ENEMYCD_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function ENEMYCD_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {x=300,y=200}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    ENEMYCD_UPGRADE_SETTINGS()
    ENEMYCD_SAVE_SETTINGS()

end


function ENEMYCD_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=TESTBOARD_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function ENEMYCD_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))

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
            ENEMYCD_LOAD_SETTINGS()


            -- --ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "ENEMYCD_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("ENEMYCD_ON_TIMER");
            timer:Start(0.1);
            timer:EnableHideUpdate(true)
            --TESTBOARD_SHOW(g.frame)
            ENEMYCD_INIT()
            g.frame:ShowWindow(0)
            g.frame:SetOffset(g.settings.x,g.settings.y)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ENEMYCD_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function ENEMYCD_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function ENEMYCD_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end
function ENEMYCD_TOGGLE_FRAME(frame)
    g.settings.x=frame:GetX()
    g.settings.y=frame:GetY()
    ENEMYCD_SAVE_SETTINGS()
end
function ENEMYCD_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ENEMYCD_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local handle=session.GetTargetHandle()
            local frame=ui.GetFrame(g.framename)
            if(handle~=nil)then
                --local targetinfo = info.GetTargetInfo( handle );
                local targetInfo= info.GetTargetInfo(handle);
                local actor =world.GetActor(handle); 
                local type = actor:GetType();
                local monCls = GetClassByType("Monster", type);
                local list = GetMonsterSkillList(monCls.ClassID);

                local st=""
                for i = 0, list:Count() - 1 do
                    local sklName = list:Get(i);
                    local sklCls = GetClass("Skill", sklName);
                    local type = sklCls.ClassID;
                    --local skill= GetSkill(obj, sklName)

                    local isAble = geMCC.IsAbleToUseSkill(actor, GetMyActor(), type);
                    --local totalTime =  skill:GetCurrentCoolDownTime();
                    --local curTime = skill:GetTotalCoolDownTime();
                    st=st..sklName..":"..tostring(isAble).."{nl}"
                end
              
                 local txt=frame:CreateOrGetControl("richtext","skills",0,0,400,100)
                 txt:SetText("{ol}"..st)
                 frame:ShowWindow(1)
                 frame:Resize(400,100)

            else
                frame:ShowWindow(0)
            end

            -- local list, cnt = SelectObject(self, 50, 'ENEMY')
            -- local i
            -- --frame:ShowWindow(0)
            -- for i = 1, cnt do
            --      --local targetinfo = info.GetTargetInfo( handle );

            --      local obj = list[i]
            --      --print(obj.ClassName)
            --      local monCls = GetClass("Monster", obj.ClassName);
            --      local list = GetMonsterSkillList(monCls.ClassID);
 
            --      local st=""
            --      for j = 0, list:Count() - 1 do
            --          local sklName = list:Get(j);
            --          local sklCls = GetClass("Skill", sklName);
            --          local type = sklCls.ClassID;
            --          --print(sklName)
            --         -- local skill= GetSkill(obj, sklName)
            --          local actor = world.GetActor( GetHandle(obj))
            --          local isAble = geMCC.IsAbleToUseSkill(actor, GetMyActor(), type);
            --          --local skill= session.GetSkillByGuid(sklCls:GetIESID());	
            --          --local curTime =  skill:GetCurrentCoolDownTime();
            --          --local totaltime = skill:GetTotalCoolDownTime();
            --          st=st..sklName..":"..tostring(isAble).."{nl}"
            --      end
            --      local txt=frame:CreateOrGetControl("richtext","skills",0,0,400,100)
            --      txt:SetText("{ol}"..st)
            --      frame:ShowWindow(1)
            --      frame:Resize(400,100)

            --     break
            -- end
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

