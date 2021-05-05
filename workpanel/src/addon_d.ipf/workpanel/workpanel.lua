--workpanel
local addonName = "workpanel"
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
g.settings = {x = 300, y = 300, isopen=false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "workpanel"
g.debug = false
g.disablevelnicescoreboard=nil
--ライブラリ読み込み
CHAT_SYSTEM("[WP]loaded")
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
function WORKPANEL_SOLODUNGEON_RANKINGPAGE_OPEN(frame)
    if g.disablevelnicescoreboard then
        --pass
    else
        return SOLODUNGEON_RANKINGPAGE_OPEN_OLD(frame)
    end
end
function WORKPANEL_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            local addontimer = frame:GetChild("addontimer")
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0,0)
            --addon:RegisterMsg('GAME_START_3SEC', 'WORKPANEL_INITFRAME')
            acutil.setupHook(WORKPANEL_SOLODUNGEON_RANKINGPAGE_OPEN,"SOLODUNGEON_RANKINGPAGE_OPEN")

            addon:RegisterMsg("DO_SOLODUNGEON_RANKINGPAGE_OPEN", "WORKPANEL_INITFRAME");
            soloDungeonClient.ReqSoloDungeonRankingPage()
            g.disablevelnicescoreboard=true
            WORKPANEL_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function WORKPANEL_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function  WORKPANEL_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {isopen=false}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    WORKPANEL_UPGRADE_SETTINGS()
    WORKPANEL_SAVE_SETTINGS()

end

function  WORKPANEL_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

function WORKPANEL_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:SetGravity(ui.RIGHT,ui.TOP)
            frame:RemoveAllChild()
            frame:SetLayerLevel(100)
            frame:SetSkinName("bg2")
            local mapClsName = session.GetMapName();

            if(mapClsName ~=  "c_Klaipe" and mapClsName ~=  "c_fedimian" and mapClsName ~=  "c_orsha")then
                frame:ShowWindow(0)
                g.disablevelnicescoreboard=false
                return
            end
            local etc=GetMyEtcObject()
            --frame:SetMargin(0,0,0,0)
            local acc_obj = GetMyAccountObj()
            local stage=TryGetProp(acc_obj,"ANCIENT_SOLO_STAGE_WEEK",0)
        
            local scoreInfo = session.soloDungeon.GetMyScore(soloDungeonShared.ThisWeek, 0)
            --local stageScore = session.soloDungeon.GetStageScore()
            
            local velnicestage=0
            if scoreInfo then
                velnicestage=scoreInfo.stage
            else
                --error "fail"
            end
            frame:ShowWindow(1)
            if g.settings.isopen==false then
                frame:Resize(50,20)

                --frame:SetMargin(0,0,0,0)
                WORKPANEL_CREATECONTROL(frame)
                ("button","btntoggleopen",50,"<<","WORKPANEL_TOGGLE_PANEL")
                
            else
                frame:Resize(1300,20)
                
                WORKPANEL_CREATECONTROL(frame)
                ("button","btntoggleopen",50,">>","WORKPANEL_TOGGLE_PANEL")
                
                ("richtext","label1",90,"{ol}Singularity","")
                ("button","btnsinglularity",70,"Left:"..GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",647).PlayPerResetType),"WORKPANEL_ENTER_HARDCHALLENGE")
                ("richtext","label2",120,"{ol}Challenge"..
                GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType).."/"..
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType)
                ,"")
                ("button","btnchallenge461",50,"361","WORKPANEL_ENTER_CHALLENGE361")
                ("button","btnchallenge400",50,"400","WORKPANEL_ENTER_CHALLENGE400")
                ("button","btnchallenge450",50,"450","WORKPANEL_ENTER_CHALLENGE450")
                ("richtext","label3",70,"{ol}Moring","")
                ("button","btnmoring",50,WORKPANEL_GETINDUNENTERCOUNT(608),"WORKPANEL_ENTER_MORING")
                ("richtext","label4",70,"{ol}Witch","")
                ("button","btnwitch",50,WORKPANEL_GETINDUNENTERCOUNT(619),"WORKPANEL_ENTER_WITCH")
                ("richtext","label5",70,"{ol}Giltine","")
                ("button","btngiltine",50,WORKPANEL_GETINDUNENTERCOUNT(635),"WORKPANEL_ENTER_GILTINE")
                ("richtext","label6",60,"{ol}Relic","")
                ("button","btnrelic",50,GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType).."/"..
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType),"WORKPANEL_ENTER_RELIC")
                ("richtext","label7",70,"{ol}Assister","")
                ("button","btnassister",50,""..stage,"WORKPANEL_ENTER_ASSISTER")
                ("richtext","label8",70,"{ol}Velnice","")
                ("button","btnvelnice",50,""..velnicestage,"WORKPANEL_ENTER_VELNICE")
            end
            g.disablevelnicescoreboard=false
        end,
        catch = function(error)
            DBGOUT(error)
            local frame = ui.GetFrame(g.framename)
            frame:SetGravity(ui.RIGHT,ui.TOP)
            frame:RemoveAllChild()
            frame:Resize(10,10)
            --retry 
            ReserveScript("WORKPANEL_INITFRAME()",1)
        end
    }
