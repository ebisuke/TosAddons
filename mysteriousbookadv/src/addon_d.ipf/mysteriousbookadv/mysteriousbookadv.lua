-- mysteriousbookadv
--アドオン名（大文字）
local addonName = "mysteriousbookadv"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.version = 0

--ライブラリ読み込み
CHAT_SYSTEM("[MBA]loaded")
local acutil = require("acutil")
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
        end,
        catch = function(error)
        end
    }
end

--マップ読み込み時処理（1度だけ）
function MYSTERIOUSBOOKADV_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(ADVANCEDASSISTERMANAGER_GETCID()))
            frame:ShowWindow(0)
            --acutil.setupHook(MYSTERIOUSBOOKADV_HIDDENABILITY_MAKE_OPEN,"HIDDENABILITY_MAKE_OPEN")
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
-- function MYSTERIOUSBOOKADV_HIDDENABILITY_MAKE_OPEN(frame)
--     HIDDENABILITY_MAKE_OPEN_OLD(frame)
--     MYSTERIOUSBOOKADV_INITFRAME(frame)
-- end
-- function MYSTERIOUSBOOKADV_SELECTED(frame, ctrl)
--     EBI_try_catch{
--         try = function()
--             local frame = ui.GetFrame("hiddenability_make")
--             local ctrl = frame:GetChildRecursively("cmbavaliable")
--             AUTO_CAST(ctrl)
            
--             local btn = frame:GetChildRecursively("btnlearn")
--             AUTO_CAST(btn)
--             btn:SetEnable(0)
--             g.tocraftsel = nil
--             if ctrl:GetSelItemIndex() == 0 then
--                 MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(nil)
--                 return
--             end
            
--             local itemclassid = g.abilitylist[ctrl:GetSelItemIndex()]
--             local itemcls = GetClassByType("Item", itemclassid)
--             --どれに含まれているか調べる
--             local itemclasslist, itemclasscount = GetClassList("TradeSelectItem")
--             for i = 0, itemclasscount - 1 do
--                 local ies = GetClassByIndexFromList(itemclasslist, i)
                
--                 for j = 1, 47 do
--                     local ids = TryGetProp(ies, "SelectItemName_" .. j, "None")
                    
--                     if ids == itemcls.ClassName then
--                         --select
--                         DBGOUT("HAAA" .. itemcls.ClassName)
--                         local result_droplist = frame:GetChildRecursively("result_droplist")
--                         AUTO_CAST(result_droplist)
--                         local itemno = tonumber(string.match(ies.ClassName, "([0-9]+)"))
--                         DBGOUT("HOHO" .. itemno)
--                         result_droplist:SelectItem(itemno)
--                         HIDDENABILITY_MAKE_DROPLIST_SELECT(frame, result_droplist)
--                         btn:SetEnable(1)
--                         MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(itemcls.StringArg)
--                         g.tocraftsel = {
--                             ability = itemcls.StringArg,
--                             first = ies.ClassName,
--                             second = itemcls.ClassName,
--                             secondno = j,
--                         }
--                         return
--                     end
--                 end
--             end
--             MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(nil)
--             ui.SysMsg("[MBA]Failed.")
--         end,
--         catch = function(error)
--             ERROUT(error)
--         end
--     }
-- end
-- function MYSTERIOUSBOOKADV_INITFRAME()
--     EBI_try_catch{
--         try = function()
--             local frame = ui.GetFrame("hiddenability_make")
            
--             local mainSession = session.GetMainSession()
--             local pcJobInfo = mainSession:GetPCJobInfo()
--             local jobCount = pcJobInfo:GetJobCount()
--             local jobHistoryList = {}
--             for i = 0, jobCount - 1 do
--                 local jobHistory = pcJobInfo:GetJobInfoByIndex(i)
--                 jobHistoryList[#jobHistoryList + 1] = {
--                     JobClassName = GetClassByType("Job", jobHistory.jobID).EngName,
--                     JobClassID = jobHistory.jobID,
--                     JobSequence = jobHistory.index,
--                     PlayTime = jobHistory:GetPlaySecond(),
--                     StartTime = imcTime.ImcTimeToSysTime(jobHistory.startTime),
--                     ChangeTime = imcTime.ImcTimeToSysTime(jobHistory.changeTime)
--                 }
--             end
--             local npcClassName = frame:GetUserValue("NPC_CLASSNAME")
--             local baseclassByNpc = {
--                 ["swordmaster"] = "Warrior",
--                 ["wizardmaster"] = "Wizard",
--                 ["npc_ARC_master"] = "Archer",
--                 ["npc_healer"] = "Cleric",
--                 ["npc_SCT_master"] = "Scout"
--             }
--             local gbox = frame:CreateOrGetControl("groupbox", "gboxmba", 30, 60, frame:GetWidth() - 60, 80)
--             AUTO_CAST(gbox)
            
--             gbox:RemoveAllChild()
--             gbox:SetSkinName("bg2")
--             local reqbaseclass = baseclassByNpc[npcClassName]
--             if not reqbaseclass or jobHistoryList[1].JobClassName ~= reqbaseclass then
--                 local rich = gbox:CreateOrGetControl("richtext", "alert", 0, 0, 0, 0)
--                 rich:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
--                 rich:SetText("{ol}{s20}{#FF0000}This master cannot craft mystery book{nl}for your class.")
--                 return
--             end
--             local cmbavaliable = gbox:CreateOrGetControl("droplist", "cmbavaliable", 0, 0, 400, 0)
--             AUTO_CAST(cmbavaliable)
--             cmbavaliable:SetSkinName("droplist_normal")
--             cmbavaliable:SetTextAlign("left", "left")
--             cmbavaliable:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
--             cmbavaliable:SetSelectedScp("MYSTERIOUSBOOKADV_SELECTED")
--             local listcnt = 1
--             local itemclasslist, itemclasscount = GetClassList("Item")
--             g.abilitylist = {}
--             cmbavaliable:AddItem(0, "")
--             for i = 0, itemclasscount - 1 do
--                 local ies = GetClassByIndexFromList(itemclasslist, i)
--                 local ids = TryGetProp(ies, "AbilityIdspace", "None")
--                 if ids ~= "None" then
--                     for j = 1, jobCount do
--                         --DBGOUT('AA'..ids)
--                         local classname = jobHistoryList[j].JobClassName
                        
--                         if "Ability_" .. jobHistoryList[j].JobClassName == ids then
--                             cmbavaliable:AddItem(listcnt, "{ol}" .. ies.Name)
--                             g.abilitylist[#g.abilitylist + 1] = ies.ClassID
--                             listcnt = listcnt + 1
--                             break
--                         end
--                     end
--                 end
--             end
--             local gboxmbaupg = frame:CreateOrGetControl("groupbox", "gboxmbaupg", 30, 470, frame:GetWidth() - 60, 160)
--             AUTO_CAST(gboxmbaupg)
            
--             gboxmbaupg:RemoveAllChild()
--             gboxmbaupg:SetSkinName("bg")
            
--             local btn = gboxmbaupg:CreateOrGetControl("button", "btnlearn", 0, 0, 150, 40)
--             btn:SetGravity(ui.RIGHT, ui.BOTTOM)
--             btn:SetMargin(0, 0, 30, 10)
--             btn:SetEnable(1)
--             btn:SetSkinName("test_red_button")
--             btn:SetText("{@st42}{s16}Direct Learning")
--             btn:SetEventScript(ui.LBUTTONUP, "MYSTERIOUSBOOKADV_ON_LEARNBTN")
--         end,
--         catch = function(error)
--             ERROUT(error)
--         end
--     }
-- end

function HIDDENABILITY_MAKE_JOB_DROPLIST_UPDATE(frame)
    frame:SetUserValue("JOB_NAME", "None");

    local main_droplist = GET_CHILD_RECURSIVELY(frame, "main_droplist");
    main_droplist:ClearItems();
    main_droplist:AddItem("", "");
    main_droplist:SetSelectedScp("HIDDENABILITY_MAKE_JOB_DROPLIST_SELECT");
    main_droplist:SetVisibleLine(5)
    local arts_droplist = GET_CHILD_RECURSIVELY(frame, "arts_droplist");
    arts_droplist:SetVisibleLine(12)
    local slot = GET_CHILD_RECURSIVELY(frame, "matslot_1"); 
    local slot_item = GET_SLOT_ITEM(slot);
    if slot_item == nil then
        return;
    end

    local ctrlType = frame:GetUserValue("CTRL_TYPE");
    local itemObj = GetIES(slot_item:GetObject());
    if IS_HIDDENABILITY_MASTERPIECE_NOVICE(itemObj) == true then
        frame:SetUserValue("IS_NOVICE", 1);

        main_droplist:SetSelectedScp("HIDDENABILITY_MAKE_NOVICE_ARTS_DROPLIST_SELECT");
        arts_droplist:EnableHitTest(0);
        
        local artsList = IS_HIDDENABILITY_MASTERPIECE_NOVICE_LIST(ctrlType);
        for k, v in pairs(artsList) do
            local itemCls = GetClass("Item", v);
            main_droplist:AddItem(v, itemCls.Name);
        end
    else
        frame:SetUserValue("IS_NOVICE", 0);
        arts_droplist:EnableHitTest(1);

        local gender = GETMYPCGENDER();
        local jobList = GET_JOB_CLASS_LIST(ctrlType);
        local mainSession = session.GetMainSession()
        local pcJobInfo = mainSession:GetPCJobInfo()
        local jobCount = pcJobInfo:GetJobCount()
        local jobHistoryList = {}
        for i = 0, jobCount - 1 do
            local jobHistory = pcJobInfo:GetJobInfoByIndex(i)
            jobHistoryList[#jobHistoryList + 1] = {
                JobClassName = GetClassByType("Job", jobHistory.jobID).EngName,
                JobClassID = jobHistory.jobID,
                JobSequence = jobHistory.index,
                JobName=GetClassByType("Job", jobHistory.jobID).Name,
                PlayTime = jobHistory:GetPlaySecond(),
                StartTime = imcTime.ImcTimeToSysTime(jobHistory.startTime),
                ChangeTime = imcTime.ImcTimeToSysTime(jobHistory.changeTime)
            }
        end
        for k, v in pairs(jobHistoryList) do 
            local jobName = v.JobName;
            main_droplist:AddItem(v.JobClassName, jobName);
        end
    end

    HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame);    
