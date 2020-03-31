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
g.qssiframe=g.qssiframe or nil
g.settings=g.settings or {}
g.personalsettings=g.personalsettings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.loaded=g.loaded or false
g.pressed=false
local function AUTO_CAST(ctrl)
    if(ctrl==nil)then
        
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
	return ctrl;
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




-- ライブラリ読み込み
function QUICKSLOTSWITCHER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            g.frame=frame
            acutil.setupHook(QSS_QUICKSLOT_REFRESH,"QUICKSLOT_REFRESH")
            acutil.setupHook(QSS_QUICKSLOTNEXPBAR_ON_DROP_JUMPER,"QUICKSLOTNEXPBAR_ON_DROP")
            acutil.setupHook(QSS_QUICKSLOTNEXPBAR_DUMPICON_JUMPER,"QUICKSLOTNEXPBAR_DUMPICON")
            acutil.setupHook(QSS_JOYSTICK_QUICKSLOTNEXPBAR_ON_DROP_JUMPER,"JOYSTICK_QUICKSLOTNEXPBAR_ON_DROP")
            acutil.setupHook(QSS_JOYSTICK_QUICKSLOTNEXPBAR_DUMPICON_JUMPER,"JOYSTICK_QUICKSLOTNEXPBAR_DUMPICON")
            addon:RegisterMsg('GAME_START_3SEC', 'QSS_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'QSS_SHOW');
            addon:RegisterMsg('QUICKSLOT_LIST_GET', 'QSS_ON_UPDATE');
            addon:RegisterMsg('REGISTER_QUICK_SKILL', 'QSS_ON_UPDATE');
            addon:RegisterMsg('REGISTER_QUICK_ITEM', 'QSS_ON_UPDATE');
            addon:RegisterMsg('INV_ITEM_ADD_FOR_QUICKSLOT', 'QSS_ON_UPDATE');
            addon:RegisterMsg('DELETE_QUICK_SKILL', 'QSS_ON_UPDATE');
	        addon:RegisterMsg("DELETE_SPECIFIC_SKILL", 'QSS_ON_UPDATE');
            g.loaded=false
           
           
        end,
        catch = function(error)
            DBGOUT(error)
        end
    }
end
function QSS_3SEC()
    g.qssiframe=ui.GetFrame("quickslotswitcherindicator")

    local timer = GET_CHILD(g.frame, "addontimer", "ui::CAddOnTimer");
    timer:SetUpdateScript("QSS_ON_TIMER")
    timer:Start(0.01)
    QSS_LOAD_SETTINGS()
    QSS_INIT()
    QSSI_INIT()
    QSSC_INIT()
    g.loaded=true
    QSSI_UPDATE_STATUS()

end
function QSSI_INIT()
    EBI_try_catch{
        try = function()
            local frame=g.qssiframe
            frame:Resize(100,30)
           
            frame:SetOffset(g.settings.x or 300,g.settings.y or 300)
            frame:SetEventScript(ui.LBUTTONUP, "QSSI_LBUTTONUP");
            --frame:SetEventScript(ui.RBUTTONUP, "QSSI_CONTEXT_MENU");
            frame:SetSkinName("test_weight_skin")
            frame:EnableMove(1)
            frame:EnableHittestFrame(1)
            frame:EnableHitTest(1)
            frame:ShowWindow(1)

            --tab

            local text=frame:CreateOrGetControl("richtext","tab",0,0,100,30)
            AUTO_CAST(text)
            text:SetGravity(ui.RIGHT,ui.TOP)
            text:SetSkinName("test_gray_button")
            text:EnableHitTest(0)
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }   
end
function QSSC_INIT()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("quickslotswitcherconfig")


            local text=frame:CreateOrGetControl("richtext","labellist",200,100,100,30)
            AUTO_CAST(text)
            text:SetText("Quickslot")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }   
end
-- コンテキストメニュー表示処理
function QSSI_CONTEXT_MENU(frame, msg, clickedGroupName, argNum)
    local context = ui.CreateContextMenu("TEMPLATE_RBTN", "", 0, 0, 200,
        100)
    ui.AddContextMenuItem(context, "Show Config", "QSSC_SHOW()")
    context:Resize(200, context:GetHeight())
    ui.OpenContextMenu(context)

end
function QSSI_UPDATE_STATUS()
    EBI_try_catch{
        try = function()
            local frame=g.qssiframe
            if(frame==nil or not g.loaded)then

                return
            end

            --tab

            local text=frame:GetChild("tab")
            AUTO_CAST(text)
            text:SetText(string.format("{b}{@st43}{s20}{#FFFFFF}Swap %d/%d",g.personalsettings.currentno,g.personalsettings.maxno))
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }   
end
function QSSC_SHOW()
    ui.GetFrame("quickslotswitcherconfig"):ShowWindow(1)
end
function QSSC_CLOSE()
    ui.GetFrame("quickslotswitcherconfig"):ShowWindow(0)
end
function QSSI_LBUTTONUP()
    local frame=g.qssiframe
    g.settings.x=frame:GetX()
    g.settings.y=frame:GetY()
    QSS_SAVE_SETTINGS()
end
function QSS_INIT()
    QSS_CHANGENO(g.personalsettings.currentno)
    
