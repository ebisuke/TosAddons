

local P={}
local function getcolorbyname(name)

    local tbl= {
        aliceblue = {0.94117647058824, 0.97254901960784, 1},
        antiquewhite = {0.98039215686275, 0.92156862745098, 0.84313725490196},
        aqua = {0, 1, 1},
        aquamarine = {0.49803921568627, 1, 0.83137254901961},
        azure = {0.94117647058824, 1, 1},
        beige = {0.96078431372549, 0.96078431372549, 0.86274509803922},
        bisque = {1, 0.89411764705882, 0.76862745098039},
        black = {0, 0, 0},
        blanchedalmond = {1, 0.92156862745098, 0.80392156862745},
        blue = {0, 0, 1},
        blueviolet = {0.54117647058824, 0.16862745098039, 0.88627450980392},
        brown = {0.64705882352941, 0.16470588235294, 0.16470588235294},
        burlywood = {0.87058823529412, 0.72156862745098, 0.52941176470588},
        cadetblue = {0.37254901960784, 0.61960784313725, 0.62745098039216},
        chartreuse = {0.49803921568627, 1, 0},
        chocolate = {0.82352941176471, 0.41176470588235, 0.11764705882353},
        coral = {1, 0.49803921568627, 0.31372549019608},
        cornflowerblue = {0.3921568627451, 0.5843137254902, 0.92941176470588},
        cornsilk = {1, 0.97254901960784, 0.86274509803922},
        crimson = {0.86274509803922, 0.07843137254902, 0.23529411764706},
        cyan = {0, 1, 1},
        darkblue = {0, 0, 0.54509803921569},
        darkcyan = {0, 0.54509803921569, 0.54509803921569},
        darkgoldenrod = {0.72156862745098, 0.52549019607843, 0.043137254901961},
        darkgray = {0.66274509803922, 0.66274509803922, 0.66274509803922},
        darkgreen = {0, 0.3921568627451, 0},
        darkgrey = {0.66274509803922, 0.66274509803922, 0.66274509803922},
        darkkhaki = {0.74117647058824, 0.71764705882353, 0.41960784313725},
        darkmagenta = {0.54509803921569, 0, 0.54509803921569},
        darkolivegreen = {0.33333333333333, 0.41960784313725, 0.1843137254902},
        darkorange = {1, 0.54901960784314, 0},
        darkorchid = {0.6, 0.19607843137255, 0.8},
        darkred = {0.54509803921569, 0, 0},
        darksalmon = {0.91372549019608, 0.58823529411765, 0.47843137254902},
        darkseagreen = {0.56078431372549, 0.73725490196078, 0.56078431372549},
        darkslateblue = {0.28235294117647, 0.23921568627451, 0.54509803921569},
        darkslategray = {0.1843137254902, 0.30980392156863, 0.30980392156863},
        darkslategrey = {0.1843137254902, 0.30980392156863, 0.30980392156863},
        darkturquoise = {0, 0.8078431372549, 0.81960784313725},
        darkviolet = {0.58039215686275, 0, 0.82745098039216},
        deeppink = {1, 0.07843137254902, 0.57647058823529},
        deepskyblue = {0, 0.74901960784314, 1},
        dimgray = {0.41176470588235, 0.41176470588235, 0.41176470588235},
        dimgrey = {0.41176470588235, 0.41176470588235, 0.41176470588235},
        dodgerblue = {0.11764705882353, 0.56470588235294, 1},
        firebrick = {0.69803921568627, 0.13333333333333, 0.13333333333333},
        floralwhite = {1, 0.98039215686275, 0.94117647058824},
        forestgreen = {0.13333333333333, 0.54509803921569, 0.13333333333333},
        fuchsia = {1, 0, 1},
        gainsboro = {0.86274509803922, 0.86274509803922, 0.86274509803922},
        ghostwhite = {0.97254901960784, 0.97254901960784, 1},
        gold = {1, 0.84313725490196, 0},
        goldenrod = {0.85490196078431, 0.64705882352941, 0.12549019607843},
        gray = {0.50196078431373, 0.50196078431373, 0.50196078431373},
        green = {0, 0.50196078431373, 0},
        greenyellow = {0.67843137254902, 1, 0.1843137254902},
        grey = {0.50196078431373, 0.50196078431373, 0.50196078431373},
        honeydew = {0.94117647058824, 1, 0.94117647058824},
        hotpink = {1, 0.41176470588235, 0.70588235294118},
        indianred = {0.80392156862745, 0.36078431372549, 0.36078431372549},
        indigo = {0.29411764705882, 0, 0.50980392156863},
        ivory = {1, 1, 0.94117647058824},
        khaki = {0.94117647058824, 0.90196078431373, 0.54901960784314},
        lavender = {0.90196078431373, 0.90196078431373, 0.98039215686275},
        lavenderblush = {1, 0.94117647058824, 0.96078431372549},
        lawngreen = {0.48627450980392, 0.98823529411765, 0},
        lemonchiffon = {1, 0.98039215686275, 0.80392156862745},
        lightblue = {0.67843137254902, 0.84705882352941, 0.90196078431373},
        lightcoral = {0.94117647058824, 0.50196078431373, 0.50196078431373},
        lightcyan = {0.87843137254902, 1, 1},
        lightgoldenrodyellow = {0.98039215686275, 0.98039215686275, 0.82352941176471},
        lightgray = {0.82745098039216, 0.82745098039216, 0.82745098039216},
        lightgreen = {0.56470588235294, 0.93333333333333, 0.56470588235294},
        lightgrey = {0.82745098039216, 0.82745098039216, 0.82745098039216},
        lightpink = {1, 0.71372549019608, 0.75686274509804},
        lightsalmon = {1, 0.62745098039216, 0.47843137254902},
        lightseagreen = {0.12549019607843, 0.69803921568627, 0.66666666666667},
        lightskyblue = {0.52941176470588, 0.8078431372549, 0.98039215686275},
        lightslategray = {0.46666666666667, 0.53333333333333, 0.6},
        lightslategrey = {0.46666666666667, 0.53333333333333, 0.6},
        lightsteelblue = {0.69019607843137, 0.76862745098039, 0.87058823529412},
        lightyellow = {1, 1, 0.87843137254902},
        lime = {0, 1, 0},
        limegreen = {0.19607843137255, 0.80392156862745, 0.19607843137255},
        linen = {0.98039215686275, 0.94117647058824, 0.90196078431373},
        magenta = {1, 0, 1},
        maroon = {0.50196078431373, 0, 0},
        mediumaquamarine = {0.4, 0.80392156862745, 0.66666666666667},
        mediumblue = {0, 0, 0.80392156862745},
        mediumorchid = {0.72941176470588, 0.33333333333333, 0.82745098039216},
        mediumpurple = {0.57647058823529, 0.43921568627451, 0.85882352941176},
        mediumseagreen = {0.23529411764706, 0.70196078431373, 0.44313725490196},
        mediumslateblue = {0.48235294117647, 0.4078431372549, 0.93333333333333},
        mediumspringgreen = {0, 0.98039215686275, 0.60392156862745},
        mediumturquoise = {0.28235294117647, 0.81960784313725, 0.8},
        mediumvioletred = {0.78039215686275, 0.082352941176471, 0.52156862745098},
        midnightblue = {0.098039215686275, 0.098039215686275, 0.43921568627451},
        mintcream = {0.96078431372549, 1, 0.98039215686275},
        mistyrose = {1, 0.89411764705882, 0.88235294117647},
        moccasin = {1, 0.89411764705882, 0.70980392156863},
        navajowhite = {1, 0.87058823529412, 0.67843137254902},
        navy = {0, 0, 0.50196078431373},
        oldlace = {0.9921568627451, 0.96078431372549, 0.90196078431373},
        olive = {0.50196078431373, 0.50196078431373, 0},
        olivedrab = {0.41960784313725, 0.55686274509804, 0.13725490196078},
        orange = {1, 0.64705882352941, 0},
        orangered = {1, 0.27058823529412, 0},
        orchid = {0.85490196078431, 0.43921568627451, 0.83921568627451},
        palegoldenrod = {0.93333333333333, 0.90980392156863, 0.66666666666667},
        palegreen = {0.59607843137255, 0.9843137254902, 0.59607843137255},
        paleturquoise = {0.68627450980392, 0.93333333333333, 0.93333333333333},
        palevioletred = {0.85882352941176, 0.43921568627451, 0.57647058823529},
        papayawhip = {1, 0.93725490196078, 0.83529411764706},
        peachpuff = {1, 0.85490196078431, 0.72549019607843},
        peru = {0.80392156862745, 0.52156862745098, 0.24705882352941},
        pink = {1, 0.75294117647059, 0.79607843137255},
        plum = {0.86666666666667, 0.62745098039216, 0.86666666666667},
        powderblue = {0.69019607843137, 0.87843137254902, 0.90196078431373},
        purple = {0.50196078431373, 0, 0.50196078431373},
        red = {1, 0, 0},
        rosybrown = {0.73725490196078, 0.56078431372549, 0.56078431372549},
        royalblue = {0.25490196078431, 0.41176470588235, 0.88235294117647},
        saddlebrown = {0.54509803921569, 0.27058823529412, 0.074509803921569},
        salmon = {0.98039215686275, 0.50196078431373, 0.44705882352941},
        sandybrown = {0.95686274509804, 0.64313725490196, 0.37647058823529},
        seagreen = {0.18039215686275, 0.54509803921569, 0.34117647058824},
        seashell = {1, 0.96078431372549, 0.93333333333333},
        sienna = {0.62745098039216, 0.32156862745098, 0.17647058823529},
        silver = {0.75294117647059, 0.75294117647059, 0.75294117647059},
        skyblue = {0.52941176470588, 0.8078431372549, 0.92156862745098},
        slateblue = {0.4156862745098, 0.35294117647059, 0.80392156862745},
        slategray = {0.43921568627451, 0.50196078431373, 0.56470588235294},
        slategrey = {0.43921568627451, 0.50196078431373, 0.56470588235294},
        snow = {1, 0.98039215686275, 0.98039215686275},
        springgreen = {0, 1, 0.49803921568627},
        steelblue = {0.27450980392157, 0.50980392156863, 0.70588235294118},
        tan = {0.82352941176471, 0.70588235294118, 0.54901960784314},
        teal = {0, 0.50196078431373, 0.50196078431373},
        thistle = {0.84705882352941, 0.74901960784314, 0.84705882352941},
        tomato = {1, 0.38823529411765, 0.27843137254902},
        turquoise = {0.25098039215686, 0.87843137254902, 0.8156862745098},
        violet = {0.93333333333333, 0.50980392156863, 0.93333333333333},
        wheat = {0.96078431372549, 0.87058823529412, 0.70196078431373},
        white = {1, 1, 1},
        whitesmoke = {0.96078431372549, 0.96078431372549, 0.96078431372549},
        yellow = {1, 1, 0},
        yellowgreen = {0.60392156862745, 0.80392156862745, 0.19607843137255}
    }
    local col=tbl[name:lower()]
    return string.format("%02X%02X%02X",math.floor(col[1]*255),math.floor(col[2]*255),math.floor(col[3]*255))
