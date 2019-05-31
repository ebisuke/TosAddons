local acutil = require('acutil')
local default = {
    blacklist = {
        charbaseinfo = 1;
        charframe = 1;
        expviewer = 1;
        headsupdisplay = 1;
        minimap = 1;
        partyinfo = 1;
        questinfoset_2 = 1;
        quickslotnexpbar = 1;
        sysmenu = 1;
        weaponswap = 1;
        indun_reward_hud = 1;
        expviewer_ex = 1;
        targetinfotoboss = 1;
        chatframe = 1;
    }
}

local settings = {}
local focusedFrames = {}
local battleframe = nil
local contextFrame = nil
local bmButton = nil
local curFrameName = nil
local bmConfigFrame = nil
local BM_CONFIG_TIMER = nil
local bmIsConfig = false
-- local bmStatusFrame = {}
local bmToggleButton = {}
local battleModeStatus = 0

CHAT_SYSTEM('Embedded Battlemode loaded. Type /ebm config to configure.')

function EMBEDDEDBATTLEMODE_ON_INIT(addon, frame)
    acutil.slashCommand('bm', EMBEDDEDBATTLEMODE_TOGGLE_BATTLE_MODE)
    if battleModeStatus == nil then
        battleModeStatus = 0
    end
    -- battleModeStatus = 0
    addon:RegisterMsg('FPS_UPDATE', 'EMBEDDEDBATTLEMODE_UPDATE_BATTLE_MODE')

end

function EMBEDDEDBATTLEMODE_LOADSETTINGS()
    local s, err = acutil.loadJSON("../addons/enhancedtargetlock/ebmsettings.json");
    if err then
        settings = default
    else
        settings = s
        for k, v in pairs(default) do
            if s[k] == nil then
                settings[k] = v
            end
        end
    end
    EMBEDDEDBATTLEMODE_SAVESETTINGS()
end

function EMBEDDEDBATTLEMODE_SAVESETTINGS()
    acutil.saveJSON("../addons/enhancedtargetlock/ebmsettings.json", settings);
end

function EMBEDDEDBATTLEMODE_CREATE_BATTLE_MODE_FRAME()
    battleframe = ui.GetFrame('EMBEDDEDBATTLEMODE_FRAME')
    if battleframe == nil then
        battleframe = ui.CreateNewFrame('bandicam', 'EMBEDDEDBATTLEMODE_FRAME')
        battleframe:ShowWindow(1)
        EMBEDDEDBATTLEMODE_UPDATE_BATTLE_MODE()
    end
    battleframe:ShowWindow(1)
    -- bmToggleButton['frame'] = ui.GetFrame('BM_TOGGLE_BUTTON_FRAME')
    -- if bmToggleButton['frame'] == nil then
    --     bmToggleButton['frame'] = ui.CreateNewFrame('embeddedbattlemode', 'BM_TOGGLE_BUTTON_FRAME')
    --     bmToggleButton['frame']:Resize(200, 200)
    --     bmToggleButton['frame']:SetPos(0, 0)
    --     bmToggleButton['frame']:SetLayerLevel(1000)
    --     bmToggleButton['frame']:ShowWindow(1)
    --     bmToggleButton['button'] = bmToggleButton['frame']:CreateOrGetControl('button', 'BM_TOGGLE_BUTTON', 0, 0, 100, 35)
    --     bmToggleButton['button'] = tolua.cast(bmToggleButton['button'], 'ui::CButton')
    --     bmToggleButton['button']:SetClickSound("button_click_big");
    --     bmToggleButton['button']:SetOverSound("button_over");
    --     bmToggleButton['button']:SetSkinName("quest_box");
    --     bmToggleButton['button']:ShowWindow(1)
    --     bmToggleButton['button']:SetEventScript(ui.LBUTTONUP, "ui.Chat('/bm')");
    -- end
    -- if battleModeStatus == 0 then
    --     bmToggleButton['button']:SetText("{@st41}{#ff0000}{s18}bm off")
    -- else
    --     bmToggleButton['button']:SetText("{@st41}{#009900}{s18}bm on");
    -- end
    return battleframe
end

function EMBEDDEDBATTLEMODE_SET_FRAME_HITTEST()
    if(settings.blacklist==nil)then
        settings.blacklist=default.blacklist
    end
    for k, v in pairs(settings.blacklist) do
        local curFrameName = k
        local curFrame = ui.GetFrame(curFrameName)
        if curFrame ~= nil then
            if focusedFrames[curFrameName] == nil then
                focusedFrames[curFrameName] = curFrame:IsEnableHitTest()
            end
            curFrame:EnableHitTest(0)
        end
    end

