--アドオン名（大文字）
local addonName = "wikihelp"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {x = 300, y = 300}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "wikihelp"
g.debug = true
g.handle = nil
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)
g.interlocked = false
g.currentIndex = 1
g.x = nil
g.y = nil
g.history = {}
-- g.baseClass = {
--     Cleric = "クレリック",
--     Archer = "アーチャー",
--     Warrior = "ソードマン",
--     Wizard = "ウィザード",
--     Scout = "スカウト"
-- }
-- g.Quest = {
--     ["防衛戦ミッション"] = "Quest/防衛戦",
--     ["七彩谷ミッション"] = "Quest/依頼所",
--     ["シャウレイミッション"] = "Quest/依頼所",
--     ["水晶鉱山ミッション"] = "Quest/依頼所",
--     ["カタコムミッション"] = "Quest/依頼所",
--     ["聖堂地下ダンジョン"] = "Map/インスタンスダンジョン/聖堂地下ダンジョン",
--     ["廃墟の遺跡"] = "Map/インスタンスダンジョン/廃墟の遺跡ダンジョン",
--     ["念願の碑石路ダンジョン"] = "Map/インスタンスダンジョン/念願の碑石路ダンジョン",
--     ["キャッスル地下ダンジョン"] = "Map/インスタンスダンジョン/キャッスルダンジョン",
--     ["ランコ湖ダンジョン"] = "Map/インスタンスダンジョン/ランコ湖ダンジョン",
--     ["依頼所ミッション"] = "Quest/依頼所",
--     ["ベルカッパーの巣"] = "Map/インスタンスダンジョン/ベルコッパーの巣",
--     ["大地の塔"] = "Map/インスタンスダンジョン/大地の塔",
--     ["白カラスの永眠地:レジェンド"] = "白カラスの永眠地：レジェンド",
    
--     ["白カラスの永眠地:ユニーク"] = "白カラスの永眠地：ユニーク",
--     ["一番目の避難所"] = "Map/インスタンスダンジョン/ユニークレイド",
--     ["峡谷地帯ミッション"] = "Quest/サルラス修道女院",
--     ["王陵ミッション"] = "Quest/サルラス修道女院",
--     ["キャッスルミッション"] = "Quest/サルラス修道女院",
--     ["防衛戦ミッション"] = "Quest/防衛戦",
    


-- }
--ライブラリ読み込み
CHAT_SYSTEM("[wikihelp]loaded")
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



local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end

local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
end

local urldecode = function(url)
    if url == nil then
        return
    end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", hex_to_char)
    return url
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function WIKIHELP_DBGOUT(msg)
    
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
function WIKIHELP_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function WIKIHELP_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function WIKIHELP_LOAD_SETTINGS()
    WIKIHELP_DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        WIKIHELP_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    WIKIHELP_UPGRADE_SETTINGS()
    WIKIHELP_SAVE_SETTINGS()

end


