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
    Tick = function(self)
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
    end,
    IsKeyDown = function(self, key)
        local keyfn = g._KeyboardFunctions[key]

        if keyfn and keyfn(g.key, '_KeyboardIsKeyDown') then
            return true
        end
        return false
    end,
    IsKeyPress = function(self, key)
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
}
g.initialize = function(self)
end
g.enableHotKey = function(self)
    g._hotkeyenablecount = g._hotkeyenablecount + 1

    if (g._hotkeyenablecount == 0) then
        keyboard.EnableHotKey(true)
        self._mousemoveto = nil

        ui.SetTopMostFrame()

        ui.GetFrame('uie_cursor'):ShowWindow(0)
    --ui.SetHoldUI(false);
    end
end
g.disableHotKey = function(self)
    if (g._hotkeyenablecount == 0) then
        keyboard.EnableHotKey(false)
        self._mousemoveto = nil
        local frame = ui.GetFrame('uie_cursor')

        ui.SetTopMostFrame()

        frame:ShowWindow(0)
        if (g.isHighRes()) then
            frame:SetOffset(option.GetClientWidth() / 4, option.GetClientHeight() / 2)
            frame:Resize(1, 1)
        else
            frame:SetOffset(option.GetClientWidth() / 2, option.GetClientHeight())
            frame:Resize(1, 1)
        end

    --ui.SetHoldUI(true);
    end
    g._hotkeyenablecount = g._hotkeyenablecount - 1
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
    end
end
g.checkFrames = function(self)
    for k, v in pairs(g._registeredFrameHandlers) do
        local handler = nil
        local idx
        for kk, vv in ipairs(g._activeHandlers) do
            if vv.key == k then
                idx = kk
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
                local key = #g._activeHandlers + 1
                handler._overrider = overrider
                g._activeHandlers[key] = handler
                handler:enter()

                ReserveScript(string.format('UIMODEEXPERT_DELAYEDENTER(%d)', key, 0.1))
            end
        else
            --registered
            local frame = ui.GetFrame(k)

            if not frame or frame:IsVisible() == 0 then
                DBGOUT('leave:' .. k)
                handler:leave()
                if handler._overrider then
                    DBGOUT('restore:' .. k)
                    handler._overrider:restore()
                end
                table.remove(g._activeHandlers, idx)
            end
        end
    end
end
g.onChangedCursor = function(self)
    imcSound.PlaySoundEvent('sys_mouseover_percussion_1')
end
g.moveMouse = function(self, x, y, w, h, ctrl)
    local frame = ui.GetFrame('uie_cursor')
    ui.GetFrame('uie_cursor'):ShowWindow(1)

    ui.SetTopMostFrame(ui.GetFrame('uie_cursor'))
    self._mousemoveto = {x = x, y = y, w = w, h = h, ctrl = ctrl, ox = frame:GetX(), oy = frame:GetY(), ow = frame:GetWidth(), oh = frame:GetHeight(), time = 0, maxtime = 5}

    -- if g.isHighRes() then
    --     self._mousemoveto = {x = x / 2, y = y / 2, w = w, h = h,ctrl=ctrl, ox = frame:GetX(), oy = frame:GetY(), ow = frame:GetWidth(), oh = frame:GetHeight(), time = 0, maxtime = 5}
    --     --self._mousemoveto = {x = x / 2, y = y / 2, w = w, h = h, ox = mouse.GetX() / 2, oy = mouse.GetY() / 2, ow = 2, oh = 2, time = 0, maxtime = 5}
    -- else
    --     self._mousemoveto = {x = x, y = y, w = w, h = h,ctrl=ctrl, ox = frame:GetX(), oy = frame:GetY(), ow = frame:GetWidth(), oh = frame:GetHeight(), time = 0, maxtime = 5}
    --     --self._mousemoveto = {x = x, y = y, w = w, h = h, ox = mouse.GetX(), oy = mouse.GetY(), ow = 2, oh = 2, time = 0, maxtime = 5}
    -- end
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

g.uieHandlerControlTracerGenerator = function(flags)
    return function(key, frame, ...)
        return g.uieHandlerControlTracer.new(key, frame, flags or g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON, ...)
    end
