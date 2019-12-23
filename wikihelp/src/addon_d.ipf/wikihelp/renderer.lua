
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
local actions={
    text={},
    font={},
    br={},
    header={},
    hl={},
    image={},
    comment={},
    td={},
    tr={},
    table={},
    li={},
    ln={},
    a={},
    quote={},
    title={},
}
local function inc(context)
    local idx=context.controlindex
    context.controlindex=context.controlindex+1
    return idx
end
local function genfont(context)
    return context.fontbase..context.fontcolor..context.fontsize
end
function actions.text.fn(rootframe,frame,node,context)
    local txt=frame:CreateOrGetControl("richtext","text"..tostring(inc(context)),context.x,context.y,0,0)
    tolua.cast(txt,"ui::CRichText")
    txt:EnableAutoResize(true,true)
    txt:SetText(genfont(context)..node.content)
    txt:EnableHitTest(0)

    context.x=context.x+txt:GetWidth()
    context.carryheight=math.max(context.carryheight,txt:GetHeight())
    return frame
end
function actions.font.fn(rootframe,frame,node,context)
    if(node.attrib.color)then
        context.fontcolor="{#"..node.attrib.color.."}"
       
    end
    if(node.attrib.size)then
        local size=tonumber(node.attrib.size)*4+8

        context.fontsize="{s"..tostring(size).."}"

    end
    return frame
end
function actions.br.fn(rootframe,frame,node,context)
    context.x=16
    context.y=context.y+ context.carryheight+4
    context.carryheight=0
    return frame
end
function actions.header.fn(rootframe,frame,node,context)
    context.size="{s24}"

    context.x=8
    return frame
end
function actions.header.after_fn(rootframe,previousframe,frame,node,context)
    context.x=16
    context.y=context.y+ context.carryheight+4
    context.carryheight=0
    return frame
end
function actions.hl.fn(rootframe,frame,node,context)
    
    context.y=context.y+8
    return frame
end
function actions.image.fn(rootframe,frame,node,context)
    local img=frame:CreateOrGetControl("picture","image"..tostring(inc(context)),context.x,context.y,24,24)
    tolua.cast(img,"ui::CPicture")
    img:SetImage("sign_enchant")
    img:Resize(img:GetImageWidth(),img:GetImageHeight())
    img:EnableAutoResize(true,true)

    img:EnableHitTest(0)
   
    context.x=context.x+img:GetWidth()
    context.carryheight=math.max(context.carryheight,img:GetHeight())
    return frame
end
function actions.comment.fn(rootframe,frame,node,context)
    return nil
end
function actions.table.fn(rootframe,frame,node,context)
    context.x=16
    context.y=context.y+ context.carryheight+4
    context.carryheight=0
    local gbox=frame:CreateOrGetControl("groupbox","gbox"..tostring(inc(context)),context.x,context.y,50,50)
    tolua.cast(gbox,"ui::CGroupBox")
    gbox:EnableScrollBar(0)
    --gbox:AutoSize(1)
    gbox:EnableHittestGroupBox(false)
    gbox:SetSkinName("chat_window")
    node.frame=gbox
    context.x=16
    context.y=16
    context.table={}
    return gbox,true
end
function actions.table.after_fn(rootframe,previousframe,frame,node,context)
    --ここにリサイズ処理を入れる
    frame:AutoSize(1)
    context.y=context.y+frame:GetHeight()

    local widths={}
    for row=1,#context.table do

        for column=1,#context.table[row].t do
      
            local cell=context.table[row].t[column].f
            for i=0,cell:GetChildCount()-1 do
                local child=cell:GetChildByIndex(i)
                local w=child:GetWidth()+child:GetX()
                widths[column]= math.max((widths[column] or 0), w)
            end
            
        end
    end
    local maxx=0

    for column=1,#widths do
        maxx=maxx+widths[column]

    end

    for row=1,#context.table do
        local x=0
        local parent=context.table[row].f
        for column=1,#context.table[row].t do
            local cell=context.table[row].t[column].f
 
            cell:SetOffset(x,cell:GetY())
            cell:Resize(widths[column],cell:GetHeight())
         
            x=x+widths[column]

           
        end
        
         
        
        parent:Resize(x,parent:GetHeight())
        
    end
    frame:Resize(maxx,frame:GetHeight())
    context.table=nil
    return frame
