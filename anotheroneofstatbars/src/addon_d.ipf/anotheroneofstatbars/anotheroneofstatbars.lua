--アドオン名（大文字）
local addonName = "ANOTHERONEOFSTATBARS"
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
g.settings = g.settings or {
    x = 300,
    y = 300,
    style = 0,
    maxlenhp = 400,
    maxlensp = 400,
    maxlenstamina = 400,
    maxlendur = 400,
    minlenhp = 100,
    minlensp = 100,
    minlenstamina = 100,
    minlendur = 100,
    maxhp = 100000,
    maxsp = 1000,
    maxstamina = 100000,
    maxdur = 4000
}
g.configurepattern = {
    
    }
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "anotheroneofstatbars"
g.debug = false
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.large = 0
g.endo = false
g.remhpw = 0
g.remspw = 0
g.curhpw = 0
g.remshpw = 0
g.curshpw = 0

g.curspw = 0
g.curstaw = 0
g.curdurw = 0
g.durmin = 0
g.durmax = 0
g.tick = 0
g.fixsp = nil
g.fixhp = nil
g.fanatic = nil

g.buffs = {}


--ライブラリ読み込み
CHAT_SYSTEM("[AOS]loaded")
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

local function DrawPolyLine(pic, poly, brush, color)
    local prev = nil
    for _, v in ipairs(poly) do
        if (prev) then
            pic:DrawBrush(prev[1], prev[2], v[1], v[2], brush, color)
        end
        prev = v
    end
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
function AOS_DEFAULT_DIAMOND()
    return {
            --shows buff duration(priority use)
            buffs = {
                --S100001 = {buff = "Velcoffer_Sumazinti", clsid = 100001, prefix = "Set_sumazinti", needs = 5},
                ["S4271"] = {
                    name = "Korup"
                },
                ["S4318"] = {
                    name = "Aqkrova"
                },
                ["S4348"] = {
                    name = "Liris"
                },
                ["S2156"] = {
                    name = "Mergaite"
                },
                ["S4287"] = {
                    name = "Goduma"
                },
                ["S4270"] = {
                    name = "Rykuma"
                },
                ["S4350"] = {
                    name = "Proverbs"
                },
                ["S4289"] = {
                    name = "Smugis"
                },
                ["S2154"] = {
                    name = "Tiksline"
                },
                ["S4288"] = {
                    name = "Gymas"
                },
                ["S2158"] = {
                    name = "Gyvenimas"
                },
                ["S2157"] = {
                    name = "Kraujas"
                },
                ["S4285"] = {
                    name = "Apsauga"
                },
                ["S4286"] = {
                    name = "Bendrinti"
                },
                ["S2153"] = {
                    name = "Sumazinti"
                },
                nouse = true,
            },
            --shows skill cooldown(resessive use)
            skills = {
                S100001 = {skill = "Velcoffer_Sumazinti", clsid = 100001, prefix = "Set_sumazinti", needs = 5},
                S100002 = {skill = "Velcoffer_Tiksline", clsid = 100002, prefix = "Set_tiksline", needs = 5},
                S100003 = {skill = "Velcoffer_Mergaite", clsid = 100003, prefix = "Set_mergaite", needs = 5},
                S100004 = {skill = "Velcoffer_Kraujas", clsid = 100004, prefix = "Set_kraujas", needs = 5},
                S100005 = {skill = "Velcoffer_Gyvenimas", clsid = 100005, prefix = "Set_gyvenimas", needs = 5},
                S100010 = {skill = "Savinose_Rykuma", clsid = 100010, prefix = "Set_rykuma", needs = 5},
                S100011 = {skill = "Savinose_Korup", clsid = 100011, prefix = "Set_korup", needs = 5},
                S100012 = {skill = "Savinose_Apsauga", clsid = 100012, prefix = "Set_apsauga", needs = 5},
                S100013 = {skill = "Savinose_Bendrinti", clsid = 100013, prefix = "Set_bendrinti", needs = 5},
                S100014 = {skill = "Varna_Goduma", clsid = 100014, prefix = "Set_goduma", needs = 5},
                S100015 = {skill = "Varna_Gymas", clsid = 100015, prefix = "Set_gymas", needs = 5},
                S100016 = {skill = "Varna_Smugis", clsid = 100016, prefix = "Set_smugis", needs = 5},
                S100017 = {skill = "Varna_Aqkrova", clsid = 100017, prefix = "Set_aqkrova", needs = 5},
                S100018 = {skill = "Varna_Atagal", clsid = 100018, prefix = "Set_atagal", needs = 5},
                S100019 = {skill = "Varna_Liris", clsid = 100019, prefix = "Set_liris", needs = 5},
                S100020 = {skill = "Varna_Proverbs", clsid = 100020, prefix = "Set_proverbs", needs = 5},
                nouse = false,
            },
    
    }
end
function AOS_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function AOS_DEFAULT_SETTINGS()
    g.settings = {
        x = 300,
        y = 300,
        style = 0,
        maxlenhp = 400,
        maxlensp = 400,
        maxlenstamina = 400,
        maxlendur = 400,
        minlenhp = 100,
        minlensp = 100,
        minlenstamina = 100,
        minlendur = 100,
        maxhp = 100000,
        maxsp = 10000,
        maxstamina = 100000,
        maxdur = 4000,
        lock = false,
        layerlevel=90,
        diamond = AOS_DEFAULT_DIAMOND()
    }
    ANOTHERONEOFSTATBARSCONFIG_GENERATEDEFAULT(g.settings)
end
function AOS_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        AOS_DEFAULT_SETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    AOS_UPGRADE_SETTINGS()
    AOS_SAVE_SETTINGS()

end


