local addonName = "RAIDWARPRELOADED"
local author = "XINXS"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.settings = {x = 500, y = 50, mini = 0, isclose = 0};
local settingsFileLoc = string.format("%s/settings.json", string.lower(addonName));
local RList = { Moring = 522, Witch = 620, Giltine = 628, Vasilisa = 655,Delmore=665};
local acutil = require('acutil');

local function spairs(t, order)
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function RAIDWARP_LOAD()
	local t, err = acutil.loadJSONX(settingsFileLoc);
	if not err then
		g.settings = t;
	end
end

function RAIDWARP_ON_INIT(addon, frame)
	RAIDWARP_LOAD();
	RAIDWARP_OPENFRAME();
	frame:SetEventScript(ui.LBUTTONUP, "RAIDWARP_MOVEFRAME");
	acutil.slashCommand("/rw",RAIDWARP_CMD);
	acutil.slashCommand("/RW",RAIDWARP_CMD);
end

function RAIDWARP_CMD(command)
	local cmd = "";
	if #command > 0 then
		cmd = table.remove(command, 1);
	else
		g.settings.isclose = 0;
		acutil.saveJSONX(settingsFileLoc, g.settings);
		RAIDWARP_OPENFRAME();
		return
	end
	for k,v in pairs(RList) do
		if string.lower(cmd) == string.lower(k) then
			RAIDWARP_WARP(v);
			return
		end
	end
	if string.lower(cmd) == "boruta" then
		RAIDWARP_BORUTABTN();
		return
	end
	if string.lower(cmd) == "help" then
		RAIDWARP_HELP();
		return
	end
	return
end

function RAIDWARP_WARP(id)
	local pc = GetMyPCObject();
    
	if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
		ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
		return
	end

	if world.GetLayer() ~= 0 then
		ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
		return;
	end

	local curMap = GetClass('Map', session.GetMapName());
	local mapType = TryGetProp(curMap, 'MapType');
	if mapType == 'Dungeon' then
		ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
		return;
	end
	
    control.CustomCommand('MOVE_TO_ENTER_NPC', id, 0, 0);
end

function RAIDWARP_OPENFRAME()
	local frame = ui.GetFrame("raidwarp");
	local tbutton = frame:CreateOrGetControl('button', 'close', 88, 2, 24, 24);
	tbutton = frame:CreateOrGetControl('button', 'help', 111, 2, 24, 24);
	tbutton = frame:CreateOrGetControl('button', 'minimize', 135, 2, 24, 24);
	if g.settings.isclose == 1 then
		frame:ShowWindow(0);
		return
	else
		frame:ShowWindow(1);
	end
	if g.settings.mini == 1 then
		frame:Resize(160,32);
		frame:SetOffset(g.settings.x, g.settings.y);
		return
	else
		frame:Resize(160,230);
	end
	frame:SetOffset(g.settings.x, g.settings.y);
	local i = 0;
	for k, v in spairs(RList, function(t,a,b) return t[a] < t[b] end) do
		local rbg = frame:CreateOrGetControl('groupbox', k..'bg', 5, (36 + i*31), 150, 30);
		rbg:SetSkinName('systemmenu_vertical');
		local rtext = rbg:CreateOrGetControl('richtext', k..'text', 5, 6, 95, 30);
		rtext:SetText("{ol}" .. k);
		local rbutton = rbg:CreateOrGetControl('button', k..'btn', 102, 2, 41, 30);
		rbutton:SetSkinName("test_red_button");
		rbutton:SetText("{ol}Warp");
		rbutton:SetEventScript(ui.LBUTTONUP,"RAIDWARP_WARPBTN");
		rbutton:SetEventScriptArgNumber(ui.LBUTTONUP, v);
		i = i + 1;
	end
	--boruta
	local rbg = frame:CreateOrGetControl('groupbox', 'Borutabg', 5, (36 + i*31), 150, 30);
	rbg:SetSkinName('systemmenu_vertical');
	local rtext = rbg:CreateOrGetControl('richtext', 'Borutatext', 5, 6, 95, 30);
	rtext:SetText("{ol}" .. "Boruta");
	local rbutton = rbg:CreateOrGetControl('button', 'Borutabtn', 102, 2, 41, 30);
	rbutton:SetSkinName("test_red_button");
	rbutton:SetText("{ol}Warp");
	rbutton:SetEventScript(ui.LBUTTONUP,"RAIDWARP_BORUTABTN");
end

function RAIDWARP_WARPBTN(parent, FromctrlSet, argStr, argNum)
	RAIDWARP_WARP(argNum)
end

function RAIDWARP_BORUTABTN(parent, FromctrlSet, argStr, argNum)
	local indunCls = GetClass('GuildEvent', 'GM_BorutosKapas_1');
	if indunCls ~= nil then
		local indunClsID = TryGetProp(indunCls, 'ClassID', 0);
		_BORUTA_ZONE_MOVE_CLICK(indunClsID);
	end
end

function RAIDWARP_MINIMIZE()
	local frame = ui.GetFrame('raidwarp');
	
	if g.settings.mini == 0 then
		g.settings.mini = 1;
		RAIDWARP_OPENFRAME()
	else
		g.settings.mini = 0;
		RAIDWARP_OPENFRAME()
	end
	acutil.saveJSONX(settingsFileLoc, g.settings);
end

function RAIDWARP_CLOSEFRAME()
	local frame = ui.GetFrame('raidwarp');
	g.settings.isclose = 1;
	frame:ShowWindow(0);
	acutil.saveJSONX(settingsFileLoc, g.settings);
end

function RAIDWARP_MOVEFRAME()
	local frame = ui.GetFrame("raidwarp");
	g.settings.x = frame:GetX();
	g.settings.y = frame:GetY();
	acutil.saveJSONX(settingsFileLoc, g.settings);
end

function RAIDWARP_HELP()
	local text = "";
	text = "{s18}/rw{/}{/}{nl} {s16}Open Frame{nl} {nl}";
	text = text .. "{s18}/rw ET{/}{nl} {s16}Earth Tower(Istora Ruins){nl} {nl}";
	text = text .. "{s18}/rw Velcoffer{/}{nl} {s16}Velcoffer Nest (Tevhrin Stalactite 5){nl} {nl}";
	text = text .. "{s18}/rw Skiaclipse{/}{nl} {s16}Tomb of the White Crow (Rasvoy Lake){nl} {nl}";
	text = text .. "{s18}/rw Moring{/}{nl} {s16}Lepidoptera Junction (Stele Road){nl} {nl}";
	text = text .. "{s18}/rw Witch{/}{nl} {s16}White Witchs Forest (Stogas Plateau){nl} {nl}";
	text = text .. "{s18}/rw Giltine{/}{nl} {s16}Demonic Sanctuary (Pradzia Temple){nl} {nl}";
	text = text .. "{s18}/rw Vasilisa{/}{nl} {s16}Saints Sacellum (Woods of the Linked Bridges){nl} {nl}";
	text = text .. "{s18}/rw Boruta{/}{nl} {s16}Battle in Sulivinas Lair(Vedas Plateau)";
	text = text .. "{s18}/rw Delmore{/}{nl} {s16}Battle in Delmore(Delmore Garden)";
	return ui.MsgBox(text,"","Nope");
end