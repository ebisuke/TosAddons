--uie_gbg_component_status

local acutil = require('acutil')

--ライブラリ読み込み
local debug = false
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end
local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
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

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

UIMODEEXPERT = UIMODEEXPERT or {}
local stat={

}
local g = UIMODEEXPERT
g.gbg=g.gbg or {}

g.gbg.uiegbgComponentStatus = {
    new = function(parentgbg, name)
        local self = inherit(g.gbg.uiegbgComponentStatus, g.gbg.uiegbgComponentBase, parentgbg, name)
        
        return self
    end,
    initializeImpl = function(self, gbox)
        self:refresh()
        
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
    end,
    refresh=function(self)
        local gbox=self.gbox
        local gboxleft=gbox:CreateOrGetControl('groupbox','gboxleft',0,0,400,gbox:GetHeight())
        gboxleft:SetSkinName('bg')
        local text=gboxleft:CreateOrGetControl('richtext','textlabel1',5,5,100,20)
        text:SetText('{ol}{s24}Basic Status')
        local gboxcenter=gbox:CreateOrGetControl('groupbox','gboxcenter',400,0,500,gbox:GetHeight())
        gboxcenter:SetSkinName('bg')
        local text2=gbox:CreateOrGetControl('richtext','textlabel2',400,0,60,20)
        text2:SetText('{ol}{s24}Property')
        local gboxprop=gbox:CreateOrGetControl('groupbox','gboxprop',400,80,500,gbox:GetHeight()-80)
        local expup=gboxprop:CreateOrGetControl('groupbox','expupGBox',0,0,80,0)
        local expupbuff=expup:CreateOrGetControl('groupbox','expupBuffBox',80,0,gboxprop:GetWidth()-80,0)
        local textotal=expup:CreateOrGetControl('richtext','totalExpUpValueText',400,20,100,20)
        AUTO_CAST(textotal)
        textotal:SetFormat('{ol}{s20}Total EXPUP:+%s%%')
        textotal:AddParamInfo('value', '0');
        local texlike=gbox:CreateOrGetControl('richtext','loceCountText',400,40,100,20)
        AUTO_CAST(texlike)
        texlike:SetFormat('{ol}{s20}いいね：%s')
        texlike:AddParamInfo('Count', '0');
        UIE_GBG_COMPONENT_STATUS_STATUS_INFO(gbox,gboxprop)
    end,
   
}

UIMODEEXPERT = g

