--uie_gbg_inventory


local acutil = require('acutil')

--ライブラリ読み込み
local debug = false
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

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT

g.gbg=g.gbg or {}
g.gbg.uiegbgFishing={

    new=function(frame,name,caption)
        local self=inherit(g.gbg.uiegbgFishing,g.gbg.uiegbgBase,frame,name,caption or g.tr('fishing'))


        return self
    end,
    
    initializeImpl=function(self,gbox)
        local label=gbox:CreateOrGetControl('richtext','txtdesc',0,30,0,0)
        label:SetText('{ol}{s30}'..g.tr('chooseabait'))
        label:SetGravity(ui.CENTER_HORZ,ui.TOP)
        
        local under=g.gbg.uiegbgComponentUnderBtn.new(self,'under',{
            {
                name="cancel",
                caption=g.tr('cancel'),
                callback=function() self:close() end,
            }
        })
        local inv=g.gbg.uiegbgComponentInventory.new(self,'bait',{
            tooltipxy={x=0,y=100},
    
            filter=function(invItem)
                local itemObj = GetIES(invItem:GetObject());
                if IS_PASTE_BAIT_ITEM(itemObj.ClassID) == 1 then
                    return true
                end
                return false
            end,
            slotsize=80,
            onrclicked=function(item)
                self:doFishing()
            end
        })
        inv:initialize(gbox:GetWidth()/2-200,60,400,200)
        self:addComponent(inv)
        under:initialize()
       
        self:addComponent(under)

       
    end,
    postInitializeImpl=function(self,gbox)
        local inv=self:getComponent('bait')
        inv:attachDefaultHandler()
    end,
    doFishing=function(self)
        local inv=self:getComponent('bait')
        local bait=inv:getSelectedItems()
        if #bait==0 then
            ui.SysMsg(g.tr('pleasechoostabait'))
            return
        end
        imcSound.PlaySoundEvent("button_click_big");
        local topFrame=ui.GetFrame('fishing')
        local fishingPlaceHandle = topFrame:GetUserIValue('FISHING_PLACE_HANDLE');
        local fishingRodID = topFrame:GetUserIValue('FISHING_ROD_ID');
        if fishingPlaceHandle == 0 or fishingRodID == 0 then -- invalid data
            ui.SysMsg(ClMsg('TryLater')); 
            return;
        end
        Fishing.ReqFishing(1, fishingPlaceHandle, fishingRodID, bait[1].item.type);
        self:close()
    end
}
UIMODEEXPERT = g