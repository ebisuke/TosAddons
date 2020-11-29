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
g.settings = {}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "mysteriousbookadv"
g.debug = false
g.working = false
g.tocraftsel=nil
g.tocraft=nil
g.timeout = 8
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
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            acutil.setupHook(MYSTERIOUSBOOKADV_HIDDENABILITY_MAKE_OPEN, "HIDDENABILITY_MAKE_OPEN")
            addon:RegisterMsg("INV_ITEM_ADD", "MYSTERIOUSBOOKADV_ON_ADDITEM")
            
            addon:RegisterOpenOnlyMsg('INV_ITEM_CHANGE_COUNT', 'MYSTERIOUSBOOKADV_ON_ADDITEM', 1);
            
            frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MYSTERIOUSBOOKADV_HIDDENABILITY_MAKE_OPEN(frame)
    HIDDENABILITY_MAKE_OPEN_OLD(frame)
    MYSTERIOUSBOOKADV_INITFRAME(frame)
end
function MYSTERIOUSBOOKADV_SELECTED(frame, ctrl)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("hiddenability_make")
            local ctrl = frame:GetChildRecursively("cmbavaliable")
            AUTO_CAST(ctrl)
            
            local btn = frame:GetChildRecursively("btnlearn")
            AUTO_CAST(btn)
            btn:SetEnable(0)
            g.tocraftsel = nil
            if ctrl:GetSelItemIndex() == 0 then
                MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(nil)
                return
            end
            
            local itemclassid = g.abilitylist[ctrl:GetSelItemIndex()]
            local itemcls = GetClassByType("Item", itemclassid)
            --どれに含まれているか調べる
            local itemclasslist, itemclasscount = GetClassList("TradeSelectItem")
            for i = 0, itemclasscount - 1 do
                local ies = GetClassByIndexFromList(itemclasslist, i)
                
                for j = 1, 47 do
                    local ids = TryGetProp(ies, "SelectItemName_" .. j, "None")
                    
                    if ids == itemcls.ClassName then
                        --select
                        DBGOUT("HAAA" .. itemcls.ClassName)
                        local result_droplist = frame:GetChildRecursively("result_droplist")
                        AUTO_CAST(result_droplist)
                        local itemno = tonumber(string.match(ies.ClassName, "([0-9]+)"))
                        DBGOUT("HOHO" .. itemno)
                        result_droplist:SelectItem(itemno)
                        HIDDENABILITY_MAKE_DROPLIST_SELECT(frame, result_droplist)
                        btn:SetEnable(1)
                        MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(itemcls.StringArg)
                        g.tocraftsel = {
                            ability = itemcls.StringArg,
                            first = ies.ClassName,
                            second = itemcls.ClassName,
                            secondno = itemno,
                        }
                        return
                    end
                end
            end
            MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(nil)
            ui.SysMsg("[MBA]Failed.")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MYSTERIOUSBOOKADV_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("hiddenability_make")
            
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
                    PlayTime = jobHistory:GetPlaySecond(),
                    StartTime = imcTime.ImcTimeToSysTime(jobHistory.startTime),
                    ChangeTime = imcTime.ImcTimeToSysTime(jobHistory.changeTime)
                }
            end
            local npcClassName = frame:GetUserValue("NPC_CLASSNAME")
            local baseclassByNpc = {
                ["swordmaster"] = "Warrior",
                ["wizardmaster"] = "Wizard",
                ["npc_ARC_master"] = "Archer",
                ["npc_healer"] = "Cleric",
                ["npc_SCT_master"] = "Scout"
            }
            local gbox = frame:CreateOrGetControl("groupbox", "gboxmba", 30, 60, frame:GetWidth() - 60, 80)
            AUTO_CAST(gbox)
            
            gbox:RemoveAllChild()
            gbox:SetSkinName("bg2")
            local reqbaseclass = baseclassByNpc[npcClassName]
            if not reqbaseclass or jobHistoryList[1].JobClassName ~= reqbaseclass then
                local rich = gbox:CreateOrGetControl("richtext", "alert", 0, 0, 0, 0)
                rich:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                rich:SetText("{ol}{s20}{#FF0000}This master cannot craft mystery book{nl}for your class.")
                return
            end
            local cmbavaliable = gbox:CreateOrGetControl("droplist", "cmbavaliable", 0, 0, 400, 0)
            AUTO_CAST(cmbavaliable)
            cmbavaliable:SetSkinName("droplist_normal")
            cmbavaliable:SetTextAlign("left", "left")
            cmbavaliable:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
            cmbavaliable:SetSelectedScp("MYSTERIOUSBOOKADV_SELECTED")
            local listcnt = 1
            local itemclasslist, itemclasscount = GetClassList("Item")
            g.abilitylist = {}
            cmbavaliable:AddItem(0, "")
            for i = 0, itemclasscount - 1 do
                local ies = GetClassByIndexFromList(itemclasslist, i)
                local ids = TryGetProp(ies, "AbilityIdspace", "None")
                if ids ~= "None" then
                    for j = 1, jobCount do
                        --DBGOUT('AA'..ids)
                        local classname = jobHistoryList[j].JobClassName
                        
                        if "Ability_" .. jobHistoryList[j].JobClassName == ids then
                            cmbavaliable:AddItem(listcnt, "{ol}" .. ies.Name)
                            g.abilitylist[#g.abilitylist + 1] = ies.ClassID
                            listcnt = listcnt + 1
                            break
                        end
                    end
                end
            end
            local gboxmbaupg = frame:CreateOrGetControl("groupbox", "gboxmbaupg", 30, 470, frame:GetWidth() - 60, 160)
            AUTO_CAST(gboxmbaupg)
            
            gboxmbaupg:RemoveAllChild()
            gboxmbaupg:SetSkinName("bg")
            
            local btn = gboxmbaupg:CreateOrGetControl("button", "btnlearn", 0, 0, 150, 40)
            btn:SetGravity(ui.RIGHT, ui.BOTTOM)
            btn:SetMargin(0, 0, 30, 10)
            btn:SetEnable(1)
            btn:SetSkinName("test_red_button")
            btn:SetText("{@st42}{s16}Direct Learning")
            btn:SetEventScript(ui.LBUTTONUP, "MYSTERIOUSBOOKADV_ON_LEARNBTN")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MYSTERIOUSBOOKADV_ON_LEARNBTN()
    if g.working == false then
        
        if ui.CheckHoldedUI() == true then
            return;
        end
        if g.tocraftsel == nil then
            ui.SysMsg('[MBA]Please select Arts.')
            return
        end
        
        local pc = GetMyPCObject()
        local abilies = GetAbility(pc, g.tocraftsel.ability)
        local abilcls = GetClass("Ability", g.tocraftsel.ability)
        local jobcls = GetClass("Job", abilcls.Job)
        local abildetailcls = GetClass("Ability_" .. jobcls.EngName, g.tocraftsel.ability)
        local needpt = _G[abildetailcls.ScrCalcPrice](
            pc,
            g.tocraftsel.ability,
            TryGetProp(abilies, "Level", 0),
            TryGetProp(abildetailcls, "MaxLevel", 0)
        )
        if TryGetProp(abilies, "Level", 0) >= TryGetProp(abildetailcls, "MaxLevel", 0) then
            ui.SysMsg('[MBA]Level is reached to maximum.')
            return
        
        end
        if needpt > session.ability.GetAbilityPoint() then
            ui.SysMsg('[MBA]Insufficient Ability Points.')
            return
        end
        
        
        
        local frame = ui.GetFrame("hiddenability_make");
        
        local resultitemslot = GET_CHILD_RECURSIVELY(frame, "result_slot");
        local resultitemClassName = g.tocraftsel.first
        if resultitemClassName == "None" or resultitemClassName == "" then
            ui.SysMsg(ClMsg("Arts_Please_Select_HiddenabilityItem"));
            return;
        end
        
        local pieceguid = frame:GetUserValue("MATERIAL_GUID_1");
        local pieceitem = GET_PC_ITEM_BY_GUID(pieceguid);
        local pieceitemobj = GetIES(pieceitem:GetObject());
        local pieceneedcnt = HIDDENABILITY_MAKE_NEED_PIECE_COUNT(resultitemClassName, pieceitemobj);
        local piececurcnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
            {Name = 'ClassName', Value = pieceitemobj.ClassName}
        }, false);
        if piececurcnt == 0 or pieceguid == "None" then
            ui.SysMsg(ClMsg("Arts_Please_Register_MaterialItem"));
            return;
        end
        if piececurcnt < pieceneedcnt then
            ui.SysMsg(ClMsg('NotEnoughRecipe'));
            return;
        end
        
        local stoneguid = frame:GetUserValue("MATERIAL_GUID_2");
        local stoneneedcnt = 0;
        local stonecurcnt = 0;
        if IS_HIDDENABILITY_MATERIAL_MASTERPIECE(pieceitemobj) == false then
            stoneneedcnt = HIDDENABILITY_MAKE_NEED_STONE_COUNT(resultitemClassName);
            stonecurcnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
                {Name = 'ClassName', Value = 'Premium_item_transcendence_Stone'}
            }, false);
            if stonecurcnt == 0 or stoneguid == "None" then
                ui.SysMsg(ClMsg("Arts_NeedOnemoreStone"));
                return;
            end
            if stonecurcnt < stoneneedcnt then
                ui.SysMsg(ClMsg('NotEnoughRecipe'));
                return;
            end
        end
        local function shallow_copy(t)
            local t2 = {}
            for k,v in pairs(t) do
              t2[k] = v
            end
            return t2
          end
              
        --craft first
        g.tocraft=shallow_copy(g.tocraftsel)
        local nameList = NewStringList();
        nameList:Add(resultitemClassName)
        session.ResetItemList();
        session.AddItemID(pieceguid, pieceneedcnt);
        session.AddItemID(stoneguid, stoneneedcnt);
        
        local btn = frame:GetChildRecursively("btnlearn")
        btn:SetEnable(0)
        local resultlist = session.GetItemIDList();
        g.working =
            item.DialogTransaction('HIDDENABILITY_MAKE', resultlist, "", nameList)
     
        DebounceScript("MYSTERIOUSBOOKADV_TIMEOUT", g.timeout, 0)
        ReserveScript('MYSTERIOUSBOOKADV_NEXT()', 1.5)
    end
