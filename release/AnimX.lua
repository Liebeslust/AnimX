--[[ --- START OF VERSION ---
MAJOR:1
MINOR:5
PATCH:0
CHANGELOG
- Added spectate warnings
--- END OF VERSION --- ]]
package.preload['src.lib.utils'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				local moduleExports = {}

function moduleExports.templateReplace(template, ...)
    local args = {...}
    local result = template:gsub("{arg(%d+)}", function(n) return args[tonumber(n)] end)
    return result
end

function moduleExports.toast(template, ...)
    local args = {...}
    local result = template:gsub("{arg(%d+)}", function(n) return args[tonumber(n)] end)
    util.toast(result, TOAST_ALL)
end

function moduleExports.debugLog(message)
    if Config.debugMode then
        local formattedMessage = string.format("[%s] %s", SCRIPT_NAME, message)
        util.toast(formattedMessage)
        util.log(formattedMessage)
    end
end

---@param modelName string
function moduleExports.requestModelLoad(modelName)
    local requestTime = os.time()
    local hash = util.joaat(modelName)
    if not STREAMING.IS_MODEL_VALID(hash) then return end
    STREAMING.REQUEST_MODEL(hash)

    moduleExports.debugLog("Requesting model " .. modelName)

    while not STREAMING.HAS_MODEL_LOADED(hash) do
        if os.time() - requestTime >= 10 then break end
        util.yield()
    end
end

function moduleExports.getModelSize(hash)
    local minptr = memory.alloc(24)
    local maxptr = memory.alloc(24)
    local min = {}
    local max = {}
    MISC.GET_MODEL_DIMENSIONS(hash, minptr, maxptr)
    min.x, min.y, min.z = v3.get(minptr)
    max.x, max.y, max.z = v3.get(maxptr)
    local size = {}
    size.x = max.x - min.x
    size.y = max.y - min.y
    size.z = max.z - min.z
    size['max'] = math.max(size.x, size.y, size.z)
    return size
end

---@return number
---@param offx number
---@param offy number
---@param offz number
---@param ped number
---@param angx number
---@param angy number
---@param angz number
---@param modelName string
---@param bone number
---@param isnpc boolean
---@param isveh boolean
function moduleExports.createEntityAndAttachTo(offx, offy, offz, ped, angx, angy, angz, modelName, bone, isnpc, isveh)
    local bone = PED.GET_PED_BONE_INDEX(ped, bone)
    local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local hash = util.joaat(modelName)
    if not STREAMING.IS_MODEL_VALID(hash) then return end
    local obj
    if isnpc then
        obj = entities.create_ped(1, hash, coords, 90.0)
    elseif isveh then
        obj = entities.create_vehicle(hash, coords, 90.0)
    else
        obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z'], true, false, false)
    end
    ENTITY.SET_ENTITY_INVINCIBLE(obj, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, ped, bone, offx, offy, offz, angx, angy, angz, false, false, true, false, 0,
        true)
    ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(obj, false, true)

    return obj
end

return moduleExports
 end)
package.preload['src.lib.misc.filelist'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-------------------------------------
-- FILE LIST
-------------------------------------
---@class FileList
FileList = {
    dir = "",
    ext = "json",
    open = false,
    reference = 0,
    options = {},
    fileOpts = {},
    onClick = nil
}
FileList.__index = FileList

---@param parent integer
---@param name string
---@param options table
---@param dir string
---@param ext string
---@param onClick fun(opt: integer, fileName: string, path: string)
---@return FileList
function FileList.new(parent, name, options, dir, ext, onClick)
    local self = setmetatable({
        dir = dir,
        ext = ext,
        options = options
    }, FileList)
    self.fileOpts = {}
    self.onClick = onClick

    self.reference = menu.list(parent, name, {}, "", function()
        self.open = true
        self:load()
    end, function()
        self.open = false
        self:clear()
    end)

    return self
end

function FileList:load()
    if not self.dir or not filesystem.exists(self.dir) then return end

    for _, path in ipairs(filesystem.list_files(self.dir)) do
        local name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
        if not self.ext or self.ext == ext then self:createOpt(name, path) end
    end
end

---@param fileName string
---@param path string
function FileList:createOpt(fileName, path)
    local list = menu.list(self.reference, fileName, {}, "")

    for i, opt in ipairs(self.options) do
        menu.action(list, opt, {}, "", function() self.onClick(i, fileName, path) end)
    end

    self.fileOpts[#self.fileOpts + 1] = list
end

function FileList:clear()
    if #self.fileOpts == 0 then return end

    for i, ref in ipairs(self.fileOpts) do
        menu.delete(ref);
        self.fileOpts[i] = nil
    end
end

---@param file string #Must include file extension.
---@param content string
function FileList:add(file, content)
    assert(self.dir ~= "", "tried to add a file to a null directory")
    if not filesystem.exists(self.dir) then filesystem.mkdir(self.dir) end

    local name, ext = string.match(file, '^(.+)%.(.+)$')
    local count = 1

    while filesystem.exists(self.dir .. file) do
        count = count + 1
        file = string.format("%s (%s).%s", name, count, ext)
    end

    local file<close> = assert(io.open(self.dir .. file, "w"))
    file:write(content)
end

function FileList:reload()
    self:clear()
    self:load()
end
 end)
package.preload['src.lib.misc.labels'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-----------------------------------
-- LABELS
-----------------------------------	
CustomLabels = {
    EnterFileName = LOC.labels.enterFileName,
    InvalidChar = LOC.labels.invalidChar,
    EnterValue = LOC.labels.enterValue,
    ValueMustBeNumber = LOC.labels.valueMustBeNumber,
    Search = LOC.labels.search
}

for key, text in pairs(CustomLabels) do CustomLabels[key] = util.register_label(text) end

 end)
package.preload['src.lib.misc.localization'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-- package.loaded["src.lib.localization"] = nil
local engTranslations = {
    noInternetAccess = "To use AnimX, please enable internet access",
    checkForUpdates = "Check for updates",
    checkForUpdatesD = "Check for updates for AnimX",
    updateInProgress = "Update in progress...",
    updating = "Updating...",
    failedToUpdate = "Failed to update the script file.",
    unexpectedResponse = "Unexpected update file. Local file will stay unchanged.",
    failedToDownloadFromGitHub = "Failed to download from GitHub.",
    changelog = "Changelog",
    noUpdatesAvailable = "No updates available.",

    attire = "Attire",
    specialLocations = "Special Locations",
    sexMusic = "Sex music",
    sexAnimations = "Sex animations",
    moans = "Moans",
    stopAllAnims = "Stop all anims",
    vehicle = "Vehicle",
    receiver = "Receiver",
    giver = "Giver",
    normal = "Normal",
    self = "Self",

    autoCleanCharacter = "Auto clean character",
    autoCleanCharacterD = "Automatically clean blood, dirt and wetness from your character",
    enableCleanAll = "Enable clean all",
    enableCleanAllD = "Enable automatic cleaning for blood, dirt and wetness",
    disableCleanAll = "Disable clean all",
    disableCleanAllD = "Disable automatic cleaning for blood, dirt and wetness",
    blood = "Blood",
    dirt = "Dirt",
    wetness = "Wetness",

    labels = {
        enterFileName = "Enter the file name",
        invalidChar = "Got an invalid character, try again",
        enterValue = "Enter the value",
        valueMustBeNumber = "The value must be a number, try again",
        search = "Type the word to search"
    },

    wardrobe = {
        type = "Type",
        texture = "Texture",

        head = "Head",
        beardMask = "Beard / Mask",
        hair = "Hair",
        glovesTorso = "Gloves / Torso",
        legs = "Legs",
        handsBack = "Hands / Back",
        shoes = "Shoes",
        teethScarfNecklaceBracelets = "Teeth / Scarf / Necklace / Bracelets",
        accessoriesTops = "Accessories / Tops",
        taskArmour = "Task / Armour",
        decals = "Decals",
        torso2 = "Torso 2",

        hat = "Hat",
        classes = "Classes",
        earwear = "Earwear",
        watch = "Watch",
        bracelet = "Bracelet"
    },
    animMenu = {
        animMenu = "Animations Menu",
        animMenuD = "Animations Menu",
        stopAnim = "Stop Animation",
        stopAnimD = "Stop Animation",
        animSelect = "Animation Select",
        animSelectD = "Animation Select",
        interactionSelect = "Interaction Select",
        interactionSelectD = "Interaction Select",
        interactionByMeSelect = "Interaction by Me Select",
        interactionByMeSelectD = "Interaction by Me Select",
    },

    actorMenu = {
        actorsMenu = "Actors Menu",
        actorMenuD = "Actor Menu",
        spawn = "Spawn",
        invincible = "Invincible",
        tpToMe = "Teleport to Me",
        tpToMePrecise = "Teleport to Me (Precise)",
        trimPosition = "Trim Position",
        disableCollisionWithMe = "Disable Collision with Me",
        delete = "Delete",
        weapon = "Weapon",
        appearance = "Appearance",
        save = "Save",
        actorSaved = "Actors saved",
        saveCanceled = "Save canceled",

        clone = "Clone",
        reachedMaxNumActors = "You reached the maximum number of actors",
        unknown = "Unknown",

        group = "Group",
        freedom = "Freedom",
        circle = "Circle",
        line = "Line",
        arrow = "Arrow",
        groupFormation = "Group Formation",

        cloneMyself = "Clone Myself",
        likePlayers = "Like Players",
        dislikePlayersLikeGangs = "Dislike Players, Like Gangs",
        hatePlayersLikeGangs = "Hate Players, Like Gangs",
        likePlayersHatePlayerHaters = "Like Players, Hate Player Haters",
        dislikePlayersLikeCops = "Dislike Players, Like Cops",
        hatePlayersLikeCops = "Hate Players, Like Cops",
        hateEveryone = "Hate Everyone",

        relationshipGroup = "Relationship Group",
        onlineOnly = "Online Only",

        deleteMembers = "Delete Members",
        teleportMembersToMe = "Teleport Members to Me",
        defaultWeapon = "Default Weapon",

        deleteFile = "Delete File",
        saved = "Saved",
        spawnedActors = "Spawned Actors"
    },
    misc = {
        search = "Search"
    },

    miscmiscellaneous = "Miscellaneous",
    spectateWarning = "Spectate Warning",
    spectateWarningD = "Spectate Warning",

    templates = {
        -- Example: "ChatGPT Prompt Preset changed to {arg1} "
        updateSuccessful = "Update successful, current version: {arg1}",
        invalidOutfit = "{arg1} has an invalid outfit: {arg2}"

    }
}

local languages = {"en"}
local translations = {
    en = engTranslations
}
local function merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

if table.contains(languages, lang.get_current()) then
    return merge(translations.en, translations[lang.get_current()])
else
    return translations.en
end
 end)
package.preload['src.lib.misc.updater'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
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
 end)
package.preload['src.lib.external.functions'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-- All at global scope

json = require "pretty.json"

local self = {}
self.version = 29

Config = {
    controls = {
        vehicleweapons = 86,
        airstrikeaircraft = 86
    },
    general = {
        standnotifications = false,
        displayhealth = true,
        language = "english",
        developer = false, -- developer flag (enables/disables some debug features)
        showintro = true
    },
    ufo = {
        disableboxes = false, -- determines if boxes are drawn on players to show their position
        targetplayer = false -- wether tractor beam only targets players or not
    },
    vehiclegun = {
        disablepreview = false
    },
    healthtxtpos = {
        x = 0.03,
        y = 0.05
    },
    handlingAutoload = {}
}

---@alias HudColour integer

HudColour = {
    pureWhite = 0,
    white = 1,
    black = 2,
    grey = 3,
    greyLight = 4,
    greyDrak = 5,
    red = 6,
    redLight = 7,
    redDark = 8,
    blue = 9,
    blueLight = 10,
    blueDark = 11,
    yellow = 12,
    yellowLight = 13,
    yellowDark = 14,
    orange = 15,
    orangeLight = 16,
    orangeDark = 17,
    green = 18,
    greenLight = 19,
    greenDark = 20,
    purple = 21,
    purpleLight = 22,
    purpleDark = 23,
    radarHealth = 25,
    radarArmour = 26,
    friendly = 118
}

local NULL<const> = 0

--------------------------
-- NOTIFICATION
--------------------------

---@class Notification
notification = {
    txdDict = "DIA_ZOMBIE1",
    txdName = "DIA_ZOMBIE1",
    title = "WiriScript",
    subtitle = "~c~" .. util.get_label_text("PM_PANE_FEE") .. "~s~",
    defaultColour = HudColour.black
}

---@param msg string
function notification.stand(msg)
    assert(type(msg) == "string", "msg must be a string, got " .. type(msg))
    msg = msg:gsub('~[%w_]-~', ""):gsub('<C>(.-)</C>', '%1')
    util.toast(string.format("[%s] %s", SCRIPT_NAME, msg))
end

---@param format string
---@param colour? HudColour
function notification:help(format, colour, ...)
    assert(type(format) == "string", "msg must be a string, got " .. type(format))

    local msg = string.format(format, ...)
    if Config.general.standnotifications then return self.stand(msg) end

    HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(colour or self.defaultColour)
    util.BEGIN_TEXT_COMMAND_THEFEED_POST("~BLIP_INFO_ICON~ " .. msg)
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER_WITH_TOKENS(true, true)
end

---@param format string
---@param colour? HudColour
function notification:normal(format, colour, ...)
    assert(type(format) == "string", "msg must be a string, got " .. type(format))

    local msg = string.format(format, ...)
    if Config.general.standnotifications then return self.stand(msg) end

    HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(colour or self.defaultColour)
    util.BEGIN_TEXT_COMMAND_THEFEED_POST(msg)
    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT(self.txdDict, self.txdName, true, 4, self.title, self.subtitle)
    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, false)
end

--------------------------
-- MENU
--------------------------

Features = {}

---@param value any
---@param e string
function type_match(value, e)
    local t = type(value)
    for w in e:gmatch('[^|]+') do if t == w then return true end end
    local msg = "must be %s, got %s"
    return false, msg:format(e:gsub('|', " or "), t)
end

---@param tbl table
---@param types {[1]: string, [2]:string}
---@return boolean
---@return string? errmsg
local check_table_types = function(tbl, types)
    if type(tbl) ~= "table" then return false, "tbl must be a tble" end
    for key, value in pairs(tbl) do
        local ok, errmsg = type_match(key, types[1])
        if not ok then return false, "field " .. key .. ' ' .. errmsg end

        local ok, errmsg = type_match(value, types[2])
        if not ok then return false, "field " .. key .. ' ' .. errmsg end
    end
    return true
end

--------------------------
-- FILE
--------------------------

Ini = {}

---Saves a table with key-value pairs in an ini format file.
---@param fileName string
---@param obj table
function Ini.save(fileName, obj)
    local file<close> = assert(io.open(fileName, "w"), "error loading file")
    local s = {}
    for section, tbl in pairs(obj) do
        assert(type(tbl) == "table", "expected field " .. section .. " to be a table, got " .. type(tbl))
        local l = {}
        table.insert(l, string.format("[%s]", section))
        for k, v in pairs(tbl) do table.insert(l, string.format("%s=%s", k, v)) end
        table.insert(s, table.concat(l, '\n') .. '\n')
    end
    file:write(table.concat(s, '\n'))
end

---Parses a table from an ini format file.
---@param fileName any
---@return table
function Ini.load(fileName)
    assert(type(fileName) == "string", "fileName must be a string")
    local file<close> = assert(io.open(fileName, "r"), "error loading file: " .. fileName)
    local data = {}
    local section
    for line in io.lines(fileName) do
        local tempSection = string.match(line, '^%[([^%]]+)%]$')

        if tempSection ~= nil then
            section = tonumber(tempSection) and tonumber(tempSection) or tempSection
            data[section] = data[section] or {}
        end

        local param, value = string.match(line, '^([%w_]+)%s*=%s*(.+)$')
        if section ~= nil and param and value ~= nil then
            if value == "true" then
                value = true
            elseif value == "false" then
                value = false
            elseif tonumber(value) then
                value = tonumber(value)
            end
            data[section][tonumber(param) or param] = value
        end
    end
    return data
end


local parseJson = json.parse

---@param filePath string
---@param withoutNull? boolean
---@return boolean
---@return string|table
json.parse = function (filePath, withoutNull)
	local file <close> = assert(io.open(filePath, "r"), filePath .. " does not exist")
	local content = file:read("a")
	local fileName = string.match(filePath, '^.+\\(.+)')
	if #content == 0 then
		return false,  fileName .. " is empty"
	end
	return pcall(parseJson, content, withoutNull)
end

--------------------------
-- EFFECT
--------------------------

---@class Effect
Effect = {
    asset = "",
    name = "",
    scale = 1.0
}
Effect.__index = Effect

---@param asset string
---@param name string
---@param scale? number
---@return Effect
function Effect.new(asset, name, scale)
    local inst = setmetatable({}, Effect)
    inst.name = name
    inst.asset = asset
    inst.scale = scale
    return inst
end

--------------------------
-- SOUND
--------------------------

---@class Sound
Sound = {
    Id = -1,
    name = "",
    reference = ""
}
Sound.__index = Sound

---@alias nullptr 0

---@param name string|nullptr
---@param reference string|nullptr
---@return Sound
function Sound.new(name, reference)
    local inst = setmetatable({}, Sound)
    inst.name = name
    inst.reference = reference
    return inst
end

function Sound:play()
    if self.Id == -1 then
        self.Id = AUDIO.GET_SOUND_ID()
        AUDIO.PLAY_SOUND_FRONTEND(self.Id, self.name, self.reference, true)
    end
end

function Sound:stop()
    if self.Id ~= -1 then
        AUDIO.STOP_SOUND(self.Id)
        AUDIO.RELEASE_SOUND_ID(self.Id)
        self.Id = -1
    end
end

function Sound:hasFinished() return AUDIO.HAS_SOUND_FINISHED(self.Id) end

function Sound:playFromEntity(entity)
    if self.Id == -1 then
        self.Id = AUDIO.GET_SOUND_ID()
        AUDIO.PLAY_SOUND_FROM_ENTITY(self.Id, self.name, entity, self.reference, true, 0)
    end
end

--------------------------
-- COLOUR
--------------------------

---@class Colour
---@field r number | integer
---@field g number | integer
---@field b number | integer
---@field a number | integer

function new_colour(r, g, b, a)
    return {
        r = r,
        g = g,
        b = b,
        a = a
    }
end

---@return Colour
function get_random_colour()
    local colour = {
        a = 255
    }
    colour.r = math.random(0, 255)
    colour.g = math.random(0, 255)
    colour.b = math.random(0, 255)
    return colour
end

---@param hudColour HudColour
---@return {r: integer, g: integer, b: integer, a: integer}
function get_hud_colour(hudColour)
    local r = memory.alloc(1)
    local g = memory.alloc(1)
    local b = memory.alloc(1)
    local a = memory.alloc(1)
    HUD.GET_HUD_COLOUR(hudColour, r, g, b, a)
    return {
        r = memory.read_int(r),
        g = memory.read_int(g),
        b = memory.read_int(b),
        a = memory.read_int(a)
    }
end

---@param colour Colour
function rainbow_colour(colour)
    if colour.r > 0 and colour.b == 0 then
        colour.r = colour.r - 1
        colour.g = colour.g + 1
    end

    if colour.g > 0 and colour.r == 0 then
        colour.g = colour.g - 1
        colour.b = colour.b + 1
    end

    if colour.b > 0 and colour.g == 0 then
        colour.r = colour.r + 1
        colour.b = colour.b - 1
    end
end

---@param perc number
---@return Colour
function get_blended_colour(perc)
    local colour = {
        a = 255
    }
    local r, g, b

    if perc <= 0.5 then
        r = 1.0
        g = interpolate(0.0, 1.0, perc / 0.5)
        b = 0.0
    else
        r = interpolate(1.0, 0, (perc - 0.5) / 0.5)
        g = 1.0
        b = 0.0
    end

    colour.r = math.ceil(r * 255)
    colour.g = math.ceil(g * 255)
    colour.b = math.ceil(b * 255)
    return colour
end

--------------------------
-- INSTRUCTIONAL
--------------------------

Instructional = {
    scaleform = 0
}

---@return boolean
function Instructional:begin()
    if GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(self.scaleform) then
        GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "CLEAR_ALL")
        GRAPHICS.END_SCALEFORM_MOVIE_METHOD()

        GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "TOGGLE_MOUSE_BUTTONS")
        GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_BOOL(true)
        GRAPHICS.END_SCALEFORM_MOVIE_METHOD()

        self.position = 0
        return true
    else
        self.scaleform = request_scaleform_movie("instructional_buttons")
        return false
    end
end

---@param index integer
---@param name string
---@param button string
function Instructional:add_data_slot(index, name, button)
    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "SET_DATA_SLOT")
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(self.position)

    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_PLAYER_NAME_STRING(button)
    if HUD.DOES_TEXT_LABEL_EXIST(name) then
        GRAPHICS.BEGIN_TEXT_COMMAND_SCALEFORM_STRING(name)
        GRAPHICS.END_TEXT_COMMAND_SCALEFORM_STRING()
    else
        GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING(name)
    end
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_BOOL(false)
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(index)
    GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    self.position = self.position + 1
end

---@param index integer
---@param name string
function Instructional.add_control(index, name)
    local button = PAD.GET_CONTROL_INSTRUCTIONAL_BUTTONS_STRING(2, index, true)
    Instructional:add_data_slot(index, name, button)
end

---@param index integer
---@param name string
function Instructional.add_control_group(index, name)
    local button = PAD.GET_CONTROL_GROUP_INSTRUCTIONAL_BUTTONS_STRING(2, index, true)
    Instructional:add_data_slot(index, name, button)
end

---@param r integer
---@param g integer
---@param b integer
---@param a integer
function Instructional:set_background_colour(r, g, b, a)
    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "SET_BACKGROUND_COLOUR")
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(r)
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(g)
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(b)
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(a)
    GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
end

function Instructional:draw()
    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    GRAPHICS.END_SCALEFORM_MOVIE_METHOD()

    GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(self.scaleform, 255, 255, 255, 220, 0)
    self.position = 0
end

--------------------------
-- TIMER
--------------------------

---@class Timer
---@field elapsed fun(): integer
---@field reset fun()
---@field isEnabled fun(): boolean
---@field disable fun()

---@return Timer
function newTimer()
    local self = {
        start = util.current_time_millis(),
        m_enabled = false
    }

    local function reset()
        self.start = util.current_time_millis()
        self.m_enabled = true
    end

    local function elapsed() return util.current_time_millis() - self.start end

    local function disable() self.m_enabled = false end
    local function isEnabled() return self.m_enabled end

    return {
        isEnabled = isEnabled,
        reset = reset,
        elapsed = elapsed,
        disable = disable
    }
end

--------------------------
-- ENTITIES
--------------------------

function SetBit(bits, place) return (bits | (1 << place)) end

function ClearBit(bits, place) return (bits & ~(1 << place)) end

function BitTest(bits, place) return (bits & (1 << place)) ~= 0 end

---@param entity Entity
---@param value boolean
function set_explosion_proof(entity, value)
    local pEntity = entities.handle_to_pointer(entity)
    if pEntity == 0 then return end
    local damageBits = memory.read_uint(pEntity + 0x188)
    damageBits = value and SetBit(damageBits, 11) or ClearBit(damageBits, 11)
    memory.write_uint(pEntity + 0x188, damageBits)
end

---@param entity Entity
---@param target Entity
---@param usePitch? boolean
function set_entity_face_entity(entity, target, usePitch)
    local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
    local pos2 = ENTITY.GET_ENTITY_COORDS(target, false)
    local rel = v3.new(pos2)
    rel:sub(pos1)
    local rot = rel:toRot()
    if not usePitch then
        ENTITY.SET_ENTITY_HEADING(entity, rot.z)
    else
        ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, false)
    end
end

