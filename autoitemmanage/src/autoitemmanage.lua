--アドオン名（大文字）
local addonName = "autoitemmanage"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

--設定ファイル保存先
--nil=ALPHA1
--1=ALPHA1-2
--2=ALPHA3,0.0.1,ALPHA4,0.0.2
--3=ALPHA5,0.0.3,0.0.4,0.0.5
g.version=3
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc=""
g.editindex = 0
g.framename="autoitemmanage"
g.debug=false
g.slotsize={48,48}
g.logpath=string.format('../addons/%s/log.txt', addonNameLower)
g.isediting=false
g.editkeydown=false

--ライブラリ読み込み
CHAT_SYSTEM("[AIM]loaded")
local acutil  = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val=="nil"
end

local translationtable={

	Tsettingsupdt12 = {jp="[AIM]共通設定のバージョンを更新しました 1->2",  eng="[AIM]Team settings updated 1->2"},
    Tsettingsupdt23 = {jp="[AIM]共通設定のバージョンを更新しました 2->3",  eng="[AIM]Team settings updated 2->3"},
	Csettingsupdt12 = {jp="[AIM]個人設定のバージョンを更新しました 1->2",  eng="[AIM]Character settings updated 1->2"},
	Csettingsupdt23 = {jp="[AIM]個人設定のバージョンを更新しました 2->3",  eng="[AIM]Character settings updated 2->3"},
	Configbtn = {jp="{ol}AIM設定",  eng="{ol}AIM Config"},
	TempDWarn= {jp="[AIM]現在自動補充を一時停止しています",  eng="[AIM] is temporarily disabled."},
	Tsmsg = {jp="[AIM]チーム倉庫からアイテムを引き出します",  eng="[AIM]Retrieved items from Team storage."},
	Psmsg = {jp="[AIM]個人倉庫からアイテムを引き出します",  eng="[AIM]Retrieved items from Personal storage."},
	Copybtn = {jp="チーム設定コピー",  eng="{s14}Copy Team settings"},
	Disablecheck = {jp="{ol}{#FF0000}自動補充を一時的に無効化",  eng="{ol}{#FF0000}Disable AIM"},
	Enablecheck = {jp="{ol}このキャラで使用する",  eng="{ol}Use on this char"},
	Charcheck = {jp="{ol}個人設定を使用する(解除で共通設定)",  eng="{ol}Settings for this char only"},
	Tscheck = {jp="{ol}チーム倉庫",  eng="{ol}Team storage"},
	Pscheck = {jp="{ol}個人倉庫",  eng="{ol}Personal storage"},
	CopyWarn = {jp="{ol}アイテム設定をチーム設定からコピーします。{nl}既存の個人アイテム設定は上書きされ削除されます。{nl}よろしいですか？",  eng="{ol}Copy Team settings. {nl}Character settings will be overwritten! Proceed?"},
	Copymsg = {jp="[AIM]個人設定をチーム設定からコピーしました",  eng="[AIM]Team settings copied."},
	DropWarn = {jp="[AIM]数量の編集中はドロップできません",  eng="[AIM]Cant drop while editing quantity"},
	RegiWarn = {jp="それは登録できません",  eng="Cant register it"},
	ClassidWarn = {jp="このアイテムをGUIDで管理しますか？{nl}いいえを押すとClassIDで管理します。{nl}期間のあるアイテムをGUIDで指定すると、{nl}見かけ上期間満了になることがあります",  eng="Do you want to manage this item by GUID? {nl} Press No to manage with ClassID."},
	Usagemsg = {jp="usage{nl}/aim on 自動補充の一時停止を解除{nl}/aim off 自動補充の一時停止",  eng="Usage:{nl}/aim on -> enable AIM{nl}/aim off -> disable AIM"},
	Enablemsg = {jp="[AIM]自動補充の一時停止を解除しました",  eng="[AIM]Enabled"},
	Disablemsg = {jp="[AIM]自動補充を一時停止しました",  eng="[AIM]Disabled"},
	
}

local function L_(str)
    if(option.GetCurrentCountry()=="Japanese")then
        return translationtable[str].jp
    else
        return translationtable[str].eng
    end
end

function AUTOITEMMANAGE_DEFAULTSETTINGS()
    return {
        version=g.version,
        --有効/無効
        enable = false,
        --フレーム表示場所
        position = {
            x = 736,
            y = 171
        },
        itemmanage={
            refills = {},
            refillenableaccountwarehouse=0,
            refillenablewarehouse=0,
            
        },
        itemmanagetempdisabled=false
    }
end
function AUTOITEMMANAGE_DEFAULTPERSONALSETTINGS()
    return {
        version=g.version,

        refills = {},
        refillenableaccountwarehouse=0,
        refillenablewarehouse=0,
        
        enabled=false,
        unusecommon=false,
    }
end
--デフォルト設定
if(not g.loaded)then
    --シンタックス用に残す
    g.settings = {
        version,
        --有効/無効
        enable = false,
        --フレーム表示場所
        position = {
            x = 0,
            y = 0
        },
        itemmanage={
            refills = {},
            refillenableaccountwarehouse=0,
            refillenablewarehouse=0,
            enabled={}
        },
        itemmanagetempdisabled=false
    }
    g.personalsettings= {
        version=nil,
        refills = {},
        refillenableaccountwarehouse=0,
        refillenablewarehouse=0
    }
    g.settings =AUTOITEMMANAGE_DEFAULTSETTINGS()
    g.personalsettings =AUTOITEMMANAGE_DEFAULTPERSONALSETTINGS()
end

function AUTOITEMMANAGE_DBGOUT(msg)
    
    EBI_try_catch{
        try=function()
            if(g.debug==true)then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd=io.open (g.logpath,"a")
                fd:write(msg.."\n")
                fd:flush()
                fd:close()
                
            end
        end,
        catch=function(error)
        end
    }

end
function AUTOITEMMANAGE_ERROUT(msg)
    EBI_try_catch{
        try=function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch=function(error)
        end
    }

