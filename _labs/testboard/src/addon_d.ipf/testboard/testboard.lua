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
local acutil = require('acutil')
g.version = 0
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "testboard"
g.debug = true
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x = nil
g.y = nil
g.buffs = {}
g.prevtime=nil
g.framelist={}
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
function TESTBOARD_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function TESTBOARD_LOAD_SETTINGS()
    TESTBOARD_DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
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
            acutil.addSysIcon('testboard', 'sysmenu_sys', 'testboard', 'TESTBOARD_TOGGLE_FRAME')
            --addon:RegisterMsg('GAME_START_3SEC', 'TESTBOARD_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            addon:RegisterMsg("ZONE_TRAFFICS", "TESTBOARD_ON_ZONE_TRAFFICS");
            
            --addon:RegisterMsg('BUFF_ADD', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_REMOVE', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_UPDATE', 'TESTBOARD_BUFF_ON_MSG');
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            --TESTBOARD_SHOW(g.frame)
            TESTBOARD_GETFRAME_OLD=ui.GetFrame
            ui.GetFrame=TESTBOARD_GETFRAME

            TESTBOARD_INIT()
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TESTBOARD_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function TESTBOARD_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function TESTBOARD_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end
function TESTBOARD_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local button = frame:CreateOrGetControl("button", "btn", 0, 80, 200, 100)
            AUTO_CAST(button)
            button:SetEventScript(ui.LBUTTONUP, "TESTBOARD_TEST")
            button:SetText("INJECT LOVE!")
            
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("TESTBOARD_ON_TIMER");
            timer:Start(1);
            timer:EnableHideUpdate(true)

            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TESTBOARD_GETFRAME(name)
    
    local frame= TESTBOARD_GETFRAME_OLD(name)
    if(frame)then
        g.framelist[name]=frame
    end
    return frame
end
function TESTBOARD_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            -- local frame = ui.GetFrame(g.framename)
            -- local pic = frame:GetChild("pic")
            -- tolua.cast(pic, "ui::CPicture")
            -- local x, y = GET_LOCAL_MOUSE_POS(pic);
            -- if mouse.IsLBtnPressed() ~= 0 then
            --     if(g.x==nil or g.y==nil )then
            --         g.x=x
            --         g.y=y
            --     end
            --     --print(string.format("draw %d,%d",x,y))
            --     local pics=pic:GetPixelColor(x, y);
            --     --print("pics "..tostring(pics))
            --     pic:DrawBrush(g.x,g.y,x,y, "spray_8", "FFFF0000");
            --     pic:Invalidate()
            --     g.x=x
            --     g.y=y
            -- else
            --     g.x=nil
            --     g.y=nil
            -- end
            -- local fndList, fndCount = SelectObject(GetMyActor(), 400, 'ALL');
            -- local flag = 0
            -- for index = 1, fndCount do
            --     local enemyHandle = GetHandle(fndList[index]);
            --     if(enemyHandle~=nil)then
            --         local enemy = world.GetActor(enemyHandle);
            --         if enemy ~= nil then
            --             local apc=enemy:GetPCApc()
            --             local aid=enemy:GetPCApc():GetAID();
            --             local opc=session.otherPC.GetByStrAID(aid)
            --             if(opc~=nil)then
            --                --print(tostring(opc:GetPartyInfo()))
            --             end
            --         end
            --     end
            -- end
            --TESTBOARD_TEST()
            -- local objList, objCount = SelectObject(GetMyActor(), 400, 'ALL');
            -- if objCount > 0 then
            --     for i = 1, objCount do
            --         local enemyHandle = GetHandle(objList[i]);
            --         local enemy = world.GetActor(enemyHandle);
            --         if enemy ~= nil then
                        
                        
            --             local tgto = enemy:GetSkillTargetObject()
            --             if (tgto) then
            --                 local targetpos = tgto:GetPos()
            --                 local pos = enemy:GetPos()
            --                 --print("" .. targetpos.x)
            --                 local eff = "F_sys_arrow_pc"
            --                 local dist = math.sqrt(math.pow((targetpos.x - pos.x), 2) + math.pow((targetpos.z - pos.z), 2))
            --                 local dirinitial = dist
            --                 --DBGOUT("DIST" .. tostring(dirinitial))
            --                 while dist >= 1 do
            --                     local dir = math.atan(targetpos.x - pos.x, targetpos.z - pos.z)
                                
            --                     local di = dist / dirinitial
                                
            --                     local xx = pos.x + math.sin(dir) * dirinitial * di
            --                     local zz = pos.z + math.cos(dir) * dirinitial * di
                                
                                
                                
            --                     effect.PlayGroundEffect(GetMyActor(), eff, 1, xx, pos.y + 1, zz, 1, "None", -dir + math.pi, 0)
            --                     dist = dist - 20
            --                 end
            --             end
            --         end
            --     end
            
            -- end
            -- local frame = ui.GetFrame(g.framename)
            -- frame:EnableHide(0)
            -- local f=ui.GetFocusFrame()
            -- if(f)then
            --    -- f:SetOffset(100,100)
            --     CHAT_SYSTEM(f:GetName())
            -- end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function TESTBOARD_TEST()
    
    EBI_try_catch{
        try = function()
            --MarketRecipeSearch(1, "0;", 12);
            -- local clsList, cnt = GetClassList("AchievePoint");
            -- for i = 0, cnt - 1 do
                
            --     local cls = GetClassByIndexFromList(clsList, i);
            --     local rankName = cls.RankName;
            --     local group = cls.RankGroup;
                
            --     if rankName ~= "None" then
            --         if rankGroup == "None" or group == rankGroup then
            --             -- fameList:AddItem(cls.ClassID, rankName, 0);
            --             local key = cls.ClassID;
            --             local name = string.format("{a SEL_VIEW_RANK %s}{@st45}%s{/}{/}", key, rankName);
            --             setTxt = setTxt .. name .. "{s6}{nl} {nl}{/}";
            --         --local item = SET_ADVBOX_ITEM_C(fameList, key, 0, name, "white_16_ol");
            --         --item:EnableHitTest(1);
            --         end
            --     end
            
            -- end
            
            -- local objList, objCount = SelectObject(GetMyActor(), 400, 'ALL');
            -- if objCount > 0 then
            --     for i = 1, objCount do
            --         local enemyHandle = GetHandle(objList[i]);
            --         local enemy = world.GetActor(enemyHandle);
            --         if enemy ~= nil then
            --             local inf=info.GetTargetInfo(enemyHandle)
            --             if(inf.isBoss==1)then
            --                 local monCls=GetClassByType("Monster",enemy:GetType())
            --                 print(monCls.ClassName)
            --                 mouseUtil.SetMouseMonster(monCls.ClassName);
            --                 mouseUtil.HoldMouseMonster(true);
            --             end
            --         end
            --     end
            -- end
            -- g.prevtime=imcTime.GetDWTime()
            -- app.RequestChannelTraffics();

            -- local handle=session.GetMyHandle()
            -- local buffCount = info.GetBuffCount(handle);

            -- for i = 0, buffCount - 1 do
            --     local buff = info.GetBuffIndexed(handle, i);
            --     local class = GetClassByType('Buff', buff.buffID);
            --     DBGOUT(string.format("No%d:%s,%d,%d,%d,%d,%d",i,class.Name,buff.arg1,buff.arg2,buff.arg3,buff.arg4,buff.arg5))
            -- end
            
            --end
            --TESTBOARD_SET_NECRO_CARD_STATE()
            -- local off=0
            -- for k,v in pairs(g.framelist) do
            --     local f=ui.GetFrame(k)
            --     if(f)then
            --         if f:GetHeight()==10 or  f:GetHeight()==39 then
            --             f:SetOffset(100+off,100+off)
            --             f:Resize(200,39)
            --             off=off+1
            --             CHAT_SYSTEM(k)
            --         end
            --     end
            -- end
            --ui.GetFrame("chat_option_e"):ShowWindow(1)
            local sObj = GetIES(session.GetSessionObjectByName("ssn_klapeda"):GetIESObject());
            RegisterHookMsg_C(GetMyPCObject(),  nil, "TAKEDMG", "TESTBOARD_TAKEDAMAGE");
            SetSObjTimeScp_C(GetMyPCObject(), nil, "TESTBOARD_SCP", 500);
        --TESTBOARD_SET_NECRO_CARD_STATE()
        end,
        catch = function(error)
            ERROUT("FAIL:" .. tostring(error))
        end
    }
end
function TESTBOARD_TAKEDAMAGE()
    DBGOUT("take")
end
function TESTBOARD_SCP()
    DBGOUT("scp")
end
function TESTBOARD_SET_NECRO_CARD_STATE()
    local frame = ui.GetFrame("necronomicon")
    frame:ShowWindow(1)
    local handle = session.GetTargetHandle()
    local inf = info.GetTargetInfo(handle)
    local actor = world.GetActor(handle)
    local bossMonID = actor:GetType();
    print("" .. bossMonID)
    local bosscardcls = GetClassByType("Monster", bossMonID)
    local necoGbox = GET_CHILD(frame, 'necoGbox', "ui::CGroupBox")
    if nil == necoGbox then
        return;
    end
    
    local descriptGbox = GET_CHILD(necoGbox, 'descriptGbox', "ui::CGroupBox")
    if nil == descriptGbox then
        return;
    end
    
    NECRONOMICON_STATE_TEXT_RESET(descriptGbox);
    
    local gbox = GET_CHILD(descriptGbox, 'desc_name', "ui::CRichText")
    if nil ~= gbox then
        gbox:SetTextByKey("bossname", bosscardcls.Name);
    end
    
    
    
    local monCls = GetClassByType("Monster", bossMonID);
    if nil == monCls then
        return;
    end
    
    -- 가상몹을 생성합시다.
    local tempObj = CreateGCIESByID("Monster", bossMonID);
    if nil == tempObj then
        return;
    end
    tempObj.Lv = inf.level
    print("here")
    --print("" .. GetObject(tempObj))
    local pcObj = GetObject();
    
    --CLIENT_SORCERER_SUMMONING_MON(tempObj, pcObj, GetIES(skl:GetObject()), bosscardcls);
    -- 체력
    local myHp = GET_CHILD(descriptGbox, 'desc_hp', "ui::CRichText")
    local hp = math.floor(TESTBOARD_SCR_Get_MON_MHP(tempObj));
    print("CLSID" .. actor:GetType())
    print("" .. (inf.stat.maxHP / hp))
    print("" .. (213516912 / hp))
    myHp:SetTextByKey("value", hp);
    
    -- 물리 공격력
    local richText = GET_CHILD(descriptGbox, 'desc_fower', "ui::CRichText")
    richText:SetTextByKey("value", math.floor(SCR_Get_MON_MINPATK(tempObj)) .. "-" .. math.floor(SCR_Get_MON_MAXPATK(tempObj)));
    
    -- 방어력
    richText = GET_CHILD(descriptGbox, 'desc_defense', "ui::CRichText")
    richText:SetTextByKey("value", math.floor(SCR_Get_MON_DEF(tempObj)));
    
    -- 힘
    richText = GET_CHILD(descriptGbox, 'desc_Str', "ui::CRichText")
    richText:SetTextByKey("value", GET_MON_STAT(tempObj, tempObj.Lv, "STR"));
    
    -- 체력
    richText = GET_CHILD(descriptGbox, 'desc_Con', "ui::CRichText")
    -- 기본적으로 GET_MON_STAT을 쓰지만 체력은 따로해달라는 평직씨의 요청
    local con = math.floor(GET_MON_STAT(tempObj, tempObj.Lv, "CON"));
    richText:SetTextByKey("value", con + math.floor(pcObj.MNA * 0.1));
    
    -- 지능
    richText = GET_CHILD(descriptGbox, 'desc_Int', "ui::CRichText")
    richText:SetTextByKey("value", GET_MON_STAT(tempObj, tempObj.Lv, "INT"));
    
    -- 민첩
    richText = GET_CHILD(descriptGbox, 'desc_Dex', "ui::CRichText")
    richText:SetTextByKey("value", GET_MON_STAT(tempObj, tempObj.Lv, "DEX"));
    
    -- 정신
    richText = GET_CHILD(descriptGbox, 'desc_Mna', "ui::CRichText")
    richText:SetTextByKey("value", GET_MON_STAT(tempObj, tempObj.Lv, "MNA"));
    
    -- 생성한 가상몹을 지워야져
    DestroyIES(tempObj);
end
function TESTBOARD_SCR_Get_MON_MHP(self)
    local monHPCount = TryGetProp(self, "HPCount", 0);
    if monHPCount > 0 then
        return math.floor(monHPCount);
    end
    
    local fixedMHP = TryGetProp(self, "FIXMHP_BM", 0);
    if fixedMHP > 0 then
        return math.floor(fixedMHP);
    end
    
    local lv = TryGetProp(self, "Lv", 1);
    
    
    
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
            print("RATE" .. statTypeRate)
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
        value = value + 5000; -- PC Summon Monster MHP Add
    end
    
    
    if value < 1 then
        value = 1;
    end
    
    return math.floor(value);
end




function SHOW_DMG_DIGIT(arg)
    CHAT_SYSTEM(tostring(arg))
	return ScpArgMsg("ADD_DAMAGE_{Auto_1}!", "Auto_1", arg);
end
