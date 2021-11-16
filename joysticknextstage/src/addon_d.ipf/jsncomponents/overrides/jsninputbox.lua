--jsninputbox.lua
--アドオン名（大文字）
local addonName = "jsn_commonlib"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
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
g.classes=g.classes or {}

g.classes.JSNInputboxBase=function (jsnmanager)
    local self={
        _className="JSNInputboxBase",
        _digitCursor=1,
        _arrows={},
        getNativeInput=function (self)
            local frame=self:getNativeFrame()
            local input=frame:GetChildRecursively("input")
            AUTO_CAST(input)
            return input
        end,
        setValue=function (self,value)
            local input=self:getNativeInput()
            input:SetText(tostring(value))
            input:AcquireFocus();
        end,
        getValue=function (self)
            local input=self:getNativeInput()
            return math.max(self:getMinValue(),math.min(self:getMaxValue(),tonumber(input:GetText()))) or self:getMinValue()
        end,
        getMaxValue=function (self)
            if(self:getNativeInput():GetMaxNumber()==0) then
                return 9999999999
            end
            return self:getNativeInput():GetMaxNumber() or 9999999999
        end,
        getMinValue=function (self)
            return self:getNativeInput():GetMinNumber() or 0
        end,
        getDigits=function (self)
            --DBGOUT("getDigits"..math.max(math.floor(math.log(self:getMaxValue(),10)),math.floor(math.log(self:getMinValue(),10)),0))
            local digit= math.max(
                math.ceil(math.log(self:getMaxValue(),10)),
                math.ceil(math.log(self:getMinValue(),10)))

            return digit
        end,
        preInitImpl=function (self)
            local frame=ui.GetFrame("inputstring")
            self:setNativeFrame(frame)
            frame:SetLayerLevel(120)
            
        end,
        initImpl=function(self)
            self._arrows={}
            local frame=ui.GetFrame("inputstring")
            
            local input=frame:GetChildRecursively("input")
            AUTO_CAST(input)
            input:ShowWindow(1)
            input:SetTextAlign("right","center")
            self:focus()
            for i=-1,10 do
                frame:RemoveChild("uparrow_"..i)
                frame:RemoveChild("downarrow_"..i)
                
            end
            --frame:RemoveChild("slider")
                
            if(self:getDigits()<1)then
                return
            end
            for i=1,self:getDigits() do
                local w,h=18,18
                local x=input:GetX()+input:GetWidth()-i*w
                local uy=input:GetY()-h
                local dy=input:GetY()+input:GetHeight()

                -- upper arrow
                local uparrow=frame:CreateOrGetControl("picture", "uparrow_"..i, x, uy, w, h)
                AUTO_CAST(uparrow)
                uparrow:SetImage("guild_arrow_up")
                uparrow:SetEnableStretch(1)
                uparrow:EnableHitTest(0)
                --down arropw 
                local downarrow=frame:CreateOrGetControl("picture", "downarrow_"..i, x, dy, w, h)
                AUTO_CAST(downarrow)
                downarrow:SetImage("guild_arrow_down")
                downarrow:SetEnableStretch(1)
                downarrow:EnableHitTest(0)
                self._arrows[#self._arrows+1]={
                    up=uparrow,
                    down=downarrow,
                }
            end
        end,
        lazyInitImpl=function(self)
           
            self:updateCursor()
        end,
    
        updateCursor=function(self)
            local input=self:getNativeInput()
            local uparrow=self._arrows[self._digitCursor].up
            local downarrow=self._arrows[self._digitCursor].down
            if(uparrow and downarrow) then
                local rect={
                    x=uparrow:GetX(),
                    y=uparrow:GetY(),
                    w=uparrow:GetWidth(),
                    h=uparrow:GetHeight()+downarrow:GetHeight()+downarrow:GetY()-uparrow:GetY(),
                }
                self:setCursorRect(rect)
                for i=1,self:getDigits() do
                    local up=self._arrows[i].up
                    local down=self._arrows[i].down
                    if(i==self._digitCursor) then
                        if up:IsBlinking() == 1 then
							up:ReleaseBlink();
						end
                        if down:IsBlinking() == 1 then
							down:ReleaseBlink();
						end
                        up:SetBlink(0,2, '0xFF000000');
                        down:SetBlink(0, 2, '0xFF000000');
                    else
                        if up:IsBlinking() == 1 then
							up:ReleaseBlink();
						end
                        if down:IsBlinking() == 1 then
							down:ReleaseBlink();
						end
                    end
                    
                end
            end
        end,
        onKeyRepeatImpl=function(self,key)
            local frame=self:getNativeFrame()
            if(key==g.classes.JSNKey.RIGHT)then
                self._digitCursor=self._digitCursor-1
                if(self._digitCursor<=0)then
                    self._digitCursor=self:getDigits()
                end
                self:updateCursor()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.LEFT)then
                self._digitCursor=self._digitCursor+1
                if(self._digitCursor>=self:getDigits())then
                    self._digitCursor=1
                end
                self:updateCursor()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.UP)then
                local value=self:getValue()
                local digitValue=math.floor((value/(10^(self._digitCursor-1)))%(10))
                if(digitValue<9)then
                    value=value+(1)*(10^(self._digitCursor-1))
                else
                    value=value-digitValue*(10^(self._digitCursor-1))
                end
                self:setValue(value)
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.DOWN)then
                local value=self:getValue()
                local digitValue=math.floor((value/(10^(self._digitCursor-1)))%(10))
                if(digitValue>0)then
                    value=value-(1)*(10^(self._digitCursor-1))
                else
                    value=value-digitValue*(10^(self._digitCursor-1))
                    value=value+(9)*(10^(self._digitCursor-1))
                end
                self:setValue(value)
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.CANCEL or key==g.classes.JSNKey.CLOSE)then
                self:getNativeFrame():ShowWindow(0)
                self:release()
                return true
            end
            if(key==g.classes.JSNKey.MAIN )then
                local input=self:getNativeInput()
                local func=input:GetEventScript(ui.ENTERKEY)
                local argnum=input:GetTopParentFrame():GetValue()
                local argstr=input:GetTopParentFrame():GetUserValue("ArgString")
                local fromFrameName = frame:GetUserValue("FROM_FR");	
                local strscp=input:GetTopParentFrame():GetSValue()
                
               
                if(_G[strscp])then
                    
                    DBGOUT(strscp.."("..tostring(argstr)..")")
                    _G[strscp](self:getNativeFrame(),nil,argstr,argnum)
                    if fromFrameName == "NULL" then
                        execScp(resultString, frame);
                    else
                        local fromFrame = ui.GetFrame(fromFrameName);
                        execScp(fromFrame, resultString, frame);
                    end
                else
                    ERROUT("no function."..func)
                    end
                self:getNativeFrame():ShowWindow(0)
                self:release()
                return true
            end
        end,
    }
    local obj=g.inherit(self,
    g.classes.JSNKeyHandler(jsnmanager),
    g.classes.JSNGenericEventHandler(jsnmanager),
    g.classes.JSNFrameBase(jsnmanager),
    g.classes.JSNFocusable(jsnmanager,self))
    return obj
