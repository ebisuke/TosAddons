-- mysteriousbookadv
--アドオン名（大文字）
local addonName = 'mysteriousbookadv'
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
g.framename = 'mysteriousbookadv'
g.debug = false


--ライブラリ読み込み
CHAT_SYSTEM('[MBA]loaded')
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
            acutil.setupHook(MYSTERIOUSBOOKADV_HIDDENABILITY_MAKE_OPEN, 'HIDDENABILITY_MAKE_OPEN')
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
            local frame = ui.GetFrame('hiddenability_make')
            local ctrl=frame:GetChildRecursively('cmbavaliable')
            AUTO_CAST(ctrl)
            
            if ctrl:GetSelItemIndex()==0 then
                return
            end
           
            local itemclassid =   g.abilitylist[ctrl:GetSelItemIndex()]
            local itemcls=GetClassByType('Item',itemclassid)
            --どれに含まれているか調べる
            local itemclasslist, itemclasscount = GetClassList('TradeSelectItem');
            for i = 0, itemclasscount - 1 do
                local ies = GetClassByIndexFromList(itemclasslist, i);
                
                for j=1,47 do
                    local ids = TryGetProp(ies, "SelectItemName_"..j, "None");
                 
       
                    if ids==itemcls.ClassName then
                        --select
                        DBGOUT('HAAA'..itemcls.ClassName)
                        local result_droplist=frame:GetChildRecursively('result_droplist')
                        AUTO_CAST(result_droplist)
                        local itemno=tonumber(string.match(ies.ClassName,'([0-9]+)'))
                        DBGOUT('HOHO'..itemno)
                        result_droplist:SelectItem(itemno)
                        HIDDENABILITY_MAKE_DROPLIST_SELECT(frame,result_droplist)
                        return
                    end
                end  
            end
            ui.SysMsg('[MBA]Failed.')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MYSTERIOUSBOOKADV_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame('hiddenability_make')
            
            
            
            local mainSession = session.GetMainSession();
            local pcJobInfo = mainSession:GetPCJobInfo();
            local jobCount = pcJobInfo:GetJobCount();
            local jobHistoryList = {};
            for i = 0, jobCount - 1 do
                local jobHistory = pcJobInfo:GetJobInfoByIndex(i);
                jobHistoryList[#jobHistoryList + 1] = {
                    JobClassName = GetClassByType('Job', jobHistory.jobID).EngName,
                    JobClassID = jobHistory.jobID, JobSequence = jobHistory.index, PlayTime = jobHistory:GetPlaySecond(),
                    StartTime = imcTime.ImcTimeToSysTime(jobHistory.startTime);
                    ChangeTime = imcTime.ImcTimeToSysTime(jobHistory.changeTime);
                };
            end
            local npcClassName = frame:GetUserValue("NPC_CLASSNAME")
            local baseclassByNpc = {
                ['swordmaster'] = 'Warrior',
                ['wizardmaster'] = 'Wizard',
                ['npc_ARC_master'] = 'Archer',
                ['npc_healer'] = 'Cleric',
                ['npc_SCT_master'] = 'Scout',
            
            }
            local gbox = frame:CreateOrGetControl('groupbox', 'gboxmba', 30, 60, frame:GetWidth() - 60, 80)
            AUTO_CAST(gbox)
            
            gbox:RemoveAllChild()
            gbox:SetSkinName('bg2')
            local reqbaseclass = baseclassByNpc[npcClassName]
            if not reqbaseclass or jobHistoryList[1].JobClassName ~= reqbaseclass then
                local rich = gbox:CreateOrGetControl("richtext", 'alert', 0, 0, 0, 0)
                rich:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                rich:SetText('{ol}{s20}{#FF0000}This master cannot craft mystery book{nl}for your class.')
                return
            
            end
            local cmbavaliable = gbox:CreateOrGetControl("droplist", 'cmbavaliable', 0, 0, 400, 0)
            AUTO_CAST(cmbavaliable)
            cmbavaliable:SetSkinName("droplist_normal");
            cmbavaliable:SetTextAlign("left", "left");
            cmbavaliable:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
            cmbavaliable:SetSelectedScp('MYSTERIOUSBOOKADV_SELECTED')
            local listcnt = 1
            local itemclasslist, itemclasscount = GetClassList('Item');
            g.abilitylist = {}
            cmbavaliable:AddItem(0, '')
            for i = 0, itemclasscount - 1 do
                local ies = GetClassByIndexFromList(itemclasslist, i);
                local ids = TryGetProp(ies, "AbilityIdspace", "None");
                if ids ~= 'None' then
                    for j = 1, jobCount do
                        --DBGOUT('AA'..ids)
                        local classname = jobHistoryList[j].JobClassName
     
                        if 'Ability_' .. jobHistoryList[j].JobClassName == ids then
                            cmbavaliable:AddItem(listcnt, '{ol}' .. ies.Name)
                            g.abilitylist[#g.abilitylist + 1] = ies.ClassID
                            listcnt = listcnt + 1
                            break
                        end
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
_G['ADDONS'][author][addonName] = g
