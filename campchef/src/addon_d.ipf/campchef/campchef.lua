--アドオン名（大文字）
local addonName = "campchef"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings={foods={}}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "campchef"
g.debug = false
g.handle=nil
g.interlocked=false
g.currentIndex=1
--ライブラリ読み込み
CHAT_SYSTEM("[CC]loaded")
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




local translationtable = {
    chef={jp="Chef",eng="Chef"},
    craft={jp="Chef作成",eng="Craft"},
    numberofcraft={jp="作成数",eng="To Craft"},
    numberofreserve={jp="補充数",eng="To Reserve"},
    chefbuy={jp="Chef購入",eng="Chef's Buy"},
    dialogtocraft={jp="一括調理します。\r\nよろしいですか？",eng="Will cook designated foods.\r\nProceed?"},
    needmoreingredients={jp="材料が不足しています。",eng="Need more ingredients."},
    openkitchen={jp="キッチンを開いてください.",eng="Open a kitchen window."},
    complete={jp="調理終了",eng="Complete."}
    --Tsettingsupdt12 = {jp="[AIM]共通設定のバージョンを更新しました 1->2",  eng="[AIM]Team settings updated 1->2"},
    }

local function L_(str)

    if (option.GetCurrentCountry() == "Japanese") then
        if(translationtable[str]~=nil)then
            return translationtable[str].jp
        end
    end
    if(translationtable[str]~=nil)then
        return translationtable[str].eng
    end
    return str
end

function CAMPCHEF_DBGOUT(msg)
    
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
function CAMPCHEF_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function CAMPCHEF_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function CAMPCHEF_SAVE_ALL()
    CAMPCHEF_SAVETOSTRUCTURE()
    CAMPCHEF_SAVE_SETTINGS()
    ui.MsgBox("保存しました")
end
function CAMPCHEF_SAVETOSTRUCTURE()
    local frame=ui.GetFrame("campchef")
    local clslist, cnt  = GetClassList("FoodTable");
    g.settings.foods={}
    for i=1,cnt do
        
        local txtrequires=frame:GetChild("txtrequires"..tostring(i))
        local txtreserve=frame:GetChild("txtreserve"..tostring(i))
        local cls = GetClassByIndexFromList(clslist, i-1);
        tolua.cast(txtrequires, "ui::CNumUpDown");
        tolua.cast(txtreserve, "ui::CNumUpDown");
        g.settings.foods[i]={
            clsid=cls.ClassID,
            requires=txtrequires:GetNumber(),
            reserve=txtreserve:GetNumber(),
        }

    end
end

