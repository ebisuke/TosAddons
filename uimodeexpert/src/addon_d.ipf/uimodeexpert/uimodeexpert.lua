--uimodeexpert
--アドオン名（大文字）
local addonName = 'uimodeexpert'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
local acutil = require('acutil')
local debug = true
--ライブラリ読み込み

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

UIMODEEXPERT = UIMODEEXPERT or {}
local g = UIMODEEXPERT
g.framename = 'uimodeexpert'
g._mousemoveto = nil
g._hotkeyenablecount = 0
g._needToRefresh = 0
g._isEnable = true
g._activeFrames = {}
g._activeFrameCount = 0
g._activeHandlers = {}
g.keydef = {
    UP = 0x0001,
    DOWN = 0x0002,
    LEFT = 0x0004,
    RIGHT = 0x0008,
    MAIN = 0x0010,
    CANCEL = 0x0020,
    SUB = 0x0040,
    TABLEFT = 0x0080,
    TABRIGHT = 0x0100,
    MENU = 0x0200,
    PAGEUP = 0x0400,
    PAGEDOWN = 0x0800,
    SYSMENU = 0x1000
}
g._KeyboardFunctions = {
    [g.keydef.UP] = function(instance, fn)
        return instance[fn](instance, 'UP')
    end,
    [g.keydef.DOWN] = function(instance, fn)
        return instance[fn](instance, 'DOWN')
    end,
    [g.keydef.LEFT] = function(instance, fn)
        return instance[fn](instance, 'LEFT')
    end,
    [g.keydef.RIGHT] = function(instance, fn)
        return instance[fn](instance, 'RIGHT')
    end,
    [g.keydef.MAIN] = function(instance, fn)
        return instance[fn](instance, 'Z')
    end,
    [g.keydef.CANCEL] = function(instance, fn)
        return instance[fn](instance, 'X') or instance[fn](instance, 'ESCAPE')
    end,
    [g.keydef.SUB] = function(instance, fn)
        return instance[fn](instance, 'C')
    end,
    [g.keydef.MENU] = function(instance, fn)
        return instance[fn](instance, 'V')
    end,
    [g.keydef.TABLEFT] = function(instance, fn)
        return instance[fn](instance, 'A')
    end,
    [g.keydef.TABRIGHT] = function(instance, fn)
        return instance[fn](instance, 'S')
    end,
    [g.keydef.PAGEUP] = function(instance, fn)
        return instance[fn](instance, 'PRIOR')
    end,
    [g.keydef.PAGEDOWN] = function(instance, fn)
        return instance[fn](instance, 'NEXT')
    end,
    [g.keydef.SYSMENU] = function(instance, fn)
        return instance[fn](instance, ']')
    end
}
g._JoystickFunctions = {
    [g.keydef.UP] = function(instance, fn)
        return instance[fn](instance, 'JOY_UP')
    end,
    [g.keydef.DOWN] = function(instance, fn)
        return instance[fn](instance, 'JOY_DOWN')
    end,
    [g.keydef.LEFT] = function(instance, fn)
        return instance[fn](instance, 'JOY_LEFT')
    end,
    [g.keydef.RIGHT] = function(instance, fn)
        return instance[fn](instance, 'JOY_RIGHT')
    end,
    [g.keydef.MAIN] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_2')
    end,
    [g.keydef.CANCEL] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_1')
    end,
    [g.keydef.SUB] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_3')
    end,
    [g.keydef.MENU] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_4')
    end,
    [g.keydef.TABLEFT] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_7')
    end,
    [g.keydef.TABRIGHT] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_8')
    end,
    [g.keydef.PAGEUP] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_5')
    end,
    [g.keydef.PAGEDOWN] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_6')
    end,
    [g.keydef.SYSMENU] = function(instance, fn)
        return instance[fn](instance, 'JOY_BTN_8') and instance[fn](instance, 'JOY_BTN_5')
    end
}
g.key = {
    UP = 0x0001,
    DOWN = 0x0002,
    LEFT = 0x0004,
    RIGHT = 0x0008,
    MAIN = 0x0010,
    CANCEL = 0x0020,
    SUB = 0x0040,
    TABLEFT = 0x0080,
    TABRIGHT = 0x0100,
    MENU = 0x0200,
    PAGEUP = 0x0400,
    PAGEDOWN = 0x0800,
    SYSMENU = 0x1000,
    _repeattime = 10,
    _repeatinterval = 3,
    _timer = {},
    _KeyboardIsKeyDown = function(self, rawkey)
        return keyboard.IsKeyDown(rawkey) == 1
    end,
    _KeyboardIsKeyPress = function(self, rawkey)
        return keyboard.IsKeyPressed(rawkey) == 1
    end,
    _JotStickIsKeyPress = function(self, rawkey)
        return keyboard.IsKeyPressed(rawkey) == 1
    end,
    Tick = function(self)
        if IsJoyStickMode() == 1 then
            for k, v in pairs(g._JoystickFunctions) do
                if not v(g.key, '_JotStickIsKeyPress') then
                    g.key._timer[k] = nil
                else
                    if g.key._timer[k] ~= nil then
                        g.key._timer[k] = g.key._timer[k] + 1
                    else
                        g.key._timer[k] = 0
                    end
                end
            end
        else
            for k, v in pairs(g._KeyboardFunctions) do
                if not v(g.key, '_KeyboardIsKeyPress') then
                    g.key._timer[k] = nil
                else
                    if g.key._timer[k] ~= nil then
                        g.key._timer[k] = g.key._timer[k] + 1
                    else
                        g.key._timer[k] = 0
                    end
                end
            end
        end
    end,
    IsKeyDown = function(self, key)
        if IsJoyStickMode() == 1 then
            local keyfn = g._JoystickFunctions[key]

            if keyfn and keyfn(g.key, '_JotStickIsKeyPress') then
                if g.key._timer[key] == nil or g.key._timer[key] == 0 then
                    return true
                end
                return false
            end
            return false
        else
            local keyfn = g._KeyboardFunctions[key]

            if keyfn and keyfn(g.key, '_KeyboardIsKeyDown') then
                return true
            end
            return false
        end
    end,
    --key repeat
    IsKeyPress = function(self, key)
        if IsJoyStickMode() == 1 then
            local keyfn = g._JoystickFunctions[key]
            if keyfn and keyfn(g.key, '_JotStickIsKeyPress') then
                if g.key._timer[key] == nil or g.key._timer[key] == 0 then
                    return true
                elseif (g.key._timer[key] >= g.key._repeattime) and (g.key._timer[key] - g.key._repeattime) % g.key._repeatinterval == 0 then
                    return true
                end
            end
        else
            local keyfn = g._KeyboardFunctions[key]

            if keyfn and keyfn(g.key, '_KeyboardIsKeyPress') then
                if g.key._timer[key] == nil or g.key._timer[key] == 0 then
                    return true
                elseif (g.key._timer[key] >= g.key._repeattime) and (g.key._timer[key] - g.key._repeattime) % g.key._repeatinterval == 0 then
                    return true
                end
            end
            return false
        end
    end,
    --always
    IsKeyPressed = function(self, key)
        if IsJoyStickMode() == 1 then
            local keyfn = g._JoystickFunctions[key]
            if keyfn and keyfn(g.key, '_JotStickIsKeyPress') then
                return true
            end
        else
            local keyfn = g._KeyboardFunctions[key]

            if keyfn and keyfn(g.key, '_KeyboardIsKeyPress') then
                return true
            end
            return false
        end
    end
}
g.initialize = function(self)
end
g.enableHotKey = function(self)
    --obsolete
    -- g._hotkeyenablecount = g._hotkeyenablecount + 1
    -- if (g._hotkeyenablecount == 0) then
    --     keyboard.EnableHotKey(true)
    --     self._mousemoveto = nil
    --     ui.SetTopMostFrame()
    --     ui.GetFrame('uie_cursor'):ShowWindow(0)
    -- --ui.SetHoldUI(false);
    -- end
