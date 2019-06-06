--OLD_SHOP_ITEM_LIST_GET
function EBI_try_catch(what)
	local status, result = pcall(what.try)
	if not status then
		what.catch(result)
	end
	return result
end
function SHOPHELPERTOOL_ON_INIT(addon, frame)
	
	if(OLD_SHOP_ITEM_LIST_GET == nil and SHOPHELPERTOOL_SHOP_ITEM_LIST_GET_PASSER ~= _G["SHOP_ITEM_LIST_GET"]) then
		OLD_SHOP_ITEM_LIST_GET = _G["SHOP_ITEM_LIST_GET"]
		_G["SHOP_ITEM_LIST_GET"]=SHOPHELPERTOOL_SHOP_ITEM_LIST_GET_PASSER
	end

end
function SHOPHELPERTOOL_SHOP_ITEM_LIST_GET_PASSER(frame)
	SHOPHELPERTOOL_SHOP_ITEM_LIST_GET(frame)
end
SHOPHELPERTOOL_FOODBOX=false
function SHOPHELPERTOOL_SHOP_ITEM_LIST_GET(frame)

	EBI_try_catch{
		try=function()

			if frame == nil then
				frame = ui.GetFrame('shop');
			end
			if(OLD_SHOP_ITEM_LIST_GET~=nil)then
				OLD_SHOP_ITEM_LIST_GET(frame)
			end
			if true then
				local ShopItemGroupBox 	= frame:GetChild('shop');
				local SHOPITEM_listSet	= tolua.cast(ShopItemGroupBox, "ui::CGroupBox");
			
				local byCompanionShop = false;
				if frame:GetTopParentFrame():GetName() == 'companionshop' then
					byCompanionShop = true;
					SHOPHELPERTOOL_FOODBOX=true;
					
				else
					SHOPHELPERTOOL_FOODBOX=false
				end
					-- statements
				
				local grid = nil;
				local pos = {}
				if byCompanionShop == true then
					--pos={10,10,0,0}
					--grid = SHOPITEM_listSet:CreateOrGetControl('grid', 'grid', 0, 0, ui.NONE_HORZ, ui.NONE_VERT, 10, 10, 0, 0);
				else
					--pos={35,15,30,8}
					--grid = SHOPITEM_listSet:CreateOrGetControl('grid', 'grid', 0, 0, ui.NONE_HORZ, ui.NONE_VERT, 30, 15, 30, 8);
				end
			
				-- 상점에 파는 아이템 개수 파악
				local shopItemList = session.GetShopItemList();
				if shopItemList == nil then
					return;
				end
				local shopItemCount = shopItemList:Count();
				local SHOPITEMLIST_prevItem = nil;
			
				local TOTALPAGENUM = math.floor(shopItemCount / 8) + 1;
				if shopItemCount % 8 == 0 then
					TOTALPAGENUM = TOTALPAGENUM - 1;
				end
				local j=0
				if shopItemCount - shopItemCount % 8 > 0 then
					local pageEndCount = NOWPAGENUM * 8 - 1;
					if pageEndCount > shopItemCount then
						pageEndCount = shopItemCount - 1;
					end
					
					for i = (NOWPAGENUM - 1) * 8, pageEndCount do
						--SHOP_ITEM_LIST_UPDATE(frame, i, shopItemCount);

						local shopItem	= shopItemList:PtrAt(i);
						local shopItemcls= GetClassByType(shopItem:GetIDSpace(), shopItem.type).ClassID
						if(GET_SHOP_ITEM_MAXSTACK(shopItem)~=-1)then
							--バンドル可能なもののみ
							SHOPHELPERTOOL_GENERATEBUTTON(SHOPITEM_listSet,i,j,shopItem.classID)
						end
						j=j+1
					end
				else
					for i = 0, shopItemCount - 1 do

						local shopItem	= shopItemList:PtrAt(i);
						local shopItemcls= GetClassByType(shopItem:GetIDSpace(), shopItem.type).ClassID
						if(GET_SHOP_ITEM_MAXSTACK(shopItem)~=-1)then
							--バンドル可能なもののみ
							SHOPHELPERTOOL_GENERATEBUTTON(SHOPITEM_listSet,i,j,shopItem.classID)
						end
						j=j+1
					end
				end
			end
		end,
		catch=function(error)
			CHAT_SYSTEM(error)
			print(error)
		end
	}
	
	