end
function HIDDENABILITY_MAKE_ARTS_UPDATE(frame, artsClassName)    
    frame:SetUserValue("ARTS_CLASSNAME", artsClassName);

    local cls = GetClass("Item", artsClassName);
    if cls == nil then
        MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(nil)
        HIDDENABILITY_MAKE_ARTS_RESET(frame);
        return;
    end

    local abilityclass=TryGetProp(cls, "StringArg", "None")
    MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(abilityclass)
    local slot = GET_CHILD_RECURSIVELY(frame, "arts_slot");
	SET_SLOT_ITEM_CLS(slot, cls);    

    local arts_text = GET_CHILD_RECURSIVELY(frame, "arts_text");
    arts_text:SetTextByKey("value", "");
    arts_text:SetTextByKey("value", cls.Name);
    arts_text:ShowWindow(1);
    
    if IS_HIGH_HIDDENABILITY(artsClassName) == true then
        frame:SetUserValue('IsHighAbility', 1)    
    else
        frame:SetUserValue('IsHighAbility', 0)
        HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame)        
    end

end
function HIDDENABILITY_MAKE_NEED_MATERIAL_COUNT_UPDATE(frame)
    local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");
    if edit:GetText() == nil then return; end

    local slot = GET_CHILD_RECURSIVELY(frame, "matslot_1"); 
    local slot_item = GET_SLOT_ITEM(slot);
    if slot_item == nil then
        HIDDENABILITY_MAKE_MATERIAL_INIT(frame);
        return;
    end

    local isNoevice = frame:GetUserIValue("IS_NOVICE");
    local curCnt = 0;
    if slot_item ~= nil then
        local pc = GetMyPCObject();
        curCnt = GET_TOTAL_HIDDENABILITY_MASTER_PIECE_COUNT(pc, isNoevice);
    end
    
    if frame:GetUserIValue("IsHighAbility") == 0 then
        edit:SetText("1")
    end

    local needCnt = HIDDENABILITY_MAKE_NEED_MASTER_PIECE_COUNT() * tonumber(edit:GetText());
    local style = frame:GetUserConfig("ENOUPH_STYLE");
    if curCnt < needCnt then
        style = frame:GetUserConfig("NOT_ENOUPH_STYLE");
    end
    
    local matslot_1_count = GET_CHILD_RECURSIVELY(frame, "matslot_1_count");
    matslot_1_count:SetTextByKey("style", style);
    matslot_1_count:SetTextByKey("cur", curCnt);
    matslot_1_count:SetTextByKey("need", needCnt);
    matslot_1_count:ShowWindow(1);
    
    local artsClassName= frame:GetUserValue("ARTS_CLASSNAME");

    local cls = GetClass("Item", artsClassName);
    local abilityclass=TryGetProp(cls, "StringArg", "None")
    MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(abilityclass)
