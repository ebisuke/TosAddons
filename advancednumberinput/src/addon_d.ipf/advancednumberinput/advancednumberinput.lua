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
g.targetctrlpath = g.targetctrlpath or nil
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
function string.split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t, cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
    end
    return t
 end
  
local function GetTargetCtrlPath(ctrl)
    local path = ""
    local parent = ctrl
    while parent ~= nil and parent:GetClassName()~='frame' do
    
        if( parent:GetClassName()~='nestgroup') then
            path = parent:GetName() .. "/" .. path
        end
        --print(parent:GetClassName()..':'..parent:GetName())
        parent = parent:GetParent()
    end
 
    return path
end
local function GetCtrlByPath(root, path)
   
    local ctrl = root
    local path_list = string.split(path, "/")
    for i = 1, #path_list do
    
        if(not ctrl) then

            return nil
        end
       
        if(path_list[i]~='')then
            local pp = ctrl:GetChild(path_list[i])
            if pp==nil then
               pp= ctrl:GetControlSet(path_list[i])
            end
            ctrl=pp
        end
    end
    return ctrl
end
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

    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" and
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
local function GetCurrentCtrl()
    local frame = ui.GetFrame(g.targetframename)
    if(g.targetctrlpath ~= nil) then
        return GetCtrlByPath(frame, g.targetctrlpath)
    else
        return nil
    end

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
        print(tostring(GetTradedCount(recipecls.ClassName)))
        if (GetBuyableCount(recipecls.ClassName)) then
            
            limit =
                math.min(
                limit,
                (GetTradedCount(recipecls.ClassName) or 0) + (GetOverbuyBuyableCount(recipecls.ClassName) or 999999999)
            )
        end
        return limit
    end

    return value
end
local function HasJoystickEnhancer()
    return _G['ADDONS']['ebisuke']['joystickenhancer']~=nil
