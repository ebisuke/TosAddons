--workpanel
local addonName = "workpanel"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
g.version = 0
g.settings = {x = 300, y = 300, isopen = false}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "workpanel"
g.debug = false
g.suppressshop = true
--ライブラリ読み込み
CHAT_SYSTEM("[WP]loaded")
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

local function DBGOUT(msg)
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end
local function GetRegion()
    if config.GetServiceNation() == "GLOBAL" then
        return "itos/en"
    elseif config.GetServiceNation() == "JPN" or config.GetServiceNation() == "GLOBAL_JP" then
        return "jtos/ja"
    elseif config.GetServiceNation() == "TAIWAN" then
        return "twtos/zh"
    elseif config.GetServiceNation() == "KOR" then
        return "ktos/ko"
    end
    return "itos/en"
end
-- function WORKPANEL_SOLODUNGEON_RANKINGPAGE_OPEN(frame)
--     if g.disablevelnicescoreboard then
--         --pass
--     else
--         return SOLODUNGEON_RANKINGPAGE_OPEN_OLD(frame)
--     end
-- end

function WORKPANEL_3SEC()
    --pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    WORKPANEL_INITFRAME()
end
function WORKPANEL_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            local addontimer = frame:GetChild("addontimer")
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0, 0)
            --addon:RegisterMsg('GAME_START_3SEC', 'WORKPANEL_INITFRAME')
            --acutil.setupHook(WORKPANEL_REQ_PVP_MINE_SHOP_OPEN,"REQ_PVP_MINE_SHOP_OPEN")
            
            addon:RegisterMsg("GAME_START_3SEC", "WORKPANEL_3SEC")
            --addon:RegisterMsg("DO_SOLODUNGEON_RANKINGPAGE_OPEN", "WORKPANEL_INITFRAME");
            --soloDungeonClient.ReqSoloDungeonRankingPage()
            g.suppressshop = true
            session.ResetItemList();
            WORKPANEL_LOAD_SETTINGS()

            --addon:RegisterMsg("GAME_START", "WORKPANEL_REFRESH")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function WORKPANEL_REFRESH()
    REQ_PVP_MINE_SHOP_OPEN()
    ReserveScript("ui.CloseFrame('earthtowershop')", 0.1)
    ReserveScript("WORKPANEL_INITFRAME()", 0.8)
end
function WORKPANEL_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function WORKPANEL_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format("[%s] cannot load setting files", addonName))
        g.settings = {isopen = false}
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

function WORKPANEL_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function WORKPANEL_ISINCITY()
    return true
    -- local mapClsName = session.GetMapName();

    -- if(mapClsName ~=  "c_Klaipe" and mapClsName ~=  "c_fedimian" and mapClsName ~=  "c_orsha")then
    --     return false
    -- end
    -- return true
end
function WORKPANEL_TICKET_STR(ticketname)


    local remain = WORKPANEL_GET_RECIPE_TRADE_COUNT(ticketname)
    local max = WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(ticketname)
    local overbuy = WORKPANEL_GET_MAX_OVERBUY_RECIPE_TRADE_COUNT(ticketname)
    local used = max - remain

    if (used >= max and overbuy and overbuy > 0) then
        return "{#FF3333}{ol}" .. used .. "/" .. (max + overbuy)
    end
    return "{#FFFFFF}{ol}" .. used .. "/" .. (max)
