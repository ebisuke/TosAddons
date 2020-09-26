--uie_menu

local acutil = require('acutil')
local framename = 'uie_menu'
--ライブラリ読み込み
local debug = true
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

--マップ読み込み時処理（1度だけ）
function UIE_MENU_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(framename)
            frame:SetSkinName('chat_window')
            frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

UIMODEEXPERT = UIMODEEXPERT or {}
local g = UIMODEEXPERT

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

g.menu = {
    incriment = 1,
    uiePopupMenu = {
        new = function(x, y, width,heightperline,named)
            local self = {}
            setmetatable(self, {__index = g.menu.uiePopupMenu})
            local defx= option.GetClientWidth()/2-width/2
            local defy= option.GetClientHeight()/2-100
            if g.isHighRes() then
                defx= option.GetClientWidth()/4-width/2
                defy= option.GetClientHeight()/4-100
            else
                defx= option.GetClientWidth()/2-width/2
                defy= option.GetClientHeight()/2-100
            end
            self.x = x or defx
            self.y = y or defy
            self.width = width
            self.height = 0
            self.heightperline=heightperline or 20
            self.frame = nil
            self.menus = {}
            self.menucount = 0
            self.top = 5
            if not named then
                self.name = 'uie_menu_sub'
            else
                self.name = 'uie_menu_' .. g.menu.incriment
            end
            g.menu.incriment = g.menu.incriment + 1
            self:initialize()
            return self
        end,
        initialize = function(self)
            local frame = ui.CreateNewFrame('uie_menu', self.name)
            frame:SetSkinName('test_frame_midle')
            self.frameno = g.menu.incriment

            self.frame = frame

            frame:ShowWindow(1)
            frame:SetOffset(self.x, self.y)
            g.menu.uiePopupMenu.instances[self.name] = self
        end,
        addMenu = function(self, caption, callback, clickafterdispose)
            local frame = self.frame
            local btn = frame:CreateOrGetControl('button', 'btn' .. self.menucount, 2, self.top, 20,   self.heightperline)
            AUTO_CAST(btn)
            --btn:EnableAutoResize(true,true)
            self.menucount = self.menucount + 1
            btn:SetSkinName('none')
            btn:SetText('{s24}{ol}'..caption)

            btn:SetEventScript(ui.LBUTTONUP, 'UIE_MENU_ONCLICKEDMENU')
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, #self.menus + 1)
            self.top = self.top + btn:GetHeight() + 2
            local w = btn:GetWidth() + 5 + 5
            frame:Resize(w, self.top + 5)
            if clickafterdispose == nil then
                clickafterdispose = true
            end
            self.menus[#self.menus + 1] = {
                caption = caption,
                callback = callback,
                clickafterdispose = clickafterdispose,
                btn = btn
            }
            local w = 10
            for _, v in ipairs(self.menus) do
                w = math.max(v.btn:GetWidth())
            end
            for _, v in ipairs(self.menus) do
                v.btn:SetGravity(ui.LEFT, ui.TOP)
                v.btn:Resize(w, v.btn:GetHeight())
            end
        end,
        dispose = function(self)
            if self.frame then
                self.frame:ShowWindow(0)
                ui.DestroyFrame(self.frame:GetName())
                self.frame = nil
            end
            g.menu.uiePopupMenu.instances[self.name] = nil
        end,
        instances = {}
    }
}
function UIE_MENU_ONCLICKEDMENU(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            if not g._isEnable then
                return
            end
            local idx = argnum
            local name = frame:GetName()
            local menuobj = g.menu.uiePopupMenu.instances[name]
            if menuobj then
                local item = menuobj.menus[idx]
             
                if item.callback then
                    
                    pcall(item.callback, menuobj)
                end
                if item.clickafterdispose then
                    menuobj:dispose()
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
UIMODEEXPERT = g
