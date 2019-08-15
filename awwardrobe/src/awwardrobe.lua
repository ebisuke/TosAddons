--アドオン名（大文字）
local addonName = "AWWARDROBE"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

--設定ファイル保存先
g.version = 0
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""

g.framename = "awwardrobe"
g.debug = false
g.interlocked = false
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)
g.effectingspot = {
    HAT_T = true, --コス
    HAT = true, --コス
    HAT_L = true, --コス
    RING1 = true, --ブレスレット
    RING2 = true, --ブレスレット
    RH = true, --左手!
    LH = true, --右手!
    GLOVES = true, --グローブ
    BOOTS = true, --ブーツ
    NECK = true, --ネックレス
    SEAL = true, --エンブレム
    PANTS = true, --下半身
    SHIRT = true --上半身
}
local translationtable={

	btnawwwithdraw = {jp="引出",  eng="Withdraw"},
	btnawwdeposit = {jp="預入",  eng="Deposit"},
    btnawwchange = {jp="入替",  eng="Swap"},
    btnawwconfig = {jp="AWW設定",  eng="AWW Conf"},
	tipbtnawwwithdraw = {jp="指定した装備セットを倉庫から引き出し、装備します",  eng="Withdraws and equips the specified equipment set from the account storage."},
	tipbtnawwdeposit = {jp="指定した装備セットの装備と装着位置が一致する装備を外し、倉庫に預けます",  eng="Remove the equipment that matches the equipment position of the specified equipment set {nl} and deposit it in the account storage."},
    tipbtnawwchange = {jp="指定した装備セットの装備と入れ替えます",  eng="Swap with the equipment of the specified equipment set."},
    tipbtnawwconfig = {jp="AWWの設定画面を開きます",  eng="Show the setting frame of AWW."},
    tipcbwardrobe = {jp="AWWで交換する装備セットを指定します",  eng="Specify the equipment set to be swapped by AWW."},
    btnregister = {jp="現在の装備をセット",  eng="Set Current Equips"},
    btnclear = {jp="装備をリセット",  eng="Clear Settings"},
    
    btnsave = {jp="設定保存",  eng="Save Settings"},
    btndelete = {jp="{#FF6666}設定削除",  eng="{#FF6666}Delete Settings"},
    labelsettingsname = {jp="{ol}保存する設定名:",  eng="{ol}Settings Name:"},
    labelcurrentsettings = {jp="{ol}現在の設定:",  eng="{ol}Settings:"},
    defaultvalue = {jp="(デフォルト)",  eng="(default)"},
    alertnosettings={jp="[AWW]設定 %s は存在しません",  eng="[AWW]Settings %s not found."},
    alertcantdelete={jp="[AWW]設定 %s は削除できません",  eng="[AWW]Settings %s cannot delete."},
    alertinvalidname={jp="[AWW]有効な名前を入れてください",  eng="[AWW]Invalid name."},
    alertsettingssaved={jp="[AWW]設定 %s 保存しました",  eng="[AWW]Settings %s saved."},
    alertnodeletesettings={jp="[AWW]設定 %s がないです",  eng="[AWW]Settings %s not found."},
    alertdeletesettings={jp="[AWW]設定 %s を削除しました",  eng="[AWW]Settings %s deleted."},
    alertcantequip={jp="[AWW]この部位には装着できません",  eng="[AWW]Cannot be equipped on that part."},
    alertworkingothers={jp="[AWW]他が動作中です",  eng="[AWW]Other processing is in progress."},
    alertopenaw={jp="[AWW]チーム倉庫画面を開いてください",  eng="[AWW]Please open the account storage."},
    alertinsufficientslot={jp="[AWW]チーム倉庫の空きが足りません",  eng="[AWW]Insufficient empty slot."},
    alertchangeequip={jp="[AWW]設定と一致した装備を入れ替えます",  eng="[AWW]Swap equips."},
    alertinsufficientequips={jp="[AWW]足りない装備がありますが、このまま続行します",  eng="[AWW]Not enough equipment but continue."},
    alertcomplete={jp="[AWW]終わりました",  eng="[AWW]Complete."},
    alertdeposit={jp="[AWW]設定と一致した個所を脱ぎます",  eng="[AWW]Deposit equips."},
    alertwithdraw={jp="[AWW]倉庫・インベントリから装備します",  eng="[AWW]Withdraw and wear equips."},
    alertunwear={jp="[AWW]全部脱ぎます",  eng="[AWW]Unwear equips."},
    alertplzselect={jp="[AWW]装備セットを選択してください",  eng="[AWW]Please select an equipment set."},
}

local function L_(str)
    if(option.GetCurrentCountry()=="Japanese")then
        return translationtable[str].jp
    else
        return translationtable[str].eng
    end
end

local function split(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end
    
    local t = {};
    i = 1
    for s in string.gmatch(str, "([^" .. ts .. "]+)") do
        t[i] = s
        i = i + 1
    end
    
    return t
end

--ライブラリ読み込み
CHAT_SYSTEM("[AWW]loaded")
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function AWWARDROBE_try(func)
    return EBI_try_catch{
        try = func,
        catch = function(error)
            AWWARDROBE_ERROUT(error)
        end
    }
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
function EBI_RemoveWhitespace(str)
    return string.gsub(string.gsub(string.gsub(str,"    ","")," ",""),"　","")
end
function EBI_IsNoneOrNilOrWhitespace(val)
    return val == nil or val == "None" or val == "nil" or EBI_RemoveWhitespace(val) == ""
end
function AWWARDROBE_DEFAULTSETTINGS()
    return {
        version = g.version,
        wardrobe = {
        },
        defaultname = nil
    }
end
function AWWARDROBE_DEFAULTPERSONALSETTINGS()
    return {
        version = g.version,
        defaultname = nil
    }
end
--デフォルト設定
if (not g.loaded) then
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
    
    }
    g.personalsettings = {
        version = nil,
    }
    g.settings = AWWARDROBE_DEFAULTSETTINGS()
    g.personalsettings = AWWARDROBE_DEFAULTPERSONALSETTINGS()
