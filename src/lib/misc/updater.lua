local utils = require "src.lib.utils"
local moduleExports = {}

local mainGitHubPath = string.format("/Liebeslust/%s/main/", SCRIPT_NAME)
local mainFileName = SCRIPT_FILENAME

local function parseVersionInfo(content)
    local majorPattern = "MAJOR%s*:%s*(%d+)"
    local minorPattern = "MINOR%s*:%s*(%d+)"
    local patchPattern = "PATCH%s*:%s*(%d+)"
    local changelogPattern = "CHANGELOG%s*(.-)%-%-%-%s*END OF VERSION"

    local major = tonumber(content:match(majorPattern))
    local minor = tonumber(content:match(minorPattern))
    local patch = tonumber(content:match(patchPattern))
    local changelog = content:match(changelogPattern)

    if not major or not minor or not patch then return nil end

    local changelogLines = {}
    for line in changelog:gmatch("[^\r\n]+") do table.insert(changelogLines, line) end

    return {
        major = major,
        minor = minor,
        patch = patch,
        changelog = changelogLines
    }
end

local function isUpdateNeeded(currentVersion, newVersion)
    if not newVersion then return false end
    util.log("Current version: " .. currentVersion.major .. "." .. currentVersion.minor .. "." .. currentVersion.patch)
    util.log("New version: " .. newVersion.major .. "." .. newVersion.minor .. "." .. newVersion.patch)

    if newVersion.major > currentVersion.major or
        (newVersion.major == currentVersion.major and newVersion.minor > currentVersion.minor) or
        (newVersion.major == currentVersion.major and newVersion.minor == currentVersion.minor and newVersion.patch >
            currentVersion.patch) then return true end

    return false
end

local function startUpdate(content, updateCallback)
    local newVersionInfo = parseVersionInfo(content)
    if not newVersionInfo then
        utils.toast(LOC.unexpectedResponse)
        return
    end
    ---@type file*?
    local scriptFile = io.open(filesystem.scripts_dir() .. mainFileName, "rb")
    if scriptFile == nil then
        updateCallback(newVersionInfo)
        return
    end
    -- Read current version info and match with parseVersionInfo
    local versionInfo = parseVersionInfo(scriptFile:read("*a"))
    scriptFile:close()
    if isUpdateNeeded(versionInfo, newVersionInfo) then
        updateCallback(newVersionInfo)
    else
        utils.toast(LOC.noUpdatesAvailable)
    end
end

local State<const> = {
    Idle = 0,
    DownloadingScript = 1
}
local state = State.Idle

function moduleExports.runUpdater(clickType)
    if state == State.DownloadingScript then
        utils.toast(LOC.updateInProgress)
        return
    end
    async_http.init("https://raw.githubusercontent.com", mainGitHubPath .. mainFileName,
        function(resBody, _, statusCode)
            if statusCode >= 200 and statusCode < 300 and resBody and resBody:len() > 0 then
                startUpdate(resBody, function(newVersionInfo)
                    state = State.DownloadingScript
                    utils.toast(LOC.updating)
                    local scriptFile = io.open(filesystem.scripts_dir() .. mainFileName, "wb")
                    if not scriptFile then
                        utils.toast(LOC.unexpectedResponse)
                        state = State.Idle
                        return
                    end

                    scriptFile:write(resBody .. "\n")
                    scriptFile:close()
                    utils.toast(LOC.templates.updateSuccessful,
                        newVersionInfo.major .. "." .. newVersionInfo.minor .. "." .. newVersionInfo.patch)
                    utils.toast(LOC.changelog .. "\n" .. table.concat(newVersionInfo.changelog, "\n"))
                    util.restart_script()
                end)
            else
                utils.toast(LOC.failedToUpdate)
            end
        end, function() utils.toast(LOC.failedToDownloadFromGitHub) end)
    async_http.dispatch()
    AnimXUtils.toast(string.format("[%s]Downloading update from " .. "https://raw.githubusercontent.com%s%s",
        SCRIPT_NAME, mainGitHubPath, mainFileName))
end

return moduleExports