end
function MYSTERIOUSBOOKADV_TIMEOUT()
    if g.working then
        ui.SysMsg("[MBA]Failed")
        MYSTERIOUSBOOKADV_COMPLETE()
    end
end

function MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(classname)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("hiddenability_make")
            local gboxmbaupg = frame:GetChildRecursively("gboxmbaupg")
            local gbox =
                gboxmbaupg:CreateOrGetControl(
                    "groupbox",
                    "gboxartsinfo",
                    0,
                    0,
                    gboxmbaupg:GetWidth(),
                    gboxmbaupg:GetHeight()
            )
            gbox:RemoveAllChild()
            AUTO_CAST(gbox)
            AUTO_CAST(gboxmbaupg)
            gbox:EnableHittestGroupBox(false)
            DBGOUT(classname)
            if not classname then
                return
            end
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
            
            txtlv:SetText(
                "{@st43}{s20}Lv" .. TryGetProp(abilies, "Level", 0) .. "/" .. TryGetProp(abildetailcls, "MaxLevel", 0)
            )
            local txtpoint = gbox:CreateOrGetControl("richtext", "txtpoint", 120, 90, 300, 30)
            txtpoint:SetText(
                "{@st43}{s16}Required/Stored: " ..
                _G[abildetailcls.ScrCalcPrice](
                    pc,
                    classname,
                    TryGetProp(abilies, "Level", 0),
                    TryGetProp(abildetailcls, "MaxLevel", 0)
                ) ..
                "/" .. session.ability.GetAbilityPoint()
        )
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MYSTERIOUSBOOKADV_COMPLETE()
    local frame = ui.GetFrame("hiddenability_make")
    if g.tocraft then
        MYSTERIOUSBOOKADV_UPDATE_ARTSINFO(g.tocraft.ability)
    end
    local btn = frame:GetChildRecursively("btnlearn")
    btn:SetEnable(1)
    
    g.tocraft = nil
    g.working = false
    HIDDENABILITY_MAKE_RESET_CENTER_UI(frame)
