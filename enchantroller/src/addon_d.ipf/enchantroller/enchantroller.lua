-- enchantroller
--アドオン名（大文字）
local addonName = 'enchantroller'
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
g.framename = 'enchantroller'
g.debug = false
g.handle = nil
g.running=false
g.highprop=0
g.lowprop=0
g.fixedprop=0
g.waitforresult=false
g.jewellv=0
g.jewelgrade=0
g.proptype={
    RareOption_SR='fixed',
    RareOption_MSPD='fixed',
    RareOption_BlockRate='high',
    RareOption_BlockBreakRate='high',
    RareOption_DodgeRate='high',
    RareOption_HitRate='high',
    RareOption_CriticalDodgeRate='high',
    RareOption_CriticalHitRate='high',
    RareOption_PVPReducedRate='high',
    RareOption_MeleeReducedRate='high',
    RareOption_MagicReducedRate='high',
    RareOption_CriticalDamage_Rate='low',
    RareOption_PVPDamageRate='low',
    RareOption_BossDamageRate='low',
    RareOption_SubWeaponDamageRate='low',
    RareOption_MainWeaponDamageRate='low'
}
--ライブラリ読み込み
CHAT_SYSTEM('[ER]loaded')
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
function ENCHANTROLLER_SAVE_SETTINGS()
    --AWAKENROLLER_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function ENCHANTROLLER_SAVE_ALL()
    ENCHANTROLLER_SAVETOSTRUCTURE()
    ENCHANTROLLER_SAVE_SETTINGS()
    --ui.MsgBox('保存しました')
end
function ENCHANTROLLER_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('enchantroller')
    local edithighpercent=frame:GetChild('edithighpercent')
    local editlowpercent=frame:GetChild('editlowpercent')
    local editfixed=frame:GetChild('editfixed')
    local high=edithighpercent:GetText()
    local low=editlowpercent:GetText()
    local fixed=editfixed:GetText()
    if high=='' then
        g.settings.highprop=nil
    else
        g.settings.highprop=tonumber(high)
     
    end
    if low=='' then
        g.settings.lowprop=nil
    else
        g.settings.lowprop=tonumber(low)
        
    end
    if fixed=='' then
        g.settings.fixedprop=nil
    else
        g.settings.fixedprop=tonumber(fixed)
        
    end
    
end

function ENCHANTROLLER_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    g.settings = g.settings or {
        highprop=15,
        lowprop=10,
        fixedprop=3,
    }
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {
            highprop=15,
            lowprop=10,
            fixedprop=3,
        }
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end

    ENCHANTROLLER_UPGRADE_SETTINGS()
    ENCHANTROLLER_SAVE_SETTINGS()
    ENCHANTROLLER_LOADFROMSTRUCTURE()
end

function ENCHANTROLLER_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('enchantroller')
    local edithighpercent=frame:GetChild('edithighpercent')
    local editlowpercent=frame:GetChild('editlowpercent')
    local editfixed=frame:GetChild('editfixed')
    edithighpercent:SetText(tostring(g.settings.highprop))
    editlowpercent:SetText(tostring(g.settings.lowprop))
    editfixed:SetText(tostring(g.settings.fixedprop))
    
end

function ENCHANTROLLER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function ENCHANTROLLER_ON_INIT(addon, frame)
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
            acutil.setupHook(ENCHANTROLLER_OPEN_RAREOPTION,'OPEN_RAREOPTION')
            acutil.setupHook(ENCHANTROLLER_WRAP_ON_SUCESS_ENCHANT_JEWELL,'ON_SUCESS_ENCHANT_JEWELL')
            frame:ShowWindow(0)
            local timer=frame:GetChild('addontimer')
            AUTO_CAST(timer)
            timer:SetUpdateScript('ENCHANTROLLER_ON_TIMER')
            timer:Start(0.01)
            addon:RegisterMsg('FAIL_ENCHANT_JEWELL', 'ENCHANTROLLER_ON_FAIL_ENCHANT_JEWELL');
            addon:RegisterMsg('SUCESS_ENCHANT_JEWELL', 'ENCHANTROLLER_ON_SUCESS_ENCHANT_JEWELL');
            ENCHANTROLLER_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ENCHANTROLLER_OPEN_RAREOPTION(frame)
    OPEN_RAREOPTION_OLD(frame)
    local frame = ui.GetFrame('rareoption');
    local btn=frame:CreateOrGetControl('button','btnroller',5,35,80,30)
    btn:SetText('{ol}Auto Roller')
    btn:SetEventScript(ui.LBUTTONUP,'ENCHANTROLLER_SHOW')


