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
local LS= LIBSTORAGEHELPERV1_3
--設定ファイル保存先
g.version = 0
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""

g.framename = "awwardrobe"
g.debug = false
g.interlocked = false
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)
g.reservedscript={}
g.effectingspot = {
    HAT_T = true, --コス
    HAT = true, --コス
    HAT_L = true, --コス
    RING1 = true, --ブレスレット
    RING2 = true, --ブレスレット
    RH = true, --左手!
    LH = true, --右手!
    RH2 = true, --左手!
    LH2 = true, --右手!
    GLOVES = true, --グローブ   
    BOOTS = true, --ブーツ
    NECK = true, --ネックレス
    SEAL = true, --エンブレム
    PANTS = true, --下半身
    SHIRT = true, --上半身
	ARK = true    --アーク
}
AWWARDROBE_TBL={}
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
local function EP12()
    if(option.GetCurrentCountry()~="Japanese")then
        return true
    elseif (ui.GetFrame("accountwarehouse"):GetChild("accountwarehouse_tab"))then
        return true
    else
        return false
    end
end
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
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
local function EBI_RemoveWhitespace(str)
    return string.gsub(string.gsub(string.gsub(str,"    ","")," ",""),"　","")
end
local function EBI_IsNoneOrNilOrWhitespace(val)
    return val == nil or val == "None" or val == "nil" or EBI_RemoveWhitespace(val) == ""
end


local function AWWARDROBE_COMPARE(a,b)
    return a.name<b.name
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

local function AWWARDROBE_DBGOUT(msg)
    
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
local function AWWARDROBE_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
local function AWWARDROBE_try(func)
    return EBI_try_catch{
        try = func,
        catch = function(error)
            AWWARDROBE_ERROUT(error)
        end
    }