end
local function till_br(def,str)
    local en="\n"
    local result=str:find(en)

    if(result)then
        return str:sub(1,str:find(en)-1),en:len()
    else
        return str,0
    end
end
local function till_parentasis(def,str)
    local en=");"
    return str:sub(1,str:find(");")-1),en:len()
end
local function till_brace(def,str)
    local en="};"
    return str:sub(1,str:find("};")-1),en:len()
end
local function till_same(def,str)
    return str:sub(1,str:find(def.begin[1])-1),def.begin[1]:len()
end
local function till_close(def,str)
    return str:sub(1,str:find(def.close)-1),def.close:len()
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
  
    local t = {} ; 
    i=1
    for s in string.gmatch(str, "([^"..ts.."]+)") do
      t[i] = s
      i = i + 1
    end
  
    return t
  end
function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end
function P.findancestor(node,name)
    while node.parent do
        
        if(node.name==name)then
            return node
        end
        node=node.parent
    end
    return nil
end

local tags={
    {
        name="text",
        isdiv=true,
    },
    
    {
        name="comment",
        begin={"#","//"},
        till_fn=till_br,
        head=true,
        nl=true,
    },
    {
        name="comment",
        begin={"''"},
    },
    {
        name="link",
        begin={"[#"},
        close="]",
        till_fn=till_close,
        attrib_fn=function(def,begin,str,context)
            return {link=str},0
        end,
        head=false,
    },
    {
        name="font",
        begin={"&color","&sizex","&size"},
        till_fn=till_brace,
        attrib_fn=function(def,begin,str,context)
            local attrib={}
            
            local offset=str:find("{")
            local notfound
            local sstr=begin..str
            repeat
                notfound=true
                if(sstr:find("&color",1,true))then
                    local attribtext=sstr:sub(sstr:find("(",1,true)+1,sstr:find(")",1,true)-1)
                    attrib.color=getcolorbyname(attribtext)
                    
                    sstr=sstr:sub(sstr:find(")",1,true)+1)
                    notfound=false
                end
               
                if(sstr:find("&sizex",1,true))then
                    local attribtext=sstr:sub(sstr:find("(",1,true)+1,sstr:find(")",1,true)-1)
                    attrib.size=attribtext
                    sstr=sstr:sub(sstr:find(")",1,true)+1)
                    notfound=false
                end
                if(sstr:find("&size",1,true))then
                    local attribtext=sstr:sub(sstr:find("(",1,true)+1,sstr:find(")",1,true)-1)
                    attrib.size=attribtext
                    sstr=sstr:sub(sstr:find(")",1,true)+1)
                    notfound=false
                end
            until(notfound==true)
            return attrib,offset
        end,
        isdiv=true,
    },
    {
        name="br",
        begin={"&BR;","&br;"},
        till_fn=nil,
    },
    {
        name="header",
        begin={"*"},
        isdiv=true,
        till_fn=till_br,
        head=true,
        nl=true,
    },
    {
        name="hl",
        begin={"----","#BR"},
        till_fn=till_br,
        head=true,
    },
    {
        name="image",
        begin={"&attachref"},
        till_fn=till_parentasis,
        attrib_fn=function(def,begin,str)
        end,
    },

    {
        name="td",
        begin={"|"},
        isdiv=true,
        till_fn=function(def,str,context)
            local findbar=str:find(def.begin[1])
            local findbr=str:find("\n")
            
            if(not findbar or findbr<findbar)then
                context.useforattr=true
                return str:sub(1,findbr),0
            end
            context.useforattr=nil
            return str:sub(1,str:find(def.begin[1])-1),0
        end,
        attrib_fn=function(def,begin,str,context)
            local attr={nl=context.useforattr}
            local st=str
            local len=0
            if(st:find(":"))then
                local opt=st:sub(1,st:find(":"))
                local arg=st:sub(st:find(":")+1)
                if(opt=="CENTER:" or opt=="LEFT:" or opt=="RIGHT:")then
                    attr.align=opt:lower()
                    attr.width=arg
                elseif(opt=="BGCOLOR:")then
                    attr.bgcolor=arg:sub(2,-2)
                end
               
                len=st:len()
            elseif(st==">")then
                attr.colspan=true
                len=st:len()
            elseif(st=="~")then
                attr.rowspan=true
                len=st:len()
            elseif(st:starts("~"))then
                len=1
            elseif(st=="c" or st=="C")then
                len=1
            end
            context.useforattr=nil
            return attr,len
        end,

    },
    {
        name="table",
        isdiv=true,
        
    },
    {
        name="tr",
        isdiv=true,
    },
    {
        name="li",
        begin={"---","--","-"},
        isdiv=true,
        till_fn=till_br,
        attrib_fn=function(def,begin,str)
        end,
        head=true,
        nl=true,
    },
    {
        name="ln",
        begin={"+"},
        isdiv=true,
        till_fn=till_br,
        attrib_fn=function(def,begin,str)

        end,
        head=true,
        nl=true,
    },
    {
        name="a",
        begin={"[["},
        till_fn=function(def,str)
            local en="]]"
            return str:sub(1,str:find("]]")-1),en:len()
        end,
        isdiv=true,
        attrib_fn=function(def,begin,str)

        end,
    },
    {
        name="quote",
        begin={">"},
        till_fn=till_br,
        isdiv=true,
        head=true,
        nl=true,
    },
    {
        name="title",
        begin={"TITLE:"},
        till_fn=till_br,
        head=true,
        
    },

}
function P.findtag(name)
    for _,v in ipairs(tags) do
        if(v.name==name)then
            return v
        end
    end
    return nil
