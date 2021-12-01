-- advancednumberinput.lua
local addonName = "advancednumberinput"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
local json = require "json_imc"
local libsearch
libsearch = libsearch or LIBITEMSEARCHER_V1_0 --dummy

g.version = 1
g.settings = g.settings or {}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "advancednumberinput"
g.debug = false
g.targetframename = nil
g.targetctrl = g.targetctrl or nil
g.closed = false
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
local function SetMousePos_Fixed(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    --return x*(sw/ow),y*(sh/oh)
    mouse.SetPos(x * (sw / ow), y * (sh / oh))
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
local g_account_prop_shop_table = {
    ["PVPMine"] = {
        ["coinName"] = "misc_pvp_mine2",
        ["propName"] = "MISC_PVP_MINE2"
    },
    ["SilverGachaShop"] = {
        ["coinName"] = "misc_silver_gacha_mileage",
        ["propName"] = "Mileage_SilverGacha"
    },
    ["GabijaCertificate"] = {
        ["coinName"] = "dummy_GabijaCertificate",
        ["propName"] = "GabijaCertificate"
    },
    ["TeamBattleLeagueShop"] = {
        ["coinName"] = "dummy_TeamBattleCoin",
        ["propName"] = "TeamBattleCoin"
    }
}
local function GetTradedCount(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)

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
local function GetOverbuyBuyableCount(recipeName)
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

local function GetBuyableCount(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    local accountCls = GetClassByType("Account", 1)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" and recipeCls.NeedProperty ~= 0 then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(accountCls, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end

    if
        recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" and
            recipeCls.AccountNeedProperty ~= 0
     then
        --local aObj = GetMyAccountObj()
        local sCount = TryGetProp(accountCls, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end
    return nil
end

local function GetMaxValueForEarthtower(frame, ctrl, value)
    local gbox = ctrl:GetParent()
    if gbox == nil then
        return
    end
    local parentCtrl = gbox:GetParent()
    if parentCtrl == nil then
        return
    end
    local ctrlset = parentCtrl:GetParent()
    if ctrlset == nil then
        return
    end
    local cnt = ctrlset:GetChildCount()
    local unitrequires = {}
    local limit = 9999999999
    -- item count increase
    local countText = value
    if cnt ~= nil then
        for i = 0, cnt - 1 do
            local eachSet = ctrlset:GetChildByIndex(i)
            if string.find(eachSet:GetName(), "EACHMATERIALITEM_") ~= nil then
                local recipecls = GetClass("ItemTradeShop", ctrlset:GetName())
                local targetItem = GetClass("Item", recipecls.TargetItem)

                -- item Name Setting
                local targetItemName_text = GET_CHILD_RECURSIVELY(ctrlset, "itemName")
                -- if targetItem.StringArg == "EnchantJewell" and recipecls.TargetItemAppendProperty ~= 'None' then
                --     targetItemName_text:SetTextByKey("value", "[Lv. "..recipecls.TargetItemAppendValue.."] "..targetItem.Name .. " [" .. recipecls.TargetItemCnt * countText .. ScpArgMsg("Piece") .. "]");
                -- else
                --     targetItemName_text:SetTextByKey("value", targetItem.Name.." ["..recipecls.TargetItemCnt * countText..ScpArgMsg("Piece").."]");
                -- end
                --print(tostring(recipecls.ClassID))
                --unitrequires[recipecls.ClassID] = recipecls.TargetItemCnt

                for j = 1, 5 do
                    if recipecls["Item_" .. j .. "_1"] ~= "None" then
                        local recipeItemCnt, recipeItemLv =
                            GET_RECIPE_REQITEM_CNT(recipecls, "Item_" .. j .. "_1", GetMyPCObject())

                        local main_frame = ui.GetFrame("earthtowershop")
                        local shopType = main_frame:GetUserValue("SHOP_TYPE")

                        recipeItemCnt =
                            GET_TOTAL_AMOUNT_OVERBUY(
                            shopType,
                            recipeItemCnt,
                            recipecls,
                            GetMyAccountObj(),
                            tonumber(countText)
                        )
                        local ingredient = GetClass("Item", recipecls["Item_" .. j .. "_1"])
                        local classname = ingredient.ClassName
                        for _, v in pairs(g_account_prop_shop_table) do
                            if (v.coinName == classname) then
                                classname = v.propName
                                break
                            end
                        end
                        unitrequires[classname] = recipeItemCnt
                    end
                end
            end
        end
        local coins = {}
        local aObj = GetMyAccountObj()
        local clsList, cnt = GetClassList("accountprop_inventory_list")
        for i = 0, cnt - 1 do
            local cls = GetClassByIndexFromList(clsList, i)
            if cls ~= nil then
                local PropName = cls.ClassName
                local value = TryGetProp(aObj, PropName, "None")
                if value == "None" then
                    value = 0
                end

                coins[PropName] = value
            end
        end
        for name, unit in pairs(unitrequires) do
            print(name)
            if coins[name] ~= nil then
                limit = math.min(limit, math.floor(coins[name] / unit))
            else
                local invItem = session.GetInvItemByName(name)
                if invItem ~= nil then
                    limit = math.min(limit, math.floor(invItem.count / unit))
                else
                    limit = 0
                end
            end
        end
        local recipecls = GetClass("ItemTradeShop", ctrlset:GetName())

        if (GetBuyableCount(recipecls.ClassName)) then
            limit =
                math.min(
                limit,
                (GetBuyableCount(recipecls.ClassName) or 0) + (GetOverbuyBuyableCount(recipecls.ClassName) or 0) -
                    (GetTradedCount(recipecls.ClassName) or 0)
            )
        end
        return limit
    end

    return value
end
local function HasJoystickEnhancer()
    return _G['ADDONS']['ebisuke']['joystickenhancer']~=nil
end
g.specials = {
    ["earthtowershop"] = {
        mode = "editasnumupdown",
        onprechange = function(frame, ctrl, value)
            value = math.max(math.min(GetMaxValueForEarthtower(frame, ctrl, value), value), 0)

            return value
        end,
        onpostchange = function(frame, ctrl, value)
            UPDATE_EARTHTOWERSHOP_CHANGECOUNT(frame, ctrl)
        end
    }
}

function ADVANCEDNUMBERINPUT_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function ADVANCEDNUMBERINPUT_LOAD_SETTINGS()

    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format("[%s] cannot load setting files", addonName))
        g.settings = {memory = 0}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    ADVANCEDNUMBERINPUT_UPGRADE_SETTINGS()
    ADVANCEDNUMBERINPUT_SAVE_SETTINGS()
end

function ADVANCEDNUMBERINPUT_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function ADVANCEDNUMBERINPUT_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            addon:RegisterMsg("FPS_UPDATE", "ADVANCEDNUMBERINPUT_ON_FPS_UPDATE")
            frame = ui.GetFrame(g.framename)
            local timer = frame:GetChild("addontimer")
            AUTO_CAST(timer)
            timer:SetUpdateScript("ADVANCEDNUMBERINPUT_ON_TIMER")
            timer:Start(0.1)
            ui.GetFrame(g.framename):ShowWindow(1)
            ADVANCEDNUMBERINPUT_LOAD_SETTINGS()
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end
function ADVANCEDNUMBERINPUT_ON_FPS_UPDATE()
    ui.GetFrame(g.framename):ShowWindow(1)
end
function ADVANCEDNUMBERINPUT_ON_TIMER()
    EBI_try_catch {
        try = function()
            if(ui.GetFrame(g.targetframename) == nil) then
                ADVANCEDNUMBERINPUT_DETACH()
            end
            if (ui.GetFrame("dialogselect"):IsVisible() == 1 and
                    ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit"):IsVisible() == 1 and
                    (ui.GetFocusObject()==nil or ui.GetFocusObject():GetName() ~= "numberEdit"))
            then
                AUTO_CAST(ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit")):Focus()
            end

            if g.targetctrl then
                local framename = g.targetctrl:GetTopParentFrame():GetName()
                if(framename == "dialogselect")then
                    if
                        framename == "dialogselect" and ui.GetFrame("dialogselect"):IsVisible() == 1 and
                            (ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit"):IsVisible() == 1)
                    then
                    else
                        ADVANCEDNUMBERINPUT_DETACH()
                    end
                end
            end

        
            local ctrl
            -- if
            --     (ui.GetFrame("dialogselect"):IsVisible() == 1 and
            --         ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit"):IsVisible() == 1)
            -- then
            --     ctrl = ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit")
                
            -- else
            if ui.GetFocusObject()==nil then
                return
            end
            ctrl = ADVANCEDNUMBERINPUT_FIND_CTRL(ui.GetFocusObject())
            --end
            if (ctrl == nil) then
                return
            end
            
            if (g.targetctrl) then
                if (g.closed==false and g.targetctrl:GetTopParentFrame():GetName() == ctrl:GetTopParentFrame():GetName()) then
                    return
                end
                ADVANCEDNUMBERINPUT_DETACH()
            end
            if (ctrl) then
                ADVANCEDNUMBERINPUT_ATTACH(ctrl)
            end
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end

function ADVANCEDNUMBERINPUT_ATTACH(ctrl)
    if (ctrl == nil) then
        return
    end
    if (g.targetctrl == ctrl) then
        return
    end
    if (g.targetctrl) then
        ADVANCEDNUMBERINPUT_DETACH()
        g.targetctrl = nil
    end
    if (ui.GetFrame("dialogselect"):IsVisible() == 1  or keyboard.IsKeyPressed("LSHIFT") == 1) then
        g.closed = false
        if(HasJoystickEnhancer())then
            local cursorctrl=ui.GetFrame("advancednumberinput"):GetChildRecursively("p5")
            SetMousePos_Fixed(cursorctrl:GetGlobalX()+cursorctrl:GetWidth()/2,cursorctrl:GetGlobalY()+cursorctrl:GetHeight()/2)
        end
    else
        g.closed = true
    end

    if (g.specials[ctrl:GetTopParentFrame():GetName()] ~= nil) then
        if (g.specials[ctrl:GetTopParentFrame():GetName()].mode == "editasnumupdown") then
            g.isnumupdown = "editasnumupdown"
            g.targetctrl = ctrl
        elseif (g.specials[ctrl:GetTopParentFrame():GetName()].mode == "numupdown") then
            g.isnumupdown = "numupdown"
            g.targetctrl = tolua.cast(ctrl, "ui::CNumUpDown")
        else
            g.targetctrl = ctrl
            g.isnumupdown = "edit"
        end
    else
        if (ctrl:GetClassName() == "numupdown") then
            g.isnumupdown = "numupdown"
            g.targetctrl = tolua.cast(ctrl, "ui::CNumUpDown")
        else
            g.targetctrl = ctrl
            g.isnumupdown = "edit"
        end
    end
    g.targetframename = g.targetctrl :GetTopParentFrame():GetName()
    local frame = ui.GetFrame("advancednumberinput_frame")
    frame:ShowWindow(1)
    ADVANCEDNUMBERINPUT_INITFRAME(frame)
end
function ADVANCEDNUMBERINPUT_INITFRAME(frame)
    EBI_try_catch {
        try = function()
            frame = frame or ui.GetFrame("advancednumberinput_frame")
            local ctrl = g.targetctrl
            if (ctrl == nil) then
                return
            end
            frame:RemoveAllChild()

            if g.closed then
                local rich = frame:CreateOrGetControl("button", "open", 0, 0, 48, 24)
                rich:SetSkinName("test_red_button")
                rich:SetText("{ol}Num")
                rich:SetEventScript(ui.LBUTTONUP, "ADVANCEDNUMBERINPUT_OPEN_INPUTFRAME")
                rich:SetClickSound("button_click_big")
                frame:Resize(48, 24)
            else
                frame:SetSkinName("None")

                frame:Resize(600, 200)

                local func = function(x, y, w, h, incw, inch, name, text, value, anotherscript)
                    local p1 = frame:CreateOrGetControl("button", name, x, y, w, h)
                    p1:SetText(text)
                    if (anotherscript) then
                        p1:SetEventScript(ui.LBUTTONUP, anotherscript)
                    else
                        p1:SetEventScript(ui.LBUTTONUP, "ADVANCEDNUMBERINPUT_CHANGE")
                    end

                    p1:SetEventScriptArgString(ui.LBUTTONUP, tostring(value))
                    p1:SetEventScript(ui.RBUTTONUP, "ADVANCEDNUMBERINPUT_DETACH")
                    return x + incw, y + inch
                end
                --generic

                local iw, ih = 0, 0
                if (g.isnumupdown == "numupdown" or g.isnumupdown == "editasnumupdown") then
                    local x, y = 8, 8
                    local w, h = 48, 24
                    local incx, incy = 48, 0
                    x, y = func(x, y, w , h, incx , incy, "<-", "{ol}BS", 1, "ADVANCEDNUMBERINPUT_BACKSPACE")
                    x, y = func(x, y, w , h, incx , incy, "MR", "{ol}{#FFFF00}MR", 1, "ADVANCEDNUMBERINPUT_MC")
                    x, y = func(x, y, w , h, incx , incy, "MS", "{ol}{#00FFFF}MS", 1, "ADVANCEDNUMBERINPUT_MS")
                    

                    x, y = 8, 8 + 24 + 24 + 24+ 24+ 24
                    x, y = func(x, y, w, h, incx*2, incy, "p0", "{ol}0", 0)
                    
                    x, y = func(x, y, w, h, incx, incy, "pAC", "{ol}AC", "ADVANCEDNUMBERINPUT_CLEAR")
                    
                    x, y = 8, 8 + 24 + 24 + 24+ 24
                    x, y = func(x, y, w, h, incx, incy, "p1", "{ol}1", 1)
                    x, y = func(x, y, w, h, incx, incy, "p2", "{ol}2", 2)
                    x, y = func(x, y, w, h, incx, incy, "p3", "{ol}3", 3)
                    x, y = 8, 8 + 24 + 24 + 24
                              
                    x, y = func(x, y, w, h, incx, incy, "p4", "{ol}4", 4)
                    x, y = func(x, y, w, h, incx, incy, "p5", "{ol}5", 5)
                    x, y = func(x, y, w, h, incx, incy, "p6", "{ol}6", 6)

                    x, y = 8, 8 + 24 + 24
                    x, y = func(x, y, w, h, incx, incy, "p7", "{ol}7", 7)
                    x, y = func(x, y, w, h, incx, incy, "p8", "{ol}8", 8)
                    x, y = func(x, y, w, h, incx, incy, "p9", "{ol}9", 9)
                    x, y = 8, 8 + 24 
                    x, y = func(x, y, w*1.5 , h, incx*1.5 , incy, "min", "{ol}MIN", 0,"ADVANCEDNUMBERINPUT_SETMIN")
                    x, y = func(x, y, w*1.5 , h, incx*1.5 , incy, "max", "{ol}MAX", 0,"ADVANCEDNUMBERINPUT_SETMAX")

                elseif (ctrl:GetClassName() == "edit") then
                    local x, y = 8, 8
                    local w, h = 48, 24
                    local incx, incy = 48, 0
                    x, y = func(x, y, w , h, incx , incy, "<-", "{ol}BS", 1, "ADVANCEDNUMBERINPUT_BACKSPACE")
                    x, y = func(x, y, w , h, incx , incy, "MR", "{ol}{#FFFF00}MR", 1, "ADVANCEDNUMBERINPUT_MC")
                    x, y = func(x, y, w , h, incx , incy, "MS", "{ol}{#00FFFF}MS", 1, "ADVANCEDNUMBERINPUT_MS")
                    x, y = 8, 8 + 24 + 24 + 24+ 24
                    x, y = func(x, y, w, h, incx*2, incy, "p0", "{ol}0", 0)
                    
                    x, y = func(x, y, w, h, incx, incy, "pAC", "{ol}AC", 0,"ADVANCEDNUMBERINPUT_CLEAR")
                    x, y = 8, 8 + 24 + 24 + 24
                    x, y = func(x, y, w, h, incx, incy, "p1", "{ol}1", 1)
                    x, y = func(x, y, w, h, incx, incy, "p2", "{ol}2", 2)
                    x, y = func(x, y, w, h, incx, incy, "p3", "{ol}3", 3)
                    x, y = 8, 8 + 24 + 24 
                    x, y = func(x, y, w, h, incx, incy, "p4", "{ol}4", 4)
                    x, y = func(x, y, w, h, incx, incy, "p5", "{ol}5", 5)
                    x, y = func(x, y, w, h, incx, incy, "p6", "{ol}6", 6)
                    x, y = 8, 8 + 24 
                    x, y = func(x, y, w, h, incx, incy, "p7", "{ol}7", 7)
                    x, y = func(x, y, w, h, incx, incy, "p8", "{ol}8", 8)
                    x, y = func(x, y, w, h, incx, incy, "p9", "{ol}9", 9)
                    if(ctrl:GetTopParentFrame():GetName()=='dialogselect')then
                        w, h = 64, 72
                        y=8
                        x, y = func(x, y, w, h, incx, incy, "enter", "{ol}ENTER", nil, "ADVANCEDNUMBERINPUT_ENTER")
                    end
                end
            end
            frame:SetGravity(ui.LEFT, ui.TOP)
            frame:SetOffset(ctrl:GetGlobalX(), ctrl:GetGlobalY() + ctrl:GetHeight())
            frame:SetLayerLevel(ctrl:GetTopParentFrame():GetLayerLevel() + 1)
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end
function ADVANCEDNUMBERINPUT_OPEN_INPUTFRAME()
    g.closed = false
    ADVANCEDNUMBERINPUT_INITFRAME()
end
function ADVANCEDNUMBERINPUT_ENTER()
    DIALOGSELECT_NUMBER_ENTER(ui.GetFrame("dialogselect"),ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit"))
end
function ADVANCEDNUMBERINPUT_CHANGE(_, _, argstr, argnum)
    EBI_try_catch {
        try = function()
            local value
            local frame = g.targetctrl:GetTopParentFrame()
            local ctrl = g.targetctrl
            if (g.isnumupdown) then
                value = g.targetctrl:GetNumber()
            else
                local text = g.targetctrl:GetText()
                value = tonumber(text)
            end
            if (value == nil) then
                value = 0
            end
            value = tostring(value) .. argstr
            value=tonumber(value)
            --SPECIALEFFECTS
            local framename = g.targetctrl:GetTopParentFrame():GetName()
            if (g.specials[framename]) then
                local special = g.specials[framename]
                value = special.onprechange(frame, ctrl, value)
            end

            if (g.isnumupdown == "numupdown") then
                --local min = g.targetctrl:GetMinValue()
                --local max = g.targetctrl:GetMinValue()
                --value = math.min(max, math.max(min, value))
                g.targetctrl:SetNumberValue(value)
            else
                -- local spc = g.targetctrl:GetEventScript("UI_CMD_TEXTCHANGE")
                -- _G[spc]()
                --g.targetctrl:SetText(tostring(value))
                g.targetctrl:SetText(tostring(value))
            end
            if (g.specials[framename]) then
                local special = g.specials[framename]
                special.onpostchange(frame, ctrl, value)
            end

            local func = g.targetctrl:GetEventScript(ui.PROPERTY_EDIT)
            if (func and _G[func]) then
                local argstr = g.targetctrl:GetEventScriptArgString(ui.PROPERTY_EDIT)
                local argnum = g.targetctrl:GetEventScriptArgNumber(ui.PROPERTY_EDIT)

                pcall(_G[func], g.targetctrl:GetTopParentFrame(), g.targetctrl, argstr, argnum)
            end
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end

function ADVANCEDNUMBERINPUT_CLEAR(frame, ctrl, argstr, argnum)
    g.targetctrl:SetText("0")
end
function ADVANCEDNUMBERINPUT_BACKSPACE(frame, ctrl, argstr, argnum)
    local text=  g.targetctrl:GetText()
    text=text:sub(1,#text-1)
    if(text=="")then
        text="0"
    end
    g.targetctrl:SetText(text)

end
function ADVANCEDNUMBERINPUT_MR(frame, ctrl, argstr, argnum)
    local memory=g.settings.memory or 0
    if (g.isnumupdown == "numupdown") then
        --local min = g.targetctrl:GetMinValue()
        --local max = g.targetctrl:GetMinValue()
        --value = math.min(max, math.max(min, value))
        g.targetctrl:SetNumberValue(memory)
    else
        -- local spc = g.targetctrl:GetEventScript("UI_CMD_TEXTCHANGE")
        -- _G[spc]()
        --g.targetctrl:SetText(tostring(value))
        g.targetctrl:SetText(tostring(memory))
    end
end
function ADVANCEDNUMBERINPUT_MS(frame, ctrl, argstr, argnum)
    local memory
    if (g.isnumupdown == "numupdown") then
        --local min = g.targetctrl:GetMinValue()
        --local max = g.targetctrl:GetMinValue()
        --value = math.min(max, math.max(min, value))
        memory= g.targetctrl:GetNumberValue()
    else
        -- local spc = g.targetctrl:GetEventScript("UI_CMD_TEXTCHANGE")
        -- _G[spc]()
        --g.targetctrl:SetText(tostring(value))
        memory = tonumber(g.targetctrl:GetText()) or 0
    end
    ADVANCEDNUMBERINPUT_SAVE_SETTINGS()
end
function ADVANCEDNUMBERINPUT_DETACH()
    if (g.targetctrl) then
        ui.CloseFrame("advancednumberinput_frame")
        g.targetctrl = nil
        g.closed = true
        g.targetframename =nil
    end
end
function ADVANCEDNUMBERINPUT_FIND_CTRL(ctrl)
    local framename = ctrl:GetTopParentFrame():GetName()
    if (framename == "inputstring") then
        return
    end
    if (framename == "accountwarehouse") then
        return
    end

    local frame = ui.GetFrame(framename)
    if (frame:IsVisible() == 0) then
        return nil
    end

    if (not ctrl) then
        return nil
    end
    AUTO_CAST(ctrl)
    if (ctrl:GetClassName() ~= "edit" and ctrl:GetClassName() ~= "numupdown") then
        return nil
    end
    if (ctrl:GetClassName() == "edit" and framename ~= "dialogselect") then
        if ctrl:GetText() == nil or ctrl:GetText()=='' or (not tonumber(ctrl:GetText())) then
         
            return nil
        end
    end
    return ctrl
end
