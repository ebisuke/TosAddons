-- detailedgrimoirestatus.lua
--アドオン名（大文字）
local addonName = "DETAILEDGRIMOIRESTATUS"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "detailedgrimoirestatus"
g.debug = false
CHAT_SYSTEM("[DGS]loaded")
local acutil = require("acutil")
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

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            end
        end,
        catch = function(error)
        end
    }
end
local function ERROUT(msg)
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function DETAILEDGRIMOIRESTATUS_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPEXTENDER_GETCID()))
            frame:ShowWindow(0)

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end

            acutil.setupHook(DETAILEDGRIMOIRESTATUS_SET_CARD_STATE, "SET_CARD_STATE")
            acutil.setupHook(DETAILEDGRIMOIRESTATUS_GRIMOIRE_STATE_TEXT_RESET, "GRIMOIRE_STATE_TEXT_RESET")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function DETAILEDGRIMOIRESTATUS_GRIMOIRE_STATE_TEXT_RESET(descriptGbox)
    EBI_try_catch {
        try = function()
            GRIMOIRE_STATE_TEXT_RESET_OLD(descriptGbox)
            local y = 430
            descriptGbox:Resize(descriptGbox:GetWidth(), 435)
            local create_stat_fn = function(name, description, value)
                local desc_text =
                    descriptGbox:CreateOrGetControl("richtext", "desc_" .. name, 10, y, descriptGbox:GetWidth(), 20)
                local value_text =
                    descriptGbox:CreateOrGetControl("richtext", "value_" .. name, 190, y, descriptGbox:GetWidth()-200, 20)
                AUTO_CAST(value_text)
                AUTO_CAST(desc_text)
                desc_text:SetText(description)

                desc_text:SetFontName("yellow_18_ol")
                value_text:SetTextFixWidth(1)
                value_text:SetFormat("{#FFFFFF}{ol}%s")
                
                value_text:SetText("{#FFFFFF}{ol}".. value)

                value_text:SetTextAlign("right", "center")
                value_text:SetFontName("brown_18")

                y = y + 30
            end
            create_stat_fn("hr", ScpArgMsg("HR"), 0)
            create_stat_fn("dr", ScpArgMsg("DR"), 0)
            create_stat_fn("blk_break", ScpArgMsg("BLK_BREAK"),0)
            create_stat_fn("blk", ScpArgMsg("BLK"), 0)
            create_stat_fn("crthr", ScpArgMsg("CRTHR"),0)
            create_stat_fn("crtdr", ScpArgMsg("CRTDR"),0)

            create_stat_fn("crtpatk", ScpArgMsg("CRTATK"), 0)
            create_stat_fn("crtmatk", ScpArgMsg("CRTMATK"), 0)
            create_stat_fn("crtdef", ScpArgMsg("CRTDEF"), 0)
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function DETAILEDGRIMOIRESTATUS_SET_CARD_STATE(frame, bosscardcls, i)
    EBI_try_catch {
        try = function()
            SET_CARD_STATE_OLD(frame, bosscardcls, i)
            local grimoireGbox = GET_CHILD(frame, "grimoireGbox", "ui::CGroupBox")
            if nil == grimoireGbox then
                return
            end
            local descriptGbox = GET_CHILD(grimoireGbox, "descriptGbox", "ui::CGroupBox")
            if nil == descriptGbox then
                return
            end

            if 1 == i then -- 메인카드
                local gbox = GET_CHILD(descriptGbox, "my_card", "ui::CRichText")
                if nil ~= gbox then
                    gbox:SetTextByKey("actorcard", bosscardcls.Name)
                end
            else
                local gbox = GET_CHILD(descriptGbox, "my_assist_card", "ui::CRichText")
                if nil ~= gbox then
                    gbox:SetTextByKey("actorassistcard", bosscardcls.Name)
                end

                return
            end

            local skl = session.GetSkillByName("Sorcerer_Summoning")
            if nil == skl then
                return
            end

            local bossMonID = bosscardcls.NumberArg1
            local monCls = GetClassByType("Monster", bossMonID)
            if nil == monCls then
                return
            end

            -- 가상몹을 생성합시다.
            local tempObj = CreateGCIES("Monster", monCls.ClassName)
            if nil == tempObj then
                return
            end

            CLIENT_SORCERER_SUMMONING_MON(tempObj, GetMyPCObject(), GetIES(skl:GetObject()), bosscardcls)
            local y = 430
            descriptGbox:Resize(descriptGbox:GetWidth(), 435)
            local create_stat_fn = function(name, description, value)
                local desc_text =
                    descriptGbox:CreateOrGetControl("richtext", "desc_" .. name, 10, y, descriptGbox:GetWidth(), 20)
                local value_text =
                    descriptGbox:CreateOrGetControl("richtext", "value_" .. name, 190, y, descriptGbox:GetWidth()-200, 20)
                AUTO_CAST(value_text)
                AUTO_CAST(desc_text)
                desc_text:SetText(description)

                desc_text:SetFontName("yellow_18_ol")
                value_text:SetTextFixWidth(1)
                value_text:SetFormat("{#FFFFFF}{ol}%s")
                
                value_text:SetText("{#FFFFFF}{ol}".. value)

                value_text:SetTextAlign("right", "center")
                value_text:SetFontName("brown_18")

                y = y + 30
            end
            create_stat_fn("hr", ScpArgMsg("HR"), SCR_Get_MON_HR(tempObj))
            create_stat_fn("dr", ScpArgMsg("DR"), SCR_Get_MON_DR(tempObj))
            create_stat_fn("blk_break", ScpArgMsg("BLK_BREAK"), SCR_Get_MON_BLK_BREAK(tempObj))
            create_stat_fn("blk", ScpArgMsg("BLK"), SCR_Get_MON_BLK(tempObj))
            create_stat_fn("crthr", ScpArgMsg("CRTHR"), SCR_Get_MON_CRTHR(tempObj))
            create_stat_fn("crtdr", ScpArgMsg("CRTDR"), SCR_Get_MON_CRTDR(tempObj))

            create_stat_fn("crtpatk", ScpArgMsg("CRTATK"), SCR_Get_MON_CRTATK(tempObj))
            create_stat_fn("crtmatk", ScpArgMsg("CRTMATK"), SCR_Get_MON_CRTMATK(tempObj))
            create_stat_fn("crtdef", ScpArgMsg("CRTDEF"), SCR_Get_MON_CRTDEF(tempObj))
            -- local richText
            -- richText = GET_CHILD(descriptGbox,'my_hr',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_MON_HR(tempObj));
            -- richText = GET_CHILD(descriptGbox,'my_dr',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_MON_DR(tempObj));
            -- richText = GET_CHILD(descriptGbox,'my_blk_break',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_Get_MON_BLK_BREAK(tempObj));
            -- richText = GET_CHILD(descriptGbox,'my_blk',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_Get_MON_BLK(tempObj));

            -- richText = GET_CHILD(descriptGbox,'my_crthr',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_Get_MON_CRTHR(tempObj));

            -- richText = GET_CHILD(descriptGbox,'my_crtdr',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_Get_MON_CRTHR(tempObj));

            -- richText = GET_CHILD(descriptGbox,'my_crt_matk',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_Get_MON_CRTMATK(tempObj));
            -- richText = GET_CHILD(descriptGbox,'my_crt_patk',"ui::CRichText")
            -- richText:SetTextByKey("value", SCR_Get_MON_CRTPATK(tempObj));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
