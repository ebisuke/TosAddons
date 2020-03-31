-- local acutil = require('acutil');

local label = {
	["PATK"]      = {name="物理攻撃: "   ;ename="PATK: "     ;kname="　　　물리 공격력 : " ;};
	["PATK_SUB"]  = {name="補助攻撃: "   ;ename="PATK_SUB: " ;kname="  보조 물리 공격력 : ";};
	["MATK"]      = {name="魔法攻撃: "   ;ename="MATK: "     ;kname="　　　마법 공격력 : " ;};
	["EATK"]      = {name="属性攻撃: "   ;ename="EATK: "     ;kname="　　　속성 공격력 : " ;};
	["CRTHR"]     = {name="クリ発　: "   ;ename="CRTHR: "    ;kname="　　　치명타 발생 : " ;};
	["CRTATK"]    = {name="物理クリ: "   ;ename="CRTATK: "   ;kname="　   치명타 공격력 : ";};
	["CRTMATK"]   = {name="魔法クリ: "   ;ename="CRTMATK: "  ;kname="　   치명타 공격력 : ";};
	["HEAL_PWR"]  = {name="治癒力　: "   ;ename="HEAL_PWR: " ;kname="　　　　　　  치유 : ";};
	["HR"]        = {name="命中　　: "   ;ename="HR: "       ;kname="　　　　　　  명중 : ";};
	["BLK_BREAK"] = {name="ブロ貫通: "   ;ename="BLK_BREAK: ";kname="　　　　블럭 관통 : " ;};
	["SR"]        = {name="ＡＯＥ　: "   ;ename="SR: "       ;kname="  　광역 공격 비율 : ";};
	["DEF"]       = {name="物理防御: "   ;ename="DEF: "      ;kname="　　　물리 방어력 : " ;};
	["MDEF"]      = {name="魔法防御: "   ;ename="MDEF: "     ;kname="　　　마법 방어력 : " ;};
	["DR"]        = {name="回避　　: "   ;ename="DR: "       ;kname="　　　　　 　 회피 : ";};
	["BLK"]       = {name="ブロック: "   ;ename="BLK: "      ;kname="　　　　　　  블럭 : ";};
	["CRTDR"]     = {name="クリ抵抗: "   ;ename="CRTDR: "    ;kname="　　   치명타 저항 : ";};
	["SDR"]       = {name="広域防御: "   ;ename="SDR: "      ;kname="  　광역 방어 비율 : ";};
	["RHP"]       = {name="ＨＰ回復: "   ;ename="RHP: "      ;kname="　　　   HP 회복력 : ";};
	["RSP"]       = {name="ＳＰ回復: "   ;ename="RSP: "      ;kname="　　　   SP 회복력 : ";};
	["MSPD"]      = {name="スピード: "   ;ename="MSPD: "     ;kname="　　　　이동 속도 : " ;};
	["WHEIGHT"]   = {name="所持量　: "   ;ename="WHEIGHT: "  ;kname="　  휴대 가능 무게 : ";};
	["CHANCE"]    = {name="チャンス: "   ;ename="CHANCE:  "  ;kname="　　　　루팅 찬스 : " ;};
	["STR"]       = {name="力　　　: "   ;ename="STR: "     ;kname="　　　　힘 : " ;};
	["CON"]       = {name="体力　　: "   ;ename="CON: "     ;kname="　　　　체력 : " ;};
	["INT"]       = {name="知能　　: "   ;ename="INT: "     ;kname="　　　　지능 : " ;};
	["MNA"]       = {name="精神　　: "   ;ename="SPR: "     ;kname="　　　　정신 : " ;};
	["DEX"]       = {name="敏捷　　: "   ;ename="DEX: "     ;kname="　　　　민첩 : " ;};
	["STATUS"]    = {name="能力値　: "   ;ename="STATUS:  "  ;kname="　　　　지위 : " ;};
};
local ctrlPos = {}

