function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function POSTBOXGETITEMFIXER_OPEN_BARRACK_SELECT_PC_FRAME_JUMPER(execScriptName, msgKey, selectMyPC)
    
    
    return POSTBOXGETITEMFIXER_OPEN_BARRACK_SELECT_PC_FRAME(execScriptName, msgKey, selectMyPC)
end
--ここでフック
if OLD_OPEN_BARRACK_SELECT_PC_FRAME == nil and OLD_OPEN_BARRACK_SELECT_PC_FRAME ~= POSTBOXGETITEMFIXER_OPEN_BARRACK_SELECT_PC_FRAME_JUMPER then
    OLD_OPEN_BARRACK_SELECT_PC_FRAME = OPEN_BARRACK_SELECT_PC_FRAME
    OPEN_BARRACK_SELECT_PC_FRAME = POSTBOXGETITEMFIXER_OPEN_BARRACK_SELECT_PC_FRAME_JUMPER
end


function POSTBOXGETITEMFIXER_ON_INIT(addon, frame)


end

function POSTBOXGETITEMFIXER_OPEN_BARRACK_SELECT_PC_FRAME(execScriptName, msgKey, selectMyPC)
    return EBI_try_catch{
        try = function()
            local bcframe=ui.GetFrame("barrack_charlist")
            
            local scrollBox = bcframe:GetChild("scrollBox");
            local selectFrame = ui.GetFrame("postbox_itemget");
            selectFrame:ShowWindow(1);
            selectFrame:SetUserValue("EXECSCRIPT", execScriptName);
            local txt = selectFrame:GetChild("txt");
            txt:SetTextByKey("value", ScpArgMsg(msgKey));
            
            local gbox_charlist = selectFrame:GetChild("gbox_charlist");
            gbox_charlist:RemoveAllChild();
            local accountInfo = session.barrack.GetMyAccount();

	        local accountInfo = session.barrack.GetMyAccount();
            

            local cnt = accountInfo:GetPCCount();
            --for i = 0, cnt - 1 do
            for i=0, scrollBox:GetChildCount()-1 do
                local child = scrollBox:GetChildByIndex(i);        
                if string.find(child:GetName(), 'char_') ~= nil then
                    local guid = child:GetUserValue("CID");
                    --local pcInfo = accountInfo:GetPCByIndex(i);
                    local pcInfo=session.barrack.GetMyAccount():GetByStrCID(guid);
                    local addControlSet = true;
                    if selectMyPC == false then
                        local mySession = session.GetMySession();
                        if pcInfo:GetCID() == mySession:GetCID() then
                            addControlSet = false;
                        end
                    end
                    
                    if addControlSet == true then
                        local ctrlSet = gbox_charlist:CreateControlSet("postbox_itemget", "PIC_" .. i, ui.LEFT, ui.TOP, 0, 0, 0, 0);
                        ctrlSet:SetOverSound('button_cursor_over_3');
                        ctrlSet:SetClickSound('button_click_big');
                        ctrlSet:ShowWindow(1);
                        
                        local pcApc = pcInfo:GetApc();
                        local headIconName = ui.CaptureModelHeadImageByApperance(pcApc);
                        local pic = GET_CHILD(ctrlSet, "pic");
                        pic:SetImage(headIconName);
                        local name = ctrlSet:GetChild("name");
                        local jobCls = GetClassByType("Job", pcInfo:GetRepID());
                        local nameText = string.format("%s{nl}{@st66}%s", pcApc:GetName(), GET_JOB_NAME(jobCls, pcApc:GetGender()));
                        ctrlSet:SetUserValue("PC_NAME", pcApc:GetName());
                        name:SetTextByKey("value", nameText);
                        
                        ctrlSet:SetEventScript(ui.LBUTTONUP, "SELECT_POSTBOX_ITEM_PC");
                    end
                end
            end
            
            GBOX_AUTO_ALIGN(gbox_charlist, 0, 1, 0, true, false);
            return selectFrame;
        end,
		catch = function(error)
			ui.MsgBox(error);
		end
	}
end
