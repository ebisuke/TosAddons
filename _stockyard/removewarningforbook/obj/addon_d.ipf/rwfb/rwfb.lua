-- RWFTLI
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

function BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN(invItem)	
	if invItem == nil then
		return;
	end

	local invFrame = ui.GetFrame("inventory");	
	local itemobj = GetIES(invItem:GetObject());
	if itemobj == nil then
		return;
	end
	
	if SYSMENU_INVENTORY_WEIGHT_NOTICE == nil then
		--older one
		invFrame:SetUserValue("INVITEM_GUID", invItem:GetIESID());
	else
		--newer
		invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
	end
	
    if itemobj.Script == 'SCR_SUMMON_MONSTER_FROM_CARDBOOK' then
        REQUEST_SUMMON_BOSS_TX()
		return;
	elseif itemobj.Script == 'SCR_QUEST_CLEAR_LEGEND_CARD_LIFT' then
		local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("Use_Item_LegendCard_Slot_Open2"));
		ui.MsgBox_NonNested(textmsg, itemobj.Name, "REQUEST_SUMMON_BOSS_TX", "None");
		return;
	end
end