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

}
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

local function acq(context)
    local idx=context.controlindex
    context.controlindex=context.controlindex+1
    return tostring(idx)
end
local function pos(context)
    context.pos=context.pos or {}
    local posa=peek(context.pos) or {x=0,y=0}
    return posa
end
local function genfont(context)
    print(context.fontcolor)
    return context.fontbase..context.fontbold..context.fonteffect..context.fontcolor..context.fontsize
end
function A.example.enter_fn(rootframe,frame,node,context)
    return frame,true
end
function A.example.leave_fn(rootframe,frame,node,context)
    return frame
end
function A.text.enter_fn(rootframe,frame,node,context)
    local ctrl=frame:CreateOrGetControl("richtext","text"..acq(context),pos(context).x,pos(context).y,0,0)
    ctrl:SetText("{ol}"..node.content)
    ctrl:EnableHitTest(0)
    poke(context.pos,
    {x=0,y=peek(context.pos).y+ctrl:GetHeight()})
    WIKIHELP_DBGOUT(node.content)
    return frame,false
end



function R.render(rootframe,node)
    local context
    context=context or {
        pos={{x=0,y=0}},
        fontname={},
        pagename=node.attrib.pagename,
        controlindex=1
    }
   
    R.renderimpl(rootframe,rootframe,node,context)
end
function R.renderimpl(rootframe,frame,node,context)

    local act=A[node.name]

    
    local result=true
    if(act and act.enter_fn)then
       
        frame,result=act.enter_fn(rootframe,frame,node,context)
        
    end
    if(node.child and result)then
        for _,v in ipairs(node.child) do
            frame=R.renderimpl(rootframe,frame,v,context)
        end
    end
    if(act and act.leave_fn)then
       
        frame=act.leave_fn(rootframe,frame,node,context)
        
    end
    return frame
end

--EOF
WIKIHELP_MEDIAWIKIRENDERER=R