---@param entity Entity
---@param blipSprite integer
---@param colour integer
---@return Blip
function add_blip_for_entity(entity, blipSprite, colour)
    local blip = HUD.ADD_BLIP_FOR_ENTITY(entity)
    HUD.SET_BLIP_SPRITE(blip, blipSprite)
    HUD.SET_BLIP_COLOUR(blip, colour)
    HUD.SHOW_HEIGHT_ON_BLIP(blip, false)

    util.create_tick_handler(function()
        if not ENTITY.DOES_ENTITY_EXIST(entity) or ENTITY.IS_ENTITY_DEAD(entity, false) then
            util.remove_blip(blip)
            return false
        elseif not HUD.DOES_BLIP_EXIST(blip) then
            return false
        else
            local heading = ENTITY.GET_ENTITY_HEADING(entity)
            HUD.SET_BLIP_ROTATION(blip, math.ceil(heading))
        end
    end)

    return blip
end

---@param blip Blip
---@param name string
---@param isLabel? boolean
function set_blip_name(blip, name, isLabel)
    HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
    if not isLabel then
        HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(name)
    else
        HUD.ADD_TEXT_COMPONENT_SUBSTRING_TEXT_LABEL(name)
    end
    HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
end

---@param entity Entity
---@return boolean
function request_control_once(entity)
    if not NETWORK.NETWORK_IS_IN_SESSION() then return true end
    local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
    return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
end

---@param entity Entity|integer
---@param timeOut? integer #time in `ms` trying to get control
---@return boolean
function request_control(entity, timeOut)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then return false end
    timeOut = timeOut or 500
    local start = newTimer()
    while not request_control_once(entity) and start.elapsed() < timeOut do util.yield_once() end
    return start.elapsed() < timeOut
end

---@param ped Ped
---@param maxPeds? integer
---@param ignore? integer
---@return Entity[]
function get_ped_nearby_peds(ped, maxPeds, ignore)
    maxPeds = maxPeds or 16
    local pEntityList = memory.alloc((maxPeds + 1) * 8)
    memory.write_int(pEntityList, maxPeds)
    local pedsList = {}
    for i = 1, PED.GET_PED_NEARBY_PEDS(ped, pEntityList, ignore or -1), 1 do
        pedsList[i] = memory.read_int(pEntityList + i * 8)
    end
    return pedsList
end

---@param ped Ped
---@param maxVehicles? integer
---@return Entity[]
function get_ped_nearby_vehicles(ped, maxVehicles)
    maxVehicles = maxVehicles or 16
    local pVehicleList = memory.alloc((maxVehicles + 1) * 8)
    memory.write_int(pVehicleList, maxVehicles)
    local vehiclesList = {}
    for i = 1, PED.GET_PED_NEARBY_VEHICLES(ped, pVehicleList) do
        vehiclesList[i] = memory.read_int(pVehicleList + i * 8)
    end
    return vehiclesList
end

---@param ped Ped
---@return Entity[]
function get_ped_nearby_entities(ped)
    local peds = get_ped_nearby_peds(ped)
    local vehicles = get_ped_nearby_vehicles(ped)
    local entities = peds
    for i = 1, #vehicles do table.insert(entities, vehicles[i]) end
    return entities
end

---@param player Player
---@param radius number
---@return Entity[]
function get_peds_in_player_range(player, radius)
    local peds = {}
    local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player)
    local pos = players.get_position(player)
    for _, ped in ipairs(entities.get_all_peds_as_handles()) do
        if ped ~= playerPed and not PED.IS_PED_FATALLY_INJURED(ped) then
            local pedPos = ENTITY.GET_ENTITY_COORDS(ped, true)
            if pos:distance(pedPos) <= radius then table.insert(peds, ped) end
        end
    end
    return peds
end

---@param player Player
---@param radius number
---@return Entity[]
function get_vehicles_in_player_range(player, radius)
    local vehicles = {}
    local pos = players.get_position(player)
    for _, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        local vehPos = ENTITY.GET_ENTITY_COORDS(vehicle, true)
        if pos:distance(vehPos) <= radius then table.insert(vehicles, vehicle) end
    end
    return vehicles
end

---@param pId Player
---@param radius number
---@return Entity[]
function get_entities_in_player_range(pId, radius)
    local peds = get_peds_in_player_range(pId, radius)
    local vehicles = get_vehicles_in_player_range(pId, radius)
    local entities = peds
    for i = 1, #vehicles do table.insert(entities, vehicles[i]) end
    return entities
end

---@param start v3
---@param to v3
---@param colour Colour
local draw_line = function(start, to, colour)
    GRAPHICS.DRAW_LINE(start.x, start.y, start.z, to.x, to.y, to.z, colour.r, colour.g, colour.b, colour.a)
end

---@param pos0 v3
---@param pos1 v3
---@param pos2 v3
---@param pos3 v3
---@param colour Colour
local draw_rect = function(pos0, pos1, pos2, pos3, colour)
    GRAPHICS.DRAW_POLY(pos0.x, pos0.y, pos0.z, pos1.x, pos1.y, pos1.z, pos3.x, pos3.y, pos3.z, colour.r, colour.g,
        colour.b, colour.a)
    GRAPHICS.DRAW_POLY(pos3.x, pos3.y, pos3.z, pos2.x, pos2.y, pos2.z, pos0.x, pos0.y, pos0.z, colour.r, colour.g,
        colour.b, colour.a)
end

---@param entity Entity
---@param showPoly? boolean
---@param colour? Colour	
function draw_bounding_box(entity, showPoly, colour)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then return end
    colour = colour or {
        r = 255,
        g = 0,
        b = 0,
        a = 255
    }
    local min = v3.new()
    local max = v3.new()
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(entity), min, max)
    min:abs();
    max:abs()

    local upperLeftRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, -max.y, max.z)
    local upperRightRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, -max.y, max.z)
    local lowerLeftRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, -max.y, -min.z)
    local lowerRightRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, -max.y, -min.z)

    draw_line(upperLeftRear, upperRightRear, colour)
    draw_line(lowerLeftRear, lowerRightRear, colour)
    draw_line(upperLeftRear, lowerLeftRear, colour)
    draw_line(upperRightRear, lowerRightRear, colour)

    local upperLeftFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, min.y, max.z)
    local upperRightFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, min.y, max.z)
    local lowerLeftFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, min.y, -min.z)
    local lowerRightFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, min.y, -min.z)

    draw_line(upperLeftFront, upperRightFront, colour)
    draw_line(lowerLeftFront, lowerRightFront, colour)
    draw_line(upperLeftFront, lowerLeftFront, colour)
    draw_line(upperRightFront, lowerRightFront, colour)

    draw_line(upperLeftRear, upperLeftFront, colour)
    draw_line(upperRightRear, upperRightFront, colour)
    draw_line(lowerLeftRear, lowerLeftFront, colour)
    draw_line(lowerRightRear, lowerRightFront, colour)

    if type(showPoly) ~= "boolean" or showPoly then
        draw_rect(lowerLeftRear, upperLeftRear, lowerLeftFront, upperLeftFront, colour)
        draw_rect(upperRightRear, lowerRightRear, upperRightFront, lowerRightFront, colour)

        draw_rect(lowerLeftFront, upperLeftFront, lowerRightFront, upperRightFront, colour)
        draw_rect(upperLeftRear, lowerLeftRear, upperRightRear, lowerRightRear, colour)

        draw_rect(upperRightRear, upperRightFront, upperLeftRear, upperLeftFront, colour)
        draw_rect(lowerRightFront, lowerRightRear, lowerLeftFront, lowerLeftRear, colour)
    end
end

---@param entity Entity
---@param flag integer
function set_decor_flag(entity, flag) DECORATOR.DECOR_SET_INT(entity, "Casino_Game_Info_Decorator", flag) end

---@param entity Entity
---@param flag integer
---@return boolean
function is_decor_flag_set(entity, flag)
    if ENTITY.DOES_ENTITY_EXIST(entity) and DECORATOR.DECOR_EXIST_ON(entity, "Casino_Game_Info_Decorator") then
        local value = DECORATOR.DECOR_GET_INT(entity, "Casino_Game_Info_Decorator")
        return (value & flag) ~= 0
    end
    return false
end

---@param entity Entity
function remove_decor(entity) DECORATOR.DECOR_REMOVE(entity, "Casino_Game_Info_Decorator") end

---@param ped Ped
---@param forcedOn boolean
---@param hasCone boolean
---@param noticeRange number
---@param colour integer
---@param sprite integer
function add_ai_blip_for_ped(ped, forcedOn, hasCone, noticeRange, colour, sprite)
    if colour == -1 then
        HUD.SET_PED_HAS_AI_BLIP(ped, true)
    else
        HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(ped, true, colour)
    end
    HUD.SET_PED_AI_BLIP_NOTICE_RANGE(ped, noticeRange)
    if sprite ~= -1 then HUD.SET_PED_AI_BLIP_SPRITE(ped, sprite) end
    HUD.SET_PED_AI_BLIP_HAS_CONE(ped, hasCone)
    HUD.SET_PED_AI_BLIP_FORCED_ON(ped, forcedOn)
end

---@param entity Entity
---@param minDistance number
---@param maxDistance number
---@return v3
function get_random_offset_from_entity(entity, minDistance, maxDistance)
    local pos = ENTITY.GET_ENTITY_COORDS(entity, false)
    return get_random_offset_in_range(pos, minDistance, maxDistance)
end

---@param coords v3
---@param minDistance number
---@param maxDistance number
---@return v3
function get_random_offset_in_range(coords, minDistance, maxDistance)
    local radius = random_float(minDistance, maxDistance)
    local angle = random_float(0, 2 * math.pi)
    local delta = v3.new(math.cos(angle), math.sin(angle), 0.0)
    delta:mul(radius)
    coords:add(delta)
    return coords
end

---@param entity Entity
function set_entity_as_no_longer_needed(entity)
    if not ENTITY.DOES_ENTITY_EXIST(entity) then return end
    local pHandle = memory.alloc_int()
    memory.write_int(pHandle, entity)
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(pHandle)
end

---@param entity Entity
---@param target Entity
---@return number
function get_distance_between_entities(entity, target)
    if not ENTITY.DOES_ENTITY_EXIST(entity) or not ENTITY.DOES_ENTITY_EXIST(target) then return 0.0 end
    local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
    return ENTITY.GET_ENTITY_COORDS(target, true):distance(pos)
end

--------------------------
-- PLAYER
--------------------------

---@param player Player
---@return boolean
function is_player_friend(player)
    local pHandle = memory.alloc(104)
    NETWORK.NETWORK_HANDLE_FROM_PLAYER(player, pHandle, 13)
    local isFriend = NETWORK.NETWORK_IS_HANDLE_VALID(pHandle, 13) and NETWORK.NETWORK_IS_FRIEND(pHandle)
    return isFriend
end

---@param player Player
---@return Vehicle
function get_vehicle_player_is_in(player)
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player)
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then return PED.GET_VEHICLE_PED_IS_IN(targetPed, false) end
    return 0
end

---@param player Player
---@return Entity
function get_entity_player_is_aiming_at(player)
    if not PLAYER.IS_PLAYER_FREE_AIMING(player) then return NULL end
    local entity, pEntity = NULL, memory.alloc_int()
    if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, pEntity) then entity = memory.read_int(pEntity) end
    if entity ~= NULL and ENTITY.IS_ENTITY_A_PED(entity) and PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
        entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
    end
    return entity
end

---@param entity Entity
---@return integer address
function get_net_obj(entity)
    local pEntity = entities.handle_to_pointer(entity)
    return pEntity ~= NULL and memory.read_long(pEntity + 0xD0) or NULL
end

---@param entity Entity
---@return Player owner
function get_entity_owner(entity)
    local net_obj = get_net_obj(entity)
    return net_obj ~= NULL and memory.read_byte(net_obj + 0x49) or -1
end

---@param player Player
---@return boolean
function is_player_passive(player)
    if player ~= players.user() then
        local address = memory.script_global(1894573 + (player * 608 + 1) + 8)
        if address ~= NULL then return memory.read_byte(address) == 1 end
    else
        local address = memory.script_global(1574582)
        if address ~= NULL then return memory.read_int(address) == 1 end
    end
    return false
end

---@param player Player
---@return boolean
function is_player_in_any_interior(player)
    local address = memory.script_global(2657589 + (player * 466 + 1) + 245)
    return address ~= NULL and memory.read_int(address) ~= 0
end

---@param player Player
---@return boolean
function is_player_in_interior(player)
    if player == -1 then return false end
    local bits = read_global.int(1853910 + (player * 862 + 1) + 267 + 31)
    if (bits & (1 << 0)) ~= 0 then
        return true
    elseif (bits & (1 << 1)) ~= 0 then
        return true
    elseif read_global.int(2657589 + (player * 466 + 1) + 321 + 7) ~= -1 then
        return true
    end
    return false
end

---@param player Player
---@return boolean
function is_player_in_rc_bandito(player)
    if player ~= -1 then
        local address = memory.script_global(1853910 + (player * 862 + 1) + 267 + 365)
        return BitTest(memory.read_int(address), 29)
    end
    return false
end

---@param player Player
---@return boolean
function is_player_in_rc_tank(player)
    if player ~= -1 then
        local address = memory.script_global(1853910 + (player * 862 + 1) + 267 + 428 + 2)
        return BitTest(memory.read_int(address), 16)
    end
    return false
end

---@param player Player
---@return boolean
function is_player_in_rc_personal_vehicle(player)
    if player ~= -1 then
        local address = memory.script_global(1853910 + (player * 862 + 1) + 267 + 428 + 3)
        return BitTest(memory.read_int(address), 6)
    end
    return false
end

---@param player Player
---@return boolean
function is_player_in_any_rc_vehicle(player)
    if is_player_in_rc_bandito(player) then return true end

    if is_player_in_rc_tank(player) then return true end

    if is_player_in_rc_personal_vehicle(player) then return true end

    return false
end

---@diagnostic disable: exp-in-action, unknown-symbol, action-after-return, undefined-global
---@param colour integer
---@return integer
function get_hud_colour_from_org_colour(colour)
    local colourMap = {
        [0] = 192,
        [1] = 193,
        [2] = 194,
        [3] = 195,
        [4] = 196,
        [5] = 197,
        [6] = 198,
        [7] = 199,
        [8] = 200,
        [9] = 201,
        [10] = 202,
        [11] = 203,
        [12] = 204,
        [13] = 205,
        [14] = 206
    }
    return colourMap[colour] or 1
end

---@diagnostic enable: exp-in-action, unknown-symbol, action-after-return, undefined-global
---@param player Player
---@return integer
function get_player_org_blip_colour(player)
    if players.get_boss(player) ~= -1 then
        local hudColour = get_hud_colour_from_org_colour(players.get_org_colour(player))
        local rgba = get_hud_colour(hudColour)
        return (rgba.r << 24) + (rgba.g << 16) + (rgba.b << 8) + rgba.a
    end
    return 0
end

---@param player Player
---@return string
function get_condensed_player_name(player)
    local condensed = "<C>" .. PLAYER.GET_PLAYER_NAME(player) .. "</C>"

    if players.get_boss(player) ~= -1 then
        local colour = players.get_org_colour(player)
        local hudColour = get_hud_colour_from_org_colour(colour)
        return string.format("~HC_%d~%s~s~", hudColour, condensed)
    end

    return condensed
end

---@param player Player
---@param isPlaying boolean
---@param inTransition boolean
---@return boolean
function is_player_active(player, isPlaying, inTransition)
    if player == -1 or not NETWORK.NETWORK_IS_PLAYER_ACTIVE(player) then return false end
    if isPlaying and not PLAYER.IS_PLAYER_PLAYING(player) then return false end
    if inTransition and read_global.int(2657589 + (player * 466 + 1)) ~= 4 then return false end
    return true
end

--------------------------
-- CAM
--------------------------

---@param dist number
---@return v3
function get_offset_from_cam(dist)
    local rot = CAM.GET_FINAL_RENDERED_CAM_ROT(2)
    local pos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local dir = rot:toDir()
    dir:mul(dist)
    local offset = v3.new(pos)
    offset:add(dir)
    return offset
end

--------------------------
-- RAYCAST
--------------------------

TraceFlag = {
    everything = 4294967295,
    none = 0,
    world = 1,
    vehicles = 2,
    pedsSimpleCollision = 4,
    peds = 8,
    objects = 16,
    water = 32,
    foliage = 256
}

---@class RaycastResult
---@field didHit boolean
---@field endCoords v3
---@field surfaceNormal v3
---@field hitEntity Entity

---@param dist number
---@param flag? integer
---@return RaycastResult
function get_raycast_result(dist, flag)
    local result = {}
    flag = flag or TraceFlag.everything
    local didHit = memory.alloc(1)
    local endCoords = v3.new()
    local normal = v3.new()
    local hitEntity = memory.alloc_int()
    local camPos = CAM.GET_FINAL_RENDERED_CAM_COORD()
    local offset = get_offset_from_cam(dist)

    local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(camPos.x, camPos.y, camPos.z, offset.x,
        offset.y, offset.z, flag, players.user_ped(), 7)
    SHAPETEST.GET_SHAPE_TEST_RESULT(handle, didHit, endCoords, normal, hitEntity)

    result.didHit = memory.read_byte(didHit) ~= 0
    result.endCoords = endCoords
    result.surfaceNormal = normal
    result.hitEntity = memory.read_int(hitEntity)
    return result
end

--------------------------
-- STREAMING
--------------------------

---@param model integer
function request_model(model)
    STREAMING.REQUEST_MODEL(model)
    while not STREAMING.HAS_MODEL_LOADED(model) do util.yield_once() end
end

---@param asset string
function request_fx_asset(asset)
    STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do util.yield_once() end
end

---@param hash integer
function request_weapon_asset(hash)
    WEAPON.REQUEST_WEAPON_ASSET(hash, 31, 0)
    while not WEAPON.HAS_WEAPON_ASSET_LOADED(hash) do util.yield_once() end
end

---Credits to aaron
---@param textureDict string
function request_streamed_texture_dict(textureDict)
    util.spoof_script("main_persistent", function() GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT(textureDict, false) end)
end

---@param textureDict string
function set_streamed_texture_dict_as_no_longer_needed(textureDict)
    util.spoof_script("main_persistent",
        function() GRAPHICS.SET_STREAMED_TEXTURE_DICT_AS_NO_LONGER_NEEDED(textureDict) end)
end

---@param name string
---@return integer
function request_scaleform_movie(name)
    local handle
    util.spoof_script("main_persistent", function() handle = GRAPHICS.REQUEST_SCALEFORM_MOVIE(name) end)
    return handle
end

---@param handle integer
function set_scaleform_movie_as_no_longer_needed(handle)
    util.spoof_script("main_persistent", function()
        local ptr = memory.alloc_int()
        memory.write_int(ptr, handle)
        GRAPHICS.SET_SCALEFORM_MOVIE_AS_NO_LONGER_NEEDED(ptr)
    end)
end

--------------------------
-- MEMORY
--------------------------

