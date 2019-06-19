function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local cols = 8
local rows = 8
MCMAGNUMOPUS_LIFTICON = nil
MCMAGNUMOPUS_BUTTONPRESS = 0
MCMAGNUMOPUS_FIREDSLOT = {}
function MCMAGNUMOPUS_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            if (OLD_CHECK_INV_LBTN == nil) then
                OLD_CHECK_INV_LBTN = CHECK_INV_LBTN
                CHECK_INV_LBTN = MCMAGNUMOPUS_CHECK_INV_LBTN_JUMPER
            end
            if (OLD_PUZZLECRAFT_DROP == nil) then
                OLD_PUZZLECRAFT_DROP = PUZZLECRAFT_DROP
                PUZZLECRAFT_DROP = MCMAGNUMOPUS_PUZZLECRAFT_DROP
            end
            if (OLD_PUZZLECRAFT_OPEN == nil) then
                OLD_PUZZLECRAFT_OPEN = PUZZLECRAFT_OPEN
                PUZZLECRAFT_OPEN = MCMAGNUMOPUS_PUZZLECRAFT_OPEN_JUMPER
            end
            if (OLD_PUZZLECRAFT_SLOT_RBTN == nil ) then
                OLD_PUZZLECRAFT_SLOT_RBTN = PUZZLECRAFT_SLOT_RBTN;
                PUZZLECRAFT_SLOT_RBTN = MCMAGNUMOPUS_PUZZLECRAFT_SLOT_RBTN
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }


end

function MCMAGNUMOPUS_CHECK_INV_LBTN_JUMPER(frame, slot, invItem, customFunc, scriptArg, count)
    MCMAGNUMOPUS_CHECK_INV_LBTN(frame, slot, invItem, customFunc, scriptArg, count)
end
function MCMAGNUMOPUS_ISLARGEDISPLAY()
    if (option.GetClientWidth() >= 3000) then
        return 1
    else
        return 0
    end
