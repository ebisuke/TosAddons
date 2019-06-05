--OLD_SHOP_ITEM_LIST_GET
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local status, xml = pcall(require, "xmlSimple");
local acutil = require('acutil')
--mode 1 from ies
--mode 2 from xml
PSEUDOFORECAST_MODE = 1
PSEUDOFORECAST_COROUTINE=nil
PSEUDOFORECAST_YOFFSET=10
PSEUDOFORECAST_DATA={
	
	example={
		{timestart=0,timeend=0,angle=0,width=0,length=0,typ="FAN"},
		{timestart=0,timeend=0,angle=0,width=0,length=0,typ="CIRCLE"}
	}

}
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

function PSEUDOFORECAST_LOADXML()
	EBI_try_catch{
        try = function()
		local ps=xml.newParser():loadFile("../addons/pseudoforecast/skill_bytool.xml");
		CHAT_SYSTEM(tostring(ps))
		PSEUDOFORECAST_DATA={}
		--ロードしていくが
		PSEUDOFORECAST_LOADINGXML()
	end,
	catch = function(error)
		CHAT_SYSTEM(error)
	end
	}

end

function PSEUDOFORECAST_LOADINGXML(ps)
	local colo = coroutine.create(function()
		EBI_try_catch{
		try = function()
			local skills = ps["ToolSkill"]:children();
			for i = 1, #skills do
				local skill = skills[i];
				local mainskil=skill["MainSkl"]
				local hitlist=mainskil["HitList"]
				if(hitlist)then
					for j = 1, #hitlist do
						local hit=hitlist[i]
						if(PSEUDOFORECAST_DATA[skill["@Name"]]==nil)then
							PSEUDOFORECAST_DATA[skill["@Name"]]={}
						end
						PSEUDOFORECAST_DATA[skill["@Name"]][#PSEUDOFORECAST_DATA[skill["@Name"]]+1]=
						{
							timestart=hit["@Time"],
							timeend=hit["@AniTime"],
							angle=hit["@Angle"],
							width=hit["@Width"],
							length=hit["@Length"],
						}
						
					end
				end
				if(i%5==0)then
					coroutine.yield()
				end
			end
		end,
		catch = function(error)
			CHAT_SYSTEM(error)
		end
		}
		end
	)
	PSEUDOFORECAST_COROUTINE=colo
	PSEUDOFORECAST_WAITFORCOROUTINE()
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
                local duration = 1
                --iesから読み込む
				local class = GetClassByType("Skill", skillclsid)
				CHAT_SYSTEM(class.SplType)
				CHAT_SYSTEM(string.format("SPR:%d,SLA:%d,LEN:%d",SCR_Get_SplRange(class),SCR_SPLANGLE(class), SCR_Get_WaveLength(class)))
				if(class.Target~="Actor")then
					if (class.SplType == "Square") then

						PSEUDOFORECAST_DRAWSQUARE_FROMMYACTOR(SCR_Get_SplRange(class), SCR_Get_WaveLength(class), duration)
					elseif (class.SplType == "Circle") then
						PSEUDOFORECAST_DRAWPOS_FROMMYACTOR(SCR_Get_WaveLength(class), duration)
					elseif (class.SplType == "Fan") then
						PSEUDOFORECAST_DRAWFAN_FROMMYACTOR(SCR_Get_SplRange(class), SCR_SPLANGLE(class)*2, duration)
					end
				end
            end
        end,
        
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

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
function PSEUDOFORECAST_DRAWFAN_FROMMYACTOR(length, arcangle, duration)
    
    local actor = GetMyActor()
    local pos = actor:GetPos()
    local angle = fsmactor.GetAngle(actor)
	PSEUDOFORECAST_DRAWFAN(pos.x, pos.y+PSEUDOFORECAST_YOFFSET, pos.z,
	 math.cos(angle / 180.0 * math.pi), math.sin(angle / 180.0 * math.pi), length, arcangle / 2.0,duration)
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
function PSEUDOFORECAST_DRAWPOS_FROMMYACTOR(radius, duration)
    
    local actor = GetMyActor()
    local pos = actor:GetPos()
    local angle = fsmactor.GetAngle(actor)
    PSEUDOFORECAST_DRAWPOS(pos.x, pos.y+PSEUDOFORECAST_YOFFSET, pos.z, radius, duration)
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
function PSEUDOFORECAST_DRAWSQUARE_FROMMYACTOR(width, length, duration)
    
    local actor = GetMyActor()
    local pos = actor:GetPos()
    local angle = fsmactor.GetAngle(actor) * math.pi / 180.0
    local dp = {
        x = math.cos(angle) * length + pos.x,
        y = pos.y,
        z = math.sin(angle) * length + pos.z
    }
    PSEUDOFORECAST_DRAWSQUARE(pos.x, pos.y+PSEUDOFORECAST_YOFFSET, pos.z, dp.x, dp.y+PSEUDOFORECAST_YOFFSET, dp.z, width, duration)

end