end

function ENCHANTROLLER_SHOW()

    local rframe = ui.GetFrame(g.framename);
    rframe:ShowWindow(1)
    local frame = ui.GetFrame('rareoption');
    frame:ShowWindow(0)
   
    ENCHANTROLLER_INITFRAME()
    local guid = frame:GetUserValue('JEWELL_GUID');

    local invItem=session.GetInvItemByGuid(guid)
    if invItem then
        local itemObj = GetIES(invItem:GetObject());
        local slotactive=rframe:GetChild('slotactive')
        AUTO_CAST(slotactive)
        local itemCls = GetClassByType("Item", invItem.type);
        SET_SLOT_ITEM(slotactive, invItem);	
        local lv = TryGetProp(itemObj, 'Level', 1)
        if lv == 1 then
            lv = TryGetProp(itemObj, 'NumberArg1', 1)		
        end
        g.jewellv=lv
        g.jewelgrade=itemObj.ItemGrade
        g.jewelguid=guid
        ENCHANTROLLER_UPDATE_JEWELCOUNT()
    else
        g.jewellv=0
        g.jewelgrade=0
        g.jewelguid=0
        local slotactive=rframe:GetChild('slotactive')
        AUTO_CAST(slotactive)
        slotactive:ClearIcon()
    end

    ITEM_UNREVERT_RANDOM_CLOSE()
end
function ENCHANTROLLER_INITFRAME()

    local frame = ui.GetFrame(g.framename);
    frame:Resize(710,386)
    local bgbox=frame:GetChild('bgBox')
    bgbox:EnableHitTest(0)
    local pic_bg=frame:GetChild('pic_bg')
    pic_bg:EnableHitTest(1)
    local headerBox=frame:GetChild('headerBox')
    headerBox:EnableHitTest(1)
    --frame:GetChild('headerBox'):SetGravity(ui.CENTER_HORZ,ui.TOP)
    local slotactive=frame:CreateOrGetControl('slot','slotactive',100,170,80,80)
    AUTO_CAST(slotactive)
    slotactive:SetSkinName('invenslot2')
    slotactive:EnableDrop(1)
    slotactive:EnablePop(1)
    slotactive:EnableDrag(0)
    slotactive:SetEventScript(ui.DROP,'ENCHANTROLLER_ON_DROP_JEWEL')
    local txtcount=frame:CreateOrGetControl('richtext','txtcount',100,170+90,120,80)
    AUTO_CAST(txtcount)

    txtcount:SetText('')
    

    local gauge=frame:CreateOrGetControl('gauge','progress',190,190,90,40)
    AUTO_CAST(gauge)
    gauge:SetMaxPoint(70)
    gauge:SetCurPoint(0)
    gauge:SetBarColor(0xFFFFFFFF)


    local btnstart=frame:CreateOrGetControl('button','btnstart',170,320,180,60)
    AUTO_CAST(btnstart)
    btnstart:SetSkinName('test_red_button')
    btnstart:SetText("{@st43}{ol}{s30}Start")
    btnstart:SetEventScript(ui.LBUTTONUP,'ENCHANTROLLER_START')
    local btnstop=frame:CreateOrGetControl('button','btnstop',170+190,320,180,60)
    AUTO_CAST(btnstop)
    btnstop:SetSkinName('test_gray_button')
    btnstop:SetText("{@st43}{ol}{s30}Stop")
    btnstop:SetEventScript(ui.LBUTTONUP,'ENCHANTROLLER_STOP')
    local txthighpercent=frame:CreateOrGetControl('richtext','txthighpercent',450,60,90,30)
    AUTO_CAST(txthighpercent)
    txthighpercent:SetText('{@st43}{s16}Condition for props of max 25%')
    local edithighpercent=frame:CreateOrGetControl('edit','edithighpercent',450,85,90,30)
    AUTO_CAST(edithighpercent)
    edithighpercent:SetText('22.5')
    edithighpercent:SetFontName('white_16_ol')
    edithighpercent:SetTextTooltip('最大値25%区分の条件。使用しない場合は空欄にしてください')
    local txtlowpercent=frame:CreateOrGetControl('richtext','txtlowpercent',450,150,90,30)
    AUTO_CAST(txthighpercent)
    txtlowpercent:SetText('{@st43}{s16}Condition for props of max 15%')
    local editlowpercent=frame:CreateOrGetControl('edit','editlowpercent',450,175,90,30)
    AUTO_CAST(editlowpercent)
    editlowpercent:SetText('13.0')
    editlowpercent:SetFontName('white_16_ol')
    editlowpercent:SetTextTooltip('最大値15%区分の条件。使用しない場合は空欄にしてください')
    local txtfixed=frame:CreateOrGetControl('richtext','txtfixed',450,240,90,30)
    AUTO_CAST(txtfixed)
    txtfixed:SetText('{@st43}{s16}Condition for props of max 3 ')
    local editfixed=frame:CreateOrGetControl('edit','editfixed',450,265,90,30)
    AUTO_CAST(editfixed)
    editfixed:SetText('3')
    editfixed:SetFontName('white_16_ol')
    editfixed:SetTextTooltip('最大値が固定値の区分の条件。使用しない場合は空欄にしてください')

    ENCHANTROLLER_LOAD_SETTINGS()
