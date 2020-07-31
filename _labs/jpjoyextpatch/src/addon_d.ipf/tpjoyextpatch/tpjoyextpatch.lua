--アドオン名（大文字）
local addonName = "tpjoyextpatch"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.framename = "tpjoyextpatch"
g.debug = false


--ライブラリ読み込み
CHAT_SYSTEM("[tpjoyextpatch]loaded")
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

_G['TPJOYEXT'] = _G['TPJOYEXT'] or {};
local g7 = _G['TPJOYEXT'];



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

function TPJOYEXTPATCH_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", TOJOYEXTPATCH_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('GAME_START', 'TOJOYEXTPATCH_GAME_START');
            addon:RegisterMsg('GAME_START_3SEC', 'TOJOYEXTPATCH_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'TOJOYEXTPATCH_EVERY');

        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function TOJOYEXTPATCH_GAME_START()
    EBI_try_catch{
        try = function()
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TOJOYEXTPATCH_3SEC()


end
function TOJOYEXTPATCH_ON_TIMER()
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame(g.framename)
            local objList, objCount = SelectObject(GetMyActor(), 400, 'ALL');
            
            local myHandle = session.GetMyHandle();
            local list = session.party.GetPartyMemberList(PARTY_GUILD);
            if objCount > 0 then
                for i = 1, objCount do
                    local handle = GetHandle(objList[i]);
                    local actor = world.GetActor(handle);
         
                    local targetinfo = info.GetTargetInfo(handle);
                    if info.IsPC(handle) and targetinfo.IsDummyPC ~= 1 then
                        local cid = info.GetCID(handle);
                        local info = session.otherPC.GetByStrCID(cid);
                        if(info~=nil)then
                            local paid=info:GetAID()

                            local guild = GET_MY_GUILD_INFO();
                            if guild == nil then
                                return;
                            end
                            local guildid=guild.info:GetPartyID();
                            local count = list:Count();    
                            for i = 0 , count - 1 do
                                local partyMemberInfo = list:Element(i);                            
                                local aid = partyMemberInfo:GetAID();
                                if(paid==aid)then
                                    --aura
                                    print("aura")
                                    actor:SetAuraInfo("GuildMemberAura");
                                end
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
function TOJOYEXTPATCH_EVERY()
    ui.GetFrame(g.framename):ShowWindow(1)
end
