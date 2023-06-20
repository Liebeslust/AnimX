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
