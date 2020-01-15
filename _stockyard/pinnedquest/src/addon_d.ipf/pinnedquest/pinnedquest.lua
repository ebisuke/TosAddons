-- アドオン名（大文字）
local addonName = "pinnedquest"
local addonNameLower = string.lower(addonName)
-- 作者名
local author = "ebisuke"

-- アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

-- 設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.isquestdialog = 0
g.debug = false
g.debugshowall = false
g.needtoinit = true
-- ライブラリ読み込み
local acutil = require('acutil')


--バージョン0の設定
function PINNEDQUEST_DEFAULTSETTINGS()
    return {
            -- 有効/無効
            enable = true,
            -- フレーム表示場所
            position = {x = 0, y = 0}
    }
end
--バージョン0の設定
function PINNEDQUEST_DEFAULTPERSONALSETTINGS()
    return {enabled = nil, pinnedquest = {}, pinnedparty = {}}
end
-- デフォルト設定
if not g.loaded then
    g.settings = PINNEDQUEST_DEFAULTSETTINGS()
    g.personalsettings = PINNEDQUEST_DEFAULTPERSONALSETTINGS()
end
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then what.catch(result) end
    return result
end
function EBI_IsNoneOrNil(val) return val == nil or val == "None" or val == "nil" end
function PINNEDQUEST_DBGOUT(msg)
    
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
        catch = function(error) end
    }

end
function PINNEDQUEST_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error) end
    }

end
-- lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName))