end
g._registeredFrameHandlers = {
    ['portal_seller'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['itembuffrepair'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['buffseller_target'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['appraisal_pc'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON | g.uieHandlerControlTracer.FLAG_ENABLE_CHECKBOX)
    },
    ['fishing'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON | g.uieHandlerControlTracer.FLAG_ENABLE_SLOT)
    },
    ['fishing_item_bag'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['indunenter'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['camp_ui'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['camp_register'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON | g.uieHandlerControlTracer.FLAG_ENABLE_CHECKBOX)
    },
    ['foodtable_ui'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON | g.uieHandlerControlTracer.FLAG_CHANGETAB_BYMENU)
    },
    ['bookitemread'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['warningmsgbox'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['itemdecompose'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON | g.uieHandlerControlTracer.FLAG_ENABLE_CHECKBOX)
    },
    ['shop'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON)
    },
    ['uie_menu_sub'] = {
        generator = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON)
    },
    ['induntheend'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['inputstring'] = {
        generator = g.uieHandlerControlTracerGenerator()
    },
    ['inventory'] = {
        overrider = function(k, frame)
        
                return g.over.uieCallbackedOverrider.new(
                    'inventory',
                    function(overrider)
                        if g._showInventory==1 then
                            g._showInventory = 2
                            DBGOUT('rrr')
                            return g.uieHandlerDummy.new(k, frame)
                        else
                            local inventory = ui.GetFrame('inventory')
                            inventory:ShowWindow(0)
                            DBGOUT('pass')
                            local frame = ui.GetFrame('uie_inventory')
                            ui.ToggleFrame('uie_inventory')
                        end
                        return g.uieHandlerDummyModal.new(k, frame)
                    end,
                    function(overrider)
                    end
                )
            
        end
    },
    ['uie_inventory'] = {
        generator = function(...)
            local frame = ui.GetFrame('uie_inventory')
            return g.uieHandlerUIEInventory.new('uie_inventory', frame)
        end,
        overrider = function(k, frame)
            return g.over.uieCallbackedOverriderDontCare.new(
                'inventory',
                function(overrider)
                   
                    local inventory = ui.GetFrame('inventory')
                    inventory:ShowWindow(0)
                    
                end,
                function(overrider)
                    if g._showInventory==2 then
                        g._showInventory=false
                    else
                    local inventory = ui.GetFrame('inventory')
                    inventory:ShowWindow(0)
                      end
                end
            )
        end
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

                local ret = v:tick()
                if ret == g.uieHandlerBase.RefEnd then
                    v:leave()
                    if (v._overrider and v._overrider.restore) then
                        v._overrider:restore()
                    end
                    DBGOUT('leavef:' .. k)
                    g._activeHandlers[k] = nil
                    k = #g._activeHandlers
                    if k > 0 then
                        g._activeHandlers[k]:refresh()
                    end
                    break
                elseif ret == g.uieHandlerBase.RefPass then
                    break
                elseif ret == g.uieHandlerBase.RefRefresh then
                    g._needToRefresh = 10
                    break
                end
            end

            --for k,v in pairs(g._activeHandlers) do
            --    if v:tick()==false then
            --         g._activeHandlers[k]:leave()
            --       g._activeHandlers[k]=nil
            --    end
            --end
            g:cleanupMessageBox()

            if g._mousemoveto then
                local destpos = {x = g._mousemoveto.x, y = g._mousemoveto.y, w = g._mousemoveto.w, h = g._mousemoveto.h}
                local curpos = {x = g._mousemoveto.ox, y = g._mousemoveto.oy, w = g._mousemoveto.ow, h = g._mousemoveto.oh}
                if g._mousemoveto.ctrl then
                    local ctrl = g._mousemoveto.ctrl
                    destpos = {x = ctrl:GetGlobalX(), y = ctrl:GetGlobalY(), w = ctrl:GetWidth(), h = ctrl:GetHeight()}
                end

                local cursorframe = ui.GetFrame('uie_cursor')

                cursorframe:Resize(
                    curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5),
                    curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)
                )

                cursorframe:SetOffset(
                    (curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)),
                    (curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5))
                )

                local lx

                local ly
                -- if g.isHighRes() then
                --     lx =
                --         (curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) +
                --         (curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                --     ly =
                --         (curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) +
                --         (curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0

                --     lx = lx * 2
                --     ly = ly * 2
                -- else
                --     lx =
                --         curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                --         (curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                --     ly =
                --         curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                --         (curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                -- end
                lx =
                    curpos.x + (destpos.x - curpos.x) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                    (curpos.w + (destpos.w - curpos.w) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                ly =
                    curpos.y + (destpos.y - curpos.y) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5) +
                    (curpos.h + (destpos.h - curpos.h) * math.pow(g._mousemoveto.time / g._mousemoveto.maxtime, 0.5)) / 2.0
                --mouse.SetPos(lx, ly)
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
