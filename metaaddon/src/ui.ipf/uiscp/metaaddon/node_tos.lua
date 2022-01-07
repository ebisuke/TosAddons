--metaaddon_node_generic
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.cls = g.cls or {}

-- in1 skill
g.cls.MAUseNode = function(pos, size)
    local self=
    {
        _className="MAUseNode",
        initImpl = function(self)

            self:addInlet(g.cls.MAUsableGate("use", self):init())
        end,
        isSkill=function(self)
            if self:getInlets()[1]:hasLeastOneStream() then
                return g.fn.tableFirst(self:getInlets()[1]:getStreams()):instanceOf(g.cls.MASkillStream())
            else
                return false 
            end
            
        end,
        isItem=function(self)
            if self:getInlets()[1]:hasLeastOneStream() then
                return g.fn.tableFirst(self:getInlets()[1]:getStreams()):instanceOf(g.cls.MAItemStream())
            else
                return false 
            end
            
        end,
        compile=function(self,addonlet)
            if self:isSkill() then
                return [[
                    local skl = session.GetSkill(args[1]);
                    if skl then
                        control.Skill(args[1]);
                    end

                ]]
            elseif self:isItem() then
                return [[
                    local item=session.GetInvItemByType(args[1])
                    if item then
                        INV_ICON_USE(item)
                    end
                ]]
            else
                return [[
                    local skl = session.GetSkill(args[1]);
                    if skl then
                        control.Skill(args[1]);
                        return
                    end
                    local item=session.GetInvItemByType(args[1])
                    if item then
                        INV_ICON_USE(item)
                        return
                    end
                ]]
            end
            
        end
    }
    local obj = g.fn.inherit(self, g.cls.MANode("Use", pos, size))

    return obj
end