end
function ENCHANTROLLER_ON_TIMER()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename);

    if g.running and not g.waitforresult then
        local gauge=frame:GetChild('progress')
        AUTO_CAST(gauge)
        local mx=gauge:GetMaxPoint()
        local cur=gauge:GetCurPoint()
        if cur==mx then
            ENCHANTROLLER_DO_ENCHANT()
        else
            cur=cur+1
            gauge:SetCurPoint(cur)
        end
    end
end,
catch = function(error)
    ERROUT(error)
end
}
end
function ENCHANTROLLER_START(frame)
    EBI_try_catch {
        try = function()
    if g.running then 
        ui.SysMsg("Already running")
        return

    end
    --入力値チェック
    local edithighpercent=frame:GetChild('edithighpercent')
    local editlowpercent=frame:GetChild('editlowpercent')
    local editfixed=frame:GetChild('editfixed')
    
    local high=edithighpercent:GetText()
    local low=editlowpercent:GetText()
    local fixed=editfixed:GetText()
    if high=='' then
        g.settings.highprop=nil
    else
        g.settings.highprop=tonumber(high)
        if g.settings.highprop==nil then
            ui.SysMsg("InvalidValue:Condition 25% is nil")
            return
        elseif g.settings.highprop>25.0 then
            ui.SysMsg("InvalidValue:Condition 25%")
            return
        end
    end
    if low=='' then
        g.settings.lowprop=nil
    else
        g.settings.lowprop=tonumber(low)
        if g.settings.lowprop==nil then
            ui.SysMsg("InvalidValue:Condition 15% is nil")
            return
        elseif g.settings.lowprop>15.0 then
            ui.SysMsg("InvalidValue:Condition 15%")
            return
        end
    end
    if fixed=='' then
        g.settings.fixedprop=nil
    else
        g.settings.fixedprop=tonumber(fixed)
        if g.settings.fixedprop==nil then
            ui.SysMsg("InvalidValue:Condition 3 is nil")
            return
        elseif g.settings.fixedprop>3 then
            ui.SysMsg("InvalidValue:Condition 3")
            return
        end
    end
    local slotactive=frame:GetChild('slotactive')
    AUTO_CAST(slotactive)
    if slotactive:GetIcon()==nil then
        ui.SysMsg("No jewel")
        return
    end
    local slot=frame:GetChildRecursively('slot')
    AUTO_CAST(slot)
    if slot:GetIcon()==nil then
        ui.SysMsg("No target item")
        return
    end
    local gauge=frame:GetChild('progress')
    AUTO_CAST(gauge)
    gauge:SetCurPoint(0)
    g.running=true
    g.waitforresult=false
    ENCHANTROLLER_SAVE_SETTINGS()
    ENCHANTROLLER_ANIM()
end,
catch = function(error)
    ERROUT(error)
end
}
end
function ENCHANTROLLER_STOP(frame)
    local gauge=frame:GetChild('progress')
    AUTO_CAST(gauge)
    gauge:SetCurPoint(0)
    g.running=false
    g.waitforresult=false
end
function ENCHANTROLLER_ON_FAIL_ENCHANT_JEWELL(frame)
    if not g.running then
        return
    end
    ui.SysMsg("Failed")
    ENCHANTROLLER_STOP(frame)
end
function ENCHANTROLLER_SUPPRESS_ORIGINAL_ANIM()
    local rframe=ui.GetFrame('rareoption')
    local pic_bg = GET_CHILD_RECURSIVELY(rframe, 'pic_bg');
	pic_bg:StopUIEffect('RESET_SUCCESS_EFFECT', true, 0.5);
