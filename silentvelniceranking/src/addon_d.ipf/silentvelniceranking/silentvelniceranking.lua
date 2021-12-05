--silentvelniceranking
local addonName = "silentvelniceranking"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")

g.debug = false
g.prevmapname = nil
g.curmapname = nil
--ライブラリ読み込み
CHAT_SYSTEM("[SVR]loaded")
local acutil = require("acutil")
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

local function DBGOUT(msg)
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end

function SILENTVELNICERANKING_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            g.frame=ui.GetFrame("silentvelniceranking")
            local zoneName = session.GetMapName()
            g.prevmapname = g.curmapname
            g.curmapname = zoneName

            g.firsttouch = true
            g.frame:ShowWindow(1)
            addon:RegisterMsg("FPS_UPDATE", "SILENTVELNICERANKING_SHOWWINDOW")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SILENTVELNICERANKING_SHOWWINDOW()
    ui.GetFrame("silentvelniceranking"):ShowWindow(1)
end
function SOLODUNGEON_SCOREBOARD_OPEN(frame, msg, argStr, argNum)
    EBI_try_catch {
        try = function()
            if g.firsttouch then
                ui.SysMsg("4秒以内にジャンプボタンを押すとランキングが表示されます。")
                local timer = ui.GetFrame("silentvelniceranking"):GetChild("addontimer")
                AUTO_CAST(timer)
                timer:SetUpdateScript("SILENTVELNICERANKING_TIMER_UPDATE")
                timer:Start(0.01)
                ReserveScript("SILENTVELNICERANKING_TIMEOUT()", 4)
                g.firsttouch = false
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SILENTVELNICERANKING_TEST()
    imcAddOn.BroadMsg("DO_SOLODUNGEON_SCOREBOARD_OPEN");
end
function SILENTVELNICERANKING_TIMER_UPDATE()
    EBI_try_catch {
        try = function()
            if imcinput.HotKey.IsDown("Jump") == true then
                ui.OpenFrame("solodungeonscoreboard")
                SOLODUNGEON_SCOREBOARD_CLEAR()
                SOLODUNGEON_SCOREBOARD_SET_CUR_STAGE()
                SOLODUNGEON_SCOREBOARD_FILL_RANK_LISTS()
                SILENTVELNICERANKING_TIMEOUT()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function SILENTVELNICERANKING_TIMEOUT()
    local timer = ui.GetFrame("silentvelniceranking"):GetChild("addontimer")
    AUTO_CAST(timer)

    timer:Stop(0)
end
