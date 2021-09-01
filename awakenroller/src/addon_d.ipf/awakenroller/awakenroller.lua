-- awakenroller
--アドオン名（大文字）
local addonName = 'awakenroller'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'awakenroller'
g.debug = false
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.invItem = nil
g.invItemIESID = nil
g.groupCount = nil
g.needs = nil
g.needscount = 0
g.attempts = -1
g.prop = nil
g.go = false
g.propvalue = 0
g.useadrasive = false
g.usehighadrasive = false

local MARKET_OPTION_GROUP_PROP_LIST = {

    DEF = {
        'ADD_DEF',        --物理防御力
        'ADD_MDEF',       --魔法防御力
        'ResAdd_Damage',  --追加ダメージ抵抗
        'CRTDR',          --クリティカル抵抗
        'ADD_DR',         --回避
        'MHP',            --MaxHP
        'MSP',            --MaxSP
        'RHP',            --HP回復力
        'RSP',            --SP回復力
    },
    WEAPON = {
        'CRTHR',          --クリティカル発生
        'PATK',           --物理攻撃力
        'ADD_MATK',       --魔法攻撃力
        'CRTATK',         --物理クリティカル攻撃力
        'CRTMATK',        --魔法クリティカル攻撃力
        'Add_Damage_Atk', --追加ダメージ
        'ADD_HR',         --命中
    }
}
--ライブラリ読み込み
CHAT_SYSTEM('[AR]loaded')
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
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
        end,
        catch = function(error)
        end
    }
end
function AWAKENROLLER_SAVE_SETTINGS()
    --AWAKENROLLER_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function AWAKENROLLER_SAVE_ALL()
    AWAKENROLLER_SAVETOSTRUCTURE()
    AWAKENROLLER_SAVE_SETTINGS()
    ui.MsgBox('保存しました')
end
function AWAKENROLLER_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('awakenroller')
end

function AWAKENROLLER_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {foods = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end

    AWAKENROLLER_UPGRADE_SETTINGS()
    AWAKENROLLER_SAVE_SETTINGS()
    AWAKENROLLER_LOADFROMSTRUCTURE()
end

function AWAKENROLLER_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('awakenroller')
end

function AWAKENROLLER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function AWAKENROLLER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(AWAKENROLLER_GETCID()))
            frame:ShowWindow(0)

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg('SUCCESS_ITEM_AWAKENING', 'AWAKENROLLER_SUCCESS')
            acutil.setupHook(AWAKENROLLER_OPEN_ITEMDUNGEON_SELLER, 'OPEN_ITEMDUNGEON_SELLER')
            acutil.setupHook(AWAKENROLLER_OPEN_ITEMDUNGEON_BUYER, 'OPEN_ITEMDUNGEON_BUYER')
            acutil.setupHook(AWAKENROLLER_ITEMDUNGEN_UI_CLOSE, 'ITEMDUNGEN_UI_CLOSE')
            acutil.setupHook(AWAKENROLLER_ITEMDUNGEON_DROP_ITEM, 'ITEMDUNGEON_DROP_ITEM')
            acutil.setupHook(AWAKENROLLER_ITEMDUNGEON_CLEAR_TARGET, 'ITEMDUNGEON_CLEAR_TARGET')
            acutil.setupHook(AWAKENROLLER_ITEMDUNGEON_INV_RBTN, 'ITEMDUNGEON_INV_RBTN')
       
            frame:ShowWindow(0)

            AWAKENROLLER_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AWAKENROLLER_IS_WEAPON(invItem)
    local cls = GetClassByType("Item",invItem.type);
    if cls.GroupName=='Weapon' or cls.GroupName=='SubWeapon' then
        return true
    else
        return false
    end