end

function AWWARDROBE_DBGOUT(msg)
    
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
function AWWARDROBE_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function AWWARDROBE_SAVE_SETTINGS()
    AWWARDROBE_DBGOUT("SAVE_SETTINGS")
    
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, tostring(AWWARDROBE_GETCID()))
    AWWARDROBE_DBGOUT("psn" .. g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end

function AWWARDROBE_LOAD_SETTINGS()
    AWWARDROBE_DBGOUT("LOAD_SETTINGS " .. tostring(AWWARDROBE_GETCID()))
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        AWWARDROBE_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = AWWARDROBE_DEFAULTSETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = AWWARDROBE_DEFAULTSETTINGS().version
        end
    end
    AWWARDROBE_DBGOUT("LOAD_PSETTINGS " .. g.personalsettingsFileLoc)
    g.personalsettings = {}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        AWWARDROBE_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.personalsettings = AWWARDROBE_DEFAULTPERSONALSETTINGS()
    
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = AWWARDROBE_DEFAULTPERSONALSETTINGS().version
        end
    end
    AWWARDROBE_VALIDATE_SETTINGS()
    local upc = AWWARDROBE_UPGRADE_SETTINGS()
    local upp = AWWARDROBE_UPGRADE_PERSONALSETTINGS()
    -- ショートサーキット評価を回避するため、いったん変数に入れる
    if upc or upp then
        AWWARDROBE_SAVE_SETTINGS()
    end
end
function AWWARDROBE_VALIDATE_SETTINGS()
    for k,v in pairs(g.settings.wardrobe) do
        if(EBI_IsNoneOrNilOrWhitespace(k))then
            g.settings.wardrobe[k]=nil
            
        end
    end
end
function AWWARDROBE_UPGRADE_SETTINGS()
    local upgraded = false
    if(not g.settings.version or g.settings.version==0)then
        g.settings.wardrobe[L_("defaultvalue")]={}
        g.settings.version=1
        CHAT_SYSTEM("[AWW]Settings Verup 0->1")
        upgraded=true;
    end
    return upgraded
end
function AWWARDROBE_UPGRADE_PERSONALSETTINGS()
    local upgraded = false
    if(not g.personalsettings.version or g.personalsettings.version==0)then
        g.personalsettings.version=1
        CHAT_SYSTEM("[AWW]PersonalSettings Verup 0->1")
        upgraded=true
    end
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function AWWARDROBE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, tostring(AWWARDROBE_GETCID()))
            frame:ShowWindow(0)
            
            AWWARDROBE_LOAD_SETTINGS()
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            
            addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'AWWARDROBE_ON_OPEN_ACCOUNT_WAREHOUSE')
            --addon:RegisterMsg('OPEN_DLG_WAREHOUSE', 'AWWARDROBE_ON_OPEN_WAREHOUSE')
            addon:RegisterMsg('OPEN_CAMP_UI', 'AWWARDROBE_ON_OPEN_CAMP_UI')
            addon:RegisterMsg('GAME_START_3SEC', 'AWWARDROBE_RESERVE_INIT')
            
            frame:ShowWindow(1)
            AWWARDROBE_INITIALIZE_FRAME()
            frame:ShowWindow(0)
            g.interlocked=false
        end,
        catch = function(error)
            AWWARDROBE_ERROUT(error)
        end
    }
end
function AWWARDROBE_TOGGLE_FRAME()
    if g.frame:IsVisible() == 0 then
        --非表示->表示
        g.frame:ShowWindow(1)
        g.settings.enable = true
    else
        --表示->非表示
        AWWARDROBE_CLEAN_EDIT()
        g.frame:ShowWindow(0)
        g.settings.show = false
    end

--AWWARDROBE_SAVE_SETTINGS()
end
function AWWARDROBE_ON_OPEN_ACCOUNT_WAREHOUSE()
    local frame = ui.GetFrame("accountwarehouse")
    --initialize
    local btnawwwithdraw = frame:CreateOrGetControl("button", "btnawwwithdraw", 110, 120, 70, 30)
    btnawwwithdraw:SetText(L_("btnawwwithdraw"))
    btnawwwithdraw:SetTextTooltip(L_("tipbtnawwwithdraw"))
    btnawwwithdraw:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_ON_WITHDRAW")
    local btnawwdeposit = frame:CreateOrGetControl("button", "btnawwdeposit", 190, 120, 70, 30)
    btnawwdeposit:SetText(L_("btnawwdeposit"))
    btnawwdeposit:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_ON_DEPOSIT")
    btnawwdeposit:SetEventScript(ui.RBUTTONDOWN, "AWWARDROBE_UNWEARALL")
    btnawwdeposit:SetTextTooltip(L_("tipbtnawwdeposit"))
    local btnawwchange = frame:CreateOrGetControl("button", "btnawwchange", 270, 120, 70, 30)
    btnawwchange:SetText(L_("btnawwchange"))
    btnawwchange:SetTextTooltip(L_("tipbtnawwchange"))
    btnawwchange:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_ON_CHANGE")
    local btnawwconfig = frame:CreateOrGetControl("button", "btnawwconfig", 350, 120, 70, 30)
    btnawwconfig:SetText(L_("btnawwconfig"))
    btnawwconfig:SetTextTooltip(L_("tipbtnawwconfig"))
    btnawwconfig:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_TOGGLE_FRAME")
    local cbwardrobe = frame:CreateOrGetControl("droplist", "cbwardrobe", 110, 100, 250, 20)
    tolua.cast(cbwardrobe, "ui::CDropList")
    cbwardrobe:SetSkinName("droplist_normal")
    cbwardrobe:SetTextTooltip(L_("tipcbwardrobe"))
    AWWARDROBE_UPDATE_DROPBOXAW()
