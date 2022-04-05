--アドオン名（大文字）
local addonName = "ebiremovedialog"
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
CHAT_SYSTEM("[ERD]loaded")
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

EBIREMOVEDIALOGCONFIG_CONFIG_DEFS = {
    {
        name = "Config",
        vname = "",
        type = "proxy",
        child = {
            
            {
                name = "artsbook",
                vname = "Remove dialog of reading Arts book.",
                type = "boolean",
                default = false,
            },
            {
                name = "cardremove",
                vname = "Remove the dialog of removing the card.",
                type = "boolean",
                default = false,
            },
            {
                name = "cardequip",
                vname = "Remove the dialog of equipping the card.",
                type = "boolean",
                default = false,
            },
            {
                name = "preventshowchallengemodeframe",
                vname = "Fix the problem of the challenge mode frame being displayed.",
                type = "boolean",
                default = false,
            },
            {
                name = "challengemodenextstep",
                vname = "Remove dialog of going to next level in challengemode.",
                type = "boolean",
                default = false,
            },
            {
                name = "challengemodecomplete",
                vname = "Remove dialog of complete challengemode",
                type = "boolean",
                default = false,
            },
            {
                name = "challengemodeabort",
                vname = "Remove dialog of abort challengemode",
                type = "boolean",
                default = false,
            },
            {
                name = "bookreading",
                vname = "Remove dialog of reading a monster cardbook.",
                type = "boolean",
                default = false,
            },
            {
                name = "timelimited",
                vname = "Remove dialog of timelimited item in storage.",
                type = "boolean",
                default = false,
            }
            ,
            {
                name = "dimension",
                vname = "Remove dialog of using dimension ticket.",
                type = "boolean",
                default = false,
            },
            {
                name = "idticket",
                vname = "Remove dialog of using instance dungeon ticket.",
                type = "boolean",
                default = false,
            },
            {
                name = "goldroupedialog",
                vname = "Remove confirmation dialog of Gold Roupe.And keep selected item.",
                type = "boolean",
                default = false,
            },
            {
                name = "normalroupedialog",
                vname = "Remove confirmation dialog of Normal Roupe.And keep selected item.",
                type = "boolean",
                default = false,
            },
            {
                name = "relicgemremovedialog",
                vname = "Remove confirmation dialog when removing a relic gem.",
                type = "boolean",
                default = false,
            },{
                name = "relicgeminstalldialog",
                vname = "Remove confirmation dialog when installing a relic gem.",
                type = "boolean",
                default = false,
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

function EBIREMOVEDIALOGCONFIG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame("ebiremovedialogconfig")
            g.addon = addon
            g.cframe = frame
            acutil.slashCommand("/erdc", EBIREMOVEDIALOGCONFIG_PROCESS_COMMAND);
            
            g.cframe:ShowWindow(0)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function EBIREMOVEDIALOGCONFIG_GENERATEDEFAULT(config, node)
    if (node == nil) then
        node = EBIREMOVEDIALOGCONFIG_CONFIG_DEFS
    end
    for k, v in ipairs(node) do
        if (v.default and config[v.name]==nil) then
            config[v.name] = v.default
        end
        if (v.child) then
            EBIREMOVEDIALOGCONFIG_GENERATEDEFAULT(config, v.child)
        end
    end
    
end
function EBIREMOVEDIALOGCONFIG_PROCESS_COMMAND(command)
    
    g.cframe:ShowWindow(1)


end
function EBIREMOVEDIALOGCONFIG_CLOSE()
    
    g.cframe:ShowWindow(0)

end
function EBIREMOVEDIALOGCONFIG_INIT()
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
            btnsave:SetEventScript(ui.LBUTTONUP, "EBIREMOVEDIALOGCONFIG_SAVE_ONLCLICK")
            btnsave:SetText("{ol}{s16}Apply")
            local label = frame:CreateOrGetControl("richtext", "labelattention", 30, 140, 70, 30)
            AUTO_CAST(label)
            label:SetText("{ol}{s16}* Restart ToS {nl} to apply the settings.")
            EBIREMOVEDIALOGCONFIG_INITGBOX(gbox, g.settings)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EBIREMOVEDIALOGCONFIG_ON_OPEN()
    EBIREMOVEDIALOGCONFIG_INIT()
end
function EBIREMOVEDIALOGCONFIG_SAVE_ONLCLICK()
    local frame = g.cframe;
    EBI_try_catch{
        try = function()
            EBIREMOVEDIALOGCONFIG_SAVETOSTRUCTURE()
            EBIREMOVEDIALOG_SAVE_SETTINGS()
            EBIREMOVEDIALOG_LOAD_SETTINGS()
            CHAT_SYSTEM("[ERD]SAVED")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EBIREMOVEDIALOGCONFIG_INITGBOX(gbox, config, node, y)
    y = y or 0
    local h=30
    node = node or EBIREMOVEDIALOGCONFIG_CONFIG_DEFS
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
            EBIREMOVEDIALOGCONFIG_INITGBOX(gbox, config, v.child, y)
        end
    end
end

function EBIREMOVEDIALOGCONFIG_SAVETOSTRUCTURE(gbox, config, node)
    gbox=gbox or AUTO_CAST(g.cframe :GetChild("gbox"))
    config=config or g.settings
    node = node or EBIREMOVEDIALOGCONFIG_CONFIG_DEFS
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
            EBIREMOVEDIALOGCONFIG_SAVETOSTRUCTURE(gbox, config, v.child)
        end
    end
end
