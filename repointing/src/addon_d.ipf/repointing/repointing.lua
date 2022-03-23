--アドオン名（大文字）
local addonName = "repointing"
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
g.framename = "repointing"
g.debug = false
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x = nil
g.y = nil
g.applyjoystick=false
g.buffs = {}



--ライブラリ読み込み
CHAT_SYSTEM("[REP]loaded")
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

function REPOINTING_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", REPOINTING_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('GAME_START', 'REPOINTING_GAME_START');
            addon:RegisterMsg('GAME_START_3SEC', 'REPOINTING_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'REPOINTING_EVERY');
            local addontimer = frame:GetChild("addontimer")
            AUTO_CAST(addontimer)
            addontimer:SetUpdateScript("REPOINTING_ON_TIMER")
            addontimer:Start(0.5)
            addontimer:EnableHideUpdate(1)
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0,0)
            g.applyjoystick=false
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function REPOINTING_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function  REPOINTING_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    REPOINTINGCONFIG_GENERATEDEFAULT(g.settings)
    REPOINTING_UPGRADE_SETTINGS()
    REPOINTING_SAVE_SETTINGS()

end


function  REPOINTING_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

function REPOINTING_GAME_START()
    EBI_try_catch{
        try = function()
            
        REPOINTING_LOAD_SETTINGS()
        REPOINTINGCONFIG_INIT()

        
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function REPOINTING_3SEC()
    

end


function REPOINTING_EVERY()

    ui.GetFrame(g.framename):ShowWindow(1)
    -- if(g.settings.resizechat)then

    --     REPOINTING_SMALLIFY_CHATFRAME()
    -- end
end

function REPOINTING_ON_TIMER()
    EBI_try_catch{
        try = function()
            
        local actor=GetMyActor()
        local mypos=actor:GetPos()

        local objList, objCount = SelectObject(self, 400, 'ENEMY')
        for i=1, objCount do
            local enemyHandle = GetHandle(objList[i])
            local enemyActor = world.GetActor(enemyHandle)
            local monsterClass = GetClassByType("Monster", enemyActor:GetType());
            local vech = enemyActor:GetHorizonalDir();
            local dirh =math.atan(vech.x,vech.y)
            if (monsterClass ~= nil) then

                if (monsterClass.MonRank == "Boss") then
                    local distinitial=100
                    local dist=100
                    local target=enemyActor:GetSkillTargetObject()
                    
                    local destpos=target:GetPos()
                    while dist >= 1 do
                        local pos=enemyActor:GetPos()
                    
                        
                        local dir=math.atan(pos.x,pos.z)
                        
                        local di=dist/distinitial

                        local xx=pos.x+math.sin(dirh)*distinitial*di
                        local zz=pos.z+math.cos(dirh)*distinitial*di

                        
                        local eff="F_sys_arrow_pc"
                
                        effect.PlayGroundEffect(GetMyActor(),eff,1,xx,pos.y+10,zz,1,"None",-dirh+math.pi,0)
                        dist=dist-20
                    end
                    effect.PlayGroundEffect(GetMyActor(),"F_warrior_conscript_shot_ground",1,destpos.x,destpos.y,destpos.z,1,"None",0,0)
                    
                end
            end
        end
    end,
    catch = function(error)
        ERROUT(error)
    end
    }


    
end

function REPOINTING_DEBUG_RELOAD()
    local basepath=[[\\theseventhbody.local\e\TosProject\TosAddons\repointing]]
    dofile(basepath..[[\src\addon_d.ipf\repointing\repointing.lua]])
    dofile(basepath..[[\src\addon_d.ipf\repointingconfig\repointingconfig.lua]])
end