end
--フレーム場所保存処理
function AWWARDROBE_END_DRAG()
    g.settings.position.x = g.frame:GetX()
    g.settings.position.y = g.frame:GetY()
    AWWARDROBE_SAVE_SETTINGS()
end
function AWWARDROBE_ON_CHANGE()
    AWWARDROBE_try(function()
        local awframe = ui.GetFrame("accountwarehouse")
        --選択しているものを取得
        local cbwardrobe = GET_CHILD(awframe, "cbwardrobe", "ui::CDropList")
        local selected = cbwardrobe:GetSelItemCaption()
        local tbl = g.settings.wardrobe[selected]
        if(tbl)then
            g.personalsettings.defaultname = selected
            AWWARDROBE_DBGOUT(selected)
            AWWARDROBE_SAVE_SETTINGS()
                    --UNWEAR
            AWWARDROBE_CHANGE_MATCHED(ui.GetFrame(g.framename), tbl)
        else
            ui.SysMsg(L_("alertplzselect"))
        end
    end)
end
function AWWARDROBE_ON_DEPOSIT()
    AWWARDROBE_try(function()
        local awframe = ui.GetFrame("accountwarehouse")
        --選択しているものを取得
        local cbwardrobe = GET_CHILD(awframe, "cbwardrobe", "ui::CDropList")
        local selected = cbwardrobe:GetSelItemCaption()
        local tbl = g.settings.wardrobe[selected]
        if(tbl)then
            g.personalsettings.defaultname = selected
            AWWARDROBE_DBGOUT(selected)
            AWWARDROBE_SAVE_SETTINGS()
            --UNWEAR
            AWWARDROBE_UNWEAR_MATCHED(ui.GetFrame(g.framename), tbl)
        else
            ui.SysMsg(L_("alertplzselect"))
        end
    end)
end
function AWWARDROBE_ON_WITHDRAW()
    AWWARDROBE_try(function()
        local awframe = ui.GetFrame("accountwarehouse")
        --選択しているものを取得
        local cbwardrobe = GET_CHILD(awframe, "cbwardrobe", "ui::CDropList")
        local selected = cbwardrobe:GetSelItemCaption()
        local tbl = g.settings.wardrobe[selected]
        if(tbl)then
            g.personalsettings.defaultname = selected
            AWWARDROBE_SAVE_SETTINGS()
            --WEAR
            AWWARDROBE_WEAR_MATCHED(ui.GetFrame(g.framename), tbl)
        else
            ui.SysMsg(L_("alertplzselect"))
        end
    end)
end




function AWWARDROBE_INITIALIZE_FRAME()
    
    local frame = ui.GetFrame(g.framename);
    
    frame:Resize(600, 450)
    frame:GetChild("gbox_Equipped"):ShowWindow(1)
    frame:GetChild("gbox_Equipped"):SetOffset(10, 110)
    frame:GetChild("gbox_Dressed"):ShowWindow(1)
    frame:GetChild("gbox_Dressed"):SetOffset(280, 120)
    -- local btnmappa=frame:CreateOrGetControl("button","btnmappa",20,300,50,50)
    -- btnmappa:SetText("全脱がし")
    -- btnmappa:SetEventScript(ui.LBUTTONDOWN,"AWWARDROBE_UNWEARALL")
    local btnregister = frame:CreateOrGetControl("button", "btnregister", 300, 240, 200, 40)
    btnregister:SetText(L_("btnregister"))
    btnregister:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_REGISTER_CURRENTEQUIP")
    
    local btnclear = frame:CreateOrGetControl("button", "btnclear", 300, 300, 200, 40)
    btnclear:SetText(L_("btnclear"))
    btnclear:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_CLEARALLEQUIPS")
    
    local btnsave = frame:CreateOrGetControl("button", "btnsave", 300, 360, 130, 40)
    btnsave:SetText(L_("btnsave"))
    btnsave:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_BTNSAVE_ON_LBUTTONDOWN")
    
    local btndelete = frame:CreateOrGetControl("button", "btndelete", 440, 360, 130, 40)
    btndelete:SetText(L_("btndelete"))
    btndelete:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_BTNDELETE_ON_LBUTTONDOWN")
    
    frame:CreateOrGetControl("richtext", "label1", 20, 80, 80, 20):SetText(L_("labelcurrentsettings"))
    
    local cbwardrobe = frame:CreateOrGetControl("droplist", "cbwardrobe", 130, 80, 250, 20)
    tolua.cast(cbwardrobe, "ui::CDropList")
    cbwardrobe:SetSkinName("droplist_normal")
    cbwardrobe:SetSelectedScp("AWWARDROBE_WARDROBE_ON_SELECT_DROPLIST")
    local ebname = frame:CreateOrGetControl("edit", "ebname", 20, 360, 250, 30)
    ebname:SetFontName("white_18_ol")
    ebname:SetSkinName("test_weight_skin")
    frame:CreateOrGetControl("richtext", "label2", 20, 340, 80, 20):SetText(L_("labelsettingsname"))
    
    for k, _ in pairs(g.effectingspot) do
        
        local slot = GET_CHILD_RECURSIVELY(frame, k, "ui::CSlot")
        slot:SetEventScript(ui.RBUTTONDOWN, "AWWARDROBE_SLOT_ON_RBUTTONDOWN")
        slot:SetEventScriptArgString(ui.RBUTTONDOWN, k)
        slot:SetEventScript(ui.DROP, "AWWARDROBE_SLOT_ON_DROP")
        slot:SetEventScriptArgString(ui.DROP, k)
        
        slot:EnableDrag(0)
    end
    
    AWWARDROBE_UPDATE_DROPBOX()
    AWWARDROBE_WARDROBE_ON_SELECT_DROPLIST(frame, true)
