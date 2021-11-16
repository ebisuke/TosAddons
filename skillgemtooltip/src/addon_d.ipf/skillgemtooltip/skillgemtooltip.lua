--skillgemtooltip
--アドオン名（大文字）
local addonName = "skillgemtooltip"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
g.version = 0

--ライブラリ読み込み
CHAT_SYSTEM("[SGT]loaded")
local acutil = require("acutil")
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
local function GET_JOB_NAME_BY_SKILLTREE_CLS(skillTreeCls)
	local tokList = StringSplit(skillTreeCls.ClassName, '_');
	return tokList[1]..'_'..tokList[2];
end

local function DBGOUT(msg)
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end

local function CloneControls(src,dest)
    local d=dest:CreateOrGetControl(
        src:GetClassName(),
        src:GetName(),
        src:GetX(),
        src:GetY(),
        src:GetWidth(),
        src:GetHeight())
    AUTO_CAST(d)
    d:CloneFrom(src)
    for i=0,src:GetChildCount()-1 do
        local s=src:GetChildByIndex(i)
        CloneControls(s,d)
    end
    
end

--マップ読み込み時処理（1度だけ）
function SKILLGEMTOOLTIP_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            acutil.setupHook(SKILLGEMTOOLTIP_UPDATE_ITEM_TOOLTIP,"UPDATE_ITEM_TOOLTIP")

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function SKILLGEMTOOLTIP_UPDATE_ITEM_TOOLTIP(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)	
   
	tolua.cast(tooltipframe, "ui::CTooltipFrame");
	local itemObj, isReadObj = nil;	
	if tooltipobj ~= nil then
		itemObj = tooltipobj;
		isReadObj = 0;
	else
		itemObj, isReadObj = GET_TOOLTIP_ITEM_OBJECT(strarg, numarg2, numarg1);
	end

	if itemObj == nil then
		return;
	end

	if nil ~= itemObj and itemObj.GroupName == "Unused" then
		tooltipframe:Resize(1, 1);
        return;
	end
    local itemcls = GetClassByType('Item', itemObj.ClassID)
    if itemcls ~= nil then
        if TryGetProp(itemcls, 'StringArg', 'None') == 'SkillGem' then
            return EBI_try_catch {
                try = function()
    
                    return SKILLGEMTOOLTIP_UPDATE_SKILL_DUMMY_TOOLTIP(tooltipframe,  TryGetProp(itemcls, 'SkillName', 'None') , numarg1, numarg2, userdata, tooltipobj, noTradeCnt,itemObj)	
                end,
                catch = function(error)
                    ERROUT(error)
                end
            }
        end
    end
    return UPDATE_ITEM_TOOLTIP_OLD(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)
end

function SKILLGEMTOOLTIP_UPDATE_SKILL_DUMMY_TOOLTIP(frame, strarg, numarg1, numarg2, userData, obj,noTrade,itemObj)
	local skl = session.GetSkillByName(strarg);
	local sklObj;
	local sklLv = 1;
    local remembered_level =  nil
	if skl == nil or skl:GetObject() == nil then
		sklObj = GetClass('Skill', strarg);
		sklLv = 1;
	else
		sklObj = GetIES(skl:GetObject());
        -- modify IES directory
        remembered_level=sklObj.Level
		sklLv = sklObj.Level+1;
        sklObj.Level=sklLv
	end
	
	local buffCls = GetClassByType('Buff', numarg1);
	--ocal spendItemName, spendItemCount, captionTimeScp, captionList, captionRatioScpList = GetBuffSellerInfoByBuffName(buffCls.ClassName);

    
 
    
	--DESTROY_CHILD_BYNAME(frame:GetChild('skill_desc'), 'SKILL_CAPTION_');
    local originalWidth =390
    local originalSkillWidth =440

    --frame:Resize(frame:GetWidth()+ui.GetTooltipFrame("skill"):GetWidth(),frame:GetHeight())
    UPDATE_ITEM_TOOLTIP_OLD(frame,strarg,numarg1,numarg2,userData,obj,noTrade)
    frame:RemoveChild("skill_desc")
    local d=frame:GetChild("skill_desc")
    if(d == nil) then
         d=CloneControls(ui.GetTooltipFrame("skill"):GetChildRecursively("skill_desc"),frame)
    end
    local a=frame:GetChild("ability_desc")
    if(a == nil) then
         a=CloneControls(ui.GetTooltipFrame("skill"):GetChildRecursively("ability_desc"),frame)
    end
    local ip=frame:GetChild("icon")
    if(ip == nil) then
        ip=CloneControls(ui.GetTooltipFrame("skill"):GetChildRecursively("icon"),frame)
    end
    
	local skill_desc = GET_CHILD(frame, "skill_desc");
    skill_desc:SetGravity(ui.RIGHT,ui.TOP)
      
	local ability_desc = GET_CHILD(frame, "ability_desc");
    ability_desc:SetGravity(ui.RIGHT,ui.TOP)
    local height=frame:GetHeight()
    local sklGuid="0"
    if(skl) then
        sklGuid=skl:GetIESID()
    end
	UPDATE_SKILL_TOOLTIP(frame,strarg,sklObj.ClassID,sklGuid,userData,obj)
    	
    local text=skill_desc:CreateOrGetControl("richtext", "mark_skillgem", 0, 0, 100, 20);
    local skilltreecls = GetClassByStrProp("SkillTree", "SkillName", sklObj.ClassName);
    local jobClsName = GET_JOB_NAME_BY_SKILLTREE_CLS(skilltreecls);
    text:SetText("{ol}{#999999}Skill Gem Tooltip{/}{nl}{s20}"..GET_JOB_NAME(GetClass("Job",jobClsName), GETMYPCGENDER()))
    text:SetOffset(20,10)
    text:SetGravity(ui.LEFT,ui.TOP)
   
	skill_desc:Resize(ui.GetTooltipFrame("skill"):GetWidth(), skill_desc:GetHeight());
    skill_desc:SetOffset(0,0)
    ability_desc:SetGravity(ui.RIGHT,ui.TOP)
    ability_desc:Resize(ui.GetTooltipFrame("skill"):GetWidth(), ability_desc:GetHeight());
    ability_desc:SetOffset(0,skill_desc:GetHeight())
	frame:Resize(originalWidth+originalSkillWidth,math.max(height,skill_desc:GetHeight()+ability_desc:GetHeight()));	

    -- 
    if remembered_level then
        sklObj.Level=remembered_level
    end
end