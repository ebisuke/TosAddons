CHAT_SYSTEM("[DII]loaded")
function DICHAT_POPUP_OPEN(frame)
    local id=frame:GetUserValue("id")
    frame:SetTitleName(id)
	frame:Invalidate()
	local title=frame:GetChild("name")
	title:SetTextByKey("title",id)
	title:Invalidate()
    CHAT_SYSTEM("INIT")
    
    CREATE_DEF_CHAT_GROUPBOX(frame)
    DICHAT_ACQUIRE_NEWMESSAGE(frame)
	local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
	timer:SetUpdateScript("DICHAT_UPDATE");
	timer:Start(20);
end


function DICHAT_POPUP_CLOSE(frame)

	
end
function DICHAT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            if(frame==nil)then
                frame=ui.GetFrame("dichat")
            end
            frame:ShowWindow(0)
            DISCORDINTEGRATION_DBGOUT("initfrm")
            

           
            CHAT_SYSTEM("INIT")
        end,
        catch = function(error)
            DISCORDINTEGRATION_ERROUT(error)
        end
    }
end
function DICHAT_DO_CLOSE_CHATPOPUP(frame)
	
	frame:ShowWindow(0)

end

function DICHAT_ACQUIRE_NEWMESSAGE(frame)
    DICHAT_UPDATE(frame)
end

function DICHAT_UPDATE(frame)
    local id=frame:GetUserValue("id")


    diapi_reqb("/channels/"..id.."/messages","messages_"..id)
    ReserveScript(string.format("DICHAT_UPDATE_DELAY(\"%s\")",frame:GetName()),10)
end
function DICHAT_UPDATE_DELAY(framename)
	EBI_try_catch{
        try = function()
		local frame=ui.GetFrame(framename)
		local id=frame:GetUserValue("id")
		DISCORDINTEGRATION_DBGOUT("IN")
		local recv=diapi_reqrx("messages_"..id)
		if(recv==nil)then
			DISCORDINTEGRATION_DBGOUT("OUT")
			return
		end
		DISCORDINTEGRATION_DBGOUT("GO")
		DI_DRAW_CHAT_MSG("chatgbox_TOTAL",0,frame,recv)
		DISCORDINTEGRATION_DBGOUT("OK")
	end,
	catch = function(error)
		DISCORDINTEGRATION_ERROUT(error)
	end
	}
end

function DI_DRAW_CHAT_MSG(groupboxname, startindex, chatframe,messages)
	local mainchatFrame = ui.GetFrame("chatframe");
	local groupbox = GET_CHILD(chatframe, groupboxname);
	local size = #messages;

	DISCORDINTEGRATION_DBGOUT("1")
	if groupbox == nil then
		return 1;
	end
	DISCORDINTEGRATION_DBGOUT("2")
	if groupbox:IsVisible() == 0 or chatframe:IsVisible() == 0 then
		return 1;
	end
	DISCORDINTEGRATION_DBGOUT("3")
	local marginLeft = 20;
	local marginRight = 0;
	local ypos = 0;
	DISCORDINTEGRATION_DBGOUT("SIZ "..tostring(size))
	for i = startindex, size-1  do
		local ii=size-i-1
		
		local clusterinfo = messages[ii+1];
		if clusterinfo == nil then
			return 0;
		end
		
		local clustername = "cluster_" .. clusterinfo.id;

		local chatCtrl = GET_CHILD(groupbox, clustername);

		if i > 0 then
			local prevClusterInfo = messages[ii-1+1];
			if prevClusterInfo ~= nil then
				local precClusterName = "cluster_" .. prevClusterInfo.id;
				precCluster = GET_CHILD(groupbox, precClusterName);
				if precCluster ~= nil then
					ypos = precCluster:GetY() + precCluster:GetHeight();
				else
					-- ui가 다 날아갔는데, 메시지가 들어온 경우
					-- 재접할때 발생한다.
					return DI_DRAW_CHAT_MSG(groupboxname, 0, chatframe, messages);
				end
			end
		end

		local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX");

		if startindex == 0 and chatCtrl ~= nil then
			chatCtrl:SetOffset(marginLeft, ypos);

			local label = chatCtrl:GetChild('bg');
			local txt = GET_CHILD(chatCtrl, "text");
			local timeCtrl = GET_CHILD(chatCtrl, "time");

			RESIZE_CHAT_CTRL(groupbox, chatCtrl, label, txt, timeCtrl, offsetX);
		end
		DISCORDINTEGRATION_DBGOUT("4")
		if chatCtrl == nil then
			local msgType = "System";
			local commnderName = clusterinfo.author.username;

			local fontSize = GET_CHAT_FONT_SIZE();
			local tempfontSize = string.format("{s%s}", fontSize);
			DISCORDINTEGRATION_DBGOUT(clustername)
			chatCtrl = groupbox:CreateOrGetControlSet('chatTextVer', clustername, ui.LEFT, ui.TOP, marginLeft, ypos , marginRight, 1);

			chatCtrl:EnableHitTest(1);
			chatCtrl:EnableAutoResize(true,false);
		
			if commnderName ~= GETMYFAMILYNAME() then
				chatCtrl:SetSkinName("")
			end
			local commnderNameUIText = commnderName .. " : "
			
			local label = chatCtrl:GetChild('bg');
			local txt = GET_CHILD(chatCtrl, "text");
			local timeCtrl = GET_CHILD(chatCtrl, "time");

			local msgFront = "";
			local msgString = "";	
			local fontStyle = nil;
		
			label:SetAlpha(0);


            fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_GUILD");
            msgFront = string.format("[%s]%s", "DI", commnderNameUIText);	


			local tempMsg = clusterinfo.content

            msgString = string.format("%s%s{nl}",msgFront, tempMsg);		


			msgString = string.format("%s{/}", msgString);	
			txt:SetTextByKey("font", fontStyle);				
			txt:SetTextByKey("size", fontSize);				
			txt:SetTextByKey("text", CHAT_TEXT_LINKCHAR_FONTSET(mainchatFrame, msgString));

			timeCtrl:SetTextByKey("time", clusterinfo.timestamp);

			local slflag = string.find(clusterinfo.content,'a SL%a')
			if slflag == nil then
				txt:EnableHitTest(0)
			else
				txt:EnableHitTest(1)
			end
		
			RESIZE_CHAT_CTRL(groupbox, chatCtrl, label, txt, timeCtrl, offsetX);
		end																									
	end

	local scrollend = false
	if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
		scrollend = true;
	end

	local beforeLineCount = groupbox:GetLineCount();	
	groupbox:UpdateData();
	
	local afterLineCount = groupbox:GetLineCount();
	local changedLineCount = afterLineCount - beforeLineCount;
	local curLine = groupbox:GetCurLine();

	if (config.GetXMLConfig("ToggleBottomChat") == 1) or (scrollend == true) then
		groupbox:SetScrollPos(99999);
	else 
		groupbox:SetScrollPos(curLine + changedLineCount);
	end

	local gboxtype = string.sub(groupboxname,string.len("chatgbox_") + 1)
	local tonumberret = tonumber(gboxtype)

    if tonumberret ~= nil and tonumberret > MAX_CHAT_CONFIG_VALUE then
		UPDATE_READ_FLAG_BY_GBOX_NAME("chatgbox_" .. gboxtype)
	end

	return 1;
end
