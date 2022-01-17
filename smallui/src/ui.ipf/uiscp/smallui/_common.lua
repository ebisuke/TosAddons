local zz=_G
_G=setmetatable(zz, {__index = function(table,key)
    if string.find(key,"_ON_INIT") then
    
        local f=io.open("c:\\temp\\frames.txt", "a+")
        local kk=key:gsub("_ON_INIT","")
        f:write(kk.."\n")
        f:close()
    end 
    return rawget(table,key) end,__newindex=
    function(table,key,value) 
        if string.find(key,"_ON_INIT") then
            local kk=key:gsub("_ON_INIT","")
            local f=io.open("c:\\temp\\frames.txt", "a+")
            f:write(kk.."\n")
            f:close()
        end 
    rawset(table,key,value) end})