function AOS_UPGRADE_SETTINGS()
    local upgraded = false
    if (g.settings.diamond == nil) then
        g.settings.diamond = AOS_DEFAULT_DIAMOND()
        upgraded = true
    end
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=CHALLENGEMODESTUFF_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function ANOTHERONEOFSTATBARS_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            --addon:RegisterMsg('GAME_START_3SEC', 'CHALLENGEMODESTUFF_SHOW')
            --ccするたびに設定を読み込む
            addon:RegisterOpenOnlyMsg('STAT_UPDATE', 'AOS_HEADSUPDISPLAY_ON_MSG');
            addon:RegisterOpenOnlyMsg('TAKE_DAMAGE', 'AOS_HEADSUPDISPLAY_ON_MSG');
            addon:RegisterOpenOnlyMsg('TAKE_HEAL', 'AOS_HEADSUPDISPLAY_ON_MSG');
            addon:RegisterMsg('STAT_UPDATE', 'AOS_HEADSUPDISPLAY_ON_MSG');
            addon:RegisterMsg('GAME_START', 'AOS_HEADSUPDISPLAY_ON_MSG');
            addon:RegisterMsg('LEVEL_UPDATE', 'AOS_HEADSUPDISPLAY_ON_MSG');
            addon:RegisterMsg('FPS_UPDATE', 'AOS_ON_FPS_UPDATE');
            addon:RegisterMsg('BUFF_ADD', 'AOS_BUFF_UPDATE');
            addon:RegisterMsg('BUFF_REMOVE', 'AOS_BUFF_UPDATE');
            addon:RegisterMsg('BUFF_UPDATE', 'AOS_BUFF_UPDATE');
            addon:RegisterMsg("SHOW_SOUL_CRISTAL", "AOS_SHOW_SOUL_CRISTAL");
            addon:RegisterMsg("UPDATE_SOUL_CRISTAL", "AOS_UPDATE_SOUL_CRISTAL");
            
            if not g.loaded then
                
                g.loaded = true
            end
            
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            --CHALLENGEMODESTUFF_SHOW(g.frame)
            DBGOUT("INIT")
        --CHALLENGEMODESTUFF_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOS_ON_FPS_UPDATE()
    g.frame:ShowWindow(1)
end
function AOS_SHOW_SOUL_CRISTAL(frame, msg, argStr, argNum)
    local frame = ui.GetFrame(g.framename)
    local soulcrystal = frame:GetChild("soulcrystal")
    AUTO_CAST(soulcrystal)
    soulcrystal:ShowWindow(1)
    soulcrystal:SetText("{img icon_item_soulCrystal 20 20}{/}{@st42}{ol}{#FFFFFF}" .. tostring(argNum) .. "/" .. tostring(argNum))

end
function AOS_UPDATE_SOUL_CRISTAL(frame, msg, maxStr, curCount)
    local frame = ui.GetFrame(g.framename)
    local soulcrystal = frame:GetChild("soulcrystal")
    local maxCount = tonumber(maxStr)
    AUTO_CAST(soulcrystal)
    local count = frame:GetUserIValue('MAX_COUNT');
    if count == 0 and maxCount ~= 0 then
        frame:SetUserValue('SOULCRYSTAL_MAX_COUNT', maxCount);
    else
        maxCount = frame:GetUserIValue('SOULCRYSTAL_MAX_COUNT');
    end
    local curnum = maxCount - curCount
    soulcrystal:ShowWindow(1)
    soulcrystal:SetText("{img icon_item_soulCrystal 20 20}{/}{@st42}{ol}{#FFFFFF}" .. tostring(curnum) .. "/" .. tostring(maxCount))

end
function AOS_BUFF_UPDATE(frame, msg, argStr, argNum)
    
    
    local fhp = false
    local fsp = false
    --アーケインエナジーを探す
    local stat = info.GetStat(session.GetMyHandle());
    local clsid_arcane = 1018
    local clsid_healing = 2001
    local clsid_fanaticism = 2104
    local handle = session.GetMyHandle();
    local buffcount = info.GetBuffCount(handle);
    g.fanatic = nil
    for i = 0, buffcount - 1 do
        local buff = info.GetBuffIndexed(handle, i);
        local buffCls = GetClassByType("Buff", buff.buffID);
        
        if (buff.buffID == clsid_arcane) then
            if (g.fixsp == nil) then
                --SP固定
                g.fixsp = stat.SP
            end
            
            fsp = true
        end
        if (buff.buffID == clsid_healing) then
            if g.fixhp == nil then
                g.fixhp = stat.HP
            end
            fhp = true
        end
        if (buff.buffID == clsid_fanaticism) then
            g.fanatic = true
        end
        if (not g.settings.diamond.buffs.nouse and g.settings.diamond.buffs["S" .. tostring(buff.buffID)]) then
            if (msg == "BUFF_ADD") then
                
                if (argNum == buff.buffID and not g.buffs[buff.buffID]) then
                    g.buffs[buff.buffID] = {
                        maxtime = buff.time,
                    }
                    DBGOUT("BUFFADD" .. tostring(buff.buffID))
                end
            
            elseif (argNum == buff.buffID and msg == "BUFF_REMOVE") then
                if (g.buffs[buff.buffID]) then
                    g.buffs[buff.buffID] = nil
                    DBGOUT("BUFFREMOVE" .. tostring(buff.buffID))
                end
            end
        
        end
    end
    if (not fhp) then
        g.fixhp = nil
    end
    if (not fsp) then
        g.fixsp = nil
    end
    
    AOS_RENDER()
end
function AOS_INIT()
    
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:RemoveAllChild()
            frame:Resize(1920, 300)
            frame:SetLayerLevel(g.settings.layerlevel or 90)
            local pic = frame:CreateOrGetControl("picture", "pic", 0, 0, frame:GetWidth(), frame:GetHeight())
            local touch = frame:CreateOrGetControl("picture", "touchbar", 500 - 20, 22, 40, 40)
            local soulcrystal = frame:CreateOrGetControl("richtext", "soulcrystal", 500 - 30, 5, 40, 40)
            tolua.cast(pic, "ui::CPicture")
            tolua.cast(touch, "ui::CPicture")
            AUTO_CAST(soulcrystal)
            pic:EnableHitTest(0)
            pic:CreateInstTexture()
            pic:FillClonePicture("00000000")
            
            touch:EnableHitTest(1)
            touch:SetEnableStretch(1)
            touch:SetEventScript(ui.MOUSEWHEEL, "AOS_MOUSEWHEEL");
            touch:SetEventScript(ui.LBUTTONDOWN, "AOS_LBTNDOWN");
            touch:SetEventScript(ui.LBUTTONUP, "AOS_LBTNUP");
            touch:SetEventScript(ui.RBUTTONUP, "AOS_RBTNUP");
            soulcrystal:ShowWindow(0)
            soulcrystal:EnableHitTest(0)
            local etc = GetMyEtcObject()
            local jobClassID = TryGetProp(etc, 'RepresentationClassID', 'None')
            if jobClassID == 'None' or tonumber(jobClassID) == 0 then
                local MySession = session.GetMyHandle()
                jobClassID = info.GetJob(MySession);
            end
            local jobCls = GetClassByType('Job', jobClassID);
            local jobIcon = TryGetProp(jobCls, 'Icon');
            if jobIcon ~= nil then
                touch:SetImage(jobIcon)
                touch:SetTextTooltip("{ol}" .. jobCls.Name .. "{nl}To show camp menu,Press RBtn.{nl}To show AOS menu,Press LSHIFT + RBtn ");
            end
            
            g.remhpw = 0
            g.remspw = 0
            g.curhpw = 0
            g.curspw = 0
            g.curshpw = 0
            g.remshpw = 0
            g.curstaw = 0
            g.curdurw = 0
            g.durmin = 0
            g.durmax = 0
            g.tick = 0
            g.fanatic = nil
            g.bufflist = {}
            AOS_RENDER()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOS_HEADSUPDISPLAY_ON_MSG(frame, msg, argStr, argNum)
    local stat = info.GetStat(session.GetMyHandle());
    if (msg == "GAME_START") then
        g.frame:ShowWindow(1)
        AOS_LOAD_SETTINGS()
        AOS_INIT()
        g.frame:SetOffset(g.settings.x, g.settings.y)
       
        AOS_TIMER_BEGIN()
    end
    if (msg == "STAT_UPDATE") then
        AOS_RENDER()
    end