end
g.disableHotKey = function(self)
    --obsolete
    -- if (g._hotkeyenablecount == 0) then
    --     keyboard.EnableHotKey(false)
    --     self._mousemoveto = nil
    --     local frame = ui.GetFrame('uie_cursor')
    --     ui.SetTopMostFrame()
    --     frame:ShowWindow(0)
    --     if (g.isHighRes()) then
    --         frame:SetOffset(option.GetClientWidth() / 4, option.GetClientHeight() / 2)
    --         frame:Resize(1, 1)
    --     else
    --         frame:SetOffset(option.GetClientWidth() / 2, option.GetClientHeight())
    --         frame:Resize(1, 1)
    --     end
    -- --ui.SetHoldUI(true);
    -- end
    -- g._hotkeyenablecount = g._hotkeyenablecount - 1
end

g.cleanupMessageBox = function(self)
    for k, v in pairs(self._msgBoxes) do
        local msgbox = ui.GetMsgBox(k) or ui.GetMsgBoxByNonNestedKey(k)
        if (not msgbox or msgbox:IsVisible() == 0) then
            self._msgBoxes[k] = nil
            self:triggerCloseMessageBox(k)
        end
    end
end
g.attachHandler = function(handler)
    local key = #g._activeHandlers + 1
    g._activeHandlers[key] = handler

    handler:enter()

    ReserveScript(string.format('UIMODEEXPERT_DELAYEDENTER(%d)', key, 0.1))

    if key == 1 then
        local frame = ui.GetFrame('uie_cursor')

        frame:ShowWindow(1)
        if (g.isHighRes()) then
            frame:SetOffset(option.GetClientWidth() / 4, option.GetClientHeight() / 2)
            frame:Resize(1, 1)
        else
            frame:SetOffset(option.GetClientWidth() / 2, option.GetClientHeight())
            frame:Resize(1, 1)
        end
    end
