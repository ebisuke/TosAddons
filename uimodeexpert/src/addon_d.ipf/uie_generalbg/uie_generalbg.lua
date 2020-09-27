--uie_generalbg

local acutil = require('acutil')
local framename = 'uie_generalbg'
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

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT
g.gbg = g.gbg or {}

g.gbg.initialize = function()
    print('INITD')
    local frame = ui.GetFrame(framename)
    local gbox = frame:GetChild('gboxbody')
    gbox:RemoveAllChild()
    local tab = frame:GetChild('tabmain')
    AUTO_CAST(tab)
    tab:ClearItemAll()

    for _, v in ipairs(g.gbg._componentInstances) do
        v:release()
    end

    g.gbg._componentInstances = {}
end

g.gbg.release = function()
    print('RELEASED')
    local frame = ui.GetFrame(framename)
    local gbox = frame:GetChild('gboxbody')
    gbox:RemoveAllChild()
    local tab = frame:GetChild('tabmain')
    AUTO_CAST(tab)
    tab:ClearItemAll()

    for _, v in ipairs(g.gbg._componentInstances) do
        v:release()
    end

    g.gbg._componentInstances = {}
    
end
g.gbg._activeInstance=nil

g.gbg._componentInstances = {}


g.gbg.getComponentInstanceByName = function(name)
    return g.gbg._componentInstances[name]
end
g.gbg.SetTitle = function(title)
    local frame = ui.GetFrame(framename)
    local text = frame:GetChild('title_text')
    text:SetTextByKey('value', title)
end
g.gbg.showFrame = function()
    ui.GetFrame('uie_generalbg'):ShowWindow(1)
end
g.gbg.hideFrame = function()
    ui.GetFrame('uie_generalbg'):ShowWindow(0)
end
g.gbg.setActiveInstance = function(gbg)
    g.gbg._activeInstance = gbg