end
function AUTOITEMMANAGE_SAVE_SETTINGS()
    AUTOITEMMANAGE_DBGOUT("SAVE_SETTINGS")
    AUTOITEMMANAGE_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(AUTOITEMMANAGE_GETCID()))
    AUTOITEMMANAGE_DBGOUT("psn"..g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end

function AUTOITEMMANAGE_LOAD_SETTINGS()
    AUTOITEMMANAGE_DBGOUT("LOAD_SETTINGS "..tostring(AUTOITEMMANAGE_GETCID()))
    g.settings={}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        AUTOITEMMANAGE_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings =  AUTOITEMMANAGE_DEFAULTSETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if(not g.settings.version)then
            g.settings.version=AUTOITEMMANAGE_DEFAULTSETTINGS().version
        end
    end
    AUTOITEMMANAGE_DBGOUT("LOAD_PSETTINGS "..g.personalsettingsFileLoc)
    g.personalsettings={}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        AUTOITEMMANAGE_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.personalsettings= AUTOITEMMANAGE_DEFAULTPERSONALSETTINGS()
        
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if(not g.personalsettings.version)then
            g.personalsettings.version=AUTOITEMMANAGE_DEFAULTPERSONALSETTINGS().version
        end
    end
    local upc=AUTOITEMMANAGE_UPGRADE_SETTINGS()
    local upp=AUTOITEMMANAGE_UPGRADE_PERSONALSETTINGS()
    -- ショートサーキット評価を回避するため、いったん変数に入れる
    if upc or upp then
        AUTOITEMMANAGE_SAVE_SETTINGS()
    end
end
function AUTOITEMMANAGE_UPGRADE_SETTINGS()
    local upgraded=false
    --1->2
    if(g.settings.version==nil or g.settings.version==1)then
        CHAT_SYSTEM(L_("Tsettingsupdt12"))

        g.settings.version=2
        upgraded=true
    end
     --1->2
     if(g.settings.version==2)then
        CHAT_SYSTEM(L_("Tsettingsupdt23"))
        g.settings.itemmanagetempdisabled=false
        g.settings.version=3
        upgraded=true
    end
    return upgraded
end
function AUTOITEMMANAGE_UPGRADE_PERSONALSETTINGS()
    local upgraded=false
    --1->2
    if(g.personalsettings.version==nil or g.personalsettings.version==1)then
        CHAT_SYSTEM(L_("Csettingsupdt12"))
        g.personalsettings.enabled=true

        g.personalsettings.unusecommon=g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()] or false
        g.personalsettings.version=2
        upgraded=true
    end  
    if(g.personalsettings.version==2)then
        CHAT_SYSTEM(L_("Csettingsupdt23"))
        g.personalsettings.enabled=true
        g.personalsettings.version=3
        upgraded=true
    end
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function AUTOITEMMANAGE_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(AUTOITEMMANAGE_GETCID()))
            frame:ShowWindow(0)
            acutil.slashCommand("/aim", AUTOITEMMANAGE_PROCESS_COMMAND);

            --ccするたびに設定を読み込む

            if not g.loaded then
               
                g.loaded = true
            end
            --acutil.addSysIcon(g.framename, 'sysmenu_sys', g.framename, 'AUTOITEMMANAGE_TOGGLE_FRAME')
            --設定ファイル保存処理
            --AUTOITEMMANAGE_SAVE_SETTINGS()
            --メッセージ受信登録処理
            --addon:RegisterMsg("メッセージ", "内部処理");
            --addon:RegisterMsg("MARKET_ITEM_LIST", "AUTOITEMMANAGE_MARKET_ITEMLIST");
            addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'AUTOITEMMANAGE_ON_OPEN_ACCOUNT_WAREHOUSE')
            addon:RegisterMsg('OPEN_DLG_WAREHOUSE', 'AUTOITEMMANAGE_ON_OPEN_WAREHOUSE')
            addon:RegisterMsg('OPEN_CAMP_UI', 'AUTOITEMMANAGE_ON_OPEN_CAMP_UI')
            addon:RegisterMsg('GAME_START_3SEC', 'AUTOITEMMANAGE_RESERVE_INIT')
            addon:RegisterMsg('TARGET_SET', 'AUTOITEMMANAGE_UPDATETARGET');
            addon:RegisterMsg('TARGET_CLEAR', 'AUTOITEMMANAGE_UPDATETARGET');
            addon:RegisterMsg('TARGET_UPDATE', 'AUTOITEMMANAGE_UPDATETARGET');
            --コンテキストメニュー
            --frame:SetEventScript(ui.RBUTTONDOWN, 'AUTOITEMMANAGE_CONTEXT_MENU')
            --ドラッグ
    
            
            --ASM連携
            --if (OLD_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE == nil and AUTOSAVEMONEY_ITEM_TO_WAREHOUSE ~= nil) then
            --    AUTOITEMMANAGE_DBGOUT('[AIM]ASMを検知しました')
            --    g.foundasm = true
            --    OLD_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE = AUTOSAVEMONEY_ITEM_TO_WAREHOUSE
            --    AUTOSAVEMONEY_ITEM_TO_WAREHOUSE = AUTOITEMMANAGE_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE_JUMPER
            --end

            --フレーム初期化処理

            --Moveではうまくいかないので、OffSetを使用する…

            frame:ShowWindow(0)
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }
end

function AUTOITEMMANAGE_UPDATETARGET(frame, msg, argStr, argNum)

    local target = session.GetTargetHandle()
    local entitycls=GetClass("Monster", info.GetMonsterClassName(handle));
end
function AUTOITEMMANAGE_RESERVE_INIT(frame)
    EBI_try_catch{
        try=function()
            AUTOITEMMANAGE_LOAD_SETTINGS()
            
            frame:Move(0, 0)
            frame:SetOffset(g.settings.position.x, g.settings.position.y)
            
 
        end,
        catch=function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }

    
    

end
function  AUTOITEMMANAGE_ON_OPEN_CAMP_UI()
        --if (not g.foundasm) then
    --ボタン登録
    EBI_try_catch{
        try=function()
            ReserveScript("AUTOITEMMANAGE_DELAYED_INIT_FRAME()",1)
            local frame=ui.GetFrame(g.framename)
            AUTOITEMMANAGE_INIT_FRAME(frame)
            AUTOITEMMANAGE_DBGOUT('OPEN WAREHOUSE1')

            local frame=ui.GetFrame("camp_ui")
            local btn=frame:CreateOrGetControl('button', 'showconfig', 240, 590, 110, 30)
            btn:SetText(L_("Configbtn"))
            btn:SetEventScript(ui.LBUTTONDOWN,"AUTOITEMMANAGE_TOGGLE_FRAME")
  
            ReserveScript("AUTOITEMMANAGE_WITHDRAW_FROM_WAREHOUSE()",0.5)
        end,
        catch=function(error)
            AUTOITEMMANAGE_ERROUT(error)       
        end
    }

    --end
end
function AUTOITEMMANAGE_ON_OPEN_ACCOUNT_WAREHOUSE()
    --if (not g.foundasm) then
    EBI_try_catch{
        try=function()
            ReserveScript("AUTOITEMMANAGE_DELAYED_INIT_FRAME()",1)
            AUTOITEMMANAGE_DBGOUT('OPEN WAREHOUSE1')

            local frame=ui.GetFrame("accountwarehouse")
            local btn=frame:CreateOrGetControl('button', 'showconfig', 400, 80, 100, 30)
            btn:SetText(L_("Configbtn"))
            btn:SetEventScript(ui.LBUTTONDOWN,"AUTOITEMMANAGE_TOGGLE_FRAME")
            ReserveScript("AUTOITEMMANAGE_WITHDRAW_FROM_WAREHOUSE()",0.5)
    end,
    catch=function(error)
        AUTOITEMMANAGE_ERROUT(error)       
    end
    }
    --end
end
function AUTOITEMMANAGE_ON_OPEN_WAREHOUSE()
    --if (not g.foundasm) then
    --ボタン登録
    EBI_try_catch{
        try=function()
            ReserveScript("AUTOITEMMANAGE_DELAYED_INIT_FRAME()",1)
            local frame=ui.GetFrame(g.framename)
            AUTOITEMMANAGE_INIT_FRAME(frame)
            AUTOITEMMANAGE_DBGOUT('OPEN WAREHOUSE1')

            local frame=ui.GetFrame("warehouse")
            local btn=frame:CreateOrGetControl('button', 'showconfig', 380, 80, 110, 30)
            btn:SetText(L_("Configbtn"))
            btn:SetEventScript(ui.LBUTTONDOWN,"AUTOITEMMANAGE_TOGGLE_FRAME")
  
            ReserveScript("AUTOITEMMANAGE_WITHDRAW_FROM_WAREHOUSE()",0.5)
        end,
        catch=function(error)
            AUTOITEMMANAGE_ERROUT(error)       
        end
    }

    --end
end

function AUTOITEMMANAGE_DELAYED_INIT_FRAME()
    local frame=ui.GetFrame(g.framename)
    AUTOITEMMANAGE_INIT_FRAME(frame)
end

