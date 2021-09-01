-- item_equip_restrict.lua (콘텐츠 입장 제한 확인 로직)

function is_scout_class(pc)
	if IsServerSection() ~= 1 then
		pc = GetMyPCObject()
	end

	local jobName = TryGetProp(pc, "JobName", "None");
    if jobName ~= "None" then
        local jobCls = GetClass("Job", jobName);
        if jobCls ~= nil then
            local ctrlType = TryGetProp(jobCls, "CtrlType");
			if ctrlType == "Scout" then
				return true
			end
		end
	end
	return false
end

-- 클라에선 쓰지 말 것

-- 분열 특이점 제한
function CHECK_SINGULARITY_AUTOMATCHING_FOR_EP13(pc)	
	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}
	local check_equip_list_2 = {'RING1', 'RING2', 'NECK'}
	local is_scout = is_scout_class(pc)
	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')
		if is_scout == true then
			item_rh = GetEquipItem(pc, 'LH')
		end
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 430, {{"Vibora", 1}}, 8, 10)
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end

		local item_lh = GetEquipItem(pc, 'LH')
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = GetEquipItem(pc, 'TRINKET')			
		end
		if is_scout == true then
			item_lh = GetEquipItem(pc, 'RH')
		end
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_lh, 440, 5, true, 380, {{"ALL", 380}}, 8, 10)	
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end		
		
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			-- 440레벨, 레전드, 고정아이커체크, 400레벨 고정아이커, 8초월, 8강
			ret = CHECK_ARMOR_ITEM(pc, item, 440, 5, true, 0, {{'ALL',400}}, 8, 8)
			if ret == false then
				SendSysMsg(pc, 'RequireArmorItemLowGrade');
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = GetEquipItem(pc, v)
			-- 350레벨, 레전드
			ret = CHECK_ACC_ITEM(pc, item, 350, 5, {{'ALL', 350}}, 0, 0)
			if ret == false then
				SendSysMsg(pc, "RequireAccessoriesItemLowGrade");
				return false
			end
		end

		-- 인장 체크
		local item_seal = GetEquipItem(pc, 'SEAL') 
		if item_seal == nil then
			SendSysMsg(pc, 'RequireSealEquip')
			return false
		end

		-- 보루타 인장 1레벨 & 근본 인장
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 1, { {'Boruta', 1}, {'2021NewYear', 0} })
		if ret == false then
			SendSysMsg(pc, "RequireSealItemLowGrade");
			return false
		end

		-- 아크 체크 (StringArg2 를 확인)
		local item_ark = GetEquipItem(pc, 'ARK')
		if item_ark == nil then
			SendSysMsg(pc, 'RequireArkEquip')
			return false
		end

		-- 퀘스트 아크 5레벨, 제작아크 5레벨
		ret = CHECK_ARK_ITEM(pc, item_ark, 1, {{'Quest_Ark', 5}, {'Made_Ark', 5}})
		if ret == false then
			SendSysMsg(pc, "RequireArkItemLowGrade");
			return false
		end

		-- 세트 옵션 체크
		ret = CHECK_SET_OPTION(pc)
		if ret == false then
			SendSysMsg(pc, "RequireSetOptionItemLowGrade");
			return false
		end
	end
	return true
end

-- EP13 챌린지 자동매칭
function CHECK_CHALLENGE_AUTOMATCHING_FOR_EP13(pc)		
	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}
	local check_equip_list_2 = {'RING1', 'RING2', 'NECK'}
	local is_scout = is_scout_class(pc)
	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')		
		if is_scout == true then
			item_rh = GetEquipItem(pc, 'LH')
		end
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라, 5초월
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 380, {{"ALL", 380}}, 5, 8)
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');			
			return false
		end

		local item_lh = GetEquipItem(pc, 'LH')
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = GetEquipItem(pc, 'TRINKET')			
		end
		if is_scout == true then
			item_lh = GetEquipItem(pc, 'RH')
		end
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라, 5초월
		local ret = CHECK_WEAPON_ITEM(pc, item_lh, 440, 5, true, 380, {{"ALL", 380}}, 5, 8)	
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end		
		
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			-- 400레벨, 레전드, 고정아이커체크, 고정아이커
			ret = CHECK_ARMOR_ITEM(pc, item, 400, 5, true, 0, {{'ALL', 400 }}, 5, 8)
			if ret == false then
				SendSysMsg(pc, 'RequireArmorItemLowGrade');
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = GetEquipItem(pc, v)
			-- 300레벨, 유니크
			ret = CHECK_ACC_ITEM(pc, item, 300, 4, {{'ALL', 300}, {'Arborday', 1}}, 0, 0)
			if ret == false then
				SendSysMsg(pc, "RequireAccessoriesItemLowGrade");
				return false
			end
		end

		-- 인장 체크
		local item_seal = GetEquipItem(pc, 'SEAL') 
		if item_seal == nil then
			SendSysMsg(pc, 'RequireSealEquip')
			return false
		end

		-- 실제 인장 아이템인지 체크
		if item_seal.GroupName ~= "Seal" then
			SendSysMsg(pc, 'RequireSealEquip');
			return false;
		end

		-- 모든 인장 허용
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 1, { {'ALL', 1}})
		if ret == false then
			SendSysMsg(pc, "RequireSealItemLowGrade");
			return false
		end

		-- 아크 체크 (StringArg2 를 확인)
		local item_ark = GetEquipItem(pc, 'ARK')
		if item_ark == nil then			
			SendSysMsg(pc, 'RequireArkEquip')
			return false
		end

		-- 퀘스트 아크 3레벨, 제작아크 3레벨
		ret = CHECK_ARK_ITEM(pc, item_ark, 1, {{'Quest_Ark', 3}, {'Made_Ark', 3}})
		if ret == false then
			SendSysMsg(pc, "RequireArkItemLowGrade");
			return false
		end	
	end
	return true
