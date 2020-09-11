--uimodeexpert
--アドオン名（大文字）
local addonName = 'uimodeexpert'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
local acutil = require('acutil')
local debug = false
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
g._needToRefresh=0
g.keydef = {
    UP = 0x0001,
    DOWN = 0x0002,
    LEFT = 0x0004,
    RIGHT = 0x0008,
    MAIN = 0x0010,
    CANCEL = 0x0020,
    SUB = 0x0040,
    MENU = 0x0080,
    PAGEUP = 0x0100,
    PAGEDOWN = 0x0200,
    SYSMENU = 0x0400,
}
g._KeyboardFunctions= {
    [g.keydef.UP] = function(instance,fn)
        return instance[fn](instance,'UP')
    end,
    [g.keydef.DOWN] = function(instance,fn)
        return instance[fn](instance,'DOWN')
    end,
    [g.keydef.LEFT] = function(instance,fn)
        return instance[fn](instance,'LEFT')
    end,
    [g.keydef.RIGHT] = function(instance,fn)
        return instance[fn](instance,'RIGHT')
    end,
    [g.keydef.MAIN] = function(instance,fn)
        return instance[fn](instance,'Z') or instance[fn](instance,'SPACE') or instance[fn](instance,'ENTER') or instance[fn](instance,'PADENTER')
    end,
    [g.keydef.CANCEL] = function(instance,fn)
        return instance[fn](instance,'X') or instance[fn](instance,'ESCAPE')
    end,
    [g.keydef.SUB] = function(instance,fn)
        return instance[fn](instance,'C')
    end,
    [g.keydef.MENU] = function(instance,fn)
        return instance[fn](instance,'V')
    end,
    [g.keydef.PAGEUP] = function(instance,fn)
        return instance[fn](instance,'PRIOR')
    end,
    [g.keydef.PAGEDOWN] = function(instance,fn)
        return instance[fn](instance,'NEXT')
    end,
    [g.keydef.SYSMENU] = function(instance,fn)
        return instance[fn](instance,']')
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
    MENU = 0x0080,
    PAGEUP = 0x0100,
    PAGEDOWN = 0x0200,
    SYSMENU = 0x0400,
    _repeattime=10,
    _repeatinterval=3,
        
    _timer={},
    _KeyboardIsKeyDown = function(self, rawkey)
        return keyboard.IsKeyDown(rawkey) == 1
    end,
    _KeyboardIsKeyPress = function(self, rawkey)
        return keyboard.IsKeyPressed(rawkey) == 1
    end,
    Tick=function(self)
        for k,v in pairs(g._KeyboardFunctions) do
            if not v(g.key,'_KeyboardIsKeyPress') then
                g.key._timer[k] =nil
            else
                if g.key._timer[k] ~=nil then
                    g.key._timer[k]=g.key._timer[k]+1
                else
                    g.key._timer[k]=0
                end
            end

        end
    end,
    IsKeyDown = function(self, key)

        local keyfn = g._KeyboardFunctions[key]
       
        if keyfn and keyfn(g.key,'_KeyboardIsKeyDown')  then
           
            return true
            
        end
        return false
    end,
    IsKeyPress = function(self, key)

        local keyfn = g._KeyboardFunctions[key]
       
        if keyfn and keyfn(g.key,'_KeyboardIsKeyPress')  then
            if  g.key._timer[key]==nil or g.key._timer[key]==0   then
                return true
            elseif   (g.key._timer[key]>=g.key._repeattime)and(g.key._timer[key]-g.key._repeattime)%g.key._repeatinterval==0 then
                return true
            end
        end
        return false
    end
}
g.initialize = function(self)
end
g.enableHotKey = function(self)
    if (g._hotkeyenablecount == 0) then
        keyboard.EnableHotKey(true)
    --ui.SetHoldUI(false);
    end
    g._hotkeyenablecount = g._hotkeyenablecount + 1
end
g.disableHotKey = function(self)
    if (g._hotkeyenablecount > 0) then
        g._hotkeyenablecount = g._hotkeyenablecount - 1
    end
    if (g._hotkeyenablecount == 0) then
        keyboard.EnableHotKey(false)
    --ui.SetHoldUI(true);
    end
end
g.cleanupMessageBox = function(self)
    for k, v in pairs(self._msgBoxes) do
        local msgbox = ui.GetMsgBox(k) or  ui.GetMsgBoxByNonNestedKey(k)
        if (not msgbox or msgbox:IsVisible() == 0) then
            self._msgBoxes[k] = nil
            self:triggerCloseMessageBox(k)
        end
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
                handler = g._registeredFrameHandlers[k](k, frame)
                local key = #g._activeHandlers + 1
                g._activeHandlers[key] = handler
                handler:enter()
                ReserveScript(string.format('UIMODEEXPERT_DELAYEDENTER(%d)', key, 0.1))
            end
        else
            --registered
            local frame = ui.GetFrame(k)
            if not frame or frame:IsVisible() == 0 then
                handler:leave()
                table.remove(g._activeHandlers, idx)
            end
        end
    end
