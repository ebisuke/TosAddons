-- advancedassistermanager_combiner

--アドオン名（大文字）
local addonName = 'advancedassistermanager'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.framename_combiner = 'advancedassistermanager_combiner'
g.aamcb={
    combine={
        isworking=false,
        ingredients={},
        cardworking=nil,
        product=nil,
    },
    getTabIndex=function()
        local frame= ui.GetFrame(g.framename_combiner)
        local tab=frame:GetChild('tab')
        AUTO_CAST(tab)
        local tabidx=tab:GetSelectItemIndex()
        return tabidx

    end

}


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
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end

--マップ読み込み時処理（1度だけ）
function ADVANCEDASSISTERMANAGER_COMBINER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(ADVANCEDASSISTERMANAGER_GETCID()))
            frame:ShowWindow(0)

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
                
            local timer = frame:CreateOrGetControl("timer", "addontimer");
            AUTO_CAST(timer)
            timer:SetUpdateScript("ADVANCEDASSISTERMANAGER_COMBINER_TICK");
            timer:Stop();
            timer:Start(0.01, 0);

            frame:ShowWindow(0)
            ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSITERMANAGER_COMBINER_OPEN()
    ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
end
function ADVANCEDASSITERMANAGER_COMBINER_CLOSE()

end
function  ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
    EBI_try_catch {
        try = function()
        local frame= ui.GetFrame(g.framename_combiner)
        local gboxmain=frame:CreateOrGetControl('groupbox','gboxmain',10,120,frame:GetWidth()-20,280)
        local gboxcomb=frame:CreateOrGetControl('groupbox','gboxcomb',10,440,frame:GetWidth()-20,frame:GetHeight()-450)
        local tab=frame:CreateOrGetControl('tab','tab',10,90,frame:GetWidth(),30)
        gboxmain:SetSkinName("bg2")
        gboxcomb:SetSkinName("bg2")

        local btnrefresh=frame:CreateOrGetControl('button','btnrefresh',10,60,100,30)
        btnrefresh:SetSkinName('test_pvp_btn')
        btnrefresh:SetText('{ol}Refresh/Stop')
        btnrefresh:SetEventScript(ui.LBUTTONUP,'ADVANCEDASSISTERMANAGER_COMBINER_REFRESH')

        AUTO_CAST(tab)
        tab:ClearItemAll()
        tab:AddItem('{ol}Combine')
        --tab:AddItem('{ol}Evolve')

        ADVANCEDASSISTERMANAGER_COMBINER_INIT_WORKINGBOX()
        local slotsetinv=gboxcomb:CreateOrGetControl('slotset','slotsetinv',5,5,gboxcomb:GetWidth()-20-10,gboxcomb:GetHeight()-10)
        ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotsetinv)
        ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotsetinv)
                
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function ADVANCEDASSISTERMANAGER_COMBINER_INIT_WORKINGBOX()
    EBI_try_catch {
        try = function()
        local frame= ui.GetFrame(g.framename_combiner)

        local gbox=frame:GetChild('gboxmain')
        
        gbox:RemoveAllChild()

        local tabindex=g.aamcb.getTabIndex()
    
        --working slot
        local slotworking=gbox:CreateOrGetControl('slotset','slotworking',50,60,309,120)
        AUTO_CAST(slotworking)
        ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotworking,nil,nil,nil,3,1)
        ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotworking,nil,{})
        
        --ingredients slot
        local slotingredients=gbox:CreateOrGetControl('slotset','slotingredients',50,180,309,40)
        AUTO_CAST(slotingredients)
        ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotingredients,30,40)
        ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotingredients,nil,{},true)
                
        --gauge
        local gauge=gbox:CreateOrGetControl('gauge','gauge',410,115,100,10)
        AUTO_CAST(gauge)
        gauge:SetMaxPoint(150)
        gauge:SetCurPoint(0)

        
        --product
        local slotproduct=gbox:CreateOrGetControl('slotset','slotproduct',410+150,60,100,120)
        AUTO_CAST(slotproduct)
        ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotproduct,nil,nil,0,nil,1,1)


    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function ADVANCEDASSISTERMANAGER_COMBINER_REFRESH()
    local frame= ui.GetFrame(g.framename_combiner)

    local gbox=frame:GetChild('gboxmain')
    local gauge=gbox:GetChild('gauge')
    AUTO_CAST(gauge)
end
function ADVANCEDASSISTERMANAGER_COMBINER_STOP()
    local frame= ui.GetFrame(g.framename_combiner)

    local gbox=frame:GetChild('gboxmain')
    local gauge=gbox:GetChild('gauge')
    AUTO_CAST(gauge)
    gauge:SetCurPoint(0)
    g.aamcb.combine.isworking=false
    ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
end
_G['ADDONS'][author][addonName]=g