
function CPL_DUMMY()
    local frame=ui.GetFrame("partyinfo");
	local summonsinfo = ui.GetFrame("summonsinfo");
	local pcparty = session.party.GetPartyInfo();
	if pcparty == nil then
		DESTROY_CHILD_BYNAME(frame, 'PTINFO_');
		frame:ShowWindow(0);

		if summonsinfo ~= nil then
			SUMMONSINFO_TOGGLE_BUTTON(summonsinfo, 0)
		end

		local button = GET_CHILD_RECURSIVELY(summonsinfo, "summonsinfobutton");
		if button ~= nil then
			button:SetVisible(0);
			button:EnableHitTest(0);
			button:SetTextTooltip("");
		end
		return;
	end

	frame:ShowWindow(1);
	frame:SetVisible(1);
	local partyInfo = pcparty.info;
	local obj = GetIES(pcparty:GetObject());
	local list = session.party.GetPartyMemberList(PARTY_NORMAL);
	local count = list:Count();
	local memberIndex = 0;
	local myAid = session.loginInfo.GetAID();	
    local partyID = pcparty.info:GetPartyID();

	for i = 0 , count - 1 do
		local partyMemberInfo = list:Element(i);
        if partyMemberInfo:GetAID() == myAid then
            for j = 0 , 3 do
                local ret = nil;		
                -- 접속중 파티원
                if geMapTable.GetMapName(partyMemberInfo:GetMapID()) ~= 'None' then
                    ret = SET_PARTYINFO_ITEM(frame, msg, partyMemberInfo, 4, false, partyInfo:GetLeaderAID(), pcparty.isCorsairType, false, partyID);
                else-- 접속안한 파티원
                    ret = SET_LOGOUT_PARTYINFO_ITEM(frame, msg, partyMemberInfo, 4, false, partyInfo:GetLeaderAID(), pcparty.isCorsairType, partyID);
                end
            end
		else -- 내정본데
			-- local headsup = ui.GetFrame("headsupdisplay");
			-- local leaderMark = GET_CHILD(headsup, "Isleader", "ui::CPicture");
			-- if partyInfo:GetLeaderAID() ~= myAid then-- 만약 내가 아니면
			-- 	leaderMark:SetImage('None_Mark');
			-- else
			-- 	leaderMark:SetImage('party_leader_mark');
			-- end
		end
	end	

	for i = 0 , frame:GetChildCount() - 1 do
		local ctrlSet = frame:GetChildByIndex(i);
		if nil ~= ctrlSet then
			local ctrlSetName = ctrlSet:GetName();
			if string.find(ctrlSetName, "PTINFO_") ~= nil then
				local aid = string.sub(ctrlSetName, 8, string.len(ctrlSetName)-1);
				local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid);
				if memberInfo == nil then
					frame:RemoveChildByIndex(i);
					i = i - 1;
				end
			end
		end
	end
	-- DESTROY_CHILD_BYNAME(frame, 'PTINFO_');
	PARTYINFO_CONTROLSET_AUTO_ALIGN(frame);
	frame:Invalidate();

	-- invite party member visible check
	if summonsinfo:IsVisible() == 1 then
		frame:SetVisible(0);
		local button = GET_CHILD_RECURSIVELY(summonsinfo, "summonsinfobutton");
		local hotkey = summonsinfo:GetUserConfig("SUMMONINFO_HOTKEY_TEXT");
		if button ~= nil then
			button:SetVisible(1);
			if hotkey ~= nil and hotkey ~= "" then
				button:SetTextTooltip(ClMsg("SummonsInfo_ConvertPartyInfo_ToolTip").."( "..hotkey.." )");
			end
			button:EnableHitTest(1);
			CHANGE_BUTTON_TITLE(summonsinfo, ClMsg("SummonsInfo_SummonsInfo"));
			summonsinfo:Invalidate();
		end
	end
end
