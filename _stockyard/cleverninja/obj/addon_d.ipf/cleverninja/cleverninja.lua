--OLD_SHOP_ITEM_LIST_GET
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

local acutil = require('acutil')

-- ライブラリ読み込み
function CLEVERNINJA_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
			if(OLD_MCC_SCRIPT_NINJA == nil or MCC_SCRIPT_NINJA ~= CLEVERNINJA_MCC_SCRIPT_NINJA_JUMPER)then
				OLD_MCC_SCRIPT_NINJA=MCC_SCRIPT_NINJA;
				MCC_SCRIPT_NINJA=CLEVERNINJA_MCC_SCRIPT_NINJA_JUMPER
			end
			--addon:RegisterMsg('DYNAMIC_CAST_BEGIN', 'PSEUDOFORECAST_DYNAMIC_CASTINGBAR_ON_MSG');
			--addon:RegisterMsg('DYNAMIC_CAST_END', 'PSEUDOFORECAST_DYNAMIC_CASTINGBAR_ON_MSG');
			--addon:RegisterMsg('GAME_START_SE', 'PSEUDOFORECAST_DYNAMIC_CASTINGBAR_ON_MSG');
			PSEUDOFORECAST_LOADSKILLS()
			acutil.slashCommand("/pf", PSEUDOFORECAST_PROCESS_COMMAND);
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function CLEVERNINJA_MCC_SCRIPT_NINJA_JUMPER(actor, mccIndex)
	CLEVERNINJA_MCC_SCRIPT_NINJA(actor, mccIndex)
end
function CLEVERNINJA_MCC_SCRIPT_NINJA(actor, mccIndex)

	if actor:IsSkillState() == true then
		return;
	end

	local myActor = GetMyActor();
	if myActor:IsSkillState() == true then

		local skillID = myActor:GetUseSkill();
		local sklName = GetClassByType("Skill", skillID).ClassName;
		local skills = GET_NINJA_SKILLS();
		local useSkill = false;
		-- for i = 1 , #skills do
		-- 	local ninjaSklName = skills[i];
		-- 	if ninjaSklName == sklName then
		-- 		useSkill = true;
		-- 	end
		-- end

		--if useSkill == true then
		
			local tgt = geMCC.GetLastAttackObject(25.0);
			if(session.GetTargetHandle())then
				tgt=world.GetActor(session.GetTargetHandle());
			end
			geMCC.UseSkill(actor, tgt, skillID);
			--geMCC.UseSkill(actor, tgt, skillID);
			--return;
		
	end

	local forpos = actor:GetFormationPos(mccIndex, 35.0);			
	geMCC.MoveTo(actor, forpos);		
	

end