-- マップ読み込み時処理（1度だけ）
function PINNEDQUEST_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            
            g.addon = addon
            frame = ui.GetFrame("pinnedquest")
            g.frame = frame
            
            frame:ShowWindow(0)
            PINNEDQUEST_LOAD_SETTINGS()
            g.loaded = true
            -- 設定ファイル保存処理
            PINNEDQUEST_SAVE_SETTINGS()
            -- メッセージ受信登録処理
            -- addon:RegisterMsg("メッセージ", "内部処理");
            -- コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "PINNEDQUEST_CONTEXT_MENU");
            -- ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "PINNEDQUEST_END_DRAG")
            addon:RegisterMsg('GET_NEW_QUEST', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('GAME_START_3SEC', 'PINNEDQUEST_3SEC')
            addon:RegisterMsg('FPS_UPDATE', 'PINNEDQUEST_FPS_UPDATE')
            addon:RegisterMsg('QUEST_UPDATE', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('AVANDON_QUEST', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('QUEST_DELETED', 'PINNEDQUEST_ENSUREQUEST')
            --addon:RegisterMsg('CUSTOM_QUEST_UPDATE', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('CUSTOM_QUEST_DELETE', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('DIALOG_ADD_SELECT', 'PINNEDQUEST_HOOKDIALOG_ADD_SELECT')
            addon:RegisterMsg('DIALOG_CLOSE', 'PINNEDQUEST_HOOKDIALOG_CLOSE');
            --addon:RegisterMsg('QUEST_UPDATE_', 'PINNEDQUEST_ENSUREQUEST')
            -- フレーム初期化処理
            PINNEDQUEST_INIT_FRAME()
            
            -- 再表示処理
            -- if g.settings.enable then
            --  frame:ShowWindow(1);
            -- else
            -- frame:ShowWindow(0);
            -- end
            -- Moveではうまくいかないので、OffSetを使用する…
            frame:Move(0, 0)
            frame:SetOffset(g.settings.position.x, g.settings.position.y)
            g.needtoinit = true
            if (OLD_QUEST_FRAME_OPEN == nil) then
                OLD_QUEST_FRAME_OPEN = QUEST_FRAME_OPEN
                QUEST_FRAME_OPEN = PINNEDQUEST_QUEST_FRAME_OPEN_JUMPER
            end
            if (OLD_UPDATE_QUESTINFOSET_2 == nil)then
                OLD_UPDATE_QUESTINFOSET_2=UPDATE_QUESTINFOSET_2
                UPDATE_QUESTINFOSET_2=PINNEDQUEST_UPDATE_QUESTINFOSET_2_JUMPER
            end
            PINNEDQUEST_DBGOUT("INIT")
           
        end,
        catch = function(error)PINNEDQUEST_ERROUT(error) end
    }
end
function PINNEDQUEST_QUEST_FRAME_OPEN_JUMPER(frame)
    if (OLD_QUEST_FRAME_OPEN ~= nil) then 
        OLD_QUEST_FRAME_OPEN(frame) 
    end
    
    PINNEDQUEST_QUEST_FRAME_OPEN(frame)
end
function PINNEDQUEST_SAVE_SETTINGS()
    g.personalsettingsFileLoc = string.format(
        '../addons/%s/settings_%s.json',
        addonNameLower,
        tostring(
            session.GetMySession():GetCID()))
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end
function PINNEDQUEST_LOAD_SETTINGS()
    g.personalsettingsFileLoc = string.format(
        '../addons/%s/settings_%s.json',
        addonNameLower,
        tostring(
            session.GetMySession():GetCID()))
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format('[%s] cannot load setting files', addonName))
        g.settings = {
                -- 有効/無効
                enable = true,
                -- フレーム表示場所
                position = {x = 0, y = 0}
        }
    else
        -- 設定ファイル読み込み成功時処理
        g.settings = t
    
    end
    g.personalsettings = {}
    local t, err =
        acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format('[%s] cannot load personal setting files',
            addonName))
        g.personalsettings = {enabled = nil, pinnedquest = {}, pinnedparty = {}}
    else
        -- 設定ファイル読み込み成功時処理
        g.personalsettings = t
    
    end
    PINNEDQUEST_UPDATESETTING()
    PINNEDQUEST_UPDATEPERSONALSETTING()
end
function PINNEDQUEST_UPDATESETTING()
    -- ver nil to 1
    if (not g.settings.version) then
        g.settings.version = 1
        g.settings.enablesetpartywhenaccept = true
        CHAT_SYSTEM("[PQ]設定ファイルバージョンアップ 0->1")
    end
end

function PINNEDQUEST_UPDATEPERSONALSETTING()
    -- ver nil to 1
    if (not g.personalsettings.version) then
        if (g.personalsettings.enabled == nil) then
            g.personalsettings.enabled = false
            ReserveScript("PINNEDQUEST_VER0_1_PINN()", 5.0)
        end
        g.personalsettings.version = 1
        CHAT_SYSTEM("[PQ]個人設定ファイルバージョンアップ 0->1")
    end
end
function PINNEDQUEST_VER0_1_PINN()
    g.personalsettings.enabled = true
    -- 現在アサインされているクエストをピン止め
    local cnt = quest.GetCheckQuestCount()
    
    -- ver nil to 1
    g.personalsettings.pinnedquest = {}
    
    for i = 0, cnt - 1 do
        local questID = quest.GetCheckQuest(i)
        PINNEDQUEST_ERROUT("ID" .. tostring(questID))
        g.personalsettings.pinnedquest[tostring(questID)] = true
    end
    CHAT_SYSTEM("[PQ]現在のクエストをピン止めしました")
end
function PINNEDQUEST_UPDATE_QUESTINFOSET_2_JUMPER(frame, msg, check, updateQuestID)
    PINNEDQUEST_UPDATE_QUESTINFOSET_2(frame,msg,check,updateQuestID)
end
function PINNEDQUEST_UPDATE_QUESTINFOSET_2(frame, msg, check, updateQuestID)
    EBI_try_catch{
        try=function()
            OLD_UPDATE_QUESTINFOSET_2(frame,msg,check,updateQuestID)
            if UI_CHECK_NOT_PVP_MAP() == 0 then

                return;
            end

        end,

        catch=function (error)
            PINNEDQUEST_ERROUT(error)
        end
    }
    

end

function PINNEDQUEST_QUEST_FRAME_OPEN(frame)


    local btnspq = frame:CreateOrGetControl("button", "showpq", 25, 90, 100, 40)
    btnspq:SetText("PQ設定")
    btnspq:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_TOGGLE_FRAME")
    -- local btnclean = frame:CreateOrGetControl("button", "pqclean", 410, 90, 100,
    --     40)
    -- btnclean:SetText("PQ更新")
    -- btnclean:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_REFRESH")
    
    local frameg = ui.GetFrame("pinnedquest")
    frameg:Resize(500, 180)
    -- local gb = frameg:GetChild("quests")
    -- gb:Resize(500, 300)
    -- gb:SetOffset(0, 180)
    -- frameg:CreateOrGetControl("richtext", "label1", 20, 120, 60, 20):SetText(
    --     "{ol}ピン止め")
    -- frameg:CreateOrGetControl("richtext", "label2", 100, 120, 60, 20):SetText(
    --     "{ol}チェック")
    -- frameg:CreateOrGetControl("richtext", "label3", 20, 140, 30, 20):SetText(
    --     "{ol}ｸｴ")
    -- frameg:CreateOrGetControl("richtext", "label4", 60, 140, 30, 20):SetText(
    --     "{ol}PT")
    -- frameg:CreateOrGetControl("richtext", "label5", 100, 140, 30, 20):SetText(
    --     "{ol}ｸｴ")
    -- frameg:CreateOrGetControl("richtext", "label6", 140, 140, 30, 20):SetText(
    --     "{ol}PT")
    -- frameg:CreateOrGetControl("richtext", "label7", 180, 140, 100, 20):SetText(
    --     "{ol}クエスト名")
    frameg:SetLayerLevel(95)
    local btnr = frameg:CreateOrGetControl("button", "btnrefresh", 20, 80, 60, 40)
    local chkenable = frameg:CreateOrGetControl("checkbox", "chkenable", 100, 80, 100, 20)
    tolua.cast(chkenable, "ui::CCheckBox")
    if (g.personalsettings.enabled == true) then
        chkenable:SetCheck(1)
    else
        chkenable:SetCheck(0)
    end
    chkenable:SetText("{ol}このキャラで使用する")
    chkenable:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_ON_CHECK_CHANGED")
    
    local chkaccs = frameg:CreateOrGetControl("checkbox", "chkaccs", 100, 100, 200, 20)
    tolua.cast(chkaccs, "ui::CCheckBox")
    if (g.settings.enablesetpartywhenaccept == true) then
        chkaccs:SetCheck(1)
    else
        chkaccs:SetCheck(0)
    end
    chkaccs:SetText("{ol}クエスト受注時にPT共有（共通）")
    chkaccs:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_ON_CHECK_CHANGED")
    
    btnr:SetText("更新")
    btnr:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_REFRESH")
    -- frameg:CreateOrGetControl("richtext","label8",400,120,100,20):SetText("{ol}前提")
    --PINNEDQUEST_UPDATELIST_QUEST(frameg)
end


function PINNEDQUEST_INIT_FRAME(frame)
    -- XMLに記載するとデザイン調整時にクライアント再起動が必要になるため、luaに書き込むことをオススメする
    -- フレーム初期化処理
    if (frame == nil) then frame = ui.GetFrame("pinnedquest") end

end
function PINNEDQUEST_ON_CHECK_CHANGED(frame, ctrl)
    tolua.cast(ctrl, "ui::CCheckBox")
    local name = ctrl:GetName()
    if (name == "chkenable") then
        if (ctrl:IsChecked() == 1) then
            g.personalsettings.enabled = true;
        else
            g.personalsettings.enabled = false;
        end
        PINNEDQUEST_UPDATEQUESTLIST()
        PINNEDQUEST_UPDATELIST_QUEST()
    elseif (name == "chkaccs") then
        if (ctrl:IsChecked() == 1) then
            g.settings.enablesetpartywhenaccept = true;
        else
            g.settings.enablesetpartywhenaccept = false;
        end
    end
    PINNEDQUEST_SAVE_SETTINGS()


end
function PINNEDQUEST_FPS_UPDATE(frame)
    --FPS UPDATE
    EBI_try_catch{
        try=function()
            local frm=ui.GetFrame("pqoverlay")
            if(frm~=nil)then
                frm:ShowWindow(1)
            end
        end,
        catch=function(error)
            PINNEDQUEST_ERROUT(error)
        end
    }

   
end
function PINNEDQUEST_3SEC(frame)
    --3SEC ACTION
    EBI_try_catch{
        try=function()
            
            PINNEDQUEST_INJECTCONTROLS()

        end,
        catch=function(error)
            PINNEDQUEST_ERROUT(error)
        end
    }

    --PINNEDQUEST_ENSUREQUEST()
    --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST()",1)
   
end
function PINNEDQUEST_INJECTCONTROLS()
    local frame=ui.GetFrame("pqoverlay")
    if(frame==nil)then
        frame=ui.CreateNewFrame("pqoverlay","pqoverlay")
    end


    -- reposition 
    local questframe=ui.GetFrame("questinfoset_2")
    if(questframe~=nil)then
        frame:SetOffset(questframe:GetX(),questframe:GetY()-28)
        frame:Resize(questframe:GetWidth(),700)
    else
        frame:SetOffset(1500,417-28)
        frame:Resize(400,700)
    end
    frame:ShowWindow(1)
    frame:SetLayerLevel(60)
    frame:EnableHittestFrame(0)

    local gbox=frame:CreateOrGetControl("groupbox","member",0,28,questframe:GetWidth(),questframe:GetHeight())
    gbox:ShowWindow(0)
    gbox:SetOffset(0,28)
    local btnchange=frame:CreateOrGetControl("button","btnchange",0,0,24,24)
    tolua.cast(btnchange,"ui::CButton")
    btnchange:SetImage("button_view_info")
    btnchange:SetOverSound("button_over")
    btnchange:SetClickSound("button_click_big")
    btnchange:SetGravity(ui.RIGHT,ui.TOP)
    btnchange:SetTextTooltip("PinnedQuest 設定 / クエストログ切り替え")
    btnchange:SetEventScript(ui.LBUTTONUP,"PINNEDQUEST_SWAPGBOX")
    local labelpq=frame:CreateOrGetControl("richtext","labelpq",0,0,100,20)
    labelpq:SetGravity(ui.CENTER_HORZ,ui.TOP)
    labelpq:SetText("{ol}PinnedQuest 設定")
    labelpq:ShowWindow(0)
    labelpq:SetTextTooltip("ここをクリックすると最新の情報に更新します")
    labelpq:SetOverSound("button_over")
    labelpq:SetClickSound("button_click_big")
    labelpq:SetEventScript(ui.LBUTTONUP,"PINNEDQUEST_REFRESH")
    local gboxpq=frame:CreateOrGetControl("groupbox","gboxpq",0,28,frame:GetWidth(),frame:GetHeight()-28-100)
    tolua.cast(gboxpq,"ui::CGroupBox")
    gboxpq:EnableDrawFrame(1)
    gboxpq:EnableResizeByParent(0)
    --デフォルトではOFF
    gboxpq:ShowWindow(0)
end
function PINNEDQUEST_SWAPGBOX()
    EBI_try_catch{
        try=function()
            local frame=ui.GetFrame("pqoverlay")
            local gbox=frame:GetChild("member")
            local gboxpq=PINNEDQUEST_GETPQQUESTBOX()
            local labelpq=frame:GetChild("labelpq")
            if(gboxpq:IsVisible()==0)then
                frame:EnableHittestFrame(0)

                --PQ表示
                --gbox:ShowWindow(0)
                gboxpq:ShowWindow(1)
                labelpq:ShowWindow(1)
               
                if(g.needtoinit)then
                    PINNEDQUEST_UPDATELIST_QUEST()
                    g.needtoinit=false
                end
                gboxpq:SetSkinName("chat_window_2")
            else
                frame:EnableHittestFrame(0)

                --gbox:ShowWindow(0)
                gboxpq:SetSkinName("None")
                gboxpq:ShowWindow(0)
                labelpq:ShowWindow(0)
            end
        end,
        catch=function(error)
            PINNEDQUEST_ERROUT(error)
        end
    }
end
function PINNEDQUEST_GETPQQUESTBOX()
    local frame=ui.GetFrame("pqoverlay")
    return GET_CHILD(frame,"gboxpq","ui::CGroupBox")
end
function PINNEDQUEST_CALCQUESTRANK(aaa)
    
    local value = 0
    local sobjIES = GET_MAIN_SOBJ()
    local questIES = aaa
    local questClassName = questIES.ClassName
    if questClassName ~= "None" then
        local abandonCheck = QUEST_ABANDON_RESTARTLIST_CHECK(questIES, sobjIES)
        if abandonCheck == 'NOTABANDON' or abandonCheck == 'ABANDON/NOTLIST' then
            if IS_ABOUT_JOB(questIES) == false then
                local result = SCR_QUEST_CHECK_C(pc, questClassName)
                if result == "SUCCESS" then
                    value = 10000 - questIES.Level
                elseif result == 'PROGRESS' then
                    if questIES.QuestMode == 'MAIN' then
                        value = 10000 + 10000 - questIES.Level
                    else
                        value = 10000 + 10000 - questIES.Level + 50000
                    end
                elseif result == 'POSSIBLE' then
                    if questIES.QuestMode == 'MAIN' then
                        value = 100000 + 10000 - questIES.Level
                    else
                        value = 100000 + 10000 - questIES.Level + 50000
                    end
                else
                    value = 999999999
                end
            end
        end
    
    else
        value = 999999999
    end
    return value
end
function PINNEDQUEST_UPDATELIST_QUEST(frame, lightweight)
    EBI_try_catch{
        try = function()
            -- if (frame == nil) then
            --     frame = ui.GetFrame("pinnedquest")
            -- end
            -- ｸｴリストを更新
            local grpbox = PINNEDQUEST_GETPQQUESTBOX()
            if (not lightweight) then grpbox:RemoveAllChild() end
            local sobjIES = GET_MAIN_SOBJ()
            
            local clsList, cnt = GetClassList("QuestProgressCheck")
            
            local listcnt = 0
            local list = {}
            for i = 0, cnt - 1 do
                list[#list + 1] = GetClassByIndexFromList(clsList, i)
            end
            -- ソート
            table.sort(list, function(a, b)
                return PINNEDQUEST_CALCQUESTRANK(a) <
                    PINNEDQUEST_CALCQUESTRANK(b)
            end)
            
            for i = 0, cnt - 1 do
                local questIES = list[i + 1]
                local questClassName = questIES.ClassName
                if questClassName ~= "None" then
                    local abandonCheck =
                        QUEST_ABANDON_RESTARTLIST_CHECK(questIES, sobjIES)
                    if abandonCheck == 'NOTABANDON' or abandonCheck ==
                        'ABANDON/NOTLIST' then
                        --if IS_ABOUT_JOB(questIES) == false then
                        local result = SCR_QUEST_CHECK_C(pc, questClassName)
                        
                        if result == 'POSSIBLE' or result == 'PROGRESS' or
                            result == "SUCCESS" then
                            local pass = true
                            if result == 'POSSIBLE' then
                                local result1, subQuestZoneList = HIDE_IN_QUEST_LIST(GetMyPCObject(), questIES, nil, {})
                                if (result1 == 1) then
                                    pass = false
                                end
                            end

                            if(g.debugshowall)then
                                pass=true
                            end
                            if (pass) then
                                local pictraw =
                                    grpbox:CreateOrGetControl("picture",
                                        "pic" ..
                                        tostring(
                                            listcnt),
                                        100,
                                        listcnt * 20,
                                        20, 20)
                                local descraw =
                                    grpbox:CreateOrGetControl("richtext",
                                        "questname" ..
                                        tostring(
                                            listcnt),
                                        120,
                                        listcnt * 20,
                                        200, 20)
                                local chkpqr =
                                    grpbox:CreateOrGetControl("checkbox",
                                        "pq" ..
                                        tostring(
                                            listcnt),
                                        20,
                                        listcnt * 20,
                                        24, 24)
                                local chkppr =
                                    grpbox:CreateOrGetControl("checkbox",
                                        "pp" ..
                                        tostring(
                                            listcnt),
                                        60,
                                        listcnt * 20,
                                        24, 24)

                                local chkpq =
                                    tolua.cast(chkpqr, "ui::CCheckBox")
                                local chkpp =
                                    tolua.cast(chkppr, "ui::CCheckBox")

                                if (not lightweight) then
                                    local questIconImgName =
                                        GET_ICON_BY_STATE_MODE(result,
                                            questIES)
                                    
                                    local pict =
                                        tolua.cast(pictraw, "ui::CPicture")
                                    pict:SetImage(questIconImgName)
                                    pict:SetEnableStretch(1)
                                    pict:SetEventScript(ui.LBUTTONDOWN,
                                        "QUEST_CLICK_INFO")
                                    pict:SetEventScriptArgNumber(
                                        ui.LBUTTONDOWN, questIES.ClassID)

                                    
                                    descraw:SetText(
                                        "{ol}" ..
                                        string.format("(Lv%d)%s",
                                            questIES.Level,
                                            questIES.Name))
                                    local zoneName=""
                                    local zoneIES = GetClass('Map', questIES.StartMap)
                                    if zoneIES ~= nil then
                                        zoneName = zoneIES.Name
                                    else
                                        zoneName = ScpArgMsg('IndunRewardItem_Empty')
                                    end

                                    -- descraw:SetTextTooltip("クエスト開始地域: "..zoneName)
                                    descraw:SetEventScript(ui.LBUTTONDOWN,
                                        "PINNEDQUEST_QUEST_CLICK_INFO")
                                    descraw:SetEventScriptArgNumber(
                                        ui.LBUTTONDOWN, questIES.ClassID)
                                    -- local req=PINNEDQUEST_GETLINKQUEST(questIES.ClassID)
                                    -- if req then
                                    --   --local preQuestIES = req;
                                    --   local reqraw=grpbox:CreateOrGetControl("richtext","required"..tostring(listcnt),400,listcnt*20,200,20)
                                    --   reqraw:SetText("{ol}"..string.format("(Lv%d)%s",req.Level,req.Name));
                                    -- end
                                    chkpq:SetEventScript(ui.LBUTTONDOWN,
                                        "PINNEDQUEST_CHECK")
                                    chkpq:SetEventScriptArgNumber(
                                        ui.LBUTTONDOWN, questIES.ClassID)
                                    chkpq:SetEventScriptArgString(
                                        ui.LBUTTONDOWN, "pq")
                                    chkpq:SetClickSound('button_click_big')
                                    chkpq:SetTextTooltip("ピン止め クエスト")
                                    chkpp:SetEventScript(ui.LBUTTONDOWN,
                                        "PINNEDQUEST_CHECK")
                                    chkpp:SetEventScriptArgNumber(
                                        ui.LBUTTONDOWN, questIES.ClassID)
                                    chkpp:SetEventScriptArgString(
                                        ui.LBUTTONDOWN, "pp")
                                    chkpp:SetClickSound('button_click_big')
                                    chkpp:SetTextTooltip("ピン止め PT共有")
                                end
                                
                                -- チェックボックス操作
                                if (g.personalsettings.pinnedquest[tostring(questIES.ClassID)]) then
                                    chkpq:SetCheck(1)
                                else
                                    chkpq:SetCheck(0)
                                end
                                if (g.personalsettings.pinnedparty[tostring(questIES.ClassID)]) then
                                    chkpp:SetCheck(1)
                                else
                                    chkpp:SetCheck(0)
                                end

                                
                                listcnt = listcnt + 1
                            end
                        --end
                        end
                    else
                        
                        end
                end
            end
        end,
        catch = function(error)PINNEDQUEST_ERROUT(error) end
    }

end
function PINNEDQUEST_QUEST_CLICK_INFO(frame,ctrl,argstr,argnum)
    QUEST_CLICK_INFO(frame,ctrl,argstr,argnum)
    local frameq = ui.GetFrame('questdetail');
    frameq:SetOffset(900,200)
end
function PINNEDQUEST_REFRESH()
    PINNEDQUEST_ENSUREQUEST()
    --PINNEDQUEST_UPDATEQUESTLIST()
    PINNEDQUEST_UPDATELIST_QUEST()
end
function PINNEDQUEST_CHECK(frame, ctrl, argStr, questClassID, notUpdateRightUI)
    EBI_try_catch{
        try = function()
            tolua.cast(ctrl, "ui::CCheckBox")
            
            if argStr == "pq" then
                if (ctrl:IsChecked() == 1) then
                    g.personalsettings.pinnedquest[tostring(questClassID)] = true
                else
                    g.personalsettings.pinnedquest[tostring(questClassID)] = nil
                end
                PINNEDQUEST_SAVE_SETTINGS()
                PINNEDQUEST_ENSUREQUEST()
            
            
            elseif argStr == "pp" then
                if (ctrl:IsChecked() == 1) then
                    g.personalsettings.pinnedparty = {}
                    g.personalsettings.pinnedparty[tostring(questClassID)] = true
                else
                    g.personalsettings.pinnedparty[tostring(questClassID)] = nil
                end
                PINNEDQUEST_SAVE_SETTINGS()
                PINNEDQUEST_ENSUREQUEST()
            
            elseif argStr == "cq" then
                -- チェック入れる
                if (ctrl:IsChecked() == 1) then
                    quest.AddCheckQuest(questClassID)
                    if quest.GetCheckQuestCount() > 5 then
                        ctrl:SetCheck(0)
                        quest.RemoveCheckQuest(questClassID)
                        return
                    end
                else
                    quest.RemoveCheckQuest(questClassID)
                end
            
            elseif argStr == "cp" then
                -- party
                if (ctrl:IsChecked() == 1) then
                    CHECK_PARTY_QUEST_ADD(ui.GetFrame("quest"), questClassID)
                else
                    party.ReqChangeMemberProperty(PARTY_NORMAL, "Shared_Quest",
                        0)
                    party.ReqChangeMemberProperty(PARTY_NORMAL, "Shared_Quest",
                        -1)
                end
            
            end
            
            ReserveScript("PINNEDQUEST_UPDATEQUESTLIST()",0.25)
            ReserveScript("PINNEDQUEST_UPDATELIST_QUEST(nil,true)", 0.5)
        
        end,
        catch = function(error)PINNEDQUEST_ERROUT(error) end
    
    }

end

-- コンテキストメニュー表示処理
function PINNEDQUEST_CONTEXT_MENU(frame, msg, clickedGroupName, argNum)
    local context = ui.CreateContextMenu("TEMPLATE_RBTN", "Template", 0, 0, 300,
        100)
    ui.AddContextMenuItem(context, "Hide", "TEMPLATE_TOGGLE_FRAME()")
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)

end

-- 表示非表示切り替え処理
function PINNEDQUEST_TOGGLE_FRAME()
    g.frame = ui.GetFrame("pinnedquest")
    if g.frame:IsVisible() == 0 then
        -- 非表示->表示
        g.frame:ShowWindow(1)
        g.settings.enable = true
    else
        -- 表示->非表示
        g.frame:ShowWindow(0)
        g.settings.show = false
    end
    
    PINNEDQUEST_SAVE_SETTINGS()
end
function PINNEDQUEST_CLOSE_FRAME()
    g.frame = ui.GetFrame("pinnedquest")
    
    g.frame:ShowWindow(0)
    
    PINNEDQUEST_SAVE_SETTINGS()
end
-- フレーム場所保存処理
function PINNEDQUEST_END_DRAG()
    g.settings.position.x = g.frame:GetX()
    g.settings.position.y = g.frame:GetY()
    PINNEDQUEST_SAVE_SETTINGS()
end

-- チャットコマンド処理（acutil使用時）
function PINNEDQUEST_PROCESS_COMMAND(command)
    local cmd = ""
    
    if #command > 0 then
        cmd = table.remove(command, 1)
    else
        local msg = "ヘルプメッセージなど"
        return ui.MsgBox(msg, "", "Nope")
    end
    
    if cmd == "on" then
        -- 有効
        g.settings.enable = true
        CHAT_SYSTEM(string.format("[%s] is enable", addonName))
        PINNEDQUEST_SAVE_SETTINGS()
        return
    elseif cmd == "off" then
        -- 無効
        g.settings.enable = false
        CHAT_SYSTEM(string.format("[%s] is disable", addonName))
        PINNEDQUEST_SAVE_SETTINGS()
        return
    end
    CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName))
