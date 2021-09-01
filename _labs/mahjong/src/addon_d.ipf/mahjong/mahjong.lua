-- mahjong
local addonName = 'MARJONG'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
local acutil = require('acutil')
--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
--for programming

local m = MAHJONG_LIBRARY_V1
local g = _G['ADDONS'][author][addonName]
--ライブラリ読み込み
CHAT_SYSTEM('[MARJONG]loaded')

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
    if (ctrl == nil) then
        return
    end
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
            print(msg)
        end,
        catch = function(error)
        end
    }
end
local function shuffle(t)
    local tbl = {}
    for i = 1, #t do
        tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
        --local j = math.random(i)
        local j=IMCRandom(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end
local haiimg = {
    'mg_man1',
    'mg_man2',
    'mg_man3',
    'mg_man4',
    'mg_man5',
    'mg_man6',
    'mg_man7',
    'mg_man8',
    'mg_man9',
    'mg_pin1',
    'mg_pin2',
    'mg_pin3',
    'mg_pin4',
    'mg_pin5',
    'mg_pin6',
    'mg_pin7',
    'mg_pin8',
    'mg_pin9',
    'mg_sou1',
    'mg_sou2',
    'mg_sou3',
    'mg_sou4',
    'mg_sou5',
    'mg_sou6',
    'mg_sou7',
    'mg_sou8',
    'mg_sou9',
    'mg_ton',
    'mg_nan',
    'mg_sha',
    'mg_pei',
    'mg_haku',
    'mg_hatu',
    'mg_chun'
}
local hairedimg = {
    'mg_R_man5',
    
    'mg_R_pin5',
    'mg_R_sou5',
}
g = {
    version = 0,
    settings = g.settings or {},
    settingsFileLoc = g.settingsFileLoc or string.format('../addons/%s/settings.json', addonNameLower),
    personalsettingsFileLoc = g.personalsettingsFileLoc or '',
    frame = g.frame or nil,
    framename = 'mahjong',
    debug = false,
    resizing = nil,
    x = nil,
    y = nil,
    --mg=g.mg or {
    mg = {
        isHost = false,
        board = nil,
        me = 1,
        startGame = function()
            local board = m.Board()
            
            for player = 1, 4 do
                board.members[player] = m.Member(player, 'ほげほげ', 25000)
            end
            
            g.mg.board = board
            g.mg.initializeRound()
        end,
        initializeRound = function()
            g.mg.doShipai()
        end,
        doShipai = function()
            --山生成
            local yama = {}
            for i = 0, 135 do
                --数字
                table.insert(yama, i)
            end
            --シャッフル
            yama = shuffle(yama)
            local dora = {}
            local rinshan = {}
            --王牌確保

            --どら
            for i = 1, 5 * 2 do
                local hai = table.remove(yama)
                table.insert(dora, hai)
            end
            --りんしゃん
            for i = 1, 2 * 2 do
                local hai = table.remove(yama)
                table.insert(rinshan, hai)
            end

            --くばる
            --雑な配り方だけど許して
            for player = 1, #g.mg.board.members do
                local hand = m.Hand()
                for i = 1, 13+1 do
                    local hai = table.remove(yama)
                    table.insert(hand.close, hai)
                end
                --ソート
                table.sort(hand.close)
                g.mg.board.members[player].hand = hand
               
            end

            g.mg.board.wanpai.dora = dora
            g.mg.board.wanpai.rinshan = rinshan
            g.mg.board.yama = yama
        end
    },
    saveSettings = function()
        acutil.saveJSON(g.settingsFileLoc, g.settings)
    end,
    loadSettings = function()
        DBGOUT('LOAD_SETTING')
        g.settings = {}
        local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
        if err then
            --設定ファイル読み込み失敗時処理
            ERROUT(string.format('[%s] cannot load setting files', addonName))
            g.settings = {x = 0, y = 0, w = 600, h = 400}
        else
            --設定ファイル読み込み成功時処理
            g.settings = t
            if (not g.settings.version) then
                g.settings.version = 0
            end
        end

        g.upgradeSettings()
        g.saveSettings()
    end,
    upgradeSettings = function()
        local upgraded = false
        return upgraded
    end,
    initializeFrame = function()
        EBI_try_catch {
            try = function()
                local frame = g.frame
                local gbox = frame:CreateOrGetControl('groupbox', 'myhand', 0, 0, frame:GetWidth() - 200, 100)
                frame:SetSkinName('chat_window')
                frame:Resize(600, 400)
                AUTO_CAST(gbox)
                gbox:RemoveAllChild()
                gbox:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
                gbox:Resize(frame:GetWidth() - 50, 50)
                gbox:SetOffset(0, 50)
            end,
            catch = function(error)
                ERROUT(error)
            end
        }
    end,
    getHaiImg = function(no)
        if no == m.FIVE_RED_MAN then
            return hairedimg[1]
        elseif no == m.FIVE_RED_PIN then
            return hairedimg[2]
        elseif no == m.FIVE_RED_SOU then
            return hairedimg[3]
        else
        
            return haiimg[math.floor(no / 4) + 1]
        end
    end,
    renderMyHand = function()
        EBI_try_catch {
            try = function()
                local frame = g.frame
                local gbox = frame:GetChild('myhand')
                AUTO_CAST(gbox)
                gbox:RemoveAllChild()

                local hand = g.mg.board.members[g.mg.me].hand
                
                --testing
                for i, hn in ipairs(hand.close) do
                    local hai = gbox:CreateOrGetControl('picture', 'my_hai' .. i, i * 30, 0, 30, 40)
                    AUTO_CAST(hai)
                    hai:SetSkinName('None')

                    hai:SetImage(g.getHaiImg(hn))
                    hai:SetEnableStretch(1)
                    hai:SetOverSound('button_over')
                    hai:SetClickSound('button_click_big')
                    hai:EnableChangeMouseCursor(1)
                end

                local shanten=frame:CreateOrGetControl("richtext",'shanten',20,40,100,30)
                AUTO_CAST(shanten)
                shanten:SetGravity(ui.RIGHT,ui.BOTTOM)
                shanten:SetOffset(100,40)
                local sh=m.Shanten()
                local array34=m.TilesConverter.to_34_array(hand.close)
                
                local shno=sh:calculate_shanten(array34,{},true,true)
                if(shno==0)then
                    shanten:SetText("{ol}テンパイ")
                elseif(shno==-1)then
                    shanten:SetText("{ol}あがり")
                else
                    shanten:SetText("{ol}"..shno.."シャンテン")
                end
            end,
            catch = function(error)
                ERROUT(error)
            end
        }
    end,
    render = function()
        g.renderMyHand()
    end
}

--マップ読み込み時処理（1度だけ）
function MAHJONG_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            m = MAHJONG_LIBRARY_V1
            g.initialized = false
            g.frame = ui.GetFrame(g.framename)
            frame = ui.GetFrame(g.framename)
            g.addon = addon

            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('MGN', 'sysmenu_inv', 'mahjong', 'MAHJONG_TOGGLE_FRAME')
            addon:RegisterMsg('GAME_START_3SEC', 'MAHJONG_INIT')
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            g.loadSettings()
            MAHJONG_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function MAHJONG_INIT()
    EBI_try_catch {
        try = function()
            g.initializeFrame()
            -- repeat
            --     g.mg.startGame()
            --     local hand = g.mg.board.members[g.mg.me].hand
                
            --     local sh=m.Shanten()
            --     local array34=m.TilesConverter.to_34_array(hand.close)
                
            --     local shno=sh:calculate_shanten(array34,{},true,true)
            -- until shno==-1
            g.mg.startGame()
            local hand = g.mg.board.members[g.mg.me].hand
            local hc=m.HandCalculator
            local config=m.HandConfig()
            local tiles = m.TilesConverter.string_to_136_array('334450', '406', '45688',nil,true)
            hand.close=tiles
            local result=hc.estimate_hand_value(hand.close,hand.close[1],nil,nil,config)
            local pp=g.frame:CreateOrGetControl("richtext","yaku",20,20,300,200)
            AUTO_CAST(pp)
            local s="{ol}"
            for _,v in ipairs(result.yaku) do
                s=s..string.format("%s %d翻{nl}" ,v.japanese,v.han_closed)
            end
            s=s..string.format("{#FF9999}{s20}%d翻 %d符 %d点 +%d" ,result.han,result.fu,result.cost.main,result.cost.additional)
            pp:SetText(s)
            g.render()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function MAHJONG_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)
end

--refresh G(is needed?)
_G['ADDONS'][author][addonName] = g
