--アドオン名（大文字）
local addonName = "midiplayer"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
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

--ライブラリ読み込み
CHAT_SYSTEM("[MIDI]loaded")
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
local function IsLesserThanForBigNumber(a, b)
    if a == b or (IsGreaterThanForBigNumber(a, b) == 1) then
        return 0
    end
    return 1
end


local translationtable = {
    
    }

local function L_(str)
    if (translationtable[str] == nil) then
        return str
    end
    if (option.GetCurrentCountry() == "Japanese") then
        return translationtable[str].jp
    end
    if (translationtable[str].eng ~= nil) then
        return translationtable[str].eng
    end
    return str

end

--デフォルト設定
if (not g.loaded) then
    --シンタックス用に残す
    g.settings = {
        version = nil,
        --フレーム表示場所
        position = {
            x = 0,
            y = 0
        },
    }


end


function MIDIPLAYER_SAVE_SETTINGS()
    DBGOUT("SAVE_SETTINGS")
    MIDIPLAYER_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)

end

function MIDIPLAYER_LOAD_SETTINGS()
    
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        MIDIPLAYER_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {items = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    
    local upc = MIDIPLAYER_UPGRADE_SETTINGS()
    
    -- ショートサーキット評価を回避するため、いったん変数に入れる
    if upc then
        MIDIPLAYER_SAVE_SETTINGS()
    end

end
function MIDIPLAYER_UPGRADE_SETTINGS()
    local upgraded = false
    --1->2
    if (g.settings.version == nil or g.settings.version == 1) then
        CHAT_SYSTEM(L_("Tsettingsupdt12"))
        
        g.settings.version = 2
        upgraded = true
    end
    --1->2
    if (g.settings.version == 2) then
        CHAT_SYSTEM(L_("Tsettingsupdt23"))
        g.settings.itemmanagetempdisabled = false
        g.settings.version = 3
        upgraded = true
    end
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function MIDIPLAYER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            MIDI = MIDIPLAYER_midiraw
            frame:ShowWindow(0)
            acutil.addSysIcon("midiplayer", "sysmenu_inv", "MidiPlayer", "MIDIPLAYER_TOGGLE_FRAME")
            addon:RegisterMsg('GAME_START_3SEC', 'MIDIPLAYER_3SEC')
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("MIDIPLAYER_ON_TIMER");
            timer:Start(0.01);
            
            MIDIPLAYER_SHOW()
        
        --MIDIPLAYER_UPDATEBOARD()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function MIDIPLAYER_3SEC()



end

function MIDIPLAYER_PLAY()
    MIDIPLAYER_LOAD(g.midifile)
    g.beat = 0
    g.track = 0
    g.idx = 0
    g.play = true
end
function MIDIPLAYER_STOP()
    if (g.prevnote ~= nil) then
        Piedpiper.ReqStopFluting(g.prevnote)
        g.prevnote = nil
    end
    
    g.play = false
end
function MIDIPLAYER_ON_TIMER()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("fluting_keyboard");
            
            local joystickrestquickslot = ui.GetFrame('joystickrestquickslot')
            local restquickslot = ui.GetFrame('restquickslot')
            
            if frame:IsVisible() == 1 then
                local curtrack = g.beat + g.score[1] / 100;
                local prevtrack = g.beat;
                
                for track = 2, #g.score do
                    if ((track - 2) * g.score[1] > curtrack) then
                        break
                    end
                    for k, event in ipairs(g.score[track]) do
                        if event[1] == 'note' then
                            print(tostring(curtrack).."note")
                            if (event[2] >= prevtrack and event[2] <= curtrack and event[3] == g.ch) then
                                --ならす
                                local note = g.nodebind[event[4]]
                                if (g.prevnote ~= nil) then
                                    Piedpiper.ReqStopFluting(g.prevnote)
                                    g.prevnote = nil
                                end
                                if note ~= nil then
                                    Piedpiper.ReqPlayFluting(note)
                                end
                            end
                        end
                    end
                
                end
                g.beat = curtrack
            end
        end,
        catch = function(error)
            MIDIPLAYER_ERROUT(error)
        end
    }
end
function MIDIPLAYER_LOAD(path)
    EBI_try_catch{
        try = function()
            local f = io.open(path, "rb")

            local rawmidi={}}
            local size=f:seek("end",0)
            f:seek("set",0)
            for i=1, size do
                local chat = f:read(1)
                rawmidi[i]=chat
            end
            

            f:close()
            DBGOUT("OK " .. tostring(#rawmidi))
            g.score = MIDI.midi2opus(rawmidi)
            g.play = false
            dataa = g.score
          
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MIDIPLAYER_SHOW()
    ui.GetFrame(g.framename):ShowWindow(1)
--MIDIPLAYER_SAVE_SETTINGS()
end

function MIDIPLAYER_TOGGLE_FRAME()
    ui.ToggleFrame(g.framename)
--MIDIPLAYER_SAVE_SETTINGS()
end

function MIDIPLAYER_CLOSE(frame)
    frame:ShowWindow(0)
--MIDIPLAYER_SAVE_SETTINGS()
end