end

function CHECK_CHALLENGE_AUTOMATCHING_FOR_EP12(pc)	
	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}
	local check_equip_list_2 = {'RING1', 'RING2', 'NECK'}
	local is_scout = is_scout_class(pc)
	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')
		if is_scout == true then
			item_rh = GetEquipItem(pc, 'LH')			
		end
		-- 장비400레벨, 레전드등급, 고정아이커체크, 고정아이커, 5초월		
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 400, 5, true, 0, {{"ALL", 380}}, 8, 10, nil, false)
		local ret_2 = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 0, {{"ALL", 380}}, 5, 10, nil, false)		
		if ret == false and ret_2 == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade')
			return false
		end

		local item_lh = GetEquipItem(pc, 'LH')
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = GetEquipItem(pc, 'TRINKET')			
		end
		if is_scout == true then
			item_lh = GetEquipItem(pc, 'RH')
		end
		-- 장비400레벨, 레전드등급, 고정아이커체크, 고정아이커, 5초월
		ret = CHECK_WEAPON_ITEM(pc, item_lh, 400, 5, true, 0, {{"ALL", 380}, {'PC_Equip', 0}}, 8, 10, nil, false)	
		ret_2 = CHECK_WEAPON_ITEM(pc, item_lh, 440, 5, true, 0, {{"ALL", 380}, {'PC_Equip', 0}}, 5, 10, nil, false)
		
		if ret == false and ret_2 == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade')
			return false
		end		
		
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			-- 440레벨, 레전드, 고정아이커체크, 고정아이커
			ret = CHECK_ARMOR_ITEM(pc, item, 400, 5, true, 0, {{'ALL',380}, {'PC_Equip', 0}}, 8, 10, nil, false)
			ret_2 = CHECK_ARMOR_ITEM(pc, item, 400, 5, true, 0, {{'ALL',380}, {'PC_Equip', 0}}, 5, 8, nil, false)
			if ret == false and ret_2 == false then
				SendSysMsg(pc, 'RequireArmorItemLowGrade')
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = GetEquipItem(pc, v)
			-- 300레벨, 유니크
			ret = CHECK_ACC_ITEM(pc, item, 300, 4, {{'ALL', 300},{'Arborday', 1} }, 0, 0)
			if ret == false then
				SendSysMsg(pc, "RequireAccessoriesItemLowGrade");				
				return false
			end
		end

		-- 인장 체크
		local item_seal = GetEquipItem(pc, 'SEAL') 
		if item_seal == nil then
			SendSysMsg(pc, 'RequireSealEquip')
			return false
		end

		-- 실제 인장 아이템인지 체크
		if item_seal.GroupName ~= "Seal" then
			SendSysMsg(pc, 'RequireSealEquip');
			return false;
		end			

		-- 모든 인장 허용
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 1, { {'ALL', 1}})
		if ret == false then
			SendSysMsg(pc, "RequireSealItemLowGrade");
			return false
		end
	end
	return true
end

function CHECK_CHALLENGE_AUTOMATCHING_FOR_EP11(pc)		
	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}	
	local is_scout = is_scout_class(pc)
	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')
		if is_scout == true then
			item_rh = GetEquipItem(pc, 'LH')
		end
		-- 장비350레벨, 유니크 
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 350, 4, false, 0, {{'PC_Equip', 0}}, 8, 0)	
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end

		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			-- 장비350레벨, 유니크 
			ret = CHECK_ARMOR_ITEM(pc, item, 350, 4, false, 0, {{'PC_Equip', 0}}, 8, 0)
			if ret == false then
				SendSysMsg(pc, 'RequireArmorItemLowGrade');
				return false
			end
		end			
	end
	return true
end

