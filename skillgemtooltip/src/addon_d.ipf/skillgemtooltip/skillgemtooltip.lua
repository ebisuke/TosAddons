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
    if(keyboard.IsKeyPressed("LALT")==1 or joystick.IsKeyPressed("JOY_TARGET_CHANGE")==1)then
        return UPDATE_ITEM_TOOLTIP_OLD(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)

    else
        return
    end
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
            local text=tooltipframe:CreateOrGetControl("richtext", "mark_skillgem", 0, 0, 100, 20);
            text:SetText("{ol}Skill Gem Tooltip")
            text:SetGravity(ui.LEFT,ui.BOTTOM)
            return UPDATE_SKILL_DUMMY_TOOLTIP(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)	
        end
    end
    return UPDATE_ITEM_TOOLTIP_OLD(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)
end