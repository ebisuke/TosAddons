-- shared_item_relic_option.lua

-- 길티네의 면류관
function get_tooltip_Relic_Guilty_arg1()
    return 10, 'ALLSTAT_BM', 1, 'ValueUp'
end

-- 시안 젬 - 통치자의 검
function get_tooltip_SOVEREIGN_SWORD_arg1()
    return 3000, 'RELIC_SKILLFACTOR', 1, 'Percent'
end

function get_tooltip_SOVEREIGN_SWORD_arg2()
    return 22.5, 'DAMAGERATE_DEBUFF', 1, 'PercentUp'
end

-- 시안 젬 - 수확의 낫
function get_tooltip_HARVEST_SCYTHE_arg1()
    return 15000, 'RELIC_SKILLFACTOR', 1, 'Percent'
end

function get_tooltip_HARVEST_SCYTHE_arg2()
    return 1500, 'HP_DRAIN', 1, 'Value'
end

function get_tooltip_HARVEST_SCYTHE_arg3()
    return 50, 'SP_DRAIN', 1, 'Value'
end

-- 시안 젬 - 거인의 마검
function get_tooltip_GIANT_EVILSWORD_arg1()
    return 15000, 'RELIC_SKILLFACTOR', 1, 'Percent'
end

function get_tooltip_GIANT_EVILSWORD_arg2()
    return 400, 'ADD_ATK_SKILLFACTOR', 1, 'Percent'
end

-- 시안 젬 - 혜성의 팔찌
function get_tooltip_OLDTREE_BRACELET_arg1()
    return 10000, 'RELIC_SKILLFACTOR', 1, 'Percent'
end

function get_tooltip_OLDTREE_BRACELET_arg2()
    return 20000, 'HP_DRAIN', 1, 'Value'
end

-- 시안 젬 - 통섭의 그릇
function get_tooltip_CONSILIENCE_PLATE_arg1()
    return 2500, 'DECREASE_ATK', 1, 'Value'
end

-- 시안 젬 - 징조의 날붙이
function get_tooltip_OMEN_EDGEWISE_arg1()
    return 3000, 'RELIC_SKILLFACTOR', 1, 'Percent'
end

function get_tooltip_OMEN_EDGEWISE_arg2()
    return 15, 'DAMAGERATE_DEBUFF', 1, 'PercentUp'
end

-------- 마젠타 젬 -------------------------------------------

-- 마젠타 젬 - 결단
function get_tooltip_DECISION_arg1()
    return 3000, 'PATK_BM', 1, 'ValueUp'
end

function get_tooltip_DECISION_arg2()
    return 1.5, 'PATK_FINALDAMAGE', 1, 'PercentUp'
end

-- 마젠타 젬 - 필살
function get_tooltip_DEADLY_arg1()
    return 4000, 'PATK_BM', 1, 'ValueUp'
end

function get_tooltip_DEADLY_arg2()
    return 2, 'PATK_FINALDAMAGE', 1, 'PercentUp'
end

-- 마젠타 젬 - 증명
function get_tooltip_PROOF_arg1()
    return 3000, 'MATK_BM', 1, 'ValueUp'
end

function get_tooltip_PROOF_arg2()
    return 1.5, 'MATK_FINALDAMAGE', 1, 'PercentUp'
end

-- 마젠타 젬 - 경이
function get_tooltip_MARVELOUS_arg1()
    return 4000, 'MATK_BM', 1, 'ValueUp'
end

function get_tooltip_MARVELOUS_arg2()
    return 2, 'MATK_FINALDAMAGE', 1, 'PercentUp'
end

-- 마젠타 젬 - 무장
function get_tooltip_ARMED_arg1()
    return 9000, 'DEF_BM/MDEF_BM', 1, 'ValueUp'
end

function get_tooltip_ARMED_arg2()
    return 9000, 'MHP_BM', 1, 'ValueUp'
end

-- 마젠타 젬 - 위격
function get_tooltip_HYPOSTASIS_arg1()
    return 12000, 'DEF_BM/MDEF_BM', 1, 'ValueUp'
end

function get_tooltip_HYPOSTASIS_arg2()
    return 12000, 'MHP_BM', 1, 'ValueUp'
end

-- 마젠타 젬 - 약진 (기본 제공)
function get_tooltip_ADVANCE_arg1()
    return 1000, 'PATK_BM', 1, 'ValueUp'
end

function get_tooltip_ADVANCE_arg2()
	return 1000, 'MATK_BM', 1, 'ValueUp'
end

-------- 블랙 젬 -------------------------------------------

-- 블랙 젬 - 치유력
function get_tooltip_HEAL_PWR_BM_GEM_LEGEND_arg1()
    return 256, 'HEAL_PWR', 1, 'ValueUp'
end
function get_tooltip_HEAL_PWR_BM_GEM_GODDESS_arg1()
    return 360, 'HEAL_PWR', 1, 'ValueUp'
end

-- 블랙 젬 - HP회복력
function get_tooltip_RHP_GEM_LEGEND_arg1()
    return 252, 'RHP', 1, 'ValueUp'
end
function get_tooltip_RHP_GEM_GODDESS_arg1()
    return 326, 'RHP', 1, 'ValueUp'
end

-- 블랙 젬 - SP회복력
function get_tooltip_RSP_GEM_LEGEND_arg1()
    return 72, 'RSP', 1, 'ValueUp'
