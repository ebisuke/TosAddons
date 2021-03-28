
local g={}
function AS_LOGIN_SERVERLIST()
    ReserveScript("AS_LOGIN_SERVERLIST_DELAY()", 0.01)
    local result = AS_LOGIN_SERVERLIST_OLD()
    return result
end
function AS_LOGIN_SERVERLIST_DELAY()
    local frame = ui.GetFrame('loginui_autojoin')
    if frame:IsVisible() == 1 then
        
        local text = frame:CreateOrGetControl("richtext", 'as', 0, 0, 200, 10);
        text:SetText("{ol}{s20}Advanced Start Enabled.")
        local timer = frame:CreateOrGetControl("timer", 'AS_timer', 0, 0, 10, 10);
        AUTO_CAST(timer)
        timer:SetUpdateScript('ADVANCEDSTART_ON_TIMER')
        timer:Start(0.00)
    end
end
local function SetMousePos_Fixed(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    --return x*(sw/ow),y*(sh/oh)
    mouse.SetPos(x * (sw / ow), y * (sh / oh))
end
local function GetScreenWidth()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return ow
end
local function GetScreenHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return oh
end
local function CalcPos(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('loginui_autojoin')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return x * (sw / ow), y * (sh / oh)

end

function ADVANCEDSTART_ON_TIMER(frame)
    local sframe = ui.GetFrame('loginui_autojoin_serverselect')
    local serverlist = sframe:GetChildRecursively('select server')
    local okbtn = frame:GetChildRecursively("OK")
    AUTO_CAST(serverlist)
    local index = serverlist:GetSelItemIndex();
    
    
    if imcinput.HotKey.IsDown("MoveUp") == true then
        index = math.max(0, index - 1)
        serverlist:DeSelectItemAll()
        serverlist:SelectItem(index)
        imcSound.PlaySoundEvent('button_click')
    end
    
    if imcinput.HotKey.IsDown("MoveDown") == true then
        index = index + 1
        serverlist:DeSelectItemAll()
        serverlist:SelectItem(index)
        imcSound.PlaySoundEvent('button_click')
    end
    if imcinput.HotKey.IsDown("NormalAttack") == true then
        local posx, posy = CalcPos(okbtn:GetX() + okbtn:GetWidth() / 2, okbtn:GetY() + okbtn:GetHeight() / 2)
        mouse.SetPos(posx, posy)
        SetKeyboardSelectMode(1)
    
    
    end
    if imcinput.HotKey.IsDown("Escape") == true then
        app.Quit()
    
    
    end
end
function AS_ISHIDELOGIN()
    SetKeyboardSelectMode(0)
    ReserveScript("AS_ISHIDELOGIN_DELAY()", 0.01)
    
    return AS_ISHIDELOGIN_OLD()
end
function AS_ISHIDELOGIN_DELAY()
    local frame = ui.GetFrame('barrack_charlist')
    if frame:IsVisible() == 1 then
        local timer = frame:CreateOrGetControl("timer", 'AS_barracktimer', 0, 0, 10, 10);
        AUTO_CAST(timer)
        timer:SetUpdateScript('ADVANCEDSTART_BARRACK_ON_TIMER');
        timer:Start(0.00)
    end
end
function ADVANCEDSTART_BARRACK_ON_TIMER()
    local frame = ui.GetFrame('barrack_charlist')
    if imcinput.HotKey.IsDown("MoveLeft") == true then
        imcSound.PlaySoundEvent('button_click_big')
        local layer = math.max(1, current_layer - 1)
        SELECT_BARRACK_LAYER(frame, frame:GetChildRecursively("changeLayer" .. layer), nil, layer)
    end
    if imcinput.HotKey.IsDown("MoveRight") == true then
        imcSound.PlaySoundEvent('button_click_big')
        local layer = math.min(3, current_layer + 1)
        SELECT_BARRACK_LAYER(frame, frame:GetChildRecursively("changeLayer" .. layer), nil, layer)
    end
    if imcinput.HotKey.IsDown("MoveUp") == true then
        imcSound.PlaySoundEvent('button_click_big')
        local cids=ADVANCEDSTART_BARRACK_ENUMERATE_CHARACTOR_CID()
        local idx,cid=ADVANCEDSTART_BARRACK_GET_CURRENT_CHARACTOR_INDEX_AND_CID(CUR_SELECT_GUID)
        idx=math.max(1,idx-1)
        SELECT_CHARBTN_LBTNUP(frame,nil,cids[idx],nil)
    
    end
    if imcinput.HotKey.IsDown("MoveDown") == true then
        imcSound.PlaySoundEvent('button_click_big')
       
        local cids=ADVANCEDSTART_BARRACK_ENUMERATE_CHARACTOR_CID()
        local idx,cid=ADVANCEDSTART_BARRACK_GET_CURRENT_CHARACTOR_INDEX_AND_CID(CUR_SELECT_GUID)
        idx=math.min(#cids,idx+1)
        SELECT_CHARBTN_LBTNUP(frame,nil,cids[idx],nil)
    end
    if imcinput.HotKey.IsDown("NormalAttack") == true then
        imcSound.PlaySoundEvent('button_click_big')
        BARRACK_TO_GAME()
    end
    if imcinput.HotKey.IsDown("Escape") == true then
        imcSound.PlaySoundEvent('button_click_big')
        
        app.BarrackToLogin()
    end
end
function ADVANCEDSTART_BARRACK_ENUMERATE_CHARACTOR_CID()
    
    local frame = ui.GetFrame('barrack_charlist')
    local scrollBox = frame:GetChildRecursively("scrollBox");
    local cids = {}
    for i = 0, scrollBox:GetChildCount() - 1 do
        local ctrl = scrollBox:GetChildByIndex(i)
        if string.find(ctrl:GetName(), 'char_') ~= nil then
            local cid = ctrl:GetUserValue("CID");
            cids[#cids + 1] = cid
        end
    end
    return cids
end
function ADVANCEDSTART_BARRACK_GET_CURRENT_CHARACTOR_INDEX_AND_CID(cid)
    
    local cids = ADVANCEDSTART_BARRACK_ENUMERATE_CHARACTOR_CID()
    for i = 1, #cids do
        
        if cids[i] == cid then
            return i, cids[i]
        end
    end
    return 1,cids[1]
end
if AS_LOGIN_SERVERLIST_OLD == nil and login.LoadServerList ~= AS_LOGIN_SERVERLIST then
    AS_LOGIN_SERVERLIST_OLD = login.LoadServerList
    login.LoadServerList = AS_LOGIN_SERVERLIST
end
if AS_ISHIDELOGIN_OLD == nil and barrack.IsHideLogin ~= AS_ISHIDELOGIN then
    AS_ISHIDELOGIN_OLD = barrack.IsHideLogin
    barrack.IsHideLogin = AS_ISHIDELOGIN
end
