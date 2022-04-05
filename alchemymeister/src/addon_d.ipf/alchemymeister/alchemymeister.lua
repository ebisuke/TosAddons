--alchemymeister
local addonName = "alchemymeister"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
g.version = 0
g.settings = {x = 300, y = 300, isopen = false}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "alchemymeister"
g.debug = false
g.suppressshop = true
g.pharmtable={

}
--ライブラリ読み込み
CHAT_SYSTEM("[AM]loaded")
local acutil = require("acutil")
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end

local function DBGOUT(msg)
    EBI_try_catch {
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
local function GetRegion()
    if config.GetServiceNation() == "GLOBAL" then
        return "itos/en"
    elseif config.GetServiceNation() == "JPN" or config.GetServiceNation() == "GLOBAL_JP" then
        return "jtos/ja"
    elseif config.GetServiceNation() == "TAIWAN" then
        return "twtos/zh"
    elseif config.GetServiceNation() == "KOR" then
        return "ktos/ko"
    end
    return "itos/en"
end

function ALCHEMYMEISTER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            local addontimer = frame:GetChild("addontimer")
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0, 0)
  

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ALCHEMYMEISTER_INITFRAME()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame("pharmacy_ui")
            local gbox = frame:GetChild("main_gb")
            local gboxslot = frame:GetChildRecursively("slotset_gb")

            local slotset19=gboxslot:GetChildRecursively("slotset_19")
            AUTO_CAST(slotset19)
            local slotset=gboxslot:CreateOrGetControl("slotset","am_overlay_slotset",0,0,437,437)
            AUTO_CAST(slotset)
            slotset:RemoveAllChild()
            slotset:EnablePop(1)
            slotset:EnableDrag(1)
            slotset:SetEventScript(ui.MOUSEMOVE, "ALCHEMYMEISTER_ON_MOUSEMOVE")
            slotset:SetSlotSize(23,23)
            slotset:SetScp(0,0)
            slotset:CreateSlots()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
        
end
function ALCHEMYMEISTER_ON_MOUSEMOVE(frame,ctrl,argstr,argnum)
end

