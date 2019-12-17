--アドオン名（大文字）
local addonName = "enemystat"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "enemystat"
g.debug = true
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x=nil
g.y=nil
--ライブラリ読み込み
CHAT_SYSTEM("[ENEMYSTAT]loaded")
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
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

-- util
local function GET_MON_STAT(self, lv, statStr)
    -- Sum MaxStat --
    local allStatMax = 10 + (lv * 2);
    
    local raceType = TryGetProp(self, "RaceType", "None");
    if GetExProp(self, "EXPROP_SHADOW_INFERNAL") == 1 then
        raceType = GetExProp_Str(self, "SHADOW_INFERNAL_RACETYPE");
        if raceType == nil then
            raceType = "None";
        end
    end
    
    local raceTypeClass = GetClass("Stat_Monster_Race", raceType);
    if raceTypeClass == nil then
        return 1;
    end
    
    -- Select Stat Rate --
    local statRate = 100;
    statRate = TryGetProp(raceTypeClass, statStr, statRate);
    
    if statRate < 0 then
        statRate = 0;
    end
    
    -- All Stat Rate --
    local totalStatRate = 0;
    local statRateList = { 'STR', 'INT', 'CON', 'MNA', 'DEX' };
    
    for i = 1, #statRateList do
        local statRateTemp = TryGetProp(raceTypeClass, statRateList[i], 0);
        if statRateTemp == nil then
            statRateTemp = 0;
        end
        
        totalStatRate = totalStatRate + statRateTemp;
    end
    
    -- Calc Stat --
    local value = allStatMax * (statRate / totalStatRate);
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

local function GET_MON_ITEM_STAT(self, lv, statStr)
    return 0;
end

local function SCR_GET_MON_ADDSTAT(self, stat)
    return 0;
end

local function SCR_Get_MON_STR(self,lv)
    local statString = "STR";
    

    
    local byStat = GET_MON_STAT(self, lv, statString);
    if byStat == nil or byStat < 0 then
        byStat = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byStat + byBuff;
    
    return math.floor(value);
end

local function SCR_Get_MON_INT(self,lv)
    local statString = "INT";
    

    local byStat = GET_MON_STAT(self, lv, statString);
    if byStat == nil or byStat < 0 then
        byStat = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byStat + byBuff;
    
    return math.floor(value);
end

local function SCR_Get_MON_CON(self,lv)
    local statString = "CON";

    
    local byStat = GET_MON_STAT(self, lv, statString);
    if byStat == nil or byStat < 0 then
        byStat = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byStat + byBuff;
    
    return math.floor(value);
end

local function SCR_Get_MON_MNA(self,lv)
    local statString = "MNA";
    

    
    local byStat = GET_MON_STAT(self, lv, statString);
    if byStat == nil or byStat < 0 then
        byStat = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byStat + byBuff;
    
    return math.floor(value);
end

local function SCR_Get_MON_DEX(self,lv)
    local statString = "DEX";
    

    local byStat = GET_MON_STAT(self, lv, statString);
    if byStat == nil or byStat < 0 then
        byStat = 0;
    end
    
    local byBuff = TryGetProp(self, statString.."_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local value = byStat + byBuff;
    
    return math.floor(value);
end


local function SCR_Get_MON_MHP(self,lv)
    local monHPCount = TryGetProp(self, "HPCount", 0);
    if monHPCount > 0 then
        return math.floor(monHPCount);
    end
    
    local fixedMHP = TryGetProp(self, "FIXMHP_BM", 0);
    if fixedMHP > 0 then
        return math.floor(fixedMHP);
    end
    

    
    
    local standardMHP = math.max(30, lv);
    local byLevel = (standardMHP / 4) * lv;
    
    local stat = TryGetProp(self, "CON", 1);
    
    local byStat = (byLevel * (stat * 0.0015)) + (byLevel * (math.floor(stat / 10) * 0.005));
    
    local value = standardMHP + byLevel + byStat;
    
    local statTypeRate = 100;
    local statType = TryGetProp(self, "StatType", "None");
    if statType ~= nil and statType ~= 'None' then
        local statTypeClass = GetClass("Stat_Monster_Type", statType);
        if statTypeClass ~= nil then
            statTypeRate = TryGetProp(statTypeClass, "MHP", statTypeRate);
        end
    end
    
    statTypeRate = statTypeRate / 100;
    value = value * statTypeRate;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "MHP");
    value = value * raceTypeRate;
    
--    value = value * JAEDDURY_MON_MHP_RATE;      -- JAEDDURY
    
    local byBuff = TryGetProp(self, "MHP_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    value = value + byBuff;
    
	local monClassName = TryGetProp(self, "ClassName", "None");
	local monOriginFaction = TryGetProp(GetClass("Monster", monClassName), "Faction");
    if monOriginFaction == "Summon" then
        value = value + 5000;   -- PC Summon Monster MHP Add
    end
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_MSP(self,lv)

    local mna = self.MNA;   
    local byBuff = self.MSP_BM;
    local byLevel = math.floor((lv -1) * 6.7);
    local byStat = math.floor(mna * 13);

    local value = byLevel + byStat + byBuff;
    
    if value < 1 then
        value = 1;
    end
    return math.floor(value);
end

-- monster only
local function SCR_GET_MON_EXP(self,lv)
    if TryGetProp(self, "GiveEXP", "NO") ~= "YES" then
        return 0;
    end

    local exPropLevel = GetExProp(self, "LEVEL_FOR_EXP")
    if exPropLevel ~= nil and exPropLevel ~= 0 then
        level = exPropLevel;
    end
    
    local cls = GetClassByType("Stat_Monster", level);
    local value = TryGetProp(cls, "EXP_BASE", 0);
    
    local expValue = 100;
    local monStatType = TryGetProp(self, "StatType", "None");
    if monStatType ~= 'None' then
        local cls2 = GetClass("Stat_Monster_Type", monStatType);
        if cls2 ~= nil then
            expValue = TryGetProp(cls2, "EXP", 0);
        end
    end
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "EXP");
    
    value = value * (expValue / 100) * raceTypeRate;
    
    return math.floor(value);
end

