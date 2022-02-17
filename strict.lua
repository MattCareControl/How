if system.getInfo('environment') == 'simulator' then  
    -- Prevent global missuse
    local mt = getmetatable(_G)
    if mt == nil then
      mt = {}
      setmetatable(_G, mt)
    end

    mt.__declared = {}

    mt.__newindex = function (t, n, v)
      if not mt.__declared[n] then
        local w = debug.getinfo(2, 'S').what
        if w ~= 'main' and w ~= 'C' then
          if string.find(debug.getinfo(2,'S').source, "widget_candy") == nil then
            --error('assign to undeclared variable \'' .. n .. '\'', 2)
            print("STRICT ERROR: " .. n .. " in " .. debug.getinfo(2,'S').source)
          end
        end
        mt.__declared[n] = true
      end
      rawset(t, n, v)
    end

    mt.__index = function (t, n)
      if not mt.__declared[n] and debug.getinfo(2, 'S').what ~= 'C' then
        --print(debug.getinfo(2,'S').source)
        if string.find(debug.getinfo(2,'S').source, "widget_candy") == nil then
          --error('variable \'' .. n .. '\' is not declared', 2)
          print("STRICT ERROR: " .. n .. " in " .. debug.getinfo(2,'S').source)
        end
      end
      return rawget(t, n)
    end
end 