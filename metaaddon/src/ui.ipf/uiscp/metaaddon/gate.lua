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
g.cls.MAGate=function(gateName,outputType,title,ownerNode)
	local self={

        title=title,
        _streams={},
        ownerNode=ownerNode,
		_className="MAGate",
        _outputType=outputType or "MAAnyStream",
        getOutputStreamType=function(self)
            return self._outputType
        end,
        initImpl=function(self)
           
            self.title=title
        end,
        releaseImpl=function(self)
            for k,v in pairs(self._streams) do
                v:release()
            end
            self._streams={}
        end,
        setPos=function(self,x,y)
            self._pos={x=x,y=y}
            self:onMove()
        end,
        isConnectableStream=function(self,stream)
            return false
        end,
   
        hasLeastOneStream=function(self)
            return g.fn.len(self._streams)>0
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
 
            local textsz={x=80,y=16}
            local txt =
            gbox:CreateOrGetControl(
                "richtext",
                "text_" .. self._id,
                self:getPos().x * zoom+offset.x-textsz.x * zoom/2,
                self:getPos().y * zoom+offset.y-textsz.y * zoom,
                
                textsz.x * zoom,
                textsz.y * zoom
            )
            AUTO_CAST(txt)
            txt:SetTextAlign("center","center")
            txt:EnableHitTest(0)
            txt:SetText("{ol}" .. self.title)
            for i, v in pairs(self._streams) do
                v:render(addonlet,gbox, offset, zoom)
            end
        end,
        hasSameStream=function(self,dest)
            for i,v in pairs(self._streams) do
                if v.sourceGate==self and v.destinationGate==dest or v.sourceGate==dest and v.destinationGate==self then
                    return true
                end
            end
            return false
        end,
        addStream=function(self,stream)
            self._streams[stream:getID()]=stream
            stream:buildDefaultLine()
        end,
        removeStream=function(self,stream)
            self._streams[stream:getID()]=nil
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
            for i,node in pairs(obj._streams) do
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
            return false
        end,
        isOutlet=function(self)
            for _,v in pairs(self.ownerNode:getOutlets()) do
                if v==self then
                    return true
                end
            end
            return false
        end,
        onMove=function(self,x,y)
            if self:isInlet() then
                self._pos={
                    x=self.ownerNode:getPos().x-8,
                    y=math.max(self.ownerNode:getPos().y,math.min(self.ownerNode:getPos().y+self.ownerNode:getRect().h,self:getPos().y))

                }
            else
                self._pos={
                    x=self.ownerNode:getPos().x+self.ownerNode:getRect().w+8,
                    y=math.max(self.ownerNode:getPos().y,math.min(self.ownerNode:getPos().y+self.ownerNode:getRect().h,self:getPos().y))

                }
            end
            for i,stream in pairs(self._streams) do
              
                stream:reconnectLine()
            end
        end,
        createCompatibleStream=function(self,dest)
           return nil
        end,
        getStreams=function(self)
            return self._streams
        end,
        compile=function(self,addonlet)
            return ""
        end,
	}
	local obj= g.fn.inherit(self,g.cls.MANodeBase(gateName))

    return obj
