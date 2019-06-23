_G.ADDONS = _G.ADDONS or {};
_G.ADDONS.YYU = _G.ADDONS.YYU or {};
_G.ADDONS.YYU.UNBUFF = _G.ADDONS.YYU.UNBUFF or {};
_G.ADDONS.YYU.UNBUFF.Version = '1.1.4';
(function(g)
	-- Skill Tables
	g.skillTable = g.skillTable or {};
	g.targetBuffIDTable = g.targetBuffIDTable or {};
	g.defaultModes = g.defaultModes or {}; -- '0':disable, '1': always, '2': under cooldown
	g.addUnbuffTable = function(name, classID, buffID, defaultMode)
		name = string.lower(name);
		g.skillTable[name] =classID;
		g.targetBuffIDTable[classID] = buffID;
		g.defaultModes[classID] = defaultMode;
	end
	g.addUnbuffTable("summoning",   20701, 3038, '0');
	g.addUnbuffTable("levitation",  21107, 3070, '1');
	g.addUnbuffTable("transpose",   20504,  167, '1');
	-- g.addUnbuffTable('deedsofvalor',11001,   46, '0');
	g.addUnbuffTable('cassiscrista',11301, 3033, '0');
	g.addUnbuffTable('thurisaz'		,21303, 1040, '1');
	g.addUnbuffTable('genbuarmor'		,21611, 2145, '1');
	-- g.addUnbuffTable('fanaticism'		,41704, 2014, '0');
	function g.hook(frame, slot, ...)
		if GetCraftState() == 1 then
			return;
		end

		tolua.cast(slot, 'ui::CSlot');
		local icon = slot:GetIcon();
		if icon == nil then
			return;
		end

		local iconInfo = icon:GetInfo();
		if iconInfo:GetCategory() == 'Skill' then
			local skillInfo = session.GetSkill(iconInfo.type);
			local skl = GetIES(skillInfo:GetObject());
			local mode = g.getMode(skl.ClassID);
			if mode == '1' or (mode == '2' and skillInfo:GetCurrentCoolDownTime() ~= 0) then
				local buffID = g.getBuffID(skl);
				if buffID ~= nil then
					packet.ReqRemoveBuff(buffID);
					return;
				end
			end
		end

		g.oldHook(frame, slot, ...)
	end


	function g.getBuffIDTraceOff(skl)
		local targetBuffID = g.targetBuffIDTable[skl.ClassID];
		if skl ~= nil and g.hasBuff(targetBuffID) then
			return targetBuffID;
		end

		return nil;
	end


	function g.getBuffIDTraceOn(skl)

		if skl ~= nil then
			local log = '[Unbuff] TRACE INFO{nl}';
			log = log .. 'SkillName:' .. skl.ClassName .. '{nl}';
			log = log .. 'SkillID:' .. skl.ClassID .. '{nl}';

			local handle = session.GetMyHandle();
			for i = 0, info.GetBuffCount(handle) - 1 do
				local buff = info.GetBuffIndexed(handle, i);
				log = log .. ' Buff ID at ' .. i .. ' = ' .. buff.buffID .. '{nl}';
			end
			
			CHAT_SYSTEM(log);
		end

		return g.getBuffIDTraceOff(skl);
	end


	function g.unbuffByBuffID(buffID)
		if buffID ~= nil and g.hasBuff(buffID) then
			packet.ReqRemoveBuff(buffID);
		end
	end


	function g.unbuffBySkillClassID(skillClassID)
		g.unbuffByBuffID(g.getBuffIDTraceOff({ ClassID = skillClassID }));
	end


	function g.hasBuff(targetBuffID)
		if targetBuffID ~= nil then
			local handle = session.GetMyHandle();
			for i = 0, info.GetBuffCount(handle) - 1 do
				if targetBuffID == info.GetBuffIndexed(handle, i).buffID then
					return true;
				end
			end
		end

		return false;
	end


	function g.skillClassIDFromName(nameLowerCase)
		for name, classID in pairs(g.skillTable) do
			if string.find(name, nameLowerCase, 1, true) == 1 then
				return classID, name;
			end
		end
		
		return nil;
	end


	function g.commandHandler(commands)
		local g = _G.ADDONS.YYU.UNBUFF;
		local arg = string.lower(commands[1] or '');

		if arg == 'mode' then
			local mode = commands[2] or '';
			mode = #mode == 1 and tonumber(mode) or nil;
			local skillClassID, name = g.skillClassIDFromName(string.lower(commands[3] or ''));
			if mode ~= nil and 0 <= mode and mode <= 2 then
				if skillClassID ~= nil then
					g.setMode(skillClassID, mode);
					CHAT_SYSTEM('[Unbuff] set ' .. name .. ' mode ' .. mode);
				end
			end

		elseif arg == 'traceon' then
			g.getBuffID = g.getBuffIDTraceOn;
			CHAT_SYSTEM('[Unbuff] Trace ON.');

		elseif arg == 'traceoff' then
			g.getBuffID = g.getBuffIDTraceOff;
			CHAT_SYSTEM('[Unbuff] Trace OFF.');

		else
			local buffID = tonumber(arg);
			if buffID ~= nil then
				g.unbuffByBuffID(buffID);
			else
				g.unbuffBySkillClassID(g.skillClassIDFromName(arg));
			end
		end
	end


	function g.setMode(skillClassID, mode)
		mode = #tostring(mode) == 1 and tonumber(mode) or nil;
		if mode ~= nil and 0 <= mode and mode <= 2 then
			g.store.set('mode_' .. skillClassID, tostring(mode));
		else
			CHAT_SYSTEM('[Unbuff]ERROR:Invalid mode');
		end
	end


	function g.getMode(skillClassID)
		local mode = g.store.get('mode_' .. skillClassID);
		if #mode == 0 then
			mode = g.defaultModes[skillClassID];
			if mode ~= nil then
				g.setMode(skillClassID, mode);
			end
		end
		return mode;
	end



	if _G.UNBUFF_ON_INIT ~= nil then
		CHAT_SYSTEM('[Unbuff] WARNING: UNBUFF_ON_INIT is defined.');
	end

	function _G.UNBUFF_ON_INIT(addon, frame)
		if g.oldHook == nil then
			-- Setup Hook
			g.oldHook = _G.QUICKSLOTNEXPBAR_SLOT_USE;
			_G.QUICKSLOTNEXPBAR_SLOT_USE = function(...) g.hook(...) end;
			g.getBuffID = g.getBuffIDTraceOff;

			-- Setup Slash Command
			_G.ADDONS.YYU.Util.slashCommand('/unbuff', g.commandHandler);
			
			-- Others
			g.store = _G.ADDONS.YYU.Util.File.sharedSimpleStore('unbuff');
			CHAT_SYSTEM('Unbuff ' .. g.Version .. ' loaded.');
		end
	end
end)(_G.ADDONS.YYU.UNBUFF);
