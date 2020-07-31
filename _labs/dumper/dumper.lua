-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
local function tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        elseif type(v) == 'function' then
            print(formatting .. "func")
        elseif type(v) == 'userdata' then
            print(formatting .. "userdata")
        else
            print(formatting .. v)
        end
    end
end

local function twrite(tbl, indent)
  
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        local formatting
        if (type(k) == 'userdata') then
            formatting = string.rep("  ", indent) .. "userdata" .. ": "
            io.write(formatting .. "\n")
        else
            formatting = string.rep("  ", indent) .. tostring(k) .. ": "
            if type(v) == "table" then
                --tx=tx .. formatting.."\n"
                
                twrite(v, indent + 1)
                --io.write(formatting .. "\n" .. tostring(twrite(v, indent + 1)) .. "\n")
            elseif type(v) == 'boolean' then
                io.write(formatting .. tostring(v) .. "\n")
            elseif type(v) == 'function' then
                io.write(formatting .. "func" .. "\n")
            elseif type(v) == 'userdata' then
                io.write(formatting .. "userdata" .. "\n")
            else
                io.write(formatting .. v .. "\n")
            end
        end
    end

end
local function tdump(tbl, indent)
    local tx = ""
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        if (type(k) == 'userdata') then
            formatting = string.rep("  ", indent) .. "userdata" .. ": "
            tx = tx .. formatting .. "\n"
        else
            formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                --tx=tx .. formatting.."\n"
                tx = tx .. formatting .. "\n" .. tdump(v, indent + 1) .. "\n"
            elseif type(v) == 'boolean' then
                tx = tx .. formatting .. tostring(v) .. "\n"
            elseif type(v) == 'function' then
                tx = tx .. formatting .. "func" .. "\n"
            elseif type(v) == 'userdata' then
                tx = tx .. formatting .. "userdata" .. "\n"
            else
                tx = tx .. formatting .. v .. "\n"
            end
        end
    end
    return tx
end
local function twriteflat(tbl,fd)
    
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
      
      if (type(k) == 'userdata') then
          formatting = string.rep("  ", indent) .. "userdata" .. ": "
          fd:write(formatting .. "\n")
      else
          formatting = string.rep("  ", indent) .. tostring(k) .. ": "
          if type(v) == "table" then
              --tx=tx .. formatting.."\n"
              fd:write(formatting .. "table" .."\n")
          elseif type(v) == 'boolean' then
              fd:write(formatting .. tostring(v) .. "\n")
          elseif type(v) == 'function' then
            fd:write(formatting .. "func" .. "\n")
          elseif type(v) == 'userdata' then
            fd:write(formatting .. "userdata" .. "\n")
          else
            fd:write(formatting .. v .. "\n")
          end
      end
  end

end

io.open("c:\\temp\\dump.txt","w")
twrite(_G)
io.close()