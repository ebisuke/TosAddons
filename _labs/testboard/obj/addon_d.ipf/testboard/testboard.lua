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
g.buffs = {}
g.prevtime=nil
g.framelist={}
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
            addon:RegisterMsg("ZONE_TRAFFICS", "TESTBOARD_ON_ZONE_TRAFFICS");
            
            --addon:RegisterMsg('BUFF_ADD', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_REMOVE', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_UPDATE', 'TESTBOARD_BUFF_ON_MSG');
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            --TESTBOARD_SHOW(g.frame)
            --TESTBOARD_GETFRAME_OLD=ui.GetFrame
            --ui.GetFrame=TESTBOARD_GETFRAME

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
            
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("TESTBOARD_ON_TIMER");
            timer:Start(1);
            timer:EnableHideUpdate(true)

            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TESTBOARD_GETFRAME(name)
    
    local frame= TESTBOARD_GETFRAME_OLD(name)
    if(frame)then
        g.framelist[name]=frame
    end
    return frame
end
function TESTBOARD_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
  
                  end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function TESTBOARD_TEST()
    
    EBI_try_catch{
        try = function()

            local pc = GetMyActor()
            local pos=pc:GetPos()
            local actor=pc
            local targetActor=world.GetActor(session.GetTargetHandle())
            --PlayEffect(actor, 'F_circle020_light', 1.5,1,'BOT')
           
            effect.PlayTextEffect(pc,"I_SYS_damage_4","100");
            effect.PlayTextEffect(pc,"I_SYS_damage_3","100")
            effect.PlayTextEffect(pc,"I_SYS_damage_2","100");
            effect.PlayTextEffect(pc,"I_SYS_damage_1","100");
            effect.PlayTextEffect(pc,"I_SYS_damage",'100');
            effect.PlayTextEffect(pc,"SHOW_DMG_SHIELD","100");
            effect.PlayTextEffect(pc,"I_SYS_heal2","100");
            local objList, objCount = SelectObject(self, 300, 'ALL') 
            CHAT_SYSTEM("Thaurge BEGIN")
                    
            for i = 1, objCount do
                local enemyHandle = GetHandle(objList[i]);
			    local enemy = world.GetActor(enemyHandle);
                if objList[i].ClassName == 'pcskill_Warlock_DarkTheurge' then
                    local enemyDestPos = enemy:GetArgPos(0);
                    local enemyPos = enemy:GetPos();
                    local distFromActor = imcMath.Vec3Dist(enemyPos, pos);
                    CHAT_SYSTEM("Thaurge"..enemyHandle..":"..tostring(objList[i].Faction))
                  
                end
                if objList[i].ClassID==150011 then
                    ACCEPT_NEXT_LEVEL_CHALLENGE_MODE(enemyHandle)
                end
                if objList[i].ClassID==150010 then
                    ACCEPT_CHALLENGE_MODE(enemyHandle)
                end
		    end
        end,
        catch = function(error)
            ERROUT("FAIL:" .. tostring(error))
        end
    }
end
function TESTBOARD_TAKEDAMAGE()
    DBGOUT("take")
end
function TESTBOARD_SCP()
    DBGOUT("scp")
end