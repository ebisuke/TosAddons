-- Anotheroneofinventory
local addonName = "compactpartylist"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings = g.settings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "compactpartylist"
g.debug = false

g.x = nil
g.y = nil
g.findstr = ""


--ライブラリ読み込み
CHAT_SYSTEM("[CPL]loaded")
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end

local function AUTO_CAST(ctrl)
    if(ctrl==nil)then
        
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
	return ctrl;
end

local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
            end
        end,
        catch = function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end


--マップ読み込み時処理（1度だけ）
function COMPACTPARTYLIST_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            g.initialized = false
   
            g.addon = addon
            acutil.setupHook(CPL_SET_PARTYINFO_ITEM_HOOK,"SET_PARTYINFO_ITEM")
            CHAT_SYSTEM("hooked")
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end

           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function CPL_SET_PARTYINFO_ITEM_HOOK(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, ispipui, partyID)
   -- SET_PARTYINFO_ITEM_OLD(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, ispipui, partyID)
    CPL_SET_PARTYINFO_ITEM(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, ispipui, partyID)
 
end
function CPL_SET_PARTYINFO_ITEM(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, ispipui, partyID)
    --SET_PARTYINFO_ITEM_OLD(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, ispipui, partyID)
    if partyID ~= nil and partyMemberInfo ~= nil and partyID ~= partyMemberInfo:GetPartyID() then
        return nil;
    end
    local partyinfoFrame = ui.GetFrame('partyinfo')
	local partyinfoFrame = ui.GetFrame('partyinfo')
	local FAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("FAR_MEMBER_FACE_COLORTONE")
	local NEAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("NEAR_MEMBER_FACE_COLORTONE")
	local FAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("FAR_MEMBER_NAME_FONT_COLORTAG")
	local NEAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("NEAR_MEMBER_NAME_FONT_COLORTAG")

	local mapName = geMapTable.GetMapName(partyMemberInfo:GetMapID());
	local partyMemberName = partyMemberInfo:GetName();
	
	local myHandle = session.GetMyHandle();
	local ctrlName = 'PTINFO_'.. partyMemberInfo:GetAID();
	if mapName == 'None' and makeLogoutPC == false then
		frame:RemoveChild(ctrlName);
		return nil;
	end	

	local partyInfoCtrlSet = frame:CreateOrGetControlSet('partyinfo', ctrlName, 10, count * 100);
	UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo);
    
	local leaderMark = GET_CHILD(partyInfoCtrlSet, "leader_img", "ui::CPicture");
	leaderMark:SetImage('None_Mark');
	leaderMark:ShowWindow(0)
	-- 머리
	local jobportraitImg = GET_CHILD(partyInfoCtrlSet, "jobportrait_bg", "ui::CPicture");
	local nameObj = partyInfoCtrlSet:GetChild('name_text');
	local nameRichText = tolua.cast(nameObj, "ui::CRichText");	
	local hpGauge = GET_CHILD(partyInfoCtrlSet, "hp", "ui::CGauge");
	local spGauge = GET_CHILD(partyInfoCtrlSet, "sp", "ui::CGauge");
    hpGauge:Resize(50,10)
    spGauge:Resize(50,10)
    spGauge:SetOffset(spGauge:GetX(),spGauge:GetY()+5)
	if jobportraitImg ~= nil then
		local jobIcon = GET_CHILD(jobportraitImg, "jobportrait", "ui::CPicture");
		local iconinfo = partyMemberInfo:GetIconInfo();
		local jobCls  = GetClassByType("Job", iconinfo.repre_job)
		if nil ~= jobCls then
			jobIcon:SetImage(jobCls.Icon);
		end
		jobIcon:Resize(30,30)
		local partyMemberCID = partyInfoCtrlSet:GetUserValue("partyMemberCID")
		if partyMemberCID ~= nil and partyMemberCID ~= 0 and partyMemberCID ~= "None" then
			local jobportraitImg = GET_CHILD(partyInfoCtrlSet, "jobportrait_bg", "ui::CPicture");
			if jobportraitImg ~= nil then
				local jobIcon = GET_CHILD(jobportraitImg, "jobportrait", "ui::CPicture");
				local partyinfoFrame = ui.GetFrame("partyinfo");	
				PARTY_JOB_TOOLTIP(partyinfoFrame, partyMemberCID, jobIcon, jobCls, 1);  
					
				local partyFrame = ui.GetFrame('party');
				local gbox = partyFrame:GetChild("gbox");
				local memberlist = gbox:GetChild("memberlist");					
				PARTY_JOB_TOOLTIP(memberlist, partyMemberCID, jobIcon, jobCls, 1);            
			end;
		end

		local tooltipID = jobIcon:GetTooltipIESID();		
		if nil == tooltipID then	
			jobName = GET_JOB_NAME(jobCls, iconinfo.gender);	
			jobIcon:SetTextTooltip(jobName);
		end
		
		local stat = partyMemberInfo:GetInst();
		local pos = stat:GetPos();

		local dist = info.GetDestPosDistance(pos.x, pos.y, pos.z, myHandle);
		local sharedcls = GetClass("SharedConst",'PARTY_SHARE_RANGE');

		local mymapname = session.GetMapName();

		local partymembermapName = GetClassByType("Map", partyMemberInfo:GetMapID()).ClassName;
		local partymembermapUIName = GetClassByType("Map", partyMemberInfo:GetMapID()).Name;

		if ispipui == true then
			--partyMemberName = ScpArgMsg("PartyMemberMapNChannel","Name",partyMemberName,"Mapname",partymembermapUIName,"ChNo",partyMemberInfo:GetChannel() + 1)
		end
				

		if dist < sharedcls.Value and mymapname == partymembermapName then
			jobportraitImg:SetColorTone(NEAR_MEMBER_FACE_COLORTONE)
			partyMemberName = NEAR_MEMBER_NAME_FONT_COLORTAG..partyMemberName;
			nameRichText:SetTextByKey("name", partyMemberName);
			hpGauge:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
			spGauge:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
		else
			jobportraitImg:SetColorTone(FAR_MEMBER_FACE_COLORTONE)
			partyMemberName = FAR_MEMBER_NAME_FONT_COLORTAG..partyMemberName;
			nameRichText:SetTextByKey("name", partyMemberName);
			hpGauge:SetColorTone(FAR_MEMBER_FACE_COLORTONE);
			spGauge:SetColorTone(FAR_MEMBER_FACE_COLORTONE);
		end
        nameRichText:SetOffset(nameRichText:GetX()-20,nameRichText:GetY())
	end
		
	partyInfoCtrlSet:SetEventScript(ui.RBUTTONUP, "CONTEXT_PARTY");
	partyInfoCtrlSet:SetEventScriptArgString(ui.RBUTTONUP, partyMemberInfo:GetAID());

	if partyMemberInfo:GetAID() == leaderFID then
		leaderMark:ShowWindow(1)
		if isCorsairType == true then
			leaderMark:SetImage('party_corsair_mark');
		else
			leaderMark:SetImage('party_leader_mark');
        end
        leaderMark:Resize(15,10)
        leaderMark:SetOffset(leaderMark:GetX()-2,leaderMark:GetY())
    end
    

	partyInfoCtrlSet:SetUserValue("MEMBER_NAME", partyMemberName);


    hpGauge:SetTextStat("%v");
    hpGauge:SetStatOffset(0, 0, -1);
    hpGauge:SetStatAlign(0, ui.CENTER_HORZ, ui.TOP);
    hpGauge:SetStatFont(0, 'white_12_ol');

	
    hpGauge:SetTextStat("%v");
    spGauge:SetStatOffset(0, 0, -1);
    spGauge:SetStatAlign(0, ui.CENTER_HORZ, ui.BOTTOM);
    spGauge:SetStatFont(0, 'white_12_ol');


	-- 파티원 레벨 표시 -- 
	local lvbox = partyInfoCtrlSet:GetChild('lvbox');
	local levelObj = partyInfoCtrlSet:GetChild('lvbox');
	local levelRichText = tolua.cast(levelObj, "ui::CRichText");
	local level = partyMemberInfo:GetLevel();	
	levelRichText:SetTextByKey("lv", "");
	levelRichText:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
	--lvbox:Resize(levelRichText:GetWidth(), lvbox:GetHeight());
	lvbox:Resize(0, lvbox:GetHeight());
		
	if frame:GetName() == 'partyinfo' then
		frame:Resize(frame:GetOriginalWidth(), (count+1) * 100);
	else
		frame:Resize(frame:GetOriginalWidth(),frame:GetOriginalHeight());
	end

	return 1;
end