end
function MYSTERIOUSBOOKADV_PUSH_DIALOGOK()
    if g.tocraft and g.tocraft.third then
        if g.tocraft.thirdtouch then
            
            control.DialogItemSelect(1);
            g.tocraft.thirdtouch=false
            ReserveScript('MYSTERIOUSBOOKADV_PUSH_DIALOGOK()', 0.8)
        else
            local item = session.GetInvItemByGuid( g.tocraft.third)
            if item and item.count == g.tocraft.thirdcount then
                
                control.DialogItemSelect(1);
                
                ReserveScript('MYSTERIOUSBOOKADV_PUSH_DIALOGOK()', 0.2)
                return
            else
                
                ui.SysMsg('[MBA]Learned.')
                MYSTERIOUSBOOKADV_COMPLETE()
            end
        end
       
    end

end
function MYSTERIOUSBOOKADV_FORCE()
    g.working = true
    MYSTERIOUSBOOKADV_NEXT()
    
end
function MYSTERIOUSBOOKADV_FORCE2()
    g.working = true
    g.tocraft.first=nil
    MYSTERIOUSBOOKADV_NEXT()
    
end

function MYSTERIOUSBOOKADV_NEXT()
    
    EBI_try_catch{
        try = function()
            
            if g.tocraft then
                if g.tocraft.first then
                    DBGOUT('1')
                    local itemcls = GetClass('Item', g.tocraft.first)
                    local item = session.GetInvItemByType(itemcls.ClassID)
                    
                    if item ~= nil then
                        --second
                        g.tocraft.first = nil
                        DebounceScript("MYSTERIOUSBOOKADV_TIMEOUT", g.timeout, 0)
                        local argStr = string.format("%s#%d", item:GetIESID(), g.tocraft.secondno);
                        pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM", argStr);
                        ReserveScript('MYSTERIOUSBOOKADV_NEXT()', 0.8)
                    end
                elseif g.tocraft.second then
                    DBGOUT('2')
                    local itemcls = GetClass('Item', g.tocraft.second)
                    local item = session.GetInvItemByType(itemcls.ClassID)
                    if item ~= nil then
                        --learn
                        g.tocraft.second = nil
                        g.tocraft.third = item:GetIESID()
                        g.tocraft.thirdcount = item.count
                        g.tocraft.thirdtouch=true
                        INV_ICON_USE(item)
                        DebounceScript("MYSTERIOUSBOOKADV_TIMEOUT", g.timeout, 0)
                        ReserveScript('MYSTERIOUSBOOKADV_PUSH_DIALOGOK()', 0.6)
                    else
                        
                        end
                end
            else
                DBGOUT('fail')
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function MYSTERIOUSBOOKADV_ON_ADDITEM(frame, msg, argstr, argnum)
    if g.working then
        --if msg == "INV_ITEM_ADD" then
        --end
        end
end
