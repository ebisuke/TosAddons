local P = {}
if (not ebi_utf8) then
    ebi_utf8 = loadfile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\utf8.lua")()
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
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
function P.generatetable(substr,template)
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
function P.paramcall(params,str)
    --findend
    local count=0
    local endpos
    local pos=1

    local start
    while pos <= str:len() do
      
        local substr=str:sub(pos)
        if substr:starts("{{{")then
            if(count==0)then
                start=pos
            end
            count=count+1
            pos=pos+3
        elseif substr:starts("}}}")then
            count=count-1
            if(count<=0)then
                endpos=pos+2
                break
            end
            pos=pos+3
        else
            pos=pos+1
        end
    end

    local replaced=str
    local sstr
    if(endpos)then
        sstr=str:sub(start+3,endpos-3)
    else
        sstr=str  \
    end
    if(sstr:find("{{{"))then
        sstr=P.paramcall(params,sstr)
    end
    if(endpos)then
        replaced=str:sub(1,start-1)..sstr..str:sub(endpos,-2)
    
    else
        replaced=sstr
    end
    
    --パラメタ処置
    local spr=string.split(replaced,"|")
    local rparam
    for k,v in ipairs(spr) do
        local param=params[v]
        if(param)then
            rparam=param
            break
        end
    end
    if(#spr>=2)then
        rparam=rparam or spr[#spr]
    else
        rparam=rparam or ""
    end
    
    replaced=rparam
    return replaced,endpos
end
function P.extracttable(params,template,templates,context)
    local str=P.removestuff(template)
    
    local pos=1
    while pos<=str:len() do
        local substr=str:sub(pos)
        
        if substr:starts("{{{")then
            --パラメータ呼び出し
            local count=0
            for ppos=pos,str:len() do
                local sstr=str:sub(ppos)
                if(sstr:starts("{"))then
                    count=count+1
                elseif(sstr:starts("}"))then
                    count=count-1
                    if(count==0)then
                        local replaced=P.paramcall(params,substr:sub(4,ppos-pos+1-3))
                        
                        --置換
                        str=str:sub(1,pos-1)..replaced..str:sub(ppos+1,-1)
                    
                        break
                    end

                end
            end
            pos=pos+1
        else
            pos=pos+1
        end
    end
    pos=1
    while pos<=str:len() do
        local substr=str:sub(pos)
        if substr:starts("{{") then
            --マジックのみ処理
            local regex="({{.-}})"
            local _,_,match=substr:find(regex)
            if(match=="{{!}}")then
                substr=substr:gsub(regex,"|",1)
                str=str:sub(1,pos-1)..substr
            elseif(match=="{{PAGENAME}}")then
                    substr=substr:gsub(regex,context.pagename,1)
                    str=str:sub(1,pos-1)..substr
            elseif(substr:starts("{{#if:"))then
                --終わりを探す
                local count=0
                for ppos=pos+1,str:len() do
                    local ss=str:sub(ppos)
                    if(ss:starts("{"))then
                        count=count+1
                    elseif(ss:starts("}"))then
                        count=count-1
                        if(count==0)then
                            local ifcondition=str:sub(pos+6,str:find("[\n%|}]",pos+6)-1)
                            
                            if(ifcondition~="")then
                                --valid
                                local value=params[ifcondition] or ifcondition
                                local sub=str:sub(ppos+2)
                                str=str:sub(1,pos-1)..value:gsub(" ","")..sub
                            else
                                --invalid
                                str=str:sub(1,pos-1)..str:sub(ppos)
                            end
                            break
                        end
                    end
                    
                end
            else
                
                pos=pos+1
                
            end
           
        else
            pos=pos+1
        end
       
    end
    --テンプレ用再展開処理
    local regex="{{(.-)}}"
    local pos=1
    local processed=str
    while true do
        local s,e,match=processed:find(regex,pos)
        if(s==nil)then
            break
        end
        --名前を取得
        
        local namer="(.-)%p"
        local _,_,templatename=match:find(namer)
        if(templates[templatename])then
            local inparams=P.generatetable(match,templatename)
            local ext=P.extracttable(inparams,templates[templatename],templates)
            --置換
            str=str:gsub(regex,ext,1)
        else
            pos=e+1
        end
    end
    return str
end
--テンプレートは辞書型
function P.preprocess(str,templates,context)
    local processed=str
    local regex="{{(.-)}}"
    local pos=1
    while true do
        local s,e,match=processed:find(regex,pos)
        if(s==nil)then
            break
        end
        --名前を取得
        
        local namer="(.-)%p"
        local _,_,templatename=match:find(namer)
        if(templates[templatename])then
            local params=P.generatetable(match,templatename,context)
            local ext=P.extracttable(params,templates[templatename],templates,context)
            --置換

            processed=processed:sub(1,s-1)..ext..processed:sub(e,-1)
        else
            pos=e+1
        end
    end
    return processed
end

WIKIHELP_MEDIAWIKIPREPROCESSOR=P


local templates={
    ["Infobox Class"]=[==[

{{{tab name A|Default={{StatChart|{{{str|0}}}|{{{con|0}}}|{{{int|0}}}|{{{spr|0}}}|{{{dex|0}}}}}}}}
    {{!}}-{{!}}
{{{tab name B|{{{altstat}}} Stat - {{PAGENAME}}={{StatChart|{{{int|0}}}|{{{con|0}}}|{{{str|0}}}|{{{dex|0}}}|{{{spr|0}}}}}}}}<br/><small>Enabled when attribute is ON</small>
{{!}}-{{!}}
}}|{{StatChart|{{{str|0}}}|{{{con|0}}}|{{{int|0}}}|{{{spr|0}}}|{{{dex|0}}} }}
}}

|-
|}<noinclude><br style="clear:both;" />
{{Infobox_Class/doc}}

[[Category:Infobox Templates]]</noinclude>
]==]

}

local tester=[==[
{{Infobox Class|2|오라클|Apolonija Barbora|15/12/2015|29/03/2016|3
| con=25 
| int=25 
| spr=50
}}

]==]

local result=P.preprocess(tester,templates,{pagename="Oracle"})
print(result)
result=result
