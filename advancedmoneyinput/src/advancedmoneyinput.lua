--advancedmoneyinput
local addonName = "advancedmoneyinput"
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
g.settings = {x = 300, y = 300}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "advancedmoneyinput"
g.debug = false

g.buffs={}
--ライブラリ読み込み
CHAT_SYSTEM("[ECD]loaded")
local acutil = require('acutil')
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
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end

function ADVANCEDMONEYINPUT_INIT(frame,addon)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", " ADVANCEDMONEYINPUT_ON_OPEN_ACCOUNTWAREHOUSE");
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDMONEYINPUT_LBTN(frame,ctrl)
    local amountstr=ctrl:GetUserValue("amount")
    local editMoney=frame:GetChildRecursively("moneyInput")
    local result=SumForBigNumberInt64(editMoney:GetText(), '+'..amountstr);
    
    editMoney:SetText(result)
end
function ADVANCEDMONEYINPUT_RBTN(frame,ctrl)
    local amountstr=ctrl:GetUserValue("amount")
    local editMoney=frame:GetChildRecursively("moneyInput")
    local result=SumForBigNumberInt64(editMoney:GetText(), ''..amountstr);
    if IsGreaterThanForBigNumber(0, result) == 1 then
		result="0"
    end
    editMoney:SetText(result)
end
function ADVANCEDMONEYINPUT_ON_OPEN_ACCOUNTWAREHOUSE(frame)
    EBI_try_catch{
        try = function()
           
            local btn10k=frame:CreateOrGetControl("button","btn10k",editMoney:GetX(),editMoney:GetY()-15,30,15)
            AUTO_CAST(btn10k)
            btn10k:SetUserValue("amount","10000")
            btn10k:SetEventScript(ui.LBUTTONUP,"ADVANCEDMONEYINPUT_LBTN")
            btn10k:SetEventScriptArgString(ui.LBUTTONUP,"1")
            btn10k:SetEventScript(ui.RBUTTONUP,"ADVANCEDMONEYINPUT_RBTN")
            btn10k:SetEventScriptArgString(ui.RBUTTONUP,"-1")
            local btn100k=frame:CreateOrGetControl("button","btn100k",editMoney:GetX()+30,editMoney:GetY()-15,30,15)
            AUTO_CAST(btn100k)
            btn100k:SetUserValue("amount","100000")
            btn100k:SetEventScript(ui.LBUTTONUP,"ADVANCEDMONEYINPUT_LBTN")
            btn100k:SetEventScriptArgString(ui.LBUTTONUP,"1")
            btn100k:SetEventScript(ui.RBUTTONUP,"ADVANCEDMONEYINPUT_RBTN")
            btn100k:SetEventScriptArgString(ui.RBUTTONUP,"-1")
            local btn1m=frame:CreateOrGetControl("button","btn1m",editMoney:GetX()+60,editMoney:GetY()-15,30,15)
            AUTO_CAST(btn1m)
            btn1m:SetUserValue("amount","1000000")
            btn1m:SetEventScript(ui.LBUTTONUP,"ADVANCEDMONEYINPUT_LBTN")
            btn1m:SetEventScriptArgString(ui.LBUTTONUP,"1")
            btn1m:SetEventScript(ui.RBUTTONUP,"ADVANCEDMONEYINPUT_RBTN")
            btn1m:SetEventScriptArgString(ui.RBUTTONUP,"-1")
            local btn10m=frame:CreateOrGetControl("button","btn10m",editMoney:GetX()+90,editMoney:GetY()-15,30,15)
            AUTO_CAST(btn10m)
            btn10m:SetUserValue("amount","10000000")
            btn10m:SetEventScript(ui.LBUTTONUP,"ADVANCEDMONEYINPUT_LBTN")
            btn10m:SetEventScriptArgString(ui.LBUTTONUP,"1")
            btn10m:SetEventScript(ui.RBUTTONUP,"ADVANCEDMONEYINPUT_RBTN")
            btn10m:SetEventScriptArgString(ui.RBUTTONUP,"-1")
            local btn100m=frame:CreateOrGetControl("button","btn100m",editMoney:GetX()+120,editMoney:GetY()-15,30,15)
            AUTO_CAST(btn100m)
            btn100m:SetUserValue("amount","100000000")
            btn100m:SetEventScript(ui.LBUTTONUP,"ADVANCEDMONEYINPUT_LBTN")
            btn100m:SetEventScriptArgString(ui.LBUTTONUP,"1")
            btn100m:SetEventScript(ui.RBUTTONUP,"ADVANCEDMONEYINPUT_RBTN")
            btn100m:SetEventScriptArgString(ui.RBUTTONUP,"-1")
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end