function STATVIEW_EX_R_ON_INIT(addon, frame)
	STATVIEW_EX_R_LOAD_SETTINGS();
	STATVIEW_EX_R_UPDATE(frame);
	addon:RegisterOpenOnlyMsg("PC_PROPERTY_UPDATE", "STATVIEW_EX_R_UPDATE");
	addon:RegisterOpenOnlyMsg("STAT_UPDATE", "STATVIEW_EX_R_UPDATE");

	_G["STATVIEW_EX_R"].isDragging = false;
	frame:SetEventScript(ui.LBUTTONDOWN, "STATVIEW_EX_R_START_DRAG");
	frame:SetEventScript(ui.LBUTTONUP, "STATVIEW_EX_R_END_DRAG");
	frame:SetEventScript(ui.RBUTTONDOWN, "STATVIEW_EX_R_CALL_MENU");
	
	STATVIEW_EX_R_UPDATE_POSITION();
end

function STATVIEW_EX_R_START_DRAG()
	_G["STATVIEW_EX_R"].isDragging = true;
end

function STATVIEW_EX_R_END_DRAG()
	_G["STATVIEW_EX_R"].isDragging = false;
	STATVIEW_EX_R_SAVE_SETTINGS();
end

function STATVIEW_EX_R_LOAD_SETTINGS()
	local acutil = require('acutil');
	_G["STATVIEW_EX_R"] = _G["STATVIEW_EX_R"] or {};
	local settings, error = acutil.loadJSON("../addons/STATVIEW_EX_R/settings.json");

	if error then
		STATVIEW_EX_R_SAVE_SETTINGS();
	else
		_G["STATVIEW_EX_R"]["settings"] = settings;
	end
	local objFrame = ui.GetFrame("statview_ex_r");
	if objFrame ~= nil then
		objFrame:EnableMove(_G["STATVIEW_EX_R"]["settings"]["Movable"] and 1 or 0);
	end

	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local statsettings, error = acutil.loadJSON("../addons/STATVIEW_EX_R/"..cid..".json");

	if error then
		STATVIEW_EX_R_SAVE_STATSETTINGS_INIT(cid, "statsettings");
	else
		_G["STATVIEW_EX_R"]["statsettings"] = statsettings;
	end

	for i = 1 , 10 do
		STATVIEW_EX_R_LOAD_COMMON_SETTINGS(i)
	end
end

function STATVIEW_EX_R_LOAD_COMMON_SETTINGS(no)
	local acutil = require('acutil');
	local statsettings, error = acutil.loadJSON("../addons/STATVIEW_EX_R/common"..no..".json");
	if error then
		STATVIEW_EX_R_SAVE_STATSETTINGS_INIT("common"..no, "common"..no);
	else
		_G["STATVIEW_EX_R"]["common"..no] = statsettings;
	end
end

function STATVIEW_EX_R_SAVE_SETTINGS()
	local acutil = require('acutil');
	_G["STATVIEW_EX_R"] = _G["STATVIEW_EX_R"] or {};

	if _G["STATVIEW_EX_R"]["settings"] == nil then
		_G["STATVIEW_EX_R"]["settings"] = {
			x = STATVIEW_EX_R_GET_DEFAULT_X();
			y = STATVIEW_EX_R_GET_DEFAULT_Y()
		};
	else
		local frame = ui.GetFrame("statview_ex_r");
		_G["STATVIEW_EX_R"]["settings"].x = frame:GetX();
		_G["STATVIEW_EX_R"]["settings"].y = frame:GetY();
	end

	acutil.saveJSON("../addons/STATVIEW_EX_R/settings.json", _G["STATVIEW_EX_R"]["settings"]);
end

function STATVIEW_EX_R_SAVE_STATSETTINGS()
	local acutil = require('acutil');
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	acutil.saveJSON("../addons/STATVIEW_EX_R/"..cid..".json", _G["STATVIEW_EX_R"]["statsettings"]);
end