local function SCR_GET_MON_JOBEXP(self,lv)
    if TryGetProp(self, "GiveEXP", "NO") ~= "YES" then
        return 0;
    end
    
    
    local cls = GetClassByType("Stat_Monster", level);
    local value = TryGetProp(cls, "JEXP_BASE", 0);
    
    local jexpValue = 100;
    local monStatType = TryGetProp(self, "StatType", "None");
    if monStatType ~= 'None' then
        local cls2 = GetClass("Stat_Monster_Type", monStatType);
        if cls2 ~= nil then
            jexpValue = TryGetProp(cls2, "JEXP", 0);
        end
    end
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "JEXP");
    
    value = value * (jexpValue / 100) * raceTypeRate;
    
    return math.floor(value);
end

local function SCR_Get_MON_DEF(self,lv)
    local fixedDEF = TryGetProp(self, "FixedDefence");
    if fixedDEF ~= nil and fixedDEF > 0 then
        return fixedDEF;
    end

    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "CON");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = 0;
    local className = TryGetProp(self, "ClassName");
    if className ~= nil and (className == "pcskill_skullsoldier" or className == "pcskill_skullarcher" or className == "pcskill_skullwizard") then
        byItem = SCR_MON_OWNERITEM_ARMOR_CALC(self);
    else
        byItem = SCR_MON_ITEM_ARMOR_DEF_CALC(self);
    end 
    
    local value = byLevel + byStat + byItem;
    --아이템 계산 후 배율로 올려준다--
    local statTypeRate = SCR_MON_STAT_RATE(self, "DEF")
    statTypeRate = statTypeRate / 100;
    value = value * statTypeRate;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "DEF");
    
    value = value * raceTypeRate;
    
    local byBuff = TryGetProp(self, "DEF_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byRateBuff = TryGetProp(self, "DEF_RATE_BM");
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = value * byRateBuff;
    
--    value = value * JAEDDURY_MON_DEF_RATE;      -- JAEDDURY
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
        value = 0;
    end
    
    return math.floor(value)
end



local function SCR_Get_MON_MDEF(self,lv)
    local fixedDEF = TryGetProp(self, "FixedDefence");
    if fixedDEF ~= nil and fixedDEF > 0 then
        return fixedDEF;
    end
    

    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "CON");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = 0;
    local className = TryGetProp(self, "ClassName");
    if className ~= nil and (className == "pcskill_skullsoldier" or className == "pcskill_skullarcher" or className == "pcskill_skullwizard") then
        byItem = SCR_MON_OWNERITEM_ARMOR_CALC(self);
    else
        byItem = SCR_MON_ITEM_ARMOR_MDEF_CALC(self);
    end 
    
    local value = byLevel + byStat + byItem;
    --아이템 계산 후 배율로 올려준다--
    local statTypeRate = SCR_MON_STAT_RATE(self, "MDEF")
    statTypeRate = statTypeRate / 100;
    value = value * statTypeRate;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "MDEF");
    
    value = value * raceTypeRate;
    
    local byBuff = TryGetProp(self, "MDEF_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byRateBuff = TryGetProp(self, "MDEF_RATE_BM");
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = value * byRateBuff;
    
--    value = value * JAEDDURY_MON_DEF_RATE;      -- JAEDDURY
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
        value = 0;
    end
    
    return math.floor(value)
end



local function SCR_Get_MON_HR(self,lv)

    
    local byLevel = lv * 1.0;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "HR");
    
    local value = byLevel * raceTypeRate;
    
    local byBuff = TryGetProp(self, "HR_BM", 0);
    
    local byRateBuff = TryGetProp(self, "HR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_DR(self,lv)
    if self.HPCount > 0 then
        return 0;
    end

    local byLevel = lv * 1.0;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "DR");
    
    local value = byLevel * raceTypeRate;
    
    local byBuff = TryGetProp(self, "DR_BM", 0);
    
    local byRateBuff = TryGetProp(self, "DR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_MHR(self)
    local value = 0;    
    value = value + self.MHR_BM;
    
    return math.floor(value);   
end



local function SCR_Get_MON_CRTHR(self,lv)

    local byLevel = lv * 1.0;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "CRTHR");
    
    local value = byLevel * raceTypeRate;
    
    local byBuff = TryGetProp(self, "CRTHR_BM", 0);
    
    local byRateBuff = TryGetProp(self, "CRTHR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_CRTDR(self,lv)

    local byLevel = lv * 1.0;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "CRTDR");
    
    local value = byLevel * raceTypeRate;
    
    local byBuff = TryGetProp(self, "CRTDR_BM", 0);
	
    local byRateBuff = TryGetProp(self, "CRTDR_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
	
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_CRTATK(self,lv)
  
    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "DEX");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local value = byLevel + byStat;
    
    return math.floor(value);
end

local function SCR_Get_MON_CRTMATK(self,lv)

    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "MNA");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local value = byLevel + byStat;
    
    return math.floor(value);
end

