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
