--アドオン名（大文字）
local addonName = "repointing"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

--ライブラリ読み込み
CHAT_SYSTEM("[REPC]loaded")
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

REPOINTING_CONFIG_DEFS = {
    {
        name = "Config",
        vname = "",
        type = "proxy",
        child = {
            
        }
    }
}

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

function REPOINTINGCONFIG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame("repointingconfig")
            g.addon = addon
            g.cframe = frame
            acutil.slashCommand("/repc", REPOINTINGCONFIG_PROCESS_COMMAND);
            
            g.cframe:ShowWindow(0)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function REPOINTINGCONFIG_GENERATEDEFAULT(config, node)
    if (node == nil) then
        node = REPOINTING_CONFIG_DEFS
    end
    for k, v in ipairs(node) do
        if (v.default and config[v.name]==nil) then
            config[v.name] = v.default
        end
        if (v.child) then
            REPOINTINGCONFIG_GENERATEDEFAULT(config, v.child)
        end
    end
    
end
function REPOINTINGCONFIG_PROCESS_COMMAND(command)
    
    g.cframe:ShowWindow(1)


end
function REPOINTINGCONFIG_CLOSE()
    
    g.cframe:ShowWindow(0)

end
function REPOINTINGCONFIG_INIT()
    local frame = g.cframe;
    frame:EnableMove(1)
    EBI_try_catch{
        try = function()
            --generate gbox
            local gbox = frame:CreateOrGetControl("groupbox", "gbox", 30, 160, frame:GetWidth() - 60, frame:GetHeight() - 220)
            AUTO_CAST(gbox)
            gbox:EnableScrollBar(1)
            local btnsave = frame:CreateOrGetControl("button", "btnsave", 30, 100, 70, 30)
            AUTO_CAST(btnsave)
            btnsave:SetEventScript(ui.LBUTTONUP, "REPOINTINGCONFIG_SAVE_ONLCLICK")
            btnsave:SetText("{ol}{s16}Apply")
            local label = frame:CreateOrGetControl("richtext", "labelattention", 30, 140, 70, 30)
            AUTO_CAST(label)
            label:SetText("{ol}{s16}* Move the map or change the character {nl} to apply the settings.")
            REPOINTINGCONFIG_INITGBOX(gbox, g.settings)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function REPOINTINGCONFIG_ON_OPEN()
    REPOINTINGCONFIG_INIT()
end
function REPOINTINGCONFIG_SAVE_ONLCLICK()
    local frame = g.cframe;
    EBI_try_catch{
        try = function()
            REPOINTINGCONFIG_SAVETOSTRUCTURE()
            REPOINTING_SAVE_SETTINGS()
            REPOINTING_3SEC()
            CHAT_SYSTEM("[REP]SAVED")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function REPOINTINGCONFIG_INITGBOX(gbox, config, node, y)
    y = y or 0
    local h=30
    node = node or REPOINTING_CONFIG_DEFS
    for k, v in ipairs(node) do

        if (v.type == "boolean") then
            local ctrl = gbox:CreateOrGetControl("checkbox", "chk" .. v.name, 5, y + h, gbox:GetWidth() - 10, h)
            AUTO_CAST(ctrl)
            ctrl:SetText("{ol}{s16}" .. v.vname)
            if (config[v.name] == true) then
                ctrl:SetCheck(1)
            else
                ctrl:SetCheck(0)
            end
        
        elseif (v.type == "number") then
            local label = gbox:CreateOrGetControl("richtext", "label" .. v.name, 5,y + h, gbox:GetWidth() - 10, h)
            label:SetText("{ol}{s16}" .. v.vname)
            local ctrl = gbox:CreateOrGetControl("numupdown", "num" .. v.name, 5 + label:GetWidth() + 10, y + h, 150, h)
            AUTO_CAST(ctrl)
            ctrl:SetFontName("white_20_ol");
            ctrl:ShowWindow(1);
            ctrl:MakeButtons("btn_numdown", "btn_numup", "editbox_s");
            ctrl:SetNumberValue(config[v.name])
        end
        y = y + h
        if (v.child) then
            REPOINTINGCONFIG_INITGBOX(gbox, config, v.child, y)
        end
    end
end

function REPOINTINGCONFIG_SAVETOSTRUCTURE(gbox, config, node)
    gbox=gbox or AUTO_CAST(g.cframe :GetChild("gbox"))
    config=config or g.settings
    node = node or REPOINTING_CONFIG_DEFS
    for k, v in ipairs(node) do
        if (v.type == "boolean") then
            local ctrl = gbox:GetChild("chk" .. v.name)
            AUTO_CAST(ctrl)
            if (ctrl:IsChecked() == 1) then
                config[v.name] = true
            else
                config[v.name] = false
            end
        
        elseif (v.type == "number") then
            
            local ctrl = gbox:GetChild("num" .. v.name)
            AUTO_CAST(ctrl)
            config[v.name] = ctrl:GetNumber()
        end
        if (v.child) then
            REPOINTINGCONFIG_SAVETOSTRUCTURE(gbox, config, v.child)
        end
    end
end
