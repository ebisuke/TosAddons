--uie_handler

local acutil = require('acutil')
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
UIMODEEXPERT = UIMODEEXPERT or {}
local g = UIMODEEXPERT
local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end
g.uieHandlerBase = {
    RefPass = 1,
    RefEnd = 0,
    RefRefresh = 2,
    new = function(key)
        local self = {key = key}
        return self
    end,
    moveMouseToControl = function(self, ctrl)
        local pos = ctrl:GetTopParentFrame():FramePosToScreenPos(ctrl:GetGlobalX() , ctrl:GetGlobalY() )
        g:moveMouse(pos.x, pos.y,ctrl:GetWidth(),ctrl:GetHeight())
    end,
    enter = function(self)
        g:disableHotKey()
    end,
    refresh = function(self)
    end,
    delayedenter = function(self)
    end,
    tick = function(self)
    end,
    leave = function(self)
        g:enableHotKey()
    end
}
g.uieHandlerGenericDialog = {
    new = function(key, btncount, yesscp, noscp, etcscp)
        local self = inherit(g.uieHandlerGenericDialog, g.uieHandlerBase, key)
        self.btncount = btncount
        self.btncursor = 0
        self.key = key
        self.yesscp = yesscp
        self.noscp = noscp
        self.etcscp = etcscp
        return self
    end,
    enter = function(self)
        self:moveMouse(0)
    end,
    moveMouse = function(self, idx)
        local ctrl
        local msgbox = g._msgBoxes[self.key]
        if idx == 0 then
            ctrl = msgbox:GetChild('YES')
        elseif idx == 1 then
            ctrl = msgbox:GetChild('NO')
        elseif idx == 2 then
            ctrl = msgbox:GetChild('ETC')
        end
        if ctrl then
            local pos = msgbox:FramePosToScreenPos(ctrl:GetGlobalX() , ctrl:GetGlobalY() )
            g:moveMouse(pos.x, pos.y,ctrl:GetWidth(), ctrl:GetHeight() )
        end
    end,
    tick = function(self)
        local msgbox = g._msgBoxes[self.key]
        if msgbox and msgbox:IsVisible() == 1 then
            if g.key:IsKeyPress(g.key.DOWN) or g.key:IsKeyPress(g.key.RIGHT) then
                --down
                self.btncursor = self.btncursor + 1
                if self.btncursor >= self.btncount then
                    self.btncursor = 0
                end
                self:moveMouse(self.btncursor)
                g:onChangedCursor()
            end
            if g.key:IsKeyPress(g.key.UP) or g.key:IsKeyPress(g.key.LEFT) then
                --up
                self.btncursor = self.btncursor - 1
                if self.btncursor < 0 then
                    self.btncursor = self.btncount - 1
                end
                self:moveMouse(self.btncursor)
                g:onChangedCursor()
            end
            if g.key:IsKeyDown(g.key.CANCEL) then
                local scp

                scp = self.noscp

                if scp then
                    local r, s = load(scp .. '()')
                    if r then
                        r()
                    end
                end
                msgbox:ShowWindow(0)
                g:onCanceledCursor()
                return g.uieHandlerBase.RefEnd
            end
            if g.key:IsKeyDown(g.key.MAIN) then
                local scp
                local idx = self.btncursor
                if idx == 0 then
                    scp = self.yesscp
                elseif idx == 1 then
                    scp = self.noscp
                elseif idx == 2 then
                    scp = self.etcscp
                end
                if scp then
                    local r, s = load('return (' .. scp .. ')')
                    if r then
                        pcall(r())
                    end
                end

                msgbox:ShowWindow(0)
                g:onDeterminedCursor()
                return g.uieHandlerBase.RefEnd
            end
            return g.uieHandlerBase.RefPass
        end
        return g.uieHandlerBase.RefEnd
    end,
    leave = function(self)
    end
}
g.uieHandlerFrameBase = {
    new = function(key, frame)
        local self = inherit(g.uieHandlerFrameBase, g.uieHandlerBase, key)
        self.frame = frame
        return self
    end,
    tick = function(self)
    end
}
g.uieHandlerDummy = {
    new = function(key, frame)
        local self = inherit(g.uieHandlerDummy, g.uieHandlerBase, key)
        self.frame = frame
        return self
    end,
    enter = function(self)
        g:enableHotKey()
    end,
    tick = function(self)
        return g.uieHandlerBase.RefPass
    end,
    leave = function(self)
        g:disableHotKey()
    end,
}
g.uieHandlerControlTracer = {
    FLAG_ENABLE_BUTTON = 0x00000001,
    FLAG_ENABLE_CHECKBOX = 0x00000002,
    FLAG_ENABLE_SLOT = 0x00000004,
    FLAG_ENABLE_SLOTSET = 0x00000008,
    FLAG_ENABLE_NUMUPDOWN = 0x00000010,
    FLAG_CHANGETAB_BYMENU = 0x00001000,
    new = function(key, frame, flags)
        local self = inherit(g.uieHandlerControlTracer, g.uieHandlerFrameBase, key, frame)
        self.ctrls = {}
        self.ctrlscursor = 0
        self.ctrlscount = 0
        self.framename = frame:GetName()
        self.flags = flags or g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON
        return self
    end,
    findButtonsRecurse = function(self, ctrl)
        for i = 0, ctrl:GetChildCount() - 1 do
            local cc = ctrl:GetChildByIndex(i)
            if cc:IsVisible() == 1 and cc:GetName():lower()~='colse' and cc:GetName():lower()~='close' then
                if
                    ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON) ~= 0 and (cc:GetClassString() == 'ui::CButton')) or
                        ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_CHECKBOX) ~= 0 and (cc:GetClassString() == 'ui::CCheckBox')) or
                        ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_SLOT) ~= 0 and (cc:GetClassString() == 'ui::CSlot')) or
                        ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_SLOTSET) ~= 0 and (cc:GetClassString() == 'ui::CSlotSet'))
                 then
                    AUTO_CAST(cc)
                    local x=cc:GetX()
                    local y=cc:GetY()
                    local w=cc:GetWidth()
                    local h=cc:GetHeight()
                    if cc:GetParent():GetClassString()~='ui::CFrame' then 
                        local p=cc:GetParent()
                        local px=cc:GetParent():GetX()
                        local py=cc:GetParent():GetY()
                        local pw=cc:GetParent():GetWidth()
                        local ph=cc:GetParent():GetHeight()
                        if cc:GetParent():GetParent() and  cc:GetParent():GetParent():GetClassString()~='ui::CFrame' then
                            local pp= cc:GetParent():GetParent()
                            --pw=math.min(pp:GetWidth()-px,math.min(pp:GetWidth()-x+px,pw))
                            --ph=math.min(pp:GetHeight()-py,math.min(pp:GetHeight()-y+px,ph))
                            
                        end
                        if (x+w>=0)and(y+h>=0)and(x<pw)and(y<ph) then
                            self.ctrls[#self.ctrls + 1] = cc
                            self.ctrlscount = self.ctrlscount + 1
                        end
                    else
                        
                        self.ctrls[#self.ctrls + 1] = cc
                        self.ctrlscount = self.ctrlscount + 1
                        
                    end
                   
                else
                    self:findButtonsRecurse(cc)
                end
            end
        end
    end,
    delayedenter = function(self)
        g.uieHandlerFrameBase.delayedenter(self)
        self:refresh()
    end,
    refresh = function(self)
        g.uieHandlerFrameBase.refresh(self)
        self.ctrls = {}
        self.ctrlscount = 0
        self.frame = ui.GetFrame(self.framename)
        self:findButtonsRecurse(self.frame)

        self.ctrlscursor = math.min(self.ctrlscount-1, self.ctrlscursor)
        table.sort(
            self.ctrls,
            function(a, b)
                if a:GetGlobalY() == b:GetGlobalY() then
                    return a:GetGlobalX() < b:GetGlobalX()
                end
                return a:GetGlobalY() < b:GetGlobalY()
            end
        )
        self:moveMouse(self.ctrlscursor)
    end,
    moveMouse = function(self, idx)
        if idx < self.ctrlscount then
            local ctrl = self.ctrls[idx + 1]

            self:moveMouseToControl(ctrl)
        end
    end,
    findAndChangeTab =function(self,ctrl)
        ctrl=ctrl or self.frame
        for i=0,ctrl:GetChildCount()-1 do
            local c=ctrl:GetChildByIndex(i)
            if c:IsVisible()==1 and c:IsEnable()==1 then
                if c:GetClassString()=='ui::CTabControl' then
                    AUTO_CAST(c)
                    local tabidx=c:GetSelectItemIndex()
                    tabidx=(tabidx + 1)%c:GetItemCount()
                    c:SelectTab(tabidx)
                    c:ChangeTab(tabidx)
                    return
                else
                    self:findAndChangeTab(c)
                end
            end
        end
    end,
    tick = function(self)
        if (self.ctrlscount > 0) then
            if g.key:IsKeyPress(g.key.DOWN) or g.key:IsKeyPress(g.key.RIGHT) then
                --down
                self.ctrlscursor = self.ctrlscursor + 1
                if self.ctrlscursor >= self.ctrlscount then
                    self.ctrlscursor = 0
                end
                self:moveMouse(self.ctrlscursor)
                g:onChangedCursor()
            end
            if g.key:IsKeyPress(g.key.UP) or g.key:IsKeyPress(g.key.LEFT) then
                --up
                self.ctrlscursor = self.ctrlscursor - 1
                if self.ctrlscursor < 0 then
                    self.ctrlscursor = self.ctrlscount - 1
                end
                self:moveMouse(self.ctrlscursor)
                g:onChangedCursor()
            end
            if g.key:IsKeyDown(g.key.CANCEL) then
                g:onCanceledCursor()
                self.frame:ShowWindow(0)
                return g.uieHandlerBase.RefEnd
            end
            if g.key:IsKeyDown(g.key.MENU) then
               if (self.flags & g.uieHandlerControlTracer.FLAG_CHANGETAB_BYMENU)~=0 then
                    self:findAndChangeTab()
                    g:onDeterminedCursor()
                    return g.uieHandlerBase.RefRefresh
               end

            end
            if g.key:IsKeyDown(g.key.MAIN) or g.key:IsKeyDown(g.key.SUB) then
                local scp
                local idx = self.ctrlscursor
                local ctrl = self.ctrls[idx + 1]

                if ctrl:GetClassString() == 'ui::CButton' or ctrl:GetClassString() == 'ui::CCheckBox' or ctrl:GetClassString() == 'ui::CSlot' then
                    local evt
                    if g.key:IsKeyDown(g.key.MAIN) then
                        evt = ui.LBUTTONUP
                        scp = ctrl:GetEventScript(evt)
                        if not scp then
                            evt = ui.LBUTTONDOWN
                            scp = ctrl:GetEventScript(evt)
                            if not scp then
                                evt = ui.LBUTTONPRESSED
                                scp = ctrl:GetEventScript(evt)
                                if not scp then
                                --none
                                end
                            end
                        end
                    elseif g.key:IsKeyDown(g.key.SUB) then
                        evt = ui.RBUTTONUP
                        scp = ctrl:GetEventScript(evt)
                        if not scp then
                            evt = ui.RBUTTONDOWN
                            scp = ctrl:GetEventScript(evt)
                            if not scp then
                                evt = ui.RBUTTONPRESSED
                                scp = ctrl:GetEventScript(evt)
                                if not scp then
                                --none
                                end
                            end
                        end
                    end

                    local scpnum = ctrl:GetEventScriptArgNumber(evt)
                    local scpstr = ctrl:GetEventScriptArgString(evt)

                    if scp and ctrl:IsEnable()==1 then
                        local r, s = load('return (' .. scp .. ')')
                        g:onDeterminedCursor()
                        if r then
                            --print(scp)
                            local parent = ctrl:GetParent()
                            local ctrlset

                            while parent do
                                if parent:GetClassString() == 'ui::CControlSet' then
                                    ctrlset = parent

                                    break
                                end
                                parent = parent:GetParent()
                            end

                            if ctrlset then
                                pcall(r(), ctrlset, ctrl, scpstr, scpnum)
                            else
                                pcall(r(), ctrl:GetTopParentFrame(), ctrl, scpstr, scpnum)
                            end
                        end
                    end
                end
                if ctrl:GetClassString() == 'ui::CCheckBox' then
                    if ctrl:IsChecked() == 1 then
                        ctrl:SetCheck(0)
                    else
                        ctrl:SetCheck(1)
                    end
                end
                if ctrl:GetClassString() == 'ui::CSlot' then
                    if g.key:IsKeyDown(g.key.MAIN) then
                        local parent = ctrl:GetParent()
                        if parent:GetClassString()=='ui::CSlotSet' then
                            AUTO_CAST(parent)
                            
                            if ctrl:IsSelected() == 1 then
                                ctrl:Select(0)
                            else
                                ctrl:Select(1)
                            end
                            parent:MakeSelectionList()
                            parent:Invalidate()
                        else
                            if ctrl:IsSelected() == 1 then
                                ctrl:Select(0)
                            else
                                ctrl:Select(1)
                            end
                        end
                    end
                end
                return g.uieHandlerBase.RefRefresh
            end
        end
        return g.uieHandlerBase.RefPass
    end
}

g.uieHandlerInventoryBase = {
    new = function(key, frame)
        local self = inherit(g.uieHandlerInventoryBase, g.uieHandlerFrameBase, key, frame)
        self.deepness = 0
        self.dircursor = 1
        self.dir = 1
        self.ctrlscount = 0
        self.ctrlscursor = 0
        self.movctrl = nil

        return self
    end,
    delayedenter = function(self)
        g.uieHandlerFrameBase.delayedenter(self)
        self:refresh()
    end,
    refresh = function(self)
        self.ctrls = {}

        self.ctrlscount = 0
        if self.dir == 0 then
            local eqtab = AUTO_CAST(self.frame:GetChildRecursively('equiptype_Tab'))
            if eqtab:GetSelectItemIndex() == 0 then
                self:findButtonsRecurse(self.frame:GetChildRecursively('gbox_Equipped'))
            else
                self:findButtonsRecurse(self.frame:GetChildRecursively('gbox_Dressed'))
            end
            table.sort(
                self.ctrls,
                function(a, b)
                    if a:GetGlobalY() == b:GetGlobalY() then
                        return a:GetGlobalX() < b:GetGlobalX()
                    end
                    return a:GetGlobalY() < b:GetGlobalY()
                end
            )
        else
            local treetab = AUTO_CAST(self.frame:GetChildRecursively('inventype_Tab'))
            local inven = AUTO_CAST(self.frame:GetChildRecursively('treeGbox_' .. g_invenTypeStrList[treetab:GetSelectItemIndex() + 1]))
            self:findButtonsRecurse(inven)
            table.sort(
                self.ctrls,
                function(a, b)
                    local pa = a:GetParent()
                    local pb = b:GetParent()

                    if (a:GetY() + pa:GetY()) == (b:GetY() + pb:GetY()) then
                        return (a:GetX() + pa:GetX()) < (b:GetX() + pb:GetX())
                    end
                    return (a:GetY() + pa:GetY()) < (b:GetY() + pb:GetY())
                end
            )
        end
        self.ctrlscursor = math.min(self.ctrlscount, self.ctrlscursor)

        self:moveMouse()
    end,
    findButtonsRecurse = function(self, ctrl)
        for i = 0, ctrl:GetChildCount() - 1 do
            local cc = ctrl:GetChildByIndex(i)
            if cc:IsVisible() == 1 then
                if (cc:GetClassString() == 'ui::CSlot') then
                    AUTO_CAST(cc)
                    if cc:GetIcon() then
                        self.ctrls[#self.ctrls + 1] = cc
                        self.ctrlscount = self.ctrlscount + 1
                    end
                else
                    self:findButtonsRecurse(cc)
                end
            end
        end
    end,
    moveMouse = function(self)
        local ctrl
        if self.deepness == 0 then
            if self.dircursor == 0 then
                ctrl = self.frame:GetChildRecursively('equip')
                self.frame:GetChildRecursively('shihouette'):SetBlink(60000, 2.0, 'FFAAAAAA', 1)
                self.frame:GetChildRecursively('inventoryitemGbox'):ReleaseBlink()
            else
                ctrl = self.frame:GetChildRecursively('inventoryitemGbox')
                self.frame:GetChildRecursively('inventoryitemGbox'):SetBlink(60000, 2.0, 'FFAAAAAA', 1)
                self.frame:GetChildRecursively('shihouette'):ReleaseBlink()
            end
        else
            self.frame:GetChildRecursively('shihouette'):ReleaseBlink()
            self.frame:GetChildRecursively('inventoryitemGbox'):ReleaseBlink()
            if self.dir == 0 then
                ctrl = self.ctrls[self.ctrlscursor + 1]
            else
                ctrl = self.ctrls[self.ctrlscursor + 1]
            end
        end
        if ctrl then
            --g_invenTypeStrList
            local treetab = AUTO_CAST(self.frame:GetChildRecursively('inventype_Tab'))
            local inven = AUTO_CAST(self.frame:GetChildRecursively('treeGbox_'.. g_invenTypeStrList[treetab:GetSelectItemIndex() + 1]))
            local parent = ctrl:GetParent()
            local y 
            if parent then
                
                y = ctrl:GetY() + parent:GetY()
            else

                y = ctrl:GetY()
            end
            local h = ctrl:GetHeight()
            local scrolly = inven:GetScrollCurPos()
            local scrollh = inven:GetHeight()
            scrolly = math.min(y, math.max(scrolly, y - scrollh + h + 10))
            inven:SetScrollPos(scrolly)
            inven:UpdateGroupBox()
            inven:ValidateControl()
            inven:UpdateDataByScroll()
            self.movctrl = ctrl
        end
    end,
    tick = function(self)
        if self.movctrl then
            self:moveMouseToControl(self.movctrl)
            self.movctrl = nil
        end
        if self.deepness == 0 then
            if g.key:IsKeyPress(g.key.DOWN) or g.key:IsKeyPress(g.key.RIGHT) then
                --down
                self.dircursor = 1
                self:moveMouse()
                g:onChangedCursor()
            end
            if g.key:IsKeyPress(g.key.UP) or g.key:IsKeyPress(g.key.LEFT) then
                --up
                self.dircursor = 0
                self:moveMouse()
                g:onChangedCursor()
            end
            if g.key:IsKeyDown(g.key.CANCEL) then
                g:onCanceledCursor()
                self.frame:ShowWindow(0)
                return g.uieHandlerBase.RefEnd
            end
            if g.key:IsKeyDown(g.key.MAIN) then
                g:onDeterminedCursor()

                self.deepness = 1
                self.dir = self.dircursor
                return g.uieHandlerBase.RefRefresh
            end
        else
            if self.dir == 0 then
                if g.key:IsKeyPress(g.key.DOWN) or g.key:IsKeyPress(g.key.RIGHT) then
                    --down
                    self.ctrlscursor = self.ctrlscursor + 1
                    if self.ctrlscursor >= self.ctrlscount then
                        self.ctrlscursor = 0
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.UP) or g.key:IsKeyPress(g.key.LEFT) then
                    --up
                    self.ctrlscursor = self.ctrlscursor - 1
                    if self.ctrlscursor < 0 then
                        self.ctrlscursor = self.ctrlscount - 1
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyDown(g.key.MENU) then
                    g:onDeterminedCursor()
                    local eqtab = AUTO_CAST(self.frame:GetChildRecursively('equiptype_Tab'))
                    local idx = (eqtab:GetSelectItemIndex() + 1) % eqtab:GetItemCount()
                    eqtab:SelectTab(idx)
                    eqtab:ChangeTab(idx)

                    return g.uieHandlerBase.RefRefresh
                end
                if g.key:IsKeyDown(g.key.SUB) then
                    local ctrl = self.ctrls[self.ctrlscursor + 1]

                    if ctrl:GetName() == 'RH' or ctrl:GetName() == 'LH' then
                        g:onDeterminedCursor()

                        WEAPONSWAP_HOTKEY_ENTERED()

                        return g.uieHandlerBase.RefPass
                    end
                end
                if g.key:IsKeyDown(g.key.MAIN) then
                    local scp
                    local idx = self.ctrlscursor
                    local ctrl = self.ctrls[idx + 1]

                    local evt
                    if g.key:IsKeyDown(g.key.MAIN) then
                        evt = ui.RBUTTONUP
                        scp = ctrl:GetEventScript(evt)
                        if not scp then
                            evt = ui.RBUTTONDOWN
                            scp = ctrl:GetEventScript(evt)
                            if not scp then
                                evt = ui.RBUTTONPRESSED
                                scp = ctrl:GetEventScript(evt)
                                if not scp then
                                --none
                                end
                            end
                        end
                    end

                    local scpnum = ctrl:GetEventScriptArgNumber(evt)
                    local scpstr = ctrl:GetEventScriptArgString(evt)

                    if scp and ctrl:IsEnable()==1 then
                        local r, s = load('return (' .. scp .. ')')
                        g:onDeterminedCursor()
                        if r then
                            --print(scp)
                            local parent = ctrl:GetParent()
                            local ctrlset

                            while parent do
                                if parent:GetClassString() == 'ui::CControlSet' then
                                    ctrlset = parent

                                    break
                                end
                                parent = parent:GetParent()
                            end

                            if ctrlset then
                                pcall(r(), ctrlset, ctrl, scpstr, scpnum)
                            else
                                pcall(r(), ctrl:GetTopParentFrame(), ctrl, scpstr, scpnum)
                            end
                        end
                    end
                    self:moveMouse()
                    return g.uieHandlerBase.RefRefresh
                end
            else
                if g.key:IsKeyPress(g.key.DOWN) or g.key:IsKeyPress(g.key.RIGHT) then
                    --down
                    self.ctrlscursor = self.ctrlscursor + 1
                    if self.ctrlscursor >= self.ctrlscount then
                        self.ctrlscursor = 0
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.UP) or g.key:IsKeyPress(g.key.LEFT) then
                    --up
                    self.ctrlscursor = self.ctrlscursor - 1
                    if self.ctrlscursor < 0 then
                        self.ctrlscursor = self.ctrlscount - 1
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.PAGEDOWN) then
                    --down
                    local ctrl = self.ctrls[self.ctrlscursor + 1]
                    local cnt = ctrl:GetParent():GetChildCount()
                    self.ctrlscursor = self.ctrlscursor + cnt
                    if self.ctrlscursor >= self.ctrlscount then
                        self.ctrlscursor = self.ctrlscount - 1
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.PAGEUP) then
                    --up
                    local ctrl = self.ctrls[self.ctrlscursor + 1]
                    local cnt = ctrl:GetParent():GetChildCount()
                    self.ctrlscursor = self.ctrlscursor - cnt
                    if self.ctrlscursor < 0 then
                        self.ctrlscursor = 0
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyDown(g.key.MAIN) or g.key:IsKeyDown(g.key.SUB) then
                    local scp
                    local idx = self.ctrlscursor
                    local ctrl = self.ctrls[idx + 1]

                    local evt
                    if g.key:IsKeyDown(g.key.SUB) then
                        evt = ui.LBUTTONUP
                        scp = ctrl:GetEventScript(evt)
                        if not scp then
                            evt = ui.LBUTTONDOWN
                            scp = ctrl:GetEventScript(evt)
                            if not scp then
                                evt = ui.LBUTTONPRESSED
                                scp = ctrl:GetEventScript(evt)
                                if not scp then
                                --none
                                end
                            end
                        end
                    elseif g.key:IsKeyDown(g.key.MAIN) then
                        evt = ui.RBUTTONUP
                        scp = ctrl:GetEventScript(evt)
                        if not scp then
                            evt = ui.RBUTTONDOWN
                            scp = ctrl:GetEventScript(evt)
                            if not scp then
                                evt = ui.RBUTTONPRESSED
                                scp = ctrl:GetEventScript(evt)
                                if not scp then
                                --none
                                end
                            end
                        end
                    end

                    local scpnum = ctrl:GetEventScriptArgNumber(evt)
                    local scpstr = ctrl:GetEventScriptArgString(evt)

                    if scp then
                        local r, s = load('return (' .. scp .. ')')
                        g:onDeterminedCursor()
                        if r then
                            --print(scp)
                            local parent = ctrl:GetParent()
                            local ctrlset

                            while parent do
                                if parent:GetClassString() == 'ui::CControlSet' then
                                    ctrlset = parent

                                    break
                                end
                                parent = parent:GetParent()
                            end

                            if ctrlset then
                                pcall(r(), ctrlset, ctrl, scpstr, scpnum)
                            else
                                pcall(r(), ctrl:GetTopParentFrame(), ctrl, scpstr, scpnum)
                            end
                        end
                    end
                    self:moveMouse()
                    return g.uieHandlerBase.RefRefresh
                end
                if g.key:IsKeyPress(g.key.MENU) then
                    g:onDeterminedCursor()
                    local eqtab = AUTO_CAST(self.frame:GetChildRecursively('inventype_Tab'))
                    local idx = (eqtab:GetSelectItemIndex() + 1) % eqtab:GetItemCount()
                    eqtab:SelectTab(idx)
                    eqtab:ChangeTab(idx)

                    return g.uieHandlerBase.RefRefresh
                end
            end
            if g.key:IsKeyDown(g.key.CANCEL) then
                g:onCanceledCursor()
                self.deepness = 0
                return g.uieHandlerBase.RefRefresh
            end
        end

        return g.uieHandlerBase.RefPass
    end
}
UIMODEEXPERT = g