function WIKIHELP_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=WIKIHELP_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function WIKIHELP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
   
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('WIKIHELP', 'sysmenu_sys', 'WIKIHELP', 'WIKIHELP_TOGGLE_FRAME')
            acutil.setupHook(WIKIHELP_UPDATE_CHANGEJOB, "UPDATE_CHANGEJOB")
            acutil.setupHook(WIKIHELP_CHANGEJOB_CLOSE, "CHANGEJOB_CLOSE")
            acutil.setupHook(WIKIHELP_INDUNINFO_MAKE_DETAIL_INFO_BOX, "INDUNINFO_MAKE_DETAIL_INFO_BOX")
            acutil.setupHook(WIKIHELP_SHOW_INDUNENTER_DIALOG, "SHOW_INDUNENTER_DIALOG")
            
            --addon:RegisterMsg('GAME_START_3SEC', 'WIKIHELP_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("WIKIHELP_ON_TIMER");
            timer:Start(0.1);
            --WIKIHELP_SHOW(g.frame)
            WIKIHELP_INIT()
        --g.frame:ShowWindow(0)
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end
function WIKIHELP_INDUNINFO_MAKE_DETAIL_INFO_BOX(frame, indunClassID)
    return EBI_try_catch{
        try = function()
            local result=INDUNINFO_MAKE_DETAIL_INFO_BOX_OLD(frame, indunClassID)

            local indunClassID = indunClassID;

            local btn = frame:CreateOrGetControl("button", "wikiinfo", 900, 250, 80, 50)
            btn:SetOffset( 900, 230)
            local indunCls = GetClassByType('Indun', indunClassID);
            local name = dictionary.ReplaceDicIDInCompStr(indunCls.Name)
            local conv = name
            if (g.Quest[conv]) then
                conv = g.Quest[conv]
            end
            btn:SetText("{s16}{ol}WikiHelp")
            btn:SetEventScript(ui.LBUTTONUP, "WIKIHELP_RENDERER_CLICK_A")
            btn:SetEventScriptArgString(ui.LBUTTONUP, conv)
            btn:SetSkinName("test_skin_01_btn")
            return result
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end
function WIKIHELP_SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
    local result = SHOW_INDUNENTER_DIALOG_OLD(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame('indunenter');
            local btn = frame:CreateOrGetControl("button", "wikiinfo", 470, 110, 60, 40)
            local indunCls = GetClassByType('Indun', indunType);
            local conv = dictionary.ReplaceDicIDInCompStr(indunCls.Name)
            if (g.Quest[conv]) then
                conv = g.Quest[conv]
            end
            btn:SetText("{s16}{ol}WikiHelp")
            btn:SetEventScript(ui.LBUTTONUP, "WIKIHELP_RENDERER_CLICK_A")
            btn:SetEventScriptArgString(ui.LBUTTONUP, conv)
            btn:SetSkinName("test_skin_01_btn")
            return result
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end
function WIKIHELP_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function WIKIHELP_OPEN(frame)

end
function WIKIHELP_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    local gbox = frame:GetChild("gbox")
    tolua.cast(gbox, "ui::CGroupBox")
    
    local pic = gbox:GetChild("pict")
    tolua.cast(pic, "ui::CGroupBox")
    frame:ShowWindow(0)
end
function WIKIHELP_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end
function WIKIHELP_CHANGEJOB_CLOSE(frame)
    CHANGEJOB_CLOSE_OLD(frame)
    local gbox = frame:GetChild("gbox")
    tolua.cast(gbox, "ui::CGroupBox")
    
    local pic = gbox:GetChild("pict")
    tolua.cast(pic, "ui::CGroupBox")
end
function WIKIHELP_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            --frame:GetChild("equip"):Resize(800, 990)
            frame:SetLayerLevel(120)
            frame:RemoveChild("nameText")
            frame:EnableResize(1)
            local gbox = frame:CreateOrGetControl("groupbox", "gbox", 8, 100, frame:GetWidth() - 16, frame:GetHeight() - 180)
            tolua.cast(gbox, "ui::CGroupBox")
            gbox:EnableHitTest(1)
            gbox:EnableAutoResize(false, false)
            gbox:EnableScrollBar(0)
            gbox:EnableHittestGroupBox(true)
            gbox:SetSkinName("test_frame_midle")
            gbox:RemoveAllChild()
            local gboxinner = gbox:CreateOrGetControl("groupbox", "gboxi", 8, 8, gbox:GetWidth() - 16, gbox:GetHeight() - 16)
            tolua.cast(gboxinner, "ui::CGroupBox")
            gboxinner:EnableHitTest(1)
            gboxinner:EnableHittestGroupBox(true)
            gboxinner:EnableAutoResize(false, false)
            gboxinner:EnableScrollBar(0)
            local pic = gboxinner:CreateOrGetControl("groupbox", "pict", 0, 0, gboxinner:GetWidth() - 16, gboxinner:GetHeight() - 180)
            tolua.cast(pic, "ui::CGroupBox")
            pic:EnableScrollBar(0)
            pic:EnableHitTest(0)
            pic:EnableHittestGroupBox(true)
            pic:EnableAutoResize(true, true)
            gboxinner:SetEventScript(ui.MOUSEWHEEL, "WIKIHELP_MOUSEWHEEL");
            gboxinner:SetEventScript(ui.LBUTTONDOWN, "WIKIHELP_LBTNDOWN");
            gboxinner:SetEventScript(ui.LBUTTONUP, "WIKIHELP_LBTNUP");
            
            local title = GET_CHILD_RECURSIVELY(frame, "changeName")
            title:SetText("{s24}{ol}WikiHelp")
            title:SetEventScript(ui.LBUTTONUP, "WIKIHELP_RENDERER_CLICK_A");
            title:SetEventScriptArgString(ui.LBUTTONUP, "MenuBar");
        
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end

function WIKIHELP_RENDER(name)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local pic = GET_CHILD_RECURSIVELY(frame, "pict")
            tolua.cast(pic, "ui::CGroupBox")
            pic:RemoveAllChild()
            pic:SetOffset(0, 0)
            local parser = WIKIHELP_MEDIAWIKIPARSER
            local renderer = WIKIHELP_MEDIAWIKIRENDERER
            
            name = name or "MenuBar"
            local pagename = GET_CHILD_RECURSIVELY(frame, "LevJobText")
            pagename:SetText("{s20}{ol}" .. name)
            local node=parser.parse({},WIKIHELP_MEDIAWIKIPAGES_SAMPLE["Oracle"],"Oracle")
            renderer.render(pic,node)
            pic:AutoSize(1)
            WIKIHELP_DBGOUT("render")
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end
function WIKIHELP_LBTNDOWN(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    local pic = GET_CHILD_RECURSIVELY(frame, "pict");
    --pic = ctrl
    if (pic == nil) then
        return
    end
    local x, y = GET_MOUSE_POS();
    
    g.x = x -- 드래그할 때, 클릭한 좌표를 기억한다.
    g.y = y
    
    ui.EnableToolTip(0);
    mouse.ChangeCursorImg("MOVE_MAP", 1);
    ctrl:RunUpdateScript("WIKIHELP_PROCESS_MOUSE");
end
function WIKIHELP_BACK()
    
    if (#g.history > 1) then
        local pict=GET_CHILD_RECURSIVELY(ui.GetFrame("wikihelp"),"pict")
        WIKIHELP_RENDER(g.history[#g.history - 1].name)
        pict:SetOffset(g.history[#g.history].x,g.history[#g.history].y)
        table.remove(g.history, #g.history)
    end
end
function WIKIHELP_LBTNUP(parent, ctrl)
    -- 워프 위치에서 마우스를 떼지 않았다면 클릭한 좌표를 리셋한다.
    g.x = nil
    g.y = nil
end
function WIKIHELP_PROCESS_MOUSE(ctrl)
    return EBI_try_catch{
        try = function()
            if mouse.IsLBtnPressed() == 0 then
                mouse.ChangeCursorImg("BASIC", 0);
                ui.EnableToolTip(1);
                return 0;
            end
            local pic = GET_CHILD_RECURSIVELY(ctrl, "pict");
            --local pic = ctrl
            if (pic == nil) then
                return
            end
            local mx, my = GET_MOUSE_POS();
            local x = g.x;
            local y = g.y;
            local dx = mx - x;
            local dy = my - y;
            dx = dx;
            dy = dy;
            
            local cx = pic:GetX();
            local cy = pic:GetY();
            cx = cx + dx;
            cy = cy + dy;
            g.x = mx
            g.y = my
            --cx=math.max(-pic:GetWidth()+pic:GetParent():GetWidth(),math.min(cx,0))
            --cy=math.max(-pic:GetHeight()+pic:GetParent():GetHeight(),math.min(cy,0))
            pic:SetOffset(cx, cy)
            
            return 1;
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end

function WIKIHELP_MOUSEWHEEL(parent, ctrl, s, n)
    
    local pic = GET_CHILD_RECURSIVELY(ctrl, "pict");
    --local pic = ctrl
    if (pic == nil) then
        return
    end
    local dx = 0;
    local dy = n;
    local cx = pic:GetX();
    local cy = pic:GetY();
    cx = cx + dx;
    cy = cy + dy;
    --cx=math.max(-pic:GetWidth()+pic:GetParent():GetWidth(),math.min(cx,0))
    --cy=math.max(-pic:GetHeight()+pic:GetParent():GetHeight(),math.min(cy,0))
    pic:SetOffset(cx, cy)

end

local function IS_NEW_JOB(jobCls)
    if jobCls.ClassName == 'Char3_18' or jobCls.ClassName == 'Char3_19' or jobCls.ClassName == 'Char5_13' or jobCls.ClassName == 'Char5_14' then
        return true;
    end
    return false;
end

function WIKIHELP_UPDATE_CHANGEJOB(frame)
    EBI_try_catch{
        try = function()
            local function _IS_SATISFIED_HIDDEN_JOB_TRIGGER(jobCls)
                local preFuncName = TryGetProp(jobCls, 'PreFunction', 'None');
                if jobCls.HiddenJob == 'NO' then
                    return true;
                end
                
                if preFuncName == 'None' then
                    return true;
                end
                --	if jobCls.HiddenJob == "YES" then
                --    	local pcEtc = GetMyEtcObject();
                --    	if pcEtc["HiddenJob_"..jobCls.ClassName] ~= 300 and IS_KOR_TEST_SERVER() == false then
                --    	    return false;
                --    	end
                --	end
                return false;
            end
            UPDATE_CHANGEJOB_OLD(frame)
            WIKIHELP_DBGOUT("HOOK")
            local pc = GetMyPCObject();
            local pcjobinfo = GetClass('Job', pc.JobName)
            local pcCtrlType = pcjobinfo.CtrlType
            local jobInfos = {};
            local forHotJobList = {};
            local jobList, jobCnt = GetClassList("Job");
            for i = 0, jobCnt - 1 do
                WIKIHELP_DBGOUT("GOO")
                local jobCls = GetClassByIndexFromList(jobList, i);
                if pcCtrlType == jobCls.CtrlType and jobCls.Rank <= JOB_CHANGE_MAX_RANK then
                    jobInfos[#jobInfos + 1] = {JobClassID = jobCls.ClassID,
                        IsHave = IS_HAD_JOB(jobCls.ClassID),
                        IsNew = IS_NEW_JOB(jobCls),
                        HotCount = session.GetChangeJobHotRank(jobCls.ClassName),
                        IsSatisfiedHiddenQuest = _IS_SATISFIED_HIDDEN_JOB_TRIGGER(jobCls)};
                
                end
            end
            for i = 1, #jobInfos do
                WIKIHELP_DBGOUT("INSERT")
                local info = jobInfos[i];
                local jobCls = GetClassByType('Job', info.JobClassID);
                
                local cjobGbox = GET_CHILD_RECURSIVELY(frame, 'changeJobGbox');
                tolua.cast(cjobGbox, "ui::CGroupBox")
                local subClassCtrl = cjobGbox:GetChild('JOB_INFO_' .. jobCls.ClassName);
                local button = GET_CHILD(subClassCtrl, "button");
                button:SetEventScript(ui.RBUTTONUP, 'WIKIHELP_OPENWIKI')
                button:SetEventScriptArgNumber(ui.RBUTTONUP, info.JobClassID);
                button:SetEventScriptArgString(ui.RBUTTONUP, jobCls.Name);
            end
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end
function WIKIHELP_OPENWIKI(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            WIKIHELP_SHOW()
            local pic = GET_CHILD_RECURSIVELY(frame, "pict")
            tolua.cast("ui::CGroupBox")
            local pc = GetMyPCObject();
            local pcjobinfo = GetClass('Job', pc.JobName)
            WIKIHELP_DBGOUT(pcjobinfo.CtrlType)
            imcSound.PlaySoundEvent("button_click_big")
            local jobname = dictionary.ReplaceDicIDInCompStr(argstr)
            local name
            if (g.baseClass[pcjobinfo.CtrlType] == dictionary.ReplaceDicIDInCompStr(argstr)) then
                name = "Class/Re" .. dictionary.ReplaceDicIDInCompStr(argstr);
            else
                local dic = dictionary.ReplaceDicIDInCompStr(argstr):gsub("{s18}", "")
                if (dic == "巫女") then
                    name = "Class/Re" .. g.baseClass[pcjobinfo.CtrlType] .. "/Re巫女神主";
                else
                    name = "Class/Re" .. g.baseClass[pcjobinfo.CtrlType] .. "/Re" .. dic;
                end
            end

            WIKIHELP_NAVIGATE(name)
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end
function WIKIHELP_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
        
        end,
        catch = function(error)
            WIKIHELP_ERROUT(error)
        end
    }
end

function WIKIHELP_RENDERER_CLICK_A(frame, ctrl, argstr, argnum)
    
    if (argstr:starts("http")) then
        login.OpenURL(argstr)
    else
        WIKIHELP_NAVIGATE(argstr)
    end
end
function WIKIHELP_NAVIGATE(name)
    
    WIKIHELP_DBGOUT(name)
    
    if (ui.GetFrame("wikihelp"):IsVisible() == 0) then
        WIKIHELP_SHOW()
    end
    local pict=GET_CHILD_RECURSIVELY(ui.GetFrame("wikihelp"),"pict")
    g.history[#g.history + 1] = {
        name=name,
        x=pict:GetX(),
        y=pict:GetY(),
        
    }
    WIKIHELP_RENDER(name)

end