end
function WORKPANEL_INITFRAME()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:SetGravity(ui.RIGHT, ui.TOP)
            frame:RemoveAllChild()
            frame:SetLayerLevel(90)
            frame:SetSkinName("bg2")
            local isopen = g.settings.isopen

            local mapClsName = session.GetMapName()

            if not WORKPANEL_ISINCITY() then
                isopen = g.settings.isopenoutsidecity
            end
            local etc = GetMyEtcObject()
            --frame:SetMargin(0,0,0,0)
            local acc_obj = GetMyAccountObj()
            local stage = TryGetProp(acc_obj, "ANCIENT_SOLO_STAGE_WEEK", 0)

            if WORKPANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") == nil then
                error "fail"
            end
            frame:ShowWindow(1)
            -- -- giltine
            -- if(recipeName=='PVP_MINE_51') then
            --     recipeName='PVP_MINE_84'
            -- end
            -- --mythic
            -- if(recipeName=='PVP_MINE_46') then
            --     recipeName='PVP_MINE_83'
            -- end
            if isopen == false then
                frame:Resize(50, 40)

                --frame:SetMargin(0,0,0,0)
                WORKPANEL_CREATECONTROL(frame).next("button", "btntoggleopen", 50, "<<", "WORKPANEL_TOGGLE_PANEL")
            else
                frame:Resize(1850, 40)
                local aObj = GetMyAccountObj()
                local pvpmine = TryGetProp(aObj, "MISC_PVP_MINE2", "0")
                if(pvpmine=='None')then
                    pvpmine=0
                end
                
                WORKPANEL_CREATECONTROL(frame).next("button", "btntoggleopen", 50, ">>", "WORKPANEL_TOGGLE_PANEL").upper(
                    "richtext",
                    "labelpvpicon",
                    80,
                    "{ol}{img icon_item_pvpmine_2 18 18}",
                    ""
                )
                .under("richtext", "labelcoins", 80, "{ol}{s16}" .. GET_COMMAED_STRING(pvpmine), "")
                .next(
                    "richtext",
                    "dummy",
                    1,
                    "",
                    ""
                )
                .upper("richtext", "label1", 120, "{ol}Singularity", "").under(
                    "button",
                    "btnhardchaweekly",
                    60,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_42"),
                    "WORKPANEL_BUYITEM_HARDCHALLENGE_WEEKLY",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_42")
                )
                .under(
                    "button",
                    "btnhardchadaily",
                    60,
                    "{ol}D " .. WORKPANEL_TICKET_STR("PVP_MINE_41"),
                    "WORKPANEL_BUYITEM_HARDCHALLENGE_DAILY",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_41")
                )
                .next(
                    "button",
                    "btnsinglularity",
                    70,
                    "Left:" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType),
                    "WORKPANEL_ENTER_HARDCHALLENGE"
                )
                .upper(
                    "richtext",
                    "label2",
                    110,
                    "{ol}Challenge:" ..
                        GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) ..
                            "/" .. GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType),
                    ""
                )
                .under(
                    "button",
                    "btnchaweekly",
                    110,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_40"),
                    "WORKPANEL_BUYITEM_CHALLENGE_WEEKLY",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_40")
                )
                .next("button", "btnchallenge400", 70, "400Solo", "WORKPANEL_ENTER_CHALLENGE400")
                .next(
                    "richtext",
                    "dummy",
                    1,
                    "",
                    ""
                )
                .upper("button", "btnchallenge440Solo", 70, "440Solo", "WORKPANEL_ENTER_CHALLENGE440Solo")
                .under(
                    "button",
                    "btnchallenge440PT",
                    70,
                    "440PT",
                    "WORKPANEL_ENTER_CHALLENGE440Party"
                )
                .next("richtext", "dummy", 1, "", "").upper("richtext", "label3", 70, "{ol}Moring", "")
                .under(
                    "button",
                    "btnmorweekly",
                    70,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_45"),
                    "WORKPANEL_BUYITEM_MORING",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_45")
                )
                .next("button", "btnmoring", 50, WORKPANEL_GETINDUNENTERCOUNT(608), "WORKPANEL_ENTER_MORING")
                .upper(
                    "richtext",
                    "label4",
                    70,
                    "{ol}Witch",
                    ""
                )
                .under(
                    "button",
                    "btnwitchweekly",
                    70,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_44"),
                    "WORKPANEL_BUYITEM_WITCH",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_44")
                )
                .next("button", "btnwitch", 50, WORKPANEL_GETINDUNENTERCOUNT(619), "WORKPANEL_ENTER_WITCH")
                .upper(
                    "richtext",
                    "label5",
                    70,
                    "{ol}Giltine",
                    ""
                )
                .under(
                    "button",
                    "btngiltineweekly",
                    70,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_84"),
                    "WORKPANEL_BUYITEM_GILTINE",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_84")
                )
                .next("button", "btngiltineparty", 50,WORKPANEL_GETINDUNENTERCOUNT(635), "WORKPANEL_ENTER_GILTINE")
                .upper(
                    "richtext",
                    "label6",
                    70,
                    "{ol}Vasilissa",
                    ""
                )
                .under(
                    "button",
                    "btnvasilisasweekly",
                    70,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_53"),
                    "WORKPANEL_BUYITEM_VASILISSA",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_53")
                )
                .next(
                    "richtext",
                    "dummy2",
                    1,
                    "",
                    ""
                )
                .upper("button", "btnvasilissasolo", 100,  "{s12}Solo:{/}"..WORKPANEL_GETINDUNENTERCOUNT(656), "WORKPANEL_ENTER_VASILISSA_SOLO")
                .under("button", "btnvasilissaparty", 100,  "{s12}Party:{/}"..WORKPANEL_GETINDUNENTERCOUNT(656), "WORKPANEL_ENTER_VASILISSA")
                .next(
                    "richtext",
                    "dummy3",
                    1,
                    "",
                    ""
                )
                .upper(
                    "richtext",
                    "label7",
                    60,
                    "{ol}Relic",
                    ""
                )
                .under(
                    "button",
                    "btnrelicweekly",
                    70,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_83"),
                    "WORKPANEL_BUYITEM_RELIC",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_83")
                )
                .next("richtext", "dummy3", 1, "", "")
                .upper(
                    "button",
                    "btnrelicsolo",
                    100,
                    "{s12}Solo:{/}" ..
                        GET_CURRENT_ENTERANCE_COUNT(
                            GetClassByType("Indun", WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType
                        ) ..
                            "/" ..
                                GET_INDUN_MAX_ENTERANCE_COUNT(
                                    GetClassByType("Indun", WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType
                                ),
                    "WORKPANEL_ENTER_RELIC_SOLO"
                )
                .under(
                    "button",
                    "btnrelicparty",
                    100,
                    "{s12}Party:{/}" ..
                        GET_CURRENT_ENTERANCE_COUNT(
                            GetClassByType("Indun", WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType
                        ) ..
                            "/" ..
                                GET_INDUN_MAX_ENTERANCE_COUNT(
                                    GetClassByType("Indun", WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType
                                ),
                    "WORKPANEL_ENTER_RELIC"
                )
                .next(
                    "button",
                    "btnrelichard",
                    100,
                    "{s12}Hard:{/}:Left " ..
                        GET_CURRENT_ENTERANCE_COUNT(
                            GetClassByType("Indun", WORKPANEL_GET_RELIC_CLSID()).PlayPerResetType
                        ),
                    "WORKPANEL_ENTER_RELIC_HARD"
                )
                .next("richtext", "label8", 70, "{ol}Assister", "").next(
                    "button",
                    "btnassister",
                    50,
                    "" .. stage,
                    "WORKPANEL_ENTER_ASSISTER"
                )
                .upper("richtext", "label9", 100, "{ol}Velnice", "")
                .under(
                    "button",
                    "btnvelniceweekly",
                    100,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_52"),
                    "WORKPANEL_BUYITEM_VELNICE",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_52")
                )
                .next(
                    "button",
                    "btnvelnice",
                    50,
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) ..
                        "/" .. GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType),
                    "WORKPANEL_ENTER_VELNICE"
                )
                .upper("richtext", "label10", 70, "{ol}Heroic", "")
                .under(
                    "button",
                    "btnheroicweekly",
                    70,
                    "{ol}W " .. WORKPANEL_TICKET_STR("PVP_MINE_54"),
                    "WORKPANEL_BUYITEM_HEROIC",
                    WORKPANEL_GET_TICKET_PRICE("PVP_MINE_54")
                )
                .next(
                    "button",
                    "btnheroic",
                    50,
                    "Left:" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 652).PlayPerResetType),
                    "WORKPANEL_ENTER_HEROIC"
                )
                .next(
                    "button",
                    "btnrefresh",
                    50,
                    "Refresh",
                    "WORKPANEL_REFRESH"
                )
            end
            g.disablevelnicescoreboard = false
        end,
        catch = function(error)
            DBGOUT(error)
            local frame = ui.GetFrame(g.framename)
            frame:SetGravity(ui.RIGHT, ui.TOP)
            frame:RemoveAllChild()
            frame:Resize(10, 10)
            --retry
            ReserveScript("WORKPANEL_INITFRAME()", 1)
        end
    }
