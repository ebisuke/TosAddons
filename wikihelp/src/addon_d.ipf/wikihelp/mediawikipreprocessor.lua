--preprocessor
local P = {}
if (not session and not ebi_utf8) then
    ebi_utf8 = loadfile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\utf8.lua")()
end
function table.elemn(tbl)
    local n = 0
    for _ in pairs (tbl) do
        n = n + 1
    end
    return n
end
function string.split(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end
    
    local t = {};
    i = 1
    for s in string.gmatch(str, "([^" .. ts .. "]+)") do
        t[i] = s
        i = i + 1
    end
    
    return t
end
function string.findclosebrace(str,len,lvl)
    lvl=lvl or 0
    for i = 1, str:len() do
        local substr=str:sub(i)
        if(substr:starts("{"))then
            lvl=lvl+1
        elseif (substr:starts("}"))then
            lvl=lvl-1
            if(lvl==0)then
                return str:sub(1+len,i-len),i,str:sub(1,i)
            end
        end
    end
    return nil,nil,nil
end
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
function P.generatetable(substr)
    substr=substr:gsub("\n","")
    local tbl={}
    local spr=string.split(substr,"|")
    for k,v in ipairs(spr) do
        --一つ目は名前なので無視
        if(k~=1)then
            local eqs=string.split(v,"=")
            if(#eqs==2)then
                --名前付き
                tbl[eqs[1]]=eqs[2]
            else
                --名前なし
                tbl[tostring(k-1)]=v
            end
        end
    end
    return tbl
end
function P.removestuff(str)
    return str:gsub("<includeonly>(.-)</includeonly>","%1"):gsub("<noinclude>.-</noinclude>","")
end

function P.generatenode(tmplstr,parent,params,context)
    parent=parent or {}
    local pos=1
    local textbuf=""
    while pos <= tmplstr:len() do
        local str=tmplstr:sub(pos)
        local ends,endpos,raw
        local name
        if(str:starts("{{{"))then
            --パラメタ呼び出し
            ends,endpos,raw=string.findclosebrace(str,3)
            name="paramcall"
        elseif(str:starts("{{"))then
            --タグ
            ends,endpos,raw=string.findclosebrace(str,2)
            if(ends:starts("#"))then
                name="special"
            else
                if(ends=="PAGENAME")then
                    ends=context.pagename
                    name="text"
                else
                    name="tag"
                end
            end
        else
            
        end
        if(ends)then
            parent.child=parent.child or {}
            if(textbuf:len()>0)then
                parent.child[#parent.child+1]={
                    name="text",
                    content=textbuf,
                    raw=textbuf,
                    parent=parent,
                }
                textbuf=""
            end

            parent.child[#parent.child+1]={
                name=name,
                content=ends,
                raw=raw,
                parent=parent
            }
            
            --探る
            local child=parent.child[#parent.child]
            
            
            
            if(name=="special")then
                local content=child.content
                local match=content:match("(#.*)")
                local match2,arg=content:match("(#.-):(.-)$")
                if(match or match2)then
                    --local _,arg=content:match("(#.-):(.-)$")
                    child.type=match2 or match
                    if(arg)then
                        P.generatenode(arg,child,params,context)
                    end
                    child.arg=arg
                end
            elseif(name=="tag")then
                local content=child.content
                local match=content:match("(.*)")
                local match2,arg=content:match("(.-)|(.-)$")
                if(match or match2)then
                    
                    child.type=match2 or match
                    if(arg)then
                        P.generatenode(arg,child,params,context)
                    end
                    child.arg=arg
                end
            elseif(name=="paramcall")then
   
                
                P.generatenode(ends,child,params,context)
                
 
            end
            pos=endpos+pos
        else
            local char=str:sub(1,1)
            if(parent.name=="paramcall")then
                if(char=="|")then
                    parent.child=parent.child or {}
                    parent.child[#parent.child+1]={
                        name="text",
                        content=textbuf,
                        raw=textbuf,
                        parent=parent,
                    }
                    textbuf=""
                else
                    textbuf=textbuf..char
                end
            else
                textbuf=textbuf..char
            end
            
            pos=pos+1
        end
    end
    if(textbuf:len()>0)then
        parent.child=parent.child or {}
        parent.child[#parent.child+1]={
            name="text",
            content=textbuf,
            raw=textbuf,
            parent=parent,
        }
        textbuf=""
    end

    parent.content=P.generatecontent(parent)
    --パラメータコールなら解決する
    if(parent.name=="paramcall")then
        parent.pretend=parent.content
        local spr=parent.child
        local ret
        if(spr)then
            if(#spr>1)then
                --choice
                ret=spr[#spr].content
                for k,v in ipairs(spr) do
                    
                    if(params[v.content])then
                        ret=params[v.content]
                        break
                    end
                end
            elseif #spr==1 then
                --無条件

                ret=params[spr[1].content] or ""
                
            end
        else
            local spr=parent
           
            ret=params[spr.content] or ""
            

        end
        parent.waste=parent.child
        parent.child=nil
        parent.content=ret
        
    end
    

    return parent
end
function P.generateparamsfromargument(node)
    local str=node.type or node.content
    if(node.child)then
        for k, v in ipairs(node.child) do
            if(str==nil)then
                str=v.content
            else
               str=str.."|"..v.content
            end
        end
    end
    return P.generatetable(str)
end
function P.generatestringfromparams(params)
    local str
    for _,v in pairs(params) do
        if(not str) then
            str=v
        else
            str=str.."|"..v
        end
       
    end
    return str
end
function P.generatecontent(node)
    local str= ""
    if(node.child)then
        for i=1,#node.child do
            if(node.child[i].content and node.child[i].content:len()>0)then
                if(str=="")then
                    str=node.child[i].content

                else
                    str=str.."|"..node.child[i].content
                end
            end
        end
    else
        str=node.content
    end
    return str
end
function P.stringnizenode(parent,templates,params,context)
    local str=""
    --チェック
    if(parent.name=="tag")then
        local typ=parent.type
        if(typ=="!")then
            str=str.."|"
        else
            --テンプレート呼び出し
            local template=templates[typ]
            if(template)then
                local coparams=P.generateparamsfromargument(parent)
                local node=P.generatenode(template,{},coparams)
                str=str..P.stringnizenode(node,templates,coparams,context)

            else
                 --無ければ無変換で突っ込む
                local coparams=P.generateparamsfromargument(parent)
                if(table.elemn(coparams)==0)then
                    str=str.."{{"..parent.type.."}}"
                else
                    str=str.."{{"..parent.type.."|"..P.generatestringfromparams(coparams).."}}"
                end
            end
        end
    elseif(parent.name=="paramcall")then
        str=str..(parent.content or "")
    elseif(parent.name=="special")then
        --TODO
    elseif(parent.name=="text")then
        str=str..(parent.content or "")
    end
    if(parent.child and parent.name~="paramcall"and parent.name~="tag"and parent.name~="special")then
        for k,v in ipairs(parent.child) do
            str=str..P.stringnizenode(v,templates,params,context)
        end
    end

    return str
end
WIKIHELP_MEDIAWIKIPREPROCESSOR=P