end
function AOS_TIMER_BEGIN()
    local frame = ui.GetFrame(g.framename)
    frame:CreateOrGetControl("timer", "addontimer", 0, 0, 10, 10)
    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
    timer:SetUpdateScript("AOS_ON_TIMER");
    timer:Start(0.01);

end
function AOS_CALC_CURDUR()
    local equips = session.GetEquipItemList();
    local maxdur = 10
    local mindur = 0
    local itemr = nil
    
    for i = 0, equips:Count() - 1 do
        local equipItem = equips:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        if equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) then
            local obj = GetIES(equipItem:GetObject());
            local dur = obj.Dur;
            local max = obj.MaxDur;
            if ((itemr == nil or mindur / maxdur > dur / max) and max > 0) then
                mindur = dur
                maxdur = max
                
                itemr = equipItem
            end
        end
    end
    if (itemr == nil) then
        return 0, 2000
    else
        if (maxdur < mindur) then
            return mindur * 2000 / maxdur, mindur * 2000 / maxdur
        else
            return mindur * 2000 / maxdur, 2000
        end
    end
end
function AOS_CALC_POINT(actualval, minw, maxw, maxav)
    local valw = math.max(minw, math.min(maxw, actualval * maxw / maxav))
    return valw
end
function AOS_CALC_POINT_ANIMATED(widthval, remwidthval, actualval, actualmax, minw, maxw, maxav, speed)
    
    local amax = math.min(maxw, actualmax * maxw / maxav)
    local valw
    if (amax < minw) then
        valw = math.min(maxw, actualval * minw / amax)
    elseif (actualmax > maxav) then
        valw = math.min(maxw, actualval * maxw / actualmax)
    
    else
        valw = math.min(maxw, actualval * maxw / maxav)
    
    end
    
    if (widthval > valw) then
        --減少
        if (remwidthval < valw) then
            --remを増やす
            remwidthval = valw
        
        end
        --curhpを近づける
        widthval = math.max(valw, widthval - math.max((widthval - valw) * speed, 1))
    
    elseif (widthval < valw) then
        if (remwidthval < valw) then
            --remを近づける
            remwidthval = remwidthval + math.max((valw - remwidthval) * speed, 1)
        
        elseif (remwidthval > valw) then
            --remを減らす
            remwidthval = valw
        
        
        else
            --curhpを近づける
            widthval = math.min(valw, widthval + math.max((valw - widthval) * speed, 1))
        
        end
    else
        if (remwidthval > valw) then
            --remを近づける
            remwidthval = math.max(valw, remwidthval - math.max((remwidthval - valw) * speed, 1))
        
        
        end
    end
    return widthval, remwidthval
end
function AOS_CALC_POINT_SIMPLE_ANIMATED(widthval, actualval, actualmax, minw, maxw, maxav, speed)
    
    local amax = math.min(maxw, actualmax * maxw / maxav)
    local valw
    if (amax < minw) then
        valw = math.min(maxw, actualval * minw / actualmax)
    elseif (actualmax > maxav) then
        valw = math.min(maxw, actualval * maxw / actualmax)
    
    else
        valw = math.min(maxw, actualval * maxw / maxav)
    
    end
    
    if (widthval > valw) then
        --減少
        --curspを近づける
        widthval = math.max(valw, widthval - math.max((widthval - valw) * speed, 0.10))
    
    elseif (widthval < valw) then
        
        --curspを近づける
        widthval = math.min(valw, widthval + math.max((valw - widthval) * speed, 0.10))
    
    end
    
    return widthval
