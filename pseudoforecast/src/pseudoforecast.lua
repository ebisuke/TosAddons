--OLD_SHOP_ITEM_LIST_GET
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

local acutil = require('acutil')
--mode 1 from ies
--mode 2 from xml
PSEUDOFORECAST_MODE = 2
PSEUDOFORECAST_COROUTINE=nil
PSEUDOFORECAST_YOFFSET=10
PSEUDOFORECAST_DATA={
	
	example={
		{timestart=0,timeend=0,angle=0,width=0,length=0,typ="FAN"},
		{timestart=0,timeend=0,angle=0,width=0,length=0,typ="CIRCLE"}
	}

}
if(PSEUDOFORECAST_MODE==2)then
	PSEUDOFORECAST_LOADSKILLS()
end
-- ライブラリ読み込み
function PSEUDOFORECAST_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
			if(OLD_ICON_USE == nil or ICON_USE ~= PSEUDOFORECAST_ICON_USE)then
				OLD_ICON_USE=ICON_USE;
				ICON_USE=PSEUDOFORECAST_ICON_USE
				CHAT_SYSTEM("UPDATED")
			end
            CHAT_SYSTEM("INITIALIZED")
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end

function PSEUDOFORECAST_LOADSKILLS()
	EBI_try_catch{
		try = function()
			PSEUDOFORECAST_DATA={}
			dofile("../addons/pseudoforecast/skills.lua")
			local t = data
			CHAT_SYSTEM(tostring(t))
			PSEUDOFORECAST_DATA=t

		end,
		catch = function(error)
			CHAT_SYSTEM(error)
			
		end
	}

end


function PSEUDOFORECAST_WAITFORCOROUTINE()

	if(coroutine.status(PSEUDOFORECAST_COROUTINE)=="dead")then
		CHAT_SYSTEM("COMPLETE COROUTINE")
		return
	else
		ReserveScript("PSEUDOFORECAST_WAITFORCOROUTINE()",0.00)
	end

end

function PSEUDOFORECAST_ICON_USE(object, reAction)
    OLD_ICON_USE(object, reAction)
    local iconPt = object;
    if iconPt ~= nil then
        local icon = tolua.cast(iconPt, 'ui::CIcon');
        
        local iconInfo = icon:GetInfo();
        if iconInfo:GetCategory() == 'Skill' then
            PSEUDOFORECAST_SKILL(iconInfo.type)
        end
    end
    CHAT_SYSTEM("CALL")
