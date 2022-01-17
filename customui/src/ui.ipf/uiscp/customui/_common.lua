local zz=_G
local settingsPath="..\\addons\\customui\\frames.txt"
io.open(settingsPath, "w"):close()
_G=setmetatable(zz, {__index = function(table,key)
    if string.find(key,"_ON_INIT") then
    
        local f=io.open(settingsPath, "a+")
        local kk=key:gsub("_ON_INIT","")
        f:write(kk.."\n")
        f:close()
    end 
    return rawget(table,key) end,__newindex=
    function(table,key,value) 
        if string.find(key,"_ON_INIT") then
            local kk=key:gsub("_ON_INIT","")
            local f=io.open(settingsPath, "a+")
            f:write(kk.."\n")
            f:close()
        end 
    rawset(table,key,value) end})
