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
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
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
    local minimatch=str:gsub("{.*}",""):match("^(.-)[\n|%|]")
    if(minimatch)then
        --分解
        local spr=minimatch:splitsafe(" ","[\"{}]")
        for _,v in ipairs(spr) do
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
        return attrib,str:sub(str:match("^(.-)[\n|%|]"):len()+1)
    else
        return attrib,nil
    end
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
        name = "alignline",
        begin = "<",
        regex = "<(.-)>",
        attrib_fn = function(def, str, hit)
            local attr = {}
            if (hit == "center" or hit == "left" or hit == "right") then
                attr.horzalign = hit
                return attr
            end
            return nil
        end,
    },
    {
        name = "table",
        begin = "{|",
        regex = "{%|(.-)[\n]",
        attrib_fn = function(def, str, hit)
            local attr,remain=P.htmlattribparser(hit,{})
 
            return attr,remain
        end,
        isdiv = true,
        head = true,
    },
    {
        name = "tr",
        begin = "|-",
        regex = "%|%-(.-)[\n]",
        attrib_fn = function(def, str, hit)
            local attr,remain=P.htmlattribparser(hit,{})

            return attr,remain
        end,
        isdiv = true,
        head = true,
    },
    {
        name = "tr",
        begin = "|+",
        regex = "%|%-(.-)[\n]",
        isdiv = true,
        head = true,
        attrib_fn = function(def, str, hit, line)
            local attr,remain=P.htmlattribparser(hit,{})
            attr.header=true      

            return attr,remain
      
        end,
    },
    {
        name = "td",
        begin = "|",
        regex = "%|(.-)[\n]",
        content_fn = function(def, str, hit, line)
            for vv in line:gmatch(def.regex) do
                return vv
            end
        end,
        attrib_fn = function(def, str, hit)
            local attr,remain=P.htmlattribparser(hit,{})
            
 
            return attr,remain
        end,
        isdiv = true,
        head = true,
    },
    {
        name = "td",
        begin = "!",
        regex = "%!(.-)[\n]",
        content_fn = function(def, str, hit, line)
            for vv in line:gmatch(def.regex) do
                return vv
            end
        end,
        attrib_fn = function(def, str, hit, line)
            local attr,remain=P.htmlattribparser(hit,{})
            attr.header=true
  
         
            return attr,remain
      
        end,
        isdiv = true,
        head = true,
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
            return {level=str:match("([%*-:;]*)"):len()}
        end,
        isdiv = true,
        head=true
    },
    {
        begin = ":",
        name = "li",
        regex = "%*(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("([%*-:;]*)"):len()}
        end,
        isdiv = true,
        head=true
    },
    {
        begin = ";",
        name = "li",
        regex = "%*(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("([%*-:;]*)"):len()}
        end,
        isdiv = true,
        head=true
    },
    {
        begin = "-",
        name = "li",
        regex = "%*(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("([%*-:;]*)"):len()}
        end,
        isdiv = true,
        head=true
    },
    {
        begin = "#",
        name = "ln",
        regex = "#(.-)\n",
        attrib_fn = function(def, str, hit)
            return {level=str:match("(#*)"):len()}
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
        name = "template",
        begin = "{{",
        ends="}}",
        attrib_fn = function(def, str, hit)
            local spr=hit:split("|")

            return {name=spr[1],split=spr}
        end,
        matroshka=true,
        head=true,
    },
}

function P.parse(node, str,pagename)
    local pos = 1
    local textbuf = ""
    node = node or {}
    node.attrib = node.attrib or {}
    node.attrib.pagename=pagename
    local line = ""
    local linepos = 1
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
                if (tag.head) then
                    result = line:starts(tag.begin)
                else
                    result = substr:starts(tag.begin)
                end
                if (result) then
                    local content
                    node.child = node.child or {}
                    
                    if(tag.matroshka)then
                        local count=0
                        local ppos=pos
                        while ppos <= str:len() do
                            local msubstr = str:sub(ppos)
                            if(msubstr:starts(tag.begin))then
                                count=count+1
                            end
                            if(msubstr:starts(tag.ends))then
                                count=count-1
                            end
                            if(count==0) then
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
                            P.parse(child, str)
                        else
                            if (tag.isdiv and content) then
                                P.parse(child, content)
                            end
                        end
                        pos = pos + total:len()+tag.ends:len()
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
                                    P.parse(child, content)
                                end
                                if(content)then
                                    local _,pp=substr:find(tag.regex)
                                    pos = pos + pp
                                else
                                    pos = pos + 0
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
        local find=str:find("\n",linepos)
        if (find and (find)<=pos) then
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





