end
function P.poptext(current,str)
    if(#str==0)then
        return ""
    end
    print(str)
    local tag=tags[1]
    
    current.child=current.child or {}
    current.child[#current.child+1]={
        tag=tag,
        name=tag.name,
        content=str,
        parent=current
    }

    return ""
end
function P.parseimpl(current,str,context,head)
    context=context or {}
    current=current or {}
    local pos=1
    local textbuf=""

    while pos <= str:len() do
        local substr=str:sub(pos)
        head=head or true
        local hit=false
        for _,tag in ipairs(tags) do
            if(tag.begin)then
                for _,b in ipairs(tag.begin) do
                    local result
                    if(tag.head)then
                        result=head and substr:starts(b)
                    else
                        result=substr:starts(b)
                    end
                    if(result) then
                        local child={
                            name=tag.name,
                            tag=tag,
                            parent=current
                        }
                        local tagstr,tilllen
                        if tag.till_fn then
                            
                            tagstr,tilllen=tag:till_fn(substr:sub(b:len()+1),context)
                        else
                            tagstr=""
                            tilllen=0
                        end
                        if(tilllen==nil)then
                            --ignore this
                            hit=true
                            pos=pos+1
                        else
                            --generate text
                            local attrlen=0
                            if(textbuf:len()>0)then
                                current.child=current.child or {}
                                current.child[#current.child+1]={
                                    name=tags[1].name,
                                    tag=tags[1],
                                    content=textbuf,
                                    parent=current,
                                }
                                textbuf=""
                            end
                            if(context.useforattr)then
                               
                                if(tag.attrib_fn)then
                                    local attrib=tag:attrib_fn(b,tagstr,context)
                                    current.child[#current.child].attrib=attrib or current.child[#current.child]
                                end
                                context.useforattr=nil
                            else
                                child.content=tagstr
                                current.child=current.child or {}
                                current.child[#current.child+1]=child
                                if(tag.attrib_fn)then
                                    local attrib
                                    attrib,attrlen=tag:attrib_fn(b,tagstr,context)
                                    child.attrib=attrib
                                    context.useforattr=nil
                                end
                                if(tag.isdiv)then
                                    local offset
                                    if(attrlen==nil)then
                                        offset=0

                                    else
                                        offset=attrlen+1

                                    end

                                    P.parseimpl(child,tagstr:sub(offset),context,head)
                
                                end
    
                            end
                        
                            pos=pos+b:len()+tagstr:len()+tilllen
                            hit=true
                            break
                        end
                    end
                end
                if(hit)then
                    break
                end
            end
            
        end
        if(str:starts("\n"))then
            head=true
        else
            head=false
        end
        if(not hit)then
            if(textbuf:len()>0 and substr:starts("\n"))then
                current.child=current.child or {}
                current.child[#current.child+1]={
                    name=tags[1].name,
                    tag=tags[1],
                    content=textbuf,
                    parent=current,
                }
                current.child[#current.child+1]={
                    name="br",
                    tag=P.findtag("br"),
                    content="",
                    parent=current,
                }
                textbuf=""
 
            else
                textbuf=textbuf..str:sub(pos,pos):gsub("\n","")
            end
            pos=pos+1
        end
    end
    --generate text
    if(textbuf:len()>0)then
        current.child=current.child or {}
        current.child[#current.child+1]={
            name=tags[1].name,
            tag=tags[1],
            content=textbuf,
            parent=current,
        }
        textbuf=""
    end
    
    return current
end
function P.generatenl(current)

    

    if(current.child)then
        local idx=1
        while idx<=#current.child do
            local child=current.child[idx]
            if(child.tag.nl)then
                table.insert(current.child,idx+1,{
                    name="br",
                    tag=P.findtag("br"),
                    parent=current,
                    content=""
                });
                idx=idx+1
            end
            P.generatenl(child)
            idx=idx+1
        end
    end
    return current
end
function P.generatetable(current)
    local idx=1
    while idx <= #current.child do
        local v=current.child[idx]
        if(v.name=="td")then
            --tableにまとめる
            local tbl={
                name="table",
                tag=P.findtag("table"),
                child={}
            }
            local tr
            local tidx=idx
            local next
            local trprev
            while tidx <= #current.child do
                local vc=current.child[tidx]
                
                if(
                current.child[tidx].attrib and 
                current.child[tidx].name=="td" and 
                current.child[tidx].attrib.nl )then
                    tr=nil
                    next=true
                elseif vc.name~="td"then
                    break
                end
                if(tr==nil)then
                    
                    tr={
                        name="tr",
                        tag=P.findtag("tr"),
                        child={}
                    }
                    
                        
                    if(not next)then
                        tbl.child[#tbl.child+1] = tr
                    end
                   
                else
                    trprev=tr
                end
                if next then
                    trprev.child[#trprev.child+1]=vc
                    tbl.child[#tbl.child+1] = tr
                    next=nil
                else
                    tr.child[#tr.child+1]=vc
                end
                

               
                table.remove(current.child,tidx)
            end
            current.child[idx]=tbl
        end
        idx=idx+1
    end
    return current
end
function P.parse(current,str)

    current=current or {
        name="root",
    }
    current=P.parseimpl(current,str)
    current=P.generatenl(current)
    current=P.generatetable(current)
    
    return current
end
--EOF
WIKIHELP_PUKIWIKI_PARSER=P

tester=P.parse({},
[==[TITLE:エレメンタリスト
>&attachref(クラス/ウィザード/6.png,nolink,60%,エレメンタリスト);
エレメンタリストはこの世界を構成する要素が女神の権能によって、
どのような働きをするのかを理解し研究する魔法学者です。
また、その考えを元に、その力を利用しようとしています。
根源物質の最初の発現状態であり利用しやすい形の4元素を重要視し、
天上の権能が万物を扱う理を理解しコントロールすることで神の力を模倣しています。
エレメンタリストは、元素の力を操るウィザードです。
強力な攻撃魔法を持っていますが、その分クールタイムが必要なので仲間との協力が大切です。
&attachref(Class/ウィザード/エレメンタリスト/wizard_m6.gif,nolink,エレメンタリスト);　&attachref(Class/ウィザード/エレメンタリスト/wizard_f6.gif,nolink,エレメンタリスト);

#include(ReBuild/ウィザード,notitle)
----
#contents
*クラス概要 [#classdesc]
属性魔法を扱う攻撃型クラス。
広範囲に攻撃できる火・氷・雷属性の攻撃スキルをもち、
敵の弱点を突いた際にダメージをアップさせることができる、属性攻撃のエキスパート。

多くのスキルは使用時にキャスティング（詠唱）が発生する。
立ち回りやロッドマスタリ等の詠唱短縮等、詠唱中の隙を以下に補うかが重要となるクラス。
~

・ステータス成長比率
|~力|~体力|~知能|~精神|~敏捷|
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|C
|0%|10%|50%|40%|0%|


*クラス特性 [#classattr]
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~T|
|~CLv1|エレメンタリスト：抵抗|5|自分の炎、氷、雷属性抵抗が5アップ&br;2レベルから特性レベル1につき1ずつアップ|A|
|~|炎属性：爆発|1|基本的攻撃を含むスキル使用時30％の確率で火属性攻撃適用&br;ダメージが30％増加するバフが5秒間付与|A|
|~|氷属性：鈍化|1|敵を氷属性攻撃でフィニッシュすると、50%の確率で&br;周辺の敵は6秒間[スロー]デバフ|A|

*スキル一覧 [#skilllist]
&size(4){アイコンにカーソルを合わせるとスキル名が表示されます。&br;クリックすればそのスキル欄まで飛びます。&br;黄枠はOHスキルです。};
|CENTER:|CENTER:50|CENTER:50|CENTER:50|CENTER:50|c
|~クラスLv|>|>|>|~スキル|
|~1-15|[[&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_electrocute.png,50%,エレクトロキュート);>#skill01]]|[[&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_hail.png,50%,ヘイル);>#skill02]]|[[&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_stormdust.png,50%,ストームダスト);>#skill03]]|[[&attachref(./icon_wizar_fireclaw.png,50%,ファイアクロー);>#skill04]]|
|~16-30|[[&attachref(./icon_wizar_elementalessence.png,50%,エレメンタルエッセンス);>#skill05]]|[[&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_stonecurse.png,50%,ストーンカース);>#skill06]]|>|>|
|~31-45|[[&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_meteor.png,50%,メテオ);>#skill07]]|>|>|>|

*クラスLv1－15 [#circle1]
**&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_electrocute.png,nolink,50%,エレクトロキュート);&sizex(5){''エレクトロキュート''}; [#skill01]
>&color(Red){''魔法－雷属性''};
電気の鎖を放出し前方の敵を連続攻撃します。
&color(DarkBlue){''コーリングストーム範囲内でエレクトロキュート使用時、適用対象数が2倍に増加します。''};
#youtube(y2wgnpKF1vg,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~スキル係数|~攻撃回数|~対象数|~詠唱時間|~消費SP|~CD|~備考|
|~1-15|~1|159%|4回|3体|0.5秒|192|10秒||
|~|~2|161%|~|4体|~|~|~|~|
|~|~3|163%|~|~|~|~|~|~|
|~|~4|165%|~|5体|~|~|~|~|
|~|~5|167%|~|~|~|~|~|~|
|~16-30|~6|169%|~|6体|~|~|~|~|
|~|~7|171%|~|~|~|~|~|~|
|~|~8|173%|~|7体|~|~|~|~|
|~|~9|175%|~|~|~|~|~|~|
|~|~10|177%|~|8体|~|~|~|~|
|~31-45|~11|179%|~|~|~|~|~|~|
|~|~12|181%|~|9体|~|~|~|~|
|~|~13|183%|~|~|~|~|~|~|
|~|~14|185%|~|10体|~|~|~|~|
|~|~15|187%|~|~|~|~|~|~|
+スキル特性
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|~SLv1|強化|100|[エレクトロキュート]のスキル係数が特性レベル1につき0.5%アップ&br;最高レベルになるとさらに10%アップ|-|P|
+スキル使用感
-向いている方向に稲妻が走る。一体ごとに4hitする。
-詠唱中は動けないが、発動後は稲妻が出ていても動ける。
--9/5 ktosにてスキル係数が 411 + [スキルレベル - 1] x 68.5 に変更。

**&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_hail.png,nolink,50%,ヘイル);&sizex(5){''ヘイル''}; [#skill02]
>&color(Red){''魔法－氷属性&br;魔法陣''};
指定した位置に氷の塊をたくさん落とし敵に持続的なダメージを与えます。
[氷結]状態の敵にヘイル攻撃がクリティカルで的中した時、与えるダメージが増加します。
#youtube(Mwuv5Az02bk,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~スキル係数|~持続時間|~詠唱時間|~消費SP|~CD|~備考|
|~1-15|~1|96%|10秒|1.0秒|270|50秒|1Hit/0.2s|
|~|~2|104%|~|~|~|~|~|
|~|~3|112%|~|~|~|~|~|
|~|~4|120%|~|~|~|~|~|
|~|~5|128%|~|~|~|~|~|
|~16-30|~6|136%|~|~|~|~|~|
|~|~7|144%|~|~|~|~|~|
|~|~8|152%|~|~|~|~|~|
|~|~9|160%|~|~|~|~|~|
|~|~10|168%|~|~|~|~|~|
|~31-45|~11|176%|~|~|~|~|~|
|~|~12|184%|~|~|~|~|~|
|~|~13|192%|~|~|~|~|~|
|~|~14|200%|~|~|~|~|~|
|~|~15|208%|~|~|~|~|~|
+スキル特性
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|~SLv1|強化|100|[ヘイル]のスキル係数が特性レベル1につき0.5%アップ&br;最高レベルになるとさらに10%アップ|-|P|
|~CLv1|氷結|5|敵が[ヘイル]で攻撃を受ける度に特性レベル1につき5%の確率で&br;5秒間[氷結]デバフ|SP+30%|A|
+スキル使用感
-指定座標を中心に小さな氷の塊を多数落下させるスキル。詠唱中は動けない。
-ランダムで落ちてくる氷の塊一つ一つに攻撃判定がある。
-氷の塊の攻撃判定は小さく、通常Mob相手にはそれほど当たらないが大型のボスには比較的当てやすい。
--サルラス等のボスには凍結が効くため、ヘイル持続中はボスの行動を制限しつつ大量にHitさせることができる。
-氷結状態の敵にクリダメ増加(slv×2%)、サイズに応じた追加ダメージ(小型150％中型100％大型50％)
-9/5 ktosにてスキル係数が 156 + [スキルレベル - 1] x 26 に変更。
**&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_stormdust.png,nolink,50%,ストームダスト);&sizex(5){''ストームダスト''}; [#skill03]
>&color(Red){''魔法－地属性&br;魔法陣''};
指定位置に砂の嵐を生成します。
嵐内の敵は持続的に地属性ダメージを受けます。
#youtube(D_tAMWX3FlM,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~スキル係数|~対象数|~持続時間|~消費SP|~CD|~備考|
|~1-15|~1|103%|14体|5.4秒|208|20秒|1Hit/0.3s|
|~|~2|106%|16体|~|~|~|~|
|~|~3|109%|18体|~|~|~|~|
|~|~4|113%|20体|~|~|~|~|
|~|~5|116%|22体|~|~|~|~|
|~16-30|~6|120%|24体|~|~|~|~|
|~|~7|123%|26体|~|~|~|~|
|~|~8|126%|28体|~|~|~|~|
|~|~9|130%|30体|~|~|~|~|
|~|~10|133%|32体|~|~|~|~|
|~31-45|~11|137%|34体|~|~|~|~|
|~|~12|140%|36体|~|~|~|~|
|~|~13|143%|38体|~|~|~|~|
|~|~14|147%|40体|~|~|~|~|
|~|~15|150%|42体|~|~|~|~|
+スキル特性
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|~SLv1|強化|100|[ストームダスト]のスキル係数が特性レベル1につき0.5%アップ&br;最高レベルになるとさらに10%アップ|-|P|
|~CLv1|スロー|5|[ストームダスト]範囲内の敵の移動速度が特性レベル1につき2ずつダウン|-|A|
|~|余波|2|[ストームダスト]スキルが終了すると[ストームダスト]の範囲内にいた敵は&br;特性レベル1につき1.5秒間[ストームダスト]のダメージ持続|-|A|
+スキル使用感
-位置設置・即時発動型。設置後1秒後から持続攻撃開始。使い勝手が良い。
-9/5 ktosにてスキル係数が 241 + [スキルレベル - 1] x 40.4 に変更。
**&attachref(./icon_wizar_fireclaw.png,nolink,50%,ファイアクロー);&sizex(5){''ファイアクロー''}; [#skill04]
>&color(Red){''魔法－炎属性&br;魔法陣''};
自分を中心として広がる炎を噴き出させて敵を攻撃します。
#youtube(irUZahSAiHk,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~スキル係数|~消費SP|~CD|~備考|
|~1-15|~1|232%|215|20秒|OH2回|
|~|~2|239%|~|~|~|
|~|~3|247%|~|~|~|
|~|~4|255%|~|~|~|
|~|~5|262%|~|~|~|
|~16-30|~6|270%|~|~|~|
|~|~7|278%|~|~|~|
|~|~8|285%|~|~|~|
|~|~9|293%|~|~|~|
|~|~10|301%|~|~|~|
|~31-45|~11|309%|~|~|~|
|~|~12|316%|~|~|~|
|~|~13|324%|~|~|~|
|~|~14|332%|~|~|~|
|~|~15|339%|~|~|~|
+スキル特性
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|~SLv1|強化|100|[ファイアクロー]のスキル係数が特性レベル1につき0.5%アップ&br;最高レベルになるとさらに10%アップ|-|P|
+スキル使用感
-指定位置を中心に8方向に炎を飛ばす。遠くなればなるほど隙間が出来る。
-敵と重なっていれば多段ヒットする。
ボス等当たり判定の大きい敵には当てやすいが、密着するためややリスクはある。
//-重なっても1hitのみ。←ハイランダー道場の木人形、チャレンジモードのボスに複数ヒットすることを確認しました。
-9/5 ktosにてスキル係数が 149 + [スキルレベル - 1] x 24.9 に変更。

*クラスLv16－30 [#circle2]
**&attachref(./icon_wizar_elementalessence.png,nolink,50%,エレメンタルエッセンス);&sizex(5){''エレメンタルエッセンス''}; [#skill05]
>相手の弱点属性で攻撃すると相性効果がアップするバフを付与します。
#youtube(Nc1o-ZOmm5w,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~相性効果増加|~持続時間|~消費SP|~CD|~備考|
|~16-30|~1|10%|20秒|228|20秒||
|~|~2|20%|~|~|~|~|
|~|~3|30%|~|~|~|~|
|~|~4|40%|~|~|~|~|
|~|~5|50%|~|~|~|~|
|~31-45|~6|60%|~|~|~|~|
|~|~7|70%|~|~|~|~|
|~|~8|80%|~|~|~|~|
|~|~9|90%|~|~|~|~|
|~|~10|100%|~|~|~|~|
+スキル特性
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|~SLv1|エレメンタルエッセンス: バランス|10|[エレメンタルエッセンス]のダメージアップ効果が特性レベルあたり5%減少する代わりに、&br;弱い属性に対するダメージダウンも特性レベルあたり5%減少する。|-|A|
//+スキル特性
//|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
//|~条件|~特性|~MaxLv|~効果|~影響|~T|
+スキル使用感
-モンスターの&color(Red){''元素属性''};に対し弱点の属性で発生する追加補正を乗算で増加させるBuff。
不得意の属性(減少補正)の場合は変化なし。
--Lv10では、+50%の相性を+100%に変更する。同様に+25%→+50%、+12.5%→+25%に変更する。
-属性相性早見表：火＞土＞雷＞氷＞火　光⇔闇　念＞光闇念　毒＞火土雷氷
[[''属性相性の詳細''>System/属性相性#k92426bc]]
-現状ではモンスターの元素属性を変更させる手段は存在しないため、手持ちの攻撃スキルと標的によって恩恵が左右されやすい。
-バランス特性はON/OFFの切り替えが可能。
**&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_stonecurse.png,nolink,50%,ストーンカース);&sizex(5){''ストーンカース''}; [#skill06]
>敵を一時的に石化状態にします。
石化状態になった敵は炎属性、念属性を除いた全ての攻撃で受けるダメージがダウンし、
炎属性、念属性攻撃に追加ダメージを受けます。
#youtube(4m18lO_B_7M,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~対象数|~持続時間|~詠唱時間|~消費SP|~CD|~備考|
|~16-30|~1|5体|5秒|1秒|270|60秒|ストーンカースにかかった敵は&br;炎属性、念属性攻撃に50%追加ダメージ|
|~|~2|~|7秒|~|~|~|~|
|~|~3|~|9秒|~|~|~|~|
|~|~4|~|11秒|~|~|~|~|
|~|~5|~|13秒|~|~|~|~|
|~31-45|~6|~|15秒|~|~|~|~|
|~|~7|~|17秒|~|~|~|~|
|~|~8|~|19秒|~|~|~|~|
|~|~9|~|21秒|~|~|~|~|
|~|~10|~|23秒|~|~|~|~|
+スキル特性
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|~CLv1|石化数アップ|3|[ストーンカース]で[石化]をかけられる数が特性レベル分アップ|SP+10%|A|
+スキル使用感
-一般のボスにも効く。
-炎/念属性攻撃による追加ダメージは通常のダメージの約75%？を2連打する多段攻撃に変化する。
-ktos 4/11 石化時間変更(1+slv秒　pvpでは1/3)、追加ダメージ100％を2連打に変更
*クラスLv31－45 [#circle3]
**&attachref(Class/ウィザード/エレメンタリスト/icon_wizar_meteor.png,nolink,50%,メテオ);&sizex(5){''メテオ''}; [#skill07]
>&color(Red){''魔法－炎属性''};
指定した位置に隕石を落とし、敵にダメージを与えます。
#youtube(qHkP-iWN9lU,300,200)

+スキル性能
|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|CENTER:|c
|~クラスLv|~Lv|~スキル係数 |~詠唱時間|~消費SP|~CD|~備考|
|~31-45|~1|1497%|2秒|249|40秒|AOE+30|
|~|~2|1646%|~|~|~|~|
|~|~3|1796%|~|~|~|~|
|~|~4|1946%|~|~|~|~|
|~|~5|2095%|~|~|~|~|
+スキル特性
|CENTER:|LEFT:|CENTER:|LEFT:|CENTER:|CENTER:|c
|~条件|~特性|~MaxLv|~効果|~影響|~T|
|~SLv1|強化|100|[メテオ]のスキル係数が特性レベル1につき0.5%アップ&br;最高レベルになるとさらに10%アップ|-|P|
|~CLv1|フレイムグラウンド|1|[フレイムグラウンド]を受ける敵に[メテオ]を使用すると5連打適用&#8203;|-|A|
+スキル使用感
-広範囲超火力。MAX推奨。
-パイロマンサー[[[フレイムグラウンド>https://wikiwiki.jp/tosjp/Class/Re%E3%82%A6%E3%82%A3%E3%82%B6%E3%83%BC%E3%83%89/Re%E3%83%91%E3%82%A4%E3%83%AD%E3%83%9E%E3%83%B3%E3%82%B5%E3%83%BC#skill04]]]のバフを受けた対象には5hitする。
-9/5 ktosにてスキル係数が 2406 + [スキルレベル - 1] x 2406.5 に変更、CDが30秒に変更。
*コメント [#comment]
//[[過去ログ>Class/ウィザード/エレメンタリスト/コメント]]
&color(red){19/2/27以前のコメントはRe:build以前のコメントとなります。日時に注意して閲覧してください。};
#zcomment(t=tosWIKIBBS%2F46&h=200&size=10&style=wikiwiki)

]==]
)
tester=tester