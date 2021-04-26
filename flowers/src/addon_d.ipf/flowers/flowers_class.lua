--flowers! class
local addonName = "flowers"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
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


g.classes = {
    TBase = {
        new = function()
            local obj = {
                enabled = false,
                uuid = g.func.uuid(),
                variables = {},
            }
            obj.is = function(self)
                return "TFlowerBase"
            end
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end
    },
    TFlowerBase = {
        
        new = function(name)
            local obj = {}
            obj.fixedaction = {}
            obj.triggers = {}
            obj.actions = {}
            obj.frame = g.classes.TFrame.new()
            obj.name = name or "noname"
            obj.guid = g.func.uuid()
            obj.is = function(self)
                return "TFlowerBase"
            end
            setmetatable(obj, {__index = g.classes.TBase})
            
            return obj
        end
    },
    TFlower = {
        
        new = function(name)
            local obj = {}
            obj.fixedaction = {
                g.classes.TAction.Actions.Frame.SetFrame(obj)
            }
            obj.flower = obj
            obj.name = name or "noname"
            obj.guid = g.func.uuid()
            obj.variablepool = g.classes.TVariablePool.new()
            obj.frame = g.classes.TFrame.new(obj.name)
            obj.is = function(self)
                return "TFlower"
            end
            setmetatable(obj, {__index = g.classes.TFlowerBase})
            
            return obj
        end
    },
    TFrame = {
        new = function(framename)
            
            local obj = {}
            obj.framename = framename
            
            obj.is = function(self)
                return "TFrame"
            end
            setmetatable(obj, {__index = g.classes.TBase})
            
            return obj
        end
    },
    TPetal = {
        new = function(flower, parent)
            local obj = {}
            obj.flower = flower
            obj.parent = parent
            obj.contents = {}
            
            obj.variablepool = g.classes.TVariablePool.new(obj)
            obj.uuid = g.func.uuid()
            obj.is = function(self)
                return "TPetal"
            end
            setmetatable(obj, {__index = g.classes.TFlowerBase})
            return obj
        end
    },
    TContent = {
        new = function()
            local obj = {}
            obj.is = function(self)
                return "TContent"
            end
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end
    },
    TCondition = {
        new = function(owner)
            local obj = {}
            obj.owner = owner
            obj.inout = g.classes.TInOut.new(owner, {
                g.classes.TIn.new("lhs", "LHS", "variant", nil, nil),
                g.classes.TIn.new("rhs", "RHS", "variant", nil, nil),
            })
            obj.comparator = nil;
            obj.is = function(self)
                return "TCondition"
            end
            obj.GetLHS = function(self)
                return self.inout.ins["lhs"]
            end
            obj.GetRHS = function(self)
                return self.inout.ins["rhs"]
            end
            obj.GetValue = function(self)
                return obj.comparator(obj.GetLHS():GetValue(), obj.GetRHS():GetValue())
            end
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end
    },
    
    TComparator = {
        new = function(name, text, func)
            local obj = {}
            obj.name = name
            obj.text = text
            obj.compare = func
            obj.is = function(self)
                return "TComparator"
            end
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end,
        Comparators = {
            function()
                return g.classes.TComparator.new("Equal", "==", function(a, b) return a == b end)
            end,
            function()
                return g.classes.TComparator.new("NotEqual", "~=", function(a, b) return a ~= b end)
            end,
            function()
                return g.classes.TComparator.new("GreaterThan", ">", function(a, b) return a > b end)
            end,
            function()
                return g.classes.TComparator.new("LessThan", "<", function(a, b) return a < b end)
            end,
            function()
                return g.classes.TComparator.new("GreaterThanEqual", "<=", function(a, b) return a <= b end)
            end,
            function()
                return g.classes.TComparator.new("LessThanEqual", ">=", function(a, b) return a >= b end)
            end,
            function()
                return g.classes.TComparator.new("And", "And", function(a, b) return a and b end)
            end,
            function()
                return g.classes.TComparator.new("Or", "Or", function(a, b) return a or b end)
            end,
            function()
                return g.classes.TComparator.new("LHS", "LHS", function(a, b) return a end)
            end,
            function()
                return g.classes.TComparator.new("RHS", "RHS", function(a, b) return b end)
            end,
            function()
                return g.classes.TComparator.new("False", "False", function(a, b) return false end)
            end,
            function()
                return g.classes.TComparator.new("True", "True", function(a, b) return true end)
            end
        }
    },
    
    TAction = {
        new = function(owner, name, description, inout, executor)
            local obj = {}
            obj.owner = owner
            obj.name = name
            obj.description = description
            
            obj.inout = inout
            obj.is = function(self)
                return "TAction"
            end
            obj.executor = executor
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end,
        Actions = {
            Frame = {
                SetFrame = function(owner) return g.classes.TAction.new("SetFrame", "Sets Frame Position",
                    g.classes.TInOut.new(owner, {
                        g.classes.TIn.new("x", "X Position", 'integer', g.classes.TRestrictMinMax.new(0, 1920), nil),
                        g.classes.TIn.new("y", "Y Position", 'integer', g.classes.TRestrictMinMax.new(0, 1080), nil),
                        g.classes.TIn.new("w", "Width", 'integer', g.classes.TRestrictMinMax.new(0, 1920), nil),
                        g.classes.TIn.new("h", "Height", 'integer', g.classes.TRestrictMinMax.new(0, 1080), nil),
                    
                    
                    
                    })
                ) end
            }
        }
    },
    TInOut = {
        new = function(owner, ins, outs)
            local obj = {}
            
            obj.owner = owner
            obj.is = function(self)
                return "TInOut"
            end
            obj.SetIn = function(self, ins)
                self.ins = ins
                for k, v in ipairs(ins) do
                    v.inout = self
                end
            end
            obj.SetOut = function(self, outs)
                self.outs = outs
                for k, v in ipairs(outs) do
                    v.inout = self
                end
            end
            obj:SetIn(ins or {})
            obj:SetOut(outs or {})
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end
    },
    TIn = {
        new = function(name, description, type, restrict, variable)
            local obj = {}
            obj.name = name;
            obj.description = description
            obj.type = type
            obj.restrict = restrict
            obj.inout = nil
            obj.variable = variable or g.classes.TVariable.new(nil, nil, nil, type)
            obj.GetValue = function(self)
                return obj.variable:GetValue()
            end
            obj.is = function(self)
                return "TIn"
            end
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end
    },
    TRestrictBase = {
        new = function()
            local obj = {}
            obj.validator = nil
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end
    },
    TRestrictMinMax = {
        new = function(min, max)
            local obj = {
                min = min,
                max = max,
            }
            obj.validator = function(value) return value <= max and value >= min end
            setmetatable(obj, {__index = g.classes.TRestrictBase})
            return obj
        end
    },
    TOut = {
        new = function(name, description, type, variable, useasresult)
            local obj = {}
            obj.name = name;
            obj.description = description
            obj.type = type
            obj.variable = variable
            obj.useasresult = useasresult
            obj.inout = nil
            obj.is = function(self)
                return "TOut"
            end
            obj.SetValue = function(self, value)
                if obj.variable then
                    obj.variable:SetValue(value)
                end
            end
            setmetatable(obj, {__index = g.classes.TBase})
            return obj
        end
    },
    TVariablePool = {
        new = function()
            local obj = {
                variables = {}--dict
            }
            obj.Add = function(self, variable)
                self.variables[variable.name] = variable
            end
            obj.Del = function(self, name)
                table.remove(self.variables, name)
            end
            obj.Get = function(self, name)
                return self.variables[name]
            end
            obj.is = function(self)
                return "TVariablePool"
            end
            return obj
        end
    },
    TVariable = {
        TYPES = {
            ["void"] = "void",
            ["null"] = 'null',
            ["boolean"] = 'boolean',
            ["integer"] = 'integer',
            ["number"] = 'number',
            ["string"] = 'string',
            ["actor"] = 'actor',
            ["handle"] = 'handle',
            ["stat"] = 'stat',
            ["variant"] = 'variant',
            ["item"] = 'item',
            ["skill"] = 'skill',
            ["guid"] = 'guid',
            ["clsid"] = 'clsid'
        },
        new = function(name, description, type)
            local obj = {
                name = name or "_",
                description = description or "_",
                value = nil,
                type = type,
            }
            obj.GetValue = function(self)
                return self.value
            end

            obj.GetRawValue = function(self)
                return self.value
            end            
            obj.SetValue = function(self, value)
                self.value = value
            end
            obj.SetRawValue = function(self, value)
                self.value = value
            end
            obj.is = function(self)
                return "TVariable"
            end
            return obj
        end
    },
    TVariableBase = {
        new = function(name)
            local obj = {
                name = name
            }
            obj.is = function(self)
                return "TVariableBase"
            end
            obj.GetValue = function(self)
                return self.value
            end
            obj.GetRawValue = function(self)
                return self.value
            end
            return obj
        end
    },
    
    TVariableLua = {
        new = function()
            local obj = {
                value = nil
            }
            obj.is = function(self)
                return "TVariableLua"
            end
            obj.GetValue = function(self)
                return assert(pcall(load(obj.value)), 'obj.GetValue failed TVariableLua>' .. obj.value)
            end
            obj.SetValue = function(self, value)
                
                end
            obj.GetRawValue = function(self)
                return obj.value
            end
            obj.SetRawValue = function(self, value)
                obj.value = value
            end
            setmetatable(obj, {__index = g.classes.TVariableBase})
            return obj
        end
    },
    TVariableFunction = {
        new = function(name, text, description, func, inout)
            local obj = {}
            obj.name = name
            obj.text = text
            obj.description = description
            obj.func = func
            
            obj.inout = inout
            obj.is = function(self)
                return "TVariableFunction"
            end
            obj.GetValue = function(self)
                local dict = {}
                for k, v in ipairs(obj.inout.ins) do
                    dict[v.name] = v.variable:GetValue()
                end
                
                return assert(pcall(obj.func, dict), 'obj.GetValue failed TVariableFunction>' .. obj.value)
            end
            obj.GetRawValue = function(self)
                
                end
            setmetatable(obj, {__index = g.classes.TVariableBase})
            return obj
        end,
        Functions = {
            Noop = function() return g.classes.TVariableFunction.new("Noop", "No operation", "No operation",
                function(indict)
                    return g.classes.TVariable.new("_", "_", "void")
                end) end,
            FindTarget = function() return g.classes.TVariableFunction.new("FindTarget", "Find Target Monster", "Find Target Monster",
                function(indict)
                    return g.classes.TVariable.new("handle", "Target Handle", g.classes.TVariable.TYPES.handle, session.GetTargetHandle(), nil, nil)
                end) end,
            GetMySelf = function() return g.classes.TVariableFunction.new("GetMySelf", "GetMySelf", "GetMySelf",
                function(indict)
                    return g.classes.TVariable.new("handle", "Myself handle", g.classes.TVariable.TYPES.handle, session.GetMyHandle(), nil, nil)
                end) end,
            GetSkill = function() return g.classes.TVariableFunction.new("GetSkill", "Get Skill Info", "Get Skill Info as Clsid",
                function(indict)
                    local clsid = indict["clsid"]
                    local skill = session.GetSkill(clsid)
                    return g.classes.TVariable.new("skill", "Skill", g.classes.TVariable.TYPES.skill, skill, nil, nil)
                end) end
        }
    },
    TVariableReference = {
        new = function(pin, target, default)
            local obj = {
                target = "_",
                default = nil,
            }
            obj.pin = pin;
            obj.GetValue = function(self)
                local pool = self.pin.inout.owner.variablepool
                local variable = pool:Get(self.target)
                
                return variable:GetValue()
            end
            obj.GetRawValue = function(self)
                return self.target
            end
            obj.is = function(self)
                return "TVariableReference"
            end
            setmetatable(obj, {__index = g.classes.TVariableBase})
            return obj
        end
    }
}
