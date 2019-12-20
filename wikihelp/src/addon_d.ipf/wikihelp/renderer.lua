
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
function actions.text.fn(rootframe,frame,node,context)
    local txt=frame:CreateOrGetControl("richtext","text"..tostring(context:inc()),context.x,context.y,0,0)
    tolua.cast(txt,"ui::CRichText")
    txt:EnableAutoResize(1)
    txt:SetText(context.font..node.content)

    context.x=context.x+txt:GetWidth()
    context.carryheight=math.max(context.carryheight,txt:GetHeight())
    return frame
end
function actions.font.fn(rootframe,frame,node,context)
    return frame
end
function actions.br.fn(rootframe,frame,node,context)
    context.x=16
    context.y=context.y+ context.carryheight+4
    return frame
end
function actions.header.fn(rootframe,frame,node,context)
    context.font="{s24}{ol}"
    context.x=8
    return frame
end
function actions.hl.fn(rootframe,frame,node,context)
    
    context.y=context.y+8
    return frame
end
function actions.image.fn(rootframe,frame,node,context)
    local img=frame:CreateOrGetControl("picture","image"..tostring(context:inc()),context.x,context.y,0,0)
    tolua.cast(img,"ui::CPicture")
    img:EnableAutoResize(1)
    context.x=context.x+img:GetWidth()
    context.carryheight=math.max(context.carryheight,img:GetHeight())
    return frame
end
function actions.comment.fn(rootframe,frame,node,context)
    return frame
end
function actions.table.fn(rootframe,frame,node,context)
    local gbox=frame:CreateOrGetControl("groupbox","gbox"..tostring(content:inc(),context.x,context.y,0,0))
    tolua.cast(gbox,"ui::CGroupBox")
    gbox:EnableScrollBar(0)
    gbox:AutoSize(1)
    node.frame=gbox
    return gbox
end
function actions.table.after_fn(rootframe,previousframe,frame,node,context)
    --ここにリサイズ処理を入れる

    return gbox
end
function actions.td.fn(rootframe,frame,node,context)
    local gbox=frame:CreateOrGetControl("groupbox","gbox"..tostring(context:inc(),context.x,context.y,0,0))
    tolua.cast(gbox,"ui::CGroupBox")
    node.frame=gbox
    gbox:EnableScrollBar(0)
    gbox:AutoSize(1)
    return gbox
end
function actions.li.fn(rootframe,frame,node,context)
    local txt=frame:CreateOrGetControl("richtext","text"..tostring(context:inc()),context.x,context.y,0,0)
    tolua.cast(txt,"ui::CRichText")
    txt:EnableAutoResize(1)
    txt:SetText(context.font.." ･ "..node.content)

    context.x=context.x+txt:GetWidth()
    context.carryheight=math.max(context.carryheight,txt:GetHeight())
    return frame
end
function actions.ln.fn(rootframe,frame,node,context)
    local txt=frame:CreateOrGetControl("richtext","text"..tostring(context:inc()),context.x,context.y,0,0)
    tolua.cast(txt,"ui::CRichText")
    txt:EnableAutoResize(1)
    txt:SetText(context.font.." * "..node.content)

    context.x=context.x+txt:GetWidth()
    context.carryheight=math.max(context.carryheight,txt:GetHeight())
    return frame
end
function actions.a.fn(rootframe,frame,node,context)
    local gbox=frame:CreateOrGetControl("groupbox","gbox"..tostring(context:inc(),context.x,context.y,0,0))
    tolua.cast(gbox,"ui::CGroupBox")
    node.frame=gbox
    gbox:EnableScrollBar(0)
    gbox:AutoSize(1)
    return gbox
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
        font="{s16}{ol}",
    }
    local action=actions[node.name]
    local previousframe=frame
    frame=action.fn(rootframe,frame,node,context)
    
    for _,v in ipairs(node.child) do
        R.render(rootframe,frame,v,context)
    end
    if(action.after_fn)then
        action.after_fn(rootframe,previousframe,frame,node,context)
    end
    context.font="{s16}{ol}"
    return frame
end

--EOF
WIKIHELP_RENDERER=R

