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
        _className="JSNISlotset",
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
        getSlotWidth=function(self)
            return self._slotSize.w
        end,
        getSlotHeight=function(self)
            return self._slotSize.h
        end,
        getSlotSpcX=function(self)
            return self._nativeSlotSet:GetSpcX()
        end,
        getSlotSpcY=function(self)
            return self._nativeSlotSet:GetSpcY()
        end,
        initImpl=function(self)
            self:recreate()
        end,
        recreate=function (self)
            local s=self:createorGetNativeControl("slotset","slotset");
            self._nativeSlotSet=s
            s:RemoveAllChild()
            s:ClearIconAll()
            s:EnableDrag(0)
            s:EnablePop(0)
            s:EnableSelection(0)
            s:SetSkinName("invenslot2");
            s:SetSpc(1,1)
            s:SetSlotSize(self._slotSize.w,self._slotSize.h)
            s:SetColRow(self:getColumnCount(),1)
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
        getSlotCount=function(self)
            return self:getNativeSlotSet():GetSlotCount()
        end,
        assign=function (self,iterable,processor)
            self:recreate()
            local s=self:getNativeSlotSet()

            local tbl={}
            for v in iterable do
                tbl[#tbl+1] = v
            end
           
            s:RemoveAllChild()
            s:ClearIconAll()
            
            s:SetColRow(self._columnCount,math.ceil(#tbl/self._columnCount))
            s:CreateSlots()
            for i,v in ipairs(tbl) do

                if(s:GetSlotByIndex(i-1)==nil) then
                    break
                end
                local slot=g.classes.JSNNativeExtender(s:GetSlotByIndex(i-1)):init()
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