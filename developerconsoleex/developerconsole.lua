local acutil = require("acutil");
DEVELOPERCONSOLE_SETTINGS={
	history={}
}
DEVELOPERCONSOLE_SETTINGSLOCATION = string.format('../addons/%s/settings.json', "developerconsole")
DEVELOPERCONSOLE_KEYDOWNFLAG = false
DEVELOPERCONSOLE_CURSOR = 0

function DEVELOPERCONSOLE_ON_INIT(addon, frame)
	acutil.slashCommand("/dev", DEVELOPERCONSOLE_TOGGLE_FRAME);
	acutil.slashCommand("/console", DEVELOPERCONSOLE_TOGGLE_FRAME);
	acutil.slashCommand("/devconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);
	acutil.slashCommand("/developerconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);

	acutil.setupHook(DEVELOPERCONSOLE_PRINT_TEXT, "print");
	acutil.addSysIcon('developerconsole', 'sysmenu_sys', 'developerconsole', 'DEVELOPERCONSOLE_TOGGLE_FRAME')
	if not DEVELOPERCONSOLE_SETTINGSLOADED then
		local t, err = acutil.loadJSON(DEVELOPERCONSOLE_SETTINGSLOCATION, DEVELOPERCONSOLE_SETTINGS)
		if err then
			--設定ファイル読み込み失敗時処理
			CHAT_SYSTEM(string.format('[%s] cannot load setting files', "developerconsole"))
		else
			--設定ファイル読み込み成功時処理
			DEVELOPERCONSOLE_SETTINGS = t
		end
		DEVELOPERCONSOLE_SETTINGSLOADED = true
	end

	CLEAR_CONSOLE();
end
function DEVELOPERCONSOLE_SAVE_SETTINGS()

    acutil.saveJSON(DEVELOPERCONSOLE_SETTINGSLOCATION, DEVELOPERCONSOLE_SETTINGS)
end
function DEVELOPERCONSOLE_TOGGLE_FRAME()
	ui.ToggleFrame("developerconsole");
end

function DEVELOPERCONSOLE_OPEN()
	local frame = ui.GetFrame("developerconsole");
	local textViewLog = frame:GetChild("textview_log");
	textViewLog:ShowWindow(1);

	local devconsole = ui.GetFrame("developerconsole");
	devconsole:ShowTitleBar(0);
	--devconsole:ShowTitleBarFrame(1);
	devconsole:ShowWindow(0);
	devconsole:SetSkinName("chat_window");
	devconsole:ShowWindow(1);
	--devconsole:Resize(800, 500);

	local input = devconsole:GetChild("input");
	if input ~= nil then
		input:Move(0, 0);
		input:SetOffset(10, 450);
		--input:ShowWindow(1);
		--input:Resize(675, 40);
		--input:SetGravity(ui.LEFT, ui.CENTER);
	end

	local executeButton = devconsole:GetChild("execute");
	if executeButton ~= nil then
		--executeButton:Resize(100, 40);
		executeButton:SetOffset(690, 450);
		executeButton:SetText("Execute");
	end

	local debugUIButton = devconsole:GetChild("debugUI");
	if debugUIButton ~= nil then
		--debugUIButton:Resize(100, 40);
		debugUIButton:SetOffset(690, 405);
		debugUIButton:SetText("Debug UI");
	end

	local clearButton = devconsole:GetChild("clearConsole");
	if clearButton ~= nil then
		clearButton:Resize(100, 40);
		clearButton:SetOffset(690, 360);
		clearButton:SetText("Clear");
	end

	local textlog = devconsole:GetChild("textview_log");
	if textlog ~= nil then
		--textlog:Resize(675, 435);
		textlog:SetOffset(10, 10);
	end

	devconsole:Invalidate();

	--ui.SysMsg("input: " .. input:GetX() .. " " .. input:GetY() .. " " .. input:GetWidth() .. " " .. input:GetHeight());
	--ui.SysMsg("execute: " .. executeButton:GetX() .. " " .. executeButton:GetY() .. " " .. executeButton:GetWidth() .. " " .. executeButton:GetHeight());
	--ui.SysMsg("debugUI: " .. debugUIButton:GetX() .. " " .. debugUIButton:GetY() .. " " .. debugUIButton:GetWidth() .. " " .. debugUIButton:GetHeight());
	--ui.SysMsg("textlog: " .. textlog:GetX() .. " " .. textlog:GetY() .. " " .. textlog:GetWidth() .. " " .. textlog:GetHeight());
	local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
	timer:SetUpdateScript("DEVELOPERCONSOLE_UPDATE");
	timer:Start(0.01);
end

function DEVELOPERCONSOLE_CLOSE()
	local frame = ui.GetFrame("developerconsole");
	if(frame~=nil)then
		local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
		timer:Stop();
	end
end

function TOGGLE_UI_DEBUG()
	debug.ToggleUIDebug();
end

function CLEAR_CONSOLE()
	local frame = ui.GetFrame("developerconsole");

	if frame ~= nil then
		local textlog = frame:GetChild("textview_log");

		if textlog ~= nil then
			tolua.cast(textlog, "ui::CTextView");
			textlog:Clear();
			textlog:AddText("Developer Console", "white_16_ol");
			textlog:AddText("Enter command and press execute!", "white_16_ol");
		end
	end
end

function DEVELOPERCONSOLE_PRINT_TEXT(text)
	if text == nil or text == "" then
		return;
	end

	local frame = ui.GetFrame("developerconsole");
	local textlog = frame:GetChild("textview_log");

	if textlog ~= nil then
		tolua.cast(textlog, "ui::CTextView");
		textlog:AddText(text, "white_16_ol");
	end
end
function DEVELOPERCONSOLE_UPDATE(frame)
	local doupdate=nil

	if(DEVELOPERCONSOLE_KEYDOWNFLAG==false)then
		if 1 == keyboard.IsKeyPressed("UP") then
			--previous
			if(DEVELOPERCONSOLE_CURSOR<(#DEVELOPERCONSOLE_SETTINGS.history-1))then
				DEVELOPERCONSOLE_CURSOR = DEVELOPERCONSOLE_CURSOR+1
			end
			doupdate=DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history-DEVELOPERCONSOLE_CURSOR]
			
			
			DEVELOPERCONSOLE_KEYDOWNFLAG=true
		elseif  1 == keyboard.IsKeyPressed("DOWN") then

			--new
			if(DEVELOPERCONSOLE_CURSOR>0)then
				DEVELOPERCONSOLE_CURSOR = DEVELOPERCONSOLE_CURSOR-1
			end

			doupdate=DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history-DEVELOPERCONSOLE_CURSOR]
			
			DEVELOPERCONSOLE_KEYDOWNFLAG=true
		end
		if(doupdate~=nil)then

			local textlog = frame:GetChild("textview_log");
			local editbox = frame:GetChild("input");
			tolua.cast(editbox, "ui::CEditControl");
			editbox:SetText(doupdate)
			
		end
	else
		if 1 == keyboard.IsKeyPressed("UP") then

		elseif  1 == keyboard.IsKeyPressed("DOWN") then

		else
			DEVELOPERCONSOLE_KEYDOWNFLAG=false
		end
	end
end
function DEVELOPERCONSOLE_ENTER_KEY(frame, control, argStr, argNum)
	local textlog = frame:GetChild("textview_log");

	if textlog ~= nil then
		tolua.cast(textlog, "ui::CTextView");

		local editbox = frame:GetChild("input");

		if editbox ~= nil then
			tolua.cast(editbox, "ui::CEditControl");
			local commandText = editbox:GetText();

			if commandText ~= nil and commandText ~= "" then
				DEVELOPERCONSOLE_IGNORE_FLAG=false
				local s = "[Execute] " .. commandText;
				textlog:AddText(s, "white_16_ol");
				local f = assert(loadstring(commandText));
				local status, error = pcall(f);

				if not status then
					textlog:AddText(tostring(error), "white_16_ol");
				end
				if(DEVELOPERCONSOLE_IGNORE_FLAG==false)then
					if(#DEVELOPERCONSOLE_SETTINGS.history == 0 or DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history]~=commandText)then
						DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history+1]=commandText
					end
				end
				DEVELOPERCONSOLE_CURSOR=0
				DEVELOPERCONSOLE_SAVE_SETTINGS()
			end
		end
	end
end
function dev_history()
	for i = 1 , #DEVELOPERCONSOLE_SETTINGS.history do
		print(DEVELOPERCONSOLE_SETTINGS.history[i])
	end
end