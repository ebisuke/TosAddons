-- CAMPEXTENDER
--アドオン名（大文字）
local addonName = 'CAMPEXTENDER'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'campextender'
g.debug = false
g.working=false
g.automode=false
--ライブラリ読み込み
CHAT_SYSTEM('[CE]loaded')
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
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
        end,
        catch = function(error)
        end
    }
end
function CAMPEXTENDER_SAVE_SETTINGS()
    --CAMPEXTENDER_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function CAMPEXTENDER_SAVE_ALL()
    CAMPEXTENDER_SAVETOSTRUCTURE()
    CAMPEXTENDER_SAVE_SETTINGS()

end
function CAMPEXTENDER_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('camp_ui')
    local gbox = frame:GetChild('gbox')
    local numdays = gbox:GetChild('numdays')
    AUTO_CAST(numdays)
    g.settings.days=numdays:GetNumber()
    local chkautoextend = gbox:GetChild('chkautoextend')
    AUTO_CAST(chkautoextend)
    g.settings.autoextend=chkautoextend:IsChecked()==1
end

function CAMPEXTENDER_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    g.settings = {days = 7,autoextend=false}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {days = 7,autoextend=false}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    
    CAMPEXTENDER_UPGRADE_SETTINGS()
    CAMPEXTENDER_SAVE_SETTINGS()
    --CAMPEXTENDER_LOADFROMSTRUCTURE()
end

function CAMPEXTENDER_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('camp_ui')
    local gbox = frame:GetChild('gbox')
    local numdays = gbox:GetChild('numdays')
    AUTO_CAST(numdays)

    --do not load here
end

function CAMPEXTENDER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function CAMPEXTENDER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPEXTENDER_GETCID()))
            frame:ShowWindow(0)
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg("OPEN_CAMP_UI", "CAMPEXTENDER_ON_OPEN_CAMP_UI");
            
            CAMPEXTENDER_LOAD_SETTINGS()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CAMPEXTENDER_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame('camp_ui')
            local gbox = frame:GetChild('gbox')
            local reg = gbox:GetChild('reg')
            reg:Resize(120, 50)
            reg:SetGravity(ui.LEFT, ui.TOP)
            reg:SetOffset(40, 440)
            
            local btnextend = gbox:CreateOrGetControl('button', 'btnextend', 180, 440, 160, 50)
            btnextend:SetText("{@st41b}Adv.Extend")
            btnextend:SetSkinName("test_red_button")
            btnextend:SetEventScript(ui.LBUTTONUP,'CAMPEXTENDER_ON_EXTEND')
            local numdays = gbox:CreateOrGetControl('numupdown', 'numdays', 80, 500, 120, 30)
            AUTO_CAST(numdays)
            numdays:MakeButtons("btn_numdown", "btn_numup", "editbox_s")
            numdays:Invalidate()
            numdays:SetMinValue(1)
            numdays:SetMaxValue(365)
            numdays:SetNumberValue(g.settings.days)
            numdays:SetIncrValue(1)
           
            numdays:SetNumChangeScp('CAMPEXTENDER_ON_NUM_CHANGE')
            numdays:SetLBtnUpScp('CAMPEXTENDER_ON_NUM_CHANGE')
            numdays:SetRBtnUpScp('CAMPEXTENDER_ON_NUM_CHANGE')
            local label = gbox:CreateOrGetControl('richtext', 'label', 200, 500, 60, 30)
            label:SetText('{@st41b}Days')
            local chkautoextend = gbox:CreateOrGetControl('checkbox', 'chkautoextend', 260, 500, 80, 30)
            AUTO_CAST(chkautoextend)
            chkautoextend:SetText("{@st41b}Auto Extend")
            chkautoextend:SetTextTooltip("{ol}ONにするとキャンプ画面を開くと自動的に延長します")
            if g.settings.autoextend then
                
            chkautoextend:SetCheck(1)
            else

                chkautoextend:SetCheck(0)
            end
            chkautoextend:SetEventScript(ui.LBUTTONUP,'CAMPEXTENDER_ON_CHECK_CHANGE')
          
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CAMPEXTENDER_ON_NUM_CHANGE()
    CAMPEXTENDER_SAVE_ALL()
end
function CAMPEXTENDER_ON_CHECK_CHANGE()
    CAMPEXTENDER_SAVE_ALL()
end
function CAMPEXTENDER_ON_EXTEND()
    g.automode=false
    CAMPEXTENDER_DO_EXTEND()
end
function CAMPEXTENDER_DO_EXTEND()
 
    g.working=true
    CAMPEXTENDER_CHECK_NEXT()
end
function CAMPEXTENDER_EXTEND_ONCE()
	local campInfo = session.camp.GetCurrentCampInfo();
	local needSilver = CAMP_EXTEND_PRICE(campInfo.skillType, campInfo.skillLevel);
	if IsGreaterThanForBigNumber(needSilver, GET_TOTAL_MONEY_STR()) == 1 then
        ui.SysMsg( ClMsg("NotEnoughMoney") );
        g.working=false
		return;
    end
    local campInfo = session.camp.GetCurrentCampInfo();
    control.CustomCommand("EXTEND_CAMP_TIME", campInfo:GetHandle());

    CAMPEXTENDER_CHECK_NEXT()
end
function CAMPEXTENDER_CHECK_NEXT()
    if g.working then
        local campInfo = session.camp.GetCurrentCampInfo();

        local serverTime = geTime.GetServerFileTime();
        local difSec = imcTime.GetIntDifSecByTime(campInfo:GetEndTime(), serverTime);
        if g.settings.days > difSec/86400 then
            ReserveScript('CAMPEXTENDER_EXTEND_ONCE()',0.15)
        else
            if g.automode==false then
                ui.SysMsg('[CE]Extend complete.')
                ReserveScript("ui.GetFrame('camp_ui'):ShowWindow(1)",0.5)
            end
            g.working=false
            ReserveScript("ui.GetFrame('camp_ui'):ShowWindow(1)",0.2)
        end
    else

    end
end
function CAMPEXTENDER_ON_OPEN_CAMP_UI()
    CAMPEXTENDER_INITFRAME()
        
    if g.settings.autoextend then
        g.automode=true
        CAMPEXTENDER_DO_EXTEND()
    end
end