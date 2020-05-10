--[[
日本語
--]]

local acutil = require('acutil');

_G['TPJOYEXT'] = _G['TPJOYEXT'] or {};
local g7 = _G['TPJOYEXT'];
g7.settingPath = g7.settingpath or "../addons/tpjoyext/stg_tpjoyext.json";
g7.settings = g7.settings or {};
local s7 = g7.settings;

function TPJOYEXT_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START_3SEC", "TPJOYEXT_3SEC");
end

function TPJOYEXT_3SEC(frame)
	local f,m = pcall(g7.TPJOYEXT_LOAD_SETTING);
	if f ~= true then
		CHAT_SYSTEM(m);
	end
	local f,m = pcall(g7.TPJOYEXT_SAVE_SETTING);
	if f ~= true then
		CHAT_SYSTEM(m);
	end
	local f,m = pcall(g7.TPJOYEXT_AUTOEXE);
	if f ~= true then
		CHAT_SYSTEM(m);
	end
end

function g7.TPJOYEXT_LOAD_SETTING()
	local t, err = acutil.loadJSON(g7.settingPath);
	if t then
		s7 = acutil.mergeLeft(s7, t);
	end
	-- 	値の存在確保と初期値設定
	s7.isDebug			= ((type(s7.isDebug			) == "boolean")	and s7.isDebug			)or false;
	s7.isOverRide		= ((type(s7.isOverRide		) == "boolean")	and s7.isOverRide		)or false;
	s7.isAutoDis		= ((type(s7.isAutoDis		) == "boolean")	and s7.isAutoDis		)or false;
	s7.isAutoOma		= ((type(s7.isAutoOma		) == "boolean")	and s7.isAutoOma		)or false;
	s7.isAutoExpBin		= ((type(s7.isAutoExpBin	) == "boolean")	and s7.isAutoExpBin		)or false;
end

function g7.TPJOYEXT_SAVE_SETTING()
    local filep = io.open(g7.settingPath, "w+");
	if filep then
		filep:write("{\n");
		filep:write("\t\"isDebug\":"		.. ((s7.isDebug			and "true") or "false")	.."\n"	);
		filep:write(",\t\"isOverRide\":"	.. ((s7.isOverRide		and "true") or "false")	.."\n"	);
		filep:write(",\t\"isAutoDis\":"		.. ((s7.isAutoDis		and "true") or "false")	.."\n"	);
		filep:write(",\t\"isAutoOma\":"		.. ((s7.isAutoOma		and "true") or "false")	.."\n"	);
		filep:write(",\t\"isAutoExpBin\":"	.. ((s7.isAutoExpBin	and "true") or "false")	.."\n"	);
		filep:write("}\n");
		filep:close();
	end
end







function JOYSTICK_QUICKSLOT_EXECUTE(slotIndex)
	local quickFrame = ui.GetFrame('joystickquickslot')

	GET_CHILD_RECURSIVELY(quickFrame,'Set1','ui::CGroupBox'):ShowWindow(1);
	GET_CHILD_RECURSIVELY(quickFrame,'Set2','ui::CGroupBox'):ShowWindow(0);
	GET_CHILD_RECURSIVELY(quickFrame,'Set3','ui::CGroupBox'):ShowWindow(1);

	local input_L1	= joystick.IsKeyPressed("JOY_BTN_5");
	local input_R1	= joystick.IsKeyPressed("JOY_BTN_6");
	local input_L2	= joystick.IsKeyPressed("JOY_BTN_7");
	local input_R2	= joystick.IsKeyPressed("JOY_BTN_8");

	local joystickRestFrame = ui.GetFrame('joystickrestquickslot')
	if joystickRestFrame:IsVisible() == 1 then
		REST_JOYSTICK_SLOT_USE(joystickRestFrame, slotIndex);
		return;
	end



	local offset=0
	if input_L1 == 1 and input_L2 ==1 and input_R1 == 1 and input_R2 ==1 then
		--nothing to do
	else
		if input_L1 == 1 and input_L2 ==0 and input_R1 == 1 and input_R2 ==0 then

			if	slotIndex == 2  or slotIndex == 14 then
				slotIndex = 10
			elseif	slotIndex == 0  or slotIndex == 12 then
				slotIndex = 8
			elseif	slotIndex == 1  or slotIndex == 13 then
				slotIndex = 9
			elseif	slotIndex == 3  or slotIndex == 15 then
				slotIndex = 11
			end
		end
		if input_L1 == 0 and input_L2 ==1 and input_R1 == 0 and input_R2 == 1 then
			if	slotIndex == 2  or slotIndex == 14 then
				slotIndex = 10
			elseif	slotIndex == 0  or slotIndex == 12 then
				slotIndex = 8
			elseif	slotIndex == 1  or slotIndex == 13 then
				slotIndex = 9
			elseif	slotIndex == 3  or slotIndex == 15 then
				slotIndex = 11
			end
			offset=20+4
			end

		if input_L1 == 0 and input_L2 == 1 and input_R1 == 1 and input_R2 == 0 then
			offset=20
			end

		if input_L1 == 1 and input_L2 == 0 and input_R1 == 0 and input_R2 == 1 then
			offset=20+12
			end

		if input_L1 == 0 and input_L2 == 0 and input_R1 == 1 and input_R2 == 1 then
			offset=20+4
			end
		--stp=stp+4
		if input_L1 == 1 and input_L2 == 1 and input_R1 == 0 and input_R2 == 0 then
			offset=20

		end

		slotIndex=slotIndex+offset
		local quickslotFrame = ui.GetFrame('joystickquickslot');

		local slot = quickslotFrame:GetChildRecursively("slot" .. slotIndex + 1);
		

		QUICKSLOTNEXPBAR_SLOT_USE(quickslotFrame, slot, 'None', 0);
	end
