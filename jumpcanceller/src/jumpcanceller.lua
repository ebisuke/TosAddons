--バフ→skill→の順
JUMPCANCELLER_SKILLS={}
JUMPCANCELLER_SKILLS[3018]={type="Skill",clsid=30208}
JUMPCANCELLER_SKILLS[3076]={type="Skill",clsid=31107}

function EBI_try_catch(what)
	local status, result = pcall(what.try)
	if not status then
		what.catch(result)
	end
	return result
end
function JUMPCANCELLER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame=ui.GetFrame("jumpcanceller");
            frame:ShowWindow(1)
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            addon:RegisterMsg('FPS_UPDATE', 'JUMPCANCELLER_SHOWWINDOW');
            timer:SetUpdateScript("JUMPCANCELLER_WATCHKEY");
            timer:Start(0.00)
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function JUMPCANCELLER_SHOWWINDOW()
    frame=ui.GetFrame("jumpcanceller");
    frame:ShowWindow(1)
end
function JUMPCANCELLER_WATCHKEY()
    EBI_try_catch{
        try=function()

            local frame=ui.GetFrame("jumpcanceller");
            --入力方法チェック
            if(imcinput.HotKey.IsDown("Jump"))then
                --ON

                --バフが含まれるかチェック
                local handle = session.GetMyHandle();
                for i = 0, info.GetBuffCount(handle) - 1 do
                    local buffout=info.GetBuffIndexed(handle, i).buffID
                    local skill=JUMPCANCELLER_SKILLS[buffout]
                    if skill then
                        --スキルを行使する

                        control.Skill(skill.clsid);
                    end
                end
            
            end
        end,
        catch=function(error)
            CHAT_SYSTEM(error)
        end
    }

end