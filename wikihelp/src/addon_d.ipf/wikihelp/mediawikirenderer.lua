--renderer
local R={}
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
local context
local A={
    example={},
    text={},
    font={},
    link={},
    table={},
    tr={},
    td={},
}
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
function string.ends(String, Ends)
    return string.sub(String, -string.len(Ends)) == Ends
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
local function peek(tbl)
    if(not tbl)then
        return nil
    end
    return tbl[#tbl]
end
local function poke(tbl,last)

    tbl[#tbl]=last
end
local function pop(tbl)
    local last=tbl[#tbl]
    tbl[#tbl]=nil
    return last
end
local function push(tbl,data)
    tbl[#tbl+1]=data
end
local function initpos()
    return {x=0,y=0,carryh=0}
end
local function pos(context)
    context.pos=context.pos or initpos()
    local posa=peek(context.pos) or initpos()
    return posa
end
local function writecarryh(context,carryh)
    context.pos=context.pos or  initpos()
    context.pos[#context.pos].carryh=math.max(context.pos[#context.pos].carryh,carryh)
end
local function addx(context,x)
    context.pos=context.pos or initpos()
    context.pos[#context.pos].x=context.pos[#context.pos].x+x
    
end
local function newpos(context)
    push(context.pos,initpos())
end
local function newline(context)
    poke(context.pos,{x=0,y=pos(context).y+pos(context).carryh,carryh=0})
end
local function newfont(context)
    context.font=context.font or {}
    push(context.font,{size=16,color="FFFFFF",bold="",base="{ol}"})
end
local function acq(context)
    local idx=context.controlindex
    context.controlindex=context.controlindex+1
    return tostring(idx)
end

local function genfont(context)
    local font=peek(context.font)
    return font.base..(font.bold).."{#"..font.color.."}".."{s"..tostring(math.ceil(font.size)).."}"
end
function A.example.enter_fn(rootframe,frame,node,context)
    return frame,true
end
function A.example.leave_fn(rootframe,frame,node,context)
    return frame:GetParent()
end
function A.text.enter_fn(rootframe,frame,node,context)
    
    local spr=node.content:split(" ")
    local concat=""
    local name="text"..acq(context)
    local prevconcat=""
    local limitw=math.max(100,frame:GetWidth())
    local ctrl
    for _,v in ipairs(spr) do
        concat=concat.." "..v
        ctrl=frame:CreateOrGetControl("richtext",name,pos(context).x,pos(context).y,0,0)
        ctrl:SetText(genfont(context)..concat)
        ctrl:EnableHitTest(0)
        local w=ctrl:GetWidth()
        if(limitw<w)then
            --その文字を消す
            ctrl:SetText(genfont(context)..prevconcat)

            --改行
            writecarryh(context,ctrl:GetHeight())
            newline(context)

            --積みを消す
            concat=""

            --新規作成
            name="text"..acq(context)
            ctrl=frame:CreateOrGetControl("richtext",name,pos(context).x,pos(context).y,0,0)
            ctrl:SetText(genfont(context)..concat)
            ctrl:EnableHitTest(0)
        end
        --TODO 必要ならリミットを再計算
        prevconcat=concat
    end
    if(ctrl)then
        addx(context,ctrl:GetWidth())
        writecarryh(context,ctrl:GetHeight())
        newline(context)
    end
    print(node.content .. string.format("%d,%d",pos(context).x,pos(context).y))
    return frame,false
end
function A.link.enter_fn(rootframe,frame,node,context)
    
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,0,0)
    tolua.cast(ctrl,"ui::CGroupBox")
    ctrl:EnableScrollBar(0)
    ctrl:EnableHitTest(1)
    ctrl:EnableHittestGroupBox(true)
    ctrl:SetSkinName("test_skin_01_btn")
    ctrl:SetOverSound("button_cursor_over_2")
    ctrl:SetClickSound("button_click_big")
    newpos(context)
    newfont(context)
    print("link")
    return ctrl,true
end
function A.link.leave_fn(rootframe,frame,node,context)
    
   
    frame:AutoSize(1)
    
    local parent=frame:GetParent()

    --TODO:成形する
    pop(context.pos)
    pop(context.font)
    addx(context,frame:GetWidth())
    return frame:GetParent()
end
function A.table.enter_fn(rootframe,frame,node,context)
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,0,0)
    tolua.cast(ctrl,"ui::CGroupBox")
    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    ctrl:SetSkinName("chat_window")
    R.applystyle(ctrl,node,context)
    newpos(context)
    newfont(context)
    context.table={tr={},row=1,column=1}
    print("table")
    return ctrl,true
end
function A.table.leave_fn(rootframe,frame,node,context)
    
    
    if( node.style and not node.style.width)then
        frame:AutoSize(1)
    end
    local parent=frame:GetParent()
    local bg=frame:GetChild("bg")
    R.applystyle(frame,node,context)
    if(bg)then
        print("bg")
        bg:Resize(frame:GetWidth(),frame:GetHeight())
        bg:Invalidate()
    end

    --TODO:成形する

    pop(context.pos)
    pop(context.font)
    return frame:GetParent()
end
function A.tr.enter_fn(rootframe,frame,node,context)
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,0,0)
    tolua.cast(ctrl,"ui::CGroupBox")

    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    ctrl:SetSkinName("chat_window")

    R.applystyle(ctrl,node,context)
    newpos(context)
    newfont(context)
    print("tr")
    return ctrl,true
end

function A.tr.leave_fn(rootframe,frame,node,context)
    
    
    if( node.style and not node.style.width)then
        frame:AutoSize(1)
    end
    local parent=frame:GetParent()
    local bg=frame:GetChild("bg")
    R.applystyle(frame,node,context)
    if(bg)then
        print("bg")
        bg:Resize(frame:GetWidth(),frame:GetHeight())
        bg:Invalidate()
    end
    pop(context.pos)
    pop(context.font)
    context.table.row=context.table.row+1
    context.table.column=1
    newline(context)
    return frame:GetParent()
end
function A.td.enter_fn(rootframe,frame,node,context)
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,100,20)
    tolua.cast(ctrl,"ui::CGroupBox")

    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    ctrl:SetSkinName("chat_window")

    R.applystyle(ctrl,node,context)
    newpos(context)
    newfont(context)
    print("td")
    return ctrl,true
end

function A.td.leave_fn(rootframe,frame,node,context)
    frame:AutoSize(1)
    local parent=frame:GetParent()
    local bg=frame:GetChild("bg")
    R.applystyle(frame,node,context)
    if(bg)then
        print("bg")
        bg:Resize(frame:GetWidth(),frame:GetHeight())
        bg:Invalidate()
    end
    pop(context.pos)
    pop(context.font)
    addx(context,frame:GetWidth())
    writecarryh(context,frame:GetHeight())
    context.table.column=context.table.column+1
    return frame:GetParent()
end
function R.applystyle(frame,node,context)
    local style=node.attrib.style
    if(not style)then
        return
    end
    if style["background-color"] and style["background-color"]:len()>=2 then
        local bk=frame:CreateOrGetControl("picture","bg",0,0,1,1)
        print("bgcolor")
        tolua.cast(bk,"ui::CPicture")
        bk:CreateInstTexture()
        bk:FillClonePicture("FF"..style["background-color"]:sub(2))
        bk:SetEnableStretch(1)
    end
    if style["font-size"] then
        local base=16
        local fs=base
        local str=style["font-size"]
        if(str:ends("%"))then
            fs=fs*tonumber(str:sub(1,-2))/100
        elseif (str:ends("px"))then
            fs=tonumber(str:sub(1,-3))
        end
        peek(context.font).size=fs
    end
    if style["color"] then
        local base="FFFFFF"
        local fs=base
        local str=style["color"]:sub("2")
        
        peek(context.font).color=fs
    end
    if style["width"] then
        local base=frame:GetParent():GetWidth()
        local fs=base
        local str=style["width"]
        if(str:ends("%"))then
            fs=fs*tonumber(str:sub(1,-2))/100
        elseif (str:ends("px"))then
            fs=tonumber(str:sub(1,-3))
        end
        print("width "..tostring(fs).."["..style["width"])
        
        frame:Resize(fs,frame:GetHeight())
    end
end

function R.render(rootframe,node)
    local context
    context=context or {
        pos={initpos()},
        pagename=node.attrib.pagename,
        controlindex=1
    }
    newfont(context)
    R.renderimpl(rootframe,rootframe,node,context)
end
function R.renderimpl(rootframe,frame,node,context)

    local act=A[node.name]

    
    local result=true
    if(act and act.enter_fn)then
       
        frame,result=act.enter_fn(rootframe,frame,node,context)
        
    end
    local framebk=frame
    if(node.child and result)then
        for _,v in ipairs(node.child) do
            frame=R.renderimpl(rootframe,frame,v,context)
        end
    end
    frame=framebk
    if(act and act.leave_fn)then
       
        frame=act.leave_fn(rootframe,frame,node,context)
        
    end
    return frame
end

--EOF
WIKIHELP_MEDIAWIKIRENDERER=R

