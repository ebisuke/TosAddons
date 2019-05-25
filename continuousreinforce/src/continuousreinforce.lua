
CONTINUOUSREINFORCE_VALUES={
	moru=nil,
	item=nil,
	itemiesid=nil,
	moruiesid=nil,
	morustate=false,
	moruplace=false,
	pricealert=false,
	delayedmode=false
}
local acutil  = require('acutil')
if not CONTINUOUSREINFORCE_SETTINGS then
	CONTINUOUSREINFORCE_SETTINGS={}
	CONTINUOUSREINFORCE_SETTINGS.enable=true
end
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
function CONTINUOUSREINFORCE_PROCESS_COMMAND(command)
    local cmd = "";
  
    if #command > 0 then
      cmd = table.remove(command, 1);
    else
      local msg = "usage{nl}/cr on 連続強化を有効(デフォルト) {nl}/cr off 連続強化を無効"
      return ui.MsgBox(msg,"","Nope")
    end
  
    if cmd == "on" then
      --有効
	    CONTINUOUSREINFORCE_SETTINGS.enable=true
        CHAT_SYSTEM("[CR]連続強化を有効化しました");
        AUTOITEMMANAGE_SAVE_SETTINGS()
      return;
    elseif cmd == "off" then
      --無効
	    CONTINUOUSREINFORCE_SETTINGS.enable=false
        CHAT_SYSTEM("[CR]連続強化を無効化しました");
        AUTOITEMMANAGE_SAVE_SETTINGS()
      return;
    end
    CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
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
	acutil.slashCommand("/cr", CONTINUOUSREINFORCE_PROCESS_COMMAND);

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
			if(CONTINUOUSREINFORCE_SETTINGS.enable==false)then
				return
			end
			local frame = ui.GetFrame("reinforce_131014");
			CONTINUOUSREINFORCE_VALUES.item, CONTINUOUSREINFORCE_VALUES.moru = REINFORCE_131014_GET_ITEM(frame);
			CONTINUOUSREINFORCE_VALUES.itemiesid = CONTINUOUSREINFORCE_VALUES.item:GetIESID()
			CONTINUOUSREINFORCE_VALUES.moruiesid = CONTINUOUSREINFORCE_VALUES.moru:GetIESID()
			

			if(CONTINUOUSREINFORCE_VALUES.morustate==false)then
				CONTINUOUSREINFORCE_VALUES.morustate=true
				CONTINUOUSREINFORCE_JUDGE_DELAYEDMODE()
				if(CONTINUOUSREINFORCE_VALUES.delayedmode==false)then
					CHAT_SYSTEM("[CR]連続強化を開始します。やめるときはESCを押してください。")
					ReserveScript("CONTINUOUSREINFORCE_STARTTIMER()",1.5)
				--	CONTINUOUSREINFORCE_STARTTIMER();

					ReserveScript("ui.SetEscapeScp(\"CONTINUOUSREINFORCE_MORUCANCEL()\")",0.05)
				end
			end
		end,
		catch=function(error)
			CHAT_SYSTEM(error)
		end
	}