end
function QSS_CHANGENO(no,force)
    DBGOUT("NO:"..tostring(no))
    if(force)then
        QSS_SAVE_CURRENTQUICKSLOT()
        g.personalsettings.currentno=no
    
        QSS_LOAD_CURRENTQUICKSLOT()
        QSS_SAVE_SETTINGS()
    else
        g.personalsettings.currentno=no
        QSS_LOAD_CURRENTQUICKSLOT()
    end
    QSSI_UPDATE_STATUS()
end
function QSS_GET_CURRENTQUICKSLOT()
    DBGOUT(tostring(g.personalsettings.currentno))
    return g.personalsettings.quickslots[g.personalsettings.currentno]
end
function QSS_SET_CURRENTQUICKSLOT(qs)
    DBGOUT(tostring(g.personalsettings.currentno))
    g.personalsettings.quickslots[g.personalsettings.currentno]=qs
    g.personalsettings.quickslotcount=quickslot.GetActiveSlotCnt()

end
function QSS_SHOW()
    if(g.loaded)then
        ui.GetFrame(g.framename):ShowWindow(1)
    end
end
function QSS_ON_TIMER()
    EBI_try_catch{
        try = function()
            if(g.loaded)then
                if((ui.GetFocusObject() == nil or 
                ui.GetFocusObject():GetClassString() ~= "ui::CEditControl") and 
                ui.IsFrameVisible("chat_frame")~=1)then
                    if(keyboard.IsKeyDown(g.settings.keys.toggle)==1 or 
                    ((joystick.IsKeyPressed("JOY_BTN_5")==1)and(joystick.IsKeyPressed("JOY_BTN_7")==1)))then
                        if(not g.pressed)then
                            local no=g.personalsettings.currentno+1
                            if(no > g.personalsettings.maxno)then
                                no=1
                            end
                            QSS_CHANGENO(no,true)
                            imcSound.PlaySoundEvent('button_click_big');
                            --CHAT_SYSTEM("SWITCH:"..tostring(no))
                        end
                        g.pressed=true
                    else
                        g.pressed=false
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function QSS_ON_UPDATE()
    DebounceScript("QSS_SAVE_ALL",0.5,0)
end
function QSS_SAVE_ALL()
    DBGOUT("SAVE ALL")
    QSS_SAVE_CURRENTQUICKSLOT()
    QSS_SAVE_SETTINGS()
end
function QSS_QUICKSLOTNEXPBAR_ON_DROP_JUMPER(frame, control, argStr, argNum)	
    QUICKSLOTNEXPBAR_ON_DROP_OLD(frame, control, argStr, argNum)	
    QSS_QUICKSLOTNEXPBAR_ON_DROP(frame, control, argStr, argNum)
end
function QSS_QUICKSLOTNEXPBAR_DUMPICON_JUMPER(frame, control, argStr, argNum)	
    QUICKSLOTNEXPBAR_DUMPICON_OLD(frame, control, argStr, argNum)	
    QSS_QUICKSLOTNEXPBAR_DUMPICON(frame, control, argStr, argNum)
end
function QSS_JOYSTICK_QUICKSLOTNEXPBAR_ON_DROP_JUMPER(frame, control, argStr, argNum)	
    JOYSTICK_QUICKSLOTNEXPBAR_ON_DROP_OLD(frame, control, argStr, argNum)	
    QSS_QUICKSLOTNEXPBAR_ON_DROP(frame, control, argStr, argNum)
end
function QSS_JOYSTICK_QUICKSLOTNEXPBAR_DUMPICON_JUMPER(frame, control, argStr, argNum)	
    JOYSTICK_QUICKSLOTNEXPBAR_DUMPICON_OLD(frame, control, argStr, argNum)	
    QSS_QUICKSLOTNEXPBAR_DUMPICON(frame, control, argStr, argNum)
end
function QSS_QUICKSLOTNEXPBAR_ON_DROP(frame, control, argStr, argNum)	
    DebounceScript("QSS_SAVE_ALL",0.5,0)
end
function QSS_QUICKSLOTNEXPBAR_DUMPICON(frame, control, argStr, argNum)	
    DebounceScript("QSS_SAVE_ALL",0.5,0)
end
function QSS_QUICKSLOT_REFRESH(curCnt)
    QUICKSLOT_REFRESH_OLD(curCnt)
    quickslot.SetActiveSlotCnt(curCnt);
    --QSS_SAVE_CURRENTQUICKSLOT()
end
function QSS_SAVE_CURRENTQUICKSLOT()
    EBI_try_catch{
        try = function()
            local curCnt = quickslot.GetActiveSlotCnt();		

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


          
            --KEYBOARD
            for idx=1,2 do

                local frame,max
                if(idx==1)then
                    frame= ui.GetFrame('quickslotnexpbar');
                    max=MAX_QUICKSLOT_CNT
                else
                    frame= ui.GetFrame('joystickquickslot');
                    max=MAX_SLOT_CNT
                end
                local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
                local qs=QSS_GET_CURRENTQUICKSLOT()
                for i = 0, max - 1 do
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
            end
            local curCnt = g.personalsettings.quickslotcount or 40
            quickslot.SetActiveSlotCnt(curCnt);
            QUICKSLOT_REFRESH(curCnt);

            DBGOUT("LOADED")
            --quickslot.RequestSave();
            
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
            x=300,y=300,
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
            maxno=2,
            quickslotcount=40,
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
    if newdata==false then
        QSS_LOAD_CURRENTQUICKSLOT()
    else
        QSS_SAVE_CURRENTQUICKSLOT()
    end
    QSS_SAVE_SETTINGS()
    
end


function QSS_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end