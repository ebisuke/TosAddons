--アドオン名（大文字）
local addonName = "testboard"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings={x=300,y=300,volume=100,mute=false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "testboard"
g.debug = true
g.handle=nil
g.interlocked=false
g.currentIndex=1
--ライブラリ読み込み
CHAT_SYSTEM("[TESTBOARD]loaded")
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





function TESTBOARD_DBGOUT(msg)
    
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
function TESTBOARD_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function TESTBOARD_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function TESTBOARD_LOAD_SETTINGS()
    TESTBOARD_DBGOUT("LOAD_SETTING")
    g.settings = {foods={}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        TESTBOARD_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0

        end
    end
    
    TESTBOARD_UPGRADE_SETTINGS()
    TESTBOARD_SAVE_SETTINGS()

end


function TESTBOARD_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=TESTBOARD_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function TESTBOARD_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))

            
            addon:RegisterMsg('GAME_START_3SEC', 'TESTBOARD_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("TESTBOARD_ON_TIMER");
            timer:Start(0.1);
            TESTBOARD_SHOW(g.frame)
            
            

        end,
        catch = function(error)
            TESTBOARD_ERROUT(error)
        end
    }
end
function TESTBOARD_SHOW(frame)
    frame=ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function TESTBOARD_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
        --TESTBOARD_DBGOUT("test")
        --REQUEST_MAP_UPDATE(nil)
        local minimap = ui.GetFrame("minimap")
        local npcList = minimap:GetChild('npclist')
        tolua.cast(npcList, 'ui::CGroupBox');
        TESTBOARD_MAP_UPDATE_GUILD(npcList,nil,nil,nil,nil)
        TESTBOARD_MAP_UPDATE_PARTY(npcList,nil,nil,nil,nil)
        TESTBOARD_MAP_UPDATE_GUILD(ui.GetFrame("map"),nil,nil,nil,nil)
        TESTBOARD_MAP_UPDATE_PARTY(ui.GetFrame("map"),nil,nil,nil,nil)
        end,
    catch = function(error)
        TESTBOARD_ERROUT(error)
    end
    }
end
function TESTBOARD_MAP_UPDATE_PARTY(frame, msg, arg, type, info)

    DESTROY_CHILD_BYNAME(frame, 'PM_');

    local mapprop = session.GetCurrentMapProp();
    local list = session.party.GetPartyMemberList();
    local count = list:Count();

    -- if count == 1 then
    --     return;
    -- end


    for i = 0, count - 1 do
        
        local pcInfo = list:Element(i);
        if pcInfo:GetHandle() ~= 0 then
            local show_flag = true
            local actor = world.GetActor(pcInfo:GetHandle())   
            if pcInfo:GetHandle() ~= session.GetMyHandle() then
              
                if actor ~= nil and session.friendly_fight.IsFriendlyFightState() == true and actor:IsVisiableState() == false then
                    show_flag = false
                end
            end
            
            if show_flag == true then
                if(actor~=nil)then
                    TESTBOARD_CREATE_PM_PICTURE(frame, pcInfo, 0, mapprop,actor)
                else
                    CREATE_PM_PICTURE(frame, pcInfo, 0, mapprop)
                end
            end
        end

    end

end

function TESTBOARD_MAP_UPDATE_GUILD(frame, msg, arg, type, info)
    DESTROY_CHILD_BYNAME(frame, 'GM_');
    if session.world.IsIntegrateServer() == true then
        DESTROY_GUILD_MEMBER_ICON()
        return
    end

    local mapprop = session.GetCurrentMapProp();
    local list = session.party.GetPartyMemberList(PARTY_GUILD);
    local count = list:Count();
    -- if count == 1 then
    --     return;
    -- end

    for i = 0, count - 1 do
        
        local pcInfo = list:Element(i)
        if pcInfo:GetHandle() ~= 0 then
            local show_flag = true
            local actor = world.GetActor(pcInfo:GetHandle())   
            if pcInfo:GetHandle() ~= session.GetMyHandle() then
                            
                if actor ~= nil and session.friendly_fight.IsFriendlyFightState() == true and actor:IsVisiableState() == false then
                    show_flag = false
                end
            end
            
            if show_flag == true  then
                if(actor~=nil)then
                    TESTBOARD_CREATE_PM_PICTURE(frame, pcInfo, PARTY_GUILD, mapprop,actor)
                else
                    CREATE_PM_PICTURE(frame, pcInfo, PARTY_GUILD, mapprop)
                end

            end
        end
    end