local function SCR_Get_MON_MINPATK(self,lv)

    if lv == nil then
        lv = 1;
    end
    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "STR");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = SCR_MON_ITEM_WEAPON_CALC(self);
    
    local value = byLevel + byStat + byItem;
    --아이템 계산 후 배율로 올려준다--
    local statTypeRate = SCR_MON_STAT_RATE(self, "ATK")
    statTypeRate = statTypeRate / 100;
    value = value * statTypeRate;
    
    local monAtkRange = TryGetProp(self, "ATK_RANGE");
    if monAtkRange == nil then
        monAtkRange = 100;
    end
    
    local range = MinMaxCorrection(monAtkRange, 100, 200);
    
    value = value * (2.0 - range / 100.0);
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "PATK");
	
    value = value * raceTypeRate;
    
    local byBuff = 0;
    local byBuffList = { "PATK_BM", "MINPATK_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local rateBuffList = {'PATK_RATE_BM', 'MINPATK_RATE_BM' };
    local byRateBuff = 0;
    for i = 1, #rateBuffList do
        local rateBuff = TryGetProp(self, rateBuffList[i]);
        if rateBuff ~= nil then
            byRateBuff = byRateBuff + rateBuff;
        end
    end
    
    byRateBuff = value * byRateBuff;
    
    value = value + byBuff + byRateBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_MAXPATK(self,lv)


    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "STR");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = SCR_MON_ITEM_WEAPON_CALC(self);
    
    local value = byLevel + byStat + byItem
    --아이템 계산 후 배율로 올려준다--
    local statTypeRate = SCR_MON_STAT_RATE(self, "ATK")
    statTypeRate = statTypeRate / 100;
    value = value * statTypeRate;
    
    local monAtkRange = TryGetProp(self, "ATK_RANGE");
    if monAtkRange == nil then
        monAtkRange = 100;
    end
    
    local range = MinMaxCorrection(monAtkRange, 100, 200);
    
    value = value * (range / 100.0)
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "PATK");
    
    value = value * raceTypeRate;
    
    local byBuff = 0;
    local byBuffList = { "PATK_BM", "MAXPATK_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local rateBuffList = {'PATK_RATE_BM', 'MAXPATK_RATE_BM' };
    local byRateBuff = 0;
    for i = 1, #rateBuffList do
        local rateBuff = TryGetProp(self, rateBuffList[i]);
        if rateBuff ~= nil then
            byRateBuff = byRateBuff + rateBuff;
        end
    end
    
    byRateBuff = value * byRateBuff;
    
    value = value + byBuff + byRateBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_MINMATK(self,lv)

    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "INT");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = SCR_MON_ITEM_WEAPON_CALC(self);
    
    local value = byLevel + byStat + byItem;
    --아이템 계산 후 배율로 올려준다--
    local statTypeRate = SCR_MON_STAT_RATE(self, "ATK")
    statTypeRate = statTypeRate / 100;
    value = value * statTypeRate;
    
    local monAtkRange = TryGetProp(self, "ATK_RANGE");
    if monAtkRange == nil then
        monAtkRange = 100;
    end
    
    local range = MinMaxCorrection(monAtkRange, 100, 200);
    
    value = value * (2.0 - range / 100.0);
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "MATK");
    
    value = value * raceTypeRate;
    
    local byBuff = 0;
    local byBuffList = { "MATK_BM", "MINMATK_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local rateBuffList = {'MATK_RATE_BM', 'MINMATK_RATE_BM' };
    local byRateBuff = 0;
    for i = 1, #rateBuffList do
        local rateBuff = TryGetProp(self, rateBuffList[i]);
        if rateBuff ~= nil then
            byRateBuff = byRateBuff + rateBuff;
        end
    end
    
    byRateBuff = value * byRateBuff;
    
    value = value + byBuff + byRateBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_MAXMATK(self,lv)

    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "INT");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 2) + (math.floor(stat / 10) * (byLevel * 0.05));
    
    local byItem = SCR_MON_ITEM_WEAPON_CALC(self);
    
    local value = byLevel + byStat + byItem;
    --아이템 계산 후 배율로 올려준다--
    local statTypeRate = SCR_MON_STAT_RATE(self, "ATK")
    statTypeRate = statTypeRate / 100;
    value = value * statTypeRate;
    
    local monAtkRange = TryGetProp(self, "ATK_RANGE");
    if monAtkRange == nil then
        monAtkRange = 100;
    end
    
    local range = MinMaxCorrection(monAtkRange, 100, 200);
    
    value = value * (range / 100.0);
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "MATK");
    
    value = value * raceTypeRate;
    
    local byBuff = 0;
    local byBuffList = { "MATK_BM", "MAXMATK_BM" };
    for i = 1, #byBuffList do
        local byBuffTemp = TryGetProp(self, byBuffList[i]);
        if byBuffTemp == nil then
            byBuffTemp = 0;
        end
        
        byBuff = byBuff + byBuffTemp;
    end
    
    local rateBuffList = {'MATK_RATE_BM', 'MAXMATK_RATE_BM' };
    local byRateBuff = 0;
    for i = 1, #rateBuffList do
        local rateBuff = TryGetProp(self, rateBuffList[i]);
        if rateBuff ~= nil then
            byRateBuff = byRateBuff + rateBuff;
        end
    end
    
    byRateBuff = value * byRateBuff;
    
    value = value + byBuff + byRateBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_BLKABLE(self)
    if self.HPCount > 0 then
        return 0;
    end
    
    local value = TryGetProp(self, 'Blockable', 0);
    
    return value;
end