end
g.gbg.uiegbgBase = {
    new = function(frame, name, caption)
        local self = inherit(g.gbg.uiegbgBase)
        self.frame = frame
        self.name = name
        self.caption = caption
        self.components = {}
        self.parentgbg = nil
        self._attachedHandler=nil
        self._isReleased = false
        return self
    end,
    initialize = function(self)
        local framegbox = self.frame:GetChild('gboxbody')

        local gbox = framegbox:CreateOrGetControl('groupbox', 'gbox' .. self.name, 0, 0, framegbox:GetWidth(), framegbox:GetHeight())
        self.gbox = gbox
        AUTO_CAST(gbox)

        if self.caption and not self.parentgbg then
            g.gbg.SetTitle(self.caption)
        end
        self:initializeImpl(gbox)
        local handler = self:defaultHandler(self.name,self.frame,self)
        if handler and not self.parentgbg then
           
            self:attachHandler(handler)
        end
        self:postInitializeImpl(gbox)
        return gbox
    end,
    initializeImpl = function(self, gbox)
        -- override me
    end,
    postInitializeImpl = function(self, gbox)
        -- override me
    end,

    release = function(self)
        self:releaseImpl()
        self:detachHandler()
        self._isReleased = true
    end,
    releaseImpl = function(self)
        --override me
    end,
    addComponent = function(self, component)
        self.components[component.name] = component
    end,
    getComponent = function(self, name)
        return self.components[name]
    end,
    hookmsg = function(self, frame, msg, argStr, argNum)
        self:hookmsgImpl(frame, msg, argStr, argNum)
        -- for _, v in ipairs(self.components) do
        --     v:hookmsg(frame, msg, argStr, argNum)
        -- end
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
        --override me
    end,
    close = function(self)
        print('UA'..self.frame:GetName())
       
        self:release()
        self.frame:ShowWindow(0)
    end,
    defaultHandler = function(self,key,frame)
        return self:defaultHandlerImpl(key,frame)
    end,
    defaultHandlerImpl = function(self,key,frame)
        --override me
        return g.uieHandlergbgBase.new(key,frame,self)
    end,
    attachDefaultHandler=function(self)
        local handler=self:defaultHandler(self.frame:GetName(),self.frame)
        
        self:attachHandler(handler)
   
    end,
    attachHandler = function(self, instance)
        if self._attachedHandler then
           self:detachHandler()
        end
        g.attachHandler(instance)
        
        self._attachedHandler = instance
    end,
    detachHandler = function(self)
 
        if  self._attachedHandler  then
            g.detachHandler(self._attachedHandler)
            self._attachedHandler = nil
        end
    
    end,
    isVisible = function(self)
        return self.gbox:IsVisible() == 1
    end,
    show = function(self)
        self:attachDefaultHandler()
        self.gbox:ShowWindow(1)
        self:showImpl()
    end,
    showImpl=function(self)
        --override me
    end,
    hide = function(self)
        if self._attachedHandler then
            self:detachHandler()
        end
        self.gbox:ShowWindow(0)
        
        self:hideImpl()
    end,
    hideImpl = function(self)
        --override me
    end,

}
g.gbg.uiegbgGroupBase = {
    new = function(frame, name, caption,initindex)
        local self = inherit(g.gbg.uiegbgGroupBase, g.gbg.uiegbgBase, frame, name, caption)
        self._children = {}
        self._initindex=initindex or 1
        
        return self
    end,
    initialize = function(self)
        if self.caption and not self.parentgbg then
            g.gbg.SetTitle(self.caption)
        end
        self:initializeImpl(nil)
        for k, v in ipairs(self._children) do
            v:initialize()
            
            v.index=k
 
        end
        local frame = ui.GetFrame(framename)
        local tab = frame:GetChild('tabmain')
        AUTO_CAST(tab)
        tab:ClearItemAll()
        for k,v in ipairs(self._children) do
            tab:AddItem('{ol}{s32}'..v.caption)
        end

        
        for k, v in ipairs(self._children) do
           
            if self._initindex==k then
                v:show()
            else
                v:hide()
            end
        end
        tab:SelectTab(self._initindex-1)
        tab:ChangeTab(self._initindex-1)

      
       
        self:postInitializeImpl()
        self:attachDefaultHandler()
    end,

    addChild = function(self, child)
        self._children[#self._children + 1] = child
        child.parentgbg = self
    end,
    showChild=function(self,index)
        for k, v in ipairs(self._children) do
            if k==index then
                v:show()
                v:attachDefaultHandler()
            else
                v:hide()
                v:detachHandler()
            end
        end
    end,
}

g.gbg.uiegbgComponentBase = {
    new = function(parentgbg, name)
        local self = inherit(g.gbg.uiegbgComponentBase ,g.gbg.uiegbgBase,parentgbg.frame,name,nil)
        self.parentgbg = parentgbg
        self.parent=parentgbg.gbox
        self.name = name
        return self
    end,
    initialize = function(self, x, y, w, h)
        if x == nil then
            x = 0
            y = 0
            w = self.parent:GetWidth()
            h = self.parent:GetHeight()
        end
        local gbox = self.parent:CreateOrGetControl('groupbox', 'gbox' .. self.name, x, y, w, h)
        AUTO_CAST(gbox)
        self.gbox = gbox
        gbox:SetUserValue('gbg_name',self.name)
        gbox:SetUserValue('gbg_intrusive',0)
        self:initializeImpl(gbox)
        print('COMP'..self.name)
        g.gbg._componentInstances[self.name] = self

        
        return gbox
    end,
    release=function(self)
        g.gbg.uiegbgBase.release(self)
        print('REL')
        g.gbg._componentInstances[self.name] = nil
    end,
    hookmsg = function(self, frame, msg, argStr, argNum)
        self:hookmsgImpl(frame,msg,argStr,argNum)
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
        --override me
    end,

}

g.uieHandlergbgBase = {
    new = function(key, frame,gbg)
        local self = inherit(g.uieHandlergbgBase, g.uieHandlerFrameBase, key,frame)
        self.gbg=gbg
       
        return self
    end,
    leave=function(self)
        g.uieHandlerFrameBase.leave(self)
        --if not self.gbg.parent then
        --    self.gbg:close()
        --end
        --self.gbg:close()
    end,
    tick = function(self)
        --if not self._plzimplement then
        --    ERROUT('please implement uieHandlergbgBase.tick')
        --    self._plzimplement =true
        --end
        if self.parentgbg then
            --pass

            return g.uieHandlerBase.RefRefresh
        end
        return self:gbgTick()
    end,
    gbgTick = function(self)
        if not self._plzimplement then
           ERROUT('please implement uieHandlergbgBase.gbgTick')
           self._plzimplement =true
        end
        return g.uieHandlerBase.RefPass
    end,
}
g.uieHandlergbgComponentTracer = {
    FLAG_ENABLE_BUTTON = 0x00000001,
    FLAG_ENABLE_CHECKBOX = 0x00000002,
    FLAG_ENABLE_SLOT = 0x00000004,
    FLAG_ENABLE_SLOTSET = 0x00000008,
    FLAG_ENABLE_NUMUPDOWN = 0x00000010,
    FLAG_CHANGETAB_BYMENU = 0x00001000,
    new = function(key, frame,gbg,flags)
        local self = inherit(g.uieHandlergbgComponentTracer, g.uieHandlergbgBase, key,frame,gbg)

        self.ctrls = {}
        self.ctrlscursor = 0
        self.ctrlscount = 0
        self.flags = flags or g.uieHandlergbgComponentTracer.FLAG_ENABLE_BUTTON
        return self
    end,
    enter=function(self)
        g.uieHandlergbgBase.enter(self)
    end,
    delayedenter = function(self)
        g.uieHandlergbgBase.delayedenter(self)
        self:refresh()
    end,
    findButtonsRecurse = function(self, ctrl)
        for i = 0, ctrl:GetChildCount() - 1 do
            local cc = ctrl:GetChildByIndex(i)
            local gbgname=ctrl:GetUserValue('gbg_name')
            local gbgintrusive=ctrl:GetUserIValue('gbg_intrusive')
            

            if cc:IsVisible() == 1 and cc:GetName():lower()~='colse' and cc:GetName():lower()~='close' then
                if
                    ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_BUTTON) ~= 0 and (cc:GetClassString() == 'ui::CButton')) or
                        ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_CHECKBOX) ~= 0 and (cc:GetClassString() == 'ui::CCheckBox')) or
                        ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_SLOT) ~= 0 and (cc:GetClassString() == 'ui::CSlot')) or
                        ((self.flags & g.uieHandlerControlTracer.FLAG_ENABLE_SLOTSET) ~= 0 and (cc:GetClassString() == 'ui::CSlotSet'))
                        --or (g.util.isNilOrNoneOrWhitespace(gbgname) and gbgintrusive==0)
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
                            --pw=math.min(pp:GetWidth()-px,math.min((pp:GetWidth()+w)-(x+px),pw))
                            --ph=math.min(pp:GetHeight()-py,math.min((pp:GetHeight()+h)-(y+px),ph))
                            
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

    gbgTick = function(self)
        
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
                if ctrl:GetClassString() == 'ui::CGroupBox' then
                    local gbgname=ctrl:GetUserValue('gbg_name')
                    local gbgintrusive=ctrl:GetUserIValue('gbg_intrusive')
                    if gbgname~='' and gbgintrusive==0 then
                        local gbg=g.gbg.getComponentInstanceByName(gbgname)
                        if gbg then
                            gbg:attachDefaultHandler()
                        end
                    end
                end
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
    end,
    refresh = function(self)
        g.uieHandlergbgBase.refresh(self)
        self.ctrls = {}
        self.ctrlscount = 0

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

}
UIMODEEXPERT = g

