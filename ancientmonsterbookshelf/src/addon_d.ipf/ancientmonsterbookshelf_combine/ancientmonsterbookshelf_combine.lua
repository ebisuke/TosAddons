--ancientmonsterbookshelf_combine
local addonName = 'ANCIENTMONSTERBOOKSHELF'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.framename_combine="ancientmonsterbookshelf_combine"
--ライブラリ読み込み
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
            print(msg)
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function ANCIENTMONSTERBOOKSHELF_COMBINE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()

            frame = ui.GetFrame(g.framename_combine)
            g.addon_combine = addon
            g.frame_combine = frame
            local btn=frame:CreateOrGetControl("button",'btndocombine',0,0,150,30)
            btn:SetGravity(ui.CENTER_HORZ,ui.TOP)
            btn:SetMargin(0,150,0,0)
            btn:SetText("Auto Combine")
            ANCIENTMONSTERBOOKSHELF_COMBINE_INITFRAME()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_COMBINE_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename_combine)
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
