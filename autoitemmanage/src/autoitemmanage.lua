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
--2=ALPHA3,0.0.1
g.version=2
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc=""
g.editindex = 0
g.settframename="autoitemmanage"
g.debug=false
g.logpath=string.format('../addons/%s/log.txt', addonNameLower)
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

function AUTOITEMMANAGE_DEFAULTSETTINGS()
    return {
        version=g.version,
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
        }
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
        }
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
        CHAT_SYSTEM("[AIM]共通設定のバージョンを更新しました 1->2")

        g.settings.version=2
        upgraded=true
    end
    return upgraded
end
function AUTOITEMMANAGE_UPGRADE_PERSONALSETTINGS()
    local upgraded=false
    --1->2
    if(g.personalsettings.version==nil or g.personalsettings.version==1)then
        CHAT_SYSTEM("[AIM]個人設定のバージョンを更新しました 1->2")
        g.personalsettings.enabled=true

        g.personalsettings.unusecommon=g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()] or false
        g.personalsettings.version=2
        upgraded=true
    end
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function AUTOITEMMANAGE_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.settframename)
            g.addon = addon
            g.frame = frame
            g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(AUTOITEMMANAGE_GETCID()))
            frame:ShowWindow(0)
            --acutil.slashCommand("/"..addonNameLower, AUTOITEMMANAGE_PROCESS_COMMAND);

            --ccするたびに設定を読み込む

            if not g.loaded then
               
                g.loaded = true
            end
            --acutil.addSysIcon(g.settframename, 'sysmenu_sys', g.settframename, 'AUTOITEMMANAGE_TOGGLE_FRAME')
            --設定ファイル保存処理
            --AUTOITEMMANAGE_SAVE_SETTINGS()
            --メッセージ受信登録処理
            --addon:RegisterMsg("メッセージ", "内部処理");
            --addon:RegisterMsg("MARKET_ITEM_LIST", "AUTOITEMMANAGE_MARKET_ITEMLIST");
            addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'AUTOITEMMANAGE_ON_OPEN_ACCOUNT_WAREHOUSE')
            addon:RegisterMsg('OPEN_DLG_WAREHOUSE', 'AUTOITEMMANAGE_ON_OPEN_WAREHOUSE')
            addon:RegisterMsg('GAME_START_3SEC', 'AUTOITEMMANAGE_RESERVE_INIT')
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
function AUTOITEMMANAGE_RESERVE_INIT(frame)
    EBI_try_catch{
        try=function()
            AUTOITEMMANAGE_LOAD_SETTINGS()
            AUTOITEMMANAGE_INIT_FRAME(frame)
            frame:Move(0, 0)
            frame:SetOffset(g.settings.position.x, g.settings.position.y)
        

        end,
        catch=function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }

    
    

end
function AUTOITEMMANAGE_ON_OPEN_ACCOUNT_WAREHOUSE()
    --if (not g.foundasm) then
    EBI_try_catch{
        try=function()
        AUTOITEMMANAGE_DBGOUT('OPEN WAREHOUSE1')

        local frame=ui.GetFrame("accountwarehouse")
        local btn=frame:CreateOrGetControl('button', 'showconfig', 400, 80, 100, 30)
        btn:SetText("{ol}AIM設定")
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
            AUTOITEMMANAGE_DBGOUT('OPEN WAREHOUSE1')

            local frame=ui.GetFrame("warehouse")
            local btn=frame:CreateOrGetControl('button', 'showconfig', 380, 80, 110, 30)
            btn:SetText("{ol}AIM設定")
            btn:SetEventScript(ui.LBUTTONDOWN,"AUTOITEMMANAGE_TOGGLE_FRAME")
  
            ReserveScript("AUTOITEMMANAGE_WITHDRAW_FROM_WAREHOUSE()",0.5)
        end,
        catch=function(error)
            AUTOITEMMANAGE_ERROUT(error)       
        end
    }

    --end
