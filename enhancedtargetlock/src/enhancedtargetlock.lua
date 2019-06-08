--アドオン名（大文字）
local addonName = "ENHANCEDTARGETLOCK";
local addonNameLower = string.lower(addonName);
--作者名
local author = "ebisuke";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);


--ライブラリ読み込み
local acutil = require('acutil');

--デフォルト設定
if not g.loaded then
    g.settings = {
            --有効/無効
            enable = true,
            --フレーム表示場所
            position = {
                x = 300,
                y = 300
            }
    };
end

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));




function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local acutil = require('acutil');
ENHANCEDTARGETLOCK_ENABLE = false
ENHANCEDTARGETLOCK_CT = nil
ENHANCEDTARGETLOCK_LOOPER = false
ENHANCEDTARGETLOCK_LOCKED = 0
ENHANCEDTARGETLOCK_FIXEDLOCK_STATE = false
local testbox = {
    {0, 0, 0},
    {0, 5, 0},
    {0, 10, 0},
    {0, 15, 0},
    {0, 25, 0},
    {0, 35, 0},
    {0, 45, 0},
    {0, 55, 0},
}
ENHANCEDTARGETLOCK_MOUSEMODE = false
local firstpos = nil

function ENHANCEDTARGETLOCK_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end
ENH = nil
function ENHANCEDTARGETLOCK_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame("enhancedtargetlock");
            g.addon = addon;
            g.frame = frame;
            
            if not g.loaded then
                local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
                if err then
                    --設定ファイル読み込み失敗時処理
                    CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName));
                else
                    --設定ファイル読み込み成功時処理
                    g.settings = t;
                end
                g.loaded = true;
            end
            --設定ファイル保存処理
            ENHANCEDTARGETLOCK_SAVE_SETTINGS();
            acutil.setupHook(ENHANCEDTARGETLOCK_ENABLE_JUMPER, 'CTRLTARGETUI_OPEN');
            acutil.setupHook(ENHANCEDTARGETLOCK_DISABLE_JUMPER, 'CTRLTARGETUI_CLOSE');
            addon:RegisterMsg('TARGET_SET', 'ENHANCEDTARGETLOCK_ON_TARGET');
            addon:RegisterMsg('TARGET_UPDATE', 'ENHANCEDTARGETLOCK_ON_TARGET_UPDATE');
            addon:RegisterMsg('TARGET_CLEAR', 'ENHANCEDTARGETLOCK_ON_TARGET_CLEAR');
            addon:RegisterMsg('FPS_UPDATE', 'ENHANCEDTARGETLOCK_ON_FPS_UPDATE');
            acutil.slashCommand("/etl", ENHANCEDTARGETLOCK_PROCESS_COMMAND);
            --ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "ENHANCEDTARGETLOCK_END_DRAG");
            frame:EnableHittestFrame(1)
            frame:EnableMove(1)
            frame:ShowWindow(1)
            --Moveではうまくいかないので、OffSetを使用する…
            frame:Move(0, 0);
            frame:SetOffset(g.settings.position.x, g.settings.position.y);
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
--フレーム場所保存処理
function ENHANCEDTARGETLOCK_END_DRAG()
    g.settings.position.x = g.frame:GetX();
    g.settings.position.y = g.frame:GetY();
    ENHANCEDTARGETLOCK_SAVE_SETTINGS();
end

function ENHANCEDTARGETLOCK_ENABLE_JUMPER()
    ENHANCEDTARGETLOCK_ENABLE()
--return CTRLTARGETUI_OPEN_OLD()
end
function ENHANCEDTARGETLOCK_DISABLE_JUMPER()
    ENHANCEDTARGETLOCK_DISABLE()
--return CTRLTARGETUI_CLOSE_OLD()
end
function ENHANCEDTARGETLOCK_ENABLE()
    
    return EBI_try_catch{
        try = function()
            ENHANCEDTARGETLOCK_FIXEDLOCK_STATE = true
            
            if (ENHANCEDTARGETLOCK_LOCKED == 0) then
                local frame = ui.GetFrame("enhancedtargetlock")
                frame:ShowWindow(1)
                local findenemy = ENHANCEDTARGETLOCK_FINDNEAREST_BOSS()
                if (findenemy ~= nil) then
                    local enemyActor = world.GetActor(findenemy)
                    local monsterClass = GetClassByType("Monster", enemyActor:GetType());
                    --CHAT_SYSTEM("[ETL]Locked" .. monsterClass.Name)
                    ENHANCEDTARGETLOCK_SETTEXT(monsterClass.Name, 1)
                    ReserveScript("ENHANCEDTARGETLOCK_UPDATETEXT()",0.05)
                    ENHANCEDTARGETLOCK_CT = findenemy
                    
                    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
                    ENHANCEDTARGETLOCK_TARGETTING()
                --timer:SetUpdateScript("ENHANCEDTARGETLOCK_TARGETTING");
                --timer:Start(0.5);
                end
            end
        end,
        catch = function(error)
            print(error)
        end
    }