end
function PSEUDOFORECAST_SKILL(skillclsid)
    EBI_try_catch{
        try = function()
            if (PSEUDOFORECAST_MODE == 1) then
                -- local duration = 1
                -- --iesから読み込む
				-- local class = GetClassByType("Skill", skillclsid)
				-- CHAT_SYSTEM(class.SplType)
				-- CHAT_SYSTEM(string.format("SPR:%d,SLA:%d,LEN:%d",SCR_Get_SplRange(class),SCR_SPLANGLE(class), SCR_Get_WaveLength(class)))
				-- if(class.Target~="Actor")then
				-- 	if (class.SplType == "Square") then

				-- 		PSEUDOFORECAST_DRAWSQUARE_FROMMYACTOR(SCR_Get_SplRange(class), SCR_Get_WaveLength(class), duration)
				-- 	elseif (class.SplType == "Circle") then
				-- 		PSEUDOFORECAST_DRAWPOS_FROMMYACTOR(SCR_Get_WaveLength(class), duration)
				-- 	elseif (class.SplType == "Fan") then
				-- 		PSEUDOFORECAST_DRAWFAN_FROMMYACTOR(SCR_Get_SplRange(class), SCR_SPLANGLE(class)*2, duration)
				-- 	end
				-- end
			elseif(PSEUDOFORECAST_MODE==2)then
				--xml(lua)から読み込む
				local duration = 1
                --iesから読み込む
				local class = GetClassByType("Skill", skillclsid)
				
				CHAT_SYSTEM(string.format("Name:%s,SPR:%d,SLA:%d,LEN:%d",class.ClassName,SCR_Get_SplRange(class),SCR_SPLANGLE(class), SCR_Get_WaveLength(class)))
				local xmlskls=PSEUDOFORECAST_DATA[class.ClassName]
				if(xmlskls)then
					if(class.Target~="Actor")then
						for i=1,#xmlskls do
							local xmlskl=xmlskls[i]
							CHAT_SYSTEM("IN"..tostring(xmlskl.timestart))
							ReserveScript(string.format('PSEUDOFORECAST_DELAYED_SKILLACTION("%s",%d)',
							class.ClassName,i),xmlskl.timestart/1000.0)
						end

						
					end
				end
			end
        end,
        
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function PSEUDOFORECAST_DELAYED_SKILLACTION(classname,index)
	local xmlskl=PSEUDOFORECAST_DATA[classname][index]
	local duration=(xmlskl.timeend-xmlskl.timestart)/1000.0
	if(xmlskl.timestart%10~=9)then
		CHAT_SYSTEM(xmlskl.typ)
		if (xmlskl.typ == "Square") then

			PSEUDOFORECAST_DRAWSQUARE_FROMMYACTOR(xmlskl.width, 
			xmlskl.length,0,xmlskl.rotate*180.0/math.pi, duration)
		elseif (xmlskl.typ == "Circle") then
			PSEUDOFORECAST_DRAWPOS_FROMMYACTOR(xmlskl.width,xmlskl.length,xmlskl.rotate, duration)
		elseif (xmlskl.typ == "Fan") then
			PSEUDOFORECAST_DRAWFAN_FROMMYACTOR(xmlskl.length,
			xmlskl.angle*180.0/math.pi*4,0,(xmlskl.rotate)*180.0/math.pi, duration)
		end
	end
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
function PSEUDOFORECAST_DRAWFAN_FROMMYACTOR(length, arcangle,push,rotate, duration)
    
    local actor = GetMyActor()
    local pos = actor:GetPos()
    local angle = fsmactor.GetAngle(actor)+rotate
	PSEUDOFORECAST_DRAWFAN(
		pos.x+push*math.cos(angle/180.0*math.pi), 
		pos.y+PSEUDOFORECAST_YOFFSET, 
		pos.z+push*math.sin(angle/180.0*math.pi),
		 math.cos(angle / 180.0 * math.pi), 
		 math.sin(angle / 180.0 * math.pi), 
		 length, 
		 arcangle / 2.0,duration)
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
function PSEUDOFORECAST_DRAWPOS_FROMMYACTOR(radius,push,rotate,duration)
    
    local actor = GetMyActor()
    local pos = actor:GetPos()
    local angle = fsmactor.GetAngle(actor)
	PSEUDOFORECAST_DRAWPOS(pos.x+push*math.cos(angle/180*math.pi), pos.y+PSEUDOFORECAST_YOFFSET, 
	pos.z+push*math.sin(angle/180*math.pi), radius, duration)
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
function PSEUDOFORECAST_DRAWSQUARE_FROMMYACTOR(width, length,push,rotate, duration)
    
    local actor = GetMyActor()
    local pos = actor:GetPos()
	local angle = fsmactor.GetAngle(actor) * math.pi / 180.0
    local dp = {
        x = math.cos(angle+rotate/180.0*math.pi) * length + pos.x+push*math.sin(angle/180*math.pi),
        y = pos.y,
        z = math.sin(angle+rotate/180.0*math.pi) * length + pos.z+push*math.cos(angle/180*math.pi)
    }
	PSEUDOFORECAST_DRAWSQUARE(pos.x+push*math.cos(angle/180*math.pi), pos.y+PSEUDOFORECAST_YOFFSET, pos.z+push*math.sin(angle/180*math.pi),
	 dp.x, dp.y+PSEUDOFORECAST_YOFFSET, dp.z, width, duration)

end
