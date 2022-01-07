--metaaddon_node
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.cls = g.cls or {}
g.cls.MANodeBase = function(name)
    local self = {
        _className="MANodeBase",
        _name = name,
        _selectable = false,
        _pos={x=0,y=0},
        _temporary=false,
    
        getPos = function(self)
            return self._pos
        end,
        setPos = function(self, x, y)
            self._pos.x = x
            self._pos.y = y
        end,
        hitTestBox=function(self, left,top,right,bottom)
            return left<=self:getPos().x and right >=self:getPos().x and top<=self:getPos().y and bottom>=self:getPos().y
        end,
        render = function(self, addonlet, gbox, offset, zoom)
        end,
        createEditor = function(self, addonlet,frame, gbox)
            return false
        end,
        confirmEditor = function(self, addonlet,frame, gbox)
            return false
        end,
        calculateBoundingBox=function(self)
            return {left=self._pos.x,top=self._pos.y,right=self._pos.x,bottom=self._pos.y}
        end,
        isSelected=function (self,addonlet)
            return addonlet:isSelected(self)
        end,
        isTemporary=function (self)
            return self._temporary
        end,
        assignImpl=function (self,obj)
            self._supers["MASerializable"].assignImpl(self,obj)
            self._name = obj._name
            self._pos = obj._pos
            self._payload = obj._payload
            self._pos=obj._pos
            self._temporary=obj._temporary
        end,
        compile=function(self,addonlet)
            return ""
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MASerializable())

    return obj
end

g.cls.MANode = function(name, pos, size)
    local self = {
        _className="MANode",
        _selectable = true,
        _inlets = {},
        _outlets = {},
        _pos = pos or {x=0,y=0},
        _size =  size or {w=0,h=0},
        _parent = nil,
        _children={},
        addInlet=function(self,inlet)
            self._inlets[#self._inlets+1] = inlet
            inlet.ownerNode=self
            self:addChild(inlet)
        end,
        addOutlet=function(self,outlet)
            self._outlets[#self._outlets+1] = outlet
            outlet.ownerNode=self
            self:addChild(outlet)
        end,
        removeInlet=function(self,inlet)
            for i,v in ipairs(self._inlets) do
                if v:getID()==inlet:getID() then
                    table.remove(self._inlets,i)
                    break
                end
            end
            self:removeChild(inlet)
            inlet:release()
        end,
        removeOutlet=function(self,outlet)
            for i,v in ipairs(self._outlets) do
                if v:getID()==outlet:getID() then
                    table.remove(self._outlets,i)
                    break
                end
            end
            self:removeChild(outlet)
            outlet:release()
        end,
        addChild=function(self,node)
            self._children[#self._children+1]=node
        end,
        getChildren = function(self)
            return self._children
        end,
        getParent = function(self)
            return self._parent
        end,
        getInlets=function(self)
            return self._inlets
        end,
        getOutlets=function(self)
            return self._outlets
        end,
        removeChild = function(self, child)
            for i, v in ipairs(self._children) do
                if v:getID() == child:getID() then
                    table.remove(self._children, i)
                    break
                end
            end
        end,
        setParent = function(self, parent)
            if parent and parent:getChildren()[self:getID()] then
                parent:removeChild(self)
            end
            self._parent = parent
        end,
        getName = function(self)
            return self._name
        end,
        getRect = function(self)
            return {
                x = self._pos.x,
                y = self._pos.y,
                w = self._size.w,
                h = self._size.h
            }
        end,
        setPos=function(self,x,y)
            local diffx=x-self._pos.x
            local diffy=y-self._pos.y



            self._pos.x=x
            self._pos.y=y
            for i,v in ipairs(self._children) do
                v:setPos(v:getPos().x+diffx,v:getPos().y+diffy)
            end
            self:notifyMoveToGates()
        end,
        setRect = function(self, x, y, w, h)
            local diffx=x-self._pos.x
            local diffy=y-self._pos.y



            self._pos.x=x
            self._pos.y=y
            for i,v in ipairs(self._children) do
                v:setPos(v:getPos().x+diffx,v:getPos().y+diffy)
            end
            self._size.w = w
            self._size.h = h
            self:notifyMoveToGates()
        end,
        hitTestBox=function(self, left,top,right,bottom)
            local rect = self:getRect()
        
            return right>=rect.x and left<=rect.x+rect.w and bottom>=rect.y and top<=rect.y+rect.h
        end,
        calculateBoundingBox=function(self)
           return {left=self._pos.x,top=self._pos.y,right=self._pos.x+self._size.w,bottom=self._pos.y+self._size.h}
        end,
        render = function(self, addonlet, gbox, offset, zoom)

            
            local g =
                gbox:CreateOrGetControl(
                "groupbox",
                "gbox_" .. self._id,
                self._pos.x * zoom + offset.x,
                self._pos.y * zoom + offset.y,
                self._size.w * zoom,
                self._size.h * zoom
            )
            AUTO_CAST(g)
            g:SetSkinName("bg2")
            g:EnableHitTest(0)
            if self:isSelected(addonlet) then
                g:SetColorTone("FF0000FF")
            end
            local p =
                g:CreateOrGetControl(
                "picture",
                "icon",
                0,0,
                self._size.w * zoom,
                self._size.h * zoom
            )
            AUTO_CAST(p)
            p:SetEnableStretch(1)
            p:EnableHitTest(0)
            local txt =
                g:CreateOrGetControl(
                "richtext",
                "text",
                0,0,
                self._size.w * zoom,
                24
            )
            AUTO_CAST(txt)
            txt:EnableHitTest(0)
            txt:SetText("{ol}" .. self._name)
            for i, v in ipairs(self:getInlets()) do
                v:render(addonlet,gbox, offset, zoom)
            end
            for i, v in ipairs(self:getOutlets()) do
                v:render(addonlet, gbox, offset, zoom)
            end

            return g
        end,
        sortGate=function(self,gate)
            for i,v in ipairs(self:getInlets()) do
                v:setPos(self:getRect().x-8,                 self:getRect().y+self:getRect().h*(i)/(#self:getInlets()+1))
            end
            for i,v in ipairs(self:getOutlets()) do
                v:setPos(self:getRect().x+self:getRect().w+8,self:getRect().y+self:getRect().h*(i)/(#self:getOutlets()+1))
            end
        end,
        notifyMoveToGates=function(self)
            for i,v in ipairs(self:getInlets()) do
                v:onMove()
            end
            for i,v in ipairs(self:getOutlets()) do
                v:onMove()
            end
        end,
        lazyInitImpl=function(self)
            self:sortGate()
        end,
        assignImpl=function (self,obj)
          
            self._supers["MANodeBase"].assignImpl(self,obj)
            self._name = obj._name
            self._pos = obj._pos
            self._size = obj._size
            self._parent = obj._parent
           
            for i,v in ipairs(obj._inlets) do
                self:addInlet(v:clone())
            end
            for i,v in ipairs(obj._outlets) do
                self:addOutlet(v:clone())
            end
        end,
        releaseImpl=function(self)
            for i,v in ipairs(self:getInlets()) do
                v:release()
            end
            for i,v in ipairs(self:getOutlets()) do
                v:release()
            end
            self._inlets={}
            self._outlets={}
            self._children={}
            self._parent=nil
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MANodeBase(name))

    return obj
end

