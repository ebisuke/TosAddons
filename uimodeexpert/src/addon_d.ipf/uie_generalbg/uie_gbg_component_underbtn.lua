--uie_gbg_component_underbtn

local acutil = require('acutil')

--ライブラリ読み込み
local debug = false
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
            if (debug == true) then
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

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

--btn={
--    name:string,
--    caption:string,
--    callback:function,
--    skin:string,
--    isdetermine:bool
--    iscancel:bool
--    width:number
--    space:number
--}

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT

g.gbg.uiegbgComponentUnderBtn = {
    _instances = {},
    new = function(tab, parent, name, btns)
        local self = inherit(g.gbg.uiegbgComponentUnderBtn, g.gbg.uiegbgComponentBase, tab, parent, name)
        self.btns = btns

        return self
    end,
    initializeImpl = function(self, gbox)
        local gboxin = gbox:CreateOrGetControl('groupbox', 'gboxin', 0, 0, 0, 0)

        AUTO_CAST(gboxin)
        local x = 0
        for k, v in ipairs(self.btns) do
            local btn = gboxin:CreateOrGetControl('button', 'btn' .. v.name, x, 0, v.width or 100, 40)
            AUTO_CAST(btn)
            if v.skin then
                btn:SetSkinName(v.skin)
            end

            btn:SetText(v.caption)
            btn:SetEventScript(ui.LBUTTONUP, 'UIE_GENERALBG_COMPONENT_UNDERBTN_LCLICK')
            btn:SetEventScriptArgString(ui.LBUTTONUP, self.name)
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, k)
            x=x+btn:GetWidth()+(v.space or 10)
        end

        gboxin:AutoSize(1)
        gboxin:SetGravity(ui.RIGHT,ui.CENTER_VERT)
        g.gbg.uiegbgComponentUnderBtn._instances[self.name] = self
    end
}
UIMODEEXPERT = g
function UIE_GENERALBG_COMPONENT_UNDERBTN_LCLICK(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(framename)
            local instance = g.gbg.uiegbgComponentUnderBtn._instances[argstr]
            local btn=instance.btns[argnum]
            if btn.callback then
                assert(pcall(btn.callback))
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
