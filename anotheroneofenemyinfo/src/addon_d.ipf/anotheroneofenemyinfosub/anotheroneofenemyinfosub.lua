--アドオン名（大文字）
local addonName = "ANOTHERONEOFENEMYINFO"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

g.subframename = "anotheroneofenemyinfosub"
g.subframe = g.subframe or nil
g.subremain = {}
g.subctrls = {}
g.subhplogs = {}
--ライブラリ読み込み
CHAT_SYSTEM("[AOE]sub loaded")

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


--マップ読み込み時処理（1度だけ）
function ANOTHERONEOFENEMYINFOSUB_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.subframe = frame
            
            --addon:RegisterMsg('GAME_START_3SEC', 'CHALLENGEMODESTUFF_SHOW')
            --ccするたびに設定を読み込む
            addon:RegisterMsg('GAME_START_3SEC', 'AOE_SUB_HEADSUPDISPLAY_ON_MSG');
            
            
            if not g.loaded then
                g.loaded = true
            end
            
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            --CHALLENGEMODESTUFF_SHOW(g.frame)
            DBGOUT("INIT")
            g.subctrls = {}
            frame:ShowWindow(0)
        --CHALLENGEMODESTUFF_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

--disabled works
return 
--[[
function AOE_SUB_INIT()
    
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.subframename)
            g.subframe = frame
            frame:RemoveAllChild()
            frame:Resize(800, 800)
            frame:SetLayerLevel(g.settings.layerlevel or 90)
            --frame:EnableHittestFrame(true)
            frame:EnableHitTest(1)
            --下準備
            local pic = frame:CreateOrGetControl("picture", "pic", 0, 0, frame:GetWidth(), frame:GetHeight())
            local touch = frame:CreateOrGetControl("picture", "touchbar", 10, 22, 40, 40)
            
            tolua.cast(pic, "ui::CPicture")
            tolua.cast(touch, "ui::CPicture")
            
            pic:EnableHitTest(0)
            pic:CreateInstTexture()
            pic:FillClonePicture("00000000")
            
            
            touch:EnableHitTest(1)
            touch:SetEnableStretch(1)
            touch:SetEventScript(ui.MOUSEWHEEL, "AOE_SUB_MOUSEWHEEL");
            touch:SetEventScript(ui.LBUTTONDOWN, "AOE_SUB_LBTNDOWN");
            touch:SetEventScript(ui.LBUTTONUP, "AOE_SUB_LBTNUP");
            touch:SetEventScript(ui.RBUTTONUP, "AOE_SUB_RBTNUP");
            -- soulcrystal:ShowWindow(0)
            -- soulcrystal:EnableHitTest(0)
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
            
            end
            
            
            
            AOE_SUB_RENDER()
            if (g.debug) then
                
                g.subframe:SetOffset(g.settings.sub_x, g.settings.sub_y)
                
                AOE_SUB_TIMER_BEGIN()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOE_SUB_HEADSUPDISPLAY_ON_MSG(frame, msg, argStr, argNum)
    
    
    if (msg == "GAME_START_3SEC") then
        
        g.subframe:ShowWindow(1)
        
        AOE_SUB_INIT()
        g.subframe:SetOffset(g.settings.sub_x, g.settings.sub_y)
        
        AOE_SUB_TIMER_BEGIN()
    end
    if (g.run == false) then
        return
    end

end
function AOE_SUB_TIMER_BEGIN()
    local frame = ui.GetFrame(g.subframename)
    frame:CreateOrGetControl("timer", "addontimer", 0, 0, 10, 10)
    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
    timer:SetUpdateScript("AOE_SUB_ON_TIMER");
    timer:Start(0.01);
    frame:CreateOrGetControl("timer", "addontimer2", 0, 0, 10, 10)
    local timer = GET_CHILD(frame, "addontimer2", "ui::CAddOnTimer");
    timer:SetUpdateScript("AOE_SUB_ON_LONGTIMER");
    timer:Start(1);

end

function AOE_SUB_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            
            g.tick = g.tick + 1
            
            if (g.tick >= 100) then
                g.tick = 0
            end
            
            if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                frame:GetChild("touchbar"):ShowWindow(1)
            else
                frame:GetChild("touchbar"):ShowWindow(0)
            end
            AOE_SUB_RENDER()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOE_SUB_RENDER()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.subframename)
            local pic = frame:GetChild("pic")
            if IS_IN_EVENT_MAP() == true then
                return;
            end
            if (pic) then
                AUTO_CAST(pic)
                pic:FillClonePicture("00000000")
                local idx = 0
                local oy = 0;
                local viewhandles = {}
                local objList, objCount = SelectObject(self, 400, 'ENEMY')
                local pos = GetMyActor():GetPos()
                --sort by distance
                table.sort(objList, function(a, b)
                    local hnda = GetHandle(a)
                    local hndb = GetHandle(b)
                    
                    local posa = world.GetActor(hnda):GetPos()
                    local posb = world.GetActor(hndb):GetPos()
                    
                    local dista = math.pow(pos.x - posa.x, 2) + math.pow(pos.z - posa.z, 2)
                    local distb = math.pow(pos.x - posb.x, 2) + math.pow(pos.z - posb.z, 2)
                    return dista < distb
                end)
                for _, v in ipairs(g.subctrls) do
                    --frame:RemoveChild(v:GetName())
                    v:ShowWindow(0)
                end
                g.subctrls = {}
                local limit = 10-#g.subremain
                for i = 1, objCount do
                    local hnd = GetHandle(objList[i])
                    local targetinfo = info.GetTargetInfo(hnd);
                    if (targetinfo.isBoss == 1 and not viewhandles[hnd]) then
                        viewhandles[hnd] = true
                        oy = oy + AOE_SUB_RENDER_ENEMY(frame, pic, idx, oy, hnd, true)
                        idx = idx + 1
                        limit = limit - 1
                    end
                end
                for i = 1, objCount do
                    local hnd = GetHandle(objList[i])
                    local targetinfo = info.GetTargetInfo(hnd);
                    if (targetinfo.isBoss ~= 1 and not viewhandles[hnd] and limit > 0) then
                        viewhandles[hnd] = true
                        oy = oy + AOE_SUB_RENDER_ENEMY(frame, pic, idx, oy, hnd, true)
                        idx = idx + 1
                        limit = limit - 1
                    end
                end
                
                
                
                for k, v in pairs(g.subremain) do
                    local handle = tonumber(k)
                    if (not viewhandles[handle]) then
                        
                        viewhandles[handle] = true
                        local r = AOE_SUB_RENDER_ENEMY(frame, pic, idx, oy, handle, false)
                        oy = oy + r
                        if (r > 0) then
                            idx = idx + 1
                        end
                    end
                end
                
                pic:Invalidate()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOE_SUB_RENDER_ENEMY(frame, pic, idx, oy, handle, nonelapse)
    return EBI_try_catch{
        try = function()
            local targetinfo = info.GetTargetInfo(handle);
            local oye = 0
            local id = tostring(handle)
            local ninfo = targetinfo
            local stat
            local maxtime = 30
            if nil == ninfo then
                if (g.subremain[tostring(handle)]) then
                    g.subremain[tostring(handle)].time = g.subremain[tostring(handle)].time - 1
                    if (g.subremain[tostring(handle)].time <= 0) then
                        g.subremain[tostring(handle)] = nil
                        
                        return 0
                    end
                    ninfo = g.subremain[tostring(handle)]
                else
                    return 0
                end
            
            else
                if (ninfo.TargetWindow == 0) then
                    return 0
                end
                
                ninfo = g.subremain[tostring(handle)] or {
                    isEliteBuff = ninfo.isEliteBuff,
                    isBoss = ninfo.isBoss,
                    time = maxtime,
                    name = ninfo.name,
                    level = ninfo.level,
                    TargetWindow = ninfo.TargetWindow,
                    isInvincible = ninfo.isInvincible,
                    attribute = ninfo.attribute
                }
                local s = targetinfo.stat
                stat = {
                    HP = math.min(s.maxHP, s.HP),
                    maxHP = s.maxHP,
                
                }
                ninfo.stat = stat
                
                if (not nonelapse) then
                    ninfo.time = ninfo.time - 1
                    if (ninfo.time <= 0) then
                        g.subremain[tostring(handle)] = nil
                        
                        return 0
                    end
                else
                    ninfo.time = maxtime
                end
                
                g.subremain[tostring(handle)] = ninfo
            
            end
            local actor = world.GetActor(handle)
            local attribute = ninfo.attribute
            
            local iconname = "nil"
            if (actor) then
                local monCls = GetClassByType("Monster", actor.type);
                iconname = TryGetProp(monCls, "Icon");
            else
                end
            
            if attribute == nil then
                attribute = "None"
            end
            local attributeImgName = "attribute_" .. attribute
            local sz = ""
            local lvsz = ""
            local len = 200
            local ox = 50
            local off = 35 + oy
            local oox = 0
            sz = "{s20}"
            lvsz = "{s16}"
            -- if (ninfo.isBoss == 1) then
            --     len = 400
            --     oox = 0
            -- elseif (ninfo.isEliteBuff == 1) then
            --     oox = 100
            --     len = 300
            -- else
            oox = 200
            len = 200
            --end
            local stat = ninfo.stat
            local speed = 0.3
            
            --hp gauge
            if (not g.subhplogs[handle]) then
                g.subhplogs[handle] = {
                    wid = stat.HP * len / stat.maxHP,
                    rem = stat.HP * len / stat.maxHP,
                    max = len
                }
            end
            local hp = g.subhplogs[handle]
            local w, r = AOE_CALC_POINT_ANIMATED(hp.wid, hp.rem, stat.HP, stat.maxHP, hp.max, hp.max, stat.maxHP, speed)
            hp.rem = r
            hp.wid = w;
            g.subhplogs[handle] = hp
            
            
            --render
            pic:DrawBrush(ox, off, ox + len, off, "aoe_spray_large_bs", "77000000")
            pic:DrawBrush(ox, off, ox + len, off, "aoe_spray_large_bs", "77000000")
            if (hp.rem ~= hp.wid) then
                if (hp.rem < hp.wid) then
                    pic:DrawBrush(ox, off, ox + hp.rem, off, "aoe_spray_large_bs", "FF22FFFF")
                else
                    pic:DrawBrush(ox, off, ox + hp.rem, off, "aoe_spray_large_bs", "FFFF7700")
                end
            end
            
            local strHPValue = TARGETINFO_TRANS_HP_VALUE(handle, stat.HP);
            
            local uppercolor = string.format("%02XFF0000", ninfo.time * 0xFF / maxtime)
            local undercolor = string.format("%02XAA0000", ninfo.time * 0xFF / maxtime)
            if (ninfo.isInvincible == 1) then
                uppercolor = string.format("%02XFFFFFF", ninfo.time * 0xFF / maxtime)
                undercolor = string.format("%02XAAAAAA", ninfo.time * 0xFF / maxtime)
            end
            
            if attributeImgName == "None" or attribute == "None" then
                local c = AOE_SUB_GENERATE_ATTRIBUTE(frame, "attr" .. id, attributeImgName, ox + 50, oy, 20, 20)
                c:ShowWindow(0)
            
            else
                local c = AOE_SUB_GENERATE_ATTRIBUTE(frame, "attr" .. id, attributeImgName, ox + 50, oy, 20, 20)
                c:ShowWindow(1)
                c:SetColorTone(string.format("%02XFFFFFF", ninfo.time * 0xFF / maxtime))
            end
            
            pic:DrawBrush(ox, off, ox + hp.wid, off, "aoe_spray_large_bs", uppercolor)
            pic:DrawBrush(ox + 2, off + 2, ox + 2 + hp.wid, off + 2, "aoe_spray_small_bs", undercolor)
            local name = dic.getTranslatedStr(ninfo.name);
            local font = string.format("{#%02X%02X%02X}", ninfo.time * 0xFF / maxtime, ninfo.time * 0xFF / maxtime, ninfo.time * 0xFF / maxtime)
            AOE_SUB_GENERATE_TEXT(frame, "lv" .. id, "{@st43}" .. font .. lvsz .. "Lv " .. tostring(ninfo.level), ox, oy, 400, 30)
            AOE_SUB_GENERATE_TEXT(frame, "name" .. id, "{img " .. tostring(iconname) .. "20 20}" .. "{@st43}" .. font .. sz .. name:gsub("{nl}", ""), ox + 70, oy, 800, 30)
            AOE_SUB_GENERATE_TEXT(frame, "hp" .. id, "{@st43}{s20}" .. font .. tostring(strHPValue), ox + 10, off - 20, 200, 30)
            if info.IsPercentageHP(handle) == true then
                else
                AOE_SUB_GENERATE_TEXT(frame, "hpp" .. id, "{@st43}{s14}" .. font .. tostring(math.ceil(stat.HP * 100 / stat.maxHP)) .. "%", ox + 110, off + 5 - 10, 200, 30)
            end
            --バフ欄設置
            local cslot = frame:CreateOrGetControl("slotset", "buff" .. id, ox + len, oy, 200, 20)
            
            AOE_SUB_GENERATE_PASSIVE(frame, cslot)
            AUTO_CAST(cslot)
            cslot:EnableHitTest(1)
            
            
            local t_buff_ui = {};
            t_buff_ui["buff_group_cnt"] = 2;
            t_buff_ui["slotsets"] = {};
            t_buff_ui["slotlist"] = {};
            t_buff_ui["captionlist"] = {};
            t_buff_ui["slotcount"] = {};
            t_buff_ui["txt_x_offset"] = 1;
            t_buff_ui["txt_y_offset"] = 1;
            
            if (cslot:GetCol() ~= 20) then
                cslot:SetColRow(20, 1)
                cslot:SetSlotSize(20, 20)
                cslot:EnableDrag(0)
                cslot:EnableDrop(0)
                cslot:EnablePop(0)
                cslot:SetSpc(0, 0)
                cslot:CreateSlots()
                cslot:Invalidate()
            end
            for i = 0, cslot:GetSlotCount() - 1 do
                local slot = cslot:GetSlotByIndex(i)
                t_buff_ui["slotlist"][i] = slot
                CreateIcon(slot)
                CLEAR_BUFF_SLOT(slot, t_buff_ui["captionlist"][i]);
                t_buff_ui["captionlist"][i] = AOE_SUB_GENERATE_TEXT(frame, "cap" .. id .. "_" .. tostring(i), "", cslot:GetX() + slot:GetX(), cslot:GetY() + slot:GetY() + 20, 20, 10)
                slot:ShowWindow(0)
                slot:Invalidate()
            end
            local slotlist = t_buff_ui["slotlist"]
            local captionlist = t_buff_ui["captionlist"]
            
            local buffCount = info.GetBuffCount(handle);
            local buffidx = 0
            
            for i = 0, buffCount - 1 do
                
                local buff = info.GetBuffIndexed(handle, i);
                local buffType = buff.buffID
                local class = GetClassByType('Buff', buffType);
                if class.ShowIcon ~= "FALSE" then
                    
                    if TryGetProp(class, 'OnlyOneBuff', 'None') == 'YES' and TryGetProp(class, 'Duplicate', 1) == 0 then
                        local skip = false
                        local exist_slot, k = get_exist_debuff_in_slotlist(t_buff_ui["slotlist"], buffType)
                        if exist_slot ~= nil then
                            SET_BUFF_SLOT(exist_slot, captionlist[k], class, buffType, handle, slotlist, k);
                            exist_slot:ShowWindow(1)
                            skip = true
                        end
                        if skip == false and buffidx < #slotlist then
                            for j = 0, cslot:GetSlotCount() - 1 do
                                
                                local slot = slotlist[j];
                                local text = captionlist[j]
                                
                                if slot:IsVisible() == 0 or slot:GetIcon():GetInfo() == nil or slot:GetIcon():GetInfo().type == 0 then
                                    AOE_SET_BUFF_SLOT(slot, text, class, buffType, handle, slotlist, j);
                                    
                                    slot:ShowWindow(1)
                                    break;
                                end
                            end
                        
                        
                        end
                    end
                
                end
            
            end
            local hasbuff = 0
            if (buffCount > 0) then
                hasbuff = 1
            end
            if (idx == 0) then
                return 40
            else
                return 40
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOE_SET_BUFF_SLOT(slot, capt, class, buffType, handle, slotlist, buffIndex)
    local icon = slot:GetIcon();
    local imageName = GET_BUFF_ICON_NAME(class);
    
    icon:Set(imageName, 'BUFF', buffType, 0);
    if buffIndex ~= nil then
        icon:SetUserValue("BuffIndex", buffIndex);
    end
    
    if tonumber(handle) == nil then
        return;
    end
    
    local buff = info.GetBuff(tonumber(handle), buffType);
    if nil == buff then
        return;
    end
    
    local frame = ui.GetFrame("buff")
    local bufflockoffset = tonumber(frame:GetUserConfig("DEFAULT_BUFF_LOCK_OFFSET"));
    local buffGroup1 = TryGetProp(class, "Group1", "Buff");
    if buffGroup1 == "Debuff" then
        local bufflv = TryGetProp(class, "Lv", "99");
        if bufflv == 4 then
            slot:SetBgImage("buff_lock_icon_3");
        elseif bufflv > 4 then
            slot:SetBgImage("buff_lock_icon_4");
        end
        
        if bufflv <= 3 then
            slot:SetBgImageSize(0, 0);
        else
            slot:SetBgImageSize(slot:GetWidth() + bufflockoffset, slot:GetHeight() + bufflockoffset);
        end
    end
    
    if buff.over > 1 then
        slot:SetText('{s13}{ol}{b}' .. buff.over, 'count', ui.RIGHT, ui.BOTTOM, -5, -3);
    else
        slot:SetText("");
    end
    
    slot:EnableDrop(0);
    slot:EnableDrag(0);
    
    if capt ~= nil then
        capt:ShowWindow(1);
        capt:SetText(GET_BUFF_TIME_TXT(buff.time, 0));
    end
    
    local targetinfo = info.GetTargetInfo(handle);
    if targetinfo ~= nil then
        if targetinfo.TargetWindow == 0 then
            slot:ShowWindow(0);
        else
            slot:ShowWindow(1);
        end
    else
        slot:ShowWindow(1);
    end
    
    if class.ClassName == "Premium_Nexon" or class.ClassName == "Premium_Token" then
        icon:SetTooltipType('premium');
        icon:SetTooltipArg(handle, buffType, buff.arg1);
    else
        icon:SetTooltipType('buff');
        if buffIndex ~= nil then
            icon:SetTooltipArg(handle, buffType, buffIndex);
        end
    end
    
    slot:Invalidate();
end


function AOE_SUB_GENERATE_TEXT(frame, name, text, x, y, w, h)
    local c = frame:CreateOrGetControl("richtext", name, x, y, w, h)
    AUTO_CAST(c)
    c:ShowWindow(1)
    c:SetText(text)
    c:EnableHitTest(0)
    g.subctrls[#g.subctrls + 1] = c
    return c
end
function AOE_SUB_GENERATE_ATTRIBUTE(frame, name, image, x, y, w, h)
    local c = frame:CreateOrGetControl("picture", name, x, y, w, h)
    AUTO_CAST(c)
    c:ShowWindow(1)
    c:SetImage(image)
    c:SetEnableStretch(1)
    c:EnableHitTest(0)
    g.subctrls[#g.subctrls + 1] = c
    return c
end
function AOE_SUB_GENERATE_PASSIVE(frame, ctrl)
    local c = ctrl
    AUTO_CAST(c)
    c:ShowWindow(1)
    c:EnableHitTest(0)
    g.subctrls[#g.subctrls + 1] = c
    return c
end
function AOE_SUB_LBTNDOWN(parent, ctrl)
    if (not g.settings.lock) then
        
        local frame = parent:GetTopParentFrame();
        
        local x, y = GET_MOUSE_POS();
        
        g.sub_x = x -- 드래그할 때, 클릭한 좌표를 기억한다.
        g.sub_y = y
        
        ui.EnableToolTip(0);
        ctrl:RunUpdateScript("AOE_SUB_PROCESS_MOUSE");
    end
end

function AOE_SUB_LBTNUP(parent, ctrl)
    
    -- 워프 위치에서 마우스를 떼지 않았다면 클릭한 좌표를 리셋한다.
    g.sub_x = nil
    g.sub_y = nil
    AOE_SAVE_SETTINGS()
end
function AOE_SUB_RBTNUP(parent, ctrl)
    if (keyboard.IsKeyPressed("LSHIFT") == 1) then
        local context = ui.CreateContextMenu("AOE", "", 0, 0, 170, 100);
        ui.AddContextMenuItem(context, "LOCK/UNLOCK Position", "AOE_LOCKUNLOCK(1)");
        ui.OpenContextMenu(context);
    end

end

function AOE_SUB_PROCESS_MOUSE(ctrl)
    return EBI_try_catch{
        try = function()
            
            local frame = ctrl:GetTopParentFrame();
            if mouse.IsLBtnPressed() == 0 then
                
                ui.EnableToolTip(1);
                AOE_SAVE_SETTINGS()
                return 0;
            end
            local mx, my = GET_MOUSE_POS();
            local x = g.sub_x;
            local y = g.sub_y;
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
            g.sub_x = mx
            g.sub_y = my
            
            
            cx = math.max(-frame:GetWidth() / 2, math.min(cx, curWidth - 30))
            cy = math.max(-frame:GetHeight() / 2, math.min(cy, curHeight - 30))
            g.settings.sub_x = cx;
            g.settings.sub_y = cy;
            AOE_SAVE_SETTINGS()
            frame:SetOffset(cx, cy)
            
            return 1;
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOE_SUB_ON_LONGTIMER(frame)
    EBI_try_catch{
        try = function()
        
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
]]