end
function WORKPANEL_GETINDUNENTERCOUNT(clsid)
    local indunCls=GetClassByType("Indun",clsid)
    
    local etc=GetMyEtcObject()
    return TryGetProp(etc, "IndunWeeklyEnteredCount_"..tostring(TryGetProp(indunCls, "PlayPerResetType"))).."/"..indunCls.WeeklyEnterableCount
end
function WORKPANEL_GETREMAININDUNENTERCOUNT(clsid)
    local indunCls=GetClassByType("Indun",clsid)
    
    local etc=GetMyEtcObject()
    if indunCls.DungeonType == "Challenge_Auto" then
        return indunCls.WeeklyEnterableCount-TryGetProp(etc, "IndunWeeklyEnteredCount_"..tostring(TryGetProp(indunCls, "PlayPerResetType")))
    else
        
    end
end
function WORKPANEL_BUY_ITEM(recipeNameArray,retrystring)
    EBI_try_catch{
        try = function()
        local recipeCls
        local fail=true
        for _,recipeName in ipairs(recipeNameArray) do
            recipeCls = GetClass("ItemTradeShop", recipeName)
            if recipeCls.NeedProperty ~= 'None' then
                local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop");
                local sCount = TryGetProp(sObj, recipeCls.NeedProperty); 
                
                if sCount > 0 then
                    fail=false
                    break
                end;
            end;
            
            if recipeCls.AccountNeedProperty ~= 'None' then
                local aObj = GetMyAccountObj()
                local sCount = TryGetProp(aObj, recipeCls.AccountNeedProperty); 
                
                local tradeBtn = GET_CHILD(ctrlset, "tradeBtn");
                if sCount > 0 then
                    fail=false
                    break
                end;
            end
        end
        if fail then
            ui.SysMsg("Exceeded trade count.")
            return
        end
        ui.SysMsg("Auto ticket trading.")
        local itemlist=session.GetItemIDList()
        session.ResetItemList()
        session.AddItemID(tostring(0), 1);
        local cntText = string.format("%s %s", recipeCls.ClassID, 1);
        item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText);

        local itemCls = GetClass("Item",recipeCls.TargetItem)
        ReserveScript(string.format('INV_ICON_USE(session.GetInvItemByType(%d));',itemCls.ClassID),1)
        ReserveScript("WORKPANEL_INITFRAME()",1.5)
        ReserveScript(retrystring.."(true)",2)
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function WORKPANEL_ENTER_CHALLENGE361(rep)
    if not rep and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",644).PlayPerResetType)==
    GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",644).PlayPerResetType) then
        WORKPANEL_BUY_ITEM({"PVP_MINE_41","PVP_MINE_40"},"WORKPANEL_ENTER_CHALLENGE361")
    else
        ReqChallengeAutoUIOpen(644)
    end
