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


g.classes={
    TBase={
        new=function()
            local obj={
                enabled=false,
                uuid=g.func.uuid(),
                variables={},
            }
            obj.is=function (self)
                return "TFlowerBase"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            return obj
        end
    },
    TFlowerBase={
       
        new=function(name)
            local obj={}
            obj.frame=g.classes.TFrame.new()
            obj.name=name or "noname"
            obj.guid=g.func.uuid()
            obj.is=function (self)
                return "TFlowerBase"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            
            return obj
        end
    },
    TFlower={
       
        new=function(name)
            local obj={}
            obj.frame=g.classes.TFrame.new()
            obj.name=name or "noname"
            obj.guid=g.func.uuid()
            obj.is=function (self)
                return "TFlower"
            end
            setmetatable(obj,{__index=g.classes.TFlowerBase})
           
            return obj
        end
    },
    TFrame={
        new=function()
            local obj={
                args={
                    g.classes.TVariableDefine.new("x","integer",0,10,1920),
                    g.classes.TVariableDefine.new("y","integer",0,10,1080),
                    g.classes.TVariableDefine.new("w","integer",0,10,1920),
                    g.classes.TVariableDefine.new("h","integer",0,10,1080),
                    g.classes.TVariableDefine.new("visible",'boolean',true)
                }
            }
            obj.is=function (self)
                return "TFrame"
            end
            setmetatable(obj,{__index=g.classes.TBase})

            return obj
        end
    },
    TPetal={
        new=function()
            local obj={}
            obj.triggers={}
            obj.contents={}
            obj.actions={}
            obj.uuid=g.func.uuid()
            obj.is=function (self)
                return "TPetal"
            end
            setmetatable(obj,{__index=g.classes.TFlowerBase})
            return obj
        end
    },
    TContent={
        new=function()
            local obj={}
            obj.is=function (self)
                return "TContent"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            return obj
        end
    },
    TCondition={
        new=function()
            local obj={}
            obj.lhs=nil;
            obj.comparator=nil;
            obj.rhs=nil;
            obj.is=function (self)
                return "TCondition"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            return obj
        end
    },
    TComparator={
        new=function(name,text,func)
            local obj={}
            obj.name=name
            obj.text=text
            obj.compare=func
            obj.is=function (self)
                return "TComparator"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            return obj
        end,
        Comparators={
            Equal=function()
                return g.classes.TComparator.new("Equal","==",function(a,b) return a==b end)
            end,
            NotEqual=function()
                return g.classes.TComparator.new("NotEqual","~=",function(a,b) return a~=b end)
            end,
            GreaterThan=function()
                return g.classes.TComparator.new("GreaterThan",">",function(a,b) return a>b end)
            end,
            LessThan=function()
                return g.classes.TComparator.new("LessThan","<",function(a,b) return a<b end)
            end,
            GreaterThanEqual=function()
                return g.classes.TComparator.new("GreaterThanEqual","<=",function(a,b) return a<=b end)
            end,
            LessThanEqual=function()
                return g.classes.TComparator.new("LessThanEqual",">=",function(a,b) return a>=b end)
            end,
            And=function()
                return g.classes.TComparator.new("And","And",function(a,b) return a and b end)
            end,
            Or=function()
                return g.classes.TComparator.new("Or","Or",function(a,b) return a or b end)
            end,
            LHS=function()
                return g.classes.TComparator.new("LHS","LHS",function(a,b) return a  end)
            end,
            RHS=function()
                return g.classes.TComparator.new("RHS","RHS",function(a,b) return  b end)
            end,
            False=function()
                return g.classes.TComparator.new("False","False",function(a,b) return false end)
            end,
            True=function()
                return g.classes.TComparator.new("True","True",function(a,b) return true end)
            end
        }
    },
    TFunction={
        new=function()
            local obj={}
            obj.inout=g.classes.TInOut.new()
           
            obj.is=function (self)
                return "TFunction"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            return obj
        end
    },
    TAction={
        new=function()
            local obj={}
            
            obj.inout=g.classes.TInOut.new()
            obj.is=function (self)
                return "TAction"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            return obj
        end
    },
    TInOut={
        new=function()
            local obj={}
            obj.arg={}
            obj.ret={}
            obj.is=function (self)
                return "TInOut"
            end
            setmetatable(obj,{__index=g.classes.TBase})
            return obj
        end
    },
    TVariableDefine={
        TYPES={
            "void",
            "null",
            "boolean",
            "integer",
            "number",
            "string",
            "actor",
            "handle",
            "stat",
            "variant",
            "item",
            "skill",
            "guid",
            "clsid"
        },
        new=function(name,type,default,min,max)
            local obj={
                name="_",
                description="nodesc",
                value=default,
                default=default,
                min=min,
                max=max,
                type=type,
            }
            return obj
        end
    },
    TVariableBase={
        new=function()
            local obj={
                name="_"
            }
            return obj
        end
    },
    TVariableImmediate={
        new=function()
            local obj={
                value=nil
            }
            setmetatable(obj,{__index=g.classes.TVariableBase})
            return obj
        end
    },
    TVariableReference={
        new=function()
            local obj={
                target="_",
                default=nil,
            }
            
            setmetatable(obj,{__index=g.classes.TVariableBase})
            return obj
        end
    }
}
