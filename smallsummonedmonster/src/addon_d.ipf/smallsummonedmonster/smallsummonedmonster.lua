--アドオン名（大文字）
local addonName = "smallsummonedmonster"
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
g.framename = "smallsummonedmonster"
g.debug = false
g.x = nil
g.y = nil
g.buffs = {}

--ライブラリ読み込み
CHAT_SYSTEM("[SMALLSUMMONEDMONSTER]loaded")
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

function SMALLSUMMONEDMONSTER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLSUMMONEDMONSTER_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('GAME_START', 'SMALLSUMMONEDMONSTER_GAME_START');
            addon:RegisterMsg('GAME_START_3SEC', 'SMALLSUMMONEDMONSTER_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'SMALLSUMMONEDMONSTER_EVERY');
            local addontimer = frame:GetChild("addontimer")
            AUTO_CAST(addontimer)
            addontimer:SetUpdateScript("SMALLSUMMONEDMONSTER_ON_TIMER")
            addontimer:Start(0.5)
            addontimer:EnableHideUpdate(1)
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0, 0)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function SMALLSUMMONEDMONSTER_GAME_START()
    EBI_try_catch{
        try = function()
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SMALLSUMMONEDMONSTER_3SEC()


end
function SMALLSUMMONEDMONSTER_ON_TIMER()
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame(g.framename)
            local objList, objCount = SelectObject(GetMyActor(), 400, 'ALL');
            
            local myHandle = session.GetMyHandle();
            if objCount > 0 then
                for i = 1, objCount do
                    local enemyHandle = GetHandle(objList[i]);
                    local enemy = world.GetActor(enemyHandle);
                    local ownerHandle = info.GetOwner(enemyHandle);
                    local targetinfo = info.GetTargetInfo(enemyHandle);
                  
                    if enemy ~= nil and ownerHandle ~= 0 
                    and ownerHandle ~= myHandle
                    then
       
                        local monCls = GetClassByType("Monster", enemy:GetType());
                        --print(tostring(enemy:GetType()))
                        if (monCls~=nil and monCls.Faction~="Pet" and info.IsPC(ownerHandle)==1)
                        then
                            local limit = 10
                            while (enemy:GetScale() >= 0.125 and limit > 0) do
                                enemy:ChangeScale(0.25)
                                limit = limit - 1
                            end
                        end
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SMALLSUMMONEDMONSTER_EVERY()
    ui.GetFrame(g.framename):ShowWindow(1)
end
