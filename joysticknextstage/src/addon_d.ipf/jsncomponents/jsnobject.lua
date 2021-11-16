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
g.CombineTable=function(t1,t2)
    local t = t1
    for key, value in pairs(t2) do
        if(t[key] == nil and value)then
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
                    hierarchy[#hierarchy+1]={
                        super=v.super
                    }
                   
                end
            end
        
    end

    --remove duplication
    local hash = {}
    local res = {}
    
  
    for _,v in ipairs(hierarchy) do
        if (not hash[v.super._className]) then
            res[#res+1] = v -- you could print here instead of saving to result table if you wanted
            hash[v.super._className] = true
        end
    end
    
    hierarchy=ReverseTable(res)
    table.insert(hierarchy,{super=object})
    object=g.CombineTable(object,combinedmeta)

    behindclasses[object._className]=object
    object._hierarchy=hierarchy
    object._supers=behindclasses
    return object
end
g.classes=g.classes or {}
g.singleton=g.singleton or {}
g.classes.JSNObject=function()

    local self={

        _className="JSNObject",
        _id=nil,
        _hierarchy={},
        _released=false,
        init=function(self)
            --don't be confused with the initialize function of the class
            --don't call in the constructor
            --don't inherit this function
            self._id=""..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999)
        
            local fail=false
            local breaking=false
            for i,v in ipairs(self._hierarchy) do
                EBI_try_catch({
                    try = function()
                    --DBGOUT("init>"..v.super._className)
                    if(v.super.preInitImpl(self)~=nil)then
                        fail=true
                        return nil
                    end
                end,
                catch = function(error)
                    ERROUT("JSNObject.init()"..error)
                    fail=true
                end
            })
            end
            if(breaking)then
                self._fail=true
                return self
            end
            
            for i,v in ipairs(self._hierarchy) do
                EBI_try_catch({
                    try = function()
                    --DBGOUT("init>"..v.super._className)
                    if(v.super.initImpl(self)~=nil)then
                        return nil
                    end
                end,
                catch = function(error)
                    ERROUT("JSNObject.init()"..error)
                    fail=true
                end
            })
            end
            if(breaking)then
                self._fail=true
                return self
            end
            
        
        
        
            for i,v in ipairs(self._hierarchy) do
                --DBGOUT("lazyinit>"..v.super._className)
                EBI_try_catch({
                    try = function()
                        v.super.lazyInitImpl(self)
                    end,
                    catch = function(error)
                        ERROUT("JSNObject.init()"..error)
                        fail=true
                    end
                })
            end 
            if(breaking)then
                self._fail=true
                return self
            end
 
            if fail then
                self._fail=true
            end
            return self
        end,
        isFailed=function(self)
            return self._fail
        end,
        isReleased=function(self)
            return self._released
        end,
        -- hook method
        -- pre hook function's return is indicated to be ignored.true is ignored, false is not ignored.
        -- post hook function's return is modified to be the return of the original hook function.
        hook=function(self,name,prefunc,postfunc)

            if(not self[name])then
                error("no such method:"..name)
            end
            if(self["_originalFunc_"..name])then
                print("jsnobject.lua:"..self._className.. "> hook method:"..name.." is already hooked.")
            end
            --replace the original method
            self["_originalFunc_"..name]=self[name]
            self[name]=function(self,...)
          
                if(prefunc)then
                    local tbl={prefunc(self,...)}
                    if tbl and tbl[1] then
                        table.remove(tbl,1)
                        return unpack(tbl)
                    end
                end
                local result={self["_originalFunc_"..name](self,...)}
                if(postfunc)then
                    local tbl={postfunc(self,result,...)}
                    if tbl then
                        return unpack(tbl)
                    end
                end
                return unpack(result)
            end
         
        end,
        release=function(self)

            --don't call in the constructor
            --don't inherit this function
            local called={}
            local reversed=ReverseTable(self._hierarchy)
            
            for i,v in ipairs(reversed) do
                v.super.releaseImpl(self)
            end
            self._released=true
            return self
        end,
        preInitImpl=function(self)
            --override me
           
             
        end,
        initImpl=function(self)
            --override me
           
             
        end,
        lazyInitImpl=function(self)
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
  
        --conventional method
        findClassInAncestorAndFollower=function(self,class)
            if(self:instanceOf(class))then
                return self
            end
            if(self:instanceOf(g.classes.JSNParentChildRelation()) and self:getParent())then
                return self:getParent():findClassInAncestorAndFollower(class)
            end
            if(self:instanceOf(g.classes.JSNOwnerRelation()))then
                for _,v in pairs(self:_getFollowers())do
                    local res=v:findClassInAncestorAndFollower(class)
                    if(res)then
                        return res
                    end
                end
            end
            return nil
        end,
        --conventional method
        releaseAllRelationship=function(self)
            if(self:instanceOf(g.classes.JSNParentChildRelation()) and self:getParent())then
                return self:getParent():releaseAllRelationship()
            end
            if(self:instanceOf(g.classes.JSNOwnerRelation()))then
                for _,v in pairs(self:_getFollowers())do
                    v:releaseAllRelationship()
                end
            end
            self:release()
        end,
        --conventional method
        findTopFrame=function(self)
            if(self:instanceOf(g.classes.JSNFrameBase()))then
                return self
            end
            if(self:instanceOf(g.classes.JSNParentChildRelation()) and self:getParent())then
                return self:getParent():findTopFrame()
            end
            return nil
        end,
    }
    self._hierarchy[#self._hierarchy+1]={super=self}
    return self
end
g.classes.JSNSingleton=function()
    local self={
        _className="JSNSingleton",
        initImpl=function(self)
            --override me
            if(g.singleton[self._className])then
                error("singleton class "..self._className.." is already initialized.")
            end
            g.singleton[self._className]=self
        end,
        releaseImpl=function(self)
            --override me
            DBGOUT(self._className.." is released.")
            g.singleton[self._className]=nil
        end,
        getInstance=function(self)
            if(g.singleton[self._className]~=nil)then
                return g.singleton[self._className]
          
            end
            return nil
        end,
    }

    local obj= g.inherit(self,g.classes.JSNObject())

    return obj
end
g.classes.JSNPlayerControlDisabler=function(jsnmanager)

    local self={
        _className="JSNPlayerControlDisabler",
        initImpl=function(self)
           
            self:getJSNManager():incrementControlRestrictionCounter()
        end,
        releaseImpl=function(self)
            self:getJSNManager():decrementControlRestrictionCounter()
        end,
    }
    local object=g.inherit(self, g.classes.JSNManagerLinker(jsnmanager))
    return object
end

g.classes.JSNFocusable=function(jsnmanager,linkedjsnobject)

    local self={
        _className="JSNFocusable",
        _focused=nil,
        _linkedJSNObject=linkedjsnobject,
        _cursor=nil,
        _modal=nil,
        initImpl=function(self)
            if(self._linkedJSNObject==nil) then
                error("JSNFocusable link must not nil")
            end
            if(not (self._linkedJSNObject:instanceOf(g.classes.JSNFrameBase()) or self._linkedJSNObject:instanceOf(g.classes.JSNComponent()))) then
                error("JSNFocusable must be linked to a JSNFrameBase or JSNComponent")
            end

            local jsnframe=self._linkedJSNObject
            if self._linkedJSNObject:instanceOf(g.classes.JSNComponent()) then
                jsnframe=self._linkedJSNObject:getJSNFrame()
            end
           
            self._cursor=g.classes.JSNCursor(jsnmanager,jsnframe):init()
        end,
        _setModalParameter=function(self,param)
            if(param==nil)then
                error("JSNFocusable _setModalParameter must not nil")
            end
            self._modal=param
        
        end,
        callModal=function(self,modalfocusable,whenunfocusedfunc)
            self:unfocus()
            modalfocusable:_setModalParameter({
                whenunfocusedfunc=whenunfocusedfunc,
                caller=self,
            })
            return modalfocusable
        end,
        releaseImpl=function(self)
            
            self:unfocus()
            if(self._cursor)then
                self._cursor:release()
                self._cursor=nil
            end

            if(self._modal)then
    
                self._modal.caller:focus()
                if(self._modal.whenunfocusedfunc)then
                    self._modal.whenunfocusedfunc(self._modal,self)
                end
                self._modal=nil
            end
        end,
        focus=function (self)
   
            DBGOUT(self._className..' focus')
            if(self:getParent() and self:getParent():instanceOf(g.classes.JSNParentChildRelation()))then
                for i,v in ipairs(self:getParent():getChildren())do
                    if(v:getID()~=self:getID() and v:instanceOf(g.classes.JSNFocusable()))then
                        --remove siblings focus
                        DBGOUT(self._className)
                        v:unfocus()
                    end
                end
            end

           
            if(not self._focused)then
                DBGOUT(self:getID().." is focused.")
                self._focused=true
                self:onFocused()
            end
        
          
            
            --focus parents
            if(self:instanceOf(g.classes.JSNParentChildRelation()))then
                local parent=self:getParent()
                if(parent==self)then
                    error("parent must not be self")
                end
                
                if(parent and parent:instanceOf(g.classes.JSNFocusable()))then
                    parent:focus()
                end
                   
            end

        end,
        hasFocus=function(self)
            return self._focused
        end,
     
        onFocused=function (self)

            self:onFocusedImpl()
        end,
        onFocusedImpl=function (self)
            --please override
        end,
        unfocus=function (self)
            if(self._focused)then
                self._focused=nil
                self:onUnfocused()
            end
        end,
        onUnfocused=function (self)
            --please override
            self:onUnfocusedImpl()
            
          
        end,
        onUnfocusedImpl=function (self)
            --please override
        end,
        getCursorObject=function (self)
            return self._cursor
        end,
        setCursorRect=function (self,x,y,w,h)

            self:getCursorObject():setCursorRect(x,y,w,h)
            self:getCursorObject():setAnchor(self)
        end,
        setCursorToObject=function (self,nativeobject)

            self:getCursorObject():setCursorRect(
                nativeobject:GetX(),
                nativeobject:GetY(),
                nativeobject:GetWidth(),
                nativeobject:GetHeight()    

            )
            self:getCursorObject():setAnchor(self)
        end,
        getLinkedJSNObject=function (self)
            return self._linkedJSNObject
        end,
    }
    local object=g.inherit(self, g.classes.JSNManagerLinker(jsnmanager))


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
    OMNISCREEN  =0x00010000,
    DEBUG   =0x80000000,
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
    [g.classes.JSNKey.OMNISCREEN]={
        [g.classes.JSNRawKey.JOY_BTN_7]=true,
        [g.classes.JSNRawKey.JOY_TARGET_CHANGE]=true,
    },
    [g.classes.JSNKey.DEBUG]={
        [g.classes.JSNRawKey.JOY_BTN_4]=true,
        [g.classes.JSNRawKey.JOY_TARGET_CHANGE]=true,
    },
}

