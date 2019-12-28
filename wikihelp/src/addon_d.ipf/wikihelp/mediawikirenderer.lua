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
    header={},
}
local function DBG(str)
    --WIKIHELP_DBGOUT(str)
    print(str)
end
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
function A.header.enter_fn(rootframe,frame,node,context)
    
    newfont(context)
    local s=peek(context.font)
    s.size=24
    DBG("h e")
    poke(context.font,s)
    return frame,true
end
function A.header.leave_fn(rootframe,frame,node,context)
    DBG("h l")
    pop(context.font)
    return frame
end
function A.text.enter_fn(rootframe,frame,node,context)

    local spr=node.content:split(" ")
    local concat=""
    local name="text"..acq(context)
    local prevconcat=""
    local limitw=math.max(100,frame:GetWidth()-50)
    DBG("LIMIT:"..tostring(limitw))
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
    R.applystyle(frame,node,context)
    DBG(node.content .. string.format("%d,%d",pos(context).x,pos(context).y))
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
    local txt=ctrl:CreateOrGetControl("richtext","internaltext",4,4,0,0)
    txt:SetText(genfont(context)..node.content)
    txt:EnableHitTest(0)
    ctrl:AutoSize(1)
    ctrl:Resize(ctrl:GetWidth()+4,ctrl:GetHeight()+4)
    newpos(context)
    newfont(context)

    return frame,false
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
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,frame:GetWidth(),1)
    tolua.cast(ctrl,"ui::CGroupBox")
    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    ctrl:SetSkinName("chat_window")
    R.applystyle(ctrl,node,context)
    newpos(context)
    newfont(context)
    context.table={rows={},row=1,column=1}
    DBG("table")
    return ctrl,true
end
function A.table.leave_fn(rootframe,frame,node,context)
    
    
   
    local parent=frame:GetParent()

   

    --TODO:成形する
    local cellw={}
    local mx=1
    local my=1
    for i=0,frame:GetChildCount()-1 do
        local child=frame:GetChildByIndex(i)
        mx=math.max(mx,child:GetX()+child:GetWidth())
        my=math.max(my,child:GetY()+child:GetHeight())
    end
    for r,row in ipairs(context.table.rows)do
        for c,cell in ipairs(row.cells)do
            if(cellw[c]==nil)then
                cellw[c]=cell.frame:GetWidth()
            else
                cellw[c]=math.max(cellw[c],cell.frame:GetWidth())
            end
        end
    end
    for r,row in ipairs(context.table.rows)do
        local x=0
        for c,cell in ipairs(row.cells)do
            cell.frame:Resize(cellw[c],cell.frame:GetHeight())
            cell.frame:SetOffset(x,cell.frame:GetY())
            x=x+cellw[c]
            DBG("X "..tostring(x).." Y "..tostring(cell.frame:GetY()))
        end
        row.row:Resize(x,row.row:GetHeight())
    end
    
    
    frame:Resize(mx,my)
    R.applystyle(frame,node,context)
    pop(context.pos)
    pop(context.font)
    local np=pos(context)
    np.y=np.y+my
    poke(context.pos,np)
    
    return frame:GetParent()
end
function A.tr.enter_fn(rootframe,frame,node,context)
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,frame:GetWidth(),1)
    tolua.cast(ctrl,"ui::CGroupBox")

    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    --ctrl:SetSkinName("chat_window")
    DBG("FRAME:"..tostring(frame:GetWidth()))
    R.applystyle(ctrl,node,context)
    newpos(context)
    newfont(context)
    context.table.rows[context.table.row]={
        row=ctrl,
        cells={}
    }
    DBG("tr")
    return ctrl,true
end