---@param addr integer
---@param offsets integer[]
---@return integer
function addr_from_pointer_chain(addr, offsets)
    if addr == 0 then return 0 end
    for k = 1, (#offsets - 1) do
        addr = memory.read_long(addr + offsets[k])
        if addr == 0 then return 0 end
    end
    addr = addr + offsets[#offsets]
    return addr
end

write_global = {
    byte = function(global, value)
        local address = memory.script_global(global)
        memory.write_byte(address, value)
    end,
    int = function(global, value)
        local address = memory.script_global(global)
        memory.write_int(address, value)
    end,
    float = function(global, value)
        local address = memory.script_global(global)
        memory.write_float(address, value)
    end
}

read_global = {
    byte = function(global)
        local address = memory.script_global(global)
        return memory.read_byte(address)
    end,
    int = function(global)
        local address = memory.script_global(global)
        return memory.read_int(address)
    end,
    float = function(global)
        local address = memory.script_global(global)
        return memory.read_float(address)
    end,
    string = function(global)
        local address = memory.script_global(global)
        return memory.read_string(address)
    end
}

HudTimer = {}

HudTimer.SetHeightMultThisFrame = function(mult) write_global.int(1655472 + 1163, mult) end

HudTimer.DisableThisFrame = function() write_global.int(2696211, 1) end

function EnableOTR()
    local toggle_addr = 2657589 + ((PLAYER.PLAYER_ID() * 466) + 1) + 210
    if read_global.int(toggle_addr) == 1 then return end
    write_global.int(toggle_addr, 1)
    write_global.int(2672505 + 56, NETWORK.GET_NETWORK_TIME() + 1)
end

function DisableOTR() write_global.int(2657589 + ((PLAYER.PLAYER_ID() * 466) + 1) + 210, 0) end

function DisablePhone() write_global.int(20366, 1) end

function is_phone_open()
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("cellphone_flashhand")) > 0 then
        return true
    end
    return false
end

---@param name string
---@param pattern string
---@param callback fun(address: integer)
function memory_scan(name, pattern, callback)
    local address = memory.scan(pattern)

    if address == NULL then error("Failed to find " .. name) end

    callback(address)
    util.log("Found %s", name)
end

--------------------------
-- TABLE
--------------------------

---Returns a random value from the given table.
---@param t table
---@return any
function table.random(t)
    if rawget(t, 1) ~= nil then return t[math.random(#t)] end
    local list = {}
    for _, value in pairs(t) do table.insert(list, value) end
    local result = list[math.random(#list)]
    return type(result) ~= "table" and result or table.random(result)
end

function pairs_by_keys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

---Inserts `value` if `t` does not already includes it.
---@param t table
---@param value any
function table.insert_once(t, value) if not table.find(t, value) then table.insert(t, value) end end

---@generic T: table, K, V
---@param t T
---@param f fun(key: K, value: V): boolean
---@return V
---@nodiscard
function table.find_if(t, f)
    for k, v in pairs(t) do if f(k, v) then return k end end
    return nil
end

---@generic T: table, K, V
---@param t T
---@param value any
---@return K?
---@nodiscard
function table.find(t, value)
    for k, v in pairs(t) do if value == v then return k end end
    return nil
end

---@generic T: table, K, V
---@param t T
---@param f fun(key: K, value: V):boolean
---@return integer
function table.count_if(t, f)
    local count = 0
    for k, v in pairs(t) do if f(k, v) then count = count + 1 end end
    return count
end

--------------------------
-- MISC
--------------------------

---Credits to Sainan
function int_to_uint(int)
    if int >= 0 then return int end
    return (1 << 32) + int
end

function interpolate(y0, y1, perc)
    perc = perc > 1.0 and 1.0 or perc
    return (1 - perc) * y0 + perc * y1
end

---@param num number
---@param places? integer
---@return number?
function round(num, places) return tonumber(string.format('%.' .. (places or 0) .. 'f', num)) end

---@param blip integer
---@return v3?
function get_blip_coords(blip)
    if blip == 0 then return nil end
    local pos = HUD.GET_BLIP_COORDS(blip)
    local tick = 0
    local success, groundz = util.get_ground_z(pos.x, pos.y)
    while not success and tick < 10 do
        util.yield_once()
        success, groundz = util.get_ground_z(pos.x, pos.y)
        tick = tick + 1
    end
    if success then pos.z = groundz end
    return pos
end

---@param pos v3
---@return number?
function get_ground_z(pos)
    local pGroundZ = memory.alloc(4)
    MISC.GET_GROUND_Z_FOR_3D_COORD(pos.x, pos.y, pos.z, pGroundZ, false, true)
    local groundz = memory.read_float(pGroundZ)
    return groundz
end

---@param windowName string #Must be a label
---@param maxInput integer
---@param defaultText string
---@return string
function get_input_from_screen_keyboard(windowName, maxInput, defaultText)
    MISC.DISPLAY_ONSCREEN_KEYBOARD(0, windowName, "", defaultText, "", "", "", maxInput);
    while MISC.UPDATE_ONSCREEN_KEYBOARD() == 0 do util.yield_once() end
    if MISC.UPDATE_ONSCREEN_KEYBOARD() == 1 then return MISC.GET_ONSCREEN_KEYBOARD_RESULT() end
    return ""
end

---@param s string
---@param x number
---@param y number
---@param scale number
---@param font integer
function draw_string(s, x, y, scale, font)
    HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
    HUD.SET_TEXT_FONT(font or 0)
    HUD.SET_TEXT_SCALE(scale, scale)
    HUD.SET_TEXT_DROP_SHADOW()
    HUD.SET_TEXT_WRAP(0.0, 1.0)
    HUD.SET_TEXT_DROPSHADOW(1, 0, 0, 0, 0)
    HUD.SET_TEXT_OUTLINE()
    HUD.SET_TEXT_EDGE(1, 0, 0, 0, 0)
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(s)
    HUD.END_TEXT_COMMAND_DISPLAY_TEXT(x, y, 0)
end

function capitalize(txt) return tostring(txt):gsub('^%l', string.upper) end

---@param min number
---@param max number
---@return number
function random_float(min, max) return min + math.random() * (max - min) end

---@param type integer
---@param pos v3
---@param scale number
---@param colour Colour
---@param textureDict string?
---@param textureName string?
function draw_marker(type, pos, scale, colour, textureDict, textureName)
    textureDict = textureDict or 0
    textureName = textureName or 0
    GRAPHICS.DRAW_MARKER(type, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, scale, colour.r,
        colour.g, colour.b, colour.a, false, false, 0, true, textureDict, textureName, false)
end

local orgLog = util.log

---@param format string
---@param ... any
util.log = function(format, ...)
    local strg = type(format) ~= "string" and tostring(format) or format:format(...)
    orgLog(string.format("[%s] %s", SCRIPT_NAME, strg))
end

function draw_debug_text(...)
    local arg = {...}
    local strg = ""
    for _, w in ipairs(arg) do strg = strg .. tostring(w) .. '\n' end
    local colour = {
        r = 1.0,
        g = 0.0,
        b = 0.0,
        a = 1.0
    }
    directx.draw_text(0.05, 0.05, strg, ALIGN_TOP_LEFT, 1.0, colour, false)
end

---@diagnostic disable: exp-in-action, unknown-symbol, break-outside, code-after-break, miss-symbol
---@diagnostic disable: undefined-global
---@param ped number
function is_ped_any_animal(ped)
    local modelHash = ENTITY.GET_ENTITY_MODEL(ped)
    local uintModelHash = int_to_uint(modelHash)
    local animalHashes = {
        [0xC2D06F53] = true,
        [0xCE5FF074] = true,
        [0x573201B8] = true,
        [0xFCFA9E1E] = true,
        [0x644AC75E] = true,
        [0xD86B5A95] = true,
        [0x4E8F95A2] = true,
        [0x1250D7BA] = true,
        [0xB11BAB56] = true,
        [0x431D501C] = true,
        [0x6D362854] = true,
        [0xDFB55C81] = true,
        [0x349F33E1] = true,
        [0x9563221D] = true,
        [0x431FC24C] = true,
        [0xAD7844BB] = true,
        [0xAAB71F62] = true,
        [0x56E29962] = true,
        [0x18012A9F] = true,
        [0x6AF51FAF] = true,
        [0x06A20728] = true,
        [0xD3939DFD] = true,
        [0x8BBAB455] = true,
        [0x2FD800B7] = true,
        [0x8D8AC8B9] = true,
        [0x3C831724] = true,
        [0x06C3F072] = true,
        [0xA148614D] = true,
        [0x14EC17EA] = true,
        [0x471BE4B2] = true
    }

    return animalHashes[uintModelHash] == true
end

return self
 end)
package.preload['src.lib.external.json'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				--
-- json.lua
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local json = { _version = "0.1.2" }

-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------

local encode

local escape_char_map = {
  [ "\\" ] = "\\",
  [ "\"" ] = "\"",
  [ "\b" ] = "b",
  [ "\f" ] = "f",
  [ "\n" ] = "n",
  [ "\r" ] = "r",
  [ "\t" ] = "t",
}

local escape_char_map_inv = { [ "/" ] = "/" }
for k, v in pairs(escape_char_map) do
  escape_char_map_inv[v] = k
end


local function escape_char(c)
  return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end


local function encode_nil(val)
  return "null"
end


local function encode_table(val, stack)
  local res = {}
  stack = stack or {}

  -- Circular reference?
  if stack[val] then error("circular reference") end

  stack[val] = true

  if rawget(val, 1) ~= nil or next(val) == nil then
    -- Treat as array -- check keys are valid and it is not sparse
    local n = 0
    for k in pairs(val) do
      if type(k) ~= "number" then
        error("invalid table: mixed or invalid key types")
      end
      n = n + 1
    end
    if n ~= #val then
      error("invalid table: sparse array")
    end
    -- Encode
    for i, v in ipairs(val) do
      table.insert(res, encode(v, stack))
    end
    stack[val] = nil
    return "[" .. table.concat(res, ",") .. "]"

  else
    -- Treat as an object
    for k, v in pairs(val) do
      if type(k) ~= "string" then
        error("invalid table: mixed or invalid key types")
      end
      table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
    end
    stack[val] = nil
    return "{" .. table.concat(res, ",") .. "}"
  end
end


local function encode_string(val)
  return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end


local function encode_number(val)
  -- Check for NaN, -inf and inf
  if val ~= val or val <= -math.huge or val >= math.huge then
    error("unexpected number value '" .. tostring(val) .. "'")
  end
  return string.format("%.14g", val)
end


local type_func_map = {
  [ "nil"     ] = encode_nil,
  [ "table"   ] = encode_table,
  [ "string"  ] = encode_string,
  [ "number"  ] = encode_number,
  [ "boolean" ] = tostring,
}


encode = function(val, stack)
  local t = type(val)
  local f = type_func_map[t]
  if f then
    return f(val, stack)
  end
  error("unexpected type '" .. t .. "'")
end


function json.encode(val)
  return ( encode(val) )
end


-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------

local parse

local function create_set(...)
  local res = {}
  for i = 1, select("#", ...) do
    res[ select(i, ...) ] = true
  end
  return res
end

local space_chars   = create_set(" ", "\t", "\r", "\n")
local delim_chars   = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars  = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals      = create_set("true", "false", "null")

local literal_map = {
  [ "true"  ] = true,
  [ "false" ] = false,
  [ "null"  ] = nil,
}


local function next_char(str, idx, set, negate)
  for i = idx, #str do
    if set[str:sub(i, i)] ~= negate then
      return i
    end
  end
  return #str + 1
end


local function decode_error(str, idx, msg)
  local line_count = 1
  local col_count = 1
  for i = 1, idx - 1 do
    col_count = col_count + 1
    if str:sub(i, i) == "\n" then
      line_count = line_count + 1
      col_count = 1
    end
  end
  error( string.format("%s at line %d col %d", msg, line_count, col_count) )
end


local function codepoint_to_utf8(n)
  -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
  local f = math.floor
  if n <= 0x7f then
    return string.char(n)
  elseif n <= 0x7ff then
    return string.char(f(n / 64) + 192, n % 64 + 128)
  elseif n <= 0xffff then
    return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
  elseif n <= 0x10ffff then
    return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                       f(n % 4096 / 64) + 128, n % 64 + 128)
  end
  error( string.format("invalid unicode codepoint '%x'", n) )
end


local function parse_unicode_escape(s)
  local n1 = tonumber( s:sub(1, 4),  16 )
  local n2 = tonumber( s:sub(7, 10), 16 )
   -- Surrogate pair?
  if n2 then
    return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
  else
    return codepoint_to_utf8(n1)
  end
end


local function parse_string(str, i)
  local res = ""
  local j = i + 1
  local k = j

  while j <= #str do
    local x = str:byte(j)

    if x < 32 then
      decode_error(str, j, "control character in string")

    elseif x == 92 then -- `\`: Escape
      res = res .. str:sub(k, j - 1)
      j = j + 1
      local c = str:sub(j, j)
      if c == "u" then
        local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                 or str:match("^%x%x%x%x", j + 1)
                 or decode_error(str, j - 1, "invalid unicode escape in string")
        res = res .. parse_unicode_escape(hex)
        j = j + #hex
      else
        if not escape_chars[c] then
          decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
        end
        res = res .. escape_char_map_inv[c]
      end
      k = j + 1

    elseif x == 34 then -- `"`: End of string
      res = res .. str:sub(k, j - 1)
      return res, j + 1
    end

    j = j + 1
  end

  decode_error(str, i, "expected closing quote for string")
end


local function parse_number(str, i)
  local x = next_char(str, i, delim_chars)
  local s = str:sub(i, x - 1)
  local n = tonumber(s)
  if not n then
    decode_error(str, i, "invalid number '" .. s .. "'")
  end
  return n, x
end


local function parse_literal(str, i)
  local x = next_char(str, i, delim_chars)
  local word = str:sub(i, x - 1)
  if not literals[word] then
    decode_error(str, i, "invalid literal '" .. word .. "'")
  end
  return literal_map[word], x
end


local function parse_array(str, i)
  local res = {}
  local n = 1
  i = i + 1
  while 1 do
    local x
    i = next_char(str, i, space_chars, true)
    -- Empty / end of array?
    if str:sub(i, i) == "]" then
      i = i + 1
      break
    end
    -- Read token
    x, i = parse(str, i)
    res[n] = x
    n = n + 1
    -- Next token
    i = next_char(str, i, space_chars, true)
    local chr = str:sub(i, i)
    i = i + 1
    if chr == "]" then break end
    if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
  end
  return res, i
end


local function parse_object(str, i)
  local res = {}
  i = i + 1
  while 1 do
    local key, val
    i = next_char(str, i, space_chars, true)
    -- Empty / end of object?
    if str:sub(i, i) == "}" then
      i = i + 1
      break
    end
    -- Read key
    if str:sub(i, i) ~= '"' then
      decode_error(str, i, "expected string for key")
    end
    key, i = parse(str, i)
    -- Read ':' delimiter
    i = next_char(str, i, space_chars, true)
    if str:sub(i, i) ~= ":" then
      decode_error(str, i, "expected ':' after key")
    end
    i = next_char(str, i + 1, space_chars, true)
    -- Read value
    val, i = parse(str, i)
    -- Set
    res[key] = val
    -- Next token
    i = next_char(str, i, space_chars, true)
    local chr = str:sub(i, i)
    i = i + 1
    if chr == "}" then break end
    if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
  end
  return res, i
end


local char_func_map = {
  [ '"' ] = parse_string,
  [ "0" ] = parse_number,
  [ "1" ] = parse_number,
  [ "2" ] = parse_number,
  [ "3" ] = parse_number,
  [ "4" ] = parse_number,
  [ "5" ] = parse_number,
  [ "6" ] = parse_number,
  [ "7" ] = parse_number,
  [ "8" ] = parse_number,
  [ "9" ] = parse_number,
  [ "-" ] = parse_number,
  [ "t" ] = parse_literal,
  [ "f" ] = parse_literal,
  [ "n" ] = parse_literal,
  [ "[" ] = parse_array,
  [ "{" ] = parse_object,
}


parse = function(str, idx)
  local chr = str:sub(idx, idx)
  local f = char_func_map[chr]
  if f then
    return f(str, idx)
  end
  decode_error(str, idx, "unexpected character '" .. chr .. "'")
end


function json.decode(str)
  if type(str) ~= "string" then
    error("expected argument of type string, got " .. type(str))
  end
  local res, idx = parse(str, next_char(str, 1, space_chars, true))
  idx = next_char(str, idx, space_chars, true)
  if idx <= #str then
    decode_error(str, idx, "trailing garbage")
  end
  return res
end


return json end)
package.preload['src.lib.audio'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				local moduleExports = {}

return moduleExports end)
package.preload['src.lib.animlib.anim'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				AnimFlag = {
    ANIM_FLAG_NORMAL = 0,
    ANIM_FLAG_REPEAT = 1,
    ANIM_FLAG_STOP_LAST_FRAME = 2,
    ANIM_FLAG_UPPERBODY = 16,
    ANIM_FLAG_ENABLE_PLAYER_CONTROL = 32,
    ANIM_FLAG_CANCELABLE = 120
}

AnimStatus = {
    playing = 0,
    stopped = 1,
    paused = 2,
    -- Always 1 or 2 frames before ENTITY.IS_ENTITY_PLAYING_ANIM returns true
    beforePlay = 3,
    stopping = 4
}

---@class AnimPlayback
AnimPlayback = {
    ped = 0,
    dict = "",
    animation = "",
    startTime = 0,
    elapsedTime = 0,
    playbackRate = 1,
    status = AnimStatus.stopped,
    ---@type fun(elapsedTime : number)?
    onStopped = nil,
    ---@type fun()?
    onFailed = nil
}
AnimPlayback.__index = AnimPlayback

---@param ped integer
---@param dict string
---@param animation string
---@param playbackRate number
---@param onStopped? fun(elapsedTime : number)
---@param onFailed? fun()
---@return AnimPlayback
function AnimPlayback.new(ped, dict, animation, playbackRate, onStopped, onFailed)
    local self = setmetatable({}, AnimPlayback)
    self.ped = ped
    self.dict = dict
    self.animation = animation
    self.playbackRate = playbackRate or 1
    self.onStopped = onStopped
    self.onFailed = onFailed
    return self
end

function AnimPlayback:start()
    if self.status == AnimStatus.playing then
        AnimXUtils.debugLog(string.format("Animation override. New animation: %s:%s", self.dict, self.animation))
    end
    self.startTime = os.clock()
    self:playAnim(self.ped, self.dict, self.animation, -1)
    self.status = AnimStatus.beforePlay
    AnimXUtils.debugLog(string.format("Animation start: %s:%s", self.dict, self.animation))
    self:monitorStatus()
end

function AnimPlayback:stop()
    if self.status == AnimStatus.playing then
        self:stopAnim(self.ped)
        self.status = AnimStatus.stopping
    end
end

function AnimPlayback:monitorStatus()
    util.create_tick_handler(function()
        local currentTime = os.clock()
        self.elapsedTime = currentTime - self.startTime

        if self.status == AnimStatus.beforePlay then
            if ENTITY.IS_ENTITY_PLAYING_ANIM(self.ped, self.dict, self.animation, 3) then
                self.status = AnimStatus.playing
            elseif self.elapsedTime >= 1.5 then
                AnimXUtils.debugLog(string.format("Failed to play animation: %s:%s", self.dict, self.animation))
                self:stop()
                return false
            end
        elseif self.status == AnimStatus.playing then
            if not ENTITY.IS_ENTITY_PLAYING_ANIM(self.ped, self.dict, self.animation, 3) then
                self.status = AnimStatus.stopped
                if self.onStopped then self.onStopped(self.elapsedTime) end
                return false
            end
        elseif self.status == AnimStatus.stopping then
            if not ENTITY.IS_ENTITY_PLAYING_ANIM(self.ped, self.dict, self.animation, 3) then
                self.status = AnimStatus.stopped
                if self.onStopped then self.onStopped(self.elapsedTime) end
                return false
            elseif self.elapsedTime >= 1.0 then
                AnimXUtils.debugLog("Failed to stop animation")
                self.status = AnimStatus.stopped
                return false
            end
        else
            return false
        end

        return true
    end)
end

---@param ped integer
---@param dict string
---@param animation string
---@param duration integer
function AnimPlayback:playAnim(ped, dict, animation, duration)
    STREAMING.REQUEST_ANIM_DICT(dict)
    while not STREAMING.HAS_ANIM_DICT_LOADED(dict) do util.yield(100) end
    if PED.IS_PED_A_PLAYER(ped) and ped ~= players.user_ped() then
        return -- Don't play animation on other players
    end
    TASK.TASK_PLAY_ANIM(ped, dict, animation, 2.0, 2.0, duration, AnimFlag.ANIM_FLAG_REPEAT, 0.0, false, false, false)
    STREAMING.REMOVE_ANIM_DICT(dict)
end

---@return boolean
---@param ped integer
function AnimPlayback:stopAnim(ped)
    if not ENTITY.DOES_ENTITY_EXIST(ped) then return false end

    if ped == players.user_ped() then
        TASK.CLEAR_PED_TASKS(ped)
        return true
    end

    if ped ~= players.user_ped() and request_control(ped, 1000) then
        TASK.CLEAR_PED_TASKS(ped)
        return true
    else
        return false
    end
end
 end)
package.preload['src.lib.animlib.animMenu'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				local AnimList<const> = require "src.consts.anim_list"

local trans = {
    AnimMenu = LOC.animMenu.animMenu,
    AnimMenuDesc = LOC.animMenu.animMenuD,
    AnimSelect = LOC.animMenu.animSelect,
    AnimSelectDesc = LOC.animMenu.animSelectD,
    InteractionSelect = LOC.animMenu.interactionSelect,
    InteractionSelectDesc = LOC.animMenu.interactionSelectD,
    InteractionByMeSelect = LOC.animMenu.interactionByMeSelect,
    InteractionByMeSelectDesc = LOC.animMenu.interactionByMeSelectD,
    StopAnim = LOC.animMenu.stopAnim,
    StopAnimDesc = LOC.animMenu.stopAnimD,
    Save = LOC.actorMenu.save
}

BoneIds = {
    NONE = -1,
    SKEL_ROOT = 0x0,
    SKEL_Pelvis = 0x2e28,
    SKEL_L_Thigh = 0xe39f,
    SKEL_L_Calf = 0xf9bb,
    SKEL_L_Foot = 0x3779,
    SKEL_L_Toe0 = 0x83c,
    IK_L_Foot = 0xfedd,
    PH_L_Foot = 0xe175,
    MH_L_Knee = 0xb3fe,
    SKEL_R_Thigh = 0xca72,
    SKEL_R_Calf = 0x9000,
    SKEL_R_Foot = 0xcc4d,
    SKEL_R_Toe0 = 0x512d,
    IK_R_Foot = 0x8aae,
    PH_R_Foot = 0x60e6,
    MH_R_Knee = 0x3fcf,
    RB_L_ThighRoll = 0x5c57,
    RB_R_ThighRoll = 0x192a,
    SKEL_Spine_Root = 0xe0fd,
    SKEL_Spine0 = 0x5c01,
    SKEL_Spine1 = 0x60f0,
    SKEL_Spine2 = 0x60f1,
    SKEL_Spine3 = 0x60f2,
    SKEL_L_Clavicle = 0xfcd9,
    SKEL_L_UpperArm = 0xb1c5,
    SKEL_L_Forearm = 0xeeeb,
    SKEL_L_Hand = 0x49d9,
    SKEL_L_Finger00 = 0x67f2,
    SKEL_L_Finger01 = 0xff9,
    SKEL_L_Finger02 = 0xffa,
    SKEL_L_Finger10 = 0x67f3,
    SKEL_L_Finger11 = 0x1049,
    SKEL_L_Finger12 = 0x104a,
    SKEL_L_Finger20 = 0x67f4,
    SKEL_L_Finger21 = 0x1059,
    SKEL_L_Finger22 = 0x105a,
    SKEL_L_Finger30 = 0x67f5,
    SKEL_L_Finger31 = 0x1029,
    SKEL_L_Finger32 = 0x102a,
    SKEL_L_Finger40 = 0x67f6,
    SKEL_L_Finger41 = 0x1039,
    SKEL_L_Finger42 = 0x103a,
    PH_L_Hand = 0xeb95,
    IK_L_Hand = 0x8cbd,
    RB_L_ForeArmRoll = 0xee4f,
    RB_L_ArmRoll = 0x1470,
    MH_L_Elbow = 0x58b7,
    SKEL_R_Clavicle = 0x29d2,
    SKEL_R_UpperArm = 0x9d4d,
    SKEL_R_Forearm = 0x6e5c,
    SKEL_R_Hand = 0xdead,
    SKEL_R_Finger00 = 0xe5f2,
    SKEL_R_Finger01 = 0xfa10,
    SKEL_R_Finger02 = 0xfa11,
    SKEL_R_Finger10 = 0xe5f3,
    SKEL_R_Finger11 = 0xfa60,
    SKEL_R_Finger12 = 0xfa61,
    SKEL_R_Finger20 = 0xe5f4,
    SKEL_R_Finger21 = 0xfa70,
    SKEL_R_Finger22 = 0xfa71,
    SKEL_R_Finger30 = 0xe5f5,
    SKEL_R_Finger31 = 0xfa40,
    SKEL_R_Finger32 = 0xfa41,
    SKEL_R_Finger40 = 0xe5f6,
    SKEL_R_Finger41 = 0xfa50,
    SKEL_R_Finger42 = 0xfa51,
    PH_R_Hand = 0x6f06,
    IK_R_Hand = 0x188e,
    RB_R_ForeArmRoll = 0xab22,
    RB_R_ArmRoll = 0x90ff,
    MH_R_Elbow = 0xbb0,
    SKEL_Neck_1 = 0x9995,
    SKEL_Head = 0x796e,
    IK_Head = 0x322c,
    FACIAL_facialRoot = 0xfe2c,
    FB_L_Brow_Out_000 = 0xe3db,
    FB_L_Lid_Upper_000 = 0xb2b6,
    FB_L_Eye_000 = 0x62ac,
    FB_L_CheekBone_000 = 0x542e,
    FB_L_Lip_Corner_000 = 0x74ac,
    FB_R_Lid_Upper_000 = 0xaa10,
    FB_R_Eye_000 = 0x6b52,
    FB_R_CheekBone_000 = 0x4b88,
    FB_R_Brow_Out_000 = 0x54c,
    FB_R_Lip_Corner_000 = 0x2ba6,
    FB_Brow_Centre_000 = 0x9149,
    FB_UpperLipRoot_000 = 0x4ed2,
    FB_UpperLip_000 = 0xf18f,
    FB_L_Lip_Top_000 = 0x4f37,
    FB_R_Lip_Top_000 = 0x4537,
    FB_Jaw_000 = 0xb4a0,
    FB_LowerLipRoot_000 = 0x4324,
    FB_LowerLip_000 = 0x508f,
    FB_L_Lip_Bot_000 = 0xb93b,
    FB_R_Lip_Bot_000 = 0xc33b,
    FB_Tongue_000 = 0xb987,
    RB_Neck_1 = 0x8b93,
    IK_Root = 0xdd1c
}

---@class AnimMenu
AnimMenu = {
    reference = 0,
    animSelectRef = 0,
    interactionSelectRef = 0,
    default = nil,
    name = "",
    command = "",
    usePid = false,
    _ped = 0,
    ---@type AnimPlayback?
    playbackInstance = nil,
    ---@type fun(dict: string, animation: string)?
    onClick = nil,
    changeName = false,
    ---@type table
    options = {},
    foundOpts = {}
}

AnimMenu.__index = function(t, k)
    if k == "ped" then
        -- return t.usePid and PLAYER.GET_PLAYER_PED(t._ped) or t._ped
        if t.usePid then
            return PLAYER.GET_PLAYER_PED(t._ped)
        else
            return t._ped
        end
    end
    if k == "pid" then
        if t.usePid then
            return t._ped
        else
            error("Attempted to get pid of AnimMenu that doesn't use pids.")
        end
    else
        return AnimMenu[k]
    end
end

---@param parent integer|CommandRef
---@param name string
---@param command string
---@param helpText string
---@param usePid boolean
---@param ped integer
---@param onClick fun(dict: string, animation: string)?
---@param changeName boolean -- If the list's name will change to show the selected model.
---@param searchOpt boolean
---@return AnimMenu
function AnimMenu.new(parent, name, command, helpText, usePid, ped, onClick, changeName, searchOpt)
    local self = setmetatable({}, AnimMenu)
    self.name = name
    self.command = command
    self.changeName = changeName
    self.foundOpts = {}
    self.options = AnimList
    self.reference = menu.list(parent, name, {self.command}, helpText or "")
    self.usePid = usePid
    self._ped = ped
    self.onClick = function(dict, animation)
        -- anim.playAnim(self.ped, dict, animation, -1)
        self.playbackInstance = AnimPlayback.new(self.ped, dict, animation, 0.0, function(elapsedTime)

            AnimXUtils.debugLog(string.format("Animation stopped. Elapsed time: %f s", elapsedTime))
            -- TODO Fix delayed delete

        end)

        self.playbackInstance:start()
    end

    -- Ignore other players
    if (not self.usePid) or self.pid == players.user() then
        -- Create the animation select list
        -- TODO Fix expired pid when changing session
        self.animSelectRef = menu.list(self.reference, trans.AnimSelect, {}, trans.AnimSelectDesc)

        if searchOpt then self:createSearchList(self.animSelectRef, LOC.misc.search) end

        for caption, value in pairs_by_keys(self.options) do
            if type(value) == "table" then
                -- Check whether the table has two keys, "dict" and "animation".
                -- If so, add the option to the menu.
                -- Otherwise, add a submenu.
                if value.dict and value.animation then
                    self:addOpt(self.animSelectRef, caption, value.dict, value.animation)
                else
                    local section = menu.list(self.animSelectRef, caption, {}, "")
                    self:addSection(section, value)
                end
            end
        end

        menu.action(self.reference, trans.StopAnim, {}, trans.StopAnimDesc,
            function() if self.playbackInstance then self.playbackInstance:stop() end end)
    end

    if not self.usePid then
        if PED.IS_PED_A_PLAYER(self.ped) then return end
        self.interactionToMeSelectRef = menu.list(self.reference, trans.InteractionSelect, {},
            trans.InteractionSelectDesc)

        local usingRape
        local dildo
        self.interactionToMeSelectRef:toggle("Rape", {}, "", function(on)
            if self.ped == players.user_ped() then
                util.toast("Cannot use on yourself!")
                return
            end
            if on then
                usingRape = true

                request_control(self.ped, 1000)
                AnimXUtils.requestModelLoad("h4_prop_battle_glowstick_01")
                dildo = AnimXUtils.createEntityAndAttachTo(0.0, 0.15, 0.0, self.ped, -90.0, 0.0, 35.0,
                    "h4_prop_battle_glowstick_01", BoneIds.SKEL_Pelvis, false, false)

                local target = players.user_ped()
                STREAMING.REQUEST_ANIM_DICT("rcmpaparazzo_2")
                while not STREAMING.HAS_ANIM_DICT_LOADED("rcmpaparazzo_2") do util.yield_once() end
                TASK.TASK_PLAY_ANIM(self.ped, "rcmpaparazzo_2", "shag_loop_a", 8.0, -8.0, -1, 1, 0.0, false, false,
                    false)
                TASK.TASK_PLAY_ANIM(players.user_ped(), "rcmpaparazzo_2", "shag_loop_poppy", 8.0, -8.0, -1, 1, 0.0, false, false,
                    false)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(self.ped, target, PED.GET_PED_BONE_INDEX(target, BoneIds.NONE), 0, -0.4,
                    0, 0.0, 0.0, 0.0, false, true, false, false, 0, true, 0)

            else
                usingRape = false
                entities.delete(dildo)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.ped)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
                ENTITY.DETACH_ENTITY(self.ped, true, false)
            end

        end)

    end

    if not (self.usePid and self.pid == players.user()) then
        self.interactionByMeSelectRef = menu.list(self.reference, trans.InteractionByMeSelect, {},
            trans.InteractionByMeSelectDesc)
        self.interactionByMeSelectRef:toggle("Hooker Sex", {}, "", function(on)
            if self.ped == players.user_ped() then
                util.toast("Cannot use on yourself!")
                return
            end
            if on then
                local target = self.ped
                STREAMING.REQUEST_ANIM_DICT("misscarsteal2pimpsex")
                while not STREAMING.HAS_ANIM_DICT_LOADED("misscarsteal2pimpsex") do util.yield_once() end
                TASK.TASK_PLAY_ANIM(players.user_ped(), "misscarsteal2pimpsex", "shagloop_hooker", 8.0, -8.0, -1, 1,
                    0.0, false, false, false)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), target,
                    PED.GET_PED_BONE_INDEX(target, BoneIds.SKEL_ROOT), 0, 0.3, 0, 0.0, 0.0, 180.0, false, true, false,
                    false, 0, true, 0)

            else
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
                ENTITY.DETACH_ENTITY(players.user_ped(), true, false)
            end

        end)
    end
    return self
end

---@param ped integer
function AnimMenu:refreshPed(ped) self._ped = ped end

---@param parent integer
---@param caption string
---@param dict string
---@param animation string
function AnimMenu:addOpt(parent, caption, dict, animation)
    local command = self.command ~= "" and self.command .. caption or ""

    return menu.action(parent, caption, {command}, "", function(click)
        if self.changeName then
            local newName = string.format("%s: %s", self.name, caption)
            menu.set_menu_name(self.reference, newName)
        end
        if (click & CLICK_FLAG_AUTO) == 0 then menu.focus(self.animSelectRef) end
        if self.onClick then self.onClick(dict, animation) end
    end)
end

---@param parent integer
---@param tbl table<string, string>
---@param outReferences integer[]?
function AnimMenu:addSection(parent, tbl, outReferences)
    for caption, value in pairs_by_keys(tbl) do
        local reference = self:addOpt(parent, caption, value.dict, value.animation)
        if outReferences then table.insert(outReferences, reference) end
    end
end

---@param parent integer
---@param menu_name string
function AnimMenu:createSearchList(parent, menu_name)
    local reference = menu.list(parent, menu_name, {}, "")

    menu.action(reference, menu_name, {}, "", function(click)
        if (CLICK_FLAG_AUTO & click) ~= 0 then return end

        for _, reference in ipairs(self.foundOpts) do
            menu.delete(reference)
            self.foundOpts = {}
        end

        local text = get_input_from_screen_keyboard(CustomLabels.Search, 20, "")
        if text == "" then
            return
        else
            text = string.lower(text)
        end

        for caption, value in pairs(self.options) do
            if type(value) == "table" then
                for sub_caption, sub_value in pairs(value) do
                    local lower_caption = string.lower(sub_caption)
                    local lower_dict = string.lower(sub_value.dict)
                    local lower_animation = string.lower(sub_value.animation)
                    if lower_caption:find(text) or lower_dict:find(text) or lower_animation:find(text) then
                        local opt = self:addOpt(reference, caption .. " > " .. sub_caption, sub_value.dict,
                            sub_value.animation)
                        table.insert(self.foundOpts, opt)
                    end
                end
            end
        end
    end)
end

---@param section string
---@param find string
---@param tbl table<string, string>
---@return table
function AnimMenu.getSectionMatches(section, find, tbl)
    local matches = {}
    find = string.lower(find)

    for caption, model in pairs(tbl) do
        if string.lower(caption):find(find) or model:find(find) then matches[section .. " > " .. caption] = model end
    end
    return matches
end
 end)