end
-- local function ReserveScript(str,delay)
--     g.reservedscript[#g.reservedscript+1]={script=str,delay=delay}
   
-- end
-- function AWWARDROBE_ProcessScript()
--     AWWARDROBE_try(function()
--     g.reservedscript=g.reservedscript or {}
--     for k,v in pairs(g.reservedscript) do
--         g.reservedscript[k].delay=v.delay-0.03
--         if(g.reservedscript[k].delay<=0)then
--             assert(loadstring(v.script))()
--             g.reservedscript[k]=nil
--         end
--     end
--     --print("aa")
--     end)
-- end
function AWWARDROBE_SAVE_SETTINGS()
    AWWARDROBE_DBGOUT("SAVE_SETTINGS")
    
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, tostring(AWWARDROBE_GETCID()))
    AWWARDROBE_DBGOUT("psn" .. g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end
function AWWARDROBE_SORTING()
    AWWARDROBE_DBGOUT("SORT")
    table.sort( g.settings.wardrobe,AWWARDROBE_COMPARE)
      
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


    --ソート
    AWWARDROBE_SORTING()
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
    if(g.settings.version==1)then
        -- 配列化する
        local tbl = {}
        for k,d in pairs(g.settings.wardrobe) do
            tbl[#tbl+1] = {name=k,data=d}
        end
        g.settings.wardrobe=tbl
        AWWARDROBE_SORTING()
      
        g.settings.version=2
        CHAT_SYSTEM("[AWW]Settings Verup 1->2")
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
    if(g.personalsettings.version==1)then
        g.personalsettings.version=2
        CHAT_SYSTEM("[AWW]PersonalSettings Verup 1->2")
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
            addon:RegisterMsg('GAME_START', 'AWWARDROBE_GAMESTART')
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
function AWWARDROBE_GAMESTART()
    LS=LIBSTORAGEHELPERV1_3
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
    AWWARDROBE_try(function()
        local frame = ui.GetFrame("accountwarehouse")
        local timer = frame:CreateOrGetControl("timer", "timer", 0, 0, 0, 0)

        --initialize
        local btnawwwithdraw 
        local btnawwdeposit
        local btnawwconfig
        local cbwardrobe
        
        if(EP12())then
            btnawwwithdraw = frame:CreateOrGetControl("button", "btnawwwithdraw", 135, 180, 70, 30)
            btnawwdeposit = frame:CreateOrGetControl("button", "btnawwdeposit", 215, 180, 70, 30)
            btnawwconfig = frame:CreateOrGetControl("button", "btnawwconfig", 295, 180, 70, 30)
            cbwardrobe = frame:CreateOrGetControl("droplist", "cbwardrobe", 135, 160, 250, 20)
        else
            btnawwwithdraw = frame:CreateOrGetControl("button", "btnawwwithdraw", 110, 120, 70, 30)
            btnawwdeposit = frame:CreateOrGetControl("button", "btnawwdeposit", 190, 120, 70, 30)
            btnawwconfig = frame:CreateOrGetControl("button", "btnawwconfig", 350, 120, 70, 30)
            cbwardrobe = frame:CreateOrGetControl("droplist", "cbwardrobe", 110, 100, 250, 20)
        end
        tolua.cast(cbwardrobe, "ui::CDropList")
        btnawwwithdraw:SetText(L_("btnawwwithdraw"))
        btnawwwithdraw:SetTextTooltip(L_("tipbtnawwwithdraw"))
        btnawwwithdraw:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_ON_WITHDRAW")
        btnawwdeposit:SetText(L_("btnawwdeposit"))
        btnawwdeposit:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_ON_DEPOSIT")
        btnawwdeposit:SetTextTooltip(L_("tipbtnawwdeposit"))
        btnawwconfig:SetText(L_("btnawwconfig"))
        btnawwconfig:SetTextTooltip(L_("tipbtnawwconfig"))
        btnawwconfig:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_TOGGLE_FRAME")

        cbwardrobe:SetSkinName("droplist_normal")
        cbwardrobe:SetTextTooltip(L_("tipcbwardrobe"))
        AWWARDROBE_UPDATE_DROPBOXAW()
    
    end)
   
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
        local selected = cbwardrobe:GetSelItemIndex()+1
        local tbl = g.settings.wardrobe[selected]
        if(tbl)then
            g.personalsettings.defaultname =  g.settings.wardrobe[selected].name
            AWWARDROBE_DBGOUT(selected)
            AWWARDROBE_SAVE_SETTINGS()
                    --UNWEAR
            AWWARDROBE_CHANGE_MATCHED(ui.GetFrame(g.framename), tbl.data)
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
        local selected = cbwardrobe:GetSelItemIndex()+1
        local tbl = g.settings.wardrobe[selected]
        if(tbl)then
            g.personalsettings.defaultname =  g.settings.wardrobe[selected].name
            AWWARDROBE_DBGOUT(selected)
            AWWARDROBE_SAVE_SETTINGS()
            --UNWEAR
            AWWARDROBE_UNWEAR_MATCHED(ui.GetFrame(g.framename), tbl.data)
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
        local selected = cbwardrobe:GetSelItemIndex()+1
        local tbl = g.settings.wardrobe[selected]
        if(tbl)then
            g.personalsettings.defaultname =  g.settings.wardrobe[selected].name
            AWWARDROBE_SAVE_SETTINGS()
            --WEAR
            AWWARDROBE_WEAR_MATCHED(ui.GetFrame(g.framename), tbl.data)
        else
            ui.SysMsg(L_("alertplzselect"))
        end
    end)
end




function AWWARDROBE_INITIALIZE_FRAME()
    
    local frame = ui.GetFrame(g.framename);
    
    frame:Resize(600, 550)
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
    local ebname = frame:CreateOrGetControl("edit", "ebname", 20, 430, 250, 30)
    ebname:SetFontName("white_18_ol")
    ebname:SetSkinName("test_weight_skin")
    frame:CreateOrGetControl("richtext", "label2", 20, 400, 80, 20):SetText(L_("labelsettingsname"))
    
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

        for k, d in pairs(g.settings.wardrobe) do
            if(k~=L_("defaultvalue"))then
                cbwardrobe:AddItem(count+1, d.name)
                if (d.name == g.settings.defaultname) then
                    selectindex = count
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
                local count = 0
                local selectindex = nil
                AWWARDROBE_DBGOUT("def" .. tostring(g.personalsettings.defaultname))
                for k, d in pairs(g.settings.wardrobe) do
                    if(k~=L_("defaultvalue"))then
                        acbwardrobe:AddItem(count+1, d.name)
                        if (d.name == g.personalsettings.defaultname) then
                            AWWARDROBE_DBGOUT("match"..tostring(count+1))
                            selectindex = count
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
            local key = cbwardrobe:GetSelItemIndex()
            if (key~="" and not g.settings.wardrobe[key+1]) then
                ui.SysMsg(string.format(L_("alertnosettings"),key));
                return
            end
            
            g.settings.defaultname = g.settings.wardrobe[key+1].name
            
            local sound = not (shutup == true)
            if(key=="")then
                AWWARDROBE_CLEARALLEQUIPS(frame)
            else
                AWWARDROBE_LOADEQFROMSTRUCTURE(g.settings.wardrobe[key+1].data, sound)
            end
            local ebname = GET_CHILD(frame, "ebname", "ui::CEditControl")
            ebname:SetText(g.settings.wardrobe[key+1].name)
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

            --インデックス探索
            local fault=true
            for i=1,#g.settings.wardrobe do
                if(g.settings.wardrobe[i].name==curname) then
                    g.settings.wardrobe[i] = {name=curname,data=table}
                    fault=false
                    break
                end
            end
            if(fault==true)then
                g.settings.wardrobe[#g.settings.wardrobe+1]= {name=curname,data=table}
            end
           
            --ソート
            AWWARDROBE_SORTING()
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
            local curindex= cbwardrobe:GetSelItemIndex()+1
            if (curname == nil) then
                --ui.SysMsg("[AWW]削除する設定がありません");
                --pass
            else
                if(curname==L_("defaultvalue")) then
                    ui.SysMsg(string.format(L_("alertcantdelete"),curname));
                elseif (g.settings.wardrobe[curindex]) then
                    g.settings.wardrobe[curindex].name=nil
                    --詰める
                    local tbl={}
                    for k,d in ipairs(g.settings.wardrobe) do
                        if(d.name~=nil)then
                            tbl[#tbl+1]=d
                            AWWARDROBE_DBGOUT("BBB")
                        end
                    end
                    g.settings.wardrobe=tbl
                    ui.SysMsg(string.format(L_("alertdeletesettings"),curname));
                else
                    ui.SysMsg(string.format(L_("alertnosettings"),curname));
                end
            end
            AWWARDROBE_SAVE_SETTINGS()
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
			if spotname == 'TRINKET' then
				spotname = 'LH'
			end
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
                --fix
                local pos=argstr
                if(argstr:sub(-1)=="2")then
                    pos=argstr:sub(1,2)
                end
                if (string.find(spotname,pos)~=1) then
                
                    --NG
                    ui.SysMsg(L_("alertcantequip"))
                    AWWARDROBE_DBGOUT(tostring(pos).."/"..tostring(spotname))
                    
                    return
                end
                AWWARDROBE_DBGOUT(tostring(pos).."/"..tostring(spotname))
                    
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
    return LS.storageremain()
end
--index = 1 일때 1번창으로 스왑하는 함수. 2일때 2번창으로 스왑하는 함수
function AWWARDROBE_DO_WEAPON_SWAP(index)        
    local frame=ui.GetFrame("inventory")
    if quickslot.IsDoingWeaponSwap() == true then
        return
    end

	if index == nil then
		index = 1
	end
    AWWARDROBE_DBGOUT("SWAP "..tostring(index))
	local pc = GetMyPCObject();
	if pc == nil then
		return;
	end
   
    local frame = ui.GetFrame("inventory");
    local weaponSwap1 = GET_CHILD_RECURSIVELY(frame, "weapon_swap_1")
	local weaponSwap2 = GET_CHILD_RECURSIVELY(frame, "weapon_swap_2")
	local WEAPONSWAP_UP_IMAGE = frame:GetUserConfig('WEAPONSWAP_UP_IMAGE')
	local WEAPONSWAP_DOWN_IMAGE = frame:GetUserConfig('WEAPONSWAP_DOWN_IMAGE')

	if index == 1 then
		weaponSwap1:SetImage(WEAPONSWAP_UP_IMAGE);
		weaponSwap2:SetImage(WEAPONSWAP_DOWN_IMAGE);
	elseif index == 2 then
		weaponSwap1:SetImage(WEAPONSWAP_DOWN_IMAGE);
		weaponSwap2:SetImage(WEAPONSWAP_UP_IMAGE);
	end

	if frame:GetUserIValue('CURRENT_WEAPON_INDEX') == index then
		return;
	end

	frame:SetUserValue('CURRENT_WEAPON_INDEX', index);

    quickslot.SwapWeapon()    

    local abil = GetAbility(pc, "SwapWeapon");

	if abil ~= nil then
		weaponSwap1:ShowWindow(1);
		weaponSwap2:ShowWindow(1);
	else
		weaponSwap1:ShowWindow(0);
		weaponSwap2:ShowWindow(0);
	end
    
	local tempIndex = 0;
	if index == 1 then
		tempIndex = 2
	elseif index == 2 then
		tempIndex = 0
	end

	SHOW_WEAPON_SWAP_TEMP_IMAGE(frame:GetUserIValue('CURRENT_WEAPON_RH'), frame:GetUserIValue('CURRENT_WEAPON_LH'), tempIndex)
end
function AWWARDROBE_UNWEAR_MATCHED(frame, tbl)
    AWWARDROBE_try(function()
        local delay = 0
        local awframe = ui.GetFrame("accountwarehouse")
        
        local items = {}
        if(AWWARDROBE_INTERLOCK())then
        
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end


        local equipItemList = session.GetEquipItemList();
        local count = 0
        local needtoswap=false
        for k, _ in pairs(tbl) do
            if (k=="RH2" or k=="LH2")then
                AWWARDROBE_DBGOUT("NEEDTOSWAP")
                needtoswap=true
            end
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
				if spname == 'TRINKET' then
					spname = 'LH'
                end
               
                if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and equipItem.type ~= 0 and tbl[spname] then
           
                    -- if(not needtoswap or spname ~= "LH" and spname ~="RH" )then
                        ReserveScript(string.format("AWWARDROBE_UNWEARBYGUID(\"%s\")", equipItem:GetIESID()), delay)
                        delay = delay + 0.5
                        items[#items + 1] = equipItem
                    --end
                end

            end

            
            ui.SysMsg(L_("alertdeposit"))
            AWWARDROBE_INTERLOCK(true)
            --ついでに入れる
            
            for _, d in pairs(tbl) do
                --ロックされているアイテムは入れない
                local invItem=GET_PC_ITEM_BY_GUID(d.iesid)
                if(invItem~=nil and true ~= invItem.isLockState)then
                    ReserveScript(string.format("AWWARDROBE_DEPOSITITEM(\"%s\")",  d.iesid), delay)
                    delay = delay + 0.6
                end
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


function AWWARDROBE_WEAR_MATCHED(frame, tbl)
    AWWARDROBE_try(function()
            
            local awframe = ui.GetFrame("accountwarehouse")
            
            
            if(AWWARDROBE_INTERLOCK())then
        
                ui.SysMsg(L_("alertworkingothers"))
                return
            end
            if (awframe:IsVisible() == 0) then
                
                ui.SysMsg(L_("alertopenaw"))
                return
            end

            local equipItemList = session.GetEquipItemList();
           
            local count = 0
            local withdrawn = {}
            local totalcount = #tbl
            local items={}
            for iesid,invItem,invObj in LS.items() do
                
                local judge = false

                for k,v in pairs(tbl) do

                    if (iesid == v.iesid) then
                        --take
                        items[#items+1] = {
                            iesid=iesid,
                            count=1
                        }

                        judge = true 
                        break
                    end
                end
                if (judge == false) then
                    --検索
                    if (GET_PC_ITEM_BY_GUID(iesid)) then
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
            LS.takeitems(items)
            

            --ここから先の処理はディレイを入れる
            local delay = 2.5
            local needtoswap=false
            ReserveScript("AWWARDROBE_DO_WEAPON_SWAP(1)",delay)
            delay = delay + 0.25
            
            for k, v in pairs(tbl) do
                --それぞれ装備していく
                if(k~="RH2" and k~="LH2")then
                    ReserveScript(string.format('AWWARDROBE_WEAR("%s","%s")', v.iesid, k), delay)
                else
                    needtoswap=true
                end
                delay = delay + 0.5
            end
            if(needtoswap)then
                AWWARDROBE_DBGOUT("NEEDTOSWAP")
                ReserveScript("AWWARDROBE_DO_WEAPON_SWAP(2)",delay)
                delay = delay + 0.25
                for k, v in pairs(tbl) do
                    --それぞれ装備していく
                    if(k=="RH2" or k=="LH2")then
                        ReserveScript(string.format('AWWARDROBE_WEAR("%s","%s")', v.iesid, k:sub(1,-2)), delay)
                    end
                    delay = delay + 0.5
                end
                ReserveScript("AWWARDROBE_DO_WEAPON_SWAP(1)",delay)
                delay = delay + 0.25
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
        

    end)
end

function AWWARDROBE_WEARSWAP(guid, spot)
    --GUID TO item
    AWWARDROBE_try(function()
        AWWARDROBE_DBGOUT("GUID" .. tostring(guid) .. "SPOT " .. spot)
        local invitem = session.GetInvItemByGuid(guid)
        if (invitem == nil) then
            AWWARDROBE_DBGOUT("FAILS")
            return
        end
        local table={
            LH="LH",
            RH="RH",
            LH2="LH",
            RH2="RH",
            
        }
        AWWARDROBE_WEAPONSWAP_ITEM_DROP(table[spot], guid);
  
    end)
end
function AWWARDROBE_WEAPONSWAP_ITEM_DROP(spot,guid)
	local frame = ui.GetFrame("inventory");


	local invItem = GET_PC_ITEM_BY_GUID(guid);

	if invItem == nil then
		return;
	end
    
    

    local slot;
    if(spot=="LH" or spot=="LH2" )then
        slot=GET_CHILD_RECURSIVELY(frame,"LH")
    elseif(spot=="RH" or spot=="RH2" )then
        slot=GET_CHILD_RECURSIVELY(frame,"RH")
    end
	if nil == slot then
		return;
	end

	local obj = GetIES(invItem:GetObject());
	if	obj.DefaultEqpSlot == "RH" or  obj.DefaultEqpSlot == "LH" or obj.DefaultEqpSlot == "RH LH" or obj.DefaultEqpSlot == "TRINKET" then
		-- 슬롯은 좌우 두개므로
		local offset = 2;
		-- 일단 슬롯 위치가, 왼쪽오른쪽인지를 확인
		if slot:GetSlotIndex() % offset == 0 then
			
			if obj.DefaultEqpSlot ~= "RH" and obj.DefaultEqpSlot ~= "RH LH" then
				return;
			end
		end

		if slot:GetSlotIndex() % offset == 1 and obj.DefaultEqpSlot ~= "LH" and obj.DefaultEqpSlot ~="TRINKET" then
			local pc = GetMyPCObject();
			if pc == nil then
				return;
			end

			local clsType = TryGetProp(obj, "ClassType2");
			if clsType ~= "Sword" then
				return;
			end

			local abil = GetAbility(pc, "SubSword");
			if abil == nil then
				return;
			end
		end
	
		local bodyGbox = frame:GetChild("bodyGbox");
		if nil == bodyGbox then
			return;
		end
	
		-- 양손무기를 체크하자
		TH_WEAPON_CHECK(obj, bodyGbox, slot:GetSlotIndex());
		quickslot.SetSwapWeaponInfo(slot:GetSlotIndex(), invItem:GetIESID());
		SET_SLOT_ITEM_IMAGE(slot, invItem);
	end
end
-- function AWWARDROBE_LOCKITEM(itemguid, state)

--     --unlock
--     local itemobj = session.GetInvItemByGuid(itemguid)
--     if(itemobj==nil)then
--         itemobj=session.GetEquipItemByGuid(itemguid)
--     end
--     if(itemobj~=nil)then
--         if (itemobj.isLockState == true) then
--             session.inventory.SendLockItem(itemguid,state)
--         end
--     end

-- end
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
            LS.putitem(itemguid,1)
        end
    end)
end
function AWWARDROBE_UNWEARBYGUID(guid)
    
    AWWARDROBE_DBGOUT("UNWEARa"..guid)
    local equipItem =GET_PC_ITEM_BY_GUID(guid)
    if(equipItem~=nil)then
        local obj = GetIES(equipItem:GetObject());
        --CHAT_SYSTEM("GO")
        local spname
        if(equipItem.equipSpot~=nil)then
            AWWARDROBE_DBGOUT("UNWEAR A"..equipItem.equipSpot)
            spname=item.GetEquipSpotName(equipItem.equipSpot);
            AWWARDROBE_UNWEAR(equipItem.equipSpot)
        else
            local s=nil
            if(guid==quickslot.GetSwapWeaponGuid(0))then
                s=0
            elseif(guid==quickslot.GetSwapWeaponGuid(1))then
                s=1
            elseif(guid==quickslot.GetSwapWeaponGuid(2))then
                s=2
            elseif(guid==quickslot.GetSwapWeaponGuid(3))then
                s=3
            end   
            AWWARDROBE_DBGOUT("UNWEAR"..tostring(s))
            if s~=nil then
                AWWARDROBE_DBGOUT("UNWEAR DO"..tostring(s))
                imcSound.PlaySoundEvent('inven_unequip');

                quickslot.SetSwapWeaponInfo(s,"");
            end
        end
        
    else
        AWWARDROBE_DBGOUT(tostring(guid).."notfound")
    end
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
                if spname~="RH" and spname ~= "LH" and equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and g.effectingspot[spname] then
                    --登録
                    local slot = GET_CHILD_RECURSIVELY(frame, spname, "ui::CSlot")
                    AWWARDROBE_SETSLOT(slot, equipItem)
                    AWWARDROBE_PLAYSLOTANIMATION(frame, spname)
                end
                --左手右手用設定
                local rh1 = quickslot.GetSwapWeaponGuid(2);
                local lh1 = quickslot.GetSwapWeaponGuid(3);
                local rh2 = quickslot.GetSwapWeaponGuid(0);
                local lh2 = quickslot.GetSwapWeaponGuid(1);

                if rh1~=nil then
                    local item=GET_ITEM_BY_GUID(rh1);
                    if item ~= nil then
                        local quickspname="RH"
                        local slot = GET_CHILD_RECURSIVELY(frame, quickspname, "ui::CSlot")
                        AWWARDROBE_SETSLOT(slot, item)
                        AWWARDROBE_PLAYSLOTANIMATION(frame, quickspname)
                    end
                end
                if lh1~=nil then
                    local item=GET_ITEM_BY_GUID(lh1);
                    if item ~= nil then
                        local quickspname="LH"
                        local slot = GET_CHILD_RECURSIVELY(frame, quickspname, "ui::CSlot")
                        AWWARDROBE_SETSLOT(slot, item)
                        AWWARDROBE_PLAYSLOTANIMATION(frame, quickspname)
                    end
                end
                if rh2~=nil then
                    local item=GET_ITEM_BY_GUID(rh2);
                    if item ~= nil then
                        local quickspname="RH2"
                        local slot = GET_CHILD_RECURSIVELY(frame, quickspname, "ui::CSlot")
                        AWWARDROBE_SETSLOT(slot, item)
                        AWWARDROBE_PLAYSLOTANIMATION(frame, quickspname)
                    end
                end
                if lh2~=nil then
                    local item=GET_ITEM_BY_GUID(lh2);
                    if item ~= nil then
                        local quickspname="LH2"
                        local slot = GET_CHILD_RECURSIVELY(frame, quickspname, "ui::CSlot")
                        AWWARDROBE_SETSLOT(slot, item)
                        AWWARDROBE_PLAYSLOTANIMATION(frame, quickspname)
                    end
                end
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