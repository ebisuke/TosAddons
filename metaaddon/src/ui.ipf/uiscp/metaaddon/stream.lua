--metaaddon_stream
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
g.cls.MAStream =function(sourceGate,destinationGate)
   local self=
    {
        _className="MAStream",
        lines = {},
        getColor=function(self)
            return "FFFF0000"
        end,
        sourceGate = sourceGate,
        destinationGate = destinationGate,
        
        buildDefaultLine = function(self)
            if self.sourceGate and self.destinationGate  then
                
                -- three lines
                local destgate=self.destinationGate
                local centerx =
                (destgate:getPos().x-self.sourceGate:getPos().x) / 2 +
                (self.sourceGate:getPos().x)

                local line = g.cls.MAStreamLine()
                self.lines = {
                    g.cls.MAStreamLine(
                        self,
                        {x = self.sourceGate:getPos().x, y = self.sourceGate:getPos().y},
                        {x = centerx, y = self.sourceGate:getPos().y}
                    ):init(),
                    g.cls.MAStreamLine(
                        self,
                        {x = centerx, y = self.sourceGate:getPos().y},
                        {x = centerx, y = destgate:getPos().y}
                    ):init(),
                    g.cls.MAStreamLine(
                        self,
                        {x = centerx, y = destgate:getPos().y},
                        {x = destgate:getPos().x, y = destgate:getPos().y}
                    ):init()
                }
                
                
            end
        end,
        reconnectLine=function(self)
            self:buildDefaultLine()
            if true then 
                return
            end
            if self.sourceGate and self.destinationGate then

                local x,y= self.sourceGate:getPos().x,self.sourceGate:getPos().y
                local prev=nil
                --check line connectivity
                for k, line in ipairs(self.lines) do
                    if k==1 and (line:getSourcePos().x~=x or line:getSourcePos().y~=y )then
                        --connect to source
                        line:setPos(x,y)

                        line:setDestinationPos(line:getDestinationPos(),y)
                    end
                    x,y=line:getDestinationPos().x,line:getDestinationPos().y
                    if k>1 and k<#self.lines and(line:getSourcePos().x~=x or line:getSourcePos().y~=y )then

                        local horz=line:isHorizontal()

                        --connect to destination
                        line:setPos(x,y)
                        if horz then
                            line:setDestinationPos(line:getDestinationPos().x,y)
                        else
                            line:setDestinationPos(x,line:getDestinationPos().y)
                        end
                        
                    end
                    x,y=line:getDestinationPos().x,line:getDestinationPos().y
                    if k==#self.lines and (line:getDestinationPos().x~=x or line:getDestinationPos().y~=y )then

                        local horz=prev:isHorizontal()

                        --connect to destination
                        prev:setPos(x,y)
                        if horz then
                            prev:setDestinationPos(line:getDestinationPos().x,y)
                        else
                            prev:setDestinationPos(x,line:getDestinationPos().y)
                        end
                        
                    end
                    if k==#self.lines and (line:getSourcePos().x~=x or line:getSourcePos().y~=y )then

                        local horz=prev:isHorizontal()

                        --connect to destination
                        prev:setPos(x,y)
                        if horz then
                            prev:setDestinationPos(line:getDestinationPos().x,y)
                        else
                            prev:setDestinationPos(x,line:getDestinationPos().y)
                        end
                        
                    end
                    prev=line
                end
                
            else
                self.lines = {}
            
            end
        end,
        calculateBoundingBox=function(self)
            local left,top,right,bottom=0,0,0,0
            for _,line in ipairs(self.lines) do
                local l,t,r,b=line:calculateBoundingBox()
                left=math.min(left,l)
                top=math.min(top,t)
                right=math.max(right,r)
                bottom=math.max(bottom,b)
            end
            return {left=left,top=top,right=right,bottom=bottom}
        end,
        hitTestBox=function(self, left,top,right,bottom)
            local rect = self:calculateBoundingBox()
            return right<=rect.left and left >=rect.right and bottom>=rect.top and top<=rect.bottom
        end,
        render=function(self,addonlet,gbox,offset,zoom)
            for _,line in ipairs(self.lines) do
                line:render(addonlet,gbox,offset,zoom)
            end
        end,
        lazyInitImpl=function(self)
            if  self.sourceGate and self.destinationGate then
                self.sourceGate:addStream(self)
                self.destinationGate:addStream(self)
            end
            self:buildDefaultLine()
        end,
        getLines=function(self)
            return self.lines
        end,
        removeLine=function(self,line)
            for k,v in ipairs(self.lines) do
                if v==line then
                    table.remove(self.lines,k)
                    break
                end
            end
        end,
        assignImpl=function(self,obj)
            self._supers["MANodeBase"].assignImpl(self,obj)
            self.lines={}
            for i,v in pairs(obj.lines) do
                self.lines[#self.lines+1]=v:clone()
            end
            self.color=obj.color
            self.sourceGate=obj.sourceGate
            self.destinationGate=obj.destinationGate
        end,
        releaseImpl=function(self)
            self._supers["MANodeBase"].releaseImpl(self)
            if  self.sourceGate then
             self.sourceGate:removeStream(self)
            end
            if  self.destinationGate then
            self.destinationGate:removeStream(self)
            end
            for _,line in ipairs(self.lines) do
                line:release()
            end
            self.lines={}
            self.sourceGate=nil
            self.destinationGate=nil
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MANodeBase())

    return obj
end

g.cls.MAPrimitiveStream = function (sourceGate,destinationGate,typename)
    local self=
    {
        _className="MAPrimitiveStream",
        _typename = typename,
        getColor=function(self)
            if self._typename=="boolean" then
                return "FF227722"
            elseif  self._typename=="number" then
                return "FF4444FF"
            elseif self._typename=="string" then
                return "FF7777FF"
            else
                return "FFAA99FF"
            end
        end,
        getTypeName = function(self)
            return self._typename
        end,
        assignImpl=function(self,obj)
            self._supers["MAStream"].assignImpl(self,obj)
            self._typename=obj._typename
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end


g.cls.MAFlowStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FF000000"
        end,
        _className="MAFlowStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end

g.cls.MAAnyStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FF444444"
        end,
        _className="MAAnyStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end
g.cls.MAVariantStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FFFF77FF"
        end,
        _className="MAVariantStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end
g.cls.MANullStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FF222222"
        end,
        _className="MANullStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end
g.cls.MASkillStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FF0000FF"
        end,
        _className="MASkillStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end
g.cls.MAItemStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FFFF6600"
        end,
        _className="MAItemStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end
g.cls.MAPoseStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FF669966"
        end,
        _className="MAPoseStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end
g.cls.MATableStream = function (sourceGate,destinationGate)
    local self=
    {
        getColor=function(self)
            return "FFAAAAAA"
        end,
        _className="MATableStream",

    }
    local obj= g.fn.inherit(self,g.cls.MAStream(sourceGate,destinationGate))

    return obj
end