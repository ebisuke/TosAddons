--AWWARDROBE
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
local LS = LIBSTORAGEHELPERV1_3
--設定ファイル保存先
local TAB_EQUIP = 0
local TAB_CARD = 1
local TAB_IKOR = 2
local TAB_COUNT = 3

local slotsetnames = {
    'ATKcard_slotset',
    'DEFcard_slotset',
    'UTILcard_slotset',
    'STATcard_slotset',
    'LEGcard_slotset',
}
--- Iterate over the sorted elements from an iterable.
--
-- A custom `key` function can be supplied, and it will be applied to each
-- element being compared to obtain a sorting key, which will be the values
-- used for comparisons when sorting. The `reverse` flag can be set to sort
-- the elements in descending order.
--
-- Note that `iterable` must be consumed before sorting, so the returned
-- iterator runs in *O(n)* memory space. Sorting is done internally using
-- `table.sort`.
--
-- @tparam coroutine iterable An iterator.
-- @tparam[opt] function key Function used to retrieve the sorting key used
--   to compare elements.
-- @tparam[opt] boolean reverse Whether to yield the elements in reverse
--   (descending) order. If not supplied, defaults to `false`.
-- @treturn coroutine An iterator over the sorted elements.
--
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.tab_aw = TAB_EQUIP
g.tab_config = TAB_EQUIP
g.max_cards = 13 --カードの最大値
g.framename = "awwardrobe"
g.debug = false
g.interlocked = false
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)
g.reservedscript = {}
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
    ARK = true --アーク
}
g.effectingikorspot = {
    RH = true, --左手!
    LH = true, --右手!
    -- RH2 = true, --左手!
    -- LH2 = true, --右手!
    GLOVES = true, --グローブ
    BOOTS = true, --ブーツ
    PANTS = true, --下半身
    SHIRT = true, --上半身
}
g.tempitemlist = {}--アイテム情報一時置き

AWWARDROBE_TBL = {}
local translationtable = {
        
        btnawwwithdraw = {jp = "引出", eng = "Withdraw"},
        btnawwdeposit = {jp = "預入", eng = "Deposit"},
        btnawwchange = {jp = "入替", eng = "Swap"},
        btnawwconfig = {jp = "AWW設定", eng = "AWW Conf"},
        tipbtnawwwithdraw = {jp = "指定した装備セットを倉庫から引き出し、装備します", eng = "Withdraws and equips the specified equipment set from the account storage."},
        tipbtnawwdeposit = {jp = "指定した装備セットの装備と装着位置が一致する装備を外し、倉庫に預けます", eng = "Remove the equipment that matches the equipment position of the specified equipment set {nl} and deposit it in the account storage."},
        tipbtnawwchange = {jp = "指定した装備セットの装備と入れ替えます", eng = "Swap with the equipment of the specified equipment set."},
        tipbtnawwconfig = {jp = "AWWの設定画面を開きます", eng = "Show the setting frame of AWW."},
        tipcbwardrobe = {jp = "AWWで交換する装備セットを指定します", eng = "Specify the equipment set to be swapped by AWW."},
        btnregister = {jp = "現在の装備をセット", eng = "Set Current Equips"},
        btnclear = {jp = "装備をリセット", eng = "Clear Settings"},
        
        btnsave = {jp = "設定保存", eng = "Save Settings"},
        btndelete = {jp = "{#FF6666}設定削除", eng = "{#FF6666}Delete Settings"},
        labelsettingsname = {jp = "{ol}保存する設定名:", eng = "{ol}Settings Name:"},
        labelcurrentsettings = {jp = "{ol}現在の設定:", eng = "{ol}Settings:"},
        defaultvalue = {jp = "(デフォルト)", eng = "(default)"},
        alertnosettings = {jp = "[AWW]設定 %s は存在しません", eng = "[AWW]Settings %s not found."},
        alertcantdelete = {jp = "[AWW]設定 %s は削除できません", eng = "[AWW]Settings %s cannot delete."},
        alertinvalidname = {jp = "[AWW]有効な名前を入れてください", eng = "[AWW]Invalid name."},
        alertsettingssaved = {jp = "[AWW]設定 %s 保存しました", eng = "[AWW]Settings %s saved."},
        alertnodeletesettings = {jp = "[AWW]設定 %s がないです", eng = "[AWW]Settings %s not found."},
        alertdeletesettings = {jp = "[AWW]設定 %s を削除しました", eng = "[AWW]Settings %s deleted."},
        alertcantequip = {jp = "[AWW]この部位には装着できません", eng = "[AWW]Cannot be equipped on that part."},
        alertworkingothers = {jp = "[AWW]他が動作中です", eng = "[AWW]Other processing is in progress."},
        alertopenaw = {jp = "[AWW]チーム倉庫画面を開いてください", eng = "[AWW]Please open the account storage."},
        alertinsufficientslot = {jp = "[AWW]チーム倉庫の空きが足りません", eng = "[AWW]Insufficient empty slot."},
        alertchangeequip = {jp = "[AWW]設定と一致した装備を入れ替えます", eng = "[AWW]Swap equips."},
        alertinsufficientequips = {jp = "[AWW]足りない装備がありますが、このまま続行します", eng = "[AWW]Not enough equipment but continue."},
        alertcomplete = {jp = "[AWW]終わりました", eng = "[AWW]Complete."},
        alertdeposit = {jp = "[AWW]設定と一致した個所を脱ぎます", eng = "[AWW]Deposit equips."},
        alertwithdraw = {jp = "[AWW]倉庫・インベントリから装備します", eng = "[AWW]Withdraw and wear equips."},
        alertunwear = {jp = "[AWW]全部脱ぎます", eng = "[AWW]Unwear equips."},
        alertplzselect = {jp = "[AWW]装備セットを選択してください", eng = "[AWW]Please select an equipment set."},
        alertstart = {jp = "[AWW]開始しました", eng = "[AWW]Started."},
        tabequip = {jp = "装備", eng = "Equip"},
        tabcard = {jp = "カード", eng = "Card"},
        tabikor = {jp = "イコル", eng = "Icor"},
        dlgcarddetach = {jp = "カードを取り外しますか？費用は自動的にチーム倉庫から引き出されます。{nl}費用:%d", eng = "Do you want to remove cards?{nl}Cost:%d"},
        dlgcardattach = {jp = "既存のカードを取り外し、設定したカードを取り付けますか？費用は自動的にチーム倉庫から引き出されます。{nl}費用:%d", eng = "Do you want to remove the existing card and install the configured card?{nl}Cost:%d"},
        dlgikordetach = {jp = "合致するイコルを自動で取り外しますか？費用は自動的にチーム倉庫から引き出されます。{nl}費用:%d", eng = "Do you want to remove icors?{nl}Cost:%d"},
        dlgikorattach = {jp = "イコルを自動で取り付けますか？すでに装着済みのイコルは外されます。費用は自動的にチーム倉庫から引き出されます。{nl}費用:%d", eng = "Do you want to attach icors?{nl}Cost:%d"},
        
        insufficientsilver = {jp = "シルバーが足りません。", eng = "Insufficient silver."},
        needtoken = {jp = "この機能を使用するには課金トークンが有効になっている必要があります", eng = "The token must be enabled in order to use this feature."},
}
local function EP12()
    if (option.GetCurrentCountry() ~= "Japanese") then
        return true
    elseif (ui.GetFrame("accountwarehouse"):GetChild("accountwarehouse_tab")) then
        return true
    else
        return false
    end
end
local function L_(str)
    if (option.GetCurrentCountry() == "Japanese") then
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
    return string.gsub(string.gsub(string.gsub(str, "    ", ""), " ", ""), "　", "")
end
local function EBI_IsNoneOrNilOrWhitespace(val)
    return val == nil or val == "None" or val == "nil" or EBI_RemoveWhitespace(val) == ""
end


local function AWWARDROBE_COMPARE(a, b)
    return a.name < b.name
end

function AWWARDROBE_DEFAULTSETTINGS()
    return {
        version = g.version,
        wardrobe = {
        },
        wardrobecard = {
        
        },
        wardrobeikor = {
        
        },
        defaultname = nil,
        defaultname = nil
    }

end
function AWWARDROBE_DEFAULTPERSONALSETTINGS()
    return {
        version = g.version,
        defaultname = nil,
        defaultname = nil
    }