function AUTOITEMMANAGE_WITHDRAW_FROM_WAREHOUSE()
    EBI_try_catch {
        try = function()
            AUTOITEMMANAGE_DBGOUT('OPEN WAREHOUSE_2')

            local cid = session.GetMySession():GetCID()
            local refer=AUTOITEMMANAGE_GETITEMSETTINGS()
            local sett=AUTOITEMMANAGE_GETSETTINGS()
            local accountmode=false
            local campmode=false
            if(AUTOITEMMANAGE_ISENABLED()==0)then
                AUTOITEMMANAGE_DBGOUT('byebye')
                return
            end
            
            local frame= ui.GetFrame('accountwarehouse')
            if(frame:IsVisible()==1)then
                --アカウント倉庫モード
                accountmode=true
                if(sett.refillenableaccountwarehouse==nil or sett.refillenableaccountwarehouse==0)then
                    AUTOITEMMANAGE_DBGOUT('bye')
                    return
                end                
            else
                accountmode=false
                if(ui.GetFrame("camp_ui"):IsVisible()==1)then
                    frame= ui.GetFrame('camp_ui')
                    campmode=true
                else
                    frame= ui.GetFrame('warehouse')
                end
                if(sett.refillenablewarehouse==nil or sett.refillenablewarehouse==0)then
                    AUTOITEMMANAGE_DBGOUT('bye')
                    return
                end       
            end
            local counthp = 0
           
            local withdrawlist = {}

            if (refer ~= nil) then
                for i = 1, #refer do
                    local vv = refer[i]
                   
                    if (vv ~= nil and vv.clsid ~= nil) then
                        AUTOITEMMANAGE_DBGOUT("bT"..tostring(vv.clsid))
                        withdrawlist[#withdrawlist+1] = {
                            clsid = vv.clsid,
                            count = vv.count,
                            having = 0,
                            iesid=vv.iesid
                        }
                        session.ResetItemList()
                        local invList = session.GetInvItemList()
                        FOR_EACH_INVENTORY(
                            invList,
                            function(invList, invItem, item)
                                EBI_try_catch {
                                    try = function()
                                        local itemObj = GetIES(invItem:GetObject())
                                        -- 含まれるかチェック

                                        --AUTOITEMMANAGE_DBGOUT("bT"..tostring(vv.clsid))

                                        --AUTOITEMMANAGE_DBGOUT(itemObj.ClassID)
                                        if itemObj.ClassID ~= nil and tonumber(itemObj.ClassID) == vv.clsid then
                                            --それはバンドル可能？
                                            if(itemObj.MaxStack <=1)then
                                                if not EBI_IsNoneOrNil(vv.iesid)then
                                                    --iesidで
                                                    if(invItem:GetIESID()==vv.iesid)then
                                                        AUTOITEMMANAGE_DBGOUT('DT'..tostring(vv.clsid))
                                                        withdrawlist[#withdrawlist].having=1
                                                    end
                                                else
                                                    AUTOITEMMANAGE_DBGOUT('YOUHAVE'..tostring(vv.clsid))
                                                      --全部引き出したいため計数を無効化
                                                    --    withdrawlist[#withdrawlist].having=1
                                                end
                                            else
                                                AUTOITEMMANAGE_DBGOUT('DT'..tostring(vv.clsid))
                                                withdrawlist[#withdrawlist].having=invItem.count
                                            end
                                            
                                        end
                                    end,
                                    catch = function(error)
                                        AUTOITEMMANAGE_ERROUT(error)
                                    end
                                }
                            end,
                            false,
                            item
                        )
                    end
                end
                AUTOITEMMANAGE_DBGOUT('NOW' .. tostring(#withdrawlist))
                local slotset = GET_CHILD_RECURSIVELY(frame, 'slotset')
                AUTO_CAST(slotset)
                local withdrawcounthp = 0
                session.ResetItemList()
                local count = 0
                local takeitems={}
                for i,wd in ipairs(withdrawlist) do
                    
                    
                   
                    for j = 0, slotset:GetSlotCount() - 1 do
                        local slot = slotset:GetSlotByIndex(j)
                        if (slot ~= nil) then
                            local Icon = slot:GetIcon()

                            if (Icon ~= nil) then

                                local iconInfo = Icon:GetInfo()
                                local invItem 
                                if(accountmode)then
                                    invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID())
                                else
                                    invItem = session.GetEtcItemByGuid(IT_WAREHOUSE, iconInfo:GetIESID())
                                end
                                local obj = GetIES(invItem:GetObject())
                                --それはバンドル可能？
                                if(obj.MaxStack<=1 and not EBI_IsNoneOrNil(wd.iesid) )then
                                    if (iconInfo:GetIESID() == wd.iesid) then
                                        local withdrawcounthp = 1
                                        
                                        AUTOITEMMANAGE_DBGOUT(tostring(wd.clsid) .. ':' .. tostring(withdrawcounthp))
                                        session.AddItemID(iconInfo:GetIESID(), withdrawcounthp)
                                        takeitems[#takeitems+1]={iesid=iconInfo:GetIESID(),count=withdrawcounthp}
                                        count = count + 1
                                        AUTOITEMMANAGE_DBGOUT('ADDB'..tostring(wd.clsid)..":"..tostring(withdrawcounthp))
                                        
                                    end
                                else

                                    if (obj.ClassID == wd.clsid) then
                                        local withdrawcounthp = wd.count - wd.having
                                        if (withdrawcounthp > invItem.count) then
                                            withdrawcounthp = invItem.count
                                        end
                                        if (withdrawcounthp > 0) then
                                            AUTOITEMMANAGE_DBGOUT(tostring(wd.clsid) .. ':' .. tostring(withdrawcounthp))
                                            session.AddItemID(iconInfo:GetIESID(), withdrawcounthp)
                                            takeitems[#takeitems+1]={iesid=iconInfo:GetIESID(),count=withdrawcounthp}
                                            count = count + 1
                                            AUTOITEMMANAGE_DBGOUT('ADD'..tostring(wd.clsid)..":"..tostring(withdrawcounthp))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if (count > 0) then
                    if(g.settings.itemmanagetempdisabled)then
                        ui.SysMsg(L_("TempDWarn"))
                    else
                        if(accountmode)then
                            CHAT_SYSTEM(L_("Tsmsg"))
                            item.TakeItemFromWarehouse_List(
                                IT_ACCOUNT_WAREHOUSE,
                                session.GetItemIDList(),
                                frame:GetUserIValue('HANDLE')
                            )
                        else
                            local count=1
                            CHAT_SYSTEM(L_("Psmsg"))
                            for _,v in ipairs(takeitems)do
                                ReserveScript( string.format("AUTOITEMMANAGE_FOREACH_TAKEITEM(\"%s\",%d,\"%s\")",  v.iesid, v.count,tostring(campmode)) , count*0.3)
                                
                                count=count+1
                            end
                            
                        end
                    end
                end
            end
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }
end
function AUTOITEMMANAGE_FOREACH_TAKEITEM(iesid,count,campmode)

    local frame
    if( campmode)then
        AUTOITEMMANAGE_DBGOUT("CAMPMODE")
        frame=ui.GetFrame("camp_ui")
    else
        AUTOITEMMANAGE_DBGOUT("WAREHOUSEMODE")
        frame=ui.GetFrame("warehouse")
    end
    item.TakeItemFromWarehouse(IT_WAREHOUSE, iesid, count, frame:GetUserIValue("HANDLE"));
end
function AUTOITEMMANAGE_WITHDRAW_FROM_EACH_WAREHOUSE()
    AUTOITEMMANAGE_WITHDRAW_FROM_EACH_WAREHOUSE()
end
function AUTOITEMMANAGE_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE_JUMPER(frame)
    AUTOITEMMANAGE_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE(frame)
end
function AUTOITEMMANAGE_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE(frame)
    --プリスクリプト

    if (OLD_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE ~= nil) then
        OLD_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE(frame)
    end
    --ポストスクリプト
    if (g.foundasm) then
        ReserveScript("AUTOITEMMANAGE_WITHDRAW_FROM_EACH_WAREHOUSE()",1)
        --AUTOITEMMANAGE_WITHDRAW_FROM_EACH_WAREHOUSE()
    end
end
function AUTOITEMMANAGE_SAVETOSTRUCTURE()
    local frame = ui.GetFrame(g.framename)
    local sett=AUTOITEMMANAGE_GETSETTINGS()
    if (frame == nil) then
        return
    end
    local slotset = frame:GetChild('slt')
    if (slotset == nil) then
        return
    end
    slotset = tolua.cast(slotset, 'ui::CSlotSet')

    for i = 0,slotset:GetSlotCount() - 1 do
        local slot = tolua.cast(slotset:GetSlotByIndex(i), 'ui::CSlot')
        if (slot ~= nil) then
            local iesid =slot:GetUserValue('iesid')
            local val = tonumber(slot:GetUserValue('clsid'))
            local amount = tonumber(slot:GetUserValue('count'))
            local data
            if (val == nil or amount == nil or amount == 0 ) then
                data = {}
            else
                AUTOITEMMANAGE_DBGOUT('save'..tostring(val))
                data = {iesid= iesid,clsid = tonumber(val), count = amount}
            end

            sett.refills[i + 1] = data

        else
        end
    end

    --local chkusepersonal = GET_CHILD(frame, 'usepersonal')
    --g.settings.unusecommon[session.GetMySession():GetCID()]= chkusepersonal:IsChecked()
    local chkenableaw = GET_CHILD(frame,'enableaw')
    sett.refillenableaccountwarehouse=chkenableaw:IsChecked()
    local chkenablew = GET_CHILD(frame,'enablew')
    sett.refillenablewarehouse=chkenablew:IsChecked()
    --local chkisenabled = GET_CHILD(frame,'isenabled')
    --sett.enabled=chkisenabled:IsChecked()
    AUTOITEMMANAGE_SETSETTINGS(sett)
end

function AUTOITEMMANAGE_TOGGLE_FRAME()
    ui.ToggleFrame(g.framename)
    --AUTOITEMMANAGE_SAVE_SETTINGS()
end

function AUTOITEMMANAGE_CLOSE()
    ui.GetFrame(g.framename):ShowWindow(0)
    AUTOITEMMANAGE_CLEAN_EDIT()
    --AUTOITEMMANAGE_SAVE_SETTINGS()
end

function AUTOITEMMANAGE_INIT_FRAME(frame)
    EBI_try_catch {
        try = function()
            if(frame==nil)then
                frame=ui.GetFrame(g.framename)
            end
            AUTOITEMMANAGE_DBGOUT("INIT FRAME")

            frame:SetEventScript(ui.LBUTTONUP, 'AUTOITEMMANAGE_END_DRAG')

            --slot 
            frame:RemoveChild('slt')
            frame:Resize(385,445+48*3)
            frame:SetLayerLevel(81)
            --local oldobj = GET_CHILD(frame,'slotset')
            --if(oldobj~=nil)then
            --    frame:RemoveChild('slt')
            --end
            local obj = frame:CreateOrGetControl('slotset', 'slt', 25, 190, 0, 0)
            if (obj == nil) then
                AUTOITEMMANAGE_DBGOUT('nil')
            end
            obj = frame:GetChild('slt')

            local slotset = tolua.cast(obj, 'ui::CSlotSet')

            slotset:SetColRow(7, 8)
            slotset:SetSlotSize(g.slotsize[1], g.slotsize[2])
            slotset:EnableDrag(0)
            slotset:EnableDrop(1)
            slotset:EnablePop(1)
            slotset:SetSpc(0, 0)
            slotset:SetSkinName('invenslot2')
            slotset:SetEventScript(ui.DROP, 'AUTOITEMMANAGE_ON_DROP')

            slotset:CreateSlots()
            for i = 0, slotset:GetSlotCount() - 1 do
                local slot = slotset:GetSlotByIndex(i)

                slot:SetEventScript(ui.RBUTTONDOWN, 'AUTOITEMMANAGE_ON_RCLICK')

                slot:SetEventScriptArgNumber(ui.RBUTTONDOWN, i)
                
            end
            local btncopyfromteam = frame:CreateOrGetControl('button','btncopyfromteam',250,70,30,40)
            btncopyfromteam:SetText(L_("Copybtn"))
            btncopyfromteam:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CLICK_COPYFROMTEAM")      
            --checkbox 設定増えそうなら見直す
            local chktemporarydisabled = frame:CreateOrGetControl('checkbox', 'temporarydisabled', 20, 80, 100, 20)
            chktemporarydisabled:SetText(L_("Disablecheck"))
            chktemporarydisabled:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED_TEMPDISABLED")       
            local chkuseisenabled = frame:CreateOrGetControl('checkbox', 'isenabled', 20, 110, 100, 20)
            chkuseisenabled:SetText(L_("Enablecheck"))
            chkuseisenabled:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED_ENABLED")            
            local chkusepersonal = frame:CreateOrGetControl('checkbox', 'usepersonal', 20, 160, 100, 20)
            chkusepersonal:SetText(L_("Charcheck"))
            chkusepersonal:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED_USEPERSONAL")
            local chkenableaw = frame:CreateOrGetControl('checkbox', 'enableaw', 20, 140, 100, 20)
            chkenableaw:SetText(L_("Tscheck"))
            chkenableaw:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED")
            local chkenablew = frame:CreateOrGetControl('checkbox', 'enablew', 150, 140, 100, 20)
            chkenablew:SetText(L_("Pscheck"))
            chkenablew:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED")
            AUTOITEMMANAGE_LOADFROMSTRUCTURE(frame)
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }
end
function AUTOITEMMANAGE_ON_CHECKCHANGED(frame, slot, argstr, argnum)
    if(frame~=nil)then
        AUTOITEMMANAGE_SAVE_SETTINGS()
    end
end
function AUTOITEMMANAGE_ON_CLICK_COPYFROMTEAM(frame, slot, argstr, argnum)
    --確認画面を出す
    imcSound.PlaySoundEvent('button_click_big_2');
    WARNINGMSGBOX_FRAME_OPEN(L_("CopyWarn"),
     'AUTOITEMMANAGE_APPROVE_COPYFROMTEAM', 'None');
end
function AUTOITEMMANAGE_APPROVE_COPYFROMTEAM()
    --現在地を保存
    AUTOITEMMANAGE_SAVETOSTRUCTURE()
    --コピー
    g.personalsettings.refills={unpack(g.settings.itemmanage.refills)}
    AUTOITEMMANAGE_LOADFROMSTRUCTURE()
    AUTOITEMMANAGE_SAVE_SETTINGS()
    CHAT_SYSTEM(L_("Copymsg"))
end
function AUTOITEMMANAGE_ON_CHECKCHANGED_TEMPDISABLED(frame, slot, argstr, argnum)
    EBI_try_catch{

        try=function()

            local chktemporarydisabled = GET_CHILD(frame, 'temporarydisabled')
            if(chktemporarydisabled:IsChecked()==1)then
                AUTOITEMMANAGE_DBGOUT("TEMP DISABLED")
                g.settings.itemmanagetempdisabled=true
                --g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()]=true
            else
                AUTOITEMMANAGE_DBGOUT("TEMP DISABLED CANCELED")
                g.settings.itemmanagetempdisabled=false
            end
            AUTOITEMMANAGE_SAVE_SETTINGS()
        end,
        catch=function(error)

            AUTOITEMMANAGE_ERROUT(error)
        end
    }

end
function AUTOITEMMANAGE_ON_CHECKCHANGED_ENABLED(frame, slot, argstr, argnum)
    EBI_try_catch{

        try=function()

            local chkuseisenabled = GET_CHILD(frame, 'isenabled')
            if(chkuseisenabled:IsChecked()==1)then
                AUTOITEMMANAGE_DBGOUT("ENABLED")
                g.personalsettings.enabled=true
                --g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()]=true
            else
                AUTOITEMMANAGE_DBGOUT("DISABLED")
                g.personalsettings.enabled=false
            end
            AUTOITEMMANAGE_SAVE_SETTINGS()
        end,
        catch=function(error)

            AUTOITEMMANAGE_ERROUT(error)
        end
    }

end
function AUTOITEMMANAGE_ON_CHECKCHANGED_USEPERSONAL(frame, slot, argstr, argnum)
    EBI_try_catch{

        try=function()
            AUTOITEMMANAGE_CLEAN_EDIT()
            AUTOITEMMANAGE_SAVETOSTRUCTURE()

            local chkusepersonal = GET_CHILD(frame, 'usepersonal')
            if(chkusepersonal:IsChecked()==1)then
                AUTOITEMMANAGE_DBGOUT("USE PERSONAL")
                g.personalsettings.unusecommon=true
                --g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()]=true
            else
                AUTOITEMMANAGE_DBGOUT("UNUSE PERSONAL")
                g.personalsettings.unusecommon=false
                --g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()]=false
            end

            AUTOITEMMANAGE_LOADFROMSTRUCTURE(frame)
            AUTOITEMMANAGE_SAVE_SETTINGS()
        end,
        catch=function(error)

            AUTOITEMMANAGE_ERROUT(error)
        end
    }

end

function AUTOITEMMANAGE_ON_RCLICK(frame, slot, argstr, argnum)
    EBI_try_catch {
        try = function()
            AUTOITEMMANAGE_CLEAN_EDIT()
            if keyboard.IsKeyPressed('LSHIFT') == 1 then
                --削除モード
                imcSound.PlaySoundEvent('button_click_big_2');
                slot:SetUserValue('count', nil)
                slot:SetUserValue('clsid', nil)
                slot:SetUserValue('iesid', nil)
                AUTOITEMMANAGE_CLEANSING()
                AUTOITEMMANAGE_SAVE_SETTINGS()
            else
                imcSound.PlaySoundEvent('inven_arrange');
                AUTOITEMMANAGE_DBGOUT("AUTOITEMMANAGE_CHANGENUMBER("..tostring(argnum)..")")
                ReserveScript("AUTOITEMMANAGE_CHANGENUMBER("..tostring(argnum)..")",0.05)
            end
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)

        end
    }
end
function AUTOITEMMANAGE_CHANGENUMBER(argnum)
    EBI_try_catch {
        try = function()
            --一旦初期値を思い出す
            AUTOITEMMANAGE_LOADFROMSTRUCTURE()
            local frame=ui.GetFrame(g.framename)
            local slotseto=frame:GetChild("slt")
            local slotset=tolua.cast(slotseto,"ui::CSlotSet")
            local index=argnum
            local slot=slotset:GetSlotByIndex(index)

            --データがなければ無視
            local clsid=tonumber(slot:GetUserValue('clsid'))
            if(clsid==nil or clsid==0)then
                return
            end
            imcSound.PlaySoundEvent('button_cursor_over_3');
            --RCLICKイベント中にスロットセットをいじってはいけない？
            AUTOITEMMANAGE_DBGOUT("SLOT NUM EDIT")
            --local slotset=frame
            for i=0,slotset:GetSlotCount()-1 do
                local curslot=slotset:GetSlotByIndex(i)
                curslot:RemoveChild("numberinput")
            end
            AUTOITEMMANAGE_DBGOUT("DONE-")
            --入力ボックスを出してみる
            
            --slot:SetText("")
            --slot:SetColorTone("FFAAFFAA")
            slot:SetSkinName("slot")
            local sloedit=slot:CreateOrGetControl("edit","numberinput",0,0,g.slotsize[1],g.slotsize[2]/2)
            local slo = tolua.cast(sloedit, 'ui::CEditControl')
            --slo:SetTempText(tonumber(slot:GetUserValue('count'))or 0)
            --slo:SetTempText(">")
            slo:SetText("")
            slo:SetNumberMode(1)
            slo:SetEnableEditTag(1);
            slo:SetMinNumber(1)
            slo:SetMaxNumber(32767)
            slo:SetSkinName("None")
            slo:SetFontName('green_20_ol')
            slo:SetGravity(ui.RIGHT, ui.TOP);
            slo:SetEventScript(ui.ENTERKEY,"AUTOITEMMANAGE_ON_ENTER")
            slo:SetEventScriptArgNumber(ui.ENTERKEY,index)
            slo:SetUserValue("index",tostring(index))
            slo:SetTextAlign("right", "top");
            --slo:SetLostFocusingScp("AUTOITEMMANAGE_LOSTFOCUS")
            ui.SetEscapeScp("AUTOITEMMANAGE_CLEAN_EDIT")
            --slo:SetEventScriptArgNumber(ui.LOSTFOCUS,index)
            slo:AcquireFocus()
            AUTOITEMMANAGE_DBGOUT("DONE")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("AUTOITEMMANAGE_EDIT_KEYCHECK");
            timer:Start(0.01);
            g.isediting=true
    end,
    catch = function(error)
        AUTOITEMMANAGE_ERROUT(error)

    end
    }
end
function AUTOITEMMANAGE_EDIT_KEYCHECK()
    EBI_try_catch {
    try=function()
        if(g.isediting)then
            if(g.editkeydown==false)then
                if keyboard.IsKeyPressed('ESCAPE') == 1 then
                    AUTOITEMMANAGE_CLEAN_EDIT()
                    
                elseif(1==keyboard.IsKeyPressed("TAB"))then
                    AUTOITEMMANAGE_DBGOUT("tabbed")
                    --タブ押した
                    g.editkeydown=true
                    --とりま今のを確定
                    local current=AUTOITEMMANAGE_DETERMINENUMBER()
                    local frame=ui.GetFrame(g.framename)
                    local slotseto=frame:GetChild("slt")
                    local slotset=tolua.cast(slotseto,"ui::CSlotSet")
                    imcSound.PlaySoundEvent('icon_pick_up');
                    --次へ
                    if(1==keyboard.IsKeyPressed("LSHIFT"))then
                        --リバース
                        local rv=current-1
                        while rv>=0 do
                            i=rv
                            if(i<0)then
                                break
                            end
                            local slot=slotset:GetSlotByIndex(i)
                            local clsid=tonumber(slot:GetUserValue("clsid"))
                            if(clsid~=nil and clsid~=0)then
                                --これを編集
                                AUTOITEMMANAGE_CHANGENUMBER(i)
                                break
                            end
                            rv=rv-1
                        end
                    else
                        --順方向
                        for i=current+1,slotset:GetSlotCount()-1 do
                            local slot=slotset:GetSlotByIndex(i)
                            local clsid=tonumber(slot:GetUserValue("clsid"))
                            if(clsid~=nil and clsid~=0)then
                                --これを編集
                                AUTOITEMMANAGE_CHANGENUMBER(i)
                                break
                            end
                        end
                    end      
                end
            else    
                if(1~=keyboard.IsKeyPressed("TAB"))then
                    --おわり
                    g.editkeydown=false
                end
            end
        end
    end,
    catch = function(error)
        AUTOITEMMANAGE_ERROUT(error)
    end
    }
end
function AUTOITEMMANAGE_CLEAN_EDIT()
    EBI_try_catch {
    try=function()
        if(g.isediting)then
            ui.SetEscapeScp("");
            AUTOITEMMANAGE_LOADFROMSTRUCTURE()
            local frame=ui.GetFrame(g.framename)
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:Stop();
            g.isediting=false;
            imcSound.PlaySoundEvent('icon_pick_up');
        end
    end,
    catch = function(error)
        AUTOITEMMANAGE_ERROUT(error)
    end
    }
end
-- function AUTOITEMMANAGE_ON_ENTER(frame, ctrl, argstr, argnum)
--     EBI_try_catch {
--         try = function()
--         local frame=ui.GetFrame(g.framename)
--         local index=argnum
--         local count=tonumber(ctrl:GetText())
--         local slotseto=frame:GetChild("slt")
--         local slotset=tolua.cast(slotseto,"ui::CSlotSet")
--         local slot=slotset:GetSlotByIndex(index)
--         --有効値か検証
--         if(count~=nil and count>0)then
--             --更新
--             slot:SetUserValue("count",tostring(count))
--         end
--         slot:RemoveChild("numberinput")
--         --更新
--         AUTOITEMMANAGE_SAVETOSTRUCTURE()
--         AUTOITEMMANAGE_LOADFROMSTRUCTURE()

--     end,
--     catch = function(error)
--         AUTOITEMMANAGE_ERROUT(error)

--     end
--     }

-- end
function AUTOITEMMANAGE_ON_ENTER(frame, ctrl, argstr, argnum)
    --チャット画面を出さないよう遅延させる
    ReserveScript("AUTOITEMMANAGE_DETERMINENUMBER("..tostring(argnum)..")",0.05)
end
function AUTOITEMMANAGE_DETERMINENUMBER(argnum)

    EBI_try_catch {
        try = function()
            local frame=ui.GetFrame(g.framename)
            local edit=GET_CHILD_RECURSIVELY(frame,"numberinput")
            if(argnum==nil)then
               
                argnum=tonumber(edit:GetUserValue("index"))
            end
            local count=tonumber(edit:GetText())
            local slotseto=frame:GetChild("slt")
            local slotset=tolua.cast(slotseto,"ui::CSlotSet")
            local slot=slotset:GetSlotByIndex(argnum)
            if(count == nil)then
                --fail
                
            else
 
                --有効値か検証
                if(count>0)then
                    --更新
                    slot:SetUserValue("count",tostring(count))
                end
            end
            slot:RemoveChild("numberinput")
            --更新
            AUTOITEMMANAGE_SAVETOSTRUCTURE()
            AUTOITEMMANAGE_SAVE_SETTINGS()
            AUTOITEMMANAGE_LOADFROMSTRUCTURE()

        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)

        end
    }
    AUTOITEMMANAGE_CLEAN_EDIT()
    return argnum
