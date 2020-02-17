--アドオン名（大文字）
local addonName = "buffremainvisualizer"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.framename = "buffremainvisualizer"

g.buffs={}
--ライブラリ読み込み
CHAT_SYSTEM("[BRV]loaded")
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


--マップ読み込み時処理（1度だけ）
function BUFFREMAINVISUALIZER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame


            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            addon:RegisterMsg('BUFF_ADD', 'BUFFREMAINVISUALIZER_BUFF_ON_MSG');
            addon:RegisterMsg('BUFF_REMOVE', 'BUFFREMAINVISUALIZER_BUFF_ON_MSG');
            addon:RegisterMsg('BUFF_UPDATE', 'BUFFREMAINVISUALIZER_BUFF_ON_MSG');

            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function BUFFREMAINVISUALIZER_ICON_UPDATE_BUFF_PSEUDOCOOLDOWN(icon)
    
    local totalTime = 20000;
    local curTime = 0;
    EBI_try_catch{
        try = function()
            
            local iconInfo = icon:GetInfo();
            if(g.buffs[ iconInfo.type]~=nil)then
                totalTime=g.buffs[ iconInfo.type].time or 0
            end
            local buff = info.GetBuff(session.GetMyHandle(), iconInfo.type);
            if buff ~= nil then
              
                curTime=buff.time;
                local n
                
                if(totalTime~=0)then
                    n=48
                else
                    n=255
                end
                if(curTime>0)then
                    icon:SetColorTone(string.format("FF%02X%02X%02X",n,n,n))
                else
                    --icon:SetColorTone(string.format("%02X%02X%02X%02X",n,math.min(255,n*2),math.min(255,n*2),math.min(255,n*2)))
                    icon:SetColorTone("FFFFFFFF")
                end
               
            end
          
        end,
        catch = function(error)
            --TESTBOARD_ERROUT("FAIL:" .. tostring(error))
        end
    }
 
    return curTime, totalTime;
end
function BUFFREMAINVISUALIZER_BUFF_ON_MSG(frame, msg, argStr, argNum)
    EBI_try_catch{
        try = function()
            local handle = session.GetMyHandle();
            if msg == "BUFF_ADD" then
               
                local buff = info.GetBuff(session.GetMyHandle(), argNum);
                g.buffs[argNum]={time=buff.time}
                
            elseif msg == "BUFF_REMOVE" then
                g.buffs[argNum]=nil
            elseif msg == "BUFF_UPDATE" then
                local buff = info.GetBuff(session.GetMyHandle(),argNum);
                g.buffs[argNum]=g.buffs[argNum] or {}
                g.buffs[argNum].time=buff.time
                
            end
            for i = 0, s_buff_ui["buff_group_cnt"] do
                local slotlist = s_buff_ui["slotlist"][i];
                local slotcount = s_buff_ui["slotcount"][i];
                local captionlist = s_buff_ui["captionlist"][i];
                for k=0,slotcount-1 do

                    local slot=s_buff_ui.slotlist[i][k]
                    if slot:IsVisible() ~= 0 then
                        local icon = slot:GetIcon();
                        icon:SetOnCoolTimeUpdateScp('BUFFREMAINVISUALIZER_ICON_UPDATE_BUFF_PSEUDOCOOLDOWN');
                        local iconInfo=icon:GetInfo()
                        local buff=GetClassByType("Buff",iconInfo.type)
                        -- icon:ClearText();
                        slot:SetIcon(icon)
                        slot:EnableDrag(0)
                        slot:EnableDrop(0)
                        
                        slot:SetSkinName("bmvaddon_icon_"..buff.Icon:lower())

                       
                        slot:EnableDrag(0)

                        --local n=127
                        --icon:SetColorTone(string.format("FF%02X%02X%02X",n,n,n))
                        icon:Invalidate()
                        slot:Invalidate()
                    else
                        slot:SetSkinName("")
                    end
                end
            end
        
        end,
        catch = function(error)
            ERROUT("FAIL:" .. tostring(error))
        end
    }
end

