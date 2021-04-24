-- PSEUDORTT
local addonName = "PSEUDORTT"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.reqtime=nil
g.tick=0
g.fallback=false
function PSEUDORTT_ON_INIT(addon, frame)

    frame=ui.GetFrame("pseudortt");
    frame:ShowWindow(1)
    addon:RegisterMsg("FPS_UPDATE","PSEUDORTT_FPS_UPDATE")
    addon:RegisterMsg("ZONE_TRAFFICS", "PSEUDORTT_ON_ZONE_TRAFFICS");
	addon:RegisterMsg('UPDATE_TRUST_POINT', 'PSEUDORTT_ON_ZONE_TRAFFICS');
    
    if app.RequestChannelTraffics~=PSEUDORTT_REQUEST_RTT and g.oldRequestChannelTraffics==nil then
        g.oldRequestChannelTraffics=app.RequestChannelTraffics
        app.RequestChannelTraffics=PSEUDORTT_REQUEST_RTT
    end
    if session.inventory.ReqTrustPoint~=PSEUDORTT_REQTRUSTPOINT and g.oldReqTrustPoint==nil then
        g.oldReqTrustPoint=session.inventory.ReqTrustPoint
        session.inventory.ReqTrustPoint=PSEUDORTT_REQTRUSTPOINT
    end
    g.fallback=false
end
function PSEUDORTT_REQUEST_RTT(...)
    g.oldRequestChannelTraffics(...)
    if not g.reqtime then
        g.reqtime=os.clock()
    end
end
function PSEUDORTT_REQTRUSTPOINT(...)
    g.oldReqTrustPoint(...)
    if not g.reqtime then
        g.reqtime=os.clock()
    end
end
function PSEUDORTT_ON_ZONE_TRAFFICS()
    if g.reqtime then
        g.tick=0
        imcAddOn.BroadMsg("RTT_UPDATE",tostring(string.format("%.0fms",((os.clock()-g.reqtime)*1000))))
        g.reqtime=nil
    end
end
function PSEUDORTT_FPS_UPDATE()
    g.tick=g.tick+1
    if g.tick==2 then
   
        if g.fallback==false then
            
            app.RequestChannelTraffic()
        else
            session.inventory.ReqTrustPoint()
        end
       
    elseif g.tick >= 5 and g.fallback==false then
        g.fallback=true
        g.tick=0
        app.RequestChannelTraffic()
    end
end