end
function WORKPANEL_GETINDUNENTERCOUNT(clsid)
    local indunCls = GetClassByType("Indun", clsid)
    
    local etc = GetMyEtcObject()
    return GET_CURRENT_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType")) ..
        "/" .. GET_INDUN_MAX_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))
end
function WORKPANEL_GETREMAININDUNENTERCOUNT(clsid)
    local indunCls = GetClassByType("Indun", clsid)

    local etc = GetMyEtcObject()

    if tonumber(GET_INDUN_MAX_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))) then
        return GET_INDUN_MAX_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType")) -
            GET_CURRENT_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))
    else
        return 9999
    end
end
function WORKPANEL_GETCURRENTINDUNENTERCOUNT(clsid)
    local indunCls = GetClassByType("Indun", clsid)

    local etc = GetMyEtcObject()

    return GET_CURRENT_ENTERANCE_COUNT(TryGetProp(indunCls, "PlayPerResetType"))
end

function WORKPANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    DBGOUT("recipeCls: " .. recipeName)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(sObj, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end

    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
 
        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end
    
    return nil
end

function WORKPANEL_IS_EXCEEDED_OVERBUY(ticketname)
    if(WORKPANEL_GET_RECIPE_TRADE_COUNT(ticketname) <= 0 and WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(ticketname) and
            WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(ticketname) > 0)
     then
        return true
    end
    return false
end
function WORKPANEL_GET_TICKET_PRICE(ticketname)

    local recipeCls = GetClass("ItemTradeShop", ticketname)
    local baseprice = recipeCls.Item_1_1_Cnt

    if (WORKPANEL_IS_EXCEEDED_OVERBUY(ticketname)) then
        return "{img icon_item_pvpmine_2 20 20}{ol}" ..
            GET_COMMAED_STRING(baseprice * (10000 + recipeCls.OverBuyRatio) / 10000.0) ..
                " {img red_up_arrow 20 20}" .. string.format("%.2f%%", recipeCls.OverBuyRatio / 100.0)
    else
        return "{img icon_item_pvpmine_2 20 20}{ol}" .. GET_COMMAED_STRING(baseprice)
    end
end
function WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    local accountCls = GetClassByType("Account", 1)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(accountCls, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end

    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
        --local aObj = GetMyAccountObj()
        local sCount = TryGetProp(accountCls, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end
    return nil
end
function WORKPANEL_GET_MAX_OVERBUY_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    local accountCls = GetClassByType("Account", 1)
    if recipeCls.MaxOverBuyCount ~= "None" then
        if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
            --local aObj = GetMyAccountObj()
            local sObj = GetMyAccountObj()
            return recipeCls.MaxOverBuyCount
        else
            local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
            return recipeCls.MaxOverBuyCount
        end
    end

    return nil
end
function WORKPANEL_GET_RECIPE_OVERBUY_TRADE_COUNT(recipeName)
    local count = WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName) -(WORKPANEL_GET_RECIPE_TRADE_COUNT(recipeName) or 0)
    local overbuy = WORKPANEL_GET_MAX_OVERBUY_RECIPE_TRADE_COUNT(recipeName) or 0
    if overbuy <= -1 then
        overbuy = 0
    end
    --DBGOUT("CURRENT:"..count.."MAX:"..WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName).."OVER:"..overbuy)
    return math.max(0,count-WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName))