end
--デフォルト設定
if (not g.loaded) then
    --シンタックス用に残す
    g.settings = {
        version = nil,
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
    table.sort(g.settings.wardrobe, AWWARDROBE_COMPARE)
    table.sort(g.settings.wardrobecard, AWWARDROBE_COMPARE)

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
    for k, v in pairs(g.settings.wardrobe) do
        if (EBI_IsNoneOrNilOrWhitespace(k)) then
            g.settings.wardrobe[k] = nil
        
        end
    end
end
function AWWARDROBE_UPGRADE_SETTINGS()
    local upgraded = false
    if (not g.settings.version or g.settings.version == 0) then
        g.settings.wardrobe[L_("defaultvalue")] = {}
        g.settings.version = 1
        CHAT_SYSTEM("[AWW]Settings Verup 0->1")
        upgraded = true;
    end
    if (g.settings.version == 1) then
        -- 配列化する
        local tbl = {}
        for k, d in pairs(g.settings.wardrobe) do
            tbl[#tbl + 1] = {name = k, data = d}
        end
        g.settings.wardrobe = tbl
        AWWARDROBE_SORTING()
        
        g.settings.version = 2
        CHAT_SYSTEM("[AWW]Settings Verup 1->2")
        upgraded = true;
    end
    if (g.settings.version == 2) then
        -- 配列化する
        local tbl = {}
        
        g.settings.wardrobecard = {
            {name = L_("defaultvalue"), data = {}}
        }
        AWWARDROBE_SORTING()
        
        g.settings.version = 3
        CHAT_SYSTEM("[AWW]Settings Verup 2->3")
        upgraded = true;
    end
    if (g.settings.version == 3) then
        -- 配列化する
        local tbl = {}
        
        g.settings.wardrobeikor = {
            {name = L_("defaultvalue"), data = {}}
        }
        AWWARDROBE_SORTING()
        
        g.settings.version = 4
        CHAT_SYSTEM("[AWW]Settings Verup 3->4")
        upgraded = true;
    end
    return upgraded
end
function AWWARDROBE_UPGRADE_PERSONALSETTINGS()
    local upgraded = false
    if (not g.personalsettings.version or g.personalsettings.version == 0) then
        g.personalsettings.version = 1
        CHAT_SYSTEM("[AWW]PersonalSettings Verup 0->1")
        upgraded = true
    end
    if (g.personalsettings.version == 1) then
        g.personalsettings.version = 2
        CHAT_SYSTEM("[AWW]PersonalSettings Verup 1->2")
        upgraded = true
    end
    if (g.personalsettings.version == 2) then
        g.personalsettings.version = 3
        g.personalsettings.defaultnamecard = L_("defaultvalue")
        CHAT_SYSTEM("[AWW]PersonalSettings Verup 2->3")
        upgraded = true
    end
    if (g.personalsettings.version == 3) then
        g.personalsettings.version = 4
        g.personalsettings.defaultnameikor = L_("defaultvalue")
        CHAT_SYSTEM("[AWW]PersonalSettings Verup 3->4")
        upgraded = true
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
            g.interlocked = false
        
        end,
        catch = function(error)
            AWWARDROBE_ERROUT(error)
        end
    }
end
function AWWARDROBE_GAMESTART()
    LS = LIBSTORAGEHELPERV1_3
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
        local btnregister
        
        btnawwwithdraw = frame:CreateOrGetControl("button", "btnawwwithdraw", 135, 180, 70, 30)
        btnawwdeposit = frame:CreateOrGetControl("button", "btnawwdeposit", 215, 180, 70, 30)
        btnawwconfig = frame:CreateOrGetControl("button", "btnawwconfig", 295, 180, 70, 30)
        cbwardrobe = frame:CreateOrGetControl("droplist", "cbwardrobe", 135, 160, 250, 20)
        btnregister = frame:CreateOrGetControl("button", "btntab", 75, 155, 50, 30)
        
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
        
        btnregister:SetText(L_("tabequip"))
        btnregister:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_AW_ON_TAB")
        g.tab_aw = TAB_EQUIP
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

function AWWARDROBE_ON_DEPOSIT()
    AWWARDROBE_try(function()
        local awframe = ui.GetFrame("accountwarehouse")
        --選択しているものを取得
        local cbwardrobe = GET_CHILD(awframe, "cbwardrobe", "ui::CDropList")
        local selected = cbwardrobe:GetSelItemIndex() + 1
        
        if g.tab_aw == TAB_EQUIP then
            local tbl = g.settings.wardrobe[selected]
            
            if (tbl) then
                g.personalsettings.defaultname = g.settings.wardrobe[selected].name
                AWWARDROBE_DBGOUT(selected)
                AWWARDROBE_SAVE_SETTINGS()
                --UNWEAR
                AWWARDROBE_UNWEAR_MATCHED(ui.GetFrame(g.framename), tbl.data)
            else
                ui.SysMsg(L_("alertplzselect"))
            end
        elseif g.tab_aw == TAB_CARD then
            local tbl = g.settings.wardrobecard[selected]
            
            if (tbl) then
                g.personalsettings.defaultnamecard = g.settings.wardrobecard[selected].name
                AWWARDROBE_SAVE_SETTINGS()
                --WEAR
                ui.MsgBox(string.format(L_('dlgcarddetach'), AWWARDROBE_CALCULATE_SILVER_DETACH(tbl.data)),
                    string.format('AWWARDROBE_DETACH_CARDS(nil,AWWARDROBE_GET_CARDDATABYINDEX(%d))', selected), 'None')
            else
                ui.SysMsg(L_("alertplzselect"))
            end
        elseif g.tab_aw == TAB_IKOR then
            local tbl = g.settings.wardrobeikor[selected]
            
            if (tbl) then
                g.personalsettings.defaultnameikor = g.settings.wardrobeikor[selected].name
                AWWARDROBE_SAVE_SETTINGS()
                --WEAR
                --@TODO need to calc
                ui.MsgBox(string.format(L_('dlgikordetach'), AWWARDROBE_CALCULATE_SILVER_IKORDETACH(tbl.data)),
                    string.format('AWWARDROBE_DETACH_IKOR(AWWARDROBE_GET_IKORDATABYINDEX(%d))', selected), 'None')
            --AWWARDROBE_DETACH_IKOR(tbl.data)
            else
                ui.SysMsg(L_("alertplzselect"))
            end
        end
    
    
    end)
end

function AWWARDROBE_ON_WITHDRAW()
    AWWARDROBE_try(function()
        local awframe = ui.GetFrame("accountwarehouse")
        --選択しているものを取得
        local cbwardrobe = GET_CHILD(awframe, "cbwardrobe", "ui::CDropList")
        local selected = cbwardrobe:GetSelItemIndex() + 1
        if g.tab_aw == TAB_EQUIP then
            local tbl = g.settings.wardrobe[selected]
            if (tbl) then
                
                
                g.personalsettings.defaultname = g.settings.wardrobe[selected].name
                AWWARDROBE_SAVE_SETTINGS()
                --WEAR
                AWWARDROBE_WEAR_MATCHED(ui.GetFrame(g.framename), tbl.data)
            
            else
                ui.SysMsg(L_("alertplzselect"))
            end
        
        elseif g.tab_aw == TAB_CARD then
            local tbl = g.settings.wardrobecard[selected]
            if (tbl) then
                g.personalsettings.defaultnamecard = g.settings.wardrobecard[selected].name
                AWWARDROBE_SAVE_SETTINGS()
                --WEAR
                --AWWARDROBE_ATTACH_CARDS(ui.GetFrame(g.framename), tbl.data)
                ui.MsgBox(string.format(L_('dlgcardattach'), AWWARDROBE_CALCULATE_SILVER_ATTACH(tbl.data)),
                    string.format('AWWARDROBE_ATTACH_CARDS(nil,AWWARDROBE_GET_CARDDATABYINDEX(%d))', selected), 'None')
            
            else
                ui.SysMsg(L_("alertplzselect"))
            end
        elseif g.tab_aw == TAB_IKOR then
            local tbl = g.settings.wardrobeikor[selected]
            if (tbl) then
                g.personalsettings.defaultnameikor = g.settings.wardrobeikor[selected].name
                AWWARDROBE_SAVE_SETTINGS()
                --WEAR
                --AWWARDROBE_ATTACH_CARDS(ui.GetFrame(g.framename), tbl.data)
                ui.MsgBox(string.format(L_('dlgikorattach'), AWWARDROBE_CALCULATE_SILVER_IKORATTACH(tbl.data)),
                string.format('AWWARDROBE_ATTACH_IKOR(AWWARDROBE_GET_IKORDATABYINDEX(%d))', selected), 'None')
        
                --AWWARDROBE_ATTACH_IKOR(tbl.data)
            else
                ui.SysMsg(L_("alertplzselect"))
            end
        end
    
    
    end)
end

function AWWARDROBE_GET_CARDDATABYINDEX(index)
    return g.settings.wardrobecard[index].data
end
function AWWARDROBE_GET_IKORDATABYINDEX(index)
    return g.settings.wardrobeikor[index].data
end
function AWWARDROBE_DETACH_CARDS(frame, tbl)
    AWWARDROBE_try(function()
        local delay = 1
        local awframe = ui.GetFrame("accountwarehouse")
        
        local items = {}
        if (AWWARDROBE_INTERLOCK()) then
            
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        ui.SysMsg(L_("alertstart"))
        
        AWWARDROBE_INTERLOCK(true)
        local needzeny, todetach = AWWARDROBE_CALCULATE_SILVER_DETACH(tbl)
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'ClassName', Value = MONEY_NAME}}, false, itemList);
        local visItem = visItemList[1];
        
        local accountsilver = '0'
        if visItem == nil or GETMYPCLEVEL() >= 15 and true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
            accountsilver = visItem:GetAmountStr()
        end
        
        local zeny = SumForBigNumberInt64(GET_TOTAL_MONEY_STR(), accountsilver)
        --足りる?
        if IsGreaterThanForBigNumber(needzeny, zeny) == 1 then
            ui.SysMsg(L_("insufficientsilver"))
            return
        end
        
        --DO
        ui.SysMsg(L_("alertstart"))
        AWWARDROBE_INTERLOCK(true)
        
        --費用を引き出す
        if IsGreaterThanForBigNumber(needzeny, accountsilver) == 1 then
            accountsilver = needzeny
        end
        if IsGreaterThanForBigNumber(accountsilver, '0') == 1 then
            ReserveScript(string.format([[AWWARDROBE_TAKESILVER('%s')]], needzeny), delay)
            delay = delay + 1
        end
        for i = 1, g.max_cards do
            for k, v in pairs(todetach) do
                
                --カードを外す
                local cardInfo = equipcard.GetCardInfo(i);
                if cardInfo and v and v.count > 0 and v.clsid == cardInfo:GetCardID() and v.lv == cardInfo.cardLv then
                    AWWARDROBE_DBGOUT('UNEQ' .. i)
                    ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", tostring(%d)..' 1');]], i - 1), delay)
                    delay = delay + 1
                    todetach[k].count = todetach[k].count - 1
                    
                    break
                end
            
            end
        end
        --預ける
        for _, v in pairs(tbl) do
            if v and v.clsid ~= 0 then
                ReserveScript(string.format([[AWWARDROBE_DEPOSITCARD(%d,%d)]], v.clsid, v.lv), delay)
                delay = delay + 0.75
            end
        end
        ReserveScript('ui.SysMsg("' .. L_("alertcomplete") .. '");AWWARDROBE_INTERLOCK(false)', delay)
    end)
end
function AWWARDROBE_TAKESILVER(silver)
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    
    local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'ClassName', Value = MONEY_NAME}}, false, itemList);
    local visItem = visItemList[1];
    session.ResetItemList();
    
    session.AddItemIDWithAmount(visItem:GetIESID(), silver);
    local frame = ui.GetFrame('accountwarehouse')
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
end
function AWWARDROBE_DEPOSITCARD(clsid, lv)
    local invItem = AWWARDROBE_FINDINVITEMBYTYPEANDLEVEL(clsid, lv)
    if (invItem ~= nil and true ~= invItem.isLockState) then
        AWWARDROBE_DEPOSITITEM(invItem:GetIESID())
    end
end
function AWWARDROBE_FINDINVITEMBYTYPEANDLEVEL(clsid, lv)
    AWWARDROBE_DBGOUT('' .. clsid .. '/' .. lv)
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = invItemList:GetItemByGuid(guid)
        
        if invItem.type == clsid then
            AWWARDROBE_DBGOUT('pp' .. invItem.type)
            local elv = GET_ITEM_LEVEL_EXP(GetIES(invItem:GetObject()))
            AWWARDROBE_DBGOUT('' .. invItem.type .. '-/' .. elv)
            if elv == lv then
                AWWARDROBE_DBGOUT('GUID' .. tostring(guid))
                return invItem
            end
        end
    end
    AWWARDROBE_DBGOUT('nil')
    return nil
end

function AWWARDROBE_ATTACH_CARDS(frame, tbl)
    AWWARDROBE_try(function()
        local delay = 1
        local awframe = ui.GetFrame("accountwarehouse")
        
        local items = {}
        if (AWWARDROBE_INTERLOCK()) then
            
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        
        local needzeny, toattach, toremove = AWWARDROBE_CALCULATE_SILVER_ATTACH(tbl)
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'ClassName', Value = MONEY_NAME}}, false, itemList);
        local visItem = visItemList[1];
        
        local accountsilver = '0'
        if visItem ~= nil and GETMYPCLEVEL() >= 15 and true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
            accountsilver = visItem:GetAmountStr()
        end
        
        local zeny = SumForBigNumberInt64(GET_TOTAL_MONEY_STR(), accountsilver)
        --足りる?
        if IsGreaterThanForBigNumber(needzeny, zeny) == 1 then
            ui.SysMsg(L_("insufficientsilver"))
            return
        end
        
        ui.SysMsg(L_("alertstart"))
        AWWARDROBE_INTERLOCK(true)
        --費用を引き出す
        if IsGreaterThanForBigNumber(needzeny, accountsilver) == 1 then
            accountsilver = needzeny
        end
        if IsGreaterThanForBigNumber(accountsilver, '0') == 1 then
            ReserveScript(string.format([[AWWARDROBE_TAKESILVER('%s')]], needzeny), delay)
            delay = delay + 0.5
        end
        
        --引き出す
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local guidList = itemList:GetGuidList();
        local sortedGuidList = itemList:GetSortedGuidList();
        local sortedCnt = sortedGuidList:Count();
        local items = {}
        local toattachcopy = deepcopy(toattach)
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i)
            local invItem = itemList:GetItemByGuid(guid)
            local obj = GetIES(invItem:GetObject());
            
            if obj.ClassName ~= MONEY_NAME then
                for k, v in pairs(toattachcopy) do
                    AWWARDROBE_DBGOUT('POPO' .. v.clsid .. '/' .. invItem.type)
                    
                    if v.count > 0 and v.clsid ~= 0 and v.clsid == invItem.type and GET_ITEM_LEVEL_EXP(GetIES(invItem:GetObject())) == v.lv then
                        items[#items + 1] = {
                            iesid = invItem:GetIESID(),
                            count = 1
                        }
                        toattachcopy[k].count = toattachcopy[k].count - 1
                        break
                    end
                end
            end
        
        end
        LS.takeitems(items);
        
        local currentcards = {}
        local detach = deepcopy(toremove)
        --取り外し
        for i = 1, g.max_cards do
            local cardInfo = equipcard.GetCardInfo(i);
            if cardInfo then
                currentcards[i] = {
                    clsid = cardInfo:GetCardID(),
                    lv = cardInfo.cardLv,
                    original = true
                }
            end
        end
        for k, v in pairs(detach) do
            local pass = false
            while pass == false and detach[k].count > 0 do
                pass = true
                for i = 1, g.max_cards do
                    local kk = i
                    local vv = currentcards[kk]
                    if vv ~= nil and v.clsid ~= 0 and (v.clsid ~= vv.clsid or v.lv ~= vv.lv) and vv.original then
                        currentcards[kk] = {
                            clsid = v.clsid,
                            lv = v.lv,
                            original = false
                        }
                        AWWARDROBE_DBGOUT('detach ' .. i)
                        ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", tostring(%d)..' 1')]], i - 1), delay)
                        delay = delay + 1
                        detach[k].count = detach[k].count - 1
                        currentcards[kk].original = false
                        pass = false
                    end
                
                end
            end
        end
        delay = delay + 2
        --取り付け
        for k, v in pairs(toattach) do
            for i = 1, v.count do
                
                if v and v.clsid ~= 0 then
                    
                    ReserveScript(string.format([[AWWARDROBE_DO_INSERT(%d,%d,%d)]], v.clsid, v.lv, i), delay)
                    delay = delay + 0.75
                end
            end
        end
        ReserveScript('ui.SysMsg("' .. L_("alertcomplete") .. '");AWWARDROBE_INTERLOCK(false)', delay)
    end)
end
function AWWARDROBE_GENERATE_IKORPROPSTRING(targetItem, userandom, usefixed)
    local targetItemObj = GetIES(targetItem:GetObject())
    local propstr = ""
    local basicList = GET_EQUIP_TOOLTIP_PROP_LIST(targetItemObj)
    local list = {}
    local basicTooltipPropList = StringSplit(targetItemObj.BasicTooltipProp, ';')
    for i = 1, #basicTooltipPropList do
        local basicTooltipProp = basicTooltipPropList[i]
        list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(basicList, basicTooltipProp, list)
    end
    local targetItemOld = GetClass('Item', targetItemObj.InheritanceItemName)
    if targetItemOld == nil then
        targetItemOld = GetClass('Item', targetItemObj.InheritanceRandomItemName)
    end
        
    local spname =  targetItemOld.EqpType;
    propstr=spname..">"
    if usefixed then
        local tgtclass = GetClass('Item', targetItemObj.InheritanceItemName)
        
        
        for i = 1, #list do
            local propName = list[i]
            local propValue = TryGetProp(tgtclass, propName, 0)
            local needToShow = true
            for j = 1, #basicTooltipPropList do
                if basicTooltipPropList[j] == propName then
                    needToShow = false
                end
            end
            local pass = false
            --if propName ~= "MINATK" and propName ~= 'MAXATK' and propName ~= 'MATK'and propName ~= 'DEF' then
            pass = true
            --end
            
            if needToShow and propName~='HiddenProp' and pass and propValue ~= 0 then
                propstr = propstr .. propName .. ':' .. propValue .. ','
            end
        end
        
     
        
        AWWARDROBE_DBGOUT("FIXEDPROP" .. propstr)
    end
    if userandom then
        local maxRandomOptionCnt = 6
        local randomOptionProp = {}
        for i = 1, maxRandomOptionCnt do
            if targetItemObj['RandomOption_' .. i] ~= 'None' then
                randomOptionProp[targetItemObj['RandomOption_' .. i]] = targetItemObj['RandomOptionValue_' .. i]
            end
        end
        local itemObj = GetIES(targetItem:GetObject())
        for i = 1, maxRandomOptionCnt do
            local propGroupName = "RandomOptionGroup_" .. i
            local propName = "RandomOption_" .. i
            local propValue = "RandomOptionValue_" .. i
            local clientMessage = 'None'
            
            if itemObj[propGroupName] == 'ATK' then
                clientMessage = 'ItemRandomOptionGroupATK'
            elseif itemObj[propGroupName] == 'DEF' then
                clientMessage = 'ItemRandomOptionGroupDEF'
            elseif itemObj[propGroupName] == 'UTIL_WEAPON' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif itemObj[propGroupName] == 'UTIL_ARMOR' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif itemObj[propGroupName] == 'UTIL_SHILED' then
                clientMessage = 'ItemRandomOptionGroupUTIL'
            elseif itemObj[propGroupName] == 'STAT' then
                clientMessage = 'ItemRandomOptionGroupSTAT'
            end
            
            if itemObj[propValue] ~= 0 and itemObj[propName] ~= "None" then
                local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(itemObj[propName]))
                propstr = propstr .. itemObj[propName] .. ":" .. itemObj[propValue] .. ','
            end
        end
        
        AWWARDROBE_DBGOUT("RANDOMPROP" .. propstr)
    end
    return propstr
