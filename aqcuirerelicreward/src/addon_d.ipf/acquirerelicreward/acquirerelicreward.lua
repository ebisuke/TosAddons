--acquirerelicreward
--アドオン名（大文字）
local addonName = "acquirerelicreward"
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
g.framename = "アドオン名（大文字）"
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM("[ARR]loaded")
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


function ACQUIRERELICREWARD_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLUI_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('GAME_START_3SEC', 'ACQUIRERELICREWARD_GAME_START_3SEC');


        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ACQUIRERELICREWARD_GAME_START_3SEC()
    ACQUIRERELICREWARD_PROCESS()
end
function ACQUIRERELICREWARD_PROCESS()
    local mapClsName = session.GetMapName();

    if(mapClsName ==  "c_Klaipe" or mapClsName ==  "c_fedimian" or mapClsName ==  "c_orsha")then
        
        local acc = GetMyAccountObj()
        if acc == nil then
            return
        end

        local ccnt=0
        -- 퀘스트 정보 업데이트
        local clsList, cnt = GetClassList("Relic_Quest")
        for i = 0, cnt - 1 do
            local relicCls = GetClassByIndexFromList(clsList, i)
            local questType = TryGetProp(relicCls, 'QuestType', 'None')
            if questType ~= 'None' and questType ~= 'Category' then
                local pcObj = GetMyPCObject()
                local result = SCR_RELIC_QUEST_CHECK(pcObj, relicCls.ClassName)
                if result == "Reward" then
                    if ccnt==0 then
                        --ui.SysMsg('[ARR]Acquiring Relic Rewards.')
                    end
                    --ReserveScript(string.format('ACQUIRERELICREWARD_ACQUIRE_REWARD("%s")', relicCls.ClassName),ccnt*3)
                    ACQUIRERELICREWARD_ACQUIRE_REWARD(relicCls.ClassName)

                    ccnt=ccnt+1
                    ReserveScript("ACQUIRERELICREWARD_PROCESS()",1)
                    break
                end
            end
        end

    end

    
end

function ACQUIRERELICREWARD_ACQUIRE_REWARD(classname)
    local pcObj = GetMyPCObject()
	local result = SCR_RELIC_QUEST_CHECK(pcObj, classname)
	if result == "Reward" then
        pc.ReqExecuteTx("SCR_TX_RELIC_QUEST_REWARD", classname)
    end
end