end

g.classes.JSNInputbox=function (jsnmanager,owner,title,default,min,max,callback)
    local self={
        _className="JSNInputbox",
       
        preInitImpl=function (self)
            g.callbackFunctionTable[tostring(callback)]=function(frame,ctrl,argstr,argnum)
                self:release()
                callback(frame,ctrl,argstr,argnum)
            end
            INPUT_NUMBER_BOX(nil, title, "JSN_COMMONLIB_CTRL_CALLBACK_FUNCTION", default, min, max, nil, tostring(callback), 1);
            g.fn.MarkAsDontOverride(ui.GetFrame("inputstring"))
        end,
        releaseImpl=function (self)
            g.callbackFunctionTable[tostring(callback)]=nil
            g.fn.MarkAsDontOverride(ui.GetFrame("inputstring"),true)
        end,
    }
    local obj=g.inherit(self,g.classes.JSNInputboxBase(jsnmanager),g.classes.JSNOwnerRelation(owner))
    return obj
end

g.classes.JSNInputboxOverrider=function ()
    local self={
        _className="JSNInputboxOverrider",
        initImpl=function (self)
            if g.fn.IsDontOverride(ui.GetFrame("inputstring")) then
                return
            end
        end
    }
    local obj=g.inherit(self,
    g.classes.JSNOverriderBase(g.jsnmanager,ui.GetFrame('inputstring')),
    g.classes.JSNInputboxBase(g.jsnmanager))
    return obj
end

