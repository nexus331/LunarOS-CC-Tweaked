-- Lunar Resource Manager Program
print("Lunar Resource Manager 1.0")
print("Please enter pin to start operation...")
-- User Authentication

local correctPassword = "0850"
local passwordAsked = false
local function askForPassword()
    while true do
        io.write("[LunarResMgr] Enter pin for user: ")
        local password = read("*")
        if password == correctPassword then
            return true
        else
            print("[LunarResMgr] Incorrect pin.")
        end
    end
end