function UIE_GBG_COMPONENT_SHOP_RCLICK(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            local self = g.gbg.getComponentInstanceByName(argstr)
            self:buyItem(argnum, 1)
            imcSound.PlaySoundEvent("button_inven_click_item");
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function UIE_GBG_COMPONENT_STATUS_STATUS_INFO(topgbox,gbox)
    local frame = gbox;
    local MySession = session.GetMyHandle()
    local CharName = info.GetName(MySession);
    --local NameObj = GET_CHILD(frame, "NameText", "ui::CRichText");
    --local LevJobObj = GET_CHILD(frame, "LevJobText", "ui::CRichText");
    local lv = info.GetLevel(session.GetMyHandle());
    local job = info.GetJob(session.GetMyHandle());
    local etc = GetMyEtcObject();
    if etc.RepresentationClassID ~= 'None' then
        local repreJobCls = GetClassByType('Job', etc.RepresentationClassID);
        if repreJobCls ~= nil then
            job = repreJobCls.ClassID;
        end
    end

    local gender = info.GetGender(session.GetMyHandle());
    local jobCls = GetClassByType("Job", job);
    local jName = GET_JOB_NAME(jobCls, gender);

    local lvText = jName;

    --NameObj:SetText('{@st53}' .. CharName)
    --LevJobObj:SetText('{@st41}{s20}' .. lvText)

    local pc = GetMyPCObject();
    local opc = nil;

    local gboxctrl = gbox
    local y = 0;

    y = y + 10;

    local expupGBox = GET_CHILD(gboxctrl, 'expupGBox');
    SETEXP_SLOT(expupGBox);
    y = y + expupGBox:GetHeight() + 10;

    local returnY = STATUS_HIDDEN_JOB_UNLOCK_VIEW(pc, opc, frame, gboxctrl, y);
    if returnY ~= y then y = returnY + 3; end

    local returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MHP", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MSP", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "RHP", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "RSP", y);
    y = returnY + 24;


    returnY = STATUS_ATTRIBUTE_VALUE_RANGE_NEW(pc, opc, frame, gboxctrl, "PATK", "MINPATK", "MAXPATK", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_RANGE_NEW(pc, opc, frame, gboxctrl, "PATK_SUB", "MINPATK_SUB", "MAXPATK_SUB", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_RANGE_NEW(pc, opc, frame, gboxctrl, "MATK", "MINMATK", "MAXMATK", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "HEAL_PWR", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "SR", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "HR", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MHR", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "BLK_BREAK", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "CRTATK", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "CRTMATK", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "CRTHR", y);
    y = returnY + 10;


    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "DEF", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MDEF", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "SDR", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "DR", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "BLK", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "CRTDR", y);
    y = returnY + 10;


    returnY = STATUS_ATTRIBUTE_VALUE_DIVISIONBYTHOUSAND_NEW(pc, opc, frame, gboxctrl, "MaxSta", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "NormalASPD", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "SkillASPD", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MSPD", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_WITH_PERCENT_SYMBOL(pc, opc, frame, gboxctrl, "CastingSpeed", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_WITH_PERCENT_SYMBOL(pc, opc, frame, gboxctrl, "HateRate", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MaxWeight", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "LootingChance", y);
    y = returnY + 10;

    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Add_Damage_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "ResAdd_Damage", y);
    y = returnY + 10;  -- 종류가 바뀌는 부분


    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Aries_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Slash_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Strike_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Arrow_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Cannon_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Gun_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Melee_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Fire_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Ice_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Lightning_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Earth_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Poison_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Dark_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Holy_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Magic_Soul_Atk", y);
    y = returnY + 10; -- 종류가 달라지면 10만큼 더 아래로


    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "DefAries", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "DefSlash", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "DefStrike", y);
    y = returnY + 10;


    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "SmallSize_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MiddleSize_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "LargeSize_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "BOSS_ATK", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Ghost_Atk", y);
    y = returnY + 10;

    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "MiddleSize_Def", y);
    y = returnY + 10;

    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Cloth_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Leather_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Iron_Atk", y);
    y = returnY + 10; 


    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Cloth_Def", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Leather_Def", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Iron_Def", y);
    y = returnY + 10;

    
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Forester_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Widling_Atk", y);    
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Klaida_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Paramune_Atk", y);
    if returnY ~= y then y = returnY + 3; end
    returnY = STATUS_ATTRIBUTE_VALUE_NEW(pc, opc, frame, gboxctrl, "Velnias_Atk", y);
    y = returnY + 10;

    -- Property Name은  calc_property_pc.lua 에서 SCR_GET_Cloth_ATK 와 일치

    -- STATUS_ATTRIBUTE_VALUE_RANGE(pc, opc, frame, gboxctrl, "PATK", "MINPATK", "MAXPATK");
    -- STATUS_ATTRIBUTE_VALUE_RANGE(pc, opc, frame, gboxctrl, "MATK", "MINMATK", "MAXMATK");
    -- STATUS_ATTR_SET_PERCENT(pc, opc, frame, gboxctrl, "CRTHR");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "CRTHR");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "SR");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "HR");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "Fire_Atk");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "Ice_Atk");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "Lightning_Atk");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "Poison_Atk");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "Holy_Atk");
    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "Dark_Atk");



    -- STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "DEF");
    STATUS_ATTR_SET_PERCENT(pc, opc, frame, gboxctrl, "BLK");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "CRTDR");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "SDR");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "DR");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "ResFire");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "ResIce");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "ResLightning");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "ResSoul");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "ResPoison");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "ResHoly");
    STATUS_ATTRIBUTE_VALUE(pc, opc, frame, gboxctrl, "ResDark");
    y = y + 10;
	
	
	
	returnY = STATUS_ATTRIBUTE_BOX_TITLE(pc, opc, frame, gboxctrl, ScpArgMsg("ItemEnchantOption"), y);
    if returnY ~= y then
        y = returnY + 5;
    end
	
	local itemRareOptionList = { 'EnchantMainWeaponDamageRate', 'EnchantSubWeaponDamageRate', 'EnchantBossDamageRate', 'EnchantMeleeReducedRate', 'EnchantMagicReducedRate', 'EnchantPVPDamageRate', 'EnchantPVPReducedRate', 'EnchantCriticalDamage_Rate', 'EnchantCriticalHitRate', 'EnchantCriticalDodgeRate', 'EnchantHitRate', 'EnchantDodgeRate', 'EnchantBlockBreakRate', 'EnchantBlockRate', 'EnchantMSPD', 'EnchantSR' };
	
	for i = 1, #itemRareOptionList do
		local itemRareOption = itemRareOptionList[i];
	    returnY = STATUS_ITEM_RARE_OPTION_VALUE(pc, opc, frame, gboxctrl, itemRareOption, y);
	    if returnY ~= y then
	        y = returnY + 3;
	    end
	end
    
	y = y + 10;
	
    frame:Invalidate();

    local loceCountText = GET_CHILD_RECURSIVELY(topgbox, "loceCountText")
    loceCountText:SetTextByKey("Count", session.likeit.GetWhoLikeMeCount());

end