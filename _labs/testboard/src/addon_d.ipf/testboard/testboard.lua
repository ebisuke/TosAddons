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
            addon:RegisterMsg('GAME_START_3SEC', 'TESTBOARD_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --addon:RegisterMsg("ZONE_TRAFFICS", "TESTBOARD_ON_ZONE_TRAFFICS");
            

            --addon:RegisterMsg('BUFF_ADD', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_REMOVE', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_UPDATE', 'TESTBOARD_BUFF_ON_MSG');
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            --TESTBOARD_SHOW(g.frame)
            --TESTBOARD_GETFRAME_OLD=ui.GetFrame
            --ui.GetFrame=TESTBOARD_GETFRAME

            TESTBOARD_INIT()
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TESTBOARD_SHOW(frame)
    --frame = ui.GetFrame(g.framename)
    --frame:ShowWindow(1)
    imcAddOn.BroadMsg("WEEKLY_BOSS_DPS_START");
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
            timer:Start(0.01);
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
            if g.b then
                local pc = GetMyActor()
                g.a=g.a+0.01
            --[[      
                pc:DetachCopiedModel();
                pc:ChangeEquipNode(EmAttach.eHelmet, "Dummy_L_HAND");
                pc:ChangeEquipNode(EmAttach.eLHand, "Dummy_L_HAND");
                pc:ChangeEquipNode(EmAttach.eRHand, "Dummy_L_HAND");
          
                pc:CopyAttachedModel(EmAttach.eLHand, "Dummy_L_HAND");
                pc:CopyAttachedModel(EmAttach.eRHand, "Dummy_L_HAND");
               ]]
            end
                  end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function TESTBOARD_TEST()
    
    EBI_try_catch{
        try = function()
            g.a=0
            if g.b then
                g.b=false
            else
                g.b=true
            end
            
             --local pc = GetMyActor()
            local itemClsList, cnt = GetClassList('NormalTX');
            for i = 0, cnt - 1 do
             local itemCls = GetClassByIndexFromList(itemClsList, i);
                CHAT_SYSTEM(string.format('%d/%s',itemCls.ClassID,itemCls.ClassName))
            end 

            --pc.ReqExecuteTx_NumArgs('SCR_TX_TP_SHOP',{1})
            --RunScript('SCR_WEEKLY_BOSS_DPS_START()')

            --pc.ReqExecuteTx_Item("ABILITY_POINT_RESET", "SCR_WEEKLY_BOSS_DPS_START",'SCR_WEEKLY_BOSS_DPS_START');
            --pc.ReqExecuteTx_Item("ABILITY_POINT_RESET", "SCR_WEEKLY_BOSS_DPS_START",'SCR_WEEKLY_BOSS_DPS_START');
             -- local pos=pc:GetPos()
            -- local actor=pc
            -- local targetActor=world.GetActor(session.GetTargetHandle())
            -- --PlayEffect(actor, 'F_circle020_light', 1.5,1,'BOT')
           
            -- effect.PlayTextEffect(pc,"I_SYS_damage_4","100");
            -- effect.PlayTextEffect(pc,"I_SYS_damage_3","100")
            -- effect.PlayTextEffect(pc,"I_SYS_damage_2","100");
            -- effect.PlayTextEffect(pc,"I_SYS_damage_1","100");
            -- effect.PlayTextEffect(pc,"I_SYS_damage",'100');
            -- effect.PlayTextEffect(pc,"SHOW_DMG_SHIELD","100");
            -- effect.PlayTextEffect(pc,"I_SYS_heal2","100");
             --local objList, objCount = SelectObject(self, 300, 'ALL') 
            -- CHAT_SYSTEM("Thaurge BEGIN")
                    
            -- for i = 1, objCount do
            --     local enemyHandle = GetHandle(objList[i]);
			--     local enemy = world.GetActor(enemyHandle);
            --     if objList[i].ClassName == 'pcskill_Warlock_DarkTheurge' then
            --         local enemyDestPos = enemy:GetArgPos(0);
            --         local enemyPos = enemy:GetPos();
            --         local distFromActor = imcMath.Vec3Dist(enemyPos, pos);
            --         CHAT_SYSTEM("Thaurge"..enemyHandle..":"..tostring(objList[i].Faction))
                  
            --     end
            --     if objList[i].ClassID==150011 then
            --         ACCEPT_NEXT_LEVEL_CHALLENGE_MODE(enemyHandle)
            --     end
            --     if objList[i].ClassID==150010 then
            --         ACCEPT_CHALLENGE_MODE(enemyHandle)
            --     end
            -- end
            -- for i = 1, objCount do
            --     local enemyHandle = GetHandle(objList[i]);
			--     local enemy = world.GetActor(enemyHandle);
            --     if objList[i].ClassName == 'pcskill_Warlock_DarkTheurge' then
            --         local enemyDestPos = enemy:GetArgPos(0);
            --         local enemyPos = enemy:GetPos();
            --         local distFromActor = imcMath.Vec3Dist(enemyPos, pos);
            --         CHAT_SYSTEM("Thaurge"..enemyHandle..":"..tostring(objList[i].Faction))
                  
            --     end
            --     if objList[i].ClassID==150011 then
            --         ACCEPT_NEXT_LEVEL_CHALLENGE_MODE(enemyHandle)
            --     end
            --     if objList[i].ClassID==150010 then
            --         ACCEPT_CHALLENGE_MODE(enemyHandle)
            --     end
            -- end
 
            -- local actor = GetMyActor()
        
            -- local scenePos = world.GetActorPos(actor:GetHandleVal());	
            -- scenePos.y = scenePos.x;	
            -- local scenePos2 = world.GetActorPos(actor:GetHandleVal());	
            -- scenePos2.x = scenePos2.x+50;	
            -- --pc:SetDirMoveSpeed(33);
            -- --pc:SetDirMoveAccel(33);
            -- actor:SetMoveFromPos(scenePos);
            -- actor:SetMoveDestPos(scenePos2);
            -- actor:SetDirDestPos(scenePos2);
        
            -- actor:SetFSMTime( imcTime.GetAppTime() );
            -- --actor:ActorJump(10000, 100);
            -- --actor:ProcessDirMove(0.1);
            -- actor:MoveDirTo(scenePos2,1)

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

-- damage_meter.lua

local damage_meter_info_total = {}

function DAMAGE_METER_ON_INIT(addon, frame)
    addon:RegisterMsg('GAME_START', 'DAMAGE_METER_OPEN_CHECK');
    addon:RegisterMsg('WEEKLY_BOSS_DPS_START', 'DAMAGE_METER_UI_OPEN');
    addon:RegisterMsg('WEEKLY_BOSS_DPS_END', 'WEEKLY_BOSS_DPS_END');
    addon:RegisterMsg('WEEKLY_BOSS_DPS_TIMER_UPDATE', 'WEEKLY_BOSS_DPS_TIMER_UPDATE_BY_SERVER');
end

function DAMAGE_METER_UI_OPEN(frame,msg,strArg,numArg)
    frame:ShowWindow(1)
    WEEKLYBOSS_DPS_INIT(frame,strArg,numArg)
end

function WEEKLYBOSS_DPS_INIT(frame,strArg,appTime)
    local stringList = StringSplit(strArg,'/');
    local handle = tonumber(stringList[1])
    local is_practice = stringList[2]

    local stageGiveUp = GET_CHILD_RECURSIVELY(frame,'stageGiveUp')
    stageGiveUp:SetEnable(BoolToNumber(is_practice == "PRACTICE"))

    DAMAGE_METER_SET_WEEKLY_BOSS(frame,handle);

    frame:SetUserValue("NOW_TIME",appTime)
    frame:SetUserValue("END_TIME",appTime + 60*7)
    DAMAGE_METER_UPDATE_TIMER(frame)

    frame:SetUserValue("DPSINFO_INDEX","0")
    frame:SetUserValue("TOTAL_DAMAGE","0")
    damage_meter_info_total = {}
    session.dps.ReqStartDpsPacket();
    frame:RunUpdateScript("WEEKLY_BOSS_UPDATE_DPS", 0.1);
    
    DAMAGE_METER_RESET_GAUGE(frame)
end

function DAMAGE_METER_RESET_GAUGE(frame)
    local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame,"damageRankGaugeBox")
    damageRankGaugeBox:RemoveAllChild()

    DAMAGE_METER_WEEKLY_BOSS_TOTAL_DAMAGE(frame,0)
end

function DAMAGE_METER_SET_WEEKLY_BOSS(frame,handle)
    frame:SetUserValue("WEEKLY_BOSS_HANDLE",handle)
end

function DAMAGE_METER_WEEKLY_BOSS_TOTAL_DAMAGE(frame,accDamage)
    accDamage = STR_KILO_CHANGE(accDamage)
    local font = frame:GetUserConfig('GAUGE_FONT');
    local damageAccGaugeBox = GET_CHILD_RECURSIVELY(frame,'damageAccGaugeBox')
    local ctrlSet = damageAccGaugeBox:CreateOrGetControlSet('gauge_with_two_text', 'GAUGE_ACC', 0, 0);

    DAMAGE_METER_GAUGE_SET(ctrlSet,'',100,font..accDamage,'gauge_damage_meter_accumulation')
end

function DAMAGE_METER_GAUGE_SET(ctrl,leftStr,point,rightStr,skin)
    local leftText = GET_CHILD_RECURSIVELY(ctrl,'leftText')
    leftText:SetTextByKey('value',leftStr)
    
    local rightText = GET_CHILD_RECURSIVELY(ctrl,'rightText')
    rightText:SetTextByKey('value',rightStr)
    
    local guage = GET_CHILD_RECURSIVELY(ctrl,'gauge')
    guage:SetPoint(point,100)
    guage:SetSkinName(skin)
end

function WEEKLY_BOSS_UPDATE_DPS(frame,totalTime,elapsedTime)
    local now_time = frame:GetUserValue("NOW_TIME")
    frame:SetUserValue("NOW_TIME",now_time + elapsedTime)
    DAMAGE_METER_UPDATE_TIMER(frame)

    local idx = frame:GetUserValue("DPSINFO_INDEX")
    if idx == nil then
        return 1;
    end
    local cnt = session.dps.Get_allDpsInfoSize()
    if idx == cnt then
        return 1;
    end
    
    AUTO_CAST(frame)
    local totalDamage = frame:GetUserValue("TOTAL_DAMAGE");

    local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame,"damageRankGaugeBox")
    local gaugeCnt = damageRankGaugeBox:GetChildCount()
    local maxGaugeCount = 5

    local handle = tonumber(frame:GetUserValue("WEEKLY_BOSS_HANDLE"))
    for i = idx, cnt - 1 do
        local info = session.dps.Get_alldpsInfoByIndex(i)
        if info:GetHandle() == handle then
            local damage = info:GetStrDamage();
            if damage ~= '0' then
                local sklID = info:GetSkillID();
                local sklCls = GetClassByType("Skill",sklID)
                local keyword = TryGetProp(sklCls,"Keyword","None")
                keyword = StringSplit(keyword,';')
                for i = 1,#keyword do
                    if keyword[i] == 'NormalSkill' then
                        sklID = 1
                        break;
                    end
                end
                if table.find(keyword, "pcSummonSkill") > 0 then
                    sklID = 163915
                end
                if table.find(keyword, "Ancient") > 0 then
                    sklID = 179999
                end
                --update gauge damage info
                local function getIndex(table, val)
                    for i=1,#table do
                    if table[i][1] == val then 
                        return i
                    end
                    end
                    return #table+1
                end

                --add damage info
                local info_idx = getIndex(damage_meter_info_total,sklID)
                if damage_meter_info_total[info_idx] == nil then
                    damage_meter_info_total[info_idx] = {sklID,damage}
                else
                    damage_meter_info_total[info_idx][2] = SumForBigNumberInt64(damage,damage_meter_info_total[info_idx][2])
                end

                totalDamage = SumForBigNumberInt64(damage,totalDamage)
            end
        end
    end
    table.sort(damage_meter_info_total,function(a,b) return IsGreaterThanForBigNumber(a[2],b[2])==1 end)
    frame:SetUserValue("DPSINFO_INDEX",cnt)
    UPDATE_DAMAGE_METER_GUAGE(frame,damageRankGaugeBox)
    DAMAGE_METER_WEEKLY_BOSS_TOTAL_DAMAGE(frame,totalDamage)
    frame:SetUserValue("TOTAL_DAMAGE",totalDamage)
    return 1;