local function SCR_Get_MON_BLK(self,lv)
    if TryGetProp(self, "BLKABLE", 0) == 0 then
        return 0;
    end
    

    local byLevel = lv * 1.0;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "BLK");
    
    local value = byLevel * raceTypeRate;
    
    local byBuff = TryGetProp(self, "BLK_BM", 0);
	
    local byRateBuff = TryGetProp(self, "BLK_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_BLK_BREAK(self,lv)

    
    local byLevel = lv * 1.0;
    
    local raceTypeRate = SCR_RACE_TYPE_RATE(self, "BLK_BREAK");
    
    local value = byLevel * raceTypeRate;
    
    local byBuff = TryGetProp(self, "BLK_BREAK_BM", 0);
    
    local byRateBuff = TryGetProp(self, "BLK_BREAK_RATE_BM", 0);
    byRateBuff = math.floor(value * byRateBuff);
    
    value = value + byBuff + byRateBuff;
    
    if value < 0 then
    	value = 0;
    end
    
    return math.floor(value);
end


-- old

local function SCR_Get_MON_KDArmorType(self)
    if self.HPCount > 0 then
        return 9999;
    end
    
    local value = self.KDArmor;
    local buffList = { "Safe", "PainBarrier_Buff", "Lycanthropy_Buff", "Marschierendeslied_Buff", "Methadone_Buff", "Mon_PainBarrier_Buff", "SkullFollowPainBarrier_Buff" };
    for i = 1, #buffList do
        if IsBuffApplied(self, buffList[i]) == 'YES' then
            value = 9999;
        end
    end
    
    return value;
end

local function SCR_GET_MON_RHPTIME(self)
    return 10000;
end

local function SCR_GET_COMPANION_RHPTIME(self)
    return 5000;
end

local function SCR_GET_MON_MSHIELD(self)
    
    return self.ShieldRate/100 * self.MHP;

end

-- Regenerate HP
local function SCR_Get_MON_RHP(self)
    if self.HPCount > 0 then
        return 0;
    end
    
    if GetBuffByProp(self, 'Keyword', 'Curse') ~= nil then
        return 0;
    end
    
    local value = TryGetProp(self, "RHP_BM");
    
    return value;
end

-- Attack damage


--local function GET_MON_TABLE_VALUE(self, propName)
--  local lv = self.Lv;
--  local cls = GetClassByType("Stat_Monster", lv);

--  local value = cls[propName] + self[propName .. "_BM"];
--  return math.floor(value);
--end



-- Critical defence
local function SCR_Get_MON_CRTDEF(self,lv)

    local value = lv;
    value = value + self.CRTDEF_BM;
    return math.floor(value);
end

-- Dodge rating reduce
local function SCR_Get_MON_DRR(self)

    local value = 25;
    value = value + self.DRR_BM;
    return math.floor(value);
end

-- Threatening
local function SCR_Get_MON_TR(self)

    local value = 10;
    value = value + self.TR_BM;
    return math.floor(value);
end

-- Add
local function SCR_GET_MON_FIRE_ATK(self)
    local attributeName = "Fire";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_ICE_ATK(self)
    local attributeName = "Ice";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_POISON_ATK(self)
    local attributeName = "Poison";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_LIGHTNING_ATK(self)
    local attributeName = "Lightning";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_SOUL_ATK(self)
    local attributeName = "Soul";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_EARTH_ATK(self)
    local attributeName = "Earth";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_HOLY_ATK(self)
    local attributeName = "Holy";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_DARK_ATK(self)
    local attributeName = "Dark";
    local value = SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_ATTRIBUTE_ATK_CALC(self, attributeName)
--    local lv = TryGetProp(self, "Lv", 1);
--    local byLevel = lv * 1.5;
--    
--    local byBuff = TryGetProp(self, attributeName .. "_Atk_BM", 0);
--    
--    local value = byLevel + byBuff;
--    
--    return math.floor(value);
    
    local value = TryGetProp(self, attributeName .. "_Atk_BM", 0);
    
    return math.floor(value);
end


local function SCR_Get_MON_HitRange(self)

    local value = 10;
    return math.floor(value);
end

local function SCR_Get_MON_ASPD(self)

    local value = 0;
    value = self.AniASPD * 1.25;
    value = value * (100 - self.ASPD_BM) / 100;
    if value < 500 then
        value = 500;
    elseif value > 10000 then
        value = 10000;
    end
    return math.floor(value);
end

local function SCR_GET_SKL_CAST_MON(skill)

    return skill.BasicCast;

end

local function SCR_Get_MON_MSPD(self)
 
    local fixMSPD = TryGetProp(self, "FIXMSPD_BM");
    if fixMSPD ~= nil and fixMSPD > 0 then
        return fixMSPD;
    end
    
    local wlkMSPD = TryGetProp(self, "WlkMSPD", 0);
    if wlkMSPD == 0 then
        return 0;
    end
    
    local byBuff = TryGetProp(self, "MSPD_BM", 0);
    
    local byBuffOnlyTopValue = 0;
    if IsServerSection(self) == 1 then
        local byBuffOnlyTopList = GetMSPDBuffInfoTable(self)
        if byBuffOnlyTopList ~= nil then
            for k, v in pairs(byBuffOnlyTopList) do
                if byBuffOnlyTopValue < byBuffOnlyTopList[k] then
                    byBuffOnlyTopValue = byBuffOnlyTopList[k];
                end
            end
        end
    end

    if (IsRaidField(self) == 1 and TryGetProp(self, "MonRank", "None") == "Boss") or TryGetProp(self, "StrArg1", nil) == "PartyFieldBoss" or TryGetProp(self, "StatType", nil) == "WorldRaidBoss" then
        byBuff = 0;
        byBuffOnlyTopValue = 0;
    end
    
    local moveType = GetExProp(self, 'MOVE_TYPE_CURRENT');
    if moveType ~= 0 then
        local runMSPD = TryGetProp(self, "RunMSPD", 0);
        
        local moveSpd = wlkMSPD + byBuff + byBuffOnlyTopValue;
        if moveType == 2 then
            moveSpd = runMSPD + byBuff + byBuffOnlyTopValue;
        elseif moveType == 3 then
            moveSpd = wlkMSPD + runMSPD + byBuff + byBuffOnlyTopValue;
        end
        
        return moveSpd;
    end
    
    local value = wlkMSPD + byBuff + byBuffOnlyTopValue;
    if value < 0 then
        value = 0;
    end
    
    value = value * SERV_MSPD_FIX;
    
    return math.floor(value);
end


local function SCR_Get_MON_minRange(self)

    local value = TryGetProp(self, "MinR", 0);
    return math.floor(value);
end

local function SCR_Get_MON_maxRange(self)

    local value = TryGetProp(self, "MaxR", 0);
    
    local byBuff = TryGetProp(self, "maxRange_BM", 0);
    value = value + byBuff;
    
    local minRange = TryGetProp(self, "MinR", 0);
    if value < (minRange + 2) then
        value = minRange + 2;
    elseif value > 300 then
        value = 300;
    end
    
    return math.floor(value);
end

local function SCR_Get_MON_KDPow(self)

    local value = 0;
    
    local byBuff = TryGetProp(self, "KDPow_BM", 0);
    value = value + byBuff;
    
    local monKDRank = TryGetProp(self, "KDRank", 1);
    value = value * monKDRank;
    
    return math.floor(value);
end

---------------------------------KnockDown-------------------------
local function SCR_GET_MON_KDBONUS(self,lv)
    local defaultValue = 120;
    

    local byLevel = lv * 10;
    
    local byBuff = TryGetProp(self, "KDBonus_BM", 0);
    
    local value = defaultValue + byLevel + byBuff;
    
    return math.floor(value);
end

local function SCR_GET_MON_KDDEFENCE(self,lv)
    local defaultValue = 80;
    
    local byLevel = lv * 10;
    
    local byBuff = TryGetProp(self, "KDBonus_BM", 0);
    
    local value = defaultValue + byLevel + byBuff;
    
    return math.floor(value);
end
---------------------------------------------------------------------

local function SCR_Get_MON_MGP(self)
    return 65535;
end

local function SCR_Get_MON_SR(self)
    local value = 50;
    
    local monSize = TryGetProp(self, 'Size', "S");
    
    if monSize == 'S' then
        value = 8;
    elseif monSize == 'M' then
        value = 16;
    elseif monSize == 'L' then
        value = 24;
    elseif monSize == 'XL' then
        value = 50;
    end
    
    local byBuff = TryGetProp(self, "SR_BM", 0);
    
    value = value + byBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value)
