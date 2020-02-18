--アドオン名（大文字）
local addonName = "MINIEXPBAR"
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
g.settings =g.settings or {
    x = 300,
    y = 300,
}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "miniexpbar"
g.debug = false


--ライブラリ読み込み
CHAT_SYSTEM("[MINIEXPBAR]loaded")
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

function MINIEXPBAR_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function MINIEXPBAR_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {
            x = 300, 
            y = 300,
        }
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end

    MINIEXPBAR_UPGRADE_SETTINGS()
    MINIEXPBAR_SAVE_SETTINGS()

end


function MINIEXPBAR_UPGRADE_SETTINGS()
    local upgraded = false

    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=CHALLENGEMODESTUFF_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function MINIEXPBAR_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            --addon:RegisterMsg('GAME_START_3SEC', 'CHALLENGEMODESTUFF_SHOW')
            --ccするたびに設定を読み込む

            addon:RegisterMsg('FPS_UPDATE', 'MINIEXPBAR_ON_FPS_UPDATE');
        
            addon:RegisterOpenOnlyMsg('LEVEL_UPDATE', 'MINIEXPBAR_ON_MSG');
            addon:RegisterMsg('EXP_UPDATE', 'MINIEXPBAR_ON_MSG');
            addon:RegisterMsg('JOB_EXP_UPDATE', 'MINIEXPBAR_ON_JOB_MSG');
            addon:RegisterMsg('JOB_EXP_ADD', 'MINIEXPBAR_ON_JOB_MSG');
            addon:RegisterMsg('CHANGE_COUNTRY', 'MINIEXPBAR_ON_MSG');
            if not g.loaded then
                
                g.loaded = true
            end
            MINIEXPBAR_LOAD_SETTINGS()
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            --CHALLENGEMODESTUFF_SHOW(g.frame)
            DBGOUT("INIT")
            --CHALLENGEMODESTUFF_INIT()
            g.frame:ShowWindow(1)
            frame:SetOffset(g.settings.x, g.settings.y)
            g.frame:SetEventScript(ui.LBUTTONUP, "MINIEXPBAR_LBTNUP");
            MINIEXPBAR_INIT()
            MINIEXPBAR_TIMER_BEGIN()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MINIEXPBAR_ON_JOB_MSG(frame, msg, str, exp, tableinfo)
    local curExp = exp - tableinfo.startExp;
    local maxExp = tableinfo.endExp - tableinfo.startExp;
    
	if tableinfo.isLastLevel == true then
		curExp = tableinfo.before:GetLevelExp();
		maxExp = curExp;
	end

	local expObject = GET_CHILD(frame, 'gaugeclassexp', "ui::CGauge");
	expObject:SetPoint(curExp, maxExp);


	local skillLevelObject = GET_CHILD(frame, 'labelclassexp', "ui::CRichText");
	skillLevelObject:SetText('{@st42}{s12}{ol}CLv:'..tableinfo.level);


end
function  MINIEXPBAR_ON_MSG(frame, msg, argStr, argNum)
    if msg == 'EXP_UPDATE'  or  msg == 'STAT_UPDATE' or msg == 'LEVEL_UPDATE' or msg == 'CHANGE_COUNTRY' then
        local expGauge 			= GET_CHILD(frame, "gaugecharexp", "ui::CGauge");
		local exp = session.GetEXP()
		local maxExp = session.GetMaxEXP()
		local percent = 0.0;

		if maxExp ~= 0 and maxExp > 0 then
			percent = exp / maxExp * 100;
			expGauge:SetPoint(exp, maxExp);
		elseif maxExp == 0 then
			percent = 100.0;
			expGauge:SetPoint(1,1);				
		end
		
		if percent > 100 then
			percent = 100.0;
		end

		local levelTextObject		= GET_CHILD(frame, "labelcharexp", "ui::CRichText");
		local level 				= info.GetLevel(session.GetMyHandle());
		levelTextObject:SetText('{@st42}{s12}{ol}Lv:'..tostring(level));


    end

end
function MINIEXPBAR_ON_FPS_UPDATE()
    g.frame:ShowWindow(1)
end

function MINIEXPBAR_INIT()
    
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            --frame:RemoveAllChild()
            frame:EnableMove(1)
            
            frame:Resize(100, 40)
            local gaugecharexp=frame:CreateOrGetControl("gauge","gaugecharexp",0,20-7,100,7)
            AUTO_CAST(gaugecharexp)
            gaugecharexp:EnableHitTest(0)
            gaugecharexp:SetSkinName("miniexpbar_gaugeyellow")
            local gaugeclassexp=frame:CreateOrGetControl("gauge","gaugeclassexp",0,40-7,100,7)
            AUTO_CAST(gaugeclassexp)
            gaugeclassexp:EnableHitTest(0)
            gaugeclassexp:SetSkinName("miniexpbar_gaugegreen")
            local labelcharexp=frame:CreateOrGetControl("richtext","labelcharexp",0,0,100,20)
            labelcharexp:EnableHitTest(0)
            --labelcharexp:SetText("{@st42}{s12}{ol}Lv:")
            local labelclassexp=frame:CreateOrGetControl("richtext","labelclassexp",0,20,100,20)
            labelclassexp:EnableHitTest(0)
            --labelclassexp:SetText("{@st42}{s12}{ol}CLv:")
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function MINIEXPBAR_HEADSUPDISPLAY_ON_MSG(frame, msg, argStr, argNum)
    local stat = info.GetStat(session.GetMyHandle());
    if(msg=="STAT_UPDATE")then
        AOS_RENDER()
    end
end
function MINIEXPBAR_TIMER_BEGIN()
    local frame = ui.GetFrame(g.framename)
    frame:CreateOrGetControl("timer", "addontimer", 0, 0, 10, 10)
    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
    timer:SetUpdateScript("MINIEXPBAR_ON_TIMER");
    timer:Start(0.01);

end


function MINIEXPBAR_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function MINIEXPBAR_LBTNUP(parent, ctrl)
    g.settings.x = parent:GetX();
    g.settings.y = parent:GetY();
    MINIEXPBAR_SAVE_SETTINGS()
end