end
function AUTOITEMMANAGE_WITHDRAW_FROM_WAREHOUSE()
    EBI_try_catch {
        try = function()
            AUTOITEMMANAGE_DBGOUT('OPEN WAREHOUSE_2')

            local cid = session.GetMySession():GetCID()
            local refer=AUTOITEMMANAGE_GETITEMSETTINGS()
            local sett=AUTOITEMMANAGE_GETSETTINGS()
            local accountmode=false
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
                frame= ui.GetFrame('warehouse')
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
                            having = 0
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
                                            AUTOITEMMANAGE_DBGOUT('DT'..tostring(vv.clsid))
                                            withdrawlist[#withdrawlist].having=invItem.count
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
                if (count > 0) then
                   
                    if(accountmode)then
                        CHAT_SYSTEM("[AIM]チーム倉庫からアイテムを引き出します")
                        item.TakeItemFromWarehouse_List(
                            IT_ACCOUNT_WAREHOUSE,
                            session.GetItemIDList(),
                            frame:GetUserIValue('HANDLE')
                        )
                    else
                        local count=1
                        CHAT_SYSTEM("[AIM]個人倉庫からアイテムを引き出します")
                        for _,v in ipairs(takeitems)do
                            ReserveScript( string.format("AUTOITEMMANAGE_FOREACH_TAKEITEM(\"%s\",%d)",  v.iesid, v.count) , count*0.3)
                            
                            count=count+1
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
function AUTOITEMMANAGE_FOREACH_TAKEITEM(iesid,count)
    local frame = ui.GetFrame("warehouse")
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
    local frame = ui.GetFrame(g.settframename)
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
            local val = tonumber(slot:GetUserValue('clsid'))
            local amount = tonumber(slot:GetUserValue('count'))
            local data
            if (val == nil or amount == nil or amount == 0) then
                data = {}
            else
                AUTOITEMMANAGE_DBGOUT('save'..tostring(val))
                data = {clsid = tonumber(val), count = amount}
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
    ui.ToggleFrame(g.settframename)
    --AUTOITEMMANAGE_SAVE_SETTINGS()
end

function AUTOITEMMANAGE_CLOSE()
    ui.GetFrame(g.settframename):ShowWindow(0)
    --AUTOITEMMANAGE_SAVE_SETTINGS()
end

function AUTOITEMMANAGE_INIT_FRAME(frame)
    EBI_try_catch {
        try = function()
            if(frame==nil)then
                frame=ui.GetFrame(g.settframename)
            end
            AUTOITEMMANAGE_DBGOUT("INIT FRAME")

            frame:SetEventScript(ui.LBUTTONUP, 'AUTOITEMMANAGE_END_DRAG')

            --slot 
            frame:RemoveChild('slt')
            frame:Resize(385,415)
            frame:SetLayerLevel(81)
            --local oldobj = GET_CHILD(frame,'slotset')
            --if(oldobj~=nil)then
            --    frame:RemoveChild('slt')
            --end
            local obj = frame:CreateOrGetControl('slotset', 'slt', 25, 160, 0, 0)
            if (obj == nil) then
                AUTOITEMMANAGE_DBGOUT('nil')
            end
            obj = frame:GetChild('slt')

            local slotset = tolua.cast(obj, 'ui::CSlotSet')

            slotset:SetColRow(7, 5)
            slotset:SetSlotSize(48, 48)
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

            --checkbox 設定増えそうなら見直す
            local chkuseisenabled = frame:CreateOrGetControl('checkbox', 'isenabled', 20, 80, 100, 20)
            chkuseisenabled:SetText("{ol}このキャラで使用する")
            chkuseisenabled:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED_ENABLED")            
            local chkusepersonal = frame:CreateOrGetControl('checkbox', 'usepersonal', 20, 130, 100, 20)
            chkusepersonal:SetText("{ol}個人設定を使用する(解除で共通設定)")
            chkusepersonal:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED_USEPERSONAL")
            local chkenableaw = frame:CreateOrGetControl('checkbox', 'enableaw', 20, 110, 100, 20)
            chkenableaw:SetText("{ol}チーム倉庫")
            chkenableaw:SetEventScript(ui.LBUTTONUP,"AUTOITEMMANAGE_ON_CHECKCHANGED")
            local chkenablew = frame:CreateOrGetControl('checkbox', 'enablew', 150, 110, 100, 20)
            chkenablew:SetText("{ol}個人倉庫")
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
            AUTOITEMMANAGE_SAVETOSTRUCTURE()

            local chkusepersonal = GET_CHILD(frame, 'usepersonal')
            if(chkusepersonal:IsChecked()==1)then
                AUTOITEMMANAGE_DBGOUT("USE PERSONAL")
                g.personalsettings.unusecommon=true
                --g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()]=true
            else
                AUTOITEMMANAGE_DBGOUT("UNUSE PERSONAL")
                g.personalsettings.unusecommon=false
                g.settings.itemmanage.unusecommon[AUTOITEMMANAGE_GETCID()]=false
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
            if keyboard.IsKeyPressed('LSHIFT') == 1 then
                --削除モード
                slot:SetUserValue('count', nil)
                slot:SetUserValue('clsid', nil)
                AUTOITEMMANAGE_CLEANSING()
                AUTOITEMMANAGE_SAVE_SETTINGS()
            end
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)

        end
    }
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
    end
end
function AUTOITEMMANAGE_LOADFROMSTRUCTURE(frame)
    AUTOITEMMANAGE_DBGOUT('LOADINGAB')

    if(frame==nil)then
        AUTOITEMMANAGE_DBGOUT('GETFRAME')
        frame=ui.GetFrame(g.settframename)
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
                        -- アイコンを生成
                        local invcls = GetClassByType('Item', item['clsid'])
                        --local invitem =session.GetInvItemByType(invcls.ClassID)
                      
                        
                        --local obj = GetIES(invitem:GetObject())
                        SET_SLOT_COUNT_TEXT(slot, item['count'], font);
                        --SET_SLOT_COUNT(slot, item['count'])
                        SET_SLOT_ITEM_CLS(slot, invcls)
                        SET_SLOT_STYLESET(slot, invcls)
                        AUTOITEMMANAGE_DBGOUT("GENE")
                        
                    end
                end
            end,
            catch = function(error)
                AUTOITEMMANAGE_ERROUT(error)
            end
        }
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