end

local function SCR_Get_MON_SDR(self)
    local fixedSDR = TryGetProp(self, 'FixedMinSDR_BM');
    if fixedSDR ~= nil and fixedSDR ~= 0 then
        return 1;
    end
    
    local value = 5;
    
    local monSDR = TryGetProp(self, 'MonSDR', 1);
    
    local monSize = TryGetProp(self, 'Size', "S");
    
    if monSize == 'S' then
        value = 1;
    elseif monSize == 'M' then
        value = 2;
    elseif monSize == 'L' then
        value = 3;
    elseif monSize == 'XL' then
        value = 5;
    end
    
    local byBuff = TryGetProp(self, 'SDR_BM', 0);
    
    value = value + byBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end

local function SCR_GET_MONSKL_COOL(skill)
    local value = TryGetProp(skill, "BasicCoolDown", 0);
    
    return value;
end

local function SCR_GET_MONSKL_SKIACLIPSE_METEOR_COOL(skill)
    local value = TryGetProp(skill, "BasicCoolDown", 0);
    
    return value;
end

local function SCR_MON_COMBOABLE(mon)
    if TryGetProp(mon, "GroupName") == "Monster" then
        return 1;
    end
    
    return 0;
end

local function SCR_GET_MON_RES_FIRE(self)
    local attributeName = "Fire";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_ICE(self)
    local attributeName = "Ice";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_POISON(self)
    local attributeName = "Poison";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_LIGHTNING(self)
    local attributeName = "Lightning";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_SOUL(self)
    local attributeName = "Soul";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_EARTH(self)
    local attributeName = "Earth";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_HOLY(self)
    local attributeName = "Holy";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_DARK(self)
    local attributeName = "Dark";
    local value = SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName);
    
    return math.floor(value);
end

local function SCR_GET_MON_RES_ATTRIBUTE_CALC(self, attributeName,lv)

    local fixedFigure = 30;
    local byLevel = math.floor(((lv / 3) ^ 2) / fixedFigure) + fixedFigure 
    
    local byBuff = TryGetProp(self, "Res" .. attributeName .. "_BM", 0);
    
    local byStatType = 0;
    local statType = TryGetProp(self, "StatType", "None");
    if statType ~= nil then
        local statTypeClass = GetClass("Stat_Monster_Type", statType);
        if statTypeClass ~= nil then
            byStatType = TryGetProp(statTypeClass, "ResAttributeRate", 100)*0.01;
        end
    end
    
    local value = (byLevel * byStatType) + byBuff;
    
    return math.floor(value);
end

local function SCR_GET_MON_LIMIT_BUFF_COUNT(self)
    local value = 999;  -- 2017/9/13 --
    
--    local byBuff = TryGetProp(self, "LimitBuffCount_BM", 0);
--    if byBuff > 0 then
--      value = byBuff;
--    end
    
    return value;
end

local function CLIENT_SORCERER_SUMMONING_MON(self, caster, skl, item,lv)

    if nil == self then
        return;
    end

    if nil == caster then
        return;
    end

    if nil == skl then
        return;
    end

    self.StatType = 30
        
    local monDef = self.DEF;
    local monMDef = self.MDEF;

    local sklbonus = 1 + skl.Level * 0.1
    local itembonus = 1 + item.Level * 0.1
    self.MATK_BM = (500 + (caster.INT * sklbonus)) * itembonus
    self.PATK_BM = (500 + (caster.INT * sklbonus)) * itembonus
    
    self.DEF_BM = (monDef / 2  + (caster.MNA * sklbonus)) * itembonus
    self.MDEF_BM = (monMDef / 2 + (caster.MNA * sklbonus)) * itembonus
end

local function SCR_GET_MON_SKILLFACTORRATE(self)
    local value = 100;
    
    local byBuff = TryGetProp(self, "SkillFactorRate_BM");
    if byBuff == nil then
        byBuff = 0;
    end
    
    local byRateBuff = TryGetProp(self, "SkillFactorRate_RATE_BM");
    if byRateBuff == nil then
        byRateBuff = 0;
    end
    
    byRateBuff = value * byRateBuff;
    
    value = value + byBuff + byRateBuff;
    
    return value;
end

local function SCR_Get_MON_HEAL_PWR(self,lv)

    
    local byLevel = lv * 1.0;
    
    local stat = TryGetProp(self, "MNA");
    if stat == nil then
        stat = 1;
    end
    
    local byStat = (stat * 1) + (math.floor(stat / 10) * (byLevel * 0.03));
    
    local value = byLevel + byStat;
    
    local byBuff = 0;
    
    local byBuffTemp = TryGetProp(self, "HEAL_PWR_BM");
    if byBuffTemp ~= nil then
        byBuff = byBuff + byBuffTemp;
    end
    
    local byRateBuff = 0;

    local byRateBuffTemp = TryGetProp(self, "HEAL_PWR_RATE_BM");
    if byRateBuffTemp ~= nil then
        byRateBuff = byRateBuff + byRateBuffTemp;
    end
    
    byRateBuff = math.floor(value * byRateBuffTemp);
    
    value = value + byBuff + byRateBuff;
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end


local function SCR_Get_MON_Slash_Res(self)
    local value = 0;

    local Slash_Res = TryGetProp(self, "Slash_Res")
    if Slash_Res == nil then
        Slash_Res = 0;
    end
    
    local Slash_Def_BM = TryGetProp(self, "Slash_Def_BM")
    if Slash_Def_BM == nil then
        Slash_Def_BM = 0;
    end
    
    value = value + Slash_Res + Slash_Def_BM;
    return value;
end

local function SCR_Get_MON_Aries_Res(self)
    local value = 0;
    
    local Aries_Res = TryGetProp(self, "Aries_Res")
    if Aries_Res == nil then
        Aries_Res = 0;
    end
    
    local Aries_Def_BM = TryGetProp(self, "Aries_Def_BM")
    if Aries_Def_BM == nil then
        Aries_Def_BM = 0;
    end
    
    value = value + Aries_Res + Aries_Def_BM;
    return value;
end

local function SCR_Get_MON_Strike_Res(self)
    local value = 0;
    
    local Strike_Res = TryGetProp(self, "Strike_Res")
    if Strike_Res == nil then
        Strike_Res = 0;
    end
    
    local Strike_Def_BM = TryGetProp(self, "Strike_Def_BM")
    if Strike_Def_BM == nil then
        Strike_Def_BM = 0;
    end
    
    value = value + Strike_Res + Strike_Def_BM;
    return value;