end
function WORKPANEL_BUYITEM_HARDCHALLENGE_WEEKLY()
    WORKPANEL_BUYANDUSE("PVP_MINE_42", 647)
end
function WORKPANEL_BUYITEM_HARDCHALLENGE_DAILY()
    WORKPANEL_BUYANDUSE("PVP_MINE_41", 647)
end
function WORKPANEL_BUYITEM_CHALLENGE_WEEKLY()
    WORKPANEL_BUYANDUSE("PVP_MINE_40", 646)
end
function WORKPANEL_BUYITEM_MORING()
    WORKPANEL_BUYANDUSE("PVP_MINE_45", 608)
end
function WORKPANEL_BUYITEM_WITCH()
    WORKPANEL_BUYANDUSE("PVP_MINE_44", 619)
end
function WORKPANEL_BUYITEM_GILTINE()

    WORKPANEL_BUYANDUSE("PVP_MINE_84", 635)
end
function WORKPANEL_BUYITEM_VASILISSA()
    WORKPANEL_BUYANDUSE("PVP_MINE_53", 656)
end
function WORKPANEL_BUYITEM_RELIC()
   
    WORKPANEL_BUYANDUSE("PVP_MINE_83", WORKPANEL_GET_RELIC_CLSID())
end
function WORKPANEL_BUYITEM_VELNICE()
    WORKPANEL_BUYANDUSE("PVP_MINE_52", 201)