end

function DAMAGE_METER_UPDATE_TIMER(frame)
    local now_time = tonumber(frame:GetUserValue('NOW_TIME'))
    local end_time = tonumber(frame:GetUserValue('END_TIME'))
    local remain_time = math.floor(end_time - now_time)
    
    if remain_time < 0 then
        return;
    end

    local remaintimeValue = GET_CHILD_RECURSIVELY(frame,"remaintimeValue")
    local remaintimeGauge = GET_CHILD_RECURSIVELY(frame,"remaintimeGauge")
    
    remaintimeValue:SetTextByKey("min",math.floor(remain_time/60))
    remaintimeValue:SetTextByKey("sec",remain_time%60)
    remaintimeGauge:SetPoint(remain_time,60*7)
end

function WEEKLY_BOSS_DPS_TIMER_UPDATE_BY_SERVER(frame,msg,strArg,numArg)
    frame:SetUserValue('NOW_TIME',numArg)
end

function UPDATE_DAMAGE_METER_GUAGE(frame,groupbox)
    if #damage_meter_info_total == 0 then
        return
    end
    local maxDamage = damage_meter_info_total[1][2]
    local font = frame:GetUserConfig('GAUGE_FONT');
    local cnt = math.min(10,#damage_meter_info_total)
    for i = 1, cnt do
        local sklID = damage_meter_info_total[i][1]
        local damage = damage_meter_info_total[i][2]
        local skl = GetClassByType("Skill",sklID)

        if skl ~= nil then
            local ctrlSet = groupbox:GetControlSet('gauge_with_two_text', 'GAUGE_'..i)
            if ctrlSet == nil then
                ctrlSet = DAMAGE_METER_GAUGE_APPEND(frame,groupbox,i)
            end
            local point = MultForBigNumberInt64(damage,"100")
            point = DivForBigNumberInt64(point,maxDamage)
            local skin = 'gauge_damage_meter_0'..math.min(i,4)
            damage = font..STR_KILO_CHANGE(damage)
            DAMAGE_METER_GAUGE_SET(ctrlSet,font..skl.Name,point,font..damage,skin);
        end
    end
end

function DAMAGE_METER_GAUGE_APPEND(frame,groupbox, index)
    local height = 17
    local ctrlSet = groupbox:CreateControlSet('gauge_with_two_text', 'GAUGE_'..index, 0, (index-1)*height);
    if index <= 10 then
        frame:Resize(frame:GetWidth(),frame:GetHeight()+height)
        groupbox:Resize(groupbox:GetWidth(),groupbox:GetHeight()+height)
    end
    return ctrlSet
end

function DAMAGE_METER_OPEN_CHECK(frame)
    frame:ShowWindow(0)
end

function WEEKLY_BOSS_DPS_END(frame,msg,argStr,argNum)
    CHAT_SYSTEM('enddps')
    frame:StopUpdateScript("WEEKLY_BOSS_UPDATE_DPS");
    --session.dps.ReqStopDps();
    
    local button = GET_CHILD_RECURSIVELY(frame,"stageGiveUp")
    button:SetEnable(0)
end

function DAMAGE_METER_REQ_RETURN()
    
    local yesscp = 'DAMAGE_METER_REQ_RETURN_YSE()';
	ui.MsgBox(ClMsg('WeeklyBoss_GiveUp_MSG'), yesscp, 'None');
end

function DAMAGE_METER_REQ_RETURN_YSE()
    --GAME_MOVE_CHANNEL(2);
    --restart.SendRestartGuildTower();
    for i=0,100 do 
         ReserveScript('session.dps.ReqStartDpsPacket();',i*0.1)
    end
    RUN_GAMEEXIT_TIMER("RaidReturn")
end
function ON_GAMEEXIT_TIMER_END(frame)
	local type = frame:GetUserValue("EXIT_TYPE");

	if type == "Exit" then
		DO_QUIT_GAME();
	elseif type == "Logout" then
		GAME_TO_LOGIN();
	elseif type == "Barrack" then
		GAME_TO_BARRACK();
	elseif type == "Channel" then
		local channel = frame:GetUserValue("CHANNEL");
		if channel ~= nil then
			GAME_MOVE_CHANNEL(channel);
		end
	elseif type == "RaidReturn" then
		--addon.BroadMsg("WEEKLY_BOSS_DPS_END","",0);
		
	end
end