package.preload['src.lib.actorlib.component'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-------------------------------------
-- COMPONENT
-------------------------------------
---@class Component
Component = {
    reference = 0,
    drawableId = -1,
    textureId = 0,
    componentId = 0
}
Component.__index = Component

local trans<const> = {
    Type = LOC.wardrobe.type,
    Texture = LOC.wardrobe.texture
}

---@param parent integer
---@param name string
---@param ped number
---@param componentId integer
---@param onChange fun(drawable: integer, texture: integer)
function Component.new(parent, name, ped, componentId, onChange)
    local self = setmetatable({}, Component)
    self.reference = menu.list(parent, name, {}, "")
    self.componentId = componentId

    local numDrawables = PED.GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS(ped, componentId)
    self.drawableId = PED.GET_PED_DRAWABLE_VARIATION(ped, componentId)
    local textureSlider

    menu.slider(self.reference, trans.Type, {}, "", -1, numDrawables - 1, self.drawableId, 1,
        function(value, prev, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then return end
            self.drawableId = value
            local numTextures = PED.GET_NUMBER_OF_PED_TEXTURE_VARIATIONS(ped, componentId, value)
            menu.set_max_value(textureSlider, numTextures - 1)
            self.textureId = 0
            menu.set_value(textureSlider, self.textureId)
            onChange(self.drawableId, self.textureId)
        end)

    self.textureId = PED.GET_PED_TEXTURE_VARIATION(ped, componentId)
    local currentNumTextures = PED.GET_NUMBER_OF_PED_TEXTURE_VARIATIONS(ped, componentId, self.drawableId)

    textureSlider = menu.slider(self.reference, trans.Texture, {}, "", 0, currentNumTextures - 1, self.textureId, 1,
        function(value, prev, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then return end
            self.textureId = value
            onChange(self.drawableId, self.textureId)
        end)

    return self
end
 end)
package.preload['src.lib.actorlib.group'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-------------------------------------
-- GROUP
-------------------------------------
Formation = {
    freedomToMove = 0,
    circleAroundLeader = 1,
    line = 3,
    arrow = 4
}

---@class Group
Group = {
    ID = 0,
    ---@type Member[]
    members = {},
    numMembers = 0,
    formation = Formation.freedomToMove,
    defaults = {
        invincible = false,
        weaponHash = util.joaat("weapon_heavypistol")
    },
    rg = util.joaat("rgFM_HateEveryOne")
}
Group.__index = Group

---@return Group
function Group.new()
    local self = setmetatable({}, Group)
    for num = 0, 6, 1 do
        local ped = PED.GET_PED_AS_GROUP_MEMBER(self.getID(), num)
        if ENTITY.DOES_ENTITY_EXIST(ped) and request_control(ped, 1000) then self:pushMember(Member.new(ped)) end
    end
    return self
end

---@return integer
function Group.getID() return PLAYER.GET_PLAYER_GROUP(players.user()) end

---@return integer
function Group:getSize()
    local unkPtr, sizePtr = memory.alloc(1), memory.alloc(1)
    PED.GET_GROUP_SIZE(self.getID(), unkPtr, sizePtr)
    return memory.read_int(sizePtr)
end

---@param member Member
function Group:pushMember(member)
    if not PED.IS_PED_IN_GROUP(member.handle) then
        PED.SET_PED_AS_GROUP_MEMBER(member.handle, self.getID())
        PED.SET_PED_NEVER_LEAVES_GROUP(member.handle, true)
    end
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(member.handle, self.rg)
    PED.SET_GROUP_SEPARATION_RANGE(self.getID(), 9999.0)
    PED.SET_GROUP_FORMATION_SPACING(self.getID(), 1.0, -1.0, -1.0)
    PED.SET_GROUP_FORMATION(self.getID(), self.formation)
    table.insert(self.members, member)
    self.numMembers = self.numMembers + 1
end

---@param rgHash Hash
function Group:setRelationshipGrp(rgHash)
    for num = 0, 6, 1 do
        local ped = PED.GET_PED_AS_GROUP_MEMBER(self.getID(), num)
        if ENTITY.DOES_ENTITY_EXIST(ped) and request_control(ped, 1000) then
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(ped, rgHash)
        end
    end
    self.rg = rgHash
end

function Group:onTick()
    if self.numMembers == 0 then return end

    for i = self.numMembers, 1, -1 do
        local member = self.members[i]
        local ped = member.handle

        if not ENTITY.DOES_ENTITY_EXIST(ped) or PED.IS_PED_INJURED(ped) then
            self.numMembers = self.numMembers - 1
            member:removeMgr()
            table.remove(self.members, i)
            set_entity_as_no_longer_needed(ped)
            goto LABEL_CONTINUE
        end

        if not PED.IS_PED_IN_GROUP(ped) then
            PED.SET_PED_AS_GROUP_MEMBER(ped, self.getID())
            PED.SET_PED_NEVER_LEAVES_GROUP(ped, true)
        end

        if (member.isMgrOpen or member.mgr:isFocused()) and menu.is_open() then
            draw_bounding_box(ped, true, {
                r = 255,
                g = 255,
                b = 255,
                a = 80
            })
        end
        ::LABEL_CONTINUE::
    end
end

---@param formation integer
function Group:setFormation(formation)
    self.formation = formation
    PED.SET_GROUP_FORMATION(self.getID(), formation)
end

function Group:deleteMembers()
    for num = 0, 6, 1 do
        local ped = PED.GET_PED_AS_GROUP_MEMBER(self.getID(), num)
        if ENTITY.DOES_ENTITY_EXIST(ped) and request_control(ped, 1000) then entities.delete(ped) end
    end
end

---@param value boolean
function Group:setInvincible(value)
    for _, member in ipairs(self.members) do member:setInvincible(value) end
    self.defaults.invincible = value
end

function Group:teleport() for _, member in ipairs(self.members) do member:tp() end end
 end)
package.preload['src.lib.actorlib.member'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-------------------------------------
-- MEMBER
-------------------------------------
---@diagnostic enable: exp-in-action, unknown-symbol, break-outside, code-after-break, miss-symbol
---@class Member
---@field handle integer
---@field mgr integer|CommandRef
---@field isMgrOpen boolean
---@field invincible boolean
Member = {
    handle = 0,
    mgr = 0,
    isMgrOpen = false,
    invincible = false,
    references = {
        invincible = 0,
        teleport = 0
    },
    weaponHash = 0,
    ---@type Wardrobe
    wardrobe = nil,
    ---@type AnimMenu
    animMenu = nil
}
Member.__index = Member

---@param ped number
---@return Member
function Member.new(ped)
    local self = setmetatable({}, Member)
    self.handle = ped
    TASK.CLEAR_PED_TASKS(ped)
    PED.SET_PED_HIGHLY_PERCEPTIVE(ped, true)
    PED.SET_PED_SEEING_RANGE(ped, 100.0)

    PED.SET_PED_CAN_PLAY_AMBIENT_ANIMS(ped, false)
    PED.SET_PED_CAN_PLAY_AMBIENT_BASE_ANIMS(ped, false)

    PED.SET_PED_CONFIG_FLAG(ped, 208, true) -- PCF_DisableExplosionReactions
    PED.SET_PED_CONFIG_FLAG(ped, 400, true) -- PCF_IgnorePedTypeForIsFriendlyWith

    PED.SET_COMBAT_FLOAT(ped, 12, 1.0)

    PED.SET_RAGDOLL_BLOCKING_FLAGS(ped, 1) -- RBF_BULLET_IMPACT
    PED.SET_RAGDOLL_BLOCKING_FLAGS(ped, 4) -- RBF_FIRE

    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 5, true) -- CA_ALWAYS_FIGHT
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 1, true) -- CA_USE_VEHICLE
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 0, false) -- CA_USE_COVER
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true) -- CA_CAN_FIGHT_ARMED_PEDS_WHEN_NOT_ARMED
    PED.SET_PED_COMBAT_ATTRIBUTES(ped, 58, true) -- CA_DISABLE_FLEE_FROM_COMBAT

    PED.SET_PED_FLEE_ATTRIBUTES(ped, 512, true) -- FA_NEVER_FLEE

    PED.SET_PED_ALLOW_VEHICLES_OVERRIDE(ped, true)
    add_ai_blip_for_ped(ped, true, false, 100.0, 2, -1)
    return self
end

---@diagnostic enable:undefined-global
---@param modelHash? Hash
function Member:createMember(modelHash)
    local pos = get_random_offset_from_entity(players.user_ped(), 2.0, 3.0)
    pos.z = pos.z - 1.0
    local ped = NULL
    modelHash = modelHash or 0
    if modelHash ~= 0 then
        ped = entities.create_ped(28, modelHash, pos, 0.0)
    else
        local userModelHash = ENTITY.GET_ENTITY_MODEL(players.user_ped())
        ped = entities.create_ped(28, userModelHash, pos, 0.0)
    end
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.PED_TO_NET(ped), true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, false, true)
    NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(NETWORK.PED_TO_NET(ped), players.user(), true)
    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ped, true, 1)

    if modelHash == 0 then PED.CLONE_PED_TO_TARGET(players.user_ped(), ped) end
    set_entity_face_entity(ped, players.user_ped(), false)
    return Member.new(ped)
end

function Member:removeMgr()
    if self.mgr == 0 then return end
    menu.delete(self.mgr);
    self.mgr = 0
end

function Member:delete()
    if ENTITY.DOES_ENTITY_EXIST(self.handle) and request_control(self.handle, 1000) then
        entities.delete(self.handle);
        self.handle = 0
    end
end

local trans = {
    Invincible = LOC.actorMenu.invincible,
    TpToMe = LOC.actorMenu.tpToMe,
    TpToMePrecise = LOC.actorMenu.tpToMePrecise,
    TrimPosition = LOC.actorMenu.trimPosition,
    DisableCollisionWithMe = LOC.actorMenu.disableCollisionWithMe,
    Delete = LOC.actorMenu.delete,
    Weapon = LOC.actorMenu.weapon,
    Appearance = LOC.actorMenu.appearance,
    AnimMenu = LOC.animMenu.animMenu,
    AnimMenuDesc = LOC.animMenu.animMenuD,
    Save = LOC.actorMenu.save,
    ActorSaved = LOC.actorMenu.actorSaved,
    SaveCanceled = LOC.actorMenu.saveCanceled
}

---Creates the list to edit some properties of the actor
---@param parent integer
---@param name string
function Member:createMgr(parent, name)
    self.mgr = menu.list(parent, name, {}, "", function() self.isMgrOpen = true end,
        function() self.isMgrOpen = false end)

    self.references = {}
    if not is_ped_any_animal(self.handle) then
        WeaponList.new(self.mgr, trans.Weapon, "", "", function(caption, model)
            local hash<const> = util.joaat(model)
            self:giveWeapon(hash);
            self.weaponHash = hash
        end, true)
    end

    self.references.invincible = menu.toggle(self.mgr, trans.Invincible, {}, "", function(on)
        request_control(self.handle, 1000)
        ENTITY.SET_ENTITY_INVINCIBLE(self.handle, on)
        ENTITY.SET_ENTITY_PROOFS(self.handle, on, on, on, on, on, on, on, on)
    end)

    self.references.teleport = menu.action(self.mgr, trans.TpToMe, {}, "", function()
        request_control(self.handle, 1000)
        if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            self:tpToLeader(true)
        else
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
            self:tpToVehicle(vehicle)
        end
    end)

    menu.action(self.mgr, trans.TpToMePrecise, {}, "", function()
        request_control(self.handle, 1000)
        if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            self:tpToLeader(false)
        else
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
            self:tpToVehicle(vehicle)
        end
    end)

    menu.action(self.mgr, trans.TrimPosition, {}, "", function()
        -- TODO
    end)

    menu.action(self.mgr, trans.Save, {}, "", function()
        local ok, errmsg = self:save()
        if not ok then
            notification:help(errmsg, HudColour.red)
            return
        end
        notification:normal(trans.ActorSaved)
    end)

    self.wardrobe = Wardrobe.new(self.mgr, trans.Appearance, {}, "", self.handle)

    self.animMenu = AnimMenu.new(self.mgr, trans.AnimMenu, "animxanimmenu", trans.AnimMenuDesc, false, self.handle,
        function(dict, animation)
            -- anim.playAnim(self.handle, dict, animation, -1)
        end, false, true)

    -- static void SET_ENTITY_NO_COLLISION_ENTITY(int entity1, int entity2, BOOL thisFrameOnly)
    self.mgr:action(trans.DisableCollisionWithMe, {}, "",
        function() ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(self.handle, players.user_ped(), false) end)

    menu.action(self.mgr, trans.Delete, {}, "", function()
        self:delete()
        self:removeMgr()
    end)
end

---@param value boolean
function Member:setInvincible(value)
    assert(self.references.invincible ~= 0, "actor manager not found")
    menu.set_value(self.references.invincible, value)
end

---@param weaponHash Hash
function Member:giveWeapon(weaponHash)
    WEAPON.REMOVE_ALL_PED_WEAPONS(self.handle, true)
    WEAPON.GIVE_WEAPON_TO_PED(self.handle, weaponHash, 9999, true, true)
    WEAPON.SET_CURRENT_PED_WEAPON(self.handle, weaponHash, false)
end

---@param vehicle number
function Member:tpToVehicle(vehicle)
    if not VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) or
        (PED.IS_PED_IN_ANY_VEHICLE(self.handle, false) and PED.GET_VEHICLE_PED_IS_IN(self.handle, false) == vehicle) then
        return
    end
    local seat
    for i = -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do
        if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, false) then
            seat = i
            break
        end
    end
    PED.SET_PED_INTO_VEHICLE(self.handle, vehicle, seat)
end

---@param randomOffset boolean
function Member:tpToLeader(randomOffset)
    local pos = randomOffset and get_random_offset_from_entity(players.user_ped(), 2.0, 3.0) or
                    ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    pos.z = pos.z - 1.0
    ENTITY.SET_ENTITY_COORDS(self.handle, pos.x, pos.y, pos.z, false, false, false, false)
    set_entity_face_entity(self.handle, players.user_ped(), false)
end

function Member:tp()
    assert(self.references.teleport ~= 0, "actor manager not found")
    menu.trigger_command(self.references.teleport, "")
end

function Member:getInfo()
    local pWeaponHash = memory.alloc_int()
    WEAPON.GET_CURRENT_PED_WEAPON(self.handle, pWeaponHash, true)
    local tbl = {
        WeaponHash = memory.read_int(pWeaponHash),
        Outfit = self.wardrobe:getOutfit(),
        ModelHash = ENTITY.GET_ENTITY_MODEL(self.handle)
    }
    return tbl
end

---@return boolean
---@return string? errmsg
function Member:save()
    local input = ""
    local label = CustomLabels.EnterFileName
    while true do
        input = get_input_from_screen_keyboard(label, 31, "")
        if input == "" then return false, trans.SaveCanceled end

        if not input:find '[^%w_%.%-]' then break end
        label = CustomLabels.InvalidChar
        util.yield(250)
    end
    local path = AnimXDir .. "actors\\" .. input .. ".json"
    local file, errmsg = io.open(path, "w")
    if not file then return false, errmsg end
    file:write(json.stringify(self:getInfo(), nil, 0, false))
    file:close()
    return true
end

---@param obj Outfit
---@return boolean
---@return string? errmsg
function Member:setOutfit(obj)
    local types = {
        components = "table",
        props = "table"
    }
    for k, v in pairs(types) do
        local ok, errmsg = type_match(obj[k], v)
        if not ok then return false, "field " .. k .. ' ' .. errmsg end
    end

    for componentId, tbl in pairs(obj.components) do
        if math.tointeger(componentId) and type(tbl.drawableId) == "number" and type(tbl.textureId) == "number" and
            request_control(self.handle) then
            PED.SET_PED_COMPONENT_VARIATION(self.handle, math.tointeger(componentId), tbl.drawableId, tbl.textureId, 2)
        end
    end

    for propId, tbl in pairs(obj.props) do
        if math.tointeger(propId) and type(tbl.drawableId) == "number" and type(tbl.textureId) == "number" and
            request_control(self.handle) then
            PED.SET_PED_PROP_INDEX(self.handle, math.tointeger(propId), tbl.drawableId, tbl.textureId, true)
        end
    end
    return true
end

 end)
package.preload['src.lib.actorlib.models'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-----------------------------------
-- PEDS LIST
-----------------------------------
---@class ModelList
ModelList = {
    reference = 0,
    default = nil,
    name = "",
    command = "",
    ---@type fun(caption: string, model: string)?
    onClick = nil,
    changeName = false,
    ---@type table
    options = {},
    foundOpts = {}
}
ModelList.__index = ModelList

---@param parent integer
---@param name string
---@param command string
---@param helpText string
---@param tbl table
---@param onClick? fun(caption: string, model: string)
---@param changeName boolean #If the list's name will change to show the selected model.
---@param searchOpt boolean
---@return ModelList
function ModelList.new(parent, name, command, helpText, tbl, onClick, changeName, searchOpt)
    local self = setmetatable({}, ModelList)
    self.name = name
    self.command = command
    self.onClick = onClick
    self.changeName = changeName
    self.foundOpts = {}
    self.options = tbl
    self.reference = menu.list(parent, name, {self.command}, helpText or "")

    if searchOpt then self:createSearchList(self.reference, LOC.misc.search) end

    for caption, value in pairs_by_keys(self.options) do
        if type(value) == "string" then
            self:addOpt(self.reference, caption, value)

        elseif type(value) == "table" then
            local section = menu.list(self.reference, caption, {}, "")
            self:addSection(section, value)
        end
    end

    return self
end

---@param parent integer
---@param caption string
---@param model string
function ModelList:addOpt(parent, caption, model)
    local command = self.command ~= "" and self.command .. caption or ""

    return menu.action(parent, caption, {command}, "", function(click)
        if self.changeName then
            local newName = string.format("%s: %s", self.name, caption)
            menu.set_menu_name(self.reference, newName)
        end
        if (click & CLICK_FLAG_AUTO) == 0 then menu.focus(self.reference) end
        if self.onClick then self.onClick(caption, model) end
    end)
end

---@param parent integer
---@param tbl table<string, string>
---@param outReferences integer[]?
function ModelList:addSection(parent, tbl, outReferences)
    for caption, name in pairs_by_keys(tbl) do
        local reference = self:addOpt(parent, caption, name)
        if outReferences then table.insert(outReferences, reference) end
    end
end

---@param parent integer
---@param menu_name string
function ModelList:createSearchList(parent, menu_name)
    local reference = menu.list(parent, menu_name, {}, "")

    menu.action(reference, menu_name, {}, "", function(click)
        if (CLICK_FLAG_AUTO & click) ~= 0 then return end

        for _, reference in ipairs(self.foundOpts) do
            menu.delete(reference)
            self.foundOpts = {}
        end

        local text = get_input_from_screen_keyboard(CustomLabels.Search, 20, "")
        if text == "" then
            return
        else
            text = string.lower(text)
        end

        for caption, value in pairs(self.options) do
            if type(value) == "string" then
                if string.lower(caption):find(text) or value:find(text) then
                    local opt = self:addOpt(reference, caption, value)
                    table.insert(self.foundOpts, opt)
                end

            elseif type(value) == "table" then
                local tbl = value
                local matches = self.getSectionMatches(caption, text, tbl)
                self:addSection(reference, matches, self.foundOpts)
            end
        end
    end)
end

---@param section string
---@param find string
---@param tbl table<string, string>
---@return table
function ModelList.getSectionMatches(section, find, tbl)
    local matches = {}
    find = string.lower(find)

    for caption, model in pairs(tbl) do
        if string.lower(caption):find(find) or model:find(find) then matches[section .. " > " .. caption] = model end
    end
    return matches
end
 end)
