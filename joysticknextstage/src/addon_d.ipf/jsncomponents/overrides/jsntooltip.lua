--jsntooltip.lua
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
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end


local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
            end
        end,
        catch = function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
g.classes=g.classes or {}
g.classes.JSNTooltipFrame=function (jsnmanager,owner,x,y)
    local self={
        _className="JSNTooltipFrame",
        _x=x,
        _y=y,
        _skillTooltip=nil,
        _itemTooltip=nil,
        initImpl=function (self)
            self._itemTooltip=ui.GetNewToolTip("wholeitem_link","wholeitem_link"..self:getID())
            self._skillTooltip=ui.GetNewToolTip("skill","wholeitem_link"..self:getID())
            AUTO_CAST(self._itemTooltip)
            AUTO_CAST(self._skillTooltip)
            self:setRect(self._x,self._y,self._x,self._y)
        end,
        releaseImpl=function (self)
            ui.DestroyFrame(self._itemTooltip:GetName())
            ui.DestroyFrame(self._skillTooltip:GetName())
       
        end,
        clearToolTip=function (self)
            self._itemTooltip:ShowWindow(0)
            self._skillTooltip:ShowWindow(0)
            self:setNativeFrame(nil)
        end,
        assignItemByGuid=function (self,guid)
            self:clearToolTip()
            local invItem=GET_PC_ITEM_BY_GUID(guid)
            local itemObj=GetIES(invItem:GetObject())
            local clsID=invItem.type
            local baseCls = GetClassByType('Item', clsID);
            local itemFrame=self._itemTooltip;
            local skillFrame=self._skillTooltip
            if IS_SKILL_SCROLL_ITEM(baseCls) == 0 then -- 스킬 스크롤이 아니면
  
                local linkInfo = session.link.CreateOrGetGCLinkObject(clsID, GET_MODIFIED_PROPERTIES_STRING(itemObj));
                itemFrame:SetTooltipType('wholeitem')
                local newobj = GetIES(linkInfo:GetObject());
                local pobj = tolua.cast(newobj, "imcIES::IObject");		
                itemFrame:SetTooltipIESID(GetIESID(newobj));
                itemFrame:SetTooltipStrArg('link');
                self:setNativeFrame(itemFrame)

            else
                local skillType, level = GetSkillScrollProperty(GetSkillItemProperiesString(itemObj));
                skillFrame:SetTooltipType('skill');
                skillFrame:SetTooltipArg("Level", skillType, level);
                self:setNativeFrame(skillFrame)
            end
                
            self:getNativeFrame():RefreshTooltip();
            self:getNativeFrame():ShowWindow(1);
            self:getNativeFrame():SetOffset(self._x,self._y);
            self:refresh()
        end,
        refreshImpl=function (self)
            if(self:getOwner())then
                self:setLayerLevel(self:getOwner():getLayerLevel()+1)
            end
        end,
        
    } 

    return g.inherit(self,
    g.classes.JSNFrameBase(jsnmanager),
    g.classes.JSNOwnerRelation(owner,true)
    )
end