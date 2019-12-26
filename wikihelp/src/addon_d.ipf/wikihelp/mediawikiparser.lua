local P = {}
if (not ebi_utf8) then
    ebi_utf8 = loadfile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\utf8.lua")()
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
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
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
        regex = "{%|(.-)%|}",
        attrib_fn = function(def, str, hit)
            local style = "style=\"(.-);\""
            local attr = {}
            for v in hit:gmatch(style) do
                
                for key, vv in v:gmatch("(.-:.-)") do
                    if (key == "width") then
                        attr.width = vv
                    elseif (key == "margin") then
                        attr.margin = vv
                    elseif (key == "padding-top") then
                        attr.padding_top = vv:substr(1, -3)
                    elseif (key == "text-align") then
                        attr.text_align = vv
                    end
                end
            end
            return attr
        end,
        isdiv = true,
        head = true,
    },
    {
        name = "tr",
        begin = "|-",
        regex = "%|%-(.-)\n",
        isdiv = true,
        head = true,
    },
    {
        name = "tr",
        begin = "|+",
        regex = "%|%-(.-)\n",
        isdiv = true,
        head = true,
        attrib_fn = function(def, str, hit, line)
            return {header=true}
        end,
    },
    {
        name = "td",
        begin = "|",
        regex = "%|(.-)\n",
        content_fn = function(def, str, hit, line)
            for vv in line:gmatch(def.regex) do
                return vv
            end
        end,
        attrib_fn = function(def, str, hit, line)
            return {}
        end,
        isdiv = true,
        head = true,
    },
    {
        name = "td",
        begin = "!",
        regex = "%!(.-)\n",
        content_fn = function(def, str, hit, line)
            for vv in line:gmatch(def.regex) do
                return vv
            end
        end,
        attrib_fn = function(def, str, hit, line)
            return {header=true}
        end,
        isdiv = true,
        head = true,
    },
    {
        begin = "-",
        name = "hr",
        regex = "%-.*\n",
        attrib_fn = function(def, str, hit)
            
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
        begin = "'''''",
        name = "font",
        regex = "''(.-)''",
        attrib_fn = function(def, str, hit)
            return {bold=true}
        end,
        isdiv = true,
    
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
}