end

function EMBEDDEDBATTLEMODE_UPDATE_FRAME_HITTEST()
    local curFrame = ui.GetFocusFrame()
    if curFrame ~= nil then
        if focusedFrames[curFrame:GetName()] == nil then
            focusedFrames[curFrame:GetName()] = curFrame:IsEnableHitTest()
        end
        if settings.blacklist[curFrame:GetName()] ~= nil then
            curFrame:EnableHitTest(0)
        end
    end

end


function EMBEDDEDBATTLEMODE_UPDATE_BATTLE_MODE()
    battleframe = EMBEDDEDBATTLEMODE_CREATE_BATTLE_MODE_FRAME()
    EMBEDDEDBATTLEMODE_TIMER = GET_CHILD(battleframe, "addontimer", "ui::CAddOnTimer");
    if battleModeStatus == 0 then
        EMBEDDEDBATTLEMODE_TIMER:Stop()
        for k, v in pairs(focusedFrames) do
            local hitTestFrame = ui.GetFrame(k)
            if hitTestFrame ~= nil then
                local val
                if v == true then val = 1 else val = 0 end
                hitTestFrame:EnableHitTest(1)
            end
        end
        focusedFrames = {}
    else

        EMBEDDEDBATTLEMODE_SET_FRAME_HITTEST()
        EMBEDDEDBATTLEMODE_TIMER:SetUpdateScript('EMBEDDEDBATTLEMODE_UPDATE_FRAME_HITTEST');
        EMBEDDEDBATTLEMODE_TIMER:EnableHideUpdate(1)
        EMBEDDEDBATTLEMODE_TIMER:Stop();
        EMBEDDEDBATTLEMODE_TIMER:Start(0.1);
    end
end


function EMBEDDEDBATTLEMODE_CONFIG(configState)
    if contextFrame == nil then
        contextFrame = ui.CreateNewFrame('embeddedbattlemode', 'EMBEDDEDBATTLEMODE_CONTEXT')
    end
    contextFrame:Resize(200, 50)
    contextFrame:SetPos(0, 0)
    contextFrame:SetLayerLevel(1000)
    bmButton = contextFrame:CreateOrGetControl('button', 'EMBEDDEDBATTLEMODE_BUTTON', 0, 0, 200, 50)
    bmButton = tolua.cast(bmButton, 'ui::CButton')
    bmButton:SetClickSound("button_click_big");
    bmButton:SetOverSound("button_over");
    bmButton:SetSkinName("test_pvp_btn");
    bmButton:ShowWindow(1)
    
    bmConfigFrame = ui.CreateNewFrame('bandicam', 'EMBEDDEDBATTLEMODE_CONFIG_FRAME')
    BM_CONFIG_TIMER = GET_CHILD(bmConfigFrame, "addontimer", "ui::CAddOnTimer");
    BM_CONFIG_TIMER:SetUpdateScript('EMBEDDEDBATTLEMODE_CONFIG_UPDATE');
    BM_CONFIG_TIMER:EnableHideUpdate(1)
    BM_CONFIG_TIMER:Stop();
    if not configState then
        BM_CONFIG_TIMER:Start(0.1);
    else
        contextFrame:ShowWindow(0)
    end
end

