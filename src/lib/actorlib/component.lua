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
