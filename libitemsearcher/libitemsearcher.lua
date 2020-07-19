function string.split(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end
    
    local t = {};
    local i = 1
    for s in string.gmatch(str, "([^" .. ts .. "]+)") do
        t[i] = s
        i = i + 1
    end
    
    return t
end
local g={
    Searcher=function()
        return {
            _by_charactor_name={},
            _itemList={},
            searchHistory={},
            _limit_of_history=100,
            addItem=function(self,name,object)
                self._itemList[name]=object
                if self._itemList[name] then
                    return
                end

                for k,v in ipairs(name) do
                    self._by_charactor_name[v]=self._by_charactor_name[v] or {}
                    table.insert(self._by_charactor_name[v],name)
                end
            end,
            clearItems=function(self)
                self._itemList={}
                self._by_charactor_name={}
            end,
            clearSearchHistory=function(self)
                
                self.searchHistory={}
            end,
            addSearchHistory=function(self,name)
                for k,v in ipairs(self.searchHistory) do
                    if v~=name then
                        table.insert(self.searchHistory,k)
                        return 
                    end
                end
            end,
            _calculateRank=function(self,name)
                local rank={}
                local spr=name:split(" ")
                for _,n in ipairs(spr) do
                    for k,v in ipairs(name) do
                        if self._by_charactor_name[v] then
                            for _,vv in ipairs( self._by_charactor_name[v]) do
                                if rank[vv] then
                                    rank[vv]=1
                                else
                                    rank[vv]=rank[vv]+1
                                end
                            end
                        end
                    end
                end
                
                local list={}
                for k,v in pairs(rank) do
                    --and operation
                    local fail=false
                    for kk,vv in ipairs(spr) do
                       if not k:find(vv) then
                        fail=true
                         break
                       end
                    end
                    if not fail then
                        table.insert(list,{name=k,rank=v,object=self._itemList[k]})
                    end
                end
                table.sort(list,function(a,b)
                    if a.rank==b.rank then
                        return a.name < b.name
                    else
                        return a.rank >= b.rank
                    end
                end)
                return list
            end,
            _searchFromHistory=function(self,name)
                local result={}
                for k,v in ipairs(self.searchHistory) do
                    if string.find(v,result) then
                        table.insert(result,{name=name,object=self._itemList[name]})
                    end
                end
                return result
            end,
            searchWithSuggest=function(self,search,num_of_searchhistory,num_of_suggest)
                num_of_suggest=num_of_suggest or 10
                num_of_searchhistory = num_of_searchhistory or 3
                local list=self:_calculateRank(search)
                local history=self:_searchFromHistory(search)
                return list,history
            end
        
        }
    end,
    SuggestLister=function()
        return {
            _targetText=nil,
            _listBox=nil,
            searcher=nil,
            _intelliname="intelli",
            init=function(self,searcher,textbox,intelliname)
                self._targetText=textbox
                self._targetText:SetTypingScp('LIBITEMSEARCHER_ON_TYPE');
                self._targetText:SetUserValue("LIBITEMSEARCHER_ON_TYPE",self)
                self.searcher=searcher
                return self
            end,
            doSearch=function(self)
                local parent=self:GetParent()
                local text=self._targetText:GetText()
                local result,history=self.searcher:searchWithSuggest(text)
                local intelli=parent:CreateOrGetControl("listbox","intelli",text:GetX(),text:GetY(),text:GetWidth(),100)
                AUTO_CAST(intelli)
                self._listBox=intelli
                
                if intelli:IsVisible()~=0 then
                    intelli:SetSkin("bg2")
                end
                intelli:ShowWindow(1)
                intelli:SetLostFocusingScp("LIBITEMSEARCHER_ON_ESCAPE")
                LIBITEMSEARCHER_CURRENT_INTTELI=self
                ui.SetEscapeScp("LIBITEMSEARCHER_ON_ESCAPE()");
                intelli:RunUpdateScript("LIBITEMSEARCHER_ON_UPDATE",0.01)
            end,
            determine=function(self)
                local sel=nil
                if ( self._listBox:GetSelItemIndex() >= 0) then
                    sel =  self._listBox:GetSelItemText()
                else
                    
                end
                self:closeSearch()
                return sel
            end,
            closeSearch=function(self)
                ui.SetEscapeScp("");
                local intelli=self._listBox
                intelli:ShowWindow(0)
                intelli:StopUpdateScript()
            end
        }
    end,
}
function LIBITEMSEARCHER_ON_TYPE(parent, ctrl)
 
    local lister=ctrl:GetUserValue("LIBITEMSEARCHER_ON_TYPE")
    lister:doSearch()
end                
function LIBITEMSEARCHER_ON_ESCAPE()  
    LIBITEMSEARCHER_CURRENT_INTTELI:closeSearch()
    LIBITEMSEARCHER_CURRENT_INTTELI=nil                                                                              
end
function LIBITEMSEARCHER_ON_UPDATE(parent, ctrl)
    local list=AUTO_CAST(ctrl)
    local lister=ctrl:GetUserValue("LIBITEMSEARCHER_ON_TYPE")
    if 1 == keyboard.IsKeyDown("ENTER") then
        lister:determine()
        return
    end
    local cur = list:GetSelItemIndex()
    if 1 == keyboard.IsKeyDown("UP") then
                    
        list:DeSelectItemAll()
        list:SelectItem(math.max(0, cur - 1))
        list:Invalidate()
    
    elseif 1 == keyboard.IsKeyDown("DOWN") then
        
        
        list:DeSelectItemAll()
        list:SelectItem(math.min(DEVELOPERCONSOLE_INTELLI_COUNT - 1, cur + 1))
        list:Invalidate()
    
    elseif 1 == keyboard.IsKeyDown("NEXT") then
        
        list:DeSelectItemAll()
        list:SelectItem(math.min(DEVELOPERCONSOLE_INTELLI_COUNT - 1, cur + 7))
        list:Invalidate()
    
    elseif 1 == keyboard.IsKeyDown("PRIOR") then
        
        list:DeSelectItemAll()
        list:SelectItem(math.max(0, cur - 7))
        list:Invalidate()
    
    end
end
LIBITEMSEARCHER_V1_0=g
return g