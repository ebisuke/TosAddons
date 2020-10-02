--merkabarfix
function ON_RIDING_VEHICLE(onoff)
    local commanderPC = GetCommanderPC()
    if IsBuffApplied(commanderPC, 'pet_PetHanaming_buff') == 'YES' or IsBuffApplied(commanderPC, 'Levitation_Buff') == 'YES' then -- no ride
        return;
    end
    local cartHandle = control.GetNearSitableCart();
    
	local isRidingOnly = 'NO';
    local summonedCompanion = session.pet.GetSummonedPet(0); -- Riding Companion Only / Not Hawk --
    if summonedCompanion ~= nil and cartHandle==0 then
	
    --if summonedCompanion ~= nil then
		local companionObj = summonedCompanion:GetObject();
		local companionIES = GetIES(companionObj);
		local companionIsActivated = TryGetProp(companionIES, 'IsActivated');
		if companionIsActivated == 0 and onoff == 1 then 
			ui.SysMsg(ClMsg('CompanionIsNotActive'));
			return
		end
		local companionClassName = TryGetProp(companionIES, 'ClassName');
		if companionClassName ~= nil then
			local companionClass = GetClass('Companion', companionClassName);
			isRidingOnly = TryGetProp(companionClass, 'RidingOnly');
		end
	end
	
 
    --js: 현재 메르카바만 하드코딩 형태로 예외처리되어있다 위에 함수명만 봐도 알수있음, 해당 예외처리 추후 하기로 정수씨와 이야기함 (2.0끝나고)--
    if (control.HaveNearCompanionToRide() == true or isRidingOnly == 'YES') or cartHandle == 0 then
	
	--if (control.HaveNearCompanionToRide() == true or isRidingOnly == 'YES') and cartHandle == 0 then
		local fsmActor = GetMyActor();
		local subAction = fsmActor:GetSubActionState();
		
		-- 41, 42 == CSS_SKILL_READY, CSS_SKILL_USE
		if subAction == 41 or subAction == 42 then
			ui.SysMsg(ClMsg('SkillUse_Vehicle'));
			return;
		end
		
		if 1 == onoff then
			local abil = GetAbility(GetMyPCObject(), "CompanionRide");
			if nil == abil and control.IsPremiumCompanion() == false then
				ui.SysMsg(ClMsg('PetHasNotAbility'));
				return
			end
		end
		
		local ret = control.RideCompanion(onoff);
		if ret == false then
			return;
		end
	else
		if onoff == 1 then
			if cartHandle ~= 0 then
				local index = control.GetNearSitableCartIndex();
				control.ReqRideCart(cartHandle, index);
			end
		else
			local myActor = GetMyActor();
			if myActor ~= nil and myActor:GetUserIValue("CART_ATTACHED") == 1 then
				control.ReqRideCart(myActor:GetUserIValue("CART_ATTACHED_HANDLE"), -1);
			end			
		end
	end
end