end
function AWWARDROBE_UPDATE_DROPBOX()
    AWWARDROBE_try(function()
        local frame = ui.GetFrame(g.framename)
        
        local cbwardrobe = GET_CHILD(frame, "cbwardrobe", "ui::CDropList")
        
        cbwardrobe:ClearItems()
        
        local count = 0
        local selectindex = nil
        AWWARDROBE_DBGOUT("def" .. tostring(g.settings.defaultname))
        --1行目にdefaultの設定を入れておく
        cbwardrobe:AddItem(0,L_("defaultvalue"))
        for k, _ in pairs(g.settings.wardrobe) do
            if(k~=L_("defaultvalue"))then
                cbwardrobe:AddItem(count+1, k)
                if (k == g.settings.defaultname) then
                    selectindex = count+1
                end
                count = count + 1
            end
          
        end
        if (selectindex ~= nil) then
            cbwardrobe:SelectItem(selectindex)
        end
        cbwardrobe:Invalidate()
    
    end)

end
function AWWARDROBE_UPDATE_DROPBOXAW()
    AWWARDROBE_try(function()
            
            local awframe = ui.GetFrame("accountwarehouse")
            if (awframe:IsVisible() == 1) then
                local acbwardrobe = GET_CHILD(awframe, "cbwardrobe", "ui::CDropList")
                
                acbwardrobe:ClearItems()
                --1行目にdefaultの設定を入れておく
                acbwardrobe:AddItem(0,L_("defaultvalue"))
                local count = 0
                local selectindex = nil
                AWWARDROBE_DBGOUT("def" .. tostring(g.personalsettings.defaultname))
                for k, _ in pairs(g.settings.wardrobe) do
                    if(k~=L_("defaultvalue"))then
                        acbwardrobe:AddItem(count+1, k)
                        if (k == g.personalsettings.defaultname) then
                            AWWARDROBE_DBGOUT("match"..tostring(count+1))
                            selectindex = count+1
                        end
                        count = count + 1
                    end
                    
                end
                if (selectindex ~= nil) then
                    acbwardrobe:SelectItem(selectindex)
                end
                acbwardrobe:Invalidate()
            end
    end)

end
function AWWARDROBE_WARDROBE_ON_SELECT_DROPLIST(frame, shutup)
    AWWARDROBE_try(function()
            --現在の設定を消す
            AWWARDROBE_DBGOUT("out")
            local cbwardrobe = GET_CHILD(frame, "cbwardrobe", "ui::CDropList")
            local key = cbwardrobe:GetSelItemCaption()
            if (key~="" and not g.settings.wardrobe[key]) then
                ui.SysMsg(string.format(L_("alertnosettings"),key));
                return
            end
            
            g.settings.defaultname = key
            
            local sound = not (shutup == true)
            if(key=="")then
                AWWARDROBE_CLEARALLEQUIPS(frame)
            else
                AWWARDROBE_LOADEQFROMSTRUCTURE(g.settings.wardrobe[key], sound)
            end
            local ebname = GET_CHILD(frame, "ebname", "ui::CEditControl")
            ebname:SetText(key)
    end)
end
function AWWARDROBE_BTNSAVE_ON_LBUTTONDOWN(frame)
    AWWARDROBE_try(function()
            
            --現在の設定を消す
            local ebname = GET_CHILD(frame, "ebname", "ui::CEditControl")
            local curname = ebname:GetText()
            if (EBI_IsNoneOrNilOrWhitespace(curname)) then
                ui.SysMsg(L_("alertinvalidname"));
                return
            end
            --現在の設定を保存
            local table = AWWARDROBE_SAVEEQTOSTRUCTURE()
            g.settings.wardrobe = g.settings.wardrobe or {}
            g.settings.defaultname = curname
            g.settings.wardrobe[curname] = table
            ui.SysMsg(string.format(L_("alertsettingssaved"),curname));
            AWWARDROBE_SAVE_SETTINGS()
            AWWARDROBE_UPDATE_DROPBOX()
            AWWARDROBE_UPDATE_DROPBOXAW()
    end)
end
function AWWARDROBE_LOADEQFROMSTRUCTURE(table, enableeffect)
    local frame = ui.GetFrame(g.framename)
    --一旦クリア
    AWWARDROBE_CLEARALLEQUIPS(frame)
    
    for k, v in pairs(table) do
        local slot = GET_CHILD_RECURSIVELY(frame, k, "ui::CSlot")
        if (slot ~= nil) then
            local iesid = v.iesid;
            local clsid = tonumber(v.clsid)
            if (not EBI_IsNoneOrNil(iesid) and not EBI_IsNoneOrNil(clsid)) then
                local invitem = AWWARDROBE_ACQUIRE_ITEM_BY_GUID(iesid)
                AWWARDROBE_DBGOUT(k)
                --取得できた？
                if (invitem == nil) then
                    --できない
                    local invcls = GetClassByType("Item", clsid)
                    SET_SLOT_ITEM_CLS(slot, invcls)
                    SET_SLOT_STYLESET(slot, invcls)
                    slot:SetText("{ol}XX")
                    slot:SetTextAlign(ui.LEFT, ui.BOTTOM)
                
                else
                    --できた
                    SET_SLOT_INFO_FOR_WAREHOUSE(slot, invitem, "wholeitem")
                end
                slot:SetUserValue("clsid", tostring(clsid))
                slot:SetUserValue("iesid", tostring(iesid))
            
            end
        end
    end
    
    if (enableeffect) then
        for k, _ in pairs(g.effectingspot) do
            local slot = GET_CHILD_RECURSIVELY(frame, k, "ui::CSlot")
            AWWARDROBE_PLAYSLOTANIMATION(frame, k)
        end
        imcSound.PlaySoundEvent('inven_equip');
    end