end
function SHOPHELPERTOOL_GENERATEBUTTON(SHOPITEM_listSet,listindex,drawindex,clsid)
	local yoffset=0
	if(SHOPHELPERTOOL_FOODBOX==true)then
		yoffset=yoffset-6
	end

	local bten=SHOPITEM_listSet:CreateOrGetControl("button","tenbutton"..tostring(drawindex), 460-90, 50*drawindex+20+yoffset, 30, 30);
	local bhundred=SHOPITEM_listSet:CreateOrGetControl("button","hundredbutton"..tostring(drawindex), 460-60, 50*drawindex+20+yoffset, 30, 30);
	
	local bedit=SHOPITEM_listSet:CreateOrGetControl("button","editbutton"..tostring(drawindex), 460-30, 50*drawindex+20+yoffset, 50, 30);
	bten:SetText("10")
	bten:SetEventScript(ui.LBUTTONDOWN, "SHOPHELPERTOOL_BUY");
	bten:SetEventScriptArgNumber(ui.LBUTTONDOWN, 10);
	bten:SetEventScriptArgString(ui.LBUTTONDOWN, tostring(clsid));
	bhundred:SetText("100")
	bhundred:SetEventScript(ui.LBUTTONDOWN, "SHOPHELPERTOOL_BUY");
	bhundred:SetEventScriptArgNumber(ui.LBUTTONDOWN, 100);
	bhundred:SetEventScriptArgString(ui.LBUTTONDOWN, tostring(clsid));
	bedit:SetText("入力")

	bedit:SetEventScript(ui.LBUTTONDOWN, "SHOPHELPERTOOL_BUYEDIT");
	bedit:SetEventScriptArgString(ui.LBUTTONDOWN, tostring(clsid));
end

function SHOPHELPERTOOL_BUY(frame, ctrl, argstr, argnum)
	EBI_try_catch{
		try=function()
			local clsid = tonumber(argstr)
			if(SHOPHELPERTOOL_FOODBOX==true)then
				frame=GET_CHILD_RECURSIVELY(ui.GetFrame("companionshop"),"foodbox")
			else
				frame=ui.GetFrame("shop")
			end
			
	
			SHOPHELPERTOOL_BUYIT(clsid,tonumber(argnum),frame)
		end,
	catch=function(error)
		CHAT_SYSTEM(error)
		print(error)
	end
	}
end
function SHOPHELPERTOOL_BUYEDIT(frame, ctrl, argstr, argnum)
	
	local clsID = tonumber(argstr)
	if(SHOPHELPERTOOL_FOODBOX==true)then
		frame=GET_CHILD_RECURSIVELY(ui.GetFrame("companionshop"),"foodbox")
	else
		frame=ui.GetFrame("shop")
	end

	SHOP_UPDATE_BUY_PRICE(frame)
	local shopItem	= geShopTable.GetByClassID(clsID);
	local remainPrice = frame:GetUserIValue("EXPECTED_REMAIN_ZENY");
	local maxStack = GET_SHOP_ITEM_MAXSTACK(shopItem);
	if -1 == maxStack then
		SHOP_BUY(clsID, shopItem.count, frame);
		SHOP_UPDATE_BUY_PRICE(frame);
		return;
	end

	local itemPrice = shopItem.price * shopItem.count;
	local shopName = session.GetCurrentShopName()
	if IS_COLONY_TAX_SHOP_NAME(GET_COLONY_TAX_CURRENT_CITY_NAME(), shopName) == true then
		local taxRate = GET_COLONY_TAX_RATE_CURRENT_MAP()
		if taxRate ~= nil then
			itemPrice = tonumber(CALC_PRICE_WITH_TAX_RATE(itemPrice, taxRate))
		end
	end
	local buyableCnt = math.floor(remainPrice / itemPrice);

	local titleText = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", buyableCnt);
	INPUT_NUMBER_BOX(frame:GetTopParentFrame(), titleText, "EXEC_SHOP_SLOT_BUY", 1, 1, buyableCnt, nil, nil, 1);
	frame:SetUserValue("BUY_CLSID", clsID);
	return;
end
function SHOPHELPERTOOL_BUYIT(clsid,num,frame)
	local shopItem	= geShopTable.GetByClassID(clsid);
	local remainPrice = frame:GetUserIValue("EXPECTED_REMAIN_ZENY");
	local itemPrice = shopItem.price * shopItem.count;
	local shopName = session.GetCurrentShopName()
	if IS_COLONY_TAX_SHOP_NAME(GET_COLONY_TAX_CURRENT_CITY_NAME(), shopName) == true then
		local taxRate = GET_COLONY_TAX_RATE_CURRENT_MAP()
		if taxRate ~= nil then
			itemPrice = tonumber(CALC_PRICE_WITH_TAX_RATE(itemPrice, taxRate))
		end
	end
	local buyableCnt = math.floor(remainPrice / itemPrice);
	num=math.min(num,buyableCnt)
	if(num>0)then
		SHOP_BUY(clsid,num,frame)
		SHOP_UPDATE_BUY_PRICE(frame);
	end
end