function STATVIEW_EX_R_SAVE_STATSETTINGS_INIT(filename, statval)
	_G["STATVIEW_EX_R"] = _G["STATVIEW_EX_R"] or {};

	_G["STATVIEW_EX_R"][statval] = {
		PATK = true;
		PATK_SUB = true;
		MATK = true;
		CRTHR = true;
		EATK = true;
		CRTATK = true;
		CRTMATK = true;
		HEAL_PWR = true;
		HR = true;
		BLK_BREAK = true;
		SR = true;
		DEF = true;
		MDEF = true;
		DR = true;
		BLK = true;
		CRTDR = true;
		SDR = true;
		RHP = true;
		RSP = true;
		MSPD = true;
		WHEIGHT = true;
		CHANCE = true;
		STR = true;
		CON = true;
		INT = true;
		MNA = true;
		DEX = true;
		STATUS = true;
		PATK_COLOR = "FFFFFF";
		PATK_SUB_COLOR = "FFFFFF";
		MATK_COLOR = "FFFFFF";
		EATK_COLOR = "FFFFFF";
		CRTHR_COLOR = "FFFFFF";
		CRTATK_COLOR = "FFFFFF";
		CRTMATK_COLOR = "FFFFFF";
		HEAL_PWR_COLOR = "FFFFFF";
		HR_COLOR = "FFFFFF";
		BLK_BREAK_COLOR = "FFFFFF";
		SR_COLOR = "FFFFFF";
		DEF_COLOR = "FFFFFF";
		MDEF_COLOR = "FFFFFF";
		DR_COLOR = "FFFFFF";
		BLK_COLOR = "FFFFFF";
		CRTDR_COLOR = "FFFFFF";
		SDR_COLOR = "FFFFFF";
		RHP_COLOR = "FFFFFF";
		RSP_COLOR = "FFFFFF";
		MSPD_COLOR = "FFFFFF";
		WHEIGHT_COLOR = "FFFFFF";
		CHANCE_COLOR = "FFFFFF";
		STR_COLOR = "FFFFFF";
		CON_COLOR = "FFFFFF";
		INT_COLOR = "FFFFFF";
		MNA_COLOR = "FFFFFF";
		DEX_COLOR = "FFFFFF";
		STATUS_COLOR = "FFFFFF";
		MEMO = "";
	};

	local acutil = require('acutil');
	acutil.saveJSON("../addons/STATVIEW_EX_R/"..filename..".json", _G["STATVIEW_EX_R"][statval]);
end

function STATVIEW_EX_R_GET_DEFAULT_X()
	local frame = ui.GetFrame("statview_ex_r");

	return (option.GetClientWidth() / 2);
end

function STATVIEW_EX_R_GET_DEFAULT_Y()
	local frame = ui.GetFrame("statview_ex_r");

	return (option.GetClientHeight() / 2);
end

function STATVIEW_EX_R_UPDATE_POSITION()
	local frame = ui.GetFrame("statview_ex_r");

	if frame ~= nil and not _G["STATVIEW_EX_R"].isDragging then
		frame:SetOffset(_G["STATVIEW_EX_R"]["settings"].x, _G["STATVIEW_EX_R"]["settings"].y);
	end
end