function A.tr.leave_fn(rootframe,frame,node,context)
    
    
    if( node.style and not node.style.width)then
        frame:AutoSize(1)
    end
    local parent=frame:GetParent()

   
    local mx=1
    local my=1
    for i=0,frame:GetChildCount()-1 do
        local child=frame:GetChildByIndex(i)
        mx=math.max(mx,child:GetX()+child:GetWidth())
        my=math.max(my,child:GetY()+child:GetHeight())
        
    end
    DBG("TR"..tostring(mx))
    
    pop(context.pos)
    pop(context.font)
    local np=pos(context)
    np.y=np.y+my
    poke(context.pos,np)
    
    frame:Resize(mx,my)
    R.applystyle(frame,node,context)
    context.table.row=context.table.row+1
    context.table.column=1
    newline(context)
    return frame:GetParent()
end
function A.td.enter_fn(rootframe,frame,node,context)
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,200,1)
    tolua.cast(ctrl,"ui::CGroupBox")

    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    --ctrl:SetSkinName("chat_window")

    R.applystyle(ctrl,node,context)
    context.table.rows[context.table.row].cells
    [context.table.column]=
    {
        node=node,
        frame=ctrl,
    }

    newpos(context)
    newfont(context)
    
    return ctrl,true
end

function A.td.leave_fn(rootframe,frame,node,context)
    
    local parent=frame:GetParent()

    
    -- local mx=1
    -- local my=1
    -- for i=0,frame:GetChildCount()-1 do
    --     local child=frame:GetChildByIndex(i)
    --     mx=math.max(mx,child:GetX()+child:GetWidth())
    --     my=math.max(my,child:GetY()+child:GetHeight())
    --     DBG("MY"..tostring(my))
    -- end
    -- frame:Resize(mx,my)
    
    
    frame:AutoSize(1)
    R.applystyle(frame,node,context)
    pop(context.pos)
    pop(context.font)
    addx(context,frame:GetWidth())
    writecarryh(context,frame:GetHeight())
    
    context.table.column=context.table.column+1
    DBG("td l"..tostring(frame:GetHeight())..","..tostring(frame:GetWidth()))
    return frame:GetParent()
end
function R.applystyle(frame,node,context)
    if(not node.attrib)then
        return
    end
    local style=node.attrib.style
    if(not style)then
        return
    end
    if style["background-color"] and style["background-color"]:len()>=2 then
        
        local has=frame:GetChild("bg")
        if(has)then
            frame:RemoveChild(has:GetName())
        end
        local bk=frame:CreateOrGetControl("picture","bg",0,0,8,8)
        DBG("bgcolor")
        tolua.cast(bk,"ui::CPicture")
        DBG(string.format("BG %d,%d",frame:GetWidth(),frame:GetHeight()))
        bk:Resize(math.max(8,frame:GetWidth()),math.max(8,frame:GetHeight()))
        bk:CreateInstTexture()
        bk:FillClonePicture("FF"..style["background-color"]:sub(2))
        bk:SetEnableStretch(1)
    
        --draw border
        -- bk:DrawBrush(1,1,bk:GetWidth()-1,1,"spray_1","FF000000")
        -- bk:DrawBrush(1,1,1,bk:GetHeight()-1,"spray_1","FF000000")
        -- bk:DrawBrush(bk:GetWidth()-1,1,bk:GetWidth()-1,bk:GetHeight()-1,"spray_1","FF000000")
        -- bk:DrawBrush(1,bk:GetHeight()-1,bk:GetWidth()-1,bk:GetHeight()-1,"spray_1","FF000000")
        -- bk:DrawBrush(0,0,bk:GetWidth()-2,0,"spray_1","FFFFFFFF")
        -- bk:DrawBrush(0,0,0,bk:GetHeight()-2,"spray_1","FFFFFFFF")
        -- bk:DrawBrush(bk:GetWidth()-2,0,bk:GetWidth()-2,bk:GetHeight()-2,"spray_1","FFFFFFFF")
        -- bk:DrawBrush(0,bk:GetHeight()-2,bk:GetWidth()-2,bk:GetHeight()-2,"spray_1","FFFFFFFF")
        bk:Invalidate()
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

        
        frame:Resize(fs,frame:GetHeight())
    end
    if style["text-align"] then
        if(style["text-align"]=="center")then
            frame:SetGravity(ui.CENTER_HORZ,ui.TOP)
        end
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

