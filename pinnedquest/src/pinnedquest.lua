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
g.isquestdialog=false
g.debug = false
-- ライブラリ読み込み
local acutil = require('acutil')

-- デフォルト設定
if not g.loaded then
    g.settings = {
            -- 有効/無効
            enable = true,
            -- フレーム表示場所
            position = {x = 0, y = 0}
    }
    g.personalsettings = {enabled=false,pinnedquest = {}, pinnedparty = {}}
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

function PINNEDQUEST_SAVE_SETTINGS()
    g.personalsettingsFileLoc = string.format(
        '../addons/%s/settings_%s.json',
        addonNameLower,
        tostring(
            session.GetMySession():GetCID()))
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end

-- マップ読み込み時処理（1度だけ）
function PINNEDQUEST_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
           
            
            g.addon = addon
            frame = ui.GetFrame("pinnedquest")
            g.frame = frame
            
            frame:ShowWindow(0)
            PINNEDQUEST_LOAD_SETTINGS()
            g.loaded=true
            -- 設定ファイル保存処理
            PINNEDQUEST_SAVE_SETTINGS()
            -- メッセージ受信登録処理
            -- addon:RegisterMsg("メッセージ", "内部処理");
            -- コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "PINNEDQUEST_CONTEXT_MENU");
            -- ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "PINNEDQUEST_END_DRAG")
            addon:RegisterMsg('GET_NEW_QUEST', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('GAME_START_3SEC', 'PINNEDQUEST_ENSUREQUEST')
            
            --addon:RegisterMsg('QUEST_UPDATE', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('AVANDON_QUEST', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('QUEST_DELETED', 'PINNEDQUEST_ENSUREQUEST')
            --addon:RegisterMsg('CUSTOM_QUEST_UPDATE', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('CUSTOM_QUEST_DELETE', 'PINNEDQUEST_ENSUREQUEST')
            addon:RegisterMsg('DIALOG_ADD_SELECT', 'PINNEDQUEST_HOOKDIALOG_ADD_SELECT')
            addon:RegisterMsg('DIALOG_CLOSE', 'PINNEDQUEST_HOOKDIALOG_CLOSE');
            --addon:RegisterMsg('QUEST_UPDATE_', 'PINNEDQUEST_ENSUREQUEST')
            
            -- フレーム初期化処理
            PINNEDQUEST_INIT_FRAME(frame)
            
            -- 再表示処理
            -- if g.settings.enable then
            --  frame:ShowWindow(1);
            -- else
            -- frame:ShowWindow(0);
            -- end
            -- Moveではうまくいかないので、OffSetを使用する…
            frame:Move(0, 0)
            frame:SetOffset(g.settings.position.x, g.settings.position.y)
            
            if (OLD_QUEST_FRAME_OPEN == nil) then
                OLD_QUEST_FRAME_OPEN = QUEST_FRAME_OPEN
                QUEST_FRAME_OPEN = PINNEDQUEST_QUEST_FRAME_OPEN_JUMPER
            end
            
            PINNEDQUEST_DBGOUT("INIT")
        end,
        catch = function(error)PINNEDQUEST_ERROUT(error) end
    }
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
        g.personalsettings = {enabled=false,pinnedquest = {}, pinnedparty = {}}
    else
        -- 設定ファイル読み込み成功時処理
        g.personalsettings = t
        
    end
end
function PINNEDQUEST_QUEST_FRAME_OPEN_JUMPER(frame)
    if (OLD_QUEST_FRAME_OPEN ~= nil) then OLD_QUEST_FRAME_OPEN(frame) end
    PINNEDQUEST_QUEST_FRAME_OPEN(frame)
end
function PINNEDQUEST_QUEST_FRAME_OPEN(frame)
    local btnspq = frame:CreateOrGetControl("button", "showpq", 25, 90, 100, 40)
    btnspq:SetText("PQ設定")
    btnspq:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_TOGGLE_FRAME")
    local btnclean = frame:CreateOrGetControl("button", "pqclean", 410, 90, 100,
        40)
    btnclean:SetText("PQ更新")
    btnclean:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_REFRESH")

    local frameg = ui.GetFrame("pinnedquest")
    frameg:Resize(500, 500)
    local gb = frameg:GetChild("quests")
    gb:Resize(500, 300)
    gb:SetOffset(0, 180)
    frameg:CreateOrGetControl("richtext", "label1", 20, 100, 60, 20):SetText(
        "{ol}ピン止め")
    frameg:CreateOrGetControl("richtext", "label2", 100, 100, 60, 20):SetText(
        "{ol}チェック")
    frameg:CreateOrGetControl("richtext", "label3", 20, 120, 30, 20):SetText(
        "{ol}ｸｴ")
    frameg:CreateOrGetControl("richtext", "label4", 60, 120, 30, 20):SetText(
        "{ol}PT")
    frameg:CreateOrGetControl("richtext", "label5", 100, 120, 30, 20):SetText(
        "{ol}ｸｴ")
    frameg:CreateOrGetControl("richtext", "label6", 140, 120, 30, 20):SetText(
        "{ol}PT")
    frameg:CreateOrGetControl("richtext", "label7", 180, 120, 100, 20):SetText(
        "{ol}クエスト名")
    frameg:SetLayerLevel(95)
    local btnr=frameg:CreateOrGetControl("button", "btnrefresh", 180, 80, 60, 40)
    local chkenable = frameg:CreateOrGetControl("checkbox", "chkenable", 240, 80, 100,20)
    tolua.cast(chkenable,"ui::CCheckBox")
    if(g.personalsettings.enabled==true)then
        chkenable:SetCheck(1)
    else
        chkenable:SetCheck(0)
    end
    chkenable:SetText("{ol}このキャラで使用する")
    chkenable:SetEventScript(ui.LBUTTONDOWN, "PINNEDQUEST_ON_CHECK_CHANGED")
    btnr:SetText("更新")
    btnr:SetEventScript(ui.LBUTTONDOWN,"PINNEDQUEST_REFRESH")
    -- frameg:CreateOrGetControl("richtext","label8",400,120,100,20):SetText("{ol}前提")
    PINNEDQUEST_UPDATELIST_QUEST(frameg)
end
function PINNEDQUEST_INIT_FRAME(frame)
    -- XMLに記載するとデザイン調整時にクライアント再起動が必要になるため、luaに書き込むことをオススメする
    -- フレーム初期化処理
    if (frame == nil) then frame = ui.GetFrame("pinnedquest") end

end
function PINNEDQUEST_ON_CHECK_CHANGED(frame,ctrl)
    tolua.cast(ctrl,"ui::CCheckBox")
    if(ctrl:IsChecked()==1)then
        g.personalsettings.enabled=true;
    else
        g.personalsettings.enabled=false;
    end
    PINNEDQUEST_SAVE_SETTINGS()
    PINNEDQUEST_UPDATEQUESTLIST()
    PINNEDQUEST_UPDATELIST_QUEST()
    
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
            if(frame==nil)then
                frame=ui.GetFrame("pinnedquest")
            end
            -- ｸｴリストを更新
            local grpbox = frame:GetChild("quests")
            if (not lightweight) then grpbox:RemoveAllChild() end
            local sobjIES = GET_MAIN_SOBJ()
            
            local clsList, cnt = GetClassList("QuestProgressCheck")
            
            local listcnt = 0
            local sublimit = 999
            local subcount = 0
            
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
                        if IS_ABOUT_JOB(questIES) == false then
                            local result = SCR_QUEST_CHECK_C(pc, questClassName)
                            
                            if result == 'POSSIBLE' or result == 'PROGRESS' or
                                result == "SUCCESS" then
                                local pass = true
                                if questIES.QuestMode == 'MAIN' then
                                    else
                                    if result == 'POSSIBLE' then
                                        --local lv = GetMyPCObject().Lv
                                        
                                        --if (math.abs(questIES.Level - lv) > 10) then
                                         --   pass = false
                                        local result1, subQuestZoneList = HIDE_IN_QUEST_LIST(GetMyPCObject(), questIES, nil, {})
                                        if(result1==1)then
                                            pass = false
                                        elseif (subcount >= sublimit) then
                                            pass = false
                                        else
                                            subcount = subcount + 1
                                        end
                                    end
                                end
                                if (pass) then
                                    local pictraw =
                                        grpbox:CreateOrGetControl("picture",
                                            "pic" ..
                                            tostring(
                                                listcnt),
                                            180,
                                            listcnt * 20,
                                            20, 20)
                                    local descraw =
                                        grpbox:CreateOrGetControl("richtext",
                                            "questname" ..
                                            tostring(
                                                listcnt),
                                            200,
                                            listcnt * 20,
                                            200, 20)
                                    local chkpqr =
                                        grpbox:CreateOrGetControl("checkbox",
                                            "pq" ..
                                            tostring(
                                                listcnt),
                                            20,
                                            listcnt * 20,
                                            24, 20)
                                    local chkppr =
                                        grpbox:CreateOrGetControl("checkbox",
                                            "pp" ..
                                            tostring(
                                                listcnt),
                                            60,
                                            listcnt * 20,
                                            24, 20)
                                    local chkcqr =
                                        grpbox:CreateOrGetControl("checkbox",
                                            "cq" ..
                                            tostring(
                                                listcnt),
                                            100,
                                            listcnt * 20,
                                            24, 20)
                                    local chkcpr =
                                        grpbox:CreateOrGetControl("checkbox",
                                            "cp" ..
                                            tostring(
                                                listcnt),
                                            140,
                                            listcnt * 20,
                                            24, 20)
                                    local chkpq =
                                        tolua.cast(chkpqr, "ui::CCheckBox")
                                    local chkpp =
                                        tolua.cast(chkppr, "ui::CCheckBox")
                                    
                                    local chkcq =
                                        tolua.cast(chkcqr, "ui::CCheckBox")
                                    local chkcp =
                                        tolua.cast(chkcpr, "ui::CCheckBox")
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
                                        descraw:SetEventScript(ui.LBUTTONDOWN,
                                            "QUEST_CLICK_INFO")
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
                                        
                                        chkpp:SetEventScript(ui.LBUTTONDOWN,
                                            "PINNEDQUEST_CHECK")
                                        chkpp:SetEventScriptArgNumber(
                                            ui.LBUTTONDOWN, questIES.ClassID)
                                        chkpp:SetEventScriptArgString(
                                            ui.LBUTTONDOWN, "pp")
                                        chkpp:SetClickSound('button_click_big')
                                        
                                        chkcq:SetEventScript(ui.LBUTTONDOWN,
                                            "PINNEDQUEST_CHECK")
                                        chkcq:SetEventScriptArgNumber(
                                            ui.LBUTTONDOWN, questIES.ClassID)
                                        chkcq:SetEventScriptArgString(
                                            ui.LBUTTONDOWN, "cq")
                                        chkcq:SetClickSound('button_click_big')
                                        
                                        chkcp:SetEventScript(ui.LBUTTONDOWN,
                                            "PINNEDQUEST_CHECK")
                                        chkcp:SetEventScriptArgString(
                                            ui.LBUTTONDOWN, "cp")
                                        chkcp:SetEventScriptArgNumber(
                                            ui.LBUTTONDOWN, questIES.ClassID)
                                        chkcp:SetClickSound('button_click_big')
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
                                    if (quest.IsCheckQuest(questIES.ClassID) ==
                                        true) then
                                        chkcq:SetCheck(1)
                                    else
                                        chkcq:SetCheck(0)
                                    end
                                    local myInfo =
                                        session.party
                                        .GetMyPartyObj(PARTY_NORMAL)
                                    local isSharedQuest = false
                                    if myInfo ~= nil then
                                        local obj = GetIES(myInfo:GetObject())
                                        local clsID = questIES.ClassID
                                        local savedID = obj.Shared_Quest
                                        if savedID == clsID then
                                            chkcp:SetCheck(1)
                                        else
                                            chkcp:SetCheck(0)
                                        end
                                    end
                                    
                                    listcnt = listcnt + 1
                                end
                            end
                        end
                    else
                        
                        end
                end
            end
        end,
        catch = function(error)PINNEDQUEST_ERROUT(error) end
    }

end
function PINNEDQUEST_REFRESH()
    PINNEDQUEST_ENSUREQUEST()
    PINNEDQUEST_UPDATEQUESTLIST()
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
                PINNEDQUEST_UPDATEQUESTLIST()
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
                PINNEDQUEST_UPDATEQUESTLIST()
            end
            --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST(ui.GetFrame(\"pinnedquest\"), true)",0.05)

        -- UPDATE_ALLQUEST(ui.GetFrame("quest"))
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
        PINNEDQUEST_DBGOUT(string.format("NEXT%d:%s",i,val))
        if (val ~= "None") then clsnames[#clsnames + 1] = val else
            break
        end
    end
    return clsnames
end
function PINNEDQUEST_ISLINKEDQUEST(pinnedclsid, searchclsid)
    local questIES = GetClassByType('QuestProgressCheck', pinnedclsid)
    local questIESsearch = GetClassByType('QuestProgressCheck', searchclsid)
    PINNEDQUEST_DBGOUT("COMPARE:"..questIES.ClassName)
    -- リストを持ってくる
    local lists = PINNEDQUEST_GETLINKQUEST(searchclsid)
    for _, v in pairs(lists) do
        local questIESSearch=GetClass('QuestProgressCheck', v)
        if v == questIES.ClassName and questIESsearch.QuestMode == questIES.QuestMode then 
            PINNEDQUEST_DBGOUT("HIT:"..questIES.ClassName)
            return true
         end
    end
    return false
end
function PINNEDQUEST_ISVALID(clsid)
    if(clsid==0)then
        return false
    end
    local pc = GetMyPCObject()
    local sobjIES = GET_MAIN_SOBJ()
    local clsList, cnt = GetClassList("QuestProgressCheck")
    for i = 0, cnt - 1 do

        
        local questIES = GetClassByIndexFromList(clsList, i)
        local questClassName = questIES.ClassName
        if(questIES.ClassID==clsid)then
            if questClassName ~= "None" then
                local abandonCheck = QUEST_ABANDON_RESTARTLIST_CHECK(questIES,
                    sobjIES)
                if abandonCheck == 'NOTABANDON' or abandonCheck == 'ABANDON/NOTLIST' then
                    if IS_ABOUT_JOB(questIES) == false then
                        local result = SCR_QUEST_CHECK_C(pc, questClassName)
                        if result == 'COMPLETE' or result == 'IMPOSSIBLE' then
                            -- 完了したり不可能なものは触らない
                            PINNEDQUEST_DBGOUT("imp"..tostring(clsid).."/"..result)
                            return false
                        elseif result == 'POSSIBLE' or result == 'PROGRESS' or result == 'SUCCESS'  then
                            PINNEDQUEST_DBGOUT(tostring(clsid).."/"..result)
                            return true
                        end
                    end
                else
                    
                end
            end
        end
    end
    PINNEDQUEST_DBGOUT("none"..tostring(clsid).."/"..tostring(result))
    return false
end
function PINNEDQUEST_FINDREQUIREDQUEST(pinnedclsid, typ)
    local list = {}
    local pc = GetMyPCObject()
    local sobjIES = GET_MAIN_SOBJ()
    local clsList, cnt = GetClassList("QuestProgressCheck")
    if(typ==nil)then
        local questIES = GetClassByType('QuestProgressCheck', pinnedclsid)
        if(questIES==nil)then
            PINNEDQUEST_DBGOUT("FAIL"..tostring(pinnedclsid))
            return {}
        end
        typ=questIES.QuestMode
    end
    for i = 0, cnt - 1 do
        local add = false
        
        local questIES = GetClassByIndexFromList(clsList, i)
        local questClassName = questIES.ClassName
        if questClassName ~= "None" then
            local abandonCheck = QUEST_ABANDON_RESTARTLIST_CHECK(questIES,
                sobjIES)
            if abandonCheck == 'NOTABANDON' or abandonCheck == 'ABANDON/NOTLIST' then
                if IS_ABOUT_JOB(questIES) == false then
                    local result = SCR_QUEST_CHECK_C(pc, questClassName)
                    if result == 'COMPLETE' or result == 'IMPOSSIBLE' then
                        -- 完了したり不可能なものは触らない
                        elseif result == 'POSSIBLE' or result == 'PROGRESS' or
                        result == 'SUCCESS' then
                            local result1
                            
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

                                if(questIES.QuestMode == 'REPEAT' or questIES.QuestMode == 'SUB') then
                                -- repeat派生ｸｴか調べる
                                if (PINNEDQUEST_ISLINKEDQUEST(pinnedclsid,
                                    questIES.ClassID)) then
                                    add = true
                                end
                            end
                            end
                        end
                end
            else
                
                end
        end
        if (add == true) then list[questIES.ClassID] = true end
    end
    return list
end

function PINNEDQUEST_ENSUREQUEST_DELAYED()
  -- 今現在トラッキングしているクエスト以外は除外する
  EBI_try_catch{
    try = function()
        if(not g.personalsettings.enabled)then
            return
        end
        local gfrm = ui.GetFrame("quest")
        PINNEDQUEST_DBGOUT("CLICKED")
        local cnt = quest.GetCheckQuestCount()
        local removelist = {}
        local addlist = {}
        local contains = {}
        local check={}
        local i,k,v,kk,vv
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
                
                check[questID]=true
               
            end
            if (doremove == true) then
                if( g.isquestdialog==true)then
                    --トラックする
                    g.personalsettings.pinnedquest[tostring(questID)]=true
                else
                    removelist[questID] = true
                end
                PINNEDQUEST_DBGOUT("rem"..tostring(questID))
            end
        end
        local additpin={}
        --派生チェック
        for k, v in pairs(g.personalsettings.pinnedquest) do
            if(v)then
                local questID=tonumber(k)
                local doremove=true
                for kk, vv in pairs(check) do
                     if(check[kk])then
                         --ok
                         local result=PINNEDQUEST_ISLINKEDQUEST(k,kk)
                         if(result==true)then
                            if (not g.personalsettings.pinnedquest[tostring(kk)]) then
                                -- 含まれていないのでたす
                                additpin[tostring(kk)]=true
                                removelist[kk]=nil
                                PINNEDQUEST_DBGOUT("tasu"..tostring(kk))
                                
                            end
                            doremove=false
                            break
                        else
                            
                        end
                     end
                    
                 end
                if(doremove)then
                    --孤立したピン止めを消す
                    if not PINNEDQUEST_ISVALID(questID) then
                        PINNEDQUEST_DBGOUT("REMOVE ORPHANED"..tostring(questID))
                        g.personalsettings.pinnedquest[k]=nil
                    end
                end
            end
        end
        for k,v in pairs(additpin) do
            g.personalsettings.pinnedquest[k]=true
        end

        -- 追加
        for k, v in pairs(g.personalsettings.pinnedquest) do
            local clsid=tonumber(k)
            if (not contains[clsid] and   g.personalsettings.pinnedquest[tostring(clsid)]) then
                -- 有効なクエストか調べる
                if (not PINNEDQUEST_ISVALID(clsid)) then
                    PINNEDQUEST_DBGOUT("invalid"..tostring(clsid))
                    g.personalsettings.pinnedquest[tostring(clsid)] = nil
                else
                    addlist[clsid] = true
                    PINNEDQUEST_DBGOUT("add"..tostring(clsid))
                end
            end
        end
        -- 消す
        PINNEDQUEST_DBGOUT("REMOVE" .. tostring(#removelist))
        PINNEDQUEST_DBGOUT("ADD" .. tostring(#addlist))
        
        for k, v in pairs(removelist) do
            local ccnt = quest.GetCheckQuestCount()
            for i = 0, ccnt - 1 do
                local questID = quest.GetCheckQuest(i)
                if (removelist[questID]) then
                    quest.RemoveCheckQuestByIndex(i)

                    PINNEDQUEST_DBGOUT("REMOVED"..tostring(questID))
                    break
                end
            end
        end
        -- 追加する
        for k, v in pairs(addlist) do
            local ccnt = quest.GetCheckQuestCount()
            if (ccnt >= 5) then break end
            PINNEDQUEST_DBGOUT("ADDED"..tostring(k))
            
            quest.AddCheckQuest(k)
            
        end
        --PTのチェック

        for k,v in pairs(g.personalsettings.pinnedparty) do
            if(v)then
                
                if(PINNEDQUEST_ISVALID(tonumber(k)))then
                    party.ReqChangeMemberProperty(PARTY_NORMAL, "Shared_Quest",
                        0)
                    party.ReqChangeMemberProperty(PARTY_NORMAL, "Shared_Quest",
                        -1)
                    CHECK_PARTY_QUEST_ADD(ui.GetFrame("quest"), k)
                    cnt=cnt+1
                    break
                else
                    --クエストが消えたので後釜を探す
                    local after=PINNEDQUEST_FINDREQUIREDQUEST(tonumber(k))
                    for kk,vv in pairs(after)do
                        --あった
                        PINNEDQUEST_DBGOUT("FOUND ALTER PARTY"..tostring(kk))
                        g.personalsettings.pinnedparty[tostring(kk)]=true
                        CHECK_PARTY_QUEST_ADD(ui.GetFrame("quest"), kk)
                        break
                    end
                    --古いのは消す
                    g.personalsettings.pinnedparty[k]=false
                end
            end
        end
        
        PINNEDQUEST_SAVE_SETTINGS()
        PINNEDQUEST_DBGOUT("OK")
        --PINNEDQUEST_UPDATEQUESTLIST()
        --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST()",0.5)
        --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST()",0.3)
        --ReserveScript("PINNEDQUEST_UPDATELIST_QUEST()",0.75)
    end,
    catch = function(error)PINNEDQUEST_ERROUT(error) end
}

end

function PINNEDQUEST_ENSUREQUEST()
    --PINNEDQUEST_ENSUREQUEST_DELAYED()
    ReserveScript("PINNEDQUEST_ENSUREQUEST_DELAYED()",1.75)
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
            return ;
        end
        g.isquestdialog=true
        PINNEDQUEST_DBGOUT("QUEST DIALOG FOUND")

	end
end
function PINNEDQUEST_HOOKDIALOG_CLOSE_CHANGESTATE()
    g.isquestdialog=false
end
function PINNEDQUEST_HOOKDIALOG_CLOSE(frame, msg, argStr, argNum)
    if( g.isquestdialog==true)then
        ReserveScript("PINNEDQUEST_HOOKDIALOG_CLOSE_CHANGESTATE()",2)
    end
end