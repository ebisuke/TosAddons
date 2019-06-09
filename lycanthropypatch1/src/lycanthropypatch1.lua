function QUICKSLOTNEXPBAR_MY_MONSTER_SKILL(isOn, monName, buffType)
	
	local frame= ui.GetFrame("quickslotnexpbar")
	-- ON 일때.
	if isOn == 1 then
		local icon = nil
		local monCls = GetClass("Monster", monName);
		local list = GetMonsterSkillList(monCls.ClassID);
		--list:Add('Common_StateClear')
		for i = 0, list:Count() - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
			tolua.cast(slot, "ui::CSlot");
			local sklName = list:Get(i);
			local sklCls = GetClass("Skill", sklName);
			local type = sklCls.ClassID;
			SET_MON_QUICK_SLOT(frame, slot, "Skill", type)
			icon = slot:GetIcon();
			slot:SetEventScript(ui.RBUTTONUP, 'None');
		end
		
		if icon ~=nil and monName == "Colony_Siege_Tower" then
			icon:SetImage('Icon_common_get_off')
		end	
		local lastSlot = GET_CHILD_RECURSIVELY(frame, "slot"..list:Count() +1, "ui::CSlot");
		local icon = lastSlot:GetIcon();
		if icon ~= nil then
			local iconInfo = icon:GetInfo();
			lastSlot:SetUserValue('ICON_CATEGORY', iconInfo:GetCategory());
			lastSlot:SetUserValue('ICON_TYPE', iconInfo.type);
		end

		CLEAR_SLOT_ITEM_INFO(lastSlot);
		local icon = CreateIcon(lastSlot);
		local slotString 	= 'QuickSlotExecute'..(list:Count() +1);
		local text 			= hotKeyTable.GetHotKeyString(slotString);
		lastSlot:SetText('{s14}{#f0dcaa}{b}{ol}'..text, 'default',  ui.LEFT, ui.TOP, 2, 1);
		local lastSlotIconName = "druid_del_icon";
		if monName == "Colony_Siege_Tower" then
			lastSlotIconName = "Icon_common_get_off";
		end	
		icon:SetImage(lastSlotIconName);
		lastSlot:EnableDrag(0);
		SET_QUICKSLOT_OVERHEAT(lastSlot);
		
		for i = list:Count(), MAX_QUICKSLOT_CNT - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
			tolua.cast(slot, "ui::CSlot");	
			slot:EnableDrag(0);
			slot:EnableDrop(0);
			local icon = slot:GetIcon();
			if icon ~= nil and icon:GetInfo():GetCategory()=='Skill' then
			 	icon:SetEnable(0);
				--icon:SetEnableUpdateScp('None');
			end
		end
		frame:SetUserValue('SKL_MAX_CNT',list:Count()+1)
		frame:SetUserValue('MON_RESET_COOLDOWN', 0)

		return;
	end

	-- OFF 일때(복구)
	for i = 0, MAX_QUICKSLOT_CNT - 1 do
		local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
		tolua.cast(slot, "ui::CSlot");	
		slot:EnableDrag(1);
		slot:EnableDrop(1);
	end

	local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
	for i = 1, sklCnt do
		local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i, "ui::CSlot");		
		CLEAR_QUICKSLOT_SLOT(slot);
		local slotString = 'QuickSlotExecute'..i;
		local text = hotKeyTable.GetHotKeyString(slotString);
		slot:SetText('{s14}{#f0dcaa}{b}{ol}'..text, 'default', ui.LEFT, ui.TOP, 2, 1);
		local cate = slot:GetUserValue('ICON_CATEGORY');
		if 'None' ~= cate then
			SET_QUICK_SLOT(frame, slot, cate, slot:GetUserIValue('ICON_TYPE'),  "", 0, 0, true);
		end
		slot:SetUserValue('ICON_CATEGORY', 'None');
		slot:SetUserValue('ICON_TYPE', 0);
		SET_QUICKSLOT_OVERHEAT(slot);
	end
	frame:SetUserValue('SKL_MAX_CNT',0)
end

function JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL(isOn, monName, buffType)
	
	local frame = ui.GetFrame('joystickquickslot')
	-- ON 일때.
	if isOn == 1 then
		local icon = nil
		local monCls = GetClass("Monster", monName);
		local list = GetMonsterSkillList(monCls.ClassID);
		--list:Add('Common_StateClear')
		for i = 0, list:Count() - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
			tolua.cast(slot, "ui::CSlot");	
			icon = slot:GetIcon();
			local sklName = list:Get(i);
			local sklCls = GetClass("Skill", sklName);
			local type = sklCls.ClassID;
			SET_MON_QUICK_SLOT(frame, slot, "Skill", type)
			icon = slot:GetIcon();
			slot:SetEventScript(ui.RBUTTONUP, 'None');
		end
		
		if icon ~=nil and monName == "Colony_Siege_Tower" then
			icon:SetImage('Icon_common_get_off')
		end	
		
		for i = list:Count(), MAX_QUICKSLOT_CNT - 1 do
			local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
			tolua.cast(slot, "ui::CSlot");	
			slot:EnableDrag(0);
			slot:EnableDrop(0);
			local icon = slot:GetIcon();
			if icon ~= nil and icon:GetInfo():GetCategory()=='Skill' then
			 	icon:SetEnable(0);
				--icon:SetEnableUpdateScp('None');
			end
		end
		local lastSlot = GET_CHILD_RECURSIVELY(frame, "slot"..list:Count() +1, "ui::CSlot");
		local icon = lastSlot:GetIcon();
		if icon ~= nil then
			local iconInfo = icon:GetInfo();
			lastSlot:SetUserValue('ICON_CATEGORY', iconInfo:GetCategory());
			lastSlot:SetUserValue('ICON_TYPE', iconInfo.type);
		end

		CLEAR_SLOT_ITEM_INFO(lastSlot);
		local icon = CreateIcon(lastSlot);
		local slotString 	= 'QuickSlotExecute'..(list:Count() +1);
		local hotKey		= hotKeyTable.GetHotKeyString(slotString, 1); -- 조이패드 핫키
		hotKey = JOYSTICK_QUICKSLOT_REPLACE_HOTKEY_STRING(false , hotKey);
		lastSlot:SetText('{s14}{#f0dcaa}{b}{ol}'..hotKey, 'default', ui.LEFT, ui.TOP, 2, 1);
		local lastSlotIconName = "druid_del_icon";
		if monName == "Colony_Siege_Tower" then
			lastSlotIconName = "Icon_common_get_off";
		end	
		icon:SetImage(lastSlotIconName);
		lastSlot:EnableDrag(0);
		
		frame:SetUserValue('SKL_MAX_CNT',list:Count()+1)
		frame:SetUserValue('MON_RESET_COOLDOWN', 0)

		return;
	end

	-- OFF 일때(복구)
	for i = 0, MAX_QUICKSLOT_CNT - 1 do
		local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
		tolua.cast(slot, "ui::CSlot");	
		slot:EnableDrag(1);
		slot:EnableDrop(1);
	end

	local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
	for i = 1, sklCnt do
		local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i, "ui::CSlot");	
		CLEAR_QUICKSLOT_SLOT(slot);
		local slotString = 'QuickSlotExecute'..i;
		local hotKey = hotKeyTable.GetHotKeyString(slotString, 1); -- 조이패드 핫키
		hotKey = JOYSTICK_QUICKSLOT_REPLACE_HOTKEY_STRING(false , hotKey);
		slot:SetText('{s14}{#f0dcaa}{b}{ol}'..hotKey, 'default', ui.LEFT, ui.TOP, 2, 1);
		local cate = slot:GetUserValue('ICON_CATEGORY');
		if 'None' ~= cate then        
			SET_QUICK_SLOT(frame, slot, cate, slot:GetUserIValue('ICON_TYPE'),  "", 0, 0, true);
		end
		slot:SetUserValue('ICON_CATEGORY', 'None');
		slot:SetUserValue('ICON_TYPE', 0);
		SET_QUICKSLOT_OVERHEAT(slot)
	end
	frame:SetUserValue('SKL_MAX_CNT',0)
end