end
g.cls.MAFlowGate=function(title,ownerNode,stream)
    local self={
        _className="MAFlowGate",

       
        isConnectableStream=function(self,stream)
            return true
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self.ownerNode=obj.ownerNode
 

        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MAFlowStream(self,dest):init()
        end,
        compile=function(self,addonlet)
            return ""
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Flow","MAFlowStream",title,ownerNode))

    return obj
end
g.cls.MAAnyGate=function(title,ownerNode,stream)
    local self={
        _className="MAAnyGate",

       
        isConnectableStream=function(self,stream)
            return true
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self.ownerNode=obj.ownerNode
 

        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MAAnyStream(self,dest):init()
        end,
        compile=function(self,addonlet)
            return ""
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Any","MAAnyStream",title,ownerNode))

    return obj
end
g.cls.MAVariantGate=function(title,ownerNode,stream)
    local self={
        _className="MAVariantGate",

       
        isConnectableStream=function(self,stream)
            return not stream:instanceOf(g.cls.MAFlowStream())
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self.ownerNode=obj.ownerNode
 

        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MAAnyStream(self,dest):init()
        end,
  
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Variant","MAVariantStream",title,ownerNode))

    return obj
end
g.cls.MAFunctionalGate=function(title,ownerNode,checkfunc,func)
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
        createCompatibleStream=function(self,dest)
            return g.cls.MAAnyStream(self,dest):init()
        end,

    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Functional","MAAnyStream",title,ownerNode))

    return obj
end
g.cls.MAPrimitiveGate=function(title,ownerNode,typename)
    local self={
        _className="MAPrimitiveGate",
        _typename=typename,
        getTypeName=function (self)
            return self._typename
        end,
  
        isConnectableStream=function(self,stream)
            
            return stream:instanceOf(g.cls.MAAnyStream()) or stream:instanceOf(g.cls.MAPrimitiveStream()) and stream:getTypeName()==self._typename
            
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self._typename=obj._typename
        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MAPrimitiveStream(self,dest,self._typename):init()
        end,
 
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Primitive","MAPrimitiveStream",title,ownerNode))

    return obj
end
g.cls.MASkillGate=function(title,ownerNode,typename)
    local self={
        _className="MASkillGate",
        _typename=typename,
        getTypeName=function (self)
            return self._typename
        end,
  
        isConnectableStream=function(self,stream)
            
            return stream:instanceOf(g.cls.MAAnyStream()) or stream:instanceOf(g.cls.MASkillStream())
            
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self._typename=obj._typename
        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MASkillStream(self,dest,self._typename):init()
        end,
     
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Skill","MASkillGate",title,ownerNode))

    return obj
end

g.cls.MAItemGate=function(title,ownerNode,typename)
    local self={
        _className="MAItemGate",
        _typename=typename,
        getTypeName=function (self)
            return self._typename
        end,
  
        isConnectableStream=function(self,stream)
            
            return stream:instanceOf(g.cls.MAAnyStream()) or stream:instanceOf(g.cls.MAItemStream())
            
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self._typename=obj._typename
        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MAItemStream(self,dest,self._typename):init()
        end,
     
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Item","MAItemGate",title,ownerNode))

    return obj
end
g.cls.MAUsableGate=function(title,ownerNode,typename)
    local self={
        _className="MAUsableGate",
        _typename=typename,
        getTypeName=function (self)
            return self._typename
        end,
  
        isConnectableStream=function(self,stream)
            
            return stream:instanceOf(g.cls.MAAnyStream()) or stream:instanceOf(g.cls.MAItemStream())or stream:instanceOf(g.cls.MASkillStream())
            
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self._typename=obj._typename
        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MAItemStream(self,dest,self._typename):init()
        end,
     
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Usable","MAUsableGate",title,ownerNode))

    return obj
end

g.cls.MAPoseGate=function(title,ownerNode,typename)
    local self={
        _className="MAPoseGate",
        _typename=typename,
        getTypeName=function (self)
            return self._typename
        end,
  
        isConnectableStream=function(self,stream)
            
            return stream:instanceOf(g.cls.MAAnyStream()) or stream:instanceOf(g.cls.MAPoseStream())
            
        end,
        assignImpl=function(self,obj)
            self._supers["MAGate"].assignImpl(self,obj)
            self._typename=obj._typename
        end,
        createCompatibleStream=function(self,dest)
            return g.cls.MAPoseStream(self,dest,self._typename):init()
        end,
     
    }
    local obj= g.fn.inherit(self,g.cls.MAGate("Pose","MAPoseGate",title,ownerNode))

    return obj
end