end
function get_tooltip_RSP_GEM_GODDESS_arg1()
    return 98, 'RSP', 1, 'ValueUp'
end

-- 블랙 젬 - 최대 SP
function get_tooltip_MSP_GEM_LEGEND_arg1()
    return 252, 'MSP', 1, 'ValueUp'
end
function get_tooltip_MSP_GEM_GODDESS_arg1()
    return 326, 'MSP', 1, 'ValueUp'
end

-- 블랙 젬 - 곤충형 대상 공격력
function get_tooltip_Klaida_Atk_GEM_LEGEND_arg1()
    return 762, 'Klaida_Atk', 1, 'ValueUp'
end
function get_tooltip_Klaida_Atk_GEM_GODDESS_arg1()
    return 992, 'Klaida_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 악마형 대상 공격력
function get_tooltip_Velnias_Atk_GEM_LEGEND_arg1()
    return 762, 'Velnias_Atk', 1, 'ValueUp'
end
function get_tooltip_Velnias_Atk_GEM_GODDESS_arg1()
    return 992, 'Velnias_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 야수형 대상 공격력
function get_tooltip_Widling_Atk_GEM_LEGEND_arg1()
    return 762, 'Widling_Atk', 1, 'ValueUp'
end
function get_tooltip_Widling_Atk_GEM_GODDESS_arg1()
    return 992, 'Widling_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 변이형 대상 공격력
function get_tooltip_Paramune_Atk_GEM_LEGEND_arg1()
    return 762, 'Paramune_Atk', 1, 'ValueUp'
end
function get_tooltip_Paramune_Atk_GEM_GODDESS_arg1()
    return 992, 'Paramune_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 식물형 대상 공격력
function get_tooltip_Forester_Atk_GEM_LEGEND_arg1()
    return 762, 'Forester_Atk', 1, 'ValueUp'
end
function get_tooltip_Forester_Atk_GEM_GODDESS_arg1()
    return 992, 'Forester_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 불 속성 마법 대미지
function get_tooltip_Magic_Fire_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Fire_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Fire_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Fire_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 얼음 속성 마법 대미지
function get_tooltip_Magic_Ice_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Ice_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Ice_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Ice_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 전기 속성 마법 대미지
function get_tooltip_Magic_Lightning_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Lightning_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Lightning_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Lightning_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 땅 속성 마법 대미지
function get_tooltip_Magic_Earth_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Earth_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Earth_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Earth_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 독 속성 마법 대미지
function get_tooltip_Magic_Poison_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Poison_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Poison_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Poison_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 어둠 속성 마법 대미지
function get_tooltip_Magic_Dark_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Dark_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Dark_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Dark_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 신성 속성 마법 대미지
function get_tooltip_Magic_Holy_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Holy_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Holy_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Holy_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 염 속성 마법 대미지
function get_tooltip_Magic_Soul_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Soul_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Soul_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Soul_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 무 속성 마법 대미지
function get_tooltip_Magic_Melee_Atk_GEM_LEGEND_arg1()
    return 510, 'Magic_Melee_Atk', 1, 'ValueUp'
end
function get_tooltip_Magic_Melee_Atk_GEM_GODDESS_arg1()
    return 664, 'Magic_Melee_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 활 대미지
function get_tooltip_Arrow_Atk_GEM_LEGEND_arg1()
    return 510, 'Arrow_Atk', 1, 'ValueUp'
end
function get_tooltip_Arrow_Atk_GEM_GODDESS_arg1()
    return 664, 'Arrow_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 캐논 대미지
function get_tooltip_Cannon_Atk_GEM_LEGEND_arg1()
    return 510, 'Cannon_Atk', 1, 'ValueUp'
end
function get_tooltip_Cannon_Atk_GEM_GODDESS_arg1()
    return 664, 'Cannon_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 총기 대미지
function get_tooltip_Gun_Atk_GEM_LEGEND_arg1()
    return 510, 'Gun_Atk', 1, 'ValueUp'
end
function get_tooltip_Gun_Atk_GEM_GODDESS_arg1()
    return 664, 'Gun_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 찌르기 대미지
function get_tooltip_Aries_Atk_GEM_LEGEND_arg1()
    return 510, 'Aries_Atk', 1, 'ValueUp'
end
function get_tooltip_Aries_Atk_GEM_GODDESS_arg1()
    return 664, 'Aries_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 때리기 대미지
function get_tooltip_Strike_Atk_GEM_LEGEND_arg1()
    return 510, 'Strike_Atk', 1, 'ValueUp'
end
function get_tooltip_Strike_Atk_GEM_GODDESS_arg1()
    return 664, 'Strike_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 베기 대미지
function get_tooltip_Slash_Atk_GEM_LEGEND_arg1()
    return 510, 'Slash_Atk', 1, 'ValueUp'
end
function get_tooltip_Slash_Atk_GEM_GODDESS_arg1()
    return 664, 'Slash_Atk', 1, 'ValueUp'
end

-- 블랙 젬 - 추가 대미지
function get_tooltip_Add_Damage_Atk_GEM_LEGEND_arg1()
    return 890, 'Add_Damage_Atk', 1, 'ValueUp'
end
function get_tooltip_Add_Damage_Atk_GEM_GODDESS_arg1()
    return 1246, 'Add_Damage_Atk', 1, 'ValueUp'
end
