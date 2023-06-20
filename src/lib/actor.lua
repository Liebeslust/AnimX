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

