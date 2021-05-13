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
function WORKPANEL_ISINCITY()
    local mapClsName = session.GetMapName();

    if(mapClsName ~=  "c_Klaipe" and mapClsName ~=  "c_fedimian" and mapClsName ~=  "c_orsha")then
        return false
    end
    return true
end
function WORKPANEL_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:SetGravity(ui.RIGHT,ui.TOP)
            frame:RemoveAllChild()
            frame:SetLayerLevel(90)
            frame:SetSkinName("bg2")
            local isopen = g.settings.isopen

            local mapClsName = session.GetMapName();

            if not WORKPANEL_ISINCITY() then
                isopen = g.settings.isopenoutsidecity 
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
            if WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")==nil then
                error "fail"
            end
            frame:ShowWindow(1)
            if isopen==false then
                frame:Resize(50,40)

                --frame:SetMargin(0,0,0,0)
                WORKPANEL_CREATECONTROL(frame)
                .next("button","btntoggleopen",50,"<<","WORKPANEL_TOGGLE_PANEL")
                
            else
                frame:Resize(1300,40)
                
                WORKPANEL_CREATECONTROL(frame)
                .next("button","btntoggleopen",50,">>","WORKPANEL_TOGGLE_PANEL")
                
                .upper("richtext","label1",120,"{ol}Singularity","")
                .under("button","btnhardchaweekly",60,"{ol}W "..WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42"),"WORKPANEL_BUYITEM_HARDCHALLENGE_WEEKLY")
                .under("button","btnhardchadaily",60,"{ol}D "..WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_43"),"WORKPANEL_BUYITEM_HARDCHALLENGE_DAILY")
                .next("button","btnsinglularity",70,"Left:"..GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",647).PlayPerResetType),"WORKPANEL_ENTER_HARDCHALLENGE")
                .upper("richtext","label2",120,"{ol}Challenge"..
                GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType).."/"..
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType)
                ,"")
                .under("button","btnchaweekly",60,"{ol}W "..WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40"),"WORKPANEL_BUYITEM_CHALLENGE_WEEKLY")
                .under("button","btnchadaily",60,"{ol}D "..WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41"),"WORKPANEL_BUYITEM_CHALLENGE_DAILY")
                .next("button","btnchallenge461",50,"361","WORKPANEL_ENTER_CHALLENGE361")
                .next("button","btnchallenge400",50,"400","WORKPANEL_ENTER_CHALLENGE400")
                .next("button","btnchallenge450",50,"450","WORKPANEL_ENTER_CHALLENGE450")
                .upper("richtext","label3",70,"{ol}Moring","")
                .under("button","btnmorweekly",70,"{ol}W "..WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_45"),"WORKPANEL_BUYITEM_MORING")
                .next("button","btnmoring",50,WORKPANEL_GETINDUNENTERCOUNT(608),"WORKPANEL_ENTER_MORING")
                .upper("richtext","label4",70,"{ol}Witch","")
                .under("button","btnwitchweekly",70,"{ol}W "..WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_44"),"WORKPANEL_BUYITEM_WITCH")
                .next("button","btnwitch",50,WORKPANEL_GETINDUNENTERCOUNT(619),"WORKPANEL_ENTER_WITCH")
                .next("richtext","label5",70,"{ol}Giltine","")
                .next("button","btngiltine",50,WORKPANEL_GETINDUNENTERCOUNT(635),"WORKPANEL_ENTER_GILTINE")
                .upper("richtext","label6",60,"{ol}Relic","")
                .under("button","btnrelicweekly",70,"{ol}W "..WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_46"),"WORKPANEL_BUYITEM_RELIC")
                .next("button","btnrelic",50,GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType).."/"..
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType),"WORKPANEL_ENTER_RELIC")
                .next("richtext","label7",70,"{ol}Assister","")
                .next("button","btnassister",50,""..stage,"WORKPANEL_ENTER_ASSISTER")
                .next("richtext","label8",70,"{ol}Velnice","")
                .next("button","btnvelnice",50,""..velnicestage,"WORKPANEL_ENTER_VELNICE")
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
    return GET_CURRENT_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType")).."/"..GET_INDUN_MAX_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))
end
function WORKPANEL_GETREMAININDUNENTERCOUNT(clsid)
    local indunCls=GetClassByType("Indun",clsid)
    
    local etc=GetMyEtcObject()
    
    return GET_INDUN_MAX_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))-GET_CURRENT_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))
  