end
function AOS_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            if (g.tick > 0) then
                g.tick = g.tick - 1
            else
                local durmin, durmax = AOS_CALC_CURDUR()
                g.durmin = durmin
                g.durmax = durmax
                
                
                g.tick = 100
            end
            local render = false
            
            
            
            local stat = info.GetStat(session.GetMyHandle());
            local minwidth = 0
            
            local maxmaxhp = g.settings.maxhp
            local maxmaxsp = g.settings.maxsp
            local maxmaxsta = g.settings.maxstamina
            local maxmaxdur = g.settings.maxdur
            
            
            -- local maxhpw = AOS_CALC_POINT(stat.maxHP,minwidth,maxwidth,maxmaxhp)
            -- local maxshpw = AOS_CALC_POINT(stat.maxHP,minwidth,maxwidth,maxmaxhp)
            -- local maxspw =AOS_CALC_POINT(stat.maxSP,minwidth,maxwidth,maxmaxsp)
            -- local maxstaw = AOS_CALC_POINT(stat.MaxStamina,minwidth,maxwidth,maxmaxsta)
            -- local maxdurw = AOS_CALC_POINT( g.durmax,minwidth,maxwidth,maxmaxdur)
            -- local curhpw = stat.HP * maxhpw / stat.maxHP
            -- local curshpw = math.min(g.settings.maxlen, stat.shield * maxshpw / stat.maxHP)
            -- local curspw = stat.SP * maxspw / stat.maxSP
            -- local curstaw = stat.Stamina * maxstaw / stat.MaxStamina
            -- local curdurw = g.durmin * maxdurw / g.durmax
            local speed = 0.3
            local speedslow = 0.05
            --HP
            g.curhpw, g.remhpw = AOS_CALC_POINT_ANIMATED(g.curhpw, g.remhpw, stat.HP, stat.maxHP, minwidth, g.settings.maxlenhp, maxmaxhp, speed)
            g.curshpw, g.remshpw = AOS_CALC_POINT_ANIMATED(g.curshpw, g.remshpw, stat.shield, stat.maxHP, minwidth, g.settings.maxlenhp, maxmaxhp, speed)
            g.curspw, g.remspw = AOS_CALC_POINT_ANIMATED(g.curspw, g.remspw, stat.SP, stat.maxSP, minwidth, g.settings.maxlensp, maxmaxsp, speed)
            g.curstaw = AOS_CALC_POINT_SIMPLE_ANIMATED(g.curstaw, stat.Stamina, stat.MaxStamina, minwidth, g.settings.maxlenstamina, maxmaxsta, speedslow)
            g.curdurw = AOS_CALC_POINT_SIMPLE_ANIMATED(g.curdurw, g.durmin, g.durmax, minwidth, g.settings.maxlendur, maxmaxdur, speedslow)
            
            -- if (g.curhpw > curhpw) then
            --     --減少
            --     if (g.remhpw < curhpw) then
            --         --remを増やす
            --         g.remhpw = curhpw
            --         render = true
            --     end
            --     --curhpを近づける
            --     g.curhpw = math.max(curhpw, g.curhpw - math.max((g.curhpw - curhpw) * speed, 1))
            --     render = true
            -- elseif (g.curhpw < curhpw) then
            --     if (g.remhpw < curhpw) then
            --         --remを近づける
            --         g.remhpw = g.remhpw + math.max((curhpw - g.remhpw) * speed, 1)
            --         render = true
            --     elseif (g.remhpw > curhpw) then
            --         --remを減らす
            --         g.remhpw = curhpw
            --         render = true
            --     else
            --         --curhpを近づける
            --         g.curhpw = math.min(curhpw, g.curhpw + math.max((curhpw - g.curhpw) * speed, 1))
            --         render = true
            --     end
            -- else
            --     if (g.remhpw > curhpw) then
            --         --remを近づける
            --         g.remhpw = math.max(curhpw, g.remhpw - math.max((g.remhpw - curhpw) * speed, 1))
            --         render = true
            --     end
            -- end
            -- --シールド
            -- if (g.curshpw > curshpw) then
            --     --減少
            --     if (g.remshpw < curshpw) then
            --         --remを増やす
            --         g.remshpw = curshpw
            --         render = true
            --     end
            --     --curshpを近づける
            --     g.curshpw = math.max(curshpw, g.curshpw - math.max((g.curshpw - curshpw) * speed, 1))
            --     render = true
            -- elseif (g.curshpw < curshpw) then
            --     if (g.remshpw < curshpw) then
            --         --remを近づける
            --         g.remshpw = g.remshpw + math.max((curshpw - g.remshpw) * speed, 1)
            --         render = true
            --     elseif (g.remshpw > curshpw) then
            --         --remを減らす
            --         g.remshpw = curshpw
            --         render = true
            --     else
            --         --curshpを近づける
            --         g.curshpw = math.min(curshpw, g.curshpw + math.max((curshpw - g.curshpw) * speed, 1))
            --         render = true
            --     end
            -- else
            --     if (g.remshpw > curshpw) then
            --         --remを近づける
            --         g.remshpw = math.max(curshpw, g.remshpw - math.max((g.remshpw - curshpw) * speed, 1))
            --         render = true
            --     end
            -- end
            -- --SP
            -- if (g.curspw > curspw) then
            --     --減少
            --     if (g.remspw < curspw) then
            --         --remを増やす
            --         g.remspw = curspw
            --         render = true
            --     end
            --     --curspを近づける
            --     g.curspw = math.max(curspw, g.curspw - math.max((g.curspw - curspw) * speed, 1))
            --     render = true
            -- elseif (g.curspw < curspw) then
            --     if (g.remspw < curspw) then
            --         --remを近づける
            --         g.remspw = g.remspw + math.max((curspw - g.remspw) * speed, 1)
            --         render = true
            --     elseif (g.remspw > curspw) then
            --         --remを減らす
            --         g.remspw = curspw
            --         render = true
            --     else
            --         --curspを近づける
            --         g.curspw = math.min(curspw, g.curspw + math.max((curspw - g.curspw) * speed, 1))
            --         render = true
            --     end
            -- else
            --     if (g.remspw > curspw) then
            --         --remを近づける
            --         g.remspw = math.max(curspw, g.remspw - math.max((g.remspw - curspw) * speed, 1))
            --         render = true
            --     end
            -- end
            -- if (g.curstaw > curstaw) then
            --     --減少
            --     --curspを近づける
            --     g.curstaw =  math.max(curstaw,g.curstaw - math.max((g.curstaw - curstaw) * speedslow, 0.10))
            --     render = true
            -- elseif (g.curstaw < curstaw) then
            --     --curspを近づける
            --     g.curstaw =  math.min(curstaw,g.curstaw + math.max((curstaw - g.curstaw) * speedslow, 0.10))
            --     render = true
            -- end
            -- if (g.curdurw > curdurw) then
            --     --減少
            --     --curspを近づける
            --     g.curdurw = math.max(curdurw,g.curdurw - math.max((g.curdurw - curdurw) * speedslow, 0.10))
            --     render = true
            -- elseif (g.curdurw < curdurw) then
            --     --curspを近づける
            --     g.curdurw = math.min(curdurw,g.curdurw + math.max((curdurw - g.curdurw) * speedslow, 0.10))
            --     render = true
            -- end
            if (g.spskill ~= nil) then
                local skl = session.GetSkill(g.spskill);
                if (skl == nil) then
                    g.spskill = nil
                else
                    if (skl:GetCurrentCoolDownTime() > 0) then
                        render = true
                    end
                end
            end
            
            AOS_RENDER()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOS_RENDER()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local pic = frame:GetChild("pic")
            if (pic) then
                if (g.settings.style == nil or g.settings.style == 0) then
                    AOS_RENDER_STYLEA()
                elseif (g.settings.style == 1) then
                    AOS_RENDER_STYLEB()
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOS_RENDER_STYLEA()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local pic = frame:GetChild("pic")
            tolua.cast(pic, "ui::CPicture")
            local touch = frame:CreateOrGetControl("picture", "touchbar", 500 - 20, 22, 40, 40)
            local soulcrystal = frame:CreateOrGetControl("richtext", "soulcrystal", 500 - 30, 5, 40, 40)
            pic:FillClonePicture("00000000")
            pic:DrawBrush(500, 41 - 5, 500, 41 + 5, "spray_dia", "AA000000")
            pic:DrawBrush(500 - 5, 41, 500 + 5, 41, "spray_dia", "AA000000")
            AOS_DRAW_HPBAR(frame, pic)
            AOS_DRAW_SPBAR(frame, pic)
            AOS_DRAW_STAMINABAR(frame, pic)
            AOS_DRAW_DURBAR(frame, pic)
            AOS_DRAW_SPECIALSKILLBAR(frame, pic)
            pic:Invalidate()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOS_DRAW_HPBAR(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local maxw = math.max(100, math.min(g.settings.maxlenhp, stat.maxHP * g.settings.maxlenhp / g.settings.maxhp))
    local colw = stat.HP * maxw / stat.maxHP
    local colsw = math.min(g.settings.maxlenhp, stat.shield * g.settings.maxlenhp / g.settings.maxhp)
    
    local curw = g.curhpw
    local fixhpw = curw
    local ox = 500 + 20 - 2
    local oy = 30 - 2
    if (g.fixhp) then
        fixhpw = math.max(0, math.min(g.settings.maxlenhp, g.fixhp * g.settings.maxlenhp / g.settings.maxhp))
    end
    if (stat.HP <= stat.maxHP * 0.3) then
        local lowstr = string.format("AA%02X4444", 0x44 + math.floor(0xBB * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw, oy + 5, "spray_large_bs", lowstr)
    else
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw, oy + 5, "spray_large_bs", "AA444444")
    end
    if (g.remhpw ~= g.curhpw) then
        if (colw > g.curhpw) then
            pic:DrawBrush(ox + 5, oy + 5, ox + 5 + g.remhpw, oy + 5, "spray_large_bs", "FF22FFFF")
        else
            pic:DrawBrush(ox + 5, oy + 5, ox + 5 + g.remhpw, oy + 5, "spray_large_bs", "FFFF0000")
        end
    end
    if g.fanatic then
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + curw, oy + 5, "spray_large_bs", "FFFFBB77")
        pic:DrawBrush(ox + 7, oy + 7, ox + 7 + fixhpw, oy + 7, "spray_small_bs", "FFDDAA44")
    else
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + curw, oy + 5, "spray_large_bs", "FF22FF77")
        pic:DrawBrush(ox + 7, oy + 7, ox + 7 + fixhpw, oy + 7, "spray_small_bs", "FF11CC55")
    end
    if (g.remshpw > 0) then
        if (g.remshpw ~= g.curshpw) then
            if (colsw > g.curshpw) then
                pic:DrawBrush(ox + 5, oy + 5, ox + 5 + g.remshpw, oy + 5, "spray_large_bs", "FFFFFFFF")
            else
                pic:DrawBrush(ox + 5, oy + 5, ox + 5 + g.remshpw, oy + 5, "spray_large_bs", "FF6666FF")
            end
        end
    end
    if (g.curshpw > 0) then
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + g.curshpw, oy + 5, "spray_large_bs", "FFFFFFFF")
        pic:DrawBrush(ox + 7, oy + 7, ox + 7 + g.curshpw, oy + 7, "spray_small_bs", "FFCCCCCC")
    end
    DrawPolyLine(pic, {
        {ox, oy},
        {ox + 10, oy + 10},
        {ox + maxw + 10, oy + 10},
    }, "spray_1", "FF000000")
    
    local txt = frame:CreateOrGetControl("richtext", "hpnum", ox + 20, oy - 10, 50, 16)
    txt:EnableHitTest(0)
    txt:SetText("{@st43}{s16}{ol}{#FFFFFF}" .. string.format("%6d", stat.HP))
