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