function STATVIEW_EX_R_UPDATE(frame)
	local pc = GetMyPCObject();

	local dimensions = STATVIEW_EX_R_GET_DIMENSIONS();
	ctrlPos = {};

	--frame, statName, statString, yPosition
	if _G["STATVIEW_EX_R"]["statsettings"].PATK then
		STATVIEW_EX_R_UPDATE_STAT(frame, "PATK"     , pc["MINPATK"] .. "~" .. pc["MAXPATK"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].PATK_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].PATK_SUB then
		STATVIEW_EX_R_UPDATE_STAT(frame, "PATK_SUB" , pc["MINPATK_SUB"] .. "~" .. pc["MAXPATK_SUB"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].PATK_SUB_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].MATK then
		STATVIEW_EX_R_UPDATE_STAT(frame, "MATK"     , pc["MINMATK"] .. "~" .. pc["MAXMATK"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].MATK_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].EATK then
		local elementalAttack = STATVIEW_EX_R_CALCULATE_ELEMENTAL_ATTACK(pc);
		STATVIEW_EX_R_UPDATE_STAT(frame, "EATK"     , elementalAttack, dimensions, _G["STATVIEW_EX_R"]["statsettings"].EATK_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].CRTHR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "CRTHR"    , pc["CRTHR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].CRTHR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].CRTATK then
		STATVIEW_EX_R_UPDATE_STAT(frame, "CRTATK"   , pc["CRTATK"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].CRTATK_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].CRTMATK then
		STATVIEW_EX_R_UPDATE_STAT(frame, "CRTMATK"   , pc["CRTMATK"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].CRTMATK_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].HEAL_PWR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "HEAL_PWR" , pc["HEAL_PWR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].HEAL_PWR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].HR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "HR"       , pc["HR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].HR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].BLK_BREAK then
		STATVIEW_EX_R_UPDATE_STAT(frame, "BLK_BREAK", pc["BLK_BREAK"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].BLK_BREAK_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].SR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "SR"       , pc["SR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].SR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].DEF then
		STATVIEW_EX_R_UPDATE_STAT(frame, "DEF"      , pc["DEF"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].DEF_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].MDEF then
		STATVIEW_EX_R_UPDATE_STAT(frame, "MDEF"     , pc["MDEF"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].MDEF_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].DR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "DR"       , pc["DR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].DR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].BLK then
		STATVIEW_EX_R_UPDATE_STAT(frame, "BLK"      , pc["BLK"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].BLK_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].CRTDR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "CRTDR"    , pc["CRTDR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].CRTDR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].SDR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "SDR"      , pc["SDR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].SDR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].RHP then
		STATVIEW_EX_R_UPDATE_STAT(frame, "RHP"      , pc["RHP"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].RHP_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].RSP then
		STATVIEW_EX_R_UPDATE_STAT(frame, "RSP"      , pc["RSP"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].RSP_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].MSPD then
		STATVIEW_EX_R_UPDATE_STAT(frame, "MSPD"     , pc["MSPD"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].MSPD_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].WHEIGHT then
		local wheight_str = string.format("%.1f/%.1f", pc["NowWeight"], pc["MaxWeight"]);
		STATVIEW_EX_R_UPDATE_STAT(frame, "WHEIGHT"  , wheight_str .. "("..tostring(math.floor(pc.NowWeight*100/pc.MaxWeight)).."%)", dimensions, _G["STATVIEW_EX_R"]["statsettings"].WHEIGHT_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].CHANCE then
		STATVIEW_EX_R_UPDATE_STAT(frame, "CHANCE"  , pc["LootingChance"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].CHANCE_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].STR then
		STATVIEW_EX_R_UPDATE_STAT(frame, "STR"  , pc["STR"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].STR_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].CON then
		STATVIEW_EX_R_UPDATE_STAT(frame, "CON"  , pc["CON"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].CON_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].INT then
		STATVIEW_EX_R_UPDATE_STAT(frame, "INT"  , pc["INT"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].INT_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].MNA then
		STATVIEW_EX_R_UPDATE_STAT(frame, "MNA"  , pc["MNA"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].MNA_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].DEX then
		STATVIEW_EX_R_UPDATE_STAT(frame, "DEX"  , pc["DEX"], dimensions, _G["STATVIEW_EX_R"]["statsettings"].DEX_COLOR);
	end
	if _G["STATVIEW_EX_R"]["statsettings"].STATUS then
		STATVIEW_EX_R_UPDATE_STAT(frame, "STATUS"  , "{#".._G["STATVIEW_EX_R"]["statsettings"].STR_COLOR.."}"..pc["STR"] .."{/}/{#".._G["STATVIEW_EX_R"]["statsettings"].CON_COLOR.."}".. pc["CON"] .."{/}/{#".._G["STATVIEW_EX_R"]["statsettings"].INT_COLOR.."}".. pc["INT"] .."{/}/{#".._G["STATVIEW_EX_R"]["statsettings"].MNA_COLOR.."}".. pc["MNA"] .."{/}/{#".._G["STATVIEW_EX_R"]["statsettings"].DEX_COLOR.."}".. pc["DEX"].."{/}", dimensions, _G["STATVIEW_EX_R"]["statsettings"].STATUS_COLOR);
	end
	frame:Resize(dimensions.width, dimensions.height+1);
	STATVIEW_EX_R_UPDATE_POSITION();
end

function STATVIEW_EX_R_GET_DIMENSIONS()
	local dimensions = {};

	dimensions.x = 0;
	dimensions.y = 0;
	dimensions.width = 0;
	dimensions.height = 0;

	return dimensions;
end

function STATVIEW_EX_R_CALCULATE_ELEMENTAL_ATTACK(pc)
	local elementalAttack = 0;

	elementalAttack = elementalAttack + pc["Fire_Atk"];
	elementalAttack = elementalAttack + pc["Ice_Atk"];
	elementalAttack = elementalAttack + pc["Lightning_Atk"];
	elementalAttack = elementalAttack + pc["Earth_Atk"];
	elementalAttack = elementalAttack + pc["Poison_Atk"];
	elementalAttack = elementalAttack + pc["Holy_Atk"];
	elementalAttack = elementalAttack + pc["Dark_Atk"];
	elementalAttack = elementalAttack + pc["Soul_Atk"];

	return elementalAttack;
end

function STATVIEW_EX_R_GET_STATSTRING(statName)
	local country=option.GetCurrentCountry();
	if string.lower(country)=="japanese" then
		return label[statName].name
	elseif string.lower(country)=="korean" then
		return label[statName].kname
	else
		return label[statName].ename
	end
end

function STATVIEW_EX_R_UPDATE_STAT(frame, statName, statString, dimensions, fontcolor)
	if fontcolor == nil then
		fontcolor = "FFFFFF";
	end
	local statRichText = frame:CreateOrGetControl("richtext", statName .. "_text", dimensions.x, dimensions.y, 0, 4);
	tolua.cast(statRichText, "ui::CRichText");
	statRichText:SetGravity(ui.LEFT, ui.TOP);
	statRichText:SetTextAlign("left", "top");
	statRichText:SetText("{#"..fontcolor.."}{ol}{s16}"..STATVIEW_EX_R_GET_STATSTRING(statName)..statString.."{/}{/}{/}");
	statRichText:EnableHitTest(0);
	statRichText:ShowWindow(1);

	local currentHeight = statRichText:GetHeight() - 4;
	ctrlPos[statName] =  {left	 = statRichText:GetX()
						, top	 = statRichText:GetY()
						, right	 = statRichText:GetX() + statRichText:GetWidth()
						, bottom = statRichText:GetY() + currentHeight + 1
						  }

	-- 余白を使う の設定があれば高さをおまけする
	if _G["STATVIEW_EX_R"]["statsettings"][statName .. "_USEMARGIN"] then
		currentHeight = currentHeight + 6;
	end
	
	dimensions.y = dimensions.y + currentHeight;

	if statRichText:GetWidth() > dimensions.width then
		dimensions.width = statRichText:GetWidth();
	end
	dimensions.height = dimensions.height + currentHeight;
	if statRichText:GetHeight() > dimensions.height then
		dimensions.height = statRichText:GetHeight();
	end
end

-- 右クリックメニュー関連


local function log(Caption)
	if Caption == nil then Caption = "Test Printing" end
	Caption = tostring(Caption) or "Test Printing";
	CHAT_SYSTEM(tostring(Caption));
end

local function GetLocalMousePos()
	local frame = ui.GetFrame("statview_ex_r");
	if frame == nil then
		return nil, nil;
	else
		return GET_LOCAL_MOUSE_POS(frame);
	end
end

-- ***** コンテキストメニュー関連 *****
-- セパレータを挿入
local function MakeCMenuSeparator(parent, width)
	width = width or 300;
	ui.AddContextMenuItem(parent, string.format("{img fullgray %s 1}", width), "None");
end
-- コンテキストメニュー項目を作成
local function MakeCMenuItem(parent, text, eventscp, checked)
	local CheckIcon = "";
	local eventscp = eventscp or "None";
	if checked == nil then
		CheckIcon = "";
	elseif checked == true then
		CheckIcon = "{img socket_slot_check 24 24} ";
	elseif checked == false  then
		CheckIcon = "{img channel_mark_empty 24 24} ";
	end
	ui.AddContextMenuItem(parent, string.format("%s%s", CheckIcon, text), eventscp);
end
-- 子を持つメニュー項目を作成
local function MakeCMenuParentItem(parent, text, child)
	ui.AddContextMenuItem(parent, text .. "  {img white_right_arrow 8 16}", "", nil, 0, 1, child);
end

-- 移動ロックの設定を切り替える
function STATVIEW_EX_R_CHANGE_MOVABLE()
	if _G["STATVIEW_EX_R"]["settings"] == nil then return end
	if _G["STATVIEW_EX_R"]["settings"]["Movable"] == nil then
		_G["STATVIEW_EX_R"]["settings"]["Movable"] = true;
	end
	_G["STATVIEW_EX_R"]["settings"]["Movable"] = not _G["STATVIEW_EX_R"]["settings"]["Movable"];
	local objFrame = ui.GetFrame("statview_ex_r");
	if objFrame ~= nil then
		objFrame:EnableMove(_G["STATVIEW_EX_R"]["settings"]["Movable"] and 1 or 0);
		STATVIEW_EX_R_SAVE_SETTINGS();
	end
end

-- 再描画用
function STATVIEW_EX_R_REDRAW()
	local frame = ui.GetFrame("statview_ex_r");
	if frame == nil then return end
	frame:RemoveAllChild();
	STATVIEW_EX_R_UPDATE(frame);
end

-- 項目のON/OFFの切り替え
function STATVIEW_EX_R_TOGGLE_VISIBLE(statName, newVisible)
	ui.CloseAllContextMenu();
	if _G["STATVIEW_EX_R"]["statsettings"][statName] == nil then return end
	_G["STATVIEW_EX_R"]["statsettings"][statName] = (newVisible == 1);
	STATVIEW_EX_R_SAVE_STATSETTINGS()
	STATVIEW_EX_R_REDRAW();
end

-- 項目の色の切り替え
function STATVIEW_EX_R_CHANGE_COLOR(statName, newColor)
	ui.CloseAllContextMenu();
	if _G["STATVIEW_EX_R"]["statsettings"][statName] == nil then return end
	_G["STATVIEW_EX_R"]["statsettings"][statName .. "_COLOR"] = newColor;
	STATVIEW_EX_R_SAVE_STATSETTINGS()
	STATVIEW_EX_R_REDRAW();
end

-- 余白の有無の切り替え
function STATVIEW_EX_R_TOGGLE_USEMARGIN(statName)
	if _G["STATVIEW_EX_R"]["statsettings"][statName] == nil then return end
	if _G["STATVIEW_EX_R"]["statsettings"][statName .. "_USEMARGIN"] == nil then
		_G["STATVIEW_EX_R"]["statsettings"][statName .. "_USEMARGIN"] = true;
	else
		-- 本当はFalseだけど、余分な設定文字を消させるためにあえてnilを採用しています
		_G["STATVIEW_EX_R"]["statsettings"][statName .. "_USEMARGIN"] = nil;
	end
	STATVIEW_EX_R_SAVE_STATSETTINGS()
	STATVIEW_EX_R_REDRAW();
end

function STATVIEW_EX_R_COMMONLOAD_CHECK(argNum)
	ui.CloseAllContextMenu();
	local yesscp = string.format("STATVIEW_EX_R_COMMONSAVE_LOAD(%d)", argNum);
	local country = string.lower(option.GetCurrentCountry());
	local msg = ""
	if country == "japanese" then
		msg = "共通データ" .. argNum .. "をロードしますか？"
	else
		msg = "load to common data " .. argNum .. "?"
	end
	ui.MsgBox(msg, yesscp, "None")
end

function STATVIEW_EX_R_COMMONSAVE_LOAD(no)
	local acutil = require('acutil');
	local statsettings, error = acutil.loadJSON("../addons/STATVIEW_EX_R/common"..no..".json");
	if error then
		return;
	else
		_G["STATVIEW_EX_R"]["statsettings"] = statsettings;
	end
	STATVIEW_EX_R_SAVE_STATSETTINGS()
	STATVIEW_EX_R_REDRAW()
end

function STATVIEW_EX_R_COMMONSAVE_CHECK(argNum)
	ui.CloseAllContextMenu();
	local yesscp = string.format("STATVIEW_EX_R_COMMONSAVE_SAVE(%d)", argNum);
	local country = string.lower(option.GetCurrentCountry());
	local msg = ""
	if country == "japanese" then
		msg = "現在の設定を共通データ" .. argNum .. "にセーブしますか？"
	else
		msg = "save the current setting to common data " .. argNum .. "?"
	end
	ui.MsgBox(msg, yesscp, "None")
end

function STATVIEW_EX_R_COMMONSAVE_SAVE(no)
	local acutil = require('acutil');
	acutil.saveJSON("../addons/STATVIEW_EX_R/common"..no..".json", _G["STATVIEW_EX_R"]["statsettings"]);
	_G["STATVIEW_EX_R"]["common"..no] = _G["STATVIEW_EX_R"]["statsettings"]
	STATVIEW_EX_R_REDRAW()
end

function STATVIEW_EX_R_CALL_MENU(frame)
	local x, y = GET_LOCAL_MOUSE_POS(frame);

	local targetStatName = nil;
	for key, rect in pairs(ctrlPos) do
		if x >= rect.left and x <= rect.right and y >= rect.top and y <= rect.bottom then
			targetStatName = key;
			break;
		end
	end
	--if targetStatName == nil then return end
	-- 対象コントロールの検出に成功
	local currentCountry = string.lower(option.GetCurrentCountry());
	local valueKey = "ename";
	if currentCountry == "japanese" then
		valueKey = "name";
	end
	-- コンテキストメニューを作成する
	local strTemp = "Settings - Status Viewer Ex -";
	if currentCountry == "japanese" then
		strTemp = "Status Viewer Exの設定";
	end
	local intTitleWidth = 320;
	if currentCountry == "japanese" then
		intTitleWidth = 260;
	end	
	local context = ui.CreateContextMenu("STATVIEW_EX_R_RBTN", "{#006666}=== " .. strTemp .. " ==={/}", 0, 0, intTitleWidth, 0);
	MakeCMenuSeparator(context, 240);

	if targetStatName ~= nil then
		local subContextColor = ui.CreateContextMenu("SUBCONTEXT_COLOR", "", 0, 0, 0, 0);
		local colorClsCount = GetClassCount("ChatColorStyle");
		for i = 0, colorClsCount - 1 do
			local colorCls = GetClass("ChatColorStyle", "Class" .. i);
			if colorCls ~= nil then
				local textColor = colorCls.TextColor;
				MakeCMenuItem(subContextColor
							, "{#" .. textColor .. "}" .. string.gsub(label[targetStatName][valueKey], ": ", "") .. " (#" .. textColor .. "){/}"
							, string.format("STATVIEW_EX_R_CHANGE_COLOR('%s', '%s')", targetStatName, textColor)
							, (_G["STATVIEW_EX_R"]["statsettings"][targetStatName .. "_COLOR"] == textColor)
							);
			end
		end
		subContextColor:Resize(240, subContextColor:GetHeight());
		strTemp = "Text Color of '%s'";
		if currentCountry == "japanese" then
			strTemp = "'%s'の表示色";
		end	
		MakeCMenuParentItem(context, string.format(strTemp, string.gsub(label[targetStatName][valueKey], ": ", "")), subContextColor);
		strTemp = "Insert a margin below '%s'";
		if currentCountry == "japanese" then
			strTemp = "この下に余白を入れる";
		end	
		MakeCMenuItem(context, string.format(strTemp, string.gsub(label[targetStatName][valueKey], ": ", "")), string.format("STATVIEW_EX_R_TOGGLE_USEMARGIN('%s')", targetStatName), _G["STATVIEW_EX_R"]["statsettings"][targetStatName .. "_USEMARGIN"] or false);
		MakeCMenuSeparator(context, 240.1);
	end

	local labelIndex = {};
	table.insert( labelIndex, "PATK");
	table.insert( labelIndex, "PATK");
	table.insert( labelIndex, "PATK_SUB");
	table.insert( labelIndex, "MATK");
	table.insert( labelIndex, "EATK");
	table.insert( labelIndex, "CRTHR");
	table.insert( labelIndex, "CRTATK");
	table.insert( labelIndex, "CRTMATK");
	table.insert( labelIndex, "HEAL_PWR");
	table.insert( labelIndex, "HR");
	table.insert( labelIndex, "BLK_BREAK");
	table.insert( labelIndex, "SR");
	table.insert( labelIndex, "DEF");
	table.insert( labelIndex, "MDEF");
	table.insert( labelIndex, "DR");
	table.insert( labelIndex, "BLK");
	table.insert( labelIndex, "CRTDR");
	table.insert( labelIndex, "SDR");
	table.insert( labelIndex, "RHP");
	table.insert( labelIndex, "RSP");
	table.insert( labelIndex, "MSPD");
	table.insert( labelIndex, "WHEIGHT");
	table.insert( labelIndex, "CHANCE");
	table.insert( labelIndex, "STR");
	table.insert( labelIndex, "CON");
	table.insert( labelIndex, "INT");
	table.insert( labelIndex, "MNA");
	table.insert( labelIndex, "DEX");
	table.insert( labelIndex, "STATUS");
	
	local subContextDisplay = ui.CreateContextMenu("SUBCONTEXT_DISPLAY", "", 0, 0, 0, 0);
	for i, key in ipairs(labelIndex) do
		MakeCMenuItem(subContextDisplay
					, string.gsub(label[key][valueKey], ": ", "")
					, string.format("STATVIEW_EX_R_TOGGLE_VISIBLE('%s', %s)", key, not _G["STATVIEW_EX_R"]["statsettings"][key] and 1 or 0)
					, _G["STATVIEW_EX_R"]["statsettings"][key]
					);
	end
	subContextDisplay:Resize(160, subContextDisplay:GetHeight());
	strTemp = "Display items";
	if currentCountry == "japanese" then
		strTemp = "表示項目";
	end	
	MakeCMenuParentItem(context, strTemp, subContextDisplay);
	strTemp = "Setting screen";
	if currentCountry == "japanese" then
		strTemp = "設定画面を開く";
	end	
	MakeCMenuItem(context, strTemp, "STATVIEWERSETTING_OPEN_UI()");
	MakeCMenuSeparator(context, 240.2);

	local subContextLoad = ui.CreateContextMenu("SUBCONTEXT_LOAD", "", 0, 0, 0, 0);
	strTemp = "Common Setting ";
	if currentCountry == "japanese" then
		strTemp = "共通データ";
	end	
	for i = 1, 10 do
		local memo = _G["STATVIEW_EX_R"]["common" .. i].MEMO
		if memo == nil or memo == "" then
			memo = ""
		else
			memo = " : " .. memo
		end
		MakeCMenuItem(subContextLoad
					, strTemp .. i .. memo
					, string.format("STATVIEW_EX_R_COMMONLOAD_CHECK(%d)", i)
					);
	end
	subContextLoad:Resize(subContextLoad:GetWidth(), subContextLoad:GetHeight());
	strTemp = "Load Setting";
	if currentCountry == "japanese" then
		strTemp = "設定読み込み";
	end	
	MakeCMenuParentItem(context, strTemp, subContextLoad);

	local subContextSave = ui.CreateContextMenu("SUBCONTEXT_SAVE", "", 0, 0, 0, 0);
	strTemp = "Common Setting ";
	if currentCountry == "japanese" then
		strTemp = "共通データ";
	end	
	for i = 1, 10 do
		local memo = _G["STATVIEW_EX_R"]["common" .. i].MEMO
		if memo == nil or memo == "" then
			memo = ""
		else
			memo = " : " .. memo
		end
		MakeCMenuItem(subContextSave
					, strTemp .. i .. memo
					, string.format("STATVIEW_EX_R_COMMONSAVE_CHECK(%d)", i)
					);
	end
	subContextSave:Resize(subContextSave:GetWidth(), subContextSave:GetHeight());
	strTemp = "Save Setting";
	if currentCountry == "japanese" then
		strTemp = "設定保存";
	end	
	MakeCMenuParentItem(context, strTemp, subContextSave);
	MakeCMenuSeparator(context, 240.3);
	if _G["STATVIEW_EX_R"]["settings"]["Movable"] == nil then
		_G["STATVIEW_EX_R"]["settings"]["Movable"] = true;
	end
	strTemp = "Lock position";
	if currentCountry == "japanese" then
		strTemp = "位置を固定する";
	end	
	MakeCMenuItem(context, strTemp, "STATVIEW_EX_R_CHANGE_MOVABLE()", not _G["STATVIEW_EX_R"]["settings"]["Movable"]);
	MakeCMenuSeparator(context, 240.4);
	strTemp = "Close";
	if currentCountry == "japanese" then
		strTemp = "閉じる";
	end	
	MakeCMenuItem(context, "{#666666}" .. strTemp .. "{/}");
	local intWidth = 360;
	if currentCountry == "japanese" then
		intWidth = 270;
	end	
	context:Resize(intWidth, context:GetHeight());
	ui.OpenContextMenu(context);
	
end
