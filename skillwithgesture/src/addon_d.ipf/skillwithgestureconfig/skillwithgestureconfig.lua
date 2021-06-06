-- SWG Config
local addonName = "SKILLWITHGESTURE"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
local framename = "skillwithgestureconfig"
g.limit = 30
g.confslots = g.confslots or {}
function SKILLWITHGESTURECONFIG_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
     
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLWITHGESTURECONFIG_SHOW()
    local frame = ui.GetFrame(framename)
    frame:ShowWindow(1)
    SKILLWITHGESTURECONFIG_INIT()
end
function SKILLWITHGESTURECONFIG_CLOSE()
    local frame = ui.GetFrame(framename)
    frame:ShowWindow(0)
end
function SKILLWITHGESTURECONFIG_INIT()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(framename)
            frame:Resize(250, 600)
            local gbox = frame:CreateOrGetControl("groupbox", "gbox", 0, 100, frame:GetWidth(), frame:GetHeight() - 120)
            g.confslots = {}
            for i = 1, g.limit do
                local size = 80

                local slotskill = gbox:CreateOrGetControl("slot", "slotskill" .. i, 20, size * (i - 1), size, size)
                local slotgesture =
                    gbox:CreateOrGetControl("slot", "slotgesture" .. i, 20 + size + 10, size * (i - 1), size, size)
                AUTO_CAST(slotskill)
                AUTO_CAST(slotgesture)
                slotskill:SetSkinName("slot")
                slotgesture:SetSkinName("slot")
                g.confslots[i] = {
                    skill = slotskill,
                    gesture = slotgesture
                }
                slotskill:EnableDrop(1)
                slotgesture:EnableDrop(1)
                slotskill:SetEventScript(ui.DROP, "SKILLWITHGESTURECONFIG_ONDROP_SKILL")
                slotgesture:SetEventScript(ui.DROP, "SKILLWITHGESTURECONFIG_ONDROP_GESTURE")
                slotskill:SetEventScript(ui.RBUTTONUP, "SKILLWITHGESTURECONFIG_ONCLEAR_SKILL")
                slotgesture:SetEventScript(ui.RBUTTONUP, "SKILLWITHGESTURECONFIG_ONCLEAR_GESTURE")
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLWITHGESTURECONFIG_ONDROP_SKILL(frame, slot, argStr, argNum)
    EBI_try_catch {
        try = function()
            local liftIcon = ui.GetLiftIcon()
            local liftParent = liftIcon:GetParent()
            local iconInfo = liftIcon:GetInfo()
            local cat = iconInfo:GetCategory()

            if cat == "Skill" then
                local skill = session.GetSkillByGuid(iconInfo:GetIESID())
                AUTO_CAST(slot)
                local icon = CreateIcon(slot)
                slot:SetUserValue("clsid", iconInfo.type)
                local imageName = "icon_" .. GetClassString("Skill", iconInfo.type, "Icon")
                icon:Set(imageName, cat, iconInfo.type, 0, iconInfo.type)
                icon:SetTooltipNumArg(type)
                icon:SetTooltipStrArg("quickslot")
                icon:SetTooltipIESID(iconInfo:GetIESID())
            end
            SKILLWITHGESTURECONFIG_SAVETOSTRUCTURE()
            SKILLWITHGESTURE_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLWITHGESTURECONFIG_ONDROP_GESTURE(frame, slot, argStr, argNum)
    EBI_try_catch {
        try = function()
            local liftIcon = ui.GetLiftIcon()
            local liftParent = liftIcon:GetParent()

            local iconInfo = liftIcon:GetInfo()
            local FromFrame = liftIcon:GetTopParentFrame()
            local toFrame = frame:GetTopParentFrame()

           
            local iconInfo = liftIcon:GetInfo()
            local poseID = liftIcon:GetUserIValue("POSEID")
            if poseID==nil or poseID==0  then
                poseID=liftParent:GetUserIValue("clsid")
            end
            local cls = GetClassByType("Pose", poseID) 
            if cls ~= nil then
                local icon = CreateIcon(slot)
                AUTO_CAST(icon)
                icon:SetImage(cls.Icon)
                icon:SetColorTone("FFFFFFFF")
                
                slot:SetUserValue("clsid", poseID)
            end
        
            SKILLWITHGESTURECONFIG_SAVETOSTRUCTURE()
            SKILLWITHGESTURE_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLWITHGESTURECONFIG_ONCLEAR_SKILL(frame, slot, argStr, argNum)
    AUTO_CAST(slot)
    slot:SetIcon(nil)
    slot:SetUserValue("clsid", nil)
    SKILLWITHGESTURECONFIG_SAVETOSTRUCTURE()
    SKILLWITHGESTURE_SAVE_SETTINGS()
end
function SKILLWITHGESTURECONFIG_ONCLEAR_GESTURE(frame, slot, argStr, argNum)
    AUTO_CAST(slot)
    slot:SetIcon(nil)
    slot:SetUserValue("clsid", nil)
    SKILLWITHGESTURECONFIG_SAVETOSTRUCTURE()
    SKILLWITHGESTURE_SAVE_SETTINGS()
end

function SKILLWITHGESTURECONFIG_SAVETOSTRUCTURE()
    EBI_try_catch {
        try = function()
            g.personalsettings.config = {}
            for k, v in ipairs(g.confslots) do
                g.personalsettings.config[k] = {
                    skill = v.skill:GetUserIValue("clsid"),
                    gesture = v.gesture:GetUserIValue("clsid")
                }
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLWITHGESTURECONFIG_LOADFROMSTRUCTURE()
    EBI_try_catch {
        try = function()
            g.personalsettings.config=g.personalsettings.config or {}
            for k, v in ipairs(g.confslots) do
                local conf=g.personalsettings.config[k] or {}
                if conf then
                    if conf.skill then
                        local skill=session.GetSkill(conf.skill)
                        if skill then
                            local slot=v.skill
                            AUTO_CAST(slot)
                            local icon = CreateIcon(slot)
                            slot:SetUserValue("clsid", conf.skill)
                            local imageName = "icon_" .. GetClassString("Skill", conf.skill, "Icon")
                            icon:Set(imageName, cat, conf.skill, 0, conf.skill)
                            icon:SetTooltipNumArg(type)
                            icon:SetTooltipStrArg("quickslot")
                            icon:SetTooltipIESID(skill:GetIESID())
                        end
                    else
                        v.skill:SetIcon(nil)
                        v.skill:SetUserValue("clsid",nil)
                    end
                    if conf.gesture then
                        local slot=v.gesture
                        AUTO_CAST(slot)
                        local icon = CreateIcon(slot)
                        slot:SetUserValue("clsid", conf.gesture)
                               
                        local cls = GetClassByType("Pose", conf.gesture)
                        if cls ~= nil then
                            local icon = CreateIcon(slot)
                            AUTO_CAST(icon)
                            icon:SetImage(cls.Icon)
                            icon:SetColorTone("FFFFFFFF")
                            slot:SetUserValue("clsid", conf.gesture)
                        end
                    else
                        v.gesture:SetIcon(nil)
                        v.gesture:SetUserValue("clsid",nil)
                    end
                end
            end
        end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
