--metaaddon_trigger
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
g.cls.MATriggerBase = function(name)
    local self={
        _className="MATriggerBase",
        _children = {},
        _size = {w = 0, h = 0},
        getRect = function(self)
            return {
                x = self._pos.x,
                y = self._pos.y,
                w = self._size.w,
                h = self._size.h
            }
        end,
        setRect = function(self, x, y, w, h)
            self._pos.x = x
            self._pos.y = y
            self._size.w = w
            self._size.h = h
        end,
        getChildren = function(self)
            return self._children
        end,
        removeChild = function(self, child)
            for i, v in ipairs(self._children) do
                if v:getID() == child:getID() then
                    table.remove(self._children, i)
                    break
                end
            end
        end,
        render = function(self, addonlet, gbox,offset,zoom)
            local g =
                gbox:CreateOrGetControl(
                "groupbox",
                "gbox_" .. self._name,
                self._pos.x*zoom+offset.x, self._pos.y*zoom+offset.y, self._size.w*zoom, self._size.h*zoom
            )
            AUTO_CAST(g)
            g:SetSkinName("bg")
            local txt = g:CreateOrGetControl("richtext", "icon", self._pos.x*zoom+offset.x, self._pos.y*zoom+offset.y, self._size.w*zoom, self._size.h*zoom)
            AUTO_CAST(txt)
            txt:EnableHitTest(0)
            txt:SetText("{ol}" .. self._name .. "{/ol}")
        end,
        calculateBoundingBox=function(self)

            local left,top,right,bottom=self._pos.x,self._pos.y,self._pos.x+self._size.w,self._pos.y+self._size.h
            for i, v in ipairs(self._children) do
                local childLeft,childTop,childRight,childBottom=v:calculateBoundingBox()
                if childLeft<left then left=childLeft end
                if childTop<top then top=childTop end
                if childRight>right then right=childRight end
                if childBottom>bottom then bottom=childBottom end
            end
            return {left=left,top=top,right=right,bottom=bottom}
        end
    }

    local obj = g.fn.inherit(self, g.cls.MANodeBase(name))

    return obj
end

g.cls.MATriggerGameStart3Sec = function()
    local self={
        _className="MATriggerGameStart3Sec",
      
    }

    local obj = g.fn.inherit(self, g.cls.MATriggerBase("GameStart3Sec"))

    return obj
end
