-- JUMPCANCELLER
local addonName = "JUMPCANCELLER"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

--バフ→skill→の順
JUMPCANCELLER_SKILLS={}

JUMPCANCELLER_SKILLS[3018]={type="Skill",clsid=30208}
JUMPCANCELLER_SKILLS[3076]={type="Skill",clsid=31107}
JUMPCANCELLER_KNELLING_CANCEL_BUFF=1100
g.settings = g.settings or {
    XXXX=false
}
g.settingsFileLoc  = string.format('../addons/%s/settings.json', addonNameLower)
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
            JUMPCANCELLER_LOAD_SETTINGS()
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function JUMPCANCELLER_LOAD_SETTINGS()

    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        g.settings = {
            XXXX=false
        }
    else
    end


end

function JUMPCANCELLER_SHOWWINDOW()
    local frame=ui.GetFrame("jumpcanceller");
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
                    --ごにょごにょ
                    if  g.settings and g.settings.XXXX then
                        if(buffout==JUMPCANCELLER_KNELLING_CANCEL_BUFF)then
                            ReserveScript(string.format("packet.ReqRemoveBuff(%d)",buffout),0.25)
                        end
                    end
                end
            
            end
        end,
        catch=function(error)
            CHAT_SYSTEM(error)
        end
    }

end