end

-- テスト用
function PINNEDQUEST_GETLINKQUEST(clsid)
    
    local pc = GetMyPCObject()
    
    local questIES = GetClassByType('QuestProgressCheck', clsid)
    local clsnames = {}
    for i = 1, 4 do
        local val = TryGetProp(questIES, 'QuestName' .. tostring(i), 'None')
        PINNEDQUEST_DBGOUT(string.format("NEXT%d:%s", i, val))
        if (val ~= "None") then clsnames[#clsnames + 1] = val else
            break
        end
    end
    return clsnames
end
function PINNEDQUEST_ISLINKEDQUEST(pinnedclsid, searchclsid)
    local questIES = GetClassByType('QuestProgressCheck', pinnedclsid)
    local questIESsearch = GetClassByType('QuestProgressCheck', searchclsid)
    PINNEDQUEST_DBGOUT("COMPARE:" .. questIES.ClassName)
    -- リストを持ってくる
    local lists = PINNEDQUEST_GETLINKQUEST(searchclsid)
    for _, v in pairs(lists) do
        local questIESSearch = GetClass('QuestProgressCheck', v)
        if v == questIES.ClassName and questIESsearch.QuestMode == questIES.QuestMode then
            PINNEDQUEST_DBGOUT("HIT:" .. questIES.ClassName)
            return true
        end
    end
    return false
end
function PINNEDQUEST_ISVALID(clsid, includeabandon)
    if (clsid == 0) then
        return false
    end
    local pc = GetMyPCObject()
    local sobjIES = GET_MAIN_SOBJ()
    local clsList, cnt = GetClassList("QuestProgressCheck")
    for i = 0, cnt - 1 do
        
        
        local questIES = GetClassByIndexFromList(clsList, i)
        local questClassName = questIES.ClassName
        if (questIES.ClassID == clsid) then
            if questClassName ~= "None" then
                local abandonCheck = QUEST_ABANDON_RESTARTLIST_CHECK(questIES,
                    sobjIES)
                if abandonCheck == 'NOTABANDON' or abandonCheck == 'ABANDON/NOTLIST' then
                    --if IS_ABOUT_JOB(questIES) == false then
                    local result = SCR_QUEST_CHECK_C(pc, questClassName)
                    if result == 'COMPLETE' or result == 'IMPOSSIBLE' then
                        -- 完了したり不可能なものは触らない
                        PINNEDQUEST_DBGOUT("imp" .. tostring(clsid) .. "/" .. result)
                        return false
                    elseif result == 'POSSIBLE' or result == 'PROGRESS' or result == 'SUCCESS' then
                        local pass=true
                        if result == 'POSSIBLE' then
                            local result1, subQuestZoneList = HIDE_IN_QUEST_LIST(GetMyPCObject(), questIES, nil, {})
                            if (result1 == 1) then
                                pass = false
                            end
                        end
 
                        PINNEDQUEST_DBGOUT(tostring(clsid) .. "/" .. result)
                        return pass
                    end
                --end
                else
                    if (includeabandon) then
                        return true
                    end
                end
            end
        end
    end
    PINNEDQUEST_DBGOUT("none" .. tostring(clsid) .. "/" .. tostring(result))
    return false
end
function PINNEDQUEST_FINDREQUIREDQUEST(pinnedclsid, typ)
    local list = {}
    local pc = GetMyPCObject()
    local sobjIES = GET_MAIN_SOBJ()
    local clsList, cnt = GetClassList("QuestProgressCheck")
    if (typ == nil) then
        local questIES = GetClassByType('QuestProgressCheck', pinnedclsid)
        if (questIES == nil) then
            PINNEDQUEST_DBGOUT("FAIL" .. tostring(pinnedclsid))
            return {}
        end
        typ = questIES.QuestMode
    end
    for i = 0, cnt - 1 do
        local add = false
        
        local questIES = GetClassByIndexFromList(clsList, i)
        local questClassName = questIES.ClassName
        if questClassName ~= "None" then
            local abandonCheck = QUEST_ABANDON_RESTARTLIST_CHECK(questIES,
                sobjIES)
            if abandonCheck == 'NOTABANDON' or abandonCheck == 'ABANDON/NOTLIST' then
                
                local result = SCR_QUEST_CHECK_C(pc, questClassName)
                if result == 'COMPLETE' or result == 'IMPOSSIBLE' then
                    -- 完了したり不可能なものは触らない
                    
                    elseif result == 'POSSIBLE' or result == 'PROGRESS' or result == 'SUCCESS' then
                    local pass = true
                    if result == 'POSSIBLE' then
                        local result1, subQuestZoneList = HIDE_IN_QUEST_LIST(GetMyPCObject(), questIES, nil, {})
                        if (result1 == 1) then
                            pass = false
                        end
                    end
                    if (pass) then
                        if typ == "MAIN" and questIES.QuestMode == 'MAIN' then
                            -- main派生ｸｴか調べる
                            --PINNEDQUEST_DBGOUT("MAIN")
                            if (PINNEDQUEST_ISLINKEDQUEST(pinnedclsid,
                                questIES.ClassID)) then
                                add = true
                            end
                        
                        elseif typ == "SUB" and questIES.QuestMode == 'SUB' then
                            -- sub派生ｸｴか調べる
                            --PINNEDQUEST_DBGOUT("SUB")
                            if (PINNEDQUEST_ISLINKEDQUEST(pinnedclsid,
                                questIES.ClassID)) then
                                add = true
                            end
                        elseif typ == "REPEAT" and (questIES.QuestMode == 'SUB' or questIES.QuestMode == 'REPEAT') then
                            --PINNEDQUEST_DBGOUT("REPEAT")
                            if (questIES.QuestMode == 'REPEAT' or questIES.QuestMode == 'SUB') then
                                -- repeat派生ｸｴか調べる
                                if (PINNEDQUEST_ISLINKEDQUEST(pinnedclsid, questIES.ClassID)) then
                                    add = true
                                end
                            end
                        end
                    end
                    end
            
            
            
            end
        end
        if (add == true) then list[questIES.ClassID] = true end
    end
    return list
end
function PINNEDQUEST_PARTYQUEST_PIN(clsid)
    g.personalsettings.pinnedparty = {}
    g.personalsettings.pinnedparty[clsid] = true
end
function PINNEDQUEST_ENSUREQUEST_DELAYED()
    -- 今現在トラッキングしているクエスト以外は除外する
    EBI_try_catch{
        try = function()
            if (not g.personalsettings.enabled) then
                return
            end
            local gfrm = ui.GetFrame("quest")
            PINNEDQUEST_DBGOUT("CLICKED")
            local cnt = quest.GetCheckQuestCount()
            local removelist = {}
            local addlist = {}
            local contains = {}
            local check = {}
            local i, k, v, kk, vv
            for i = 0, cnt - 1 do
                local doremove = true
                local questID = quest.GetCheckQuest(i)
                PINNEDQUEST_DBGOUT("ID" .. tostring(questID))
                contains[questID] = true
                -- トラッキング中？
                if (g.personalsettings.pinnedquest[tostring(questID)]) then
                    -- トラッキング中
                    doremove = false
                    PINNEDQUEST_DBGOUT("track")
                else
                    
                    check[questID] = true
                
                end
                if (doremove == true or g.isquestdialog > 0) then
                    if (g.isquestdialog > 0) then
                        --トラックする
                        g.personalsettings.pinnedquest[tostring(questID)] = true
                        --ついでにPTクエストにする
                        PINNEDQUEST_DBGOUT("pinned by dialog")
                        if (g.settings.enablesetpartywhenaccept) then
                            
                            g.personalsettings.pinnedparty = {}
                            g.personalsettings.pinnedparty[tostring(questID)] = true
                        end
                    else
                        removelist[questID] = true
                    end
                    PINNEDQUEST_DBGOUT("rem" .. tostring(questID))
                end
            end
            local additpin = {}
            --派生チェック
            for k, v in pairs(g.personalsettings.pinnedquest) do
                if (v) then
                    local questID = tonumber(k)
                    local doremove = true
                    for kk, vv in pairs(check) do
                        if (check[kk]) then
                            --ok
                            local result = PINNEDQUEST_ISLINKEDQUEST(k, kk)
                            if (result == true) then
                                if (not g.personalsettings.pinnedquest[tostring(kk)]) then
                                    -- 含まれていないのでたす
                                    additpin[tostring(kk)] = true
                                    removelist[kk] = nil
                                    PINNEDQUEST_DBGOUT("tasu" .. tostring(kk))
                                
                                end
                                doremove = false
                                break
                            end
                        end
                    
                    end
                    if (doremove) then
                        --孤立したピン止めを消す
                        if not PINNEDQUEST_ISVALID(questID, true) then
                            PINNEDQUEST_DBGOUT("REMOVE ORPHANED" .. tostring(questID))
                            g.personalsettings.pinnedquest[k] = nil
                        end
                    end
                end
            end
            for k, v in pairs(additpin) do
                g.personalsettings.pinnedquest[k] = true
            end
            
            -- 追加
            for k, v in pairs(g.personalsettings.pinnedquest) do
                local clsid = tonumber(k)
                if (not contains[clsid] and g.personalsettings.pinnedquest[tostring(clsid)]) then
                    -- 有効なクエストか調べる
                    if (not PINNEDQUEST_ISVALID(clsid)) then
                        PINNEDQUEST_DBGOUT("invalid" .. tostring(clsid))
                        g.personalsettings.pinnedquest[tostring(clsid)] = nil
                    else
                        addlist[clsid] = true
                        PINNEDQUEST_DBGOUT("add" .. tostring(clsid))
                    end
                end
            end
            -- 消す
            for k, v in pairs(removelist) do
                local ccnt = quest.GetCheckQuestCount()
                for i = 0, ccnt - 1 do
                    local questID = quest.GetCheckQuest(i)
                    if (removelist[questID]) then
                        quest.RemoveCheckQuestByIndex(i)
                        
                        PINNEDQUEST_DBGOUT("REMOVED" .. tostring(questID))
                        break
                    end
                end
            end
            -- 追加する
            for k, v in pairs(addlist) do
                local ccnt = quest.GetCheckQuestCount()
                if (ccnt >= 5) then break end
                PINNEDQUEST_DBGOUT("ADDED" .. tostring(k))
                
                quest.AddCheckQuest(k)
            
            end
            --PTのチェック
            for k, v in pairs(g.personalsettings.pinnedparty) do
                if (v) then
                    
                    if (PINNEDQUEST_ISVALID(tonumber(k), true)) then
                        party.ReqChangeMemberProperty(PARTY_NORMAL, "Shared_Quest",
                            0)
                        party.ReqChangeMemberProperty(PARTY_NORMAL, "Shared_Quest",
                            -1)
                        ReserveScript("CHECK_PARTY_QUEST_ADD(ui.GetFrame(\"quest\"), " .. tostring(k) .. ")", 0.3)
                        cnt = cnt + 1
                        break
                    else
                        PINNEDQUEST_DBGOUT("PT CHANGED" .. tostring(k))
                        --クエストが消えたので後釜を探す
                        local after = PINNEDQUEST_FINDREQUIREDQUEST(tonumber(k))
                        local kk
                        for kk, vv in pairs(after) do
                            --あった
                            PINNEDQUEST_DBGOUT("FOUND ALTER PARTY" .. tostring(kk))
                            g.personalsettings.pinnedparty[tostring(kk)] = true
                            SCR_QUEST_SHARE_PARTY_MEMBER(nil,nil,nil,kk)
                            break
                        end
                        --古いのは消す
                        if kk ~= k then
                            PINNEDQUEST_DBGOUT("PT REMOVED" .. tostring(k))
                            g.personalsettings.pinnedparty[k] = false
                        end
                    end
                end
            end
            
            PINNEDQUEST_SAVE_SETTINGS()
            PINNEDQUEST_DBGOUT("OK")
        --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST()",0.5)
        --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST()",0.3)
        --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST()",0.75)
        end,
        catch = function(error)PINNEDQUEST_ERROUT(error) end
    }

end

function PINNEDQUEST_ENSUREQUEST()
    --PINNEDQUEST_ENSUREQUEST_DELAYED()
    g.needtoinit=true
    ReserveScript("PINNEDQUEST_ENSUREQUEST_DELAYED()", 0.01)
end

function PINNEDQUEST_UPDATEQUESTLIST()
    --UPDATE_ALLQUEST(ui.GetFrame("quest"));
    local questframe2 = ui.GetFrame("questinfoset_2")
    UPDATE_QUESTINFOSET_2(questframe2)

end

function PINNEDQUEST_HOOKDIALOG_ADD_SELECT(frame, msg, argStr, argNum)
    if argNum == 1 then
        --reward found
        local questCls = GetClass("QuestProgressCheck", argStr);
        local cls = GetClass("QuestProgressCheck_Auto", argStr);
        local pc = GetMyPCObject();
        
        if questCls == nil or cls == nil then
            return;
        end
        g.isquestdialog = g.isquestdialog + 1
        PINNEDQUEST_DBGOUT("QUEST DIALOG FOUND")
    
    end
end
function PINNEDQUEST_HOOKDIALOG_CLOSE_CHANGESTATE()
    if (g.isquestdialog > 0) then
        g.isquestdialog = g.isquestdialog - 1
        PINNEDQUEST_DBGOUT("QUEST DIALOG CLOSED")
    end
end
function PINNEDQUEST_HOOKDIALOG_CLOSE(frame, msg, argStr, argNum)
    if (g.isquestdialog > 0) then
        ReserveScript("PINNEDQUEST_HOOKDIALOG_CLOSE_CHANGESTATE()", 0.75)
        PINNEDQUEST_DBGOUT("HOOK CLOSE QUEST DIALOG")
    end
end
