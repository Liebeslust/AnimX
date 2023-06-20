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
