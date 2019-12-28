WIKIHELP_MEDIAWIKITEMPLATES={
    ["Infobox Class"]=[==[
{| class="infobox" style="font-size:89%; width:300px;"
|-
! colspan="6" style="background-color:#{{ClassColors|{{{1|{{{tree}}}}}}}}; color:#ffffff; font-size:120%; padding:1em;" | {{{name|{{PAGENAME}}}}}
|- style="text-align:center;"
| colspan="6" style="padding:0.5em;" | [[File:ICO_{{{icon|{{PAGENAME}}}}}.png|{{{icon width|100}}}px|link=]]
|-

{{#if:{{{costume B<includeonly>|</includeonly>}}} |
{{!}}colspan="6" style="text-align: center; padding:0.5em;"{{!}}
{{#tag:tabber|
{{{tab name A|{{{costume A|Default}}}}}}=[[File:SPR_{{{image|{{{costume A|{{PAGENAME}}}}}}}}{{{ext A|{{{ext|.png}}}}}}|{{{image width|250}}}px]]
{{!}}-{{!}}
{{{tab name B|{{{costume B|B}}}}}}=[[File:SPR_{{{costume B|{{PAGENAME}}B}}}{{{ext B|.png}}}|{{{imag ewidth|250}}}px]]
{{!}}-{{!}}
{{#if:{{{costume C<includeonly>|</includeonly>}}} |
{{{tab name C|{{{costume C|C}}}}}}=[[File:SPR_{{{costume C|{{PAGENAME}}C}}}{{{ext C|.png}}}|{{{image width|250}}}px]]
{{!}}-{{!}}
}}
{{#if:{{{costume D<includeonly>|</includeonly>}}} |
{{{tab name D|{{{costume D|D}}}}}}=[[File:SPR_{{{costume D|{{PAGENAME}}D}}}{{{ext D|.png}}}|{{{image width|250}}}px]]
{{!}}-{{!}}
}}
{{#if:{{{costume E<includeonly>|</includeonly>}}} |
{{{tab name E|{{{costume E|E}}}}}}=[[File:SPR_{{{costume E|{{PAGENAME}}E}}}{{{ext E|.png}}}|{{{image width|250}}}px]]
{{!}}-{{!}}
}}
}}
{{!}}-
|
{{!}}colspan="6" style="text-align:center; padding:0.5em;"{{!}}[[File:SPR_{{{image|{{PAGENAME}}}}}{{{ext|.png}}}|{{{image width|250}}}px]]
{{!}}-
}}
! colspan="6" style="background-color:#{{ClassColors|{{{1|{{{tree}}}}}}}}; color:#ffffff;" | Basic Information
|-
! colspan="2" style="text-align: left;" | '''Class Tree'''
| colspan="4" style="text-align: left;" | {{#switch: {{{1|{{{tree}}}}}}
| 1 = [[Archer]]
| 2 = [[Cleric]]
| 3 = [[Scout]]
| 4 = [[Swordsman]]
| 5 = [[Wizard]]
| 6 = '''Removed'''
| #default = {{{1|{{{tree|''Not Assigned''}}}}}}
}}
|-
! colspan="2" style="width:50%; text-align: left;" | '''Class Master'''
| colspan="4" style="width:50%; text-align: left;" | {{#if:{{{master B|}}} | 
[[{{{3|{{{master|Unknown}}}}}}]] <br/>[[{{{master B}}}]]|[[{{{3|{{{master|Unknown}}}}}}]]
}}
|-
! colspan="2" style="width:50%; text-align: left;" | '''Release Date (kToS)'''
| colspan="4" style="width:50%; text-align: left;" | {{{4|{{{release ktos|''Unknown''}}}}}}
|-
! colspan="2" style="width:50%; text-align: left;" | '''Release Date (iToS)'''
| colspan="4" style="width:50%; text-align: left;" | {{{5|{{{release itos|''Unknown''}}}}}}
|-
{{#if:{{{spelling<includeonly>|</includeonly>}}} |
{{!}} colspan="2" style="width:50%;"{{!}}'''Original Spelling'''
{{!}} colspan="2" style="width:50%;"{{!}}{{{spelling|}}}
{{!}}-
}}
! colspan="2" style="width:50%; text-align: left;" | '''Korean Spelling'''
| colspan="4" style="width:50%; text-align: left;" | {{{2|{{{korean|''Unknown''}}}}}}
|-
{{#if:{{{internal<includeonly>|</includeonly>}}} |
{{!}} colspan="2" style="width:50%;"{{!}}'''Internal Name'''
{{!}} colspan="2" style="width:50%;"{{!}}{{{internal|}}}
{{!}}-
}}
! colspan="6" style="background-color:#{{ClassColors|{{{1|{{{tree}}}}}}}}; color:#ffffff;" | Class Characteristics
|-
! colspan="2" style="width:50%; text-align: left;" | '''Type'''
| colspan="4" style="width:50%; text-align: left;" | {{#switch: {{{6|{{{type}}}}}}
| 1 = Offensive
| 2 = Defensive
| 3 = Support
| 4 = Summoner
| 5 = Craftsman
| 6 = Rider
| 7 = Unique
| #default = ''Not Assigned''
}}
|-
{{#if:{{{7|{{{damage<includeonly>|</includeonly>}}}}}} |
{{!}} colspan="2" style="width:50%;"{{!}}'''Primary Damage'''
{{!}} colspan="4" style="width:50%;"{{!}}{{{7|{{{damage<includeonly>|</includeonly>}}}}}}
{{!}}-
}}
{{#if:{{{8|{{{weapon<includeonly>|</includeonly>}}}}}}|
{{!}} colspan="2" style="width:50%;"{{!}}'''Main Weapon'''
{{!}} colspan="4" style="width:50%;"{{!}}{{{8|{{{weapon<includeonly>|</includeonly>}}}}}}
{{!}}-
}}
{{#if:{{{9|{{{item<includeonly>|</includeonly>}}}}}} |
{{!}} colspan="2" style="width:50%;"{{!}}'''Associated Catalysts'''
{{!}} colspan="4" style="width:50%;"{{!}}{{{9|{{{item|''Not Assigned''}}}}}}
{{!}}-
}}
{{#if:{{{companion<includeonly>|</includeonly>}}} |
{{!}} colspan="6" style="text-align:center;" {{!}} '''Requires''' {{#switch: {{{companion<includeonly>|</includeonly>}}}
| 1 = '''Ground Companion'''
| 2 = '''Flying Companion'''
| #default = '''None'''
}}
{{!}}-
}}
! colspan="6" style="background-color:#{{ClassColors|{{{1|{{{tree}}}}}}}}; color:#ffffff;" | Stat Distribution
|-
| colspan="6" | {{#if:{{{altstat|}}}|{{#tag:tabber|
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

        
        
]==],
    ["ClassColors"]=[==[
{{#switch: {{{1|{{{i}}}}}}
| 1 = 228822
| 2 = 1188EE
| 3 = EE8811
| 4 = DD1100    
| 5 = 9944DD
| 6 = 000000
| #default = 004444
}}
]==],
}