end
function actions.tr.fn(rootframe,frame,node,context)
    local gbox=frame:CreateOrGetControl("groupbox","tr"..tostring(inc(context)),context.x,context.y,10,10)
    tolua.cast(gbox,"ui::CGroupBox")
    node.frame=gbox
    gbox:EnableScrollBar(0)
    --gbox:AutoSize(1)
    gbox:EnableHittestGroupBox(false)
   
    --gbox:SetSkinName("chat_window")
    context.x=0
    context.y=0
    context.table[#context.table+1]={f=gbox,t={}}
    return gbox,true
end
function actions.tr.after_fn(rootframe,previousframe,frame,node,context)
    frame:AutoSize(1)
    context.x=0
    context.y=context.y+frame:GetHeight()
    
    return frame
   
end
function actions.td.fn(rootframe,frame,node,context)
    local gbox=frame:CreateOrGetControl("groupbox","gbox"..tostring(inc(context)),context.x,context.y,10,10)
    tolua.cast(gbox,"ui::CGroupBox")
    node.frame=gbox
    gbox:EnableScrollBar(0)
    --gbox:AutoSize(1)
    gbox:EnableHittestGroupBox(false)
    gbox:EnableAutoResize(true,true)
    gbox:SetClickSound('button_click_big');
    context.x=0
    context.y=0
    context.table[#context.table].t[#context.table[#context.table].t+1]={f=gbox}
    return gbox,true
end
function actions.td.after_fn(rootframe,previousframe,frame,node,context)
    frame:AutoSize(1)
    context.x=context.x+frame:GetWidth()
    
    return frame
end


function actions.li.fn(rootframe,frame,node,context)
    local txt=frame:CreateOrGetControl("richtext","text"..tostring(inc(context)),context.x,context.y,0,0)
    tolua.cast(txt,"ui::CRichText")
    txt:EnableAutoResize(true,true)
    txt:SetText(genfont(context).." ･ ")
    txt:EnableHitTest(0)
    context.x=context.x+txt:GetWidth()
    context.carryheight=math.max(context.carryheight,txt:GetHeight())
    return frame
end
function actions.ln.fn(rootframe,frame,node,context)
    local txt=frame:CreateOrGetControl("richtext","text"..tostring(inc(context)),context.x,context.y,0,0)
    tolua.cast(txt,"ui::CRichText")
    txt:EnableAutoResize(true,true)
    txt:EnableHitTest(0)
    txt:SetText(genfont(context).." * ")

    context.x=context.x+txt:GetWidth()
    context.carryheight=math.max(context.carryheight,txt:GetHeight())
    return frame
end
function actions.a.fn(rootframe,frame,node,context)
    local gbox=frame:CreateOrGetControl("groupbox","gbox"..tostring(inc(context)),context.x,context.y,0,0)
    tolua.cast(gbox,"ui::CGroupBox")
    node.frame=gbox
    gbox:EnableScrollBar(0)
    gbox:EnableHitTest(1)
    gbox:EnableHittestGroupBox(true)
    gbox:SetSkinName("test_skin_01_btn")
    print("a")
    gbox:SetOverSound("button_cursor_over_2")
    gbox:SetClickSound("button_cursor_over_2")
    gbox:SetEventScript(ui.LBUTTONUP,"WH_RENDERER_CLICK_A")
    gbox:SetEventScriptArgString(ui.LBUTTONUP,node.attrib.link or "")
    context.x=4
    context.y=4
    return gbox,true
end
function actions.a.after_fn(rootframe,previousframe,frame,node,context)
    frame:AutoSize(1)
    print("a")
    frame:Resize(frame:GetWidth()+4,frame:GetHeight()+4)

    context.x=frame:GetWidth()
    context.carryheight=math.max(context.carryheight,frame:GetHeight())
    return frame
end

function actions.title.fn(rootframe,frame,node,context)
    context.title=node.content
    return frame
end
function actions.quote.fn(rootframe,frame,node,context)
    context.x=context.x+16
    return frame
end

function R.render(rootframe,frame,node,context)
    
    frame=frame or rootframe
    context=context or {
        x=16,
        y=8,
        carryheight=0,
        controlindex=1,
        fontsize="{s16}",
        fontbase="{ol}",
        fontcolor="",
    }
    local action=actions[node.name]
    local previousframe=frame
    local contextbk=deepcopy(context)
    local needtorecoverposition=false
    if(action==nil)then
        --print("Not found Tag:"..node.name)
    else
        
        frame,needtorecoverposition=action.fn(rootframe,frame,node,context)
    end
    if(frame~=nil) then
        if(node.child)then
            for _,v in ipairs(node.child) do
                
                context=R.render(rootframe,frame,v,context)
                
            end
        end
    else
        frame=previousframe
    end
    if(needtorecoverposition)then
        context.x=contextbk.x
        context.y=contextbk.y
        context.carryheight=contextbk.carryheight
    end   
    context.fontsize=contextbk.fontsize
    context.fontbase=contextbk.fontbase
    context.fontcolor=contextbk.fontcolor
    if(action and action.after_fn)then
        frame=action.after_fn(rootframe,previousframe,frame,node,context)
    end

    
    return context
end
function WH_RENDERER_CLICK_A(frame,ctrl,argstr,argnum)

end
--EOF
WIKIHELP_RENDERER=R