end
function WORKPANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    if recipeCls.NeedProperty ~= 'None' then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop");
        local sCount = TryGetProp(sObj, recipeCls.NeedProperty); 
        
        if sCount then
            return sCount
            
        end;
    end;
    
    if recipeCls.AccountNeedProperty ~= 'None' then
        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipeCls.AccountNeedProperty); 
        
        if sCount  then
            return sCount
            
        end;
    end
    return nil
end
function WORKPANEL_BUYITEM_HARDCHALLENGE_WEEKLY()
    WORKPANEL_BUYANDUSE("PVP_MINE_42",647)
end
function WORKPANEL_BUYITEM_HARDCHALLENGE_DAILY()
    WORKPANEL_BUYANDUSE("PVP_MINE_43",647)
end
function WORKPANEL_BUYITEM_CHALLENGE_WEEKLY()
    WORKPANEL_BUYANDUSE("PVP_MINE_40",646)
end
function WORKPANEL_BUYITEM_CHALLENGE_DAILY()
    WORKPANEL_BUYANDUSE("PVP_MINE_41",646)
end
function WORKPANEL_BUYITEM_MORING()
    WORKPANEL_BUYANDUSE("PVP_MINE_45",608)
end
function WORKPANEL_BUYITEM_WITCH()
    WORKPANEL_BUYANDUSE("PVP_MINE_44",619)
end
function WORKPANEL_BUYITEM_RELIC()
    WORKPANEL_BUYANDUSE("PVP_MINE_46",WORKPANEL_GET_RELIC_CLSID())
end
function WORKPANEL_BUYANDUSE(recipeName,indunclsid,force)
    local count=WORKPANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    if count==0 then
        ui.SysMsg("No trade count.")
        return
    end
    if not force and WORKPANEL_GETREMAININDUNENTERCOUNT(indunclsid) > 0 then
        ui.MsgBox("回数が残っていますが使用しますか？",string.format("WORKPANEL_BUYANDUSE('%s',%d,true)",recipeName,indunclsid),"None")
        return
    end
    local recipeCls= GetClass("ItemTradeShop", recipeName)
    ui.SysMsg("Auto ticket trading.")
    session.ResetItemList()
    session.AddItemID(tostring(0), 1);
    local itemlist=session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1));
    item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText);

    local itemCls = GetClass("Item",recipeCls.TargetItem)
    ReserveScript(string.format('INV_ICON_USE(session.GetInvItemByType(%d));',itemCls.ClassID),1)
    ReserveScript("WORKPANEL_INITFRAME()",2)
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
        session.ResetItemList()
        session.AddItemID(tostring(0), 1);
        local itemlist=session.GetItemIDList()
        local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1));
        item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText);

        local itemCls = GetClass("Item",recipeCls.TargetItem)
        ReserveScript(string.format('INV_ICON_USE(session.GetInvItemByType(%d));',itemCls.ClassID),1)
        ReserveScript("WORKPANEL_INITFRAME()",2)
        if retrystring then
            ReserveScript(retrystring.."(true)",3)
        end
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function WORKPANEL_ENTER_CHALLENGE361(rep)
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
    if not rep and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",644).PlayPerResetType)==
    GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",644).PlayPerResetType) then
        WORKPANEL_BUY_ITEM({"PVP_MINE_41","PVP_MINE_40"},"WORKPANEL_ENTER_CHALLENGE361")
    else
        ReqChallengeAutoUIOpen(644)
    end
end
function WORKPANEL_ENTER_CHALLENGE400(rep)
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
    if not rep and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",645).PlayPerResetType)==
    GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",645).PlayPerResetType) then
        WORKPANEL_BUY_ITEM({"PVP_MINE_41","PVP_MINE_40"},"WORKPANEL_ENTER_CHALLENGE400")
    else
        ReqChallengeAutoUIOpen(645)
    end