end
function  TESTBOARD_CREATE_PM_PICTURE(frame, pcInfo, type, mapprop,actor)    
	local myInfo = session.party.GetMyPartyObj(type);    
	if nil == myInfo then
		return;
	end
    
	if myInfo == pcInfo then
	 	return;
	end
	
	if myInfo:GetMapID() ~= pcInfo:GetMapID() or myInfo:GetChannel() ~= pcInfo:GetChannel() then
		return;
	end

	local header = "PM_";
	if type == PARTY_GUILD then
		header = "GM_";
	end    
	local name = header .. pcInfo:GetAID()
	if pcInfo:GetMapID() == 0 then
		frame:RemoveChild(name);
		return
	end
    
    if type == PARTY_GUILD then        
		if frame:GetChild("GM_" .. pcInfo:GetAID()) ~= nil then
			return;
		end
	else
		if frame:GetChild("PM_" .. pcInfo:GetAID()) ~= nil then
			return;
		end
	end
        
	local instInfo = pcInfo:GetInst();
	local map_partymember_iconset = frame:CreateOrGetControlSet('map_partymember_iconset', name, 0, 0);    
	map_partymember_iconset:SetTooltipType("partymap");
	map_partymember_iconset:SetTooltipArg(pcInfo:GetName(), type);

	local pm_name_rtext = GET_CHILD_RECURSIVELY(map_partymember_iconset,"pm_name","ui::CRichText")
	pm_name_rtext:SetTextByKey("pm_fname", pcInfo:GetName())    
	local iconinfo = pcInfo:GetIconInfo();    
	SET_PM_MINIMAP_ICON(map_partymember_iconset, instInfo.hp, pcInfo:GetAID());
	TESTBOARD_SET_PM_MAPPOS(frame, map_partymember_iconset, instInfo, mapprop,actor)    
end
function  TESTBOARD_SET_PM_MAPPOS(frame, controlset, instInfo, mapprop,actor)    	
	local worldPos = actor:GetPos();
	SET_MINIMAP_CTRLSET_POS(frame, controlset, worldPos, mapprop);
end
-- function TESTBOARD_ON_AOS_OBJ_ENTER(frame, msg, str, handle, info)

-- 	local iconSize = 12;
-- 	local type = info.classID;
-- 	local iconName = "fullwhite";
--     local colorTone = "";
--     TESTBOARD_DBGOUT("AOC")
-- 	if type == 11119 then
-- 		iconName = "fullwhite";
-- 		colorTone = "FF888800";
-- 		iconSize = 4;
-- 	elseif type == 40205 then
-- 		iconName = "minimap_goddess";
-- 	elseif type == 40200 then
-- 		iconName = "minimap_portal";
-- 	elseif type == 40202 or type == 40206 then
-- 		iconName = "fullwhite";
-- 		if info.teamID == GET_MY_TEAMID() then
-- 			colorTone = "FF0000FF";
-- 		else
-- 			colorTone = "FFFF0000";
-- 		end
		
-- 		iconSize = 3;
-- 	elseif type == 40203 then -- golem
-- 		iconName = "fullwhite";
-- 		if info.teamID == GET_MY_TEAMID() then
-- 			colorTone = "FF0000FF";
-- 		else
-- 			colorTone = "FFFF0000";
-- 		end
		
-- 		iconSize = 7;
-- 	elseif type == 40204 then -- midboss
-- 		iconName = "fullwhite";
-- 		colorTone = "FF880088";
-- 		iconSize = 9;
-- 	elseif type == 0 and session.GetMyHandle() ~= handle then
-- 		iconName = "fullwhite";
-- 		if info.teamID == GET_MY_TEAMID() then
-- 			colorTone = "FF0000FF";
-- 		else
-- 			colorTone = "FFFF0000";
-- 		end
		
-- 		iconSize = 6;
-- 	end
	
-- 	if iconName == "" then
-- 		return;
-- 	end
	
-- 	local ctrlName = "__CTRL__" .. handle;
-- 	local pic = frame:CreateOrGetControl('picture', ctrlName, 500, 500, iconSize, iconSize);
-- 	tolua.cast(pic, "ui::CPicture");
-- 	pic:SetImage(iconName);
-- 	pic:SetEnableStretch(1);
-- 	pic:ShowWindow(1);
-- 	if colorTone ~= "" then
-- 		pic:SetColorTone(colorTone);
-- 	end
		
-- 	local map = frame:GetChild("map");
	
-- 	SET_AOS_PIC_POS_WORLD(frame, map, pic, info.x, info.y);
	
-- end