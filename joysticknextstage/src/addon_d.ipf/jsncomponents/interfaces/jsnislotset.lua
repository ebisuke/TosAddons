--jsnslotset.lua
--アドオン名（大文字）
local addonName = "jsn_commonlib"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

g.classes=g.classes or {}
g.classes.JSNISlotset=function(nativeParentControl)

    local self={
        _nativeSlotSet=nil,
        _slotSize={w=64,h=64},
        _columnCount=5,
        getNativeSlotSet=function(self)
            return self._nativeSlotSet
        end,
        setSlotSize=function(self,w,h)
           self._slotSize={w=w,h=h}

           self:recreate();
        end,
        initImpl=function(self)
            self:recreate()
        end,
        recreate=function (self)
            local s=self:createorGetNativeControl("slotset","slotset");
            self._nativeSlotSet=s
            s:RemoveAllChild()
            s:EnableDrag(0)
            s:EnablePop(0)
            s:EnableSelection(0)
            s:SetSkinName("invenslot2");
            s:SetSpc(1,1)
            s:SetSlotSize(self._slotSize.w,self._slotSize.h)
            s:SetColRow(0,0)
            s:CreateSlots()
        end,
        clearAll=function(self)
            self._nativeSlotSet:ClearIconAll()
            self._nativeSlotSet:RemoveAllChild()
        end,
        setColumnCount=function(self,col)
            self._columnCount=col
        end,
        getColumnCount=function(self)
            return self._columnCount
        end,
        
        assign=function (self,iterable,processor)
            local s=self:getNativeSlotSet()

            local tbl
            for k,v in pairs(iterable) do
                tbl[#tbl+1] = v
            end
            s:SetColRow(self._columnColunt,math.floor(#tbl/self._columnCount))
            s:CreateSlots()
            for i,v in ipairs(tbl) do
                
                local slot=g.classes.JSNNativeExtender(s:GetSlotByIndex(i-1))
                if processor then
                    processor(v,slot)
                end
            end
        end,
        getSlotByIndex=function(self,index)
            return g.classes.JSNISlotInSlotSet(self,index):init()
        end,
        getSlotByColRow=function (self,col,row)
            return g.classes.JSNISlotInSlotSet(self,col+row*self:getColumnCount()):init()
        end
    }

    local object=g.inherit(self,g.classes.JSNInterface(nativeParentControl))
    
    return object
end