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
    local frame = ui.GetFrame(framename)
    local gbox = frame:GetChild('gboxbody')
    gbox:RemoveAllChild()
    local tab = frame:GetChild('tabmain')
    AUTO_CAST(tab)
    tab:ClearItemAll()
    for _, v in ipairs(g.gbg._attached) do
        v:release()
    end
    for _, v in ipairs(g.gbg._componentInstances) do
        v:release()
    end
    g.gbg._attached = {}
end
g.gbg._activeInstance=nil
g.gbg._attached = {}
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
        local handler = self:defaultHandler(self.frame:GetName(),self.frame,self)
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
        if self._attachedHandler then
            g.detachHandler(self._attachedHandler)
        end
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
        for _, v in ipairs(self.components) do
            v:hookmsg(frame, msg, argStr, argNum)
        end
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
        --override me
    end,
    close = function(self)
        self.frame:ShowWindow(0)
    end,
    defaultHandler = function(self,key,frame)
        return self:defaultHandlerImpl(key,frame)
    end,
    defaultHandlerImpl = function(self,key,frame)
        --override me
        return g.uieHandlergbgBase.new(key,frame,self)
    end,
    attachHandler = function(self, instance)
        g.attachHandler(instance)
        self._attachedHandler = instance
    end,
    detachHandler = function(self, instance)
        g.detachHandler(instance)
        self._attachedHandler = nil
    end,
    isVisible = function(self)
        return self.gbox:IsVisible() == 1
    end,
    show = function(self)
        self:attachHandler(self:defaultHandler())
        self.gbox:ShowWindow(1)
        self:showImpl()
    end,
    showImpl=function(self)
        --override me
    end,
    hide = function(self)
        if self._attachedHandler then
            self:detachHandler(self._attachedHandler)
        end
        self.gbox:ShowWindow(0)
        
        self:hideImpl()
    end,
    hideImpl = function(self)
        --override me
    end
}
g.gbg.uiegbgGroupBase = {
    new = function(frame, name, caption,initindex)
        local self = inherit(g.gbg.uiegbgGroupBase, g.gbg.uiegbgBase, frame, name, caption)
        self._children = {}
        self._initindex=initindex
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
    
        for k,v in ipairs(self._children) do
            tab:AddItem(v.caption)
        end

        
        --local handler = self:defaultHandler()
        --if handler then
        --    self:attachHandler(handler)
        --end
        for k, v in ipairs(self._children) do
            print(''..self._initindex)
            if self._initindex==k then
                v:show()
            else
                v:hide()
            end
        end
        tab:SelectTab(self._initindex-1)
        tab:ChangeTab(self._initindex-1)
        self:postInitializeImpl(nil)
    end,
    release = function(self)
        self:releaseImpl()
    
        self._isReleased = true
    end,
    addChild = function(self, child)
        self._children[#self._children + 1] = child
        child.parentgbg = self
    end,
    showChild=function(self,index)
        for k, v in ipairs(self._children) do
            if k==index then
                v:show()
            else
                v:hide()
            end
        end
    end,
}

g.gbg.uiegbgComponentBase = {
    new = function(tab, parent, name)
        local self = inherit(g.gbg.uiegbgBase)
        self.tab = tab
        self.parent = parent
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
        self:initializeImpl(gbox)
        g.gbg._componentInstances[self.name] = self

        
        return gbox
    end,
    initializeImpl = function(self, gbox)
        -- override me
        --self:hookmsgImpl(frame, msg, argStr, argNum)
    end,
    release = function(self)
        self:releaseImpl()
        if self._attachedHandler then
            g.detachHandler(self._attachedHandler)
        end
        self._isReleased = true
    end,
    releaseImpl = function(self)
        --override me
    end,
    hookmsg = function(self, frame, msg, argStr, argNum)
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
        --override me
    end,
    attachHandler = function(self, instance)
        g.attachHandler(instance)
        self._attachedHandler = instance
    end,
    detachHandler = function(self, instance)
        g.detachHandler(instance)
        self._attachedHandler = nil
    end
}

g.uieHandlergbgBase = {
    new = function(key, frame,gbg)
        local self = inherit(g.uieHandlergbgBase, g.uieHandlerFrameBase, key,frame)
        self.gbg=gbg
        return self
    end,
    leave=function(self)
        --self.gbg:close()
    end,
    tick = function(self)
    end
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
    for _, v in ipairs(g.gbg._attached) do
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
            local tab = frame:CreateOrGetControl('tab', 'tabmain', 0, 100, 1920, 50)
            AUTO_CAST(tab)
            tab:Resize(frame:GetWidth() - 100, 50)

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
            frame:ShowWindow(1)
            local aa = g.gbg.uiegbgShop.new(frame, 'shop')
            aa:initialize()
            g.gbg.attach(aa)
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
function UIE_GENERALBG_ON_CLOSE(frame)
    frame:ShowWindow(0)
end
