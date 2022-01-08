--metaaddon_node_generic
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.cls = g.cls or {}
g.fn = g.fn or {}

g.fn.GetListOfNodeClasses = function()
    local list = {}
    for k, v in pairs(g.cls) do
        if (v():instanceOf(g.cls.MANode()) and v()._className ~= "MANode") then
            table.insert(list, k)
        end
    end
    return list
end

-- in1 number
-- in2 number
-- in3 number can be none
-- in4 number can be none
-- out1 number
g.cls.MACalculateNode = function(pos, size)
    local self = {
        _className = "MACalculateNode",
        _ops={
            "+",
            "-",
            "*",
            "/",
            "%",
            "or",
            "and",
            "^",
            "==",
            "~=",
            "<",
            ">",
            ">=",
            "<=",
        },
        _op="+",
        initImpl = function(self)
            self:addInlet(g.cls.MAAnyGate("a", self):init())
            self:addInlet(g.cls.MAAnyGate("b", self):init())
            self:addOutlet(g.cls.MAAnyGate("x", self):init())
        end,
        createEditor = function(self, addonlet, frame, gbox)
            gbox:CreateOrGetControl("richtext","rich",20,30,200,30):SetText("{ol}Operator:")
            
            local list=gbox:CreateOrGetControl("droplist","op",20,60,200,30)
            AUTO_CAST(list)
            list:SetSkinName("droplist_normal")
            for k, v in pairs(self._ops) do
                list:AddItem(k-1,v)
                if v==self._op then
                    list:SelectItem(k-1)
                end
            end
            
            return true
        end,
        confirmEditor = function(self, addonlet, frame, gbox)
            local list=gbox:GetChild("op")
            AUTO_CAST(list)
            local index=list:GetSelItemIndex()
            self._op=self._ops[index+1]
            return true
        end,
        render = function(self, addonlet, gbox, offset, zoom)
            local g=self._supers["MANode"].render(self, addonlet, gbox, offset, zoom)
            local richtext=g:CreateOrGetControl("richtext","rich",20*zoom,20*zoom,60*zoom,60*zoom)
            richtext:SetText("{@st43}"..self._op)
            richtext:EnableHitTest(0)
        end,
        compile = function(self, addonlet)
            return [[
                if args[1]==nil then
                    return nil
                end
                if args[2]==nil then
                    return nil
                end
                return (args[1]) ]]..self._op..[[ (args[2])
            ]]
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Calculate", pos, size))

    return obj
end
-- in1 data
g.cls.MAVariableSetNode = function(pos, size)
    local self = {
        _className = "MAVariableSetNode",
        _variableName="A",
        initImpl = function(self)
            self:addInlet(g.cls.MAAnyGate("data", self):init())
     
        end,
        createEditor = function(self, addonlet, frame, gbox)
            gbox:CreateOrGetControl("richtext","rich",20,30,200,30):SetText("{ol}Variable Name:")
            
            local edit=gbox:CreateOrGetControl("edit","name",20,60,200,30)
            AUTO_CAST(edit)
            edit:SetFontName("white_14_ol")
            edit:SetText(self._variableName)
            
            return true
        end,
        confirmEditor = function(self, addonlet, frame, gbox)
            local edit=gbox:GetChild("name")
            if edit:GetText()=="" then
                return false
            end
            self._variableName=edit:GetText() or "A"

            return true
        end,
        render = function(self, addonlet, gbox, offset, zoom)
            local g=self._supers["MANode"].render(self, addonlet, gbox, offset, zoom)
            local richtext=g:CreateOrGetControl("richtext","rich",20*zoom,20*zoom,60*zoom,60*zoom)
            richtext:SetText("{@st43}"..self._variableName)
            richtext:EnableHitTest(0)
        end,
        compile = function(self, addonlet)
            return [[
                variables[ ]]..self._variableName..[[ ] = args[1]
                return EMPTY
            ]]
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Var Set", pos, size))

    return obj
end
-- in1 data
g.cls.MAVariableGetNode = function(pos, size)
    local self = {
        _className = "MAVariableGetNode",
        _variableName="A",
        initImpl = function(self)
            self:addOutlet(g.cls.MAAnyGate("data", self):init())

        end,
        createEditor = function(self, addonlet, frame, gbox)
            gbox:CreateOrGetControl("richtext","rich",20,30,200,30):SetText("{ol}Variable Name:")
            
            local edit=gbox:CreateOrGetControl("edit","name",20,60,200,30)
            AUTO_CAST(edit)
            edit:SetFontName("white_14_ol")
            edit:SetText(self._variableName)
            
            return true
        end,
        confirmEditor = function(self, addonlet, frame, gbox)
            local edit=gbox:GetChild("name")
            if edit:GetText()=="" then
                return false
            end
            self._variableName=edit:GetText() or "A"

            return true
        end,
        render = function(self, addonlet, gbox, offset, zoom)
            local g=self._supers["MANode"].render(self, addonlet, gbox, offset, zoom)
            local richtext=g:CreateOrGetControl("richtext","rich",20*zoom,20*zoom,60*zoom,60*zoom)
            richtext:SetText("{@st43}"..self._variableName)
            richtext:EnableHitTest(0)
        end,
        compile = function(self, addonlet)
            return [[
                return variables[ ]]..self._variableName..[[ ]
            ]]
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Var Get", pos, size))

    return obj
end

-- in1 data
-- in2 condituon
-- in3 true
-- in4 false
-- out1 number
g.cls.MABooleanSwitchNode = function(pos, size)
    local self = {
        _className = "MABooleanSwitchNode",
        initImpl = function(self)
            self:addInlet(g.cls.MAAnyGate("in", self):init())
            self:addInlet(g.cls.MAPrimitiveGate("condition", self, "boolean"):init())

            self:addOutlet(g.cls.MAAnyGate("true", self):init())
            self:addOutlet(g.cls.MAAnyGate("false", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                if args[1]==nil then
                    CHAT_SYSTEM("arg1 is nil")
                    return nil,nil
                end
                if args[2]==nil then
                    CHAT_SYSTEM("arg2 is nil")
                    return nil,nil
                end
        
                if not args[2] then
                    return nil, args[1],EMPTY
                else
                    return args[1],nil,EMPTY
                end
            ]]
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MANode("BooleanSwitch", pos, size))

    return obj
end
-- in1 any
-- in2 number amount
-- out1 any
g.cls.MALatchNode = function(pos, size)
    local self = {
        _className = "MALatchNode",
        initImpl = function(self)
            self:addInlet(g.cls.MAAnyGate("in1", self):init())
            self:addInlet(g.cls.MAAnyGate("in2", self):init())
            self:addInlet(g.cls.MAAnyGate("in3", self):init())
            self:addInlet(g.cls.MAAnyGate("in4", self):init())
            self:addInlet(g.cls.MAFlowGate("latch", self):init())

            self:addOutlet(g.cls.MAAnyGate("out1", self):init())
            self:addOutlet(g.cls.MAAnyGate("out2", self):init())
            self:addOutlet(g.cls.MAAnyGate("out3", self):init())
            self:addOutlet(g.cls.MAAnyGate("out4", self):init())
        end,
        compile=function(self,addonlet)
            return [[return table.unpack(args,1,4)]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Latch", pos, size))

    return obj
end
-- in1 any
-- in2 number amount
-- out1 any
g.cls.MADelayNode = function(pos, size)
    local self = {
        _className = "MADelayNode",
        initImpl = function(self)
            self:addInlet(g.cls.MAAnyGate("in1", self):init())
            self:addInlet(g.cls.MAAnyGate("in2", self):init())
            self:addInlet(g.cls.MAAnyGate("in3", self):init())
            self:addInlet(g.cls.MAAnyGate("in4", self):init())
            self:addInlet(g.cls.MAPrimitiveGate("duration", self, "number"):init())
            self:addInlet(g.cls.MAFlowGate("latch", self):init())

            self:addOutlet(g.cls.MAAnyGate("out1", self):init())
            self:addOutlet(g.cls.MAAnyGate("out2", self):init())
            self:addOutlet(g.cls.MAAnyGate("out3", self):init())
            self:addOutlet(g.cls.MAAnyGate("out4", self):init())
        end,
        compile=function(self,addonlet)
            return [[
                local funcname="METAADDON_DELAY_]]..self:getID()..[["
                --pass=false
                --fired=false
                local e=_ENV

                _G[funcname]=function()
                    local _ENV=e
                    
                    pass=true
                end
      
                if not fired then
                    
                    ReserveScript("_G['"..funcname.."']()",tonumber(args[5]))
                    fired=true
                end
                if not pass then
                    keepInData()
                    return nil 
                else
                  
                    pass=false
                    fired=false
                    return table.unpack(args,1,4)
                end
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Delay", pos, size))

    return obj
end

-- out1 any
g.cls.MAConstantNode = function(pos, size)
    local self = {
        _comboList = {
            "variant",
            "boolean",
            "number",
            "string",
            "skill",
            "item",
            "pose"
        },
        _className = "MAConstantNode",
        supportType = "variant",
        value = 0,
        _outlet = nil,
        _prevSupportType = nil,
        initImpl = function(self)
            self._outlet = g.cls.MAVariantGate("out", self):init()
            self:addOutlet(self._outlet)
        end,
        createEditor = function(self, addonlet, frame, gbox)
            self._prevSupportType = self.supportType
            MACONSTANTNODE_RECREATE()

            return true
        end,
        confirmEditor = function(self, addonlet, frame, gbox)
            if self.supportType == "variant" or self.supportType == "string" or self.supportType == "number" then
                local text = gbox:GetChild("editconstant")
                AUTO_CAST(text)
                local text = text:GetText()
                if self.supportType == "number" then
                    self.value = tonumber(text)
                else
                    self.value = text
                end
            elseif self.supportType == "boolean" then
                local check = gbox:GetChild("checkconstant")
                AUTO_CAST(check)

                if check:IsChecked() == 1 then
                    self.value = true
                else
                    self.value = false
                end
            end
            if self.supportType ~= self._prevSupportType then
                self:removeOutlet(self._outlet)
                if self.supportType == "variant" then
                    self._outlet = g.cls.MAVariantGate("out", self):init()
                    self:addOutlet(self._outlet)
                elseif self.supportType == "string" then
                    self._outlet = g.cls.MAPrimitiveGate("out", self, "string"):init()
                    self:addOutlet(self._outlet)
                elseif self.supportType == "number" then
                    self._outlet = g.cls.MAPrimitiveGate("out", self, "number"):init()
                    self:addOutlet(self._outlet)
                elseif self.supportType == "boolean" then
                    self._outlet = g.cls.MAPrimitiveGate("out", self, "boolean"):init()
                    self:addOutlet(self._outlet)
                elseif self.supportType == "skill" then
                    self._outlet = g.cls.MASkillGate("out", self):init()
                    self:addOutlet(self._outlet)
                elseif self.supportType == "item" then
                    self._outlet = g.cls.MAItemGate("out", self):init()
                    self:addOutlet(self._outlet)
                elseif self.supportType == "pose" then
                    self._outlet = g.cls.MAPoseGate("out", self):init()
                    self:addOutlet(self._outlet)
                end
                self:sortGate()
            end

            return true
        end,
        compile = function(self, addonlet)
            if type(self.value) == "string" then

                local str=self.value
                --escape string
                str = string.gsub(str, "\\", "\\\\")
                str = string.gsub(str, "\"", "\\\"")
            

                return 'return "' .. str .. '"'
            else
                return "return " .. tostring(self.value)
            end
        end,
        render = function(self, addonlet, gbox, offset, zoom)
            local g=self._supers['MANode'].render(self, addonlet, gbox, offset, zoom)
            if self.supportType == "variant" or self.supportType == "string" or self.supportType == "number" or self.supportType == "boolean" then
                local text=g:CreateOrGetControl("richtext", "editconstant", 20*zoom, 20*zoom, 64*zoom, 32*zoom)
                text:SetText("{@st43}"..tostring(self.value))
                text:EnableHitTest(0)
            elseif self.supportType == "skill" then
                local pic=g:CreateOrGetControl("picture", "pic", 20*zoom, 20*zoom, 64*zoom, 64*zoom)
                AUTO_CAST(pic)
                pic:SetEnableStretch(1)
                local cls=GetClassByType("Skill", self.value)
                if cls then
                    pic:SetImage("icon_"..cls.Icon)
                end
               
                pic:EnableHitTest(0)
            elseif self.supportType == "item" then
                local pic=g:CreateOrGetControl("picture", "pic", 20*zoom, 20*zoom, 64*zoom, 64*zoom)
                AUTO_CAST(pic)
                pic:SetEnableStretch(1)
                local cls=GetClassByType("Item", self.value)
                if cls then
                    pic:SetImage(cls.Icon)
                end
               
                pic:EnableHitTest(0)
            elseif self.supportType == "pose" then
                local pic=g:CreateOrGetControl("picture", "pic", 20*zoom, 20*zoom, 64*zoom, 64*zoom)
                AUTO_CAST(pic)
                pic:SetEnableStretch(1)
                local cls=GetClassByType("Pose", self.value)
                if cls then
                    pic:SetImage(cls.Icon)
                end
               
                pic:EnableHitTest(0)
            end
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Constant", pos, size))

    return obj
end
function MACONSTANTNODE_SELECT_TYPE()
    g.fn.trycatch {
        try = function()
            local node = METAADDON_NODE_GETNODE()
            local gbox = METAADDON_NODE_GETGBOX()
            local types = gbox:GetChild("combotype")
            AUTO_CAST(types)
            local index = types:GetSelItemIndex() + 1
            node.supportType = node._comboList[index]
            MACONSTANTNODE_RECREATE()
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function MACONSTANTNODE_RECREATE()
    g.fn.trycatch {
        try = function()
            local node = METAADDON_NODE_GETNODE()
            local gbox = METAADDON_NODE_GETGBOX()
            gbox:RemoveAllChild()
            local types = gbox:CreateOrGetControl("droplist", "combotype", 10, 30, 200, 25)
            types:SetSkinName("droplist_normal")
            types:SetFontName("white_16_ol")
            AUTO_CAST(types)

            types:SetSelectedScp("MACONSTANTNODE_SELECT_TYPE")
            local num = 0
            for k, v in ipairs(g.cls.MAConstantNode()._comboList) do
                if v == node.supportType then
                    num = k
                end
                types:AddItem(k - 1, v)
            end

            types:SelectItem(num - 1)
            --types:SetEventScript(ui.LBUTTONUP, "MACONSTANTNODE_SELECT_TYPE")
            types:Invalidate()
            if node.supportType == "variant" or node.supportType == "string" or node.supportType == "number" then
                local text = gbox:CreateOrGetControl("edit", "editconstant", 50, 80, 300, 30)
                AUTO_CAST(text)
                text:SetText(node.value or "")
                text:SetFontName("white_16_ol")
            elseif node.supportType == "boolean" then
                local check = gbox:CreateOrGetControl("checkbox", "checkconstant", 50, 80, 300, 30)
                AUTO_CAST(check)
                if node.value == nil then
                    node.value = false
                end
                if node.value == true then
                    check:SetCheck(1)
                else
                    check:SetCheck(0)
                end
            elseif node.supportType == "item" or node.supportType == "skill" or node.supportType == "pose" then
                local slot = gbox:CreateOrGetControl("slot", "checkconstant", 60, 80, 128, 128)
                AUTO_CAST(slot)
                slot:SetSkinName("slot")
                slot:EnableDrop(1)
                slot:SetEventScript(ui.DROP, 'MACONSTANTNODE_ON_DROPSLOT')
                if node.value then
                    local icon = CreateIcon(slot)
                    if node.supportType == "item" then
                        local pose = GetClassByType("Item", node.value)
                        if pose then
                            icon:Set(pose.Icon)
                            icon:SetColorTone("FFFFFFFF")
                            icon:SetTextTooltip(pose.Name)
                        end
                    elseif node.supportType == "skill" then
                        local pose = GetClassByType("Skill", node.value)
                        if pose then
                            icon:Set("icon_"..pose.Icon)
                            icon:SetColorTone("FFFFFFFF")
                            icon:SetTextTooltip(pose.Name)
                        end
                    elseif node.supportType == "pose" then
                        local pose = GetClassByType("Pose", node.value)
                        if pose then
                            icon:Set(pose.Icon)
                            icon:SetColorTone("FFFFFFFF")
                            icon:SetTextTooltip(pose.Name)
                        end
                    end
                end
            end
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function MACONSTANTNODE_ON_DROPSLOT()

    local node = METAADDON_NODE_GETNODE()
    local gbox = METAADDON_NODE_GETGBOX()
    local liftIcon = ui.GetLiftIcon()
    local info = liftIcon:GetInfo()
    local clsid=info.type
    node.value = clsid
    MACONSTANTNODE_RECREATE()
end

-- out1 any
g.cls.MAGameStart3SecNode = function(pos, size)
    local self = {
        _className = "MAGameStart3SecNode",
        initImpl = function(self)
            self:addOutlet(g.cls.MAFlowGate("flow", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                if getFlags(MF_GAME_START_3SEC) then
                    return EMPTY
                else
                    return nil
                end
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("GameStart3Sec", pos, size))

    return obj
end
-- out1 any
g.cls.MAAlwaysNode = function(pos, size)
    local self = {
        _className = "MAEvery1SecNode",
        initImpl = function(self)
            self:addOutlet(g.cls.MAFlowGate("flow", self):init())
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Always", pos, size))

    return obj
end

-- out1 any
g.cls.MAFpsUpdateNode = function(pos, size)
    local self = {
        _className = "MAFpsUpdateNode",
        initImpl = function(self)
            self:addOutlet(g.cls.MAFlowGate("flow", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                if getFlags(MF_FPS_UPDATE) then
                   
                    return EMPTY
                else
                    return nil
                end
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("FPS_UPDATE", pos, size))

    return obj
end

-- out1 any
g.cls.MADebugOutputNode = function(pos, size)
    local self = {
        _className = "MADebugOutputNode",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addInlet(g.cls.MAPrimitiveGate("message", self, "string"):init())
        end,
        compile = function(self, addonlet)
            return [[
                CHAT_SYSTEM(""..tostring(args[1]) or "(input is nil)")
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("DebugOutput", pos, size))

    return obj
end
g.cls.MADebugPrintNode = function(pos, size)
    local self = {
        _className = "MADebugPrintNode",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addInlet(g.cls.MAPrimitiveGate("message", self, "string"):init())
        end,
        compile = function(self, addonlet)
            return [[
                print(tostring(args[1]))
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("DebugOutput", pos, size))

    return obj
end
-- out1 any
g.cls.MAEvalLuaNode = function(pos, size)
    local self = {
        _className = "MAEvalLuaNode",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addInlet(g.cls.MAPrimitiveGate("lua", self, "string"):init())
            self:addInlet(g.cls.MAAnyGate("arg", self):init())
            self:addOutlet(g.cls.MAAnyGate("return", self):init())
            
        end,
        compile = function(self, addonlet)
            return [[
                if args[1]==nil then return end
                local fn=load(args[1],nil,"t",_ENV)
                if fn then
                    local ok,ret=pcall(fn,args[2])
                    if ok then
                        return ret
                    else
                        return ret
                    end
                end
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("MAEvalLuaNode", pos, size))

    return obj
end
-- out1 any
g.cls.MAKeyInputNode = function(pos, size)
    local self = {
        _className = "MAKeyInputNode",
        _isJoyStick=false,
        _key="",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addOutlet(g.cls.MAFlowGate("flow", self):init())
            
        end,
        compile = function(self, addonlet)
            if self._isJoyStick then
                return [[
                    if joystick.IsKeyPressed(']]..self._key..[[')==1 then
                        return EMPTY
                    end
                ]]
            else
                return [[
                    if keyboard.IsKeyPressed(']]..self._key..[[')==1 then
                        return EMPTY
                    end
                ]]
            end
        end,
        createEditor = function(self, addonlet, frame, gbox)
            local check=gbox:CreateOrGetControl("checkbox","joy",20,30,200,30)
            AUTO_CAST(check)
            check:SetText("{ol}JoyStickMode")
            if self._isJoyStick then
                check:SetCheck(1)
            else
                check:SetCheck(0)
            end
            local btn=gbox:CreateOrGetControl("button","judge",20,60,200,30)
            AUTO_CAST(btn)
            btn:SetFontName("white_14_ol")
            btn:SetText(self._key)
            btn:SetEventScript(ui.LBUTTONUP,"MAKEYINPUTNODE_JUDGE_BTN_CLICK")
            return true
        end,
        confirmEditor = function(self, addonlet, frame, gbox)
            local check=gbox:GetChild("joy")
            AUTO_CAST(check)
            if check:IsChecked()==1 then
                self._isJoyStick=true
            else
                self._isJoyStick=false
            end
            
            return true
        end,
        render = function(self, addonlet, gbox, offset, zoom)
            local g=self._supers["MANode"].render(self, addonlet, gbox, offset, zoom)
            local richtext=g:CreateOrGetControl("richtext","rich",20*zoom,20*zoom,60*zoom,60*zoom)
            richtext:SetText("{@st42b}"..self._key)
            richtext:EnableHitTest(0)
        end,
    }
    local obj = g.fn.inherit(self, g.cls.MANode("MAKeyInputNode", pos, size))

    return obj
end

function MAKEYINPUTNODE_JUDGE_BTN_CLICK()
    local node=METAADDON_NODE_GETNODE()
    local gbox=METAADDON_NODE_GETGBOX()
    local btn=gbox:GetChild("judge")
    btn:SetText("{ol}...")
    btn:RunUpdateScript("MAKEYINPUTNODE_JUDGE_BTN_CLICK_UPDATE")
end
function MAKEYINPUTNODE_JUDGE_BTN_CLICK_UPDATE()
    local node=METAADDON_NODE_GETNODE()
    local gbox=METAADDON_NODE_GETGBOX()
    local btn=gbox:GetChild("judge")
    local downkey;
    
    downkey=joystick.GetDownJoyStickBtn();
 

    if downkey~="" then
        btn:SetText("{ol}"..downkey)
        node._key=downkey
        btn:StopUpdateScript("MAKEYINPUTNODE_JUDGE_BTN_CLICK_UPDATE")
        return
    end
    downkey = keyboard.GetDownKey();
    if downkey~="" then
        btn:SetText("{ol}"..downkey)
        node._key=downkey
        btn:StopUpdateScript("MAKEYINPUTNODE_JUDGE_BTN_CLICK_UPDATE")
        return
    end
    btn:RunUpdateScript("MAKEYINPUTNODE_JUDGE_BTN_CLICK_UPDATE")
end
