--quickslotswitcher
local addonName = "quickslotswitcher"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
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

g.debug = false
g.framename="quickslotswitcher"
g.settings=g.settings or {}
g.personalsettings=g.personalsettings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
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
function QUICKSLOTSWITCHER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            local timer = GET_CHILD(ui.GetFrame("quickslotswitcher"), "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("QSS_ON_TIMER")
            timer:Start(0.01)
            addon:RegisterMsg('FPS_UPDATE', 'QSS_SHOW');
            addon:RegisterMsg('QUICKSLOT_LIST_GET', 'QSS_ON_UPDATE');
            addon:RegisterMsg('REGISTER_QUICK_SKILL', 'QSS_ON_UPDATE');
            addon:RegisterMsg('REGISTER_QUICK_ITEM', 'QSS_ON_UPDATE');
            frame:ShowWindow(1)
            QSS_LOAD_SETTINGS()
            QSS_INIT()
        end,
        catch = function(error)
            DBGOUT(error)
        end
    }
end
function QSS_INIT()
    
end
function QSS_CHANGENO(no,force)
 
    if(force)then
        QSS_SAVE_CURRENTQUICKSLOT()
        g.personalsettings.currentno=no
    
        QSS_LOAD_CURRENTQUICKSLOT()
        QSS_SAVE_SETTINGS()
    else
        g.personalsettings.currentno=no
    
    end
end
function QSS_GET_CURRENTQUICKSLOT()
    return g.personalsettings.quickslots[g.personalsettings.currentno]
end
function QSS_SET_CURRENTQUICKSLOT(qs)
    DBGOUT(tostring(g.personalsettings.currentno))
    g.personalsettings.quickslots[g.personalsettings.currentno]=qs
    QSS_SAVE_SETTINGS()
end
function QSS_SHOW()
    ui.GetFrame(g.framename):ShowWindow(1)
end
function QSS_ON_TIMER()
    EBI_try_catch{
        try = function()
            if(keyboard.IsKeyDown(g.settings.keys.toggle)==1)then
                local no=g.personalsettings.currentno+1
                if(no > g.personalsettings.maxno)then
                    no=1
                end
                QSS_CHANGENO(no,true)
                imcSound.PlaySoundEvent('button_over');
                --CHAT_SYSTEM("SWITCH:"..tostring(no))
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function QSS_ON_UPDATE()
    DebounceScript("QSS_SAVE_CURRENTQUICKSLOT",0.5,0)
    DebounceScript("QSS_SAVE_SETTINGS",1,0)
end
function QSS_SAVE_CURRENTQUICKSLOT()
    EBI_try_catch{
        try = function()
            local curCnt = quickslot.GetActiveSlotCnt();		
            if curCnt < 20 or curCnt > 40 then
                curCnt = 20;
            end
        
            if curCnt % 10 ~= 0 then
                curCnt = 20;
            end
            --KEYBOARD
            local frame = ui.GetFrame('quickslotnexpbar');
            local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
            local qs={}
            for i = 0, MAX_QUICKSLOT_CNT - 1 do
                local quickSlotInfo = quickslot.GetInfoByIndex(i); 
                if quickSlotInfo.type ~= 0 then
                    qs[i+1]={
                        type= quickSlotInfo.type,
                        category= quickSlotInfo.category,
                        iesid= quickSlotInfo:GetIESID(),
                    }
                else
                    qs[i+1]={type=0}
                    DBGOUT("ZERO")
                end
            end
            DBGOUT("SAVED")
            QSS_SET_CURRENTQUICKSLOT(qs)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function QSS_LOAD_CURRENTQUICKSLOT()
    EBI_try_catch{
        try = function()
            local curCnt = quickslot.GetActiveSlotCnt();		
            if curCnt < 20 or curCnt > 40 then
                curCnt = 20;
            end
        
            if curCnt % 10 ~= 0 then
                curCnt = 20;
            end
            --KEYBOARD
            local frame = ui.GetFrame('quickslotnexpbar');
            local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
            local qs=QSS_GET_CURRENTQUICKSLOT()
            for i = 0, MAX_QUICKSLOT_CNT - 1 do
                if(qs==nil or qs[i+1] ==nil )then
                    local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
                    tolua.cast(icon, "ui::CIcon")            
                    slot:ClearIcon()                
                    QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
                    SET_QUICKSLOT_OVERHEAT(slot)  
                    quickslot.OnSetSkillIcon(slot, 0);  
                    quickslot.SetInfo(slot:GetSlotIndex(),nil, 0, slot:GetSlotIndex());          
                else
                    local quickSlotInfo = qs[i+1]; 
                    if quickSlotInfo~= nil and quickSlotInfo.type~=nil and quickSlotInfo.type ~= 0 then
                        
                        local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot")
                        SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, quickSlotInfo.type, quickSlotInfo.iesid, 0, true, true);
                    else
                        local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
                        tolua.cast(icon, "ui::CIcon")            
                        slot:ClearIcon()                
                        QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
                        SET_QUICKSLOT_OVERHEAT(slot)      
                        quickslot.OnSetSkillIcon(slot, 0);    
                        quickslot.SetInfo(slot:GetSlotIndex(),nil, 0, slot:GetSlotIndex());       
                    end
                end
            end
            DBGOUT("LOADED")
            quickslot.RequestSave();
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function QSS_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,session.GetMySession():GetCID())
   
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
    --acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end


function QSS_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {
            keys={
                toggle="B",
                select={
                    [1]=nil,
                    [2]=nil,
                    [3]=nil,
                    [4]=nil,  
                }
            }
        }
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    local newdata=false
    g.personalsettings = {}
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,session.GetMySession():GetCID())
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load personal setting files', addonName))
        g.personalsettings = {
            currentno=1,
            maxno=4,
            quickslots={
                [1]={},
                [2]={},
                [3]={},
                [4]={},  
            }

        }
        newdata=true
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = 0
        
        end
    end
    QSS_UPGRADE_SETTINGS()
    QSS_SAVE_SETTINGS()
    if newdata==false then
        QSS_LOAD_CURRENTQUICKSLOT()
    end
end


function QSS_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end