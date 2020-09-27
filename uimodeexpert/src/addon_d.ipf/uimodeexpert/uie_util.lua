--uie_util
--アドオン名（大文字）
local addonName = 'uimodeexpert'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
local acutil = require('acutil')
local debug = true
--ライブラリ読み込み

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end
local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
                fd:flush()
                fd:close()
            end
        end,
        catch = function(error)
        end
    }
end
local function ERROUT(msg)
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end


UIMODEEXPERT = UIMODEEXPERT or {}
local g = UIMODEEXPERT
g.util=g.util or {}
g.util.map={
    ['ui::CButton']='button',
    ['ui::CRichText']='richtext',
    ['ui::CPicture']='picture',
    ['ui::CGroupBox']='groupbox',
    ['ui::CCheckBox']='checkbox',
    ['ui::CTabControl']='tab',
    ['ui::CSlot']='slot',
    ['ui::CIcon']='icon',
    ['ui::CDropList']='droplist',

    
}


g.util.instanceof=function (subject, super)

	super = tostring(super)
	local mt = getmetatable(subject)

	while true do
		if mt == nil then return false end
		if tostring(mt) == super then return true end

		mt = getmetatable(mt)
	end	
end
g.util.cloneControl=function(src,dest)
    
    for i=0,src:GetChildCount()-1 do
        local child=src:GetChildByIndex(i)
        AUTO_CAST(child)
        local cstr=child:GetClassString()
        if cstr=='ui::CControlSet' then
            --print(child:GetStrcontrolset()..'/'..child:GetName()..'/'..child:GetText())
            local clone=dest:CreateOrGetControlSet(child:GetStrcontrolset(),child:GetName(),child:GetX(),child:GetY())
            if clone then
                AUTO_CAST(clone)
                clone:CloneFrom(child)
            
                g.util.cloneControl(child,clone)
            end
        else
            local clone=dest:CreateOrGetControl(child:GetClassName(),child:GetName(),child:GetX(),child:GetY(),child:GetWidth(),child:GetHeight())
            AUTO_CAST(clone)
            clone:CloneFrom(child)
            
            g.util.cloneControl(child,clone)
            
        end
    end
end
g.util.showItemToolTip=function(invItem,x,y)
   


    local obj = GetIES(invItem:GetObject())

    local noTradeCnt = TryGetProp(obj, 'BelongingCount')
    local itemFrame = ui.GetFrame("wholeitem");
    
    if not itemFrame then
            itemFrame = ui.GetNewToolTip("wholeitem", "wholeitem");
    end
    UPDATE_ITEM_TOOLTIP(itemFrame, '', 0, 0, nil, obj, noTradeCnt)
    itemFrame:RefreshTooltip();
    itemFrame:ShowWindow(1);
    itemFrame:SetOffset(x,y)
    --ui.ToCenter(itemFrame);

end
g.util.isNilOrNoneOrWhitespace=function(str)
    if str==nil then
        return true
    else
        local mod=string.gsub(str,' *',''):lower()
        if mod=='' or mod=='none' then
            return true
        end
    end
    return false
end
g.util.hideItemToolTip=function()
   
    local itemFrame = ui.GetFrame("wholeitem");
    
    if itemFrame then
            itemFrame:ShowWindow(0)
    end
end
g.util.generateSilverString=function(price,size)
    size=size or 20
    return string.format('{img icon_item_silver %d %d} {ol}{s%d} %s',size,size,size,tostring(price))
end
UIMODEEXPERT = g