end
g.onChangedCursor = function(self)
    imcSound.PlaySoundEvent('sys_mouseover_percussion_1')
end
g.moveMouse=function(self,x,y)
    self._mousemoveto={x=x,y=y,ox=mouse.GetX(),oy=mouse.GetY(),time=0,maxtime=5}
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
            self._msgBoxes[keys] = nil
            break
        end
    end
end
g.triggerShowMessageBox = function(self, msgbox,key, btncount, yesscp, noscp, etcscp)
    EBI_try_catch {
        try = function()
            
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

g.uieHandlerControlTracerGenerator=function(flags)
    return function(key,frame,...)
        return g.uieHandlerControlTracer.new(key,frame,flags or g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON,...)
    end
end
g._registeredFrameHandlers = {
    ['portal_seller'] = g.uieHandlerControlTracerGenerator(),
    ['itembuffrepair'] = g.uieHandlerControlTracerGenerator(),
    ['buffseller_target'] = g.uieHandlerControlTracerGenerator(),
    ['appraisal_pc'] = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON|g.uieHandlerControlTracer.FLAG_ENABLE_CHECKBOX),
    ['fishing'] = g.uieHandlerControlTracerGenerator(g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON|g.uieHandlerControlTracer.FLAG_ENABLE_SLOT),
    ['fishing_item_bag'] = g.uieHandlerControlTracerGenerator(),
    ['indunenter'] = g.uieHandlerControlTracerGenerator(),
    ['inventory'] = function(...) return g.uieHandlerInventoryBase.new(...) end,
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
function UIMODEEXPERT_UI_MSGBOX(msgBoxStr, yesScp, noScp,...)
    local ret = ui.MsgBox_NonNested_OLD(msgBoxStr,msgBoxStr, yesScp, noScp,...)
    print(tostring(ret))
    local tag=ui.ConvertScpArgMsgTag(msgBoxStr)
    g:triggerShowMessageBox(ret,tag or msgBoxStr, 2, yesScp, noScp)
    return ret
end

function UIMODEEXPERT_UI_MSGBOXETC(key, yesScp, noScp, etcScp, msgBoxStr,...)
    local ret = ui.MsgBoxEtc_OLD(key, yesScp, noScp, etcScp, msgBoxStr,...)
    g:triggerShowMessageBox(ret,key, 3, yesScp, noScp, etcScp)
    return ret
end

function UIMODEEXPERT_UI_MSGBOX_NONNESTED(msgBoxStr, key, yesScp, noScp,...)
    local ret = ui.MsgBox_NonNested_OLD(msgBoxStr, key, yesScp, noScp,...)
    g:triggerShowMessageBox(ret,key or msgBoxStr, 2, yesScp, noScp)
    return ret
end

function UIMODEEXPERT_UI_MSGBOX_NONNESTED_EX(msgBoxStr, flag, key, yesScp, noScp,...)
    local ret = ui.MsgBox_NonNested_Ex_OLD(msgBoxStr, flag, key, yesScp, noScp,...)
    g:triggerShowMessageBox(ret,key or msgBoxStr, 2, yesScp, noScp)
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
            g:checkFrames()
            g.key:Tick()
            if g._needToRefresh>0 then
                g._needToRefresh=g._needToRefresh-1
                if g._needToRefresh==0 then
                    UIMODEEXPERT_ON_REFRESH()
                end
                return
            end
            while #g._activeHandlers > 0 do
                local k = #g._activeHandlers
                local v = g._activeHandlers[k]
               
                local ret=v:tick();
                if ret==g.uieHandlerBase.RefEnd then
                    v:leave()
                    g._activeHandlers[k] = nil
                    k = #g._activeHandlers
                    if k>0 then
                        g._activeHandlers[k]:refresh()
                    end
                    break
                elseif ret==g.uieHandlerBase.RefPass then
                    break
                elseif ret==g.uieHandlerBase.RefRefresh then
                    g._needToRefresh=5
                    break;
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
                local destpos = {x=g._mousemoveto.x,y=g._mousemoveto.y}
                local curpos = {x=g._mousemoveto.ox,y=g._mousemoveto.oy}
        
                mouse.SetPos(curpos.x + (destpos.x - curpos.x) *math.pow(g._mousemoveto.time/g._mousemoveto.maxtime,0.5),
                curpos.y + (destpos.y - curpos.y) *math.pow(g._mousemoveto.time/g._mousemoveto.maxtime,0.5))
                g._mousemoveto.time=g._mousemoveto.time+1
                if g._mousemoveto.time>g._mousemoveto.maxtime then
                    g._mousemoveto = nil
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
