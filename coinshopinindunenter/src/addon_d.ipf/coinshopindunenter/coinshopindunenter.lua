--coinshopindunenter
--アドオン名（大文字）
local addonName = "coinshopindunenter"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "アドオン名（大文字）"
g.debug = false
g.useflag=false
--ライブラリ読み込み
CHAT_SYSTEM("[CSIE]loaded")
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

local g_account_prop_shop_table = 
{
    ['PVPMine'] = 
    {
        ['coinName'] = 'misc_pvp_mine2',
        ['propName'] = 'MISC_PVP_MINE2',
    },
    ['SilverGachaShop'] = 
    {
        ['coinName'] = 'misc_silver_gacha_mileage',
        ['propName'] = 'Mileage_SilverGacha',
    },
}

function COINSHOPINDUNENTER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            acutil.setupHook("EXCHANGE_CREATE_TREE_NODE_CTRL", COINSHOPINDUNENTER_EXCHANGE_CREATE_TREE_NODE_CTRL)

            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

--EARTH_TOWER_SHOP_EXEC


function COINSHOPINDUNENTER_EXCHANGE_CREATE_TREE_NODE_CTRL(ctrlset, cls, shopType) 
    EXCHANGE_CREATE_TREE_NODE_CTRL_OLD(ctrlset, cls, shopType)
    local btn=ctrlset:CreateOrGetControl("button","btnbuyanduse",0,0,100,30) 
    AUTO_CAST(btn)
    btn:SetSkinName('test_red_button')
    btn:SetText('{@st41}1個買って使う')
    btn:SetEventScript(ui.LBUTTONUP,"COINSHOPINDUNENTER_BUYANDUSE")
    btn:SetEventScriptArgString(ui.LBUTTONUP,cls.TargetItem)
    
end

function COINSHOPINDUNENTER_BUYANDUSE(parent, ctrl,targetItemStr)
    local cls=GetClass("Item",targetItemStr)

    session.ResetItemList();
    session.AddItemID(tostring(0), 1);
    local resultlist = session.GetItemIDList();
    item.DialogTransaction("PVP_MINE_SHOP", resultlist, string.format("%s %d",cls.ClassID,1));    
end

function COINSHOPINDUNENTER_USEITEM(targetItemStr)
    local invItem=session.GetInvItemByName(targetItemStr)
    if invItem then
        INV_ICON_USE(invItem)
    end
end

