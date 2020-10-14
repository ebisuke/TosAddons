--ancientmonstersimpleopen
local addonName = 'ANCIENTMONSTERSIMPLEOPEN'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings =
    g.settings or
    {
        x = 300,
        y = 300,
        style = 0
    }
g.configurepattern = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'ancientmonstersimpleopen'
g.debug = false

g.addon = g.addon
g.items={}
g.itemcursor=1
g.issquire=false
g.working=false
g.squirewaitfornext=false
g.enchantname=nil
--ライブラリ読み込み
CHAT_SYSTEM('[AMS]loaded')
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
            print(msg)
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function ANCIENTMONSTERSIMPLEOPEN_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            if not g.loaded then
                g.loaded = true
            end
            acutil.setupHook(AMS_ANCIENT_GACHA_LOAD_PACK_ITEM_LIST,'ANCIENT_GACHA_LOAD_PACK_ITEM_LIST')
            acutil.setupHook(AMS_ON_ANCIENT_CARD_GACHA_END,'ON_ANCIENT_CARD_GACHA_END')
            acutil.setupHook(AMS_ON_ANCIENT_CARD_GACHA_UPDATE,'ON_ANCIENT_CARD_GACHA_UPDATE')

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AMS_ANCIENT_GACHA_LOAD_PACK_ITEM_LIST(frame)
    ANCIENT_GACHA_LOAD_PACK_ITEM_LIST_OLD(frame)
    local invItemList = session.GetInvItemList()
    local cardpackList = {}
    FOR_EACH_INVENTORY(invItemList, 
        function(invItemList, invItem, cardpackList)		
            if invItem ~= nil then
                if invItem.isLockState == false then
                    local itemobj = GetIES(invItem:GetObject());
                    if string.find(itemobj.StringArg,'reward_ancient') then
                        cardpackList[#cardpackList+1] = invItem
                    end
                end
            end
        end, false, cardpackList);
    local cardpacklist_bg = GET_CHILD_RECURSIVELY(frame,'cardpacklist_bg')
    for i = 1,#cardpackList do
        local invItem = cardpackList[i]
        local item = GetIES(invItem:GetObject())
        local ctrlSet = cardpacklist_bg:CreateOrGetControlSet("ancient_card_gacha_pack_list", "PACK_" .. i, 0, (i-1)*52);
        local ancient_card_slot = ctrlSet:GetChild("ancient_card_slot")
        AUTO_CAST(ctrlSet)
        AUTO_CAST(ancient_card_slot)
        local btn=ctrlSet:CreateOrGetControl('button','gacha',0,0,50,30)
        btn:SetGravity(ui.RIGHT,ui.CENTER_VERT)
        btn:SetText('{ol}Gacha')
        btn:SetEventScript(ui.LBUTTONUP,'AMS_DO_GACHA')
        btn:SetEventScriptArgNumber(ui.LBUTTONUP,i)
        btn:SetEventScriptArgString(ui.LBUTTONUP,invItem:GetIESID())
        
    end

end
function AMS_ON_ANCIENT_CARD_GACHA_END(frame)
    if g.gacha then
        AMS_ANCIENT_GACHA_LOAD_PACK_ITEM_LIST(frame)
        AMS_GACHA()
    else
        ON_ANCIENT_CARD_GACHA_END_OLD(frame)
    end
end
function AMS_ON_ANCIENT_CARD_GACHA_UPDATE(frame,msg,argStr,argNum)
    if g.gacha then
      
    else
        ON_ANCIENT_CARD_GACHA_UPDATE_OLD(frame,msg,argStr,argNum)
    end
end
function AMS_DO_GACHA(frame,ctrl,argstr,argnum)
    if not g.gacha then
        g.gacha=true
        g.gachaiesid=argstr
        ui.MsgBox('このメッセージボックスを閉じると自動開封が終了します（はい・いいえどちらでも終了します）','AMS_CANCEL()','AMS_CANCEL()')
        AMS_GACHA()
    else
        ui.SysMsg('動作中です しばらくしてからお試しください')
    end
end
function AMS_CANCEL()
    g.gacha=false
end
function AMS_GACHA()
    if g.gacha then
        local invItem=session.GetInvItemByGuid(g.gachaiesid)
        if invItem then
            if invItem.type==1420042 then
                pc.ReqExecuteTx_Item("ANCIENT_GACHA_START",g.gachaiesid);
                ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_ANCIENT_GACHA_CARD_OPEN", %d);]],1),0.3)
                ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_ANCIENT_GACHA_CARD_OPEN", %d);]],2),0.6)
                ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_ANCIENT_GACHA_CARD_OPEN", %d);]],3),0.9)
                ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_ANCIENT_GACHA_CARD_OPEN", %d);]],4),1.2)
                ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_ANCIENT_GACHA_CARD_OPEN", %d);]],5),1.5)
                ReserveScript('ui.FlushGachaDelayPacket()',1.8)
            else
                pc.ReqExecuteTx_Item("ANCIENT_GACHA_START",g.gachaiesid);
                ReserveScript(string.format([[pc.ReqExecuteTx_NumArgs("SCR_ANCIENT_GACHA_CARD_OPEN", %d);]],1),0.3)
                ReserveScript('ui.FlushGachaDelayPacket()',0.6)
            end
            
        else
            g.gacha=false
        end
    end
end
function AMS_GACHA_END()
    g.gacha=false
end
