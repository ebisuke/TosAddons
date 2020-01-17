
local P = {}
ebi_utf8 = ebi_utf8 or {}
if (not session) then
    print("LOADFILE")
    ebi_utf8 = loadfile("E:\\ToSProject\\TosAddons\\wikihelp\\src\\addon_d.ipf\\wikihelp\\utf8.lua")()
end
local function getcolorbyname(name)
    
    local tbl = {
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
    local col = tbl[name:lower()]
    return string.format("%02X%02X%02X", math.floor(col[1] * 255), math.floor(col[2] * 255), math.floor(col[3] * 255))
end
local function till_br(def, str)
    local en = "\n"
    local result = str:find(en)
    
    if (result) then
        return str:sub(1, str:find(en) - 1), 0
    else
        return str, 0
    end
end
local function till_parentasis(def, str)
    local remain = 0
    local findfirst = true
    local en = ")"
    local pos = 1
    while (remain > 0 or findfirst) do
        local substr = str:sub(pos)
        if (substr:starts("(")) then
            remain = remain + 1
            findfirst = false
        elseif substr:starts(en) then
            remain = remain - 1
        end
        pos = pos + 1
    end
    return str:sub(1, pos - 2), 2
end
local function till_brace(def, str)
    local remain = 0
    local findfirst = true
    local en = "};"
    local pos = 1
    while (remain > 0 or findfirst) do
        local substr = str:sub(pos)
        if (substr:starts("{")) then
            remain = remain + 1
            findfirst = false
        elseif substr:starts(en) then
            remain = remain - 1
        end
        pos = pos + 1
    end
    
    return str:sub(1, pos - 2), 2
end
local function till_same(def, str)
    return str:sub(1, str:find(def.begin[1]) - 1), def.begin[1]:len()
end
local function till_close(def, str)
    return str:sub(1, str:find(def.close) - 1), def.close:len()
end
function table.elemn(tbl)
    local n = 0
    for _ in pairs(tbl) do
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
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
function P.findancestor(node, name)
    while node.parent do
        
        if (node.name == name) then
            return node
        end
        node = node.parent
    end
    return nil
end

local tags = {
    {
        name = "text",
        isdiv = true,
    },
    
    
    {
        name = "comment",
        begin = {"''"},
    },
    {
        name = "link",
        begin = {"[#"},
        close = "]",
        till_fn = till_close,
        attrib_fn = function(def, begin, str, context)
            return {link = str}, 0
        end,
        head = false,
    },
    {
        name = "bold",
        begin = {"''"},
        isdiv=true,
        till_fn = till_same,
        head = false,
    },
    
    {
        name = "font",
        begin = {"&color", "&sizex", "&size"},
        till_fn = till_brace,
        attrib_fn = function(def, begin, str, context)
            local attrib = {}
            
            local offset = str:find("{")
            local notfound
            local sstr = begin .. str
            repeat
                notfound = true
                if (sstr:starts("&color")) then
                    local attribtext = sstr:sub(sstr:find("(", 1, true) + 1, sstr:find(")", 1, true) - 1)
                    attrib.color = getcolorbyname(attribtext)

                    sstr = sstr:sub(sstr:find(")", 1, true) + 1)
                    notfound = false
                end
                
                if (sstr:starts("&sizex")) then
                    local attribtext = sstr:sub(sstr:find("(", 1, true) + 1, sstr:find(")", 1, true) - 1)
                    attrib.size = tonumber(attribtext) * 4 + 8
                    sstr = sstr:sub(sstr:find(")", 1, true) + 1)
                    notfound = false
                end
                if (sstr:starts("&size")) then
                    local attribtext = sstr:sub(sstr:find("(", 1, true) + 1, sstr:find(")", 1, true) - 1)
                    attrib.size = math.max(8, attribtext + 2)
                    sstr = sstr:sub(sstr:find(")", 1, true) + 1)
                    notfound = false
                end
            until (notfound == true)
            return attrib, offset
        end,
        isdiv = true,
    },
    {
        name = "br",
        begin = {"&BR;", "&br;","&br();"},
        till_fn = nil,
    },
    {
        name = "header",
        begin = {"***", "**", "*"},
        isdiv = true,
        till_fn = till_br,
        head = true,
        nl = true,
        attrib_fn = function(def, begin, str, context)
            return {level=begin:len()}
        end
    },
    {
        name = "hl",
        begin = {"----", "#BR"},
        till_fn = till_br,
        head = true,
    },
    {
        name = "image",
        begin = {"#ref", "&attachref"},
        till_fn = till_parentasis,
        attrib_fn = function(def, begin, str, context)
            local substr = str:sub(2)
            
            local split = ebi_utf8.utf8split(substr, ",")
            local zoom = 100
            local linkstr = substr:sub(1, -2)
            for i, sstr in ipairs(split) do
                if (i == 1) then
                    linkstr = sstr
                else
                    local percent = ebi_utf8.utf8find(sstr, "%%")
                    if (percent) then
                        local temp = sstr
                        zoom = ebi_utf8.utf8sub(sstr, 1, percent - 1)
                    end
                end
            end
            
            local attr = {link =
                ebi_utf8.utf8gsub(
                    ebi_utf8.utf8gsub(
                        ebi_utf8.utf8gsub(
                            ebi_utf8.utf8gsub(
                                ebi_utf8.utf8gsub(
                                    ebi_utf8.utf8gsub(linkstr,
                                        "%./", ""),
                                    ":", "_"),
                                "/", "_"),
                            "%(", "_"),
                        "%)", "_"),
                    "%.gif", "%.png"),
                zoom = tonumber(zoom),
            }
            
            return attr
        end,
    },
    {
        name = "comment",
        begin = {"#", "//"},
        till_fn = till_br,
        head = true,
        nl = true,
    },
    {
        name = "td",
        begin = {"|"},
        isdiv = true,
        till_fn = function(def, str, context)
            local findbar = str:find(def.begin[1])
            local findbr = str:find("\n")
            
            if (not findbar or findbr < findbar) then
                
                context.useforattr = true
                return str:sub(1, findbr), 0
            end
            context.useforattr = nil
            return str:sub(1, str:find(def.begin[1]) - 1), 0
        end,
        attrib_fn = function(def, begin, str, context)
            local attr = {nl = context.useforattr}
            local st = str
            local len = 0
            if (st:find(":")) then
                local opt = st:sub(1, st:find(":"))
                local arg = st:sub(st:find(":") + 1)
                if (opt:starts("CENTER") or opt:starts("LEFT") or opt:starts("RIGHT")) then
                    attr.align = opt:lower()
                    attr.width = arg
                    len = opt:len() + arg:len() + 1
                elseif (opt:starts("BGCOLOR")) then
                    for v in ebi_utf8.utf8gmatch(opt, "%((.*)%)") do
                        attr.bgcolor = v:sub(2)
                        break
                    end
                    len = opt:len()
                
                end
            
            
            elseif (st == ">") then
                attr.colspan = true
                len = st:len()
            elseif (st == "~") then
                attr.rowspan = true
                len = st:len()
            elseif (st:starts("~")) then
                len = 1
            elseif (st == "c" or st == "C") then
                len = 1
            end
            context.useforattr = nil
            return attr, len
        end,
    
    },
    {
        name = "table",
        isdiv = true,
    
    },
    {
        name = "tr",
        isdiv = true,
    },
    {
        name = "li",
        begin = {"---", "--", "-"},
        isdiv = true,
        till_fn = till_br,
        attrib_fn = function(def, begin, str)
            
            if begin == "---" then
                return {level = 3}
            elseif begin == "--" then
                return {level = 2}
            else
                return {level = 1}
            end
        end,
        head = true,
        nl = true,
    },
    {
        name = "ln",
        begin = {"+"},
        isdiv = true,
        till_fn = till_br,
        attrib_fn = function(def, begin, str)
        
        end,
        head = true,
        nl = true,
    },
    {
        name = "a",
        begin = {"http://","https://"},
        till_fn = till_br,
        attrib_fn = function(def, begin, str, context)
            return {link = begin..str}, 0
        end,
        isdiv=true,
        head = false,
    },
    {
        name = "a",
        begin = {"[["},
        till_fn = function(def, str, context)
            local en = "]]"
            local findlink = str:find(">")
            local brf = str:find("\n")
            local endo = str:find("]]")
            if (endo == nil) then
                --floralwhite
                return nil, nil
            elseif (findlink and endo and findlink < endo) then
                context.link = str:sub(findlink + 1, endo - 1)
                
                return str:sub(1, findlink - 1), en:len() + endo - findlink
            
            else
                context.link = str:sub(1, endo - 1)
                return str:sub(1, endo - 1), en:len()
            
            end
        
        end,
        isdiv = true,
        attrib_fn = function(def, begin, str, context)
            local attrib = {
                link = context.link
            }
            context.link = nil
            return attrib
        end,
    },
    {
        name = "quote",
        begin = {">"},
        till_fn = till_br,
        isdiv = true,
        head = true,
        nl = true,
    },
    {
        name = "title",
        begin = {"TITLE:"},
        till_fn = till_br,
        head = true,
    
    },

}
function P.findtag(name)
    for _, v in ipairs(tags) do
        if (v.name == name) then
            return v
        end
    end
    return nil
end
function P.poptext(current, str)
    if (#str == 0) then
        return ""
    end
    
    local tag = tags[1]
    
    current.child = current.child or {}
    current.child[#current.child + 1] = {
        tag = tag,
        name = tag.name,
        content = str,
        parent = current
    }
    
    return ""
end
function P.parseimpl(current, str, context, head)
    context = context or {}
    current = current or {}
    local pos = 1
    local textbuf = ""
    
    while pos <= str:len() do
        local substr = str:sub(pos)
        if (head == nil) then
            head = true
        end
        
        local hit = false
        for _, tag in ipairs(tags) do
            if (tag.begin) then
                for _, b in ipairs(tag.begin) do
                    local result
                    if (tag.head) then
                        result = head and substr:starts(b)
                    else
                        result = substr:starts(b)
                    end
                    if (result) then
                        local child = {
                            name = tag.name,
                            tag = tag,
                            parent = current
                        }
                        local tagstr, tilllen
                        if tag.till_fn then
                            
                            tagstr, tilllen = tag:till_fn(substr:sub(b:len() + 1), context)
                        else
                            tagstr = ""
                            tilllen = 0
                        end
                        if (tilllen == nil) then
                            --ignore this
                            hit = true
                            pos = pos + 1
                        else
                            --generate text
                            local attrlen = 0
                            if (textbuf:len() > 0) then
                                current.child = current.child or {}
                                current.child[#current.child + 1] = {
                                    name = tags[1].name,
                                    tag = tags[1],
                                    content = textbuf,
                                    parent = current,
                                }
                                textbuf = ""
                            end
                            if (context.useforattr) then
                                
                                if (tag.attrib_fn) then
                                    local attrib = tag:attrib_fn(b, tagstr, context)
                                    current.child[#current.child].attrib = attrib or current.child[#current.child]
                                end
                                context.useforattr = nil
                            else
                                child.content = tagstr
                                current.child = current.child or {}
                                current.child[#current.child + 1] = child
                                if (tag.attrib_fn) then
                                    local attrib
                                    attrib, attrlen = tag:attrib_fn(b, tagstr, context)
                                    child.attrib = attrib
                                    context.useforattr = nil
                                end
                                if (tag.isdiv) then
                                    local offset
                                    if (attrlen == nil) then
                                        offset = 0
                                    
                                    else
                                        offset = attrlen + 1
                                    
                                    end
                                    
                                    P.parseimpl(child, tagstr:sub(offset), context, head)
                                
                                end
                            
                            end
                            
                            pos = pos + b:len() + tagstr:len() + tilllen
                            hit = true
                            break
                        end
                    end
                end
                if (hit) then
                    break
                end
            end
        
        end
        if (substr:starts("\n")) then
            head = true
        else
            head = false
        end
        if (not hit) then
            
            if (textbuf:len() > 0 and substr:starts("\n")) then
                current.child = current.child or {}
                current.child[#current.child + 1] = {
                    name = tags[1].name,
                    tag = tags[1],
                    content = textbuf,
                    parent = current,
                }
                
                textbuf = ""
            
            else
                textbuf = textbuf .. str:sub(pos, pos):gsub("\n", "")
            end
            if (substr:starts("\n")) then
                current.child[#current.child + 1] = {
                    name = "br",
                    tag = P.findtag("br"),
                    content = "",
                    parent = current,
                }
            
            end
            pos = pos + 1
        end
    end
    --generate text
    if (textbuf:len() > 0) then
        current.child = current.child or {}
        current.child[#current.child + 1] = {
            name = tags[1].name,
            tag = tags[1],
            content = textbuf,
            parent = current,
        }
        textbuf = ""
    end
    
    return current
end
function P.generatenl(current)
    
    
    
    if (current.child) then
        local idx = 1
        while idx <= #current.child do
            local child = current.child[idx]
            if (child.tag.nl) then
                table.insert(current.child, idx + 1, {
                    name = "br",
                    tag = P.findtag("br"),
                    parent = current,
                    content = ""
                });
                idx = idx + 1
            end
            P.generatenl(child)
            idx = idx + 1
        end
    end
    return current
end
function P.generatetable(current)
    local idx = 1
    while idx <= #current.child do
        local v = current.child[idx]
        if (v.name == "td") then
            --tableにまとめる
            local tbl = {
                name = "table",
                tag = P.findtag("table"),
                child = {}
            }
            local tr
            local tidx = idx
            local next
            local trprev
            while tidx <= #current.child do
                local vc = current.child[tidx]
                
                if (
                    current.child[tidx].attrib and
                    current.child[tidx].name == "td" and
                    current.child[tidx].attrib.nl) then
                    tr = nil
                    next = true
                elseif vc.name ~= "td" then
                    break
                end
                if (tr == nil) then
                    
                    tr = {
                        name = "tr",
                        tag = P.findtag("tr"),
                        child = {}
                    }
                    
                    
                    if (not next) then
                        tbl.child[#tbl.child + 1] = tr
                    end
                
                else
                    trprev = tr
                end
                if next then
                    trprev = trprev or tr
                    trprev.child[#trprev.child + 1] = vc
                    tbl.child[#tbl.child + 1] = tr
                    next = nil
                else
                    tr.child[#tr.child + 1] = vc
                end
                
                
                
                table.remove(current.child, tidx)
            end
            current.child[idx] = tbl
        end
        idx = idx + 1
    end
    return current
end
function P.parse(current, str, pagename)
    
    current = {
        name = "root",
        attrib = {pagename = pagename},
    }
    current = P.parseimpl(current, str)
    current = P.generatenl(current)
    current = P.generatetable(current)
    
    return current
end
--EOF
WIKIHELP_PUKIWIKI_PARSER = P

local tester = P.parse({}, [==[
*クラペダ [#ye121d48]
//　大きな画像、NPCの位置に①②③のような振り分けがあると見やすい
#contents

**地図 [#jb9dd2fd]
#ref(Map/街/クラペダ/クラペダ.jpg,nolink,75%);
CENTER:|CENTER:|CENTER:|c
|~番号|~NPC名|~番号|~NPC名|~番号|~NPC名|
|CENTER:|CENTER:150|CENTER:|CENTER:150|CENTER:|CENTER:150|c
|①|[[コンパニオン商人>Map/街/クラペダ#c2acf175]]|⑪|[[倉庫番>Map/街/クラペダ#c2acf175]]|&#12881;|[[クリヴィスマスター>Map/街/クラペダ#c2acf175]]|
|②|[[アクセサリ商人>Map/街/クラペダ#c2acf175]]|⑫|女神像|&#12882;|[[クォレルシューターマスター>Map/街/クラペダ#c2acf175]]|
|③|[[装備商人>Map/街/クラペダ#c2acf175]]|⑬|[[レンジャーマスター>Map/街/クラペダ#c2acf175]]|&#12883;|[[ソードマンマスター>Map/街/クラペダ#c2acf175]]|
|④|[[雑貨商人>Map/街/クラペダ#c2acf175]]|⑭|[[テンプラーマスター>Map/街/クラペダ#c2acf175]]|-|-|
|⑤|[[鍛冶屋>Map/街/クラペダ#c2acf175]]|⑮|[[クレリックマスター>Map/街/クラペダ#c2acf175]]|-|-|
|⑥|[[クリオンマンサーマスター>Map/街/クラペダ#c2acf175]]|⑯|[[魔法協会クラペダ支部>Map/街/クラペダ#c2acf175]]|-|-|
|⑦|[[ペルタストマスター>Map/街/クラペダ#c2acf175]]|⑰|[[プリーストマスター>Map/街/クラペダ#c2acf175]]|-|-|
|⑧|[[ウィザードマスター>Map/街/クラペダ#c2acf175]]|⑱|[[バイボラの翼>Map/街/クラペダ#c2acf175]]|-|-|
|⑨|[[TP商人>Map/街/クラペダ#c2acf175]]|⑲|[[オラクルマスター>Map/街/クラペダ#c2acf175]]|-|-|
|⑩|[[マーケット管理人>Map/街/クラペダ#c2acf175]]|⑳|[[アーチャーマスター>Map/街/クラペダ#c2acf175]]|-|-|

**隣接マップ [#jf176d83]
-[[シャウレイ西の森>Map/戦闘区域/シャウレイ西の森]] Lv1
-[[シャウレイ東の森>Map/戦闘区域/シャウレイ東の森]] Lv6
-[[ギティスの開拓地>Map/戦闘区域/ギティスの開拓地]] Lv69

**ショップ [#z03b1322]
***装備商人 [#f53da977]
#region(武器)
''片手剣''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|1|[[ダンケルファルシオン>Item/武器/片手剣]]|533 シルバ―|
|15|[[ダンケルカスカラ>Item/武器/片手剣]]|3,600 シルバ―|
|15|[[ダンケルチンクエディア>Item/武器/片手剣]]|4,320 シルバ―|
|40|[[ダンケルサーベル>Item/武器/片手剣]]|5,040 シルバ―|
|40|[[ダンケルシャムシール>Item/武器/片手剣]]|14,840 シルバ―|
|75|[[ダンケルスニッカーズニ>Item/武器/片手剣]]|20,666 シルバ―|
''両手剣''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|15|[[ダンケルバスターソード>Item/武器/両手剣]]|5,760 シルバ―|
|15|[[ダンケルフランベルジュ>Item/武器/両手剣]]|6,912 シルバ―|
|40|[[ダンケル野太刀>Item/武器/両手剣]]|8,064 シルバ―|
|40|[[ダンケルクレイモア>Item/武器/両手剣]]|23,744 シルバ―|
|75|[[ダンケルカダラ>Item/武器/両手剣]]|33,066 シルバ―|
''片手杖''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|1|[[ダンケルロッド>Item/武器/片手杖]]|533 シルバ―|
|15|[[ダンケルケインローバー>Item/武器/片手杖]]|3,600 シルバ―|
|15|[[ダンケルケイン>Item/武器/片手杖]]|4,320 シルバ―|
|40|[[ダンケルクルーク>Item/武器/片手杖]]|5,040 シルバ―|
|40|[[ダンケルピューターロッド>Item/武器/片手杖]]|14,840 シルバ―|
|75|[[ダンケルクリスタルロッド>Item/武器/片手杖]]|20,666 シルバ―|
''両手杖''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|1|[[ダンケルウッドスタッフ>Item/武器/両手杖]]|852 シルバ―|
|15|[[ダンケルオークスタッフ>Item/武器/両手杖]]|5,760 シルバ―|
|15|[[ダンケルスタッフ>Item/武器/両手杖]]|6,912 シルバ―|
|40|[[ダンケルジュウスタッフ>Item/武器/両手杖]]|8,064 シルバ―|
|40|[[ダンケルウポコスタッフ>Item/武器/両手杖]]|23,744 シルバ―|
|75|[[ダンケルデーモンスタッフ>Item/武器/両手杖]]|33,066 シルバ―|
''弓''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|1|[[ダンケルショートボウ>Item/武器/弓]]|533 シルバ―|
|15|[[ダンケルロングボウ>Item/武器/弓]]|5,760 シルバ―|
|15|[[ダンケルコンポジットボウ>Item/武器/弓]]|6,912 シルバ―|
|40|[[ダンケルセルフボウ>Item/武器/弓]]|8,064 シルバ―|
|40|[[ダンケルローカスボウ>Item/武器/弓]]|23744 シルバ―|
|75|[[ダンケルカーマン>Item/武器/弓]]|33,066 シルバ―|
''クロスボウ''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|15|[[ダンケルクロスボウ>Item/武器/クロスボウ]]|3600 シルバ―|
|15|[[ダンケルドキュ>Item/武器/クロスボウ]]|4,320 シルバ―|
|40|[[ダンケルクォレルボウ>Item/武器/クロスボウ]]|5,040 シルバ―|
|40|[[ダンケルオーククロスボウ>Item/武器/クロスボウ]]|14,840 シルバ―|
|75|[[ダンケルクレインクイン>Item/武器/クロスボウ]]|20,666 シルバ―|
''鈍器''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|1|[[ダンケルアイアンクラブ>Item/武器/鈍器]]|533 シルバ―|
|15|[[ダンケルメイス>Item/武器/鈍器]]|3,600 シルバ―|
|15|[[ダンケルモーニングスター>Item/武器/鈍器]]|4,320 シルバ―|
|40|[[ダンケルマウル>Item/武器/鈍器]]|5040 シルバ―|
|40|[[ダンケルゴーデンダック>Item/武器/鈍器]]|14,840 シルバ―|
|75|[[ダンケルバトルハンマー>Item/武器/鈍器]]|20,666 シルバ―|
''片手槍''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|40|[[ダンケルショートスピア>Item/武器/片手槍]]|5,040 シルバ―|
|40|[[ダンケルエスボントゥーン>Item/武器/片手槍]]|5,760 シルバ―|
|75|[[ダンケルアスター>Item/武器/片手槍]]|17,010 シルバ―|
|75|[[ダンケルパイク>Item/武器/片手槍]]|33,066 シルバ―|
#endregion
#region(防具)
''プレート''
|~LV|~名称|~価格|
|CENTER:|CENTER:150|CENTER:200|c
|15|[[ダンケルリングメイル>Item/防具/上半身]]|2,952 シルバー|
|15|[[ダンケルリングパンツ>Item/防具/下半身]]|2,952 シルバー|
|15|[[ダンケルリングブーツ>Item/防具/靴]]|1,296 シルバー|
|15|[[ダンケルリンググローブ>Item/防具/手袋]]|1,296 シルバー|
''レザー''
|~LV|~名称|~価格|
|CENTER:|CENTER:180|CENTER:200|c
|1|[[ダンケルキルトアーマー>Item/防具/上半身]]|360 シルバー|
|1|[[ダンケルキルトパンツ>Item/防具/下半身]]|360 シルバー|
|1|[[ダンケルキルトブーツ>Item/防具/靴]]|180 シルバー|
|1|[[ダンケルキルトグローブ>Item/防具/手袋]]|180 シルバー|
|15|[[ダンケルハードレザーアーマー>Item/防具/上半身]]|2,592 シルバー|
|15|[[ダンケルハードレザーパンツ>Item/防具/下半身]]|2,592 シルバー|
|15|[[ダンケルハードレザーブーツ>Item/防具/靴]]|1,296 シルバー|
|15|[[ダンケルハードレザーグローブ>Item/防具/手袋]]|1,296 シルバー|
''クロース''
|~LV|~名称|~価格|
|CENTER:|CENTER:180|CENTER:200|c
|15|[[ダンケルコットンローブ>Item/防具/上半身]]|2,592 シルバー|
|15|[[ダンケルコットンパンツ>Item/防具/下半身]]|2,592 シルバー|
|15|[[ダンケルコットンブーツ>Item/防具/靴]]|1,296 シルバー|
|15|[[ダンケルコットングローブ>Item/防具/手袋]]|1,296 シルバー|
''盾''
|~LV|~名称|~価格|
|CENTER:|CENTER:180|CENTER:200|c
|1|[[ダンケルウッドシールド>Item/サブウェポン/盾]]|240 シルバー|
|15|[[ダンケルウッドバックラー>Item/サブウェポン/盾]]|1,728 シルバー|
#endregion

***アクセサリ商人 [#nedd1c8a]
#region(アクセサリ)
''ブレスレット''
|~LV|~名称|~価格|
|CENTER:|CENTER:180|CENTER:200|c
|1|[[ライトロネッサバングル>Item/防具/ブレスレット]]|369 シルバー|
|15|[[スーベリアロネッサバングル>Item/防具/ブレスレット]]|1,728 シルバー|
|15|[[ロネッサリングブレスレット>Item/防具/ブレスレット]]|1,728 シルバー|
|40|[[ロネッサノーブルブレスレット>Item/防具/ブレスレット]]|1,728 シルバー|
|75|[[ロネッサクラペダブレスレット>Item/防具/ブレスレット]]|4,536 シルバー|
''ネックレス''
|~LV|~名称|~価格|
|CENTER:|CENTER:180|CENTER:200|c
|1|[[ロネッサウッドネックレス>Item/防具/ネックレス]]|516 シルバー|
|15|[[ロネッサアイアンネックレス>Item/防具/ネックレス]]|1,728 シルバー|
|15|[[ロネッサスチールネックレス>Item/防具/ネックレス]]|1,728 シルバー|
|40|[[ロネッサタリスマン>Item/防具/ネックレス]]|1,728 シルバー|
|75|[[ロネッサクラペダチェーン>Item/防具/ネックレス]]|4,536 シルバー|
#endregion

***雑貨商人 [#ia9fba56]
#region(雑貨商人)
''アイテム''
|~名称|~価格|~効果|~備考|
|CENTER:250|CENTER:200|CENTER:250|CENTER:250|c
|HPポーション(小)|80 シルバー|即時190HP回復&br;毎秒2秒持続回復&br;合計266回復&br;CT20|ステータスで回復量変化|
|HPポーション|160 シルバー|即時320HP回復&br;毎秒2秒持続回復&br;合計488回復&br;CT25|ステータスで回復量変化|
|SPポーション(小)|120 シルバー|即時70HP回復&br;毎秒2秒持続回復&br;合計98回復&br;CT30|ステータスで回復量変化|
|SPポーション|480 シルバー|即時120HP回復&br;毎秒2秒持続回復&br;合計168回復&br;CT45|ステータスで回復量変化|
|小さなスタミナ錠|80 シルバー|スタミナ30回復&br;CT30|-|
|解毒剤|100 シルバー|毒状態を治療する|-|
|クラペダワープの呪文書|500 シルバー|クラペダに移動する&br;右クリックで使用|-|
|オルシャワープの呪文書|500 シルバー|オルシャに移動する&br;右クリックで使用|-|
|金床|300 シルバー|装備強化に使用&br;右クリックで使用|-|
|薪|30 シルバー|座った状態で使用し、&br;たき火を起こせる　|-|
|[[製造書女神の祝福石:武器>Item/クラフト/製造素材/マ行]]|10,000 シルバー|座った状態の製造で使用|-|
|[[製造書女神の祝福石:防具>Item/クラフト/製造素材/マ行]]|10,000 シルバー|座った状態の製造で使用|-|
|[[製造書女神の祝福石:アクセサリ>Item/クラフト/製造素材/マ行]]|10,000 シルバー|座った状態の製造で使用|-|
#endregion

***コンパニオン商人 [#oc4f5116]
#region(コンパニオン商人)
''コンパニオン''
|~名称|~価格|
|CENTER:200|CENTER:300|c
|ヴェルハイダー|110,000 シルバー|
|ホグラン|453,600 シルバー|
|鷹|453,600 シルバー|
''コンパニオンアイテム''
|~名称|~価格|~効果|
|CENTER:200|CENTER:300|CENTER:300|c
|コンパニオンのエサ|489 シルバー|コンパニオンのHP全回復 スタミナ+60|
|シラス|5,127 シルバー|ペンギンのHP全回復 スタミナ+15|
|トマト|300 シルバー|レッサーパンダのHP全回復 スタミナ+60|
#endregion

***鍛冶屋 [#ddf73afb]
#region(鍛冶屋)
''鍛冶屋''
|~名称|~価格|
|CENTER:200|CENTER:300|c
|[[製造書ザリアレザーグローブ>Item/クラフト/防具/製造手袋]]|1,134 シルバー|
|[[製造書ザリアレザーブーツ>Item/クラフト/防具/製造靴]]|1,701 シルバー|
|[[製造書ザリアレザーパンツ>Item/クラフト/防具/製造下半身]]|3,402 シルバー|
|[[製造書ザリアレザーアーマー>Item/クラフト/防具/製造上半身]]|3,402 シルバー|
|[[製造書プロタスブーツ>Item/クラフト/防具/製造靴]]|1,701 シルバー|
|[[製造書プロタストラウザー>Item/クラフト/防具/製造下半身]]|3,402 シルバー|
|[[製造書サベージシールド>Item/クラフト/サブウェポン/製造盾]]|1,092 シルバー|
|[[製造書ルーダスシールド>Item/クラフト/サブウェポン/製造盾]]|4,053 シルバー|
#endregion

**NPC [#c2acf175]
|CENTER:|150|||c
|~画像|~名前|~クエスト|~備考|h
|#ref(コンパニオン商人.jpg)|[コンパニオン商人]&br;クリスティーナ|-|-|
|#ref(アクセサリ商人.jpg)|[アクセサリ商人]&br;ロネッサ|・[[東の森の脅威>Quest/クラペダ#i302eefc]]|-|
|#ref(装備商人.jpg)|[装備商人]&br;ダンケル|-|-|
|#ref(雑貨商人.jpg)|[雑貨商人]&br;ミリア|-|-|
|#ref(鍛冶屋.jpg)|[鍛冶屋]&br;ザラス|・[[司教が見た女神の夢(2)>Quest/クラペダ#k7304afa]]|-|
|#ref(クリオンマンサーマスターjpg.jpg)|[クリオマンサーマスター]&br;アリスター・クロウリー|・[[転職クエ>Class/ウィザード/クリオマンサー]]|-|
|#ref(ペルタストマスター.jpg)|[ペルタストマスター]&br;マリア・リード|・[[転職クエ>Class/ソードマン/ペルタスト]]|-|
|#ref(ウィザードマスター.jpg)|[ウィザードマスター]&br;ルチア|・[[転職クエ>Class/ウィザード]]|-|
|#ref(TP商人.jpg)|[TP商人]&br;レティーシャ|-|-|
|#ref(マーケット管理人jpg.jpg)|[マーケット管理人]&br;ロージー|-|-|
|#ref(倉庫番.jpg)|[倉庫番]&br;リタ|-|-|
|#ref(レンジャーマスター.jpg)|[レンジャーマスター]&br;モーケン|・[[転職クエ>Class/アーチャー/レンジャー]]|-|
|#ref(テンプラーマスター.jpg)|[テンプラーマスター]&br;騎士団長ウスカ|・[[転職クエ>Class/ソードマン/テンプラー]]&br;・[[司教が見た女神の夢(1)>Quest/クラペダ#b172d89a]]&br;・[[一歩一歩の積み重ね>Quest/クラペダ#g61d6cbe]]　&br;・[[正体不明の石板(2)>Quest/水晶鉱山３階]]|-|
|#ref(クレリックマスター.jpg)|[クレリックマスター]&br;ロザリア|・[[転職クエ>Class/クレリック]]|-|
|#ref(プリーストマスター.jpg)|[プリーストマスター]&br;ポラブル|・[[転職クエ>Class/クレリック/プリースト]]|-|
|#ref(バイボラの翼.jpg)|[バイボラの翼]&br;レナ|-|-|
|#ref(オラクルマスター.jpg)|[オラクルマスター]&br;アポロニア・バルボラ|・[[転職クエ>Class/クレリック/オラクル]]|-|
|#ref(アーチャーマスター.jpg)|[アーチャーマスター]&br;アドミュンタス・テイラー|・[[転職クエ>Class/アーチャー]]|-|
|#ref(クリヴィスマスター.jpg)|[クリヴィスマスター]&br;ヘルクス|・[[転職クエ>Class/クレリック/クリヴィス]]|-|
|#ref(クォレルシューターマスター.jpg)|[クォレルシューターマスター]&br;リアム・トイラー|・[[転職クエ>Class/アーチャー/クォレルシューター]]|-|
|#ref(ソードマンマスター.jpg)|[ソードマンマスター]&br;ラシュア|・[[転職クエ>Class/ソードマン/ペルタスト]]|-|

**クエスト [#c65f154b]
-[[クラペダ>Quest/クラペダ]]

**隠し要素 [#x3d2ce03]
-ハイランダーマスターの部屋にいる「練習用の木人形」を壊すと隠しクエストが発生する。
ハイランダーマスターに話しかけて受注。
クエストの推奨Lvは40くらい。
報酬は所持重量100増加。
--木人形は叩き続ければ壊せる。木人形の受けるダメージは全て1でHPは50程度、普段は高速で自動回復(秒間10かそれ以上?)している。
しかし、ときどき自動回復が止まり、その間に十分HPを削り切れる。なお、まれに移動する(逃げる)。

**コメント [#uf56c633]
#pcomment(./コメント,reply,10)
    
]==]




























































































































































































































































)
tester = tester
