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
    EBI_try_catch {
        try = function()
	
            local frame = ui.GetFrame("itemoptionextract");

            local slot=frame:GetChildRecursively('slot')
            AUTO_CAST(slot)
            local iconInfo=slot:GetIcon():GetInfo()
            local mainiesid=iconInfo:GetIESID()
            local extractKitSlot = GET_CHILD_RECURSIVELY(frame, "extractKitSlot")
            local extractKitIcon = extractKitSlot:GetIcon()
            local extractiesid= extractKitIcon:GetInfo():GetIESID()

            CLEAR_ITEMOPTIONEXTRACT_UI()
            if session.GetInvItemByGuid(mainiesid) then
                ITEM_OPTIONEXTRACT_REG_TARGETITEM(frame, mainiesid);
                if session.GetInvItemByGuid(extractiesid) then
                    ITEM_OPTIONEXTRACT_KIT_REG_TARGETITEM(frame, extractiesid);
                else
                    
                    local extractKitName = GET_CHILD_RECURSIVELY(frame, "extractKitName")
                    extractKitName:SetTextByKey("value", frame:GetUserConfig("EXTRACT_KIT_DEFAULT"))
            
                end
            else

                slot:ClearIcon();
                slot:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)    
            end
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end