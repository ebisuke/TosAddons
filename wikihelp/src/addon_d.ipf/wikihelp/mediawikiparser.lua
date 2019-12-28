--parser
local P = {}
if (not session and not ebi_utf8) then
    ebi_utf8 = loadfile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\utf8.lua")()
    dofile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\mediawikipreprocessor.lua")
    dofile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\mediawikitemplates_sample.lua")
    dofile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\mediawikipages_sample.lua")
end
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
function string.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
 end
function string.splitsafe(str, ts,ignore)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end
    
    local t = {};
    local ignoremode=false
    local textbuf=""
    local i=1
    while i<=str:len() do
        local sstr=str:sub(i)
        if(sstr:find(ignore)==1)then
            ignoremode=not ignoremode
            i=i+1
        elseif(not ignoremode and sstr:starts(ts))then
            t[#t+1]=textbuf
            textbuf=""
            i=i+ts:len()
        else
            textbuf=textbuf..sstr:sub(1,1)
            i=i+1
        end
        
    end
    if(textbuf:len()>0)then
        t[#t+1]=textbuf
    end
    
    return t
end
function string.splitbar(str)
    local t = {};
    local ignoremode=false
    local textbuf=""
    local i=1
    local lvl=0
    local head=true
    while i<=str:len() do
        local sstr=str:sub(i)
        if(sstr:starts("\n"))then
            head=true
            textbuf=textbuf..sstr:sub(1,1)
        else
            if(sstr:find("[%[({]")==1)then
                lvl=lvl+1
            elseif(sstr:find("[%])}]")==1)then
                lvl=lvl-1
            elseif (lvl==0 and not head and sstr:starts("|")) then
                t[#t+1]=textbuf
                textbuf=""
            else
                textbuf=textbuf..sstr:sub(1,1)
               
            end
            head=false
        
        end
        i=i+1
    end
    if(textbuf:len()>0)then
        t[#t+1]=textbuf
    end
    
    return t
end
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
function string.findstringnorebracebracket(str,ts)
    local lvl=0
    for i = 1, str:len() do
        local substr=str:sub(i)
        if(substr:starts("{")or substr:starts("["))then
            lvl=lvl+1
        elseif (substr:starts("}")or substr:starts("]"))then
            lvl=lvl-1
            
        elseif(substr:starts(ts))then
            if(lvl==0)then
                return str:sub(1,i-1),i-1
            end
        end
    end
    return nil,nil
end
function string.splitignorebracebracket(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end
    
    local t = {};
    local lvl=0
    local textbuf=""
    local i=1
    while i<=str:len() do
        local sstr=str:sub(i)
        if(sstr:starts("{") or sstr:starts("["))then
            lvl=lvl+1
            i=i+1
            textbuf=textbuf..sstr:sub(1,1)
        elseif(sstr:starts("}") or sstr:starts("]"))then
            lvl=lvl-1
            i=i+1
            textbuf=textbuf..sstr:sub(1,1)
        elseif(lvl==0 and sstr:find(ts)==1)then
            t[#t+1]=textbuf
            textbuf=""
            i=i+ts:len()
        else
            textbuf=textbuf..sstr:sub(1,1)
            i=i+1
        end
        
    end
    if(textbuf:len()>0)then
        t[#t+1]=textbuf
    end
    
    return t
end
function P.htmlstyleparser(str)
    local style={}
    --分解
    local spr=str:split(";")
    for _,v in ipairs(spr) do
        --さらに:で分解
        local eq=v:split(":")
        if(#eq==2)then
            style[eq[1]:trim()]=eq[2]:trim()
        end
    end
    return style
    
end

function P.htmlattribparser(str,attrib)
    str=str.."\n"   --便宜的に
    local match=string.findstringnorebracebracket(str:match("(.-)\n"),"|")
    local recover
    local spr

    if(match)then
        spr=str:trim():splitignorebracebracket("|")
        recover=spr[2]
        for i=3,#spr do
            recover="|"..spr[i]
        end

        
    else
        match=str:match("(.-)\n")
        recover=str:sub(match:len()+1)
        spr=str:trim():splitignorebracebracket("|")
    end
    
    if(match)then
        --分解
        local spl=match:splitsafe(" ","[\"{}]")
        for _,v in ipairs(spl) do
            --さらに=で分解
            local eq=v:split("=")
            if(#eq==2)then
                attrib[eq[1]:trim()]=eq[2]:trim()
            end
        end
        if(attrib.style)then
            attrib.styleraw=attrib.style
            attrib.style=P.htmlstyleparser(attrib.style)
        end
        
        return attrib,recover
    end
    return attrib,""
    
end
local tags = {
    {
        name = "text",
    },
    {
        name = "link",
        begin = "[[",
        regex = "%[%[(.-)%]%]",
        attrib_fn = function(def, str, hit)
            local attr = {}
            
            if (hit:starts("File:")) then
                local substr = hit:sub(6)
                local spr=hit:split("%|")
                for _,v in ipairs(spr) do
                    if (v:starts("File: ")) then
                        --filename
                        attr.filename = v:sub(7)
                    elseif (v == "center" or v == "left" or v == "right") then
                        attr.horzalign = v
                    elseif (v:starts("link=")) then
                        attr.link = v:sub(6)
                    elseif (v:starts("thumb")) then
                        attr.thumb = true
                    elseif (v:find("x%)") and v:find("px")) then
                        for x, y in v:gmatch("(.-)x(.-)px") do
                            attr.sizex = x;
                            attr.sizey = y;
                            break
                        end
                    end
                
                end
            else
                --link
                attr.link = str
            end
            return attr
        end,
    },
    {
        name = "div",
        begin = "<div",
        regex = "<div(.-)>",
        ends="</div>",
        matroshka=true,
        isdiv=true,
    },
    {
        name = "br",
        begin = "<br",
        regex = "<br(.-)/>",
    },
    {
        name = "span",
        begin = "<span",
        regex = "<span.->(.-)</span>",
        
        isdiv=true,
    },
    {
        name = "font",
        begin = "<font",
        regex = "<font.->(.-)</font>",
        
        isdiv=true,
    },
    {
        name = "table",
        begin = "{|",
        attrib_fn = function(def, str, hit)
            local attr,remain=P.htmlattribparser(hit,{})
 
            return attr,remain
        end,
        ends={"|}"},
        matroshka=true,
        isdiv = true,
        head = true,

    },
    {
        name = "tr",
        begin = "|-",
        ends={"|-","|+","|}"},
        attrib_fn = function(def, str, hit)
            local attr,remain=P.htmlattribparser(hit,{})

            return attr,remain
        end,
        matroshka=true,
        isdiv = true,
        head = true,
        noaddfinal=true,
    },
    {
        name = "tr",
        begin = "|+",
        isdiv = true,
        head = true,
        matroshka=true,
        ends={"|-","|+","|}"},
        attrib_fn = function(def, str, hit, line)
            local attr,remain=P.htmlattribparser(hit,{})
            attr.header=true      

            return attr,remain
      
        end,
        noaddfinal=true,
    },
    {
        name = "td",
        begin = "|",
        regex="%|(.-)\n",
        content_fn = function(def, str, hit, line)
            for vv in line:gmatch(def.regex) do
                return vv
            end
        end,
        attrib_fn = function(def, str, hit)
            local attr,remain=P.htmlattribparser(hit:trim(),{})
            
 
            return attr,remain
        end,
        isdiv = true,
        head = true,
        noaddfinal=true,
    },
    {
        name = "td",
        begin = "!",
        regex="!(.-)\n",
        content_fn = function(def, str, hit, line)
            for vv in line:gmatch(def.regex) do
                return vv
            end
        end,
        attrib_fn = function(def, str, hit, line)
            local attr,remain=P.htmlattribparser(hit:trim(),{})
            attr.header=true
  
         
            return attr,remain
      
        end,
        isdiv = true,
        head = true,
        noaddfinal=true,
    },
    {
        begin = "-",
        name = "hr",
        regex = "%-.*\n",
        attrib_fn = function(def, str, hit)
            return {},nil
        end,
        head=true
    },
    {
        begin = "<nowiki>",
        name = "ignore",
        regex = "<nowiki>(.-)</nowiki>",
        attrib_fn = function(def, str, hit)
            
        end,
        isdiv = true,
        head=true
    },
    {
        begin = "<br />",
        name = "br",
        regex = "<br />",
    },
    {
        begin = "*",
        name = "li",
        regex = "%*(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("([*-:;]*)"):len()},str:match("[*-:;]*(.*)$")
        end,
        isdiv = true,
        head=true
    },
    {
        begin = ":",
        name = "li",
        regex = "%:(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("([*-:;]*)"):len()},str:match("[*-:;]*(.*)$")
        end,
        isdiv = true,
        head=true
    },
    {
        begin = ";",
        name = "li",
        regex = "%;(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("([*-:;]*)"):len()},str:match("[*-:;]*(.*)$")
        end,
        isdiv = true,
        head=true
    },
    {
        begin = "-",
        name = "li",
        regex = "%-(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("([*-:;]*)"):len()},str:match("[*-:;]*(.*)$")
        end,
        isdiv = true,
        head=true
    },
    {
        begin = "#",
        name = "ln",
        regex = "#(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("(#*)"):len()},str:match("#*(.*)$")
        end,
        isdiv = true,
        head=true
    },
    {
        begin = "'''",
        name = "font",
        regex = "'''(.-)'''",
        attrib_fn = function(def, str, hit)
            return {bold=true}
        end,
        isdiv = true,
    
    },
    {
        begin = "''",
        name = "font",
        regex = "''(.-)''",
        attrib_fn = function(def, str, hit)
            return {bold=true}
        end,
        isdiv = true,
    
    },

    {
        begin = "''",
        name = "font",
        regex = "'(.-)'",
        attrib_fn = function(def, str, hit)
            return {}
        end,
        isdiv = true,
    
    },
    {
        name = "extlink",
        begin = "[",
        regex = "%[(.-)%]",
        attrib_fn = function(def, str, hit)
            return {link = hit}
        end,
    },
    {
        name = "header",
        begin = "==",
        regex = "==*(.-)==*\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("(==*)"):len()}
        end,
        head = true,
        isdiv=true,
    },
    {
        name = "gallery",
        begin = "<gallery",
        regex = "<gallery(.-)</gallery>",
        attrib_fn = function(def, str, hit)
           return {}
        end,
        head=true,
    },
    {
        name = "tag",
        begin = "<",
        regex = "<.->(.-)</.->",
        attrib_fn = function(def, str, hit,total)
           return {},hit
        end,
        divide=true,
    },
    {
        name = "template",
        begin = "{{",
        ends={"}}"},
        attrib_fn = function(def, str, hit)
            local spr=hit:splitignorebracebracket("|")

            return {name=spr[1],split=spr}
        end,
        matroshka=true,
    },
}

function P.parse(node, str,pagename,head)
    local pos = 1
    local textbuf = ""
    node = node or {}
    node.attrib = node.attrib or {}
    node.attrib.pagename=pagename
    if head == nil then
        head=true
    end
    local line = ""
    local linepos = 1
    local forcehead=false
    if(str==nil)then
        print("ERROR! str is nil")
        return
    end
    --便宜的に改行を入れる
    str=str.."\n"
    while pos <= str:len() do
        local hit = false
        local substr = str:sub(pos)
        line = str:sub(linepos, str:find("\n", linepos + 1) or -1)
        for _, tag in ipairs(tags) do
            local result
            if (tag.begin) then
                
                result = substr:starts(tag.begin)
                if tag.head then
                    result=result and head
                end
                if (result) then
                    local content
                    node.child = node.child or {}
                    if(tag.divide)then
                        local content
                        local treg=tag.regex:gsub("[()]","")
                        local total=substr:match(treg)
                        content=substr:match(tag.regex)
                        if(content~=nil)then
                            if (textbuf:len() > 0) then
                                node.child[#node.child + 1] = {
                                    name = "text",
                                    content = textbuf,
                                    parent=node,
                                }
                                textbuf = ""
                            end
                            node.child[#node.child + 1] = {
                                name = tag.name,
                                tag = tag,
                                parent=node,
                            }
                            local child = node.child[#node.child]
                        
                            child.content = content;
                            local attrib={}
                            local attrib_remain
                            if (tag.attrib_fn) then
                                attrib,attrib_remain = tag.attrib_fn(tag, substr, content, total)
                            end
                            child.attrib=attrib
                            if(attrib_remain)then
                                content=attrib_remain
                            end
                            --split by |
                            local spr=content:splitbar()
                            for _,v in ipairs(spr) do
                                local cc
                                child.child=child.child or {}
                                child.child[#child.child+1] = {
                                    name="split",
                                    content=v,
                                    parent=child,
                                }
                                cc=child.child[#child.child]

                                --値が含まれているか検証
                                local eq=v:match("(.-)=")
                                local val=v:match(".-=(.*)$")
                                if eq then
                                    cc.key=eq
                                    P.parse(cc, val,pagename)
                                else
                                    P.parse(cc, v,pagename)
                                end
                                
                            end
                            pos = pos + total:len()
                            hit = true
                            break
                        end
                    elseif(tag.matroshka)then
                        local count=0
                        local ppos=pos+tag.begin:len()
                        local final=""
                        local lvl=0
                        while ppos <= str:len() do
                            local hit=false
                            local msubstr = str:sub(ppos)
                            if(msubstr:starts(tag.begin))then
                                hit=true
                                count=count+1
                            elseif(msubstr:starts("{") or msubstr:starts("["))then
                                lvl=lvl+1
                            elseif (msubstr:starts("}") or msubstr:starts("]"))then
                                lvl=lvl-1
                            end
                            
                            for _,v in ipairs(tag.ends)do
                                if(msubstr:starts(v))then
                                    hit=true
                                    count=count-1
                                    final=v
                                    break
                                end
                            end
                            
                            if(hit and count<=0 and lvl<=0) then
                                break
                            end
                            ppos=ppos+1
                        end
                        local content
                        local total=substr:sub(1,ppos-pos)
                        if(tag.regex)then
                            content=str:sub(pos+substr:match(tag.regex:gsub("%(",""):gsub("%)","")):len(),ppos)
                        else
                            content=substr:sub(tag.begin:len()+1,ppos-pos)
                        end
                       
                        if (textbuf:len() > 0) then

      
                            node.child[#node.child + 1] = {
                                name = "text",
                                content = textbuf,
                                parent=node,
                            }

                            textbuf = ""
                        end
                        node.child[#node.child + 1] = {
                            name = tag.name,
                            tag = tag,
                            parent=node,
                        }
                        local child = node.child[#node.child]
                       
                        child.content = content;
                        local attrib={}
                        local attrib_remain
                        if (tag.attrib_fn) then
                            attrib,attrib_remain = tag.attrib_fn(tag, substr, content, line)
                        end
                        child.attrib=attrib
                        if(attrib_remain)then
                            content=attrib_remain
                        end
                        
                        if(tag.name=="template" and WIKIHELP_MEDIAWIKITEMPLATES[attrib.name])then
                            local PRE=WIKIHELP_MEDIAWIKIPREPROCESSOR
                            local template=PRE.removestuff(WIKIHELP_MEDIAWIKITEMPLATES[attrib.name])
                            local params=PRE.generatetable(content)
                            local node=PRE.generatenode(template,{},params,{pagename=pagename})
                            local str=PRE.stringnizenode(node,WIKIHELP_MEDIAWIKITEMPLATES,params,{pagename=pagename})
                            child.content=str
                            P.parse(child, str,pagename,head)
                        else
                            if (tag.isdiv and content) then
                                P.parse(child, content,pagename,head)
                            end
                        end
                        if tag.noaddfinal then
                            pos = pos + total:len()
                            forcehead=true
                        else
                            pos = pos + total:len()+final:len()
                        end
                        hit = true
                        break
                    else
                        for v in string.gmatch(substr, tag.regex) do
                            --hit
                            if (tag.content_fn) then
                                content = tag.content_fn(tag, substr, v,line)
                            else
                                content = v
                            end
                            break
                        end
                        if(content~=nil) then
                            local attrib={}
                            local attrib_remain
                            if (tag.attrib_fn) then
                                attrib,attrib_remain = tag.attrib_fn(tag, substr, content, line)
                            end
                            if(attrib_remain)then
                                content=attrib_remain
                            end
                            if(attrib==nil)then
                            else
                                if (textbuf:len() > 0) then
                                    

                                    node.child[#node.child + 1] = {
                                        name = "text",
                                        content = textbuf,
                                        parent=node,
                                    }
        
                                    textbuf = ""
                                end
                                node.child[#node.child + 1] = {
                                    name = tag.name,
                                    tag = tag,
                                    attrib=attrib,
                                    parent=node,
                                }
                                local child = node.child[#node.child]
                                child.content = content
                                if (tag.isdiv and content) then
                                    P.parse(child, content,pagename,head)
                                end
                                if(content)then
                                    local _,pp=substr:find(tag.regex)
                                    pos = pos + pp
                                else
                                    pos = pos + 0
                                end
                                if tag.noaddfinal or tag.head then
        
                                    forcehead=true
                                end
                                hit = true
                                break
                            
                            end
                        end
                    end
                end
            end
        end
        if (not hit) then
            pos = pos + 1
            if not (substr:starts("\n")) then
                textbuf = textbuf .. substr:sub(1, 1)
            end
        end
        if(substr:starts("\n") or forcehead)then
            head=true
            forcehead=false
        else
            head=false
        end

        if (substr:starts("\n")) then
            linepos = pos
            if (textbuf:len() > 0) then
                node.child = node.child or {}

                node.child[#node.child + 1] = {
                    name = "text",
                    content = textbuf,
                    parent=node,
                }

                textbuf = ""
            end
        end
    end
    if (textbuf:len() > 0) then
        node.child = node.child or {}
        node.child[#node.child + 1] = {
            name = "text",
            content = textbuf
        }

        textbuf = ""
    end
    return node
end
function P.dump(node)
    if(node.name=="text")then
        print(node.content)
    end
    if(node.child)then
        for _,v in ipairs(node.child) do
            P.dump(v)
        end
    end
end
WIKIHELP_MEDIAWIKIPARSER = P


local test = P.parse({},WIKIHELP_MEDIAWIKIPAGES_SAMPLE["Oracle"],"Oracle")
P.dump(test)