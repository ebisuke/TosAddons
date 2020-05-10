-- YAI Config
local addonName = "YAACCOUNTINVENTORY"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')


local l={}
l.framename="yaiconfig"
local c
local function IsJpn()
	if (option.GetCurrentCountry() == "Japanese") then
        return true
    else
        return false
    end
end
local function L_(str)
	if(g.notrans)then
		return str
	end
	if(IsJpn() and YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str])then
		return YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].jpn
	elseif (YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str] and YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].eng)then
		return YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].eng
	else
		return str
	end		
end

--ライブラリ読み込み

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end

local function DBGOUT(msg)
    
    EBI_try_catch{
        try=function()
            if(g.debug==true)then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd=io.open (g.logpath,"a")
                fd:write(msg.."\n")
                fd:flush()
                fd:close()
                
            end
        end,
        catch=function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try=function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch=function(error)
        end
    }

end
function YAICONFIG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            l.frame=frame

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function YAIC_INIT()
    EBI_try_catch{
        try = function()
            c=g.constants
            local frame=ui.GetFrame(l.framename)
            frame:Resize(800,600)
            local gbox=frame:CreateOrGetControl("groupbox","gboxkeybinds",5,300,frame:GetWidth()-10,frame:GetHeight()-350)
            AUTO_CAST(gbox)
            gbox:EnableScrollBar(1)
            YAIC_GENERATE_KEYBINDCONTROLS(gbox)
            local label=frame:CreateOrGetControl("richtext","labelkeybind",20,300-30,100,30)
            label:SetText("{ol}{s16}"..L_("Keybinds"))
            local label=frame:CreateOrGetControl("richtext","labelinterval",20,100,80,30)
            label:SetText("{ol}"..L_("Interval"))
            local edit=frame:CreateOrGetControl("edit","editinterval",200,100,80,30)
            AUTO_CAST(edit)
            edit:SetText(tostring(g.settings.speed))
            edit:SetSkinName("systemmenu_vertical")
            edit:SetFontName("white_16_ol")
            local label=frame:CreateOrGetControl("richtext","labellimit",20,140,80,30)
            label:SetText("{ol}"..L_("Stack limit"))
            local edit=frame:CreateOrGetControl("edit","editlimit",200,140,80,30)
            AUTO_CAST(edit)
            edit:SetText(tostring(g.settings.stacklimit))
            edit:SetSkinName("systemmenu_vertical")
            edit:SetFontName("white_16_ol")
            local chkdrag = frame:CreateOrGetControl("checkbox", "chkdrag", 20, 180, 80, 30)
            AUTO_CAST(chkdrag)
            chkdrag:SetText("{ol}"..L_("Enable Drag"))
            if(g.settings.enabledrag~=false)then
                chkdrag:SetCheck(1)
            else
                chkdrag:SetCheck(0)
            end
            local button=frame:CreateOrGetControl("button","btnadd",200,300-50,80,35)
            AUTO_CAST(button)
            button:SetText("{ol}"..L_("Add"))
            button:SetEventScript(ui.LBUTTONUP,"YAIC_ADD")
            local button=frame:CreateOrGetControl("button","btnsave",frame:GetWidth()-100,frame:GetHeight()-40,80,30)
            AUTO_CAST(button)
            button:SetText("{ol}"..L_("Save&Close"))
            button:SetEventScript(ui.LBUTTONUP,"YAIC_SAVE")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAIC_OPEN()
    YAIC_INIT()
end
function YAIC_SAVE()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame(l.framename)
            local edit=frame:GetChild("editinterval")
            g.settings.speed=math.max(0.0,math.min(10.0,tonumber(edit:GetText()) or 1.0))
            local edit=frame:GetChild("editlimit")
            g.settings.stacklimit=math.max(1,math.min(99999,tonumber(edit:GetText()) or 50))
            local chk=frame:GetChild("chkdrag")
            AUTO_CAST(chk)
            g.settings.enabledrag=chk:IsChecked()==1

            -- read keybind
            local gbox=frame:GetChild("gboxkeybinds")
            AUTO_CAST(gbox)
            local idx=1
            g.settings.keybinds={}
            while true do
                local kb={trigger="",modifiers={},action="",value=0}
                local gbkeybind=gbox:GetChild("gboxkeybind"..tostring(idx))
                if(gbkeybind==nil)then
                    break
                end
                local combo=gbkeybind:GetChild("combokey")
                AUTO_CAST(combo)
                kb.trigger=combo:GetSelItemCaption()
                local combo=gbkeybind:GetChild("combomodifier")
                AUTO_CAST(combo)
                local selitem=combo:GetSelItemCaption()
                kb.modifiers=StringSplit(selitem," ")
                local combo=gbkeybind:GetChild("comboaction")
                AUTO_CAST(combo)
                kb.action=c.action[combo:GetSelItemIndex()+1].name
                local edit=gbkeybind:GetChild("editvalue")
                AUTO_CAST(edit)
                kb.value=tonumber(edit:GetText())


                g.settings.keybinds[idx]=kb
                idx=idx+1
            end

            YAI_SAVE_SETTINGS()
            YAICONFIG_CLOSE()
            imcAddOn.BroadMsg("YAI_UPDATED_CONFIG","")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAICONFIG_CLOSE()
    local frame=ui.GetFrame(l.framename)
    frame:ShowWindow(0)
end
function YAIC_GENERATE_KEYBINDCONTROLS(parent)
    EBI_try_catch{
        try = function()
            local offset=0
            if(parent==nil)then
                local frame=ui.GetFrame(l.framename)
                parent=frame:GetChild("gboxkeybinds")              
                AUTO_CAST(parent)
            end
            parent:RemoveAllChild()
            for k,v in ipairs(g.settings.keybinds) do
                offset=YAIC_ADD_KEYBINDCONTROL(parent,k,v,offset)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAIC_ADD()
    local kb={trigger="L",modifiers={},action="NONE",value=0}
    local idx=1

    local parent

    local frame=ui.GetFrame(l.framename)
    parent=frame:GetChild("gboxkeybinds")              
    AUTO_CAST(parent)
    
    while true do
        local gbkeybind=parent:GetChild("gboxkeybind"..tostring(idx))
        if(gbkeybind==nil)then
            break
        end

        idx=idx+1
    end

    YAIC_ADD_KEYBINDCONTROL(parent,idx,kb,(idx-1)*80)
end
function YAIC_ADD_KEYBINDCONTROL(parent,index,keybind,offsety)
    return EBI_try_catch{
        try = function()
            local h=80
            local gbox=parent:CreateOrGetControl("groupbox","gboxkeybind"..tostring(index),5,offsety,parent:GetWidth()-30,h)
            AUTO_CAST(gbox)
            gbox:SetSkinName("test_frame_midle")
            gbox:EnableHittestGroupBox(false)
            gbox:EnableScrollBar(0)
            
            local label=gbox:CreateOrGetControl("richtext","labelkey",10,5,80,25)
            label:SetText("{ol}"..L_("Trigger:"))
            local combokey=gbox:CreateOrGetControl("droplist","combokey",10,30,80,25)
            AUTO_CAST(combokey)
            
            combokey:SetSkinName("droplist_normal")
            combokey:SetFontName("white_16_ol")
            combokey:AddItem(0,"L")
            combokey:AddItem(1,"R")
            if(keybind.trigger=="L")then
                combokey:SelectItem(0)
            elseif (keybind.trigger=="R")then
                combokey:SelectItem(1)
            end
            combokey:Invalidate()
            --generate modifier
            local label=gbox:CreateOrGetControl("richtext","labelmodifier",110,5,180,25)
            label:SetText("{ol}"..L_("Modifier Key:"))
            
            local combomodifier=gbox:CreateOrGetControl("droplist","combomodifier",110,30,180,25)
            AUTO_CAST(combomodifier)
            local mods=""
            for _,v in ipairs(keybind.modifiers) do
                mods=mods..v.." "
            end
            combomodifier:SetSkinName("droplist_normal")
            combomodifier:SetFontName("white_16_ol")
            g.combomodifier={}
            for i=0,7 do
                local text=""
                if (i&1)~=0 then
                    text=text.."LSHIFT "
                end
                if (i&2)~=0 then
                    text=text.."LCTRL "
                end
                if (i&4)~=0 then
                    text=text.."LALT "
                end
                text=string.gsub(text,"*%s$","")
                combomodifier:AddItem(i,text)
                if(text==mods)then
                    combomodifier:SelectItem(i)
                end
                g.combomodifier[#g.combomodifier+1] = text
            end

            --actions 
            local label=gbox:CreateOrGetControl("richtext","labelaction",310,5,80,25)
            label:SetText("{ol}"..L_("Action:"))
            local comboaction=gbox:CreateOrGetControl("droplist","comboaction",310,30,280,25)
            AUTO_CAST(comboaction)
            comboaction:SetSkinName("droplist_normal")
            comboaction:SetFontName("white_16_ol")
            for k,v in ipairs(c.action) do
                

                comboaction:AddItem(k-1,v.text)
                if(keybind.action==v.name)then
                    comboaction:SelectItem(k-1)
                end
            end

            --value 
            local label=gbox:CreateOrGetControl("richtext","labelvalue",610,5,80,25)
            label:SetText("{ol}"..L_("VALUE:"))
            local edit=gbox:CreateOrGetControl("edit","editvalue",610,30,80,25)
            AUTO_CAST(edit)
            edit:SetSkinName("systemmenu_vertical")
            edit:SetFontName("white_16_ol")
            edit:SetText(tostring(keybind.value))
            
            --Delete
            local button=gbox:CreateOrGetControl("button","btndelete",gbox:GetWidth()-100,55,80,25)
            button:SetText("{ol}"..L_("Delete"))
            button:SetEventScript(ui.LBUTTONUP,"YAIC_DELETE_KEYBIND")
            button:SetEventScriptArgNumber(ui.LBUTTONUP,index)
            
            return offsety+h
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAIC_DELETE_KEYBIND(frame,ctrl,argstr,argnum)
    EBI_try_catch{
        try = function()
            table.remove(g.settings.keybinds,argnum)
            YAIC_GENERATE_KEYBINDCONTROLS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

