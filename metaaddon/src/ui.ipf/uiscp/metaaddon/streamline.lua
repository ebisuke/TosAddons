--metaaddon_stream
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

g.cls.MAStreamLine=function(ownerStream,srcpos,destpos)
    local self={
        _className="MAStreamLine",
        lines={},
        _pos=srcpos,
        selectable=true,
        _ownerStream=ownerStream,
        _destinationpos=destpos,

        setPos=function(self,x,y)
            if self._pos.x==self._destinationpos.x then
                -- lock X
                x=self._pos.x
            else
                y=self._pos.y
            end
            self:setSourcePos({x=x,y=y})
        end,
        getSourcePos=function(self)
            return self._pos
        end,
        setSourcePos=function(self,pos)
            if self._pos.x==self._destinationpos.x then
                -- lock X
                pos.x=self._pos.x
            else
                pos.y=self._pos.y
            end
            self._pos=pos
        end,
        getDestinationPos=function(self)
            return self._destinationpos
        end,
        setDestinationPos=function(self,x,y)
            if self._pos.x==self._destinationpos.x then
                -- lock X
                x=self._pos.x
            else
                y=self._pos.y
            end
            self._destinationpos.x=x
            self._destinationpos.y=y
        end,
        render=function(self,addonlet,gbox,offset,zoom)
            local brush="brush_2"
            if self:isSelected(addonlet) then
                brush="brush_4"
            end


            local x=math.min( self:getSourcePos().x*zoom+offset.x, self:getDestinationPos().x*zoom+offset.x)
            local y=math.min( self:getSourcePos().y*zoom+offset.y, self:getDestinationPos().y*zoom+offset.y)
            local xx=math.max( self:getSourcePos().x*zoom+offset.x, self:getDestinationPos().x*zoom+offset.x)
            local yy=math.max( self:getSourcePos().y*zoom+offset.y, self:getDestinationPos().y*zoom+offset.y)
            

            if self:getSourcePos().y==self:getDestinationPos().y then
                gbox:DrawBrushHorz(x,y,xx,yy,brush,self._ownerStream.color)
            else
                gbox:DrawBrushVert(x,y,xx,yy,brush,self._ownerStream.color)
            end
        end,
        calculateBoundingBox=function(self)
            local left=math.min(self:getSourcePos().x,self:getDestinationPos().x)
            local top=math.min(self:getSourcePos().y,self:getDestinationPos().y)
            local right=math.max(self:getSourcePos().x,self:getDestinationPos().x)
            local bottom=math.max(self:getSourcePos().y,self:getDestinationPos().y)

            if left==right then
                left=left-2
                right=right+2
            else
                top=top-2
                bottom=bottom+2
            end
            return {left=left,top=top,right=right,bottom=bottom}
        end,
        hitTestBox=function(self, left,top,right,bottom)
            local rect = self:calculateBoundingBox()
            return left<=rect.right and right >=rect.left and bottom>=rect.top and top<=rect.bottom
        end,
        isHorizontal=function(self)
            return self:getSourcePos().y==self:getDestinationPos().y
        end,
    }
    local obj= g.fn.inherit(self,g.cls.MANodeBase())

    return obj
end


