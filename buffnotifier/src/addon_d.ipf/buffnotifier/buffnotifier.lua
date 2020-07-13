--buffnotifier
--アドオン名（大文字）
local addonName = "buffnotifier"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

local function AUTO_CAST(ctrl)
    if (ctrl == nil) then
        
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
    return ctrl;
end
--ライブラリ読み込み
CHAT_SYSTEM("[BN]loaded")

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
local confighandler = {}
confighandler.alloc = function()
    return {
        f = nil,
        buffboxcount = 0,
        init = function(self)
            return EBI_try_catch{
                try = function()
                    self.f = ui.GetFrame("buffnotifierconfig")
                    local f = self.f
                    f:ShowWindow(1)
                    f:Resize(600, 400)
                    local btnsave = f:CreateOrGetControl("button", "btnsave", 20, 100, 100, 30)
                    btnsave:SetText("Close")
                    btnsave:SetEventScript(ui.LBUTTONUP, "BUFFNOTIFIERCONFIG_CLOSE")
                    btnsave:SetGravity(ui.RIGHT, ui.TOP)
                    btnsave:SetOffset(20, 100)
                    local btnadd = f:CreateOrGetControl("button", "btnadd", 20, 100, 100, 30)
                    btnadd:SetText("Add")
                    btnadd:SetEventScript(ui.LBUTTONUP, "BUFFNOTIFIERCONFIG_ONBTNADD")
                    btnadd:SetGravity(ui.LEFT, ui.TOP)
                    btnadd:SetOffset(20, 100)
                    local gbox = f:CreateOrGetControl("groupbox", "gbox", 10, 150, f:GetWidth() - 20, f:GetHeight() - 170)
                    AUTO_CAST(gbox)
                    gbox:RemoveAllChild()
                    gbox:EnableScrollBar(1)
                    self:generateList(false)
                    return self
                end,
                catch = function(error)
                    ERROUT(error)
                end
            }
        end,
        generateList = function(self, isappend)
            local f = self.f
            local gbox = f:GetChild("gbox")
            AUTO_CAST(gbox)
            if (not isappend) then
                gbox:RemoveAllChild()
                self.buffboxcount = 0
            else
                
                end
            local index = self.buffboxcount
            for k, v in pairs(g.settings.buffs) do
                local idx=k:match("buff_(.*)")
                local c = gbox:GetChild("buff_" .. tostring(idx))
                if not c then
                    self:generateBuffBox( v, idx,index)
                end
                index = index + 1
            end
        
        
        end,
        addBuffBox = function(self)
            self:generateBuffBox( {sound = ""}, 0, self.buffboxcount)
        
        end,
        generateBuffBox = function(self,  v,buffid, index)
            EBI_try_catch{
                try = function()
                    local f = self.f
                    local gbox = f:GetChild("gbox")
                    AUTO_CAST(gbox)
                    local cobox = gbox:CreateOrGetControl("groupbox", "buff_" .. tostring(index), 5, index * 100, gbox:GetWidth(), 100)
                    AUTO_CAST(cobox)
                    cobox:SetUserValue("index", index)
                    --buffid
                    local txtid = cobox:CreateOrGetControl("edit", "txtid", 10, 10, 100, 30)
                    AUTO_CAST(txtid)
                    txtid:SetText(tostring(buffid))
                    txtid:SetTypingScp("BUFFNOTIFIERCONFIG_ONCHANGEDBUFFID")
                    txtid:SetUserValue("index", index)
                    --buffico
                    local pic = cobox:CreateOrGetControl("picture", "pic", 120, 10, 30, 30)
                    AUTO_CAST(pic)
                    pic:SetEnableStretch(1)
                    --buffname
                    local name = cobox:CreateOrGetControl("richtext", "name", 10, 40, 100, 30)
                    --sound
                    local txtsound = cobox:CreateOrGetControl("edit", "txtsound", 160, 10, 200, 30)
                    txtsound:SetText(v.sound or "")
                    local cmbsound = cobox:CreateOrGetControl("droplist", "cmbsound", 160, 50, 200, 20)
                    AUTO_CAST(cmbsound)
                    cmbsound:SetSelectedScp("BUFFNOTIFIERCONFIG_ONSELECTEDSOUND")
                    cmbsound:SetSkinName("droplist_normal")
                    self:generateSoundList(cmbsound, txtsound:GetText())
                    -- apply
                    local btnapply = cobox:CreateOrGetControl("button", "btnapply", 10, 10, 60, 30)
                    
                    btnapply:SetEventScript(ui.LBUTTONUP, "BUFFNOTIFIERCONFIG_APPLYBUFF")
                    btnapply:SetText("{ol}Apply")
                    btnapply:SetEventScriptArgNumber(ui.LBUTTONUP, k)
                    btnapply:SetGravity(ui.RIGHT, ui.BOTTOM)
                    btnapply:SetOffset(30, 10)
                    local btndel = cobox:CreateOrGetControl("button", "btndel", 10, 50, 60, 30)
                    btndel:SetText("{ol}Delete")
                    btndel:SetEventScript(ui.LBUTTONUP, "BUFFNOTIFIERCONFIG_DELETEBUFF")
                    btndel:SetEventScriptArgNumber(ui.LBUTTONUP, k)
                    btndel:SetGravity(ui.RIGHT, ui.BOTTOM)
                    btndel:SetOffset(30, 50)
                    self:updateIconAndName(buffid,index)
                    self.buffboxcount = self.buffboxcount + 1
                end,
                catch = function(error)
                    ERROUT(error)
                end
            }
        end,
        
        updateIconAndName = function(self, buffid,index)
            local f = self.f
            local gbox = f:GetChild("gbox")
            AUTO_CAST(gbox)
            DBGOUT("" .. tostring(index))
            local cobox = gbox:GetChild("buff_" .. tostring(index))
            AUTO_CAST(cobox)
            local name = cobox:GetChild("name")
            local pic = cobox:GetChild("pic")
            local txtid = cobox:GetChild("txtid")
            AUTO_CAST(txtid)
            AUTO_CAST(name)
            AUTO_CAST(pic)
            local typeid = tonumber(txtid:GetText())
            local cls = GetClassByType("Buff", typeid)
            if (cls) then
                pic:SetImage(cls.Icon)
                name:SetText("{ol}" .. dictionary.ReplaceDicIDInCompStr(cls.Name))
            else
                pic:SetImage("None")
                name:SetText("")
            end
        
        end,
        generateSoundList = function(self, cmb, findstr)
            
            
            cmb:ClearItems()
            table.sort(BUFFNOTIFIER_SOUNDLIST)
            local i = 0
            local sel
            for _, v in pairs(BUFFNOTIFIER_SOUNDLIST) do
                if (not findstr or v:find(findstr)) then
                    cmb:AddItem(i, v)
                    if (findstr == v) then
                        sel = i
                    end
                    i = i + 1
                
                end
            end
            if sel then
                cmb:SelectItem(sel)
            end
        
        end,
        dispose = function(self)
            self.f:ShowWindow(0)
        end
    
    }