--return CTRLTARGETUI_OPEN_OLD()
end
function ENHANCEDTARGETLOCK_DISABLE()
    
    ENHANCEDTARGETLOCK_FIXEDLOCK_STATE = false
    if ENHANCEDTARGETLOCK_LOCKED == 0 then
        
        --CHAT_SYSTEM("CHG2")
        ENHANCEDTARGETLOCK_CT = nil
        local frame = ui.GetFrame("enhancedtargetlock")
        local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
        --timer:Stop();
        ENHANCEDTARGETLOCK_SETTEXT("", 0)
    end
--return CTRLTARGETUI_CLOSE_OLD()
end
function ENHANCEDTARGETLOCK_SETTEXT(text, mode)
    local frame = ui.GetFrame("enhancedtargetlock")
    local textbox = frame:GetChild("textbox")
    tolua.cast(textbox, "ui::CRichText")
    local temp = textbox:GetTextByKey("text")
    if (mode == 0) then

        textbox:SetFormat("{ds}{@s14}{ol}{#FFFFFF}");
        textbox:SetTextByKey("text", "");
        textbox:SetTextByKey("text", "ETL");
    elseif (mode == 1) then
        
        textbox:SetFormat("{ds}{ol}{#22ddFF}");
        if (text ~= nil) then
            textbox:SetTextByKey("text", "ETL:" .. text);
        else
            textbox:SetTextByKey("text", "");
            textbox:SetTextByKey("text", temp);
        end
    elseif (mode == 2) then
        
        textbox:SetFormat("{ds}{ol}{#FF0000}");
        if (text ~= nil) then
            textbox:SetTextByKey("text", "ETL:" .. text);
        else
            textbox:SetTextByKey("text", "");
            textbox:SetTextByKey("text", temp);
        end
    elseif (mode == 3) then
        --target lost
        textbox:SetFormat("{ds}{ol}{#666666}");
        if (text ~= nil) then
            textbox:SetTextByKey("text", "ETL:" .. text);
        else
            textbox:SetTextByKey("text", "");
            textbox:SetTextByKey("text", temp);
        end
    end
    textbox:Invalidate()
    frame:ShowWindow(1);

end

function ENHANCEDTARGETLOCK_FINDNEAREST_BOSS()
    return EBI_try_catch{
        try = function()
            local nearestdistance = 999999999
            local mypos = GetMyActor():GetPos()
            local nearestEnemy = nil
            local objList, objCount = SelectObject(GetMyActor(), 400, 'ENEMY')
            
            --ボスを検索
            for i = 1, objCount do
                local enemyHandle = GetHandle(objList[i])
                local enemyActor = world.GetActor(enemyHandle)
                local monsterClass = GetClassByType("Monster", enemyActor:GetType());
                
                if (monsterClass ~= nil) then
                    if (monsterClass.MonRank == "Boss") then
                        --死んでたら除外
                        local stat = info.GetStat(enemyHandle)
                        if (stat.HP > 0) then
                            local enemypos = enemyActor:GetPos()
                            --距離を測る
                            local dist = math.sqrt((mypos.x - enemypos.x) ^ 2 + (mypos.z - enemypos.z) ^ 2)
                            if (dist < nearestdistance) then
                                nearestEnemy = enemyHandle
                                nearestdistance = dist
                            end
                        
                        end
                    end
                end
            end
            return nearestEnemy
        end,
        catch = function(error)
            print(error)
        end
    }
end

function ENHANCEDTARGETLOCK_TARGETTING()
    ReserveScript("ENHANCEDTARGETLOCK_TARGETTING_ON()", 0.01)
--ReserveScript("ENHANCEDTARGETLOCK_TARGETTING()",0.01)
end
function ENHANCEDTARGETLOCK_TARGETTING_ON()
    EBI_try_catch{
        try = function()
            if (ENHANCEDTARGETLOCK_CT == nil) then
                ENHANCEDTARGETLOCK_DISABLE()
                --print("neaz")
                return
            end
            
            local targetactor = world.GetActor(ENHANCEDTARGETLOCK_CT)
            local myactor = GetMyActor()
            if (targetactor == nil) then
                ENHANCEDTARGETLOCK_DISABLE()
                --print("ned")
                return
            end
            --死んでたら除外
            local stat = info.GetStat(ENHANCEDTARGETLOCK_CT)
            if (stat.HP <= 0) then
                ENHANCEDTARGETLOCK_CT = nil
                
                ENHANCEDTARGETLOCK_DISABLE()
            else
                if (session.GetTargetHandle() ~= ENHANCEDTARGETLOCK_CT and ENHANCEDTARGETLOCK_LOCKED == 0) then
                    --DRT_ATTACH_TO_TARGET_C(myactor,nil,ENHANCEDTARGETLOCK_CT,nil,"")
                    local frame = ui.GetFrame('enhancedtargetlock')
                    ENHANCEDTARGETLOCK_SETTEXT(nil, 2)
                    firstpos = {mouse.GetX(), mouse.GetY()}
                    ENHANCEDTARGETLOCK_LOCKED = 1
                    ENHANCEDTARGETLOCK_FORCEDTARGET()
                end
            end
        --DRT_LOOKAT_C(myactor, nil, ENHANCEDTARGETLOCK_CT)
        end,
        catch = function(error)
            print(error)
        end
    }