--マップ読み込み時処理（1度だけ）
function UIE_GENERALBG_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(framename)
            --frame:ShowWindow(0)
            addon:RegisterMsg('GAME_START', 'UIE_GENERALBG_GAME_START')
            addon:RegisterMsg('INV_ITEM_ADD', 'UIE_GENERALBG_HOOK')
            addon:RegisterMsg('INV_ITEM_CHANGE_COUNT', 'UIE_GENERALBG_HOOK')
            addon:RegisterMsg('INV_ITEM_REMOVE', 'UIE_GENERALBG_HOOK')
            addon:RegisterMsg('INV_ITEM_LIST_GET', 'UIE_GENERALBG_HOOK')
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "UIE_GENERALBG_HOOK");
            addon:RegisterMsg("CABINET_ITEM_LIST", "UIE_GENERALBG_HOOK");
            
            addon:RegisterOpenOnlyMsg("ACCOUNT_WAREHOUSE_VIS", "UIE_GENERALBG_HOOK");
            UIE_GENERALBG_INIT(frame)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function UIE_GENERALBG_ON_OPEN(frame)
    EBI_try_catch {
        try = function()
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GENERALBG_HOOK(frame, msg, argStr, argNum)
       
    for _, v in pairs(g.gbg._componentInstances) do

        v:hookmsg(frame, msg, argStr, argNum)
    end
end
function UIE_GENERALBG_INIT()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(framename)
            frame:SetLayerLevel(95)
            local gbox = frame:CreateOrGetControl('groupbox', 'gboxbody', 0, 0, 1920, 1080)
            AUTO_CAST(gbox)
            gbox:Resize(frame:GetWidth(), frame:GetHeight() - 200)
            gbox:EnableScrollBar(0)
            gbox:SetOffset(0, 200)
            local tab = frame:CreateOrGetControl('tab', 'tabmain', 0, 100, 1920, 60)
            AUTO_CAST(tab)
            tab:Resize(frame:GetWidth() - 100, 80)

            tab:SetOffset(60, 150)
            --tab:
            g.gbg.initialize()

            tab:SetSkinName('tab')
            tab:SetEventScript(ui.LBUTTONUP, 'UIE_GENERALBG_CHANGE_TAB')
            --tab:SetItemsFixWidth(150)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GENERALBG_CHANGE_TAB()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(framename)
            local tab = frame:GetChild('tabmain')
            AUTO_CAST(tab)
            local idx = tab:GetSelectItemIndex() + 1
            for k, v in ipairs(g.gbg._activeInstance._children) do
                if k ~= idx then
                    if v:isVisible() then
                        v:hide()
                    end
                else
                    v:show()
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GENERALBG_TEST()
    EBI_try_catch {
        try = function()
            UIE_GENERALBG_INIT()
            local frame = ui.GetFrame(framename)
            local aa = g.gbg.uiegbgShop.new(frame, 'shop')
            aa:initialize()
            g.gbg.attach(aa)
            g.gbg.showFrame()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GENERALBG_ON_OPEN(frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(framename)
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GENERALBG_OPEN()
    local frame = ui.GetFrame(framename)
    frame:ShowWindow(1)
    UIE_GENERALBG_INIT()
end
function UIE_GENERALBG_CLOSE(frame)
    frame:ShowWindow(0)
end

function UIE_GENERALBG_ON_CLOSE(frame)
    g.gbg.release()

end