end
function AUTOITEMMANAGE_LOSTFOCUS()
    AUTOITEMMANAGE_CLEAN_EDIT()
end
function AUTOITEMMANAGE_ISUSEPERSONALSETTINGS()

    if (g.personalsettings.unusecommon==true) then
        
       return 1
    else
       return 0
    end
end
function AUTOITEMMANAGE_GETCID()
    local cid = session.GetMySession():GetCID()
    return cid
end
function AUTOITEMMANAGE_GETITEMSETTINGS()
   return AUTOITEMMANAGE_GETSETTINGS().refills or {}
end
function AUTOITEMMANAGE_ISENABLED()
    if (g.personalsettings.enabled==true) then
        
        return 1
    else
        return 0
    end 
end
function AUTOITEMMANAGE_GETSETTINGS()

    if (AUTOITEMMANAGE_ISUSEPERSONALSETTINGS()==1) then
        return g.personalsettings
     else
        return g.settings.itemmanage
     end
end
function AUTOITEMMANAGE_SETSETTINGS(sett)
    local cid = session.GetMySession():GetCID()
    if (AUTOITEMMANAGE_ISUSEPERSONALSETTINGS()==1) then
        
        g.personalsettings=sett
        
     else

        g.settings.itemmanage=sett

     end
end
function AUTOITEMMANAGE_CLEANSINGSLOT(slot)
    if (slot ~= nil) then
        slot:SetText('')
        slot:RemoveAllChild()
        slot:SetSkinName('invenslot2')
        slot:SetUserValue('clsid', nil)
        slot:SetUserValue('count', nil)
        slot:SetUserValue('iesid', nil)
    end