package.preload['src.lib.actorlib.prop'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-------------------------------------
-- PROP
-------------------------------------
---@class Prop
Prop = {
    reference = 0,
    componentId = -1,
    drawableId = 0,
    textureId = 0
}
Prop.__index = Prop

local trans<const> = {
    Type = LOC.wardrobe.type,
    Texture = LOC.wardrobe.texture
}

---@param parent integer
---@param name string
---@param ped Ped
---@param componentId integer
---@param onChange fun(drawableId: integer, textureId: integer)
function Prop.new(parent, name, ped, componentId, onChange)
    local self = setmetatable({}, Prop)
    self.reference = menu.list(parent, name, {}, "")
    self.componentId = componentId

    local numDrawables = PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(ped, componentId)
    self.drawableId = PED.GET_PED_PROP_INDEX(ped, componentId)
    local textureSlider

    menu.slider(self.reference, trans.Type, {}, "", -1, numDrawables - 1, self.drawableId, 1,
        function(drawableId, prev, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then return end
            self.drawableId = drawableId
            local numTextures = PED.GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS(ped, componentId, drawableId)
            menu.set_max_value(textureSlider, numTextures - 1)
            self.textureId = 0
            menu.set_value(textureSlider, self.textureId)
            onChange(self.drawableId, self.textureId)
        end)

    self.textureId = PED.GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS(ped, componentId, self.drawableId)
    local currentNumTextures = PED.GET_PED_PROP_TEXTURE_INDEX(ped, componentId)

    textureSlider = menu.slider(self.reference, trans.Texture, {}, "", 0, currentNumTextures - 1, self.textureId, 1,
        function(value, prev, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then return end
            self.textureId = value
            onChange(self.drawableId, self.textureId)
        end)

    return self
end

 end)
package.preload['src.lib.actorlib.wardrobe'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-------------------------------------
-- WARDROBE
-------------------------------------
---@class Wardrobe
Wardrobe = {
    reference = 0,
    ---@type table<number, Component>
    components = {},
    ---@type table<number, Prop>
    props = {}
}
Wardrobe.__index = Wardrobe

local components<const> = {
    [0] = LOC.wardrobe.head,
    [1] = LOC.wardrobe.beardMask,
    [2] = LOC.wardrobe.hair,
    [3] = LOC.wardrobe.glovesTorso,
    [4] = LOC.wardrobe.legs,
    [5] = LOC.wardrobe.handsBack,
    [6] = LOC.wardrobe.shoes,
    [7] = LOC.wardrobe.teethScarfNecklaceBracelets,
    [8] = LOC.wardrobe.accessoriesTops,
    [9] = LOC.wardrobe.taskArmour,
    [10] = LOC.wardrobe.decals,
    [11] = LOC.wardrobe.torso2
}

local props<const> = {
    [0] = LOC.wardrobe.hat,
    [1] = LOC.wardrobe.classes,
    [2] = LOC.wardrobe.earwear,
    [6] = LOC.wardrobe.watch,
    [7] = LOC.wardrobe.bracelet
}

---@param parent integer
---@param menu_name string
---@param command_names string[]
---@param help_text string
---@param ped number
---@return Wardrobe
function Wardrobe.new(parent, menu_name, command_names, help_text, ped)
    local self = setmetatable({}, Wardrobe)
    self.reference = menu.list(parent, menu_name, command_names, help_text, function() self.isOpen = true end,
        function() self.isOpen = false end)
    self.components, self.props = {}, {}

    for componentId, name in pairs_by_keys(components, function(a, b) return a < b end) do
        if PED.GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS(ped, componentId) < 1 then
            -- Skip
        else
            self.components[componentId] = Component.new(self.reference, name, ped, componentId,
                function(drawableId, textureId)
                    request_control(ped)
                    PED.SET_PED_COMPONENT_VARIATION(ped, componentId, drawableId, textureId, 2)
                end)
        end
    end

    for propId, name in pairs_by_keys(props, function(a, b) return a < b end) do
        if PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(ped, propId) < 1 then
            -- continue
        else
            self.props[propId] = Prop.new(self.reference, name, ped, propId, function(drawableId, textureId)
                request_control(ped)
                if drawableId == -1 then
                    PED.CLEAR_PED_PROP(ped, propId)
                else
                    PED.SET_PED_PROP_INDEX(ped, propId, drawableId, textureId, true)
                end
            end)
        end
    end

    return self
end

---@alias Component_t {drawableId: integer, textureId: integer}
---@alias Prop_t Component_t
---@alias Outfit {components: table<integer, Component_t>, props: table<integer, Prop_t>}

---@return Outfit
function Wardrobe:getOutfit()
    assert(self.reference ~= 0, "wardrobe reference does not exist")
    local tbl = {
        components = {},
        props = {}
    }

    for componentId, component in pairs(self.components) do
        tbl.components[componentId] = {
            drawableId = component.drawableId,
            textureId = component.textureId
        }
    end

    for propId, prop in pairs(self.props) do
        tbl.props[propId] = {
            drawableId = prop.drawableId,
            textureId = prop.textureId
        }
    end

    return tbl
end
 end)
package.preload['src.lib.actorlib.weaponsMenu'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-----------------------------------
-- WEAPONS LIST
-----------------------------------
local Weapons<const> = {
    -- Shotguns
    VAULT_WMENUI_2 = {
        WT_SG_PMP = "weapon_pumpshotgun",
        WT_SG_PMP2 = "weapon_pumpshotgun_mk2",
        WT_SG_SOF = "weapon_sawnoffshotgun",
        WT_SG_BLP = "weapon_bullpupshotgun",
        WT_SG_ASL = "weapon_assaultshotgun",
        WT_MUSKET = "weapon_musket",
        WT_HVYSHOT = "weapon_heavyshotgun",
        WT_DBSHGN = "weapon_dbshotgun",
        WT_AUTOSHGN = "weapon_autoshotgun",
        WT_CMBSHGN = "weapon_combatshotgun"
    },
    -- Machine guns
    VAULT_WMENUI_3 = {
        WT_SMG_MCR = "weapon_microsmg",
        WT_MCHPIST = "weapon_machinepistol",
        WT_MINISMG = "weapon_minismg",
        WT_SMG = "weapon_smg",
        WT_SMG2 = "weapon_smg_mk2",
        WT_SMG_ASL = "weapon_assaultsmg",
        WT_COMBATPDW = "weapon_combatpdw",
        WT_MG = "weapon_mg",
        WT_MG_CBT = "weapon_combatmg",
        WT_MG_CBT2 = "weapon_combatmg_mk2",
        WT_GUSENBERG = "weapon_gusenberg",
        WT_RAYCARBINE = "weapon_raycarbine"
    },
    -- Rifles
    VAULT_WMENUI_4 = {
        WT_RIFLE_ASL = "weapon_assaultrifle",
        WT_RIFLE_ASL2 = "weapon_assaultrifle_mk2",
        WT_RIFLE_CBN = "weapon_carbinerifle",
        WT_RIFLE_CBN2 = "weapon_carbinerifle_mk2",
        WT_RIFLE_ADV = "weapon_advancedrifle",
        WT_RIFLE_SCBN = "weapon_specialcarbine",
        WT_SPCARBINE2 = "weapon_specialcarbine_mk2",
        WT_BULLRIFLE = "weapon_bullpuprifle",
        WT_BULLRIFLE2 = "weapon_bullpuprifle_mk2",
        WT_CMPRIFLE = "weapon_compactrifle",
        WT_MLTRYRFL = "weapon_militaryrifle",
        WT_HEAVYRIFLE = "WEAPON_HEAVYRIFLE",
        WT_TACRIFLE = "WEAPON_TACTICALRIFLE"
    },
    -- Sniper rifles
    VAULT_WMENUI_5 = {
        WT_SNIP_RIF = "weapon_sniperrifle",
        WT_SNIP_HVY = "weapon_heavysniper",
        WT_SNIP_HVY2 = "weapon_heavysniper_mk2",
        WT_MKRIFLE = "weapon_marksmanrifle",
        WT_MKRIFLE2 = "weapon_marksmanrifle_mk2",
        WT_PRCSRIFLE = "WEAPON_PRECISIONRIFLE"
    },
    -- Heavy weapons
    VAULT_WMENUI_6 = {
        WT_GL = "weapon_grenadelauncher",
        WT_RPG = "weapon_rpg",
        WT_MINIGUN = "weapon_minigun",
        WT_FWRKLNCHR = "weapon_firework",
        WT_RAILGUN = "weapon_railgun",
        WT_HOMLNCH = "weapon_hominglauncher",
        WT_CMPGL = "weapon_compactlauncher",
        WT_RAYMINIGUN = "weapon_rayminigun"
    },
    -- Melee weapons
    VAULT_WMENUI_8 = {
        WT_UNARMED = "weapon_unarmed",
        WT_KNIFE = "weapon_knife",
        WT_NGTSTK = "weapon_nightstick",
        WT_HAMMER = "weapon_hammer",
        WT_BAT = "weapon_bat",
        WT_CROWBAR = "weapon_crowbar",
        WT_GOLFCLUB = "weapon_golfclub",
        WT_BOTTLE = "weapon_bottle",
        WT_DAGGER = "weapon_dagger",
        WT_SHATCHET = "weapon_stone_hatchet",
        WT_KNUCKLE = "weapon_knuckle",
        WT_MACHETE = "weapon_machete",
        WT_FLASHLIGHT = "weapon_flashlight",
        WT_SWTCHBLDE = "weapon_switchblade",
        WT_BATTLEAXE = "weapon_battleaxe",
        WT_POOLCUE = "weapon_poolcue",
        WT_WRENCH = "weapon_wrench",
        WT_HATCHET = "weapon_hatchet"
    },
    -- Pistols
    VAULT_WMENUI_9 = {
        WT_PIST = "weapon_pistol",
        WT_PIST2 = "weapon_pistol_mk2",
        WT_PIST_CBT = "weapon_combatpistol",
        WT_PIST_50 = "weapon_pistol50",
        WT_SNSPISTOL = "weapon_snspistol",
        WT_SNSPISTOL2 = "weapon_snspistol_mk2",
        WT_HEAVYPSTL = "weapon_heavypistol",
        WT_VPISTOL = "weapon_vintagepistol",
        WT_CERPST = "weapon_ceramicpistol",
        WT_MKPISTOL = "weapon_marksmanpistol",
        WT_REVOLVER = "weapon_revolver",
        WT_REVOLVER2 = "weapon_revolver_mk2",
        WT_REV_DA = "weapon_doubleaction",
        WT_REV_NV = "weapon_navyrevolver",
        WT_GDGTPST = "weapon_gadgetpistol",
        WT_STUN = "weapon_stungun",
        WT_FLAREGUN = "weapon_flaregun",
        WT_RAYPISTOL = "weapon_raypistol",
        WT_PIST_AP = "weapon_appistol"
    }
}

---@class WeaponList
WeaponList = {
    reference = 0,
    ---@type string?
    name = "",
    ---@type string?
    command = "",
    ---@type fun(caption: string, model: string)?
    onClick = nil,
    changeName = false,
    selected = nil
}
WeaponList.__index = WeaponList

---@param parent integer
---@param name string
---@param command? string
---@param helpText? string
---@param onClick? fun(caption: string, model: string)
---@param changeName boolean
---@return WeaponList
function WeaponList.new(parent, name, command, helpText, onClick, changeName)
    local self = setmetatable({}, WeaponList)
    self.name = name
    self.command = command
    self.changeName = changeName
    self.onClick = onClick
    self.reference = menu.list(parent, name, {self.command}, helpText or "")

    for section, tbl in pairs_by_keys(Weapons) do self:addSection(section, tbl) end

    return self
end

---@param parent integer
---@param label string
---@param model string
function WeaponList:addOpt(parent, label, model)
    local name = util.get_label_text(label)
    local command = self.command ~= "" and self.command .. name or ""
    menu.action(parent, name, {command}, "", function(click)
        if self.changeName then
            local newName = string.format("%s: %s", self.name, name)
            menu.set_menu_name(self.reference, newName)
        end
        self.selected = model
        if click == CLICK_MENU then menu.focus(self.reference) end
        if self.onClick then self.onClick(name, model) end
    end)
end

---@param section string
---@param weapons table<string, string>
function WeaponList:addSection(section, weapons)
    local list = menu.list(self.reference, util.get_label_text(section), {}, "")
    for label, model in pairs_by_keys(weapons) do self:addOpt(list, label, model) end
end
 end)
package.preload['src.consts.ped_list'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				return {
    ["Animal"] = {
        ["Hawk"] = "a_c_chickenhawk",
        ["Crow"] = "a_c_crow",
        ["Coyote"] = "a_c_coyote",
        ["Boar"] = "a_c_boar",
        ["Pug"] = "a_c_pug",
        ["Deer"] = "a_c_deer",
        ["Hen"] = "a_c_hen",
        ["Mountain Lion"] = "a_c_mtlion",
        ["Cow"] = "a_c_cow",
        ["Hammerhead Shark"] = "a_c_sharkhammer",
        ["Pigeon"] = "a_c_pigeon",
        ["Rottweiler"] = "a_c_rottweiler",
        ["Seagull"] = "a_c_seagull",
        ["Pig"] = "a_c_pig",
        ["Humpback"] = "a_c_humpback",
        ["Australian Shepherd"] = "a_c_shepherd",
        ["Killer Whale"] = "a_c_killerwhale",
        ["Dolphin"] = "a_c_dolphin",
        ["Fish"] = "a_c_fish",
        ["Westie"] = "a_c_westy",
        ["Tiger Shark"] = "a_c_sharktiger",
        ["Panther"] = "a_c_panther",
        ["Cat"] = "a_c_cat_01",
        ["Husky"] = "a_c_husky",
        ["Cormorant"] = "a_c_cormorant",
        ["Retriever"] = "a_c_retriever",
        ["Rabbit"] = "a_c_rabbit_01",
        ["Rat"] = "a_c_rat",
        ["Chimp"] = "a_c_chimp",
        ["Stingray"] = "a_c_stingray",
        ["Poodle"] = "a_c_poodle",
        ["Chop"] = "a_c_chop",
        ["Rhesus"] = "a_c_rhesus"
    },
    ["Story Scenario Male"] = {
        ["Tattoo Artist"] = "u_m_y_tattoo_01",
        ["Mani"] = "u_m_y_mani",
        ["Jesco White (Tapdancing Hillbilly)"] = "u_m_o_taphillbilly",
        ["Jeweller Security"] = "u_m_m_jewelsec_01",
        ["Paparazzi Young Male"] = "u_m_y_paparazzi",
        ["Prologue Security"] = "u_m_m_prolsec_01",
        ["Ushi"] = "u_m_y_ushi",
        ["Kifflom Guy"] = "u_m_y_baygor",
        ["Jesus"] = "u_m_m_jesus_01",
        ["Street Art Male"] = "u_m_m_streetart_01",
        ["Vince"] = "u_m_m_vince",
        ["Glen-Stank Male"] = "u_m_m_glenstank_01",
        ["Ex-Mil Bum"] = "u_m_y_militarybum",
        ["Prologue Mourner Male"] = "u_m_m_promourn_01",
        ["Republican Space Ranger"] = "u_m_y_rsranger_01",
        ["Hippie Male"] = "u_m_y_hippie_01",
        ["Ed Toh"] = "u_m_m_edtoh",
        ["Stag Party Groom"] = "u_m_y_staggrm_01",
        ["Sports Biker"] = "u_m_y_sbike",
        ["Spy Actor"] = "u_m_m_spyactor",
        ["Rival Paparazzo"] = "u_m_m_rivalpap",
        ["Hangar Mechanic"] = "u_m_y_smugmech_01",
        ["Male Club Dancer (Leather)"] = "u_m_y_dancelthr_01",
        ["Pogo the Monkey"] = "u_m_y_pogo_01",
        ["Prologue Driver"] = "u_m_y_proldriver_01",
        ["Prisoner"] = "u_m_y_prisoner_01",
        ["Anton Beaudelaire"] = "u_m_y_antonb",
        ["Love Fist Willy"] = "u_m_m_willyfist",
        ["Griff"] = "u_m_m_griff_01",
        ["Party Target"] = "u_m_m_partytarget",
        ["Chip"] = "u_m_y_chip",
        ["Jewel Thief"] = "u_m_m_jewelthief",
        ["Movie Director"] = "u_m_m_filmdirector",
        ["Mark Fostenburg"] = "u_m_m_markfost",
        ["Partygoer"] = "u_m_y_party_01",
        ["Blane"] = "u_m_m_blane",
        ["Justin"] = "u_m_y_justin",
        ["Movie Corpse (Suited)"] = "u_m_o_filmnoir",
        ["Cyclist Male"] = "u_m_y_cyclist_01",
        ["Male Club Dancer (Burlesque)"] = "u_m_y_danceburl_01",
        ["Male Club Dancer (Rave)"] = "u_m_y_dancerave_01",
        ["Impotent Rage"] = "u_m_y_imporage",
        ["Zombie"] = "u_m_y_zombie_01",
        ["Gabriel"] = "u_m_y_gabriel",
        ["Bike Hire Guy"] = "u_m_m_bikehire_01",
        ["Dead Courier"] = "u_m_y_corpse_01",
        ["Gun Vendor"] = "u_m_y_gunvend_01",
        ["Guido"] = "u_m_y_guido_01",
        ["Tramp Old Male"] = "u_m_o_tramp_01",
        ["Bank Manager Male"] = "u_m_m_bankman",
        ["Abner"] = "u_m_y_abner",
        ["Burger Drug Worker"] = "u_m_y_burgerdrug_01",
        ["Baby D"] = "u_m_y_babyd",
        ["FIB Mugger"] = "u_m_y_fibmugger_01",
        ["DOA Man"] = "u_m_m_doa_01",
        ["Al Di Napoli Male"] = "u_m_m_aldinapoli",
        ["Financial Guru"] = "u_m_o_finguru_01",
        ["Dean"] = "u_m_o_dean",
        ["Curtis"] = "u_m_m_curtis",
        ["FIB Architect"] = "u_m_m_fibarchitect",
        ["Casino Thief"] = "u_m_y_croupthief_01",
        ["Caleb"] = "u_m_y_caleb",
        ["Avon Juggernaut"] = "u_m_y_juggernaut_01"
    },
    ["Cutscene"] = {
        ["Brucie Kibbutz"] = "csb_brucie2",
        ["Marine"] = "csb_ramp_marine",
        ["Natalia"] = "cs_natalia",
        ["Cletus"] = "csb_cletus",
        ["Jack Howitzer"] = "csb_jackhowitzer",
        ["Island Dj 2"] = "csb_isldj_02",
        ["Dale"] = "cs_dale",
        ["United Paper Man"] = "cs_paper",
        ["Burger Drug Worker"] = "csb_burgerdrug",
        ["Jimmy De Santa 2"] = "cs_jimmydisanto2",
        ["Simeon Yetarian"] = "cs_siemonyetarian",
        ["Oscar"] = "csb_oscar",
        ["Hugh Welsh"] = "csb_hugh",
        ["Tao Cheng"] = "cs_taocheng",
        ["Mary-Ann Quinn"] = "cs_maryann",
        ["Merryweather Merc"] = "csb_mweather",
        ["Mrs. Thornhill"] = "cs_mrs_thornhill",
        ["Tennis Coach"] = "cs_tenniscoach",
        ["Nervous Ron"] = "cs_nervousron",
        ["Vagos Speak"] = "csb_vagspeak",
        ["FIB Suit"] = "cs_fbisuit_01",
        ["Movie Premiere Female"] = "cs_movpremf_01",
        ["Steve Haines"] = "cs_stevehains",
        ["DJ Black Madonna"] = "csb_djblamadon",
        ["Hipster"] = "csb_ramp_hipster",
        ["Vincent (Casino)"] = "csb_vincent",
        ["Anita Mendoza"] = "csb_anita",
        ["Mjo"] = "csb_mjo",
        ["Tony Prince"] = "csb_tonyprince",
        ["Avon Hertz"] = "csb_avon",
        ["Dave Norton"] = "cs_davenorton",
        ["Michelle"] = "cs_michelle",
        ["Stretch"] = "cs_stretch",
        ["Vincent (Casino) 2"] = "csb_vincent_2",
        ["Hick"] = "csb_ramp_hic",
        ["Manuel"] = "cs_manuel",
        ["Casey"] = "cs_casey",
        ["Cris Formage"] = "cs_chrisformage",
        ["Agent 14"] = "csb_mp_agent14",
        ["Ballas OG"] = "csb_ballasog",
        ["Marnie Allen"] = "cs_marnie",
        ["Jimmy Boston"] = "cs_jimmyboston",
        ["Epsilon Tom"] = "cs_tomepsilon",
        ["Thornton Duggan"] = "csb_thornton",
        ["Maude"] = "csb_maude",
        ["Miguel Madrazo"] = "csb_miguelmadrazo",
        ["Island Dj 1"] = "csb_isldj_01",
        ["Devin"] = "cs_devin",
        ["Minuteman Joe"] = "cs_joeminuteman",
        ["Denise"] = "cs_denise",
        ["Island Dj 4"] = "csb_isldj_04",
        ["Ferdinand Kerimov (Mr. K)"] = "cs_mrk",
        ["Dom Beasley"] = "cs_dom",
        ["Agent"] = "csb_agent",
        ["Grove Street Dealer"] = "csb_grove_str_dlr",
        ["Chinese Goon"] = "csb_chin_goon",
        ["Peter Dreyfuss"] = "cs_dreyfuss",
        ["Dima Popov"] = "csb_popov",
        ["Dr. Friedlander"] = "cs_drfriedlander",
        ["Wade"] = "cs_wade",
        ["Island Dj"] = "csb_isldj_00",
        ["sessanta"] = "csb_sessanta",
        ["Ashley Butler"] = "cs_ashley",
        ["Barry"] = "cs_barry",
        ["Reporter"] = "csb_reporter",
        ["Drug Dealer"] = "csb_drugdealer",
        ["Tale of Us 1"] = "csb_talcc",
        ["Fabien"] = "cs_fabien",
        ["Stripper"] = "csb_stripper_01",
        ["Jeweller Assistant"] = "cs_jewelass",
        ["Johnny Klebitz"] = "cs_johnnyklebitz",
        ["Tao Cheng (Casino)"] = "cs_taocheng2",
        ["Alan Jerome"] = "csb_alan",
        ["FOS Rep"] = "csb_fos_rep",
        ["Wei Cheng"] = "cs_chengsr",
        ["Abigail Mathers"] = "csb_abigail",
        ["Imran Shinowa"] = "csb_imran",
        ["Car 3 Guy 1"] = "csb_car3guy1",
        ["Avi Schwartzman"] = "csb_avischwartzman_02",
        ["Tao's Translator (Casino)"] = "cs_taostranslator2",
        ["Floyd Hebert"] = "cs_floyd",
        ["Lester Crest 3"] = "cs_lestercrest_3",
        ["Denise's Friend"] = "csb_denise_friend",
        ["Groom"] = "csb_groom",
        ["Dixon"] = "csb_dix",
        ["Hao 2"] = "csb_hao_02",
        ["Huang"] = "csb_huang",
        ["Old Man 1"] = "cs_old_man1a",
        ["Beverly Felton"] = "cs_beverly",
        ["Patricia 2"] = "cs_patricia2",
        ["Wendy"] = "csb_wendy",
        ["Janet"] = "cs_janet",
        ["Georgina Cheng"] = "csb_georginacheng",
        ["Money Man"] = "csb_money",
        ["Stripper 2"] = "csb_stripper_02",
        ["Jimmy De Santa"] = "cs_jimmydisanto",
        ["Maxim Rashkovsky"] = "csb_rashcosvki",
        ["Amanda De Santa"] = "cs_amandatownley",
        ["Lazlow 2"] = "cs_lazlow_2",
        ["Celeb 1"] = "csb_celeb_01",
        ["Hunter"] = "cs_hunter",
        ["Tale of Us 2"] = "csb_talmm",
        ["Soloman"] = "csb_sol",
        ["English Dave 2"] = "csb_englishdave2",
        ["Tonya"] = "csb_tonya",
        ["English Dave"] = "csb_englishdave",
        ["Life Invader"] = "cs_lifeinvad_01",
        ["Karen Daniels"] = "cs_karen_daniels",
        ["Island Dj 3"] = "csb_isldj_03",
        ["Molly"] = "cs_molly",
        ["Ary"] = "csb_ary",
        ["Undercover Cop"] = "csb_undercover",
        ["Traffic Warden"] = "csb_trafficwarden",
        ["Nigel"] = "cs_nigel",
        ["Bank Manager"] = "cs_bankman",
        ["Chef"] = "csb_chef2",
        ["Tracey De Santa"] = "cs_tracydisanto",
        ["Priest"] = "cs_priest",
        ["Guadalope"] = "cs_guadalope",
        ["Bigfoot"] = "cs_orleans",
        ["Brad's Cadaver"] = "cs_bradcadaver",
        ["Tom Connors"] = "csb_tomcasino",
        ["Tom"] = "cs_tom",
        ["Omega"] = "cs_omega",
        ["Tao's Translator"] = "cs_taostranslator",
        ["Tanisha"] = "cs_tanisha",
        ["Sss"] = "csb_sss",
        ["Solomon Richards"] = "cs_solomon",
        ["Prologue Security 2"] = "cs_prolsec_02",
        ["Russian Drunk"] = "cs_russiandrunk",
        ["Rocco Pelosi"] = "csb_roccopelosi",
        ["Screenwriter"] = "csb_screen_writer",
        ["Prologue Security"] = "csb_prolsec",
        ["Prologue Driver"] = "csb_prologuedriver",
        ["Hao"] = "csb_hao",
        ["Lazlow"] = "cs_lazlow",
        ["Bride"] = "csb_bride",
        ["Lester Crest"] = "cs_lestercrest",
        ["Clay Simons (The Lost)"] = "cs_clay",
        ["Patricia"] = "cs_patricia",
        ["GURK"] = "cs_gurk",
        ["Customer"] = "csb_customer",
        ["Gerald"] = "csb_g",
        ["Janitor"] = "csb_janitor",
        ["Porn Dude"] = "csb_porndudes",
        ["Paige Harris"] = "csb_paige",
        ["Mrs. Rackman"] = "csb_mrs_r",
        ["Bryony"] = "csb_bryony",
        ["Gustavo"] = "csb_gustavo",
        ["Terry"] = "cs_terry",
        ["Martin Madrazo"] = "cs_martinmadrazo",
        ["Old Man 2"] = "cs_old_man2",
        ["Andreas Sanchez"] = "cs_andreas",
        ["Debra"] = "cs_debra",
        ["Movie Premiere Male"] = "cs_movpremmale",
        ["Lamar Davis"] = "cs_lamardavis",
        ["Josef"] = "cs_josef",
        ["Zimbor"] = "cs_zimbor",
        ["Avery Duggan"] = "csb_avery",
        ["Bogdan"] = "csb_bogdan",
        ["Juan Strickler"] = "csb_juanstrickler",
        ["Helmsman Pavel"] = "csb_helmsmanpavel ",
        ["Magenta"] = "cs_magenta",
        ["Brad"] = "cs_brad",
        ["Moodyman"] = "csb_moodyman_02",
        ["Milton McIlroy"] = "cs_milton",
        ["Families Gang Member"] = "csb_ramp_gang",
        ["Ortega"] = "csb_ortega",
        ["Mimi"] = "csb_mimi",
        ["Josh"] = "cs_josh",
        ["Jio"] = "csb_jio",
        ["Cop"] = "csb_cop",
        ["Mrs. Phillips"] = "cs_mrsphillips",
        ["Mexican"] = "csb_ramp_mex",
        ["Car 3 Guy 2"] = "csb_car3guy2",
        ["Agatha Baker"] = "csb_agatha",
        ["Anton Beaudelaire"] = "csb_anton",
        ["Car Buyer"] = "cs_carbuyer"
    },
    ["Others"] = {
        ["Jewel Heist Gunman"] = "hc_gunman",
        ["Jewel Heist Driver"] = "hc_driver",
        ["Jewel Heist Hacker"] = "hc_hacker"
    },
    ["Scenario Male"] = {
        ["Postal Worker Male 2"] = "s_m_m_postal_02",
        ["IAA Security"] = "s_m_m_ciasec_01",
        ["Marine"] = "s_m_m_marine_01",
        ["Dealer"] = "s_m_y_dealer_01",
        ["High Security 2"] = "s_m_m_highsec_02",
        ["Life Invader Male"] = "s_m_m_lifeinvad_01",
        ["Movie Astronaut"] = "s_m_m_movspace_01",
        ["Street Vendor"] = "s_m_m_strvend_01",
        ["Street Vendor Young"] = "s_m_y_strvend_01",
        ["Snow Cop Male"] = "s_m_m_snowcop_01",
        ["Pilot"] = "s_m_y_pilot_01",
        ["Clown"] = "s_m_y_clown_01",
        ["FIB Office Worker 2"] = "s_m_m_fiboffice_02",
        ["Casino Staff"] = "s_m_y_casino_01",
        ["Army Mechanic"] = "s_m_y_armymech_01",
        ["Doctor"] = "s_m_m_doctor_01",
        ["Hairdresser Male"] = "s_m_m_hairdress_01",
        ["Ammu-Nation Rural Clerk"] = "s_m_m_ammucountry",
        ["FIB Office Worker"] = "s_m_m_fiboffice_01",
        ["Baywatch Male"] = "s_m_y_baywatch_01",
        ["Bouncer 2"] = "s_m_m_bouncer_02",
        ["Pest Control"] = "s_m_y_pestcont_01",
        ["Street Preacher"] = "s_m_m_strpreach_01",
        ["Busker"] = "s_m_o_busker_01",
        ["DW Airport Worker"] = "s_m_y_dwservice_01",
        ["Mariachi"] = "s_m_m_mariachi_01",
        ["Latino Handyman Male"] = "s_m_m_lathandy_01",
        ["Doorman"] = "s_m_y_doorman_01",
        ["High Security"] = "s_m_m_highsec_01",
        ["Black Ops Soldier"] = "s_m_y_blackops_01",
        ["High Security 3"] = "s_m_m_highsec_03",
        ["Warehouse Technician"] = "s_m_y_waretech_01",
        ["Factory Worker Male"] = "s_m_y_factory_01",
        ["Postal Worker Male"] = "s_m_m_postal_01",
        ["Crew Member"] = "s_m_m_ccrew_01",
        ["Prisoner"] = "s_m_y_prisoner_01",
        ["Duggan Secruity"] = "s_m_y_westsec_01",
        ["Cop Male"] = "s_m_y_cop_01",
        ["Devin's Security"] = "s_m_y_devinsec_01",
        ["DW Airport Worker 2"] = "s_m_y_dwservice_02",
        ["Prisoner (Muscular)"] = "s_m_y_prismuscl_01",
        ["Busboy"] = "s_m_y_busboy_01",
        ["Window Cleaner"] = "s_m_y_winclean_01",
        ["Chef"] = "s_m_y_chef_01",
        ["Waiter"] = "s_m_y_waiter_01",
        ["Robber"] = "s_m_y_robber_01",
        ["Field Worker"] = "s_m_m_fieldworker_01",
        ["FIB Security"] = "s_m_m_fibsec_01",
        ["Movie Premiere Male"] = "s_m_m_movprem_01",
        ["US Coastguard"] = "s_m_y_uscg_01",
        ["Highway Cop"] = "s_m_y_hwaycop_01",
        ["Security Guard"] = "s_m_m_security_01",
        ["Autoshop Worker 3"] = "s_m_m_Autoshop_03",
        ["Bartender (Rural)"] = "s_m_m_cntrybar_01",
        ["Line Cook"] = "s_m_m_linecook",
        ["UPS Driver 2"] = "s_m_m_ups_02",
        ["UPS Driver"] = "s_m_m_ups_01",
        ["Sheriff Male"] = "s_m_y_sheriff_01",
        ["Trucker Male"] = "s_m_m_trucker_01",
        ["Air Worker Male"] = "s_m_y_airworker",
        ["Ammu-Nation City Clerk"] = "s_m_y_ammucity_01",
        ["Grip"] = "s_m_y_grip_01",
        ["Marine Young 3"] = "s_m_y_marine_03",
        ["SWAT"] = "s_m_y_swat_01",
        ["Marine Young 2"] = "s_m_y_marine_02",
        ["Bouncer"] = "s_m_m_bouncer_01",
        ["Armoured Van Security"] = "s_m_m_armoured_01",
        ["Scientist"] = "s_m_m_scientist_01",
        ["Mask Salesman"] = "s_m_y_shop_mask",
        ["Mime Artist"] = "s_m_y_mime",
        ["Street Performer"] = "s_m_m_strperf_01",
        ["Janitor"] = "s_m_m_janitor",
        ["Club Bartender Male"] = "s_m_y_clubbar_01",
        ["Dock Worker"] = "s_m_y_dockwork_01",
        ["Fireman Male"] = "s_m_y_fireman_01",
        ["Valet"] = "s_m_y_valet_01",
        ["Marine Young"] = "s_m_y_marine_01",
        ["Ranger Male"] = "s_m_y_ranger_01",
        ["Migrant Male"] = "s_m_m_migrant_01",
        ["Autoshop Worker 2"] = "s_m_m_autoshop_02",
        ["Black Ops Soldier 3"] = "s_m_y_blackops_03",
        ["Duggan Security 2"] = "s_m_y_westsec_02",
        ["Barman"] = "s_m_y_barman_01",
        ["Mechanic"] = "s_m_y_xmech_01",
        ["Paramedic"] = "s_m_m_paramedic_01",
        ["Garbage Worker"] = "s_m_y_garbage",
        ["Racer Organisator"] = "s_m_m_raceorg_01",
        ["Alien"] = "s_m_m_movalien_01",
        ["Marine 2"] = "s_m_m_marine_02",
        ["construction Worker 2"] = "s_m_y_construct_02",
        ["Autopsy Tech"] = "s_m_y_autopsy_01",
        ["Autoshop Worker"] = "s_m_m_autoshop_01",
        ["Gaffer"] = "s_m_m_gaffer_01",
        ["LS Metro Worker Male"] = "s_m_m_lsmetro_01",
        ["High Security 4"] = "s_m_m_highsec_04",
        ["Black Ops Soldier 2"] = "s_m_y_blackops_02",
        ["Transport Worker Male"] = "s_m_m_gentransport",
        ["Armoured Van Security 2"] = "s_m_m_armoured_02",
        ["Gardener"] = "s_m_m_gardener_01",
        ["construction Worker"] = "s_m_y_construct_01",
        ["Prison Guard"] = "s_m_m_prisguard_01",
        ["Drug Processer"] = "s_m_m_drugprocess_01",
        ["Pilot 2"] = "s_m_m_pilot_02",
        ["Tattoo Artist 2"] = "s_m_m_tattoo_01",
        ["MC Clubhouse Mechanic"] = "s_m_y_xmech_02",
        ["Chemical Plant Security"] = "s_m_m_chemsec_01"
    },
    ["Story Scenario Female"] = {
        ["Miranda"] = "u_f_m_miranda",
        ["Corpse Young Female"] = "u_f_y_corpse_01",
        ["Casino Cashier"] = "u_f_m_casinocash_01",
        ["Female Club Dancer (Rave)"] = "u_f_y_dancerave_01",
        ["Poppy Mitchell"] = "u_f_y_poppymich",
        ["Jeweller Assistant"] = "u_f_y_jewelass_01",
        ["Prologue Mourner Female"] = "u_f_m_promourn_01",
        ["Poppy Mitchell 2"] = "u_f_y_poppymich_02",
        ["Biker Chic Female"] = "u_f_y_bikerchic",
        ["Jane"] = "u_f_y_comjane",
        ["Casino shop owner"] = "u_f_m_casinoshop_01",
        ["Carol"] = "u_f_o_carol",
        ["Spy Actress"] = "u_f_y_spyactress",
        ["Eileen"] = "u_f_o_eileen",
        ["Female Club Dancer (Burlesque)"] = "u_f_y_danceburl_01",
        ["Prologue Host Old Female"] = "u_f_o_prolhost_01",
        ["Debbie (AgathaÂ´s Secretary)"] = "u_f_m_debbie_01",
        ["Movie Star Female"] = "u_f_o_moviestar",
        ["Taylor"] = "u_f_y_taylor",
        ["Female Club Dancer (Leather)"] = "u_f_y_dancelthr_01",
        ["Mistress"] = "u_f_y_mistress",
        ["Corpse Young Female 2"] = "u_f_y_corpse_02",
        ["Miranda 2"] = "u_f_m_miranda_02",
        ["Lauren"] = "u_f_y_lauren",
        ["Princess"] = "u_f_y_princess",
        ["Corpse Female"] = "u_f_m_corpse_01",
        ["Hot Posh Female"] = "u_f_y_hotposh_01",
        ["Beth"] = "u_f_y_beth"
    },
    ["Scenario Female"] = {
        ["Factory Worker Female"] = "s_f_y_factory_01",
        ["Sales Assistant (Low-End)"] = "s_f_y_shop_low",
        ["Barber Female"] = "s_f_m_fembarber",
        ["Air Hostess"] = "s_f_y_airhostess_01",
        ["Hooker 3"] = "s_f_y_hooker_03",
        ["Sales Assistant (Mid-Price)"] = "s_f_y_shop_mid",
        ["Movie Premiere Female"] = "s_f_y_movprem_01",
        ["Autoshop Worker Female"] = "s_f_m_autoshop_01",
        ["Club Bartender Female 2"] = "s_f_y_clubbar_02",
        ["Stripper 2"] = "s_f_y_stripper_02",
        ["Hospital Scrubs Female"] = "s_f_y_scrubs_01",
        ["Club Bartender Female"] = "s_f_y_clubbar_01",
        ["Sweatshop Worker Young"] = "s_f_y_sweatshop_01",
        ["Maid"] = "s_f_m_maid_01",
        ["Stripper"] = "s_f_y_stripper_01",
        ["Stripper Lite"] = "s_f_y_stripperlite",
        ["Sheriff Female"] = "s_f_y_sheriff_01",
        ["Migrant Female"] = "s_f_y_migrant_01",
        ["Sweatshop Worker"] = "s_f_m_sweatshop_01",
        ["Sales Assistant (High-End)"] = "s_f_m_shop_high",
        ["Casino Staff"] = "s_f_y_casino_01",
        ["Baywatch Female"] = "s_f_y_baywatch_01",
        ["Retailstaff"] = "s_f_m_retailstaff_01",
        ["Cop Female"] = "s_f_y_cop_01",
        ["Beach Bar Staff"] = "s_f_y_beachbarstaff_01",
        ["Bartender"] = "s_f_y_bartender_01",
        ["Ranger Female"] = "s_f_y_ranger_01",
        ["Hooker 2"] = "s_f_y_hooker_02",
        ["Hooker"] = "s_f_y_hooker_01"
    },
    ["Gang Female"] = {
        ["Ballas Female"] = "g_f_y_ballas_01",
        ["Gang Female (Import-Export)"] = "g_f_importexport_01",
        ["Import Export Female"] = "g_f_importexport_01",
        ["Vagos Female"] = "g_f_y_vagos_01",
        ["The Lost MC Female"] = "g_f_y_lost_01",
        ["Families Female"] = "g_f_y_families_01"
    },
    ["Story"] = {
        ["Brucie Kibbutz"] = "ig_brucie2",
        ["DJ Rupert"] = "ig_djblamrupert",
        ["Lester Crest"] = "ig_lestercrest",
        ["Cletus"] = "ig_cletus",
        ["Benny"] = "ig_benny",
        ["Clay Simons (The Lost)"] = "ig_clay",
        ["Dale"] = "ig_dale",
        ["United Paper Man"] = "ig_paper",
        ["Island Dj 4D2"] = "ig_isldj_04_D_02",
        ["Sacha Yetarian"] = "ig_sacha",
        ["Simeon Yetarian"] = "ig_siemonyetarian",
        ["Tao Cheng"] = "ig_taocheng",
        ["Mary-Ann Quinn"] = "ig_maryann",
        ["Mrs. Thornhill"] = "ig_mrs_thornhill",
        ["Tennis Coach"] = "ig_tenniscoach",
        ["Nervous Ron"] = "ig_nervousron",
        ["FIB Suit"] = "ig_fbisuit_01",
        ["Steve Haines"] = "ig_stevehains",
        ["DJ Black Madonna"] = "ig_djblamadon",
        ["Hipster"] = "ig_ramp_hipster",
        ["Vincent (Casino)"] = "ig_vincent",
        ["Jackie"] = "ig_jackie",
        ["Mjo"] = "ig_mjo",
        ["Tony Prince"] = "ig_tonyprince",
        ["Milton McIlroy"] = "ig_milton",
        ["Dave Norton"] = "ig_davenorton",
        ["Michelle"] = "ig_michelle",
        ["Stretch"] = "ig_stretch",
        ["Vincent (Casino) 2"] = "ig_vincent_2",
        ["Hick"] = "ig_ramp_hic",
        ["Manuel"] = "ig_manuel",
        ["Casey"] = "ig_casey",
        ["Cris Formage"] = "ig_chrisformage",
        ["Agent 14"] = "ig_mp_agent14",
        ["Ballas OG"] = "ig_ballasog",
        ["Marnie Allen"] = "ig_marnie",
        ["Jimmy Boston"] = "ig_jimmyboston",
        ["Avi Schawrtzman"] = "ig_avischwartzman_02",
        ["Soloman Manager"] = "ig_djsolmanager",
        ["Thornton Duggan"] = "ig_thornton",
        ["Maude"] = "ig_maude",
        ["Sessanta"] = "ig_sessanta",
        ["Lil Dee"] = "ig_lildee",
        ["Miguel Madrazo"] = "ig_miguelmadrazo",
        ["Island Dj 1"] = "ig_isldj_01",
        ["Clay Jackson (The Pain Giver)"] = "ig_claypain",
        ["Minuteman Joe"] = "ig_joeminuteman",
        ["Denise"] = "ig_denise",
        ["Island Dj 4"] = "ig_isldj_04",
        ["Ferdinand Kerimov (Mr. K)"] = "ig_mrk",
        ["Dom Beasley"] = "ig_dom",
        ["Agent"] = "ig_agent",
        ["DJ Fotios"] = "ig_djsolfotios",
        ["DJ Rob T"] = "ig_djsolrobt",
        ["Peter Dreyfuss"] = "ig_dreyfuss",
        ["Dima Popov"] = "ig_popov",
        ["Dr. Friedlander"] = "ig_drfriedlander",
        ["Wade"] = "ig_wade",
        ["Island Dj"] = "ig_isldj_00",
        ["Agatha Baker"] = "ig_agatha",
        ["Ashley Butler"] = "ig_ashley",
        ["Barry"] = "ig_barry",
        ["Tale of Us 1"] = "ig_talcc",
        ["Fabien"] = "ig_fabien",
        ["Jeweller Assistant"] = "ig_jewelass",
        ["Johnny Klebitz"] = "ig_johnnyklebitz",
        ["Tao Cheng (Casino)"] = "ig_taocheng2",
        ["Best Man"] = "ig_bestmen",
        ["Kerry McIntosh"] = "ig_kerrymcintosh",
        ["Pilot"] = "ig_pilot",
        ["Wendy"] = "ig_wendy",
        ["Lester Crest 3"] = "ig_lestercrest_3",
        ["Franklin"] = "player_one",
        ["Abigail Mathers"] = "ig_abigail",
        ["Jimmy De Santa 2"] = "ig_jimmydisanto2",
        ["Ary"] = "ig_ary",
        ["Tom Connors"] = "ig_tomcasino",
        ["Georgina Cheng"] = "ig_georginacheng",
        ["Car 3 Guy 1"] = "ig_car3guy1",
        ["Benny (Los Santos Tuners)"] = "ig_benny_02",
        ["Tao's Translator (Casino)"] = "ig_taostranslator2",
        ["Floyd Hebert"] = "ig_floyd",
        ["Malc"] = "ig_malc",
        ["Drugdealer"] = "ig_drugdealer",
        ["Old Man 2"] = "ig_old_man2",
        ["Dixon"] = "ig_dix",
        ["Celeb 1"] = "ig_celeb_01",
        ["Huang"] = "ig_huang",
        ["Old Man 1"] = "ig_old_man1a",
        ["Lester Crest (Doomsday Heist)"] = "ig_lestercrest_2",
        ["Patricia 2"] = "ig_patricia_02",
        ["Tyler Dixon 2"] = "ig_tylerdix_02",
        ["Janet"] = "ig_janet",
        ["Tale of Us 2"] = "ig_talmm",
        ["Money Man"] = "ig_money",
        ["Soloman"] = "ig_sol",
        ["Jimmy De Santa"] = "ig_jimmydisanto",
        ["Maxim Rashkovsky"] = "ig_rashcosvki",
        ["Helmsman Pavel"] = "ig_helmsmanpavel",
        ["Lazlow 2"] = "ig_lazlow_2",
        ["Lacy Jones 2"] = "ig_lacey_jones_02",
        ["Kerry McIntosh 2"] = "ig_kerrymcintosh_02",
        ["Jimmy Boston 2"] = "ig_jimmyboston_02",
        ["DJ Dixon Manager"] = "ig_djdixmanager",
        ["Island Dj 4E"] = "ig_isldj_04_E_01",
        ["Tonya"] = "ig_tonya",
        ["English Dave"] = "ig_englishdave_02",
        ["Life Invader"] = "ig_lifeinvad_01",
        ["Karen Daniels"] = "ig_karen_daniels",
        ["Island Dj 3"] = "ig_isldj_03",
        ["Molly"] = "ig_molly",
        ["Beverly Felton"] = "ig_beverly",
        [" DJ Aurelia"] = "ig_djtalaurelia",
        ["Kaylee"] = "ig_kaylee",
        ["Nigel"] = "ig_nigel",
        ["Bank Manager"] = "ig_bankman",
        ["Chef"] = "ig_chef2",
        ["DJ Ignazio"] = "ig_djtalignazio",
        ["Priest"] = "ig_priest",
        ["Mimi"] = "ig_mimi",
        ["Bigfoot"] = "ig_orleans",
        ["DJ Jakob"] = "ig_djsoljakob",
        ["DJ Ryan S"] = "ig_djblamryans",
        ["DJ Mike T"] = "ig_djsolmike",
        ["Wei Cheng"] = "ig_chengsr",
        ["Vagos Funeral Speaker"] = "ig_vagspeak",
        ["Jio"] = "ig_jio",
        ["Life Invader 2"] = "ig_lifeinvad_02",
        ["Traffic Warden"] = "ig_trafficwarden",
        ["Tracey De Santa"] = "ig_tracydisanto",
        ["Groom"] = "ig_groom",
        ["Tao's Translator"] = "ig_taostranslator",
        ["Trevor"] = "player_two",
        ["Tanisha"] = "ig_tanisha",
        ["Talina"] = "ig_talina",
        ["Hao"] = "ig_hao",
        ["Lazlow"] = "ig_lazlow",
        ["Bride"] = "ig_bride",
        ["Jay Norris"] = "ig_jay_norris",
        ["Sss"] = "ig_sss",
        ["Patricia"] = "ig_patricia",
        ["Island Dj 2"] = "ig_isldj_02",
        ["Russian Drunk"] = "ig_russiandrunk",
        ["Gerald"] = "ig_g",
        ["Solomon Richards"] = "ig_solomon",
        ["Screenwriter"] = "ig_screen_writer",
        ["Generic DJ"] = "ig_djgeneric_01",
        ["Rocco Pelosi"] = "ig_roccopelosi",
        ["Prologue Security 2"] = "ig_prolsec_02",
        ["Gustavo"] = "ig_gustavo",
        ["Terry"] = "ig_terry",
        ["Paige Harris"] = "ig_paige",
        ["Avon Hertz"] = "ig_avon",
        ["Andreas Sanchez"] = "ig_andreas",
        ["Moodyman"] = "ig_moodyman_02",
        ["O'Neil Brothers"] = "ig_oneil",
        ["Lamar Davis"] = "ig_lamardavis",
        ["Josef"] = "ig_josef",
        ["Zimbor"] = "ig_zimbor",
        ["Avery Duggan"] = "ig_avery",
        ["Old Rich Guy"] = "ig_oldrichguy",
        ["Island Dj 4D"] = "ig_isldj_04_D_01",
        ["Omega"] = "ig_omega",
        ["Magenta"] = "ig_magenta",
        ["Brad"] = "ig_brad",
        ["Amanda De Santa"] = "ig_amandatownley",
        ["Natalia"] = "ig_natalia",
        ["Hunter"] = "ig_hunter",
        ["Ortega"] = "ig_ortega",
        ["Josh"] = "ig_josh",
        ["Epsilon Tom"] = "ig_tomepsilon",
        ["Devin"] = "ig_devin",
        ["Juan Strickler"] = "ig_juanstrickler",
        ["Mrs. Phillips"] = "ig_mrsphillips",
        ["Mexican"] = "ig_ramp_mex",
        ["Car 3 Guy 2"] = "ig_car3guy2",
        ["Families Gang Member"] = "ig_ramp_gang",
        ["Michael"] = "player_zero",
        ["Tyler Dixon"] = "ig_tylerdix"
    },
    ["Gang Male"] = {
        ["Polynesian Goon 2"] = "g_m_y_pologoon_02",
        ["Armenian Lieutenant"] = "g_m_m_armlieut_01",
        ["The Lost MC Male 2"] = "g_m_y_lost_02",
        ["Mexican Boss"] = "g_m_m_mexboss_01",
        ["Cartel Guard"] = "g_m_m_cartelguards_01",
        ["Azteca"] = "g_m_y_azteca_01",
        ["Street Punk"] = "g_m_y_strpunk_01",
        ["Mexican Goon"] = "g_m_y_mexgoon_01",
        ["Armenian Goon 2"] = "g_m_y_armgoon_02",
        ["Chinese Goon Older"] = "g_m_m_chicold_01",
        ["Casino Guests"] = "g_m_m_casrn_01",
        ["Mexican Goon 2"] = "g_m_y_mexgoon_02",
        ["Gang Prisoner Male"] = "g_m_m_prisoners_01",
        ["Salvadoran Goon 3"] = "g_m_y_salvagoon_03",
        ["Armenian Boss"] = "g_m_m_armboss_01",
        ["Cartel Guard 2"] = "g_m_m_cartelguards_02",
        ["Korean Young Male 2"] = "g_m_y_korean_02",
        ["The Lost MC Male"] = "g_m_y_lost_01",
        ["Mexican Boss 2"] = "g_m_m_mexboss_02",
        ["Families DNF Male"] = "g_m_y_famdnf_01",
        ["Street Punk 2"] = "g_m_y_strpunk_02",
        ["Chinese Goon"] = "g_m_m_chigoon_01",
        ["Families FOR Male"] = "g_m_y_famfor_01",
        ["Gang Male (Import-Export)"] = "g_m_importexport_01",
        ["The Lost MC Male 3"] = "g_m_y_lost_03",
        ["Korean Boss"] = "g_m_m_korboss_01",
        ["Salvadoran Goon 2"] = "g_m_y_salvagoon_02",
        ["Mexican Gang Member"] = "g_m_y_mexgang_01",
        ["Polynesian Goon"] = "g_m_y_pologoon_01",
        ["Salvadoran Boss"] = "g_m_y_salvaboss_01",
        ["Salvadoran Goon"] = "g_m_y_salvagoon_01",
        ["Mexican Goon 3"] = "g_m_y_mexgoon_03",
        ["Korean Young Male"] = "g_m_y_korean_01",
        ["Ballas Original Male"] = "g_m_y_ballaorig_01",
        ["Families CA Male"] = "g_m_y_famca_01",
        ["Korean Lieutenant"] = "g_m_y_korlieut_01",
        ["Armenian Goon"] = "g_m_m_armgoon_01",
        ["Gang Slasher Male"] = "g_m_m_slasher_01",
        ["Chinese Boss"] = "g_m_m_chiboss_01",
        ["Ballas South Male"] = "g_m_y_ballasout_01",
        ["Chinese Goon 2"] = "g_m_m_chigoon_02",
        ["Ballas East Male"] = "g_m_y_ballaeast_01",
        ["Chemical Plant Worker"] = "g_m_m_chemwork_01"
    },
    ["Multiplayer"] = {
        ["Boat-Staff Female"] = "mp_f_boatstaff_01",
        ["Securoserve Guard (Male)"] = "mp_m_securoguard_01",
        ["Bogdan Goon"] = "mp_m_bogdangoon",
        ["Dead Hooker"] = "mp_f_deadhooker",
        ["Claude Speed"] = "mp_m_claude_01",
        ["Biker Meth Male"] = "mp_m_meth_01",
        ["Biker Weed Female"] = "mp_f_weed_01",
        ["Executive PA Female 2"] = "mp_f_execpa_02",
        ["Freemode Male"] = "mp_m_freemode_01",
        ["Families DD Male"] = "mp_m_famdd_01",
        ["Misty"] = "mp_f_misty_01",
        ["Biker Cocaine Female"] = "mp_f_cocaine_01",
        ["FIB Security"] = "mp_m_fibsec_01",
        ["Shopkeeper (Male)"] = "mp_m_shopkeep_01",
        ["Ex-Army Male"] = "mp_m_exarmy_01",
        ["Avon Goon"] = "mp_m_avongoon",
        ["Biker Meth Female"] = "mp_f_meth_01",
        ["Biker Forgery Male"] = "mp_m_forgery_01",
        ["Heli-Staff Female"] = "mp_f_helistaff_01",
        ["John Marston"] = "mp_m_marston_01",
        ["Vagos Funeral"] = "mp_m_g_vagfun_01",
        ["Warehouse Mechanic (Male)"] = "mp_m_waremech_01",
        ["Armoured Van Security Male"] = "mp_s_m_armoured_01",
        ["Biker Weed Male"] = "mp_m_weed_01",
        ["Freemode Female"] = "mp_f_freemode_01",
        ["Office Garage Mechanic (Female)"] = "mp_f_cardesign_01",
        ["Weapon Work (Male)"] = "mp_m_weapwork_01",
        ["Weapon Exp (Male)"] = "mp_m_weapexp_01",
        ["Executive PA Female"] = "mp_f_execpa_01",
        ["Benny Mechanic (Female)"] = "mp_f_bennymech_01",
        ["Biker Forgery Female"] = "mp_f_forgery_01",
        ["Stripper Lite (Female)"] = "mp_f_stripperlite",
        ["Biker Counterfeit Male"] = "mp_m_counterfeit_01",
        ["Clubhouse Bar Female"] = "mp_f_chbar_01",
        ["Boat-Staff Male"] = "mp_m_boatstaff_01",
        ["Niko Bellic"] = "mp_m_niko_01",
        ["Biker Cocaine Male"] = "mp_m_cocaine_01",
        ["Executive PA Male"] = "mp_m_execpa_01",
        ["Biker Counterfeit Female"] = "mp_f_counterfeit_01",
        ["Pros"] = "mp_g_m_pros_01"
    },
    ["Player"] = {
        ["Freemode Female"] = "mp_f_freemode_01",
        ["Trevor"] = "player_two",
        ["Freemode Male"] = "mp_m_freemode_01",
        ["Franklin"] = "player_one",
        ["Michael"] = "player_zero"
    },
    ["Ambient Male"] = {
        ["Road Cyclist"] = "a_m_y_roadcyc_01",
        ["South Central Young Male 4"] = "a_m_y_soucent_04",
        ["Tourist Male"] = "a_m_m_tourist_01",
        ["Transvestite Male 2"] = "a_m_m_tranvest_02",
        ["Hippie Male"] = "a_m_y_hippy_01",
        ["Hipster Male 2"] = "a_m_y_hipster_02",
        ["Business Young Male"] = "a_m_y_business_01",
        ["Vinewood Male 4"] = "a_m_y_vinewood_04",
        ["Vinewood Male 3"] = "a_m_y_vinewood_03",
        ["Beach Muscle Male"] = "a_m_y_musclbeac_01",
        ["Golfer Male"] = "a_m_m_golfer_01",
        ["Gay Male 2"] = "a_m_y_gay_02",
        ["Farmer"] = "a_m_m_farmer_01",
        ["Business Casual"] = "a_m_y_busicas_01",
        ["Beach Male 2"] = "a_m_m_beach_02",
        ["Beverly Hills Male"] = "a_m_m_bevhills_01",
        ["Hiker Male"] = "a_m_y_hiker_01",
        ["South Central Young Male 2"] = "a_m_y_soucent_02",
        ["Epsilon Male"] = "a_m_y_epsilon_01",
        ["Korean Young Male"] = "a_m_y_ktown_01",
        ["Skater Young Male"] = "a_m_y_skater_01",
        ["Hipster Male 3"] = "a_m_y_hipster_03",
        ["Car Club Male"] = "a_m_y_carclub_01",
        ["Fat Latino Male"] = "a_m_m_fatlatin_01",
        ["Altruist Cult Young Male 2"] = "a_m_y_acult_02",
        ["Hillbilly Male 2"] = "a_m_m_hillbilly_02",
        ["Hasidic Jew Male"] = "a_m_m_hasjew_01",
        ["Beach Male"] = "a_m_m_beach_01",
        ["Black Street Male 2"] = "a_m_y_stbla_02",
        ["Mexican Thug"] = "a_m_y_mexthug_01",
        ["General Street Young Male 2"] = "a_m_y_genstreet_02",
        ["Breakdancer Male"] = "a_m_y_breakdance_01",
        ["Skater Male"] = "a_m_m_skater_01",
        ["Golfer Young Male"] = "a_m_y_golfer_01",
        ["Salton Male"] = "a_m_m_salton_01",
        ["South Central Young Male 3"] = "a_m_y_soucent_03",
        ["Hillbilly Male"] = "a_m_m_hillbilly_01",
        ["Beach Young Male"] = "a_m_y_beach_01",
        ["Korean Young Male 2"] = "a_m_y_ktown_02",
        ["Jogger Male 2"] = "a_m_y_runner_02",
        ["Epsilon Male 2"] = "a_m_y_epsilon_02",
        ["Korean Old Male"] = "a_m_o_ktown_01",
        ["Tramp Old Male"] = "a_m_o_tramp_01",
        ["Business Young Male 3"] = "a_m_y_business_03",
        ["Beverly Hills Young Male 2"] = "a_m_y_bevhills_02",
        ["Polynesian"] = "a_m_m_polynesian_01",
        ["Hipster Male"] = "a_m_y_hipster_01",
        ["Beach Young Male 4"] = "a_m_y_beach_04",
        ["Indian Young Male"] = "a_m_y_indian_01",
        ["Salton Young Male"] = "a_m_y_salton_01",
        ["Indian Male"] = "a_m_m_indian_01",
        ["Salton Male 3"] = "a_m_m_salton_03",
        ["East SA Male"] = "a_m_m_eastsa_01",
        ["Rural Meth Addict Male"] = "a_m_m_rurmeth_01",
        ["Polynesian Young"] = "a_m_y_polynesian_01",
        ["Mexican Rural"] = "a_m_m_mexcntry_01",
        ["Sunbather Male"] = "a_m_y_sunbathe_01",
        ["Korean Male"] = "a_m_m_ktown_01",
        ["Surfer"] = "a_m_y_surfer_01",
        ["South Central Old Male 2"] = "a_m_o_soucent_02",
        ["Club Customer Male 3"] = "a_m_y_clubcust_03",
        ["Black Street Male"] = "a_m_y_stbla_01",
        ["Beach Tramp Male"] = "a_m_m_trampbeac_01",
        ["Altruist Cult Old Male 2"] = "a_m_o_acult_02",
        ["Meth Addict"] = "a_m_y_methhead_01",
        ["Midlife Crisis Casino Bikers"] = "a_m_m_mlcrisis_01",
        ["Club Customer Male 4"] = "a_m_y_clubcust_04",
        ["Salton Male 4"] = "a_m_m_salton_04",
        ["Formel Casino Guests"] = "a_m_y_smartcaspat_01",
        ["Tramp Male"] = "a_m_m_tramp_01",
        ["Downhill Cyclist"] = "a_m_y_dhill_01",
        ["Altruist Cult Young Male"] = "a_m_y_acult_01",
        ["Gay Male"] = "a_m_y_gay_01",
        ["Latino Young Male"] = "a_m_y_latino_01",
        ["Beach Old Male"] = "a_m_o_beach_01",
        ["Tattoo Cust Male"] = "a_m_y_tattoocust_01",
        ["Jogger Male"] = "a_m_y_runner_01",
        ["East SA Young Male"] = "a_m_y_eastsa_01",
        ["African American Male"] = "a_m_m_afriamer_01",
        ["General Street Old Male"] = "a_m_o_genstreet_01",
        ["General Street Young Male"] = "a_m_y_genstreet_01",
        ["Yoga Male"] = "a_m_y_yoga_01",
        ["Paparazzi Male"] = "a_m_m_paparazzi_01",
        ["Club Customer Male 1"] = "a_m_y_clubcust_01",
        ["White Street Male 2"] = "a_m_y_stwhi_02",
        ["White Street Male"] = "a_m_y_stwhi_01",
        ["Beach Young Male 3"] = "a_m_y_beach_03",
        ["Vinewood Male 2"] = "a_m_y_vinewood_02",
        ["Hasidic Jew Young Male"] = "a_m_y_hasjew_01",
        ["Vinewood Male"] = "a_m_y_vinewood_01",
        ["Altruist Cult Mid-Age Male"] = "a_m_m_acult_01",
        ["Jetskier"] = "a_m_y_jetski_01",
        ["Vinewood Douche"] = "a_m_y_vindouche_01",
        ["East SA Male 2"] = "a_m_m_eastsa_02",
        ["Malibu Male"] = "a_m_m_malibu_01",
        ["Vespucci Beach Male 2"] = "a_m_y_beachvesp_02",
        ["Downtown Male"] = "a_m_y_downtown_01",
        ["General Fat Male"] = "a_m_m_genfat_01",
        ["General Fat Male 2"] = "a_m_m_genfat_02",
        ["Vespucci Beach Male"] = "a_m_y_beachvesp_01",
        ["Business Young Male 2"] = "a_m_y_business_02",
        ["Beverly Hills Male 2"] = "a_m_m_bevhills_02",
        ["Transvestite Male"] = "a_m_m_tranvest_01",
        ["South Central Young Male"] = "a_m_y_soucent_01",
        ["OG Boss"] = "a_m_m_og_boss_01",
        ["Tennis Player Male"] = "a_m_m_tennis_01",
        ["Altruist Cult Old Male"] = "a_m_o_acult_01",
        ["Beach Old Male 2"] = "a_m_o_beach_02",
        ["South Central Old Male"] = "a_m_o_soucent_01",
        ["Latino Street Young Male"] = "a_m_y_stlat_01",
        ["Beach Young Male 2"] = "a_m_y_beach_02",
        ["South Central Old Male 3"] = "a_m_o_soucent_03",
        ["Juggalo Male"] = "a_m_y_juggalo_01",
        ["Skid Row Male"] = "a_m_m_skidrow_01",
        ["South Central Male 4"] = "a_m_m_soucent_04",
        ["South Central Male 3"] = "a_m_m_soucent_03",
        ["South Central Male 2"] = "a_m_m_soucent_02",
        ["South Central Male"] = "a_m_m_soucent_01",
        ["Beverly Hills Young Male"] = "a_m_y_bevhills_01",
        ["Business Male"] = "a_m_m_business_01",
        ["Salton Male 2"] = "a_m_m_salton_02",
        ["South Central Latino Male"] = "a_m_m_socenlat_01",
        ["Salton Old Male"] = "a_m_o_salton_01",
        ["Skater Young Male 2"] = "a_m_y_skater_02",
        ["East SA Young Male 2"] = "a_m_y_eastsa_02",
        ["Mexican Labourer"] = "a_m_m_mexlabor_01",
        ["Prologue Host Male"] = "a_m_m_prolhost_01",
        ["Club Customer Male 2"] = "a_m_y_clubcust_02",
        ["Casual Casino Guests"] = "a_m_y_gencaspat_01",
        ["Motocross Biker 2"] = "a_m_y_motox_02",
        ["Beach Muscle Male 2"] = "a_m_y_musclbeac_02",
        ["Latino Street Male 2"] = "a_m_m_stlat_02",
        ["Cyclist Male"] = "a_m_y_cyclist_01",
        ["Motocross Biker"] = "a_m_y_motox_01"
    },
    ["Ambient Female"] = {
        ["Salton Old Female"] = "a_f_o_salton_01",
        ["Business Young Female"] = "a_f_y_business_01",
        ["Skater Female"] = "a_f_y_skater_01",
        ["Juggalo Female"] = "a_f_y_juggalo_01",
        ["East SA Young Female 3"] = "a_f_y_eastsa_03",
        ["South Central Young Female 2"] = "a_f_y_soucent_02",
        ["East SA Female"] = "a_f_m_eastsa_01",
        ["Fat White Female"] = "a_f_m_fatwhite_01",
        ["Fitness Female"] = "a_f_y_fitness_01",
        ["Hipster Female 2"] = "a_f_y_hipster_02",
        ["Casual Casino Guest"] = "a_f_y_gencaspat_01",
        ["Beverly Hills Young Female 4"] = "a_f_y_bevhills_04",
        ["Downtown Female"] = "a_f_m_downtown_01",
        ["General Hot Young Female"] = "a_f_y_genhot_01",
        ["South Central Young Female"] = "a_f_y_soucent_01",
        ["Fat Cult Female"] = "a_f_m_fatcult_01",
        ["Hiker Female"] = "a_f_y_hiker_01",
        ["Club Customer Female 1"] = "a_f_y_clubcust_01",
        ["Formel Casino Guest"] = "a_f_y_smartcaspat_01",
        ["Beverly Hills Young Female 3"] = "a_f_y_bevhills_03",
        ["East SA Female 2"] = "a_f_m_eastsa_02",
        ["Vinewood Female 2"] = "a_f_y_vinewood_02",
        ["Indian Young Female"] = "a_f_y_indian_01",
        ["Tourist Female"] = "a_f_m_tourist_01",
        ["Beverly Hills Young Female 2"] = "a_f_y_bevhills_02",
        ["Beverly Hills Female"] = "a_f_m_bevhills_01",
        ["Club Customer Female 2"] = "a_f_y_clubcust_02",
        ["Business Young Female 3"] = "a_f_y_business_03",
        ["Dressy Female"] = "a_f_y_scdressy_01",
        ["Beach Young Female 2"] = "a_f_y_beach_02",
        ["Yoga Female"] = "a_f_y_yoga_01",
        ["East SA Young Female"] = "a_f_y_eastsa_01",
        ["Business Female 2"] = "a_f_m_business_02",
        ["Skid Row Female"] = "a_f_m_skidrow_01",
        ["South Central Female"] = "a_f_m_soucent_01",
        ["South Central MC Female"] = "a_f_m_soucentmc_01",
        ["Car Club Female"] = "a_f_y_carclub_01",
        ["Beach Young Female"] = "a_f_y_beach_01",
        ["Hipster Female 3"] = "a_f_y_hipster_03",
        ["Beach Female"] = "a_f_m_beach_01",
        ["Tramp Female"] = "a_f_m_tramp_01",
        ["Korean Female"] = "a_f_m_ktown_01",
        ["Beverly Hills Female 2"] = "a_f_m_bevhills_02",
        ["Indian Old Female"] = "a_f_o_indian_01",
        ["Golfer Young Female"] = "a_f_y_golfer_01",
        ["Tourist Young Female 2"] = "a_f_y_tourist_02",
        ["Fat Black Female"] = "a_f_m_fatbla_01",
        ["Beverly Hills Young Female 5"] = "a_f_y_bevhills_05",
        ["Club Customer Female 4"] = "a_f_y_clubcust_04",
        ["Club Customer Female 3"] = "a_f_y_clubcust_03",
        ["Vinewood Female 4"] = "a_f_y_vinewood_04",
        ["Vinewood Female 3"] = "a_f_y_vinewood_03",
        ["Vinewood Female"] = "a_f_y_vinewood_01",
        ["Tourist Young Female"] = "a_f_y_tourist_01",
        ["Hipster Female"] = "a_f_y_hipster_01",
        ["Bodybuilder Female"] = "a_f_m_bodybuild_01",
        ["Business Young Female 2"] = "a_f_y_business_02",
        ["Korean Old Female"] = "a_f_o_ktown_01",
        ["Epsilon Female"] = "a_f_y_epsilon_01",
        ["South Central Old Female"] = "a_f_o_soucent_01",
        ["Jogger Female"] = "a_f_y_runner_01",
        ["Female Agent"] = "a_f_y_femaleagent",
        ["Beverly Hills Young Female"] = "a_f_y_bevhills_01",
        ["South Central Young Female 3"] = "a_f_y_soucent_03",
        ["Hipster Female 4"] = "a_f_y_hipster_04",
        ["Prologue Host Female"] = "a_f_m_prolhost_01",
        ["South Central Old Female 2"] = "a_f_o_soucent_02",
        ["Tennis Player Female"] = "a_f_y_tennis_01",
        ["South Central Female 2"] = "a_f_m_soucent_02",
        ["Business Young Female 4"] = "a_f_y_business_04",
        ["Fitness Female 2"] = "a_f_y_fitness_02",
        ["East SA Young Female 2"] = "a_f_y_eastsa_02",
        ["Salton Female"] = "a_f_m_salton_01",
        ["Beach Tramp Female"] = "a_f_m_trampbeac_01",
        ["Rural Meth Addict Female"] = "a_f_y_rurmeth_01",
        ["General Street Old Female"] = "a_f_o_genstreet_01",
        ["Korean Female 2"] = "a_f_m_ktown_02",
        ["Hippie Female"] = "a_f_y_hippie_01",
        ["Topless"] = "a_f_y_topless_01"
    }
}
 end)
package.preload['src.consts.anim_list'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				return {
    ["Naughty"] = {
        ["All Fours"] = {
            dict = "random@peyote@dog",
            animation = "wakeup_loop"
        },
        ["Bent Over"] = {
            dict = "switch@trevor@naked_on_bridge",
            animation = "002055_01_trvs_17_naked_on_bridge_idle"
        },
        ["Pooping"] = {
            dict = "timetable@trevor@on_the_toilet",
            animation = "trevonlav_baseloop"
        },
        ["Wiggle"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_intro",
            animation = "ld_2g_intro_s2"
        },
        ["Bump and Grind"] = {
            dict = "anim@amb@nightclub@peds@",
            animation = "mini_strip_club_private_dance_idle_priv_dance_idle"
        },
        ["Butthump"] = {
            dict = "timetable@trevor@skull_loving_bear",
            animation = "skull_loving_bear"
        },
        ["Humping Air"] = {
            dict = "family_4_mcs_2-14",
            animation = "cs_tracydisanto_dual-14"
        },
        ["Shake Your Ass"] = {
            dict = "switch@trevor@mocks_lapdance",
            animation = "001443_01_trvs_28_idle_stripper"
        },
        ["Street_Corner Sexy 1"] = {
            dict = "amb@world_human_prostitute@french@base",
            animation = "base"
        },
        ["Street_Corner Sexy 2"] = {
            dict = "amb@world_human_prostitute@hooker@base",
            animation = "base"
        },
        ["Street_Corner Sexy 3"] = {
            dict = "amb@world_human_prostitute@cokehead@base",
            animation = "base"
        },
        ["Street_Corner Sexy 4"] = {
            dict = "amb@world_human_prostitute@crackhooker@base",
            animation = "base"
        },
        ["Street_Corner Sexy 5"] = {
            dict = "switch@michael@prostitute",
            animation = "base_hooker"
        },
        ["Stripper Wait 1"] = {
            dict = "mini@strip_club@idles@stripper",
            animation = "stripper_idle_06"
        },
        ["Stripper Wait 2"] = {
            dict = "mini@strip_club@idles@stripper",
            animation = "stripper_idle_04"
        },
        ["Stripper Wait 3"] = {
            dict = "mini@strip_club@idles@stripper",
            animation = "stripper_idle_03"
        },
        ["Stripper Wait 4"] = {
            dict = "mini@strip_club@idles@stripper",
            animation = "stripper_idle_01"
        },
        ["Stripper Wait 5"] = {
            dict = "mini@strip_club@idles@stripper",
            animation = "stripper_idle_02"
        }
    },
    ["Blowjob"] = {
        ["Blowjob Female"] = {
            dict = "misscarsteal2pimpsex",
            animation = "pimpsex_hooker"
        },
        ["Peeing"] = {
            dict = "misscarsteal2peeing",
            animation = "peeing_loop"
        }
    },
    ["Sex"] = {
        ["Shag Female"] = {
            dict = "rcmpaparazzo_2",
            animation = "shag_loop_poppy"
        },
        ["Shag Hooker"] = {
            dict = "misscarsteal2pimpsex",
            animation = "shagloop_hooker"
        },
        ["Shag Male"] = {
            dict = "rcmpaparazzo_2",
            animation = "shag_loop_a"
        },
        ["Shag Pimp"] = {
            dict = "misscarsteal2pimpsex",
            animation = "shagloop_pimp"
        }
    },
    ["Lap Dance"] = {
        ["Lap Dance 1"] = {
            dict = "mp_am_stripper",
            animation = "lap_dance_girl"
        },
        ["Lap Dance 10"] = {
            dict = "mini@strip_club@lap_dance@ld_girl_a_song_a_p3",
            animation = "ld_girl_a_song_a_p3_f"
        },
        ["Lap Dance 11"] = {
            dict = "anim@amb@nightclub@peds@",
            animation = "mini_strip_club_lap_dance_ld_girl_a_song_a_p1"
        },
        ["Lap Dance 2"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_p1",
            animation = "ld_2g_p1_s1"
        },
        ["Lap Dance 3"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_p2",
            animation = "ld_2g_p2_s2"
        },
        ["Lap Dance 4"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_p1",
            animation = "ld_2g_p1_s2"
        },
        ["Lap Dance 5"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_p3_",
            animation = "ld_2g_p3_s1"
        },
        ["Lap Dance 6"] = {
            dict = "oddjobs@assassinate@multi@yachttarget@lapdance",
            animation = "yacht_ld_f"
        },
        ["Lap Dance 7"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_p3",
            animation = "ld_2g_p3_s2"
        },
        ["Lap Dance 8"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_p2",
            animation = "ld_2g_p2_s1"
        },
        ["Lap Dance 9"] = {
            dict = "mini@strip_club@lap_dance_2g@ld_2g_p3",
            animation = "ld_2g_p3_s1"
        }
    },
    ["Private Dance"] = {
        ["Private Dance 1"] = {
            dict = "mini@strip_club@private_dance@part1",
            animation = "priv_dance_p1"
        },
        ["Private Dance 2"] = {
            dict = "mini@strip_club@private_dance@part2",
            animation = "priv_dance_p2"
        },
        ["Private Dance 3"] = {
            dict = "mini@strip_club@private_dance@part3",
            animation = "priv_dance_p3"
        }
    },
    ["Pole Dance"] = {
        ["Pole Dance 1"] = {
            dict = "mini@strip_club@pole_dance@pole_dance1",
            animation = "pd_dance_01"
        },
        ["Pole Dance 2"] = {
            dict = "mini@strip_club@pole_dance@pole_dance2",
            animation = "pd_dance_02"
        },
        ["Pole Dance 3"] = {
            dict = "mini@strip_club@pole_dance@pole_dance3",
            animation = "pd_dance_03"
        }
    },
    ["Masturbate"] = {
        ["Masturbate 1"] = {
            dict = "timetable@amanda@ig_6",
            animation = "ig_6__base"
        },
        ["Masturbate 2"] = {
            dict = "switch@trevor@jerking_off",
            animation = "trev_jerking_off_loop"
        }
    },
    ["Vehicle"] = {
        ["Blowjob in Car Female"] = {
            dict = "mini@prostitutes@sexlow_veh",
            animation = "low_car_bj_loop_female"
        },
        ["Blowjob in Car Male"] = {
            dict = "mini@prostitutes@sexlow_veh",
            animation = "low_car_bj_loop_player"
        },

        ["Car Sex Female"] = {
            dict = "mini@prostitutes@sexlow_veh",
            animation = "low_car_sex_loop_female"
        },
        ["Car Sex Male"] = {
            dict = "mini@prostitutes@sexlow_veh",
            animation = "low_car_sex_loop_player"
        }
    }

}
 end)
package.preload['src.lib.actor'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				-- Adapted from Wiriscipt
local PedList<const> = require "src.consts.ped_list"

if not filesystem.exists(AnimXDir) then filesystem.mkdir(AnimXDir) end

if not filesystem.exists(AnimXDir .. "actors") then filesystem.mkdir(AnimXDir .. "actors") end

-------------------------------------
-- ACTORS MENU
-------------------------------------

local trans = {
    Clone = LOC.actorMenu.clone,
    ReachedMaxNumActors = LOC.actorMenu.reachedMaxNumActors,
    Unknown = LOC.actorMenu.unknown,
    InvalidOutfit = LOC.templates.invalidOutfit
}

---@class ActorMenu
ActorMenu = {
    ref = 0,
    divider = 0,
    isOpen = false,
    ---@type Group
    group = {}
}
ActorMenu.__index = ActorMenu

---@param parent integer|CommandRef
---@param name string
---@param command_names? table
---@return ActorMenu
function ActorMenu.new(parent, name, command_names)
    local self = setmetatable({}, ActorMenu)
    self.ref = menu.list(parent, name, command_names or {}, "", function() self.isOpen = true end,
        function() self.isOpen = false end)
    self.group = Group.new()

    ModelList.new(self.ref, LOC.actorMenu.spawn, "animxspawnbg", "", PedList, function(caption, model)
        if self.group:getSize() >= 7 then return notification:help(trans.ReachedMaxNumActors, HudColour.red) end
        local modelHash<const> = util.joaat(model)
        util.request_model(modelHash, 2000)
        local member = Member:createMember(modelHash)
        self.group:pushMember(member)
        local weaponHash = self.group.defaults.weaponHash
        if is_ped_any_animal(member.handle) then weaponHash = util.joaat("weapon_animal") end
        member:giveWeapon(weaponHash)
        member:createMgr(self.ref, caption)
        if self.group.defaults.invincible then member:setInvincible(true) end
    end, false, true)

    menu.action(self.ref, LOC.actorMenu.cloneMyself, {"animxclonebg"}, "", function()
        if self.group:getSize() >= 7 then return notification:help(trans.ReachedMaxNumActors, HudColour.red) end
        local member = Member:createMember()
        self.group:pushMember(member)
        local weaponHash = self.group.defaults.weaponHash
        if is_ped_any_animal(member.handle) then weaponHash = util.joaat("weapon_animal") end
        member:giveWeapon(weaponHash)
        member:createMgr(self.ref, trans.Clone)
        if self.group.defaults.invincible then member:setInvincible(true) end
    end)

    local savedFileOpts = {LOC.actorMenu.spawn, LOC.actorMenu.deleteFile}
    local saved
    saved = FileList.new(self.ref, LOC.actorMenu.saved, savedFileOpts, AnimXDir .. "actors", "json",
        function(opt, name, path)
            if opt == 1 then
                if self.group:getSize() >= 7 then
                    return notification:help(trans.ReachedMaxNumActors, HudColour.red)
                end
                local ok, result = json.parse(path)
                if not ok then return notification:help(result, HudColour.red) end

                local modelHash<const> = result.ModelHash
                -- void util.request_model(int|string model, int timeout = 2000)
                util.request_model(modelHash, 2000)
                local member = Member:createMember(modelHash)
                self.group:pushMember(member)

                local weaponHash = result.WeaponHash
                if is_ped_any_animal(member.handle) and weaponHash ~= util.joaat("weapon_animal") then
                    weaponHash = util.joaat("weapon_animal")
                end

                local ok, errmsg = member:setOutfit(result.Outfit)
                if not ok then AnimXUtils.toast(trans.InvalidOutfit, name, errmsg) end

                member:giveWeapon(weaponHash)
                member:createMgr(self.ref, name)
                if self.group.defaults.invincible then member:setInvincible(true) end

            else
                local ok, errmsg = os.remove(path)
                if not ok then return notification:help(errmsg, HudColour.red) end
                saved:reload()
            end
        end)

    self:createCommands(self.ref)
    self.divider = menu.divider(self.ref, LOC.actorMenu.spawnedActors)
    for _, member in ipairs(self.group.members) do
        if member.mgr == 0 then member:createMgr(self.ref, trans.Unknown) end
    end
    return self
end

---@param parent integer
function ActorMenu:createCommands(parent)
    local list = menu.list(parent, LOC.actorMenu.group, {}, "")
    local formations<const> = {LOC.actorMenu.freedom, LOC.actorMenu.circle, LOC.actorMenu.line, LOC.actorMenu.arrow}
    -- CommandRef|CommandUniqPtr menu.list_select(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, table<int, table> options, int default_value, function on_change)
    -- options must be table of list action item data or Label. List action item data is an index-based table that contains at least a Label (menu_name), and can optionally have command_names and help_text.

    -- Your on_change function will be called with the option's index, the option's menu_name, and previous option's index, and click_type as parameters.
    menu.list_select(list, LOC.actorMenu.groupFormation, {"animxgroupformation"}, "", formations, 2,
        function(index, option, prevIndex, clickType)
            local formation
            if index == 1 then
                formation = Formation.freedomToMove
            elseif index == 2 then
                formation = Formation.circleAroundLeader
            elseif index == 3 then
                formation = Formation.line
            elseif index == 4 then
                formation = Formation.arrow
            else
                error("got unexpected option")
            end
            self.group:setFormation(formation)
        end)

    local relGroups<const> = {
        {LOC.actorMenu.likePlayers, {"like"}}, {LOC.actorMenu.dislikePlayersLikeGangs, {"dislike"}},
        {LOC.actorMenu.hatePlayersLikeGangs, {"hate"}}, {LOC.actorMenu.likePlayersHatePlayerHaters, {"hatehaters"}},
        {LOC.actorMenu.dislikePlayersLikeCops, {"dislikeplyrlikecops"}},
        {LOC.actorMenu.hatePlayersLikeCops, {"hateplyrlikecops"}}, {LOC.actorMenu.hateEveryone, {"hateall"}}}
    local menuName = LOC.actorMenu.relationshipGroup
    local helpText = LOC.actorMenu.onlineOnly
    menu.list_select(list, menuName, {"rg"}, helpText, relGroups, 7, function(opt)
        local rg
        if opt == 1 then
            rg = util.joaat("rgFM_AiLike")
        elseif opt == 2 then
            rg = util.joaat("rgFM_AiDislike")
        elseif opt == 3 then
            rg = util.joaat("rgFM_AiHate")
        elseif opt == 4 then
            rg = util.joaat("rgFM_AiLike_HateAiHate")
        elseif opt == 5 then
            rg = util.joaat("rgFM_AiDislikePlyrLikeCops")
        elseif opt == 6 then
            rg = util.joaat("rgFM_AiHatePlyrLikeCops")
        elseif opt == 7 then
            rg = util.joaat("rgFM_HateEveryOne")
        end
        self.group:setRelationshipGrp(rg)
    end)

    menu.action(list, LOC.actorMenu.deleteMembers, {"animxcleargroup"}, "", function() self.group:deleteMembers() end)
    menu.action(list, LOC.actorMenu.teleportMembersToMe, {"animxtpmembers"}, "", function() self.group:teleport() end)
    menu.toggle(list, LOC.actorMenu.invincible, {"animxgroupgodmode"}, "", function(on) self.group:setInvincible(on) end)
    WeaponList.new(list, LOC.actorMenu.defaultWeapon, "animxgroupgun", "",
        function(caption, model) self.group.defaults.weaponHash = util.joaat(model) end, true)
end

function ActorMenu:onTick()
    if self.group.numMembers ~= 0 then
        if self.isOpen and not menu.get_visible(self.divider) then menu.set_visible(self.divider, true) end
        self.group:onTick()
    elseif self.isOpen and menu.get_visible(self.divider) then
        menu.set_visible(self.divider, false)
    end
end

 end)
package.preload['src.lib.menus'] = (function (...)
					local _ENV = _ENV;
					local function module(name, ...)
						local t = package.loaded[name] or _ENV[name] or { _NAME = name };
						package.loaded[name] = t;
						for i = 1, select("#", ...) do
							(select(i, ...))(t);
						end
						_ENV = t;
						_M = t;
						return t;
					end
				local updater = require "src.lib.misc.updater"
local animXAudio = require "src.lib.audio"

if not async_http.have_access() then
    AnimXUtils.toast(LOC.noInternetAccess)
    util.stop_script()
end

updater.runUpdater(0)

animxConfig = {
    debugMode = false
}

local resourcesDir = filesystem.resources_dir() .. string.format("/%s/", SCRIPT_NAME)
if not filesystem.is_dir(resourcesDir) then
    util.toast("ALERT: resources dir is missing! Please make sure you installed AnimX properly.")
end

local logo = directx.create_texture(resourcesDir .. 'AnimXLogo.png')

if SCRIPT_MANUAL_START then
    AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Pre_Screen_Stinger", players.user_ped(), "DLC_HEISTS_FINALE_SCREEN_SOUNDS", true,
        20)
    local logoAlpha = 0
    local logoAlphaDelta = 0.01
    util.create_thread(function(thr)
        local starttime = os.clock()
        while true do
            logoAlpha = logoAlpha + logoAlphaDelta
            directx.draw_texture(logo, 0.14, 0.14, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, logoAlpha)

            if os.clock() - starttime > 3 then logoAlphaDelta = -0.01 end

            if logoAlpha > 0.5 then
                logoAlpha = 0.5
            elseif logoAlpha < 0 then
                logoAlpha = 0
                break
            end

            util.yield()
        end
    end)
end

local attireRoot = menu.my_root():list(LOC.attire, {"animxattire"}, "")
local locationsRoot = menu.my_root():list(LOC.specialLocations, {"animxlocations"}, "")
---@type CommandRef
local moansRoot = menu.my_root():list(LOC.moans, {"animxmoans"}, "")

local voices = {
    [1] = {
        name = "Female moan",
        voice = "S_F_Y_HOOKER_01_WHITE_FULL_01",
        speech = "SEX_GENERIC_FEM"
    },
    [2] = {
        name = "Male moan",
        voice = "MICHAEL_NORMAL",
        speech = "SEX_GENERIC"
    },
    [3] = {
        name = "Female blowjob",
        voice = "S_F_Y_HOOKER_01_WHITE_FULL_01",
        speech = "SEX_ORAL_FEM"
    },
    [4] = {
        name = "Male climax",
        voice = "MICHAEL_NORMAL",
        speech = "SEX_CLIMAX"
    }
}
local voiceOptions = {}
for _, v in ipairs(voices) do table.insert(voiceOptions, v.name) end

moansRoot:list_action(LOC.moans, {"moans"}, "", voiceOptions, function(index, value, click_type)
    local targetPed = PLAYER.PLAYER_PED_ID()
    local voice
    local speech
    local z_off = 0
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        z_off = AnimXUtils.getModelSize(ENTITY.GET_ENTITY_MODEL(PED.GET_VEHICLE_PED_IS_IN(targetPed, false))).z
    end

    local case = voices[index]

    if case then
        voice = case.voice
        speech = case.speech
    end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetPed, 0.0, -1.0, 0.0 + z_off)
    -- AUDIO.PLAY_AMBIENT_SPEECH_FROM_POSITION_NATIVE(speech, voice, coords.x, coords.y, coords.z, "SPEECH_PARAMS_FORCE_SHOUTED")
    AnimXUtils.requestModelLoad("s_f_m_shop_high")
    local voicePed = entities.create_ped(28, util.joaat("s_f_m_shop_high"), coords, 0)
    AnimXUtils.debugLog("voicePed: " .. tostring(voicePed))
    ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(voicePed, true, false)
    ENTITY.SET_ENTITY_VISIBLE(voicePed, false, 0)
    ENTITY.FREEZE_ENTITY_POSITION(voicePed, true)
    ENTITY.SET_ENTITY_INVINCIBLE(voicePed, true)
    AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(voicePed, speech, voice, "SPEECH_PARAMS_FORCE", 0)
    while AUDIO.IS_AMBIENT_SPEECH_PLAYING(voicePed) do util.yield(100) end
    AnimXUtils.debugLog("Deleting voicePed")
    entities.delete(voicePed)
end)

attireRoot:action("Topless female", {"sextoplessf"}, "", function(on_click) menu.trigger_commands("toplessfemale") end)

attireRoot:action("Attach dildo", {"sexstrapon"}, "", function(on_click)
    AnimXUtils.requestModelLoad("prop_cs_dildo_01")
    AnimXUtils.createEntityAndAttachTo(0.15, 0.15, 0.0, players.user_ped(), -90.0, 0.0, 0.0, "prop_cs_dildo_01",
        BoneIds.SKEL_Pelvis, false, false)
end)

attireRoot:action("Clear attached entities", {"clearattach"}, "", function(on_click)
    -- local attachmentHandle = ENTITY.GET_ENTITY_ATTACHED_TO(PLAYER.PLAYER_PED_ID())
    -- if attachmentHandle ~= 0 then
    --     AnimXUtils.debugLog("Deleting attachmentHandle: " .. attachmentHandle)
    --     GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(attachmentHandle)
    --     entities.delete(attachmentHandle)
    -- end
    ENTITY.DETACH_ENTITY(PLAYER.PLAYER_PED_ID(), true, false)
end)

-- CommandRef|CommandUniqPtr menu.list(CommandRef parent, Label menu_name, table<any, string> command_names = {}, Label help_text = "", ?function on_click = nil, ?function on_back = nil, ?function on_active_list_update = nil)
---@type CommandRef
local autoCleanCharacterRef = attireRoot:list(LOC.autoCleanCharacter, {"autocleancharacter"}, LOC.autoCleanCharacterD)

local autoCleanCharacterBloodRef
local autoCleanCharacterWetnessRef
local autoCleanCharacterDirtRef

autoCleanCharacterRef:action(LOC.enableCleanAll, {"enablecleanall"}, LOC.enableCleanAllD, function(on_click)
    menu.set_value(autoCleanCharacterBloodRef, true)
    menu.set_value(autoCleanCharacterWetnessRef, true)
    menu.set_value(autoCleanCharacterDirtRef, true)
end)

autoCleanCharacterRef:action(LOC.disableCleanAll, {"disablecleanall"}, LOC.disableCleanAllD, function(on_click)
    menu.set_value(autoCleanCharacterBloodRef, false)
    menu.set_value(autoCleanCharacterWetnessRef, false)
    menu.set_value(autoCleanCharacterDirtRef, false)
end)

autoCleanCharacterBloodRef = autoCleanCharacterRef:toggle_loop(LOC.blood, {"cleanblood"}, "", function()
    PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID())
end)