end
function WORKPANEL_ENTER_CHALLENGE400(rep)
    if not rep and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",645).PlayPerResetType)==
    GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",645).PlayPerResetType) then
        WORKPANEL_BUY_ITEM({"PVP_MINE_41","PVP_MINE_40"},"WORKPANEL_ENTER_CHALLENGE400")
    else
        ReqChallengeAutoUIOpen(645)
    end
end
function WORKPANEL_ENTER_CHALLENGE450(rep)
    if not rep and 
    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType)==
    GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType) then
        WORKPANEL_BUY_ITEM({"PVP_MINE_41","PVP_MINE_40"},"WORKPANEL_ENTER_CHALLENGE450")
    else
         ReqChallengeAutoUIOpen(646)
    end
end
function WORKPANEL_ENTER_HARDCHALLENGE(rep)
    if not rep and tonumber(GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",647).PlayPerResetType)  or 0)== 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_43","PVP_MINE_42"},"WORKPANEL_ENTER_HARDCHALLENGE")

    else
        ReqChallengeAutoUIOpen(647)
    end
end
function WORKPANEL_ENTER_MORING(rep)
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(608)==0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_45"},"WORKPANEL_ENTER_MORING")

    else
        ReqRaidAutoUIOpen(608)
    end
end
function WORKPANEL_ENTER_WITCH(rep)
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(619)==0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_44"},"WORKPANEL_ENTER_WITCH")

    else
        ReqRaidAutoUIOpen(619)
    end
end
function WORKPANEL_ENTER_GILTINE()
    ReqRaidAutoUIOpen(635)
end
function WORKPANEL_ENTER_VELNICE()
    ReqEnterSoloIndun(201,0)
end
function WORKPANEL_ENTER_ASSISTER()
    local acc_obj = GetMyAccountObj()
    local stage=TryGetProp(acc_obj,"ANCIENT_SOLO_STAGE_WEEK",0)
    ReqEnterSoloIndun(202,1)
end
function WORKPANEL_GET_RELIC_CLSID()
    local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
    local mapCls = GetClassByType("Map",pattern_info.mapID)

    local cls = GetClass("Indun",mapCls.ClassName.."_Auto")
    return cls.ClassID
end
function WORKPANEL_ENTER_RELIC(rep)
    EBI_try_catch{
        try = function()
        local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
        local mapCls = GetClassByType("Map",pattern_info.mapID)

        local cls = GetClass("Indun",mapCls.ClassName.."_Auto")
        
        ReqRaidAutoUIOpen(cls.ClassID)
    end,
    catch = function(error)
        ERROUT(error)
    end
    } 
end

function WORKPANEL_TOGGLE_PANEL()
    if g.settings.isopen==nil then
        g.settings.isopen=true
    else
        g.settings.isopen=not g.settings.isopen
    end
    WORKPANEL_INITFRAME()
    WORKPANEL_SAVE_SETTINGS()
end
function WORKPANEL_CREATECONTROL(frame)
    
    local fn=function (frame,carry,type,name,width,text,clickfn,offset)
        offset=offset or 0
        local control= frame:CreateOrGetControl(type,name,offset,0,width,frame:GetHeight())
        control:SetEventScript(ui.LBUTTONUP,"WORKPANEL_INTER")
        control:SetEventScriptArgString(ui.LBUTTONUP,clickfn)
        control:SetText(text)
        offset=offset+width
        return function(type,name,width,text,clickfn)
            return carry(frame,carry,type,name,width,text,clickfn,offset)
        end
    end
    

    return function (type,name,width,text,clickfn)
        return fn(frame,fn,type,name,width,text,clickfn,0)
    end
end
function WORKPANEL_INTER(parent,ctrl,argstr,argnum)
    local frame = ui.GetFrame(g.framename)
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(),parent:GetName(),ctrl:GetName(),4)
    _G[argstr]()
end