end
function WORKPANEL_BUYITEM_HEROIC()
    WORKPANEL_BUYANDUSE("PVP_MINE_54", 652)
end

function WORKPANEL_BUYANDUSE(recipeName, indunclsid, force)
    EBI_try_catch {
        try = function()

            local count = WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName) -(WORKPANEL_GET_RECIPE_TRADE_COUNT(recipeName) or 0)
            local overbuy = WORKPANEL_GET_MAX_OVERBUY_RECIPE_TRADE_COUNT(recipeName) or 0
            if overbuy <= -1 then
                overbuy = 0
            end
            --DBGOUT("CURRENT:"..count.."MAX:"..WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName).."OVER:"..overbuy)
            if count >= overbuy+WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName) then
                ui.SysMsg("No trade count.")
                return
            end
            local remain = WORKPANEL_GETREMAININDUNENTERCOUNT(indunclsid)
            if indunclsid == 647 or indunclsid == WORKPANEL_GET_RELIC_HARD_CLSID() or indunclsid == 652 then
                remain = WORKPANEL_GETCURRENTINDUNENTERCOUNT(indunclsid)
            end
            if recipeName == "PVP_MINE_54" and remain > 0 then
                ui.SysMsg("Use the current remaining before buying a ticket.")
                return
            end
            if not force and remain > 0 then
                ui.MsgBox(
                    "回数が残っていますが使用しますか？",
                    string.format("WORKPANEL_BUYANDUSE('%s',%d,true)", recipeName, indunclsid),
                    "None"
                )
                return
            end
            local recipeCls = GetClass("ItemTradeShop", recipeName)
            ui.SysMsg("Auto ticket trading.")
            session.ResetItemList()
            session.AddItemID(tostring(0), 1)
            local itemlist = session.GetItemIDList()
            local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
            item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)

            local itemCls = GetClass("Item", recipeCls.TargetItem)
            ReserveScript(string.format("WORKPANEL_INV_ICON_USE_INTER(session.GetInvItemByType(%d));", itemCls.ClassID), 1)
            ReserveScript("WORKPANEL_INITFRAME()", 2)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function WORKPANEL_INV_ICON_USE_INTER(invItem)
    if invItem==nil then
        ui.SysMsg("No item.")
        return
    end
    INV_ICON_USE(invItem)