end
function ENCHANTROLLER_ON_SUCESS_ENCHANT_JEWELL(frame)
    --判定
    if not g.running then
        return
    end
    ReserveScript('ENCHANTROLLER_SUPPRESS_ORIGINAL_ANIM()',0.01)
    ENCHANTROLLER_UPDATE_JEWELCOUNT()
    local slot=frame:GetChildRecursively('slot')
    AUTO_CAST(slot)
    local icon=slot:GetIcon()
    local targetguid = icon:GetInfo():GetIESID();
    local invItem=session.GetInvItemByGuid(targetguid)
    local itemObj=GetIES(invItem:GetObject())

	local propName = 'RandomOptionRare';
    local propValue = 'RandomOptionRareValue';
    local propname=itemObj[propName]
    local propvalue= itemObj[propValue]
    local proptype=g.proptype[propname]
    if not proptype then
        --ENCHANTROLLER_ON_FAIL_ENCHANT_JEWELL
        ui.SysMsg("Unknown prop:"..propname)
        ENCHANTROLLER_STOP(frame)
        return
    end
    local complete=false
    if proptype=='fixed' then
        if  g.fixedprop and propvalue >= g.fixedprop then
            complete=true
        end
    elseif proptype=='high' then
        if  g.highprop and propvalue/10.0 >= g.highprop then
            complete=true
        end
    elseif proptype=='low' then
        if  g.lowprop and propvalue/10.0 >= g.lowprop then
            complete=true
        end
    end
    if complete then
        ui.SysMsg("Complete.")
        ENCHANTROLLER_STOP(frame)
        return
    else
        --続行

        local jewelinvItem=session.GetInvItemByGuid(g.jewelguid)
        if not jewelinvItem then
            jewelinvItem=ENCHANTROLLER_FIND_JEWELL_ITEM()
            local slotactive=frame:GetChildRecursively('slotactive')
            AUTO_CAST(slotactive)
            if jewelinvItem then
                g.jewelguid=jewelinvItem:GetIESID()
                SET_SLOT_ITEM(slotactive,jewelinvItem)
            else
                ui.SysMsg("No jewel.")
              
                slotactive:ClearIcon()
                ENCHANTROLLER_STOP(frame)
                return
            end
        end
        local gauge=frame:GetChild('progress')
        AUTO_CAST(gauge)
        gauge:SetCurPoint(0)
        g.waitforresult=false
        ENCHANTROLLER_ANIM()
    end
end
function ENCHANTROLLER_DO_ENCHANT()
    local frame = ui.GetFrame(g.framename);

    local slot=frame:GetChildRecursively('slot')
    AUTO_CAST(slot)
    local icon=slot:GetIcon()
    local targetguid = icon:GetInfo():GetIESID();

    g.waitforresult=true
    session.ResetItemList();
    session.AddItemID(targetguid, 1);
    session.AddItemID(g.jewelguid, 1);
    local resultlist = session.GetItemIDList();
	item.DialogTransaction('EXECUTE_ENCHANT_JEWELL', resultlist);	
end
function ENCHANTROLLER_ON_DROP_JEWEL(frame)
    EBI_try_catch {
        try = function()
            if g.running then
                return
            end
            local liftIcon = ui.GetLiftIcon();
            local fromFrame = liftIcon:GetTopParentFrame();

            if fromFrame:GetName() == 'inventory' then
                local iconInfo = liftIcon:GetInfo();
                local invItem=session.GetInvItemByGuid(iconInfo:GetIESID())
                local itemObj=GetIES(invItem:GetObject())
                local stringarg = TryGetProp(itemObj, 'StringArg', '')
                if stringarg=='EnchantJewell' then
                    local slotactive=frame:GetChild('slotactive')
                    AUTO_CAST(slotactive)
                    local itemCls = GetClassByType("Item", invItem.type);
                    SET_SLOT_ITEM(slotactive, invItem);	
                    local lv = TryGetProp(itemObj, 'Level', 1)
                    if lv == 1 then
                        lv = TryGetProp(itemObj, 'NumberArg1', 1)		
                    end
                    g.jewellv=lv
                    g.jewelgrade=itemObj.ItemGrade
                    g.jewelguid=iconInfo:GetIESID()
                    ENCHANTROLLER_UPDATE_JEWELCOUNT()
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ENCHANTROLLER_UPDATE_JEWELCOUNT()
    local frame = ui.GetFrame(g.framename);
    local txtcount=frame:GetChild('txtcount')

    local count=0
    local slotactive=frame:GetChild('slotactive')
    AUTO_CAST(slotactive)
    local icon=slotactive:GetIcon()
    if icon==nil then
        txtcount:SetText('{@st43}No jewels')
        return
    end

    local haveCount = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'StringArg', Value ='EnchantJewell'}, {Name = 'Level', Value = g.jewellv}, {Name = 'ItemGrade', Value =g.jewelgrade}});

	haveCount =haveCount+ GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'StringArg', Value ='EnchantJewell'}, {Name = 'NumberArg1', Value = g.jewellv}, {Name = 'ItemGrade', Value = g.jewelgrade}});

    
    txtcount:SetText('{@st43}Jewels:'..haveCount)