function CHECK_EXTREME_GRADE_FOR_RELIC_DUNGEON(pc)	
	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}
	local check_equip_list_2 = {'RING1', 'RING2', 'NECK'}	
	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라등급, 10초월, 11강
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 430, {{"Vibora", 4}}, 10, 11)
		if ret == false then
			return false
		end

		local item_lh = GetEquipItem(pc, 'LH')
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = GetEquipItem(pc, 'TRINKET')			
		end
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라등급, 10초월, 11강
		local ret = CHECK_WEAPON_ITEM(pc, item_lh, 440, 5, true, 430, {{"Vibora", 1}}, 10, 11)		
		if ret == false then
			return false
		end		
		
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			-- 장비레벨 440, 레전드등급, 고정아이커체크, 1레벨 여신/마신, 10초월, 11강
			ret = CHECK_ARMOR_ITEM(pc, item, 440, 5, true, 400, { {'evil',1}, {'goddess',1}}, 10, 11)
			if ret == false then
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = GetEquipItem(pc, v)			
			-- 장비레벨 430, 레전드등급, 카랄 또는 루시페리, 10초월
			ret = CHECK_ACC_ITEM(pc, item, 430, 5, { {'Half_Acc_EP12', 1}, {'Acc_EP12', 1}, {'Luciferi', 1}}, 0, 0)
			if ret == false then
				return false
			end
		end

		-- 인장 체크
		local item_seal = GetEquipItem(pc, 'SEAL') 
		if item_seal == nil then
			SendSysMsg(pc, 'RequireSealEquip')
			return false
		end
		-- 레전드 등급, 보루타 인장 3레벨 & 근본 인장
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 5, { {'Boruta', 3}, {'2021NewYear', 0}})
		if ret == false then
			return false
		end

		-- 아크 체크 (StringArg2 를 확인)
		local item_ark = GetEquipItem(pc, 'ARK')
		if item_ark == nil then
			SendSysMsg(pc, 'RequireArkEquip')
			return false
		end
		-- 레전드 등급, 퀘스트/제작아크 7레벨
		ret = CHECK_ARK_ITEM(pc, item_ark, 5, {{'Quest_Ark', 7}, {'Made_Ark', 7}})
		if ret == false then
			return false
		end

		-- 세트 옵션 체크
		ret = CHECK_SET_OPTION(pc)
		if ret == false then
			return false
		end
		--성물 체크--
		local item_relic = GetEquipItem(pc, 'RELIC')
		if item_relic == nil then
			SendSysMsg(pc, 'RequireRelicEquip')
			return false
		end

		ret = CHECK_RELIC_ITEM(pc, item_relic, 458)
		if ret == false then
			SendSysMsg(pc, "RequireRelicEquip");
			return false
		end
	else
		local item_rh = session.GetEquipItemBySpot(item.GetEquipSpotNum('RH'))
		if item_rh == nil or item_rh:GetObject() == nil then
			return false
		end
		item_rh = GetIES(item_rh:GetObject())
		-- 장비440레벨, 레전드등급, 고정아이커체크, 바이보라등급, 10초월, 11강
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 430, {{"Vibora", 1}}, 10, 11)
		if ret == false then
			return false
		end

		local item_lh = session.GetEquipItemBySpot(item.GetEquipSpotNum('LH'))
		if item_lh == nil or item_lh:GetObject() == nil then
			return false
		end
		item_lh = GetIES(item_lh:GetObject())
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = session.GetEquipItemBySpot(item.GetEquipSpotNum('TRINKET'))
			if item_lh == nil or item_lh:GetObject() == nil then
				return
			end
			item_lh = GetIES(item_lh:GetObject())
		end		
		-- 장비440레벨, 레전드등급, 고정아이커체크, 바이보라등급, 10초월, 11강
		local ret = CHECK_WEAPON_ITEM(pc, item, 440, 5, true, 430, {{"Vibora",1}}, 10, 11)
		if ret == false then
			return false
		end

		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
			if item == nil or item:GetObject() == nil then
				return
			end
			item = GetIES(item:GetObject())
			-- 장비레벨 440, 레전드등급, 고정아이커체크, 1레벨 여신/마신, 10초월, 11강
			ret = CHECK_ARMOR_ITEM(pc, item, 440, 5, true, 400, {{'evil',1}, {'goddess',1}}, 10, 11)
			if ret == false then
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
			if item == nil or item:GetObject() == nil then
				return
			end
			item = GetIES(item:GetObject())
			-- 장비레벨 430, 레전드등급, 카랄 또는 루시페리, 10초월
			ret = CHECK_ACC_ITEM(pc, item, 430, 5, {{'Half_Acc_EP12',1}, {'Acc_EP12',1}, {'Luciferi',1}}, 0, 0)			
			if ret == false then
				return false
			end
		end
		
		-- 인장 체크
		local item_seal = session.GetEquipItemBySpot(item.GetEquipSpotNum('SEAL'))
		if item_seal == nil or item_seal:GetObject() == nil then
			ui.SysMsg(ScpArgMsg('RequireSealEquip'))
			return false
		end
		item_seal = GetIES(item_seal:GetObject())
		-- 레전드 등급, 보루타 인장 3레벨 & 근본 인장
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 5, {{'Boruta', 3}, {'2021NewYear', 0}})
		if ret == false then
			return false
		end

		-- 아크 체크
		local item_ark = session.GetEquipItemBySpot(item.GetEquipSpotNum('ARK'))
		if item_ark == nil or item_ark:GetObject() == nil then
			ui.SysMsg(ScpArgMsg('RequireArkEquip'))			
			return false
		end		
		item_ark = GetIES(item_ark:GetObject())
		-- 레전드 등급, 퀘스트/제작아크 7레벨
		ret = CHECK_ARK_ITEM(pc, item_ark, 5, {{'Quest_Ark', 7}, {'Made_Ark', 7}})
		if ret == false then
			return false
		end

		-- 세트 옵션 체크
		ret = CHECK_SET_OPTION(pc)
		if ret == false then
			return false
		end
		--성물 체크--
		local item_relic = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
		if item_relic == nil or item_relic:GetObject() == nil then
			ui.SysMsg(ScpArgMsg('RequireRelicEquip'))			
			return false
		end
		item_relic = GetIES(item_relic:GetObject())
		--임시처리--
		ret = CHECK_RELIC_ITEM(pc, item_relic, 458)
		if ret == false then
			return false
		end
	end
	return true
end