function AUTOITEMMANAGE_ON_DROP(frame, ctrl)
    EBI_try_catch {
        try = function()
            AUTOITEMMANAGE_DBGOUT('dropped')
            local liftIcon = ui.GetLiftIcon()
            local liftParent = liftIcon:GetParent()
            local slot = tolua.cast(ctrl, 'ui::CSlot')
            local iconInfo = liftIcon:GetInfo()

            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID())
            if (invitem == nil) then
                -- リトライ
                invitem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID())
            end

            if (invitem == nil) then
                -- リトライ
                invitem = session.GetEtcItemByGuid(IT_WAREHOUSE, iconInfo:GetIESID())
            end

            if iconInfo == nil or slot == nil or invitem == nil then
                return
            end
            local register = true
            local itemobj = GetIES(invitem:GetObject())
            local isstackable = true
            if (iconInfo:GetIESID() == '0') then
                if (liftParent:GetName() == 'pic') then
                    local parent = liftParent:GetParent()
                    while (string.starts(parent:GetName(), 'ITEM') == false) do
                        parent = parent:GetParent()
                        if (parent == nil) then
                            AUTOITEMMANAGE_ERROUT('失敗')
                            return
                        end
                    end

                    local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
                    local mySession = session.GetMySession()
                    local cid = mySession:GetCID()
                    local count = session.market.GetItemCount()
                    local marketItem = session.market.GetItemByIndex(row)
                    local obj = GetIES(marketItem:GetObject())

                    -- アイコンを生成
                    local invitems = GetClassByType('Item', obj.ClassID)
                    -- IESを生成
                    if (invitems == nil) then
                        CHAT_SYSTEM('それは登録できません')
                    else
                        slot:SetUserValue('clsid', tostring(obj.ClassID))
                        if(obj.MaxStack <= 1) then
                            isstackable=false
                        end
                        --SET_SLOT_ITEM_CLS(slot, invitems)
                        --SET_SLOT_STYLESET(slot, invitems)
                        register = true
                    end
                else
                    CHAT_SYSTEM('そこからのドロップには対応していません')
                    return
                end
            else
                local invitems = GetClassByType('Item', itemobj.ClassID)
                if (invitems == nil) then
                    CHAT_SYSTEM('それは登録できません')
                else
                    slot:SetUserValue('clsid', tostring(itemobj.ClassID))

                    if(itemobj.MaxStack <= 1) then
                        isstackable=false
                    end
                    --slot:SetUserValue("iesid",iconInfo:GetIESID())
                    --SET_SLOT_ITEM_CLS(slot, invitems)
                    --SET_SLOT_STYLESET(slot, invitems)
                    register = true
                end
            end
            if register then
                AUTOITEMMANAGE_CHANGECOUNT(frame, count, slot:GetSlotIndex(),isstackable)
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
        maxcount=1
    end
    INPUT_NUMBER_BOX(ui.GetFrame(g.settframename), '補充する数を入力', 'AUTOITEMMANAGE_DETERMINE', 1, 1, maxcount, nil, nil, 1)
end
function AUTOITEMMANAGE_DETERMINE(frame, cnt)
    --数量を書き換える

    EBI_try_catch {
        try = function()
            local obj = frame:GetChild('slt')
            local slotset = tolua.cast(obj, 'ui::CSlotSet')
            local slot = tolua.cast(slotset:GetSlotByIndex(g.editindex), 'ui::CSlot')
            local clsid=tonumber(slot:GetUserValue('clsid'))

            for i = 0,slotset:GetSlotCount()-1 do
                if(i~=g.editindex)then
                    local sslot = tolua.cast(slotset:GetSlotByIndex(i), 'ui::CSlot')
                    if(sslot~=nil)then
                        local sclsid=tonumber(sslot:GetUserValue('clsid'))
                        if(sclsid==clsid)then
                            -- 消す
                            AUTOITEMMANAGE_CLEANSINGSLOT(sslot)
                        end
                    end
                end
            end

            slot:SetUserValue('count', tonumber(cnt))
            local invItem = session.GetInvItemByType(tonumber(slot:GetUserValue('clsid')))
            local obj = GetIES(invItem:GetObject())
            SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, tonumber(cnt))
            SET_SLOT_ITEM_CLS(slot, obj)
            SET_SLOT_STYLESET(slot, obj)
            AUTOITEMMANAGE_SAVETOSTRUCTURE()
            AUTOITEMMANAGE_CLEANSING()
            AUTOITEMMANAGE_SAVE_SETTINGS()
        end,
        catch = function(error)
            AUTOITEMMANAGE_ERROUT(error)
        end
    }
end
function AUTOITEMMANAGE_CLEANSING()
    local frame = ui.GetFrame(g.settframename)
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