end
function WORKPANEL_BUY_ITEM(recipeNameArray, retrystring,rep)
    EBI_try_catch {
        try = function()
            local recipeClsGuid
            local fail = true
            for _, recipeName in ipairs(recipeNameArray) do
                recipeCls = GetClass("ItemTradeShop", recipeName)
                if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
                    local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
                    local sCount = TryGetProp(sObj, recipeCls.NeedProperty)

                    if sCount > 0 then
                        fail = false
                        break
                    end
                end

                if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
                    local aObj = GetMyAccountObj()
                    local sCount = TryGetProp(aObj, recipeCls.AccountNeedProperty)

                    if sCount > 0 then
                        fail = false
                        break
                    end
                end
                --超過購入
                if recipeCls.OverBuyProperty ~= "None" and recipeCls.OverBuyProperty ~= "" then
                    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
                        local aObj = GetMyAccountObj()
                        local sCount = TryGetProp(aObj, recipeCls.OverBuyProperty)

                        if sCount <WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)+ WORKPANEL_GET_RECIPE_OVERBUY_TRADE_COUNT(recipeName) then
                            fail = false
                            break
                        end
                    else
                        local aObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
                        local sCount = TryGetProp(aObj, recipeCls.OverBuyProperty)

                        if sCount < WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)+WORKPANEL_GET_RECIPE_OVERBUY_TRADE_COUNT(recipeName) then
                            fail = false
                            break
                        end
                    end
                end
            end
            if fail then
                ui.SysMsg("Exceeded trade count.")
                return
            end
            ui.SysMsg("Auto ticket trading.")
            session.ResetItemList()
            session.AddItemID(tostring(0), 1)
            local itemlist = session.GetItemIDList()
            local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
            item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)

            local itemCls = GetClass("Item", recipeCls.TargetItem)
            ReserveScript(string.format("WORKPANEL_INV_ICON_USE_INTER(session.GetInvItemByType(%d));", itemCls.ClassID), 1)
            ReserveScript("WORKPANEL_INITFRAME()", 2)
            if retrystring and (not rep) then
                ReserveScript(retrystring .. "(true)", 3)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function WORKPANEL_ENTER_CHALLENGE400(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if
        not rep and
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) ==
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType)
     then
        WORKPANEL_BUY_ITEM({"PVP_MINE_40"}, "WORKPANEL_ENTER_CHALLENGE400",rep)
    else
        ReqChallengeAutoUIOpen(644)
        ReserveScript("ReqMoveToIndun(1,0)", 1.25)
    end
end
function WORKPANEL_ENTER_CHALLENGE440Solo(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if
        not rep and
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 645).PlayPerResetType) ==
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 645).PlayPerResetType)
     then
        WORKPANEL_BUY_ITEM({"PVP_MINE_40"}, "WORKPANEL_ENTER_CHALLENGE440Solo",rep)
    else
        ReqChallengeAutoUIOpen(645)
        ReserveScript("ReqMoveToIndun(1,0)", 1.25)
    end
end
function WORKPANEL_ENTER_CHALLENGE440Party(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if
        not rep and
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) ==
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType)
     then
        WORKPANEL_BUY_ITEM({"PVP_MINE_40"}, "WORKPANEL_ENTER_CHALLENGE440Party",rep)
    else
        ReqChallengeAutoUIOpen(646)
    end
end
function WORKPANEL_ENTER_HARDCHALLENGE(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if not rep and tonumber(GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) or 0) == 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_41", "PVP_MINE_42"}, "WORKPANEL_ENTER_HARDCHALLENGE",rep)
    else
        ReqChallengeAutoUIOpen(647)
    end
