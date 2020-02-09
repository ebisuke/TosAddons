--DEVELOPERCONSOLEINTELLISENSE_ON_INIT

-- ライブラリ読み込み
function DEVELOPERCONSOLEINTELLISENSE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