end
g = {
        
        framename = "buffnotifier",
        cframename = "buffnotifierconfig",
        confighandler = confighandler,
        debug = false,
        v = g.v or {
        
        },
        settings = g.settings or {
            buffs = {}-- [buffid]={sound="hogehoge"}
        
        },
        settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower),
        saveSettings = function(self)
            acutil.saveJSON(self.settingsFileLoc, self.settings)
        end,
        loadSettings = function(self)
            DBGOUT("LOAD_SETTING")
            self.settings = {foods = {}}
            local t, err = acutil.loadJSON(self.settingsFileLoc, self.settings)
            if err then
                --設定ファイル読み込み失敗時処理
                DBGOUT(string.format('[%s] cannot load setting files', addonName))
                self.settings = {
                    buffs = {}
                }
            else
                --設定ファイル読み込み成功時処理
                self.settings = t
                if (not self.settings.version) then
                    self.settings.version = 0
                
                end
            end
        
        end,
        onRemovedBuff = function(self, buffid)
            if self.settings.buffs["buff_"..buffid] then
                --play sound
                imcSound.PlaySoundEvent(self.settings.buffs["buff_"..buffid].sound)
            end
        end,
        newConfigWindow = function(self)
            local f = ui.GetFrame(g.cframename)
            
            local ch = confighandler.alloc():init()
            self.confighandler = ch
        end,
        disposeConfigWindow = function(self)
            if self.confighandler then
                self.confighandler:dispose()
                self.confighandler = nil
            end
            g:saveSettings()
            self.confighandler = nil
        end
}

