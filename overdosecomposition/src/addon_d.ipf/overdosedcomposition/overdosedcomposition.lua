-- overdosedcomposition
local addonName = "overdosedcomposition"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')


function EBI_try_catch(what)
	local status, result = pcall(what.try)
	if not status then
		what.catch(result)
	end
	return result
end
function OVERDOSEDCOMPOSITION_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            acutil.setupHook(ODDC_REINFORCE_BY_MIX_SETITEM,"REINFORCE_BY_MIX_SETITEM")
            acutil.setupHook(ODDC_RECREATE_MATERIAL_SLOT,"RECREATE_MATERIAL_SLOT")

        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function ODDC_RECREATE_MATERIAL_SLOT(frame)
   
    EBI_try_catch{
        try = function()
            RECREATE_MATERIAL_SLOT_OLD(frame)
            local matslot = GET_MAT_SLOT(frame);        
            matslot:ShowWindow(1);
           
            matslot:RemoveAllChild();
            matslot:SetColRow(18,6);
            matslot:SetSlotSize(20,20);
            matslot:SetSpc(1,1);
            matslot:CreateSlots();
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function ODDC_REINFORCE_BY_MIX_SETITEM(frame,invItem)
    
    EBI_try_catch{
        try = function()
            REINFORCE_BY_MIX_SETITEM_OLD(frame,invItem)
            local matslot = GET_MAT_SLOT(frame);        
            matslot:ShowWindow(1);
           
            matslot:RemoveAllChild();
            matslot:SetColRow(18,6);
            matslot:SetSlotSize(20,20);
            matslot:SetSpc(1,1);
            matslot:CreateSlots();
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end