end

local function SCR_Get_MON_Magic_Res(self)
    local value = 0;
    
    local magicRes = TryGetProp(self, "Magic_Res")
    if magicRes == nil then
        magicRes = 0;
    end

    local magicDefBM = TryGetProp(self, "Magic_Def_BM")
    if magicDefBM == nil then
        magicDefBM = 0;
    end

    value = value + magicRes + magicDefBM;

    return value;
end

local function SCR_Get_MON_Arrow_Res(self)
    local value = 0;
    
    local Arrow_Res = TryGetProp(self, "Arrow_Res")
    if Arrow_Res == nil then
        Arrow_Res = 0;
    end
    
    local Arrow_Def_BM = TryGetProp(self, "Arrow_Def_BM")
    if Arrow_Def_BM == nil then
        Arrow_Def_BM = 0;
    end
    
    value = value + Arrow_Res + Arrow_Def_BM;
    return value;
end

local function SCR_Get_MON_Gun_Res(self)
    local value = 0;
    
    local Gun_Res = TryGetProp(self, "Gun_Res")
    if Gun_Res == nil then
        Gun_Res = 0;
    end
    
    local Gun_Def_BM = TryGetProp(self, "Gun_Def_BM")
    if Gun_Def_BM == nil then
        Gun_Def_BM = 0;
    end
    
    value = value + Gun_Res + Gun_Def_BM;
    return value;
end

local function SCR_Get_MON_Cannon_Res(self)
    local value = 0;
    
    local Cannon_Res = TryGetProp(self, "Cannon_Res")
    if Cannon_Res == nil then
        Cannon_Res = 0;
    end
    
    local Cannon_Def_BM = TryGetProp(self, "Cannon_Def_BM")
    if Cannon_Def_BM == nil then
        Cannon_Def_BM = 0;
    end
    
    value = value + Cannon_Res + Cannon_Def_BM;
    return value;
end