end
function AWWARDROBE_CALCULATE_SILVER_IKORDETACH(tbl)
    
    local releasefixed = {}
    local releaserandom = {}
    local releasemixed = {}
    local equipItemList = session.GetEquipItemList();
    local totalPrice = 0
    local count = 0
    for i = 0, equipItemList:Count() - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i)
        local spname = item.GetEquipSpotName(equipItem.equipSpot);
        if spname == 'TRINKET' then
            spname = 'LH'
        end
        if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and equipItem.type ~= 0 and tbl[spname] then
            local itemrandom = AWWARDROBE_GENERATE_IKORPROPSTRING(equipItem, true, false)
            local itemfixed = AWWARDROBE_GENERATE_IKORPROPSTRING(equipItem, false, true)
            local pass = false
            if  tbl[spname].random then
                if tbl[spname].random.props then
                    if tbl[spname].random.props == itemrandom then
                        pass = true
                    end
                end
            end
            if tbl[spname].fixed then
                if tbl[spname].fixed.props then
                    if tbl[spname].fixed.props == itemfixed then
                        pass = true
                    end
                end
            end
            if pass and true ~= equipItem.isLockState then
                -- ReserveScript(string.format("AWWARDROBE_UNWEARBYGUID(\"%s\")", equipItem:GetIESID()), delay)
                if tbl[spname].random and itemrandom ~= "" then
                    releaserandom[#releaserandom + 1] = equipItem
                    releasemixed[equipItem:GetIESID()] = equipItem.equipSpot
                end
                if tbl[spname].fixed and itemfioxed ~= "" then
                    releasefixed[#releasefixed + 1] = equipItem
                    releasemixed[equipItem:GetIESID()] = equipItem.equipSpot
                end
            
            end
        end
    end
    
    for _, invItem in ipairs(releaserandom) do
        local invItemObj = GetIES(invItem:GetObject())
        local eachPrice = GET_OPTION_RELEASE_COST(invItemObj, nil, 0)
        totalPrice = totalPrice + eachPrice
        count = count + 1
    end
    for _, invItem in ipairs(releasefixed) do
        local invItemObj = GetIES(invItem:GetObject())
        local eachPrice = GET_OPTION_RELEASE_COST(invItemObj, nil, 0)
        totalPrice = totalPrice + eachPrice
        count = count + 1
    end
    return totalPrice, count

end

function AWWARDROBE_CALCULATE_SILVER_IKORATTACH(tbl)
    local totalPrice = 0
    local count = 0
    local equipItemList = session.GetEquipItemList();
    for i = 0, equipItemList:Count() - 1 do
        --装備しているかチェック
        local equipItem = equipItemList:GetEquipItemByIndex(i)
        local spname = item.GetEquipSpotName(equipItem.equipSpot);
        if spname == 'TRINKET' then
            spname = 'LH'
        end
        if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and equipItem.type ~= 0 and tbl[spname] then
            if true ~= equipItem.isLockState then
                
                local invItemObj=GetIES(equipItem:GetObject())
                if tbl[spname].random then
                  
                    if TryGetProp(invItemObj, 'InheritanceRandomItemName', 'None') ~= 'None' and AWWARDROBE_FINDIKORBYPROPS(tbl[spname].random.props) then
                        --OUT
                        local eachPrice = GET_OPTION_RELEASE_COST(invItemObj, nil, 0)
                        totalPrice=totalPrice+eachPrice
                        count=count+1
                    end
                end
                if tbl[spname].fixed then
                    if TryGetProp(invItemObj, 'InheritanceItemName', 'None') ~= 'None'and AWWARDROBE_FINDIKORBYPROPS(tbl[spname].fixed.props)  then
                        --OUT
                        local eachPrice = GET_OPTION_RELEASE_COST(invItemObj, nil, 0)
                        totalPrice=totalPrice+eachPrice
                        count=count+1
                    end
                end
            end

        end
    end
    return totalPrice

end
function AWWARDROBE_DETACH_IKOR(tbl)
    AWWARDROBE_try(function()
        local delay = 1
        local awframe = ui.GetFrame("accountwarehouse")
        
        local items = {}
        if (AWWARDROBE_INTERLOCK()) then
            
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        local isPremiumState = session.loginInfo.IsPremiumState(ITEM_TOKEN);
        if isPremiumState == false then
            
            ui.SysMsg(L_("needtoken"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        ui.SysMsg(L_("alertstart"))
        
        
        local needzeny = AWWARDROBE_CALCULATE_SILVER_IKORDETACH(tbl)
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'ClassName', Value = MONEY_NAME}}, false, itemList);
        local visItem = visItemList[1];
        
        local accountsilver = '0'
        if visItem == nil or GETMYPCLEVEL() >= 15 and true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
            accountsilver = visItem:GetAmountStr()
        end
        
        local zeny = SumForBigNumberInt64(GET_TOTAL_MONEY_STR(), accountsilver)
        --足りる?
        if IsGreaterThanForBigNumber(needzeny, zeny) == 1 then
            ui.SysMsg(L_("insufficientsilver"))
            return
        end
        
        --DO
        ui.SysMsg(L_("alertstart"))
        AWWARDROBE_INTERLOCK(true)
        
        --sit down
        ReserveScript("if not control.IsRestSit() then control.RestSit() end", delay)
        delay = delay + 1.2
        --費用を引き出す
        if IsGreaterThanForBigNumber(needzeny, accountsilver) == 1 then
            accountsilver = needzeny
        end
        if IsGreaterThanForBigNumber(accountsilver, '0') == 1 then
            ReserveScript(string.format([[AWWARDROBE_TAKESILVER('%s')]], needzeny), delay)
            delay = delay + 1
        end
        
        local releasefixed = {}
        local releaserandom = {}
        local releasemixed = {}
        local equipItemList = session.GetEquipItemList();
        for i = 0, equipItemList:Count() - 1 do
            local equipItem = equipItemList:GetEquipItemByIndex(i)
            local spname = item.GetEquipSpotName(equipItem.equipSpot);
            if spname == 'TRINKET' then
                spname = 'LH'
            end
            if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and equipItem.type ~= 0 and tbl[spname] then
                local itemrandom = AWWARDROBE_GENERATE_IKORPROPSTRING(equipItem, true, false)
                local itemfixed = AWWARDROBE_GENERATE_IKORPROPSTRING(equipItem, false, true)
                local pass = false
                if tbl[spname].random then
                    if tbl[spname].random.props then
                        if tbl[spname].random.props == itemrandom then
                            pass = true
                        end
                    end
                end
                if tbl[spname].fixed then
                    if tbl[spname].fixed.props then
                        if tbl[spname].fixed.props == itemfixed then
                            pass = true
                        end
                    end
                end
                if pass and true ~= equipItem.isLockState then
                    
                    if tbl[spname].random and itemrandom ~= "" then
                        releaserandom[#releaserandom + 1] = equipItem
                        releasemixed[equipItem:GetIESID()] = equipItem.equipSpot
                    end
                    if tbl[spname].fixed and itemfioxed ~= "" then
                        releasefixed[#releasefixed + 1] = equipItem
                        releasemixed[equipItem:GetIESID()] = equipItem.equipSpot
                    end
                
                end
            end
        end
        --装備を外す
        for iesid, spot in pairs(releasemixed) do
            ReserveScript(string.format("AWWARDROBE_UNWEARBYGUID(\"%s\")", iesid), delay)
            delay = delay + 0.5
        
        end
        if #releaserandom > 0 then
            local script = 'AWWARDROBE__RESET_ITEMLIST();'
            
            for i, invItem in pairs(releaserandom) do
                --ランダムイコルを外す
                script = script .. 'AWWARDROBE__ADD_ITEM("' .. invItem:GetIESID() .. '");'
            
            end
            
            script = script .. 'AWWARDROBE__DIALOG_TRANSACTION("RELEASE_ITEM_ICOR_RANDOM_MULTIPLE");'
            ReserveScript(script, delay)
            delay = delay + 5
        end
        
        if #releasefixed > 0 then
            local script = 'AWWARDROBE__RESET_ITEMLIST();'
            
            for i, invItem in pairs(releasefixed) do
                --ランダムイコルを外す
                script = script .. 'AWWARDROBE__ADD_ITEM("' .. invItem:GetIESID() .. '");'
            
            end
            
            script = script .. 'AWWARDROBE__DIALOG_TRANSACTION("RELEASE_ITEM_ICOR_MULTIPLE");'
            ReserveScript(script, delay)
            delay = delay + 5
        end
        --装備を戻す
        for iesid, spot in pairs(releasemixed) do
            local spname = item.GetEquipSpotName(spot);
            ReserveScript(string.format("AWWARDROBE_WEAR(\"%s\",\"%s\")", iesid, spname), delay)
            delay = delay + 0.5
        end
        --イコルを預ける
    
         
        for i, tp in pairs(tbl) do
            
            if tp.random then
                AWWARDROBE_DBGOUT("DEPOS"..tp.random.props)
                local script = 'AWWARDROBE_DEPOSIT_IKOR_BY_PROPS("'..tp.random.props..'");'
                ReserveScript(script, delay)
                delay = delay + 0.8
            end
            if tp.fixed then
                local script = 'AWWARDROBE_DEPOSIT_IKOR_BY_PROPS("'..tp.fixed.props..'");'
                ReserveScript(script, delay)
                delay = delay + 0.8
            end
        end
        
        
        
    
        ReserveScript("if control.IsRestSit() then control.RestSit() end", delay)
        delay = delay + 1.2
        ReserveScript('ui.SysMsg("' .. L_("alertcomplete") .. '");AWWARDROBE_INTERLOCK(false)', delay)
    end)
end
function AWWARDROBE_FINDIKORBYPROPS(props)
    --イコルを探す
    for guid, invItem, invItemObj in LS.getitemiter() do
                
        if TryGetProp(invItemObj, 'GroupName') == 'Icor' then
            local randomprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, true, false)
            local fixedprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, false, true)
            if randomprops==props or fixedprops==props then
                return invItem
            end
        end
    end
    --なかったらインベントリから検索
    local invItemList = session.GetInvItemList();
    FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem)
        local invItemObj = GetIES(invItem:GetObject())
        if TryGetProp(invItemObj, 'GroupName') == 'Icor' then
            local randomprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, true, false)
            local fixedprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, false, true)
            if randomprops==props or fixedprops==props then
                return invItem
            end
        end
    end, false);
    return nil
    
end
function AWWARDROBE_DEPOSIT_IKOR_BY_PROPS(prop)
    LS.target=IT_ACCOUNT_WAREHOUSE
    local invItemList = session.GetInvItemList();
    FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem)
        local invItemObj = GetIES(invItem:GetObject())
        if TryGetProp(invItemObj, 'GroupName') == 'Icor' then
            local randomprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, true, false)
            local fixedprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, false, true)
            AWWARDROBE_DBGOUT('LHS:'..randomprops)
            AWWARDROBE_DBGOUT('RHS:'..prop)

            if prop==randomprops or prop==fixedprops then
                                LS.putitem(invItem:GetIESID(),1);
            end
        end
    end, false);
