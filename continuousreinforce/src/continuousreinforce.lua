
CONTINUOUSREINFORCE_VALUES={
	moru=nil,
	item=nil,
	morustate=false,
	moruplace=false
}

function EBI_stringstartswith(String,Start)
	return string.sub(String,1,string.len(Start))==Start
 end
function EBI_try_catch(what)
	local status, result = pcall(what.try)
	if not status then
		what.catch(result)
	end
	return result
end

function CONTINUOUSREINFORCE_ON_INIT(addon, frame)
	-- if(OLD_REINFORCE_131014_MSGBOX==nil and CONTINUOUSREINFORCE_REINFORCE_JUMPER~=OLD_REINFORCE_131014_MSGBOX)then
	-- 	OLD_REINFORCE_131014_MSGBOX=REINFORCE_131014_MSGBOX;
	-- 	REINFORCE_131014_MSGBOX=CONTINUOUSREINFORCE_REINFORCE_JUMPER
	-- end
	if (OLD_REINFORCE_131014_EXEC==nil and CONTINUOUSREINFORCE_REINFORCE_EXEC_JUMPER~=OLD_REINFORCE_131014_EXEC)then
		OLD_REINFORCE_131014_EXEC=REINFORCE_131014_EXEC;
		REINFORCE_131014_EXEC=CONTINUOUSREINFORCE_REINFORCE_EXEC_JUMPER
	end
	CHAT_SYSTEM("[CR]init")
end

-- function CONTINUOUSREINFORCE_REINFORCE_JUMPER(frame)
-- 	if(OLD_REINFORCE_131014_MSGBOX~=nil)then
-- 		OLD_REINFORCE_131014_MSGBOX(frame)
-- 	end
-- 	CONTINUOUSREINFORCE_REINFORCE(frame)
-- end
-- function CONTINUOUSREINFORCE_REINFORCE(frame)
-- 	CONTINUOUSREINFORCE_VALUES.moru,CONTINUOUSREINFORCE_VALUES.item = GET_REINFORCE_TARGET_AND_MORU(frame);
-- 	local fromItemObj = GetIES(fromItem:GetObject());
-- 	local moruObj = GetIES(fromMoru:GetObject());
-- 	CHAT_SYSTEM("moru")
-- end
function CONTINUOUSREINFORCE_REINFORCE_EXEC_JUMPER(checkReuildFlag)
	CONTINUOUSREINFORCE_REINFORCE_EXEC(checkReuildFlag)
	if(OLD_REINFORCE_131014_EXEC~=nil)then
		OLD_REINFORCE_131014_EXEC(checkReuildFlag)
	end

end

function CONTINUOUSREINFORCE_REINFORCE_EXEC(checkReuildFlag)
	EBI_try_catch{
		try=function()
			local frame = ui.GetFrame("reinforce_131014");
			CONTINUOUSREINFORCE_VALUES.item, CONTINUOUSREINFORCE_VALUES.moru = REINFORCE_131014_GET_ITEM(frame);
			if(CONTINUOUSREINFORCE_VALUES.morustate==false)then
				CONTINUOUSREINFORCE_VALUES.morustate=true
				CHAT_SYSTEM("[CR]連続強化を開始します。やめるときはESCを押してください。")
				ReserveScript("CONTINUOUSREINFORCE_STARTTIMER()",1.5)
			--	CONTINUOUSREINFORCE_STARTTIMER();

				ReserveScript("ui.SetEscapeScp(\"CONTINUOUSREINFORCE_MORUCANCEL()\")",0.05)
			end
		end,
		catch=function(error)
			CHAT_SYSTEM(error)
		end
	}


end
function CONTINUOUSREINFORCE_STARTTIMER()
	local frame=ui.GetFrame("continuousreinforce");
	frame:ShowWindow(1)
	local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");

	timer:SetUpdateScript("CONTINUOUSREINFORCE_MORUCHECK_DELAY");
	timer:Start(0.01);
end
function CONTINUOUSREINFORCE_MORUCHECK_DELAY(frame, timer, str, num, totalTime)
	--print("delay"..tostring(totalTime))

	ReserveScript("CONTINUOUSREINFORCE_MORUCHECK()",0.01)
	