function CAMPCHEF_LOAD_SETTINGS()
    CAMPCHEF_DBGOUT("LOAD_SETTING")
    g.settings = {foods={}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        CAMPCHEF_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {foods={}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
            g.settings.foods={}
        end
    end
    
    CAMPCHEF_UPGRADE_SETTINGS()
    CAMPCHEF_SAVE_SETTINGS()
    CAMPCHEF_LOADFROMSTRUCTURE()
end

function CAMPCHEF_LOADFROMSTRUCTURE()
    local frame=ui.GetFrame("campchef")
    local clslist, cnt  = GetClassList("FoodTable");
    for i=1,cnt do
        
        local txtrequires=frame:GetChild("txtrequires"..tostring(i))
        local txtreserve=frame:GetChild("txtreserve"..tostring(i))
        local cls = GetClassByIndexFromList(clslist, i-1);
        tolua.cast(txtrequires, "ui::CNumUpDown");
        tolua.cast(txtreserve, "ui::CNumUpDown");
        if(g.settings.foods[i]~=nil)then
            txtrequires:SetNumberValue(g.settings.foods[i].requires)
            txtreserve:SetNumberValue(g.settings.foods[i].reserve)
            CAMPCHEF_DBGOUT(tostring(g.settings.foods[i].reserve))
        else
            txtrequires:SetNumberValue(0)
            txtreserve:SetNumberValue(0)
        end
    end
end

function CAMPCHEF_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end


--マップ読み込み時処理（1度だけ）
function CAMPCHEF_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            frame:ShowWindow(0)
            acutil.slashCommand("/cc", CAMPCHEF_PROCESS_COMMAND);
            addon:RegisterMsg("OPEN_FOOD_TABLE_UI", "CAMPCHEF_ON_OPEN_FOOD_TABLE_UI");
            addon:RegisterMsg('SHOP_ITEM_LIST_GET', 'CAMPCHEF_SHOP_ITEM_LIST_GET');

            ON_FOOD_ADD_SUCCESS=CAMPCHEF_ON_FOOD_ADD_SUCCESS
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            
            frame:ShowWindow(0)
            CAMPCHEF_INITFRAME(frame)
            CAMPCHEF_LOAD_SETTINGS()
        end,
        catch = function(error)
            CAMPCHEF_ERROUT(error)
        end
    }
end
function CAMPCHEF_ON_OPEN_FOOD_TABLE_UI(frame, msg, handle, forceOpenUI)
    local campframe=ui.GetFrame("foodtable_ui")
    local btnchef=campframe:CreateOrGetControl("button","btnsetting",50,20,100,40)
    btnchef:SetText(L_("chef"))
    btnchef:SetEventScript(ui.LBUTTONDOWN,"CAMPCHEF_TOGGLE_FRAME")
    g.handle=handle
    CAMPCHEF_DBGOUT("OPEN")
end
function CAMPCHEF_INITFRAME(frame)
    EBI_try_catch{
        try=function()

           
            CAMPCHEF_INITFOODFRAME(frame)
        end,
        catch=function(exp)
            CAMPCHEF_ERROUT(exp)
        end
    }

end
function CAMPCHEF_REFRESHFRAME(frame)
    frame:RemoveAllChild()
    CAMPCHEF_INITFRAME(frame)

    g.interlocked=false
end

function CAMPCHEF_INITFOODFRAME(frame)
    
    local tableInfo = session.camp.GetCurrentTableInfo();
    frame:Resize(480,320)
    if(tableInfo~=nil)then
        local clslist, cnt  = GetClassList("FoodTable");
        -- 作成可能なフードを列挙
        for i=1,cnt do
            local labelTitle=frame:CreateOrGetControl("richtext","labelheader",80,10,300,30)
            local btnToggle=frame:CreateOrGetControl("button","buttonClose",480-40,0,40,40)
            btnToggle:SetText("X")
            btnToggle:SetEventScript(ui.LBUTTONUP,"CAMPCHEF_TOGGLE_FRAME")
            labelTitle:SetText("CampChef")
            labelTitle:SetFontName("white_24_ol")
            local btncraft=frame:CreateOrGetControl("button","btncraft",50,50,100,30)
            btncraft:SetText(L_("craft"))
            btncraft:SetEventScript(ui.LBUTTONDOWN,"CAMPCHEF_DIALOG_TOCRAFT")
 
            if(g.debug)then
                local btnrefresh=frame:CreateOrGetControl("button","btnrefresh",200,50,100,30)
                btnrefresh:SetText(L_("refresh"))
                btnrefresh:SetEventScript(ui.LBUTTONDOWN,"CAMPCHEF_REFRESHFRAME")
            end
            local btnsave=frame:CreateOrGetControl("button","btnsave",350,50,100,30)
            btnsave:SetText(L_("save"))
            btnsave:SetEventScript(ui.LBUTTONDOWN,"CAMPCHEF_SAVE_ALL")
            CAMPCHEF_DBGOUT("CLASS"..tostring(i))
            local label
            label=frame:CreateOrGetControl("richtext","label1",200,90,90,30)
            label:SetText(L_"numberofcraft")
            label:SetFontName("white_20_ol");
            label=frame:CreateOrGetControl("richtext","label2",360,90,90,30)
            label:SetText(L_"numberofreserve")
            label:SetFontName("white_20_ol");
            local labelfood=frame:CreateOrGetControl("richtext","labelfood"..tostring(i),20,90+i*30,100,30)
            local cls = GetClassByIndexFromList(clslist, i-1);
            labelfood:SetText(cls.Name)
            labelfood:SetFontName("white_20_ol");
            local txtrequires=frame:CreateOrGetControl("numupdown","txtrequires"..tostring(i),180,90+i*30,100,30)
            tolua.cast(txtrequires, "ui::CNumUpDown");
            txtrequires:SetFontName("white_20_ol");
           
            txtrequires:MakeButtons("btn_numdown", "btn_numup", "editbox_s");
            local txtreserve=frame:CreateOrGetControl("numupdown","txtreserve"..tostring(i),340,90+i*30,100,30)
            tolua.cast(txtreserve, "ui::CNumUpDown");
            txtreserve:SetFontName("white_20_ol");
            txtreserve:ShowWindow(1);
            txtreserve:MakeButtons("btn_numdown", "btn_numup", "editbox_s");
        end
    end
  
end
function CAMPCHEF_DIALOG_TOCRAFT()
    EBI_try_catch{
        try = function()
        if(ui.GetFrame("foodtable_ui"):IsVisible()==0)then
            ui.MsgBox(L_("openkitchen"))
            return
        end
        CAMPCHEF_DBGOUT("HREE")
        local needs=CAMPCHEF_CALCULATEINGREDIENTS(false)
        --食材は十分あるか調べる
        local issatisfied=true;

        for k,d in pairs(needs) do
            if(d>0)then
                --不足
                issatisfied=false
                break
            end
        end
        if(issatisfied==false)then
            local message=L_("needmoreingredients")
            for k,d in pairs(needs) do
                if(d>0)then
                    --不足
                    local invcls = GetClassByType('Item',k)
                    
                    message=message.."\r\n"..dictionary.ReplaceDicIDInCompStr(invcls.Name).." x "..tostring(d)

                end
            end
            ui.MsgBox(message);
        else
            ui.MsgBox(L_("dialogtocraft"), "CAMPCHEF_CRAFT", "None");
        end
    end,
    catch = function(error)
        CAMPCHEF_ERROUT(error)
    end
    }
end
function CAMPCHEF_CRAFT()
    -- if(g.interlocked==true)then
    --     ui.MsgBox(L_("interlocked"))
    --     return
    -- end
    g.interlocked=true;

    g.currentIndex=1;

    CAMPCHEF_COOKING()

end

function CAMPCHEF_COOKING()
    CAMPCHEF_DBGOUT("CALL")
    EBI_try_catch{
        try=function()
            local clslist, cnt  = GetClassList("FoodTable");
            -- 作成可能なフードを列挙
            if(cnt<g.currentIndex)then
                g.interlocked=false;
                CAMPCHEF_DBGOUT("end")
                ui.MsgBox(L_("complete"))
                return
            end
            
            i=g.currentIndex
            g.currentIndex=g.currentIndex+1
            --作成済みの数を調べる
            local tableInfo = session.camp.GetCurrentTableInfo();
            local foodItem = tableInfo:GetFoodItem(i-1);
            local remain=0
            if(foodItem~=nil)then
                remain=foodItem.remainCount
            end
            local cnt=g.settings.foods[i].requires-remain
            if(cnt>0)then
                --順番に作ってく
                local cls = GetClassByIndexFromList(clslist, i-1);
                
                CAMPCHEF_DBGOUT("COOKING")
                control.CustomCommand("MAKE_FOODTABLE_FOOD", cls.ClassID,cnt, g.handle);
            else
                CAMPCHEF_DBGOUT("NO COOKING")
                --作る必要がなければ次
                CAMPCHEF_COOKING()
            end
        end,
        catch=function(exp)
            CAMPCHEF_ERROUT(exp)
        end
    }

end
function CAMPCHEF_TOGGLE_FRAME(frame)
    ui.ToggleFrame("campchef")
end

function CAMPCHEF_NEXT(frame)
    EBI_try_catch{
        try=function()
            CAMPCHEF_DBGOUT("SUCC")
            CAMPCHEF_COOKING()
        end,
        catch=function(exp)
            CAMPCHEF_ERROUT(exp)
        end
    }
end
function  CAMPCHEF_ON_FOOD_ADD_SUCCESS(frame)
    if(g.interlocked)then
        CAMPCHEF_NEXT(frame)
    end
	--ui.SysMsg(ClMsg("MakingFoodIsCompleted"));
end

function CAMPCHEF_DOBUYOUT(frame)
    CAMPCHEF_DBGOUT("BUYING")
    
    --実際に買う
    EBI_try_catch{
        try=function()
            local cart=CAMPCHEF_CALCULATEINGREDIENTS(true)
            local shopItemList = session.GetShopItemList()
            local shopItemCount = shopItemList:Count();
            for i=0,shopItemCount-1 do
                local obj=shopItemList:PtrAt(i)
                CAMPCHEF_DBGOUT(tostring(obj.classID))
                local cnt=cart[CAMPCHEF_CONVERT_SHOPCLSID_TO_GENERICCLSID(obj.classID)]
                if(cnt~=nil and cnt>0)then
                    --購入
                    SHOP_BUY(obj.classID,cnt,ui.GetFrame("shop"))
                    SHOP_UPDATE_BUY_PRICE(frame);
                end
            end

    end,
    catch=function(exp)
        CAMPCHEF_ERROUT(exp)
    end
    }
end

function CAMPCHEF_CALCULATEINGREDIENTS(isreserve)
    --材料の必要数を数える
    local cart={}
    local clslist, cnt  = GetClassList("FoodTable");
    for i = 0 , cnt - 1 do
        local cls = GetClassByIndexFromList(clslist, i);
        
        local list = StringSplit(cls.Material, "/");
        for j = 1,  #list / 2 do
            local itemName = list[2 * j - 1];
            local itemCount = list[2 * j];
            local itemCls = GetClass("Item", itemName);
            CAMPCHEF_DBGOUT(cls.Material)
            if(itemCls~=nil)then
                if(cart[itemCls.ClassID]==nil)then
                    cart[itemCls.ClassID]=0
                end
                if(isreserve==false)then
                    cart[itemCls.ClassID]=cart[itemCls.ClassID]+itemCount*g.settings.foods[i+1].requires
                else
                    cart[itemCls.ClassID]=cart[itemCls.ClassID]+itemCount*g.settings.foods[i+1].reserve
                end
            end
        end
    end
    session.ResetItemList()
    local invList = session.GetInvItemList()
    FOR_EACH_INVENTORY(
        invList,
        function(invList, invItem, item)
            EBI_try_catch {
                try = function()
                    local itemObj = GetIES(invItem:GetObject())
                    CAMPCHEF_DBGOUT("AA")
                    if(cart[itemObj.ClassID]~=nil)then
                        --所持数分引く
                        CAMPCHEF_DBGOUT("HAVING")
                        cart[itemObj.ClassID]=cart[itemObj.ClassID]-invItem.count
                    end
                end,
                catch = function(error)
                    CAMPCHEF_ERROUT(error)
                end
            }
        end,
        false,
        item
    )

    return cart

end

function CAMPCHEF_SHOP_ITEM_LIST_GET()
    CAMPCHEF_DBGOUT("LIST GET")
    frame=ui.GetFrame("shop")
    EBI_try_catch{
        try=function()
        local shopItemList = session.GetShopItemList()
        local squireshop=false
        --ネギが売っているか調べる
        local shopItemCount = shopItemList:Count();
        for i=0,shopItemCount-1 do
            local obj=shopItemList:PtrAt(i)
            CAMPCHEF_DBGOUT(tostring(obj.classID))
            if(CAMPCHEF_CONVERT_SHOPCLSID_TO_GENERICCLSID(obj.classID)== 640253)then
                squireshop=true
                break
            end
        end
        if(squireshop==false)then
            frame:RemoveChild("btnallbuy")
            frame:RemoveChild("btnchef")
            CAMPCHEF_DBGOUT("bye")
            return
        end
        CAMPCHEF_DBGOUT("PASS")
        --設定ウインドウを一括購買を作成
        local btnallbuy=frame:CreateOrGetControl("button","btnallbuy",30,60,100,30)
        btnallbuy:SetText(L_("chefbuy"))
        btnallbuy:SetEventScript(ui.LBUTTONDOWN,"CAMPCHEF_DOBUYOUT")
        local btnchef=frame:CreateOrGetControl("button","btnchef",170,60,100,30)
        btnchef:SetText(L_("chef"))
        btnchef:SetEventScript(ui.LBUTTONDOWN,"CAMPCHEF_TOGGLE_FRAME")
    end,
    catch=function(exp)
        CAMPCHEF_ERROUT(exp)
    end
    }
end

function CAMPCHEF_CONVERT_SHOPCLSID_TO_GENERICCLSID(clsid)
    local class=GetClassByType("Shop",clsid)
    CAMPCHEF_DBGOUT( class.ItemName)
    local itemCls = GetClass('Item',  class.ItemName);
    return itemCls.ClassID
end