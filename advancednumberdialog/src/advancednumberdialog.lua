
function EBI_try_catch(what)
	local status, result = pcall(what.try)
	if not status then
		what.catch(result)
	end
	return result
end

ADVANCEDNUMBERDIALOG_RECENTMINMAX={}

function ADVANCEDNUMBERDIALOG_ON_INIT(addon, frame)
	
	if(OLD_INPUT_NUMBER_BOX == nil and ADVANCEDNUMBERDIALOG_INPUT_NUMBER_BOX_JUMPER ~= _G["INPUT_NUMBER_BOX"]) then
		OLD_INPUT_NUMBER_BOX = _G["INPUT_NUMBER_BOX"]
		_G["INPUT_NUMBER_BOX"]=ADVANCEDNUMBERDIALOG_INPUT_NUMBER_BOX_JUMPER
	end

end
function ADVANCEDNUMBERDIALOG_INPUT_NUMBER_BOX_JUMPER(cbframe, titleName, strscp, defNumber, minNumber, maxNumber, numarg, strarg, isNumber)
	ADVANCEDNUMBERDIALOG_INPUT_NUMBER_BOX(cbframe, titleName, strscp, defNumber, minNumber, maxNumber, numarg, strarg, isNumber)
end
function ADVANCEDNUMBERDIALOG_INPUT_NUMBER_BOX(cbframe, titleName, strscp, defNumber, minNumber, maxNumber, numarg, strarg, isNumber)

	if(OLD_INPUT_NUMBER_BOX~=nil)then
		OLD_INPUT_NUMBER_BOX(cbframe, titleName, strscp, defNumber, minNumber, maxNumber, numarg, strarg, isNumber)
	end
	EBI_try_catch{
		try=function()
			local frame=ui.GetFrame("inputstring")
			frame:GetChild("input2"):SetVisible(0)
			frame:GetChild("title2"):SetVisible(0)
			frame:GetChild("input_name_skin2"):SetVisible(0)
			
			frame:Resize(500,300)

			local input = frame:GetChild("input")
			input:SetTypingScp("ADVANCEDNUMBERDIALOG_ON_CHANGETEXT")
			frame:CreateOrGetControl("slidebar","slider",40,140,440,30)
			local obj 		= frame:GetChild("slider");	
			local slideBar 	= tolua.cast(obj, "ui::CSlideBar");	
			slideBar:SetMaxSlideLevel(maxNumber);
			slideBar:SetMinSlideLevel(minNumber);
			ADVANCEDNUMBERDIALOG_RECENTMINMAX={minNumber,maxNumber}
			slideBar:SetLevel(defNumber);

			slideBar:SetEventScript(ui.MOUSEMOVE, "ADVANCEDNUMBERDIALOG_ON_SLIDE");
			slideBar:SetEventScript(ui.LBUTTONUP, "ADVANCEDNUMBERDIALOG_ON_SLIDE");

			--ボタンを作る
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"p1","{#FFFFFF}1",1,40+40*5+20,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"p10","{#FFFFFF}10",10,40*2+40*5+20,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"p100","{#FFFFFF}100",100,40*3+40*5+20,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"p1000","{#FFFFFF}1k",1000,40*4+40*5+20,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"p10000","{#FFFFFF}10k",10000,40*5+40*5+20,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"m10000","{#FF0000}10k",-10000,40,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"m1000","{#FF0000}1k",-1000,40*2,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"m100","{#FF0000}100",-100,40*3,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"m10","{#FF0000}10",-10,40*4,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"m1","{#FF0000}1",-1,40*5,200,40,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"bmin","{#FF0000}Min",-2147483648,140,170,100,30)
			ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,"bmax","{#FFFFFF}Max",2147483647,260,170,100,30)
			


		end,
		catch=function(error)
			print(error)
			CHAT_SYSTEM(error)
		end

	}


	

end

function ADVANCEDNUMBERDIALOG_ON_SLIDE(frame, ctrl, argstr, argnum)

	EBI_try_catch{
		try=function()
			local obj 		= frame:GetChild("slider");	
			local slideBar 	= tolua.cast(obj, "ui::CSlideBar");	
			local frame=ui.GetFrame("inputstring")
			local input=frame:GetChild("input")
			local curnum=tonumber(slideBar:GetLevel())
			input:SetText(tostring(curnum))
		end,
		catch=function(error)
			print(error)
			CHAT_SYSTEM(error)
		end

	}

end
function ADVANCEDNUMBERDIALOG_CREATEBUTTON(frame,name,text,number,x,y,w,h)

	local btn=frame:CreateOrGetControl("button",name,x,y,w,h);
	
	btn:SetText(text)
	btn:SetEventScript(ui.LBUTTONDOWN, "ADVANCEDNUMBERDIALOG_ON_CLICK_CHANGEBUTTON");
	btn:SetEventScriptArgNumber(ui.LBUTTONDOWN, number);

end


function ADVANCEDNUMBERDIALOG_ON_CLICK_CHANGEBUTTON(frame, ctrl, argstr, argnum)

	local input=frame:GetChild("input")
	local minimum=ADVANCEDNUMBERDIALOG_RECENTMINMAX[1];
	local maximum=ADVANCEDNUMBERDIALOG_RECENTMINMAX[2];
	local current=tonumber(input:GetText());

	--足し算で現在値が1なら特殊処理
	if(argnum>1 and current==1)then
		argnum=argnum-1
	end

	current=current+argnum
	--補正
	if(current<minimum)then
		current=minimum
	end
	if(current>maximum)then
		current=maximum
	end
	input:SetText(tostring(current))
	ADVANCEDNUMBERDIALOG_UPDATESLIDER(frame)
end
function ADVANCEDNUMBERDIALOG_ON_CHANGETEXT(frame, ctrl)
	ADVANCEDNUMBERDIALOG_UPDATESLIDER(frame)
end
function ADVANCEDNUMBERDIALOG_UPDATESLIDER(frame)
	local input = frame:GetChild("input")
	local obj=frame:GetChild("slider");
	local slideBar 	= tolua.cast(obj, "ui::CSlideBar");
	slideBar:SetLevel(tonumber(input:GetText()))
end
function ADVANCEDNUMBERDIALOG_GETVALUE(frame)
	local input=frame:GetChild("input")
	local curnum=tonumber(input:GetText())
	return curnum;
end
function ADVANCEDNUMBERDIALOG_SETVALUE(frame,num)
end