end
g.detachHandlerByFrame = function(frame)
    local handler = nil
    local idx
    for kk, vv in ipairs(g._activeHandlers) do
        if vv.frame == frame then
            idx = kk
            handler = vv
            if handler then
                g.detachHandler(handler)
            end
        end
    end
end
g.detachHandler = function(handler)
    for k, v in ipairs(g._activeHandlers) do
        if v == handler then
            table.remove(g._activeHandlers, k)
            v:leave()
            if handler._overrider then
                DBGOUT('restore:' .. k)
                handler._overrider:restore()
            end
            DBGOUT('detach' .. (handler.key or '(nil)'))

            break
        end
    end

    if #g._activeHandlers == 0 then
        --ui.SetHoldUI(false);
        keyboard.EnableHotKey(true)
        g._mousemoveto = nil
        DBGOUT('DIED:')
        --ui.SetTopMostFrame()

        ui.GetFrame('uie_cursor'):ShowWindow(0)
    else
        DBGOUT('REMAIN:' .. #g._activeHandlers)
    end
end
g.Enable = function(self, enable)
    self._isEnable = enable
    if not self._isEnable then
        self._msgBoxes = {}
        for _, v in ipairs(self._activeHandlers) do
            if v._overrider then
                v._overrider:restore()
            end
        end

        self._activeHandlers = {}
        self._hotkeyenablecount = 0
        self:enableHotKey()
        self._mousemoveto = nil
    end
end
g.checkFrames = function(self)
    EBI_try_catch {
        try = function()
            for k, v in pairs(g._registeredFrameHandlers) do
                local handler = nil

                for kk, vv in ipairs(g._activeHandlers) do
                    if vv.key == k then

                        handler = vv
                        break
                    end
                end
                if not handler then
                    -- not registered
                    local frame = ui.GetFrame(k)
                    if frame and frame:IsVisible() == 1 then
                        DBGOUT('enter:' .. k)
                        local overrider = nil
                        if g._registeredFrameHandlers[k].overrider then
                            local ret = g._registeredFrameHandlers[k].overrider(k, frame)
                            overrider = ret
                            if ret == false then
                                --cancel operation
                                return
                            elseif ret then
                                handler = ret:override()
                                if not handler then
                                    handler = g._registeredFrameHandlers[k].generator(k, frame)
                                end
                            else
                                handler = g._registeredFrameHandlers[k].generator(k, frame)
                            end
                        else
                            handler = g._registeredFrameHandlers[k].generator(k, frame)
                        end
                        handler._overrider = overrider
                        handler.key=k
                        g.attachHandler(handler)
                    end
                else
                    --registered
                    local frame = ui.GetFrame(k)

                    if not frame or frame:IsVisible() == 0 then
                        DBGOUT('leave:' .. k)
                        g.detachHandler(handler)

                    end
                end
            end
            for k, v in pairs(g._activeHandlers) do
                local handler = v

                
                    --registered
                if v.key then
                    local frame = ui.GetFrame(v.key)

                    if not frame or frame:IsVisible() == 0 then
                        DBGOUT('leave:' .. v.key)
                        g.detachHandler(handler)
                    end
                end
            end
            --gbg
            for k, v in pairs(g._registeredFrameGeneralbg) do
                local gb = nil
                local idx
                for kk, vv in pairs(g._activeFrames) do
                    if kk == k then
                        idx = kk
                        gb = vv
                        break
                    end
                end
                if not gb then
                    -- not registered
                    local frame = ui.GetFrame(k)
                    if frame and frame:IsVisible() == 1 and (g._activeFrameCount == 0 or g._activeFramePriority > (v.priority or 0)) then
                        DBGOUT('gb enter:' .. k..'/'..(v.priority or 0))
                        if g._activeFrameCount > 0 then
                            for kk, vv in pairs(g._activeFrames) do
                                DBGOUT('gb enter kick:' .. kk..'/'.. g._activeFramePriority)
                                vv:release()
                                g._activeFrameCount = g._activeFrameCount - 1
                            end
                            g._activeFrames = {}
                            g.gbg.setActiveInstance(nil)
                        end
                        --g.gbg.initialize()
                        local instance = v.class.new(ui.GetFrame('uie_generalbg'), k, '', v.arg)
                        g.gbg.setActiveInstance(instance)
                        g._activeFrames[k] = instance
                        g._activeFrameCount = g._activeFrameCount + 1
                        g._activeFramePriority = v.priority or 0
                        instance:initialize()

                        g.gbg.showFrame()
                      
                       
                    end
                else
                    --registered
                    local frame = ui.GetFrame(k)

                    if not frame or frame:IsVisible() == 0 then
                        g._activeFrames[k] = nil
                        g._activeFrameCount = g._activeFrameCount - 1
                        DBGOUT('gb leave:' .. k .. idx)
                        gb:release()
                        DBGOUT('gb leaveaa2:' .. k .. idx)
                        g.gbg.hideFrame()
                        DBGOUT('gb leaveaa3:' .. k .. idx)

                        g.gbg.setActiveInstance(nil)
                        g._activeFramePriority = 0
                        DBGOUT('gb leaveaa:' .. k .. idx)
                    elseif ui.GetFrame('uie_generalbg'):IsVisible() == 0 then
                        g._activeFrames[k] = nil
                        g._activeFrameCount = g._activeFrameCount - 1
                        DBGOUT('gb leave3:' .. k)
                        gb:release()
                        g.gbg.hideFrame()
                        ui.GetFrame(k):ShowWindow(0)

                        g.gbg.setActiveInstance(nil)
                        g._activeFramePriority = 0
                        DBGOUT('gb leaveaa3:' .. k .. idx)
                    elseif gb._isReleased or gb._giveUp then
                        g._activeFrames[k] = nil
                        g._activeFrameCount = g._activeFrameCount - 1
                        DBGOUT('gb leave2:' .. k)

                        ui.GetFrame(k):ShowWindow(0)

                        g.gbg.setActiveInstance(nil)
                        g._activeFramePriority = 0
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
g.setCursorMode = function(mode)
    g._cursormode = mode
end
g.onChangedCursor = function(self)
    imcSound.PlaySoundEvent('sys_mouseover_percussion_1')
end
g.moveMouse = function(self, x, y, w, h, ctrl)
    local frame = ui.GetFrame('uie_cursor')
    ui.GetFrame('uie_cursor'):ShowWindow(1)

    ui.SetTopMostFrame(ui.GetFrame('uie_cursor'))

    self._mousemoveto = {x = x, y = y, w = w, h = h, ctrl = nil, ox = frame:GetX(), oy = frame:GetY(), ow = frame:GetWidth(), oh = frame:GetHeight(), time = 0, maxtime = 5}
end
g.onCanceledCursor = function(self)
    imcSound.PlaySoundEvent('textballoon_open')
end
g.onDeterminedCursor = function(self)
    imcSound.PlaySoundEvent('sys_popup_open_2')
end
g.triggerCloseMessageBox = function(self, keys)
    for _, v in ipairs(g._activeHandlers) do
        if v.key == keys then
            v:leave()
            if v._overrider then
                v._overrider:restore()
            end
            self._msgBoxes[keys] = nil
            break
        end
    end
end
g.showOriginalInventory = function(self)
    g._showInventory = 1

    ui.GetFrame('inventory'):ShowWindow(1)
end
g.isHighRes = function(self)
    return option.GetClientWidth() >= 3000
end
g.triggerShowMessageBox = function(self, msgbox, key, btncount, yesscp, noscp, etcscp)
    EBI_try_catch {
        try = function()
            if not g._isEnable then
                return
            end

            self._msgBoxes[key] = msgbox
            --AUTO_CAST(msgbox)
            local handler = g.uieHandlerGenericDialog.new(key, btncount, yesscp, noscp, etcscp)
            local keys = #g._activeHandlers + 1
            g._activeHandlers[keys] = handler
            handler:enter()
            ReserveScript(string.format('UIMODEEXPERT_DELAYEDENTER(%d)', keys, 0.1))
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
g._msgBoxes = {}
g.tr = function(translateStr)
    return translateStr
end
g.uieHandlerControlTracerGenerator = function(flags)
    return function(key, frame, ...)
        return g.uieHandlerControlTracer.new(key, frame, flags or g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON, ...)
    end
end
g._registeredFrameGeneralbg = {
    ['shop'] = {class = g.gbg.uiegbgShop},
    --['inventory'] = {class = g.gbg.uiegbgGroupMe, arg = 1, priority = 100},
    --['status'] = {class = g.gbg.uiegbgGroupMe, arg = 2},
    ['fishing'] = {class = g.gbg.uiegbgFishing}
}
g._registeredFrameHandlers = {
    ['bookitemread'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['warningmsgbox'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['uie_menu_sub'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON)
    },
    ['fishing_item_bag'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON)
    },
    ['dialogselect'] = {
        generator = function(...)
            return g.uieHandlerDummy.new(...)
        end
    },
    ['dialog'] = {
        generator = function(...)
            return g.uieHandlerDummy.new(...)
        end
    },
    ['dialogillust'] = {
        generator = function(...)
            return g.uieHandlerDummy.new(...)
        end
    }
}
g._activeHandlers = {}
UIMODEEXPERT = g

--マップ読み込み時処理（1度だけ）
function UIMODEEXPERT_DELAYEDENTER(key)
    if g._activeHandlers[key] then
        g._activeHandlers[key]:delayedenter()
    end
end
function UIMODEEXPERT_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)

            addon:RegisterMsg('FPS_UPDATE', 'UIMODEEXPERT_FPS_UPDATE')
            local timer = frame:GetChild('addontimer')
            AUTO_CAST(timer)
            timer:SetUpdateScript('UIMODEEXPERT_ON_TICK')
            timer:Start(0.01)
            keyboard.EnableHotKey(true)
            ui.SetHoldUI(false)
            acutil.slashCommand('/uie', UIMODEEXPERT_PROCESS_COMMAND)
            if (not ui.MsgBox_OLD) then
                ui.MsgBox_OLD = ui.MsgBox
                ui.MsgBox = UIMODEEXPERT_UI_MSGBOX
            end
            if (ui.MsgBox ~= UIMODEEXPERT_UI_MSGBOX) then
                ui.MsgBox = UIMODEEXPERT_UI_MSGBOX
            end
            if (not ui.MsgBoxEtc_OLD) then
                ui.MsgBoxEtc_OLD = ui.MsgBoxEtc
                ui.MsgBoxEtc = UIMODEEXPERT_UI_MSGBOXETC
            end
            if (ui.MsgBoxEtc ~= UIMODEEXPERT_UI_MSGBOXETC) then
                ui.MsgBoxEtc = UIMODEEXPERT_UI_MSGBOXETC
            end

            if (not ui.MsgBox_NonNested_OLD) then
                ui.MsgBox_NonNested_OLD = ui.MsgBox_NonNested
                ui.MsgBox_NonNested = UIMODEEXPERT_UI_MSGBOX_NONNESTED
            end
            if (ui.MsgBox_NonNested ~= UIMODEEXPERT_UI_MSGBOX_NONNESTED) then
                ui.MsgBox_NonNested = UIMODEEXPERT_UI_MSGBOX_NONNESTED
            end
            if (not ui.MsgBox_NonNested_Ex_OLD) then
                ui.MsgBox_NonNested_Ex_OLD = ui.MsgBox_NonNested_Ex
                ui.MsgBox_NonNested_Ex = UIMODEEXPERT_UI_MSGBOX_NONNESTED_EX
            end
            if (ui.MsgBox_NonNested_Ex ~= UIMODEEXPERT_UI_MSGBOX_NONNESTED_EX) then
                ui.MsgBox_NonNested_Ex = UIMODEEXPERT_UI_MSGBOX_NONNESTED_EX
            end
            --g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
g.hasher = function(str)
    local hash = 6700417
    for i = 1, #str do
        hash = hash * 137 + str:byte(i)
    end
    return tostring(hash)
end
function UIMODEEXPERT_UI_MSGBOX(msgBoxStr, yesScp, noScp, ...)
    if g._isEnable then
        local key = g.hasher(msgBoxStr)

        local ret = ui.MsgBox_NonNested_OLD(msgBoxStr, 'ABCDEFGH' .. key, yesScp, noScp, ...)
        local tag = ui.ConvertScpArgMsgTag(msgBoxStr)
        g:triggerShowMessageBox(ret, 'ABCDEFGH' .. key, 2, yesScp, noScp)
        return ret
    else
        local ret = ui.MsgBox_OLD(msgBoxStr, yesScp, noScp, ...)
        return ret
    end
end

function UIMODEEXPERT_UI_MSGBOXETC(key, yesScp, noScp, etcScp, msgBoxStr, ...)
    local ret = ui.MsgBoxEtc_OLD(key, yesScp, noScp, etcScp, msgBoxStr, ...)
    g:triggerShowMessageBox(ret, key, 3, yesScp, noScp, etcScp)
    return ret
end

function UIMODEEXPERT_UI_MSGBOX_NONNESTED(msgBoxStr, key, yesScp, noScp, ...)
    local ret = ui.MsgBox_NonNested_OLD(msgBoxStr, key, yesScp, noScp, ...)
    g:triggerShowMessageBox(ret, key or msgBoxStr, 2, yesScp, noScp)
    return ret
end

function UIMODEEXPERT_UI_MSGBOX_NONNESTED_EX(msgBoxStr, flag, key, yesScp, noScp, ...)
    local ret = ui.MsgBox_NonNested_Ex_OLD(msgBoxStr, flag, key, yesScp, noScp, ...)
    g:triggerShowMessageBox(ret, key or msgBoxStr, 2, yesScp, noScp)
    return ret
end
function UIMODEEXPERT_ON_REFRESH()
    while #g._activeHandlers > 0 do
        local k = #g._activeHandlers
        local v = g._activeHandlers[k]
        v:refresh()
        break
    end
end
function UIMODEEXPERT_ON_TICK(frame)
    EBI_try_catch {
        try = function()
            if not g._isEnable then
                return
            end
            g:checkFrames()
            g.key:Tick()
            if g._needToRefresh > 0 then
                g._needToRefresh = g._needToRefresh - 1
                if g._needToRefresh == 0 then
                    UIMODEEXPERT_ON_REFRESH()
                end
                return
            end
            while #g._activeHandlers > 0 do
                local k = #g._activeHandlers
                local v = g._activeHandlers[k]
                local ret
                if not v._giveup then
                    ret = v:tick()
                else
                    ret = g.uieHandlerBase.RefEnd
                end

                if ret == g.uieHandlerBase.RefEnd then
                    DBGOUT('leavef:' .. k)
                    local prevk = k
                    g.detachHandler(v)
                    --table.remove(g._activeHandlers, k)
                    k = #g._activeHandlers
                    if k > 0 and prevk ~= k then
                        g._activeHandlers[k]:refresh()
                    end
                    break
                elseif ret == g.uieHandlerBase.RefPass then
                    break
                elseif ret == g.uieHandlerBase.RefRefresh then
                    g._needToRefresh = 10
                    break
                else
                    break
                end
            end

            g:cleanupMessageBox()

            if g._mousemoveto then
                local destpos = {x = g._mousemoveto.x, y = g._mousemoveto.y, w = g._mousemoveto.w, h = g._mousemoveto.h}
                local curpos = {x = g._mousemoveto.ox, y = g._mousemoveto.oy, w = g._mousemoveto.ow, h = g._mousemoveto.oh}
                if g._mousemoveto.ctrl then
                    local ctrl = g._mousemoveto.ctrl
                    destpos = {x = ctrl:GetGlobalX(), y = ctrl:GetGlobalY(), w = ctrl:GetWidth(), h = ctrl:GetHeight()}
                end

                local cursorframe = ui.GetFrame('uie_cursor')

                local lx

                local ly
                if g.isHighRes() then
                    --lx = lx *2
                    --ly = ly *2
                    lx =
                        (curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) +
                        (curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                    ly =
                        (curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) +
                        (curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                else
                    lx =
                        curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                        (curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                    ly =
                        curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                        (curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                end
                -- lx =
                --     curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                --     (curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                -- ly =
                --     curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                --     (curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0

                if g._cursormode then
                    mouse.SetPos(lx, ly)
                    cursorframe:Resize(0, 0)
                    cursorframe:SetOffset(lx, ly)
                else
                    cursorframe:Resize(
                        curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5),
                        curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)
                    )

                    cursorframe:SetOffset(
                        (curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)),
                        (curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5))
                    )
                end
                g._mousemoveto.time = math.min(g._mousemoveto.maxtime, g._mousemoveto.time + 1)
                if g._mousemoveto.time > g._mousemoveto.maxtime then
                --g._mousemoveto = nil
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIMODEEXPERT_FPS_UPDATE(frame)
    frame:ShowWindow(1)
end
function UIMODEEXPERT_PROCESS_COMMAND(command)
    local cmd = ''

    if #command > 0 then
        cmd = table.remove(command, 1)
    else
        local msg = L_('Usagemsg')
        return ui.MsgBox(msg, '', 'Nope')
    end
    if cmd == 'on' then
        g:Enable(true)
        CHAT_SYSTEM('[UIE]ENABLED')
        return
    end
    if cmd == 'off' then
        g:Enable(false)
        CHAT_SYSTEM('[UIE]DISABLED')
        return
    end

    CHAT_SYSTEM(string.format('[%s] Invalid Command', addonName))
end