end

function HIDDENABILITY_MAKE_OK_CLLICK(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end

    -- local slot = GET_CHILD_RECURSIVELY(frame, "matslot_1"); 
    -- local slot_item = GET_SLOT_ITEM(slot);
    -- if slot_item == nil then
    --     HIDDENABILITY_MAKE_MATERIAL_INIT(frame);
        
    -- end

    --HIDDENABILITY_MAKE_MATERIAL_INIT(frame);
    --HIDDENABILITY_MAKE_JOB_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_ARTS_DROPLIST_INIT(frame);
    HIDDENABILITY_MAKE_RESULT_RESET(frame);
    HIDDENABILITY_CONTROL_ENABLE(frame, 1);    
end
function MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(classname)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("hiddenability_make")
           
            local gbox =
                frame:CreateOrGetControl(
                    "groupbox",
                    "gboxartsinfo",
                    20,
                    560,
                    frame:GetWidth()-40,
                    120
            )
            gbox:RemoveAllChild()
            AUTO_CAST(gbox)
            gbox:SetSkinName("bg")
            gbox:EnableHittestGroupBox(false)
            DBGOUT(classname)
            if not classname or classname=='None' or classname=='' then
                return
            end
            
            local edit = GET_CHILD_RECURSIVELY(frame, "once_edit");
            
            local slotarts = gbox:CreateOrGetControl("slot", "slotarts", 20, 20, 80, 80)
            AUTO_CAST(slotarts)
            local txtnamearts = gbox:CreateOrGetControl("richtext", "txtnamearts", 120, 20, 300, 40)
            
            local pc = GetMyPCObject()
            local abilies = GetAbility(pc, classname)
            local abilcls = GetClass("Ability", classname)
            
            local jobcls = GetClass("Job", abilcls.Job)
            local abildetailcls = GetClass("Ability_" .. jobcls.EngName, classname)
            
            local icon = CreateIcon(slotarts)
            
            icon:SetImage(abilcls.Icon)
            
            icon:SetTooltipType('ability');
            icon:SetTooltipArg("", abilcls.ClassID, 0);
            txtnamearts:SetText("{@st43}{s15}" .. abilcls.Name)
            local txtlv = gbox:CreateOrGetControl("richtext", "txtlv", 120, 60, 300, 30)
            if edit:GetText() == nil then return; end
            local curlv= TryGetProp(abilies, "Level", 0)
            local maxlv= TryGetProp(abildetailcls, "MaxLevel", 0)
            local createCount=tonumber(edit:GetText())
            local requires=0
            for lv= curlv+1, math.min(maxlv,curlv+createCount) do
                requires=requires+_G[abildetailcls.ScrCalcPrice](
                    pc,
                    classname,
                    lv,
                    maxlv
                )    
            
            end
            if curlv+createCount > maxlv then
                txtlv:SetText(
                    "{@st43}{s20}{#FF0000}Lv" .. TryGetProp(abilies, "Level", 0) ..' -> '..(TryGetProp(abilies, "Level", 0)+createCount).. "/" .. TryGetProp(abildetailcls, "MaxLevel", 0)
                )
    
            else
                txtlv:SetText(
                    "{@st43}{s20}Lv" .. TryGetProp(abilies, "Level", 0) ..' -> '..(TryGetProp(abilies, "Level", 0)+createCount).. "/" .. TryGetProp(abildetailcls, "MaxLevel", 0)
                )
    
            end
         
            
            local txtpoint = gbox:CreateOrGetControl("richtext", "txtpoint", 120, 90, 300, 30)
            if requires <= session.ability.GetAbilityPoint() then
            
                txtpoint:SetText(
                    "{@st43}{s16}Required/Stored: " ..
                    requires ..
                    "/" .. session.ability.GetAbilityPoint())
            else

                txtpoint:SetText(
                    "{@st43}{s16}{#FF0000}Required/Stored: " ..
                    requires ..
                    "/" .. session.ability.GetAbilityPoint())
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
