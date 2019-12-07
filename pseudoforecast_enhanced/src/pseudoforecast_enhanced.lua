--OLD_SHOP_ITEM_LIST_GET
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

local acutil = require('acutil')

PSEUDOFORECAST_ENABLE = false
PSEUDOFORECAST_CASTING_SKILLID = nil
PSEUDOFORECAST_YOFFSET = 10
PSEUDOFORECAST_DATA = {
        
        example = {
            {timestart = 0, timeend = 0, angle = 0, width = 0, length = 0, typ = "FAN"},
            {timestart = 0, timeend = 0, angle = 0, width = 0, length = 0, typ = "CIRCLE"}
        }

}
PSEUDOFORECAST_PADDATA = {
        
        example = {
            {timestart = 0, timeend = 0, angle = 0, width = 0, length = 0, typ = "FAN"},
            {timestart = 0, timeend = 0, angle = 0, width = 0, length = 0, typ = "CIRCLE"}
        }

}
if (PSEUDOFORECASTPADSKILL_rawdata ~= nil and PSEUDOFORECAST_rawdata ~= nil) then
    PSEUDOFORECAST_LOADSKILLS()
    
    PSEUDOFORECAST_ENABLE = true
end
PSEUDOFORECAST_ORIGIN = {x = 0, y = 0, z = 0}
PSEUDOFORECAST_ANGLE = 0
PSEUDOFORECAST_TRACKING = {}
PSEUDOFORECAST_TRACK_PAD = {}
-- ライブラリ読み込み
function PSEUDOFORECAST_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            if (OLD_ICON_USE == nil or ICON_USE ~= PSEUDOFORECAST_ICON_USE_JUMPER) then
                OLD_ICON_USE = ICON_USE;
                ICON_USE = PSEUDOFORECAST_ICON_USE_JUMPER
            
            end
            addon:RegisterMsg('DYNAMIC_CAST_BEGIN', 'PSEUDOFORECAST_DYNAMIC_CASTINGBAR_ON_MSG');
            addon:RegisterMsg('DYNAMIC_CAST_END', 'PSEUDOFORECAST_DYNAMIC_CASTINGBAR_ON_MSG');
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("PSEUDOFORECAST_ON_TIMER");
            timer:Start(0.01);
            PSEUDOFORECAST_LOADSKILLS()
            acutil.slashCommand("/pf", PSEUDOFORECAST_PROCESS_COMMAND);
            frame:ShowWindow(1)
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end