autoCleanCharacterWetnessRef = autoCleanCharacterRef:toggle_loop(LOC.wetness, {"cleanwetness"}, "", function()
    PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
end)

autoCleanCharacterDirtRef = autoCleanCharacterRef:toggle_loop(LOC.dirt, {"cleandirt"}, "", function()
    PED.CLEAR_PED_ENV_DIRT(PLAYER.PLAYER_PED_ID())
end)

menu.action(locationsRoot, "Motel room", {"sexinmotel"}, "", function(on_click) menu.trigger_commands("tpmotelroom") end)

menu.action(locationsRoot, "Bahama mamas", {"sexinbahamasmamas"}, "",
    function(on_click) menu.trigger_commands("tpbahamamamas") end)

menu.action(locationsRoot, "Torture room", {"sexintortureroom"}, "",
    function(on_click) menu.trigger_commands("tptortureroom") end)

menu.action(locationsRoot, "Floyd\'s house", {"sexinfloydhouse"}, "",
    function(on_click) menu.trigger_commands("tpfloyd") end)

local actorMenu<const> = ActorMenu.new(menu.my_root(), LOC.actorMenu.actorsMenu, {"animxactorsmenu"})

local animMenu<const> = AnimMenu.new(menu.my_root(), LOC.animMenu.animMenu, "animxanimmenu", LOC.animMenu.animMenuD,
    true, players.user(), function(dict, animation)
        -- anim.playAnimOnSelf(dict, animation, -1) deprecated
    end, false, true)

