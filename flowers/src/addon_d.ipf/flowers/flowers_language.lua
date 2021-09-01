--flowers! func
local addonName = "flowers"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.L=function(str)
    local s=g.languagetable[str]
    if s then
        return s.jp
    else
        return str
    end
end

g.languagetable={
    [""]={en="",jp=""},
    ["Add"]={en="Add",jp="追加"},
    ["Add Action"]={en="Add Action",jp="動作を追加"},
    ["Add Variable"]={en="Add Variable",jp="変数を追加"},
    ["Add Condition"]={en="Add Condition",jp="条件を追加"},
    ["Variables"]={en="Variables",jp="変数"},
    ["Actions"]={en="Actions",jp="動作"},
    ["Conditions"]={en="Conditions",jp="条件"},
    ["Flower/Petal Config"]={en="Flower/Petal Config",jp="Flower/Petal 設定"},
    ["Enter Flower Name"]={en="Enter Flower Name",jp="Flower名を入力"},
    ["OK"]={en="OK",jp="OK"},
    ["Cancel"]={en="Cancel",jp="キャンセル"},
    ["LHS"]={en="LHS",jp="左辺値"},
    ["RHS"]={en="RHS",jp="右辺値"},
    ["Comparator"]={en="Comparator",jp="比較演算子"},
    
}
