--jsnobject.lua
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

g.instanceOf=function(subject,super)

    super = tostring(super)
    local mt = getmetatable(subject)

    while true do
        if mt == nil then return false end
        if tostring(mt) == super then return true end

        mt = getmetatable(mt)
    end	

end
local function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end
g. CombineTable=function(t1,t2)
    local t = t1
    for key, value in pairs(t2) do
        if(t[key] == nil)then
            t[key] = value
        end
    end
    return t
end 





g.inherit=function(obj,...)
    local chain={...}
    local object=obj
   
    local combinedmeta={}
    local hierarchy={}
    local behindclasses={}
    for _,super in pairs(chain) do
        if(not  behindclasses[super._className])then
            behindclasses[super._className]=super
          
        end
        combinedmeta=g.CombineTable(combinedmeta,super)
        hierarchy[#hierarchy+1]={super=super}
        if(super._hierarchy) then
            for _,v in ipairs(super._hierarchy) do
                if(not  behindclasses[v.super._className])then
                    behindclasses[v.super._className]=v.super
                end
                combinedmeta=g.CombineTable(combinedmeta,v.super)
                hierarchy[#hierarchy+1]={super=v.super}
            end
        end
        
    end
    --remove duplication
    local hash = {}
    local res = {}
    table.insert(hierarchy,1,{super=object})
    for _,v in ipairs(hierarchy) do
        if (not hash[v.super._className]) then
            res[#res+1] = v -- you could print here instead of saving to result table if you wanted
            hash[v.super._className] = true
        end
    end
    behindclasses[object._className]=object
    hierarchy=res
    object=g.CombineTable(object,combinedmeta)
    object._hierarchy=hierarchy
    
    object._supers=behindclasses
    return object
end
g.classes=g.classes or {}
g.classes.JSNObject=function()

    local self={
      
        _className="JSNObject",
        _id=nil,
        _hierarchy={},
        init=function(self)
            --don't be confused with the initialize function of the class
            --don't call in the constructor
            --don't inherit this function
            self._id=""..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999)

            for i,v in ipairs(ReverseTable(self._hierarchy)) do

                v.super.initImpl(self)
            end
 
    
    
            return self
        end,
        release=function(self)

            --don't call in the constructor
            --don't inherit this function
            local called={}
            local reversed=(self._hierarchy)
            self:releaseImpl()
            for i,v in ipairs(reversed) do
                v.super.releaseImpl(self)
               
            end

            return self
        end,
        initImpl=function(self)
            --override me
        end,
        releaseImpl=function(self)
            --override me
        end,
        
        getID=function(self)
            return self._id
        end,
        instanceOf=function (self,super)
            if(type(super)=="function")then
                error "instanceOf must be needed object.not constructor."
            end
            if(self._className==super._className)then
                return true
            end
            if(self._supers[super._className])then
                return true
            end
            return false
            
        end,
  
    }
    self._hierarchy[#self._hierarchy+1]={super=self}
    return self
end


g.classes.JSNFocusable=function(jsnmanager,disableFocus)

    local self={
        _className="JSNFocusable",
        _focused=false,
        _disableFocus=disableFocus,
        focus=function (self)
            if(self._disableFocus)then
                return
            end
          
            if(self:instanceOf(g.classes.JSNParentChildRelation()))then
                for i,v in ipairs(self:getChildren())do
                    if(v~=self and v:instanceOf(g.classes.JSNFocusable()))then
                        --remove siblings focus
                        v:unfocus()
                    end
                end
            end
            self._focused=true
            self:getJSNManager():focused(self)
            self:onFocused()
        end,
        setDisableFocus=function (self,disableFocus)
            self._disableFocus=disableFocus
        end,
        onFocused=function (self)
            self:onFocusedImpl()
        end,
        onFocusedImpl=function (self)
            --please override
        end,
        unfocus=function (self)
            self._focused=false
            self:onUnfocused()
        end,
        onUnfocused=function (self)
            --please override
            self:onUnfocusedImpl()
        end,
        onUnfocusedImpl=function (self)
            --please override
        end,
        getCursorObject=function (self)
            return self:getJSNManager().cursor
        end,
        setCursorRect=function (self,x,y,w,h)

            self:getCursorObject():setCursorRect(x,y,w,h)
            self:getCursorObject():setAnchor(self)
        end,
    }
    local object=g.inherit(self,g.classes.JSNManagerLinker(jsnmanager))


    return object

end
g.classes.JSNRawKey={
    NONE=false,
    JOY_UP="JOY_UP",
    JOY_DOWN="JOY_DOWN",
    JOY_LEFT="JOY_LEFT",
    JOY_RIGHT="JOY_RIGHT",
    JOY_BTN_1="JOY_BTN_1",
    JOY_BTN_2="JOY_BTN_2",
    JOY_BTN_3="JOY_BTN_3",
    JOY_BTN_4="JOY_BTN_4",
    JOY_BTN_5="JOY_BTN_5",
    JOY_BTN_6="JOY_BTN_6",
    JOY_BTN_7="JOY_BTN_7",
    JOY_BTN_8="JOY_BTN_8",
    JOY_BTN_9="JOY_BTN_9",
    JOY_BTN_10="JOY_BTN_10",
    JOY_BTN_11="JOY_BTN_11",
    JOY_BTN_12="JOY_BTN_12",
    
    JOY_TARGET_CHANGE="JOY_TARGET_CHANGE",
    
    JOY_L1L2="JOY_L1L2",
    JOY_R1R2="JOY_R1R2",
}
g.classes.JSNKey={
    NONE     =0x00000000,
    UP       =0x00000001,
    DOWN     =0x00000002,
    LEFT     =0x00000004,
    RIGHT    =0x00000008,
    MAIN     =0x00000010,
    CANCEL   =0x00000020,
    SUB      =0x00000040,
    OPTION   =0x00000080,
    PAGEBACK =0x00000100,
    PAGENEXT =0x00000200,
    TABBACK  =0x00000400,
    TABNEXT  =0x00000800,
    SYSMENU  =0x00001000,
    CLOSE    =0x00002000,
    MODIFIER =0x00004000,
}
g.jsnKeyInterpretation={
    [g.classes.JSNKey.UP]={
        [g.classes.JSNRawKey.JOY_UP]=true,
    },
    [g.classes.JSNKey.DOWN]={
        [g.classes.JSNRawKey.JOY_DOWN]=true,
    },
    [g.classes.JSNKey.LEFT]={
        [g.classes.JSNRawKey.JOY_LEFT]=true,
    },
    [g.classes.JSNKey.RIGHT]={
        [g.classes.JSNRawKey.JOY_RIGHT]=true,
    },
    [g.classes.JSNKey.MAIN]={
        [g.classes.JSNRawKey.JOY_BTN_1]=true,
    },
    [g.classes.JSNKey.CANCEL]={
        [g.classes.JSNRawKey.JOY_BTN_2]=true,
    },
    [g.classes.JSNKey.SUB]={
        [g.classes.JSNRawKey.JOY_BTN_3]=true,
    },
    [g.classes.JSNKey.OPTION]={
        [g.classes.JSNRawKey.JOY_BTN_4]=true,
    },
    [g.classes.JSNKey.PAGEBACK]={
        [g.classes.JSNRawKey.JOY_UP]=true,
        [g.classes.JSNRawKey.JOY_TARGET_CHANGE]=true,
    },
    [g.classes.JSNKey.PAGENEXT]={
        [g.classes.JSNRawKey.JOY_DOWN]=true,
        [g.classes.JSNRawKey.JOY_TARGET_CHANGE]=true,
    },
    [g.classes.JSNKey.TABBACK]={
        [g.classes.JSNRawKey.JOY_BTN_5]=true,
        [g.classes.JSNRawKey.JOY_TARGET_CHANGE]=false,
    },
    [g.classes.JSNKey.TABNEXT]={
        [g.classes.JSNRawKey.JOY_BTN_6]=true,
        [g.classes.JSNRawKey.JOY_TARGET_CHANGE]=false,
    },
    [g.classes.JSNKey.SYSMENU]={
        [g.classes.JSNRawKey.JOY_BTN_7]=true,
    },
    [g.classes.JSNKey.CLOSE]={
        [g.classes.JSNRawKey.JOY_BTN_10]=true,
    },
    [g.classes.JSNKey.MODIFIER]={
        [g.classes.JSNRawKey.JOY_TARGET_CHANGE]=true,
    },
}
-- owner-follower relationship
-- owner can't know about followers usually.(don't use function of start with "_" directly)
g.classes.JSNOwnerRelation=function (owner)
    local self={
        _owner=owner,
        _followers={},
        getOwner=function (self)
            return self._owner
        end,
        hasLeastOneFollower=function (self)
            return #self._followers>0
        end,
        _addFollower=function (self,follower)
            self._followers[#self._followers+1]=follower
        end,
        _removeFollower=function (self,follower)
            for i=1,#self._followers do
                if self._followers[i]==follower then
                    table.remove(self._followers,i)
                    break
                end
            end
        end,
        initImpl=function (self)
            if(owner)then
                if (owner:instanceOf(g.classes.JSNOwnerRelation())==false)then
                    error("owner must be instance of JSNOwnerRelation")
                end
                owner:_addFollower(self)
            end
            
        end,
        releaseImpl=function (self)
            if(owner)then
                owner:_removeFollower(self)
            end
        end
    }
    local object=g.inherit(self,g.classes.JSNObject())

    return object
end
-- parent-child relationship
-- parent can know about children.
g.classes.JSNParentChildRelation=function (parent)
    local self={
        _parent=parent,
        _children={},
        initImpl=function (self)
            if(self:getParent()~=nil)then
                self:getParent():addChild(self)
            end
        end,
        releaseImpl=function (self)
            if(self:getParent()~=nil)then
                self:getParent():removeChild(self)
            end
        end,
        setParent=function (self,parent)
            if(self:getParent()~=nil)then
                self:getParent():removeChild(self)
            end
            self._parent=parent
            if(self:getParent()~=nil)then
                self:getParent():addChild(self)
            end
        end,
        getParent=function (self)
            return self._parent
        end,
        getChildren=function (self)
            return self._children
        end,
        addChild=function (self,child)
            table.insert(self._children,child)
            self:onAddChild(child)
        end,
        onAddChild=function (self,child)
            --don't call directly
            self:onAddChildImpl(child)
        end,
        onAddChildImpl=function (self,child)
            --please override
        end,
        removeChild=function (self,child)
            for i,v in ipairs(self._children) do
                if v==child then
                    table.remove(self._children,i)
                    self:onRemoveChild(child)
                    break
                end
            end
            
        end,
        onRemoveChild=function (self,child)
            --don't call directly
            self:onRemoveChildImpl(child)
        end,
        onRemoveChildImpl=function (self,child)
            --please override
        end
    }
    local object=g.inherit(self,g.classes.JSNObject())

    return object
end
g.classes.JSNKeyHandler=function(jsnmanager)

    local self={
        _className="JSNKeyHandler",
        initImpl=function (self)
            self:getJSNManager():registerKeyListener(self)
        end,
        releaseImpl=function (self)
            self:getJSNManager():unregisterKeyListener(self)
        end,
 
        onKeyDown=function (self,key)
            --dont call directly
            --dont override
            
            self:onKeyDownImpl(key)
            if self:instanceOf(g.classes.JSNParentChildRelation()) then
                --伝搬
                for i,v in ipairs(self:getChildren()) do
                    v:onKeyDown(key)
                end
            end
        end,
        onKeyRepeat=function (self,key)
            --dont call directly
            --dont override
            self:onKeyRepeatImpl(key)
            if self:instanceOf(g.classes.JSNParentChildRelation()) then
                --伝搬
                for i,v in ipairs(self:getChildren()) do
                    v:onKeyRepeat(key)
                end
            end
        end,
        onKeyDownImpl=function (self,key)
            --please override
        end,
        onKeyRepeatImpl=function (self,key)
            --please override
        end,
        canHandleKeyDirectly=function (self)
            if(self:instanceOf(g.classes.JSNOwnerRelation()))then
                --子が一人でもいたら受けない
                if self:hasLeastOneFollower() then
                    return false
                end
            end
            if(self:instanceOf(g.classes.JSNParentChildRelation()))then
                --親がいたら直接的には受けない
                if self:getParent() then
                    return false
                end
            end
            return true
        end,
    }
    local object=g.inherit(self,g.classes.JSNManagerLinker(jsnmanager))

    return object
end

g.classes.JSNManagerLinker=function(jsnmanager)

    local self={
        _className="JSNManagerLinker",
        _jsnmanager=jsnmanager,
        initImpl=function (self)
            if(self:getJSNManager()==nil)then
                error("JSNManagerLinker: jsnmanager is nil")
            end
        end,
        getJSNManager=function (self)
            return self._jsnmanager
        end,
    }
  
    local object=g.inherit(self,g.classes.JSNObject())

    return object
end

g.classes.JSNEveryTickHandler=function(jsnmanager)

    local self={
        _className="JSNEveryTickHandler",
        onEveryTick=function (self)
            --please override
        end,
        initImpl=function (self)
            self:getJSNManager():registerTickListener(self)   
        end,
        releaseImpl=function(self)
            self:getJSNManager():unregisterTickListener(self)
        end
    }
    local object=g.inherit(self,g.classes.JSNManagerLinker(jsnmanager))

    return object

end