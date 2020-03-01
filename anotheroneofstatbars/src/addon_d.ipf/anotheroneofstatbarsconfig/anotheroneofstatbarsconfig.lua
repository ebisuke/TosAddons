--アドオン名（大文字）
local addonName = "ANOTHERONEOFSTATBARS"
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
CHAT_SYSTEM("[SUC]loaded")
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

ANOTHERONEOFSTATBARS_CONFIG_DEFS = {
    {
        name = "Config",
        vname = "",
        type = "proxy",
        child = {
            {
                name = "layerlevel",
                vname = "Layer Level",
                type = "number",
                default = 90,
            },
            {
                name = "minlenhp",
                vname = "Min length of HP",
                type = "number",
                default = 100,
            },
            {
                name = "maxlenhp",
                vname = "Max length of HP",
                type = "number",
                default = 400,
            },
            {
                name = "maxhp",
                vname = "Limit of HP",
                type = "number",
                default =100000,
            },
            {
                name = "minlensp",
                vname = "Min length of SP",
                type = "number",
                default = 100,
            },
            {
                name = "maxlensp",
                vname = "Max length of SP",
                type = "number",
                default = 400,
            },
            {
                name = "maxsp",
                vname = "Limit of SP",
                type = "number",
                default =10000,
            },
            {
                name = "minlenstamina",
                vname = "Min length of STA",
                type = "number",
                default = 100,
            },
            {
                name = "maxlenstamina",
                vname = "Max length of STA",
                type = "number",
                default = 400,
            },
            {
                name = "maxstamina",
                vname = "Limit of STA",
                type = "number",
                default =100000,
            }
            ,
            {
                name = "minlendur",
                vname = "Min length of Dur",
                type = "number",
                default = 100,
            },
            {
                name = "maxlendur",
                vname = "Max length of Dur",
                type = "number",
                default = 400,
            },
            {
                name = "maxdur",
                vname = "Limit of Dur",
                type = "number",
                default =4000,
            },
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

function ANOTHERONEOFSTATBARSCONFIG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame("anotheroneofstatbarsconfig")
            g.addon = addon
            g.cframe = frame
            acutil.slashCommand("/aosc", ANOTHERONEOFSTATBARSCONFIG_PROCESS_COMMAND);
            
            g.cframe:ShowWindow(0)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ANOTHERONEOFSTATBARSCONFIG_GENERATEDEFAULT(config, node)
    if (node == nil) then
        node = ANOTHERONEOFSTATBARS_CONFIG_DEFS
    end
    for k, v in ipairs(node) do
        if (v.default and config[v.name]==nil) then
            config[v.name] = v.default
        end
        if (v.child) then
            ANOTHERONEOFSTATBARSCONFIG_GENERATEDEFAULT(config, v.child)
        end
    end
    
end
function ANOTHERONEOFSTATBARSCONFIG_PROCESS_COMMAND(command)
    
    g.cframe:ShowWindow(1)


end
function ANOTHERONEOFSTATBARSCONFIG_CLOSE()
    
    g.cframe:ShowWindow(0)

end
function ANOTHERONEOFSTATBARSCONFIG_INIT()
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
            btnsave:SetEventScript(ui.LBUTTONUP, "ANOTHERONEOFSTATBARSCONFIG_SAVE_ONLCLICK")
            btnsave:SetText("{ol}{s16}Apply")
            ANOTHERONEOFSTATBARSCONFIG_INITGBOX(gbox, g.settings)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANOTHERONEOFSTATBARSCONFIG_ON_OPEN()
    ANOTHERONEOFSTATBARSCONFIG_INIT()
end
function ANOTHERONEOFSTATBARSCONFIG_SAVE_ONLCLICK()
    local frame = g.cframe;
    EBI_try_catch{
        try = function()
            ANOTHERONEOFSTATBARSCONFIG_SAVETOSTRUCTURE()
            AOS_SAVE_SETTINGS()
            AOS_INIT()
            AOS_TIMER_BEGIN()
            CHAT_SYSTEM("[AOS]SAVED")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANOTHERONEOFSTATBARSCONFIG_INITGBOX(gbox, config, node, y)
    y = y or 0
    local h=30
    node = node or ANOTHERONEOFSTATBARS_CONFIG_DEFS
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
            local ctrl = gbox:CreateOrGetControl("numupdown", "num" .. v.name,math.max(200, 5 + label:GetWidth() + 10), y + h, 150, h)
            AUTO_CAST(ctrl)
            ctrl:SetFontName("white_20_ol");
            ctrl:ShowWindow(1);
            ctrl:MakeButtons("btn_numdown", "btn_numup", "editbox_s");
            ctrl:SetNumberValue(config[v.name] or v.default)
        end
        y = y + h
        if (v.child) then
            ANOTHERONEOFSTATBARSCONFIG_INITGBOX(gbox, config, v.child, y)
        end
    end
end

function ANOTHERONEOFSTATBARSCONFIG_SAVETOSTRUCTURE(gbox, config, node)
    gbox=gbox or AUTO_CAST(g.cframe :GetChild("gbox"))
    config=config or g.settings
    node = node or ANOTHERONEOFSTATBARS_CONFIG_DEFS
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
            ANOTHERONEOFSTATBARSCONFIG_SAVETOSTRUCTURE(gbox, config, v.child)
        end
    end
end
