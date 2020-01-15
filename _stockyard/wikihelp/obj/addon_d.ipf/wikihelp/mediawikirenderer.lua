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
    br={},
    tag={},
    split={},
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
function string.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
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
    push(context.font,{size=18,color="FFFFFF",bold="",base="{ol}"})
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
function A.br.enter_fn(rootframe,frame,node,context)
    

    newline(context)

    return frame,false
end
function A.tag.enter_fn(rootframe,frame,node,context)
    
    if(node.attrib.tagname=="tabber")then
        --タブ生成
        local tab=frame:CreateOrGetControl("tab","tab"..acq(context),pos(context).x,pos(context).y,frame:GetWidth(),40)
        tolua.cast(tab,"ui::CTabControl")
        tab:SetSkinName("tab2")
        for k,v in ipairs(node.child)do
            local key=v.key
            tab:AddItem("{ol}"..key:trim())
        end
        tab:SetOverSound("btn_mouseover")
        tab:SetClickSound("inven_arrange")
        writecarryh(context,40)
        newline(context)
    end
    return frame,true
end
function A.tag.leave_fn(rootframe,frame,node,context)

    return frame
end
function A.header.enter_fn(rootframe,frame,node,context)
    
    newfont(context)
    newline(context)
    local s=peek(context.font)
    s.size=24
    if(node.attrib.level<=2)then
        local pic=frame:CreateOrGetControl("picture","bk"..acq(context),pos(context).x,pos(context).y,frame:GetWidth(),32)
        tolua.cast(pic,"ui::CPicture")
        pic:SetEnableStretch(0)
        pic:CreateInstTexture()
        pic:EnableHitTest(0)
        pic:FillClonePicture("00000000")
        pic:DrawBrush(0,0,0,pic:GetHeight(),"spray_8","FF664422")
        pic:DrawBrush(8,0,8,pic:GetHeight(),"spray_8","FF664422")
        pic:DrawBrush(0,pic:GetHeight(),pic:GetWidth(),pic:GetHeight(),"spray_8","FF664422")
        
        pic:Invalidate()
    end
    writecarryh(context,32)
    poke(context.font,s)
    addx(context,16)
    return frame,true
end
function A.header.leave_fn(rootframe,frame,node,context)
    DBG("h l")
    pop(context.font)
    newline(context)
    return frame
end
function A.text.enter_fn(rootframe,frame,node,context)

    local spr=node.content:split(" ")
    local concat=""
    local name="text"..acq(context)
    local prevconcat=""
    local limitw=math.max(100,frame:GetWidth())
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
        --newline(context)
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
    newline(context)
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),0,0,frame:GetWidth(),1)
    tolua.cast(ctrl,"ui::CGroupBox")
    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    ctrl:SetSkinName("chat_window")
    R.applystyle(ctrl,node,context,false,true)
    newpos(context)
    newfont(context)
    context.table=context.table or {}
    push(context.table,{rows={},row=1,column=1})
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
    for r,row in ipairs(peek(context.table).rows)do
        for c,cell in ipairs(row.cells)do
            cellw[c]=cellw[c] or 0
            cellw[c]=math.max(cellw[c],cell.frame:GetWidth())
            print("MWIDTH"..tostring(cellw[c]))
        end
    end
    frame:Resize(mx,my)
    R.applystyle(frame,node,context)
    local ry=0
    for r,row in ipairs(peek(context.table).rows)do
        local x=0
        
        local rowheight=0
        if(row and row.cells)then
            
            for c,cell in ipairs(row.cells)do
                if(cell)then
                    local cf=cell.frame
                    local n=cell.node
                    cell.frame:Resize(cellw[c],cf:GetHeight())
                    cell.frame:SetOffset(x,ry)
                    DBG(string.format("XX:%d YY:%d",x,ry))
                    if(n.attrib and n.attrib.colspan)then
                        --colスパニング処理
                        local ax=0
                        local pax=0
                        
                        for cc=c,c+tonumber(n.attrib.colspan)-1 do
                            if(cellw[cc])then
                                
                                pax=ax
                                ax=ax+cellw[cc]
                            end
                        end
                        DBG("COLSPAN "..n.attrib.colspan.." W" ..tostring(ax).." RY"..tostring(ry))
                        --親子関係を入れ替える
                        local cx=cf:GetX()
                        local cy=cf:GetParent():GetY()
                        DBG(cell.frame:GetParent():GetName())
                        
                        --frame:AddChild(cf,cf:GetName())
                        --cf:SetOffset(x,ry)
                    
                        cell.frame:Resize(ax,cf:GetHeight())
                    end
                    if(n.attrib and n.attrib.rowspan)then
                        --rowスパニング処理
                        local ay=0
                        for cy=r,r+tonumber(n.attrib.rowspan)-1 do
                            local cl=peek(context.table).rows[cy]
                            ay=ay+cl.row:GetHeight()
                        end
                        --親子関係を入れ替える
         
                        local cx=cf:GetX()
                        local cy=cf:GetY()
                        --frame:AddChild(cf,cf:GetName())
                        --cf:SetOffset(cx,cy)
                        
                        cf:Resize(cf:GetWidth(),ay)
                    end
                   
                    DBG("CELLHEIGHT:"..tostring(cf:GetHeight()))
                    rowheight=math.max(cf:GetHeight(),rowheight)
                    R.applystyle(cf,n,context)
                end
                DBG("CELLC:"..tostring(cellw[c]))
                x=x+cellw[c]
            end
        end
        row.row:SetOffset(0,ry)
        ry=ry+rowheight
        
        row.row:Resize(row.row:GetWidth(),rowheight)
    end
    
    
 
    pop(context.pos)
    pop(context.font)
    pop(context.table)
    local np=pos(context)
    np.y=np.y+my
    poke(context.pos,np)

    return frame:GetParent()