end

function ENHANCEDTARGETLOCK_FORCEDTARGET()
    EBI_try_catch{
        try = function()
            if (session.GetTargetHandle() ~= ENHANCEDTARGETLOCK_CT and ENHANCEDTARGETLOCK_LOCKED <= #testbox) then
                --DRT_ATTACH_TO_TARGET_C(myactor,nil,ENHANCEDTARGETLOCK_CT,nil,"")
                local cur = testbox[ENHANCEDTARGETLOCK_LOCKED]
                local targetactor = world.GetActor(ENHANCEDTARGETLOCK_CT)
                local pos = targetactor:GetPos()
                local pts = world.ToScreenPos(pos.x + cur[1], pos.y + cur[2], pos.z + cur[3]);
                local crx = pts.x
                local cry = pts.y
                
                
                if (option.GetClientWidth() >= 3000) then
                    
                    --4k対応
                    crx = crx * 2
                    cry = cry * 2
                
                end
                --ensure
                if (crx >= 0 and cry >= 0 and crx < option.GetClientWidth() and cry < option.GetClientHeight()) then
                    --in
                    mouse.SetHidable(0);
                    ENHANCEDTARGETLOCK_MOUSEMODE = true
                    --CHAT_SYSTEM(string.format("pos %d/%d", crx, cry))
                    if (ENHANCEDTARGETLOCK_LOCKED == 1) then
                        
                        session.config.SetMouseMode(true)
                        EMBEDDEDBATTLEMODE_SET_BM(1)
                    end
                    mouse.SetPos(crx, cry)
                    ENHANCEDTARGETLOCK_LOCKED = ENHANCEDTARGETLOCK_LOCKED + 1
                    ReserveScript("ENHANCEDTARGETLOCK_FORCEDTARGET()", 0.01)
                else
                    --画面範囲外
                    ENHANCEDTARGETLOCK_LOCKED = ENHANCEDTARGETLOCK_LOCKED + 1
                    ENHANCEDTARGETLOCK_FORCEDTARGET()
                end
            
            else
                ReserveScript("ENHANCEDTARGETLOCK_TARGET_END()", 0.01)
            end
        end,
        catch = function(error)
            print(error)
        end
    }
end
function ENHANCEDTARGETLOCK_TARGET_END()
    if (ENHANCEDTARGETLOCK_MOUSEMODE == true) then
        session.config.SetMouseMode(false)
        EMBEDDEDBATTLEMODE_SET_BM(0)
        mouse.SetPos(firstpos[1], firstpos[2]);
        ENHANCEDTARGETLOCK_MOUSEMODE = false
    
    end
    
    ENHANCEDTARGETLOCK_SETTEXT(nil, 1)
    ENHANCEDTARGETLOCK_LOCKED = 0
end
function ENHANCEDTARGETLOCK_ON_TARGET()

end


function ENHANCEDTARGETLOCK_ON_TARGET_UPDATE()

end
function ENHANCEDTARGETLOCK_ON_TARGET_CLEAR()

end

function ENHANCEDTARGETLOCK_ON_FPS_UPDATE(frame)
    ENHANCEDTARGETLOCK_UPDATETEXT()
 
end
function ENHANCEDTARGETLOCK_UPDATETEXT()
    if (ENHANCEDTARGETLOCK_LOCKED == 0) then
        
        if (ENHANCEDTARGETLOCK_FIXEDLOCK_STATE == true and ENHANCEDTARGETLOCK_CT ~= nil) then
            
            --ターゲットしていなければ色を変える
            if (ENHANCEDTARGETLOCK_CT == session.GetTargetHandle()) then
                ENHANCEDTARGETLOCK_SETTEXT(nil, 1)
            else
                ENHANCEDTARGETLOCK_SETTEXT(nil, 3)
            end
        else
            
            ENHANCEDTARGETLOCK_SETTEXT(nil, 0)
        end
    end
end
function ENHANCEDTARGETLOCK_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = "usage{nl}/etl retarget ターゲットする"
        return ui.MsgBox(msg, "", "Nope")
    end
    
    if cmd == "retarget" then
        ENHANCEDTARGETLOCK_TARGETTING();
    end
    if cmd == "initpos" then
        local frame = ui.GetFrame("enhancedtargetlock")
        frame:ShowWindow(1);
        frame:SetOffset(300, 300);
        ENHANCEDTARGETLOCK_SAVE_SETTINGS();
    end
end
