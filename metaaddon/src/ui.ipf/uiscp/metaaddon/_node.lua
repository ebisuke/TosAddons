--metaaddon_node
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
g.cls.MANodeBase = function(name)
    local self = {
        _className = "MANodeBase",
        _name = name,
        _selectable = false,
        _pos = {x = 0, y = 0},
        _temporary = false,

        getPos = function(self)
            return self._pos
        end,
        setPos = function(self, x, y)
            self._pos.x = x
            self._pos.y = y
        end,
        hitTestBox = function(self, left, top, right, bottom)
            return left <= self:getPos().x and right >= self:getPos().x and top <= self:getPos().y and
                bottom >= self:getPos().y
        end,
        render = function(self, addonlet, gbox, offset, zoom)
        end,
        createEditor = function(self, addonlet, frame, gbox)
            return false
        end,
        confirmEditor = function(self, addonlet, frame, gbox)
            return false
        end,
        calculateBoundingBox = function(self)
            return {left = self._pos.x, top = self._pos.y, right = self._pos.x, bottom = self._pos.y}
        end,
        isSelected = function(self, addonlet)
            return addonlet:isSelected(self)
        end,
        isTemporary = function(self)
            return self._temporary
        end,
        assignImpl = function(self, obj)
            self._supers["MASerializable"].assignImpl(self, obj)
            self._name = obj._name
            self._pos = obj._pos
            self._payload = obj._payload
            self._pos = obj._pos
            self._temporary = obj._temporary
        end,
        compile = function(self, addonlet)
            return ""
        end
    }
    local obj = g.fn.inherit(self, g.cls.MASerializable())

    return obj
end

