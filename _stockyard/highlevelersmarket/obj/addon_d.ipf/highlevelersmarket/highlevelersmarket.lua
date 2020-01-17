_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['highlevelersmarket'] = _G['ADDONS']['DARKENCOOLDOWN'] or {};
local g = _G['ADDONS']['highlevelersmarket'];
local acutil = require('acutil')

g.user = nil;
g.setting = {}
g.settingPath = '../addons/highlevelersmarket/'
g.loaded=g.loaded or 0

HIGHLEVELERSMARKET_LEVELLIST={1,15,40,75,120,170,220,315,350,360}
HIGHLEVELERSMARKET_LEVELLIST_ACCESORY={1,15,40,75,120,170,220}

function HIGHLEVELERSMARKET_ON_INIT(addon,frame)

    CHAT_SYSTEM('on init highlevelersmarket')
    if (OLD_DRAW_DETAIL_CATEGORY==nil and HIGHLEVELERSMARKET_DRAW_DETAIL_CATEGORY_JUMPER~=DRAW_DETAIL_CATEGORY)then
        OLD_DRAW_DETAIL_CATEGORY=DRAW_DETAIL_CATEGORY
        DRAW_DETAIL_CATEGORY=HIGHLEVELERSMARKET_DRAW_DETAIL_CATEGORY_JUMPER
    end
    g.loaded=1
end

function HIGHLEVELERSMARKET_DRAW_DETAIL_CATEGORY_JUMPER(frame, selectedCtrlset, subCategoryList, forceOpen)
    return HIGHLEVELERSMARKET_DRAW_DETAIL_CATEGORY(frame,selectedCtrlset,subCategoryList,forceOpen)
end

function HIGHLEVELERSMARKET_DRAW_DETAIL_CATEGORY(frame, selectedCtrlset, subCategoryList, forceOpen)
    local parentCategory = selectedCtrlset:GetUserValue('CATEGORY');	
    local ypos = OLD_DRAW_DETAIL_CATEGORY(frame,selectedCtrlset,subCategoryList,forceOpen)
    if parentCategory ~= 'Weapon' and parentCategory ~= 'Accessory'and  parentCategory ~= 'Armor' and parentCategory ~= 'Recipe' and parentCategory ~= 'OPTMisc' then
        return ypos
    end

    local chks={}
    if(parentCategory == 'Accessory')then
        chks={
            gradeCheck_1=0,
            gradeCheck_2=0,
            gradeCheck_3=1,
            gradeCheck_4=1,
            gradeCheck_5=1
        }
    else
        chks={
            gradeCheck_1=0,
            gradeCheck_2=0,
            gradeCheck_3=0,
            gradeCheck_4=1,
            gradeCheck_5=1
        }
    end

    
    for k,v in pairs(chks) do
        local chkraw=GET_CHILD_RECURSIVELY(frame,k)
        if(chkraw~=nil)then
            local chk=tolua.cast(chkraw,"ui::CCheckBox")
            chk:SetCheck(v)
        end
    end

    local nearestlv=1
    local pclv=GETMYPCLEVEL();
    local searchlv={}
    if(parentCategory == 'Accessory')then
        searchlv=HIGHLEVELERSMARKET_LEVELLIST_ACCESORY
    else
        searchlv=HIGHLEVELERSMARKET_LEVELLIST
    end
    for _,v in ipairs(searchlv) do
        if(pclv < v)then
            break
        end
        nearestlv=v
    end

    local minEdit = GET_CHILD_RECURSIVELY(frame, 'minEdit');

	minEdit:SetText(tostring(nearestlv));

    return ypos

end