end
function CONTINUOUSREINFORCE_JUDGE_DELAYEDMODE()
	local fromItem, fromMoru = CONTINUOUSREINFORCE_VALUES.item, CONTINUOUSREINFORCE_VALUES.moru
	local delay=false
	--moru(金床)残数が1ならディレイモード
	if(fromMoru.count==1)then
		delay=true
	end
	--ポテが0ならディレイモード
	local fromItemObj = GetIES(fromItem:GetObject());
	
	if(fromItemObj.PR==0)then
		delay=true
	end
	 CONTINUOUSREINFORCE_VALUES.delayedmode=delay
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
			if(CONTINUOUSREINFORCE_SETTINGS.enable==false)then
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
			local fndList, fndCount = SelectObject(self, 200, 'ALL');
			local myName=world.GetActor(myHnd)

			
			for i = 1, fndCount do
				itm		= fndList[i];
				hnd		= GetHandle(itm);
				actr	= world.GetActor(hnd);
				mon		= GetClassByType("Monster", actr:GetType());
			
					if(itm.ClassID==41432 or itm.ClassID==47412)then
						local stat=info.GetStat(hnd)

						if(actr:GetName():match(myName:GetName())and stat.HP>0)then
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
			local delay=0.01
			--金床が消えてしまう可能性がある場合はエラーを抑止するため遅延させる
			if(CONTINUOUSREINFORCE_VALUES.delayedmode==true)then
				delay=2
			end
			ReserveScript("CONTINUOUSREINFORCE_NEXTMORU()",delay)
			
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
			if(CONTINUOUSREINFORCE_VALUES.morustate==false or CONTINUOUSREINFORCE_VALUES.moruplace==true or CONTINUOUSREINFORCE_SETTINGS.enable==false)then
				return
			end
			local fromItem, fromMoru = CONTINUOUSREINFORCE_VALUES.item, CONTINUOUSREINFORCE_VALUES.moru
			if(fromItem.isLockState)then
				--locked
				CHAT_SYSTEM("[CR]アイテムがロックされています 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end
			local invItem = GET_ITEM_BY_GUID(CONTINUOUSREINFORCE_VALUES.itemiesid)
			if(invItem==nil or invItem.count==0)then
				--fil
				CHAT_SYSTEM("[CR]アイテムがなくなりました 連続強化を終了します.")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end

			local invMoru = GET_ITEM_BY_GUID(CONTINUOUSREINFORCE_VALUES.moruiesid)
			if(invMoru==nil or invMoru.count==0)then
				--fil
				CHAT_SYSTEM("[CR]金床がなくなりました 連続強化を終了します.")
				CONTINUOUSREINFORCE_MORUSTOP()

				return

			end
			if(invMoru.count==1)then
				--fil
				CHAT_SYSTEM("[CR]金床が1個しかありません 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end
			if(invItem:GetObject()==nil or GetIES(invItem:GetObject())==nil)then
				--アイテムを喪失した
				CHAT_SYSTEM("[CR]アイテムがなくなりました 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end
			if(invMoru:GetObject()==nil or GetIES(invMoru:GetObject())==nil)then
				--アイテムを喪失した
				CHAT_SYSTEM("[CR]金床がなくなりました 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end

			--お金のチェック
			local fromItemObj = GetIES(invItem:GetObject());
			local curReinforce = fromItemObj.Reinforce_2;
			local moruObj = GetIES(invMoru:GetObject());
			local pc = GetMyPCObject();
			local price = GET_REINFORCE_PRICE(fromItemObj, moruObj, pc)	
			local retPrice, retCouponList = SCR_REINFORCE_COUPON_PRECHECK(pc, price)	
			if(fromItemObj.PR==0)then
				CHAT_SYSTEM("[CR]ポテンシャルが0です 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return
			end

			if IsGreaterThanForBigNumber(retPrice, GET_TOTAL_MONEY_STR()) == 1 then
				CHAT_SYSTEM("[CR]シルバーが不足しています 連続強化を終了します")
				CONTINUOUSREINFORCE_MORUSTOP()
				return;
			end
			
			if(CONTINUOUSREINFORCE_VALUES.pricealert==false)then
				CHAT_SYSTEM(string.format("[CR]必要なシルバーは%s ポテ %d/%d",retPrice,fromItemObj.PR,fromItemObj.MaxPR))
				CONTINUOUSREINFORCE_VALUES.pricealert=true
			end

			CONTINUOUSREINFORCE_VALUES.moruplace=true;
			--良ければmoruする
			session.ResetItemList();
			session.AddItemID(CONTINUOUSREINFORCE_VALUES.itemiesid);
			session.AddItemID(CONTINUOUSREINFORCE_VALUES.moruiesid);
			local resultlist = session.GetItemIDList();
			item.DialogTransaction("ITEM_REINFORCE_131014", resultlist);
			local timer = GET_CHILD(ui.GetFrame("continuousreinforce"), "addontimer", "ui::CAddOnTimer");
			timer:Start(0.01);
			CONTINUOUSREINFORCE_JUDGE_DELAYEDMODE()
			ReserveScript("CONTINUOUSREINFORCE_VALUES.moruplace=false;CONTINUOUSREINFORCE_VALUES.pricealert=false",0.5);
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
	ui.SetEscapeScp("")
end