end

function UPDATE_JOYSTICK_INPUT(frame)

	if IsJoyStickMode() == 0 then
		return;
	end

	local input_L1 = joystick.IsKeyPressed("JOY_BTN_5")
	local input_L2 = joystick.IsKeyPressed("JOY_BTN_7")
	local input_R1 = joystick.IsKeyPressed("JOY_BTN_6")
	local input_R2 = joystick.IsKeyPressed("JOY_BTN_8")

	if(s7.isOverRide ~= true) then
		if joystick.IsKeyPressed("JOY_UP") == 1 and joystick.IsKeyPressed("JOY_L1L2") == 1	then
			ON_RIDING_VEHICLE(1)
		end

		if joystick.IsKeyPressed("JOY_DOWN") == 1 and joystick.IsKeyPressed("JOY_L1L2") == 1  then
			ON_RIDING_VEHICLE(0)
		end
	end

	local gboxL1 = frame:GetChildRecursively("L1_slot_Set1");
	local gboxR1 = frame:GetChildRecursively("R1_slot_Set1");
	local gboxL2 = frame:GetChildRecursively("L2_slot_Set1");
	local gboxR2 = frame:GetChildRecursively("R2_slot_Set1");
    local gboxL1L2 = frame:GetChildRecursively("L1L2_slot_Set2");
    local gboxL2R1 = frame:GetChildRecursively("L2R1_slot_Set2");
    local gboxL2R2 = frame:GetChildRecursively("L2R2_slot_Set2");
    local gboxL1R2 = frame:GetChildRecursively("L1R2_slot_Set2");
    local gboxR1R2 = frame:GetChildRecursively("R1R2_slot_Set2");
	local gboxL1R1 = frame:GetChildRecursively("L1R1_slot_Set1");
	if input_L1 == 1 and input_L2 ==1 and input_R1 == 1 and input_R2 ==1 then
		--nothing to do
		gboxL1:SetSkinName(padslot_offskin);
		gboxL2:SetSkinName(padslot_offskin);
		gboxR1:SetSkinName(padslot_offskin);
		gboxR2:SetSkinName(padslot_offskin);
		gboxL1R2:SetSkinName(padslot_offskin);
		gboxL1L2:SetSkinName(padslot_offskin);
		gboxL1R1:SetSkinName(padslot_offskin);
		gboxR1R2:SetSkinName(padslot_offskin);

	else
		if input_L1 == 1 and input_R1 == 0 and input_L2 == 0 and input_R2 == 0 then
			gboxL1:SetSkinName(padslot_onskin);
		else
			gboxL1:SetSkinName(padslot_offskin);
		end
		if input_L1 == 0 and input_R1 == 1 and input_L2 == 0 and input_R2 == 0 then
			gboxR1:SetSkinName(padslot_onskin);
		else
			gboxR1:SetSkinName(padslot_offskin);
		end
		if input_L1 == 0 and input_R2 == 0 and input_L2 == 1 and input_R1 == 0 then
			gboxL2:SetSkinName(padslot_onskin);
		else
			gboxL2:SetSkinName(padslot_offskin);
		end
		if input_L1 == 0 and input_L2 == 0 and input_R1 == 0 and input_R2 == 1 then
			gboxR2:SetSkinName(padslot_onskin);
		else
			gboxR2:SetSkinName(padslot_offskin);
		end
		if input_L1 == 0 and input_L2 == 1 and input_R1 == 1 and input_R2 == 0 then
			gboxL2R1:SetSkinName(padslot_onskin);
		else
			gboxL2R1:SetSkinName(padslot_offskin);
		end

		if input_L1 == 1 and input_R1 == 0 and input_L2 == 0 and input_R2 == 1 then
			gboxL1R2:SetSkinName(padslot_onskin);
		else
			gboxL1R2:SetSkinName(padslot_offskin);
		end
		if input_L2 == 1 and input_R2 == 1 and input_L1 == 0 and input_R1 == 0 then
			gboxL2R2:SetSkinName(padslot_onskin);
		else
			gboxL2R2:SetSkinName(padslot_offskin);
		end
		if input_L2 == 1 and input_R2 == 0 and input_L1 == 1 and input_R1 == 0 then
			gboxL1L2:SetSkinName(padslot_onskin);
		else
			gboxL1L2:SetSkinName(padslot_offskin);
		end
		if input_L2 == 0 and input_R2 == 0 and input_L1 == 1 and input_R1 == 1 then
			gboxL1R1:SetSkinName(padslot_onskin);
		else
			gboxL1R1:SetSkinName(padslot_offskin);
		end
		if input_R1 == 1 and input_R2 == 1 and input_L1 == 0 and input_L2 == 0 then
			gboxR1R2:SetSkinName(padslot_onskin);
		else
			gboxR1R2:SetSkinName(padslot_offskin);
		end
	end