end
function AWWARDROBE_SAVEEQTOSTRUCTURE()
    local tbl = {}
    local frame = ui.GetFrame(g.framename)
    for k, _ in pairs(g.effectingspot) do
        local slot = GET_CHILD_RECURSIVELY(frame, k, "ui::CSlot")
        local clsid = slot:GetUserValue("clsid")
        local iesid = slot:GetUserValue("iesid")
        if (not EBI_IsNoneOrNil(iesid)) then
            tbl[k] = {clsid = clsid, iesid = iesid}
        end
    end
    return tbl
end
function AWWARDROBE_BTNDELETE_ON_LBUTTONDOWN(frame)
    AWWARDROBE_try(function()
            --現在の設定を消す
            local cbwardrobe = GET_CHILD(frame, "cbwardrobe", "ui::CDropList")
            local curname = cbwardrobe:GetText()
            if (curname == nil) then
                --ui.SysMsg("[AWW]削除する設定がありません");
                --pass
            else
                if(curname==L_("defaultvalue")) then
                    ui.SysMsg(string.format(L_("alertcantdelete"),curname));
                elseif (g.settings.wardrobe[curname]) then
                    g.settings.wardrobe[curname] = nil
                    ui.SysMsg(string.format(L_("alertdeletesettings"),curname));
                else
                    ui.SysMsg(string.format(L_("alertnosettings"),curname));
                end
            end
            AWWARDROBE_UPDATE_DROPBOX()
            AWWARDROBE_UPDATE_DROPBOXAW()
    end)

end
function AWWARDROBE_SLOT_ON_RBUTTONDOWN(frame, ctrl, argstr, argnum)
    --現在の装備を登録
    AWWARDROBE_try(function()
            
            AWWARDROBE_CLEAREQUIP(frame, argstr)
            imcSound.PlaySoundEvent('inven_unequip');
            AWWARDROBE_PLAYSLOTANIMATION(frame, argstr)
    end)
end
function AWWARDROBE_SLOT_ON_DROP(frame, ctrl, argstr, argnum)
    --ドロップされた装備を登録
    AWWARDROBE_try(function()
            --AWWARDROBE_CLEAREQUIP(frame,argstr)
            local liftIcon = ui.GetLiftIcon()
            local liftframe = ui.GetLiftFrame():GetTopParentFrame()
            local slot = tolua.cast(ctrl, 'ui::CSlot')
            
            local iconInfo = liftIcon:GetInfo()
            local invItem = AWWARDROBE_ACQUIRE_ITEM_BY_GUID(iconInfo:GetIESID())
            local invClass = GetClassByType("Item", GetIES(invItem:GetObject()).ClassID)
            local spotname = invClass.DefaultEqpSlot;
            --着用可能部位か調べる
            if (spotname == "RING") then
                if (argstr ~= "RING1" and argstr ~= "RING2") then
                    --NG
                    AWWARDROBE_DBGOUT(tostring(spotname))
                    ui.SysMsg(L_("alertcantequip"))
                    return
                end
            elseif (spotname == "HAT" or spotname == "HAT_L" or spotname == "HAT_T") then
                --exact
                if argstr ~= spotname then
                    --NG
                    ui.SysMsg(L_("alertcantequip"))
                    AWWARDROBE_DBGOUT(tostring(spotname))
                    
                    return
                end
            else
                if (not string.find(spotname, argstr)) then
                    --NG
                    ui.SysMsg(L_("alertcantequip"))
                    AWWARDROBE_DBGOUT(tostring(spotname))
                    
                    return
                end
            end
            
            AWWARDROBE_SETSLOT(slot, invItem)
            imcSound.PlaySoundEvent(equipSound);
            AWWARDROBE_PLAYSLOTANIMATION(frame, argstr)
    end)
end
function AWWARDROBE_SETSLOT(slot, invItem)
    SET_SLOT_INFO_FOR_WAREHOUSE(slot, invItem, "wholeitem")
    
    AWWARDROBE_DBGOUT("C" .. tostring(GetIES(invItem:GetObject()).ClassID))
    AWWARDROBE_DBGOUT("I" .. tostring(invItem:GetIESID()))
    
    slot:SetUserValue("clsid", tostring(GetIES(invItem:GetObject()).ClassID))
    slot:SetUserValue("iesid", tostring(invItem:GetIESID()))


end
function AWWARDROBE_GETCID()
    return info.GetCID(session.GetMyHandle())
end
function AWWARDROBE_ACQUIRE_ITEM_BY_CLASSID(classid)
    local invItem = nil
    invItem = GET_PC_ITEM_BY_TYPE(classid)
    if (invItem ~= nil) then
        return invItem
    end
    return nil
