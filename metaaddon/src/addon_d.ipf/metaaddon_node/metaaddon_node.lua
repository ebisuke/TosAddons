--metaaddon_node
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

local currentNode=nil

function METAADDON_NODE_ON_INIT(addon, frame)
    g.fn.trycatch{
        try = function()
            frame = ui.GetFrame("metaaddon_node")
            g.frm.node={
                ["addon"] = addon,
                ["frame"] = frame
            }
            local btn=frame:CreateOrGetControl("button","buttonok",0,0,120,40)
            btn:SetText("OK")
            btn:SetGravity(ui.RIGHT,ui.BOTTOM)
            btn:SetOffset(20,20)
            btn:SetEventScript(ui.LBUTTONUP, "METAADDON_NODE_ON_OK")
           local gbox=ui.GetFrame("metaaddon_node"):GetChildRecursively("gbox") 

        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end

function METAADDON_NODE_SET(node)
    local  frame = ui.GetFrame("metaaddon_node")
    local gbox=ui.GetFrame("metaaddon_node"):GetChildRecursively("gbox") 
    gbox:RemoveAllChild()
    currentNode=node
    if(node:createEditor(g.document.active,ui.GetFrame("metaaddon_node"),gbox)==false) then
        ui.GetFrame("metaaddon_node"):ShowWindow(0)
        --ui.MsgBox("No confugration editor for this node")
    end

end
function METAADDON_NODE_GETNODE()
    return currentNode
end

function METAADDON_NODE_GETGBOX()
    local frame = ui.GetFrame("metaaddon_node")
    local gbox=ui.GetFrame("metaaddon_node"):GetChildRecursively("gbox")
    return gbox
end

function METAADDON_NODE_ON_OK()
    local  frame = ui.GetFrame("metaaddon_node")
    local gbox=ui.GetFrame("metaaddon_node"):GetChildRecursively("gbox") 
    if(currentNode:confirmEditor(g.document.active,ui.GetFrame("metaaddon_node"),gbox)==false) then
     
        ui.MsgBox("Invalid configuration")
        return
    end

    ui.GetFrame("metaaddon_node"):ShowWindow(0)
    METAADDON_EDITOR_RENDER()
end