end

function JOYSTICK_QUICKSLOT_SWAP(test)
	QUICKSLOT_INIT();
end

function QUICKSLOT_INIT(frame, msg, argStr, argNum)
	local quickFrame = ui.GetFrame('joystickquickslot')
	local Set1 = GET_CHILD_RECURSIVELY(quickFrame,'Set1','ui::CGroupBox');
	local Set2 = GET_CHILD_RECURSIVELY(quickFrame,'Set2','ui::CGroupBox');
	local Set3 = GET_CHILD_RECURSIVELY(quickFrame,'Set3','ui::CGroupBox');
	Set1:ShowWindow(0);
	Set2:ShowWindow(0);
	Set3:ShowWindow(0);
	Set1:ShowWindow(1);
	Set3:ShowWindow(1);
end

function JOYSTICKQUICKSLOT_DRAW()
	QUICKSLOT_INIT();
	JOYSTICK_QUICKSLOT_UPDATE_ALL_SLOT();
	JOYSTICK_QUICKSLOT_REFRESH(40);
end

function CHECK_SLOT_ON_ACTIVEJOYSTICKSLOTSET(frame, slotNumber)
	return true;
end


function g7.TPJOYEXT_AUTOEXE()
	g7.fUseDisp	= s7.isAutoDis;
	g7.fUseOma	= s7.isAutoOma;
	g7.fUseBin	= s7.isAutoExpBin;
	if(g7.fUseDisp ~= true) and (g7.fUseOma ~= true) and (g7.fUseBin ~= true) then
		return;
	end
	local invItemList	= session.GetInvItemSortedList();
	if(invItemList ~= nil) then
		local invItemCnt	= invItemList:size();
		for i = 0, invItemCnt - 1 do
			local invItem = invItemList:at(i);
			if(invItem ~= nil) then
				local itmObj = GetIES(invItem:GetObject());
				if(itmObj ~= nil) then
					if(g7.fUseDisp) and(invItem.type == 641151) then
						CHAT_SYSTEM("{#FFD0C0}{s14}{ol}　自動：" .. itmObj.Name .. " /" .. g7.nts(invItem.count) .. "{/}{/}{/}");
						INV_ICON_USE(invItem);
						g7.fUseDisp = false;
					end
					if(g7.fUseOma) and(invItem.type == 641153) then
						CHAT_SYSTEM("{#FFD0C0}{s14}{ol}　自動：" .. itmObj.Name .. " /" .. g7.nts(invItem.count) .. "{/}{/}{/}");
						INV_ICON_USE(invItem);
						g7.fUseOma = false;
					end
					if(g7.fUseBin) and(invItem.type == 699011) then
						local curExp, maxExp = GET_LEGENDEXPPOTION_EXP(itmObj)
						if(curExp < maxExp) then
							CHAT_SYSTEM("{#FFD0C0}{s14}{ol}　自動：" .. itmObj.Name .. " " .. g7.nts(curExp) .. " /" .. g7.nts(maxExp) .. "{/}{/}{/}");
							INV_ICON_USE(invItem);
							g7.fUseBin = false;
						end
					end
				end
			end
		end
	end
end



function g7.nts(num)
	local numStr		= "";
	if (num~=nil) then
		numStr = numStr..num;
	end
	if (#numStr > 12) then
		numStr = string.sub(numStr,0,#numStr-12)..","..string.sub(numStr,#numStr-11,#numStr-9)..","..string.sub(numStr,#numStr-8,#numStr-6)..","..string.sub(numStr,#numStr-5,#numStr-3)..","..string.sub(numStr,#numStr-2);
	elseif (#numStr > 9) then
		numStr = string.sub(numStr,0,#numStr-9)                                               ..","..string.sub(numStr,#numStr-8,#numStr-6)..","..string.sub(numStr,#numStr-5,#numStr-3)..","..string.sub(numStr,#numStr-2);
	elseif (#numStr > 6) then
		numStr = string.sub(numStr,0,#numStr-6)                                                                                            ..","..string.sub(numStr,#numStr-5,#numStr-3)..","..string.sub(numStr,#numStr-2);
	elseif (#numStr > 3) then
		numStr = string.sub(numStr,0,#numStr-3)                                                                                                                                         ..","..string.sub(numStr,#numStr-2);
	end
	return numStr;
end
function g7.lpnts(num,len)
	local numStr		= g7.nts(num);
	return string.rep(" ", len - #numStr) .. numStr;
end