end
function AWWARDROBE_ATTACH_IKOR(tbl)
    AWWARDROBE_try(function()
        local delay = 1
        local awframe = ui.GetFrame("accountwarehouse")
        
        local items = {}
        if (AWWARDROBE_INTERLOCK()) then
            
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        local isPremiumState = session.loginInfo.IsPremiumState(ITEM_TOKEN);
        if isPremiumState == false then
            
            ui.SysMsg(L_("needtoken"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        ui.SysMsg(L_("alertstart"))
        
        local needzeny =  AWWARDROBE_CALCULATE_SILVER_IKORATTACH(tbl)
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'ClassName', Value = MONEY_NAME}}, false, itemList);
        local visItem = visItemList[1];
        
        local accountsilver = '0'
        if visItem == nil or GETMYPCLEVEL() >= 15 and true == session.loginInfo.IsPremiumState(ITEM_TOKEN) then
            accountsilver = visItem:GetAmountStr()
        end
        
        local zeny = SumForBigNumberInt64(GET_TOTAL_MONEY_STR(), accountsilver)
        --足りる?
        if IsGreaterThanForBigNumber(needzeny, zeny) == 1 then
            ui.SysMsg(L_("insufficientsilver"))
            return
        end
        
        --DO
        ui.SysMsg(L_("alertstart"))
        AWWARDROBE_INTERLOCK(true)
        
        --sit down
        ReserveScript("if not control.IsRestSit() then control.RestSit() end", delay)
        delay = delay + 1.2
        --費用を引き出す
        if IsGreaterThanForBigNumber(needzeny, accountsilver) == 1 then
            accountsilver = needzeny
        end
        if IsGreaterThanForBigNumber(accountsilver, '0') == 1 then
            ReserveScript(string.format([[AWWARDROBE_TAKESILVER('%s')]], needzeny), delay)
            delay = delay + 1
        end
        
        local attachfixed = {}
        local attachrandom = {}
        local attachmixed = {}
        local searchrandom = {}
        local searchfixed = {}
        
        local equipItemList = session.GetEquipItemList();
        for i = 0, equipItemList:Count() - 1 do
            --装備しているかチェック
            local equipItem = equipItemList:GetEquipItemByIndex(i)
            local spname = item.GetEquipSpotName(equipItem.equipSpot);
            if spname == 'TRINKET' then
                spname = 'LH'
            end
            
            if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and equipItem.type ~= 0 and tbl[spname] then
                if true ~= equipItem.isLockState then
                    
                    if tbl[spname].random then
                        attachrandom[#attachrandom + 1] = equipItem
                        attachmixed[equipItem:GetIESID()] = equipItem.equipSpot
                        searchrandom[#searchrandom + 1] = {
                            props = tbl[spname].random,
                            to = equipItem}
                    end
                    if tbl[spname].fixed then
                        attachfixed[#attachfixed + 1] = equipItem
                        attachmixed[equipItem:GetIESID()] = equipItem.equipSpot
                        searchfixed[#searchfixed + 1] = {
                            props = tbl[spname].fixed,
                            to = equipItem}
                    end
                end
            end
        end
        local withdraws = {}
        local toattachrandom = {}
        local toattachfixed = {}
        
        --イコルを探す
        for guid, invItem, invItemObj in LS.getitemiter() do
            
            if TryGetProp(invItemObj, 'GroupName') == 'Icor' then
                local randomprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, true, false)
                local fixedprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, false, true)
                AWWARDROBE_DBGOUT('FFF'..fixedprops)
                for k, v in ipairs(searchrandom) do
                    if v.props.props == randomprops then
                        withdraws[#withdraws + 1] = {
                            iesid = guid,
                            count = 1
                        }
                        toattachrandom[#toattachrandom + 1] = {guid = guid, data = v}
                        table.remove(searchrandom, k)
                        break
                    end
                end
                for k, v in ipairs(searchfixed) do
                    if v.props.props == fixedprops then
                        withdraws[#withdraws + 1] = {
                            iesid = guid,
                            count = 1
                        }
                        toattachfixed[#toattachfixed + 1] = {guid = guid, data = v}
                        table.remove(searchfixed, k)
                        break
                    end
                end
            end
        end
        --なかったらインベントリから検索
        if #searchfixed + #searchrandom > 0 then
            local invItemList = session.GetInvItemList();
            FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem)
                local invItemObj = GetIES(invItem:GetObject())
                if TryGetProp(invItemObj, 'GroupName') == 'Icor'  then
                    local randomprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, true, false)
                    local fixedprops = AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, false, true)
                   
                    for k, v in ipairs(searchrandom) do
                        if v.props.props == randomprops then
                            toattachrandom[#toattachrandom + 1] = {guid = invItem:GetIESID(), data = v}
                            table.remove(searchrandom, k)
                            break
                        end
                    end
                    for k, v in ipairs(searchfixed) do
                        if v.props.props == fixedprops then
                            AWWARDROBE_DBGOUT("MATCH")
                            toattachfixed[#toattachfixed + 1] = {guid = invItem:GetIESID(), data = v}
                            table.remove(searchfixed, k)
                           
                            break
                        end
                    end
                end
            end, false);
        end
        if #toattachrandom + #toattachfixed > 0 then
            if #withdraws > 0 then
                --イコルを引き出す(fasttrick)
                LS.takeitems(withdraws)
                delay = delay + 3
            end
            --装備を外す
            for iesid, spot in pairs(attachmixed) do
                ReserveScript(string.format("AWWARDROBE_UNWEARBYGUID(\"%s\")", iesid), delay)
                delay = delay + 0.5
            
            end
           


            if #toattachrandom > 0 then
                --イコル装着済みのアイテムを処す
                local cnt=0
                local script = 'AWWARDROBE__RESET_ITEMLIST();'
                for i, v in pairs(toattachrandom) do
                    local invItemObj=GetIES(v.data.to:GetObject())
                    if TryGetProp(invItemObj, 'InheritanceRandomItemName', 'None') ~= 'None'  then
                        script = script .. 'AWWARDROBE__ADD_ITEM("' .. v.data.to:GetIESID() .. '");'
                        cnt=cnt+1
                    end
                end
                if cnt>0 then
                    script = script .. "AWWARDROBE__DIALOG_TRANSACTION('RELEASE_ITEM_ICOR_RANDOM_MULTIPLE');"
                    ReserveScript(script, delay)
                    delay=delay+7
                end
                local script = 'AWWARDROBE__RESET_ITEMLIST();'
                for i, v in pairs(toattachrandom) do
                    
                    --ランダムイコルを付ける
                    script = script .. 'AWWARDROBE__ADD_ITEM("' .. v.data.to:GetIESID() .. '");'
                    script = script .. 'AWWARDROBE__ADD_ITEM("' .. v.guid .. '");'
                
                
                end
                script = script .. "AWWARDROBE__DIALOG_TRANSACTION('EQUIP_ITEM_ICOR_MULTIPLE');"
                ReserveScript(script, delay)
                delay = delay + 7
            end
            
            if #toattachfixed > 0 then
                --イコル装着済みのアイテムを処す
                
                local cnt=0
                local script = 'AWWARDROBE__RESET_ITEMLIST();'
                for i, v in pairs(toattachfixed) do
                    local invItemObj=GetIES(v.data.to:GetObject())
                    if TryGetProp(invItemObj, 'InheritanceItemName', 'None') ~= 'None'  then
                        script = script .. 'AWWARDROBE__ADD_ITEM("' .. v.data.to:GetIESID() .. '");'
                        cnt=cnt+1
                    end
                end
                if cnt>0 then
                    script = script .. "AWWARDROBE__DIALOG_TRANSACTION('RELEASE_ITEM_ICOR_MULTIPLE');"
                    ReserveScript(script, delay)
                    delay=delay+7
                end
                --固定イコルを付ける
                
                local script = 'AWWARDROBE__RESET_ITEMLIST();'
                for i, v in pairs(toattachfixed) do
                    
                    script = script .. 'AWWARDROBE__ADD_ITEM("' .. v.data.to:GetIESID() .. '");'
                    script = script .. 'AWWARDROBE__ADD_ITEM("' .. v.guid .. '");'
                    AWWARDROBE_DBGOUT("OK")
                
                end
                script = script .. "AWWARDROBE__DIALOG_TRANSACTION('EQUIP_ITEM_ICOR_MULTIPLE');"
                ReserveScript(script, delay)
                delay = delay + 7
            end
            --装備を戻す
            for iesid, spot in pairs(attachmixed) do
                local spname = item.GetEquipSpotName(spot);
                ReserveScript(string.format("AWWARDROBE_WEAR(\"%s\",\"%s\")", iesid, spname), delay)
                delay = delay + 0.5
            end
        end
        
        ReserveScript("if control.IsRestSit() then control.RestSit() end", delay)
        delay = delay + 1.2
        ReserveScript('ui.SysMsg("' .. L_("alertcomplete") .. '");AWWARDROBE_INTERLOCK(false)', delay)
    end)
end
function AWWARDROBE__RESET_ITEMLIST()
    g.tempitemlist = {}
