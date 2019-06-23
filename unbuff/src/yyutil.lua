_G.ADDONS = _G.ADDONS or {};
_G.ADDONS.YYU = _G.ADDONS.YYU or {};
_G.ADDONS.YYU.Util = _G.ADDONS.YYU.Util or {};
(function(YYUtil)
	local VERSION = 4;
	if YYUtil.version == nil or YYUtil.version < VERSION then
		YYUtil.version = VERSION;
	else
		return;
	end

	----------
	-- File --
	----------
	YYUtil.File = YYUtil.File or {};
	
	function YYUtil.File.createAddonFolder(addonName)
		os.execute('mkdir ..\\addons\\' .. addonName);
	end
	
	function YYUtil.File.write(addonName, relativePath, text)
		local file, error = io.open('../addons/' .. addonName .. '/' .. relativePath, 'w')
		if error then
			return nil, error;
		end

		file:write(text);
		file:close();
	end
	
	function YYUtil.File.read(addonName, relativePath)
		local file, error = io.open('../addons/' .. addonName .. '/' .. relativePath, 'r');
		if error then
			return nil, error;
		end
		
		local ret = file:read("*all");
		file:close();
		return ret;
	end

	----------------------------
	-- File.createSimpleStore --
	----------------------------
	YYUtil.File.sharedSimpleStores = YYUtil.File.sharedSimpleStores or {}
	
	function YYUtil.File.sharedSimpleStore(addonName)
		local store = YYUtil.File.sharedSimpleStores[addonName];
		if store == nil then
			store = YYUtil.File.createSimpleStore(addonName);
			YYUtil.File.sharedSimpleStores[addonName] = store;
		end
		return store;
	end
	
	function YYUtil.File.createSimpleStore(addonName)
		local File = YYUtil.File;

		local ret = {};
		local cache = {};
		local savedCache = {};
		
		ret.set = function(key, text, _unsave)
			if (cache[key] or savedCache[key]) ~= text then
				if _unsave == true then
					cache[key] = text;
					savedCache[key] = nil;
				else
					cache[key] = nil;
					savedCache[key] = text;
					File.write(addonName, key .. '.txt', text);
				end
			end
		end
		
		ret.get = function(key)
			local data = cache[key] or savedCache[key];
			if data ~= nil then return data; end
			return File.read(addonName, key .. '.txt') or '';
		end
		
		ret.flush = function()
			for k,v in pairs(cache) do
				local unused, error = File.write(addonName, k .. '.txt', v);
				if error == nil then
					cache[k] = nil;
					savedCache[k] = v;
				end
			end
		end
		
		ret.dump = function()
			local ret = '[cache]';
			for k,v in pairs(cache) do
				ret = ret .. k .. '=' .. v .. ',';
			end
			ret = ret .. '[savedCache]';
			for k,v in pairs(savedCache) do
				ret = ret .. k .. '=' .. v .. ',';
			end
			CHAT_SYSTEM(ret);
			return ret;
		end
		
		-- create addon directory
		local data, error = File.read(addonName, '.simplestore');
		if error ~= nil then
			File.createAddonFolder(addonName);
			File.write(addonName, '.simplestore', '');
		end

		ret.addonName = addonName;
		ret.cache = cache;
		ret.savedCache = savedCache;
		
		return ret;
	end

	-----------
	-- proxy --
	-----------
	function YYUtil.intercept(obj, key, prev, post)
		local fn = obj[key];
		obj[key] = function(...)
			if type(prev) == 'function' and prev(...) then
				-- ignore original function if prev returns true
				return;
			end
			local ret = fn(...);
			if type(post) == 'function' then
				post(...);
			end
			return ret;
		end
	end

	function YYUtil.hook(obj, key, prev, post)
		if type(prev) == 'function' then
			local a = obj[key];
			obj[key] = function(...)
				return a(prev(...))
			end
		end
		
		if type(post) == 'function' then
			local b = obj[key];
			obj[key] = function(...)
				return post(b(...));
			end
		end
	end

	-------------------
	-- slashCommands --
	-------------------
	YYUtil.slashCommands = {};

	--if pcall(function() require('acutil') end) then
	--	YYUtil.slashCommand = function(cmd, fn)
	--		require('acutil').slashCommand(cmd, fn);
	--	end
	--else
			YYUtil.slashCommand = function(cmd, fn)
				if cmd:sub(1,1) ~= "/" then cmd = "/" .. cmd end
				YYUtil.slashCommands[cmd] = fn;
			end
	--end

	YYUtil.UI_CHAT_HOOKED = function(msg)
		-- refer: https://github.com/Tree-of-Savior-Addon-Community/AC-Util/blob/master/src/cwapi.lua
		local words = {};
		for w in msg:gmatch('%S+') do table.insert(words, w) end
		
		local cmd = table.remove(words, 1);
		if #words ~= 0 and #cmd == 2 and string.find(cmd, '^/[gprswy]') == 1 then
			cmd = table.remove(words, 1);
		end

		local fn = YYUtil.slashCommands[cmd];
		if fn == nil then

			YYUtil.UI_CHAT_ORIGINAL(msg);
		else
			fn(words);
		
			-- close chat
			local chatFrame = GET_CHATFRAME();
			local edit = chatFrame:GetChild('mainchat');
			chatFrame:ShowWindow(0);
			edit:ShowWindow(0);
			ui.CloseFrame("chat_option");
			ui.CloseFrame("chat_emoticon");
		end
	end

	-- hook
	if YYUtil.UI_CHAT_ORIGINAL == nil then
		YYUtil.UI_CHAT_ORIGINAL = _G.UI_CHAT;
		_G.UI_CHAT = function(...)
			 YYUtil.UI_CHAT_HOOKED(...);
		end
	end
end)(_G.ADDONS.YYU.Util);

