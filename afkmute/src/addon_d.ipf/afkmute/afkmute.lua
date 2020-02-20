--アドオン名（大文字）
local addonName = "afkmute"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings={x=300,y=300,volume=100,mute=false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "afkmute"
g.debug = false
g.handle=nil
g.interlocked=false
g.currentIndex=1
--ライブラリ読み込み
CHAT_SYSTEM("[AFKMUTE]loaded")
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




local translationtable = {

    --Tsettingsupdt12 = {jp="[AIM]共通設定のバージョンを更新しました 1->2",  eng="[AIM]Team settings updated 1->2"},
    }

local function L_(str)

    if (option.GetCurrentCountry() == "Japanese") then
        if(translationtable[str]~=nil)then
            return translationtable[str].jp
        end
    end
    if(translationtable[str]~=nil)then
        return translationtable[str].eng
    end
    return str
end

function AFKMUTE_DBGOUT(msg)
    
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
function AFKMUTE_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function AFKMUTE_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function AFKMUTE_LOAD_SETTINGS()
    AFKMUTE_DBGOUT("LOAD_SETTING")
    g.settings = {foods={}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        AFKMUTE_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {x=300,y=300,volume=100,mute=false}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0

        end
    end
    
    AFKMUTE_UPGRADE_SETTINGS()
    AFKMUTE_SAVE_SETTINGS()

end


function AFKMUTE_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end


--マップ読み込み時処理（1度だけ）
function AFKMUTE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))

            acutil.slashCommand("/afkmute", AFKMUTE_PROCESS_COMMAND)
            addon:RegisterMsg('GAME_START_3SEC', 'AFKMUTE_3SEC')
            addon:RegisterMsg('FPS_UPDATE', 'AFKMUTE_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
             --コンテキストメニュー
            frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            --ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            
            AFKMUTE_SHOW(g.frame)
            
            

        end,
        catch = function(error)
            AFKMUTE_ERROUT(error)
        end
    }
end
function AFKMUTE_3SEC(frame)
    frame=ui.GetFrame(g.framename)
    AFKMUTE_LOAD_SETTINGS()
    frame:SetOffset(g.settings.x, g.settings.y);
   
    AFKMUTE_INITFRAME(frame)
    AFKMUTE_SHOW(frame)
    if(g.settings.mute==true)then
        AFKMUTE_RESTORATION(frame)
    end

   
end
function AFKMUTE_SHOW(frame)
    frame=ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function AFKMUTE_TOGGLE(frame)
    EBI_try_catch{
        try=function()
            if(g.settings.mute==false)then
              

                AFKMUTE_MUTE(frame)
            else
               
                AFKMUTE_RESTORATION(frame)
            end
        end,
        catch=function(exp)
            AFKMUTE_ERROUT(exp)
        end
    }
end
function AFKMUTE_MUTE(frame)
    g.settings.volume=config.GetTotalVolume()
    g.settings.mute=true
    AFKMUTE_SAVE_SETTINGS()
    config.SetTotalVolume(0)
    local btn=frame:GetChild("mute")
    tolua.cast(btn,"ui::CPicture")
    btn:SetImage("btn_afkmute_on")
    CHAT_SYSTEM("[AFKMUTE] MUTE ON")
end
function AFKMUTE_RESTORATION(frame)
    config.SetTotalVolume(g.settings.volume)
    g.settings.mute=false
    AFKMUTE_SAVE_SETTINGS()
    local btn=frame:GetChild("mute")
    tolua.cast(btn,"ui::CPicture")
    btn:SetImage("btn_afkmute_off")
    CHAT_SYSTEM("[AFKMUTE] MUTE OFF")
end
function AFKMUTE_INITFRAME(frame)
    EBI_try_catch{
        try=function()
            local btn=frame:CreateOrGetControl("picture","mute",0,0,120,60)
            tolua.cast(btn,"ui::CPicture")
            btn:SetSkinName("None")
            btn:SetImage("btn_afkmute_off")
            btn:ShowWindow(1)
            btn:EnableHitTest(0)
            frame:ShowWindow(1)
        end,
        catch=function(exp)
            AFKMUTE_ERROUT(exp)
        end
    }

end
function AFKMUTE_END_DRAG()
    g.settings.x = g.frame:GetX();
    g.settings.y = g.frame:GetY();
    AFKMUTE_SAVE_SETTINGS();
end
  
function AFKMUTE_PROCESS_COMMAND(command)
    local cmd = "";
  
    AFKMUTE_TOGGLE(frame)
    
    --CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
  end
