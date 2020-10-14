--ikorextractionresetinhibiter
local addonName = 'IKOREXTRACTIONRESETINHIBITER'
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
g.framename = 'ikorextractionresetinhibiter'
g.debug = false

g.addon = g.addon
g.items={}
g.itemcursor=1
g.issquire=false
g.working=false
g.squirewaitfornext=false
g.enchantname=nil
--ライブラリ読み込み
CHAT_SYSTEM('[IERI]loaded')
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
function IKOREXTRACTIONRESETINHIBITER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            if not g.loaded then
                g.loaded = true
            end
            acutil.setupHook(IERI_ITEMOPTIONEXTRACT_OPEN,'ITEMOPTIONEXTRACT_OPEN')


        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function IERI_ITEMOPTIONEXTRACT_OPEN(frame)
    ITEMOPTIONEXTRACT_OPEN_OLD(frame)
    local confirm=frame:GetChild('send_ok')
    confirm:SetEventScript(ui.LBUTTONUP,'IERI_SEND_OK')
end

function IERI_SEND_OK(frame)

	local pic_bg = GET_CHILD_RECURSIVELY(frame, "pic_bg")
	pic_bg:ShowWindow(1)

	local send_ok = GET_CHILD_RECURSIVELY(frame, "send_ok")
	send_ok:ShowWindow(0)

	local do_extract = GET_CHILD_RECURSIVELY(frame, "do_extract")
	do_extract : ShowWindow(1)

	local resultGbox = GET_CHILD_RECURSIVELY(frame, "resultGbox")
	resultGbox:ShowWindow(0)

	local putOnItem = GET_CHILD_RECURSIVELY(frame, "text_putonitem")
	putOnItem:ShowWindow(1)

	local text_material = GET_CHILD_RECURSIVELY(frame, "text_material")
	text_material : ShowWindow(1)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image : ShowWindow(1)

	local text_potential = GET_CHILD_RECURSIVELY(frame, "text_potential")
	text_potential : ShowWindow(0)
	local gauge_potential = GET_CHILD_RECURSIVELY(frame, "gauge_potential")
	gauge_potential : ShowWindow(0)
		
	local arrowbox = GET_CHILD_RECURSIVELY(frame, "arrowbox")
	arrowbox : ShowWindow(0)

	local slot_result = GET_CHILD_RECURSIVELY(frame, "slot_result")
	slot_result : ShowWindow(0)

	local itemName = GET_CHILD_RECURSIVELY(frame, "text_itemname")
	itemName:SetText("")

	local bodyGbox1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1');
	bodyGbox1:ShowWindow(1)
	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
	bodyGbox2:ShowWindow(1)
	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_1');
	bodyGbox2_1:ShowWindow(1)
	local extractKitGbox = GET_CHILD_RECURSIVELY(frame, 'extractKitGbox')
	extractKitGbox:ShowWindow(0)
	local bodyGbox3 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox3');
    bodyGbox3:ShowWindow(0)
    
    
	local bodyGbox1_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1_1');
	bodyGbox1_1:ShowWindow(1)
	bodyGbox1_1:Resize(bodyGbox1:GetWidth(), bodyGbox1:GetHeight())

	local bodyGbox2_2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_2');
	bodyGbox2_2:ShowWindow(1)

	local bodyGbox3_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox3_1');
	bodyGbox3_1:ShowWindow(1)


	local destroy_gbox = GET_CHILD_RECURSIVELY(frame, 'destroy_gbox')
	destroy_gbox:ShowWindow(0)

    local invItem = session.GetInvItemByGuid(itemID)
	if invItem == nil then
		return;
	end
    local slot=frame:GetChild('slot')
    AUTO_CAST(slot)
    local iconInfo=slot:GetIcon():GetInfo()
    local extractKitSlot = GET_CHILD_RECURSIVELY(frame, "extractKitSlot")
    local extractKitIcon = extractKitSlot:GetIcon()

    if session.GetInvItemByGuid(iconInfo:GetIESID()) then
        ITEM_OPTIONEXTRACT_REG_TARGETITEM(frame, iconInfo:GetIESID());
        if session.GetInvItemByGuid(extractKitIcon:GetInfo():GetIESID()) then
            ITEM_OPTIONEXTRACT_KIT_REG_TARGETITEM(frame, extractKitIcon:GetInfo():GetIESID());
        else
            
            local extractKitName = GET_CHILD_RECURSIVELY(frame, "extractKitName")
            extractKitName:SetTextByKey("value", frame:GetUserConfig("EXTRACT_KIT_DEFAULT"))
    
        end
    else

        slot:ClearIcon();
        slot:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)    
    end
    
end