-- owner-follower relationship
-- owner can't know about followers usually.(don't use function of start with "_" directly)
-- weak parameter is effect to hasLeastOneFollower function.
g.classes.JSNOwnerRelation=function (owner,weak)
    local self={
        _className="JSNOwnerRelation",
        _owner=owner,
        _followers={},
        _weak=weak or false,
        getOwner=function (self)
            return self._owner
        end,
        hasLeastOneFollower=function (self)
            for k,v in pairs(self._followers) do
                if not v._weak then
                    return true
                end
            end
            return false
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
        _getFollowers=function (self)
            return self._followers
        end,
        initImpl=function (self)
            if(self:getOwner())then
                if (self:getOwner():instanceOf(g.classes.JSNOwnerRelation())==false)then
                    error("owner must be instance of JSNOwnerRelation")
                end
                self:getOwner():_addFollower(self)
            end
            
        end,
        releaseImpl=function (self)
            if(self:getOwner())then
                self:getOwner():_removeFollower(self)
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
        _className="JSNParentChildRelation",
        _parent=parent,
        _children={},
        initImpl=function (self)
            if(self==self:getParent())then
                error("parent can't be itself")
            end
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
            if(self==parent)then
                error("parent can't be itself")
            end
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
            if(self==child)then
                error("child can't be itself")
            end
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
        onPreKeyDown=function (self,key)
            self:onPreKeyDownImpl(key)
        end,
        onPreKeyRepeat=function (self,key)
            self:onPreKeyRepeatImpl(key)
        end,
        onPreKeyDownImpl=function (self,key)
 
        end,
        onPreKeyRepeatImpl=function (self,key)
           
        end,
        onKeyDown=function (self,key)
            --dont call directly
            --dont override
            if(self:instanceOf(g.classes.JSNFocusable())and not self:hasFocus())then
                DBGOUT("JSNKeyHandler:onKeyDown:no focus")
                return
            end
            if(self:instanceOf(g.classes.JSNOwnerRelation()) and self:hasLeastOneFollower())then
                return
            end
            if(self:onKeyDownImpl(key))then
                return true
            end
            if self:instanceOf(g.classes.JSNParentChildRelation()) then
                --伝搬
                local result=false
                for i,v in ipairs(self:getChildren()) do
                    if(not v:instanceOf(g.classes.JSNOwnerRelation())or not v:hasLeastOneFollower() )then
                        result=v:onKeyDown(key) or result
                    end
                end
                return result
            end
        end,
        onKeyRepeat=function (self,key)
            --dont call directly
            --dont override
            if(self:instanceOf(g.classes.JSNFocusable())and not self:hasFocus())then
                return
            end
            if(self:instanceOf(g.classes.JSNOwnerRelation()) and self:hasLeastOneFollower())then
                return
            end
            if(self:onKeyRepeatImpl(key))then
                return true
            end
            if self:instanceOf(g.classes.JSNParentChildRelation()) then
                --伝搬
                local result=false
                for i,v in ipairs(self:getChildren()) do
                   
                    result= v:onKeyRepeat(key) or result
                    
                end
                return result
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
                    DBGOUT("JSNKeyHandler:canHandleKeyDirectly:hasLeastOneFollower")
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
            self:onEveryTickImpl()
        end,
        onEveryTickImpl=function (self)
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