end
function AOS_DRAW_SPBAR(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local maxw = math.max(100, math.min(g.settings.maxlensp, stat.maxSP * g.settings.maxlensp / g.settings.maxsp))
    local curw = g.curspw
    
    local colw = stat.SP * maxw / stat.maxSP
    local fixspw = curw
    local ox = 500 - 20 + 2
    local oy = 30 - 2
    if (g.fixsp) then
        fixspw = math.max(0, math.min(g.settings.maxlensp, g.fixsp * g.settings.maxlensp / g.settings.maxsp))
    end
    if (stat.SP <= stat.maxSP * 0.3) then
        local lowstr = string.format("AA4444%02X", 0x44 + math.floor(0xBB * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 - maxw, oy + 5, "spray_large_s", lowstr)
    
    else
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 - maxw, oy + 5, "spray_large_s", "AA444444")
    end
    if (g.remspw ~= g.curspw) then
        if (colw > g.curspw) then
            pic:DrawBrush(ox - 5, oy + 5, ox - 5 - g.remspw, oy + 5, "spray_large_s", "FF22FF77")
        
        else
            pic:DrawBrush(ox - 5, oy + 5, ox - 5 - g.remspw, oy + 5, "spray_large_s", "FFFF0000")
        end
    end
    pic:DrawBrush(ox - 5, oy + 5, ox - 5 - curw, oy + 5, "spray_large_s", "FF44CCFF")
    pic:DrawBrush(ox - 7, oy + 7, ox - 7 - fixspw, oy + 7, "spray_small_s", "FF33AACC")
    DrawPolyLine(pic, {
        {ox, oy},
        {ox - 10, oy + 10},
        {ox - maxw - 10, oy + 10},
    }, "spray_1", "FF000000")
    
    local txt = frame:CreateOrGetControl("richtext", "spnum", ox - 20 - 50, oy - 10, 50, 16)
    txt:EnableHitTest(0)
    txt:SetText("{@st43}{s16}{ol}{#FFFFFF}" .. string.format("%6d", stat.SP))

end
function AOS_DRAW_DURBAR(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local durmin, durmax
    durmin = g.durmin
    durmax = g.durmax
    local maxw = math.max(100, math.min(g.settings.maxlendur, durmax * g.settings.maxlendur / g.settings.maxdur))
    local curw = g.curdurw
    local ox = 500 - 20 + 2
    local oy = 40 + 4
    if (durmin <= durmax * 0.3 and durmin > 0) then
        --if(durmin <= durmax*0.3)then
        local lowstr = string.format("AA%02X44%02X", 0x44 + math.floor(0x99 * math.abs(g.tick % 50 - 25) / 25), 0x44 + math.floor(0x99 * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 - maxw, oy + 5, "spray_large_bs", lowstr)
    else
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 - maxw, oy + 5, "spray_large_bs", "AA444444")
    end
    
    pic:DrawBrush(ox - 5, oy + 5, ox - 5 - curw, oy + 5, "spray_large_bs", "FFFF88FF")
    pic:DrawBrush(ox - 5 + 2, oy + 7, ox - 5 + 2 - curw + 1 - 1, oy + 7, "spray_small_bs", "FFCC55CC")
    DrawPolyLine(pic, {
        {ox - 10, oy},
        {ox + 0, oy + 10},
        {ox - maxw + 0, oy + 0 + 10},
    }, "spray_1", "FF000000")


end
function AOS_DRAW_STAMINABAR(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local maxw = math.max(100, math.min(g.settings.maxlenstamina, stat.MaxStamina * g.settings.maxlenstamina / g.settings.maxstamina))
    local curw = g.curstaw
    
    local ox = 500 + 20 - 2
    local oy = 40 + 4
    pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw + 1, oy + 5, "spray_large_s", "AA444444")
    if (stat.Stamina <= stat.MaxStamina * 0.3) then
        local lowstr = string.format("AA%02X%02X44", 0x44 + math.floor(0x99 * math.abs(g.tick % 50 - 25) / 25), 0x44 + math.floor(0x44 * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw + 1, oy + 5, "spray_large_s", lowstr)
    else
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw + 1, oy + 5, "spray_large_s", "AA444444")
    end
    
    pic:DrawBrush(ox + 5, oy + 5, ox + 5 + curw + 1, oy + 5, "spray_large_s", "FFFFFF00")
    pic:DrawBrush(ox + 5 - 2 - 1, oy + 7, ox + 5 - 2 + curw + 1 - 1, oy + 7, "spray_small_s", "FFCCCC00")
    DrawPolyLine(pic, {
        {ox + 10 - 2, oy},
        {ox - 10 + 10 - 2, oy + 10},
        {ox + maxw - 10 + 10, oy + 10},
    }, "spray_1", "FF000000")

end
function AOS_DRAW_SPECIALSKILLBAR(frame, pic)
    local curtime, maxtime = AOS_GET_DIAMOND_VALUE()
    
    local ox = 500
    local oy = 41
    local off = 25
    local color = "FF00FFFFFF"
    local spray = "spray_2"
    if (g.settings.diamond.shownumber) then
        local gbox = frame:CreateOrGetControl("groupbox", "gboxsklnumber", ox - off, oy - off, off * 2, off * 2)
        AUTO_CAST(gbox)
        gbox:EnableHitTest(0)
        local txt = gbox:CreateOrGetControl("richtext", "txtsklnumber", 0, 0, 0, 0)
        AUTO_CAST(txt)
        txt:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
        local touch = frame:GetChild("touchbar")
        if (curtime == nil) then
            touch:SetColorTone("FFFFFFFF")
            txt:SetText("")
        else
            touch:SetColorTone("44FFFFFF")
            txt:SetText("{@st43}{ol}{b}{s24}{#FFFFFF}" .. AOS_TO_TIME_STRING(curtime))
        end
        txt:EnableHitTest(0)
    end
    if (curtime == nil) then
        return
    end
    local skillpercent = curtime * 100 / maxtime
    if (skillpercent >= 75) then
        local r = (skillpercent - 75) / 25.0
        DrawPolyLine(pic, {
            {ox, oy - off},
            {ox - off, oy},
            {ox, oy + off},
            {ox + off, oy},
            {ox + off - off * r, oy - off * r}},
        spray,
        color
    )
    elseif (skillpercent >= 50) then
        local r = (skillpercent - 50) / 25.0
        DrawPolyLine(pic, {
            {ox, oy - off},
            {ox - off, oy},
            {ox, oy + off},
            {ox + off * r, oy + off - off * r}},
        spray,
        color
    )
    elseif (skillpercent >= 25) then
        local r = (skillpercent - 25) / 25.0
        DrawPolyLine(pic, {
            {ox, oy - off},
            {ox - off, oy},
            {ox - off + off * r, oy + off * r}},
        spray,
        color
    )
    elseif (skillpercent > 0) then
        local r = (skillpercent - 0) / 25.0
        DrawPolyLine(pic, {
            {ox, oy - off},
            {ox - off * r, oy - off + off * r}},
        spray,
        color
    )
    end
end
function AOS_GET_DIAMOND_VALUE()
    --find buff
    if (not g.settings.diamond.buffs.nouse) then
        local handle = session.GetMyHandle();
        local buffcount = info.GetBuffCount(handle);
        
        for i = 0, buffcount - 1 do
            local buff = info.GetBuffIndexed(handle, i);
            local recbuf = g.buffs[buff.buffID]
            if (recbuf) then
                --バフ時間を返す
                return buff.time, recbuf.maxtime
            end
        end
    end
    if (not g.settings.diamond.skills.nouse) then
        --find skill
        for k, v in pairs(g.settings.diamond.skills) do
            
            if (k ~= "nouse" and v) then
                local skillInfo = session.GetSkill(tonumber(k:sub(2)));
                if (skillInfo) then
                    if (skillInfo:GetCurrentCoolDownTime() > 0) then
                        return skillInfo:GetCurrentCoolDownTime(), skillInfo:GetTotalCoolDownTime()
                    end
                end
            end
        
        
        end
    end
    return nil, nil
end

function AOS_RENDER_STYLEB()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local pic = frame:GetChild("pic")
            tolua.cast(pic, "ui::CPicture")
            pic:FillClonePicture("00000000")
            pic:DrawBrush(40, 20 + 20, 0, 20 + 20, "spray_triangle", "AA000000")
            pic:DrawBrush(0, 20 + 20, 0, 20 + 20 + 20, "spray_triangle", "AA000000")
            --pic:DrawBrush(50+20, 20+20, 50+20, 20+20, "spray_triangle", "AA000000")
            local touch = frame:GetChild("touchbar")
            local soulcrystal = frame:GetChild("soulcrystal")
            touch:SetOffset(0, 20)
            soulcrystal:SetOffset(0, 0)
            AOS_DRAW_HPBAR_B(frame, pic)
            AOS_DRAW_SPBAR_B(frame, pic)
            AOS_DRAW_STAMINABAR_B(frame, pic)
            AOS_DRAW_DURBAR_B(frame, pic)
            
            pic:Invalidate()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOS_DRAW_HPBAR_B(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local maxw = math.max(100, math.min(g.settings.maxlenhp, stat.maxHP * g.settings.maxlenhp / g.settings.maxhp))
    local colw = stat.HP * maxw / stat.maxHP
    local colsw = math.min(g.settings.maxlenhp, stat.shield * g.settings.maxlenhp / g.settings.maxhp)
    
    local curw = g.curhpw
    local fixhpw = curw
    local ox = 40 + 20 - 5 + 5 + 1
    local oy = 50 - 20 - 5 - 5
    if (g.fixhp) then
        fixhpw = math.max(0, math.min(g.settings.maxlenhp, g.fixhp * g.settings.maxlenhp / g.settings.maxhp))
    end
    if (stat.HP <= stat.maxHP * 0.3) then
        local lowstr = string.format("AA%02X4444", 0x44 + math.floor(0xBB * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + maxw, oy + 5, "spray_large_s", lowstr)
    else
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + maxw, oy + 5, "spray_large_s", "AA444444")
    end
    if (g.remhpw ~= g.curhpw) then
        if (colw > g.curhpw) then
            pic:DrawBrush(ox - 5, oy + 5, ox - 5 + g.remhpw, oy + 5, "spray_large_s", "FF22FFFF")
        else
            pic:DrawBrush(ox - 5, oy + 5, ox - 5 + g.remhpw, oy + 5, "spray_large_s", "FFFF0000")
        end
    end
    if g.fanatic then
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + curw, oy + 5, "spray_large_s", "FFFFBB77")
        pic:DrawBrush(ox - 5 - 2, oy + 5 + 2, ox - 5 - 2 + fixhpw, oy + 5 + 2, "spray_small_s", "FFDDAA44")
    else
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + curw, oy + 5, "spray_large_s", "FF22FF77")
        pic:DrawBrush(ox - 5 - 2, oy + 5 + 2, ox - 5 - 2 + fixhpw, oy + 5 + 2, "spray_small_s", "FF11CC55")
    end
    if (g.remshpw > 0) then
        if (g.remshpw ~= g.curshpw) then
            if (colsw > g.curshpw) then
                pic:DrawBrush(ox - 5, oy + 5, ox + 5 + g.remshpw, oy + 5, "spray_large_s", "FFFFFFFF")
            else
                pic:DrawBrush(ox - 5, oy + 5, ox + 5 + g.remshpw, oy + 5, "spray_large_s", "FF6666FF")
            end
        end
    end
    if (g.curshpw > 0) then
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + g.curshpw, oy + 5, "spray_large_s", "FFFFFFFF")
        pic:DrawBrush(ox - 5 - 2, oy + 5 + 2, ox - 5 - 2 + g.curshpw, oy + 5 + 2, "spray_small_s", "FFCCCCCC")
    end
    DrawPolyLine(pic, {
        {ox - 1, oy},
        {ox - 10 - 1, oy + 10},
        {ox + maxw - 10, oy + 10},
    }, "spray_1", "FF000000")
    
    local txt = frame:CreateOrGetControl("richtext", "hpnum", ox + 20, oy - 10, 50, 16)
    txt:EnableHitTest(0)
    txt:SetText("{@st43}{s16}{ol}{#FFFFFF}" .. string.format("%6d", stat.HP))