function PSEUDOFORECAST_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            -- if (not PSEUDOFORECAST_ENABLE) then
            --     return
            -- end
            local pc = GetMyPCObject();
            local myActor = GetMyActor();
            if pc ~= nil then
                local enemyList, enemyCount = SelectObject(pc, 300, 'ENEMY');
                
                if enemyCount > 0 then
                    for i = 1, enemyCount do
                    
                        local enemy = world.GetActor(GetHandle(enemyList[i]));
                        
                        local track = PSEUDOFORECAST_TRACKING[enemy:GetHandleVal()]
                        if (track == nil) then
                            track = {}
                        end
                        local curskill = enemy:GetUseSkill()
                        if (curskill == nil or curskill == 0) then
                            
                            PSEUDOFORECAST_TRACKING[enemy:GetHandleVal()] = nil
                        else
                            if (track.skill == nil) then
                                CHAT_SYSTEM("ENEMYSKILL"..curskill)
                                PSEUDOFORECAST_ENEMYSKILL(enemy, curskill)
                            
                            end
                            track.skill = curskill
                            PSEUDOFORECAST_TRACKING[enemy:GetHandleVal()] = track
                        end
                        
                    end
                end
                for handleval, data in pairs(PSEUDOFORECAST_TRACK_PAD) do
                    local actor = data.actor
                   
                    local padList = SelectPad_C(actor, data.skill, actor:GetPos().x, actor:GetPos().y, actor:GetPos().z, 400, 'ALL');
                    if (#padList > 0) then
                        CHAT_SYSTEM("PAD")
                        for i = 1, #padList do
                            
                            local pad = tolua.cast(padList[i], "CClientPadSkill");
                            local guid = pad:GetGuid();
                            
                            if (data.pads[guid] == nil) then
                                data.pads[guid] = pad
                                PSEUDOFORECAST_PADSKILL(actor,pad, data.skill)
                               
                            end
                        end
                    end
                    data.waittime = data.waittime - 1
                    if (data.waittime <= 0) then
                        CHAT_SYSTEM("EOF")
                        PSEUDOFORECAST_TRACK_PAD[handleval] = nil
                    else
                        PSEUDOFORECAST_TRACK_PAD[handleval] = data
                    end
                end
            -- CHAT_SYSTEM("TESAT")
            -- for skillname,data in pairs(PSEUDOFORECAST_PADDATA) do
            --     local padList = SelectPad_C(myActor, skillname,myActor:GetPos().x,myActor:GetPos().y,myActor:GetPos().z, 400,'ALL');
            --     if #padList > 0 then
            --         print("PAD")
            --         for i = 1, #padList do
            --             local pad = tolua.cast(padList[1], "CClientPadSkill");
            --             local guid=pad:GetGuid();
            --             local track = PSEUDOFORECAST_TRACKING[pad:GetGuid()]
            --             if (track == nil) then
            --                 track = {}
            --             end
            --             if (skillname == nil ) then
            --                 PSEUDOFORECAST_TRACKING[guid] = nil
            --             else
            --                 if (track.skill == nil) then
            --                     PSEUDOFORECAST_PADSKILL(pad, skillname)
            --                 end
            --                 track.skill = skillname
            --                 PSEUDOFORECAST_TRACKING[guid] = track
            --             end
            --         end
            --     end
            -- end
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function PSEUDOFORECAST_DYNAMIC_CASTINGBAR_ON_MSG(frame, msg, argStr, maxTime, isVisivle)
    if (not PSEUDOFORECAST_ENABLE) then
        return
    end
    if msg == 'DYNAMIC_CAST_BEGIN' then
        local sList = StringSplit(argStr, "#");
        local sklName = argStr;
        if 1 < #sList then
            sklName = sList[1];
        end
        local sklObj = GetSkill(GetMyPCObject(), sklName);
        if nil ~= sklObj then
            PSEUDOFORECAST_CASTING_SKILLID = sklObj.ClassID
        end
    elseif msg == 'DYNAMIC_CAST_END' and PSEUDOFORECAST_CASTING_SKILLID then
        PSEUDOFORECAST_SKILL(PSEUDOFORECAST_CASTING_SKILLID)
        PSEUDOFORECAST_CASTING_SKILLID = nil
    end
end
function PSEUDOFORECAST_LOADSKILLS()
    EBI_try_catch{
        try = function()
            PSEUDOFORECAST_DATA = {}
            local succ, _ = pcall(dofile, "../addons/pseudoforecast/skills.lua")
            if (not succ) then
                --succ,_=pcall(dofile,"skills.lua")
                if (not PSEUDOFORECAST_rawdata) then
                    CHAT_SYSTEM("FORECASTDATA LOADING FAILURE")
                    return
                
                end
                data = PSEUDOFORECAST_rawdata
            end
            local t = data
            
            PSEUDOFORECAST_DATA = t
            local succ, _ = pcall(dofile, "../addons/pseudoforecast/padskills.lua")
            if (not succ) then
                --succ,_=pcall(dofile,"skills.lua")
                if (not PSEUDOFORECASTPADSKILL_rawdata) then
                    CHAT_SYSTEM("FORECASTPADDATA LOADING FAILURE")
                    return
                
                end
                data = PSEUDOFORECASTPADSKILL_rawdata
            end
            t = data
            PSEUDOFORECAST_PADDATA = t
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        
        end
    }

end
function PSEUDOFORECAST_ICON_USE_JUMPER(object, reAction)
    
    EBI_try_catch{
        try = function()
            PSEUDOFORECAST_ICON_USE(object, reAction)
        
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        
        end
    }
    --finally
    OLD_ICON_USE(object, reAction)
end
function PSEUDOFORECAST_ICON_USE(object, reAction)
    if (not PSEUDOFORECAST_ENABLE) then
        return
    end
    local iconPt = object;
    if iconPt ~= nil then
        local icon = tolua.cast(iconPt, 'ui::CIcon');
        
        local iconInfo = icon:GetInfo();
        if iconInfo:GetCategory() == 'Skill' then
            local class = GetClassByType("Skill", iconInfo.type)
            local myActor = GetMyActor();
            local skillobj = session.GetSkill(iconInfo.type)
            --CHAT_SYSTEM(string.format("%s,%s,%d,%d",tostring(myActor:IsSkillState()),class.ClassName,skillobj:GetRemainRefreshTimeMS(),skillobj:GetCurrentCoolDownTime()))
            if (myActor:IsSkillState() == false and
                skillobj:GetRemainRefreshTimeMS() <= 0 and
                skillobj:GetCurrentCoolDownTime() <= 0) then
                
                --それは使える？
                if (control.IsSkillIconUsable(iconInfo.type) == 1) then
                    ReserveScript(string.format("PSEUDOFORECAST_JUDGSKILL(%d)", iconInfo.type), 0.01)
                end
            
            end
        end
    end

end
function PSEUDOFORECAST_JUDGSKILL(skillclsid)
    --CHAT_SYSTEM(tostring(PSEUDOFORECAST_CASTING_SKILLID)..","..tostring(skillclsid))
    if (not PSEUDOFORECAST_CASTING_SKILLID) then
        PSEUDOFORECAST_SKILL(skillclsid)
    end
end
function PSEUDOFORECAST_SKILL(skillclsid)
    EBI_try_catch{
        try = function()
            
            --xml(lua)から読み込む
            local duration = 1
            --iesから読み込む
            local class = GetClassByType("Skill", skillclsid)
            --SCR_GET_SKL_CAST(class)
            local className = string.gsub(class.ClassName, "-", "_")
            local xmlskls = PSEUDOFORECAST_DATA[className]
            local actor = GetMyActor()
            local pos = actor:GetPos()
            local angle = fsmactor.GetAngle(actor)
            PSEUDOFORECAST_ORIGIN = {x = pos.x, y = pos.y, z = pos.z}
            PSEUDOFORECAST_ANGLE = angle
            CHAT_SYSTEM(className)
            if (xmlskls) then
                if (class.Target ~= "Actor") then
                    for i = 1, #xmlskls do
                        local xmlskl = xmlskls[i]
                        CHAT_SYSTEM("IN"..tostring(xmlskl.timestart))
                        ReserveScript(string.format('PSEUDOFORECAST_DELAYED_SKILLACTION("%s",%d)',
                            class.ClassName, i), math.max(0.01,xmlskl.timestart / 500.0))
                    end
                end
            end
        end,
        
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function PSEUDOFORECAST_PADSKILL(actor,pad, className)
    EBI_try_catch{
        try = function()
            
            --xml(lua)から読み込む
            local duration = 1
            --iesから読み込む
            CHAT_SYSTEM("PAD CREATE")
            --SCR_GET_SKL_CAST(class)
            
            local xmlskls = PSEUDOFORECAST_PADDATA[className]
            local pos = pad:GetPos()
            local angle = fsmactor.GetAngle(actor)
            PSEUDOFORECAST_ORIGIN = {x = pos.x, y = pos.y, z = pos.z}
            PSEUDOFORECAST_ANGLE = angle
            
            if (xmlskls) then
                
                --if (class.Target ~= "Actor") then
                for i = 1, #xmlskls do
                    local xmlskl = xmlskls[i]
                    CHAT_SYSTEM("IN"..tostring(xmlskl.timestart))
                    PSEUDOFORECAST_PADSKILLACTION(actor,pad, className, i)
                end
            
            
            --end
            end
        
        end,
        
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function PSEUDOFORECAST_TRACK_PADSKILL(actor, skillname)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM("TRACK PAD"..skillname)
            PSEUDOFORECAST_TRACK_PAD[actor:GetHandleVal()] = {
                skill = skillname,
                actor = actor,
                pads = {},
                waittime = 1000
            }
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function PSEUDOFORECAST_ENEMYSKILL(actor, skillclsid)
    EBI_try_catch{
        try = function()
            
            --xml(lua)から読み込む
            local duration = 1
            --iesから読み込む
            local class = GetClassByType("Skill", skillclsid)
            if (class == nil) then
                
                return
            end
            --SCR_GET_SKL_CAST(class)
            local className = string.gsub(class.ClassName, "-", "_")
            
            local xmlskls = PSEUDOFORECAST_DATA[className]
            local pos = actor:GetPos()
            local angle = fsmactor.GetAngle(actor)
            PSEUDOFORECAST_ORIGIN = {x = pos.x, y = pos.y, z = pos.z}
            PSEUDOFORECAST_ANGLE = angle
            
            if (xmlskls) then
                
                --if (class.Target ~= "Actor") then
                for i = 1, #xmlskls do
                    local xmlskl = xmlskls[i]
                    --CHAT_SYSTEM("IN"..tostring(xmlskl.timestart))
                    PSEUDOFORECAST_SKILLACTION(actor, class.ClassName, i)
                end
            
            
            --end
            end
        
        end,
        
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function PSEUDOFORECAST_PADSKILLACTION(actor,pad, classname, index)
    local xmlskl = PSEUDOFORECAST_PADDATA[classname][index]
    local duration =0.5
    --local duration = math.max(0.5, (xmlskl.timeend - xmlskl.timestart) / 1000.0)
    local push = xmlskl.length
    CHAT_SYSTEM("SHOW PAD "..classname.."/"..tostring(index))
    if (tonumber(xmlskl.postype) == 1) then
        push = 0
    end
    
    if (xmlskl.typ == "Square") then
        PSEUDOFORECAST_DRAWSQUARE_FROMACTOR(pad, PSEUDOFORECAST_ORIGIN, PSEUDOFORECAST_ANGLE, xmlskl.width,
            xmlskl.length, 0, xmlskl.rotate * 180.0 / math.pi, duration)
    elseif (xmlskl.typ == "Circle") then
        PSEUDOFORECAST_DRAWPOS_FROMACTOR(pad, PSEUDOFORECAST_ORIGIN, PSEUDOFORECAST_ANGLE, xmlskl.width, push, xmlskl.rotate, duration)
    elseif (xmlskl.typ == "Fan") then
        PSEUDOFORECAST_DRAWFAN_FROMACTOR(pad, PSEUDOFORECAST_ORIGIN, PSEUDOFORECAST_ANGLE, xmlskl.length,
            xmlskl.angle * 180.0 / math.pi * 4, 0, (xmlskl.rotate) * 180.0 / math.pi, duration)
    end

end
function PSEUDOFORECAST_SKILLACTION(actor, classname, index)
    local xmlskl = PSEUDOFORECAST_DATA[classname][index]
    local duration = math.max(0.5, (xmlskl.timeend - xmlskl.timestart) / 1000.0)
    local push = xmlskl.length
    CHAT_SYSTEM("SHOW "..classname.."/"..tostring(index))
  

    
    if (tonumber(xmlskl.postype) == 1) then
        push = 0
    end
    
    if (xmlskl.typ == "Square") then
        
        PSEUDOFORECAST_DRAWSQUARE_FROMACTOR(actor, PSEUDOFORECAST_ORIGIN, PSEUDOFORECAST_ANGLE, xmlskl.width,
            xmlskl.length, 0, xmlskl.rotate * 180.0 / math.pi, duration)
    elseif (xmlskl.typ == "Circle") then
        PSEUDOFORECAST_DRAWPOS_FROMACTOR(actor, PSEUDOFORECAST_ORIGIN, PSEUDOFORECAST_ANGLE, xmlskl.width, push, xmlskl.rotate, duration)
    elseif (xmlskl.typ == "Fan") then
        PSEUDOFORECAST_DRAWFAN_FROMACTOR(actor, PSEUDOFORECAST_ORIGIN, PSEUDOFORECAST_ANGLE, xmlskl.length,
            xmlskl.angle * 180.0 / math.pi * 4, 0, (xmlskl.rotate) * 180.0 / math.pi, duration)
    end
    
    dataaa=xmlskl
    if (xmlskl.scptype == "MONSKL_CRE_PAD" or xmlskl.scptype == "MSL_PAD_THROW") then
        PSEUDOFORECAST_TRACK_PADSKILL(actor, xmlskl.pad)
    end
end
function PSEUDOFORECAST_DELAYED_SKILLACTION(classname, index)
    PSEUDOFORECAST_SKILLACTION(GetMyActor(), classname, index)

end
function PSEUDOFORECAST_DRAWFAN_IMPL(x, y, z, ampx, ampy, length, arcangle)
    debug.DrawFan(x, y, z, ampx, ampy, arcangle, length)
end
function PSEUDOFORECAST_DRAWFAN(x, y, z, ampx, ampy, length, arcangle, duration, continued)
    local normaldur = 0.70
    if (duration >= normaldur or (not continued)) then
        PSEUDOFORECAST_DRAWFAN_IMPL(x, y, z, ampx, ampy, length, arcangle / 2.0)
        if (duration) then
            ReserveScript(string.format("PSEUDOFORECAST_DRAWFAN(%f,%f,%f,%f,%f,%f,%f,%f,%s)", x, y, z, ampx, ampy, length, arcangle, duration - normaldur, tostring(true)), normaldur)
        end
    end
end
function PSEUDOFORECAST_DRAWFAN_FROMMYACTOR(origin, oangle, length, arcangle, push, rotate, duration)
    
    local actor = GetMyActor()
    local pos = origin
    --local angle = fsmactor.GetAngle(actor)+rotate
    local angle = oangle + rotate
    PSEUDOFORECAST_DRAWFAN(
        pos.x + push * math.cos(angle / 180.0 * math.pi),
        pos.y + PSEUDOFORECAST_YOFFSET,
        pos.z + push * math.sin(angle / 180.0 * math.pi),
        math.cos(angle / 180.0 * math.pi),
        math.sin(angle / 180.0 * math.pi),
        length,
        arcangle / 2.0, duration)
end
function PSEUDOFORECAST_DRAWFAN_FROMACTOR(actor, origin, oangle, length, arcangle, push, rotate, duration)
    
    local pos = origin
    --local angle = fsmactor.GetAngle(actor)+rotate
    local angle = oangle + rotate
    PSEUDOFORECAST_DRAWFAN(
        pos.x + push * math.cos(angle / 180.0 * math.pi),
        pos.y + PSEUDOFORECAST_YOFFSET,
        pos.z + push * math.sin(angle / 180.0 * math.pi),
        math.cos(angle / 180.0 * math.pi),
        math.sin(angle / 180.0 * math.pi),
        length,
        arcangle / 2.0, duration)
end
function PSEUDOFORECAST_DRAWPOS_IMPL(x, y, z, radius)
    debug.DrawPos(x, y, z, radius)
end
function PSEUDOFORECAST_DRAWPOS(x, y, z, radius, duration, continued)
    local normaldur = 0.01
    if (duration >= normaldur or (not continued)) then
        
        PSEUDOFORECAST_DRAWPOS_IMPL(x, y, z, radius)
        if (duration) then
            ReserveScript(string.format("PSEUDOFORECAST_DRAWPOS(%f,%f,%f,%f,%f,%s)", x, y, z, radius, duration - normaldur, tostring(true)), normaldur)
        end
    end
end
function PSEUDOFORECAST_DRAWPOS_FROMMYACTOR(origin, oangle, radius, push, rotate, duration)
    
    local actor = GetMyActor()
    local pos = origin
    --local angle = fsmactor.GetAngle(actor)
    local angle = oangle + rotate
    PSEUDOFORECAST_DRAWPOS(pos.x + push * math.cos(angle / 180 * math.pi), pos.y + PSEUDOFORECAST_YOFFSET,
        pos.z + push * math.sin(angle / 180 * math.pi), radius, duration)
end
function PSEUDOFORECAST_DRAWPOS_FROMACTOR(actor, origin, oangle, radius, push, rotate, duration)
    
    local pos = origin
    --local angle = fsmactor.GetAngle(actor)
    local angle = oangle + rotate
    PSEUDOFORECAST_DRAWPOS(pos.x + push * math.cos(angle / 180 * math.pi), pos.y + PSEUDOFORECAST_YOFFSET,
        pos.z + push * math.sin(angle / 180 * math.pi), radius, duration)
end
function PSEUDOFORECAST_DRAWSQUARE_IMPL(x, y, z, xx, yy, zz, width, duration)
    debug.DrawSquare(x, y, z, xx, yy, zz, width, duration)
end

function PSEUDOFORECAST_DRAWSQUARE(x, y, z, xx, yy, zz, width, duration, continued)
    local normaldur = duration
    if (duration >= normaldur or (not continued)) then
        PSEUDOFORECAST_DRAWSQUARE_IMPL(x, y, z, xx, yy, zz, width, duration)
    end
end
function PSEUDOFORECAST_DRAWSQUARE_FROMACTOR(actor, origin, oangle, width, length, push, rotate, duration)
    
    local pos = origin
    --local angle = fsmactor.GetAngle(actor) * math.pi / 180.0
    local angle = (oangle) * math.pi / 180.0
    local dp = {
        x = math.cos((oangle + rotate) / 180.0 * math.pi) * (length + push) + pos.x,
        y = pos.y,
        z = math.sin((oangle + rotate) / 180.0 * math.pi) * (length + push) + pos.z
    }
    PSEUDOFORECAST_DRAWSQUARE(
        pos.x + push * math.cos((oangle + rotate) / 180.0 * math.pi),
        pos.y + PSEUDOFORECAST_YOFFSET,
        pos.z + push * math.sin((oangle + rotate) / 180.0 * math.pi),
        dp.x, dp.y + PSEUDOFORECAST_YOFFSET, dp.z, width, duration)

end
function PSEUDOFORECAST_DRAWSQUARE_FROMMYACTOR(origin, oangle, width, length, push, rotate, duration)
    
    local actor = GetMyActor()
    local pos = origin
    --local angle = fsmactor.GetAngle(actor) * math.pi / 180.0
    local angle = (oangle) * math.pi / 180.0
    local dp = {
        x = math.cos((oangle + rotate) / 180.0 * math.pi) * (length + push) + pos.x,
        y = pos.y,
        z = math.sin((oangle + rotate) / 180.0 * math.pi) * (length + push) + pos.z
    }
    PSEUDOFORECAST_DRAWSQUARE(
        pos.x + push * math.cos((oangle + rotate) / 180.0 * math.pi),
        pos.y + PSEUDOFORECAST_YOFFSET,
        pos.z + push * math.sin((oangle + rotate) / 180.0 * math.pi),
        dp.x, dp.y + PSEUDOFORECAST_YOFFSET, dp.z, width, duration)

end
function PSEUDOFORECAST_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = "usage{nl}/pf on 有効化{nl}/pf off 無効化"
        return ui.MsgBox(msg, "", "Nope")
    end
    
    if cmd == "on" then
        PSEUDOFORECAST_ENABLE = true
        CHAT_SYSTEM("[PF]ENABLED")
    end
    if cmd == "off" then
        PSEUDOFORECAST_ENABLE = false
        CHAT_SYSTEM("[PF]DISABLED")
    end
end