end
local function HasAdvancedNumberDialog()
    return ADVANCEDNUMBERDIALOG_ON_INIT ~= nil
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
            if g.targetctrlpath and ui.GetFrame(g.targetframename):IsVisible()==0 then
                ui.CloseFrame("advancednumberinput_frame")
            end
            -- if (ui.GetFrame("dialogselect"):IsVisible() == 1 and
            --         ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit"):IsVisible() == 1 and
            --         (ui.GetFocusObject()==nil or ui.GetFocusObject():GetName() ~= "numberEdit"))
            -- then
            --     AUTO_CAST(ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit")):Focus()
            -- end

            if GetCurrentCtrl() then
                local framename = g.targetframename
                if(framename == "dialogselect")then
                    if
                        framename == "dialogselect" and ui.GetFrame("dialogselect"):IsVisible() == 1 and
                            (ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit"):IsVisible() == 1)
                    then
                    else
                        ADVANCEDNUMBERINPUT_DETACH()
                    end
                else
                    if ui.GetFrame(framename):IsVisible() == 0 then
                        ADVANCEDNUMBERINPUT_DETACH()
                    end
                end
            elseif g.targetctrlpath then
                ADVANCEDNUMBERINPUT_DETACH()
        
            end

        
            local ctrl=ui.GetFocusObject()
            if(ui.GetFocusFrame()==nil)then
                ctrl=nil
            end;
            if
                (ui.GetFrame("dialogselect"):IsVisible() == 1 and
                    ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit"):IsVisible() == 1)
                    and GetCurrentCtrl()==nil
            then
                ctrl = ui.GetFrame("dialogselect"):GetChildRecursively("numberEdit")
                
            end
            if ctrl==nil then
                return
            end
            ctrl = ADVANCEDNUMBERINPUT_FIND_CTRL(ctrl)
            --end
            if (ctrl == nil) then
                return
            end
            
            if (g.targetctrlpath) then
                if (g.closed==false and GetCurrentCtrl() and GetCurrentCtrl():GetTopParentFrame():GetName() == ctrl:GetTopParentFrame():GetName()) then
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
    if (GetCurrentCtrl() == ctrl) then
        return
    end
    if (g.targetctrlpath) then
        ADVANCEDNUMBERINPUT_DETACH()
        g.targetctrlpath = nil
    end
    if (ui.GetFrame("dialogselect"):IsVisible() == 1  or keyboard.IsKeyPressed("LSHIFT") == 1) then
        g.closed = false
   
    else
        g.closed = true
    end

    if (g.specials[ctrl:GetTopParentFrame():GetName()] ~= nil) then
        if (g.specials[ctrl:GetTopParentFrame():GetName()].mode == "editasnumupdown") then
            g.isnumupdown = "editasnumupdown"
            g.targetctrlpath = GetTargetCtrlPath(ctrl)
        elseif (g.specials[ctrl:GetTopParentFrame():GetName()].mode == "numupdown") then
            g.isnumupdown = "numupdown"
            g.targetctrlpath =  GetTargetCtrlPath(ctrl)
        else
            g.targetctrlpath =  GetTargetCtrlPath(ctrl)
            g.isnumupdown = "edit"
        end
    else
        if (ctrl:GetClassName() == "numupdown") then
            g.isnumupdown = "numupdown"
            g.targetctrlpath = GetTargetCtrlPath(ctrl)
        else
            g.targetctrlpath = GetTargetCtrlPath(ctrl)
            g.isnumupdown = "edit"
        end
    end
    g.targetframename = ctrl:GetTopParentFrame():GetName()
    local frame = ui.GetFrame("advancednumberinput_frame")
    frame:ShowWindow(1)
    ADVANCEDNUMBERINPUT_INITFRAME(frame)

    
end
function ADVANCEDNUMBERINPUT_INITFRAME(frame)
    EBI_try_catch {
        try = function()
            frame = frame or ui.GetFrame("advancednumberinput_frame")
            local ctrl = GetCurrentCtrl()
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
                    p1:SetEventScript(ui.RBUTTONUP, "ADVANCEDNUMBERINPUT_CLOSE")
                    return x + incw, y + inch
                end
                --generic

                local iw, ih = 0, 0
                if (g.isnumupdown == "numupdown" or g.isnumupdown == "editasnumupdown") then
                    local x, y = 8, 8
                    local w, h = 48, 24
                    local incx, incy = 48, 0
               
                    x, y = func(x, y, w , h, incx , incy, "MR", "{ol}{#FFFF00}MR", 1, "ADVANCEDNUMBERINPUT_MC")
                    x, y = func(x, y, w , h, incx , incy, "MS", "{ol}{#00FFFF}MS", 1, "ADVANCEDNUMBERINPUT_MS")
                    x, y = func(x, y, w , h, incx , incy, "BS", "{ol}<-", 1, "ADVANCEDNUMBERINPUT_BACKSPACE")

                    x, y = 8, 8 + 24 + 24 + 24+ 24+ 24
                    x, y = func(x, y, w, h, incx, incy, "p0", "{ol}0", 0)
                    x, y = func(x, y, w, h, incx, incy, "pmp", "{ol}-/+", 0,"ADVANCEDNUMBERINPUT_INV")
                   
                    x, y = func(x, y, w, h, incx, incy, "pAC", "{ol}AC", 0,"ADVANCEDNUMBERINPUT_CLEAR")
                    
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
                    x, y = func(x, y, w , h, incx , incy, "MR", "{ol}{#FFFF00}MR", 1, "ADVANCEDNUMBERINPUT_MC")
                    x, y = func(x, y, w , h, incx , incy, "MS", "{ol}{#00FFFF}MS", 1, "ADVANCEDNUMBERINPUT_MS")
                    x, y = func(x, y, w , h, incx , incy, "BS", "{ol}<-", 1, "ADVANCEDNUMBERINPUT_BACKSPACE")
                    x, y = 8, 8 + 24 + 24 + 24+ 24
                    x, y = func(x, y, w, h, incx, incy, "p0", "{ol}0", 0)
                    x, y = func(x, y, w, h, incx, incy, "pmp", "{ol}-/+", 0,"ADVANCEDNUMBERINPUT_INV")
                   
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
            if(ctrl:GetTopParentFrame():GetName()=='dialogselect')then
                if(HasJoystickEnhancer())then
                    local cursorctrl=ui.GetFrame("advancednumberinput_frame"):GetChildRecursively("p5")
                    SetMousePos_Fixed(cursorctrl:GetGlobalX()+cursorctrl:GetWidth()/2,cursorctrl:GetGlobalY()+cursorctrl:GetHeight()/2)
                end
            end
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
            local frame = GetCurrentCtrl():GetTopParentFrame()
            local ctrl = GetCurrentCtrl()
            if (g.isnumupdown) then
                value = GetCurrentCtrl():GetNumber()
            else
                local text = GetCurrentCtrl():GetText()
                value = tonumber(text)
            end
            if (value == nil) then
                value = 0
            end
            value = tostring(value) .. argstr
            value=tonumber(value)
            ADVANCEDNUMBERINPUT_SETVALUE(ctrl,value)
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end
function ADVANCEDNUMBERINPUT_SETVALUE(ctrl,value)
    EBI_try_catch {
        try = function()

            value=tonumber(value)
            --SPECIALEFFECTS
            local framename = GetCurrentCtrl():GetTopParentFrame():GetName()
            if (g.specials[framename]) then
                local special = g.specials[framename]
                value = special.onprechange(ctrl:GetTopParentFrame(), ctrl, value)
            end

            if (g.isnumupdown == "numupdown") then
                --local min = GetCurrentCtrl():GetMinValue()
                --local max = GetCurrentCtrl():GetMinValue()
                --value = math.min(max, math.max(min, value))
                GetCurrentCtrl():SetNumberValue(value)
            else
                -- local spc = GetCurrentCtrl():GetEventScript("UI_CMD_TEXTCHANGE")
                -- _G[spc]()
                --GetCurrentCtrl():SetText(tostring(value))
                GetCurrentCtrl():SetText(tostring(value))
            end
            if (g.specials[framename]) then
                local special = g.specials[framename]
                special.onpostchange(ctrl:GetTopParentFrame(), ctrl, value)
            end

            local func = GetCurrentCtrl():GetEventScript(ui.PROPERTY_EDIT)
            if (func and _G[func]) then
                local argstr = GetCurrentCtrl():GetEventScriptArgString(ui.PROPERTY_EDIT)
                local argnum = GetCurrentCtrl():GetEventScriptArgNumber(ui.PROPERTY_EDIT)

                pcall(_G[func], GetCurrentCtrl():GetTopParentFrame(), GetCurrentCtrl(), argstr, argnum)
            end
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end
function ADVANCEDNUMBERINPUT_CLEAR(frame, ctrl, argstr, argnum)
      EBI_try_catch {
        try = function()
            local value
            local frame = GetCurrentCtrl():GetTopParentFrame()
            local ctrl = GetCurrentCtrl()
            if (g.isnumupdown) then
                value = GetCurrentCtrl():GetNumber()
            else
                local text = GetCurrentCtrl():GetText()
                value = tonumber(text)
            end
            if (value == nil) then
                value = 0
            end
            value = 0
            ADVANCEDNUMBERINPUT_SETVALUE(ctrl,value)
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end
function ADVANCEDNUMBERINPUT_BACKSPACE(frame, ctrl, argstr, argnum)
    local text=  GetCurrentCtrl():GetText()
    text=text:sub(1,#text-1)
    if(text=="")then
        text="0"
    end

    ADVANCEDNUMBERINPUT_SETVALUE(ctrl,tonumber(text))
end
function ADVANCEDNUMBERINPUT_MR(frame, ctrl, argstr, argnum)
    local memory=g.settings.memory or 0
  

    ADVANCEDNUMBERINPUT_SETVALUE(ctrl,tonumber(memory))
end
function ADVANCEDNUMBERINPUT_MS(frame, ctrl, argstr, argnum)
    local memory
    if (g.isnumupdown == "numupdown") then
        --local min = GetCurrentCtrl():GetMinValue()
        --local max = GetCurrentCtrl():GetMinValue()
        --value = math.min(max, math.max(min, value))
        memory= GetCurrentCtrl():GetNumberValue()
    else
        -- local spc = GetCurrentCtrl():GetEventScript("UI_CMD_TEXTCHANGE")
        -- _G[spc]()
        --GetCurrentCtrl():SetText(tostring(value))
        memory = tonumber(GetCurrentCtrl():GetText()) or 0
    end
    ADVANCEDNUMBERINPUT_SAVE_SETTINGS()
end
function ADVANCEDNUMBERINPUT_DETACH()
    if (g.targetctrlpath) then
        ui.CloseFrame("advancednumberinput_frame")
        g.targetctrlpath =nil

        g.closed = true
        g.targetframename =nil
    end
end
function ADVANCEDNUMBERINPUT_FIND_CTRL(ctrl)
    local framename = ctrl:GetTopParentFrame():GetName()
    if (framename == "inputstring" and HasAdvancedNumberDialog()) then
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
function ADVANCEDNUMBERINPUT_FRAME_CLOSE()

end
function ADVANCEDNUMBERINPUT_CLOSE()
    ui.CloseFrame("advancednumberinput_frame")
    ADVANCEDNUMBERINPUT_DETACH()
    if(ui.GetFrame("dialogselect"):IsVisible()==1)then
        
        control.DialogCancel();

    end
end
function ADVANCEDNUMBERINPUT_SETMIN()
    EBI_try_catch {
        try = function()
            local value
            local frame = GetCurrentCtrl():GetTopParentFrame()
            local ctrl = GetCurrentCtrl()
            if (g.isnumupdown) then
                value = GetCurrentCtrl():GetNumber()
            else
                local text = GetCurrentCtrl():GetText()
                value = tonumber(text)
            end
            if (value == nil) then
                value = 0
            end
            value=tonumber(0)
            ADVANCEDNUMBERINPUT_SETVALUE(ctrl,value)
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end
function ADVANCEDNUMBERINPUT_SETMAX()
    EBI_try_catch {
        try = function()
            local value
            local frame = GetCurrentCtrl():GetTopParentFrame()
            local ctrl = GetCurrentCtrl()
            if (g.isnumupdown) then
                value = GetCurrentCtrl():GetNumber()
            else
                local text = GetCurrentCtrl():GetText()
                value = tonumber(text)
            end
            if (value == nil) then
                value = 999999999
            end
            value=tonumber(999999999)
            ADVANCEDNUMBERINPUT_SETVALUE(ctrl,value)
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end

function ADVANCEDNUMBERINPUT_INV()
    EBI_try_catch {
        try = function()
            local value
            local frame = GetCurrentCtrl():GetTopParentFrame()
            local ctrl = GetCurrentCtrl()
            if (g.isnumupdown) then
                value = GetCurrentCtrl():GetNumber()
            else
                local text = GetCurrentCtrl():GetText()
                value = tonumber(text)
            end
            if (value == nil) then
                value = 0
            end
            value=-tonumber(value)
            --SPECIALEFFECTS
            local framename = GetCurrentCtrl():GetTopParentFrame():GetName()
            if (g.specials[framename]) then
                local special = g.specials[framename]
                value = special.onprechange(frame, ctrl, value)
            end

            if (g.isnumupdown == "numupdown") then
                --local min = GetCurrentCtrl():GetMinValue()
                --local max = GetCurrentCtrl():GetMinValue()
                --value = math.min(max, math.max(min, value))
                GetCurrentCtrl():SetNumberValue(value)
            else
                -- local spc = GetCurrentCtrl():GetEventScript("UI_CMD_TEXTCHANGE")
                -- _G[spc]()
                --GetCurrentCtrl():SetText(tostring(value))
                GetCurrentCtrl():SetText(tostring(value))
            end
            if (g.specials[framename]) then
                local special = g.specials[framename]
                special.onpostchange(frame, ctrl, value)
            end

            local func = GetCurrentCtrl():GetEventScript(ui.PROPERTY_EDIT)
            if (func and _G[func]) then
                local argstr = GetCurrentCtrl():GetEventScriptArgString(ui.PROPERTY_EDIT)
                local argnum = GetCurrentCtrl():GetEventScriptArgNumber(ui.PROPERTY_EDIT)

                pcall(_G[func], GetCurrentCtrl():GetTopParentFrame(), GetCurrentCtrl(), argstr, argnum)
            end
        end,
        catch = function(err)
            ERROUT(err)
        end
    }
end