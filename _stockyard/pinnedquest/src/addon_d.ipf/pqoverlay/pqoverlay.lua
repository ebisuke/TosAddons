
-- ライブラリ読み込み
local acutil = require('acutil')



-- マップ読み込み時処理（1度だけ）
function PQOVERLAY_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()

        end,
        catch = function(error)PINNEDQUEST_ERROUT(error) end
    }
end
