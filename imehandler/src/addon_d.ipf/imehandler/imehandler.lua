-- imehandler
--アドオン名（大文字）
local addonName = 'IMEHANDLER'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.execFileLoc = string.format('../addons/%s/tosinputhandler.exe', addonNameLower)
g.txFileLoc = string.format('../addons/%s/tx.txt', addonNameLower)
g.rxFileLoc = string.format('../addons/%s/rx.txt', addonNameLower)
local function CalcPosToSToGlobal(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return x * (ow/sw), y * (oh/sh)

end
g.personalsettingsFileLoc = ''
g.framename = 'imehandler'
g.debug = false
g.timelimit=0
local function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end
CHAT_SYSTEM('[IME]loaded')
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
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
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function IMEHANDLER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPEXTENDER_GETCID()))
            frame:ShowWindow(1)
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg("FPS_UPDATE","IMEHANDLER_FPS_UPDATE")
            local timer=frame:GetChild("addontimer")
            AUTO_CAST(timer)
            timer:SetUpdateScript("IMEHANDLER_TIMER")
            
            timer:EnableHideUpdate(true)
            timer:Start(0.00)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function IMEHANDLER_FPS_UPDATE(frame)
    EBI_try_catch{
        try = function()
            frame:ShowWindow(1)
            if file_exists(g.txFileLoc) then
                
                local f=io.open(g.txFileLoc,"r")
                local txt=f:read("a")
                f:close()
                local ctrl=ui.GetFocusObject()
                if ctrl:GetClassString()=="ui::CEditControl" then
                    ctrl:SetText(txt)
                end
                os.remove(g.txFileLoc)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function IMEHANDLER_TIMER()
    EBI_try_catch{
        try = function()
            if g.timelimit>0 then
                g.timelimit=g.timelimit-1
            end
            if 1==keyboard.IsKeyDown("D") and 1==keyboard.IsKeyPressed("LALT")  then

                if g.timelimit<=0 then
                    g.timelimit=15
                else

                    g.timelimit=0
                    local ctrl=ui.GetFocusObject()
                    if ctrl:GetClassString()=="ui::CEditControl" then
                        AUTO_CAST(ctrl)
                        if not file_exists(g.execFileLoc) then
                            ui.SysMsg("Not found imehandler.")
                            return
                        end
                        os.remove(g.rxFileLoc)
                        local f=io.open(g.rxFileLoc,"w")
                        local txt=ctrl:GetText()
                        f:write(txt)
                        f:close()

                        os.remove(g.txFileLoc)
                        local x,y=CalcPosToSToGlobal(ctrl:GetGlobalX(),ctrl:GetGlobalY())
                        local w,h=CalcPosToSToGlobal(ctrl:GetWidth(),ctrl:GetHeight())
                        
                        debug.ShellExecute(g.execFileLoc.." "..x.." "..y.." "..w.." "..h)
                    end
                end
            end
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end