end
function AOS_DRAW_SPBAR_B(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local maxw = math.max(100, math.min(g.settings.maxlensp, stat.maxSP * g.settings.maxlensp / g.settings.maxsp))
    local curw = g.curspw
    
    local colw = stat.SP * maxw / stat.maxSP
    local fixspw = curw
    local ox = 40 + 20 - 5 + 5 - 15 + 1
    local oy = 50 - 20 - 5 - 5 + 15
    if (g.fixsp) then
        fixspw = math.max(0, math.min(g.settings.maxlensp, g.fixsp * g.settings.maxlensp / g.settings.maxsp))
    end
    if (stat.SP <= stat.maxSP * 0.3) then
        local lowstr = string.format("AA4444%02X", 0x44 + math.floor(0xBB * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + maxw, oy + 5, "spray_large_s", lowstr)
    
    else
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + maxw, oy + 5, "spray_large_s", "AA444444")
    end
    if (g.remspw ~= g.curspw) then
        if (colw > g.curspw) then
            pic:DrawBrush(ox - 5, oy + 5, ox - 5 + g.remspw, oy + 5, "spray_large_s", "FF22FF77")
        
        else
            pic:DrawBrush(ox - 5, oy + 5, ox - 5 + g.remspw, oy + 5, "spray_large_s", "FFFF0000")
        end
    end
    pic:DrawBrush(ox - 5, oy + 5, ox - 5 + curw, oy + 5, "spray_large_s", "FF44CCFF")
    pic:DrawBrush(ox - 7, oy + 7, ox - 7 + fixspw, oy + 7, "spray_small_s", "FF33AACC")
    DrawPolyLine(pic, {
        {ox - 1, oy},
        {ox - 10 - 1, oy + 10},
        {ox + maxw - 10, oy + 10},
    }, "spray_1", "FF000000")
    
    local txt = frame:CreateOrGetControl("richtext", "spnum", ox + 20, oy - 10, 50, 16)
    txt:EnableHitTest(0)
    txt:SetText("{@st43}{s16}{ol}{#FFFFFF}" .. string.format("%6d", stat.SP))

end
function AOS_DRAW_DURBAR_B(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local durmin, durmax
    durmin = g.durmin
    durmax = g.durmax
    local maxw = math.max(100, math.min(g.settings.maxlendur, durmax * g.settings.maxlendur / g.settings.maxdur))
    local curw = g.curdurw
    local ox = 40 + 20 - 5 + 5 - 15 + 1 - 15
    local oy = 50 - 20 - 5 - 5 + 15 + 15
    if (durmin <= durmax * 0.3 and durmin > 0) then
        --if(durmin <= durmax*0.3)then
        local lowstr = string.format("AA%02X44%02X", 0x44 + math.floor(0x99 * math.abs(g.tick % 50 - 25) / 25), 0x44 + math.floor(0x99 * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + maxw, oy + 5, "spray_large_s", lowstr)
    else
        pic:DrawBrush(ox - 5, oy + 5, ox - 5 + maxw, oy + 5, "spray_large_s", "AA444444")
    end
    
    pic:DrawBrush(ox - 5, oy + 5, ox - 5 + curw, oy + 5, "spray_large_s", "FFFF88FF")
    pic:DrawBrush(ox - 5 - 2, oy + 7, ox - 5 - 2 + curw + 1 - 1, oy + 7, "spray_small_s", "FFCC55CC")
    DrawPolyLine(pic, {
        {ox - 1, oy},
        {ox - 10 - 1, oy + 10},
        {ox + maxw - 10, oy + 10},
    }, "spray_1", "FF000000")


end
function AOS_DRAW_STAMINABAR_B(frame, pic)
    local stat = info.GetStat(session.GetMyHandle());
    local maxw = math.max(100, math.min(g.settings.maxlenstamina, stat.MaxStamina * g.settings.maxlenstamina / g.settings.maxstamina))
    local curw = g.curstaw
    
    local ox = 40 + 15 + 5 - 15 + 1 - 15 - 15 - 10
    local oy = 50 - 20 - 5 - 5 + 15 + 15 + 15
    pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw + 1, oy + 5, "spray_large_s", "AA444444")
    if (stat.Stamina <= stat.MaxStamina * 0.3) then
        local lowstr = string.format("AA%02X%02X44", 0x44 + math.floor(0x99 * math.abs(g.tick % 50 - 25) / 25), 0x44 + math.floor(0x44 * math.abs(g.tick % 50 - 25) / 25))
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw + 1, oy + 5, "spray_large_s", lowstr)
    else
        pic:DrawBrush(ox + 5, oy + 5, ox + 5 + maxw + 1, oy + 5, "spray_large_s", "AA444444")
    end
    
    pic:DrawBrush(ox + 5, oy + 5, ox + 5 + curw + 1, oy + 5, "spray_large_s", "FFFFFF00")
    pic:DrawBrush(ox + 5 - 2 - 1, oy + 7, ox + 5 - 2 + curw + 1 - 1, oy + 7, "spray_small_s", "FFCCCC00")
    DrawPolyLine(pic, {
        {ox + 10 - 2, oy},
        {ox - 10 + 10 - 2, oy + 10},
        {ox + maxw - 10 + 10, oy + 10},
    }, "spray_1", "FF000000")

end

function AOS_TO_TIME_STRING(millisec)
    local sec = (millisec / 1000)
    if (sec <= 60) then
        return tostring(math.ceil(sec))
    end
    if (sec <= 60 * 60) then
        return tostring(math.ceil(sec / 60)) .. "m"
    end
    if (sec <= 60 * 60 * 24) then
        return tostring(math.ceil(sec / (60 * 60))) .. "h"
    end
    return tostring(math.ceil(sec / (60 * 60 * 24))) .. "d"
end
function AOS_LBTNDOWN(parent, ctrl)
    if (not g.settings.lock) then
        local frame = parent:GetTopParentFrame();
        
        local x, y = GET_MOUSE_POS();
        
        g.x = x -- 드래그할 때, 클릭한 좌표를 기억한다.
        g.y = y
        
        ui.EnableToolTip(0);
        ctrl:RunUpdateScript("AOS_PROCESS_MOUSE");
    end
end

function AOS_LBTNUP(parent, ctrl)
    -- 워프 위치에서 마우스를 떼지 않았다면 클릭한 좌표를 리셋한다.
    g.x = nil
    g.y = nil
    AOS_SAVE_SETTINGS()
end
function AOS_RBTNUP(parent, ctrl)
    if (keyboard.IsKeyPressed("LSHIFT") == 1) then
        local context = ui.CreateContextMenu("AOS", "", 0, 0, 170, 100);
        ui.AddContextMenuItem(context, "STYLE_A", "AOS_STYLE(0)");
        ui.AddContextMenuItem(context, "STYLE_B", "AOS_STYLE(1)");
        ui.AddContextMenuItem(context, "LOCK/UNLOCK Position", "AOS_LOCKUNLOCK(1)");
        ui.AddContextMenuItem(context, "Configuration", "ui.GetFrame('anotheroneofstatbarsconfig'):ShowWindow(1)");
        ui.OpenContextMenu(context);
    else
        HEDADSUPDISPLAY_CAMP_BTN_CLICK()
    end


end
function AOS_LOCKUNLOCK()
    g.settings.lock = not g.settings.lock
end
function AOS_STYLE(style)
    g.frame:SetOffset(40, 40)
    g.settings.style = style
    g.settings.lock = false
    AOS_SAVE_SETTINGS()
end
function AOS_PROCESS_MOUSE(ctrl)
    return EBI_try_catch{
        try = function()
            local frame = ctrl:GetTopParentFrame();
            if mouse.IsLBtnPressed() == 0 then
                
                ui.EnableToolTip(1);
                AOS_SAVE_SETTINGS()
                return 0;
            end
            local mx, my = GET_MOUSE_POS();
            local x = g.x;
            local y = g.y;
            local dx = mx - x;
            local dy = my - y;
            dx = dx;
            dy = dy;
            
            local cx = frame:GetX();
            local cy = frame:GetY();
            local curWidth = option.GetClientWidth();
            local curHeight = option.GetClientHeight();
            if (curWidth >= 3000) then
                cx = cx + dx / 2;
                cy = cy + dy / 2;
            else
                cx = cx + dx;
                cy = cy + dy;
            end
            g.x = mx
            g.y = my
            
            
            cx = math.max(-frame:GetWidth() / 2, math.min(cx, curWidth - 30))
            cy = math.max(-frame:GetHeight() / 2, math.min(cy, curHeight - 30))
            g.settings.x = cx;
            g.settings.y = cy;
            AOS_SAVE_SETTINGS()
            frame:SetOffset(cx, cy)
            
            return 1;
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