g.cls.MANode = function(name, pos, size)
    local self = {
        _className = "MANode",
        _selectable = true,
        _inlets = {},
        _outlets = {},
        _pos = pos or {x = 0, y = 0},
        _size = size or {w = 0, h = 0},
        _parent = nil,
        _children = {},
        addInlet = function(self, inlet)
            self._inlets[#self._inlets + 1] = inlet
            inlet.ownerNode = self
            self:addChild(inlet)
        end,
        addOutlet = function(self, outlet)
            self._outlets[#self._outlets + 1] = outlet
            outlet.ownerNode = self
            self:addChild(outlet)
        end,
        removeInlet = function(self, inlet)
            for i, v in ipairs(self._inlets) do
                if v:getID() == inlet:getID() then
                    table.remove(self._inlets, i)
                    break
                end
            end
            self:removeChild(inlet)
            inlet:release()
        end,
        removeOutlet = function(self, outlet)
            for i, v in ipairs(self._outlets) do
                if v:getID() == outlet:getID() then
                    table.remove(self._outlets, i)
                    break
                end
            end
            self:removeChild(outlet)
            outlet:release()
        end,
        addChild = function(self, node)
            self._children[#self._children + 1] = node
        end,
        getChildren = function(self)
            return self._children
        end,
        getParent = function(self)
            return self._parent
        end,
        getInlets = function(self)
            return self._inlets
        end,
        getOutlets = function(self)
            return self._outlets
        end,
        removeChild = function(self, child)
            for i, v in ipairs(self._children) do
                if v:getID() == child:getID() then
                    table.remove(self._children, i)
                    break
                end
            end
        end,
        setParent = function(self, parent)
            if parent and parent:getChildren()[self:getID()] then
                parent:removeChild(self)
            end
            self._parent = parent
        end,
        getName = function(self)
            return self._name
        end,
        getRect = function(self)
            return {
                x = self._pos.x,
                y = self._pos.y,
                w = self._size.w,
                h = self._size.h
            }
        end,
        setPos = function(self, x, y)
            local diffx = x - self._pos.x
            local diffy = y - self._pos.y

            self._pos.x = x
            self._pos.y = y
            for i, v in ipairs(self._children) do
                v:setPos(v:getPos().x + diffx, v:getPos().y + diffy)
            end
            self:notifyMoveToGates()
        end,
        setRect = function(self, x, y, w, h)
            local diffx = x - self._pos.x
            local diffy = y - self._pos.y

            self._pos.x = x
            self._pos.y = y
            for i, v in ipairs(self._children) do
                v:setPos(v:getPos().x + diffx, v:getPos().y + diffy)
            end
            self._size.w = w
            self._size.h = h
            self:notifyMoveToGates()
        end,
        hitTestBox = function(self, left, top, right, bottom)
            local rect = self:getRect()

            return right >= rect.x and left <= rect.x + rect.w and bottom >= rect.y and top <= rect.y + rect.h
        end,
        calculateBoundingBox = function(self)
            return {
                left = self._pos.x,
                top = self._pos.y,
                right = self._pos.x + self._size.w,
                bottom = self._pos.y + self._size.h
            }
        end,
        render = function(self, addonlet, gbox, offset, zoom)
            local g =
                gbox:CreateOrGetControl(
                "groupbox",
                "gbox_" .. self._id,
                self._pos.x * zoom + offset.x,
                self._pos.y * zoom + offset.y,
                self._size.w * zoom,
                self._size.h * zoom
            )
            AUTO_CAST(g)
            g:SetSkinName("bg2")
            g:EnableHitTest(0)
            if self:isSelected(addonlet) then
                g:SetColorTone("FF0000FF")
            end
            local p = g:CreateOrGetControl("picture", "icon", 0, 0, self._size.w * zoom, self._size.h * zoom)
            AUTO_CAST(p)
            p:SetEnableStretch(1)
            p:EnableHitTest(0)
            local txt = g:CreateOrGetControl("richtext", "text", 0, 0, self._size.w * zoom, 24)
            AUTO_CAST(txt)
            txt:EnableHitTest(0)
            txt:SetText("{ol}" .. self._name)
            for i, v in ipairs(self:getInlets()) do
                v:render(addonlet, gbox, offset, zoom)
            end
            for i, v in ipairs(self:getOutlets()) do
                v:render(addonlet, gbox, offset, zoom)
            end

            return g
        end,
        sortGate = function(self, gate)
            for i, v in ipairs(self:getInlets()) do
                v:setPos(self:getRect().x - 8, self:getRect().y + self:getRect().h * (i) / (#self:getInlets() + 1))
            end
            for i, v in ipairs(self:getOutlets()) do
                v:setPos(
                    self:getRect().x + self:getRect().w + 8,
                    self:getRect().y + self:getRect().h * (i) / (#self:getOutlets() + 1)
                )
            end
        end,
        notifyMoveToGates = function(self)
            for i, v in ipairs(self:getInlets()) do
                v:onMove()
            end
            for i, v in ipairs(self:getOutlets()) do
                v:onMove()
            end
        end,
        lazyInitImpl = function(self)
            self:sortGate()
        end,
        assignImpl = function(self, obj)
            self._supers["MANodeBase"].assignImpl(self, obj)
            self._name = obj._name
            self._pos = obj._pos
            self._size = obj._size
            self._parent = obj._parent

            for i, v in ipairs(obj._inlets) do
                self:addInlet(v:clone())
            end
            for i, v in ipairs(obj._outlets) do
                self:addOutlet(v:clone())
            end
        end,
        releaseImpl = function(self)
            for i, v in ipairs(self:getInlets()) do
                v:release()
            end
            for i, v in ipairs(self:getOutlets()) do
                v:release()
            end
            self._inlets = {}
            self._outlets = {}
            self._children = {}
            self._parent = nil
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANodeBase(name))

    return obj
end

g.cls.MADependencyBaseNode = function(pos, size, dependsOn)
    local self = {
        _className = "MADependencyNode",
        _dependsOn = nil,
        getDependency = function(self)
            return self._dependsOn
        end,
        initImpl = function(self)
            if self._dependsOn == nil then
                self._dependsOn = self:getID()
            end
        end,
        createEditor = function(self, addonlet, frame, gbox)
            METAADDON_EDITOR_LOADFILEORNEW("_" .. self._dependsOn, "(nodelet)")

            return false
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("MADependencyBaseNode", pos, size))

    return obj
end

g.cls.MAPackNode = function(pos, size)
    local self = {
        _className = "MAPackNode",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addInlet(g.cls.MAAnyGate("in1", self):init())
            self:addInlet(g.cls.MAAnyGate("in2", self):init())
            self:addInlet(g.cls.MAAnyGate("in3", self):init())
            self:addInlet(g.cls.MAAnyGate("in4", self):init())
            self:addOutlet(g.cls.MATableGate("out", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                return args
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("MAPackNode", pos, size))

    return obj
end
g.cls.MAUnpackNode = function(pos, size)
    local self = {
        _className = "MAUnpackNode",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addInlet(g.cls.MATableGate("in", self):init())

            self:addOutlet(g.cls.MAAnyGate("out1", self):init())
            self:addOutlet(g.cls.MAAnyGate("out2", self):init())
            self:addOutlet(g.cls.MAAnyGate("out3", self):init())
            self:addOutlet(g.cls.MAAnyGate("out4", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                if args[1]==nil then
                    return nil
                end
                return table.unpack(args[1])
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("MAUnpackNode", pos, size))

    return obj
end
g.cls.MAForeachNode = function(pos, size)
    local self = {
        _className = "MAForeachNode",
        _name = "Foreach",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addInlet(g.cls.MATableGate("table", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                local id=']] ..
                self:getID() ..
                    [['
                local deps=METAADDON_CONTEXT[']] ..
                        self.dependsOn ..
                            [[']
                for k,v in pairs(args[1]) do
                    deps.indata=v
                    deps.fn()
                end
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MADependencyBaseNode(pos, size))

    return obj
end
g.cls.MASubroutineNode = function(pos, size)
    local self = {
        _className = "MASubroutineNode",
        _name = "Subroutine",
        initImpl = function(self)
            --self:addInlet( g.cls.MAPrimitiveGate("text", self,"string"):init())
            self:addInlet(g.cls.MAAnyGate("in", self):init())
            self:addOutlet(g.cls.MAAnyGate("out", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                local deps=METAADDON_CONTEXT[']] ..
                self.dependsOn ..
                    [[']
                if deps == nil then
                    return nil
                end
                deps.indata=args[1]
                deps.fn()
                if deps.outdata then
                    local data=deps.outdata
                    deps.outdata=nil
                    return data
                end
                return nil
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MADependencyBaseNode(pos, size))

    return obj
end
g.cls.MAStartNode = function(pos, size)
    local self = {
        _className = "MAStartNode",
        initImpl = function(self)
            self:addOutlet(g.cls.MAAnyGate("out", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                if indata then
                    local indatatemp=indata
                    indata=nil
                    return indatatemp
                end
                
                return nil
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("MAStartNode", pos, size))
    return obj
end
g.cls.MAEndNode = function(pos, size)
    local self = {
        _className = "MAEndNode",
        initImpl = function(self)
            self:addInlet(g.cls.MAAnyGate("out", self):init())
        end,
        compile = function(self, addonlet)
            return [[
                if args[1]==nil then
                    return nil
                end
                outdata=args[1]
                return EMPTY
            ]]
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("MAEndNode", pos, size))

    return obj
end

g.cls.MALoadAddonletNode = function(pos, size)
    local self = {
        _className = "MALoadAddonletNode",
        _name = "LoadAddonlet",
        initImpl = function(self)
        end,
        lazyInitImpl = function(self)
            self._dependsOn = ""
        end,
        createEditor = function(self, addonlet, frame, gbox)
            local edit = gbox:CreateOrGetControl("edit", "edit", 20, 40, 400, 32)
            AUTO_CAST(edit)
            edit:SetText(self._dependsOn or "")
            local btn = gbox:CreateOrGetControl("button", "button", 420, 40, 40, 32)
            AUTO_CAST(btn)
            btn:SetText("...")
            edit:SetFontName("white_16_ol")
            btn:SetEventScript(ui.LBUTTONUP, "MALOADADDONLET_BTN_CLICK")
            return true
        end,
        confirmEditor = function(self, addonlet, frame, gbox)
            local edit = gbox:GetChild("edit")
            AUTO_CAST(edit)
            self._dependsOn = edit:GetText()
            return true
        end
    }
    local obj = g.fn.inherit(self, g.cls.MADependencyBaseNode(pos, size))

    return obj
end

function MALOADADDONLET_BTN_CLICK()
    local gbox = METAADDON_NODE_GETGBOX()
    local node = METAADDON_NODE_GETNODE()
    local context = ui.CreateContextMenu("CONTEXT_METAADDON_EDITOR_LOAD", "Reference", 0, 0, 300, 200)
    for k, v in ipairs(g.settings.fileList) do
        ui.AddContextMenuItem(context, v, "MALOADADDONLET_SELECT('" .. v .. "')")
    end
    ui.OpenContextMenu(context)
end

function MALOADADDONLET_SELECT(name)
    g.fn.trycatch {
        try = function()
            local gbox = METAADDON_NODE_GETGBOX()
            local node = METAADDON_NODE_GETNODE()

            local edit = gbox:GetChild("edit")
            AUTO_CAST(edit)
            edit:SetText("")
            edit:SetText(name)
            
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
