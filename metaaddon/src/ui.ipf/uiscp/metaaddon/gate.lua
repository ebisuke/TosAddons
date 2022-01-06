--metaaddon_gate
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
g.cls = g.cls or {}
g.cls.MAGate=function(gateName,title,ownerNode)
	local self={

        title="",
        _streams={},
        ownerNode=ownerNode,
		_className="MAGate",
        initImpl=function(self)
           
            self.title=title
        end,
        compile=function(self)
            return ""
        end,
        setPos=function(self,x,y)
            self._pos={x=x,y=y}
            self:onMove()
        end,
        render = function(self, addonlet, gbox, offset, zoom)
            local size=16
           
            local g =
                gbox:CreateOrGetControl(
                "groupbox",
                "gbox_" .. self._id,
                self:getPos().x * zoom+offset.x - size*zoom/2,
                self:getPos().y * zoom+offset.y   - size*zoom/2,
                size*zoom,
                size*zoom
            )
            AUTO_CAST(g)
            g:SetSkinName("bg2")
            g:EnableScrollBar(0)
            g:EnableHitTest(0)
            if self:isSelected(addonlet) then
                g:SetColorTone("FF0000FF")
            end
 
            local textsz={x=80,y=24}
            local txt =
                g:CreateOrGetControl(
                "richtext",
                "text",
                self:getPos().x * zoom+offset.x-textsz.x * zoom/2,
                self:getPos().y * zoom+offset.y-textsz.y * zoom*3/2,
                
                textsz.x * zoom,
                textsz.y * zoom
            )
            AUTO_CAST(txt)
            txt:EnableHitTest(0)
            txt:SetText("{ol}" .. self._name)
            for i, v in ipairs(self._streams) do
                v:render(addonlet,gbox, offset, zoom)
            end
        end,
        addStream=function(self,stream)
            table.insert(self._streams,stream)
            stream:buildDefaultLine()
        end,
        removeStream=function(self,stream)
            for i,v in ipairs(self._streams) do
                if v==stream then
                    table.remove(self._streams,i)
                    return
                end
            end
        end,
        hitTestBox=function(self, left,top,right,bottom)
            local rect = self:getPos()
            local sz=16
            return right>=rect.x-sz/2 and left<=rect.x+sz/2 and bottom>=rect.y-sz/2 and top<=rect.y+sz/2
        end,
        assignImpl=function(self,obj)
            self._supers["MANodeBase"].assignImpl(self,obj)
            self.title=obj.title
            self._streams={}
            for i,node in ipairs(obj._streams) do
                self._streams[#self._streams+1]=node:clone()
            end
            self.ownerNode=obj.ownerNode
        end,
        isInlet=function(self)
            for _,v in pairs(self.ownerNode:getInlets()) do
                if v==self then
                    return true
                end
            end
            
        end,
        isOutlet=function(self)
            for _,v in pairs(self.ownerNode:getInlets()) do
                if v==self then
                    return true
                end
            end
            
        end,
        onMove=function(self,x,y)
            
            for i,stream in ipairs(self._streams) do
                g.fn.dbgout("RECONNECT")
                stream:reconnectLine()
            end
        end,
	}
	local obj= g.fn.inherit(self,g.cls.MANodeBase(gateName))

    return obj
end

g.cls.MAAnyGate=function(addonletName,title,ownerNode,stream)
    local self={
        _className="MAAnyGate",
        _stream=stream,
        isConnectableStream=function(self,stream)
            return true
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self.ownerNode=obj.ownerNode
            self._stream=obj._stream
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Any",title,ownerNode))

    return obj
end
g.cls.MAFunctionalGate=function(addonletName,title,ownerNode,checkfunc,func)
    local self={
        _className="MAFunctionalGate",
        _checkfunc=checkfunc,
        _func=func,

        isConnectableStream=function(self,stream)
            
            return  self._checkfunc(stream)
            
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self._checkfunc=obj._checkfunc
            self._func=obj._func
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Functional",addonletName,title,ownerNode))

    return obj
end
g.cls.MAPrimitiveGate=function(self,addonletName,title,ownerNode,typename)
    local self={
        _className="MAPrimitiveGate",
        _typename=typename,
        getTypeName=function (self)
            return self._typename
        end,
  
        isConnectableStream=function(self,stream)
            
            return stream:instanceOf(g.cls.MAPrimitiveStream) and stream:getTypeName()==self._typename
            
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self._typename=obj._typename
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Primitive",addonletName,title,ownerNode))

    return obj
end

