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
g.midifile = string.format('../addons/%s/play.mid', addonNameLower)
g.debug = true
g.framename = "midiplayer"
g.notebind = {
    [48] = 1,
    [49] = 15,
    [50] = 2,
    [51] = 16,
    [52] = 3,
    [53] = 4,
    [54] = 17,
    [55] = 5,
    [56] = 18,
    [57] = 6,
    [58] = 19,
    [59] = 7,
    [60] = 8,
    [61] = 20,
    [62] = 9,
    [63] = 21,
    [64] = 10,
    [65] = 11,
    [66] = 22,
    [67] = 12,
    [68] = 23,
    [69] = 13,
    [70] = 24,
    [71] = 14,
    [72] = 25,
    [73] = 32,
    [74] = 26,
    [75] = 33,
    [76] = 27,
    [77] = 28,
    [78] = 34,
    [79] = 29,
    [80] = 35,
    [81] = 30,
    [82] = 36,
    [83] = 37
}
g.notebind_minista = {
    [24] = 1,
    [25] = 15,
    [26] = 2,
    [27] = 16,
    [28] = 3,
    [29] = 4,
    [30] = 17,
    [31] = 5,
    [32] = 18,
    [33] = 6,
    [34] = 19,
    [35] = 7,
    [36] = 1,
    [37] = 15,
    [38] = 2,
    [39] = 16,
    [40] = 3,
    [41] = 4,
    [42] = 17,
    [43] = 5,
    [44] = 18,
    [45] = 6,
    [46] = 19,
    [47] = 7,
    [48] = 1,
    [49] = 15,
    [50] = 2,
    [51] = 16,
    [52] = 3,
    [53] = 4,
    [54] = 17,
    [55] = 5,
    [56] = 18,
    [57] = 6,
    [58] = 19,
    [59] = 7,
    [60] = 8,
    [61] = 20,
    [62] = 9,
    [63] = 21,
    [64] = 10,
    [65] = 11,
    [66] = 22,
    [67] = 12,
    [68] = 23,
    [69] = 13,
    [70] = 24,
    [71] = 14,
    [72] = 8,
    [73] = 20,
    [74] = 9,
    [75] = 21,
    [76] = 10,
    [77] = 11,
    [78] = 22,
    [79] = 12,
    [80] = 23,
    [81] = 13,
    [82] = 24,
    [83] = 14,
    [84] = 8,
    [85] = 20,
    [86] = 9,
    [87] = 21,
    [88] = 10,
    [89] = 11,
    [90] = 22,
    [91] = 12,
    [92] = 23,
    [93] = 13,
    [94] = 24,
    [95] = 14,

}