end
function AUTOITEMMANAGE_LOADFROMSTRUCTURE(frame)
    AUTOITEMMANAGE_DBGOUT('LOADINGAB')

    if(frame==nil)then
        AUTOITEMMANAGE_DBGOUT('GETFRAME')
        frame=ui.GetFrame(g.framename)
    end
    AUTOITEMMANAGE_DBGOUT('LOADING3')
    
    local sett=AUTOITEMMANAGE_GETSETTINGS()
    if (frame == nil or sett == nil) then
        AUTOITEMMANAGE_DBGOUT('NO DATA')
        return
    end
    AUTOITEMMANAGE_DBGOUT('LOADING2')

    local obj = frame:GetChild('slt')
    local slotset = tolua.cast(obj, 'ui::CSlotSet')
    if (slotset == nil) then
        return
    end
    slotset:ClearIconAll()

    for i = 0, slotset:GetSlotCount()-1 do
        -- statements
        local slot = slotset:GetSlotByIndex(i)
        AUTOITEMMANAGE_CLEANSINGSLOT(slot)

    end
    local refills=AUTOITEMMANAGE_GETITEMSETTINGS()
    for i = 1, #refills do
        EBI_try_catch { 
            try = function()
                local item = refills[i]
                if (item ~= nil) then
                    local slot = slotset:GetSlotByIndex(i - 1)
                    if (item['clsid'] ~= nil) then
                        slot:SetUserValue('clsid', tostring(item['clsid']))
                        slot:SetUserValue('count', tostring(item['count']))
                        slot:SetUserValue('iesid', tostring(item['iesid']))
                        -- アイコンを生成
                        local invcls = GetClassByType('Item', item['clsid'])
                        local useclsid=false
                        
                        if(not EBI_IsNoneOrNil(item['iesid']))then
                            local invitem =AUTOITEMMANAGE_ACQUIRE_ITEM_BY_GUID(item['iesid'])
                            if(invitem~=nil)then
                                useclsid=false
                                AUTOITEMMANAGE_DBGOUT("TYPEA "..item['iesid'])
                            else
                                --currently invalid
                                useclsid=true
                                AUTOITEMMANAGE_DBGOUT("TYPEB")
                            end
                        else
                            useclsid=true
                            AUTOITEMMANAGE_DBGOUT("TYPEC")
                        end
                        local isstackable=false
                        if(useclsid)then
                            AUTOITEMMANAGE_DBGOUT("BBB"..tostring(item['clsid']))
                            local invitem=AUTOITEMMANAGE_ACQUIRE_ITEM_BY_CLASSID(item['clsid'])
                            if(invitem~=nil)then  
                                local obj = GetIES(invitem:GetObject())
                                --SET_SLOT_INFO_FOR_WAREHOUSE(slot, invitem,"wholeitem")
                                if(obj.MaxStack > 1)then
                                    isstackable=true
                                    SET_SLOT_COUNT_TEXT(slot, item['count'])
                                end
                            else
                                if( item['count']<=1)then
                                    isstackable=false
                                    
                                else
                                    isstackable=true
                                    SET_SLOT_COUNT_TEXT(slot, item['count'])
                                    
                                end
                            end
                           
                            SET_SLOT_ITEM_CLS(slot, invcls)
                            SET_SLOT_STYLESET(slot, invcls)
                            AUTOITEMMANAGE_DBGOUT("GENE")
                        else
                            local invitem =AUTOITEMMANAGE_ACQUIRE_ITEM_BY_GUID(item['iesid'])
                            if( invitem~=nil)then
                            
                                local obj = GetIES(invitem:GetObject())
                                if(obj.MaxStack > 1)then
                                    isstackable=true
                                end
                                AUTOITEMMANAGE_DBGOUT("AAA:"..item['iesid'])
                                --SET_SLOT_COUNT_TEXT(slot, item['count'], nil);
                                --SET_SLOT_COUNT(slot, item['count'])
                                SET_SLOT_INFO_FOR_WAREHOUSE(slot, invitem,"wholeitem")
                                --SET_SLOT_ITEM_CLS(slot, obj)
                                --SET_SLOT_STYLESET(slot, obj)

                                AUTOITEMMANAGE_DBGOUT("GENE2")
                            else
                                slot:SetText("{ol}NG")
                                slot:SetTextAlign("right","bottom")
                            end
                        end
                        if isstackable==false  then
                            if EBI_IsNoneOrNil(item['iesid']) then
                                --clsidで管理する対象
                                slot:SetText("{ol}Cls")
                                slot:SetTextAlign("left","bottom")
                            else
                                --GUIDで管理する対象
                                slot:SetText("{ol}G")
                                slot:SetTextAlign("left","bottom")
                            end
                        end
                        
                    end
                end
            end,
            catch = function(error)
                AUTOITEMMANAGE_ERROUT(error)
            end
        }
    end
    local btncopyfromteam = GET_CHILD(frame,'btncopyfromteam')
    if(AUTOITEMMANAGE_ISUSEPERSONALSETTINGS()==1)then
        btncopyfromteam:SetVisible(1)
    else
        btncopyfromteam:SetVisible(0)
    end
    local chktemporarydisabled = GET_CHILD(frame,'temporarydisabled')
    if(g.settings.itemmanagetempdisabled)then
        chktemporarydisabled:SetCheck(1)
    else
        chktemporarydisabled:SetCheck(0)
    end
    local chkusepersonal = GET_CHILD(frame, 'usepersonal')
    chkusepersonal:SetCheck(AUTOITEMMANAGE_ISUSEPERSONALSETTINGS())
    local chkenableaw = GET_CHILD(frame,'enableaw')
    chkenableaw:SetCheck(sett.refillenableaccountwarehouse or 0)
    local chkenablew = GET_CHILD(frame,'enablew')
    chkenablew:SetCheck(sett.refillenablewarehouse or 0)
    local chkisenabled = GET_CHILD(frame,'isenabled')
    if(g.personalsettings.enabled==true)then
        chkisenabled:SetCheck(1)
    else
        chkisenabled:SetCheck(0)
    end
    AUTOITEMMANAGE_DBGOUT("LOAD_SUCCESSFUL")
