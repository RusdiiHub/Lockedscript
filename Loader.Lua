-- ============================================================
--  Giannis Client — Auto-Updating Loader
--  Share THIS script instead of the full script.
--  When you update Menu-V3.Lua on GitHub, everyone auto-gets it.
-- ============================================================

-- ⚠️ CHANGE THIS to your actual GitHub raw URL after uploading:
-- Format: https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Menu-V3.Lua
local ScriptURL = "https://raw.githubusercontent.com/RusdiiHub/GiannisClient/refs/heads/main/Menu-V3.Lua"

-- Optional: Version check
local VersionURL = "https://raw.githubusercontent.com/RusdiiHub/GiannisClient/refs/heads/main/version.txt"

local function LoadScript()
    local success, result = pcall(function()
        return game:HttpGet(ScriptURL)
    end)
    
    if success and result then
        print("[Giannis Client] Script fetched successfully!")
        local exec = loadstring(result)
        if exec then
            exec()
        else
            warn("[Giannis Client] Failed to compile script!")
        end
    else
        warn("[Giannis Client] Failed to fetch script: " .. tostring(result))
        warn("[Giannis Client] Check your internet or the URL.")
    end
end

-- Show version if available
pcall(function()
    local ver = game:HttpGet(VersionURL)
    if ver then
        print("[Giannis Client] Version: " .. ver)
    end
end)

LoadScript()
