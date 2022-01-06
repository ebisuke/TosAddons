--metaaddon_addonlet
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
g.cls = g.cls or {}
g.cls.MAAddonlet=function(addonletName,title)
	local self={
        addonletName="",
        title="",
        nodes={},

        _isTemporary=false,
		_className="MAAddonlet",
        scrollOffset={x=0,y=0},
        zoom=1,
        selected={},
        initImpl=function(self)
            self.addonletName=addonletName
            self.title=title
        end,
        clear=function(self)
            self.nodes={}
            self.streams={}
            self.selected={}
        end,
        insertNodes=function(self,lists)
            for i,node in ipairs(lists) do
             
                table.insert(self.nodes,node)
                
            end

        end,
        insertAndCloneNodes=function(self,lists)
            for i,node in ipairs(lists) do
                
                table.insert(self.nodes,node:clone())
                
            end

        end,

        compile=function(self)
            return ""
        end,
        hitTestByBox=function(self,left,top,right,bottom)
            local hits={}
            for id,node in pairs(self.nodes) do
                if node:hitTestBox(left,top,right,bottom) then
   
                    hits[#hits+1]=node
                end
                if node.getChildren then
                    for _,v in pairs(node:getChildren()) do
                        if v:hitTestBox(left,top,right,bottom) then
                            hits[#hits+1]=v
                        end
                        
                    end
                end
            end

            return hits
        end,
        selectByBox=function(self,left,top,right,bottom)
            if keyboard.IsKeyPressed("LSHIFT")==1 then
                
            else
                self.selected={}
            end
            for id,node in pairs(self.nodes) do
                if node:hitTestBox(left,top,right,bottom) then
                    g.fn.dbgout("Select node:"..node._name)
                    self.selected[#self.selected+1]=node
                end
                if node.getChildren then
                    for _,v in pairs(node:getChildren()) do
                        if v:hitTestBox(left,top,right,bottom) then
                            self.selected[#self.selected+1]=v
                        end
                    
                    end
                end
            end
           
        end,
        addNode=function(self,node)
            self.nodes[#self.nodes+1]=node
        end,
        addStream=function(self,stream)
            self.streams[#self.streams+1]=stream
        end,


        removeNode=function(self,node)
            for i,v in pairs(self.nodes) do
                if v==node then
                    table.remove(self.nodes,i)
                    break
                end
            end
        end,
        render=function(self,gbox)
            for id,node in pairs(self.nodes) do
                node:render(self,gbox,self.scrollOffset,self.zoom)
            end

        end,
        calculateBoundingBox=function(self)

            local left,top,right,bottom=0,0,0,0
            for id,node in pairs(self.nodes) do
                local bbox=node:calculateBoundingBox()
                left=math.min(left,bbox.left)
                top=math.min(top,bbox.top)
                right=math.max(right,bbox.right)
                bottom=math.max(bottom,bbox.bottom)

            end
            return {left=left,top=top,right=right,bottom=bottom}
        end,
        isSelected=function(self,node)
            for i,n in ipairs(self.selected) do
                if n==node then
                    return true
                end
            end
            return false
        end,
        isTemporary=function(self)
            return self._isTemporary
        end,
        assignImpl=function(self,obj)
            self._supers["MASerializable"].assignImpl(self,obj)
            self.addonletName=obj.addonletName
            self.title=obj.title
            self.nodes={}
            for i,v in pairs(obj.nodes) do
                self.nodes[#self.nodes+1]=v:clone()
                
            end
            self.streams=obj.streams
            self.selected=obj.selected
            self.scrollOffset=obj.scrollOffset
            self.zoom=obj.zoom
            
        end,
	}
	local obj= g.fn.inherit(self,g.cls.MASerializable())

    return obj
end