end
function AUTOITEMMANAGE_ACQUIRE_ITEM_BY_GUID(guid)
    local invItem=nil
    invItem = GET_ITEM_BY_GUID(guid)
    if(invItem~=nil)then
        return invItem
    end
    invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE,guid)
    if(invItem~=nil)then
        return invItem
    end
    invItem = session.GetEtcItemByGuid(IT_WAREHOUSE, guid)
    if(invItem~=nil)then
        return invItem
    end
    return nil
end
function AUTOITEMMANAGE_ACQUIRE_ITEM_BY_CLASSID(classid)
    local invItem=nil
    invItem = GET_PC_ITEM_BY_TYPE(classid)
    if(invItem~=nil)then
        return invItem
    end
    return nil
end
function AUTOITEMMANAGE_ON_DROP(frame, ctrl)
    EBI_try_catch {
        try = function()
            if(g.isediting==true)then
                --CHAT_SYSTEM("[AIM]数量の編集中はドロップできません")
                ui.SysMsg(L_("DropWarn"))
                return
            end
            AUTOITEMMANAGE_DBGOUT('dropped')
            local liftIcon = ui.GetLiftIcon()
            local liftframe = ui.GetLiftFrame():GetTopParentFrame()
            AUTOITEMMANAGE_DBGOUT("FRAMENAME:"..liftframe:GetName())
            if(liftframe:GetName()==g.framename)then
                -- 入れ替え

                local slot = tolua.cast(ctrl, 'ui::CSlot')
                local iconInfo = liftIcon:GetInfo()
                AUTOITEMMANAGE_DBGOUT("IESID "..tostring(iconInfo:GetIESID()))
                local invitem = AUTOITEMMANAGE_ACQUIRE_ITEM_BY_GUID(iconInfo:GetIESID())
                if iconInfo == nil or slot == nil or invitem == nil then
                    AUTOITEMMANAGE_DBGOUT("GB")
                    return
                end
                local itemobj = GetIES(invitem:GetObject())
                --元スロットを探す
                local slotseto=liftframe:GetChild("slt")
                local slotset = tolua.cast(slotseto,"ui::CSlotSet")
                local fromslot=nil
                for i=0,slotset:GetSlotCount()-1 do
                    local curslot=slotset:GetSlotByIndex(i)
                    local cclsid=tonumber(curslot:GetUserValue("clsid"))
                    local ciesid=curslot:GetUserValue("iesid")
                    
                    --まずiesidから
                    if(ciesid==iconInfo:GetIESID() or cclsid==itemobj.ClassID)then
                        fromslot=curslot
                        break
                    end
                end
                if(fromslot~=nil)then
                    --移動してくる
                    local oclsid=slot:GetUserValue("clsid")
                    local oiesid=slot:GetUserValue("iesid")
                    local ocount=slot:GetUserValue("count")
                    slot:SetUserValue("clsid",fromslot:GetUserValue("clsid"))
                    slot:SetUserValue("iesid",fromslot:GetUserValue("iesid"))
                    slot:SetUserValue("count",fromslot:GetUserValue("count"))
                    slot:SetUserValue("clsid",oclsid)
                    slot:SetUserValue("iesid",oiesid)
                    slot:SetUserValue("count",ocount)

                    --保存
                    AUTOITEMMANAGE_SAVE_SETTINGS()
                end
            else
                --新規登録

                local liftParent = liftIcon:GetParent()
                local slot = tolua.cast(ctrl, 'ui::CSlot')
                local iconInfo = liftIcon:GetInfo()
                AUTOITEMMANAGE_DBGOUT("IESID "..tostring(iconInfo:GetIESID()))
                local invitem = AUTOITEMMANAGE_ACQUIRE_ITEM_BY_GUID(iconInfo:GetIESID())


                if iconInfo == nil or slot == nil or invitem == nil then
                    AUTOITEMMANAGE_DBGOUT("GB")
                    return
                end
                local register = false
                local itemobj = GetIES(invitem:GetObject())
                local isstackable = true
                if (iconInfo:GetIESID() == '0') then
                    -- if (liftParent:GetName() == 'pic') then
                    --     local parent = liftParent:GetParent()
                    --     while (string.starts(parent:GetName(), 'ITEM') == false) do
                    --         parent = parent:GetParent()
                    --         if (parent == nil) then
                    --             AUTOITEMMANAGE_ERROUT('失敗')
                    --             return
                    --         end
                    --     end

                    --     local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
                    --     local mySession = session.GetMySession()
                    --     local cid = mySession:GetCID()
                    --     local count = session.market.GetItemCount()
                    --     local marketItem = session.market.GetItemByIndex(row)
                    --     local obj = GetIES(marketItem:GetObject())

                    --     -- アイコンを生成
                    --     local invitems = GetClassByType('Item', obj.ClassID)
                    --     -- IESを生成
                    --     if (invitems == nil) then
                    --         CHAT_SYSTEM('それは登録できません')
                    --     else
                    --         slot:SetUserValue('clsid', tostring(obj.ClassID))
                    --         if(obj.MaxStack <= 1) then
                    --             isstackable=false
                    --         end
                    --         --SET_SLOT_ITEM_CLS(slot, invitems)
                    --         --SET_SLOT_STYLESET(slot, invitems)
                    --         register = true
                    --     end
                    -- else
                    --     CHAT_SYSTEM('そこからのドロップには対応していません')
                    --     return
                    -- end
                else
                    local invitems = GetClassByType('Item', itemobj.ClassID)
                    if (invitems == nil) then
                        CHAT_SYSTEM(L_("RegiWarn"))
                    else
                        slot:SetUserValue('clsid', tostring(itemobj.ClassID))
                        
                        invitem=GET_PC_ITEM_BY_TYPE(itemobj.ClassID)
                        local obj=GetIES(invitem:GetObject())
                        if(obj.MaxStack <= 1) then
                            isstackable=false
                            slot:SetUserValue('iesid', iconInfo:GetIESID())
                            AUTOITEMMANAGE_DBGOUT("unstackable")
                        else
                            slot:SetUserValue('iesid', nil)
                            AUTOITEMMANAGE_DBGOUT("stackable")
                        end
                        --slot:SetUserValue("iesid",iconInfo:GetIESID())
                        --SET_SLOT_ITEM_CLS(slot, invitems)
                        --SET_SLOT_STYLESET(slot, invitems)
                        register = true
                    end
                end
                if register then
                    AUTOITEMMANAGE_DBGOUT("regist")
                    AUTOITEMMANAGE_CHANGECOUNT(frame, count, slot:GetSlotIndex(),isstackable)
                end
            end
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }
end
function AUTOITEMMANAGE_CHANGECOUNT(frame, count, index,isstackable)
    g.editindex = index
    local maxcount=32767
    if(isstackable==false)then
        imcSound.PlaySoundEvent('button_click_big_2');
        ui.MsgBox(L_("ClassidWarn"),
         'AUTOITEMMANAGE_DETERMINENONSTACKABLE_AS_IESID', 'AUTOITEMMANAGE_DETERMINENONSTACKABLE_AS_CLSID');
    else
        INPUT_NUMBER_BOX(ui.GetFrame(g.framename), 'How much to be refill', 'AUTOITEMMANAGE_DETERMINE', 1, 1, maxcount, nil, nil, 1)
    end
