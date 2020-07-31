-- autosavemoney
local addonName			= "AUTOSAVEMONEYRELOADED"
local addonNameLower	= string.lower(addonName)
local author			= "EBISUKE"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.notrans=false
local acutil = require('acutil')
local putItemTable
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName))
local LS=LIBSTORAGEHELPERV1_2
local function IsJpn()
	if (option.GetCurrentCountry() == "Japanese") then
        return true
    else
        return false
    end
end
local function L_(str)
	if(g.notrans)then
		return str
	end
	if(IsJpn() and AUTOSAVEMONEYRELOADED_LANGUAGE_DATA[str])then
		return AUTOSAVEMONEYRELOADED_LANGUAGE_DATA[str].jpn
	elseif (AUTOSAVEMONEYRELOADED_LANGUAGE_DATA[str] and AUTOSAVEMONEYRELOADED_LANGUAGE_DATA[str].eng)then
		return AUTOSAVEMONEYRELOADED_LANGUAGE_DATA[str].eng
	else
		return str
	end		
end
-- アイテムテーブル作成 ----------------------------------------------------------------------
function AUTOSAVEMONEY_ADDITEMTABLE()
	putItemTableT = {}
	putItemTableP = {}

	for i = 7,70 do
		if g.settings[1].teamflg then
			if g.settingsCommon[i].teamflg		then table.insert(putItemTableT, g.settingsCommon[i].date) end
			if g.settingsCommon[i].privateflg	then table.insert(putItemTableP, g.settingsCommon[i].date) end

		elseif g.settings[1].teamflg == false then
			if g.settings[i].teamflg			then table.insert(putItemTableT,g.settings[i].date) end
			if g.settings[i].privateflg			then table.insert(putItemTableP,g.settings[i].date) end	
		end
	end
end

-- 個別セーブ -----------------------------------------------------------------------------------
function AUTOSAVEMONEY_PRIVATESAVE()
	g.settingsFileLoc = string.format("../addons/%s/%s.json", addonNameLower, session.GetMySession():GetCID())
	local erase = {}
	acutil.saveJSON(g.settingsFileLoc, erase)
	acutil.saveJSON(g.settingsFileLoc, g.settings)

end

-- 共通セーブ
function AUTOSAVEMONEY_COMMONSAVE()
	g.settingsFileLocCommon = string.format("../addons/%s/%s.json", addonNameLower, "commonsetting")
	acutil.saveJSON(g.settingsFileLocCommon, g.settingsCommon)

end
-- 共通セーブ
function AUTOSAVEMONEY_ADDITIONALSAVE()
	g.settingsFileLocAddit = string.format("../addons/%s/%s.json", addonNameLower, "additionalsetting")
	acutil.saveJSON(g.settingsFileLocAddit, g.settingsAddit)

end
-- エラーチェック
-- function AUTOSAVEMONEY_PRIVATE_ERRORCHECK()
	-- local checkTable = g.settings[70].name				g.settingsの初期テーブルの最終行を入れる
-- end
-- function AUTOSAVEMONEY_COMMON_ERRORCHECK()
	-- local checkTable = g.settingsCommon[70].name		g.settingsCommonの初期テーブルの最終行を入れる pcall(AUTOSAVEMONEY_PRIVATE_ERRORCHECK)
-- end

-- 個別ロード -----------------------------------------------------------------------------------
function AUTOSAVEMONEY_PRIVATELOAD()
	local cid = session.GetMySession():GetCID()
	g.settingsFileLoc = string.format("../addons/%s/%s.json", addonNameLower, cid)
	local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

	if (err) then
		AUTOSAVEMONEY_FIRSTLOAD_SETTINGS()
		return
	end
	if t[70] == nil then
		AUTOSAVEMONEY_FIRSTLOAD_SETTINGS()
	else
		g.settings = t
	end
	--if pcall(AUTOSAVEMONEY_PRIVATE_ERRORCHECK) == false then
	--	AUTOSAVEMONEY_FIRSTLOAD_SETTINGS()
	--end
end

-- 共通ロード
function AUTOSAVEMONEY_COMMONLOAD()
	g.settingsFileLocCommon	= string.format("../addons/%s/%s.json", addonNameLower, "commonsetting")
	local t, err = acutil.loadJSON(g.settingsFileLocCommon, g.settingsCommon)

	if (err) then
		AUTOSAVEMONEY_FIRSTLOAD_COMMONSETTINGS()
		return
	end
	if t[70] == nil then
		AUTOSAVEMONEY_FIRSTLOAD_COMMONSETTINGS()
	else
		g.settingsCommon = t
	end


	--if pcall(AUTOSAVEMONEY_COMMON_ERRORCHECK) == false then
	--	AUTOSAVEMONEY_FIRSTLOAD_COMMONSETTINGS()
	--end
end

-- 共通(追加)ロード
function AUTOSAVEMONEY_ADDITIONALLOAD()
	g.settingsFileLocAddit	= string.format("../addons/%s/%s.json", addonNameLower, "additionalsetting")
	g.settingsAddit=g.settingsAddit or {}
	local t, err = acutil.loadJSON(g.settingsFileLocAddit, g.settingsAddit)

	if (err) then
		g.settingsAddit={}

	end
	-- versionup 
	g.settingsAddit.speed=g.settingsAddit.speed or 1.0

	--if pcall(AUTOSAVEMONEY_COMMON_ERRORCHECK) == false then
	--	AUTOSAVEMONEY_FIRSTLOAD_COMMONSETTINGS()
	--end
end