function CHECK_HARD_GRADE_FOR_RELIC_DUNGEON(pc)
	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}
	local check_equip_list_2 = {'RING1', 'RING2', 'NECK'}
	local is_scout = is_scout_class(pc)
	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')
		if is_scout == true then
			item_rh = GetEquipItem(pc, 'LH')
		end
		-- 장비440레벨, 고정아이커체크, 1레벨 바이보라, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 430, {{"Vibora", 1}}, 10, 11)
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end

		local item_lh = GetEquipItem(pc, 'LH')
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = GetEquipItem(pc, 'TRINKET')			
		end
		if is_scout == true then
			item_lh = GetEquipItem(pc, 'RH')
		end
		-- 장비440레벨, 고정아이커체크, 380레벨 고정아이커, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_lh, 440, 5, true, 380, {{"ALL", 380}}, 10, 11)	
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end		
		
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			-- 440레벨, 레겐다, 고정아이커체크, 430레벨 고정아이커
			ret = CHECK_ARMOR_ITEM(pc, item, 440, 5, true, 0, {{'evil',1},{'goddess',1}}, 10, 11, {"GlacierLegenda"})
			if ret == false then
				SendSysMsg(pc, 'RequireArmorItemLowGrade');
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = GetEquipItem(pc, v)
			-- 430레벨, 레전드
			ret = CHECK_ACC_ITEM(pc, item, 430, 5, {{'ALL', 430}}, 0, 0)
			if ret == false then
				SendSysMsg(pc, "RequireAccessoriesItemLowGrade");
				return false
			end
		end

		-- 인장 체크
		local item_seal = GetEquipItem(pc, 'SEAL') 
		if item_seal == nil then
			SendSysMsg(pc, 'RequireSealEquip')
			return false
		end

		-- 레전드, 보루타 인장 3레벨
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 5, { {'Boruta', 3} })
		if ret == false then
			SendSysMsg(pc, "RequireSealItemLowGrade");
			return false
		end

		-- 아크 체크 (StringArg2 를 확인)
		local item_ark = GetEquipItem(pc, 'ARK')
		if item_ark == nil then
			SendSysMsg(pc, 'RequireArkEquip')
			return false
		end
		-- 퀘스트 아크 6레벨, 제작아크 6레벨
		ret = CHECK_ARK_ITEM(pc, item_ark, 5, {{'Made_Ark', 6}})
		if ret == false then
			SendSysMsg(pc, "RequireArkItemLowGrade");
			return false
		end

		-- 세트 옵션 체크
		ret = CHECK_SET_OPTION(pc)
		if ret == false then
			SendSysMsg(pc, "RequireSetOptionItemLowGrade");
			return false
		end
		--성물 체크--
		local item_relic = GetEquipItem(pc, 'RELIC')
		if item_relic == nil then
			SendSysMsg(pc, 'RequireRelicEquip')
			return false
		end

		ret = CHECK_RELIC_ITEM(pc, item_relic, 458)
		if ret == false then
			SendSysMsg(pc, "RequireRelicEquip");
			return false
		end
		--상급 특성 20레벨 3개 이상--
		ret = CHECK_HIDDEN_ABILITY(pc, 3, 20)
		if ret == false then
			return false
		end
	end
	return true
end

function CHECK_EASY_GRADE_FOR_RELIC_DUNGEON(pc)
	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}
	local check_equip_list_2 = {'RING1', 'RING2', 'NECK'}
	local is_scout = is_scout_class(pc)
	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')
		if is_scout == true then
			item_rh = GetEquipItem(pc, 'LH')
		end
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 430, {{"Vibora", 1}}, 8, 10)
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end

		local item_lh = GetEquipItem(pc, 'LH')
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = GetEquipItem(pc, 'TRINKET')			
		end
		if is_scout == true then
			item_lh = GetEquipItem(pc, 'RH')
		end
		-- 장비440레벨, 레전드등급, 고정아이커 380레벨, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_lh, 440, 5, true, 380, {{"ALL", 380}}, 8, 10)	
		if ret == false then
			SendSysMsg(pc, 'RequireWeaponItemLowGrade');
			return false
		end		
		
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			-- 440레벨, 레전드, 고정아이커체크, 430레벨 고정아이커
			ret = CHECK_ARMOR_ITEM(pc, item, 440, 5, true, 0, {{'ALL',430}}, 8, 10)
			if ret == false then
				SendSysMsg(pc, 'RequireArmorItemLowGrade');
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = GetEquipItem(pc, v)
			-- 350레벨, 레전드
			ret = CHECK_ACC_ITEM(pc, item, 350, 5, {{'ALL', 350}}, 0, 0)
			if ret == false then
				SendSysMsg(pc, "RequireAccessoriesItemLowGrade");
				return false
			end
		end

		-- 인장 체크
		local item_seal = GetEquipItem(pc, 'SEAL') 
		if item_seal == nil then
			SendSysMsg(pc, 'RequireSealEquip')
			return false
		end
		-- 보루타 인장 1레벨 & 근본 인장
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 1, { {'Boruta', 1}, {'2021NewYear', 0} })
		if ret == false then
			SendSysMsg(pc, "RequireSealItemLowGrade");
			return false
		end

		-- 아크 체크 (StringArg2 를 확인)
		local item_ark = GetEquipItem(pc, 'ARK')
		if item_ark == nil then
			SendSysMsg(pc, 'RequireArkEquip')
			return false
		end
		-- 퀘스트 아크 5레벨, 제작아크 5레벨
		ret = CHECK_ARK_ITEM(pc, item_ark, 1, {{'Quest_Ark', 5}, {'Made_Ark', 5}})
		if ret == false then
			SendSysMsg(pc, "RequireArkItemLowGrade");
			return false
		end
		-- 세트 옵션 체크
		ret = CHECK_SET_OPTION(pc)
		if ret == false then
			SendSysMsg(pc, "RequireSetOptionItemLowGrade");
			return false
		end
		--성물 체크--
		local item_relic = GetEquipItem(pc, 'RELIC')
		if item_relic == nil then
			SendSysMsg(pc, 'RequireRelicEquip')
			return false
		end

		ret = CHECK_RELIC_ITEM(pc, item_relic, 458)
		if ret == false then
			SendSysMsg(pc, "RequireRelicEquip");
			return false
		end
	else
		local item_rh = session.GetEquipItemBySpot(item.GetEquipSpotNum('RH'))
		if item_rh == nil or item_rh:GetObject() == nil then
			return false
		end
		item_rh = GetIES(item_rh:GetObject())
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_rh, 440, 5, true, 430, {{"Vibora", 1}}, 8, 10)	
		if ret == false then
			return false
		end

		local item_lh = session.GetEquipItemBySpot(item.GetEquipSpotNum('LH'))
		if item_lh == nil or item_lh:GetObject() == nil then
			return false
		end
		item_lh = GetIES(item_lh:GetObject())
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = session.GetEquipItemBySpot(item.GetEquipSpotNum('TRINKET'))
			if item_lh == nil or item_lh:GetObject() == nil then
				return
			end
			item_lh = GetIES(item_lh:GetObject())
		end
		-- 장비440레벨, 레전드등급, 고정아이커체크, 1레벨 바이보라, 8초월
		local ret = CHECK_WEAPON_ITEM(pc, item_lh, 440, 5, true, 380, {{"ALL", 380}}, 8, 10)	
		if ret == false then
			return false
		end
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
			if item == nil or item:GetObject() == nil then
				return
			end
			item = GetIES(item:GetObject())
			-- 440레벨, 레전드, 고정아이커체크, 430레벨 고정아이커
			ret = CHECK_ARMOR_ITEM(pc, item, 440, 5, true, 0, {{'ALL',430}}, 8, 10)
			if ret == false then
				return false
			end
		end

		-- 악세서리 체크
		for k, v in pairs(check_equip_list_2) do
			local item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
			if item == nil or item:GetObject() == nil then
				return
			end
			item = GetIES(item:GetObject())
			-- 350레벨, 레전드
			ret = CHECK_ACC_ITEM(pc, item, 350, 5, {{'ALL', 350}}, 0, 0)
			if ret == false then
				return false
			end
		end
		
		-- 인장 체크
		local item_seal = session.GetEquipItemBySpot(item.GetEquipSpotNum('SEAL'))
		if item_seal == nil or item_seal:GetObject() == nil then
			ui.SysMsg(ScpArgMsg('RequireSealEquip'))
			return false
		end
		item_seal = GetIES(item_seal:GetObject())
		-- 보루타 인장 1레벨 & 근본 인장
		ret = CHECK_SEAL_ITEM(pc, item_seal, 0, 1, { {'Boruta', 1}, {'2021NewYear', 0}})
		if ret == false then
			return false
		end

		-- 아크 체크
		local item_ark = session.GetEquipItemBySpot(item.GetEquipSpotNum('ARK'))
		if item_ark == nil or item_ark:GetObject() == nil then
			ui.SysMsg(ScpArgMsg('RequireArkEquip'))			
			return false
		end		
		item_ark = GetIES(item_ark:GetObject())
		-- 퀘스트 아크 5레벨, 제작아크 5레벨
		ret = CHECK_ARK_ITEM(pc, item_ark, 1, {{'Quest_Ark', 5}, {'Made_Ark', 5}})
		if ret == false then
			return false
		end
		-- 세트 옵션 체크
		ret = CHECK_SET_OPTION(pc)
		if ret == false then
			ui.SysMsg(ScpArgMsg('RequireSetOptionItemLowGrade'))	
			return false
		end
		--성물 체크--
		local item_relic = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
		if item_relic == nil or item_relic:GetObject() == nil then
			ui.SysMsg(ScpArgMsg('RequireRelicEquip'))			
			return false
		end
		item_relic = GetIES(item_relic:GetObject())
		ret = CHECK_RELIC_ITEM(pc, item_relic, 458)
		if ret == false then
			return false
		end
	end
	return true