end
function AUTOITEMMANAGE_DETERMINENONSTACKABLE_AS_CLSID()
    AUTOITEMMANAGE_DBGOUT("SET AS CLSID")
    local frame=ui.GetFrame(g.framename)
    --iesidを消す
    local obj = frame:GetChild('slt')
    local slotset = tolua.cast(obj, 'ui::CSlotSet')
    local slot = tolua.cast(slotset:GetSlotByIndex(g.editindex), 'ui::CSlot')
    slot:SetUserValue("iesid",nil)

    AUTOITEMMANAGE_DETERMINE(frame,1)
end
function AUTOITEMMANAGE_DETERMINENONSTACKABLE_AS_IESID()
    AUTOITEMMANAGE_DBGOUT("SET AS IESID")
    local frame=ui.GetFrame(g.framename)
    AUTOITEMMANAGE_DETERMINE(frame,1)

end
function AUTOITEMMANAGE_DETERMINE(frame, cnt)
    --数量を書き換える

    EBI_try_catch {
        try = function()
            local obj = frame:GetChild('slt')
            local slotset = tolua.cast(obj, 'ui::CSlotSet')
            local slot = tolua.cast(slotset:GetSlotByIndex(g.editindex), 'ui::CSlot')
            local clsid=tonumber(slot:GetUserValue('clsid'))
            local iesid=slot:GetUserValue('iesid')
            for i = 0,slotset:GetSlotCount()-1 do
                if(i~=g.editindex)then
                    local sslot = tolua.cast(slotset:GetSlotByIndex(i), 'ui::CSlot')
                    if(sslot~=nil)then
                        local sclsid=tonumber(sslot:GetUserValue('clsid'))
                        if(sclsid==nil or sclsid == 0)then
                        else
                            AUTOITEMMANAGE_DBGOUT("ITEM "..tostring(sclsid))
                            local invcls = GetClassByType('Item', sclsid)
                            local siesid=sslot:GetUserValue('iesid')
                            if(EBI_IsNoneOrNil(siesid) or EBI_IsNoneOrNil(iesid))then

                                if(sclsid==clsid)then
                                    -- 消す
                                    AUTOITEMMANAGE_CLEANSINGSLOT(sslot)
                                end
                        
                            else
                                AUTOITEMMANAGE_DBGOUT(siesid)
                                local invitem=AUTOITEMMANAGE_ACQUIRE_ITEM_BY_GUID(siesid)
                                if(invitem~=nil)then
                                    local obj=GetIES(invitem:GetObject())
                                    local maxstack = obj.MaxStack
                                    if(maxstack<=1)then
                                    
                                        --local siesid=sslot:GetUserValue('iesid')
                                        AUTOITEMMANAGE_DBGOUT("MINISTA"..iesid.."/"..siesid)
                                        if(iesid==siesid)then
                                            -- 消す
                                            AUTOITEMMANAGE_CLEANSINGSLOT(sslot)
                                        end
                                    else
                                        if(sclsid==clsid)then
                                            -- 消す
                                            AUTOITEMMANAGE_CLEANSINGSLOT(sslot)
                                        end
                                    end
                                end
                            end
                            
                        end
                    end
                end
            end

            slot:SetUserValue('count', tonumber(cnt))
            -- local invItemByIES=AUTOITEMMANAGE_ACQUIRE_ITEM_BY_GUID(iesid)
            -- local invItem = session.GetInvItemByType(tonumber(slot:GetUserValue('clsid')))
            
            -- if(iesid~=nil and iesid ~= "None")then
            --     local obj = GetIES(invItemByIES:GetObject())
            --     SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot,invItemByIES,obj, tonumber(cnt))
            --     SET_SLOT_ITEM_CLS(slot, obj)
            --     SET_SLOT_STYLESET(slot, obj)
            -- else
            --     AUTOITEMMANAGE_DBGOUT("HERE")
            --     local obj = GetIES(invItem:GetObject())
            --     SET_SLOT_COUNT_TEXT(slot, tonumber(cnt))
            --     SET_SLOT_ITEM_CLS(slot, obj)
            --     SET_SLOT_STYLESET(slot, obj)
            -- end

       
            AUTOITEMMANAGE_SAVETOSTRUCTURE()
            AUTOITEMMANAGE_CLEANSING()
            AUTOITEMMANAGE_SAVE_SETTINGS()

            AUTOITEMMANAGE_LOADFROMSTRUCTURE()
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }
end
function AUTOITEMMANAGE_CLEANSING()
    local frame = ui.GetFrame(g.framename)
    local obj = frame:GetChild('slt')
    local slotset = tolua.cast(obj, 'ui::CSlotSet')

    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = tolua.cast(slotset:GetSlotByIndex(i), 'ui::CSlot')
        local data = nil
        if (slot ~= nil) then
            local count = tonumber(slot:GetUserValue('count'))
            if (count == nil or count == 0) then
                slot:ClearIcon()
                slot:SetMaxSelectCount(0)
                slot:SetText('')
                slot:RemoveAllChild()
                slot:SetSkinName('invenslot2')
            end
        end
    end