end
function WORKPANEL_ENTER_CHALLENGE450(rep)
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
    if not rep and 
    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType)==
    GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun",646).PlayPerResetType) then
        WORKPANEL_BUY_ITEM({"PVP_MINE_41","PVP_MINE_40"},"WORKPANEL_ENTER_CHALLENGE450")
    else
         ReqChallengeAutoUIOpen(646)
    end
end
function WORKPANEL_ENTER_HARDCHALLENGE(rep)
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
    if not rep and tonumber(GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun",647).PlayPerResetType)  or 0)== 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_43","PVP_MINE_42"},"WORKPANEL_ENTER_HARDCHALLENGE")

    else
        ReqChallengeAutoUIOpen(647)
    end
end
function WORKPANEL_ENTER_MORING(rep)
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(608)==0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_45"},"WORKPANEL_ENTER_MORING")

    else
        ReqRaidAutoUIOpen(608)
    end
end
function WORKPANEL_ENTER_WITCH(rep)
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(619)==0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_44"},"WORKPANEL_ENTER_WITCH")

    else
        ReqRaidAutoUIOpen(619)
    end
end
function WORKPANEL_ENTER_GILTINE()
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
    ReqRaidAutoUIOpen(635)
end
function WORKPANEL_ENTER_VELNICE()
    if WORKPANEL_ISINCITY()==false then
        ui.SysMsg("Cannot use outside city.")
        return 
    end
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
            if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(WORKPANEL_GET_RELIC_CLSID())==0 then
                WORKPANEL_BUY_ITEM({"PVP_MINE_46"},"WORKPANEL_ENTER_RELIC")
        
            else
            
                local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
                local mapCls = GetClassByType("Map",pattern_info.mapID)

                local cls = GetClass("Indun",mapCls.ClassName.."_Auto")
                
                ReqRaidAutoUIOpen(cls.ClassID)
            end
        end,
    catch = function(error)
        ERROUT(error)
    end
    } 
end

function WORKPANEL_TOGGLE_PANEL()
    if not WORKPANEL_ISINCITY() then
        if g.settings.isopenoutsidecity==nil then
            g.settings.isopenoutsidecity=true
        else
            g.settings.isopenoutsidecity=not g.settings.isopenoutsidecity
        end
    else
        if g.settings.isopen==nil then
            g.settings.isopen=true
        else
            g.settings.isopen=not g.settings.isopen
        end
    end
    WORKPANEL_INITFRAME()
    WORKPANEL_SAVE_SETTINGS()
end
function WORKPANEL_CREATECONTROL(frame)
    
    local carryfn=function (carry,offsetx,basex,prevmode)
        return {
            next=function(type,name,width,text,clickfn)
                return carry(frame,carry,type,name,width,text,clickfn,offsetx,basex,0,prevmode)
            end,
            upper=function(type,name,width,text,clickfn)
                return carry(frame,carry,type,name,width,text,clickfn,offsetx,basex,1,prevmode)
            end,
            under=function(type,name,width,text,clickfn)
                return carry(frame,carry,type,name,width,text,clickfn,offsetx,basex,2,prevmode)
            end,
            
        }
    end

    local nextfn=function (frame,carry,type,name,width,text,clickfn,offsetx,basex,mode,prevmode)

        offsetx = offsetx or 0
        if mode==0 then
            if offsetx~=basex then
                basex=offsetx
            end
        else
            if mode~=prevmode then
                offsetx=basex
            end
        end
        local offsety=0
        local height=frame:GetHeight()
        if mode==1 or mode == 2 then
            height=height/2
        end
        if mode==2 then
            offsety=20
        end

        local control= frame:CreateOrGetControl(type,name,offsetx,offsety,width,height)
        control:SetEventScript(ui.LBUTTONUP,"WORKPANEL_INTER")
        control:SetEventScriptArgString(ui.LBUTTONUP,clickfn)
        control:SetText(text)

        if mode==0 then
            offsetx=offsetx+width
            basex=basex+width
        
        else
        
            offsetx=offsetx+width
        end
    
        return carryfn(carry,offsetx,basex,mode)
    end
    

    return carryfn(nextfn,0,0,0)

end
function WORKPANEL_INTER(parent,ctrl,argstr,argnum)
    local frame = ui.GetFrame(g.framename)
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(),parent:GetName(),ctrl:GetName(),4)
    _G[argstr]()
end