function EMBEDDEDBATTLEMODE_CONFIG_UPDATE()
    bmButton:SetEventScript(ui.RBUTTONUP, "ui.Chat('/ebm config')")
    local curFrame = ui.GetFocusFrame()
    if curFrame ~= nil then
        if curFrameName ~= curFrame:GetName() and curFrame:GetName() ~= 'EMBEDDEDBATTLEMODE_CONTEXT' then
            contextFrame:SetPos(curFrame:GetX() + curFrame:GetWidth() / 2 - contextFrame:GetWidth() / 2, curFrame:GetY() + curFrame:GetHeight() / 2 - contextFrame:GetHeight() / 2)
            contextFrame:ShowWindow(1)
            contextFrame:EnableHitTest(1)
            if settings.blacklist[curFrame:GetName()] == nil then
                bmButton:SetText('{#009900}' .. curFrame:GetName())
                bmButton:SetEventScript(ui.LBUTTONUP, "ui.Chat('/ebm blacklist " .. curFrame:GetName() .. "')");
            else
                bmButton:SetText('{#ff0000}' .. curFrame:GetName())
                bmButton:SetEventScript(ui.LBUTTONUP, "ui.Chat('/ebm whitelist " .. curFrame:GetName() .. "')");
            end
            contextFrame:Resize(bmButton:GetWidth(), contextFrame:GetHeight())
            curFrameName = curFrame:GetName()
        
        end
    else
        if contextFrame:GetX() == 0 and contextFrame:GetY() == 0 then
            curFrameName = 'quickslotnexpbar'
            local quickSlot = ui.GetFrame('quickslotnexpbar')
            if quickSlot ~= nil then
                contextFrame:ShowWindow(1)
                contextFrame:EnableHitTest(1)
                contextFrame:SetPos(quickSlot:GetX() + quickSlot:GetWidth() / 2 - contextFrame:GetWidth() / 2, quickSlot:GetY() + quickSlot:GetHeight() / 2 - contextFrame:GetHeight() / 2)
                if settings.blacklist['quickslotnexpbar'] == nil then
                    bmButton:SetText('{#009900}quickslotnexpbar')
                    bmButton:SetEventScript(ui.LBUTTONUP, "ui.Chat('/ebm blacklist quickslotnexpbar')");
                else
                    bmButton:SetText('{#ff0000}quickslotnexpbar')
                    bmButton:SetEventScript(ui.LBUTTONUP, "ui.Chat('/ebm whitelist quickslotnexpbar')");
                end
                contextFrame:Resize(bmButton:GetWidth(), contextFrame:GetHeight())
            end
        end
    end
end

function EMBEDDEDBATTLEMODE_TOGGLE_BATTLE_MODE(command)
    EMBEDDEDBATTLEMODE_LOADSETTINGS()
    cmd = table.remove(command, 1)
    local framename = nil
    if cmd == 'config' then
        if battleModeStatus == 1 then
            EMBEDDEDBATTLEMODE_TOGGLE_BATTLE_MODE({})
        end
        if not bmIsConfig then
            CHAT_SYSTEM('Entering battlemode configuration.{nl}Frame names in red will be turned off in battlemode. {nl}{nl}If you cannot click the button, you can type /bm whitelist <framename> or /bm blacklist <framename>.{nl}Right click the button to exit, or type /bm config again.')
        else
            CHAT_SYSTEM('Exiting battlemode configuration.')
        end
        
        EMBEDDEDBATTLEMODE_CONFIG(bmIsConfig)
        bmIsConfig = not bmIsConfig
        return EMBEDDEDBATTLEMODE_SAVESETTINGS()
    end
    if cmd == 'blacklist' then
        framename = table.remove(command, 1)
        settings.blacklist[framename] = 1
        bmButton:SetText('{#ff0000}' .. framename)
        CHAT_SYSTEM('Frame ' .. framename .. ' added to blacklist.')
        bmButton:SetEventScript(ui.LBUTTONUP, "ui.Chat('/ebm whitelist " .. framename .. "')");
        return EMBEDDEDBATTLEMODE_SAVESETTINGS()
    end
    if cmd == 'whitelist' then
        framename = table.remove(command, 1)
        for k, v in pairs(settings.blacklist) do
            if k == framename then
                settings.blacklist[k] = nil
                bmButton:SetText('{#009900}' .. framename)
                CHAT_SYSTEM('Frame ' .. framename .. ' removed from blacklist.')
                bmButton:SetEventScript(ui.LBUTTONUP, "ui.Chat('/ebm blacklist " .. framename .. "')");
            end
        end
        return EMBEDDEDBATTLEMODE_SAVESETTINGS()
    end
    if cmd == 'reset' then
        CHAT_SYSTEM('Resetting all settings.')
        settings = {}
        EMBEDDEDBATTLEMODE_SAVESETTINGS()
        EMBEDDEDBATTLEMODE_LOADSETTINGS()
        return;
    end
    if bmIsConfig and battleModeStatus == 0 then
        return CHAT_SYSTEM('Exit configuration before toggling battlemode on!')
    end
    
    battleModeStatus = math.abs(battleModeStatus - 1)
    EMBEDDEDBATTLEMODE_UPDATE_BATTLE_MODE()
    if battleModeStatus == 0 then
        CHAT_SYSTEM('Battle mode off.')
        -- bmToggleButton['button']:SetText("{@st41}{#ff0000}{s18}bm off");
    else
        CHAT_SYSTEM('Battle mode on.')
        -- bmToggleButton['button']:SetText("{@st41}{#009900}{s18}bm on");
    end
end


function EMBEDDEDBATTLEMODE_SET_BM(mode)
    battleModeStatus = mode
    EMBEDDEDBATTLEMODE_UPDATE_BATTLE_MODE()
end