end

function CHECK_WEAPON_ITEM(pc, item, item_level, item_grade, check_inheritance, inheritance_lv, check_string_arg_list, transcend_count, reinforce_count, dungeonEnterType, active_msg)
	if active_msg == nil then
		active_msg = true
	end
	if item == nil then
		if active_msg == true then
			SendSysMsg(pc, 'RequireWeaponEquip')
		end
		return false, ScpArgMsg('RequireWeaponEquip')
	end
	
	if TryGetProp(item, 'StringArg', 'None') == 'FreePvP' then
		if active_msg == true then
			SendSysMsg(pc, 'NotAllowFreePvPEquip')
		end
		return false, ScpArgMsg('NotAllowFreePvPEquip')
	end
	
	if TryGetProp(item, 'ItemGrade', 0) < item_grade then
		local msg = 'Rare'
		if item_grade == 5 then
			msg = ScpArgMsg("Legend")
		elseif item_grade == 4 then
			msg = ScpArgMsg("Unique")
		elseif item_grade == 3 then
			msg = ScpArgMsg("Rare")
		end

		if active_msg == true then				
			SendSysMsg(pc, 'RequireWeaponItemGrade{grade}', 0, 'grade', msg)		
		end
		return false, ScpArgMsg("RequireWeaponItemGrade{grade}", "grade", msg)
	end
	
	if TryGetProp(item, 'StringArg', 'None') ~= 'PC_Equip' and TryGetProp(item, 'UseLv', 0) < item_level then
		if active_msg == true then			
			SendSysMsg(pc, 'RequireWeapon{level}', 0, 'level', item_level)		
		end
		return false, ScpArgMsg("RequireWeapon{level}", "level", item_level)
	end

	local is_match = false
	if check_inheritance == true then
		local inheritanceItemName = TryGetProp(item, 'InheritanceItemName', 'None')
		if inheritanceItemName == 'None' then
			if TryGetProp(item, 'StringArg', 'None') == 'PC_Equip' then
				inheritanceItemName = TryGetProp(item, 'ClassName', 'None')
			end
		end
		
		local cls = GetClass('Item', inheritanceItemName)
		if cls == nil then
			return false
		end
	
		if TryGetProp(cls, 'UseLv', 0) < inheritance_lv then
			if active_msg == true then		
				SendSysMsg(pc, 'RequireWeaponInheritanceItemLowGrade')			
			end
			return false, ScpArgMsg("RequireWeaponInheritanceItemLowGrade")
		end
	
		
		for k, v in pairs(check_string_arg_list) do		
			if #v == 2 then
				if v[1] == 'ALL' and TryGetProp(cls, 'UseLv', 0) >= v[2] then
					is_match = true
					break
				end				
				if v[1] == TryGetProp(cls, 'StringArg', 'None') and TryGetProp(cls, 'NumberArg1', 0) >= v[2] then
					is_match = true
					break
				end
			end			
		end
		
		if is_match == false then
			if active_msg == true then				
				SendSysMsg(pc, 'RequireWeaponInheritanceItemLowGrade')			
			end
			return false, ScpArgMsg("RequireWeaponInheritanceItemLowGrade")
		end
	else
		for k, v in pairs(check_string_arg_list) do		
			if #v == 2 then
				if v[1] == 'PC_Equip' and TryGetProp(item, 'StringArg', 'None') == 'PC_Equip'  then
					is_match = true
					break
				end
			end			
		end
	end
	
	if TryGetProp(item, 'Transcend', 0) < transcend_count then
		if active_msg == true then			
			SendSysMsg(pc, 'RequireWeaponTranscend{count}over', 0, 'count', transcend_count)		
		end
		return false, ScpArgMsg("RequireWeaponTranscend{count}over", "count", transcend_count)
	end
	
	if TryGetProp(item, 'Reinforce_2', 0) < reinforce_count then
		if active_msg == true then			
			SendSysMsg(pc, 'RequireWeaponReinforce{count}over', 0, 'count', reinforce_count)		
		end
		return false, ScpArgMsg("RequireWeaponReinforce{count}over", "count", reinforce_count)
	end
	
	if dungeonEnterType ~= nil then
		local enterTypeCheck = false
		for j = 1, #dungeonEnterType do
			if TryGetProp(item, "DungeonEnterType") == dungeonEnterType[j] then
				enterTypeCheck = true
				break;
			end
		end
		if enterTypeCheck == false then
			if active_msg == true then			
				SendSysMsg(pc, "RequireWeaponlegenda")		
			end
			return false, ScpArgMsg("RequireWeaponlegenda")
		end
	end
	return true