end
function WORKPANEL_ENTER_MORING(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(608) == 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_45"}, "WORKPANEL_ENTER_MORING",rep)
    else
        ReqRaidAutoUIOpen(608)
    end
end
function WORKPANEL_ENTER_WITCH(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(619) == 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_44"}, "WORKPANEL_ENTER_WITCH",rep)
    else
        ReqRaidAutoUIOpen(619)
    end
end
function WORKPANEL_ENTER_GILTINE()
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(635) == 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_84"}, "WORKPANEL_ENTER_GILTINE",rep)
    else
        ReqRaidAutoUIOpen(635)
    end

end

function WORKPANEL_ENTER_VELNICE(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if
        not rep and
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) ==
                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType)
     then
        WORKPANEL_BUY_ITEM({"PVP_MINE_52"}, "WORKPANEL_ENTER_VELNICE",rep)
    else
        --ReqEnterSoloIndun(201,0)
        local indun_cls_id = 201
        local indun_cls = GetClassByType("Indun", indun_cls_id)
        if indun_cls ~= nil then
            local name = TryGetProp(indun_cls, "Name", "None")
            local account_obj = GetMyAccountObj()
            if account_obj ~= nil then
                local stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE", 0)
                local yesScp = "INDUNINFO_MOVE_TO_SOLO_DUNGEON_PRECHECK"
                local title = ScpArgMsg("Select_Stage_SoloDungeon", "Stage", stage + 5)
                INDUN_EDITMSGBOX_FRAME_OPEN(indun_cls_id, title, "", yesScp, "", 1, stage + 5, 1)
            end
        end
    end
end
function WORKPANEL_ENTER_VASILISSA(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(656) == 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_53"}, "WORKPANEL_ENTER_VASILISSA",rep)
    else
        ReqRaidAutoUIOpen(656)
    end
end
function WORKPANEL_ENTER_VASILISSA_SOLO(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end
    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(657) == 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_53"}, "WORKPANEL_ENTER_VASILISSA_SOLO",rep)
    else
        ReqRaidAutoUIOpen(657)
    end
end
function WORKPANEL_ENTER_ASSISTER()
    local acc_obj = GetMyAccountObj()
    local stage = TryGetProp(acc_obj, "ANCIENT_SOLO_STAGE_WEEK", 0)
    ReqEnterSoloIndun(202, 1)
end
function WORKPANEL_GET_RELIC_CLSID()
    local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
    local mapCls = GetClassByType("Map", pattern_info.mapID)
    local auto = {
        Mythic_firetower = "Mythic_FireTower_Auto",
        Mythic_startower = "Mythic_startower_Auto",
        Mythic_thorn1 = "Mythic_thorn2_Auto",
        Mythic_castle = "Mythic_castle_Auto"
    }
    local cls = GetClass("Indun", auto[mapCls.ClassName])
    return cls.ClassID
end
function WORKPANEL_GET_RELIC_HARD_CLSID()
    local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
    local mapCls = GetClassByType("Map", pattern_info.mapID)
    local auto = {
        Mythic_firetower = "Mythic_FireTower_Auto_Hard",
        Mythic_startower = "Mythic_startower_Auto_Hard",
        Mythic_thorn1 = "Mythic_thorn2_Auto_Hard",
        Mythic_castle = "Mythic_castle_Auto_Hard"
    }
    local cls = GetClass("Indun", auto[mapCls.ClassName])
    return cls.ClassID
end
function WORKPANEL_ENTER_RELIC(rep)
    EBI_try_catch {
        try = function()
            if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(WORKPANEL_GET_RELIC_CLSID()) == 0 then
                WORKPANEL_BUY_ITEM({"PVP_MINE_83"}, "WORKPANEL_ENTER_RELIC",rep)
            else
                local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
                local mapCls = GetClassByType("Map", pattern_info.mapID)
                local auto = {
                    Mythic_firetower = "Mythic_FireTower_Auto",
                    Mythic_startower = "Mythic_startower_Auto",
                    Mythic_thorn1 = "Mythic_thorn2_Auto",
                    Mythic_castle = "Mythic_castle_Auto"
                }
                
                local cls = GetClass("Indun", auto[mapCls.ClassName])
                ReqRaidAutoUIOpen(cls.ClassID)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function WORKPANEL_ENTER_RELIC_SOLO(rep)
    EBI_try_catch {
        try = function()
            if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(WORKPANEL_GET_RELIC_CLSID()) == 0 then
                WORKPANEL_BUY_ITEM({"PVP_MINE_83"}, "WORKPANEL_ENTER_RELIC",rep)
            else
                local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
                local mapCls = GetClassByType("Map", pattern_info.mapID)
                local auto = {
                    Mythic_firetower = "Mythic_FireTower_Auto_Solo",
                    Mythic_startower = "Mythic_startower_Auto_Solo",
                    Mythic_castle = "Mythic_castle_Auto_Solo"
                }
                
                local cls = GetClass("Indun", auto[mapCls.ClassName])
                if(cls==nil)then
                    ERROUT("Unknown Raid. Please report to the author.")
                    return
                end
                ReqRaidAutoUIOpen(cls.ClassID)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function WORKPANEL_ENTER_RELIC_HARD(rep)
    EBI_try_catch {
        try = function()
            local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
            local mapCls = GetClassByType("Map", pattern_info.mapID)
            local auto = {
                Mythic_firetower = "Mythic_FireTower_Auto_Hard",
                Mythic_startower = "Mythic_startower_Auto_Hard",
                Mythic_thorn1 = "Mythic_thorn2_Auto_Hard",
                Mythic_castle = "Mythic_castle_Auto_Hard"
            }
            
            local cls = GetClass("Indun", auto[mapCls.ClassName])
            ReqRaidAutoUIOpen(cls.ClassID)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function WORKPANEL_ENTER_HEROIC(rep)
    if WORKPANEL_ISINCITY() == false then
        ui.SysMsg("Cannot use outside city.")
        return
    end

    if not rep and WORKPANEL_GETREMAININDUNENTERCOUNT(652) == 0 then
        WORKPANEL_BUY_ITEM({"PVP_MINE_54"}, "WORKPANEL_ENTER_HEROIC",rep)
    else
        ReqTOSHeroEnter(652)
    end

end
function WORKPANEL_TOGGLE_PANEL()
    if not WORKPANEL_ISINCITY() then
        if g.settings.isopenoutsidecity == nil then
            g.settings.isopenoutsidecity = true
        else
            g.settings.isopenoutsidecity = not g.settings.isopenoutsidecity
        end
    else
        if g.settings.isopen == nil then
            g.settings.isopen = true
        else
            g.settings.isopen = not g.settings.isopen
        end
    end
    WORKPANEL_INITFRAME()
    WORKPANEL_SAVE_SETTINGS()
end
function WORKPANEL_CREATECONTROL(frame)
    local carryfn = function(carry, offsetx, basex, prevmode, tooltip)
        return {
            next = function(type, name, width, text, clickfn, tooltip)
                return carry(frame, carry, type, name, width, text, clickfn, offsetx, basex, 0, prevmode, tooltip)
            end,
            upper = function(type, name, width, text, clickfn, tooltip)
                return carry(frame, carry, type, name, width, text, clickfn, offsetx, basex, 1, prevmode, tooltip)
            end,
            under = function(type, name, width, text, clickfn, tooltip)
                return carry(frame, carry, type, name, width, text, clickfn, offsetx, basex, 2, prevmode, tooltip)
            end
        }
    end

    local nextfn = function(frame, carry, type, name, width, text, clickfn, offsetx, basex, mode, prevmode, tooltip)
        local frame = ui.GetFrame(g.framename)
        offsetx = offsetx or 0
        if mode == 0 then
            if offsetx ~= basex then
                basex = offsetx
            end
        else
            if mode ~= prevmode then
                offsetx = basex
            end
        end
        local offsety = 0
        local height = frame:GetHeight()
        if mode == 1 or mode == 2 then
            height = height / 2
        end
        if mode == 2 then
            offsety = 20
        end

        local control = frame:CreateOrGetControl(type, name, offsetx, offsety, width, height)
        control:SetEventScript(ui.LBUTTONUP, "WORKPANEL_INTER")
        control:SetEventScriptArgString(ui.LBUTTONUP, clickfn)
        control:SetText(text)
        if (tooltip) then
            control:SetTextTooltip(tooltip)
        end
        if mode == 0 then
            offsetx = offsetx + width
            basex = basex + width
        else
            offsetx = offsetx + width
        end

        return carryfn(carry, offsetx, basex, mode)
    end

    return carryfn(nextfn, 0, 0, 0)
end
function WORKPANEL_INTER(parent, ctrl, argstr, argnum)
    local frame = ui.GetFrame(g.framename)
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), parent:GetName(), ctrl:GetName(), 4)
    _G[argstr]()
end