function P.parse(node, str)
    local pos = 1
    local textbuf = ""
    node = node or {}
    local line = ""
    local linepos = 1
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
                if (tag.regex and result) then
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
                        local content=str:sub(pos+substr:match(tag.regex:gsub("%(",""):gsub("%)","")):len(),ppos+tag.ends:len())
                        if (textbuf:len() > 0) then
      
                            node.child[#node.child + 1] = {
                                name = "text",
                                content = textbuf
                            }
            
 
                            textbuf = ""
                        end
                        node.child[#node.child + 1] = {
                            name = tag.name,
                            tag = tag,
                        }
                        local child = node.child[#node.child]
                        child.content = content;
                        local attrib={}
                        if (tag.attrib_fn) then
                            attrib = tag.attrib_fn(tag, substr, content, line)
                        end
                        if (tag.isdiv and content) then
                            P.parse(child, content)
                        end
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
                            if (tag.attrib_fn) then
                                attrib = tag.attrib_fn(tag, substr, content, line)
                            end
                            if(attrib==nil)then
                            else
                                if (textbuf:len() > 0) then
                                    

                                    node.child[#node.child + 1] = {
                                        name = "text",
                                        content = textbuf
                                    }
        
                                    textbuf = ""
                                end
                                node.child[#node.child + 1] = {
                                    name = tag.name,
                                    tag = tag,
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
        if ( find and (find)<pos) then
            linepos = pos
            if (textbuf:len() > 0) then
                node.child = node.child or {}

                node.child[#node.child + 1] = {
                    name = "text",
                    content = textbuf
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
WIKIHELP_MEDIAWIKIPARSER = P

local test = P.parse({}, [==[
{{Infobox Class|2|클레릭|Rozalija|15/12/2015|29/03/2016|3
| con=25
| int=30
| spr=45
| altstat = Physical
}}
'''{{PAGENAME}}''' have various skills that can either heal or buff allies in battle. They are largely a support class but they can be developed into a profession that plays a larger role in the front-lines as well as behind the scenes as support.

==Lore==
'''Clerics''' are former apprentice clergymen who have completed their training. For thousands of years, the '''Clerics''' are a group that has devoted their lives to studying and worshipping the Goddesses.

==Background==
''No data yet.''

==Icon and Outfit==
''No data yet.''

==Stat Multipliers==
'''{{PAGENAME}}''' have the following stat multipliers
{{PercentageBar|HP|EE8811|80|width=450|fieldWidth=120}}
{{PercentageBar|HP Recovery|DD6600|120|width=450|fieldWidth=120}}
{{PercentageBar|SP|1188EE|80|width=450|fieldWidth=120}}
{{PercentageBar|SP Recovery|004499|120|width=450|fieldWidth=120}}
{{PercentageBar|Physical Defense|EE1111|150|width=450|fieldWidth=120}}
{{PercentageBar|Magical Defense|00AAFF|150|width=450|fieldWidth=120}}
{{PercentageBar|Critical Resistance|11BB11|150|width=450|fieldWidth=120}}

==Weapons==
'''{{PAGENAME}}''' can use the following weapons by default:
* [[1h Mace]]
* [[1h Sword]]
* [[Rod]]
* [[Dagger]]
* [[Shield]]
The only weapon group exclusive to '''{{PAGENAME}}''' is '''[[2h Mace]]s'''.

==Skills and Attributes==
<tabber>
Tree View=
{| class="wikitable"
|-
{{TreeViewCell|Cure|Enhance}}
{{TreeViewCell|Fade}}<br/><br/>
{{TreeViewCell|Guardian Saint|Enhance}}
{{TreeViewCell|Heal|Linger|Enhance|Enhanced Upgrade}}
{{TreeViewCell|Smite|Enhance|Enhanced Upgrade}}
|-
{{TreeViewRow|One-handed Blunt Mastery - Healing|Two-handed Blunt Mastery - Strike|Physical Stat - Cleric|Cloth Mastery - Healing}}
|}
|-|
List View=
{| class="wikitable"
{{ListViewSkill}}
{{ListViewSkill|Cure|Active|Removes all removable debuffs affecting the target.}}
{{ListViewSkill|Fade|[[Buff]]|Erases the threat of monsters making them stop any attacks on you.}}
{{ListViewSkill|Guardian Saint|[[Buff]]|Increases the caster's Healing ability.}}
{{ListViewSkill|Heal|Active|Restores the HP of a designated target. The amount of HP restored depends on the caster's healing values. Repeated casting increases SP consumption that is dependent on the player's SPR stat.<br/>{{TextLink|Kabbalist|2}} - Heal factor increased by 10%.<br/>{{TextLink|Pardoner|2}} - '''[[SP|SP consumption]]''' reduced by 50.<br/>{{TextLink|Plague Doctor|2}} - '''Heal - Overload''' duration reduced by 0.7 second.<br/>{{TextLink|Priest|2}} - Heal factor increased by 5%. '''[[SP|SP consumption]]''' reduced by 25. '''Heal - Overload''' duration reduced by 0.3 second.}}
{{ListViewSkill|Smite|[[Strike Property|Strike]]|Strike down enemies with a powerful attack. Deals additional damage to Mutant- and Demon-type enemies.}}
|}

{| border="1" cellpadding="1" cellspacing="1" class="wikitable" style="width: 800px;"
{{ListViewAttribute}}
{{ListViewAttribute|One-handed Blunt Mastery - Healing|||5|Increases Healing by 2% per attribute level when equipping a one-handed blunt weapon.}}
{{ListViewAttribute|Two-handed Blunt Mastery - Strike|||1|•Strike damage +10% when equipping a [Two-handed Blunt] weapon.}}
{{ListViewAttribute|Physical Stat - Cleric|||1|Cleric's stat growth ratio is changed. INT ↔ STR, SPR ↔ DEX​}}
{{ListViewAttribute|Heal|Linger||10|Applies a buff that continuously restores the HP of allies healed with Heal or Mass Heal. The buff lasts 10 sec and restores HP in a value equal to [attribute level x 5]% of your Healing stat.|30}}
|-
{{ListViewArts}}
{{ListViewArts|Cloth Mastery - Healing|While equipped with 4 pieces of [Cloth] armor, your Attack is reduced by 5% in exchange for increasing Healing by the amount of Attack lost.<br/>'''Does not apply simultaneously with the''' {{TextLink|Cloth Mastery - Communion|2}} '''art.'''}}
|}
</tabber>
{{RemovedClassElement|1|Deprotected Zone|Divine Might|Safety Zone}}

== Advancements ==
{{ClassTable|Chaplain|Crusader|Dievdirbys|Druid|Exorcist|Inquisitor|Kabbalist|Krivis|Miko|Monk|Oracle|Paladin|Pardoner|Plague Doctor|Priest|Sadhu|Zealot}}

==Tips and Strategies==
''No data yet.''

==Gallery==
<gallery spacing="small" captionalign="center">
ToS_Cleric(M).gif|A male Cleric.
ToS_Cleric(F).gif|A female Cleric.
ToS ClericConcept.jpg|Old Cleric concept art.
</gallery>

==Trivia==
''No data yet.''

==References==
{{Reflist}}

==External links==
*[https://treeofsavior.com/page/class/view.php?c=Cleric Official Class Page]
*[https://tos.guru/itos/database/classes/4001 ToS Guru]
*[https://tos.neet.tv/skills?cls=Char4_1&f=1 ToS Neet]

{{ClassFooter|2}}
==History Log==
'''[[https://treeofsavior.com/page/news/view.php?n=1837 29/10/2019]]'''
* '''Stat growth redistributed'''
** '''[[STR]]''' - 12.5 → 0
** '''[[CON]]''' - 22.5 → 25
** '''[[INT]]''' - 12.5 → 30
** '''[[SPR]]''' - 40 → 45
** '''[[DEX]]''' - 12.5 → 0
* '''Added attributes'''
** {{TextLink|Physical Stat - Cleric|2}}
* '''Added arts'''
** {{TextLink|Cloth Mastery - Healing|2}}
** {{TextLink|Heal - Enhanced Upgrade|2}}
** {{TextLink|Smite - Enhanced Upgrade|2}}

{{PageProgress|2}}
    
]==])

test=test






