local function SCR_RACE_TYPE_RATE(self, prop)
    -- RaceType --
    local raceTypeRate = 100;
    
    local raceType = TryGetProp(self, "RaceType", "None");
    if GetExProp(self, "EXPROP_SHADOW_INFERNAL") == 1 then
        raceType = GetExProp_Str(self, "SHADOW_INFERNAL_RACETYPE");
        if raceType == nil then
            raceType = "None";
        end
    end
    
    local raceTypeClass = GetClass("Stat_Monster_Race", raceType);
    if raceTypeClass ~= nil then
        raceTypeRate = TryGetProp(raceTypeClass, prop, raceTypeRate);
        --방어력, 마법방어력 평균치 적용--
        if prop == "DEF" or prop == "MDEF" then
            local statType = TryGetProp(self, "StatType", "None");
            if statType ~= nil and statType ~= 'None' then
                local statTypeClass = GetClass("Stat_Monster_Type", statType);
                if statTypeClass ~= nil then
                    local averge_def = TryGetProp(statTypeClass, "AVERAGE_DEF", nil);
                    if averge_def ~= nil and averge_def ~= 0 then
                        local defTypeList = {"DEF", "MDEF"}
                        local raceTypeRateTable = {};
                        for i = 1, #defTypeList do
                            raceTypeRateTable[#raceTypeRateTable + 1] = TryGetProp(raceTypeClass, defTypeList[i], raceTypeRate);
                        end
                
                        if averge_def == 1 then
                            if raceTypeRateTable[1] >= raceTypeRateTable[2] then
                                raceTypeRate = raceTypeRateTable[2];
                            else
                                raceTypeRate = raceTypeRateTable[1];
                            end
                        elseif averge_def == 2 then
                            if raceTypeRateTable[1] >= raceTypeRateTable[2] then
                                raceTypeRate = raceTypeRateTable[1];
                            else
                                raceTypeRate = raceTypeRateTable[2];
                            end
                        end
                    end
                end
            end
        end
    end
    
    raceTypeRate = raceTypeRate / 100;
    
    if raceTypeRate < 0 then
        raceTypeRate = 0;
    end
    
    
    
    -- Size --
    local sizeTypeRate = 100;
    
    local sizeType = TryGetProp(self, "Size", "None");
    if GetExProp(self, "EXPROP_SHADOW_INFERNAL") == 1 then
        sizeType = GetExProp_Str(self, "SHADOW_INFERNAL_SIZE");
        if sizeType == nil then
            sizeType = "None";
        end
    end
    
    if sizeType ~= nil then
        local sizeTypeClass = GetClass("Stat_Monster_Race", sizeType);
        if sizeTypeClass ~= nil then
            sizeTypeRate = TryGetProp(sizeTypeClass, prop, sizeTypeRate);
        end
    end
    
    sizeTypeRate = sizeTypeRate / 100;
    
    if sizeTypeRate < 0 then
        sizeTypeRate = 0;
    end
    
    
    
    -- MonRank --
    local rankTypeRate = 100;
    
    local rankType = TryGetProp(self, "MonRank", "None");
    
    if rankType ~= nil then
        local rankTypeClass = GetClass("Stat_Monster_Race", rankType);
        if rankTypeClass ~= nil then
            rankTypeRate = TryGetProp(rankTypeClass, prop, rankTypeRate);
        end
    end
    
    rankTypeRate = rankTypeRate / 100;
    
    if rankTypeRate < 0 then
        rankTypeRate = 0;
    end
    
    local value = raceTypeRate * sizeTypeRate * rankTypeRate;
    
    return value;
end



local function SCR_MON_ITEM_WEAPON_CALC(self,lv)
	local monClassName = TryGetProp(self, "ClassName", "None");
	local monOriginFaction = TryGetProp(GetClass("Monster", monClassName), "Faction");
    if monOriginFaction == "Summon" then
        return 0;
    end
    

    lv = math.max(1, lv - 30);
    
    local value = 20 + (lv * 5);
    
    local defList = { };
    defList["Cloth"] = 1.0;
    defList["Leather"] = 1.5 ;
    defList["Iron"] = 1.0;
    
    local armorMaterial = TryGetProp(self, "ArmorMaterial", "None");
    if defList[armorMaterial] ~= nil then
        value = value * defList[armorMaterial];
    end
    
    local byReinforce = 0;
    local byTranscend = 0;
    
    local statType = TryGetProp(self, "StatType", "None");
    if statType ~= nil then
        local statTypeClass = GetClass("Stat_Monster_Type", statType);
        if statTypeClass ~= nil then
            local itemGrade = TryGetProp(statTypeClass, "WeaponGrade", "Normal")
            local basicGradeRatio, reinforceGradeRatio = SCR_MON_ITEM_GRADE_RATE(self, itemGrade);
            value = math.floor(value * basicGradeRatio);
            
            local reinforceValue = TryGetProp(statTypeClass, "ReinforceWeapon", 0);
            byReinforce = SCR_MON_ITEM_REINFORCE_WEAPON_CALC(self, lv, reinforceValue, reinforceGradeRatio);
            
            local itemTranscend = TryGetProp(statTypeClass, "TranscendWeapon", 0);
            local transcendValue = SCR_MON_ITEM_TRANSCEND_CALC(self, itemTranscend);
            byTranscend = math.floor(value * transcendValue);
        end
    end
    
    value = value + byReinforce + byTranscend;
    
    return math.floor(value);
end

local function SCR_MON_ITEM_ARMOR_DEF_CALC(self)
    return SCR_MON_ITEM_ARMOR_CALC(self, "DEF");
end

local function SCR_MON_ITEM_ARMOR_MDEF_CALC(self)
    return SCR_MON_ITEM_ARMOR_CALC(self, "MDEF");
end


local function SCR_MON_ITEM_ARMOR_CALC(self, defType,lv)

    lv = math.max(1, lv - 30);

    local value = (40 + (lv * 8));
    local statType = TryGetProp(self, "StatType", "None");
    local statTypeClass = nil;
    if statType ~= nil then
        statTypeClass = GetClass("Stat_Monster_Type", statType);
    end
    
    if defType ~= nil then
        local defClass = GetClass("item_grade", "armorMaterial_" .. defType);
        local armorMaterial = TryGetProp(self, "ArmorMaterial", "None");
        local defRatio = TryGetProp(defClass, armorMaterial, 1);
        -- 물리 방어력, 마법 방어력 평균치 적용 --
        if statTypeClass ~= nil then
            local averge_def = TryGetProp(statTypeClass, "AVERAGE_DEF", nil);
            if averge_def ~= nil and averge_def ~= 0 then
                local defTypeList = {"DEF", "MDEF"}
                local defRatioTable = {};
                for i = 1, #defTypeList do
                    local defClassType = GetClass("item_grade", "armorMaterial_" .. defTypeList[i]);
                    defRatioTable[#defRatioTable + 1] = TryGetProp(defClassType, armorMaterial, 1);
                end
                
                if averge_def == 1 then
                    if defRatioTable[1] >= defRatioTable[2] then
                        defRatio = defRatioTable[2];
                    else
                        defRatio = defRatioTable[1];
                    end
                elseif averge_def == 2 then
                    if defRatioTable[1] >= defRatioTable[2] then
                        defRatio = defRatioTable[1];
                    else
                        defRatio = defRatioTable[2];
                    end
                end
            end
        end
        
        if defRatio ~= nil then
            value = value * defRatio;
        end
    end
    
    local byReinforce = 0;
    local byTranscend = 0;

    if statType ~= nil then
        if statTypeClass ~= nil then
            local itemGrade = TryGetProp(statTypeClass, "ArmorGrade", "C")
            local basicGradeRatio, reinforceGradeRatio = SCR_MON_ITEM_GRADE_RATE(self, itemGrade);
            value = math.floor(value * basicGradeRatio);
            
            local reinforceValue = TryGetProp(statTypeClass, "ReinforceArmor", 0);
            byReinforce = SCR_MON_ITEM_REINFORCE_ARMOR_CALC(self, lv, reinforceValue, reinforceGradeRatio);
            
            local itemTranscend = TryGetProp(statTypeClass, "TranscendArmor", 0);
            local transcendValue = SCR_MON_ITEM_TRANSCEND_CALC(self, itemTranscend);
            byTranscend = math.floor(value * transcendValue);
        end
    end
    
    value = value + byReinforce + byTranscend;
    
    return math.floor(value);
end

local function SCR_MON_ITEM_GRADE_RATE(self, itemGrade)
    if itemGrade == nil then
        itemGrade = "Normal";
    end

--    if GetExProp(self, "EXPROP_SHADOW_INFERNAL") == 1 then
--        monRank = GetExProp_Str(self, "SHADOW_INFERNAL_MONRANK");
--    end
    
    local gradeList = { "Normal", "Magic", "Rare", "Unique", "Legend" };
    local gradeIndex = table.find(gradeList, itemGrade);

    if gradeIndex == 0 then
        gradeIndex = 1;
    end

    local basicGradeRatio = SCR_GET_ITEM_GRADE_RATIO(gradeIndex, "BasicRatio");
    local reinforceGradeRatio = SCR_GET_ITEM_GRADE_RATIO(gradeIndex, "ReinforceRatio");

    return basicGradeRatio, reinforceGradeRatio;
end

local function SCR_MON_ITEM_REINFORCE_WEAPON_CALC(self, lv, reinforceValue, reinforceGradeRatio)
    local value = 0;
    
    value = math.floor((reinforceValue + (math.max(1, lv - 50) * (reinforceValue * (0.08 + (math.floor((math.min(21, reinforceValue) - 1) / 5) * 0.015 ))))));
    value = math.floor(value * reinforceGradeRatio);
    
    return value;
end

local function SCR_MON_ITEM_REINFORCE_ARMOR_CALC(self, lv, reinforceValue, reinforceGradeRatio)
    local value = 0;
    value = math.floor((reinforceValue + (math.max(1, lv - 50) * (reinforceValue * (0.12 + (math.floor((math.min(21, reinforceValue) - 1) / 5) * 0.0225 ))))) * 1.25);
    value = math.floor(value * reinforceGradeRatio);
    
    value = value * 2;  -- 방어구는 무기의 2배 --
    
    return value;
end

local function SCR_MON_ITEM_TRANSCEND_CALC(self, transcendValue)
    local value = transcendValue * 0.1;
    
    return value;
end

local function SCR_MON_OWNERITEM_ARMOR_CALC(self,lv, defType)
    local lv = TryGetProp(self, "Lv", 1);
    lv = math.max(1, lv - 30);
    
    local value = (40 + (lv * 8));
    if defType ~= nil then
        local defClass = GetClass("item_grade", "armorMaterial_" .. defType);
        local armorMaterial = TryGetProp(self, "ArmorMaterial", "None");
        local defRatio = TryGetProp(defClass, armorMaterial, 1);
        if defRatio ~= nil then
            value = value * defRatio;
        end
    end

    local owner = GetOwner(self);
    if owner == nil then 
        return;
    end

    local itemSpotList = { "SHIRT", "PANTS", "GLOVES", "BOOTS" };
    local listCnt = #itemSpotList;
    local total_grade = 0;
    local total_reinfroce = 0;
    local total_transcend = 0;
    
    for i = 1, listCnt do
        local item = GetEquipItem(owner, itemSpotList[i]);
        if item == nil then return end;

        local item_grade = TryGetProp(item, "ItemGrade", 1);
        local item_reinforce = TryGetProp(item, "Reinforce_2", 0);
        local item_transcend = TryGetProp(item, "Transcend", 0);

        -- owner item grade
        local byGrade = 0;
        local gradeRatio = SCR_GET_ITEM_GRADE_RATIO(item_grade, "BasicRatio");
        local reinforcegradeRatio = SCR_GET_ITEM_GRADE_RATIO(item_grade, "ReinforceRatio");
        value = value * gradeRatio
        byGrade = gradeRatio;
        
        -- owner item reinforce
        local byReinforce = SCR_MON_ITEM_REINFORCE_ARMOR_CALC(owner, lv, item_reinforce, reinforcegradeRatio);

        -- owner item transcend
        local byTranscend = 0; 
        local transcendValue = SCR_MON_ITEM_TRANSCEND_CALC(owner, item_transcend);
        byTranscend = math.floor(value * transcendValue);

        total_grade = total_grade + byGrade;
        total_reinfroce = total_reinfroce + byReinforce;
        total_transcend = total_transcend + byTranscend;
    end

    total_grade = total_grade / listCnt;
    total_reinfroce = total_reinfroce / listCnt;
    total_transcend = total_transcend / listCnt;

    value = (value * total_grade) + total_reinfroce + total_transcend;
    
    return math.floor(value);
end

local function SCR_MON_STAT_RATE(self, prop)
    local statType = TryGetProp(self, "StatType", "None");
    local statTypeRate = 0;
    if statType ~= nil and statType ~= 'None' then
        local statTypeClass = GetClass("Stat_Monster_Type", statType);
        if statTypeClass ~= nil then
            statTypeRate = TryGetProp(statTypeClass, prop, statTypeRate);
        end
    end
    
    if statTypeRate == nil or statTypeRate == 0 then
        statTypeRate = 100;
    end
    
    return statTypeRate;
end

function ENEMYSTAT_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function ENEMYSTAT_LOAD_SETTINGS()
    ENEMYSTAT_DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ENEMYSTAT_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    ENEMYSTAT_UPGRADE_SETTINGS()
    ENEMYSTAT_SAVE_SETTINGS()

end


function ENEMYSTAT_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=ENEMYSTAT_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function ENEMYSTAT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('ENEMYSTAT', 'sysmenu_sys', 'ENEMYSTAT', 'ENEMYSTAT_TOGGLE_FRAME')
            --addon:RegisterMsg('GAME_START_3SEC', 'ENEMYSTAT_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "ENEMYSTAT_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("ENEMYSTAT_ON_TIMER");
            timer:Start(0.1);
            --ENEMYSTAT_SHOW(g.frame)
            
            ENEMYSTAT_INIT()
            g.frame:ShowWindow(1)
        end,
        catch = function(error)
            ENEMYSTAT_ERROUT(error)
        end
    }
end
function ENEMYSTAT_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function ENEMYSTAT_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function ENEMYSTAT_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end
--フレーム場所保存処理
function ENEMYSTAT_END_DRAG()
    g.settings.position= g.settings.position or {}
    g.settings.position.x = g.frame:GetX();
    g.settings.position.y = g.frame:GetY();
    ENEMYSTAT_SAVE_SETTINGS();
end
function ENEMYSTAT_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            if(g.settings.posotion~=nil)then
                frame:SetOffset(g.settings.position.x,g.settings.position.y)
            end
            
            frame:SetSkinName("test_weight_skin")
            frame:Resize(400,60)
            frame:EnableHittestFrame(1)
            frame:EnableMove(1)
            local txt=frame:CreateOrGetControl("richtext","status",0,0,400,60)
            txt:EnableHitTest(0)
   
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ENEMYSTAT_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local targetHandle= session.GetTargetHandle()

            local txt=frame:GetChild("status")
            local monactor = world.GetActor(targetHandle);
            if(targetHandle~=ni and monactor~=nil)then
               
                local targetInfo=info.GetTargetInfo( targetHandle )

                local montype = monactor:GetType()
                local monclass = GetClassByType("Monster", montype);
                local lv=monactor:GetLv()
                --atks
                local patkmax,patkmin, matkmax,matkmin
                patkmax=SCR_Get_MON_MAXPATK(monclass,lv)
                patkmin=SCR_Get_MON_MINPATK(monclass,lv)
                matkmax=SCR_Get_MON_MAXMATK(monclass,lv)
                matkmin=SCR_Get_MON_MINMATK(monclass,lv)
                pdef=SCR_Get_MON_DEF(monclass,lv)
                mdef=SCR_Get_MON_MDEF(monclass,lv)
               
                txt:SetText(
                    "{s16}{ol}\r\n"..
                    "Lv"..tostring(lv).." "..info.GetMonsterClassName(targetHandle).."\r\n"..
                    string.format("{#00FF77}{img test_sword_icon 16 16}%d-%d{/} {#FF44AA}{img test_sword_icon 16 16}%d-%d{/}\r\n",patkmin,patkmax,matkmin,matkmax)..
                    string.format("{#00FF77}{img test_shield_icon 16 16}%d{/} {#FF44AA}{img test_shield_icon 16 16}%d{/}\r\n",pdef,mdef)..
                    "")
                
            else

                txt:SetText("")
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