end
function CONTINUOUSREINFORCE_MORUCHECK()
	EBI_try_catch{
		try=function()
			if(CONTINUOUSREINFORCE_VALUES.morustate==false )then
				return
			end
		--moruしているアイテムがロック状態か調べる
			local fromItem, fromMoru = CONTINUOUSREINFORCE_VALUES.item, CONTINUOUSREINFORCE_VALUES.moru
			if(fromItem==nil or fromMoru==nil) then
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end

			if keyboard.IsKeyPressed('ESCAPE') == 1 then
				CONTINUOUSREINFORCE_MORUCANCEL()
				return;
			end

			if(CONTINUOUSREINFORCE_VALUES.moruplace==true)then
				return
			end

			local i=0;
			local hnd=0;
			local hnd2="";
			local itm=nil;
			local tgt=nil;
			local actr=nil;
			local mon=nil;
			
			local myPC = GetMyPCObject();
			local myHnd=session.GetMyHandle();
			--近くに自分の金床があるかチェック
			local fndList, fndCount = SelectObject(self, 100, 'ALL');
			local myName=world.GetActor(myHnd)

			
			for i = 1, fndCount do
				itm		= fndList[i];
				hnd		= GetHandle(itm);
				actr	= world.GetActor(hnd);
				mon		= GetClassByType("Monster", actr:GetType());
			
					if(itm.ClassID==41432 or itm.ClassID==47412)then

						print("hp"..tostring(itm.HP))
						if(actr:GetName():match(myName:GetName())and itm.HP>0)then
							--anvilある

							return
						end
					end


			end
			if(GetIES(fromItem:GetObject())==nil)then
				--アイテムを喪失した
				CHAT_SYSTEM("[CR]アイテムがなくなりました 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end
			if(GetIES(fromMoru:GetObject())==nil)then
				--アイテムを喪失した
				CHAT_SYSTEM("[CR]金床がなくなりました 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end
			--CHAT_SYSTEM("[CR]次の金床強化に移ります")
			ReserveScript("CONTINUOUSREINFORCE_NEXTMORU()",0.05)
			
			local timer = GET_CHILD(ui.GetFrame("continuousreinforce"), "addontimer", "ui::CAddOnTimer");
			timer:Stop();
		end,catch=function(error)
			CHAT_SYSTEM(error)
		end
	}

end
function CONTINUOUSREINFORCE_NEXTMORU()
	EBI_try_catch{
		try=function()
			if(CONTINUOUSREINFORCE_VALUES.morustate==false or CONTINUOUSREINFORCE_VALUES.moruplace==true)then
				return
			end
			local fromItem, fromMoru = CONTINUOUSREINFORCE_VALUES.item, CONTINUOUSREINFORCE_VALUES.moru
			if(fromItem.isLockState)then
				--locked
				CHAT_SYSTEM("[CR]アイテムがロックされています 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end
			CONTINUOUSREINFORCE_VALUES.moruplace=true;
			--お金のチェック
			local fromItemObj = GetIES(fromItem:GetObject());
			local curReinforce = fromItemObj.Reinforce_2;
			local moruObj = GetIES(fromMoru:GetObject());
			local pc = GetMyPCObject();
			local price = GET_REINFORCE_PRICE(fromItemObj, moruObj, pc)	
			local retPrice, retCouponList = SCR_REINFORCE_COUPON_PRECHECK(pc, price)	
			
			CHAT_SYSTEM("[CR]必要なシルバーは"..retPrice)
			if IsGreaterThanForBigNumber(retPrice, GET_TOTAL_MONEY_STR()) == 1 then
				CHAT_SYSTEM("[CR]シルバーが不足しています 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return;
			end

			--良ければmoruする
			session.ResetItemList();
			session.AddItemID(fromItem:GetIESID());
			session.AddItemID(fromMoru:GetIESID());
			local resultlist = session.GetItemIDList();
			item.DialogTransaction("ITEM_REINFORCE_131014", resultlist);
			local timer = GET_CHILD(ui.GetFrame("continuousreinforce"), "addontimer", "ui::CAddOnTimer");
			timer:Start(0.01);
			ReserveScript("CONTINUOUSREINFORCE_VALUES.moruplace=false",0.2);
		end,
		catch=function(error)
			CHAT_SYSTEM(error)
		end
	}
end

function CONTINUOUSREINFORCE_MORUCANCEL()
	CHAT_SYSTEM("[CR]連続強化を中断します")
	CONTINUOUSREINFORCE_MORUSTOP()
end
function CONTINUOUSREINFORCE_MORUSTOP()
	local timer = GET_CHILD(ui.GetFrame("continuousreinforce"), "addontimer", "ui::CAddOnTimer");
	timer:Stop();
	CONTINUOUSREINFORCE_VALUES.morustate=false
	CONTINUOUSREINFORCE_VALUES.moruplace=false
	print("stopped")
	ui.SetEscapeScp("")
end