end

function CHECK_ARMOR_ITEM(pc, item, item_level, item_grade, check_inheritance, inheritance_lv, check_string_arg_list, transcend_count, reinforce_count, dungeonEnterType, active_msg)
	if active_msg == nil then active_msg = true end
	if item == nil then
		if active_msg == true then
			SendSysMsg(pc, 'RequireArmorEquip')		
		end
		return false, ScpArgMsg('RequireArmorEquip')
	end
	
	if TryGetProp(item, 'StringArg', 'None') == 'FreePvP' then
		if active_msg == true then
			SendSysMsg(pc, 'NotAllowFreePvPEquip')		
		end		
		return false, ScpArgMsg('NotAllowFreePvPEquip')
	end

	if TryGetProp(item, 'ItemGrade', 0) < item_grade then
		local msg = 'Rare'
		if item_grade == 5 then
			msg = ScpArgMsg("Legend")
		elseif item_grade == 4 then
			msg = ScpArgMsg("Unique")
		elseif item_grade == 3 then
			msg = ScpArgMsg("Rare")
		end

		if active_msg == true then
			SendSysMsg(pc, 'RequireArmorItemGrade{grade}', 0, 'grade', msg)		
		end
		return false, ScpArgMsg("RequireArmorItemGrade{grade}", "grade", msg)
	end

	if TryGetProp(item, 'StringArg', 'None') ~= 'PC_Equip' and TryGetProp(item, 'UseLv', 0) < item_level then
		if active_msg == true then
			SendSysMsg(pc, 'RequireArmor{level}', 0, 'level', item_level)		
		end
		return false, ScpArgMsg("RequireArmor{level}", "level", item_level)
	end

	local is_match = false
	if check_inheritance == true then
		local inheritanceItemName = TryGetProp(item, 'InheritanceItemName', 'None')
		if inheritanceItemName == 'None' then
			if TryGetProp(item, 'StringArg', 'None') == 'PC_Equip' then
				inheritanceItemName = TryGetProp(item, 'ClassName', 'None')
			end
		end

		local cls = GetClass('Item', inheritanceItemName)
		if cls == nil then
			return false			
		end
		
		if TryGetProp(cls, 'UseLv', 0) < inheritance_lv then
			if active_msg == true then
				SendSysMsg(pc, 'RequireArmorInheritanceItemLowGrade')			
			end
			return false, ScpArgMsg("RequireArmorInheritanceItemLowGrade")
		end
		
		for k, v in pairs(check_string_arg_list) do
			if #v == 2 then
				if v[1] == 'ALL' and TryGetProp(cls, 'UseLv', 0) >= v[2] then
					is_match = true
					break
				end				
				if v[1] == TryGetProp(cls, 'StringArg', 'None') and TryGetProp(cls, 'NumberArg1', 0) >= v[2] then
					is_match = true
					break
				end
			end	
		end

		if is_match == false then
			if active_msg == true then
				SendSysMsg(pc, 'RequireArmorInheritanceItemLowGrade')			
			end
			return false, ScpArgMsg("RequireArmorInheritanceItemLowGrade")
		end
	else
		for k, v in pairs(check_string_arg_list) do		
			if #v == 2 then
				if v[1] == 'PC_Equip' and TryGetProp(item, 'StringArg', 'None') == 'PC_Equip'  then
					is_match = true
					break
				end
			end			
		end
	end

	

	if TryGetProp(item, 'Transcend', 0) < transcend_count then
		if active_msg == true then
			SendSysMsg(pc, 'RequireArmorTranscend{count}over', 0, 'count', transcend_count)		
		end
		return false, ScpArgMsg("RequireArmorTranscend{count}over", "count", transcend_count)
	end

	if TryGetProp(item, 'Reinforce_2', 0) < reinforce_count then
		if active_msg == true then
			SendSysMsg(pc, 'RequireArmorReinforce{count}over', 0, 'count', reinforce_count)		
		end
		return false, ScpArgMsg("RequireArmorReinforce{count}over", "count", reinforce_count)
	end

	if dungeonEnterType ~= nil then
		local enterTypeCheck = false
		for j = 1, #dungeonEnterType do
			if TryGetProp(item, "DungeonEnterType") == dungeonEnterType[j] then
				enterTypeCheck = true
				break;
			end
		end
		if enterTypeCheck == false then
			if active_msg == true then			
				SendSysMsg(pc, "RequireWeaponlegenda")		
			end
			return false, ScpArgMsg("RequireWeaponlegenda")
		end
	end
	return true
