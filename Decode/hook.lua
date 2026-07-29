local originalLoadstring
originalLoadstring = hookfunction(loadstring, newcclosure(function(source, chunkname)
    local cleanSource = tostring(source)
    print("--- [LOADSTRING INTERCEPTED] ---")
    
    pcall(function()
        if writefile then
            local filename = "dump_" .. math.floor(os.clock() * 1000) .. ".lua"
            
            writefile(filename, cleanSource)
        end
    end)
    
    return originalLoadstring(source, chunkname)
end))