menu.on_focus(animMenu.reference, function() animMenu:refreshPed(players.user()) end)

-- void util.create_tick_handler(function func)
-- Registers the parameter-function to be called every tick until it returns false.
util.create_tick_handler(function() actorMenu:onTick() end)

local miscRoot = menu.my_root():list(LOC.miscmiscellaneous, {}, "")

miscRoot:toggle_loop(LOC.spectateWarning, {}, LOC.spectateWarningD, function()
    for _, player in ipairs(players.list(false)) do
        local target = players.get_spectate_target(player)
        if target ~= -1 then
            util.draw_debug_text(string.format("%s spectating %s", players.get_name(player), players.get_name(target)))
        end
    end
end)

-- CommandRef|CommandUniqPtr menu.toggle(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, function on_change, bool default_on = false)
menu.my_root():toggle("Debug Mode", {}, "", function(on) animxConfig.debugMode = on end, false)

---@param pId integer
local networkPlayerMenuPopulate = function(pId)
    menu.divider(menu.player_root(pId), SCRIPT_NAME)

    AnimMenu.new(menu.player_root(pId), LOC.animMenu.animMenu, "animxanimmenu", LOC.animMenu.animMenuD, true, pId,
        function(dict, animation)
            -- anim.playAnimOnSelf(dict, animation, -1)
        end, false, true)
end
players.on_join(networkPlayerMenuPopulate)
players.dispatch_on_join()
 end)
util.keep_running()
util.require_natives("1676318796")

LOC = require "src.lib.misc.localization"
AnimXUtils = require "src.lib.utils"

AnimXDir = filesystem.store_dir() .. "AnimX\\"


require "src.lib.external.functions"
require "src.lib.misc.filelist"
require "src.lib.misc.labels"

require "src.lib.animlib.anim"

require "src.lib.actorlib.component"
require "src.lib.actorlib.group"
require "src.lib.actorlib.member"
require "src.lib.actorlib.models"
require "src.lib.actorlib.prop"
require "src.lib.actorlib.wardrobe"
require "src.lib.actorlib.weaponsMenu"

require "src.lib.animlib.animMenu"
require "src.lib.actor"

require "src.lib.menus"