end

function CHECK_ACC_ITEM(pc, item, item_level, item_grade, check_string_arg_list, transcend_count, reinforce_count)
	if item == nil then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireAccEquip')
		else
			ui.SysMsg(ScpArgMsg('RequireAccEquip'))	
		end
		return false
	end

	if TryGetProp(item, 'ItemGrade', 0) < item_grade then
		local msg = 'Rare'
		if item_grade == 5 then
			msg = ScpArgMsg("Legend")
		elseif item_grade == 4 then
			msg = ScpArgMsg("Unique")
		elseif item_grade == 3 then
			msg = ScpArgMsg("Rare")
		end

		if IsServerSection() == 1 then			
			SendSysMsg(pc, 'RequireAccItemGrade{grade}', 0, 'grade', msg)
		else
			ui.SysMsg(ScpArgMsg("RequireAccItemGrade{grade}", "grade", msg))		
		end
		return false
	end
	
	local is_match = false
	if check_string_arg_list ~= nil and #check_string_arg_list > 0 then				
		for k, v in pairs(check_string_arg_list) do			
			if #v == 2 then								
				if v[1] == 'ALL' and TryGetProp(item, 'UseLv', 0) >= v[2] then
					is_match = true
					break
				end			
				if v[1] == TryGetProp(item, 'StringArg', 'None') and TryGetProp(item, 'UseLv', 0) >= v[2] then
					is_match = true
					break
				end
			end
		end
		if is_match == false then
			if IsServerSection() == 1 then				
				SendSysMsg(pc, 'RequireAccItemLowGrade')
			else
				ui.SysMsg(ScpArgMsg("RequireAccItemLowGrade"))
			end
			return false
		end
	end

	if is_match == false and TryGetProp(item, 'UseLv', 0) < item_level then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireAcc{level}', 0, 'level', item_level)
		else
			ui.SysMsg(ScpArgMsg("RequireAcc{level}", "level", item_level))		
		end
		return false
	end

	if TryGetProp(item, 'Transcend', 0) < transcend_count then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireAccTranscend{count}over', 0, 'count', transcend_count)
		else
			ui.SysMsg(ScpArgMsg("RequireAccTranscend{count}over", "count", transcend_count))		
		end
		return false
	end

	if TryGetProp(item, 'Reinforce_2', 0) < reinforce_count then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireAccReinforce{count}over', 0, 'count', reinforce_count)
		else
			ui.SysMsg(ScpArgMsg("RequireAccReinforce{count}over", "count", reinforce_count))		
		end
		return false
	end

	return true
end

function CHECK_SEAL_ITEM(pc, item, item_level, item_grade, check_string_arg_list)
	if item == nil then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireSealEquip')
		else
			ui.SysMsg(ScpArgMsg('RequireSealEquip'))	
		end
		return false
	end
	
	if TryGetProp(item, 'ItemGrade', 0) < item_grade then
		local msg = 'Rare'
		if item_grade == 5 then
			msg = ScpArgMsg("Legend")
		elseif item_grade == 4 then
			msg = ScpArgMsg("Unique")
		elseif item_grade == 3 then
			msg = ScpArgMsg("Rare")
		end

		if IsServerSection() == 1 then			
			SendSysMsg(pc, 'RequireSealItemGrade{grade}', 0, 'grade', msg)
		else
			ui.SysMsg(ScpArgMsg("RequireSealItemGrade{grade}", "grade", msg))		
		end
		return false
	end

	local is_match = false
	if check_string_arg_list ~= nil and #check_string_arg_list > 0 then		
		for k, v in pairs(check_string_arg_list) do
			if #v == 2 then
				if v[1] == 'ALL' and TryGetProp(item, 'UseLv', 0) >= v[2] then
					is_match = true
					break
				end
				
				if v[1] == TryGetProp(item, 'StringArg', 'None') and GET_CURRENT_SEAL_LEVEL(item) >= v[2] then
					is_match = true
					break
				end
			end
		end
		if is_match == false then
			if IsServerSection() == 1 then
				SendSysMsg(pc, 'RequireSealItemLowGrade')
			else
				ui.SysMsg(ScpArgMsg("RequireSealItemLowGrade"))
			end
			return false
		end
	end

	if is_match == false and TryGetProp(item, 'UseLv', 0) < item_level then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireSeal{level}', 0, 'level', item_level)
		else
			ui.SysMsg(ScpArgMsg("RequireSeal{level}", "level", item_level))		
		end
		return false
	end

	return true
end

function CHECK_ARK_ITEM(pc, item, item_grade, check_string_arg_list)
	if item == nil then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireArkEquip')
		else
			ui.SysMsg(ScpArgMsg('RequireArkEquip'))	
		end
		return false
	end

	if TryGetProp(item, 'ItemGrade', 0) < item_grade then
		local msg = 'Rare'
		if item_grade == 5 then
			msg = ScpArgMsg("Legend")
		elseif item_grade == 4 then
			msg = ScpArgMsg("Unique")
		elseif item_grade == 3 then
			msg = ScpArgMsg("Rare")
		end

		if IsServerSection() == 1 then	
			SendSysMsg(pc, 'RequireArkItemGrade{grade}', 0, 'grade', msg)
		else
			ui.SysMsg(ScpArgMsg("RequireArkItemGrade{grade}", "grade", msg))		
		end
		return false
	end

	local is_match = false
	if check_string_arg_list ~= nil and #check_string_arg_list > 0 then		
		for k, v in pairs(check_string_arg_list) do
			if #v == 2 then
				if v[1] == 'ALL' and TryGetProp(item, 'UseLv', 0) >= v[2] then
					is_match = true
					break
				end
				
				if v[1] == TryGetProp(item, 'StringArg2', 'None') and TryGetProp(item, 'ArkLevel', 0) >= v[2] then
					is_match = true
					break
				end
			end			
		end
		
		if is_match == false then
			if IsServerSection() == 1 then
				SendSysMsg(pc, 'RequireArkItemLowGrade')
			else
				ui.SysMsg(ScpArgMsg("RequireArkItemLowGrade"))
			end
			return false
		end
	end
	return true