end
function ENCHANTROLLER_FIND_JEWELL_ITEM()	
    local jewellItem
    local curSettedLv = g.jewellv
    local curSettedGrade = g.jewelgrade
    if curSettedLv == 0 or curSettedGrade == 0 then
        return;
    end

    local haveCount = 0
    local itemList = {}

    haveCount, itemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'StringArg', Value ='EnchantJewell'}, {Name = 'Level', Value = curSettedLv}, 
    {Name = 'ItemGrade', Value = curSettedGrade}});
    if haveCount == 0 then
        haveCount, itemList = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'StringArg', Value ='EnchantJewell'}, {Name = 'NumberArg1', Value = curSettedLv}, 
        {Name = 'ItemGrade', Value = curSettedGrade}});
    end
    if haveCount < 1 then
      
        return;
    end
    for i = 1, #itemList do
        local itemObj = GetIES(itemList[i]:GetObject());
        local itemObjLevel = TryGetProp(itemObj, 'Level', 1)
        
        if itemObjLevel == 1 then
            itemObjLevel = itemObj.NumberArg1
        end

        if itemObjLevel == curSettedLv and itemObj.ItemGrade == curSettedGrade then
            jewellItem = itemList[i];
            break;
        end
    end


	local jewellObj = GetIES(jewellItem:GetObject());
    return jewellItem,jewellObj
end

function ENCHANTROLLER_RAREOPTION_DROP_ITEM()
    EBI_try_catch {
        try = function()
        if g.running then
            return
        end
        local liftIcon = ui.GetLiftIcon();
        local fromFrame = liftIcon:GetTopParentFrame();

        if fromFrame:GetName() == 'inventory' then
            local frame=ui.GetFrame(g.framename)
            local iconInfo = liftIcon:GetInfo();
            local invItem=session.GetInvItemByGuid(iconInfo:GetIESID())
            local itemObj=GetIES(invItem:GetObject())
            local slot=frame:GetChildRecursively('slot')
            AUTO_CAST(slot)
            if invItem.isLockState == true then
                ui.SysMsg(ClMsg('MaterialItemIsLock'));
                return false;
            end
            local slotactive=frame:GetChild('slotactive')
            AUTO_CAST(slotactive)
            local icon=slotactive:GetIcon()
            if icon==nil then
                ui.SysMsg('NotExistJewel');
                return
            end
            local jewelguid = icon:GetInfo():GetIESID();
            local jewelinvItem,jewellObj =ENCHANTROLLER_FIND_JEWELL_ITEM()
        
            local enable, reason = IS_ENABLE_APPLY_JEWELL(jewellObj, itemObj);
            if enable == false then
                ui.SysMsg(ScpArgMsg('CannotApplyJewellBecause{REASON}', 'REASON', ClMsg(reason)));
                return
            end
         
            SET_SLOT_ITEM(slot, invItem);	
        end
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function ENCHANTROLLER_RAREOPTION_INIT(frame,slot)
    if g.running then
        return
    end
    AUTO_CAST(slot)
    slot:ClearIcon()
end
function ENCHANTROLLER_ANIM()

    local frame = ui.GetFrame(g.framename);
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'));
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end

	pic_bg:StopUIEffect('RESET_SUCCESS_EFFECT', true, 0.5);
	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'RESET_SUCCESS_EFFECT');

 
end
function ENCHANTROLLER_WRAP_ON_SUCESS_ENCHANT_JEWELL(frame, msg, argStr, argNum)	
    if g.running then
    else
        ON_SUCESS_ENCHANT_JEWELL_OLD(frame, msg, argStr, argNum)	
    end
end
function ENCHANTROLLER_CLOSE(frame)
    EBI_try_catch {
        try = function()
        g.frame:ShowWindow(0)
        ENCHANTROLLER_STOP(g.frame)
        ENCHANTROLLER_SAVE_ALL()
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end