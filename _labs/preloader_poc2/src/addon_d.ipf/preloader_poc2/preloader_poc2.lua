--preloader_poc2
local addonName = "preloader_poc2"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
g.framename = "preloader_poc2"

--ライブラリ読み込み
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
PRELOADER_ADDLISTENER(PRELOADER.Events.EventsOnBarrack, function(addon, frame)
    local frame = ui.CreateNewFrame('balloon', 'POC_CHARSELECT')
    frame:RemoveAllChild()
    frame:SetOffset(20, 200)
    frame:Resize(1800, 600)
    frame:SetSkinName("bg2")
    frame:SetColorTone("FFFFFFFF")
    frame:ShowWindow(1)
    
    if SELECTTEAM_NEW_CTRL ~= SELECTTEAM_NEW_CTRL_NEW then
        SELECTTEAM_NEW_CTRL_OLD = SELECTTEAM_NEW_CTRL
        SELECTTEAM_NEW_CTRL = SELECTTEAM_NEW_CTRL_NEW
    end
end)
PRELOADER_ADDLISTENER(PRELOADER.Events.EventsOnTitle, function()
    
    end)
EBI_try_catch{
    try = function()
        
        local cnt = 0
        function SELECTTEAM_NEW_CTRL_NEW(frame, actor)
            EBI_try_catch{
                try = function()
                    
                    local cframe = ui.GetFrame('POC_CHARSELECT')
                    local barrackOwner = session.barrack.GetMyAccount();
                    local account = session.barrack.GetCurrentAccount();
                    local myaccount = session.barrack.GetMyAccount();
                    local barrackMode = frame:GetUserValue("BarrackMode");
                    SELECTTEAM_NEW_CTRL_OLD(frame, actor)
                    if "Visit" == barrackMode and account == myaccount then
                        cframe:ShowWindow(0)
                        return;
                    end
                    
                    cframe:ShowWindow(1)
                    local myCharCont = barrackOwner:GetPCCount();
                    local barrackMode = frame:GetUserValue("BarrackMode");
                    local name = actor:GetName();
                    local brk = GetBarrackSystem(actor);
                    local key = brk:GetCIDStr();
                    local bpc = barrack.GetBarrackPCInfoByCID(key);
                    local imgName = ui.CaptureMyFullStdImageByAPC(actor:GetPCApc(), 2, 1);
                    local pic = cframe:CreateOrGetControl('picture', 'pic' .. cnt, cnt * 100 + 10, 20, 100, 200);
                    AUTO_CAST(pic)
                    pic:SetImage(imgName)
                    local names = cframe:CreateOrGetControl('richtext', 'txt' .. cnt, cnt * 100 + 10, 220, 100, 200);
                    names:SetText("{ol}" .. name)
                    cframe:Invalidate();
                end,
                catch = function(error)
                    ui.SysMsg('ERROR:' .. error)
                end
            }
        end
    end,
    catch = function(error)
        ui.SysMsg('ERROR:' .. error)
    end
}