function MIDIPLAYER_SAVE_SETTINGS()
    DBGOUT("SAVE_SETTINGS")
    
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
            g.play=false
            frame:ShowWindow(0)
            acutil.addSysIcon("midiplayer", "sysmenu_inv", "MidiPlayer", "MIDIPLAYER_TOGGLE_FRAME")
            addon:RegisterMsg('GAME_START_3SEC', 'MIDIPLAYER_3SEC')
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("MIDIPLAYER_ON_TIMER");
            timer:Start(0.016);
            frame:Resize(400, 300)
            local btnplay=frame:CreateOrGetControl('button','btnplay',10,200,100,80)
            btnplay:SetText("PLAY")
            local btnstop=frame:CreateOrGetControl('button','btnstop',110,200,100,80)
            btnstop:SetText("STOP")
            local edittempo=frame:CreateOrGetControl('edit','edittempo',210,200,100,30)
            edittempo:SetText("90")
            local editch=frame:CreateOrGetControl('edit','editch',210,240,100,30)
            editch:SetText("90")
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
local function split(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end
  
    local t = {} ; 
    i=1
    for s in string.gmatch(str, "([^"..ts.."]+)") do
      t[i] = s
      i = i + 1
    end
  
    return t
  end
function MIDIPLAYER_PLAY()
    local frame = ui.GetFrame(g.framename)
   
    
    local edittempo=frame:CreateOrGetControl('edit','edittempo',210,200,100,30)
    g.tempo=tonumber(edittempo:GetText()) or 90

    local editch=frame:CreateOrGetControl('edit','editch',210,240,100,30)
    local ch=tostring(editch:GetText())
    if ch=="" or not ch then
        
        g.ch =nil
    else
        g.ch={}
        for _,v in ipairs(split(ch,",")) do
            g.ch[#g.ch+1] = tonumber(v)
        end
    end
    MIDIPLAYER_LOAD(g.midifile)
    g.beat = 0
    g.track = 2
  
    g.idx = {}
    g.play = true
    g.delta = {}
    g.elapsed = 0
    g.prevdt = 0
    g.pitch=0
    g.prevnote={}
end
function MIDIPLAYER_STOP()
    if (g.prevnote ~= nil) then
        for _,v in pairs(g.prevnote) do
            Piedpiper.ReqStopFluting(v)
        end
        g.prevnote = nil
    end
    
    g.play = false
end
local function isIn(val,tbl)
    for index, value in ipairs(tbl) do
        if value==val then
            return true
        end
    end
    return false
end
function MIDIPLAYER_ON_TIMER()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("fluting_keyboard");
            local cframe = ui.GetFrame(g.framename)
            local joystickrestquickslot = ui.GetFrame('joystickrestquickslot')
            local restquickslot = ui.GetFrame('restquickslot')
            
            if frame:IsVisible() == 1 and g.play then
                local allover=true
                g.elapsed = g.elapsed + g.score[1] / (60/2*g.tempo/60)  --60BPM base
                for track = g.track, #g.score do
                    g.track=track
                    local idx=g.idx[track] or 1
                    local noteon = false
                    local pass = false
                   
                    local dt = cframe:CreateOrGetControl("richtext", "delta", 0, 120, 100, 40)
                    dt:SetText("{ol}Time:" .. math.floor(g.elapsed / g.score[1]))
                    for i = idx, #g.score[track] do
                        local event = g.score[track][i]
                        allover=false
                        g.delta[track]=g.delta[track] or 0
                        g.idx[track] = i
                        
                        -- print(g.delta..'/'.. g.elapsed)
                        if event[2]~=0 and (g.delta[track] + event[2]) > g.elapsed then
                            
                            break
                        else
                            --print(g.delta[track]..'/'.. g.elapsed)
                            
                        end
                        pass=true
                     
                        g.delta[track] = event[2] + g.delta[track]
                        
                        local delay=0
                        local notes = cframe:CreateOrGetControl("richtext", "note", 0, 140, 100, 20)
                        local ticker = cframe:CreateOrGetControl("richtext", "ticker", 0, 100, 100, 20)
                                ticker:SetText("{ol}ET:" ..track.."/".. math.floor(g.delta[track] / g.score[1]) .. '/' .. math.floor(g.delta[track]) .. "/" .. g.score[1])
                                
                        if not noteon then
                            
                            
                            if event[1] == 'note_on' then
                                
                                
                                if (not g.ch and event[3]~=9) or isIn(event[3],g.ch) then
                                    --if (event[2] >= prevtrack and event[2] <= curtrack and event[3] == g.ch) then
                                    --ならす
                                    local note = g.notebind_minista[event[4]+g.pitch]
                                    -- if (g.prevnote[note] ~= nil) then
                                        
                                    --     notes:SetText("{ol}")
                                    --     --Piedpiper.ReqStopFluting(g.prevnote)
                                    --     g.prevnote[note] = nil
                                    -- end
                                    if g.prevnote[note] ==nil and note ~= nil then
                                        Piedpiper.ReqPlayFluting(note)
                                        --ReserveScript(string.format("Piedpiper.ReqPlayFluting(%d)",note),delay)
                                        delay=delay+0.01
                                        g.prevnote[note] = note
                                    end
                                    --noteon = true
                                end
                            end
                        end
                        if event[1] == 'note_off' or (event[1]=="note_on" and event[5]==0) then
                            
                            local note = g.notebind_minista[event[4]+g.pitch]
                            if ((not g.ch and event[3]~=9) or isIn(event[3],g.ch)) and g.prevnote[note] then
                                --Piedpiper.ReqStopFluting(note)
                                ReserveScript(string.format("Piedpiper.ReqStopFluting(%d)",note),delay)
                                delay=delay+0.01
                                g.prevnote[note]=nil
                            end
                        end
                        local str=''
                        for k,v in pairs(g.prevnote) do
                            str=str..v..','
                        end

                        notes:SetText("{ol}" .. str)
                    end
                    if #g.score[track]==idx then
                        
                    else
                        break
                    end
                end
                if allover then
                    MIDIPLAYER_STOP()
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function MIDIPLAYER_LOAD(path)
    EBI_try_catch{
        try = function()
            
            os.setlocale("C", "ctype")
            local f = io.open(path, "rb")
            local size = f:seek("end", 0)
            local total = ""
            local mid = {}
            for i = 0, size - 1 do
                f:seek("set", i)
                local part = f:read(1)
                mid[#mid + 1] = string.byte(part)
            end
            f:close()
            --print(tostring(string.byte(total:sub(8,8))))
            g.score = LIBMIDI.midi2opus(mid)
            SCORE = g.score
            --table.sort(g.score, function (e1,e2) return e1[2]<e2[2] end)
            g.play = false
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
