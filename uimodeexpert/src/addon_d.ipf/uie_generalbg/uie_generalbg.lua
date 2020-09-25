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
g.gbg=g.gbg or {}
g.gbg.initialize=function()
    local frame = ui.GetFrame(framename)
    local gbox=frame:GetChild('gboxbody')
    gbox:RemoveAllChild()
    local tab=frame:GetChild('tabmain')
    AUTO_CAST(tab)
    tab:ClearItemAll()
    for _,v in ipairs(g.gbg._attached) do
        v:release()
    end
    for _,v in ipairs(g.gbg._componentInstances) do
        v:release()
    end
    g.gbg._attached={}
end
g.gbg.lib={
    ['inventory']=g.gbg.uiegbgInventory,
}
g.gbg._attached={}
g.gbg._componentInstances={}
g.gbg.attach=function(tab)
    g.gbg._attached[#g.gbg._attached+1] = tab
    local frame = ui.GetFrame(framename)
    local tabctrl=frame:GetChild('tabmain')
    AUTO_CAST(tabctrl)
    tabctrl:AddItem('{ol}'..tab.caption)
end
g.gbg.getComponentInstanceByName=function(name)
    return g.gbg._componentInstances[name]
end
g.gbg.SetTitle=function(title)
    local frame = ui.GetFrame(framename)
    local text=frame:GetChild('title_text')
    text:SetTextByKey('value',title)
end

g.gbg.uiegbgBase={
    new=function(frame,name,caption)
        local self=inherit(g.gbg.uiegbgBase)
        self.frame=frame
        self.name=name
        self.caption=caption
        self.components={}
        return self
    end,
    initialize=function(self)
        -- override me
        local framegbox=self.frame:GetChild('gboxbody')
        local gbox=framegbox:CreateOrGetControl("groupbox",'gbox'..self.name,0,0,framegbox:GetWidth(),framegbox:GetHeight())
        self.gbox=gbox
        AUTO_CAST(gbox)
        if self.caption then
            g.gbg.SetTitle(self.caption)
        end
        self:initializeImpl(gbox)
     
        return gbox
    end,
    initializeImpl=function(self,gbox)
        -- override me
    end,
    release=function(self)
        self:releaseImpl()
    end,
    releaseImpl=function(self)
        --override me
    end,
    addComponent=function(self,component)
        self.components[component.name]=component
    end,
    hookmsg=function(self,frame, msg, argStr, argNum)
        self:hookmsgImpl(frame,msg,argStr,argNum)
        for _,v in ipairs(self.components) do   
            v:hookmsg(frame, msg, argStr, argNum)
        end
    end,
    hookmsgImpl=function(self,frame, msg, argStr, argNum)
        --override me
    end,
}
g.gbg.uiegbgComponentBase={
    new=function(tab,parent,name)
        local self=inherit(g.gbg.uiegbgBase)
        self.tab=tab
        self.parent=parent
        self.name=name
        return self
    end,
    initialize=function(self,x,y,w,h)
        if x==nil then
            x=0
            y=0
            w=self.parent:GetWidth()
            h=self.parent:GetHeight()
        end
        local gbox=self.parent:CreateOrGetControl("groupbox",'gbox'..self.name,x,y,w,h)
        AUTO_CAST(gbox)
        self:initializeImpl(gbox)
        g.gbg._componentInstances[self.name] = self
        return gbox
    end,
    initializeImpl=function(self,gbox)
        -- override me
        self:hookmsgImpl(frame,msg,argStr,argNum)
    end,
    
    release=function(self)
        self:releaseImpl()
    end,
    releaseImpl=function(self)
        --override me
    end,
    hookmsg=function(self,frame, msg, argStr, argNum)
      
    end,
    hookmsgImpl=function(self,frame, msg, argStr, argNum)
        --override me
    end,
}
local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end


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
function UIE_GENERALBG_HOOK(frame, msg, argStr, argNum)
    for _,v in ipairs(g.gbg._attached) do
        v:hookmsg(frame,msg,argStr,argNum)
    end
end
function UIE_GENERALBG_INIT()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(framename)
            local gbox=frame:CreateOrGetControl('groupbox','gboxbody',0,0,1920,1080)
            AUTO_CAST(gbox)
            gbox:Resize(frame:GetWidth(),frame:GetHeight()-200);
            gbox:EnableScrollBar(0)
            gbox:SetOffset(0,200)
            local tab=frame:CreateOrGetControl('tab','tabmain',0,100,1920,50)
            AUTO_CAST(tab)
            tab:Resize(frame:GetWidth()-100,50);
            
            tab:SetOffset(60,150)
            --tab:
            g.gbg.initialize()

    
            tab:SetSkinName('tab')
            --tab:SetItemsFixWidth(150)


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
             local aa=g.gbg.uiegbgShop.new(frame,'shop')
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
   local  frame = ui.GetFrame(framename)
   frame:ShowWindow(1) 
   UIE_GENERALBG_INIT()
end
function UIE_GENERALBG_ON_CLOSE(frame)
    frame:ShowWindow(0)
end