end

function CHECK_SET_OPTION(pc)
	if item == nil then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireLegendSetOption')
		else
			ui.SysMsg(ScpArgMsg('RequireLegendSetOption'))	
		end
		return false
	end

	local check_equip_list_1 = {'SHIRT', 'GLOVES', 'BOOTS', 'PANTS'}
	local dic_set_option = {}

	if IsServerSection() == 1 then
		local item_rh = GetEquipItem(pc, 'RH')
		if item_rh ~= nil then
			local name = TryGetProp(item_rh, 'LegendPrefix', 'None')
			if name ~= 'None' then
				if dic_set_option[name] == nil then
					dic_set_option[name] = 1
				else
					dic_set_option[name] = dic_set_option[name] + 1
				end
			end
		end

		local item_lh = GetEquipItem(pc, 'LH')
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = GetEquipItem(pc, 'TRINKET')			
		end
		
		if item_lh ~= nil then
			local name = TryGetProp(item_lh, 'LegendPrefix', 'None')
			if name ~= 'None' then
				if dic_set_option[name] == nil then
					dic_set_option[name] = 1
				else
					dic_set_option[name] = dic_set_option[name] + 1
				end
			end
		end
		
		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = GetEquipItem(pc, v)
			if item ~= nil then
				local name = TryGetProp(item, 'LegendPrefix', 'None')
				if name ~= 'None' then
					if dic_set_option[name] == nil then
						dic_set_option[name] = 1
					else
						dic_set_option[name] = dic_set_option[name] + 1
					end
				end
			end			
		end
	else
		local item_rh = session.GetEquipItemBySpot(item.GetEquipSpotNum('RH'))
		if item_rh ~= nil and item_rh:GetObject() ~= nil then
			item_rh = GetIES(item_rh:GetObject())
			local name = TryGetProp(item_rh, 'LegendPrefix', 'None')
			if name ~= 'None' then
				if dic_set_option[name] == nil then
					dic_set_option[name] = 1
				else
					dic_set_option[name] = dic_set_option[name] + 1
				end
			end
		end
		
		local item_lh = session.GetEquipItemBySpot(item.GetEquipSpotNum('LH'))
		if item_lh ~= nil and item_lh:GetObject() ~= nil then		
			item_lh = GetIES(item_lh:GetObject())			
		end
				
		if TryGetProp(item_rh, 'EquipGroup', 'None') == 'THWeapon' then
			item_lh = session.GetEquipItemBySpot(item.GetEquipSpotNum('TRINKET'))
			if item_lh ~= nil and item_lh:GetObject() ~= nil then
				item_lh = GetIES(item_lh:GetObject())
			end			
		end		
		
		if item_lh ~= nil then
			local name = TryGetProp(item_lh, 'LegendPrefix', 'None')
			if name ~= 'None' then
				if dic_set_option[name] == nil then
					dic_set_option[name] = 1
				else
					dic_set_option[name] = dic_set_option[name] + 1
				end
			end
		end

		-- 방어구 체크
		for k, v in pairs(check_equip_list_1) do
			local item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
			if item ~= nil and item:GetObject() ~= nil then
				item = GetIES(item:GetObject())
				local name = TryGetProp(item, 'LegendPrefix', 'None')
				if name ~= 'None' then
					if dic_set_option[name] == nil then
						dic_set_option[name] = 1
					else
						dic_set_option[name] = dic_set_option[name] + 1
					end
				end
			end
		end
	end

	for k, v in pairs(dic_set_option) do
		local cls = GetClass('LegendSetItem', k)
		if cls ~= nil then
			if TryGetProp(cls, 'MaxOptionCount', 0) ~= 0 and TryGetProp(cls, 'MaxOptionCount', 0) <= v then
				return true
			end
		end
	end	

	if IsServerSection() == 1 then
		SendSysMsg(pc, 'RequireLegendSetOption')
	else
		ui.SysMsg(ScpArgMsg('RequireLegendSetOption'))	
	end
	return false
end

function CHECK_RELIC_ITEM(pc, item, uselv)
	if item == nil then
		if IsServerSection() == 1 then
			SendSysMsg(pc, 'RequireRelicEquip')
		else
			ui.SysMsg(ScpArgMsg('RequireRelicEquip'))	
		end
		return false
	end
		
	if TryGetProp(item, 'UseLv', 0) < uselv then
		if IsServerSection() == 1 then			
			SendSysMsg(pc, "RequireRelicEquip")
		else
			ui.SysMsg(ScpArgMsg("RequireRelicEquip"))		
		end
		return false
	end
	return true
end

-- goal_lv보다 높은 상급 특성이 abil_count 만큼 있어야 한다.
function CHECK_HIDDEN_ABILITY(pc, abil_count, goal_lv)	
	abil_count = tonumber(abil_count)
	goal_lv = tonumber(goal_lv)
	local abil_list = GetAbilityNames(pc)
	local match_count = 0
	for k, name in pairs(abil_list) do
		local is = IS_HIGH_HIDDENABILITY('HiddenAbility_' .. name)
		if is == true then
			local abil = GetAbility(pc, name)
			local level = TryGetProp(abil, 'Level', 0)			
			if level >= goal_lv then
				match_count = match_count + 1
				if match_count >= abil_count then	
					return true
				end
			end
		end
	end
	
	SendSysMsg(pc, 'MustHaveHiddenAbility{goal_lv}{count}{current}', 0, 'goal_lv', goal_lv, 'count', abil_count, 'current', match_count)
	return false
end