end
function MCMAGNUMOPUS_CHECK_INV_LBTN(frame, slot, invItem, customFunc, scriptArg, count)
    EBI_try_catch{
        try = function()
            if (OLD_CHECK_INV_LBTN ~= nil) then
                OLD_CHECK_INV_LBTN(frame, slot, invItem, customFunc, scriptArg, count)
            end
            if (ui.GetFrame("puzzlecraft"):IsVisible() == 1) then
                ui.CancelLiftIcon()
                MCMAGNUMOPUS_LIFTICON = slot:GetIcon()
                if (MCMAGNUMOPUS_LIFTICON ~= nil) then
                    MCMAGNUMOPUS_CLEARMOUSESTATE()
                    MCMAGNUMOPUS_BEGINMOUSEMOVE(MCMAGNUMOPUS_LIFTICON)
                end
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function MCMAGNUMOPUS_PUZZLECRAFT_SLOT_RBTN(parent, ctrl)
--noop
end
function MCMAGNUMOPUS_BEGINMOUSEMOVE(icon)
    local framemc = ui.GetFrame("mcmagnumopus")
    local mccursor = GET_CHILD(framemc, "item", "ui::CSlot")
    
    local invItem = GET_PC_ITEM_BY_GUID(icon:GetInfo():GetIESID())
    local invObj = GetIES(invItem:GetObject());
    mccursor:ClearIcon()
    local dup = CreateIcon(mccursor)
    dup:SetImage(GET_ITEM_ICON_IMAGE(invObj));
    
    --framemc:ShowWindow(1)
    framemc:SetLayerLevel(999)
    
    local mctimer = GET_CHILD(framemc, "addontimer", "ui::CAddOnTimer")
    mctimer:SetUpdateScript("MCMAGNUMOPUS_TRACING")
    mctimer:Start(0.01)
end
function MCMAGNUMOPUS_CLEARMOUSESTATE()
    MCMAGNUMOPUS_BUTTONPRESS = 0
    local framemc = ui.GetFrame("mcmagnumopus")
    framemc:ShowWindow(0)
    local mccursor = GET_CHILD(framemc, "item", "ui::CSlot")
    mccursor:ClearIcon()
    local mctimer = GET_CHILD(framemc, "addontimer", "ui::CAddOnTimer")
    mctimer:Stop()
    for _, v in ipairs(MCMAGNUMOPUS_FIREDSLOT) do
        if (v:GetUserIValue("SELECTED") == 0) then
            --CHECK_NEW_PUZZLE(ui.GetFrame("puzzlecraft"),v)
        end
    end
    MCMAGNUMOPUS_FIREDSLOT = {}
end
function MCMAGNUMOPUS_PUZZLECRAFT_DROP()
--nope
end
function MCMAGNUMOPUS_PUZZLECRAFT_OPEN_JUMPER(frame)
    MCMAGNUMOPUS_PUZZLECRAFT_OPEN(frame)
end
function MCMAGNUMOPUS_PUZZLECRAFT_OPEN(frame)
    EBI_try_catch{
        try = function()
            OLD_PUZZLECRAFT_OPEN(frame)
            local slotset = GET_CHILD_RECURSIVELY(frame, "slotset", "ui::CSlotSet")
            --やかましい音を消す
            for i = 0, rows - 1 do
                for j = 0, cols - 1 do
                    local slot = slotset:GetSlotByRowCol(i, j)
                    slot:SetOverSound("")
                    slot:EnableDrag(0)
                    slot:EnableDrop(0)
                    slot:SetEventScript(ui.LBUTTONDOWN, "MCMAGNUMOPUS_ON_PICKUP")
                    slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, 0)
                    slot:SetEventScript(ui.RBUTTONDOWN, "MCMAGNUMOPUS_ON_PICKUP")
                    slot:SetEventScriptArgNumber(ui.RBUTTONDOWN, 1)
                end
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function MCMAGNUMOPUS_ON_PICKUP(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("puzzlecraft")
            --選択されているスロットを取得
            local slotset = GET_CHILD_RECURSIVELY(frame, "slotset", "ui::CSlotSet")
            local slotpos = MCMAGNUMOPUS_CALCMOUSEPOSTOSLOTPOS()
            if (MCMAGNUMOPUS_ISVALIDSLOTPOS(slotpos)) then
                local slot = slotset:GetSlotByRowCol(slotpos.y, slotpos.x)
                --スロットの情報を取得
                local icon = slot:GetIcon()
                if (icon ~= nil) then
                    MCMAGNUMOPUS_BEGINMOUSEMOVE(icon)
                    --左クリックなら消す
                    if (argnum == 0) then
                        CLEAR_SLOT_ITEM_INFO(slot);
                        --レシピブレイク検証
                        if true == CHECK_COMBINATION_BREAK(frame) then
                            UPDATE_PUZZLECRAFT_TARGETS();
                        end
                    end
                end
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function MCMAGNUMOPUS_TRACING()
    EBI_try_catch{
        try = function()
            
            if mouse.IsLBtnPressed() == 1 or mouse.IsRBtnPressed() == 1 then
                if (MCMAGNUMOPUS_BUTTONPRESS == 0) then
                    MCMAGNUMOPUS_BUTTONPRESS = 1
                end
            
            else
                if (MCMAGNUMOPUS_BUTTONPRESS == 1) then
                    MCMAGNUMOPUS_BUTTONPRESS = 2
                end
            end
            if mouse.IsLBtnPressed() == 0 then
                if (MCMAGNUMOPUS_BUTTONPRESS == 3) then
                    
                    MCMAGNUMOPUS_CLEARMOUSESTATE()
                
                end
            else
                if (MCMAGNUMOPUS_BUTTONPRESS == 2) then
                    MCMAGNUMOPUS_BUTTONPRESS = 3
                end
                if (MCMAGNUMOPUS_BUTTONPRESS == 3) then
                    MCMAGNUMOPUS_ONPRESSED()
                end
            end
            if (mouse.IsRBtnPressed() == 1 and MCMAGNUMOPUS_BUTTONPRESS == 2) then
                MCMAGNUMOPUS_ONPRESSED()
            end
            if keyboard.IsKeyPressed("ESCAPE") == 1 then
                MCMAGNUMOPUS_CLEARMOUSESTATE()
            
            end
            MCMAGNUMOPUS_TRACING_DELAY()
        --ReserveScript("MCMAGNUMOPUS_TRACING_DELAY()",0.01)
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function MCMAGNUMOPUS_CALCMOUSEPOSTOSLOTPOS()
    local framemc = ui.GetFrame("mcmagnumopus")
    local mccursor = GET_CHILD(framemc, "item", "ui::CSlot")
    local icon = mccursor:GetIcon()
    local pos = {x = mouse.GetX() / (MCMAGNUMOPUS_ISLARGEDISPLAY() + 1) - 30, y = mouse.GetY() / (MCMAGNUMOPUS_ISLARGEDISPLAY() + 1) - 30}
    
    --スロットの範囲内？
    local framepz = ui.GetFrame("puzzlecraft")
    local gbox = GET_CHILD_RECURSIVELY(framepz, "bg", "ui::CGroupBox")
    local slots = GET_CHILD_RECURSIVELY(framepz, "slotset", "ui::CSlotSet")
    
    local siz = slots:GetWidth() / cols
    
    --どのスロット？
    local slotpos = {
        x = (pos.x - framepz:GetX() - gbox:GetX() - slots:GetX() + 30) / siz,
        y = (pos.y - framepz:GetY() - gbox:GetY() - slots:GetY() + 30) / siz,
    }
    return slotpos
end
function MCMAGNUMOPUS_ISVALIDSLOTPOS(slotpos)
    
    if (slotpos.x < 0 or slotpos.y < 0 or slotpos.x >= cols or slotpos.y >= rows) then
        --give up
        return false
    end
    return true
end
function MCMAGNUMOPUS_ONPRESSED()
    local framemc = ui.GetFrame("mcmagnumopus")
    local mccursor = GET_CHILD(framemc, "item", "ui::CSlot")
    local icon = MCMAGNUMOPUS_LIFTICON
    
    --スロットの範囲内？
    local framepz = ui.GetFrame("puzzlecraft")
    local gbox = GET_CHILD_RECURSIVELY(framepz, "bg", "ui::CGroupBox")
    local slots = GET_CHILD_RECURSIVELY(framepz, "slotset", "ui::CSlotSet")
    
    
    --どのスロット？
    local slotpos = MCMAGNUMOPUS_CALCMOUSEPOSTOSLOTPOS()
    if (not MCMAGNUMOPUS_ISVALIDSLOTPOS(slotpos)) then
        --give up
        return
    end
    --fill
    local slot = slots:GetSlotByRowCol(slotpos.y, slotpos.x)
    if (slot) then
        local curricon = slot:GetIcon()
        if (icon ~= nil) then
            local iconInfo = icon:GetInfo();
            local guid = iconInfo:GetIESID();
            if (curricon ~= nil) then
                if (curricon:GetInfo():GetIESID() == guid) then
                    -- 同じアイテムは何もしない
                    return
                end
            end
            
            if (slot:IsEnable() == 0) then
                --それは使用できない
                return
            end
            local invItem = GET_ITEM_BY_GUID(guid);
            SET_SLOT_INVITEM(slot, invItem);
            
            slot:SetText("", 'count', ui.RIGHT, ui.BOTTOM, -2, 1);
            slot:Invalidate()
            
            MCMAGNUMOPUS_CHECK_NEW_PUZZLE(ui.GetFrame("puzzlecraft"), slot)
            --MCMAGNUMOPUS_FIREDSLOT[#MCMAGNUMOPUS_FIREDSLOT + 1] = slot
            CHECK_NEW_PUZZLE(ui.GetFrame("puzzlecraft"), slot);
        end
    end
end
function MCMAGNUMOPUS_TRACING_DELAY()
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame("mcmagnumopus")
            frame:SetOffset(
                mouse.GetX() / (MCMAGNUMOPUS_ISLARGEDISPLAY() + 1) - 30,
                mouse.GetY() / (MCMAGNUMOPUS_ISLARGEDISPLAY() + 1) - 30)
            if (frame:IsVisible() == 0) then
                frame:ShowWindow(1)
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end

function MCMAGNUMOPUS_CHECK_NEW_PUZZLE(frame, checkSlot)

	frame = frame:GetTopParentFrame();
	geItemPuzzle.ClearPuzzleInfo();

	local checkRow = 0;
	local checkCol = 0;
	local bg = frame:GetChild("bg");
	local slotset = GET_CHILD(bg, "slotset", "ui::CSlotSet");
	for i = 0 , slotset:GetSlotCount() - 1 do
		local slot = slotset:GetSlotByIndex(i);
		local icon = slot:GetIcon();
		if icon ~= nil then
			if slot:GetUserIValue("SELECTED") == 0 then
				local iconInfo = icon:GetInfo();
				local row = math.floor(i / slotset:GetCol());
				local col = math.mod(i, slotset:GetCol());
				geItemPuzzle.AddPuzzleInfo(row, col, iconInfo.type);

				if checkSlot == slot then
					checkRow = row;
					checkCol = col;
				end
			end
		end
	end
	
	local ret = geItemPuzzle.CheckNewPuzzleInfo(checkRow, checkCol);
	if ret ~= nil then
		local tgt = ret.info:GetTargetItemName();

		local scpString = string.format("SELECT_PUZZLECRAFT_TARGET(%d, %d, %d)", ret.info.classID, ret.row, ret.col)
		local destItem = GetClass("Item", ret.info:GetTargetItemName());
		local msgString = ClMsg("WouldYouSelectThisCombinationAsAlchemystryTarget?");
		msgString = msgString.. "{nl}" ..ClMsg("TargetItem") .. " : " ;
		msgString = msgString .. string.format("{img %s %d %d}%s", destItem.Icon, 40, 40, destItem.Name);
        --ui.MsgBox(msgString, scpString, "None");
        SELECT_PUZZLECRAFT_TARGET( ret.info.classID, ret.row, ret.col)
		MCMAGNUMOPUS_FIREDSLOT[#MCMAGNUMOPUS_FIREDSLOT+1]=checkSlot
	end

	-- if true == CHECK_COMBINATION_BREAK(frame) then
	-- 	UPDATE_PUZZLECRAFT_TARGETS();
	-- end
end