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