--マップ読み込み時処理（1度だけ）
function BUFFNOTIFIER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            g:loadSettings()
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            
            addon:RegisterMsg('BUFF_REMOVE', 'BUFFNOTIFIER_BUFF_ON_MSG');
            acutil.slashCommand("/bn", BUFFNOTIFIER_PROCESS_COMMAND);
            acutil.slashCommand("/buffnotifier", BUFFNOTIFIER_PROCESS_COMMAND);
            
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function BUFFNOTIFIER_BUFF_ON_MSG(frame, msg, argStr, argNum)
    EBI_try_catch{
        try = function()
            local handle = session.GetMyHandle();
            if msg == "BUFF_REMOVE" then
                g:onRemovedBuff(argNum)
            end
        
        
        end,
        catch = function(error)
            ERROUT("FAIL:" .. tostring(error))
        end
    }
end
function BUFFNOTIFIER_PROCESS_COMMAND(command)
    EBI_try_catch{
        try = function()
            g:newConfigWindow()
        end,
        catch = function(error)
            ERROUT("FAIL:" .. tostring(error))
        end
    }
-- local cmd = "";
-- if #command > 0 then
--     cmd = table.remove(command, 1);
-- else
--     local msg = "usage{nl}/pf on 有効化{nl}/pf off 無効化"
--     return ui.MsgBox(msg, "", "Nope")
-- end
-- if cmd == "on" then
--     PSEUDOFORECAST_ENABLE = true
--     CHAT_SYSTEM("[PF]ENABLED")
-- end
-- if cmd == "off" then
--     PSEUDOFORECAST_ENABLE = false
--     CHAT_SYSTEM("[PF]DISABLED")
-- end
end
function BUFFNOTIFIERCONFIG_CLOSE(frame)
    g:disposeConfigWindow()

end
function BUFFNOTIFIERCONFIG_ONBTNADD(frame)
    g.confighandler:addBuffBox()
end
function BUFFNOTIFIERCONFIG_APPLYBUFF(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            local cobox = ctrl:GetParent()
            AUTO_CAST(cobox)
            local txtid = cobox:GetChild("txtid")
            local txtsound = cobox:GetChild("txtsound")
            
            local newid = tonumber(txtid:GetText())
            g.settings.buffs["buff_"..argnum] = nil
            g.settings.buffs["buff_"..newid] = {
                sound = txtsound:GetText()
            }
            g:saveSettings()
        end,
        catch = function(error)
            DBGOUT(error)
        end
    }
end
function BUFFNOTIFIERCONFIG_DELETEBUFF(frame, ctrl, argstr, argnum)
    g.settings.buffs[argnum] = nil
    g:saveSettings()
    g.confighandler:generateList(false)
end
function BUFFNOTIFIERCONFIG_ONCHANGEDBUFFID(frame, ctrl)
    EBI_try_catch{
        try = function()
            local cobox = ctrl:GetParent()
            AUTO_CAST(cobox)
            local txtid = cobox:GetChild("txtid")
            local index = ctrl:GetUserIValue("index")
            g.confighandler:updateIconAndName(index)
        end,
        catch = function(error)
            DBGOUT(error)
        end
    }
end

function BUFFNOTIFIERCONFIG_ONSELECTEDSOUND(frame, ctrl)
    EBI_try_catch{
        try = function()
            local cobox = ctrl:GetParent()
            AUTO_CAST(cobox)
            local index = cobox:GetUserValue("index")
            
            local txtsound = cobox:GetChild("txtsound")
            AUTO_CAST(ctrl)
            local selected = ctrl:GetSelItemCaption()
            txtsound:SetText(selected)
            imcSound.PlaySoundEvent(selected)
        --g.confighandler:updateIconAndName(index)
        end,
        catch = function(error)
            DBGOUT(error)
        end
    }
end
