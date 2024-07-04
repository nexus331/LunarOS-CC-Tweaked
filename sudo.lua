local modemSide = "back"
local channel = 1
local correctPassword = "0850"
local passwordAsked = false
local versionFileID = "EzYxKhqP"
local scriptPastebinID = "dR7yyeb5"
local versionFile = "version.txt"
local version = "2.3"
 -- User Authentication
local function askForPassword()
    while true do
        io.write("[sudo] Enter pin for user: ")
        local password = read("*")
        if password == correctPassword then
            return true
        else
            print("[sudo] Incorrect pin.")
        end
    end
end
 -- Lunar Control Panel
local function broadcastCommand(command)
    rednet.open(modemSide)
    rednet.broadcast(command, "rednet_message", channel)
    local timeout = os.startTimer(1)
    local responseReceived = false
    while true do
        local event, senderId, message, protocol = os.pullEvent()
        if event == "rednet_message" then
            if type(message) == "string" then
                if message == "Access Granted." then
                    print(message)
                elseif message == "Lockdown initiated." then
                    print(message)
                elseif message == "Lockdown lifted." then
                    print(message)
                elseif message == "Command ignored. Lockdown in place." then
                    print(message)
                elseif message == "No lockdown in place. Ignored." then
                    print(message)
                end
            end
            responseReceived = true
            break
        elseif event == "timer" and senderId == timeout then
            print("[sudo] Timeout. No response received.")
            break
        end
    end
    if not responseReceived then
        print("[sudo] No response received.")
    end
    rednet.close(modemSide)
end
 
local function update()
    print("[sudo] Checking for updates...")
    -- Fetch the latest version file from Pastebin
    local success, err = shell.run("pastebin get " .. versionFileID .. " " .. versionFile)
    if not success then
        print("[sudo] Failed to fetch version information from Pastebin:", err)
        return
    end
 
    -- Open the version file to read the latest version number
    if fs.exists(versionFile) then
        local file = fs.open(versionFile, "r")
        if file then
            local latestVersion = file.readLine()
            file.close()
            fs.delete(versionFile)
 
            -- Trim whitespace from version numbers for accurate comparison
            latestVersion = latestVersion:match("^%s*(.-)%s*$")
            version = version:match("^%s*(.-)%s*$")
 
            if latestVersion and latestVersion ~= version then
                print("[sudo] Latest version available: " .. latestVersion)
                print("[sudo] Current installed version: " .. version)
                io.write("[sudo] Do you want to proceed with the update? (y/n): ")
                local proceed = read("*l")
                if proceed:lower() == "y" then
                    print("[sudo] Updating script...")
                    -- Overwrite the existing "sudo" script with the latest version
                    shell.run("rm sudo.lua")
                    local success, err = shell.run("pastebin get " .. scriptPastebinID .. " sudo")
                    if success then
                        version = latestVersion
                        print("[sudo] Script updated to version " .. latestVersion)
                    else
                        print("[sudo] Failed to update script:", err)
                    end
                else
                    print("[sudo] Update aborted.")
                end
            else
                print("[sudo] No updates available. You are running the latest version.")
            end
        else
            print("[sudo] Failed to open version file for reading.")
        end
    else
        print("[sudo] Version file does not exist.")
    end
end
 
local function fetchLocalVersion()
    print("[sudo] Fetching installed version...")
    print("[sudo] Installed version: " .. version)
end
 
local function monitorActivation()
    while true do
        local event, side = os.pullEvent()
        if event == "computer_command" or event == "computer_terminate" then
            passwordAsked = false
        end
    end
end
 
local function main()
    while true do
        if not passwordAsked then
            if askForPassword() then
                passwordAsked = true
            else
                return
            end
        end
        print("user@user:~$")
        local command = read()
        if command == "sudo apt upd" then
            update()
            return
        elseif command == "sudo apt ver" then
            fetchLocalVersion()
        else
            broadcastCommand(command)
        end
    end
end
 
parallel.waitForAny(main, monitorActivation)
 