--デフォルト設定 --------------------------------------------------------------------------------
function AUTOSAVEMONEY_FIRSTLOAD_SETTINGS()
	if(not IsJpn())then
		g.settings = {
			
			[1]  = {name="Common";			teamflg=true;	privateflg=false;	date =0;		com ="Configs";		};
			[2]  = {name="CommonItem";		teamflg=true;	privateflg=false;	date =0;		com ="Storage options";		};	--中止
			[3]  = {name="Automode";		teamflg=false;	privateflg=false;	date =0;		com ="Deposit";		};
			[4]  = {name="Autopay";			teamflg=false;	privateflg=false;	date =0;		com ="Withdraw";		};
			[5]  = {name="Splitprice";		teamflg=false;	privateflg=false;	date =1000;		com ="Split";			};
			[6]  = {name="Thresholdprice";	teamflg=false;	privateflg=false;	date =500000;	com ="Base silver";		};
			[7]  = {name="Talt";			teamflg=false;	privateflg=false;	date =645268;	com ="Talt";			};
			[8]  = {name="Stone";			teamflg=false;	privateflg=false;	date =646045;	com ="Bless Gem";	};
			[9]  = {name="Piece";			teamflg=false;	privateflg=false;	date =645783;	com ="Bless Shard";	};
			[10] = {name="Spowder";			teamflg=false;	privateflg=false;	date =649026;	com ="Sierra Powder";	};
			[11] = {name="Npowder";			teamflg=false;	privateflg=false;	date =649025;	com ="Nucle powder";		};
			[12] = {name="RaidstoneR";		teamflg=false;	privateflg=false;	date =919024;	com ="Portal Stone Recipe";	};
			[13] = {name="Planium";			teamflg=false;	privateflg=false;	date =647024;	com ="Planium";	};
			[14] = {name="Uench";			teamflg=false;	privateflg=false;	date =699030;	com ="U. Enchant Jewel 410";	};
			[15] = {name="Rench";			teamflg=false;	privateflg=false;	date =699029;	com ="R. Enchant Jewel 410";	};
			[16] = {name="Uench440";		teamflg=false;	privateflg=false;	date =699025;	com ="U. Enchant Jewel 440";	};
			[17] = {name="Rench440";		teamflg=false;	privateflg=false;	date =699024;	com ="R. Enchant Jewel 440";	};
			[18] = {name="Opal";			teamflg=false;	privateflg=false;	date =649203;	com ="Opal";		};
			[19] = {name="Obsidian";		teamflg=false;	privateflg=false;	date =649205;	com ="Obsidian";	};
			[20] = {name="Garnet";			teamflg=false;	privateflg=false;	date =649204;	com ="Garnet";		};
			[21] = {name="Sapphire";		teamflg=false;	privateflg=false;	date =649216;	com ="Sapphire";		};
			[22] = {name="Zircon";			teamflg=false;	privateflg=false;	date =649207;	com ="Zircon";		};
			[23] = {name="Topaz";			teamflg=false;	privateflg=false;	date =649202;	com ="Topaz";		};
			[24] = {name="Peridot";			teamflg=false;	privateflg=false;	date =649206;	com ="Peridot";		};
			[25] = {name="Ruby";			teamflg=false;	privateflg=false;	date =649217;	com ="Ruby";			};
			[26] = {name="GoldING";			teamflg=false;	privateflg=false;	date =645257;	com ="Gold Bar";			};
			[27] = {name="SilverING";		teamflg=false;	privateflg=false;	date =645485;	com ="Silver Bar";			};
			[28] = {name="Mithril";			teamflg=false;	privateflg=false;	date =649004;	com ="Mithril Ore";	};
			[29] = {name="Absidium";		teamflg=false;	privateflg=false;	date =649016;	com ="Absidium";	};--クエっぽい？個人倉庫入らないらしい
			[30] = {name="Andesium";		teamflg=false;	privateflg=false;	date =649012;	com ="Andesium";	};
			[31] = {name="Arochium";		teamflg=false;	privateflg=false;	date =649015;	com ="Artilonium";	};
			[32] = {name="Ithildin";		teamflg=false;	privateflg=false;	date =649006;	com ="Ithildin Ore";		};
			[33] = {name="Urstar";			teamflg=false;	privateflg=false;	date =649028;	com ="Ultermite";	};
			[34] = {name="Teranium";		teamflg=false;	privateflg=false;	date =645694;	com ="Terranium";		};
			[35] = {name="Practnium";		teamflg=false;	privateflg=false;	date =649014;	com ="Practonium";	};
			[36] = {name="Fedesium";		teamflg=false;	privateflg=false;	date =649009;	com ="Phydecium";	};
			[37] = {name="Berinium";		teamflg=false;	privateflg=false;	date =649010;	com ="Ferinium";		};
			[38] = {name="Vertremin";		teamflg=false;	privateflg=false;	date =649027;	com ="Pheltremin";	};
			[39] = {name="Porchium";		teamflg=false;	privateflg=false;	date =649011;	com ="Portium";		};
			[40] = {name="ECard";			teamflg=false;	privateflg=false;	date =646071;	com ="Enhance Card:100";	};
			[41] = {name="TomePage";		teamflg=false;	privateflg=false;	date =2010001;	com ="M. Tome Page";	};
			[42] = {name="Pamoka";			teamflg=false;	privateflg=false;	date =699012;	com ="Full Pamoka";	};
			[43] = {name="Awak400";			teamflg=false;	privateflg=false;	date =647023;	com ="Awak Abrasive 400";	};
			[44] = {name="Awak430";			teamflg=false;	privateflg=false;	date =647040;	com ="Awak Abrasive 430";		};
			[45] = {name="GemAbrasive";		teamflg=false;	privateflg=false;	date =640264;	com ="Gem Abrasive Lv3";	};
			[46] = {name="MStone";			teamflg=false;	privateflg=false;	date =647011;	com ="Magic Stone";		};
			[47] = {name="Sandra1";			teamflg=false;	privateflg=false;	date =490271;	com ="Mysterious Magnifier";	};
			[48] = {name="Sandra2";			teamflg=false;	privateflg=false;	date =490272;	com ="Artisan Magnifier";		};
			[49] = {name="Sandra3";			teamflg=false;	privateflg=false;	date =494171;	com ="Detailed Magnifier";	};
			[50] = {name="Sandra4";			teamflg=false;	privateflg=false;	date =494105;	com ="Sandra Magnifier";	};
			[51] = {name="Free1";			teamflg=false;	privateflg=false;	date =0;		com ="Free 1 ";};
			[52] = {name="Free2";			teamflg=false;	privateflg=false;	date =0;		com ="Free 2 ";};
			[53] = {name="Free3";			teamflg=false;	privateflg=false;	date =0;		com ="Free 3 ";};
			[54] = {name="Free4";			teamflg=false;	privateflg=false;	date =0;		com ="Free 4 ";};
			[55] = {name="Free5";			teamflg=false;	privateflg=false;	date =0;		com ="Free 5 ";};
			[56] = {name="Free6";			teamflg=false;	privateflg=false;	date =0;		com ="Free 6 ";};
			[57] = {name="Free7";			teamflg=false;	privateflg=false;	date =0;		com ="Free 7 ";};
			[58] = {name="Free8";			teamflg=false;	privateflg=false;	date =0;		com ="Free 8 ";};
			[59] = {name="Free9";			teamflg=false;	privateflg=false;	date =0;		com ="Free 9 ";};
			[60] = {name="Free10";			teamflg=false;	privateflg=false;	date =0;		com ="Free 10";};
			[61] = {name="Free11";			teamflg=false;	privateflg=false;	date =0;		com ="Free 11";};
			[62] = {name="Free12";			teamflg=false;	privateflg=false;	date =0;		com ="Free 12";};
			[63] = {name="Free13";			teamflg=false;	privateflg=false;	date =0;		com ="Free 13";};
			[64] = {name="Free14";			teamflg=false;	privateflg=false;	date =0;		com ="Free 14";};
			[65] = {name="Free15";			teamflg=false;	privateflg=false;	date =0;		com ="Free 15";};
			[66] = {name="Free16";			teamflg=false;	privateflg=false;	date =0;		com ="Free 16";};
			[67] = {name="Free17";			teamflg=false;	privateflg=false;	date =0;		com ="Free 17";};
			[68] = {name="Free18";			teamflg=false;	privateflg=false;	date =0;		com ="Free 18";};
			[69] = {name="Free19";			teamflg=false;	privateflg=false;	date =0;		com ="Free 19";};
			[70] = {name="Free20";			teamflg=false;	privateflg=false;	date =0;		com ="Free 20";};

		};
	else
		g.settings = {
			[1]  = {name="Common";			teamflg=true;	privateflg=false;	date =0;		com ="設定";		};
			[2]  = {name="CommonItem";		teamflg=true;	privateflg=false;	date =0;		com ="倉庫 設定";		};	--中止
			[3]  = {name="Automode";		teamflg=false;	privateflg=false;	date =0;		com ="自動 入金";		};
			[4]  = {name="Autopay";			teamflg=false;	privateflg=false;	date =0;		com ="自動 出金";		};
			[5]  = {name="Splitprice";		teamflg=false;	privateflg=false;	date =1000;		com ="単位";			};
			[6]  = {name="Thresholdprice";	teamflg=false;	privateflg=false;	date =500000;	com ="基準金額";		};
			[7]  = {name="Talt";			teamflg=false;	privateflg=false;	date =645268;	com ="タルト";			};
			[8]  = {name="Stone";			teamflg=false;	privateflg=false;	date =646045;	com ="女神の祝福石";	};
			[9]  = {name="Piece";			teamflg=false;	privateflg=false;	date =645783;	com ="祝福された欠片";	};
			[10] = {name="Spowder";			teamflg=false;	privateflg=false;	date =649026;	com ="シエラパウダー";	};
			[11] = {name="Npowder";			teamflg=false;	privateflg=false;	date =649025;	com ="ﾆｭｰｸﾙﾊﾟｳﾀｰ";		};
			[12] = {name="RaidstoneR";		teamflg=false;	privateflg=false;	date =919024;	com ="レイドストーン書";	};
			[13] = {name="Planium";			teamflg=false;	privateflg=false;	date =647024;	com ="プレニウム";	};
			[14] = {name="Uench";			teamflg=false;	privateflg=false;	date =699030;	com ="Lv410ﾕﾆｰｸｴﾝﾁｬﾝﾄ";	};
			[15] = {name="Rench";			teamflg=false;	privateflg=false;	date =699029;	com ="Lv410ﾚｱｴﾝﾁｬﾝﾄ";	};
			[16] = {name="Uench440";		teamflg=false;	privateflg=false;	date =699025;	com ="Lv440ﾕﾆｰｸｴﾝﾁｬﾝﾄ";	};
			[17] = {name="Rench440";		teamflg=false;	privateflg=false;	date =699024;	com ="Lv440ﾚｱｴﾝﾁｬﾝﾄ";	};
			[18] = {name="Opal";			teamflg=false;	privateflg=false;	date =649203;	com ="オパール";		};
			[19] = {name="Obsidian";		teamflg=false;	privateflg=false;	date =649205;	com ="オブシディアン";	};
			[20] = {name="Garnet";			teamflg=false;	privateflg=false;	date =649204;	com ="ガーネット";		};
			[21] = {name="Sapphire";		teamflg=false;	privateflg=false;	date =649216;	com ="サファイア";		};
			[22] = {name="Zircon";			teamflg=false;	privateflg=false;	date =649207;	com ="ジルコン";		};
			[23] = {name="Topaz";			teamflg=false;	privateflg=false;	date =649202;	com ="トパーズ";		};
			[24] = {name="Peridot";			teamflg=false;	privateflg=false;	date =649206;	com ="ペリドット";		};
			[25] = {name="Ruby";			teamflg=false;	privateflg=false;	date =649217;	com ="ルビー";			};
			[26] = {name="GoldING";			teamflg=false;	privateflg=false;	date =645257;	com ="金塊";			};
			[27] = {name="SilverING";		teamflg=false;	privateflg=false;	date =645485;	com ="銀塊";			};
			[28] = {name="Mithril";			teamflg=false;	privateflg=false;	date =649004;	com ="ミスリル鉱石";	};
			[29] = {name="Absidium";		teamflg=false;	privateflg=false;	date =649016;	com ="アブシディウム";	};--クエっぽい？個人倉庫入らないらしい
			[30] = {name="Andesium";		teamflg=false;	privateflg=false;	date =649012;	com ="アンデシウム";	};
			[31] = {name="Arochium";		teamflg=false;	privateflg=false;	date =649015;	com ="アチロニウム";	};
			[32] = {name="Ithildin";		teamflg=false;	privateflg=false;	date =649006;	com ="ｲｼﾙﾃﾞｨﾝ鉱石";		};
			[33] = {name="Urstar";			teamflg=false;	privateflg=false;	date =649028;	com ="ｳﾙｽﾀｰﾏｲﾄ";	};
			[34] = {name="Teranium";		teamflg=false;	privateflg=false;	date =645694;	com ="テラニウム";		};
			[35] = {name="Practnium";		teamflg=false;	privateflg=false;	date =649014;	com ="プラクトニウム";	};
			[36] = {name="Fedesium";		teamflg=false;	privateflg=false;	date =649009;	com ="フィデシウム";	};
			[37] = {name="Berinium";		teamflg=false;	privateflg=false;	date =649010;	com ="ベリニウム";		};
			[38] = {name="Vertremin";		teamflg=false;	privateflg=false;	date =649027;	com ="ベルトレミン";	};
			[39] = {name="Porchium";		teamflg=false;	privateflg=false;	date =649011;	com ="ポルチウム";		};
			[40] = {name="ECard";			teamflg=false;	privateflg=false;	date =646071;	com ="強化用カード：100";	};
			[41] = {name="TomePage";		teamflg=false;	privateflg=false;	date =2010001;	com ="神秘の書のﾍﾟｰｼﾞ";	};
			[42] = {name="Pamoka";			teamflg=false;	privateflg=false;	date =699012;	com ="充填済ﾌｧﾓｶ";	};
			[43] = {name="Awak400";			teamflg=false;	privateflg=false;	date =647023;	com ="Lv400覚醒研磨剤";	};
			[44] = {name="Awak430";			teamflg=false;	privateflg=false;	date =647040;	com ="Lv430覚醒研磨剤";		};
			[45] = {name="GemAbrasive";		teamflg=false;	privateflg=false;	date =640264;	com ="3星ジェム研磨材";	};
			[46] = {name="MStone";			teamflg=false;	privateflg=false;	date =647011;	com ="魔精石";		};
			[47] = {name="Sandra1";			teamflg=false;	privateflg=false;	date =490271;	com ="不思議なルーペ";	};
			[48] = {name="Sandra2";			teamflg=false;	privateflg=false;	date =490272;	com ="職人のルーペ";		};
			[49] = {name="Sandra3";			teamflg=false;	privateflg=false;	date =494171;	com ="ｻﾝﾄﾞﾗ微細鑑定ﾙｰﾍﾟ";	};
			[50] = {name="Sandra4";			teamflg=false;	privateflg=false;	date =494105;	com ="ｻﾝﾄﾞﾗ鑑定ﾙｰﾍﾟ";	};
			[51] = {name="Free1";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 1 ";};
			[52] = {name="Free2";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 2 ";};
			[53] = {name="Free3";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 3 ";};
			[54] = {name="Free4";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 4 ";};
			[55] = {name="Free5";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 5 ";};
			[56] = {name="Free6";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 6 ";};
			[57] = {name="Free7";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 7 ";};
			[58] = {name="Free8";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 8 ";};
			[59] = {name="Free9";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 9 ";};
			[60] = {name="Free10";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 10";};
			[61] = {name="Free11";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 11";};
			[62] = {name="Free12";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 12";};
			[63] = {name="Free13";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 13";};
			[64] = {name="Free14";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 14";};
			[65] = {name="Free15";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 15";};
			[66] = {name="Free16";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 16";};
			[67] = {name="Free17";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 17";};
			[68] = {name="Free18";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 18";};
			[69] = {name="Free19";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 19";};
			[70] = {name="Free20";			teamflg=false;	privateflg=false;	date =0;		com ="フリー 20";};

		};
	end
	AUTOSAVEMONEY_PRIVATESAVE()
	CHAT_SYSTEM(L_("It is the first time the add-on [autosave money] is activated, or updated {nl} Default settings loaded."))
end
--デフォルト設定 --------------------------------------------------------------------------------
function AUTOSAVEMONEY_FIRSTLOAD_COMMONSETTINGS()
	
	g.settingsCommon = g.settings

	AUTOSAVEMONEY_COMMONSAVE()
	CHAT_SYSTEM(L_("Common settings loaded."))
end

-- 読み込み --------------------------------------------------------------------------------
function AUTOSAVEMONEY_ON_INIT(addon, frame)
		g.settings = {}
	--ロード：個別
		ReserveScript("AUTOSAVEMONEY_PRIVATELOAD()", 3);
		ReserveScript("AUTOSAVEMONEY_COMMONLOAD()" , 3.5);
		ReserveScript("AUTOSAVEMONEY_ADDITIONALLOAD()" ,4);
		ReserveScript("AUTOSAVEMONEY_ADDITEMTABLE()" , 4.5);
		addon:RegisterMsg("GAME_START","AUTOSAVEMONEY_GAME_START")
	--ボタン作成
		local rtCtrl = {
			[1]  = 	{name="ASM_OPENPRIVATE_BTN";	left=530;	frame="accountwarehouse";	msg="OPEN_DLG_ACCOUNTWAREHOUSE";	call="AUTOSAVEMONEY_ACT";};
			[2]  = 	{name="ASM_OPENTEAM_BTN";		left=500;	frame="warehouse";		 	msg="OPEN_DLG_WAREHOUSE";			call="AUTOSAVEITEM_ACT";};
			};

		for i, ver in ipairs(rtCtrl) do
			local frame = ui.GetFrame(rtCtrl[i].frame)
			local asm_setting_btn = frame:CreateOrGetControl("button", rtCtrl[i].name, rtCtrl[i].left, 80, 130, 30);
				asm_setting_btn = tolua.cast(asm_setting_btn, "ui::CButton");
				asm_setting_btn:SetText(L_("ASM settings"));
				asm_setting_btn:SetEventScript(ui.LBUTTONDOWN, "AUTOSAVEMONEY_OPEN_SETTING");
				addon:RegisterMsg(rtCtrl[i].msg, rtCtrl[i].call)
		end

end
function AUTOSAVEMONEY_GAME_START()
	LS=LIBSTORAGEHELPERV1_2
end
-- キャラクター倉庫処理 --------------------------------------------------------------------------------
function AUTOSAVEITEM_ACT()
	ReserveScript("AUTOSAVEMONEY_ITEM_TO_CHRWAREHOUSE()" , 0.5);
end

function AUTOSAVEMONEY_ACT()
		ReserveScript("AUTOSAVEMONEY_MONEY_TO_WAREHOUSE()" , 0.8);
	ReserveScript("AUTOSAVEMONEY_ITEM_TO_WAREHOUSE()" , 1.4);

end

-- 入出金処理 -------------------------------------------------------------------------------------------
function AUTOSAVEMONEY_MONEY_TO_WAREHOUSE(frame)
	local totalMoney = GET_TOTAL_MONEY()
	local splitPrice
	local thresholdPrice
	local setPrice
	local afterMoney
	local autoSaveFlg
	local autoPayFlg

	if g.settings[1].teamflg then
		splitPrice		= g.settingsCommon[5].date
		thresholdPrice	= g.settingsCommon[6].date
		autoSaveFlg		= g.settingsCommon[3].teamflg
		autoPayFlg		= g.settingsCommon[4].teamflg
	else
		splitPrice		= g.settings[5].date
		thresholdPrice	= g.settings[6].date
		autoSaveFlg		= g.settings[3].teamflg
		autoPayFlg		= g.settings[4].teamflg

	end

	local frame			= ui.GetFrame("accountwarehouse")
	local logBox		= GET_CHILD(frame,  "logbox")
	local depBox		= GET_CHILD(logBox, "DepositSkin")
	local setCTRL		= GET_CHILD(depBox, "moneyInput", "ui::CEditControl")
	
	--入金
	if totalMoney >= (thresholdPrice + splitPrice) then
		setPrice = math.floor((totalMoney-thresholdPrice)/splitPrice)*splitPrice
		setCTRL:SetText(setPrice)

		if autoSaveFlg then
			ACCOUNT_WAREHOUSE_DEPOSIT(frame)
		
			afterMoney = GET_TOTAL_MONEY()
			if afterMoney ~= totalMoney then
				CHAT_SYSTEM(string.format(L_("[Automatic deposit: %s] %s silver{/}"),info.GetName(session.GetMyHandle()),GetCommaedText(setPrice)))
			end
		end

	--出金
	elseif (thresholdPrice - splitPrice) >= totalMoney then
		setPrice	= math.floor((thresholdPrice-totalMoney+splitPrice)/splitPrice)*splitPrice
		setCTRL:SetText(setPrice);

		if autoPayFlg then
			ACCOUNT_WAREHOUSE_WITHDRAW(frame)

			afterMoney = GET_TOTAL_MONEY()
			if afterMoney ~= totalMoney then
				CHAT_SYSTEM(string.format(L_("[Automatic withdrawal: %s] %s silver{/}"),info.GetName(session.GetMyHandle()),GetCommaedText(setPrice)))
			end
		end
	end	
end

-- アイテム処理 -------------------------------------------------------------------------------------------
function AUTOSAVEMONEY_ITEM_TO_WAREHOUSE_CHECK(itemID, itemCount, itemName, itemIcon, checkFlg)
	local findItem = 0
	if session.GetInvItemByGuid(itemID) ~= nil then
		findItem = 1;
	end
	local warehouseName
	if checkFlg == "T" then
		warehouseName = L_("Team storage")
	elseif checkFlg == "P" then
		warehouseName = L_("Personal storage")
	end
	if findItem == 0 then
		warehouseName = L_("[Item deposit: ") .. warehouseName .. "]"
	elseif findItem >= 1 then
        warehouseName = L_("[Failed to deposit: ") .. warehouseName .. "]"
	end

	CHAT_SYSTEM(warehouseName .. "{img " .. itemIcon .. " 18 18} " .. itemName .. ": " ..itemCount .. L_(" pieces"))

end

function isPutItem(itemID, warehouseFlg)

	if warehouseFlg == "T" then
		putItemTable = putItemTableT
	elseif warehouseFlg == "P" then
		putItemTable = putItemTableP
	end

	for i, putItemID in ipairs(putItemTable) do
		if itemID == putItemID then
			return true
		end
	end
	
	return false
end

-- function AUTOSAVEMONEY_GET_EXIST_INDEX(insertItem)
--     local ret1 = false
--     local ret2 = -1
    
--     if geItemTable.IsStack(insertItem.ClassID) == 1 then
--         local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)    
--         local sortedGuidList = itemList:GetSortedGuidList()  
--         local sortedCnt = sortedGuidList:Count()
        
--         for i = 0, sortedCnt - 1 do
--             local guid = sortedGuidList:Get(i)
--             local invItem = itemList:GetItemByGuid(guid)
--             local invItem_obj = GetIES(invItem:GetObject())
--             if insertItem.ClassID == invItem_obj.ClassID then
--                 ret1 = true
--                 ret2 = invItem.invIndex
--                 break
--             end
--         end
--         return ret1, ret2
--     else
--         return false, -1
--     end
-- end

-- function AUTOSAVEMONEY_GET_VALIDINDEX()
-- 	local current_tab_index = 0;
-- 	local max_slot_per_tab = account_warehouse.get_max_slot_per_tab();
-- 	local account = session.barrack.GetMyAccount();
--     local slotCount = account:GetAccountWarehouseSlotCount();
--     local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
--     local guidList = itemList:GetGuidList();
--     local sortedGuidList = itemList:GetSortedGuidList();    
--     local sortedCnt = sortedGuidList:Count();    
    
--     local start_index = (current_tab_index * max_slot_per_tab)
--     local last_index = (start_index + max_slot_per_tab) -1
    
--     local __set = {}
--     for i = 0, sortedCnt - 1 do
--         local guid = sortedGuidList:Get(i)
--         local invItem = itemList:GetItemByGuid(guid)
--         local obj = GetIES(invItem:GetObject());
--         if obj.ClassName ~= MONEY_NAME then
--             if start_index <= invItem.invIndex and invItem.invIndex <= last_index and __set[invItem.invIndex] == nil then
--                 __set[invItem.invIndex] = 1
--             end
--         end
--     end

--     local index = start_index
--     for k, v in pairs(__set) do
--         if __set[index] ~= 1 then
--             break
--         else
--             index = index + 1
--         end
--     end
-- 	if index == (slotCount) then
-- 		index = 70
-- 		for k, v in pairs(__set) do
-- 			if __set[index] ~= 1 then
-- 				break
-- 			else
-- 				index = index + 1
-- 			end
-- 		end
--     end
    
--     return index
-- end

function _AUTOSAVEMONEY_ITEM_TO_WAREHOUSE(iesID,count,name)
	-- local inItem = GetObjectByGuid(iesID)
	-- local WHindex = AUTOSAVEMONEY_GET_VALIDINDEX()
	-- local exist, index = AUTOSAVEMONEY_GET_EXIST_INDEX(inItem)
	-- if exist == true and index >= 0 then
    --     WHindex = index;
    -- end
	-- local frame = ui.GetFrame("accountwarehouse")
	-- item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesID, count, frame:GetUserIValue("HANDLE"), WHindex);
	LS.target=IT_ACCOUNT_WAREHOUSE
	LS.putitem(iesID,count,true)
end

function AUTOSAVEMONEY_ITEM_TO_WAREHOUSE(frame)
	local wframe = ui.GetFrame("accountwarehouse")
	local create_CTRL	= wframe:CreateOrGetControl("richtext", "ASM_LOAD_LBL", 560, 110, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{#ff0000}{s14}{ol}" .. "Depositing..." .. "{/}");
	
	local delayCount = 0
	local invList = session.GetInvItemList()
	FOR_EACH_INVENTORY(invList, function(invList, invItem)
			if invItem ~= nil then
				local itemObj = GetIES(invItem:GetObject())
				if isPutItem(itemObj.ClassID,"T") then
					ReserveScript( string.format("_AUTOSAVEMONEY_ITEM_TO_WAREHOUSE(\"%s\",%d,\"%s\")",  invItem:GetIESID(), invItem.count,itemObj.Name) , delayCount*g.settingsAddit.speed)
					delayCount = delayCount + 1
					ReserveScript( string.format("AUTOSAVEMONEY_ITEM_TO_WAREHOUSE_CHECK(\"%s\",%d,\"%s\",\"%s\",\"%s\")",  invItem:GetIESID(), invItem.count, itemObj.Name, itemObj.Icon, "T") , delayCount*g.settingsAddit.speed+1)
				end
			end
		end, false)
	ReserveScript(string.format("AUTOSAVEMONEY_COMPLETETXT()") , (delayCount*g.settingsAddit.speed+2))
end

function AUTOSAVEMONEY_COMPLETETXT()
	local wframe = ui.GetFrame("accountwarehouse")
	local create_CTRL	= wframe:CreateOrGetControl("richtext", "ASM_LOAD_LBL", 585, 110, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{#2D9B27}{s14}{ol}" .. "OK!" .. "{/}");
	AUTOSAVEMONEY_MONEY_TO_WAREHOUSE();
end

function _AUTOSAVEMONEY_ITEM_TO_CHRWAREHOUSE(iesID,count,name)
	--item.PutItemToWarehouse(IT_WAREHOUSE, iesID, count, frame2:GetUserIValue("HANDLE"));
	LS.target=IT_WAREHOUSE
	
	LS.putitem(iesID,count,true)
end

function AUTOSAVEMONEY_ITEM_TO_CHRWAREHOUSE(frame)
	local delayCount = 0
	local invList = session.GetInvItemList()
	FOR_EACH_INVENTORY(invList, function(invList, invItem)
			if invItem ~= nil then
				local itemObj = GetIES(invItem:GetObject())
				if isPutItem(itemObj.ClassID,"P") then
					ReserveScript( string.format("_AUTOSAVEMONEY_ITEM_TO_CHRWAREHOUSE(\"%s\",%d,\"%s\")",  invItem:GetIESID(), invItem.count,itemObj.Name) , delayCount*g.settingsAddit.speed)
					delayCount = delayCount + 1
					ReserveScript( string.format("AUTOSAVEMONEY_ITEM_TO_WAREHOUSE_CHECK(\"%s\",%d,\"%s\",\"%s\",\"%s\")", invItem:GetIESID(), invItem.count, itemObj.Name, itemObj.Icon, "P") , delayCount*g.settingsAddit.speed+1)
				end
			end
		end, false)
end

-- 設定フレーム --------------------------------------------------------------------------
function AUTOSAVEMONEY_OPEN_SETTING(frame)
	local frame = ui.GetFrame("autosavemoney")
	if frame:IsVisible() == 1 then
		ui.CloseFrame("autosavemoney")
		return
	end

	AUTOSAVEMONEY_OPEN_SETTING_FRAME(frame)

	frame:ShowWindow(1)
end

function AUTOSAVEMONEY_CLOSE_SETTING_FRAME()
	ui.CloseFrame("autosavemoney")
end

function AUTOSAVEMONEY_OPEN_SETTING_FRAME(frame)
	local bg_gbox = GET_CHILD(frame, "bg", "ui::CGroupBox")
	local asmmenu_gbox = GET_CHILD(bg_gbox, "asmmenu_gbox", "ui::CGroupBox")
		  asmmenu_gbox = tolua.cast(asmmenu_gbox, "ui::CGroupBox")
		  asmmenu_gbox:SetScrollBar(asmmenu_gbox:GetHeight())

	local asmmenu_list = GET_CHILD(bg_gbox, "asmmenu_gbox", "ui::CGroupBox")
	asmmenu_list = tolua.cast(asmmenu_list, "ui::CGroupBox")

		local rtCtrlBTN		= {}
		local rtCtrlCHKT	= {}
		local rtCtrlCHKP	= {}
		local rtCtrlEDITD	= {}
		local rtCtrlEDITA	= {}
		local rtCtrlLBLT	= {}
		local rtCtrlLBLP	= {}
		local tAdd			= {tchk=false, ptchk=false, body="", com=""}

	--使用設定
	local flowLTWH = {l=25,t=10,w=100}

	for ic = 1,1 do
		rtCtrlBTN[ic]  = {name="ASM_".. g.settings[ic].name .."_BTN";	left=flowLTWH.l;		top=flowLTWH.t;		w=flowLTWH.w;	h=25;	body=g.settings[ic].com;		fnc=""};
		rtCtrlCHKT[ic] = {name="ASM_".. g.settings[ic].name .."_CHKT";	left=flowLTWH.l+146;	top=flowLTWH.t-3;	w=30;			h=30;	body="";						fnc="ASM_TOGGLECHECKT"..ic};
		rtCtrlCHKP[ic] = {name="ASM_".. g.settings[ic].name .."_CHKP";	left=flowLTWH.l+216;	top=flowLTWH.t-3;	w=30;			h=30;	body="";						fnc="ASM_TOGGLECHECKP"..ic};
		rtCtrlLBLT[ic] = {name="ASM_".. g.settings[ic].name .."_LBLT";	left=flowLTWH.l+105;	top=flowLTWH.t+1;	w=30;			h=30;	body=L_(" all");					fnc=""};
		rtCtrlLBLP[ic] = {name="ASM_".. g.settings[ic].name .."_LBLP";	left=flowLTWH.l+175;	top=flowLTWH.t+1;	w=30;			h=30;	body=L_("char");					fnc=""};
		flowLTWH.t = flowLTWH.t + 30

		--button
			local create_CTRL = asmmenu_list:CreateOrGetControl("button", rtCtrlBTN[ic].name, rtCtrlBTN[ic].left, rtCtrlBTN[ic].top, rtCtrlBTN[ic].w, rtCtrlBTN[ic].h)
			tolua.cast(create_CTRL, "ui::CButton")
			create_CTRL:SetText(rtCtrlBTN[ic].body)

		--check box / team
			create_CTRL	= asmmenu_list:CreateOrGetControl("checkbox", rtCtrlCHKT[ic].name, rtCtrlCHKT[ic].left, rtCtrlCHKT[ic].top, rtCtrlCHKT[ic].w, rtCtrlCHKT[ic].h)
			tolua.cast(create_CTRL, "ui::CCheckBox");
			create_CTRL:SetClickSound("button_click_big");
			create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
			create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
			create_CTRL:SetOverSound("button_over");
			create_CTRL:SetEventScript(ui.LBUTTONUP, rtCtrlCHKT[ic].fnc);
			create_CTRL:SetUserValue("NUMBER", 1);

			if g.settings[ic].teamflg then
				create_CTRL:SetCheck(1)
			else
				create_CTRL:SetCheck(0)
			end

		--check box / private
			create_CTRL	= asmmenu_list:CreateOrGetControl("checkbox", rtCtrlCHKP[ic].name, rtCtrlCHKP[ic].left, rtCtrlCHKP[ic].top, rtCtrlCHKP[ic].w, rtCtrlCHKP[ic].h)
			tolua.cast(create_CTRL, "ui::CCheckBox");
			create_CTRL:SetClickSound("button_click_big");
			create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
			create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
			create_CTRL:SetOverSound("button_over");
			create_CTRL:SetEventScript(ui.LBUTTONUP, rtCtrlCHKP[ic].fnc);
			create_CTRL:SetUserValue("NUMBER", 1);

			if g.settings[ic].teamflg then
				create_CTRL:SetCheck(0)
			else
				create_CTRL:SetCheck(1)
			end

		--label
			create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", rtCtrlLBLT[ic].name, rtCtrlLBLT[ic].left, rtCtrlLBLT[ic].top, rtCtrlLBLT[ic].w, rtCtrlLBLT[ic].h)
			tolua.cast(create_CTRL, "ui::CRichText");
			create_CTRL:SetText("{@st43}{s18}" .. rtCtrlLBLT[ic].body .. "{/}");

			create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", rtCtrlLBLP[ic].name, rtCtrlLBLP[ic].left, rtCtrlLBLP[ic].top, rtCtrlLBLP[ic].w, rtCtrlLBLP[ic].h)
			tolua.cast(create_CTRL, "ui::CRichText");
			create_CTRL:SetText("{@st43}{s18}" .. rtCtrlLBLP[ic].body .. "{/}");
	end


	--銀行設定
	flowLTWH = {l=308,t=10,w=100,h=25}
	for icq = 3,4 do
		if g.settings[1].teamflg then
			tAdd.tchk = g.settingsCommon[icq].teamflg
			tAdd.com  = g.settingsCommon[icq].com
		else
			tAdd.tchk = g.settings[icq].teamflg
			tAdd.com  = g.settings[icq].com
		end 

		rtCtrlBTN[icq]  = 	{name="ASM_".. g.settings[icq].name .."_BTN";	left=flowLTWH.l;		top=flowLTWH.t;		w=flowLTWH.w;	h=flowLTWH.h;	body=tAdd.com;	fnc=""};
		rtCtrlCHKT[icq] = 	{name="ASM_".. g.settings[icq].name .."_CHKT";	left=flowLTWH.l+101;	top=flowLTWH.t-3;	w=30;			h=30;			body=tAdd.tchk; fnc=""};
		flowLTWH.t = flowLTWH.t + 30

	--button
		local create_CTRL = asmmenu_list:CreateOrGetControl("button", rtCtrlBTN[icq].name, rtCtrlBTN[icq].left, rtCtrlBTN[icq].top, rtCtrlBTN[icq].w, rtCtrlBTN[icq].h)
		tolua.cast(create_CTRL, "ui::CButton")
		create_CTRL:SetEventScript(ui.LBUTTONDOWN, rtCtrlBTN[icq].fnc)
		create_CTRL:SetText(rtCtrlBTN[icq].body)
	--check box / team
		create_CTRL	= asmmenu_list:CreateOrGetControl("checkbox", rtCtrlCHKT[icq].name, rtCtrlCHKT[icq].left, rtCtrlCHKT[icq].top, rtCtrlCHKT[icq].w, rtCtrlCHKT[icq].h)
		tolua.cast(create_CTRL, "ui::CCheckBox");
		create_CTRL:SetClickSound("button_click_big");
		create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
		create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
		create_CTRL:SetOverSound("button_over");
		create_CTRL:SetEventScript(ui.LBUTTONUP, rtCtrlCHKT[icq].fnc);
		create_CTRL:SetUserValue("NUMBER", 1);
		if tAdd.tchk then
			create_CTRL:SetCheck(1)
		else
			create_CTRL:SetCheck(0)
		end

	end

	flowLTWH = {l=455,t=10,w=92,h=25}
	for icr = 5,6 do
		if g.settings[1].teamflg then
			tAdd.com  = g.settingsCommon[icr].com
			tAdd.body = g.settingsCommon[icr].date
		else
			tAdd.com  = g.settings[icr].com
			tAdd.body = g.settings[icr].date
		end 

		rtCtrlBTN[icr]  = 	{name="ASM_".. g.settings[icr].name .."_BTN";	left=flowLTWH.l;	top=flowLTWH.t; w=flowLTWH.w; h=flowLTWH.h; body=tAdd.com;	fnc=""};
		rtCtrlEDITD[icr]  = {name="ASM_".. g.settings[icr].name .."_EDITD"; left=flowLTWH.l+98; top=flowLTWH.t; w=flowLTWH.w; h=flowLTWH.h; body=tAdd.body;	fnc=""};
		flowLTWH.t = flowLTWH.t + 30

		--button
			local create_CTRL = asmmenu_list:CreateOrGetControl("button", rtCtrlBTN[icr].name, rtCtrlBTN[icr].left, rtCtrlBTN[icr].top, rtCtrlBTN[icr].w, rtCtrlBTN[icr].h)
			tolua.cast(create_CTRL, "ui::CButton")
			create_CTRL:SetEventScript(ui.LBUTTONDOWN, rtCtrlBTN[icr].fnc)
			create_CTRL:SetFontName("white_16_ol")
			create_CTRL:SetText(rtCtrlBTN[icr].body)
		--edit box
			create_CTRL = asmmenu_list:CreateOrGetControl("edit", rtCtrlEDITD[icr].name, rtCtrlEDITD[icr].left, rtCtrlEDITD[icr].top, rtCtrlEDITD[icr].w, rtCtrlEDITD[icr].h)
			tolua.cast(create_CTRL, "ui::CEditControl")
			create_CTRL:MakeTextPack()
			create_CTRL:SetTextAlign("center", "center")
			create_CTRL:SetSkinName("systemmenu_vertical")
			create_CTRL:SetFontName("white_16_ol")
			create_CTRL:SetText(rtCtrlEDITD[icr].body)
	end

	-- カテゴリ１//よく使うもの
	flowLTWH = {l=25,t=100,w=160,h=25}
	for ica = 7,50 do
		if g.settings[1].teamflg then
			tAdd.tchk = g.settingsCommon[ica].teamflg
			tAdd.pchk = g.settingsCommon[ica].privateflg
			tAdd.com  = g.settingsCommon[ica].com
		else
			tAdd.tchk = g.settings[ica].teamflg
			tAdd.pchk = g.settings[ica].privateflg
			tAdd.com  = g.settings[ica].com
		end 

		rtCtrlBTN[ica]   = {name="ASM_".. g.settings[ica].name .."_BTN";	left=flowLTWH.l;		top=flowLTWH.t;		w=flowLTWH.w;	h=flowLTWH.h;	body=tAdd.com;		fnc=""};
		rtCtrlCHKT[ica]  = {name="ASM_".. g.settings[ica].name .."_CHKT";	left=flowLTWH.l+162;	top=flowLTWH.t-2;	w=30;			h=30;			body=tAdd.tchk;		fnc=""};
		rtCtrlCHKP[ica]  = {name="ASM_".. g.settings[ica].name .."_CHKP";	left=flowLTWH.l+187;	top=flowLTWH.t-2;	w=30;			h=30;			body=tAdd.pchk;	fnc=""};
		flowLTWH.t = flowLTWH.t + 30

	-- category2 / 宝石
		if ica == 17 then
			flowLTWH = {l=260,t=100,w=160,h=25}
		end
	-- category3 / 鉱石
		if ica == 28 then
			flowLTWH = {l=495,t=100,w=160,h=25}
		end
	-- category4 / 380武器素材
		if ica == 39 then
			flowLTWH = {l=730,t=100,w=160,h=25}
		end

	--ボタン
		local create_CTRL = asmmenu_list:CreateOrGetControl("button", rtCtrlBTN[ica].name, rtCtrlBTN[ica].left, rtCtrlBTN[ica].top, rtCtrlBTN[ica].w, rtCtrlBTN[ica].h)
		tolua.cast(create_CTRL, "ui::CButton")
		create_CTRL:SetEventScript(ui.LBUTTONDOWN, rtCtrlBTN[ica].fnc)
		create_CTRL:SetText(rtCtrlBTN[ica].body)

	--check box / team
		local create_CTRL	= asmmenu_list:CreateOrGetControl("checkbox", rtCtrlCHKT[ica].name, rtCtrlCHKT[ica].left, rtCtrlCHKT[ica].top, rtCtrlCHKT[ica].w, rtCtrlCHKT[ica].h)
		tolua.cast(create_CTRL, "ui::CCheckBox");
		create_CTRL:SetClickSound("button_click_big");
		create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
		create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
		create_CTRL:SetOverSound("button_over");
		create_CTRL:SetEventScript(ui.LBUTTONUP, rtCtrlCHKT[ica].fnc);
		create_CTRL:SetUserValue("NUMBER", 1);
		if tAdd.tchk then
			create_CTRL:SetCheck(1)
		else
			create_CTRL:SetCheck(0)
		end

	--check box / private
		local create_CTRL	= asmmenu_list:CreateOrGetControl("checkbox", rtCtrlCHKP[ica].name, rtCtrlCHKP[ica].left, rtCtrlCHKP[ica].top, rtCtrlCHKP[ica].w, rtCtrlCHKP[ica].h)
		tolua.cast(create_CTRL, "ui::CCheckBox");
		create_CTRL:SetClickSound("button_click_big");
		create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
		create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
		create_CTRL:SetOverSound("button_over");
		create_CTRL:SetEventScript(ui.LBUTTONUP, rtCtrlCHKP[ica].fnc);
		create_CTRL:SetUserValue("NUMBER", 1);
		if tAdd.pchk then
			create_CTRL:SetCheck(1)
		else
			create_CTRL:SetCheck(0)
		end
	end

		-- category6 / フリー１～１０
		flowLTWH = {l=25,t=455,w=65,h=25}
		for icb = 51,70 do
			if g.settings[1].teamflg then
				tAdd.tchk = g.settingsCommon[icb].teamflg
				tAdd.pchk = g.settingsCommon[icb].privateflg
				tAdd.body = g.settingsCommon[icb].date
				tAdd.com  = g.settingsCommon[icb].com
			else
				tAdd.tchk = g.settings[icb].teamflg
				tAdd.pchk = g.settings[icb].privateflg
				tAdd.body = g.settings[icb].date
				tAdd.com  = g.settings[icb].com
			end 

			rtCtrlEDITD[icb] = {name="ASM_".. g.settings[icb].name .."_EDITD";	left=flowLTWH.l;		top=flowLTWH.t;		w=flowLTWH.w;		h=flowLTWH.h;	body=tAdd.body;		fnc="ADD_FREETXT"..icb -50};
			rtCtrlEDITA[icb] = {name="ASM_".. g.settings[icb].name .."_EDITA";	left=flowLTWH.l+70;		top=flowLTWH.t;		w=flowLTWH.w+220;	h=flowLTWH.h;	body=tAdd.com;		fnc="ADD_FREETXT"..icb-50};
			rtCtrlCHKT[icb]  = {name="ASM_".. g.settings[icb].name .."_CHKT";	left=flowLTWH.l+360;	top=flowLTWH.t-4;	w=30;				h=30;			body=tAdd.tchk;		fnc=""};
			rtCtrlCHKP[icb]  = {name="ASM_".. g.settings[icb].name .."_CHKP";	left=flowLTWH.l+385;	top=flowLTWH.t-4;	w=30;				h=30;			body=tAdd.pchk;		fnc=""};
			rtCtrlBTN[icb]   = {name="ASM_".. g.settings[icb].name .."_BTN";	left=flowLTWH.l+328;	top=flowLTWH.t-2;	w=30;				h=flowLTWH.h+2;	body="C";			fnc="ADD_FREETXTCLEAR"..icb -50};
			flowLTWH.t = flowLTWH.t + 30

		-- category7 / フリー１１～２０
			if icb == 60 then
				flowLTWH = {l=495,t=455,w=65,h=25}
			end

	--check box / team
		local create_CTRL	= asmmenu_list:CreateOrGetControl("checkbox", rtCtrlCHKT[icb].name, rtCtrlCHKT[icb].left, rtCtrlCHKT[icb].top, rtCtrlCHKT[icb].w, rtCtrlCHKT[icb].h)
		tolua.cast(create_CTRL, "ui::CCheckBox");
		create_CTRL:SetClickSound("button_click_big");
		create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
		create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
		create_CTRL:SetOverSound("button_over");
		create_CTRL:SetEventScript(ui.LBUTTONUP, rtCtrlCHKT[icb].fnc);
		create_CTRL:SetUserValue("NUMBER", 1);
		if tAdd.tchk then
			create_CTRL:SetCheck(1)
		else
			create_CTRL:SetCheck(0)
		end


	--check box / private
		create_CTRL	= asmmenu_list:CreateOrGetControl("checkbox", rtCtrlCHKP[icb].name, rtCtrlCHKP[icb].left, rtCtrlCHKP[icb].top, rtCtrlCHKP[icb].w, rtCtrlCHKP[icb].h)
		tolua.cast(create_CTRL, "ui::CCheckBox");
		create_CTRL:SetClickSound("button_click_big");
		create_CTRL:SetAnimation("MouseOnAnim",  "btn_mouseover");
		create_CTRL:SetAnimation("MouseOffAnim", "btn_mouseoff");
		create_CTRL:SetOverSound("button_over");
		create_CTRL:SetEventScript(ui.LBUTTONUP, rtCtrlCHKP[icb].fnc);
		create_CTRL:SetUserValue("NUMBER", 1);
		if tAdd.pchk then
			create_CTRL:SetCheck(1)
		else
			create_CTRL:SetCheck(0)
		end

	--item ID
		create_CTRL = asmmenu_list:CreateOrGetControl("edit", rtCtrlEDITD[icb].name, rtCtrlEDITD[icb].left, rtCtrlEDITD[icb].top, rtCtrlEDITD[icb].w, rtCtrlEDITD[icb].h)
		tolua.cast(create_CTRL, "ui::CEditControl");
		create_CTRL:MakeTextPack();
		create_CTRL:SetTextAlign("center", "center");
		create_CTRL:SetFontName("white_16_ol");
		create_CTRL:SetSkinName("systemmenu_vertical");
		create_CTRL:SetEventScript(ui.DROP,rtCtrlEDITD[icb].fnc)
		create_CTRL:SetText(rtCtrlEDITD[icb].body)

	--item Name
		create_CTRL= asmmenu_list:CreateOrGetControl("edit", rtCtrlEDITA[icb].name, rtCtrlEDITA[icb].left, rtCtrlEDITA[icb].top, rtCtrlEDITA[icb].w, rtCtrlEDITA[icb].h)
		tolua.cast(create_CTRL, "ui::CEditControl");
		create_CTRL:MakeTextPack();
		create_CTRL:SetTextAlign("left", "left");
		create_CTRL:SetFontName("white_16_ol");
		create_CTRL:SetSkinName("systemmenu_vertical");
		create_CTRL:SetEventScript(ui.DROP,rtCtrlEDITD[icb].fnc)
		create_CTRL:SetText(rtCtrlEDITA[icb].body)

	--clear
		local create_CTRL = asmmenu_list:CreateOrGetControl("button", rtCtrlBTN[icb].name, rtCtrlBTN[icb].left, rtCtrlBTN[icb].top, rtCtrlBTN[icb].w, rtCtrlBTN[icb].h)
		tolua.cast(create_CTRL, "ui::CButton")
		create_CTRL:SetEventScript(ui.LBUTTONDOWN, rtCtrlBTN[icb].fnc)
		create_CTRL:SetText(rtCtrlBTN[icb].body)
	end

	create_CTRL = asmmenu_list:CreateOrGetControl("button", "ASM_SAVE_BTN", 700, 35, 165, 30)
	tolua.cast(create_CTRL, "ui::CButton")
	create_CTRL:SetEventScript(ui.LBUTTONDOWN, "ASM_SETTING_SAVE")
	create_CTRL:SetText(L_("Save"))

	create_CTRL = asmmenu_list:CreateOrGetControl("button", "ASM_CLOSE_BTN", 700, 0, 165, 30)
	tolua.cast(create_CTRL, "ui::CButton")
	create_CTRL:SetEventScript(ui.LBUTTONDOWN, "AUTOSAVEMONEY_CLOSE_SETTING_FRAME")
	create_CTRL:SetText(L_("Exit"))


	create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", "ASM_CATEGORY1_LBL", 180, 83, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{@st43}{s12}" .. L_("Team/Personal").. "{/}");
	
	create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", "ASM_CATEGORY2_LBL", 415, 83, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{@st43}{s12}" .. L_("Team/Personal").. "{/}");
	
	create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", "ASM_CATEGORY3_LBL", 650, 83, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{@st43}{s12}" .. L_("Team/Personal").. "{/}");
	
	create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", "ASM_CATEGORY4_LBL", 885, 83, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{@st43}{s12}" .. L_("Team/Personal").. "{/}");
	
	create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", "ASM_CATEGORY5_LBL", 375, 438, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{@st43}{s12}" .. L_("Team/Personal") .. "{/}");
	
		create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", "ASM_CATEGORY6_LBL", 800, 438, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{@st43}{s12}" .. L_("Team/Personal") .. "{/}");
	
		create_CTRL	= asmmenu_list:CreateOrGetControl("richtext", "ASM_CATEGORY7_LBL", 25, 438, 20, 20)
	tolua.cast(create_CTRL, "ui::CRichText");
	create_CTRL:SetText("{@st43}{s12}" .. L_("CUSTOM: enter ID or Drag&Drop") .. "{/}");


	local obj_picture = frame:CreateOrGetControl("picture", "ASM_OBJ_PICTURE", 850, 0, 128, 128);
	tolua.cast(obj_picture, "ui::CPicture");
	obj_picture:SetEventScript(ui.DROP,"TESTMSG")
	obj_picture:SetImage("medeina_emotion02");

	local title = GET_CHILD(bg_gbox, "title", "ui::CRichText");
	title:SetText("{@st68b}{s18}addon : Autosave Money Reloaded ver.: 2.1.0 Settings {/}{/}");
	asmmenu_gbox:ShowWindow(1);

	--搬入速度
	local flowLTWH = {l=25,t=80,w=100}
	local create_CTRL = frame:CreateOrGetControl("button","ASM_INTERVAL_BTN",flowLTWH.l,flowLTWH.t,flowLTWH.w,30)
	tolua.cast(create_CTRL, "ui::CButton")
	create_CTRL:SetText("{@st43}{s16}" ..L_("Interval"))

	create_CTRL = frame:CreateOrGetControl("edit","ASM_INTERVAL",flowLTWH.l+flowLTWH.w+20,flowLTWH.t,flowLTWH.w,30)
	tolua.cast(create_CTRL, "ui::CEditControl")
	create_CTRL:SetText(tostring(g.settingsAddit.speed))
	create_CTRL:SetTextAlign("center", "center")
	create_CTRL:SetSkinName("systemmenu_vertical")
	create_CTRL:SetFontName("white_16_ol")
end	

-- 共通設定のトグルチェック --------------------------------------------------------------------
function ASM_TOGGLECHECKT1(frame) ASM_TGGLECHECK(frame, 1,"T","P") end
function ASM_TOGGLECHECKP1(frame) ASM_TGGLECHECK(frame, 1,"P","T") end
function ASM_TOGGLECHECKT2(frame) ASM_TGGLECHECK(frame, 2,"T","P") end
function ASM_TOGGLECHECKP2(frame) ASM_TGGLECHECK(frame, 2,"P","T") end

function ASM_TGGLECHECK(frame,ctrlName,flgA,flgB)
local chkFlg

	if GET_CHILD(frame, "ASM_" .. g.settings[ctrlName].name .. "_CHK" .. flgA):IsChecked() == 1 then
		GET_CHILD(frame, "ASM_" .. g.settings[ctrlName].name .. "_CHK" .. flgB):SetCheck(0)
		if flgA == "T" then
			chkFlg = true
		else
			chkFlg = false
		end
	elseif GET_CHILD(frame, "ASM_" .. g.settings[ctrlName].name .. "_CHK" .. flgA):IsChecked() == 0 then
		GET_CHILD(frame, "ASM_" .. g.settings[ctrlName].name .. "_CHK" .. flgB):SetCheck(1)
		if flgA == "T" then
			chkFlg = false
		else
			chkFlg = true
		end
	end

	if chkFlg then
		--ロード：共通設定
		AUTOSAVEMONEY_COMMONLOAD()
		ReserveScript("AUTOSAVEMONEY_ADDITEMTABLE()" , 3);
		ui.MsgBox(L_("[Common] setting loaded"))

		for i = 3,70 do
			if i == 5 or i == 6 then
				GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_EDITD"):SetText(g.settingsCommon[i].date)

			else
				if g.settingsCommon[i].teamflg then
					GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKT"):SetCheck(1)
				else
					GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKT"):SetCheck(0)
				end
	
				if i >= 7 then
					if g.settingsCommon[i].privateflg then
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKP"):SetCheck(1)
					else
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKP"):SetCheck(0)
					end
				end
				
				if i >= 51 then
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_EDITD"):SetText(g.settingsCommon[i].date)
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_EDITA"):SetText(g.settingsCommon[i].com)
				end
			end
		end

	else
		--ロード：個人設定
			AUTOSAVEMONEY_PRIVATELOAD()
			AUTOSAVEMONEY_ADDITEMTABLE()
			ui.MsgBox(L_("[Character] setting loaded"))

		for i = 3,70 do
			if i == 5 or i == 6 then
				GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_EDITD"):SetText(g.settings[i].date)

			else
				if g.settings[i].teamflg then
					GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKT"):SetCheck(1)
				else
					GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKT"):SetCheck(0)
				end
	
				if i >= 7 then
					if g.settings[i].privateflg then
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKP"):SetCheck(1)
					else
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_CHKP"):SetCheck(0)
					end
				end
				
				if i >= 51 then
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_EDITD"):SetText(g.settings[i].date)
						GET_CHILD(frame, "ASM_" .. g.settings[i].name .. "_EDITA"):SetText(g.settings[i].com)
				end
			end
		end
	end

end

--アイテムＩＤと名称を返す
function GET_ITEMID(parent)
	local frame = parent:GetTopParentFrame();
	local liftIcon = ui.GetLiftIcon()
	local iconInfo = liftIcon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
	local obj = GetIES(invItem:GetObject());

	local itemID = {Name=obj.Name; ClassID=obj.ClassID;}
	
	return itemID;
end

-- Ｄ＆Ｄ処理 -------------------------------------------------------------------------
function ADD_FREETXT1(frame,parent) EDIT_TXTBOX(frame,parent,1) end
function ADD_FREETXT2(frame,parent) EDIT_TXTBOX(frame,parent,2) end
function ADD_FREETXT3(frame,parent) EDIT_TXTBOX(frame,parent,3) end
function ADD_FREETXT4(frame,parent) EDIT_TXTBOX(frame,parent,4) end
function ADD_FREETXT5(frame,parent) EDIT_TXTBOX(frame,parent,5) end
function ADD_FREETXT6(frame,parent) EDIT_TXTBOX(frame,parent,6) end
function ADD_FREETXT7(frame,parent) EDIT_TXTBOX(frame,parent,7) end
function ADD_FREETXT8(frame,parent) EDIT_TXTBOX(frame,parent,8) end
function ADD_FREETXT9(frame,parent) EDIT_TXTBOX(frame,parent,9) end
function ADD_FREETXT10(frame,parent) EDIT_TXTBOX(frame,parent,10) end
function ADD_FREETXT11(frame,parent) EDIT_TXTBOX(frame,parent,11) end
function ADD_FREETXT12(frame,parent) EDIT_TXTBOX(frame,parent,12) end
function ADD_FREETXT13(frame,parent) EDIT_TXTBOX(frame,parent,13) end
function ADD_FREETXT14(frame,parent) EDIT_TXTBOX(frame,parent,14) end
function ADD_FREETXT15(frame,parent) EDIT_TXTBOX(frame,parent,15) end
function ADD_FREETXT16(frame,parent) EDIT_TXTBOX(frame,parent,16) end
function ADD_FREETXT17(frame,parent) EDIT_TXTBOX(frame,parent,17) end
function ADD_FREETXT18(frame,parent) EDIT_TXTBOX(frame,parent,18) end
function ADD_FREETXT19(frame,parent) EDIT_TXTBOX(frame,parent,19) end
function ADD_FREETXT20(frame,parent) EDIT_TXTBOX(frame,parent,20) end

function EDIT_TXTBOX(frame,parent,editNo)
	local itemID		= GET_ITEMID(parent)
	local bg_gbox		= GET_CHILD(parent:GetTopParentFrame(), "bg", "ui::CGroupBox");
	local asmmenu_list	= GET_CHILD(bg_gbox, "asmmenu_gbox", "ui::CGroupBox");

	local txtBoxName = "ASM_Free".. editNo .. "_EDITD"
	local editName = GET_CHILD(asmmenu_list, txtBoxName, "ui::CEditControl")
	editName:SetText(itemID.ClassID)

	editName = GET_CHILD(asmmenu_list, "ASM_Free" .. editNo .. "_EDITA", "ui::CEditControl")
	editName:SetText(itemID.Name)

end

-- クリア処理 -------------------------------------------------------------------------
function ADD_FREETXTCLEAR1(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,1) end
function ADD_FREETXTCLEAR2(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,2) end
function ADD_FREETXTCLEAR3(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,3) end
function ADD_FREETXTCLEAR4(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,4) end
function ADD_FREETXTCLEAR5(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,5) end
function ADD_FREETXTCLEAR6(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,6) end
function ADD_FREETXTCLEAR7(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,7) end
function ADD_FREETXTCLEAR8(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,8) end
function ADD_FREETXTCLEAR9(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,9) end
function ADD_FREETXTCLEAR10(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,10) end
function ADD_FREETXTCLEAR11(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,11) end
function ADD_FREETXTCLEAR12(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,12) end
function ADD_FREETXTCLEAR13(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,13) end
function ADD_FREETXTCLEAR14(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,14) end
function ADD_FREETXTCLEAR15(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,15) end
function ADD_FREETXTCLEAR16(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,16) end
function ADD_FREETXTCLEAR17(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,17) end
function ADD_FREETXTCLEAR18(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,18) end
function ADD_FREETXTCLEAR19(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,19) end
function ADD_FREETXTCLEAR20(frame,parent) EDIT_TXTBOXCLEAR(frame,parent,20) end

function EDIT_TXTBOXCLEAR(frame,parent,editNo)
	local bg_gbox = GET_CHILD(parent:GetTopParentFrame(), "bg", "ui::CGroupBox");
	local asmmenu_list = GET_CHILD(bg_gbox, "asmmenu_gbox", "ui::CGroupBox");

	local txtBoxName = "ASM_Free".. editNo .. "_EDITD"

	local editName = GET_CHILD(asmmenu_list, txtBoxName, "ui::CEditControl")
	editName:SetText(0)

	editName = GET_CHILD(asmmenu_list, "ASM_Free" .. editNo .. "_EDITA", "ui::CEditControl")
	editName:SetText(L_("Free ")..editNo)

end

--所持金 -------------------------------------------------------------------------
function GET_TOTAL_MONEY()
    local Cron = 0;
    local invItem = session.GetInvItemByName('Vis');
    if invItem ~= nil then
        Cron = invItem.count;
    end

    return Cron;
 end

function ASM_SETTING_CLOSE(frame)
	AUTOSAVEMONEY_CLOSE_SETTING_FRAME()
end

--保存設定 -------------------------------------------------------------------------
function ASM_SETTING_SAVE(frame)

	g.settingsAddit.speed=math.min(10.0,math.max(0.0,tonumber(ui.GetFrame("autosavemoney"):GetChild("ASM_INTERVAL"):GetText()) or 1.0))

	--共通
	if GET_CHILD(frame, "ASM_".. g.settings[1].name .."_CHKT"):IsChecked() == 1 then
		g.settings[1].teamflg = true
		AUTOSAVEMONEY_PRIVATESAVE()

		for i = 3,70 do
			if i == 5 or i == 6 then
				if tonumber(GET_CHILD(frame, "ASM_".. g.settingsCommon[i].name .."_EDITD"):GetText()) >= 1 then
					g.settingsCommon[i].date = tonumber(GET_CHILD(frame, "ASM_".. g.settingsCommon[i].name .."_EDITD"):GetText())
				end
			else
				if GET_CHILD(frame, "ASM_".. g.settingsCommon[i].name .."_CHKT"):IsChecked() == 1 then
					g.settingsCommon[i].teamflg = true
				else
					g.settingsCommon[i].teamflg = false
				end
	
				if i >= 7 then
					if GET_CHILD(frame, "ASM_".. g.settingsCommon[i].name .."_CHKP"):IsChecked() == 1 then
						g.settingsCommon[i].privateflg = true
					else
						g.settingsCommon[i].privateflg = false
					end
				end
				
				if i >= 51 then
					if tonumber(GET_CHILD(frame, "ASM_".. g.settingsCommon[i].name .."_EDITD"):GetText()) >= 0 then
						g.settingsCommon[i].date	= tonumber(GET_CHILD(frame, "ASM_".. g.settingsCommon[i].name .."_EDITD"):GetText())
						g.settingsCommon[i].com		= tostring(GET_CHILD(frame, "ASM_".. g.settingsCommon[i].name .."_EDITA"):GetText())
					end
				end
			end
		end
	
		AUTOSAVEMONEY_COMMONSAVE()
		AUTOSAVEMONEY_ADDITEMTABLE()
		AUTOSAVEMONEY_COMMONLOAD()
		ui.MsgBox(L_("AutosaveMoney:[Common] setting saved"))
		CHAT_SYSTEM(L_("AutosaveMoney:[Common] setting saved"))

	elseif GET_CHILD(frame, "ASM_".. g.settings[1].name .."_CHKT"):IsChecked() == 0 then
	--個別
		for i = 3,70 do
			if i == 5 or i == 6 then
				if tonumber(GET_CHILD(frame, "ASM_".. g.settings[i].name .."_EDITD"):GetText()) >= 1 then
					g.settings[i].date	=	tonumber(GET_CHILD(frame, "ASM_".. g.settings[i].name .."_EDITD"):GetText())
				end
			else

				if GET_CHILD(frame, "ASM_".. g.settings[i].name .."_CHKT"):IsChecked() == 1 then
					g.settings[i].teamflg = true
				else
					g.settings[i].teamflg = false
				end
	
				if i >= 7 then
					if GET_CHILD(frame, "ASM_".. g.settings[i].name .."_CHKP"):IsChecked() == 1 then
						g.settings[i].privateflg = true
					else
						g.settings[i].privateflg = false
					end
				end
				
				if i >= 51 then
					if tonumber(GET_CHILD(frame, "ASM_".. g.settings[i].name .."_EDITD"):GetText()) >= 0 then
						g.settings[i].date	= tonumber(GET_CHILD(frame, "ASM_".. g.settings[i].name .."_EDITD"):GetText())
						g.settings[i].com		= tostring(GET_CHILD(frame, "ASM_".. g.settings[i].name .."_EDITA"):GetText())
					end
				end
			end
		end

		g.settings[1].teamflg = false
		AUTOSAVEMONEY_PRIVATESAVE()
		AUTOSAVEMONEY_ADDITEMTABLE()
		AUTOSAVEMONEY_PRIVATELOAD()
		ui.MsgBox(L_("AutosaveMoney:[Character] setting saved"))
		CHAT_SYSTEM(L_("AutosaveMoney:[Character] setting saved"))
		


	end
	--共通設定があるので、共通も保存
	AUTOSAVEMONEY_ADDITIONALSAVE()
	AUTOSAVEMONEY_ADDITIONALLOAD()
	AUTOSAVEMONEY_CLOSE_SETTING_FRAME()
end