end
function AWWARDROBE__ADD_ITEM(guid)
    g.tempitemlist[#g.tempitemlist + 1] = guid
end
function AWWARDROBE__DIALOG_TRANSACTION(cmd)
    session.ResetItemList()
    for _, v in ipairs(g.tempitemlist) do
        session.AddItemID(v, 1)
    end
    local resultlist = session.GetItemIDList()
    item.DialogTransaction(cmd, resultlist)
end
function AWWARDROBE_DO_INSERT(clsid, lv, dummy)
    AWWARDROBE_try(function()
        AWWARDROBE_DBGOUT('hooo4')
        
        local invItem = AWWARDROBE_FINDINVITEMBYTYPEANDLEVEL(clsid, lv);
        AWWARDROBE_DBGOUT('hooo3')
        if invItem then
            
            AWWARDROBE_DBGOUT('hooo2')
            AWWARDROBE_INSERTCARD(invItem)
        else
            
            AWWARDROBE_DBGOUT('hooaao2')
        end
    end)
end
function AWWARDROBE_INSERTCARD(invItem)
    
    
    local cardObj = GetClassByType("Item", invItem.type)
    if cardObj == nil then
        
        return
    end
    if cardObj.CardGroupName == "REINFORCE_CARD" then
        ui.SysMsg(ClMsg("LegendReinforceCard_Not_Equip"));
        return
    end
    local groupNameStr = cardObj.CardGroupName
    local groupSlotIndex = 1
    local max = MONSTER_CARD_SLOT_COUNT_PER_TYPE
    if groupNameStr == 'ATK' then
        groupSlotIndex = groupSlotIndex + (0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif groupNameStr == 'DEF' then
        groupSlotIndex = groupSlotIndex + (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif groupNameStr == 'UTIL' then
        groupSlotIndex = groupSlotIndex + (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif groupNameStr == 'STAT' then
        groupSlotIndex = groupSlotIndex + (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif groupNameStr == 'LEG' then
        groupSlotIndex = groupSlotIndex + (4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        max = 1
    -- leg 카드는 slotindex = 12, 13번째 슬롯
    end
    local candidate = nil
    local lessercandidate = nil
    for idx = groupSlotIndex, groupSlotIndex + max - 1 do
        local cardInfo = equipcard.GetCardInfo(idx);
        if cardInfo == nil then
            candidate = idx
            break
        else
            
            end
    end
    candidate = candidate or lessercandidate
    
    if candidate then
        
        local argStr = string.format("%d#%s", candidate - 1, invItem:GetIESID());
        pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr);
    end
end

function AWWARDROBE_INITIALIZE_FRAME()
    AWWARDROBE_try(function()
        local frame = ui.GetFrame(g.framename);
        
        frame:Resize(900, 550)
        --frame:GetChildRecursively("equip"):ShowWindow(1)
        
        frame:GetChild("mainGbox"):ShowWindow(1)
        frame:GetChild("mainGbox"):SetOffset(0, 110)
        frame:GetChild("mainGbox"):SetGravity(ui.LEFT, ui.TOP)
        frame:GetChild("mainGbox"):SetVisible(0)
        frame:GetChildRecursively("gbox_Equipped"):SetOffset(10, 110)
        frame:GetChildRecursively("gbox_Equipped"):ShowWindow(1)
        frame:GetChildRecursively("gbox_Dressed"):ShowWindow(1)
        frame:GetChildRecursively("gbox_Dressed"):SetOffset(280, 120)
        frame:GetChild("equip"):Resize(600, 400)
        
        
        local btnregister = frame:CreateOrGetControl("button", "btnregister", 550, 240, 200, 40)
        btnregister:SetText(L_("btnregister"))
        btnregister:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_REGISTER_CURRENT")
        
        local btnclear = frame:CreateOrGetControl("button", "btnclear", 550, 300, 200, 40)
        btnclear:SetText(L_("btnclear"))
        btnclear:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_CLEARALL")
        
        local btnsave = frame:CreateOrGetControl("button", "btnsave", 550, 360, 130, 40)
        btnsave:SetText(L_("btnsave"))
        btnsave:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_BTNSAVE_ON_LBUTTONDOWN")
        
        local btndelete = frame:CreateOrGetControl("button", "btndelete", 690, 360, 130, 40)
        btndelete:SetText(L_("btndelete"))
        btndelete:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_BTNDELETE_ON_LBUTTONDOWN")
        
        frame:CreateOrGetControl("richtext", "label1", 20, 80, 80, 20):SetText(L_("labelcurrentsettings"))
        
        local cbwardrobe = frame:CreateOrGetControl("droplist", "cbwardrobe", 130, 80, 250, 20)
        tolua.cast(cbwardrobe, "ui::CDropList")
        cbwardrobe:SetSkinName("droplist_normal")
        cbwardrobe:SetSelectedScp("AWWARDROBE_WARDROBE_ON_SELECT_DROPLIST")
        
        local btntab
        btntab = frame:CreateOrGetControl("button", "btntab", 70, 75, 60, 30)
        btntab:SetText(L_("tabequip"))
        btntab:SetEventScript(ui.LBUTTONDOWN, "AWWARDROBE_CONFIG_ON_TAB")
        
        local ebname = frame:CreateOrGetControl("edit", "ebname", 20, 430, 250, 30)
        ebname:SetFontName("white_18_ol")
        ebname:SetSkinName("test_weight_skin")
        frame:CreateOrGetControl("richtext", "label2", 20, 400, 80, 20):SetText(L_("labelsettingsname"))
        
        
        for _, v in pairs(slotsetnames) do
            local slotset = frame:GetChildRecursively(v)
            AUTO_CAST(slotset)
            slotset:EnableDrag(0)
            slotset:EnablePop(0)
            slotset:EnableDrop(1)
        
        end
        
        
        
        
        for k, _ in pairs(g.effectingspot) do
            
            local slot = GET_CHILD_RECURSIVELY(frame:GetChildRecursively('equip'), k, "ui::CSlot")
            slot:SetEventScript(ui.RBUTTONDOWN, "AWWARDROBE_SLOT_ON_RBUTTONDOWN")
            slot:SetEventScriptArgString(ui.RBUTTONDOWN, k)
            slot:SetEventScript(ui.DROP, "AWWARDROBE_SLOT_ON_DROP")
            slot:SetEventScriptArgString(ui.DROP, k)
            
            slot:EnableDrag(0)
        end
        for k, _ in pairs(g.effectingikorspot) do
            
            local slot = GET_CHILD_RECURSIVELY(frame:GetChildRecursively('gbox_Ikor'), k, "ui::CSlot")
            slot:SetEventScript(ui.RBUTTONDOWN, "AWWARDROBE_IKORSLOT_ON_RBUTTONDOWN")
            slot:SetEventScriptArgString(ui.RBUTTONDOWN, k)
            slot:SetEventScript(ui.DROP, "AWWARDROBE_IKORSLOT_ON_DROP")
            slot:SetEventScriptArgString(ui.DROP, k)
            
            slot:EnableDrag(0)
            local rslot = GET_CHILD_RECURSIVELY(frame:GetChildRecursively('gbox_Ikor'), "R_" .. k, "ui::CSlot")
            rslot:SetEventScript(ui.RBUTTONDOWN, "AWWARDROBE_IKORSLOT_ON_RBUTTONDOWN")
            rslot:SetEventScriptArgString(ui.RBUTTONDOWN, "R_" .. k)
            rslot:SetEventScript(ui.DROP, "AWWARDROBE_IKORSLOT_ON_DROP")
            rslot:SetEventScriptArgString(ui.DROP, k)
            rslot:EnableDrag(0)
        end
        g.tab_config = TAB_EQUIP
        
        AWWARDROBE_CLEARALLCARDS(frame)
        AWWARDROBE_UPDATE_DROPBOX()
        AWWARDROBE_WARDROBE_ON_SELECT_DROPLIST(frame, true)
    end)
end
function AWWARDROBE_UPDATE_DROPBOX()
    AWWARDROBE_try(function()
            
            local frame = ui.GetFrame(g.framename)
            
            local cbwardrobe = GET_CHILD(frame, "cbwardrobe", "ui::CDropList")
            
            cbwardrobe:ClearItems()
            
            local count = 0
            local selectindex = nil
            AWWARDROBE_DBGOUT("def" .. tostring(g.settings.defaultname))
            local wardrobe;
            local defaultname;
            if g.tab_config == TAB_EQUIP then
                wardrobe = g.settings.wardrobe
                defaultname = g.settings.defaultname
            elseif g.tab_config == TAB_CARD then
                wardrobe = g.settings.wardrobecard
                defaultname = g.settings.defaultnamecard
            elseif g.tab_config == TAB_IKOR then
                wardrobe = g.settings.wardrobeikor
                defaultname = g.settings.defaultnameikor
            end
            for k, d in pairs(wardrobe) do
                if (k ~= L_("defaultvalue")) then
                    cbwardrobe:AddItem(count + 1, d.name)
                    if (d.name == defaultname) then
                        selectindex = count
                    end
                    count = count + 1
                end
            
            end
            if (selectindex ~= nil) then
                cbwardrobe:SelectItem(selectindex)
            end
            cbwardrobe:Invalidate()
            AWWARDROBE_WARDROBE_ON_SELECT_DROPLIST(frame, true)
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
                
                local wardrobe
                local defaultname
                if g.tab_aw == TAB_EQUIP then
                    wardrobe = g.settings.wardrobe
                    defaultname = g.personalsettings.defaultname
                elseif g.tab_aw == TAB_CARD then
                    wardrobe = g.settings.wardrobecard
                    defaultname = g.personalsettings.defaultnamecard
                elseif g.tab_aw == TAB_IKOR then
                    wardrobe = g.settings.wardrobeikor
                    defaultname = g.personalsettings.defaultnameikor
                end
                for k, d in pairs(wardrobe) do
                    if (k ~= L_("defaultvalue")) then
                        acbwardrobe:AddItem(count + 1, d.name)
                        if (d.name == defaultname) then
                            AWWARDROBE_DBGOUT("match" .. tostring(count + 1))
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
            
            local wardrobe
            local defaultname
            if g.tab_config == TAB_EQUIP then
                wardrobe = g.settings.wardrobe
                g.personalsettings.defaultname = wardrobe[key + 1].name
                local sound = not (shutup == true)
                if (key ~= "" and not g.settings.wardrobe[key + 1]) then
                    ui.SysMsg(string.format(L_("alertnosettings"), key));
                    return
                end
                
                if (key == "") then
                    AWWARDROBE_CLEARALLEQUIPS(frame)
                else
                    AWWARDROBE_LOADEQFROMSTRUCTURE(g.settings.wardrobe[key + 1].data, sound)
                end
            elseif g.tab_config == TAB_CARD then
                wardrobe = g.settings.wardrobecard
                g.personalsettings.defaultnamecard = wardrobe[key + 1].name
                if (key ~= "" and not g.settings.wardrobecard[key + 1]) then
                    ui.SysMsg(string.format(L_("alertnosettings"), key));
                    return
                end
                
                if (key == "") then
                    AWWARDROBE_CLEARALLCARDS(frame)
                else
                    AWWARDROBE_LOADCARDFROMSTRUCTURE(g.settings.wardrobecard[key + 1].data)
                end
            elseif g.tab_config == TAB_IKOR then
                wardrobe = g.settings.wardrobeikor
                g.personalsettings.defaultnameikor = wardrobe[key + 1].name
                if (key ~= "" and not g.settings.wardrobeikor[key + 1]) then
                    ui.SysMsg(string.format(L_("alertnosettings"), key));
                    return
                end
                
                if (key == "") then
                    AWWARDROBE_CLEARALLIKOR(frame)
                else
                    AWWARDROBE_LOADIKORFROMSTRUCTURE(g.settings.wardrobeikor[key + 1].data)
                end
            end
            
            
            
            local ebname = GET_CHILD(frame, "ebname", "ui::CEditControl")
            ebname:SetText(wardrobe[key + 1].name)
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
            if g.tab_config == TAB_EQUIP then
                local table = AWWARDROBE_SAVEEQTOSTRUCTURE()
                g.settings.wardrobe = g.settings.wardrobe or {}
                g.settings.defaultname = curname
                
                --インデックス探索
                local fault = true
                for i = 1, #g.settings.wardrobe do
                    if (g.settings.wardrobe[i].name == curname) then
                        g.settings.wardrobe[i] = {name = curname, data = table}
                        fault = false
                        break
                    end
                end
                if (fault == true) then
                    g.settings.wardrobe[#g.settings.wardrobe + 1] = {name = curname, data = table}
                end
            elseif g.tab_config == TAB_CARD then
                local table = AWWARDROBE_SAVECARDTOSTRUCTURE()
                g.settings.wardrobecard = g.settings.wardrobecard or {}
                g.settings.defaultnamecard = curname
                
                --インデックス探索
                local fault = true
                for i = 1, #g.settings.wardrobecard do
                    if (g.settings.wardrobecard[i].name == curname) then
                        g.settings.wardrobecard[i] = {name = curname, data = table}
                        fault = false
                        break
                    end
                end
                if (fault == true) then
                    g.settings.wardrobecard[#g.settings.wardrobecard + 1] = {name = curname, data = table}
                end
            elseif g.tab_config == TAB_IKOR then
                local table = AWWARDROBE_SAVEIKORTOSTRUCTURE()
                g.settings.wardrobeikor = g.settings.wardrobeikor or {}
                g.settings.defaultnameikor = curname
                
                --インデックス探索
                local fault = true
                for i = 1, #g.settings.wardrobeikor do
                    if (g.settings.wardrobeikor[i].name == curname) then
                        g.settings.wardrobeikor[i] = {name = curname, data = table}
                        fault = false
                        break
                    end
                end
                if (fault == true) then
                    g.settings.wardrobeikor[#g.settings.wardrobeikor + 1] = {name = curname, data = table}
                end
            end
            --ソート
            AWWARDROBE_SORTING()
            ui.SysMsg(string.format(L_("alertsettingssaved"), curname));
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
function AWWARDROBE_LOADCARDFROMSTRUCTURE(table)
    local frame = ui.GetFrame(g.framename)
    --一旦クリア
    AWWARDROBE_CLEARALLCARDS(frame)
    local cnt = 1
    for i = 1, 5 do
        local max = 3
        if i == 5 then
            --legendcard
            max = 1
        end
        for j = 1, max do
            local slotset = frame:GetChildRecursively(slotsetnames[i])
            AUTO_CAST(slotset)
            local slot = slotset:GetSlotByIndex(j - 1)
            if table[cnt] and table[cnt].clsid ~= 0 then
                AWWARDROBE_SETSLOT_CARD(slot, table[cnt].clsid, table[cnt].lv)
            end
            
            cnt = cnt + 1
        end
    end

end
function AWWARDROBE_LOADIKORFROMSTRUCTURE(tbl)
    --local tbl = {}
    local frame = ui.GetFrame(g.framename):GetChildRecursively('gbox_Ikor')
    for k, _ in pairs(g.effectingikorspot) do
        if tbl[k] then
            if tbl[k].fixed then
                local slot = GET_CHILD_RECURSIVELY(frame, k, "ui::CSlot")
                
                
                AWWARDROBE_SETSLOT_IKOR(slot, tbl[k].fixed.clsid, tbl[k].fixed.props)
            end
            if tbl[k].random then
                local slot = GET_CHILD_RECURSIVELY(frame, "R_" .. k, "ui::CSlot")
                AWWARDROBE_SETSLOT_IKOR(slot, tbl[k].random.clsid, tbl[k].random.props)
            end
        end
    end
    return tbl
end
function AWWARDROBE_SAVEEQTOSTRUCTURE()
    local tbl = {}
    local frame = ui.GetFrame(g.framename):GetChildRecursively('equip')
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
function AWWARDROBE_SAVECARDTOSTRUCTURE()
    local tbl = {}
    local frame = ui.GetFrame(g.framename)
    local cnt = 1
    for i = 1, 5 do
        local max = 3
        if i == 5 then
            --legendcard
            max = 1
        end
        for j = 1, max do
            local slotset = frame:GetChildRecursively(slotsetnames[i])
            AUTO_CAST(slotset)
            local slot = slotset:GetSlotByIndex(j - 1)
            
            
            tbl[#tbl + 1] = {
                clsid = tonumber(slot:GetUserValue("clsid") or '0') or 0,
                lv = tonumber(slot:GetUserValue("lv") or '0') or 0,
            }
            cnt = cnt + 1
        end
    end
    return tbl
end
function AWWARDROBE_SAVEIKORTOSTRUCTURE()
    local tbl = {}
    local frame = ui.GetFrame(g.framename):GetChildRecursively('gbox_Ikor')
    for k, _ in pairs(g.effectingikorspot) do
        local slot = GET_CHILD_RECURSIVELY(frame, k, "ui::CSlot")
        local clsid = slot:GetUserValue("clsid")
        local props = slot:GetUserValue("props")
        if (not EBI_IsNoneOrNil(props)) then
            tbl[k] = tbl[k] or {}
            tbl[k]["fixed"] = {clsid = clsid, props = props}
        end
        local slot = GET_CHILD_RECURSIVELY(frame, "R_" .. k, "ui::CSlot")
        local clsid = slot:GetUserValue("clsid")
        local props = slot:GetUserValue("props")
        if (not EBI_IsNoneOrNil(props)) then
            tbl[k] = tbl[k] or {}
            tbl[k]["random"] = {clsid = clsid, props = props}
        end
    end
    return tbl
end
function AWWARDROBE_BTNDELETE_ON_LBUTTONDOWN(frame)
    AWWARDROBE_try(function()
            --現在の設定を消す
            local cbwardrobe = GET_CHILD(frame, "cbwardrobe", "ui::CDropList")
            local curname = cbwardrobe:GetText()
            local curindex = cbwardrobe:GetSelItemIndex() + 1
            if (curname == nil) then
                --ui.SysMsg("[AWW]削除する設定がありません");
                --pass
                else
                if (curname == L_("defaultvalue")) then
                    ui.SysMsg(string.format(L_("alertcantdelete"), curname));
                elseif (g.tab_config == TAB_EQUIP and g.settings.wardrobe[curindex]) then
                    g.settings.wardrobe[curindex].name = nil
                    --詰める
                    local tbl = {}
                    for k, d in ipairs(g.settings.wardrobe) do
                        if (d.name ~= nil) then
                            tbl[#tbl + 1] = d
                            AWWARDROBE_DBGOUT("BBB")
                        end
                    end
                    g.settings.wardrobe = tbl
                    ui.SysMsg(string.format(L_("alertdeletesettings"), curname));
                elseif (g.tab_config == TAB_CARD and g.settings.wardrobecard[curindex]) then
                    g.settings.wardrobecard[curindex].name = nil
                    --詰める
                    local tbl = {}
                    for k, d in ipairs(g.settings.wardrobecard) do
                        if (d.name ~= nil) then
                            tbl[#tbl + 1] = d
                            AWWARDROBE_DBGOUT("BBB")
                        end
                    end
                    g.settings.wardrobecard = tbl
                    ui.SysMsg(string.format(L_("alertdeletesettings"), curname));
                else
                    ui.SysMsg(string.format(L_("alertnosettings"), curname));
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
        frame = ctrl:GetTopParentFrame()
        AWWARDROBE_CLEAREQUIP(ctrl:GetTopParentFrame(), argstr)
        imcSound.PlaySoundEvent('inven_unequip');
        AWWARDROBE_PLAYSLOTANIMATION(frame:GetChildRecursively("equip"), argstr)
    end)
end
function AWWARDROBE_IKORSLOT_ON_RBUTTONDOWN(frame, ctrl, argstr, argnum)
    --現在の装備を登録
    AWWARDROBE_try(function()
            
            frame = ctrl:GetTopParentFrame()
            AWWARDROBE_CLEARIKOR(ctrl:GetTopParentFrame(), argstr)
            
            imcSound.PlaySoundEvent('inven_unequip');
            AWWARDROBE_PLAYSLOTANIMATION(frame:GetChildRecursively("gbox_Ikor"), argstr)
    end)
end
function AWWARDROBE_CARD_SLOT_ON_RBUTTONDOWN(frame, slot, argstr, argnum)
    --現在の装備を登録
    AWWARDROBE_try(function()
        AUTO_CAST(slot)
        slot:ClearIcon()
        slot:SetMaxSelectCount(0)
        slot:SetText('')
        slot:RemoveAllChild()
        slot:SetUserValue('clsid', nil)
        slot:SetUserValue('iesid', nil)
        slot:SetUserValue('lv', nil)
        
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
                local pos = argstr
                if (argstr:sub(-1) == "2") then
                    pos = argstr:sub(1, 2)
                end
                if (string.find(spotname, pos) ~= 1) then
                    
                    --NG
                    ui.SysMsg(L_("alertcantequip"))
                    AWWARDROBE_DBGOUT(tostring(pos) .. "/" .. tostring(spotname))
                    
                    return
                end
                AWWARDROBE_DBGOUT(tostring(pos) .. "/" .. tostring(spotname))
            
            end
            
            AWWARDROBE_SETSLOT(slot, invItem)
            local equipSound = "sys_armor_equip_new";
            imcSound.PlaySoundEvent(equipSound);
            AWWARDROBE_PLAYSLOTANIMATION(frame, argstr)
    end)
end
function AWWARDROBE_IKORSLOT_ON_DROP(frame, ctrl, argstr, argnum)
    --ドロップされた装備を登録
    AWWARDROBE_try(function()
            --AWWARDROBE_CLEAREQUIP(frame,argstr)
            local liftIcon = ui.GetLiftIcon()
            local liftframe = ui.GetLiftFrame():GetTopParentFrame()
            local slot = tolua.cast(ctrl, 'ui::CSlot')
            
            local iconInfo = liftIcon:GetInfo()
            local invItem = AWWARDROBE_ACQUIRE_ITEM_BY_GUID(iconInfo:GetIESID())
            local itemObj = GetIES(invItem:GetObject())
            -- invItem 이 아이커가 아니면 에러 후 리턴 if invItem
            if TryGetProp(itemObj, 'GroupName') ~= 'Icor' then
                ui.SysMsg(ClMsg("MustEquipIcor"))
                return
            end
            local invClass = GetClassByType("Item", GetIES(invItem:GetObject()).ClassID)
            local spotname = invClass.DefaultEqpSlot;
            local isRandom = false
            local targetItem = GetClass('Item', itemObj.InheritanceItemName)
            if targetItem == nil then
                targetItem = GetClass('Item', itemObj.InheritanceRandomItemName)
                isRandom = true
            end
            local randomprefix = ""
            if TryGetProp(itemObj, 'InheritanceRandomItemName', 'None') ~= 'None' then
                randomprefix = "R_"
            end
            local expectedspot
            if targetItem.GroupName == 'Weapon' then
                expectedspot = {'RH', 'LH'}
            end
            if targetItem.GroupName == 'Armor' and targetItem.ClassType == 'Boots' then
                expectedspot = {'BOOTS'}
            end
            if targetItem.GroupName == 'Armor' and targetItem.ClassType == 'Gloves' then
                expectedspot = {'GLOVES'}
            end
            if targetItem.GroupName == 'Armor' and targetItem.ClassType == 'PANTS' then
                expectedspot = {'PANTS'}
            end
            if targetItem.GroupName == 'Armor' and targetItem.ClassType == 'SHIRTS' then
                expectedspot = {'SHIRTS'}
            end
            for name in expectedspot do
                
                if slot:GetName() == (randomprefix .. name) then
                    AWWARDROBE_SETSLOT_IKOR_BYITEM(slot:GetParent(), slot:GetName(), invItem)
                    local equipSound = "sys_armor_equip_new";
                    imcSound.PlaySoundEvent(equipSound);
                    AWWARDROBE_PLAYSLOTANIMATION(frame, argstr)
                    return
                end
            end
            ui.SysMsg("Mismatch equipspot")
    --AWWARDROBE_PLAYSLOTANIMATION(frame, "R_"..argstr)
    end)
end
function AWWARDROBE_SLOT_CARD_ON_DROP(frame, ctrl, argstr, argnum)
    --ドロップされた装備を登録
    AWWARDROBE_try(function()
            --AWWARDROBE_CLEAREQUIP(frame,argstr)
            local liftIcon = ui.GetLiftIcon()
            local liftframe = ui.GetLiftFrame():GetTopParentFrame()
            local slot = tolua.cast(ctrl, 'ui::CSlot')
            
            local iconInfo = liftIcon:GetInfo()
            local invItem = AWWARDROBE_ACQUIRE_ITEM_BY_GUID(iconInfo:GetIESID())
            
            local cardObj = GetClassByType("Item", invItem.type)
            if cardObj == nil then
                return
            end
            if cardObj.CardGroupName == "REINFORCE_CARD" then
                ui.SysMsg(ClMsg("LegendReinforceCard_Not_Equip"));
                return
            end
            local parentSlotSet = slot:GetParent()
            if parentSlotSet == nil then
                return
            end
            local cardGroupName_slotset = cardObj.CardGroupName .. 'card_slotset'
            if parentSlotSet:GetName() ~= cardGroupName_slotset then
                --같은 card group 에 착용해야합니다 메세지 띄워줘야해
                ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
                return
            end
            local equipSound = "sys_armor_equip_new";
            imcSound.PlaySoundEvent(equipSound);
            AWWARDROBE_SETSLOT_CARD_AS_INV(slot, invItem)
    
    end)
end
function AWWARDROBE_SETSLOT(slot, invItem)
    SET_SLOT_INFO_FOR_WAREHOUSE(slot, invItem, "wholeitem")
    
    AWWARDROBE_DBGOUT("C" .. tostring(GetIES(invItem:GetObject()).ClassID))
    AWWARDROBE_DBGOUT("I" .. tostring(invItem:GetIESID()))
    
    slot:SetUserValue("clsid", tostring(GetIES(invItem:GetObject()).ClassID))
    slot:SetUserValue("iesid", tostring(invItem:GetIESID()))


end
function AWWARDROBE_SETSLOT_IKOR(slot, clsid, props)
    local invcls = GetClassByType("Item", clsid)
    SET_SLOT_ITEM_CLS(slot, invcls)
    SET_SLOT_STYLESET(slot, invcls)
    --AWWARDROBE_DBGOUT("C" .. tostring(GetIES(invItem:GetObject()).ClassID))
    --AWWARDROBE_DBGOUT("I" .. tostring(invItem:GetIESID()))
    AWWARDROBE_DBGOUT("IK" .. tostring(props))
    
    slot:SetUserValue("clsid", tostring(clsid))
    --slot:SetUserValue("iesid", tostring(invItem:GetIESID()))
    slot:SetUserValue("props", tostring(props))


end
function AWWARDROBE_SETSLOT_IKOR_BYITEM(parent, slotname, invItem)
    local invItemObj = GetIES(invItem:GetObject())
    local inheritItemName = TryGetProp(invItemObj, 'InheritanceItemName', 'None')
    local inheritItemCls = nil
    AWWARDROBE_DBGOUT("IKORD" .. slotname)
    AWWARDROBE_CLEARIKOR(parent:GetTopParentFrame(), slotname)
    --AWWARDROBE_CLEARIKOR(parent:GetTopParentFrame(), "R_" .. slotname)
    local slot = parent:GetChild(slotname)
    AUTO_CAST(slot)
    if TryGetProp(invItemObj, 'InheritanceItemName', 'None') ~= "None" then
        inheritItemName = TryGetProp(invItemObj, 'InheritanceItemName', 'None')
        inheritItemCls = GetClass('Item', inheritItemName)
        AWWARDROBE_DBGOUT(inheritItemName)
        AWWARDROBE_SETSLOT_IKOR(slot, inheritItemCls.ClassID, AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, false, true))
        AWWARDROBE_DBGOUT(inheritItemName .. "end")
    end
    local rslot = parent:GetChild("R_" .. slotname)
    AWWARDROBE_DBGOUT(tostring(rslot) .. parent:GetName())
    AUTO_CAST(rslot)
    if TryGetProp(invItemObj, 'InheritanceRandomItemName', 'None') ~= "None" then
        inheritItemName = TryGetProp(invItemObj, 'InheritanceRandomItemName', 'None')
        inheritItemCls = GetClass('Item', inheritItemName)
        AWWARDROBE_DBGOUT(inheritItemName)
        AWWARDROBE_SETSLOT_IKOR(rslot, inheritItemCls.ClassID, AWWARDROBE_GENERATE_IKORPROPSTRING(invItem, true, false))
    
    end

end
function AWWARDROBE_SETSLOT_CARD_AS_INV(slot, invItem)
    
    
    
    local lv = GET_ITEM_LEVEL_EXP(GetIES(invItem:GetObject()));
    AWWARDROBE_SETSLOT_CARD(slot, invItem.type, lv)
end
function AWWARDROBE_SETSLOT_CARD(slot, clsid, lv)
    
    
    local slotidx = slot:GetSlotIndex()
    
    local cardObj = GetClassByType('Item', clsid)
    if cardObj then
        slot:SetUserValue("clsid", tostring(clsid))
        slot:SetUserValue("lv", tostring(lv))
        
        local groupNameStr = cardObj.CardGroupName
        local groupSlotIndexOriginal = slot:GetSlotIndex()
        local groupSlotIndex
        if groupNameStr == 'ATK' then
            groupSlotIndex = groupSlotIndexOriginal + (0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif groupNameStr == 'DEF' then
            groupSlotIndex = groupSlotIndexOriginal + (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif groupNameStr == 'UTIL' then
            groupSlotIndex = groupSlotIndexOriginal + (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif groupNameStr == 'STAT' then
            groupSlotIndex = groupSlotIndexOriginal + (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif groupNameStr == 'LEG' then
            groupSlotIndex = groupSlotIndexOriginal + (4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        -- leg 카드는 slotindex = 12, 13번째 슬롯
        end
        
        local moncardGbox = GET_CHILD_RECURSIVELY(slot:GetTopParentFrame(), groupNameStr .. 'cardGbox');
        local card_slotset = GET_CHILD(moncardGbox, groupNameStr .. "card_slotset");
        
        local card_labelset = GET_CHILD(moncardGbox, groupNameStr .. "card_labelset");
        if card_slotset ~= nil and card_labelset then
            CARD_SLOT_SET(card_slotset, card_labelset, groupSlotIndexOriginal, clsid, lv, 0);
            local icon = slot:GetIcon()
            icon:SetTextTooltip('{ol}{s24}' .. cardObj.Name .. ' {img star_mark 24 24}' .. tostring(lv))
            icon:SetPosTooltip(0, 0)
            slot:EnableDrag(0)
            slot:EnablePop(0)
            slot:EnableDrop(1)
            slot:SetPosTooltip(0, 0);
            slot:SetEventScript(ui.RBUTTONUP, "AWWARDROBE_CARD_SLOT_RBTNUP_ITEM_INFO");
            slot:SetEventScript(ui.MOUSEMOVE, "None");
            slot:SetEventScriptArgNumber(ui.MOUSEMOVE, 0);
            slot:SetEventScript(ui.LOST_FOCUS, "None");
        end;
    else
        
        end
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
    local frame = ui.GetFrame("inventory")
    if quickslot.IsDoingWeaponSwap() == true then
        return
    end
    
    if index == nil then
        index = 1
    end
    AWWARDROBE_DBGOUT("SWAP " .. tostring(index))
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
        if (AWWARDROBE_INTERLOCK()) then
            
            ui.SysMsg(L_("alertworkingothers"))
            return
        end
        if (awframe:IsVisible() == 0) then
            
            ui.SysMsg(L_("alertopenaw"))
            return
        end
        
        
        local equipItemList = session.GetEquipItemList();
        local count = 0
        local needtoswap = false
        for k, _ in pairs(tbl) do
            if (k == "RH2" or k == "LH2") then
                AWWARDROBE_DBGOUT("NEEDTOSWAP")
                needtoswap = true
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
                local invItem = GET_PC_ITEM_BY_GUID(d.iesid)
                if (invItem ~= nil and true ~= invItem.isLockState) then
                    ReserveScript(string.format("AWWARDROBE_DEPOSITITEM(\"%s\")", d.iesid), delay)
                    delay = delay + 0.6
                end
            end
            ReserveScript('ui.SysMsg("' .. L_("alertcomplete") .. '");AWWARDROBE_INTERLOCK(false)', delay)
        end
    
    
    end)
end
function AWWARDROBE_INTERLOCK(state)
    if (state ~= nil) then
        g.interlocked = state
    end
    return g.interlocked
end

function AWWARDROBE_CALCULATE_SILVER_DETACH(tbl)
    local current = {}
    local silver = 0
    local todetach = {}
    --すでに装着済みをカウント
    for i = 1, MAX_NORMAL_MONSTER_CARD_SLOT_COUNT + LEGEND_CARD_SLOT_COUNT do
        local cardInfo = equipcard.GetCardInfo(i);
        if cardInfo ~= nil then
            local key = tostring(cardInfo:GetCardID() .. '#' .. tostring(cardInfo.cardLv))
            current[key] = current[key] or 0
            current[key] = current[key] + 1
        end
    end
    for k, v in pairs(tbl) do
        if v and v.clsid ~= 0 then
            --装着済みがあればカウント
            local key = tostring(v.clsid) .. '#' .. tostring(v.lv)
            local cardObj = GetClassByType("Item", v.clsid);
            if current[key] and current[key] > 0 then
                local lv = v.lv
                if lv == 1 then
                    lv = 0
                end
                silver = silver + (CALC_NEED_SILVER(cardObj, lv) or 0)
                current[key] = current[key] - 1
                if todetach[key] then
                    todetach[key].count = todetach[key].count + 1
                else
                    
                    todetach[key] = {
                        count = 1,
                        clsid = v.clsid,
                        lv = v.lv
                    
                    }
                
                end
            
            end
        end
    end
    return silver, todetach
end
function AWWARDROBE_CALCULATE_SILVER_ATTACH(tbl)
    local toattach = {}
    local silver = 0
    local current = {}
    --装着したいカードをカウント
    for k, v in pairs(tbl) do
        if v and v.clsid ~= 0 then
            
            local key = tostring(v.clsid) .. '#' .. tostring(v.lv)
            if toattach[key] then
                toattach[key].count = toattach[key].count + 1
            else
                toattach[key] = {
                    count = 1,
                    clsid = v.clsid,
                    lv = v.lv
                }
            end
        end
        tbl[k].filled = false
    end
    
    local toremove = {}
    --  --すでに装着済みをカウント
    --  for i = 1, 13 do
    --     local cardInfo = equipcard.GetCardInfo(i);
    --     if cardInfo ~= nil and cardInfo:GetCardID()~=0 then
    --         local key=tostring(cardInfo:GetCardID())..'#'..tostring(cardInfo.cardLv)
    --         AWWARDROBE_DBGOUT('CARD'..key)
    --         current[key]=
    --         current[key] or 0
    --         current[key]=
    --         current[key]+1
    --         local cardObj = GetClassByType("Item", cardInfo:GetCardID())
    --         local localidx=i
    --         if cardObj.CardGroupName=='ATK' then
    --             localidx=i-0
    --         elseif cardObj.CardGroupName=='DEF' then
    --             localidx=i-3
    --         elseif cardObj.CardGroupName=='UTIL' then
    --             localidx=i-6
    --         elseif cardObj.CardGroupName=='STAT' then
    --             localidx=i-9
    --         else
    --             localidx=i-12
    --         end
    --         slotemptyness[cardObj.CardGroupName][localidx]=0
    --         if toremove[i] then
    --             toremove[i].count=toremove[i].count+1
    --             toremove[i].remain=toremove[i].remain+1
    --         else
    --             toremove[i]={
    --                 count=1,
    --                 remain=1
    --                 clsid=cardInfo:GetCardID(),
    --                 lv=cardInfo.cardLv,
    --                 group=cardObj.CardGroupName,
    --                 remove=false
    --             }
    --         end
    --     else
    --         AWWARDROBE_DBGOUT('EMPTY'..i)
    --     end
    -- end
    for k, v in pairs(tbl) do
        if v and v.clsid ~= 0 then
            --すでに装着済みなら除外
            local key = tostring(v.clsid) .. '#' .. tostring(v.lv)
            local cardObj = GetClassByType("Item", v.clsid);
            AWWARDROBE_DBGOUT('CUR' .. key)
            if current[key] and current[key] > 0 then
                if toattach[key] then
                    if (toattach[key].count > 0) then
                        toattach[key].count = toattach[key].count - 1
                    end
                    if toattach[key].count == 0 then
                        toattach[key] = nil
                    end
                    tbl[k].filled = true
                    current[key] = current[key] - 1
                    AWWARDROBE_DBGOUT('found')
                
                end
            end
        end
    end
    local filled = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    local zone = {
        "ATK",
        "ATK",
        "ATK",
        "DEF",
        "DEF",
        "DEF",
        "UTIL",
        "UTIL",
        "UTIL",
        "STAT",
        "STAT",
        "STAT",
        "LEG",
    }
    --すでに装着済みをカウント
    for k, v in pairs(tbl) do
        if v and v.clsid ~= 0 then
            --すでに装着済みなら除外
            local key = tostring(v.clsid) .. '#' .. tostring(v.lv)
            local pass = false
            for i = 1, 13 do
                local cardInfo = equipcard.GetCardInfo(i);
                local cardObjB = GetClassByType("Item", v.clsid);
                if cardInfo == nil and filled[i] == 0 and zone[i] == cardObjB.CardGroupName then
                    
                    
                    
                    filled[i] = 1
                    pass = true
                    break
                end
            end
            if pass == false then
                for i = 1, 13 do
                    local cardInfo = equipcard.GetCardInfo(i);
                    if cardInfo ~= nil and (cardInfo:GetCardID() ~= v.clsid or cardInfo.cardLv ~= v.lv) then
                        local cardObjA = GetClassByType("Item", cardInfo:GetCardID());
                        local cardObjB = GetClassByType("Item", v.clsid);
                        if filled[i] == 0 and cardObjA.CardGroupName == cardObjB.CardGroupName then
                            if not toremove[key] then
                                toremove[key] = {
                                    count = 1,
                                    clsid = v.clsid,
                                    lv = v.lv
                                }
                            else
                                toremove[key].count = toremove[key].count + 1
                            end
                            
                            
                            filled[i] = 1
                            break
                        end
                    
                    end
                end
            end
        end
    end
    -- --スロットがあいているならシルバーの計算からは除外
    -- for k,v in pairs(tbl) do
    --     if v and v.clsid ~= 0 and not v.filled then
    --         local cardObj = GetClassByType("Item", v.clsid);
    --         AWWARDROBE_DBGOUT('FILLA'.. k)
    --         for kk,vv in ipairs(slotemptyness[cardObj.CardGroupName]) do
    --             if vv==1 then
    --                 local key=tostring(v.clsid)..'#'..tostring(v.lv)
    --                 slotemptyness[cardObj.CardGroupName][kk]=-1
    --                 AWWARDROBE_DBGOUT('FILL'.. key)
    --                 tbl[k].filled=true
    --                 break
    --             end
    --         end
    --     end
    -- end
    -- --最後に計算
    -- for k,v in pairs(tbl) do
    --     if v and v.clsid ~= 0 and v.count ~= 0 and not v.filled then
    --         local key=tostring(v.clsid)..'#'..tostring(v.lv)
    --         local cardObj = GetClassByType("Item", v.clsid);
    --         for kk,vv in pairs(toremove) do
    --             if not vv.remove and vv.group==cardObj.CardGroupName and toremove[key].remain>0 then
    --                 toremove[kk].count=toremove[kk].count+1
    --                 toremove[kk].remain=toremove[kk].remain-1
    --                 break
    --             end
    --         end
    --     end
    -- end
    for k, v in pairs(toremove) do
        
        local cardObj = GetClassByType("Item", v.clsid);
        
        local lv = v.lv
        if lv == 1 then
            lv = 0
        end
        silver = silver + (CALC_NEED_SILVER(cardObj, lv) or 0) * v.count
    
    end
    
    return silver, toattach, toremove
end

function AWWARDROBE_WEAR_MATCHED(frame, tbl)
    AWWARDROBE_try(function()
            
            local awframe = ui.GetFrame("accountwarehouse")
            
            
            if (AWWARDROBE_INTERLOCK()) then
                
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
            local items = {}
            for iesid, invItem, invObj in LS.items() do
                
                local judge = false
                
                for k, v in pairs(tbl) do
                    
                    if (iesid == v.iesid) then
                        --take
                        items[#items + 1] = {
                            iesid = iesid,
                            count = 1
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
            local needtoswap = false
            ReserveScript("AWWARDROBE_DO_WEAPON_SWAP(1)", delay)
            delay = delay + 0.25
            
            for k, v in pairs(tbl) do
                --それぞれ装備していく
                if (k ~= "RH2" and k ~= "LH2") then
                    ReserveScript(string.format('AWWARDROBE_WEAR("%s","%s")', v.iesid, k), delay)
                else
                    needtoswap = true
                end
                delay = delay + 0.5
            end
            if (needtoswap) then
                AWWARDROBE_DBGOUT("NEEDTOSWAP")
                ReserveScript("AWWARDROBE_DO_WEAPON_SWAP(2)", delay)
                delay = delay + 0.25
                for k, v in pairs(tbl) do
                    --それぞれ装備していく
                    if (k == "RH2" or k == "LH2") then
                        ReserveScript(string.format('AWWARDROBE_WEAR("%s","%s")', v.iesid, k:sub(1, -2)), delay)
                    end
                    delay = delay + 0.5
                end
                ReserveScript("AWWARDROBE_DO_WEAPON_SWAP(1)", delay)
                delay = delay + 0.25
            end
            
            ReserveScript('ui.SysMsg("' .. L_("alertcomplete") .. '"); AWWARDROBE_INTERLOCK(false)', delay)
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
        local table = {
            LH = "LH",
            RH = "RH",
            LH2 = "LH",
            RH2 = "RH",
        
        }
        AWWARDROBE_WEAPONSWAP_ITEM_DROP(table[spot], guid);
    
    end)
end
function AWWARDROBE_WEAPONSWAP_ITEM_DROP(spot, guid)
    local frame = ui.GetFrame("inventory");
    
    
    local invItem = GET_PC_ITEM_BY_GUID(guid);
    
    if invItem == nil then
        return;
    end
    
    
    
    local slot;
    if (spot == "LH" or spot == "LH2") then
        slot = GET_CHILD_RECURSIVELY(frame, "LH")
    elseif (spot == "RH" or spot == "RH2") then
        slot = GET_CHILD_RECURSIVELY(frame, "RH")
    end
    if nil == slot then
        return;
    end
    
    local obj = GetIES(invItem:GetObject());
    if obj.DefaultEqpSlot == "RH" or obj.DefaultEqpSlot == "LH" or obj.DefaultEqpSlot == "RH LH" or obj.DefaultEqpSlot == "TRINKET" then
        -- 슬롯은 좌우 두개므로
        local offset = 2;
        -- 일단 슬롯 위치가, 왼쪽오른쪽인지를 확인
        if slot:GetSlotIndex() % offset == 0 then
            
            if obj.DefaultEqpSlot ~= "RH" and obj.DefaultEqpSlot ~= "RH LH" then
                return;
            end
        end
        
        if slot:GetSlotIndex() % offset == 1 and obj.DefaultEqpSlot ~= "LH" and obj.DefaultEqpSlot ~= "TRINKET" then
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
            if (itemObj) then
                LS.putitem(itemguid, 1)
            end
    end)
end
function AWWARDROBE_UNWEARBYGUID(guid)
    
    AWWARDROBE_DBGOUT("UNWEARa" .. guid)
    local equipItem = GET_PC_ITEM_BY_GUID(guid)
    if (equipItem ~= nil) then
        local obj = GetIES(equipItem:GetObject());
        --CHAT_SYSTEM("GO")
        local spname
        if (equipItem.equipSpot ~= nil) then
            AWWARDROBE_DBGOUT("UNWEAR A" .. equipItem.equipSpot)
            spname = item.GetEquipSpotName(equipItem.equipSpot);
            AWWARDROBE_UNWEAR(equipItem.equipSpot)
        else
            local s = nil
            if (guid == quickslot.GetSwapWeaponGuid(0)) then
                s = 0
            elseif (guid == quickslot.GetSwapWeaponGuid(1)) then
                s = 1
            elseif (guid == quickslot.GetSwapWeaponGuid(2)) then
                s = 2
            elseif (guid == quickslot.GetSwapWeaponGuid(3)) then
                s = 3
            end
            AWWARDROBE_DBGOUT("UNWEAR" .. tostring(s))
            if s ~= nil then
                AWWARDROBE_DBGOUT("UNWEAR DO" .. tostring(s))
                imcSound.PlaySoundEvent('inven_unequip');
                
                quickslot.SetSwapWeaponInfo(s, "");
            end
        end
    
    else
        AWWARDROBE_DBGOUT(tostring(guid) .. "notfound")
    end
end
function AWWARDROBE_UNWEAR(equipSpot)
    
    imcSound.PlaySoundEvent('inven_unequip');
    local spot = equipSpot;
    item.UnEquip(spot);
end
function AWWARDROBE_REGISTER_CURRENT(frame)
    if g.tab_config == TAB_EQUIP then
        AWWARDROBE_REGISTER_CURRENTEQUIP(frame)
    elseif g.tab_config == TAB_CARD then
        AWWARDROBE_REGISTER_CURRENTCARD(frame)
    elseif g.tab_config == TAB_IKOR then
        AWWARDROBE_REGISTER_CURRENTIKOR(frame)
    end
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
                if spname ~= "RH" and spname ~= "LH" and equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and g.effectingspot[spname] then
                    --登録
                    local slot = GET_CHILD_RECURSIVELY(frame, spname, "ui::CSlot")
                    AWWARDROBE_SETSLOT(slot, equipItem)
                    AWWARDROBE_PLAYSLOTANIMATION(frame, spname)
                end
            
            end
            local gbox = frame:GetChildRecursively("equip")
            --左手右手用設定
            local rh1 = quickslot.GetSwapWeaponGuid(2);
            local lh1 = quickslot.GetSwapWeaponGuid(3);
            local rh2 = quickslot.GetSwapWeaponGuid(0);
            local lh2 = quickslot.GetSwapWeaponGuid(1);
            
            if rh1 ~= nil then
                local item = GET_ITEM_BY_GUID(rh1);
                if item ~= nil then
                    local quickspname = "RH"
                    local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
                    AWWARDROBE_SETSLOT(slot, item)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, quickspname)
                end
            end
            if lh1 ~= nil then
                local item = GET_ITEM_BY_GUID(lh1);
                if item ~= nil then
                    local quickspname = "LH"
                    local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
                    AWWARDROBE_SETSLOT(slot, item)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, quickspname)
                end
            end
            if rh2 ~= nil then
                local item = GET_ITEM_BY_GUID(rh2);
                if item ~= nil then
                    local quickspname = "RH2"
                    local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
                    AWWARDROBE_SETSLOT(slot, item)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, quickspname)
                end
            end
            if lh2 ~= nil then
                local item = GET_ITEM_BY_GUID(lh2);
                if item ~= nil then
                    local quickspname = "LH2"
                    local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
                    AWWARDROBE_SETSLOT(slot, item)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, quickspname)
                end
            end
            imcSound.PlaySoundEvent('inven_equip');
    end)
end
function AWWARDROBE_REGISTER_CURRENTCARD(frame)
    --現在の装備を登録
    AWWARDROBE_try(function()
            --先にクリア
            AWWARDROBE_CLEARALLCARDS(frame)
            
            local items = {}
            local cnt = 1
            for i = 1, 5 do
                
                local max = 3
                if i == 5 then
                    max = 1
                end
                
                local slotset = frame:GetChildRecursively(slotsetnames[i])
                AUTO_CAST(slotset)
                for slotidx = 0, max - 1 do
                    local slot = slotset:GetSlotByIndex(slotidx)
                    local cardInfo = equipcard.GetCardInfo(cnt)
                    cnt = cnt + 1
                    if cardInfo then
                        
                        AWWARDROBE_SETSLOT_CARD(slot, cardInfo:GetCardID(), cardInfo.cardLv)
                    end
                end
            
            end
            imcSound.PlaySoundEvent('inven_equip');
    end)
end
function AWWARDROBE_REGISTER_CURRENTIKOR(frame)
    --現在の装備を登録
    AWWARDROBE_try(function()
            --先にクリア
            AWWARDROBE_DBGOUT("CLEAR")
            AWWARDROBE_CLEARALLIKOR(frame)
            AWWARDROBE_DBGOUT("CLEARD")
            local gbox = frame:GetChildRecursively("gbox_Ikor")
            local equipItemList = session.GetEquipItemList();
            local items = {}
            
            for i = 0, equipItemList:Count() - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                --local obj = GetIES(item.GetNoneItem(equipItem.equipSpot));
                --CHAT_SYSTEM("GO")
                local spname = item.GetEquipSpotName(equipItem.equipSpot);
                AWWARDROBE_DBGOUT("EQ" .. i .. spname)
                if spname ~= "RH" and spname ~= "LH" and equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) and g.effectingikorspot[spname] ~= nil then
                    --登録
                    local slot = GET_CHILD_RECURSIVELY(gbox, spname, "ui::CSlot")
                    
                    AWWARDROBE_SETSLOT_IKOR_BYITEM(slot:GetParent(), spname, equipItem)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, 'R_' .. spname)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, spname)
                end
            end
            --左手右手用設定
            local rh1 = quickslot.GetSwapWeaponGuid(2);
            local lh1 = quickslot.GetSwapWeaponGuid(3);
            local rh2 = quickslot.GetSwapWeaponGuid(0);
            local lh2 = quickslot.GetSwapWeaponGuid(1);
            
            if rh1 ~= nil then
                local item = GET_ITEM_BY_GUID(rh1);
                if item ~= nil then
                    local quickspname = "RH"
                    local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
                    AWWARDROBE_SETSLOT_IKOR_BYITEM(slot:GetParent(), quickspname, item)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, 'R_' .. quickspname)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, quickspname)
                end
            end
            if lh1 ~= nil then
                local item = GET_ITEM_BY_GUID(lh1);
                if item ~= nil then
                    local quickspname = "LH"
                    local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
                    AWWARDROBE_SETSLOT_IKOR_BYITEM(slot:GetParent(), quickspname, item)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, 'R_' .. quickspname)
                    AWWARDROBE_PLAYSLOTANIMATION(gbox, quickspname)
                end
            end
            -- if rh2 ~= nil then
            --     local item = GET_ITEM_BY_GUID(rh2);
            --     if item ~= nil then
            --         local quickspname = "RH2"
            --         local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
            --         AWWARDROBE_SETSLOT_IKOR_BYITEM(slot:GetParent(),spname,equipItem )
            --         AWWARDROBE_PLAYSLOTANIMATION(frame, 'R_'..quickspname)
            --         AWWARDROBE_PLAYSLOTANIMATION(frame, quickspname)
            --     end
            -- end
            -- if lh2 ~= nil then
            --     local item = GET_ITEM_BY_GUID(lh2);
            --     if item ~= nil then
            --         local quickspname = "LH2"
            --         local slot = GET_CHILD_RECURSIVELY(gbox, quickspname, "ui::CSlot")
            --         AWWARDROBE_SETSLOT_IKOR_BYITEM(slot:GetParent(),spname,equipItem )
            --         AWWARDROBE_PLAYSLOTANIMATION(frame, quickspname)
            --         AWWARDROBE_PLAYSLOTANIMATION(frame, 'R_'..quickspname)
            --     end
            -- end
            imcSound.PlaySoundEvent('inven_equip');
    end)
end
function AWWARDROBE_CLEAREQUIP(frame, spname)
    --現在の装備を登録
    AWWARDROBE_try(function()
        local gbox = frame:GetChildRecursively("equip")
        local slot = GET_CHILD_RECURSIVELY(gbox, spname, "ui::CSlot")
        local slot_bg = GET_CHILD_RECURSIVELY(gbox, spname .. "_bg", "ui::CSlot")
        
        slot:ClearIcon()
        slot:SetMaxSelectCount(0)
        slot:SetText('')
        slot:RemoveAllChild()
        slot:SetSkinName(slot_bg:GetSkinName())
        slot:SetUserValue('clsid', nil)
        slot:SetUserValue('iesid', nil)
    
    end)
end
function AWWARDROBE_CLEARIKOR(frame, spname)
    --現在の装備を登録
    AWWARDROBE_try(function()
        local gbox = frame:GetChildRecursively("gbox_Ikor")
        local slot = GET_CHILD_RECURSIVELY(gbox, spname, "ui::CSlot")
        local slot_bg = GET_CHILD_RECURSIVELY(gbox, spname .. "_bg", "ui::CSlot")
        
        slot:ClearIcon()
        slot:SetMaxSelectCount(0)
        slot:SetText('')
        slot:RemoveAllChild()
        slot:SetSkinName(slot_bg:GetSkinName())
        slot:SetUserValue('clsid', nil)
        slot:SetUserValue('iesid', nil)
        slot:SetUserValue('props', nil)
    
    end)
end
function AWWARDROBE_CLEARALL(frame)
    if g.tab_config == TAB_EQUIP then
        AWWARDROBE_CLEARALLEQUIPS(frame)
    elseif g.tab_config == TAB_CARD then
        AWWARDROBE_CLEARALLCARDS(frame)
    elseif g.tab_config == TAB_IKOR then
        AWWARDROBE_CLEARALLIKOR(frame)
    end
end
function AWWARDROBE_CLEARALLEQUIPS(frame)
    
    
    for k, _ in pairs(g.effectingspot) do
        AWWARDROBE_CLEAREQUIP(frame, k)
    end

end
function AWWARDROBE_CLEARALLIKOR(frame)
    
    
    for k, _ in pairs(g.effectingikorspot) do
        AWWARDROBE_CLEARIKOR(frame, k)
        AWWARDROBE_CLEARIKOR(frame, "R_" .. k)
    end

end
function AWWARDROBE_CLEARCARD(frame, slotIndex)
    local groupnames = {
        'ATK',
        'DEF',
        'UTIL',
        'STAT',
        'LEG',
    }
    local groupNameStr = groupnames[math.floor((slotIndex - 1) / 3) + 1]
    local cardGroupName = groupNameStr
    local groupSlotIndex = slotIndex
    if cardGroupName == 'ATK' then
        groupSlotIndex = slotIndex - (0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif cardGroupName == 'DEF' then
        groupSlotIndex = slotIndex - (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif cardGroupName == 'UTIL' then
        groupSlotIndex = slotIndex - (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif cardGroupName == 'STAT' then
        groupSlotIndex = slotIndex - (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    elseif cardGroupName == 'LEG' then
        groupSlotIndex = slotIndex - (4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    end
    
    local gBox = GET_CHILD_RECURSIVELY(frame, groupNameStr .. 'cardGbox');
    local card_slotset = GET_CHILD(gBox, groupNameStr .. "card_slotset");
    local card_labelset = GET_CHILD(gBox, groupNameStr .. "card_labelset");
    AWWARDROBE_DBGOUT('' .. tostring(card_slotset) .. ':' .. tostring(card_labelset) .. "card_labelset")
    if card_slotset ~= nil and card_labelset ~= nil then
        local slot = card_slotset:GetSlotByIndex(groupSlotIndex - 1);
        if slot ~= nil then
            slot:ClearIcon();
        end;
        
        local slot_label = card_labelset:GetSlotByIndex(groupSlotIndex - 1);
        if slot_label ~= nil then
            local icon_label = CreateIcon(slot_label)
            if cardGroupName == 'ATK' then
                icon_label:SetImage('red_cardslot1')
            elseif cardGroupName == 'DEF' then
                icon_label:SetImage('blue_cardslot1')
            elseif cardGroupName == 'UTIL' then
                icon_label:SetImage('purple_cardslot1')
            elseif cardGroupName == 'STAT' then
                icon_label:SetImage('green_cardslot1')
            elseif cardGroupName == 'LEG' then
                icon_label:SetImage('legendopen_cardslot')
            end
        end;
        slot:SetUserValue('clsid', nil)
        slot:SetUserValue('lv', nil)
    
    end;

end
function AWWARDROBE_CLEARALLCARDS(frame)
    
    -- normal cards
    for i = 1, 13 do
        AWWARDROBE_CLEARCARD(frame, i)
    
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
end

function AWWARDROBE_AW_ON_TAB(frame, ctrl)
    if g.tab_aw == TAB_EQUIP then
        g.tab_aw = TAB_IKOR
    else
        g.tab_aw = TAB_EQUIP
    end
    local tabcfg = g.tab_aw
    local tabctrl = ctrl
    
    
    if tabcfg == TAB_EQUIP then
        tabctrl:SetText(L_('tabequip'))
    elseif tabcfg == TAB_CARD then
        tabctrl:SetText(L_('tabcard'))
    elseif tabcfg == TAB_IKOR then
        tabctrl:SetText(L_('tabikor'))
    end
    AWWARDROBE_UPDATE_DROPBOXAW()
end
function AWWARDROBE_CONFIG_ON_TAB(frame, ctrl)
    if g.tab_config == TAB_EQUIP then
        g.tab_config = TAB_IKOR
    else
        g.tab_config = TAB_EQUIP
    end
    local tabcfg = g.tab_config
    local tabctrl = ctrl
    local equip = frame:GetChildRecursively('equip')
    --local equip2 = frame:GetChildRecursively('gbox_Dressed')
    local card = frame:GetChildRecursively('mainGbox')
    local ikor = frame:GetChildRecursively('gbox_Ikor')
    
    
    
    if tabcfg == TAB_EQUIP then
        tabctrl:SetText(L_('tabequip'))
        equip:ShowWindow(1)
        --equip2:ShowWindow(1)
        card:ShowWindow(0)
        ikor:ShowWindow(0)
    
    elseif tabcfg == TAB_CARD then
        tabctrl:SetText(L_('tabcard'))
        equip:ShowWindow(0)
        --equip2:ShowWindow(0)
        card:ShowWindow(1)
        ikor:ShowWindow(0)
    elseif tabcfg == TAB_IKOR then
        tabctrl:SetText(L_('tabikor'))
        equip:ShowWindow(0)
        --equip2:ShowWindow(0)
        card:ShowWindow(0)
        ikor:ShowWindow(1)
    end
    AWWARDROBE_UPDATE_DROPBOX()
end

function AWWARDROBE_CARD_SLOT_RBTNUP_ITEM_INFO(frame, slot, argstr, argnum)
    AWWARDROBE_try(function()
        frame = ui.GetFrame('awwardrobe')
        local icon = slot:GetIcon();
        if icon == nil then
            return;
        end;
        
        local parentSlotSet = slot:GetParent()
        if parentSlotSet == nil then
            return
        end
        
        local slotIndex = slot:GetSlotIndex()
        
        if parentSlotSet:GetName() == 'ATKcard_slotset' then
            slotIndex = slotIndex + (0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif parentSlotSet:GetName() == 'DEFcard_slotset' then
            slotIndex = slotIndex + (1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif parentSlotSet:GetName() == 'UTILcard_slotset' then
            slotIndex = slotIndex + (2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif parentSlotSet:GetName() == 'STATcard_slotset' then
            slotIndex = slotIndex + (3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        elseif parentSlotSet:GetName() == 'LEGcard_slotset' then
            slotIndex = slotIndex + (4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
        end
        
        AWWARDROBE_CLEARCARD(frame, slotIndex + 1)
    
    end)
end