end
function AWAKENROLLER_OPEN_ITEMDUNGEON_SELLER()
    EBI_try_catch {
        try = function()
            OPEN_ITEMDUNGEON_SELLER_OLD()
            local frame = ui.GetFrame('itemdungeon')
            frame:RemoveChild('btnactivate')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AWAKENROLLER_ITEMDUNGEON_INV_RBTN(itemobj, invslot, invguid)
    ITEMDUNGEON_INV_RBTN_OLD(itemobj, invslot, invguid)
    local frame = ui.GetFrame("itemdungeon");
	if frame == nil then
		return
	end

	if invslot:IsSelected() == 1 then
		ITEMDUNGEON_CLEARUI(frame)
	else
		local invItem, isEquip = GET_PC_ITEM_BY_GUID(invguid);	
		if nil == invItem then
			return;
		end
	
		if nil ~= isEquip then
			ui.SysMsg(ClMsg("CannotDropItem"));
			return;
		end

		if true == invItem.isLockState then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return;
		end
	
		local itemObj = GetIES(invItem:GetObject());
		local targetSlot = GET_CHILD_RECURSIVELY(frame, "targetSlot");
		if IS_EQUIP(itemObj) == true then
			-- 장비 등록		
			if IS_ENABLE_GIVE_HIDDEN_PROP_ITEM(itemObj) == false then
				
				return;
			end
            local frame = ui.GetFrame('itemdungeon')
            local btn = frame:GetChild('btnactivate')
        
            AUTO_CAST(btn)
        
            btn:SetEnable(1)
            AWAKENROLLER_INITFRAME(invItem)
		end	
	end
end
function AWAKENROLLER_OPEN_ITEMDUNGEON_BUYER(groupName, sellType, handle)
    EBI_try_catch {
        try = function()
            OPEN_ITEMDUNGEON_BUYER_OLD(groupName, sellType, handle)
            local frame = ui.GetFrame('itemdungeon')
            local btn = frame:CreateOrGetControl('button', 'btnactivate', 20, 80, 120, 30)
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, 'AWAKENROLLER_TOGGLEFRAME')
            btn:SetText('{ol}Auto Reroll')
            btn:SetEnable(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AWAKENROLLER_ITEMDUNGEN_UI_CLOSE(frame)
    ITEMDUNGEN_UI_CLOSE_OLD(frame)
    local frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)

    local frame = ui.GetFrame('itemdungeon')
    local btn = frame:GetChild('btnactivate')
    if btn then
        AUTO_CAST(btn)

        btn:SetEnable(0)
    end
end

function AWAKENROLLER_ITEMDUNGEON_DROP_ITEM(parent, ctrl)
    ITEMDUNGEON_DROP_ITEM_OLD(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local liftIcon = ui.GetLiftIcon()
    local slot = tolua.cast(ctrl, ctrl:GetClassString())
    local iconInfo = liftIcon:GetInfo()
    local invItem, isEquip = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
    if nil == invItem then
        return
    end

    if nil ~= isEquip then
        ui.SysMsg(ClMsg('CannotDropItem'))
        return
    end

    if true == invItem.isLockState then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end

    local itemObj = GetIES(invItem:GetObject())
    if IS_ENABLE_GIVE_HIDDEN_PROP_ITEM(itemObj) == false then
        ui.SysMsg(ClMsg('ItemIsNotEnchantable1'))
        return
    end
    local frame = ui.GetFrame('itemdungeon')
    local btn = frame:GetChild('btnactivate')

    AUTO_CAST(btn)

    btn:SetEnable(1)
    AWAKENROLLER_INITFRAME(invItem)
end

function AWAKENROLLER_ITEMDUNGEON_CLEAR_TARGET(parent, ctrl)
    local frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end

function AWAKENROLLER_TOGGLEFRAME()
    ui.ToggleFrame(g.framename)
    local frame = ui.GetFrame(g.framename)
    if frame:IsVisible() == 1 and g.invItem then
        AWAKENROLLER_INITFRAME(g.invItem)
    end
end
function AWAKENROLLER_GETABRASIVECOUNTFROMINV(argnum)
    local cnt = 0
    local pc = GetMyPCObject()
    local invItemList = GetInvItemList(pc)
    local curCount = #invItemList
    for _, guid in ipairs(invItemList) do
        local invItem = session.GetInvItemByGuid(guid)
        local cls = GetClassByType('Item',invItem.type)
       
            local prop = TryGetProp(cls, 'NumberArg1') or 0
            if  cls.StringArg == "AbrasiveStone" and invItem.isLockState == false and (not argnum or prop == argnum) then
                cnt = cnt + invItem.count
                break
            end
        
    end
    return cnt
end
function AWAKENROLLER_GETAWAKENSTONEFROMINV()
    local cnt = 0
    local pc = GetMyPCObject()
    local invItemList = GetInvItemList(pc)
    local curCount = #invItemList
    for _, guid in ipairs(invItemList) do
        local invItem = session.GetInvItemByGuid(guid)
        local cls = GetClassByType('Item',invItem.type)
  
        local prop = TryGetProp(cls, 'NumberArg1') or 0
        if IS_ITEM_AWAKENING_STONE(cls)and invItem.isLockState == false then
            cnt = cnt + invItem.count
            
        end

    end
    return cnt
    
end
function AWAKENROLLER_INITFRAME(invItem)
    EBI_try_catch {
        try = function()
            local obj = GetIES(invItem:GetObject())

            local frame = ui.GetFrame(g.framename)
            frame:EnableMove(0)
            frame:SetOffset(450, 300)
            frame:Resize(400, 450)
            local gbox = frame:CreateOrGetControl('groupbox', 'gbox', 10, 100, frame:GetWidth() - 20, 300)
            AUTO_CAST(gbox)
            gbox:RemoveAllChild()

            local txtoption = frame:CreateOrGetControl('richtext', 'txttype', 30, 20, 50, 30)
            txtoption:SetText('{ol}{s20}Awaken Option: ')
            local cmboption = frame:CreateOrGetControl('droplist', 'cmbtype', 30, 50, 300, 20)
            AUTO_CAST(cmboption)
            cmboption:SetSkinName('droplist_normal')
            cmboption:SetTextTooltip('絞り込むオプションの種類です')
            cmboption:ClearItems()
            local idx = 0
            local props
            if AWAKENROLLER_IS_WEAPON(invItem) then
                props=MARKET_OPTION_GROUP_PROP_LIST.WEAPON
            else
                props=MARKET_OPTION_GROUP_PROP_LIST.DEF
            end
            for k, v in pairs(props) do
              
                    cmboption:AddItem(idx, ScpArgMsg(v))
                    idx = idx + 1
                
            end
            local txtmorethaneq = frame:CreateOrGetControl('richtext', 'txtmorethaneq', 30, 90, 160, 30)
            txtmorethaneq:SetText('{ol}{s14}is more than or equal {s16}(≧)')
            local numvalue = frame:CreateOrGetControl('numupdown', 'numvalue', 240, 80, 150, 30)
            AUTO_CAST(numvalue)

            numvalue:MakeButtons('btn_numdown', 'btn_numup', 'editbox_s')
            numvalue:SetMinValue(0)
            numvalue:SetMaxValue(9999999)
            numvalue:SetNumberValue(0)
            numvalue:SetIncrValue(1)
            numvalue:Invalidate()
            numvalue:SetTextTooltip('オプションが指定した値以上なら終了し、未満ならロールを継続します')
            local txtattention = frame:CreateOrGetControl('richtext', 'txtattention', 30, 120, 50, 30)
            txtattention:SetText('{ol}{b}{s16}{#FF8888}The option you choose may not always appear.')
            local txtprice = frame:CreateOrGetControl('richtext', 'txtprice', 30, 180, 50, 30)

            local _, cnt = GET_ITEM_AWAKENING_PRICE(invItem)
            local groupInfo = session.autoSeller.GetByIndex('Awakening', 0)
            local price = cnt * groupInfo.price
            txtprice:SetText('{ol}Price per attempt: ' .. price)
            local txtcount = frame:CreateOrGetControl('richtext', 'txtcount', 30, 210, 50, 40)
            txtcount:SetText('{ol}{s24}{#FFFF77}-- Offering Ingredients --')
            local txtstones = frame:CreateOrGetControl('richtext', 'txtstones', 30, 240, 50, 40)
            txtstones:SetText('{ol}{s20}{img icon_item_awakeningstone 35 35}: ' .. AWAKENROLLER_GETAWAKENSTONEFROMINV())
            txtstones:SetTextTooltip('各種覚醒石を含んだ個数です')
            --local txtadrasives = frame:CreateOrGetControl('richtext', 'txtadrasives', 180, 240, 50, 40)
            --txtadrasives:SetText('{ol}{s20}{img icon_item_awakemisc01 35 35}:'..AWAKENROLLER_GETCOUNTFROMINV(g.adrasive))
            local chkuseadrasive = frame:CreateOrGetControl('checkbox', 'chkuseadrasive', 30, 270, 50, 30)
            AUTO_CAST(chkuseadrasive)
            chkuseadrasive:SetCheck(0)
            chkuseadrasive:SetText('{ol}Use LV400 Abrasive {img icon_item_awakemisc01 35 35}: ' .. AWAKENROLLER_GETABRASIVECOUNTFROMINV(400))
            chkuseadrasive:SetEventScript(ui.LBUTTONUP, 'AWAKENROLLER_UPDATENUMATTEMPT')
            chkuseadrasive:SetTextTooltip('LV400覚醒研磨剤を使用します。')
            local chkusehighadrasive = frame:CreateOrGetControl('checkbox', 'chkusehighadrasive', 30, 300, 50, 30)
            AUTO_CAST(chkusehighadrasive)
            chkusehighadrasive:SetCheck(1)
            chkusehighadrasive:SetText("{ol}Use Lv430 Abrasive {s12}Lv430{/}{img icon_item_awakemisc01 35 35}: " .. AWAKENROLLER_GETABRASIVECOUNTFROMINV( 430))
            chkusehighadrasive:SetEventScript(ui.LBUTTONUP, 'AWAKENROLLER_UPDATENUMATTEMPT')
            chkusehighadrasive:SetTextTooltip('Lv430覚醒研磨剤を使用します')
            local txtattempt = frame:CreateOrGetControl('richtext', 'txtattempt', 30, 360, 50, 30)
            txtattempt:SetText('{ol}Max Attempts:')

            local numattempts = frame:CreateOrGetControl('numupdown', 'numattempt', 150, 360, 80, 30)
            AUTO_CAST(numattempts)

            numattempts:MakeButtons('btn_numdown', 'btn_numup', 'editbox_s')
            numattempts:SetMinValue(0)
            numattempts:SetMaxValue(1000)
            numattempts:SetNumberValue(100)
            AWAKENROLLER_UPDATENUMATTEMPT()
            numattempts:SetIncrValue(1)
            numattempts:Invalidate()
            numattempts:SetTextTooltip('試行回数です。覚醒石の数を超えて指定することはできません。')
            local btngo = frame:CreateOrGetControl('button', 'btngo', 0, 240, 100, 40)
            btngo:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            btngo:SetOffset(0, 20)
            btngo:SetSkinName('base_btn')
            btngo:SetText('{ol}EXECUTE')
            btngo:SetEventScript(ui.LBUTTONUP, 'AWAKENROLLER_CONFIRM')

            g.invItem = invItem
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AWAKENROLLER_UPDATENUMATTEMPT(aa,ctrl)
    local frame = ui.GetFrame(g.framename)
    local chkuseadrasive = frame:GetChild('chkuseadrasive')
    AUTO_CAST(chkuseadrasive)
    local chkusehighadrasive = frame:GetChild('chkusehighadrasive')
    AUTO_CAST(chkusehighadrasive)
    local useadrasive = chkuseadrasive:IsChecked()
    local usehighadrasive = chkusehighadrasive:IsChecked()
    local adrasive = 0
    local mx
    if useadrasive==1 and usehighadrasive==1 and ctrl then
        chkuseadrasive:SetCheck(0)
        chkusehighadrasive:SetCheck(0)
        AUTO_CAST(ctrl)
        ctrl:SetCheck(1)
        useadrasive = chkuseadrasive:IsChecked()
        usehighadrasive = chkusehighadrasive:IsChecked()
    end

    if useadrasive == 1 then
       
    
        adrasive = AWAKENROLLER_GETABRASIVECOUNTFROMINV(400)
        
        mx = math.min(AWAKENROLLER_GETAWAKENSTONEFROMINV(), adrasive)
    elseif usehighadrasive == 1 then
        adrasive = AWAKENROLLER_GETABRASIVECOUNTFROMINV( 430)
        mx = math.min(AWAKENROLLER_GETAWAKENSTONEFROMINV(), adrasive)
    else
        mx = AWAKENROLLER_GETAWAKENSTONEFROMINV()
    end

    local numattempts = frame:GetChild('numattempt')
    AUTO_CAST(numattempts)

    numattempts:SetMaxValue(mx)
    if (numattempts:GetNumber() > mx) then
        numattempts:SetNumberValue(mx)
    end

    numattempts:Invalidate()
end

function AWAKENROLLER_CONFIRM()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            local invItem = g.invItem
            local chkuseadrasive = frame:GetChild('chkuseadrasive')
            AUTO_CAST(chkuseadrasive)
            local chkusehighadrasive = frame:GetChild('chkusehighadrasive')
            AUTO_CAST(chkusehighadrasive)

            g.useadrasive = chkuseadrasive:IsChecked() == 1
            g.usehighadrasive = chkusehighadrasive:IsChecked() == 1
            if  not  g.useadrasive and not g.usehighadrasive then
                ui.SysMsg('Abrasive is required for item awakening.')
                return
            end
            local numattempts = frame:GetChild('numattempt')
            AUTO_CAST(numattempts)
            local numofattempts = numattempts:GetNumber()
            local txt = '{ol}{#FFFFFF}'
            local cmboption = frame:GetChild('cmbtype')
            AUTO_CAST(cmboption)
            local prop
            local idx = 0
            local numvalue = frame:GetChild('numvalue')
            AUTO_CAST(numvalue)
            local props
            if AWAKENROLLER_IS_WEAPON(invItem) then
                props=MARKET_OPTION_GROUP_PROP_LIST.WEAPON
            else
                props=MARKET_OPTION_GROUP_PROP_LIST.DEF
            end
            for k, v in pairs(props) do
                
                    if cmboption:GetSelItemIndex() == idx then
                        prop = v
                        g.prop = v
                    end
                    idx = idx + 1
                
            end
            if numofattempts <= 0 then
                ui.SysMsg('Max Attempts must be higher than 1.')
                return
            end

            g.propvalue = numvalue:GetNumber()

            txt = txt .. 'Target: ' .. ScpArgMsg(prop) .. ' >= ' .. g.propvalue .. '{nl}'
            txt = txt .. 'Max Attempts:' .. numofattempts .. '{nl}'

            local _, cnt = GET_ITEM_AWAKENING_PRICE(invItem)
            local groupInfo = session.autoSeller.GetByIndex('Awakening', 0)
            local price = cnt * groupInfo.price
            txt = txt .. 'Max Price:' .. price * numofattempts .. '{nl}'
            txt = txt .. 'Do you want to do auto item awaken?'

            g.attempts = numofattempts
            ui.MsgBox(txt, ' AWAKENROLLER_EXECUTE()', 'None')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AWAKENROLLER_EXECUTE()
    EBI_try_catch {
        try = function()
            g.go = true

            ui.SetEscapeScp('AWAKENROLLER_CANCEL()')
            AWAKENROLLER_DO_EXECUTE()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AWAKENROLLER_DO_EXECUTE()
    EBI_try_catch {
        try = function()
            local invItem = g.invItem
            local stones = {}
            local adrasives = {}

            local _, cnt = GET_ITEM_AWAKENING_PRICE(invItem)
            local groupInfo = session.autoSeller.GetByIndex('Awakening', 0)
            local price = tostring(cnt * groupInfo.price)
            local money = GET_TOTAL_MONEY_STR()
            if IsGreaterThanForBigNumber(price, money) == 1 then
                ui.SysMsg('Insufficient money.')
                AWAKENROLLER_CANCEL()
                return
            end
            DBGOUT('hoge3')
            local invItemList = session.GetInvItemList()
            local guidList = invItemList:GetGuidList();
	        local ccnt = guidList:Count();
            --石と研磨剤を列挙
            for i = 0, ccnt - 1 do
                
                local guid = guidList:Get(i);
                local iv=invItemList:GetItemByGuid(guid);

                if iv ~= nil then
                   
                    if iv.isLockState == false  then
                        local itemobj = GetIES(iv:GetObject())
                        
                        if IS_ITEM_AWAKENING_STONE(itemobj) then
                            
                            stones[#stones + 1] ={
                                iesid = guid,
                                has = iv.hasLifeTime,
                                time = GET_ITEM_REMAIN_LIFETIME_BY_SEC(itemobj)
                            }
                            
                        end
                    
                        if g.useadrasive or g.usehighadrasive then
                            if  itemobj.StringArg == "AbrasiveStone"  then
                                DBGOUT('hoge5:'..i..'/'..ccnt-1)
                                local cls = GetClassByType('Item', v)
                                
                                local prop = TryGetProp(itemobj, 'NumberArg1') or 0
                                DBGOUT('hoge6:'..i..'/'..ccnt-1)
                                if (prop < 430 and not g.usehighadrasive )or (prop == 430 and g.usehighadrasive)then
                                    adrasives[#adrasives + 1] = {
                                        iesid = guid,
                                        has = iv.hasLifeTime,
                                        time = GET_ITEM_REMAIN_LIFETIME_BY_SEC(itemobj)
                                    }
                                end
                                
                                
                            end
                        
                        end
                    end
                end
            end
            -- DBGOUT('hoge2')
            --ソート
            table.sort(
                stones,
                function(a, b)
                    local ta = 100000000
                    local tb = 100000000
                    if a.has then
                        ta = tonumber(a.time)
                    end
                    if b.has then
                        tb = tonumber(b.time)
                    end
                    return ta < tb
                end
            )
            DBGOUT('hoge34')
            table.sort(
                adrasives,
                function(a, b)
                    local ta = 100000000
                    local tb = 100000000
                    if a.has then
                        ta = tonumber(a.time)
                    end
                    if b.has then
                        tb = tonumber(b.time)
                    end
                    return ta < tb
                end
            )
            -- DBGOUT('hoge33')
            --先頭から使う
            local stone = stones[1]
            local adrasive = adrasives[1]
            local stoneguid = '0'
            if stone then
                stoneguid = stone.iesid
            else
                ui.SysMsg('No stones')
                ui.SetEscapeScp('')
                return
            end
            local adrasiveguid = '0'
            if adrasive then
                adrasiveguid = adrasive.iesid
            else
                ui.SysMsg('No abrasives')
                ui.SetEscapeScp('')
                return
            end
            local aframe = ui.GetFrame('itemdungeon')
            local handle = aframe:GetUserIValue('HANDLE')

            local sklCls = GetClass('Skill', 'Alchemist_ItemAwakening')
            session.autoSeller.BuyWithPluralMaterialItem(handle, sklCls.ClassID, AUTO_SELL_AWAKENING, invItem:GetIESID(), stoneguid, adrasiveguid)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AWAKENROLLER_CANCEL()
    g.attempts = -1
    g.go = false
    ui.SysMsg('Cancelled.')
    ui.SetEscapeScp('')
end
function AWAKENROLLER_SUCCESS()
    EBI_try_catch {
        try = function()
            if g.go == false then
                return
            end
            if g.attempts == 0 then
                ui.SysMsg('Max attempt has reached.')
                ui.SetEscapeScp('')
            elseif g.attempts > 0 then
                --条件を満たしているか調べる
                local obj = GetIES(g.invItem:GetObject())

                if obj.HiddenProp == g.prop and obj.HiddenPropValue >= g.propvalue then
                    ui.SysMsg('Complete')
                    g.attempts = -1
                else
                    ui.SysMsg('Remain Attempt:' .. tostring(g.attempts-1))
                    g.attempts = g.attempts - 1
                    -- いくらでも早くできるが、まぁ
                    ReserveScript('AWAKENROLLER_DO_EXECUTE()', 0.9)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