end
function AUTOITEMMANAGE_TOGGLE_FRAME()
    if g.frame:IsVisible() == 0 then
        --非表示->表示
        g.frame:ShowWindow(1)
        g.settings.enable = true
    else
        --表示->非表示
        AUTOITEMMANAGE_CLEAN_EDIT()
        g.frame:ShowWindow(0)
        g.settings.show = false
    end

    --AUTOITEMMANAGE_SAVE_SETTINGS()
end

--フレーム場所保存処理
function AUTOITEMMANAGE_END_DRAG()
    g.settings.position.x = g.frame:GetX()
    g.settings.position.y = g.frame:GetY()
    AUTOITEMMANAGE_SAVE_SETTINGS()
end
--チャットコマンド処理（acutil使用時）
function AUTOITEMMANAGE_PROCESS_COMMAND(command)
    local cmd = "";
  
    if #command > 0 then
      cmd = table.remove(command, 1);
    else
      local msg = L_("Usagemsg")
      return ui.MsgBox(msg,"","Nope")
    end
  
    if cmd == "on" then
      --有効
        g.settings.itemmanagetempdisabled=false
        CHAT_SYSTEM(L_("Enablemsg"));
        AUTOITEMMANAGE_SAVE_SETTINGS()
      return;
    elseif cmd == "off" then
      --無効
        g.settings.itemmanagetempdisabled=true
        CHAT_SYSTEM(L_("Disablemsg"));
        AUTOITEMMANAGE_SAVE_SETTINGS()
      return;
    end
    CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
  end