end
function A.tr.enter_fn(rootframe,frame,node,context)
    if(peek(context.table)==nil)then
        return frame,false
    end
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,frame:GetWidth(),1)
    tolua.cast(ctrl,"ui::CGroupBox")

    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)
    --ctrl:SetSkinName("chat_window")

    R.applystyle(ctrl,node,context,false,true)
    --newpos(context)
    newfont(context)
    peek(context.table).rows[peek(context.table).row]={
        index=peek(context.table).row,
        row=ctrl,
        cells={}
    }
    DBG("tr")
    return frame,true
end

function A.tr.leave_fn(rootframe,frame,node,context)
    
    

    if(peek(context.table)==nil)then
        return frame
    end
   
    pop(context.font)
    local np=pos(context)
    

    R.applystyle(frame,node,context,false,true)
    peek(context.table).row=peek(context.table).row+1
    peek(context.table).column=1
    newline(context)
    return frame
end
function A.td.enter_fn(rootframe,frame,node,context)
    if(peek(context.table)==nil)then
        return frame,false
    end
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,frame:GetWidth(),1)
    tolua.cast(ctrl,"ui::CGroupBox")

    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)

    R.applystyle(ctrl,node,context)
    peek(context.table).rows[peek(context.table).row].cells
    [peek(context.table).column]=
    {
        row=peek(context.table).row,
        column=peek(context.table).column,
        node=node,
        frame=ctrl,
    }

    newpos(context)
    newfont(context)
    
    return ctrl,true
end

function A.td.leave_fn(rootframe,frame,node,context)
    if(peek(context.table)==nil)then
        return frame
    end
    local parent=frame:GetParent()

    
    local mx=1
    local my=1
    for i=0,frame:GetChildCount()-1 do
        local child=frame:GetChildByIndex(i)
        mx=math.max(mx,child:GetX()+child:GetWidth())
        my=math.max(my,child:GetY()+child:GetHeight())
        DBG("MY"..tostring(my))
    end
    frame:Resize(mx,my)
    
    
    frame:AutoSize(1)
    R.applystyle(frame,node,context,true)
    pop(context.pos)
    pop(context.font)
    addx(context,frame:GetWidth())
    writecarryh(context,frame:GetHeight())
    
    peek(context.table).column=peek(context.table).column+1
    DBG("td l"..tostring(frame:GetHeight())..","..tostring(frame:GetWidth()))
    return frame:GetParent()
end
function A.split.enter_fn(rootframe,frame,node,context)
    local ctrl=frame:CreateOrGetControl("groupbox","gbox"..acq(context),pos(context).x,pos(context).y,frame:GetWidth(),1)
    tolua.cast(ctrl,"ui::CGroupBox")

    ctrl:EnableScrollBar(0)
    ctrl:EnableHittestGroupBox(false)


    newpos(context)
    newfont(context)
    
    return ctrl,true
end

function A.split.leave_fn(rootframe,frame,node,context)
    
    local parent=frame:GetParent()
    frame:AutoSize(1)

    pop(context.pos)
    pop(context.font)
    --addx(context,frame:GetWidth())
    writecarryh(context,frame:GetHeight())

    return frame:GetParent()
end
function R.applystyle(frame,node,context,isinnercell,enableresize)
    if(not node.attrib)then
        return
    end
    local style=node.attrib.style
    if(not style)then
        return
    end
   
    if style["font-size"] then
        local base=18
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
    if style["width"] and not isinnercell and enableresize then
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
    if style["background-color"] and style["background-color"]:len()>=2 then
        
        local has=frame:GetChild("bg")

        local bk=frame:CreateOrGetControl("picture","bg",0,0,8,8)
        DBG("bgcolor")
        tolua.cast(bk,"ui::CPicture")
        DBG(string.format("BG %d,%d",frame:GetWidth(),frame:GetHeight()))
        bk:Resize(math.max(8,frame:GetWidth()),math.max(8,frame:GetHeight()))
        bk:CreateInstTexture()
        bk:FillClonePicture("FF"..style["background-color"]:sub(2))
        bk:SetEnableStretch(1)
        bk:EnableHitTest(0)
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