end
function AWWARDROBE_ACQUIRE_ITEM_BY_GUID(guid)
    local invItem = nil
    invItem = GET_ITEM_BY_GUID(guid)
    if (invItem ~= nil) then
        return invItem
    end
    invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, guid)
    if (invItem ~= nil) then
        return invItem
    end
    invItem = session.GetEtcItemByGuid(IT_WAREHOUSE, guid)
    if (invItem ~= nil) then
        return invItem
    end
    return nil
end
function AWWARDROBE_GETEMPTYSLOTCOUNT()
    local awframe = ui.GetFrame("accountwarehouse")
    local s = GET_CHILD_RECURSIVELY(awframe, "itemcnt"):GetTextByKey("cnt")
    local s2 = GET_CHILD_RECURSIVELY(awframe, "itemcnt"):GetTextByKey("slotmax")
    
    AWWARDROBE_DBGOUT(s)
    local remain = tonumber(s2) - tonumber(s)
    return remain
end
function AWWARDROBE_CHANGE_MATCHED(frame, tbl)
    AWWARDROBE_try(function()
        local delay = 0
        local awframe = ui.GetFrame("accountwarehouse")
        local equipItemList = session.GetEquipItemList();
        local items = {}
        if(AWWARDROBE_INTERLOCK())then
        
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        local count = 0
        for _, _ in pairs(tbl) do
            count = count + 1
        end
        --空きがある？
        local remain = AWWARDROBE_GETEMPTYSLOTCOUNT()
        if (remain < count) then
            ui.SysMsg(L_("alertinsufficientslot"))
        else
            for i = 0, equipItemList:Count() - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                local spname = item.GetEquipSpotName(equipItem.equipSpot);
                if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and equipItem.type ~= 0 and tbl[spname] then
                    ReserveScript(string.format("AWWARDROBE_UNWEAR(%d)", equipItem.equipSpot), delay)
                    delay = delay + 0.4
                    items[#items + 1] = equipItem:GetIESID()
                end
            --SET_EQUIP_SLOT_BY_SPOT(frame,equipItem, equipItemList, function()end);
            end
            
            ui.SysMsg(L_("alertchangeequip"))
            AWWARDROBE_INTERLOCK(true)
            --ついでに入れる
            for _, d in ipairs(items) do
                if (items.isLockState) then
                    ReserveScript(string.format("AWWARDROBE_LOCKITEM(\"%s\",0)", d.iesid), delay)
                    delay = delay + 0.4
                end
            end
            --出庫
            session.ResetItemList()
            local count = 0
            local slotset = GET_CHILD_RECURSIVELY(awframe, 'slotset')
            local withdrawn = {}
            local totalcount = 0
            for k, v in pairs(tbl) do
                AWWARDROBE_DBGOUT("OUT " .. v.iesid)
                totalcount = totalcount + 1
                local judge = false
                for j = 0, slotset:GetSlotCount() - 1 do
                    local slot = slotset:GetSlotByIndex(j)
                    if (slot ~= nil) then
                        local Icon = slot:GetIcon()
                        
                        if (Icon ~= nil) then
                            local iconInfo = Icon:GetInfo()
                            if (v.iesid == iconInfo:GetIESID()) then
                                --take
                                session.AddItemID(iconInfo:GetIESID(), 1)
                                --count = count + 1
                                withdrawn[k] = v
                                judge = true
                                break
                            end
                        end
                    end
                end
                if (judge == false) then
                    --検索
                    if (GET_ITEM_BY_GUID(v.iesid)) then
                        judge = true
                    end
                end
                if (judge) then
                    count = count + 1
                end
            end
            if (count < totalcount) then
                ui.SysMsg(L_("alertinsufficientequips"))
            end

            --真っ先に引き出す
            item.TakeItemFromWarehouse_List(
                IT_ACCOUNT_WAREHOUSE,
                session.GetItemIDList(),
                awframe:GetUserIValue('HANDLE')
            )

            --ここから先の処理はディレイを入れる
            delay = delay+2.5
            for k, v in pairs(tbl) do
                --それぞれ装備していく
                ReserveScript(string.format('AWWARDROBE_WEAR("%s","%s")', v.iesid, k), delay)
                delay = delay + 0.5
            end
            for _, d in  ipairs(items) do
                if (GET_ITEM_BY_GUID(d).isLockState) then
                    ReserveScript(string.format("AWWARDROBE_LOCKITEM(\"%s\",0)", d), delay)
                    delay = delay + 0.4
                end
            end
            for _, d in ipairs(items) do

                ReserveScript(string.format("AWWARDROBE_DEPOSITITEM(\"%s\")",  d), delay)
                delay = delay + 0.6
            end
            ReserveScript('ui.SysMsg("'..L_("alertcomplete")..'");AWWARDROBE_INTERLOCK(false)', delay)
        end
    
    
    end)
end
function AWWARDROBE_UNWEAR_MATCHED(frame, tbl)
    AWWARDROBE_try(function()
        local delay = 0
        local awframe = ui.GetFrame("accountwarehouse")
        local equipItemList = session.GetEquipItemList();
        local items = {}
        if(AWWARDROBE_INTERLOCK())then
        
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        local count = 0
        for _, _ in pairs(tbl) do
            count = count + 1
        end
        --空きがある？
        local remain = AWWARDROBE_GETEMPTYSLOTCOUNT()
        if (remain < count) then
            ui.SysMsg(L_("alertinsufficientslot"))
        else
            for i = 0, equipItemList:Count() - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                local spname = item.GetEquipSpotName(equipItem.equipSpot);
                if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and equipItem.type ~= 0 and tbl[spname] then
                    ReserveScript(string.format("AWWARDROBE_UNWEAR(%d)", equipItem.equipSpot), delay)
                    delay = delay + 0.4
                    items[#items + 1] = equipItem:GetIESID()
                end
            --SET_EQUIP_SLOT_BY_SPOT(frame,equipItem, equipItemList, function()end);
            end
            
            ui.SysMsg(L_("alertdeposit"))
            AWWARDROBE_INTERLOCK(true)
            --ついでに入れる
            for _, d in pairs(tbl) do
                --if (GET_ITEM_BY_GUID(d.iesid).isLockState) then
                    ReserveScript(string.format("AWWARDROBE_LOCKITEM(\"%s\",0)", d.iesid), delay)
                    delay = delay + 0.4
                --end
            end
            for _, d in pairs(tbl) do
                
                ReserveScript(string.format("AWWARDROBE_DEPOSITITEM(\"%s\")",  d.iesid), delay)
                delay = delay + 0.6
            end
            ReserveScript('ui.SysMsg("'..L_("alertcomplete")..'");AWWARDROBE_INTERLOCK(false)', delay)
        end
    
    
    end)
end
function AWWARDROBE_INTERLOCK(state)
    if(state ~= nil)then
        g.interlocked=state
    end
    return g.interlocked
end
function AWWARDROBE_UNWEARALL(frame)
    AWWARDROBE_try(function()
        local delay = 0
        local awframe = ui.GetFrame("accountwarehouse")
        local equipItemList = session.GetEquipItemList();
        local items = {}
        if(AWWARDROBE_INTERLOCK())then
        
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        --カウントする
        local count = 0
        for i = 0, equipItemList:Count() - 1 do
            local equipItem = equipItemList:GetEquipItemByIndex(i)
            --local obj = GetIES(item.GetNoneItem(equipItem.equipSpot));
            --CHAT_SYSTEM("GO")
            local spname = item.GetEquipSpotName(equipItem.equipSpot);
            if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and g.effectingspot[spname] then
                count = count + 1
            end
        
        end
        --空きがある？
        local remain = AWWARDROBE_GETEMPTYSLOTCOUNT()
        if (remain < count) then
            ui.SysMsg(L_("alertinsufficientslot"))
        else
            for i = 0, equipItemList:Count() - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                --local obj = GetIES(item.GetNoneItem(equipItem.equipSpot));
                --CHAT_SYSTEM("GO")
                local spname = item.GetEquipSpotName(equipItem.equipSpot);
                if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and g.effectingspot[spname] then
                    ReserveScript(string.format("AWWARDROBE_UNWEAR(%d)", equipItem.equipSpot), delay)
                    delay = delay + 0.4
                    items[#items + 1] = equipItem
                end
            --SET_EQUIP_SLOT_BY_SPOT(frame,equipItem, equipItemList, function()end);
            end
            
            ui.SysMsg(L_("alertunwear"))
            AWWARDROBE_INTERLOCK(true)
            --ついでに入れる
            for _, d in ipairs(items) do
                local obj = d
                --if (d.isLockState) then
                    ReserveScript(string.format("AWWARDROBE_LOCKITEM(\"%s\",0)", obj:GetIESID()), delay)
                    delay = delay + 0.4
                --end
            end
            for _, d in ipairs(items) do
                local obj = d
                ReserveScript(string.format("AWWARDROBE_DEPOSITITEM(\"%s\")", obj:GetIESID()), delay)
                delay = delay + 0.6
            end
            ReserveScript('ui.SysMsg("'..L_("alertcomplete")..'");AWWARDROBE_INTERLOCK(false)', delay)
        end
    
    
    end)
end
function AWWARDROBE_WEAR_MATCHED(frame, tbl)
    AWWARDROBE_try(function()
            
            local awframe = ui.GetFrame("accountwarehouse")
            local equipItemList = session.GetEquipItemList();
            local items = {}
            if(AWWARDROBE_INTERLOCK())then
        
                ui.SysMsg(L_("alertworkingothers"))
                return
            end
            if (awframe:IsVisible() == 0) then
                
                ui.SysMsg(L_("alertopenaw"))
                return
            end
            session.ResetItemList()
            local count = 0
            local slotset = GET_CHILD_RECURSIVELY(awframe, 'slotset')
            local withdrawn = {}
            local totalcount = 0
            for k, v in pairs(tbl) do
                AWWARDROBE_DBGOUT("OUT " .. v.iesid)
                totalcount = totalcount + 1
                local judge = false
                for j = 0, slotset:GetSlotCount() - 1 do
                    local slot = slotset:GetSlotByIndex(j)
                    if (slot ~= nil) then
                        local Icon = slot:GetIcon()
                        
                        if (Icon ~= nil) then
                            local iconInfo = Icon:GetInfo()
                            if (v.iesid == iconInfo:GetIESID()) then
                                --take
                                session.AddItemID(iconInfo:GetIESID(), 1)
                                --count = count + 1
                                withdrawn[k] = v
                                judge = true
                                break
                            end
                        end
                    end
                end
                if (judge == false) then
                    --検索
                    if (GET_ITEM_BY_GUID(v.iesid)) then
                        judge = true
                    end
                end
                if (judge) then
                    count = count + 1
                end
            end
            if (count < totalcount) then
                ui.SysMsg(L_("alertinsufficientequips"))
            else
                ui.SysMsg(L_("alertwithdraw"))
            end
            AWWARDROBE_INTERLOCK(true)
            --真っ先に引き出す
            item.TakeItemFromWarehouse_List(
                IT_ACCOUNT_WAREHOUSE,
                session.GetItemIDList(),
                awframe:GetUserIValue('HANDLE')
            )
            --ここから先の処理はディレイを入れる
            local delay = 2.5
            for k, v in pairs(tbl) do
                --それぞれ装備していく
                ReserveScript(string.format('AWWARDROBE_WEAR("%s","%s")', v.iesid, k), delay)
                delay = delay + 0.5
            end
            ReserveScript('ui.SysMsg("'..L_("alertcomplete")..'"); AWWARDROBE_INTERLOCK(false)', delay)
    end)
end
function AWWARDROBE_WEAR(guid, spot)
    --GUID TO item
    AWWARDROBE_try(function()
        AWWARDROBE_DBGOUT("GUID" .. tostring(guid) .. "SPOT " .. spot)
        local invitem = session.GetInvItemByGuid(guid)
        if (invitem == nil) then
            AWWARDROBE_DBGOUT("FAIL")
            return
        end
        
        ITEM_EQUIP_MSG(invitem, spot)
    --item.Equip(guid,spot)
    --SET_EQUIP_SLOT_BY_SPOT(ui.GetFrame("inventory"), GetIES(invitem:GetObject()), session.GetEquipItemList(), function() end)
    end)
end
function AWWARDROBE_LOCKITEM(itemguid, state)
    if (state == 0) then
        --unlock
        local itemobj = session.GetInvItemByGuid(itemguid)
        if (itemobj.isLockState == true) then
            session.inventory.SendLockItem(itemguid, 0)
        end
    end
end
function AWWARDROBE_DEPOSITITEM(itemguid)
    AWWARDROBE_try(function()
        local awframe = ui.GetFrame("accountwarehouse")
        local gbox = awframe:GetChild("gbox");
        local slotset = GET_CHILD_RECURSIVELY(gbox, "slotset");
        
        if slotset == nil then
            local gbox_warehouse = GET_CHILD_RECURSIVELY(gbox, "gbox_warehouse");
            if gbox_warehouse ~= nil then
                slotset = GET_CHILD_RECURSIVELY(gbox_warehouse, "slotset");
            end
        end
        
        AUTO_CAST(slotset);
        
        local warehouseSlot = GET_EMPTY_SLOT(slotset);
        if warehouseSlot == nil then
            --insufficient
            ui.SysMsg("[AWW]Insufficient Space")
            return
        end
        
        --預入
        local itemObj = session.GetInvItemByGuid(itemguid);
        if(itemObj)then
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, itemguid, 1, awframe:GetUserIValue("HANDLE"));
        end
    end)
end

function AWWARDROBE_UNWEAR(equipSpot)
    imcSound.PlaySoundEvent('inven_unequip');
    local spot = equipSpot;
    item.UnEquip(spot);
end
function AWWARDROBE_REGISTER_CURRENTEQUIP(frame)
    --現在の装備を登録
    AWWARDROBE_try(function()
            --先にクリア
            AWWARDROBE_CLEARALLEQUIPS(frame)
            local equipItemList = session.GetEquipItemList();
            local items = {}
            for i = 0, equipItemList:Count() - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                --local obj = GetIES(item.GetNoneItem(equipItem.equipSpot));
                --CHAT_SYSTEM("GO")
                local spname = item.GetEquipSpotName(equipItem.equipSpot);
                if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and g.effectingspot[spname] then
                    --登録
                    local slot = GET_CHILD_RECURSIVELY(frame, spname, "ui::CSlot")
                    AWWARDROBE_SETSLOT(slot, equipItem)
                    AWWARDROBE_PLAYSLOTANIMATION(frame, spname)
                end
            --SET_EQUIP_SLOT_BY_SPOT(frame,equipItem, equipItemList, function()end);
            end
            imcSound.PlaySoundEvent('inven_equip');
    end)
end
function AWWARDROBE_CLEAREQUIP(frame, spname)
    --現在の装備を登録
    AWWARDROBE_try(function()
            
            local slot = GET_CHILD_RECURSIVELY(frame, spname, "ui::CSlot")
            local slot_bg = GET_CHILD_RECURSIVELY(frame, spname .. "_bg", "ui::CSlot")
            
            slot:ClearIcon()
            slot:SetMaxSelectCount(0)
            slot:SetText('')
            slot:RemoveAllChild()
            slot:SetSkinName(slot_bg:GetSkinName())
            slot:SetUserValue('clsid', nil)
            slot:SetUserValue('iesid', nil)
    
    end)
end
function AWWARDROBE_CLEARALLEQUIPS(frame)
    
    
    for k, _ in pairs(g.effectingspot) do
        AWWARDROBE_CLEAREQUIP(frame, k)
    end

end
function AWWARDROBE_PLAYSLOTANIMATION(frame, spname)
    local child = GET_CHILD_RECURSIVELY(frame, spname .. "ANIM");
    
    if child ~= nil then
        local slot = tolua.cast(child, 'ui::CAnimPicture');
        local slotGbox = slot:GetParent()
        --slot:ForcePlayAnimationReverse();
        slot:PlayAnimation();
    end
end

function AWWARDROBE_SLOTANIM_CHANGEIMG(frame, key, str, cnt)
    if cnt < 4 then
        return;
    end
    local child = GET_CHILD_RECURSIVELY(frame, str, 'ui::CAnimPicture');
    child:ForcePlayAnimationReverse();
    local equipSound = "sys_armor_equip_new";
    imcSound.PlaySoundEvent(equipSound);
end
--チャットコマンド処理（acutil使用時）
function AWWARDROBE_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = "usage{nl}/aww no commands"
        return ui.MsgBox(msg, "", "Nope")
    end
    
    CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
end
function AWWARDROBE_CLOSE()
    ui.GetFrame(g.framename):ShowWindow(0)

--AUTOITEMMANAGE_SAVE_SETTINGS()
end
